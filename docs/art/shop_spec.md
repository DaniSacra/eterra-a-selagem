# Loja da descida e Vendedor do Santuário: a banca do mercador (especificação, art-director, 2026-11-23)

Uma família só (`meta_identities.md` 4): forma **baixa e larga**, tecido listrado, couro costurado e madeira de balcão,
cor terra e vinho apagado 6e2a2a, gesto **pôr no prato**, som de moedas e balança. Duas partes:
- **A. Loja da descida** (no mundo, sem tela): `room-designer` (posições, PT-11), `environment-artist` (pano, colunas,
  etiquetas em 3D), `ui-ux-designer` (texto da etiqueta, `DoorSign`).
- **B. Vendedor do Santuário** (tela `VendorScreen`): `ui-ux-designer`, `technical-artist` (balança).

A peça que une as duas: a **etiqueta de couro** (seção C), igual nas duas.
Alvo de leitura: **em 3 segundos** o jogador sabe o que é cada item, quanto custa, se pode pagar e o que muda.

---

## A. Loja da descida (PT-11: os itens junto da parede)

Princípio da referência local `docs/art/ref/sworn_daniel/shop_along_wall.png` (outro jogo, só a sensação; nada copiado,
nunca vai ao ChatGPT nem ao Meshy): itens em colunas finas ao longo da parede, cada um numa bolha de luz pequena com a
plaquinha de preço em cima, o meio da sala livre, uma oferta de destaque sozinha mais à frente.

### A.1 Disposição (para o `room-designer`; câmera Perto, estilizado)

- **Fileira da parede**: os itens de cura e crescimento (2 a 4) em **colunas de pedra baixas** (altura 1,1 m, diâmetro
  0,7 m, o capitel com o pano listrado dobrado por cima) encostadas na parede do fundo (norte na tela) e nas laterais, a
  1,2 m da face da parede, 4,5 m ou mais entre elas. Na tela, a 1280 x 720, as etiquetas ficam no terço de cima (y 120..300)
  e nenhuma passa de x 60 nem de x 1220.
- **Destaque**: a Bênção (grupo `shop_group_boon`) sozinha **à frente e no eixo**, a 4 m da fileira, num pedestal um
  pouco mais alto (1,3 m) com o pano estendido no chão em volta (tapete listrado 2,4 x 1,6 m, o `floor_decal` da loja de
  hoje com as listras da seção C.3). Se a loja não tiver Bênção, o destaque é o item mais caro.
- **Meio livre**: um círculo de 5 m de raio no centro sem coluna, sem quebrável (`test_breakables` já mantém 3 m dos
  relicários; manter).
- Posições são **dado** da sala (pontos da loja no `_layout` da sala, por `tools/make_data.gd`), não constante no
  `rooms.gd`: `Rooms._build_shop` lê os pontos em vez de `SHOP_STEP` e `SHOP_SHIFT`; sala sem pontos cai na fileira de
  hoje. O robô compra igual: mesmas compras no `RESULT` da semente 5.
- Luz: a bolha de cada item é o `RewardShaft` de hoje (`SHOP_CAN` 0,75 com ouro, `SHOP_CANNOT` 0,3 sem), encurtado para
  1,6 m acima da coluna; as lanternas de ferro da loja (`SHOP_LAMP_LIGHT`) entre as colunas, não no meio.

### A.2 A etiqueta sobre cada item (no mundo, `DoorSign.shop`)

Troca o visual da placa (o filete) pela etiqueta de couro (C.1), pendurada por um cordão curto acima do item. Duas alturas:
- **Longe** (o herói a mais de 3 m): só a **linha do preço**: moeda de ouro 22 px (`assets/ui/rewards/gold.png`) e o
  número em Alegreya Sans Bold 24; embaixo o **nome** em Alegreya Sans Bold 16 (`reward_*`). Sem ouro: número em
  vermelho apagado c05040 e "faltam N" em 14 (como hoje, `set_gold`).
- **Perto** (o item que o `use_spot` escolhe): a etiqueta cresce para baixo (0,15 s) e ganha a **linha do que muda**
  (Alegreya Sans 16, números em negrito) e a tecla com o verbo ("E Comprar", `StationSign`). Textos novos com o número
  vindo do dado: `shop_effect_heal` "Cura {n}% da vida" (`stage.shop_heal`), `shop_effect_heart` "Mais {n} de vida
  máxima" (`stage.heart_life`), `shop_effect_magick` "Mais {n} de Magia máxima" (`stage.magick_more`), `shop_effect_pom`
  "Fortalece uma Bênção à escolha", `shop_effect_pom_slice` "Fortalece uma Bênção ao acaso", `shop_effect_boon` "Uma
  Bênção à escolha", `shop_effect_enchant` "Um Encanto até o fim da descida".
- A etiqueta nunca cobre outra: com o herói perto de um item, as vizinhas ficam na altura "longe".

### A.3 Comprar

Fica um aperto de `interact` (E, A), como hoje: no mundo não há balança e o robô e o `RESULT` não podem mudar. Ao comprar:
som de moedas, a etiqueta vira para o lado de trás (couro liso, 0,2 s) e cai no pano, o item sobe para o herói como hoje.

### A.4 Mercador de rota (`is_route_shop`)

Mesma família, menor: 1 a 3 itens (4 com a Obra Banca da Rota) numa **banca de pano no chão** (tapete listrado 3 x 1,4 m
encostado numa parede), os itens sobre caixotes baixos (0,6 m). Sem pedestal de destaque. Mesmas etiquetas.

---

## B. Vendedor do Santuário: a balança

### B.1 Composição (1280 x 720; a 1920 x 1080 x1,5)

Ordem das camadas: fundo (balcão visto de frente), toldo, colunas de etiquetas, balança, placa de leitura, bolsa.

| Peça | 1280 x 720 | Observação |
|---|---|---|
| Toldo | x 0..1280, y 0..86 | listras verticais de 64 px, vinho apagado 6e2a2a e terra 8a6a48, borda de baixo em franja recortada (o toldo que o Vendedor já tem no Santuário) |
| Título "Banca do Vendedor" | Cinzel 28 `STRONG` com sombra, centro (640, 44), sobre o toldo | `vendor_title` |
| Bolsa | x 1010..1256, y 104..136 | Prata, Memória, Esmeralda (`MaterialCount.purse`), Alegreya Sans Bold 20, ícone 24 |
| Fundo | x 0..1280, y 86..720 | parede do balcão em madeira escura 2a1c12, tampo do balcão em y 560..600 (madeira mais clara 5a3c24 com veio) |
| Coluna **Trocas** (esquerda) | x 40..360, cabeçalho y 104 | Cinzel 18 `GOLD` "Trocas"; 3 etiquetas de 320 x 76 em y 140, 228, 316 |
| Coluna **Obras** (direita) | x 920..1240, cabeçalho y 150 (abaixo da bolsa) | Cinzel 18 "Obras"; 3 etiquetas de 320 x 76 em y 186, 274, 362 |
| **Balança** | pivô (640, 200), travessão 380 px, pratos 150 x 30 pendurados 150 px abaixo das pontas | latão envelhecido a08050, correntes de 3 elos; pé apoiado no tampo em y 560 |
| Placa de leitura | x 400..880, y 404..548 (480 x 144) | couro escuro 2e1e16 com costura em pesponto marfim a 4 px da borda |
| Botão "Fechar a troca" | centro (640, 584), 300 x 44, sobre o tampo | só depois de pôr no prato |

### B.2 A etiqueta da coluna (Trocas e Obras)

Etiqueta de couro (C.1) deitada, 320 x 76, furo com ilhó à esquerda:
- **Troca**: à esquerda o que se dá (ícone 28 + "10"), uma seta de tinta, à direita o que se recebe (ícone 28 + "1");
  números em Alegreya Sans Bold 22. Sem material: o número do que se dá em vermelho apagado; bolsa cheia: o do que se
  recebe em vermelho apagado (`vendor_trade_cant`).
- **Obra**: nome em Cinzel 17 na linha de cima; embaixo os custos (ícone 20 + número em Bold 18, um por material, o que
  falta em vermelho apagado). Erguida: etiqueta com um **carimbo** de ouro velho "Erguida" girado -8 graus e o resto a 60%.
- Foco: a etiqueta avança 10 px para o meio, aro de ouro velho 2 px, e um cordão aparece da etiqueta até o prato.

### B.3 Pôr no prato (o gesto)

1. **Foco** numa etiqueta: os pratos mostram uma **prévia fantasma** (ícones a 40%): prato da esquerda = o que se dá,
   prato da direita = o que se recebe (Obra: o desenho da Obra, ícone 48). A placa de leitura já diz tudo (B.4).
2. **Primeiro aperto** (A, Enter, clique): **pôr no prato**. Os ícones caem nos pratos (0,25 s, peso), a balança pende
   para o lado do que se dá (mais pesado), ângulo proporcional à perda, de 4 a 10 graus (troca de 10 Prata por 1 Memória:
   8 graus; Obra: 6 graus fixos), balança 2 vezes antes de parar (0,6 s). O foco pula para "Fechar a troca".
3. **Segundo aperto**: fecha (`Vendor.trade` ou `Vendor.build`). Moedas tilintam, o prato da esquerda esvazia para o
   Vendedor (os ícones saem pela esquerda, 0,25 s), o da direita desce para a bolsa (os números contam, 0,3 s), a balança
   volta ao nível. Grava o save e emite `traded`/`built` como hoje.
4. **B / Esc** com algo no prato: tira do prato sem gastar (os ícones voltam para a etiqueta, 0,2 s). Prato vazio: fecha.
- Sem material: o primeiro aperto põe no prato mesmo assim (mostra o tamanho da troca), mas o botão fica desligado com o
  motivo ("Faltam 4 de Prata"); nada se gasta.

### B.4 Placa de leitura (3 segundos)

Dentro de 480 x 144, margem 16:
- Linha 1: **nome** em Cinzel 22 `STRONG` ("Fonte Viva", ou "Troca" para as trocas) e, à direita, o **estado** em Bold 16
  ("Pode trocar" em ouro, "Faltam 12 de Prata" em vermelho apagado, "Erguida" em verde `Book.OK` clareado).
- Linha 2: **o que muda**, Alegreya Sans 18 `PALE`, números em negrito: `obra_*_desc` ("As fontes das catacumbas curam
  **55%** da vida, não **40%**."), e para as trocas "Dá **10** Prata e recebe **1** Memória. A troca perde no caminho."
- Linha 3: **quanto**, ícones 24 e números Bold 22, e "você tem N" em 15 `DIM` sob cada custo.

### B.5 Balcão fechado (antes da primeira encomenda)

Mesma tela: a balança amarrada com uma corda (desenho), as colunas vazias e, no meio da placa, a **encomenda**
(`OficioSheets.order`: a marca da Pedra Funda, "Pede 1 de 2", onde achar, o que dá) numa etiqueta só, com o verbo
"Entregar" no mesmo gesto (pôr no prato, fechar). Reaproveita a lógica de hoje da folha (`HubPanel`); muda só o desenho.
Se isso pedir mudança no `HubPanel` maior que a tela, fica para depois: o primeiro passo é a tela aberta (B.1 a B.4).

### B.6 Entrada

- Direcional e setas: ↑/↓ andam nas etiquetas de uma coluna; ←/→ passam de Trocas para Obras (caindo na mesma linha) e
  pelo botão do meio quando ele está aceso. LB/RB e PageUp/PageDown também trocam de coluna.
- A / Enter / clique: pôr no prato, depois fechar. B / Esc: tirar do prato, depois fechar a tela.
- Mouse: passar dá o foco (prévia fantasma); clicar põe no prato; clicar no botão fecha.
- Abre com o foco na primeira troca que se pode pagar; se nenhuma, na primeira Obra.

---

## C. Peças da família (iguais nas duas partes)

### C.1 Etiqueta de couro

Couro curtido marrom avermelhado 5a3424 com borda mais escura 2e1a12, **pesponto marfim** e9dcc0 a 4 px da borda (traço
de 4 px, vão de 3 px), cantos cortados a 45 graus no lado do ilhó, ilhó de latão a08050. Texto em marfim `MARK_IVORY`
(`Book`) com sombra; preço em Bold. No mundo, presa por um cordão de 18 px; na tela, deitada.

### C.2 Moedas e ícones

Ouro da descida = `assets/ui/rewards/gold.png` (moeda). Prata, Memória, Esmeralda = os de `MaterialCount`/`DoorGlyph`
(`silver.png`, `memory.png`, a pedra desenhada). Itens da loja = `assets/ui/rewards/*.png` (`heal`, `heart`, `magick`,
`pom`, `pom_slice`, `boon`, `enchant`). O ouro **não** é a cor dominante (é dos Dons): só a moeda.

### C.3 Listras

Vinho apagado 6e2a2a e terra 8a6a48, listras de 64 px na tela (toldo) e de 0,25 m no mundo (pano, tapete). Mesmo par
nas duas partes; nunca vermelho vivo (é o que fere).

---

## D. Até a arte chegar (só peças que já existem)

| Peça | Provisório |
|---|---|
| Etiqueta de couro | `StyleBoxFlat` 5a3424, borda 2e1a12, pesponto desenhado (`_draw`, traço tracejado) |
| Toldo, balcão | `_draw` (listras, tampo) |
| Balança | `_draw`: travessão, correntes, pratos (arcos), pivô; o ângulo é só uma rotação |
| Ícones | `assets/ui/rewards/*.png`, `MaterialCount`, `DoorGlyph`, `PickMark` |
| Colunas e pano da loja | `Masonry` (coluna baixa), `floor_decal.gdshader` com as listras de C.3 |
| Som | `ui_move` (foco), `door` provisório para fechar; moedas e rangido pendentes |

Arte final por caminho previsto (como `DonsArt`): `assets/ui/shop/counter_bg.png`, `awning.png`, `scale_post.png`,
`scale_beam.png`, `scale_plate.png`, `tag_flat.png` (9-patch), `tag_hang.png`, `tag_back.png`, `stamp_built.png`,
`obra_altar.png`, `obra_fonte.png`, `obra_banca.png`, `rope.png`; o pano listrado do chão (`stripes.png`, sem emenda) vai
para o `floor_decal` da loja (itens 1 a 9 do pedido).
Pedido em `docs/art/requests/Pedido-ChatGPT-Loja.txt`; o que vier entra em `docs/steam-ia.md` antes do jogo.

## E. Critério de aprovação

Loja da descida (captura GPU, estilizado, câmera Perto, `--start=shop`):
1. Itens ao longo da parede, etiquetas no terço de cima, a Bênção sozinha à frente, meio da sala livre.
2. De longe, preço e nome legíveis em todas; de perto, a linha do que muda e "E Comprar" na do item escolhido, sem
   cobrir as vizinhas. Sem ouro, o preço lê vermelho apagado com "faltam N".
3. `RESULT` da semente 5 com as mesmas compras do robô.

Vendedor (captura 1280 x 720 e 1920 x 1080, `--hub --hero-at=vendor --hub-use=vendor --materials=...`):
4. Balança no centro, Trocas à esquerda, Obras à direita, placa com nome, o que muda e o preço com "você tem N".
5. Pôr no prato faz a balança pender para o que se dá; B tira sem gastar; o segundo aperto troca uma vez só.
6. Estados (pode, falta, bolsa cheia, erguida) por cor **e** palavra; corpo 14 px ou mais a 720; nada de violeta; o ouro
   só nas moedas.
