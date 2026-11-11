#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# 衡账 LedgerAI · App Store 截图抓取脚本
#
# 前置条件（本脚本不负责安装）：
#   · macOS + Xcode（含 iOS 模拟器运行时）
#   · Flutter SDK 在 PATH 中，`flutter doctor` 通过
#   · 已执行 `flutter pub get`
#
# 用法：
#   ./scripts/capture_screenshots.sh              # 交互式：按提示逐个页面抓图
#   DEVICE_NAME="iPhone 17 Pro Max" ./scripts/capture_screenshots.sh
#   OUT_DIR=/tmp/shots ./scripts/capture_screenshots.sh
#
# 流程：
#   1. 启动指定模拟器（默认 iPhone 18 Pro Max，6.9 英寸）并解锁状态栏 9:41；
#   2. `flutter run -d <UDID> --dart-define=DEMO=true` 启动带示例数据的版本；
#   3. 每抓一张前脚本会暂停，提示你在模拟器里手动切到对应页面，回车后
#      `xcrun simctl io <UDID> screenshot` 保存 PNG；
#   4. 结束后退出 flutter run 并清理状态栏覆盖。
#
# 产物：store/screenshots/raw/NN_<slug>.png（默认 1320×2868，App Store 6.9" 规格）
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/store/screenshots/raw}"
FLUTTER_LOG="${FLUTTER_LOG:-/tmp/ledgerai_flutter_run.log}"
DEVICE_NAME="${DEVICE_NAME:-iPhone 18 Pro Max}"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-180}"

# 6.9 英寸 iPhone（iPhone 16/17/18 Pro Max）截图规格；6.7 英寸为 1290×2796。
EXPECTED_W=1320
EXPECTED_H=2868

SCREENS=(
  "01_home|首页概览（首页 Tab：本月收支 / 结余 / 预算进度 / 最近交易）"
  "02_add_photo|拍照记账（记账页「拍照识别」入口或识别结果确认页）"
  "03_add_voice|语音记账（记账页「语音记账」入口，展示识别出的金额与分类）"
  "04_reports|报表分析（报表 Tab：趋势 + 分类占比 + 本地智能建议）"
  "05_budget|预算管理（预算 Tab：月度总预算 + 分类预算进度）"
  "06_privacy|隐私与数据（我的/设置页：本地存储、导出与清空数据）"
  "07_dark|深色模式（可选：深色主题下的首页，体现两套主题都可用）"
)

log()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31m%s\033[0m\n' "$*" >&2; exit 1; }

command -v flutter >/dev/null 2>&1 || die "找不到 flutter，请先把 Flutter SDK 加入 PATH。"
command -v xcrun   >/dev/null 2>&1 || die "找不到 xcrun，请在 macOS + Xcode 环境执行。"

mkdir -p "$OUT_DIR"

# --- 1. 选择并启动模拟器 -----------------------------------------------------
pick_udid() {
  local name="$1"
  xcrun simctl list devices available |
    grep -F "$name (" | head -n 1 |
    sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/'
}

UDID="$(pick_udid "$DEVICE_NAME" || true)"
if [[ -z "${UDID:-}" ]]; then
  warn "未找到模拟器「$DEVICE_NAME」，尝试 6.9\" 备选机型……"
  for alt in "iPhone 17 Pro Max" "iPhone 16 Pro Max" "iPhone 15 Pro Max"; do
    UDID="$(pick_udid "$alt" || true)"
    if [[ -n "${UDID:-}" ]]; then DEVICE_NAME="$alt"; break; fi
  done
fi
[[ -n "${UDID:-}" ]] || die "没有可用的 6.9\" iPhone 模拟器。请在 Xcode ▸ Settings ▸ Components 下载 iOS 运行时，或创建 iPhone 17/18 Pro Max 模拟器。"

log "设备：$DEVICE_NAME ($UDID)"

xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light >/dev/null 2>&1 || true
# 统一状态栏：9:41 / 满电 / 满格信号（App Store 截图惯例）
xcrun simctl status_bar "$UDID" override \
  --time "9:41" --batteryState charged --batteryLevel 100 \
  --wifiBars 3 --cellularBars 4 >/dev/null 2>&1 || \
  warn "状态栏覆盖失败（旧版 Xcode 可能不支持），截图状态栏将显示模拟器当前时间。"

FLUTTER_PID=""
cleanup() {
  if [[ -n "$FLUTTER_PID" ]] && kill -0 "$FLUTTER_PID" 2>/dev/null; then
    kill -INT "$FLUTTER_PID" 2>/dev/null || true
    wait "$FLUTTER_PID" 2>/dev/null || true
  fi
  xcrun simctl status_bar "$UDID" clear >/dev/null 2>&1 || true
  log "已退出 flutter run 并清理状态栏覆盖。"
}
trap cleanup EXIT

# --- 2. 启动 DEMO 版本 -------------------------------------------------------
log "启动 App（--dart-define=DEMO=true，示例账本）……"
flutter run -d "$UDID" --dart-define=DEMO=true >"$FLUTTER_LOG" 2>&1 &
FLUTTER_PID=$!

deadline=$((SECONDS + BOOT_TIMEOUT))
until grep -qE "Flutter run key commands|Syncing files to device|A Dart VM Service" "$FLUTTER_LOG" 2>/dev/null; do
  if ! kill -0 "$FLUTTER_PID" 2>/dev/null; then
    tail -n 40 "$FLUTTER_LOG" >&2
    die "flutter run 提前退出，详见 $FLUTTER_LOG"
  fi
  (( SECONDS < deadline )) || { tail -n 40 "$FLUTTER_LOG" >&2; die "等待 App 启动超时（${BOOT_TIMEOUT}s），详见 $FLUTTER_LOG"; }
  sleep 2
done
# 等待首页第一帧与示例数据落盘
sleep 4
log "App 已启动。日志：$FLUTTER_LOG"

# --- 3. 逐屏抓图 -------------------------------------------------------------
for item in "${SCREENS[@]}"; do
  slug="${item%%|*}"
  desc="${item#*|}"
  target="$OUT_DIR/$slug.png"
  echo
  read -r -p "→ 请在模拟器中切到「$desc」，就绪后按回车抓图（输入 s 跳过）： " ans || true
  if [[ "${ans:-}" == "s" ]]; then
    warn "跳过 $slug"
    continue
  fi
  xcrun simctl io "$UDID" screenshot "$target" >/dev/null
  dims="$(sips -g pixelWidth -g pixelHeight "$target" 2>/dev/null | awk '/pixel/{printf "%s ", $2}')"
  w="${dims%% *}"; h="${dims##* }"
  printf '   [OK] %s  %s×%s\n' "${target#$ROOT/}" "$w" "$h"
  if [[ "$w" != "$EXPECTED_W" || "$h" != "$EXPECTED_H" ]]; then
    warn "   该尺寸不是 6.9\" 规格（${EXPECTED_W}×${EXPECTED_H}）。当前机型可能是 6.7\"（1290×2796）或其他；App Store Connect 只要求上传最大尺寸那一组。"
  fi
done

log "完成，截图位于 ${OUT_DIR#$ROOT/}/"
log "下一步：按 store/screenshots_plan.md 的文案，用 Figma / Sketch / AppMockUp 等在截图外加标题与背景，导出 6.9\" 1320×2868 的最终图后上传 App Store Connect。"
