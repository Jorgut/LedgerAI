#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · App 图标生成器（Pillow + numpy + Flutter Material 图标字体）。

设计：与应用内左上角 Logo 同一字形（Material `account_balance_wallet_rounded`，码位 0xF520），
并在品牌绿渐变上加入「科技感」层：深绿渐变 + 青绿光晕 + 同心 HUD 圆环 + 局部青色弧线 + 内描边。
白色字形按**墨迹质心**做视觉居中（不是简单几何外框居中），解决小尺寸下"看起来偏右"的问题。

用法（仓库根目录）：

    python3 scripts/generate_icon.py

产物：
1. assets/app_icon_1024.png —— 1024×1024 RGB 无 alpha 主图标
2. ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png —— Contents.json 列出的全部尺寸
脚本末尾逐张校验尺寸与无 alpha。
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
MASTER_PATH = ROOT / "assets" / "app_icon_1024.png"
ICONSET_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS_PATH = ICONSET_DIR / "Contents.json"

MATERIAL_FONT = Path(
    "/Users/aj/Development/flutter/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
)
WALLET_GLYPH = chr(0xF520)  # Icons.account_balance_wallet_rounded

CANVAS = 1024
SUPERSAMPLE = 2
S = CANVAS * SUPERSAMPLE
GLYPH_WIDTH_RATIO = 0.56

# 深绿科技渐变 + 青绿光晕
BG_TOP = (9, 84, 66)       # #095442
BG_BOTTOM = (3, 32, 26)    # #03201A
GLOW = (45, 212, 191)      # #2DD4BF
ARC = (45, 212, 191, 150)


def tech_background(size: int) -> Image.Image:
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = np.clip((x / (size - 1)) * 0.55 + (y / (size - 1)) * 0.45, 0, 1)[..., None]
    a = np.array(BG_TOP, np.float32)
    b = np.array(BG_BOTTOM, np.float32)
    rgb = a * (1 - t) + b * t

    # 左上角青绿光晕
    nx = (x / (size - 1) - 0.18) / 0.55
    ny = (y / (size - 1) - 0.12) / 0.55
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * (110 / 255))[..., None]
    rgb = rgb + (np.array(GLOW, np.float32) - rgb) * glow
    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def draw_rings(img: Image.Image) -> None:
    """v3：去掉同心圆/弧线/HUD 边框，只保留轻微光晕，避免小尺寸下视觉杂乱。"""
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    r = int(S * 0.30)
    ImageDraw.Draw(glow).ellipse(
        [S // 2 - r, S // 2 - r, S // 2 + r, S // 2 + r],
        fill=(45, 212, 191, 28),
    )
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(S // 22)))


def glyph_layer() -> Image.Image:
    """白色钱包字形，按墨迹质心居中。"""
    font = ImageFont.truetype(str(MATERIAL_FONT), int(round(S * GLYPH_WIDTH_RATIO)))
    bbox = font.getbbox(WALLET_GLYPH)
    glyph_w, glyph_h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pad = 80
    mask = Image.new("L", (glyph_w + pad * 2, glyph_h + pad * 2), 0)
    ImageDraw.Draw(mask).text(
        (pad - bbox[0], pad - bbox[1]), WALLET_GLYPH, font=font, fill=255
    )
    arr = np.array(mask)
    ys, xs = np.nonzero(arr)
    # 质心相对画布中心的偏移（视觉居中）
    dx = int(round(mask.size[0] / 2 - xs.mean()))
    dy = int(round(mask.size[1] / 2 - ys.mean()))
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    layer.paste(
        Image.new("RGBA", mask.size, (255, 255, 255, 255)),
        ((S - mask.size[0]) // 2 + dx, (S - mask.size[1]) // 2 + dy),
        mask,
    )
    return layer


def render_master() -> Image.Image:
    img = tech_background(S)
    draw_rings(img)

    # 字形后的青绿光晕
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    r = int(S * 0.23)
    ImageDraw.Draw(glow).ellipse(
        [S // 2 - r, S // 2 - r, S // 2 + r, S // 2 + r], fill=(45, 212, 191, 70)
    )
    glow = glow.filter(ImageFilter.GaussianBlur(S // 45))
    img = Image.alpha_composite(img, glow)

    glyph = glyph_layer()
    shadow = glyph.filter(ImageFilter.GaussianBlur(S // 110))
    shadow_arr = np.array(shadow)
    shadow_arr[..., 3] = (shadow_arr[..., 3] * 0.5).astype(np.uint8)
    img = Image.alpha_composite(img, Image.fromarray(shadow_arr))
    img = Image.alpha_composite(img, glyph)

    return img.convert("RGB").resize((CANVAS, CANVAS), Image.LANCZOS)


def save_png_no_alpha(image: Image.Image, path: Path) -> None:
    if image.mode in ("RGBA", "LA", "P"):
        rgba = image.convert("RGBA")
        if rgba.getchannel("A").getextrema()[0] < 255:
            raise ValueError(f"{path}: 存在透明像素，App Store 图标不允许 alpha")
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


def validate(path: Path, expected_px: int) -> None:
    with Image.open(path) as im:
        im.verify()
    with Image.open(path) as im:
        if im.size != (expected_px, expected_px):
            raise AssertionError(f"{path.name}: 尺寸 {im.size}，期望 {(expected_px, expected_px)}")
        if "A" in im.getbands():
            raise AssertionError(f"{path.name}: 含 alpha 通道（App Store 图标不允许）")
        if im.mode == "P" and "transparency" in im.info:
            raise AssertionError(f"{path.name}: 调色板带透明色")


def main() -> int:
    if not MATERIAL_FONT.exists():
        print(f"[FAIL] 找不到 Material Icons 字体：{MATERIAL_FONT}", file=sys.stderr)
        return 1
    if not CONTENTS_PATH.exists():
        print(f"[FAIL] 找不到 {CONTENTS_PATH}", file=sys.stderr)
        return 1

    master = render_master()
    save_png_no_alpha(master, MASTER_PATH)
    print(f"[OK] 主图标 {MASTER_PATH.relative_to(ROOT)}  1024×1024  RGB（无 alpha）")

    specs = icon_specs()
    if not specs:
        print("[FAIL] Contents.json 未列出任何图标文件", file=sys.stderr)
        return 1

    print(f"\n按 Contents.json 生成 {len(specs)} 个尺寸：")
    for filename, px in specs:
        target = ICONSET_DIR / filename
        icon = master if px == CANVAS else master.resize((px, px), Image.LANCZOS)
        save_png_no_alpha(icon, target)
        validate(target, px)
        print(f"  [OK] {filename:<28} {px:>4}×{px:<4} RGB 无 alpha")

    print("\n全部图标尺寸与 alpha 校验通过。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
