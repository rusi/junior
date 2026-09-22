"""Literal findings and exact, content-bound review decisions."""

from __future__ import annotations

import hashlib
import re
from pathlib import PurePosixPath

PATTERNS = {
    "private-path": re.compile(r"\.(?:junior|code-captain)(?:\b|[/\\])|(?:~|/Users/[^/\s]+|/home/[^/\s]+)/\.(?:agents|claude|codex|cursor)(?:/|\b)", re.I),
    "metadata": re.compile(r"\.junior-[\w.-]+|junior[_-](?:capture|owner|provenance|story|task)", re.I),
    "tracking": re.compile(r"\b(?:feat|imp|dbg|exp|comp|enh|bug)-\d+(?:-[\w.-]+)?|\b(?:story|task)[ _-]+\d+(?:[.-]\d+)*", re.I),
    "command": re.compile(r"(?:/|\$)jr(?:-[a-z][a-z-]*)?\b", re.I),
    "junior": re.compile(r"\bjunior\b", re.I),
}
RUNTIME_PATH = re.compile(
    r"(?:AGENTS(?:\.override)?\.md|CLAUDE\.md|"
    r"\.(?:agents|claude|codex|cursor)/(?:"
    r"(?:rules|skills|hooks|commands)/.+|(?:settings(?:\.local)?\.json|config\.toml|junior-contract\.md|\.junior-install\.json)))$"
)
MIXED_DOCUMENTS = {"AGENTS.md", "AGENTS.override.md", "CLAUDE.md"}


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def tracking(path: str) -> bool:
    return path.split("/", 1)[0] in {".junior", ".code-captain"}


def validate_review(review: dict) -> None:
    """Reject broad or unsupported waivers; semantic justification remains a reader's job."""
    if not isinstance(review, dict) or set(review) - {"runtime", "product", "literal"}:
        raise ValueError("Review must contain only runtime, product, and literal lists")
    for kind, entries in review.items():
        if not isinstance(entries, list):
            raise ValueError(f"Review {kind} must be a list")
        for entry in entries:
            fields = {"path", "sha256", "reason"} | ({"start", "end"} if kind == "runtime" else {"line", "rule"})
            if kind == "literal":
                fields.add("independent")
            if not isinstance(entry, dict) or set(entry) != fields:
                raise ValueError(f"Review {kind} requires exactly {sorted(fields)}")
            path = entry["path"]
            if not isinstance(path, str) or not path or PurePosixPath(path).is_absolute() or any(c in path for c in "*?[]\\") or ".." in path.split("/"):
                raise ValueError("Review paths must be exact repository-relative paths")
            if not isinstance(entry["sha256"], str) or not re.fullmatch(r"[0-9a-f]{64}", entry["sha256"]) or not isinstance(entry["reason"], str) or not entry["reason"].strip():
                raise ValueError("Review requires a SHA-256 digest and a concrete reason")
            if kind == "runtime":
                if not RUNTIME_PATH.fullmatch(path) or not all(type(entry[k]) is int for k in ("start", "end")) or not 1 <= entry["start"] <= entry["end"]:
                    raise ValueError("Runtime review requires a supported exact surface and positive line range")
            else:
                allowed = tuple(PATTERNS) if kind == "literal" else ("junior", "command")
                if entry["rule"] not in allowed or type(entry["line"]) is not int or entry["line"] < 0:
                    raise ValueError(f"{kind} review requires a supported rule and exact line (0 for path)")
                if kind == "literal" and entry["independent"] is not True:
                    raise ValueError("Literal review must affirm independence from private working material")


def scan(path: str, data: bytes, review: dict) -> tuple[list[dict], list[dict], bool]:
    """Scan filenames and bytes; return findings, applied reviews, and binary-review need."""
    if tracking(path):
        return [], [], False
    content_hash = digest(data)
    text = data.decode("utf-8", errors="replace")
    binary = b"\x00" in data or "\ufffd" in text
    if data.startswith((b"\xff\xfe", b"\xfe\xff")):
        text = data.decode("utf-16", errors="replace")
    lines = text.splitlines()
    matching = {kind: [e for e in entries if e["path"] == path and e["sha256"] == content_hash]
                for kind, entries in review.items()}
    runtime = matching.get("runtime", [])
    product = matching.get("product", []) + matching.get("literal", [])
    findings, applied = [], []
    for entry in runtime:
        if entry["end"] > len(lines):
            raise ValueError(f"{path}: runtime range must exist")
    if path in MIXED_DOCUMENTS and runtime and all(any(e["start"] <= n <= e["end"] for e in runtime) for n in range(1, len(lines) + 1)):
        raise ValueError(f"{path}: mixed contributor documents cannot be wholly exempted")
    if any(e["path"] == path for e in review.get("runtime", [])) and not runtime:
        findings.append({"path": path, "line": 0, "rule": "review", "detail": "Runtime review is stale; inspect current bytes"})
    whole_runtime = path not in MIXED_DOCUMENTS and any(e["start"] == 1 and e["end"] == len(lines) for e in runtime)
    for number, line in enumerate([path, *lines]):
        exemptions = [e for e in runtime if (number == 0 and whole_runtime) or e["start"] <= number <= e["end"]]
        if exemptions:
            applied.extend(e for e in exemptions if e not in applied)
            continue
        for rule, pattern in PATTERNS.items():
            match = pattern.search(line)
            if not match:
                continue
            exception = next((e for e in product if e["line"] == number and e["rule"] == rule), None)
            if exception:
                applied.append(exception)
            else:
                findings.append({"path": path, "line": number, "rule": rule, "detail": match.group(), "sha256": content_hash})
    return findings, applied, binary


def group_findings(paths: list[str], message: bytes, review: dict) -> list[dict]:
    groups = {"tracking" if tracking(path) else "product/runtime" for path in paths}
    findings = []
    if len(groups) > 1:
        findings.append({"path": "@commit", "line": 0, "rule": "mixed-group", "detail": "Separate every product/runtime file from .junior/ working material"})
    if groups != {"tracking"}:
        findings.extend(scan("@message", message, review)[0])
    return findings
