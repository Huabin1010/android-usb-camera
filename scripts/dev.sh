#!/usr/bin/env bash
# Debug session with hot reload.
#   r  hot reload
#   R  hot restart
#   q  quit
# Saving a Dart file under flutter_app/lib also hot reloads.
# Another terminal can run ./scripts/reload.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE="${1:-}"
if [[ -z "$DEVICE" ]]; then
  DEVICE="$(adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')"
fi
if [[ -z "$DEVICE" ]]; then
  echo "没有连接安卓设备。插上手机并允许 USB 调试后再运行。" >&2
  exit 1
fi

echo "调试设备: $DEVICE"
echo "这是 debug 模式。保存 flutter_app/lib 里的 Dart 文件会热重载。"
echo "这个终端也可以直接按 r 热重载、R 热重启、q 退出。另一个终端可执行 ./scripts/reload.sh"
exec python3 "$ROOT/scripts/dev.py" "$DEVICE"
