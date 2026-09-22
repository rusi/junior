#!/usr/bin/env python3
"""Prepare reviewed capture bundles and accept verified product replacements."""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / '_shared/scripts'))
from isolation_git import Repository
from isolation_rules import digest, scan, validate_review
from product_isolation import inspect_tree

OWNER = '.capture-owner.json'
LEGACY = '.junior-capture.json'


def safe_path(path: Path) -> Path:
    """Refuse symlinks in any component, including dangling links."""
    absolute = Path(os.path.abspath(path))
    if any(p.is_symlink() for p in (absolute, *absolute.parents)):
        raise ValueError(f'Symlink path refused: {path}')
    return absolute


def repository_root(path: Path) -> Path:
    """Keep storage, destination names, and isolation anchored to the same Git root."""
    path = safe_path(path)
    root = safe_path(Repository(path).path)
    if path != root:
        raise ValueError(f'Use the Git root as --repo: {root}')
    return root


def read_json(path: Path) -> dict:
    if not safe_path(path).is_file():
        raise ValueError(f'Missing regular metadata file: {path}')
    data = json.loads(path.read_bytes())
    if not isinstance(data, dict):
        raise ValueError(f'Expected metadata object: {path}')
    return data


def inventory(directory: Path, exclude_owner: bool = False) -> dict[str, str | None]:
    directory = safe_path(directory)
    if not directory.is_dir():
        raise ValueError(f'Not a real bundle directory: {directory}')
    entries = {}
    for file in sorted(directory.rglob('*')):
        safe_path(file)
        name = file.relative_to(directory).as_posix()
        if file.name.lower() == OWNER:
            if name != OWNER or not file.is_file():
                raise ValueError('Ownership metadata must be a regular bundle-root file')
            if exclude_owner:
                continue
        if file.is_dir():
            entries[name + '/'] = None
        elif file.is_file():
            entries[name] = digest(file.read_bytes())
        else:
            raise ValueError(f'Unsupported bundle entry: {file}')
    return entries


def ownership(root: Path, source: Path, identity: str, marker: str = OWNER) -> dict:
    root, source = safe_path(root), safe_path(source)
    if source.parent != root or not source.is_dir() or not identity.strip():
        raise ValueError('Capture must be a direct child of its root with a nonempty identity')
    owner = read_json(source / marker)
    if owner.get('identity') != identity or not isinstance(owner.get('token'), str) or not owner['token']:
        raise ValueError('Capture ownership does not match the selected identity')
    return owner


def completed(root: Path, source: Path, identity: str) -> dict:
    owner = ownership(root, source, identity)
    contents = inventory(source, exclude_owner=True)
    if 'index.html' not in contents or not owner.get('complete') or owner['complete'] != contents:
        raise ValueError('Capture is incomplete or changed; run the capture with its completion reporter')
    return contents


def migrate(root: Path, source: Path, identity: str) -> None:
    ownership(root, source, identity, LEGACY)
    neutral = source / OWNER
    if neutral.exists() or neutral.is_symlink():
        raise ValueError('Conflicting ownership markers; migration refused')
    # Exclusive creation preserves the exact bytes and refuses a concurrent destination.
    os.link(source / LEGACY, neutral, follow_symlinks=False)
    (source / LEGACY).unlink()


def product_path(repo: Path, destination: str) -> Path:
    parts = destination.split('/')
    if len(parts) < 2 or any(not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', p) or
                             re.search(r'[0-9a-f]{32,}', p) for p in parts):
        raise ValueError('Use a readable relative product path without hashes or traversal')
    if scan(destination, b'', {})[0]:
        raise ValueError('Product destination contains private or planning names')
    return safe_path(repo / destination)


def state_root(repo: Path) -> Path:
    return safe_path(repo / '.junior/demo-promotion')


def ledger_path(repo: Path, destination: str) -> Path:
    return safe_path(state_root(repo) / 'owners' / (digest(destination.encode()) + '.json'))


def published(repo: Path, destination: str) -> dict | None:
    target = product_path(repo, destination)
    ledger = ledger_path(repo, destination)
    if not target.exists():
        if ledger.exists():
            raise ValueError('Owned destination is missing; resolve its saved promotion state')
        return None
    saved = read_json(ledger)
    actual = inventory(target)
    if saved != {'destination': destination, 'contents': actual}:
        raise ValueError('Published destination changed or is unowned')
    return actual


def validate(repo: Path, destination: str, bundle: Path, review: dict) -> None:
    validate_review(review)
    findings = inspect_tree(Repository(repo), 'worktree', review)['findings']
    for name, value in inventory(bundle).items():
        file = bundle / name
        if file.name in {OWNER, LEGACY}:
            raise ValueError('Product bundles cannot contain ownership metadata')
        findings.extend(scan(f'{destination}/{name}', file.read_bytes() if value else b'', review)[0])
    if findings:
        raise ValueError('Product isolation failed: ' + json.dumps(findings))


def prepare(repo: Path, root: Path, source: Path, identity: str, destination: str,
            *, reviewed: bool, review: dict | None = None) -> Path:
    if not reviewed:
        raise ValueError('Select a successfully completed capture after reviewing its contents')
    repo = repository_root(repo)
    target = product_path(repo, destination)
    root, source = safe_path(root), safe_path(source)
    if target.is_relative_to(source) or source.is_relative_to(target) or target.is_relative_to(root):
        raise ValueError('Capture and product paths must not overlap')
    contents = completed(root, source, identity)
    prior = published(repo, destination)
    runs = safe_path(state_root(repo) / 'runs')
    if runs.is_relative_to(source) or source.is_relative_to(runs):
        raise ValueError('Capture overlaps promotion state')
    runs.mkdir(parents=True, exist_ok=True)
    transaction = Path(tempfile.mkdtemp(prefix='candidate-', dir=runs))
    bundle = transaction / 'bundle'
    # No extension list: copy all directories and assets, omitting only the root marker.
    shutil.copytree(source, bundle, ignore=lambda folder, names: [OWNER] if Path(folder) == source else [],
                    symlinks=True)
    if inventory(bundle) != contents or completed(root, source, identity) != contents:
        raise ValueError('Capture or candidate changed during copying')
    validate(repo, destination, bundle, review or {})
    ticket = transaction / 'ticket.json'
    ticket.write_text(json.dumps({'repo': str(repo), 'root': str(root), 'source': str(source),
                                 'identity': identity, 'destination': destination, 'contents': contents,
                                 'prior': prior, 'review': review or {}}))
    return ticket


def accept(repo: Path, ticket: Path, *, reviewed: bool) -> Path:
    if not reviewed:
        raise ValueError('Open and review the prepared bundle before accepting it')
    repo, ticket = repository_root(repo), safe_path(ticket)
    runs = state_root(repo) / 'runs'
    if ticket.name != 'ticket.json' or ticket.parent.parent != runs:
        raise ValueError('Ticket must belong to this repository promotion state')
    data = read_json(ticket)
    if data.get('repo') != str(repo) or data.get('accepted'):
        raise ValueError('Ticket belongs to another repository or was already accepted')
    destination = data['destination']
    target = product_path(repo, destination)
    bundle = ticket.parent / 'bundle'
    contents = completed(Path(data['root']), Path(data['source']), data['identity'])
    if inventory(bundle) != data['contents'] or contents != data['contents']:
        raise ValueError('Reviewed source or candidate changed')
    if published(repo, destination) != data['prior']:
        raise ValueError('Destination changed after preparation')
    validate(repo, destination, bundle, data['review'])
    target.parent.mkdir(parents=True, exist_ok=True)
    ledger = ledger_path(repo, destination)
    ledger.parent.mkdir(parents=True, exist_ok=True)
    pending = ticket.parent / 'owner.json'
    pending.write_text(json.dumps({'destination': destination, 'contents': contents}))
    backup = ticket.parent / 'previous'
    if backup.exists():
        raise ValueError('Previous interrupted acceptance needs recovery')
    if data['prior'] is not None:
        os.replace(target, backup)
    try:
        os.replace(bundle, target)
        os.replace(pending, ledger)
    except OSError:
        if target.exists():
            os.replace(target, bundle)
        if backup.exists():
            os.replace(backup, target)
        raise
    # Backups remain recoverable in private working storage; no published files are pruned.
    return target


def parser() -> argparse.ArgumentParser:
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('--repo', type=Path, default=Path.cwd())
    commands = cli.add_subparsers(dest='command', required=True)
    for name in ('prepare', 'migrate'):
        sub = commands.add_parser(name)
        sub.add_argument('--root', required=True, type=Path)
        sub.add_argument('--source', required=True, type=Path)
        sub.add_argument('--identity', required=True)
        if name == 'prepare':
            sub.add_argument('--destination', required=True)
            sub.add_argument('--reviewed', action='store_true')
            sub.add_argument('--review', type=Path)
    sub = commands.add_parser('accept')
    sub.add_argument('--ticket', type=Path, required=True)
    sub.add_argument('--reviewed', action='store_true')
    return cli


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        if args.command == 'migrate':
            migrate(args.root, args.source, args.identity)
            result = {'marker': str(args.source / OWNER)}
        elif args.command == 'prepare':
            ticket = prepare(args.repo, args.root, args.source, args.identity, args.destination,
                             reviewed=args.reviewed, review=read_json(args.review) if args.review else {})
            result = {'ticket': str(ticket), 'index': str(ticket.parent / 'bundle/index.html')}
        else:
            result = {'index': str(accept(args.repo, args.ticket, reviewed=args.reviewed) / 'index.html')}
    except (ValueError, OSError, KeyError) as error:
        print(json.dumps({'ok': False, 'error': str(error)}))
        return 1
    print(json.dumps({'ok': True, **result}))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
