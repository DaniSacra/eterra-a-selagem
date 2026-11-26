# Créditos de recursos externos (texturas, modelos, sons)

Tudo que entra no jogo vindo de fora fica registrado aqui: peça, arquivo, autor, fonte, licença e data. Só CC0 ou
licença equivalente verificada na página do recurso. Nada gerado por IA nesta lista (o que for de IA vai para
`docs/steam-ia.md`).

## Texturas

| Peça | Arquivos | Autor e fonte | Licença | Data | Uso |
|---|---|---|---|---|---|
| Rock Surface | `assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg`, `rock_surface_disp_1k.jpg` (1K) | Amal Kumar, Poly Haven (https://polyhaven.com/a/rock_surface) | CC0 1.0 Universal (página do recurso e https://polyhaven.com/license) | 2026-11-14 | Só relevo: o normal e o deslocamento modulam a cor pintada do chão (`catacomb_floor.gdshader`) e da cantaria (`masonry.gdshader`); a cor continua a nossa. Licença em `assets/textures/rock_surface/LICENSE.txt`. |

## Modelos e fontes

| Peça | Arquivos | Autor e fonte | Licença | Uso |
|---|---|---|---|---|
| KayKit Dungeon Remastered, Adventurers e Skeletons | `assets/models/dungeon/`, `dungeon_r/`, `characters/`, `weapons/` | Kay Lousberg (kaylousberg.com) | CC0 | cenário provisório, armas presas aos inimigos (`tools/bake.gd`, `held`), a gente do hub (`NPCS`) |
| Universal Animation Library 1 e 2 | `assets/models/anim/` | Quaternius (quaternius.com) | CC0 | clipes do herói (`tools/bake_hero.gd`) e dos inimigos (`tools/bake.gd`) |
| Cinzel, Alegreya Sans | `assets/fonts/` | The Cinzel Project Authors (github.com/NDISCOVER/Cinzel); The Alegreya Sans Project Authors (Huerta Tipográfica) | SIL Open Font License 1.1 | toda a interface |

Modelos do Meshy (herói, inimigos, Emeth) são de IA: `docs/steam-ia.md`.

## Sons e músicas

Lista por arquivo em `audio/LICENSES.md` (fonte da verdade): Kenney (Impact Sounds, RPG Audio; CC0), Iwan Gabovitch
(qubodup, Swish; CC0), rubberduck (CC0), Little Robot Sound Factory (Fantasy Sound Effects Library; **CC BY 3.0**) e
Kevin MacLeod ("Tempting Secrets", "Achaidh Cheide", "Thatched Villagers", "Oppressive Gloom", "The Descent", "Heroic Age", "Ossuary 5 - Rest", "Clash Defiant"; **CC BY 4.0**). Os dois CC BY
estão no `CREDITOS.txt` ao lado do exe. Música própria, Salmos, vitória e ambiência: síntese do projeto
(`tools/make_music.gd`, `tools/make_ambience.gd`).
