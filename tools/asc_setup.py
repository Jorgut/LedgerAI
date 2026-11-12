#!/usr/bin/env python3
"""衡账 App Store Connect 元数据准备脚本（幂等，可重复执行）。

读取 store/metadata_zh.md 中的文案，写入 App Store Connect：
- App 版权声明、版本号
- 商店本地化：副标题、隐私政策 URL、描述、关键词、促销文案、支持 URL
- 主分类（财务）
- 年龄分级
- 审核联系信息与备注

前置：source .env.asc（ASC_ISSUER_ID / ASC_KEY_ID / ASC_APP_ID / ASC_VERSION_ID ...）
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from asc_api import request  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
META = ROOT / "store" / "metadata_zh.md"

APP_ID = os.environ["ASC_APP_ID"]
VERSION_ID = os.environ["ASC_VERSION_ID"]
LOC_ID = os.environ["ASC_LOC_ID"]
INFO_ID = os.environ["ASC_INFO_ID"]
INFO_LOC_ID = os.environ["ASC_INFO_LOC_ID"]

PRIVACY_URL = "https://jorgut.github.io/LedgerAI/PRIVACY.html"
SUPPORT_URL = "https://jorgut.github.io/LedgerAI/SUPPORT.html"
MARKETING_URL = "https://github.com/Jorgut/LedgerAI"

REVIEW_CONTACT = {
    "contactFirstName": "Altankhuu",
    "contactLastName": "JORGUTYN",
    "contactPhone": "+8618588751947",
    "contactEmail": "honaler@gmail.com",
}


def sections(text: str) -> dict[str, str]:
    """按二级标题切分 markdown。"""
    result: dict[str, str] = {}
    current = ""
    for line in text.splitlines():
        if line.startswith("## "):
            current = line[3:].strip()
            result[current] = []
        elif current:
            result[current].append(line)
    return {key: "\n".join(value) for key, value in result.items()}


def first_fence(text: str) -> str:
    match = re.search(r"```(?:text)?\n(.*?)```", text, re.S)
    if not match:
        raise SystemExit("未找到代码块文案")
    return match.group(1).strip()


def log(label: str, status: int, payload) -> None:
    ok = 200 <= status < 300
    print(f"[{'OK ' if ok else 'ERR'}] {label} → {status}")
    if not ok:
        print(json.dumps(payload, ensure_ascii=False, indent=2)[:3000])


def patch(path: str, body: dict, label: str) -> bool:
    status, payload = request("PATCH", path, body=body)
    log(label, status, payload)
    return 200 <= status < 300


def main() -> int:
    meta = sections(META.read_text(encoding="utf-8"))
    keywords = first_fence(meta["3. 关键词（上限 100 字符，英文逗号分隔）"])
    promotional = first_fence(meta["4. 促销文案（Promotional Text，上限 170 字符，更新无需重新提审）"])
    description = first_fence(meta["5. 完整描述（上限 4000 字符，实测 1035 字符）"])
    notes = first_fence(meta["6. 审核备注（App Review Information ▸ Notes，上限 4000 字符）"])
    notes = notes.replace(
        "https://github.com/Jorgut/LedgerAI/blob/main/PRIVACY.md", PRIVACY_URL
    )

    # 1) 主分类（财务）
    status, payload = request("GET", "/v1/appCategories", params={"filter[platforms]": "IOS", "limit": 200})
    if status != 200:
        log("读取分类", status, payload)
        return 1
    finance_id = next((c["id"] for c in payload["data"] if c["id"] == "FINANCE"), None)
    if not finance_id:
        print("未找到 FINANCE 分类")
        return 1

    # 2) App 级：版权声明
    patch(
        f"/v1/apps/{APP_ID}",
        {
            "data": {
                "type": "apps",
                "id": APP_ID,
                "attributes": {
                    "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT",
                    "primaryLocale": "zh-Hans",
                },
            }
        },
        "App 内容版权声明",
    )

    # 3) 版本号（包内为 1.0.0，需一致才能关联构建）
    patch(
        f"/v1/appStoreVersions/{VERSION_ID}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": VERSION_ID,
                "attributes": {"versionString": "1.0.0", "copyright": "© 2026 Jorgut"},
            }
        },
        "版本号 1.0.0 / 版权",
    )

    # 4) App 信息本地化：副标题 + 隐私政策 URL
    patch(
        f"/v1/appInfoLocalizations/{INFO_LOC_ID}",
        {
            "data": {
                "type": "appInfoLocalizations",
                "id": INFO_LOC_ID,
                "attributes": {
                    "name": "衡账",
                    "subtitle": "拍照语音记账，离线更安心",
                    "privacyPolicyUrl": PRIVACY_URL,
                },
            }
        },
        "App 信息：名称/副标题/隐私政策",
    )

    # 5) 版本本地化：描述、关键词、促销、支持 URL
    patch(
        f"/v1/appStoreVersionLocalizations/{LOC_ID}",
        {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": LOC_ID,
                "attributes": {
                    "description": description,
                    "keywords": keywords,
                    "promotionalText": promotional,
                    "supportUrl": SUPPORT_URL,
                    "marketingUrl": MARKETING_URL,
                },
            }
        },
        "版本本地化：描述/关键词/促销/URL",
    )

    # 6) 主分类关系
    patch(
        f"/v1/appInfos/{INFO_ID}",
        {
            "data": {
                "type": "appInfos",
                "id": INFO_ID,
                "relationships": {
                    "primaryCategory": {"data": {"type": "appCategories", "id": finance_id}},
                    "secondaryCategory": {"data": {"type": "appCategories", "id": "PRODUCTIVITY"}},
                },
            }
        },
        "主分类 财务 / 次分类 效率",
    )

    # 7) 审核联系信息（若已存在则跳过）
    status, payload = request("GET", f"/v1/appStoreVersions/{VERSION_ID}/appStoreReviewDetail")
    if status == 200 and payload.get("data"):
        print("[OK ] 审核联系信息已存在，跳过")
    else:
        attrs = dict(REVIEW_CONTACT)
        attrs.update({"demoAccountRequired": False, "notes": notes})
        status, payload = request(
            "POST",
            "/v1/appStoreReviewDetails",
            body={
                "data": {
                    "type": "appStoreReviewDetails",
                    "attributes": attrs,
                    "relationships": {
                        "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
                    },
                }
            },
        )
        log("审核联系信息", status, payload)

    # 8) 年龄分级（全部无 / 否）
    age_body: dict = {
        "advertising": False,
        "gambling": False,
        "unrestrictedWebAccess": False,
        "ageRatingOverride": "NONE",
        "ageRatingOverrideV2": "NONE",
        "koreaAgeRatingOverride": "NONE",
        "socialMedia": False,
        "socialMediaAgeRestricted": False,
        "messagingAndChat": False,
        "userGeneratedContent": False,
        "parentalControls": False,
        "ageAssurance": False,
    }
    for field in (
        "alcoholTobaccoOrDrugUseOrReferences",
        "contests",
        "gamblingSimulated",
        "gunsOrOtherWeapons",
        "healthOrWellnessTopics",
        "lootBox",
        "medicalOrTreatmentInformation",
        "profanityOrCrudeHumor",
        "sexualContentGraphicAndNudity",
        "sexualContentOrNudity",
        "horrorOrFearThemes",
        "matureOrSuggestiveThemes",
        "violenceCartoonOrFantasy",
        "violenceRealisticProlongedGraphicOrSadistic",
        "violenceRealistic",
    ):
        age_body[field] = "NONE"
    patch(
        f"/v1/ageRatingDeclarations/{INFO_ID}",
        {"data": {"type": "ageRatingDeclarations", "id": INFO_ID, "attributes": age_body}},
        "年龄分级",
    )

    # 输出当前状态
    for label, path in (
        ("版本", f"/v1/appStoreVersions/{VERSION_ID}"),
        ("本地化", f"/v1/appStoreVersionLocalizations/{LOC_ID}"),
        ("App 信息", f"/v1/appInfoLocalizations/{INFO_LOC_ID}"),
        ("审核信息", f"/v1/appStoreVersions/{VERSION_ID}/appStoreReviewDetail"),
    ):
        status, payload = request("GET", path)
        log(f"读取{label}", status, payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
