"""Plan shared skill ownership and legacy retirement before touching an installation."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import codex_rules

CONSUMERS = ("codex", "cursor")
MANIFEST = ".junior-install.json"
SHARED_MANIFEST = f".agents/{MANIFEST}"
SKILL_ROOT = ".agents/skills"


class ManifestError(ValueError):
    """Ownership metadata cannot safely authorize an operation."""


def checksum(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def read_manifest(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    data = json.loads(path.read_text())
    if not isinstance(data, dict) or not isinstance(data.get("files"), dict):
        raise ManifestError(f"Malformed ownership manifest: {path}")
    pending = data.get("pending_cleanup", [])
    if not isinstance(pending, list) or any(not isinstance(item, dict) or not isinstance(item.get("path"), str) or not isinstance(item.get("reason"), str) for item in pending):
        raise ValueError(f"Malformed pending cleanup inventory: {path}")
    for key, entry in data["files"].items():
        if not isinstance(key, str) or not isinstance(entry, dict) or not isinstance(entry.get("sha256"), str) or not entry["sha256"]:
            raise ValueError(f"Malformed ownership entry in {path}: {key}")
        if "source" in entry and not isinstance(entry["source"], str):
            raise ValueError(f"Malformed source in {path}: {key}")
        source = Path(entry.get("source", ""))
        if source.is_absolute() or ".." in source.parts or str(source).startswith("~"):
            raise ValueError(f"Source path escapes canonical tree in {path}: {source}")
    return data


def write_manifest(path: Path, data: dict[str, Any]) -> None:
    content = (json.dumps(data, indent=2, ensure_ascii=True) + "\n").encode()
    write_bytes(path, content)


def write_bytes(path: Path, content: bytes) -> None:
    if path.is_file() and path.read_bytes() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content)


def owned_path(root: Path, key: str) -> Path:
    path = Path(key).expanduser()
    path = (path if path.is_absolute() else root / path).resolve()
    if not path.is_relative_to(root):
        raise ValueError(f"Ownership path escapes installation scope: {key}")
    return path


def shared_metadata(root: Path, metadata: dict[str, Any]) -> dict[str, Any] | None:
    reference = metadata.get("shared_skills")
    if reference is None:
        return None
    if reference != SHARED_MANIFEST:
        raise ValueError(f"Unsupported shared skill reference: {reference}")
    shared = read_manifest(owned_path(root, SHARED_MANIFEST))
    if shared is None:
        raise ValueError(f"Missing shared ownership manifest: {root / SHARED_MANIFEST}")
    consumers = shared.get("consumers")
    if not isinstance(consumers, list) or not consumers or any(c not in CONSUMERS for c in consumers):
        raise ValueError(f"Malformed shared consumers: {root / SHARED_MANIFEST}")
    for key in shared["files"]:
        if not owned_path(root, key).is_relative_to((root / SKILL_ROOT).resolve()):
            raise ValueError(f"Shared ownership outside skills: {key}")
    return shared


def effective_files(root: Path, metadata: dict[str, Any]) -> dict[str, Any]:
    shared = shared_metadata(root, metadata)
    files = {**metadata["files"], **(shared["files"] if shared else {})}
    for key in files:
        owned_path(root, key)
    return files


def legacy_source(relative: Path, entry: dict[str, Any], repo: Path) -> str | None:
    """Recognize only legacy asset roots; source metadata cannot authorize other paths."""
    parts = relative.parts
    if len(parts) < 3 or parts[0] not in (".codex", ".cursor", ".agents"):
        return None
    if parts[1] == "skills":
        source = "agents/skills/" + Path(*parts[2:]).as_posix()
        if source in ("agents/skills/junior/references/junior-readme.md", "agents/skills/jr/references/junior-readme.md"):
            return "README.md"
        return source
    if parts[:2] != (".cursor", "commands"):
        return None
    if len(parts) == 3 and relative.suffix == ".md":
        return f"agents/skills/{relative.stem}/SKILL.md"
    if parts[2] != "_shared":
        return None
    if parts[3:] == ("junior-readme.md",):
        return "README.md"
    recorded = entry.get("source", "")
    if recorded.startswith("agents/skills/") and ".." not in Path(recorded).parts:
        return recorded
    tail = Path(*parts[3:])
    if tail.parts and (repo / "agents/skills" / tail.parts[0] / "SKILL.md").exists():
        return f"agents/skills/{tail.as_posix()}"
    return f"agents/skills/_shared/{tail.as_posix()}"


def command_body(content: bytes, source: bytes, skill: str, project: bool) -> bytes:
    """Reverse the old command renderer and restore native skill frontmatter."""
    text = content.decode()
    support = ("" if project else "~/") + ".cursor/commands/_shared"
    # Reverse the renderer's later substitutions first: it also rewrote path segments
    # introduced by its first substitution.
    for folder in ("references", "templates"):
        text = text.replace(f"{support}/{skill}/{folder}/", f"{folder}/")
    text = text.replace(f"{support}/", "../_shared/")
    frontmatter = re.match(rb"\A---\r?\n.*?\r?\n---\r?\n+", source, re.DOTALL)
    return (frontmatter[0] if frontmatter else b"") + text.encode()


def render_command(source: bytes, skill: str, project: bool) -> bytes:
    text = re.sub(r"\A---\r?\n.*?\r?\n---\r?\n+", "", source.decode(), count=1, flags=re.DOTALL)
    support = ("" if project else "~/") + ".cursor/commands/_shared"
    text = text.replace("../_shared/", f"{support}/")
    for folder in ("templates", "references"):
        text = re.sub(rf"(?<!_shared/){folder}/", f"{support}/{skill}/{folder}/", text)
    return text.encode()


def rule_dependencies(root: Path, profile: Path | None = None) -> dict[Path, str]:
    """Conservatively inventory installed instructions, configuration, rules, and hooks."""
    paths = {root / name for name in ("AGENTS.md", "AGENTS.override.md", "CLAUDE.md")}
    directories = {root / runtime for runtime in (".codex", ".cursor", ".claude")}
    if profile is not None:
        directories.add(profile)
    for directory in sorted(directories):
        if directory.is_dir():
            # Runtime history, databases, and caches are not active loading inputs and
            # can contain gigabytes of old rule references. Never traverse those trees.
            paths.update(p for p in directory.iterdir() if p.is_file() and p.suffix in
                         (".md", ".mdc", ".toml", ".json", ".jsonc", ".yaml", ".yml") and p.name not in
                         (MANIFEST, "models_cache.json", ".codex-global-state.json", "auth.json", "version.json"))
            for name in ("rules", "hooks"):
                paths.update(p for p in (directory / name).rglob("*") if p.is_file())
    return {p: p.read_bytes().decode("utf-8", errors="replace") for p in sorted(paths) if p.is_file()}


@dataclass
class NativePlan:
    root: Path
    project: bool
    manifests: dict[str, dict[str, Any]]
    shared: dict[str, Any]
    writes: dict[Path, bytes] = field(default_factory=dict)
    modes: dict[Path, int] = field(default_factory=dict)
    removals: set[Path] = field(default_factory=set)
    handled: dict[str, set[str]] = field(default_factory=dict)
    pending: dict[str, list[dict[str, str]]] = field(default_factory=dict)
    runtime_files: dict[str, Any] = field(default_factory=dict)
    codex_capacity: int = 0

    def key(self, path: Path) -> str:
        resolved = path.resolve()
        return resolved.relative_to(self.root).as_posix() if self.project else str(resolved)

    def retain(self, target: str, path: Path, reason: str) -> None:
        self.pending.setdefault(target, []).append({"path": self.key(path), "reason": reason})

    def apply(self) -> None:
        for path, content in self.writes.items():
            write_bytes(path, content)
            path.chmod(self.modes[path])
        # Replacements exist before any predecessor is retired. Never prune runtime roots.
        for path in sorted(self.removals):
            path.unlink()
            parent = path.parent
            while parent.parent != self.root:
                try:
                    parent.rmdir()
                except OSError:
                    break
                parent = parent.parent
        write_manifest(self.root / SHARED_MANIFEST, self.shared)
        for target in self.shared["consumers"]:
            path = self.root / f".{target}" / MANIFEST
            metadata = read_manifest(path) or self.manifests[target]
            old = self.manifests[target]
            retained = {item["path"] for item in self.pending.get(target, [])}
            metadata["files"] = {k: v for k, v in old["files"].items() if k in retained} | {
                k: v for k, v in metadata["files"].items() if k not in self.handled[target]
            }
            metadata["shared_skills"] = SHARED_MANIFEST
            if target == "codex":
                metadata["files"].update(self.runtime_files)
            metadata["scope"] = "project" if self.project else "global"
            metadata["pending_cleanup"] = sorted(self.pending.get(target, []), key=lambda item: item["path"])
            write_manifest(path, metadata)


def plan_install(repo: Path, root: Path, project: bool, targets: list[str], version: dict[str, str]) -> NativePlan:
    available = {t: read_manifest(owned_path(root, f".{t}/{MANIFEST}")) for t in CONSUMERS}
    previous = read_manifest(owned_path(root, SHARED_MANIFEST))
    if previous:
        shared_metadata(root, {"shared_skills": SHARED_MANIFEST})
    consumers = sorted(set(targets).intersection(CONSUMERS) | {t for t, m in available.items() if m} | set((previous or {}).get("consumers", [])))
    manifests = {t: available[t] or {"files": {}} for t in consumers}
    for target in consumers:
        shared_metadata(root, manifests[target])
        manifests[target]["files"] = {
            (owned_path(root, key).relative_to(root).as_posix() if project else str(owned_path(root, key))): entry
            for key, entry in manifests[target]["files"].items()
        }
    plan = NativePlan(root, project, {t: manifests[t] for t in consumers}, {})
    plan.handled = {target: set() for target in CONSUMERS}
    if "codex" in targets:
        codex_rules.prepare(repo, plan)
    candidates: dict[str, list[tuple[Path, bytes]]] = {}
    dependencies = rule_dependencies(root, codex_rules.runtime_home(root, project))
    dependencies.update({p: content.decode() for p, content in plan.writes.items()})
    if plan.codex_capacity:
        # Unchanged predecessors are no longer loading inputs. Their mutual references
        # must not keep the entire retired rule set alive. Operator-owned inputs remain.
        for key, entry in manifests["codex"]["files"].items():
            path = owned_path(root, key)
            if (path.is_relative_to(root / ".codex/rules") and path.is_file()
                    and path.name != "default.rules" and checksum(path.read_bytes()) == entry["sha256"]
                    and not re.match(r"(?:[1-9]\d{2,})-", path.name)):
                dependencies.pop(path, None)
    for target in CONSUMERS:
        metadata = plan.manifests.get(target, {"files": {}})
        owned = set()
        for key, entry in metadata["files"].items():
            path = owned_path(root, key)
            owned.add(path)
            if key in plan.handled[target]:
                continue
            rel = path.relative_to(root)
            source = legacy_source(rel, entry, repo)
            if source is not None:
                plan.handled[target].add(key)
                if not path.is_file():
                    continue
                source_path = repo / source
                if not source_path.is_file():
                    if checksum(path.read_bytes()) == entry["sha256"]:
                        plan.removals.add(path)
                    else:
                        raise ValueError(f"Cannot reconcile legacy asset without source: {path} -> {source}")
                    continue
                authored = source_path.read_bytes()
                content = path.read_bytes()
                expected = authored
                if rel.parts[:2] == (".cursor", "commands") and len(rel.parts) == 3:
                    expected = render_command(authored, rel.stem, project)
                    content = command_body(content, authored, rel.stem, project)
                edited = checksum(path.read_bytes()) != entry["sha256"]
                if edited and content != authored and checksum(expected) != entry["sha256"]:
                    raise ValueError(f"Migration conflict: source and legacy asset both changed: {path} -> {source_path}")
                candidates.setdefault(source, []).append((path, content if edited else authored))
                plan.removals.add(path)
            elif rel.parts[:2] == (".codex", "rules") and path.is_file():
                references = [str(p.relative_to(root)) for p, text in dependencies.items() if p != path and (
                    rel.as_posix() in text or str(path) in text or
                    (re.search(rf"(?<![/\w.-]){re.escape(path.name)}(?![\w.-])", text)
                     and not any(p.is_relative_to(root / other / "rules") for other in (".agents", ".claude", ".cursor"))) or
                    re.search(r"\.codex/rules/?(?=[`'\"\s*]|$)", text) or
                    ((p.name in ("config.toml", "config.json") or p.is_relative_to(root / ".codex/hooks"))
                     and p.is_relative_to(root / ".codex") and re.search(r"\brules\b", text))
                )]
                number = re.match(r"(\d+)-", path.name)
                reason = ("user-authored 100+ rule" if number and int(number[1]) >= 100 else
                          "edited rule requires reconciliation" if checksum(path.read_bytes()) != entry["sha256"] else
                          "referenced by " + ", ".join(references) if references else "")
                if reason:
                    plan.retain(target, path, reason)
                else:
                    plan.removals.add(path)
                    plan.handled[target].add(key)
            elif rel.parts[:2] not in ((".cursor", "rules"), (".agents", "rules")):
                plan.retain(target, path, "preserved instruction or asset outside legacy cleanup")
        for directory in (root / f".{target}/skills", root / f".{target}/rules", root / f".{target}/commands"):
            if directory.is_dir():
                for path in sorted(p for p in directory.rglob("*") if p.is_file()):
                    if path.resolve() not in owned:
                        plan.retain(target, path, "unowned; no ownership evidence")

    source_files = {p.relative_to(repo).as_posix(): p for p in (repo / "agents/skills").rglob("*") if p.is_file()}
    source_files["README.md"] = repo / "README.md"
    files = {}
    old_files = {plan.key(owned_path(root, key)): entry for key, entry in (previous or {}).get("files", {}).items()}
    for source, path in sorted(source_files.items()):
        skill_rel = "jr/references/junior-readme.md" if source == "README.md" else source.removeprefix("agents/skills/")
        dest = owned_path(root, f"{SKILL_ROOT}/{skill_rel}")
        key = plan.key(dest)
        authored = path.read_bytes()
        variants = {content for _, content in candidates.get(source, []) if content != authored}
        old = old_files.get(key)
        if dest.exists():
            installed = dest.read_bytes()
            if installed != authored:
                if old is None:
                    raise ValueError(f"Migration conflict: unowned destination {dest}")
                if checksum(installed) != old["sha256"]:
                    if checksum(authored) != old["sha256"]:
                        raise ValueError(f"Migration conflict: source and shared asset both changed: {dest} -> {path}")
                    variants.add(installed)
        if len(variants) > 1:
            paths = [str(p) for p, _ in candidates.get(source, [])] + [str(dest)]
            raise ValueError("Migration conflict: differing edits: " + ", ".join(paths))
        content = next(iter(variants), authored)
        if dest in plan.writes and plan.writes[dest] != content:
            raise ValueError(f"Conflicting physical destination: {dest}")
        plan.writes[dest] = content
        plan.modes[dest] = path.stat().st_mode & 0o777
        files[key] = {"sha256": old["sha256"] if old and content != authored else checksum(authored),
                      "size": len(authored), "modified": content != authored, "source": source}
    for key, entry in old_files.items():
        if key in files:
            continue
        path = owned_path(root, key)
        if path.is_file():
            if checksum(path.read_bytes()) == entry["sha256"]:
                plan.removals.add(path)
            else:
                files[key] = entry
                for target in consumers:
                    plan.retain(target, path, "edited obsolete shared asset requires reconciliation")
    # Physical aliases are one destination and must never be removed after installation.
    plan.removals.difference_update(plan.writes)
    plan.shared = {**version, "scope": "project" if project else "global", "consumers": consumers, "files": files}
    plan.shared["pending_cleanup"] = [item for target, items in plan.pending.items() if target not in consumers for item in items]
    return plan
