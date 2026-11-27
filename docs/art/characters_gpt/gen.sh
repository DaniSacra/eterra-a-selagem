#!/bin/bash
# usage: gen.sh <name> <tag> <input.png> <prompt_file> [extra.png ...]   (COMMON=file overrides prompts/common.txt) one call at a time; writes out/<name>-<tag>.png and .prompt.txt
set -e
H=/home/dani/games/eterra-a-selagem/docs/art/characters_gpt
N=$1; T=$2; I=$3; PF=$4; shift 4
EX=(); for e in "$@"; do EX+=(-F "image[]=@$e"); done
P="$(cat ${COMMON:-$H/prompts/common.txt}; echo; cat $PF)"
O=$H/out/${N}-${T}
printf '%s\n' "$P" > $O.prompt.txt
curl -sS --http1.1 --max-time 500 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 -F "image[]=@$I" "${EX[@]}" --form-string "prompt=$P" -F size=1024x1536 -F quality=high -o $O.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$O.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$O.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$N $T ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $O.json
