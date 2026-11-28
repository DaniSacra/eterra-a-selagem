#!/bin/bash
# usage: SIZE=1536x1024 gen.sh <name> <img1> [img2|-] <prompt files...> -> out/<name>.png (+ .prompt.txt). One call at a time.
set -e
D=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt/cap2; mkdir -p $D/out
N=$1; I1=$2; I2=$3; shift 3
P="$(for f in "$@"; do cat $f; echo; done)"
printf '%s\n' "$P" > $D/out/$N.prompt.txt
IMG=(-F "image[]=@$I1"); [ "$I2" != "-" ] && IMG+=(-F "image[]=@$I2")
curl -sS --http1.1 --max-time 400 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 "${IMG[@]}" --form-string "prompt=$P" -F size=${SIZE:-1536x1024} -F quality=high -o $D/out/$N.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$D/out/$N.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$D/out/$N.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$N ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $D/out/$N.json
