> Índice: [rooms.md](../rooms.md)

## E5, eventos e exploração (spec de arte `docs/art/e5_spec.md`; métricas em `docs/qa/e5_metrics.md`)
- **Três arenas novas** no `_stage` do `make_data.gd` (`_sanctuary`, `_bridge`, `_runes`, duas variantes cada, dificuldade 2):
  Santuário Desmoronado (casa do guardião: `RoomLayout.guardian_home`, `RunMap._layout` manda o MINIBOSS para ela em qualquer
  profundidade se não foi a sala anterior; ele nasce em `boss_spawn` diante da grade; variante B com a nave afundada),
  Ponte dos Condenados (comprida, três plataformas e duas pontes de 5 m, portas só na plataforma leste, sem sacerdote,
  ninguém nasce numa ponte; B com a ponte longa e o patamar) e Câmara das Runas Instáveis (4 a 6 inimigos, no máximo 2
  atiradores, câmera fixa). Partes do chão com nome (`RoomLayout.areas`, `area_names`, `area_at`): o tempo do herói em
  cada uma vai para `rooms[].zones` do `RESULT` (`RoomTally.zone_time`); desde o RP-01 em toda sala de luta (Cripta
  `north`/`middle`/`south`, B `west_of_wall`/`east_of_wall`/`south_open`; Fendas `bridge_n`/`bridge_s`/`south_way`/`west`/
  `east`; Jardim `tree_shade`/`east_field`/`rest`; Runas A `pillars`/`middle`/`edge`, B `quiet`/`middle`/`edge`; números
  e leitura em `docs/design/rooms_progression.md`). Ponte A (RP-04): a luta nasce toda na plataforma leste e um bloco de
  ruína (`block` 1,0 x 2,4 m, 2,2 m) fica 1,5 m depois do fim da ponte 2; Fendas A (RP-05): três tocos de coluna de 1,5 m
  (barram tiro), um de cada lado da fenda entre as cabeceiras e um na luta do leste. Desenhadas pelos looks do E5 (ver a seção de
  cenário acima; o `PlainLook` provisório saiu). Peças do dado com o nome que o look desenha: `column` (5 m ou mais ganha
  capitel), `column_base` (toco, para corpo e não tiro), `drums`, `bench`/`bench_broken`, `pylon`, `rune_pillar`, `quiet`
  (a pedra quieta da B das Runas, caixa que não barra nada), `trial_block`, `altar`; braseiros de parede (`brazier`) a 0,9 m
  ou mais fora do chão, os da grade do Santuário são do look. Cada porta que abre sopra o ar da sala de trás
  (`ArenaRoom.breath`, `Rooms.door_look`; Morvath = `chamber`). Opções: `--arena=sanctuary|bridge|runes`, `--start=trial|altar`.
- **Runas** (`HazardDef` no `RoomLayout.hazard`, lógica pura `ArenaHazard`, no jogo `RuneFloor`): grade de 10 x 8 ladrilhos
  de 3 m; padrões só em faixas e ladrilhos (A: `sweep`, `comb`, `cut`; B: `checker`, `frame`, `islands` e a pedra quieta no
  meio); aviso 1,2 s, golpe 0,25 s, descanso 2,4 s, nada nos 3 s do começo, nas portas nem em ladrilho cortado pela borda;
  nem em ladrilho com chão a menos de 6 m da entrada (RP-02: `RUNES_ENTRY` no `make_data.gd`, somado ao `HazardDef.quiet`
  das duas variantes, só regra, o `RunesLook` não pinta; GUT com 2000 padrões por variante em `test_hazard.gd`);
  no máximo 35% aceso (os densos, 50%, só com até 3 inimigos de pé) e todo ladrilho aceso tem um vizinho apagado. Fere o
  herói 7 (RP-03 passo 1, era 4; o Hades fere 10 sobre os mesmos 30 de vida; como aviso, `Ground.add_hazard`) e todo inimigo
  comum em cima 60 (era 35; `Ground.hazard_landed`); "Derrotado por: Runas
  Instáveis" (`killer_runes`). Desenho: estilo `GroundLook.Style.HAZARD` (âmbar `HAZARD_COLOR`, moldura por ladrilho
  `tile_m`, preenchimento fraco, `render_priority` -1, abaixo dos avisos vermelhos), mas na sala de verdade quem desenha é o
  próprio chão: o `RuneFloor` escreve a cada quadro o estado de cada ladrilho no `RunesLook` (`RuneFloor.paint`:
  `ArenaHazard.state` = preparo, golpe e brasa de 0,4 s, `ArenaHazard.EMBER`; divisas da varredura por `ArenaHazard.chevron`
  só no preparo; um `apply`, nada quando em repouso) e os avisos do `Ground` ficam invisíveis (`add_hazard(..., drawn)`,
  nada desenhado duas vezes; continuam ferindo). Grade conferida contra o look (`RuneFloor.fits`, 10 x 8 de 3 m desde
  (-15; -12)); em outro look o âmbar volta. `rooms[].hazard` no `RESULT`, com `patterns` (até 16
  `[segundo da sala, padrão, ladrilhos acesos]`, `RuneFloor.patterns`, AT-RB2). Som: `rune_arm` ao armar e `rune_crack` no
  golpe, um por padrão (ver o som do combate).
- **Laje Rachada (RP-06, H-2; RP-13; plano e medidas em `docs/design/rooms_progression.md`)**: segundo tipo de
  `HazardDef` (`kind` `GRID` as Runas, `PLATES` as lajes; campos `plates`, `rearm`, `from_progress`, e por laje
  `plate_hero_damage` e `plate_push`), dado no `_stage` (`_plates`, `PLATES_FROM` 0,34). Lajes de 3 x 3 m que qualquer
  um arma ao pisar (herói ou inimigo, como o vapor do Hades II): 1,0 s de aviso acendendo da borda para o meio, golpe de
  0,25 s em quem está em cima (herói 7, inimigo 60, os números do RP-03), recarga 5 s; nada nos 3 s do começo, nada em
  laje na boca de porta, no máximo 2 armadas ao mesmo tempo (`PlateHazard.MOST_AT_ONCE`, R9); antes do progresso 0,34 (salas
  2 e 3) ficam desenhadas e dormem. Lógica pura `PlateHazard` (`core/plate_hazard.gd`), no jogo `PlateFloor`
  (`game/plate_floor.gd`, criado por `Rooms._start_hazard` em luta e no guardião): o golpe é o `Ground.add_hazard(...,
  drawn = false, Ground.PLATE_SOURCE)`; o desenho é dele, um nó por laje pendurado na arena (`GroundLook.plate`,
  `set_plate`: moldura e duas rachaduras em osso apagado em repouso, `PLATE_REST_COLOR`, nunca âmbar; armando, o âmbar das
  Runas entrando da borda; `plate` e `crack_m` no estilo HAZARD do `ground.gdshaderinc`; placeholder até a peça do
  `environment-artist`, SW-G7). Onde: Cripta A (quatro, junto das paredes, fora dos corredores do sarcófago), Cripta B
  (duas no pé do muro divisor), Santuário A e B (duas em cada nave lateral). RP-13, a borda que desmorona (Santuário
  B): duas lajes nas pontas do buraco ferem 5 e jogam todos 2,5 m para longe dele (`plate_push`, por `Arena.sweep`,
  ninguém cai), zona `hole_edge`. "Derrotado por: Laje Rachada" (`killer_plates`, nome provisório para o Daniel); som
  `plate_arm`/`plate_fire` = `rune_arm`/`rune_crack`. `rooms[].hazard` com `kind` `plates`, `hero_damage`, `enemy_damage`,
  `kills`, `strikes`, `armed_by_hero`, `armed_by_enemy` e `hero_on_s` (segundos dele em cima); o das Runas ganhou
  `hero_damage`. Testes em `tests/test_plates.gd` (ritmo, inimigo arma, dormente, porta, duas de cada vez, lugares
  contra chão, peças, portas, nascimentos e 6 m da entrada, saída andando de 12 x 12 pontos, sala real, empurrão).
- **Corrente da Ponte (RP-11, H-3; `docs/design/rooms_progression.md`)**: terceiro tipo de `HazardDef` (`LINE`: `bands`,
  `band_push`, `cycle`), faixas que golpeiam uma por vez e em ordem no relógio da sala (`BandHazard`, `core/band_hazard.gd`;
  no jogo `BandFloor`, `game/band_floor.gd`, pelo `Rooms._start_hazard`, `Rooms.bands`): 3 s de calma, uma a cada 6 s,
  aviso 1,2 s desenhado como a faixa âmbar (`Ground.add_hazard`, `Ground.CHAIN_SOURCE`; placeholder até a corrente do
  `environment-artist`), golpe 0,25 s de 7 no herói e 60 no inimigo, empurrão de 2,5 m ao longo da ponte para a
  plataforma (`PlateFloor.strike`, comum às lajes); faixa na boca de porta nunca golpeia. Ponte A: uma faixa de 2 m em
  cada ponte, alternando; B: as duas metades da ponte longa, a 6 m do patamar (`_chain`, `CHAIN_PUSH` no `make_data.gd`).
  "Derrotado por: Corrente da Ponte" (`killer_chain`, provisório); `rooms[].hazard` `kind` (`band_source`), `hero_in_s`; som
  `chain_arm`/`chain_fire` = os das Runas. Testes em `tests/test_chain.gd`.
- **Fenda que respira (RP-08, H-4)**: o `LINE` sem dano nas Fendas (`HazardDef.band_source` `breath`, `Ground.BREATH_SOURCE`;
  `_breath`, `RIFT_BREATH` no `make_data.gd`): quatro trechos da beira onde a luta acontece, um por vez a cada 7 s, o
  com mais inimigos primeiro (`HazardDef.band_busy`, `BandHazard._busiest`), aviso 1,2 s, empurrão de 2,5 m para longe
  da beira que corta a preparação ou o ataque de quem foi empurrado (`PlateFloor.strike(..., cut)`; nunca investida
  imune nem guardião); o aviso do chão sem dano não fere (`Ground.Zone.floor_own`: aterrissa e avisa `hazard_landed`
  mesmo sem dano, `hit_player` só com `power` acima de 0). Som `breath_arm` = `rune_arm`, `breath_fire` = `dodge`.
  `rooms[].hazard` `kind` `breath` com `pushed` e `cut` (a corrente também). Testes em `tests/test_breath.gd`.
  **S (2026-11-25, RD2-04c)**: o respiro agora fere 10 só em inimigo (`BREATH_ENEMY` no `make_data.gd`, `enemy_damage` 10, `hero_damage` 0; o
  corte da preparação continua, `BandFloor._on_landed`); chave "Derrotado por" é a do `breath` do `DefeatCause`.
- **Coluna rachada que tomba (RP-09, a árvore que cai do Érebo do Hades II)**: `ArenaObstacle.hits_to_fall` (0 = nunca),
  `fall_length` 5, `fall_width` 1,2, `fall_time` 0,6, `fall_damage` 50 (`_cracked` no `make_data.gd`): Santuário A e B
  (15; -6) e (-9; 6), Jardim A (4,5; 7), Cripta B (6,5; -6). Só os golpes do herói contam (`Combat.reached`: forma,
  origem, direção, alcance e largura de todo golpe do combo com dano; `ColumnFall.touches`): o 1º racha, o 2º tomba
  para onde o golpe foi (nunca de volta nele): faixa âmbar de 1,2 x 5 m por 0,6 s enquanto inclina
  (`Ground.add_fall`, `FALL_SOURCE` `column`, sem `power`), 50 a todo inimigo cujo corpo toca a faixa
  (`PlateFloor.strike(..., bodies)`), nada ao herói; fica o toco no mesmo lugar (para corpos, não tiros: sai do
  `Arena.cover`; a grade de andar não muda). Uma vez por coluna por sala. Lógica pura `ColumnFall`
  (`core/column_fall.gd`), no jogo `ColumnFloor` (`game/column_floor.gd`, criado pelo `Rooms._start_hazard` em luta e
  guardião, `Rooms.columns`); `rooms[].columns` (`cracked`, `toppled`, `enemy_damage`, `kills`). Som `column_crack` =
  `rune_crack`, `column_fall` = `boss_down`. Robô: vai a uma coluna a até 10 m que cairia sobre um inimigo ou mais,
  contorna para o outro lado e golpeia na direção do bando (`Bot.column_plan`, `COLUMN_*`). **Visual provisório, para o
  environment-artist**: as malhas da coluna ficam fora do `merge` (`ArenaRoom.toppling`, `Masonry.take_since`) sob um
  pivô no pé; a racha só balança 3 graus com poeira, o tombo gira o pivô até 82 graus em 0,6 s e ao bater ela some e
  aparece um `TombKit.column` quebrado baixo com poeira ao longo da faixa e tremor. Falta: racha desenhada na pedra
  (fissura que acende ou abre no 1º golpe), a coluna caindo de verdade (tambores se separando, pedaços rolando na faixa,
  a coluna deitada ou em pedaços no chão depois, sem colidir), o toco com a quebra (topo irregular, lascas em volta) e
  pó mais grosso no impacto; nada pode mudar a colisão nem a faixa. Testes em `tests/test_columns.gd`.
- **Raiz que golpeia (RP-10, H-1)**: as lajes do RP-06 ganharam faixas giradas (`HazardDef.strips`: segmentos de `a` a
  `b` com `strip_width` 3 m, numerados depois dos retângulos; `PlateHazard.on`, `bounds`, `from`/`dirs`/`lengths`/`widths`),
  espera para armar (`dwell`: segundos que alguém fica em cima; 0 nas lajes), empurrão para longe da linha do meio
  (`push_out`; `PlateFloor.strike(..., out)`, `PlateFloor.away`) e nome próprio (`plate_source`; sons `<nome>_arm` e
  `_fire`, as lajes seguem `plate_arm`). Jardim (`_roots` no `make_data.gd`): as duas raízes de fora de cada variante
  (A: a do norte e a do oeste, cortada antes de 6 m da entrada; B: a do oeste, cortada, e o toco junto da parede oeste),
  faixa da face do tronco até a ponta; quem fica nela acorda (herói 0,5 s, inimigo 0,2 s, `HazardDef.enemy_dwell`): 1,2 s de aviso âmbar com poeira,
  golpe 0,25 s de 7 no herói e 60 no inimigo, empurrão de 1 m para fora da raiz, 6 s até acordar de novo; dormente
  antes da sala 4 (`PLATES_FROM`). `Ground.add_band` (o `add_hazard` sobre qualquer faixa), `GroundLook.plate_band`
  (placeholder: a moldura da laje ao longo da raiz; a raiz que racha é do environment-artist), `Ground.ROOT_SOURCE`
  `roots`, "Derrotado por: Raiz Morta" (`killer_roots`, provisório para o Daniel). `rooms[].hazard` `kind` `roots`. A 1ª onda nascendo a oeste e ao sul do tronco foi provada e voltou (2026-11-20: pátio do Jardim a 9% na A e 15% na B, meta 20%; `rooms_progression.md`).
  Testes em `tests/test_roots.gd`.
- **Seteira ligada à laje (RP-16)**: uma laje do RP-06 com `HazardDef.aims[i]` (segmento da boca da seteira até onde os
  virotes param, `aim_width` 1 m; `aims_away(i)`) arma a seteira em vez de golpear a si mesma: a faixa da seteira avisa
  1,0 s em âmbar desenhada (`Ground.add_band`, `Ground.SLIT_SOURCE` `slit`) e golpeia quem está nela (7 no herói, 60 no
  inimigo), recarga 5 s pela laje. Cripta B (`_slit`, `SLIT_WEST`, `SLIT_EAST` no `make_data.gd`): uma seteira na parede
  norte de cada lado do muro divisor, peça `bolt_slit` de 0,5 x 0,6 m e 1,2 m (barra corpo e tiro; bloco provisório até a
  seteira com a divisa do environment-artist), atirando para o sul até a fileira dos sarcófagos; a laje de um lado arma a
  seteira do outro. "Derrotado por: Seteira" (`killer_slit`, provisório), som `slit_fire` = `bolt`; `rooms[].hazard` com
  `slit_damage` e `slit_struck`. Robô: pisa na laje a até 8 m quando 2 inimigos ou mais estão na faixa e ele não
  (`Bot.slit_plan`, `in_band`, `SLIT_*`). Testes em `tests/test_slits.gd`.
- **Aviso de área padronizado (SR-P4, lote 3, 2026-11-21)**: um só estilo de aviso de área no chão, o do inimigo comum:
  vermelho de aviso (`GroundLook.WARNING_COLOR`), contorno limpo de `RIM_METERS`, chão fraco subindo até `FILL_MAX`
  (0,35). Passaram a usá-lo os perigos que eram âmbar com moldura por ladrilho: corrente, respiro, seteira, raiz, nicho,
  planta, laje armando, pedras, urna, óleo e a armadilha de parede (`GroundLook.HAZARD_COLOR/STRENGTH/RIM` agora são as do
  inimigo; só a prioridade de desenho continua abaixo dos avisos dos inimigos). Seguem como estavam, de propósito: os
  ladrilhos das Runas (`RunesLook`, peça própria), a assinatura violeta dos avisos de Morvath (contorno e preenchimento
  já eram os padrões; só o fio e as runas são dele) e a mira fina do besteiro (`GroundLook.aim`, é uma mira, não uma
  área). Já usavam o padrão: círculos de atiradores e mágicos, cone do soldado, golpes de chefe.
- **Armadilha de parede (SR-P1, lote 3)**: bloco na parede que lança lâminas numa faixa de 1,2 m. É um `HazardDef`
  LINE com `band_source` `trap` (a corrente sem empurrão): `bands` são as linhas, `band_dir` o sentido (`band_dir_of`),
  `band_busy` faz a linha com mais inimigos ir primeiro (atrair o bando), `from_progress` a deixa dormindo (o bloco
  fica, nada voa; `BandFloor(awake)`). 1,2 s de aviso na faixa (padrão P4), 10 no herói, 60 no inimigo, calma de 5 s,
  uma linha por vez. O bloco é o obstáculo `trap_block` (corpo e tiro, 1,2 x 0,6 m) com a peça da seteira (`HazardPiece.slit`,
  boca acendendo, três chevrons no sentido do tiro; placeholder). Fonte `Ground.TRAP_SOURCE`, "Derrotado por: Armadilha de
  Lâminas" (`killer_trap`), sons `trap_arm`/`trap_fire`, `rooms[].hazard.fired`. Dado: `_trap`, `_trap_blocks`,
  `GARDEN_TRAPS`, `SANCTUARY_TRAPS` no `make_data.gd`: Jardim A (2 linhas, desde 0,3, ciclo 6 s), Santuário A (3 linhas,
  desde 0,5, ciclo 4,5 s) e C Colunata (2). Testes em `tests/test_traps.gd`. Plano e métricas em `rooms_progression.md`.
- **SR-P2, P3, P5 e a armadilha mais dura (2026-11-21, room-designer)**. Dois campos novos no `HazardDef` valem para
  qualquer perigo `LINE` ou `PLATES`: `late_from` (0,7 da descida), `cycle_late` e `rearm_late` (`cycle_at(p)`,
  `rearm_at(p)`; `BandHazard` e `PlateHazard` recebem o progresso e guardam `cycle`/`rearm`). Só o descanso encurta; o
  aviso e a duração do golpe nunca mudam. `Rooms._start_hazard` agora percorre toda a cadeia `also` (um slot por tipo:
  até 2 `PLATES`, 1 `LINE`, 1 de cada o resto; `test_hazard_sr.gd` trava).
  **Laje que cede** (`plate_source` `sag`, `_sag`): `PLATES` com `dwell` 0,7 s (inimigo 0,35 s), aviso 1,4 s (mais longo
  que o dos inimigos: dá para sair), 10 e 60, descanso 8 s (6 s desde 0,7), calma 5 s, dormente antes de `from`. Peça
  `HazardPiece.Kind.SAG` (a laje do RP-06 sem setas: rachaduras, poeira e o afundar). Fendas A (2 lajes a leste, desde
  0,4) e Santuário A (3 lajes, desde 0,5; é a casa do guardião). **Grade de fosso** (`band_source` `spikes`, `_spikes`):
  `LINE` em quadrados de 2,4 m, uma por vez, a com mais inimigos primeiro (`band_busy`), aviso 1,2 s, espinhos de pé 1,0
  s, ciclo 3,5 s (2,8 s desde 0,7), 10 e 60. Peça `Kind.GRATE` (moldura de ferro, fosso escuro, 16 espinhos que
  espiam a 25% no aviso, sobem cheios no golpe e recolhem; placeholder). Cripta A e B (desde 0,4) e Santuário B (desde
  0,55). Fontes `Ground.SAG_SOURCE`/`SPIKES_SOURCE`, "Derrotado por: Laje que Cedeu" e "Grade de Espinhos", sons
  `sag_*`/`spikes_*`. **Armadilha de parede mais dura**: linha de 1,6 m (era 1,2), Santuário A e C ciclo 3,5 s (era 4,5)
  e 2,8 s desde 0,7; Jardim A 5 s e 4 s (era 6). **Relíquia na pedra (SR-P5)**: `RoomLayout.relic_spots` (Cripta,
  Fendas, Jardim, Santuário), `StageDef.relic_*` (50% das lutas desde a sala 3, dados da própria sala: nunca os da
  descida), `RelicFloor` (pedra com anel claro, placeholder), `Rooms._relic_cleared/_step_relic`: depois da luta, F
  junto dela dá 30 de ouro ou 6 de Prata Antiga (sorteio da sala), uma vez; o robô vai até ela antes da recompensa.
  Texto de trabalho (`hub_use_relic` "Tocar"); **tema a confirmar com o Daniel**. Testes: `tests/test_hazard_sr.gd`.
- **Mureta (RP-17)**: só dado, caixas baixas de 0,9 m (`_capsule(..., 0.5, 0.9)`, peça `block` desenhada como mureta
  baixa; o corpo dá a volta, o tiro passa por cima): Cripta A uma de 5,5 m ao sul do túmulo grande ((-3,5..2; 3,8));
  Jardim A duas quebradas num arco a 6 m do tronco (`_low_arc`: leste de -6 a 21 graus, sul de 64 a 98), as raízes que
  cruzam o arco as três entradas de 4,5 m. Testes em `tests/test_low_walls.gd`.
- **Lote A, frente A1 (2026-11-21; `docs/design/rooms_progression.md` seção "Lote A, frente A1"; critérios em
  `docs/design/combat_cadence.md` 9), valendo sobre os números acima**: todo perigo de sala tira 10 do herói
  (`HAZARD_HERO` no `make_data.gd`; era 7) e a borda que desmorona 7 (`CRUMBLE_HERO`; era 5); inimigos seguem 60.
  Laje Rachada com aviso de 1,2 s (era 1,0; P0 do combat-feel-director com o 10). **R9, dois avisos de sala no máximo**:
  `PlateHazard.MOST_AT_ONCE` 2 (era 3) e contado com os outros perigos da sala (`PlateHazard.step(..., others)`,
  `Ground.room_live` e `room_rects` sobre `Ground.ROOM_SOURCES`; um padrão das Runas ou uma descarga conta um). **Dois
  perigos na mesma sala**: `HazardDef.also` (Santuário B lajes e pedras, Fendas B fôlego e pedras, Cripta A lajes e
  urnas), iniciado pelo `Rooms._start_one`; o `RESULT` guarda o segundo em `rooms[].hazard.also`
  (`RoomTally.hazard`, `hurt_in_room`).
- **Cristal Instável (RP-14, H-5)**: campos `crystals`, `crystal_cols`, `crystal_hits` 3, `crystal_radius`,
  `crystal_from` no `HazardDef` GRID; Runas B com dois cristais fora do chão junto da parede norte, (-4,5; -12,6) na
  coluna 3 e (10,5; -12,6) na coluna 8. Cada golpe do herói que toca um cristal o carrega (`Combat.reached`,
  `ColumnFall.touches`; nada nos 3 s do começo nem com uma descarga no chão); no 3º ele descarrega na hora pela coluna
  (`ArenaHazard.discharge`: só ladrilhos que podem acender, nunca a pedra quieta, a entrada nem porta; 1,2 s de aviso
  com as divisas para o sul, golpe das Runas, 10 / 60; o padrão das Runas que esquentava apaga sem golpear, nunca dois
  no chão), e da 2ª carga a coluna fica um degrau mais clara em repouso (`ArenaHazard.hint`, `RuneFloor.HINT` 0,3).
  Lógica pura `CrystalHazard` (`core/crystal_hazard.gd`), no jogo pelo `RuneFloor` (marca provisória: uma laje de
  1,6 x 0,8 m no chão diante de cada cristal, `GroundLook.plate`, acende com a carga). "Derrotado por: Cristal
  Instável" (`killer_crystal`, provisório), sons `crystal_charge` = `ward`, `crystal_arm`/`_fire` = os das Runas;
  `rooms[].hazard` com `crystal_charges`, `discharges`, `crystal_damage`, `crystal_kills`, `crystal_hero_damage`. Testes
  em `tests/test_crystals.gd`.
- **Pedras da Abóbada (RP-20)**: `HazardDef.Kind.DROPS` (`drop_zones`, `drop_size` 2, `drop_count` 2, `drop_every` 4,
  `drop_aim` 0,5; `_rocks` no `make_data.gd`, desde a sala 4): quadrados de 2 m caindo um a cada 4 s depois dos 3 s,
  metade mirada nele quando está numa zona, 1,2 s de aviso (o quadrado inteiro desde o primeiro quadro, o âmbar das
  Runas enchendo; a pedra cai nos últimos 0,25 s e toca o chão no quadro do golpe), 10 / 60; nunca sobre outra pedra,
  outro aviso da sala, porta nem fora do chão, e nunca com a sala já com dois avisos (R9). Entulho só desenhado por
  3 s (não para corpo). Santuário B: a nave em volta do buraco (x -8 a 13); Fendas B: a plataforma leste (dois
  retângulos). Lógica pura `DropHazard` (`core/drop_hazard.gd`, dado próprio pela `fight_seed` do nó), no jogo
  `DropFloor` (`game/drop_floor.gd`; pedra provisória em caixa cinza, poeira caindo, tremor). "Derrotado por: Pedras da
  Abóbada" (`killer_rocks`, provisório), sons `rocks_arm` = `rune_arm`, `rocks_fire` = `boss_down`; `rooms[].hazard`
  `kind` `rocks`, `hero_in_s`, `aimed`. Testes em `tests/test_rocks.gd` (também o R9 das lajes).
- **Urna de Óleo (RP-12, o barril do Hades II)**: `HazardDef.Kind.URNS` (`urns`, `urn_radius` 2,5, `urn_flows`,
  `flow_*`, `burn`; `_urns`, `_urn`, `CRYPT_URNS`, `CRYPT_OIL`, `URNS_FROM` 0,67): Cripta A, duas urnas de bronze ao pé
  das paredes leste (11,2; -1,6) e norte (-1,6; -10), peça `oil_urn` de 0,45 m e 1 m (barra corpo, tiro passa;
  desenho genérico até a peça do environment-artist). Um golpe do herói acende: o aro de 2,5 m inteiro em âmbar desde o
  primeiro quadro (`Ground.add_round`, `GroundLook.hazard_round`, ramo novo do estilo 3 no `ground.gdshaderinc`) por
  1,3 s (P0 do combat-feel-director) e explode 10 nele e 80 em cada inimigo; o óleo corre pelo canal a 3 m/s em trechos
  de 2 m, cada um avisado 1,0 s antes da chama (faixa âmbar desenhada), 5 nele e 40 no inimigo quando a chama chega, e
  arde 2 s (quem entra leva uma vez por trecho). Uma vez por urna por sala; antes de dois terços da descida o golpe só
  faísca. Lógica pura `UrnHazard` (`core/urn_hazard.gd`), no jogo `UrnFloor` (`game/urn_floor.gd`). "Derrotado por: Urna
  de Óleo" e "Óleo em Chamas" (`killer_urn`, `killer_oil`, provisórios), sons `urn_arm` = `tell_ember`, `urn_fire` =
  `enemy_burst`, `oil_arm`/`_fire` = os das Runas; `rooms[].hazard` `kind` `urn`, `lit`, `blasts`, `oil_damage`,
  `oil_hero_damage`. Testes em `tests/test_urns.gd`.
- **Robô com o cristal e a urna (Lote A, no molde do `Bot.column_plan`; `tests/test_bot_hazards.gd`)**:
  `Bot.crystal_plan` vai a um cristal a até `CRYSTAL_NEAR` 18 m (desperto, sem descarga nem calma no chão) quando a
  coluna dele tem `CRYSTAL_PACK` 2 inimigos ou mais (pelo corpo), golpeia de `CRYSTAL_SIDE` 2,1 m ao lado (fora da
  coluna) e `CRYSTAL_BACK` 1,4 m ao sul até descarregar; `Bot.urn_plan` vai a uma urna acordada e apagada a até
  `URN_NEAR` 10 m com `URN_PACK` 2 inimigos no anel e golpeia de `URN_REACH` 1,5 m do lado longe do bando (depois foge
  do anel pelo `_danger`). Ordem: coluna, cristal, urna. Medido em 12 sementes (`smoke 700`): o cristal só acorda na
  sala 7 (`crystal_from` 0,5); na semente 1 o robô carregou 4 vezes e descarregou 1 (120 de dano); a urna foi acesa nas
  2 salas acordadas, mas o bando sai do anel em 1,3 s (0 a 120 de dano). Nenhum `stuck`.
- **Colunata (RP-18)**: Santuário C (`depth` 0,5 a 1): o leste da nave vira uma grade de nove colunas baixas de 2,5 m
  (`COLONNADE`, x 3, 7 e 11 por z -4, 0 e 4, raio 0,5: barram corpo e tiro mas nunca escondem um preparo, critério do
  combat-feel-director), duas reduzidas a tocos (`column_base`, corpo sim, tiro não) e uma rachada que tomba 3 m
  (RP-09); o oeste da nave fica aberto para a investida do guardião; lajes da A; zona `colonnade`. Só dado.
- **Portas no fundo (RP-19)**: `tests/test_exits.gd` confere em toda sala de luta e variante cada porta a 8 m ou mais da
  entrada, fora de toda zona de nascimento e 5 m ou mais das outras; todas já passavam, nenhuma porta mudou.
- **Protótipos do atlas (AT-H1 a AT-H3, Lote D; Q-AT3 a, Q-AT4 a; `rooms_progression.md` seção "Lote D")**: **AT-H1, laje de
  pressão do Santuário** = o RP-06 que já existe; a isca (inimigo que pisa e arma) já vale (`armed_by_enemy`), cada laje
  das naves tem uma faixa de 1 m livre ao lado (teste); o robô não atrai inimigos de propósito (o `Bot.lure_plan` é do
  gameplay-engineer). **AT-H2, Esqueleto do Nicho (Cripta B)**: faixa de laje (`_niche`, `NICHE_AT` (-12; -6,5) na parede
  oeste, 2,2 x 2,2 m) no `hazard.also` da B, desde a sala 4: acorda com ele 0,3 s (inimigo 0,2), 1,2 s de aviso, agarra
  0,25 s, 10 / 60 e **puxa 1 m para o nicho sem prender** (`HazardDef.pull`; no herói em `PlateFloor.PULL_TIME` 0,12 s,
  quadro a quadro por `Arena.sweep`, encurtado na borda de outro aviso do chão ou da pedra, R10, `PlateFloor.pull_reach`;
  a esquiva corta), recarga 6 s; o grupo de quebráveis da parede oeste da B saiu dali. **AT-H3, Planta Hostil (Jardim
  B)**: no lugar da raiz do toco junto da parede oeste (as raízes da B ficam com uma), `_plant`, `PLANT_AT` (-16,6; -1,5),
  faixa de 2,5 x 1,5 m para o leste, como a raiz: 0,5 s (inimigo 0,2), 1,2 s, 10 / 60, empurrão de 1 m para fora, 6 s.
  Nos dois a Emeth só faísca (`HazardDef.sparks`, `spark_radius` 0,6, pelo `Combat.reached` e `ColumnFall.touches`: nada
  ferido, não é inimigo, então a mira assistida nunca o escolhe, sem número nem hit stop). Segundo PLATES da sala em
  `Rooms.plates_also`; `rooms[].hazard.also` com `kind` `niche`/`plant`, `pulled`, `sparked`. "Derrotado por: Esqueleto do
  Nicho" e "Planta Hostil" (`killer_niche`, `killer_plant`, provisórios para o Daniel); sons `niche_arm`/`plant_arm` =
  `rune_arm`, `niche_fire` = `bone`, `plant_fire` = `enemy_swing`. Desenho provisório: a moldura de laje ao longo da faixa
  (`GroundLook.plate_band`) e faísca; a mão do esqueleto e a planta são do environment-artist (SW-G7 3.5). Testes em
  `tests/test_niche_plant.gd`.
- **AT-SA2, o 1º aviso na tela**: `tools/first_warning.gd -- --bot --autopick --nosave --seed=N [--cam=far]` joga a
  primeira sala e imprime `FIRST_WARNING` com onde o contorno do primeiro aviso de inimigo cai na tela (0 a 1) no
  quadro em que aparece; no Salão, inteiro em 8 de 8 sementes na Perto e na Longe (`rooms_progression.md`).
- **Hipóteses de planta do atlas (AT-CA2, AT-SE2, AT-PB2, AT-FO2; `rooms_progression.md`)**: contador novo
  `rooms[].dodge_blocked_by` (esquiva cortada pela pedra ou pela borda, uma vez por esquiva: sinal `Player.dodge_blocked`,
  `Arena.blocker_at` dá `peça@x,z` da planta ou `edge`, `RoomTally.dodge_blocked`). Cripta A, Santuário B e Ponte B
  ficaram como estavam (medidas abaixo do limite). A Fonte do Salão nasce em `Rooms.FOUNTAIN_SPOT` (-8; 10), na tela das
  duas câmeras quando ele chega pelo patamar (antes (0; -2), fora das duas); `test_the_fountain_is_seen_on_arrival` em
  `test_arenas.gd`.
- **Morte de elite** (V-14): elite de aço dourado (`EnemyDef.elite` com `gild`; guardiões não) cai com duas lascas de
  ouro velho a mais (`CrowdRenderer.GILD_COLOR`, `Horde.damage`); teste em `test_vfx_lote1.gd`.
- **Provação** (o Caos; `Trials`, `TrialDef` em `data/trials/`, parte `trials`; números no grupo Events do `StageDef`): laje
  numa sala de luta vencida (20%, profundidades 2 a 7, intervalo de 10 salas, nunca com maldição em curso), custo
  `ceil(10 + 0,5 x profundidade)` só com mais vida que isso; pisar paga e leva à câmara (`stage.trial_layout`), com 3
  cartas (Bênção forte com raridade sorteada, maldição por 3 a 5 encontros) e as portas da sala de antes (fechadas até
  pegar uma). A laje é a do look (`TrialLook.entry_slab`, com a placa e um fio de luz marfim de 1,2 s ao surgir, sem
  lâmpada própria); escolhida a carta, `TrialLook.settle`; feita a troca do altar, `AltarLook.kindle` (`Rooms._to_look`).
  A maldição age em `Horde.speed_scale`, `Player.heal_scale`, `Player.hurt_scale`, ondas (`wave_extra`) e
  ouro (`gold_pct`); depois do último encontro vira a Bênção (`BoonState.grant`, "Provação vencida").
  Para a UI: `Rooms.trials` (`active`, `left`, `won`), `trial_cards`
  (`Trials.Card.view()`), `take_trial(i)`, sinais `trial_slab_shown`, `trial_entered`, `trial_offered`, `trial_taken`,
  `trial_turned`. Robô: paga se sobrar 60% da vida (`Trials.bot_accepts`) e pega a primeira carta.
  **Interface (spec 5.3)**: pisar diante do bloco (`Rooms.TRIAL_SPOT`) abre as cartas numa tela (`EventChoice.open_trial`,
  `scripts/ui/event_choice.gd`, filha da `BoonChoice`; `Game.open_screen`/`close_screen`; escolher chama `take_trial`):
  `BoonCard.setup_trial` com a Bênção em cima (nome, "Bênção" e a raridade, que também é a borda) e a maldição numa
  faixa de tinta lilás-escura com por quantas lutas; o medalhão é o da Bênção (`BoonIcon.setup_glyph`, `TrialSeal.blessing_look`) com o losango rachado pequeno como selo. Robô e `--autopick` pegam
  a primeira sem tela. No HUD, acima do medalhão, o selo `TrialSeal` (losango lilás acinzentado de 33 px a 1080, encontros
  que faltam dentro, nome da maldição ao lado, escondido enquanto o selo da maldição de Morvath está de pé; nada no herói,
  E5-D7); na virada a rachadura enche de ouro velho em 0,4 s e o `EloBanner.show_trial` diz "Provação vencida" com o nome e
  o efeito da Bênção (`Hud.show_trial_won`, no lugar do aviso). A laje mostra o losango e troca "Pisar custa N de vida" por "Vida
  insuficiente" no rosa apagado enquanto falta vida (`DoorSign.set_short`).
  **T5 (o PO não entendeu Provação nem Altar)**: cada tela de evento tem uma linha sob o título (`BoonChoice._page(...,
  lead)`, nó `Lead`): "A maldição começa agora. Vença as lutas e a Bênção fica com você até o fim da descida." e, embaixo,
  "A vida já foi paga. Escolha uma carta para abrir as portas."; a carta da Provação (`TRIAL_SIZE` 320 x 404) diz
  "Bênção · Rara", "VOCÊ RECEBE DEPOIS DE N LUTAS", o número e "e fica até o fim da descida" e, na faixa,
  "VOCÊ CARREGA NAS PRÓXIMAS N LUTAS" (a Bênção só vem na virada, `Rooms._fight_won`; testado). A laje ganha uma nota
  (`DoorSign.add_note`, uma linha por rótulo, entrelinha `LINE_PITCH` 1,15, véu escuro atrás): "Uma Bênção forte, com uma maldição" e "Para recusar, não pise". Altar: "Uma troca só, ou
  nenhuma. O que mudar vale até o fim desta descida."; cada carta com VOCÊ ENTREGA e VOCÊ RECEBE, os números e o antes e
  depois (vida máxima, ouro, Magia máxima: `Altar.options` devolve `give_from`/`give_to`/`get_from`/`get_to`, `why` e
  `short`, só informação), o porquê exato ("Faltam N de ouro", "Nenhuma Bênção sua pode subir de nível", "Vida máxima
  baixa demais") e "Seguir em frente" com Nada e Nada; a porta do altar diz "Uma troca, sem luta" (`door_altar`).
  Capturas em `docs/gallery/t5/ui/`.
- **Altar Esquecido** (`Altar`, `stage.altar_layout`): porta uma vez por descida (profundidades 2 a 8, 20%), sem luta,
  uma troca ou nenhuma: 10 de vida máxima por uma romã (`Game.open_grow_choice`) ou 75 de ouro por 25 de Magia máxima.
  `Rooms.altar_options`, `take_altar(option)`, sinal `altar_used`. Robô: `Altar.bot_choice`. Pisar na laje gasta diante
  do degrau (`Rooms.ALTAR_SPOT`) abre uma tela pequena (`EventChoice.open_altar`, `BoonCard.setup_altar`, 290 x 392 a
  720): as duas trocas com medalhão de selo (`SealMedal`: romã, chama de vela; arco aberto em "Seguir em frente") e o que pedem, a que não cabe agora apagada com o porquê,
  e "Seguir em frente" (nada); sair da laje e voltar abre de novo.
- **Portas que mostram o caminho**: a luta atrás de cada porta é sorteada ao abrir a sala de antes (`Rooms._prepare`,
  `RunMap.Room.fight`, na semente do nó desde o DV-1) e entra igual; a placa diz "Difícil" para luta com elite e "Guardião" (`Rooms.door_text`);
  `Rooms.door_info(i)` dá `kind`, `reward`, `depth`, `tier`, `guardian`, `hard`, `elites`, `arena`, chaves de texto.
  Pictograma à esquerda do nome na placa (`DoorGlyph`, `DoorGlyph.of(door_info)`, `DoorSign.make(..., glyph)`; spec 7.1):
  uma divisa de ouro velho para "Difícil", duas para o guardião, três para Morvath, gota na fonte, moeda na loja, chama no
  altar, losango rachado na laje da Provação; luta comum sem nada. Testes em `tests/test_e5_ui.gd`; capturas
  `tools/ui_lab.gd -- --trial|--altar|--slab` (comando no topo), galeria `docs/gallery/e5/ui/`.
- **Registro**: `events` no `RESULT` e no registro (`RoomTally.event`: `door`, `trial_shown`, `trial_paid`,
  `trial_refused`, `trial_offered`, `trial_taken`, `trial_turned`, `altar`), mais `trial` (`active`, `left`, `won`).
  Testes: `test_hazard.gd`, `test_trial.gd`, `test_altar.gd`, `test_arenas.gd`, `test_descent.gd`, `test_e5_wiring.gd`.
