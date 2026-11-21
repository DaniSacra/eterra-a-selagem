#!/bin/bash
# Runs the game on the real GPU from WSL: the Windows build of Godot (same version) talks Vulkan to the NVIDIA card,
# which WSL's Linux Godot cannot (no Vulkan driver for WSL in Ubuntu: it falls back to llvmpipe, 2 to 4 min a shot).
# The project is mirrored to the Windows drive (the Windows Godot reads it there fast; its .godot cache stays there).
#   tools/gpu.sh shot out.png [game options...]      one capture (Forward+, 1672x941 unless RES=WxH), about 15 s
#   tools/gpu.sh run [godot args...]                 anything else, e.g. tools/gpu.sh run -s tools/enemy_lab.gd -- C:/x
#   tools/gpu.sh sync                                mirror and reimport only
# At most GPU_SLOTS runs at a time (default 2, Daniel 2026-11-19; slot 1 uses its own mirror, eterra-gpu2), others wait. A game window shows on the desktop while it runs. Paths given to the game are Windows paths (C:/...): `shot` turns
# out.png into one and copies the result back. GODOT_WIN and MIRROR override the defaults below.
set -e
GODOT_WIN=${GODOT_WIN:-/mnt/c/Users/danie/tools/godot/Godot_v4.7.2-stable_win64_console.exe}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
win() { wslpath -w "$1"; }
# GPU_SLOTS runs at a time, each slot with its own mirror (two runs on one mirror would sync under each other); the
# PC rebooted with a display-driver crash (0x116) with more at once, so keep it small
SLOTS=${GPU_SLOTS:-2}
slot=""
while [ -z "$slot" ]; do
	for i in $(seq 0 $((SLOTS - 1))); do
		exec 9>"/tmp/eterra-gpu.$i.lock"
		if flock -n 9; then slot=$i; break; fi
		exec 9>&-
	done
	[ -z "$slot" ] && sleep 2
done
if [ "$slot" = 0 ]; then MIRROR=${MIRROR:-/mnt/c/Users/danie/tools/eterra-gpu}; else MIRROR=${MIRROR:-/mnt/c/Users/danie/tools/eterra-gpu$((slot + 1))}; fi
mkdir -p "$MIRROR"

sync() {
	rsync -a --delete --exclude .git --exclude .claude --exclude .godot --exclude build --exclude 'assets/models/meshy/*/*-v[0-9]*' "$ROOT/" "$MIRROR/"
	"$GODOT_WIN" --headless --path "$(win "$MIRROR")" --import >/dev/null 2>&1 || true
}

cmd=$1; shift || true
case "$cmd" in
	sync) sync ;;
	shot)
		out=$1; shift
		sync
		tmp="$MIRROR/.shot_$$.png"
		"$GODOT_WIN" --path "$(win "$MIRROR")" --rendering-driver vulkan --resolution "${RES:-1672x941}" --fixed-fps 30 \
			-- --nosave --shot="$(win "$tmp")" "$@" 2>&1 | grep -E "Using Device|SCRIPT ERROR|RESULT" || true
		mv "$tmp" "$out"
		echo "saved $out"
		;;
	run)
		sync
		"$GODOT_WIN" --path "$(win "$MIRROR")" "$@"
		;;
	*) sed -n 2,10p "$0" ;;
esac
