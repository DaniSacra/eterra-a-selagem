> Índice: [gameplay.md](../gameplay.md)

- Colisão do cenário: pilares são círculos (`RoomLayout.pillars`); escadas, entulho e barris são caixas sólidas
  (`Arena.boxes`, pelo `solid` de `_place`). Sai-se da sala pisando no pé da escada (`Arena.exit_at`).
  `Arena.resolve` nunca deixa ninguém dentro de pedra (ciclo C12c, GP-03): espremido onde duas peças (ou peça e borda) ficam
  mais perto que o corpo é largo, vai para o lugar livre mais perto (`Arena.overlaps`, `_free_near`, anéis de 0,1 m até 3 m);
  invocações do Ancião por `Horde.raise_spot`. Testes em `test_arenas.gd`: o centro e 400 pontos dentro das peças de cada
  arena e variante, 200 invocações do Ancião e 200 de Morvath, e "cercado" (GP-04: 2 esqueletos de cada lado nos 4
  corredores mais estreitos de cada arena e variante, 16 de 16 esquivas saem mais de 2,5 m).
- Corpos sólidos como no Hades II (`StopsUnits` na heroína e nos inimigos; pedido do Daniel, 2026-11-15: "trombar nos
  inimigos e empurrar eles" era estranho): o paladino andando, correndo, levando golpe ou no avanço de um golpe para no
  contorno do inimigo (círculo de `EnemyDef.radius`) e desliza ao longo dele, sem empurrar ninguém
  (`Horde.stop_walker`, pelo hash espacial; lógica pura em `core/body_block.gd`, `BodyBlock`); se ficar espremido sem
  saída, fica onde estava (nunca preso por arredondamento). Só a esquiva atravessa (o BLINK do Hades). Os inimigos param
  no corpo dele (`Horde.keep_off_target`, depois da separação entre eles, para a multidão não empurrá-lo), menos a
  investida em voo (estado ATTACK) e a carga de Morvath; quem terminou dentro dele (esquiva, investida, invocação) sai
  devagar, a `BodyBlock.EASE` m/s, sem salto. `EnemyDef.blocks_body = false` (no `make_data.gd`) faz um tipo
  atravessável; hoje todos bloqueiam, Morvath (raio 1,4) e os guardiões (1,0 e 1,1) também. O robô contorna corpos
  (`Bot._steer`), foge do aviso para onde há chão (`Bot._escape`) e, preso, esquiva através deles. Testes em `tests/test_body_block.gd`.
  Com menos de 60% da vida o robô vai à fonte que ainda tem luz, também entre as lutas (`Bot.drink_at`, `DRINK_BELOW`; B-2).
- Barra de vida fina sobre a cabeça de cada inimigo, como no Hades II (`CrowdRenderer.add_bar`, `life_bar.gdshader`; o chefe usa a barra do topo). Ciclo 8 (salas de 4 a 20 inimigos): todos mostram a barra (`Horde.BARS_FOR_ALL` 24; acima disso, só nos testes de estresse, só os feridos, mais finas); a armadura ganha faixa amarela própria em cima da vida (a barra cresce para baixo, `BAR_ARMOR_HEIGHT`, sem cobrir a vida), elites e guardiões têm moldura de ouro velho e barra um pouco mais larga (`BAR_ELITE_*`, continua dizendo elite depois que a armadura quebra), rastro claro do que o golpe tirou (`BarTrails`), a barra mais perto da câmera desenhada por último (`sort_bars`). O topo da barra não sobe (os números de dano começam acima dela). A barra grande do topo é só de Morvath e dos guardiões (`Game.boss_enemy`); elites comuns não a ganham (no `--horde` ganham).
- **Inimigos de longe** (teste do Daniel, 2026-11-16: "querem ficar na distância máxima atirando e não chegar perto"; números
  dos atiradores do Érebo do Hades II, estudo do mesmo dia, fontes na pasta local `estudo`): mago, besteiro e sacerdote têm o
  comportamento `ARCHER` (`Horde._behave_ranged`): andam só até o fim do alcance, fogem quando o paladino chega a menos de
  `EnemyDef.keep_away` do alcance (nosso; contornando a parede, `Horde.flee_dir`; encurralados atiram de perto) e atiram de lá
  (`Horde.shoot`, campos `shot_*`). Mago = o "Mage" do Hades: 3,5 m/s, alcance 13,1 m (elite 16,25), mira 1 s, rajada de 3
  orbes a cada 0,17 s (elite 7, `shot_ticks`) que o empurram para trás a 5 m/s (`recoil`), orbes a 7 m/s por 20 m que viram
  atrás dele (20 graus/s só no primeiro 0,8 s do voo desde o C17, nosso: o arquivo não diz), depois espera atrás da coluna mais próxima, 3,1 m além dela
  (`cover_hug`, `Horde.cover_spot`), no máximo 6 atacando. Besteiro (vida do "Screamer", que no Hades não atira): virote
  rápido (16 m/s, 12 m) por uma linha marcada no chão onde a mira trava; do Hades, foge 8,75 m por 1,5 a 1,75 s depois de
  cada tiro (`retreat_far`, `retreat_time`) e no máximo 2 atiram ao mesmo tempo (`max_attackers`, `Horde.attackers`).
  Sacerdote = a "SiegeVine": parado, alcance 22,5 m, aviso 0,8 s (clipe `cast` reassado com 0,8 s), uma trepadeira de sombra
  rasteja pelo chão atrás do paladino (1,9 m/s, vira 90 graus/s caindo 15 por s, `shot_turn_decay`, 12 s, `shot_low`,
  `Projectiles.Shot.low`/`turn_decay`), depois 3,25 s (elite: 3 a cada 0,7 s, depois 2,25 s). O sacerdote ancião (guardião)
  solta um leque de 5 orbes entre as invocações. Ficaram de fora: a lentidão de 0,2 s do orbe e a trava de passo da trepadeira.
  Círculos mágicos no chão são só de Morvath (o `CASTER` e o cone ficaram sem uso). Erupções de Morvath com 4 m de raio (eram
  2) e aviso de 1,2 s (era 0,9) para ainda dar para sair andando (`BossRules.ERUPTION_NUDGE` 0,2). Testes em
  `tests/test_ranged_enemies.gd`.
- **Atordoamento pelo golpe (E1b, GF-12, D-42: o Hades II por inimigo)**: golpe que fere um inimigo comum sem armadura o
  atordoa (`Horde.flinch`): para de andar (`stun_t`, `Enemy.helpless`), a preparação ou o ataque em curso é cortado e não
  sai (`Horde.interrupt`: volta a `WALK`, o aviso no chão do ataque some na hora por `Ground.end_zone(Enemy.warning)`, o
  som `interrupt`), e mostra o golpe sofrido (o recuo do E1a, `HitRecoil`, continua). Duração por inimigo em
  `EnemyDef.stun_time` e `stun_heavy_time` (finalizador e Ômega; desde a E1c os do golpe da heroína do Hades, `OnHitStun`
  0,5 s e `OnHitStunHeavy` 1,1 s, para todo comum: `STUN` e `STUN_HEAVY` no `_enemies` do `make_data.gd`; eram 0,3 e 0,6).
  Preparação cortada se anuncia de novo inteira, mas só `Horde.REARM` 0,5 s depois do fim do atordoamento (`Enemy.rearm`,
  a recarga segura toda preparação e o som dela); ataque já solto cortado conta a recarga. Elites só depois que a armadura
  quebra (a barra absorve antes); a quebra da armadura também corta o ataque (`Game._on_armor_broken`, o
  `ArmorBreakStun`). Investida do Escudo em voo não é cortada (`stun_immune_attacking`, a carga do Brute do Hades; a
  preparação é). Guardiões e Morvath nunca (`stun_time` 0, o `ImmuneToStun`). Queimadura e zonas não atordoam (só golpe
  com direção e clarão). `RESULT` traz `flinches` e `interrupts`. Testes em `tests/test_flinch.gd`; sonda `GF-12`.
- **Inimigos comuns no molde do Hades II (E1c; auditoria `docs/gallery/e1c/enemies/AUDIT.md`, P1 a P9; testes em
  `tests/test_enemy_motion.gd`)**: o desenho segue o corpo: velocidade real no chão suavizada em `Horde.VEL_SMOOTH` 0,1 s
  (`Enemy.vel`, sem o empurrão; `Horde._drawn_motion`); abaixo de `WALK_FROM` 0,3 m/s toca `idle` (de `WALK_START` 0,4 para
  cima volta a andar), acima o andar no ritmo dessa velocidade (`Enemy.walk_phase`, `walk_rate`); com mais de
  `FACE_SPLIT` 60 graus entre o movimento e o rosto o corpo vira para onde anda a `TURN_RATE` 1200 graus/s e só volta a
  olhar a mira (`dir`) quando anda para ela ou prepara (`Enemy.face`, `yaw()`; atordoado não gira). O sacerdote parado fica
  em `idle`. Recuperação depois do golpe (o `PostAttackDuration`): `EnemyDef.recover_time` e o estado `Enemy.State.RECOVER`
  (`Horde._end_attack`), parado, com o clipe do golpe seguindo até o fim e segurando a última pose (`Enemy.blow_t`): esqueleto
  2,1 s (elite 1,5), corredor 1,35 (elite 0,5), Escudo 1,1 (também depois da investida, onde era um atordoamento de 0,8),
  besteiro 0,6 antes de fugir, mago 0,8, Cavaleiro 0,8 (o de antes); golpe na recuperação atordoa mas não corta nada. O
  golpe do esqueleto: `attack` assado de 0,3 a 1,2 s do `Sword_Attack`, tocado do começo quando o tipo tem clipe `windup`
  próprio (`CrowdRenderer.Kind.has_windup`, `Horde.ATTACK_PLAY` 1,4): a lâmina desce nos primeiros 0,14 s do bote. Mistura
  entre clipes para todos (a do chefe, `CrowdRenderer.add_kind(..., from_row, fade)`, por `Horde._fade`): `CLIP_FADE` 0,1 s
  (o chefe `BOSS_CLIP_FADE` 0,18 desde o T5b), também na queda; o alvo da mistura é a pose interpolada do clipe novo, não a
  mais perto (T5b P1-3: alfa negativo na cor da instância, `CrowdRenderer.fade_target`/`fade_pick`, lido no
  `crowd_pose.gdshaderinc`; antes o alvo saltava de pose em pose, até 0,55 m num quadro em Morvath); atordoado por golpe, todo corpo (pesado também) mostra o golpe sofrido
  esticado no atordoamento inteiro (`Enemy.stun_len`, `Kind.hit_time`), sem `idle` no meio. Bote do esqueleto para no
  contorno do herói (`keep_off_target` vale para o `RUNNER` em `ATTACK`; investidas de Escudo e Cavaleiro atravessam);
  no máximo 2 esqueletos (com as elites) preparam ou dão o bote juntos (`max_attackers` 2). Assado: esqueleto com o pé
  travado (`SOLDIER_RUN`, 149 passos por minuto; corria a 96; desde o T5 o `Jog_Fwd`, ver abaixo), ancião `ELDER_STRIDE` 0,9 (91 por
  minuto; era 67), besteiro com a besta baixa ao lado do quadril andando e parado (`CROSSBOW_LOW`, guarda do `Sword_Idle`;
  `idle` agora o `Idle`), subindo ao ombro só na mira (`aim`, `Pistol_Idle`) e no tiro.
- **T5, o corpo prepara o golpe (especificação em `docs/design/combat_cadence.md` 6; antes e depois em
  `docs/qa/t5_enemy_motion.md`; quadros em `docs/gallery/t5/motion/after/`; testes em `tests/test_enemy_windup.gd`)**: toda
  preparação em três tempos desenhada pelo `Horde.render` (`Horde.windup_arm`): assentar `EnemyDef.windup_settle` (0,12;
  besteiro 0,25, a besta subindo ao ombro), armar com o clipe próprio em curva suave até `1 - windup_hold` (0,3) e segurar
  a pose (ou o laço `<clipe>_hold`) com o `windup_shake` só aí. Clipes próprios no assado (UAL e KayKit, `tools/bake.gd`,
  opções novas `bend_in`/`bend_out` para o tronco enrolar no preparo e desenrolar no golpe, e `plant`): esqueleto a subida
  inteira da lâmina (`Sword_Attack` 0 a 0,35 s, `SOLDIER_COIL`), corredor o agachar do `Jump_Start` e o giro
  `2H_Melee_Attack_Spinning`, feiticeiro e ancião o cajado subindo (`cast` = `Spell_Simple_Enter`, `cast_hold`, `shot` por
  orbe recomeçado a cada tiro da rajada, `exit` na recuperação), ancião `summon` ao erguer os mortos, sacerdote elite `shot`
  por trepadeira, Escudo e Cavaleiro `brace`, `charge` e `recover` (`Idle_Shield_Break`), Morvath
  `dash_windup` (`Sword_Dash_RM` 0 a 0,12 s, `CHARGE_LEAN`) e `blades_windup` (`Sword_Regular_B` 0 a 0,2 s, `DRAW_BACK`),
  armados pelo `Boss` com o mesmo `windup_arm` (`Boss.WINDUP_*`, tremor `Enemy.shake`, só desenho). **Dano do corpo**: as
  investidas do Escudo, do Cavaleiro e de Morvath ferem no primeiro quadro em que o contorno do corpo, varrido de onde
  estava, toca o herói (`BodyBlock.swept_touch`, `Ground.strike` para Morvath, uma vez por investida); a faixa no chão é
  só desenho e enche até o quadro em que o corpo chegaria (`Boss.dash_contact`). O bote do esqueleto é um salto: o corpo
  percorre a distância anunciada (até o contorno do herói), a lâmina desce `strike_at` 0,1 s depois e fere de onde o corpo
  está, no arco de `strike_degrees` 120 e alcance `Horde.blade_reach` (raio + `strike_reach` 1,1 x tamanho); o corredor
  explode `strike_at` 0,1 s no giro; os avisos da multidão ganham um quadro (`+ dt`, o chão anda depois da multidão no
  mesmo passo) e os tempos `TICK_SLACK`, então o aviso enche no quadro do golpe. Foice de Morvath fere `Boss.SCYTHE_HIT`
  0,07 s na descida (`slash3:7`). **Recuperação viva**: o resto do golpe no ritmo do clipe, ou o clipe `recover`, depois
  a guarda com mistura de `RECOVER_FADE` 0,3 s, virando para o herói no fim a `RECOVER_TURN` 360 graus/s, e pelo menos
  `AFTER_RECOVER` 0,25 s até a próxima preparação. **Esqueleto que espera** (T5-10): anel a `RING_SHARE` 0,75 do alcance
  com folga, passo lateral para o mesmo lado por `RING_SIDE` 1,2 s, no máximo `RING_SPEED` 1 m/s, com os passos laterais
  e de costas próprios (`strafe_l`, `strafe_r`, `back`, `Horde.walk_side`) olhando o herói; histerese no rosto
  (`FACE_SPLIT` 70, `FACE_BACK` 45, `FACE_SPEED`), troca andar/parado só depois de `STAND_AFTER` 0,15 s ou `WALK_AFTER`
  0,1 s, linha reta até `WAY_FAR` 3 m, separação todo quadro com `SEPARATE` 0,25; desde a revisão (7.1) a troca do rosto
  espera `FACE_AFTER` 0,1 s e só volta à mira abaixo de `FACE_SPEED_BACK` 0,9 m/s. **Corrida** (T5-11, A-T5-2): `Jog_Fwd`
  com `SOLDIER_JOG` (`lock`, passada 0,74, `plant` 0,5, `stand` 0,15: o quadril 15 cm mais alto sobre as mesmas pegadas,
  joelho menos dobrado), 161 passos por minuto, pés no ar em 6 de 20 poses, cabeça a 100% da parada.
  **Revisão de arte (A-T5-1 a 4, `docs/gallery/t5/motion/after2/`)**: a investida do Escudo e do Cavaleiro corre com as
  pernas do `Sprint` e o tronco (e o braço do escudo do Cavaleiro) presos no fim do `brace` (`BRUTE_RUSH`, `KNIGHT_RUSH`,
  "guard" com segundo fixo, `RUSH_AT` 0,33 do `Shield_Dash_RM`): escudo 0,47 m ou mais à frente do peito e tronco 13 a
  33 graus em toda pose (`BakedModel.guard_pose`, partes com nome no assado em `BakedModel.parts`: `shield`, `sword`,
  `staff`; `tools/charge_probe.gd`); corredor prepara do `Jump_Start` 0,26 a 0,4 s (sem joelho erguido); cada orbe do
  feiticeiro é o cajado recuando pela subida e voltando (`Spell_Simple_Enter` 0,53 a 0,22 s, `there_and_back`, começa e
  termina na pose de segurar). **Fuga** (T5-20): o atirador guarda a direção de fuga `FLEE_HOLD` 0,4 s enquanto ela está
  livre (`Horde._flee`), foge com folga `FLEE_SLACK` 0,75 m além de onde começa e, correndo por conta própria, o corpo
  olha a velocidade suavizada por `RUN_FACE` 0,3 s (`Enemy.run_t`), nunca a direção crua do quadro.
  Medir: `tools/clip_motion.gd` (pico, pose armada e andar de cada clipe assado, cabeça no andar) e a sonda
  `tools/enemy_motion_probe.gd` com `tools/enemy_motion_probe.py` (tremor, golpe x corpo x aviso, pose parada).
- **T5b, a luta de Morvath sem "esqueletos pulando"** (diagnóstico e números antes e depois em `docs/qa/t5b_boss_fight.md`;
  dados em `docs/gallery/t5b/boss/after/`; testes em `tests/test_t5b_fight.gd` e `tests/test_boss_body.gd`): quem pulava era o
  feiticeiro (trote `Running_B` com meio pulo); ele e o besteiro correm no `Jog_Fwd` de pés travados (`MAGE_JOG`,
  `CROSSBOW_JOG` no `tools/bake.gd`). O `rise` comum fica no lugar (`in_place`) e, com cajado ou escudo redondo, termina na
  guarda (`STAFF_RISE`, `SHIELD_RISE`, opção `"settle"` do assado: os últimos 0,45 s vão para a primeira pose do clipe da
  guarda); a saída do `RISE` mistura em `Horde.RISE_FADE` 0,25 s, o corpo vira no máximo `RISEN_TURN` 480 graus/s por
  `RISEN_TIME` 0,3 s e espera `Horde.ARRIVE` 0,6 s antes da primeira preparação. Mistura de clipe para a pose interpolada do
  clipe novo (`CrowdRenderer.fade_target`). Morvath: o corpo desenhado (`Enemy.face`, girado pelo `Boss._turn_body`) vira no
  máximo `Boss.BODY_TURN` 720 graus/s para o rumo do ataque (que continua instantâneo, avisos iguais); conjurando
  (erupções, invocação, tempestade) e na recuperação ele segue o herói (`FOLLOW_RATE` 2). Sonda do desenho:
  `tools/drawn_probe.gd` (lê o que o `CrowdRenderer` pôs nos MultiMesh), análise em `docs/gallery/t5b/boss/{data,after/data}/*.py`.
- **PT-1 (2026-11-23, Daniel jogando): só golpe de área tem mancha no chão.** `EnemyDef.ground_warning` (dado, `make_data.gd`; hoje o corredor `runner`/`runner_big`/elite, o Varredor e o Canalizador) deixa a zona desenhada; sem ele (bote e espadas do esqueleto e do guarda, investida e golpe de perto do Cavaleiro, besteiro, lanceiro, feiticeiro, Ancião) `Horde._mark` chama `Ground.mute`: a zona existe igual (tempo, dano, o que o robô lê, `Zone.silent`) mas não é desenhada nem faz o estalo de trava. No lugar, o "!" (`EnemyFx.alert`, 2 traços marfim e ouro com contorno de tinta, por cima de tudo, maior em elite e pesado, um pulso curto ao acender) aparece nos `Feel.bang_lead` 0,35 s antes do golpe (`Horde.strike_in`: a zona muda mais próxima de `warning`, `warning2` e `fan`) e some no golpe ou em `Horde.interrupt`; um som (`lock_click`) por golpe, no máximo um a cada 0,12 s (`Horde.BANG_SOUND_GAP`). Morvath, perigos de sala, círculos, erupções, runas e invocações não mudam. Testes em `tests/test_pt1_warning.gd`.
- (Antes do PT-1) Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`; o desenho fica em `GroundLook`, que os laboratórios usam sem o jogo). Ciclo 8, direção do golpe: na linha a ponta de longe é a clara, o preenchimento avança como uma divisa apontando para onde o golpe vai, com divisas fracas na parte ainda vazia; o arco ganhou borda nos lados retos. Laboratório: `tools/enemy_lab.gd ... --bars --warn=0.6`.

## C17 "Justiça e peso", frente de gameplay (backlog `docs/backlog.md` seção C17; evidências em `docs/gallery/c17/`)
- **Provação tardia (BUG-101, Q-08 a)**: a laje só aparece onde a maldição mais curta cabe nas lutas que restam antes de
  Morvath (`RunMap.fights_left`: salas até a loja menos a fonte e o altar ainda não vistos; `Trials.may_show(...,
  fights_left)`, `Trials.shortest_curse`) e nenhuma carta pede mais encontros que isso (`Trials.offers`). Teste em 500 mapas
  com o pior caminho (`test_trial.gd`).
- **Save atômico (BUG-102)**: `SaveFile` (`core/save_file.gd`): grava em `.tmp`, confere o JSON, copia o bom para `.bak` e
  renomeia; leitura cai no `.bak` e o arquivo ilegível vai para `.broken` (nunca é gravado por cima). `tests/test_save_file.gd`.
- **Loja na Câmara (BUG-103)**: artefato do `ui_lab --shop` com `--bot` (o robô já estava em Morvath quando a loja era
  remontada); o `ui_lab` recusa fora da loja; partida real sem placa de loja na câmara (`test_economy.gd`).
- **Morvath não desliza parado (BUG-104)**: sai do corpo do herói uma vez por quadro (`e.was_in_target`, a medida da
  multidão) e mostra o andar quando é movido sob um clipe parado (`Boss._drawn_walk`, `SLIDE_*`); `tools/boss_slide.py`
  sobre o `boss_probe`: 85 trechos em s1 a s5 para 0.
- **Orbe e corredor (QW-101, QW-102)**: o orbe do feiticeiro vira a 20 graus/s (era 40) e só nos primeiros
  `EnemyDef.shot_homing` 0,8 s do voo (depois reto); robô em 24 sementes: golpes do feiticeiro nas salas de 50% para 33%;
  corredor com `attack_windup` 1,0 s (era 0,7).
- **Sopro no quadro da lâmina (QW-103)**: `ComboNode.sound_at` (segundos depois do começo do golpe, divididos pela
  velocidade do combo) e `sound_press` (som no aperto): o giro toca `spin_gather` no aperto e o sopro aos 0,30 s, as
  estocadas aos 0,035 e 0,115 s (picos medidos das amostras, `SWISH_PEAK`, `THRUST_PEAK`); golpe cortado antes da lâmina
  não sopra (`Player._step_move_sound`).
- **Corpo que acende no "vai bater" (QW-104)**: no segurar do preparo (`windup_hold`) o corpo clareia morno até metade do
  clarão de um golpe, sob o `flash_cap` (`tell_hold`, `tell_light` no `crowd.gdshader`, `CrowdRenderer.TELL_LIGHT`).
  Falta a aprovação do art-director.
- **Sem metrônomo (QW-105)**: espera sorteada de 0 a `Horde.AFTER_RECOVER_JITTER` 0,5 s depois de cada recuperação;
  Cavaleiro e Escudo recuam `KNIGHT_BACK_OFF` e investem depois de `KNIGHT_SLAMS` 3 golpes de perto; voltam a andar só
  `MELEE_WALK_BAND` 0,8 m além de onde pararam (`Enemy.closing`); quem espera no anel ou recua olha o herói
  (`Enemy.facing_him`, lido no `_drawn_motion`).
- **Mira em fio (QW-107)**: a mira do besteiro e o bote do esqueleto são `Ground.add_aim_warning` (`GroundLook.aim`,
  `aim_px` no `ground.gdshaderinc`): fio de `AIM_PX` 6 px a `AIM_LIGHT` 0,5, ponta clara, a faixa enche até `AIM_FILL`
  0,22 só nos últimos 30%. Os outros avisos não mudaram. (PT-1: a mira em fio, o fio do leque e o bote deixaram de ser desenhados; a zona fica, muda, e o "!" avisa.)
- **Robô (QW-112)**: porta da fonte só abaixo de `Rooms.BOT_FOUNTAIN_BELOW` 0,8 da vida (`bot_door(..., life)`), e bebe
  abaixo do mesmo (`Bot.DRINK_BELOW`, era 0,6); régua das métricas sempre com `--ultimate=cleave`.
- **Vigia (BUG-110)**: `--watchdog` imprime `WATCH {...}` a cada `Watchdog.EVERY` 5 s reais (`frames`, `fps`, `mode`,
  `rate`, `time_scale`, `time`) e guarda as amostras no registro (`watch`). `tests/test_watchdog.gd`.
- **Instrumentação (DT-102)**: `RESULT` e registro com `windups` por tipo (`started`, `struck`, `cut`; `Horde.windup_report`),
  `shot_flight` por atirador (`hits`, `avg`, `max` do voo do tiro que acertou; `Projectiles.flight_report`),
  `omega_charges_started` (carga segurada além de `Player.CHARGE_SOUND_AT`) e `omega_charges_cancelled`.
- **Lâminas das Almas de perto (Q-09 b)**: a qualquer distância; com o herói a menos de `BossDef.blade_step_within` 4 m
  ele recua `blade_step` 2 m em `blade_step_time` 0,25 s e as faixas saem de onde ele termina. Fase 1 em 3 sementes:
  foice 91% para 62%, maior sequência igual 9 para 2 (`tools/boss_cadence.gd --cadence-log`).

## C19 "Variedade do combate e da descida", frente de gameplay (backlog `docs/backlog.md` Lote 2A; critérios em `docs/design/combat_cadence.md` 8.2; testes em `tests/test_c19.gd`)
- **Golpes por ataque como dado (Q-11)**: `EnemyDef.strikes` e `strike_gap` (`_enemies` do `make_data.gd`); um elite novo
  com dois golpes não pede código. **Esqueleto elite** (C19-1): 2 golpes a 0,2 s (o Guard elite do Hades); o fio do
  segundo nasce com a preparação (`Enemy.warning2`, `Ground.add_aim_warning`, fraco até os últimos 30%) a partir de onde
  o bote termina (`Enemy.lands_at`) e segue o herói até o fim da preparação (`Ground.point_line`); o segundo golpe vai
  para onde ele estava então (`Enemy.aim2`), `Horde.blow_at(e, k)`; atordoar depois do primeiro corta o segundo e o fio
  (`Horde.interrupt`, a morte também); recuperação 1,5 s (`recover_time`). **Corredor elite** (C19-2): explosão dupla a
  0,5 s; o segundo anel nasce no quadro da primeira explosão onde o corpo está e enche na segunda; giro em laço
  (`Horde.render`), `PULSE_AFTER` 0,3 s depois. O `windups` do `RESULT` ganhou `punished` (golpes que o tipo levou na
  recuperação, `_tally_windup(e, 3)`).
- **Ceifa Dupla de Morvath (Q-09 a, C19-3)**: ataque `reap` (`BossAttack`: fase 1 em diante, até 6 m, `near_bias` 2,2,
  `streak` 1, peso 3,5; números em `BossDef` grupo Double reap): meia-lua de 4,5 m e 150 graus, preparo 0,85 s e ativo
  0,4 (clipe `slash1`), pausa 0,35 e o segundo com preparo 0,5 e ativo 0,5 (`slash2`), recuperação 2,2 s; o aviso do
  segundo nasce no fim do ativo do primeiro (0,85 s para ler) na direção do herói; cada aviso cheio no quadro do golpe;
  pico do clipe no fim do preparo (`Boss.REAP_PEAK`, medido com `tools/clip_motion.gd`), corpo virando no `BODY_TURN`.
  Estado `Boss.State.REAP`, `_step_reap`, momentos `reap_warn`/`reap_strike`, "Derrotado por: Ceifa Dupla de Morvath"
  (`killer_reap`). `tools/boss_cadence.gd --cadence-log` imprime `CHOSE <ataque> phase=N dist=X`.
- **Ômega carregando no número do Hades (Q-12, C19-4)**: `HeroDef.charge_move_light` 0,03 (Swing5SelfSlowCharge) com o
  corpo travado (`charge_turn_light` 0, RotationMultiplier 1e-8) e `charge_move_heavy` 0,6 (inferência: o Ômega do
  especial do cajado não tem velocidade própria; WeaponStaffBoltInstantStop 0,6); `Player.charge_move_scale`. Carregando
  o do ataque ele segura a pose do golpe (nada de corrida a 0,2 m/s); a esquiva corta a carga no quadro do aperto sem
  gastar Magia; toda carga que acaba passa por `Player._end_charge`, que apaga o `charge_up` em `CHARGE_SOUND_FADE` 0,2 s
  (`Audio.fade_out(som, segundos)`, novo). Sonda: meta `C19-4` (0,066 m do aperto ao golpe, sem virar, corte em f20 sem
  Magia); 41 metas.
- **Ancião e feiticeiros mais justos (GP-1, GP-6, 2026-11-22)**: o leque do Ancião trava a mira nos últimos `Horde.FAN_LOCK` 0,35 s,
  abre 84 graus e tira 10; no máximo 3 feiticeiros preparando juntos; golpe de perto do guarda com 0,85 s de aviso.
- **Fio da mira do feiticeiro e do Ancião (Q-14 a, C19-5)**: na gramática do besteiro (`Ground.add_aim_warning`): o
  feiticeiro mostra um fio do começo da preparação ao primeiro orbe (um fio para a rajada), virando com a mira; o leque
  do Ancião um fio por orbe (5, `Horde.FAN_THREADS`; com só as bordas e o meio, sair de um fio punha o herói num orbe sem
  fio e o robô levou o dobro do Ancião), todos nascendo e enchendo juntos no quadro do tiro;
  cada fio do comprimento que o tiro voa antes da pedra (`arena.shot_reach`); `Enemy.fan`, `Horde._aim_fan`,
  `_point_fan`, `_end_fan` (golpe que corta, morte). A trepadeira do sacerdote segue a regra (b): o rito é o aviso. Os
  fios levam a etiqueta `Horde.FAN_TAG` e o robô desvia dos orbes, não dos fios (`Bot._danger`, `_threatened`: com a
  folga de 0,9 m dele as faixas de cinco fios se tocavam e ele ficava pulando de uma para outra dentro do leque).
- **Botão de usar (Q-13)**: recompensa, item da loja e porta só com a ação `interact` (E, A no controle) parado neles;
  encostar não compra nem sai (`Rooms._used`, `usable`, `use()` para clique e testes); o robô aperta quando
  `usable()`. A placa com a tecla é do ui-ux-designer.
- `tools/enemy_motion_probe.gd` lê também o `warning2` (o segundo golpe): aviso e dano a 0 ou 1 quadro.
- **Aceite medido (2026-11-20, HEAD `b903eee`)**: GUT 1282/1282 (`test_c19` 10/10, 75 asserções); sonda 41/41;
  `enemy_motion_probe` sementes 1 a 3 iguais à seção 8.1 (corredor da semente 2 na borda, Escudo +3 f conhecido) e com
  `--stress=4 --stress-ids=skeleton_elite,runner_elite`: os dois golpes de cada elite com aviso a -1 a +1 f do dano,
  segundo golpe do esqueleto a 0,99 a 1,78 m, pose parada até 0,22 s; `boss_cadence --cadence-log` sementes 1, 2, 3 e 5
  (reação 0,25, 5 Bênçãos): fase 1 perto, maior parte 43 / 43 / 50 / 43%, nunca 3 iguais, Ceifa com recuperação 2,21 s;
  24 descidas do robô (`smoke 900 --bot-reaction=0.25 --ultimate=cleave`): 20 vitórias, 24 em Morvath, `stuck` 0,
  nenhum golpe com `warn_s` abaixo de 0,97 s (Ancião 1,04), esqueleto elite 0 de dano antes e depois (o robô esquiva
  os botes). Ancião 45 para 126 de dano nas 24 (5 para 14 golpes): não é o fio (sem os fios, 126), é o Ômega a 3%
  (C19-4; com a carga a 100% volta a 45 nas mesmas 8 sementes); os golpes saem com o robô plantado em golpes comuns, aviso
  1,04 s ou mais, então fica para o balance-designer e o teste com gente. Vídeos a 1/4 da velocidade (GPU, 1280 x 720,
  semente 5) em `docs/gallery/c19/` (`skeleton_elite_*`, `runner_elite_*`, `reap_*`).
- **Depois da aprovação do C19 (combat_cadence.md 8.3)**: (a) o robô não começa o Ômega do ataque com um atirador
  (feiticeiro, besteiro, sacerdote, Ancião) preparando a menos de `Bot.SHOT_NEAR` 12 m (`Bot.shot_coming`: toca em vez
  de segurar); Ancião 126 para 81 de dano nas 24 descidas (meta 68: fica para o equilíbrio, `balance.md`). (b) O
  corredor (comum e elite) esperando a recarga encostado no herói usa a folga `Horde.MELEE_WALK_BAND` 0,8 m
  (`Enemy.closing`, como Cavaleiro e Escudo): idas e voltas por segundo 1,5 a 4,6 para 0,2 a 0,63. (c) O disco da
  primeira explosão do corredor elite é um aro fino sem preenchimento que some em `Ground.LAND_QUICK` 0,1 s
  (`Zone.land_quick`): o aro do segundo anel fica 0,4 s à vista antes da segunda explosão. BUG-108: `Game.unhook` no
  `_exit_tree` e no `Boss` derrotado solta os sinais de objetos `RefCounted` (os lambdas seguravam `Boss`, `Enemy`,
  `BossDirector`). QW-104 P2: `EnemyDef.tell_time` 0,5 s (`CrowdRenderer.tell_share`), falta o aceite do
  combat-feel-director. Q-15 medido em `docs/qa/q15_economy.md` (ouro na loja mediana 81,5, Elo 24%, Salmo 5,6%).

## Passada de VFX, Lote 1, parte do gameplay (spec `docs/art/vfx_pass_spec.md` 4, 5.3, 5.4 e 6; testes em `tests/test_vfx_lote1.gd`)
- **Luz sobre o que se pega** (o pedido do Daniel; a peça é o `RewardShaft` do technical-artist,
  `scripts/game/reward_shaft.gd`): a sala vencida não sobe mais coluna (`Rooms._room_cleared`); a recompensa ganha o facho
  (`RewardShaft.make(rooms, ponto, RewardShaft.tint_of(recompensa, família do anjo da porta))`, `appear()` espera o fim da
  câmera lenta) e pegar chama `take()`; a família vem do anjo que a porta mostrou (`Rooms._angel_family`; encontro de dois
  anjos e guardião, marfim). Loja: cada item com o facho na hora (`appear(0, true)`), força `Rooms.shop_light`
  (`RewardShaft.SHOP_CAN` 0,75 com ouro, `SHOP_CANNOT` 0,3 sem), seguida pelo setter do `Rooms.gold`; comprar levanta.
  Fonte: `RewardShaft.FOUNTAIN` 0,8 enquanto há água (`Game.spawn_fountain`, filho do nó da fonte), `take()` junto do
  `fountain_spent`. Elite surgindo sem coluna (`Rooms._spawn`, `Game._spawn_elite`); a peça no chão dela (V-15/V-18) é do
  technical-artist. Bênção e Salmo tomados sem coluna (seção 6: a marca da família no chão,
  `Fx.family_mark`; Elo um anel). Ficaram com coluna: dom que cai (`Skills`, Lote 2) e a morte de elite no `--horde`. `--no-shafts` desliga (a peça).
- **Paleta** (seção 4): `Combat.FIRE` âmbar (1,0; 0,6; 0,16), matiz 31; `Combat.LIGHT` ouro pálido (1,0; 0,92; 0,7);
  `Combat.VIGIL` sálvia (0,66; 0,78; 0,46), matiz 82, e `Combat.color_of` dá a Vigília separada da Luz. **`Boon.FAMILY_COLOR`
  mudou (para o ui-ux-designer: cartas, HUD e medalhões leem dali; conferir as telas)**: Chama e Luz como acima, Geada
  igual, Vigília sálvia (era verde 0,45 / 0,95 / 0,6, perto da Emeth), Elo ouro velho (0,78; 0,62; 0,34), o do
  `PsalmDef.color` (era violeta, o de Morvath). `Rooms.PSALM_COLOR` = esse ouro velho (era marfim-lilás); romã e coração
  saem do vermelho do perigo (`Rooms._reward_color`: matiz 352 sat 0,5 e 340 sat 0,45). Magia dos mortos (V-11, `_enemies` do
  `make_data.gd`): `DEAD_CRIMSON` (1,4; 0,16; 0,3) no corredor e no besteiro, `DEAD_MAGENTA` (1,2; 0,18; 0,64), matiz 333 no material para dar 320 a 330 na tela (P2 da revisão de arte), no
  feiticeiro, no sacerdote e no Ancião (o violeta frio do feiticeiro, do Daniel de 2026-11-14, saiu com a spec); violeta só
  de Morvath. Nenhum tempo, dano nem alcance mudou.
