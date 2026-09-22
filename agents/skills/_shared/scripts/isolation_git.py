"""Read Git candidate bytes without changing the index, worktree, or history."""

from __future__ import annotations

import os
import subprocess
from pathlib import Path


class Repository:
    def __init__(self, path: Path):
        self.path = path
        self.path = Path(self.git("rev-parse", "--show-toplevel").decode().strip())

    def git(self, *args: str) -> bytes:
        result = subprocess.run(["git", "--no-optional-locks", "-C", str(self.path), *args], capture_output=True)
        if result.returncode:
            detail = result.stderr.decode(errors="replace").strip()
            raise ValueError(detail or f"Git {' '.join(args)} failed (exit {result.returncode})")
        return result.stdout

    def revision(self, ref: str) -> str:
        return self.git("rev-parse", "--verify", "--end-of-options", ref + "^{commit}").decode().strip()

    def message(self, revision: str) -> bytes:
        return self.git("cat-file", "commit", revision).split(b"\n\n", 1)[1]

    def entries(self, ref: str | None = None) -> dict[str, tuple[str, str]]:
        records = self.git("ls-tree", "-rz", ref) if ref else self.git("ls-files", "--stage", "-z")
        entries = {}
        for record in records.split(b"\0"):
            if not record:
                continue
            header, name = record.split(b"\t", 1)
            fields = header.decode().split()
            mode, oid = (fields[0], fields[2]) if ref else fields[:2]
            if not ref and fields[2] != "0":
                raise ValueError("Resolve the unmerged index before validation")
            entries[os.fsdecode(name)] = mode, oid
        return entries

    def files(self, source: str, ref: str | None = None) -> dict[str, bytes]:
        entries = self.entries(ref)
        if source == "worktree":
            for path in self.git("ls-files", "--others", "--exclude-standard", "-z").split(b"\0"):
                if path:
                    entries[os.fsdecode(path)] = "worktree", ""
        files = {}
        for path, (mode, oid) in entries.items():
            if mode == "160000":
                raise ValueError(f"{path}: submodule content requires a separate repository check")
            if source == "worktree":
                file = self.path / path
                if not file.parent.resolve().is_relative_to(self.path):
                    raise ValueError(f"{path}: parent symlink leaves repository")
                if file.is_symlink():
                    files[path] = os.fsencode(os.readlink(file))
                elif file.exists():
                    files[path] = file.read_bytes()
            else:
                files[path] = self.git("cat-file", "blob", oid)
        return files

    def changed(self, revision: str | None = None) -> list[str]:
        args = ("diff-tree", "--root", "-m", "--no-commit-id", "-r", revision) if revision else ("diff", "--cached")
        return sorted({os.fsdecode(p) for p in self.git(*args, "--name-only", "--no-renames", "-z").split(b"\0") if p})

    def commits(self, base: str, head: str) -> list[str]:
        self.git("merge-base", "--is-ancestor", base, head)
        return self.git("rev-list", "--reverse", f"{base}..{head}").decode().splitlines()
