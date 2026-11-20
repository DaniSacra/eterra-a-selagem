# Benchmark de estilo: Hades II contra A Selagem (2026-11-19)

Dono: `art-director`. Estudo de **leitura e acabamento**, não de cópia: do Hades II copiamos mecânica e leitura; a
sensação visual é do Ember & Blade; a identidade (leão, ouro velho, petróleo, Livro de Ahk, pedra das catacumbas) é de
Eterra. Nada do Hades entra no repositório (imagem, ornamento, lua, caveira, faixa verde, fonte): os pedidos abaixo
traduzem princípios para a nossa língua visual.

## 0. Material estudado

**Hades II (só locais, gitignored, nunca copiar):**
- `docs/art/ref/hades2_bench_2026-11-19/01.jpeg` a `08.jpeg`: escolha de save (01), diálogo com retrato sobre o hub (02),
  estação de encantos (03), loja (04), inventário (05, 06), escolha de Bênção com retrato do deus (07), clareira do hub
  com a heroína no foco de luz (08).
- `C:\Users\danie\OneDrive\Imagens\Hades 2\Boss 1\` (9 quadros de luta contra o primeiro chefe; medidos 184601, 184730,
  185256).

**Ember & Blade** (a sensação visual nossa): `C:\Users\danie\OneDrive\Imagens\Ember Blade\` (3 quadros).

**A Selagem, commit 4098f7a, RTX 5060, Forward+, 1920 x 1080, estilizado, câmera Perto** (capturas da fila do Game
Director, no scratchpad da sessão, `zip/shots/`): `salas/01` a `18` (Salão, Cripta A/B, Fendas A/B, Jardim A/B,
Santuário A/B, Ponte A/B, Runas A/B, guardião, fonte, loja, Provação), `telas/` (cartas dos anjos e das Bênçãos,
Forja, Livro, pausa, hub, Morvath e as demais). As pastas `morvath/` e `santuario/` ainda não tinham capturas quando
este estudo foi escrito; usei `telas/boss_1920x1080.jpg` e `telas/hub_1920x1080.jpg`.

Medidas: `python3 -I tools/frame_stats.py --hue --scene [--box=x,y,w,h ...]` (matiz médio, saturação HSV p50, luma
p10/p50/p90). Caixas padrão a 1920 x 1080, usadas em todos os aceites abaixo:

| Nome | Caixa | O que é |
|---|---|---|
| Cena | `--scene` | quadro sem HUD (x 5 a 95%, y 8 a 85%) |
| Meio | `640,360,640,360` | o campo da luta em volta do herói |
| Lateral E / D | `60,140,320,760` / `1540,140,320,760` | as bordas da tela |
| Perto | `520,780,880,150` | a faixa de baixo, acima do HUD (o que está mais perto da câmera) |
| Chão nu | 200 x 150 escolhida na captura, só laje, sem peça nem figura | a textura do chão em escala de 3 x 2 m |

Para outras resoluções, escalar as caixas na mesma proporção (os quadros do Hades e do Ember & Blade foram medidos com
caixas equivalentes).

## 1. Os números lado a lado

### 1.1 Quadro de luta

| | Cena: sat p50 | Cena: luma p50 | Meio luma p50 | Laterais luma p50 (razão ao meio) | Perto luma p50 (razão) | Chão nu p90 menos p10 | Chão nu sat p50 |
|---|---|---|---|---|---|---|---|
| Hades II (Hécate, 3 quadros) | **0,49 a 0,55** | 31 a 36 | 36 a 62 | 24 a 35 (0,42 a 0,67) | 26 a 28 (0,45 a 0,72) | **5 a 15** | 0,22 a 0,61 |
| Ember & Blade (3 quadros) | **0,46 a 0,51** | 64 a 73 | 96 a 122 | 45 a 77 (0,40 a 0,75) | 56 a 58 (0,48 a 0,60) | (não isolado) | 0,53 |
| Selagem, salas de luta (16 quadros) | **0,12 a 0,29** | 39 a 72 | 42 a 109 | 19 a 66 (0,23 a 0,92) | 23 a 103 (0,46 a **1,00**) | **39 a 72** | 0,03 a 0,25 |
| Selagem, Provação | 0,35 | 43 | | | | | |
| Selagem, Câmara do Selo (Morvath) | **0,50** | 40 | 56 | 54 e 17 | 27 (0,48) | | |

Saturação p90 no formato antigo do `frame_stats` (o da seção 3 do `art_direction.md`): Hades 27 a 43, Ember & Blade 21 a
23, Selagem 9 a 14 nas salas de luta (25 em Morvath). **Estamos abaixo até do Ember & Blade, a nossa própria referência
de sensação**: a passada estilizada (saturação do mundo 0,77, pedra puxada para `paint_stone`) apagou a cor junto com o
ruído.

Casos que mais destoam:
- Salão (02): faixa de perto luma 86 = o meio (86); chão nu 39 a 78 e 50 a 118.
- Santuário A (09): chão nu 49 a 120 e 51 a 101; perto 91 contra meio 109 (0,83).
- Fendas B (06): perto 103 contra meio 108 (0,95). Jardim A (07): lateral direita 48 contra meio 57 (0,84).
- Salão, Runas A/B, fonte: cena com saturação p50 0,12 a 0,14, quase cinza.

### 1.2 Figuras contra o chão (Salão 02, caixas apertadas)

| | luma p50 | luma p90 | matiz | sat p50 |
|---|---|---|---|---|
| Herói | 121 | 204 | 40 (com a capa e a Emeth) | 0,25 |
| Esqueletos (três) | 50 a 73 | 99 a 126 | 21 a 29 (morno) | 0,27 a 0,38 |
| Chão vizinho | 72 | 83 | 225 (frio) | 0,12 |

O herói lê bem (p90 120 acima do chão). Os esqueletos ficam 0 a 22 abaixo do chão em valor e se separam pelo **matiz**
(morno sobre frio) e pelo contorno; no Ember & Blade é a mesma estratégia (figuras escuras e mornas sobre chão claro e
frio), então a direção está certa. O que atrapalha é o chão em volta: grade de juntas escuras com o mesmo contraste do
contorno das figuras.

### 1.3 Hub

| | Cena luma p50 | Cena sat p50 | Meio luma p50 | Bordas luma p50 (razão ao meio) |
|---|---|---|---|---|
| Hades II, clareira (08) | 36 | 0,40 | 114 | 7 a 12 (**0,06 a 0,10**) |
| Selagem, Santuário (hub) | **97** | 0,21 | 115 | 71 a 113 (**0,62 a 0,98**) |

### 1.4 Interface

| | Caixa | luma p10 / p50 / p90 | Leitura |
|---|---|---|---|
| Nossa carta de Bênção, terço de baixo | `230,780,410,130` | 20 / 20 / 20 | vazio absoluto |
| Nossa carta de Bênção, faixa sob a descrição | `230,690,410,60` | 19 / 20 / 23 | vazio |
| Nossa Forja, página direita abaixo do texto | `830,480,1000,420` | 189 / 193 / 198 | pergaminho liso, 40% da tela sem nada |
| Nossa Forja, página esquerda abaixo da lista | `100,420,620,480` | 189 / 194 / 199 | idem |
| Hades, carta de Bênção (07), faixa do corpo | `520,300,900,80` | 0 / 2 / 122 | texto, valores e cor ocupam a faixa |

## 2. O que eles fazem

### 2.1 Cena de luta
1. **Um matiz dominante por sala, saturado e de valor baixo** (azul-índigo no bosque da Hécate, sat p50 0,5). A cor é
   o ar da sala, não um acento; o cinza praticamente não existe.
2. **Chão calmo**: na escala de 2 a 3 m o chão varia só 5 a 15 de luma. O detalhe do chão é pincelada de baixo contraste
   e desenhos grandes (raízes, marcas, círculos), não uma grade.
3. **Hierarquia de valor clara**: chão escuro, figuras com picos de claro (pele, cabelo, arma), e o mais claro e mais
   saturado da tela é sempre o efeito ou o aviso (aviso laranja, golpe ciano). O olho vai direto à luta.
4. **Moldura cheia e escura**: as bordas têm a maior densidade de detalhe da tela (árvores, cogumelos, pedras), mas em
   valor baixo e saturadas no matiz da sala; o centro fica livre. Nunca se vê a sala "por fora" (penhasco, laje cortada,
   vazio liso): o mundo continua além da tela.
5. **Linha de tinta em tudo**: personagens e peças têm contorno desenhado e sombra recortada; a silhueta é a primeira
   leitura de cada peça.
6. **Silhuetas orgânicas e assimétricas**: troncos torcidos, pedras em pé tortas, borlas penduradas, mato. Pouquíssima
   aresta reta repetida.

### 2.2 Hub (08)
Uma clareira acesa no meio, quase preta nas bordas (razão 0,06 a 0,10), com primeiro plano escuro (mato, pedras em pé,
cortinas) recortando a tela. A heroína está no foco de luz; o resto é sugerido.

### 2.3 Interface
1. **A moldura tem silhueta própria**: ornamento no topo e nos cantos que quebra o retângulo (01, 05, 06); a carta de
   Bênção termina numa mancha de tinta, não num canto reto (07).
2. **Um tema de material por família de tela**, sempre o mesmo motivo (metal prateado e luas no inventário; faixa de
   cor nos menus de estação).
3. **Ilustração dentro do menu**: retrato grande do deus na escolha de Bênção (07), da personagem no diálogo (02), a
   estação desenhada ao fundo (03, 04). O menu é uma cena, não um formulário.
4. **Texto com hierarquia interna**: palavra-chave em negrito claro, número em cor de valor, efeito em linha própria
   com rótulo e valor alinhados, glossário lateral das palavras-chave (Conjurações, Fraqueza em 07). Nada de parágrafo
   centrado.
5. **Sem vazio**: a carta tem a altura do conteúdo; o painel grande é preenchido por grade, lista ou ilustração.
6. **Prompts nos cantos de baixo**: placa da tecla e verbo colorido (ESCOLHER, SAIR), sempre no mesmo lugar.

## 3. O que nós fazemos

### 3.1 O que está bom e fica
- **Câmara do Selo**: a única sala com a saturação da referência (0,50), matiz dominante violeta, bordas escuras, selo
  de ouro no meio. É o nosso modelo interno: as outras salas devem chegar perto dela na cor e na moldura.
- **Herói** legível em toda captura (p90 204 contra chão 72); a Emeth é a única coisa esmeralda viva.
- **Inimigos mornos sobre chão frio**: a separação por matiz funciona e é a do Ember & Blade.
- **Avisos**: o fio vermelho da mira e o aro dos avisos leem sobre qualquer chão.
- **HUD** (retrato, barras, losangos com a tecla) e a **linguagem do Livro de Ahk** (pergaminho, couro, cantoneiras):
  a direção é boa, falta conteúdo, não troca.
- **Provação** (sat 0,35, lilás dominante, luma 43): já perto da meta.

### 3.2 O que lê como protótipo
1. **Cena cinza**: saturação p50 0,12 a 0,29 em 14 das 16 salas de luta. Sem cor, a pedra parece material de
   bloqueio (greybox).
2. **Chão ruidoso na escala curta**: grade de juntas escuras e lajes de valores muito diferentes (39 a 72 de faixa
   numa caixa de 3 x 2 m, contra 5 a 15 no Hades). É a textura mais contrastada da tela e compete com as figuras e os
   avisos. Atenção: o Sworn P1 (SW-G1 a G3) abriu de propósito a faixa do chão do meio; o certo é **variação grande
   (manchas de 3 a 8 m, gradiente para a borda, lajes emolduradas) com a escala curta calma**, não as duas juntas.
3. **Faixa de perto clara**: no Salão, Fendas B e Santuário a parte de baixo da tela é tão clara quanto o meio (razão
   0,83 a 1,00). A tela não tem moldura; o olho escorrega para fora.
4. **Maquete sobre o vazio**: Cripta A, Fendas A, Jardim A e Ponte mostram a parede de fora da sala como um bloco liso
   de tijolo e, além, um vazio em degradê com listras verticais de bruma (Cripta A: caixa `1250,700,600,250` com luma
   16 a 51, valor certo mas sem forma nenhuma). Lê como cenário de teste montado no ar.
5. **Silhuetas de bloco**: balaustradas em ameia, pedestais cúbicos, sarcófagos retangulares, módulos repetidos; quase
   nada orgânico quebrando as linhas. Peças do KayKit à vista (caixotes, barris) e velas em cachos quase da altura do
   herói (Salão), o que dá escala de brinquedo.
6. **Sem linha de tinta no cenário**: as figuras têm contorno, as peças não; personagem desenhado sobre cenário 3D de
   jogo de celular.
7. **Luz morna desbotada**: as poças de fogo saem bege; o único acento quente da sala não tem cor.
8. **Hub de dia**: luma 97, bordas tão claras quanto o meio, toldo listrado de feira; nada sugere o lugar sagrado
   escondido sob a igreja.
9. **Interface de formulário**: retângulos de filete fino iguais em toda tela, cartas com o terço de baixo vazio, texto
   centrado sem hierarquia, medalhões chapados, Forja com 70% das páginas em branco, nenhuma ilustração nas telas de
   escolha.
10. **HUD do combo sobre a luta**: a caixa "N Golpes / nome do golpe" à direita cobre inimigos (Ponte A, quadro 11) e usa
    Cinzel fino abaixo de 24 px (contra a regra 8 do `art_direction.md`).

## 4. Pedidos

Prioridade: **P0** = é o que mais faz parecer protótipo e vale para toda sala; **P1** = acabamento visível; **P2** =
polimento. Todo aceite é na GPU (`tools/gpu.sh shot`), 1920 x 1080, estilizado, `--seed=5`, salas em luta
(`--bot --autopick --shot-at=9`, `--arena=<id> --variant=<n>`), antes e depois no mesmo quadro, com a tabela do
`frame_stats.py --hue --scene` e das caixas da seção 0. Toda mudança só no estilizado (o clássico do F7 igual, como no
redesenho) e sem mexer em colisão, aviso, tempo nem regra. Compatibility abre sem erro; iGPU Baixa a 1280 x 720 sem
perder mais de 3 qps.

### 4.1 environment-artist

**ENV-HB1 (P0) Cor do ar em toda sala.** Subir a saturação do mundo estilizado mantendo o matiz dominante que cada sala
já tem (matriz do redesenho): pedra, chão, bruma e fundo pintados no matiz da sala, não no cinza. Caminhos: a saturação
do `VisualProfile.dress_world` (0,77), o `paint_recolor`/`paint_stone` e a pedra e o chão de cada `STYLE`. O modelo é a
Câmara do Selo.
Aceite: em todas as salas de luta (A e B) e nas de evento, cena com **saturação p50 entre 0,30 e 0,45** (hoje 0,12 a
0,29) e luma p50 entre 45 e 65; matiz p50 da cena a até 15 graus do de hoje; saturação p90 no formato antigo entre 18 e
32. As cores reservadas continuam únicas: na cena, faixa vermelho até 1,5% fora de aviso, verde e ciano até 1% (Jardim:
o oliva fica abaixo de 100 graus de matiz p50 e verde até 2%). Caixa 300 x 300 em volta do herói: herói luma p90 pelo
menos 90 acima do p50 do chão vizinho (hoje 121 / 204 contra 72).

**ENV-HB2 (P0) Chão calmo na escala curta, variado na escala larga.** Baixar o contraste das juntas (para perto do valor
da laje) e o salto de valor entre lajes vizinhas no campo da luta; manter as manchas do bioma (SW-G1), o gradiente para
a borda, a sombra recortada (SW-G2) e as lajes emolduradas (SW-G3, SW-C1), que são escala larga.
Aceite: em três caixas de chão nu de 200 x 150 por sala (coordenadas anotadas na entrega), **p90 menos p10 até 30**
(hoje 39 a 72; Hades 5 a 15); entre duas caixas de chão nu a 6 m ou mais uma da outra, diferença de p50 de 10 ou mais
(a variação larga continua). Fio da mira e aro dos avisos: diferença de luma para o chão em volta igual ou maior que a
de hoje (tabela do Sworn P1 no `CLAUDE.md`).

**ENV-HB3 (P0) Moldura escura e cheia.** As bordas e a faixa de perto descem em valor e ficam saturadas no matiz da sala:
peças de primeiro plano escuras entre a câmera e a sala (pilar, arco quebrado, corrente, raiz, cortina de hera), que
abrem em pontilhado em volta do herói como os obeliscos (`see_through`), e bruma colorida no vazio. Nada de vinheta de
tela nova (a do `screen.gdshader` fica como está). Densidade de detalhe no terço de fora, campo do meio livre.
Aceite: em toda sala, **laterais e faixa de perto com luma p50 até 0,65 do meio** (hoje até 1,00 no Salão, 0,95 nas
Fendas B, 0,83 no Santuário A, 0,84 no Jardim A) e saturação p50 de 0,30 ou mais nessas caixas; o herói continua a mais
de 18% da borda sem nada opaco sobre ele (raio-x só onde já existe).

**ENV-HB4 (P1) Nada de maquete no ar.** Onde a sala mostra o lado de fora (Cripta A ao sul e leste, Fendas A a oeste,
Jardim A a oeste, Ponte), o paredão liso de tijolo vira rocha e arcos que descem para a bruma, com raízes, correntes e
ruínas em duas profundidades (a `ArenaRoom.backdrop` já faz isso nas câmaras de evento), e as listras verticais de bruma
somem.
Aceite: na caixa sobre o vazio (Cripta A `1250,700,600,250` e equivalentes anotadas por sala), luma p50 até 0,5 do chão
do meio, **p90 menos p10 de 30 ou mais** (formas, hoje 35 só pelas listras) e saturação p50 de 0,30 ou mais; nenhuma
faixa vertical clara contínua de mais de 200 px.

**ENV-HB5 (P1) Silhueta orgânica nas bordas.** Quebrar os módulos retos repetidos que ficam na tela (balaústres em ameia,
pedestais cúbicos, fileiras de sarcófagos iguais): peças tortas e quebradas, entulho, pano, hera e raiz por cima das
arestas, uma de cada tipo por trecho de borda; só no terço de fora.
Aceite: nas caixas laterais, p90 menos p10 de 50 ou mais (detalhe) com p50 dentro da regra do ENV-HB3; nenhuma
sequência de mais de 4 módulos idênticos alinhados visível numa captura; o `tools/fit_probe.gd` igual ou melhor.

**ENV-HB6 (P1) Hub à noite, com foco.** O Santuário fica uma clareira acesa no meio da noite: luz principal sobre a
praça e a estação em foco, bordas em valor baixo no matiz frio, primeiro plano escuro (arcadas, floreiras, cortina de
hera) recortando os cantos; toldo do Vendedor em pano gasto (terra e petróleo apagados, não listra de feira).
Aceite (`--hub --hero-at=0,0` e as cinco estações): cena luma p50 entre 40 e 60 (hoje 97), meio p50 de 90 ou mais,
**bordas (`0,0,1920,200`, `0,880,1920,200`, `0,200,300,680`, `1620,200,300,680`) até 0,35 do meio** (hoje 0,62 a 0,98;
Hades 0,06 a 0,10), saturação p50 da cena de 0,30 ou mais. A placa da estação legível (contraste 4,5:1).

**ENV-HB7 (P2) Fogo com cor e escala certa.** Poças das velas e braseiros com saturação p50 de 0,45 ou mais na caixa da
poça (hoje bege); velas do Salão com altura até 0,25 da do herói na captura (hoje os cachos chegam perto da metade);
caixotes e barris do KayKit fora do campo de luta.

### 4.2 technical-artist

**TA-HB1 (P1) Linha de tinta nas peças.** Contorno por salto de profundidade só (sem o Kuwahara do STY-07, que borrava as
runas), aplicado às peças de cenário e não ao relevo do chão: 1,5 a 2,5 px a 1080, tinta no valor da sombra da sala,
mais fino longe. Alternativa se o pós não couber: casca invertida nas peças do kit (como as figuras).
Aceite: recortes de 400 x 300 em três salas mostrando a linha nas peças e nenhuma linha nova sobre as runas do
medalhão, as lajes emolduradas nem os avisos; custo até 0,3 ms de GPU na RTX a 1080 e iGPU Baixa sem perder mais de 3
qps; Compatibility abre sem erro (sem a linha lá é aceitável).

**TA-HB2 (P1) Kit de primeiro plano e de borda.** As peças que o ENV-HB3 a HB5 pedem: pilar quebrado, arco partido,
cortina de raiz, hera pendurada, corrente com peso, entulho grande, todas com `see_through`, um material por família,
peças procedurais ou do kit existente (Meshy zero sem o Daniel).
Aceite: inventário em `docs/art/asset_inventory.md` com triângulos e chamadas por peça; uma sala de teste montada com
elas dentro do orçamento acima.

**TA-HB3 (P2) Figuras depois da cor nova.** Com ENV-HB1 e HB2 feitos, conferir a separação: inimigo comum com luma p50 a
20 ou mais do chão vizinho (para cima ou para baixo) **ou** matiz a 90 graus ou mais dele; acento (olho, gema, pano) com
saturação p90 de 0,45 ou mais na caixa da figura; elites com o ouro lido como hoje. Barras de vida de um grupo
(`CrowdRenderer.add_bar`) sem sobreposição de mais de metade da altura entre duas (Ponte A, quadro 11, tem três
empilhadas).

### 4.3 ui-ux-designer

**UI-HB1 (P0) Cartas sem vazio.** Carta de Bênção e de anjo com a altura do conteúdo (não 450 fixo): nome, família e
raridade, e o efeito em linhas de rótulo e valor alinhados ("Congela por" / "0,4 s"), como uma ficha; o que muda contra
a que se tem; glossário à direita da fileira de cartas para as palavras-chave da carta em foco (congela, queima, Magia,
Ômega), uma linha cada, na tinta da interface.
Aceite: nenhuma faixa de 60 px de altura dentro de uma carta com p90 menos p10 abaixo de 8 (hoje o terço de baixo é 20 /
20 / 20); `tools/ui_lab.gd -- --card-only` e as capturas `meet_*` a 720 e 1080 sem texto cortado.

**UI-HB2 (P0) Hierarquia dentro do texto.** Corpo em marfim apagado; palavras-chave e números em marfim cheio e negrito
(sem usar esmeralda, petróleo, vermelho de perigo nem cor de raridade, que são reservados); efeito sempre com o número
à vista, nunca só em frase; texto alinhado à esquerda nas cartas e painéis (centrado só em título).
Aceite: na caixa da descrição de cada carta, luma p90 de 40 ou mais acima do p50 do texto comum (o negrito se destaca);
teste de texto (`test_c17_ui.gd` ou novo) garantindo que toda descrição de Bênção com número o mostra marcado.

**UI-HB3 (P1) Molduras com silhueta nossa.** Os painéis de tela (pausa, cartas, anjos, Forja, Vendedor) ganham um remate
no topo e cantoneiras de ouro velho com o losango e, onde couber, o leão em relevo pequeno, quebrando o retângulo; uma
família de moldura por tipo de tela (cartas: medalhão no topo; menus de estação: a capa e as cantoneiras do Livro; pausa:
o painel de tinta). Nada de lua, caveira, faixa de cor do Hades.
Aceite: capturas antes e depois a 720 e 1080 de cada tela; nenhuma moldura reta sem remate nos quatro tipos.

**UI-HB4 (P1) Ilustração nas telas de escolha.** Encontro dos anjos e escolha de Bênção com uma figura grande à esquerda,
como o retrato do deus no Hades: por enquanto **o selo do anjo** (`AngelSeal`, cerca de 360 px a 1080, sobre um brilho na
cor do anjo abaixo do glow), até o Daniel decidir se os anjos têm figura e como (pergunta abaixo; não inventar). Forja: a
própria Emeth grande na página esquerda, com o posto atual e o próximo (`EmethSword.set_temper`), antes e depois.
Aceite: na Forja, nenhuma caixa de 400 x 200 dentro das páginas com p90 menos p10 abaixo de 12 fora das margens
(hoje 189 / 193 / 198 numa caixa de 1000 x 420); no encontro, a figura ocupa a coluna da esquerda sem cobrir as cartas
a 720.

**UI-HB5 (P1) Contador de golpes fora da luta.** A caixa "N Golpes" e o nome do golpe saem de cima do campo: menores,
sem fundo, perto do HUD de baixo ou do retrato, Alegreya Sans Bold (Cinzel só a partir de 24 px).
Aceite: em 10 capturas de luta (Ponte A, Fendas A, Salão), a caixa nunca cobre barra de vida nem figura; nenhum texto
Cinzel abaixo de 24 px a 1080 no HUD.

**UI-HB6 (P2) Prompts nos cantos.** Toda tela de escolha e de estação com os prompts no canto de baixo à direita (e o
secundário à esquerda): placa da tecla real (`ActionSlot.key_plate`) e o verbo em versalete ouro velho, sempre no mesmo
lugar, no lugar das linhas centradas ("Esc: voltar aos anjos").
Aceite: as telas de cartas, anjos, Forja, Vendedor, Livro e pausa com os prompts na mesma posição medida (desvio até 4
px) a 1080.

## 5. Ordem sugerida e perguntas

Ordem: ENV-HB1 e ENV-HB2 juntos numa sala (Salão, a de abertura) para o Daniel ver antes de espalhar; depois HB3 e a
moldura; UI-HB1 e UI-HB2 em paralelo (arquivos distintos); TA-HB1 depois que a cor assentar (a linha muda a leitura do
valor). Revisão do art-director a cada lote em `docs/art/visual_review.md`.

Para o Daniel, pelo Game Director:
1. **Subir a saturação do mundo** (ENV-HB1) muda o estilizado que ele aprovou na direção do Ember & Blade e do Hades
   (cena com cor, não cinza). Ele quer ver o Salão assim antes do resto?
2. **Os anjos têm figura?** Para a ilustração das telas de escolha (UI-HB4). Até a resposta, só o selo.
3. **Hub à noite** (ENV-HB6) contra o entardecer da `hub_spec_art.md`.

## 6. Atualizações que este estudo pede no guia

A seção 3 do `docs/art/art_direction.md` tem teto de saturação do cenário (p90 até 32) e nenhum piso; hoje estamos em 9
a 14 e o piso é o que falta. Quando ENV-HB1 for aprovado, o art-director acrescenta: cena com saturação p50 de 0,30 a
0,45; bordas e faixa de perto até 0,65 do meio; chão nu com p90 menos p10 até 30; hub com bordas até 0,35 do meio.
