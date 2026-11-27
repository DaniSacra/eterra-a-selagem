#!/bin/bash
# usage: diff.sh approval game out.jpg  (amplified difference; fixed pieces must not show double edges)
ffmpeg -loglevel error -y -i $1 -i $2 -filter_complex "[0]format=rgb24[a];[1]format=rgb24[b];[a][b]blend=all_mode=difference,curves=all='0/0 0.35/1 1/1'" -q:v 4 $3
