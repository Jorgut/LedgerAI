#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · LaunchImage 生成器（仅依赖 Pillow + numpy）。

用法（在仓库根目录执行）：

    python3 scripts/make_launch_images.py

产物（覆盖 Flutter 模板的 1×1 透明占位图）：

    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png     168×185   (1x)
    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png  336×370   (2x)
    ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png  504×555   (3x)

尺寸依据：`ios/Runner/Base.lproj/LaunchScreen.storyboard` 中 LaunchImage 视图为
`contentMode="center"`、无尺寸约束，因此图片按自身点尺寸（168×185pt）居中显示。
本脚本只替换图片资源，不修改 storyboard。

设计：品牌绿渐变圆角方块 + 白色几何 ¥ + 下方「衡账」字标；背景透明，
在 storyboard 的白色底上呈现为居中的品牌徽标。渲染时先按 6× 超采样再降采样，
得到干净的抗锯齿边缘；文字使用系统中的中文字体，缺失时自动退化为纯图标版本。
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
IMAGESET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"

# 点尺寸（与 storyboard 中的 LaunchImage 视图一致）
POINT_W, POINT_H = 168, 185
SCALE = 6  # 超采样倍数：168×6 = 1008，185×6 = 1110
W, H = POINT_W * SCALE, POINT_H * SCALE

BRAND = (16, 185, 129)        # #10B981
BRAND_DARK = (5, 150, 105)    # #059669
INK = (6, 95, 70)             # #065F46 字标颜色

BADGE = 116                   # 徽标边长（pt）
BADGE_RADIUS = 26             # 徽标圆角（pt）
GAP = 7                       # 徽标与字标间距（pt）
WORDMARK = "衡账"
WORDMARK_SIZE = 26            # 字标字号（pt）
WORDMARK_TRACKING = 3         # 字间距（pt）

CJK_FONT_CANDIDATES = [
    ("/System/Library/Fonts/STHeiti Medium.ttc", 0),
    ("/System/Library/Fonts/Hiragino Sans GB.ttc", 0),
    ("/System/Library/Fonts/PingFang.ttc", 2),
]


# --------------------------------------------------------------------------- #
# 品牌渐变（与 App 图标同一套色）
# --------------------------------------------------------------------------- #
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
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * 0.16)[..., None]
    rgb = rgb + (np.array([255, 255, 255], np.float32) - rgb) * glow

    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=radius, fill=255
    )
    return mask


# --------------------------------------------------------------------------- #
# 白色几何 ¥（与 App 图标同一套比例，按高度缩放）
# --------------------------------------------------------------------------- #
def draw_yuan(draw: ImageDraw.ImageDraw, cx: float, cy: float, height: float,
              fill: tuple) -> None:
    stroke = 0.170 * height
    apex_y = cy - 0.50 * height
    junction_y = apex_y + 0.40 * height
    arm_dx = 0.32 * height
    stem_bottom = apex_y + height
    bar_th = 0.155 * height
    bar1_y = apex_y + 0.550 * height
    bar2_y = bar1_y + bar_th + 0.115 * height
    bar_half = 0.350 * height

    w = int(round(stroke))
    half = w / 2.0

    def round_line(p1, p2):
        draw.line([p1, p2], fill=fill, width=w)
        for x, y in (p1, p2):
            draw.ellipse([x - half, y - half, x + half, y + half], fill=fill)

    apex = (cx, apex_y)
    round_line(apex, (cx - arm_dx, junction_y))
    round_line(apex, (cx + arm_dx, junction_y))
    round_line((cx, junction_y), (cx, stem_bottom))

    r = bar_th / 2.0
    for y in (bar1_y, bar2_y):
        draw.rounded_rectangle(
            [cx - bar_half, y, cx + bar_half, y + bar_th], radius=r, fill=fill
        )


def load_wordmark_font(size: int) -> ImageFont.FreeTypeFont | None:
    for path, index in CJK_FONT_CANDIDATES:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size=size, index=index)
            except OSError:
                continue
    return None


# --------------------------------------------------------------------------- #
# 组合：徽标 + 字标，然后按内容外接框做光学居中
# --------------------------------------------------------------------------- #
def render_content() -> Image.Image:
    content = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    badge_px = BADGE * SCALE
    badge_top = 0
    badge_left = (W - badge_px) // 2

    # 柔和投影，让徽标在纯白启动页上有轻微层次
    shadow = Image.new("RGBA", content.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [badge_left, badge_top + 4 * SCALE,
         badge_left + badge_px, badge_top + badge_px + 4 * SCALE],
        radius=BADGE_RADIUS * SCALE,
        fill=(1, 61, 43, 34),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(7 * SCALE))
    content = Image.alpha_composite(content, shadow)

    # 渐变徽标
    badge = brand_gradient(badge_px, badge_px)
    badge.putalpha(rounded_mask(badge_px, BADGE_RADIUS * SCALE))
    content.alpha_composite(badge, (badge_left, badge_top))

    # 白色 ¥
    draw_yuan(
        ImageDraw.Draw(content),
        badge_left + badge_px / 2,
        badge_top + badge_px / 2,
        60 * SCALE,
        (255, 255, 255, 255),
    )

    # 「衡账」字标
    font = load_wordmark_font(WORDMARK_SIZE * SCALE)
    if font is not None:
        tracking = WORDMARK_TRACKING * SCALE
        advances = [font.getlength(ch) for ch in WORDMARK]
        total = sum(advances) + tracking * (len(WORDMARK) - 1)
        ink = font.getbbox(WORDMARK)
        x = (W - total) / 2
        # 默认锚点下 getbbox 的 ink[1] 是文字上缘相对原点的偏移
        text_y = badge_top + badge_px + GAP * SCALE - ink[1]
        for ch, adv in zip(WORDMARK, advances):
            ImageDraw.Draw(content).text((x, text_y), ch, font=font, fill=INK)
            x += adv + tracking

    # 光学居中：把实际内容（含投影）挪到画布正中
    bbox = content.getbbox()
    if bbox is None:
        raise RuntimeError("启动图内容为空")
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    dx = round((W - bw) / 2 - bbox[0])
    dy = round((H - bh) / 2 - bbox[1])
    centered = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    centered.alpha_composite(content, (dx, dy))
    return centered


def save_variant(content: Image.Image, path: Path, width: int, height: int) -> None:
    out = content.resize((width, height), Image.LANCZOS)
    out.save(path, format="PNG", optimize=True)
    with Image.open(path) as im:
        im.verify()  # PNG 完整性校验要求紧接着 open 调用
    with Image.open(path) as im:
        if im.size != (width, height):
            raise AssertionError(f"{path.name}: 尺寸 {im.size}，期望 {(width, height)}")
        if im.mode != "RGBA":
            raise AssertionError(f"{path.name}: 期望 RGBA，实际 {im.mode}")
        if im.getchannel("A").getextrema()[1] == 0:
            raise AssertionError(f"{path.name}: 图片完全透明")
    print(f"  [OK] {path.name:<22} {width}×{height}   RGBA（含透明背景）")


def main() -> int:
    content = render_content()
    print(f"生成 LaunchImage（画布 {POINT_W}×{POINT_H}pt，{SCALE}× 超采样）")
    save_variant(content, IMAGESET / "LaunchImage.png", POINT_W, POINT_H)
    save_variant(content, IMAGESET / "LaunchImage@2x.png", POINT_W * 2, POINT_H * 2)
    save_variant(content, IMAGESET / "LaunchImage@3x.png", POINT_W * 3, POINT_H * 3)
    print("全部启动图尺寸校验通过。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
