#!/bin/bash
# usage: gen.sh effect tag [extra_fix_file]  (effect: cut1|cut2|spin|smash|contact|hit_ring)  one call at a time
set -e
E=$1; T=$2; X=$3; H=/home/dani/games/eterra-a-selagem/docs/art/vfx_painted
P="$(cat $H/prompt_common.txt; echo; cat $H/$E.txt; if [ -n "$X" ]; then echo; cat $X; fi)"
O=$H/${E}-${T}
printf '%s\n' "$P" > $O.prompt.txt
curl -sS --http1.1 --max-time 400 https://api.openai.com/v1/images/generations -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -H "Content-Type: application/json" -d @<(python3 -I -c "import json,sys; print(json.dumps({'model':'gpt-image-2','prompt':sys.argv[1],'size':'1536x1024','quality':'high'}))" "$P") -o $O.json
python3 -I -c "
import json,base64,sys
d=json.load(open('$O.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$O.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$E $T ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $O.json
