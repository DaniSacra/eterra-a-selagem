# Ciclo 4: diagnóstico e especificação de arte (2026-11-14, noite)

Pedido do Daniel: "A implementação atual ainda está distante da qualidade visual desejada." Meta única:
`docs/art/ref/arena_catacumbas_1672.png` (1672 x 941, fora do git). Ordem dele: P0 personagens, P0 portal, P1 piso,
P1 arquitetura, P1 iluminação, P1 abismo, P2 HUD.

Autor: Art Director. Implementação: Environment Artist (cenário, materiais, luz), Gameplay Engineer (personagens na
tela, câmera de jogo), UI/UX (HUD). Nada aqui foi implementado.

## 0. Evidência e método

- Capturas reais (Vulkan, 1672 x 941, `--seed=5`), no scratchpad da sessão
  (`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/ad/`):
  `ad_vitrine.png` (`--showcase`, 2 s), `ad_luta.png` (`--bot --autopick`, 9 s), `ad_luta14.png` (14 s).
  Recortes ampliados lado a lado no mesmo lugar: `ref_*.png` e `g_*.png` (portal, chão, noroeste, leste, sudoeste,
  personagens).
- Captura do Daniel (Windows, 1901 x 1010, sala 1, 0:06), descrita pelo Game Director: herói dourado chapado,
  inimigos de gesso, portal retângulo verde estourado lavando a fachada e a escada, fachada de tijolos repetidos,
  estátuas do portal vultos verdes, braseiros e velas com halos laranja-brancos grandes, chão em lajes cinza-lilás
  uniformes, medalhão em traço fino, parede azul-violeta chapada no abismo à direita, obeliscos de caixas. A nossa
  captura mostra tudo isso; as duas concordam.
- Métricas: `python3 -I tools/art_metrics.py` (valor e cor) e um script de estudo
  (`.../scratchpad/tools/extra.py`) com quatro medidas novas por região: desvio padrão da luminância (`sd`),
  **detalhe** (média do módulo do laplaciano da luminância, amostra a cada 2 px: mede quanta forma pequena se lê),
  **verde** (fração com G > R + 40 e G > B + 15) e **halo quente** (fração com L > 120, R > G > B, R - B > 60).

### O achado principal

As oito métricas globais do ciclo 3 já estão na faixa (p50 49, p95 140, < 20: 16%, chão azul 51%, verde no chão
13,9%, quentes 1,1%, violeta 8,5% / 3,6%). **A distância que o Daniel vê não é mais de valor nem de matiz global; é
de forma, material e forma da luz.** Onde a pintura tem desenho (aresta acesa, lasca, dobra, moldura, chama com
línguas), o jogo tem superfície lisa, caixa reta ou borrão de brilho. As medidas de detalhe mostram isso:

| Região (vitrine) | Detalhe ref | Detalhe jogo | Outra medida ref | jogo |
|---|---|---|---|---|
| Fachada inteira (1050,0)-(1672,330) | 13,3 | 5,9 | verde 13% | **49%** |
| Miolo do portal (1270,110)-(1350,240) | 13,5 | 1,5 | sd 64 | **9** (chapado) |
| Estátuas do portal (1110,60)-(1220,240) | 15,1 | 6,4 | verde 10% | **63%** |
| Fachada à direita (1450,0)-(1672,250) | 9,8 | 4,2 | | |
| Braseiro leste (1300,560)-(1500,720) | 13,5 | 4,9 | halo quente 13,6% | **26,8%** |
| Chão limpo à direita (1000,620)-(1200,760) | 10,9 | 5,1 | | |
| Chão ao fundo à direita (1180,380)-(1380,470) | 13,1 | 9,1 | sd 33 | 17 |
| Colunas do abismo à esquerda (0,180)-(260,420) | 5,6 | 2,7 | mediana #052f44 | **#26215d** |

Notar: `abyss_left_cols` com mediana #26215d **reprova** o aceite P0-2 do `arena_reference.md` (pedia G >= R + 20 e
B >= R + 25); o ciclo 3 mediu o topo, não esta caixa.

## (a) Diferenças por área, da mais perceptível para a menos

| # | Área | A pintura | O jogo hoje |
|---|---|---|---|
| 1 | **Herói** | Corpo escuro e quente (couro #3d2a26 a #4b2e29), cabelo cobre #a9340d a #e15e26, cachecol petróleo grande voando (#234648 a #5a8767), sombra de contato escura no chão, 88 px de altura | Corpo inteiro dourado translúcido (brilhos #ffd858, a cor de `Player.OUTLINE`); lê como fantasma de ouro; sem sombra no chão; 69 px na luta |
| 2 | **Portal** | Vão fundo dentro de 3 a 4 ordens que recuam, ogiva aguda de aduelas lascadas, pendentes escuros longos (o do meio desce cerca de 55% da altura do vão), luz com degradê e fiapos (sd 64), janela em losango com moldura, verde só nas faces internas, no degrau e no chão molhado | Retângulo verde liso (sd 9), 3 pendentes minúsculos, halo de glow grande; a fachada e as estátuas viram verdes (49% e 63% da área) |
| 3 | **Inimigos** | Esqueletos marfim (#d8ccb0 nos brilhos) com órbitas e frestas pretas, couro marrom, faixa de valor larga dentro da figura, sombra embaixo | Gesso cinza uniforme (#92959a a #a0a6aa, só 14 níveis entre a mediana e o brilho), sem preto interno, sem sombra; partículas magenta (#ff40ff) que não existem na paleta |
| 4 | **Luz quente** | Chama com forma (línguas, miolo #fff0a0, borda laranja), bacia de bronze com aro aceso, poça pequena | Bolhas de glow laranja-branco; a bacia some no brilho; halo quente ocupa o dobro (26,8% contra 13,6%) |
| 5 | **Fachada e arquitetura** | Cantaria grande e irregular (blocos de 1,2 a 2,6 m), arestas chanfradas e lascadas com luz no topo, nichos, cornijas, contrafortes com pináculos | Tijolos regulares pequenos (fiada 0,85 m, bloco 1,7 m) com aresta de computador; caixas retas empilhadas (obeliscos, balaustradas, pedestais) |
| 6 | **Piso** | Lajes de 1,2 a 2,8 m sem linha contínua, cada uma com seu valor, chanfro aceso, lascas, cantos faltando, pétalas vermelhas, brilho úmido perto do verde e do fogo | Fileiras contínuas ao longo de x atravessando a sala inteira (a "grade"), valor quase igual, sem chanfro, plano; duas faixas escuras compridas e retas atravessando o chão (sombra a identificar) |
| 7 | **Estátuas** | Monges esculpidos: capuz fundo com máscara clara no rosto, mãos, cinto, dobras grandes, base esculpida | Cones lisos com capuz (detalhe 6,4 contra 15,1); a gigante é um cilindro com bola |
| 8 | **Abismo** | Silhuetas escuras (#052f44) em 3 ou mais planos: pilares, arcadas em ponte, torre; bancos de bruma clara entre os planos; violeta só no terço de baixo; janela ogival acesa pequena | Caixas lisas iluminadas de azul-violeta (#26215d) com faixas violetas verticais de cima a baixo; lanterna é um pentágono amarelo chapado; na câmera de jogo, cartões de brilho vistos de lado viram painéis lilás quase brancos (direita de `ad_luta14`) |
| 9 | **Medalhão** | Faixa larga em relevo de pedra com volutas, pontas cheias, ouro velho gasto, lê como chão esculpido | Traço dourado fino com anéis e bolinhas; lê como círculo de ritual desenhado por cima do chão |
| 10 | **Enquadramento de jogo** | Herói com 88 px em 941 | Herói com 69 px (cerca de 22% menor); o Daniel acha o quadro "mais aberto que a pintura" |
| 11 | HUD (P2) | Retrato, barras com moldura, losangos de habilidade | Barras chapadas; fica para o UI/UX depois do cenário |

## (b) Especificação para o Environment Artist

Regra geral: **nenhuma caixa nua em pedra.** Toda peça de pedra construída passa a ter chanfro, variação e lasca.
Isso sozinho tira metade da cara de "primitiva".

### B0. Bloco chanfrado (base de tudo)  `scripts/game/masonry.gd`

- Nova `Masonry.bevel_mesh(size: Vector3, chamfer: float) -> ArrayMesh` (cache por tamanho arredondado a 0,05 m):
  caixa com chanfro de 45° em todas as arestas, `chamfer` 0,06 m (blocos até 1,5 m) a 0,1 m (maiores). Usar em
  `box` e `block` no lugar do `BoxMesh`.
- Variação por bloco (semente pela posição): giro de -1,5 a 1,5° em y, de -0,8 a 0,8° em x e z; tamanho de 0,96 a
  1,0 por eixo; 30% dos blocos com um canto lascado (um octante cortado de 0,1 a 0,25 m, feito na própria malha).
- No `masonry.gdshader`: chanfro mais claro quando voltado para cima ou para a lua (`top_light` 1,3 continua; a
  face do chanfro de cima x1,45), arestas verticais x1,15 no lado da luz; cavidades (juntas e lascas) a 0,35 do valor.
- Aceite: num recorte ampliado 3x de qualquer obelisco, balaustrada ou pedestal, nenhuma aresta de 90° perfeita e
  reta de ponta a ponta; detalhe do `obelisk_s` >= 6,5 (ref 6,8; hoje 5,8).

### B1. Portal gótico  `catacomb_hall.gd` `_facade`; `masonry.gd` `pointed_arch`; `arena_kit.gd` `portal_glow`, `PORTAL_*`; `assets/shaders/portal.gdshader`

Medidas da pintura na tela da vitrine: vão de x 1275 a 1370 e y 120 a 245 (cerca de 28 px/m); ogiva de fora de x
1210 a 1430 com a ponta em y 0 a 10; janela em losango de (1307, 67) a (1340, 100); pendente do meio até y 190.
No jogo hoje: vão de x 1275 a 1382 e y 82 a 220 (cerca de 35 px mais alto), losango em (1320 a 1350, 30 a 65).

1. **Profundidade**: o véu de luz recua para dentro de um túnel. `PORTAL_DEPTH` 0,7 para 2,2 m. As faces internas
   (ombreiras e intradorso) em cantaria chanfrada, recebendo verde; o fundo atrás do véu continua escuro
   (Color(0.02, 0.06, 0.04)).
2. **Arquivoltas**: `PORTAL_ORDERS` 2 para 4. Cada ordem é uma ogiva de **aduelas separadas** (blocos de 0,55 m ao
   longo do arco, junta de 0,04 m, cada aduela com recuo aleatório de 0 a 0,05 m), largura do anel 0,45 m,
   profundidade 0,5 m. A ordem k fica 0,35 m mais larga de cada lado e 0,45 m mais à frente que a k - 1 (a de dentro
   começa em z `FACADE_Z` - 1,6, a de fora em `FACADE_Z` + 0,2). Ogiva aguda: centros dos arcos a 0,8 da largura
   (arco quebrado de terceiro ponto), não os dois segmentos retos de hoje; 6 a 8 aduelas por lado. Pedra das ordens
   `PORTAL_ORDER_TINT` 1,35 para 1,15 (mais escura que hoje: a pintura separa as ordens por sombra entre elas, não
   por pedra clara). A ponta da ordem de fora em y de tela 0 a 15 na vitrine (baixar a altura total se precisar).
3. **Colunelos**: entre as ordens, 2 por lado, cilindros de raio 0,13 m da base (bloco 0,4 x 0,25 x 0,4) ao
   capitel (bloco 0,42 x 0,3 x 0,42, chanfrado) na altura do nascimento do arco.
4. **Pendentes**: 5 dentes de pedra escura pendurados do alto do vão, como na pintura: o do meio com 2,2 m, dois
   com 1,3 m, dois com 0,6 m; raiz de 0,35 a 0,6 m, contorno serrilhado (prisma de 4 a 6 lados afinando com 2 dentes
   laterais); material de pedra com tint 0,4, sem luz própria; o verde só no contorno (são silhueta contra a luz).
5. **Tímpano e janela**: entre o lintel e a ordem de dentro, painel recuado 0,25 m; janela em losango de 1,0 x 1,2 m
   com moldura de 0,15 m em pedra (4 barras chanfradas) e uma cruz fina de pedra (0,06 m) dividindo o vidro; vidro
   verde a `PORTAL_WINDOW_GLOW` 1,6 para 1,2.
6. **Gablete e pináculos**: sobre a ordem de fora, um gablete triangular (inclinação de 60°, espessura 0,4 m, borda
   de 0,2 m saliente). Os dois contrafortes que ladeiam o portal terminam em pináculo: tronco de 1,3 m de lado,
   pirâmide de 1,8 m, 4 ganchos (blocos de 0,18 m) em cada aresta, florão de 0,3 m no topo.
7. **Véu de luz** (`portal.gdshader`): degradê vertical (base 1,0, topo 0,55), escurecer 0,3 m nas bordas, fiapos de
   fbm subindo devagar (amplitude 0,15, 0,08 m/s), duas manchas mais claras perto do chão (a "boca" da luz).
   `PORTAL_DIM` 2,0 para 1,5 e `PORTAL_OPEN` 2,8 para 2,0: com o degradê, a mediana do miolo continua perto de
   #39f65d e o glow para de criar o halo grande.
8. **Luz verde localizada**: omni do portal `PORTAL_RANGE` 9 para 5,5, `PORTAL_LIGHT_DIM` 4 para 2,5,
   `PORTAL_LIGHT` 5,5 para 3,5, posta 1,2 m à frente do véu (dentro do túnel, não 2,2 m fora). Mais duas omni pequenas
   nas faces internas (alcance 2,5, energia 1,5) para acender o intradorso. O foco da escada fica (energia 9,
   alcance 14), abertura 40 para 30, sem sombra na fachada: tirar a fachada e as estátuas da máscara dele (uma
   camada de luz para "fachada"; o foco só acende chão, degraus e personagens).
9. **Estátuas do portal**: tint de Color(0.22, 0.3, 0.27) para Color(0.16, 0.18, 0.2); o verde só no lado do vão
   (consequência do item 8).
- Aceite (vitrine): `portal_open` mediana luminância >= 150 e G >= R + 120; sd do miolo >= 35; verde na fachada
  (1050,0)-(1672,330) <= 20%; verde nas estátuas (1110,60)-(1220,240) <= 25%; detalhe da fachada >= 9; o pendente do
  meio visível como silhueta escura até y 175 a 200; quatro ordens contáveis num recorte 2x; `stairs` mediana entre
  #0f5050 e #1a7068 (já passa, não pode piorar); verde no chão em frente >= 8%.

### B2. Fachada e cantaria  `masonry.gdshader`; `catacomb_hall.gd` `_facade`

- Material próprio da fachada (`Masonry.stone` com parâmetros): fiada variável por linha de 0,9 a 1,4 m
  (`course` 0,85 vira faixa), bloco de 1,2 a 2,6 m (`block_len` 1,7 vira faixa), junta 0,06 m, lascas nos cantos dos
  blocos no próprio shader (canto escuro arredondado de 0,08 a 0,2 m em 25% dos blocos), `stone_a` / `stone_b`
  10% mais escuros que hoje; mediana da fachada na sombra perto de #11313a (ref).
- Relevo: plinto de 1,0 m saliente 0,25 m ao longo da fachada; duas cornijas (0,25 m de altura, 0,2 m de saliência)
  em y `DAIS_Y` + 4,2 e + 8,0; entre os contrafortes, arcada cega: nichos ogivais de 0,9 x 2,4 m, 0,3 m de fundo, com
  fundo escuro (tint 0,3), um por vão de contraforte.
- Janelas altas: as duas `pointed_arch` de 1,2 x 2,6 viram nichos fundos (0,4 m) com mainel central de 0,1 m.
- Aceite: detalhe em `facade_right` (1450,0)-(1672,250) >= 7 (ref 9,8; hoje 4,2); num recorte 2x, nenhuma fileira
  de tijolos iguais com mais de 4 blocos do mesmo tamanho seguidos.

### B3. Piso  `assets/shaders/catacomb_floor.gdshader` `stones`, `fragment`; `arena_kit.gd` `floor_plate`

- **Acabar com as linhas contínuas.** Hoje cada fileira é uma faixa em x de ponta a ponta. Trocar `stones()` por um
  padrão "amarelinha" (lajes grandes de 2,4 m com lajes pequenas de 1,2 m nos cantos, sem linha reta que passe de
  duas lajes) e, sobre ele, partir 30% das grandes em 2 (direção sorteada) e 10% em 3. Tamanho final de 1,0 a 2,8 m,
  proporção até 1,8:1.
- Borda irregular: cantos arredondados de 0,12 m, borda tremida por ruído com amplitude 0,06 m (já existe um
  tremido global de 0,06 unidades: passar a ser por laje).
- Valor por laje: fator de 0,78 a 1,2 (hoje 0,85 a 1,15 multiplicado pela aguada); três lajes em cada dez com tom
  levemente mais frio ou mais quente (x Color(0.92, 1.0, 1.08) ou Color(1.08, 1.0, 0.92)).
- Relevo por laje: cada laje com uma inclinação aleatória de 0 a 3° na normal (`NORMAL_MAP` a partir de um vetor
  sorteado por laje) e chanfro de 0,12 m com normal analítica (distância à junta em coordenada da laje, sem
  `dFdx`): a luz do key e do fogo acende o chanfro de um lado e escurece do outro, como na pintura.
- Desgaste: 15% das lajes com um canto faltando (triângulo de 0,2 a 0,45 m em cor de junta com cascalho); lascas
  pequenas (0,05 a 0,15 m) ao longo das bordas; rachaduras como hoje, mas 25% das lajes e mais finas no meio.
- Pétalas ou manchas vermelhas pequenas (0,08 a 0,2 m, Color(0.45, 0.06, 0.06)) em grupos raros perto das bordas e
  dos obeliscos (a pintura tem; não é sangue em poça).
- Reflexos controlados: tirar a umidade aleatória pelo chão todo (hoje `fbm` > 0,55, cerca de 20%) e deixar só:
  a zona `WET` do portal (como está) e um anel úmido de 1,5 a 3 m em volta do pé de cada braseiro, rugosidade 0,25.
  Fora disso rugosidade 0,75 a 0,9.
- As duas faixas escuras retas que cruzam a sala na vitrine (de (560, 300) para a direita embaixo e paralela a ela,
  ver `g_floor.png`): identificar a origem (não são as correntes, que já não fazem sombra; suspeita: sombra da lua de
  peças altas do fundo ou da fachada) e tirar. Testar com `moon.shadow_enabled = false`.
- Aceite: detalhe em (1000,620)-(1200,760) >= 8,5 (ref 10,9; hoje 5,1); sd no chão ao fundo à direita >= 25 (ref 33;
  hoje 17); num recorte 2x do chão, nenhuma junta reta contínua mais longa que 5 m (cerca de 2 lajes grandes);
  `floor_blue_dominant` continua de 40% a 65%.

### B4. Medalhão  `catacomb_floor.gdshader` `medallion`

- O desenho de rosa dos ventos fica (aprovado no ciclo 1), mas como **relevo de pedra**, não traço: faixa entre os
  anéis de 0,9 m (anel externo r 4,7 e interno r 3,8) preenchida com pedra 15% mais clara e volutas em sulco escuro
  (0,05 m) no lugar das 16 bolinhas (que hoje leem como círculo de ritual); pontas cheias com metade clara e metade
  escura (já previsto) e contorno em sulco escuro 0,06 m com fio de ouro velho de 0,03 m dentro (#7a6a4c a #a08a5e,
  sem emissão).
- As juntas das lajes passam por baixo do relevo (a pintura mostra as lajes através do medalhão) mas mais fracas
  (40%).
- Aceite: num recorte 2x, o medalhão lê como pedra esculpida (faixa larga com relevo), não como linha desenhada;
  nenhuma bolinha isolada.

### B5. Luz  `scripts/game/game.gd` `_build_world`; `arena_kit.gd` `brazier`, `fire`; `masonry.gd` `candle`

- **Fogo com forma**: o problema é o glow, não a luz. Línguas da chama com a cor máxima em HDR 1,6 (hoje `FLAME`
  Color(2.4, 1.5, 0.6) e `CANDLE_FIRE` Color(4.0, 2.2, 0.8)): `FLAME` para Color(1.6, 1.0, 0.4) com miolo branco-ouro
  Color(1.8, 1.6, 1.0) só nas línguas de dentro; `CANDLE_FIRE` para Color(1.9, 1.2, 0.5). Halo das velas
  (`CANDLE_HALO` 0,9) para 0,5 com opacidade 0,35.
- Glow do ambiente: `glow_hdr_threshold` 1,1 para 1,3; nível 4 (o mais largo) de 1,0 para 0,3; `glow_intensity`
  0,45 fica. Isso reduz todos os halos de uma vez sem apagar o branco das lâminas e dos cortes (que passam de 2).
- Bacia do braseiro visível: aro de bronze com emissão quente fraca por dentro (Color(0.9, 0.4, 0.12) x 0,6) para
  a borda ler contra a chama, como na pintura.
- Poças de luz: braseiros e velas como estão (`BRAZIER_LIGHT` 3,5, alcance 10), mas com sombra nas omni das velas
  maiores desligada e nas dos braseiros ligada (já está); conferir que os pedestais e as balaustradas lançam sombra
  no chão (contraste cinematográfico).
- Sombras ricas: SSAO `ssao_intensity` 2,2 para 3,0 e `ssao_radius` 1,4 para 1,0 (cantos e pés das peças mais
  escuros); `ssao_light_affect` 0,2 para escurecer também onde há luz direta.
- Aceite: halo quente no braseiro leste <= 16% (ref 13,6%; hoje 26,8%) e detalhe ali >= 9 (ref 13,5; hoje 4,9);
  `warm_hot_px` >= 0,7% (não pode cair abaixo); núcleo da chama com brilhos >= #f8f090 e borda laranja; a bacia
  lê como objeto num recorte 2x.

### B6. Arquitetura, estátuas e adereços  `masonry.gd` `obelisk`, `balustrade`, `post`, `hooded_statue`; `arena_kit.gd` `statue`; `catacomb_hall.gd` `_west`, `_north_west`

- Obeliscos, balaustradas, pedestais: pelo B0 (chanfro, giro, lascas); obelisco com rachaduras verticais no shader
  (2 por face, 30% da altura) e o nicho com moldura de 0,08 m.
- Estátuas (sem modelo novo, melhora procedural): manto com pregas mais fundas (`PLEAT_DEPTH` 0,012 para 0,025,
  `PLEATS` 10 para 7, pregas indo até o peito); cinto (anel de 0,03 de altura em 0,55H); mangas largas (cone aberto
  de 0,07H na boca) cobrindo as mãos; máscara do rosto em pedra clara (0,05H, x2 do valor do manto) dentro do capuz
  escuro, como na pintura (a pintura mostra máscara clara no fundo do capuz); base esculpida em dois degraus
  chanfrados. Material: ruído triplanar mais forte (contraste 0,35) e `rim` 0,3 para 0,15.
- Estátua gigante (`GIANT`): mesmo boneco, tint Color(0.14, 0.12, 0.12); luz de baixo só do braseiro (como está).
- Correntes: elos com raio de arame 0,12 m (hoje `LINK_SIZE` 0,2 com furo 0,55: arame fino); ferro com rim frio
  fraco para recortar contra a bruma.
- Estandartes: P1-9 do `arena_reference.md` continua valendo (pano comprido, borda dourada, ponta em V, sem
  símbolo até o Daniel decidir).
- Aceite: estátuas do portal com detalhe >= 10 (ref 15,1; hoje 6,4); rosto mais claro que o capuz em volta; todas as
  caixas de pedra visíveis com chanfro.

### B7. Abismo em camadas  `catacomb_hall.gd` `_depths`, `_pier`, `_lantern`, `ROW_*`, `GLOW_*`; `depth_stone.gdshader`; `arena_kit.gd` `abyss_glow`

- O problema hoje: as fileiras de pilares são caixas lisas que pegam luz (azul-violeta, mediana #26215d) e os
  cartões violetas desenham faixas verticais do topo ao fundo atrás delas. Na pintura: silhuetas escuras (#052f44)
  contra bruma mais clara, com detalhe de arquitetura (arcos, pontes, capitéis) e o violeta só embaixo.
- `depth_stone.gdshader`: a fileira da frente com `stone_color` Color(0.02, 0.05, 0.07) e `edge_color` só no topo
  dos capitéis e arcos (aresta fria fina); `glow_energy` 0,25 para 0 nas faces de cima; o violeta só abaixo de y -8.
- Cartões violetas (`abyss_glow`, `GLOW_*`): do chão da bruma até no máximo y -6 (hoje sobem à altura das colunas),
  degradê de baixo para cima com borda suave, e atrás da fileira da frente só onde há vão entre pilares.
- Camadas: 4 planos (68, 82, 98 e um quarto a 120 m), cada um com mais bruma (`fade_max` 0,8 nos dois de trás). Entre
  os planos, cartões de bruma clara horizontais (petróleo Color(0.07, 0.28, 0.31), alfa 0,25, borda de ruído) na
  altura de y -4 a 2, para separar as silhuetas.
- Arquitetura nos planos: a fileira da frente com uma ponte em arco (aqueduto) ligando dois pilares a oeste em y
  -2 a 2, arcos ogivais entre todos os pilares (já existem) e capitéis chanfrados; o plano de trás com pilares mais
  finos e quebrados (topo partido, alturas de 60% a 100%).
- Lanterna (`_lantern`): o pentágono amarelo chapado vira janela ogival de 0,8 x 1,4 m com moldura de pedra de
  0,12 m, vidro quente com degradê (Color(1.5, 0.8, 0.28) embaixo, 0,6 disso em cima) e um halo pequeno (0,5 m);
  na tela perto de (130, 280) com 25 x 45 px.
- **Cartões vistos de lado na câmera de jogo** (`ad_luta14.png`, direita, de (1290, 420) a (1672, 780)): com a câmera
  seguindo o herói para o leste, os cartões de `abyss_glow` (e os de bruma) aparecem como painéis lisos lilás quase
  brancos, a "parede azul-violeta chapada brilhante" da captura do Daniel. Os cartões precisam olhar para a câmera
  real (billboard só no eixo y, `BILLBOARD_FIXED_Y` ou o equivalente no shader) e sumir pela borda (alfa por
  ângulo e borda de ruído de 30% do tamanho); brilho máximo deles abaixo de luminância 140 na tela.
- Ponto vermelho aceso no alto da corrente do centro em `ad_luta14.png` (perto de (465, 75)): identificar (luz de
  Morvath ou de porta?) e tirar do quadro da sala 1; vermelho é reservado aos avisos e aos estandartes.
- Direita embaixo: a parede violeta lisa vira a muralha da plataforma em blocos (`_cliff` com o material do B2) e
  o violeta só como brilho subindo da bruma no pé.
- Aceite: `abyss_left_cols` mediana com G >= R + 20 e B >= R + 25 (hoje falha) e detalhe >= 4,5 (ref 5,6; hoje
  2,7); violeta esquerda >= 6% e direita >= 3% (continua); nenhuma faixa violeta vertical acima de y 380 na
  esquerda; a lanterna lê como janela ogival num recorte 2x; na captura de luta de 14 s, nenhum painel liso com
  luminância acima de 140 maior que 40 x 40 px no abismo.

### B8. Navegador

- Tudo acima precisa rodar no Compatibility (sem SSR, sem volumétrica): chanfros e relevo são malha e shader, valem
  nos dois. Conferir com `DRIVER=opengl3` que o portal não estoura em branco e que os cartões de bruma aparecem.

## (c) Personagens: para o Gameplay Engineer (não implementar aqui)

Herói (`scripts/game/player.gd`, `scripts/render/hero_body.gd`, `assets/shaders/flash.gdshader`, `xray.gdshader`):
- Suspeita a confirmar: o passe de raio X (`xray.gdshader`, `depth_test_disabled`, `blend_add`, encadeado como
  `next_pass` do `_overlay` em `Player`) desenha por cima do herói inteiro o tempo todo, não só quando algo o
  encobre, e soma dourado (`OUTLINE` Color(1.0, 0.78, 0.35)) em todo o corpo; o contorno do `flash.gdshader` também
  é dourado. Juntos explicam o "herói todo dourado" na captura do Daniel e na nossa.
- Alvo na tela (luta, sala 1): cabelo entre #a9340d e #e15e26; cachecol e manto entre #234648 e #5a8767, no mínimo
  12% dos pixels da figura; couro e calça com mediana entre #2a1e1c e #4b2e29; nenhum pixel do corpo acima de
  luminância 200 fora da lâmina, da fivela e do cabelo no lado da luz; pixels dourados (R > 200, G > 160, B < 110)
  <= 3% da caixa do herói. Contorno, se houver, frio e claro (Color(0.75, 0.9, 1.0)) de 1 px, nunca preenchimento.
- Raio X só onde está encoberto (ou desligado até isso existir).
- Sombra de contato: elipse escura de 1,2 x 0,8 m sob os pés, opacidade 0,5, para todos (herói e multidão); a
  pintura tem sombra sob cada figura.
- Tamanho: o herói tem 69 px na luta e 88 na pintura. Proposta para o Daniel decidir: `Feel.cam_distance` 60 para
  50 só na câmera de jogo (a vitrine continua no enquadramento da pintura). Não aumentar o herói (a sala foi medida
  com 2,5 m).

Multidão (`scripts/render/crowd_renderer.gd`, `assets/shaders/crowd.gdshader`, `crowd_outline.gdshader`):
- Hoje gesso: `CROWD_LIFT` 0,45 e `CROWD_FLAT` 0,45 apagam a forma; a cor sai cinza-clara uniforme (#92959a a
  #a0a6aa). Alvo: os esqueletos com brilho marfim (#d8ccb0) e preto interno (órbitas, costelas, juntas) <= #201810;
  diferença de luminância entre p10 e p90 da figura >= 110 e p10 <= 40. Caminho sugerido: `CROWD_LIFT` 0,45 para
  0,12, `CROWD_FLAT` 0,45 para 0,2, `CROWD_GREY` 0,92 para 0,8 com o marfim vindo da textura, e um contorno escuro
  fino (Color(0.04, 0.03, 0.05), 1 px) na multidão comum para separar do chão escuro (os elites mantêm o contorno
  rosa avermelhado).
- Luz da sala na multidão: hoje fica fora das tochas (camada 2) e só recebe `hero_pos`; deixar receber o key light
  do medalhão e o verde do portal (a pintura mostra os esqueletos com o lado quente do fogo).
- Partículas magenta (#ff40ff, aglomerados na luta): trocar por uma cor da paleta (violeta do abismo #7b54d7 ou
  branco) ou reduzir; magenta saturado não existe na pintura.
- Aviso no chão vermelho: legível, manter; conferir que o vermelho não é mais claro que a lâmina do herói.

## (d) O que depende de modelos

Impossível só com formas procedurais (precisa de modelo esculpido, Meshy suspenso):
- Herói Explorador fiel à folha (cachecol e manto com pano, ombreiras, cabelo em mechas): `hero_explorer.md`.
- Esqueletos e o guerreiro de escudos da pintura (são outros modelos; o KayKit fica provisório).
- Estátuas com rosto, mãos e dobras esculpidas; gárgulas e relevos da fachada; pedra lascada orgânica dos obeliscos.

O que modelos e texturas CC0 resolveriam:
- Herói: Universal Base Characters + Modular Character Outfits (Ranger), Quaternius, CC0 verificado em
  `docs/art/free_assets_research.md`; mesmo esqueleto da UAL. Ainda faltam cachecol, manto e ombreiras.
- Texturas de pedra e chão: Poly Haven e ambientCG publicam texturas em CC0 (licença geral dos sites, **não
  verificada hoje para peças específicas**). Usar só os mapas de relevo e normal (lajes, cantaria) sob a nossa cor
  pintada: dá lascas e chanfros reais ao chão e à fachada sem mudar a paleta. É o ganho mais barato de fidelidade.
- Esqueletos: o KayKit tem pacote de esqueletos (Kay Lousberg; licença a verificar antes de baixar); continua chibi.
- Peças de ruína (arcos, colunas quebradas) para o abismo: pacotes CC0 da Quaternius e do Kenney existem, licença e
  conteúdo **não verificados**; pedir pesquisa ao QA ou ao Game Director antes de qualquer download.
- Lembrete: tudo de IA vai para `docs/steam-ia.md`; CC0 feito à mão, nos créditos.

## (e) Critérios de aceite do ciclo 4

Captura: `RES=1672x941 tools/shot.sh <saida> 2 --showcase --seed=5` e `... 9 --bot --autopick --seed=5`. Medidas
com `tools/art_metrics.py` mais as regiões novas desta página (pedir ao QA para acrescentar `sd`, detalhe, verde e
halo quente ao script; a versão de estudo está em `.../scratchpad/tools/extra.py`).

| Medida | Ref | Hoje | Aceite |
|---|---|---|---|
| Verde na fachada (1050,0)-(1672,330) | 13% | 49% | <= 20% |
| sd do miolo do portal (1270,110)-(1350,240) | 64 | 9 | >= 35, mediana L >= 150, G >= R + 120 |
| Verde nas estátuas do portal (1110,60)-(1220,240) | 10% | 63% | <= 25% |
| Detalhe da fachada (1050,0)-(1672,330) | 13,3 | 5,9 | >= 9 |
| Detalhe da fachada direita (1450,0)-(1672,250) | 9,8 | 4,2 | >= 7 |
| Detalhe das estátuas do portal | 15,1 | 6,4 | >= 10 |
| Halo quente no braseiro leste (1300,560)-(1500,720) | 13,6% | 26,8% | <= 16% |
| Detalhe no braseiro leste | 13,5 | 4,9 | >= 9 |
| Detalhe do chão (1000,620)-(1200,760) | 10,9 | 5,1 | >= 8,5 |
| sd do chão ao fundo (1180,380)-(1380,470) | 33 | 17 | >= 25 |
| `abyss_left_cols` mediana | #052f44 | #26215d | G >= R + 20 e B >= R + 25 |
| Detalhe `abyss_left_cols` | 5,6 | 2,7 | >= 4,5 |
| Detalhe do obelisco sul | 6,8 | 5,8 | >= 6,5 |
| Herói: pixels dourados na caixa dele (luta) | quase 0 | maioria | <= 3% |
| Esqueleto: p90 - p10 de luminância na figura | cerca de 100 | cerca de 60 | >= 100, p10 <= 40 |
| As oito medidas globais do ciclo 3 | | na faixa | continuam na faixa |

E, a olho, lado a lado com a pintura (o Art Director registra em `visual_review.md`):
- portal lê como arco gótico fundo com ordens, pendentes e janela; verde só dentro, no degrau e no chão molhado;
- chão sem linhas que atravessam a sala; lajes com valor, chanfro e desgaste;
- nenhuma pedra de caixa nua; estátuas com rosto claro no capuz escuro;
- abismo com silhuetas escuras em planos e o violeta só embaixo;
- herói escuro com cabelo cobre e cachecol petróleo; esqueletos marfim com preto interno; os dois com sombra;
- navegador (`DRIVER=opengl3`) sem quebrar.

Ordem sugerida de trabalho: B5 (glow e fogo, rápido e muda muito) e (c) herói em paralelo; depois B1 (portal), B0
e B3 (chanfro e piso), B7 (abismo), B2, B6, B4.
