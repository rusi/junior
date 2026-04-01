#!/usr/bin/env python3
"""Junior installer/update core.

Single cross-platform entrypoint for:
- install / upgrade
- sync-back
- update (check/apply)
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any

GITHUB_OWNER = "rusi"
GITHUB_REPO = "junior"
GITHUB_BRANCH = "main"
GITHUB_API_COMMIT = f"https://api.github.com/repos/{GITHUB_OWNER}/{GITHUB_REPO}/commits/{GITHUB_BRANCH}"
GITHUB_TARBALL = f"https://github.com/{GITHUB_OWNER}/{GITHUB_REPO}/archive/refs/heads/{GITHUB_BRANCH}.tar.gz"


class Console:
    def __init__(self, verbose: bool) -> None:
        self.verbose = verbose

    def info(self, msg: str) -> None:
        print(f"[INFO] {msg}")

    def success(self, msg: str) -> None:
        print(f"[SUCCESS] {msg}")

    def warning(self, msg: str) -> None:
        print(f"[WARNING] {msg}")

    def error(self, msg: str) -> None:
        print(f"[ERROR] {msg}", file=sys.stderr)

    def debug(self, msg: str) -> None:
        if self.verbose:
            print(f"[DEBUG] {msg}")


@dataclass(frozen=True)
class FileOp:
    source_path: Path
    dest_path: Path
    metadata_key: str
    skip_if_exists: bool


@dataclass(frozen=True)
class PlannedAction:
    op: FileOp
    action: str
    source_checksum: str


@dataclass(frozen=True)
class InstallTargetConfig:
    home_dir: str
    contract_filename: str


INSTALL_TARGETS: dict[str, InstallTargetConfig] = {
    "codex": InstallTargetConfig(home_dir=".codex", contract_filename="AGENTS.md"),
    "cursor": InstallTargetConfig(home_dir=".cursor", contract_filename="AGENTS.md"),
    "gemini": InstallTargetConfig(home_dir=".gemini", contract_filename="GEMINI.md"),
    "claude": InstallTargetConfig(home_dir=".claude", contract_filename="CLAUDE.md"),
}
SUPPORTED_INSTALL_TARGETS = tuple(INSTALL_TARGETS.keys())


def script_path() -> Path:
    return Path(__file__).resolve()


def repo_root_from_script() -> Path:
    return script_path().parent.parent


def agents_root(root: Path) -> Path:
    return root / "agents"


def rules_root(root: Path) -> Path:
    return agents_root(root) / "rules"


def skills_root(root: Path) -> Path:
    return agents_root(root) / "skills"


def cursor_rules_root(root: Path) -> Path:
    return root / "cursor" / "rules"


def install_target_config(target: str) -> InstallTargetConfig:
    config = INSTALL_TARGETS.get(target)
    if config is None:
        raise ValueError(f"Unsupported install target: {target}")
    return config


def runtime_root(target: str, home: Path | None = None) -> Path:
    base = (home or Path.home()).resolve()
    config = install_target_config(target)
    return base / config.home_dir


def runtime_contract_filename(target: str) -> str:
    return install_target_config(target).contract_filename


def runtime_rules_root(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "rules"


def runtime_skills_root(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "skills"


def runtime_contract_path(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / runtime_contract_filename(target)


def runtime_commands_root(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "commands"


def runtime_junior_doc_path(target: str, home: Path | None = None) -> Path:
    return runtime_skills_root(target, home) / "jr" / "references" / "junior-readme.md"


def runtime_cursor_support_root(home: Path | None = None) -> Path:
    return runtime_commands_root("cursor", home) / "_shared"


def runtime_cursor_doc_path(home: Path | None = None) -> Path:
    return runtime_cursor_support_root(home) / "junior-readme.md"


def runtime_legacy_junior_doc_path(target: str, home: Path | None = None) -> Path:
    return runtime_skills_root(target, home) / "junior" / "references" / "junior-readme.md"


def global_install_root() -> Path:
    return Path.home().resolve()


def global_metadata_path(target: str) -> Path:
    return runtime_root(target) / ".junior-install.json"


def local_metadata_rel_paths() -> set[str]:
    paths = {".junior/.junior-install.json"}
    for config in INSTALL_TARGETS.values():
        paths.add(f"{config.home_dir}/.junior-install.json")
    return paths


def detect_platform() -> str:
    return "windows" if os.name == "nt" else "unix"


def is_absolute_destination(value: str) -> bool:
    if value.startswith("~/"):
        return True
    return Path(value).is_absolute()


def expand_destination(value: str, target_root: Path) -> Path:
    if value.startswith("~/"):
        return Path.home() / value[2:]
    raw = Path(value)
    if raw.is_absolute():
        return raw
    return target_root / raw


def destination_key(base_destination: str, rel_path: str | None = None) -> str:
    if is_absolute_destination(base_destination):
        base_path = expand_destination(base_destination, Path.cwd())
        if rel_path:
            return str((base_path / rel_path).resolve())
        return str(base_path.resolve())

    if rel_path:
        return str(PurePosixPath(base_destination) / PurePosixPath(rel_path))
    return base_destination


def key_to_path(target_root: Path, key: str) -> Path:
    path = Path(os.path.expanduser(key))
    if path.is_absolute():
        return path
    return target_root / path


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def file_size(path: Path) -> int:
    return path.stat().st_size


def run_command(command: list[str], cwd: Path | None = None) -> str:
    out = subprocess.check_output(command, cwd=str(cwd) if cwd else None, text=True)
    return out.strip()


def read_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected object JSON in {path}")
    return data


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=True)
        f.write("\n")


def parse_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values

    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def is_effectively_empty_text_file(path: Path) -> bool:
    try:
        if path.stat().st_size == 0:
            return True
    except OSError:
        return False

    try:
        content = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False

    return content.strip() == ""


def is_blank_global_contract(path: Path, install_target: str) -> bool:
    expected = runtime_contract_path(install_target).resolve()
    try:
        resolved = path.resolve()
    except FileNotFoundError:
        resolved = path

    if resolved != expected:
        return False
    return is_effectively_empty_text_file(path)


def query_latest_commit(console: Console) -> tuple[str, str]:
    req = urllib.request.Request(
        GITHUB_API_COMMIT,
        headers={"Accept": "application/vnd.github+json", "User-Agent": "junior-installer"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
    except Exception as exc:  # noqa: BLE001
        console.debug(f"GitHub API request failed: {exc}")
        return "", ""

    commit_hash = str(payload.get("sha") or "")
    commit_date = str((((payload.get("commit") or {}).get("committer") or {}).get("date")) or "")
    return commit_hash, commit_date


def resolve_source_version(repo_root: Path, ignore_dirty: bool, console: Console) -> tuple[str, str]:
    git_dir = repo_root / ".git"
    if git_dir.exists():
        if not ignore_dirty:
            status = run_command(["git", "status", "--porcelain"], cwd=repo_root)
            if status:
                raise RuntimeError(
                    "Junior source git is not clean. Commit/stash changes or use --ignore-dirty."
                )

        commit_hash = run_command(["git", "rev-parse", "HEAD"], cwd=repo_root)
        commit_ts = run_command(["git", "log", "-1", "--format=%ct"], cwd=repo_root)
        return commit_hash or "unknown", commit_ts or "unknown"

    values = parse_env_file(repo_root / ".githash")
    commit_hash = values.get("COMMIT_HASH", "")
    commit_ts = values.get("COMMIT_TIMESTAMP", "")
    if commit_hash and commit_ts:
        return commit_hash, commit_ts

    latest_commit, latest_date = query_latest_commit(console)
    if latest_commit and latest_date:
        try:
            stamp = int(dt.datetime.fromisoformat(latest_date.replace("Z", "+00:00")).timestamp())
            return latest_commit, str(stamp)
        except ValueError:
            return latest_commit, "unknown"

    return "unknown", "unknown"


def should_include_file(entry: dict[str, Any], platform_name: str) -> bool:
    configured_platform = entry.get("platform")
    if configured_platform is None:
        return True
    return configured_platform == platform_name


def discover_skill_markdown_command_ops(repo_root: Path, target_root: Path, destination: str) -> list[FileOp]:
    ops: list[FileOp] = []
    commands_root = expand_destination(destination, target_root)
    for skill_dir in sorted(p for p in skills_root(repo_root).iterdir() if p.is_dir() and p.name != "_shared"):
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            continue
        destination = commands_root / f"{skill_dir.name}.md"
        ops.append(
            FileOp(
                source_path=skill_file,
                dest_path=destination,
                metadata_key=str(destination),
                skip_if_exists=False,
            )
        )
    return ops


def discover_skill_support_ops(repo_root: Path, target_root: Path, destination: str) -> list[FileOp]:
    ops: list[FileOp] = []
    support_root = expand_destination(destination, target_root)
    shared_source = skills_root(repo_root) / "_shared"

    if shared_source.is_dir():
        for file_path in sorted(p for p in shared_source.rglob("*") if p.is_file()):
            rel = file_path.relative_to(shared_source).as_posix()
            destination = support_root / rel
            ops.append(
                FileOp(
                    source_path=file_path,
                    dest_path=destination,
                    metadata_key=str(destination),
                    skip_if_exists=False,
                )
            )

    for skill_dir in sorted(p for p in skills_root(repo_root).iterdir() if p.is_dir() and p.name != "_shared"):
        for file_path in sorted(p for p in skill_dir.rglob("*") if p.is_file() and p.name != "SKILL.md"):
            rel = file_path.relative_to(skill_dir).as_posix()
            destination = support_root / skill_dir.name / rel
            ops.append(
                FileOp(
                    source_path=file_path,
                    dest_path=destination,
                    metadata_key=str(destination),
                    skip_if_exists=False,
                )
            )

    return ops


def discover_file_ops(config: dict[str, Any], repo_root: Path, target_root: Path, platform_name: str, console: Console) -> list[FileOp]:
    ops: list[FileOp] = []
    mode_handlers = {
        "skill_markdown_commands": discover_skill_markdown_command_ops,
        "skill_support_tree": discover_skill_support_ops,
    }

    files = config.get("files", [])
    if not isinstance(files, list):
        raise ValueError("Invalid install-config.json: 'files' must be a list")

    for entry in files:
        if not isinstance(entry, dict):
            continue
        if not should_include_file(entry, platform_name):
            continue

        source = str(entry.get("source") or "")
        destination = str(entry.get("destination") or "")
        is_directory = bool(entry.get("isDirectory", False))
        skip_if_exists = bool(entry.get("skipIfExists", False))
        mode = str(entry.get("mode") or "")

        if not source or not destination:
            continue

        handler = mode_handlers.get(mode)
        if handler is not None:
            ops.extend(handler(repo_root, target_root, destination))
            continue

        source_path = repo_root / source
        dest_base = expand_destination(destination, target_root)

        if is_directory:
            if not source_path.is_dir():
                console.warning(f"Source directory not found: {source_path}")
                continue
            for file_path in sorted(p for p in source_path.rglob("*") if p.is_file()):
                rel = file_path.relative_to(source_path).as_posix()
                dest_path = dest_base / rel
                key = destination_key(destination, rel)
                ops.append(
                    FileOp(
                        source_path=file_path,
                        dest_path=dest_path,
                        metadata_key=key,
                        skip_if_exists=skip_if_exists,
                    )
                )
        else:
            key = destination_key(destination)
            ops.append(
                FileOp(
                    source_path=source_path,
                    dest_path=dest_base,
                    metadata_key=key,
                    skip_if_exists=skip_if_exists,
                )
            )

    return ops


def load_existing_metadata(metadata_path: Path) -> dict[str, Any] | None:
    if not metadata_path.exists():
        return None
    data = read_json(metadata_path)
    files = data.get("files")
    if not isinstance(files, dict):
        data["files"] = {}
    return data


def classify_action(
    op: FileOp,
    source_checksum: str,
    is_upgrade: bool,
    existing_files: dict[str, Any],
    force_overwrite: bool,
    install_target: str,
) -> str:
    if not op.dest_path.exists():
        return "copy"

    if op.skip_if_exists:
        return "skip"

    current_checksum = sha256_file(op.dest_path)
    if current_checksum == source_checksum:
        return "noop"

    if not is_upgrade:
        if is_blank_global_contract(op.dest_path, install_target):
            return "copy"
        return "conflict"

    old_entry = existing_files.get(op.metadata_key)
    if not isinstance(old_entry, dict):
        return "conflict"

    old_checksum = str(old_entry.get("sha256") or "")
    if not old_checksum:
        return "conflict"

    if current_checksum == old_checksum:
        return "copy"

    if force_overwrite:
        return "overwrite_modified"

    return "preserve_modified"


def plan_install_actions(
    ops: list[FileOp],
    repo_root: Path,
    is_upgrade: bool,
    existing_files: dict[str, Any],
    force_overwrite: bool,
    install_target: str,
    console: Console,
) -> tuple[list[PlannedAction], list[FileOp]]:
    planned: list[PlannedAction] = []
    conflicts: list[FileOp] = []

    for op in ops:
        if not op.source_path.exists():
            console.warning(f"Source file not found: {op.source_path}")
            continue

        source_checksum = sha256_bytes(rendered_source_bytes(op, repo_root, install_target))
        action = classify_action(
            op,
            source_checksum,
            is_upgrade,
            existing_files,
            force_overwrite,
            install_target,
        )

        if action == "conflict":
            conflicts.append(op)
            continue

        planned.append(PlannedAction(op=op, action=action, source_checksum=source_checksum))

    return planned, conflicts


def normalize_install_target(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in SUPPORTED_INSTALL_TARGETS:
        raise ValueError(
            f"Invalid target '{value}'. Supported targets: {', '.join(SUPPORTED_INSTALL_TARGETS)}"
        )
    return normalized


def parse_install_targets(value: str) -> list[str]:
    raw = value.strip().lower()
    if raw == "all":
        return list(SUPPORTED_INSTALL_TARGETS)

    targets: list[str] = []
    for chunk in raw.split(","):
        target = normalize_install_target(chunk)
        if target not in targets:
            targets.append(target)
    return targets


def requested_targets(args: argparse.Namespace) -> list[str]:
    cli_value = str(getattr(args, "target", "") or "").strip()
    legacy_value = str(getattr(args, "legacy_target_path", "") or "").strip()
    raw_value = legacy_value if legacy_value and not cli_value else cli_value
    return parse_install_targets(raw_value)


def has_explicit_target(args: argparse.Namespace) -> bool:
    cli_value = str(getattr(args, "target", "") or "").strip()
    legacy_value = str(getattr(args, "legacy_target_path", "") or "").strip()
    return bool(cli_value or legacy_value)


def target_home_alias(install_target: str) -> str:
    config = install_target_config(install_target)
    return f"~/{config.home_dir}"


def target_contract_alias(install_target: str) -> str:
    return f"{target_home_alias(install_target)}/{runtime_contract_filename(install_target)}"


def rewrite_codex_paths_for_target(value: str, install_target: str) -> str:
    if install_target in {"codex", "cursor"}:
        return value

    replacements = (
        ("~/.codex/AGENTS.md", target_contract_alias(install_target)),
        ("~/.codex/skills", f"{target_home_alias(install_target)}/skills"),
        ("~/.codex", target_home_alias(install_target)),
    )
    rewritten = value
    for source, destination in replacements:
        rewritten = rewritten.replace(source, destination)
    return rewritten


def render_contract_content_for_target(content: str, install_target: str) -> str:
    return rewrite_codex_paths_for_target(content, install_target)


def strip_yaml_frontmatter(content: str) -> str:
    return re.sub(r"\A---\r?\n.*?\r?\n---\r?\n+", "", content, count=1, flags=re.S)


def is_cursor_command_source(op: FileOp, repo_root: Path) -> bool:
    try:
        rel = op.source_path.relative_to(skills_root(repo_root))
    except ValueError:
        return False
    return rel.name == "SKILL.md"


def render_cursor_command_content(content: str, op: FileOp) -> str:
    stripped = strip_yaml_frontmatter(content)
    skill_dir = op.source_path.parent.name
    support_root = "~/.cursor/commands/_shared"
    rewritten = stripped.replace("../_shared/", f"{support_root}/")
    rewritten = re.sub(
        r"(?<!_shared/)templates/",
        f"{support_root}/{skill_dir}/templates/",
        rewritten,
    )
    rewritten = re.sub(
        r"(?<!_shared/)references/",
        f"{support_root}/{skill_dir}/references/",
        rewritten,
    )
    return rewritten


def rendered_source_bytes(op: FileOp, repo_root: Path, install_target: str) -> bytes:
    content = op.source_path.read_bytes()
    if install_target == "cursor" and is_cursor_command_source(op, repo_root):
        try:
            decoded = content.decode("utf-8")
        except UnicodeDecodeError:
            return content
        return render_cursor_command_content(decoded, op).encode("utf-8")
    if op.source_path != (repo_root / "AGENTS.md"):
        return content
    try:
        decoded = content.decode("utf-8")
    except UnicodeDecodeError:
        return content
    return render_contract_content_for_target(decoded, install_target).encode("utf-8")


def is_runtime_contract_source(op: FileOp, repo_root: Path) -> bool:
    return op.source_path == (repo_root / "AGENTS.md")


def should_render_source(op: FileOp, repo_root: Path, install_target: str) -> bool:
    return is_runtime_contract_source(op, repo_root) or (
        install_target == "cursor" and is_cursor_command_source(op, repo_root)
    )


def op_source_relpath(op: FileOp, repo_root: Path) -> str:
    try:
        return op.source_path.relative_to(repo_root).as_posix()
    except ValueError:
        return op.source_path.name


def map_destination_for_target(destination: str, install_target: str) -> str:
    return rewrite_codex_paths_for_target(destination, install_target)


def build_target_install_config(config: dict[str, Any], install_target: str) -> dict[str, Any]:
    targets = config.get("targets", {})
    if isinstance(targets, dict):
        target_config = targets.get(install_target)
        if isinstance(target_config, dict):
            return target_config

    if install_target == "codex":
        return config

    directories: list[str] = []
    for value in config.get("directories", []):
        if not isinstance(value, str):
            continue
        if value.startswith("~/.cursor/"):
            continue
        directories.append(map_destination_for_target(value, install_target))

    files: list[dict[str, Any]] = []
    for entry in config.get("files", []):
        if not isinstance(entry, dict):
            continue
        destination = str(entry.get("destination") or "")
        if destination.startswith("~/.cursor/"):
            continue

        mapped = dict(entry)
        mapped["destination"] = map_destination_for_target(destination, install_target)
        files.append(mapped)

    messages = config.get("messages", {})
    mapped_messages: dict[str, Any] = {}
    if isinstance(messages, dict):
        for key, value in messages.items():
            if key == "nextSteps" and isinstance(value, list):
                next_steps: list[str] = []
                for step in value:
                    if not isinstance(step, str):
                        continue
                    mapped_step = rewrite_codex_paths_for_target(step, install_target)
                    next_steps.append(mapped_step)
                mapped_messages[key] = next_steps
                continue

            if key == "availableCommands" and isinstance(value, str):
                mapped_messages[key] = rewrite_codex_paths_for_target(value, install_target)
                continue

            mapped_messages[key] = value

    return {
        "directories": directories,
        "files": files,
        "messages": mapped_messages,
    }


def remove_obsolete_files(
    target_root: Path,
    existing_files: dict[str, Any],
    new_manifest_keys: set[str],
    force_overwrite: bool,
    console: Console,
) -> list[str]:
    def remove_empty_parents(start_path: Path, stop_at: Path) -> None:
        current = start_path.parent
        while True:
            if current == stop_at:
                return
            if not current.exists() or not current.is_dir():
                return
            try:
                current.rmdir()
            except OSError:
                return
            current = current.parent

    removed: list[str] = []

    for key, meta in existing_files.items():
        if key in new_manifest_keys:
            continue
        if not isinstance(meta, dict):
            continue

        path = key_to_path(target_root, key)
        if not path.exists() or not path.is_file():
            continue

        installed_sha = str(meta.get("sha256") or "")
        if not installed_sha:
            continue

        current_sha = sha256_file(path)
        if current_sha != installed_sha:
            if force_overwrite:
                path.unlink()
                removed.append(str(path))
                remove_empty_parents(path, target_root)
                console.warning(f"Obsolete user-modified file removed due to --force: {path}")
                continue
            console.warning(f"Obsolete file preserved (user modified): {path}")
            continue

        path.unlink()
        removed.append(str(path))
        remove_empty_parents(path, target_root)

    return removed


def run_install_for_target(args: argparse.Namespace, install_target: str) -> int:
    console = Console(verbose=bool(args.verbose))
    repo_root = repo_root_from_script()
    install_root = global_install_root()
    config_path = repo_root / "scripts" / "install-config.json"

    if not (rules_root(repo_root) / "00-junior.mdc").exists():
        console.error("Cannot find Junior files. Run from the Junior repository.")
        return 1

    if not config_path.exists():
        console.error(f"Config file not found: {config_path}")
        return 1

    console.info(f"Target: {install_target}")

    if not console.verbose:
        print("Installing Junior...")

    try:
        commit_hash, commit_version = resolve_source_version(
            repo_root=repo_root,
            ignore_dirty=bool(args.ignore_dirty),
            console=console,
        )
    except Exception as exc:  # noqa: BLE001
        console.error(str(exc))
        return 1

    config = build_target_install_config(read_json(config_path), install_target)

    metadata_path = global_metadata_path(install_target)
    existing = load_existing_metadata(metadata_path)
    is_upgrade = existing is not None
    existing_files = (existing or {}).get("files", {})
    if not isinstance(existing_files, dict):
        existing_files = {}

    # Create configured directories.
    for value in config.get("directories", []):
        if not isinstance(value, str):
            continue
        expand_destination(value, install_root).mkdir(parents=True, exist_ok=True)

    platform_name = detect_platform()
    ops = discover_file_ops(config, repo_root, install_root, platform_name, console)

    new_manifest_keys = {op.metadata_key for op in ops}
    removed_files: list[str] = []
    if is_upgrade:
        removed_files = remove_obsolete_files(
            install_root, existing_files, new_manifest_keys, bool(args.force), console
        )

    planned, conflicts = plan_install_actions(
        ops, repo_root, is_upgrade, existing_files, bool(args.force), install_target, console
    )

    if conflicts:
        console.error("INSTALLATION ABORTED - file conflicts detected:")
        for op in conflicts:
            console.error(f"  - {op.dest_path}")
        console.info("Remove conflicting files or run in a clean environment before retrying.")
        return 1

    metadata_files: dict[str, dict[str, Any]] = {}
    modified_files: list[str] = []
    overwritten_files: list[str] = []

    for item in planned:
        op = item.op
        action = item.action
        op.dest_path.parent.mkdir(parents=True, exist_ok=True)

        if action == "skip":
            console.debug(f"Skipped existing file: {op.dest_path}")
            continue

        if action == "preserve_modified":
            modified_files.append(str(op.dest_path))
            metadata_files[op.metadata_key] = {
                "sha256": item.source_checksum,
                "size": file_size(op.source_path),
                "modified": True,
            }
            console.warning(f"User-modified: {op.dest_path} (preserving)")
            continue

        if action == "copy":
            if should_render_source(op, repo_root, install_target):
                op.dest_path.write_bytes(rendered_source_bytes(op, repo_root, install_target))
            else:
                shutil.copy2(op.source_path, op.dest_path)
            console.debug(f"Installed: {op.dest_path}")
        elif action == "overwrite_modified":
            if should_render_source(op, repo_root, install_target):
                op.dest_path.write_bytes(rendered_source_bytes(op, repo_root, install_target))
            else:
                shutil.copy2(op.source_path, op.dest_path)
            overwritten_files.append(str(op.dest_path))
            console.warning(f"User-modified: {op.dest_path} (overwritten due to --force)")
        elif action == "noop":
            console.debug(f"Up-to-date: {op.dest_path}")

        metadata_files[op.metadata_key] = {
            "sha256": item.source_checksum,
            "size": file_size(op.dest_path),
            "modified": False,
            "source": op_source_relpath(op, repo_root),
        }

    installed_at = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    metadata = {
        "version": commit_version,
        "installed_at": installed_at,
        "commit_hash": commit_hash,
        "files": metadata_files,
    }
    write_json(metadata_path, metadata)

    messages = config.get("messages", {}) if isinstance(config.get("messages"), dict) else {}
    success_msg = str(messages.get("success") or "Junior installation complete!")
    next_steps = messages.get("nextSteps")

    print("")
    console.success(f"\u2713 {success_msg}")

    if removed_files:
        print("")
        console.info(f"Removed obsolete files ({len(removed_files)}):")
        for value in removed_files:
            print(f"  - {value}")

    if modified_files:
        print("")
        console.warning(f"Preserved user-modified files ({len(modified_files)}):")
        for value in modified_files:
            print(f"  - {value}")

    if overwritten_files:
        print("")
        console.warning(f"Overwritten user-modified files due to --force ({len(overwritten_files)}):")
        for value in overwritten_files:
            print(f"  - {value}")

    print("")
    console.info("Next steps:")
    if isinstance(next_steps, list) and next_steps:
        for item in next_steps:
            print(f"  {item}")
    else:
        print("  1. Run jr-init to define project foundation")
        print("  2. Run jr-feature to plan the next feature")
        print("  3. Run jr-implement to execute stories with TDD")

    if console.verbose:
        available = str(messages.get("availableCommands") or "")
        if available:
            print("")
            console.info(available)

    return 0


def run_install(args: argparse.Namespace) -> int:
    console = Console(verbose=bool(args.verbose))
    if not has_explicit_target(args):
        console.error("Missing required --target. Use one of: claude, codex, cursor, gemini, all, or a csv list.")
        return 1
    try:
        targets = requested_targets(args)
    except ValueError as exc:
        console.error(str(exc))
        return 1
    exit_code = 0
    for install_target in targets:
        rc = run_install_for_target(args, install_target)
        if rc != 0:
            exit_code = rc
    return exit_code


def source_path_for_sync(
    repo_root: Path,
    key: str,
    install_target: str,
    source_rel: str = "",
) -> Path | None:
    if source_rel:
        candidate = repo_root / source_rel
        if candidate.exists() or not source_rel.startswith("~"):
            return candidate

    path = key_to_path(global_install_root(), key)
    home = Path.home().resolve()

    try:
        resolved = path.resolve()
    except FileNotFoundError:
        resolved = path

    target_rules = runtime_rules_root(install_target, home).resolve()
    target_skills = runtime_skills_root(install_target, home).resolve()
    target_commands = runtime_commands_root(install_target, home).resolve()
    target_contract = runtime_contract_path(install_target, home).resolve()
    target_junior_doc = runtime_junior_doc_path(install_target, home).resolve()
    target_legacy_junior_doc = runtime_legacy_junior_doc_path(install_target, home).resolve()
    cursor_support_root = runtime_cursor_support_root(home).resolve()
    cursor_doc = runtime_cursor_doc_path(home).resolve()

    if str(resolved).startswith(str(target_rules) + os.sep):
        rel = resolved.relative_to(target_rules)
        if install_target == "cursor":
            cursor_specific = cursor_rules_root(repo_root) / rel
            if cursor_specific.exists():
                return cursor_specific
        return rules_root(repo_root) / rel

    if str(resolved).startswith(str(target_skills) + os.sep):
        rel = resolved.relative_to(target_skills)
        return skills_root(repo_root) / rel

    if resolved == cursor_doc:
        return repo_root / "README.md"

    if str(resolved).startswith(str(cursor_support_root) + os.sep):
        rel = resolved.relative_to(cursor_support_root)
        if rel.parts and rel.parts[0] != "_shared" and (skills_root(repo_root) / rel.parts[0]).is_dir():
            return skills_root(repo_root) / rel
        return skills_root(repo_root) / "_shared" / rel

    if str(resolved).startswith(str(target_commands) + os.sep):
        rel = resolved.relative_to(target_commands)
        if len(rel.parts) != 1:
            return None
        return skills_root(repo_root) / rel.stem / "SKILL.md"

    if resolved == target_contract:
        return repo_root / "AGENTS.md"

    if resolved in {target_junior_doc, target_legacy_junior_doc}:
        return repo_root / "README.md"

    if key == "AGENTS.md":
        return repo_root / "AGENTS.md"

    return None


@dataclass(frozen=True)
class SyncCandidate:
    target: str
    key: str
    src_path: Path
    dest_path: Path
    sha256: str


def installed_targets_with_metadata() -> list[str]:
    targets: list[str] = []
    for target in SUPPORTED_INSTALL_TARGETS:
        if global_metadata_path(target).exists():
            targets.append(target)
    return targets


def collect_sync_candidates_for_target(
    repo_root: Path,
    install_target: str,
    console: Console,
) -> tuple[list[SyncCandidate], list[str]]:
    install_root = global_install_root()
    metadata_path = global_metadata_path(install_target)
    if not metadata_path.exists():
        return [], [f"Metadata file missing for target {install_target}: {metadata_path}"]

    metadata = read_json(metadata_path)
    files = metadata.get("files", {})
    if not isinstance(files, dict):
        files = {}

    candidates: list[SyncCandidate] = []
    warnings: list[str] = []

    for key, value in files.items():
        if not isinstance(value, dict):
            continue
        installed_sha = str(value.get("sha256") or "")
        if not installed_sha:
            continue

        target_path = key_to_path(install_root, key)
        if not target_path.exists() or not target_path.is_file():
            continue

        current_sha = sha256_file(target_path)
        if current_sha == installed_sha:
            continue

        source_rel = str(value.get("source") or "")
        dest_path = source_path_for_sync(repo_root, key, install_target, source_rel)
        if dest_path is None:
            warnings.append(f"Skipping unknown mapping for {install_target}: {key}")
            continue

        candidates.append(
            SyncCandidate(
                target=install_target,
                key=key,
                src_path=target_path,
                dest_path=dest_path,
                sha256=current_sha,
            )
        )

    return candidates, warnings


def run_sync_back(args: argparse.Namespace) -> int:
    console = Console(verbose=bool(args.verbose))
    if has_explicit_target(args):
        try:
            targets = requested_targets(args)
        except ValueError as exc:
            console.error(str(exc))
            return 1
    else:
        targets = installed_targets_with_metadata()
        if not targets:
            console.error("No global Junior installation metadata found for any target.")
            return 1

    repo_root = repo_root_from_script()
    all_candidates: list[SyncCandidate] = []
    warnings: list[str] = []

    for install_target in targets:
        console.info(f"Inspecting target: {install_target}")
        candidates, target_warnings = collect_sync_candidates_for_target(repo_root, install_target, console)
        all_candidates.extend(candidates)
        warnings.extend(target_warnings)

    for warning in warnings:
        console.warning(warning)

    if not all_candidates:
        console.success("No modified files to sync")
        return 0

    print("")
    console.info(f"Modified runtime files found ({len(all_candidates)}):")
    for candidate in all_candidates:
        print(f"  - [{candidate.target}] {candidate.key}")

    grouped: dict[Path, list[SyncCandidate]] = {}
    for candidate in all_candidates:
        grouped.setdefault(candidate.dest_path, []).append(candidate)

    synced = 0
    conflict_count = 0
    for dest_path, candidates in sorted(grouped.items(), key=lambda item: str(item[0])):
        sha_values = {candidate.sha256 for candidate in candidates}
        if len(sha_values) > 1:
            conflict_count += 1
            console.error(f"Sync conflict for {dest_path}:")
            for candidate in candidates:
                print(f"  - [{candidate.target}] {candidate.src_path}")
            continue

        chosen = candidates[0]
        dest_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(chosen.src_path, dest_path)
        console.success(f"Synced: {chosen.src_path} -> {dest_path}")
        synced += 1

    print("")
    if conflict_count:
        console.warning(f"Sync completed with {conflict_count} conflict(s). Conflicted files were not overwritten.")
    console.success(f"Sync complete. {synced} files copied to Junior source.")
    return 1 if conflict_count else 0


def create_local_tarball(local_source: Path, tarball_path: Path, console: Console) -> None:
    if not local_source.exists() or not local_source.is_dir():
        raise RuntimeError(f"Local source does not exist: {local_source}")
    if not (rules_root(local_source) / "00-junior.mdc").exists():
        raise RuntimeError("Local source is not a Junior repository")

    excludes = {
        ".git",
        "__pycache__",
        ".DS_Store",
    }
    metadata_paths = local_metadata_rel_paths()

    with tarfile.open(tarball_path, "w:gz") as tar:
        for path in sorted(local_source.rglob("*")):
            rel = path.relative_to(local_source)
            parts = set(rel.parts)
            if excludes & parts:
                continue
            if path.name.endswith(".pyc"):
                continue
            if rel.as_posix() in metadata_paths:
                continue

            arcname = Path("junior-local") / rel
            tar.add(path, arcname=arcname)

    console.debug(f"Created local tarball at {tarball_path}")


def extract_tarball(tarball_path: Path, temp_dir: Path) -> Path:
    with tarfile.open(tarball_path, "r:gz") as tar:
        tar.extractall(path=temp_dir)

    for child in sorted(temp_dir.iterdir()):
        if child.is_dir() and child.name.startswith("junior-"):
            return child
    raise RuntimeError("Could not find extracted Junior directory")


def write_githash(path: Path, commit_hash: str, commit_date: str, commit_timestamp: str) -> None:
    values = [
        f"COMMIT_HASH={commit_hash}",
        f"COMMIT_DATE={commit_date}",
        f"COMMIT_TIMESTAMP={commit_timestamp}",
        "",
    ]
    (path / ".githash").write_text("\n".join(values), encoding="utf-8")


def local_source_version(source_root: Path) -> tuple[str, str, str]:
    if (source_root / ".git").exists():
        commit_hash = run_command(["git", "rev-parse", "HEAD"], cwd=source_root)
        commit_date = run_command(["git", "log", "-1", "--format=%cI"], cwd=source_root)
        commit_ts = run_command(["git", "log", "-1", "--format=%ct"], cwd=source_root)
        return commit_hash, commit_date, commit_ts

    now = dt.datetime.now(dt.timezone.utc)
    return "local-test", now.strftime("%Y-%m-%dT%H:%M:%SZ"), str(int(now.timestamp()))


def run_update_for_target(args: argparse.Namespace, install_target: str) -> int:
    console = Console(verbose=bool(args.verbose))
    metadata_path = global_metadata_path(install_target)
    console.info(f"Target: {install_target}")

    if not metadata_path.exists():
        console.error("Global Junior installation metadata not found.")
        console.error(f"Missing metadata: {metadata_path}")
        return 1

    metadata = read_json(metadata_path)
    current_commit = str(metadata.get("commit_hash") or "")
    current_version = str(metadata.get("version") or "")
    installed_at = str(metadata.get("installed_at") or "")

    local_source_path: Path | None = None
    if args.local_source:
        local_source_path = Path(args.local_source).expanduser().resolve()
        try:
            latest_commit, latest_date, _latest_ts = local_source_version(local_source_path)
        except Exception as exc:  # noqa: BLE001
            console.error(f"Failed to resolve local source version: {exc}")
            return 1
    else:
        latest_commit, latest_date = query_latest_commit(console)
        if not latest_commit:
            console.error("Failed to query GitHub for latest version")
            return 1

    print("")
    console.info("Junior Version Check")
    print(f"  Current commit: {(current_commit[:7] if current_commit else 'unknown')}")
    print(f"  Current version: {current_version or 'unknown'}")
    if installed_at:
        print(f"  Installed at: {installed_at}")
    print(f"  Latest commit: {latest_commit[:7]}")
    print(f"  Latest date: {latest_date or 'unknown'}")

    if current_commit == latest_commit:
        print("")
        console.success("Junior is up to date")
        return 0

    print("")
    console.warning("Update available")

    if args.check_only:
        return 2

    if not args.force:
        response = input("Download and apply update? [y/N]: ").strip().lower()
        if response not in {"y", "yes"}:
            console.info("Update cancelled")
            return 0

    with tempfile.TemporaryDirectory(prefix=".junior-update-") as temp:
        temp_dir = Path(temp)
        tarball_path = temp_dir / "junior.tar.gz"

        if local_source_path is not None:
            create_local_tarball(local_source_path, tarball_path, console)
            commit_hash, commit_date, commit_ts = local_source_version(local_source_path)
        else:
            console.info("Downloading latest Junior release...")
            try:
                with urllib.request.urlopen(GITHUB_TARBALL, timeout=30) as resp:
                    tarball_path.write_bytes(resp.read())
            except urllib.error.URLError as exc:
                console.error(f"Download failed: {exc}")
                return 1

            try:
                ts = int(dt.datetime.fromisoformat(latest_date.replace("Z", "+00:00")).timestamp())
                commit_ts = str(ts)
            except ValueError:
                commit_ts = "unknown"
            commit_hash, commit_date = latest_commit, latest_date

        try:
            extracted = extract_tarball(tarball_path, temp_dir)
        except Exception as exc:  # noqa: BLE001
            console.error(f"Extraction failed: {exc}")
            return 1

        write_githash(extracted, commit_hash, commit_date, commit_ts)

        installer = extracted / "scripts" / "junior.py"
        if not installer.exists():
            console.error(f"Installer missing in extracted release: {installer}")
            return 1

        command = [
            sys.executable,
            str(installer),
            "install",
            "--target",
            install_target,
            "--force",
            "--ignore-dirty",
        ]
        if args.verbose:
            command.append("--verbose")

        console.info("Applying update...")
        result = subprocess.run(command, check=False)
        if result.returncode != 0:
            console.error("Install step failed during update")
            return result.returncode

    print("")
    console.success(f"Junior updated to commit {latest_commit[:7]}")
    return 0


def run_update(args: argparse.Namespace) -> int:
    console = Console(verbose=bool(args.verbose))
    if not has_explicit_target(args):
        console.error("Missing required --target. Use one of: claude, codex, cursor, gemini, all, or a csv list.")
        return 1
    try:
        targets = requested_targets(args)
    except ValueError as exc:
        console.error(str(exc))
        return 1
    exit_code = 0
    for install_target in targets:
        rc = run_update_for_target(args, install_target)
        if rc != 0:
            exit_code = rc
    return exit_code


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Junior cross-platform installer/update utility")
    sub = parser.add_subparsers(dest="command", required=True)

    install = sub.add_parser("install", help="Install or upgrade global Junior assets")
    install.add_argument("legacy_target_path", nargs="?", default="", help=argparse.SUPPRESS)
    install.add_argument(
        "-t",
        "--target",
        default="",
        help="Install targets: codex, cursor, gemini, claude, comma-list, or all",
    )
    install.add_argument("-v", "--verbose", action="store_true", help="Show debug output")
    install.add_argument("-i", "--ignore-dirty", action="store_true", help="Skip clean git check")
    install.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Skip confirmation prompts and overwrite tracked user-modified files",
    )

    sync = sub.add_parser("sync-back", help="Sync modified global assets back into Junior source")
    sync.add_argument("legacy_target_path", nargs="?", default="", help=argparse.SUPPRESS)
    sync.add_argument(
        "-t",
        "--target",
        default="",
        help="Sync targets: codex, cursor, gemini, claude, comma-list, or all",
    )
    sync.add_argument("-v", "--verbose", action="store_true", help="Show debug output")

    update = sub.add_parser("update", help="Check and apply global Junior updates")
    update.add_argument("--project-root", default="", help=argparse.SUPPRESS)
    update.add_argument("--check-only", action="store_true", help="Check update availability only")
    update.add_argument("-f", "--force", action="store_true", help="Skip confirmation prompts")
    update.add_argument("-v", "--verbose", action="store_true", help="Show debug output")
    update.add_argument("--local-source", help="Use a local Junior repository as update source")
    update.add_argument(
        "-t",
        "--target",
        default="",
        help="Update targets: codex, cursor, gemini, claude, comma-list, or all",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "install":
        return run_install(args)
    if args.command == "sync-back":
        return run_sync_back(args)
    if args.command == "update":
        return run_update(args)

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
