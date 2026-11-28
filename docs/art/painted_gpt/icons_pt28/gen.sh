#!/bin/bash
# usage: gen.sh <sheet index> <tag> [style ref png|-] [extra prompt file]  -> sheets/s<NN>-<tag>.png (+ .prompt.txt), log in costs.log
set -e
D=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/icons_pt28; cd $D
N=$(printf %02d $1); TAG=$2; REF=${3:--}; EXTRA=$4
NAME=sheets/s$N-$TAG
P="$(python3 -I build.py $1 prompt $EXTRA)"; [ -n "$SUBJ" ] && NAME=sheets/fix$N-$TAG
[ "$REF" != "-" ] && P="$P
A imagem 2 é uma folha de ícones já aprovada deste mesmo jogo: siga o MESMO estilo de pintura, a mesma espessura de pincel, a mesma luz e o mesmo tamanho de objeto dentro do miolo. Não copie os objetos dela."
printf '%s\n' "$P" > $NAME.prompt.txt
IMG=(-F "image[]=@template.png"); [ "$REF" != "-" ] && IMG+=(-F "image[]=@$REF")
curl -sS --http1.1 --max-time 400 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 "${IMG[@]}" --form-string "prompt=$P" -F size=1536x1024 -F quality=high -o $NAME.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$NAME.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$NAME.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
t=d.get('usage',{}).get('output_tokens'); print('$NAME ok', t)
open('costs.log','a').write('$NAME %s\n'%t)
"
rm -f $NAME.json
