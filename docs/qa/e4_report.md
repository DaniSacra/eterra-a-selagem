# Relatório de QA: E3 (Bênçãos, raridades, Elos, loja) e E4 (Salmos, carta de Salmo, Compêndio, música)

- **Data**: 2026-11-17.
- **Testado**: `arpg-3d` no `5316e9f` (E3, E4-01 a E4-05, E4-06 música e as regras da E5 já integradas), na worktree do
  QA. Mudanças do QA só em `tests/` (seção 1.1 e 1.2). **Base de desempenho**: `ec8529c` (E2 aprovada), copiada por
  `git archive` para `/home/dani/tools/e4/qa/base_ec8529c`.
- **Ambiente**: WSL2, Godot 4.7.2 Linux sem tela. Sem som ouvido (a música foi conferida por teste, pelas chamadas no
  código e pela sonda de mixagem offline), sem controle físico, sem celular, nenhum teste com gente. **Sem GPU nesta
  rodada** (seção 4). Outro agente rodava testes numa worktree vizinha ao mesmo tempo (carga 2,4 a 3,1): os tempos de
  passo têm esse ruído.
- Logs brutos (fora do repositório): `/home/dani/tools/e4/qa/logs/` (`seedN.txt` com o `RESULT` de cada semente,
  `boss25.txt`, `test2.log`, `test3_full.log`, `bb1.log` a `bb6.log`, `check.log`; `test1.log` só tem o fim da saída).

## Veredito

**Pronto para seguir, com um P1 para corrigir antes do Daniel testar**: o tema do Salmo (E4-06) **nunca toca no jogo**.
`Game.take_psalm` chama `Music.sting(p.id)` com o id real do Salmo (`sentinela`, `abrigo`, `pastor`, `rocha`), mas os
temas estão guardados com nomes em inglês (`psalm_sentinel`, `psalm_shelter`, `psalm_shepherd`, `psalm_rock`): a busca
`psalm_sentinela` não acha nada e `MusicMix.sting` devolve `null` em silêncio. O teste da música passava porque chama
`Music.sting(&"sentinel")`, um id que não existe. Escrevi o teste que falha (seção 1.2) e entrego ao dono.

Fora isso: `CHECK ok`, 0 `SCRIPT ERROR`, `FLOW ok`, o robô chega em Morvath em 8 de 8 sementes, vence 5 de 8, chega com 5 a
8 Bênçãos em 7 de 8 e compra na loja em 6 de 8 (as metas da E3); o teste instável de Morvath ficou determinístico.

## 1. Checagem e testes

| Comando | Resultado | Evidência |
|---|---|---|
| `godot --headless --path . --import` | 0 `SCRIPT ERROR`, 0 `Parse Error`; 4 linhas `ERROR` da fonte `AlegreyaSans-Regular.ttf`, só na primeira importação da worktree nova (cache vazio), como nas rodadas anteriores | saída do comando |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok` | `logs/check.log` |
| `tools/test.sh`, rodada 1 (código do `5316e9f`, antes das mudanças do QA) | 81 scripts, **838 testes, 838 passando**, 0 falhando, 0 arriscados, 2 avisos do GUT, 211,5 s | `logs/test1.log` |
| `tools/test.sh`, rodadas 2 e 3 (com o teste de Morvath semeado e o teste novo da música) | 81 scripts, **839 testes, 838 passando, 1 falhando** (o novo `test_every_real_psalm_finds_its_sting`, 4 asserts, de propósito), 0 arriscados, 219,8 s | `logs/test2.log`, `logs/test3_full.log` |
| `tools/test.sh -gselect=test_boss_body`, 6 vezes | **2/2 nas 6** | `logs/bb1.log` a `bb6.log` |
| `godot --headless --path . -s tools/title_flow_check.gd` | **`FLOW ok`** | saída do comando |

- O arriscado conhecido `test_only_finishers_glint` não apareceu como arriscado.
- Os 2 avisos do GUT são `Float/Int comparison` em `test_boss_exits.gd` (`test_the_floor_is_a_circle...`, ao comparar
  "free way out of the scythe/storm"): só higiene de teste (P2).
- Toda execução termina com `28 ObjectDB instances were leaked` e `19 resources still in use` (o `CLAUDE.md` diz que o
  ciclo 10 tinha zerado isso). Não afeta a partida; causa não investigada (P2).
- **O comando do `CLAUDE.md` para rodar um arquivo só (`tools/test.sh -gtest=res://tests/x.gd`) roda a suíte inteira**,
  porque o `.gutconfig.json` já lista `res://tests`: o `-gtest` soma em vez de filtrar. O que filtra é
  `tools/test.sh -gselect=test_x` (P2, documentação).

### 1.1 Teste instável de Morvath: causa e correção (feita pelo QA, só em `tests/`)

`tests/test_boss_body.gd`, `test_the_whole_fight_four_phases...`, conferia `"dash was played"`. Sem `--seed`,
`Dev.seed_rng` chama `randomize()` no gerador de Morvath (`Boss._rng`, sal 3), então a escolha dos ataques pelo
`BossDirector` mudava a cada rodada e às vezes a investida não saía. O comentário do `DRAWN_STEP` já registrava a outra
cara do mesmo problema ("depending on the seedless frame timing").

Correção, a mesma do `test_enemy_motion.gd` e do `test_ranged_enemies.gd` na E2: `before_each` liga `--seed=1`
(`Dev._args["seed"]`) e `after_each` desliga. Nada foi afrouxado: os mesmos `assert` (as quatro fases, a queda, sem salto,
foice, lâminas **e investida** jogadas, avisos com pelo menos 0,5 s, soltura das mãos). Com a semente 1 a luta joga os três
ataques; 6 de 6 rodadas do arquivo e as rodadas 2 e 3 da suíte inteira passaram.

### 1.2 Teste novo que falha: o tema do Salmo (P1, para o dono)

`tests/test_music.gd`, `test_every_real_psalm_finds_its_sting`: para cada Salmo de `data/psalms/`
(`Psalms.load_catalog()`), `Music.sting(p.id)` precisa pôr um tema na fila. Falha nos quatro:

```
[Failed]: [0] expected to equal [1]:  Psalm sentinela (Music.sting(&"sentinela")) plays a theme
[Failed]: [0] expected to equal [1]:  Psalm abrigo (Music.sting(&"abrigo")) plays a theme
[Failed]: [0] expected to equal [1]:  Psalm pastor (Music.sting(&"pastor")) plays a theme
[Failed]: [0] expected to equal [1]:  Psalm rocha (Music.sting(&"rocha")) plays a theme
```

Passos: `tools/test.sh -gselect=test_music`. Na partida: `--psalm=sentinela` ou qualquer Salmo tomado; `Music.mix.stings`
fica vazio. Correção sugerida (dono: quem fez a E4-06, `gameplay-engineer`): o nome do tema como dado do Salmo
(`PsalmDef`, "conteúdo é dado") ou os arquivos e `Music.STINGS` com os ids reais (`psalm_sentinela`...); e trocar o
`&"sentinel"` do `test_the_api_levels_phases_and_stings`, que escondia o erro.

## 2. Robô (sem tela, `--fixed-fps 60`, `tools/smoke.sh 600 --bot-reaction=0.25 --seed=N`, 4 por vez)

| semente | Morvath aos (s) | Bênçãos em Morvath | Elos | Salmos | ouro na loja | comprou | resultado | fase máx. / da morte | tempo total (s) | vida em Morvath | `step_ms_avg` / `peak` |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 196,2 | 6 | 1 | - | 70 | cura | vitória | 4 | 299,5 | 30 | 0,21 / 6,97 |
| 2 | 246,8 | 6 | 1 | sentinela | 72 | cura | vitória | 4 | 349,2 | 50 | 0,22 / 7,20 |
| 3 | 265,8 | 7 | 1 | - | 72 | cura | vitória | 4 | 387,2 | 30 | 0,22 / 9,41 |
| 4 | 276,3 | 8 | 0 | - | 27 | nada | morte | 3 / 3 | 352,5 | 33,2 | 0,22 / 10,43 |
| 5 | 251,1 | 7 | 2 | sentinela | 79 | cura | morte | 2 / 2 | 293,5 | 15 | 0,22 / 9,39 |
| 6 | 288,7 | 7 | 0 | - | 75 | cura | vitória | 4 | 410,0 | 55 | 0,23 / 5,80 |
| 7 | 246,2 | 5 | 0 | - | 40 | nada | morte | 4 / 4 | 328,5 | 49 | 0,23 / 9,15 |
| 8 | 258,1 | **3** | 0 | - | 81 | cura | vitória | 4 | 356,4 | 65 | 0,23 / 6,11 |

| Meta (E3, `docs/qa/e3_metrics.md`) | E3 medida | Agora | Situação |
|---|---|---|---|
| Chega a Morvath | 7 de 8 | **8 de 8** | ok |
| 5 a 8 Bênçãos em Morvath em 6 de 8 | 7 de 8 | **7 de 8** (a semente 8 chega com 3) | ok |
| Compra na loja em 6 de 8 | 7 de 8 | **6 de 8** | ok, no limite |
| Vence 3 a 6 de 8 | 5 de 8 | **5 de 8** | ok |

- Descida até Morvath: 3 min 16 s a 4 min 49 s (E3: 3 min 55 s a 4 min 40 s); partida inteira 4 min 54 s a 6 min 50 s.
- **As duas sementes que não compram (4 e 7) aceitaram a Provação e tiraram "Pobreza"** (`gold_pct` -1, `trial_pobreza`):
  o ouro para em 27 e 40 da sala 5 até a 9 (`gold_in` dos `rooms`), abaixo dos 50 da cura. É a regra da E5 funcionando,
  não um erro; mas o robô (`Trials.bot_accepts`) aceita sem olhar a maldição. Anotado como P2 para o dono das regras.
- A semente 8 chega com 3 Bênçãos apesar de escolher portas de Bênção nas salas 2, 3, 4, 6 e 7 (`boons_in` fica em 2 da
  sala 4 à 7). Causa não medida: o `RESULT` não traz a lista das Bênçãos tomadas (a troca de uma Bênção da mesma ação é a
  suspeita). P2, para olhar.
- Salmos: 2 de 8 partidas tomaram um (os dois, a Sentinela). O robô pega o Salmo sempre que vem.
- 0 `SCRIPT ERROR`, `bot.stuck` 0 em todas, `max_alive` 8.
- `tools/smoke.sh 180 --start=boss --boons=25 --seed=5`: **vitória aos 83,8 s**, vida 50, fase 4 alcançada, 3 Elos,
  `step_ms_avg` 0,21, pico 6,18 (`logs/boss25.txt`).
- `step_ms_peak`: com a semente 5 sozinha e `--trace-steps` os dois picos são o primeiro quadro da partida (`player`
  5,56 ms, sala 1) e o quadro da morte (`shots` 8,81 ms, sala 11). A mesma semente sozinha e em paralelo morreu no mesmo
  segundo (293,5): a partida é determinística.

## 3. Desempenho (sem tela; nenhum FPS de GPU nesta rodada)

| Medida | Base `ec8529c` (E2) | `5316e9f` |
|---|---|---|
| `tools/smoke.sh 120 --stress=300 --seed=5` | avg 2,22 / 2,36 ms, pico 12,3 / 17,2 (312 abates, **arena Cripta**) | avg 2,81 / 2,82 / 2,83 / 2,87 ms, pico 12,8 a 17,5 (300 abates, **arena Salão**) |
| mesmo, `--arena=hall` | avg 2,32, pico 20,1 | avg 2,53, pico 15,3 |
| mesmo, `--arena=crypt` | avg 4,82, pico 33,6 | avg 5,13, pico 36,5 |
| partida normal (`smoke.sh 600`, 8 sementes) | (E2: 0,18) | avg 0,21 a 0,23 ms |

- O `--stress=300` sem `--arena` não cai mais na mesma sala que na E2 (o mapa da E5 mudou o sorteio), então a linha de
  cima não compara. Na mesma arena a diferença é de +6 a +9% no passo médio, quase tudo na `horde` (`--trace-steps`),
  com a carga da máquina em 3: dentro do ruído desta rodada ou uma subida pequena; longe do orçamento de 16,7 ms.
- A Cripta com 300 inimigos tem picos de 33 a 36 ms na base e agora: não é da E3/E4 (estresse fora do teto de 20 da
  partida normal).
- **Não medido**: FPS na RTX 5060 (a GPU estava fora do escopo pedido e as capturas da E4 já existem), placa fraca,
  celular, Compatibility em tempo de quadro.

## 4. Música (E4-06)

| Item | Resultado | Evidência |
|---|---|---|
| Autoload `Music` | registrado (`project.godot`: `Music="*res://scripts/music.gd"`), silencioso sem tela | código |
| Salão: cama de exploração | `boot.gd` e `Game` chamam `Music.play(&"catacombs", Music.WALK)` | código |
| Camada da luta | `Rooms._enter` toca `FIGHT` em COMBAT, MINIBOSS e TRIAL; `_room_cleared` volta a `WALK` | código |
| Morvath por fase | `Game` chama `Music.boss_phase(boss.phase)` e liga `phase_changed`; 4 camadas | código; `test_the_api_levels_phases_and_stings` passa |
| Vitória | `Boss` toca `victory`, que passa para `catacombs` | `test_a_new_track_crossfades_and_the_victory_hands_over` passa |
| **Tema do Salmo** | **não toca**: ids não batem (seção 1.2) | teste novo falha |
| Limitador | `Audio.LIMIT_DB` **-1,5 dB** no fim do `Master` (o `CLAUDE.md` ainda diz -1 dB: P2 de documentação) | `scripts/audio.gd`; `test_music_runs_into_master_before_the_limiter` passa |
| Pico | `tools/mix_probe.gd`: música sozinha RMS -29,0 dBFS, pico -13,2 dBTP; com os golpes mais fortes a cada 0,25 s, +3,7 dBTP antes do limitador e **-1,40 dBTP depois** (modelo do limitador): abaixo de -1 dBTP | saída da sonda |
| Silêncio e arquivos | `test_every_track_is_there_in_time_and_small`, `test_no_track_has_two_seconds_of_silence`, `test_a_run_never_leaves_two_seconds_of_silence`, `test_music_sits_under_the_blows` passam | `logs/test2.log` |

O limitador real (`AudioEffectHardLimiter`) não foi medido: a sonda é um modelo; o real só pelo Movie Maker na GPU.
Ninguém ouviu a música.

## 5. Capturas (já existentes, abertas e olhadas; nada novo capturado)

`docs/gallery/e4/ui/` já tem a carta de Salmo a 720 (`card_sentinela_720.jpg`) e a 1080 (`card_pastor_1080.jpg`), o
Compêndio nas abas Salmos, Inimigos, Morvath e Arenas a 720 e 1080, a saudação, o HUD e as luzes do Pastor. Abri
`card_sentinela_720.jpg`, `card_pastor_1080.jpg`, `codex_psalms_720.jpg` e `pastor_lights_crop_1080.jpg`: moldura
própria, aba "Salmo descoberto", "Transforma: ...", "Aberto por ..." legíveis; oito abas cabem a 720; as luzes do Pastor
(uma acesa, duas apagadas) sobre o losango do especial. O commit `ccd2ee2` não diz se foram feitas na GPU ou na CPU. O
critério visual é do `art-director`.

## 6. Falhas e regressões, por gravidade

**P0**: nenhuma.

**P1**
1. **Tema do Salmo nunca toca** (E4-06). Passos: tomar qualquer Salmo (`--psalm=sentinela`) ou
   `tools/test.sh -gselect=test_music`. Esperado: o tema por cima da cama, com a cama abaixada. Obtido: nada
   (`Music.sting(&"sentinela")` procura `psalm_sentinela`, que não existe). Responsável: `gameplay-engineer` (dono da
   E4-06, `scripts/music.gd`, `data/psalms` pelo `make_data.gd`). Teste que falha: `tests/test_music.gd`,
   `test_every_real_psalm_finds_its_sting`.

**P2**
1. Robô aceita a Provação sem olhar a maldição: com "Pobreza" fica sem ouro para a loja (sementes 4 e 7). Responsável:
   `gameplay-engineer` (`Trials.bot_accepts`), só se o robô precisar representar gente nas métricas da loja.
2. Semente 8 chega a Morvath com 3 Bênçãos escolhendo portas de Bênção; o `RESULT` não diz quais foram tomadas nem
   trocadas. Responsável: `gameplay-engineer` (pôr `gifts` no `RESULT` do robô, como no registro de gente).
3. `ObjectDB instances were leaked` (28) e `resources still in use` (19) no fim de toda execução. Responsável:
   `gameplay-engineer`.
4. Documentação: `CLAUDE.md` diz limitador -1 dB (é -1,5) e `tools/test.sh -gtest=...` para um arquivo (roda tudo; usar
   `-gselect`). Responsável: Game Director.
5. Avisos `Float/Int comparison` em `tests/test_boss_exits.gd`. Responsável: `gameplay-engineer` (higiene de teste).
6. Passo da simulação com 300 inimigos +6 a +9% na mesma arena contra a E2 (seção 3), com ruído de carga: medir de novo
   numa máquina parada antes de mexer.

## 7. Limitações

WSL2 sem tela; sem som ouvido (só sonda offline e testes); sem GPU nesta rodada (nenhum FPS real, nenhuma captura nova);
sem controle físico; sem celular; nenhum teste com gente; outro agente usava a CPU ao mesmo tempo (os tempos de passo têm
esse ruído); as 8 sementes rodaram 4 por vez.
