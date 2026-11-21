# AP-4 "Livro, coleção e título": especificação de arte

Autor: art-director, 2026-11-21. Backlog: `docs/backlog.md` Lote 5B (linha 361) e MAP-06; itens ART-06.2, 06.3, 07.1 a
07.5, 10.2 a 10.4, 01.5 e ART P1-10 de `docs/art/art_polish_backlog.md`.

Objetivo do ciclo: **a coleção parece uma coleção e o Livro parece um livro.** Toda tela do Livro (Abertura, O
Guerreiro, Dons, Compêndio, Mapa, Forja) fala uma língua só: papel, tinta, rubrica, ouro gravado e couro. Nada de caixa
escura de interface por cima do papel.

## 0. Escopo, regras e medida

### 0.1 Fora deste ciclo (pede arte ou decisão do Daniel)

| Item | Por que fica de fora | O que vale até lá |
|---|---|---|
| ART-06.2 medalhões pintados das Bênçãos, Elos e Salmos | Q-24: dependem de prancha nova do Daniel | os vetores de hoje; ver 2.4 (só o aro igualado, sem pintura nova) |
| ART-07.3 cena de Ahk escrevendo | Q-03 e Q-23 (a): Ahk só pela voz e por objetos | vinheta de objetos (1.4) |
| ART-07.5 retrato do Guerreiro com a Emeth certa | Q-04 (a): o retrato fica até haver arte | sem tarefa |
| ART-08.1 cruzes e a maga do título | Q-07 (a) pede arte nova de IA | sem tarefa; 1.10 só escurece o fundo dos menus |

Regras do ciclo: nada de Meshy nem imagem gerada por IA; tudo é vetor desenhado em código, shader ou o nosso modelo
assado. Nada canônico novo (nenhum nome, símbolo, legenda ou figura que o cânone não tenha). Nunca cruz, sol nem olho em
marca nova. Leão e espada só onde já estão (selo, estandartes, Câmara).

### 0.2 Linguagem do Livro (valores fixos, já no código)

- Papel `Book.PAPER` (0,83; 0,75; 0,60), luma cerca de 190. Tinta `Book.INK`, apagada `Book.FADED`, rubrica
  `Book.RUBRIC`, ouro que lê no papel `Book.GILT`, couro `Book.LEATHER` e `LEATHER_EDGE`, fita `Book.RIBBON`.
- Ouro no papel é sempre "gravado": `GILT` com 1 px mais claro em cima (luz de cima à esquerda) e 1 px de tinta a 0,4
  embaixo. Nunca ouro saturado (saturação HSV até 0,55, matiz 32 a 42).
- Seleção e foco no papel: aguada (`Book.BUTTON_LIT`) mais um sinal de tinta ou rubrica (losango, fita fina). **Nunca
  caixa cheia de petróleo ou preto** sobre o papel (hoje o índice do Compêndio faz isso).
- Algarismos sempre em `UiKit.number_font()` (regra do P0-1 da revisão d2ff05d).

### 0.3 Como medir

- 720 = 1280 x 720; 1080 = 1920 x 1080. Capturas na GPU, uma por vez (`tools/gpu.sh shot <saída> --title
  --screen=book|hero|gifts|codex|map ...` com `RES=1920x1080`; `tools/book_lab.gd`, `tools/ui_lab.gd`,
  `tools/menu_lab.gd`, `tools/sketch_lab.gd`). Medida por `python3 -I tools/frame_stats.py <img> --box=x,y,w,h --hue`.
- "Contraste" = razão WCAG entre a cor média do traço e a do papel em volta. Texto: 4,5:1 ou mais. Traço de desenho
  (marca, motivo, linha do mapa): 3:1 ou mais.
- Espessura: medida no recorte ampliado (largura do traço onde a luma passa da metade entre papel e tinta).
- Toda entrega traz as capturas antes e depois nas duas resoluções em `docs/gallery/ap4/` com o mesmo nome e sufixo
  `_720`/`_1080`. Aprovação final: art-director (esta revisão) e depois o Daniel.

---

## 1. ui-ux-designer

### 1.1 Capa de couro (ART-07.2, parte da moldura) (P1)

Hoje: a capa é uma faixa marrom chapada de 12 px com fio claro.

Pedido (`BookSpread`, um shader novo `book_cover.gdshader` ou o desenho no `_draw`, à escolha):
- Couro com grão: ruído fino de 2 a 3 px a 1080 (escala com a altura da tela), variação de valor de no máximo 6%.
- Gasto nas quinas e no meio das bordas: até 10% mais claro e 0,1 menos saturado, num raio de 40 px a 1080.
- Vinco cego (gravado sem ouro) em linha dupla a 10 px e 14 px da borda de fora: 1 px escuro e 1 px claro ao lado.
- Costura: pontilhado na cor `LEATHER_EDGE` clareada 30%, traço 4 px e vão 3 px a 1080, a 6 px da borda de fora.
- Cantoneiras de ouro velho que já existem passam para a capa (não para a página), com dois rebites de 3 px.
- A capa aparece com pelo menos 18 px a 1080 e 12 px a 720 em volta das folhas (`COVER` escalado).

Aceite: luma p50 do couro 20 a 35 e saturação p50 até 0,45 (`--box` numa faixa da capa); a costura difere do couro
em luma 12 ou mais; nenhuma emenda ou repetição visível na borda de cima a 1080; a tela do Livro, do Compêndio, do Mapa
e da Forja usam a mesma capa.

### 1.2 Abas como fitas (ART-07.2) (P1)

Hoje (`Book.mark`): retângulos largos de couro em cima do livro, todos iguais; o aberto só tem a borda petróleo.

Pedido:
- Cada capítulo é uma fita estreita que sai **de dentro do livro**, por trás da borda de cima da capa (a fita começa
  escondida sob a capa, sem emenda à vista), e sobe acima dela.
- Largura = texto + 24 px a 1080 (mínimo 120 px); ponta de cima em rabo de andorinha (corte em V de 8 px a 1080).
- Fechada: couro tostado (`LEATHER_EDGE`), sobe 30 px a 1080; texto em Cinzel na cor do papel a 0,75.
- Aberta: fita petróleo `RIBBON` com 1 px de brilho na borda esquerda e 1 px escuro na direita, sobe 42 px; texto em
  marfim cheio. O rabo de andorinha da aberta tem 10 px.
- Sombra de 2 px a 0,35 da tinta abaixo e à direita, sobre o fundo (não sobre o papel).
- O mesmo componente nas abas do Livro, do Compêndio (quando houver abas) e das Configurações? **Não**: Configurações
  não são o Livro; ficam com `UiKit.tab`.

Aceite: a 720 o texto de cada fita tem pelo menos 13 px de altura de versal e contraste 4,5:1 com a fita; a aberta é
lida em uma olhada: mais alta em 10 px ou mais (1080) e matiz da fita a 15 graus ou menos do `RIBBON`; nenhuma fita
cobre o título da página; LB/RB e clique continuam (`title_flow_check`).

### 1.3 Seleção no papel (ART-07.2, ações em ouro gravado) (P1)

Hoje: a entrada escolhida do índice do Compêndio é uma caixa cheia petróleo com borda rubrica
(`docs/gallery/fatia3_ui/codex_angels_720.png`).

Pedido: entrada escolhida = aguada `BUTTON_LIT`, fita rubrica de 4 px a 1080 na borda esquerda descendo 4 px abaixo
da entrada (como um marcador), texto em `RUBRIC`, marca do capítulo em rubrica. Foco sem seleção = só o losango
rubrica à esquerda. Vale para `Book.index_entry` em todo lugar (Compêndio, Forja, Mapa).

Aceite: nenhum pixel com luma abaixo de 60 numa caixa de entrada selecionada fora do texto e da marca; contraste do
texto 4,5:1; a entrada selecionada e a em foco se distinguem numa captura com as duas à vista.

Também: a marca das **Arenas** no índice é o mesmo arco dos **Salmos**. Trocar a das Arenas por uma planta de sala
(losango com uma boca de porta embaixo, traço de tinta). Aceite: as nove marcas do índice diferentes duas a duas
(nenhum par com a mesma silhueta numa captura a 720).

### 1.4 Abertura: vinheta e capitular (ART-07.3, parte possível) (P1)

Hoje: página esquerda com o título e a epígrafe, metade de cima vazia.

Pedido:
- Vinheta vetorial em tinta sépia acima do título "Livro de Ahk": um rolo de papiro meio aberto (com linhas de escrita
  ilegíveis, como `hub_page.gdshader`), uma pena num tinteiro e um rolo fechado com lacre de cera rubrica com o leão do
  selo (`lion_sdf.res`, o mesmo leão da Câmara). Sem figura humana, sem rosto, sem mão.
- Tamanho 360 x 200 px a 1080 (240 x 133 a 720), centrada na coluna; traço de contorno 2 px (1080), hachura de 1 px
  nas sombras, aguada `FADED` a 0,15 no lado sem luz.
- Capitular: o "M" de "Meus amados" em Cinzel rubrica com altura de 3 linhas, num quadrado de filete `GILT` com
  ramagem simples (folhas, nunca cruz nem estrela); a epígrafe passa a alinhada à esquerda numa coluna de 520 px a 1080
  para a capitular assentar. Assinatura "Ahk, o Escriba" continua à direita, sem mudança de texto.

Aceite: a 720 a vinheta e o texto não se tocam (12 px ou mais de folga); traço de contorno de 1,5 px ou mais a 720 com
contraste 3:1; a capitular ocupa 3 linhas exatas sem empurrar a epígrafe para fora da página; nenhum texto novo.

### 1.5 Árvore de Dons no papel (ART-07.1) (P1)

Hoje: a árvore fica numa lousa preta dentro do pergaminho; nós trancados mostram cadeado e número grandes.

Pedido (`TalentTree`, `TalentNode`):
- Sai a lousa. A árvore é desenhada no papel da página esquerda dentro de um filete duplo de tinta (moldura de prancha,
  `Book.INK` a 0,6, 1 px e 1 px com 3 px de vão a 1080), com cantos em ângulo.
- Linhas da árvore em tinta `FADED` 1,5 px (1080); linha acesa entre dois equipados em `GILT` 2 px com o brilho do
  gravado (0.2); a linha do caminho em foco em rubrica (hoje marfim, que no papel some).
- Nó = medalhão em losango com fundo de papel tostado (papel x 0,85), aro de ouro gravado de 2 px e o **motivo pintado
  do Dom** (2.2) dentro. Estados:
  - equipado: fundo na cor do ramo escurecida para o papel (`Book.ink(cor do ramo)`) a 0,35, aro `GILT` cheio, selo
    redondo esmeralda com visto no canto (já existe);
  - aberto: fundo papel tostado, motivo em cor cheia;
  - selado (Memória): motivo a meia força, folha da Memória com o preço embaixo (já existe);
  - bloqueado: moldura cortada nas pontas e motivo a 0,4 (já existe);
  - trancado pela Maestria: **motivo apagado** (tinta `FADED` a 0,35, sem cor), cadeado pequeno de 10 px (1080) no
    canto de baixo e o nível em `number_font` 13 px ao lado do cadeado. Cadeado e número nunca no centro do nó.
- Nomes dos ramos em Cinzel rubrica (hoje coloridos em fundo escuro); a cor do ramo fica só no motivo e no equipado.
- Custo em losangos pequenos continua, em tinta (não ouro claro).

Aceite: a 720 todo nó tem pelo menos 44 px de lado e o motivo pelo menos 26 px; o trancado tem o motivo reconhecível
(o mesmo contorno do aberto a 0,35) e o cadeado ocupa até 20% da área do nó; nenhum pixel abaixo de luma 50 na área da
árvore fora dos motivos, cadeados e textos (a lousa saiu); `tests/test_book.gd` e `tests/test_hero_screen.gd` verdes.

### 1.6 Compêndio ilustrado (ART-07.4) (P1)

- Inimigos: o detalhe da entrada mostra o esboço a tinta do `FigureSketch` (2.1) num quadro de prancha (filete duplo de
  tinta como na árvore), a figura com 300 px de altura a 1080 e 200 px a 720, parada no `idle` e girando devagar como
  hoje ou fixa na vista de 3/4 (escolha do ui-ux-designer; fixa lê melhor como gravura). Nome em Cinzel rubrica embaixo,
  papel em `RoleMark` e a contagem.
- Desconhecido: silhueta em tinta `FADED` a 0,3 do mesmo modelo, sem linhas internas, e "Derrote um para conhecer."
- Listas: as linhas "???" juntadas numa linha só no fim da lista, "N por descobrir" em `FADED` com um losango vazado.
  Vale para Bênçãos, Elos, Inimigos e Anjos. Salmos ficam como estão (cada um tem a sua Pista, que é informação).
- Elites: entrada própria com o esboço da elite (o ouro em aguada, 2.1).

Aceite: as 9 figuras e as elites com desenho a 720 e 1080; nenhuma linha "???" repetida nas quatro abas; o esboço
inteiro dentro do quadro (2.1); `tests/test_e4_ui.gd` e `test_bench_ui.gd` verdes.

### 1.7 MAP-06, a página do mapa (P2)

Hoje (`docs/gallery/dv1/ui/map_middle_1080.jpg`): discos pretos chapados sobre o papel, linhas cinza, números em Cinzel
pequenos à esquerda.

Pedido (`MapGraph`, `MapScreen`), **sem mudar nenhuma marca** (as do `DoorGlyph`, iguais às placas):
- Nós "pintados": medalhão com corpo de tinta escura (`INK` x 1,3, não preto: luma 35 a 50), aro de ouro gravado de 2 px
  (1080) e um anel de papel de 1 px entre o aro e a tinta. A marca dentro igual à de hoje. Nó apagado (ficou para trás):
  corpo `FADED` a 0,3, aro em tinta, marca a 0,5. Sala atual: aro duplo petróleo (já existe). Porta aberta: aro e
  ligação em ouro gravado (já existe).
- Ligações: as alcançáveis em tinta 2 px; as deixadas em tinta tracejada (4 px traço, 4 px vão) a 0,35; o caminho feito
  em rubrica 3 px com pontas arredondadas (hoje 3 px, fica).
- Fundo da descida: as camadas a cada duas profundidades com uma aguada de 4% de valor a menos (faixas horizontais
  suaves, sem borda dura), para a página ler como estratos descendo.
- Vinheta do topo: acima do nó 1, a boca das catacumbas em tinta (arco de pedra com três aduelas e degraus descendo),
  40 x 50 px a 1080. Nada de figura.
- Morvath no fim como selo: o nó 11 vira um lacre de cera (disco de borda irregular, 1,5 vez o nó comum) em violeta
  escuro apagado (matiz 275 a 290, saturação até 0,45, valor até 0,45) com as três divisas de Morvath gravadas em ouro.
  O nome "Morvath" fica ao lado como hoje.
- Números das salas na margem em `number_font` 15 px (1080) em `FADED`.
- Legenda: as amostras da legenda usam o mesmo medalhão novo.

Aceite: nenhuma marca diferente das placas (comparar `DoorGlyph` lado a lado); a 720 todo nó com 28 px ou mais de
diâmetro e marca com contraste 3:1 sobre o corpo; o lacre de Morvath com saturação p50 até 0,45 e matiz 275 a 290;
ligação deixada distinguível da alcançável a 720 (tracejado visível); `tools/map_flow_check.gd` e
`tests/test_map_screen.gd` verdes. Capturas `--title --screen=map --map-at=start|middle|doors` a 720 e 1080.

### 1.8 Vitória, cartas e topo do HUD (ART-10.2 a 10.4) (conferir e fechar)

Estes já foram feitos (QW-115, UI-HB1, HudVeil). Pedido: recapturar e, onde não passar, corrigir.
- ART-10.2 vitória (`tools/menu_lab.gd`, vitória em três momentos): halo sem nenhum disco de borda dura (perfil radial
  da luma sem degrau maior que 8 entre anéis de 4 px a 1080); nenhum pixel do halo com saturação acima de 0,5 e luma
  acima de 200 ao mesmo tempo; título e frase sobre o véu com contraste 4,5:1; o leão chega ao brilho cheio em 0,6 s
  (quadros a 0,0, 0,3 e 0,6 s).
- ART-10.3 cartas: nenhuma carta (Bênção, Elo, Salmo, Encanto, Provação, Altar) com mais de 20% da altura vazia entre o
  fim do texto e a borda de baixo, a 720 e 1080 (`tools/ui_lab.gd -- --card-only` com a carta de texto mais curto e a de
  texto mais longo).
- ART-10.4 topo do HUD: véu atrás do relógio, sala e ouro presente na luta da Ponte e do Salão (as mais claras no
  topo); nenhum texto em Cinzel abaixo de 24 px a 1080 no HUD (abaixo disso, Alegreya Sans Bold); texto do topo com
  contraste 4,5:1 sobre o véu nas duas.

### 1.9 Glifos pequenos sem cruz (ART-06.3, QW-117) (conferir)

Recapturar a 720 e 1080 o losango R (Corte do Juízo), o escudo da Vigília, a lâmina de gelo e a pausa com muitas
Bênçãos (`menu_lab`). Aceite: em nenhum glifo dois traços se cruzam perto de 90 graus (entre 70 e 110) com os dois
braços maiores que 40% do glifo.

### 1.10 Título (ART-08.2 e 08.3, sem a arte nova) (P2)

- 08.2: o Iniciar em `UiKit.OLD_GOLD`; o brilho só na borda e só em foco. Aceite: preenchimento do botão com saturação
  p50 até 0,55 e matiz 32 a 42.
- 08.3: atrás das Configurações, Como Jogar e Músicas o fundo do título vai mais escuro e desfocado, para a cruz da arte
  não aparecer. Aceite: na caixa do clérigo e do estandarte (medir na captura de hoje) a luma p90 cai para 60 ou menos e
  nenhuma aresta da cruz é visível a 1080 (desfoque de pelo menos 8 px a 1080).

### 1.11 Ordem sugerida

1.3 e 1.1, 1.2 (a língua) → 1.5 (com os motivos do 2.2) → 1.6 (com o esboço do 2.1) → 1.4 → 1.7 → 1.8 a 1.10.

---

## 2. technical-artist

### 2.1 Esboço a tinta dos inimigos (`FigureSketch`): revisão da prancha

Prancha: `docs/gallery/ap4/sketch_enemies_lavapipe.jpg` (lavapipe, `tools/sketch_lab.gd`).

**Veredito: aprovado na direção.** É o nosso modelo, lê como gravura e não como captura do jogo; o contorno mais grosso
por fora e mais fino por dentro está certo, a hachura só na sombra está certa, a cor da tinta é a do Livro. Não entra
no Compêndio antes dos ajustes P1 abaixo.

P1:
1. **Sombra sob os pés.** A mancha redonda esfumada é luz de cena 3D, não desenho: no papel ela lê como borrão de
   aerógrafo e a única coisa macia da prancha. Trocar por **hachura de chão**: 3 a 5 traços horizontais de tinta,
   paralelos, de comprimentos desiguais, 1 px a 1080, alfa até 0,5, sob os pés numa largura de 0,6 a 0,8 da base da
   figura, o mais longo sob o pé de apoio. Sem degradê. (O código já diz `ground_shade = false`; se a prancha é de antes
   disso, a mancha some e entra a hachura.) Aceite: sob os pés, nenhuma mancha mais escura que o papel em 15 de luma com
   mais de 3 px de altura a 1080; os traços contam 3 a 5.
2. **Cabeças vazias.** As caveiras (esqueleto, corredor, besteiro, Escudo, Cavaleiro, elites) saem como ovais de papel
   claro, mais claras que o corpo: leem como rosto apagado. A aguada da pintura escura tem de pegar as órbitas, o nariz e
   a boca, e a cabeça recebe o mesmo tom do resto do corpo. Aceite: na caixa da cabeça, luma mínima até o papel menos 60
   (as órbitas aparecem) e luma p50 da cabeça a até 10 da p50 do tronco.
3. **Elites iguais aos comuns** (`skeleton_elite`, `guard_elite` idênticos aos comuns na prancha). O ouro da elite
   (`EnemyDef.gild`) entra como aguada de `Book.GILT` a 0,35 sobre as partes douradas, com a hachura por cima. Aceite:
   na elite, 8% ou mais dos pixels da figura com matiz 32 a 48 e saturação 0,3 ou mais; no comum, até 2%.
4. **Corte no quadro.** O cajado do feiticeiro e do Ancião sai pelo topo e o sacerdote sai pela direita. O enquadramento
   usa a caixa de todas as poses do clipe mostrado, arma inclusa, com margem de 4% da altura em volta (para o laboratório
   e para o `FigureView` do Compêndio). Aceite: nenhum pixel de tinta a menos de 4% da borda do quadro em nenhuma figura.
5. **Armas que somem.** O esqueleto e o corredor aparecem sem lâmina legível (vista de frente, a arma de perfil). Vista
   padrão de 3/4: figura girada 25 a 35 graus para a direita da tela e o tempo do `idle` escolhido por figura para a arma
   aparecer de lado. Aceite: em todo inimigo com arma (todos menos o corredor, se ele não tiver), a arma lida a 720 com
   pelo menos 20 px de comprimento.

P2:
6. Linha de contorno 2 a 3 px a 1080 e 1,5 px ou mais a 720; hachura com espaçamento de 3 px ou mais a 720 (hoje
   `HATCH_PX` 5 escalado dá 3,3: ok, manter o piso).
7. Corpo: o tom do papel tingido (hoje cerca de 8% abaixo do papel) fica; nada de branco puro em nenhuma parte.
8. Compatibility: o mesmo desenho no renderizador do navegador (os três passes dependem de profundidade); captura
   `DRIVER=opengl3`. Aceite: contorno e hachura presentes; nenhuma figura preta.
9. Custo: uma figura no Compêndio, até 1 ms de GPU na iGPU a 720 Baixa.
10. Prancha nova na GPU (`tools/gpu.sh run`) a 720 e 1080 com as 9 figuras e 3 elites, antes e depois, em
    `docs/gallery/ap4/`. A prancha de lavapipe não vale como aceite.

### 2.2 Motivos pintados dos 19 Dons (ART P1-10)

**Decisão: completam, não substituem os `TalentGlyph`.** O glifo continua sendo a marca pequena (até 28 px de lado:
listas do Compêndio, painel do Livro, Trazidos, qualquer lugar pequeno) e é o esqueleto do motivo: o motivo é o mesmo
desenho do glifo, com o mesmo contorno, vestido de pintura. Assim quem aprendeu o glifo reconhece o motivo, e o
Compêndio e a árvore falam a mesma coisa. Onde há espaço (nó da árvore, detalhe do Dom no Compêndio, painel do Dom
no Livro) entra o motivo.

API pedida: `TalentMotif` (`scripts/ui/talent_motif.gd`), `TalentMotif.draw(ci, id, centro, raio, estado)` com estado
`OPEN`, `EQUIPPED`, `SEALED`, `BLOCKED`, `LOCKED`; sem motivo próprio cai no `TalentGlyph.draw`. Abaixo de raio 14 px
o motivo desenha só o glifo (LOD).

Receita da pintura vetorial (igual para os 19, para virem de uma mão só):
- Até três tons por forma, em polígonos com borda dura (sem degradê): base na cor do ramo
  (`TalentNode.BRANCH_COLOR`, levada para o papel por `Book.ink`), sombra a 0,62 do valor na metade de baixo e direita
  da forma, luz a 1,22 do valor (sem passar de 0,9 em canal nenhum) numa faixa de cima e esquerda. Luz sempre de cima à
  esquerda.
- Fio de ouro gravado (`GILT`, 1 px a 1080) numa aresta de luz de cada forma principal.
- Contorno de tinta `INK` em volta de tudo: 2 px a 1080, 1,5 px a 720.
- Detalhe interno (hachura, veio, faceta) só acima de raio 22 px.
- Esmeralda da Emeth só no ramo Emeth e no Coração da Emeth; nunca acima de saturação 0,6 no papel.
- Proibido: cruz (dois traços a 70 a 110 graus com os dois braços maiores que 40% do motivo), sol (disco com raios),
  olho (amêndoa com círculo dentro), lâmina de pé com guarda (lê cruz: lâmina sempre inclinada, guarda curta ou nenhuma),
  corrente de elos (é a marca do Elo), leão (é o selo).

Esboço por Dom (ramo: Combo carmim, Fúria ferrugem, Emeth esmeralda, Magia azul, pontes ouro velho, sustento terra
rosada; a ordem é a dos arquivos em `data/talents/warrior/`):

| # | Dom | Efeito (resumo) | Motivo |
|---|---|---|---|
| 00 | Quarto Corte | quarto golpe, uma estocada, antes do giro | três talhos diagonais paralelos em carmim, crescendo, e o quarto é uma ponta de lâmina estreita e mais longa em esmeralda, na mesma diagonal; nenhum traço cruza outro |
| 01 | Passo Encadeado | o Corte Veloz conta como o 1º golpe | uma pincelada só: começa como três traços curtos de corrida embaixo à esquerda e dobra para cima num talho; a dobra com fio de ouro |
| 02 | Golpe sem Fim | giro que acerta 3 recomeça o combo | arco de 300 graus com a ponta voltando sobre o começo (cabeça de seta), três entalhes **tangenciais** na borda de fora (os três acertos; nunca radiais, senão vira sol), talho curto no meio |
| 03 | Ímpeto | cargas por abate, golpes mais rápidos | três divisas em fila para a direita, crescendo, a última cheia em ferrugem viva e as outras duas em contorno com a base |
| 04 | Avanço Feroz | abate com finalizador devolve a esquiva | seta com cabeça de lâmina para a direita, dois traços de velocidade atrás, e embaixo uma meia-volta curta voltando para a esquerda (a carga que volta) |
| 05 | Fúria Plena | três cargas, finalizador atordoa mais | chama de três línguas sobre três divisas cheias; três losangos pequenos em arco acima da chama (o atordoar) |
| 06 | Corte Crescente | o giro solta uma onda | a meia-lua da onda (W-1): barriga para a direita, borda de ataque pálida, corpo esmeralda afinando para trás, fio de ouro velho no meio, rastro curto em dois traços |
| 07 | Fio Longo | ataque alcança 15% mais | lâmina reta da Emeth deitada na diagonal (sem guarda), a ponta seguida por um fio pontilhado marfim e dois tiques de medida |
| 08 | Onda Atravessante | a onda atravessa a pedra | a meia-lua passando por dois blocos de cantaria partidos (junta escura entre eles), a onda inteira dos dois lados |
| 09 | Lâmina Faminta | Ômega depois de finalizador custa metade | gema azul em losango cheia só na metade de baixo, uma lâmina pequena inclinada cortando-a no meio |
| 10 | Reserva | +20 de Magia máxima | losango azul dentro de um losango maior vazado com duas facetas de luz; o de fora em contorno duplo |
| 11 | Coração da Emeth | ultimate carrega mais rápido, mais Magia | gema esmeralda lapidada mais alta que larga (a da guarda da Emeth), dentro de um aro partido em quatro arcos curtos, os vãos nas diagonais (sem raios) |
| 12 | Investida | Corte Veloz que derruba não gasta a esquiva | seta de lâmina atravessando um vulto de capuz em contorno (sem rosto), o vulto inclinado caindo para trás |
| 13 | Sangue Quente | abate com Ômega dá duas cargas | duas chamas lado a lado, a da frente maior em ferrugem-carmim, a de trás em contorno |
| 14 | Onda Carregada | Ômega do especial solta a onda do giro | meia-lua da onda com três pontos de luz atrás em fila (as cargas), o maior mais perto |
| 15 | Fio do Passo | o Corte Veloz solta uma onda curta | três traços de corrida embaixo à esquerda terminando numa meia-lua pequena em cima à direita |
| 16 | Firmeza | +10 de vida e +10 de Magia | gota terra-rosada e losango azul encostados, de pé sobre um degrau de pedra (barra larga com junta) |
| 17 | Respiro | sala vencida cura 2 | gota com uma divisa subindo dentro e um fiapo de ar curvo saindo do topo |
| 18 | Ainda de Pé | levanta uma vez com metade da vida | seta subindo de uma linha de chão partida (fenda em V), duas lascas caindo dos lados; nada de espada cravada de pé (lê cruz) |

Aceite (ferramenta nova `tools/motif_sheet.gd`, comando no topo, sem tela: prancha com os 19 nos cinco estados a raio
16 px, que é o da árvore a 720, e a raio 32 px, mais a tabela de semelhança):
- Silhuetas distintas: com cada motivo reduzido à máscara binária a raio 16, a interseção sobre a união de qualquer par
  abaixo de 0,8; os pares que passarem de 0,7 listados para o art-director olhar.
- Contraste: contorno contra o papel tostado do nó 3:1 ou mais; motivo trancado (0,35) ainda com o contorno visível
  (luma pelo menos 25 abaixo do fundo).
- Cor: maior canal até 0,9; saturação HSV p50 do motivo até 0,6; matiz p50 de cada motivo a até 20 graus da cor do
  ramo dele (pontes e sustento conferidos pelo art-director).
- Sem cruz, sol ou olho na prancha (revisão do art-director).
- Na árvore a 720 e 1080 (captura `--title --screen=gifts --hero-xp=2470`, tudo destravado, e `--hero-xp=160` com
  trancados) e no detalhe do Compêndio.
- Custo: o Livro aberto na aba Dons não perde mais de 0,5 ms de CPU por quadro (19 motivos redesenhados só quando o
  estado muda).

### 2.3 Medalhões das coleções (ART-06.2): só o que não pede pintura

A pintura nova fica com a Q-24. Até lá, pedido pequeno: o `BoonIcon` desenhado (as Bênçãos sem PNG, os Elos e os
Salmos) usa o mesmo aro dos PNG pintados (largura, ouro velho, sombra interna), para a mesma tela não misturar dois
aros. Aceite: numa tela com uma Bênção pintada e uma desenhada lado a lado (`ui_lab -- --card-only --offer=vapor,<sem
arte>,<elo>`), largura do aro a até 1 px e cor média do aro a até 10 de luma uma da outra a 1080.

---

## 3. environment-artist

### 3.1 Marca de recompensa sobre as portas (ART-01.5) (P2)

O disco que paira sobre a boca da porta passa a ficar preso: haste de ouro velho do topo do arco (ou da verga, onde a
porta é uma escada sem arco: um poste baixo de ferro de 1,2 m ao lado da boca) até o pé do disco, com um berço de ouro
velho segurando a borda de baixo (o mesmo do `RewardGem.Stand` do relicário). O balanço lento para a câmera fica, com a
haste balançando junto. Nada colide; a placa e o ponto de usar iguais.

Aceite: numa sala vencida com três portas (Salão e Cripta, Longe e Perto) a haste lida a 1080 com 3 px ou mais de
largura e contraste com a parede atrás; nenhum disco solto no ar; a marca e a placa não se cobrem a 720; `fit_probe`
igual. Relevo na verga fica recusado (não lê a 720).

---

## 4. Ordem e dependências

1. technical-artist 2.1 (ajustes do esboço) e 2.2 (motivos) em paralelo, arquivos distintos.
2. ui-ux-designer 1.1 a 1.3, depois 1.5 com o `TalentMotif` e 1.6 com o `FigureSketch` aprovados.
3. ui-ux-designer 1.4, 1.7, 1.8 a 1.10; environment-artist 3.1 a qualquer momento.
4. Revisão do art-director nas duas resoluções de cada tela; depois, o exe para o Daniel.
