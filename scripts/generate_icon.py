#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""衡账 LedgerAI · App 图标生成器（仅依赖 Pillow + numpy）。

用法（在仓库根目录执行）：

    python3 scripts/generate_icon.py

产物：

1. ``assets/app_icon_1024.png``                   —— 1024×1024、RGB（无 alpha）主图标
2. ``ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png``
   —— 严格按 Contents.json 中列出的 ``size × scale`` 生成全部尺寸（覆盖原有占位图）

设计：品牌绿渐变（#10B981 → #059669）+ 白色几何「¥」+ 半透明白色小票外框。
不使用任何文字，避免小尺寸发糊；iOS 会自动裁切圆角，因此本脚本不画圆角外轮廓。

脚本结尾会逐张校验：像素尺寸是否与 Contents.json 一致、PNG 是否无 alpha 通道；
任一校验失败即以非 0 退出码结束，便于上游在提交前拦截。
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
MASTER_PATH = ROOT / "assets" / "app_icon_1024.png"
ICONSET_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
CONTENTS_PATH = ICONSET_DIR / "Contents.json"

CANVAS = 1024          # 主图标边长（pt = px）
SUPERSAMPLE = 2        # 先按 2× 绘制再降采样，获得干净的抗锯齿边缘

BRAND = (16, 185, 129)        # #10B981
BRAND_DARK = (5, 150, 105)    # #059669


# --------------------------------------------------------------------------- #
# 背景：对角渐变 + 左上柔光 + 右下轻微压暗
# --------------------------------------------------------------------------- #
def brand_gradient(size: int) -> Image.Image:
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = np.clip((x / (size - 1)) * 0.55 + (y / (size - 1)) * 0.45, 0, 1)[..., None]
    a = np.array(BRAND, np.float32)
    b = np.array(BRAND_DARK, np.float32)
    rgb = a * (1 - t) + b * t

    # 左上柔光，让纯渐变不那么平
    nx = (x / (size - 1) - 0.26) / 0.62
    ny = (y / (size - 1) - 0.16) / 0.62
    glow = (np.clip(1 - np.sqrt(nx * nx + ny * ny), 0, 1) ** 2 * 0.16)[..., None]
    rgb = rgb + (np.array([255, 255, 255], np.float32) - rgb) * glow

    # 右下角非常轻的暗角
    vx = (x / (size - 1) - 0.82) / 0.9
    vy = (y / (size - 1) - 0.95) / 0.9
    vignette = np.clip(np.sqrt(vx * vx + vy * vy), 0, 1)[..., None]
    rgb = rgb * (1 - 0.10 * vignette)

    return Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


# --------------------------------------------------------------------------- #
# 几何「¥」：全部用圆头线段/圆角矩形绘制，避免依赖字体
# --------------------------------------------------------------------------- #
class YuanMark:
    """以自身高度 H 为基准的几何 ¥，坐标单位为像素。"""

    def __init__(self, cx: float, cy: float, H: float) -> None:
        self.cx = cx
        self.H = H
        self.stroke = 0.170 * H          # 笔画宽度
        self.apex_y = cy - 0.50 * H      # ¥ 顶点
        self.junction_y = self.apex_y + 0.40 * H   # V 与竖笔的交点
        self.arm_dx = 0.32 * H           # 两撇的水平跨度
        self.stem_bottom = self.apex_y + H
        self.bar_th = 0.155 * H          # 横画粗细
        self.bar1_y = self.apex_y + 0.550 * H
        self.gap = 0.115 * H             # 两横画之间的空隙
        self.bar2_y = self.bar1_y + self.bar_th + self.gap
        self.bar_half = 0.350 * H        # 横画半宽

    def draw(self, draw: ImageDraw.ImageDraw, fill: tuple) -> None:
        w = int(round(self.stroke))
        half = w / 2.0

        def round_line(p1, p2):
            draw.line([p1, p2], fill=fill, width=w)
            for cx, cy in (p1, p2):
                draw.ellipse([cx - half, cy - half, cx + half, cy + half], fill=fill)

        apex = (self.cx, self.apex_y)
        round_line(apex, (self.cx - self.arm_dx, self.junction_y))
        round_line(apex, (self.cx + self.arm_dx, self.junction_y))
        round_line((self.cx, self.junction_y), (self.cx, self.stem_bottom))

        r = self.bar_th / 2.0
        for y in (self.bar1_y, self.bar2_y):
            draw.rounded_rectangle(
                [self.cx - self.bar_half, y, self.cx + self.bar_half, y + self.bar_th],
                radius=r,
                fill=fill,
            )


# --------------------------------------------------------------------------- #
# 1024 主图标（无 alpha）
# --------------------------------------------------------------------------- #
def render_master() -> Image.Image:
    S = CANVAS * SUPERSAMPLE
    img = brand_gradient(S)

    # 半透明白色小票/账本卡片外框：交代「小票 / 账本」意象，小尺寸下自然变淡
    frame = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle(
        [236 * SUPERSAMPLE, 190 * SUPERSAMPLE, 788 * SUPERSAMPLE, 824 * SUPERSAMPLE],
        radius=48 * SUPERSAMPLE,
        outline=(255, 255, 255, 62),
        width=13 * SUPERSAMPLE,
    )
    img = Image.alpha_composite(img, frame)

    # 白色 ¥
    YuanMark(S / 2, 506 * SUPERSAMPLE, 480 * SUPERSAMPLE).draw(
        ImageDraw.Draw(img), (255, 255, 255, 255)
    )

    master = img.convert("RGB").resize((CANVAS, CANVAS), Image.LANCZOS)
    return master


def save_png_no_alpha(image: Image.Image, path: Path) -> None:
    """保存为无 alpha 的 PNG（RGB 或调色板模式，且不含透明像素）。"""
    if image.mode in ("RGBA", "LA", "P"):
        rgba = image.convert("RGBA")
        if rgba.getchannel("A").getextrema()[0] < 255:
            raise ValueError(f"{path}: 存在透明像素，App Store 图标不允许 alpha")
        image = rgba.convert("RGB")
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)


# --------------------------------------------------------------------------- #
# Contents.json -> 全部尺寸
# --------------------------------------------------------------------------- #
def icon_specs() -> list[tuple[str, int]]:
    contents = json.loads(CONTENTS_PATH.read_text(encoding="utf-8"))
    specs: list[tuple[str, int]] = []
    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        base = float(entry["size"].split("x")[0])
        scale = float(entry["scale"].rstrip("x"))
        px = int(round(base * scale))
        specs.append((filename, px))
    return specs


def validate(path: Path, expected_px: int) -> None:
    with Image.open(path) as im:
        im.verify()  # PNG 完整性校验要求紧接着 open 调用
    with Image.open(path) as im:
        if im.size != (expected_px, expected_px):
            raise AssertionError(f"{path.name}: 尺寸 {im.size}，期望 {(expected_px, expected_px)}")
        if "A" in im.getbands():
            raise AssertionError(f"{path.name}: 含 alpha 通道（App Store 图标不允许）")
        if im.mode == "P" and "transparency" in im.info:
            raise AssertionError(f"{path.name}: 调色板带透明色")


def main() -> int:
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
