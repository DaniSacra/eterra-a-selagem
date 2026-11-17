#!/bin/bash
# E5 rooms on the real GPU (Forward+), through tools/arena_lab.gd, one after the other:
#   tools/e5_shots.sh <out dir> <name>:<lab args...> [<name>:<lab args...>...]
# e.g. tools/e5_shots.sh /tmp/e5 "sanct_a:--arena=sanctuary --bare" "runes_arm:--arena=runes --state=arm --bare"
# Each capture is <out dir>/<name>.png; the lab's lines (SHADOWED LIGHTS, FRAME) are printed with the name.
# RES=WxH (default 1920x1080), DRIVER=opengl3 for the browser's renderer.
set -e
out=$1; shift
ROOT=$(cd "$(dirname "$0")/.." && pwd)
MIRROR=${MIRROR:-/mnt/c/Users/danie/tools/eterra-gpu}
mkdir -p "$out"
for spec in "$@"; do
	name=${spec%%:*}
	args=${spec#*:}
	win=$(wslpath -w "$MIRROR")
	# shellcheck disable=SC2086
	"$ROOT/tools/gpu.sh" run --rendering-driver "${DRIVER:-vulkan}" --resolution "${RES:-1920x1080}" -s tools/arena_lab.gd -- \
		"$win\\e5_$name.png" $args 2>&1 | grep -E "SHADOWED|FRAME|SCRIPT ERROR|ERROR:|ISLANDS" | sed "s/^/$name: /" || true
	cp "$MIRROR/e5_$name.png" "$out/$name.png" 2>/dev/null && echo "$name: $out/$name.png" || echo "$name: no capture"
done
