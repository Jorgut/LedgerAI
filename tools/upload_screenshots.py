#!/usr/bin/env python3
"""上传 6.9 英寸 App Store 截图到 App Store Connect。

用法：source .env.asc && python3 tools/upload_screenshots.py [--replace]
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parent))
from asc_api import request  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LOC_ID = os.environ["ASC_LOC_ID"]

# 展示顺序：首页 → 拍照识别 → 报表 → 预算 → 账单 → 设置
SCREENSHOTS = [
    ("store/screenshots_raw/01_home.png", "01_home.png"),
    ("store/screenshots_raw/07_add_receipt.png", "02_receipt.png"),
    ("store/screenshots_raw/03_reports_donut.png", "03_reports.png"),
    ("store/screenshots_raw/04_budget.png", "04_budget.png"),
    ("store/screenshots_raw/02_transactions.png", "05_transactions.png"),
    ("store/screenshots_raw/05_settings.png", "06_settings.png"),
]

DISPLAY_TYPES = ["APP_IPHONE_69", "APP_IPHONE_67"]


def upload_asset(url: str, method: str, headers: dict, data: bytes) -> None:
    response = requests.request(method, url, headers=headers, data=data, timeout=120)
    if response.status_code >= 400:
        raise RuntimeError(f"上传失败 {response.status_code}: {response.text[:500]}")


def main() -> int:
    replace = "--replace" in sys.argv

    # 清理已有截图（可重复执行）
    status, payload = request(
        "GET", f"/v1/appStoreVersionLocalizations/{LOC_ID}/appScreenshotSets"
    )
    if status != 200:
        print("读取截图集失败", status, payload)
        return 1
    for item in payload.get("data", []):
        if replace:
            _, detail = request("GET", f"/v1/appScreenshotSets/{item['id']}/appScreenshots")
            for shot in (detail.get("data") or []):
                request("DELETE", f"/v1/appScreenshots/{shot['id']}")
            status, body = request("DELETE", f"/v1/appScreenshotSets/{item['id']}")
            print(f"删除旧截图集 {item['id']} → {status}")

    set_id = None
    display_type = None
    for candidate in DISPLAY_TYPES:
        status, payload = request(
            "POST",
            "/v1/appScreenshotSets",
            body={
                "data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": candidate},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {
                                "type": "appStoreVersionLocalizations",
                                "id": LOC_ID,
                            }
                        }
                    },
                }
            },
        )
        if status in (200, 201):
            set_id = payload["data"]["id"]
            display_type = candidate
            print(f"创建截图集 {display_type} → {set_id}")
            break
        print(f"{candidate} 不支持：{status} {str(payload)[:300]}")
    if not set_id:
        return 1

    # 先准备去掉 alpha 的 RGB PNG（App Store 更稳妥）
    prepared = []
    for source, name in SCREENSHOTS:
        from PIL import Image

        image = Image.open(ROOT / source).convert("RGB")
        out = ROOT / "store" / "screenshots_raw" / f"final_{name}"
        image.save(out, "PNG", optimize=True)
        prepared.append((out, name))

    for path, name in prepared:
        data = path.read_bytes()
        checksum = hashlib.md5(data).hexdigest()
        status, payload = request(
            "POST",
            "/v1/appScreenshots",
            body={
                "data": {
                    "type": "appScreenshots",
                    "attributes": {
                        "fileName": name,
                        "fileSize": len(data),
                    },
                    "relationships": {
                        "appScreenshotSet": {
                            "data": {"type": "appScreenshotSets", "id": set_id}
                        }
                    },
                }
            },
        )
        if status not in (200, 201):
            print(f"创建截图记录失败 {name}: {status} {str(payload)[:500]}")
            return 1
        shot = payload["data"]
        shot_id = shot["id"]
        for op in shot["attributes"]["uploadOperations"]:
            headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
            chunk = data[op["offset"]: op["offset"] + op["length"]]
            upload_asset(op["url"], op["method"], headers, chunk)
        status, payload = request(
            "PATCH",
            f"/v1/appScreenshots/{shot_id}",
            body={
                "data": {
                    "type": "appScreenshots",
                    "id": shot_id,
                    "attributes": {
                        "uploaded": True,
                        "sourceFileChecksum": checksum,
                    },
                }
            },
        )
        print(f"上传截图 {name} → {status}")
        if status not in (200, 201):
            print(str(payload)[:800])
            return 1

    status, payload = request("GET", f"/v1/appScreenshotSets/{set_id}/appScreenshots")
    count = len(payload.get("data", [])) if status == 200 else -1
    print(f"截图集 {display_type} 共 {count} 张")
    return 0 if count == len(prepared) else 1


if __name__ == "__main__":
    raise SystemExit(main())
