# Relatório de QA e desempenho: versão final antes do teste do Daniel (ciclo 6)

- **Data**: 2026-11-15, 13:10 a 14:10
- **Branch**: `arpg-3d`, **commit testado `78b0642`** (working tree limpo; só aparece o `tests/test_cam_frame.gd.uid`
  que a importação gera, ver B1).
- **Comparação ("antes")**: o commit do ciclo 5 já com QA, `1709da2`, extraído por `git archive` numa pasta fora do
  projeto e espelhado em `C:/Users/danie/tools/eterra-gpu-head` (`MIRROR=`). Entre os dois entraram: elites desde a
  sala 2, a interface do Elo (`EloLink`, `EloBanner`, `BoonsScreen`), os inimigos do Meshy e a Emeth no jogo
  (`MeshSlim`, multidão assada), o raio-x do herói e o `CamFrame`, a arena do ciclo 6 (abismo, estandartes, portal ogival).
- **Ambiente**: WSL2 (Linux 6.18). Testes e partidas do robô sem tela (Godot 4.7.2 de Linux). Capturas e medidas de
  quadro na **placa de vídeo real** (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan Forward+, Godot 4.7.2 de Windows) por
  `tools/gpu.sh`. **Sem som** (não verificado).

Evidências em `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/final/qa/`
(abaixo, `qa/`), capturas em `qa/shots/`.

## Veredito

**Pronto para o Daniel testar.** 0 `SCRIPT ERROR` e 0 `Parse Error` em todas as execuções; 161 testes, 160 passando,
0 falhando, 1 arriscado (o conhecido); o robô chega em Morvath (sala 5) nas cinco sementes; a versão de Windows exporta
e roda na placa de vídeo sem erro; o custo na placa fica dentro do guarda (no máximo +0,38 ms por quadro com 90
inimigos, e o jogo fica entre 128 e mais de 1000 quadros por segundo em todas as cenas medidas). Dois achados médios
de interface sobre os elites (M1) e um aviso para o teste (M2: o elite só aparece se o Daniel escolher uma porta de
luta na sala 2). O critério visual é do `art-director` e do Daniel.

## 1. Checagem, testes e partidas do robô

| Comando | Resultado | Saída |
|---|---|---|
| `godot --headless --path . --import` | ok, 0 erro de script | `qa/import.txt` |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok`, 0 SCRIPT ERROR, 0 Parse Error | `qa/check.txt` |
| `tools/test.sh` | **16 arquivos, 161 testes, 160 passando, 0 falhando, 1 arriscado** (`test_only_finishers_glint`, "Did not assert"), 13479 asserções, 3,7 s | `qa/test.txt` |

No ciclo 5 eram 12 arquivos e 137 testes; entraram `test_cam_frame`, `test_elo`, `test_mesh_slim`, `test_retarget`.

Partidas do robô (`tools/smoke.sh`, sem tela, `--fixed-fps 60`):

| Comando | Sala | Modo | Tempo | Abates | Dons | Vida de Morvath | step_ms |
|---|---|---|---|---|---|---|---|
| `300 --seed=5` | 5 (Morvath) | OVER (perdeu) | 183,5 | 20 | 2 | 2623 (fase 2) | 0,07 |
| `120 --start=boss --boons=25 --seed=5` | 5 | PLAY (Morvath com 5) | 118,3 | 21 | 8 | 5 (fase 3) | 0,11 |
| `120 --stress=300 --seed=5` | 1 | PLAY | 118,1 | 259 (41 de pé) | 0 | | 0,36 |
| `300 --seed=1` | 5 | OVER | 200,7 | 32 | 2 | 1382 (fase 3) | 0,12 |
| `300 --seed=2` | 5 | OVER | 153,1 | 16 | 2 | 3106 (fase 2) | 0,07 |
| `300 --seed=3` | 5 | OVER | 130,0 | 10 | 2 | 4001 (fase 1) | 0,07 |
| `300 --seed=7` | 5 | OVER | 213,4 | 51 | 2 | 994 (fase 3) | 0,17 |

As três primeiras linhas são **idênticas** às do ciclo 5, número por número (só o `step_ms` do `--stress` passou de
0,33 para 0,36, dentro do ruído): nenhuma regra de combate mudou na semente 5. Saídas em `qa/smoke_*.txt`. Em toda
execução seguem o `2 ObjectDB instances leaked` e o `1 resources still in use at exit` (B4).

## 2. Desempenho na placa de vídeo

RTX 5060 Laptop, Vulkan Forward+, janela 1672 x 941, `--fixed-fps 30 --disable-vsync`, `--seed=5`. Sonda
`C:/Users/danie/tools/qa/gpuperf.gd`: descarta 300 quadros (compilação dos shaders) e mede os 300 seguintes. "Quadro" é
o tempo real entre quadros (CPU e GPU, com a simulação); "GPU" é `viewport_get_measured_render_time_gpu`. Três rodadas
alternando antes e depois; a tabela mostra a mediana das três medianas (as 24 linhas em `qa/gpu_perf.txt`; script
`final/tools/perf.sh`).

| Cena (`--seed=5 ...`) | Quadro antes | Quadro depois | Diferença | FPS depois | GPU antes / depois | p90 do quadro depois | Primitivas antes / depois | Chamadas antes / depois |
|---|---|---|---|---|---|---|---|---|
| `--showcase` | 0,95 ms | 0,95 ms | 0 | 1053 | 0,91 / 0,92 | 1,07 | 65 mil / 69 mil | 62 / 53 |
| `--bot --autopick` (luta) | 2,59 ms | 2,60 ms | +0,01 | 385 | 2,53 / 2,55 | 2,97 | 678 mil / 930 mil | 987 / 1000 |
| `--bot --autopick --stress=90` | 3,34 ms | 3,72 ms | **+0,38** | 269 | 2,56 / 2,61 | 4,45 | 1,16 / 1,34 milhão | 1090 / 1098 |
| `--bot --autopick --stress=300` | 7,68 ms | 7,79 ms | +0,11 | 128 | 2,80 / **3,26** | 8,78 | 2,43 / 2,27 milhões | 1025 / 1001 |

Leitura:
- Guarda do ciclo (no máximo +0,5 ms com `--stress=90`): **passa** com +0,38 ms. As três rodadas do depois deram
  3,72, 3,60 e 3,85; as do antes 3,31, 3,53 e 3,34. A alta é do lado da CPU (o desenho na CPU subiu de 0,92 para
  1,04 ms; a GPU só +0,05).
- Com 300 inimigos a GPU sobe 0,46 ms (2,80 para 3,26, nas três rodadas), mas o gargalo continua a CPU (simulação e
  multidão): o quadro fica em 7,8 ms, 128 por segundo. O commit `faef8d6` dizia "acima de 114 fps": confere.
- Primitivas na luta +37% (inimigos do Meshy com cerca de 3,9 mil triângulos e o cenário do ciclo 6); a GPU não sente.
- Os números absolutos estão mais baixos que os do relatório do ciclo 5 (luta 3,48 ms naquele dia, 2,59 hoje no mesmo
  commit): o estado do notebook muda entre dias. Só a comparação na mesma sessão vale.
- **Não medido**: celular, navegador de verdade (o OpenGL 3 só foi capturado), placa de vídeo fraca.

Na captura com 300 inimigos (`6_horda.png`, Windows, 267 de pé aos 8 s) o `step_ms` da simulação é 2,77 ms; no
`smoke` sem tela, 0,36 ms em média nos 118 s (com 41 de pé no fim).

## 3. Versão de Windows

- `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`: código 0,
  sem `ERROR` nem `SCRIPT ERROR` no log (`qa/export_windows.txt`), `ASelagem.exe` com 191,7 MB (pacote embutido).
- Rodei uma cópia do exe por interoperabilidade do Windows (`ASelagem.exe --resolution 1672x941 -- --nosave --bot
  --autopick --seed=5 --shot=... --shot-at=9`; `qa/exe_run.txt`): `Vulkan 1.4.357 - Forward+ - Using Device #0: NVIDIA
  GeForce RTX 5060 Laptop GPU`, linha `RESULT` com a partida rodando (2 abates aos 8,7 s), **nenhum erro**. A captura
  (`shots/12_exe_windows.png`) mostra a Emeth verde na mão, inimigos pintados e o HUD inteiro. A cópia foi apagada
  depois; não copiei para as pastas de teste do Daniel (isso é do Game Director).

## 4. Capturas reais (abertas e olhadas uma a uma)

Placa de vídeo, Vulkan Forward+, 1672 x 941, `--seed=5` salvo indicação, em `qa/shots/`:

| Arquivo | Comando (depois de `--`) | O que se vê |
|---|---|---|
| `1_arena.png` | `--showcase --shot-at=4` | arena do ciclo 6: correntes sobre o abismo, estandartes vermelhos, portal verde ogival, arcos violeta a oeste, medalhão |
| `2_combate.png` | `--bot --autopick --shot-at=9` | Explorador com a Emeth, aviso vermelho inteiro, Escudo e Feiticeiro do Meshy com barras sobre a cabeça |
| `3_sacerdote.png` | `--start=miniboss --bot --autopick --shot-at=9 --seed=2` | Sacerdote dos Mortos (guardião) com a barra do topo e a armadura amarela, esqueletos chamados |
| `4_elite.png`, `crop_elite.png` | laboratório `final/tools/elite_room.gd` (sala 2 de luta com `guard_elite` na 1ª onda), aos 6 s | Escudo elite em ouro velho e contorno escuro ao lado do herói; ver M1 |
| `5_medalhao.png` | `--showcase --cam-dist=32 --shot-at=4` | medalhão de pedra de perto, runas e bronze |
| `6_horda.png` | `--bot --autopick --stress=300 --shot-at=8` | 267 inimigos; herói na frente do bolo, lido |
| `7_morvath.png` | `--start=boss --bot --autopick --shot-at=12` | Morvath, arco de aviso inteiro, portal vermelho, barra do chefe; herói coberto por Morvath aparece em raio-x |
| `8_horda90.png`, `crop_horda90.png` | `--bot --autopick --stress=90 --shot-at=6` | herói **dentro** do bolo, achável pela silhueta petróleo e pelo anel |
| `9_cercado40.png`, `crop_cercado40.png` | `--bot --autopick --stress=40 --shot-at=7` | herói no patamar oeste, a cerca de 18% da borda esquerda (x 307 de 1672) |
| `10_combate_1920.png` | `RES=1920x1080`, como o 2 | HUD inteiro e proporcional em 1920 x 1080 |
| `11_titulo.png` | `--title --shot-at=3` | título com o Explorador; ver B3 |
| `elo_card.png`, `elo_formed.png`, `elo_formed_late.png`, `elo_panel.png` | `tools/ui_lab.gd` em 1280 x 720 | carta do Elo com a corrente de ouro e os dois dons de origem, "Elo formado" sem pausar, painel "Seus dons" com 8 dons cabendo |
| `12_exe_windows.png` | o `ASelagem.exe` exportado | ver seção 3 |
| `13_combate_opengl3_gpu.png` | `--rendering-driver opengl3`, como o 2 | renderizador do navegador na placa: nada falta, mais claro e mais saturado, como esperado |

Itens do relatório anterior conferidos nas capturas:
- **M3 antigo (herói na borda oeste)**: resolvido. No `9_cercado40.png` o herói fica em x 307 (18,4% da largura); no
  ciclo 5 ficava a cerca de 11%.
- **M4 antigo (herói some no bolo)**: muito melhor. No `crop_horda90.png` a silhueta petróleo com borda clara e o anel
  acham o herói de imediato; no `crop_cercado40.png` ele estava no clarão branco do golpe recebido, ainda achável pelo
  anel e pelo cabelo. A silhueta lê mais ciano que "as cores dele" (decisão do `art-director`).
- **M1 antigo (nenhum elite aparece)**: resolvido na regra, com ressalva (M2 abaixo).
- **M2 antigo (elite igual ao comum)**: o ouro velho e o contorno escuro separam o Escudo elite do comum lado a lado
  (`crop_elite.png`).
- **B2 antigo (`docs/steam-ia.md`)**: resolvido, cita o Explorador, os nove inimigos e a Emeth do Meshy.

## 5. Falhas e regressões por gravidade

Nenhuma crítica nem alta.

### Média

**M1. Todo elite comum ganha a barra de chefe no topo da tela, com o nome do inimigo comum.** Novo para o jogador
(antes nenhum elite comum aparecia nas salas). Responsável: Gameplay Engineer (`scripts/game/game.gd:773`
`boss_enemy`), com o UI/UX (`scripts/ui/hud.gd:287` `_update_boss`).
`boss_enemy()` devolve o primeiro inimigo com `def.elite` da horda (`game.gd:776-778`), e o HUD mostra a barra grande
do topo para ele. Efeito: numa sala 2 com `guard_elite` aparece "Esqueleto de Escudo" na barra de chefe
(`shots/4_elite.png`), igual ao guardião; com dois elites, só o primeiro tem barra no topo. No Hades II os inimigos
blindados comuns só têm a barra sobre a cabeça; a barra do topo é dos guardiões e do chefe. Passos: rodar
`final/tools/elite_room.gd` (comando no topo do arquivo) ou, jogando, escolher na sala 2 uma porta que não seja a da
fonte até sair um elite. Sugestão: só `Behavior.BOSS` e os `stage.minibosses` na barra do topo; decisão do Game Director.

**M2. O robô nunca vê um elite, e o Daniel só vê se escolher a porta certa na sala 2.** Não é falha de código; é
aviso para o teste. Responsável: Game Director (instrução de teste) ou Gameplay Engineer (`tools/make_data.gd` `_stage`).
Medido com `final/tools/elite_odds.gd` (geração real, 1000 sementes): sala 1, 0 de 1000 com elite; sala 2 de luta,
**764 de 1000** com elite. Mas na sala 2 a porta 0 é **sempre** a fonte (200 de 200 sementes, `run_map.gd:58`, porque
`fountain_depth_min = fountain_depth_max = 2`), e o robô sempre pega a porta 0 (`rooms.gd:310` `bot_goal`,
`door_goal(0)`). Por isso as partidas do robô são idênticas às do ciclo 5. Para ver um elite o Daniel precisa pegar a
porta de luta na sala 2 (abrindo mão da fonte).

### Baixa
- **B1. `tests/test_cam_frame.gd.uid` não está no commit**: a importação gera e o working tree fica sujo
  (`git status`: `?? tests/test_cam_frame.gd.uid`). Game Director (commitar o arquivo).
- **B2. No `2_combate.png` um Feiticeiro fica atrás da barra de ações** (centro inferior), parte do corpo coberta pelo
  HUD. O `CamFrame` só protege o herói. Leitura de borda; UI/UX decide se vale.
- **B3. Espaçamento irregular das palavras na premissa do título** ("traiu a luz", "ergueu os", "sob a igreja";
  `11_titulo.png`), vem do ciclo 4. UI/UX.
- **B4. Vazamento ao sair** (`2 ObjectDB instances leaked`, `1 resources still in use`), igual a antes.
- **B5. Mancha violeta do abismo leste ainda com a borda esquerda reta** em `7_morvath.png` (canto direito), vinda do
  ciclo 4. Environment Artist.

## 6. Limitações
- Desempenho medido só no notebook do Daniel (RTX 5060), uma janela de 1672 x 941; variação entre rodadas iguais de
  até 0,5 ms. **Não medido**: celular, navegador de verdade, placa fraca, Linux exportado, Web exportado (não pedidos).
- Sem som; sem gente jogando (só o robô): sensação, ritmo e leitura em movimento ficam para o Daniel.
- A captura do elite usa um laboratório de QA fora do projeto (`final/tools/elite_room.gd`, chama `rooms._enter` com uma
  sala de luta da profundidade 2); o elite em si é o do jogo, a sala é a mesma que o jogador encontra.
- Mudei só arquivos fora do projeto e este relatório; o espelho `C:/Users/danie/tools/eterra-gpu-head` agora tem o
  `1709da2`. Nenhum crédito externo usado.
