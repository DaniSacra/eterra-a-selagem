# Relatório do gameplay-engineer, fim do ciclo (2026-11-18)

- **Commit lido**: `dd1f5ba` (`arpg-3d`), com `git log --since=2026-11-17` (43 commits: T5, T5b, sala de música, pacote de
  arte 1A, 1B, 2 e 4, auditoria e C1 de assets, corredor no chão).
- **Rodado**: `tools/check.gd` (`CHECK ok`), `tools/test.sh` (resultado na seção 4), 16 descidas do robô de 900 s com
  `--bot-reaction=0.25` (sementes 1 a 8 Maestria 1; 9 a 12 Maestria 20 de sustento com `--ultimate=cleave`; 13 a 16
  Maestria 1). Saídas fora do git, no scratchpad da sessão (`smk/s*.log`, `smk/u*.log`). Nada de código, dado ou outro
  documento foi alterado.

## Resumo em 5 linhas

1. O jogo está estável: 16 descidas sem nenhuma linha de erro, ninguém preso (`stuck` 0, `bot.stuck` 0), 15 vitórias e 1
   morte na fase 4, Morvath aos 203 a 321 s, passo médio 0,22 a 0,38 ms (pico 12 ms).
2. **Bug de regra (P1)**: a Provação tomada nas profundidades 5 a 7 quase nunca vira Bênção; a maldição atravessa Morvath
   e a descida acaba sem a recompensa. 4 das 9 Provações tomadas pelo robô terminaram assim (`trial.left` 1 a 3).
3. **Risco de save (P1)**: `Save.write` trunca e reescreve `save.json` no lugar; um corte de energia no meio apaga a
   Maestria, e um arquivo ilegível vira o save padrão, que a próxima gravação torna definitivo.
4. Investigação do robô parado no exe: **nenhum caminho do código abre a pausa com o robô** (Esc e clique não chegam ao
   jogo quando há controle virtual); o relógio só para fora do modo PLAY ou com quadros muito lentos (o jogo anda no
   máximo 0,05 s por quadro). A causa provável está fora da lógica do jogo; proponho um vigia que prove (seção 2).
5. Para o molde do Hades II o que mais pesa agora: Ômega carregando a toda velocidade, nenhuma tecla de interagir (loja
   compra e porta sai ao encostar), nenhuma pausa ao perder o foco, Elos e Salmos que quase não aparecem, loja em que a
   Bênção (150) nunca é alcançável (ouro de 60 a 89 nas 16 descidas).

## 1. Partidas do robô (reação 0,25, 900 s)

| Sementes | Montagem | Vitórias | Morvath aos (s) | Vida ao chegar | Luta (s, vitórias) | Bênçãos em Morvath | Elos | Salmos | Ouro na loja | Comprou |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 a 8 | Maestria 1 | 7 de 8 (morte na fase 4, semente 8) | 202 a 321 | 30 a 75 | 68 a 146 | 5 a 8 | 0 em 8 | 0 em 8 | 60 a 85 | cura, 8 de 8 |
| 9 a 12 | Maestria 20 sustento + Corte do Juízo | 4 de 4 | 203 a 269 | 40 a 85 | 82 a 88 | 3 a 7 | 2 em 4 | 2 descidas com 2 cada | 70 a 84 | cura, 4 de 4 |
| 13 a 16 | Maestria 1 | 4 de 4 | 211 a 282 | 39 a 75 | 83 a 118 | 6 a 8 | 1 em 4 | 0 em 4 | 66 a 89 | cura, 4 de 4 |

- Pico de inimigos de pé 8 em todas (faixa comum 4 a 8 respeitada). Ultimate: 9 a 11 usos por descida, 3 a 4 em
  Morvath quando equipada; sem save a Maestria 1 não tem ultimate (`ult.id` vazio), então as métricas de Maestria 1
  nunca a exercitam.
- Luta de Morvath ainda curta para o robô (68 a 146 s nas vitórias, meta 2 a 4 min; pendência conhecida, falta gente).

## 2. Investigação: robô parado em 2,2 s na primeira sala (exe do Windows, com janela)

**Conclusão: no código do jogo não há caminho que pare o relógio assim na primeira sala com o robô.** O que sobra é fora
da lógica (motor, janela, sistema, saída padrão) e precisa de uma medida, não de mais leitura.

O que o código garante (lido no `dd1f5ba`):

1. **A pausa não abre com o robô.** `Game._process` só abre a pausa com `Controls.pressed(&"pause")`
   (`scripts/game/game.gd:432`), e com o controle virtual ligado (`--bot` põe `Controls.virtual = bot.pad`, `game.gd:216`)
   `Controls.pressed` lê **só** os toques do robô (`scripts/controls.gd:200-202`: `virtual.tapped` ou `_pad_latched`). Esc,
   P, Start e clique do mouse nunca chegam lá. Não existe outro caminho para `Mode.PAUSE` (`_open_pause` só nesse ponto),
   ninguém usa `get_tree().paused`, nenhum nó trata perda de foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` não aparece no
   projeto) e o título não intercepta (com `--bot` o `boot.gd` troca de cena antes de montar o menu). **A hipótese "pausa
   aberta por Esc ou clique" está descartada.**
2. **O relógio (`Game.time`) só anda em `Mode.PLAY`** (`game.gd:457-459`, dentro de `_step`, chamado só se
   `world_dt > 0`, `game.gd:426-429`). Saídas de PLAY: `CHOICE` (cartas de Bênção, Provação, Altar), `PAUSE`, `OVER`,
   `ENDING`. Na primeira sala, aos 2,2 s, nenhuma delas: a luta está começando (primeiro contato entre 1,5 e 6,0 s nas 16
   descidas, quase sempre perto de 3 s), não há recompensa, laje nem altar. E onde há, o robô fecha: cartas em 0,6 s por `create_timer`
   (`game.gd:810-813`), Provação e Altar sem tela (`Rooms._auto`, `rooms.gd:836-838`).
3. **Hit stop e câmera lenta não prendem.** `Fx.tick` (`scripts/game/fx.gd:734-743`) conta em tempo real e todo estado
   (`HitStop.advance`, `_tick_slow`) termina pelo tempo real. Conferi o pior caso, NaN: `maxf(NAN, 0.0001)` dá 0,0001 na
   Godot 4.7.2 (sonda no scratchpad, `nan.gd`), então `Engine.time_scale` não vira NaN; um NaN numa fração deixa o mundo
   parado só enquanto o efeito dura.
4. **O que de fato para o relógio sem mudar de modo é quadro lento**: o mundo anda no máximo 0,05 s por quadro
   (`_timed_step(minf(world_dt, 0.05))`, `game.gd:427`). 2,2 s de jogo são pelo menos 44 quadros; em 7 min isso é um quadro a
   cada 10 s ou menos. Candidatos fora do jogo: (a) o processo bloqueado escrevendo na saída padrão (exe lançado pelo
   WSL com a saída num cano que ninguém lê; a Godot escreve todo `ERROR:` do motor ali, e o encontro dos primeiros
   inimigos aos 2,2 s é o primeiro desenho da multidão); (b) a janela fora de vista ou minimizada no Windows com o
   Forward+ esperando a apresentação; (c) a GPU disputada por outra captura (`tools/gpu.sh` de outro agente).
   O `--smoke=40` não reproduz porque roda sem janela e com `--fixed-fps 60`.
5. Como o registro saiu com 2,2 s, o laço principal estava vivo ao fechar (`log_run("quit")` roda no `_exit_tree`): bate
   com quadros raros ou um bloqueio que se soltou, não com um travamento no GDScript.

**Para fechar (proposta, não feita)**: um vigia `--watchdog` que a cada 5 s reais imprima e grave no registro
`real_s`, `frames`, `fps`, `mode`, `Fx.rate`, `Engine.time_scale`, `time`; rodar o exe com a saída num arquivo
(`> out.txt 2>&1`) e a janela em primeiro plano. Se `frames` parar, é o motor ou o sistema; se `frames` andar com `mode`
fora de PLAY ou `rate` perto de zero, é nosso.

## 3. Achados

### P0
Nenhum. Nenhum erro de script, nenhum travamento reproduzido, todas as 16 descidas chegam a Morvath.

### P1

**P1-1. A Provação tardia nunca vira Bênção e a maldição vai para Morvath.**
- Regra: a maldição dura 3 a 5 encontros (`_trial(..., encounters := Vector2i(3, 5))`, `tools/make_data.gd:1205`), a laje
  sai até a profundidade 7 (`trial_depth_max = 7`, `make_data.gd:589`) e só uma vitória em `_room_cleared` conta
  (`Rooms._fight_won`, `scripts/game/rooms.gd:411` e `617`; `Trials.fight_won`, `scripts/core/trials.gd:103`). A sala de
  Morvath é `Phase.BOSS` e nunca passa por lá. Depois da profundidade 5 sobram 2 a 4 lutas (fonte, altar e loja não
  contam).
- Evidência: Provação tomada em 9 de 16 descidas; **4 terminaram com a maldição de pé**: semente 4 (tomada na 6, sobram 3,
  `trial_ferida`), 11 (na 5, sobra 1, `trial_ferida`), 12 (na 7, sobram 2, `trial_horda`), 13 (na 7, sobram 3,
  `trial_fragil`, golpes recebidos maiores contra Morvath). As 5 que viraram foram tomadas na 2 a 5.
- Por que o Hades II não tem isso: lá a maldição atravessa para a região seguinte; aqui a descida acaba em Morvath.
- Correção proposta (dado e regra pura): sortear os encontros até as lutas que ainda cabem antes de Morvath, ou contar a
  luta de Morvath como encontro (a Bênção chega na vitória, inútil) ou baixar `trial_depth_max` para 4. A melhor: limitar
  pelo `RunMap` (lutas restantes antes da loja) e não mostrar a laje se nem 3 cabem.

**P1-2. O save pode se perder inteiro.**
- `Save.write` abre `user://save.json` com `FileAccess.WRITE` (trunca) e escreve (`scripts/save.gd:46-50`), sem arquivo
  temporário nem cópia. Ao ler, um JSON quebrado cai em `SaveData.merged`, que devolve o padrão (`save.gd:14`,
  `core/save_data.gd:59-62`); a próxima gravação (qualquer opção, fim de partida) sobrescreve o arquivo bom-mas-ilegível
  com o padrão: Maestria, Dons, Compêndio, vitórias e Juramentos perdidos sem aviso.
- Evidência de risco real: o notebook do Daniel desligou sem bateria no meio do QA do T5 (`docs/qa/latest_report.md`,
  Ambiente). Steam: perder a progressão é o pior relato possível.
- Correção: gravar em `save.json.tmp`, fechar e renomear por cima; guardar `save.json.bak` antes; ao ler, se o principal
  falhar, tentar o `.bak` e nunca gravar por cima de um arquivo que não se conseguiu ler. Teste GUT com arquivo
  truncado.

### P2

**P2-1. Ômega carregando anda a toda.** `Player` não reduz a velocidade enquanto `charging` (`player.gd:487` usa só
`runner.move_scale`); no Hades II a carga anda devagar (a lança a 3%). Já anotado na E1c e sem dono; é o item de mão que
mais separa o Ômega do Hades (decisão de compromisso: andar segurando é forte demais e a carga não pesa).

**P2-2. Nenhuma tecla de interagir.** A loja compra ao encostar (`Rooms._step_shop`, `rooms.gd:949-962`, sem
confirmação: compra cura com a vida cheia), a recompensa se pega ao encostar e a porta leva ao pisar no pé da escada
(`Arena.exit_at`). No Hades II as três pedem o botão de usar. Risco: compra e porta erradas ao desviar de um golpe perto da
saída (o último inimigo morre, a recompensa aparece no meio, as portas abrem).

**P2-3. Nenhuma pausa ao perder o foco ou o controle.** Alt-Tab, notificação ou controle desconectado deixam a luta
correr (nada trata `NOTIFICATION_APPLICATION_FOCUS_OUT` nem `Input.joy_connection_changed`). O Hades pausa; o Steam Deck
espera isso.

**P2-4. Elos e Salmos quase não acontecem.** Maestria 1: 1 Elo em 12 descidas, nenhum Salmo; Maestria 20: 2 Elos em 4,
Salmos em 2 de 4 (os dois pela via do Dom no 3º grupo). Com 5 a 8 Bênçãos por descida e 12% por carta, a
condição do Elo raramente fecha; os Salmos dependem de Elo ou Dom no 3º grupo, então um jogador novo nunca vê um.
Não é bug, mas a "regra central" (Salmo transforma o poder) não chega ao jogador nas primeiras horas. Medir com 72
sementes antes de mexer (dado: `elo_chance`, `psalm_chance`, grupos no `_psalms` do `make_data.gd`).

**P2-5. Loja sem compra que importa.** Em 16 de 16 descidas o robô chegou à loja com 60 a 89 de ouro e comprou só a cura
(50); a Bênção (150), o coração (125) e a romã (100) nunca. O robô prefere Bênção a ouro nas portas, como gente faria.
Comparar a renda do Érebo do Hades II por sala (ouro por luta e quantas portas de ouro) antes de mexer no `GoldPurse`.

**P2-6. Tiro do feiticeiro, rajada do Ancião e trepadeira do sacerdote sem aviso no chão.** Só o virote do besteiro marca
linha (`horde.gd:555-558`, `if d.shot_line and not caster`); os outros têm só o gesto e as centelhas. A regra do projeto diz
"todo ataque inimigo tem aviso no chão". O Hades também não marca o orbe do Mage; decidir e alinhar a regra ou o jogo
(uma linha curta da mira, como a do besteiro, custa pouco).

**P2-7. O robô sempre escolhe a fonte** (`Rooms.bot_door`, rank -1), mesmo com a vida cheia, trocando uma porta de
Bênção por cura. Distorce Bênçãos em Morvath e a medida de dificuldade. Fonte só abaixo de, por exemplo, 80% da vida.

**P2-8. Métricas de Maestria 1 sem ultimate.** Sem save não há ultimate (`ult.id` vazio nas 12 de Maestria 1); o
jogador de verdade a tem desde a Maestria 2. Rodar a régua da E6 sempre com `--ultimate=cleave` para medir o jogo que se
joga.

**P2-9. Dívida: arquivos grandes.** `game.gd` 1741 linhas (relógio, mundo, telas, Maestria, Compêndio, RESULT,
laboratórios), `horde.gd` 1504, `boss.gd` 1431, `rooms.gd` 1146. Cada mudança de combate passa por eles; separar o
`RESULT`/registro (`RunReport`) e a Maestria e Compêndio de fim de partida (`RunAward`) do `game.gd` sem mudar
comportamento.

**P2-10. Teste instável conhecido** `test_descent.gd` (`Q-T5-5`) segue aberto.

**P2-11. Mundo mais lento abaixo de 20 qps.** O teto de 0,05 s por quadro (`game.gd:427`) deixa a partida em câmera
lenta numa máquina fraca (na Baixa da iGPU dá 62 qps, então não aparece hoje). Documentar ou subdividir o passo.

## 4. Verificação

- `~/tools/godot/godot --headless --path . -s tools/check.gd`: `CHECK ok`.
- `tools/test.sh`: **992 de 992** em 97 scripts (239 376 asserções, 234 s), rodado com 4 descidas em paralelo; o
  `test_descent.gd` passou desta vez.
- Descidas: 16 de 900 s, 0 linhas de erro, tabela da seção 1.

## 5. As 10 melhorias de maior ganho por esforço

| # | Melhoria | Ganho | Esforço | Critério de aceite |
|---|---|---|---|---|
| 1 | Provação que sempre pode virar (P1-1): encontros limitados às lutas que restam antes de Morvath; laje só onde cabem 3 | regra quebrada some; a decisão de risco volta a valer | P | `test_trial.gd`: para toda profundidade de 2 a 7 e todo mapa sorteado (500 sementes), `encounters <= lutas restantes`; 24 descidas do robô sem `trial.left > 0` no fim |
| 2 | Save atômico com cópia (P1-2) | progressão nunca perdida | P | teste com `save.json` truncado: carrega o `.bak` e não grava por cima do quebrado; gravar passa por `.tmp` e renomeia |
| 3 | Pausa ao perder o foco e ao desconectar o controle (P2-3) | molde do Hades, Steam Deck | P | sinal de foco perdido em PLAY abre a pausa; desconectar o controle em uso abre a pausa; com `--bot` ou `--smoke` nada abre; teste GUT com a notificação simulada |
| 4 | Vigia `--watchdog` (seção 2) | fecha o mistério do exe e de qualquer travamento de gente | P | linha `WATCH` a cada 5 s reais com `frames`, `fps`, `mode`, `rate`, `time_scale`, `time`; aparece no registro da partida; rodado no exe com janela por 10 min |
| 5 | Ômega carregando devagar (P2-1), número do Hades por ação em `ComboNode` (dado) | a carga pesa e tem risco, como no Hades | P a M | sonda: andar segurando o Ômega do ataque e do especial na fração do dado (medido em m/s); a esquiva corta; testes do `test_feel_c12d.gd` passando |
| 6 | Botão de usar (`interact`) para loja, recompensa e porta (P2-2) | nada comprado ou escolhido sem querer | M | ação nova no `Controls` (teclado e controle, remapeável), placa diz a tecla; encostar sem apertar não compra nem sai; robô aperta; `test_input_leak` e fluxos de loja e porta com a ação |
| 7 | Régua de medida honesta: robô com ultimate e fonte só abaixo de 80% (P2-7, P2-8) | as métricas da E6 medem o jogo que se joga | P | `smoke.sh 900` 24 sementes: `ult.uses > 0` em todas; fonte escolhida só com vida abaixo de 80% (registro `events`) |
| 8 | Elos e Salmos ao alcance (P2-4), números no `make_data.gd` depois de medir | a regra central chega ao jogador | M | 72 sementes Maestria 1: ao menos um Elo em 35% das descidas e um Salmo visto em 15%; Maestria 20 sem passar de 25 pontos acima da 1 |
| 9 | Economia da loja (P2-5) pela renda do Érebo do Hades II | a loja vira escolha (Bênção ou romã contra cura) | P a M | 24 sementes: ouro na loja com mediana entre 150 e 220; ao menos 1/3 das descidas compra algo além da cura |
| 10 | Aviso curto no chão para o orbe do feiticeiro e o leque do Ancião (P2-6) ou regra corrigida | regra do projeto cumprida; "derrotado por" justo | P | todo `Projectiles.fire` de inimigo tem `warn_s >= 0,4` no `hurt_ctx`; teste em `test_ranged_enemies.gd`; captura na GPU aprovada pelo `art-director` |
