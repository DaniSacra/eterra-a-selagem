#!/bin/sh
# Runs the game on a virtual display (Vulkan Forward+ like the desktop build; DRIVER=opengl3 for the browser look, RES=1920x1080 for another size) at a fixed 30 fps (the same game instant every run) and saves a 1280x720 screenshot (and --frames=prefix --count=N --every=s for a sequence): tools/shot.sh out.png [seconds] [extra game args]
out="$1"; at="${2:-2}"; shift; shift
timeout 180 xvfb-run -a "${GODOT:-$HOME/tools/godot/godot}" --path "$(dirname "$0")/.." --rendering-driver "${DRIVER:-vulkan}" --resolution "${RES:-1280x720}" --fixed-fps 30 -- --shot="$out" --shot-at="$at" --nosave "$@" 2>&1 | grep -E "SCRIPT ERROR|ERROR: |res://|RESULT" | grep -v -E "alsa|ALSA|audio" | head -30
