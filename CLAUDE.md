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
`docs/qa/latest_report.md`), `combat-feel-director` (cadência, peso e sincronia do combate: preparação, impacto, recuperação e próxima ação do Guerreiro, dos inimigos e de Morvath; mede em capturas reais, mantém `docs/design/combat_cadence.md`, classifica P0/P1/P2 e pode reprovar tecnicamente uma entrega de combate com evidência; não implementa), `technical-artist` (valida, mantém e evolui todo asset: modelos, assados, texturas, arte de UI, sons e músicas; orçamento, importação, licenças, declaração de IA, assets sem uso; inventário em `docs/art/asset_inventory.md`, relatório em `docs/qa/asset_report.md`; Meshy só com autorização), `room-designer` (evolução e progressão das salas: tamanho, forma, perigos de sala que pedem pensar, como armadilhas, árvore que ataca, buracos e raios, sempre avisados e ferindo inimigos também; plano em `docs/design/rooms_progression.md`), `game-director` (lê todas as evidências e revisões e mantém o backlog em `docs/backlog.md`: bugs e quickwins
primeiro, depois os próximos ciclos; roda ao fim de cada ciclo, não implementa). Cada arquivo tem um dono por tarefa; agentes em paralelo só com arquivos distintos (ou em
worktree). Tarefa pequena o Game Director faz direto. Protocolo completo: `docs/development/agent_workflow.md`.

## Comandos
- Godot: `~/tools/godot/godot` (4.7.2). Rodar o jogo: `~/tools/godot/godot --path .`
- Testes: `tools/test.sh` (GUT sem tela). Um arquivo só: `tools/test.sh -gselect=test_combo`
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
- Partida sem tela com o robô (rápida, para ritmo e regressão): `tools/smoke.sh 300` (partida inteira) ou `tools/smoke.sh 180 --start=boss --boons=25`.
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
- Modelos **provisórios**: KayKit (Kay Lousberg, CC0) em `assets/models/` (personagens e armas só para o assado; masmorra em `dungeon/` e `dungeon_r/`, todas com a paleta única `kaykit_palette.png`).
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
- Salas: `RunMap` (`core/run_map.gd`; desde o DV-1 um grafo gerado no começo, ver Descida de Valmor: abertura com dom, portas que mostram a recompensa, guardião entre as salas 4 e 6,
  uma fonte entre 5 e 8, loja na 10, Morvath na 11: **a descida padrão desde a E3** (C13-01, D-61; `--medium` é a de 7 do
  ciclo C12, fonte na 4, guardião na 5, loja na 6, e `--short` a de 5, as duas com elites desde a sala 2,
  `Rooms.short_stage`), elites desde a profundidade 3 (`elite_from_depth`), nenhuma arena mais de 3 vezes
  (`arena_max_uses`, a menos usada primeiro), `_stage` em `make_data.gd`), `EncounterGen` (`core/encounter_gen.gd`: dificuldade 55 + 15 por sala,
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
- **Bênçãos e economia da E3 (Hades II; regras, números e decisões em `docs/design/e3_blessings.md`, métricas do robô em
  `docs/qa/e3_metrics.md`)**: as portas tiram cartas de um baralho sem repor que volta inteiro quando nada serve
  (`StageDef.reward_deck`, `RewardDeck`: 6 Bênçãos, 2 romãs, 2 corações, 2 Magia, 2 ouro). Raridade em sequência
  (`BoonState.roll_rarity`: rara 10%, épica 5%, 85,5 / 9,5 / 5; guardião rara 90%, épica 7%), quatro raridades
  comum 1, rara 1,5, épica 2 e lendária 2,5 (D-52, D-53), a lendária só pela troca (E3-01: 10% por carta, a Bênção de
  uma ação ocupada troca por outra uma raridade acima e no nível dela, `BoonState.trade_card`). Cada carta é
  `BoonState.Card` (`Game.offer_cards`: raridade, `trade`, `replaces`, `level`); Bênção que já se tem não volta nas
  cartas (cresce pela romã). Romã: cada número tem `base` (nível 1, vezes a raridade) e `per_level` (ganho fixo por
  nível, o último se repete, sem raridade; `BoonMod.at`, `SkillDef.damage_at`); teto de nível 3 mantido (E3-D1). Elo
  12% por carta (`elo_chance`), pede uma Bênção de cada lista (`Boon.requires_sets`), sem raridade e sem nível
  (BUG-017). Sem bônus de sequência de golpes (C13-07, D-10). Ouro cai dos inimigos (`GoldPurse`: teto de 10 a 15 +
  0,5 por profundidade, 70% por inimigo da parte dele), recompensa de ouro 100; loja em 3 grupos (`StageDef.shop_groups`,
  `ShopGroup.count`: Bênção 150; cura 50 e coração 125; dois de Magia 100, romã 100 e fatia de romã 50,
  `RunMap.Reward.POM_SLICE`), 5 itens como a última loja antes do chefe final (`Rooms.shop()` para a tela). O robô
  escolhe a porta como gente (`Rooms.bot_door`). `RESULT` com `dealt_by` (dano por fonte, `DealtBy`, `Horde.dealt`) e
  `elos`. Testes: `test_rarity.gd`, `test_elo.gd`, `test_economy.gd`, `test_descent.gd`, `test_boons.gd`.
- Golpes do Hades: ataque em 3 (20, 25, 60 em volta), especial = onda (40; no Hades, a seta), Ômega do ataque segurando 0,8 s (160, para
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
- `scripts/boot.gd` compõe: Iniciar entra na partida (o único fluxo), O Guerreiro (`HeroScreen`, E2-06), Como Jogar
  (`HowToScreen`, teclas reais lidas do mapa, com o Compêndio dentro), Configurações (`OptionsScreen`), Sair só no desktop.
  Os quatro botões pequenos ficam numa coluna de 52 px de altura a cada 62 px a partir de y 506 da arte
  (`TitleButton.SMALL_*`; antes três a cada 71). Fluxo testado por `tools/title_flow_check.gd` (teclado, sem tela, passa
  pela tela do herói e pelo Compêndio). Os outros três heróis da arte ainda não têm nome nem papel no jogo.
- **Tela do herói** (E2-06, `scripts/ui/hero_screen.gd`): medalhão e "O Guerreiro", Maestria (`MasteryBar`, nível num
  losango de ouro velho, barra de XP e "No nível N: ..." do que o próximo nível dá), Devoção em losangos (usada e livre),
  a árvore de Dons em losango (`TalentTree`, `TalentNode`: passiva no centro, Combo em cima, Fúria à direita, Magia
  embaixo, Emeth à esquerda, entrada, meio e ápice para fora, pontes nas diagonais, sustento no canto de baixo à esquerda;
  trancado mostra cadeado e o nível; custo em losangos pequenos embaixo de cada nó; linha acesa entre dois equipados;
  equipado = losango cheio da cor do ramo, fio esmeralda mais grosso e brilho em volta (`TalentNode.EQUIPPED_*`,
  `GLOW_*`), só destravado = tinta escura com fio de ouro velho e o símbolo na cor do ramo; Combo em carmesim, a cor do
  punho da Emeth, antes um cinza que lia como desligado, `TalentNode.BRANCH_COLOR`) e as
  duas ultimates (`UltCard`, trancada mostra o nível). O painel da direita conta o Dom ou a ultimate em foco e, quando
  não dá para equipar, por quê, nas regras do `Talents` (`HeroLoadout`, `core/hero_loadout.gd`: `state`, `why`,
  `toggle` que tira junto o que dependia, `choose_ult`). A dica de teclas do rodapé troca ao vivo entre teclado e
  controle (`Controls.device_changed`). Enter, A ou clique equipa e tira; grava na hora em
  `heroes.warrior.equipped`/`ultimate`. Nome da passiva: "Ímpeto da Emeth" (1ª opção da spec, `hero_passive`).
  Capturas: `--title --screen=hero` com `--hero-xp=N`, `--hero-equip=a,b`, `--hero-ult=id` (só na sessão, nada gravado,
  `Save._dev_hero`). Testes em `tests/test_hero_screen.gd`.
- **Compêndio** (E2-11, `CodexScreen`): abas Dons (os do Guerreiro na ordem em que destravam; antes, "???" e "Maestria N")
  e Golpes (a antiga `MovesScreen`, que saiu); aberto pelo Como Jogar e pela pausa; `--screen=codex|moves`. E4-05: oito
  abas numa fileira (Dons, Bênçãos, Elos, Salmos, Inimigos, Morvath, Arenas, Golpes; `CodexScreen.TAB_WIDTH` 120,
  cabe a 720): Salmos (descoberto: medalhão `PsalmIcon`, nome, efeito, vezes tomado; não: selo fechado, "???" e
  "Pista:" com o `hint_key`), Inimigos (`CodexScreen.ENEMIES`, nome, papel `codex_role_<role>` e derrotados, elites à
  parte; nunca derrotado "???"), Morvath (vezes enfrentado e selado, as 4 fases com nome e dica quando alcançadas,
  `phase_text` corta o `boss_phase_N` no primeiro ponto), Arenas (salão, as três arenas e a Câmara do Selo, vezes).
  Só texto de jogo (D-62 a). Dados no fim da partida por `Game.codex_run` (no `award_mastery`): `codex.enemies.<id>`
  `defeated`/`elite` (de `Game.defeated`, a elite conta para o comum), `codex.enemies.morvath` `met`, `phase` (o maior,
  `SaveData.codex_max`), `defeated`; seção nova `codex.arenas.<id>.entered` (`Game.arenas_seen`, `hall` para o salão).
  Testes em `tests/test_e4_ui.gd`.
- **Livro de Ahk (etapa 2 do pacote de arte, 2026-11-18; pranchas 04, 05 e 09 só locais; antes e depois em
  `docs/gallery/artpack/stage2/`)**: a tela do herói e o Compêndio são páginas de um livro aberto (`BookSpread`,
  `scripts/ui/book_spread.gd`: capa de couro, folhas, dois pergaminhos em `book_page.gdshader` com a dobra em `spine`,
  cantoneiras de ouro velho, fita petróleo; as páginas são `left`/`right` e se refazem quando o conteúdo muda de
  tamanho) na linguagem `Book` (`scripts/ui/book.gd`: tinta `INK`, `FADED`, rubrica `RUBRIC`, ouro que lê no papel `GILT`,
  `Book.theme()` sem contorno, `heading`, `section` "◆ EFEITO", `index_entry`, `ink(cor)` para escurecer cores de família
  e ramo no papel). `HeroScreen` tem três capítulos em marcadores (`HeroScreen.Chapter`: OPENING "Abertura", HERO "O
  Guerreiro", GIFTS "Dons"; abre em HERO com foco em "Dons"; `open(data, chapter)`): Abertura com as palavras de Ahk do
  cânone (`book_epigraph`, assinado "Ahk, o Escriba") e a descida em três passos (os mesmos sinais e textos do Como
  Jogar, `HowToScreen.step_glyph`); O Guerreiro com o retrato pintado (`assets/ui/hero/warrior_page.png`, recortado da
  prancha 04, IA, `docs/steam-ia.md`), Arma, Estilo e Habilidades com as marcas do HUD (`ActionSlot.mark`,
  `ActionSlot.glyph_mark` para a ultimate) e a passiva; Dons com a árvore numa lousa e o painel Efeito, Custo,
  Pré-requisito (`HeroLoadout.needs_text`), Estado e Próximo passo (`next_step`, `xp_missing`). "Descer às catacumbas" na
  Abertura e no Guerreiro emite `descend`, e o título faz o mesmo que o Iniciar (`boot._open_hero`; Juramentos antes
  depois da primeira vitória). Só o Guerreiro: nenhum outro herói, nenhuma vaga trancada. Árvore (prancha 09): cada Dom
  com o próprio glifo pelo efeito (`TalentGlyph`, nunca cruz nem sol; sem glifo cai no do ramo,
  `TalentNode.branch_glyph`), moldura de ouro velho com pontas, quatro estados (equipado, aberto, `BLOCKED` com a
  moldura cortada nas pontas e o glifo apagado, trancado com cadeado e nível), o foco acende em marfim o caminho do que
  o Dom pede (`TalentTree.path_of`, `TalentNode.on_path`) e o losango se ajusta ao espaço (`TalentTree.fit`). Compêndio
  (`CodexScreen`): índice na página esquerda (`SPINE` 0,3) com marca a tinta por capítulo (`CodexMark`) e quanto foi
  achado (`progress`, `codex_count`), cima e baixo andam no índice, direita vai ao Voltar; a lista na página direita em
  tinta, os Dons com o nó da árvore (`TalentGlyph.mark`). Capturas: `--title --screen=hero|gifts|book|codex` e
  `tools/book_lab.gd` (comando no topo). Testes em `tests/test_book.gd`.
- **Mapa da descida** (DV-1, MAP-03, lê o grafo do MAP-01): ação `map` em `Controls` (M, Back
  no controle; remapeável no teclado nas Configurações, linha "Mapa" no Como Jogar), botão discreto "Mapa [M]" ao lado do
  "Sala N de 11" no HUD (`Hud.map_button`: nunca toma o foco, abre no aperto para o clique, que também é o ataque, não
  golpear; tecla real) e "Mapa" na pausa logo abaixo de Continuar (M também abre de lá). `Hud.open_map` abre por
  `Game.open_screen` (a partida para) e fecha por `Game.close_screen` (`Controls.clear_presses`); a tecla é lida no
  `Hud._unhandled_input`, como a pausa lê a dela. Página do Livro (`MapScreen`, `scripts/ui/map_screen.gd`, `BookSpread`
  com `SPINE` 0,37): à direita o desenho (`MapGraph`: entrada no topo, Morvath embaixo, número da sala na margem,
  medalhão de tinta com a marca do `DoorGlyph` de cada nó, divisas de difícil e guardião ao lado, nome curto do guardião
  "Cavaleiro"/"Ancião" (`map_guardian_<id>`), caminho feito em rubrica, sala atual com aro duplo petróleo, portas abertas
  com aro e ligação de ouro, o que ainda alcança em tinta, ramos deixados apagados a 0,3); à esquerda a sala em foco
  (nome, "Sala N de 11", recompensa, difícil, arena, estado) e a legenda. Foco começa na primeira porta; setas, direcional
  e o ponteiro andam pelos nós (`DescentMap.step`); M, Back, Esc, Start ou Voltar fecham. `DoorGlyph.Kind.UNKNOWN` é o
  "?" do nó escondido (Q-25 a). Dados por `DescentMap` (`scripts/ui/descent_map.gd`, puro): `from_dict` lê
  o `RunMap.view()` (`{layers: [[{id, depth, slot, kind, reward, guardian, hidden, arena, next}]], path, here, doors}`;
  aceita também `current` e `hard`); `from_game` lê o `Rooms.map` da partida e marca "difícil" nas portas abertas pelo
  `Rooms.door_info`. Grafo fixo de teste `MapSample`
  (`--title --screen=map --map-at=start|middle|doors`, `tools/ui_lab.gd -- --map [--map-at=...]`). Testes em
  `tests/test_map_screen.gd` e `tests/test_input_leak.gd`; fluxo por teclado, controle e mouse em
  `tools/map_flow_check.gd`; capturas em `docs/gallery/dv1/ui/` (mapa no começo, no meio e diante das portas a 720 e 1080, sobre a partida, a linha de hoje numa partida real, HUD com o botão, horda de 300, Controles).
- **Tela de fim com Maestria** (E2-04, `MasteryReport`): "+N XP" ao lado da barra que enche do XP de antes ao de depois,
  de onde veio (só as fontes que deram algo), "Nível N alcançado" e "Novos Dons: ..." e "Nova ultimate: ..."; dados do
  `Game.mastery_report` (o `mastery_gain` e o XP antes, guardados no `log_run`, passados no `stats.mastery`).
- **Bênção no texto** (QW-018, D-50): o texto do jogador chama as cartas de Bênção (raridades no feminino: Comum, Rara,
  Épica, Heroica); "Dom" só nos Dons do herói (`talent_*`, `hero_*`, `codex_*`, `end_unlocked*`; teste em
  `test_hero_screen.gd`). Chaves, classes (`Boon`) e registro não mudaram.
- **C17, texto e HUD** (testes em `tests/test_c17_ui.gd`; capturas em `docs/gallery/c17/ui/`): o especial se chama
  **Onda de Luz** em todo lugar (QW-109, D-69; `move_bolt` também diz "Onda de Luz" até o `make_data.gd` trocar o título
  do nó para `move_wave`; o teste falha com "seta" em qualquer texto do jogador). **Um vocabulário só** para as ações
  (QW-110, Q-16): Ataque, Especial, Círculo, Esquiva, Ultimate nos Controles (`action_*` = `slot_*`), no Como Jogar, nas
  cartas ("O ataque incendeia", "O especial congela") e no Compêndio > Golpes, que mostra as entradas com os símbolos do
  HUD (`CodexScreen.move_marks`, `ActionSlot.mark`, "segurado" no Ômega), nunca E/D nem Leve/Pesado; "Avanço" só no Dom
  Avanço Feroz; "Descer de novo" e "Voltar ao menu" nos dois finais (`end_again`, `end_menu`). Maiúsculas (QW-118):
  nomes de Bênção, provação e maldição em Title Case, "Bênção" e "Magia" sempre maiúsculas. Números (BUG-113): vida,
  Magia, ouro e dano inteiros como no HUD (`BoonMod.WHOLE`, `UiKit.whole`; segundos ficam com uma casa). Como Jogar
  (BUG-106) com a ultimate de hoje (carga pela Magia e pelo dano causado e sofrido) e um quarto passo, "Provação e
  Altar" (`HowToScreen.STEPS`, selo pintado da Provação), também na Abertura do Livro. HUD: a fileira das Bênçãos que
  agem sozinhas para em 96% da largura e o último lugar diz "+N" (BUG-105, `Hud.PASSIVE_EDGE`, `passive_fit`,
  `passives_shown`: as com recarga primeiro); com tela aberta (escolha, pausa, evento) a fileira some e as saudações
  esperam paradas (`EloBanner.held`, BUG-107) e, na luta, saem sobre um véu escuro em elipse (`EloBanner.VEIL_*`); as
  divisas de fora da tela giram pelo meio e ficam acima da legenda da ultimate (`EDGE_INSET` 128, BUG-111); o nome do
  golpe some junto com o contador (`on_combo(0)`, BUG-112) e as transições do HUD correm em tempo real (`Fx.real_dt`);
  legenda da ultimate e tecla dos losangos em 14 px (`ActionSlot.CAPTION_FONT`, `KEY_FONT`). Compêndio e Livro inteiros
  a 720 (QW-114): nada de reticências, a lista do Compêndio rola (`CodexScreen._scroll`: roda do mouse, ou direita a
  partir do índice e cima e baixo; esquerda volta ao índice), corpo mínimo 14 px (as habilidades do Livro em 15 px na
  tinta). LB e RB (PageUp e PageDown) trocam abas e capítulos nas Configurações, no Como Jogar, no Livro e no Compêndio
  (`Controls.MENU_KEYS`, ações `tab_prev`/`tab_next`, `UiKit.step_tabs`; DT-103 em parte, o `title_flow_check` testa com
  eventos reais do controle). Juramentos e Músicas no painel das Configurações (`UiKit.page`, QW-113).

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
- O jogo abre em tela cheia (padrão desde 2026-11-16, `SaveData.VERSION` 2 passa os saves antigos para tela cheia uma vez; capturas, vídeos e `--nosave` ficam em janela, `App.apply_options`); a pausa tem "Sair do jogo" no desktop (`pause_exit_game`).
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`, versão 3 com heróis e Compêndio; versão 5 passa uma vez as músicas que estavam no padrão antigo para o padrão novo do MUS-1). Sem save (`--nosave`) não há recorde
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
  [--before] [--why] [--parts=music,air,sfx] [--wav=x]` refaz a mistura pelos barramentos (`tools/mix_replay.gd`) e mede
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

## Descida de Valmor (DV-1, frente de gameplay: MAP-01, MAP-02, MAP-04; backlog seção "Descida de Valmor")
- **Grafo da descida** (`RunMap`, `core/run_map.gd`, puro; a API que o mapa e o HUD leem está descrita no topo do
  arquivo): gerado no começo da descida num dado próprio (`Rooms.new_map`: `hash([semente da partida, Rooms.MAP_SALT])`;
  a mesma `--seed` dá o mesmo mapa, seja o que for que a partida sorteie antes). Camadas: 1 o salão (Bênção), 2 a 9 com 2
  a 4 salas (`StageDef.map_widths` 35/45/20%), a camada do guardião inteira (4 a 6; 1 ou 2 salas, `guardian_pair_chance`
  0,5: com duas, Cavaleiro e Ancião, Q-27 a, `Room.guardian`), a loja na 10 (Q-26 a), Morvath na 11: toda rota tem 11
  salas. Ligações sem cruzar (`_link`: cada sala liga a uma faixa de 1 a 3 salas lado a lado embaixo, a faixa seguinte
  começa onde a anterior acabou ou logo depois; todas as formas listadas e uma sorteada com o peso `map_doors` 1/5/2 pelo
  número de portas). Fonte numa camada de 5 a 8 (35% por camada, senão a 8) e uma segunda na 8 em outro ramo quando
  nenhuma rota passa pelas duas (`fountain_more_chance` 1,0, `_one_fountain`; cerca de metade das rotas tem fonte), altar em no máximo
  um nó (2 a 8, 20% por camada), Provação num nó de luta marcado `trial` e `hidden` ("?" no mapa até a laje aparecer,
  Q-25 a; `trial_chance` por nó, só onde a maldição mais curta cabe no pior caminho, nunca dois na mesma rota). Recompensas
  do baralho no gerador, camada por camada, nenhuma repetida na camada (então nunca em duas portas da mesma sala), romã só
  desde a sala 3 (`pom_from_depth`); ao abrir as portas, a romã que não puder subir vira Bênção antes da placa
  (`RunMap.settle`, `pom_turned`). Cada nó tem `fight_seed` (a mesma luta por qualquer caminho, `Rooms._prepare`). Arena
  por nó com as regras de antes valendo em toda rota (nunca a da luta anterior, o altar passa adiante a de antes dele;
  nenhuma mais de 3 vezes numa rota, contado por programação dinâmica; a menos usada primeiro; salas da mesma camada em
  arenas diferentes quando dá; a camada antes do guardião deixa o Santuário livre); o grafo é conferido
  (`_keeps_rules`) e gerado de novo se quebrar alguma (`failures`: 369 tentativas a mais em 1000 sementes, no máximo 5).
  `fights_left` (BUG-101) é o pior caminho: o menor número de lutas em qualquer rota até a loja. `--arena`, `--short`,
  `--medium`, `--start=` (o primeiro nó daquele tipo; `altar` gera o mapa de novo com o altar certo) e Juramentos seguem.
- **Portas = ligações** (MAP-02): `Rooms._enter` toma as portas do nó (`map.doors()`, porta i = `next[i]`); sala fora do
  grafo (testes) pega as portas do primeiro nó da profundidade. `door_info` ganhou `node`, `hidden`, `guardian_id` e
  `guardian_key`; `door_word` leva o guardião. A laje só aparece no nó `trial` (`Trials.open_at`) e revela o "?"
  (`RunMap.reveal`). `RESULT` e registro (`RunLog.VERSION` 4, `normalized` lê as versões antigas com `map` vazio e
  `node` -1): `map` (semente, nós `[profundidade, tipo, recompensa, arena, guardião?, "trial"?]`, arestas, caminho,
  `failures`, `pom_turned`), `rooms[].node`, evento `door` com `node` e `offered` e evento novo `reward` (o que a sala
  deu, ao lado do que a porta prometeu).
- **Robô** (MAP-04): `Rooms.bot_door(doors, altar_useful, life, map)` lê o mapa: o gosto de antes pela porta da frente
  mais `BOT_AHEAD` 1,0 do melhor caminho depois dela (`bot_way`: cada sala vale pela mesma ordem, Bênção 5 a Magia 1, a
  fonte `BOT_FOUNTAIN_AHEAD` 12, o altar útil 3,5). Régua refeita em `docs/qa/dv1_metrics.md`.
- Testes: `tests/test_descent.gd` reescrito (BUG-109: só sementes fixas, contagem de asserções igual em toda rodada):
  1000 grafos com todas as regras, 100 sementes com pelo menos 95 grafos diferentes, pior caminho conferido por todas
  as rotas, 200 descidas do robô em que a sala é a que a placa disse, a recompensa dada numa sala real; mais
  `test_trial.gd` (500 grafos), `test_rooms.gd`, `test_economy.gd`, `test_altar.gd`, `test_e5_wiring.gd`,
  `test_run_log.gd`.

## Arenas (ciclo C12, Arenas I; plano em `docs/design/cycle12_arenas_plan.md`, plantas em `docs/art/cycle12_arenas_spec.md`)
- A descida tem 10 salas e Morvath na 11 desde a E3 (era a de teste de 7, D-27, hoje `--medium`): abertura no Salão das
  Catacumbas, lutas sorteadas entre a Cripta dos Esquecidos, o Salão das Fendas e o Jardim das Raízes Mortas (nunca a
  mesma duas vezes seguidas, nenhuma mais de 3 vezes, a menos usada primeiro, `RunMap._layout`, `RunMap.uses`),
  guardião na 4 a 6, fonte uma vez na 5 a 8 (no salão), loja na 10 (no salão), Morvath na 11. `--short` volta à de 5.
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
- **Pacote de direção de arte, etapa 4, cenário (2026-11-17, prancha `07-salas-combate.png`, só local em
  `docs/art/ref/direcao_2026-11-17/`; antes e depois na GPU em `docs/gallery/artpack/stage4/`)**: o desenho fica onde a
  colisão para. `tools/fit_probe.gd -- --arena=garden|rift [--variant=n] [--png=x]` mede numa grade de 0,1 m vista de cima
  o que está desenhado acima do joelho no chão livre (`phantom`), peça que bloqueia sem desenho (`bare`), chão sem
  superfície (`void`) e superfície de chão fora do chão (`ledge`). Jardim: o peitoril das janelas sai só `SILL_OUT`
  0,12 m da parede, o contraforte do canto noroeste corre ao longo do corte e a mureta quebrada fica `CUT_WALL_OUT` 0,8 m
  fora; as raízes desenham os lombos do tronco até o último ponto (`StoneTree.ROOT_BODY` 0,8 do perfil) e mergulham no
  chão nos `ROOT_PAST` 0,75 m depois (acima de 0,15 m até o fim quadrado da cápsula; o mergulho invisível não conta no
  `footprint`, `FOOT_SEEN`); musgo no chão ao longo das raízes, em volta do tronco e no pé das paredes norte e oeste
  (`GardenLook._moss`, `MOSS_*`, `root_moss.gdshader`: uma malha, um material, verde-cinza abaixo do valor das lajes;
  no Compatibility menos dele, `MOSS_COMPAT_COVER` 0,55).
  Fendas: lascas dos lábios um degrau abaixo do chão (`ArenaRoom.LIP_SINK` 0,2 a 0,42 m; eram 3 a 16 cm e liam como
  chão), balaustrada quebrada longe das pontas da borda (`BALUSTRADE_END`: passava por cima da cabeceira da ponte). Toda
  arena: os pilaretes da boca da porta ficam fora do chão, sobre as bochechas (`DOOR_POST_OUT`). Medido (m²,
  antes e depois): Jardim A fantasma 8,8 para 2,0, peça sem desenho 3,0 para 1,6; Fendas A fantasma 3,7 para 1,5, borda falsa 11,1
  para 5,1 (o que sobra fica nas bocas das portas e longe da borda). Placa de ouro da porta: a gema é uma moeda de pé
  girando (`Rooms.gem_mesh`, `GEM_COIN`; Bênção prisma, romã fruta). Câmara do Selo: meias-luas de Morvath em violeta
  frio com núcleo marfim-lilás (`Boss.SOUL_VIOLET`, `core_color` e `edge_pale` no `soul_crescent.gdshader`; o rastro e o
  ajuntar das almas também; eram o verde espectral) e a rachadura e os veios do selo descem a `SealLook.HUSH` 0,45 da luz
  enquanto ele prepara e lança um ataque (`hush_for`, chamado pelo `BossChamber.on_cue` nos avisos de foice, lâminas,
  tempestade, maldição, investida e runas; nunca na quebra do escudo nem na vitória). Testes em
  `tests/test_artpack_env.gd`.
- `RESULT` e o registro trazem `rooms` (por sala: profundidade, arena, vida ao entrar, dano por fonte, tempo e primeiro
  contato), `hp_at_boss`, `arena`, `stuck`/`stuck_by` (inimigo que queria andar e ficou 3 s parado) e `shots_blocked`;
  desde o C12c também os campos do GP-02 por sala e `boons_at_boss`, `shop`, `fountain_used` (ver Registro das partidas).
- Opções: `--arena=crypt|rift|garden|hall` (a primeira sala), `--variant=n`, `--short`, `--trace-steps` (imprime os
  passos acima de 4 ms e onde o tempo foi), `--trace-cam` (maior salto do alvo da câmera por sala, GP-06). Laboratório sem personagens, com grade, bordas, peças, zonas e câmera:
  `tools/arena_lab.gd` (comando no topo; `--top` vista de cima). Testes: `test_arenas.gd`, `test_descent.gd`,
  `test_killing_blow.gd`.
- **E5, cenário das arenas novas e das câmaras de evento** (`docs/art/e5_spec.md`; capturas em `docs/gallery/e5/env/`):
  cinco looks novos em `ArenaRoom.LOOKS`, escolhidos por `RoomLayout.look`, que desenham o `RoomLayout` que recebem
  (peças por `ArenaObstacle.piece`, nada do plano no código): `sanctuary` (`SanctuaryLook`, Santuário Desmoronado: nave
  de colunas, paredes norte e oeste com janelas cegas, presbitério elevado atrás da grade em frente ao `boss_spawn`, dois
  fachos de lua `moon_shaft` com poeira; variante B com o buraco para a cripta de baixo, `UNDER`), `bridge` (`BridgeLook`,
  Ponte dos Condenados: plataformas e pontes lidas do chão, polígono de 4 cantos até `DECK_WIDE` 5,2 m é ponte e o largo
  entre duas é o patamar da ponte longa da B; lábios quebrados ao norte, balaustradas nas outras bordas, estátuas nas
  cabeceiras, pilone `pylon` com correntes, bruma que corre de lado, `ArenaKit.mist_bank(..., drift)`), `runes`
  (`RunesLook`, Câmara das Runas Instáveis: chão em lajes de 3 m com moldura de ouro velho e marcas retas,
  `rune_floor.gdshader` = o chão das catacumbas com `#define RUNES` e `rune_tiles.gdshaderinc`; estado por laje numa
  textura 10 x 8 que o gameplay escreve: `set_tile(t, arm, fire, ember)`, `set_chevrons(dir)`, `apply()` uma vez por
  quadro, `tile_at`, `tile_rect`, `clear_tiles`, `heat`, `is_quiet`; a lâmina do disparo em `rune_flash.gdshader` sob o
  teto da tela, até 4 luzes âmbar sem sombra só no Forward+; pilares `rune_pillar` com sulcos que esquentam; estelas
  com marcas retas; laje quieta `quiet` da B lisa; nada redondo, D-29), `trial` (`TrialLook`, Provação: veias lilás
  `trial_veins.gdshader`, bloco `trial_block` com a rachadura em X `x_crack.gdshader`, um foco marfim com a única
  sombra, lanternas frias, `settle(s)` apaga 60%, `vein_level`, `SETTLED`; a laje de entrada na sala anterior é
  `TrialLook.entry_slab(pai, onde)`), `altar` (`AltarLook`, Altar Esquecido: arco cego com faixa gasta sem texto,
  leão em relevo na frente do `altar` (`altar_lion.gdshader`, o campo do selo), 11 velas apagadas, estandartes
  desbotados (um rasgado), facho frio; `kindle(s)` acende as velas com uma luz com sombra, `lit()`). Comum em
  `ArenaRoom`: a ponte e os lábios do Salão das Fendas (`bridge(r, ..., arches, open)`, `broken_lip`, `deck`, `parapet`;
  as Fendas não mudaram, antes e depois na GPU), `wall`, `wall_part`, `cut_wall`, `door_gaps`, `closed_edge` (sala
  fechada: parede ao norte e oeste, corte baixo na frente), `blind_window`, `round_column` (a coluna da Cripta),
  `drums`, `moon_shaft`, banco `TombKit.bench` (peças `bench`, `bench_broken`), toco `column_base`, `door_lamp()` e o
  bafo de luz da porta (`breath(i, look)`: cartão de 4 x 3 m na boca da porta usada, na cor do ar da próxima arena,
  `BREATH`, maior canal 0,6, sem luz; chamado quando as portas abrem). Plantas de laboratório com as medidas da spec em
  `tools/e5_layouts.gd` (`arena_lab.gd` cai nelas quando o estágio não tem o id; `--state=arm|fire|after` chama
  `demo`, `--measure=s` imprime `FRAME`); capturas em lote `tools/e5_shots.sh`. Sombras por sala no Forward+: santuário 5 (B 4),
  ponte 2 (B 1) mais a lua, runas 2 (B 3), provação 1, altar 2; no Compatibility os fachos `moon_shaft` não fazem sombra
  (`ArenaRoom.compat()`; listras). Quadro na GPU a 1080: 1,4 a 2,3 ms. Testes em `tests/test_e5_looks.gd`.

- **C18, a tela de um jogo acabado (cenário; antes e depois e a tabela de luma e saturação em `docs/gallery/c18/`)**:
  recompensas de verdade (QW-106): disco de ouro velho sobre pedestal da pedra do salão, o medalhão pintado
  (`assets/ui/events`: romã, selo da Provação, velas) ou a marca da `DoorGlyph` cunhada em esmalte da cor da recompensa,
  virado para a câmera e balançando devagar (`RewardGem`, `scripts/game/reward_gem.gd`, `reward_gem.gdshader`; halo
  `reward_halo.gdshader` abaixo do glow; um material por tipo, nenhuma luz própria); no `rooms.gd` só a chamada mudou
  (`Rooms.gem_mesh` saiu). Paleta num tom só: bruma, brilho e névoa do abismo e céu do salão menos saturados
  (`ArenaKit.MIST`, `ABYSS_*`, `RUIN_EDGE`, `Game.SKY`/`FOG`, `CatacombHall.ABYSS_LIGHT`, `BossChamber.ABYSS_COLOR`,
  `BLUE_COLOR`), metade das velas acesas que restavam no salão apagada, clareiras pálidas em todo chão
  (`clearing*` no `catacomb_floor.gdshaderinc`) e o ar de cada arena mais claro (`ambient_gain` e lua no `air()` de cada
  look), luz das portas acesas metade para um branco morno (`ArenaKit.DOOR_LIGHT_*`; o vermelho de Morvath fica inteiro),
  preenchimento das paredes do fundo na Cripta e no Santuário (`ArenaRoom.wall_fill`, `WALL_FILL`), Fendas, câmara e o
  ar da fase 4 (`RoomMood.LAST_BREATH`) violeta mas abaixo de 0,45 de saturação. Verdes de Morvath longe do herói: domo do ritual no matiz 165 (`BossShield.DOME_*`), erupções translúcidas com
  miolo vermelho até 0,35 sobre o que está atrás (`eruption_color`, `danger_alpha` no `ritual_rune.gdshader`, que agora é
  `blend_premul_alpha`; alfa até 0,24), runa de invocação no matiz 165 sem ciano (`color`, `spirit`), partículas espectrais até 0,12 m e nunca a menos de 1,5 m do herói (`Fx.CLEAR_OF_HERO`,
  `HERO_CLEAR_M`). Leitura do chão: Ponte B com o parapeito contornando o patamar (Q-10 a, `BridgeLook._read_floor`),
  Santuário B com `broken_lip` nos buracos, Runas B com a pedra quieta clara e um fio de ouro (`quiet_*` no
  `rune_tiles.gdshaderinc`); parapeito das pontes virado para a câmera em pontilhado em volta do herói
  (`ArenaRoom.faces_camera`). Runas (QW-108): preenchimento até 0,25 e âmbar acinzentado (`fill_*`, `fill_grey`,
  `heat_glow`), sulcos dos pilares em `rune_groove.gdshader` (`RunesLook.GROOVE_HEAT`). Colunas inteiras com ábaco
  quadrado, sem os arcos que liam como "Y"; no Santuário três silhuetas pelo lugar (capitel, capitel com imposta e anel,
  quebrada; `ArenaRoom.column_kind`, `IMPOST`, `ANNULET`, `COLUMN_BROKEN`; colisão igual). Câmaras da Provação e do
  Altar com ruínas em duas profundidades e bruma embaixo (`ArenaRoom.backdrop`, `BACKDROP_*`). Entulho do KayKit fora do
  salão (`CatacombHall._rubble`, `RUBBLE*`; as velas da pedra leste bloqueiam como se leem, `EAST_CLUTTER`), e o
  `tools/fit_probe.gd` conta também os círculos e caixas da própria sala (`Arena.overlaps`). Jardim: cristais escuros com brilho só na aresta
  (`crystal_edge.gdshader`) e copa de cartões procedurais (Q-21 a, `GardenLook._canopy`, `canopy.gdshader`, `CANOPY_*`,
  um MultiMesh, abre em volta do herói). Onda do especial 25% maior no desenho e rastro mais claro, acerto igual
  (QW-111, `look_scale`, `wake_light` no `emeth_wave.gdshader`). Medir uma captura: `python3 -I tools/frame_stats.py
  imagens... [--box=x,y,w,h]` (luma e saturação como o relatório de arte, violeta acima de 60%, verde e rosa na caixa). Com `--hue` (RS-0.5) sai uma tabela por região (quadro, `--scene` = sem HUD, x 5 a 95% e y 8 a 85%, e cada `--box`, que se repete): matiz médio circular pesado pela saturação HSV (o da matriz do redesenho), matiz p10/p50/p90 dos pixels acima de `--sat-min` (0,1), saturação HSV p50, luma p10/p50/p90 e as faixas quente, vermelho, verde, ciano, verde+ciano e violeta em % dos pixels (só biblioteca padrão e ffmpeg).
- **AP-1 "Nada de protótipo" (cenário; itens ART-01.2, 01.3, 01.4, 01.6, 02.3, 02.5, 03.7 e 04.2 do
  `docs/art/art_polish_backlog.md`; antes e depois na GPU e as medidas em `docs/gallery/ap1/`)**: o medalhão de cada
  recompensa tem o esmalte da família (`RewardGem.ENAMEL_*`: matiz, saturação e valor, teto `ENAMEL_MAX` 0,5 / 0,45;
  Bênção petróleo com a marca em marfim, Ouro sem esmalte, a própria moeda com serrilha, `all_gold`), a marca a 60% da
  face (`mark_size`, cada marca escalada pela própria extensão, `mark_extent`), disco de 2 m (`RADIUS` 1,0, cerca de 90 px
  a 1080) com o topo abaixo do pé da placa (`Rooms.MARK_SIGN_Y` 2,7), o halo atrás do disco na linha da vista
  (`HALO_BACK`; atravessando o disco ele velava meia face) e a face sem receber sombra. Onde se pega a recompensa ele
  pousa num relicário de pedra (`RewardGem.Stand`, `_reliquary`: degrau de pisar à frente, `STEP`, sobre o ponto do
  toque, que não mudou; corpo atrás, longe da câmera, `RELIQUARY` até 0,5 m; filete de ouro velho; pano petróleo com o
  leão de ouro velho, Q-22, `reliquary_cloth.gdshader`; haste e berço de ouro velho); sobre a boca da porta ele continua
  solto (`RewardGem.at_door`, pelo `Arena.door_label`). A chamada no `rooms.gd` não mudou (`Stand.AUTO`). Estela da
  Provação no lugar do cubo com X (`TrialLook._block`, `STELE*`, `SEAL`: pedra em pé virada para a câmera, rachada do
  ombro ao pé com a parte direita inclinada, o selo em relevo, a luz lilás só na fenda, `stele_crack.gdshader`; colisão
  igual). Câmaras de evento assentadas (`ArenaRoom.closed_edge`): a ponta da parede alta que encontra a frente baixa cai
  em degraus com entulho (`RUIN_END`, `RUIN_STEPS`, `_ruin_end`; só em canto de verdade, `_side_out`, `_low`) e além da
  frente baixa o chão continua quebrado sobre rocha que desce para a bruma (`_apron`, `APRON_*`, portas livres);
  Provação com luz só do chão (`TrialLook.FLOOR_FILL*`, `floor_layers`), céu, névoa, fundo e rocha mais claros
  (`AIR`, `CLIFF`, `BACKDROP_*`): luma 43 para 56. `tools/fit_probe.gd -- --arena=trial|altar` mede as câmaras. Fonte de pedra (`ArenaKit.fountain`, chamada pelo
  `Game._spawn_fountain`; bacia baixa em blocos, água escura com anéis e brilho pálido, `fountain_water.gdshader`, bica
  com taça e o borbotão marfim-azulado baixo; `fountain_spent` apaga a água quando ele bebe). Portal do salão com
  profundidade (`portal.gdshader`: oco escuro, anéis partidos que entram, veios, coração pálido pequeno, esmeralda
  escuro `body_saturation`, `body_value`, `body_tint`, teto `cap`). Braseiros sem miolo branco (`ArenaKit.FLAME*`,
  `FLAME_CORE` âmbar, chama um terço mais baixa, `BRAZIER_FIRE`; a luz igual). Janelas da Câmara do Selo em lanceta com
  caixilho, montante e travessa e luz em degradê (`far_window.gdshader`, `BossChamber.FAR_WINDOW_*`, um par aceso e um
  apagado; a janela da torre também).

## E5, eventos e exploração (spec de arte `docs/art/e5_spec.md`; métricas em `docs/qa/e5_metrics.md`)
- **Três arenas novas** no `_stage` do `make_data.gd` (`_sanctuary`, `_bridge`, `_runes`, duas variantes cada, dificuldade 2):
  Santuário Desmoronado (casa do guardião: `RoomLayout.guardian_home`, `RunMap._layout` manda o MINIBOSS para ela em qualquer
  profundidade se não foi a sala anterior; ele nasce em `boss_spawn` diante da grade; variante B com a nave afundada),
  Ponte dos Condenados (comprida, três plataformas e duas pontes de 5 m, portas só na plataforma leste, sem sacerdote,
  ninguém nasce numa ponte; B com a ponte longa e o patamar) e Câmara das Runas Instáveis (4 a 6 inimigos, no máximo 2
  atiradores, câmera fixa). Partes do chão com nome (`RoomLayout.areas`, `area_names`, `area_at`): o tempo do herói em
  cada uma vai para `rooms[].zones` do `RESULT` (`RoomTally.zone_time`). Desenhadas pelos looks do E5 (ver a seção de
  cenário acima; o `PlainLook` provisório saiu). Peças do dado com o nome que o look desenha: `column` (5 m ou mais ganha
  capitel), `column_base` (toco, para corpo e não tiro), `drums`, `bench`/`bench_broken`, `pylon`, `rune_pillar`, `quiet`
  (a pedra quieta da B das Runas, caixa que não barra nada), `trial_block`, `altar`; braseiros de parede (`brazier`) a 0,9 m
  ou mais fora do chão, os da grade do Santuário são do look. Cada porta que abre sopra o ar da sala de trás
  (`ArenaRoom.breath`, `Rooms.door_look`; Morvath = `chamber`). Opções: `--arena=sanctuary|bridge|runes`, `--start=trial|altar`.
- **Runas** (`HazardDef` no `RoomLayout.hazard`, lógica pura `ArenaHazard`, no jogo `RuneFloor`): grade de 10 x 8 ladrilhos
  de 3 m; padrões só em faixas e ladrilhos (A: `sweep`, `comb`, `cut`; B: `checker`, `frame`, `islands` e a pedra quieta no
  meio); aviso 1,2 s, golpe 0,25 s, descanso 2,4 s, nada nos 3 s do começo, nas portas nem em ladrilho cortado pela borda;
  no máximo 35% aceso (os densos, 50%, só com até 3 inimigos de pé) e todo ladrilho aceso tem um vizinho apagado. Fere o
  herói 4 (como aviso, `Ground.add_hazard`) e todo inimigo comum em cima 35 (`Ground.hazard_landed`); "Derrotado por: Runas
  Instáveis" (`killer_runes`). Desenho: estilo `GroundLook.Style.HAZARD` (âmbar `HAZARD_COLOR`, moldura por ladrilho
  `tile_m`, preenchimento fraco, `render_priority` -1, abaixo dos avisos vermelhos), mas na sala de verdade quem desenha é o
  próprio chão: o `RuneFloor` escreve a cada quadro o estado de cada ladrilho no `RunesLook` (`RuneFloor.paint`:
  `ArenaHazard.state` = preparo, golpe e brasa de 0,4 s, `ArenaHazard.EMBER`; divisas da varredura por `ArenaHazard.chevron`
  só no preparo; um `apply`, nada quando em repouso) e os avisos do `Ground` ficam invisíveis (`add_hazard(..., drawn)`,
  nada desenhado duas vezes; continuam ferindo). Grade conferida contra o look (`RuneFloor.fits`, 10 x 8 de 3 m desde
  (-15; -12)); em outro look o âmbar volta. `rooms[].hazard` no `RESULT`.
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
  Reserva e Firmeza (`magick_max`, `max_hp`), somados às Bênçãos em `BoonState.stat` (`equip_talents`). Tela do herói: `HeroScreen` (ver Tela de título). Testes:
  `test_hero_def.gd`, `test_mastery.gd`, `test_talents.gd`, `test_save.gd`, `test_run_log.gd`.
- **Passiva e os 19 Dons agindo (E2-07, E2-09; escolhas na `warrior_spec.md` 4.5)**: todo efeito é estatística dos `mods`
  do Dom (com a tag do golpe) lida por `GiftState` (`core/gift_state.gd`, puro) e feita por `HeroGifts`
  (`game/hero_gifts.gd`, `Game.hero_gifts`, criado depois do `_equip_talents`; `Game.equip_talents(ids)` para testes),
  `Combat` (sinal `landed(node, tags, hits)`, uma vez por golpe que acerta alguém, e uma por onda no primeiro inimigo;
  `kill_tags`/`kill_blow` dizem o que derrubou cada abate; Fúria Plena e as ondas dos Dons em `_gift_wave`) e `Player`
  (`omega_discount`, `give_dodge_back`, `show_fury`, `use_tree`, Ainda de Pé em `hurt`, sinal `rose`). Passiva P-A: 2 de
  Magia por golpe com `HeroDef.passive_tags` (finisher, dash, omega) e nenhuma `passive_never` (ultimate), nunca acima
  do máximo; `--no-passive` desliga (com ela desligada e sem Dons a partida é igual à de antes, mesma semente). Quarto
  Corte troca a árvore (`TalentDef.combos`, `data/combos/paladin_fourth.tres`, estocada `thrust4` de 30, DPS do combo
  86,5 contra 86,1); Passo Encadeado e Golpe sem Fim por `ComboRunner.chain_from(opener())`; Ímpeto por
  `ComboRunner.speed` (preparo, brilho, trava, pernas e clipe); ondas de Dom pelo `Projectiles.fire_wave` (`Shot.counted`,
  `Shot.through` da Onda Atravessante, que atravessa a pedra: a seta já atravessava todos os inimigos); Respiro no
  `Rooms._room_cleared`; Coração da Emeth expõe `ult_charge_pct` para a ultimate. Testes em `tests/test_warrior_talents.gd`.

- **Ultimates (E2-08, E2-10)**: ação `ultimate` (R, LB no controle), carga `UltCharge` (`core/ult_charge.gd`) pela Magia gasta (`Magick.spent`; U-1 60, U-2 70; `ult_charge_pct` do Coração da Emeth acelera) e, desde a T5 (`docs/design/t5_ultimate.md`), pelo dano causado (`UltDef.damage_charge` 0,02 por ponto, sem os acertos da própria ultimate) e pela vida perdida (`hurt_charge` 1,0; `RESULT` `ult.charged`); sem escolha no save, a descida joga a primeira que a Maestria abre (`HeroDef.ult_for`, gravada no save); o 5º losango aparece trancado com "Maestria 2" antes de abrir, pulsa e diz "Pronta" cheio, e R sem poder diz por quê (`Player.ult_refused`, `Hud.ult_caption`; testes em `tests/test_t5_ultimate.gd`), gesto `Player` estado `ULT` 0,3 s protegido que corta o golpe como a esquiva; efeitos em `scripts/game/ultimates.gd`: U-1 Corte do Juízo (faixa 12 x 4 m, 300 no miolo e 200, armadura em dobro, atordoa 1 s, `ult_rift.gdshader`), U-2 Voragem (6 m a 4 m à frente ou no cursor até 8, 4 s, tiques de 8, implosão 120, espiral por `Arena.sweep`; elites 50%, guardiões 25%, Morvath só lento; `ult_vortex.gdshader`: véu esmeralda até 0,3, três braços marfim, aro de ouro velho que se fecha na implosão, tetos em `Ultimates.vortex_peaks`). Golpes com tag `ultimate` nunca são finalizador nem Ômega. 5º losango no HUD. `--ultimate=cleave|vortex`, `--ult-full`, `--shot-on=ult`. Testes em `tests/test_ultimate.gd`; sonda 40 metas (E2-U1 a U3).

## Salmos (E4-01 e E4-02; regras, números e escolhas em `docs/design/e4_psalms.md`)
- `PsalmDef` (`core/psalm_def.gd`, `data/psalms/`, parte `psalms` do `make_data.gd`): nome só por tema, sem número nem
  texto bíblico (D-59 (a); teste nas chaves `psalm_*`), `theme`, `slot` (a ação que transforma), três grupos `requires`
  (id de Bênção ou Elo, ou `dom:` + id de Dom equipado), `effect` (SENTINEL, SHELTER, FLOCK, STONE) e os números.
  Regras puras em `Psalms` (`core/psalms.gd`): uma coisa por grupo e nunca a mesma para dois (`met`), 10% por carta e 5%
  no guardião (`StageDef.psalm_chance`, `guardian_psalm_chance`, `Psalms.fill`; o dado só é lido quando algum pode vir),
  um por tema, dois por partida (`MAX_PER_RUN`). Efeitos em `PsalmPlay` (`game/psalm_play.gd`): **Sentinela** (o círculo
  anda com ele e golpeia com 30 quem entra, `Ground.Zone.follow`/`strike`), **Abrigo** (onde a esquiva termina, abrigo de
  2,6 m por 3 s, até 2, que desfaz tiros inimigos menos as meias-luas, `Ground.Kind.SHELTER`, `Projectiles.shelter`),
  **Pastor** (abate reúne luz, até 3; o especial solta uma onda a mais por luz em leque de 14 graus, `Combat.throw_wave`),
  **Rocha** (o giro planta pedra de luz: 30 em 4 m, atordoa comuns 1 s, fica 3 s deixando lento, `Ground.Kind.STONE`).
  Carta: `BoonState.Card.psalm`; `Game.psalm_offered(psalm, first)` e `psalm_taken(psalm, first)`, `Game.choose_card`;
  gente recebe carta de Salmo desde a E4-03 (`BoonChoice.open_cards`, sinal `card_chosen`, ver Tela de dons). Robô e `--autopick` pegam o Salmo; `--psalm=a,b` toma no começo. Compêndio `codex.psalms` (`seen`,
  `taken`) e Maestria (`new_psalms`) no fim da partida; `RESULT` e registro com `psalms`; dano em `dealt_by.psalm`.
  Testes em `tests/test_psalms.gd`.

## Juramentos (E6, D-63; regras, números e escolhas em `docs/design/e6_juramentos.md`)
- Os votos do Juramento do Hades II, abertos depois da primeira vitória (`Juramentos.unlocked`: `wins > 0`), Medo vira
  **Peso**. Nove em `data/juramentos/` (`JuramentoDef`, parte `juramentos` do `make_data.gd`: `stat`, `values` e
  `weights` por nível): Golpes Duros (dano), Mortos Resistentes (vida de todos, Morvath também), Passo Ligeiro (andar),
  Mais Mortos (ondas maiores), Mais Elites, Feridas Abertas (cura), Preço Alto (loja), Escolhas Perdidas (2 Bênçãos não
  escolhidas saem da descida, `BoonState.banned`), Morvath Implacável (descansa menos, ergue mais); Peso máximo 30.
  Regras puras em `Juramentos` (`core/juramentos.gd`: Peso, `scale`, `stage_for`, `boss_for`, `more_waves`, `denial`);
  ganchos em `Game._swear_juramentos` (`Horde.vow_hp`), `Rooms.setup`/`_apply_curse`/ondas, `Boss.setup`, `Game._take`.
  Save versão 4 (`juramentos`: `ranks`, `best`); `RESULT` e registro com `juramentos` e `weight`; vitória dá
  `MasteryCurve.weight_xp` 3 por Peso (fonte `juramentos`). Tela `JuramentoScreen`: depois da primeira vitória o Iniciar
  abre os Juramentos com "Descer" em foco. Sem save (testes, `--nosave`) e para o robô, nenhum. Opções:
  `--juramentos=pain:2,grit:1`, `--wins=N` (abre só na sessão), `--title --screen=juramentos`. Testes em
  `tests/test_juramentos.gd`.

## Balanceamento da região (E6; decisões em `docs/design/e6_balance.md`, números em `docs/qa/e6_metrics.md`)
- Medir com `tools/smoke.sh 900 --seed=N --bot-reaction=0.25`, 72 sementes; Maestria 20 = `--talents=` (o robô não lê o
  save nem `--hero-equip`; Dons que ficam de fora agora geram aviso, `Talents.why_dropped`). Robô 0,25: Maestria 1 vence
  72%, Maestria 20 (montagem de sustento, a mais forte) 90%, diferença 18 (teto 25).
- Ainda de Pé não levanta na sala de Morvath (`GiftState.boss_room`, estatística `rise_boss_share`, hoje 0): com ele lá
  a Maestria 20 nunca perdia. Vida de Morvath fica 6050; carga da ultimate segue pela Magia gasta (`ult.boss_uses` e
  `boss_damage` no `RESULT`).
- O robô escolhe a carta da Provação pelo custo da maldição (`Trials.bot_card`; Pobreza só depois da loja), só entra no
  altar para trocar (`Rooms.bot_door(doors, altar_useful)`) e guarda 50 de ouro para a loja (`Altar.BOT_GOLD_KEEP`).

## Onde mexer
- **Elo** (mecânica das Crônicas de Eterra) = dom duplo do Hades: família `DUO` em `scripts/core/boon.gd`, dom com
  `requires_sets` (E3-02: uma lista por família, uma Bênção de cada forma o Elo; `BoonState.forged`), 12% por carta,
  sem raridade e sem nível (BUG-017; `Boon.has_rarity`, `max_level` 1) (6 hoje; nome "Elo" no texto desde 2026-11-15). A carta mostra os dois dons de origem
  numa corrente de ouro velho com o Elo no meio (`EloLink`, `BoonState.sources`), o medalhão do Elo tem aro de elos,
  a HUD saúda cada Elo novo com "Elo formado" sem pausar (`EloBanner`) e a pausa tem o painel "Suas bênçãos" (`BoonsScreen`).
  Capturas dessas telas numa partida real: `tools/ui_lab.gd` (comando no topo).
- **Pacote de direção de arte, etapa 1B (menus, pranchas 06 e 10, só locais em `docs/art/ref/direcao_2026-11-17/`;
  antes e depois a 720 e 1080 em `docs/gallery/artpack/stage1b/`)**: uma linguagem só para as páginas de menu em
  `UiKit` (`page`: painel de tinta com fio de ouro velho e sombra, título Cinzel sobre o `GoldRule`, o antigo
  `EndScreen.Ornament`; `primary` para a ação principal em bronze; `tab` com a aba à mostra em petróleo; `link` para as
  saídas discretas; `section` "Nome ———"; `focus_row` para linhas que tomam foco dentro de rolagem; `gift_icons` e
  `carried_of` para os medalhões levados). **Pausa** (`PauseMenu`): o quadro congelado fica, escurecido só à esquerda
  (`SHADE_*`), painel compacto à esquerda com Continuar em destaque, Bênçãos, Compêndio, Configurações, os medalhões da
  descida ("Bênçãos da descida: N", até 15 e "+N") e no rodapé Sair para o menu e Sair do jogo; cima e baixo dão a volta,
  e a página aberta devolve o foco ao botão que a abriu. **Suas Bênçãos** (`BoonsScreen`): grupos Ações (pela ordem das
  ações, `Boon.slot`), Efeitos automáticos (`Slot.NONE`) e Elos (`BoonsScreen.group_of`); à esquerda uma entrada por
  grupo com a contagem, que leva o foco à primeira linha; à direita a lista rola com o foco. **Créditos**
  não são tela (o Daniel, 2026-11-18: "não tem nada"): `CREDITOS.txt` na raiz, copiado ao lado do exe e depois na página
  da Steam, com todas as atribuições (CC BY de Kevin MacLeod e Little Robot Sound Factory exigem crédito).
  **Vitória** (`EndScreen`): primeiro a selagem sozinha (`SealEmblem`: aro de ouro velho que se fecha em volta do leão do
  selo da Câmara, `lion_sdf.res`, que acende; nunca sol nem cruz), depois o resumo sobe (`SUMMARY_AT` 2 s); apertar
  durante a selagem mostra tudo (`finish_sealing`). **Derrota**: painel com o título, "Derrotado por", onde caiu, as
  Bênçãos levadas, a Maestria, os números e Tentar de novo (`primary`, com foco) e Menu. **Configurações**
  (`OptionsScreen`): abas Áudio (volumes em régua com losango, clicável, `Gauge`; Músicas), Vídeo, Conforto e Controles
  (teclas com o valor à direita, Teclas padrão); andar sobre uma aba mostra a página dela, baixo entra nela; o foco
  guardado num `_build` abre a página onde está. **Como Jogar** (`HowToScreen`): abas "A descida" (três passos:
  portas, Bênçãos, Morvath na Câmara do Selo; `howto_step_*`) e Controles (a tabela de teclas de antes); Compêndio
  e Voltar no rodapé. A prancha 10 mostra escolha de capítulo: o jogo tem uma região, então não há. Tela do
  herói: só o `GoldRule` (a árvore é da etapa 2). Capturas: `tools/menu_lab.gd` (comando no topo; pausa com poucas e
  muitas Bênçãos, Suas Bênçãos no topo e rolada, derrota, vitória em três momentos e, com `--title-screens`, Como
  Jogar, cada aba das Configurações e Músicas). Testes em `tests/test_menus_1b.gd`.
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
  [--held=x,y] [--rarity=0,2,1] [--upgrade=0,1,0] [--trade] [--rest] [--focus-move]`; galeria em
  `docs/gallery/boon_cards/` e `docs/gallery/e3/ui/`; testes em `tests/test_boon_cards.gd` e `tests/test_e3_ui.gd`.
  **Pacote de direção de arte, etapa 1A (2026-11-17; pranchas só locais em `docs/art/ref/direcao_2026-11-17/`, antes e
  depois em `docs/gallery/artpack/stage1a/`)**: título "Escolha uma bênção" (`choice_title`; a dica embaixo diz que a
  Bênção fica até o fim da descida). Medalhões pintados também de `brasas`, `toque_geada`, `onda_maior` e `escudo`
  (`tools/cut_medallions.gd -- --board=... --grid=4x3 --names=...`, modo grade, 384 px, máscara pelo aro redondo) e
  das trocas do altar e do selo da Provação em `assets/ui/events/` (`BoonArt.event`: `pomegranate`, `candles`,
  `passage`, `trial_seal`); o Salmo do atlas (livro com cruz) não entrou. Glifos pequenos com o mesmo motivo
  (`BoonIcon.glyph`: Brasas três brasas caindo, escudo com estrela de quatro pontas, nunca cruz). A ação da carta e o
  "Transforma" do Salmo levam o símbolo do HUD (`ActionSlot.mark`). Troca: "Sai" e "Entra", cada uma com glifo, nome e
  raridade, nessa ordem (`BoonCard._swap`, nó `Replaces` com `TradeOut` e `TradeIn`; textos `choice_trade_out`/`_in`).
  Altar: medalhão pintado, a marca da recompensa ao lado do que se entrega e recebe (`BoonCard.ALTAR_MARKS`) e "Sem
  custo" em Seguir em frente (`altar_free`). Provação: só o medalhão da Bênção no topo; o selo rachado pintado fica na
  faixa da maldição (`CurseSeal`). Marcas das recompensas (`DoorGlyph.of_reward`: Bênção um aro com o losango do filete
  das cartas, romã, coração, gema da Magia, moeda, gota) nas placas das portas, ao lado do nome (o pictograma da sala
  vai para a linha de baixo, `DoorSign.make(..., glyph, reward_mark)`), na loja e nas cartas do altar. Ultimate pronta:
  anel fechado de luz esmeralda em volta do losango, um pulso breve quando enche e depois só respira
  (`ActionSlot.READY_*`, `ready_ring`, ligado ao `pulse` do `Hud._update_ult`).
  **Carta de Salmo (E4-03)**: `Game._open_choice` chama `BoonChoice.open_cards(cards, state, game)` quando um Salmo vem
  na tiragem; a escolha sai por `card_chosen(card)` para `Game.choose_card` (Bênção ou Salmo). `BoonCard.setup_psalm`:
  moldura própria, octógono de cantos cortados (`PSALM_CUT`) com linha dupla marfim (`PSALM_EDGE`), ouro velho por
  dentro com losangos nos cortes, arco ogival de ouro velho sobre o medalhão e o brilho na cor do `PsalmDef.color`;
  aba "Salmo" (ou "Salmo descoberto" na primeira vez da vida do save) com um arquinho; nome, "Transforma: ação",
  descrição com os números do efeito e "Aberto por A · B · C" (as três coisas da mão que abriram, uma por grupo,
  `Psalms.matching`, `BoonChoice.opened_by`; Dom pelo nome do Dom). Sem raridade, nível, número de salmo nem versículo
  (teste lê toda etiqueta). Medalhão `PsalmIcon` (`scripts/ui/psalm_icon.gd`): selo de tinta, aro de ouro velho e
  marfim, arco ogival na cor do Salmo e um glifo por efeito (aro com três marcas, cúpula com tiro partido, três luzes
  que se juntam, pedra de pé com fenda); nunca sol nem cruz. **"Salmo descoberto" (E4-04)**: `EloBanner.show_psalm`
  (em fila com Elo e Bênção nova), pedido pela HUD (`psalm_offered` com `first`, `psalm_taken`) e mostrado só quando a
  tela de cartas fecha (`Hud._update_psalms`, modo PLAY): título, medalhão e nome, embaixo a frase do Salmo tomado
  (`line_key`) ou "Anotado no Compêndio". **Luzes do Pastor**: losanguinhos na cor do Salmo sobre o losango do
  especial (`ActionSlot.show_lights`, `LIGHT_*`), apagados os que faltam; só com o Pastor. Capturas:
  `tools/ui_lab.gd -- --psalm-card=id`, `--psalm-banner=id`, `--codex=psalms|enemies|morvath|arenas`; galeria em
  `docs/gallery/e4/ui/`.
  **E3 na interface**: uma moldura por raridade (comum no metal com rebites, rara uma linha azul, épica linha dupla
  violeta, lendária linha dupla de ouro velho com floreios nos cantos, `BoonCard.RARITY_LINES`, `FLOURISH`); a cor de
  cada raridade é uma só no jogo todo (`Boon.RARITY_COLOR`: rara `6f9be6`, épica `b07ae6`, lendária ouro velho
  `d4ad66`, nunca amarelo vivo; `BoonCard.rarity_color` usa ela e só a comum fica no metal `COMMON_EDGE`), também na
  palavra da raridade da carta e do painel "Dons" (`BoonsScreen`, ao lado do nível; Elo sem raridade). Elo sem raridade
  nem nível, moldura de corrente. Troca (E3-01) com a aba "Sobe uma raridade" no alto da carta e "Troca X: de A para
  B" embaixo, no nível da Bênção trocada. **Ligação com as regras**: `Game._open_choice` passa as cartas da regra
  (`Game.offer_cards`, `BoonState.Card`) à tela por `BoonChoice.offers_of` (`{rarity, upgrade}` por id, upgrade =
  `Card.trade`); a tela lê com `BoonChoice.offer_of` (aceita também a raridade crua) e `_take` toma a própria carta
  (`BoonState.take_card`: raridade e nível da troca). "Bênção nova" (E3-04): a primeira vez que se toma uma Bênção na
  vida do save, saudação curta no alto sem pausar (`EloBanner`, em fila com "Elo formado", `fresh_boons` contra
  `codex.boons`). Compêndio (`CodexScreen`; 8 abas desde a E4-05: Dons, Bênçãos, Elos, Salmos, Inimigos, Morvath, Arenas, Golpes; desconhecidos como "???", receita
  do Elo quando as duas Bênçãos já foram vistas). Loja: cada item com `DoorSign.shop(nome, preço, grupo)` (palavra do
  grupo em cinza frio por cima, `Rooms.SHOP_GROUP_KEY`, omitida quando é igual ao nome; preço em marfim) e
  `set_gold` sempre que o ouro muda (o `Rooms.gold` tem setter): sem ouro o preço fica rosa apagado com "faltam N".
  Os itens ficam numa fileira reta na tela (ao longo da direita da câmera, `Feel.cam_yaw`), `Rooms.SHOP_STEP` 5 m entre
  eles e o meio `SHOP_SHIFT` 3,5 m para o lado da entrada: com 5 itens sobram 45 px ou mais entre as placas a 1080 e
  a última cabe na tela a 1280 x 720 (`docs/gallery/e3/ui/shop_real_*.jpg`; `tools/ui_lab.gd -- --start=shop --shop
  [--gold=N]`).
- Combos: `data/combos/paladin.tres` (nós `ComboNode`; `tags` é o que os dons enxergam; os seguintes em `next`, um
  `Array[Resource]`, lidos tipados por `following()`: o `Array[ComboNode]` dentro da própria classe vazava o script na saída,
  as linhas "ObjectDB instances were leaked" e "resources still in use" de toda execução, ciclo 10). Dons: `data/boons/*.tres`
  (`Boon.slot`: um dom por ação, ATTACK/SPECIAL/CAST/DASH, o novo substitui o antigo; NONE = age sozinho, sem limite.
  Raridade sorteada por carta em sequência, `Boon.RARITY_MULT` multiplica o nível 1 dos números com `BoonMod.by_rarity`)
  (`BoonMod`: `stat`, `tag`, `base` e `per_level` (E3, C13-05: ganho fixo por nível); as estatísticas que o jogo
  conhece estão em `scripts/game/combat.gd` e `game.gd` `_take`). Baralho das portas, raridade, loja e ouro: dados no
  `_stage` do `make_data.gd` (`reward_deck`, `rarity_chance`, `guardian_rarity_chance`, `elo_chance`, `trade_chance`,
  `gold_*`, `shop_groups`). Inimigos: `data/enemies/*.tres`. Ondas, elites, fonte e chefe: `data/waves/catacombs.tres`.
- **E1c, Morvath sumia e aparecia em outro lugar para atacar (bug 3)**: a posição dele no jogo nunca saltou; o desenho
  sim. Os golpes dele vêm de clipes das bibliotecas com deslocamento de raiz assado no quadril: a foice (`slash3`,
  Sword_Regular_C, desde a E1b `43229d9`) punha o corpo até 8 m à frente (4 m já na primeira pose) e voltava de uma vez no
  fim, longe dos avisos e da colisão; as Lâminas (`slash1`/`slash2`, Sword_Regular_A e B, desde `faef8d6`) 3 m e o
  arremesso (`volley`, OverhandThrow, `43229d9`) 1,8 m. `tools/bake.gd` ganhou `in_place` (quadril fixo no lugar, como os
  `_RM`) nesses clipes; `BakedModel.pose_centre`/`drift` e `tools/pose_drift.gd` medem (toda pose dele a no máximo 0,45 m
  no tamanho 1, fora queda e levantar). Também: a troca de clipe dele é uma mistura de `Horde.BOSS_CLIP_FADE` (0,12 s, 0,18 desde o T5b) da última
  pose para a nova (`CrowdRenderer.add_kind` com `from_row`/`fade`; antes o corpo pulava até 0,96 m num quadro), o
  atordoamento dele desenhava `idle` (o `Horde.render` lia o `stun_t` que o `Boss` segura; desde o marco 5), e as Lâminas
  e a maldição começam o arremesso antes do tiro para a soltura cair no quadro do tiro (`Boss.THROW_PEAK`, `_throw_by`; o
  pico vinha 10 quadros depois). `tools/boss_probe.gd` acompanha a luta quadro a quadro. Testes em `tests/test_boss_body.gd`
  (poses, as 4 fases até a queda, passo simulado e desenhado, clipe desenhado, avisos onde ele está, soltura). Vídeos em
  `docs/gallery/e1c/bugs/`.
- **Morvath mais difícil (E2)**: camadas `BossAttack.layers` (fase 3: maldição, foice e lâminas com erupções e/ou invocados; fase 4: tempestade com erupções e invocados) com a faixa livre das erupções onde o ataque de baixo não alcança (`BossRules.free_way`) e os invocados nos tetos de sempre; tempestade em 3 ondas (recarga 4 s), descansos 0,6 e 0,4 s nas fases 3 e 4, maldição 6 s, invocação 9 s; vida 6050 e dano iguais. Robô 0,25 com 5 Bênçãos: 8 de 16 vitórias (era 14). `RESULT` `boss.layers`; medição em `docs/qa/e2_morvath.md`, tempos em `combat_cadence.md` 1.4 (`tools/boss_cadence.gd`).
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
- Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`; o desenho fica em `GroundLook`, que os laboratórios usam sem o jogo). Ciclo 8, direção do golpe: na linha a ponta de longe é a clara, o preenchimento avança como uma divisa apontando para onde o golpe vai, com divisas fracas na parte ainda vazia; o arco ganhou borda nos lados retos. Laboratório: `tools/enemy_lab.gd ... --bars --warn=0.6`.

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
  0,22 só nos últimos 30%. Os outros avisos não mudaram.
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

## Prova estilizada (STY-03 a STY-05, cenário; spec `docs/art/stylized_spec.md`, plano `docs/art/stylized_poc_plan.md`)
- Perfil visual reversível (`VisualProfile`, `core/visual_profile.gd`): `Look.CLASSIC` (padrão) e `STYLIZED`, `--look=classic|stylized`,
  **F7** troca ao vivo também no exe (ação `look_toggle`, lida no `Game._process`), global de shader `art_style` (0 ou 1).
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

## Redesenho das salas, Lote A (só no estilizado; spec `docs/art/room_redesign_lotA_spec.md`, antes e depois em `docs/gallery/redesign/lotA/`)
- **Biblioteca** (para os lotes B a E): cada look devolve o bioma em `ArenaRoom.style()` (dicionário; o Salão usa
  `CatacombHall.STYLE`), aplicado por `ArenaRoom._stylize` no fim do `build` e por `ArenaKit.stylize(style, luzes, tomb)`:
  `paint_look(style)` (chaves `stone`, `shadow`, `floor_stone`, `joint_cold`, `olive_share`, `slab_hue`, `edge_value`,
  `pool_gain`, `pool_saturation`; um material pode trazer os próprios números na meta `ArenaKit.PAINT_OWN`),
  `stylize_fires` (`fire`: alcance, queda e ganho de velas e braseiros, braseiros marcados com a meta `ArenaKit.BOWL`,
  sem sombra; `off`: luzes apagadas no estilizado), `abyss_glow` (cor dos cartões de brilho do abismo), `metal`
  (`stylize_metal`: bronze, ouro e ferro mais apagados), `air` (o ar estilizado da sala, por cima do `air()`) e
  `backdrop` (ruínas e bruma ao fundo só no estilizado). Peças só do estilizado: `ArenaKit.styled()` (um `Masonry`
  próprio sob o nó "Styled", escondido no clássico, `ArenaKit.style_only`); nunca o `_rng` da sala (o clássico não
  muda). Peças novas: `Masonry.urn`, `Masonry.carved`, `TombKit.effigy`, `floor_decal.gdshader` (tapete da loja,
  musgo da fonte), `cold_glow.gdshader` (brilho frio além da porta).
- **F7 e o ar**: o `Environment` tinha dois donos; agora `Game` chama `Arena.restyle()` depois do `VisualProfile.toggle()`
  e a sala refaz o próprio ar (`ArenaRoom.redress_air`, base clássica por `VisualProfile.classic_of`); `leave_air`
  devolve o ar do look em uso. `VisualProfile.AMBIENT` frio (0,70; 0,74; 0,80). Teste: `tests/test_room_style.gd`
  (Cripta A e B e Salão trocados duas vezes voltam idênticos, colisão igual, peça nova sobre o chão abaixo de 0,3 m).
- **Cripta** (`CryptLook.STYLE`, petróleo frio): ar próprio (ambiente 2,1, lua de chave 0,9 com sombra, névoa clara
  longe; no Compatibility `STY_COMPAT_AMBIENT` 0,7 e `STY_COMPAT_MOON` 0,5), chave e preenchimento apagados, velas 3,4 m;
  efígie no túmulo grande, urnas nas saliências, velas nos nichos, inscrições, brilho frio além da porta norte, bancos
  de bruma ao sul e leste; na B uma figura encapuzada de 3 m sobre o Ossuário. Os sarcófagos pequenos e os ossos dividem
  um material (o `Masonry` guarda por cor e a cor passa de 1): no estilizado ele vai ao valor da pedra
  (`STY_PAINT_REF`, `STY_LIGHT_STONE`) com poça mais fraca (`STY_LID_POOL`), senão as tampas com velas viravam creme.
- **Salão** (`CatacombHall.STYLE`, ardósia azul, L-1): pedra e chão azulados, abismo azul no lugar do violeta
  (`STY_ABYSS_LIGHT`, `STY_ABYSS_GLOW`), urnas baixas nos potes oeste e nos plintos do portal. Loja (`Arena.dress_shop`,
  chamado no fim do `Rooms._build_shop`; `CatacombHall.dress_shop`): tapete sob cada relicário, lanternas de ferro
  baixas entre as placas (nunca na frente delas), panos e urnas. Fonte (`CatacombHall.dress_fountain`, pelo
  `ArenaKit.fountain`): musgo cinza-verde com flores e velas na borda. Poças e figuras do STY-10 iguais.
- Medido (RTX 1080, vitrine do jogo, semente 5): Cripta chão 66 e 69, parede norte 34, fora 25, quadro 56, matiz 206;
  Salão chão 74 (matiz 229, saturação 0,12), norte 65, abismo matiz 211, quadro 68. Quadro: Cripta RTX 2,08 para 1,97 ms,
  iGPU 720 Baixa 14,3 para 13,3; Salão 2,55 para 2,42 e 17,3 para 15,2. O clássico igual à galeria nas cinco vistas.

## Pendências conhecidas
- **Fase por salas** (padrão desde a E3): o robô com reação 0,25 desce as 10 salas em 4 a 4 min 40 s e chega em Morvath
  com 5 a 7 Bênçãos em 7 de 8 sementes, compra na loja em 7 de 8 e vence 5 de 8 (`docs/qa/e3_metrics.md`).
  `tools/smoke.sh 300` não chega mais em Morvath: usar 600 (ou `--medium`). Falta teste com gente. O modo de horda (`--horde`) ficou como estava, com os números novos.
- Morvath (4 fases, 2026-11-15; ciclo 9): o robô sem tempo de reação vence sempre e quase não apanha; com reação humana
  (`--bot-reaction=0.25`) vence cerca de metade das lutas com 5 dons, perde mais na fase 4 (a tempestade e a maldição
  somam mais da metade do dano). A luta dura de 1 min 40 s a 2 min para o robô (abaixo da meta de 2 a 4 min; gente bate
  menos, medir antes de mexer na vida). A dificuldade para gente ainda não foi medida. A foice é a lâmina do modelo aprovado (ele não
  tem foice); meias-luas sem as caveiras da referência; maldição lida pelo brilho roxo e fumaça no herói. Diferenças do Hades
  que ficaram: Morvath tem ataques próprios (não os da chefe do Hades), só a vida (6050) e o dano seguem a escala; sem martelo, feitiço lunar ou dom de velocidade como recompensa; a loja compra ao pisar (não há botão de
  interagir); a seta especial não persegue (o bônus de sequência de golpes saiu na E3, D-10).
  Depois do 1º teste do Daniel (mais dinâmico, 2026-11-14; o avanço e o "andar corta o golpe" desta época saíram na E1c,
  ver Golpe parado): o corte de luz segue o lado do braço
  (`ComboNode.sweep`, `SWEEP` em `make_data.gd`), golpes
  empurram mais, inimigos mais rápidos (esqueleto 3,75 m/s) e com menos espera entre ataques (avisos iguais); a câmera
  se adianta para onde ele anda, não para a mira.
- Cenário do KayKit, fontes e áudio sintetizado são provisórios. Assados somam 43,9 MB (43,75 no pacote; 16 bits, `ARRAY_FLAG_COMPRESS_ATTRIBUTES`, textura S3TC de 1024 dentro de cada um). Fora do pacote (`exclude_filter` dos três presets): os `enemy_*` de origem, os bonecos do KayKit (`assets/models/characters`), a UAL (`assets/models/anim`), as armas (`assets/models/weapons`) e a `statue.res` sem uso; ficam no repositório para o `tools/bake.gd` e o `tools/bake_hero.gd`. Pacote (C1 do artista técnico, `docs/qa/asset_report.md`): exe do Windows 197,2 MB (PCK 87,9; era 219,7 / 110,3), `index.pck` da Web 88,0 MB. **Texturas 3D comprimidas para a placa em todo `.import`** (`compress/mode=2`, `detect_3d/compress_to=0`: o projeto é importado sem tela e a detecção do editor nunca trocava): herói 2048 e Emeth 1024 (`process/size_limit`) em BC7, normal da rocha em BC5 (o z refeito no `masonry.gdshader` e no `catacomb_floor.gdshaderinc`), altura em BC4; as peças do KayKit usam um material só, `assets/models/kaykit_material.tres` com a paleta `kaykit_palette.png` em BC7 (`use_external` no `_subresources` de cada `.glb.import`, sem imagem extraída). VRAM dessas texturas de 161 para 10 MB. Travado por `tests/test_asset_import.gd`; medir com `tools/asset_probe.gd -- vram` e `tools/pck_sizes.py`.
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
