"""Resolve tagged Junior releases and bootstrap an explicitly chosen installation."""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path

REPOSITORY = "rusi/junior"
TARGETS = ("claude", "cursor", "codex")


def normalize_install_target(value: str) -> str:
    normalized = value.strip().lower()
    if normalized in ("gemini",):
        raise ValueError(
            f"Target '{normalized}' is no longer supported. "
            f"Supported targets: {', '.join(TARGETS)}. "
            f"An existing ~/.{normalized} installation is left untouched."
        )
    if normalized not in TARGETS:
        raise ValueError(
            f"Invalid target '{value}'. Supported targets: {', '.join(TARGETS)}"
        )
    return normalized


def parse_install_targets(value: str) -> list[str]:
    raw = value.strip().lower()
    if raw == "all":
        return list(TARGETS)

    targets: list[str] = []
    for chunk in raw.split(","):
        target = normalize_install_target(chunk)
        if target not in targets:
            targets.append(target)
    return targets


@dataclass(frozen=True)
class Release:
    name: str
    sha: str
    date: str

    @property
    def tarball_url(self) -> str:
        return f"https://github.com/{REPOSITORY}/archive/{self.sha}.tar.gz"


def api_json(path: str):
    request = urllib.request.Request(f"https://api.github.com/repos/{REPOSITORY}/{path}",
                                     headers={"Accept": "application/vnd.github+json", "User-Agent": "junior-installer"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def release_tags() -> list[dict]:
    tags, page = [], 1
    while True:
        batch = api_json(f"tags?per_page=100&page={page}")
        tags.extend(tag for tag in batch if re.fullmatch(r"v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", tag["name"]))
        if len(batch) < 100:
            break
        page += 1
    return sorted(tags, key=lambda tag: tuple(map(int, tag["name"].removeprefix("v").split("."))), reverse=True)


def select_release(version: str = "latest", tags: list[dict] | None = None) -> Release:
    if version == "main":
        name, ref = "main", "heads/main"
    else:
        tags = release_tags() if tags is None else tags
        if not tags:
            raise ValueError("No stable tagged releases found. Use --development to select main explicitly.")
        tag = tags[0] if version == "latest" else next(
            (tag for tag in tags if tag["name"].removeprefix("v") == version.removeprefix("v")), None)
        if tag is None:
            raise ValueError(f"Unknown release {version!r}. Use --list-versions to see available releases.")
        name, ref = tag["name"], tag["commit"]["sha"]
    commit = api_json(f"commits/{urllib.parse.quote(ref, safe='')}")
    if not re.fullmatch(r"[0-9a-f]{40}", commit["sha"]):
        raise ValueError("GitHub did not return a valid release commit.")
    return Release(name, commit["sha"], commit["commit"]["committer"]["date"])


def install_location(destination: str = "", scope: str = "", project_root: str = "") -> tuple[str, Path]:
    if destination and project_root and Path(destination).expanduser().resolve() != Path(project_root).expanduser().resolve():
        raise ValueError("Specify one installation destination.")
    path = destination or project_root
    scope = scope or ("project" if path else "global")
    if scope not in ("global", "project"):
        raise ValueError("Scope must be global or project.")
    if scope == "global":
        if destination:
            raise ValueError("A global install cannot also name a project destination.")
        return scope, Path.home().resolve()
    root = Path(path or Path.cwd()).expanduser().resolve()
    if not root.is_dir():
        raise ValueError(f"Project directory does not exist: {root}")
    return scope, root


def prompt(message: str) -> str:
    if sys.stdin.isatty():
        return input(message).strip()
    try:
        with open("CONIN$" if os.name == "nt" else "/dev/tty", encoding="utf-8") as terminal:
            print(message, end="", flush=True)
            return terminal.readline().strip()
    except OSError as error:
        raise ValueError("No interactive terminal. Supply --target and --yes for unattended installation.") from error


def show_installed(root: Path, targets: list[str]) -> None:
    for target in targets:
        manifest = root / f".{target}/.junior-install.json"
        if manifest.is_file():
            metadata = json.loads(manifest.read_text())
            print(f"Installed {target}: {metadata.get('release') or metadata.get('commit_hash', 'unknown')}")


def choose_version(tags: list[dict]) -> str:
    choices = [tag["name"] for tag in tags]
    if not choices:
        raise ValueError("No stable tagged releases found.")
    latest = select_release(choices[0], tags)
    development = select_release("main")
    comparison = api_json(f"compare/{latest.sha}...{development.sha}")
    for number, name in enumerate(choices, 1):
        print(f"  {number}. {name}" + (" (latest release)" if number == 1 else ""))
    if comparison["status"] == "ahead":
        choices.append("main")
        print(f"  {len(choices)}. main (development, {comparison['ahead_by']} commits after {latest.name})")
    answer = prompt("Version [1]: ") or "1"
    if not answer.isdecimal() or not 1 <= int(answer) <= len(choices):
        raise ValueError("Choose a listed version number.")
    return choices[int(answer) - 1]


def download_release(release: Release, directory: Path) -> Path:
    archive = directory / "junior.tar.gz"
    with urllib.request.urlopen(release.tarball_url, timeout=60) as response:
        archive.write_bytes(response.read())
    unpacked = directory / "source"
    with tarfile.open(archive, "r:gz") as stream:
        members = stream.getmembers()
        for member in members:
            target = (unpacked / member.name).resolve()
            if not target.is_relative_to(unpacked.resolve()) or not (member.isdir() or member.isfile()):
                raise ValueError(f"Unsafe release archive entry: {member.name}")
        for member in members:
            target = unpacked / member.name
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with stream.extractfile(member) as source:
                    target.write_bytes(source.read())
                target.chmod(member.mode & 0o777)
    roots = list(unpacked.iterdir())
    if len(roots) != 1 or not (roots[0] / "scripts/junior.py").is_file():
        raise ValueError("Release archive has no unique Junior installer.")
    root = roots[0]
    timestamp = int(dt.datetime.fromisoformat(release.date.replace("Z", "+00:00")).timestamp())
    (root / ".githash").write_text(f"COMMIT_HASH={release.sha}\nCOMMIT_DATE={release.date}\nCOMMIT_TIMESTAMP={timestamp}\nRELEASE={release.name}\n")
    return root


def add_version_arguments(parser: argparse.ArgumentParser) -> None:
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--version", default="latest", help="Tagged release to install (default: latest)")
    group.add_argument("--development", action="store_const", const="main", dest="version", help="Use the latest main commit")
    group.add_argument("--choose-version", action="store_true", help="Choose from tagged releases and newer development code")
    group.add_argument("--list-versions", action="store_true", help="List stable releases without installing")


def installer_command(source: Path, targets: list[str], scope: str, destination: Path) -> list[str]:
    command = [sys.executable, str(source / "scripts/junior.py"), "install"]
    help_result = subprocess.run([*command, "--help"], capture_output=True, text=True, check=True)
    if "--yes" not in help_result.stdout or "--project-root" not in help_result.stdout:
        raise ValueError("This release predates safe consent and project installs. Choose Junior 2.0.0 or newer.")
    command.extend(("--target", ",".join(targets), "--scope", scope, "--yes"))
    if scope == "project":
        command.extend(("--project-root", str(destination)))
    return command


def requested_release(args: argparse.Namespace) -> Release | None:
    if args.list_versions or args.choose_version:
        tags = release_tags()
        if args.list_versions:
            print("\n".join(tag["name"] for tag in tags) or "No stable tagged releases.")
            return None
        return select_release(choose_version(tags), tags)
    return select_release(args.version)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Install Junior's latest tagged release globally or into a project.")
    parser.add_argument("destination", nargs="?", default="", help="Project directory; omit for a global install")
    parser.add_argument("--target", "-t", default="", help="claude, cursor, codex, all, or a comma-separated list")
    parser.add_argument("--scope", default="", help=argparse.SUPPRESS)
    parser.add_argument("--project-root", default="", help=argparse.SUPPRESS)
    parser.add_argument("--yes", "-y", action="store_true", help="Confirm installation without prompting")
    add_version_arguments(parser)
    args = parser.parse_args(argv)
    try:
        scope, destination = install_location(args.destination, args.scope, args.project_root)
        if args.list_versions:
            requested_release(args)
            return 0
        target = args.target or prompt("Install for [claude/cursor/codex/all]: ").lower()
        targets = parse_install_targets(target)
        show_installed(destination, targets)
        release = requested_release(args)
        print(f"Install Junior {release.name} ({release.sha[:7]}) for {', '.join(targets)}")
        print(f"Destination: {destination} ({scope})")
        if not args.yes and prompt("Continue? [y/N]: ").lower() not in ("y", "yes"):
            print("Installation cancelled.")
            return 0
        with tempfile.TemporaryDirectory(prefix="junior-bootstrap-") as temporary:
            source = download_release(release, Path(temporary))
            command = installer_command(source, targets, scope, destination)
            return subprocess.run(command, check=False).returncode
    except (OSError, ValueError, KeyError, tarfile.TarError, subprocess.CalledProcessError) as error:
        print(f"Installation failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
