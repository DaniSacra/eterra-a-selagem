# Arquitetura, motor, desempenho e pendências

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Arquitetura
- `scripts/core/`: lógica pura (sem nós), toda testada. `scripts/game/`: nós da partida. `scripts/ui/`: telas.
  `scripts/render/`: modelos assados e a multidão.
- A simulação é no plano do chão: posições `Vector2(x, z)` em metros; o desenho é 3D.
- `scripts/game/game.gd` é dono do relógio: chama `step(dt)` de cada sistema. Hit stop, pausa e a escolha de dom são
  só "não chamar step". Cada sistema que emite sinal dentro do laço (golpe que mata o paladino limpa tudo) precisa
  aguentar a lista mudar no meio (ver `Ground.step`, `Projectiles.step`).
- **O fim da partida fora do `game.gd`** (DT-106): `RunReport` (`game/run_report.gd`: `result`, `line` e o `entry` do
  registro) e `RunAward` (`game/run_award.gd`: `keep` grava Maestria, Compêndio, materiais e ferramentas uma vez, `gain`,
  `award`, `codex`, `banks_materials`); o `Game` guarda delegados de uma linha (`result`, `result_line`, `run_entry`,
  `log_run`, `mastery_gain`, `award_mastery`, `codex_run`, `banks_materials`). Mesmo `RESULT` antes e depois
  (`smoke 600 --seed=5` e `--start=boss --boons=25 --seed=5`).
- **O ar do mundo tem um dono só** (DT-RS1): o `RoomMood` filho do `WorldEnvironment` (`RoomMood.own`, posto pelo
  `WorldAir.build`; `RoomMood.of(nó)` acha o do mundo daquele nó, o mais perto subindo a árvore) é o único que escreve no
  `Environment` e na lua. Camadas: o mundo (clássico e estilizado, `VisualProfile.world_values`), a sala
  (`dress_room(quem, clássico, estilizado)`, `undress_room`; `ArenaRoom._dress_air` e `BossChamber._dress_world` passam
  os dois ares por `RoomMood.air_values` e `BossChamber.air_values`) e o clima por cima (`blend`, fase 4, selagem). A
  troca de look (F7, Configurações) é vista pelo dono e recomposta com os fogos; `Arena.restyle` chama `apply`. Saíram
  `VisualProfile.dress_world`, os ares guardados estáticos do `ArenaRoom` e o `restore_air` da câmara. Teste em
  `tests/test_air_owner.gd` (todas as salas nos dois looks, F7 ida e volta, fase 4 e o salão depois da câmara iguais).
- **Multidão**: inimigos são objetos leves em `Horde`; o desenho é `CrowdRenderer` (cada tipo consultado uma vez em `register`: `Kind`, `Clip`; `add_kind` no laço; só os lotes usados são mexidos), um MultiMesh por (inimigo, animação).
  As poses vêm assadas: `tools/bake.gd` esqueleta os modelos (Meshy; os do KayKit ficaram em `KAYKIT`) e guarda cada figura (`assets/baked/*.res`,
  `BakedModel`) como uma malha só e uma **animação por vértice** (E1a, VX-04): toda pose de todo clipe vira texels em duas imagens
  (`positions` RGBA meia precisão e `normals` octaédricas RG8, linhas de `BakedModel.WIDTH` 2048; vértice v da pose p no texel
  p * vertices + v). Cada figura é desenhada **entre duas poses** (`crowd_pose.gdshaderinc`, lido pelo `crowd.gdshader` e pelo
  `crowd_outline.gdshader` por `VERTEX_ID` e `texelFetch`): a cor da instância leva pose, próxima pose e fração (`CrowdRenderer.POSED`,
  20 floats: transformação, cor, estado; o estado de `INSTANCE_CUSTOM` e a barra de vida não mudaram); `BakedModel.blend_at` e
  `pose_rate` (um clipe que não repete chega à última pose quando acaba). Poses por clipe: andar 20, parado 12, golpe sofrido 8,
  morte 16, erguer 12, ataque 14 a 16 (golpes de Morvath 14 a 20, preparos 8); a duração de cada clipe não mudou (testado contra a
  tabela de antes em `tests/test_living_crowd.gd`). Assados: 45,7 MB antes, 39,0 MB depois (teto 70). Passo do andar (VX-05): o assado
  mede a velocidade com que o chão corre sob o pé de apoio (`BakedModel.ground_speed`, pelos vértices da sola em `feet`,
  `ground_of`, `slide_per_step`) e o `Horde.walk_rate` toca o andar a velocidade / (chão x tamanho); o andar guarda a subida e descida
  do próprio clipe (uma altura só para o ciclo inteiro: a corrida voa, o pé no chão nunca é um preso no meio do passo). Para isso os
  quatro que correm trocaram o `Jog_Fwd`/`Sprint` pelo `Running_B` do KayKit (esqueleto, corredor, mago e besteiro; o `Jog_Fwd` daria
  1 passo por segundo) e o sacerdote ancião anda com o `Walk_Formal`: escorregam 1 a 4,5 cm por passo.
  E1b (A1 a A3): o escorregamento é medido em **metros do jogo** (vezes `EnemyDef.size`; teste em `test_living_crowd.gd`: menos
  de 5 cm para quem corre, 8 cm para os grandes que andam; o assado imprime "walk in the game" com passos por minuto e
  escorregamento) e o pé de apoio é **travado no chão no assado** (`"lock"` nas opções do andar, `_foot_lock` e `_place_feet` em
  `tools/bake.gd`: com cada pose do ciclo já posta, enquanto um pé está no chão o ponto onde ele pisa recua a uma velocidade
  só, a média do clipe vezes `"stride"`, e a perna se dobra até lá por IK de duas juntas, `_bend_limb`, o giro do pé mantido; no
  ar o pé vai suave de onde saiu para onde desce). O `"stride"` acerta a cadência sem mudar a velocidade da simulação: Escudo
  com o `Walking_A` do KayKit (o andar pesado do bruto) a 120 passos por minuto, Cavaleiro 96 e Morvath 102 no `Walk` da UAL
  em passada longa, mago 136 e besteiro 127 no `Jog_Fwd` com os pés no chão como o esqueleto (T5b P1-1: `MAGE_JOG`, `CROSSBOW_JOG`; o `Running_B` de antes com meio pulo deixava o feiticeiro no ar em 14 de 20 poses),
  corredor 171 no `Jog_Fwd` de pés travados em passada longa (T5b Corredor: `RUNNER_JOG`, escorrega 3,2 cm; o `Running_B` o deixava no ar em 14 de 20 poses, subindo e descendo 23 cm; a elite, 7,4 m/s, dá 259 passos por minuto) e o balanço do corredor (`EnemyDef.sway`) segue a passada, um lado por passo (`Horde.stride_lean`; antes 9 vezes por segundo, mais um passo irregular que tocava o andar de trás para frente a 2,4 vezes: era o "esqueleto que anda tremendo"),
  ancião 67; todos escorregam até 1,6 cm em jogo (antes Escudo 16, Cavaleiro 21, Morvath 15, ancião 10). O braço livre do mago
  fica junto ao corpo (`MAGE_JOG`, guarda do `Idle`; o assado imprime o quanto cada braço abre). Medir clipes sem assar:
  `tools/walk_probe.gd` (andares; `id=rig:clip:stride`) e `tools/clip_probe.gd` (altura e velocidade da mão por clipe, para
  acertar o tempo de um clipe novo no antigo). Tiras de andar: `tools/walk_strip.gd` (chão xadrez de 0,5 m, câmera seguindo;
  `docs/gallery/e1b/walk/`). VX-14: os golpes de Morvath são com as duas mãos (`"two_hands"`, `_both_hands`: a mão esquerda
  no punho abaixo da direita), a foice (`slash3`) é o golpe por cima da cabeça `Sword_Regular_C` da UAL 2 cortado para a
  lâmina estar no alto em `Boss.SCYTHE_LIFT` e descer dentro do `SCYTHE_SWEEP` (o `Sword_Attack` de antes já tinha descido no
  meio do preparo), `volley` é o arremesso `OverhandThrow` (maldição e o primeiro sopro de cada onda da tempestade,
  `Boss._step_storm`) e `roar` os braços abertos para cima com o peito aberto (`Taunt_Longer`, `ROAR_BEND`); a duração de
  todo clipe é a de antes (`BEFORE` no teste). Golpe sofrido (VX-06): o corpo desenhado recua 0,24 m
  (0,15 nos pesados) em 3 quadros e volta em 0,3 s (`HitRecoil`, `core/hit_recoil.gd`; `Enemy.recoil_t`/`recoil_dir`, só desenho).
  Modelo ou animação nova de inimigo: editar `MODELS` em `tools/bake.gd` e rodar
  `~/tools/godot/godot --headless --path . -s tools/bake.gd [-- ids]` (cerca de 4 s por figura; o Godot do editor: o atlas novo usa o xatlas). A multidão fica fora da luz das tochas (camada 2)
  e recebe a luz do paladino pelo global `hero_pos`. O `RESULT` sai em JSON (`Game.result_line`, E1a-5).
- O herói (o Guerreiro) usa o modelo do Explorador do Meshy (2026-11-15, da folha aprovada; `assets/models/meshy/hero_explorer/hero_explorer-rigged.glb`,
  24 ossos, os mesmos da antiga "Sombra", pose em A), montado por `HeroBody` (`scripts/render/hero_body.gd`, também usado na
  galeria de inimigos), desenhado com 2,75 m (`HeroBody.HEIGHT`; o combate continua com 2,5). A "Sombra" e o
  `paladin_1` saíram do repositório (DT-107, Q-19 a; o histórico do git os guarda). As animações dele são próprias
  (`hero_explorer/hero_anims.res`): `tools/bake_hero.gd` transfere clipes da Universal Animation Library 1 e 2 da Quaternius (CC0,
  `assets/models/anim/`) para o esqueleto dele pelo `Retarget` (`scripts/render/retarget.gd`) e mede o pico de cada golpe
  (`PEAK` em `make_data.gd`), o passo da corrida (`Player.RUN_CLIP_PACE`), achata o sobe e desce do quadril na corrida e a pegada da espada (pela linha dos nós dos
  dedos do manequim, lâmina saindo do lado do indicador e inclinada `GRIP_TILT` para os dedos). Parado, correndo, na corrida
  longa e no avanço ele leva a Emeth à frente do corpo, apontando para frente e um pouco para baixo, a mão à frente do quadril
  (pedido do Daniel de 2026-11-15, quadro do Ember & Blade; antes a lâmina ia para trás): o braço da espada fica na guarda
  `GUARD` (o começo do `Sword_Regular_A` da UAL 2), com o braço firme no corpo apesar do tronco, levantado `GUARD_IDLE`/`GUARD_RUN`
  e a lâmina `GUARD_DOWN` abaixo do nível (testado em `test_hero_look.gd`). Galeria: `docs/gallery/hero/` e `grip/`. Clipe novo: editar `CLIPS` em `tools/bake_hero.gd` e rodar
  `~/tools/godot/godot --headless --path . -s tools/bake_hero.gd`. Ver as poses: `tools/pose_lab.gd` (comando no topo).
  A espada é a Emeth, o modelo do Meshy (`assets/models/meshy/emeth/emeth.glb`, da imagem do Daniel de 2026-11-15: lâmina de cristal esmeralda com veios de ouro, guarda de chifres com esmeralda, punho vermelho), montada por `EmethSword` (`scripts/render/emeth_sword.gd`) com o tamanho e a pegada da anterior (topo do punho em 0,13 m, ponta em 1,5 m); só a lâmina brilha, abaixo do limiar do glow (`emeth.gdshader`, `BLADE_GLOW`), com o fio central aceso por cima (`CORE_*`). Emeth é o nome da espada, não do herói (o Daniel, 2026-11-14). Os cortes sem dom são do verde dela (`Combat.EMETH`); dons mudam a cor (fogo, gelo, ouro de Elun). Desenho escolhido pelo Daniel: memória do projeto e `build/web/herois.html`.
- Dons agem sozinhos por `SkillDef` (`scripts/game/skills.gd`: STRIKES, NOVA, ORBIT, FAN, METEOR, CONSECRATE) e/ou
  mudam golpes por `BoonMod`.
- **Combate no estilo Hades 2** (o visual segue o Ember & Blade): ataque (E), especial (D), círculo de luz (`cast`, Q)
  e esquiva (segurar = corrida, `Feel.sprint_scale`). Segurar E, D ou Q faz a versão Ômega, que gasta Magia
  (`Magick`, `ComboNode.magick_cost`, `In.CHARGE_LIGHT`/`In.CHARGE`, `HeroDef.cast_omega_cost`); Magia volta por abate
  (`Game.MAGICK_PER_KILL`). Círculo: zona `Ground.Kind.BIND` que prende (chefe só fica lento); o Ômega explode no fim
  (`Combat.cast_burst`). Armadura (`EnemyDef.armor`, barra amarela): absorve os golpes, ao quebrar atordoa
  (`Horde.armor_broken`; Morvath se rearma depois do atordoamento).
- Entrada só por ações (`Controls`): `light_attack`, `heavy_attack`, `dodge`, `cast`, mira (`Controls.aim`). Nunca ler tecla direto.
  Toque e robô usam `Controls.VirtualPad`. Toques num quadro em que o jogo não andou ficam guardados (`Controls.flush`;
  o controle virtual também, `Controls.latch_virtual`, GF-06). E1c (bug 1, "o herói solta um golpe sozinho ao começar"):
  o título não anda o jogo, então o clique em Iniciar (botão esquerdo = ataque) e o Espaço (confirmar = esquiva) ficavam
  guardados e saíam no primeiro quadro da partida; `Controls.clear_presses` esquece tudo e engole os botões ainda
  apertados até serem soltos, chamado no `Game._ready` e ao fechar a escolha de dom e a pausa (`Game._back_to_play`; o Esc
  que fechava a pausa também a reabria). Testes em `tests/test_input_leak.gd` (título por mouse, teclado e controle,
  botão segurado, dom, pausa).
- Sonda de game feel (`tools/feel_probe.gd`): 37 metas (as 30 do C12d que seguem, `GF-12` e as seis da E1c, `E1c-P1` a
  `E1c-P6`; a `GF-07d` e as `E1b-L2`/`L35` do avanço saíram).
- **Golpe parado (E1c; teste do Daniel da E1, "tem que atacar parado", e o vídeo dele do Hades II; números do cajado em
  `docs/design/hades2_feel_study.md`; estados e janelas em `docs/design/warrior_spec.md` 2.2; testes em
  `tests/test_warrior_strike.gd`)**: nenhum golpe leva o herói (sem avanço; só o Corte Veloz da esquiva anda, `lunge` 3,2 m);
  com a direção segurada ele planta do aperto até o fim da trava de pernas (`ComboNode.move_hold`, contada no `ComboRunner`
  mesmo depois da janela de emendar; `ComboRunner.planted`), que só a esquiva corta; andar nunca corta o golpe, só o clipe de
  retorno depois da trava; nenhum quadro de corrida enquanto preso. Preparação 0,08 / 0,13 / 0,36 s (giro 0,28 + 0,08 de
  brilho), próximo golpe livre 8 / 13 / 18 quadros depois do acerto (`recovery`, a cadência do combo), pernas 11 / 19 / 30;
  especial e Ômega do especial com as pernas presas 0,71 s (D-44) na pose do disparo; lança 0,78 s. Estados
  `ComboRunner.Stage` (IDLE, WINDUP, STRIKE, RECOVERY). O resto do clipe do golpe toca ao longo da trava
  (`ComboNode.follow_speed`, `Player._follow_through`) e, parado, o clipe de volta à guarda (`recover_anim`: `Slash_A_Rec`,
  `Slash_B_Rec`). O golpe gira para o inimigo mais perto até 5 m num arco de 130 graus sem mouse (`Player.ASSIST_*`).
  Empurrão dos golpes 1 e 2 em 2,5 e 3 m/s (`COMBO_PUSH`): sem avanço o alvo saía do alcance do giro. Vídeos em
  `docs/gallery/e1c/hero/` (roteiro `--feel=planted` do `tools/feel_driver.gd`).
- **Game feel I, a mão (ciclo C12d; números do Hades II, D-39, D-43, D-44; aceite pela sonda `tools/feel_probe_run.gd`,
  `docs/gallery/c12d/PROBE.md`; testes em `tests/test_feel_c12d.gd`)**: hit stop no molde do Hades, nunca congelamento
  (`HitStop`, `core/hit_stop.gd`; `Fx.blow_stop`): o mundo segue `ComboNode.hit_stop_ms` (25, 65, 70, 50 ms) depois do
  acerto, cai a `hit_slow_scale` (6%) por `hit_slow_ms` (10; +40 com abate, `Combat.KILL_HOLD_MS`) e volta em 20 ms, em
  tempo real; `Fx.tick` conta tudo em tempo real e dá `Fx.rate` (câmera lenta vezes hit stop) e `Fx.real_dt`; `Game`
  anda o mundo `real_dt * rate` e põe `Engine.time_scale = rate` (animações seguem um quadro depois). `Fx.hit_stop(ms)`
  (Morvath, dons) é lentidão imediata a 6%. A câmera lenta pedida durante um hit stop espera ele acabar (GF-05).
  Entrada: a esquiva corta qualquer golpe, a preparação também (golpe cortado não acerta, `ComboRunner.can_cancel`);
  ataque e especial apertados na esquiva ou ferido ficam no `ComboRunner` travado (`locked`) e saem no fim (o da esquiva
  vira `dash_cut`); o buffer só envelhece quando o golpe poderia sair (IDLE e WINDOW; trava de gatilho do Hades), então
  o aperto em qualquer quadro do golpe vale; esquiva apertada ferido ou na esquiva espera `Player.DODGE_BUFFER` (sem
  carga, nada). Botões lidos e o golpe começado antes de andar: ele planta no quadro do aperto. Direção na hora, corpo a
  1340 graus/s (`Player.TURN_BODY`). Esquiva no quadro do aperto (nosso, D-44) com 19 quadros de proteção
  (`Feel.dodge_iframes` 0,3). Seta: ataque livre 18 quadros depois do dardo (`recovery`), especial 0,7 s
  (`ComboNode.cooldown`, guardado pelo golpe sofrido), pernas presas 0,71 s que só a esquiva corta (`move_hold`, ver
  Golpe parado), dardo a 62,5 m/s (`Projectiles.SPARK_SPEED`). Ômega do ataque: preparação e brilho dentro da carga,
  acerta quando ela enche (`Player._charge_lead`); apertar de novo recomeça a carga. Círculo sem proteção e 8 quadros
  sem golpe (`ComboRunner.hold_for`, `HeroDef.cast_attack_lock`). Impacto: tranco do golpe comum 0,09 m, finalizador
  0,32, Ômega 0,56 (`Combat.KICK_*`, `kick_of`); clarão do inimigo 0,05 s (`Horde.FLASH_TIME`). Som da lâmina no
  começo de cada golpe (`ComboNode.sound`: `blade`, `blade_spin`, `thrust`, `dart`; nada mais de `swing` só no erro) e
  `charge_up` segurando o Ômega; vibração por golpe e ao ser ferido (`Fx.buzz`, `Combat.RUMBLE_*`), só com controle
  em uso e a opção `rumble` do save ligada (`Fx.rumble`, `Game.apply_options`).
- **CF-09 e CF-10 (sensação)**: nenhum clipe de golpe do herói passa de `HERO_CLIP_MAX` 1,5x na preparação (o clipe
  começa mais perto do pico, `anim_from` no `_move` do `make_data.gd`; golpe 1 de 2,75x e corte da esquiva e lança de
  3,67x para 1,5x; o pico continua no fim da preparação, sonda 41/41 com E1c-P4 a P6 iguais). Segunda camada de som no
  quadro do golpe (`ComboNode.layers`, tocada pelo `Player._body_layer` no `move_hit`, sorteada num dado próprio sem
  repetir a anterior): golpe 2 o giro do corpo (`dodge`), o giro `dash_land` ou `dodge`, a lança o passo plantado
  (`dash_land`). Luta de Morvath gravada: -1,42 dBTP depois do limitador (antes -1,44).
- O jogo abre em tela cheia (padrão desde 2026-11-16, `SaveData.VERSION` 2 passa os saves antigos para tela cheia uma vez; capturas, vídeos e `--nosave` ficam em janela, `App.apply_options`); a pausa tem "Sair do jogo" no desktop (`pause_exit_game`).
- Save em três espaços, `user://save_1.json` a `save_3.json` (ver "Escolha de save" na Tela de título), pela camada única `Save` (regras puras em `core/save_data.gd`, versão 3 com heróis e Compêndio; versão 5 passa uma vez as músicas que estavam no padrão antigo para o padrão novo do MUS-1). Sem save (`--nosave`) não há recorde
  (`SaveData.record_win_time`). Os testes nunca gravam o save nem o registro (`tests/hooks/pre_run.gd`, `pre_run_script` no
  `.gutconfig.json`; `tools/title_flow_check.gd` também desliga). O mesmo gancho põe `--seed=1` (BUG-109): todo jogo
  aberto num teste joga o mesmo dado, e a suíte dá a mesma contagem de asserções em toda rodada. Teste que troca a
  semente devolve `Dev.put("seed", "1")` no `after_each`, nunca a apaga (12 arquivos apagavam e deixavam o resto da
  suíte em dado sorteado; `tests/test_zz_seed_kept.gd`, o último, confere); `RandomNumberGenerator` de teste com semente.
- Registro das partidas de gente (ciclo 10, QW-001): `user://runs.jsonl`, uma linha JSON por partida (vitória, morte ou saída,
  `Game.log_run`, uma vez só; sair no meio grava `quit` no `_exit_tree`) com o dicionário do `RESULT`, os dons na ordem
  (`gifts`: id, nível, raridade), o controle (`device`: keyboard, gamepad, both; `Controls.seen_keys`/`seen_pad`), `omegas`,
  `dodges`, o que feriu por último (`last_hurt`) e, na morte, `defeated_by` (chave de texto). Nada sai do computador; o robô e
  `--nosave` não gravam. Formato em `core/run_log.gd` (`RunLog`), sinal `Game.run_logged(outcome, entry)`.
  Ciclo C12c (GP-02, `RunLog.VERSION` 2, para separar injusto de não reagiu): `source` (`human` ou `bot`), `boons_at_boss`,
  `shop` (`gold` ao entrar, `bought`, `spent`), `fountain_used` e `hurt_ctx` (até 60 golpes levados: `by`, `t`, `room`, `dmg`,
  `warn_s` = segundos de aviso antes do golpe, -1 sem aviso conhecido; `dash_ready`; `offscreen` = quem bateu fora dos 5 a
  95% da tela ao bater ou atirar). Por sala (`RoomTally`): `variant`, `gold_in`, `boons_in`, `dodges`, `hits`, `hits_by`,
  `shots` por atirador (`fired`, `hit`, `blocked`; Morvath é `morvath`) e `blocked_by` (peça que barrou). O aviso vem de quem
  bate: `Horde.last_warn` (golpe erguido), `Ground.last_warn` (tempo do aviso no chão), `Projectiles.last_warn` (mira do
  atirador, `Shot.warned`, mais o voo); a meia-lua de Morvath soma a faixa que ele marcou antes (`Ground.warned_for`).
  Tela: `Horde.on_screen`/`screen_flag`, `Shot.offscreen`, `Zone.offscreen` (os avisos do próprio Morvath leem onde ele está).
  `--runlog=arquivo` grava também a partida do robô, com `source: bot`.
- "Derrotado por" (ciclo 10, QW-003, lógica): todo aviso e tiro de inimigo leva o tipo de quem o fez (`Ground.Zone.by`,
  `Projectiles.Shot.by`, preenchidos por `Horde.acting` durante o passo da multidão; o golpe direto por `Horde.last_by`);
  `Game.last_hurt` guarda `{attack, enemy}` do último golpe que tirou vida e `Game.defeated_by()` devolve a chave de texto
  (`DefeatCause`, `core/defeat_cause.gd`): `killer_<ataque>` para os ataques de Morvath (Foice Sepulcral, Lâminas das Almas,
  Tempestade das Seis Almas, Erupções Sepulcrais, Erupções do Ritual, Maldição de Morvath, Investida de Morvath), senão o
  `name_key` do inimigo, senão `killer_unknown`; rótulo `defeated_by` ("Derrotado por: {name}"). A tela é do ui-ux-designer.
- Som: `scripts/audio.gd` (nomes e receitas de reserva). Um arquivo `audio/<nome>.ogg` substitui a receita;
  `audio/<nome>_0.ogg`, `_1.ogg`... sorteia entre eles. Licenças e créditos em `audio/LICENSES.md` (D-12b: síntese, CC0 e
  CC-BY com crédito); fora do jogo, em `CREDITOS.txt` ao lado do exe (a tela de Créditos saiu em 2026-11-18).
  **T5 (relatos do PO "música da partida igual à do título" e "efeitos de fliperama"; `docs/design/t5_audio.md`)**: todo
  nome de som tem arquivo gravado, montado por `tools/make_sfx.sh <pasta dos pacotes>` (fonte da verdade: uma linha por
  arquivo com as camadas já mixadas, movimento da arma, contato, impacto e magia, tom, filtro e pico) a partir de CC0
  (Kenney Impact Sounds e RPG Audio, qubodup, rubberduck) e CC BY 3.0 (Little Robot Sound Factory, nos créditos); golpe 2
  `blade_heavy` e Ômega do especial `wave_omega` próprios (`ComboNode.sound` no `make_data.gd`, família da lâmina no
  `VoiceGate`). Música do título, das salas e de Morvath gravada: Kevin MacLeod, CC BY 4.0 ("Tempting Secrets" no
  título, `Music.play(&"title")` no `boot.gd`, abertura uma vez e laço de `loop_from` 16 s; "Oppressive Gloom" caminhada
  e "The Descent" luta; "Clash Defiant" em 4 seções, uma por fase), laços de compassos inteiros por
  `tools/make_music_loops.sh <pasta dos mp3>`; faixas `solo` (`MusicMix.Deck.solo`: o nível n ouve só a camada n, as
  outras seguem mudas no tempo, troca em crossfade sem reiniciar). Os Salmos e a vitória seguem sintetizados.
  **Músicas para escolher (T5, o PO não gostou da música nova da fase e gostava da antiga)**: as antigas voltaram com
  nome próprio (`audio/music/classic_catacombs_1/2.ogg`, `classic_morvath_1..4.ogg`, do `5dfe97f`) e foram o padrão até o
  MUS-1; as do MacLeod continuam no pacote para escolher.
  **MUS-1, música de luta (o PO, 2026-11-18: "músicas mais animadas, dinâmicas", as de antes "um pouco depressivas")**:
  quatro peças novas compostas e sintetizadas pelo projeto (`tools/make_music.gd`, `-- blade_march deep_drums iron_pulse
  morvath_battle`), cada uma com riff, melodia com contraponto, progressões que sobem e cadência para o maior no pico:
  "Marcha das Lâminas" (`blade_march`, orquestral e épica, ré menor a ré maior, 144 BPM, 40 compassos, 66,7 s),
  "Tambores do Fundo" (`deep_drums`, folk e tribal, rabeca e flauta, mi dórico a mi maior, 150 BPM, 64 s), "Pulso de
  Ferro" (`iron_pulse`, baixo em semicolcheias, lá menor harmônico a lá maior, 138 BPM, 36 compassos, 62,6 s), as três em
  caminhada e luta somadas; "Morvath, a Batalha" (`morvath_battle`, dó menor harmônico a dó maior, 150 BPM, 64 s, uma
  camada por fase: cordas e tambor, coro do ritual, trêmulo e caixa da maldição, metais do herói). **Padrão**: Marcha das
  Lâminas no título (a caminhada) e nas salas, Morvath, a Batalha em Morvath (`MusicCatalog.DEFAULT`); as antigas e as do
  MacLeod ficam na lista. Niveladas por loudness, não por pico (`_publish_levelled`: ganho por camada até a meta da soma,
  `ROOMS_LUFS` -21,8 / -20,0, `MORVATH_LUFS` -22,6 a -19,4, limitador com antecipação só acima de `ROOMS_CEILING` -2 e
  `MORVATH_CEILING` -5,2 dBFS); bateria nova no script (`_kick`, `_snare`, `_tom`, `_hat`, `_clap`, `_crash`, `_fill`,
  padrões de 16 passos em `_hits`), baixo, spiccato, metais em `_stab`, linhas por `_line` e contracanto por `_counter`.
  Medido: caminhada -21,9 a -22,0 LUFS, com a luta -20,0 a -20,1, pico -3,3 a -4,5 dBTP; luta gravada do robô (salas,
  `--sound-log` e `tools/mix_probe.gd --music-dungeon=id`) -16,8 a -16,9 LUFS, Morvath -16,2. Para caber no teto o
  MacLeod foi reencodado em qualidade Vorbis 0 (Q-20 a) e as originais, os Salmos e a vitória saem do .wav em qualidade 1 (`QUALITY` no script;
  as novas em 2). Gravações para ouvir em `docs/gallery/mus1/`. Catálogo como dado em `MusicCatalog` (`core/music_catalog.gd`, `PIECES`: id, nome `music_<id>` no
  `text_pt.tres`, arquivo, camadas, `solo` ou somadas, laço, `places`: `title`, `catacombs` = masmorra, que pede
  caminhada e luta, `morvath` = 4 fases; peça de masmorra serve no título e toca só a caminhada; vitória e Salmos só para
  ouvir). Escolha por lugar no save (`music_title`, `music_dungeon`, `music_morvath`; inválida ou ausente cai no
  `MusicCatalog.DEFAULT`, `MusicCatalog.resolve`). Os decks do `MusicMix` são as peças; `Music.play(&"title"|&"catacombs"|
  &"morvath")` e `Music.boss_phase` tocam a peça escolhida (`Music.piece_for`; o registro de som guarda o lugar e o
  `tools/mix_replay.gd` resolve igual), a vitória passa à caminhada da masmorra escolhida (`Music.choose` religa).
  Tela **Músicas** (`MusicRoomScreen`, botão "Músicas" nas Configurações, `--title --screen=music`): à esquerda
  "Título", "Masmorra", "Morvath" com "< peça >" (grava na hora), à direita todas as peças com Ouvir/Parar
  (`Music.listen`, `heard`, `quiet`; tema de Salmo sozinho, vitória sem passar à caminhada) e, nas de camadas, Caminhada
  ou Luta, Fase 1 a 4 ou "Todas as fases" (20 s cada, `MusicRoomScreen.TOUR`); ao sair, `Music.resume()` volta à música
  do jogo onde estava, já com a escolha nova. Loudness igual: as antigas medem -21,7 / -20,1 LUFS (caminhada / com a
  luta) contra -21,1 / -20,1 das novas, Morvath na fase 4 -19,3 contra -19,0 (a fase 1 da original é mais baixa de
  propósito); a luta gravada (`test_mix.gd`) com cada uma: -16,6 e -16,3 LUFS, -1,4 dBTP (com "Morvath, a Batalha"
  -16,4). Teto da música no pacote 18 MB (desde o MUS-1: 16,69 MB de .ogg, 17,73 MB importados no pacote;
  `test_music.gd` confere os .ogg abaixo de 18 MiB). A tela
  Músicas tem linhas de 30 px (`MusicRoomScreen.ROW`, `_compact`) para as 14 peças caberem em 720. Testes em `tests/test_music_room.gd`; fluxo Configurações, Músicas, voltar no `tools/title_flow_check.gd`;
  capturas `docs/gallery/t5/ui/music_room_*.jpg`.
  **Música (E4-06, C15-03)**: composta nota por nota e sintetizada pelo projeto em `tools/make_music.gd` (licença nossa;
  tabelas de onda, coro por formantes, corda Karplus-Strong, sinos, tambores, Freeverb; ré menor, a luz de Elun em maior),
  rodar `~/tools/godot/godot --headless --path . -s tools/make_music.gd [-- psalms victory]` (`catacombs` e `morvath` só se pedidos pelo nome, gravando `classic_catacombs_*` e `classic_morvath_*`) (cerca de
  3 min, precisa do ffmpeg com libvorbis; .wav de trabalho em `~/tools/e4/music`, só os .ogg em `audio/music/`; as
  peças do MUS-1 também só pelo nome, cerca de 1,5 a 3 min cada, dá para rodar em paralelo).
  Faixas: `classic_catacombs` (96 s, 80 BPM, laço sem emenda: a reverberação do fim aquece o começo) em 2 camadas, caminhada e luta;
  `classic_morvath` (64 s, 120 BPM) em 4 camadas, uma por fase; temas dos Salmos `psalm_sentinel`, `psalm_shelter`,
  `psalm_shepherd`, `psalm_rock` (16 s); `victory` (12,6 s, bVI, bVII, I). Tocador: autoload `Music`
  (`scripts/music.gd`, regras puras em `MusicMix`, `core/music_mix.gd`): cada faixa é um deck com as camadas começando
  juntas; `Music.play(id, nível)` (o nível liga as primeiras camadas; a mesma faixa só troca o nível), troca de faixa em
  crossfade (entra 1,5 s, sai 2,5 s), camada entra ou sai em 2 s, `Music.boss_phase(n)`, `Music.sting(id)` (aceita
  `sentinel` ou `psalm_sentinel`; a música de fundo abaixa para `MusicMix.DUCK` 0,45 por baixo), a vitória passa para a
  caminhada 2 s antes de acabar (`HANDOVER`); fades em tempo real (câmera lenta não mexe). Ligado: título e salas
  (`Rooms._enter`: luta e guardião nível 2, fonte e loja 1; sala vencida volta a 1), Morvath (`Game._start_boss`,
  `Boss.phase_changed`), vitória (`Boss`, no golpe final), morte (volta à caminhada). Barramento `Music` vai ao `Master`
  antes do limitador; volume da opção `music` do save (0,7) e `Music.MUSIC_DB` -3 por baixo. Mixagem medida: os 4 de
  Morvath juntos ficam muito abaixo de -1 dBTP sozinhos e pelo menos 6 dB abaixo de um golpe (`tests/test_music.gd`,
  também nenhum silêncio de 2 s nas faixas nem numa descida inteira no relógio do `MusicMix`); a mistura inteira (Morvath na
  fase 4 com os golpes mais fortes juntos a cada 0,25 s) antes e depois de um modelo do limitador: `tools/mix_probe.gd` (medido: música sozinha -29 dBFS RMS e -13 dBTP;
  com os golpes, +4,2 dBTP antes do limitador e -1,4 dBTP depois). A outra frente (Salmos) só chama `Music.sting`.
  **Mixagem por barramentos (E6, C15-01, B-3; números em `docs/qa/e6_audio_perf.md`)**: `Music`, `SFX`, `UI` e `Ambience`
  vão ao `Master` (limitador por último); `Audio.BUSES` dá a opção de volume e o ajuste de cada um (Music +9, SFX +2,
  UI -6; UI e Ambience seguem a opção `sfx`), `Audio.GAIN_DB` baixa os sons que empilhavam no limitador (golpe, osso,
  escudo, queda de elite, rugido...), `Audio.UI_SOUNDS` vão ao `UI`. Ducking: os avisos de Morvath (`Audio.WARN_CUES`:
  foice erguida, investida, erupção, maldição, rugido, invocação) chamam `Music.warn(s)` e a música e o ar descem a
  `MusicMix.WARN_DUCK` 0,5 (-6 dB) em 0,06 s, seguram e voltam em 0,5 s. Medida de verdade: `--sound-log=arquivo` grava
  todo som, música e ar de uma partida no relógio do jogo (`Audio.log_event`) e `tools/mix_probe.gd -- --log=arquivo
  [--before] [--why] [--parts=music,air,sfx] [--wav=x]` refaz a mistura pelos barramentos (`tools/mix_replay.gd`) (as amostras, o tom e o volume de cada `AudioStreamRandomizer` num dado próprio, `dice_seed` 1: o `test_mix` dava outro resultado conforme os testes de antes mexiam no aleatório global) e mede
  LUFS integrado (BS.1770, `Loudness`, `core/loudness.gd`, conferido com o `ebur128` do ffmpeg), pico real e as janelas de
  0,1 s em que o limitador trabalha: descida -17,7 LUFS, Morvath -17,3, -1,4 dBTP depois do limitador, limitador em 0,3 a
  0,5% das janelas (antes da E6: -19,5 a -20 LUFS e até 3 janelas fundas). **Ambiência por arena (C15-04)**: um laço
  de 24 s por arena sintetizado em `tools/make_ambience.gd` (`audio/ambience/amb_*.ogg`), tabela `Ambience.BY_ARENA`
  (`core/ambience.gd`; arena nova com ar que já existe é uma linha), tocada por `Music.ambience(id)` no `Rooms._enter` com o
  crossfade do `MusicMix` (`Music.air`), `Ambience.AMBIENCE_DB` -6, cerca de 10 LU abaixo da música; sair da partida
  (`Rooms._exit_tree`) apaga. Testes em `tests/test_mix.gd` (medidor, barramentos, ducking, laços sem emenda, crossfade e a
  luta de Morvath gravada em `tests/fixtures/sound_log_boss.json` dentro das metas).
  Limitador `AudioEffectHardLimiter` no fim do barramento `Master` com teto de -1,5 dB nas amostras (E4: assim o pico real entre elas fica abaixo de -1 dBTP)
  (`Audio.LIMIT_DB`, `Audio.limit_master`, posto uma vez ao iniciar; ciclo C12c, GP-05). E1c (bug 2, "E apertado sem
  parar parece pacman"): o sopro da lâmina (`blade`, `blade_spin`, `thrust`, `dart`, `ComboNode.sound`, só quando o golpe
  sai de verdade) é gravado, sorteado entre 3 a 5 amostras CC0 do qubodup por família (`audio/blade_*.ogg`...), tom
  variando 12%, e passa por `VoiceGate` (`core/voice_gate.gd`): a família não recomeça antes de 70 ms e soa no máximo em
  2 vozes (a nova toma a mais velha). O impacto segue separado (`hit`/`hit_heavy` e o material, só com acerto).
  `Audio.listen` grava o que passou para os testes (`tests/test_voice_gate.gd`).
  Som do combate (E1b, C15-02): a tabela é `CombatSounds` (`core/combat_sounds.gd`): `EVENTS` (golpe e golpe forte, dardo,
  escudo do ritual `ward`, ataque cortado `interrupt`, quebra de armadura `armor_break`, atordoamento, Ômega carregando e
  pronto, círculo, círculo Ômega e a explosão dele, esquiva, golpe sofrido, maldição, invocação); por cima do golpe, a
  camada do material mais alto atingido (`EnemyDef.material`: `bone`, `shield` o Escudo, `armor` o Cavaleiro, `spectral`
  Morvath; golpe na barra de armadura soa `armor`; `CombatSounds.material_of`, `loudest`); a queda por material
  (`kill`); o começo de cada preparação de inimigo pelo `EnemyDef.tell` (um som curto por papel: lâmina, brasas, orbe,
  besta, escudo, ritual; `Horde._set_state`), o golpe solto (`strike`) e o tiro (`shot`: virote, orbe, trepadeira). Um
  inimigo novo com `tell`, comportamento e `material` que já existem soa sem código. 16 vozes (`Audio.VOICES`).
  Teste: `tests/test_combat_sounds.gd` (todo evento, material, inimigo e golpe do herói com receita; nenhuma receita
  passa de 0,95 sozinha; limitador a -1,5 dB). Projéteis barrados pela pedra ainda sem som (`projectiles.gd`).
  Runas Instáveis (parecer de cadência 7, P1): um som por padrão ao armar (`rune_arm`: pedra raspando e um sopro morno
  que cresce) e um estalo de pedra no quadro do golpe (`rune_fire` toca `rune_crack`), nunca um por ladrilho
  (`RuneFloor.step`, eventos `ARMED` e `FIRED` do `ArenaHazard`); abaixo dos avisos de Morvath (fora de
  `Audio.WARN_CUES`, sem ducking). Gravados de CC0 do rubberduck (`tools/make_sfx.sh`, `audio/LICENSES.md`); teste em
  `tests/test_rune_sounds.gd`.

## A8, depois do QA (gameplay)
- **Sala nova na tela preta (QA P1-1, DT-RS3)**: o escurecimento chega ao preto, um quadro preto é mostrado
  (`Rooms._go`, também na laje da Provação), a sala é montada (`_enter`) e fica preta por `Rooms.HOLD_FRAMES` 2 quadros
  desenhados (`RenderingServer.frame_post_draw`) com o mundo parado (`Rooms.holding()`, lido no `Game._process`): o
  primeiro desenho compila os shaders da sala (segundos na iGPU) atrás do preto; só então o clareamento de 0,35 s, em
  tempo real. Sem tela (smoke, testes) nada espera: o mesmo `RESULT` (`smoke 600 --seed=5` `boss_at` 268,0).
  `--hold-frames=N` força. O aquecimento dos shaders é do technical-artist (pode usar o `holding()`).
  Teste `tests/test_room_hold.gd`.
- **Controle nos menus e no hub (QA A8)**: `tests/test_pad_menus.gd` (A e B nas ações de menu), `tests/test_hub_f7.gd`
  (o hub pelo F7 ida e volta, P2-4), `tools/title_pad_check.gd` (A em Iniciar chega ao hub) e `tools/hub_pad_check.gd`
  (analógico, A em cada estação, B, Start, o Portal), os dois saem com o número de falhas; `tools/frame_spikes.gd`
  (quadros acima de 50 ms por sala, pelo `tools/gpu.sh run`).
- **Cor do golpe pela Bênção** (`BoonState.family_on(tags)`): a Bênção que só dá dano a um golpe (Golpe Radiante,
  Golpe Firme, Final Radiante) pinta o corte, o número e o brilho na cor da família (`Combat.color_of`; a da ação antes
  da que age sozinha; Elo fica de fora). Teste `tests/test_blow_family.gd`.
- **Entrada de Morvath (ART-05.5)**: na Câmara do Selo ele sobe do selo em `Boss.RISE_TIME` 1,5 s (só o desenho:
  `Enemy.y` de `RISE_SINK` 2,4 x tamanho abaixo do chão, saindo devagar, `Boss.rise_depth`; almas a cada 0,3 s), então
  um segundo anel violeta, tremor, `roar` e o clipe do rugido até `ENTER_TIME` 2,4 s, quando a luta começa como antes
  (momento e `cue` `risen`). Mesmo `RESULT` do `--start=boss --boons=25 --seed=5`. Falta a aprovação do
  combat-feel-director. Teste `tests/test_boss_entrance.gd`.

## C20 técnico e DT-111 (gameplay)
- **Pausa sozinha (GP P2-3)**: a janela perde o foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` no `Game._notification`) ou
  o controle em uso é desligado (`Input.joy_connection_changed`, só com `Controls.using_pad`): `Game.auto_pause` abre a
  pausa, só em PLAY sem tela aberta e nunca para o robô, `--smoke`, `--shot`, `--frames` nem `--no-auto-pause`
  (`AutoPause`, `core/auto_pause.gd`). No hub não (nada a perder). Teste `tests/test_auto_pause.gd`; o
  `tools/title_flow_check.gd` já faz o fluxo só de controle.
- **DT-111, passo da simulação**: o `Game._process` anda o mundo num passo só por quadro, com teto de 0,05 s
  (`_timed_step(minf(world_dt, 0.05))`): abaixo de 20 qps o mundo corre em câmera lenta em vez de dar saltos (nada
  atravessa parede, avisos não pulam quadros), e o relógio da partida segue o mundo. Não subdividido: a iGPU mais fraca
  medida (Intel RaptorLake, Baixa a 1280 x 720) fica de 56 a 81 qps nas salas, e o pior caso de CPU é o
  `--stress=300` (13 ms por passo no Windows), que a partida por salas nunca alcança (teto de 20 de pé). Subdividir
  (dois passos de até 0,05 s) só se uma máquina alvo ficar abaixo de 20 qps na partida real; os engasgos de entrada de
  sala caem na tela preta (`Rooms.holding`).

## Pendências conhecidas
- **Fase por salas** (padrão desde a E3): o robô com reação 0,25 desce as 10 salas em 4 a 4 min 40 s e chega em Morvath
  com 5 a 7 Bênçãos em 7 de 8 sementes, compra na loja em 7 de 8 e vence 5 de 8 (`docs/qa/e3_metrics.md`).
  `tools/smoke.sh 300` não chega mais em Morvath: usar 600 (ou `--medium`). Falta teste com gente. O modo de horda (`--horde`) ficou como estava, com os números novos.
- Morvath (4 fases, 2026-11-15; ciclo 9): o robô sem tempo de reação vence sempre e quase não apanha; com reação humana
  (`--bot-reaction=0.25`) vence cerca de metade das lutas com 5 dons, perde mais na fase 4 (a tempestade e a maldição
  somam mais da metade do dano). A luta dura de 1 min 40 s a 2 min para o robô (abaixo da meta de 2 a 4 min; gente bate
  menos, medir antes de mexer na vida). A dificuldade para gente ainda não foi medida. A foice é a lâmina do modelo aprovado (ele não
  tem foice); meias-luas sem as caveiras da referência; maldição lida pelo brilho roxo e fumaça no herói. Diferenças do Hades
  que ficaram: Morvath tem ataques próprios (não os da chefe do Hades), só a vida (6050) e o dano seguem a escala; sem martelo, feitiço lunar ou dom de velocidade como recompensa; a loja, a recompensa e a porta pedem o botão de usar desde o C19 (`interact`; antes a loja comprava ao pisar e não havia botão de
  interagir); a seta especial não persegue (o bônus de sequência de golpes saiu na E3, D-10).
  Depois do 1º teste do Daniel (mais dinâmico, 2026-11-14; o avanço e o "andar corta o golpe" desta época saíram na E1c,
  ver Golpe parado): o corte de luz segue o lado do braço
  (`ComboNode.sweep`, `SWEEP` em `make_data.gd`), golpes
  empurram mais, inimigos mais rápidos (esqueleto 3,75 m/s) e com menos espera entre ataques (avisos iguais); a câmera
  se adianta para onde ele anda, não para a mira.
- Cenário do KayKit, fontes e áudio sintetizado são provisórios. Assados somam 45,3 MB com os dois do hub (os nove inimigos 43,75; 16 bits, `ARRAY_FLAG_COMPRESS_ATTRIBUTES`, textura S3TC de 1024 dentro de cada um), todos reassados juntos em 2026-11-19 (Lote 2C; Morvath estava dois commits do `bake.gd` atrás). Cada `.res` guarda o `bake_stamp` da sua entrada no `tools/bake.gd` (`stamp()`, `PIPELINE`: subir quando uma mudança do código muda todo assado) e `tests/test_asset_budget.gd` (DT-104) falha com assado atrasado, assados acima de 70 MB, música do pacote acima de 18 MB ou figura acima de 5 600 triângulos (os de cajado têm 5 530 e 5 557; o `"lod"` de um `held` existe, mas tira a cabeça do cajado e a borda do escudo e mexe nas medidas do `test_enemy_windup.gd`, então ficou de fora). Fora do pacote (`exclude_filter` dos três presets): os `enemy_*` de origem, os bonecos do KayKit (`assets/models/characters`), a UAL (`assets/models/anim`), as armas (`assets/models/weapons`), as paletas e o `lion.svg` (fonte do `lion_sdf.res`); ficam no repositório para o `tools/bake.gd`, o `tools/bake_hero.gd` e o `tools/make_seal_lion.gd`. Sem `include_filter` (o `*.json` levava o `.gutconfig.json` ao pacote). A `statue.res`, a "Sombra" (`hero_sombra/`), o `paladin_1/`, o `tools/recolor_hero.gd` e o `HeroGear` saíram do repositório (DT-107, Q-19 a). Pacote (C1 do artista técnico, `docs/qa/asset_report.md`): exe do Windows 197,2 MB (PCK 87,9; era 219,7 / 110,3), `index.pck` da Web 88,0 MB. **Texturas 3D comprimidas para a placa em todo `.import`** (`compress/mode=2`, `detect_3d/compress_to=0`: o projeto é importado sem tela e a detecção do editor nunca trocava): herói 2048 e Emeth 1024 (`process/size_limit`) em BC7, normal da rocha em BC5 (o z refeito no `masonry.gdshader` e no `catacomb_floor.gdshaderinc`), altura em BC4; as peças do KayKit usam um material só, `assets/models/kaykit_material.tres` com a paleta `kaykit_palette.png` em BC7 (`use_external` no `_subresources` de cada `.glb.import`, sem imagem extraída). VRAM dessas texturas de 161 para 10 MB. Travado por `tests/test_asset_import.gd`; medir com `tools/asset_probe.gd -- vram` e `tools/pck_sizes.py`.
- O lobo de geada do spec virou o esqueleto corredor. Vigília aparece como voto do PALADIN_1 (provisório).
- O spec fala em quatro paladinos; o cânone de 12/11 fala em um paladino do leão e quatro guardiões. Vale o que o Daniel decidir.
- Nomes dos paladinos: enquanto `PALADIN_n` for o próprio marcador, a oração entre colchetes que o cita some do texto
  (`"Luz[, dom de {P4}]"` mostra "Luz"; `TextTable._clauses`, `is_named`) e volta sozinha quando o Daniel der o nome (C12d,
  VX-11; `tests/test_no_placeholder.gd` monta as cartas e o painel de dons e procura `PALADIN_`). Contador de golpes do HUD
  menor (VX-12: `Hud.FONT_COMBO` 30, `COMBO_POP` 0,15, algarismos abaixo de 48 px a 1080 no pico, nome do golpe com alfa
  `MOVE_ALPHA` 0,7).
- Toque (celular) ainda não tem botões na tela.
- Desempenho: cerca de 1 ms por passo com 150 inimigos no PC; não medido em celular. **Qualidade gráfica (E6, DT-003)**:
  opção "Qualidade gráfica" Alta/Média/Baixa nas Configurações (`GraphicsQuality`, `core/graphics_quality.gd`; chave
  `quality` do save, Alta por padrão; escala 3D 1/0,85/0,5 com FSR, MSAA, névoa no ar, SSAO, SSR e tamanho das sombras;
  o glow fica sempre; `App.apply_options` e `Game.apply_options`; `--quality=alta|media|baixa`, `--gfx-<chave>=valor`).
  Medido na iGPU do notebook do Daniel (Intel RaptorLake-S, `tools/gpu.sh run ... --gpu-index 1`) a 1280 x 720: Alta 15 a
  17 qps, Baixa 62 a 81 qps no salão, Fendas, Jardim, Cripta e fase 4 de Morvath (`docs/qa/e6_audio_perf.md`).

## Aquecimento dos shaders (P1-1 do QA A8, DT-RS3; technical-artist, 2026-11-21; teste em `tests/test_warmup.gd`)
- `Warmup` (`scripts/render/warmup.gd`): no começo desenha 1 quadro de cada material do conjunto
  `assets/warmup/warmup_set.res` (135 itens: todo `.gdshader` de `assets/shaders`, os materiais montados em código e as
  variantes do `StandardMaterial3D` que as partidas usam), cada um num quadrado pequeno diante da própria câmera, com sol,
  lâmpada e foco que fazem sombra e um ambiente como o da partida (glow, névoa, SSAO/SSR pela qualidade), MultiMesh para
  os da multidão, `CanvasLayer` para os de tela, `FogVolume`, `Label3D` e `Sprite3D` pelas flags. Posto pelo `boot.gd`:
  atrás da arte do título, 3 por quadro (`PER_FRAME_TITLE`, o título segue respondendo); quando a linha de comando pula o
  título (`--bot`, `--start`...), sob uma tela preta, 40 por quadro, e a partida espera (`await warm.done`). `Warmup.reached`
  guarda até onde foi: um `Warmup.start(self, true)` depois (no `Game`, nos quadros pretos) faz só o que faltou; `null`
  quando não há nada (sem tela, `--no-warmup`, tudo feito). Depois de um shader ou look novo: `tools/make_warmup.sh` (cerca
  de 10 min; joga título, hub, todas as arenas e variantes, eventos, fases de Morvath, elites, famílias, ultimates e
  Salmos nos dois looks e nos dois renderizadores, sem tela, e guarda uma cópia leve de cada material novo,
  `tools/make_warmup.gd`); o teste falha se um `.gdshader` não está no conjunto.
- Medido na iGPU (1280 x 720 Baixa, Vulkan, robô, semente 5, `tools/frame_spikes.gd`, 420 s): cache vazio, o aquecimento
  leva 33,8 s no editor (no exe 133 s: o exe não traz os shaders do motor já compilados) e depois nenhum quadro de jogo
  acima de 50 ms nas salas além de 4 (132, 106, 56 e 55 ms; antes 0,5 a 3,3 s nos primeiros golpes); com o cache quente o
  aquecimento leva 1,9 a 2,0 s e só a Câmara tem um quadro de 117 ms. Fica o 1º quadro de cada sala, já na tela preta do
  `Rooms` (montagem da sala): frio 0,28 a 1,4 s, quente 0,16 a 0,77 s (Salão na 1ª entrada 2,6 s, com a carga da cena).
- **Não no Compatibility** (`Warmup.wanted`; `--warmup` força): lá o Godot não guarda shader de material entre uma
  abertura e outra (só os do motor) e compila cada um pelas luzes e pela instância de quem desenha. Medido na iGPU pelo
  D3D12 do WSL (opengl3, 1280 x 720 Baixa): o aquecimento custava 56 a 62 s a cada abertura, igual com o cache "quente",
  e o Salão ainda parava 16,8 a 17,8 s no 1º quadro e 0,2 a 2,2 s nos primeiros golpes. O P1-2 segue aberto.
- Shader Baker ligado nos presets Windows e Linux (`shader_baker/enabled`): só assa quando a exportação roda com tela e
  Vulkan (`xvfb-run ~/tools/godot/godot --path . --rendering-driver vulkan --export-release ...`, sem `--headless`); com
  `--headless` ele é pulado em silêncio. Assado, o exe do Windows fica com 206,8 MB (+9,6).

## Montagem da sala em quadros e o resto do aquecimento (P1-1 do QA A8, gameplay; testes em `tests/test_room_hold.gd` e `tests/test_masonry_merge.gd`)
- **O resto do aquecimento**: quem sai cedo do título leva o que faltou dos shaders para o `Game._ready`, antes da 1ª
  sala (`Warmup.start(self, true)`, a partida espera o `done`), sob a tela preta do `Warmup` com "Preparando as
  catacumbas" (`warmup_preparing`, provisório para o ui-ux-designer) e três losangos de ouro velho que acendem em vez
  (`Game._preparing_note`, `PreparingMark`, camada 101); enquanto isso o `Game._process` não anda (`_warming`) e a pausa
  automática não abre. Sem tela o `Warmup.start` dá `null` e nada espera.
- **A sala montada em quadros**: com tela, a porta (`Rooms._go`) segura o mundo (`holding()`) e monta a sala nova
  escondida, ao lado da velha, em passos (`Arena.build_async`, `Game.rebuild_room(..., wait)`): cada quadro preto faz
  passos até gastar `Arena.BUILD_BUDGET_MS` 8 ms; um passo pode devolver mais passos, que vêm logo depois
  (`BuildSteps`, `core/build_steps.gd`: `run` faz tudo de uma vez, igual a antes). Passos: `ArenaRoom.build_steps`
  (bordas de 2 em 2, `EDGES_A_STEP`; peças de 4 em 4, `PIECES_A_STEP`; `dress_steps()` de cada look, que o look
  reparte; a junção; `_stylize_steps`, com `ArenaKit.stylize_steps`, `_sworn_p2_steps`, um portão por porta), o salão
  (`CatacombHall.build_steps`), a Câmara do Selo (`BossChamber.build_steps`, sem `_process` até pronta), a árvore do
  Jardim (`StoneTree.build_steps`) e a grade de andar no fim (`_finish`). Pronta, a nova aparece e a velha some e é
  liberada um quadro depois (`Game._free_later`); o resto do `Rooms._enter_with` (a luta, a loja, o evento) tem quadros
  pretos próprios. A primeira sala da descida também (`Rooms._enter_first`, esperada pelo `Game._ready`: o que vem depois
  dele, `--stress`, `--boons`, captura, espera a sala pronta, como antes); com tela o `Game` começa com uma sala sem
  desenho (`Arena.build_bare`: medidas e grade de andar), nunca vista. Salão em passos menores (`_dais`, `_facade`,
  `_dais_props`, `_north_west`, `_north_west_props`). Medido na iGPU: a abertura saiu de 1,9 s (o salão montado duas
  vezes no mesmo quadro) para passos de no máximo 50 ms; o 1º quadro da cena do jogo (o `Game._ready`, uns 220 ms de
  CPU, e o primeiro desenho dela) segue entre 0,45 e 1,9 s. Sem tela tudo de uma vez: o mesmo `RESULT` (`smoke 600 --seed=5` e `--start=boss --boons=25`). A
  mesma sala nos dois caminhos (nós, cobertura, grade de andar, meio, saídas; todas as arenas, eventos e câmara no teste).
- **Junção sem ler a placa de vídeo** (`Masonry.merge`): o `SurfaceTool.append_from` lia cada peça de volta da placa
  (`surface_get_arrays` espera a placa: 0,15 a 0,57 s por sala na iGPU, 30 ms sem tela). Agora as malhas do `Masonry`
  guardam os arrays (`Masonry.kept(st)`, meta `ARRAYS`, com a tangente que a placa devolveria), os primitivos os fazem
  na CPU (`arrays_of`, uns de cada vez, `PRIMITIVES_A_STEP`) e a junção é feita nos arrays (`joined_arrays`: vértice
  pela transformação, normal e tangente pela base, normalizadas, como o `append_from`; o `SurfaceTool` fica de reserva),
  em fatias de `MERGE_SLICE` 6000 vértices (`merge_steps`). `Masonry.read_back` conta o que ainda vem da placa (0 nas
  salas). `--trace-build` imprime cada passo (`BUILD sala step N ms`) e cada junção (`MERGE`).

