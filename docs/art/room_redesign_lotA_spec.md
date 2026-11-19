# Redesenho das salas, Etapa 1 e Lote A: biblioteca, Cripta A e B, Salão (com Loja e Fonte)

- **Data**: 2026-11-18. **Autor**: art-director. **Para**: environment-artist (cenário, shaders, luz). Partes de outros
  donos estão marcadas (uma linha no `rooms.gd` e o vigia do F7 no `game.gd` passam pelo Game Director).
- **Base**: `docs/art/room_redesign_matrix.md` (paleta 0.4, regras 0.3, aceite comum 4), `docs/art/room_redesign_decisions.md`,
  `docs/design/room_redesign_level_review.md`. Conceitos só locais: `docs/art/ref/redesign_2026-11-18/conceitos/01`,
  `02`, `03`, `16`, `17` (clima e paleta, nunca posição).
- **Só perfil STYLIZED.** O clássico não muda nem um número. Tudo novo entra por `VisualProfile.vary` (valor clássico =
  como foi montado; peça nova = `visible` falso no clássico e verdadeiro no estilizado).
- Colisão, `RoomLayout`, câmeras, portas, nascimentos, avisos, raio-x: intocados. Meshy zero.

---

## Parte 1. Biblioteca compartilhada (Etapa 1, só o que o Lote A usa)

KISS: cada lote cria a peça da biblioteca que usa (musgo, folha e água no C; runas no D). O que entra agora:

### 1.1 Preset de bioma: `style()` de cada sala

- No `ArenaRoom`, ao lado de `air()`, `floor_look()` e `stone_tint()`, um gancho novo `func style() -> Dictionary` (vazio
  = a sala fica como está no estilizado, como hoje). O `CatacombHall` ganha o mesmo dicionário como constante
  (`STYLE`). Chaves (todas opcionais):

| Chave | Vai para | Tipo |
|---|---|---|
| `stone` | `shader_parameter/paint_stone` de todo material `masonry_paint` da sala | cor |
| `shadow` | `shader_parameter/paint_shadow` dos pintados (pedra, chão, KayKit pintado) | cor |
| `floor_stone`, `joint_cold`, `olive_share`, `slab_hue`, `edge_value` | os mesmos uniforms do `catacomb_floor_paint` | cor ou número |
| `keep` | lista de materiais da sala que mantêm a própria cor (`paint_keep` 1): madeira (já), osso, ouro | |
| `fire` | `{bowl_range, candle_range, bowl_attenuation, bowl_gain, candle_gain, compat}` (o `_stylize` do Salão, ver 1.3) | dicionário |
| `air` | o ar estilizado da sala (mesmas chaves do `air()`, ver 1.4) | dicionário |
| `off` | luzes da sala desligadas no estilizado (a chave e o preenchimento do chão que desenham anéis) | lista de nós |
| `backdrop` | `{mist, stone, edge}` do `ArenaRoom.backdrop`, só estilizado | dicionário |

- Aplicação: no fim do `build` (depois do `m.merge()` e do `_dress_air()`), uma função comum (sugestão:
  `ArenaRoom._stylize()`, chamando `kit.paint_look(style)` e `kit.stylize_fires(style.fire)`) registra tudo pelo
  `VisualProfile.vary`. O `ArenaKit.paint_look()` passa a aceitar o dicionário e soma as chaves de cor ao `values` de
  cada material que troca de shader (hoje só põe o `shader` e o `paint_keep`). O `CatacombHall._stylize` passa a usar
  as mesmas duas funções com o `STYLE` dele.
- Nada de global de shader por bioma: na troca de sala as duas salas coexistem um quadro (o ar já trata isso), e o
  parâmetro por material não vaza.

### 1.2 Pedra, chão e peças pintados

- `masonry_paint` e `catacomb_floor_paint` já existem e têm os uniforms; o que muda é o valor por sala (0.4 da matriz).
- **Osso não vira pedra**: o `BONE` da Cripta é um `m.stone(0.0, BONE)` e o `paint_recolor` o puxaria ao petróleo. Pôr
  `paint_keep` 1 nesses materiais (osso marfim apagado, tela matiz 35 a 45, luma 110 a 150 nos feixes iluminados).
- **Metal** (`TombKit.gold()`, `iron()`, `ArenaKit._bronze()`, a soleira de ouro da entrada da Cripta): `vary` no
  `StandardMaterial3D`: `roughness` 0,75, `metallic` 0,35, `albedo_color` ouro velho (0,42; 0,31; 0,13) no ouro, ferro
  (0,16; 0,16; 0,17), bronze (0,32; 0,22; 0,12). Alvo de tela: ouro matiz 34 a 42, saturação até 0,6, nada acima de 200.
- **Estátuas encapuzadas** (`kit.statue`, `hooded_statue`): como no Salão estilizado (camada própria). Não mexer.
- **Pano**: estandartes petróleo do STY (`BANNER_PAINT_*`) servem. Pano novo da Loja: umbra (0,16; 0,11; 0,08) e ocre
  apagado (0,34; 0,24; 0,12), barra de ouro velho; nunca vermelho.

### 1.3 Poças de fogo: `ArenaKit.stylize_fires(fire)`

Levar o laço do `CatacombHall._stylize` (que hoje só existe no Salão) para uma função do `ArenaKit` que percorre as
`OmniLight3D` da raiz do kit: quente (`light_color.r - b >= RoomMood.FIRE_FROM`) e fora da `DEPTH_LAYER` vira poça
(alcance, queda, ganho, sem sombra); a chave do meio e o que estiver em `off` ficam invisíveis. Valores do Salão iguais
aos de hoje (`STY_BOWL_*`, `STY_CANDLE_*`, `STY_COMPAT_FIRE`: o Salão não pode mudar nas poças). A Cripta usa os seus
(Parte 2).

### 1.4 Ar estilizado por sala e o F7

Problema medido: na Cripta o `_dress_air()` grava o ar dela direto no `Environment` e na lua, por cima do que o
`VisualProfile.dress_world` registrou; o estilizado da Cripta sai com o ar clássico. Pedido:

- `_dress_air()` escolhe `style().air` quando `VisualProfile.stylized()` e `air()` senão (as chaves que faltarem no
  estilizado caem nas do `air()`).
- Na troca do F7 a sala refaz o próprio ar (o `Game._process` que lê `look_toggle` chama `arena` para refazer o ar da
  sala vestida depois do `VisualProfile.toggle()`; arquivo compartilhado, avisar o Game Director). O `leave_air()`
  continua devolvendo o ar de antes da sala, nos dois perfis.
- No Salão o ar estilizado continua o do `VisualProfile` (`AMBIENT`, `KEY_*`), com os números novos da Parte 3.
- Teste (novo, `tests/test_room_style.gd`): monta a Cripta A e B e o Salão, troca o look duas vezes, confere que todo
  material, luz, visibilidade, `Environment` e lua voltam aos valores clássicos e que a colisão é a mesma; e que dentro
  da Cripta no estilizado o ambiente e a lua são os do `style().air`.

### 1.5 Fundo em camadas (salas fechadas)

`ArenaRoom.backdrop(mist, stone, edge)` (cartões de ruína em duas profundidades e banco de bruma, das câmaras de evento)
entra nas salas fechadas, só no estilizado (`vary` do `visible` em cada nó criado). Na Cripta substitui o cinza chapado.

### 1.6 Peças procedurais novas

- **Urna** (`Masonry.urn(at, height, mat)` ou o `pot` com outro material): corpo torneado, boca estreita, tampa opcional;
  altura 0,3 a 0,55 m, raio até 0,14 m (cabe no parapeito de 0,3 m); material pedra da sala ou bronze (1.2).
- **Efígie amortalhada** (`TombKit.effigy(at, length, yaw, mat)`): figura deitada sob o sudário, feita de um perfil
  torneado ao longo do eixo (cabeça 0,26 m de largura, ombros 0,6, afinando aos pés 0,32; altura 0,22 no peito, 0,3 na
  cabeça, 0,26 nos pés), dobras do pano pelo sombreamento de vértice (três a cinco sulcos rasos na diagonal), sem rosto,
  sem mãos, nenhuma cruz nem espada sobre ela. Pedra da sala, um degrau mais clara (1,05).
- **Vela agrupada** já existe (`candle_line`, apagada com `_wax_out`).

### 1.7 Densidade e onde pode haver peça nova

Vale a 0.3 e a seção 2 da matriz. Lugares permitidos para peça nova: dentro de nicho, recesso ou arco (atrás da face
da parede); no parapeito de 0,3 m ao pé das paredes do fundo; em cima de peça que barra, dentro do contorno dela menos
0,1 m; fora do polígono do chão (além das paredes cortadas, no monte de blocos, no abismo); decalque abaixo de 0,02 m.
Nunca no chão andável acima de 0,3 m; nunca a menos de 1,5 m da boca de porta acima de 0,3 m.

---

## Parte 2. Cripta dos Esquecidos A e B (`CryptLook`)

### 2.1 O que a medida diz (2026-11-18, captura da galeria, reproduzida igual na GPU)

| Caixa (pixels a 1920 x 1080) | Hoje, estilizado (A / B) | Conceito | Alvo |
|---|---|---|---|
| Chão leste `1152,432,192,162` | matiz 263 / 250, sat HSV p50 0,15 / 0,17, luma p50 79 / 79 | matiz 204 a 208, sat 0,29 a 0,40, luma 67 a 79 | matiz 198 a 215, sat 0,10 a 0,20, **luma p50 60 a 75** |
| Chão oeste `576,432,192,108` | matiz 264, luma p50 92 (A); B 100 com vela | | luma p50 60 a 78 longe das velas |
| Parede norte `864,32,288,97` | luma p50 40, matiz 237 | 37 a 38 | luma p50 32 a 48, matiz 200 a 225 |
| Fora da sala `0,324,96,324` | (26; 26; 26), desvio 0 | profundidade fria | luma p50 12 a 30, p90 menos p10 de 6 ou mais, matiz 195 a 215 |
| Quadro (`frame_stats`) | YAVG 57, SATHIGH 8 a 9 | 60 a 64, 29 a 30 | YAVG 50 a 62, **SATHIGH 12 a 24** |
| Parte quente da cena (sat acima de 0,35, valor acima de 0,35, matiz abaixo de 50 ou acima de 340) | 0,9 a 1,1% | 9% | **2,5 a 7%** |

### 2.2 Preset `style()` da Cripta

| Chave | Valor |
|---|---|
| `stone` | (0,285; 0,32; 0,347), matiz 206 |
| `shadow` | (0,784; 0,898; 0,98) |
| `floor_stone` | (0,266; 0,296; 0,317) |
| `joint_cold` | (0,85; 0,938; 1,0) |
| `olive_share` | 0,03 (uma laje em 33 puxa ao oliva; cripta é seca) |
| `slab_hue` | 4 |
| `keep` | osso (`BONE`), madeira |
| `fire` | `candle_range` 2,6, `candle_gain` 1,3, `bowl_range` 3,5, `bowl_attenuation` 0,7, `bowl_gain` 1,0, `compat` 0,4; nenhuma sombra de fogo |
| `air` | `sky` (0,045; 0,065; 0,08), `fog` (0,09; 0,14; 0,17), `fog_depth` (30; 70), `ambient` (0,62; 0,70; 0,78), `ambient_gain` 1,6 (o clássico é 2,1; ajustar até o chão bater 60 a 75), `moon` (0,86; 0,93; 1,0), `moon_energy` 0,9, `moon_shadow` verdadeiro (a chave de trás da câmera do `VisualProfile.KEY_ROTATION` dá a sombra das figuras) |
| `off` | a chave do meio (`KEY`) e o preenchimento do chão (`FLOOR_FILL`): no estilizado as omni sem fogo desenham anel no chão (o mesmo motivo do Salão); o `wall_fill` fica se nenhuma borda de anel aparecer na captura, senão sai também |
| `backdrop` | `mist` (0,10; 0,15; 0,18), `stone` (0,05; 0,07; 0,08), `edge` (0,16; 0,22; 0,26) |

Luzes com sombra no estilizado: a chave direcional e o facho frio (2), contra 4 a 5 no clássico. Abaixo do teto de 6.

### 2.3 Facho frio e profundidade (A e B)

- Facho `COLD` (0,62; 0,74; 0,9) vira (0,66; 0,82; 0,92) (matiz 200, sat 0,28) no estilizado, `COLD_ENERGY` 1,6 igual,
  poeira igual. A tampa do túmulo sob o facho até luma 170 (nunca branca; `TOMB_LID_LIGHT` 1,0 continua).
- **Brilho frio da porta norte** (X1, boca em x 4,3 na parede norte): um cartão vertical sem sombra e sem luz dentro do
  arco, 1,0 m atrás da face da parede (z -11,8), da largura do vão e 4 m de altura, degradê de baixo (0,10; 0,17; 0,21) a
  cima (0,02; 0,03; 0,04), sem tocar no chão andável. Na B, o cartão sobe a (0,16; 0,24; 0,28) embaixo: é "a luz
  distante" do conceito 03, fria azul-marfim e não verde. Teto: maior canal na tela até 120.
- **Bruma além da frente cortada**: um `ArenaKit.mist_bank` por frente (sul e leste), centro 2,5 m para fora da face
  externa, y -2,5, cor (0,10; 0,15; 0,18) vezes 2, alfa 0,5, nunca acima de y 0. Cobre a pedra que cai no escuro e o
  monte de blocos.
- **Nunca névoa sobre o chão andável** (a caixa de 300 px do herói não pode passar de 2% de ciano).

### 2.4 Peças novas, Cripta A (coordenadas da sala: x leste, z sul; chão de -12 a 12 por -10,5 a 10,5; face da parede
norte em z -10,8, da oeste em x -12,3; parapeito de 0,3 m a y 0,9)

| # | Peça | Onde | Medidas | Por quê |
|---|---|---|---|---|
| A1 | Efígie amortalhada (1.6) | em cima do túmulo grande (centro (0,5; 0), 4 x 2 m, topo 1,5 m), de x -0,6 a 1,6, cabeça a oeste | comprimento 2,2 m; topo a 1,8 m | o marco do conceito; fica longe das linhas de velas das pontas (x -1,05 e 2,05) |
| A2 | Urnas em grupo | parapeito norte em x -10,6 (duas) e x -1,2 (uma e um toco de vela apagado) | 0,3 a 0,55 m, raio até 0,14 | ritmo da faixa norte; fora das velas de x -5,9 a -5,3 e 0,3 a 0,9 e dos recessos dos braseiros (0,75 a 2,25; 6,35 a 7,85) |
| A3 | Urnas em grupo | parapeito oeste em z -2,4 (duas) e z 0,9 (uma) | idem | fora das velas de z -3,9 a -3,3 e 1,5 a 2,1, da mureta em z 0 e da entrada (z 2,5 a 6,5 mais o batente) |
| A4 | Velas aos pés das estátuas | no piso dos dois nichos de estátua (norte x -2,5; oeste z -7,5), fileira de 5, acesas | 0,1 a 0,3 m | "velas agrupadas"; uma luz simples cada (sem sombra, `candle_range`), só no estilizado (no máximo 2 luzes a mais na sala) |
| A5 | Urnas e velas apagadas | nas prateleiras dos nichos sem estátua (norte x -8,5; oeste z 8,5), entre os potes que já existem | 2 urnas e 3 velas apagadas por nicho | memória e abandono |
| A6 | Velas apagadas a mais | nas tampas dos dois sarcófagos pequenos que hoje têm velas acesas, a ponta oposta | 3 por tampa | o conceito tem muito mais vela; a regra é metade apagada |
| A7 | Lajes de túmulo com nome apagado | as 6 lajes que existem (`SLAB_ROWS`) ganham na pintura um retângulo inscrito com traços sem texto (como a faixa do Altar) | relevo pintado, 0 m | narrativa sem altura |

### 2.5 Peças novas, Cripta B (Ossuário: muro de x 0,1 a 0,9, z -10,5 a -3,5, altura 3,2)

| # | Peça | Onde | Medidas | Por quê |
|---|---|---|---|---|
| B1 | Figura velada monumental | em pé sobre o topo do muro, na ponta norte (0,5; -9,6), virada para o sul (para a câmera) | `hooded_statue` de 3,0 m sobre 3,2 m (topo a 6,2, abaixo da cornija de 6,5) | o marco do conceito 03, onde a câmera olha; na ponta norte não cobre a luta (a ponta sul tem o pilarete e o facho) |
| B2 | Urnas sobre o muro | no topo do muro, z -8,5, -7,0, -5,5 e -4,5 | 0,35 a 0,5 m | "urnas" do conceito, em cima de peça que barra |
| B3 | Luz fria da figura | `kit.statue_glow` frio (0,66; 0,82; 0,92), energia 1,2, alcance 6, cone 35, de cima e da frente | | separa a figura da parede norte |
| B4 | Sem "pequenas escadas" | | | degrau no chão andável é desnível falso |

A figura e as urnas sobre o muro: o muro está em pontilhado em volta do herói (`see_through`); as peças em cima dele
levam o mesmo (`see()` no material) para nunca esconderem o herói atrás do muro.

### 2.6 O que não muda na Cripta

Planta, peças que barram, alturas, portas e arcos, frente cortada a 0,9 m, monte a nordeste, posição e cone do facho,
estandartes (o gêmeo petróleo do STY), raio-x, avisos. Clássico idêntico.

---

## Parte 3. Salão das Catacumbas (`CatacombHall`), e por ele a Loja (16) e a Fonte (17)

### 3.1 O que a medida diz

| Caixa (pixels a 1920 x 1080) | Clássico | Estilizado hoje | Alvo estilizado |
|---|---|---|---|
| Chão do meio `1152,486,384,184` | matiz 254, sat 0,28, luma p50 60 | **matiz 42**, sat 0,31, luma p50 76 | **matiz 215 a 235**, sat HSV p50 0,08 a 0,16, luma p50 65 a 78 |
| Chão norte `1056,238,384,108` | luma 49 | luma 67, matiz 43 | luma p50 55 a 70, matiz 215 a 235 |
| Abismo `0,270,230,378` | matiz 224, sat 0,47 | matiz 229, sat 0,33 | matiz 205 a 225, sat 0,30 a 0,50 |
| Quadro (`frame_stats`) | YAVG 56, SATHIGH 23 | YAVG 68, SATHIGH 18 | YAVG 58 a 70, SATHIGH 14 a 22 |
| Poça do braseiro leste (laje a 1,5 m) | | 106 a 109, matiz 27 (STY-10) | igual: 100 a 150, matiz 26 a 34 |

### 3.2 Preset `STYLE` do Salão (o resto do STY fica)

| Chave | De | Para |
|---|---|---|
| `paint_stone` | (0,355; 0,34; 0,31) | (0,325; 0,341; 0,386), matiz 224 |
| `paint_shadow` | (0,92; 0,93; 0,98) | (0,833; 0,877; 0,98) (sombra azul, nunca preta) |
| `floor_stone` | (0,325; 0,315; 0,29) | (0,301; 0,316; 0,35) |
| `joint_cold` | (0,93; 0,96; 1,05) | (0,88; 0,91; 1,0) |
| `olive_share` | 0,125 | 0,06 |
| `VisualProfile.AMBIENT` (só o Salão o usa; nas arenas o ar da sala manda) | (0,78; 0,74; 0,68) | (0,70; 0,74; 0,80) |
| `VisualProfile.KEY_COLOR` | (1,0; 0,94; 0,84) | igual; se o chão do meio ficar com matiz abaixo de 212, (0,98; 0,97; 0,95) |
| Madeira dos caixotes, cera, barro, chamas, estandartes, poças | STY-10 | igual |

O que fica igual: geometria, colisão, posições, braseiros e velas (acesas e apagadas), alcance e ganho das poças
(`STY_*`), medalhão (S-Q6 continua pendente: as quatro pontas ficam no valor da junta), portal (AP-1), avisos,
figuras. Nada de peça nova no chão de luta. Se o abismo não ficar na faixa com isso, `vary` em `ArenaKit.MIST` e no
`ABYSS_LIGHT` só no estilizado, puxando o matiz para 210 a 220, saturação da tela até 0,5.

Riqueza: o Salão já tem a densidade do conceito 01 (estátuas, estandartes, braseiros, potes, caixotes, velas). No Lote
A só: urnas de pedra (1.6) junto aos dois grupos de potes da balaustrada oeste (do lado do abismo da balaustrada, x
menor que a face dela) e no pé das duas estátuas do portal, sobre o plinto delas; nenhuma vela acesa a mais.

### 3.3 Loja (sala 10; o Salão vestido, só estilizado)

As placas ficam onde estão (`Rooms._build_shop`: fileira ao longo da direita da tela, `right` = (0,819; -0,574); com
5 itens, pontos em `right` vezes -13,5, -8,5, -3,5, 1,5 e 6,5 m). Pedido de uma linha ao Game Director: depois de
montar a fileira, `arena.dress_shop(pontos)` (o `CatacombHall` desenha; nada barra).

| Peça | Onde | Medidas |
|---|---|---|
| Tapete pintado | sob cada item, centrado no ponto, alinhado à fileira | 2,6 x 1,8 m, decalque de 0,01 m: umbra (0,16; 0,11; 0,08) com barra ocre (0,34; 0,24; 0,12) de 0,12 m e um losango de ouro velho no meio; nada de círculo nem vermelho |
| Lanterna de ferro | uma a cada dois itens (3 para 5 itens), num gancho que sai do corpo do relicário (`RewardGem.Stand`, atrás do ponto) | topo a 3,2 m, a lanterna 0,6 m atrás do plano da placa; vidro âmbar, uma luz simples (`candle_range`, ganho 1,0), sem sombra |
| Posto de provisões | os grupos de caixotes e potes que já existem ao pé da escada do altar e no recanto oeste ganham pano umbra dobrado por cima e duas urnas | sobre o que já existe |

Aceite: placas e preços legíveis como hoje (`DoorSign.contrast` 4,5:1 nas capturas da loja a 720 e 1080; o "faltam N"
rosa apagado com contraste igual ao de hoje); nenhuma lanterna cobre placa; parte quente da cena até 10%.

### 3.4 Fonte (o Salão vestido, bacia fixa em (0; -2), só estilizado)

| Peça | Onde | Medidas |
|---|---|---|
| Musgo pintado | anel no chão em volta da bacia, de 1,95 a 3,2 m do centro, recortado irregular, mais denso do lado norte | decalque de 0,01 m, verde-cinza (0,20; 0,24; 0,17), abaixo do valor da laje; nunca verde vivo |
| Flores pálidas | pontos marfim (0,72; 0,7; 0,62) e lilás muito apagado (0,55; 0,52; 0,6) dentro do anel de musgo | decalque, 4 a 7 cm cada, até 40 |
| Velas de descanso | 4 tocos acesos na borda da bacia (em cima da peça), dois apagados | luz única já existente da fonte; nenhuma luz nova |
| Água | `fountain_water.gdshader` sem mudança de cor; se a água perder contraste sobre a pedra azul, subir só o brilho pálido (`vary`) | luma da água 40 ou mais acima da laje vizinha |

Bica de pedra simples (decisão P-11). Aceite: a fonte achada em 1 s na captura `--start=fountain` (só ela com água
clara e musgo no quadro); nenhuma confusão com o relicário das recompensas.

---

## Parte 4. Como medir (o environment-artist entrega com isto)

1. **Antes** (já existe): `docs/gallery/rooms_2026-11-18/estilizado/01`, `02`, `03`, `16`, `17`.
2. **Depois**, na RTX, mesma linha da galeria (a captura de 2026-11-18 foi reproduzida idêntica com ela):
   - `RES=1920x1080 tools/gpu.sh shot <saída> --look=stylized --arena=crypt --variant=0 --bot --autopick --seed=5 --shot-at=5`
     (e `--variant=1`; e `--look=classic` para a prova do clássico intacto);
   - Salão: `--look=stylized --bot --autopick --seed=5 --shot-at=5`; Loja: `--start=shop`; Fonte: `--start=fountain`;
   - em luta com aviso: os mesmos com `--shot-at=9`; 1280 x 720 com `RES=1280x720`;
   - F7: uma captura do estilizado depois de ir e voltar (`tools/test.sh -gselect=test_room_style` cobre os números).
   Saída em `docs/gallery/redesign/lotA/` (antes e depois lado a lado).
3. `python3 -I tools/frame_stats.py <capturas> --box=<caixa>` nas caixas das tabelas 2.1 e 3.1; o matiz pelo script de
   caixa (ou o `--hue` pedido ao technical-artist).
4. Jogo: `~/tools/godot/godot --headless --path . -s tools/fit_probe.gd -- --arena=crypt --variant=0 --look=stylized`
   (e 1; e `--arena=hall`). Linha de base de hoje (clássico): Cripta A fantasma 0,32 m², peça sem desenho 0,04; B 0,31
   e 0,04; Salão fantasma 3,04, borda falsa 39,06. Aceite: nada sobe mais de 0,1 m². Conferir que o `fit_probe` honra
   o `--look` (ele ignora malha invisível; se montar a sala antes do `VisualProfile` ler o argumento, as peças só do
   estilizado não contam: corrigir antes de medir).
5. `tools/test.sh` inteiro, `tools/check.gd`, 8 sementes do robô na Cripta (`tools/smoke.sh 120 --arena=crypt
   --seed=N` e `--variant=1`) sem `stuck`.
6. Desempenho: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/sty_probe.gd -- --nosave
   --bot --autopick --seed=5 --look=stylized --arena=crypt --probe-wait=6 --probe-for=6` e o mesmo com `--quality=baixa
   --gpu-index 1 --resolution 1280x720`: linha de base antes do lote, depois no máximo 3 qps abaixo; luzes com sombra
   (`tools/arena_lab.gd` imprime `SHADOWED LIGHTS`) até 6.
7. Compatibility: `DRIVER=opengl3 tools/shot.sh` uma por sala tocada, sem erro de shader no log.

## Parte 5. Aceite do Lote A (além do comum da matriz, seção 4)

- Tabelas 2.1 e 3.1 nos alvos, nas capturas A, B, Salão, Loja e Fonte.
- Três salas lidas como lugares diferentes lado a lado: Cripta petróleo frio com poças de vela e fundo em bruma; Salão
  ardósia azul com braseiros e portal; nenhuma das duas umbra.
- Marcos: efígie no túmulo (A) e figura sobre o Ossuário (B) visíveis na captura do jogo sem cobrir inimigos.
- Clássico idêntico ao da galeria nas cinco vistas.
- Nenhum círculo novo, nenhuma cruz, nenhum vermelho, nenhum verde fora do portal, nenhum ciano no chão.

## Parte 6. Esforço e riscos

- Esforço: biblioteca 1 a 1,5 sessões (gancho `style()`, `paint_look` com preset, `stylize_fires`, ar e F7, teste);
  Cripta 2 sessões (preset, efígie, urnas, velas, fundo, porta fria, figura da B); Salão, Loja e Fonte 1 a 1,5 sessões;
  correções da revisão 1. **Total: 5 a 6 sessões do environment-artist**, mais uma do QA e a minha revisão.
- Riscos:
  1. **Ar e F7**: o ponto mais frágil (o `Environment` tem dois donos, `VisualProfile` e a sala); sem o teste da 1.4 o
     clássico pode voltar com o ar errado.
  2. **Anéis de luz**: omni sem fogo no estilizado desenha borda de poça no chão; desligar a chave e o preenchimento da
     Cripta pode deixar o chão escuro demais (compensar no ambiente, nunca com omni nova).
  3. **Petróleo perto do herói**: pedra da Cripta e cachecol vizinhos de matiz; separar pela saturação (pedra até 0,2) e
     conferir o herói em 1 s nas capturas de luta.
  4. **Salão sai do morno do STY**: o parecer STY-09 aprovou a umbra; a diretriz nova pede o contrário. Se o Daniel
     preferir a umbra no Salão, só o preset muda de volta (L-1).
  5. **Contraste da fonte** (água fria sobre pedra fria).
