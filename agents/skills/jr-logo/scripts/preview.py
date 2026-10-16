#!/usr/bin/env python3
"""Render logo concepts listed in <brand-dir>/concepts.json as a live preview page and per-theme GIFs.

preview.html shows every mark large, beside the product title and at favicon size, in every theme.
With --gif, each theme also gets preview-<theme>.gif: one seamless loop captured with headless Chrome
(requires Pillow, for example `uv run --no-project --with pillow python preview.py <dir> --gif`).
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True

CHROME_CANDIDATES = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    "google-chrome", "google-chrome-stable", "chromium", "chromium-browser", "microsoft-edge", "msedge", "chrome",
]
FIGURE_PX, GAP_PX, PAD_PX, PROBE_HEIGHT = 140, 26, 30, 2400

CSS = """body{{margin:0;font-family:-apple-system,"Segoe UI",Helvetica,sans-serif}}
section{{padding:4px {pad}px 20px}}h2{{font-size:12px;text-transform:uppercase;letter-spacing:.08em;opacity:.6;margin:14px 0 8px}}
.row{{display:flex;gap:{gap}px}}figure{{margin:0;width:{fig}px;display:flex;flex-direction:column;align-items:center;gap:10px}}
figcaption{{font-size:13px;font-weight:600}}.big{{width:96px;height:96px}}
.lockup{{display:flex;align-items:center;gap:6px;font-size:20px;font-weight:700;letter-spacing:-.02em}}.lockup svg{{width:32px;height:32px}}
.tiny{{display:flex;align-items:center;gap:8px;font-size:11px;opacity:.7}}.tiny svg{{width:16px;height:16px}}
{themes}"""

FREEZE = """const t=parseFloat(new URLSearchParams(location.search).get('t'));
if(!isNaN(t)){document.getAnimations().forEach(a=>{a.pause();a.currentTime=t*1000});}"""


def load_config(brand: Path) -> dict:
    config = json.loads((brand / "concepts.json").read_text())
    for group in config["groups"]:
        for mark in group["marks"]:
            if not (brand / mark["file"]).is_file():
                raise SystemExit(f"concepts.json lists a missing mark: {mark['file']}")
    return config


def theme_css(themes: dict) -> str:
    return "".join(
        f".{name}{{background:{t['background']};color:{t['text']}}}.{name} .lockup{{color:{t['title']}}}"
        for name, t in themes.items()
    )


def svg(brand: Path, name: str, cls: str = "") -> str:
    source = (brand / name).read_text()
    if "<svg " not in source:
        raise SystemExit(f"{name} has no <svg> root element")
    return source.replace("<svg ", f'<svg class="{cls}" ', 1)


def figure(brand: Path, product: str, mark: dict) -> str:
    return (
        f'<figure>{svg(brand, mark["file"], "big")}<figcaption>{mark["label"]}</figcaption>'
        f'<div class="lockup">{svg(brand, mark["file"])}<span>{product}</span></div>'
        f'<div class="tiny">{svg(brand, mark["file"])}<span>16px</span></div></figure>'
    )


def section(brand: Path, config: dict, theme: str) -> str:
    groups = "".join(
        f'<h2>{group["title"]}</h2><div class="row">'
        f'{"".join(figure(brand, config["product"], m) for m in group["marks"])}</div>'
        for group in config["groups"]
    )
    return f'<section class="{theme}">{groups}</section>'


def write_page(brand: Path, config: dict, name: str, themes: list[str]) -> Path:
    css = CSS.format(pad=PAD_PX, gap=GAP_PX, fig=FIGURE_PX, themes=theme_css(config["themes"]))
    body_class = themes[0] if len(themes) == 1 else ""
    page = brand / f"{name}.html"
    page.write_text(
        f'<!doctype html><html><head><meta charset="utf-8"><title>{config["product"]} logo concepts</title>'
        f'<style>{css}</style></head><body class="{body_class}">'
        f'{"".join(section(brand, config, t) for t in themes)}<script>{FREEZE}</script></body></html>'
    )
    return page


def find_chrome(explicit: str | None) -> str:
    for candidate in [explicit, os.environ.get("CHROME"), *CHROME_CANDIDATES]:
        if candidate and (Path(candidate).is_file() or shutil.which(candidate)):
            return shutil.which(candidate) or candidate
    raise SystemExit("No Chrome, Chromium or Edge found; pass --chrome PATH or set CHROME")


def capture(chrome: str, page: Path, t: float, size: tuple[int, int], out: Path) -> None:
    out.unlink(missing_ok=True)
    result = subprocess.run(
        [chrome, "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--window-size={size[0]},{size[1]}",
         f"--screenshot={out}", f"{page.resolve().as_uri()}?t={t:.4f}"],
        capture_output=True, text=True,
    )
    # Chrome on macOS can exit non-zero from a teardown watchdog after the screenshot is already written.
    if not out.is_file() or out.stat().st_size == 0:
        raise SystemExit(f"Chrome exited {result.returncode} capturing t={t:.2f}s:\n{result.stderr[-2000:]}")


def content_height(image, background: str) -> int:
    """Last row that differs from the page background, plus a small margin."""
    from PIL import ImageChops, Image

    bg = Image.new("RGB", image.size, background)
    box = ImageChops.difference(image.convert("RGB"), bg).getbbox()
    if box is None:
        raise SystemExit("Captured frame is blank; the page did not render")
    return min(image.height, box[3] + 20)


def build_gif(chrome: str, page: Path, config: dict, theme: str) -> Path:
    from PIL import Image

    columns = max(len(g["marks"]) for g in config["groups"])
    width = 2 * PAD_PX + columns * FIGURE_PX + (columns - 1) * GAP_PX
    loop_s, fps = config.get("loop_seconds", 4), config.get("fps", 12.5)
    frames_dir = page.parent / "frames" / page.stem
    frames_dir.mkdir(parents=True, exist_ok=True)

    probe = frames_dir / "probe.png"
    capture(chrome, page, 0, (width, PROBE_HEIGHT), probe)
    size = (width, content_height(Image.open(probe), config["themes"][theme]["background"]))
    probe.unlink()

    paths = [frames_dir / f"{i:03d}.png" for i in range(round(loop_s * fps))]
    for i, out in enumerate(paths):
        capture(chrome, page, i / fps, size, out)
    images = [Image.open(p).convert("RGB") for p in paths]
    gif = page.with_suffix(".gif")
    images[0].save(gif, save_all=True, append_images=images[1:], duration=round(1000 / fps), loop=0)
    return gif


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("brand_dir", type=Path, help="directory holding concepts.json and the mark SVGs")
    parser.add_argument("--gif", action="store_true", help="also write preview-<theme>.gif for every theme")
    parser.add_argument("--chrome", help="path to Chrome, Chromium or Edge")
    args = parser.parse_args()

    brand = args.brand_dir.resolve()
    config = load_config(brand)
    themes = list(config["themes"])
    print(write_page(brand, config, "preview", themes))
    if args.gif:
        chrome = find_chrome(args.chrome)
        for theme in themes:
            print(build_gif(chrome, write_page(brand, config, f"preview-{theme}", [theme]), config, theme))


if __name__ == "__main__":
    main()
