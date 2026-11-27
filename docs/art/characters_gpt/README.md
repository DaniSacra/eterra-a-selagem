# Characters from Daniel's ChatGPT pack, fixed and Meshy-ready (2026-11-27)

`src/` = Daniel's pack (enemy crops are from `src/enemies.jpg`). `in/` = the inputs sent (enemy crops upscaled to 1080 px
high, lanczos). `prompts/`: `common.txt` (style + Eterra rules, prefixed to every call), `A_<nn>.txt` (concept fix),
`meshy_common.txt` + `B_<nn>.txt` (front A-pose), `back_common.txt` + `C_<nn>.txt` (hero backs), `*_fix.txt` (redos),
`full_*.txt` the concatenations. `out/<nn>-<tag>.png` + `.prompt.txt` = every raw output with the exact text sent.
`gen.sh <name> <tag> <input> <prompt_file>`: `/v1/images/edits`, gpt-image-2, 1024x1536, high, one call at a time, `--http1.1`.
B views use the chosen A as the input image (C2 of the Maga used her B1 front).

`final/` = the picks sent to Downloads\ASelagem-GP8\APROVAR-PERSONAGENS (+ `todos.jpg`, `LEIA.txt`):
01-03, 05, 06, 08 concept A1 + front B1; 04 A1 + B2; 07 A2 + B2 + back C1; 08 back C2.
Fixes: Guard shield plain wood with iron rim, two bands and a round boss (was a sun); Priest no halo, staff a plain iron
crook with a yellow-green lantern (was a spiked ring); violet removed from Mage hat/robe, Priest, Warrior cape/trousers,
Maga skirts/sash; Warrior chest symbol removed (a small lion was tried, read as a sun, removed in A2); undead glow yellow-green.
22 images, ~US$5.50. Awaiting Daniel. No Meshy credits spent. `docs/steam-ia.md` gets them if they enter the game.

## Part 2 (2026-11-27): 09 Knight, 10 Elder, 11 Morvath
No pack art: `in/<nn>_old.png` = the old Meshy refs (`tools/meshy/ref/enemies/<id>/threequarter.png`), sent as image 2;
image 1 = an approved concept as style ref (Guard for the Knight, Priest for the Elder and Morvath). `gen.sh` now takes
extra images after the prompt file and `COMMON=` to swap the rule header (`prompts/common_morvath.txt` allows violet on
him only). Prompts `A_/B_/C_` 09 to 11 and `full_*`. Violet removed from the Knight and the Elder (Elder oxblood, bone,
ochre, amber gem); guardian eyes and magic yellow-green; Morvath keeps violet, scythe, white hair, frost hem (canon:
death and endless winter). Picks all first try (A1, B1, C1) in `final/` + `todos_2.jpg` + `LEIA_2.txt`; sent to
Downloads\ASelagem-GP8\APROVAR-PERSONAGENS-2. 7 images, ~US$1.75. No Meshy credits spent.
