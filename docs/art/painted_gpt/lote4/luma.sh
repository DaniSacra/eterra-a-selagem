#!/bin/bash
# floor-centre luma (box 40-60% x 45-60%) of each image
for f in "$@"; do
  v=$(ffmpeg -loglevel error -i $f -vf "crop=iw*0.2:ih*0.15:iw*${X:-0.4}:ih*${Y:-0.45},format=gray,scale=1:1:flags=area" -f rawvideo - | od -An -tu1 | tr -d ' ')
  echo "$f $v"
done
