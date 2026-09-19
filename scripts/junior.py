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
import shlex
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

import managed_region
import native_skills
import release_source
from release_source import normalize_install_target, parse_install_targets


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
    "claude": InstallTargetConfig(home_dir=".claude", contract_filename="junior-contract.md"),
    "cursor": InstallTargetConfig(home_dir=".cursor", contract_filename="AGENTS.md"),
    "codex": InstallTargetConfig(home_dir=".codex", contract_filename="AGENTS.md"),
}
SUPPORTED_INSTALL_TARGETS = tuple(INSTALL_TARGETS.keys())

GLOBAL_SCOPE = "global"
PROJECT_SCOPE = "project"
INSTALL_SCOPES = (GLOBAL_SCOPE, PROJECT_SCOPE)
METADATA_FILENAME = ".junior-install.json"

# Claude Code expands this to the checkout a session was started in. A committed install
# has to reach its hook through that rather than through whatever absolute path the
# machine that ran the installer happened to see.
PROJECT_DIR_VARIABLE = "$CLAUDE_PROJECT_DIR"


@dataclass(frozen=True)
class InstallScope:
    """Which install a command operates on, and the base its paths resolve against.

    One field decides both. A global install resolves against the operator's home and
    never leaves the machine that wrote it. A project install resolves against a
    repository root and is committed, so everything it records has to mean the same
    thing in a checkout that has never seen this machine.
    """

    name: str
    root: Path

    @property
    def is_project(self) -> bool:
        return self.name == PROJECT_SCOPE

    def key(self, destination: Path) -> str:
        """The manifest key for one installed file, in this scope's spelling."""
        if not self.is_project:
            return manifest_key(destination)
        return destination.resolve().relative_to(self.root).as_posix()


def global_scope() -> InstallScope:
    return InstallScope(name=GLOBAL_SCOPE, root=Path.home().resolve())


def project_scope(root: Path) -> InstallScope:
    return InstallScope(name=PROJECT_SCOPE, root=Path(root).expanduser().resolve())


def normalize_install_scope(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in INSTALL_SCOPES:
        raise ValueError(f"Invalid scope '{value}'. Supported scopes: {', '.join(INSTALL_SCOPES)}")
    return normalized

# Rules are authored as neutral Markdown. Cursor loads a rules file only when it is
# spelled `.mdc` and declares that it always applies, so that form is produced on the
# way out rather than kept in source.
CANONICAL_RULE_SUFFIX = ".md"
CURSOR_RULE_SUFFIX = ".mdc"
CURSOR_RULE_FRONTMATTER = "---\nalwaysApply: true\n---\n\n"
ALWAYS_APPLY_RULE_NAME = re.compile(r"^\d+-")

# Runtimes Junior used to install. Named so their removal reads as a decision rather
# than a typo; files already written to those homes are left alone.

# Claude's polling guard is independent of native rule loading.
HOOK_INSTALL_TARGET = "claude"
HOOK_SCRIPT_NAME = "junior-session-start.py"

# The polling-loop guard refuses one shell shape that deadlocks with itself. It screens
# Bash calls, so it is registered before the tool rather than at session start.
GUARD_SCRIPT_NAME = "no-polling-loop.py"
GUARD_HOOK_MATCHER = "Bash"
GUARD_HOOK_TIMEOUT = 10

TARGET_CHOICES = f"{', '.join(SUPPORTED_INSTALL_TARGETS)}, comma-list, or all"
MISSING_TARGET_MESSAGE = (
    f"Missing required --target. Use one of: {', '.join(SUPPORTED_INSTALL_TARGETS)}, all, or a csv list."
)


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


def shipped_skill_names(root: Path) -> list[str]:
    """List callable shipped skills without private or support-only directories."""
    return sorted(path.parent.name for path in skills_root(root).glob("*/SKILL.md")
                  if path.is_file() and path.parent.name != "_shared")


def hooks_root(root: Path) -> Path:
    return agents_root(root) / "hooks"


def installed_rule_suffix(install_target: str) -> str:
    """The extension a runtime loads its rules from."""
    return CURSOR_RULE_SUFFIX if install_target == "cursor" else CANONICAL_RULE_SUFFIX


def canonical_rule_relpath(rel: Path) -> Path:
    """The source file behind an installed rule, whatever extension the runtime wanted."""
    return rel.with_suffix(CANONICAL_RULE_SUFFIX) if rel.suffix == CURSOR_RULE_SUFFIX else rel


def is_always_apply_rule_source(path: Path, repo_root: Path) -> bool:
    """Whether a source file is a rule the assistant should load on every turn.

    The rules tree also holds the material rules point at, such as document templates.
    Numbering is what separates the two: a template rendered as an always-apply rule
    would be loaded into every session alongside the rules themselves.
    """
    try:
        rel = path.relative_to(rules_root(repo_root))
    except ValueError:
        return False
    return bool(ALWAYS_APPLY_RULE_NAME.match(rel.name))


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
    if target == "codex":
        return (home or Path.home()).resolve() / ".agents/rules"
    return runtime_root(target, home) / "rules"


def runtime_skills_root(target: str, home: Path | None = None) -> Path:
    if target in native_skills.CONSUMERS:
        return (home or Path.home()).resolve() / native_skills.SKILL_ROOT
    return runtime_root(target, home) / "skills"


def runtime_contract_path(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / runtime_contract_filename(target)


def runtime_commands_root(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "commands"


def runtime_hooks_root(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "hooks"


def runtime_hook_script_path(target: str, home: Path | None = None) -> Path:
    return runtime_hooks_root(target, home) / HOOK_SCRIPT_NAME


def runtime_guard_script_path(target: str, home: Path | None = None) -> Path:
    return runtime_hooks_root(target, home) / GUARD_SCRIPT_NAME


def runtime_settings_path(target: str, home: Path | None = None) -> Path:
    return runtime_root(target, home) / "settings.json"


def instructions_relpath(install_target: str, scope: InstallScope) -> PurePosixPath:
    """Where the operator's instruction file sits, relative to the scope's base.

    A repository's instructions live at its root, because that is where the runtime
    looks for a project's own; an operator's live inside the runtime's home.
    """
    if scope.is_project:
        return PurePosixPath("CLAUDE.md")
    return PurePosixPath(install_target_config(install_target).home_dir) / "CLAUDE.md"


def instructions_path(install_target: str, scope: InstallScope) -> Path:
    """The operator's own instruction file, which Junior borrows one block of."""
    return scope.root / instructions_relpath(install_target, scope)


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


def install_metadata_path(target: str, scope: InstallScope) -> Path:
    return runtime_root(target, scope.root) / METADATA_FILENAME


def global_metadata_path(target: str) -> Path:
    return install_metadata_path(target, global_scope())


def local_metadata_rel_paths() -> set[str]:
    paths = {f".junior/{METADATA_FILENAME}", native_skills.SHARED_MANIFEST}
    for config in INSTALL_TARGETS.values():
        paths.add(f"{config.home_dir}/{METADATA_FILENAME}")
    return paths


def detect_platform() -> str:
    return "windows" if os.name == "nt" else "unix"


def is_absolute_destination(value: str) -> bool:
    if value.startswith("~/"):
        return True
    return Path(value).is_absolute()


def expand_destination(value: str, install_root: Path) -> Path:
    """Where a configured destination lands, given the base this install resolves against.

    Destinations are written `~/...` because that is the form a global install produces.
    The tilde means "this install's base", which is the operator's home for a global
    install and the repository root for a project one.
    """
    if value.startswith("~/"):
        return install_root / value[2:]
    raw = Path(value)
    if raw.is_absolute():
        return raw
    return install_root / raw


def manifest_key(destination: Path) -> str:
    """The canonical manifest key for one installed file.

    Every producer must spell a given path the same way, because the next install
    matches its own files by key. Resolving is what makes that true when the home
    directory is a symlink.
    """
    return str(destination.resolve())


def destination_key(base_destination: str, rel_path: str | None, scope: InstallScope) -> str:
    if is_absolute_destination(base_destination):
        base_path = expand_destination(base_destination, scope.root)
        return scope.key(base_path / rel_path if rel_path else base_path)

    if rel_path:
        return str(PurePosixPath(base_destination) / PurePosixPath(rel_path))
    return base_destination


def key_to_path(target_root: Path, key: str) -> Path:
    path = Path(os.path.expanduser(key))
    if path.is_absolute():
        return path
    return target_root / path


def normalized_manifest_key(key: str) -> str:
    """A key from an existing manifest, in the form this version records.

    Manifests written before keys were canonical can hold two spellings of one tree.
    Comparing those against freshly derived keys would orphan files that are still ours.
    """
    path = Path(os.path.expanduser(key))
    if not path.is_absolute():
        return key
    return manifest_key(path)


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


def is_blank_installed_contract(path: Path, install_target: str, scope: InstallScope) -> bool:
    expected = runtime_contract_path(install_target, scope.root).resolve()
    try:
        resolved = path.resolve()
    except FileNotFoundError:
        resolved = path

    if resolved != expected:
        return False
    return is_effectively_empty_text_file(path)


def query_latest_commit(console: Console) -> tuple[str, str]:
    try:
        release = release_source.select_release()
    except Exception as exc:  # noqa: BLE001
        console.debug(f"GitHub API request failed: {exc}")
        return "", ""

    return release.sha, release.date


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


def discover_cursor_rule_ops(repo_root: Path, scope: InstallScope, destination: str) -> list[FileOp]:
    ops: list[FileOp] = []
    rules_destination = expand_destination(destination, scope.root)
    source_root = rules_root(repo_root)

    for file_path in sorted(p for p in source_root.rglob("*") if p.is_file()):
        rel = PurePosixPath(file_path.relative_to(source_root).as_posix())
        if is_always_apply_rule_source(file_path, repo_root):
            rel = rel.with_suffix(CURSOR_RULE_SUFFIX)
        destination_path = rules_destination / rel
        ops.append(
            FileOp(
                source_path=file_path,
                dest_path=destination_path,
                metadata_key=scope.key(destination_path),
                skip_if_exists=False,
            )
        )
    return ops


def discover_file_ops(config: dict[str, Any], repo_root: Path, scope: InstallScope, platform_name: str, console: Console) -> list[FileOp]:
    ops: list[FileOp] = []
    mode_handlers = {
        "cursor_rules": discover_cursor_rule_ops,
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
            ops.extend(handler(repo_root, scope, destination))
            continue

        source_path = repo_root / source
        dest_base = expand_destination(destination, scope.root)

        if is_directory:
            if not source_path.is_dir():
                console.warning(f"Source directory not found: {source_path}")
                continue
            for file_path in sorted(p for p in source_path.rglob("*") if p.is_file()):
                rel = file_path.relative_to(source_path).as_posix()
                dest_path = dest_base / rel
                key = destination_key(destination, rel, scope)
                ops.append(
                    FileOp(
                        source_path=file_path,
                        dest_path=dest_path,
                        metadata_key=key,
                        skip_if_exists=skip_if_exists,
                    )
                )
        else:
            key = destination_key(destination, None, scope)
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
    data = native_skills.read_manifest(metadata_path)
    if data is None:
        return None
    files = data["files"]
    data["files"] = {normalized_manifest_key(key): value for key, value in files.items()}
    return data


def classify_action(
    op: FileOp,
    source_checksum: str,
    is_upgrade: bool,
    existing_files: dict[str, Any],
    overwrite: bool,
    install_target: str,
    scope: InstallScope,
) -> str:
    if not op.dest_path.exists():
        return "copy"

    if op.skip_if_exists:
        return "skip"

    current_checksum = sha256_file(op.dest_path)
    if current_checksum == source_checksum:
        return "noop"

    if not is_upgrade:
        if is_blank_installed_contract(op.dest_path, install_target, scope):
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

    if overwrite:
        return "overwrite_modified"

    return "preserve_modified"


def plan_install_actions(
    ops: list[FileOp],
    repo_root: Path,
    is_upgrade: bool,
    existing_files: dict[str, Any],
    overwrite: bool,
    install_target: str,
    scope: InstallScope,
    console: Console,
) -> tuple[list[PlannedAction], list[FileOp]]:
    planned: list[PlannedAction] = []
    conflicts: list[FileOp] = []

    for op in ops:
        if not op.source_path.exists():
            console.warning(f"Source file not found: {op.source_path}")
            continue

        source_checksum = sha256_bytes(rendered_source_bytes(op, repo_root, install_target, scope))
        action = classify_action(
            op,
            source_checksum,
            is_upgrade,
            existing_files,
            overwrite,
            install_target,
            scope,
        )

        if action == "conflict":
            conflicts.append(op)
            continue

        planned.append(PlannedAction(op=op, action=action, source_checksum=source_checksum))

    return planned, conflicts


def requested_targets(args: argparse.Namespace) -> list[str]:
    cli_value = str(getattr(args, "target", "") or "").strip()
    legacy_value = str(getattr(args, "legacy_target_path", "") or "").strip()
    raw_value = legacy_value if legacy_value and not cli_value else cli_value
    return parse_install_targets(raw_value)


def has_explicit_target(args: argparse.Namespace) -> bool:
    cli_value = str(getattr(args, "target", "") or "").strip()
    legacy_value = str(getattr(args, "legacy_target_path", "") or "").strip()
    return bool(cli_value or legacy_value)


def scope_prefix(scope: InstallScope) -> str:
    """How a path under this install's base is written down for a reader.

    A global install's paths are only ever read on the machine that holds them, so they
    are spelled from the home directory. A project's are read from a checkout whose
    location nobody can predict, so they are spelled from the repository root.
    """
    return "" if scope.is_project else "~/"


def target_home_alias(install_target: str, scope: InstallScope) -> str:
    return f"{scope_prefix(scope)}{install_target_config(install_target).home_dir}"


def target_contract_alias(install_target: str, scope: InstallScope) -> str:
    return f"{target_home_alias(install_target, scope)}/{runtime_contract_filename(install_target)}"


def strip_yaml_frontmatter(content: str) -> str:
    return re.sub(r"\A---\r?\n.*?\r?\n---\r?\n+", "", content, count=1, flags=re.S)


def render_cursor_command_content(content: str, source_path: Path, scope: InstallScope) -> str:
    return native_skills.render_command(content.encode(), source_path.parent.name, scope.is_project).decode()


def with_cursor_rule_frontmatter(content: str) -> str:
    """Declare a rule always-apply, replacing any block already there.

    Rendering runs again on every install, so injecting has to be idempotent or a
    reinstall grows a second frontmatter block that Cursor reads as body text.
    """
    return CURSOR_RULE_FRONTMATTER + strip_yaml_frontmatter(content)


def is_cursor_rule_source(source_path: Path, repo_root: Path, install_target: str) -> bool:
    return install_target == "cursor" and is_always_apply_rule_source(source_path, repo_root)


def should_render_source(source_path: Path, repo_root: Path, install_target: str) -> bool:
    """Whether a source file is transformed on its way into a runtime.

    Cursor rules declare themselves always-apply. Native skills and their supporting
    files, along with the Claude contract, are installed byte for byte.
    """
    if install_target != "cursor":
        return False
    return is_always_apply_rule_source(source_path, repo_root)


def render_source_bytes(
    content: bytes,
    source_path: Path,
    repo_root: Path,
    install_target: str,
    scope: InstallScope,
) -> bytes:
    """What the installer writes to a runtime for one source file.

    Install, sync-back's divergence check, and the manifest checksum all have to agree
    on this, so they all ask here rather than each deriving the rendered form.
    """
    if not should_render_source(source_path, repo_root, install_target):
        return content
    try:
        decoded = content.decode("utf-8")
    except UnicodeDecodeError:
        return content

    return with_cursor_rule_frontmatter(decoded).encode("utf-8")


def rendered_source_bytes(op: FileOp, repo_root: Path, install_target: str, scope: InstallScope) -> bytes:
    return render_source_bytes(
        op.source_path.read_bytes(), op.source_path, repo_root, install_target, scope
    )


def op_source_relpath(op: FileOp, repo_root: Path) -> str:
    try:
        return op.source_path.relative_to(repo_root).as_posix()
    except ValueError:
        return op.source_path.name


def build_target_install_config(config: dict[str, Any], install_target: str) -> dict[str, Any]:
    """The install layout for one target, exactly as configured.

    Every supported target declares its own entry. Nothing is derived from another
    target's paths, so a missing entry is a configuration error rather than an
    invitation to guess a layout.
    """
    targets = config.get("targets", {})
    target_config = targets.get(install_target) if isinstance(targets, dict) else None
    if not isinstance(target_config, dict):
        raise ValueError(
            f"install-config.json has no 'targets.{install_target}' entry. "
            f"Configured targets: {', '.join(sorted(targets)) if isinstance(targets, dict) else 'none'}"
        )
    return target_config


def renamed_rule_migrations(
    ops: list[FileOp], repo_root: Path, scope: InstallScope
) -> list[tuple[str, Path, str, Path]]:
    """Installed rules whose destination name changed since the last install.

    Rules were delivered as `.mdc` to every runtime before the canonical source became
    plain Markdown. Where a runtime now receives `.md`, the file already on disk is the
    same rule under its old name.
    """
    migrations = []
    for op in ops:
        if op.dest_path.suffix != CANONICAL_RULE_SUFFIX:
            continue
        if not is_always_apply_rule_source(op.source_path, repo_root):
            continue
        predecessor = op.dest_path.with_suffix(CURSOR_RULE_SUFFIX)
        migrations.append((scope.key(predecessor), predecessor, op.metadata_key, op.dest_path))
    return migrations


def migrate_renamed_files(
    migrations: list[tuple[str, Path, str, Path]],
    existing_files: dict[str, Any],
    console: Console,
) -> dict[str, Any]:
    """Carry each renamed file's identity onto its new name, before anything compares.

    Without this a rename reads as one deletion plus one fresh install. That discards
    the recorded checksum, which is the only thing that distinguishes a rule the user
    edited from one that was never touched.
    """
    migrated = dict(existing_files)

    for old_key, old_path, new_key, new_path in migrations:
        if old_key not in migrated or new_key in migrated:
            continue
        if new_path.exists():
            # Something already occupies the new name and it is not ours to move over.
            continue
        if old_path.is_file():
            old_path.rename(new_path)
            console.debug(f"Renamed installed file: {old_path.name} -> {new_path.name}")
        migrated[new_key] = migrated.pop(old_key)

    return migrated


def retired_handoff_source(source: str) -> bool:
    return source == "agents/hooks/junior-session-start.py" or source.startswith("agents/skills/jr-handoff/")


def remove_obsolete_files(
    target_root: Path,
    existing_files: dict[str, Any],
    new_manifest_keys: set[str],
    overwrite: bool,
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
            if overwrite and not retired_handoff_source(str(meta.get("source") or "")):
                path.unlink()
                removed.append(str(path))
                remove_empty_parents(path, target_root)
                console.warning(f"Obsolete user-modified file removed due to --overwrite: {path}")
                continue
            console.warning(f"Obsolete file preserved (user modified): {path}")
            continue

        path.unlink()
        removed.append(str(path))
        remove_empty_parents(path, target_root)

    return removed


def adopt_instructions_document(path: Path, legacy_contract: dict[str, Any] | None) -> tuple[str, bool]:
    """The document Junior's block goes into, and whether stale contract text is in it.

    Junior used to own this file outright. Where its contents are still exactly what
    Junior installed, the block replaces them, because that text now lives in the
    contract file. Where the operator has written in it, nothing is taken out: an
    unrecognised file is theirs, and a modified one is theirs plus a copy of a contract
    only they can safely untangle.
    """
    if not path.is_file():
        return "", False

    document = path.read_text(encoding="utf-8")
    if legacy_contract is None:
        return document, False
    if sha256_file(path) == str(legacy_contract.get("sha256") or ""):
        return "", False
    return document, True


def link_contract_from_instructions(
    install_target: str,
    scope: InstallScope,
    legacy_contract: dict[str, Any] | None,
    console: Console,
) -> None:
    """Point the operator's instruction file at the contract Junior installed."""
    path = instructions_path(install_target, scope)
    document, stale_contract = adopt_instructions_document(path, legacy_contract)

    try:
        updated = managed_region.upsert_markdown_block(
            document, f"@{target_contract_alias(install_target, scope)}"
        )
    except managed_region.ManagedRegionError as exc:
        console.warning(f"{path} left unchanged: {exc}")
        return

    if updated != document:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(updated, encoding="utf-8")
    console.info(f"Junior contract linked from {path}")

    if stale_contract:
        console.warning(
            f"{path} still holds the contract text Junior used to install there. The contract "
            f"is now {runtime_contract_path(install_target, scope.root)}; remove the older copy "
            f"from your file."
        )


def confirm_settings_consent(
    settings_path: Path,
    guard: Path,
    args: argparse.Namespace,
    console: Console,
) -> bool:
    if bool(args.yes):
        console.debug("Consent assumed from --yes")
        return True
    if not sys.stdin.isatty():
        return False

    print("")
    print(f"Junior registers the polling-loop guard in {settings_path}.")
    print(f"  PreToolUse    {guard}")
    print("                refuses one shell loop shape that deadlocks with itself")
    print("Existing settings and hooks are preserved.")
    return input("Register it? [y/N]: ").strip().lower() in {"y", "yes"}


def hook_command(script: Path, scope: InstallScope) -> str:
    """The hook line as the runtime's shell will read it.

    Claude Code runs this through a shell, and Junior does not choose the path it points
    at — the operator's home does. So the path goes in as data: a POSIX shell expands
    `$(...)` inside double quotes, which would make a directory name executable, and
    drops a lone backslash. `cmd` has neither behaviour and no single-quote form, so it
    keeps the quoting it understands.

    A project install names neither the repository nor the interpreter absolutely. Both
    belong to the machine that ran the installer, and this line is committed and read on
    machines that have never seen it. The runtime expands `$CLAUDE_PROJECT_DIR` to the
    checkout in hand, and a shell does not rescan what a parameter expanded to, so the
    operator's directory name is carried as data without appearing here at all. What is
    left inside the quotes is a path Junior chose.
    """
    expression = hook_script_expression(script, scope)
    if scope.is_project:
        return f"python3 {expression}"
    if detect_platform() == "windows":
        return f'"{sys.executable}" {expression}'
    return f"{shlex.quote(sys.executable)} {expression}"


def hook_script_expression(script: Path, scope: InstallScope) -> str:
    """The script's path alone, quoted as the runtime's shell will read it."""
    if scope.is_project:
        relative = script.resolve().relative_to(scope.root).as_posix()
        return f'"{PROJECT_DIR_VARIABLE}/{relative}"'
    if detect_platform() == "windows":
        return f'"{script}"'
    return shlex.quote(str(script))


def guard_hook_command(script: Path, scope: InstallScope) -> str:
    """The guard's hook line, wrapped so a missing script cannot block the tool.

    A guard that errors would refuse every Bash call in every project, which is a worse
    failure than the one it prevents. The existence test keeps it silent if the script is
    ever removed from under a registration that outlived it. `cmd` has no such test, so a
    Windows install registers the bare command and relies on the runtime to report it.
    """
    command = hook_command(script, scope)
    if not scope.is_project and detect_platform() == "windows":
        return command
    return f"[ -f {hook_script_expression(script, scope)} ] && {command} || true"


def retired_hook_settings(scope: InstallScope) -> tuple[Path, dict, dict]:
    """Plan scanner removal before obsolete files can disappear."""
    path = runtime_settings_path(HOOK_INSTALL_TARGET, scope.root)
    settings = read_json(path) if path.exists() else {}
    script = runtime_hook_script_path(HOOK_INSTALL_TARGET, scope.root)
    aliases = {str(script), "~/.claude/hooks/junior-session-start.py"}
    if scope.is_project:
        aliases = {str(script), "$CLAUDE_PROJECT_DIR/.claude/hooks/junior-session-start.py",
                   "${CLAUDE_PROJECT_DIR}/.claude/hooks/junior-session-start.py"}
    return path, settings, managed_region.remove_session_start_hook(settings, aliases)


def install_guard_hook(
    install_target: str,
    scope: InstallScope,
    args: argparse.Namespace,
    console: Console,
) -> None:
    """Register the polling guard with consent, independently of native rule loading."""
    settings_path = runtime_settings_path(install_target, scope.root)
    guard = runtime_guard_script_path(install_target, scope.root)
    if not guard.is_file():
        console.warning(f"Polling-loop guard not registered: {guard} is missing")
        return
    try:
        settings = read_json(settings_path) if settings_path.exists() else {}
        if not managed_region.has_hook(settings, managed_region.PRE_TOOL_USE, managed_region.GUARD_HOOK_TOKEN) and not confirm_settings_consent(
            settings_path, guard, args, console
        ):
            console.warning(f"Guard skipped: {settings_path} was not modified; native rules still load.")
            return
        merged = managed_region.upsert_guard_hook(
            settings, guard_hook_command(guard, scope), GUARD_HOOK_MATCHER, GUARD_HOOK_TIMEOUT
        )
    except (OSError, ValueError, managed_region.ManagedRegionError) as exc:
        console.warning(f"{settings_path} left unchanged: {exc}")
        return
    if merged != settings:
        write_json(settings_path, merged)
    console.info(f"Polling-loop guard registered in {settings_path}")


def requested_scope(args: argparse.Namespace) -> str:
    return str(getattr(args, "scope", "") or "").strip().lower()


def project_root_argument(args: argparse.Namespace) -> str:
    return str(getattr(args, "project_root", "") or "").strip()


def resolve_install_scope(args: argparse.Namespace, console: Console) -> InstallScope | None:
    """A destination selects project scope; otherwise install globally."""
    destination = str(args.legacy_target_path) if args.target else ""
    try:
        name, root = release_source.install_location(destination, requested_scope(args), project_root_argument(args))
    except ValueError as exc:
        console.error(str(exc))
        return None

    if name == GLOBAL_SCOPE:
        return global_scope()
    return project_scope(root)


def recorded_install_scope(metadata_path: Path) -> str:
    """The scope a manifest records, or "" where there is no manifest to ask.

    Manifests written before installs had a scope record none, and every one of those is
    a global install, because it is the only kind that existed.
    """
    if not metadata_path.is_file():
        return ""
    try:
        data = read_json(metadata_path)
    except (OSError, ValueError):
        return ""
    return str(data.get("scope") or GLOBAL_SCOPE)


def project_install_targets(root: Path) -> set[str]:
    return {
        target
        for target in SUPPORTED_INSTALL_TARGETS
        if recorded_install_scope(runtime_root(target, root) / METADATA_FILENAME) == PROJECT_SCOPE
    }


def discover_project_root(start: Path) -> Path | None:
    """The nearest directory at or above `start` holding a project install."""
    resolved = start.resolve()
    for directory in [resolved, *resolved.parents]:
        if project_install_targets(directory):
            return directory
    return None


def resolve_update_scope(
    args: argparse.Namespace,
    targets: list[str],
    console: Console,
) -> InstallScope | None:
    """Which install this run updates, stated outright or discovered from where it ran."""
    requested = requested_scope(args)
    raw_root = project_root_argument(args)

    if requested:
        try:
            name = normalize_install_scope(requested)
        except ValueError as exc:
            console.error(str(exc))
            return None
        if name == GLOBAL_SCOPE:
            return global_scope()
        root = (
            Path(raw_root).expanduser()
            if raw_root
            else (discover_project_root(Path.cwd()) or Path.cwd())
        )
        if not root.is_dir():
            console.error(f"Project root does not exist: {root}")
            return None
        return project_scope(root)

    discovered_root = discover_project_root(Path.cwd())
    if discovered_root is None:
        return global_scope()
    root = discovered_root

    vendored = project_install_targets(root)
    # Scope is resolved for the run, not per target. Resolving it per target would update
    # some of a run's targets inside the repository and the rest in the operator's home,
    # from a single command that named neither.
    elsewhere = [t for t in targets if t not in vendored and global_metadata_path(t).exists()]
    if elsewhere:
        console.error(
            f"Scope is ambiguous. {root} holds a project install of "
            f"{', '.join(sorted(vendored))}, and {', '.join(elsewhere)} is installed globally."
        )
        console.error("Re-run with --scope project or --scope global to say which one you mean.")
        return None
    return project_scope(root)


def dirty_managed_paths(scope: InstallScope, files: dict[str, Any]) -> list[str]:
    """Tracked edits, including deletions and both sides of staged renames."""
    try:
        # Git discovers the repository above the install root. Relative, NUL-separated
        # paths avoid porcelain quoting and directory aggregation; no-renames lists both sides.
        changed = subprocess.check_output(
            ["git", "diff", "HEAD", "--name-only", "--relative", "--no-renames", "-z", "--", "."],
            cwd=scope.root, stderr=subprocess.DEVNULL,
        )
    except (OSError, subprocess.SubprocessError):
        # No Git evidence is not permission: the checksum/recovery gate runs before install.
        return []
    return sorted(set(os.fsdecode(changed).split("\0")) & set(files))


def committed_project_file(scope: InstallScope, path: Path) -> bool:
    """Prove the current bytes exist in HEAD, independent of index flags or filters."""
    relative = path.relative_to(scope.root).as_posix()
    try:
        committed = subprocess.check_output(
            ["git", "show", f"HEAD:./{relative}"], cwd=scope.root, stderr=subprocess.DEVNULL,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    return committed == path.read_bytes()


def unsynced_runtime_edits(
    release_root: Path,
    files: dict[str, Any],
    install_target: str,
    scope: InstallScope,
) -> list[str]:
    """Installed files edited in the runtime that the incoming release would discard.

    Applies to both scopes. An edit already carried by the incoming release survives
    replacement; project updates additionally verify committed recovery for other edits.
    """
    at_risk: list[str] = []
    for key, value in files.items():
        if not isinstance(value, dict):
            continue
        recorded = str(value.get("sha256") or "")
        if not recorded:
            continue

        path = key_to_path(scope.root, key)
        if not path.exists() or not path.is_file():
            continue

        current = sha256_file(path)
        if current == recorded:
            continue

        source_path = source_path_for_sync(release_root, key, install_target, str(value.get("source") or ""))
        expected = (
            None if source_path is None
            else expected_installed_bytes(release_root, source_path, install_target, scope)
        )
        # Unmappable or absent in the release: nothing proves the edit survives, and the
        # branch that cannot tell must refuse rather than assume.
        if expected is not None and sha256_bytes(expected) == current:
            continue
        at_risk.append(str(path))

    return sorted(at_risk)


def run_install_for_target(
    args: argparse.Namespace,
    install_target: str,
    scope: InstallScope,
    native_plan: native_skills.NativePlan | None = None,
    hook_retirement: tuple[Path, dict, dict] | None = None,
) -> int:
    console = Console(verbose=bool(args.verbose))
    repo_root = repo_root_from_script()
    install_root = scope.root
    config_path = repo_root / "scripts" / "install-config.json"

    if not (rules_root(repo_root) / "00-junior.md").exists():
        console.error("Cannot find Junior files. Run from the Junior repository.")
        return 1

    if not config_path.exists():
        console.error(f"Config file not found: {config_path}")
        return 1

    console.info(f"Target: {install_target}")
    console.info(f"Scope: {scope.name} ({install_root})")

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

    metadata_path = install_metadata_path(install_target, scope)
    existing = load_existing_metadata(metadata_path)
    is_upgrade = existing is not None
    existing_files = (existing or {}).get("files", {})
    if not isinstance(existing_files, dict):
        existing_files = {}
    if native_plan is not None and install_target in native_skills.CONSUMERS:
        # Legacy ownership is retired by the shared plan only after replacements exist.
        # Runtime rules remain on the ordinary renderer/update path.
        existing_files = {k: v for k, v in existing_files.items()
                          if install_target == "cursor" and key_to_path(scope.root, k).is_relative_to(runtime_rules_root("cursor", scope.root))}

    # Create configured directories.
    for value in config.get("directories", []):
        if not isinstance(value, str):
            continue
        expand_destination(value, install_root).mkdir(parents=True, exist_ok=True)

    platform_name = detect_platform()
    ops = discover_file_ops(config, repo_root, scope, platform_name, console)
    if native_plan is not None and install_target in native_skills.CONSUMERS:
        ops = [op for op in ops if op.dest_path.resolve() not in native_plan.writes]

    new_manifest_keys = {op.metadata_key for op in ops}
    if is_upgrade:
        existing_files = migrate_renamed_files(
            renamed_rule_migrations(ops, repo_root, scope), existing_files, console
        )

    # The contract used to be installed as the operator's own instruction file. Dropping its
    # manifest key keeps obsolete-file removal away from a file that is now theirs, while the
    # checksum it recorded still answers whether what is on disk is Junior's own text.
    legacy_contract: dict[str, Any] | None = None
    if is_upgrade and install_target == HOOK_INSTALL_TARGET:
        entry = existing_files.pop(scope.key(instructions_path(install_target, scope)), None)
        legacy_contract = entry if isinstance(entry, dict) else None

    planned, conflicts = plan_install_actions(
        ops, repo_root, is_upgrade, existing_files, bool(args.overwrite), install_target, scope, console
    )

    if conflicts:
        console.error("INSTALLATION ABORTED - file conflicts detected:")
        for op in conflicts:
            console.error(f"  - {op.dest_path}")
        console.info("Remove conflicting files or run in a clean environment before retrying.")
        return 1

    if hook_retirement is not None:
        settings_path, original_settings, retired_settings = hook_retirement
        if retired_settings != original_settings:
            write_json(settings_path, retired_settings)
            console.info(f"Retired Junior startup scanner from {settings_path}")

    # Nothing is deleted until the install is known to be able to finish. An abort that
    # has already removed files leaves the runtime worse than it found it, and retrying
    # reproduces the same abort with less left to recover.
    removed_files: list[str] = []
    if is_upgrade:
        removed_files = remove_obsolete_files(
            install_root, existing_files, new_manifest_keys, bool(args.overwrite), console
        )

    metadata_files: dict[str, dict[str, Any]] = {
        key: value for key, value in existing_files.items()
        if key not in new_manifest_keys and isinstance(value, dict)
        and retired_handoff_source(str(value.get("source") or ""))
        and key_to_path(install_root, key).is_file()
    }
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
                **existing_files[op.metadata_key],
                "modified": True,
            }
            console.warning(f"User-modified: {op.dest_path} (preserving)")
            continue

        if action == "copy":
            if should_render_source(op.source_path, repo_root, install_target):
                op.dest_path.write_bytes(rendered_source_bytes(op, repo_root, install_target, scope))
            else:
                shutil.copy2(op.source_path, op.dest_path)
            console.debug(f"Installed: {op.dest_path}")
        elif action == "overwrite_modified":
            if should_render_source(op.source_path, repo_root, install_target):
                op.dest_path.write_bytes(rendered_source_bytes(op, repo_root, install_target, scope))
            else:
                shutil.copy2(op.source_path, op.dest_path)
            overwritten_files.append(str(op.dest_path))
            console.warning(f"User-modified: {op.dest_path} (overwritten due to --overwrite)")
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
        "release": parse_env_file(repo_root / ".githash").get("RELEASE", ""),
        "installed_at": installed_at,
        "commit_hash": commit_hash,
        "scope": scope.name,
        "files": metadata_files,
    }
    if existing is not None and all(metadata[k] == existing.get(k) for k in ("version", "commit_hash", "scope")):
        metadata["installed_at"] = existing.get("installed_at", installed_at)
    if native_plan is not None and install_target in native_skills.CONSUMERS:
        metadata["shared_skills"] = native_skills.SHARED_MANIFEST
    write_json(metadata_path, metadata)

    if install_target == HOOK_INSTALL_TARGET:
        link_contract_from_instructions(install_target, scope, legacy_contract, console)
        install_guard_hook(install_target, scope, args, console)

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
        console.warning(f"Overwritten user-modified files due to --overwrite ({len(overwritten_files)}):")
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
        print("")
        console.info("Skills installed: " + ", ".join(shipped_skill_names(repo_root)))

    return 0


def run_install(args: argparse.Namespace) -> int:
    console = Console(verbose=bool(args.verbose))
    if not has_explicit_target(args):
        console.error(MISSING_TARGET_MESSAGE)
        return 1
    try:
        targets = requested_targets(args)
    except ValueError as exc:
        console.error(str(exc))
        return 1

    scope = resolve_install_scope(args, console)
    if scope is None:
        return 1

    release_source.show_installed(scope.root, targets)
    source = repo_root_from_script()
    label = parse_env_file(source / ".githash").get("RELEASE", "local checkout")
    console.info(f"Install Junior {label} for {', '.join(targets)} in {scope.root} ({scope.name})")
    if sys.stdin.isatty() and not args.yes:
        if release_source.prompt("Continue? [y/N]: ").lower() not in ("y", "yes"):
            console.info("Installation cancelled.")
            return 0
        args.yes = True

    hook_retirement = None
    if HOOK_INSTALL_TARGET in targets:
        try:
            hook_retirement = retired_hook_settings(scope)
        except (OSError, ValueError, managed_region.ManagedRegionError) as exc:
            console.warning(f"{runtime_settings_path(HOOK_INSTALL_TARGET, scope.root)} left unchanged: {exc}")
            console.error("Startup retirement incomplete; existing assets preserved. Reconcile settings before retrying.")
            return 1

    native_plan = None
    try:
        # Validate every participant before the first runtime is changed.
        for target in targets:
            native_skills.owned_path(scope.root, str(install_metadata_path(target, scope)))
            load_existing_metadata(install_metadata_path(target, scope))
        if set(targets).intersection(native_skills.CONSUMERS):
            repo = repo_root_from_script()
            commit_hash, version = resolve_source_version(repo, bool(args.ignore_dirty), console)
            native_plan = native_skills.plan_install(repo, scope.root, scope.is_project, targets, {"commit_hash": commit_hash, "version": version})
            config = read_json(repo / "scripts/install-config.json")
            for target in targets:
                ops = discover_file_ops(build_target_install_config(config, target), repo, scope, detect_platform(), console)
                for op in ops:
                    native_skills.owned_path(scope.root, str(op.dest_path))
                ops = [op for op in ops if op.dest_path.resolve() not in native_plan.writes]
                existing = load_existing_metadata(install_metadata_path(target, scope))
                _, conflicts = plan_install_actions(ops, repo, existing is not None, (existing or {}).get("files", {}), bool(args.overwrite), target, scope, console)
                if conflicts:
                    raise ValueError("Installation conflicts: " + ", ".join(str(op.dest_path) for op in conflicts))
    except (OSError, ValueError) as exc:
        console.error(str(exc))
        return 1

    exit_code = 0
    for install_target in targets:
        rc = run_install_for_target(
            args, install_target, scope, native_plan,
            hook_retirement if install_target == HOOK_INSTALL_TARGET else None,
        )
        if rc != 0:
            exit_code = rc
    if exit_code == 0 and native_plan is not None:
        native_plan.apply()
        console.info("Native skills are shared: Codex and Cursor both discover .agents/skills and use one installed skill version.")
        if native_plan.codex_capacity:
            console.info(f"Codex startup rules installed through AGENTS.md; project_doc_max_bytes capacity: {native_plan.codex_capacity} bytes. Start a fresh session.")
            if scope.is_project:
                console.info("Codex loads project configuration only in trusted projects; trust this project before using its installed rules.")
        console.info("Cursor global rule activation requires separate setup.")
        for target, items in native_plan.pending.items():
            for item in items:
                console.warning(f"Pending cleanup [{target}]: {item['path']} ({item['reason']})")
    return exit_code


def source_path_for_sync(
    repo_root: Path,
    key: str,
    install_target: str,
    source_rel: str = "",
) -> Path | None:
    """Resolve installed assets without resurrecting a retired handoff workflow."""
    source = mapped_source_path(repo_root, key, install_target, source_rel)
    if source is not None and retired_handoff_source(source.relative_to(repo_root).as_posix()) and not source.exists():
        return None
    return source


def mapped_source_path(
    repo_root: Path,
    key: str,
    install_target: str,
    source_rel: str = "",
) -> Path | None:
    path = key_to_path(global_install_root(), key).resolve()
    # Old manifests name the repository entry point as an installed contract source.
    # Resolve that identity before trusting source metadata; native instructions are
    # generated and must never be synced over contributor guidance.
    if source_rel == "AGENTS.md" or key == "AGENTS.md" or path == runtime_contract_path(install_target).resolve():
        return repo_root / "agents/contracts/claude.md" if install_target == "claude" else None

    if source_rel:
        candidate = repo_root / source_rel
        if candidate.exists() or not source_rel.startswith("~"):
            return candidate

    home = Path.home().resolve()
    resolved = path

    target_rules = runtime_rules_root(install_target, home).resolve()
    target_skills = runtime_skills_root(install_target, home).resolve()
    target_commands = runtime_commands_root(install_target, home).resolve()
    target_junior_doc = runtime_junior_doc_path(install_target, home).resolve()
    target_legacy_junior_doc = runtime_legacy_junior_doc_path(install_target, home).resolve()
    cursor_support_root = runtime_cursor_support_root(home).resolve()
    cursor_doc = runtime_cursor_doc_path(home).resolve()

    # Exact-match destinations must be tested before the prefix branches below.
    # The junior-readme and cursor docs live *inside* the skills/commands trees, so a
    # prefix test reached first would claim them and map them to a stray source path
    # instead of README.md.
    if resolved in {target_junior_doc, target_legacy_junior_doc, cursor_doc}:
        return repo_root / "README.md"

    if str(resolved).startswith(str(target_rules) + os.sep):
        rel = resolved.relative_to(target_rules)
        return rules_root(repo_root) / canonical_rule_relpath(rel)

    if str(resolved).startswith(str(target_skills) + os.sep):
        rel = resolved.relative_to(target_skills)
        return skills_root(repo_root) / rel

    # Hooks are installed for one runtime only, so the tree is claimed for that runtime
    # alone. Without this branch a hook edited in the runtime maps nowhere, and sync
    # reports it as an unknown mapping instead of copying it back.
    if install_target == HOOK_INSTALL_TARGET:
        target_hooks = runtime_hooks_root(install_target, home).resolve()
        if str(resolved).startswith(str(target_hooks) + os.sep):
            return hooks_root(repo_root) / resolved.relative_to(target_hooks)

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

    return None


@dataclass(frozen=True)
class SyncCandidate:
    target: str
    key: str
    src_path: Path
    dest_path: Path
    sha256: str


@dataclass(frozen=True)
class SyncFinding:
    """A global-vs-source difference that sync must report but must not resolve on its own."""

    target: str
    kind: str
    global_path: Path
    source_path: Path | None
    detail: str


def installed_targets_with_metadata() -> list[str]:
    targets: list[str] = []
    for target in SUPPORTED_INSTALL_TARGETS:
        if global_metadata_path(target).exists():
            targets.append(target)
    return targets


def unrender_bytes_for_source(content: bytes, source_path: Path, repo_root: Path, install_target: str) -> bytes:
    """Undo install-time rendering before a runtime file is written back to source.

    Only Cursor's always-apply frontmatter is undone, because it is the only render that
    source must not carry. Nothing here rewrites paths: a file that names a runtime home
    means it, and a textual substitution could not tell that apart from a rendered path.
    """
    if not is_cursor_rule_source(source_path, repo_root, install_target):
        return content
    try:
        decoded = content.decode("utf-8")
    except UnicodeDecodeError:
        return content
    return strip_yaml_frontmatter(decoded).encode("utf-8")


def expected_installed_bytes(
    repo_root: Path,
    source_path: Path,
    install_target: str,
    scope: InstallScope,
) -> bytes | None:
    """What the installer would write to the runtime for this source file right now."""
    if not source_path.exists() or not source_path.is_file():
        return None
    return render_source_bytes(source_path.read_bytes(), source_path, repo_root, install_target, scope)


def junior_scan_roots(install_target: str) -> list[Path]:
    roots = [runtime_rules_root(install_target), runtime_skills_root(install_target)]
    if install_target == HOOK_INSTALL_TARGET:
        roots.append(runtime_hooks_root(install_target))
    if install_target == "cursor":
        roots.extend([runtime_commands_root(install_target), runtime_cursor_support_root()])
    return [root for root in roots if root.is_dir()]


def looks_like_junior_asset(path: Path, root: Path, repo_root: Path, install_target: str) -> bool:
    """Whether a file the installer never wrote still looks like Junior's to own.

    Runtimes ship their own skills and rules into the same directories Junior installs
    into, so presence under a scan root proves nothing about authorship. Junior's own
    naming is the only signal available: ``jr``-prefixed skill directories, rule files
    in the extension that runtime is installed with, and any name that exists in source.
    """
    try:
        rel = path.relative_to(root)
    except ValueError:
        return False
    if not rel.parts:
        return False
    head = rel.parts[0]
    if head.startswith("."):
        return False

    if root == runtime_rules_root(install_target):
        return path.suffix == installed_rule_suffix(install_target) or (
            rules_root(repo_root) / canonical_rule_relpath(rel)
        ).exists()

    # The hooks directory is shared with whatever hooks the operator wrote themselves,
    # so the extension is the only signal, as it is for rules. A finding here asks for a
    # decision rather than copying anything, so claiming an operator's own hook costs
    # them one line to dismiss. Missing Junior's costs the file.
    if root == runtime_hooks_root(install_target):
        return path.suffix == ".py"

    return head.startswith("jr") or head == "_shared" or (skills_root(repo_root) / head).exists()


def collect_sync_candidates_for_target(
    repo_root: Path,
    install_target: str,
    console: Console,
) -> tuple[list[SyncCandidate], list[SyncFinding], list[str]]:
    # Sync-back reads what an operator edited in their own runtime. A project install is
    # edited through the repository and reviewed as a diff there, so it has no part here.
    scope = global_scope()
    install_root = scope.root
    metadata_path = install_metadata_path(install_target, scope)
    if not metadata_path.exists():
        return [], [], [f"Metadata file missing for target {install_target}: {metadata_path}"]

    metadata = load_existing_metadata(metadata_path)
    assert metadata is not None
    files = native_skills.effective_files(scope.root, metadata)
    pending = {item["path"] for item in metadata.get("pending_cleanup", [])}
    for item in metadata.get("pending_cleanup", []):
        console.warning(f"Pending reconciliation: {item['path']} ({item['reason']})")
    files = {key: entry for key, entry in files.items() if key not in pending}
    if not isinstance(files, dict):
        files = {}

    candidates: list[SyncCandidate] = []
    findings: list[SyncFinding] = []
    warnings: list[str] = []
    installed_paths: set[Path] = {key_to_path(scope.root, key).resolve() for key in pending}

    for key, value in files.items():
        if not isinstance(value, dict):
            continue
        installed_sha = str(value.get("sha256") or "")
        if not installed_sha:
            continue

        target_path = key_to_path(install_root, key)
        installed_paths.add(target_path.resolve())

        source_rel = str(value.get("source") or "")
        dest_path = source_path_for_sync(repo_root, key, install_target, source_rel)

        if not target_path.exists() or not target_path.is_file():
            findings.append(
                SyncFinding(
                    target=install_target,
                    kind="deleted",
                    global_path=target_path,
                    source_path=dest_path,
                    detail="Installed file was deleted from the runtime. Source is left untouched.",
                )
            )
            continue

        current_sha = sha256_file(target_path)
        if current_sha == installed_sha:
            continue

        if dest_path is None:
            warnings.append(f"Skipping unknown mapping for {install_target}: {key}")
            continue

        # A runtime file differing from its recorded install sha was edited in place.
        # Whether that edit is safe to copy back depends on the source having stood
        # still: if source also moved on, copying back silently reverts it.
        expected = expected_installed_bytes(repo_root, dest_path, install_target, scope)
        if expected is not None and sha256_bytes(expected) == current_sha:
            # Source already carries this edit; the stale install metadata is the only
            # thing still disagreeing, and the next install refreshes it.
            continue
        if expected is not None and sha256_bytes(expected) != installed_sha:
            findings.append(
                SyncFinding(
                    target=install_target,
                    kind="diverged",
                    global_path=target_path,
                    source_path=dest_path,
                    detail="Runtime and source both changed since install. Copying back would revert source.",
                )
            )
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

    for root in junior_scan_roots(install_target):
        for path in sorted(p for p in root.rglob("*") if p.is_file()):
            if path.name == ".DS_Store" or path.resolve() in installed_paths:
                continue
            if not looks_like_junior_asset(path, root, repo_root, install_target):
                continue
            key = str(path)
            dest_path = source_path_for_sync(repo_root, key, install_target)
            if dest_path is None or dest_path.exists():
                continue
            findings.append(
                SyncFinding(
                    target=install_target,
                    kind="added",
                    global_path=path,
                    source_path=dest_path,
                    detail="Authored in the runtime and absent from source. It exists nowhere else.",
                )
            )

    return candidates, findings, warnings


def report_sync_findings(findings: list[SyncFinding], console: Console) -> None:
    labels = {
        "added": "Global-only files (not in source)",
        "deleted": "Deleted from the runtime (still in source)",
        "diverged": "Changed in BOTH runtime and source",
    }
    for kind in ("added", "diverged", "deleted"):
        group = [f for f in findings if f.kind == kind]
        if not group:
            continue
        print("")
        console.warning(f"{labels[kind]} ({len(group)}):")
        for finding in group:
            print(f"  - [{finding.target}] {finding.global_path}")
            if finding.source_path is not None:
                print(f"      source: {finding.source_path}")
            print(f"      {finding.detail}")


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
    try:
        for target in targets:
            metadata = load_existing_metadata(global_metadata_path(target))
            if metadata is None:
                raise ValueError(f"Missing ownership metadata for sync target {target}: {global_metadata_path(target)}")
            native_skills.effective_files(global_scope().root, metadata)
            if target in native_skills.CONSUMERS and "shared_skills" not in metadata:
                raise ValueError(f"Legacy {target} layout: run install --target {target} before sync-back.")
    except (OSError, ValueError) as exc:
        console.error(str(exc))
        return 1
    all_candidates: list[SyncCandidate] = []
    all_findings: list[SyncFinding] = []
    warnings: list[str] = []

    for install_target in targets:
        console.info(f"Inspecting target: {install_target}")
        candidates, findings, target_warnings = collect_sync_candidates_for_target(repo_root, install_target, console)
        all_candidates.extend(candidates)
        all_findings.extend(findings)
        warnings.extend(target_warnings)

    for warning in warnings:
        console.warning(warning)

    adopt = bool(getattr(args, "adopt_new", False))
    if adopt:
        for finding in [f for f in all_findings if f.kind == "added"]:
            assert finding.source_path is not None
            all_candidates.append(
                SyncCandidate(
                    target=finding.target,
                    key=str(finding.global_path),
                    src_path=finding.global_path,
                    dest_path=finding.source_path,
                    sha256=sha256_file(finding.global_path),
                )
            )
        all_findings = [f for f in all_findings if f.kind != "added"]

    if all_candidates:
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
        content = unrender_bytes_for_source(chosen.src_path.read_bytes(), dest_path, repo_root, chosen.target)
        dest_path.parent.mkdir(parents=True, exist_ok=True)
        dest_path.write_bytes(content)
        console.success(f"Synced: {chosen.src_path} -> {dest_path}")
        synced += 1

    report_sync_findings(all_findings, console)

    print("")
    if conflict_count:
        console.warning(f"Sync completed with {conflict_count} conflict(s). Conflicted files were not overwritten.")
    if not all_candidates and not all_findings:
        console.success("No modified files to sync")
        return 0
    console.success(f"Sync complete. {synced} files copied to Junior source.")

    unresolved = [f for f in all_findings if f.kind in {"added", "diverged"}]
    if unresolved:
        console.warning(f"{len(unresolved)} item(s) need a decision and were not copied. Review the list above.")
    return 1 if conflict_count else 0


def create_local_tarball(local_source: Path, tarball_path: Path, console: Console) -> None:
    if not local_source.exists() or not local_source.is_dir():
        raise RuntimeError(f"Local source does not exist: {local_source}")
    if not (rules_root(local_source) / "00-junior.md").exists():
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


def run_update_for_target(args: argparse.Namespace, install_target: str, scope: InstallScope) -> int:
    console = Console(verbose=bool(args.verbose))
    metadata_path = install_metadata_path(install_target, scope)
    console.info(f"Target: {install_target}")
    console.info(f"Scope: {scope.name} ({scope.root})")

    if not metadata_path.exists():
        console.error(f"Junior {scope.name} installation metadata not found.")
        console.error(f"Missing metadata: {metadata_path}")
        return 1

    metadata = load_existing_metadata(metadata_path)
    assert metadata is not None
    manifest_files = native_skills.effective_files(scope.root, metadata)
    if not isinstance(manifest_files, dict):
        manifest_files = {}

    if scope.is_project:
        dirty = dirty_managed_paths(scope, manifest_files)
        if dirty:
            console.error(f"{scope.root} has uncommitted changes to files this update rewrites:")
            for value in dirty:
                console.error(f"  - {value}")
            console.error("Commit or discard them, then run update again.")
            return 1

    shared = native_skills.shared_metadata(scope.root, metadata)
    current_commit = str(metadata.get("commit_hash") or "")
    current_version = str(metadata.get("version") or "")
    installed_at = str(metadata.get("installed_at") or "")

    local_source_path: Path | None = None
    selected_release = None
    if args.local_source:
        local_source_path = Path(args.local_source).expanduser().resolve()
        try:
            latest_commit, latest_date, _latest_ts = local_source_version(local_source_path)
        except Exception as exc:  # noqa: BLE001
            console.error(f"Failed to resolve local source version: {exc}")
            return 1
    else:
        try:
            selected_release = release_source.requested_release(args)
        except (OSError, ValueError, KeyError) as exc:
            console.error(f"Failed to resolve release: {exc}")
            return 1
        if selected_release is None:
            return 0
        latest_commit, latest_date = selected_release.sha, selected_release.date
        console.info(f"Selected release: {selected_release.name}")

    print("")
    console.info("Junior Version Check")
    print(f"  Current commit: {(current_commit[:7] if current_commit else 'unknown')}")
    print(f"  Current version: {metadata.get('release') or current_version or 'unknown'}")
    if shared:
        print(f"  Shared skill version (Codex/Cursor): {shared.get('version', 'unknown')} ({shared.get('commit_hash', 'unknown')})")
    if installed_at:
        print(f"  Installed at: {installed_at}")
    print(f"  Latest commit: {latest_commit[:7]}")
    print(f"  Latest date: {latest_date or 'unknown'}")

    if current_commit == latest_commit and (shared is None or shared.get("commit_hash") == latest_commit):
        print("")
        console.success("Junior is up to date")
        return 0

    print("")
    console.warning("Update available")

    if args.check_only:
        return 2

    if not args.yes:
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
            console.info(f"Downloading Junior {selected_release.name}...")

        try:
            if selected_release is not None:
                extracted = release_source.download_release(selected_release, temp_dir)
            else:
                extracted = extract_tarball(tarball_path, temp_dir)
                write_githash(extracted, commit_hash, commit_date, commit_ts)
        except (OSError, ValueError, tarfile.TarError, RuntimeError) as exc:
            console.error(f"Download or extraction failed: {exc}")
            return 1

        installer = extracted / "scripts" / "junior.py"
        if not installer.exists():
            console.error(f"Installer missing in extracted release: {installer}")
            return 1

        if shared and not (extracted / "scripts/native_skills.py").is_file():
            console.error("Update source does not support shared skills; refusing legacy installer before mutation.")
            return 1

        if install_target == "codex" and not (extracted / "scripts/codex_rules.py").is_file():
            console.error("Update source does not support native Codex rules; refusing legacy installer before mutation.")
            return 1

        at_risk = unsynced_runtime_edits(extracted, manifest_files, install_target, scope)
        if scope.is_project:
            at_risk = [value for value in at_risk if not committed_project_file(scope, Path(value))]
        if at_risk:
            console.error("Runtime edits are not in the update source and would be lost:")
            for value in at_risk:
                console.error(f"  - {value}")
            if scope.is_project:
                console.error("Git recovery could not be verified. Commit these exact files or sync their edits into source.")
            else:
                console.error("Run `/jr sync` to bring them into source, then run update again.")
            return 1

        command = [
            sys.executable,
            str(installer),
            "install",
            "--target",
            install_target,
            "--scope",
            scope.name,
            "--yes",
            "--ignore-dirty",
        ]
        # Destruction is requested only where it can still be exercised. A project install
        # reaches files modified since install and committed since, which git can give back
        # and the gate above has cleared; replacing those is what update is for. A global
        # install cannot reach one any more: the gate refuses every runtime edit the release
        # does not already carry, and an edit it does carry installs as a no-op. Passing the
        # grant there would leave it standing on the strength of a guard rather than a need
        # — the same unearned grant this gate was added to remove, one turn further out.
        if scope.is_project:
            command.extend(("--project-root", str(scope.root)))
            command.append("--overwrite")
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
        console.error(MISSING_TARGET_MESSAGE)
        return 1
    try:
        targets = requested_targets(args)
    except ValueError as exc:
        console.error(str(exc))
        return 1

    scope = resolve_update_scope(args, targets, console)
    if scope is None:
        return 1

    try:
        for target in targets:
            metadata = load_existing_metadata(install_metadata_path(target, scope))
            if metadata is not None:
                native_skills.effective_files(scope.root, metadata)
    except (OSError, ValueError) as exc:
        console.error(str(exc))
        return 1

    exit_code = 0
    for install_target in targets:
        rc = run_update_for_target(args, install_target, scope)
        if rc != 0:
            exit_code = rc
    return exit_code


RETIRED_FORCE_MESSAGE = (
    "--force is retired: one word granted two unrelated permissions. Use --yes to answer "
    "prompts without a terminal, --overwrite to replace installed files you have modified "
    "(install only), or both to grant what --force used to."
)


def add_retired_force(parser: argparse.ArgumentParser) -> None:
    """Accept the retired flag so it can be refused by name rather than by parser error.

    Dropping it outright would leave an operator with an unrecognised-argument message
    that names neither replacement, which is the same silence that let one flag stand for
    two grants in the first place.
    """
    parser.add_argument("-f", "--force", action="store_true", help=argparse.SUPPRESS)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Junior cross-platform installer/update utility")
    sub = parser.add_subparsers(dest="command", required=True)

    install = sub.add_parser("install", help="Install or upgrade Junior assets")
    install.add_argument("legacy_target_path", nargs="?", default="", metavar="destination", help="Project directory; omit to install globally")
    install.add_argument(
        "-t",
        "--target",
        default="",
        help=f"Install targets: {TARGET_CHOICES}",
    )
    install.add_argument(
        "--scope",
        default="",
        help=argparse.SUPPRESS,
    )
    install.add_argument(
        "--project-root",
        default="",
        help="Repository a project install is vendored into (default: current directory)",
    )
    install.add_argument("-v", "--verbose", action="store_true", help="Show debug output")
    install.add_argument("-i", "--ignore-dirty", action="store_true", help="Skip clean git check")
    install.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Assume yes to prompts, so a run without a terminal can finish",
    )
    install.add_argument(
        "--overwrite",
        action="store_true",
        help="Replace installed files you have since modified",
    )
    add_retired_force(install)

    sync = sub.add_parser("sync-back", help="Sync modified global assets back into Junior source")
    sync.add_argument("legacy_target_path", nargs="?", default="", help=argparse.SUPPRESS)
    sync.add_argument(
        "-t",
        "--target",
        default="",
        help=f"Sync targets: {TARGET_CHOICES}",
    )
    sync.add_argument("-v", "--verbose", action="store_true", help="Show debug output")
    sync.add_argument(
        "--adopt-new",
        action="store_true",
        help="Also copy global-only files into source. Off by default; they are reported for review.",
    )

    update = sub.add_parser("update", help="Check and apply Junior updates")
    release_source.add_version_arguments(update)
    update.add_argument(
        "--scope",
        default="",
        help="Which install to update; discovered from the working directory when omitted",
    )
    update.add_argument(
        "--project-root",
        default="",
        help="Repository whose project install to update (default: discovered upward from here)",
    )
    update.add_argument("--check-only", action="store_true", help="Check update availability only")
    update.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Assume yes to prompts, so a run without a terminal can finish",
    )
    add_retired_force(update)
    update.add_argument("-v", "--verbose", action="store_true", help="Show debug output")
    update.add_argument("--local-source", help="Use a local Junior repository as update source")
    update.add_argument(
        "-t",
        "--target",
        default="",
        help=f"Update targets: {TARGET_CHOICES}",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if getattr(args, "force", False):
        Console(verbose=False).error(RETIRED_FORCE_MESSAGE)
        return 1

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
