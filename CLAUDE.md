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
`docs/qa/latest_report.md`). Cada arquivo tem um dono por tarefa; agentes em paralelo só com arquivos distintos (ou em
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
  `--start=boss|miniboss|shop|fountain` (sala onde começar), `--showcase` (câmera fixa no enquadramento da imagem de referência; `--cam-yaw`, `--cam-pitch`, `--cam-dist`, `--cam-fov` ajustam), `--horde` (o modo antigo de horda contínua, com `--start=boss|elite1|elite2`), `--shot=arquivo.png`, `--shot-at=segundos`, `--frames=prefixo --count=N --every=s`, `--nosave`, `--smoke` (partida sem tela, imprime `RESULT`).
- Depois de criar arquivos ou classes novas (`class_name`): `~/tools/godot/godot --headless --path . --import`.
- Regerar os dados (combos, inimigos, dons, ondas, salas, sensação): `~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [feel]`.
  Editar os números em `tools/make_data.gd` (fonte da verdade) e regerar; não editar os `.tres` à mão.
- Achar erros de script sem rodar: `~/tools/godot/godot --headless --path . -s tools/check.gd`.
- Partida sem tela com o robô (rápida, para ritmo e regressão): `tools/smoke.sh 300` (partida inteira) ou `tools/smoke.sh 120 --start=boss --boons=25`.
  Outras opções: `--boons=N` (N dons sorteados), `--boss-hp=0.2`, `--stress=300`, `--title --screen=options|moves|howto`, `--hold`,
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
  (`Player.HURT_*`). `--outline=0` desliga o raio-x.
- Escala (1º teste do Daniel, "tudo é muito grande"): o cenário do KayKit é encolhido por peça em `Arena.PROP_SCALE`
  (paredes 72% da altura, escadas 0,8 x 0,55, barris 0,55, entulho 0,5 a 0,6, velas 0,7); pilares desenhados pelo raio que
  bloqueia (`RoomLayout.pillars`, 0,6 m; `Arena.PILLAR_MODEL_RADIUS`, `PILLAR_HEIGHT` 0,68). A colisão segue o modelo escalado.
  Efeitos e HUD mais discretos (números `Fx.NUMBER_SIZE` 17, HUD em `Hud`: medalhão do herói `HeroCrest` com o rosto do Explorador recortado da arte do título (`assets/ui/hud/hero_portrait.png`), vida e Magia em `HudBar` com rastro do que foi perdido, as quatro ações em losango `ActionSlot` com a tecla real, recarga num fio que corre pelo aro e translúcidas quando há alguém atrás; uma espessura de moldura `UiKit.FRAME` e `UiKit.OLD_GOLD`, sombra em todo texto, divisas para elite, guardião e chefe fora da tela). Números em `docs/arte/estetica.md`.
- Impacto de cada golpe (ciclo 7): uma fita só que afina até a cauda, com ponta de lâmina, sobre a tinta escura (`slash.gdshader`,
  `Fx.slash`), pulso curto da lâmina sem luz nova (`EmethSword.PULSE_GLOW`), talho ao longo do corte e lascas só em acerto real
  (`impact.gdshader`, `Fx.gash`, `Combat.cut_axis`; testado em `tests/test_fx_on_hit.gd`), números pálidos (esmeralda só em
  finalizador e Ômega, `Combat.number_color`), estocadas em feixe fino (`emeth_thrust.gdshader`), o especial como dardo
  esmeralda (`emeth_dart.gdshader`), o círculo de luz como aro fino com marcas girando; inimigo pisca abaixo do limiar do glow e achata, corpo arremessado ao morrer
  (`Horde.THROW`), tranco de câmera (`Fx.kick`), hit stop curto (`Feel.hit_stop_scale`) e brilho de antecipação nos finalizadores
  (`ComboNode.glint`, desenhado por `Fx.glint` na ponta da espada). Finalizadores soltam a meia-lua enorme (`Fx.crescent`) e,
  nos grandes, o quadro de impacto em preto e branco (`Fx.impact_frame`). Multidão cinza clara sobre o chão escuro, que brilha um pouco sozinha para ser lida longe da luz (`CrowdRenderer.CROWD_*`, `lift` e `flat_light` no `crowd.gdshader`); cortes em faixa larga (`Fx.SLASH_INNER`); elites com contorno escuro e fino
  (`crowd_outline.gdshader`, `CrowdRenderer.OUTLINE_*`; largura em metros do mundo) e borda de ouro velho fraca (`ELITE_RIM`); o ouro das elites é velho (`CrowdRenderer.GILD_COLOR`), nunca amarelo vivo. Detalhes e pendências em `docs/arte/estetica.md`.
- Câmera lenta no molde do Hades II (`Fx.slow_mo`: velocidade do mundo por `Engine.time_scale`, zoom, desfoque radial e
  brilho no `screen.gdshader`): último abate da sala (0,35 por 0,55 s, `Rooms.LAST_KILL_*`), golpe que derruba 3 ou
  acerta 7 de uma vez, no máximo uma vez a cada 6 s (`Combat.SLOW_MO_*`, `wants_slow_mo`; no Hades só o último abate e o chefe
  têm câmera lenta, golpes têm só centésimos), morte de Morvath; abate segura o hit slow +40 ms; a câmera
  fecha 8% enquanto o Ômega carrega (`Game.OMEGA_ZOOM`). Menus cortam a câmera lenta. Ver parado: `--lab --lab-slow`.
  Finalizadores soltam a meia-lua gigante e branca do Ember & Blade (`Fx.CRESCENT_*`), também no giro.
- Efeitos: `scripts/game/fx.gd` (partículas, cortes, anéis, feixes, números, hit stop, tremor) e shaders em `assets/shaders/`.
  Brilho pelo glow do `WorldEnvironment` (cores acima de 1 brilham).

## Primeira fase no molde do Hades II (2026-11-14)
- A partida é por salas, com a estrutura e os números da primeira região do Hades II (estudo dos dados do jogo do
  Daniel; nada de arte, nome, história ou som copiado). Notas do estudo: fora do repositório (scratchpad da sessão).
- Escala: 80 unidades do Hades = 1 m (andar 540 = 6,75 m/s; heroína de 200 de altura = paladino de 2,5 m). `U` em `make_data.gd`.
- Salas: `RunMap` (`core/run_map.gd`: abertura com dom, portas que mostram a recompensa, guardião entre as salas 4 e 6,
  uma fonte entre 5 e 8, loja na 10, Morvath na 11; **encurtado para teste**: fonte na 2, guardião na 3, loja na 4, Morvath na 5, elites desde a sala 2 (`elite_from_depth`; no Hades, 3), `_stage` em `make_data.gd`), `EncounterGen` (`core/encounter_gen.gd`: dificuldade 55 + 15 por sala,
  1 a 3 ondas, 2 a 3 tipos, no máximo 1 tipo de elite, próxima onda com 1 inimigo de pé, limite 4 + 0,35 por sala), dados
  em `data/stages/catacombs.tres` (`StageDef`, `RoomLayout`). Nó `Rooms` (`game/rooms.gd`) conduz: ondas, recompensa,
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
  (`BakedModel.painted`). Cor da magia em `EnemyDef.magic_color` (feiticeiro violeta frio, sacerdotes e Morvath roxo; verde só da
  Emeth e do portal); olhos, gemas e orbes brilham pela própria pintura (`paint_glow` no `crowd.gdshader`).
  **Elites sem créditos**: a mesma figura com o aço em ouro velho por shader (`EnemyDef.gild`, `ELITE_GILD` no `make_data.gd`,
  `gild` no `crowd.gdshader`), contorno escuro fino, borda fraca e barra de armadura; uma repintura no Meshy (10 créditos cada)
  ficaria melhor e depende do Daniel. Galeria: `tools/enemy_lab.gd` (ids opcionais para ver de perto).
  Ciclo 7 (papel de cada um pela silhueta, arma e pose, não só pela cor): avisos de preparo por `EnemyDef.tell` num MultiMesh só
  (`EnemyFx`, `enemy_tell.gdshader`, lidos de `Enemy.state_t`), campos de aparência `vivid`, `crest`, `shine`, `sway`; peças
  rígidas no assado (`rigid` em `tools/bake.gd`: escudo preso ao antebraço do Escudo); ouro da elite só no aço; armadura com
  centelhas ao absorver e estilhaços ao quebrar; Morvath violeta com coroa pálida.
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
  (`PEAK` em `make_data.gd`), o passo da corrida (`Player.RUN_CLIP_PACE`), achata o sobe e desce do quadril na corrida, mantém o braço da espada em guarda e a pegada da espada (pela linha dos nós dos
  dedos do manequim). Clipe novo: editar `CLIPS` em `tools/bake_hero.gd` e rodar
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
- Save em `user://save.json` pela camada única `Save` (regras puras em `core/save_data.gd`).
- Som: `scripts/audio.gd` (receitas sintetizadas, provisórias). Um arquivo `audio/<nome>.ogg` substitui a receita;
  `audio/<nome>_0.ogg`, `_1.ogg`... sorteia entre eles. Golpes, ossos, escudo e atordoamento usam o Kenney Impact Sounds (CC0).
  Música desligada por enquanto.

## Onde mexer
- **Elo** (mecânica das Crônicas de Eterra) = dom duplo do Hades: família `DUO` em `scripts/core/boon.gd`, dom com
  `requires` de dois outros (6 hoje; nome "Elo" no texto desde 2026-11-15). A carta mostra os dois dons de origem
  numa corrente de ouro velho com o Elo no meio (`EloLink`, `BoonState.sources`), o medalhão do Elo tem aro de elos,
  a HUD saúda cada Elo novo com "Elo formado" sem pausar (`EloBanner`) e a pausa tem o painel "Dons" (`BoonsScreen`).
  Capturas dessas telas numa partida real: `tools/ui_lab.gd` (comando no topo).
- Combos: `data/combos/paladin.tres` (nós `ComboNode`; `tags` é o que os dons enxergam). Dons: `data/boons/*.tres`
  (`Boon.slot`: um dom por ação, ATTACK/SPECIAL/CAST/DASH, o novo substitui o antigo; NONE = age sozinho, sem limite.
  Raridade sorteada por carta, `Boon.RARITY_MULT` multiplica os números com `BoonMod.by_rarity`)
  (`BoonMod`: `stat`, `tag`, `values` por nível; as estatísticas que o jogo conhece estão em `scripts/game/combat.gd` e
  `game.gd` `_take`). Inimigos: `data/enemies/*.tres`. Ondas, elites, fonte e chefe: `data/waves/catacombs.tres`.
- Morvath: `scripts/game/boss.gd` (estados) e `scripts/core/boss_rules.gd` (fases e padrões, testados).
- Colisão do cenário: pilares são círculos (`RoomLayout.pillars`); escadas, entulho e barris são caixas sólidas
  (`Arena.boxes`, pelo `solid` de `_place`). Sai-se da sala pisando no pé da escada (`Arena.exit_at`).
- Barra de vida fina sobre a cabeça de cada inimigo, como no Hades II (`CrowdRenderer.add_bar`, `life_bar.gdshader`; amarela por cima quando tem armadura; com mais de `Horde.BARS_FOR_ALL` inimigos só os feridos mostram; o chefe usa a barra do topo). A barra grande do topo é só de Morvath e dos guardiões (`Game.boss_enemy`); elites comuns não a ganham (no `--horde` ganham).
- Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`).

## Pendências conhecidas
- **Fase por salas** (padrão): o robô desce as 10 salas em cerca de 5 minutos e chega em Morvath com 4 a 7 dons;
  vence ou perde por pouco. Falta teste com gente. O modo de horda (`--horde`) ficou como estava, com os números novos.
- Diferenças do Hades que ficaram: Morvath mantém os ataques dele (não os da chefe do Hades), só a vida (6050) e o dano
  seguem a escala; sem martelo, feitiço lunar ou dom de velocidade como recompensa; a loja compra ao pisar (não há botão de
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
