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
| 2026-11-27 | VFX lote 1 (generations, no ref): cut1 v1 (ellipse, drift), cut1 v2, cut2 v1, spin v1, smash v1 (radial stripes read as sun rays, rejected), smash v2, contact v1, hit_ring v1 | 8 | 5488 | 2.00 |
| 2026-11-27 | characters (edits 1024x1536, `docs/art/characters_gpt/`): 8 concepts A1, 8 Meshy fronts B1, 2 hero backs C1; redos: Warrior A2+B2 (chest lion read as a sun), Guard B2 (lost bulk), Maga C2 (staff on wrong side, spear tip) | 22 | 5488 | 5.50 |
| 2026-11-27 | HUD v3 kit (`docs/art/hud_v3/`): icons_a (6 icons), icons_b (attack + smash redo: first smash fanned up like a burst, first attack read as an arrow), frames_a (slot, rings), frames_b (bar, cartouche, divider, medallions), portrait (1024x1024, 7024 tokens) | 5 | 5488 (portrait 7024) | 1.30 |
| 2026-11-27 | lote2 (`lote2/`): crypt1 e1 (floor too dark, luma 48), e2 (chosen, sala02); rift e1 (chosen, sala03), e2 (left side 35 to 50 px off); garden e1 (statue niche became a 3rd arch), e2 (platform grew), e3 (chosen, sala04) | 7 | 5488 | 1.75 |

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

## VFX painted sheets, lote 1 (2026-11-27)
Guide: `docs/art/vfx_painted_style.md`. Files in `docs/art/vfx_painted/`: `prompt_common.txt` + `<fx>.txt` + fix files,
full sent text in `<fx>-<tag>.prompt.txt`, raw output `<fx>-<tag>.png`, generator `gen.sh <fx> <tag> [fix]`
(`/v1/images/generations`, one call at a time, `--http1.1`). The final sheets (`cut1, cut2, spin (4x2 2048x1024),
smash, contact, hit_ring .png`) are the raw output after a post pass: near-black (<=12) crushed to 0 and each cell moved
(and for spin/smash scaled) so the pivot sits at the cell centre: `register.py` (circle fitted to the outer edge, arcs
and rings), `fan.py` (smash: top of arc + half-width), `point.py` (spark core). gpt-image-2 drifts 15 to 50 px per cell;
after the pass the outer edges fall within a few px (`<fx>_overlay.png`, the 6 frames tinted and stacked).
Spin frames 7 and 8 are frame 6 at 55% and 25% (no extra call). Previews `<fx>_preview.gif` (`preview.py`): guide
colours over a floor crop of sala01, real time then 4x slower. Plan B not needed. Deviations: the cut arcs span about
210 to 240 degrees (asked 150) and the smash fan's inner edge sits ~25 px above the pivot. Sent to
Downloads\ASelagem-GP8\APROVAR-EFEITOS (awaiting Daniel); `docs/steam-ia.md` gets them when they enter the game.

## Base captures, lote 2 (2026-11-27): Cripta A, Fendas A, Jardim A
All with `--start=combat --arena=<id> --variant=<n> --no-arrival --doors-shut --no-hero --no-hud --no-angels --showcase
--cam-yaw=35 --cam-pitch=30 --cam-fov=24 --seed=5 --shot-at=0.5`, RES=2560x1440 (saved 1924x1175):
- crypt variant 1 (Cripta A, Ossário): --cam-at=0,0 --cam-dist=60 -> base_crypt1.png
- rift variant 0 (Fendas A): --cam-at=-7,-2 --cam-dist=84 -> base_rift.png
- garden variant 0 (Jardim A): --cam-at=3,0 --cam-dist=82 -> base_garden.png
`--start=combat` (new) enters the first fight room, so `--arena` takes effect outside the guided first descent.

## Lote 2 paintings (2026-11-27): Sala02 Cripta A, Sala03 Fendas A, Sala04 Jardim A
Request = `lote2/prompt_common.txt` (dark_v3 rules; image 2 = `assets/rooms/painted/sala01.png` as the STYLE of another
room) + `lote2/room_<base>.txt` + `fix_light.txt` (+ the room's `fix_fit_*.txt` on retries); sent text in
`lote2/<base>-<tag>.prompt.txt`. Generator `lote2/gen.sh <crypt1|rift|garden> <tag> [fix files]`, overlays
`lote2/overlay.sh` (`_overlay.jpg` = 3:2 stretch, `_overlay_uniform.jpg` = base scaled to 1536x938 at the top, like sala01).
Chosen: `lote2/sala02.png` (crypt1-e2), `sala03.png` (rift-e1), `sala04.png` (garden-e3), side-by-sides `sala0N_lado_a_lado.jpg`;
copies in Downloads\ASelagem-GP8\GPT-Sala02..04 (awaiting Daniel).
Floor-centre luma: 62, 55, 51 (sala01 dark = 86, antessala 68): darker than Sala 01; brighten in a post pass if Daniel wants.
Fit: the bases are 1924x1175 like sala01, so the model keeps the aspect: Cripta and Fendas fit with the UNIFORM mapping
(walls, doors, statue, platform edge within a few px; Cripta tombs, grates and column 10 to 15 px; Fendas bridges 15 to 20 px,
water and columns 5 to 10 px). Jardim e3 fits the 3:2 STRETCH better (walls, tree, column, altar ~20 px; statue ~25 px;
right braziers ~40 px; platform edge ~20 to 30 px inside the base). PaintedHall must use the matching mapping per room.
Rules checked on all three: no banners (lion banners removed), no sun, star, cross or symbol, no text, no figures,
doors shut and unlit, void blue-slate (R ~ G < B, not violet), no emerald (garden crystals now ice blue), doors only
where the base has them, with a wall pier (Cripta, Fendas also a brazier) or the statue niche (Jardim) between them.

