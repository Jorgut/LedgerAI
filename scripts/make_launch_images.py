#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · LaunchImage 生成器（Pillow + numpy + Flutter Material 图标字体）。

用法（在仓库根目录执行）：

    python3 scripts/make_launch_images.py

产物（覆盖 Flutter 模板的透明占位图）：

    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png     168×185   (1x)
    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png  336×370   (2x)
    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png  504×555   (3x)

尺寸依据：`ios/Runner/Base.lproj/LaunchScreen.storyboard` 的 LaunchImage 视图为
`contentMode="center"`、无尺寸约束，因此按图片自身点尺寸（168×185pt）居中显示。

设计：与 App 图标、应用内左上角 Logo 完全一致——品牌绿渐变圆角徽标 +
白色 `Icons.account_balance_wallet_rounded`，下方「衡账」字标；背景透明，
在 storyboard 白色底上呈现为居中的品牌徽标。
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
IMAGESET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
MATERIAL_FONT = Path(
    "/Users/aj/Development/flutter/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
)
WALLET_GLYPH = chr(0xF520)

POINT_W, POINT_H = 168, 185
SCALE = 6
W, H = POINT_W * SCALE, POINT_H * SCALE

# 与应用内 AppTheme.brandGradient 一致
BRAND = (4, 120, 87)
BRAND_DARK = (6, 95, 70)
INK = (6, 95, 70)

BADGE = 116
BADGE_RADIUS = 26
GAP = 7
WORDMARK = "衡账"
WORDMARK_SIZE = 26
WORDMARK_TRACKING = 3
GLYPH_RATIO = 0.60

CJK_FONT_CANDIDATES = [
    ("/System/Library/Fonts/STHeiti Medium.ttc", 0),
    ("/System/Library/Fonts/Hiragino Sans GB.ttc", 0),
    ("/System/Library/Fonts/PingFang.ttc", 2),
]


def brand_gradient(width: int, height: int) -> Image.Image:
    y, x = np.mgrid[0:height, 0:width].astype(np.float32)
    t = np.clip(
        (x / max(width - 1, 1)) * 0.55 + (y / max(height - 1, 1)) * 0.45, 0, 1
    )[..., None]
    a = np.array(BRAND, np.float32)
    b = np.array(BRAND_DARK, np.float32)
    rgb = a * (1 - t) + b * t
    nx = (x / max(width - 1, 1) - 0.26) / 0.62
    ny = (y / max(height - 1, 1) - 0.16) / 0.62
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * 0.14)[..., None]
    rgb = rgb + (np.array([255, 255, 255], np.float32) - rgb) * glow
    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=radius, fill=255
    )
    return mask


def draw_wallet(img: Image.Image, width_ratio: float = GLYPH_RATIO) -> None:
    size = img.size[0]
    font = ImageFont.truetype(str(MATERIAL_FONT), int(round(size * width_ratio)))
    bbox = font.getbbox(WALLET_GLYPH)
    glyph_w = bbox[2] - bbox[0]
    glyph_h = bbox[3] - bbox[1]
    x = (size - glyph_w) / 2 - bbox[0]
    y = (size - glyph_h) / 2 - bbox[1]
    ImageDraw.Draw(img).text((x, y), WALLET_GLYPH, font=font, fill=(255, 255, 255, 255))


def load_cjk_font(size_px: int):
    for path, index in CJK_FONT_CANDIDATES:
        try:
            return ImageFont.truetype(path, size_px, index=index)
        except Exception:
            continue
    return None


def render() -> Image.Image:
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    badge_px = BADGE * SCALE
    radius_px = BADGE_RADIUS * SCALE
    badge = brand_gradient(badge_px, badge_px)
    draw_wallet(badge)
    badge.putalpha(rounded_mask(badge_px, radius_px))

    badge_x = (W - badge_px) // 2
    badge_y = 0
    canvas.alpha_composite(badge, (badge_x, badge_y))

    font = load_cjk_font(WORDMARK_SIZE * SCALE)
    if font is not None:
        draw = ImageDraw.Draw(canvas)
        # 手动字间距
        widths = []
        for ch in WORDMARK:
            bbox = font.getbbox(ch)
            widths.append(bbox[2] - bbox[0])
        tracking_px = WORDMARK_TRACKING * SCALE
        total = sum(widths) + tracking_px * (len(WORDMARK) - 1)
        x = (W - total) / 2
        y = badge_y + badge_px + GAP * SCALE
        for ch, w in zip(WORDMARK, widths):
            bbox = font.getbbox(ch)
            draw.text((x - bbox[0], y - bbox[1]), ch, font=font, fill=INK + (255,))
            x += w + tracking_px

    return canvas


def main() -> int:
    if not MATERIAL_FONT.exists():
        print(f"[FAIL] 找不到 Material Icons 字体：{MATERIAL_FONT}", file=sys.stderr)
        return 1
    image = render()
    targets = [
        ("LaunchImage.png", 1),
        ("LaunchImage@2x.png", 2),
        ("LaunchImage@3x.png", 3),
    ]
    for name, scale in targets:
        target = IMAGESET / name
        size = (POINT_W * scale, POINT_H * scale)
        out = image.resize(size, Image.LANCZOS)
        out.save(target, format="PNG", optimize=True)
        with Image.open(target) as check:
            if check.size != size:
                print(f"[FAIL] {name}: 尺寸 {check.size}，期望 {size}", file=sys.stderr)
                return 1
        print(f"[OK] {name:<24} {size[0]}×{size[1]}  RGBA")
    print("LaunchImage 生成完成。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
