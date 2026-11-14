#!/bin/sh
# A frozen still of one finisher in the middle of the crowd, for judging the look: tools/lab.sh out.png [extra game args]
# Later options win, so e.g. tools/lab.sh lab.png --lab-t=0.2 --cam-pitch=40 overrides the defaults below.
out="${1:-lab.png}"; [ $# -gt 0 ] && shift
timeout 180 xvfb-run -a "${GODOT:-$HOME/tools/godot/godot}" --path "$(dirname "$0")/.." --rendering-driver opengl3 --resolution 1280x720 -- \
	--lab --lab-t=0.42 --look=warm --cam-dist=44 --cam-pitch=50 --cam-fov=32 --outline=1 --shot="$out" --shot-at=4 --nosave "$@" 2>&1 \
	| grep -E "SCRIPT ERROR|ERROR: res|res://|RESULT" | head -30
