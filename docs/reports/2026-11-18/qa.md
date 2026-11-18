# QA integrado, fim do ciclo (2026-11-18)

- **Commit testado**: `dd1f5ba` (`arpg-3d`, árvore limpa). Exe Windows em `build/windows/ASelagem.exe` (197 233 336 bytes,
  gerado 12:15, depois do commit das 12:12).
- **Base de comparação**: `fe07159` (fim do QA T5, o commit do `docs/qa/latest_report.md`), cópia por `git archive` em
  `/home/dani/tools/qa1118/base`, importada à parte. Para as partidas do robô, as saídas guardadas do QA T5 em
  `/home/dani/tools/t5qa/runs/` (`h_m1` = `620a21e`, `base_m1` = `5dfe97f`).
- **Saídas brutas** (fora do git): scratchpad da sessão
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/3fad4f71-7d30-45b5-a1d2-8a4280759982/scratchpad/`
  (`tests1.txt` a `tests3.txt`, `tests_verbose.txt`, `flaky/`, `runs/1..8.log`, `stress/`, `gpu/`, `gpu2/`, `trace3.txt`,
  `smk*.txt`, `flow.txt`, `check.txt`) e exports em `/home/dani/tools/qa1118/export/`.

## Resumo (5 linhas)

1. Nenhuma regressão P0. Importação e `tools/check.gd` limpos, **992 de 992 testes em 4 rodadas inteiras** (3 normais e 1 com `--verbose`), 0 arriscados, `FLOW ok`.
2. A instabilidade relatada **não se reproduziu**: 4 suítes inteiras e 8 repetições de `test_descent`, `test_enemy_motion`, `test_enemy_windup` e `test_living_crowd` (32 execuções), todas verdes.
3. Robô (reação 0,25, Maestria 1, sementes 1 a 8): **7 de 8 vitórias**, chega em Morvath aos 254 s em média com 50,5 de vida, 0 presos, 0 erros; a tempestade é metade do dano levado de Morvath e o Ancião metade do dano antes dele.
4. Desempenho sem mudança: passo da simulação com 300 inimigos 4,2 ms antes e depois (3 x 3 alternado); na RTX 5060 o estresse de 300 está preso na CPU (52 a 55 qps em qualquer qualidade, igual ao T5); sem sincronia, a sala 1 roda a 343 / 473 / 527 qps (Alta / Média / Baixa) e Morvath com 25 Bênçãos a 150 a 160 em qualquer qualidade.
5. Achados novos: **P1** uma Provação tomada tarde não termina antes de Morvath (paga vida, carrega a maldição até o fim e nunca recebe a Bênção prometida na carta); **P2** o vazamento de fim de execução (28 ObjectDB, 19 recursos) vem de um único teste, `test_boss_body.gd` `test_the_whole_fight...`, e não acontece no jogo.

## 1. Comandos e resultados

| Item | Comando | Resultado |
|---|---|---|
| Importação | `~/tools/godot/godot --headless --path . --import` | 0 `SCRIPT ERROR`, 0 `Parse Error` (`import.txt`) |
| Scripts | `~/tools/godot/godot --headless --path . -s tools/check.gd` | `CHECK ok`, 0 erros (`check.txt`) |
| Testes, 3 rodadas | `tools/test.sh` (x3, em sequência) | 97 scripts, **992/992** nas três (261 s, 228 s, 210 s de parede); 2 avisos do GUT, 1 "Deprecated"; 0 arriscados (o `test_only_finishers_glint` passou sem marca nas três) |
| Testes com `--verbose` | `godot --headless --verbose ... gut_cmdln.gd` | 992/992 (4ª rodada inteira); lista dos objetos vazados (seção 3) |
| Instabilidade | `tools/test.sh -gselect=<arquivo>` x8 para `test_descent`, `test_enemy_motion`, `test_enemy_windup`, `test_living_crowd` | 32 de 32 verdes (`flaky/`) |
| Fluxo do título | `godot --headless --path . -s tools/title_flow_check.gd` | 53 linhas `ok`, `FLOW ok`, nenhuma falha (`flow.txt`) |
| Descida padrão | `tools/smoke.sh 300 --seed=5` | chega em Morvath (sala 11) aos 246,4 s; aos 300 s está na fase 2 (`smk300.txt`) |
| Descida com vitória | `tools/smoke.sh 600 --seed=5` | vence aos 333,3 s, luta de 83,4 s, 24 de vida (`smk600.txt`) |
| Chefe | `tools/smoke.sh 180 --start=boss --boons=25 --seed=5` | vence aos 77,4 s, fase 4, vida cheia (50) (`smkboss.txt`); no QA T5: 75,1 s |
| Export Linux | `godot --headless --path . --export-release "Linux" <scratch>/ASelagem.x86_64` | saída 0, nenhuma linha com "error" (`linux.log`), 161 484 264 bytes (pck embutido) |
| Export Web | `godot --headless --path . --export-release "Web" <scratch>/index.html` | saída 0, nenhuma linha com "error" (`web.log`); `index.pck` 87 964 840 bytes, `index.wasm` 39 514 754 |

Os exports foram para `/home/dani/tools/qa1118/export/`, não para `build/`, para não mexer no exe que o Daniel vai testar.

## 2. Partidas do robô (8 sementes)

Comando: `godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=900 --seed=N --bot-reaction=0.25` (o mesmo
do `tools/smoke.sh 900`, com a saída inteira guardada), N de 1 a 8, quatro de cada vez. Maestria 1 (sem save: sem Dons,
sem ultimate; o `RESULT` traz `ult.id` vazio nas 8).

| Semente | Fim | Tempo | Chega em Morvath | Vida ao chegar | Luta | Vida no fim | Bênçãos | Dano levado de Morvath |
|---|---|---|---|---|---|---|---|---|
| 1 | vitória | 283,4 s | 201,7 s | 50 | 78,1 s | 50 | 8 | nada |
| 2 | vitória | 446,4 s | 321,0 s | 50 | 121,8 s | 15 | 5 | tempestade 30, maldição 6, invocados 4 |
| 3 | vitória | 444,0 s | 294,9 s | 55 | 145,5 s | 35 | 6 | tempestade 20, maldição 6 |
| 4 | vitória | 367,6 s | 240,6 s | 43 | 123,4 s | 6 | 6 | tempestade 20, invocados 12, erupções 10 |
| 5 | vitória | 345,2 s | 250,6 s | 75 | 91,0 s | 71 | 7 | invocados 4 |
| 6 | vitória | 302,0 s | 230,8 s | 46 | 67,6 s | 36 | 7 | invocados 4, maldição 6 |
| 7 | vitória | 310,9 s | 212,1 s | 55 | 95,1 s | 55 | 7 | nada |
| 8 | **morte na fase 4** | 397,0 s | 283,9 s | 30 | 113,1 s | 0 (Morvath com 347) | 6 | invocados 12, erupções 10, tempestade 8 |

- **Vitórias**: 7 de 8. Nas mesmas sementes, o QA T5 deu 7 de 8 no `620a21e` e 6 de 8 no `5dfe97f`: sem desvio.
- **Tempos**: chega em Morvath aos 254,5 s em média (201,7 a 321,0); a descida vencida leva 357 s em média; a luta, 104,5 s
  (67,6 a 145,5), ainda abaixo da meta de 2 a 4 min do `CLAUDE.md` (a observação de sempre: gente bate menos).
- **Vida em Morvath**: 50,5 em média (30 a 75; a vida máxima varia com os corações e o altar).
- **O que mais fere** (soma das 8): antes de Morvath 165 de dano, **Ancião (guardião) 81 (49%)**, feiticeiro 44, elite do
  feiticeiro 12, Cavaleiro 12, besteiro 6, elite do besteiro 6, Runas 4. Em Morvath 152, **tempestade 78 (51%)**, invocados
  36, erupções 20, maldição 18. A única derrota foi na fase 4, com invocados e erupções somando mais que a tempestade.
- **Presos**: `stuck` 0, `bot.stuck` 0, `died_stuck` falso nas 8. Nenhuma linha de erro nos 8 registros (só o cabeçalho
  do Godot). Pico de inimigos de pé: 8.
- **Passo da simulação nas descidas**: `step_ms_avg` 0,34 a 0,43 ms. Os picos de 8,8 a 35,7 ms dessas 8 partidas são da
  máquina carregada (rodaram 4 juntas com a suíte de testes): a semente 3 sozinha com `--trace-steps` tem pico de 6,94 ms
  e só 4 passos acima de 4 ms, todos na `horde` (`trace3.txt`).
- Lojas: as 8 compraram só a cura (50 de ouro, com 60 a 85 na bolsa). Provação paga em 2 de 8 (sementes 4 e 6), vencida em
  1 (a 6); ver P1-1.

## 3. Falhas e regressões

Nenhum P0. Nenhuma regressão contra o `fe07159` nas medidas feitas (testes, robô, passo, exports).

### P1-1 Provação tomada tarde nunca termina: paga vida, carrega a maldição até Morvath e não recebe a Bênção
- **Evidência**: `runs/4.log` (semente 4): `trial_paid` na sala 6 (13 de vida, 51,8 para 38,8), `trial_taken`
  `trial_pesado` com a maldição `trial_ferida` (cura -50%) por **4** encontros; depois disso a descida tem altar (7), salão
  (8), Fendas (9, a única luta), loja (10) e Morvath. O `RESULT` termina com `"trial": {"active": "trial_ferida", "left": 3,
  "won": 0}`: a Bênção prometida nunca veio, e a maldição de cura valia na compra da cura da loja. A carta (T5) diz "VOCÊ
  RECEBE DEPOIS DE N LUTAS" sem avisar que não há N lutas pela frente.
- **Causa provável**: `trial_depth_max` 7 (`tools/make_data.gd` linha 589, cortado em `rooms_ - 2` por `rooms.gd:129`) e
  maldições de 3 a 5 encontros (`_trial(..., encounters := Vector2i(3, 5))`), mas da sala 6 ou 7 em diante sobram no
  máximo 2 ou 3 lutas (as salas de evento, fonte e loja não contam, e Morvath também não: `left` não mudou na luta).
- **Reproduzir**: `tools/smoke.sh 900 --seed=4 --bot-reaction=0.25` e ler `trial` e `events` no `RESULT`.
- **Responsável sugerido**: `gameplay-engineer` (regra: só oferecer a laje com encontros que ainda cabem, sortear os
  encontros até as lutas que restam, ou contar Morvath como encontro), com a decisão de design no `game-director`. Teste
  que falha a escrever: "toda carta oferecida tem `encounters` menor ou igual às lutas que restam no mapa".

### P2-1 Vazamento no fim de toda execução da suíte (28 ObjectDB, 19 recursos) vem de um teste só
- **Evidência**: `tests_verbose.txt`: os 19 "Resource still in use" são `test_boss_body.gd`, `boss.gd`, `enemy.gd`,
  `boss_def.gd`, `boss_attack.gd`, `boss_director.gd`, `enemy_def.gd`, `floor_shape.gd`, `addons/gut/test.gd`,
  `data/enemies/morvath.tres`, `data/bosses/morvath.tres` e 7 sub-recursos dele, um do `catacombs.tres`. Isolado:
  `tools/test.sh -gselect=test_boss_body -gunit_test_name=test_the_whole_fight` reproduz os dois avisos;
  `-gunit_test_name=test_every_pose` e `-gselect=test_boss_exits` não. Nenhuma das 8 partidas do robô nem o
  `title_flow_check` imprime o aviso: **não é do jogo**.
- **Causa provável**: as lambdas do teste ligadas aos sinais do `Boss` (`phase_changed`, `moment`, `cue`) capturam `e`
  (o `Enemy`, RefCounted), `boss` e dicionários; um `RefCounted` com contagem 2 no fim sugere ciclo. É o DT-005 do backlog.
- **Responsável sugerido**: `gameplay-engineer` (dono do teste): desligar as lambdas ou soltar as referências no fim do
  teste. Pronto quando `tools/test.sh` termina sem as duas linhas.

### P2-2 Higiene da suíte
- `tests/test_e5_ui.gd:108` usa `wait_frames` (GUT marca "Deprecated": trocar por `wait_process_frames`).
- 2 avisos `Float/Int comparison` em `test_boss_exits.gd` (`free way out of the scythe` e `of the storm`), já conhecidos.
- O número de asserções varia entre rodadas (239 232, 236 970, 238 520) com o mesmo número de testes: há laços que
  dependem do tempo de parede. Não falhou, mas é a origem provável da instabilidade relatada; vale fixar a semente ou o
  número de quadros nesses testes. Responsável: `gameplay-engineer`.

### P2-3 Tamanho do pacote Web diferente do documentado
- O `CLAUDE.md` (Pendências) diz "o pacote web tem 61 MB"; o export de hoje tem `index.pck` de 88 MB mais o `wasm` de
  39,5 MB. Não é falha do jogo, é documento desatualizado (e o download do navegador ficou 44% maior). Responsável:
  Game Director (documento) e `technical-artist` (tamanho).

### Instabilidade relatada (um teste falhou uma vez depois de um merge)
- Não reproduzida: 4 suítes inteiras e 32 execuções dos arquivos suspeitos, todas verdes. O instável conhecido
  (`test_descent.gd` `test_the_doors_know_their_rooms_before_they_open`, Q-T5-5, 1 em 6 no QA T5) passou 12 de 12 hoje. Sem
  o nome do teste que falhou, não dá para dizer se foi esse. Fica como P2 para acompanhar.

## 4. Desempenho

### Simulação sem tela, 300 inimigos (`tools/smoke.sh 120 --stress=300 --seed=5`, 3 x 3 alternado, máquina sem outras partidas)

| Rodada | `fe07159` `step_ms_avg` / pico | `dd1f5ba` `step_ms_avg` / pico |
|---|---|---|
| 1 | 4,19 / 18,5 | 4,34 / 20,5 |
| 2 | 4,16 / 23,2 | 4,18 / 22,2 |
| 3 | 4,19 / 16,2 | 4,16 / 31,8 |

Média 4,18 antes e 4,23 depois (no ruído). A mudança do corredor (`Horde.stride_lean`) não custou nada mensurável.

### GPU real (RTX 5060 Laptop, Godot 4.7.2 de Windows, Vulkan, Forward+, 1672 x 941, `tools/gpu.sh shot`, cópia padrão)

Com sincronia vertical (o `tools/gpu.sh shot` padrão, `fps` da linha `RESULT`, `gpu2/gpu.out`):

| Cena | Alta | Média | Baixa |
|---|---|---|---|
| 300 inimigos (`--stress=300 --seed=5 --shot-at=8`) | 52 qps (passo 12,8 ms) | 55 (12,2) | 54 (12,4) |
| Sala 1, luta do robô (`--bot --autopick --seed=5 --shot-at=9`) | 142 | 146 | 142 (1ª rodada, `gpu/`) |
| Morvath com 25 Bênçãos (`--start=boss --boons=25 --bot --autopick --seed=5 --shot-at=14`) | 143 | 142 | 144 |
| Sala 1 a 1920 x 1080 | 144 | não medido | não medido |

Os 142 a 146 de toda cena normal são o teto da sincronia com a tela do notebook (não mudam com qualidade nem
resolução), então não medem a placa. Sem sincronia (`tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941
--disable-vsync -- --nosave --quality=Q <cena> --seed=5 --smoke=14`, `gpu2/novsync.out`, uma rodada cada):

| Cena | Alta | Média | Baixa |
|---|---|---|---|
| Sala 1, luta do robô | **343 qps (2,9 ms)** | 473 (2,1 ms) | 527 (1,9 ms) |
| Morvath com 25 Bênçãos, 14 s | **160 qps (6,3 ms)** | 153 (6,5 ms) | 150 (6,7 ms) |

- O estresse de 300 está **preso na CPU** (o passo da simulação no Windows mede 12 a 13 ms, a qualidade não muda nada):
  52 qps na Alta, igual ao QA T5 (55 / 55 / 52). Sem regressão.
- Morvath com 25 Bênçãos custa 6,3 a 6,7 ms por quadro em qualquer qualidade: também é CPU (efeitos dos dons, câmara);
  folga grande para 60 qps, mas é a cena mais cara medida e onde a Qualidade Baixa não ajuda.
- Primeira rodada (`gpu/gpu.out`, CPU ocupada pela minha suíte e pelas partidas): estresse 45 / 41 (Alta), 53 / 51
  (Média), 51 / 52 (Baixa). Descartada para comparação; mostra que a máquina carregada tira até 20% do estresse.
- Não houve antes e depois na GPU (ver limitações); a iGPU Intel não foi medida nesta rodada (o E6 mediu Alta 15 a 17 e
  Baixa 62 a 81 qps a 1280 x 720).

## 5. As 10 melhorias de maior ganho

1. **Provação que não termina (P1-1)**: só oferecer a laje se os encontros cabem nas lutas restantes (ou contar Morvath).
   Ganho: tira uma armadilha que custa vida e mente na carta. `gameplay-engineer`.
2. **Teste com gente**: os números de dificuldade continuam sendo do robô (7 de 8 com reação 0,25); a luta de Morvath dura
   104 s no robô, abaixo da meta de 2 a 4 min. Um teste do Daniel vale mais que outra rodada de sementes.
3. **Tempestade da fase 4**: 51% do dano levado de Morvath e presente em todas as derrotas recentes; medir com `--bot-kite`
   se é leitura (aviso) ou espaço. `combat-feel-director` e `gameplay-engineer`.
4. **Ancião (guardião)**: 49% do dano antes de Morvath em 8 descidas; conferir se o leque de 5 orbes e as invocações estão
   avisados (os `warn_s` do registro). `gameplay-engineer`.
5. **Vazamento do `test_boss_body` (P2-1, DT-005)**: correção pequena que limpa a saída de toda execução da suíte e deixa
   um vazamento de verdade aparecer quando vier.
6. **Testes que dependem do relógio de parede (P2-2)**: o número de asserções muda a cada rodada; fixar semente e quadros
   tira a instabilidade que aparece "depois de um merge".
7. **Cenário de 300 inimigos preso na CPU**: na RTX a qualidade não muda o FPS do estresse (o passo mede cerca de 13 ms no
   Windows contra 4 ms no Linux sem tela); não afeta as salas reais (até 20 de pé), mas é o próximo gargalo se o modo de
   horda voltar. Perfilar a `horde` (os 4 passos lentos da semente 3 eram todos dela).
8. **Fila da GPU entre agentes**: na rodada de hoje até 8 `tools/gpu.sh` esperavam a trava ao mesmo tempo e partidas sem
   tela de outros agentes rodavam na mesma CPU; as medidas de FPS de um agente ficam sujas. Um modo "medir" que espera a
   CPU calma, ou um horário só para medidas, deixaria os números comparáveis.
9. **Tamanho do pacote** (P2-3): Web 88 MB de `pck`, Linux 161 MB, Windows 197 MB; seguir a auditoria de ativos (C2 em
   diante) e atualizar o número no `CLAUDE.md`.
10. **Higiene da suíte** (`wait_frames` e `Float/Int`, P2-2): minutos de trabalho, saída limpa.

## 6. Limitações do ambiente

- WSL2 sem tela e sem som ouvido: nada de áudio foi julgado. Sem controle, sem celular, nenhum teste com gente.
- A GPU foi usada pela Godot de Windows na cópia padrão (`C:\Users\danie\tools\eterra-gpu`); nada novo criado em
  `C:\Users\danie\tools`. Por isso não houve antes e depois na GPU (a cópia do commit base ficaria lá); o antes e depois do
  desempenho é o do passo sem tela.
- Outros agentes usavam a GPU e a CPU ao mesmo tempo (fila de até 8 na trava do `gpu.sh`, partidas sem tela em paralelo).
  A primeira rodada de FPS (`gpu/`) rodou junto com a minha própria suíte e as 8 partidas e foi descartada para o estresse
  (41 a 45 qps na Alta); os números da tabela são da segunda (`gpu2/`), com a minha parte da CPU parada.
- As 8 partidas do robô rodaram 4 de cada vez: os tempos de jogo e os resultados não mudam com isso (relógio fixo de 60
  quadros), mas os picos de `step_ms` sim (ver seção 2).
- Capturas abertas e olhadas: `gpu2/stress_alta_1.png` (300 inimigos no salão, HUD com o 5º losango "Maestria 2"),
  `gpu/fight_alta.png` e `gpu/fight_baixa.png` (sala 1, 4 esqueletos; a Baixa um pouco mais serrilhada, mesmo quadro),
  `gpu2/boss_alta.png` (Câmara do Selo, Morvath na foice com o herói colado nele e 25 Bênçãos no HUD). Na partida do
  robô o 5º losango some de propósito (`hud.gd:417`, `game.bot == null`), não é falha.
  Sem julgamento de arte (é do `art-director`).
