#!/bin/bash
# cut_icon.sh src.png cellW cellH cellX cellY out.png  -> 128x128 keyed (black -> alpha by luminance)
set -e
S=$1; W=$2; H=$3; X=$4; Y=$5; O=$6
BB=$(ffmpeg -hide_banner -loop 1 -i $S -frames:v 2 -vf "crop=$W:$H:$X:$Y,cropdetect=limit=5:round=2:skip=0" -f null - 2>&1 | grep -o 'crop=[0-9:]*' | tail -1 | cut -d= -f2)
IFS=: read w h x y <<<"$BB"
s=$(( (w>h?w:h) * 108 / 100 )); cx=$((X+x+w/2)); cy=$((Y+y+h/2)); x0=$((cx-s/2)); y0=$((cy-s/2))
ffmpeg -v error -y -i $S -vf "format=rgb24,pad=iw+1200:ih+1200:600:600:black,crop=$s:$s:$((x0+600)):$((y0+600)),scale=128:128:flags=lanczos,format=rgba,geq=a='min(255,3*max(max(r(X,Y),g(X,Y)),b(X,Y)))':r='min(255,r(X,Y)*255/max(1,min(255,3*max(max(r(X,Y),g(X,Y)),b(X,Y)))))':g='min(255,g(X,Y)*255/max(1,min(255,3*max(max(r(X,Y),g(X,Y)),b(X,Y)))))':b='min(255,b(X,Y)*255/max(1,min(255,3*max(max(r(X,Y),g(X,Y)),b(X,Y)))))'" $O
echo "$O bbox $BB side $s"
