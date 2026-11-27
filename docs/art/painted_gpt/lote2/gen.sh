#!/bin/bash
# usage: gen.sh room tag [extra_fix_file]  (room: crypt1|rift|garden). One call at a time.
set -e
R=$1; T=$2; X=$3; H=/home/dani/games/eterra-a-selagem/docs/art/painted_gpt; L=$H/lote2
AP=/home/dani/games/eterra-a-selagem/assets/rooms/painted/sala01.png
P="$(cat $L/prompt_common.txt; echo; cat $L/room_$R.txt; if [ -n "$X" ]; then echo; cat $X; fi)"
O=$L/${R}-${T}
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
