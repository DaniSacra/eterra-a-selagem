> Índice: [art_rooms.md](../art_rooms.md)

## Salão, C1V item 2.1 (Lote N1, 2026-11-22; `docs/art/identidade_c1v.md`)
Só no perfil estilizado (F7 mostra o clássico como antes; `--smoke` com a mesma semente dá o mesmo `RESULT`). Números em constantes `STY_*`/`ELUN_*` de `catacomb_hall.gd`, ainda sem medida em captura (ajustar pela imagem):
- **Sombra colorida**: uniforme `paint_shadow_glow` (padrão preto) em `paint.gdshaderinc`, somado só pela luz direcional na faixa de sombra; chave de estilo `shadow_glow` (`STY_SHADOW_GLOW` = (0.30, 0.29, 0.66)), passada por `ArenaKit.paint_look` (`STONE_KEYS`, `FLOOR_KEYS`, `KIT_KEYS`).
- **Vinheta de cena**: uniforme `paint_vignette_set` (força, início, fim; força 0 = hoje) aplicado no albedo da pedra, do chão e do kit pela posição na tela (`paint_vignette`), nunca em figuras, efeitos nem interface; `STY_VIGNETTE` = (0.5, 0.5, 1.3). O abismo e a neblina têm shader próprio e não entram.
- **Chave morna**: spot difuso sem sombra (`_elun`), #F2C890, energia `STY_WARM_ENERGY` 2.4, poça de 7 m em (-4.5, -1.0), vindo de cima à esquerda.
- **Facho de Elun** (revisão 2: inclinado 25 graus, corpo 0,08, uniforme `from_above`, sem base cortada; chave morna 7.0 em (-6.5, 1.5); sombra e vinheta mais fortes): cilindro com `beam.gdshader` (novos uniformes `brush_break`, `brush_size`, `dust`, `dust_*`, todos 0 nos outros feixes) em (-8, -7), 26 m, marfim-ouro `ELUN_LIGHT`, borda desfiada por pincel em mundo, poeira dourada que sobe, abre em volta do herói pelo `hero_hole`. O feixe da Fonte (`RewardShaft.fountain_tint`) passa a matiz 40 só no estilizado.
- **Neblina com forma**: `abyss_mist.gdshader` ganhou `brush`/`brush_scale` (0 = hoje); os bancos do Salão ficam em faixas pinceladas (`STY_MIST_BRUSH`) e o plano mais perto escurece (`STY_MIST_NEAR`).
Fora desta rodada: `RoomMood` (o Salão não tem ar próprio; mexer ali muda as outras salas) e `abyss_fog.gdshader`. Teste: `tests/test_visual_profile.gd`.

## Cripta e Fenda, C1V Lote N2 (2026-11-23; `docs/art/identidade_c1v.md`)
A receita do Salão (item 2.1), só no estilizado, pelos mesmos uniformes (`shadow_glow`, `vignette` no `STYLE` de cada sala; a vinheta é a do Salão, `CatacombHall.STY_VIGNETTE`) e a chave morna do Salão (`STY_WARM_KEY`, energia 7, 7 m):
- **Cripta** (`crypt_look.gd`): sombra `STY_SHADOW_GLOW` (0,20; 0,50; 0,55), matiz alvo 184 a 194; chave morna por `key_pool` no meio da sala deslocado `STY_WARM_SHIFT`. Uma luz a mais (teste `test_rs_c1_lights`: 17 e 19).
- **Fenda** (`rift_look.gd`): sombra `STY_SHADOW_GLOW` (0,55; 0,40; 1,0), matiz alvo 246 a 260; chave morna sobre o campo `STY_KEY_POOLS[STY_WARM_FIELD]` (o do meio, entre as pontes).
- Fora desta rodada: facho de Elun e neblina com pincel (não coube na composição sem medida em captura); a Ponte (`bridge_look.gd`) não entrou. Números sem medida: ajustar pela captura.
- Abrir cada sala: `--arena=crypt` e `--arena=rift` (`--variant=0|1`); `--showcase` só enquadra o Salão.

## C1V Lote N3: a receita nas outras salas (2026-11-23; `docs/art/identidade_c1v.md`, paletas em `plano_pintado_a_mao.md` 5)
Só estilizado, sem medida em captura (ajustar pela imagem). Cada `STYLE` ganha `shadow_glow` e `vignette` (a do Salão, `CatacombHall.STY_VIGNETTE`; a do hub mais suave, (0,5; 0,45; 1,3)) e, nas salas de luta, a chave `c1v`: `ArenaRoom._c1v_light` (no fim de `_stylize_steps`) põe a chave morna do Salão (`key_pool`, deslocada do meio por `warm`, energia vezes `energy`) e, com `shaft`, o facho de Elun (`CatacombHall.elun_shaft`, agora estático) a no mínimo `C1V_INSET` m da borda do piso.
| Sala | `shadow_glow` | chave morna (energia) | facho |
|---|---|---|---|
| Ponte | (0,45; 0,40; 1,0) | meio, x-3 (0,8) | não (plataformas estreitas, já têm poças) |
| Jardim | (0,20; 0,42; 0,30) | meio, x-3 (1,0) | sim |
| Santuário | (0,15; 0,40; 0,62) | meio, x-3 (0,7) | não (já tem os seus fachos) |
| Runas | (0,45; 0,40; 0,85) | meio, x-3 (0,7) | não (não cobrir lajes acesas) |
| Altar | (0,50; 0,25; 0,35) | meio, x-4 (0,6) | sim |
| Provação | (0,55; 0,30; 0,75) | meio, x-3 (0,7) | não (lilás da maldição) |
| Hub | (0,15; 0,40; 0,55) | não (cada estação tem a sua poça) | não |
- **Câmara de Morvath: não entrou.** Ela não passa por `ArenaKit.paint_look` (chão `chamber_floor` e pedra clássicos sem `paint_vignette`); paleta e vinheta pedem levar o chão e a pedra dela ao pipeline pintado (outro lote, com o dono do `boss_chamber.gd`).
- `--smoke=90 --seed=5`: `RESULT` igual antes e depois (sem fps/step_ms). Cada sala ganha 1 luz (spot sem sombra): conferir o `step_ms`/fps na GPU.
- Capturas (uma por vez, Perto, estilizado): `tools/gpu.sh shot <out> --bot --autopick --seed=5 --arena=<bridge|garden|sanctuary|runes|altar|trial> --variant=0 --shot-at=9`; hub: `tools/gpu.sh shot <out> --start=hub` (conferir a opção do hub no `docs/reference/hub.md`); Câmara: `--start=boss`.

## Salão, laboratório do pacote 2026-11-23

Pacote do Daniel em `docs/art/ref/salas_2026-11-23/` (imagem 01 = o Salão). O Salão já seguia a composição da imagem de
referência anterior (fachada com portal, leões, balaustrada, abismo), então o laboratório mexeu só no que o pacote e as
regras do projeto pedem de diferente. Geometria de jogo intacta (mesmo `RESULT` do `--smoke=30 --seed=5 --nosave`).
- **Veio da pintura:** o emblema do leão no meio do chão, como moldura de pedra com o leão em relevo.
- **Adaptado (regras sobrepõem a imagem):** o medalhão redondo (anel de 16 pedras + rosa de 8 pontas + rosácea) virou uma
  faixa QUADRADA de 16 pedras alinhada aos eixos da sala (`SQUARE_FIT` em `catacomb_floor.gdshaderinc`; sem pontas nem
  rosácea), com o leão dentro numa laje de túmulo quadrada (`CatacombHall.EMBLEM_SIDE`, 1ª laje de `_frames`, reaproveita
  `ArenaKit.framed_slab` GRAVE com marca; `framed_lion_span` = `EMBLEM_LION_SPAN`). Círculo no chão é só do Morvath. A laje
  de túmulo do caminho do portal perdeu o leão (um só leão no chão). Sem folhagem vermelha (nada no Salão tem; o carmim
  fica nos estandartes) e portal só no esmeralda que já existia.
- **Quebráveis:** o Salão já tem 10 peças (`tests/test_breakables.gd`).
- **Fica para depois (precisa de olho na GPU):** conferir massas de luz e a leitura do quadrado na captura; fogo/bordas
  como na pintura (heras âmbar/musgo nas colunas da frente) só se a captura pedir.
- Shader mudado (`catacomb_floor.gdshaderinc`): nenhum material novo; `tools/make_warmup.sh` na GPU por segurança, pois o
  código do shader do chão mudou (a lista de aquecimento é a mesma).
- Teste: `tests/test_hall_artpack.gd`.

## Cripta B, Jardim B e Fendas, laboratório 2 do pacote 2026-11-23
Detalhe, plantas e listas em `docs/art/salas_pacote_2026-11-23_cripta_jardim_fendas.md`. Só estilizado, geometria de jogo intacta.
- **Cripta B:** a primeira moldura elevada do ossário é uma laje quadrada com o leão (`CryptLook.STY_LION_FRAME_B`); guarda: só quando há muro divisório.
- **Jardim:** patches de flores claras (`Masonry.blossoms`, `GardenLook.BLOSSOM_*`) no pé do muro norte e em volta do tronco; sem vermelho nem violeta.
- **Fendas:** estandarte do leão em haste sobre o pilar norte da cabeça oeste de cada ponte (`RiftLook.HEAD_POLE`, `HEAD_BANNER`).
- Capturas por fazer na GPU (sem medida em imagem). Teste: `tests/test_rooms_artpack.gd`. Aquecimento: nenhum shader nem material novo de shader; `make_warmup.sh` não precisa.



## Casas dos guardiões, look próprio (2026-11-23)

`GuardianLook` (`scripts/game/guardian_look.gd`, classe única, uma variante por casa) desacoplado de `CryptLook`:
`&"armory"` (Salão do Cavaleiro) e `&"chapel"` (Câmara do Ancião), ids em `RoomLayout.look` (`tools/make_data.gd`
`_guardian_house(..., look)`, regerar com `-- stage`), registrados em `ArenaRoom.LOOKS`/`make()`, `BREATH` e
`FloorScatter.BIOMES`. Planos com vista de cima, essencial e clima em `docs/art/guardian_knight_hall.md` e
`guardian_elder_chamber.md`. Casca compartilhada: paredes altas norte/oeste (`ArenaRoom.wall`), sul/leste baixas
(`cut_wall`), corte NE em parede alta, arco e degraus da entrada oeste; tudo atrás da borda ou acima de 2,6 m
(`tests/test_guardian_look.gd`). Sem peças novas de shader: sem necessidade de `tools/make_warmup.sh`. Provisório:
adereços (racks, armaduras, altar, atril) são caixas e cilindros do `Masonry`; luz da janela usa `moon_shaft`
(inclinação fixa `SHAFT_LEAN`).

## Casas dos guardiões, look próprio (2026-11-23)

`GuardianLook` (`scripts/game/guardian_look.gd`, classe única, uma variante por casa) desacoplado de `CryptLook`:
`&"armory"` (Salão do Cavaleiro) e `&"chapel"` (Câmara do Ancião), ids em `RoomLayout.look` (`tools/make_data.gd`
`_guardian_house(..., look)`, regerar com `-- stage`), registrados em `ArenaRoom.LOOKS`/`make()`, `BREATH` e
`FloorScatter.BIOMES`. Planos com vista de cima, essencial e clima em `docs/art/guardian_knight_hall.md` e
`guardian_elder_chamber.md`. Casca compartilhada: paredes altas norte/oeste (`ArenaRoom.wall`), sul/leste baixas
(`cut_wall`), corte NE em parede alta, arco e degraus da entrada oeste; tudo atrás da borda ou acima de 2,6 m
(`tests/test_guardian_look.gd`). Sem peças novas de shader: sem necessidade de `tools/make_warmup.sh`. Provisório:
adereços (racks, armaduras, altar, atril) são caixas e cilindros do `Masonry`; luz da janela usa `moon_shaft`
(inclinação fixa `SHAFT_LEAN`).

## Pente fino lote C (2026-11-25, `docs/art/ART_REVIEW_2026-11-25_sweep.md` itens 3, 8, 17 e chegada; só estilizado, sem shader novo)
- **Vazio das casas dos guardiões** (salas 5 e 10): `GuardianLook.BACKDROP` de cinza-azulado claro (0,3; 0,34; 0,44) para o azul escuro da sala (0,075; 0,09; 0,125), pedra e aresta junto. Jardim (sala 8): `STY_MIST`, `STY_GLOW` e `STY_WEST_MIST_COLOR` escurecidos (o plano oliva aceso eram esses bancos e o brilho do abismo).
- **Chegada**: o obelisco sul do Salão não é desenhado nem colide na Antessala (`CatacombHall._is_ante`: o layout com `hazard`, a variante 1 do `hall`). Cristais da chegada (`ArrivalScene`, só visual): faces mais fundas (`CRYSTAL_DEEP` 0,28, `CRYSTAL_EDGE` 1,0), halo aditivo em cada um (`CRYSTAL_HALO*`) e uma luz esmeralda sobre o anel (`CRYSTAL_LIGHT`). Feixe: mais estrias (`BEAM_STREAK*`) e poeira subindo (`DUST_*`, um `CPUParticles3D`). Cristais do Jardim: `crystal_edge.gdshader` ganhou brilho que corre pela pedra (`shimmer*`), faces mais escuras, aresta mais forte (`face_glow` 0,05); `GardenLook.CRYSTAL_GLOW` (0,2; 0,24).
- **Peças provisórias**: mecanismo da sala 9 (a "gaiola", `RunesLook.MECH_*`) com laje de fundo grossa (`MECH_BACK_DEPTH`), barras mais grossas e ouro envelhecido; as riscas das colunas em repouso escuras (`STY_GROOVE_REST`); água do Jardim com espuma apagada nas lâminas do lago e das poças (`GardenLook.SHEET_PALE`); toco de vela apagada em cinza de fuligem com topo queimado (`Masonry.BURNT_WAX`, `BURNT_TOP`). As lajes claras da sala 9 são o golpe das Runas (sinal de perigo, `ground_look`/`rune_tiles`): não mexidas.
- **Ar da Fenda** (sala 4): sombra, pedra, névoa e ambiente do violeta (255) para azul (cerca de 228): `RiftLook.STY_SHADOW_GLOW`, `STYLE`.

## SL-01, Sala 01 Salão das Catacumbas refeita (2026-11-25; pacote local `docs/art/ref/sala01_2026-11-25/`, o `PROMPT-CLAUDE-CODE.md` manda; layout `hall`)
Primeira sala do grande ajuste de layout. Vale para toda sala que reusa o `hall` (fonte, loja, Antessala), com o perfil CLASSIC reversível salvo no que é de função (portas, símbolos).
- **Símbolos fora (território inimigo):** o piso não tem medalhão, moldura nem leão (`floor_plate` sem `ring_radius`; `_frames()` devolve `[]`; `MEDALLION*`, `EMBLEM_*` e `STY_FRAMES` saíram, `MIDDLE_AT`/`MIDDLE_CLEAR` guardam o centro calmo e a folga das peças soltas). Os estandartes são de carmim gasto sem insígnia (`Emblem.NONE`, `BANNER_CLOTH`; `ArenaKit.banner` ganhou o parâmetro `cloth`). A estátua gigante do oeste, sua pilha, brasa e luzes saíram; no lugar `_west_arcade` (duas fileiras de arcos de pedra do fundo, um vão caído, banco de névoa fria) e a ponte e as ruínas que já existiam. O verniz verde do portal (`HallLife` `_stain`) e a luz de derramamento sumiram com o portal.
- **Portas (`05-portas.md`):** duas portas na parede norte, D1 (7,6) e D2 (11,8), ao rés do chão, 4,2 m entre os centros, vão de 2,4 m, 3,6 m até o ápice, 1,1 m de alvenaria entre as molduras (`CatacombHall.DOOR_*`, `_door_wall`). A parede encosta na borda do piso (`DOOR_WALL_Z` -15,3), em pedra sem colisão: a borda do piso é o limite. Cada vão tem batentes que forram um recuo de 1,2 m, anel de aduelas, tampa preta no arco e fundo preto neutro sem emissão (`DOOR_BLACK`), e `HallDoor` (`scripts/game/hall_door.gd`): duas folhas de madeira escura com ferragens, fechadas e sólidas; só `Arena.open_exit(i)` (chamado por `Rooms._leave`, a porta escolhida) as abre, 90 graus para dentro do recuo, em 0,45 s. A outra segue fechada. Três estados: combate (as duas fechadas, sem sinal), pronta (fechadas, `RewardGem`/`DoorSign` à frente de cada uma), escolhida (só ela abre sobre o preto). A ordem é a do mapa (porta i = `next_rooms[i]`); a contagem não mudou (duas portas mais a escada sul quando há três; a escada lateral leste, seu vão, zona e âncora saíram, o parapeito leste corre inteiro).
- **Sinais:** `Arena.exit_medals` põe a âncora de cada medalhão a 2 m à frente da porta (`DOOR_SIGN`: altura 2,6, texto a 0,5), `exit_rod = false` tira a haste (flutuam livres) e `exit_sign_up`. A zona de uso (`DOOR_ZONE`, 3 x 2,6 m) é piso andável diante da parede; ninguém passa para além dela.
- **Chão (só estilizado, `_ground`, nó `HallGround` de `style_only`):** córrego raso andável a oeste pela linha do JSON (largura 0,55 a 1,4, Catmull-Rom) e duas poças, `assets/shaders/shallow_water.gdshader` (shader novo, no aquecimento; ondulação que entorta a normal, brilho dourado fraco, borda quebrada, sem espelho), margem úmida e musgo (`HallLife.decal`); entulho baixo O1 a O3 (`RUBBLE_PILES`, blocos de até 0,28 m na `kit.styled()`, musgo embaixo). Nada disso tem colisão nem penalidade. `HallLife`: heaps e laje solta saíram do caminho da água.
- **Luz local (só estilizado):** luz dourada principal vinda de noroeste (`STY_WARM_FROM` (-22; 18; -20) mirando o centro, raio 8) e preenchimento frio fraco (`STY_COLD_FILL`, omni sem sombra em (0; 14; 10), não no navegador). Câmera, exposição global e materiais compartilhados intactos. A paleta de pedra e piso (petróleo, ajustada nas revisões anteriores) ficou como estava: a afinação para o "Último Esplendor" depende das capturas da GPU.
- **Desvios do pacote:** a âncora do sinal ficou a 2,6 m de altura (2,1 deixava o disco de 2,8 m deitado sobre o batente); as folhas abrem para dentro (a parede tem recuo), não em fachada; a rua das estátuas da doca ficou três (uma por nicho) em vez de duas ao lado do portal; as fendas e tochas externas das portas são o braseiro do píer NE e as velas já existentes (sem tocha nova); loja e fonte: a pilha de caixas do pé leste dos degraus passou ao lado leste da escada e o pano da loja (`SHOP_CLOTHS`, `SHOP_URNS`) acompanha. A Antessala segue sem obelisco sul.
- Testes: `tests/test_sl01_hall.gd` (portas, zonas, âncoras, três estados, escada leste, água, entulho), `test_hall_artpack.gd` (sem medalhão, moldura nem leão), `test_hall_life.gd`, `test_room_style.gd`, `test_arena_layout.gd` ajustados.

## E4 (2026-11-25): canal, portas grandes, Cripta SL-02
- **Canal (`scripts/game/canal.gd`, `Canal`)**: uma peça só para o rio do Salão (`CatacombHall._ground`) e o riacho de esquiva da
  Antessala (`GapFloor`), para parecerem o mesmo canal: musgo e umidade, meio-fio de pedra baixo (`KERB_HEIGHT` 0,11) nas duas
  margens (o piso é uma placa só; o rebaixo é lido pelo meio-fio e pela sombra da beira no shader), água de
  `shallow_water.gdshader` com sombra de beira (`rim_shadow`) e reflexo em riscos (`reflect_*`, `view_yaw`). Vaus: trechos sem
  meio-fio (`WATER_FORDS`). Na Antessala (`layout.gaps` não vazio) o rio começa ao sul do riacho e a primeira poça sai.
  O meio-fio é só visual (nada colide); o riacho de esquiva usa as mesmas peças em água mais escura.
- **Portas grandes (PT-25-10)**: `HallDoor.doorway` monta a porta inteira (batentes, soleira, anel de aduelas, preto, duas folhas
  com tábuas, tiras e argola). Salão: `DOOR_CLEAR` 3,0 x 5,2, moldura 0,3, 1,2 m de vão entre as aberturas; o medalhão
  (`DOOR_SIGN`: 0,05 à frente da borda, altura 2,55) fica DENTRO do vão e o texto logo abaixo (`DOOR_SIGN_TEXT` 0,8). Cripta:
  as mesmas portas na face da parede norte (`CryptLook._north_door`), `ArenaExit.medal_up` 2,5 / `sign_up` 0,8 (`CRYPT_MEDAL`),
  sem degraus nem grade; a porta fora de uso é parede lisa; `Arena.open_exit` abre a escolhida (`ArenaRoom.open_door_leaves`).
  Mouth 3,0 m (`CRYPT_DOOR`); a terceira porta foi de -2,0 para -3,0 (`CRYPT_THIRD`) para a urna de óleo (-1,6; -10) não fechar a boca.
- **Salão, mais detalhe (`CatacombHall._detail`)**: faixas de musgo no pé das paredes, folhas secas em um só mesh
  (`LEAF_DRIFTS`), velas apagadas e potes nos cantos e ao pé das portas; nada colide nem passa de 0,3 m, o miolo fica livre.
- **Cripta SL-02**: colisão e perigos das variantes A e B mantidos (os sarcófagos e colunas da planta do pacote não foram
  movidos: os perigos e testes se apoiam neles). Nichos do norte em -9,6 e -6,4 (as portas ficam entre eles). Braseiros da parede norte
  entre as portas (4,9) e a leste (9,7). Fonte quebrada no nordeste (`CryptLook._fountain`): muro em ruína atrás da borda leste,
  bica, queda (`waterfall.gdshader`), bacia rasa (-0,5 de borda quebrada, 2,4 x 2,4 em (10,6; -3,4), deslocada da (10; -4,4) do
  pacote para não cair em cima da laje e da urna), escoamento a sudoeste, um ponto frio de luz. Água andável e sem efeito.
- Testes: `tests/test_sl02_crypt.gd`; `test_sl01_hall`, `test_pt2_door_medallion`, `test_room_style` seguem as portas e a luz nova.

## Salão, revisão 2026-11-26 (environment-artist)
- Rio largo (`WATER_WIDTH` 2,4 a 3,3 m) e a linha termina na mureta oeste (-14,2; 13,4); continua andável (`test_sl01_hall`).
- Obelisco sul movido para x 1,0 (antes -2,6, no meio da tela sobre a chegada) e baixado a 2,0 m (colisão igual).
- Muretas do lado sul mais baixas (`SOUTH_RAIL_LOW` 0,7, parâmetro `low` de `Masonry.balustrade`) para não tapar o herói; a
  mureta sul agora começa no fim do patamar (`LANDING.y`).
- O herói nasce na borda esquerda da tela: a chegada é no patamar (x -11,6, z 18,1) e a câmera é limitada pelos limites da
  sala; é posição/câmera (gameplay), só anotado.

## QW-3 e QW-4 (2026-11-26 noite; sem captura)
- Aviso da pedra que cai: no ramo `drop` do `ground.gdshaderinc` o preenchimento ganhou gradiente (mais claro perto da borda),
  mancha de ruído e uma rachadura; a borda e o ritmo do aviso ficam iguais.
- Torres da ponte: `abyss_ruins.gdshader` ganhou `paint` (mancha de pedra) e `paint_foot` (escurece para o pé); a ponte liga com
  `RUIN_PAINT` 0,45 e `RUIN_PAINT_FOOT` 0,5. Os outros cartões ficam em 0 (iguais).
- Runas: `STY_REST.paint_quiet_value` 0,36 para 0,3 (a pedra calma, o "xadrez" claro, menos clara). Sem captura: conferir.
- Água e musgo (`shallow_water.gdshader`, `Canal.water`): `glint` 0,05, `sheen` 0,035, `reflect_amount` 0,15, `roughness` 0,6
  (valores de compat também abaixados), para o vermelho e os avisos lerem por cima.

## PT-6 e PT-11, arte (2026-11-24, `environment-artist`; sem captura na GPU ainda)
- **Portão da entrada ao sul** (`ArenaRoom._way_in`, `way_in_edge`, constantes `WAY_IN_*`): em toda sala de `ArenaRoom` (cripta, fendas, jardim, ponte, runas, santuário, guardiões, provação, altar), na borda sul atrás de `hero_spawn`: soleira de pedra, dois marcos baixos e a grade de ferro das portas não usadas fechada (`TombKit.grille`), sem luz nem medalhão (lê como o portão que fechou, nunca como saída). Tudo na borda ou além dela (nunca sobre o chão aberto; `test_rs_c7`), fora da colisão. Não aparece se a borda sul está a menos de 1,2 m ou a mais de 6 m do ponto de partida. O Salão (loja, fonte) segue com a escada da própria composição.
- **Arcos selados do oeste removidos**: `CryptLook` (abertura, `_entry`, luz quente `_entry_warm`), `GuardianLook`, `RunesLook` (parede oeste lisa), `RiftLook`, `BridgeLook`, `GardenLook`, `SanctuaryLook` (sem escada de entrada velha; as bordas ganham o acabamento normal em vez do filete). As funções `_entry` das looks ficaram sem uso (candidatas a limpeza).
- **Loja** (`CatacombHall._shop_column`): a caixa de pedra virou coluna esculpida (plinto, anel de base, fuste, capitel; `SHOP_SHAFT_R`, `SHOP_PLINTH`, `SHOP_BASE`, `SHOP_CAPITAL`) com plaquinha de pergaminho e dois rolinhos na face da sala (`SHOP_PLAQUE*`, `SHOP_PARCHMENT`). O número do preço continua no `DoorSign` (texto de HUD, não mexi).
