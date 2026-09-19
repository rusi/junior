"""Render canonical rules into Codex's supported instruction chain before legacy cleanup."""
from __future__ import annotations

import hashlib
import os
import re
from pathlib import Path
from typing import TYPE_CHECKING

import managed_region

try:
    import tomllib
except ModuleNotFoundError:  # Older Python can still install the other runtimes.
    tomllib = None  # type: ignore[assignment]

if TYPE_CHECKING:
    from native_skills import NativePlan

MARKER = "<!-- junior:session-rules -->"

# Codex's core rule order. Its subject-specific rules are referenced separately by the
# installer; Claude discovers all installed Markdown through its native loader.
MANDATORY_RULES = (
    "00-junior.md",
    "01-structure.md",
    "02-current-date.md",
    "03-style-guide.md",
    "05-dry-principles.md",
    "06-expert-judgement.md",
    "13-software-implementation-principles.md",
    "07-understand-before-acting.md",
    "08-destructive-operations.md",
    "10-waiting-on-work.md",
    "09-code-or-skill.md",
)

PREAMBLE = (
    "The following Junior rules are loaded and authoritative for this session. "
    "They are already in context: do not read them from disk again."
)


def assemble_context(loaded: list[tuple[str, str]]) -> str:
    """Render the complete core rule bodies already validated by the Codex installer."""
    sections = [MARKER, "# Junior Rules", "", PREAMBLE, ""]
    for name, body in loaded:
        # Rules carry headings of their own, so each file is fenced off by a rule line and
        # named on the way in. Without that, one rule's sections read as the next one's.
        sections.extend(["---", "", f"# Rule: {name}", "", body.strip(), ""])
    return "\n".join(sections)


RULE_ROOT = ".agents/rules"
END_MARKER = "<!-- junior:session-rules:end -->"
HEADROOM = 65536


def runtime_home(root: Path, project: bool) -> Path:
    """Select the active global Codex profile; project configuration stays local."""
    configured = os.environ.get("CODEX_HOME", "") if not project else ""
    return Path(configured).expanduser().resolve() if configured else root / ".codex"


def capacity_config(document: str, required: int) -> str:
    """Change only the root capacity setting; preserve comments and all other TOML."""
    if tomllib is None:
        raise ValueError("Codex rule installation requires Python 3.11 or newer (TOML support)")
    parsed = tomllib.loads(document)
    value = parsed.get("project_doc_max_bytes", 32768)
    if type(value) is not int or value < 0:
        raise ValueError("Codex project_doc_max_bytes must be a nonnegative integer")
    if value >= required:
        return document
    desired = {**parsed, "project_doc_max_bytes": required}
    if "project_doc_max_bytes" in parsed:
        updated = re.sub(
            r"(?m)^([ \t]*(?:project_doc_max_bytes|\"project_doc_max_bytes\"|'project_doc_max_bytes')[ \t]*=[ \t]*)[^#\r\n]+",
            lambda match: f"{match[1]}{required} ", document, count=1,
        )
    else:
        updated = f"project_doc_max_bytes = {required}\n" + document
    if tomllib.loads(updated) != desired:
        raise ValueError("Cannot safely update Codex document capacity; configuration left unchanged")
    return updated


def prepare(repo: Path, plan: NativePlan) -> None:
    """Add rule copies and native loading surfaces to the shared preflight transaction."""
    prefix = RULE_ROOT if plan.project else f"~/{RULE_ROOT}"
    loaded = [(f"{prefix}/{name}", (repo / "agents/rules" / name).read_text(encoding="utf-8"))
              for name in MANDATORY_RULES]
    context = assemble_context(loaded)
    conditional = ("04-meta-rules.md", "11-python-conventions.md",
                   "12-software-architecture-document-guide.md", "architecture-document-template.md")
    for name in conditional:
        (repo / "agents/rules" / name).read_text(encoding="utf-8")
    body = (context + "\n## Conditional rules\n\n"
            "Read these only when their subject applies:\n"
            + "\n".join(f"- `{prefix}/{name}`" for name in conditional)
            + f"\n\n{END_MARKER}\n")
    old = plan.manifests["codex"]["files"]

    def path_for(relative: str, root: Path = plan.root) -> Path:
        path = (root / relative).resolve()
        if not path.is_relative_to(root):
            raise ValueError(f"Codex destination escapes installation scope: {relative}")
        return path

    def stage(path: Path, content: bytes) -> None:
        if path in plan.writes and plan.writes[path] != content:
            raise ValueError(f"Conflicting physical Codex destination: {path}")
        plan.writes[path] = content
        plan.modes[path] = path.stat().st_mode & 0o777 if path.exists() else 0o644

    for source in sorted((repo / "agents/rules").glob("*.md")):
        dest = path_for(f"{RULE_ROOT}/{source.name}")
        content = source.read_bytes()
        entry = old.get(plan.key(dest))
        if (dest.exists() and dest.read_bytes() != content
                and (not entry or loader_checksum(dest.read_bytes()) != entry["sha256"])):
            raise ValueError(f"Codex rule conflict; reconcile edited or unowned destination: {dest}")
        stage(dest, content)
        plan.runtime_files[plan.key(dest)] = {"source": source.relative_to(repo).as_posix(),
                                            "sha256": loader_checksum(content), "size": len(content), "modified": False}
        plan.handled["codex"].add(plan.key(dest))

    for key, entry in old.items():
        path = Path(key) if Path(key).is_absolute() else plan.root / key
        if path.is_relative_to(plan.root / RULE_ROOT) and key not in plan.runtime_files:
            plan.handled["codex"].add(key)
            if path.is_file():
                if loader_checksum(path.read_bytes()) == entry["sha256"]:
                    plan.removals.add(path)
                else:
                    plan.retain("codex", path, "edited obsolete rule requires reconciliation")

    # The active override must receive the block too; installing only AGENTS.md would
    # leave Junior hidden. Both documents preserve everything outside the managed block.
    profile = runtime_home(plan.root, plan.project)
    instruction_root = plan.root if plan.project else profile
    documents = [path_for("AGENTS.md", instruction_root)]
    override = path_for("AGENTS.override.md", instruction_root)
    if override.is_file() and override.read_text(encoding="utf-8").strip():
        documents.append(override)
    legacy = path_for(".codex/AGENTS.md")
    if plan.project and legacy.is_file() and plan.key(legacy) in old:
        entry = old[plan.key(legacy)]
        if loader_checksum(legacy.read_bytes()) == entry["sha256"]:
            stage(legacy, b"<!-- Junior instructions moved to the project AGENTS.md. -->\n")
            plan.handled["codex"].add(plan.key(legacy))
    for path in documents:
        document = path.read_text(encoding="utf-8") if path.exists() else ""
        entry = old.get(plan.key(path))
        if entry and loader_checksum(document.encode()) == entry["sha256"]:
            document = ""  # Proven unchanged old Junior contract; replace its obsolete preflight.
        try:
            updated = managed_region.upsert_markdown_block(document, body)
        except managed_region.ManagedRegionError as exc:
            raise ValueError(f"{path}: {exc}") from exc
        stage(path, updated.encode())
        plan.handled["codex"].add(plan.key(path))

    # Allow another complete Junior bundle plus ordinary project guidance. A project
    # install stays within the project and uses Codex's trusted project config layer.
    required = 2 * max(len(plan.writes[p]) for p in documents) + HEADROOM
    config = path_for("config.toml", profile)
    document = config.read_text(encoding="utf-8") if config.exists() else ""
    stage(config, capacity_config(document, required).encode())
    plan.codex_capacity = tomllib.loads(plan.writes[config].decode())["project_doc_max_bytes"]


def loader_checksum(content: bytes) -> str:
    """The same checksum used by the installation ownership manifest."""
    # Kept independent of NativePlan to avoid a circular module import.
    return hashlib.sha256(content).hexdigest()
