#!/usr/bin/env python3
"""App Store Connect API 小工具（衡账上架自动化）。

仅本机使用：读取 ~/.appstoreconnect/private_keys/AuthKey_<KEYID>.p8，
用 ES256 生成 JWT 调用 App Store Connect API。不记录、不上传任何凭据。

用法：
  python3 tools/asc_api.py get /v1/apps 'limit=5'
  python3 tools/asc_api.py post /v1/bundleIds '<json body>'
  python3 tools/asc_api.py patch /v1/apps/123 '<json body>'
  python3 tools/asc_api.py delete /v1/...
"""

from __future__ import annotations

import base64
import json
import os
import sys
import time
import urllib.parse
from pathlib import Path

import requests
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "e47c13e9-4fa8-4764-aa53-5b257951df84")
KEY_ID = os.environ.get("ASC_KEY_ID", "79W52WL2JB")
KEY_PATH = Path(
    os.environ.get(
        "ASC_KEY_PATH",
        os.path.expanduser(f"~/.appstoreconnect/private_keys/AuthKey_{KEY_ID}.p8"),
    )
)
BASE = "https://api.appstoreconnect.apple.com"


def _b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def make_token() -> str:
    header = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"}
    signing_input = (
        _b64url(json.dumps(header, separators=(",", ":")).encode())
        + "."
        + _b64url(json.dumps(payload, separators=(",", ":")).encode())
    ).encode()
    key = serialization.load_pem_private_key(KEY_PATH.read_bytes(), password=None)
    der = key.sign(signing_input, ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der)
    signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return signing_input.decode() + "." + _b64url(signature)


def request(method: str, path: str, params: dict | None = None, body=None, timeout: int = 60):
    url = path if path.startswith("http") else BASE + path
    headers = {"Authorization": f"Bearer {make_token()}"}
    if body is not None:
        headers["Content-Type"] = "application/json"
    response = requests.request(
        method,
        url,
        params=params,
        data=json.dumps(body) if body is not None else None,
        headers=headers,
        timeout=timeout,
    )
    try:
        payload = response.json()
    except ValueError:
        payload = response.text
    return response.status_code, payload


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    action = sys.argv[1]
    if action == "get":
        params = dict(urllib.parse.parse_qsl(sys.argv[3])) if len(sys.argv) > 3 else None
        status, payload = request("GET", sys.argv[2], params=params)
    elif action in ("post", "patch"):
        body = json.loads(sys.argv[3]) if len(sys.argv) > 3 else {}
        status, payload = request(action.upper(), sys.argv[2], body=body)
    elif action == "delete":
        status, payload = request("DELETE", sys.argv[2])
    elif action == "token":
        print(make_token())
        return 0
    else:
        print(f"unknown action {action}")
        return 2
    print(status)
    print(json.dumps(payload, ensure_ascii=False, indent=2)[:20000])
    return 0 if 200 <= status < 300 else 1


if __name__ == "__main__":
    raise SystemExit(main())
