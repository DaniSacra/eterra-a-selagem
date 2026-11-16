# Game Feel Review: medições técnicas (2026-11-16)

Parte técnica da Game Feel Review pedida na diretriz do Daniel (`docs/design/game_feel_directive.md`). Só medição e
diagnóstico: nada do jogo mudou. HEAD `beb6c27`, árvore principal.

## Como foi medido

- **Jogo real**: a cena `scenes/game.tscn` inteira, sem tela, a 60 quadros por segundo fixos (`--fixed-fps 60`), na sala
  da fonte (sem inimigos próprios), com um boneco de teste (esqueleto com vida alta ou baixa) posto à frente. Entradas pelo
  `Controls.VirtualPad`, como o robô; no teste do hit stop, também pelo caminho real do `Input` (o do teclado).
- **Ferramenta**: `tools/feel_probe.gd` (os cenários) e `tools/feel_probe_run.gd` (o lançador):
  `~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain`
  (`PROBE=_s_dodge,_s_buffer` roda só esses). Não entra no jogo; serve para medir de novo depois de cada ajuste.
- **Quadro 0** é o quadro em que o jogo lê o aperto. "No mesmo quadro" quer dizer que o efeito já está no estado que esse
  quadro desenha. A latência do monitor, da sincronia vertical e do áudio (padrões da Godot: vsync ligado, 15 ms de áudio)
  vem por cima e **não foi medida** (precisa de captura na placa com o aperto marcado; ver proposta K).
- **Hades II**: números lidos nos dados do jogo na cópia do Daniel (`Content/Game/Weapons/PlayerWeapons.sjson`,
  `Content/Game/Units/PlayerUnits.sjson`, `Content/Scripts/WeaponData_Staff.lua`, `CombatPresentation.lua`,
  `EnemyData*.lua`, `PlayerProjectiles.sjson`). A arma comparada é o cajado (Swing 1, 2, 3, Swing5 = Ômega, StaffDash,
  StaffBall = especial), de onde vieram os nossos números (`_combos` no `make_data.gd`). Onde o dado não fecha a regra,
  está marcado **a confirmar**. Escala: 80 unidades = 1 m; quadros a 60 por segundo.

## 1. Latência entre a ação e o primeiro quadro de efeito

| Ação | Primeiro efeito | Medido | Hades II | Onde |
|---|---|---|---|---|
| Andar | posição muda | quadro 0 (já a 6,75 m/s) | instantâneo (`Speed 540`, sem aceleração) | `Player.step`, ramo `State.MOVE` |
| Golpe 1 | clipe e investida começam | quadro 0 | carga de 0,06 s | `ComboRunner._try_start`, `Player._on_move_started` |
| Golpe 1 | dano, corte de luz, número | quadro 4 (0,067 s) | disparo em 0,06 s | `ComboRunner.step` (WINDUP), `Combat.strike` |
| Golpe 2 (encadeado) | dano | 7 quadros depois do início | 0,11 s | `cut2.windup` |
| Golpe 3 (giro) | brilho na lâmina / dano | brilho no 17, dano no 22 (0,37 s) | 0,36 s | `cut3.windup` 0,28 + `glint` 0,08 |
| Especial (seta) | dardo sai | quadro 7 (0,117 s) | carga de 0,1 s | `bolt.windup` 0,1 |
| Esquiva | deslocamento e proteção | quadro 0 (0,6 m já no 1º quadro) | 3 quadros de carga antes do salto (`ChargeTimeFrames 3`), com proteção desde o aperto | `Player._start_dodge` |
| Círculo (toque) | lentidão; círculo no chão | lentidão no quadro 0; círculo no 15 (0,25 s) | 15 quadros (`ChargeTimeFrames 15`) | `Player._read_cast`, `CAST_CHARGE` |
| Ômega do ataque (segurar) | golpe 1 no quadro 0; lança começa / acerta | 47 / 56 (0,93 s) | dispara ao encher (0,8 s, `FireOnRelease` + `ForceMaxChargeRelease`) | `lance.charge_time` 0,8 + windup 0,06 + brilho 0,08 |
| Ômega do especial | explosão sai | 47 (carga cheia no 39, espera o fim da recuperação da seta no 42) | a confirmar | `burst`, `Player._read_buttons` |
| Ômega do círculo | círculo armado | quadro 35 | a confirmar | `CAST_OMEGA_TIME` 0,6 |
| Aperto durante o hit stop (teclado) | ação | primeiro quadro que anda depois da pausa | (o Hades não congela) | `Controls._latched`, `Controls.flush` |
| Aperto durante o hit stop (controle virtual: robô, toque futuro) | ação | **perdido** | | `VirtualPad.tapped` limpo a cada quadro |

O jogo responde no mesmo quadro em quase tudo. O que atrasa é o que **some** (tabelas 3 a 5), não o que demora.

## 2. Aceleração e desaceleração do Explorador

| Medida | Medido | Hades II | Onde |
|---|---|---|---|
| Do repouso à velocidade cheia | 0 quadros (6,75 m/s no quadro 0) | sem aceleração nos dados (`Speed 540`, `Grip 1000`); anima início e parada (`MelinoeStart`, `MelinoeStop`) | `Player.step` |
| Distância de parada | 0 m, para no quadro em que solta | igual (parada é só animação) | `Player.step` |
| Corrida (segurar esquiva) | 11,13 m/s logo ao fim da esquiva; volta a 6,75 no quadro em que solta | teto 890 = 11,125 m/s (`WeaponSprint`) | `Feel.sprint_scale` |
| Virar 180 graus | direção a 90% em 7 quadros (`TURN` 18/s); o corpo desenhado mais devagar, a 95% em 11 quadros | direção instantânea (`RotationSpeed 216000`), corpo a 1340 graus/s (180 em 8 quadros) | `Player.TURN`, `Player._show` |
| Mistura de clipe parado / correndo | 0,08 s | animações próprias de início e parada | `playback_default_blend_time` |
| No quadro do aperto de um golpe | anda um passo inteiro (0,11 m) antes de plantar | parado já na carga (5% da velocidade) | ordem em `Player.step`: botões, andar, `runner.step` |

Movimento sem aceleração é fiel ao Hades II. O que o Hades tem e nós não: clipes curtos de arrancar e parar, que dão peso
sem atrasar a resposta.

## 3. Esquiva

| Medida | Medido | Hades II | Onde |
|---|---|---|---|
| Tempo até sair | quadro 0 | 3 quadros de carga | `_start_dodge` |
| Duração | 13 quadros (0,2 s pedidos; o acumulado arredonda para 13) | 0,2 s (`BlinkDuration`) | `Feel.dodge_time`, `State.DODGE` |
| Distância | 5,6 a 5,8 m (35,9 m/s caindo a 18,75) | 450 = 5,6 m, velocidade constante (`BlinkEaseIn/Out 0`) | `Feel.dodge_speed` |
| Proteção | 17 quadros a partir do aperto | 10 na carga + 16 do salto = 19 desde o aperto | `Feel.dodge_iframes`, `Player.invulnerable` |
| Recarga | 0,74 s desde o aperto (45 quadros); 1 carga | 0,74 s, 1 carga (`ClipRegenInterval`) | `Feel.dodge_recharge` |
| Corta o golpe | só depois que ele acerta (fim do WINDUP) | corta a carga do golpe (os dados bloqueiam a fila de ataque da esquiva durante a carga, `BlockDashDisable`, o que só faz sentido se ela pode sair ali); depois do disparo, só após 6, 3 e 9 quadros travados (Swing1, 2, 3) | `ComboRunner.can_cancel` |
| Atravessa corpos | sim | sim (`NoUnitCollision`) | `Player.step`, `dashing` |
| Segunda esquiva colada | o aperto no quadro em que a esquiva termina se perde; vale no seguinte | | ramo `State.DODGE` não lê botões |

## 4. Buffer de comandos

| Situação | O que fica guardado | Por quanto tempo | Hades II | Onde |
|---|---|---|---|---|
| Ataque ou especial durante um golpe | o último aperto | 0,15 s (9 quadros) contados do aperto, também durante a preparação: no golpe 1, apertos nos quadros 1 a 3 se perdem; no giro (40 quadros), só os dos 8 últimos valem | as travas de cada golpe pedem trava de gatilho (`RequestTriggerLock`): o aperto espera a trava inteira (a confirmar jogando) | `ComboTree.buffer_time`, `ComboRunner._expire_buffer` |
| Esquiva durante um golpe | nada: o aperto na preparação se perde (golpe 1: quadros 1 a 4; seta: 1 a 7; giro: 1 a 22) | 0 | a esquiva corta a carga | `Player._read_buttons` |
| Ataque durante a esquiva | nada: perdido nos 14 quadros da esquiva (0 a 13) | 0 | guardado e transformado no golpe da esquiva (`DashAttackQueue`, 23 quadros, `RequestTriggerLock`) | ramo `State.DODGE` não chama `_read_buttons`; o `ComboRunner.locked` sabe guardar, mas nunca recebe |
| Qualquer botão no hit stop (teclado) | sim, até o primeiro quadro que anda | o hit stop todo | | `Controls._latched` |
| Qualquer botão no hit stop (robô, toque) | nada | 0 | | `VirtualPad.end_frame` |
| Qualquer botão ao ser ferido (0,18 s) | nada | 0 | a confirmar | ramo `State.HURT` |
| Círculo | nada (só aceita com recarga zerada e sem círculo de pé) | 0 | | `_read_cast` |

## 5. Cancelamentos (o que corta o quê e em que quadro)

| Ação | Corta | Medido (golpe apertado no quadro 0) | Hades II | Onde |
|---|---|---|---|---|
| Esquiva no golpe 1 | recuperação | aceita do quadro 5 em diante (acerto no 4) | carga cortável; depois do disparo, travado 6 quadros | `can_cancel` |
| Esquiva no especial | recuperação | do quadro 8 (dardo sai no 7) | travado 12 quadros após o disparo, depois cortável | |
| Esquiva no giro | recuperação | do quadro 23 (acerto no 22) | travado 9 após o disparo | |
| Esquiva no mesmo quadro do ataque | o ataque inteiro | a esquiva ganha, o golpe nem começa | | `_read_buttons` (esquiva primeiro) |
| Andar no golpe 1 | o resto do golpe | anda do quadro 5 (logo após o acerto) | parado 11 quadros após o disparo (`Swing1DisableMoveHold`) | `ComboRunner.move_scale` |
| Andar no giro | o resto | anda do quadro 23 após o início do giro | parado 30 quadros | |
| Andar na seta | o resto | anda do quadro 8 | **parado 0,71 s** após o disparo (`Special1DisableMoveHold`), só a esquiva corta | |
| Golpe no especial | a recuperação não se corta | o golpe 1 só sai no quadro 42 (35 após o dardo) | ataque liberado 18 quadros após o disparo; o especial tem recarga de 0,7 s à parte | `bolt.recovery` 0,6 |
| Especial depois do especial | | quadro 42 (0,7 s) | recarga 0,7 s após o disparo | |
| Ferido | golpe, carga do Ômega | perde a sequência; volta a agir no quadro 11 | | `Player.hurt`, `HURT_TIME` 0,18 |

Andar cortando o fim do golpe na hora é decisão do Daniel (1º teste, "mais dinâmico"), não erro.

## 6. Ritmo do combo (quadros a 60 por segundo)

| Golpe | Antecipação (até o dano) | Recuperação (trava) | Janela para o seguinte | Hades II (carga / trava de ataque / trava dura / parado) |
|---|---|---|---|---|
| Golpe 1 | 4 (0,06 s) | 8 | 0,4 s | 0,06 s / 8 / 6 / 11 |
| Golpe 2 | 7 (0,11 s) | 13 | 0,4 s | 0,11 s / 13 / 3 / 19 |
| Golpe 3, giro | 22 (0,28 s + 0,08 de brilho) | 18 | 0,6 s | 0,36 s / 18 / 9 / 30 |
| Golpe da esquiva | 4 (0,06 s) | 14 | 0,4 s | 0,06 s / 14 / 5 / |
| Seta (especial) | 7 (0,1 s) | 35 (0,6 s) | 0,2 s | 0,1 s / 18 / 12 / 0,71 s |
| Ômega do ataque | 47 de carga + 9 (brilho incluído) | 36 (0,6 s) | 0,4 s | 0,8 s / 47 / 20 / |
| Ômega do especial | 39 de carga, sai no 42, dano no 47 | 0,45 s | | a confirmar |

Combo de 3 apertando sem parar: golpe 1 no 0, golpe 2 no 12, giro no 32, fim do giro no **72 (1,2 s)** no ar e no 77
sobre um alvo (5 quadros de hit stop). Pelo Hades II dá cerca de 71 quadros (soma de carga e trava de ataque). O ritmo
bate; a diferença está no hit stop (item 7) e nos apertos perdidos (itens 4 e 5).

## 7. Impacto (golpe 1 num alvo; o acerto é o quadro 4)

| Efeito | Medido | Mesmo quadro do acerto? | Hades II | Onde |
|---|---|---|---|---|
| Hit stop | congelamento total: golpe 1 25 ms (1 quadro), golpe 2 65 ms (nunca acontece no combo: cai dentro da recarga de 0,3 s), giro 70 ms (4 quadros), lança 50 ms, golpe da esquiva 25 ms; abate +40 ms (golpe 1 que mata: 3 quadros) | começa no quadro seguinte | **não é congelamento**: o mundo segue normal por 25 / 65 / 70 / 50 ms depois do acerto (`ScreenPreWait`, tempo real), cai a 6% por 10 ms (abate ou crítico: +40 ms) e volta em 20 ms; recarga 0,3 s | `ComboNode.hit_stop_ms`, `Combat._hit_slow`, `Fx.hit_stop`, `Game._process` |
| Clarão no inimigo | 0,14 s, claro e morno | sim | 0,03 s, vermelho cheio (`DoUnitHitFlash`) | `Horde.FLASH_TIME`, `crowd.gdshader` |
| Empurrão | 8, 10, 16 m/s (golpes 1, 2, 3), cai 7 por segundo; golpe 1 leva o alvo cerca de 1,1 m | sim | força 720 x 0,9, 800 x 1,0, 880 x 1,1 (cerca de 8, 10, 12 m/s) | `ComboNode.knockback`, `Horde.KNOCKBACK_DECAY` |
| Tranco de câmera | 0,32 m (comum) e 0,56 m (forte), some a 14 por segundo (cerca de 7 a 15 px a 1080 linhas) | sim | não existe; só tremor de 4 unidades (0,05 m, cerca de 3 px) por 0,08 s (giro 0,23 s) | `Fx.kick`, `KICK_METERS` |
| Tremor | 0,076 m no golpe 1, some em 6 quadros; giro 0,2 m | sim | o do tremor acima | `Fx.shake`, `SHAKE_METERS` |
| Som | só no acerto (`hit`, `hit_heavy`, `bone` ao matar); `swing` só se erra; nenhum som na preparação | sim | som do golpe no disparo, impacto por material, som de carga no Swing3 e no Ômega | `Combat.strike`, `Audio.play` |
| Vibração do controle | nenhuma | por golpe (`HitRumbleParameters`) | | |
| Corte de luz, talho, lascas, número | no acerto | sim | | `Combat._draw_swing`, `_draw_hit`, `Fx` |
| Brilho do finalizador | 0,08 s antes do giro e da lança | antes do acerto | | `ComboNode.glint` |

Tudo dispara no quadro do acerto; o hit stop começa no seguinte e congela o primeiro quadro do clarão e do empurrão.

## 8. Reação dos inimigos ao dano

| Medida | Medido | Hades II | Onde |
|---|---|---|---|
| Atordoamento por golpe | nenhum | inimigo sem armadura toca a animação de atordoamento (`StunAnimations`) e a IA sai da espera (`EndThreadWaitsOnStun`); elite com armadura é imune até ela quebrar; alguns ficam imunes só durante o próprio ataque (`WeaponSetImmuneToStun`) | `Horde.damage` |
| Recuo visual | clipe `hit` 0,3 s só se o inimigo está andando; continua andando para o paladino enquanto o clipe toca | atordoado não anda | `Enemy.hurt_t`, `Horde.render` |
| Interrupção do ataque | **nunca**: esqueleto acertado na preparação (quadro 11 de 54) atacou no tempo de sempre | provável que sim nos comuns (a confirmar jogando) | `Horde._behave` não olha `hurt_t` |
| Armadura | sem empurrão nem recuo; ao quebrar, atordoa 1,5 s | igual (`ArmorBreakStun`) | `Horde.damage`, `armor_stagger` |
| Inclinação para trás | 0,2 rad no clarão | | `Horde.RECOIL_TILT` |
| Quem para | só congelados, atordoados por efeito, no ar, presos no círculo, cegos | | `Enemy.helpless` |

## 9. Recuperação entre ações (quando cada coisa volta a valer)

| Depois de | Anda | Esquiva | Ataque | Especial |
|---|---|---|---|---|
| Golpe 1 (acerto no 4) | 5 | 5 | 12 | 12 |
| Giro (acerto no 22) | 23 | 23 | 40 | 40 |
| Seta (dardo no 7) | 8 | 8 | 42 | 42 |
| Esquiva (0 a 12) | 14 | 45 (recarga) | 14 (golpe da esquiva até o 35; golpe 1 depois) | 14 |
| Círculo solto (15) | sempre (60% durante) | sempre | sempre (Hades: 8 quadros travado) | sempre |
| Ferido | 11 | 11 | 11 | 11 |

## 10. Diferenças entre ataque, especial, círculo e Ômegas

| Ação | Forma | Alcance e tempo | Visual e peso | Hades II |
|---|---|---|---|---|
| Ataque 1, 2 | arco de 150 graus | 5,4 m; 20 e 25 de dano | fita do corte, números pálidos, tranco 0,32 m | arco 430 |
| Giro | círculo | 3 m; 60 | meia-lua gigante, brilho 0,08 s, separação de cores, hit stop 70 ms | 240 em volta |
| Seta | dardo | 30 m/s, 11 m; 40 | estrela furada com lascas de ouro; sem hit stop, tranco ou tremor no acerto do dardo | `ProjectileStaffBall`: 62,5 m/s (5000), 11 m, 40; 0,71 s parado |
| Ômega do ataque | linha para frente e para trás | 13,5 m; 160; 20 de Magia | fio largo branco, quadro de impacto, câmera fecha 8% na carga | 0,8 s, tremor ao disparar, câmera 1,08 |
| Ômega do especial | onda larga | 22 m/s, 8,25 m de largura; 80; 10 de Magia | | `ProjectileStaffBallCharged`: 9,75 m/s, explosão de 4,1 m, 80 |
| Círculo | zona que prende | 5,4 m por 3 s; Ômega explode 150 | aro fino, 0,2 s de proteção ao soltar | sem proteção (`CastInvulnerable` desligado), 8 quadros sem atacar |

A seta e o Ômega do especial não dão hit stop nem tranco (o dano vem do projétil, `Combat.on_shot_hit`): o especial é o
golpe mais "leve" na mão, apesar de ser o de maior dano por aperto.

## 11. Satisfação do abate

| Medida | Medido | Hades II | Onde |
|---|---|---|---|
| Pausa extra | +40 ms de congelamento | +40 ms de lentidão a 6% | `Combat.KILL_HOLD_MS` |
| Arremesso | 9 a 14 m/s para longe e 4 a 8 m/s para cima, gravidade 24; o corpo sobe 0,6 a 1,1 m e volta ao chão em cerca de 0,6 s | animação de morte | `Horde.THROW`, `THROW_UP` |
| Som e partículas | `bone` e lascas de osso no quadro do abate | som e efeito por inimigo | `Horde.damage` |
| Câmera lenta de 3 abates ou 7 atingidos | pedida: 0,2 de velocidade, 0,12 s, volta em 0,25 s, zoom 1,05. **Medido**: 17 quadros (0,28 s) totalmente congelados, depois 8 quadros de 0,58 a 1,0; a parte lenta quase não aparece | só último abate e chefe | `Combat.SLOW_MO_*`, `Fx.slow_mo`, `Fx.tick` |
| Último abate da sala | 0,35 de velocidade, 0,55 s, volta em 0,4, zoom 1,1, desfoque 0,85; começa depois do hit stop | 0,35, entra em 0,08 s, segura 0,6, volta em 0,4, desfoque 0,85, quadro 1,25, paladina protegida e sem entrada 0,5 s | `Rooms._room_cleared` |

## Problemas concretos

1. **Hit stop copiado errado do Hades II.** Os nossos 25, 65, 70 e 50 ms são exatamente as esperas (`ScreenPreWait`)
   antes da lentidão do cajado, usadas como duração de um congelamento que começa no quadro seguinte ao acerto. No Hades
   o golpe aterrissa, o mundo anda 25 a 70 ms (o clarão e o empurrão já aparecem), e só então quase para por 10 ms (50 com
   abate) e volta em 20 ms. O giro hoje congela 4 a 5 quadros, e com abate até 7: é o "peso grudento" no finalizador.
2. **A esquiva não corta a preparação e o aperto some.** Golpe 1: 4 quadros; seta: 7; giro: 22 (0,37 s) em que apertar a
   esquiva não faz nada e não fica guardado. O Hades deixa a esquiva cortar a carga. É a fonte mais provável de "apertei e
   não esquivou".
3. **Ataque apertado durante a esquiva some** (14 quadros). O Hades guarda e solta o golpe da esquiva. O `ComboRunner` já
   sabe guardar durante a esquiva (`locked`), mas o `Player` não lê botões no estado `DODGE`.
4. **Buffer curto e contado do aperto.** 0,15 s desde o aperto, também na preparação: no giro, só os 8 últimos de 40
   quadros guardam o próximo golpe; no golpe 1, apertos nos quadros 1 a 3 somem. Ferido (11 quadros) e no quadro em que a
   esquiva termina, nada é guardado.
5. **Câmera lenta engolida pelo hit stop.** `Fx.tick` desconta o hit stop com o tempo já desacelerado: quando os dois
   começam juntos (3 abates ou 7 atingidos), os 110 ms viram 0,28 s de tela congelada e a lentidão quase não aparece. O mesmo
   alonga qualquer hit stop durante a câmera lenta do último abate (2,9 vezes).
6. **Inimigos não reagem ao golpe.** Sem atordoamento, sem interrupção; o clipe de recuo só toca andando e o corpo continua
   vindo. Acertar um esqueleto na preparação não muda nada. No Hades os comuns sem armadura atordoam (a interrupção do
   ataque está a confirmar jogando).
7. **A seta trava o ataque 35 quadros e solta as pernas na hora**; o Hades faz o contrário (ataque em 18 quadros, parada de
   0,71 s que só a esquiva corta). Isso deixa a seta rígida no ataque e o dardo é a metade da velocidade (30 contra 62,5 m/s).
8. **Tranco de câmera de 6 a 11 vezes o tremor do Hades** em todo acerto, mais o tremor (cerca de 7 a 15 px a 1080
   linhas). Pode cansar e tirar a leitura dos avisos; decisão de câmera com o `art-director`.
9. **Controle virtual perde apertos no hit stop.** O robô (que mede as lutas) e o toque futuro perdem tudo o que for
   apertado num quadro congelado; o teclado e o controle guardam (`Controls._latched`).
10. **Ômega do ataque acerta 0,14 s depois de a carga encher** (preparação 0,06 + brilho 0,08); no Hades sai ao encher.
11. **Som só no contato.** Nenhum som de lâmina na preparação (o giro tem 0,37 s mudos), nenhuma vibração no controle; o
   Hades tem som no disparo, som de carga no Swing3 e vibração por golpe.
12. **Clarão do inimigo 4 vezes mais longo** que o do Hades (0,14 contra 0,03 s), e o hit stop congela o primeiro quadro
   dele; com o tranco e o tremor, o acerto lê mais "mole" que "seco". Decisão de arte (`art-director`).
13. Pequenos, sem razão escrita: círculo dá 0,2 s de proteção que o Hades não dá; a esquiva sai no quadro 0 (o Hades
   espera 3) e protege 17 quadros (o Hades 19); o corpo desenhado vira 180 graus em cerca de 11 quadros (o Hades 8);
   sem animação de arrancar e parar.

## Propostas (pequenas e verificáveis; nada implementado)

| Id | Proposta | Como verificar | Dono |
|---|---|---|---|
| A | Hit stop no molde do Hades: guardar por golpe a espera, a fração (6%) e o tempo de lentidão (dado no `ComboNode`, gerado pelo `make_data.gd`), contar em tempo real e entrar por `Engine.time_scale` como a câmera lenta | `feel_probe`: giro com 0 quadros parados, 1 a 3 quadros a 6%; teste GUT da agenda | gameplay |
| B | Esquiva corta a preparação (`can_cancel` também no WINDUP) e o aperto da esquiva entra no buffer por `buffer_time` | `_s_dodge_cancel` sem nenhum "LOST" | gameplay |
| C | Ler ataque e especial durante a esquiva e ao ser ferido, para o `ComboRunner` guardar (`locked`), e soltar o golpe da esquiva no fim dela | `_s_attack_in_dodge`: aperto nos quadros 1 a 13 vira golpe da esquiva no 13 | gameplay |
| D | Buffer contado do momento em que o golpe poderia sair, não do aperto (como a trava de gatilho do Hades), ou 0,3 s | `_s_buffer`: o 2º aperto vale em qualquer quadro do golpe 1 e do giro | gameplay |
| E | `Fx.tick` desconta o hit stop em tempo real (`delta / time_scale`); a câmera lenta de vários abates só começa quando o hit stop acaba | `_s_kill`: no máximo 7 quadros parados, depois a lentidão a 0,2 visível | gameplay |
| F | Reação ao golpe nos comuns sem armadura: parar de andar durante o recuo e, a decidir com o Daniel, interromper a preparação (muda dificuldade) | teste GUT: esqueleto acertado na preparação não ataca; smoke e `--bot-reaction=0.25` antes e depois | gameplay, decisão do Daniel |
| G | Seta: travar o ataque 18 quadros e as pernas 0,71 s (cortável pela esquiva), recarga própria de 0,7 s; dardo a 62,5 m/s | `_s_special`: golpe no quadro 25, especial no 48 | gameplay |
| H | Tranco de câmera na escala do Hades (0,05 a 0,1 m) ou só nos finalizadores | captura na GPU e vídeo, revisão do `art-director` | gameplay com `art-director` |
| I | `VirtualPad` guarda os toques até o jogo andar (como o `_latched` do teclado) | `_s_hitstop_buffer`: o controle virtual não perde | gameplay |
| J | Lança do Ômega acerta ao encher a carga (brilho dentro da carga) | `_s_omegas`: acerto no quadro 48 | gameplay |
| K | Medir a latência de ponta a ponta na placa (vsync ligado e desligado): aperto marcado e captura dos quadros até o primeiro pixel mudar | número em ms por ação | qa-performance |
| L | Som de lâmina no começo de cada golpe e de carga no giro; vibração por golpe no controle | ouvir no vídeo com som; teste do `Audio` | gameplay (sons provisórios) |

Ordem sugerida pelo efeito na mão: B, C, A, E, D, I (resposta e sincronia), depois G, F, H, J, L (peso e leitura).
