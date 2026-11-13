# Crônicas de Eterra: A Selagem

Roguelite de ação em horda, 3D visto de cima (pegada de Hades 2 e Ember & Blade), em **Godot 4.7** (GDScript tipado, GL Compatibility). Spin-off e prelúdio do RPG
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
  `--start=boss|elite1|elite2`, `--shot=arquivo.png`, `--shot-at=segundos`, `--frames=prefixo --count=N --every=s`, `--nosave`, `--smoke` (partida sem tela, imprime `RESULT`).
- Depois de criar arquivos ou classes novas (`class_name`): `~/tools/godot/godot --headless --path . --import`.
- Regerar os dados (combos, inimigos, dons, ondas): `~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves]`.
  Editar os números em `tools/make_data.gd` (fonte da verdade) e regerar; não editar os `.tres` à mão.
- Achar erros de script sem rodar: `~/tools/godot/godot --headless --path . -s tools/check.gd`.
- Partida sem tela com o robô (rápida, para ritmo e regressão): `tools/smoke.sh 1100` ou `tools/smoke.sh 300 --start=boss --boons=25`.
  Outras opções: `--boons=N` (N dons sorteados), `--boss-hp=0.2`, `--stress=300`, `--title --screen=options|moves`, `--hold`.
- Build: `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`
  (e `"Linux"` em `build/linux/ASelagem.x86_64`). Web para ver no navegador: `tools/web.sh` e abrir `http://localhost:8070`.
  Android fica para depois (sem preset ainda).

## Direção de arte e modelos
- Referência atual: Hades 2 e Ember & Blade (vídeos do Daniel). Mesmo gênero, mecânica e sensação; nada copiado
  (personagens, nomes, UI e visual são de Eterra). A versão 2D em pixel art está na tag `v1-pixel-2d`.
- Modelos **provisórios**: KayKit (Kay Lousberg, CC0) em `assets/models/` (personagens, masmorra, armas).
  Fontes Cinzel e Alegreya Sans (OFL) em `assets/fonts/`.
- Efeitos: `scripts/game/fx.gd` (partículas, cortes, anéis, feixes, números, hit stop, tremor) e shaders em `assets/shaders/`.
  Brilho pelo glow do `WorldEnvironment` (cores acima de 1 brilham).

## Arquitetura
- `scripts/core/`: lógica pura (sem nós), toda testada. `scripts/game/`: nós da partida. `scripts/ui/`: telas.
  `scripts/render/`: modelos assados e a multidão.
- A simulação é no plano do chão: posições `Vector2(x, z)` em metros; o desenho é 3D.
- `scripts/game/game.gd` é dono do relógio: chama `step(dt)` de cada sistema. Hit stop, pausa e a escolha de dom são
  só "não chamar step". Cada sistema que emite sinal dentro do laço (golpe que mata o paladino limpa tudo) precisa
  aguentar a lista mudar no meio (ver `Ground.step`, `Projectiles.step`).
- **Multidão**: inimigos são objetos leves em `Horde`; o desenho é `CrowdRenderer`, um MultiMesh por (inimigo, animação,
  quadro). As poses vêm assadas: `tools/bake.gd` esqueleta os modelos KayKit em malhas estáticas (`assets/baked/*.res`,
  `BakedModel`). Modelo ou animação nova de inimigo: editar `MODELS` em `tools/bake.gd` e rodar
  `~/tools/godot/godot --headless --path . -s tools/bake.gd [-- ids]`. A multidão fica fora da luz das tochas (camada 2)
  e recebe a luz do paladino pelo global `hero_pos`.
- O paladino é o Knight com `AnimationPlayer` de verdade (`scripts/game/player.gd`).
- Dons agem sozinhos por `SkillDef` (`scripts/game/skills.gd`: STRIKES, NOVA, ORBIT, FAN, METEOR, CONSECRATE) e/ou
  mudam golpes por `BoonMod`.
- Entrada só por ações (`Controls`): `light_attack`, `heavy_attack`, `dodge`, mira (`Controls.aim`). Nunca ler tecla direto.
  Toque e robô usam `Controls.VirtualPad`. Toques durante o hit stop ficam guardados (`Controls.flush`).
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`).
- Som: `scripts/audio.gd` (receitas sintetizadas, provisórias). Um arquivo `audio/<nome>.ogg` substitui a receita.
  Música desligada por enquanto.

## Onde mexer
- Combos: `data/combos/paladin.tres` (nós `ComboNode`; `tags` é o que os dons enxergam). Dons: `data/boons/*.tres`
  (`BoonMod`: `stat`, `tag`, `values` por nível; as estatísticas que o jogo conhece estão em `scripts/game/combat.gd` e
  `game.gd` `_take`). Inimigos: `data/enemies/*.tres`. Ondas, elites, fonte e chefe: `data/waves/catacombs.tres`.
- Morvath: `scripts/game/boss.gd` (estados) e `scripts/core/boss_rules.gd` (fases e padrões, testados).
- Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`).

## Pendências conhecidas
- Equilíbrio medido só com o robô: partindo do zero ele chega vivo aos 9 minutos, no nível 35; com 20 dons ele vence
  Morvath. Falta teste com gente. Os números estão em `tools/make_data.gd`.
- Modelos KayKit, fontes e áudio sintetizado são provisórios. Assados somam cerca de 46 MB (o pacote web tem 61 MB).
- O lobo de geada do spec virou o esqueleto corredor. Vigília aparece como voto do PALADIN_1 (provisório).
- O spec fala em quatro paladinos; o cânone de 12/11 fala em um paladino do leão e quatro guardiões. Vale o que o Daniel decidir.
- Toque (celular) ainda não tem botões na tela.
- Desempenho: cerca de 1 ms por passo com 150 inimigos no PC; não medido em celular nem em placa de vídeo fraca.
