# Direção de arte, modelos e o look estilizado

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Direção de arte e modelos
- Ciclo 7 na arena: estátuas com pregas, mangas e rosto afundado (sombreado na cor de vértice, camada de luz própria
  `ArenaKit.STATUE_LAYER`), ruínas distantes (`RUIN_GROUPS`), portal sem estouro (núcleo pequeno, luz baixa nas ombreiras; o derrame nos degraus segue a cor do portal, `ArenaKit.tint_with_portal`),
  medalhão com chanfro e runas fundas. Opções de captura: `--shot-on=swing|hit|special|omega` com `--shot-after`,
  `--cam-at=x,z` na vitrine, `--stress-ids=a,b`, `--hover=N` no título. Evidências do ciclo: `docs/gallery/cycle7/`.
- **Toda sala é o Salão das Catacumbas da imagem de referência do Daniel (2026-11-14, "Arena das Catacumbas")**,
  reconstruído peça por peça onde a pintura as tem (`CatacombHall`, `scripts/game/catacomb_hall.gd`; análise, medidas
  e pendências em `docs/art/arena_reference.md`): sala de 32 x 30 m sobre o abismo, altar com escada larga e o portal
  verde numa fachada gótica ao norte, estátuas encapuzadas, estátua gigante no abismo a oeste, balaustradas com velas e
  potes, obeliscos, patamar de entrada a sudoeste (o herói entra por ali), escada descendo a leste (porta 1) e ao sul
  (porta 2, com três portas), medalhão gravado. Pedra construída em `Masonry` (`masonry.gdshader`, cantaria triplanar,
  vale também para as peças de pedra do KayKit), chão em `catacomb_floor.gdshader`. Chão andável fora do retângulo:
  `Arena.walk`. Modelos que faltam para a fidelidade: `docs/art/meshy_asset_plan.md` (nada gerado).
  Ciclo 6 (feito pelo Fable, `docs/art/cycle6_spec.md` e `cycle6_final.md`): abismo com ponte e torre a oeste, portão de
  arco de ponta com fustes, pilone de corrente, cartões de ruína (`abyss_ruins.gdshader`) e bancos de bruma; estandartes
  (`ArenaKit.banner`), portal em arco de ponta (`PORTAL_SPRING`), caixotes (`Masonry.crate`). A vinheta da tela poupa os
  claros (`screen.gdshader`, `vignette` 0,45 e `vignette_spare_weight`), senão apaga braseiros e portal.
- **Renderizador**: Forward+ no desktop (névoa volumétrica, SSAO, reflexos nas poças, sombras dos braseiros);
  Compatibility no navegador e no celular, com exposição compensada (`Game.COMPAT_*`). Capturas usam Vulkan
  (`tools/shot.sh`; `DRIVER=opengl3` para ver como o navegador, `RES=1920x1080` para outro tamanho).
- Guia da estética (análise das referências, paleta, tempos dos golpes): `docs/arte/estetica.md`. Trabalho visual
  vai para o agente `art-director` (`.claude/agents/art-director.md`). Meshy: `tools/meshy/` (`meshy.mjs`: `image`, `retexture` para repintar a mesma malha, `rig`; pedir antes de gastar créditos; o Daniel comprou 1000 em 2026-11-15 e pediu para segurar depois dos inimigos e da Emeth, sobram 546).
- Referência atual: Hades 2 e Ember & Blade (vídeos do Daniel). **Do Hades II copiamos as mecânicas e os números,
  fielmente** (base para evoluir; o Daniel, 2026-11-15); do Ember & Blade, a sensação visual. Nomes, personagens, UI e
  arte são de Eterra. Terceira referência (2026-11-16): Ravenswatch, só em princípios (heróis com kit próprio, sem troca
  de arma, talentos por herói; `docs/design/benchmark_ravenswatch.md`). Comparação sistema por sistema e o que falta: `docs/design/comparativo.md` (manter em dia). A versão 2D em pixel art está na tag `v1-pixel-2d`.
- Modelos **provisórios**: KayKit (Kay Lousberg, CC0) em `assets/models/` (personagens e armas só para o assado; masmorra em `dungeon/` e `dungeon_r/`, todas com a paleta única `kaykit_palette.png`).
  Fontes Cinzel e Alegreya Sans (OFL) em `assets/fonts/`.
- **Armas e peças do Meshy (2026-11-21)**: cutelo (esqueleto), espada e escudo (cavaleiro), cajado (feiticeiro e ancião) e
  foice (Morvath) são `held` com `"meshy"` no `tools/bake.gd` (`triangles`, `slot` 0 a 3 do atlas de 128 px na faixa sob o corpo,
  `grip` o ponto da arma que vai à mão, `turn`/`rot`, `scale`); o orbe do cajado fica no anel (`STAFF_RING`). A foice é só a
  lâmina em meia-lua: o cabo é um cilindro de madeira (1,1 m, 2,0 m com a lâmina) na mão direita. O arqueiro mantém a besta do KayKit.
  A estátua do Salão (`Masonry.meshy_stone`, a lathe antiga fica de reserva) e o leão do Santuário (`HubLook.LION_*`, plinto,
  leão a 2,5 m, o do oeste espelhado, virados 0,3 rad para a escada) usam só a malha, com a pedra `Masonry.carved`.
- **Corpo por herói (M1c, 2026-11-23)**: `HeroBody.BODIES` (por `HeroDef.id`: modelo com esqueleto do Meshy, clipes, peça na
  mão); `HeroBody.make(id)`. A Maga é `hero_maga_img-rigged.glb` (mesmos 24 ossos e orçamento do Guerreiro) com os clipes
  da Quaternius levados a ela por `tools/bake_hero.gd -- maga` (`MAGA_CLIPS`; todos os golpes tocam `Cast`, o Passo `Blink`;
  os nomes de espada do Guerreiro apontam para `Cast`; o script imprime a altura das pontas do bastão em cada clipe) e o
  bastão `MagaStaff` (duas cópias da cabeça de `w_maga_staff` unidas no punho, `HALF` 1,2 do espaço da espada para cada lado). Brilho âmbar nas pontas (2026-11-23): uma esfera de 8 x 4 anéis em cada orbe (`MagaStaff._glow`, `staff_glow.gdshader`, aditivo, sem partícula, respira em contrafase, abaixo do limiar do brilho); `MagaStaff.set_cast(staff, 0..1)` levanta o brilho ao conjurar (falta o gancho do `Player`, de `scripts/game/`).
- Proporção: o KayKit é cabeçudo; `scripts/render/slender.gd` (`Slender`) afina o boneco depois da animação (cabeça
  menor, pernas e tronco mais longos), só no assado dos bonecos do KayKit guardados (os modelos do Meshy já têm a proporção certa).
- Câmera da imagem de referência, medida nela: girada 35° (`Feel.cam_yaw`; a sala vira o losango da pintura),
  inclinação 30, campo de visão 24, distância 54 no jogo (ciclo 5, para o herói ler maior; a vitrine `--showcase` fica em 60) (`_feel` do `make_data.gd`). Teclado e controle giram junto
  (`Feel.screen_to_floor`). `--showcase`: câmera fixa no enquadramento da pintura, para comparar.
  Enquadramento (`CamFrame`, `core/cam_frame.gd`): o ponto que a câmera olha fica dentro das margens da sala (`Game.CAM_MARGIN`,
  `CAM_SOUTH`, medidas a 60 m e escaladas pela distância), mas o herói nunca fica a menos de 18% de uma borda da tela
  (`CamFrame.SAFE`, `keep`): no patamar oeste a câmera segue ele além das margens. Ciclo C12c (GP-06): o ponto que a câmera
  olha nunca anda mais que `CamFrame.MAX_SPEED` 24 m/s (0,4 m por quadro a 60 FPS; `CamFrame.follow`; no avanço o herói passa
  dele por até 0,8 m, uns 2% da tela) e cada sala nova começa enquadrada nele (`Game.snap_camera` no `Rooms._enter`; antes a
  câmera voava da sala anterior, até 2,9 m por quadro atrás do escurecimento). `--trace-cam` imprime por sala o maior salto
  do alvo entre quadros e onde (`CAM_TRACE`, `CamFrame.JumpTrace`), e o da partida no fim.
  **Câmera Perto (2026-11-19; padrão desde o LR-01)**: Configurações > Vídeo > Câmera, "Perto" (padrão) ou "Longe" (a de
  antes, 54 m). Save versão 7: padrão `"near"`; um save de antes ainda no padrão antigo `"far"` passa a `"near"` uma vez, a
  menos que o jogador tenha escolhido (`camera_chosen`, marcado pelo `Save.set_option("camera", ...)`). "Perto"
  (`Feel.cam_distance_near` 37 m, o ZoomFraction 0,85 das salas de Érebo do Hades II: uns 28 m de largura na tela contra 41,
  a sala maior que a tela); chave `camera` do save (`"far"`/`"near"`), lida a cada quadro (`CamRig.near`, `CamRig.distance`:
  muda ao vivo, também no hub), `--cam=near|far` para capturas e testes (`--cam-dist` continua por cima). Perto, as margens da
  sala escalam como sempre (`CamFrame.margin`) e as salas de quadro fixo deixam de segurar: nas de `cam_target`/`cam_reach`
  (Runas, Provação, Altar, Câmara do Selo, hub) a câmera segue o herói (`CamRig.holds` só longe) e o alcance cresce, como a
  caixa `cam_bounds`, pelo que a câmera longe via a mais (`CamFrame.slack`, metade do chão visto no meio da tela a 54 menos a
  37, na largura e na altura da tela; `CamFrame.widen`); `hold` e `keep` iguais com folga zero, então Longe dá o mesmo
  `RESULT` com a mesma semente. **LR-02**: os atiradores preparam só dentro de 5 a 95% da tela **da câmera Longe**, qualquer
  que seja a câmera (`Horde.view`, `on_screen`, `_can_fire`; `Game._screen_of(..., as_far)`, `CamRig.look_at(..., as_far)`
  sem folga): a Perto não é dificuldade escondida, o `RESULT` é o mesmo com `--cam=near` e `--cam=far` na mesma semente
  (tiros e dano por sala iguais aos da Longe). A tela em uso (`Horde.seen`, `in_sight`) serve ao registro
  (`screen_flag`, `hurt_ctx.offscreen`) e à lista dos atiradores (e do sacerdote ancião) preparando fora dela
  (`Horde.off_screen_windups()`, para a divisa na borda da tela do ui-ux-designer). Testes em `tests/test_camera_near.gd`;
  capturas em `docs/gallery/camera_near/`.
- Herói no meio da multidão: onde algo o cobre ele aparece como o próprio corpo iluminado, nas cores dele (ciclo 7: nada de
  silhueta chapada), com fio marfim fino em pixels da tela e a Emeth por cima, em três passes desenhados por último
  (`xray_depth`, `xray`, `xray_edge`; `Player.XRAY_*`), mais um anel fino petróleo no chão com uma cunha para onde ele olha
  (`hero_ring.gdshader`, `Player.RING_*`). Ao levar golpe ele clareia morno por 0,05 s, nunca vira silhueta branca
  (`Player.HURT_*`). `--outline=0` desliga o raio-x. Ciclo 8 (B3): a multidão marca o stencil (`stencil_mode write` no
  `crowd.gdshader`, valor 1); o raio-x cheio só aparece onde a multidão o cobre (`xray.gdshader`, `compare_equal`) e atrás de
  pedra (obelisco, balaustrada, estátua) ele sai mais apagado, sem luz extra (`xray_behind.gdshader`, `Player.XRAY_BEHIND_*`,
  corpo comum em `xray_body.gdshaderinc`), com o mesmo fio marfim; o anel só se desenha no chão aberto e através da multidão
  (`hero_ring_through.gdshader`), nunca por cima da pedra. Assim ele lê como "atrás", não "em cima". Luz pintada nos ombros
  e no cabelo um passo maior (`Player.KEY_LIGHT` 0,3). Funciona em Forward+ e Compatibility.
- Escala (1º teste do Daniel, "tudo é muito grande"): o cenário do KayKit é encolhido por peça em `Arena.PROP_SCALE`
  (paredes 72% da altura, escadas 0,8 x 0,55, barris 0,55, entulho 0,5 a 0,6, velas 0,7); pilares desenhados pelo raio que
  bloqueia (`RoomLayout.pillars`, 0,6 m; `Arena.PILLAR_MODEL_RADIUS`, `PILLAR_HEIGHT` 0,68). A colisão segue o modelo escalado.
  Efeitos e HUD mais discretos (números `Fx.NUMBER_SIZE` 17, HUD em `Hud`: medalhão do herói `HeroCrest` com o rosto do Explorador recortado da arte do título (`assets/ui/hud/hero_portrait.png`), vida e Magia em `HudBar` com rastro do que foi perdido, as quatro ações em losango `ActionSlot` com a tecla real, recarga num fio que corre pelo aro e num nível de ouro velho que sobe dentro da gema (`ActionSlot.band`), e com alguém atrás só o corpo do losango fica translúcido (`ActionSlot.veil`; ícone, recarga e tecla ficam inteiros, ciclo 8); uma espessura de moldura `UiKit.FRAME` e `UiKit.OLD_GOLD`, sombra em todo texto, divisas para elite, guardião e chefe fora da tela). Números em `docs/arte/estetica.md`.
- Impacto de cada golpe (ciclo 7): uma fita só que afina até a cauda, com ponta de lâmina, sobre a tinta escura (`slash.gdshader`,
  `Fx.slash`), pulso curto da lâmina sem luz nova (`EmethSword.PULSE_GLOW`), talho ao longo do corte e lascas só em acerto real
  (`impact.gdshader`, `Fx.gash`, `Combat.cut_axis`; testado em `tests/test_fx_on_hit.gd`), números pálidos (esmeralda só em
  finalizador e Ômega, `Combat.number_color`), estocadas em feixe fino (`emeth_thrust.gdshader`), o especial como onda
  esmeralda da lâmina (W-1, D-69: `emeth_wave.gdshader`), o círculo de luz como aro fino com marcas girando; inimigo pisca abaixo do limiar do glow e achata, corpo arremessado ao morrer
  (`Horde.THROW`), tranco de câmera (`Fx.kick`), hit stop do Hades, lentidão e não congelamento (`HitStop`, C12d) e brilho de antecipação nos finalizadores
  (`ComboNode.glint`, 0,08 s em todo finalizador, `FINISHER_GLINT` no `make_data.gd`, desenhado por `Fx.glint` na ponta da
  espada; ciclo 10: antes o dado era zero). Finalizadores soltam a meia-lua enorme (`Fx.crescent`). Quadro de impacto em preto e
  branco (`Fx.impact_frame`; ciclo 10, decisão D-08): só no Ômega que acerta e no golpe que derruba uma fase do chefe (ou o
  derruba), no máximo um a cada 10 s (`Feel.impact_frame_every`, `Combat.wants_impact_frame`, `breaks_phase`), e nunca com a
  opção `impact_frames` do save desligada (`SaveData`, padrão ligada; `Game.apply_options` passa para `Fx.impact_frames`; a tela
  da opção é do ui-ux-designer, texto `opt_impact_frames`). Multidão cinza clara sobre o chão escuro, que brilha um pouco sozinha para ser lida longe da luz (`CrowdRenderer.CROWD_*`, `lift` e `flat_light` no `crowd.gdshader`); cortes desenhados até a ponta da Emeth (`Fx.BLADE_REACH`, C12d); elites com contorno escuro e fino
  (`crowd_outline.gdshader`, `CrowdRenderer.OUTLINE_*`; largura em metros do mundo) e borda de ouro velho fraca (`ELITE_RIM`); o ouro das elites é velho (`CrowdRenderer.GILD_COLOR`), nunca amarelo vivo. Detalhes e pendências em `docs/arte/estetica.md`.
  Ciclo 8: o inimigo atingido é o próprio corpo mais claro e morno (`flash_light`, `flash_warm` no `crowd.gdshader`), o que o
  pisca soma para em `flash_cap` 1,0 (abaixo do limiar do glow, nada de bola branca sobre o herói); só o 1º quadro de um golpe
  forte vai um pouco para o marfim (`white_from` 0,85, `flash_white` 0,35). Fita do corte mais estreita, lado de dentro mais
  suave (`widest`, `inner_light` no `slash.gdshader`). Ataque, especial e Ômega se distinguem: estocada comum com fio pálido;
  Ômega com fio mais largo e branco e os dois veios de ouro velho nas bordas (`omega` no `emeth_thrust.gdshader`,
  `Fx.thrust(..., omega)`) e talho cruzado; a onda do especial com o fio de ouro velho no meio (`vein_*` e `gold_light` no `emeth_wave.gdshader`) e
  acerto em estrela furada com lascas de ouro (`Combat.SPECIAL_STAR`). Orçamento por quadro (`FxBudget`,
  `core/fx_budget.gd`; `Fx.BUDGET_*`: 40 lascas, 8 talhos, 6 explosões de partículas). Números de dano por `NumberTally`
  (`core/number_tally.gd`): acertos seguidos no mesmo alvo (até 0,6 s entre eles) somam num número só que pula de novo,
  no máximo 6 num raio de 3 m e 12 na tela; os de finalizador e Ômega nunca dão lugar a um comum (testes em
  `tests/test_fx_budget.gd` e `tests/test_fx_on_hit.gd`). Antes e depois: `docs/gallery/cycle8/work/`. Ciclo 9: passando de
  6 números comuns no mesmo quadro (`NumberTally.GROUP_FROM`), os comuns daquele quadro viram um total só no meio deles
  (`group`, fonte `GROUP_SIZE` 20, continua somando por 0,15 s); finalizadores nunca somam; nenhum número a menos de 60 px
  (a 720 linhas) da cabeça do herói (`NumberTally.clear_of`, `Fx.hero_head`). Testes em `tests/test_curse_hud.gd`.
- Ciclo 10 (arte da luta e da multidão; `docs/arte/estetica.md`, evidências em `docs/gallery/cycle10/work/`): escudo do ritual
  sem pontos brancos (provável NaN no glow: `boss_shield.gdshader` protegido; partículas `BossShield.MOTE_*` verdes e azuis, 0,12 m, até
  1,2); esmeralda corrompido frio e escuro (`BossShield.COLOR`, matiz 165, valor 0,7) no escudo, nas colunas
  (`spectral_column.gdshader`) e nas runas (`ritual_rune.gdshader`), longe do verde da Emeth; no começo do ritual uma
  cortina fina na borda do escudo (`BossShield.CURTAIN_*`, luz 0,4) no lugar do pilar branco que cobria Morvath; tiros
  inimigos no matiz da magia, miolo pequeno abaixo do glow e halo misturado de 1,5 raio (`enemy_orb*.gdshader`,
  `Projectiles.HALO`, matiz por instância), centelhas do preparo a 1,2 (`EnemyFx.MAGIC_SPARK`); queimadura em brasas
  na borda e pontos de brasa, sem tingir o corpo (`burn_*`, `coal_*` no `crowd.gdshader`). Clima da sala: `RoomMood`
  (`scripts/game/room_mood.gd`, `Arena.mood()`) vira o ar de qualquer cenário para um `RoomMood.Look` e devolve tudo
  exato (ambiente, névoa, fundo, lua, fogos, brilho do abismo, curva de cor nos escuros, global de shader `room_air`
  seguido pelas ruínas e pela bruma do abismo); `Arena.final_phase` liga `LAST_BREATH` (fase 4 violeta) e
  `seal_portal` desliga. Testes em `tests/test_cycle10_look.gd`.
- Ciclo C12d (VX-01 a VX-03, VX-08 a VX-10, VX-COL; números em `docs/arte/estetica.md`, quadros em
  `docs/gallery/c12d/work/vx_*.jpg`): o corte é só o fio marfim-menta da borda de ataque com miolo pálido (saturação até
  0,4) sobre tinta escura translúcida (alfa até 0,6), o fio onde a ponta da lâmina passou (`blade_m`, `reach_m`,
  `band_from` no `slash.gdshader` e no `slash_ink.gdshader`, passados pelo `Fx`: `BLADE_REACH` 2,6 m medido na ponta
  real da Emeth nos golpes, `SLASH_INNER` e `INK_INNER` 0,12; o inimigo passa `blade` 0 e fica com a borda de fora), e só
  um véu até o alcance; o corte já aparece no quadro do golpe (`Fx.SLASH_LEAD`, um quadro) e varre em 3 quadros
  (`Feel.slash_sweep_time` 0,05; `tests/test_slash_wire.gd`); o brilho do
  finalizador tem anel em metros (até 1,6 m de diâmetro), cruz vazada no meio e só 0,2 da luz sobre o corpo do herói
  (`hero_pos`, `glint.gdshader`); o preenchimento dos avisos dos inimigos sai numa segunda passada (`ground_fill.gdshader`,
  corpo comum em `ground.gdshaderinc`, uniforms nos dois por `GroundLook.put`), fraco até os últimos 30% do preparo
  (`fill_max` 0,35) e sem somar onde avisos se cruzam (stencil 2; a multidão usa 1); aro do círculo de luz mais fino e
  fraco (`circle_rim*`, `circle_mark_*`); quem tem borda própria (elites, guardiões, Morvath) queima sem perder a cor
  (`burn_*_own` no `crowd.gdshader`); partículas e lascas alongadas pelo voo em `chip.gdshader` (a MultiMesh do `Fx`: `MOTE_WIDTH` 0,5, `MOTE_STREAK` 0,03,
  `MOTE_LONG` 2 a 4 larguras, `Fx.streak`); as lascas de um acerto são cinza-pedra e somem em até 0,22 s (`Combat.CHIP_*`:
  cor 0,42 / 0,4 / 0,37, 6 m/s, 0,08 m); colunas
  de luz translúcidas, lados suaves, miolo pálido, degradê para cima e veios subindo, sempre sob o teto da tela
  (`beam.gdshader`: `body`, `side_soft`, `core_*`, `top_from`, `foot`, `streaks`).
- E1b, cenário e especial (evidências em `docs/gallery/e1b/vfx/` e `env/`): **W-1 (D-69)** a Seta de Luz lê como a onda
  da lâmina do Guerreiro, não como dardo: meia-lua curta e fina deitada a 1,1 m, a barriga para onde voa, borda de
  ataque pálida, corpo esmeralda afinando para trás, fio de ouro velho no meio e um rastro curto, por cima do que está
  atrás (`blend_premul_alpha`, tinta escura 0,3) e aberta em volta do herói (`hero_hole`); maior canal 1,0, abaixo do
  limiar do glow 1,3 (`emeth_wave.gdshader`, `Projectiles.WAVE_*`, `WAVE_PEAK`, `WAVE_GOLD_LIGHT`). O especial tem
  1,6 m de ponta a ponta (acerto de 1,4); o Ômega do especial é a mesma onda da largura do acerto (8,25 m, `OMEGA_*`).
  Mesmas regras: velocidade, alcance, círculo do acerto, dano e tempos (`tests/test_special_wave.gd`); o acerto em
  estrela com lascas de ouro continua. `emeth_dart.gdshader` saiu. **VX-13**: metade dos grupos de velas da borda do
  salão apagados (`CatacombHall._candles(..., burnt)`, `Masonry.candle_out`: cera escura `WAX_OUT`, pavio, sem chama,
  halo nem luz): os do leste, do canto nordeste, da pedra sul, do patamar e o de z 2,2 da balaustrada oeste; ficam o
  altar, os outros quatro do oeste, o do canto norte e os braseiros. **M-1**: luz de preenchimento só do chão da Cripta
  (`CryptLook.FLOOR_FILL*`, sem sombra, `light_cull_mask` = `ArenaRoom.FLOOR_LAYER` 64, que só o chão tem por
  `ArenaRoom.floor_layers`): as paredes não mudam.
- Câmera lenta no molde do Hades II (`Fx.slow_mo`: velocidade do mundo por `Engine.time_scale`, zoom, desfoque radial e
  brilho no `screen.gdshader`): último abate da sala (0,35 por 0,55 s, `Rooms.LAST_KILL_*`), golpe que derruba 3 ou
  acerta 7 de uma vez, no máximo uma vez a cada 6 s (`Combat.SLOW_MO_*`, `wants_slow_mo`; no Hades só o último abate e o chefe
  têm câmera lenta, golpes têm só centésimos), morte de Morvath; abate segura o hit slow +40 ms; a câmera
  fecha 8% enquanto o Ômega carrega (`Game.OMEGA_ZOOM`). Menus cortam a câmera lenta. Ver parado: `--lab --lab-slow`.
  Finalizadores soltam a meia-lua gigante e branca do Ember & Blade (`Fx.CRESCENT_*`), também no giro.
- Efeitos: `scripts/game/fx.gd` (partículas, cortes, anéis, feixes, números, hit stop, tremor) e shaders em `assets/shaders/`.
  Ciclo 10: a coluna de um dom que cai sobre o chefe ou um guardião sai fraca (`Skills.BEAM_OVER_BOSS` 0,2 da luz,
  `Fx.beam(..., intensity)`; ART-004); as partículas de luz do herói (dom tomado, Ômega carregado, círculo) são marfim abaixo
  do glow (`&"light"` em `Fx.BURSTS`, até 1,1) e saem atrás dele vistas da câmera (`Fx.hero_burst`, `HERO_BURST_BACK`; ART-009).
  Brilho pelo glow do `WorldEnvironment` (cores acima de 1 brilham). Ciclo C12c (GP-01): toda coluna de luz para em 1,0 por
  canal (`Fx.BEAM_CORE_CAP`, o padrão do `Fx.beam`; `BEAM_NO_CAP` só pedido pelo nome) e passa por `Game.column`, que a deixa
  fraca (`Skills.BEAM_OVER_BOSS`) a menos de 2 m do herói (`Game.BEAM_NEAR_HERO`) ou na frente dele ou do chefe na tela
  (`Skills.covers`, `over_boss`): recompensa, fonte, dom tomado, dom que cai, elite que surge. Morvath entra sem coluna: anel
  espectral no chão e almas aos pés (`Boss.ENTRANCE_RING`, `ENTRANCE_SOULS`). Gemas das portas e das recompensas com a cor
  2,2 vezes e o maior canal em 1,0, mesmo matiz (`Rooms.gem_color`, `GEM_LIFT`, `GEM_CAP`). Testes em `tests/test_cycle12c.gd`.
  Correção A-1/B-1 do QA-02: 1,0 no material não é 1,0 na tela (exposição 1,25 e curva fílmica levam 0,9 a 255, a saturação
  1,3 empurra o canal mais forte; a coluna era aditiva, duas faces e o chão somavam). `ScreenTone` (`core/screen_tone.gd`)
  modela a tela do Forward+ (conferido na GPU por `tools/tone_probe.gd`, até 3 de diferença) e dá o teto na tela
  (`SCREEN_MAX` 235, mira em `SAFE` 226): a coluna recebe `cap` = `ScreenTone.linear_peak(cor)` e se deposita por cima do
  que está atrás (`blend_premul_alpha`, alfa = luz / teto, nada soma além do teto), lados pouco esbranquiçados (`whiten`
  0,25: a cor da recompensa fica) e abre em volta do herói onde está na frente dele (`hero_hole`, global `hero_pos`); gemas
  por `ScreenTone.fit`; o realce da câmera lenta no `screen.gdshader` não passa de `lift_ceiling` 0,9. Testes em
  `tests/test_screen_tone.gd`.

## Prova estilizada (STY-03 a STY-05, cenário; spec `docs/art/stylized_spec.md`, plano `docs/art/stylized_poc_plan.md`)
- Perfil visual reversível (`VisualProfile`, `core/visual_profile.gd`): `Look.CLASSIC` e `STYLIZED`; **no exe exportado o padrão é o
  STYLIZED** (RS-F2, 2026-11-19, `VisualProfile.default_look`: `OS.has_feature("template")`), na Godot do editor (testes, capturas,
  ferramentas) continua o CLASSIC; `--look=classic|stylized`,
  **F7** troca ao vivo também no exe (ação `look_toggle`, lida no `Game._process` e no `Hub`), global de shader `art_style` (0 ou 1).
  DT-RS2: o look fica nas opções do computador (chave `look` do perfil, `"stylized"` ou `"classic"`, padrão `"stylized"`;
  save de antes sem a chave abre estilizado); `Save.choose_look(look)` aplica e grava, o F7 e a tela das Configurações
  usam ela; no exe o `Save.load_profile` passa a escolha ao `VisualProfile.remember` (`--look` continua por cima; no
  editor segue o clássico).
  Um look é uma lista de valores ao lado de cada peça: `VisualProfile.vary(objeto, {propriedade: valor estilizado})` guarda o
  valor de agora como o clássico (referência fraca) e aplica o do look em curso; vale para material (`shader`,
  `shader_parameter/x`, `albedo_color`), luz, `visible` e `Environment`. O clássico é a peça como foi montada: nenhum
  shader clássico inclui a pintura, então o quadro clássico é o de antes (testado: `tests/test_visual_profile.gd` monta o
  salão, troca duas vezes e compara todo material, luz, visibilidade e a colisão).
- Pintura: `paint.gdshaderinc` (`light()` em três faixas 0,42 / 0,72 / 1,0 com cortes 0,3 e 0,65, sombra quase neutra fria,
  poça das chamas com borda `paint_pool`, brilho só no chão molhado; pincelada em mundo de 0,6 e 0,15 m esticada 2:1 em três
  degraus 0,88 a 1,12 e ±4 graus de matiz; `paint_recolor` leva qualquer pedra à pedra morna `paint_stone` mantendo o valor; aresta
  clara `PAINT_RIM` nos props). Gêmeos com `#define PAINT`: `masonry_paint.gdshader` (corpo em `masonry.gdshaderinc`: valor e
  matiz por bloco, oliva em 1 de 8, lábio claro no topo, juntas frias e escuras) e `catacomb_floor_paint.gdshader` (lajes
  mornas, juntas frias, medalhão sem ouro nem brilho, S-Q6; chão escurece para a borda `edge_*`); `kaykit_paint.gdshader` e
  `assets/models/kaykit_paint.tres` (paleta do KayKit pintada). `ArenaKit.paint_look()` troca o shader de toda pedra, chão
  e peça do KayKit da sala (madeira com `paint_keep`); estandartes de leão ganham um gêmeo petróleo (`BANNER_PAINT_*`, um em
  dois rasgado) mostrado só no estilizado. Ar (`VisualProfile.dress_world`, chamado no `_build_world`): ambiente morno
  `AMBIENT` x `AMBIENT_GAIN` 1,2, névoa 0,4, saturação 0,77, lua vira luz de chave de trás da câmera (`KEY_*`, 1,6); no
  Compatibility a chave a `COMPAT_KEY` 0,12 e a saturação 0,8 (lá a pedra pintada clareava demais). Salão
  (`CatacombHall._stylize`): luz do meio apagada, braseiros 4,5 m e velas 3,5 m de alcance com metade da energia, velas
  com cera mais escura e chama âmbar sob o glow (`Masonry.STY_*`). O salão não tem parede nem pilar do KayKit (já é cantaria):
  STY-05 nele são os estandartes e os props. Nada muda colisão. Outras arenas recebem só o que passar pelo `ArenaKit` e podem
  ficar incompletas. Medido (1920 x 1080 RTX, Alta, vitrine): 144 qps clássico, 141 estilizado; iGPU Baixa 1280 x 720: 58/54
  contra 55/54; nenhuma textura nova.

## Prova estilizada, personagens e pós (STY-06, STY-07)
- **Personagens, Emeth e combate (STY-06, technical-artist)**: tudo pelo global `art_style` (0 clássico, 1 estilizado,
  `VisualProfile`; `--look`, F7); com 0 o quadro é o de antes (captura da RTX igual fora das chamas, que mexem sozinhas) e
  nenhum parâmetro muda (`tests/test_stylized_figures.gd`, também depois de ir e voltar pelo F7). Multidão
  (`crowd.gdshader`, `style_*`): chave do corpo em três faixas (`figure_bands` em `figure_paint.gdshaderinc`, as do
  `paint.gdshaderinc` do cenário: 0,42 / 0,72 / 1,0 em N·L 0,3 e 0,65, rampa 0,10), corpo mais escuro (`style_light`
  0,32 da chave, `style_scene` 0,22 do ambiente), borda morna (1,0; 0,82; 0,62) de fresnel 3,5 no lugar da tinta escura
  da borda, textura puxada 0,35 para a média do mip 3 (`style_flat`); pisca, "vai bater", queimadura, ouro e dissolver
  iguais. Contorno de casca em todos (`crowd_outline.gdshader`, `style_width` 0,04 m, `style_color` (0,07; 0,06; 0,06),
  empurrado `style_push` 0,25 m para longe da câmera: sem manchas por dentro do pano aberto); os comuns só ganham o
  passe no estilizado (`VisualProfile.vary` no `next_pass`, `CrowdRenderer.STYLE_OUTLINE_*`). Herói: `hero_paint.gdshader`
  (duas faces como o modelo, luz das salas em três faixas por `light()`, `value` 0,34, mesma borda morna mais forte e
  maior no lado da luz, `flatten` 0,35, fosco) e `hero_outline.gdshader` (0,045 m, (0,05; 0,07; 0,08), empurrado 0,25 m),
  postos por `HeroBody.painted` e trocados pelo F7 (`VisualProfile.vary` no `material_override`); os três passes do raio-x,
  o anel, o pisca (`HeroBody.set_fill` nos dois materiais, `HeroBody.materials`) e a maldição continuam. Emeth: cristal em
  duas faixas (fundo matiz 140 valor 0,45, face matiz 133 valor 0,75, `style_back`/`style_face`), nada acima de 0,98
  (`style_cap`), fio do meio marfim-menta sem brilho (`EmethSword.STYLE_CORE`). Corte: miolo mais fundo e chapado, metade
  de trás em pinceladas partidas de 0,08 a 0,18 m que somem da cauda (`slash_strokes.gdshaderinc`, no `slash` e no
  `slash_ink`), nada acima de `style_cap` 0,55 por canal. Lascas esmeralda do golpe com metade da largura e abaixo de 0,9
  (`chip.gdshader`; as cinza do acerto e as de ouro iguais). Avisos (`ground.gdshaderinc`): `style_rim_gain` 1,6 no aro,
  frente, divisas e fio da mira, `style_fill_gain` 1,5 no preenchimento; forma, tempo e cor iguais.
- **Pós de pintura (STY-07, `PaintPass`, `scripts/render/paint_pass.gd`, `assets/shaders/paint_pass.glsl`)**: Kuwahara de 4
  setores de 2 px a 1080 e contorno por salto de profundidade, `CompositorEffect` depois do opaco, só Forward+, só Alta,
  só estilizado. **Desligado** (`PaintPass.DEFAULT_ON` false; `--paint-pass=1` liga para ver): cai nos critérios 1 e 2 da
  spec 5.2 (as runas do medalhão e as rachaduras finas viram borrão, pontos escuros nos corpos) e não convive com o MSAA
  da Alta (o quadro é resolvido de novo depois dos transparentes; ligado, ele desliga o MSAA). Custo medido na RTX a
  1080: 0,14 ms de GPU, mais 7,5 MB de memória de vídeo.
- **Correções depois do STY-09 (STY-10, technical-artist; só no estilizado, o clássico igual)**, valendo sobre os números
  acima: multidão mais escura que a laje (`crowd.gdshader`: `style_light` 0,2, `style_scene` 0,1, `style_rim` 0,18 e
  `style_hero` 0,2 da luz morna do herói, que era o que mais clareava o osso perto dele): esqueleto ao lado do herói de
  luma p50 103 para 65 na mesma captura (-37%; na medida do art-director, 86 para cerca de 55). "Vai bater" reforçado
  (`style_tell`, `CrowdRenderer.STYLE_TELL` 1,6): subida média 29 contra 19 no clássico; pisca igual (p90 +143 contra
  +142). Morvath com o violeta (`style_vivid`, `CrowdRenderer.STYLE_BOSS_VIVID` 1,0: a pintura dele mais saturada e a
  borda na cor dele em vez da morna): saturação do corpo 0,19 para 0,32, matiz 313 para 275 (clássico 0,36 e 280). Herói
  `value` 0,28, `rim` 0,7 e `top` 0,3 (`hero_paint.gdshader`: o claro da pintura, o forro creme da capa, para em 0,3 de
  luma): p90 do tronco 189 para 181. Avisos dos inimigos (`ground.gdshaderinc`): o vermelho vira `style_warn_color`
  (1; 0,09; 0,21) e a segunda passada (`ground_fill.gdshader`, agora `blend_premul_alpha` com `ALPHA` 0 no clássico)
  escurece a laje sob a forma e sob o fio da mira a 0,8 (`style_under` 0,2), com `style_rim_gain` 2,0: matiz na tela de 4
  a 13 para 349 a 2 (aro 348 a 352), saturação do fio da mira 0,42 para 0,56, aro 54 a 72 acima do chão. Corte
  (`slash.gdshader`, `slash_ink.gdshader`): miolo 28% mais fraco e mais raso (`style_core_light` 0,216, `style_core_depth`
  0,6), tinta com alfa vezes `style_veil` 0,72, fio com teto próprio `style_edge_cap` 0,38: no chão, fio top 15% de 243
  (com 265 pixels acima de 235) para 222 sem nenhum acima de 235, véu 29% menor; área do corte 0,76 da do clássico. Sobre o osso
  claro da multidão o fio somado ainda vai ao branco, como no clássico. Faixas das figuras seguem em
  `figure_paint.gdshaderinc` (a pedra baixou a faixa de sombra para 0,25; juntar só quando as duas frentes fecharem).
  **Ouro das elites no estilizado** (bug do PO de 2026-11-19, elites iguais aos comuns no look padrão do exe): toda
  figura com borda própria menos o chefe (`EnemyDef.rim` > 0: elites e guardiões; `style_elite` 1, posto pelo
  `CrowdRenderer.register`) tem no estilizado o aço dourado aceso pela chave a `style_gild_light` 0,7 (não a 0,2 do
  corpo), ouro velho mais saturado `style_gild_sat` 1,15 e um véu de ouro `style_gild_rest` 0,12 no resto; a borda morna
  vira borda de ouro velho (`gild_color`, `style_elite_rim` 1,0 da morna, fresnel 3,5) e a casca escura vira ouro velho
  escuro (`crowd_outline.gdshader` `style_elite_color`, `CrowdRenderer.STYLE_ELITE_OUTLINE` (0,36; 0,27; 0,12), 0,05 m,
  `STYLE_ELITE_WIDTH`). Pisca, "vai bater", queimadura, dissolver, Morvath e os comuns iguais; o clássico igual (captura
  na RTX idêntica fora das chamas). Medido no laboratório (`enemy_lab --look=stylized`, só os pixels da figura): antes
  comum e elite iguais (matiz 21 a 30, saturação 0,32 a 0,46 contra 0,34 a 0,50, luma p50 23 a 47 contra 24 a 48), depois
  a elite com matiz 28 a 35, saturação 0,51 a 0,67 e luma p50 45 a 89 (o comum fica 15 a 30, 0,29 a 0,46 e 23 a 47); no
  jogo (`--stress=8 --stress-ids=guard_elite,skeleton_elite,skeleton,guard --seed=5 --hero-at=2,2 --shot-at=0.8`, contra
  o quadro vazio) Escudo elite luma p50 43 para 79 e saturação 0,35 para 0,50 (Escudo comum 51 e 0,29), esqueleto elite
  saturação 0,41 para 0,54 e pixels de ouro velho 36 para 59% (comum 13 a 37%). No Compatibility as figuras seguem
  escuras e a casca de ouro lê. Antes e depois em `docs/gallery/redesign/elite_gold/`.
- **Correções depois do STY-09 (STY-10, environment-artist; só no estilizado, o clássico igual)**: **poças de fogo**
  (`paint.gdshaderinc`): a luz quente (vermelho bem acima do azul, `paint_fire_from`) não passa mais pelas três faixas
  (N·L vezes a queda de um fogo a 2,8 m nunca saía da faixa de sombra): pinta uma poça chapada com borda desenhada
  (`paint_pool` 0,1, núcleo `paint_pool_core` 0,3, borda `paint_pool_soft` 0,02), mais clara que a luz (`paint_pool_gain`
  2,5: a cera das velas e as figuras ficam na energia da luz) e menos saturada (`paint_pool_saturation` 0,65). Braseiros
  sem sombra no estilizado (a borda da tigela sombreava o chão até 2,3 m: a poça era um anel fino em volta de um disco
  escuro), queda 0,5, energia 1,1 da clássica (`CatacombHall.STY_BOWL_*`); velas 1,2 (`STY_CANDLE_GAIN`); ambiente
  `VisualProfile.AMBIENT_GAIN` 1,0. No chão, em volta dos braseiros (os `wet_spots`), a laje fica no valor do meio e não
  no escurecido da borda da sala, e o molhado não escurece (`paint_wet_dark` 1,0). Medido na vitrine (RTX, 720, laje a
  1,5 m): braseiro leste 30 para 106 a 109 (p90 120), matiz 27; velas 107 a 150, matiz 29 a 32; braseiro norte 103 a 175;
  meio do chão 72 a 77 (era 74 a 80); quadro p50 56. **Fase 4 na Câmara do Selo (P1-1)**: o `RoomMood` lia o ar da
  sala no `blend` e a câmara se veste um quadro depois (`BossChamber._dress_world` diferido); com o chefe já na fase 4
  (`--boss-hp`) ele guardava o ar do salão, e no estilizado a chave de trás da câmera (1,6) vezes 1,8 lavava o chão de
  ciano. Agora o ar é lido no quadro seguinte e de novo a cada vez que o clima liga do zero (`RoomMood._take_due`; teste
  em `test_cycle10_look.gd`). Medido com as correções do technical-artist juntas (`--start=boss --boss-hp=0.14
  --boss-only=storm`, 0,6 s, com e sem o `Ground`): chão sob o aviso 129 para 73, caixa ao sul do selo 125 a 142 para 63 a
  75 (matiz 190 para 215), faixas saturação 0,27 para 0,50, aro 73 para 122 acima do chão; clássico 70 / 121 / 0,55 (o
  atalho do clássico também lia o ar do salão: chão 75 para 70, a partida de verdade já era assim). Fases 1 a 3 e o
  ritual iguais ao clássico. **Medalhão** (`catacomb_floor.gdshaderinc`, `PAINT`): faixa de pedra única um pouco mais
  clara (`paint_band` 1,08), um sulco só em cada borda (`paint_band_groove` 0,11, relevo dos chanfros a 0,25), runas mais
  longas e finas com borda dura no valor da junta da própria faixa (`paint_rune_stroke` 0,12 m: 5,6 px a 1080 de través e
  3 px no sentido mais encurtado; `paint_rune_size` 0,4, sem o lábio claro), quadrifólio no mesmo traço
  (`paint_rosette`). **Velas e caixotes**: cera velha `Masonry.STY_WAX` (0,52; 0,45; 0,36), sem borda de luz; madeira
  dos caixotes (`paint_keep`) a 0,5 da saturação e 0,8 do valor, lábio claro das tábuas a 0,35 (`wood_*` no
  `masonry.gdshaderinc`). No Compatibility os fogos a `STY_COMPAT_FIRE` 0,4 (sem isso a poça ia a 217; com, 107 a 181,
  sem erro no log). iGPU Baixa 1280 x 720 (duas rodadas): clássico 16,8 e 17,1 ms (59,5 e 58,5 qps), estilizado 16,3 e
  17,8 ms (61,3 e 56,2 qps), 616 chamadas contra 822 a 926 (braseiros sem sombra).
- Medido depois do STY-04/05 (bot, semente 5, sala de abertura): RTX 1080 Alta GPU 2,80 ms clássico, 2,63 estilizado (756 e 818
  chamadas, 330 e 332 MB); iGPU Baixa 1280 x 720 15,05 e 15,75 ms; fio da mira dos avisos 130 a 138 de luma sobre a laje de
  72 a 86 (+50). Sonda de sensação 40/40 nos dois looks; o Compatibility abre sem erro.
- Medir o quadro do jogo: `tools/sty_probe.gd` (comando no topo; `PROBE` com quadro, CPU, GPU, chamadas e memória de vídeo).

- Revisão de 2026-11-21 (`docs/art/review_2026-11-21.md` itens 2, 4, 6): comuns mais claros no estilizado (`CrowdRenderer.STYLE_COMMON_*`, elites e Morvath intactos); chamas com ponta que some, borda translúcida e oscilação por camada (`ArenaKit.FLAME_*`); raio-x por ruído de gradiente (`see_through.gdshaderinc`, `SEE_GHOST`). Armas no assado: `"aim"` gira a arma na mão para uma direção do modelo no idle (espada do cavaleiro, foice de Morvath com cabo de 2,0 m em peças `shape`), `"lift"` clareia a textura (cutelo).

- **H-1/H-2 (2026-11-25)**: o Guerreiro estilizado: `hero_paint.gdshader` pinta como aço escuro tudo que não é pele, laranja, verde da capa nem ouro; ouro velho nos remendos dourados; couro marrom só na faixa do cinto (`belt_y0..belt_y1`) e nas botas (`boot_y`); a capa é cortada acima do joelho (`CAPE_CUT` 0,58 de 1,8) e fica 80% mais estreita (`CAPE_NARROW`), a casca de contorno (`hero_outline`) segue. Só o Guerreiro (`armor`, `painted(own, true)`); a Maga fica como estava. O espaço do vértice é em centímetros (esqueleto). Limite: os remendos de forro bege da capa não são verdes e não são cortados.

## GP-8: the painted rooms (2026-11-27, `--painted`, OFF until Daniel approves the art)

Code: `scripts/game/painted_hall.gd` (`PaintedHall`), `assets/shaders/painted.gdshader`, paintings `assets/rooms/painted/{sala01,sala00,antessala}.png`
(gpt-image-2 over game captures, sources and capture flags in `docs/art/painted_gpt/README.md`), tests `tests/test_painted_hall.gd`.
The first prototype (an old ChatGPT painting on proxy walls, 15 degree pitch) is gone: the new paintings are made at game cameras.
- How: after the room's look is built (hook: `ArenaRoom.build_steps` last step, `CatacombHall` last step) every visible solid mesh
  (masonry*, catacomb_floor*, depth_stone*, abyss_ruins, opaque Standard materials: banners, doors) gets the projecting shader
  through `VisualProfile.vary` (so it is the stylized look's stone; F7 brings the classic one back). The painting's UV 0..1 is the
  16:9 capture frame (the file is stretched to 3:2). Decals and the abyss fog/mist/glow and translucent cards (`HIDE_CARDS`) are hidden;
  lights, particles, water, hazards, the altar's lion stay. Two far planes (under the room, a wall beyond) carry the painting where no
  mesh is. A shut door's leaves and black inside wear the painting and get their own look when `HallDoor.is_open` (`_process`).
- Camera and collision are untouched: painters' yaw/pitch/fov are the game's (35/30/24); only distance (painted 68/52/80 m, the near
  camera is 37 m) and pan differ, which a pinhole camera tolerates on the floor and on walls (the geometry is the real one).
  Same seed, same `--smoke` RESULT.
- Switch: `--painted` on, `--painted=off` off, `PaintedHall.DEFAULT_ON` (false) ships it. Swapping a painting is replacing its png.
- Measured (CPU captures, `docs/gallery/gp8_gpt_2026-11-27/`): at the painter's pose it equals the painting; at the near camera with the
  hero walking it reads well (stone, banners, door, candles), the pillars bend a little (the painting's pillar is not the mesh's) and
  the painting is shown 1.5 to 2.3 times larger than its pixels (35 px/m painted, 69 px/m on screen), so it is soft: the shader
  sharpens a little (`sharpen`). A 2x upscale of the files would help. Forward+ only measured; Compatibility untested.


### GP-8 shipped (2026-11-27)
- `PaintedHall.DEFAULT_ON = true`: the Salão (all `hall` rooms: combat, fountain, shop), the Sala 00 and the Antessala show
  the gpt-image-2 paintings in the stylized look (F7 classic shows the old stone). `--painted=off` turns them off.
- `painted.gdshader`: `exposure` 0.9 with the dark-floor paintings (0.52 with the first bright ones); omni lights are clamped
  (`LIGHT_COLOR / PI`, max 1) before `torch_boost`, otherwise the hero light and braziers burned the painting white.
- Base captures for a repaint: `--doors-shut` keeps a room as before its doors open (no signs, leaves shut). Sala 01:
  `--start=fountain --doors-shut --showcase --cam-at=2,1 --cam-dist=68 --no-hud --no-angels --no-hero`; tell the generator
  to erase the fountain. Requests, poses and costs: `docs/art/painted_gpt/README.md`; agent `ai-art-producer`.
- Approved direction (Daniel): warm, bright, hand-painted like Hades II, NO banners. The Sala 00 and Antessala
  paintings in use are the first ("atual") ones, still with banners: to redo without them.
- 2026-11-27 Daniel chose the dark floor for all three (dark_v3: sala01-e3, sala00-e2, antessala-e2): floor mid-dark
  grey-green, warmth only in light pools, no banners. This is the approved look for every painted room from now on.

### GP-8 refinement (2026-11-27): what the painting has is shown once, gameplay sits where it is drawn
- Water: `shallow_water` is in `PaintedHall.HIDDEN` (the Salao's canal and pools, the Antessala's stream). The stream is a `GapFloor` that
  `Rooms` adds AFTER the build, so it was never dressed: `Rooms` now calls `PaintedHall.dress_late(stream)` (its water hides, its kerbs
  wear the painting).
- Flames and lights: `PaintedHall.PROPS` (per room: `at`, `radius`, `kinds` fire/light, optional `to`) hides or moves the 3D props the
  painting also has, only while it is on. Measured on `sala01-e3` (crosses at the 3D flames' base): the four Salao braziers
  (-8.2,-13.3), (-14.3,-3.6), (14.2,12.9), (14.2,2.7) fall within 2 px (0.06 m) of their painted flames and stay; the fifth, on the doors'
  wall's east pier (17,-14.8), is a wall in the painting, so its fire and light are hidden. Candle flames and halos were already hidden
  (`HIDE_CARDS`, their lights stay); the Sala 00 and Antessala have no 3D flames (their painted torches/candles are painted only).
- Gameplay moved to the painting (`tools/make_data.gd`, `-- stage`; the painter's drift measured with `PaintedHall.to_floor` over the
  painting's corners): Antessala stream z -8.3..-5.7 -> -10.7..-8.1, slab (-2.5,-18.5,5,3) -> (-2.6,-21.3,5.2,4.4), the eight posts
  (`ANTE_POSTS`, were x +-6 at z 19, 5, -12, -21); Sala 00 pillars (+-5,+-4) -> `SALA00_PILLARS`. Tests: `tests/test_painted_props.gd`.
- Still different: the Antessala painting keeps a few painted props (vases, a crate, a post stub) near the 3D breakables (the 3D ones break, the
  painted ones stay: ask the next repaint to erase them); the Sala 00's painted altar candles stay lit after the Blessing.
- CPU captures at the painter poses: `docs/gallery/gp8_refine_2026-11-27/` (one water, one flame per brazier, plate on the painted plate).
