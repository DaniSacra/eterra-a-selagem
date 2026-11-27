#!/bin/bash
# usage: gen.sh name img1 [img2|-] prompt_file...   -> lote3/<name>.png (+ .prompt.txt). One call at a time.
# approval: gen.sh knight-a1 ../base_knight_hall.png <sala01.png> prompt_common.txt room_knight.txt
# game:     gen.sh knight-g1 knight-a1.png - game_common.txt game_knight.txt
set -e
L=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/game_v1; cd $L
N=$1; I1=$2; I2=$3; shift 3
P="$(for f in "$@"; do cat $f; echo; done)"
printf '%s\n' "$P" > $N.prompt.txt
IMG=(-F "image[]=@$I1"); [ "$I2" != "-" ] && IMG+=(-F "image[]=@$I2")
curl -sS --http1.1 --max-time 400 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 "${IMG[@]}" --form-string "prompt=$P" -F size=1536x1024 -F quality=high -o $N.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$N.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$N.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$N ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $N.json
