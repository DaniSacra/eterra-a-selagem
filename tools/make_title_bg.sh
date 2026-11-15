#!/bin/bash
# Rebuilds the title screen's clean art from the approved painting (docs/art/title_screen_spec.md, sections 1.2, 1.3, 3.2):
#   assets/ui/title/title_bg.png    the painting with the four painted buttons erased (the real ones are drawn over them);
#                                   pixel for pixel the reference outside the erase polygons (the script counts and says)
#   assets/ui/title/title_fill.png  a small blurred copy that fills the bands outside 16:9 (TitleBackdrop darkens it)
# The erasing is tools/make_title_bg.gd (ffmpeg's removelogo smears a 450 px button into streaks); the fill is ffmpeg.
#   tools/make_title_bg.sh [mask_out.png]      then: ~/tools/godot/godot --headless --path . --import
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DIR="$ROOT/assets/ui/title"
FILL_SIZE=160:90
FILL_BLUR=4
"${GODOT:-$HOME/tools/godot/godot}" --headless --path "$ROOT" -s tools/make_title_bg.gd ${1:+-- "$1"} 2>&1 | grep -E "TITLE_BG|ERROR"
ffmpeg -hide_banner -loglevel error -y -i "$DIR/title_bg.png" \
	-vf "scale=$FILL_SIZE:flags=area,gblur=sigma=$FILL_BLUR,format=rgb24" -frames:v 1 "$DIR/title_fill.png"
echo "written: $DIR/title_bg.png, $DIR/title_fill.png"
