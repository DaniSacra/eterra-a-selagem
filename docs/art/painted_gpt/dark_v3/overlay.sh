#!/bin/bash
# usage: overlay.sh room tag -> dark_v3/<room>-<tag>_overlay.jpg (painting averaged with the base stretched to 1536x1024)
H=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt
ffmpeg -loglevel error -y -i $H/dark_v3/$1-$2.png -i $H/base_$1.png -filter_complex "[0]format=rgb24[a];[1]scale=1536:1024,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $H/dark_v3/$1-$2_overlay.jpg
