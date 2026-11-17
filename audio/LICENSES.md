# Licenças do som

Regra (D-12b): só síntese, CC0 e CC-BY com crédito aqui; nada pago.

| O quê | Arquivos | Autor | Licença |
|---|---|---|---|
| Kenney Impact Sounds (golpes, ossos, escudo do herói, atordoamento) | `hit_*.ogg`, `hit_heavy_*.ogg`, `bone_*.ogg`, `shield_*.ogg`, `stagger_*.ogg` | Kenney (kenney.nl) | CC0 1.0 (`LICENSE-kenney-impact-sounds.txt`) |
| "Swish - bamboo stick weapon swhoshes" (sopro da lâmina do herói: corte, giro, estocada do Ômega, especial), cortados, sem o silêncio do começo, com passa-altas, tom ajustado por família e volume abaixo do impacto (E1c) | `blade_*.ogg` (swosh 11, 15, 16, 17, 22), `blade_spin_*.ogg` (43, 40, 36), `thrust_*.ogg` (07, 09, 14), `dart_*.ogg` (05, 18, 12) | Iwan Gabovitch (qubodup), https://opengameart.org/content/swish-bamboo-stick-weapon-swhoshes | CC0 1.0 (crédito opcional, dado aqui) |
| Música (E4-06): salas (`catacombs_1` caminhada, `catacombs_2` luta), Morvath por fase (`morvath_1` a `morvath_4`), temas dos Salmos (`psalm_sentinel`, `psalm_shelter`, `psalm_shepherd`, `psalm_rock`) e vitória (`victory`) | `music/*.ogg` | composta nota por nota e sintetizada pelo projeto em `tools/make_music.gd` (tabelas de onda, coro por formantes, corda dedilhada Karplus-Strong, sinos, tambores, reverberação Freeverb); nada gravado, nenhuma amostra, nada de outro jogo | do projeto |
| Todo o resto (material do golpe, avisos dos inimigos, tiros, quebra de armadura, corte do ataque, círculo, Morvath, interface) | sem arquivo: receitas em `scripts/audio.gd` (`SOUNDS`) | sintetizado pelo jogo | do projeto |

Nenhum som CC-BY em uso ainda. Ao pôr um, acrescentar a linha com autor, link e licença, e o crédito nos créditos do jogo.

A música é regerada com `~/tools/godot/godot --headless --path . -s tools/make_music.gd` (precisa do ffmpeg com
libvorbis); os .wav de trabalho ficam fora do projeto (`~/tools/e4/music`). Os créditos do jogo ficam em Como Jogar,
Créditos (`CreditsScreen`, textos `credits_*`).
