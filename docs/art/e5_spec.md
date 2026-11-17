# E5 "Eventos e exploração": especificação de arte das três arenas, das duas salas de evento e das portas

Autor: art-director, 2026-11-17. Para: `gameplay-engineer` (planta em dado no `_stage` do `make_data.gd`, perigo de chão
das Runas, Provação e altar como tipos de sala, o que a porta sabe da sala seguinte), `environment-artist` (construtores
`SanctuaryLook`, `BridgeLook`, `RunesLook`, as duas salas de evento, peças novas, ar e luz) e `ui-ux-designer` (placa da
porta com o tipo de sala, carta e selo da Provação). Revisão depois: `art-director` em `docs/art/visual_review.md` e na
galeria `docs/gallery/e5/`. **Só documento: nada foi implementado.** Nada vai para o Meshy; nenhuma imagem de IA nova
(nada a declarar em `docs/steam-ia.md` por causa desta spec).

- Itens do backlog: E5 (seção E5), C14-A4 a A6, D-29 (runas em faixas e ladrilhos, nunca círculos).
- Modelo seguido: `docs/art/cycle12_arenas_spec.md` (convenções da seção 0 valem aqui inteiras: eixos, câmera, corte de
  vista `1,73 x h`, regras de geometria, classes de obstáculo, regra do tiro 1,0 / 1,25 m, saídas, luz e glow) e
  `docs/design/cycle12_arenas_plan.md` (faixas de tamanho, números do herói e dos atiradores).
- Para estas arenas vale a decisão do Daniel do ciclo 12: **variedade de salas, não fidelidade a imagens**. Não há imagem
  de referência para nenhuma das três; a planta abaixo é desenhada para a câmera e os números do jogo.
- Posições na tela: calculadas com a câmera do jogo (giro 35°, inclinação 30°, campo 24°, distância 54, 1920 x 1080), a
  mesma conta que acerta o túmulo da Cripta em (981; 505). Tolerância de revisão: 40 px.

## Decisões tomadas nesta spec (o Daniel autorizou a E5 sem perguntar; anotar no backlog)

| ID proposto | Decisão | Por quê |
|---|---|---|
| E5-D1 | Cada arena nova tem **uma** decisão de combate (seção 0.2) e a planta existe para ela | aceite da E5 e do C14 |
| E5-D2 | Perigo das Runas: **ladrilhos quadrados de 3 m e faixas de ladrilhos**, ouro velho apagado em repouso, **âmbar** armando, clarão marfim-âmbar ao disparar. Nunca vermelho (é dos inimigos), nunca violeta (é de Morvath), nunca círculo (D-29) | o jogador lê "o chão" diferente de "um inimigo" sem aprender regra nova de tempo |
| E5-D3 | O perigo das Runas **fere todos** (herói e inimigos comuns; guardiões e Morvath nunca entram ali) | é a decisão da sala: atrair para a faixa que vai acender |
| E5-D4 | Santuário: o fundo é um **presbitério elevado atrás de uma grade baixa**, fora do chão andável; o guardião surge diante dela | evita bolsos de 1 a 3 m em volta de um altar andável; o guardião ganha uma entrada no fim da nave |
| E5-D5 | Ponte: **todas as saídas na plataforma de longe** e ninguém nasce em ponte | obriga a atravessar, como as Fendas |
| E5-D6 | Provação: tema sem dono. **Pedra, uma luz de cima e o violeta corrompido por baixo.** A entrada é uma **laje quadrada rachada no chão** da sala vencida (não uma porta na borda, não um círculo) | pedido do backlog; nada de deus nem personagem novo |
| E5-D7 | Maldição da Provação **sem aura no herói**: só selo no HUD, em lilás acinzentado e losango rachado | a aura violeta no corpo é da maldição de Morvath; as duas não podem se confundir |
| E5-D8 | Sala de altar: **altar de oração abandonado** sob a igreja, com o leão no frontal, velas apagadas e inscrição gasta **sem texto legível**. Nada de túmulo de Juramentado (seção 6.4) | só o que o cânone sustenta |
| E5-D9 | A porta mostra, além da recompensa, o **tipo de sala** por um pictograma e uma segunda linha, e o **ar da arena seguinte** como um bafo de luz no vão da escada | "portas que mostram o caminho" e a hipótese A (lugares ligados) |
| E5-D10 | Nomes no jogo propostos (chaves novas em `text_pt.tres`): "Santuário Desmoronado", "Ponte dos Condenados", "Câmara das Runas Instáveis" (do Daniel, D-33), "Provação" e "Altar Esquecido" (meus, provisórios) | os dois últimos o Daniel pode trocar sem mudar arte |

---

## 0. O que vale para as cinco salas

### 0.1 Convenções
Todas as da seção 0 da `cycle12_arenas_spec.md`. Lembrando as que mais pesam aqui: norte e oeste são o fundo (peças altas
permitidas), sul e leste a frente (só peças baixas ou com pontilhado `see_through`); o eixo leste-oeste aparece inclinado
19° na tela (o eixo das arenas compridas); vão de abismo que corta caminho com 6 m ou mais; corredor de 3,5 m ou mais
entre duas coisas que bloqueiam o corpo (peça encostada encosta de verdade); nenhuma peça entre 1,0 e 1,25 m de topo;
velas nunca soltas no chão andável; até 8 luzes com sombra por arena; nada no chão andável acima do limiar do glow;
mediana do chão do meio entre 45 e 60 na tela; estandartes com o leão (`ArenaKit.banner(..., Emblem.LION)`); estátuas
encapuzadas de mãos vazias; fogo sempre âmbar.

Forma das peças no dado: `ArenaObstacle` só tem círculo e caixa girada; toda "cápsula" desta spec é a caixa do
`_capsule` do `make_data.gd` (pontas quadradas), como nas arenas do C12.

### 0.2 A decisão de combate de cada arena

| Arena | A pergunta que a sala faz | O que a planta faz para isso |
|---|---|---|
| Santuário Desmoronado | **Nave ou naves laterais?** Lutar no aberto da nave (espaço para esquivar da investida do Cavaleiro, mas exposto ao leque do Ancião e aos atiradores) ou nas naves laterais atrás das colunas (o tiro para na pedra, a investida para no fuste, mas é estreito quando os invocados chegam) | duas fileiras de colunas que bloqueiam tiro, nave de 10,7 m livre, naves laterais de 7,35 m |
| Ponte dos Condenados | **Segurar a ilha ou atravessar?** Ficar na plataforma do meio e receber os de perto um a um pela ponte (gargalo de 5 m), apanhando dos atiradores do outro lado, ou atravessar sob fogo e lutar no meio deles | três plataformas sobre o abismo ligadas por pontes de 5 m; atiradores nascem na plataforma de longe; a ruína do meio é a única cobertura contra eles |
| Câmara das Runas Instáveis | **Onde estar quando o chão acender?** O chão fere todos: puxar os inimigos para a faixa que vai acender ou lutar só no que está apagado | ladrilhos de 3 m com padrões que se anunciam; a câmera fica parada para a sala inteira estar sempre à vista |

Medida (aceite da E5, "decisão medida no registro"): por sala, `RoomTally` ganha o que cada decisão precisa; proposta ao
`gameplay-engineer`: Santuário, segundos do herói na nave e nas naves laterais e investidas que pararam numa coluna;
Ponte, segundos em cada plataforma e na ponte, e tiros recebidos de outra plataforma; Runas, dano do chão no herói e nos
inimigos e abates pelo chão.

### 0.3 Peças novas comuns

| Peça | Para quê | Especificação | Dono |
|---|---|---|---|
| **Ponte de pedra comum** | Ponte (A e B) | levar o `RiftLook._bridge` (tabuleiro com lajes no sentido do vão, meio-fio, junta escura nas cabeceiras, parapeito vazado de 0,9 m fora dos 5 m, pilares de 1,4 m sobre os pegões, arco e pegões na pedra escura) para o `ArenaRoom`, lendo um `Rect2` e o lado do vão. Critério: a captura das Fendas não muda | `environment-artist` |
| **Banco de pedra** | Santuário, altar | caixa chanfrada de 2,0 x 0,6 m, assento a 0,45 m e encosto a 0,9 m (topo 0,9: não bloqueia tiro), pés em dois blocos; o partido sem o encosto em metade e com o pedaço caído dentro da caixa. Eco dos "bancos quebrados" da nave da igreja velha (cânone, seção 6.2) | `environment-artist` |
| **Grade do presbitério** | Santuário | a `Masonry.balustrade` a 0,9 m sobre a borda andável (não é obstáculo: é a borda), com dois pilares altos de 1,6 m nas pontas que levam os braseiros; o piso do presbitério 0,6 m acima do chão da nave | `environment-artist` |
| **Facho de lua** | Santuário | `SpotLight3D` frio caindo de um rombo do teto (fora do quadro) com a poeira do `Arena._dust`; o rombo desenhado como cartão de céu azul-marinho escuro com bordas de lajes partidas, só visível no alto do quadro | `environment-artist` |
| **Ladrilho de runa** | Runas | seção 3.4 (shader de chão novo e perigo novo) | `environment-artist` (aparência), `gameplay-engineer` (perigo) |
| **Laje da Provação** | Provação | seção 5.1 | `environment-artist`, `gameplay-engineer` |
| **Altar** | altar | seção 6.3 | `environment-artist` |

Reuso: `TombKit` (sarcófago com a espada em relevo, coluna inteira e quebrada, mureta, lanterna, pilarete, laje sem texto,
grade de saída), `Masonry` (cantaria, `depth_stone`, `prism`, `stairs`, `balustrade`, `post`, `obelisk`, `pointed_arch`,
`voussoir_arch`, `hooded_statue`, `candle`/`candle_out`, `pot`), `ArenaKit` (`brazier`, `banner` com o leão, `chain`,
`abyss_glow`, `mist_bank`, `ruin_card`, `statue`), `ArenaRoom` (chão de polígono com buracos, `broken_edge`,
`balustrade_edge`, `filet`, `door_arch`, saídas com escada e grade, `key_light`, `leave_air`).

---

## 1. Santuário Desmoronado (C14-A4): a casa do guardião

**Experiência**: grande e alto, uma nave de igreja subterrânea com o teto meio caído. Duas fileiras de colunas, a nave
larga no meio, naves laterais dos lados, o presbitério elevado no fundo oeste com o altar, a grade e os estandartes do
leão. Luz de lua entrando pelos rombos do teto em fachos frios; braseiros âmbar só no presbitério. O guardião surge
diante da grade, no fim da nave, a 37 m do herói.

### 1.1 Contorno

- 44 x 28 m: `x` de -22 a 22, `z` de -14 a 14 (grande, 38 a 48 m). Cerca de 1190 m² andáveis.
- Polígono (horário): (-22; -14), (14; -14), (22; -6), (22; 14), (-18; 14), (-22; 10).
- Bordas:
  - **norte** (fundo): parede de 9 m com quatro janelas ogivais cegas e rendilhado partido (sem vidro, sem figuras),
    o arranque das abóbadas saindo dela; a porta X1;
  - **nordeste** (o corte de (14; -14) a (22; -6)): o desmoronamento do teto, monte de lajes, aduelas e um pedaço de
    arco caído, de 0,3 m na beira a 4 m junto às paredes; o pé do monte é a borda;
  - **oeste** (fundo): de z -6 a 6, a **grade do presbitério** (0.3) sobre a borda; atrás dela o presbitério (x -22
    a -27), 0,6 m mais alto, com o altar; de z -14 a -6 e de 6 a 10, parede de 9 m com a porta X3;
  - **sudoeste** (o corte de (-22; 10) a (-18; 14)): blocos caídos baixos (até 0,9 m);
  - **sul** (frente): a parede cortada a 0,9 m, como a frente da Cripta, com três falhas de 2 a 3 m por onde se vê o
    escuro (sem abismo violeta); blocos caídos fora do chão;
  - **leste** (frente): a entrada e, ao norte dela, parede cortada a 0,9 m.

### 1.2 Variante A, "Nave": obstáculos

Colunas: fileira norte em `z` -6, fileira sul em `z` 6, nos `x` -15, -9, -3, 3, 9, 15. Raio 0,65 (o da base), inteiras
com 5,2 m (capitel e arranque de arco para o fundo), quebradas com o topo dado. Todas bloqueiam tiro e abrem em
pontilhado.

| Peça | Forma | Centro (x; z) | Tamanho | Topo | C (tiro) | Pontilhado |
|---|---|---|---|---|---|---|
| Colunas inteiras (9) | círculo | norte -15, -9, -3, 9; sul -15, -3, 3, 9, 15 | raio 0,65 | 5,2 | sim | sim |
| Coluna quebrada norte | círculo | (15; -6) | raio 0,65 | 3,4 | sim | sim |
| Coluna quebrada sul | círculo | (-9; 6) | raio 0,65 | 3,0 | sim | sim |
| Base da coluna caída | círculo | (3; -6) | raio 0,65 | 0,6 | não | não |
| Tambores da coluna caída | cápsula | de (3; -6,9) a (3; -9,8) | largura 1,1 | 1,0 | não | não |
| Sarcófago encostado 1 | caixa encostada na parede norte | (-12; -13,4) | 2,5 x 1,2 | 1,35 | sim | não |
| Sarcófago encostado 2 | caixa encostada na parede norte | (-4; -13,4) | 2,5 x 1,2 | 1,35 | sim | não |
| Banco partido 1 | caixa | (-12; 10,2) | 2,0 x 0,6 (leste-oeste) | 0,9 | não | não |
| Banco partido 2 | caixa | (6; 10,2) | 2,0 x 0,6 | 0,9 | não | não |

- Medidas: nave livre 10,7 m entre as faces das colunas; naves laterais 7,35 m; vão entre colunas 4,7 m; bancos a 3,7 m
  das colunas e 3,5 m da borda sul; tambores a 3,65 m da parede norte e 4,8 m das colunas vizinhas; coluna (15; -6) a
  4,3 m do corte nordeste.
- A nave fica **vazia de propósito** (a pista da investida). Enfeite (A): velas só nas tampas dos sarcófagos, nas bases das
  colunas do fundo e no presbitério; entulho baixo (até 0,15 m) junto das paredes e espalhado em volta dos tambores;
  lajes sem texto (`TombKit.slab`) em fila no meio da nave, a cada 4 m, alinhadas com o eixo.

### 1.3 Variante B, "Nave partida"

- O chão da nave cedeu: **buraco** (8,4 x 7,0 m) com os pontos (1; -3,2), (4,5; -3,5), (9; -3,1), (9,4; 0), (9; 3,1),
  (4,5; 3,5), (1; 3,2), (0,6; 0). As quatro colunas de `x` 3 e 9 caíram dentro dele (não existem no dado; os tambores e
  capitéis aparecem lá embaixo).
- Volta-se pelo buraco pelas faixas de 3 m entre ele e a linha das colunas e pelas naves laterais. Buraco a coluna (-3; ±6)
  4,2 m; a coluna (15; ±6) 6,6 m.
- **O que se vê no buraco** (não é o abismo das Fendas): 6 m abaixo, o chão de uma cripta de baixo, lajes, os tambores
  caídos, uma luz de vela âmbar fraca lá no fundo (omni sem sombra, energia 1,2, alcance 8, só na camada das profundezas
  `ArenaKit.DEPTH_LAYER`), poeira caindo. Borda quebrada (`broken_edge`) com o filete de ouro velho nas duas faces de
  frente para a câmera (sul e leste). Nada violeta.
- Demais peças: as da A, menos a coluna caída da fileira norte (base e tambores), e a coluna (-9; -6) quebrada com 3,2 m.
- Clima B: um facho de lua só (o de oeste) e mais forte (energia 2,8), poeira mais densa sobre o buraco.

### 1.4 Entrada, saídas, guardião, nascimento e câmera

| Item | Posição | Observação |
|---|---|---|
| Entrada | borda leste, `z` 0 a 4, escada subindo do leste | herói nasce em **(19,5; 2)**, olhando para o oeste (-1; 0) |
| Guardião | surge em **(-17; 0)**, de frente para o leste | diante da grade, entre os braseiros (usar `boss_spawn` do `RoomLayout` ou campo novo, decisão do `gameplay-engineer`) |
| Saída X1 | porta em ogiva na parede norte, centro (6,5; -14) | dois braseiros em rebaixos da parede (x 4,3 e 8,7, z -14,6), fora do chão |
| Saída X2 | escada descendo para o sul, centro (-6; 14) | lanterna sobre o pilar oeste da boca |
| Saída X3 | porta em ogiva na parede oeste, centro (-22; -10,5) | lanterna no rebaixo |
| Zona 1 | x -20 a -14, z -3 a 3 | diante do presbitério |
| Zona 2 | x -19 a -15, z 8 a 11 | |
| Zona 3 | x -8 a -2, z -12 a -8,5 | nave lateral norte |
| Zona tardia 4 | x 10 a 16, z 8 a 12 | só da 2ª onda (7,8 m ou mais do herói na entrada) |
| Câmera | segue o herói; alvo no retângulo **x -10 a 10, z -2 a 2** (`cam_bounds`) | vitrine: alvo (0; 0) |

Na vitrine (alvo (0; 0)): altar em (202; 275), grade de (425; 218) a (61; 379), porta X1 em (1519; 378), centro do buraco B
em (1162; 611). Com o alvo no limite oeste (-10; 0), o altar vem para (482; 373): o presbitério inteiro no terço esquerdo.

Dado: `size_class` LARGE, `difficulty` 2, `depth` (0,4; 1,0), `guardian` true, `max_alive` (6; 8) como luta comum e o
teto do tier difícil (8 a 12) quando é a sala do guardião, `max_ranged` 3.

### 1.5 Material, paleta e luz

- **Chão**: o mais claro e menos saturado das arenas, calcário cinza morno: `stone_a` (0,31; 0,30; 0,29), `stone_b`
  (0,41; 0,39; 0,37), juntas (0,10; 0,09; 0,09), lajes **compridas no sentido da nave** (2,4 x 1,2 m, se o
  `catacomb_floor` aceitar `unit` por eixo; senão `unit` 1,2), musgo quase nenhum, sem medalhão, rachaduras finas em
  volta do monte nordeste e da borda do buraco B. Alvo: mediana do chão do meio perto de #3a3936 fora dos fachos e até
  70 dentro deles.
- **Colunas e paredes**: `ashlar` com multiplicador (1,0; 0,98; 0,95), um passo mais escuras que o chão; capitéis
  simples (anel e ábaco), sem figura.
- **Presbitério**: piso do mesmo calcário 10% mais claro; o altar (caixa chanfrada 3,0 x 1,4 x 1,3 m) com o frontal
  liso e uma faixa de ouro velho sem brilho; atrás, a janela ogival grande cega (rendilhado, 3 x 7 m) e, nos lados,
  dois estandartes com o leão (2,2 m de pano) e duas estátuas encapuzadas em nichos. Velas acesas no altar e nos degraus.
- **Ar**: fundo (0,05; 0,055; 0,07), névoa (0,10; 0,11; 0,14), ambiente (0,34; 0,34; 0,36) energia 0,75; lua
  (0,70; 0,78; 0,92) energia 0,2 sem sombra (a sombra vem dos fachos).
- **Luz** (com sombra: no máximo 6):
  1. **dois fachos de lua** (A): `SpotLight3D` (0,70; 0,78; 0,92), energia 2,2, cone 22°, de 16 m de altura, caindo na
     nave em (-9; 0) e (9; 2), com sombra: as colunas riscam faixas no chão. O chão dentro do facho não passa de 1,35
     vez a luminância do chão em volta e nunca do limiar do glow; a sombra das colunas fica acima de 60% do chão
     iluminado (não pode parecer aviso). B: um facho só;
  2. dois braseiros nos pilares da grade, em (-22,8; -6,6) e (-22,8; 6,6), fora do chão, com sombra;
  3. velas do altar, um grupo com sombra;
  4. sem sombra: lanternas das saídas, velas das tampas, o fundo do buraco B.
- **Diferença das outras**: o único salão "de igreja" (nave, colunas em fila, presbitério), o chão mais claro e cinza, a
  luz de lua vinda **de cima** em fachos. Cripta é castanha e fechada; Fendas, violeta de baixo; Jardim, morno com a
  árvore; Ponte, azul-aço e aberta.

---

## 2. Ponte dos Condenados (C14-A5)

**Experiência**: comprida, aberta, ventosa. Três plataformas de pedra sobre um abismo azul-acinzentado, ligadas por pontes
em arco de 5 m; a luz é a lua, fria e de cima; lanternas âmbar marcam as cabeceiras. Correntes enormes descem do alto do
quadro até um pilone na plataforma do meio. O eixo comprido é o leste-oeste (19° na tela); a câmera anda ao longo dele.

### 2.1 Variante A, "Três plataformas": contorno

- 56 x 18 m: `x` de -28 a 28, `z` de -9 a 9 (comprida, 45 a 56 m no eixo, 14 a 20 de largura). Chão = união de cinco
  polígonos (sobrepostos 0,05 m nas emendas, para a união não abrir fresta):
  - **Plataforma oeste** (entrada, 14 x 18): (-28; -6), (-25; -9), (-15; -9), (-14; -7), (-14; 7), (-16; 9), (-26; 9), (-28; 7);
  - **Ponte 1**: `x` -14 a -7, `z` -2,5 a 2,5 (7 m de vão, 5 m andáveis);
  - **Plataforma do meio** (14 x 16): (-7; -6), (-5; -8), (5; -8), (7; -6), (7; 6), (5; 8), (-5; 8), (-7; 6);
  - **Ponte 2**: `x` 7 a 14, `z` -2,5 a 2,5;
  - **Plataforma leste** (saídas, 14 x 18): (14; -7), (15; -9), (25; -9), (28; -6), (28; 7), (26; 9), (16; 9), (14; 7).
- Cerca de 770 m² andáveis. Abismo entre plataformas: 7 m (maior que a esquiva de 5,6 m, regra 1).
- Bordas: **norte** de cada plataforma, `broken_edge` com lábio quebrado e lajes saindo da queda (as do C12); **sul** de
  cada plataforma e as faces leste e oeste fora das pontes, `balustrade_edge` baixa com pontilhado nos pilares (é a
  frente); pontes com o parapeito vazado de 0,9 m (0.3); nas quatro cabeceiras, pilar com lanterna e uma estátua
  encapuzada sobre plinto **fora** do chão, olhando para a ponte.

### 2.2 Variante A: obstáculos

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Coluna quebrada oeste | círculo | (-21; -4) | raio 0,7 | 3,0 | sim | sim |
| Pilone de corrente | caixa encostada na borda norte do meio | (0; -7,2) | 2,8 x 1,6 | 6,0 | sim | sim |
| Ruína de parede do meio | caixa | (2,5; 2,5) | 1,0 x 3,2 (norte-sul) | 2,2 (topo quebrado, 1,7 a 2,2) | sim | sim |
| Coluna quebrada do meio | círculo | (-2,5; 3,5) | raio 0,7 | 3,4 | sim | sim |
| Sarcófago leste | caixa | (21; -4,8) | 2,5 x 1,2 | 1,35 | sim | não |
| Coluna quebrada leste | círculo | (20; 4,5) | raio 0,7 | 3,6 | sim | sim |

- Medidas: ruína a 4 m da borda leste do meio e 4,2 m do canto sudeste; coluna do meio a 3,8 m da borda oeste (fora da
  boca da ponte) e da sul; coluna leste a 3,8 m da borda sul; sarcófago a 3,6 m da borda norte; coluna oeste a 4,3 m da
  borda norte.
- **A ruína do meio fica do lado leste de propósito**: é a cobertura contra os atiradores da plataforma leste (mago
  13,1 m, besteiro 12 m alcançam o meio por cima do abismo; tiro passa sobre buraco). O pilone fica no fundo.
- **Pilone**: o `CatacombHall._pylon` (ciclo 6) no tamanho da tabela, com duas correntes grossas (`ArenaKit.chain`,
  tamanho 2) subindo para o noroeste e saindo pelo alto do quadro, e uma terceira descendo para o abismo. Nada pendurado
  nas correntes (sem gaiolas, sem corpos: o nome da arena não ganha explicação nossa).

### 2.3 Variante B, "A ponte longa"

- Chão: plataforma oeste (16 x 18): (-28; -6), (-25; -9), (-13; -9), (-12; -7), (-12; 7), (-14; 9), (-26; 9), (-28; 7);
  **ponte longa** `x` -12 a 12, `z` -2,5 a 2,5 (24 m de vão, 3,6 s a pé); **patamar** no meio da ponte `x` -3 a 3, `z`
  -4,5 a 4,5 (parte da ponte, com parapeito em volta); plataforma leste espelhada: (12; -7), (13; -9), (25; -9), (28; -6),
  (28; 7), (26; 9), (14; 9), (12; 7).
- A pergunta muda: não há ilha. Atravessa-se 24 m de corredor de 5 m com os de perto vindo pela ponte e os atiradores na
  ponta. O patamar é o único lugar para esquivar de lado.
- Obstáculos: coluna oeste (-21; -4), sarcófago e coluna leste da A; nada na ponte nem no patamar (ponte de luta limpa).
  Sob a ponte longa, três arcos (`voussoir_arch`, vão de 7 m) e quatro pegões descendo na bruma; o patamar sobre o pegão
  do meio, com duas estátuas encapuzadas nos cantos de fora.
- Clima B: bruma mais alta (as faixas laterais sobem até 1 m abaixo do tabuleiro) e vento mais forte nas faixas.

### 2.4 Entrada, saídas, nascimento e câmera (A e B)

| Item | Posição | Observação |
|---|---|---|
| Entrada | escada subindo do oeste, boca centrada em (-28; 0) | herói nasce em **(-24,5; 0)**, olhando para o leste |
| Saída X1 | escada descendo para o norte, centro (21; -9) | pilares e lanterna; é a do fundo, lida mais longe |
| Saída X2 | escada descendo para o leste, centro (28; 0,5) | lanterna |
| Saída X3 | escada descendo para o sul, centro (21; 9) | lanterna |
| Zona 1 (A) | x -4 a 4, z -5,5 a -3 | meio, atrás do pilone |
| Zona 2 | x 17 a 24, z -7,5 a -1 | leste |
| Zona 3 | x 17 a 24, z 1 a 7,5 | leste (os pontos dentro da coluna caem pela regra de folga) |
| Zona tardia 4 | x -26 a -20, z -7 a -4 | oeste, só da 2ª onda: o herói que atravessou é cercado por trás |
| Câmera | segue; alvo no retângulo **x -14 a 14, z -1 a 1** | vitrine: alvo (0; 0) |

- **Todas as saídas na plataforma leste** (E5-D5). Ninguém nasce em ponte nem no patamar. Na B não há zona 1.
- Dado: `size_class` LONG, `difficulty` 2, `depth` (0,5; 1,0), `guardian` false, `max_alive` (6; 8) com no máximo 5
  numa plataforma (regra de onda por plataforma do plano, `gameplay-engineer`), `max_ranged` 3, `banned_roles`
  [`area`] (a trepadeira do sacerdote numa ponte de 5 m não deixa sair de lado).
- Vitrine (alvo (0; 0)): fim oeste em (102; 240), pilone em (1138; 413), ponte 1 em (591; 411), ponte 2 em (1408; 697),
  porta X1 em (2097; 659), fora do quadro: com o alvo no limite leste (14; 0) a plataforma do meio fica em (482; 373) e o
  fim leste em (1579; 757). A sala não cabe inteira (é comprida de propósito): o vídeo de travessia é o critério.

### 2.5 Material, paleta e luz

- **Chão das plataformas**: azul-aço, lajes médias (`unit` 1,2): `stone_a` (0,25; 0,27; 0,31), `stone_b` (0,34; 0,37;
  0,42), juntas (0,07; 0,08; 0,10), líquen cinza só junto das bordas norte, rachaduras densas a até 2 m de toda borda.
  Pontes: as lajes do tabuleiro das Fendas, no sentido do vão, meio-fio claro. Alvo: mediana do chão do meio perto de
  #343a44.
- **Peças**: `ashlar` frio (0,94; 0,98; 1,05).
- **Abismo**: o mais escuro e menos violeta de todos. Bruma azul-acinzentada (0,18; 0,21; 0,28) em faixas que **correm
  de lado** devagar (o vento: `mist_bank` com deslocamento em `x` de 0,4 m/s, alfa 0,2 a 0,3), `abyss_glow` violeta só
  como um fio fraco lá embaixo (energia 0,4 da das Fendas). Ao fundo (norte e oeste), `ruin_card` de torres partidas e
  dois pilones distantes com correntes.
- **Ar**: fundo (0,035; 0,045; 0,07), névoa (0,09; 0,11; 0,16), ambiente (0,30; 0,34; 0,42) energia 0,75.
- **Luz** (com sombra: no máximo 4):
  1. **lua** direcional (0,62; 0,72; 0,95), energia 0,55, do noroeste e do alto, com sombra (as balaustradas e as
     estátuas riscam o chão);
  2. lanternas das quatro cabeceiras (energia 1,5, alcance 4,5), as duas da ponte 2 com sombra (a ponte que leva à
     batalha). B: as duas cabeceiras da ponte longa do lado leste com sombra;
  3. sem sombra: lanterna de cada saída, as outras cabeceiras.
- **Diferença das outras**: a única sala aberta dos dois lados e comprida; azul-aço e lua, o abismo cinza com vento, não
  violeta. As Fendas são violeta de baixo e cabem numa sala; aqui a sala é uma travessia.

---

## 3. Câmara das Runas Instáveis (C14-A6)

**Experiência**: média, quadrada, de pedra escura e fria, sem enfeite no chão: o chão **é** a sala. Ladrilhos de 3 m com
caixilhos de ouro velho entalhados; quatro pilares de runa nos nós da grade. Em ritmo, faixas e grupos de ladrilhos
esquentam em âmbar e disparam um clarão que fere quem está em cima. Câmera parada: o jogador vê o chão inteiro.

### 3.1 Contorno

- 30 x 24 m: `x` de -15 a 15, `z` de -12 a 12, cantos chanfrados de 3 m (nunca redonda: D-29 vale também para a forma da
  sala). Polígono: (-15; -9), (-12; -12), (12; -12), (15; -9), (15; 9), (12; 12), (-12; 12), (-15; 9). Cerca de 700 m².
- **Grade**: ladrilhos de 3 x 3 m alinhados com os eixos, colunas 0 a 9 de oeste a leste (`x` -15, -12 ... 12), linhas 0 a
  7 de norte a sul (`z` -12, -9 ... 9). Os ladrilhos cortados pelos chanfros não acendem.
- Bordas: **norte** (fundo), parede de basalto de 7 m com três estelas altas (1,2 x 5 m) cobertas de marcas retas
  entalhadas (só traços e ângulos, nenhuma curva, nenhum círculo, nada legível), a porta X1 entre elas; **oeste**
  (fundo), parede de 7 m com a arcada de entrada; **sul e leste** (frente), balaustrada sobre o abismo com pontilhado
  nos pilares; chanfros: o canto da parede (noroeste) ou um pilar da balaustrada (os outros três).

### 3.2 Variante A, "Faixas"

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Pilar de runa (4) | caixa | (-6; -6), (6; -6), (-6; 6), (6; 6) | 1,2 x 1,2 | 4,0 | sim | sim |

- Os pilares ficam nos nós da grade (cantos de quatro ladrilhos); os ladrilhos em volta deles acendem normalmente. Pilares a
  12 m um do outro e 8,4 m das paredes.
- **Padrões da A** (só faixas): uma faixa = uma linha (3 x 30 m) ou uma coluna (3 x 24 m) de ladrilhos.
  - *Varredura*: duas linhas separadas por três, andando uma linha por disparo, de norte a sul e de volta;
  - *Pente*: as linhas pares, depois as ímpares (só quando a sala tem 3 ou menos inimigos de pé);
  - *Corte*: uma linha e uma coluna, a cruz passando por um ladrilho perto do herói (nunca o dele no começo do aviso).
- Enfeite: nenhum no chão. Velas só nos ressaltos das estelas (apagadas na A, metade acesa na B).

### 3.3 Variante B, "Ladrilhos"

- Pilares só dois, na diagonal: (-9; -6) e (9; 6). No meio, a **pedra quieta**: os quatro ladrilhos de `x` -3 a 3, `z`
  -3 a 3 em basalto liso, sem caixilho de ouro, que nunca acendem (o lugar seguro que atrai todos, inimigos também).
- **Padrões da B** (ladrilhos): *Xadrez* (metade dos ladrilhos, de cor alternada; todo ponto fica a até 1,5 m de um
  ladrilho apagado), *Moldura* (o anel quadrado de ladrilhos da borda, depois o anel de dentro), *Ilhas* (blocos de 2 x 2
  ladrilhos espalhados, até 4).
- Clima B: metade das velas das estelas acesas, luz de cima um passo mais fria.

### 3.4 O ladrilho de runa e o perigo (aparência; números de tempo propostos)

O perigo é um sistema novo (o "F" do plano, `ArenaHazard`); o tempo e o dano são do `gameplay-engineer`. O que a arte
precisa dele: cada ladrilho com um estado (repouso, armando com fração 0 a 1, disparo, recarga) num MultiMesh ou num
uniforme de máscara para o shader do chão (um `Image` de 10 x 8 com o estado por texel, como o `lion_sdf`).

| Estado | Duração proposta | Aparência |
|---|---|---|
| Repouso | | caixilho de ouro velho apagado (`gold_light` (0,478; 0,384; 0,22) só no albedo, sem emissão), entalhe de 0,12 m de largura e 0,03 de fundo; dentro do ladrilho, três marcas retas gastas no mesmo ouro, contraste até 15% |
| Armando | **1,2 s** (os avisos dos inimigos ficam entre 0,8 e 1,2: o mesmo ritmo) | o caixilho esquenta de ouro velho a âmbar (1,0; 0,62; 0,25), maior canal da emissão subindo até 1,0 no fim; as marcas de dentro acendem uma a uma; o preenchimento âmbar fraco (alfa 0,08) até 70% e subindo a 0,3 nos últimos 30% (o mesmo `fill_late` dos avisos, para a mão aprender uma vez); nas faixas que andam, divisas âmbar no sentido da próxima faixa; faíscas violeta curtas (0,08 m, até 1,1, 4 por ladrilho por segundo) correndo pelas rachaduras: a instabilidade |
| Disparo | **0,25 s** (o dano é no primeiro quadro) | uma lâmina de luz marfim-âmbar (1,0; 0,88; 0,70) subindo 0,4 m do ladrilho inteiro, por `ScreenTone` com teto `SAFE` (226 na tela), por cima do que está atrás (`blend_premul_alpha`), aberta em volta do herói (`hero_hole`) como as colunas de luz; lascas cinza-pedra (as `Combat.CHIP_*`) e um tranco de câmera mínimo só se o herói estiver em cima |
| Recarga | **2,4 s** até o próximo padrão (rápido demais vira ruído) | o caixilho volta ao ouro velho em 0,4 s, com um resto de brasa nos cantos que some |

Regras de leitura (aceite):
- Desenhado **por baixo** dos avisos dos inimigos e por cima do chão (o vermelho sempre vence). Stencil próprio (3) para
  dois padrões não somarem.
- No máximo 35% do chão armando ao mesmo tempo (o *Xadrez* é a exceção, 50%, e só com 3 inimigos ou menos); de todo ponto
  do chão, um ladrilho apagado a até 3 m (0,45 s a pé) no começo do aviso.
- Nunca um padrão nos 3 primeiros segundos da sala nem sob o herói recém-chegado; nunca nos ladrilhos da boca de uma
  saída aberta.
- Quatro luzes no máximo seguindo o perigo (uma omni âmbar por faixa armando, energia até 1,0, sem sombra, só no
  Forward+); no Compatibility só a emissão.
- Os pilares de runa acendem junto: o entalhe deles esquenta no mesmo âmbar enquanto qualquer padrão arma (a sala é a
  fonte, não um inimigo).
- Nunca círculo, arco nem anel redondo, em nada: caixilhos, marcas, divisas, faíscas em traço.

### 3.5 Entrada, saídas, nascimento e câmera

| Item | Posição | Observação |
|---|---|---|
| Entrada | arcada na parede oeste, centro (-15; 3,5) | herói nasce em **(-12,5; 3,5)**, olhando para o leste |
| Saída X1 | porta em ogiva na parede norte, centro (6; -12) | braseiros em rebaixos (x 3,8 e 8,2, z -12,6) |
| Saída X2 | escada descendo para o leste, centro (15; 0) | lanterna |
| Saída X3 | escada descendo para o sul, centro (-4,5; 12) | lanterna |
| Zona 1 | x -4 a 3, z -11 a -8 | |
| Zona 2 | x 10 a 13,5, z -4 a 4 | |
| Zona 3 | x 0 a 9, z 8 a 11 | |
| Zona tardia 4 | x -13 a -9, z -9,5 a -6 | |
| Câmera | **fixa**, alvo (0,5; 1), `cam_reach` 3,5, `CamFrame.hold` | a sala inteira no quadro: canto noroeste (858; 214), nordeste (1706; 450), sudeste (1155; 1030), sudoeste (158; 585); centro (968; 514) |

Dado: `size_class` MEDIUM, `difficulty` 2, `depth` (0,5; 1,0), `guardian` false, `max_alive` (4; 6) (o chão vale por um
ou dois), `max_ranged` 2, `banned_roles` [`area`] (a trepadeira rasteja por cima dos ladrilhos e confunde o chão).

### 3.6 Material, paleta e luz

- **Chão**: pedra fria neutra, `stone_a` (0,27; 0,27; 0,30), `stone_b` (0,36; 0,36; 0,40), um ladrilho de 3 m por laje
  (as juntas são os caixilhos), sem musgo, rachaduras finas atravessando ladrilhos (onde correm as faíscas). Alvo:
  mediana do chão do meio perto de #38383f em repouso.
- **Paredes, estelas e pilares**: basalto azul-negro (`ashlar` com multiplicador (0,72; 0,74; 0,82)), entalhes em ouro
  velho apagado.
- **Ar**: fundo (0,03; 0,03; 0,05), névoa (0,07; 0,07; 0,10), ambiente (0,30; 0,31; 0,36) energia 0,7.
- **Luz** (com sombra: no máximo 4): luz de cima fria e larga (`key_light` (0,78; 0,82; 0,95), energia 1,8, sem sombra);
  dois braseiros da X1 com sombra; um grupo de velas das estelas com sombra (B).
  **Nenhuma luz quente no chão longe das paredes**: o âmbar no chão é só das runas. Poça de braseiro no chão andável no
  máximo a 2 m da parede norte.
- **Diferença das outras**: a única sala onde o chão é o perigo; geometria regular, quadrada, nenhuma ruína no meio; a
  luz da sala é fria e o calor é o aviso.

---

## 4. As oito salas lado a lado (miniatura de 320 px deve distinguir todas)

| | Tamanho andável | Câmera | Ar | Chão | Luz que manda | Marco |
|---|---|---|---|---|---|---|
| Salão das Catacumbas | 32 x 30 | segue | teal | lajes mornas, medalhão | portal verde | portal no alto à direita |
| Cripta | 24 x 21 | fixa | castanho escuro | lajes pequenas frias | velas em poças, facho frio | túmulo no meio |
| Fendas | 42 x 30 | anda | azul-violeta | lajes grandes azuis | violeta de baixo | a fenda na diagonal |
| Jardim | 34 x 28 | anda pouco | cinza frio | lajes mornas partidas | facho na árvore | a árvore |
| **Santuário** | 44 x 28 | anda no eixo | cinza neutro claro | calcário em lajes compridas | fachos de lua de cima | nave, colunas em fila, presbitério |
| **Ponte** | 56 x 18 | anda no eixo | azul-aço | lajes azul-aço, pontes | lua direcional, lanternas | pontes e o pilone com correntes |
| **Runas** | 30 x 24 | fixa | quase preto frio | ladrilhos de 3 m com caixilho de ouro | o próprio chão em âmbar | a grade de ladrilhos |
| Câmara do Selo | círculo de 25 | fixa | azul-marinho e violeta | selo | lanternas violeta | o selo e a porta |

---

## 5. Provação (evento; molde do Caos do Hades II)

Mecânica do backlog (`hades2_sistemas.md` seção 7): ao limpar uma sala, pode surgir a entrada; entrar custa
`teto(10 + 0,5 x profundidade)` de vida; dentro, uma escolha de maldição por 3 a 5 encontros que depois vira bênção.
Tema sem dono (E5-D6): **a pedra guarda uma corrupção por baixo; uma luz de cima a segura. Quem paga com vida aceita
carregar a corrupção um trecho e sai dela mais forte.** Nenhuma voz, nenhum rosto, nenhum símbolo novo, nenhum nome além
de "Provação".

### 5.1 A entrada: a laje rachada

- Surge no chão da sala vencida (lugar livre a 4 m ou mais de saídas, peças e bordas; `gameplay-engineer`), em 1,2 s,
  depois da recompensa.
- **Forma**: laje **quadrada** de 2,4 x 2,4 m, alinhada com os eixos da sala, 0,04 m acima do chão, com moldura entalhada
  de 0,15 m (sem ouro) e uma **rachadura em X** de canto a canto. Nada redondo.
- **Luz**: pelas rachaduras, violeta corrompido pálido (0,52; 0,36; 0,78), emissão até 0,8 no maior canal (abaixo do
  glow), pulsando devagar (±15% a 0,3 Hz); fiapos de bruma violeta subindo 0,6 m (`mist_bank` pequeno, alfa 0,2). Por
  cima, um **fio de luz marfim** vertical de 0,25 m de largura descendo do alto do quadro até o meio da laje (a luz que
  segura), pelo `Fx.beam` com `Fx.BEAM_CORE_CAP`, passando por `Game.column` (fraco perto do herói).
- **Placa** (`DoorSign`): "Provação" em ouro claro e, embaixo, "Custa {n} de vida" em marfim; sem vida bastante, a segunda
  linha vira "Vida insuficiente" no `SHORT_COLOR` e a laje não aceita. Pictograma: o losango rachado (seção 7).
- **Ao entrar**: a rachadura abre em 0,3 s, o violeta sobe e a tela escurece como nas portas; o custo aparece como golpe
  sofrido **sem** a borda vermelha (só o número de vida perdida em lilás pálido sobre o herói).

### 5.2 A Câmara da Provação

- **Tamanho**: 16 x 14 m (`x` -8 a 8, `z` -7 a 7), retângulo com cantos chanfrados de 1,5 m, sem combate. Câmera fixa no
  alvo (0; 0,5).
- **Paredes**: `depth_stone` escuro (a pedra das profundezas), próximas, 8 m, sem janela; quatro pilares quadrados
  partidos nos cantos chanfrados (fora do chão). Nenhuma estátua, estandarte, vela ou leão: a sala não é de ninguém.
- **Chão**: lajes grandes (`unit` 1,6) em (0,24; 0,23; 0,27) / (0,30; 0,29; 0,33), cortadas por **veios violeta** que
  saem das paredes e vão para o meio (o desenho dos veios da fase 4 da câmara, `vein_*`, mais esparsos e em lilás
  (0,52; 0,36; 0,78), emissão até 0,5), parando a 1,5 m da peça do meio.
- **Peça do meio**: um bloco **quadrado** de pedra de 1,2 x 1,2 m e 1,1 m (caixa chanfrada; o tiro não importa aqui), no
  centro, com a mesma rachadura em X no topo. Sobre ele cai a luz: `SpotLight3D` marfim (1,0; 0,95; 0,85), energia 3,0,
  cone 20°, de uma abertura **quadrada** no teto fora do quadro, com sombra (a única). A poça de luz é luz, não marca no
  chão.
- **Escolha**: o herói pisa diante do bloco e a tela de escolha abre com as cartas da Provação (seção 5.3). Depois da
  escolha: os veios perdem 60% da luz em 1,5 s, a bruma baixa, a rachadura do bloco escurece; a saída abre.
- **Entrada e saída**: o herói chega por uma escada no canto sudoeste (nasce em (-5,5; 4,5)); sai por uma escada subindo
  no norte, centro (0; -7), que só se abre depois da escolha, com uma lanterna fria marfim (sem fogo âmbar aqui).
- **Ar**: fundo (0,03; 0,02; 0,05), névoa (0,08; 0,05; 0,12), ambiente (0,22; 0,20; 0,28) energia 0,5. Sala de evento,
  sem a regra de mediana 45 a 60 do chão de luta: a poça de luz perto de 60, o resto entre 25 e 40.
- **Na tela** (alvo (0; 0,5)): bloco em (973; 530); a sala ocupa de cerca de (878; 349) a (1101; 772) e o resto do quadro
  é parede e escuro desenhados (paredes de 8 m preenchem o alto; a frente sul cortada a 0,9 m sobre o preto).

### 5.3 A carta, o selo e a virada (para o `ui-ux-designer`)

- **Carta da Provação**: a `BoonCard` com o corpo dividido: em cima a bênção (o que vai ganhar, nome em marfim, raridade
  na borda como as outras), embaixo a provação numa faixa de tinta lilás-escura (0,16; 0,12; 0,22) com o texto em lilás
  pálido (0,82; 0,76; 0,92) e a duração ("Por 3 encontros"). Família: "Provação". Sem medalhão pintado; o ícone é o
  losango rachado. Proteção de 350 ms como as outras.
- **Selo no HUD** enquanto dura: junto ao medalhão do herói, um losango de 30 px a 1080, lilás acinzentado
  (0,62; 0,56; 0,74), com a rachadura e o número de encontros que faltam dentro; nada no corpo do herói, na Emeth nem no
  chão (E5-D7). Ele não usa o anel que esvazia do `ConditionBadge` da maldição de Morvath (aquele é de segundos).
- **A virada** (fim do último encontro): a rachadura do selo se enche de ouro velho em 0,4 s e o losango vira o ícone da
  bênção; no herói, as partículas de luz marfim de sempre (`&"light"`, `Fx.hero_burst`), uma vez; a faixa "Provação
  vencida" pelo `EloBanner` (mesmo molde do "Elo formado", sem pausar).
- **Cores proibidas aqui**: o violeta saturado (0,55; 0,25; 1,0) do abismo e de Morvath, o verde espectral, o vermelho.

---

## 6. Sala de altar: "Altar Esquecido" (evento curto, sem combate)

### 6.1 O que o cânone sustenta (`../dungeon-rpg/docs/mundo/canone.md`, cânone de 12/11/2026)

| Trecho | Onde | O que vira na sala |
|---|---|---|
| "**Sobre cada selo foi construída uma igreja**, para que a oração nunca deixasse de pesar sobre ele." | "As igrejas e as fontes de luz" | um altar de oração sob a igreja velha |
| "Passa a ser um lugar de verdade [...]: nave abandonada, bancos quebrados, telhado meio caído [...] A igreja ficou vazia há cinquenta anos" | "A igreja velha de Valmor" | altar abandonado, velas apagadas, poeira, um banco inteiro e um partido |
| "Abrir um selo exige três coisas: 1. A fé morta no lugar: a igreja em cima vazia." | "Como se abre um selo" | o altar sem ninguém há muito tempo; nada mais é dito |
| "Três símbolos que nunca se confundem: o leão (Hanokh e Elun), a espada erguida (os guardiões dos selos) e o olho cortado ao meio (a Irmandade)" | "O leão" | só o **leão** no altar (é um altar de Elun); nem espada erguida (é dos Juramentados) nem olho |
| "Nada de sermão, nada de versículo citado em fala, Deus nunca é personagem." e "Os ecos bíblicos ficam [...] nos símbolos (leão, fonte, pomba de luz, sino)." | "A fé na narrativa" | nenhum texto citado na sala; a inscrição é gasta e ilegível |

### 6.2 O que não entra (e por quê)

- **Texto legível na inscrição**: nenhum. O cânone tem o Éowen ("a língua que foi ensinada por Yah", seção "Éowen, a língua
  esquecida"), mas dizer que a inscrição está em Éowen, ou o que ela diz, é decisão do Daniel. Até lá: linhas de marcas
  gastas, sem forma de letra.
- **Túmulo de um Juramentado** (o outro altar possível): o cânone os põe "enterrados ao redor da igreja, com a espada
  erguida como sinal", e para abrir o selo "os quatro guardiões desenterrados: as pedras deles fora da terra consagrada".
  Valmor foi aberto, então um jazigo intacto contradiz e um violado conta história. Fica como **pergunta ao Daniel** (6.4).
- **A Lâmpada** e o nicho sob o leão: são do selo de Valmor (a Câmara do Selo) e da trama do Velkor; fora desta sala.
- **Sino, Sineiro, pomba de luz**: símbolos do cânone, mas ligados a personagens e à história; não usar sem o Daniel.

### 6.3 Aparência

- **Tamanho**: 18 x 14 m (`x` -9 a 9, `z` -7 a 7), retângulo, sem combate, câmera fixa no alvo (0; 0). Uma capela.
- **Altar**: encostado na parede norte, caixa chanfrada de 3,6 x 1,6 m (centro (0; -6,2)), topo 1,3, sobre um degrau
  de 0,15 que faz parte da caixa. **No frontal (a face sul, de frente para a câmera), o leão rampante em relevo** (o
  campo de distância `lion_sdf` do selo, em pedra, sem ouro e sem brilho, 1,0 m de altura). No topo, uma toalha de pedra
  (aba de 0,05 m) e onze velas **apagadas** (`Masonry.candle_out`), cera escura `WAX_OUT`.
- **Parede norte**: arco ogival cego sobre o altar (3,6 x 6 m) e, na verga, a **faixa da inscrição**: 4 x 0,6 m a 2,8 m
  do chão, três linhas de marcas entalhadas gastas, metade apagada por lascas e uma rachadura, ouro velho só no fundo
  das marcas que restam, sem brilho. Dois estandartes com o leão, desbotados (o vermelho 30% mais apagado que nas arenas)
  e um rasgado na ponta.
- **Bancos**: dois bancos de pedra (0.3) de frente para o altar, em (-3; -1) inteiro e (3; -1,5) partido; poeira e lajes
  soltas no corredor do meio. Classe B (bloqueiam o corpo, não o tiro).
- **Chão**: o do Salão das Catacumbas (as lajes mornas), sem medalhão, com uma faixa de lajes mais gastas no eixo da
  porta ao altar (o caminho de quem rezava).
- **Luz** (com sombra: 2): um facho frio de uma fresta do teto sobre o altar (`SpotLight3D` (0,70; 0,78; 0,92), energia
  2,0, cone 16°, com sombra, com poeira); a lanterna da saída sem sombra; **depois do evento**, as velas do altar acesas
  (um grupo com sombra, energia 1,6) e o leão do frontal pegando a luz quente.
- **Ar**: o do Salão (teal), ambiente 10% mais escuro.
- **Estados**: *intocado* (velas apagadas, só o facho frio, poeira caindo) e *depois* (velas acesas, a luz quente sobe
  pelo frontal e pelos estandartes, a poeira assenta). O que o herói ganha ou troca ali é do `gameplay-engineer` e do
  Game Director; a arte só pede os dois estados. Proposta de interação: pisar na laje gasta diante do degrau (1,5 x 1,5,
  quadrada), com a placa "Altar Esquecido".
- **Entrada e saída**: escada no canto sudoeste (herói nasce em (-6,5; 4,5)); saída por uma porta na parede leste, centro
  (9; 2), que abre depois do evento.
- **Na tela** (alvo (0; 0)): altar em (1091; 446), cantos de (833; 346) a (1133; 804).

### 6.4 Perguntas ao Daniel (pelo Game Director)

1. A inscrição pode ser em Éowen? Se sim, ela diz alguma coisa (que só o Daniel escreve)?
2. Os Juramentados de Valmor estão nas catacumbas ou no chão em volta da igreja? Um jazigo violado de um Juramentado, com
   a espada erguida, pode ser uma sala de evento?
3. "Provação" e "Altar Esquecido" como nomes no jogo.

---

## 7. Portas que mostram o caminho

Hoje (`Rooms._open_doors`, `_marker`): a gema na cor da recompensa (forma por recompensa), a luz da boca na mesma cor e a
placa `DoorSign` com o nome da recompensa (ou do tipo, fora das lutas). O que entra (E5-D9):

### 7.1 O tipo de sala na placa

- A placa ganha um **pictograma** à esquerda do nome (vetor, `UiKit`, traço marfim de 2 px a 1080 com contorno escuro, a
  altura das maiúsculas do `DoorSign.CAP_PX`) e, quando a sala não é uma luta comum, uma **segunda linha** com o tipo em
  marfim pálido (`DETAIL_COLOR`).

| Sala | Linha 1 | Linha 2 | Pictograma | Cor da luz da boca |
|---|---|---|---|---|
| Luta comum | recompensa | (nada) | nenhum | a da recompensa (hoje) |
| Luta difícil (com elite) | recompensa | "Difícil" | **uma divisa** de ouro velho (a mesma `HudMark.CHEVRON` do HUD para elites) | a da recompensa |
| Guardião | recompensa | "Guardião" | **duas divisas** de ouro velho | a da recompensa, com o vermelho do guardião (`_kind_color`) na gema de cima |
| Fonte de luz | "Fonte de luz" | (nada) | gota | a da fonte (hoje) |
| Loja | "Loja" | (nada) | moeda | a da loja (hoje) |
| Altar | "Altar Esquecido" | (nada) | chama de vela | marfim morno (0,95; 0,85; 0,65), por `gem_color` |
| Morvath | "A Câmara do Selo" | (nada) | três divisas | a de hoje |
| Provação | (não é porta: é a laje, seção 5.1) | "Custa {n} de vida" | losango rachado | lilás (0,52; 0,36; 0,78), por `gem_color` |

- Precisa do `gameplay-engineer`: a sala seguinte saber, ao abrir as portas, se terá elite (sortear o encontro antes,
  com a mesma semente; hoje o `EncounterGen` sorteia ao entrar).
- Nenhuma placa diz o nome da arena seguinte (a surpresa fica; a placa já tem duas linhas).

### 7.2 O lugar seguinte no vão da porta

- No vão de cada saída usada, além da escada, um **cartão de luz** vertical (4 x 3 m, 2 m além da boca, fora do chão)
  na cor do **ar da arena seguinte** (o `ambient` do `air()` dela: castanho na Cripta, violeta nas Fendas, cinza frio no
  Jardim, azul-aço na Ponte, cinza claro no Santuário, quase preto com um fio âmbar nas Runas, teal no Salão, lilás na
  Provação), alfa até 0,35, maior canal até 0,6, sem luz projetada, subindo da escada como um bafo. Na porta de Morvath,
  o azul-marinho e violeta da câmara.
- Ele não compete com a gema: a gema fica acima (1,6 m), o bafo atrás e embaixo.
- Saída não usada: grade e nada de bafo (hoje).

---

## 8. Critérios de revisão (o que vou checar nas capturas)

Capturas reais na placa de vídeo: `tools/gpu.sh shot <saída> --showcase --arena=<id> --variant=<n> --seed=5 --shot-at=2`
e em luta `--bot --autopick --arena=<id>`; uma por arena no Compatibility (`DRIVER=opengl3 tools/shot.sh`); vídeo de
travessia do Santuário e das duas Pontes; vídeo de 20 s das Runas com os três padrões de cada variante.

1. **Composição**: os marcos nas posições da tela dadas em 1.4, 2.4, 3.5, 5.2 e 6.3 (tolerância 40 px); as oito salas
   distinguíveis em miniatura de 320 px sem personagens (tabela 4).
2. **Geometria** (com o `qa-performance`, `tools/arena_lab.gd --top`): contornos, buracos, pontes e peças batendo com as
   tabelas a 0,1 m; nenhum corredor abaixo de 3,5 m, nenhum vão sem ponte entre 0 e 6 m; testes do C12 (`test_arenas.gd`:
   caminho, avanço na borda, empurrão, cercado, 400 pontos dentro das peças) em todas as variantes.
3. **Decisão**: o vídeo e o registro mostram a pergunta da sala acontecendo (0.2): no Santuário, a investida do Cavaleiro
   parando numa coluna e o leque do Ancião morrendo na pedra; na Ponte, os atiradores do leste atirando no meio e a
   ruína barrando; nas Runas, um inimigo ferido pelo chão.
4. **Leitura**: avisos vermelhos lidos sobre todo chão (no facho de lua, no âmbar das runas, na ponte); o âmbar das
   runas nunca confundido com poça de braseiro (nenhuma poça quente no chão andável das Runas a mais de 2 m da parede);
   herói visível (corpo ou raio-x) atrás de cada coluna, pilone, ruína e pilar de runa; mediana do chão do meio de 45 a 60
   nas três arenas; nada no chão acima do limiar do glow em repouso; o clarão das runas abaixo de 235 na tela.
5. **D-29**: nenhum círculo, arco ou anel em perigo, entalhe, pictograma ou laje (inclusive a Provação).
6. **Provação e altar**: nenhum símbolo novo; o lilás da Provação distinto do violeta de Morvath lado a lado com a
   maldição dele (captura `--shot-on=hurt-cursed` ao lado do selo da Provação); o leão do altar lido como o leão dos
   estandartes.
7. **Portas**: pictograma e segunda linha lidos a 1280 x 720; o bafo da porta diz a cor da sala seguinte sem apagar a gema.
8. **Desempenho**: luzes com sombra dentro dos tetos (Santuário 6, Ponte 4, Runas 4, Provação 1, altar 2); quadro até
   6 ms a 1080 na RTX 5060 por arena (aceite da E5); Runas com o padrão maior armado.

---

## 9. Quem faz o quê e o que é provisório

| Tarefa | Dono |
|---|---|
| Plantas em dado (seções 1 a 3), guardião no Santuário, regra de onda por plataforma, perigo de chão (`ArenaHazard`, padrões, tempos, dano, quem fere), Provação e altar como tipos de sala no `RunMap`, laje da Provação, encontro sorteado antes da porta, métricas da decisão | `gameplay-engineer` |
| `SanctuaryLook`, `BridgeLook`, `RunesLook`, câmaras da Provação e do altar, ponte comum, banco, grade do presbitério, facho de lua, shader do ladrilho de runa, laje rachada, bafo da porta | `environment-artist` |
| Pictogramas e segunda linha da placa, carta da Provação, selo no HUD, faixa "Provação vencida", textos em `text_pt.tres` | `ui-ux-designer` |
| Capturas, vídeos, medidas | `qa-performance` |
| Revisão em `docs/art/visual_review.md` | `art-director` |

Ordem sugerida: Runas primeiro (o sistema novo de chão e a regra D-29 são o maior risco de leitura), depois a Ponte (usa
o chão com buracos e a ponte das Fendas), depois o Santuário (só obstáculos, a casa do guardião); Provação e altar em
paralelo com o `ui-ux-designer`.

Provisório: todas as peças são procedurais (colunas, sarcófagos, estátuas, altar, leão em relevo, pilone); o que ficaria
melhor com modelos definitivos segue em ART-010, com créditos só se o Daniel autorizar. Nada aqui depende de modelo que
não existe.
