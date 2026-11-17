# Licenças do som

Regra (D-12b): só síntese, CC0 e CC-BY com crédito aqui; nada pago. Todo CC-BY também está nos créditos do jogo
(Como Jogar, Créditos: `CreditsScreen`, textos `credits_*`). Detalhes do T5 (o que cada arquivo leva, de onde veio,
pontos de laço): `docs/design/t5_audio.md`.

## Música

| O quê | Arquivos | Autor | Licença |
|---|---|---|---|
| Título: "Tempting Secrets" (a abertura toca uma vez, o laço volta aos 16 s) | `music/title.ogg` | Kevin MacLeod, https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1300038 | CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/) |
| Salas, caminhada: "Oppressive Gloom" (laço de 40 compassos) | `music/catacombs_1.ogg` | Kevin MacLeod, https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100885 | CC BY 4.0 |
| Salas, luta: "The Descent" (laço de 70 compassos) | `music/catacombs_2.ogg` | Kevin MacLeod, https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1200094 | CC BY 4.0 |
| Morvath, uma seção por fase: "Clash Defiant" (4 laços de 48 compassos) | `music/morvath_1.ogg` a `morvath_4.ogg` | Kevin MacLeod, https://incompetech.com/music/royalty-free/index.html?isrc=USUAN1600003 | CC BY 4.0 |
| Temas dos Salmos (`psalm_sentinel`, `psalm_shelter`, `psalm_shepherd`, `psalm_rock`) e vitória (`victory`), E4-06 | `music/psalm_*.ogg`, `music/victory.ogg` | compostos nota por nota e sintetizados pelo projeto em `tools/make_music.gd`; nada gravado | do projeto |

Crédito pedido pelo autor: "Título" Kevin MacLeod (incompetech.com), Licensed under Creative Commons: By Attribution
4.0 License, http://creativecommons.org/licenses/by/4.0/. Os laços são cortes e emendas (mudança permitida pela
licença), feitos por `tools/make_music_loops.sh` a partir dos .mp3 do site.

## Efeitos

| O quê | Autor | Licença |
|---|---|---|
| Kenney Impact Sounds: base dos golpes (`hit_*`, `hit_heavy_*`), escudo do herói (`shield_*`), atordoamento (`stagger_*`) | Kenney (kenney.nl) | CC0 1.0 (`LICENSE-kenney-impact-sounds.txt`) |
| "50 RPG sound effects" (RPG Audio): panos, couro, passos, lâmina sacada, corte de faca, trinco, porta | Kenney, https://opengameart.org/content/50-rpg-sound-effects | CC0 1.0 |
| "Swish - bamboo stick weapon swhoshes": sopro da lâmina (`blade_*`, `blade_spin_*`, `thrust_*`, e por baixo de `dart_*`, `blade_heavy_*`, `wave_omega_*`, esquiva, golpes inimigos e de Morvath) | Iwan Gabovitch (qubodup), https://opengameart.org/content/swish-bamboo-stick-weapon-swhoshes | CC0 1.0 (crédito opcional, dado aqui) |
| "80 CC0 RPG SFX": magias, correntes, metal, criaturas, rugidos, gemas, madeira | rubberduck, https://opengameart.org/content/80-cc0-rpg-sfx | CC0 1.0 |
| "75 CC0 breaking/falling/hit sfx": pedra, metal, madeira e vidro batendo, quebrando e caindo | rubberduck, https://opengameart.org/content/75-cc0-breaking-falling-hit-sfx | CC0 1.0 |
| "100 CC0 SFX": gongo, sino, respingo | rubberduck, https://opengameart.org/content/100-cc0-sfx | CC0 1.0 |
| "Fantasy Sound Effects Library": magias (`Spell_00` a `Spell_04`) e rugido de dragão | Little Robot Sound Factory, www.littlerobotsoundfactory.com, https://opengameart.org/content/fantasy-sound-effects-library | CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/), crédito no jogo |
| Ambiência por arena (E6, C15-04): `ambience/amb_*.ogg` | sintetizada pelo projeto em `tools/make_ambience.gd`; nada gravado | do projeto |

Todo efeito em `audio/*.ogg` é montado por `tools/make_sfx.sh` a partir desses pacotes (camadas mixadas fora do jogo,
tom e filtro ajustados, pico nivelado); a tabela de cada arquivo, com as fontes de cada camada, está no próprio script
e em `docs/design/t5_audio.md`. As receitas sintetizadas de `scripts/audio.gd` só tocam se um arquivo faltar.

A música própria é regerada com `~/tools/godot/godot --headless --path . -s tools/make_music.gd` (Salmos e vitória;
precisa do ffmpeg com libvorbis; .wav de trabalho em `~/tools/e4/music`). A ambiência com
`~/tools/godot/godot --headless --path . -s tools/make_ambience.gd` (.wav em `~/tools/e6/ambience`).
