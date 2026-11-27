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
| 2026-11-27 | dark_v3 sala01 e1 (too dark), e2 (shrunk), e3 (chosen) | 3 | 5488 | 0.75 |
| 2026-11-27 | dark_v3 sala00 e1 (too dark), e2 (chosen) | 2 | 5488 | 0.50 |
| 2026-11-27 | dark_v3 antessala e1 (too dark), e2 (chosen) | 2 | 5488 | 0.50 |
| 2026-11-27 | dark_v3: 3 calls cut by the network (no image; billing unknown, at most 0.75) | 0 | - | 0 to 0.75 |

## style_v2 (2026-11-27): style approval round
`style_v2/` holds the variants Daniel is choosing from (Downloads\ASelagem-GP8\APROVAR-ESTILO). Request =
`prompt_common.txt` (full hand-painted, Hades II-like style explanation + Eterra rules, banners plain) + `room_<room>.txt`
(playable things to keep) + `variant_A.txt` (warm, faithful to the approved art) or `variant_B.txt` (graphic, darker,
colder shadows) + for the B2 redos `fit_<room>.txt` (positions as fractions of the frame). Full texts in
`prompt_<room>-<variant>.txt`; generator `style_v2/gen.sh <room> <A|B|B2>`.
Overlay test (`*_overlay.jpg`): walls, low walls, platform edge, door, water strip and spike plate fit within a few px in
A and B2; the four Sala 00 pillars, the altar and the Antessala posts drift 25 to 50 px (1536 wide), same as v1.
Giving positions as fractions (B2) fixed the Antessala water and platform but not the pillars.

In the game: `PaintedHall.ROOMS` (scripts/game/painted_hall.gd) names each file and its pose; to swap a painting replace its png in assets/rooms/painted (same 3:2 stretch of the 16:9 base, same pose).

## dark_v3 (2026-11-27): "o chão é o palco" round
Daniel's rule: mid-dark, low-saturation floor (Hades II, SWORN), warm light only in pools around flames, no banners.
Request = `dark_v3/prompt_common.txt` + `room_<room>.txt` (+ `fix_light.txt` for e2/e3: e1 came out too dark and cold;
sala01 e3 adds `fix_fit01.txt`). Full sent text in `dark_v3/<room>-<tag>.prompt.txt`; generator `dark_v3/gen.sh <room> <tag> [fix]`
(use it one call at a time, `--http1.1`: parallel calls and HTTP/2 got cut), overlay `dark_v3/overlay.sh`, floor luma `dark_v3/luma.sh`.
Chosen: sala01-e3, sala00-e2, antessala-e2 (Downloads\ASelagem-GP8\APROVAR-CHAO-ESCURO, awaiting Daniel).
Floor-centre mean luma (0-255), current -> dark: sala01 186 -> 92, sala00 134 -> 91, antessala 129 -> 68.
Fit: sala00 walls, platform edge, door fit; pillars and altar drift 15 to 40 px as in every round. Antessala platform,
water strip, spike plate and door fit; the low posts drift 25 to 50 px and some carry new small torches.
Sala01: gpt-image-2 kept the base's aspect (1924x1175 is wider than 3:2): the painting is the base scaled UNIFORMLY to
1536x938 at the top plus ~86 px of extra cliff at the bottom, not the 3:2 stretch. With that mapping e3 fits within a few px
(braziers, statues, doors, stairs, canal); with the stretch the lower half is 50 to 70 px off. The in-game v3 shows the same
behaviour (~20 px off even uniformly), so PaintedHall's sala01 mapping should be checked before swapping.
