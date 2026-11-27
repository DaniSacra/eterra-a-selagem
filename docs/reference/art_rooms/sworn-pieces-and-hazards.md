> Índice: [art_rooms.md](../art_rooms.md)

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
