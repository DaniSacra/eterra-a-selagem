#!/bin/bash
# overlay.sh sheet.png out.png : the 6 cells stacked with 'lighten', each frame tinted a different hue for the drift check
S=$1; O=$2
ffmpeg -v error -y -i $S -filter_complex "[0]scale=1536:1024,split=6[a][b][c][d][e][f];\
[a]crop=512:512:0:0,colorchannelmixer=1:0:0:0:0:0:0:0:0:0:0:0[A];[b]crop=512:512:512:0,colorchannelmixer=0:0:0:0:0:1:0:0:0:0:0:0[B];\
[c]crop=512:512:1024:0,colorchannelmixer=0:0:0:0:0:0:0:0:0:0:1:0[C];[d]crop=512:512:0:512,colorchannelmixer=1:0:0:0:0:1:0:0:0:0:0:0[D];\
[e]crop=512:512:512:512,colorchannelmixer=0:0:0:0:0:1:0:0:0:0:1:0[E];[f]crop=512:512:1024:512[F];\
[A][B]blend=all_mode=lighten[ab];[ab][C]blend=all_mode=lighten[abc];[abc][D]blend=all_mode=lighten[abcd];[abcd][E]blend=all_mode=lighten[abcde];[abcde][F]blend=all_mode=lighten,drawbox=x=255:y=255:w=3:h=3:c=white" $O
