#!/bin/bash
cd /home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote5
for pair in crypt0:crypt_0 rift0:rift_0 rift1:rift_1 garden0:garden_0 sanctuary0:sanctuary_0 knight_hall:knight_hall elder_hall:elder_hall trial:trial; do
 b=${pair%%:*}; k=${pair##*:}
 ./gen.sh $b-e1 ../../../../assets/rooms/painted/$k.png bases/${b}_al.png entry_common.txt entry_$b.txt || echo FAIL $b
done
