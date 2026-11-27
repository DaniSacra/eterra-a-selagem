#!/bin/bash
cd /home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote5
P=../../../../assets/rooms/painted
./run_g.sh crypt1:a1 garden1:a1 sanctuary1:a1
./gen.sh bridge0-e1 $P/bridge_0.png bases/bridge0_al.png entry_common.txt entry_bridge0.txt || echo FAIL
./gen.sh bridge1-a2 ../lote4/bridge1-a1.png bases/bridge1_al.png edit_bridge1.txt || echo FAIL
./gen.sh bridge1-g1 bridge1-a2.png - game_common.txt game_bridge1.txt || echo FAIL
