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
`docs/qa/latest_report.md`), `combat-feel-director` (cadência, peso e sincronia do combate: preparação, impacto, recuperação e próxima ação do Guerreiro, dos inimigos e de Morvath; mede em capturas reais, mantém `docs/design/combat_cadence.md`, classifica P0/P1/P2 e pode reprovar tecnicamente uma entrega de combate com evidência; não implementa), `technical-artist` (valida, mantém e evolui todo asset: modelos, assados, texturas, arte de UI, sons e músicas; orçamento, importação, licenças, declaração de IA, assets sem uso; inventário em `docs/art/asset_inventory.md`, relatório em `docs/qa/asset_report.md`; Meshy só com autorização), `room-designer` (evolução e progressão das salas: tamanho, forma, perigos de sala que pedem pensar, como armadilhas, árvore que ataca, buracos e raios, sempre avisados e ferindo inimigos também; plano em `docs/design/rooms_progression.md`), `balance-designer` (equilíbrio: curva entre descidas, a primeira muito difícil e melhorando aos poucos com Maestria, Dons e hub, e curva dentro da descida; mede com o robô em muitas sementes e Maestrias, metas em `docs/design/balance.md`; propõe números, não implementa), `game-director` (lê todas as evidências e revisões e mantém o backlog em `docs/backlog.md`: bugs e quickwins
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
- **Exportação sem converter recursos para binário** (`editor/export/convert_text_resources_to_binary=false` no `project.godot`, 2026-11-19): com a conversão o exe lia o `reward_deck` do estágio vazio (todas as portas com Bênção, loja vazia); `tests/test_export_settings.gd` trava. Conferir o exe com `build/linux/ASelagem.x86_64 --headless -- --smoke=30 --seed=5 --nosave` contra o editor.
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
  portas, fonte, loja (o botão de usar compra, C19), chefe. Magia enche em toda sala; sem experiência nem níveis.
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
  0,58 (aço 0,52 m = 0,6 do tronco), besta a `CROSSBOW_SCALE` 0,62 em madeira com o arco no ferro gasto da lâmina (ciclo LC; era 0,5 em ferro escuro), cajados em madeira escura com anéis de metal
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
- **Escolha de save (2026-11-19, pedido do Daniel; capturas em `docs/gallery/save_slots/`)**: a primeira tela de cada
  sessão é a escolha entre Save 1, 2 e 3 (`SaveSlotScreen`, `scripts/ui/save_slot_screen.gd`, na página dos menus,
  `UiKit.page`, sobre a arte do título escurecida); escolhido, vem o título com Iniciar etc. (fluxo: escolha, título,
  hub; escolhido uma vez, "Voltar ao título" do hub cai direto no título). Cada cartão mostra o medalhão do Guerreiro,
  Maestria, descidas, vitórias, Bolsa (Prata e Memória, `MaterialCount`) e "Última partida" (data e hora do fim da última
  descida, `played_at` gravado no `Game.log_run`); vazio diz "Espaço vazio" e escolher cria um save novo na hora.
  "Apagar" fica embaixo de cada save que existe e pergunta numa página própria "Apagar o Save N? Não há volta.", com
  Cancelar em foco (`slot_erase_*`). Esquerda e direita andam nos cartões, baixo vai ao Apagar; Esc e B fecham a pergunta
  e só fecham a tela quando aberta do título com um save em uso. No título, o canto de baixo à esquerda diz "Save N ·
  Trocar de save (Esc)" (clique, ou Esc/B no título, reabre a escolha). Regras em `SaveSlots` (`core/save_slots.gd`,
  puro): cada save é um arquivo inteiro gravado pelo `SaveFile` com `.bak`; `user://profile.json` guarda o save em uso
  (`active`) e as **opções, que são do computador e valem para os três** (`Save.set_option` grava só o perfil,
  `write_options`; trocar de save não muda volume, tela nem teclas). O `save.json` de antes lê como Save 1 enquanto o
  Save 1 não existe e vira ele no primeiro `Save.write` (`SaveSlots.migrate`: copia o arquivo e o `.bak` e renomeia o
  antigo para `save_legacy.json`, nunca mais lido; o progresso inteiro fica, testado com todos os `tests/fixtures/save_v*.json`).
  Ler nunca grava. `Save.use(n)` põe o save em uso (cria o vazio), `Save.erase(n)` apaga o arquivo, a cópia, o `.tmp` e os
  `.broken` (o Save 1 também aposenta o `save.json` antigo, que não volta). `runs.jsonl` continua um só, com `slot` em cada
  linha. Sem a tela: `--nosave`, os testes (o gancho desliga o save), `--title` (capturas) e `--slot=N` (usa aquele save);
  `--title --screen=slots` captura a tela, `--save-dir=pasta` lê saves de outra pasta (só leitura com o `--nosave` do
  `tools/gpu.sh`), `--slot-ask=N` abre a pergunta. Testes em `tests/test_save_slots.gd`; fluxo por teclado no
  `tools/title_flow_check.gd` (numa pasta própria). Benchmark de interface com o Hades II e propostas P0 a P2:
  `docs/design/benchmark_hades2_ui.md`.
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
  losango de ouro velho, barra de XP e "O nível N revela: ..." do que o próximo nível dá), Devoção em losangos (usada e livre),
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
- **Benchmark de interface contra o Hades II (P0 e P1 de `docs/design/benchmark_hades2_ui.md`, UI-HB1, HB2, HB5 de
  `docs/art/benchmark_hades2_style.md`, item 3 do `docs/design/ciclo_visual_2026-11-20.md`; testes em
  `tests/test_bench_ui.gd`; capturas em `docs/gallery/ciclo_visual_1120/ui_*`)**: a tecla de usar da partida
  (`Rooms.prompt`) fica pendurada embaixo do que se usa, não em cima do herói (`StationSign.under`, `place_under`,
  `UNDER_GAP`; âncora em `Rooms.use_spot`: a recompensa, o item da loja, o medalhão da porta), e onde o herói cobre
  esse ponto desce para baixo dos pés dele (`StationSign.hero_box`); na loja sem ouro a linha diz "Faltam N de ouro"
  (`shop_use_short`). Placas da loja em duas linhas, nome e preço, a falta pela cor do preço (`DoorSign.set_gold`,
  `SHORT_COLOR`; a palavra do grupo saiu). **Barra de ações** (`ActionBar`, `scripts/ui/action_bar.gd`):
  `ActionBar.attach(tela, [ActionBar.entry(ação, verbo, ao_clicar, extra)])` põe no rodapé a tecla real de cada ação
  (`StationSign.KeyCap`, `UiKit.action_label`; A e B do controle para `ui_accept`/`ui_cancel` por `UiKit.MENU_PAD`) e
  o verbo, que troca ao vivo entre teclado e controle e é clicável; `ActionBar.RESERVE` é a margem de baixo dos livros.
  Nas Bênçãos, nos anjos, no Livro (o verbo segue o capítulo: Confirmar, Equipar ou tirar, Abrir com Memória;
  `HeroScreen.bar`), no mapa, no Compêndio, na Forja, na escolha de save e na pausa; as frases de teclas saíram
  (`hero_hint*`, `slot_hint*`, `map_close_hint` ficaram sem uso). **Contador de golpes** fora da luta (UI-HB5): uma linha
  só sobre a barra de vida, à direita do medalhão (`Hud._combo_row`: número `FONT_COMBO` 24 com contorno, sem véu, a
  palavra e o nome do golpe em Alegreya Sans Bold 14), que sobe quando o selo da maldição aparece. **Cartas de
  Bênção** (UI-HB1, HB2): altura pelo conteúdo, de `BoonCard.MIN_H` 300 até `SIZE.y` 450 (`fit_height`), descrição em
  `UiKit.rich` com o corpo em marfim mais quieto (`BoonCard.BODY`) e números e palavras-chave em negrito no marfim
  cheio (`UiKit.strong`, `UiKit.STRONG`; `BoonChoice.describe(..., marked)`, `Glossary.emphasize`), alinhada à
  esquerda; os números do efeito em linhas rótulo e valor (`BoonChoice.facts`, `fact_value`, chaves `fact_*`; nós
  `Facts`, `Fact_<stat>`, `Value`, e `Was` com o valor de antes quando a carta troca uma Bênção que tem o mesmo número).
  Troca sempre com Sai e Entra (`Replaces`). **Glossário** (`Glossary`, `scripts/ui/glossary.gd`) à direita da fileira
  de cartas: os termos da carta em foco (congelar, queimadura, atordoar, Ômega, Magia, armadura, Corte Veloz; chaves
  `gloss_<id>`, `_text` e `_words`, as raízes que acham a palavra no texto), no máximo 2. **Encontro dos anjos**: o selo
  de cada anjo maior (`EncounterScreen.SEAL` 176) sobre uma luz da cor dele abaixo do limiar (`GLOW_*`); nada de figura.
  **Forja**: a Emeth de verdade na página esquerda (`EmethView`, `scripts/ui/emeth_view.gd`: `SubViewport` com mundo
  próprio, o modelo do `EmethSword` com o `set_temper` do posto, câmera ortográfica, balanço lento; `show_rank(r, grow)`
  faz o veio crescer ao forjar) com "Posto da Emeth" embaixo; à direita o índice dos postos, "Melhoria seguinte" ou
  "Forjado", Efeito, Estado, Próximo passo e, junto do Forjar, Custo e Saldo lado a lado (nó `deal`).
  Segundo lote (ciclo visual 2026-11-20, item 3; capturas `docs/gallery/ciclo_visual_1120/ui2_*`): **Compêndio** com o
  detalhe da entrada selecionada na página do índice (`CodexScreen.detail`): em Inimigos a própria figura assada
  (`FigureView`, `scripts/ui/figure_view.gd`: `SubViewport` com mundo próprio e um `CrowdRenderer` de uma figura, no
  `idle`, girando devagar; nunca derrotado, silhueta em tinta e "Derrote um para conhecer."), em Dons a marca do Dom
  grande (`TalentGlyph.mark`); as linhas dessas abas tomam o foco (direita do índice entra, esquerda volta, mouse
  seleciona; `CodexScreen.selected`). **Árvore**: equipado com um selo redondo esmeralda com visto no canto
  (`TalentNode._badge_tick`), selado com a moldura tracejada sem pontas e um lacre de cera (`_badge_seal`,
  `SEAL_WAX`), além da cor; no painel Custo e Pré-requisito lado a lado em negrito (nó `glance`). **Menus**: a
  `ActionBar` também nos Juramentos (`ActionBar.STEP`, a placa "← →" para o nível), nas Configurações (abas, Mudar,
  Confirmar, Voltar), nas Músicas, na tela de fim e na página das estações do hub (`HubPanel`), sempre no mesmo lugar;
  `ActionBar.press_focus(tela)` aperta o botão em foco (as frases `jur_hint_*` saíram). Fim de partida: primeiro o que
  fica (os materiais trazidos em 24 px, `EndScreen.BROUGHT_SIZE`, e a Maestria), depois as Bênçãos da descida e os
  números. **Molduras (UI-HB3)**: toda página de menu (`UiKit.page`), a pausa e o resumo da vitória ganham um remate no
  topo (arco com o losango) e cantoneiras de ouro velho com losango (`UiKit.crown`). **Selo do anjo (UI-HB4)**: na
  escolha de Bênção trazida por um anjo, o selo grande numa coluna à esquerda das cartas (`BoonChoice.ANGEL_FIGURE`
  220 a 720, cerca de 330 a 1080, luz da cor dele) com o nome e o glossário embaixo. **Selo de salvo (P2-4)**: todo
  `Save.write` que grava o save em uso emite `Save.written` e mostra por 1 s um selo pequeno com "Salvo" no canto de
  baixo à direita (`SaveSeal`, `scripts/ui/save_seal.gd`); nunca sem save; a escolha de save diz quando ele grava
  (`slots_saves_when`). Toda `UiKit.column` (páginas de menu, cartas, fim) centra acima da fileira da `ActionBar`
  (`ActionBar.RESERVE`); nas Configurações a dica fica no pé da página (`tip` dentro do quadro). Testes em `tests/test_bench_ui.gd`.
  Terceiro lote (capturas `docs/gallery/ciclo_visual_1120/ui3_*`, `_side_` lado a lado): o nome do golpe sai mais
  longe do medalhão e acima do fio da barra (`Hud.COMBO_INSET` 14, `COMBO_RISE` 9; encostava nele na horda). **P1-4,
  a fileira, é o padrão** (aprovada pelo art-director com os ajustes A a C de `ART_REVIEW.md` 3.1; `--hud=classic` volta
  aos losangos no meio de baixo para comparar): os cinco losangos menores (`Hud.ROW_DIAMOND` 36, 54 px a 1080;
  `ActionSlot.side`) numa fileira sobre as barras a partir do ombro do medalhão, a tecla pendurada sob a ponta
  (`ActionSlot.key_drop`, `ROW_KEY_DROP`), nada entre 30 e 70% da largura embaixo (a fileira acaba em 28%); uma faixa de
  tinta atrás dela (`HudVeil` sobre os losangos, `Hud._row_band`) e o véu dos losangos só pelo herói atrás
  (`_someone_behind(..., true)`): corpo do losango com luma p50 12 sobre a horda de 300; o contador e o nome do golpe na
  mesma linha, à direita do último losango à mostra (`Hud._follow_row`, `ROW_COUNT_GAP`; o robô não tem o da
  ultimate), o bloco todo com cerca de 197 px a 1080 (teto 200); selo da maldição e selo da Provação sobem a altura da
  fileira e das legendas (`Hud._row_lift`; só com eles à mostra o bloco passa dos 200); as Bênçãos que agem sozinhas no
  canto de baixo à direita, cada grupo com o próprio véu; divisas da borda acima da fileira (`Hud.edge_bottom()`,
  `ROW_EDGE_BOTTOM` 168). Capturas do aceite em `ui3_after_*` (Salão e Ponte A com a horda a 720 e 1080, ultimate
  trancada e pronta, maldição, Provação, herói na borda sul, `classic`).
- **Fatia 2 na interface** (`docs/design/rejogabilidade/sistemas.md` 5.3 "Fatia 2"; testes em `tests/test_ui_fatia2.gd`;
  capturas `docs/gallery/ciclo_visual_1120/ui4_*`): **Encanto** nas cartas (`EnchantChoice`, filha da `BoonChoice`:
  título, linha de baixo, dica "Até dois Encantos por descida", barra de ações, `GUARD_MS`; `open_enchants(opções)`,
  sinal `chosen_enchant`; aberta pelo `Game.open_enchant_choice` quando ninguém ouve `enchant_offered`):
  `BoonCard.setup_enchant` com a aba "Encanto", medalhão de tinta com a marca, nome, "Muda: <ação>" com o símbolo do HUD, a regra,
  o texto com os números em negrito (`BoonCard.strong_numbers`) e "Até o fim da descida"; borda e brilho esmeralda
  pálido (`ENCHANT_EDGE`, `ENCHANT_GLOW`), sem raridade nem nível. **Marcas** desenhadas (`DoorGlyph.Kind`): `ENCHANT` a
  lâmina inclinada com uma centelha de ouro velho de quatro pontas (`DoorGlyph.enchant`; nunca de pé com a guarda, que
  lê como cruz, nem com um aro, que lia como o sinal de Vênus), `PSALM` o arco ogival das cartas de Salmo com a luz
  lilás e um losango, `EMERALD` a pedra lapidada mais alta que larga no esmeralda da Emeth (a gema da Magia é redonda e
  azul); `of_reward` (ENCHANT, PSALM), `of_material` (EMERALD), na legenda do mapa e nas placas da loja. **Anjo na
  porta**: a linha do anjo sob a recompensa ganha o selo da casa e o nome na cor dele, ou dois selos e "Dois anjos"
  (`DoorSign.show_angel`, `angel_row`, chamada pelo `Rooms._sign_angel`; o texto do `door_text` não mudou e sai do
  detalhe, que fica com "Difícil"). **Forja** (`ForgeScreen`): o índice é uma grade de três colunas que cabe em 720
  (Temperar I a III, Refinar Ataque e Especial com três escolhas cada; `Book.index_entry` com altura, fonte e margens
  compactas), cada entrada com a marca do estado (`ForgeScreen.Mark`: lingote e preço esperando, losango de ouro velho
  forjado, losango esmeralda na lâmina, losango apagado sem a ferramenta), sobre o Refinar "Ferramenta: Encontrada" ou
  "Ainda perdida nas catacumbas"; o botão diz o que faz: Forjar (a primeira de uma ação entra na lâmina), Usar (troca
  a da ação, sem custo, `Forge.put_on`) ou Em uso; sem a ferramenta, Estado "Falta a ferramenta" e o `forge_no_tool`.
  **Esmeralda**: na Bolsa (`MaterialCount.purse`, `shown`) depois da primeira, no cartão do save, em Trazidos (todo
  `MaterialPurse.IDS`) e na saudação de material; a ferramenta achada também em Trazidos. Capturas: `tools/ui_lab.gd --
  --enchant`, `--doors=boon,meeting,enchant,psalm`, `--shop --route --want-enchant`, `--cursed`; Forja com
  `--tools=tool_refine --refined=refine_fio,refine_peso` (só na sessão, `Save._dev_materials`).
  Medalhões do mundo (`RewardGem`): Encanto (`Mark.ENCHANT`, a lâmina inclinada com a centelha, esmalte verde
  `ENAMEL_ENCHANT` matiz 148) e Salmo (`Mark.PSALM`, o arco ogival com o losango, lilás `ENAMEL_PSALM` matiz 255, longe
  da Provação), desenhados no `reward_gem.gdshader`; `tools/gem_lab.gd --rewards=10,11,1`. Cores das famílias: toda tela
  lê `Boon.color()` (`FAMILY_COLOR`, Vigília em sálvia) e o selo do anjo o `AngelSeal.TINT`, nada copiado.
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
  de onde veio (só as fontes que deram algo), "Nível N alcançado" e "Dons revelados: ..." (o nível revela, a Memória abre) e "Nova ultimate: ..."; dados do
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
- **Tecla de usar na descida** (C19, Q-13, o Daniel pediu a letra na tela): recompensa, item da loja e porta só com
  `interact` (E, A no controle), parado neles (`Rooms.usable`, `use_kind`). Enquanto há algo para usar, a plaqueta
  da `StationSign` sem nome (só a tecla real e o verbo: "Pegar", "Comprar", "Entrar", `hub_use_reward`/`shop`/`door`)
  fica sobre a cabeça do herói (`Rooms.prompt`, `_step_prompt`; escondida fora do modo PLAY e para o robô); clique nela usa.
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
- **RP-07, variante pela profundidade**: cada variante tem a faixa da descida em que pode sair (`RoomLayout.variant_depth`
  para a A, `ArenaVariant.depth` para as outras; `RoomLayout.variants_at(progresso)`, a primeira quando nenhuma cabe); o
  `RunMap` sorteia só entre as que cabem, com o mesmo dado de antes (sem faixa, o mapa de antes). Faixas do room-designer:
  Fendas A 0,1 a 0,6 e B 0,34 a 1; Ponte A 0,5 a 0,8 e B 0,67 a 1; Runas B 0,5 a 0,8 e A 0,67 a 1 (`_stage`). A
  intensidade do perigo pela faixa (Runas A tardia mais densa) não entrou: é número. Teste
  `test_rp07_no_variant_out_of_its_band` (1000 grafos).
- **LR-03 (Santuário)**: a primeira onda nasce também no leste das duas naves laterais (`_rect(4, 12, 8, 12)`,
  `_rect(-2, 6, -12, -8.5)`). LR-04 (Jardim, atiradores ao norte do tronco) e LR-06 (Cripta B, muro de 12 m) foram
  provados e voltaram (sem efeito com o robô; números em `rooms_progression.md`). `--trace-thirds` soma em
  `rooms[].zones` os segundos do herói por terço da sala (`hero_x0..2` oeste a leste, `hero_z0..2` norte a sul) e dos
  inimigos (`foe_x0..2`); sem ela o `RESULT` é o de antes.
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
- **Correções da revisão** (`docs/art/room_redesign_lotA_review.md`, itens 1 a 10; capturas da galeria substituídas):
  Cripta com velas 1,8, poça 1,4, braseiros 1,5 e 4,5 m; pedra (0,315; 0,325; 0,335), chão (0,285; 0,296; 0,306),
  sombra (0,90; 0,94; 0,97), ambiente (0,74; 0,76; 0,78); figura velada da B mais clara (`VEILED_VALUE` 1,35,
  `VEILED_GLOW` 3,2) e brilho da porta norte mais claro e menos saturado (`DOOR_GLOW_FOOT`, `_B`); na B as velas das
  tampas a 0,6 da luz das outras (`STY_LID_LIGHT`, pela meta `ArenaKit.FIRE_SHARE` que o `stylize_fires` lê) e a tampa
  a `STY_LID_POOL` 0,45. Loja: lanterna em todo vão entre itens, luz âmbar própria (`SHOP_LAMP_LIGHT`, energia 7,
  alcance 4,5), vidro e chama pelo `ScreenTone.fit`. Salão: velas 1,5 e poças com a saturação inteira do fogo
  (`STY_POOL_SATURATION` 1,0, só o Salão, a loja e a fonte). Relicário de toda recompensa pintado no estilizado
  (`RewardGem.STY_RELIQUARY_TINT`, pedra e sombra do `CatacombHall.STYLE`). Musgo da fonte com borda quebrada
  (`ragged` 0,5 m, `north_reach` 0,3, raio médio 3,0, `FOUNTAIN_MOSS_*`) e flores de 9 a 14 cm em tufos de 3 a 6.
  Compatibility: o ambiente não muda as figuras (chão 106 a 111, figuras 33 a 39 com 0,7 ou 0,85): fica 0,7 e as
  figuras são do technical-artist (`crowd.gdshader`). Medido (RTX 1080, semente 5): Cripta A / B parte quente 3,1 /
  2,6%, chão leste 68 / 67 (saturação 0,18, matiz 208), parede norte 34 (saturação 0,27), ciano 0,3%, figura velada
  55 (p90 78), porta norte p90 81 / 84 (saturação 0,33 / 0,31); Salão quente 3,2%, meio 72 (matiz 235); Loja quente
  7,8%; o chão oeste da B segue 90 porque a caixa pega o herói e o círculo na captura. iGPU 720 Baixa: Cripta 13,4 ms,
  Salão 15,3 (iguais). O clássico mede igual.

## Redesenho das salas, Lote B (só no estilizado; spec `docs/art/room_redesign_lotB_spec.md`, capturas em `docs/gallery/redesign/lotB/`)
- **Biblioteca nova**: `ArenaKit.styled_build(build, at, scale)` monta qualquer peça do kit (estátua, estandarte,
  braseiro) dentro do `Masonry` só do estilizado (luzes sem sombra, escala em volta de `at`, poças de chão do kit
  devolvidas); `Masonry.broken_arch` (arco de aduelas sem as do meio, `gap` em m do meio); `floor_decal.gdshader`
  `kind` 2 (musgo e hera pendurados numa parede); `far_vortex.gdshader` (cartão de espiral violeta apagada, maior canal
  0,45, gira devagar, sem luz).
- **Santuário** (`SanctuaryLook.STYLE`, calcário morno, a única sala de luta em pedra morna): ar próprio (ambiente
  neutro 1,6, lua de chave 0,85 com sombra), luz da nave a `STY_KEY` 0,6, fachos marfim-ouro (`STY_SHAFT`) e um facho
  só do estilizado sobre o `boss_spawn` (`STY_GUARD_SHAFT`, sem sombra); oferendas no presbitério (velas, urnas,
  passadeira petróleo apagada, `OFFERINGS`, `RUNNER_*`), lascas encostadas nas colunas quebradas (`DRUM_SHARD*`),
  estátuas encapuzadas nas janelas cegas sobre mísulas (`NICHE_STATUES`, `NICHE_CORBEL`: o corpo só passa sobre o chão
  acima de 3 m), estandartes do leão nos pilastras, musgo na parede norte (`MOSS*`); na B o facho do buraco frio
  (`STY_TEAR_SHAFT`) mirando o buraco, mais poeira e a abóbada rasgada (`VAULT_*`, acima de 9 m, contra a parede norte;
  sem céu de pôr do sol, P-6). Sombras iguais (A 5, B 4).
- **Fendas** (`RiftLook.STYLE`, índigo-cinza): ar próprio (ambiente 2,8, lua 1,4), bruma e abismo 40% para o cinza
  (`STY_HAZE_GREY`, também os planos do `abyss`), névoa da fenda mais cinza (`STY_RIFT_FOG`), luzes do fundo mais
  pálidas (`STY_DEEP`), brilho dos lábios 0,14; braseiro baixo na cabeceira norte de cada ponte de pé (`HEAD_BOWL*`),
  lascas penduradas na fenda (`SHARDS_HUNG`), arco quebrado com correntes na boca norte (`MOUTH_ARCH*`); na B o arco
  caído da ponte com um pedaço do tabuleiro em correntes (`FALLEN_*`, lê-se pela ponte que caiu, P-6), bruma do vão
  apagada (`STY_FALLEN_MIST*`) e o vórtice distante no alto do quadro (`VORTEX*`).
- Teste: `tests/test_room_style.gd` cobre as quatro vistas (ida e volta idênticas, ar próprio, sombras iguais, nada novo
  sobre o chão entre 0,3 e 2,6 m). Robô: 8 sementes por arena e variante, nenhum `stuck`. fit_probe igual ou melhor.
- Medido (RTX 1080, semente 5, `--shot-at=5`): Santuário matiz 33 a 34, saturação 0,12 a 0,13, chão da nave 71 a 83;
  Fendas matiz 255 a 257, saturação 0,21 a 0,23, chão 42 a 54, violeta na cena 0,7 (A) e 1,8% (B). Quadro RTX 1080 Alta
  (GPU) Santuário 2,33 / 2,15 para 2,18 / 2,26 ms, Fendas 2,22 / 2,19 para 1,92 / 1,96; iGPU 720 Baixa 14,6 / 14,6 para
  14,8 / 15,3 e 14,3 / 15,6 para 14,0 / 14,5. Compatibility sem erro (`STY_COMPAT_*` de cada look). O clássico igual.
  Cena (luma p50): Santuário 63 / 58, Fendas 49 / 53.
- **Correções**: luz difusa na pintura: uma luz com `light_specular` 0 (`SPECULAR_AMOUNT` no `paint.gdshaderinc`) pula
  as faixas e a borda de poça e acende por N·L vezes a queda (`paint_diffuse`), então o cone some largo e macio (nada
  de círculo no chão, P-4). Os fachos do Santuário no estilizado são assim, mais quentes (`STY_SHAFT_WARM`), a 0,75 da
  energia, cone de 30 graus e mais inclinados (`STY_SHAFT_LEAN`, `_leaning`: a mancha alonga na direção da luz); o da
  B no buraco continua frio. Chão do Santuário mais quente e com mais variação por laje (`STY_FLOOR`,
  `STY_SLAB_PAINT` 0,78 a 1,2, `STY_SLAB_HUE` 7, chave nova `slab_paint` do `ArenaKit.FLOOR_KEYS`, oliva 0,04). Fendas:
  chão mais claro e sem escurecer para a borda (`STY_FLOOR`, `STY_EDGE_VALUE` 1,0). Medido: Santuário A nave matiz 30
  a 34, saturação 0,13 a 0,19, luma 74 a 90 (p10 a p90 de 53 a 115, antes chapado), cena 61; B 59; Fendas A caixa da
  frente `1500,850,192,162` 51 e `1600,700` 56 (eram 39 e 46), o meio oeste 71.

## Redesenho das salas, Lote C (só no estilizado; spec `docs/art/room_redesign_lotC_spec.md`, capturas em `docs/gallery/redesign/lotC/`)
- **Biblioteca nova**: musgo pintado (`root_moss.gdshaderinc` com o corpo; `root_moss.gdshader` igual, gêmeo
  `root_moss_paint.gdshader` trocado pelo `ArenaKit.paint_look`, chaves `shadow` e `moss` do `style()`, `MOSS_KEYS`:
  verde-cinza em três degraus de valor `paint_moss_steps`); folha caída (`floor_decal.gdshader` `kind` 3: folhas ovais
  pontudas em células, `litter_*`, cobertura até 30%, ao longo de uma borda ou num anel `litter_ring`); fungo pálido
  (`Masonry.fungus(at, count, reach, seed)`, cacho de chapéus achatados, `fungus.gdshader`: marfim-cinza, brilho só na
  borda do chapéu, maior canal até 0,6); água escura (`dark_water.gdshader`, da família do `fountain_water` mas à parte
  para a fonte clássica não mudar: `form` 0 lâmina com ondas lentas e espuma quebrada na borda, `foam_at` onde cai a
  cascata; `form` 1 cascata em cartão com veios descendo e névoa no pé; matiz 200 a 210, espuma abaixo de `peak` 0,9; no Compatibility, onde a luz própria sai sem o linear para sRGB e a
  água ficava preta, o corpo entra pela luz própria `compat_body` 1,0 e ondas e espuma sobem pela raiz de 2,2 vezes
  `compat_glow` 0,7: na fonte do hub matiz 193 para 202, saturação 0 para 0,41, luma p90 102 para 109, contra 203, 0,39 e 97 no Forward+).
  Em `ArenaRoom`: `added_since(from)`, `style_abyss(nós, mist, cor, luz)` (apaga partículas, recolore as luzes da camada
  funda e a bruma), `style_depths(valores)` (todo material da pedra funda da sala, inclusive a das bordas) e
  `hanging_lantern(from, ring_y, size, luz, styled)` (a lanterna do Jardim, agora comum; `styled` monta no `kit.styled()`).
- **Jardim** (`GardenLook.STYLE`, cinza-musgo, oliva 0,25): ar próprio (ambiente neutro 1,8, lua 0,75 com sombra), luz
  do meio e facho difusos (`light_specular` 0, `STY_KEY`, `STY_BEAM`), cristais sem luz (só a aresta), janelas e bruma
  frias apagadas (`STY_WINDOW_*`), abismo e penhascos mais escuros e neutros (`STY_MIST`, `STY_CLIFF`); árvore de pedra
  em casca cinza-musgo com preenchimento morno (`STY_BARK`, `STY_CORD`, `STY_LICHEN`, `STY_TREE_FILL`); J1 copa em
  ferrugem (`STY_LEAF_A`/`B`); J2 folha caída a até 1,2 m das paredes norte e oeste e em volta do tronco (`LEAVES_*`,
  `LEAF_*`); J3 fungos nas tampas, no pé das colunas, nos peitoris e no pé das paredes (`FUNGI*`); J4 cascatas atrás das
  janelas cegas e além do corte noroeste com poça escura no pé, fora do chão (`FALL_*`, `POOL_*`); J5 na B a parede
  oeste (nó `WestWall`, com os estandartes e a estátua) some e dá lugar a um peitoril baixo quebrado e ao lago escuro a
  y -0,6 com blocos caídos e a cascata do fundo (`PARAPET_*`, `LAKE_*`); J6 musgo no gêmeo pintado.
- **Ponte** (`BridgeLook.STYLE`, azul-ardósia): ar próprio (ambiente 1,8, lua 1,0 com sombra), bruma do abismo menos
  saturada (`STY_MIST_SAT` 0,6) e cartões de ruína com ela, pedra funda `STY_CLIFF`; P1 pilar com braseiro na quina sem
  estátua de cada cabeceira, fora do polígono, luz sem sombra e poça mais forte (`HEAD_BOWL_*`, `pool_saturation` 1,0);
  P2 um segundo anel de aduelas 4 m sob cada ponte (`LOW_ARCH_*`, na pedra funda); P3 corrente de cada pilar para o
  abismo; P4 três cascatas ao norte a 26 m da borda (`FALLS*`); P5 na B duas pontes quebradas ao fundo em pedra funda
  (`FAR_*`); P6 na B lanternas suspensas sobre o patamar com o pé acima de 3 m (`LANDING_LANTERN*`, luz 0,6).
- Teste: `tests/test_room_style.gd` com as quatro vistas (ida e volta, ar próprio, sombras iguais, nada do estilizado
  sobre o chão entre 0,3 e 2,6 m, o lago da B fora do chão). Robô: 8 sementes por arena e variante, nenhum `stuck`.
  fit_probe igual (Jardim 1,99 / 1,62 e 1,64; Ponte 4,12 e 2,76).
- Medido (RTX 1080, semente 5, `--shot-at=5`; `tools/frame_stats.py --hue --scene`): Jardim cena matiz 88 / 81 (era 234
  / 240), saturação 0,20 / 0,19, chão a leste da árvore matiz 86 / 93, luma 63 / 61, saturação 0,14; ciano 6,4 / 6,1%
  (era 32 / 24%); ferrugem só 0,5 / 1,2% (abaixo dos 2 a 6% da spec: a copa fica no alto do quadro e a folha caída no
  teto de 30% e 1,2 m). Ponte cena matiz 221 / 223, saturação 0,26 / 0,27 (era 0,39 / 0,40), ciano 49 / 56%, chão das
  plataformas luma 68 / 47 a 54 (B ainda abaixo de 55), parte quente 3,2%. Quadro na GPU: RTX 1080 Alta Jardim 2,26 para
  1,95 / 1,99 ms, Ponte 3,4 para 1,6 a 3,5 ms (instável nas duas); iGPU 720 Baixa Jardim 16,8 / 17,0 para 15,9 / 15,8 ms,
  Ponte 13,1 / 13,1 para 13,6 / 13,7 ms de quadro (cerca de 3 qps a menos; as aduelas de baixo e as pontes do fundo na
  pedra funda, mais barata que a cantaria pintada). Compatibility sem erro (o Jardim mais claro e mais verde lá).

## Redesenho das salas, Lote D (só no estilizado; spec `docs/art/room_redesign_lotD_spec.md`, capturas em `docs/gallery/redesign/lotD/`)
- **Biblioteca nova** (`ArenaRoom`): `diffuse_lights(sem_sombra)` (toda luz que não é fogo vira difusa, `light_specular` 0,
  sem disco de borda dura), `fade_banners(nós, fade)` (estandarte desbotado, um material por fonte, do Altar, agora comum),
  `wall_moss(sm, topos, cartão, cor)` (musgo de parede do Santuário, agora comum), `wall_ledge(sm, a, b, fora, altura,
  mat)` (prateleira de pedra com duas mísulas na folga entre a borda e a face da parede, `LEDGE_*`) e
  `style_backdrop(nós, bruma, pedra, borda)` (as ruínas do `backdrop()` no estilizado). `ArenaKit`: chão de runas
  pintado (`RUNE_FLOOR` / `RUNE_FLOOR_PAINT`, `rune_floor_paint.gdshader` com `#define PAINT` e `RUNES`, trocado pelo
  `paint_look`), metas `NOT_FIRE` (luz quente que o `stylize_fires` não mexe: a do perigo) e `KEEP_SHADOW` (fogo que
  fica com sombra no estilizado), `brazier(..., lit = false)` braseiro frio (ferro escuro, cinza, sem luz).
  `floor_decal.gdshader` `kind` 4: losangos concêntricos sulcados (`lozenges`, `groove_*`, lábio claro `groove_lip`).
- **Runas** (`RunesLook.STYLE`, cinza-ardósia frio): o estado das lajes é o mesmo material e a mesma textura nos dois
  looks; no pintado o traço das marcas e da moldura em repouso é marfim apagado (`paint_trace`, `paint_trace_share`
  0,45), nada âmbar fora do perigo, a pedra quieta da B mais escura (`paint_quiet_value` 0,5); armar, golpe e brasa
  iguais. Sulcos dos pilares e barras das estelas em marfim (`STY_IVORY`; o sulco volta ao âmbar com o calor, `heat`);
  luz de cima neutra e difusa (`STY_KEY`), luzes do perigo e fogos difusos (nada redondo, D-29). R2 mecanismo de
  quadrados de ouro velho na face norte (`MECH*`, foco frio sem sombra); R4 prateleira de estudo no corte noroeste
  (`STUDY*`); R5 na B cristais de prisma encostados na parede norte, só imagem (`CRYSTAL*`, `crystal_edge`, fora do
  chão e longe da pedra quieta).
- **Provação** (`TrialLook.STYLE`, lilás): ar e ruínas do fundo lilás (`STY_BACKDROP`), luzes difusas (o foco fica com a
  sombra); T1 losangos sulcados em volta da estela (`LOZENGE*`, sem círculo novo); T2 dois estandartes desbotados nas
  paredes norte e oeste; T3 mísulas com braseiros frios acima de 3 m (`COLD_BOWLS`, `CORBEL_TOP` 3,25); T4 prateleiras
  com urnas abertas e cacos (`SHELF_*`). `settle` apaga as veias igual nos dois looks.
- **Altar** (`AltarLook.STYLE`, calcário morno): ar e ruínas mornos, facho frio difuso e sem sombra (`STY_SHAFT*`); a
  luz das velas acesas é a única com sombra (`KEEP_SHADOW`) e pinta a poça de um braseiro (`BOWL`, `bowl_range` 7,5,
  `bowl_gain` 2,2); oferendas no topo do altar e em duas prateleiras na parede norte (`OFFERINGS`, `SHELVES`, urnas, pano
  dobrado petróleo e terra, tigela de ouro velho), pétalas pálidas diante do degrau (`PETALS`, decalque `kind` 3), hera
  pela `wall_moss` (`IVY`). Nada de figura alada, auréola, raio, sol ou cruz.
- Ferramentas: `tools/arena_lab.gd --look=classic|stylized` e `tools/fit_probe.gd --look=...`. Teste:
  `tests/test_room_style.gd` (ida e volta das quatro vistas, ar próprio, sombras iguais e nenhuma no que é só do
  estilizado, a vela acesa do Altar a única com sombra, nada do estilizado sobre o chão entre 0,3 e 2,6 m, o chão de
  runas pintado lê todo uniform do clássico e guarda o estado com F7, e 600 quadros de `RuneFloor` com o mesmo estado,
  divisas e dano no herói e no inimigo nos dois looks). Robô: 8 sementes nas Runas A e B, `--start=trial` e
  `--start=altar`, nenhum `stuck`. fit_probe igual nos dois looks (Runas 2,61 / borda falsa 0,45; Provação 1,12; Altar 3,36).
- Medido (RTX 1080, semente 5; `tools/frame_stats.py --hue --scene`): Runas chão da luta matiz 227 a 231, luma 68 a 77,
  saturação 0,09 a 0,11 (clássico 0,38 a 0,52); armado, laje acesa luma 171 contra 73 do chão vizinho, matiz 31 (clássico
  29); em repouso 0,3% de âmbar (os braseiros). Provação quadro matiz 266 a 268, luma p50 47, vermelho só o do HUD; veias
  de 94 para 69 depois do `settle` (clássico 100 para 76). Altar chão matiz 36 a 37, luma 51 antes do `kindle`; parte
  quente do quadro do jogo 4,2% antes de acender (portas e placas), no laboratório só a sala 0,6% para 2,7% acesa (abaixo
  dos 4 a 10% da spec contados só na sala). Quadro: RTX 1080 Alta Runas 1,85 / 1,90 para 1,75 / 1,80 ms, Provação 2,20
  para 2,17, Altar 2,23 para 2,26; iGPU 720 Baixa Runas 12,9 / 12,8 para 12,6 / 12,8, Provação 15,2 para 14,1, Altar
  16,3 para 16,2 ms (nada perdido). Compatibility sem erro. O clássico é o mesmo (diferença só nas partículas e nas divisas
  que andam).

## Redesenho das salas, Lote E (só no estilizado; spec `docs/art/room_redesign_lotE_spec.md`, capturas em `docs/gallery/redesign/lotE/`)
- **Câmara do Selo, só fundo e ar**: nada dentro do círculo nem a menos de `BossChamber.STY_CLEAR` (12,5 + 6 m) do meio
  além do anel distante; chão, selo, `SealLook`, balaustrada, fachada, escada, avisos, colisão e câmera iguais; nenhum
  preset de pedra. Peças no `kit.styled()` da câmara (`BossChamber._stylize`, no `build` antes do `merge`, dado próprio
  `STY_SEED`, nunca o `_rng`): E1 cinco arcos partidos a meia altura nos vãos oeste do anel distante (`STY_ARCHES`,
  `STY_ARCH`, `STY_ARCH_GAPS`, `Masonry.broken_arch`; pedra do anel que afunda na bruma mais embaixo, `STY_ARCH_SINK`)
  com uma aduela pendurada numa corrente (`STY_ARCH_HANGS`, `STY_HANG`); E2 duas correntes de lado (`STY_CHAINS`: da torre
  para oeste, da parede da plataforma para nordeste; nunca sobre Morvath na tela); E3 24 cacos de pedra parados no abismo
  nas laterais do quadro (`STY_SHARDS`, `STY_SHARD_SPANS`, pedra da torre, sem brilho); E4 céu a `STY_SKY` 0,9 no
  `BossChamber.dress`, borda das agulhas `STY_SPIRE_EDGE` 1,15 e o anel distante um degrau mais claro (`STY_FAR_TINT`
  1,4, bruma em que afunda `STY_FAR_MIST`) pelo `VisualProfile.vary`. SW-K1 (aprovado 2026-11-19): quatro gaiolas de ferro vazias penduradas por correntinhas nas correntes de fora, duas a oeste e duas a leste, uma com a porta aberta e uma com barra torta (`STY_CAGES`, `STY_CAGE*`, `Masonry.cage_mesh`, `cage_hook`), ferro `ArenaKit.STY_IRON` com a borda das correntes, sem luz nem sombra, balançando devagar no `_process` (`_swing_cages`, só visíveis); caixa de Morvath igual (`docs/gallery/redesign/sworn_p1/k1_*`). F7 na câmara: `Arena.restyle` chama
  `BossChamber.restyle` (veste o ar da câmara de novo no look em uso); na fase 4 o `RoomMood` segue mandando no ar.
  Gêmeos das velas que abrem em volta do herói (`Masonry.see_open`) pegam a cor clássica do material e a estilizada
  pelo `VisualProfile` (antes, montados no estilizado, ficavam com a chama estilizada no clássico). `tools/chamber_lab.gd
  --look=classic|stylized`. Testes em `tests/test_room_style.gd` (ida e volta, montada no estilizado igual no clássico,
  peças longe e correntes fora de Morvath).
- Medido (RTX 1080, semente 5, `--hue --scene`): quadro matiz 256, luma p50 35 a 36 (antes 36), violeta 1,6% na fase 1
  e 1,9% na fase 4; fundo p90 menos p10: alto à esquerda 44, abismo oeste 129, leste 150 (alto à esquerda p50 24 para
  29); chão e avisos iguais; o clássico igual nas três vistas. Quadro na fase 4: RTX 1080 Alta 2,38 / 2,20 para 2,44 /
  2,22 ms, iGPU 720 Baixa 15,4 / 15,3 para 15,1 / 15,3 ms; Compatibility sem erro.

## RS-C1, Criptas (só no estilizado; spec `docs/art/rs_c1_crypt_spec.md`, antes e depois em `docs/gallery/redesign/rs_c1/`)
- Cada variante da Cripta ganha uma peça funerária que manda no quadro, tudo em `kit.styled()` ou por `VisualProfile.vary`
  (o clássico igual: diferença só em chamas e partículas). **A, o túmulo coroado**: coroa de velas pendurada a 6 m sobre o
  túmulo grande (`CryptLook._crown`, `CROWN_*`: aro de ferro de 1,5 m com aro interno e raios, 16 velas, 5 apagadas, halo
  morno em cada acesa; ferro, cera, chamas e halos abrem em pontilhado em volta do herói, ferro no `candle_wax_see`
  com `ArenaKit.STY_IRON`; três correntes até o gancho e uma até 10 m, abaixo do relógio, num MultiMesh só,
  `ArenaKit.chains`; tudo sem sombra, um mesh por material, `Masonry.merge(from, false)`, chamas e halos em MultiMesh,
  `Masonry.gather_billboards`; numa camada própria `CROWN_LAYER` 128 que a luz dela não acende, senão queimava a cera de
  branco), luz própria `NOT_FIRE` (`CROWN_COLOR` um pouco mais amarela que a vela, 1,25, alcance 9,5,
  atenuação 0,4: com 1,0 a 5,7 m a poça pintada não abria) e o pano petróleo nas faces sul e leste do túmulo com o leão
  de ouro velho no sul (decisão do Daniel, 2026-11-19; `_pall`, `reliquary_cloth.gdshader`, `PALL_*`, franja de ouro).
  Calam na A: a luz do degrau oeste do túmulo (apagada), a vela do sarcófago norte a 0,6, as velas das estátuas a 0,5, os
  braseiros da porta a 0,75 (`ArenaKit.FIRE_SHARE`), o facho frio a 1,1. **B, a velada do ossuário**: plinto com mísulas
  sobre a ponta norte do muro e a figura encapuzada de 4,4 m (topo a 8 m, acima da cornija; `VEILED_RS_VALUE` 1,75, brilho
  próprio 4,0) com a lanterna fria pendurada das mãos (`ArenaRoom.hanging_lantern(..., lamp)` aceita outra cor; luz difusa
  `STY_COLD` sem sombra, `NOT_FIRE`, `LANTERN_*`), o facho frio reapontado para o peito dela (`STY_SHAFT_*`) e a poeira dele
  escondida; calam os dois braseiros da porta (apagados só no estilizado, `ArenaKit.quench`: tigela e aro no ferro frio,
  cinza fria, chama, brasas e luz escondidos, colisão igual), o estandarte ao lado da figura e as velas da estátua do nicho
  norte (apagadas, sem luz). Luzes acesas no estilizado: A 18 (igual), B 16 (eram 18); com sombra, iguais
  (`tests/test_room_style.gd`, `test_rs_c1_*`).
- Medido (laboratório, RTX 1920 x 1080, `--bare`, alvo (1,0; 1,5); o laboratório não desenha chamas de vela, antes e
  depois; no jogo a coroa tem quente 17% e p90 146): A, coroa quente 17,1% e p90 107, poças em volta do túmulo luma 111 e 118 (matiz 32 e 30), chão leste 79
  (matiz 208), pano luma 47 (matiz 191, leão p90 110), coluna do meio quente 3,7% e cena 3,0%; B, figura luma 76 contra
  41 da parede, cabeça acima da cornija 60, lanterna p90 149 (matiz 208), braseiros sem quente (p90 82 e 96), cena 1,2%.
  Chamadas de desenho +8 a +12 na A, +2 na B; quadro igual (RTX 1080 Alta 1,65 a 1,69 ms, iGPU 720 Baixa 13,2 a 13,5).

## Hub (HUB-01; HUB-B1 fundação, plano em `docs/design/hub_spec.md`, espaço em `hub_spec_art.md`, auditoria em `hub_audit.md`)
- Fluxo: título, Iniciar, **hub** (`scenes/hub.tscn`, `Hub`, `scripts/game/hub.gd`), Portal (interagir e "Descer às
  catacumbas?" Descer/Ficar, `HubPanel`; Juramentos antes depois da primeira vitória, como era o Iniciar), partida. Tela de
  fim "Voltar ao {HUB}" e pausa "Sair para o {HUB}" voltam ao hub; "Descer de novo" segue direto. No hub, Esc abre o
  `PauseMenu` com `hub = true` (Compêndio, Configurações, Voltar ao título). Toda troca de cena por `SceneGo.to`
  (`TITLE`, `HUB`, `GAME`; `SceneGo.catch` nos testes). Nome do lugar só na chave `hub_name` ("Santuário", provisório,
  D-H4): `TextTable` troca `{HUB}` por ele em qualquer texto.
- Ação `interact` (E, A no controle; remapeável; linha no Como Jogar). Save que já usava o E em outra ação: `interact`
  vai para a primeira livre de `Controls.SPARE_KEYS` (F, G, T, C, V; `keys_for`); remapear para uma tecla usada troca
  as duas (`rebind`).
- Herói em paz (`Player.peaceful`): só anda e corre (segurar a esquiva); nenhum golpe, especial, círculo, ultimate nem
  esquiva; empurrado no meio de uma peça redonda desliza em volta (`RoundSlide`, só no hub). Sem HUD de combate.
- Planta (`HubPlan`, `core/hub_plan.gd`, fora do `StageDef`: chão, chegada, cinco pontos de uso, âncoras, obstáculos, eixo
  (u, v) girado pelo `cam_yaw`). **Chão de 50 x 33 m** (o PO achou o primeiro, 25 x 16,5, pequeno: a Encruzilhada do Hades II
  espalha os NPCs por uns 80 x 35 m; `HALF_U`, `NORTH`, `SOUTH`, `CUT`), fonte no meio (origem), portal ao norte, Vendedor
  em cima à esquerda, Forjador embaixo à esquerda, Árvore em cima à direita, Livro embaixo à direita, de 3 a 5 s de
  caminhada entre eles; peças em constantes (`FOUNTAIN`, `COUNTER`, `ANVIL`, `SMITH_SPOT`, `DAIS`, `LECTERN`, `LAMPS`,
  `BENCHES`, `BEDS`, `URNS`), todas fora das linhas retas da chegada às estações. Câmera: ponto `CAM_TARGET` com
  `CAM_REACH` 16 m (`CamFrame.hold`: anda só o que a margem de 18% do herói pede, então chega a qualquer estação e na
  borda mostra o hub, não o penhasco; uma caixa `cam_bounds` no mundo não serve, o hub está a 35 graus dos eixos); a
  câmera Perto segue o herói (`CamRig.near`). Foco por distância com histerese (`HubFocus`: entra a 2,2 m, sai a 2,8, troca por
  0,4 m mais perto; sinal `Hub.focus_changed`).
- **Cenário (HUB-B2, `HubLook`, `scripts/game/hub_look.gd`, look `hub` sobre `ArenaRoom`; capturas em `docs/gallery/hub/b2/`)**:
  pátio aberto ao entardecer, montado no eixo do hub dentro de um nó girado pelo `cam_yaw` (`HubLook.frame`, `at(u, y, v)`,
  `world(u, y, v)`; kit e `Masonry` próprios, `fk`/`fm`). Bordas só penhasco (`edge`), peças `hub_*` desenhadas pelo
  `dress` sobre a pegada do `HubPlan.layout()` (a mesma que colide; `piece` pula as `hub_*`). Fachada em duas camadas
  com vãos cortados por `_wall` (blocos inteiros entre os vãos, fatias de `BAND` só sobre cada arco), portal com três
  ordens de aduelas e a aduela do leão (nunca estrela), escada de 6 degraus que **não** é chão (o portal é usado ao pé
  dela, `HubPlan` sem mudança), terraço com duas estelas do leão em relevo (`altar_lion.gdshader`), braseiros sem
  sombra, floreiras; arcadas de quatro arcos de cada lado abertas para as ruínas e a cascata; paredes laterais com o forno (oeste,
  única luz de fogo com sombra, `KEEP_SHADOW`) e a estante de rolos (leste), um nicho com figura encapuzada em cada
  uma e um degrau de 1 m entre o chão e a parede com urnas, caixotes e velas (`_ledge`); nichos com figuras na fachada;
  na praça anel de ouro em volta da fonte com fios para as estações, bancos, urnas grandes em plintos e canteiros; mureta baixa com balaústres (abaixo de
  0,72 m), escada de chegada com grade e dois postes com lanterna. Praça: leão do medalhão em ouro velho embutido
  (`INLAY_GOLD`) com dois anéis e o fio de ouro no eixo, lajes de losangos sulcados nos cinco pontos de uso, fonte do
  leão só decorativa (bacia em blocos, água escura `dark_water`, estela com o leão e o fio d'água, musgo com flores
  ocre e terra). Estações: toldo listrado terra e ocre com o leão sobre o balcão do Vendedor, mercadorias em âmbar,
  marfim e azul-ardósia, duas lanternas; forno, bigorna e cavalete com três lâminas de ponta para cima e o escudo do
  leão; Árvore de Dons = `StoneTree` a 0,65 em ouro velho (sem cristais, veios de ouro, folhas de ouro pálido no
  `canopy.gdshader`) sobre o estrado octogonal, luz quente sem sombra; Livro de Ahk aberto no atril
  (`hub_page.gdshader`: pergaminho com linhas de tinta e rubrica, nada legível), fita petróleo, velas, tapete. Luz por
  estação em `HubLook.station_lights` (`station_light(id)`, para o HUB-B3). Ar e pintura próprios (`AIR`, `STYLE`:
  calcário morno, sombra petróleo; ambiente e lua um pouco mais neutros que a spec para a saturação ficar na meta) e
  no Compatibility `STY_COMPAT_*`; no clássico (F7) o chão é o calcário `CLASSIC_FLOOR`, não a laje rosada do salão. `tools/fit_probe.gd -- --arena=hub`. A cantaria e as lajes seguem o quadro girado (HUB-D,
  global `frame_yaw`, ver abaixo).
- **Placa e páginas (HUB-B3 e a interface do HUB-C; testes em `tests/test_hub_ui.gd`, capturas em `docs/gallery/hub/ui/`)**:
  uma placa só, da estação em foco (`StationSign`, `scripts/ui/station_sign.gd`, na língua da `DoorSign`: nome em ouro
  claro, linha curta em marfim, véu escuro de cantos cortados, e embaixo a tecla real na plaqueta do HUD,
  `ActionSlot.key_plate`, redonda num botão do controle, e "Interagir", `hub_use`); a tecla troca ao vivo por
  `Controls.device_changed` e relê o mapa quando uma tela fecha (`refresh`). Presa à âncora do `HubPlan`, dentro da tela
  e nunca sobre o herói (`StationSign.place`: sobe acima da cabeça, `HERO_GAP`), aparece em 0,15 s, some com tela aberta;
  clique nela usa a estação (`pressed`). Portal: "Descer às catacumbas?" numa folha do Livro (`HubPanel`: `BookSpread`
  com `single`, uma página com as duas bordas tostadas e sem dobra, `single` no `book_page.gdshader`, do tamanho do
  conteúdo; marca da porta do Como Jogar, título Cinzel em rubrica, filete, uma linha do que fica e do que não fica,
  `hub_descend_line`, Descer em destaque e com foco, Ficar). Vendedor e Forjador: a mesma folha com o medalhão trancado
  (`SealedMark`), "◆ A DEFINIR", "Ainda não há nada para comprar/forjar aqui nesta versão." e só Voltar (nada de compra
  falsa). Livro de Ahk: ao lado do medalhão do Guerreiro, três lugares selados (`HeroScreen.SEALED`, `SealedMark` com
  silhueta encapuzada sem rosto e cadeado; sem nome, texto, foco nem clique, D-H3) e "Compêndio" no rodapé (abre o
  `CodexScreen` sobre o livro; Esc ou B volta com o foco no botão). Menu do hub (`PauseMenu.hub`) com Como Jogar.
  Música: lugar próprio `MusicCatalog.HUB` ("{HUB}" na tela Músicas, opção `music_hub` do save), toda peça do título,
  padrão a do título (do título ao hub a música segue sem emenda). Capturas: `--hub --hero-at=x,z`,
  `--hub --hero-at=<estação>` (no ponto de uso dela), `--hub-use=portal|vendor|tree|smith|book`, `--hub-menu`, `--pad`.
- Peças comuns tiradas do `Game` (mesmo RESULT, `smoke 300` e `--start=boss --boons=25`, semente 5): câmera `CamRig`
  (`game/cam_rig.gd`: segue, segura o ponto fixo, trace; `Game.cam`), ar do mundo `WorldAir` (`game/world_air.gd`;
  `Game.air`), anfitrião de telas `ScreenHost` (`ui/screen_host.gd`, do título e do hub: Esc/B fecha,
  `Controls.clear_presses`, nada vaza). `--hub` entra direto no hub (`--hero-at`, `--shot`); `--bot`, `--smoke`,
  `--start`, `--stress`, `--play` e `--shot` sem `--title` seguem pulando título e hub (`boot.route`). Testes em `tests/test_hub.gd`; fluxo por teclado em `tools/title_flow_check.gd`.
- **HUB-D, parte do technical-artist (Meshy zero; capturas em `docs/gallery/hub/d/`, testes em
  `tests/test_hub_d_assets.gd`)**: **gente do hub**: Vendedor e Forjador são bonecos do KayKit Adventurers (CC0)
  assados como a multidão antiga, `tools/bake.gd -- npcs` (`NPCS`, 1 s cada) em `assets/baked/npc_vendor.res` e
  `npc_smith.res` (no pacote; a paleta própria, `tools/make_palettes.gd -- npcs`, vai comprimida dentro do `.res`,
  `"embed"`, porque `assets/models/palettes` é excluído): `Rogue_Hooded` sem armas, capuz petróleo escuro e manto
  terra; `Knight` sem elmo, escudo, espada nem capa, braços nus e pernas de lã por `remap`, avental de couro e martelo
  procedural `NPC_HAMMER` na mão (peça `hammer`); `Slender`, `height` 1,90 e 1,95 m com as solas no chão, cabeça a
  `head_shrink` 0,9; 4 005 + 4 232 triângulos (teto 12 mil). Opções novas do modo KayKit do assado: `height`,
  `head_shrink`, `embed` e o 4º campo do clipe `{from, to, bend}`. Desenhados por `HubNpc`
  (`scripts/render/hub_npc.gd`: um `CrowdRenderer` próprio com uma figura, a mesma pintura, contorno e faixas do
  estilizado da multidão, F7 ao vivo, mas mais claros que os mortos: T-1 da re-revisão, `HubNpc.STYLE_LIGHT` 0,5,
  `STYLE_SCENE` 0,3 e `STYLE_RIM` 0,35 contra 0,2 / 0,1 / 0,18 da multidão, o Vendedor, de capuz escuro sob o toldo,
  vezes `STYLE_VENDOR` 2,2; corpo na câmera Perto de luma p50 cerca de 55 para 79 no Forjador e 45 para 76 no
  Vendedor, o herói ao lado 94 a 97; `HubNpc.make(HubNpc.Who.VENDOR|SMITH)`, `face(ponto)`, `gesture()`): parado no
  `Idle` e um gesto de vez em quando (Vendedor `Interact` a cada 6 a 9 s; Forjador em séries de 3 a 5 golpes do
  `1H_Melee_Attack_Chop` a cada 1,2 s, cortado onde a cabeça do martelo pousa na face da bigorna a 0,94 m com o
  tronco 12 graus para trás, `HubNpc.landing`, `strike_point`, e 4 a 7 s de descanso), fagulhas âmbar pequenas
  (`CPUParticles3D`, 10, 0,4 s, nenhum canal acima de 1,0) no quadro do golpe. Postos pelo `HubLook._people`: o Vendedor
  atrás do balcão (`VENDOR_STAND`, virado 30 graus para a câmera), o Forjador a oeste da bigorna olhando para ela de
  perfil, onde o martelo pousa nela (0,79 m da bigorna; o `HubPlan.SMITH_SPOT` de colisão fica 1,7 m dela e deve ir
  para esse ponto, dono gameplay-engineer). **`frame_yaw`**: global de shader (`project.godot`, padrão 0) que
  `frame_yaw.gdshaderinc` (`frame_in`, `frame_out`) usa para assentar a cantaria (`masonry.gdshaderinc`) e as lajes
  (`catacomb_floor.gdshaderinc`, fora das lajes emolduradas e das Runas) no quadro da sala; o `HubLook.dress` o põe no
  `cam_yaw` (`HubLook.FRAME_YAW`) e o `_exit_tree` volta a 0; com 0 nenhuma conta muda (as salas iguais).
- **HUB-D, planta e cenário (environment-artist; revisão `docs/gallery/hub/ART_REVIEW.md` H-P0-1 a H-P0-4, LR-07 do
  room-designer; capturas em `docs/gallery/hub/d/`, testes em `tests/test_hub_d.gd`)**, valendo sobre a Planta e o
  Cenário acima: a câmera Longe vê uns 25 m de chão entre a margem do herói e o portal a um quinto da tela, então o
  portal veio 4,5 m para dentro (fachada em v 17,5, folha `SHEET_V` 18,75, escada do pé `HubPlan.NORTH` 12) e o chão
  sobe ao lado do terraço em dois lóbulos até `LOBE` (16, a partir de |u| 9), onde ficam Vendedor e Árvore; o herói
  chega pela escada num poço cortado na borda sul (`WELL`: meia largura 3,5, topo em -9; 20 degraus que descem até a
  bruma, sem grade) e aparece em `ARRIVAL` (0; -7,8) na borda do medalhão (0; -4,6). Chão 50 x 32,5 m. Estações a 11,5 m
  do eixo (`USE`; nenhum par a mais de 4 s andando, `test_no_two_stations_more_than_four_seconds_apart`), portal usado ao
  pé da escada (0; 11), a placa na metade direita da escada (fora do portal e do herói). Câmera: `CAM_TARGET` (0; 5,6) deixa a soleira do portal a 0,22 da tela e o
  arco inteiro (`PORTAL_TOP`, a 3ª ordem a 7,8 m) da chegada e de toda estação, sem a câmera se mexer ao chegar no portal
  (o `SHOW` dele fica mais baixo; `test_far_the_portal_shows_whole_from_everywhere`);
  na Perto o `Hub.lean` sempre segue o herói por `HubPlan.near_want` (nunca olha ao sul de `NEAR_SOUTH` -6), a borda sul
  fica abaixo de 0,85 da tela (`test_near_the_south_edge_stays_low`); ao chegar pela escada a Perto olha primeiro o ponto
  da Longe (`HubPlan.CAM_TARGET`) por `HubPlan.ARRIVAL_LOOK` 1,5 s, com a margem de 18% do herói valendo, e só então o
  segue (`HubPlan.near_want_at`, `Hub.arrived`; P1-A2 da revisão `ciclo_visual_1120`: o portal no alto do quadro, verde
  36,8% na caixa 690,0,300,150 a 1672 x 941 no `--shot-at=1`; a Longe igual; `--hero-at` pula isso); com estação em foco a câmera ainda se inclina pelo
  `HubPlan.frame_for` (`SHOW`, `CamRig.lean`). Estações com lugar próprio e de frente para a câmera: barraca do Vendedor
  no lóbulo oeste (`COUNTER` com `COUNTER_HALF`, toldo de 5,8 m listrado terra e ocre de 5 a 3,5 m de altura sobre quatro
  postes, `AWNING_*`, prateleiras atrás, mercadorias, duas lanternas; mercadorias encostadas, `GOODS`); Árvore a 0,56 (inteira na tela da Longe, re-revisão E-3) em ouro mais velho sobre
  o estrado no lóbulo leste (folhas em cartões maiores e em menos lugares, H-P2-1); forja no chão a noroeste da bigorna
  (`FORGE`, `FORGE_HALF`: bloco de 3,8 x 3 m e 3,4 de altura, boca em arco para o sul com brasas, fogo e brilho, coifa,
  chaminé de 5,8 m com fumaça, a única luz de fogo com sombra), bigorna 1,5 vez maior, os dois NPCs com círculo de corpo onde são desenhados (`HubPlan.SMITH_SPOT` onde o martelo do
  Forjador pousa, `VENDOR_SPOT` 0,4 m atrás do balcão, `test_the_npcs_block_where_they_stand`), pátio a oeste (`YARD`: cavalete com
  quatro lâminas e o escudo do leão de frente, cocho, carvão, rebolo; o desenho no `hub_yard`, as outras partes só
  colidem, `hub_yard_part`); Livro num atril de 1,5 m sobre degrau, dois castiçais de ferro, tapete, estante alta de 4 x 4,6
  m de frente (`SHELF`, `_shelf`: livros, rolos, escada, velas) e a mesa de escrita (`DESK`); os pátios de baixo fechados
  ao sul por muretas de 0,65 m (`YARD_WALL`). Praça: fonte de 5,6 m com estela de 2,8 e o leão em ouro velho (H-P1-5,
  H-P2-2), lajes em anel nela e no medalhão e caminhos de lajes com meio-fio e um fio de ouro de 0,18 m que termina na
  laje de uso (`_pave_way`, `WAY_FILET`, `WAY_SHORT`; as de cima saem da fonte, as de baixo do medalhão, H-P1-2),
  ciprestes em floreiras (`CYPRESSES`), canteiros elevados com arbustos de cobre (`BEDS`, `ARBOUR`, `_crowns`
  "Shrubs", `SHRUB_*`; os de flores pareciam caixões), urnas grandes abertas com um arbusto de cobre (fechadas e altas pareciam espetos pretos), bancos ao lado do eixo do portal, braseiros em pé
  ao lado da escada de chegada (`ARRIVAL_FIRES`, sem sombra, luz quente na praça, H-P1-7) e postes com lanterna; nichos
  de fora da fachada com urna no lugar da figura (H-P1-4); estelas do leão do terraço a 1,7 vez (H-P1-3, procedural).
  `HubLook.focus(id)` (chamado pelo `Hub` no `focus_changed`): a luz da estação em foco sobe `FOCUS_GAIN` 25% por uma
  gêmea sem sombra e um fio de ouro fraco (`FOCUS_RIM`, `ScreenTone.fit`) contorna a laje de uso, entrando e saindo em
  `FOCUS_EASE` 0,3 s. `HubLook.set_forge_rank(n)` (0 a `FORGE_RANKS` 3, para o gameplay-engineer pelo `hub.arena.look`):
  brilho do fundo da forja mais forte, uma gêmea de luz `FORGE_RANK_LIGHT` 0,3 por posto e duas línguas de fogo a mais
  desde o posto 2. Medalhões da Fatia 1 no `RewardGem`: Prata Antiga em prata com a barra (`Mark.INGOT`, aro de prata) e
  Fragmento de Memória em pergaminho com a folha rasgada a tinta (`Mark.LEAF`, `parchment` no `reward_gem.gdshader`);
  Re-revisão do art-director (E-1 a E-4): os braseiros do terraço acendem difuso no estilizado (`light_specular` 0, sem
  os discos de borda dura na fachada), a luz da forja fica `FORGE_LIGHT_EAST` 1,5 m a leste da boca (a poça chega à
  bigorna e ao Forjador) e dois canteiros baixos partem os quadrantes de baixo da praça (`BEDS`, u ±7,4, v -1,5; o
  maior quadrado livre de peça é o do medalhão da chegada, 8,5 m). `tools/gem_lab.gd` mostra os medalhões lado a lado (`docs/gallery/hub/d/medallions_silver_memory_720.png`). Capturas do hub
  com a câmera Longe pedem `--cam=far` (a Perto é o padrão desde o LR-01).
- **Santuário da Vigília Rev. 02, HV-A e HV-B (gameplay; backlog P.5, Q-HV1 a, Q-HV2 a; `tests/test_hub_rev02.gd`)**,
  valendo sobre a planta acima: o poço sul saiu; toda chegada (save novo, carregar, morte, vitória, pausa, todas por
  `SceneGo.HUB`) é no selo do Retorno `HubPlan.ARRIVAL` (18; -11,4), sobre a escada de 7 m na borda sul
  (`ARRIVAL_STAIRS` u 14,5 a 21,5; o canto sudeste deixou de ser cortado); "Descer de novo" segue direto. Usos:
  Vendedor (-10,3; 5,2), Árvore (10,1; 5,0), Forja (-10,3; -5,2), Livro (10,1; -5,1), Portal (0; 11) igual; cada
  estação leva as peças no mesmo lugar em volta do uso (`COUNTER`, `DAIS`, `ANVIL`, `SMITH_SPOT`, `FORGE` ao sul do
  Alquimista, `LECTERN`, `SHELF`, `DESK`, `YARD`, âncoras e `SHOW`); Fonte com 3,1 m; Alquimista reservado
  (`ALCHEMIST`, bancada `ALCHEMIST_BENCH` que barra, peça `hub_alchemist`, fora de `STATIONS`: sem foco, placa nem
  uso); muro do pátio só a oeste; bancos nos lóbulos norte; ciprestes e urnas dos lados para as paredes; canteiros,
  braseiros (os dois do Retorno), lampião e urna fora do caminho do Retorno. `HubLook` só o mínimo: escada nova com
  muretas, leão gasto no selo (`SEAL_LION`, `SEAL_GOLD`), bancada provisória do Alquimista, poças do `STY_POOLS`
  movidas com as estações; a forja continua com a boca para o sul (girar é do HV-C). Câmera (HV-B): do selo nenhuma
  câmera mostra o arco inteiro do Portal com ele a 18% da borda, então por `ARRIVAL_LOOK` 1,5 s as duas olham de
  `ARRIVAL_DISTANCE` 60 m com o herói a `ARRIVAL_SAFE` 0,14 (soleira a 0,23, topo do arco a 0,04, Fonte e duas
  estações à vista) e voltam em `ARRIVAL_EASE` 1 s à própria distância e aos 18% (`HubPlan.arrival_share`,
  `CamRig.wide`, `wide_distance`, `safe`, `dist()`; `CamFrame.hold(..., safe)`). Caminhadas medidas pelo campo de
  fluxo: entre estações 1,47 a 3,40 s; do selo ao Portal 4,25, à Forja 4,25, ao Vendedor 4,88 (a chegada não é
  estação). `fit_probe --arena=hub`: fantasma 6,11, sem desenho 7,20 (antes 6,09 / 7,18).
- **Fatia 1, parte do technical-artist (`docs/design/rejogabilidade/sistemas.md` 3.4; provas em `docs/gallery/rj1/`,
  `tools/rj1_lab.gd`)**: a Emeth por posto de Temperar: `temper` no `emeth.gdshader` (0 a 2, padrão 0 = a lâmina de
  sempre; frações fazem crescer), `EmethSword.set_temper(blade, posto)` e `EmethSword.TEMPER_MAX`: cada posto põe um
  veio de ouro velho num lado do meio da lâmina (`temper_gold`, até `temper_reach`) e estende o fio pálido do gume
  (`temper_thread`, `temper_edge`: posto 1 até a metade, 2 até a ponta), nada acima de 1,0, no estilizado sob o
  `style_cap`; o gameplay-engineer liga ao `ForgeRank`. Selos dos quatro anjos em código (`AngelSeal`,
  `scripts/ui/angel_seal.gd`: `AngelSeal.new().setup(Boon.Family.X, px, lit)` ou `AngelSeal.mark(ci, família, centro,
  raio, linha, cor)`): o selo da casa (`SealMedal.draw_seal`) e a marca da família (Chama brasa em losango com três
  línguas de fogo, Geada floco de seis braços, Luz um feixe sem ponta que desce sobre um losango, o topo reto esmaecendo (alfa 0,2 no alto a 0,9 embaixo) e alargando até a largura do losango com dois fios nas bordas, T-2, nunca pedra em pé nem raios, Vigília a trombeta do
  vigia, oliva, T-3), cores calmas em `AngelSeal.TINT`; nunca sol, cruz, leão, escudo nem olho; o Elo não tem selo.

## Rejogabilidade, Fatia 1 (gameplay; spec `docs/design/rejogabilidade/sistemas.md` 1, 3 a 5; API para a UI em 5.3)
- **Três materiais, sem Brasa** (Q-RJ1 a Q-RJ3): Prata Antiga, Fragmento de Memória e Esmeralda (nomes de trabalho),
  `MaterialPurse` (`core/material_purse.gd`, puro: soma por fonte na descida, teto 999/999/99, `bank` no fim, `give`,
  `spend`, `parse`). Na descida (`game.materials`): elite comum abatida 1 de Prata (não guardião nem chefe,
  `Rooms._on_killed`), porta de Prata 10 e de Memória 3 (`RunMap.Reward.SILVER` e `MEMORY`, `_give`), guardião 6 e 2
  (`_room_cleared`), Provação vencida 2 de Memória (`_fight_won`), cada fase de Morvath alcançada 2 (até 4, uma vez,
  `Rooms.boss_phase`) e a vitória 10 e 3 (`Rooms.victory`); números no grupo Materials do `StageDef` (`_stage` do
  `make_data.gd`). Baralho das portas com 16 cartas (uma Prata, uma Memória a mais; nada saiu). Guardados no save no
  fim de toda descida (`Game.log_run`, `Game.banks_materials`): nunca o robô nem sem save (`--materials-keep` deixa o
  robô guardar, para medir). Robô: porta de material com peso 2,6 / 2,4 (`Rooms.BOT_MATERIAL_RANK`, entre Magia e romã).
- **Forja** (`Forge`, `core/forge.gd`; `ForgeRank` em `data/forge/emeth/`, parte `forge`): Temperar I 15 de Prata (+10%
  no ataque, tag `light`, a lança junto) e II 35 (+10% no especial, tag `heavy`); somados ao `BoonState.stat` pelo
  `equip_forge` (`Game._equip_forge`: do save para gente, `--forge=N` também para o robô). No hub o Forjador abre a
  Forja (`ForgeScreen`, ver a interface da Fatia 1 abaixo), que compra, grava e emite `Hub.forged(rank)`.
- **Dons abertos com Memória** (Q-RJ11: a Maestria revela um Dom por nível): `TalentDef.memory_cost` (o custo de
  Devoção; 0 no Dom do nível 1, o Quarto Corte), `opened` no bloco do herói; `Talents` com `SEALED`, `OPENED`, `SHORT`,
  `open_in`, `open_problem`, `is_open` (`opened` nulo = tudo aberto, o robô e `--talents`). `HeroLoadout.State.SEALED`;
  abrir é só pela confirmação na página do Livro (`HeroLoadout.open`; `toggle` nunca abre um selado).
- **Anjos e o Encontro** (Q-RJ4 a Q-RJ6, nada canônico): Sarael (Chama), Nivael (Geada), Lumael (Luz), Shomael
  (Vigília), `AngelDef` em `data/angels/` (parte `angels`). Toda Bênção de sala e do guardião vem de dois anjos
  (`Encounter.pair` no dado da sala, `Encounter.dice`, sal 9241; a Bênção da loja segue o sorteio de antes); o anjo
  escolhido oferece até 3 Bênçãos da família (`BoonState.draw` com filtro, `Encounter.belongs`: o Elo pertence se uma
  das listas tem a família), raridade, troca, Elo e Salmo como antes, dado próprio por anjo (`cards_dice`). Só um anjo
  com carta: vem sozinho; nenhum: o Fôlego. `Encounters` (`game/encounters.gd`, `game.encounters`) conduz; gente vê a
  o Encontro (`EncounterScreen`, ver abaixo; a `AngelChoice` provisória só abre se ninguém ouvir `Encounters.opened`) e depois a `BoonChoice`; robô e `--autopick` escolhem por
  afinidade (`Encounter.affinity`). `--angels=a,b`, `--no-angels`.
- **Save versão 6** (`materials`, `materials_total`; no herói `opened`, `forge`, `tools`): a migração abre de graça
  todo Dom que a Maestria já destravava e dá 5 de Prata por descida jogada, até 30 (Q-RJ8). `_fixed_keys` entra nos
  blocos com chaves conhecidas (`forge`). Fixture `tests/fixtures/save_v5.json`. **Registro e `RESULT` versão 5**:
  `materials` (por fonte e total), `forge`, `talents_opened`, `angels` (um por encontro: `room`, `node`, `offered`,
  `chose`, `cards`, `fallback`). Opções `--materials=silver:30,memory:5` e `--forge=N` (só na sessão).
- Testes: `tests/test_rejogabilidade.gd` (puros, A1, A3, A4, A6) e `tests/test_rejogabilidade_game.gd` (cena: o
  encontro, robô por afinidade, materiais por fonte, A2, Forjador).

## Rejogabilidade, Fatia 2 e DV-2 (gameplay; spec `sistemas.md` 1.5 a 1.7 e 3.6, API para a UI em 5.3 "Fatia 2"; testes em `tests/test_fatia2.gd`)
- **Portas (RJ-2, RJ-3)**: baralho de 21 (mais 2 `ENCHANT`, 1 `PSALM` e 2 `BOON`, para a Bênção manter a fatia de antes); grupos `RunMap.Group` POWER (Bênção, romã,
  Encanto, Salmo), BODY (coração, Magia, ouro, cura), HOME (Prata, Memória), `RunMap.group_of`; o gerador prefere a
  carta de um grupo que as portas irmãs ainda não mostram (`RewardDeck.draw_prefer`): bifurcações com dois grupos 77,8%
  para 93,9% em 1000 grafos, três grupos 3,8% para 9,4% (`tools/door_forks.gd`). Encanto no máximo 2 num caminho
  (`StageDef.enchant_max`), o segundo desde a sala 5 (`enchant_second_from`); Salmo desde a 4 (`psalm_from_depth`);
  `RunMap.settle(portas, romã, salmo, encanto)` troca por Bênção o que não pode vir. Caminhos com menos de 3 portas de
  Bênção 9,7% para 10,4%; encontros de dois 30% das salas de Bênção.
- **Anjo na porta (Q-RJ5 a)**: sala de Bênção é encontro de dois (`Room.meeting`: a sala 1, o guardião e 2 de cada 6,
  `StageDef.angel_deck`, dado próprio `RunMap.ANGEL_SALT`) ou mostra um anjo (`Room.angel`, sorteado ao abrir as portas
  por `Encounters.door_angel`); a placa diz o nome ou "Dois anjos"; o encontro abre direto nas cartas dele
  (`fallback` "door").
- **Encantos** (`EnchantDef`, `Enchants`, `data/enchants/`, parte `enchants`): Lâmina Tríplice (o giro solta 3 ondas
  em leque, `blow_wave_fan`, `Psalms.fan`), Eco da Verdade (o giro golpeia de novo 0,3 s depois com metade,
  `Combat._echo`, tag `echo`), Retorno do Corte (1 s depois do Corte Veloz o golpe alcança e abre 30% mais,
  `return_time`, `return_reach`, `Combat.swing_shape(..., largura)`); exclusões com os Dons (`excludes`); `BoonState.enchants`
  somados no `stat`; `Game.open_enchant_choice`, `take_enchant`, `enchant_offers` (dado da sala, `ENCHANT_SALT`), sinal
  `enchant_offered` (sem ninguém ouvindo, a `EnchantChoice` provisória); loja: Encanto 200 no grupo da Magia e da romã.
- **Porta de Salmo**: `Game.open_psalm_choice` (três Bênçãos, a primeira carta um Salmo elegível). O mapa nunca promete
  um Salmo que não vem: a carta de Salmo do baralho cai no mapa como Bênção (`Room.psalm`, nunca encontro de dois, desde
  a sala 4) e a porta só vira de Salmo ao abrir, quando um pode vir (`RunMap.settle(..., can_psalm)`, padrão `false`);
  antes o mapa mostrava o Salmo e a porta trocava por Bênção (o robô sem Dons nunca tinha um elegível). `--start=shop`
  é a loja antes de Morvath, nunca a de rota.
- **Forja**: Temperar III (60 Prata, +5% em `light` e `heavy`); Refinar (`Forge.REFINE`, 25 Prata, uma escolha por ação:
  Fio `reach_pct`, Peso `stun_pct` (novo: `Horde.stun_scale`), Pressa `blow_speed` (novo: `GiftState.attack_speed(tags)`)
  no ataque; Onda Larga, Onda Pesada, Onda Pronta no especial), aberto pela ferramenta `tool_refine` achada no primeiro
  guardião vencido (`Game.find_tool`, `tools_found`, guardada no fim como os materiais); `Forge.ranks_for(data)`,
  `--refine=a,b`. Save: `forge.refine`, `refined`, `inscribed` (`HERO_LISTS`).
- **Esmeralda**: 1 na fase 3 de Morvath alcançada, 1 na vitória (`MaterialPurse.SOURCES[EMERALD]` = `boss`).
- **Bênçãos novas** (todas sem ação, `Slot.NONE`, só estatísticas que existem; entram nas listas dos Elos): Geada Final,
  Flocos Errantes, Ômega de Gelo; Vigia Firme, Vigília Longa, Guarda Atenta; Ômega em Brasa, Chuva de Brasas; Final
  Radiante, Onda Clara (9 por família).
- **DV-2, loja de rota (MAP-09, Q-26 b)**: num ramo de uma camada de 6 a 8 (`StageDef.route_shop_*`, 35% por camada
  onde cabe, nunca na camada da fonte nem do altar, só em camada de 2 salas ou mais), 3 itens, um de cada grupo da
  loja (`Rooms._build_shop`, `RunMap.is_route_shop`); loja não gasta usos de arena (`_place_arenas`). `RESULT`
  `route_shop` à parte do `shop` (`RoomTally.shop_entered(ouro, rota)`). Robô entra com 100 de ouro ou mais
  (`Rooms.BOT_ROUTE_SHOP_GOLD`, `bot_door(..., ouro)`). Em 300 grafos, 45% têm a loja de rota.
- `RESULT`: `enchants`, `tools`, `forge.refine`, `route_shop`, `materials` com `emerald`.
- **Medido (72 sementes, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`)**: Encantos escolhidos 28 / 36 / 36%
  (Lâmina Tríplice, Eco, Retorno; meta 20 a 45%); 384 encontros, nenhum com menos de 3 cartas (meta: 95% com 3);
  171 de 384 pela porta de um anjo; ferramenta em 69 de 72; Esmeralda 2 em 47, 1 em 9. Porta de Salmo: o robô nunca a
  viu (a mão dele quase nunca abre um Salmo: `settle` a troca por Bênção). Robô 47 de 72 vitórias, vida em Morvath
  mediana 30 (Q-15: 58 e 51,5); a mesma queda aparece sem as portas da Fatia 2 (16 de 24, vida 30) e sem as Bênçãos
  novas (13 de 24): vem de o robô levar 0,3 coração por descida (0,61 no Q-15), RJ-3 põe Bênção ao lado de corpo e ele
  escolhe a Bênção. Para o `balance-designer` (`balance.md`). Loja de rota: o robô passa com 50 de ouro ou mais
  em 29% (sala 6), 62% (7) e 86% (8) das descidas, entra só com 100 (ou 50 ferido): 5 visitas em 72.

## Rejogabilidade, Fatia 3 "o fim de jogo" (gameplay; spec `sistemas.md` 1.5, 1.7 e 3.6; nomes de trabalho; testes em `tests/test_fatia3.gd`)
- **Ferramentas 2 e 3**: `Forge.TOOL_AWAKEN` na primeira fase 3 de Morvath alcançada (`Rooms.boss_phase`) e
  `TOOL_INSCRIBE` na primeira Provação vencida (`Rooms._fight_won`), guardadas como a primeira (`Game.find_tool`).
- **Despertar** (trilha `Forge.AWAKEN`, Esmeralda, um desperto por vez: `forge.awake`, `put_on`, `take_off(data,
  Forge.AWAKEN)`, lista `forge.awakened`): Sede (0,5 de vida por abate, 2), Ímpeto (3 de Magia a mais por finalizador,
  3), Eco Longo (o finalizador golpeia de novo 0,25 s depois com um terço, 4). Levado na descida pelo `ranks_for`;
  `--awaken=id`. **Inscrever** (trilha `Forge.INSCRIBE`, 20 Prata, o id do posto é o do Encanto, guardado em
  `forge.inscribed`, lido pelo `Enchants.learned`): os Encantos 4 a 6 (`EnchantDef.learned` falso; `INSCRIBED` no
  `make_data.gd`): Corte Sísmico (o giro solta um pulso de 4,5 m de 25, `ground_pulse`, `Combat._ground_pulse`, tag
  `pulse`), Onda Gêmea (o especial solta duas ondas de 15 em leque, `blow_wave_side` tira a do meio; nunca com a Onda
  Carregada), Eco do Passo (o Corte Veloz ecoa a metade em 0,3 s; nunca com o Retorno do Corte). `--inscribed=a,b`.
- **Discernimento** (`Discern`, `core/discern.gd`; `heroes.<id>.discern`, Memória 8 e 12, em ordem): I, uma vez por
  descida a escolha de Bênçãos na tela é sorteada de novo (`Game.can_reroll`, `reroll_choice`, `rerolls_left`, sinal
  `rerolled`; com anjo escolhido, as cartas da família dele por outro dado, `Encounters.reroll_cards`; nunca na porta de
  Salmo nem na romã); II, o anjo das salas de Bênção uma camada mais adiante no mapa (`Rooms._preview_angels`, somado à
  Obra da prévia). `--discern=N`. O botão na tela e a compra no Livro são do ui-ux-designer.
- **Obras e troca no Vendedor** (`Vendor`, `core/vendor.gd`; `ObraDef` em `data/obras/`, parte `obras`): abertas com a
  primeira encomenda entregue; Altar Restaurado (`altar_chance` 0,35, 40 Prata e 4 Memória), Fonte Viva
  (`fountain_heal` 0,55, 30 e 3), Banca da Rota (`route_shop_items` 4, 50 Prata e 1 Esmeralda), números do `StageDef`
  postos por cima no `Rooms.setup` (`Vendor.stage_for`); guardadas nas `oficios.recipes`; `--oficios=obra_x`. Troca com
  perda (`OficiosDef.trades`: 10 Prata por 1 Memória, 2 Memória por 5 Prata, 40 Prata por 1 Esmeralda; `Vendor.trade`).
  A folha do Vendedor é do ui-ux-designer.
- **Esmeralda por recorde de Peso**: vitória acima do melhor Peso dá 1 por degrau de 5 cruzado
  (`Juramentos.record_emeralds`, até 6), fonte `juramentos` do `MaterialPurse` (`RunAward.keep`).
- **Aba Anjos** (`AngelCodex`, `core/angel_codex.gd`; seção `codex.angels`: `met`, `chosen`, `blessed`, guardada pelo
  `RunAward.codex`; `entries`, `count`); a página é do ui-ux-designer (textos `codex_tab_angels`, `codex_angel_*`).
- RJ-11 (a Memória como as Cinzas) já está coberta pela Fatia 1 (a Memória abre os Dons).
- `RESULT`: `forge` com `awaken`, `discern`, `rerolls_used`; `materials.emerald.juramentos`; `tools` com as três.

## Ofícios, Roteiro A, "A Primeira Picareta" (gameplay; `docs/design/oficios/15_prototipo.md`, decisões Q-OF1 a Q-OF4 e Q-OF6 a; testes em `tests/test_oficios.gd` e `tests/test_oficios_game.gd`)
- **OF-05**: porta de Prata só da profundidade 4 (`StageDef.silver_from_depth`) e de Memória só depois da camada do
  guardião (`memory_after_guardian`), filtradas no `RunMap._may` como a romã; dado em `_oficios_stage` do `make_data.gd`.
- **Números** num recurso só (`OficiosDef`, `data/oficios/oficios.tres`, parte `oficios`): Picareta restaurada por 20 de
  Prata, Pedra Funda com teto 10, veios nas Fendas e nas Runas depois do guardião (no máximo 2 por descida, um aperto e
  `vein_hold` 1 s parado nele), sala da cabeça entre as profundidades 4 e 8, piedade depois de 2 descidas, encomenda do
  Vendedor de 2 Pedra Funda e 30 de Prata que faz a Obra 1 (`angel_preview`). Nomes de trabalho (Q-OF5).
- **Regras puras** em `Oficios` (`core/oficios.gd`) sobre o bloco `oficios` do save (versão 8: `items`, `items_total`,
  `finds`, `tools`, `orders`, `recipes`, `pity`, `seen`; saves 1 a 7 abrem com o bloco vazio, fixtures `save_v6.json` e
  `save_v7.json`): `noted`, `head_wanted`, `pity_due`, `add_item` (teto), `restore`/`restore_problem`, `order_state`
  (LOCKED até a primeira Pedra Funda, OPEN, DONE), `order_missing`, `deliver` (uma vez), `bank` (no fim da descida, pelo
  `RunAward.keep`, junto dos materiais e nas mesmas condições). A parte da descida é `OficiosRun` (`game.oficios`: do save,
  ou `--oficios=noted,pity,pick,preview` também para o robô; nada para o robô sem a opção, então o `RESULT` dele é o de antes).
- **Mapa**: `RunMap.mark_finds` (dado próprio, `FIND_SALT`, depois do grafo: o mapa e a partida não mudam) marca
  `Room.vein` (luta depois do guardião numa arena de `vein_arenas`) e, quando a cabeça é pedida (veio anotado, sem a
  cabeça nem a Picareta), `Room.find` numa sala de luta sem Provação; `view()` traz `find` e `vein`, o `summary()` traz
  `"find"`. **Falta a marca no mapa (ui-ux-designer)**: um losango só no nó com `find`.
- **Sala** (`Rooms`): vencida a sala marcada, a cabeça é achada ("Achado: Cabeça da Picareta", evento `find`); o
  guardião vencido a entrega por piedade (`head_by` "pity"). O veio (`VeinFloor`, `game/vein_floor.gd`, **placeholder**:
  bloco escuro com fio cinza, três estados, sem colisão; a peça é do environment-artist) aparece no
  `RoomLayout.gather_spots[0]` (Fendas (3,5; 7), Runas (0,5; -10), lugares provisórios para o room-designer) quando a sala é
  vencida: sem a Picareta, `use_kind` `vein_note` ("Anotar") e o aperto anota ("Anotado no Livro de Ahk"; só para gente);
  com ela, `vein` ("Extrair"): um aperto e 1 s parado nele (sair dele esquece) dá 1 Pedra Funda, até 2 por descida
  (`gather_s` conta o tempo). Robô com a Picareta vai ao veio antes da recompensa e das portas (`Rooms.bot_goal`).
- **Obra 1, Prévia dos anjos**: ao abrir as portas, as salas de Bênção (um anjo) atrás delas já ganham o anjo
  (`Rooms._preview_angels`, `Encounters.door_angel`) e a porta o guarda quando abrir (a promessa do mapa).
- **Santuário** (folhas mínimas no `HubPanel`, `Hub._use_smith`, `_use_vendor`, sinal `Hub.oficio_done`): com o veio
  anotado o Forjador pede a cabeça e 20 de Prata ("Onde achar: numa sala marcada no mapa") e restaura; o Vendedor fica
  fechado até a primeira Pedra Funda, depois mostra a encomenda e entrega; a placa diz "Tem um pedido"
  (`Hub.station_line`). **Para o ui-ux-designer**: aba Oficina na Forja, folha da encomenda com marcas e números, Bolsa e
  Trazidos com a Pedra Funda, saudação "Achado", placa do veio com "Pede: Picareta", capítulo Ofícios no Livro.
- `RESULT` e registro (`RunLog.VERSION` 6): `oficios` (`finds`, `find_by`, `marked`, `gather`: `veins`, `stones`,
  `gather_s`, `noted`; `pity`: `due`, `passed_guardian`).

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

## Rejogabilidade, Fatia 3, interface (ui-ux-designer; testes em `tests/test_fatia3_ui.gd`, capturas em `docs/gallery/fatia3_ui/`, `tools/fatia3_lab.gd`)
- **Forja**: terceiro marcador "Despertar" (`ForgeScreen.Tab.ARTS`, `arts_open()`: aparece com qualquer ferramenta do
  Forjador achada; ordem dos marcadores em `_tab_order`, LB e RB andam nela) com duas colunas, Despertar (Esmeralda) e
  Inscrever (Prata), cada uma com o estado da ferramenta; a marca do preço é a do material do posto (`Mark.paid_in`,
  `MaterialCount.set_id`). Despertar: forjado e dormindo diz "Despertar" (`put_on`, grátis), desperto "Adormecer"
  (`take_off`); Inscrever: "Inscrever" e depois "Inscrito"; sem a ferramenta, o `forge_no_<ferramenta>`.
- **Sortear de novo** na escolha de Bênçãos (Discernimento I): com `Game.can_reroll()` a `BoonChoice` põe
  "Sortear de novo (N)" na `ActionBar` (`reroll_item`, `reroll()` chama `Game.reroll_choice`); ação de menu
  `menu_reroll` em `Controls.MENU_KEYS` (Y no controle, R no teclado, só nos menus).
- **Discernimento** no capítulo Ofícios do Livro: um botão por grau (`HeroScreen.discern_buttons`), dois apertos como
  abrir um Dom ("Confirmar: N de Memória"), `Discern.buy` e grava; o II diz que pede o I.
- **Banca do Vendedor** (`VendorScreen`, `scripts/ui/vendor_screen.gd`): aberta pelo Vendedor depois da encomenda
  entregue (`Hub._use_vendor`); à esquerda as Obras (custo com marcas, o que falta em rubrica, Erguer, "Erguida"), à
  direita as trocas (Dá, seta, Recebe, Trocar) e o Saldo; sinais `built`, `traded`.
- **Compêndio**: aba Anjos (`CodexScreen.Tab.ANGELS`, nona, antes de Golpes; `AngelCodex`): selo aceso, nome na cor
  do anjo, frase e vezes encontrado, escolhido e Bênçãos levadas; nunca encontrado, selo apagado e "???".
- **Esboço a tinta no Compêndio** (AP-4, peça do technical-artist): o `FigureView` chama `FigureSketch.apply(renderer,
  def, Book.INK, altura da vista)` depois do `register` nos inimigos já derrotados (passar de conhecido para não conhecido refaz a
  figura); os nunca derrotados seguem em silhueta. Com nove abas, as entradas do índice ficam com `TAB_HEIGHT` 34 e
  margem vertical de 1 px, para a figura caber embaixo a 720.

## Rejogabilidade, Fatia 1, interface (ui-ux-designer; capturas em `docs/gallery/rj1/ui/`, testes em `tests/test_rj1_ui.gd`)
- **Marcas dos materiais**: `DoorGlyph.Kind.SILVER` (lingote de prata) e `MEMORY` (folha rasgada com três linhas de tinta),
  `DoorGlyph.of_reward` para `RunMap.Reward.SILVER`/`MEMORY` (placas das portas e mapa) e `DoorGlyph.of_material(id)`;
  `DoorGlyph.material(ci, kind, centro, altura)` desenha a marca em qualquer canvas. `MaterialCount`
  (`scripts/ui/material_count.gd`): marca e número no `UiKit.number_font` (nunca Cinzel), `named` acrescenta "Prata",
  `plus` escreve "+3"; `MaterialCount.purse(data)` é a Bolsa (Prata e Memória lado a lado) e `refresh(row, data)`. A
  legenda do mapa (`MapScreen.legend_kinds`) só mostra os tipos que a descida tem (Prata e Memória entram quando há).
- **Forja da Emeth** (`ForgeScreen`, `scripts/ui/forge_screen.gd`, aberta pelo Forjador em `Hub._open_forge` pelo `ScreenHost`):
  `BookSpread` de duas páginas. Esquerda: título, uma linha do que a Forja faz, "Temperar" com uma entrada por posto
  (`Book.index_entry`, marca de Prata e o custo, "Forjado" quando já tem) e a Bolsa no pé. Direita: o posto em foco com
  Efeito, Custo (`MaterialCount` com o nome), Estado e Próximo passo (pelo `Forge.problem`: pronto, falta Prata com quanto,
  pede o anterior, forjado), Forjar (ação principal, só habilitado e focável quando pode) e Voltar. Mover o foco só mostra;
  Enter numa entrada leva ao Forjar; comprar gasta (`Forge.buy`), grava (`Save.write`, só nos dados do jogo), emite
  `forged` e passa ao próximo posto. `forge_done` sem "nesta versão".
- **Abrir Dom com Memória** (`HeroScreen`, `TalentNode`): o Dom revelado e não aberto (`HeroLoadout.State.SEALED`) mostra o
  glifo a meia força e, embaixo, a folha da Memória com o preço (`TalentNode.SEALED_GLYPH`, `MEMORY_MARK`, `MEMORY_SIZE`) no
  lugar dos losangos de Devoção. O painel diz "Abrir: N de Memória" no Custo, "Revelado pela Maestria, ainda fechado" no
  Estado e o próximo passo; a dica do rodapé troca para abrir. O primeiro aperto pergunta na própria página ("Abrir por N
  de Memória? Aperte de novo para confirmar. Não há volta.", em rubrica; `HeroScreen.arming`), o segundo em até
  `CONFIRM_TIME` 3 s abre (`HeroLoadout.open`, grava) e não equipa; mudar o foco ou o tempo esquece; sem Memória o nó
  recusa e diz quanto falta. A Bolsa fica no alto da página direita, ao lado da Devoção.
- **Encontro** (`EncounterScreen`, `scripts/ui/encounter_screen.gd`): na língua da `BoonChoice` (título Cinzel sobre a
  partida escurecida, dica embaixo), um cartão de tinta por anjo (`EncounterScreen.AngelCard`, 300 x 392): selo grande
  (`AngelSeal`), nome, "Bênçãos de {família}", filete, a linha do anjo e quantas Bênçãos da família o herói leva (o fato
  que decide a escolha); foco no primeiro. `EncounterScreen.attach(game)` (o `Hud` liga no `game.ready`) ouve
  `Encounters.opened`; escolher fecha, chama `encounters.choose` e a `BoonChoice` ganha o selo pequeno e "Trazidas por
  {nome}" no alto (`BoonChoice.by_angel(anjo, voltar)`); Esc ou B ali volta ao mesmo par, com o foco no anjo visto, e as
  cartas são as mesmas (`Encounters.cards_of`). Cores dos selos (`AngelSeal.TINT`) longe do vermelho do perigo, do
  esmeralda da Emeth e do petróleo do herói: Chama âmbar terroso (matiz 24), Vigília sálvia (matiz 88; era petróleo, 177);
  testado com 20 graus de folga.
- **Trazidos e Bolsa**: a tela de fim mostra "Trazidos" sob as Bênçãos levadas (`EndScreen._brought`: `stats.materials`,
  senão `game.materials_banked`, e sem save o que a descida achou; nada quando nada veio). O hub tem a Bolsa no canto
  de cima à direita sobre um véu de tinta (`HubLabels.purse`, `PURSE_MARGIN`), escondida com tela aberta.
- **Saudação de material** (`EloBanner.show_material`, na fila das outras, 1,8 s, `MATERIAL_TIME`): "+10 Prata" com a marca;
  mais do mesmo enquanto aparece ou espera soma. O `Hud._greet_materials` lê `game.materials.found` a cada quadro e saúda
  tudo menos o abate de elite (fica só a palavra do `Rooms.found` onde ele caiu). Respeita o `keep_out` das placas como
  as outras saudações.
- Texto da Maestria: o nível revela, a Memória abre: "Dom revelado: X" / "Dons revelados: X, Y" no fim
  (`MasteryReport.unlocks`) e "O nível N revela: ..." no Livro (`hero_next`).
- P2 da revisão d2ff05d fechados depois: Juramentos sem caixa por linha, fio entre linhas, foco numa faixa com a linha de
  ouro, "Peso N" à direita só ligado (`JuramentoScreen._thread`); Músicas com cabeçalhos `UiKit.section` e o Ouvir só
  inteiro na linha em foco, sob o ponteiro ou tocando (`MusicRoomScreen.QUIET_LISTEN` 0,3; a largura ficou a de antes,
  1160: com as duas colunas numa de 780 a lista não cabe em 720); Compêndio, Inimigos e Dons com linhas de 34 px
  (`CodexScreen.LIST_ROW`), a marca do papel do inimigo a tinta (`RoleMark`, `scripts/ui/role_mark.gd`) e a contagem
  "64 derrotados · 5 de elite" em `FADED` no `number_font`; menu do Santuário numa folha do Livro (`PauseMenu` com
  `hub`: `BookSpread` única, botões de papel); foco das cartas (Bênção, Provação, Altar, Encontro) em cantoneiras marfim
  por dentro da linha de metal, nunca uma linha inteira (`BoonCard.draw_focus`, `FOCUS_ARM`; a Comum em foco ganha um
  brilho marfim, as outras ficam com o brilho da raridade); os cabeçalhos em versal das cartas de evento ficam em 13
  px (`BoonCard.HEAD_SIZE`: a 14 o da maldição quebra em duas linhas na faixa). Testes no fim de `tests/test_ui_review.gd`.
- Capturas: `--hub --hero-at=smith --hub-use=smith --materials=silver:30,memory:5` (Forja), `--title --screen=gifts
  --hero-xp=160 --hero-opened=quarto_corte --materials=...` (`--hero-opened` só abre esses, os outros revelados ficam
  selados; `Save._dev_hero`), `tools/book_lab.gd` (`gifts_sealed`, `_ask`, `_short`), `tools/ui_lab.gd -- --meeting` e
  `--found`, `tools/menu_lab.gd` (fim com Trazidos), `--hub --hero-at=vendor --materials=...` (Bolsa do hub).

## Revisão de layout da interface (d2ff05d; `docs/gallery/ui_review_d2ff05d/REVIEW.md`, depois em `after/`)
- **Números nunca em Cinzel** (P0-1: o 1 da Cinzel lia como I romano, "SALA I DE II"): sala, relógio, ouro, contador de
  golpes e todo aviso com algarismo em `UiKit.number_font()` (`UiKit.has_digit`); teste em `tests/test_ui_review.gd`.
- Relógio e contador de golpes sobre um véu de tinta de cantos cortados (`HudVeil`, `scripts/ui/hud_veil.gd`: cobre só o
  texto dos rótulos pelo alinhamento, some sem eles); com a barra de um chefe ou guardião o relógio vai para o canto de
  cima à direita, sob o ouro, e o nome do chefe fica sozinho sobre a barra (`Hud._place_clock`, `CLOCK_BOSS_Y`,
  `BOSS_TOP_ALONE`). Na pausa o medalhão e as barras somem sob o painel (P2-7).
- Ouro que cai soma como o dano (`Fx.gold(pos, n)`, `GOLD_SIZE` 15, `GOLD_WORD` ouro velho claro, junta em
  `NumberTally.MERGE_TIME` e `GOLD_JOIN` 6 m: "+3 ouro", nunca "+1 ouro+1 ouro"); o `Rooms` chama `fx.gold`.
- Saudações e placas não se tocam: enquanto o `EloBanner` mostra algo ele marca a faixa dele em `DoorSign.keep_out`
  (`EloBanner.band`) e a placa que cruzaria desce para baixo dela (`DoorSign.KEEP_GAP`).
- **Livro**: botões do papel `Book.button` (tinta sobre papel mais escuro, fio `GILT`, foco fio rubrica e losango à
  esquerda) e `Book.primary` (papel tostado, letras rubrica) na folha do Portal e do Vendedor (`HubPanel`), no Livro, no
  Compêndio e no Mapa; cartas de ultimate no papel com o estado escrito (`UltCard`: Escolhida, Pode escolher, Destrava
  na Maestria N). Capítulos como marcadores de couro saindo da capa (`Book.mark`, `Book.mark_open`: o aberto mais longo
  e com a fita petróleo; `HeroScreen.OUTER` 12 px do topo). Rodapé numa fileira só à direita: Dons (no capítulo O
  Guerreiro), Compêndio, Voltar (`HeroScreen.FOOT_WIDTH`). **Aberto no hub não tem "Descer às catacumbas"**
  (`HeroScreen.open(data, chapter, true)`, `in_hub`; só o Portal desce); no título continua. Folha única com a fita no
  meio (P2-6). Barras de rolagem com tema (`UiKit.scroll_bar`: trilho de 2 px, pegador em losango alongado; no
  `UiKit.theme()` em ouro velho e no `Book.theme()` no ouro do papel) e o pé da lista esmaece quando há mais
  (`UiKit.scroll_fade`, `ScrollFade`, `FADE_HEIGHT` 24, filho interno do `ScrollContainer`) no Compêndio e em Suas
  Bênçãos.
- **Santuário**: placa da estação com o verbo dela no lugar de "Interagir" (`StationSign.verb`, chaves `hub_use_<id>`:
  Descer, Olhar, Ver os Dons, Forjar, Ler); a linha do meio diz o que a estação é ("O caminho para as catacumbas").
  Vendedor sem texto de protótipo: "Balcão fechado" e "Não há nada à venda no balcão." (`hub_soon`, `hub_vendor_soon`).
  Nome do lugar por 2 s ao chegar e um nome fraco sobre cada estação na tela, menos a que está em foco
  (`HubLabels`, `scripts/ui/hub_labels.gd`, posto pelo `Hub._ready`).
- **Fins de partida**: os dois com os caminhos no mesmo lugar ("Voltar ao {HUB}" à esquerda, "Descer de novo" à direita;
  o destaque muda: vitória o hub, derrota a descida; `EndScreen._ways`), HUD escondido nos dois (`_hide_hud`), números
  numa fileira só de células (nome em cima, número embaixo; `STAT_CELL`) e medalhões sem os pontos de nível (P2-12,
  `UiKit.gift_icons(..., levels)`).
- **Configurações**: um controle só para toda opção (`OptionsScreen._setting`): linha-botão com o nome à esquerda e o
  valor entre duas divisas de ouro velho desenhadas (`OptionsScreen.Chevron`, `opt_<id>_-1`/`_1`, sem foco), Cinzel no
  valor sem algarismo e `number_font` com; esquerda e direita mudam, Enter, A ou clique avançam (o interruptor vira
  "Sim"/"Não"); "Janela" apagada e pulada pelo foco com a tela cheia ligada; embaixo da página a linha do que a opção em
  foco faz (`opt_<id>_tip`, `OptionsScreen.tip_text`).
- P2 feitos: ícone de Sair do título é uma porta em arco aberta (`TitleButton._draw_door`, nada de símbolo de energia);
  estado da porta no Mapa em tinta e curto ("Uma porta desta sala leva até aqui."). Ficaram: P2-2 (Juramentos e
  Músicas), P2-3 e P2-4 (Controles), P2-5 (Compêndio), P2-8, P2-10, P2-11 (asset), resto do P2-12; enquadramento do
  Portal pela câmera (P1-8, gameplay).

## Lote A, frente A5, interface (backlog "Estado e ordem de 2026-11-20"; testes em `tests/test_lote_a_ui.gd`, capturas em `docs/gallery/lote_a_ui/`)
- **Estilo visual (DT-RS2)**: Configurações > Vídeo, "Estilo visual" Estilizado ou Clássico (`opt_look*`), pelo
  `OptionsScreen.apply_look(tree, look)`: `Save.choose_look` (aplica e grava a chave `look`) e `Arena.restyle()` de toda arena na árvore, o mesmo
  quadro do F7, gravado na chave `look` por `Save.choose_look`.
  Capturas: `--title --screen=options --options-tab=video|comfort|controls [--options-focus=opt_look]`.
- **Controle (resto do DT-103)**: `ui_accept`/`ui_cancel` ganham A e B do controle (`Controls.MENU_BUTTONS`; antes os
  menus não aceitavam o A). Remapear no controle: nos Controles, escolhida uma ação, um botão do controle a liga
  (`Controls.rebind_pad`, `PAD_REMAPPABLE`: ataque, especial, esquiva, círculo, ultimate, mapa, usar; troca com quem tinha
  o botão; o andar fica no analógico), gravado em `bindings` como `pad:<ação>` (`pad_button_for`), Start cancela, Teclas
  padrão volta tudo. O botão aparece numa plaqueta (`StationSign.KeyCap`, redonda nos botões de face) e uma linha embaixo
  diz que botão também liga (`options_pad_note`). Como Jogar com as teclas e botões em plaquetas (`HowToScreen.Plates`,
  `key_parts`, `pad_parts`; P2-3). `tools/title_flow_check.gd` faz uma volta só de controle (Como Jogar, Configurações,
  remapear o Ataque para Y, Teclas padrão) e uma só de clique (Como Jogar, Configurações, Estilo visual ida e volta).
- **Mapa (MAP-07, MAP-08)**: com o foco numa sala atrás de uma porta aberta, a porta acende na sala com o facho das
  recompensas na cor da recompensa (`MapScreen._light_door`, `RewardShaft` "MapDoorLight" sobre o `arena.door_label(i)`;
  outra sala apaga, `lit_door()`); ao fechar ela fica acesa `DOOR_LINGER` 4 s e o HUD aponta a porta na borda da tela
  quando ela está fora (`Hud.point_door(onde, nome, s)`, divisa com o nome, some nos últimos `DOOR_FADE` 0,6 s,
  `clear_door`). A página vira ao abrir (0,22 s em volta da lombada) e ao fechar (0,16 s, numa camada que não toma entrada;
  o `closed` sai na hora) e, a primeira vez que o mapa abre numa sala, o trecho novo do caminho se desenha a tinta
  (`MapGraph.ink`, `draw_in`); sem animação sem tela (`MapScreen.turns`). `tools/map_flow_check.gd` confere a luz.
- **Entrada de Morvath (AP-2, ART-05.5)**: quando ele surge, embaixo da barra dele, num véu, "A Câmara do Selo", "Morvath"
  em Cinzel e "O rei que traiu a luz" (o `enemy_morvath` cortado na vírgula) por `Hud.ENTRANCE_TIME` 2,3 s, entrando em
  0,3 e saindo em 0,45 (`Hud.show_entrance`, `entrance_shown`); um `show_notice` do nome da câmara vai para lá.
- **Vitória (QW-115)**: o halo do selo é um degradê radial de ouro velho até nada (`SealEmblem.halo_texture`, `HALO`
  0,42, `HALO_REACH` 1,55; os discos de antes liam como disco amarelo), o leão acende em `EndScreen.LION_GLOW` 0,6 s e o
  título e a frase da selagem ficam sobre um véu escuro em elipse (`words_veil`, `WORDS_VEIL` 0,72). O ouro que cai sobe
  ao lado do número do golpe e menor (`Fx.GOLD_SIDE` 1,1 m para a direita da tela, `GOLD_SIZE` 14).
- **Glifos sem cruz (QW-117, `BoonIcon.glyph`)**: lâmina de gelo (5) é um caco facetado sem travessa; escudo da Vigília
  (9, 15) com divisa e losango no lugar da estrela de quatro pontas; Corte do Juízo (110) é uma lâmina sem guarda descendo
  de lado na fenda.
- **Barras dos comuns (ART-02.6)**: no `life_bar.gdshader` a barra de quem não é elite nem tem armadura tem a vida
  `common_dim` 0,85 mais escura e é `common_cut` 25% mais fina, cortada de baixo (o topo não muda); elites iguais.
- P2-12: número do selo da Provação em 14 px (`TrialSeal.NUMBER_SIZE`). P2-4, P2-5, P2-8 e P2-10 já estavam feitos.
- **HV-D, interface do Santuário da Vigília** (`docs/art/hv_santuario_vigilia_art.md` 6.3): a placa da estação em foco
  pendura no pé do que se usa, nunca flutuando sobre ele (`Hub._show_focus`: a âncora do `HubPlan` levada ao chão e
  `StationSign.under`), e fora do herói (`place_under` com o y arredondado para cima). Os nomes fracos das estações
  (`HubLabels`) nunca sobre o herói nem sobre a Bolsa. O Alquimista não é estação: sem placa, nome nem foco.
- **Ofícios, marca da Pedra Funda**: `DoorGlyph.Kind.STONE` (bloco de ardósia quebrado com dois estratos pálidos),
  `DoorGlyph.of_material(&"pedra_funda")` (`STONE_ID`, o `OficiosDef.stone`), pronta para a Bolsa, Trazidos e a saudação.

## Ofícios, Roteiro A, interface (ui-ux-designer; `docs/design/oficios/10_ux.md`; testes em `tests/test_oficios_ui.gd`)
- **Mapa**: `DescentMap.Room.find` e `vein` (lidos do `view()`); o nó com `find` ganha um losango de ouro velho de 6 px no
  alto à direita do medalhão (`MapGraph.find_diamond`, `FIND`) e a legenda "Achado" só quando há; a página da sala diz
  "Guarda um achado: Cabeça da Picareta" e "Um veio de Pedra Funda" (`DescentMap.find_name`); depois de achada, o
  `from_game` tira o losango. `MapSample` tem o achado no nó 14 e o veio no 12.
- **Placa do veio**: `StationSign.tool_line` põe sob a tecla "Pede: Picareta" no rosa do que falta (`vein_note`) ou "Com
  a Picareta" (`vein`); `dim_verb()` apaga o verbo (para o `Rooms.prompt` quando o veio já foi anotado).
- **Bolsa e Trazidos**: `MaterialCount` aceita a Pedra Funda (`name_of`, `short_of`, `amount_of` pelo `Oficios.count`); a
  Bolsa a mostra depois da primeira (`shown`, `items_total`); a tela de fim traz as pedras e o achado da descida
  (`stats.oficios`, senão `game.oficios`; `PickMark` com o nome).
- **Saudação** (`EloBanner.show_find`: "Achado", a cabeça desenhada e "Leve ao Forjador no {HUB}"; `show_noted`: "Veio de
  Pedra Funda", "Anotado no Livro de Ahk" e "Pede: Picareta"), pedidas pelo `Hud._greet_oficios` lendo o `game.oficios`
  (também cada Pedra Funda extraída, saudação de material); os `show_notice` do `rooms.gd` com esses textos são
  engolidos (`Hud.oficio_notice`).
- **Picareta desenhada** (`PickMark`, `scripts/ui/pick_mark.gd`: perdida em contorno, só a cabeça com o cabo partido,
  inteira; no papel ou sobre a partida).
- **Forja com a Oficina** (`ForgeScreen.Tab`): depois de anotado um veio, dois marcadores de couro sobre a capa, Emeth e
  Oficina (LB e RB); a Oficina mostra a Picareta grande na página esquerda e, à direita, o índice das ferramentas com os
  mesmos Efeito, Estado, Próximo passo, custo, "Cabeça da Picareta: aqui/perdida" e Restaurar (`restore()`, sinal
  `restored`). O Forjador abre a Forja direto na Oficina enquanto a Picareta espera (`Hub._open_forge`).
- **Encomenda do Vendedor** (`OficioSheets.order`, na folha do `HubPanel`, que ganhou `body` e escolhas apagadas
  `[id, texto, false]`): marca da Pedra Funda, uma fala, "◆ PEDE" com marca, nome e "1 de 2" (falta em rubrica, visto em
  tinta), "◆ ONDE ACHAR", "◆ DÁ" e Entregar só aceso com tudo.
- **Livro, capítulo Ofícios** (`HeroScreen.Chapter.OFICIOS`, quarto marcador): Recursos (Pedra Funda "N de 10" e onde
  achar, ou "???" com a pista), Ferramentas (a Picareta no estado dela), Pedidos (Forjador, Vendedor) e Obras (Prévia dos
  anjos), em voz neutra.

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

## Quebráveis (AT-Q1, Lote D; arte em `docs/art/at_q0_breakables.md`, cadência em `docs/design/combat_cadence.md` 9.6; testes em `tests/test_breakables.gd`)
- Dado: `RoomLayout.breakables` e `ArenaVariant.breakables` (`BreakablePiece`, `core/breakable_piece.gd`: `form` vaso,
  urna, oferenda, vaso de água, caixote, tábua, banco, galho, muda; `at`, `radius` até `Breakables.MAX_RADIUS` 0,45,
  `height` 0,35 a 1,0, `group`), postos pelo `_place_breakables` do `make_data.gd` (parte `stage`): Salão 10 em 4 grupos
  (bordas e pé das balaustradas, longe do eixo, do medalhão, da fonte e da fileira da loja), Cripta A e B 8 em 3 grupos;
  AT-Q4 (room-designer): todas as outras salas e variantes, a Provação e o Altar, de 7 a 10 em 3 ou 4
  grupos de 2 ou 3 nos cantos e encostados (Fendas e Ponte madeira, Jardim galhos, mudas e vasos de água, Santuário
  oferendas, Runas caixas baixas e tigelas, Provação e Altar cerâmica), conferidos em `test_arenas.gd`
  (`test_breakables_stand_where_they_may`: 4 a 10 em 2 a 4 grupos de 2 a 5, cada grupo encostado, 1,5 m ou mais de
  porta, marca da porta, entrada, recompensa, nascimento, ponto de uso, guardião e toda laje ou faixa de perigo, também do
  `also`). Regras de cada sala (Atlas, coluna 3) em `tests/test_breakable_rules.gd`: nunca no tabuleiro das Fendas
  (`RiftLook.BRIDGES`) nem da Ponte (os tabuleiros do `BridgeLook`, 2,5 m ou mais da linha das pontes, no patamar da B só
  na borda), vasos de água do Jardim B a até 2 m da borda oeste úmida, nas Runas nunca tocando ladrilho que arma
  (`ArenaHazard.live`; só cabem no chão quieto da entrada, `RUNES_ENTRY`) e na B a 3 m da pedra quieta, no Santuário 4 m
  ou mais da linha entre o `boss_spawn` e a entrada e só na periferia, na loja 3 m ou mais de todo relicário com 1 a 5
  itens. **Câmara do Selo (AT-CS3)**: 8 de cerâmica no patamar da escada sul e na borda noroeste e nordeste, de 11 a
  12 m do selo, longe da câmera e além do anel do ritual; o `test_boss_exits` refeito com elas inteiras (como pedra
  sólida, mais duro que o jogo) e quebradas, e na câmara de verdade elas não param nada. Nenhum no hub. Regras puras em `Breakables` (`core/breakables.gd`): material por forma (`Stuff` CERAMIC, WATER, WOOD,
  BRANCH), um golpe e o caixote dois (o 1º racha), quebra uma vez só, por golpe do herói (`swing`, pelo `Combat.reached`,
  que só sai do golpe que saiu: golpe cortado pela esquiva não quebra), pela onda dele (`circle`, tiros não hostis), por
  golpe de inimigo e perigo de sala quando o aviso aterrissa (`reached_by`, pelo sinal novo `Ground.zone_landed`), nunca
  por andar; `tally` (`total`, `broken`, `by_hero`, `by_enemy`, `by_hazard`) vai para `rooms[].breakables` do `RESULT`
  (`RoomTally.breakables`; sala sem quebráveis igual a antes: o `smoke 600 --seed=5` dá o mesmo `RESULT` fora dessa
  chave). No jogo `BreakFloor` (`game/break_floor.gd`, criado pelo `Game.rebuild_room` debaixo da arena, passo no
  `Game._step` depois dos tiros): nada barra corpo nem tiro (não é `ArenaObstacle`, fora da `NavGrid`), a mira assistida
  nunca o escolhe (só a `Horde`), nenhum hit stop, número, combo, Magia, passiva, carga da ultimate nem câmera lenta.
  Desenho provisório para o AT-Q2: forma simples por material na cor do bioma (`BreakFloor.CLAY`, `WOOD`), achata
  `SQUASH_TIME` 0,04 s e some, cacos pelo `Fx.chips` e pó pelo `Fx.wisps` (dado do `Fx`); som por material com os sons
  que existem (`Breakables.SOUND`, um por material por golpe, pela `VoiceGate`) até os `break_*` do AT-Q3. Sonda:
  `PROBE_VASES=1` põe 6 vasos em volta do herói, inteiros de novo antes de cada caso (`BreakFloor.restore`): 41/41 com os
  mesmos quadros.

## Ciclo LC, preparação dos atiradores (LC-1 a LC-3; evidências em `docs/gallery/lc/windup/`)
- Só desenho, sem mudar tempo, alcance, dano nem duração de clipe. As luzes da preparação (`EnemyFx`) ficam onde a
  pose desenhada tem a peça: `BakedModel.point(nome, clipe, t)` (média dos vértices da peça na mistura de duas poses,
  lida uma vez por clipe), com os nomes do assado em `parts` (`crossbow`) ou em `marks` (`orb` dos cajados, `hands`,
  `hand_l`, `hand_r` do sacerdote, por `"marks"` do `tools/bake.gd`, vértices presos àqueles ossos); `Horde.render`
  passa o modelo, o clipe e o tempo para `EnemyFx.tell` e `loosed` (`EnemyFx.spot`; sem modelo cai no `tell_at`).
- **Besteiro**: besta a 0,62 com o arco claro (`CROSSBOW_PAINT`, ferro gasto `blade`); na mira (LC-1b) a besta é um ícone
  desenhado no plano da tela, apontando para onde a mira aponta na tela (nunca encurtado pela inclinação da câmera):
  coronha `CROSSBOW_STOCK` 1,0 m, os dois braços do arco `CROSSBOW_ARM` 0,62 m varridos `CROSSBOW_SWEEP` 0,3 rad e a corda
  reta entre as pontas, em traços duros (`Shape.BAR`) com tinta escura em volta (`Shape.INK`, `INK_EDGE`, `INK_ALPHA`
  0,6), cerca de 70 px a 1080 (eram 30 a 40); a ponta que brilha antes do tiro (`TIP_GLINT`) e a linha de mira que desce
  da ponta até o fio do aviso no chão, `SIGHT` 3,4 m à frente dos pés (`_stroke`): quem mira ligado a por onde o virote
  passa. Tudo por cima do próprio corpo (`enemy_tell_over.gdshader`, agora `blend_premul_alpha` com `#define PREMUL`:
  as luzes somam como antes, a tinta escurece); traços no teto da tela (`EnemyFx.lit`: `ScreenTone.fit` linear vezes
  `STROKE_ROOM` 0,9, cerca de 220 de 255).
- **Feiticeiro**: no topo do cajado um miolo que cresce de `ORB_CORE` 0,16 a `ORB_CORE_FULL` 0,42 m e anéis que se fecham
  nele (`ORB_GATHER` 1,1 m, `ORB_RINGS` 2), as centelhas entrando; nada acima do limiar do glow.
- **Sacerdote**: o rito é os dois braços abertos para cima em V (`cast` = `Cheer` do KayKit de 0 a 0,84 s em 0,8 s,
  `RITE_BEND`: o tronco e a cabeça jogados para trás), a chama sobre as mãos (`RITUAL_FLAME`, `RITUAL_LIFT`), o anel no
  chão como antes e um fio da chama ao anel na espera (`RITUAL_THREAD`). LC-3b: o V dos braços desenhado em luz da magia
  com tinta em volta, do peito (`RITUAL_NECK` 0,6 da altura) às palmas, no plano da tela e por cima do corpo; visto de
  lado ou de costas ele abre até `RITUAL_SPREAD` 0,8 m de largura e `RITUAL_RAISE` 0,45 m acima do peito, então lê igual
  de qualquer lado; a luz de cada palma (`RITUAL_PALM`) e a chama também por cima.
- Medido (LC-1b e LC-3b, RTX a 1920 x 1080, estilizado, câmera do jogo, `--stress=6 --stress-ids=archer,mage,priest
  --seed=5 --hero-at=0,0`, quadros a cada 0,1 s): besta de luz do besteiro de 35 x 18 px (a cruz fina) para 64 a 70 x 67 a
  69 px, traços em luma p50 217 a 219 (antes 228 a 241, até 255); sacerdote de costas no meio de outros
  (`--seed=7 --hero-at=0,-6`): antes só uma palma à vista, depois o V inteiro com cerca de 80 px de largura e pixels
  violeta na caixa da cabeça de 1708 para 2085; o quadro inteiro igual (luma p50 57, matiz 216 a 218). Ferramenta:
  `tools/enemy_lab.gd ... --spin` (a fileira gira, cada figura vista de um lado). Evidências em
  `docs/gallery/lc/windup/after2/` (tiras antes e depois, vídeos em velocidade real lado a lado, clássico e Compatibility).
- O que é desenhado por cima (`EnemyFx.OVER_PRIORITY` 11) sai depois das barras de vida (`CrowdRenderer.BAR_PRIORITY`
  10): na multidão as barras de quem está na frente cobriam o V do Sacerdote e a besta.
- Testes em `tests/test_enemy_fx.gd` e `tests/test_indicators.gd`. Pendência conhecida do assado: dobra (`bend`) em osso
  que o rig do KayKit não move (`Spine01`, `neck`) se acumula pose após pose; o rugido de Morvath (`ROAR_BEND` no
  `Taunt_Longer`) provavelmente tem isso (medir antes de reassar Morvath).

## Ciclo LC, Compatibility (LC-4 e LC-5, só no estilizado do Compatibility; antes e depois em `docs/gallery/lc/compat/`)
- Causa: no Compatibility a luz chega à tela sem o passo de linear para sRGB do desktop (uma rampa de emissão v sai como
  cerca de v^2,2 da do Forward+). O corpo estilizado é feito de luz bem abaixo de 1 (`style_light`, `style_scene`) e ia ao
  preto dentro do contorno; um vermelho somado ao chão pintado (que lá é mais claro e frio) lia rosa pálido.
- **Figuras (LC-4)**: só nesse renderizador a luz da figura estilizada sobe a `CrowdRenderer.COMPAT_GAMMA` 0,55 pela
  luminância, mantendo matiz e saturação (`style_gamma` no `crowd.gdshader`, `figure_gamma` no
  `figure_paint.gdshaderinc`); o herói igual (`HeroBody.COMPAT_GAMMA`, `gamma` no `hero_paint.gdshader`: albedo, cada luz
  e a luz própria). O contorno fica como estava (subido, virava halo cinza). 0,55 casa a luma das figuras do
  `tools/enemy_lab.gd` com a do Forward+ (1/2,2 passava um terço). Santuário: fachos e chave da nave a
  `SanctuaryLook.STY_COMPAT_SHAFT` 0,25 no Compatibility.
- **Avisos (LC-5)**: só nesse renderizador, no estilizado, todo aviso (style 0) soma `GroundLook.COMPAT_GAIN` 1,1 da luz e
  a segunda passada escurece o chão sob a área a 1 - `COMPAT_UNDER` 0,3, também nos avisos assinados de Morvath (a
  Tempestade), devolvendo o vermelho da primeira passada por cima; os assinados somam `style_compat_warn` (1; 0,13; 0,1)
  (`ground.gdshaderinc`: `style_compat_gain`, `style_compat_under`, `style_compat_warn`; a mira do besteiro e o bote não
  escurecem). Padrões neutros: Forward+ e todo o clássico iguais (capturas Forward+ antes e depois diferem só em chamas e
  partículas; teste em `tests/test_stylized_figures.gd`).
- Medido (1920 x 1080, RTX; `tools/frame_stats.py --hue`): Tempestade aos 6,25 s, caixa 1300,470,150,40: vermelho na faixa
  69,5% para 100% (Forward+ 99,8%), saturação 0,42 para 0,64 (0,63), matiz 354 para 359 (358), luma 112 para 119 (117);
  na preparação (4,0 s, caixa 900,690,60,60) 43% para 97% (92%), saturação 0,33 para 0,57 (0,57); no começo do aviso
  (3,5 s) 11% para 22% (40%), a faixa já mais escura que o chão (luma 87 contra 106 fora). Santuário A aos 9 s: laje no
  facho 145 para 116 (Forward+ 88), cena p50 77 para 66 (63); esqueleto ao lado do herói p10 1 para 21 e p50 42 para 82
  (Forward+ 33 e 87). iGPU Intel pelo D3D12 do WSL (`MESA_D3D12_DEFAULT_ADAPTER_NAME=Intel GALLIUM_DRIVER=d3d12`,
  `xvfb-run`, opengl3, 1280 x 720 Baixa; o OpenGL do Windows escolhe a NVIDIA): Santuário 27,7 / 25,8 ms antes e
  24,8 / 23,9 depois, Tempestade 34,4 / 32,9 e 31,0 / 34,2 (nada perdido). Pendências: o chão pintado do Compatibility
  segue mais claro que o do Forward+ em todas as salas (Cripta, Santuário: é do `paint.gdshaderinc` e do ar das salas, do
  environment-artist); as erupções (`ritual_rune.gdshader`) e a Emeth seguem mais pálidas no Compatibility.
- **Runas no Compatibility (parecer de cadência 7, P1; só no estilizado do Compatibility)**: lá a laje armada não tem as
  luzes de cima (`RunesLook.ARM_LIGHTS` só no Forward+) e a luz própria sai sem o linear para sRGB: lia só pela moldura
  (+4 a +13 de luma, saturação 0,04). O `RunesLook.dress` põe no chão de runas, só nesse renderizador, `paint_compat_*`
  (`rune_tiles.gdshaderinc`, só no `PAINT`; padrões neutros, o chão clássico nem tem): a luz da laje vezes
  `COMPAT_GAIN` 1,6, a pedra armada `COMPAT_FILL` 0,4 a caminho do âmbar sem cinza a `COMPAT_TONE` 0,6 e com luz própria
  `COMPAT_GLOW` 0,45, as duas vezes o armar; no golpe e na brasa a mesma pedra vai ao marfim-âmbar com luz
  `COMPAT_STRIKE` 0,4 (no Forward+ o golpe é a laje inteira creme; aqui era cinza pálido que sumia em 0,1 s). Medido
  (Runas A, semente 5, estilizado, 1672 x 941, RTX; `docs/gallery/rooms_rp/cadence/*_after.png`): armada aos 3,9 s (0,75
  do aviso) luma p50 103 a 104 para 143 a 145 contra 82 a 113 das vizinhas (+30 sobre a mais clara), saturação 0,04 para
  0,40 a 0,41 (vizinhas 0,08), matiz 30; golpe (quadros a cada 33 ms, `runes_a_strike_*`) +27 para +126 sobre a vizinha
  escura, +18 para +89 e +53 a 0,07 e 0,13 s (Forward+ +125, +108, +86). Forward+ igual (777 pixels de chama e partícula
  de 1,57 milhão). iGPU Intel no Compatibility (D3D12 do WSL, 1280 x 720 Baixa): 34,8 / 35,0 ms antes, 34,0 a 36,2
  depois (GPU 27,8 contra 27,5 a 28,1). Teste em `tests/test_runes_compat.gd`.

## Sworn P1, chão (SW-G1, SW-G2, SW-G3, SW-C1, SW-F1; só no estilizado; ideias em `docs/art/sworn_reference_ideas.md` 3.1, antes e depois em `docs/gallery/redesign/sworn_p1/`)
- Camadas do chão pintado em `assets/shaders/floor_biome.gdshaderinc` (incluído pelo `catacomb_floor.gdshaderinc` só
  com `PAINT`; tudo 0 por padrão, então a câmara das Runas e a Câmara do Selo não mudam; o SW-G3 e outras camadas do
  chão entram ali, cada uma com função e uniforms próprios). Distância até a borda do chão andável na cor do vértice
  (vermelho = metros / `ArenaRoom.FLOOR_EDGE_NORM` 8, escrito pelo `ArenaRoom._floor`; o salão, sem cor, passa
  `floor_box`), lida por `floor_edge_m`. Números por sala na chave `floor` do `style()` de cada look
  (`ArenaKit.paint_look`: nome do uniform para valor; `ArenaKit.gobo(look, pontos)` acrescenta até 4 pontos `x, z, raio,
  peso`).
- **SW-G1, manchas do bioma** (`floor_patches`): segunda cor em manchas de 3 a 8 m (`patch_scale` 3,5, ruído baixo com
  borda quebrada), 0,8 da força no meio e cheia a até `patch_reach` 3 m da borda; a mancha guarda o valor de cada laje
  (cor vezes o valor da laje / `floor_stone`, cerca de 1,4 a 1,5 vezes mais clara) e o chão entre elas desce a
  `patch_rest` 0,9 a 0,95. Salão sal azul-pálido, Cripta umidade fria, Fendas pó lilás, Ponte líquen cinza, Provação pó
  lilás, Altar pó morno, Jardim musgo seco oliva, Santuário pó de calcário (`STY_FLOOR_BIOME` em cada look).
- **SW-G2, sombra recortada** (`floor_gobo`, no albedo, então igual no Compatibility; sem `light_projector`): o chão
  escurece até `gobo_strength` 0,25 e se mexe devagar (`TIME`), limpo nas poças de fogo. Jardim: folhas da copa
  (`gobo_kind` 1, peso 0,85 em toda a sala e cheio debaixo da árvore, `STY_GOBO_TREE`). Santuário: nervuras quebradas da
  abóbada (`gobo_kind` 2, abóbada de 4 partes de 2,6 m esticada 1,5 vezes ao longo da inclinação da luz, algumas sem
  as diagonais, poucas sem nada, falhas ao longo das nervuras) só nos fachos (`MOOT_AT`, o buraco da B) e no do guardião.
- Medido (RTX 1080, semente 5, vitrine 5 s e luta 9 s, `tools/frame_stats.py --hue`; faixa luma p10 a p90 do chão do meio,
  antes e depois): Salão 68 para 78 e 62 para 75; Cripta A 84 para 98 (chão leste 38 para 60), B 72 para 82 (leste 38 para
  63); Santuário A 65 para 81, B 93 para 117; Fendas A 90 para 101 (chão 68 para 94), B 76 para 96; Jardim A campo leste
  37 para 57 (a caixa do meio, tomada pelo tronco, só +5), B 36 para 47 a 50 e oeste 59 para 69; Ponte A plataformas 61
  para 77 e 74 para 86, B plataforma oeste 48 para 65; Provação 50 para 62 e Altar 45 para 56 (laboratório). Saturação
  p90 da tela 6 a 17 (teto 32). Fio da mira menos o chão em volta: Cripta 44 / 37 / 44 para 41 / 35 / 39, Santuário
  28 / 57 / 37 para 33 / 53 / 39, Jardim 31 / 38 para 42 / 44, Ponte 37 / 61 / 41 para 38 / 59 / 50 (figuras e avisos sem
  mudança de shader). Clássico: menos de 0,08% dos pixels mudam mais de 12 (chamas). iGPU 720 Baixa (GPU, duas rodadas):
  Jardim 16,23 / 16,25 para 16,45 / 16,20 ms, Cripta 13,11 / 13,21 para 13,27 / 13,27, Salão 14,95 / 14,96 para 15,19 /
  15,20, Santuário (com e sem a chave `floor`, mesma hora) 15,42 / 15,34 para 16,04 / 15,82 / 15,86 / 15,63
  (média +0,46, no limite de +0,5).
- **SW-G3, lajes emolduradas, e SW-C1, lajes tumulares** (`floor_framed` e `framed_at` no `floor_biome.gdshaderinc`): até
  `ArenaKit.FRAMED_MAX` 16 lajes por sala, retângulos alinhados aos eixos (`framed_rects`: x, z, meia largura, meia
  profundidade; `framed_info`: tipo, leão, valor, semente), postas pela chave `floor` do `style()` com
  `ArenaKit.framed(look, lajes)` e `ArenaKit.framed_slab(meio, tamanho, ArenaKit.Framed.RAISED|GRAVE, leão, valor,
  semente)`. Dentro de uma, as lajes e juntas do chão dão lugar a uma laje só do tamanho dela (a junta na borda dela,
  `rect` e `id` trocados logo depois do `slab()`, sem canto faltando, sem inclinação própria, oscilação da borda a 0,25);
  o relevo é só pintura e normal (nada sobe, nada colide; 0,04 a 0,08 m lidos pelo sombreado de `relief_light`):
  RAISED, moldura saliente de `framed_rim` 0,2 m com topo `framed_lip` 1,22 mais claro, rampas de `framed_slope` 0,05 m
  claras ou escuras pela face (`framed_face` 0,45), linha escura no pé de dentro (`framed_foot` 0,55) e a laje gasta
  dentro (mais clara e lisa para o meio, `framed_worn` 0,16, `framed_smooth` 0,4); GRAVE, sulco rebaixado
  (`framed_groove` a 0,1 m da borda, 0,08 de largura, `framed_groove_dark` 0,85 para a cor das juntas) e, com o leão, o
  leão do selo (`lion_sdf.res`, `framed_lion`, posto pelo `ArenaKit.framed`) em relevo pequeno no meio, `framed_lion_span`
  0,8 m de altura, cabeça ao norte, mais claro e com sombra do lado de lá da luz. Nunca disco, anel nem cruz. Salão
  (SW-H1): dois pares de 2,4 m dos lados do eixo da escada do altar entre o medalhão e o altar (`CatacombHall.STY_FRAMES_*`,
  `_frames`). Cripta: lajes tumulares do tamanho das antigas (`SLAB`) completando as fileiras de z -8,3 e 8,3
  (`CryptLook.STY_GRAVES_NORTH`, `_SOUTH`; 13 na A, 12 na B, que deixa a do sarcófago noroeste), 4 com o leão (uma em
  cada cinco contando as 6 antigas, que seguem iguais), valor `STY_GRAVE_VALUE` 1,06; e um par emoldurado: 2,2 m dos
  lados do túmulo grande na A, 1,9 m entre os dois sarcófagos do sul na B (`STY_FRAMES_A`, `_B`; `_graves`). Santuário
  (SW-S3): três de 2,4 m em fileira no chão da nave diante da grade (`SanctuaryLook.STY_FRAMES_*`). Ponte (losango) ficou
  de fora: o shader só faz retângulos alinhados.
- **SW-F1, coluna tombada nas Fendas** (`RiftLook._fallen_column`, `FALLEN_COLUMN_*`, A e B; refeita pela revisão do
  Sworn P1, F-1 e F-2, `docs/gallery/redesign/sworn_p1/ART_REVIEW.md`): coluna de 0,7 m de raio com caneluras
  (`Masonry.fluted`, 14 caneluras de 0,06 m, cilindro facetado em leque), três tambores por metade de raio 0,88 a 1,0 e
  giro próprios, base com plinto e toro na ponta oeste (`FALLEN_COLUMN_BASE`) e o capitel caído pendurado na quebra
  (ábaco, campana e um toco do fuste, `FALLEN_CAPITAL*`), atravessando o buraco do sul da fenda no lado norte dele (z 5,0,
  onde a câmera do jogo a vê inteira; em z 6,2 o meio ficava atrás da ponte do sul), de baixo do lábio oeste (x -8) a
  baixo do leste (3,4), quebrada em x -2,3 (vão de 0,9 m), cada metade descendo 12 graus para a quebra, topo a -0,6 m
  nos lábios, a metade leste girada 15 graus para o sul no plano (`FALLEN_COLUMN_TWIST`): não lê como viga nem cano nem
  passarela. Pedra da sala a 0,7 do valor (`ashlar()` vezes `FALLEN_COLUMN_VALUE`) na camada das profundezas, lascas da
  quebra embaixo, correntes da quebra e das pontas (`FALLEN_COLUMN_HANG`), sem luz, nada colide, tudo no `kit.styled()`.
- **Correções da revisão do Sworn P1** (só no estilizado; antes e depois na GPU em `docs/gallery/redesign/sworn_p1/fix_*`):
  C-1 as 6 lajes tumulares antigas da Cripta (escuras, liam como alçapão) pintadas pelo próprio `paint_ref`
  (`CryptLook.STY_OLD_SLAB`: laje 0,22, moldura 0,1, sulco 0,03, inscrição 0,2; gêmeos `_own_paint` com
  `ArenaKit.PAINT_OWN`): na luta da A a laje fica a 0,73 a 1,0 da luma p50 do chão a 1 m (era 0,59 a 0,79). S-1 Salão: as quatro emolduradas
  com tamanhos, valores e tipos próprios (`CatacombHall.STY_FRAMES`: 2,0 a 2,8 m, valor 0,92 a 1,0, uma tumular com o
  leão, uma com a quina quebrada), moldura mais baixa (`framed_lip` 1,08, `framed_worn` 0,05): na vitrine as lajes medem
  luma p50 96 a 134 contra 98 a 138 do chão vizinho (antes 102 a 141, de 4 a 9 acima). `ArenaKit.framed_slab(..., mark)`: na tumular o leão, na RAISED a quina quebrada
  (`framed_broken` 0,55 no `floor_biome.gdshaderinc`: uma quina por semente, borda irregular, sem moldura nem topo, mais
  escura). S-2 Santuário: as três (`SanctuaryLook.STY_FRAMES`, tamanhos e valores próprios, uma quebrada) descem a nave do
  facho do guardião para leste, 2 m ao norte do eixo, entre as fileiras de colunas, onde a câmera do jogo as vê. G-2
  nervuras do Santuário mais fortes e duras (`gobo_strength` 0,35, `gobo_soft` 0,03). K-1 gaiolas da Câmara do Selo
  maiores (`BossChamber.STY_CAGE` 0,73 x 2,13 m, barras 0,08) e um osso velho caído numa delas (`STY_CAGE_BONE*`). R-1
  na Cripta A metade dos grupos de velas fora da coroa apagados no estilizado (`CryptLook.STY_GROUPS_OUT`, chamas
  escondidas e luz em `off`; 16 luzes acesas, eram 18). Nenhuma laje só desenhada (emoldurada ou tumular) a menos
  de `ArenaRoom.PLATE_CLEAR` 0,6 m de uma laje que fere do RP-06 (`ArenaRoom.clear_of_plates`, lido do
  `layout.hazard`): na Cripta A saem 4 tumulares novas (ficam 8). Colisão, clássico e `fit_probe` iguais; iGPU 720
  Baixa (GPU) Cripta A 13,70 / 13,89 para 13,88 ms, Fendas A 14,58 / 14,55 para 14,69 / 14,81.
- Testes em `tests/test_room_style.gd`: `test_sworn_framed_slabs_lie_on_free_floor` (Salão, Cripta A e B, Santuário A e B:
  cada laje no chão, longe de toda peça e das outras, 2 a 3 m as emolduradas, o Salão com 4 longe do medalhão, a Cripta
  com 2 emolduradas, mais de 10 tumulares e 15 a 25% de leões contando as antigas; nenhuma no chão clássico) e
  `test_sworn_fallen_column_under_the_floor` (A e B: topo abaixo do chão, de baixo do lábio oeste a baixo do leste, a
  metade leste girada para fora da linha);
  ida e volta do F7 e "nada do estilizado sobre o chão entre 0,3 e 2,6 m" nos testes de antes.
- Medido (G3, C1, F1; RTX 1672 x 941, semente 5, vitrine 2 s e luta 9 s, `frame_stats.py --hue --scene`; capturas `g3_*`,
  `c1_*`, `f1_*` com recortes `*_detail_*` e `*_compat_after`): o quadro igual (luma p50 da cena 67 / 44 / 43 / 63 no
  Salão, Cripta A, B e Santuário, saturação igual), as lajes leem pelo relevo e não pela luz. Fio da mira de 4 besteiros
  sobre o herói parado numa moldura do Salão: caixa do fio luma p50 104 para 105, vermelho 15% nos dois, chão em volta
  igual. fit_probe igual antes e depois em todas (Salão 3,04 / borda 39,06; Cripta 0,32 e 0,31; Fendas 1,49; Santuário
  1,20). Clássico: 0,27 a 0,42% dos pixels mudam mais de 12 (chamas e partículas). iGPU 720 Baixa (quadro, duas
  rodadas; Cripta quatro): Salão 17,63 / 17,78 para 17,18 / 18,07 ms, Cripta A 16,31 / 16,46 para 16,22 / 16,22 / 15,70,
  B 15,93 / 16,27 para 16,05 / 14,99 / 15,42 (uma rodada de 19,04 fora), Fendas A 17,98 / 16,64 para 17,09 / 16,68, B
  17,00 / 17,63 para 17,36 / 17,20, Santuário 18,59 / 18,24 para 18,23 / 18,05: nada acima do ruído. Compatibility sem
  erro no Salão, Cripta e Fendas.

## Sworn P2 (cenário; SW-G4 a G6, SW-H2, H3, SW-C2, C3, SW-F2, F3, SW-J2, J3, SW-S2, SW-P1 a P3, SW-R1, SW-A-1, RS-C7; só no estilizado salvo RS-C7; antes e depois em `docs/gallery/sworn_p2/`)
- **Comum em `ArenaRoom`**: `classic_only()` (um `Masonry` sob o nó "ClassicOnly", escondido no estilizado, o gêmeo do
  `kit.styled()`); `wall()` guarda as paredes em `_wall_runs` (`[a, b, out, altura, vãos]`); `on_hazard(p, folga)` (lajes,
  faixas e tiras do perigo da sala). **SW-G4, oferendas**: `offerings(ponto, along, y, quantas, semente)` (urnas de barro
  morno `OFFER_CLAY`, uma em três mais escura, e velas apagadas, nada sobre o chão andável) e, nas salas com
  `sworn_offerings()` verdadeiro (Santuário, Runas, Provação, Altar), grupos no pé das paredes altas a cada `OFFER_EVERY`
  5,5 m, longe de portas, nascimentos, vãos e do que o look recusa (`offer_free`). **SW-G5, portões**: em cada porta usada
  um portão de ferro logo depois da boca (`GATE_*`): as portas viradas para a câmera uma grade baixa que afunda, as outras
  duas folhas que giram; fechados na luta, abrem uma vez em `GATE_TIME` 0,9 s quando as portas abrem (`breath(i)` chama
  `open_gate(i)`; `gate_shut(i)`); Salão e Câmara do Selo sem portões. **SW-G6, primeiro plano**: o look que devolve
  `foreground_look()` (`out`, `top`, `every`, `tint`) ganha tocos e pares de aduelas da pedra funda fora das bordas viradas
  para a câmera (`_foreground`, `FG_*`; Fendas e Jardim). **SW-F3, merlões**: `merlons(a, b, out)` (no clássico a
  balustrada de sempre; no estilizado um murete de `MERLON_PLINTH` 0,36 m com blocos a 45 graus, altos e baixos), no trecho
  `RiftLook.MERLON_SPAN` da borda norte das Fendas; entra na sequência das quebras de balustrada (`_on_merlons`) para o
  resto ficar igual. **RS-C7**: `balustrade_edge(..., trim)` recua os postes das pontas para fora do chão e das bocas
  (`_rail_end`, `RAIL_TRIM_*`); a Ponte usa: fantasma 4,12 / 2,76 m² para 0 nos dois looks, chão igual.
- **Salas**: Salão, fonte com três filetes de umidade e musgo saindo da bacia (`CatacombHall._rivulets`, `RIVULETS`) e loja
  com o caminho de lajes gastas da entrada aos itens (`_trail`, `TRAIL`); `CatacombHall.floor_strip(caminho, largura, y,
  material, esmaecer)` faz a faixa no chão; `floor_decal.gdshader` `kind` 5 (umidade, `wet`, `wet_moss`) e 6 (trilha
  gasta, `trail`, `trail_cell`, `trail_wear`). Cripta: pilhas de fêmures nos nichos norte e oeste (`CryptLook._ossuary`,
  `FEMUR_*`, SW-C2: crânios só com o Meshy, nunca sem o Daniel) e oferendas na saliência (C3); `_slab_free` tira as
  lajes tumulares sob peças. Fendas: sal pálido nas manchas do chão (`STY_SALT`). Jardim: poça rasa fora do corte noroeste
  na A (`_cut_pool`) e raízes rasas, até 0,12 m, na casca escura do `EdgeKit`, saindo dos pés das colunas (`_shallow_roots`, longe dos
  perigos).
  Santuário: remates nas colunas quebradas (`_finials`, nunca na que tomba). Ponte: estandarte do leão balançando em cada
  pilone (`_pylon_banners`), losangos sulcados nas plataformas (`_lozenges`, decalque `kind` 4) e pegões antigos no
  abismo (`_old_piers`). Runas: grupos de três tabuletas encostadas nas paredes norte e oeste (`_tablets`). Altar: duas
  bacias de água escura com luz fria difusa (`AltarLook._basin`, `BASIN_*`). Provação (SW-T1) e SW-H1, S3, F-6, J-5 já
  estavam feitos. Medido: `fit_probe` igual em todas as salas e looks, Ponte A e B fantasma 4,12 / 2,76 para 0; robô em
  8 descidas (`smoke 900 --bot-reaction=0.25`) sem `stuck`; iGPU 720 Baixa não medida (o disco C: cheio quebrava o
  espelho do `tools/gpu.sh`).

## SW-G7, os perigos como peças da sala (frente A2; spec `docs/art/sw_g7_hazard_grammar.md`; peça visual, a lógica é do room-designer)
- `HazardPiece` (`scripts/game/hazard_piece.gd`): a divisa gravada em ouro velho escuro e a fenda com brasa âmbar, em
  `hazard_mark.gdshader` (multiplicado sobre a pedra: junta escura, afundar, divisas; igual nos dois looks e no
  Compatibility) e `hazard_fissure.gdshader` (fenda recortada: brasa 0,08 respirando em repouso, até 0,2 nos primeiros 70%
  do preparo e 0,6 no fim, pó claro dormindo). Montadas pelo `ArenaRoom` a partir do `layout.hazard` (e do `also`), nos
  dois looks, nada colide nem muda faixa: laje (`HazardPiece.plate`: junta de 0,06 m, quatro divisas para o meio, duas
  rachaduras que não se cruzam; com `plate_push` três divisas para o empurrão, RP-13; com `aims` três para a seteira,
  RP-16), seteira (peça `bolt_slit`: bloco de 1,4 m na pegada do obstáculo, boca escura com moldura de ferro que acende
  de baixo, três divisas), corrente da Ponte (`HazardPiece.chain`: poste de ferro de 3,6 m fora do tabuleiro do lado
  longe da câmera, braço, corrente e peso com divisas para a plataforma; proposta de forma) e a fenda da coluna que tomba
  (`HazardPiece.column`, posta em `toppling[o]`, inclina junto).
- **O que a lógica chama** (PlateFloor, BandFloor, ColumnFloor): `arena.look.hazard_piece(def.plate_source, i)` (laje i)
  e `hazard_piece(def.band_source, i)` (faixa i da corrente) `.set_state(hazard.state(i), not awake, segundos de recarga
  que faltam)` sempre que muda: a laje afunda em 0,15 s (pela junta e o sombreado, o chão é uma malha só), segura a meio
  com os fios novos até o último 0,5 s da recarga; o peso recua 35 graus, treme, varre a 62 e amortece em uns 2 s.
  `look.slit_at(ponto da boca)` dá a seteira de um `aims[i]` (mesmo `set_state`). Coluna:
  `hazard_piece(&"column", obstáculo).crack()` no primeiro golpe; ao bater, `look.toppled(o, rumo, comprimento)` monta os
  tambores deitados (afundados até 0,45 m, 0,8 do valor, descendo 0,2 m em 4 s) e o toco com dentes e lascas, no lugar do
  `tomb.column`. Enquanto a lógica não liga, as peças ficam em repouso (brasa baixa) e o placeholder do `GroundLook`
  (moldura de osso) continua por cima: o `PlateFloor` deve trocar o repouso dele pela peça e deixar só o âmbar do preparo.
  Falta da spec: raiz (3.4), cristal (3.9), urna (3.10), pedras da abóbada (3.8), fenda que respira (3.7), planta e nicho
  (Lote D). Testes em `tests/test_room_style.gd` (`test_sw_g7_hazard_pieces`, `test_sworn_gates_open_with_the_doors`,
  `test_sworn_p2_pieces_stand`, `test_rs_c7_bridge_rails_off_the_decks`).
- **Ligado pela lógica (room-designer)**: `PlateFloor` pega a peça de cada laje (`pieces`, e a seteira que ela arma,
  `slits`, por `slit_at` na boca) e chama `set_state(estado, não acordada, segundos de recarga)` quando muda e durante a
  recarga; com peça, a moldura do `GroundLook.plate_band` fica escondida em repouso e só aparece no âmbar do preparo e no
  golpe (faixas sem peça, como raiz, planta e nicho enquanto não registradas, seguem com a moldura). `BandFloor` faz o
  mesmo com a peça de cada faixa (`band_source`: corrente, e o fôlego quando registrado). `ColumnFloor` chama `crack()` no
  1º golpe e `look.toppled(o, rumo, comprimento)` ao bater, no lugar do `tomb.column`. `DropFloor` monta um
  `HazardPiece.drop` por pedra (a caixa provisória só sem look) e passa o preparo, o golpe e os segundos de entulho.
  `RuneFloor` chama `set_charge` e `set_state` na peça `hazard_piece(Ground.CRYSTAL_SOURCE, i)` e `UrnFloor` `set_state` e
  `set_oil` na `hazard_piece(Ground.URN_SOURCE, i)` quando a sala as tiver registrado (hoje o `ArenaRoom._hazard_pieces`
  registra só lajes e corrente: raiz, planta e nicho entram pelo `plate_source` no índice da faixa, depois das lajes).
- **Resto das peças (2026-11-21; `docs/gallery/sw_g7/`)**: `HazardPiece.root`, `crystal`, `urn`, `drop`, `breath`, `plant`,
  `niche`, registradas pelo `ArenaRoom._hazard_pieces`: raiz, planta e nicho pelo `plate_source` no índice da faixa
  (`plates.size() + i`), cristal por `Ground.CRYSTAL_SOURCE` (encostado na face da parede, a base para o chão), urna por
  `Ground.URN_SOURCE` (com o canal do óleo), fôlego pelo `breath` (folhas de bruma cinza-índigo, `hazard_haze.gdshader`);
  pedras da abóbada por `look.drop_piece(ponto, lado, preparo, semente)` (entulho enquanto `spent`). Extras:
  `set_charge(n, cheio)` no cristal, `set_oil(alcance, carbonizado)` na urna. A planta fica fora do chão andável, atrás
  do começo da faixa (`PLANT_FOOT` 0,75; só a laje e o chicote no chão). Santuário B: borda limpa (`lip_wall`) nos trechos
  do buraco a menos de `PLATE_EDGE_GAP` 0,6 m das lajes que desmoronam e quatro manchas pálidas nas bocas do buraco
  (`SanctuaryLook._mouths`, AT-SE1/SE2, só no estilizado).

## AP-4 3.1, marca da porta presa (ART-01.5; `docs/art/ap4_spec.md` 3.1)
- O disco que paira sobre a boca de uma porta (`RewardGem.Stand.FLOAT`) ganha o berço de ouro velho do relicário e uma
  haste de ouro velho (`RewardGem.DOOR_ROD` 0,04 m) até o pé dele: do topo do arco onde a porta abre na parede
  (`ArenaRoom.in_wall`, `DOOR_ARCH_TOP` 4,9 m, `DOOR_ARCH_BACK` 0,5 m fora da sala) ou, na escada sem arco, de um poste
  baixo de ferro de 1,2 m (`DOOR_POST`) sobre a bochecha da escada, ao lado da boca do lado direito da câmera, com um
  botão de ouro no topo (`DOOR_KNOB`). A haste encontra o disco no eixo do giro, então o balanço não a solta. Nada
  colide; placa e ponto de usar iguais (`RewardGem._door_mount`).

## Quebráveis, peças (AT-Q2; `docs/art/at_q0_breakables.md`, prancha em `docs/gallery/at_q2/`)
- `BreakableKit` (`scripts/game/breakable_kit.gd`, estático): `build(peça, cor, sala)` monta as nove formas (vaso, urna,
  oferenda, vaso de água com faixa molhada, caixote de tábuas com pregos, tábuas, banco, galhos, muda) com sombra de
  contato (`soft_shadow.gdshader`), `crack(peça)` inclina e racha a tábua da frente do caixote, `shatter(pai, peça, cor,
  rumo)` solta cacos que pulam, deitam 4 s e afundam (a muda solta as folhas, o vaso de água deixa a mancha que seca,
  `water_stain.gdshader`). O `BreakFloor` só chama essas três; regras e colisão iguais. Prancha: `tools/break_lab.gd`.

## HV-C, pintura do Santuário da Vigília (`docs/art/hv_santuario_vigilia_art.md`; capturas em `docs/gallery/hub/hv_c/`)
- No `HubLook`: toldo do Vendedor em duas águas, a de trás mais longa (`AWNING_RIDGE`), listras terra e vinho apagado
  (`AWNING_STRIPE`); Pátio do Retorno com anel de lajes gastas em volta do selo, falhas escuras no leão
  (`SEAL_PAVING`, `SEAL_FAULTS`), caminho de lajes até o medalhão, braseiros menores (`RETURN_FIRE` 0,65) e um lampião
  âmbar baixo sem sombra na mureta leste da escada (`RETURN_LAMP`); placas baixas dos Dons em volta do estrado da Árvore,
  apagadas (`_gift_plaques`, `PLAQUE_*`, para o HV-E acender); Alquimista com estante e frascos, bancada com pano,
  pilão e balança de ferro, telheiro de tábuas sobre dois postes (sempre acima de 2,6 m sobre o chão, `ALCH_ROOF`),
  ervas penduradas e um lampião âmbar baixo sem sombra (`ALCH_LAMP`). Colisão e `HubPlan` iguais.

## Ciclo visual 2026-11-20, cenário (ENV-HB1 a HB3 no Salão, BH-07 no hub; só no estilizado; `docs/design/ciclo_visual_2026-11-20.md` itens 1 e 2, metas em `docs/art/benchmark_hades2_style.md` 4.1; capturas `docs/gallery/ciclo_visual_1120/env_*`)
- **Salão, ENV-HB1 (petróleo)**: pedra, chão e sombra do `CatacombHall.STYLE` num azul-petróleo (`STY_STONE`,
  `STY_FLOOR_STONE`, `STY_SHADOW`; manchas do bioma `patch_color` no mesmo tom), braseiros com poça 1 m mais larga
  (`STY_BOWL_RANGE` 5,5) e as poças do chão âmbar, não bege (`STY_POOL_GAIN` 1,8, `STY_FLOOR_POOL_SATURATION` 1,35, só
  no chão, pela chave `floor`). **ENV-HB2 (duas escalas)**: o chão calmo na escala de poucas lajes (`STY_CALM`, somado ao
  `STY_FLOOR_BIOME` na chave `floor`): juntas, rachaduras e cantos faltando perto do valor da própria laje (uniform novo
  `joint_lift` no `catacomb_floor.gdshaderinc`, só no `PAINT`, padrão 0 = as outras salas iguais; os sulcos do medalhão
  não mudam), chanfro suave, lajes de valores próximos, menos grão e quase sem inclinação; a escala grande fica (manchas,
  lavados, clareiras, lajes emolduradas, medalhão, poças de fogo, borda mais escura). **ENV-HB3 (moldura)**: o chão
  escurece para a borda da sala mais cedo e mais fundo (`STY_EDGE_VALUE` 0,38, `STY_EDGE_SPAN` 0,5 a 1,25 do raio calmo),
  a pedra de baixo do chão (lábios, contrafortes e penhascos, `_under`) num petróleo fundo (`STY_FRAME_STONE`, por
  `ArenaKit.PAINT_OWN`), as balaustradas mais perto da câmera (sul, patamar e a leste até a pedra) com material próprio um
  degrau mais escuro (`_near`, `STY_NEAR_STONE`; no clássico é a mesma pedra) e, no abismo ao sul e a leste, colunas
  quebradas da pedra funda subindo da bruma (`_frame`, `STY_FRAME_*`: seis colunas, um tambor caído e uma corrente; postas
  pela regra de projeção para nunca cobrir chão, escada nem saída na tela; abrem em pontilhado em volta do herói, uniforms
  `see_*` novos no `depth_stone.gdshader` com o `see_through.gdshaderinc`). Nenhuma vinheta nova; nada colide.
- Medido (RTX 1920 x 1080, semente 5, `frame_stats.py --hue --scene`; antes / depois): luta Longe cena matiz 221 / 209,
  saturação p50 0,14 / 0,41, luma p50 65 / 54; meio 80 / 76; laterais 45 e 45 / 34 e 41 (0,45 e 0,54 do meio); faixa de
  baixo 62 / 44 (0,58); chão 3 x 2 m (caixa 1150,600,200,150) p10 a p90 42 a 85 / 43 a 61 (18), e a 6 m dela 42 contra 51
  (a escala grande fica). Luta Perto: cena 0,12 / 0,38, luma 72 / 61, laterais 0,49 e 0,60, faixa de baixo 0,66 (no
  limite: a câmera perto põe o próprio chão da luta nela), chão 3 x 2 m 22. Vitrine: cena 0,15 / 0,41, luma 67 / 58,
  laterais 0,51 e 0,60, faixa de baixo 0,75 (é o chão andável do patamar, que não se escurece mais). Clássico igual
  (`test_room_style`), fit_probe igual (3,04 / 39,06). Loja: a luz das lanternas mais perto do âmbar dos braseiros
  (`SHOP_LAMP_LIGHT` 1,0 / 0,66 / 0,36; com a saturação das poças do chão ia a amarelo vivo, matiz 48 e saturação 0,71,
  agora 37 e 0,52). Compatibility sem erro (Salão e hub; lá o Salão sai mais contrastado: cena 40, meio 99). iGPU 720
  Baixa: Salão 17,32 / 17,29 ms de quadro (17,18 / 18,07 no Sworn P1), hub 17,18 / 17,18 (GPU 15,15).

## Ciclo visual 2026-11-20, cenário, segunda passada (item 4 e o método do Salão por bioma; só no estilizado; matriz em `docs/art/benchmark_hades2_style.md` 7.2, revisão em `docs/gallery/ciclo_visual_1120/ART_REVIEW.md`; capturas `docs/gallery/ciclo_visual_1120/env2_*`)
- **Salão e hub (revisão do art-director)**: manchas do bioma mais calmas para toda sala (`ArenaKit.SOFT_PATCHES`, somado
  depois do `ArenaKit.CALM_FLOOR`; o dicionário do bioma só traz a `patch_color`); o derrame do portal no chão é um ponto
  de luz pequeno (`CatacombHall.STY_SPILL`: verde 0% na caixa 1440,320,140,60 da Longe); no Compatibility o chão do
  Salão escurece menos para a borda (`STY_COMPAT_FLOOR`: laterais 0,34 a 0,43 e faixa de baixo 0,42 a 0,47 do meio). Fonte
  do Salão com uma poça fria de luz difusa por cima (`CatacombHall.FOUNTAIN_POOL*`, `light_specular` 0, sem sombra, nunca na
  multidão; `ArenaKit.fountain_spent` a apaga a 0,3 junto com a água). Hub: água da fonte sem o céu (P2-A9: o mármore eram
  as próprias ondas largas e o cubemap baixo; no estilizado `dark_water_matte.gdshader`, `ambient_light_disabled`, com
  ondas finas e fracas e luz própria do corpo, `HubLook.STY_WATER_*`, `body_light` no `dark_water.gdshaderinc`, corpo
  comum dos dois shaders); borda do pátio mais escura (`HubLook.STY_RIM_FLOOR`: `calm_radius` 8, `edge_value` 0,45) com as
  poças das estações poupadas (uniforms novos `keep_spots`/`keep_spot_count` no `catacomb_floor.gdshaderinc`, lidos das
  miras de `STY_POOLS`); a poça do portal verde e larga (P1-A2: verde 21% na caixa 810,40,300,150 da Perto).
- **Por bioma** (cor da pedra, sombra, ar, chão e manchas no `STYLE`/`STY_FLOOR_BIOME` de cada look; nada colide):
  Cripta petróleo (A: coroa um pouco menos verde, `CROWN_COLOR`, `CROWN_ENERGY` 2,2; B: banho frio sobre o ossuário,
  `STY_OSSUARY_WASH*`, 17 luzes acesas), Fendas índigo (aqueduto na pedra funda `deep()`), Ponte ardósia (pontes do fundo
  nas duas variantes e quatro esporões de rocha subindo da bruma, `ArenaRoom.depth_spurs`, `BridgeLook.STY_SPURS`), Runas
  ardósia (grade de repouso a `paint_trace_share` 0,2, sulcos dos pilares `STY_IVORY` mais apagados; âmbar só armado),
  Jardim oliva, Santuário calcário morno (fachos `STY_SHAFT_WARM` menos laranja), Provação e Altar com moldura escura
  (`STY_FRAME`: `calm_radius` 6, `edge_value` 0,6) e o Altar em pedra morna.
- Medido (RTX 1920 x 1080, semente 5, Perto / Longe, `frame_stats.py --hue --scene`; matiz, saturação p50, luma p50):
  Cripta A 183 a 192, 0,32 a 0,34, 44 a 51 (quente 4,9 a 8,6%), B 189 a 193, 0,33 a 0,38, 43 a 49; Fendas 252 a 254,
  0,39 a 0,40, 48 a 54; Ponte 221, 0,34, 50 na Perto (na Longe o abismo toma o quadro: 220, 0,36, 36 a 38); Runas 239 a
  241, 0,28 a 0,29, 49 a 55; Jardim 73 a 82, 0,25 a 0,28, 51 a 54, verde 0%; Santuário 32, 0,30 a 0,33, 60 a 64; Provação
  267 a 270, 0,33 a 0,34, 42 a 47; Altar 28 a 30, 0,29 a 0,33, 44 a 45; Salão Longe 210, 0,42, 48. Moldura: Salão
  laterais 0,43 e 0,50 e faixa de baixo 0,55 do meio, vitrine 0,62; Cripta laterais 0,34 a 0,43. Não atingido: a faixa de
  baixo das Fendas e da Ponte na Perto (0,9 a 1,08: é o chão andável) e as bordas do hub (0,78 a 1,0: as estações acesas
  ficam nas laterais do quadro, BH-07). Compatibility sem erro em todas, matizes iguais. `test_room_style` 43/43,
  `test_hub` 54/54, `fit_probe` igual em todas.
  iGPU 720 Baixa (GPU, `sty_probe` com `--play`, o quadro preso no vsync): antes e depois no mesmo arranjo, Jardim 15,88
  e 15,89 ms, Ponte A 12,87 e 12,67 (as pontes do fundo e os esporões não custam); Salão 15,05 a 15,18, hub 15,24 a 15,27,
  Cripta 14,4 a 14,5, Fendas 14,1, Santuário 13,9, Runas 13,6 a 13,7, Altar 10,7, Provação 11,7.
- **P1 e P2 da revisão dos biomas** (`docs/gallery/ciclo_visual_1120/ART_REVIEW.md` 4.5; capturas `env3_*`): Altar mais
  vermelho que o Santuário (pedra, chão, ar e manchas, `AltarLook.STYLE`), Santuário em calcário amarelo-pálido menos
  saturado (`STY_FLOOR`, `STY_SHAFT_WARM` quase marfim, manchas); Fendas e Ponte com poças de luz de chave difusas sobre
  os campos de luta (`ArenaRoom.key_pool`: `SpotLight3D` sem especular nem sombra, nunca na multidão, só no estilizado,
  o meio `KEY_POOL_SHIFT` do raio para longe da câmera; `RiftLook.STY_KEY_POOLS`, `BridgeLook.STY_KEY_POOLS`, energia 6)
  e o ar mais baixo (ambiente 1,6 e 1,3, lua 0,8 e 0,6), sem pintar o chão nem mexer nos avisos; hub com as chamas dos
  braseiros da chegada a 0,67 (`HubLook.STY_STAND_FLAME`, a luz igual) e a borda entre as estações mais escura
  (`STY_RIM_FLOOR` `edge_value` 0,32, `STY_KEEP` 2,5 a 4 m); Ponte com pedra, sombra, céu, névoa e brilho do abismo mais
  azuis (`BridgeLook.STYLE`, `STY_GLOW`); Jardim com ar, casca, cordas e preenchimento da árvore um pouco mais verdes,
  ferrugem da copa e das folhas mais viva, janelas e água das cascatas em cinza-oliva (`GardenLook.WATER_DEEP`,
  `WATER_PALE`, `STY_WINDOW_*`). Medido (RTX 1080, semente 5): Altar matiz 23 (Perto e Longe), saturação 0,40 a 0,42,
  vermelho 0,1%; Santuário 36 a 37, 0,24 a 0,25; laje Rachada armada na nave oeste (`--start=miniboss --hero-at=-12,-9.5`,
  4 s) saturação 0,53 e luma 161 contra 0,23 a 0,26 e 72 a 96 da pedra em volta; Fendas Perto faixa de baixo 0,77 do meio
  (era 1,0), Ponte 0,73 (era 0,94); fio da mira menos o chão em volta: Fendas 35 para 40, Ponte 0 para 1; Ponte matiz 223;
  Jardim 84, ciano 0% na lateral oeste; hub: faixa de perto quente 11%, borda oeste entre as estações 0,63 da praça.
  Não atingido: o esqueleto à direita do herói no `sanct0_armed` (corpo 73 contra 60 a 75 do chão; o de baixo fica 37 a
  46 abaixo): é a luz do corpo (`crowd.gdshader`), do technical-artist.
- **EdgeKit nas salas (TA-HB2, `docs/gallery/hb/ART_REVIEW.md` item 2; só no estilizado, por `ArenaRoom.edge_kit()`, um
  `EdgeKit` sobre o `kit.styled()`)**: Fendas com tufos de raízes presos sob a beira do tabuleiro de cada ponte de pé, do
  lado da câmera (`RiftLook.EDGE_ROOTS`, `EDGE_ROOT_CLUMPS`), e entulho no degrau afundado de metade dos lábios com
  balaustrada (`_ledges`, `EDGE_RUBBLE`; nenhum perto da coluna tombada); o arco quebrado da boca norte ficou. Jardim:
  raízes dentro das janelas cegas do norte sob o arco e no topo quebrado do pilar noroeste, hera sob a cornija de cima da
  parede norte e, na A, da oeste (`GardenLook.EDGE_*`). Santuário: duas colunas quebradas subindo do escuro em dois vãos
  da parede baixa do sul e entulho sobre o topo dela (`SanctuaryLook.EDGE_*`). Cripta: hera sobre a crista da parede
  norte entre os nichos e dentro do nicho sem estátua, com entulho no chão dele (`CryptLook.EDGE_*`). Ponte: dois arcos
  quebrados longe no abismo ao norte (`BridgeLook.EDGE_ARCHES`); a corrente com peso espera a correção. Salão sem nada.
  Nada colide nem passa sobre o chão andável (`test_room_style` 43/43, `fit_probe` igual em todas).

## ENV-HB4, o vazio além da borda (só no estilizado; `docs/art/benchmark_hades2_style.md` 4.1; capturas `docs/gallery/ciclo_visual_1120/env4_*`)
- **Arcadas sob a borda** (`ArenaRoom.under_look()`, padrão `{}`; `_under_arcades`, `_under_run`, constantes `UNDER_*`): cada
  borda OUTER virada para a câmera (`UNDER_FACING` 0,2) e com pelo menos `UNDER_MIN` 4 m ganha, sob o chão, pilares a cada
  `UNDER_STEP` 4,6 m (alguns quebrados com uma pedra em cima), arcos de aduelas com o topo em `top`, um vão escuro
  (`UNDER_RECESS`) e blocos de rocha ou cortinas de raiz (`EdgeKit.root_curtain`) entre eles, na pedra funda da sala um
  degrau mais clara (`UNDER_TINT` 1,7); longe das bocas das portas (`_near_door`, `UNDER_DOOR`). Opt-in por look:
  `STY_UNDER` na Cripta (`set` = `FRONT.y`, cores próprias), Fendas, Jardim e Ponte (esta com `skip` nas plataformas de
  fora). As bordas são guardadas em `_runs` pelo `_edges`.
- **Cartões de ruína** (`ArenaRoom._style_ruins`, todo `abyss_ruins.gdshader` da sala): menos fustes (`STY_RUIN_SHAFTS`
  0,1), todo vão entre torres com ponte (`STY_RUIN_BRIDGED` 1), a bruma do cartão `STY_RUIN_MIST` 0,7 do caminho até a
  pedra dele, e o cartão mais longe pinta a própria bruma onde não há pedra (`backdrop` 1, sem as manchas claras): as
  faixas verticais claras entre as torres eram o céu aparecendo pelo cartão recortado. Cripta: a bruma da frente baixa,
  rasa e mais fraca (`CryptLook.FRONT_MIST` (2,5; -4; 3; 0,25)). Fendas: o aqueduto em duas fileiras
  (`STY_AQUEDUCT_FAR*`), a de perto em `STY_AQUEDUCT_TINT` 3,0 afundando mais embaixo (`STY_AQUEDUCT_SINK`).
  Jardim: bancos de bruma oliva sob a borda sudoeste (`GardenLook.STY_WEST_MIST*`).
- Medido (RTX 1920 x 1080, Longe, semente 5; caixa do vazio contra o meio 640,360,640,360, luma p50, p90-p10,
  saturação p50; antes / depois): Cripta A (1250,700,600,250) 0,59 / 0,46, 39 / 54, 0,37 / 0,41, faixa clara da
  direita 320 / 211 px; Fendas A (0,300,300,600) 0,40 / 0,42, 23 / 18, 0,40 / 0,54 (o aqueduto lê em pedra, mas a caixa
  segue escura: fica abaixo de 30); Jardim A (0,500,300,450) 0,25 / 0,36, 30 / 33, 0,28 / 0,29; Ponte (200,650,700,350)
  0,30 / 0,36, 38 / 56, 0,41 / 0,41, faixa da esquerda 319 / 255 px (as cascatas ao norte, P4, são faixas de propósito).
  fit_probe igual ao de antes; clássico igual (`test_room_style` 43/43, `test_visual_profile` 6/6).

## ENV-HB7 e ENV-HB5 (só no estilizado; `docs/art/benchmark_hades2_style.md` 4.1; capturas `docs/gallery/ciclo_visual_1120/env7_*`, `env5_*`)
- **ENV-HB7, Salão**: velas no estilizado a `CatacombHall.STY_CANDLE_HEIGHT` 0,45 da altura e `STY_CANDLE_RADIUS` 0,85
  do raio (a maior 0,5 m contra os 2,75 m do herói desenhado), o halo e a luz descem junto; as velas clássicas ficam num
  `Masonry` só do clássico (`CatacombHall.classic()`, nó "ClassicOnly") e as gêmeas no `kit.styled()`, com os mesmos
  tamanhos sorteados. Poças do chão mais saturadas (`STY_FLOOR_POOL_SATURATION` 1,9, era 1,35). O caixote do KayKit da
  pedra leste, no campo de luta, vira no estilizado um bloco da pedra do salão do mesmo tamanho e no mesmo lugar, com uma
  lasca em cima (`_field_crate`, `FIELD_CRATE_CHIP`; `ArenaKit.crate(..., into)` e `crate_frame`); a colisão é a mesma.
  Os outros caixotes ficam no pé do altar e na balaustrada, fora da luta. Medido (RTX 1080, Longe, semente 5, antes /
  depois): saturação p50 da poça da vela oeste 0,22 / 0,47, do braseiro leste 0,36 / 0,80, do norte 0,39 / 0,55; cera da
  vela maior 55 / 37 px contra o herói correndo com 122 px. fit_probe estilizado fantasma 3,04 / 2,49 e borda falsa
  39,06 / 41,20 (os topos das velas baixas fora do chão contam como chão; com as velas no tamanho clássico 39,40).
- **ENV-HB5, balaustradas** (`ArenaRoom._break_rails`, `RAIL_*`, toda `balustrade_edge`; as linhas que continuam uma a
  outra juntas por `_joined_rails`): a cada `RAIL_BREAK_EVERY` 3 vãos uma peça quebra a fileira, nunca perto de porta e
  nunca sobre o chão. Na balaustrada virada para a câmera, em rodízio: hera pela face de fora, pedras caídas num poste,
  raízes. Na virada para longe: um toco de coluna quebrada sobre o poste (`RAIL_STUMP`, tambores caídos para fora) ou
  pedras sobre o corrimão. Parcial: lê nas Fendas (toco e pedras na fileira norte e oeste), pouco na Ponte; as caixas
  laterais seguem no vazio do abismo (p90-p10 à esquerda e à direita, antes / depois: Fendas 22 e 54 / 22 e 53, Ponte 58 e 52 / 57 e 52), então o aceite de
  50 nelas depende do HB4, que ficou como está. fit_probe estilizado igual ou melhor (Fendas borda falsa 5,47 para 3,45).

## Lote 2B e TA-HB, parte do technical-artist (2026-11-20; evidências em `docs/gallery/lote2b/`, `docs/gallery/hb/`, `docs/gallery/c19/hurt_flash/`)
- **Ferramentas de `-s` que nomeiam classes com autoload** (`T`, `Audio`): o script de `-s` é compilado antes dos
  autoloads existirem. `tools/enemy_lab.gd`, `tools/walk_strip.gd`, `tools/rj1_lab.gd` e `tools/edge_lab.gd` são calços
  que carregam o corpo de `tools/lab/<nome>.gd` (um `Node`) em tempo de execução; ferramenta nova que monta o jogo faz
  igual. `Fx` lê o texto do ouro por `_gold_word()` (o `chamber_lab` e o `drawn_probe` voltaram a compilar).
  `walk_strip` aceita `id@modelo` (o mesmo inimigo com outro assado).
- **Golpe sofrido sem silhueta** (combat_cadence 8.3 item 4): o `flash.gdshader` somava uma cor morna chapada no corpo
  inteiro (+0,45 a +0,75 linear) e o herói virava marfim por 2 a 3 quadros nos dois looks. Agora o clarão é a própria
  pintura dele mais clara (`Player.HURT_FLASH_LIGHT` 0,45 somado ao `fill` do `HeroBody.set_fill`, o caminho do pisca) e
  o overlay só deixa uma borda morna (`flash_edge` 0,35, `flash_gain` 0,6). Medido a 60 qps (Movie Maker, 10 esqueletos
  elite, semente 5): luma da caixa do herói no pico 154 antes, 121 depois (105 em repouso), cores e rosto lidos.
- **Assado** (`tools/bake.gd`): opção `"centred"` no clipe (cada pose deslocada em x e z para o centro dos vértices ir em
  linha da origem ao da última pose; o erguer de quem levanta no lugar: esqueleto 0,23 para 0,05 m, corredor 0,18 para
  0,02, besteiro 0,14 para 0,03, sacerdote 0,26 para 0,06, Cavaleiro 0,30 para 0,14; feiticeiro, Escudo e ancião têm o
  pior na última pose, a guarda com cajado ou escudo, T5b P2-2); opção `"kick"` (`{at, up, down, bend}`: a dobra sobe em
  `up` s e volta em `down` s; o tiro do besteiro `CROSSBOW_KICK`, tronco 5 graus para trás em 0,06 s e de volta em 0,2,
  T5-19). Morvath: `curse_windup` (`OverhandThrow` 0 a 0,26 s, no lugar) armado pelo `Boss._step_curse` com o
  `Horde.windup_arm` antes do arremesso (T5-17) e `rain_wave` (`Spellcast_Raise` 0 a 0,5 s ida e volta) tocado uma vez
  por onda de erupção (`Boss._step_eruptions`, T5-18; o `rain:13` parado saiu). Assado novo `runner_elite.res`
  (`RUNNER_ELITE_JOG`, passada 1,55: 199 passos por minuto a 7,4 m/s, escorrega 4,6 cm; o comum daria 259), usado pela
  elite do corredor (`"model": &"runner_elite"` no `_pair` do `make_data.gd`).
- **Arranque, parada, finalizador e esquiva no desenho do herói (GF-15, VX-17, B-b; gameplay-engineer; testes em
  `tests/test_hero_motion_look.gd`, sonda 41/41)**: a UAL não tem clipes de arrancar e parar, então o `Player` faz por
  código: da guarda à corrida e da corrida à guarda o clipe mistura em `RunLean.BLEND` 0,1 s e o corpo inclina num pulso
  de `RunLean.TIME` 0,3 s (pico a um terço), `START_DEG` 7 graus para frente ao sair e `STOP_DEG` 5 para trás ao parar
  (`RunLean`, `core/run_lean.gd`, puro; `_model.rotation.x`, só desenho, nunca durante golpe ou esquiva). O finalizador
  (golpe com a tag `finisher`: giro, lança) segura a última pose do clipe `Player.FINISHER_HOLD` 0,3 s e só então vai à
  guarda numa mistura de `FINISHER_SETTLE` 0,3 s (antes voltava em 0,08 s); andar ou outro golpe cortam no quadro. A
  esquiva toca o `Dash` do começo e sem mistura (`_play(..., from, blend)`). Resposta ao direcional e tempos iguais.
- **`--shot-on` antes do `--shot-at`** (Q-T5-7): o `Game._shot` escuta os momentos `boss:` desde o começo; se o momento
  já passou quando o `--shot-at` chega, captura no quadro seguinte e imprime `SHOT ... came N time(s) before --shot-at`.
- **Orbes do Redemoinho** (Q-T5-6): miolo, halo e rastro abaixo do limiar do glow (`Skills.ORB_CORE`, `ORB_HALO`,
  `ORB_TRAIL`; eram 3,0 / 2,4 / 2,6 e viravam dois globos laranja estourados perto do herói).
- **Linha de tinta nas peças (TA-HB1)**: `PaintPass` com `ink` (só contorno por salto de profundidade, sem Kuwahara,
  depois dos transparentes, MSAA mantido): `INK_PX` 2, `INK_COLOR` no tom da sombra, `INK_ALPHA` 0,7, `INK_JUMP` 0,015.
  Só Forward+, estilizado, Alta e Média (na Baixa a iGPU perdia 6 qps), **desligada** (`INK_DEFAULT_ON` false) até o
  art-director aprovar; `--ink-line=1` liga. Custo na RTX a 1080: GPU 2,37 para 2,41 ms.
- **Kit de borda e primeiro plano (TA-HB2)**: `EdgeKit` (`scripts/game/edge_kit.gd`, `EdgeKit.new(kit)` sobre o
  `ArenaKit` da sala): `broken_pillar`, `broken_arch`, `rubble`, `root_curtain`, `ivy`, `chain_weight`; nada colide; tudo
  abre em pontilhado em volta do herói e de Morvath (`see_through`); pedra = a cantaria da sala com `see_through` (pintada
  pelo `paint_look`), raiz, hera e ferro um material cada (`edge_piece.gdshader`, gêmeo `edge_piece_paint.gdshader` pelo
  `VisualProfile`). Triângulos e chamadas por peça em `docs/art/asset_inventory.md`; tabuleiro `tools/edge_lab.gd`.
- **Hub, BH-07 (luz por estação)**: no estilizado o pátio um degrau mais escuro (`HubLook.STY_AMBIENT_GAIN` 0,8, lua
  `STY_MOON` 0,45, preenchimento a `STY_KEY_SHARE` 0,45) e cada estação com poça própria de luz morna vinda do alto
  (`STY_POOLS`: estação, mira, origem, energia, cone, alcance, cor; `_station_pools` monta os `SpotLight3D` difusos,
  `light_specular` 0, sem sombra, `cull_mask` sem a multidão, meta `NOT_FIRE`, num nó só do estilizado): Forja entre a
  boca do forno e a bigorna (fogo do forno a `STY_FORGE_GAIN` 1,5), Livro com uma luz de leitura estreita no atril e
  uma larga no tapete, Vendedor no balcão, Árvore no estrado, e uma poça verde-pálida no pé da escada do portal (na
  chegada a câmera segura o portal fora do quadro: a poça no alto da tela aponta o caminho). Medido (RTX 1080, luma p50
  do chão de uso contra a praça, antes / depois): Forja 153/78 = 1,96 para 166/52 = 3,2; Livro 121/79 = 1,53 para
  109/53 = 2,06; Vendedor 111/61 = 1,82; Árvore 145/46 = 3,2 (meta 1,8). Cena luma p50 80 para 54 a 56, saturação 0,23
  para 0,25 a 0,26. O ENV-HB6 completo (meio 90 ou mais, bordas até 0,35 do meio, saturação 0,30) não foi atingido:
  pede escurecer as bordas do pátio a um terço do meio, o que briga com a spec do hub (4.2, o chão mais claro do jogo);
  fica para o Game Director decidir. `tools/hub_walk.gd` (ferramenta de arte) anda o herói da chegada até uma estação
  pelo `VirtualPad` e grava quadros (`--walk-to`, `--walk-frames`, `--walk-every`, `--walk-count`, `--walk-wait`;
  comando no topo). Testes: `test_room_style` 43/43, `test_hub*` 54/54; fit_probe do hub igual (6,09 / 7,18).

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

## Passe de VFX, Lote 1, parte do technical-artist (2026-11-20; spec `docs/art/vfx_pass_spec.md`, capturas em `docs/gallery/vfx_pass/`)
- **Luz que cai sobre o que se pega (seção 6, `RewardShaft`, `scripts/game/reward_shaft.gd`)**: tronco de luz fraca de
  cima da tela até o relicário (0,6 m em cima, 1,25 no chão, 18 m, `reward_shaft.gdshader`), poça no chão (decalque,
  sem luz real, `reward_pool.gdshader`) e poeira caindo (`reward_dust.gdshader`); tudo `blend_premul_alpha` sob
  `ScreenTone.linear_peak(cor) x CAP_SHARE` 0,85; a 2,5 m do eixo do herói cai a 0,35 (a poça a 0,6) e abre em volta dele
  (`hero_hole`); tempo real. Cor: o matiz do esmalte da recompensa (`TONE`) ou do anjo da porta (`AngelSeal.TINT`), a
  saturação a `TINT` 0,55 da dela e no máximo `PALE` 0,28 (em HSV: misturado com marfim em RGB a romã e o Encanto iam 30
  a 48 graus para o marfim); Bênção de dois anjos ou do guardião em marfim; fonte `fountain_tint()`.
  **API para o gameplay-engineer** (`rooms.gd`, loja e fonte; a `game.column` do `_room_cleared` sai):
  `var s := RewardShaft.make(pai, Vector3(x, 0, z), RewardShaft.tint_of(recompensa, família_do_anjo))`; `s.appear()`
  (espera `WAIT` 0,45 s, desce em 0,35, pousa em 0,25 com pulso, respira); `s.appear(0.0, true)` (loja e fonte: já ali);
  `s.set_strength(RewardShaft.SHOP_CAN | SHOP_CANNOT)` (0,75 / 0,3 pelo ouro; fonte `FOUNTAIN` 0,8 no `make`);
  `s.take()` (sobe em 0,3 s e se apaga sozinho). `--no-shafts` esconde. `tools/gem_lab.gd -- --shafts [--at=s]
  [--shop=0.3]`. Medido (RTX 1080, estilizado, `shafts_sheet_stylized.png`): matiz de cada coluna a até 3 graus da tabela
  (romã 350, coração 340, Magia 226, ouro 40, prata 211, Memória 37, Encanto 137, Salmo 40, Vigília 85), saturação p50 até
  0,26, maior canal p99 159 (teto 210); no Compatibility igual a olho com `COMPAT_GAIN` 1,6. Teste `tests/test_reward_shaft.gd`.
  Falta: medalhão do Encanto e do Salmo é um aro vazio no `RewardGem` (sem marca).
- **Partículas sem bolinha (5.6)**: os `Fx.BURSTS` não usam mais `CPUParticles3D` com o ponto redondo (`Fx.soft_dot` e
  `Fx.quad` ficam para os halos das velas): `form` `chip` = lascas na MultiMesh das lascas (`Fx._spray`, gravidade por
  lasca, as de explosão não contam em `showing(&"motes")`), `wisp` = fiapos de fumaça de borda rasgada que sobem e se
  desfazem de baixo (`Fx.wisps`, MultiMesh de `WISP_POOL` 96, `wisp.gdshader`, premul: escuro cobre, claro soma pouco);
  cores todas abaixo de 1 (cura marfim-rosada, sombra de inimigo em fumaça escura, fogo com dois fiapos de fumaça no
  fim). `chip.gdshader` agora premul sob `cap` (226 na tela). Orçamento igual.
- **V-11 e V-12, inimigo**: orbe com núcleo escuro (`enemy_orb.gdshader`: tinta no meio, aro na cor, `rim` 0,21 e `hot` 0,1: o
  `ScreenTone.linear_peak` do magenta e do carmim a 210 é 0,21 a 0,24; a 0,48 a curva da tela levava o aro a 248 e 255) e
  fumaça rasgada com três espinhos girando em volta (`enemy_orb_halo.gdshader`, premul, `spike_light` 0,22); virote = agulha escura com a
  ponta na cor (`needle`), sem halo; rastro de fumaça a cada 0,45 m (virote) ou 0,7 m (orbe) (`Projectiles._trail`). Onde
  o golpe de um inimigo cai: anel de fumaça escura de borda rasgada que se abre, aro de dentro na cor sob 205 na tela, meio
  escuro, sete fiapos (`Fx.smoke_ring`, `smoke_ring.gdshader`, `Ground._land`; o `land_quick` é o anel fino); as
  erupções de Morvath ficam com o `Fx.ring`. A cor da magia (carmim e magenta) é do `make_data.gd` (gameplay-engineer).
- **V-01 a V-05, a lâmina**: `slash.gdshader` premul (alfa 0 no clássico = a mesma soma), no estilizado o fio a
  `style_edge_pale` 0,45 e o teto pelo maior canal (`style_peak` = `ScreenTone.linear_peak` do fio, posto pelo
  `Fx.slash`; o teto por canal deixava o fio branco-cinza); o giro e os finalizadores são uma fita que varre
  (`crescent.gdshader`: `CRESCENT_SPIN` 300 graus, finalizador `CRESCENT_ARC` 120 a 180, cabeça 0,35 m e cauda 0,08 m,
  fio só no terço da cabeça, a cauda some primeiro); o brilho do finalizador é estrela de 6 pontas desiguais girada por
  golpe, sem cruz nem risco longo (`glint.gdshader` `seed`, `spike_min_m` 0,18, `spike_max_m` 0,42); a estocada é uma
  lâmina (`emeth_thrust.gdshader`: base a ponta 1,0 a 0,15 de `blade_share` 0,4 da largura do golpe, inteira lia como
  folha verde; fio de 2 px, miolo `core_light` 0,12, miolo escuro, tinta 0,4, entra em `THRUST_IN`
  0,06 s e sai em `THRUST_OUT` 0,15; Ômega com os veios e `THRUST_SPIKES` 5 lascas de cristal na ponta); o estalo no
  contato (`Fx.contact`, `contact.gdshader`: 5 a 7 espinhos desiguais, metade num leque de 70 graus para onde a lâmina
  foi, miolo marfim 0,12 m, 0,05 s crescendo a 1,25; orçamento próprio `contacts` de 8 por quadro), chamado no
  `Combat._draw_hit`.
- **V-16, foice e Ceifa**: `boss_scythe.gdshader` premul sob 226: borda roída por ruído (0,15 m em 0,4 m), aro e cabeça
  no violeta, lilás-marfim só no meio do setor, o `edge` espectral não é mais desenhado; `SCYTHE_WISPS` 7 fiapos violeta
  escuro saindo do alcance.
- **Também (fila do HB)**: a linha de tinta ligada por padrão (`PaintPass.INK_DEFAULT_ON`) e fora das figuras: o
  Forward+ marca instância que se mexe no alfa do `normal_roughness` (acima de 0,5) e nenhuma borda que toque uma é
  pintada (`needs_normal_roughness`, `mask` no `paint_pass.glsl`; `--ink-debug` mostra a marca); com 12 inimigos o
  contorno não dobra e não cruza as barras (`docs/gallery/hb/ink_crowd/near_*_masked.png`). HB3: herói no estilizado com
  a pintura `saturation` 1,8 (`hero_paint.gdshader`) e a Emeth com teto pelo maior canal e cristal mais saturado
  (`emeth.gdshader` `style_back`/`style_face`, `EmethSword.STYLE_CORE`): verde na caixa do herói 0,61% para 1,00% na GPU,
  matiz 130 (`docs/gallery/hb/hb3_*`). `chain_weight` refeito (elos a 90 graus, catenária, contrapeso de 0,7 m).
- **Corpo da multidão um quarto mais escuro no estilizado** (Game Director: no calcário do Santuário o osso lia tão claro
  quanto a laje): `crowd.gdshader` `style_light` 0,15, `style_scene` 0,075, `style_rim` 0,14, `style_hero` 0,15 (eram 0,2 /
  0,1 / 0,18 / 0,2); ouro das elites, "vai bater" e pisca iguais. Osso do esqueleto no Santuário A (RTX 1080, semente 5,
  `--arena=sanctuary --hero-at=-12,-9.5`, 4 s) p50 85 para 74 contra o chão 96 a 108 (22 a 34 abaixo, meta 25).
- Medido no fim (RTX 1080, estilizado, semente 5, `docs/gallery/vfx_pass/`): orbes p99 180 a 185, nenhum pixel acima de
  210, matiz 313 (a cor do feiticeiro do `make_data.gd`; a spec pede 320 a 355); fita do giro matiz p50 135, p99 226;
  estalo do contato até 225; foice e Ceifa matiz p50 250 a 254, sem ciano no setor. Sonda de sensação 41/41.

## Passe de VFX, correções do Lote 1 e Lote 2, parte do technical-artist (2026-11-20; revisão `docs/gallery/vfx_pass/ART_REVIEW.md`, capturas `fix_*` e `l2_*`)
- **P1 da revisão**: estalo do contato (`contact.gdshader`) com miolo em estrela dura de 5 pontas (`heart_m` 0,12, não o
  disco macio), 6 ou 7 espinhos com os do leque espalhados por ele, todos encolhendo juntos para o menor no fim (nunca um
  par sobrando em cruz), teto `Fx.CONTACT_SCREEN` 210: na caixa de 80 x 80 sobre Morvath maior canal 209, branco 0%. O
  traço branco vertical era o talho (`impact.gdshader`, `Fx.gash`) somado e visto de ponta: agora premul sob
  `ScreenTone.linear_peak` a `GASH_SCREEN` 210 e `pale` 0,35 (branco nos quadros da multidão 6,7% para até 0,03%). Aro do
  brilho do finalizador (`glint.gdshader`) não se desenha sobre o corpo do herói (a estrela fica com `over_body`). Lascas
  de luz do herói (`Fx.hero_burst(&"light")`) saem baixas e caem (`HERO_LIGHT_TOP` 0,9, nunca acima de `HERO_SHOULDER`
  1,9 m; o atordoar do combo também passa por ele). Morvath no estilizado pisca no próprio violeta (`own_flash` no
  `crowd.gdshader` pelo `style_vivid`, teto `style_boss_flash_cap` 0,5, sem o quadro marfim). P2: anel da explosão do
  corredor mais largo e com meio escuro (`band` 0,3, `middle_dark` 0,5, `rim_light` 0,8), foice com o lilás-marfim no
  miolo (`pale_light` 0,55) e fiapos deitados, fita do herói mais saturada no estilizado (`style_edge_pale` 0,3,
  `style_core_sat` 0,65), virote capturado (`fix_bolt.png`: agulha escura de ponta carmim).
- **5.3, formas das famílias**: `family_mark.gdshader` (`Fx.family_mark(família, ponto, raio, cor, tempo, rumo, arco)`,
  pool `MARK_POOL` 12, orçamento `marks`): Chama línguas de fogo sobre um anel chamuscado, Geada placas hexagonais que se
  espalham e racham, Luz um aro fino desenhado a partir do lado do herói com 8 marcas e fio de ouro, Vigília três arcos
  segmentados que se abrem. `Fx.family_of(cor)` acha a família pela cor (`Combat.FIRE`... e `Boon.FAMILY_COLOR`);
  `Fx.family_hit` no acerto (`Combat._draw_hit`): línguas, farpas de gelo, raio fino com o aro da Luz, grito da
  Vigília. Lascas com forma (`chip.gdshader`, `shape` em `MODEL_MATRIX[1].z`: lente, farpa, língua; `Fx.SHAPE_*`). Cortes
  (`slash.gdshader` `family`): Chama cauda em línguas (e 3 a 5 línguas soltas), Geada farpas na borda, Luz fio mais fino
  e longo, Vigília três traços partidos. `Skills`: NOVA, CONSECRATE e o pouso pelo `family_mark` (sem anel cheio nem
  explosões redondas), STRIKES da Luz um raio fino (`STRIKE_RAY` 0,08 m) e das outras famílias lascas caindo de 7 m,
  orbe de fogo uma brasa alongada com fumaça (sem halo nem `CPUParticles3D`). Corpo congelado com casca facetada
  (`frost_cell` 0,16 m, juntas `frost_seam`). Bênção e Salmo tomados sem coluna: a forma da família no chão em volta dele.
- **V-06**: onda do especial com corpo 0,75 e borda 0,5 (`WAVE_BODY_LIGHT`, `WAVE_EDGE_PALE`), rastro de lascas de
  cristal a cada 0,6 m (`Projectiles._trail`, `WAKE_CHIP*`), acerto = o estalo V-05 com pontas de ouro velho e a forma da
  família (sai a estrela furada `SPECIAL_STAR`). **V-07**: o círculo de luz lança com o aro da Luz e 5 lascas caindo no
  aro (`Fx.circle_cast`), o Ômega explode em 10 espinhos de cristal do aro para dentro (`Fx.circle_burst`); o aro do chão
  a `circle_rim` 0,62 (ia a 233 a 235). **V-13**: `EnemyFx.PALE` marfim-avermelhado (1,05; 0,78; 0,74); o brilho da
  lâmina do esqueleto é um traço que corre a lâmina com um ponto quente na ponta (`GLINT_LINE`, `GLINT_RUN`), sem
  estrela; o orbe do feiticeiro escuro por dentro com a cor no aro. **V-14**: a morte arde em brasa suja
  (`dissolve_color` (0,35; 0,07; 0,06)) e solta um fiapo cinza (`Fx.DEATH_ASH`); as lascas de osso já eram cinza-osso.
  **V-15**: elite surgindo e caindo (horda) com anel de fumaça que se fecha e borda de ouro apagado (`Fx.elite_surge`,
  `smoke_ring.gdshader` `closing`), sem coluna. **V-17**: meias-luas de Morvath premul sob 215, borda roída, corpo
  escuro, lilás só no terço do meio, três caudas de fumaça e giro de 15 graus/s (`Projectiles.SOUL_*`; o rastro aditivo
  `boss_wake` escondido). **V-18**: erupções em lilás-marfim (`eruption_color`) sob `eruption_cap` 0,62.
  **V-09**: Corte do Juízo sem a faixa verde chapada (`ult_rift.gdshader` `breath` 0, as duas bordas em fio
  marfim-menta), 10 espinhos de cristal em duas fileiras saindo da fenda em 0,12 s e quebrando em lascas
  (`Fx.crystal_spike`, `crystal_spike.gdshader`, `Ultimates.CLEAVE_*`; espalhamento por hash, nunca o sorteio da partida),
  acerto pelo estalo pesado. **V-10**: Voragem com véu 0,15 puxado para o amarelo da Emeth, chão escurecido (`ink`
  0,35) e braços partidos em lascas (`dash_m`). **5.7**: número entra a 1,3 e volta a 1,0 em 0,08 s (`Fx.NUMBER_POP`).
- Falta: as lascas de ouro velho das elites ao morrer (uma linha no `horde.gd`, gameplay-engineer). V-08 e as capturas
  saíram no AP-2 (abaixo).

## AP-2 "Combate que se lê", parte do technical-artist (2026-11-21; backlog A6; capturas em `docs/gallery/ap2/`, testes em `tests/test_ap2_read.gd`)
- **ART-05.2, menos vermelho na fase 3**: o vermelho das erupções segue o regime dos avisos comuns
  (`ritual_rune.gdshader`: `fill_early` 0,12 da cor enquanto o golpe está longe, inteira só nos últimos `fill_late` 30%;
  `red_after` 0,2 s depois do pouso some; teto `danger_alpha` 0,24 igual) e o preenchimento dos avisos assinados de
  Morvath também (`ground.gdshaderinc`: `sign_early` 0,3, `sign_level()`, no traço, no arco e no círculo; aro, fio
  violeta e runas inteiros desde o primeiro quadro). Raio, tempo e dano iguais.
- **ART-05.4, foice que abre em volta do herói**: `boss_scythe.gdshader` com `hero_pos`, `hero_hole` (0,7; 1,5) m e
  `hero_keep` 0,3: preenchimento e miolo pálido caem a 0,3 em volta dele; aro e fio da lâmina nunca.
- **ART-05.3**: herói atrás de Morvath conferido na GPU (o raio-x do ciclo 8 já o mostra inteiro com o anel; sem mudança).
- **P2-C19a, corredor elite**: o aro fino do primeiro estouro (`land_quick`) para em `thin_reach` 0,62 do anel
  (`smoke_ring.gdshader`), dentro do aro do segundo aviso, que fica à vista até a segunda explosão.
- **V-08, esquiva e Retorno**: na esquiva o `Fx` (`_animate_ghosts`) deixa até 4 silhuetas de tinta do herói, uma a cada
  `GHOST_EVERY` 0,05 s, cada uma `GHOST_TIME` 0,12 s (`dodge_ghost.gdshader`: tinta do corte, alfa 0,25 a 0,1, fio
  marfim só nas bordas viradas para cima; pose assada por `bake_mesh_from_current_skeleton_pose`, pool de 8; nada sem
  tela). Retorno do Corte: um fio esmeralda fino com um nó que corre a lâmina enquanto a janela de 1 s está aberta
  (`emeth.gdshader` `return_thread`, `EmethSword.set_return(lâmina, k)`, lido do `Combat._return_t` no
  `Fx._animate_return`; no estilizado sob o `style_cap`); `tools/rj1_lab.gd -- --return=1` mostra a lâmina com ele.
- Casca da Geada com juntas mais finas e fracas (`crowd.gdshader` `frost_seam` (0,22; 0,36; 0,46), `frost_seam_from`
  0,455; a 720 lia como rede branca). Capturas das quatro famílias e do Cavaleiro se erguendo na sala em `docs/gallery/ap2/`.
- **ART-05.5** (entrada de Morvath mais lida) depende do tempo da entrada no `boss.gd`: fica para o gameplay-engineer e
  o combat-feel-director. `chain_weight` do `EdgeKit` já refeito (2026-11-20), espera a nova revisão do art-director.

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

## AP-4, esboço em traço dos inimigos e motivos dos Dons (technical-artist, 2026-11-21; spec `docs/art/ap4_spec.md` 2.1 a 2.3; testes em `tests/test_figure_sketch.gd`, `tests/test_talent_motif.gd`)
- `FigureSketch` (`scripts/render/figure_sketch.gd`): o inimigo do Compêndio desenhado a tinta no papel do Livro a partir
  do próprio modelo assado (sem IA), em três passes sobre a página, vazados entre as linhas: só profundidade
  (`figure_sketch.gdshader`, o corpo de perto esconde o de trás), contorno (`figure_sketch_edge.gdshader`, o corpo
  inflado `EDGE_WIDTH` 0,025 m e desenhado por trás) e as linhas de dentro (`figure_sketch_ink.gdshader`: dobras onde a
  superfície vira, hachura na sombra de uma luz fixa do alto à esquerda, uma camada abaixo de `shade_one` 0,5 e outra
  cruzando abaixo de `shade_two` 0,26, a `HATCH_PX` 5 px a 1080, nunca abaixo de `HATCH_MIN` 3; o corpo é o papel tingido
  `fill` 0,26 de um cinza da tinta (`wash_ink`, neutro: o papel escurece sem amarelar); aguada `wash` onde a pintura do modelo é escura; as células que brilham no jogo, olhos e gemas,
  `BakedModel.glow_from`, viram aguada de tinta `glow_ink` 0,5, então a caveira tem órbitas). Elites (`EnemyDef.gild`): o aço
  (a máscara do `crowd.gdshader`, o resto a `gilt_rest` 0,45) numa aguada do ouro do Livro (`Book.GILT`, `gilt_alpha` 0,55); as linhas com a tinta do Livro a no máximo `INK_SAT` 0,32 de saturação, para só o ouro ler como ouro com a hachura por cima.
  Hachura leve no osso claro virado da luz (`bone_from`, `bone_shade`, `bone_alpha` 0,4: a caveira não fica papel em
  branco sobre o corpo hachurado). Vista de 3/4 (`VIEW_YAW` 30 graus para o lado em que a arma fica mais comprida na
  tela, `FigureSketch.yaw(modelo)`: o esqueleto e o Cavaleiro a -30; câmera ortográfica inclinada `PITCH` 12), a pose do `idle`
  que mostra a arma mais comprida na tela (`pose_time`, partes `WEAPONS` do assado), enquadrada pela caixa de todas as
  poses do clipe com `MARGIN` 4% (`fit`, `clip_box`). Sob os pés, sem sombra redonda (`CrowdRenderer.ground_shade`
  falso), quatro traços de tinta de 1 px a 1080 e alfa 0,5 por `GROUND_SPAN` 0,7 da largura dos pés, o mais longo sob o
  pé de apoio (`figure_sketch_ground.gdshader`, `ground`). Para o ui-ux-designer, no `FigureView`, depois do
  `register(def)`: `FigureSketch.apply(renderer, def, Book.INK, altura da vista em px)`, `FigureSketch.fit(câmera, def,
  modelo, &"idle", aspecto)` e o `add_kind` em `pose_time` com `FigureSketch.yaw(modelo)`. Prancha: `tools/sketch_lab.gd`
  (comando no topo), `docs/gallery/ap4/sketch_enemies_*`.
- `TalentMotif` (`scripts/ui/talent_motif.gd`): o motivo pintado de cada um dos 19 Dons, o glifo do `TalentGlyph` vestido
  numa receita só: até três tons por forma de borda dura (base na cor do ramo levada ao papel, saturação até `SAT_MAX`
  0,58; sombra `SHADE` 0,62 embaixo à direita; luz `LIGHT` 1,22 com canal até 0,9 em cima à esquerda), fio de ouro gravado
  na borda iluminada da forma principal, contorno de tinta de 1,5 a 3 px pelo raio, detalhe de dentro só de `DETAIL_FROM`
  22 px; esmeralda só no ramo da Emeth, no quarto corte e no Coração da Emeth. `TalentMotif.draw(ci, id, centro, raio,
  HeroLoadout.State.X)` (trancado a 0,35 com o contorno, selado 0,6, bloqueado acinzentado); abaixo de `LOD_UNDER` 14 px
  desenha o glifo em tinta; falso sem motivo. Formas em `shapes(id)` (polígonos no círculo unitário). Ligar no
  `TalentNode` e no detalhe do Compêndio é do ui-ux-designer. Medidas: `tools/motif_sheet.gd` (sem tela: pares de
  silhuetas por interseção sobre união a raio 16, a maior 0,64; cor, saturação e matiz contra o ramo, todos a 0 graus;
  contorno sobre o nó 4,2:1; trancado 48 de luma abaixo do fundo; com `--png=` a prancha dos 5 estados a raio 16 e 32,
  `--big` todos a raio 80).
- Aro dos medalhões desenhados (2.3): `BoonIcon.ring(ci, centro, raio de fora, largura)` com o perfil do aro dos PNG
  pintados (`RING_BANDS`, medido no `vapor.png`: borda escura, bronze, sulco, filete claro, bronze, sulco, faixa baça e a
  sombra para dentro), `RING_PX` 12,2 px na carta (a largura do aro pintado a 128 px) e `RING_SHARE` 0,12 do tamanho nos
  pequenos; usado pelo `BoonIcon` (Bênçãos sem PNG e Elos) e pelo `PsalmIcon` por cima do selo.

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
  pretos próprios. Sem tela tudo de uma vez: o mesmo `RESULT` (`smoke 600 --seed=5` e `--start=boss --boons=25`). A
  mesma sala nos dois caminhos (nós, cobertura, grade de andar, meio, saídas; todas as arenas, eventos e câmara no teste).
- **Junção sem ler a placa de vídeo** (`Masonry.merge`): o `SurfaceTool.append_from` lia cada peça de volta da placa
  (`surface_get_arrays` espera a placa: 0,15 a 0,57 s por sala na iGPU, 30 ms sem tela). Agora as malhas do `Masonry`
  guardam os arrays (`Masonry.kept(st)`, meta `ARRAYS`, com a tangente que a placa devolveria), os primitivos os fazem
  na CPU (`arrays_of`, uns de cada vez, `PRIMITIVES_A_STEP`) e a junção é feita nos arrays (`joined_arrays`: vértice
  pela transformação, normal e tangente pela base, normalizadas, como o `append_from`; o `SurfaceTool` fica de reserva),
  em fatias de `MERGE_SLICE` 6000 vértices (`merge_steps`). `Masonry.read_back` conta o que ainda vem da placa (0 nas
  salas). `--trace-build` imprime cada passo (`BUILD sala step N ms`) e cada junção (`MERGE`).
