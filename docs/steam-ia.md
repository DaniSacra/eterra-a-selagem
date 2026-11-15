# Conteúdo feito com IA (para a declaração da Steam)

A Steam pede que se declare todo conteúdo feito com ajuda de IA, tanto o que vai pronto no jogo ("pré-gerado") quanto o
que for gerado durante o jogo (este jogo não gera nada ao vivo). Manter esta lista em dia.

## Pré-gerado
- **Arte de referência do Daniel (toda feita por IA, confirmado em 2026-11-14)**: a imagem da arena
  ("Arena das Catacumbas: Golpe Dourado"), a ficha do herói com a espada Emeth, a folha do Explorador, a prancha "Inimigos da Fase 1" (docs/art/enemies_phase1.md) e a nova imagem da Emeth (2026-11-15). Não vão no jogo, mas o jogo foi
  desenhado a partir delas: as arenas em plataforma sobre o abismo (`Arena._platform`, `ArenaKit`, shaders do chão,
  da névoa e do portal) e a espada Emeth (`EmethSword`).
- **Arte da tela de título (vai no jogo)**: `assets/ui/title/title_screen_reference.png` (2026-11-15, feita por IA para o
  Daniel): os quatro heróis, a fortaleza, o portal e o logotipo "Crônicas de Eterra: A Selagem". No jogo entra uma cópia
  com os botões pintados apagados (os botões reais são da Godot por cima); o logotipo é o da imagem.
- **Modelos 3D do Meshy** (lista completa e ids em `tools/meshy/tasks.json`):
  - no jogo: o herói Explorador (`assets/models/meshy/hero_explorer/`, 2026-11-15, gerado a partir da folha do Explorador,
    também feita por IA), com o esqueleto do Meshy; os nove inimigos da fase 1 (`assets/models/meshy/enemy_<id>/`, gerados das
    vistas da prancha "Inimigos da Fase 1" e repintados no Meshy por texto; no jogo entram reduzidos e assados em
    `assets/baked/`, com animações CC0 da Quaternius e do KayKit) e a espada Emeth (`assets/models/meshy/emeth/`,
    gerada da imagem da Emeth enviada pelo Daniel, também feita por IA);
  - sem uso: o herói "Sombra" e o `paladin_1`.
- **Código, shaders e textos**: escritos com assistentes de IA (Claude, Codex).

## Sem IA
- Modelos KayKit (Kay Lousberg, CC0), animações da Quaternius (CC0), sons Kenney (CC0), fontes Cinzel e Alegreya Sans (OFL).
