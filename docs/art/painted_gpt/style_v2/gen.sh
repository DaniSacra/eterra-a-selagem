#!/bin/bash
# usage: gen.sh room variant  (room: sala00|antessala; variant: A|B)
set -e
R=$1; V=$2; H=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt; D=/mnt/c/Users/danie/Downloads/ASelagem-GP8
[ $R = sala00 ] && AP=$D/GPT-Sala00/2-arte-aprovada-ANEXAR.jpg || AP=$D/GPT-Antessala/2-arte-aprovada-ANEXAR.jpg
P="$(cat $H/style_v2/prompt_common.txt; echo; cat $H/style_v2/room_$R.txt; echo; cat $H/style_v2/variant_${V%2}.txt; [ "${V#?}" = 2 ] && { echo; cat $H/style_v2/fit_$R.txt; })"
O=$H/style_v2/${R}-${V}
curl -s https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 -F "image[]=@$H/base_$R.png" -F "image[]=@$AP" --form-string "prompt=$P" \
  -F size=1536x1024 -F quality=high -o $O.json
python3 -c "
import json,base64,sys
d=json.load(open('$O.json'))
if 'data' not in d: print('ERR',json.dumps(d)[:400]); sys.exit(1)
open('$O.png','wb').write(base64.b64decode(d['data'][0]['b64_json']))
print('$R $V ok', d.get('usage',{}).get('output_tokens'))
"
rm -f $O.json
