# Ciclo C12 "Arenas I": especificação de arte e planta das três arenas novas

Autor: art-director, 2026-11-16. Para: `gameplay-engineer` (forma do chão, buracos, pontes, obstáculos, nascimento,
saídas, câmera, tudo em dado no `_stage` do `make_data.gd`) e `environment-artist` (construtores de cada arena, peças
novas, materiais, luz). Revisão depois: `art-director` em `docs/gallery/cycle12_maps/ART_REVIEW.md`.
Nada aqui foi implementado; nada vai para o Meshy (regra do ciclo; D-30: a árvore é de pedra, feita no código).

- Pedido do Daniel: `docs/design/cycle12_arenas_brief.md`. Plano e regras de geometria: `docs/design/cycle12_arenas_plan.md`
  (seções 3 e 4). Itens aprovados: `docs/backlog.md`, C12-F1 a F9 e C12-A1 a A3; decisões D-25 a D-33.
- Referências (feitas por IA, **só locais**, declaradas em `docs/steam-ia.md`): `docs/art/ref/cycle12_maps/01_*.png` a
  `05_*.png`. Servem para direção de arte e ideia de geometria; **não são mapas**. A planta abaixo é desenhada para a
  câmera e os números do jogo, e as diferenças em relação às imagens estão ditas em cada seção.
- A Câmara do Selo não muda. O Salão das Catacumbas (a pintura do Daniel) continua como está (D-26).
- Nenhum texto de história. A árvore não tem nome nem explicação. Os nomes das arenas são os que o Daniel deu (D-33).

---

## 0. Convenções e contas que valem para as três

### 0.1 Eixos, câmera e o que fica "perto" e "longe"

- Metros no plano do chão; `x` para leste, `z` para o sul (norte = `-z`), origem no meio da arena, como no resto do jogo.
- Câmera do jogo: giro 35°, inclinação 30°, campo de visão 24°, distância 54. Ela fica no **rumo 145°** (sudeste) do
  ponto que olha, 27 m acima. Na tela:
  - leste vai para a **direita e um pouco para baixo** (19° abaixo da horizontal na tela);
  - norte vai para a **direita e para cima** (35° acima da horizontal);
  - sul vai para a esquerda e para baixo; oeste para a esquerda e para cima.
- Por isso, como no salão: as bordas **norte e oeste são o fundo** (alto da tela; podem ter paredes, fachadas e peças
  altas) e as bordas **sul e leste são a frente** (baixo da tela; só peças baixas ou com pontilhado).
- Um eixo comprido leste-oeste aparece quase na horizontal da tela (19°): é o eixo das arenas maiores.
- Chão visto em 16:9 na altura do alvo: cerca de 41 m de largura; para o lado da câmera só cerca de 17 m; para o fundo
  cerca de 36 m. Cada metro de altura sobe cerca de 40 px na tela (1920 x 1080).
- **Corte de vista**: uma peça de altura `h` esconde o chão até `1,73 x h` metros atrás dela (para o noroeste, rumo
  325°). É a conta usada em todas as tabelas de pontilhado abaixo.

### 0.2 Regras de geometria (do plano, aplicadas)

1. Vão de abismo que corta caminho: 6 m ou mais, ou tem ponte. Entre duas superfícies andáveis separadas por buraco, a
   menor distância é 6 m (inclusive de uma ponte para outra e de uma ponte para o chão ao lado).
2. Corredor: 3,5 m ou mais entre quaisquer duas coisas que bloqueiam o corpo (peça, borda, buraco). Desenhei com 3,8 m
   ou mais para sobrar folga de arredondamento. Peça encostada na parede encosta de verdade (vão zero), nunca deixa
   fresta de 1 a 3 m.
3. Ponte de luta 5 m de largura andável; plataforma de luta 14 m ou mais.
4. Nada alto entre a câmera e o herói sem pontilhado (`see_through`, raio 2,2 m em volta do herói, como os obeliscos).
5. Sem colisão invisível: a colisão de cada peça é a forma desenhada na planta (círculo, caixa, cápsula, polígono) e a
   peça desenhada cobre exatamente essa forma no chão (pé da peça = contorno da colisão, tolerância 0,1 m).
6. A planta foi conferida numa grade de 0,2 m (corpo do herói 0,5 m): todas as saídas e zonas alcançáveis do início,
   nenhuma ilha morta, nenhum beco mais estreito que 3,5 m além dos cantos. O teste que vale é o do `NavGrid`
   (C12-F3, F5, testes 1 e 6 do plano), em todas as variantes.

### 0.3 Classes de obstáculo (seção 6 do pedido) e a regra do tiro

- O tiro inimigo voa a 1,1 m (`Projectiles.HEIGHT`); o ramo rasteiro do sacerdote a 0,3 m.
- **Regra de aparência**: peça com topo a 1,25 m ou mais **bloqueia tiro**; peça com topo até 1,0 m **não bloqueia**
  (o tiro passa por cima, e se vê passar). Não existe peça entre 1,0 e 1,25 m nas três arenas, para não haver dúvida.
- Classes usadas aqui: **A** enfeite sem colisão (velas sobre peças, entulho baixo até 0,15 m, raízes finas, capim seco,
  lajes erguidas até 0,08 m); **B** bloqueia o corpo (todas as peças das tabelas); **C** bloqueia também o tiro (coluna
  "C" na tabela); **E** buraco no chão (abismo). Nada destrutível (D) nem terreno (F) neste ciclo.
- Ramo rasteiro (0,3 m): para em toda peça B ou C (todas têm 0,5 m ou mais). Decisão do `gameplay-engineer`; se for outra,
  a aparência não muda.
- **Velas nunca soltas no chão andável**: só sobre peças (tampas, plintos, base de coluna, ressalto de parede,
  balaustrada). Uma vela no chão parece obstáculo e não é.

### 0.4 Saídas e entrada (todas as arenas)

- Cada arena tem a **entrada** (por onde o herói chega; vira cenário depois) e **três bocas de saída** (o mapa usa 2 ou
  3, `RunMap`). Cada saída é uma escada que desce, como no salão (`Arena.exit_at`, `exit_zones`, `exit_inward`,
  `door_label`), ou uma porta em ogiva com degraus descendo para dentro dela quando fica numa parede do fundo.
- A boca é chão andável: um retângulo de 4,0 m de largura por 2,4 m além da borda (o patamar de cima da escada). A zona de
  saída é a metade de fora desse retângulo. Saída não usada pela sala: a escada continua lá, fechada por uma grade de
  ferro baixa (0,9 m, sem brilho) no lugar da boca, e o retângulo não entra no chão.
- Toda boca usada tem uma luz quente própria (braseiro ou lanterna) a até 3 m, para a saída ler longe. Braseiros e
  lanternas ficam sempre **fora** do chão andável (pilar da boca, rebaixo da parede, pórtico), nunca soltos no chão.
- A entrada não é andável depois que o herói nasce: o chão termina numa soleira com o filete de ouro velho embutido
  (0,04 m, o mesmo da câmara) de lado a lado da boca. É o desenho do limite; o herói para onde o filete está.

### 0.5 Luz, glow e leitura (todas)

- Até **8 luzes com sombra por arena** (braseiros e o facho frio contam; velas e brilhos do abismo nunca têm sombra).
- Nada no chão andável passa do limiar do glow: maior canal da emissão final de filetes, inscrições, cristais e
  qualquer peça no chão no máximo 1,0. Acima do limiar só chamas, janelas distantes e os efeitos.
- **Nenhum vermelho no cenário do chão** (o vermelho é dos avisos). Estandartes carmim só em paredes e fachadas.
- **Nenhum círculo fechado e nenhuma inscrição acesa no chão** (círculos no chão são só de Morvath, `da35721`).
  Inscrições de ouro são entalhe sem brilho, em arcos interrompidos.
- **Nada de fogo verde** (as imagens têm braseiros verdes): o verde é da Emeth e do portal. Fogo é âmbar.
- Cristais (só no Jardim) no esmeralda corrompido frio da paleta (matiz 165, mais azulado e escuro que a Emeth).
- Chão do meio de cada arena com mediana de luminância entre 45 e 60 na tela (como o salão e a câmara): o matiz muda de
  arena para arena, o valor não, para herói, inimigos e avisos lerem igual em todas.
- Estandartes: o `ArenaKit.banner` liso, como no salão (sem emblema). As imagens mostram um leão nos estandartes; isso é
  pergunta para o Daniel (seção 8), não decisão nossa.
- Estátuas encapuzadas: `Masonry.hooded_statue`, mãos juntas e vazias, como no salão (as imagens põem espada na mão: não).

---

## 1. O kit: o que existe e o que é peça nova

### 1.1 O que já existe e se usa como está

| Peça | Onde | Usada em |
|---|---|---|
| Cantaria, pedra, pedra das profundezas | `Masonry.ashlar`, `stone`, `depth_stone` | paredes, colunas, sarcófagos, penhascos |
| Caixa chanfrada, bloco, prisma de polígono | `Masonry.box`, `bevel_mesh`, `block`, `prism` | muros baixos, túmulo, chão de pontes, plintos |
| Fuste de coluna, pináculo, ponta | `Masonry.shaft`, `pinnacle`, `point` | colunas, contrafortes |
| Arcos | `Masonry.pointed_arch`, `voussoir_arch`, `arch_ring` | portas de saída, nichos, arcos sob pontes e plataformas |
| Escada | `Masonry.stairs` | entradas e saídas |
| Balaustrada e pilar | `Masonry.balustrade`, `post` | bordas sobre o abismo, pontes |
| Estátua encapuzada | `Masonry.hooded_statue` | nichos |
| Pote, vela, caixote | `Masonry.pot`, `candle` (com `open` para o pontilhado), `crate` | enfeite |
| Braseiro, fogo, estandarte, corrente | `ArenaKit.brazier`, `fire`, `banner`, `chain` | luz quente, paredes, abismo |
| Abismo, brilho do abismo, bruma, cartão de ruína | `ArenaKit.abyss`, `abyss_glow`, `abyss_fog`, `mist_bank`, `ruin_card` | Fendas e Jardim |
| Chão de lajes | `catacomb_floor.gdshader` (`ArenaKit.floor_material`) | as três, com parâmetros próprios (seções 2.5, 3.5, 4.6) |
| Pontilhado | `see_through.gdshaderinc` (`hero_pos`) | colunas, muros altos, tronco e copa |

### 1.2 Do `BossChamber` para o kit comum (sem mudar a câmara)

O sarcófago (`_sarcophagus`), a lanterna de ferro (`_lantern`), o pilarete (`_pinnacle`) e a espada em relevo (`_sword`)
são privados da câmara. Pedido ao `environment-artist`: levá-los para o kit (`Masonry` ou `ArenaKit`) com os mesmos
parâmetros, e a câmara chamar o kit. Critério: `tests/test_chamber_look.gd` e `test_boss_chamber.gd` passam e a
captura da câmara não muda. Os sarcófagos das arenas usam o **mesmo** desenho com tamanho próprio: corpo 2,5 x 1,2 m,
1,05 de altura, tampa de 0,15 com aba, sobre plinto de 0,15 (topo 1,35 m: bloqueia tiro). Na tampa, a espada em relevo
sem ouro; sem leão (decisão D-17 da câmara).

### 1.3 Peças novas

| Peça | Para quê | Especificação | Dono |
|---|---|---|---|
| **Chão de polígono com buracos** | as três | malha do chão feita do mesmo `FloorShape.POLY` que a colisão (contorno menos buracos, mais pontes); o `catacomb_floor` por cima; espessura de 0,6 m na borda (cimalha) | `environment-artist`, com o `gameplay-engineer` (o dado) |
| **Borda quebrada** (penhasco de um polígono) | Fendas (fenda e buraco), bordas sobre o abismo | generalizar o `CatacombHall._cliff` (hoje um retângulo) para qualquer polígono: parede de `depth_stone` de y 0 a y -14 seguindo a borda, com dentes (blocos de 0,4 a 1,2 m que se projetam ou faltam a cada 0,8 a 2 m), lajes da beira baixadas de 0,05 a 0,25 m numa faixa de 0,3 m, lascas soltas caindo nos primeiros 2 m. Tudo fora do chão andável | `environment-artist` |
| **Ponte de pedra em arco** | Fendas | generalizar `CatacombHall._bridge`: tabuleiro de 5,0 m andáveis, parapeito baixo de 0,9 m (`balustrade` sem pontilhado) fora dos 5 m, de cada lado, 0,5 m de largura; um arco ogival sob o vão (`voussoir_arch`, 7 m de vão, fecho a 2,5 m abaixo do tabuleiro) e dois pegões descendo na bruma; cabeceiras com pilar e lanterna | `environment-artist` |
| **Ponte caída** | Fendas, variante B | as duas cabeceiras ficam (pilares e 1,5 m de tabuleiro quebrado em dente, **fora** do chão andável: a cabeceira é fechada pela balaustrada da borda) e o meio do arco falta; pedaços do tabuleiro presos por uma corrente pendurada (`ArenaKit.chain`) | `environment-artist` |
| **Muro baixo quebrado** | Cripta, Fendas, Jardim | cápsula de cantaria de 0,6 m de largura e 0,9 m de altura, topo irregular (0,7 a 0,95), pontas com blocos caídos **dentro** da cápsula. Não bloqueia tiro | `environment-artist` |
| **Coluna inteira e coluna quebrada** | Cripta, Fendas, Jardim | fuste (`shaft`) de raio 0,5 sobre base redonda de raio 0,65 (o raio da colisão), capitel a 4,6 m e um arranque de arco virado para o fundo (rumo 325°) até 5,2 m. A quebrada termina entre 2,8 e 3,8 m em fratura, com o pedaço caído **fora** do chão andável ou dentro do círculo da colisão. Pontilhado sempre | `environment-artist` |
| **Túmulo maior** | Cripta A | o sarcófago em escala 1,6 x 1,67 (4,0 x 2,0 m de pé) sobre dois degraus (0,15 cada) que **fazem parte** da caixa de colisão; tampa com a espada em relevo maior (1,2 m); topo 1,5 m | `environment-artist` |
| **Lápides no chão** | Cripta | placas embutidas de 0,9 x 1,9 m com moldura entalhada de 0,06 m, um losango gasto no meio, sem texto, sem relevo (classe A); a cada 3 a 4 m nos corredores, alinhadas | `environment-artist` (decalque ou `#define` no chão) |
| **Nicho funerário com prateleiras** | Cripta | nicho em ogiva (o `_niche` do salão) com três prateleiras de pedra e potes e ossos estilizados como volumes simples cinza (sem caveira detalhada) | `environment-artist` |
| **Árvore petrificada** | Jardim | seção 4.4 | `environment-artist` |
| **Grupo de cristais** | Jardim | 5 a 9 prismas de 6 lados com ponta piramidal, 0,15 a 0,35 m de raio, 0,4 a 1,6 m de altura, inclinados 10 a 35° para fora de um centro; material na seção 4.6. Ficam só dentro da colisão de outra peça (base do tronco, pé de parede) ou fora do chão: nunca soltos no chão andável | `environment-artist` |
| **Capim seco** | Jardim | cartões de 0,2 a 0,45 m em tufos, um `MultiMesh`, alpha scissor, cor (0,33; 0,31; 0,27), sem brilho, até 80 tufos, só junto de paredes, raízes e muretas (classe A) | `environment-artist` |
| **Janela gótica quebrada** | Jardim | vão de 2,4 x 6,0 m em ogiva na parede do fundo, rendilhado de pedra em parte caído, sem vidro desenhado (sem figuras); atrás, cartão de bruma violeta (`mist_bank`) e um `abyss_glow` | `environment-artist` |

---

## 2. Cripta dos Esquecidos (C12-A1)

**Experiência**: pequena, fechada, compartimentada. Pouca luz, só velas e dois braseiros; colunas e sarcófagos como
cobertura; corredores de 4 m; nada de abismo à vista. Teto de inimigos 4 a 6, no máximo 2 atiradores, sem sacerdote (C12-A1).

**O que tirei das imagens**: a faixa de baixo da `05` (sarcófagos, colunas, muros baixos, nichos com estátua, velas) e as
miniaturas de cripta da `01`. **O que muda**: as imagens têm muitos objetos soltos e corredores de um corpo; aqui são
menos peças, todas com 3,8 m ou mais entre si. Não há o portal verde da `05`.

### 2.1 Contorno andável

- 24 x 21 m: `x` de -12 a 12, `z` de -10,5 a 10,5, com o canto nordeste cortado por um desmoronamento.
- Polígono (sentido horário): (-12; -10,5), (8,5; -10,5), (12; -7), (12; 10,5), (-12; 10,5). Cerca de 400 m² andáveis
  na variante A (tamanho do plano: pequena, 20 a 24 m).
- Bordas:
  - **norte** (z -10,5, fundo): parede de cantaria de 6,5 m com três nichos funerários (centros em x -8,5, -2,5 e 8;
    o de 8 cai no desmoronamento e fica meio enterrado), a porta da saída X1 e dois estandartes ladeando-a;
  - **oeste** (x -12, fundo): parede de 6,5 m com a arcada de entrada (z 2,5 a 6,5) e dois nichos (z -7,5 e z 8,5);
  - **nordeste** (o corte de (8,5; -10,5) a (12; -7)): monte de blocos e lajes caídos, de 0,3 m na beira do chão até
    3,5 m junto às paredes; o pé do monte é a borda (nenhum bloco dentro do chão);
  - **sul e leste** (frente): a parede "cortada" a 0,9 m (como uma maquete aberta), com o topo mostrando a seção da
    cantaria e enchimento escuro; dentes e blocos caídos fora do chão; além dela, o escuro (a face de fora da parede
    descendo 3 m e sumindo em preto acastanhado, sem abismo violeta).

### 2.2 Variante A, "Nave": obstáculos

| Peça | Forma da colisão | Centro (x; z) | Tamanho | Topo | C (tiro) | Pontilhado |
|---|---|---|---|---|---|---|
| Túmulo maior | caixa | (0,5; 0) | 4,0 x 2,0 (eixo longo leste-oeste) | 1,5 | sim | não |
| Coluna 1 | círculo | (-6,0; -5,6) | raio 0,65 | 5,2 | sim | sim |
| Coluna 2 | círculo | (7,0; -5,6) | raio 0,65 | 5,2 | sim | sim |
| Coluna 3 | círculo | (-5,5; 5,6) | raio 0,65 | 5,2 | sim | sim |
| Sarcófago norte | caixa | (0,5; -5,6) | 2,5 x 1,2 (leste-oeste) | 1,35 | sim | não |
| Sarcófago sul | caixa | (4,0; 5,6) | 2,5 x 1,2 (leste-oeste) | 1,35 | sim | não |
| Sarcófago da parede | caixa encostada na parede oeste | (-11,4; -6,0) | 1,2 x 2,5 (norte-sul) | 1,35 | sim | não |
| Muro baixo oeste | cápsula | de (-12; 0) a (-8; 0) | largura 0,6 | 0,9 | não | não |
| Muro baixo leste | cápsula | de (12; 0,5) a (8; 0,5) | largura 0,6 | 0,9 | não | não |

- Corredores: túmulo a sarcófago norte 4,0 m; túmulo a sarcófago sul 4,0 m; colunas à parede 3,85 m ou mais; coluna 2 ao
  desmoronamento 3,85 m; muros baixos ao túmulo 5,2 m ou mais.
- Leitura: três faixas leste-oeste (norte, meio, sul), o túmulo no meio e quatro "baias" nos cantos fechadas em parte pelos
  muros baixos. Na tela, o túmulo cai no centro (981; 505) e a nave inteira cabe no quadro.
- Enfeite (classe A): velas nas tampas dos três sarcófagos e nos degraus do túmulo (grupos de 3 a 5, até 0,35 m), nas bases
  das colunas do fundo (1 e 2) e no ressalto das paredes do fundo; potes e ossos nas prateleiras dos nichos; lápides no
  chão das faixas norte e sul; entulho baixo (até 0,15 m) só junto das paredes e do desmoronamento.

### 2.3 Variante B, "Ossário": obstáculos

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Parede divisória | caixa | (0,5; -7,0) | 0,8 x 7,0 (da parede norte até z -3,5) | 3,2 | sim | sim |
| Sarcófago encostado | caixa encostada na parede norte | (-5,5; -9,25) | 1,2 x 2,5 (norte-sul) | 1,35 | sim | não |
| Coluna | círculo | (6,5; -6,0) | raio 0,65 | 5,2 | sim | sim |
| Sarcófago oeste | caixa | (-4,0; 3,0) | 2,5 x 1,2 | 1,35 | sim | não |
| Sarcófago leste | caixa | (3,0; 3,0) | 2,5 x 1,2 | 1,35 | sim | não |
| Muro baixo oeste | cápsula | de (-12; -2,5) a (-8; -2,5) | 0,6 | 0,9 | não | não |
| Muro baixo leste | cápsula | de (12; 1,0) a (8; 1,0) | 0,6 | 0,9 | não | não |

- A divisória separa a metade norte em duas baias (a oeste com o sarcófago encostado, a leste com a coluna e a porta X1);
  a metade sul fica aberta com os dois sarcófagos a 4,5 m um do outro. Divisória a coluna 4,95 m; à parede oeste 11 m.
- A divisória tem estante de ossário nas duas faces (nichos rasos de 0,15 m, só desenho) e termina ao sul num pilar
  com a espada em relevo (o painel ogival do pilarete da câmara).
- Diferença de clima: na B, as velas da baia oeste ficam apagadas (pavios sem chama) e o facho frio cai sobre a ponta sul da
  divisória (seção 2.5).

### 2.4 Entrada, saídas, nascimento e câmera

| Item | Posição | Observação |
|---|---|---|
| Entrada | arcada na parede oeste, z 2,5 a 6,5, escada subindo para o oeste | herói nasce em **(-10,0; 4,5)**, olhando para o leste (1; 0) |
| Saída X1 | porta em ogiva na parede norte, x 2,5 a 6,1 (centro (4,3; -10,5)) | degraus descendo para dentro do vão; dois braseiros em rebaixos da parede a cada lado (x 1,5 e 7,1, z -11), fora do chão |
| Saída X2 | escada descendo para o leste na borda leste, z 3,5 a 7,5 (centro (12; 5,5)) | lanterna de ferro sobre o pilar sul da boca |
| Saída X3 | escada descendo para o sul na borda sul, x -4 a 0 (centro (-2; 10,5)) | lanterna sobre o pilar oeste da boca |
| Zona de nascimento 1 | retângulo x 2 a 7, z -9,5 a -7,5 | |
| Zona 2 | x 8,5 a 11,2, z -4 a -0,5 | |
| Zona 3 | x 6,5 a 11, z 7 a 9,5 | |
| Zona 4 | x -10 a -7,5, z -10 a -8 | longe da entrada (12 m) |
| Câmera | alvo fixo **(1,0; 1,5)**, `cam_reach` 2,5 m, `CamFrame.hold` como na câmara | a sala inteira cabe: canto noroeste em (821; 222), sudeste em (1192; 952), sudoeste em (217; 538) |

Em toda zona, o ponto sorteado só vale com folga até peça e borda de pelo menos o raio do inimigo mais 0,3 m (a regra do
`NavGrid`, C12-F5); nenhum ponto a menos de 6 m do herói (como hoje).

### 2.5 Material, paleta e luz

- **Chão** (`catacomb_floor`): lajes menores e mais frias que as do salão; `unit` 0,8; `stone_a` (0,24; 0,24; 0,28),
  `stone_b` (0,34; 0,33; 0,38); juntas (0,08; 0,08; 0,10); musgo quase nenhum; sem medalhão; lápides embutidas (1.3).
  Alvo na tela: mediana do chão do meio perto de #34343e com a luz das velas.
- **Paredes e colunas**: `Masonry.ashlar` com multiplicador (0,92; 0,95; 1,02), um passo mais escuras que o chão; nichos
  com o fundo bem escuro (#120f14).
- **Ar** (um `RoomMood.Look` ligado na entrada, `arena.mood().blend(look, true)`, ou o `dress` da câmara; devolvido quando a sala sai): fundo e névoa (0,035; 0,03; 0,04), ambiente
  (0,32; 0,30; 0,30) energia 0,55 (mais escuro que o salão), lua desligada ou energia 0,1 (não há céu), névoa de distância
  curta (de 40 a 80) para a frente escura se perder.
- **Luz** (com sombra: no máximo 6):
  1. dois braseiros na porta X1 (`ArenaKit.brazier`, com sombra);
  2. **facho frio**: uma `SpotLight3D` caindo de uma fresta do teto (fora do quadro, 14 m acima), cor (0,62; 0,74; 0,9),
     energia 2,5, cone 18°, sobre o túmulo (A) ou a ponta sul da divisória (B), com sombra, com a poeira caindo
     (`Arena._dust`). É o único azul da sala e o centro do quadro;
  3. três grupos de velas mais fortes com sombra: tampa do sarcófago norte, degrau oeste do túmulo, base da coluna 3 (A);
     na B, tampas dos dois sarcófagos do sul e o pé da divisória;
  4. sem sombra: os outros grupos de velas (até 6, energia 1,2, alcance 2,8) e as duas lanternas das saídas.
- O quente fica em manchas: nenhum ponto do chão fora de 3 m de uma vela ou braseiro passa de 70% da luminância dos
  pontos iluminados (o chão não pode ficar chapado de laranja).
- **Diferença do salão**: o salão é aberto, teal, com abismo e portal verde; a cripta é fechada, sem céu, sem violeta, de
  luz quente em poças e um único facho frio.

---

## 3. Salão das Fendas (C12-A2)

**Experiência**: grande e aberto, a câmera anda. Uma fenda comprida divide o salão em duas plataformas; atravessa-se por
duas pontes de 5 m ou pela passagem ao sul. Um buraco menor na plataforma leste. O abismo violeta ilumina de baixo.
Teto de inimigos 6 a 8.

**O que tirei das imagens**: da `02`, o rasgo comprido atravessando o salão na diagonal da tela (de baixo à esquerda para
cima à direita), balaustrada quebrada numa borda e borda viva na outra, filete de ouro no chão junto da borda, fachada com
estátua e estandartes ao fundo, escada descendo na frente à direita; da `01` e da `03`, as pontes em arco e a borda
quebrada; da faixa de cima da `05`, os buracos no chão. **O que muda**: na `02` o chão em volta da fenda é um anel de 3 a 5 m
(estreito demais para lutar); aqui as plataformas têm 14 e 19 m. As pontes da `01` têm 2 corpos de largura; aqui 5 m.

### 3.1 Contorno, fenda, buraco e pontes

- 42 x 30 m: `x` de -21 a 21, `z` de -15 a 15 (grande: 38 a 48 m). Cerca de 935 m² andáveis (A).
- **Contorno** (sentido horário): (-21; -12), (-18; -15), (21; -15), (21; 9), (15; 15), (-15; 15), (-21; 10).
  Cantos noroeste, sudoeste e sudeste cortados (borda quebrada, nunca um retângulo).
- **Fenda** (buraco, polígono; atravessa a borda norte e se abre no abismo de fora):
  - borda oeste, de norte a sul: (-7,0; -17), (-7,0; -12), (-7,0; -7), (-7,8; -5), (-6,6; -3), (-7,0; -1), (-7,0; 4), (-7,6; 6), (-6,4; 8);
  - ponta sul: (-5,0; 9,4), (-2,5; 10,0), (0,3; 9,2);
  - borda leste, de sul a norte: (1,6; 8), (2,6; 6), (2,0; 4), (2,0; -1), (1,6; -3), (2,8; -5), (2,0; -7), (2,0; -12), (2,0; -17).
  - Largura 8,6 a 10,6 m; comprimento dentro do salão 25 m (de z -15 a 10, 83% da profundidade).
  - Os trechos retos (z -12 a -7 e -1 a 4) são as cabeceiras das pontes.
- **Pontes** (chão andável por cima da fenda): ponte norte, tabuleiro `x` -8 a 3, `z` -12 a -7; ponte sul, `x` -8 a 3,
  `z` -1 a 4. Vão de 9 m, 5 m andáveis, parapeitos fora dos 5 m.
- Distâncias de abismo (regra 1): ponte norte a ponte sul 6,0 m; ponte sul à passagem sul 6,0 m; ao norte da ponte norte a
  fenda se abre no abismo de fora.
- **Passagem sul**: entre a ponta da fenda (z 10) e a borda sul (z 15), 5 m de largura, 8 a 10 m de comprimento.
- **Buraco leste** (variante A): (8,0; -6,5), (9,5; -8,2), (12,5; -8,4), (14,6; -6,2), (14,0; -2,6), (11,0; -1,8), (8,4; -3,4);
  6,6 x 6,6 m. Distância à fenda 6 m, à borda leste 6,4 m, à norte 6,6 m.
- **Plataformas**: oeste, `x` -21 a -7 (14 m, o mínimo de luta); leste, `x` 2 a 21 (19 m).

**Bordas da fenda** (o que a `02` mostra):
- borda **oeste** da fenda: balaustrada quebrada (`balustrade` em lances de 2 a 4 m com falhas de 1 a 2 m, pilares
  partidos, um lance caído pendurado na beira), sobre um lábio de pedra de 0,45 m que é parte do buraco (fora do chão);
- borda **leste**: **borda viva**, sem balaustrada; o chão termina num filete de ouro velho embutido de 0,05 m a 0,3 m da
  queda, contínuo, que é o desenho do limite; entre ele e a queda, lajes baixadas e dentes (a borda quebrada da 1.3);
- buraco leste: borda viva com o filete; nos dois pontos mais perto da câmera, um bloco de cantaria caído na beira (até
  0,6 m, fora do chão);
- todas as faces de dentro da fenda: `depth_stone` descendo até sumir na bruma violeta, com arcos ogivais rasos de uma
  construção antiga aparecendo nas paredes (como na `02`), sem brilho próprio.

### 3.2 Variante A, "Duas pontes": obstáculos

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Ruína de parede | caixa | (14,0; 7,0) | 3,6 x 1,0 | 2,6 (topo quebrado, 2,0 a 2,6) | sim | sim |
| Coluna quebrada leste | círculo | (7,5; 3,0) | raio 0,7 | 3,8 | sim | sim |
| Sarcófago oeste | caixa | (-14,0; -5,5) | 1,2 x 2,5 (norte-sul) | 1,35 | sim | não |
| Coluna quebrada oeste | círculo | (-13,0; 3,0) | raio 0,7 | 3,2 | sim | sim |

Poucas peças de propósito: a fenda é o obstáculo. Enfeite (A): velas nas cabeceiras das pontes (sobre os pilares do
parapeito), no sarcófago e nos tocos das colunas; entulho baixo nas bordas.

### 3.3 Variante B, "Ponte caída": obstáculos e mudanças

- A **ponte norte caiu** (peça "ponte caída" da 1.3): as cabeceiras ficam, fechadas pela balaustrada, fora do chão.
  Cruza-se só pela ponte sul (`z` -1 a 4) ou pela passagem sul.
- O buraco vai para a **plataforma oeste**: (-17,5; -3,0), (-16,0; -5,2), (-13,0; -5,6), (-11,3; -3,5), (-11,6; -0,4),
  (-14,0; 0,6), (-16,6; -0,6). Corredor até a borda oeste 3,5 m; até a fenda 4,3 m.

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Ruína de parede | caixa | (14,0; 7,0) | 3,6 x 1,0 | 2,6 | sim | sim |
| Coluna quebrada 1 | círculo | (8,0; -4,0) | raio 0,7 | 3,8 | sim | sim |
| Coluna quebrada 2 | círculo | (13,0; -8,5) | raio 0,7 | 3,4 | sim | sim |
| Coluna quebrada 3 | círculo | (15,0; -1,0) | raio 0,7 | 2,9 | sim | sim |
| Sarcófago noroeste | caixa | (-13,5; -10,5) | 2,5 x 1,2 | 1,35 | sim | não |

- Clima B: o violeta de baixo mais forte (`deep_gain` 1,3) e um banco de bruma violeta subindo devagar da fenda no lugar da
  ponte caída (`mist_bank`, alfa 0,25).

### 3.4 Entrada, saídas, nascimento e câmera

| Item | Posição | Observação |
|---|---|---|
| Entrada | borda oeste, z 4,5 a 8,5: patamar e escada subindo do oeste (como o patamar do salão) | herói nasce em **(-18,0; 6,5)**, olhando para o leste |
| Saída X1 | porta em ogiva na fachada norte, x 10,2 a 13,8 (centro (12; -15)) | dois braseiros no pórtico da fachada (x 8,5 e 15,5, z -15,6), fora do chão |
| Saída X2 | escada descendo para o leste, z 0 a 4 (centro (21; 2)) | lanterna |
| Saída X3 | escada descendo para o sul, x 6 a 10 (centro (8; 15)) | lanterna |
| Zona 1 | x 5 a 11, z -13,5 a -10,5 | |
| Zona 2 | x 16 a 19,5, z -8 a -2 | |
| Zona 3 | x 5 a 11, z 7 a 12 | |
| Zona 4 | A: x -17 a -11, z -13 a -9; B: x -19,5 a -15,5, z -12 a -7 | a única do lado do herói, a 16 m dele |
| Câmera | segue o herói; o alvo fica no retângulo **x -6 a 7, z -4 a 5** (`cam_bounds`); `CamFrame.keep` com 18% manda | vitrine: alvo (-2; 0) |

- **Todas as saídas estão na plataforma leste**: a sala obriga a atravessar.
- Ninguém nasce em ponte nem na passagem sul (as zonas não as tocam). A primeira onda nasce nas zonas 1 a 3 (do outro
  lado da fenda); a zona 4 só a partir da segunda onda.
- Vitrine (alvo (-2; 0), 1920 x 1080): a fenda corre de (629; 753), a ponta sul, até (1281; 294), a boca norte, na
  diagonal como na `02`; ponte norte perto de (1170; 372), ponte sul perto de (899; 562); porta X1 na borda direita (1844; 446).

### 3.5 Material, paleta e luz

- **Chão**: lajes maiores (`unit` 1,4), mais azuis: `stone_a` (0,22; 0,23; 0,30), `stone_b` (0,31; 0,32; 0,42); rachaduras
  mais densas a até 3 m de qualquer borda de buraco (máscara feita do `FloorShape`, como o campo de distância do leão),
  com um fundo violeta muito escuro (0,08; 0,04; 0,12) nas rachaduras mais largas, sem brilho; filete de ouro velho
  `gold_light` (0,478; 0,384; 0,22) na borda viva; inscrições de ouro em arcos interrompidos e linhas retas (como na
  `02`) só entre a fenda e o buraco, contraste até 15%. Alvo: mediana do chão do meio perto de #2f3346.
- **Peças**: `ashlar` com multiplicador frio (0,92; 0,96; 1,06).
- **Ar**: fundo (0,04; 0,03; 0,10), névoa (0,10; 0,05; 0,20) e névoa de altura enchendo a fenda abaixo de y -2,
  ambiente (0,32; 0,30; 0,48) energia 0,7, lua fria (0,55; 0,65; 0,9) energia 0,3 vinda do noroeste (por trás), com sombra.
- **Luz** (com sombra: no máximo 5):
  1. **violeta de baixo**: 4 `OmniLight3D` (0,55; 0,25; 1,0) energia 5 em y -10 dentro da fenda (z -9, -2, 5) e do buraco,
     sem sombra, na camada das profundezas (`ArenaKit.DEPTH_LAYER`), mais um `abyss_glow` de 9 m de largura ao longo da
     fenda. O violeta sobe pelas bordas e pinta a beira das lajes até 1,5 m; o meio das plataformas fica na pedra fria;
  2. dois braseiros da fachada (com sombra);
  3. quatro lanternas de ferro nas cabeceiras das pontes, quentes (energia 1,5, alcance 4,5), duas com sombra (cabeceira
     oeste da ponte norte e leste da ponte sul);
  4. lanternas das saídas X2 e X3 sem sombra.
- **Fundo**: borda norte da plataforma oeste aberta para o abismo (balaustrada baixa), com cartões de ruína (`ruin_card`)
  e duas correntes enormes cruzando o alto do quadro de uma torre (fora do chão, além da borda noroeste) até a fachada.
  Fachada norte da plataforma leste: cantaria de 10 m, a porta X1, duas estátuas encapuzadas, dois estandartes lisos.
- **Diferença do salão**: o salão é teal com o portal verde no alto à direita e o abismo só em volta; aqui o abismo está
  **dentro** da sala, o ar é azul-violeta e a luz vem de baixo.

---

## 4. Jardim das Raízes Mortas (C12-A3)

**Experiência**: média, larga e assimétrica. Uma árvore enorme petrificada a noroeste, raízes baixas atravessando o chão,
sarcófagos e ruínas soltos; contornar o tronco, usar o tronco como cobertura. Teto de inimigos 6 a 8. A árvore é o
destaque visual; ela **nunca** esconde o herói (pontilhado no tronco e na copa, e a copa fica fora da frente).

**O que tirei das imagens**: da `04`, quase tudo: salão largo, tronco no alto à esquerda, raízes rastejando pelo chão,
cristais na base, sarcófagos, braseiros em pedestal, janelas góticas ao fundo com o violeta atrás, inscrições de ouro no
chão em volta, escada na frente à esquerda; da `03`, as lanternas penduradas nos galhos. **O que muda**: na `04` a árvore é
de madeira; aqui é **pedra** (D-30). A copa da `03` cobre um terço da tela; aqui ela sobe e abre para os lados e para o
fundo, nunca para a câmera. As inscrições não fecham círculo e não brilham.

### 4.1 Contorno

- 34 x 28 m: `x` de -17 a 17, `z` de -14 a 14 (média: 26 a 34 m). Cerca de 745 m² andáveis.
- Polígono: (-17; -10), (-13; -14), (17; -14), (17; 8), (11; 14), (-12; 14), (-17; 9).
- Bordas: **norte** (fundo): parede gótica em ruína de 7 a 9 m com três janelas quebradas (centros em x -3, 3,5 e 13;
  a de 13 é a porta X1); **oeste** (fundo): parede de 7 m com uma janela (z -4) e dois estandartes (z -8 e z 2);
  **noroeste** (o corte): pilar e contraforte quebrados; **leste e sul** (frente): balaustrada sobre o abismo com
  pontilhado nos pilares e arcos ogivais sob a plataforma (como a `04` embaixo à direita); **sudoeste** (o corte): a
  escada de entrada.

### 4.2 Variante A: tronco, raízes e obstáculos

- **Tronco**: centro **(-8,0; -5,0)**. Colisão: polígono de 48 pontos com raio `3,5 x (1 + 0,05 sen 3θ + 0,03 cos 5θ)`
  (θ = rumo), mais uma "sapopema" em cada rumo de raiz, que leva o raio a 4,4 m dentro de ±14° do rumo. Bloqueia
  corpo e tiro; pontilhado sim.
- Passagem atrás do tronco (para o norte): 5,5 m até a parede norte. Ao oeste: 5,5 m até a parede oeste.
- **Raízes que bloqueiam** (cápsulas de 1,0 m de largura, 0,5 a 0,7 m de altura, baixando para 0,35 na ponta; não
  bloqueiam tiro; sem pontilhado; saem da sapopema a 4 m do centro):

| Raiz | Rumo de saída | Pontos (x; z) |
|---|---|---|
| R1 | 60° | (-4,5; -7,0), (-2,5; -7,7), (-0,4; -8,1), (1,8; -8,1) |
| R2 | 135° (para a câmera, baixa) | (-5,2; -2,2), (-3,5; -0,8), (-1,6; 0,3), (0,3; 1,2) |
| R3 | 210° | (-10,0; -1,5), (-10,8; 0,1), (-11,4; 1,9), (-11,9; 3,6) |
| R4 | 300° (curta) | (-11,5; -7,0), (-12,8; -7,8) |

  Ângulos entre raízes vizinhas de 70° ou mais: o vão entre duas raízes já tem 4 m ou mais onde elas saem do tronco
  (sem bolso estreito junto do tronco). Cada raiz fica visível acima do chão em **toda** a cápsula; ela só pode afundar
  no chão depois da ponta, como raiz fina sem colisão (classe A, até 0,12 m de altura, até 3 m além).

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Sarcófago leste | caixa | (7,5; -5,0) | 2,5 x 1,2 | 1,35 | sim | não |
| Sarcófago encostado | caixa encostada na parede oeste | (-16,4; -1,5) | 1,2 x 2,5 | 1,35 | sim | não |
| Muro baixo em ruína | cápsula | de (9,0; 5,0) a (13,0; 5,0) | largura 0,8 | 1,0 | não | não |
| Coluna quebrada | círculo | (4,5; 7,0) | raio 0,7 | 3,6 | sim | sim |

### 4.3 Variante B: raízes e obstáculos

- Mesmo tronco e mesmo lugar (a árvore é o marco do lugar). Sapopemas nos rumos 80°, 160° e 240°.

| Raiz | Rumo | Pontos |
|---|---|---|
| R1 | 80° | (-4,1; -5,7), (-2,4; -5,8), (-0,7; -5,7), (0,9; -5,4) |
| R2 | 160° (para a frente) | (-6,6; -1,2), (-6,2; 0,7), (-6,1; 2,7), (-6,3; 4,7) |
| R3 | 240° (curta) | (-11,5; -3,0), (-12,2; -2,5) |

| Peça | Forma | Centro | Tamanho | Topo | C | Pontilhado |
|---|---|---|---|---|---|---|
| Sarcófago nordeste | caixa | (11,5; -6,0) | 1,2 x 2,5 (norte-sul) | 1,35 | sim | não |
| Sarcófago sul | caixa | (6,5; 5,0) | 2,5 x 1,2 | 1,35 | sim | não |
| Coluna quebrada leste | círculo | (12,0; 3,0) | raio 0,7 | 3,4 | sim | sim |
| Coluna quebrada oeste | círculo | (-12,5; 4,0) | raio 0,7 | 3,0 | sim | sim |

- Clima B: o facho frio mais fraco (energia 1,8) e os cristais da base um passo mais acesos (máximo 0,9); duas lanternas
  penduradas em vez de uma.

### 4.4 A árvore petrificada (peça nova, a mais difícil do ciclo)

**Ideia de forma**: uma árvore velha e retorcida que virou pedra; reconhecível como árvore pela silhueta (tronco largo,
casca em cordas torcidas, galhos que se dividem até pontas finas, raízes que agarram o chão), e como pedra pela cor, pelas
fraturas limpas e pelas lascas. Sem folhas. Sem rosto, sem forma escondida, sem símbolo.

- **Construção**: varredura (sweep) de uma seção lobada ao longo de uma espinha curva; o `Masonry._lathe` é o ponto de
  partida (torno), estendido para seguir uma curva e torcer a seção. Uma classe própria (por exemplo `PetrifiedTree`,
  `scripts/game/`) com `build(parent, at, seed)` e o desenho todo em constantes, como o `BossChamber`.
- **Tronco**: espinha inclinada 8° para o oeste-noroeste (rumo 300°, para longe da câmera). Seção com 7 a 9 lóbulos (as
  cordas da casca), torcidos 40° do pé à forquilha. Raio: 3,5 em y 0 (a sapopema se funde ao chão), 2,6 em y 1,0, 2,0
  em y 2,5, 1,7 em y 4,5. Sulcos fundos entre os lóbulos (sombra na cor de vértice, como as estátuas).
- **Forquilha a 4,5 m** em três pernadas:
  - A para o oeste-sudoeste (rumo 245°, esquerda da tela), subindo até 7,0 m e chegando a 7 m do eixo;
  - B para o norte-nordeste (rumo 20°, fundo à direita), até 8,0 m de altura e 6 m do eixo;
  - C para cima e para o fundo (rumo 320°), até 9,0 m.
  Cada pernada divide em 2 ou 3 galhos, por mais dois níveis, afinando até 0,08 m; 40 a 60 tubos no total; desvio por
  ruído ao longo de cada espinha (galhos tortos, nunca retos); três galhos quebrados com fratura limpa e lascas.
- **Regra da copa** (para não esconder o herói): nenhum galho abaixo de 4,5 m, a não ser a 1 m do tronco; nenhum galho
  nos rumos de 95° a 195° (o lado da câmera) mais longe que 2 m do eixo. Assim o corte de vista da copa (a 4,5 m de
  altura ou mais) cai a 7,8 m ou mais atrás de cada galho, quase sempre fora da sala (o norte e o oeste do tronco ficam
  a 5,5 m das paredes). Na tela (vitrine, alvo (0; 1)): pé do tronco em (833; 346), forquilha em (828; 174); a ponta da
  pernada A perto de (530; 60); as pontas de B e C saem pelo alto do quadro, como na `04`. A copa ocupa de cerca de x 520 a
  x 1100 entre y 0 e 200: em cima do fundo (paredes e janelas), não do chão da luta.
- **Pontilhado**: tronco e galhos com o `see_through` (raio 2,2 m em volta do herói, o mesmo dos obeliscos). Atrás do tronco
  (a passagem norte) o herói aparece pelo raio-x de pedra (`xray_behind`): o material do tronco entra na mesma camada
  das peças de pedra.
- **Raízes que bloqueiam**: varredura com seção elíptica achatada (1,0 de largura, 0,6 de altura), dois "lombos" por raiz
  (sobe a 0,7, desce a 0,45, sobe de novo), afinando na ponta; continuam sem colisão como raízes finas (até 0,12 m)
  entrando nas juntas do chão. Lajes em volta das raízes erguidas e partidas (até 0,08 m, classe A).
- **Material**: pedra, não madeira. Base (0,30; 0,30; 0,34) nos sulcos escurecendo a 0,6; cordas da casca mais claras
  (0,45; 0,43; 0,48); manchas de líquen cinza-esverdeado (0,22; 0,26; 0,22) só na metade de baixo; fraturas e pontas
  quebradas mais claras (0,55; 0,53; 0,56). Triplanar como o `masonry.gdshader` (grão fino ao longo da espinha, nada de
  blocos de cantaria). Valor médio do tronco 10% a 20% acima do chão em volta, para a silhueta ler contra o fundo escuro.
- **Cristais**: 3 grupos na base do tronco, dentro da colisão (entre as sapopemas, rumos de 100° a 300°), e veios finos do
  mesmo esmeralda corrompido subindo por 2 ou 3 fendas da casca até 2,5 m (só emissão fraca, máximo 0,6).
- **Lanternas penduradas**: uma (A) ou duas (B) lanternas de ferro (a do kit, 1.2) penduradas por corrente da pernada A
  (e da B), a 5,5 m de altura, sobre o chão a oeste e ao norte do tronco, nunca no lado da câmera; luz quente sem sombra.
- **Orçamento**: até 25 mil triângulos a árvore inteira, 2 materiais (pedra e cristal), uma malha só depois do
  `Masonry.merge`.
- **Critério de aprovação da árvore** (D-30: se reprovar, o Jardim sai da entrega 1): lida como árvore a 1920 x 1080 na
  câmera do jogo sem explicação; galhos finos visíveis contra o fundo; herói visível em 100% das posições de uma grade de
  2 m atrás e em volta dela; lado a lado com a `04`, a forma geral (tronco no alto à esquerda, raízes agarrando o chão,
  copa aberta para cima e para os lados) bate.

### 4.5 Entrada, saídas, nascimento e câmera

| Item | Posição | Observação |
|---|---|---|
| Entrada | escada no corte sudoeste, boca no meio da diagonal (-14,5; 11,5) | herói nasce em **(-12,0; 9,0)**, olhando para o nordeste |
| Saída X1 | porta em ogiva na parede norte, x 11,2 a 14,8 (centro (13; -14)) | braseiro em pedestal a cada lado, encostado na parede além da borda (z -14,6), fora do chão |
| Saída X2 | escada descendo para o leste, z -2 a 2 (centro (17; 0)) | braseiro em pedestal sobre o pilar norte da boca, além da borda |
| Saída X3 | escada descendo para o sul, x 3 a 7 (centro (5; 14)) | lanterna |
| Zona 1 | x 6 a 12, z -12,5 a -9,5 | |
| Zona 2 | x 13 a 16, z -4 a 3 | |
| Zona 3 | x -6 a 0, z -13,2 a -10,5 | atrás do tronco: inimigo que nasce ali sai pelos lados |
| Zona 4 | x -2 a 6, z 9 a 12,5 | |
| Zona 5 | x -15 a -13, z -6 a -3,5 | só a partir da segunda onda (a 12 m do herói) |
| Câmera | segue o herói; alvo no retângulo **x -3 a 4, z -2 a 3**; `CamFrame.keep` com 18% | vitrine: alvo (0; 1) |

### 4.6 Material, paleta e luz

- **Chão**: o mais quente das três, como a `04`: `unit` 1,1, `stone_a` (0,30; 0,27; 0,28), `stone_b` (0,42; 0,38; 0,38),
  musgo e líquen cinza-esverdeados (`moss_color` (0,18; 0,22; 0,20)) em faixas junto das raízes e das paredes; lajes
  partidas e erguidas pelas raízes; inscrição de ouro em **arcos interrompidos** em volta do tronco (raio 9 a 10 m,
  cortados pelas raízes e com pelo menos 3 falhas de 2 m ou mais; nunca fecha), entalhe sem brilho, contraste até 15%.
  Alvo: mediana do chão do meio perto de #3b3537.
- **Cristais** (`emission` só, sem transparência, para valer no Compatibility): albedo (0,10; 0,25; 0,22), emissão no miolo
  e nas arestas do esmeralda corrompido (0,32; 0,70; 0,60), maior canal no máximo 0,8 (A) ou 0,9 (B). Nunca pulsam
  depressa (no máximo ±10% a 0,2 Hz).
- **Ar**: fundo (0,05; 0,06; 0,09), névoa (0,07; 0,08; 0,12), ambiente (0,30; 0,33; 0,38) energia 0,7, lua fria
  (0,6; 0,68; 0,85) energia 0,25, por trás.
- **Luz** (com sombra: no máximo 5):
  1. **facho frio sobre a árvore**: `SpotLight3D` do alto, por trás e à direita (de (-2; 22; -16) mirando o tronco),
     cor (0,75; 0,8; 0,95), energia 3,0 (A) ou 1,8 (B), cone 30°, com sombra: os galhos riscam sombras compridas no chão a
     norte e a leste do tronco. Opacidade da sombra no chão: o chão sombreado continua acima de 60% da luminância do chão
     iluminado (sombra de galho não pode virar faixa preta que confunda com aviso);
  2. três braseiros (dois da porta X1 e o da saída X2), com sombra;
  3. lanternas penduradas (sem sombra), uma luz verde-azulada fraca nos cristais da base (energia 0,6, alcance 3, sem
     sombra), velas sobre os sarcófagos.
- Janelas do fundo: atrás de cada uma, `mist_bank` violeta e `abyss_glow`; o violeta entra pelas janelas e pinta só a
  pedra das paredes do fundo, não o chão.
- **Diferença do salão e das outras**: o único com um marco vertical no meio do jogo; o chão mais quente (lilás e
  castanho), o facho frio desenhando sombras de galho, os cristais frios na base. Sem abismo dentro da sala.

---

## 5. As cinco salas lado a lado

| | Salão das Catacumbas | Cripta | Fendas | Jardim | Câmara do Selo |
|---|---|---|---|---|---|
| Tamanho andável | 32 x 30 | 24 x 21 | 42 x 30 | 34 x 28 | círculo de 25 |
| Câmera | segue, margens | fixa (alvo (1; 1,5)) | anda nos dois eixos | anda pouco | fixa |
| Ar | teal (0,06; 0,22; 0,27) | castanho escuro, sem céu | azul-violeta | cinza frio com violeta nas janelas | azul-marinho e violeta |
| Chão | lajes mornas, medalhão | lajes pequenas frias, lápides | lajes grandes azuis, rachado nas bordas, filete de ouro | lajes mornas partidas por raízes, líquen | lajes pequenas, selo |
| Luz que manda | portal verde, braseiros | velas em poças e um facho frio | violeta de baixo | facho frio na árvore e sombras dos galhos | lanternas violeta, selo |
| Marco | portal no alto à direita | túmulo no meio | a fenda na diagonal | a árvore no alto à esquerda | o selo e a porta |
| Abismo | em volta | nenhum | dentro da sala | só atrás das janelas e na frente | em volta |
| Cobertura | obeliscos | colunas e sarcófagos | quase nenhuma (a fenda) | tronco, raízes, sarcófagos | nenhuma |

Se duas capturas de salas diferentes, sem personagens, puderem ser confundidas por alguém que não conhece o jogo, a
diferença não está bastando (critério 6.1).

---

## 6. Critérios de revisão (o que vou checar nas capturas)

Capturas reais na placa de vídeo (`tools/gpu.sh shot ... --arena=<id> --variant=<n>`), as seis da seção 16 do pedido por
arena e variante, mais o vídeo de travessia; e uma no Compatibility (`DRIVER=opengl3 tools/shot.sh`).

### 6.1 Composição e identidade
- O marco de cada sala está onde a planta diz: túmulo no meio da cripta; fenda de baixo à esquerda para cima à direita
  passando perto de (629; 753) e (1281; 294) na vitrine; pé da árvore perto de (833; 346), forquilha perto de (828; 174).
  Tolerância de 40 px.
- As cinco salas (tabela 5) se distinguem em miniatura (320 px de largura, sem personagens): matiz do ar, marco e forma do chão.
- Nenhum piso igual ao do salão: `unit`, cores e detalhes do chão como nas seções 2.5, 3.5 e 4.6.

### 6.2 Geometria e colisão (junto do `qa-performance`)
- Visto de cima (`tools/arena_lab.gd`, grade e buracos desenhados): o contorno, os buracos, as pontes e cada obstáculo
  batem com as tabelas (tolerância 0,1 m) e a peça desenhada cobre exatamente a forma da colisão.
- Nenhum corredor abaixo de 3,5 m, nenhum vão de abismo entre 0 e 6 m sem ponte (medido na vista de cima).
- Nenhuma vela, cristal ou peça de enfeite solta no chão andável; nenhuma raiz afundando dentro da colisão.

### 6.3 Leitura do combate
- Herói visível (corpo ou raio-x) em 100% de uma grade de 2 m em volta e atrás de cada peça com pontilhado (colunas,
  divisória, ruína, tronco, copa); o anel do herói não aparece sobre pedra.
- Avisos vermelhos lidos sobre todo o chão: na poça de vela, no violeta da beira da fenda, na sombra dos galhos e no facho frio.
- Mediana do chão do meio entre 45 e 60 de luminância em cada sala; nenhum ponto do chão andável acima do limiar do glow.
- Borda de buraco lida a 1920 x 1080: o filete ou a balaustrada inteira, sem falha que pareça passagem.
- Saídas lidas de longe: cada boca usada com sua luz quente; boca não usada com a grade.

### 6.4 Luz e desempenho
- Contagem de luzes com sombra por arena e variante: no máximo 8 (o lab imprime).
- Quadro a 1080p na RTX 5060 até 6 ms por arena (aceite do C12); Compatibility: sem névoa volumétrica, conferir que a
  fenda continua violeta e a cripta não vira breu.
- Árvore: até 25 mil triângulos.

### 6.5 Câmera
- Cripta: a sala inteira no quadro com o alvo fixo; herói no canto mais longe ainda na moldura segura.
- Fendas e Jardim: vídeo de travessia de ponta a ponta sem salto do alvo; além das bordas só abismo, parede ou escuro
  desenhado, nunca o vazio cinza do fundo do motor.

---

## 7. Quem faz o quê

| Tarefa | Dono |
|---|---|
| Planta em dado: contornos, buracos, pontes, obstáculos (forma, `blocks_move`, `blocks_shots`, `see_through`), zonas, saídas, entrada, alvo e limites da câmera, variantes (seções 2 a 4) | `gameplay-engineer` (C12-F1 a F6) |
| Teste de que cada peça desenhada cobre a forma da colisão (comparar o dado com o que o construtor monta) | `gameplay-engineer` com o `environment-artist` |
| Kit comum (1.2) sem mudar a câmara | `environment-artist` |
| Peças novas (1.3), construtores `crypt`, `rift`, `garden` lendo o `RoomLayout`, materiais, ar e luz | `environment-artist` |
| Leitura das bordas e das saídas, e a regra de que cenário não cobre aviso | `ui-ux-designer` |
| Capturas, vídeos, medidas (luzes, triângulos, ms) | `qa-performance` |
| Revisão com a referência e as capturas, `ART_REVIEW.md` | `art-director` |

Ordem (do plano): Cripta, depois Fendas, por último o Jardim (a árvore pode cair, D-30).

---

## 8. Pendências e perguntas ao Daniel (pelo Game Director)

1. **Leão nos estandartes**: as cinco imagens põem um leão nos estandartes vermelhos. Hoje o salão tem estandarte liso e a
   câmara tem a espada erguida (o leão ficou só no selo, decisão da sessão a confirmar). As arenas novas usam o liso até
   ele decidir.
2. **Espada na mão das estátuas** (`02`, `03`): mantive mãos juntas e vazias, como no salão. Muda só com a palavra dele.
3. **Porta verde da `05`** (a cripta tem uma porta com luz verde): não usei, porque o verde é da Emeth e do portal.
4. **Árvore**: de pedra, sem nome e sem explicação (D-30). Se ele quiser que a árvore signifique algo, é cânone, não arte.
5. **Lápides sem texto**: nada escrito nelas, nem runa legível.

Nada nesta especificação depende de modelo que não existe: tudo sai do código. O que ficaria melhor com modelos
definitivos (estátuas, sarcófagos, árvore viva) continua em ART-010 (C15), com créditos autorizados pelo Daniel.
