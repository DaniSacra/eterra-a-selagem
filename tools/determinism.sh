#!/bin/sh
# Same seed, same bot, same RESULT: runs a short smoke N times (default 3) and compares the lines without fps and step_ms.
# Usage: tools/determinism.sh [runs] [seconds] [extra game args]
runs="${1:-3}"; secs="${2:-30}"; [ $# -gt 1 ] && shift 2 || shift $#
cd "$(dirname "$0")/.." || exit 1
first=""; bad=0; i=1
while [ "$i" -le "$runs" ]; do
	line=$("${GODOT:-$HOME/tools/godot/godot}" --headless --path . -- --bot --nosave --seed=5 --smoke="$secs" "$@" 2>&1 \
		| grep '^RESULT' | sed -E 's/"(fps|step_ms[a-z_]*)":[0-9.]+//g')
	[ -z "$line" ] && { echo "run $i: no RESULT"; exit 1; }
	[ -z "$first" ] && first="$line"
	[ "$line" = "$first" ] || { echo "run $i differs"; bad=1; }
	i=$((i + 1))
done
[ "$bad" = 0 ] && echo "DETERMINISTIC ($runs runs)" || { echo "NOT DETERMINISTIC"; exit 1; }
