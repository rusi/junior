#!/usr/bin/env python3
"""Read-only literal checks for product trees and proposed or existing commits."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

sys.dont_write_bytecode = True

from isolation_git import Repository
from isolation_rules import digest, group_findings, scan, validate_review


def inspect_tree(repo: Repository, source: str, review: dict, ref: str | None = None) -> dict:
    files = repo.files(source, ref)
    result = {"source": source, "revision": ref, "files": sorted(files), "findings": [], "reviews": [], "manual_review": []}
    identity = bytearray()
    for path, data in sorted(files.items()):
        identity.extend(os.fsencode(path) + b"\0" + digest(data).encode() + b"\0")
        findings, applied, binary = scan(path, data, review)
        result["findings"].extend(findings)
        result["reviews"].extend(applied)
        if binary:
            result["manual_review"].append(path)
    result["snapshot_sha256"] = digest(identity)
    return result


def parser() -> argparse.ArgumentParser:
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--repo", type=Path, default=Path.cwd())
    commands = cli.add_subparsers(dest="command", required=True)
    for name in ("tree", "range", "staged"):
        command = commands.add_parser(name)
        command.add_argument("--review", type=Path, help="Exact content-bound runtime and product-purpose decisions")
        if name == "tree":
            command.add_argument("--ref", help="Commit to inspect; default is tracked and nonignored new worktree files")
        elif name == "range":
            command.add_argument("--base", required=True, help="Explicit ancestor commit, excluded from range")
            command.add_argument("--head", default="HEAD")
        else:
            command.add_argument("--message-file", type=Path, required=True)
    return cli


def run(args: argparse.Namespace) -> dict:
    review = json.loads(args.review.read_text()) if args.review else {}
    validate_review(review)
    repo = Repository(args.repo)
    if args.command == "range":
        base, head = repo.revision(args.base), repo.revision(args.head)
        result = {"base": base, "head": head, "commits": [], "findings": []}
        for revision in repo.commits(base, head):
            tree = inspect_tree(repo, "commit", review, revision)
            tree["changed_files"] = repo.changed(revision)
            tree["findings"].extend(group_findings(tree["changed_files"], repo.message(revision), review))
            result["commits"].append(tree)
            result["findings"].extend(dict(f, revision=revision) for f in tree["findings"])
    elif args.command == "staged":
        result = inspect_tree(repo, "index", review)
        result["changed_files"] = repo.changed()
        message = args.message_file.read_bytes()
        result["message_sha256"] = digest(message)
        result["findings"].extend(group_findings(result["changed_files"], message, review))
        if not result["changed_files"] or not message.strip():
            raise ValueError("Staged validation requires changed files and a nonempty proposed message")
    else:
        ref = repo.revision(args.ref) if args.ref else None
        result = inspect_tree(repo, "commit" if ref else "worktree", review, ref)
    result["ok"] = not result["findings"]
    result["limits"] = "Literal checks only. Semantic and rendered-content review remain required. Tree/staged checks do not inspect pending history."
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        result = run(args)
    except (ValueError, OSError) as error:
        result = {"ok": False, "findings": [{"path": "@input", "line": 0, "rule": "input", "detail": str(error)}]}
    print(json.dumps(result, indent=2, ensure_ascii=True))
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
