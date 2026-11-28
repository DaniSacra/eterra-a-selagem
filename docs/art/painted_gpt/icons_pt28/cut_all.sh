#!/bin/bash
# cut_all.sh [tag per sheet: file chosen.txt "NN tag" lines; default a] -> assets/ui/<rewards|boons>/<id>.png
D=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/icons_pt28; cd $D
for i in $(seq 0 26); do
  N=$(printf %02d $i); T=$(grep "^$N " chosen.txt 2>/dev/null | cut -d' ' -f2); T=${T:-a}
  ~/tools/godot/godot --headless -s frame.gd -- cut $D/sheets/s$N-$T.png /home/dani/games/eterra-a-selagem/assets/ui "$(python3 -I build.py $i names)" 2>&1 | grep '^cut'
done
