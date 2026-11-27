#!/bin/bash
# cut_piece.sh keyed.png W H X Y outW outH out.png : tight bbox of alpha in region, scale to fit outW x outH (keep aspect, centred)
K=$1; W=$2; H=$3; X=$4; Y=$5; OW=$6; OH=$7; O=$8
BB=$(ffmpeg -hide_banner -loop 1 -i $K -frames:v 2 -vf "crop=$W:$H:$X:$Y,alphaextract,cropdetect=limit=20:round=2:skip=0" -f null - 2>&1 | grep -o 'crop=[0-9:]*' | tail -1 | cut -d= -f2)
IFS=: read w h x y <<<"$BB"
ffmpeg -v error -y -i $K -vf "crop=$w:$h:$((X+x)):$((Y+y)),scale=$OW:$OH:force_original_aspect_ratio=decrease:flags=lanczos,pad=$OW:$OH:(ow-iw)/2:(oh-ih)/2:color=black@0,format=rgba" $O
echo "$O bbox $BB"
