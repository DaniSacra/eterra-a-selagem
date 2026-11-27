#!/bin/bash
cd /home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote5
for r in runes0 runes1; do
 ./gen.sh $r-a2c bases/${r}_crop.png ../../../../assets/rooms/painted/sala01.png prompt_common.txt room_${r}_crop.txt || echo FAIL $r
 ffmpeg -loglevel error -y -i $r-a2c.png -i bases/${r}_crop.png -filter_complex "[0]format=rgb24[a];[1]scale=1536:1024,format=rgb24[b];[a][b]blend=all_mode=average" -q:v 3 $r-a2c_overlay.jpg
 ./gen.sh $r-g1c $r-a2c.png - game_common.txt game_$r.txt || echo FAIL $r
done
