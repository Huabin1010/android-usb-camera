#!/usr/bin/env bash
# Send a hot reload to the debug session started by scripts/dev.sh.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIPE="$ROOT/flutter_app/.run/input"
if [[ ! -p "$PIPE" ]]; then
  echo "调试会话没在跑。先执行 ./scripts/dev.sh" >&2
  exit 1
fi
printf 'r\n' > "$PIPE"
echo "已发送热重载"
