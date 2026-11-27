# GP-8: rooms painted by gpt-image-2 over game captures (2026-11-27)

Each `<room>.png` (1536x1024) is the API's repaint of `base_<room>.png` (a 16:9 game capture, no hero, no HUD) in the
style of the approved ChatGPT art. The painting is the base frame STRETCHED to 3:2: scale it back to 16:9 and it lies
over the capture (overlay test passed for the three: walls, platform edge, door, pillars within a few px).
Requests: Downloads\ASelagem-GP8\GPT-<room>\PEDIDO-PARA-O-GPT.txt plus rule 8 (no symbols on banners). Cost ~US$0.25 each.

Painter's cameras (game flags, all --showcase --no-hero --no-hud --seed=5):
- sala01: --cam-at=2,1 --cam-dist=68 (yaw 35, pitch 30, fov 24: the "game" pose of painted_hall.gd), 1920x1080
- sala00: --start=sala00 --no-arrival --cam-at=0,0 --cam-yaw=35 --cam-pitch=30 --cam-fov=24 --cam-dist=52, 2560x1440
- antessala: --start=ante --no-arrival --cam-at=0,0 --cam-yaw=35 --cam-pitch=30 --cam-fov=24 --cam-dist=80, 2560x1440

Generation (curl; the key is read from the file, never printed):
`curl -s https://api.openai.com/v1/images/edits -H "Authorization: Bearer $(cat ~/.config/eterra/openai_key)" -F model=gpt-image-2 -F "image[]=@base.png" -F "image[]=@approved.jpg" --form-string "prompt=$P" -F size=1536x1024 -F quality=high -o out.json` then base64-decode `data[0].b64_json`.

## Cost log
| date | room | images | output tokens each | ~US$ |
|---|---|---|---|---|
| 2026-11-27 | sala00 (v1 star banners, v2 ok) | 2 | 5488 | 0.50 |
| 2026-11-27 | sala01 v1 (old door pair: to redo) | 1 | 5488 | 0.25 |
| 2026-11-27 | antessala v1 | 1 | 5488 | 0.25 |
| 2026-11-27 | style_v2 sala00 A, B1 (fog too violet, rejected), B2 | 3 | 5488 | 0.75 |
| 2026-11-27 | style_v2 antessala A, B1 (water strip ~35 px off, platform shrunk, rejected), B2 | 3 | 5488 | 0.75 |

## style_v2 (2026-11-27): style approval round
`style_v2/` holds the variants Daniel is choosing from (Downloads\ASelagem-GP8\APROVAR-ESTILO). Request =
`prompt_common.txt` (full hand-painted, Hades II-like style explanation + Eterra rules, banners plain) + `room_<room>.txt`
(playable things to keep) + `variant_A.txt` (warm, faithful to the approved art) or `variant_B.txt` (graphic, darker,
colder shadows) + for the B2 redos `fit_<room>.txt` (positions as fractions of the frame). Full texts in
`prompt_<room>-<variant>.txt`; generator `style_v2/gen.sh <room> <A|B|B2>`.
Overlay test (`*_overlay.jpg`): walls, low walls, platform edge, door, water strip and spike plate fit within a few px in
A and B2; the four Sala 00 pillars, the altar and the Antessala posts drift 25 to 50 px (1536 wide), same as v1.
Giving positions as fractions (B2) fixed the Antessala water and platform but not the pillars.
