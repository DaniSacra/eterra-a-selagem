# Conteúdo feito com IA (para a declaração da Steam)

A Steam pede que se declare todo conteúdo feito com ajuda de IA, tanto o que vai pronto no jogo ("pré-gerado") quanto o
que for gerado durante o jogo (este jogo não gera nada ao vivo). Manter esta lista em dia.

## Pré-gerado
- **Arte de referência do Daniel (toda feita por IA, confirmado em 2026-11-14)**: a imagem da arena
  ("Arena das Catacumbas: Golpe Dourado"), as três imagens conceituais do hub em `docs/art/ref/hub/` (2026-11-19, base da `docs/design/hub_spec_art.md`), as cinco imagens conceituais do pacote de rejogabilidade em `docs/art/ref/rejogabilidade/` (2026-11-19, só planejamento), a ficha do herói com a espada Emeth, a folha do Explorador, a prancha "Inimigos da Fase 1" (docs/art/enemies_phase1.md) e a nova imagem da Emeth (2026-11-15). Também são de IA (o Daniel confirmou em 2026-11-16 que todas as imagens de referência foram feitas por IA): as quatro imagens de Morvath em `docs/art/ref/morvath/` (2026-11-15: `foice_laminas_1`, `foice_laminas_2`, `ritual_escudo_erupcoes` e a "Câmara circular do Selo de Morvath", `camara_do_selo`, base da arena circular do chefe, `docs/art/boss_chamber_spec.md`) e as cinco imagens conceituais de arenas do ciclo 12 em `docs/art/ref/cycle12_maps/` (2026-11-16: prancha do mapa das catacumbas, salão da fenda, árvore sobre o abismo, jardim da árvore, quatro reinos; pedido em `docs/design/cycle12_arenas_brief.md`). Não vão no jogo, mas o jogo foi
  desenhado a partir delas: as arenas em plataforma sobre o abismo (`Arena._platform`, `ArenaKit`, shaders do chão,
  da névoa e do portal) e a espada Emeth (`EmethSword`).
- **Arte da tela de título (vai no jogo)**: `assets/ui/title/title_screen_reference.png` (2026-11-15, feita por IA para o
  Daniel): os quatro heróis, a fortaleza, o portal e o logotipo "Crônicas de Eterra: A Selagem". No jogo entra uma cópia
  com os botões pintados apagados (os botões reais são da Godot por cima); o logotipo é o da imagem. O retrato do herói no HUD (`assets/ui/hud/hero_portrait.png`) é o rosto do Explorador
  recortado dessa mesma arte, e o fundo das faixas fora de 16:9 (`assets/ui/title/title_fill.png`) é uma cópia pequena e
  desfocada dela (`tools/make_title_bg.sh`, ffmpeg); a cópia limpa `title_bg.png` também sai dela.
- **Medalhões pintados da tela de dons (vão no jogo, 2026-11-16)**: `assets/ui/boons/vapor.png`, `aurora.png` e
  `redemoinho.png` (Vapor, Aurora Gelada e Redemoinho de Fogo), recortados por `tools/cut_medallions.gd` da prancha de
  medalhões feita por IA para o Daniel (`docs/art/ref/boon_cards/02_medalhoes.png`, só local). A outra imagem do pedido,
  a tela completa com as três cartas (`docs/art/ref/boon_cards/01_tela_tres_dons.png`, também de IA, só local), não vai
  no jogo: guiou a composição da tela (`BoonChoice`, `BoonCard`), que é feita com componentes da Godot.
- **Medalhões pintados do pacote de direção de arte (vão no jogo, 2026-11-17, etapa 1A)**: `assets/ui/boons/brasas.png`,
  `toque_geada.png`, `onda_maior.png` e `escudo.png` (Brasas, Toque da Geada, Maré de Luz, Escudo da Vigília) e
  `assets/ui/events/pomegranate.png`, `candles.png`, `passage.png` e `trial_seal.png` (as trocas do Altar Esquecido e o
  selo rachado da maldição da Provação), recortados por `tools/cut_medallions.gd` (modo grade) do atlas de ícones feito por
  IA pelo diretor de arte do PO no ChatGPT (`docs/art/ref/direcao_2026-11-17/pranchas/02-atlas-icones.png`, só local). As
  outras pranchas do pacote (cartas, eventos e as demais) não vão no jogo: guiaram a composição das telas, feitas com
  componentes da Godot e com os textos e números do jogo. Os glifos pequenos do HUD com o mesmo motivo são desenhados em
  código (`BoonIcon.glyph`, `DoorGlyph`).
- **Retratos dos 7 anjos (fonte, 2026-11-21; entram no jogo pelo item AN-1 do backlog)**: `docs/art/angels_src/angel_1..7.png`
  (1024 x 1536), gerados por IA pelo Daniel no ChatGPT a partir da tabela dos anjos (`docs/design/rejogabilidade/sistemas.md`
  4 e 4.1). **No jogo desde 2026-11-21 (AN-1)**: `assets/ui/angels/angel_1..4.jpg` (512 x 768, reduzidos com o ffmpeg dos
  anjos 1 Sarael, 2 Nivael, 3 Lumael e 4 Shomael; recorte do busto no código, `AngelArt`), na tela do Encontro à esquerda das
  cartas. Os anjos 5 a 7 (Velael, Galael, Qeshael) entram com as Bênçãos no AN-2: `assets/ui/angels/angel_5..7.jpg`, mesmo processo.
- **Retratos dos anjos 8 e 9 (2026-11-26)**: Zerael (Peste) e Saarael (Trovão), `docs/art/angels_src/angel_8..9.png` (1024 x 1536), gerados por IA pelo Daniel no ChatGPT a partir de `docs/art/requests/Pedido-ChatGPT-Anjos-8-e-9.txt`; no jogo como `assets/ui/angels/angel_8..9.jpg` (512 x 768, ffmpeg), entram com as Bênçãos V2.
- **Retrato do Guerreiro no Livro de Ahk (vai no jogo, 2026-11-18, etapa 2)**: `assets/ui/hero/warrior_page.png`
  (330 x 400), o Guerreiro pintado em aguada sobre pergaminho, recortado com o ffmpeg da página esquerda da prancha
  "Livro de Akh" (`docs/art/ref/direcao_2026-11-17/pranchas/04-livro-akh.png`, só local), feita por IA pelo diretor de
  arte do PO no ChatGPT. Aparece no capítulo "O Guerreiro" da tela do herói (`HeroScreen`), com as bordas esfumadas no
  papel por shader. O resto da prancha (Ahk e o anotador, o livro, o esqueleto do Compêndio) e as pranchas 05 e 09 não
  vão no jogo: guiaram o livro (`BookSpread`, `book_page.gdshader`), a árvore e os glifos dos Dons (`TalentGlyph`),
  feitos em código com os textos e números do jogo.
- **Modelos 3D do Meshy** (lista completa e ids em `tools/meshy/tasks.json`). Licença: gerados no plano Pro pago do
  Daniel; os modelos são dele, uso comercial liberado, sem crédito obrigatório (Q-01, resposta de 2026-11-21):
  - no jogo: o herói Explorador (`assets/models/meshy/hero_explorer/`, 2026-11-15, gerado a partir da folha do Explorador,
    também feita por IA), com o esqueleto do Meshy; os nove inimigos da fase 1 (`assets/models/meshy/enemy_<id>/`, gerados das
    vistas da prancha "Inimigos da Fase 1" e repintados no Meshy por texto; no jogo entram reduzidos e assados em
    `assets/baked/`, com animações CC0 da Quaternius e do KayKit) e a espada Emeth (`assets/models/meshy/emeth/`,
    gerada da imagem da Emeth enviada pelo Daniel, também feita por IA;
  - no jogo desde 2026-11-27: os onze personagens `*_gpt` (`hero_warrior_gpt`, `hero_maga_gpt`, `enemy_skeleton_gpt`,
    `enemy_runner_gpt`, `enemy_archer_gpt`, `enemy_guard_gpt`, `enemy_mage_gpt`, `enemy_priest_gpt`, e depois `enemy_knight_gpt`, `enemy_priest_elder_gpt`, `enemy_morvath_gpt`), imagem para 3D do Meshy a partir de arte
    pintada feita por IA no ChatGPT e aprovada pelo Daniel; esqueleto do Meshy, animações CC0 da Quaternius e do KayKit. Substituem
    o Explorador, a Maga de imagem e os doze inimigos anteriores (que ficam no repositório, fora do jogo por padrão).
  - no jogo desde 2026-11-23 (M1c): a Maga (`assets/models/meshy/hero_maga_img/`, imagem para 3D da arte 01 do pacote do
    Daniel, feita por IA no ChatGPT), com o esqueleto do Meshy (`hero_maga_img-rigged.glb`) e as mesmas animações CC0 da
    Quaternius levadas ao corpo dela (`maga_anims.res`, `tools/bake_hero.gd -- maga`; nenhuma animação gerada por IA), e o
    bastão de duas pontas (`assets/models/meshy/w_maga_staff/`, texto para 3D do Meshy descrevendo o bastão da arte 01;
    no jogo, duas cópias da cabeça unidas na mão). Prévias só de malha por texto em `hero_maga/` (fora do jogo).
  - no jogo desde 2026-11-21 (peças aprovadas pelo Daniel, geradas no plano Pro, prompts em `tools/meshy/prompts.json`):
    armas que entram nas mãos dos inimigos assados (`assets/models/meshy/w_cleaver`, `w_knight_sword`, `w_knight_shield`,
    `w_staff`, `w_morvath_scythe`; o cabo longo da foice é um cilindro feito em código), a estátua encapuzada do Salão
    (`statue_hooded`) e o leão sentado do Santuário (`lion_seated`; só a malha, a pedra é do material das salas);
  - fora do jogo e do repositório desde 2026-11-19 (DT-107): o herói "Sombra" e o `paladin_1` (só no histórico do git).
- **Código, shaders e textos**: escritos com assistentes de IA (Claude, Codex).
- **Leão do selo da Câmara do Selo** (vai no jogo, 2026-11-15): desenho vetorial do leão rampante
  (`assets/textures/seal/lion.svg`) escrito à mão em SVG por um assistente de IA (Claude), sem gerador de imagem; o
  campo de distância `lion_sdf.res` sai dele por `tools/make_seal_lion.gd`. Toda a cenografia da câmara é geometria e
  shader (`BossChamber`, `chamber_*.gdshader`), sem modelo nem textura gerada.
- **Chegada do herói (PT-25-7)**: cometa de luz feito só de quadros e partículas de código e do shader `arrival_impact.gdshader`; nenhum modelo, textura ou áudio novo gerado por IA.

- **Música (vai no jogo, E4-06, 2026-11-17)**: `audio/music/*.ogg`, composta e escrita em código (notas, timbres e
  mixagem em `tools/make_music.gd`) por um assistente de IA (Claude), como o leão do selo: nenhum gerador de música ou
  de áudio por IA, nenhuma amostra gravada; o som sai da síntese do próprio script. MUS-1 (2026-11-18): as peças de
  luta "Marcha das Lâminas", "Tambores do Fundo", "Pulso de Ferro" e "Morvath, a Batalha"
  (`audio/music/blade_march_*`, `deep_drums_*`, `iron_pulse_*`, `morvath_battle_*`), do mesmo jeito.
- **Ambiência das salas (vai no jogo, C15-04)**: `audio/ambience/amb_*.ogg`, laços sintetizados em código
  (`tools/make_ambience.gd`) escrito por um assistente de IA (Claude), como a música: nenhum gerador de áudio por IA.
- **Selos dos quatro anjos e gente do hub (vão no jogo, 2026-11-19)**: os selos (`AngelSeal`,
  `scripts/ui/angel_seal.gd`) são desenho vetorial em código escrito por um assistente de IA (Claude), sem gerador de
  imagem; o Vendedor e o Forjador do hub são bonecos do KayKit (CC0) repintados e assados pelo `tools/bake.gd`, sem IA
  na arte.

- **Medalhões pintados à mão, Rev. 02 (vão no jogo, 2026-11-23)**: os 25 de `assets/ui/rewards/` (portas e escadas:
  recompensas, tipos de sala e os 7 anjos) e 70 dos 77 de `assets/ui/boons/` (os 7 de antes ficaram), gerados por IA
  pelo diretor de arte do PO no ChatGPT (pacote `Eterra_Pintura_Medalhoes_PARTE_1..3`, relatório em
  `docs/art/medallions_rev02.md`). Única edição nossa: o texto solto no alto de `trial.png` apagado.

- **Ícones pintados, Rev. 03 (vão no jogo, 2026-11-23, substituem a Rev. 02)**: os 25 de `assets/ui/rewards/` e os 77 de
  `assets/ui/boons/`, pintados por IA pelo diretor de arte do PO no ChatGPT, quadrados e sem moldura
  (`Eterra_REV03_01..04`); o recorte redondo e a moldura única são nossos (`tools/art/frame_borderless.gd`).

## Sem IA
- Modelos KayKit (Kay Lousberg, CC0), animações da Quaternius (CC0), fontes Cinzel e Alegreya Sans (OFL), textura
  Rock Surface (Amal Kumar, Poly Haven, CC0).
- Sons gravados: Kenney (CC0), Iwan Gabovitch (qubodup, CC0), rubberduck (CC0), Little Robot Sound Factory (CC BY 3.0);
  músicas de Kevin MacLeod (CC BY 4.0). Lista completa por arquivo em `audio/LICENSES.md`.

- **Revisão de 2026-11-24 (R10)**: nada de imagem, modelo ou som novo por IA desde a Maga (acima). A Maga elemental
  (`ElementBook`, `ElementLook`, pips de estado `StatePips`), a Videira dos Dons e os 12 Dons provisórios são código e dados escritos
  por um assistente de IA (Claude), sem gerador de imagem nem de áudio; as cores dos três elementos são constantes no código. O modelo
  da Maga continua o do Meshy já declarado, ainda uma prévia a refazer antes do final.

- **Texturas de efeito (2026-11-25, passe de efeitos)**: `assets/textures/fx/star4.png`, `star6.png` (estrelas de impacto),
  `puff_sheet.png` (8 quadros de poeira de osso) e `brush_streaks.png` (riscos de pincel seco) são desenhadas por código
  (`tools/make_fx_textures.gd`, ruído e gradientes em `Image`), escritas por um assistente de IA (Claude), como a música; nenhum
  gerador de imagem, nenhuma imagem de origem, nenhum pacote externo.
