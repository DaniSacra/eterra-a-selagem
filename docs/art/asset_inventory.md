# Inventário de assets de A Selagem

Mantido pelo artista técnico (`.claude/agents/technical-artist.md`). Achados, riscos e propostas ficam em
`docs/qa/asset_report.md`; aqui fica o que existe, de onde veio, onde é usado e quanto pesa.

Auditoria inicial: 2026-11-18, HEAD `d458633` do `arpg-3d`; atualizado no mesmo dia pela entrega C1 (melhorias 1 a 4
do relatório: fontes dos assados fora do pacote, uma paleta do KayKit, herói, Emeth e rocha comprimidos para a placa;
exe de 219,7 para 197,2 MB). Como foi medido (refazer quando um asset mudar):
- **Disco**: `du -b` / `stat` no repositório.
- **Pacote**: exportado `"Windows Desktop"` no worktree (`build/windows/ASelagem.exe`, 197,2 MB = modelo da Godot
  109,3 MB + PCK embutido 87,9 MB; antes da C1 219,7 MB com PCK de 110,3) e lida a tabela do PCK por `python3 -I tools/pck_sizes.py build/windows/ASelagem.exe`,
  cada entrada ligada à fonte pelo `.import`. MB = 10^6 bytes.
- **Uso em jogo**: `grep` em `scripts/`, `data/`, `scenes/` e o rastro `--verbose` ("Loading resource") de 29 partidas
  do robô sem tela: as 7 arenas com as 2 variantes, Morvath, guardião, loja, fonte, Provação, Altar, descida inteira
  (`--smoke=900 --fast=3`), `--horde` e 7 telas do título. O som não é carregado sem tela, então o uso dos efeitos
  vem só do código.
- **Triângulos, poses e texturas**: `tools/asset_probe.gd -- baked|scenes` (sem tela);
  **memória de vídeo**: `tools/gpu.sh run --rendering-driver vulkan -s tools/asset_probe.gd -- vram` (RTX 5060, Forward+).
- **Som**: `ffprobe` e `ffmpeg -af ebur128=peak=true` (LUFS integrado e pico real).

Estados: **definitivo** (aprovado e tecnicamente certo), **provisório** (no jogo, a trocar ou acertar), **fonte** (não
vai no jogo, é matéria-prima de uma ferramenta), **sem uso** (nem o jogo nem uma ferramenta usa).

## 1. Personagens e espada (Meshy, IA)

Licença: geração própria no Meshy (declarada em `docs/steam-ia.md`; o plano do Meshy em que cada modelo foi gerado
não está registrado, ver o relatório). Ids das tarefas e prompts em `tools/meshy/tasks.json` e `prompts.json`.

| Asset | Arquivos | Uso | Disco | Pacote | Medidas | Estado | Falta para definitivo |
|---|---|---|---|---|---|---|---|
| Herói (o Guerreiro, modelo do Explorador) | `assets/models/meshy/hero_explorer/hero_explorer-rigged.glb` + `_Image_0.jpg` | `HeroBody.MODEL` | 6,5 + 3,5 MB | 1,42 + 5,59 MB | 30 741 triângulos, 24 ossos, textura 2048 x 2048 BC7 (BPTC) com mipmaps, 5,3 MB de VRAM (era RGB8, 21,3 MB) | definitivo no desenho e na textura | avaliar reduzir a malha (é 8 vezes um inimigo e o raio-x a desenha mais 3 vezes) |
| Animações do herói | `hero_explorer/hero_anims.res` | `HeroBody.ANIMS` | 0,39 MB | 0,39 MB | clipes da UAL 1 e 2 transferidos por `tools/bake_hero.gd` | definitivo | em dia com o `bake_hero.gd` (`579ce02`, mesmo commit) |
| Espada Emeth | `assets/models/meshy/emeth/emeth.glb` + `emeth_0.jpg` | `EmethSword.MODEL` | 4,3 + 3,8 MB | 0,29 + 1,40 MB | 8 145 triângulos, textura importada em 1024 x 1024 BC7 com mipmaps (`process/size_limit`), 1,3 MB de VRAM (era 2048 RGB8, 21,3 MB) | definitivo | |
| Miniatura da Emeth | `emeth/emeth.png` (512) | nenhum (excluída do pacote) | 46 KB | 0 | prévia do Meshy | fonte | |
| Nove inimigos da fase 1 | `assets/models/meshy/enemy_<id>/enemy_<id>-rigged.glb` + `_Image_0.jpg` + miniatura `.png` | `tools/bake.gd` (`MODELS`, `"meshy"`); excluídos do pacote | 79,3 MB (9 x 5,0 a 5,7 MB de glb + 3,0 a 3,6 MB de textura 2048) | 0 | ~15,5 mil triângulos cada, 24 ossos | fonte | |
| "Sombra" (herói antigo) | `assets/models/meshy/hero_sombra/` (12 arquivos) | nenhum (excluído do pacote; `tools/recolor_hero.gd` ainda o lê) | 32 MB | 0 | 4 cópias idênticas da textura de 2048 | sem uso | decidir com o Daniel: guardar fora do repositório |
| `paladin_1` | `assets/models/meshy/paladin_1/` (12 arquivos) | nenhum (excluído do pacote) | 28 MB | 0 | 4 cópias idênticas da textura de 2048 | sem uso | idem |

## 2. Inimigos assados (`assets/baked/*.res`, `BakedModel`)

Origem: os modelos do Meshy acima reduzidos pelo `MeshSlim` (corpo de 3 900 triângulos, atlas novo de 1024 em DXT1),
armas do KayKit presas (`held`, repintadas pelos `SWATCHES`), clipes da UAL (Quaternius, CC0) e do KayKit (CC0)
transferidos pelo `Retarget`. Feitos por `tools/bake.gd`. Lidos por `CrowdRenderer.model` pelo `EnemyDef.model` dos
`data/enemies/*.tres`. Teto dos assados: 70 MB; hoje **43,92 MB** no disco e **43,75 MB** no pacote (a `statue.res`
fica fora desde a C1).

| Figura | Arquivo | Disco/pacote | Vértices | Triângulos | Poses (clipes) | Imagens de pose | Altura | Pé em repouso | Assado em |
|---|---|---|---|---|---|---|---|---|---|
| esqueleto | `skeleton.res` | 5,23 MB | 6 048 | 4 311 | 128 (10) | 2048 x 378 | 1,92 | -0,007 | `5aeee46` |
| corredor | `runner.res` | 3,65 MB | 5 304 | 3 866 | 90 (7) | 2048 x 234 | 1,65 | +0,012 | `5aeee46` |
| feiticeiro | `mage.res` | 5,44 MB | 6 660 | 5 530 | 119 (10) | 2048 x 387 | 1,92 | +0,004 | `5aeee46` |
| besteiro | `archer.res` | 3,94 MB | 6 078 | 4 435 | 90 (7) | 2048 x 268 | 1,92 | -0,015 | `5aeee46` |
| Escudo | `guard.res` | 3,90 MB | 4 459 | 3 877 | 114 (9) | 2048 x 249 | 2,03 | -0,013 | `5aeee46` |
| sacerdote | `priest.res` | 3,51 MB | 4 513 | 3 846 | 102 (8) | 2048 x 225 | 1,93 | -0,021 | `5aeee46` |
| Cavaleiro (guardião) | `knight.res` | 4,80 MB | 6 109 | 4 956 | 114 (9) | 2048 x 341 | 2,03 | -0,025 | `5aeee46` |
| sacerdote ancião (guardião) | `priest_elder.res` | 5,30 MB | 6 617 | 5 557 | 116 (9) | 2048 x 375 | 2,07 | **-0,081** | `5aeee46` |
| Morvath | `morvath.res` | 7,96 MB | 5 325 | 4 281 | 230 (17) | 2048 x 599 | 2,02 | -0,012 | `6338417` (um commit de `bake.gd` atrás) |
| estátua encapuzada | `statue.res` | 0,17 MB | 5 586 | 6 035 | 1 | 2048 x 3 | 2,47 | | `ec5d757`, **sem uso** (a estátua é feita em código por `Masonry._build_statue`); fora do pacote desde a C1 |

Posições em RGBA meia precisão (8 bytes por vértice por pose), normais RG8, albedo 1024 DXT1 com mipmaps em todos.
Memória de vídeo dos assados juntos: 79,0 MB (medido). Elites usam o mesmo assado (ouro por shader).

## 3. Fontes dos assados (fora do pacote desde a C1, `exclude_filter` dos três presets)

| Asset | Arquivos | Origem e licença | Uso | Disco | Pacote | Estado |
|---|---|---|---|---|---|---|
| Universal Animation Library 1 e 2 | `assets/models/anim/ual_standard.glb`, `ual2_standard.glb` | Quaternius, CC0 (`LICENSE_Quaternius_UAL.txt`) | `tools/bake.gd`, `tools/bake_hero.gd` (`RIGS`) | 14,7 MB | 0 (era 2,18) | fonte |
| Bonecos do KayKit | `assets/models/characters/*.glb` + texturas (7 figuras) | Kay Lousberg, CC0 (`LICENSE_KayKit_Adventurers.txt`, `_Skeletons.txt`) | `tools/bake.gd`: `Skeleton_Warrior` é o rig `kaykit` dos clipes; os outros só no modo `-- kaykit` e na estátua sem uso | 29 MB | 0 (era 11,38) | fonte |
| Armas do KayKit | `assets/models/weapons/*.gltf` + `skeleton_texture.png` | Kay Lousberg, CC0 | `tools/bake.gd` (`held`) | 0,29 MB | 0 (era 0,20) | fonte |
| Paletas dos bonecos do KayKit | `assets/models/palettes/*.png` (15, 512 px) | geradas por `tools/make_palettes.gd` | `tools/bake.gd` (faixa das armas `held`) | 0,24 MB | 0 (excluídas) | fonte |

## 4. Cenário do KayKit (Kay Lousberg, CC0; provisório desde o início)

`assets/models/dungeon/` (26 peças) e `assets/models/dungeon_r/` (43 peças, "Dungeon Remastered"), cada peça um `.glb`
(18 peças são iguais byte a byte nas duas pastas). Desde a C1 todas usam um material só,
`assets/models/kaykit_material.tres` (a paleta `assets/models/kaykit_palette.png`, 1024 x 1024 BC7 com mipmaps, e a
rugosidade 0,45 do kit), pelo `_subresources` de cada `.glb.import` (`use_external`) com
`gltf/embedded_image_handling=0`: as 69 cópias extraídas da mesma paleta (mesmo hash) foram apagadas. Licenças `LICENSE_KayKit_Dungeon.txt` e `_Dungeon_Remastered.txt` (idênticas). Uso: `Arena._place`
(`DUNGEON`) e `ArenaKit._kit_mesh` (`KIT`); as peças de pedra levam o material `Masonry` por cima.

| Grupo | Peças | Disco | Pacote | Triângulos | Estado |
|---|---|---|---|---|---|
| carregadas numa descida inteira (rastro) | `dungeon/`: banner_patternA_white, banner_thin_yellow, barrel_large, candle_lit, candle_triple, floor_tile_large, pillar, pillar_decorated, rubble_half, rubble_large, stairs_wide, sword_shield_broken, torch_mounted, wall, wall_arched, wall_broken, wall_corner, wall_cracked; `dungeon_r/`: box_small, rubble_half, rubble_large | ~1,0 MB | ~0,4 MB | 83 a 2 010 por peça | provisório |
| nunca carregadas em 29 partidas | `dungeon/`: chest_gold, column, floor_dirt_large_rocky, floor_tile_large_rocks, floor_tile_small_broken_A, floor_tile_small_weeds_A, torch_lit, wall_pillar; `dungeon_r/`: as outras 40 | ~2,0 MB | ~0,6 MB | | provável sem uso (confirmar com o environment-artist: o `ArenaKit` ainda cita algumas, como `wall_doorway` em `portal()` e a lista `STONY`) |

Memória de vídeo: as 21 peças carregadas numa descida ocupam **1,3 MB** (uma paleta BC7; antes da C1, 112 MB: 21
cópias RGBA8 sem compressão de vídeo; medido na RTX 5060). Pacote: peças 0,97 MB + paleta 1,40 MB (antes 3,63 MB).

## 5. Texturas do cenário

| Asset | Arquivos | Origem e licença | Uso | Disco | Pacote | Medidas | Estado |
|---|---|---|---|---|---|---|---|
| Rock Surface (relevo) | `assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg`, `_disp_1k.jpg` | Amal Kumar, Poly Haven, CC0 (`LICENSE.txt`) | `Masonry.ROCK_NORMAL`, `ROCK_HEIGHT` (chão e cantaria) | 1,15 + 0,43 MB | 1,40 + 0,70 MB | 1024 com mipmaps; normal em BC5 (RGTC_RG, `compress/normal_map=1`; o z é refeito no `masonry.gdshader` e no `catacomb_floor.gdshaderinc`), altura em BC4 (RGTC_R, verde e azul zerados e `channel_pack` otimizado); 1,3 + 0,7 MB de VRAM (eram 5,3 + 1,3) | definitivo |
| Leão do selo | `assets/textures/seal/lion.svg` | desenhado em SVG por IA (Claude), `docs/steam-ia.md` | fonte de `tools/make_seal_lion.gd` | 4 KB | 4 KB (entra sem precisar) | 512 | fonte |
| Campo de distância do leão | `assets/textures/seal/lion_sdf.res` | gerado do SVG | `BossChamber.LION`, `ArenaKit.LION_FIELD`, `SealEmblem.LION` | 0,70 MB | 0,70 MB | | definitivo |

## 6. Arte de interface (IA, `docs/steam-ia.md`)

Importadas sem perda (WebP sem perda dentro do `.ctex`), certo para 2D. Mipmaps onde o desenho usa
`TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`.

| Asset | Arquivos | Uso | Disco | Pacote | Medidas | Estado | Falta |
|---|---|---|---|---|---|---|---|
| Fundo do título | `assets/ui/title/title_bg.png` (botões apagados por `tools/make_title_bg.sh`) | `TitleBackdrop.ART` | 2,47 MB | 2,80 MB | 1672 x 941, mipmaps, 8,8 MB de VRAM | definitivo | a 1920 x 1080 sobe 1,15 vez (limite da pintura) |
| Faixas do título | `assets/ui/title/title_fill.png` | `TitleBackdrop.FILL` | 18 KB | 18 KB | 160 x 90, desfocada | definitivo | |
| Pintura original do título | `assets/ui/title/title_screen_reference.png` | `tools/make_title_bg.sh` (excluída do pacote) | 2,58 MB | 0 | 1672 x 941 | fonte | |
| Retrato do HUD | `assets/ui/hud/hero_portrait.png` | `HeroCrest.PORTRAIT` (76 px a 720) | 0,12 MB | 0,13 MB | 256, mipmaps | definitivo | |
| Retrato do Livro de Ahk | `assets/ui/hero/warrior_page.png` | `HeroScreen.PORTRAIT` | 0,28 MB | 0,22 MB | 330 x 400, sem mipmaps, filtro linear | provisório | conferir se sobe a 1080 (ampliado borra); recortar maior da prancha se der |
| Medalhões das Bênçãos | `assets/ui/boons/{vapor,aurora,redemoinho}.png` (512) e `{brasas,toque_geada,onda_maior,escudo}.png` (384) | `BoonArt.medallion` (pelo id da Bênção) | 2,04 MB | 2,10 MB | RGBA, mipmaps, 1,3 MB de VRAM cada (512) | definitivo para os 7 | 25 das 32 Bênçãos ainda sem arte pintada (usam o `BoonIcon` desenhado) |
| Medalhões dos eventos | `assets/ui/events/{pomegranate,candles,passage,trial_seal}.png` (384) | `BoonArt.event` (Altar e Provação) | 0,88 MB | 0,91 MB | RGBA, mipmaps | definitivo | |

## 7. Fontes (SIL Open Font License)

| Fonte | Arquivo | Uso | Disco | Pacote | Estado |
|---|---|---|---|---|---|
| Alegreya Sans Regular e Bold | `assets/fonts/AlegreyaSans-*.ttf` (`OFL_AlegreyaSans.txt`) | tema e textos (`UiKit`, `DoorSign`, título) | 0,53 MB | 0,29 MB | definitivo |
| Cinzel | `assets/fonts/Cinzel.ttf` (`OFL_Cinzel.txt`) | títulos | 0,13 MB | 0,07 MB | definitivo |

## 8. Shaders (só a lista; donos: environment-artist e quem fez o efeito)

77 arquivos em `assets/shaders/` (0,28 MB no pacote), todos citados por algum script ou por outro shader:
abyss_fog, abyss_glow, abyss_mist, abyss_ruins, altar_lion, banner_lion, beam, book_page, boss_scythe, boss_shield,
boss_wake, candle_wax_see, catacomb_floor (+ `.gdshaderinc`), chamber_door, chamber_floor, chamber_seal (inc),
chamber_veil, chip, crescent, crowd, crowd_outline, crowd_pose (inc), curse_aura, depth_stone, door_breath, dry_grass,
emeth, emeth_thrust, emeth_wave, enemy_orb, enemy_orb_halo, enemy_tell, flame_see, flash, floor_detail, fury_ember,
garden_inscription, glint, ground (+ inc), ground_fill, hero_ring (+ inc), hero_ring_through, impact, life_bar,
masonry, portal, rift_haze, ring, ritual_rune, room_air (inc), root_moss, rune_flash, rune_floor, rune_glyph (inc),
rune_tiles (inc), screen, see_through (inc), slash, slash_ink, soul_crescent, spectral_column, spectral_motes,
stone_tree, title_art, title_mist, trial_veins, ult_rift, ult_vortex, x_crack, xray, xray_behind, xray_body (inc),
xray_depth, xray_edge.

## 9. Música (`audio/music/`, teto no pacote 18 MB; hoje 16,57 MB no disco e **17,22 MB no pacote**)

Ogg Vorbis 44,1 kHz estéreo. Escolha por lugar em `MusicCatalog` (`core/music_catalog.gd`).

| Peça | Arquivos | Origem e licença | Disco | Pacote | Duração | LUFS / dBTP por camada | Estado |
|---|---|---|---|---|---|---|---|
| Catacumbas (original), padrão no título e nas salas | `classic_catacombs_1.ogg`, `_2.ogg` | síntese do projeto (`tools/make_music.gd`, código escrito por IA) | 2,38 MB | 2,50 MB | 96 s | -21,7 / -10,5; -25,1 / -6,6 | definitivo |
| Morvath (original), padrão na luta | `classic_morvath_1..4.ogg` | síntese do projeto | 3,14 MB | 3,27 MB | 64 s | -27,9 a -24,4 / -13,1 a -8,8 | definitivo |
| Salmos | `psalm_{sentinel,shelter,shepherd,rock}.ogg` | síntese do projeto | 0,73 MB | 0,76 MB | 16 a 16,7 s | -20,4 a -14,8 / -4,6 a -4,3 | definitivo |
| Vitória | `victory.ogg` | síntese do projeto | 0,13 MB | 0,14 MB | 12,6 s | -22,8 / -4,3 | definitivo |
| "Tempting Secrets" (título, para escolher) | `title.ogg` | Kevin MacLeod, CC BY 4.0 | 2,27 MB | 2,32 MB | 172 s | -22,0 / -4,3 | definitivo (opcional) |
| "Oppressive Gloom" e "The Descent" | `catacombs_1.ogg`, `catacombs_2.ogg` | Kevin MacLeod, CC BY 4.0 | 4,23 MB | 4,37 MB | 165 e 163 s | -21,1 / -5,1; -20,1 / -6,3 | definitivo (opcional) |
| "Clash Defiant" (4 seções) | `morvath_1..4.ogg` | Kevin MacLeod, CC BY 4.0 | 3,70 MB | 3,87 MB | 67,8 s | -22,0 a -19,0 / -9,8 a -7,6 | definitivo (opcional) |

Laços feitos no tocador (`MusicMix`, `loop_from`), não no `.import` (`loop=false` em todos, de propósito). Laços sem
emenda testados em `tests/test_music.gd` e `tests/test_mix.gd`.

## 10. Ambiência (`audio/ambience/amb_*.ogg`)

10 laços de 24 s (altar, bridge, crypt, garden, hall, rift, runes, sanctuary, seal, trial), sintetizados por
`tools/make_ambience.gd` (código escrito por IA, nada gravado). `Ambience.BY_ARENA`. Disco 2,91 MB, pacote 3,01 MB.
-28,6 a -23,6 LUFS, pico -15,4 a -8,5 dBTP. Estado: definitivo.

## 11. Efeitos sonoros (`audio/*.ogg`)

125 arquivos (78 nomes; `<nome>_N.ogg` sorteia), montados por `tools/make_sfx.sh` com as camadas já mixadas de pacotes
CC0 (Kenney Impact Sounds e RPG Audio, qubodup "Swish", rubberduck 80/75/100 CC0 SFX) e CC BY 3.0 (Little Robot Sound
Factory, "Fantasy Sound Effects Library"). Tabela por arquivo no próprio `make_sfx.sh` e em `docs/design/t5_audio.md`.
Uso: `Audio.play(&"nome")` (`scripts/audio.gd`, `CombatSounds`, `ComboNode.sound`); todos os 78 nomes aparecem no
código ou nos dados. Disco 1,16 MB, pacote 1,30 MB. Ogg 44,1 kHz (115 mono, 10 estéreo), 0,15 a 1,6 s, pico real de
-20,1 a -0,6 dBTP sozinhos (o limitador do `Master` fica em -1,5 dB). Estado: definitivo (receitas sintetizadas de
`scripts/audio.gd` só tocam se um arquivo faltar).

## 12. Licenças guardadas no repositório

`assets/models/LICENSE_KayKit_{Adventurers,Dungeon,Dungeon_Remastered,Skeletons}.txt`,
`assets/models/anim/LICENSE_Quaternius_UAL.txt`, `assets/textures/rock_surface/LICENSE.txt`,
`assets/fonts/OFL_*.txt`, `audio/LICENSE-kenney-impact-sounds.txt`, `audio/LICENSES.md`, `CREDITOS.txt`.
