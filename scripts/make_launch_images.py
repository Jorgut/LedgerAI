#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · LaunchImage 生成器（Pillow + numpy + Flutter Material 图标字体）。

设计：与 App 图标同一套「科技感」徽标——深绿渐变 + 青绿光晕 + HUD 圆环/弧线 +
白色 `account_balance_wallet_rounded` 字形（墨迹质心居中），下方「衡账」字标。
背景透明，在 LaunchScreen.storyboard 的白色底上居中显示。

产物（覆盖模板占位图）：
    LaunchImage.png 168×185 / @2x 336×370 / @3x 504×555
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
IMAGESET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
MATERIAL_FONT = Path(
    "/Users/aj/Development/flutter/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
)
WALLET_GLYPH = chr(0xF520)

POINT_W, POINT_H = 168, 185
SCALE = 6
W, H = POINT_W * SCALE, POINT_H * SCALE

BADGE = 116
BADGE_RADIUS = 26
GAP = 7
WORDMARK = "衡账"
WORDMARK_SIZE = 26
WORDMARK_TRACKING = 3
GLYPH_RATIO = 0.56

BG_TOP = (9, 84, 66)
BG_BOTTOM = (3, 32, 26)
GLOW = (45, 212, 191)
INK = (6, 95, 70)

CJK_FONT_CANDIDATES = [
    ("/System/Library/Fonts/STHeiti Medium.ttc", 0),
    ("/System/Library/Fonts/Hiragino Sans GB.ttc", 0),
    ("/System/Library/Fonts/PingFang.ttc", 2),
]


def tech_gradient(width: int, height: int) -> Image.Image:
    y, x = np.mgrid[0:height, 0:width].astype(np.float32)
    t = np.clip((x / max(width - 1, 1)) * 0.55 + (y / max(height - 1, 1)) * 0.45, 0, 1)[..., None]
    a = np.array(BG_TOP, np.float32)
    b = np.array(BG_BOTTOM, np.float32)
    rgb = a * (1 - t) + b * t
    nx = (x / max(width - 1, 1) - 0.18) / 0.55
    ny = (y / max(height - 1, 1) - 0.12) / 0.55
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * (110 / 255))[..., None]
    rgb = rgb + (np.array(GLOW, np.float32) - rgb) * glow
    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_badge(size: int) -> Image.Image:
    badge = tech_gradient(size, size)
    draw = ImageDraw.Draw(badge)
    line = max(2, size // 220)
    for ratio, alpha in ((0.33, 34), (0.415, 22)):
        r = int(size * ratio)
        draw.ellipse(
            [size // 2 - r, size // 2 - r, size // 2 + r, size // 2 + r],
            outline=(255, 255, 255, alpha),
            width=line,
        )
    arc_r = int(size * 0.44)
    draw.arc(
        [size // 2 - arc_r, size // 2 - arc_r, size // 2 + arc_r, size // 2 + arc_r],
        start=20,
        end=110,
        fill=(45, 212, 191, 170),
        width=max(3, size // 140),
    )
    inset = int(size * 0.05)
    draw.rounded_rectangle(
        [inset, inset, size - inset, size - inset],
        radius=int(size * 0.17),
        outline=(255, 255, 255, 40),
        width=max(2, size // 240),
    )

    # 光晕
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gr = int(size * 0.23)
    ImageDraw.Draw(glow).ellipse(
        [size // 2 - gr, size // 2 - gr, size // 2 + gr, size // 2 + gr], fill=(45, 212, 191, 80)
    )
    badge = Image.alpha_composite(badge, glow.filter(ImageFilter.GaussianBlur(size // 30)))

    # 字形（墨迹质心居中）
    font = ImageFont.truetype(str(MATERIAL_FONT), int(round(size * GLYPH_RATIO)))
    bbox = font.getbbox(WALLET_GLYPH)
    gw, gh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    pad = 40
    mask = Image.new("L", (gw + pad * 2, gh + pad * 2), 0)
    ImageDraw.Draw(mask).text((pad - bbox[0], pad - bbox[1]), WALLET_GLYPH, font=font, fill=255)
    arr = np.array(mask)
    ys, xs = np.nonzero(arr)
    dx = int(round(mask.size[0] / 2 - xs.mean()))
    dy = int(round(mask.size[1] / 2 - ys.mean()))
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    layer.paste(
        Image.new("RGBA", mask.size, (255, 255, 255, 255)),
        ((size - mask.size[0]) // 2 + dx, (size - mask.size[1]) // 2 + dy),
        mask,
    )
    shadow = layer.filter(ImageFilter.GaussianBlur(size // 50))
    shadow_arr = np.array(shadow)
    shadow_arr[..., 3] = (shadow_arr[..., 3] * 0.5).astype(np.uint8)
    badge = Image.alpha_composite(badge, Image.fromarray(shadow_arr))
    badge = Image.alpha_composite(badge, layer)

    badge.putalpha(rounded_mask(size, BADGE_RADIUS * SCALE))
    return badge


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
    badge = draw_badge(badge_px)
    canvas.alpha_composite(badge, ((W - badge_px) // 2, 0))

    font = load_cjk_font(WORDMARK_SIZE * SCALE)
    if font is not None:
        draw = ImageDraw.Draw(canvas)
        widths = []
        for ch in WORDMARK:
            bbox = font.getbbox(ch)
            widths.append(bbox[2] - bbox[0])
        tracking = WORDMARK_TRACKING * SCALE
        total = sum(widths) + tracking * (len(WORDMARK) - 1)
        x = (W - total) / 2
        y = badge_px + GAP * SCALE
        for ch, w in zip(WORDMARK, widths):
            bbox = font.getbbox(ch)
            draw.text((x - bbox[0], y - bbox[1]), ch, font=font, fill=INK + (255,))
            x += w + tracking
    return canvas


def main() -> int:
    if not MATERIAL_FONT.exists():
        print(f"[FAIL] 找不到 Material Icons 字体：{MATERIAL_FONT}", file=sys.stderr)
        return 1
    image = render()
    for name, scale in (("LaunchImage.png", 1), ("LaunchImage@2x.png", 2), ("LaunchImage@3x.png", 3)):
        target = IMAGESET / name
        size = (POINT_W * scale, POINT_H * scale)
        image.resize(size, Image.LANCZOS).save(target, format="PNG", optimize=True)
        with Image.open(target) as check:
            if check.size != size:
                print(f"[FAIL] {name}: 尺寸 {check.size}，期望 {size}", file=sys.stderr)
                return 1
        print(f"[OK] {name:<24} {size[0]}×{size[1]}  RGBA")
    print("LaunchImage 生成完成。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
