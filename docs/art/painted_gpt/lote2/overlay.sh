#!/bin/bash
# usage: overlay.sh room tag -> <room>-<tag>_overlay.jpg (3:2 stretch) and _overlay_uniform.jpg (base scaled uniformly to 1536x938 at the top)
H=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt; L=$H/lote2
ffmpeg -loglevel error -y -i $L/$1-$2.png -i $H/base_$1.png -filter_complex "[0]format=rgb24[a];[1]scale=1536:1024,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $L/$1-$2_overlay.jpg
ffmpeg -loglevel error -y -i $L/$1-$2.png -i $H/base_$1.png -filter_complex "[0]format=rgb24[a];[1]scale=1536:938,pad=1536:1024:0:0,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $L/$1-$2_overlay_uniform.jpg
