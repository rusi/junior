#!/usr/bin/env python3
"""Exclusively save UTF-8 feedback and verify the complete bytes before success."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


class DeliveryError(Exception):
    """A failed delivery, including any file created before the failure."""

    def __init__(self, message: str, path: str | None = None):
        super().__init__(message)
        self.path = path


def write_feedback(directory: Path, subject: str, content: bytes) -> dict:
    """Create a distinct proposal without modifying existing files."""
    created: str | None = None
    try:
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", subject) or len(subject) > 80:
            raise ValueError("Subject must be a lowercase ASCII slug of at most 80 characters")
        if not content:
            raise ValueError("Feedback content is empty")
        content.decode("utf-8")
        directory = directory.expanduser().resolve()
        directory.mkdir(parents=True, exist_ok=True)
        number = 1
        while True:
            suffix = "" if number == 1 else f"-{number}"
            path = directory / f"feedback-{subject}{suffix}.md"
            try:
                stream = path.open("xb")
            except FileExistsError:
                number += 1
                continue
            created = str(path)
            with stream:
                if stream.write(content) != len(content):
                    raise OSError("Incomplete feedback write")
            if path.read_bytes() != content:
                raise OSError("Feedback readback differs from the prepared bytes")
            return {"ok": True, "path": created, "bytes": len(content)}
    except (OSError, ValueError) as error:
        raise DeliveryError(str(error), created) from error


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, required=True)
    parser.add_argument("--subject", required=True)
    args = parser.parse_args()
    try:
        result = write_feedback(args.directory, args.subject, sys.stdin.buffer.read())
    except (DeliveryError, OSError) as error:
        path = error.path if isinstance(error, DeliveryError) else None
        print(json.dumps({"ok": False, "error": str(error), "path": path}))
        return 1
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
