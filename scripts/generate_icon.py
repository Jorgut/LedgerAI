#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""HENG / 衡记 · App icon generator (Pillow + numpy).

Flat market-green field, no stars, no streaks, no glyph shadow. The oracle-bone
"衡" glyph is pre-cleaned and slightly boldened in assets/brand/heng_glyph_bold.png
so it survives 20–60 px.

Usage (repo root):
    python3 scripts/generate_icon.py

Outputs:
1. assets/app_icon_1024.png
2. every size listed in ios/.../AppIcon.appiconset/Contents.json
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
MASTER_PATH = ROOT / "assets" / "app_icon_1024.png"
ICONSET_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS_PATH = ICONSET_DIR / "Contents.json"
GLYPH_PATH = ROOT / "assets" / "brand" / "heng_glyph_bold.png"

CANVAS = 1024
SUPERSAMPLE = 2
S = CANVAS * SUPERSAMPLE
GLYPH_HEIGHT_RATIO = 0.605
INK = (244, 241, 230)  # warm cream

# Rising-market green: vivid jade at the light end, deep pine at the dark end.
BG_TOP = (18, 185, 110)     # #12B96E
BG_BOTTOM = (4, 92, 67)     # #045C43
GLOW = (88, 224, 162)       # #58E0A2


def background(size: int) -> Image.Image:
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = np.clip((x / (size - 1)) * 0.58 + (y / (size - 1)) * 0.42, 0, 1)[..., None]
    a = np.array(BG_TOP, np.float32)
    b = np.array(BG_BOTTOM, np.float32)
    rgb = a * (1 - t) + b * t

    # One very soft top-left highlight; no bands, no star texture.
    nx = (x / (size - 1) - 0.22) / 0.62
    ny = (y / (size - 1) - 0.16) / 0.62
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * (78 / 255))[..., None]
    rgb = rgb + (np.array(GLOW, np.float32) - rgb) * glow
    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def glyph_layer() -> Image.Image:
    glyph = Image.open(GLYPH_PATH).convert("RGBA")
    h = int(round(S * GLYPH_HEIGHT_RATIO))
    w = int(round(glyph.width * h / glyph.height))
    glyph = glyph.resize((w, h), Image.Resampling.LANCZOS)

    alpha = glyph.getchannel("A")
    ys, xs = np.nonzero(np.array(alpha) > 0)
    dx = int(round(S / 2 - (xs.min() + xs.max()) / 2))
    dy = int(round(S / 2 - (ys.min() + ys.max()) / 2))

    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    solid = Image.new("RGBA", glyph.size, (*INK, 255))
    layer.paste(solid, (dx, dy), alpha)
    return layer


def render_master() -> Image.Image:
    img = background(S)
    glyph = glyph_layer()
    img = Image.alpha_composite(img, glyph)
    return img.convert("RGB").resize((CANVAS, CANVAS), Image.Resampling.LANCZOS)


def save_no_alpha(image: Image.Image, path: Path) -> None:
    if image.mode in ("RGBA", "LA", "P"):
        rgba = image.convert("RGBA")
        if rgba.getchannel("A").getextrema()[0] < 255:
            raise ValueError(f"{path}: transparent pixels are not allowed")
        image = rgba.convert("RGB")
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


def icon_specs() -> list[tuple[str, int]]:
    contents = json.loads(CONTENTS_PATH.read_text(encoding="utf-8"))
    specs: list[tuple[str, int]] = []
    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        base = float(entry["size"].split("x")[0])
        scale = float(entry["scale"].rstrip("x"))
        specs.append((filename, int(round(base * scale))))
    return specs


def validate(path: Path, expected: int) -> None:
    with Image.open(path) as im:
        im.verify()
    with Image.open(path) as im:
        if im.size != (expected, expected):
            raise AssertionError(f"{path.name}: {im.size}, expected {(expected, expected)}")
        if "A" in im.getbands():
            raise AssertionError(f"{path.name}: alpha channel is not allowed")


def main() -> int:
    if not GLYPH_PATH.exists():
        print(f"[FAIL] missing glyph: {GLYPH_PATH}", file=sys.stderr)
        return 1
    if not CONTENTS_PATH.exists():
        print(f"[FAIL] missing {CONTENTS_PATH}", file=sys.stderr)
        return 1

    master = render_master()
    save_no_alpha(master, MASTER_PATH)
    print(f"[OK] {MASTER_PATH.relative_to(ROOT)}  1024x1024 RGB")

    specs = icon_specs()
    for filename, px in specs:
        target = ICONSET_DIR / filename
        icon = master if px == CANVAS else master.resize((px, px), Image.Resampling.LANCZOS)
        save_no_alpha(icon, target)
        validate(target, px)
    print(f"[OK] {len(specs)} AppIcon sizes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
