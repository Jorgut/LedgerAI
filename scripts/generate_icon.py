#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · App 图标生成器（仅依赖 Pillow + numpy + Flutter Material 图标字体）。

设计：**与 App 内左上角 Logo 完全一致**——品牌绿渐变圆角方块 + 白色
`Icons.account_balance_wallet_rounded`（Material Icons，码位 0xF520）。
使用同一字形、同一渐变（#047857 → #065F46），保证「App Store 图标 = 启动图 = 应用内 Logo」。

用法（在仓库根目录执行）：

    python3 scripts/generate_icon.py

产物：

1. ``assets/app_icon_1024.png``                   —— 1024×1024、RGB（无 alpha）主图标
2. ``ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png``
   —— 严格按 Contents.json 中列出的 ``size × scale`` 生成全部尺寸（覆盖原有占位图）

脚本结尾逐张校验像素尺寸与无 alpha；任一失败即非 0 退出，便于提交前拦截。
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
MASTER_PATH = ROOT / "assets" / "app_icon_1024.png"
ICONSET_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS_PATH = ICONSET_DIR / "Contents.json"

# Material Icons 字体（Flutter SDK 自带）；如本机路径不同，可用环境变量覆盖。
MATERIAL_FONT = Path(
    "/Users/aj/Development/flutter/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
)
WALLET_GLYPH = chr(0xF520)  # Icons.account_balance_wallet_rounded

CANVAS = 1024
SUPERSAMPLE = 2
GLYPH_WIDTH_RATIO = 0.60  # 白色钱包图形占画布宽度比例（与应用内 18/32 视觉比例一致）

# 与应用内 AppTheme.brandGradient 完全一致：kBrandText(#047857) → #065F46
BRAND = (4, 120, 87)
BRAND_DARK = (6, 95, 70)


def brand_gradient(size: int) -> Image.Image:
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = np.clip((x / (size - 1)) * 0.55 + (y / (size - 1)) * 0.45, 0, 1)[..., None]
    a = np.array(BRAND, np.float32)
    b = np.array(BRAND_DARK, np.float32)
    rgb = a * (1 - t) + b * t

    # 左上柔光，避免纯渐变发平
    nx = (x / (size - 1) - 0.26) / 0.62
    ny = (y / (size - 1) - 0.16) / 0.62
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * 0.14)[..., None]
    rgb = rgb + (np.array([255, 255, 255], np.float32) - rgb) * glow

    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def draw_wallet(img: Image.Image, width_ratio: float = GLYPH_WIDTH_RATIO) -> None:
    """在画布中心绘制白色钱包 glyph（与 Flutter Icon 渲染同一字体字形）。"""
    size = img.size[0]
    target_w = size * width_ratio
    font = ImageFont.truetype(str(MATERIAL_FONT), int(round(target_w)))
    bbox = font.getbbox(WALLET_GLYPH)
    glyph_w = bbox[2] - bbox[0]
    glyph_h = bbox[3] - bbox[1]
    x = (size - glyph_w) / 2 - bbox[0]
    y = (size - glyph_h) / 2 - bbox[1]
    ImageDraw.Draw(img).text(
        (x, y), WALLET_GLYPH, font=font, fill=(255, 255, 255, 255)
    )


def render_master() -> Image.Image:
    S = CANVAS * SUPERSAMPLE
    img = brand_gradient(S)
    draw_wallet(img)
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
