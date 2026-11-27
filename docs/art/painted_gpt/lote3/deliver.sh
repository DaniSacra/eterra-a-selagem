#!/bin/bash
# usage: deliver.sh salaNN base_png approval_png game_png leia_txt
L=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote3; cd $L
S=$1; D=/mnt/c/Users/danie/Downloads/ASelagem-GP8/GPT-${S^}
cp $3 ${S}_aprovacao.png; cp $4 ${S}_jogo.png
ffmpeg -loglevel error -y -i $2 -i $3 -i $4 -filter_complex "[0]scale=1024:625,pad=1024:683:0:0[a];[1]scale=1024:683[b];[2]scale=1024:683[c];[a][b][c]hstack=3" -q:v 3 ${S}_lado_a_lado.jpg
mkdir -p $D; cp ${S}_aprovacao.png ${S}_jogo.png ${S}_lado_a_lado.jpg $D/; cp $5 $D/LEIA.txt
echo "$S pronta: $D" >> /tmp/claude-1000/-home-dani-games-eterra-a-selagem/32bdc047-6648-4c60-8ea4-608051fcc718/scratchpad/rooms_ready.txt
ls $D
