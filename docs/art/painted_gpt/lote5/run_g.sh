#!/bin/bash
# usage: run_g.sh room:approvalTag ...
cd /home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote5
for p in "$@"; do r=${p%%:*}; a=${p##*:}
 ./gen.sh $r-g1 $r-$a.png - game_common.txt game_$r.txt || echo FAIL $r; done
