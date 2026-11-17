# Conteúdo feito com IA (para a declaração da Steam)

A Steam pede que se declare todo conteúdo feito com ajuda de IA, tanto o que vai pronto no jogo ("pré-gerado") quanto o
que for gerado durante o jogo (este jogo não gera nada ao vivo). Manter esta lista em dia.

## Pré-gerado
- **Arte de referência do Daniel (toda feita por IA, confirmado em 2026-11-14)**: a imagem da arena
  ("Arena das Catacumbas: Golpe Dourado"), a ficha do herói com a espada Emeth, a folha do Explorador, a prancha "Inimigos da Fase 1" (docs/art/enemies_phase1.md) e a nova imagem da Emeth (2026-11-15). Também são de IA (o Daniel confirmou em 2026-11-16 que todas as imagens de referência foram feitas por IA): as quatro imagens de Morvath em `docs/art/ref/morvath/` (2026-11-15: `foice_laminas_1`, `foice_laminas_2`, `ritual_escudo_erupcoes` e a "Câmara circular do Selo de Morvath", `camara_do_selo`, base da arena circular do chefe, `docs/art/boss_chamber_spec.md`) e as cinco imagens conceituais de arenas do ciclo 12 em `docs/art/ref/cycle12_maps/` (2026-11-16: prancha do mapa das catacumbas, salão da fenda, árvore sobre o abismo, jardim da árvore, quatro reinos; pedido em `docs/design/cycle12_arenas_brief.md`). Não vão no jogo, mas o jogo foi
  desenhado a partir delas: as arenas em plataforma sobre o abismo (`Arena._platform`, `ArenaKit`, shaders do chão,
  da névoa e do portal) e a espada Emeth (`EmethSword`).
- **Arte da tela de título (vai no jogo)**: `assets/ui/title/title_screen_reference.png` (2026-11-15, feita por IA para o
  Daniel): os quatro heróis, a fortaleza, o portal e o logotipo "Crônicas de Eterra: A Selagem". No jogo entra uma cópia
  com os botões pintados apagados (os botões reais são da Godot por cima); o logotipo é o da imagem. O retrato do herói no HUD (`assets/ui/hud/hero_portrait.png`) é o rosto do Explorador
  recortado dessa mesma arte.
- **Medalhões pintados da tela de dons (vão no jogo, 2026-11-16)**: `assets/ui/boons/vapor.png`, `aurora.png` e
  `redemoinho.png` (Vapor, Aurora Gelada e Redemoinho de Fogo), recortados por `tools/cut_medallions.gd` da prancha de
  medalhões feita por IA para o Daniel (`docs/art/ref/boon_cards/02_medalhoes.png`, só local). A outra imagem do pedido,
  a tela completa com as três cartas (`docs/art/ref/boon_cards/01_tela_tres_dons.png`, também de IA, só local), não vai
  no jogo: guiou a composição da tela (`BoonChoice`, `BoonCard`), que é feita com componentes da Godot.
- **Modelos 3D do Meshy** (lista completa e ids em `tools/meshy/tasks.json`):
  - no jogo: o herói Explorador (`assets/models/meshy/hero_explorer/`, 2026-11-15, gerado a partir da folha do Explorador,
    também feita por IA), com o esqueleto do Meshy; os nove inimigos da fase 1 (`assets/models/meshy/enemy_<id>/`, gerados das
    vistas da prancha "Inimigos da Fase 1" e repintados no Meshy por texto; no jogo entram reduzidos e assados em
    `assets/baked/`, com animações CC0 da Quaternius e do KayKit) e a espada Emeth (`assets/models/meshy/emeth/`,
    gerada da imagem da Emeth enviada pelo Daniel, também feita por IA);
  - sem uso: o herói "Sombra" e o `paladin_1`.
- **Código, shaders e textos**: escritos com assistentes de IA (Claude, Codex).
- **Leão do selo da Câmara do Selo** (vai no jogo, 2026-11-15): desenho vetorial do leão rampante
  (`assets/textures/seal/lion.svg`) escrito à mão em SVG por um assistente de IA (Claude), sem gerador de imagem; o
  campo de distância `lion_sdf.res` sai dele por `tools/make_seal_lion.gd`. Toda a cenografia da câmara é geometria e
  shader (`BossChamber`, `chamber_*.gdshader`), sem modelo nem textura gerada.

- **Música (vai no jogo, E4-06, 2026-11-17)**: `audio/music/*.ogg`, composta e escrita em código (notas, timbres e
  mixagem em `tools/make_music.gd`) por um assistente de IA (Claude), como o leão do selo: nenhum gerador de música ou
  de áudio por IA, nenhuma amostra gravada; o som sai da síntese do próprio script.

## Sem IA
- Modelos KayKit (Kay Lousberg, CC0), animações da Quaternius (CC0), sons Kenney (CC0), fontes Cinzel e Alegreya Sans (OFL).
