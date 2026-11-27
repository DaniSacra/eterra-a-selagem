> Índice: [hub.md](../hub.md)

## Refino do Santuário, rodada 1 (2026-11-26; environment-artist, SEM captura: tudo às cegas, conferir na GPU)
Pedido do Daniel: o hub estava feio ("fundo branco, paredão cinza, prédios caixa, piscina, postes pretos, bolas verdes").
Meta: ficar perto de `docs/art/ref/hub01_2026-11-25/eterra_hub/01-arte-aprovada.jpg`. Só visual: colisão, planta, pontos de uso
e `HubPlan` intactos (testes `test_hub*` passam). Arquivos: `hub_scenery.gd`, `hub_facades.gd` (novo, `HubFacades`),
`hub_blockout.gd`, `hub_look.gd`, `arena_room.gd` (gancho `cliff_material()`), shaders `hub_cliff` e `hub_vista` (novos).
- **Fundo (item 1)**: o branco era o plano opaco do abismo (`kit.abyss`, a -22 m, cor `MIST` x ruído), não o céu. `HubLook.MIST`
  agora lilás de crepúsculo `(0.44, 0.33, 0.46)` (o plano opaco fica ~0,5 disso; as três camadas translúcidas, mais claras,
  viram bancos de névoa lilás). Céu `SKY_TOP` violeta, `SKY_HORIZON` pêssego, mar `SEA_*` e as três serras `RIDGES` em
  roxo/pêssego/verde-escuro (antes azul-claro); `AIR` com névoa lilás-rosada e lua dourada (`DUSK_GOLD`), `STY_MOON` 1,05 e
  `STY_AMBIENT_GAIN` 0,98 (mais contraste, sombras seguem azuladas).
- **Penhascos (item 2)**: `ArenaRoom.cliff_material()` (gancho novo, `null` nas outras salas) devolve, no hub, o
  `hub_cliff.gdshader`: rocha quente em estratos com rachaduras, musgo/capim nos primeiros metros sob a borda, lavagem dourada
  no alto e, descendo (`CLIFF_FADE` 2 a 19 m), afunda na névoa lilás do abismo. Por cima (`HubScenery._cliffs`): tufos de
  arbusto, flores e glicínia pendendo da face (a cada 2,2 m de borda) e saliências de rocha (a cada 6 m, blocos com o mesmo
  material, musgo em cima), menos sob a ponte e as quedas. Uma queda nova no sul do Portão (`FALLS`).
- **Muretas**: balaústre baixo (`RAIL_LOW` 0,8) por todas as bordas externas que olham para a câmera ou para os lados
  (`_balustrades`: fora das atrás de prédio, da ponte e das bocas dos quartos futuros), a cada 2º poste uma lanterna;
  canteiros de pedra com flores lilás/magenta junto a elas (`_planters`, substituem os tufos soltos).
- **Prédios (item 3)**: parede em calcário creme (`HubLook.facade_stone()`, cor própria `OWN_KEEP`, no lugar do ashlar azul-cinza),
  telhas terracota mais vivas, janelas de vidro âmbar (`WINDOW_GLOW`), caixas de flores sob as janelas (antes tufos no chão),
  pilastras com base e capitel, portas abertas mostram o interior aceso (`DOOR_GLOW`), duas lanternas em cada porta
  (`HubFacades._door_lanterns`, um MultiMesh com as do balaústre). Por estação (`HubFacades`): **Aposento** = grande arco
  ogival de vidro âmbar com travessas, dois estandartes vinho com o leão, tapete vermelho com bordas douradas para o sul;
  **Biblioteca** e **Capela dos Dons** = vitral colorido (cunhas vermelho/ouro/turquesa/violeta) em arco de aduelas; Capela
  com pináculo dourado; **Alquimista** = estufa de vidro (moldura dourada, painéis, telhado de quatro águas de vidro, plantas
  em flor, luz); **Mercador** = toldo vinho e creme (`AWNING_CLOTH`, `AWNING_STRIPE`); **Ponto de Vigília** = bacia redonda
  de pedra em dois degraus (antes um bloco quadrado), estandarte vinho; **Portões das Áreas Futuras** = cadeado de ouro.
  Estandartes do Portão e da Vigília trocados pelos de `HubFacades.banner` (vinho; o `fk.banner` estilizado é petróleo).
  **Portão** = dois leões de pedra sentados (caixas) nos pés dos pilares e a vista violeta no vão (`hub_vista.gdshader`
  atrás da folha de luz: céu dourado-violeta, duas serras, estrada clara).
- **Videira (item 4)**: o tanque grande (`WATER_2`) virou **jardim elevado** (`GARDEN_BASIN`: terra a 0,36 m em meio-fio de
  pedra, flores lilás/magenta, arbustos, alguns ciprestes; é buraco do piso, ninguém anda) e a bacia pequena ficou só nas
  outras duas; **fonte redonda** no meio da pérgola, em cima do canteiro (`HubScenery._fountain`: borda em blocos, água,
  pedestal, taça, cortina e jato com `waterfall.gdshader`, uma luz quente). O canteiro (`_bed`) não põe arbustos onde a
  fonte fica (`FOUNTAIN_CLEAR`).
- **Postes (item 5)**: os de ferro preto saíram; `_lamp` agora é pilar de calcário com lanterna acesa, a cada 21 m de borda
  (antes 9,5) mais as lanternas dos balaústres e das portas (emissivo, um MultiMesh; sem luz própria).
- **Vegetação (item 6)**: nas prateleiras de rocha, 3 de cada 4 viram pares de ciprestes escuros (antes bolas verdes); árvore
  vermelha grande no canto noroeste (`RED_TREE_AT`); glicínia pendente nas paredes e nos penhascos; canteiros e jardim.
- **Chão (item 7)**: faixa de brilho dourado discreto (`_path_glow`, aditivo, 1,5 m) no caminho Vigília, Videira, Dons/Aposento
  e no ramal do Portão; só onde os dois lados são piso (verificado: 100% das amostras no piso).
- **Luz (item 8)**: crepúsculo (lua dourada, névoa lilás) e, de pontual, só 5 OmniLights novas (arco do Aposento, vitral da
  Biblioteca, vitral dos Dons, estufa, fonte; `NOT_FIRE`, `~CROWD_LAYER`, sem sombra), o resto emissivo.
- **Shaders novos (para o aquecimento)**: `assets/shaders/hub_cliff.gdshader`, `assets/shaders/hub_vista.gdshader`.
- **Opções de captura**: chegada `--hub --hub-open=all --shot-at=3`; estações `--hero-at=<portal|vendor|tree|smith|book|vine|heroes>`;
  o Aposento (arco e tapete) com `--hero-at=heroes`, o Portão com `--hero-at=portal`.
- **Ficou de fora / para a rodada 2**: rampas e escadas de verdade (o piso é plano e a planta não muda); o Aposento sem
  escada (só tapete); interiores; telhado da Forja aberto com toldo (a peça da forja ocupa a fachada); árvores de folha
  vermelha só uma; céu e serras só se veem de fato com a câmera Longe; o brilho do caminho e as cores do penhasco/névoa foram
  escolhidos sem ver, ajustar por `HubLook.MIST`, `CLIFF_*`, `PATH_GLOW`, `STY_MOON`.

## Refino do Santuário, rodada 2 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: ficar crepúsculo (a rodada 1 saiu meio-dia lavado). Só visual; colisão, `HubPlan` e pontos de uso intactos
(`test_hub*` passam). Nenhum shader novo (só `hub_cliff.gdshader` editado).
- **1 Exposição** (`hub_look.gd`): `DUSK_AMBIENT` violeta frio (0,6/0,58/0,82), `DUSK_FOG` índigo escuro, `STY_AMBIENT_GAIN` 0,62,
  `STY_MOON` 0,85, `KEY_ENERGY` 0,4, `STY_SHADOW_GLOW` violeta, pedra/piso/sombra do `STYLE` mais escuros e frios,
  `WALL_A/B` do calcário mais escuros. As luzes quentes (janelas, lanternas, fogo) ficam como estavam e saltam.
- **2 Vazio**: `MIST` índigo escuro (0,15/0,1/0,27); céu, serras e mar escurecidos (`SKY_*`, `SEA_*`, `RIDGES`); cachoeiras
  mais longas (`FALLS`, 14 a 17 m) com `FALL_MIST` violeta; copas escuras de ciprestes e árvores lá embaixo
  (`HubScenery._cliffs`, `DEEP_*`, listas `_deep_*`, `DEEP_A/B`).
- **3 Penhasco** (`hub_cliff.gdshader`): blocos facetados (`facet_size`, cada célula com luz própria e fresta escura), sombra
  fria `shade_color` (`CLIFF_SHADE`), escurece com a profundidade (`deep_dark`, `CLIFF_DEEP_DARK`), `CLIFF_FADE` 1 a 15 m,
  rocha `CLIFF_ROCK_A/B` e musgo `CLIFF_MOSS` mais escuros.
- **4 Vãos**: `HubLook.lit_opening(cor, energia, topo)` (emissão em gradiente vertical, escuro em cima, quente embaixo) nas
  portas abertas (`HubBlockout.DOOR_GLOW`, `DOOR_TOP`) e nas janelas (`HubScenery.WINDOW_TOP`, `GLASS_GLOW`). A porta aberta
  da Videira não desenha mais batentes nem lintel nem brilho (a pérgola aparece).
- **5 Telhados**: `TERRACOTTA` (1,05/0,5/0,38), beiral `FASCIA` 0,2 em `FASCIA_COLOR` escuro.
- **6 Flores**: jardim da Videira com `GARDEN_LILAC` 0,2 e `GARDEN_MAGENTA` 0,1 (antes 0,4 e 0,3), canteiros com 3 plantas
  em vez de 4, `WISTERIA_*` e `MAGENTA_*` menos saturados.
- **7 Caminho**: sem faixa; trilha de pedrinhas acesas (`_path_glow`, `PATH_DOT_STEP` 1,3, `PATH_DOT_OFFSET`, `PATH_GLOW`).
- **8 Chegada**: a Vigília ("vigil") não ganha telhado nem janelas (massa e colisão iguais), bacia aberta ao céu.
  Ficou de fora: o arco de pedra atrás da fogueira.
- **9 Portas futuras** (`HubBlockout._arched_door`): arco de aduelas, folha de madeira ogival com tiras de ferro, ombreiras e
  cadeado; escada visual do pátio com 5 degraus (`YARD_STEPS`).
- Ajuste fino: `HubLook.STY_AMBIENT_GAIN/STY_MOON/KEY_ENERGY/MIST/DUSK_*`, `CLIFF_*`, `HubScenery.DEEP_*`, `PATH_GLOW`.

## Refino do Santuário, rodada 3 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: piso quente com poças de luz, vazio menos chapado, lanternas menores, Vigília proposital, escadas de pedra, pérgola densa,
penhasco com relevo e glicínias presas. Só visual; colisão, `HubPlan` e pontos de uso intactos (`test_hub*` passam). Luzes: nenhuma
nova (as poças são malha aditiva). **Shaders editados** (nenhum arquivo de shader novo; entrar no aquecimento se já listado):
`abyss_fog.gdshader` (uniforms `rim_color`, `rim_range`, desligados nas outras salas) e `waterfall.gdshader` (uniform `vanish`).
- **1 Piso quente** (`hub_look.gd`): `STY_FLOOR_STONE` (0,8/0,66/0,56) e `STY_STONE` creme-rosados, `shadow`/`joint_cold` menos frios,
  `KEY` quente `(1,0,9,0,78)` com `KEY_ENERGY` 0,5, `STY_AMBIENT_GAIN` 0,72, escurecimento de borda a partir de `calm_radius` 40 (era 60).
  Poças: `HubGlow` (`scripts/game/hub_glow.gd`, classe nova): discos suaves aditivos (centro e 3 anéis, cor de vértice, uma malha "WarmPools"),
  vértices fora do piso são puxados para dentro. Uma por lanterna (`LANTERN_POOL` raio 2,1, força 0,34) e as das praças em
  `HubScenery.SQUARE_POOLS` (chegada e fogo, Videira, Aposento, Mercador, Dons, Forja, Livro, Portão, praça central).
- **2 Vazio**: `HubLook.MIST` índigo-azul `(0,075/0,085/0,17)`; `HubLook._abyss()` põe `MIST_RIM` violeta `(0,2/0,16/0,32)` nos planos do abismo
  com a distância (`MIST_RIM_RANGE` 46 a 150 m do meio: escuro embaixo da plataforma, mais claro no horizonte); `STY_SHADOW_GLOW` menos azul.
  Copas fundas mais claras e mais densas (`DEEP_A/B`, `DEEP_EVERY` 2,4); cachoeiras brancas (`FALL_COLOR`) que somem na névoa (`FALL_VANISH`
  0,4) e mais 3 (`EXTRA_FALLS`, escolhidas na borda sul, `EXTRA_FALL_*`).
- **3 Lanternas**: `RAIL_LANTERN_EVERY` 4 (um poste em quatro), `LANTERN_SIZE` 0,2, `LAMP_LANTERN` 0,24; âmbar `LANTERN_COLOR` com
  `LANTERN_ENERGY` 1,5, capelinha de ferro (prisma, `LANTERN_CAP`) e halo (cartão voltado à câmera, `LANTERN_HALO*`), três MultiMeshes
  ("Lanterns", "LanternCaps", "LanternHalos") sobre as mesmas transformadas.
- **4 Vigília** (`_vigil_post`, `_vigil_bed`, `_vigil_niche`): a massa virou canteiro elevado (terra, balaústre, flores, dois ciprestes,
  glicínia caindo pelas faces sul e leste) com nicho de aduelas na face sul (fundo escuro, estandarte, duas lanternas); a base da fogueira
  em dois degraus redondos de pedra creme (`facade_stone`, antes invisíveis na cor do piso). Constantes `VIGIL_*`.
- **5 Escadas futuras**: degraus em `facade_stone` creme com friso claro (`STEP_NOSING`), pátio `YARD_FLOOR` mais claro.
- **6 Caminho**: sem pedrinhas; duas fileiras contínuas de lajotas um pouco mais claras (`PATH_TILE`, `PATH_TILE_GAP`, `PATH_TILE_COLOR`,
  malha "PathTiles").
- **7 Pérgola**: telhado de folhas fechado (`PERGOLA_LEAF`, `PERGOLA_LEAF_EVERY`, metade sul mais rala por `PERGOLA_GAP` para ver a fonte),
  cachos de uva roxos pendurados (`GRAPE_*`, cartões pequenos em `add_crowns(..., hanging, card_scale)`), glicínia mais longa; água da fonte
  clara (`FOUNTAIN_DEEP/SHALLOW/SPARKLE`).
- **8 Penhasco**: pilhas de rocha que descem em degraus saindo da face (`ROCK_STEP_*`), mais saliências (`LEDGE_EVERY` 4), cortinas de hera
  pendente (`IVY_*`).
- **9 Glicínias**: `add_crowns(..., hanging := true)` vira o cacho de cabeça para baixo (largo no alto, ponta embaixo); nos penhascos o topo
  fica no nível do piso junto à rocha e o cacho tem `HANG_TALL` 2 a 3,8 m (`HANG_WIDTH`).
- Ajuste fino: `SQUARE_POOLS` e `LANTERN_POOL` (poças), `STY_FLOOR_STONE`, `MIST*`, `PERGOLA_*`, `ROCK_STEP_*`. Pontos de risco sem ver: a poça
  da lanterna da borda sai pela metade (o resto fica sobre o vazio e é cortado); o telhado da pérgola pode esconder a fonte na câmera Perto.

## Refino do Santuário, rodada 4 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: Portão virado para a câmera, vitrais góticos, cachoeiras finas, arcos pretos, faixa clara, vazio azul-noite, rochas cinza.
Só visual; colisão (`HubPlan.GATE` continua a caixa sólida de 6 m), `HubPlan` e pontos de uso intactos. **Shader novo**:
`assets/shaders/hub_stained.gdshader` (vitral). Editados: `waterfall.gdshader` (uniforms `gap`, `lip`).
- **1 Portão** (`HubBlockout._gate`, `HubFacades.gate`): a abertura olhava para o oeste (de lado para a câmera). Agora o bloco é um
  terraço baixo (`GATE_TERRACE` 0,55 m, a mesma pegada) e sobre ele a FACHADA para o sul: parede (`GATE_WALL_U` u 37,6 a 42, face em
  `GATE_FRONT` v -9, espessura `GATE_DEPTH`, crista `GATE_TOP` 5,7 < 6), arco ogival de aduelas (`GATE_W` 2,4, `GATE_SPRING` 1,5,
  `GATE_RING`), cornija, folha de luz dourada (`portal_glow` de yaw 0, mesmas luzes e `station_lights`), vista violeta no vão
  (`hub_vista`), dois estandartes vinho com o leão na parede ao lado do anel (`GATE_BANNER`), leão dourado sobre a chave
  (`GATE_MEDAL`), dois degraus até a soleira e dois leões de pedra sentados no terraço de frente (`LION_OFFSET`). A parede fica
  fora do ponto de uso (u 37, a borda oeste). Saíram a moldura solta de pilares e a coluna de luz de 16 m (`_gate_dressing`,
  `_light_column`: o cartão translúcido alto era um dos "planos soltos"). `HubBlockout.gate_apex()`/`gate_arc()` dão a curva.
- **2 Vitrais** (`hub_stained.gdshader`, `HubFacades._stained_glass`): losangos pequenos em quatro tons joia dessaturados
  (`STAINED`: âmbar, vinho, azul profundo, verde-musgo) com chumbo escuro, mainel e travessa, mais escuro na borda e aceso por trás;
  `ogive_mesh` sem cores de vértice no vitral.
- **3 Cachoeiras**: fita estreita (`FALL_NARROW` 0,55 da largura), azul pálido (`FALL_COLOR`), listras com vãos transparentes
  (`FALL_GAP`), faixa de espuma na boca (`FALL_LIP`), somem na névoa (`FALL_VANISH` 0,55), alfa `FALL_ALPHA`. Só onde o vazio à frente
  está aberto (`_open_void`: 3, 6, 9 e 12 m para fora, e 2 m de cada lado, sem piso, bacia nem pátio): a "placa branca no buraco" era
  uma queda extra na borda sul do pátio dos Dons, num vão de 1,5 m entre ele e a ponte. Teste em `test_hub_refine.gd`.
- **4 Arcos pretos**: a folha de `HubFacades.ogive_mesh` tinha o enrolamento (winding) voltado para trás (o Godot desenha o lado
  horário), era cortada e o vão mostrava o preto de trás. Corrigido (vale também para o nicho da Vigília, que ganha o fundo escuro).
  Arcos das Áreas Futuras mais baixos (`ARCH_SPRING` 0,8, `ARCH_ARC` 0,52: de 4,1 m para 3 m) e madeira mais clara (`DOOR_WOOD`).
- **5 Faixa clara**: eram as lajotas aditivas do caminho (`_path_glow`, `PathTiles`, rodada 3), duas fileiras translúcidas por cima das
  lajes. Removidas (o caminho segue gasto por `_pave_way`). Além disso `HubGlow` não estica mais vértices fora do piso para dentro (isso
  gerava triângulos longos e inclinados): descarta o triângulo que tem vértice fora do piso.
- **6 Vazio**: a causa do roxo chapado e das copas fantasmas era a névoa de altura do mundo (`WorldAir.FOG_HEIGHT_DENSITY` 0,6, cor
  `DUSK_FOG`): opaca poucos metros abaixo do piso, o que está lá embaixo (planos do abismo com `rim_color`, copas) virava só a cor da
  névoa. No hub `HubLook.HUB_FOG_HEIGHT` 0,05 (chave nova `fog_height_density` em `RoomMood.air_values`; outras salas não pedem) e
  `DUSK_FOG` azul-noite pouco saturado (0,1/0,105/0,16); `MIST` (0,07/0,075/0,14), `MIST_RIM` cinza-azulado mais claro (0,17/0,17/0,3)
  de 24 a 110 m; céu, mar, serras e `DEEP_A/B` (copas fundas, mais escuras que o plano) em azul-noite.
- **7 Rochas**: `CLIFF_ROCK_A/B` cinza-quente (0,4/0,36/0,31 e 0,23/0,22/0,24), `CLIFF_MOSS` mais verde, `CLIFF_SHADE` sem rosa.
- Ajuste fino se algo sair errado: `HUB_FOG_HEIGHT` (mais alto = mais névoa embaixo), `GATE_*`/`LION_OFFSET`/`GATE_BANNER`, `FALL_*`,
  `hub_stained` (`cells`, `lead`, `brightness`). Risco sem ver: a fachada do Portão (5,7 m) pode tapar o que está atrás dela; o shader do
  vitral ainda não foi visto; a névoa mais fina pode deixar os planos do abismo visíveis demais.

## Refino do Santuário, rodada 5 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Só visual; colisão, `HubPlan` e pontos de uso intactos; nenhum shader novo.
- **1 Arcos pretos do primeiro plano de `r4_tree`**: eram os arcos da PONTE do caminho sul (`HubScenery._bridge`), não os das Áreas
  Futuras. A linha de arranque estava em +2,2 m (acima do piso) e eles subiam até ~4,5 m na frente da câmera, com um painel preto
  (`GATE_DARK`) no vão. Agora `ARCH_SPRING` -4,1 (o anel todo abaixo da cornija, ápice ~ -0,7 m) e o vão é uma ogiva (`ogive_mesh`)
  de pedra escura (`ARCH_BACK` 0,38 do tom interno), nunca preto chapado. As portas das Áreas Futuras já tinham folha de madeira.
- **2 Estufa** (`HubFacades._glasshouse`): vidro verde-âmbar escuro (`GLASS_PANE`, `GLASS_ALPHA` 0,34, `GLASS_EMIT*` baixo), caixilhos
  de ferro escuro mais grossos (`GLASSHOUSE_IRON`, `FRAME_THICK`), telhado em duas águas (`inset` 0) com caibros em cada poste, painel
  âmbar aceso atrás das plantas (`lit_opening`) e luz interna menor (`GLASSHOUSE_GLOW`).
- **3 Portão**: folha e luzes a 60% (`HubBlockout.GATE_SHEET_DIM`), para a vista violeta aparecer; a borda dourada fica.
- **4 Portas abertas**: `lit_opening` ganhou o parâmetro `mid` (gradiente de três pontos: interior escuro na metade de cima, luz
  junto ao chão); `DOOR_TOP` 0,03, `DOOR_MID` 0,22, energia 0,8, mais faixas escuras de batente (`DOOR_REVEAL`) e soleira de pedra.
- **5 Glicínia de quina**: tufos/cortinas pendurados na borda (`_cliffs`) não nascem a menos de `HANG_CLEAR` (4 m) da chegada, de
  pontos de uso e de portas (`_near_avoid`).
- **6 Muretas e lanternas**: balaústre só onde a borda dá para o vazio (`_facing_court`: com piso de novo a 2,5 ou 4,5 m para fora,
  é vala entre pátios e fica só o lado sul); lanterna de poste ou de lampião no máximo a cada `LANTERN_APART` (6 m,
  `_lantern_free`; os lampiões das Áreas Futuras são exceção); canteiros a cada 13 m (era 9).
- **7 Rochas**: `_rock_size` (um terço alto e estreito, o resto com os três tamanhos variados), chanfro `ROCK_CHAMFER` 0,28 com
  quina quebrada, giro de até 0,5 rad e inclinação `ROCK_TILT` 0,14.
- Ajuste fino: `GATE_SHEET_DIM`, `RAIL_TRENCH`, `LANTERN_APART`, `ROCK_*`, `GLASS_*`. Risco sem ver: `_facing_court` pode tirar um
  balaústre que ainda era borda; a ponte sem o arco alto deixa o rosto sul dela mais baixo.

## Refino do Santuário, rodada 6 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
- Vitrais (`hub_stained.gdshader`, `HubFacades.STAINED`): cerca de 60% âmbar/mel (jewel_a e jewel_d), vinho e azul profundo dessaturados como acento, chumbo mais fino (`lead` 0.05), brilho 0.78.
- Vão do Portão: `GATE_SHEET_DIM` 0.3 (folha) e `GATE_LIGHT_DIM` 0.4 (luzes que douram o chão); `hub_vista.gdshader` com céu baixo, brilho do sol e estrada mais escuros, para a vista violeta aparecer.
- Portas e janelas: janelas (`WINDOW_TOP` 0.06, `WINDOW_MID` 0.25) e o arco do Aposento (`_warm_glass`) usam `HubLook.lit_opening` com interior escuro; portas abertas ganham faixa escura sob o lintel (`DOOR_HEAD`).
- Escadas das Áreas Futuras: degrau em tom quente escuro (`STEP_TREAD`), friso mais escuro (`STEP_NOSING`) e faixa de sombra no espelho (`STEP_SHADOW`).
- Canteiro da Vigília: mureta contínua com coroamento (`VIGIL_WALL`) e só 2 pilares (cantos sul), sem balaústres.
- Não feito: árvore vermelha extra e glicínia nova no Aposento/Biblioteca (já há glicínia de `_wall_flowers` onde não há peça).

## Rodada 2 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU; testes em `tests/test_hub_levels.gd`)
Pedido: níveis e escadas de verdade, escada do Aposento, flores limpas, mais uma árvore vermelha, glicínias nos beirais. A simulação segue
no plano (colisão, `FloorShape`, `NavGrid`); só os pés do herói e o desenho seguem um campo de altura.
- **Níveis** (`HubPlan`, `HubLevels`, classe nova `scripts/game/hub_levels.gd`): terraço alto (`TIER_H` 1,2) = todo o piso com v >= `TIER_V`
  (14,06): galerias, Forja, Aposento, Biblioteca (menos a bacia do jardim, que fica baixa: a borda da galeria sobre ela é o muro de
  arrimo). Dois lances de escada sobem para +v em `STAIR_STEPS` 6 degraus: `STAIR_A` (u -17..-13, v 10..14,06: o caminho da Forja, as
  duas laterais são borda do piso: contorno e bacia) e `STAIR_B` (u 1,5..12,4, v 10,4..14,06: o eixo principal, até o Aposento e a
  Biblioteca; a lateral leste é a fenda `STAIR_CUT` na planta, um buraco de 0,6 m entre o lance e a praça do Mercador, coberto por um
  parapeito de pedra). A piscina do Mercador (`WATER_3`) acaba em v 10 para não invadir o lance. `HubPlan.TIER_H = 0` desliga tudo (hub plano).
  - `HubPlan.ramp_at(p)` é o campo liso (o que levanta o desenho), `height_at(p)` o em degraus (os pés), `ground(world)`; contínuo em todo o piso
    (teste varre o piso a cada 0,25 m: nenhum salto maior que um degrau). `Arena.ground_at(p)` (só `hub` devolve algo) e `Player._ground`
    (suavizado, `GROUND_EASE` 28) põem `position.y` do herói; câmera e colisão seguem no plano. Placas de estação e luz-guia usam
    `HubPlan.anchor/ramp_at` (altura da estação); `hero_at.y` é o `position.y` do herói.
  - **Como o cenário sobe**: tudo é construído plano, como antes; o último passo do build (`HubLook.build_steps`, depois de `merge` e de
    `stylize`) roda `HubLevels.raise_steps(look)`: soma `ramp_at` aos vértices de cada `ArrayMesh` próprio (pedra fundida, piso, falésias,
    balaústres, poças), às instâncias de cada `MultiMesh`, à origem de luzes, partículas, `HubNpc` e de meshes primitivos ou compartilhados
    (barras, estátuas). Sem auditar peça por peça; ignora meshes chamados `Garden` (`KEEP_NAMES`, o solo do jardim). Passos de 60 mil vértices.
    Depois `HubLevels.stairs(look)` desenha os degraus (altura absoluta): bloco por degrau, friso e faixa de sombra no espelho (as constantes
    `HubScenery.STEP_*`), e o parapeito escalonado sobre a fenda.
  - **Aposento** (item 2): degraus de pedra creme com tapete vermelho e filetes dourados (`HubLook._hero_steps`, peça `hub_heroes_steps`,
    obstáculo sólido `HERO_STEPS` v 20..21,2, 5 degraus até `HERO_PLINTH` 0,8) e o estandarte sobre o plinto (`HERO_STAND` v 21,2..22, plinto + friso, `HeroStation` a
    `HERO_PLINTH` + 0,1). O tapete do chão (`HubFacades.CARPET_RUN`) começa no pé dos degraus (v 20). É uma escada de monumento (sólida), a porta
    do Aposento continua o vão ao lado; o ponto de uso (-1, 19) fica a 1 m do primeiro degrau.
- **Flores** (item 3): `hub_flower.gdshader` (novo) desenha o tufo inteiro num cartão: lâminas verdes pontudas e 7 flores em disco com miolo
  claro e borda escura, bordas cortadas limpas (sem ruído nem tracejado; sem `see_through`, sem sombra). `HubLook.add_blooms` (3 cartões por
  ponto, `BLOOM_*`) substitui `add_crowns` para "Flowers", "Magentas" e "Wisteria"; os discos ficam redondos pelo `squash` (altura sobre largura do cartão).
- **Árvore vermelha** (item 4): `RED_TREE_2` (u -31,6, v 6,5, 85% do tamanho) atrás do Alquimista, na falésia oeste; `_red_tree_at` desenha as duas.
- **Glicínia** (item 5): cachos do beiral mais densos e longos (`WALL_WISTERIA_EVERY`, 1,2 a 2 m) e cortinas nos dois cantos da frente
  dos telhados da Biblioteca, do Aposento, da Forja, da Capela e do Mercador (`_cascades`, `CASCADE_*`: 3 cachos de 2,2 a 3,4 m escalonados),
  fora de portas, arcos e estações; cachos agora são o tassel de `hub_flower` (flores em fila que afinam e balançam).
- Testes: `test_hub_levels.gd` (campo, degraus, sem salto, `Arena.ground_at`, hub construído levantado, degraus desenhados); `test_hub_sv`
  (4 buracos: 3 bacias e a fenda) e `test_hub_ui` (a placa livra o herói na altura dele) ajustados. Shader novo: `hub_flower` (conjunto de aquecimento refeito).
- Ajuste fino: `HubPlan.TIER_H/TIER_V/STAIR_*`, `HubLevels` (`TREAD_THICK`, `PARAPET_*`), `HubLook.BLOOM_*/TASSEL_*`, `HubScenery.CASCADE_*`, `RED_TREE_2`.
  Riscos sem ver: a fatia de piso entre o parapeito e a praça do Mercador; balaústres/falésias nas laterais dos lances seguem a rampa lisa
  e os degraus em bloco ficam por cima (pode aparecer o chão liso entre eles); o solo do jardim (`Garden`) na borda sul fica 0,84 m abaixo da
  galeria (muro de arrimo = a falésia); coisas criadas depois do build (nada conhecido) ficariam sem a altura.

## Rodada 3 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU; lista em `docs/art/ART_REVIEW_2026-11-26b.md`)
Os 10 itens do art-director. Tudo provisório (formas simples).
1. **Praça baixa no lugar do abismo** (`HubPlan`, `HubLevels`, `HubScenery._plaza`): o recorte do `OUTLINE` entre os dois corredores das Áreas
   Futuras segue como está (paredes do recorte = borda do piso com corrimão); dentro dele há um piso novo, `PLAZA` (0,4 m `PLAZA_GAP` para dentro
   das paredes, então uma fresta de vazio separa a praça dos corredores e do caminho do Portão), `PLAZA_DROP` 1,2 abaixo do terraço baixo, com
   dois lances largos (`PLAZA_FLIGHTS`, 6 degraus, descem para -v a partir de v -8,2, lado da Videira), um jardineira de pedra entre eles
   (`PLANTER_BOX`, obstáculo `hub_planter`) e um canteiro grande de flores no meio (`PLAZA_BED`, `hub_plaza_bed`). `floor_polys()` junta
   (`merge_polygons`) contorno, praça e lances num piso só (sem buraco novo: o espaço entre os lances é piso sob a jardineira, uma aba de
   `PLAZA` sobe até v -8,3). Campo de altura: `ramp_at` ganha `_plaza_ramp` (lances lisos e `PLAZA_DROP` em `PLAZA_LOW`), `height_at` os degraus
   (descendo). `HubLevels` agora também abaixa o que está na faixa da praça (`PLAZA_FOOT`..`PLAZA_TOP`) e `stairs` desenha os degraus
   (`_plaza_flights`). Decoração do cenário some perto da praça (`HubPlan.near_plaza`: plantas, pedras, hera, corrimão da própria praça; o corrimão
   das paredes do recorte fica, olhando para baixo); lampiões e flores da praça em `_plaza`. `EXTRA_FALLS` 0: cachoeira só em `FALLS` (u >= 16).
   `PLAZA_DROP` 0 devolve o chão plano. Sem mudança em portas, `USE`, `ANCHOR`, `ARRIVAL`, `HubGate`; os pátios das Áreas Futuras continuam a -1,2
   (no mesmo nível da praça). Segurança: a praça é alcançável só pelos lances; as Áreas Futuras seguem fechadas (as portas estão nos corredores, a 0).
2. **Videira, gazebo redondo** (`HubScenery._pergola`, `GAZEBO_*`): anel de 8 colunas creme em volta da fonte, cornija de pedra, coroa de folhas
   aberta sobre a fonte e mais rala para a câmera, cachos e uvas entre as colunas; piso: degrau redondo de pedra (`HubLook._bed`, `GAZEBO_DAIS`),
   sem terra escura; fonte mais larga (`FOUNTAIN_BASIN` 1,9). O pórtico de pedra saiu (`_vine_arch`: só o vaso numa base redonda; o colisor
   `VINE_ARCH` fica). Não mexi no `USE` da Videira (-7, -5, a 2,3 m do vaso, dentro do foco de 2,2 m do vaso... a conferir na captura).
3. **Piso**: `STY_FLOOR_STONE` (0.86, 0.75, 0.58), `slab_hue` 3, lajes de 0,6 m (`HUB_SLAB`, era 1,2) e juntas de 0,03 (`HUB_JOINT`).
4. **Fundo**: céu `SKY_TOP` azul só no alto, `SKY_HORIZON` lilás; falésia cinza-lilás (`CLIFF_ROCK_*`) e rocha em pé atrás das bordas oeste e norte
   (`HubScenery._backdrop`, `BACKDROP_*`: blocos de 6 a 9,5 m, musgo e cipreste no topo).
5. **Flores** (`HubLook.BLOOM_*`): 0,6 de altura, 14 flores por tufo, largura `BLOOM_CLUMP` 1,0; três tons por canteiro (roxo, magenta, creme 15% `CREAM_SHARE`).
6. **Balaustrada fina** (`HubScenery._thin_rail`, `RAIL_*`): pilar 0,5 m, 0,8 m com o capitel, corrimão creme (pedra de fachada), balaústres pequenos,
   lanterna a cada 4 pilares.
7. **Hera e ciprestes**: `IVY_EVERY` 4; nenhum cipreste a menos de `PATH_CLEAR` 3 m dos caminhos (`_clear_cypresses`).
8. **Ponto de Vigília**: arco ogival alto (vão 2,4, 3 m) num pano de parede (`HubPlan.VIGIL_ARCH`, obstáculo `hub_vigil_arch`) logo a oeste do braseiro,
   voltado para a praça, com dois estandartes e lampiões (`_vigil_niche`, `VIGIL_ARCH_*`). O nicho baixo antigo saiu.
9. **Folhagem**: `IVY_A`, `TREE_DARK`, `LEAF_DARK`, `CYPRESS_A` e o cipreste do cenário mais claros (~30%); `STY_CROWN_RAGGED` 0,08.
10. **Toldo do Mercador**: vinho `AWNING_CLOTH` e creme `AWNING_STRIPE` (0.9, 0.82, 0.68).

## PM-2 (2026-11-26 noite; environment-artist, SEM captura: conferir na GPU)
- Fundo (item 4): `HubLook.MIST` (o plano opaco do abismo e a névoa das falésias) e `MIST_RIM` de azul-marinho para lilás
  `(0.2, 0.18, 0.3)` / `(0.38, 0.31, 0.48)`; mar de nuvens `SEA_FAR`/`SEA_NEAR` lilás, `SEA_CLOUD` 1,2 e escala 0,11 (mais
  mancha); céu `SKY_TOP` mais azul e `SKY_HORIZON` lilás. Novas serras a oeste, `RIDGES_WEST` (cartões virados para leste em
  u -38, -58, -92, `_ridge_card`), para o vazio ao lado do piso não ser liso. Se o canto esquerdo da `r8_arrive` ainda sair
  chapado, subir `SEA_CLOUD` ou aproximar a primeira serra.
- Folhagem (item 9): `IVY_A` e `TREE_DARK` com o valor subido cerca de 30% (sombra oliva), cipreste `CYPRESS_SHADE` 1,2 (era
  0,95), borda das folhas `STY_CROWN_RAGGED` 0,05 (era 0,08).
- Hera e cipreste (item 7), nicho em arco (8) e Portão de lado: já feitos na rodada 3 (`IVY_EVERY` 4 só nas bordas, `VIGIL_ARCH`,
  `GATE_WALL_H`); só conferir nas capturas.

## PM-2, rodada 2 (2026-11-26 noite; environment-artist, SEM captura)
- Fundo: duas serras novas a leste (`HubScenery.RIDGES_EAST`, u 76 e 120, viradas para oeste) para o vazio depois do Portão não ficar liso; as do oeste e o paredão norte (`_backdrop`) já existiam. Hera, folhagem, nicho em arco da Vigília e Portão de lado já estavam feitos (rodadas 3 e PM-2); só conferir.
- Capturas: `tools/gpu.sh shot x.png --hub --shot-at=4`, `--hub --hero-at=portal`, `--hub --hub-open=all --shot-at=3`.
