# Crônicas de Eterra: A Selagem

Roguelite de ação em horda, 3D visto de cima (pegada de Hades 2 e Ember & Blade), em **Godot 4.7** (GDScript tipado, GL Compatibility). Spin-off e prelúdio do RPG
"Crônicas de Eterra": quatro paladinos descem às catacumbas sob a igreja velha de Valmor para selar Morvath.
Steam primeiro (Windows e Linux, mouse e teclado ou controle), Android depois.
Projetos irmãos: `../dungeon-rpg` (RPG original em JS, dono do cânone em `docs/mundo/`), `../cronicas-godot`
(RPG em Godot) e `../eterra-survivors` (Valmor Resiste, Phaser). **Não publicar nada no GitHub sem o Daniel pedir.**

## Regras
- **Entregar em versões MVP completas**: juntar várias mudanças numa versão jogável e só então pedir para o Daniel
  testar tudo de uma vez. Nada de pedir teste a cada ajuste pequeno.
- Código, nomes de arquivos e commits em inglês. Todo texto para o jogador em português do Brasil, **sem travessão**,
  e só em `data/text_pt.tres` (`T.t("chave")`). Nomes dos paladinos: marcadores `PALADIN_1` a `PALADIN_4` (o Daniel define).
- Yah é Deus e Elun é Jesus (alegoria cristã). A luz vem de Elun; não existem outros deuses. Tom de aventura, não de terror.
  Nunca inventar lore: ler `../dungeon-rpg/docs/mundo/canone.md` e perguntar ao Daniel.
- Trabalhar em marcos; terminar e testar um antes do outro; mostrar o jogo rodando ao fim de cada um.
- DRY e KISS, máximo de reuso. Lógica nova entra com teste (GUT).
- **Conteúdo é dado, não código.** Combos, dons, inimigos e ondas são Resources em `data/`. Um combo novo, um dom novo
  (com estatísticas que já existem) ou um inimigo novo (com um comportamento que já existe) não pode exigir código.
- A Steam exige declarar conteúdo gerado por IA: manter `docs/steam-ia.md` em dia.

## Equipe de agentes
A sessão principal é o Game Director / Tech Lead: planeja, delega, integra, valida e é a única que faz commit e push.
Subagentes em `.claude/agents/`: `art-director` (identidade visual, especificação e revisão), `environment-artist`
(cenário, materiais, luz), `gameplay-engineer` (combate, inimigos, salas, câmera de jogo, colisão, testes),
`ui-ux-designer` (HUD, menus, legibilidade), `qa-performance` (testes, medições, capturas reais, relatório em
`docs/qa/latest_report.md`), `game-director` (lê todas as evidências e revisões e mantém o backlog em `docs/backlog.md`: bugs e quickwins
primeiro, depois os próximos ciclos; roda ao fim de cada ciclo, não implementa). Cada arquivo tem um dono por tarefa; agentes em paralelo só com arquivos distintos (ou em
worktree). Tarefa pequena o Game Director faz direto. Protocolo completo: `docs/development/agent_workflow.md`.

## Comandos
- Godot: `~/tools/godot/godot` (4.7.2). Rodar o jogo: `~/tools/godot/godot --path .`
- Testes: `tools/test.sh` (GUT sem tela). Um arquivo só: `tools/test.sh -gtest=res://tests/test_combo.gd`
- **Captura na placa de vídeo (preferir)**: `tools/gpu.sh shot saida.png --bot --shot-at=9` (cerca de 30 s, Forward+ na RTX 5060
  do Daniel pela Godot de Windows em `C:\Users\danie\tools\godot`, com o projeto espelhado em `C:\Users\danie\tools\eterra-gpu`;
  abre uma janela na tela dele). O WSL não tem Vulkan da GPU (cai no llvmpipe, 2 a 4 min por captura); OpenGL na GPU
  funciona com `MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA GALLIUM_DRIVER=d3d12 LD_LIBRARY_PATH=/usr/lib/wsl/lib` e `--rendering-driver opengl3`.
- Captura sem tela (CPU, lenta): `tools/shot.sh saida.png 3 --bot` (segundos antes da captura; o resto são opções do jogo).
- Opções de teste (depois de `--`): `--bot` (joga sozinho), `--fast=N` (o relógio da partida corre N vezes mais rápido),
  `--start=boss|miniboss|shop|fountain` (sala onde começar), `--showcase` (câmera fixa no enquadramento da imagem de referência; `--cam-yaw`, `--cam-pitch`, `--cam-dist`, `--cam-fov` ajustam), `--horde` (o modo antigo de horda contínua, com `--start=boss|elite1|elite2`), `--shot=arquivo.png`, `--shot-at=segundos`, `--frames=prefixo --count=N --every=s`, `--nosave`, `--smoke` (partida sem tela, imprime `RESULT`), `--runlog[=arquivo]` (grava
  a partida no registro mesmo com o robô ou `--nosave`; sem arquivo, em `user://runs.jsonl`).
- Depois de criar arquivos ou classes novas (`class_name`): `~/tools/godot/godot --headless --path . --import`.
- Regerar os dados (combos, inimigos, dons, ondas, salas, chefes, sensação): `~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [bosses] [feel]`.
  Editar os números em `tools/make_data.gd` (fonte da verdade) e regerar; não editar os `.tres` à mão.
- Achar erros de script sem rodar: `~/tools/godot/godot --headless --path . -s tools/check.gd`.
- Partida sem tela com o robô (rápida, para ritmo e regressão): `tools/smoke.sh 300` (partida inteira) ou `tools/smoke.sh 120 --start=boss --boons=25`.
  Outras opções: `--boons=N` (N dons sorteados), `--boss-hp=0.2`, `--hero-hp=N` (vida do paladino), `--stress=300`, `--title --screen=options|moves|howto`, `--hold`,
  `--autopick` (pega o primeiro dom sem abrir a tela, bom para capturas).
- Build: `~/tools/godot/godot --headless --path . --export-release "Windows Desktop" build/windows/ASelagem.exe`
  (e `"Linux"` em `build/linux/ASelagem.x86_64`). Web para ver no navegador: `tools/web.sh` e abrir `http://localhost:8070`.
  Android fica para depois (sem preset ainda).

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
  arte são de Eterra. Comparação sistema por sistema e o que falta: `docs/design/comparativo.md` (manter em dia). A versão 2D em pixel art está na tag `v1-pixel-2d`.
- Modelos **provisórios**: KayKit (Kay Lousberg, CC0) em `assets/models/` (personagens, masmorra, armas).
  Fontes Cinzel e Alegreya Sans (OFL) em `assets/fonts/`.
- Proporção: o KayKit é cabeçudo; `scripts/render/slender.gd` (`Slender`) afina o boneco depois da animação (cabeça
  menor, pernas e tronco mais longos), só no assado dos bonecos do KayKit guardados (os modelos do Meshy já têm a proporção certa).
- Câmera da imagem de referência, medida nela: girada 35° (`Feel.cam_yaw`; a sala vira o losango da pintura),
  inclinação 30, campo de visão 24, distância 54 no jogo (ciclo 5, para o herói ler maior; a vitrine `--showcase` fica em 60) (`_feel` do `make_data.gd`). Teclado e controle giram junto
  (`Feel.screen_to_floor`). `--showcase`: câmera fixa no enquadramento da pintura, para comparar.
  Enquadramento (`CamFrame`, `core/cam_frame.gd`): o ponto que a câmera olha fica dentro das margens da sala (`Game.CAM_MARGIN`,
  `CAM_SOUTH`, medidas a 60 m e escaladas pela distância), mas o herói nunca fica a menos de 18% de uma borda da tela
  (`CamFrame.SAFE`, `keep`): no patamar oeste a câmera segue ele além das margens.
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
  finalizador e Ômega, `Combat.number_color`), estocadas em feixe fino (`emeth_thrust.gdshader`), o especial como dardo
  esmeralda (`emeth_dart.gdshader`), o círculo de luz como aro fino com marcas girando; inimigo pisca abaixo do limiar do glow e achata, corpo arremessado ao morrer
  (`Horde.THROW`), tranco de câmera (`Fx.kick`), hit stop curto (`Feel.hit_stop_scale`) e brilho de antecipação nos finalizadores
  (`ComboNode.glint`, 0,08 s em todo finalizador, `FINISHER_GLINT` no `make_data.gd`, desenhado por `Fx.glint` na ponta da
  espada; ciclo 10: antes o dado era zero). Finalizadores soltam a meia-lua enorme (`Fx.crescent`). Quadro de impacto em preto e
  branco (`Fx.impact_frame`; ciclo 10, decisão D-08): só no Ômega que acerta e no golpe que derruba uma fase do chefe (ou o
  derruba), no máximo um a cada 10 s (`Feel.impact_frame_every`, `Combat.wants_impact_frame`, `breaks_phase`), e nunca com a
  opção `impact_frames` do save desligada (`SaveData`, padrão ligada; `Game.apply_options` passa para `Fx.impact_frames`; a tela
  da opção é do ui-ux-designer, texto `opt_impact_frames`). Multidão cinza clara sobre o chão escuro, que brilha um pouco sozinha para ser lida longe da luz (`CrowdRenderer.CROWD_*`, `lift` e `flat_light` no `crowd.gdshader`); cortes em faixa larga (`Fx.SLASH_INNER`); elites com contorno escuro e fino
  (`crowd_outline.gdshader`, `CrowdRenderer.OUTLINE_*`; largura em metros do mundo) e borda de ouro velho fraca (`ELITE_RIM`); o ouro das elites é velho (`CrowdRenderer.GILD_COLOR`), nunca amarelo vivo. Detalhes e pendências em `docs/arte/estetica.md`.
  Ciclo 8: o inimigo atingido é o próprio corpo mais claro e morno (`flash_light`, `flash_warm` no `crowd.gdshader`), o que o
  pisca soma para em `flash_cap` 1,0 (abaixo do limiar do glow, nada de bola branca sobre o herói); só o 1º quadro de um golpe
  forte vai um pouco para o marfim (`white_from` 0,85, `flash_white` 0,35). Fita do corte mais estreita, lado de dentro mais
  suave (`widest`, `inner_light` no `slash.gdshader`). Ataque, especial e Ômega se distinguem: estocada comum com fio pálido;
  Ômega com fio mais largo e branco e os dois veios de ouro velho nas bordas (`omega` no `emeth_thrust.gdshader`,
  `Fx.thrust(..., omega)`) e talho cruzado; o dardo do especial com o miolo de ouro (`vein_*` no `emeth_dart.gdshader`) e
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
  Brilho pelo glow do `WorldEnvironment` (cores acima de 1 brilham).

## Primeira fase no molde do Hades II (2026-11-14)
- A partida é por salas, com a estrutura e os números da primeira região do Hades II (estudo dos dados do jogo do
  Daniel; nada de arte, nome, história ou som copiado). Notas do estudo: fora do repositório (scratchpad da sessão).
- Escala: 80 unidades do Hades = 1 m (andar 540 = 6,75 m/s; heroína de 200 de altura = paladino de 2,5 m). `U` em `make_data.gd`.
- Salas: `RunMap` (`core/run_map.gd`: abertura com dom, portas que mostram a recompensa, guardião entre as salas 4 e 6,
  uma fonte entre 5 e 8, loja na 10, Morvath na 11; **encurtado para teste**: fonte na 2, guardião na 3, loja na 4, Morvath na 5, elites desde a sala 2 (`elite_from_depth`; no Hades, 3), `_stage` em `make_data.gd`), `EncounterGen` (`core/encounter_gen.gd`: dificuldade 55 + 15 por sala,
  1 a 3 ondas, no máximo 1 tipo de elite, próxima onda com 1 inimigo de pé), dados
  em `data/stages/catacombs.tres` (`StageDef`, `EncounterPool`, `RoomLayout`).
  **Poucos inimigos, cada um com seu papel** (ciclo 8; o Daniel, 2026-11-15: não é survivor de horda, a referência é o
  Hades II): de pé ao mesmo tempo, comum 4 a 8, difícil 8 a 12 (guardião e elites), especial 12 a 16, teto absoluto 20
  contando invocações (`StageDef.tier_alive`, `alive_cap`; `Horde.alive_cap` e `room_for` cortam a invocação do Ancião
  e de Morvath); Morvath com até 4 invocados de pé fora do ritual e 6 no ritual (`BossDef.adds_cap`, `ritual_cap`, `BossRules.summon_count`). O limite de
  cada sala vai do mínimo ao máximo da faixa ao longo da região (`EncounterGen.cap`, `progress`); cada onda cabe na faixa
  (sobra vira outra onda). Composição por papel (`EnemyDef.role`: pressure esqueleto, react corredor, control feiticeiro,
  flank besteiro, block Escudo, area sacerdote) em conjuntos `EncounterPool` no `_stage` do `make_data.gd`: começo da
  região 2 papéis, meio 3 que se completam, fim misturas exigentes com elites e uma especial rara de 4. `--horde` e
  `--stress` ignoram os tetos. O RESULT do `--smoke` traz `max_alive` (pico de inimigos de pé, chefe incluído), `boss_at` e o custo do passo da simulação medido só nos quadros com inimigos de pé, `step_ms_avg` e `step_ms_peak` (`StepTimer`, `core/step_timer.gd`; `step_ms` continua, suavizado e lido no fim). Nó `Rooms` (`game/rooms.gd`) conduz: ondas, recompensa,
  portas, fonte, loja (pisar compra), chefe. Magia enche em toda sala; sem experiência nem níveis.
- Golpes do Hades: ataque em 3 (20, 25, 60 em volta), especial = seta (40), Ômega do ataque segurando 0,8 s (160, para
  frente e para trás, 20 de Magia), Ômega do especial 0,65 s (80, 10 de Magia), avanço 0,2 s / 5,6 m com 16 quadros de
  proteção e 1 carga, círculo em volta do paladino (5,4 m, 3 s, um por vez). Vida 30, 1,3 s de proteção após um golpe.
- Inimigos com os números de Érebo: cada um tem a versão elite (`_elite`, armadura do Hades). Guardiões: `knight` e `priest_elder`.
- Aparência dos inimigos pela prancha do Daniel "Inimigos da Fase 1" (`docs/art/enemies_phase1.md`; imagem só local em
  `docs/art/ref/`): **os nove são os modelos do Meshy** aprovados pelo Daniel (2026-11-15; `assets/models/meshy/enemy_<id>/`,
  esqueleto de 24 ossos, `-rigged.glb`; tom da 3ª versão do Sacerdote: caveira de marfim, roxo apagado, metal escuro, brilho só
  nos olhos e gemas). `tools/bake.gd` (`MODELS`, entrada com `"meshy"`) faz tudo: reduz a malha de 15,5 mil para cerca de 3,9 mil
  triângulos e repassa a pintura para um atlas novo de 1024 (`MeshSlim`, `scripts/render/mesh_slim.gd`), transfere clipes da
  Quaternius e do KayKit pelo `Retarget`, prende as armas do KayKit que o modelo não tem (`held`: lâmina, cajado, besta, escudo
  do Cavaleiro; o Escudo já traz as dele), põe os pés no chão e a altura da prancha (`height`). A textura vai dentro do `.res`
  (`BakedModel.painted`). Cor da magia em `EnemyDef.magic_color` (feiticeiro violeta frio, sacerdotes roxo; a necromancia de Morvath é o verde
  espectral frio do pedido do Daniel de 2026-11-15, `SPECTRAL`, mais azulado e pálido que o verde cristalino da Emeth); olhos, gemas e orbes brilham pela própria pintura (`paint_glow` no `crowd.gdshader`).
  **Elites sem créditos**: a mesma figura com o aço em ouro velho por shader (`EnemyDef.gild`, `ELITE_GILD` no `make_data.gd`,
  `gild` no `crowd.gdshader`), contorno escuro fino, borda fraca e barra de armadura; uma repintura no Meshy (10 créditos cada)
  ficaria melhor e depende do Daniel. Galeria: `tools/enemy_lab.gd` (ids opcionais para ver de perto).
  Ciclo 7 (papel de cada um pela silhueta, arma e pose, não só pela cor): avisos de preparo por `EnemyDef.tell` num MultiMesh só
  (`EnemyFx`, `enemy_tell.gdshader`, lidos de `Enemy.state_t`), campos de aparência `vivid`, `crest`, `shine`, `sway`; peças
  rígidas no assado (`rigid` em `tools/bake.gd`: escudo preso ao antebraço do Escudo); ouro da elite só no aço; armadura com
  centelhas ao absorver e estilhaços ao quebrar; Morvath violeta com coroa pálida.
  Ciclo 8: os avisos de preparo crescem até pouco antes do golpe e somem quando ele sai (`EnemyFx.ramp`): brilho em cruz da
  lâmina, virote puxado com um traço claro na direção da mira, borda do escudo desde 30% do preparo e poeira nos pés; um
  golpe inclina o corpo para trás por um instante (`Horde.RECOIL_TILT`, nada quando a armadura absorve).
  Os bonecos do KayKit e as paletas (`tools/make_palettes.gd`, `assets/models/palettes/`) ficam guardados, sem uso:
  `tools/bake.gd -- kaykit [ids]` volta a assá-los. Prompts e repinturas em `tools/meshy/prompts.json`.

## Tela de título (2026-11-15)
- A arte cinematográfica aprovada pelo Daniel (`assets/ui/title/title_screen_reference.png`, feita por IA; quatro heróis,
  fortaleza, portal, logotipo pintado) é o fundo, contida sem corte (`TitleBackdrop`, `scripts/ui/title_backdrop.gd`; faixas
  desfocadas nas outras proporções; névoa, brasas e partículas do portal que não tocam rosto, lâmina nem logotipo). Os botões
  pintados foram apagados numa cópia limpa (`title_bg.png`, `tools/make_title_bg.sh`) e os reais (`TitleMenu`, `TitleButton`,
  vetor, Alegreya Sans Bold) ficam exatamente por cima, na escala da arte. Medidas: `docs/art/title_screen_spec.md`.
- `scripts/boot.gd` compõe: Iniciar entra na partida (o único fluxo), Como Jogar (`HowToScreen`, teclas reais lidas do mapa,
  com a lista de Golpes dentro), Configurações (`OptionsScreen`), Sair só no desktop. Fluxo testado por
  `tools/title_flow_check.gd` (teclado, sem tela). Os outros três heróis da arte ainda não têm nome nem papel no jogo.

## Arquitetura
- `scripts/core/`: lógica pura (sem nós), toda testada. `scripts/game/`: nós da partida. `scripts/ui/`: telas.
  `scripts/render/`: modelos assados e a multidão.
- A simulação é no plano do chão: posições `Vector2(x, z)` em metros; o desenho é 3D.
- `scripts/game/game.gd` é dono do relógio: chama `step(dt)` de cada sistema. Hit stop, pausa e a escolha de dom são
  só "não chamar step". Cada sistema que emite sinal dentro do laço (golpe que mata o paladino limpa tudo) precisa
  aguentar a lista mudar no meio (ver `Ground.step`, `Projectiles.step`).
- **Multidão**: inimigos são objetos leves em `Horde`; o desenho é `CrowdRenderer` (cada tipo consultado uma vez em `register`: `Kind`, `Clip`; `add_kind` no laço; só os lotes usados são mexidos), um MultiMesh por (inimigo, animação,
  quadro). As poses vêm assadas: `tools/bake.gd` esqueleta os modelos (Meshy; os do KayKit ficaram em `KAYKIT`) em malhas estáticas
  (`assets/baked/*.res`, `BakedModel`). Modelo ou animação nova de inimigo: editar `MODELS` em `tools/bake.gd` e rodar
  `~/tools/godot/godot --headless --path . -s tools/bake.gd [-- ids]` (o Godot do editor: o atlas novo usa o xatlas). A multidão fica fora da luz das tochas (camada 2)
  e recebe a luz do paladino pelo global `hero_pos`.
- O herói é o Explorador do Meshy (2026-11-15, da folha aprovada; `assets/models/meshy/hero_explorer/hero_explorer-rigged.glb`,
  24 ossos, os mesmos da antiga "Sombra", pose em A), montado por `HeroBody` (`scripts/render/hero_body.gd`, também usado na
  galeria de inimigos), desenhado com 2,75 m (`HeroBody.HEIGHT`; o combate continua com 2,5). A "Sombra" repintada
  (`tools/recolor_hero.gd`, `HeroGear`) ficou guardada, sem uso. As animações dele são próprias
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
  (`Magick`, `ComboNode.magick_cost`, `In.CHARGE_LIGHT`/`In.CHARGE`, `Player.CAST_OMEGA_COST`); Magia volta por abate
  (`Game.MAGICK_PER_KILL`). Círculo: zona `Ground.Kind.BIND` que prende (chefe só fica lento); o Ômega explode no fim
  (`Combat.cast_burst`). Armadura (`EnemyDef.armor`, barra amarela): absorve os golpes, ao quebrar atordoa
  (`Horde.armor_broken`; Morvath se rearma depois do atordoamento).
- Entrada só por ações (`Controls`): `light_attack`, `heavy_attack`, `dodge`, `cast`, mira (`Controls.aim`). Nunca ler tecla direto.
  Toque e robô usam `Controls.VirtualPad`. Toques durante o hit stop ficam guardados (`Controls.flush`).
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`). Sem save (`--nosave`) não há recorde
  (`SaveData.record_win_time`). Os testes nunca gravam o save nem o registro (`tests/hooks/pre_run.gd`, `pre_run_script` no
  `.gutconfig.json`; `tools/title_flow_check.gd` também desliga).
- Registro das partidas de gente (ciclo 10, QW-001): `user://runs.jsonl`, uma linha JSON por partida (vitória, morte ou saída,
  `Game.log_run`, uma vez só; sair no meio grava `quit` no `_exit_tree`) com o dicionário do `RESULT`, os dons na ordem
  (`gifts`: id, nível, raridade), o controle (`device`: keyboard, gamepad, both; `Controls.seen_keys`/`seen_pad`), `omegas`,
  `dodges`, o que feriu por último (`last_hurt`) e, na morte, `defeated_by` (chave de texto). Nada sai do computador; o robô e
  `--nosave` não gravam. Formato em `core/run_log.gd` (`RunLog`), sinal `Game.run_logged(outcome, entry)`.
- "Derrotado por" (ciclo 10, QW-003, lógica): todo aviso e tiro de inimigo leva o tipo de quem o fez (`Ground.Zone.by`,
  `Projectiles.Shot.by`, preenchidos por `Horde.acting` durante o passo da multidão; o golpe direto por `Horde.last_by`);
  `Game.last_hurt` guarda `{attack, enemy}` do último golpe que tirou vida e `Game.defeated_by()` devolve a chave de texto
  (`DefeatCause`, `core/defeat_cause.gd`): `killer_<ataque>` para os ataques de Morvath (Foice Sepulcral, Lâminas das Almas,
  Tempestade das Seis Almas, Erupções Sepulcrais, Erupções do Ritual, Maldição de Morvath, Investida de Morvath), senão o
  `name_key` do inimigo, senão `killer_unknown`; rótulo `defeated_by` ("Derrotado por: {name}"). A tela é do ui-ux-designer.
- Som: `scripts/audio.gd` (receitas sintetizadas, provisórias). Um arquivo `audio/<nome>.ogg` substitui a receita;
  `audio/<nome>_0.ogg`, `_1.ogg`... sorteia entre eles. Golpes, ossos, escudo e atordoamento usam o Kenney Impact Sounds (CC0).
  Música desligada por enquanto.

## Onde mexer
- **Elo** (mecânica das Crônicas de Eterra) = dom duplo do Hades: família `DUO` em `scripts/core/boon.gd`, dom com
  `requires` de dois outros (6 hoje; nome "Elo" no texto desde 2026-11-15). A carta mostra os dois dons de origem
  numa corrente de ouro velho com o Elo no meio (`EloLink`, `BoonState.sources`), o medalhão do Elo tem aro de elos,
  a HUD saúda cada Elo novo com "Elo formado" sem pausar (`EloBanner`) e a pausa tem o painel "Dons" (`BoonsScreen`).
  Capturas dessas telas numa partida real: `tools/ui_lab.gd` (comando no topo).
- Combos: `data/combos/paladin.tres` (nós `ComboNode`; `tags` é o que os dons enxergam; os seguintes em `next`, um
  `Array[Resource]`, lidos tipados por `following()`: o `Array[ComboNode]` dentro da própria classe vazava o script na saída,
  as linhas "ObjectDB instances were leaked" e "resources still in use" de toda execução, ciclo 10). Dons: `data/boons/*.tres`
  (`Boon.slot`: um dom por ação, ATTACK/SPECIAL/CAST/DASH, o novo substitui o antigo; NONE = age sozinho, sem limite.
  Raridade sorteada por carta, `Boon.RARITY_MULT` multiplica os números com `BoonMod.by_rarity`)
  (`BoonMod`: `stat`, `tag`, `values` por nível; as estatísticas que o jogo conhece estão em `scripts/game/combat.gd` e
  `game.gd` `_take`). Inimigos: `data/enemies/*.tres`. Ondas, elites, fonte e chefe: `data/waves/catacombs.tres`.
- **Morvath, a luta em 4 fases** (pedido do Daniel de 2026-11-15; desenho em `docs/design/morvath_boss_fight.md`): todos os
  números em `data/bosses/morvath.tres` (`BossDef`, gerado por `_bosses` no `make_data.gd`, parte `bosses`); a escolha do
  ataque é do `BossDirector` (`core/boss_director.gd`: fase, distância, paladino parado, recargas, sem repetir, nunca vazio,
  `BossAttack` por ataque); fases, padrões, ritual e teto de invocados em `BossRules`; estados e desenho em `scripts/game/boss.gd`.
  A vida para em cada limiar (`Enemy.hp_floor`): 1 "O Despertar" (100 a 66%: Foice Sepulcral em meio círculo de 5 m, Lâminas
  das Almas, investida), 2 "O Ritual dos Mortos" (66%: vai ao meio, escudo, invulnerável só no ritual, 2 esqueletos e 2
  feiticeiros, até 6, no máximo 20 s ou até esses 4 caírem: os reforços que sobem a cada 6 s pressionam mas não contam, ciclo 10,
  BUG-002; contagem para a barra em `Boss.ritual_left()`, `ritual_total()` e o sinal `ritual_changed(left, total)`; com
  `--boss-hp` na fase 2 o ritual roda; Erupções Sepulcrais; depois invocações ocasionais), 3 "A Maldição dos
  Condenados" (33%: projétil que persegue pouco; maldição de 3 s no paladino, `CurseState`/`Player.apply_curse`: 30% mais
  lento e especial travado, 2 s de imunidade), 4 "O Último Suspiro" (15%: portal verde espectral, Tempestade das Seis Almas
  em duas ondas, descansos menores). Meias-luas: `Projectiles.Kind.SOUL` (`soul_crescent.gdshader`, acerta uma vez), maldição
  `Kind.CURSE`. Cenário da luta (ciclo 9): escudo do ritual de vidro espectral `BossShield` (`boss_shield.gdshader`, círculo de
  runas no chão, partículas em órbita; `Boss` controla pelo `power` do material e passando de 1 ele se parte em cacos);
  erupções e invocações são círculos rituais cuja borda é exatamente a área (`Ground.rune_burst`, `Ground.Rune`,
  `ritual_rune.gdshader`): runas fracas que acendem, pulso duplo, coluna espectral (`spectral_column.gdshader`) e as runas
  se desfazendo; o aviso com `Zone.eruption` vira círculo sozinho; a runa de invocação (`Rune.SUMMON`, sem dano) marca o
  tempo em que cada morto se ergue e a coluna dela é a única do erguer; cancelada (`clear_warnings`, `end_zone`) some sem
  coluna. Fase 4: portal inquieto (`Arena.final_phase`, `PortalOmen`, `unrest` no `portal.gdshader`, partículas no ar).
  Vitória: selagem do portal (`Arena.seal_portal`, 2,4 s, `Boss.VICTORY_SEAL`, terminando em `VICTORY_CALM`, antes da tela).
  Obeliscos abrem em pontilhado em volta do herói atrás deles (`see_through` no `masonry.gdshader`, código comum em
  `see_through.gdshaderinc`; C12a: as velas da frente da Câmara do Selo também, `Masonry.candle(..., open)`, `see_open`,
  `candle_wax_see.gdshader`, `flame_see.gdshader`). C12a na câmara: faixas da tempestade translúcidas (`GroundLook.STORM_*`:
  preenchimento 0,09, aro a 0,75 abaixo de 1, nada perto da raiz até 5 m, `root_rim`, `light_cap`) e o miolo do selo
  escurece enquanto elas estão no chão (`BossChamber.STORM_DARK`); fio violeta dos avisos separado do aro por 2 px
  (`thread_gap_px`); estrela da vitória abaixo do limiar (`seal_converge_light`, `seal_heart_light`); janelinhas em pares
  e nenhuma na bruma oeste (`FAR_WINDOW_PAIR`, `FAR_WINDOW_HIDDEN`); tampa e friso dos sarcófagos mais claros
  (`SARC_LID_LIGHT`, `SARC_FRIEZE`); espada dos estandartes no meio do pano com borda escura (`ArenaKit.BANNER_SWORD_*`);
  névoa volumétrica e SSR só ligadas no Forward+ (`_build_world`; sem aviso no log do Compatibility). HUD (ciclo 9): na barra
  (`HudBar.show_boss`) as marcas de fase ficam escuras à frente da vida e viram ouro velho com losango quando passadas, a
  recém-atingida pisca (`MARK_FLASH`); o nome da fase aparece por 3 s embaixo da barra (`Hud.show_phase`: o `show_notice` da
  fase vai para lá, nome até o primeiro ponto, dica embaixo); escudo do ritual = moldura na cor dele, véu fino e faixas
  inclinadas correndo (`SHIELD_*`); ciclo 10: no meio da barra um losango por morto do ritual (`HudBar.show_ritual`, de
  `Boss.ritual_left`/`ritual_total`; de pé, a cor do escudo dentro de ouro velho; caído, escuro e vazado, com um lampejo) e,
  depois do nome da fase, "Derrube os mortos" embaixo enquanto o escudo está de pé. Maldição no herói: runas pequenas girando na cintura e névoa violeta no chão (`CurseAura`,
  `curse_aura.gdshader`, abaixo do glow), borda violeta no corpo, veios violeta subindo pela lâmina da Emeth
  (`EmethSword.set_corrupt`, `corrupt` no `emeth.gdshader`), um sopro de partículas só quando pega. No HUD: selo
  `ConditionBadge` junto ao medalhão (anel que esvazia, "Amaldiçoado" e "Mais lento e sem especial"), aro do medalhão
  violeta, losango do especial com véu violeta, cadeado e fio que encolhe (`ActionSlot.locked`), anel de luz quando volta.
  Golpe sofrido (ciclo 10, BUG-007): nada de tela inteira vermelha; só as bordas, por 0,22 s, alfa até 0,42 nos cantos (metade abaixo de
  10 de dano), separação de cores pequena só nos fortes; amaldiçoado (ou pelo projétil da maldição), borda violeta da aura com
  alfa 0,2 por 0,2 s e sem separação (`HurtTint`, `core/hurt_tint.gd`; números no grupo Hurt do `Feel`, `_feel` do
  `make_data.gd`; `hurt`, `curse` e `hurt_edge` no `screen.gdshader`). Derrota: "Derrotado por: X" logo abaixo do título
  (`EndScreen`, `stats.defeated_by`). "Novo melhor tempo!" nunca sem save (`EndScreen.open` confere `Save.enabled`).
  Configurações: grupo "Conforto" com tremor, clarões de impacto, câmera lenta (com zoom e desfoque) e separação de cores, todos
  ligados por padrão (`OptionsScreen.COMFORT`, `Fx.slow_motion`, `Fx.color_split`, `Game.apply_options`); fluxo por teclas
  em `tools/title_flow_check.gd`, testes em `tests/test_comfort_ui.gd`. Capturas: `--shot-on=hurt|hurt-cursed|end|ritual-left:N`.
  Vitória (`EndScreen`, depois da selagem): título, "O poder de Morvath foi contido.", os dons levados, tempo, abates,
  sequência, ouro, "Continuar" (título, com foco) e "Descer de novo". Testes em `tests/test_boss.gd` (saídas sempre
  possíveis, diretor, ritual, maldição e a luta numa cena real). Capturas: `--boss-only=<ataque>`,
  `--shot-on=boss:<momento>` (`Boss.moment`), galeria em `docs/gallery/morvath/`. `RESULT` traz `boss` (`Game.boss_stats`).
  **Ciclo 9 (frente A, refinamento; detalhes na seção 0 do documento)**: paleta do chefe em `Boss` (`VIOLET`, `SPECTRAL`,
  `CORRUPT`); todo efeito cobre só a área que fere. Foice: clipe `slash3` esticado no preparo, `Fx.boss_scythe`
  (`boss_scythe.gdshader`) no setor exato, cinzas, recuperação. Meias-luas com núcleo, fumaça violeta, rastro curto do
  tamanho do alcance (`boss_wake.gdshader`) e dissipação, colisão igual. Investida: preparo, faixa revelada
  (`Fx.boss_dash`), impacto dentro da faixa. Toda recuperação é uma janela (`State.RECOVER`, `stats.windows`/`punished`).
  Fases abrem no próprio padrão (`BossDef.phase_openers`), sem quadro branco. Reforços um por vez com runa
  (`Ground.Rune.SUMMON`, `rise_stagger`, teto 6 vivos e 20 na luta, `BossRules.reinforce_room`). Paladino amaldiçoado: avisos
  mais longos na mesma proporção (`BossRules.cursed_windup`). Fase 4: meias-luas uma por vez (`storm_stagger`,
  `storm_order`), combinações (`BossAttack.then`, `chain_ready`), luz do portal pulsando entre o verde espectral e o violeta
  (`_step_final`, por cima do portal inquieto), borda corrompida. Vitória curta
  (`Boss.VICTORY_TIME` 3,6 s, com controle; ciclo 10: sem pisca no golpe final nem na queda, `Horde.death_flash`, e o corpo
  escurece a pedra violeta, `Boss.VICTORY_DIM` 0,55 e `VICTORY_GREY` 0,5 sobre o `tint` e o `desaturate` do material): o poder dele volta ao altar e ao portal (que se sela, `seal_portal`), a Emeth brilha (`Fx.blade_glow`),
  `Game.victory_started`/`victory_finished(stats)`, depois `await _play_ending(at)` e `_open_end` (a tela de fim). Golpe no
  escudo (alvo invulnerável) só faísca: sem flash, número, combo, fogo ou gelo (`Combat.hit_enemy`, `WARD_SPARK*`). Para as frentes de arte: `Boss.cue(nome, onde,
  direção, tamanho, segundos)`. Simulações: `--boon-ids=a,b,c`, `--bot-reaction=0.25`, `--bot-kite=0.2` (o robô
  passa essa fração de cada 10 s da luta longe do chefe, a mais de 11 m, correndo, e atira o especial de lá: a investida aparece,
  ciclo 10, `Bot.kiting`); métricas por ataque no `RESULT`
  (`hurt_by`, `hits_by`, `phase_time`, `died_phase`). Testes novos em `tests/test_boss_refine.gd`.
- **Câmara do Selo** (ciclo C11, a arena de Morvath; raio e contas em `docs/design/boss_arena.md`, arte em
  `docs/art/boss_chamber_spec.md`): o `StageDef.boss_layout` é um `RoomLayout` com `chamber` e `floor` (`FloorShape`,
  `core/floor_shape.gd`: retângulo ou círculo, `contains`, `clamp`, `edge_distance`, `cut`), círculo de 12,5 m (o herói anda
  até 12), herói nasce em (-0,9; 10,4), Morvath em (0; -1,2) sobre o selo; as salas comuns continuam no salão. `Arena.shape()`
  é o chão de qualquer sala (o salão vira o retângulo menos `Arena.WALL`); `resolve`, `inside` e a esquiva seguem o círculo,
  sem limite invisível. `Arena._build_boss_room` monta os dados e `_chamber_look` o visual: o `BossChamber`
  (`scripts/game/boss_chamber.gd`, plano da spec em constantes; `build(arena, layout, seed)`), que recebe `open_door`,
  `final_phase` e `seal_portal` pelo `Arena.chamber` e os `Boss.cue` pelo `on_cue` (ligado em `Boss.setup`). Cenografia:
  selo de ouro velho com o leão rampante em relevo (campo de distância `assets/textures/seal/lion_sdf.res`, do `lion.svg`
  por `tools/make_seal_lion.gd`) e a rachadura violeta que cresce por fase, desenhados no próprio chão
  (`chamber_floor.gdshader` = o corpo do chão do salão, `catacomb_floor.gdshaderinc`, com `#define CHAMBER` e
  `chamber_seal.gdshaderinc`); cinco estados no tempo por `SealLook` (`core/seal_look.gd`: repouso, preparo do ritual,
  ritual, fase final com veios pelas juntas, vitória), quebra do escudo entre eles; balaustrada com velas, lanternas
  violeta, pilaretes e sarcófagos com a espada erguida, fachada com a porta selada (`chamber_door.gdshader`, costura
  que pulsa na fase 4 e se fecha na selagem), estandartes com a espada (`ArenaKit.banner(..., emblem)`), escada sul com o
  véu de runas (`chamber_veil.gdshader`), muralha de arcos, torre, correntes, anel de arcadas, ar próprio
  (`BossChamber.dress`; guardado em `air_of` e devolvido ao salão quando a câmara sai, `restore_air` no `_exit_tree`,
  testado em `test_boss_chamber.gd`). Polimento C11: céu azul-marinho (cartões das agulhas em silhueta `SPIRE_*`, luz
  azul `BLUE_ENERGY` 1,2), colunas altas de névoa violeta nos lados do abismo (`COLUMNS`), correntes grossas da torre e
  da fachada até as arcadas que cruzam a faixa de cima da câmera do jogo (`CHAINS`, `CHAIN_SIZE`), pontas da estrela
  mais largas com chapa de bronze e espinha de ouro (`seal_point*` no `chamber_seal.gdshaderinc`, só albedo), sarcófagos
  maiores (`SARC_*`, velas do nicho em `NICHE_CANDLES`), veios da fase 4 orgânicos (raízes de ruído torcido, violeta com
  miolo esmeralda corrompido escuro e mancha roxa na pedra, `vein_*`), não mais pelas juntas. O desfazer da morte de
  qualquer inimigo (`state.a` no `crowd.gdshader`) só arde nas partículas que vão sumir, em ouro velho abaixo do glow
  (`dissolve_color`, `dissolve_band`): antes o corpo inteiro brilhava laranja 3,2 e Morvath caído virava uma mancha
  amarela sobre o selo. Nada fica dentro do círculo de 12,5 m (testado por vértice em `tests/test_chamber_look.gd`);
  o arco da frente abre em pontilhado em volta do herói e de Morvath (`see_through` com `boss_pos`). Laboratório:
  `tools/chamber_lab.gd` (comando no topo; `--state=`, `--phase=`, `--hero`, `--boss`, `--showcase`, `--hall`,
  `--measure=`). Capturas: `docs/gallery/boss_arena/work/chamber_*.jpg`. Correções antes do teste do Daniel
  (`work/fix_*`): o par de sarcófagos na metade da borda perto da câmera (`NEAR_HALF`, o leste) recua 0,9 m com o nicho,
  baixo como na spec (`NEAR_SARC`) e com a pedra em pontilhado em volta do herói (`_see_through`), e as velas do arco da
  frente ficam encostadas nos balaústres e mais baixas (`CANDLE_FRONT_R`, `CANDLE_FRONT_MAX` 0,28): o herói na borda não
  parece mais em pé sobre a tampa nem sobre as velas; pilaretes da frente com furo menor e mais pedra (`PINNACLE_SEE`)
  para continuarem lá atrás dele; a espada erguida (sarcófagos, pilaretes, porta: `_sword`, `SWORD_*`; estandartes:
  `ArenaKit.BANNER_SWORD_WIDTH`) com lâmina larga afinando até a ponta, guarda curta e fina, punho fino e pomo, nunca cruz;
  a rachadura fecha a partir de `SealLook.HEAL_FROM` (veios de volta, 2,3 s) e some por inteiro antes da calma
  (`tests/test_seal_victory.gd`). Queimadura (M-1): o tique de fogo não pisca o corpo (`Horde.damage(..., flash = false)`),
  o contorno de elites e de Morvath não vai mais a branco 3,0 no pisca (`flash_color` no `crowd_outline.gdshader`; no
  manto aberto de Morvath o contorno de trás aparecia em manchas brancas) e a borda de fogo substitui a borda fria e a da
  coroa enquanto queima (`crowd.gdshader`); testes em `tests/test_burn_flash.gd`. Morvath: lanes
  recortadas na borda (`Boss._lane`), meias-luas se desfazem `BossDef.soul_overrun` (0,3 m) além da borda, investida só com
  `dash_min_free` (8 m) livres e parando na borda, invocações com a runa inteira no chão (`summon_ring`, `summon_clear`,
  `ritual_ring` no `BossDef`), fases 3 e 4 abertas do meio (`center_phases`), erupções pelo `FloorShape`. Avisos dele com
  assinatura (ART-001: miolo 0,35, aro 0,18, fio violeta de 2 px, runas espectrais por fora; `Ground.sign_boss`,
  `GroundLook.SIGN_*`) e a tempestade com a ordem de saída (`Ground.storm_rank`: pontos na raiz, aro em degraus); nenhum
  aviso pinta além da borda (global `floor_round` no `ground.gdshader` e no `ritual_rune.gdshader`). Global `boss_pos` para o
  `see_through` da cenografia. Câmera: alvo fixo `RoomLayout.cam_target` com `CamFrame.hold` (18%, no máximo `cam_reach` 3 m).
  Opções: `--no-boss`, `--hero-at=x,z`. O robô escolhe o vão (`Bot._escape` evita outros avisos) e conta "preso" (`RESULT`
  `bot.stuck`, `died_stuck`). Testes: `test_floor_shape.gd`, `test_boss_exits.gd` (saída de cada padrão, 12 x 12 posições),
  `test_boss_chamber.gd`, `test_chamber_look.gd`.
  Revisão de arte da câmara (`docs/gallery/boss_arena/ART_REVIEW.md`, P1 a P6, 2026-11-16): chão da câmara mais claro e um
  pouco mais quente só nela (`BossChamber.FLOOR_A`/`FLOOR_B`; o salão não muda); céu, névoa das agulhas e bordas de volta
  ao azul da pintura (`SKY`, `SPIRE_*`); anel distante de arcadas de 200° a 470° (`FAR_SPAN`) com uma janelinha quente em
  cada pilar (`FAR_WINDOW`, `FAR_WINDOW_GLASS`, `WINDOW_EVERY`). Tempestade: cada faixa só desenha a sua cunha em volta da
  raiz (metade do ângulo até cada vizinha, `GroundLook.storm_wedges`, `Ground.storm_wedge`, `wedge` no `ground.gdshader`),
  então nada soma; nada a menos de 1,2 m de Morvath (`GroundLook.STORM_CLEAR`), miolo mais fraco perto dele
  (`STORM_SOFT`, `STORM_ROOT_FILL`) e mais leve no todo (`STORM_FILL` 0,2; testes em `tests/test_storm_wedge.gd`).
  Erupções com o miolo vermelho da assinatura dentro do círculo (`danger*` no `ritual_rune.gdshader`, `Ground.RUNE_DANGER`).
  Colunas de dom sobre o chefe: também as que ficam entre ele e a câmera (`Skills.over_boss` com altura, yaw e pitch),
  fracas e com o miolo limitado a 1,0 (`Skills.BEAM_CORE_CAP`, `cap` no `beam.gdshader`); golpe forte no chefe pisca no
  máximo `Horde.BOSS_FLASH` 0,8, abaixo do `white_from` (antes o 1º quadro de um Ômega de geada deixava Morvath marfim).
- Colisão do cenário: pilares são círculos (`RoomLayout.pillars`); escadas, entulho e barris são caixas sólidas
  (`Arena.boxes`, pelo `solid` de `_place`). Sai-se da sala pisando no pé da escada (`Arena.exit_at`).
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
- Barra de vida fina sobre a cabeça de cada inimigo, como no Hades II (`CrowdRenderer.add_bar`, `life_bar.gdshader`; o chefe usa a barra do topo). Ciclo 8 (salas de 4 a 20 inimigos): todos mostram a barra (`Horde.BARS_FOR_ALL` 24; acima disso, só nos testes de estresse, só os feridos, mais finas); a armadura ganha faixa amarela própria em cima da vida (a barra cresce para baixo, `BAR_ARMOR_HEIGHT`, sem cobrir a vida), elites e guardiões têm moldura de ouro velho e barra um pouco mais larga (`BAR_ELITE_*`, continua dizendo elite depois que a armadura quebra), rastro claro do que o golpe tirou (`BarTrails`), a barra mais perto da câmera desenhada por último (`sort_bars`). O topo da barra não sobe (os números de dano começam acima dela). A barra grande do topo é só de Morvath e dos guardiões (`Game.boss_enemy`); elites comuns não a ganham (no `--horde` ganham).
- **Inimigos de longe** (teste do Daniel, 2026-11-16: "querem ficar na distância máxima atirando e não chegar perto"; números
  dos atiradores do Érebo do Hades II, estudo do mesmo dia, fontes na pasta local `estudo`): mago, besteiro e sacerdote têm o
  comportamento `ARCHER` (`Horde._behave_ranged`): andam só até o fim do alcance, fogem quando o paladino chega a menos de
  `EnemyDef.keep_away` do alcance (nosso; contornando a parede, `Horde.flee_dir`; encurralados atiram de perto) e atiram de lá
  (`Horde.shoot`, campos `shot_*`). Mago = o "Mage" do Hades: 3,5 m/s, alcance 13,1 m (elite 16,25), mira 1 s, rajada de 3
  orbes a cada 0,17 s (elite 7, `shot_ticks`) que o empurram para trás a 5 m/s (`recoil`), orbes a 7 m/s por 20 m que viram
  atrás dele (40 graus/s, nosso: o arquivo não diz), depois espera atrás da coluna mais próxima, 3,1 m além dela
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
- Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`; o desenho fica em `GroundLook`, que os laboratórios usam sem o jogo). Ciclo 8, direção do golpe: na linha a ponta de longe é a clara, o preenchimento avança como uma divisa apontando para onde o golpe vai, com divisas fracas na parte ainda vazia; o arco ganhou borda nos lados retos. Laboratório: `tools/enemy_lab.gd ... --bars --warn=0.6`.

## Pendências conhecidas
- **Fase por salas** (padrão): o robô desce as 10 salas em cerca de 5 minutos e chega em Morvath com 4 a 7 dons;
  vence ou perde por pouco. Falta teste com gente. O modo de horda (`--horde`) ficou como estava, com os números novos.
- Morvath (4 fases, 2026-11-15; ciclo 9): o robô sem tempo de reação vence sempre e quase não apanha; com reação humana
  (`--bot-reaction=0.25`) vence cerca de metade das lutas com 5 dons, perde mais na fase 4 (a tempestade e a maldição
  somam mais da metade do dano). A luta dura de 1 min 40 s a 2 min para o robô (abaixo da meta de 2 a 4 min; gente bate
  menos, medir antes de mexer na vida). A dificuldade para gente ainda não foi medida. A foice é a lâmina do modelo aprovado (ele não
  tem foice); meias-luas sem as caveiras da referência; maldição lida pelo brilho roxo e fumaça no herói. Diferenças do Hades
  que ficaram: Morvath tem ataques próprios (não os da chefe do Hades), só a vida (6050) e o dano seguem a escala; sem martelo, feitiço lunar ou dom de velocidade como recompensa; a loja compra ao pisar (não há botão de
  interagir); o bônus de dano por sequência de golpes (`DamageCalc.combo_bonus`) continua ligado; a seta especial não persegue.
  Depois do 1º teste do Daniel (mais dinâmico, 2026-11-14): o paladino fica plantado enquanto a lâmina corta (como no Ember & Blade; só o avanço do golpe o move) e, depois que o golpe
  acerta, andar corta o fim do golpe e ele corre (`ComboRunner.is_swinging`, `move_scale` 0); cada golpe leva o paladino até o inimigo à frente, como no Ember & Blade (`ComboNode.lunge_toward`, `LUNGE_MAGNET` 2,5 m, para antes de atravessar; `lunge` em metros); o corte de luz segue o lado do braço
  (`ComboNode.sweep`, `SWEEP` em `make_data.gd`), golpes
  empurram mais, inimigos mais rápidos (esqueleto 3,75 m/s) e com menos espera entre ataques (avisos iguais); a câmera
  se adianta para onde ele anda, não para a mira.
- Cenário do KayKit, fontes e áudio sintetizado são provisórios. Assados somam cerca de 44 MB (16 bits, `ARRAY_FLAG_COMPRESS_ATTRIBUTES`, textura S3TC de 1024 dentro de cada um; os `enemy_*` de origem não vão no pacote, ver `export_presets.cfg`) (o pacote web tem 61 MB).
- O lobo de geada do spec virou o esqueleto corredor. Vigília aparece como voto do PALADIN_1 (provisório).
- O spec fala em quatro paladinos; o cânone de 12/11 fala em um paladino do leão e quatro guardiões. Vale o que o Daniel decidir.
- Toque (celular) ainda não tem botões na tela.
- Desempenho: cerca de 1 ms por passo com 150 inimigos no PC; não medido em celular nem em placa de vídeo fraca.
