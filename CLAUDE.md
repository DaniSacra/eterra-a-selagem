# Crônicas de Eterra: A Selagem

Roguelite de ação em horda, 3D visto de cima (pegada de Hades 2 e Ember & Blade), em **Godot 4.7** (GDScript tipado, GL Compatibility). Spin-off e prelúdio do RPG
"Crônicas de Eterra": quatro paladinos descem às catacumbas sob a igreja velha de Valmor para selar Morvath.
Steam primeiro (Windows e Linux, mouse e teclado ou controle), Android depois.
Projetos irmãos: `../dungeon-rpg` (RPG original em JS, dono do cânone em `docs/mundo/`), `../cronicas-godot`
(RPG em Godot) e `../eterra-survivors` (Valmor Resiste, Phaser). **Não publicar nada no GitHub sem o Daniel pedir.**
**O herói jogável é o Guerreiro** (correção do PO de 2026-11-16; não é o Explorador nem o Guardião): guerreiro ofensivo de
espada, sem bloqueio nem aparo; especificação canônica em `docs/design/warrior_spec.md`, prancha só local em
`docs/art/ref/warrior_art_bible.png`. O título "Punho de Elun" é de Hanokh no cânone; decidido (D-64 a D-71, seguir as recomendações): o jogo mostra só
"O Guerreiro", símbolo do herói é o leão, nada de "Aliança"/"Convênio" nem poder com nome de Elun, especial como onda
(E1b), Fúria em cargas sem barra, primeiro Salmo o da Sentinela. `hero_explorer` continua como nome técnico do modelo; "guardião" no jogo é a sala e os inimigos de minichefe.
Regra central: Dom define o herói, Bênção define a partida, Salmo transforma o poder (`docs/design/po_directive_guardian.md`).

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
  arte são de Eterra. Terceira referência (2026-11-16): Ravenswatch, só em princípios (heróis com kit próprio, sem troca
  de arma, talentos por herói; `docs/design/benchmark_ravenswatch.md`). Comparação sistema por sistema e o que falta: `docs/design/comparativo.md` (manter em dia). A versão 2D em pixel art está na tag `v1-pixel-2d`.
- Modelos **provisórios**: KayKit (Kay Lousberg, CC0) em `assets/models/` (personagens, masmorra, armas).
  Fontes Cinzel e Alegreya Sans (OFL) em `assets/fonts/`.
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

## Primeira fase no molde do Hades II (2026-11-14)
- A partida é por salas, com a estrutura e os números da primeira região do Hades II (estudo dos dados do jogo do
  Daniel; nada de arte, nome, história ou som copiado). Notas do estudo: fora do repositório (scratchpad da sessão).
- Escala: 80 unidades do Hades = 1 m (andar 540 = 6,75 m/s; heroína de 200 de altura = paladino de 2,5 m). `U` em `make_data.gd`.
- Salas: `RunMap` (`core/run_map.gd`: abertura com dom, portas que mostram a recompensa, guardião entre as salas 4 e 6,
  uma fonte entre 5 e 8, loja na 10, Morvath na 11; **encurtado para teste**: 7 salas desde o ciclo C12 (fonte na 4, guardião na 5, loja na 6, Morvath na 7; `--short` volta à de 5), elites desde a sala 2 (`elite_from_depth`; no Hades, 3), `_stage` em `make_data.gd`), `EncounterGen` (`core/encounter_gen.gd`: dificuldade 55 + 15 por sala,
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
  frente e para trás, 20 de Magia), Ômega do especial 0,65 s (80, 10 de Magia), avanço 0,2 s / 5,6 m com 19 quadros de
  proteção desde o aperto (C12d) e 1 carga, círculo em volta do paladino (5,4 m, 3 s, um por vez). Vida 30, 1,3 s de proteção após um golpe.
- Inimigos com os números de Érebo: cada um tem a versão elite (`_elite`, armadura do Hades). Guardiões: `knight` e `priest_elder`.
- Aparência dos inimigos pela prancha do Daniel "Inimigos da Fase 1" (`docs/art/enemies_phase1.md`; imagem só local em
  `docs/art/ref/`): **os nove são os modelos do Meshy** aprovados pelo Daniel (2026-11-15; `assets/models/meshy/enemy_<id>/`,
  esqueleto de 24 ossos, `-rigged.glb`; tom da 3ª versão do Sacerdote: caveira de marfim, roxo apagado, metal escuro, brilho só
  nos olhos e gemas). `tools/bake.gd` (`MODELS`, entrada com `"meshy"`) faz tudo: reduz a malha de 15,5 mil para cerca de 3,9 mil
  triângulos e repassa a pintura para um atlas novo de 1024 (`MeshSlim`, `scripts/render/mesh_slim.gd`), transfere clipes da
  Quaternius e do KayKit pelo `Retarget`, prende as armas do KayKit que o modelo não tem (`held`: lâmina, cajado, besta, escudo
  do Cavaleiro; o Escudo já traz as dele), põe os pés no chão e a altura da prancha (`height`). Armas do KayKit repintadas no
  assado (E1a-4, VX-07, paliativo até o Meshy): `paint` de cada `held` troca as células da paleta por amostras pintadas no tom das
  figuras (`SWATCHES`: ferro escuro, ferro gasto, osso, madeira escura, metal velho, ouro velho, couro, vermelho; primeira linha da
  faixa da paleta, projetadas ao longo da arma, `_repainted`, `_paint_swatches`), sem faixas de duas cores; cutelo a `CLEAVER_SCALE`
  0,58 (aço 0,52 m = 0,6 do tronco), besta a `CROSSBOW_SCALE` 0,5 em madeira e ferro, cajados em madeira escura com anéis de metal
  velho, gancho de Morvath em ouro velho (na tela matiz 37, saturação 0,44). O Escudo tem a rótula esquerda do rig fora do lugar:
  `even_legs` encurta a perna ao alcance que ela tem em repouso (`_even_leg`) e o pé direito, que flutuava 20 cm, pisa no chão.
  Testes em `tests/test_held_weapons.gd`; antes e depois em `docs/gallery/e1a/after/weapons/`. A textura vai dentro do `.res`
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
  em passada longa, mago 130 e besteiro 126 num trote curto (o `Running_B` com passada 0,62 e 0,67 e meio pulo, `"lift"` 0,5),
  ancião 67; todos escorregam até 1,6 cm em jogo (antes Escudo 16, Cavaleiro 21, Morvath 15, ancião 10). O braço livre do mago
  fica junto ao corpo (`MAGE_TROT`, guarda do `Idle`; o assado imprime o quanto cada braço abre). Medir clipes sem assar:
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
  (`Magick`, `ComboNode.magick_cost`, `In.CHARGE_LIGHT`/`In.CHARGE`, `HeroDef.cast_omega_cost`); Magia volta por abate
  (`Game.MAGICK_PER_KILL`). Círculo: zona `Ground.Kind.BIND` que prende (chefe só fica lento); o Ômega explode no fim
  (`Combat.cast_burst`). Armadura (`EnemyDef.armor`, barra amarela): absorve os golpes, ao quebrar atordoa
  (`Horde.armor_broken`; Morvath se rearma depois do atordoamento).
- Entrada só por ações (`Controls`): `light_attack`, `heavy_attack`, `dodge`, `cast`, mira (`Controls.aim`). Nunca ler tecla direto.
  Toque e robô usam `Controls.VirtualPad`. Toques num quadro em que o jogo não andou ficam guardados (`Controls.flush`;
  o controle virtual também, `Controls.latch_virtual`, GF-06).
- Sonda de game feel (`tools/feel_probe.gd`) desde a E1b: 34 metas (as 31 do C12d, `GF-12` e `E1b-L2`/`E1b-L35`, o
  primeiro ataque com um esqueleto a 2 m, já no alcance: acerta em f4 sem atravessar o corpo; a 3,5 m: avança pelo menos
  1,2 m e acerta em f4). O avanço do golpe para a `HeroDef.lunge_standoff` do alcance do golpe (0,3 desde a E1b, decisão do Game
  Director pela identidade do Guerreiro, `warrior_spec` 2 e 10.1; era 0,45, a constante `Player.LUNGE_STANDOFF`): com
  0,3 ele anda 1,38 m a 3,5 m e 0,15 m a 2 m (o mínimo do `ComboNode.lunge_toward`: a 2 m o golpe 1 já alcança).
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
  (`ComboNode.cooldown`, guardado pelo golpe sofrido), pernas presas 0,71 s que só a esquiva corta (`root_time`,
  `Player.rooted`), dardo a 62,5 m/s (`Projectiles.SPARK_SPEED`). Ômega do ataque: preparação e brilho dentro da carga,
  acerta quando ela enche (`Player._charge_lead`); apertar de novo recomeça a carga. Círculo sem proteção e 8 quadros
  sem golpe (`ComboRunner.hold_for`, `HeroDef.cast_attack_lock`). Impacto: tranco do golpe comum 0,09 m, finalizador
  0,32, Ômega 0,56 (`Combat.KICK_*`, `kick_of`); clarão do inimigo 0,05 s (`Horde.FLASH_TIME`). Som da lâmina no
  começo de cada golpe (`ComboNode.sound`: `blade`, `blade_spin`, `thrust`, `dart`; nada mais de `swing` só no erro) e
  `charge_up` segurando o Ômega; vibração por golpe e ao ser ferido (`Fx.buzz`, `Combat.RUMBLE_*`), só com controle
  em uso e a opção `rumble` do save ligada (`Fx.rumble`, `Game.apply_options`).
- O jogo abre em tela cheia (padrão desde 2026-11-16, `SaveData.VERSION` 2 passa os saves antigos para tela cheia uma vez; capturas, vídeos e `--nosave` ficam em janela, `App.apply_options`); a pausa tem "Sair do jogo" no desktop (`pause_exit_game`).
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`, versão 3 com heróis e Compêndio). Sem save (`--nosave`) não há recorde
  (`SaveData.record_win_time`). Os testes nunca gravam o save nem o registro (`tests/hooks/pre_run.gd`, `pre_run_script` no
  `.gutconfig.json`; `tools/title_flow_check.gd` também desliga).
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
- Som: `scripts/audio.gd` (receitas sintetizadas, provisórias). Um arquivo `audio/<nome>.ogg` substitui a receita;
  `audio/<nome>_0.ogg`, `_1.ogg`... sorteia entre eles. Golpes, ossos, escudo e atordoamento usam o Kenney Impact Sounds (CC0).
  Licenças e créditos em `audio/LICENSES.md` (D-12b: síntese, CC0 e CC-BY com crédito). Música desligada por enquanto.
  Limitador `AudioEffectHardLimiter` no fim do barramento `Master` com teto de -1 dB
  (`Audio.LIMIT_DB`, `Audio.limit_master`, posto uma vez ao iniciar; ciclo C12c, GP-05).
  Som do combate (E1b, C15-02): a tabela é `CombatSounds` (`core/combat_sounds.gd`): `EVENTS` (golpe e golpe forte, dardo,
  escudo do ritual `ward`, ataque cortado `interrupt`, quebra de armadura `armor_break`, atordoamento, Ômega carregando e
  pronto, círculo, círculo Ômega e a explosão dele, esquiva, golpe sofrido, maldição, invocação); por cima do golpe, a
  camada do material mais alto atingido (`EnemyDef.material`: `bone`, `shield` o Escudo, `armor` o Cavaleiro, `spectral`
  Morvath; golpe na barra de armadura soa `armor`; `CombatSounds.material_of`, `loudest`); a queda por material
  (`kill`); o começo de cada preparação de inimigo pelo `EnemyDef.tell` (um som curto por papel: lâmina, brasas, orbe,
  besta, escudo, ritual; `Horde._set_state`), o golpe solto (`strike`) e o tiro (`shot`: virote, orbe, trepadeira). Um
  inimigo novo com `tell`, comportamento e `material` que já existem soa sem código. 16 vozes (`Audio.VOICES`).
  Teste: `tests/test_combat_sounds.gd` (todo evento, material, inimigo e golpe do herói com receita; nenhuma receita
  passa de 0,95 sozinha; limitador a -1 dB). Projéteis barrados pela pedra ainda sem som (`projectiles.gd`).

## Arenas (ciclo C12, Arenas I; plano em `docs/design/cycle12_arenas_plan.md`, plantas em `docs/art/cycle12_arenas_spec.md`)
- A descida de teste tem 7 salas (D-27): abertura no Salão das Catacumbas, lutas sorteadas entre a Cripta dos Esquecidos,
  o Salão das Fendas e o Jardim das Raízes Mortas (nunca a mesma duas vezes seguidas, as ainda não vistas primeiro,
  `RunMap._layout`), fonte na 4 (no salão), guardião na 5, loja na 6 (no salão), Morvath na 7. `--short` volta à de 5.
- Cada arena é dado no `_stage` do `make_data.gd` (`_crypt`, `_rift`, `_garden`): `RoomLayout` com `id`, `name_key`,
  `look`, tamanho, dificuldade, faixa da descida (`depth`), teto de inimigos (`max_alive`, `max_ranged`,
  `banned_roles`), chão `FloorShape.POLY` (polígonos menos buracos), obstáculos `ArenaObstacle` (círculo ou caixa
  girada; `blocks_move`, `blocks_shots`, `see_through`, altura e peça), zonas de nascimento (`spawns`, `late_spawns`
  só da 2ª onda), saídas `ArenaExit` (boca de 4 x 2,4 m além da borda, que só vira chão quando a porta é usada),
  caixa da câmera (`cam_bounds`) ou alvo fixo (`cam_target`), variantes `ArenaVariant` (outros obstáculos, outro chão,
  espelho). A mesma peça desenha e colide (`Arena._build_arena`). Regra do tiro: topo acima de 1,25 m bloqueia, até
  1,0 m passa por cima (o ramo rasteiro do sacerdote para em tudo que bloqueia corpo, `Arena.cover_low`).
- Movimento varrido (`Arena.sweep`, passos de 0,2 m) para herói, inimigos e corpos empurrados: nada atravessa buraco
  nem cai (D-28). Inimigos andam reto quando a linha está livre, senão pela grade `NavGrid` (0,5 m, folga 0,55) e pelo
  campo de fluxo `FlowField` (busca em largura fatiada, no máximo 4 vezes por segundo); o robô usa os mesmos. Atirador
  só prepara com linha de tiro livre e dentro de 5 a 95% da tela (`Horde._can_fire`); tiros morrem na pedra com faísca
  (`Projectiles.blocked`). O nome da arena aparece por 2 s ao entrar (`Hud.show_place`, chaves `arena_*`).
- Visual: `ArenaRoom` (`scripts/game/arena_room.gd`) monta o comum (chão em células de 8 m com `floor_look`, bordas por tipo
  `Edge` OUTER/HOLE/MOUTH com `broken_edge`, `balustrade_edge` (pontilhado nas bordas viradas para a câmera) e `filet` de
  ouro, peças de `ArenaObstacle`, portas com escada ou arco na parede `door_arch`, `key_light` sem sombra); cada arena
  sobrescreve `dress`, `air`, `floor_look`, `stone_tint`, `mist`, `cliff_look`, `edge`, `in_wall`. O ar de cada sala é
  aplicado por ela e devolvido ao sair (`ArenaRoom.leave_air` no começo de `Arena._build`, porque a sala nova se veste
  antes da velha sair da árvore). Peças de túmulo em `TombKit` (`scripts/game/tomb_kit.gd`, vindas do `BossChamber`, que
  ficou igual: sarcófago, espada em relevo, lanterna `Lamp`, pilarete, coluna inteira ou quebrada, mureta, túmulo
  grande, nicho, laje sem texto, grade). Estandarte com o leão do selo: `ArenaKit.banner(..., ArenaKit.Emblem.LION)`
  (`banner_lion.gdshader`, um material só); o salão e as arenas usam o leão, a Câmara do Selo a espada (`Emblem.SWORD`).
  Cripta (`crypt_look.gd`): paredes de 6,5 m com nichos ao norte e oeste, frente cortada a 0,9 m, ossuário divisor na
  variante B, feixe frio sobre o túmulo (`COLD_*`), 6 luzes com sombra. Fendas (`rift_look.gd`): pontes em arco de 5 m
  (`BRIDGES`; a de cima caída na variante B, com tocos e pedaços pendurados), balaustrada quebrada na borda oeste da
  fenda e filete de ouro na leste e no buraco, violeta de baixo (`DEEP_*`), arcos cegos nas paredes da fenda,
  fachada com pórtico, estátuas e estandartes, torre e correntes; 3 a 4 luzes com sombra. Correções F-1 a F-6 e G-1 da
  revisão (`docs/gallery/cycle12_maps/ART_REVIEW.md`; antes e depois em `work/fix_rift_*`): lábios quebrados (`broken_lip`,
  `LIP_*`: lascas da beira com as lajes do chão saindo da queda, falhas, pedras caídas), paredes de dentro e penhascos
  de fora na pedra das profundezas escura logo abaixo da beira (`CLIFF`), bruma violeta em três folhas dentro da fenda e
  dos buracos (`HAZE_*`, `rift_haze.gdshader`, saindo pela boca norte) e o violeta pintado na beira das lajes (sem luz);
  pontes com lajes próprias no sentido do vão, meio-fio claro, junta escura nas cabeceiras, parapeito vazado de 0,9 m,
  pilares de 1,4 m sobre os pegões (`DECK_*`, `KERB`, `PARAPET*`, `HEAD`, `ABUTMENT`; arco, enchimento e pegões na pedra
  escura); a lua faz a luz principal (sem a omni do meio, que deixava os cantos em metade); inscrições de ouro entre a
  fenda e o buraco (`INSCRIPTION_*`, `garden_inscription.gdshader`); no Compatibility ar mais neutro e bruma mais clara
  (`AIR_COMPAT`, `HAZE_COMPAT`). Nada disso muda colisão nem o `_rift` do `make_data.gd`. `tools/arena_lab.gd` imprime
  `SHADOWED LIGHTS`. Evidências: `docs/gallery/cycle12_maps/work/` (`before_*`, `w4_*`).
- Revisão de arte das arenas (`docs/gallery/cycle12_maps/ART_REVIEW.md`, 2026-11-16): Cripta e Jardim aprovados (a árvore
  fica, D-30), Fendas segurado até F-1 a F-3. Correções C e J: facho da Cripta 1,6 e tampa do túmulo no valor da pedra
  (`TOMB_LID_LIGHT`, `sarcophagus` sobrescrito só na Cripta; o `TombKit` e a câmara não mudam), colunas com capitel e aduelas,
  degraus no valor da cantaria (`Masonry.stairs(..., mat)`); árvore com camada própria (`StoneTree.LAYER` 32) e luz de
  preenchimento só dela (`GardenLook.TREE_FILL*`), casca torcida 100 graus com cordas desiguais, grão, líquen e fraturas, tocos
  quebrados (`STUBS`), cristais esmeralda corrompido escuro (`CRYSTAL_GLOW`), raízes com dois lombos e pontas abertas
  (`TIP_ROOTS`); compensação de luz no Compatibility por sala (`COMPAT_*` na Cripta e no Jardim). Para estas arenas o Daniel
  pediu variedade de salas, não fidelidade às imagens conceituais (2026-11-16).
  C12c (ENV-01 a ENV-03; evidências em `docs/gallery/cycle12c/work/env_*`): chão da luta na Cripta entre 45 e 60 longe das
  velas (lajes mais claras em `CryptLook.FLOOR`, a luz de cima mais alta, mais larga e de queda lenta, deslocada para as
  baías do oeste: `KEY_ENERGY` 1,8, `KEY_HEIGHT` 11, `KEY_FALLOFF` 0,5, `KEY_REACH` 26, `KEY_SHIFT`; sem luz nova, paredes
  continuam escuras); fraturas da árvore no marfim velho, nunca brancas (`fracture_color` 0,5 no `stone_tree.gdshader`);
  no Compatibility a lua do Jardim não faz sombra (`GardenLook.COMPAT_MOON_SHADOW`, menos 270 chamadas de desenho).
- `RESULT` e o registro trazem `rooms` (por sala: profundidade, arena, vida ao entrar, dano por fonte, tempo e primeiro
  contato), `hp_at_boss`, `arena`, `stuck`/`stuck_by` (inimigo que queria andar e ficou 3 s parado) e `shots_blocked`;
  desde o C12c também os campos do GP-02 por sala e `boons_at_boss`, `shop`, `fountain_used` (ver Registro das partidas).
- Opções: `--arena=crypt|rift|garden|hall` (a primeira sala), `--variant=n`, `--short`, `--trace-steps` (imprime os
  passos acima de 4 ms e onde o tempo foi), `--trace-cam` (maior salto do alvo da câmera por sala, GP-06). Laboratório sem personagens, com grade, bordas, peças, zonas e câmera:
  `tools/arena_lab.gd` (comando no topo; `--top` vista de cima). Testes: `test_arenas.gd`, `test_descent.gd`,
  `test_killing_blow.gd`.

## Guerreiro: HeroDef, Maestria, Dons (E2a, fundação; especificação em `docs/design/warrior_spec.md`)
- **`HeroDef`** (`core/hero_def.gd`, `data/heroes/warrior.tres`, parte `hero` do `make_data.gd`; DT-013): id técnico `warrior`,
  modelo `hero_explorer`, combos, vida 30, `hurt_time`, proteção 1,3 s, 1 carga de esquiva em 0,74 s (saíram do `Feel`), Magia
  50, os números do círculo (saíram de `Player.CAST_*` e `Combat.CAST_*`), passiva `magick_on_finisher` 2 (sem
  comportamento ainda), as duas ultimates (`UltDef`, `core/ult_def.gd`, `data/ultimates/`, parte `ultimates`: U-1 faixa
  12 x 4 m 300/200, carga 60, Maestria 2; U-2 Voragem, carga 70, Maestria 6; só dados), a pasta dos Dons e a curva.
  `HeroDef.warrior()`; `Player.hero`, `Combat.hero` e `Game.hero` leem dele. `Player.RADIUS` continua constante.
  Prova: mesma semente, mesmo `RESULT` antes e depois (smoke 300 e `--start=boss --boons=25`, `--seed=5`).
- **Maestria** (`MasteryCurve`, `core/mastery.gd`, `data/heroes/warrior_mastery.tres`, parte `mastery`): 20 níveis, do n
  para o n+1 `40 + 10 (n - 1)` (2470 no todo), Devoção 5 + nível; XP por sala de luta 10, guardião 25, fase de Morvath
  alcançada 10 (até 40), vitória 50 e primeiras vezes (Bênção vista 2, Elo 10, Salmo 25, guardião 25, vitória 100). No
  fim de toda partida (vitória, morte, saída) `Game.log_run` calcula (`mastery_gain`) e soma ao save (`award_mastery`:
  XP, Dons destravados, primeiras vezes, Compêndio); nunca sem save nem com o robô (`--mastery` deixa o robô somar).
- **Save versão 3** (DT-012, `SaveData`): `heroes.<id>` (`mastery_xp`, `unlocked`, `equipped`, `ultimate`, `firsts`) e
  `codex` (`boons`, `elos`, `psalms`, `talents`, `enemies`: id para contagens); dicionários de chaves livres sobrevivem a
  ler e gravar. Saves 1 e 2 ganham a Maestria retroativa uma vez (40 por partida, 60 por vitória, até o nível 5).
  Arquivos fixos em `tests/fixtures/save_v1.json` a `save_v3.json`.
- **Registro versão 3** (DT-015, `RunLog`): `hero`, `xp`, `xp_by`, `mastery_level`, `talents`, `ultimate`; linhas antigas
  lidas por `RunLog.normalized` (`tests/fixtures/runs_v2.jsonl`).
- **Dons** (`TalentDef`, `core/talent_def.gd`; regras em `Talents`, `core/talents.gd`; 19 em `data/talents/warrior/`, parte
  `talents`): a árvore da seção 4 (Combo, Fúria, Emeth, Magia com entrada, meio e ápice; quatro pontes; três de sustento),
  custo, ramo, degrau, nível que destrava (ordem da 4.4), `slot` quando troca a ação, `partner` do ápice, `joins` da ponte.
  Pré-requisito só vale equipado; ápice pede o meio e um Dom do ramo parceiro (vizinho); ponte pede as duas entradas; um
  Dom por ação; `check`, `can_add`, `sanitized` (o que vem do save). Equipados na descida por `Game._equip_talents`
  (do save, validado pelo nível; `--talents=a,b` para testes); só os de número já agem: Fio Longo (`reach_pct` light 0,15),
  Reserva e Firmeza (`magick_max`, `max_hp`), somados às Bênçãos em `BoonState.stat` (`equip_talents`). Os efeitos dos
  outros, a tela do herói e a ultimate jogável são as próximas tarefas. Testes: `test_hero_def.gd`, `test_mastery.gd`,
  `test_talents.gd`, `test_save.gd`, `test_run_log.gd`.

## Onde mexer
- **Elo** (mecânica das Crônicas de Eterra) = dom duplo do Hades: família `DUO` em `scripts/core/boon.gd`, dom com
  `requires` de dois outros (6 hoje; nome "Elo" no texto desde 2026-11-15). A carta mostra os dois dons de origem
  numa corrente de ouro velho com o Elo no meio (`EloLink`, `BoonState.sources`), o medalhão do Elo tem aro de elos,
  a HUD saúda cada Elo novo com "Elo formado" sem pausar (`EloBanner`) e a pausa tem o painel "Dons" (`BoonsScreen`).
  Capturas dessas telas numa partida real: `tools/ui_lab.gd` (comando no topo).
- **Tela de dons "Um dom chega até você"** (2026-11-16, referências de IA só locais em `docs/art/ref/boon_cards/`):
  `BoonChoice` monta três `BoonCard` (`scripts/ui/boon_card.gd`, 320 x 450 a 720 linhas): arte no topo sobre um brilho
  da cor da família, nome em marfim, família ou "Elo de A e B", ação, nível e raridade numa linha, filete com losango,
  descrição sobre tinta escura e "Substitui X" embaixo. Medalhão pintado pelo id do dom (`BoonArt.medallion`:
  `assets/ui/boons/<id>.png`; hoje `vapor`, `aurora`, `redemoinho`, recortados da prancha por
  `tools/cut_medallions.gd`, 512 px com mipmaps): dom novo com arte é só pôr o PNG com o id. Elo pintado: `EloLink`
  com `art`, as duas origens (`BoonIcon` de 46 px) numa corrente curta que entra no aro pintado (o aro do PNG é o
  único). Sem arte: o `BoonIcon` desenhado (e o `EloLink` desenhado no Elo). HUD e painel "Dons" não usam os PNGs.
  A borda e o brilho de fora seguem a raridade (comum fica no metal, `BoonCard.COMMON_EDGE`); o foco é um filete
  marfim por dentro e a tinta mais clara (`FOCUS_*`), sem escala (borrava o texto). Proteção de 350 ms
  (`BoonChoice.GUARD_MS`). A carta de descanso ("Fôlego") existe na tela, mas a partida por salas aplica o descanso
  direto quando não há oferta (`Game._open_choice`). Capturas: `tools/ui_lab.gd -- --card-only [--offer=a,b,c]
  [--held=x,y] [--rarity=0,2,1] [--rest] [--focus-move]`; galeria em `docs/gallery/boon_cards/`; testes em
  `tests/test_boon_cards.gd`.
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
  (`EndScreen`, `stats.defeated_by`) e, embaixo, onde caiu ("Sala 3 de 7, Cripta dos Esquecidos", `EndScreen.where_text`:
  `stats.room`, `rooms_total`, `arena` ou, sem eles, o `Game` de cima; a sala de Morvath diz "A Câmara do Selo", o salão
  "Salão das Catacumbas") e os dons levados em medalhões, como na vitória (`stats.gifts` ou `game.boons`; ciclo C12c, UI-02,
  `tests/test_end_screen_run.gd`). Placas das portas, da recompensa e da loja: `DoorSign` (`scripts/ui/door_sign.gd`, UI-01):
  nome em ouro claro e preço em marfim, Alegreya Sans Bold com contorno escuro, `fixed_size` com maiúsculas de
  `DoorSign.CAP_PX` 19 px a 1080 linhas (proporcional em outras telas, pelo campo de visão da câmera) e contraste de pelo
  menos 4,5:1 com o contorno (`DoorSign.contrast`). "Novo melhor tempo!" nunca sem save (`EndScreen.open` confere `Save.enabled`).
  Configurações: grupo "Conforto" com tremor, clarões de impacto, câmera lenta (com zoom e desfoque) e separação de cores, todos
  ligados por padrão (`OptionsScreen.COMFORT`, `Fx.slow_motion`, `Fx.color_split`, `Game.apply_options`); C12d: vibração do
  controle (`opt_rumble`, chave `rumble` do save, ligada; a partida lê `Save.option("rumble")`; ligar dá um zumbido curto de
  teste em todo controle, `OptionsScreen.RUMBLE_TRY`; linhas da coluna da esquerda com 42 px, `ROW`, para caber em 720); fluxo por teclas
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
  fracas e com o miolo limitado ao teto da tela (`Skills.BEAM_CORE_CAP`, `cap` no `beam.gdshader`, ver GP-01); golpe forte no chefe pisca no
  máximo `Horde.BOSS_FLASH` 0,8, abaixo do `white_from` (antes o 1º quadro de um Ômega de geada deixava Morvath marfim).
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
- **Atordoamento pelo golpe (E1b, GF-12, D-42: o Hades II por inimigo)**: golpe que fere um inimigo comum sem armadura o
  atordoa (`Horde.flinch`): para de andar (`stun_t`, `Enemy.helpless`), a preparação ou o ataque em curso é cortado e não
  sai (`Horde.interrupt`: volta a `WALK`, o aviso no chão do ataque some na hora por `Ground.end_zone(Enemy.warning)`, o
  som `interrupt`), e mostra o golpe sofrido (o recuo do E1a, `HitRecoil`, continua). Duração por inimigo em
  `EnemyDef.stun_time` e `stun_heavy_time` (finalizador e Ômega; `STUN` 0,3 s no `_enemies` do `make_data.gd`, a pose do
  golpe sofrido: o Hades usa o comprimento das `StunAnimations`, que não está nos scripts; o Heavy é a mesma animação a
  meia velocidade: esqueleto e mago 0,6, o Escudo 0,23 e 0,5 como o Brawler, os outros só o Default). Preparação cortada
  fica pronta e se anuncia de novo inteira; ataque já solto cortado conta a recarga. Elites só depois que a armadura
  quebra (a barra absorve antes); a quebra da armadura também corta o ataque (`Game._on_armor_broken`, o
  `ArmorBreakStun`). Investida do Escudo em voo não é cortada (`stun_immune_attacking`, a carga do Brute do Hades; a
  preparação é). Guardiões e Morvath nunca (`stun_time` 0, o `ImmuneToStun`). Queimadura e zonas não atordoam (só golpe
  com direção e clarão). `RESULT` traz `flinches` e `interrupts`. Testes em `tests/test_flinch.gd`; sonda `GF-12`.
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
- Nomes dos paladinos: enquanto `PALADIN_n` for o próprio marcador, a oração entre colchetes que o cita some do texto
  (`"Luz[, dom de {P4}]"` mostra "Luz"; `TextTable._clauses`, `is_named`) e volta sozinha quando o Daniel der o nome (C12d,
  VX-11; `tests/test_no_placeholder.gd` monta as cartas e o painel de dons e procura `PALADIN_`). Contador de golpes do HUD
  menor (VX-12: `Hud.FONT_COMBO` 30, `COMBO_POP` 0,15, algarismos abaixo de 48 px a 1080 no pico, nome do golpe com alfa
  `MOVE_ALPHA` 0,7).
- Toque (celular) ainda não tem botões na tela.
- Desempenho: cerca de 1 ms por passo com 150 inimigos no PC; não medido em celular nem em placa de vídeo fraca.
