#!/usr/bin/env bash
payload=$(cat)
command=$(printf '%s' "$payload" | python -c \
  'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))')

case "$command" in
  *cp*data/raw/*|*copy*data/raw/*|*mv*data/raw/*|*Move-Item*data/raw/*)
    echo "BLOCKED: commands that copy or move data into data/raw/ are denied." >&2
    exit 2
    ;;
esac
exit 0
