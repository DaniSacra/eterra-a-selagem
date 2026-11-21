# Cenário das salas (redesenho, Sworn, biomas)

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

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
