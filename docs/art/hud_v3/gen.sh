#!/bin/bash
# usage: gen.sh <name> <size> <prompt-file> <image>... ; writes docs/art/hud_v3/raw/<name>.png
set -e
cd "$(dirname "$0")"; mkdir -p raw
N=$1; S=$2; P=$(cat "$3"); shift 3
ARGS=(); for f in "$@"; do ARGS+=(-F "image[]=@$f"); done
curl -s --http1.1 --max-time 600 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" \
  -F model=gpt-image-2 "${ARGS[@]}" --form-string "prompt=$P" -F size=$S -F quality=high -o raw/$N.json
python3 -I -c "import json,base64,sys;d=json.load(open(sys.argv[1]));
print(d.get('usage') or d.get('error'));open(sys.argv[2],'wb').write(base64.b64decode(d['data'][0]['b64_json']))" raw/$N.json raw/$N.png
rm raw/$N.json
