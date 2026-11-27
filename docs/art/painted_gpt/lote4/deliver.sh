#!/bin/bash
# usage: deliver.sh NN prefix base_png approval_png game_png leia_txt   (prefix: sala02_v2 or sala08)
L=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/lote4; cd $L
N=$1; S=$2; D=/mnt/c/Users/danie/Downloads/ASelagem-GP8/GPT-Sala$N
cp $4 ${S}_aprovacao.png; cp $5 ${S}_jogo.png
ffmpeg -loglevel error -y -i $3 -i $4 -i $5 -filter_complex "[0]scale=1024:625,pad=1024:683:0:0[a];[1]scale=1024:683[b];[2]scale=1024:683[c];[a][b][c]hstack=3" -q:v 3 ${S}_lado_a_lado.jpg
mkdir -p $D; cp ${S}_aprovacao.png ${S}_jogo.png ${S}_lado_a_lado.jpg $D/
if [[ $S == *_v2 ]]; then cp $6 $D/LEIA_v2.txt; else cp $6 $D/LEIA.txt; fi
echo "GPT-Sala$N pronta ($S): $D" >> /tmp/claude-1000/-home-dani-games-eterra-a-selagem/32bdc047-6648-4c60-8ea4-608051fcc718/scratchpad/rooms_ready.txt
ls $D
