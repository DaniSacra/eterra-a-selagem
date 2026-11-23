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

## 2. Inimigos assados (`assets/baked/*.res`, `BakedModel`)

Origem: os modelos do Meshy acima reduzidos pelo `MeshSlim` (corpo de 3 900 triângulos, atlas novo de 1024 em DXT1),
armas do KayKit presas (`held`, repintadas pelos `SWATCHES`), clipes da UAL (Quaternius, CC0) e do KayKit (CC0)
transferidos pelo `Retarget`. Feitos por `tools/bake.gd`. Lidos por `CrowdRenderer.model` pelo `EnemyDef.model` dos
`data/enemies/*.tres`. Teto dos assados: 70 MB; hoje **45,32 MB** no disco com a gente do hub (os nove inimigos 43,75
MB, os dois do hub 1,57 MB). Todos reassados juntos em 2026-11-19 (Lote 2C: Morvath estava em `6338417`, dois commits
do `tools/bake.gd` atrás; a `statue.res` saiu do repositório e do `MODELS`, DT-107). Cada `.res` guarda o
`bake_stamp` da entrada que o fez (`stamp()` no `tools/bake.gd`, DT-104) e `tests/test_asset_budget.gd` falha quando
algum fica atrás da entrada, quando os assados passam de 70 MB, a música do pacote de 18 MB ou uma figura do teto de
triângulos (5 600; ver a nota da tabela).

| Figura | Arquivo | Disco/pacote | Vértices | Triângulos | Poses (clipes) | Imagens de pose | Altura | Pé em repouso | Assado em |
|---|---|---|---|---|---|---|---|---|---|
| esqueleto | `skeleton.res` | 5,23 MB | 6 048 | 4 311 | 128 (10) | 2048 x 378 | 1,92 | -0,007 | Lote 2C (2026-11-19) |
| corredor | `runner.res` | 3,64 MB | 5 304 | 3 866 | 90 (7) | 2048 x 234 | 1,65 | +0,012 | Lote 2C; `Jog_Fwd` de pés travados (`RUNNER_JOG`, `40d6618`) |
| feiticeiro | `mage.res` | 5,44 MB | 6 660 | 5 530 | 119 (10) | 2048 x 387 | 1,92 | +0,004 | Lote 2C (marca `orb`) |
| besteiro | `archer.res` | 3,95 MB | 6 078 | 4 435 | 90 (7) | 2048 x 268 | 1,92 | -0,015 | Lote 2C (besta 0,62, peça `crossbow`) |
| Escudo | `guard.res` | 3,91 MB | 4 459 | 3 877 | 114 (9) | 2048 x 249 | 2,03 | -0,013 | Lote 2C |
| sacerdote | `priest.res` | 3,52 MB | 4 513 | 3 846 | 102 (8) | 2048 x 225 | 1,93 | -0,021 | Lote 2C (`cast` = Cheer do KayKit, marcas `hands`, `hand_l`, `hand_r`) |
| Cavaleiro (guardião) | `knight.res` | 4,80 MB | 6 109 | 4 956 | 114 (9) | 2048 x 341 | 2,03 | -0,025 | Lote 2C; o escudo (vértices 5481 a 6435) some da mão enquanto voa e é recortado para o arremesso (2026-11-23, `ThrownShield`) |
| Gritador (apoio, C1e A) | `herald.res` | 3,98 MB | ? | 4 095 | 119 (10) | 2048 x 284 | 1,92 | n/d | Corpo do feiticeiro ereto, estandarte (mastro, pano âmbar, ponta de osso) na esquerda; sem Meshy, `tools/bake.gd` `herald`; tinta azul-aço no `make_data`; provisório (conferir em captura a 720p) |
| Coveiro (apoio, C1e A) | `gravedigger.res` | 3,46 MB | ? | 4 158 | 102 (8) | 2048 x 239 | 1,93 | n/d | Corpo do sacerdote curvado, pá e lanterna; `tools/bake.gd` `gravedigger`; tinta terra; escorrega 0,10 m por passo na marcha (igual ao sacerdote); provisório |
| sacerdote ancião (guardião) | `priest_elder.res` | 5,30 MB | 6 617 | 5 557 | 116 (9) | 2048 x 375 | 2,07 | **-0,081** | Lote 2C (marca `orb`) |
| Morvath | `morvath.res` | 7,96 MB | 5 325 | 4 281 | 230 (17) | 2048 x 599 | 2,02 | -0,012 | Lote 2C (estava em `6338417`); `pose_drift` até 0,44 m fora da queda (0,52) e do levantar (0,41) |

| corredor elite (Lote 2B, sem uso ainda) | `runner_elite.res` | 3,47 MB | 5 304 | 3 866 | 90 (7) | 2048 x 234 | 1,65 | +0,012 | 2026-11-20; o corredor com `RUNNER_ELITE_JOG` (passada 1,55, 199 passos/min a 7,4 m/s, escorrega 4,6 cm); falta `"model"` na elite do `make_data.gd` (gameplay) |

Lote 2B (2026-11-20): os nove reassados juntos (opção `"centred"` no erguer, `"kick"` no tiro do besteiro, Morvath com
`curse_windup` e `rain_wave`, 8,20 MB, 17 + 2 clipes). Assados no disco: **47,3 MB** com o corredor elite e a gente do
hub (teto 70).

**Lote do Canalizador (2026-11-23): assados 69,61 MB (teto 70, sem espaço) para 68,55 MB com o novo `channeler.res` (3,35 MB).**
Peso de um assado = vértices x poses (a textura de 1024 pesa só 0,25 a 0,4 MB: ATLAS 768 ou 512 não rende). Folga aberta
nos clipes comuns (`COMMON_ANIMS` em `tools/bake.gd`, as poses se misturam, a duração não muda): `death` 16 para 11 poses,
`hit` 8 para 6, `rise` 12 para 9; `PIPELINE` 2 e todos reassados (os dois do hub também). `tests/test_living_crowd.gd` aceita
agora no mínimo 6 e 11. Maior peso: Morvath 10,5 MB (250 poses), Knight 5,1, Skeleton 4,9, Mage 4,6, Elder 4,4, Guard 4,3.
Ainda sem uso a cortar: nenhum clipe achado sem uso; candidatos futuros: `rain_wave`/`curse_windup` do Morvath (repetem clipes),
`walk` do Herald e do Mago (compartilham o corpo, três assados do mesmo corpo: mage, herald, channeler, 12,3 MB).
| Canalizador (C1e) | `channeler.res` | 3,35 MB | 4 885 | 4 179 | 99 (10: sem andar de verdade, `walk` de 4 poses; `idle` = `Spell_Simple_Idle`) | 2048 x 246 | 1,92 | 0,000 | 2026-11-23; sem cajado, braços erguidos, um orbe frio em cada punho (`held` esferas, `mark` no esquerdo); definitivo da silhueta; `docs/gallery/channeler/lab_game.png` |

| Vendedor do hub (HUB-D) | `npc_vendor.res` | 0,77 MB | 3 252 | 4 005 | 30 (2: `idle` 16, `gesture` 14 = `Interact`) | 2048 x 48 | 1,90 | 0,000 | HUB-D (2026-11-19), `tools/bake.gd -- npcs` |
| Forjador do hub (HUB-D) | `npc_smith.res` | 0,85 MB | 3 807 | 4 232 | 28 (2: `idle` 16, `gesture` 12 = `1H_Melee_Attack_Chop` de 0,1 a 0,655 s, tronco 12 graus para trás) | 2048 x 56 | 1,95 | 0,000 | HUB-D, idem; peças `hammer` e `handle` |

Triângulos: o corpo depois do `MeshSlim` tem cerca de 3 870; o resto é a arma do KayKit inteira (cajado 1 519,
escudo grande 626, besta 584, lâmina 457). Os níveis mais simples da cadeia do motor (`"lod"` de um `held` no
`tools/bake.gd`, DT-107) foram medidos: lâmina 227, besta 292, cajado 759 (no nível 2 o cajado perde a cabeça, 0,2 m)
e escudo 304 (perde a borda, a espessura cai de 0,36 para 0,27 m); ficaram de fora porque as figuras mudam de forma e
as medidas de preparo do `test_enemy_windup.gd` (média por vértice) mudam com o número de vértices da arma. O teto de
4 100 do DT-107 pede armas próprias (Meshy ou feitas no código).

Posições em RGBA meia precisão (8 bytes por vértice por pose), normais RG8, albedo 1024 DXT1 com mipmaps em todos (os
dois do hub: a paleta própria de 512 em DXT1 com mipmaps dentro do `.res`, `"embed"`, porque `assets/models/palettes`
fica fora do pacote).

**Gente do hub (HUB-D, provisório; `docs/design/hub_spec_art.md` 3.8, Meshy zero)**: bonecos do KayKit Adventurers
(Kay Lousberg, CC0) assados pelo `tools/bake.gd -- npcs` (`NPCS`: `Rogue_Hooded` sem armas para o Vendedor; `Knight`
sem elmo, escudos, espadas e capa para o Forjador, os braços de placa viram pele e as pernas lã escura por `remap`,
martelo procedural `NPC_HAMMER` na mão direita), afinados pelo `Slender` (cabeça a `head_shrink` 0,9 por cima), na
altura de `height` com as solas no chão, repintados por paletas próprias (`tools/make_palettes.gd -- npcs`:
`npc_vendor.png`, `npc_smith.png`; capuz petróleo escuro com luz 0,25 de valor, manto terra apagado, couro, avental de
couro escuro, ferro escuro; nada de petróleo saturado, esmeralda nem ouro de elite). Os dois somam 8 237 triângulos
(teto 12 mil). Desenhados por `HubNpc` (`scripts/render/hub_npc.gd`, um `CrowdRenderer` próprio com uma figura: a
pintura, o contorno e as faixas do estilizado da multidão), postos pelo `HubLook._people`. Falta para definitivo: o
Daniel dizer quem são (Q-H3); modelo próprio só com ele (Meshy, 40 créditos estimados no `hub_spec_art.md` 3.9).
Memória de vídeo dos assados juntos: 79,0 MB (medido). Elites usam o mesmo assado (ouro por shader).

## 3. Fontes dos assados (fora do pacote desde a C1, `exclude_filter` dos três presets)

| Asset | Arquivos | Origem e licença | Uso | Disco | Pacote | Estado |
|---|---|---|---|---|---|---|
| Universal Animation Library 1 e 2 | `assets/models/anim/ual_standard.glb`, `ual2_standard.glb` | Quaternius, CC0 (`LICENSE_Quaternius_UAL.txt`) | `tools/bake.gd`, `tools/bake_hero.gd` (`RIGS`) | 14,7 MB | 0 (era 2,18) | fonte |
| Bonecos do KayKit | `assets/models/characters/*.glb` + texturas (7 figuras) | Kay Lousberg, CC0 (`LICENSE_KayKit_Adventurers.txt`, `_Skeletons.txt`) | `tools/bake.gd`: `Skeleton_Warrior` é o rig `kaykit` dos clipes; os outros só no modo `-- kaykit` e na estátua sem uso | 29 MB | 0 (era 11,38) | fonte |
| Armas do KayKit | `assets/models/weapons/*.gltf` + `skeleton_texture.png` | Kay Lousberg, CC0 | `tools/bake.gd` (`held`: só a besta do arqueiro e o modo `-- kaykit`) | 0,29 MB | 0 (era 0,20) | fonte |
| Armas do Meshy (2026-11-21) | `assets/models/meshy/w_{cleaver,knight_sword,knight_shield,staff,morvath_scythe}/` (glb 2048 px, 1,5 a 3,1 mil triângulos) | Meshy (plano Pro do Daniel, `docs/steam-ia.md`) | `tools/bake.gd` (`held` com `meshy`): reduzidas pelo `MeshSlim` (cutelo 800, espada 750, escudo 750, cajado 1000, foice 1550) e repintadas num atlas de 128 px por peça, na faixa sob o corpo (`SLOT`); esqueleto, cavaleiro, feiticeiro, ancião e Morvath reassados | 17 MB | 0 (`w_*/*` no `exclude_filter`) | fonte; definitivo |
| Estátua encapuzada e leão sentado do Meshy | `assets/models/meshy/{statue_hooded,lion_seated}/*.glb` (6,2 mil triângulos cada, textura de 64 px: só a malha é usada) | Meshy (plano Pro) | `Masonry.meshy_stone` (estátua dos Salões e leões do `HubLook`, pedra do `Masonry._carved`) | 8 MB | malha + 2 texturas de 64 px | definitivo (tinta pela pedra) |
| Paletas dos bonecos do KayKit | `assets/models/palettes/*.png` (15 + 2 da gente do hub, 512 px) | geradas por `tools/make_palettes.gd` (`-- npcs` só as do hub, sobre as paletas do `Knight` e do `Rogue_Hooded`) | `tools/bake.gd` (faixa das armas `held`; as do hub entram dentro do `.res`) | 0,26 MB | 0 (excluídas) | fonte |

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
| Leão do selo | `assets/textures/seal/lion.svg` | desenhado em SVG por IA (Claude), `docs/steam-ia.md` | fonte de `tools/make_seal_lion.gd` | 4 KB | 0 (fora do pacote desde o DT-107) | 512 | fonte |
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

**Arte de interface desenhada em código (sem arquivo, sem IA)**: selos dos anjos da Fatia 1 (`AngelSeal`,
`scripts/ui/angel_seal.gd`; proposta da seção 4 do `docs/design/rejogabilidade/sistemas.md`, nada canônico): o selo da
casa (`SealMedal.draw_seal`) com a marca da família em linhas marfim acesas na cor dela (`AngelSeal.TINT`, mais calma
que `Boon.FAMILY_COLOR`): Chama brasa em losango com três línguas de fogo, Geada floco de seis braços curtos com
galhinhos (nunca quatro), Luz feixe vertical estreito que desce sobre um losango (nenhum raio em volta), Vigília
trombeta do vigia com a campânula à direita e a alça; o Elo não tem selo próprio (os dois lado a lado). Nunca sol,
cruz, leão, escudo nem olho. Estado: provisório até a revisão do art-director e os nomes do Daniel. Provas em
`docs/gallery/rj1/` (`tools/rj1_lab.gd`).

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

HUB-D e Fatia 1 (technical-artist, 2026-11-19): `frame_yaw.gdshaderinc` (novo; global `frame_yaw` no `project.godot`,
0 em toda sala, o ângulo do quadro no hub: a cantaria do `masonry.gdshaderinc` e as lajes do
`catacomb_floor.gdshaderinc` seguem as paredes do hub girado 35 graus; com 0 as funções devolvem o argumento sem conta
nenhuma) e `emeth.gdshader` com `temper` (0 a 2, padrão 0: nada desenhado; veios de ouro velho e o fio pálido do gume
por posto de Temperar, nenhum canal acima de 1,0, no estilizado sob o `style_cap`).

Passe de VFX, Lote 1 (technical-artist, 2026-11-20; `vfx_pass_spec.md`; tudo procedural, licença do projeto, sem
textura nova): novos `reward_shaft`, `reward_pool`, `reward_dust` (a luz sobre o que se pega, `RewardShaft`; um material
por facho, 3 chamadas de desenho: tronco sem tampas de 24 lados, plano da poça, MultiMesh de 8 riscos), `wisp` (fiapos de
fumaça, uma MultiMesh de 96 no `Fx`), `smoke_ring` (onde o golpe de inimigo cai, pool de 12), `contact` (estalo do
acerto, pool de 12). Reescritos: `chip` (premul com teto), `enemy_orb` (núcleo escuro, agulha do virote),
`enemy_orb_halo` (fumaça rasgada e espinhos), `slash` (premul, teto pelo maior canal no estilizado), `crescent` (fita que
varre), `glint` (estrela de 6 pontas), `emeth_thrust` (perfil de lâmina), `boss_scythe` (borda roída). Os
`CPUParticles3D` do `Fx` (10 tipos x 14 nós = 140 nós) saíram: as explosões são lascas e fiapos nas duas MultiMesh.
`hero_paint` (`saturation` 1,8), `emeth` (teto pelo maior canal) e `crowd` (corpo um quarto mais escuro) só no
estilizado. Estado: provisório até a revisão do art-director e o aceite do combat-feel-director.

Passe de VFX, correções do Lote 1 e Lote 2 (technical-artist, 2026-11-20; procedural, licença do projeto, sem textura
nova): novos `family_mark` (formas das famílias no chão, pool de 12 quads, `Fx.family_mark`) e `crystal_spike` (espinhos
do Corte do Juízo, pool de 14, `CylinderMesh` de 4 lados sem tampa, 8 triângulos cada). Mexidos: `contact` (miolo em
estrela de 5 pontas), `impact` (premul com teto), `glint` (aro fora do corpo do herói), `chip` (forma por lasca), `slash`
(`family`), `smoke_ring` (`closing`), `soul_crescent` (premul, borda roída), `ritual_rune` (`eruption_cap`), `ult_rift`
(sem faixa chapada), `ult_vortex` (véu 0,15, `ink`, braços partidos), `crowd` (casca de gelo, pisca de Morvath no
violeta, brasa da morte), `ground.gdshaderinc` (`circle_rim` 0,62). Estado: provisório até a revisão do art-director.

AP-2 "Combate que se lê" (technical-artist, 2026-11-21; procedural, licença do projeto, sem textura nova): novo
`dodge_ghost` (silhuetas de tinta da esquiva, V-08: a pose do herói assada por `MeshInstance3D.bake_mesh_from_current_skeleton_pose`
num pool de até 8 malhas no `Fx`, 4 por esquiva, 0,12 s cada; nada sem tela). Mexidos: `ritual_rune` (`fill_early`,
`fill_late`, `red_after`), `ground.gdshaderinc` (`sign_early`, `sign_level`), `boss_scythe` (`hero_hole`, `hero_keep`),
`smoke_ring` (`thin_reach`), `emeth` (`return_thread`, o fio do Retorno do Corte). Estado: provisório até a revisão do
art-director e o aceite do combat-feel-director.

## 8a. Conjunto de aquecimento dos shaders (P1-1, `Warmup`, gerado, licença do projeto)
- `assets/warmup/warmup_set.res` (31 KB, no pacote): 139 cópias leves de material (sem textura), colhidas por
  `tools/make_warmup.sh`; desenhado pelo `scripts/render/warmup.gd` no começo. Definitivo enquanto for regerado depois
  de cada shader novo (`tests/test_warmup.gd` falha sem isso).

## 8c. Esboço dos inimigos e motivos dos Dons (AP-4, procedural, licença do projeto)
- Esboço a tinta do Compêndio (`FigureSketch`): nenhum arquivo novo de imagem; quatro shaders
  (`figure_sketch*.gdshader`) sobre os assados de sempre. Definitivo quando o ui-ux-designer ligar no `FigureView`.
- Motivos dos 19 Dons (`TalentMotif`): vetor no código, sem textura. Provisório até a revisão do art-director da prancha
  (`tools/motif_sheet.gd`) e a ligação no `TalentNode`.
- Aro dos medalhões desenhados (`BoonIcon.ring`): o perfil do aro do `vapor.png`; os PNG de grade (`brasas`, `escudo`,
  `toque_geada`, `onda_maior`, 384 px) têm um aro mais fino e mais claro que o do `vapor`/`aurora`/`redemoinho` (512 px):
  dois aros pintados no jogo, para a prancha nova do Daniel (Q-24) igualar.

## 8b. Kit de borda e primeiro plano (TA-HB2, `EdgeKit`, procedural, licença do projeto)

`scripts/game/edge_kit.gd`, shaders `edge_piece.gdshader` (+ `.gdshaderinc`) e `edge_piece_paint.gdshader`. Nenhuma
textura nova, nada no pacote além dos scripts e shaders. Medido no tabuleiro `tools/edge_lab.gd` (CPU, peças soltas
antes do `Masonry.merge`; a sala junta a pedra com a dela):

| Peça | Triângulos | Chamadas soltas | Material |
|---|---|---|---|
| `broken_pillar` (r 0,55, 3,4 m, dois tambores caídos) | 944 | 14 | cantaria da sala com `see_through` |
| `broken_arch` (4 m de vão, dois pilares) | 660 | 22 | idem |
| `rubble` (1,8 m) | 220 | 12 | idem |
| `root_curtain` (4 x 3,5 m) | 2 710 | 1 | `bark` |
| `ivy` (2,4 x 3 m) | 1 424 | 1 | `ivy` (cor no vértice) |
| `chain_weight` (4,5 m solta, mais 4 m presa nas duas pontas com 0,9 m de flecha; refeita pela revisão de 2026-11-20) | 3 056 as duas (cerca de 1 400 a solta) | 15 as duas, antes do `merge` | `iron` (elos próprios em MultiMesh: 0,13 m, fio 0,04, olho aberto, um em dois a 90 graus, passo 0,27 m; olhal) e pedra (contrapeso octogonal lavrado de 0,7 m com cinta de ferro) |

As seis juntas depois do `merge`: 22 chamadas no quadro do tabuleiro (4 do chão). Estado: provisório até o
environment-artist usar numa sala (ENV-HB3 a HB5) e o art-director revisar. Capturas `docs/gallery/hb/edge_kit_*.png`.

## 9. Música (`audio/music/`, teto no pacote 18 MB; MUS-1: 16,69 MB no disco e **17,73 MB importados**)

Ogg Vorbis 44,1 kHz estéreo. Escolha por lugar em `MusicCatalog` (`core/music_catalog.gd`).

| Peça | Arquivos | Origem e licença | Disco | Pacote | Duração | LUFS / dBTP por camada | Estado |
|---|---|---|---|---|---|---|---|
| Marcha das Lâminas (MUS-1), **padrão no título e nas salas** | `blade_march_1.ogg`, `_2.ogg` (qualidade 2) | síntese do projeto (`tools/make_music.gd`, código escrito por IA) | 1,36 MB | ~1,44 MB | 66,7 s | caminhada -21,9 / -9,1; com a luta -20,1 / -3,9 | provisório até o PO ouvir |
| Tambores do Fundo (MUS-1) | `deep_drums_1.ogg`, `_2.ogg` (2) | síntese do projeto | 1,43 MB | ~1,52 MB | 64 s | -21,9 / -8,7; -20,0 / -4,5 | provisório até o PO ouvir |
| Pulso de Ferro (MUS-1) | `iron_pulse_1.ogg`, `_2.ogg` (2) | síntese do projeto | 1,34 MB | ~1,42 MB | 62,6 s | -22,0 / -6,4; -20,1 / -3,3 | provisório até o PO ouvir |
| Morvath, a Batalha (MUS-1), **padrão na luta** | `morvath_battle_1..4.ogg` (2) | síntese do projeto | 2,58 MB | ~2,73 MB | 64 s | fases 1 a 4: -22,6 / -21,4 / -20,5 / -19,4, -6,4 a -4,9 dBTP | provisório até o PO ouvir |
| Catacumbas (original), para escolher | `classic_catacombs_1.ogg`, `_2.ogg` (1, do .wav) | síntese do projeto | 1,60 MB | ~1,69 MB | 96 s | -21,7 / -10,7; com a luta -20,1 / -4,8 | definitivo (opcional) |
| Morvath (original), para escolher | `classic_morvath_1..4.ogg` (1, do .wav) | síntese do projeto | 2,22 MB | ~2,35 MB | 64 s | fases -27,9 / -23,1 / -20,7 / -19,3 | definitivo (opcional) |
| Salmos | `psalm_{sentinel,shelter,shepherd,rock}.ogg` (1, do .wav) | síntese do projeto | 0,49 MB | ~0,52 MB | 16 a 16,7 s | -20,4 a -14,8 / -4,6 a -4,3 | definitivo |
| Vitória | `victory.ogg` (1, do .wav) | síntese do projeto | 0,09 MB | ~0,10 MB | 12,6 s | -22,8 / -4,5 | definitivo |
| "Tempting Secrets" (título, para escolher) | `title.ogg` (0, reencodado do q3) | Kevin MacLeod, CC BY 4.0 | 1,11 MB | ~1,18 MB | 172 s | -22,1 / -4,4 | definitivo (opcional) |
| "Oppressive Gloom" e "The Descent" | `catacombs_1.ogg`, `catacombs_2.ogg` (0) | Kevin MacLeod, CC BY 4.0 | 2,31 MB | ~2,45 MB | 165 e 163 s | -21,2 / -4,9 | definitivo (opcional) |
| "Clash Defiant" (4 seções) | `morvath_1..4.ogg` (0) | Kevin MacLeod, CC BY 4.0 | 2,17 MB | ~2,30 MB | 67,8 s | -22,0 a -19,0 | definitivo (opcional) |

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
