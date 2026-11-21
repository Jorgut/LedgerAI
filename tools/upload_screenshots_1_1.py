#!/usr/bin/env python3
"""Upload HENG 1.1 App Store screenshots to a version localization."""
from __future__ import annotations

import hashlib
import os
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parent))
from asc_api import request  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def upload_asset(url: str, method: str, headers: dict, data: bytes) -> None:
    response = requests.request(method, url, headers=headers, data=data, timeout=120)
    if response.status_code >= 400:
        raise RuntimeError(f"upload failed {response.status_code}: {response.text[:400]}")


def upload_set(loc_id: str, folder: Path) -> None:
    # Remove the auto-copied 1.0 screenshot set.
    status, payload = request("GET", f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")
    if status != 200:
        raise RuntimeError(f"read sets failed: {status} {payload}")
    for item in payload.get("data", []):
        _, detail = request("GET", f"/v1/appScreenshotSets/{item['id']}/appScreenshots")
        for shot in detail.get("data", []) or []:
            request("DELETE", f"/v1/appScreenshots/{shot['id']}")
        request("DELETE", f"/v1/appScreenshotSets/{item['id']}")

    status, payload = request(
        "POST",
        "/v1/appScreenshotSets",
        body={
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": "APP_IPHONE_67"},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                    }
                },
            }
        },
    )
    if status not in (200, 201):
        raise RuntimeError(f"create set failed: {status} {payload}")
    set_id = payload["data"]["id"]
    print("set", set_id)

    files = sorted(folder.glob("*.png"))
    if len(files) != 6:
        raise RuntimeError(f"expected 6 screenshots in {folder}, found {len(files)}")
    for path in files:
        data = path.read_bytes()
        checksum = hashlib.md5(data).hexdigest()
        status, payload = request(
            "POST",
            "/v1/appScreenshots",
            body={
                "data": {
                    "type": "appScreenshots",
                    "attributes": {"fileName": path.name, "fileSize": len(data)},
                    "relationships": {
                        "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
                    },
                }
            },
        )
        if status not in (200, 201):
            raise RuntimeError(f"create shot failed {path.name}: {status} {payload}")
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
                    "attributes": {"uploaded": True, "sourceFileChecksum": checksum},
                }
            },
        )
        print(path.name, status)
        if status not in (200, 201):
            raise RuntimeError(f"finalize failed: {status} {payload}")


if __name__ == "__main__":
    upload_set(sys.argv[1], Path(sys.argv[2]))
