> Índice: [art_rooms.md](../art_rooms.md)

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
