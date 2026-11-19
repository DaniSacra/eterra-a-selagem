# Sworn como referência de layout e cenário: princípios e ideias traduzidas para Eterra

- **Data**: 2026-11-19. **Autor**: art-director. **Pedido**: Game Director, a partir das capturas do Daniel.
- **Fonte**: 13 imagens locais em `C:\Users\danie\OneDrive\Imagens\Sworn\` (12 "Captura de tela 2026-11-18 *.jpeg"
  e `pexels-photo-4065021.jpeg`, que é outro quadro do mesmo vídeo). São quadros de vídeo do YouTube, com compressão.
  **Nunca entram no repositório, nunca vão para o Meshy, nunca são evidência.**
- **Regra**: só princípios. Nada de arte, paleta exata, nomes, personagens, símbolos, interface, arquitetura singular ou
  planta de sala do outro jogo. Tudo abaixo está traduzido para Eterra: sensação do Ember & Blade, perfil STYLIZED
  pintado, catacumbas sob Valmor, tom de aventura, leão como símbolo, nada de cruz, sol, auréola ou figura alada.
- **Limites que valem sobre toda ideia** (de `room_redesign_matrix.md` 0.3): câmera, colisão, rotas, portas,
  nascimentos e avisos iguais; nada novo acima de 0,3 m no chão andável (fora do chão, sobre peça que já barra, ou
  abaixo de 0,15 m); do lado sul nada acima de 0,9 m a 2 m da borda; círculo no chão só no Salão e na Câmara do Selo;
  cores reservadas (esmeralda da Emeth, verde e violeta de Morvath, vermelho dos avisos, âmbar das Runas) fora dos
  biomas; CLASSIC intacto; Meshy zero.
- **Gameplay das salas** (perigos, formas, progressão) é do room-designer em `docs/design/rooms_progression.md`. Aqui só
  cenário, moldura, luz e leitura. Onde uma ideia daqui serve a um RP de lá, digo qual.
- Nada implementado. Nenhum crédito gasto.

## 1. Medida rápida (para calibrar, não para perseguir)

`python3 -I tools/frame_stats.py --hue --scene` em quatro quadros de luta (222430, 222549, 222603, 222731): luma p50 da
cena 31 a 37 (p90 55 a 76), saturação p90 do `frame_stats` 10 a 13, matiz médio 162 a 174 (verde-musgo e azul-petróleo
frio), parte quente 0,2 a 1,1% da cena. Nossas salas estilizadas medem luma p50 47 a 77. Confirma o que a matriz já
disse (0.2, item 3): **a riqueza ali vem de valor e de bordas povoadas, não de saturação nem de claridade**. Não baixar
nossa luma para a deles: o Daniel joga em monitor comum e nossos avisos e figuras foram calibrados nos valores de hoje.

## 2. O que cada imagem ensina (1 a 3 linhas)

1. **222408** (tela de escolha de bênção): interface e personagem do outro jogo; nada para salas. Só confirma que a
   tela de escolha é um momento à parte, fora do cenário. Nada a tirar daqui.
2. **222420** (saída com recompensa): a porta de saída é uma peça monumental (arco com grade ornamental) e a recompensa
   flutua dentro do vão, não ao lado. Uma poça de água escura recortada no chão, com mato na borda, quebra o retângulo
   da sala sem tirar chão de luta. Raízes grossas cortam os cantos de cima do quadro.
3. **222430** (sala com água rasa): o chão de luta é uma ilha cercada por canais escuros; a borda viva (água, mato,
   estacas) desenha a forma da sala melhor que uma parede. Lajes quadradas emolduradas em relevo, giradas a 45 graus,
   dão ritmo ao chão. O perigo se lê pela peça: bloco com crânios e pontas, sempre o mesmo desenho.
4. **222445** (plataforma elevada): um terraço com balaustrada num canto, um degrau acima do chão, emoldura a sala e
   dá desnível sem tirar área. Potes em grupos de 3 a 5 exatamente onde a parede encontra o chão. A trilha de lajes
   mais escuras entre manchas de musgo diz por onde se anda.
5. **222504** (marco central): um poço de pedra com balaustrada no meio é o marco, com lajes emolduradas em volta;
   muretas baixas em diagonal repartem o salão em bolsões. Uma armadilha com setas gravadas diz a direção do golpe.
   Primeiro plano sul escuro e baixo (folhagem, tocos) emoldura sem tapar.
6. **222527** (beira da água): muro baixo com parapeito ao longo de um canal mostra a borda da sala com volume; uma
   ruína tombada atravessa a borda como obstáculo e marco. Cascata no canto de cima traz movimento ao fundo.
7. **222537** (duas saídas): duas portas lado a lado, cada uma num arco grande fora do chão, com a recompensa no vão;
   a trilha gasta no chão leva até elas. Arcos e raízes gigantes nas bordas mostram escala sem ocupar chão.
8. **222549** (colunata em ruína): fileira de pilares quebrados, alguns com remate de estátua, dá ritmo e profundidade
   com poucas peças altas e regulares. Manchas grandes de musgo (3 a 8 m) e sombra mosqueada de copa quebram o tom do
   chão em escala grande, por baixo da luta.
9. **222603** (evento no canto): o objeto do evento é o ponto mais claro e mais quente do quadro, com luz própria
   pequena. Cascata grande na lateral, com espuma no pé. Os pilares do primeiro plano (sul) são tocos baixos e
   cortados, para não esconder o herói. Merlões em ziguezague na borda de cima.
10. **222700** (chefe ao ar livre): a arena do chefe é ampla e vazia no meio; tudo que é adereço (gaiolas, cercas,
    ossos) fica no anel de borda. O chão é escuro e de baixo contraste, então os círculos vermelhos de aviso leem de
    longe. Confirma a nossa regra de Morvath.
11. **222731** (aviso e marco): aviso vermelho translúcido sobre chão de lajes frias com faixas de musgo; pedestal com
    bacia de água (único ponto ciano) como marco; raízes saindo da base do pedestal e se espalhando pelo chão em
    relevo baixo. Portões enormes no canto do quadro dizem "saída" sem texto.
12. **222445** e **222537** juntos: a vegetação invade da borda para dentro em manchas, nunca uniforme; o meio fica mais
    limpo que as bordas.
13. **pexels-photo-4065021** (evento de escolha em jogo): o ponto do evento é marcado por um feixe vertical de luz do
    alto e por dois pedestais simétricos com bacias. Simetria local diz "aqui é especial" numa sala assimétrica.

### 2.1 Os oito princípios que valem para nós

- **P1 Chão quieto no meio, bordas ricas.** Variação de valor em escala grande (manchas de 3 a 8 m) por baixo da luta;
  detalhe miúdo e volume só nas bordas. Já é a nossa regra (matriz 0.1); Sworn mostra que dá para ir mais longe nas
  bordas.
- **P2 A borda desenha a sala.** Água, mato, muro baixo, parapeito, terraço: a forma da sala se lê pelo contorno vivo,
  não pela parede do fundo.
- **P3 Ritmo no chão por lajes emolduradas em relevo baixo**, em grupos, giradas ou em fileira.
- **P4 Grupos de adereços onde dois planos se encontram** (parede e chão, pé de coluna, pé de escada), 3 a 5 por grupo,
  alturas diferentes.
- **P5 Luz que guia**: o evento e a saída são os pontos mais claros e quentes; a sombra mosqueada de copa ou de abóbada
  dá textura sem objetos.
- **P6 Escala fora do chão**: arcos, raízes e portões grandes nas bordas do quadro, nunca no chão de luta.
- **P7 Primeiro plano baixo e escuro**: o sul tem tocos cortados e silhuetas baixas, nada que esconda o herói.
- **P8 Perigo se lê pela peça**: o mesmo desenho para o mesmo perigo em toda sala (gravação, marca de direção).

## 3. Ideias traduzidas por sala (só STYLIZED)

Custo: P até 1 sessão, M 1 a 2, G 2 a 4 do dono. Prioridade: P1 (fazer primeiro), P2, P3. "Fora do chão" = fora do
polígono andável.

### 3.1 Biblioteca comum (antes das salas; ganha em todas)

| Id | O que acrescenta | Por que fica mais distinta na câmera | Reaproveita | Custo | Dono | Prioridade |
|---|---|---|---|---|---|---|
| SW-G1 | **Manchas de bioma no chão**: máscara de ruído de baixa frequência (3 a 8 m) no chão pintado que mistura uma segunda cor do bioma (musgo no Jardim, pó claro no Santuário, sal cinza nas Fendas, umidade fria na Cripta), abaixo de 0,15 m (só pintura) e mais forte a menos de 3 m das bordas | quebra o "tapete uniforme"; cada bioma ganha uma segunda cor no chão que se vê no quadro inteiro (P1, P2) | `catacomb_floor_paint.gdshader`, `clearing*` do `catacomb_floor.gdshaderinc`, chaves do `ArenaKit.FLOOR_KEYS` | P | technical-artist (shader), environment-artist (valores por sala) | P1 |
| SW-G2 | **Sombra mosqueada** (gobo): no shader do chão pintado, uma máscara que escurece 15 a 25% em manchas, tirada da copa (Jardim) ou das nervuras partidas da abóbada (Santuário), andando devagar | dá a luz filtrada que mais distingue os quadros de referência, sem objeto nenhum; liga o chão à peça que está acima dele (P5) | uniform no `paint.gdshaderinc`/chão; os `CANOPY_*` e `VAULT_*` dão a posição; nada de `light_projector` (não vale no Compatibility) | P a M | technical-artist | P1 |
| SW-G3 | **Lajes emolduradas em relevo baixo**: decalque ou geometria de 0,04 a 0,08 m, quadro de 2 a 3 m com moldura saliente e laje gasta dentro, em grupos de 2 a 4; nunca disco nem anel; nunca em cruz | ritmo de chão que diz "aqui foi construído" e marca eixos e cantos (P3) | `floor_decal.gdshader` (um `kind` novo) ou `Masonry` raso; o padrão das lajes do `rune_tiles.gdshaderinc` como modelo | P | environment-artist | P1 |
| SW-G4 | **Grupos de oferendas no encontro de planos**: 3 a 5 potes e urnas de alturas diferentes no pé das paredes, das colunas e das escadas, fora do chão ou dentro do contorno de peça que barra | as bordas ficam habitadas; os grupos quentes (barro) contra a pedra fria dão os pontos de cor de canto (P4) | `Masonry.urn`, potes do KayKit, velas apagadas (`Masonry.candle_out`) | P | environment-artist | P2 |
| SW-G5 | **Portão da porta que abre**: grade de ferro (duas folhas ou levadiça) na boca de cada porta de saída, fechada durante a luta, que sobe ou abre quando as portas abrem, com a recompensa no vão (já é `RewardGem.at_door`) | a saída vira peça monumental e o "acabou a luta" se lê na arquitetura, não só na placa (P6, P8) | `TombKit` grade, `ArenaRoom.door_arch`, `door_lamp`, gancho onde já se chama `ArenaRoom.breath` | M | environment-artist (peça), gameplay-engineer só se faltar o sinal | P2 |
| SW-G6 | **Primeiro plano sul**: tocos de coluna e aduelas que sobem do abismo ou do pé da borda sul com o topo abaixo do chão ou até 0,9 m, em silhueta escura | moldura de baixo como nos quadros de referência; profundidade sem tapar o herói (P7) | `ArenaKit.styled_build`, `Masonry` (tambores), pedra funda `CLIFF` | P | environment-artist | P2 |
| SW-G7 | **Gramática visual do perigo de sala** (para os RP do room-designer): toda peça que fere tem a mesma gravação (divisa funda em ouro velho escuro apontando para onde o golpe vai) e uma fenda âmbar apagada que acende no preparo; nunca verde, nunca violeta | o jogador aprende uma vez e lê em qualquer sala (P8); conversa com RP-06, RP-09, RP-10, RP-11, RP-12 | `ArenaHazard.chevron`, `rune_tiles.gdshaderinc`, `stele_crack.gdshader` | P (só a regra; cada peça entra com o RP dela) | art-director (spec), environment-artist | P2 |

### 3.2 Por sala

**Salão das Catacumbas (e Loja, Fonte)**
- SW-H1: dois pares de lajes emolduradas (SW-G3) ladeando o eixo da escada até o portal, entre o medalhão e o altar.
  Reforça o eixo que já leva o olho ao portal. Custo P, environment-artist, P2.
- SW-H2: Fonte: água escura que escorre da bacia pelas juntas do chão em dois ou três fios, só pintura (abaixo de
  0,15 m), sumindo a 3 m; musgo segue os fios. Dá à Fonte uma assinatura que a Loja não tem. Reusa `dark_water`,
  `FOUNTAIN_MOSS_*`. P, environment-artist, P2. (Se o RP-15 der câmaras próprias, ver SW-N4.)
- SW-H3: Loja: trilha gasta de lajes mais escuras ligando a entrada à fileira de relicários (P4 de 222445). Diz "ande
  por aqui" sem texto. P, environment-artist, P3.

**Cripta dos Esquecidos (A e B)**
- SW-C1: **lajes tumulares no chão** (lápides de chão, sem texto, moldura rebaixada, uma em cada cinco com o leão em
  relevo pequeno) em fileiras entre os sarcófagos, abaixo de 0,08 m. É a identidade de cripta mais forte que ainda não
  temos e não ocupa altura. Reusa SW-G3 e o campo do leão (`altar_lion.gdshader`). P, environment-artist, **P1**.
- SW-C2: parede norte em ossuário: prateleiras de fêmures empilhados (cilindros com cabeças) e nichos de crânios nos
  nichos que já existem, só na parede (fora do chão). Lê "catacumba" de longe, na faixa norte que a câmera vê. M,
  environment-artist (fêmur procedural), crânio depende de SW-A1. P2.
- SW-C3: grupos de urnas com velas apagadas no pé dos nichos (SW-G4). P, P3.

**Salão das Fendas (A e B)**
- SW-F1: **coluna tombada sobre a fenda**, fora do chão: tambores deitados atravessando o vão abaixo do nível do
  chão (topo a -0,3 m), quebrada no meio, com correntes. Um marco que só as Fendas têm, lido de cima como "algo caiu
  aqui". Reusa `Masonry` tambores, pedra funda. P, environment-artist, **P1** (ideia de 222527, traduzida em coluna, não
  estátua).
- SW-F2: manchas de sal cinza-pálido na beira da fenda (SW-G1), mais fortes a 1 m dos lábios. A beira se lê melhor e
  diz "cuidado, borda" sem aviso. P, technical-artist/environment-artist, P2.
- SW-F3: merlões baixos em ziguezague na borda norte, fora do chão, no lugar de um trecho de balaustrada. Quebra a
  repetição de balaústres que existe em quatro salas. P, P3.

**Jardim das Raízes Mortas (A e B)**
- SW-J1: **sombra mosqueada da copa** (SW-G2) no chão inteiro, mais densa sob a árvore. É o que mais falta ao Jardim
  para ler "luz filtrada entre folhas" e casa com a copa ferrugem do Lote C. P a M, technical-artist, **P1**.
- SW-J2: raízes rasas saindo da base das colunas e das muretas e se espalhando pelo chão em relevo de até 0,12 m (como
  222731, traduzido para o nosso tronco de pedra), sem barrar. Liga as peças à árvore do meio. Reusa o perfil de
  `StoneTree` (`ROOT_BODY`) achatado. M, environment-artist, P2. (Se o RP-10 vier, as raízes que golpeiam são outras e
  levam SW-G7.)
- SW-J3: na A, poça escura recortada num canto sem rota, fora do polígono (o corte noroeste), com mato na borda.
  Quebra o retângulo como 222420. Reusa `dark_water` `form` 0. P, P3.

**Santuário Desmoronado (A e B)**
- SW-S1: **sombra das nervuras partidas** da abóbada nos fachos (SW-G2), alongada no sentido do `STY_SHAFT_LEAN`. O
  facho deixa de ser mancha e vira "luz entrando por um teto quebrado". P a M, technical-artist, **P1**.
- SW-S2: remates nas colunas quebradas (pináculo baixo ou bloco esculpido), dentro do contorno da coluna, para a nave
  ter o ritmo de colunata de 222549. Reusa `ArenaRoom.column_kind`, `Masonry.carved`. P, environment-artist, P2.
- SW-S3: lajes emolduradas (SW-G3) no presbitério, uma fileira diante da grade, diz "chão nobre". P, P3.

**Ponte dos Condenados (A e B)**
- SW-P1: estandarte petróleo rasgado pendurado de cada corrente dos pilones, balançando devagar, fora do chão. Dá cor de
  identidade a uma sala hoje toda azul-ardósia. Reusa `ArenaKit.banner` (gêmeo petróleo). P, environment-artist, P2.
- SW-P2: patamares com lajes emolduradas em losango (SW-G3, sem círculo). Diferencia patamar de tabuleiro de ponte
  na leitura de cima. P, P2.
- SW-P3: primeiro plano sul: dois pegões de ponte antiga subindo do abismo com o topo abaixo do chão (SW-G6). P, P3.

**Câmara das Runas Instáveis (A e B)**
- O chão é o perigo: não mexer nele (P1 levado ao máximo). SW-R1: grupos de tábuas de pedra gravadas encostadas nas
  paredes norte e oeste (a prateleira de estudo do Lote D se repete em dois cantos), marcas retas, sem âmbar. Reforça
  "sala de estudo e mecanismo". P, environment-artist, P3.

**Provação**
- SW-T1: estela sobre um estrado de dois degraus baixos (até 0,3 m, dentro do contorno que já barra), com os losangos
  sulcados em volta. O evento ganha o "pedestal" de 222603 sem mudar colisão. P, environment-artist, P2.

**Altar Esquecido**
- SW-A-1: dois pedestais simétricos com bacias de água escura a 2,5 a 3 m do altar, fora da rota, com a luz fria do
  facho só neles (de pexels: simetria local marca o ponto especial). P, environment-artist, P2.

**Câmara do Selo**
- Já cumpre o princípio de 222700 (meio vazio, adereços só no anel, chão quieto para os avisos). Nada dentro do
  círculo. SW-K1 (opcional): gaiolas de ferro vazias penduradas nas correntes de fora, longe de Morvath na tela. **Aprovado
  pelo Daniel em 2026-11-19**; entra no lote da prioridade 1 (fora do círculo, longe de Morvath na tela, só no
  estilizado como o Lote E). P.

### 3.3 Salas novas (forma e cenário; a regra de jogo é do room-designer)

| Id | Sala (nome de trabalho, o nome final é do Daniel) | O que traz | Por que é distinta na câmera | Reaproveita | Custo | Dono |
|---|---|---|---|---|---|---|
| SW-N1 | Ossuário Alagado | chão de luta em três ilhas ligadas por lajes largas, canais de água escura entre elas (vazio que barra, sem queda, D-28), ossuário nas paredes | a única sala cuja forma é desenhada por água; silhueta de cima diferente de todas | `FloorShape.POLY` com buracos, `dark_water`, `broken_lip`, SW-C2 | G | room-designer (planta), environment-artist |
| SW-N2 | Claustro em Ruínas | poço quadrado com balaustrada no meio como marco que barra, quatro quadras, muretas baixas em diagonal, colunata partida em volta | marco central quadrado (não círculo) e repartição em bolsões; lê "pátio" | `Masonry`, `balustrade_edge`, `round_column`, SW-G3 | G | room-designer, environment-artist |
| SW-N3 | Galeria Alta | sala de um nível só jogável, com um terraço a 3 m ao norte e leste, balaustrada, escada que não se usa, estátuas olhando para baixo | o desnível emoldura a sala de cima (P6) sem tirar chão; primeira sala com "andar de cima" | `wall`, `balustrade_edge`, `Masonry.stairs`, estátuas do salão | M a G | environment-artist (com planta do room-designer) |
| SW-N4 | Câmara da Fonte (se o RP-15 for aprovado) | fonte encostada numa cascata alta ao norte, bacia fora do chão, musgo e água escorrendo pelas juntas | a Fonte deixa de ser o Salão de novo; a cascata é a assinatura | `ArenaKit.fountain`, `dark_water` `form` 1, SW-H2 | M | environment-artist |

## 4. Assets que faltam

**Procedural (sem créditos)**: lápide de chão com moldura (SW-C1); fêmures empilhados (cilindros e esferas, SW-C2);
portão de grade em arco, duas folhas e levadiça (SW-G5, a partir da grade do `TombKit`); estrado de degraus baixos;
pedestal com bacia (torno de perfil, como o `Masonry.urn`); coluna tombada em tambores; merlões; mais formas de urna e
pote (ânfora, jarro com alça, pote baixo) no `Masonry.urn`; raiz rasa achatada; tábua de pedra gravada; cartões de
samambaia e mato para a borda fora do chão (como os da copa, `canopy.gdshader`); máscaras de ruído para SW-G1 e SW-G2
(geradas no shader, nenhuma textura nova).

**Pediriam Meshy** (15 créditos cada peça parada com textura: prévia 5 + textura 10; **nada gerado, só com o sim do
Daniel**, saldo informado no CLAUDE.md: 546):
- SW-A1 crânio e pilha de crânios modular para o ossuário: 15.
- SW-A2 portão monumental de ferro com arco esculpido (o leão no tímpano, sem outros símbolos): 15.
- SW-A3 arco desmoronado esculpido, com relevo e aduelas soltas, para as bordas: 15.
- SW-A4 pia ou bacia esculpida com o leão: 15.
- Já no `meshy_asset_plan.md` e ainda valendo aqui: estátua encapuzada (15; deitada, também serve de estátua tombada
  sem crédito extra) e conjunto de potes (15).
Total se tudo fosse pedido: 90 créditos. Recomendação: nenhum agora; o procedural cobre o P1 inteiro.

## 5. Ordem recomendada

1. P1, uma entrega do technical-artist e do environment-artist: SW-G1, SW-G2 (Jardim e Santuário primeiro), SW-G3,
   SW-C1, SW-F1, SW-J1, SW-S1. Aceite por captura na GPU, vitrine e luta, semente 5, antes e depois: em cada sala o chão
   do meio com luma p10 a p90 pelo menos 10 níveis mais aberto que hoje, sem passar do teto de saturação da
   `art_direction.md` 3; avisos e figuras com o mesmo contraste de hoje (`--hue --box` sobre o aviso); clássico igual;
   quadro na iGPU 720 Baixa sem perder mais de 0,5 ms.
2. P2: SW-G4, SW-G5, SW-G6, SW-G7 (spec com o primeiro RP de perigo), e as P2 de cada sala.
3. Salas novas só depois da sessão do Daniel e com o room-designer.
