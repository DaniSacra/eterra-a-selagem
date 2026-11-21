# Crônicas de Eterra: A Selagem

Roguelite de ação em horda, 3D visto de cima (pegada de Hades 2 e Ember & Blade), em **Godot 4.7** (GDScript tipado, GL Compatibility). Spin-off e prelúdio do RPG
"Crônicas de Eterra": quatro paladinos descem às catacumbas sob a igreja velha de Valmor para selar Morvath.
Steam primeiro (Windows e Linux, mouse e teclado ou controle), Android depois.
Projetos irmãos: `../dungeon-rpg` (RPG original em JS, dono do cânone em `docs/mundo/`), `../cronicas-godot`
(RPG em Godot) e `../eterra-survivors` (Valmor Resiste, Phaser). **Não publicar nada no GitHub sem o Daniel pedir.**
**O herói jogável é o Guerreiro** (correção do PO de 2026-11-16; não é o Explorador nem o Guardião): guerreiro ofensivo de
espada, sem bloqueio nem aparo; especificação canônica em `docs/design/warrior_spec.md`, prancha só local em
`docs/art/ref/warrior_art_bible.png`. O título "Punho de Elun" é de Hanokh no cânone; decidido (D-64 a D-71, seguir as recomendações): o jogo mostra só
"O Guerreiro", símbolo do herói é o leão, nada de "Aliança"/"Convênio" nem poder com nome de Elun, especial como onda
(E1b), Fúria em cargas sem barra, primeiro Salmo o da Sentinela. `hero_explorer` continua como nome técnico do modelo; "guardião" no jogo é a sala e os inimigos de minichefe.
Regra central: Dom define o herói, Bênção define a partida, Salmo transforma o poder (`docs/design/po_directive_guardian.md`).

## Regras
- **Entregar em versões MVP completas**: juntar várias mudanças numa versão jogável e só então pedir para o Daniel
  testar tudo de uma vez. Nada de pedir teste a cada ajuste pequeno.
- Código, nomes de arquivos e commits em inglês. Todo texto para o jogador em português do Brasil, **sem travessão**,
  e só em `data/text_pt.tres` (`T.t("chave")`). Nomes dos paladinos: marcadores `PALADIN_1` a `PALADIN_4` (o Daniel define).
- Yah é Deus e Elun é Jesus (alegoria cristã). A luz vem de Elun; não existem outros deuses. Tom de aventura, não de terror.
  Nunca inventar lore: ler `../dungeon-rpg/docs/mundo/canone.md` e perguntar ao Daniel.
- Trabalhar em marcos; terminar e testar um antes do outro; mostrar o jogo rodando ao fim de cada um.
- DRY e KISS, máximo de reuso. Lógica nova entra com teste (GUT).
- **Conteúdo é dado, não código.** Combos, dons, inimigos e ondas são Resources em `data/`. Um combo novo, um dom novo
  (com estatísticas que já existem) ou um inimigo novo (com um comportamento que já existe) não pode exigir código.
- A Steam exige declarar conteúdo gerado por IA: manter `docs/steam-ia.md` em dia.

## Equipe de agentes e economia (2026-11-21, pedido do Daniel: gastar menos)
A sessão principal é o Game Director / Tech Lead: planeja, delega, integra, valida e é a única que faz commit e push.
Subagentes em `.claude/agents/` (protocolo em `docs/development/agent_workflow.md`): `art-director`, `environment-artist`,
`gameplay-engineer`, `ui-ux-designer`, `qa-performance`, `combat-feel-director`, `technical-artist`, `room-designer`,
`balance-designer`, `hero-designer` (os 4 heróis jogáveis e suas 5 habilidades), `game-director` (backlog em `docs/backlog.md`). Cada arquivo tem um dono por tarefa.
- **Tarefa pequena ou média a sessão principal faz direto.** Agente só para frente grande e separada.
- **No máximo 2 agentes ao mesmo tempo.** Nada de "todos os agentes"; nada de rodar a noite inteira "até o fim".
- Agentes rodam no Sonnet (frontmatter `model: sonnet`); art-director e game-director no Opus. Nunca passar `fable`.
- **Ciclos curtos e fechados**: o Daniel pede um lote, entrega com exe e para. Uma conversa nova por lote.
- **Medir pouco**: suíte inteira só na integração (agente roda `-gselect` dos próprios testes); QA e equilíbrio uma vez
  por lote e com poucas sementes (12); capturas só as que alguém vai olhar, uma por vez (WSL de 8 GB, disco C: cheio).
- Agente terminou: relatório curto e para (sem fila de itens novos).
- **Este arquivo fica curto (cerca de 150 linhas).** Detalhe de sistema, números e histórico vão para `docs/reference/`
  (abaixo) ou para o documento de design do item, nunca para cá.

## Comandos
- Godot: `~/tools/godot/godot` (4.7.2). Rodar o jogo: `~/tools/godot/godot --path .`
- Testes: `tools/test.sh` (GUT sem tela). Um arquivo só: `tools/test.sh -gselect=test_combo`
- **Captura na placa de vídeo (preferir)**: `tools/gpu.sh shot saida.png --bot --shot-at=9` (sempre estilizado e câmera Perto, como o jogador vê; o editor sozinho abre no clássico e Longe, então rodar o jogo pelo editor pede `--look=stylized --cam=near`) (cerca de 30 s, Forward+ na RTX 5060
  do Daniel pela Godot de Windows em `C:\Users\danie\tools\godot`, com o projeto espelhado em `C:\Users\danie\tools\eterra-gpu`;
  abre uma janela na tela dele). O WSL não tem Vulkan da GPU (cai no llvmpipe, 2 a 4 min por captura); OpenGL na GPU
  funciona com `MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA GALLIUM_DRIVER=d3d12 LD_LIBRARY_PATH=/usr/lib/wsl/lib` e `--rendering-driver opengl3`.
- Captura sem tela (CPU, lenta): `tools/shot.sh saida.png 3 --bot` (segundos antes da captura; o resto são opções do jogo).
- Opções de teste (depois de `--`): `--bot` (joga sozinho), `--fast=N` (o relógio da partida corre N vezes mais rápido),
  `--start=boss|miniboss|shop|fountain` (sala onde começar), `--showcase` (câmera fixa no enquadramento da imagem de referência; `--cam-yaw`, `--cam-pitch`, `--cam-dist`, `--cam-fov` ajustam), `--horde` (o modo antigo de horda contínua, com `--start=boss|elite1|elite2`), `--shot=arquivo.png`, `--shot-at=segundos`, `--frames=prefixo --count=N --every=s`, `--nosave`, `--smoke` (partida sem tela, imprime `RESULT`), `--runlog[=arquivo]` (grava
  a partida no registro mesmo com o robô ou `--nosave`; sem arquivo, em `user://runs.jsonl`).
- Depois de criar arquivos ou classes novas (`class_name`): `~/tools/godot/godot --headless --path . --import`.
- Regerar os dados (combos, inimigos, dons, ondas, salas, chefes, sensação): `~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [bosses] [feel]`.
  Editar os números em `tools/make_data.gd` (fonte da verdade) e regerar; não editar os `.tres` à mão.
- Achar erros de script sem rodar: `~/tools/godot/godot --headless --path . -s tools/check.gd`.
- Partida sem tela com o robô (rápida, para ritmo e regressão): `tools/smoke.sh 300` (partida inteira) ou `tools/smoke.sh 180 --start=boss --boons=25`.
  Outras opções: `--boons=N` (N dons sorteados), `--boss-hp=0.2`, `--hero-hp=N` (vida do paladino), `--stress=300`, `--title --screen=options|moves|howto`, `--hold`,
  `--autopick` (pega o primeiro dom sem abrir a tela, bom para capturas).
- **Exportação sem converter recursos para binário** (`editor/export/convert_text_resources_to_binary=false` no `project.godot`, 2026-11-19): com a conversão o exe lia o `reward_deck` do estágio vazio (todas as portas com Bênção, loja vazia); `tests/test_export_settings.gd` trava. Conferir o exe com `build/linux/ASelagem.x86_64 --headless -- --smoke=30 --seed=5 --nosave` contra o editor.
- Build: `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`
  (e `"Linux"` em `build/linux/ASelagem.x86_64`). Web para ver no navegador: `tools/web.sh` e abrir `http://localhost:8070`.
  Android fica para depois (sem preset ainda).

## Onde está o detalhe (`docs/reference/`, ler só a seção que a tarefa pede, por grep)
- `engine.md`: arquitetura (simulação no plano, `Game` dono do relógio, `Horde`/`CrowdRenderer`, assados, entrada por
  `Controls`, save em três espaços, registro de partidas, som e música), aquecimento de shaders, sala montada no preto,
  pausa sozinha, pendências conhecidas.
- `gameplay.md`: primeira fase no molde do Hades II, golpes e números, inimigos, Morvath e a Câmara do Selo, corpos
  sólidos, atiradores, atordoamento, C17, C19, onde mexer (Elo, Bênçãos, combos, dons, cartas).
- `rooms.md`: descida (grafo `RunMap`, portas, robô), arenas C12, eventos E5 (Provação, Altar), perigos de sala (Runas,
  lajes, corrente, coluna, raiz, cristal, urna, pedras, nicho, planta), quebráveis.
- `meta.md`: Guerreiro (`HeroDef`, Maestria, Dons, ultimates), Salmos, Juramentos, equilíbrio da região, rejogabilidade
  (materiais, Forja, anjos, Encantos, Fatias 1 a 3), Ofícios.
- `hub.md`: Santuário (planta `HubPlan`, `HubLook`, placas, NPCs, Rev. 02, HV-C a HV-E).
- `ui.md`: título, escolha de save, Livro de Ahk, Compêndio, mapa, cartas, HUD, menus, telas da Fatia 1 a 3 e Ofícios.
- `art_core.md`: direção de arte, modelos (Meshy, KayKit), câmera, raio-x do herói, impacto dos golpes, look estilizado.
- `art_fx.md`: efeitos (VFX, cores das famílias, `RewardShaft`), preparação dos atiradores, Compatibility, esboço do AP-4.
- `art_rooms.md`: cenário das salas (redesenho A a E, Sworn, biomas, vazio, peças dos perigos SW-G7, quebráveis AT-Q2).
- Design e decisões: `docs/design/` (spec do herói `warrior_spec.md`, cadência `combat_cadence.md`, equilíbrio
  `balance.md`, salas `rooms_progression.md`, rejogabilidade, Ofícios), arte em `docs/art/`, QA em `docs/qa/`.

## Essencial do código
- `scripts/core/`: lógica pura, toda testada. `scripts/game/`: nós da partida. `scripts/ui/`: telas. `scripts/render/`:
  assados, multidão, herói.
- Simulação no plano do chão (`Vector2(x, z)` em metros); `Game` chama `step(dt)` de cada sistema; pausa e hit stop são
  "não chamar step". Entrada só por ações (`Controls`), nunca tecla direto.
- Números em `tools/make_data.gd` (fonte da verdade), regerados para `data/`. Texto em `data/text_pt.tres`.
- Look estilizado é o padrão do exe (F7 troca); `VisualProfile.vary` guarda o clássico. Forward+ no desktop é o que
  importa; Compatibility (navegador) é secundário.
- Saves: `user://save_1..3.json` pela camada `Save`; os testes nunca gravam (gancho `tests/hooks/pre_run.gd`, semente 1).
- Mesma semente, mesmo `RESULT` do `--smoke`: toda mudança que não é de gameplay tem de manter isso.
