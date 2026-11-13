#!/bin/sh
# Plays a run without a screen with the bot and prints RESULT: tools/smoke.sh [seconds] [extra game args]
secs="${1:-60}"; [ $# -gt 0 ] && shift
cd "$(dirname "$0")/.." && timeout 900 "${GODOT:-$HOME/tools/godot/godot}" --headless --path . --fixed-fps 60 -- --bot --nosave --smoke="$secs" "$@" 2>&1 | grep -E "RESULT|SCRIPT ERROR|ERROR: res|at: " | head -20
