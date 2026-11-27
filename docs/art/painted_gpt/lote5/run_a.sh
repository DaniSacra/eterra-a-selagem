#!/bin/bash
# usage: run_a.sh tag room... (approval: base + sala01 style + prompt_common + room [+ fix_<room>.txt if exists])
cd /home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote5
T=$1; shift
for r in "$@"; do F=(); [ -f fix_$r.txt ] && [ "$T" != a1 ] && F=(fix_$r.txt)
 ./gen.sh $r-$T bases/$r.png ../../../../assets/rooms/painted/sala01.png prompt_common.txt room_$r.txt "${F[@]}" || echo FAIL $r
 ./overlay.sh $r-$T bases/$r.png; done
