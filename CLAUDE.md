# Crônicas de Eterra: A Selagem

Roguelite de ação 2D em **Godot 4.7** (GDScript tipado, GL Compatibility). Spin-off e prelúdio do RPG
"Crônicas de Eterra": quatro paladinos descem às catacumbas sob a igreja velha de Valmor para selar Morvath.
Steam primeiro (Windows e Linux, mouse e teclado ou controle), Android depois.
Projetos irmãos: `../dungeon-rpg` (RPG original em JS, dono do cânone em `docs/mundo/`), `../cronicas-godot`
(RPG em Godot) e `../eterra-survivors` (Valmor Resiste, Phaser). **Não publicar nada no GitHub sem o Daniel pedir.**

## Regras
- Código, nomes de arquivos e commits em inglês. Todo texto para o jogador em português do Brasil, **sem travessão**,
  e só em `data/text_pt.tres` (`T.t("chave")`). Nomes dos paladinos: marcadores `PALADIN_1` a `PALADIN_4` (o Daniel define).
- Yah é Deus e Elun é Jesus (alegoria cristã). A luz vem de Elun; não existem outros deuses. Tom de aventura, não de terror.
  Nunca inventar lore: ler `../dungeon-rpg/docs/mundo/canone.md` e perguntar ao Daniel.
- Trabalhar em marcos; terminar e testar um antes do outro; mostrar o jogo rodando ao fim de cada um.
- DRY e KISS, máximo de reuso. Lógica nova entra com teste (GUT).
- **Conteúdo é dado, não código.** Combos, dons, inimigos e ondas são Resources em `data/`. Um combo novo, um dom novo
  (com estatísticas que já existem) ou um inimigo novo (com um comportamento que já existe) não pode exigir código.
- A Steam exige declarar conteúdo gerado por IA.

## Comandos
- Godot: `~/tools/godot/godot` (4.7.2). Rodar o jogo: `~/tools/godot/godot --path .`
- Testes: `tools/test.sh` (GUT sem tela). Um arquivo só: `tools/test.sh -gtest=res://tests/test_combo.gd`
- Captura sem tela: `tools/shot.sh saida.png 3 --bot` (segundos antes da captura; o resto são opções do jogo).
- Opções de teste (depois de `--`): `--bot` (joga sozinho), `--fast=N` (o relógio da partida corre N vezes mais rápido),
  `--start=boss|elite1|elite2`, `--shot=arquivo.png`, `--shot-at=segundos`, `--nosave`, `--smoke` (partida sem tela, imprime `RESULT`).
- Depois de criar arquivos ou classes novas (`class_name`): `~/tools/godot/godot --headless --path . --import`.
- Regerar a arte: `python3 tools/art/build.py` (escreve `art/grids/*.json`).
- Build: `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`
  (e `"Linux"` em `build/linux/ASelagem.x86_64`).

## Direção de arte (bíblia de arte de Eterra, `../dungeon-rpg/docs/arte/estilo.md`)
- "Aventura luminosa": Dragon Quest, Chrono Trigger, Sea of Stars. Cores vivas, perigo sem horror.
- Base 320x180, escala inteira, filtro nearest, nada desfocado. Sprites no tamanho em que aparecem.
- **Paleta fechada**: `data/palette.tres` (cópia de `src/palette.js` do RPG). Cor nova só entra primeiro na paleta.
  Um teste reprova qualquer grade com cor de fora.
- Contorno escuro da própria cor, nunca preto puro. Cenário sem contorno. Luz do alto à esquerda, 3 ou 4 tons, sem degradê.
- **Formato de sprite**: grade de strings, uma letra por cor (`art/grids/*.json`), lida por `art/grid_sprite.gd`
  (porte de `src/gridsprite.js`), que cria `ImageTexture` e `SpriteFrames`. Variantes por troca de paleta
  (`GridSprite.recolor_hex`, `Art.add_variant`; `flash` e `frozen` já existem para todo sprite).
- As grades são escritas pelas ferramentas em `tools/art/*.py` (um esqueleto por tipo de personagem, uma pose por quadro).
- **Trocar por PNG desenhado à mão**: pôr `art/png/<nome>.png` (tira horizontal, mesmo tamanho de quadro e mesma ordem
  da grade). `Art` usa o PNG se ele existir. `tools/export_png.gd` exporta as tiras atuais como molde.
- Efeitos com `GPUParticles2D`, luz com `PointLight2D` e `CanvasModulate`, sempre com cores da paleta.

## Arquitetura
- `scripts/core/`: lógica pura (sem nós), toda testada. `scripts/game/`: nós da partida. `scripts/ui/`: telas.
- `scripts/game/game.gd` é dono do relógio: chama `step(dt)` de cada sistema. Hit stop, pausa e a escolha de dom são
  só "não chamar step".
- Inimigos sem nó de física: objetos leves em `EnemySystem`, com pool de `Sprite2D`, grade espacial para separação e
  acerto. Meta: 60 fps com 300 inimigos em celular intermediário.
- Entrada só por ações (`Controls`): `light_attack`, `heavy_attack`, `dodge`, mira (`Controls.aim`). Nunca ler tecla direto.
  No celular, botões na tela alimentam as mesmas ações (`Controls.virtual`, o mesmo caminho do robô de teste).
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`).
