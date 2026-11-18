#!/usr/bin/env bash
set -uo pipefail
payload=$(cat)
stop_active=$(printf '%s' "$payload" | python3 -c \
  'import json,sys; d=json.load(sys.stdin); print(d.get("stop_hook_active","false"))')
if [ "$stop_active" = "True" ] || [ "$stop_active" = "true" ]; then
  exit 0
fi
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 2
if ! python -m pytest tests/ -q >/tmp/bikeshare-stop.log 2>&1; then
  echo "FAIL: tests are not green; work is not complete." >&2
  tail -20 /tmp/bikeshare-stop.log >&2
  exit 2
fi
exit 0
