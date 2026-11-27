#!/bin/bash
# usage: gen.sh room tag [extra_fix_file]  (room: sala01|sala00|antessala)
set -e
R=$1; T=$2; X=$3; H=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt; D=/mnt/c/Users/danie/Downloads/ASelagem-GP8
case $R in sala01) AP=$D/GPT-Sala01;; sala00) AP=$D/GPT-Sala00;; *) AP=$D/GPT-Antessala;; esac
AP=$AP/2-arte-aprovada-ANEXAR.jpg
P="$(cat $H/dark_v3/prompt_common.txt; echo; cat $H/dark_v3/room_$R.txt; if [ -n "$X" ]; then echo; cat $X; fi)"
O=$H/dark_v3/${R}-${T}
printf '%s\n' "$P" > $O.prompt.txt
curl -sS --http1.1 --max-time 400 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 -F "image[]=@$H/base_$R.png" -F "image[]=@$AP" --form-string "prompt=$P" \
  -F size=1536x1024 -F quality=high -o $O.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$O.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$O.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$R $T ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $O.json
