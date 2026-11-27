#!/bin/bash
# usage: overlay.sh name base_png -> <name>_overlay.jpg (3:2 stretch) and _overlay_uniform.jpg (1536x938 at top)
L=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote4; cd $L
ffmpeg -loglevel error -y -i $1.png -i $2 -filter_complex "[0]format=rgb24[a];[1]scale=1536:1024,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $1_overlay.jpg
ffmpeg -loglevel error -y -i $1.png -i $2 -filter_complex "[0]format=rgb24[a];[1]scale=1536:938,pad=1536:1024:0:0,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $1_overlay_uniform.jpg
