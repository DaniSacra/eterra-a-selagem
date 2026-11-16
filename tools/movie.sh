#!/bin/bash
# Records a video with sound on the real GPU (Godot's Movie Maker, Forward+), at the size asked (1920x1080 by default).
#   tools/movie.sh out.avi <frames> [game options...]      e.g. tools/movie.sh C:/x/luta.avi 600 --bot --seed=5
# out.avi is a Windows path (C:/...). FPS (30) and RES (1920x1080) override; MIRROR as in tools/gpu.sh; PRE adds engine
# options before the game's (e.g. PRE="-s res://tools/feel_driver.gd" for the game feel videos).
# Why not `tools/gpu.sh run --write-movie --resolution 1920x1080`: the Movie Maker takes its size from the project's
# window size (1280x720), not from --resolution, so the mirror gets an override.cfg with the window override; and the
# game sets the window back to the saved size (App.apply_options) unless --shot or --frames is given, so a --frames that
# never fires (--shot-at far away, --count=0) keeps it (it does not silence the sound, unlike --shot).
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
MIRROR=${MIRROR:-/mnt/c/Users/danie/tools/eterra-gpu}
GODOT_WIN=${GODOT_WIN:-/mnt/c/Users/danie/tools/godot/Godot_v4.7.2-stable_win64_console.exe}
RES=${RES:-1920x1080}
out=$1; frames=$2; shift 2
MIRROR="$MIRROR" "$ROOT/tools/gpu.sh" sync
exec 9>/tmp/eterra-gpu.lock
flock 9
printf '[display]\n\nwindow/size/window_width_override=%s\nwindow/size/window_height_override=%s\n' "${RES%x*}" "${RES#*x}" \
	> "$MIRROR/override.cfg"
"$GODOT_WIN" --path "$(wslpath -w "$MIRROR")" --rendering-driver vulkan --fixed-fps "${FPS:-30}" $PRE --write-movie "$out" \
	--quit-after "$frames" -- --nosave --frames=C:/never --shot-at=1000000 --count=0 "$@" 2>&1 \
	| grep -E "Movie Maker|SCRIPT ERROR|RESULT|CAM_TRACE|FEEL" || true
rm -f "$MIRROR/override.cfg"
