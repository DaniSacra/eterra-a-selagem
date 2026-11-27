> Índice: [rooms.md](../rooms.md)

## Fase 2 do Plano SWORN, ritmo das salas e da descida (SW-R1 a SW-R3; 2026-11-25; `tests/test_sw_r.gd`)
Números de referência: `docs/design/sworn_rea_kingswood_2026-11-25.md` seções 3.1 e 3.2. Plano e tabelas: `docs/design/rooms_progression.md`
("Fase 2 SWORN").
- **SW-R1, orçamento de inimigos.** `EnemyDef.cost` (dado em `ENEMY_COST` do `make_data.gd`; 0 vale 0,6 do `rating`, `cost_of()`): pequeno 1
  (Rato de osso), comum 3, atirador 4, pesado 5, elite o dobro do tipo (6 a 12), maior 8 ou 9, Capitão 12. `StageDef.cost_curve` (um número por
  sala 1 a 12; depois da lista, a dificuldade antiga x `cost_per_rating`) é o orçamento de UMA onda inteira (`EncounterGen.cost_budget`).
  Cada sala de luta sorteia como é lutada (`EncounterGen.plan`, `Fight.mode`): `horde_share` 0,5 de horda (duas ondas de `horde_initial` e
  `horde_reserve` 0,75, a reserva entra atrás da primeira assim que a fila esvazia, sem esperar o chão limpar: `Rooms._horde`), o resto
  uma onda de `wave_coef_one` 1,0 ou, em `two_wave_share` 0,5, duas de `wave_coef_two` (0,6; SWORN 0,75, mas a nossa espera o chão limpar entre
  as duas e leva 10 s a mais). A onda deixou de ser cortada no máximo de corpos de pé: é uma fila (no máximo `wave_most` 20) que sobe conforme há
  lugar (`Fight.cap`, o que já valia). Sala longa (`long_depths`) virou toda sala de luta: corpos um a um e a última onda com 1 elite. `rooms[].budget`
  e `rooms[].mode` (`horde`, `waves1`, `waves2`) no `RESULT` (`RoomTally.note`). `tools/budget_probe.gd` imprime cabeças, custo e modos por sala.
- **SW-R2, âncoras.** `StageDef.rest_after_guardian`: uma das duas portas da sala depois de cada guardião (6 e 11) é uma fonte (o descanso, o
  `Kind.FOUNTAIN` de sempre, 40% de cura; as duas portas seguem juntas; a fonte não gasta o uso do Salão em `arena_max_uses`).
  `StageDef.fixed_rewards` (profundidade -> recompensas em ordem de slot, só nas portas de luta; as demais saem do baralho como sempre; as fixas
  não tiram carta dele): 2 Bênção e Coração, 7 Romã e Magia, 11 Bênção e Ouro. A 1 já era Bênção, a loja é sempre a 13, os guardiões na 5 e na 10.
  `Rooms.short_stage` zera os dois campos. Um caminho tem até 4 fontes (antes 2). `tools/run_map_probe.gd` conta as tentativas do grafo.
- **SW-R3, zonas mortas.** `RoomLayout.far_spawn` (Fendas e Santuário 1,5): o peso de cada zona de nascimento (`Rooms.spawn_weights`) é a área
  vezes (distância do centro dela ao herói sobre 8 m, entre 0,25 e 3) elevada a isso, então o próximo inimigo sobe do lado em que o herói não
  está; as zonas tardias abrem depois de 4 cabeças (`Rooms.LATE_AFTER`) e não só na 2a onda, para a horda e a sala de uma onda também as usarem.
  As áreas do Santuário `aisles` viraram `aisle_n` e `aisle_s`.

## Primeira descida guiada e Antessala (SW-O3, SW-O4; lote 3A1, 2026-11-25; `tests/test_first_descent.gd`; especificação `docs/design/onboarding_sw_o.md`)
- **Quando.** `FirstDescent.active(data, flags)` (`scripts/core/first_descent.gd`, puro): `--first` liga sempre (também com robô, sem save, `--smoke`);
  `--first=arrival` só a chegada e a Antessala (a porta não leva adiante, para capturas). Sem `--first`: falso com `--bot`, `--smoke`, `--start`, `--horde`, `--stress`,
  `--arena`, `--short`, `--medium`, `--nosave` ou `Save.enabled` falso; senão verdadeiro se `save.first == 0`. O robô, o `--smoke`, as capturas e a suíte seguem a
  descida normal, com o mesmo `RESULT` (provado com `tools/smoke.sh 900 --seed=1..6` antes e depois). `Game.first_run` guarda a decisão (calculada uma vez no `_ready`).
- **Save 16.** Campo `first`: 0 pendente, 1 feita, 2 pulada. `SaveData.merged`: versão menor com `runs` > 0 vira 1, sem descida fica 0. `Boot.first_scene` leva ao Santuário
  quem pulou (`first` 2). Fim da descida (`FirstDescent.finish`): morte e Morvath curto gravam 1 com `runs += 1` e **sem** `wins`, `firsts.victory` nem `firsts.guardian`
  (o `RunAward.award` não conta o guardião da guiada) nem a ferramenta da Forja (`Rooms` não chama `find_tool` na guiada); `Game.skip_first_descent()` (a pausa) grava 2 e vai ao Santuário.
  Fechar o jogo no meio deixa 0. O registro (`RunLog` 9) ganha `first: true` e `tools/runs_report.py` não conta essas linhas; `outcome` "first" é o Morvath curto.
- **Dados.** `data/first_descent.tres` (`FirstDescentDef`, `FirstRoomDef`; parte `first` de `tools/make_data.gd`, é onde se muda sala, onda, recompensa, anjo, vida, perigo):
  9 passos (0 a 8). Passos com duas salas são escolhas de porta; toda sala abre para todas as do passo seguinte (como a descida longa). Ondas escritas à mão, sem orçamento,
  sem elite, sem modificador, sem Provação nem Altar (`FirstDescent.stage_for` zera `trial_chance`, `altar_chance`, `route_shop_chance`, `long_depths`, `fixed_rewards`).
  `RunMap.scripted(stage, def, seed, arrival)` monta o grafo (`RunMap.is_scripted`, `Kind.ANTE` = 7, camada 0 = a Antessala, `_keeps_rules` não roda). A vida do guardião
  (`hp_scale`) é aplicada em `Rooms._spawn`; o perigo da sala liga por `hazards` e a distância da descida em que vale por `hazard_progress` (a Cripta B acorda as lajes
  de aprender em 0,2; a Casa do Cavaleiro em 0,36, como a primeira descida normal).
- **Sala a sala** (`Sala N de 8`; N é `depth`, a Antessala é 0):

| # | Sala (arena, variante) | Ondas | Recompensa | Portas |
|---|---|---|---|---|
| 0 | Antessala (layout `ante`, corredor 14 x 48; riacho, laje) | nenhuma | nada (a Bênção de Sarael é a do altar da Sala 00, 2026-11-26) | 1: Ouro |
| 1 | Cripta A (`crypt`, 1, sem perigo) | `[skeleton]`; `[skeleton x2]` | Ouro (a Bênção veio da Sala 00) | 1: Ouro |
| 2 | Fendas A (`rift`, sem quedas) | `[archer]`; `[archer x2, skeleton]` | Ouro | 2: Bênção (Nivael) ou Romã |
| 3 | Jardim A (`garden`) | `[bone_rat x5]`; `[runner x2]` | a escolhida | 2: Fonte ou Cripta B (Bênção) |
| 4 | Fonte (`hall`) ou Cripta B (`crypt`, 0, lajes de aprender) | `[skeleton, archer, bone_rat x3]`; `[guard, skeleton, archer]` | Bênção | 1: o guardião |
| 5 | Casa do Cavaleiro (`knight_hall`) | `[knight]`, vida x0,7, sem escolta | Bênção do guardião | 1 |
| 6 | Santuário (`sanctuary`, sem perigo) | `[skeleton x2, archer]`; `[mage, runner, bone_rat x4]` | Ouro | 1: loja |
| 7 | Salão (loja) | nenhuma | 3 itens | 1: Morvath |
| 8 | Câmara do Selo | Morvath curto: vida x0,6, só a fase 1 | fim da guiada | nenhuma |

  Desvio do documento: a Cripta A é a variante 1 (Ossário, sem perigo) e a B a 0 (as lajes de aprender são as da variante 0), para as duas não serem iguais; a Fonte da 4 é uma das portas
  da 3 (o documento a punha "na 3 ou na 4").
- **Antessala** (`RunMap.Kind.ANTE`; o parágrafo de 2026-11-25, valem as mudanças do bloco de 2026-11-26 logo abaixo: layout próprio, dicas novas, sem Bênção): sem luta, sem recompensa, sem cura de sala nem Prata, sem aviso "Sala N" (`notice` não sai). Desde o PT-25-8/9 (2026-11-25) ensina e a
  porta só acende no fim: `phase` OPEN desde a entrada, mas `_open_doors` só roda em `Rooms._open_ante`, quando `AnteLesson.done()` (veja o bloco de 2026-11-26 abaixo); antes disso `usable()` e a saída pela porta
  ficam fechados (`_ante_open`).
  - **Dicas** (`scripts/core/ante_lesson.gd`, pura, `tests/test_ante_lesson.gd`): uma de cada vez, cada uma espera o gesto. Ordem em `AnteLesson.ORDER`: `attack` (3 golpes do
    ataque, ou o final), `special` (o botão `heavy_attack`), `dodge` (atravessar o riacho), `shout` (Q), `rush` (E), `blessing`. Um gesto fora de hora vale (cruzou o riacho antes do
    terceiro clique: aquele passo já está feito; a linha pede o primeiro não feito). Sem Brado ou sem Investida na árvore do herói o passo some. `Rooms._on_struck` lê
    `Skills.trigger_of` do golpe (FINISHER, SPECIAL, SHOUT, RUSH, ou o golpe leve) e alimenta `AnteLesson.feed`; o texto sai pela linha de objetivo (`Objective.pick`, ctx `lesson`,
    que na Antessala vem antes de tudo; `Rooms.ante_ctx()` dá `lesson`, `near_plates` e os outros; o HUD usa `ante_ctx`). As chaves `lesson_*` usam `{attack}`, `{special}`,
    `{dodge}`, `{shout}`, `{rush}` de `UiKit.action_label`, então o controle mostra o botão do controle. Quando só falta a Bênção, `Rooms._step_lesson` abre `_give(BOON)` com o anjo
    `ante.angel` (Sarael) e, escolhida, acende a porta. O robô (`--first`) pula todos os passos menos o riacho e a Bênção. Alvos: os quebráveis do Salão; sem bonecos novos (arte).
  - **Riacho** (PT-25-9, `scripts/core/gap_rule.gd`, `RoomLayout.gaps`/`gap_fall`, `ArenaVariant.gaps`, `Arena.gaps`, `Arena.keep_out_of_gaps`, `Player.fell_in_gap`): retângulo de
    chão (2 a 4 m) que o andar não entra e a esquiva (5,6 m) vence; é dado do layout e serve a qualquer sala (as travessias opcionais da E4 usam o mesmo). Na Antessala:
    `ANTE_GAP` (x -16,5 a 16,5, z -10,6 a -8,0), de parede a parede, entre o jogador (sudoeste) e a porta (nordeste). `Player.step` põe quem anda de volta na margem de onde veio
    (`GapRule.keep_out`) e quem sai da esquiva dentro dele na margem mais perto; `gap_fall` > 0 fere o que a sala disser (`Ground.GAP_SOURCE`, "Derrotado por: Queda na Fenda"),
    0 na Antessala. A grade `Arena.nav` (inimigos, `FlowField`, nascimentos) fecha o riacho como chão que ninguém pisa (`NavGrid.build(..., gaps)`); `Arena.nav_dash` é a mesma sala com o riacho aberto e é a do
    robô (`Bot._way`, que dispara a esquiva da margem com `GapRule.hop`, até 0,9 m da margem). Inimigo não atravessa: `Horde` passa cada um por `Arena.keep_out_of_gaps` depois do `sweep`
    (andando ou empurrado fica na margem), atirador atira por cima (projétil não olha o riacho). Teste `tests/test_room_gaps.gd`. Desenho placeholder: `GapFloor` (água escura, espuma nas margens), no `Rooms._enter_with`. `Rooms.plates_crossed` agora diz "passou o riacho".
    As três lajes de aprender do SW-O3 saíram (o riacho ensina a esquiva no lugar delas).
  - `idle_blink` (25 s parado) e `broke_one` continuam; `Rooms.ante_ctx()` dá `near_plates` (perto do riacho), `near_breakable`, `crossed_plates`, `broke_one`, `lesson`.
- **Antessala nova e Sala 00 (2026-11-26, pacote `docs/art/ref/antessala_sala00_2026-11-26`, só local; `tests/test_prologue.gd`)**. Substitui a Antessala do Salão (a variante 1 do `hall` saiu).
  - **Fluxo** (`scripts/core/prologue.gd`, pura): save novo, descida guiada: Livro de Ahk, Antessala, Sala 00, sala 1. Toda outra descida (Santuário): Sala 00, sala 1. Nenhuma das duas é sala do
    grafo: `RunMap.Kind.ANTE` = 7 e `SALA00` = 8 (no fim do enum), `Room` sem id (a Sala 00) ou de profundidade 0; `depth` fica 0, o HUD mostra o nome ("Câmara de Preparação") e "Sala 1 de 14" começa na
    sala 1; `room_tally.enter` e `_log_leaving` não rodam nelas (o RESULT `rooms` começa na sala 1), guardiões, loja, contagens e profundidades não mudam. `Rooms.setup` guarda `_sala00` e `_after`
    (a primeira sala do grafo, `layer(1)[0]` na guiada); `Rooms._opening()` escolhe a primeira (`Prologue.kinds(guiada, Save.data)`) e `_enter_with` põe `next_rooms` = [Sala 00] na Antessala e
    [`_after`] na Sala 00 (a primeira sala não é "preparada": a luta dela sai como sempre saiu, na hora). Flag por save `ante` (SaveData v19: 0 pendente, 1 cruzada): escrita ao atravessar a porta da
    Antessala (`Rooms._leave`), então fechar o jogo na Sala 00 não repete o tutorial; save velho com descida jogada (ou guiada feita/pulada) migra para 1 e nunca recebe a Antessala. `--start=ante` e
    `--start=sala00` (`Game.ROOM_STARTS`, `Rooms.start_at`) abrem cada uma sozinha (o robô atravessa a Antessala e segue).
  - **Antessala** (`stage.ante_layout`, `make_data` `_ante_room`; planta `02-planta-dados.json`): piso 14 x 48 (x ±7, z ±24), entrada (0, 20), oito colunas, riacho `Rect2(-7, -8,3, 14, 2,6)` (de parede a parede, a esquiva
    de 5,6 m passa, andar não; `gap_fall` 0), laje de espetos `Rect2(-2,5, -18,5, 5, 3)` (o `PlateHazard` de sempre, ativa desde o início: `Rooms._start_one` põe progresso 1 na Antessala; 4,5 m livres de cada
    lado), seis quebráveis (vaso, caixa, urna, duas barricadas `PLANK` e um vaso; quebrável nunca dá nada em sala nenhuma: sem ouro, XP, material, nem abate), porta monumental em (0, -24). Câmera:
    `cam_bounds` de 4 x 42 m (acompanha o corredor). Proteção de morte só ali: `Player.guard_death` (o golpe nunca leva o último ponto de vida; `Rooms` liga na entrada e desliga na saída, e devolve a vida com que
    ele entrou, então a laje não cura nem mata). Dicas (`AnteLesson`): combo, Golpe Esmagador (segurar o ataque, `heavy`), Corte Circular, Lança, esquiva (riacho), laje (`passed`: passar 0,5 m além dela pelo lado);
    a Maga usa `ORDER_MAGA` (sem o Esmagador) e as chaves `_maga`; fora de ordem vale; o passo `blessing` saiu. A porta acende quando todos estão feitos (`Rooms._open_ante`).
  - **Sala 00** (`stage.sala00_layout`, `_sala00_room`): 18 x 16 (x ±9, z ±8), entrada (0, 6), quatro colunas, altar `&"altar"` 2,2 x 2,2 x 1,35 no meio, porta em (0, -8), sem inimigo, perigo ou quebrável.
    O altar (`Rooms._at_altar`, `ALTAR_REACH` 1,1 m de pedra, qualquer lado; o botão de usar paira em `_altar_front`) abre `_give(BOON, false, true)`: o sistema de anjos e cartas de sempre (na guiada o anjo
    é `FirstDescentDef.altar_angel`, Sarael), uma vez por descida. `Prologue.Grant` é a máquina: READY, OFFERED (a escolha aberta; o altar não abre de novo), TAKEN (a tela sumiu por dois passos: a escolha é modal,
    e as cartas saem de dados da run e da sala, então voltar ao par de anjos e reabrir mostra as mesmas). A porta (`_door_locked`) fica fechada (folhas de `HallDoor` e pedra na boca: `_lock_door`) até TAKEN; aí o
    altar apaga as velas (`PreludeLook.spend`) e a porta acende e abre (`_unlock_door`), sem placa nem medalhão. Primeira vez de um save: uma linha curta (`altar_intro`, `FirstTips` id `altar`; nunca para o
    robô, `--smoke` ou `--nosave`). O robô vai ao altar e depois à porta (`bot_goal`).
  - **Visual** (`scripts/game/prelude_look.gd`, filho do `AltarLook`; looks `ante` e `sala00` em `ArenaRoom.LOOKS`): forma e colisão são o que vale (a arte final será uma pintura projetada, GP-8): fachada de 7 m ao norte
    com a porta (`HallDoor.doorway`, 3 x 5,5 m, interior preto, sem escada), muretas de 1,3 m nos lados do corredor, paredes da capela na Sala 00, o altar do `AltarLook` (leão na frente, velas acesas até a Bênção),
    sem sol nem cruz nem medalhão no piso. Violeta só de Morvath e esmeralda só da Emeth: nada disso aqui. Ar da Antessala um pouco mais claro (`OUTSIDE_*`); sem captura conferida na GPU.
  - **Chegada** (`Prologue.arrival`): o cometa de `ArrivalScene` (`play(game, at, from_clock, with_caption)`) na Antessala (com a linha, só save novo), na Sala 00 vinda do Santuário (inteiro) e na Sala 00 vinda da
    Antessala (curto: o relógio da cena começa em `Prologue.SHORT_FROM` = 1,6 s, sem estrela nem preto antes, sem linha). Nunca nas salas da descida. Só com tela (`hold_frames() > 0`) ou `--first`/`--arrival`; nunca em
    `--smoke` nem nos testes sem tela (o RESULT não espera 5 s reais). `Rooms.arriving()`: `Game._step` solta os botões (`Controls.clear_presses()`) e não move o herói até a cena devolver o controle; a cena já o deixa
    invulnerável e escondido, então sem dano, sem vaso quebrado, sem Magia gasta. Sair da sala no meio a limpa (`_restore`).
  - **Diferenças da planta**: a porta tem os 3 m livres e 5,5 m de altura, as ombreiras de 0,3 m fazem o vão do muro de 3,6 m; as folhas são as do Salão (arco agudo). A laje é um retângulo só de 5 x 3. O espaço de
    câmera da Antessala é uma caixa de 4 m de largura (o corredor tem 14); a da Sala 00 é fixa como as câmaras de evento. `RESULT` do `--smoke`: a descida passa pela Sala 00 (uma Bênção a mais, no começo), então
    a semente 5 não repete a de antes.
- **Travessias opcionais** (E4, PT-25-9, `make_data` `_ring`, `SANCTUARY_ISLAND`, `RIFT_ISLAND`, `GAP_BAND` 2 m): um canteiro de chão cercado por água ou fenda de 2 m que só a esquiva pega, com um grupo
  de 2 quebráveis em cima como prêmio (quebrável não dá ouro nem Magia; uma bolsa de ouro de verdade fica para o gameplay-engineer). Nunca no caminho: portas, nascimentos, laje, entrada e
  recompensa ficam na ilha do herói (`test_room_gaps.gd`). Santuário (A, B e C): ilha 3 x 2 m no meio da nave, a oeste (x -10 a -7), anel de x -12 a -5, z -3 a 3; na B as pedras da abóbada
  começam em x -3,5 e o segundo espeto foi para (-7,5; -4,5). Fendas (A e B): ilha de 3,5 x 3 m colada à parede oeste (x -21 a -17,5, z 3,5 a 6,5), anel só em cima, embaixo e a leste.
  A ilha conta como encosto dos quebráveis (`test_arenas`) e não entra na conta de "ilha cortada". O robô não busca as ilhas (anotado). Garden, Cripta, Runas e Ponte não tinham canto livre
  de nascimento, laje, raiz ou porta; ficam sem travessia.
- **Laje de pisar 2 x 2** (E4, PT-25-10): a laje do `PLATES` agora é 2 x 2 placas de 1,25 m (2,5 m de lado, era um bloco de 3 x 3), `make_data` `SLAB_TILE` e `_plates(..., tiled)`; cada laje antiga
  mantém o centro. O desenho (`HazardPiece.plate`, `hazard_mark.gdshader` `tiles`) leva a junta em cruz e uma seta em cada placa. Laje que cede (`sag`) e placa de espetos não mudaram.
  A laje inteira fere junto.
- **Chegada** (SW-O1): `Rooms._play_arrival` carrega `scripts/game/arrival_scene.gd` se existir (`play(game, at)`, `finished`, `skip()`), uma vez, na Antessala da guiada; o preto de
  `Rooms._fade` abre em `arrival_open_at`/`arrival_open_s` do dado e qualquer ataque, esquiva ou interação depois de `arrival_skip_after` chama `skip()`. Sem o arquivo: a sala abre como as outras.
- **RESULT** com a guiada: `first` 1, `ante_s` (segundos de jogo até a porta da Antessala) e `first_boon_s` (a primeira Bênção oferecida). Sem a guiada o `RESULT` é o de sempre.
- **Pendências de integração**: `Milestones.ult_open` (o `Game._ult_open` pergunta se o arquivo existir, senão a Ultimate segue aberta), `ArrivalScene`, `Objective`, a condição `ult` do
  `HubGuide.due`, as chaves de texto novas (`room_ante`, `first_tip_*`, `first_done`, `arrival_line`, `obj_*`, `guide_ult`), `MilestoneDef` (a parte `milestones` do `make_data` só escreve quando a classe existe),
  `Boss.last_phase` e `Boss.tutorial_end` (o `Game._shorten_boss` os usa se existirem; sem eles Morvath cai inteiro e o `Game` termina a guiada do mesmo jeito).
