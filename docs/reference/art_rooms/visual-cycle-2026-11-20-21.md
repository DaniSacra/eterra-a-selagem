> Índice: [art_rooms.md](../art_rooms.md)

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


## Atlas, marcos visuais (lote reduzido; só no estilizado; `docs/backlog.md` P.2; capturas `docs/gallery/atlas/at_crypt_b.jpg`, `at_sanct_b.png`)
- **AT-CB1 (Cripta B)**: uma luz quente de vela no acesso oeste, a única interrupção quente do ossuário frio (`CryptLook.STY_ENTRY_WARM`, `_entry_warm`, sem especular nem sombra, nunca na multidão); `test_room_style` passou a esperar 18 luzes na B estilizada.
- **AT-SE1 (Santuário B)**: dois degraus de rocha funda bem abaixo do chão do buraco com entulho em cima (`SanctuaryLook.HOLE_DEPTH_LEDGES`, `_hole_depth`, `EdgeKit.rubble`); quase não lê na Perto (o buraco é pequeno): conferir de perto.
- **AT-FB1 (Fendas B)**: três blocos pendurados em correntes sob a ruptura norte (`RiftLook.FALLEN_REMAINS`, `_hanging_remains`), além do arco e do tabuleiro que já existiam; sem captura.
- **AT-CS1**: já existe (arcos E1, correntes E2, gaiolas, ruína ao fundo); sem mudança. Os outros itens ficam para depois.
- Nada colide; sem shader nem material novo (`make_warmup` não necessário). `test_warmup` falha em `book_cover.gdshader` (do outro agente, não deste lote).
- **Lote 2 do atlas (só estilizado, sem shader nem material novo, `make_warmup` não necessário; capturas `at_rift_a.jpg`, `at_sanct_a.jpg`, `at_garden_b.jpg`)**:
  - **AT-FA1 (Fendas A)**: um pilar baixo claro em cada canto das cabeças das duas pontes, fora do tabuleiro, sobre a fenda (`RiftLook.HEAD_PILASTER`, `_head_pilasters`). Coluna caída e correntes já existiam (SW-F1).
  - **AT-SD1 (Santuário A)**: faixa de luz difusa quente ao longo da nave, entre a entrada e o feixe do guardião (`SanctuaryLook.STY_NAVE_BAND`, `_nave_band`, `key_pool`; sem sombra, só na A). Sutil na captura.
  - **AT-JB1 (Jardim B)**: poça fria fraca em volta do anel de raízes para o caminho ler contra o lago escuro (`GardenLook.STY_ROOT_PATH`, `_root_path_light`).
  - **Existe, validado só pelo código, sem mudança**: AT-JA1 (`TREE_FILL` contraluz frio, musgo `MOSS_*`, raízes `_shallow_roots`), AT-PA1 e AT-PB1 (braseiros de cabeça `HEAD_BOWL_*`, lanternas do patamar, `_old_piers`, `_far_bridges`, arcos `EDGE_ARCHES`), AT-RA1 e AT-RB1 (grade dormente e âmbar no preparo em `RunesLook`; prismas e mecanismo R2/R5), AT-GU1 (feixe e medalhões da `SanctuaryLook`, `STY_GUARD_SHAFT`), AT-FO1 (`dress_fountain`, poça fria, `RewardShaft`), AT-LO1 (tapetes, lanternas, trilha em `dress_shop`), AT-CS1 (arcos E1, correntes E2, ruína). Marcos que pedem peça nova (arco remanescente no patamar da Ponte A, ilhas em bloco das Runas B) ficam para depois.
  - Medido: `fit_probe` idêntico antes e depois (Fendas A, Santuário A, Jardim B); iGPU 720 Baixa GPU Fendas A 15,14 (antes 15,24), Santuário A 15,99 (15,81), Jardim B 16,94 (16,89); `test_room_style` e `test_visual_profile` passam.

- **Lote 3 do atlas (só estilizado, sem shader nem material novo, `make_warmup` não necessário; capturas `at_bridge_a.jpg`, `at_runes_b.jpg`, câmera do `arena_lab`)**:
  - **AT-PA1 (Ponte A)**: um arco ogival quebrado em silhueta atrás da borda norte da plataforma do meio, deslocado do centro (`BridgeLook.LANDING_ARCH`, `LANDING_ARCH_FOOT`; `EdgeKit.broken_arch`), fora do andável e longe da linha dos ataques; a visão longitudinal fica livre.
  - **AT-RB1 (Runas B)**: seis ilhas de bloco na pedra funda além das bordas sul e leste, topos de 1,4 a 3,4 m abaixo do chão, com moldura de ouro velho no topo como as lajes da A (`RunesLook.ISLANDS`, `_islands`; só na B). Lêem pouco no escuro; as do sul aparecem acima da fachada.
  - Medido: `fit_probe` estilizado idêntico antes e depois (Ponte A, Runas B); `test_room_style` e `test_visual_profile` passam; `smoke.sh 600 --seed=5` igual (kills 116, damage 22703, time 370.3, hp 39). iGPU não medido (só a GPU: lab 1,7 a 1,8 ms, sem diferença).

## Revisão de arte de 2026-11-21 (itens 1, 3, 5, 7, 8, 9; só look estilizado, via `VisualProfile.vary`)
- 1 (vazio): `abyss_fog` e `abyss_mist` ganharam `edge_fade` (0 = clássico; 0,15 no estilizado por `ArenaKit.STY_MIST_EDGE_FADE`);
  `ArenaRoom.backdrop` escurece a névoa do fundo a `STY_BACKDROP_MIST` (0,55) (hub, Cripta e todos que usam o fundo);
  Morvath: `STY_GLOW`, `STY_FOG_*` em `boss_chamber.gd` (violeta escuro, `ArenaKit.abyss_fog` agora devolve o `FogMaterial`);
  Runas: `STY_DEPTH_SINK` (parede afunda na névoa de 1 m a 5 m abaixo do piso). Sem blocos de ruína novos (pendente).
- 3: `STY_POOL_SATURATION` 0,6, `STY_BOWL_GAIN` 0,9, `paint_pool_soft` 0,07 (`paint.gdshaderinc`), `BRAZIER_COLOR` âmbar (1; 0,65; 0,3).
- 5: `STY_SHRUB_*`, `STY_CROWN_*` (`hub_look.gd`) e `STY_LEAF_*`, `STY_LEAVES/FILL/RAGGED` (`garden_look.gd`): folhas maiores, menos dentes, cor apagada.
- 7: só o desenho (`STY_TREE_VALUE` 0,78 no albedo, fill da árvore 0,18); tamanho 0,8 e deslocar o tronco mudariam a colisão `_trunk_o`: ficam com o Game Director.
- 8: Santuário piso -10% e lua -20% (`sanctuary_look.gd`); Runas `paint_quiet_value` 0,36; urnas da loja do Salão `STY_URN_TINT`.
- 9: os riscos brancos eram o pó das fendas dormentes (`hazard_fissure.gdshader`): `dust_color` agora tinta escura (0,08; 0,07; 0,07).

## Lote 4 (2026-11-21, a partir do SWORN do Daniel): armadilha de lâminas, chão rico, moldura escura
- **Bloco da armadilha** (`HazardPiece.slit(..., flight)`, `_trap_dress`): o bloco da pedra da sala ganha tampa de pedra
  (`CAP`) com três setas talhadas apontando o voo, duas órbitas escuras sobre a boca (a caveira: boca e olhos, `EYE`) e a
  lâmina de aço (`BLADE`) que sai da boca e voa a faixa inteira durante o golpe (`_strike` cai de 1 a 0), com rastro
  aditivo no vermelho do aviso (`TRAIL`, `BLADE_GLOW`); a faixa no chão continua o aviso do `Ground`. Só `arena_room.gd`
  passa o comprimento da faixa.
- **Peças âmbar**: o brilho das fendas (`hazard_fissure.gdshader` `ember_color`) vai de âmbar a laranja-vermelho
  (1; 0,36; 0,14), perto de `GroundLook.WARNING_COLOR`; o dourado velho dos chevrons fica.
- **`FloorScatter`** (SR-G1 e G3; `floor_scatter.gd`, shader `floor_patch.gdshader`): um passo `scatter` no fim do `dress`
  de toda sala (menos o Santuário-hub), só no estilizado (`ArenaKit.style_only`). Manchas de musgo e umidade (um
  MultiMesh), tufos (`dry_grass`), crânios e ossos (dois MultiMesh), potes pequenos em grupos (`POT_SIZE` abaixo de 0,3 m,
  regra do `test_room_style`), uma faixa escura em cada borda do piso (`FRAME_REACH`, `FRAME_ALPHA`) e pedras caídas
  grandes logo depois da borda sobre o vazio (`STONE_*`; 0 nas salas com parede e na Fenda, que já tem a coluna caída).
  Cada bioma em `BIOMES` (contagens e força da moldura). Nunca onde nasce o herói, diante de portas, em piso que golpeia
  (`on_hazard`), dentro de obstáculo nem no meio da luta (`CENTRE_FREE`); números aleatórios próprios (a partida não muda).
  Cerca de 6 draw calls por sala. Ainda não há cachoeira (precisa de malha e shader de água).

## Ajustes de 2026-11-21 (fim do dia)
- Árvore do Jardim só mais escura (Daniel: "só escurecer"): `GardenLook.STY_BARK`, `STY_CORD`, `STY_LICHEN` um quarto
  abaixo, `STY_TREE_VALUE` 0,62 e `STY_TREE_FILL_ENERGY` 0,1; tamanho e colisão iguais.
- Fenda: ar, névoa, brumas, luz funda e chão do violeta (matiz 255, cor de Morvath) para índigo frio (228 a 236)
  (`RiftLook.AIR`, `STY_*`), item da revisão de arte de 2026-11-21.


## Marcas da luta e musgo (2026-11-21)
- `BattleMarks` (`game/battle_marks.gd`, sob a arena): pó de osso e lascas onde um morto-vivo cai, rachadura onde um círculo
  pesado (1,8 m ou mais) acerta o chão e onde elite ou guardião cai. Sem sangue (decisão do Daniel). 3 MultiMesh, teto
  32, 72 e 12, dados próprios: a semente 5 não muda. Teste `test_battle_marks`.
- `FloorScatter`: as cores das manchas eram sRGB lidas como lineares (musgo virava grama clara); agora `srgb_to_linear`, manchas menores.
- Santuário: estação fechada sem brasa, chama nem fumaça (Forja), sem folhas (Árvore), livro fechado (`HubLook.set_closed`); os
  ciprestes da escada foram para ±9,6 e os leões do patamar aparecem inteiros.
