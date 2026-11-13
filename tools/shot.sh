#!/bin/sh
# Runs the game on a virtual display and saves a 1280x720 screenshot (and --frames=prefix --count=N --every=s for a sequence): tools/shot.sh out.png [seconds] [extra game args]
out="$1"; at="${2:-2}"; shift; shift
timeout 180 xvfb-run -a "${GODOT:-$HOME/tools/godot/godot}" --path "$(dirname "$0")/.." --rendering-driver opengl3 --resolution 1280x720 -- --shot="$out" --shot-at="$at" --nosave "$@" 2>&1 | grep -E "SCRIPT ERROR|ERROR: |res://|RESULT" | grep -v -E "alsa|ALSA|audio" | head -30
