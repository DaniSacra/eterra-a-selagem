# Câmara do Selo: especificação de arte (ciclo C11)

Autor: art-director, 2026-11-15. Para: `environment-artist` (câmara, selo, perímetro, luz, materiais, transparência) e
`gameplay-engineer` (forma do chão, colisão, câmera, avisos recortados, ganchos do selo, opções de captura).
Nada aqui foi implementado; nada foi gerado no Meshy. As decisões D-14 a D-18 do `docs/backlog.md` (seção 7) já foram
tomadas pelo Game Director e esta especificação as segue.

- Pedido: `docs/design/boss_arena_brief.md`. Planejamento e conta do raio: `docs/backlog.md`, seção C11.
- Referência: `docs/art/ref/morvath/camara_do_selo.png` (1672 x 941, feita por IA, **só local**, fora do repositório
  público; declarada em `docs/steam-ia.md`). Comparações lado a lado com ela ficam fora do repositório
  (`C:\Users\danie\ASelagem-teste\`); dentro do repositório só capturas do nosso jogo.
- Método de medida: o de `docs/art/arena_reference.md` (direções das bordas dão a câmera; marcos projetados no chão dão
  as posições). Contas feitas com a mesma fórmula de `CamFrame.screen_of`.
- Convenções: metros; centro da câmara (centro do selo) na origem; `x` para leste, `z` para o sul (norte = `-z`), como
  no resto do jogo. **Rumo** = graus a partir do norte no sentido horário: `x = r sen(rumo)`, `z = -r cos(rumo)`.
  "Tela" = captura de 1920 x 1080 com a câmera do jogo (seção 4).
- Decisões aplicadas: **D-15** só Morvath luta aqui (as salas comuns continuam no `CatacombHall`); **D-18** raio andável
  12 m; **D-14** a porta selada substitui o portal vermelho na luta; **D-16** geometria da imagem com o leão de pé
  entalhado no miolo e a rachadura atravessando; **D-17** nada de cruz: espada erguida nos sarcófagos, pilaretes e estandartes; o leão só no selo (o leão em quatro
  sarcófagos sugeriria quatro paladinos do leão, e o cânone fala de um por selo; decisão da sessão, a confirmar).

---

## 1. Leitura da imagem

**O que ela mostra.** Plataforma redonda de pedra escura sobre um abismo violeta e azul, com arcadas ogivais sob a
borda; balaustrada contínua com velas, quatro lanternas de chama violeta, quatro pilaretes góticos de ponta e dois pares
de sarcófagos; uma escadaria longa entrando pela esquerda de baixo da tela; ao fundo à direita, uma fachada gótica com
escada curta, porta dupla de ouro e violeta com uma costura de luz violeta, duas estátuas encapuzadas de mãos juntas,
dois estandartes carmim e dois braseiros; uma torre quadrada à esquerda do alto e correntes enormes cruzando o topo do
quadro; ao fundo de tudo, um anel distante de arcadas com janelinhas quentes e agulhas góticas na bruma azul. No meio,
o selo de ouro velho (anel duplo, estrela de oito raios iguais, uma cruz de linhas no miolo) com uma rachadura violeta
acesa, e Morvath de pé sobre ele; o herói entra pela boca da escadaria.

**Câmera da imagem (medida).** Ajustei a elipse do chão (borda interna da balaustrada: esquerda x 300, direita 1390,
fundo y 245, frente y 745) com a câmera do jogo. Com giro de 35° (o do jogo), a imagem fecha com inclinação **27°**,
campo de visão 24° e distância **51 m**, a câmera olhando 1 m à frente do centro (para o lado da câmera); erro de cerca
de 10 px na elipse. Lente longa, verticais quase paralelas, como a pintura da arena. Com esse giro os eixos da pintura
caem limpos: a escada da fachada fica no rumo 1° e a boca da escadaria de entrada no rumo 178°; os degraus da
escadaria de entrada correm de leste a oeste (a escada desce para o sul). Ou seja: **a porta fica ao norte e a entrada
ao sul do mundo**; o "sudoeste" do pedido é o canto de baixo à esquerda **da tela** (com a câmera girada 35°, o sul do
mundo aparece embaixo à esquerda).

**A fachada não encara o centro: encara a câmera.** As quinas dos degraus dela correm no rumo 63° a 83° (medido pelos
degraus, pelas estátuas e pelos braseiros), então a frente da fachada olha para o rumo 165° (sul-sudeste), 20° da
direção de onde a câmera vem (145°). É por isso que a porta aparece quase de frente. Mantive: a fachada fica girada.

**O que a pintura não resolve (e como decidi).**
- O par de sarcófagos de baixo à direita está dentro do chão (r 10) e o de cima à esquerda na borda (r 13). A regra
  de colisão manda tudo na borda: os dois pares ficam na borda. Na tela, o par de baixo cai 80 a 110 px mais para fora
  do que na pintura. Diferença aceita.
- A cruz (sarcófagos, pilaretes, estandartes, miolo do selo e porta) sai toda (D-17).
- As velas da pintura estão no chão, na frente da balaustrada; aqui ficam num ressalto da própria balaustrada (fora do
  andável).
- Os estandartes da pintura descem até quase o chão do pórtico; com a fachada na geometria certa, a ponta deles fica
  cerca de 70 px mais alta na tela. Aceito.

---

## 2. Planta

### 2.1 Raios (todos a partir da origem)

| Faixa | Raio | Uso |
|---|---|---|
| Centro de Morvath no máximo | 11,1 | 12,5 menos o raio dele (1,4); vale para qualquer corpo: 12,5 menos o raio |
| **Centro do herói no máximo (raio andável)** | **12,0** | D-18; 12,5 menos `Player.RADIUS` (0,5) |
| Linha de limite gravada no chão | 12,45 | filete de ouro velho de 0,04 m embutido, contínuo, inclusive na boca das duas escadas |
| Face interna da balaustrada (borda do chão) | 12,5 | dado do jogo: `RoomLayout` da câmara, campo do raio do chão = 12,5 |
| Ressalto das velas (topo do rodapé) | 12,5 a 12,78 | velas e potes pequenos; sem colisão (fica além do círculo) |
| Corrimão | 12,78 a 13,23 | centro em 13,0 |
| Pilares da balaustrada | 12,55 a 13,45 | `Masonry.POST` 0,9 x 1,3 x 0,9, centro em 13,0 |
| Rodapé | 12,5 a 13,4 | 0,26 de altura (`Masonry.CURB`) |
| Borda da plataforma (cimalha) | 13,6 | daqui para fora, o abismo |
| Nichos dos sarcófagos | até 14,5 | só nos arcos dos dois pares (seção 2.4) |

Contas do raio (do backlog C11, conferir por teste): investida existe com o herói a 9 m ou mais de Morvath; vão da
tempestade passa de 2 m a partir de 7,4 m; anel do ritual 6,5 m mais um morto; a câmera cabe com margem (seção 4).

### 2.2 Chão

- Disco de raio 13,6 (até a cimalha), mais as duas bocas de escada. Só o círculo de 12,5 conta para o jogo.
- Faixa de borda: anel de lajes de meio-fio de r 12,05 a 12,5, um passo mais escuras (valor 0,8), com o filete de ouro
  velho em 12,45. Na boca das escadas o filete continua e o meio-fio vira uma soleira de pedra (mesma faixa, sem
  degrau). É o desenho do limite: o herói para onde o filete está.
- Lajes: `catacomb_floor.gdshader` sem o medalhão do salão (`ring_radius` 0). Lajes menores que as do salão, como na
  pintura (de 0,6 a 0,9 m de lado): `unit` 0,8. Fileiras retas (não radiais), juntas escuras (#0a0c12 a #12131c na
  tela). Inscrições: 8% das lajes com linhas de glifos gastos (o desenho do `rune_glyph.gdshaderinc`, só entalhe
  escuro, contraste no máximo 15% do valor da laje, sem brilho, sem cor), mais frequentes numa faixa de r 7 a 9.
  Nada de inscrição dentro de r 5,3 (é o selo).

### 2.3 O selo (geometria; estados na seção 6)

Desenhado num disco próprio de raio 5,3 deitado sobre o chão (não bloqueia nada). A estrela fica alinhada com a tela,
como na pintura: as pontas apontam para os eixos da tela e para as diagonais (rumos 325°, 10°, 55°, 100°, 145°, 190°,
235° e 280°; é o `rose_turn = cam_yaw` que o salão já usa). Com isso uma ponta aponta para a porta (10°), uma para a
entrada (190°) e duas para os sarcófagos (100° e 280°).

| Peça | Medida | Material |
|---|---|---|
| Anel externo | traço duplo: dois filetes de 0,06 m em r 3,50 e 3,66, sulco escuro entre eles | ouro velho embutido |
| Anel interno | traço duplo em r 2,82 e 2,96 (o escudo do ritual tem 2,9: ele nasce sobre este anel) | ouro velho |
| Faixa entre os anéis | 16 losangos pequenos (0,22 x 0,12 m) e 16 folhas alternados; nada de cruz | ouro velho, metade do contraste dos anéis |
| Oito raios | losango alongado de r 3,66 até a ponta em r 5,0, base 1,0 m no anel, aresta no meio (metade 15% mais escura), contorno de ouro de 0,05 m, miolo de pedra 12% mais clara | pedra e ouro |
| Folhas nos vãos | uma folha de ouro de 0,4 m entre cada par de raios, em r 4,0 | ouro velho |
| Miolo (r < 2,82) | **o leão de pé entalhado** (abaixo); nenhuma linha reta atravessando o miolo | pedra em relevo e ouro |
| Rachadura | ver abaixo | violeta |

**O leão** (D-16; o cânone: "cada selo tem um leão de pé entalhado"; "a rachadura atravessa o leão de cima a baixo").
- Leão de perfil, de pé sobre as patas de trás (a postura de brasão), voltado para a esquerda da tela, cabeça para o
  alto da tela (rumo 325°). Altura 4,2 m da pata de trás à orelha, largura 3,0 m, cabe inteiro em r 2,7.
- Desenhado à mão pela equipe como vetor (`assets/textures/seal/lion.svg`), sem traçar brasão de ninguém e sem IA;
  convertido num campo de distância de 512 x 512 para o shader (contorno, relevo e brilho saem do mesmo campo).
- Relevo: o corpo 10% mais claro que a pedra do miolo, com sombra de 0,04 m do lado de baixo da tela (normal tirada do
  campo de distância); contorno de ouro velho de 0,05 m; olho, juba e garras em entalhe escuro.
- Leitura: a 1920 x 1080 o leão mede cerca de 140 px de largura e 100 px de altura na tela (o chão visto a 30° encurta
  pela metade o que corre para o fundo da tela). Tem de ler como leão (juba, patas, cauda) a esse tamanho, e não como
  mancha: traços internos de no mínimo 0,06 m (3 px), silhueta com recortes fundos entre as patas e a cauda.
- Pendente de confirmação (seção 12): a postura "de pé" pode ser em pé nas quatro patas; o vetor troca sem mexer em
  nada mais.

**A rachadura** (uma polilinha de largura variável, 0,03 a 0,07 m, com 4 a 6 ramos curtos; núcleo violeta, borda escura
queimada de 0,12 m). Cresce com as fases (comprimento dado por fase, crescendo em 1 s a cada troca):
- fase 1: da cabeça do leão até as patas de trás, de cima a baixo dele (rumo 325° a 145°, dentro de r 2,7);
- fase 2 (depois do ritual): um ramo sai da barriga do leão para a entrada (rumo 190°) e corta o anel interno;
- fase 3: o ramo chega ao anel externo; um segundo ramo curto corta o anel interno para o norte (rumo 10°);
- fase 4: o ramo sul atravessa o raio de 190° até a ponta (r 5,0) e o do norte chega ao anel externo.

### 2.4 Perímetro (peça por peça)

Todas as peças ficam com a face interna em r 12,5 ou além. Posições pelo centro da peça.

| Peça | Rumo | r | x, z | Tamanho | Observação |
|---|---|---|---|---|---|
| Par de sarcófagos oeste | 278° (cada um em 273° e 283°) | 13,0 | (-12,87; -1,81) | cada um 2,0 x 1,0 x 0,85 m mais tampa de 0,15 com aba de 0,08; vão de 0,3 entre eles | eixo longo tangente ao círculo; face interna em 12,5 |
| Par de sarcófagos leste | 96° (91° e 101°) | 13,0 | (12,93; 1,36) | igual | igual |
| Lanternas violeta | 264°, 292°, 82°, 110° | 12,85 | (-12,78; 1,34), (-11,91; -4,81), (12,72; -1,79), (12,07; 4,39) | poste de pedra 0,6 x 1,0 x 0,6; gaiola de ferro 0,45 x 0,75 com telhado de ponta de 0,3; total 2,1 m | ladeiam os sarcófagos; ocupam o lugar de um pilar |
| Pilaretes góticos | 125°, 193°, 310°, 332° | 12,95 | (10,61; 7,43), (-2,91; 12,62), (-9,92; -8,32), (-6,08; -11,43) | base 0,9 x 0,9, corpo até 2,8, ponta piramidal de 0,6 (total 3,4 m) | espada erguida em painel ogival nas faces que olham o centro e a câmera; o de 193° é a ombreira oeste da boca da escadaria |
| Pilar da ombreira leste da escadaria | 167° | 12,95 | (2,91; 12,62) | `Masonry.post` | |
| Braseiro oeste | 341° | 13,4 | (-4,42; -12,70) | pedestal de 0,9 (`BRAZIER_PEDESTAL`), bacia de `BRAZIER_BOWL` | fim da balaustrada oeste, ao pé da escada da fachada |
| Braseiro leste | 22° | 16,9 | (6,40; -15,60) | igual | no nível do chão, à frente do contraforte leste, num pátio pequeno fechado: da bochecha leste da escada da fachada, a balaustrada sai do pilar terminal (18°) e contorna o braseiro pelo lado do abismo até o contraforte leste |
| Potes | 336° e 18° | 13,6 e 13,8 | (-5,53; -12,42), (4,26; -13,12) | `Masonry.pot` 0,8 e 1,0 | junto do pedestal do braseiro oeste e do pilar terminal leste |
| Pilar terminal leste da fachada | 18° | 12,95 | (4,00; -12,32) | `Masonry.post` | a balaustrada leste termina aqui, contra a bochecha da escada da fachada |
| Balaustrada | de 18° a 167° e de 193° a 341°, menos os arcos dos sarcófagos | | | `Masonry.balustrade`, pilares a cada 3,0 m de arco (cerca de 13,3°) | curva: segmentos de corda de um pilar a outro |

**Nichos dos sarcófagos.** No arco de cada par (rumo do par mais e menos 12°) a balaustrada recua: os sarcófagos ficam
na linha da borda (sobre um plinto de 0,2 m que vai de 12,5 a 13,6), e atrás deles um parapeito baixo (0,6 m, liso,
com tampa) em r 14,1, sobre uma saliência da plataforma até r 14,5. Entre os sarcófagos e as lanternas, só velas no
plinto. Não sobra chão no nível do piso entre 12,5 e o parapeito que pareça andável.

**Sarcófagos.** Caixa de pedra com base e tampa chanfradas (`Masonry.bevel_mesh`, `CHAMFER_BIG`), um friso a 0,6 m. Na
tampa, a espada erguida em relevo raso (a mesma dos pilaretes, 0,8 m de altura, sem ouro, só relevo e sombra) e uma borda
de ouro velho de 0,03 m. Na face longa voltada para o centro, um painel rebaixado liso. Pedra um passo mais clara que
a balaustrada (tint 1,1), como os blocos claros da pintura (#825460 na luz da lanterna).

**Velas** (20 grupos de 3 a 6, `Masonry.candle`, receita do salão; grupos com luz marcados com L). Rumos: 23 (L),
32, 56 (L), 81, 96 (no plinto dos sarcófagos leste, L), 115, 129, 140 (L), 163, 196, 213 (L), 234, 258 (L), 266, 283 (no
plinto dos sarcófagos oeste), 304 (L), 315, 328 (L), 336 (com o pote), 345. Todos no ressalto da balaustrada (r 12,6 a
12,75) ou no plinto, nunca no chão. **No arco da frente (rumos 100° a 190°) as velas têm no máximo 0,45 m**, para não
esconder o chão (seção 3.2).

**Luz das lanternas**: `OmniLight3D` cor (0,6; 0,3; 1,0), energia 1,5, alcance 4,5, atenuação 1,3, sem sombra, fora da
camada da multidão (como os braseiros, `ArenaKit.WARM_MASK`). Vidro emissivo (0,55; 0,25; 1,0) com maior canal 1,0;
chama de 0,12 m (0,9; 0,4; 1,6). Na tela: núcleo perto de #ad40c1 a #d070e0; chão a 1,5 m da lanterna com mediana entre
#45284a e #5a3460 (a pintura dá #4f2e52).

### 2.5 Fachada norte e a porta selada

Coordenadas locais da fachada: `a` ao longo da frente (positivo para leste-nordeste, rumo 75°, vetor (0,966; -0,259)),
`n` para a frente (rumo 165°, vetor (0,259; 0,966)). Origem `D` = centro da soleira da porta = **(0,37; -16,47)**,
r 16,5, rumo 1°. Mundo = `D + a (0,966; -0,259) + n (0,259; 0,966)`.

| Peça | a | n | Altura | Medida |
|---|---|---|---|---|
| Plano da porta (fundo do vão) | 0 | 0 | pórtico em 0,9 | vão 3,4 x 5,0 em ogiva, recuado em 3 ordens de aduelas (receita do portal do salão: `PORTAL_ORDERS`, `PORTAL_ORDER_RING`, `PORTAL_ORDER_STEP`) |
| Pórtico | -4,6 a 4,6 | 0 a 1,4 | 0,9 | lajes do chão em escala menor |
| Escada da fachada | -3,0 a 3,0 | 1,4 a 3,4 | 0,9 até 0 | 6 degraus de 0,15; os 5 de cima retos (corrida 0,33); **o de baixo curvo**, com a frente exatamente no arco r 12,5, para o pé da escada encostar no círculo sem sobra de chão |
| Bochechas da escada | ±3,0 a ±3,6 | 1,4 a 3,4 | 0,9 descendo | muretas com tampa; a oeste termina no pedestal do braseiro oeste, a leste no pilar terminal |
| Estátuas encapuzadas | ±3,9 | 0,6 | sobre plinto de 0,3 no pórtico | `Masonry.hooded_statue`, 4,4 m, mãos juntas e vazias, valor 0,8 (oeste em (-3,24; -14,88), leste em (4,29; -16,90)) |
| Contrafortes | ±5,6 | 0 a 1,25 | até 12,5 | 1,4 de largura, pináculo (`Masonry.pinnacle`) no topo |
| Estandartes | ±5,6 | 1,3 | barra em 8,5 | `ArenaKit.banner`, pano 1,5 x 6,0 mais ponta em V de 0,6 (ponta em 1,9); carmim `BANNER_CLOTH`, borda `BANNER_TRIM`; **espada erguida** em ouro velho (seção 5.4) |
| Corpo da fachada | -7,5 a 7,5 | -4 a 0 | 12,5 no frontão | cantaria `Masonry.ashlar`, janelas ogivais escuras, frontão de 60° (`GABLE_SLOPE`) |
| Fecho do arco | 0 | 0 | 6,4 | losango de pedra com a espada erguida em relevo, sem brilho |

**A porta.** Duas folhas de 1,7 x 5,0 de madeira e ferro escuros arroxeados (albedo (0,2; 0,12; 0,22); na tela #392241),
com ferragens de ouro velho de 0,12 m formando o mesmo desenho do selo: um anel de r 1,3 centrado a 2,6 m do pórtico e
oito raios dele até a moldura, mais a moldura em volta. **A costura entre as folhas é o raio violeta**: uma linha
quebrada de 0,06 m de largura, do pórtico ao topo da ogiva, com ramos curtos, núcleo (0,62; 0,22; 1,2) com maior canal
1,4 (a porta fica a 3,5 m ou mais do herói; pode brilhar) e uma gema de 0,12 m onde a costura cruza o anel. Luz:
`OmniLight3D` violeta no pórtico, energia 1,5, alcance 5. Nenhuma cruz. A porta não abre.

### 2.6 Escadaria de entrada (sul)

- Eixo norte-sul em `x = 0`, descendo para o sul. Largura útil 4,6 m, muretas de 0,6 m com tampa (de `x` ±2,3 a ±2,9).
- Lance 1: 6 degraus de 0,2 x 0,5, da boca (z 12,9) até z 15,9; patamar de 1,2 m (z 15,9 a 17,1) com dois pilares
  `Masonry.post` nas muretas; lance 2: 14 degraus até z 24,1 e y -4,0, sumindo na bruma. Arcos ogivais sob a escada
  (vão de 2,4 m), como o viaduto da pintura.
- **Não é andável na luta.** O herói nasce dentro do círculo, na boca: **(-0,9; 10,4)**, olhando para o norte (para
  Morvath). Morvath começa em **(0; -1,2)**, sobre o selo, olhando para o sul. (Como na pintura: o herói chega pela boca,
  Morvath no meio.)
- **Véu da entrada** (sinal visual, sem colisão própria; o limite é o círculo): da aparição de Morvath até
  `victory_done`, uma cortina baixa de runas violeta atravessa a boca, de pilar a pilar (4,6 x 1,2 m, sobre a soleira):
  o desenho do `ritual_rune.gdshader` em pé, alfa 0,35, maior canal 0,8, glifos subindo devagar (0,3 m/s). Some em
  0,8 s na vitória. Não diz nada de história: só que a luta fecha a saída. Se o Daniel não gostar, sai sem afetar o
  resto.

### 2.7 Embaixo e longe

| Peça | Onde | Medida e material | Alvo na tela (vitrine, 1920 x 1080) |
|---|---|---|---|
| Muralha sob a plataforma | cilindro de r 13,6, de y -0,6 a -14 | cimalha de 0,6 (ashlar), arcos ogivais a cada 15° (vão 2,4 x 5,5, topo em -1,6, fundo recuado 0,8 e escuro), pedra `depth_stone` sumindo na bruma | mediana perto de #1b1547 embaixo do chão (y 85% a 100%) |
| Torre | rumo 286°, r 16 | seção 3,2 x 3,2, de y -20 a y 30 (sai do quadro), cantaria escura; janela ogival acesa (0,8 x 1,4, vidro quente (1,0; 0,55; 0,25), maior canal 1,0) em y 3,5 | x 540 a 600, some atrás da balaustrada noroeste; janela perto de (555, 150) |
| Correntes | três (abaixo) | `ArenaKit.chain`, elos de 1,0 m, ferro (0,06; 0,065; 0,07) | ver abaixo |
| Anel de arcadas distante | r 38, coroamento em y -4, descendo até -30 | arcos ogivais de 4 m, `depth_stone` com névoa; só o lado do fundo (rumos 230° a 40°); janelinhas quentes de 0,6 x 1,0 a cada 10° (uma em três acesa) | cruza o quadro de lado a lado entre y 8% e 26% |
| Agulhas e torres na bruma | r 55 a 70, rumos 250° a 40° | `ArenaKit.ruin_card` em duas camadas, `RUIN_STONE` e `RUIN_EDGE` | silhuetas escuras contra o azul no terço de cima |
| Bruma e abismo | abaixo de y -3 | névoa de altura e `ArenaKit.abyss_fog` (densidade 0,04, emissão (0,25; 0,12; 0,5)); cartões de bruma violeta nas laterais | laterais violeta, topo azul (seção 5.2) |

Correntes (como no salão, o alvo é a posição na tela; ajustar âncoras e barriga até bater):
- A: entra pela borda esquerda entre y 0 e 30, desce até perto de (265, 130) e sobe até a torre perto de (540, 40).
- B: sai da torre perto de (585, 60), desce até perto de (800, 115) e sobe ao contraforte oeste da fachada perto de
  (1068, 25) (âncora no contraforte em cerca de 6,8 m de altura).
- C: sai do contraforte leste perto de (1642, 103), desce até (1745, 120) e sai pela borda direita perto de y 65.
- Nenhuma corrente passa sobre o chão da câmara na tela (todas acima de y 130 nas metades de cima).

---

## 3. Colisão e transparência

### 3.1 Colisão (dono: `gameplay-engineer`)

- **O chão é um círculo de raio 12,5**; o centro de um corpo de raio `r` fica a no máximo `12,5 - r` da origem
  (herói 12,0; esqueleto 12,0; Morvath 11,1). É toda a colisão do cenário: nenhuma caixa, nenhum círculo de peça,
  nenhum retângulo invisível. As peças ficam todas além de 12,5 (tabela 2.4), então não precisam de colisão própria.
- Sem cantos: o herói desliza pela borda em qualquer rumo, inclusive nas bocas das duas escadas (o filete de 12,45
  marca onde para).
- O selo não bloqueia nada.
- Pontos de invocação e de erupção sempre a `r <= 12,5 - raio - 0,3` (o morto inteiro dentro, com folga para a runa).
- O raio 12,5 vai como dado da sala (`RoomLayout` da câmara, escolhido por `StageDef.boss_layout`), não como constante.

### 3.2 O que fica entre a câmera e a luta

A câmera fica no rumo 145° (sudeste), a 46,8 m na horizontal e 27 m de altura. Calculei quanto chão andável (r < 12)
cada peça esconde (o "corte de vista" de uma peça de altura `h` vai `h x distância / altura da câmera` para trás dela):

| Peça (rumo) | Altura | Chão andável escondido | Tratamento |
|---|---|---|---|
| Pilarete 125° | 3,4 | até 2,8 m para dentro | `see_through` obrigatório |
| Pilarete 193° | 3,4 | até 0,8 m | `see_through` |
| Lanterna 110° | 2,1 | até 1,0 m | `see_through` |
| Pilares da balaustrada de 100° a 190° | 1,52 com tampa | até 1,0 m (no rumo 145°) | `see_through` |
| Corrimão de 100° a 190° | 1,05 | até 0,6 m | `see_through` |
| Sarcófagos leste (96°), lanterna 82° | 1,05 e 2,1 | nada | nada |
| Velas do arco da frente | até 0,45 m sobre o ressalto | quase nada | limite de altura (2.4) |

- `see_through` é o pontilhado que já existe no `masonry.gdshader` (obeliscos, ciclo 9). As peças do arco da frente
  (rumos 100° a 195°, balaustrada, pilaretes 125° e 193° e lanterna 110°) usam material próprio com `see_through` 1;
  o resto da balaustrada não (o pontilhado não pode aparecer no fundo).
- Hoje o furo abre só em volta do herói (`global uniform hero_pos`). Pedido: abrir também em volta de Morvath (um
  segundo ponto global, por exemplo `boss_pos`, posto longe quando não há chefe), raio 2,2 m. Assim nada esconde nem
  um nem outro.
- A altura da balaustrada fica igual em volta toda (a da pintura); com o pontilhado não é preciso rebaixar a frente.

---

## 4. Câmera

Igual à do jogo: giro 35°, inclinação 30°, campo de visão 24°, distância 54 (`Feel`). O que muda é para onde ela olha
(dono: `gameplay-engineer`, `Game.cam_look_at` e `CamFrame`):

- **Alvo fixo C = (0,40; 0,57)**: 0,7 m do centro do selo na direção da câmera, para a câmara ficar um pouco mais alta
  no quadro, como na pintura. Sem `cam_lead` (sem adiantar para onde ele anda) na câmara.
- Sobre esse alvo, `CamFrame.keep` com `SAFE` 0,18, como hoje: a câmera só se mexe quando o herói chegaria a menos de
  18% de uma borda da tela. Desvio máximo do alvo: 3,0 m.
- Os retângulos de margem do salão (`CAM_MARGIN`, `CAM_SOUTH`, `view_north`) não valem aqui.

**Quanto se vê** (contas com a fórmula do `CamFrame.screen_of`, herói medido pelo peito, 1,25 m):

| Tela | Zoom | Chão (face interna da balaustrada) na tela | Peito do herói no limite (r 12), pior caso | A câmera precisa andar? |
|---|---|---|---|---|
| 16:9 | 1,0 | x 19% a 81%, y 26% a 82% | 20,0% da borda | não |
| 16:9 | 1,08 (carga do Ômega) | x 17% a 83%, y 24% a 84% | 17,6% | sim, poucos centímetros |
| 16:10 | 1,0 | x 16% a 84% | 16,7% | sim, até cerca de 0,6 m |
| 4:3 | 1,0 | x 9% a 91% | 10,0% | sim, até cerca de 2,5 m |
| 21:9 | 1,0 | x 27% a 73% | 22,8% | não |

Em 16:9 a câmara inteira cabe com o alvo parado: 19% de cada lado da tela mostram abismo, sarcófagos e torre; os 26% de
cima mostram a fachada (cortada no alto, como na pintura: o topo do vão da porta fica em y 57) e o anel distante; os 16%
de baixo mostram a cimalha, as arcadas e a escadaria. O canto de baixo à esquerda é a escadaria; o terço de cima à
direita é a porta. Morvath no limite norte fica com a coroa em y 19% (abaixo da barra do chefe).

**Vitrine** (`--showcase` na câmara): a mesma câmera do jogo (alvo C, 54 m). Para pôr lado a lado com a pintura:
`--showcase --cam-dist=51 --cam-pitch=27` reproduz o quadro dela (erro de cerca de 10 px na borda do chão).

**Onde cada marco cai na tela** (câmera do jogo, 1920 x 1080; entre parênteses a pintura reescalada para 1920):

| Marco | Jogo | Pintura |
|---|---|---|
| Centro do selo | (960, 524) | (949, 540) |
| Ponta do selo à esquerda | (727, 524) | (704, 534) |
| Soleira da porta | (1337, 243) | (1358, 276) |
| Topo do vão da porta | (1352, 57) | (1358, 52) |
| Estátua oeste, pé / leste, pé | (1185, 231) / (1484, 273) | (1189, 247) / (1499, 287) |
| Braseiro oeste / leste (bacia) | (1103, 230) / (1543, 292) | (1091, 218) / (1550, 304) |
| Pé da escada da fachada | (1308, 317) | (1292, 324) |
| Sarcófagos oeste / leste | (572, 345) / (1488, 751) | (572, 349) / (1412, 666) |
| Lanternas 264° / 292° / 82° / 110° | (484, 393) / (682, 312) / (1547, 672) / (1372, 815) | (482, 396) / (680, 335) / (1504, 660) / (1311, 741) |
| Pilaretes 310° / 332° / 125° / 193° | (830, 284) / (1021, 278) / (1215, 871) / (441, 755) | (829, 287) / (1033, 262) / (1229, 810) / (427, 752) |
| Boca da escadaria | (544, 817) | (552, 805) |
| Herói e Morvath no começo | (603, 735) e (991, 502) | (597, 721) e (988, 522) |

---

## 5. Materiais, cores e luz

### 5.1 Paleta (valores do jogo e alvos na tela)

| Cor | Para quê | Valor (linear, como no código) | Alvo na tela (sRGB) |
|---|---|---|---|
| Pedra escura (chão) | lajes | `stone_a` (0,19; 0,20; 0,30), `stone_b` (0,27; 0,28; 0,40) | mediana do chão do meio #31365a (luminância 45 a 60; B - R de 25 a 45; R e G a até 8 um do outro) |
| Pedra das peças | balaustrada, fachada, sarcófagos | `Masonry.ASHLAR_A`, `ASHLAR_B`, multiplicador frio (0,95; 1,0; 1,04) | balaustrada #2d2842, fachada #26223e |
| Violeta profundo | pigmento do abismo e da corrupção; luz das lanternas e do abismo | pigmento (0,17; 0,08; 0,28); luz `Boss.VIOLET` (0,62; 0,22; 1,2) | abismo lateral #381685; núcleo da rachadura #d04bd2 |
| Azul espectral | abismo alto, névoa do fundo, runas dos avisos | (0,32; 0,6; 1,0) (o `spirit` do `ritual_rune.gdshader`) | topo do abismo #0f315e a #16507f |
| Esmeralda corrompido | veios da corrupção na fase 4 | **(0,32; 0,70; 0,60)** (matiz 165°, saturação 0,55, valor 0,7; ART_REVIEW N9) | sempre mais azulado e mais escuro que a Emeth (`Combat.EMETH` (0,3; 1,0; 0,45)); nunca verde-menta |
| Ouro antigo | selo, ferragens, filete do limite, espadas, bordas | albedo `gold_light` (0,478; 0,384; 0,22); brilho `Boss.OLD_GOLD` (0,72; 0,58; 0,32) | traço do selo parado entre #6a5844 e #8e7444; nunca amarelo saturado |
| Carmim | estandartes | `BANNER_CLOTH` (0,6; 0,1; 0,12) | #6d182a |
| Fogo | braseiros e velas | receitas do `ArenaKit` e do `Masonry` | estouro só nas chamas |
| Vermelho de perigo | avisos | `GroundLook.WARNING_COLOR` (1,0; 0,18; 0,12) | ver seção 8 |

Regra de leitura: a pedra é fria e pouco saturada; o violeta vem da luz (lanternas, abismo, rachadura), não da pedra.
Assim os efeitos violeta de Morvath não somem no chão.

### 5.2 Luz e atmosfera (dono: `environment-artist`; Forward+ primeiro)

- Ambiente: cor (0,30; 0,33; 0,50), energia 0,3.
- Luz do meio: `OmniLight3D` em (0; 9; 0), cor (0,78; 0,76; 0,95), energia 3,0, alcance 17, atenuação 1,0, fora da
  camada da multidão: o meio do chão um pouco mais claro que a borda, como na pintura.
- Lua: direcional vinda do noroeste, por trás, cor (0,45; 0,55; 0,85), energia 0,35, com sombra.
- Quente, pouco: **só os dois braseiros** (`BRAZIER_LIGHT` 4,5, alcance 8, atenuação 1,3; o oeste com sombra) e 8
  grupos de velas com luz (energia 1,2, alcance 2,8, sem sombra). O quente fica na fachada e em manchas pequenas da
  borda.
- Violeta: as quatro lanternas (2.4), a costura da porta e o abismo: duas luzes violeta (0,55; 0,25; 1,0), energia 5,
  em y -12, nas laterais da tela (rumos 250° e 80°, r 22), que não tocam o topo da plataforma (camada de luz das
  profundezas, `ArenaKit.DEPTH_LAYER`).
- Azul: uma luz (0,25; 0,5; 1,0), energia 3, em (rumo 330°, r 45, y 4), só na camada das profundezas: recorta as agulhas
  e o anel de arcadas.
- Névoa: de distância como no salão (`FOG_MODE_DEPTH`, de 64 a 130); de altura enchendo o abismo abaixo de y -3;
  volume violeta no abismo. Fundo (0,02; 0,08; 0,18).
- Compatibility (navegador): sem névoa volumétrica; cartões de bruma no lugar; conferir com `DRIVER=opengl3` que o p50
  fica a até 10% do desktop.

### 5.3 Leitura do combate

- O chão do meio fica médio-escuro (luminância 45 a 60) para o vermelho translúcido dos avisos ler e as juntas
  continuarem visíveis através dele.
- **Nada no chão até r 12,5 passa do limiar do glow** (1,3; `Game.GLOW_THRESHOLD`): maior canal da emissão final do
  selo, dos veios, da rachadura, do filete e da luz das peças no chão no máximo 1,0. Brilham acima do limiar só as
  chamas, a costura da porta, as janelas distantes e os efeitos de golpe.
- O herói (capa petróleo, cabelo ruivo, couro) e o anel dele (petróleo) se leem sobre a pedra fria; nenhuma luz da
  câmara é petróleo.
- Desenho por cima do selo: chão, selo, avisos (`Ground`), anel do herói. O selo nunca cobre um aviso.

### 5.4 Símbolos (D-17)

- **Espada erguida** (pilaretes, estandartes, fecho do arco): espada de ponta para cima, lâmina de 70% da altura do
  desenho, afinando até a ponta; guarda curta (30% da altura) com as pontas caindo levemente; punho e pomo em disco.
  Sem círculo atrás e sem braços iguais: tem de ler como espada, não como cruz. Nos estandartes, 1,2 m de altura em ouro
  velho, centrada a 1/3 do topo do pano. Nos pilaretes, em relevo com filete de ouro de 0,03 m dentro de um painel
  ogival de 0,5 x 1,1 m, a 1,5 m do chão.
- **Leão de pé** (só o miolo do selo): o mesmo vetor (2.3).
- O olho cortado da Irmandade não aparece aqui.

---

## 6. O selo e seus cinco estados

Ligação ao jogo: a câmara escuta o sinal `Boss.cue(nome, onde, direção, tamanho, segundos)` e o `Boss.moment(nome)`;
nada de estado novo no `boss.gd` além do que está pedido no fim desta seção. Camadas do desenho: **pedra** (relevo e ouro
fixos) e **luz** (uma camada de traços e runas emissivos sobre os anéis, que pode girar; a pedra nunca gira). Valores de
brilho = maior canal da emissão final (limite 1,0, seção 5.3).

| Estado | Liga em | Desliga em | Ouro (pedra) | Camada de luz | Cor da luz | Movimento | Rachadura | Duração |
|---|---|---|---|---|---|---|---|---|
| 1. Normal | início da sala; 1,2 s depois de `shield_break` | `phase_shift` com tamanho 2 | sem brilho (só luz da cena) | apagada | | parada | núcleo 0,75, pulso de ±0,15 a 0,33 Hz; mancha de corrupção de 0,6 m em volta (pedra 30% mais escura, tinta violeta) | fases 1, 2 depois do ritual, e 3 |
| 2. Preparo do ritual | `cue phase_shift` com tamanho igual a `BossDef.ritual_phase` (2) | `cue shield_up` | sem brilho | as 8 pontas acendem uma a uma no sentido horário a partir da que aponta para Morvath, a cada 0,12 s; anel externo sobe de 0 a 0,6 em 1,2 s; 16 runas na faixa entre os anéis de 0 a 0,3 | violeta (`Boss.VIOLET` x 0,6) no anel externo indo para o azul espectral no interno | anel externo de 0 a 8°/s, interno de 0 a -12°/s (o contrário) | de 0,75 a 1,0 | o rugido (`roar_time` 1,6 s) mais a caminhada ao meio (até 4 s) |
| 3. Ritual ativo | `cue shield_up` | `cue shield_break` | sem brilho | anéis 0,85; runas 0,6 em azul espectral; uma onda sai do miolo até as pontas a 0,7 Hz (amplitude 0,25); pedra dentro do escudo (r < 2,9) 20% mais escura | violeta e azul espectral | externo 12°/s, interno -18°/s | 1,0 (dentro do escudo) | até 20 s (`ritual_time`) ou até os mortos caírem |
| | (saída do 3) `cue shield_break` | | resíduo morno de 0,1 por 2 s | sobe a 1,0 por 0,15 s (violeta e ouro, sem branco) e apaga em 1,2 s | | os anéis param em 0,6 s (desaceleração) | volta a 0,75 e cresce para o comprimento da fase 2 | 1,2 s, depois estado 1 |
| 4. Transição final | `cue phase_shift` com tamanho igual a `BossDef.final_light_phase` (4); as chamadas `Arena.open_door` e `Arena.final_phase(true)` que o `_corrupt` já faz | vitória | o ouro "comido": albedo x 0,6 onde um veio passa | veios de corrupção correm pelas juntas das lajes da rachadura até r 7,5 a 4,7 m/s (1,6 s, o rugido); depois pulsam com a porta | núcleo dos veios esmeralda corrompido, borda violeta; máximo 0,8 no pico, 0,45 no vale | sem giro: tremor irregular de ±3° (ruído a 2 Hz); luz dos anéis piscando de 0,2 a 0,45 | comprimento da fase 4; núcleo 1,0 | 1,6 s de alastrar e depois a fase 4 inteira, pulsando a `Boss.PORTAL_PULSE_HZ` (0,35 Hz), junto com a costura da porta |
| 5. Vitória (selo restaurado; Morvath selado, não morto) | `cue victory_blow` | fica até a tela de fim | ver a linha do tempo abaixo | | ouro antigo `Boss.OLD_GOLD` | | | `Boss.VICTORY_TIME` 3,6 s |

**Linha do tempo da vitória** (segundos do jogo, as constantes de `boss.gd`):
- 0 a 0,5 (`victory_blow`, câmera lenta): o selo congela; veios param de pulsar; a rachadura sobe a 1,0 por 0,2 s e baixa.
- 0,5 a 2,3 (`VICTORY_STREAM`): **a corrupção recua**: os veios voltam de r 7,5 para a rachadura, no ritmo do fluxo;
  o fluxo de partículas (`Fx.chips`) vai de onde ele caiu para o centro do selo (ver o pedido 1 abaixo).
- 2,3 (`VICTORY_PORTAL`, `victory_absorb` no centro do selo): **a energia converge**: oito traços de luz correm pelos
  raios das pontas (r 5,0) até o centro em 0,5 s, em ouro antigo com máximo 0,86; os anéis dão uma última volta (40°/s
  caindo a 0 até 3,1).
- 2,8 (`VICTORY_RITUAL`, `ritual_broken`): **a rachadura fecha** das pontas para o coração do leão em 0,3 s; o
  contorno do leão acende em ouro antigo (máximo 1,0) por 0,4 s.
- 3,1 (`VICTORY_CALM`): **selo restaurado**: ouro com brilho fixo de 0,12, sem nenhum violeta no selo; onde era a
  rachadura fica uma cicatriz sem brilho (pedra x 0,7, sem cor).
- Ao mesmo tempo, na porta (`seal_portal`, de `VICTORY_CALM - VICTORY_SEAL` até `VICTORY_CALM`): a costura violeta
  fecha de baixo para cima e as ferragens de ouro ficam com brilho 0,3. O véu da entrada some em 0,8 s a partir de
  `victory_done`.
- "Selado, não morto": o corpo dele some no `victory_fade` como hoje; as últimas almas dele (`Fx.burst(&"soul")`)
  descem para o centro do selo em vez de subir. Nenhum texto novo (o "Morvath foi selado" já existe).

**Pedidos para o `gameplay-engineer`** (o resto é da câmara, dono `environment-artist`):
1. Na câmara, `Arena.door_pos` é o centro do selo (0; 0), para o fluxo e o `victory_absorb` irem para ele; a câmara
   implementa `open_door`, `final_phase` e `seal_portal` (mesma interface do salão) na porta e no selo.
2. O comprimento da rachadura por fase precisa da fase atual: o `phase_shift` já traz a fase no tamanho; o estado
   inicial é fase 1. Nada novo.
3. Opcional (P1, para a luta ler melhor): no ritual ativo, as 8 pontas apagam uma a uma ao longo do `ritual_time`
   (relógio do ritual), e todas juntas se ele terminar antes. Precisa de um `cue` com o progresso (por exemplo
   `ritual_tick`, tamanho = fração restante) ou de uma leitura pública do tempo do ritual.

---

## 7. A porta e o portal (D-14)

Na câmara não há portal nem véu verde. As chamadas que o chefe já faz ficam assim:
- `open_door(SPECTRAL)` (fase 4): a costura acende de 1,4 para pulsar entre 1,0 e 1,6 a 0,35 Hz, cor indo do violeta ao
  azul espectral; luz do pórtico de 1,5 para 2,5.
- `final_phase(true)`: o selo entra no estado 4.
- `seal_portal(segundos, de)`: a porta se fecha (6) e o selo vai ao estado 5.
- Fases 1 a 3: a porta fica no estado de repouso (costura 1,4, sem pulso). Nenhum vermelho na fachada além dos
  estandartes.

---

## 8. Avisos de Morvath com assinatura (ART-001)

Vale para todo aviso cuja origem (`Zone.source`) é Morvath: foice (arco), lâminas, investida, tempestade e maldição
(faixas) e erupções (círculo, que já tem runa). Os avisos dos outros inimigos não mudam. Dono do desenho:
`environment-artist` (`ground.gdshader`, `GroundLook`); passar a origem e o círculo do chão ao desenho:
`gameplay-engineer`.

- **Miolo**: o mesmo vermelho de perigo, preenchido com 0,35 (hoje 0,38 mais a frente de 0,6); a frente que avança é
  uma linha de 0,12 m com 0,6.
- **Aro**: o aro vermelho estreita de 0,28 para 0,18 m; por fora dele, um **fio violeta de 2 px** na tela (a 1080
  linhas; pelo `fwidth`, nunca abaixo de 1 px), cor `Boss.VIOLET` x 0,8.
- **Runas**: por fora do fio, uma faixa de 0,3 m de glifos espectrais (os do `rune_glyph.gdshaderinc`), azul
  espectral (0,32; 0,6; 1,0) x 0,5, correndo ao longo da borda a 0,4 m/s; nas faixas, nos dois lados compridos; no
  arco, só na curva. As erupções mantêm o círculo de runas do ciclo 9 e só ganham o miolo de 0,35.
- **Tempestade, ordem de saída**: cada faixa ganha, na raiz (1,2 m de Morvath), de 1 a 6 pontos espectrais em fila (a
  ordem dada por `BossRules.storm_order`), e o aro da próxima a sair fica mais forte: 100%, 70%, 55%, 45%, 38%, 32%;
  quando uma sai, as outras sobem um degrau. Opcional, a decidir com o Game Director porque muda a dificuldade: as faixas
  da segunda onda aparecem só em contorno (0,12) durante a primeira.
- **Recorte no círculo**: nenhum aviso pinta fora de r 12,5 (nem balaustrada nem abismo). O shader recebe o centro e o
  raio do chão e descarta o que passa; a ponta clara das faixas (a "ponta de longe") vai para onde a faixa é cortada. A
  investida (16 m) e as lâminas (26 m) terminam visualmente na borda. Recomendo que as meias-luas se desfaçam ao cruzar
  r 12,8 (a dissipação que já existe), em vez de voar 26 m sobre o abismo.
- **Critério**: nas capturas de `scythe_warn` + 0,5 s, `curse` + 0,3 s e `storm` + 0,5 s: (a) dentro do aviso as juntas
  das lajes continuam visíveis e a mediana tem R pelo menos 40 acima de B, luminância de 60 a 120; (b) o fio violeta
  aparece contínuo, de 1 a 3 px; (c) as runas se veem por fora, azuis, não vermelhas; (d) nenhum pixel de aviso além
  da balaustrada; (e) na tempestade, a faixa 1 tem o aro pelo menos 40% mais claro que a 6 e os pontos de 1 a 6 se
  contam; (f) mostrado a alguém sem ver Morvath, o aviso se reconhece como dele.

---

## 9. Evidências: `docs/gallery/boss_arena/`

Todas reais, na placa de vídeo, 1920 x 1080: `shot` = `RES=1920x1080 tools/gpu.sh shot <saída.png> --nosave --seed=5
--start=boss` seguido das opções. Sem dom de fogo (como no ciclo 9). Registrar o comando, o commit e o `time` do
`RESULT` de cada uma num `CAPTURAS.md`, como em `docs/gallery/cycle9/CAPTURAS.md`.

Opções novas que estas capturas pedem (dono `gameplay-engineer`, só para teste): `--no-boss` (a câmara sem Morvath),
`--hero-at=x,z` (herói posto num ponto), `--bot-kite` (QW-004 do C10).

| Arquivo | Opções | Enquadramento e o que tem de aparecer |
|---|---|---|
| `01_arena_vazia.jpg` | `--no-boss --shot-at=2` | câmera do jogo; câmara inteira, herói na boca da escadaria, selo no estado 1, as quatro lanternas, a porta com a costura, a torre e as correntes; mais `01b_vitrine_referencia.png` com `--showcase --cam-dist=51 --cam-pitch=27` (só para a comparação local) |
| `02_explorador_morvath.jpg` | `--shot-at=1` | a composição da pintura: herói na boca (embaixo à esquerda), Morvath sobre o selo, porta no alto à direita |
| `03_foice.jpg` | `--bot --boss-only=scythe --shot-at=3 --shot-on=boss:scythe_warn --shot-after=0.5` | aviso em arco com a assinatura (miolo 0,35, fio violeta, runas); `03b` com `scythe_strike` + 0,08 |
| `04_investida.jpg` | `--bot-kite --boss-only=dash --shot-at=2 --shot-on=boss:dash --shot-after=0.6` | faixa da investida recortada na borda; `04b` com + 1,05 (ele no meio da investida) |
| `05_ritual.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=1.2` | selo no estado 3 sob o escudo, anéis girando, runas acesas; `05a` com `boss:phase` + 1,0 (estado 2, preparo) |
| `06_invocacao.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=3.0` | runas de invocação dentro do círculo, mortos de pé no anel de 6,5 m, nenhum fora do chão |
| `07_erupcoes.jpg` | `--bot --boss-hp=0.5 --boss-only=eruptions --shot-at=2 --shot-on=boss:eruptions --shot-after=0.6` | círculos de runa com miolo 0,35; `07b` com + 1,0 (colunas) |
| `08_maldicao.jpg` | `--boss-hp=0.3 --boss-only=curse --shot-at=2 --shot-on=boss:curse --shot-after=0.3` (sem robô) | faixas da maldição com assinatura; `08b` com `boss:cursed` + 1,2 (herói amaldiçoado) |
| `09_tempestade.jpg` | `--bot --boss-hp=0.14 --boss-only=storm --shot-at=2 --shot-on=boss:storm --shot-after=0.5` | seis faixas com os pontos de ordem e o aro em degraus, recortadas na borda, selo no estado 4, porta pulsando; `09b` com `boss:storm_fire` + 0,25 |
| `10_vitoria_selagem.jpg` | `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:victory --shot-after=3.3` | selo restaurado (ouro, sem violeta, cicatriz), porta fechada; `10a` + 1,2 (corrupção recuando), `10b` + 2,5 (energia convergindo pelos raios) |

Extras obrigatórios:
- `selo_estados.jpg`: montagem dos cinco estados (recortes de 700 x 400 em volta do selo, tirados de `01`, `05a`, `05`,
  `09` e `10`), com rótulo em cima de cada quadro.
- `borda_e_camera.jpg`: quatro quadros com `--no-boss` e `--hero-at=0,12`, `--hero-at=12,0`, `--hero-at=0,-12` e
  `--hero-at=8.5,8.5` (os quatro extremos), e um quinto com `--hero-at=9.7,5.7`, 2 m atrás do pilarete de 125° visto da
  câmera (o pontilhado aberto, herói perto de (1220, 805) na tela). Mostra os 18% e a transparência.
- Antes e depois (mesmo comando, mesma semente; antes = o último commit antes do C11): `before_after_arena.jpg`
  (`02` contra o `01_morvath_fase1` do salão), `before_after_foice.jpg`, `before_after_ritual.jpg`,
  `before_after_tempestade.jpg`, `before_after_vitoria.jpg`. Quadros inteiros, rótulo acima, como no ciclo 9.
- Vídeo: a luta inteira sem cortes (`morvath_camara_luta.mp4`), com o mesmo kit e a mesma semente do vídeo do ciclo 9
  (`--bot --bot-reaction=0.25 --seed=1 --boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno`),
  para comparar com `docs/gallery/cycle9/morvath_full_fight.mp4`. Se a gravação sair em 1280 x 720 como no ciclo 9,
  dizer no `CAPTURAS.md`.
- Comparação com a pintura (`01b` ao lado da referência): só local, em `C:\Users\danie\ASelagem-teste\`.

---

## 10. Critérios de aprovação

Composição e planta
1. O chão andável é um círculo de raio entre 11 e 13 (12 pedido), número em dado; nenhuma colisão de cenário além dele.
2. Na captura `02`, cada marco da tabela da seção 4 cai a até 40 px da posição "Jogo" (fachada, estandartes e o par de
   sarcófagos leste: até 80 px).
3. Porta no terço de cima à direita, escadaria embaixo à esquerda, selo no meio, os dois pares de sarcófagos nas
   laterais com uma lanterna de cada lado, quatro pilaretes, dois braseiros só na fachada.
4. Nenhuma cruz em nenhuma peça; leão no selo e nos sarcófagos; espada erguida nos pilaretes, estandartes e fecho do
   arco, lendo como espada.

Selo
5. Os cinco estados aparecem nas capturas (`selo_estados.jpg`) e se distinguem em miniatura (recorte a 350 x 200).
6. O leão lê como leão em `01` (juba, patas e cauda reconhecíveis sem ampliar); a rachadura atravessa o leão de cima a
   baixo e cresce de fase para fase.
7. Em nenhuma captura um pixel do selo, dos veios ou da rachadura dentro de r 12,5 passa do limiar do glow (sem halo
   em volta do traço quando o herói está em cima).
8. Vitória (`10`): nenhum violeta no selo nem na costura da porta; ouro antigo, sem amarelo saturado (nenhum pixel do
   selo com R > 200 e B < 60).

Leitura do combate
9. Herói, Morvath e avisos sempre dentro do quadro; o peito do herói nunca a menos de 18% de uma borda (conferido em
   `borda_e_camera.jpg` e no vídeo).
10. Atrás do pilarete de 125° e da balaustrada da frente, o herói e o anel dele aparecem pelo pontilhado; Morvath
    também.
11. Avisos de Morvath: os seis itens (a) a (f) da seção 8.
12. Nenhum clarão branco da câmara (selo, porta, véu) em nenhum quadro do vídeo.

Cor e luz (medidas na captura `01`, como em `arena_reference.md`, "Como medir")
13. Chão do meio: mediana com luminância de 45 a 60 e B - R de 25 a 45.
14. Abismo nas laterais (x < 12% e x > 88%, y 50% a 90%): violeta (B pelo menos 50 acima de R, R pelo menos 20 acima de
    G); topo do quadro entre as correntes: azul (B pelo menos 50 acima de R, G pelo menos 20 acima de R).
15. Quente estourado (luminância > 170 e R > G > B) só nas chamas, entre 0,2% e 1% da tela.
16. Esmeralda corrompido e Emeth na mesma captura (`09` ou o vídeo) se distinguem sem ler a forma.

Desempenho e navegador
17. Quadro a 1080p na placa de vídeo: p90 até 6,5 ms nas três cenas do aceite do C11 (fase 1, ritual, fase 4).
18. `DRIVER=opengl3`: a câmara aparece inteira, sem peça faltando, p50 a até 10% do desktop.

---

## 11. Quem faz o quê

| Trabalho | Dono | Arquivos (sugestão) |
|---|---|---|
| A câmara como cena própria e reaproveitável (`BossChamber`), chão, perímetro, fachada, porta, escadaria, abismo, luz | `environment-artist` | `scripts/game/boss_chamber.gd` (novo), `masonry.gd`, `arena_kit.gd`, `catacomb_floor.gdshader` (parâmetros), `game.gd` `_build_world` (só luz e ambiente, combinar com o Game Director) |
| Selo e estados | `environment-artist` | `assets/shaders/seal.gdshader` (novo), `assets/textures/seal/lion.svg` e o campo de distância |
| Espada erguida nos estandartes | `environment-artist` | `ArenaKit.banner` (aceitar um desenho) |
| Pontilhado do arco da frente e em volta de Morvath | `environment-artist` (shader) e `gameplay-engineer` (o global do chefe) | `masonry.gdshader` |
| Avisos com assinatura e recortados | `environment-artist` (desenho) e `gameplay-engineer` (origem e círculo) | `ground.gdshader`, `ground_look.gd`, `ground.gd` |
| Forma do chão, colisão, nascimento, invocações, câmera, `door_pos` da câmara, opções de teste | `gameplay-engineer` | `core/` (forma do chão), `arena.gd` (`resolve`), `game.gd` (`cam_look_at`), `boss.gd`, `tools/make_data.gd` (`_stage`) |
| Capturas, vídeo, medidas, `CAPTURAS.md` | `qa-performance` | `docs/gallery/boss_arena/` |
| Revisão contra esta especificação | `art-director` | `docs/art/visual_review.md` |

---

## 12. Pendências e perguntas ao Daniel (pelo Game Director)

1. **Postura do leão**: "leão de pé" ficou como em pé nas patas de trás (a postura de brasão). Se for em pé nas quatro
   patas, troca-se o vetor.
2. **Leão nos sarcófagos**: o cânone diz que cada selo tem um paladino do leão e quatro guardiões enterrados com a
   espada erguida. Quatro sarcófagos com o leão podem sugerir quatro paladinos do leão aqui. Nada foi dito sobre quem
   está neles; se o Daniel preferir, a espada erguida vai para os sarcófagos (seriam os quatro guardiões) e o leão fica
   só no selo.
3. **Estátuas**: na pintura uma parece segurar algo junto ao peito. Ficaram de mãos juntas e vazias, como no salão.
4. **A porta**: o que ela é (e para onde dá) não está no cânone. Ela só repete o desenho do selo e se fecha com ele na
   vitória; nenhum texto fala dela.
5. **Véu da entrada**: sinal visual de que a luta fecha a saída; pode sair se o Daniel não quiser.
6. **Ordem da tempestade com a segunda onda em contorno**: ajuda a leitura, mas facilita a fase 4; decisão de jogo.
7. Peças que só aproximam a pintura sem modelo novo (D-05): estátuas e cantaria esculpida são procedurais; o leão é
   relevo raso desenhado num vetor. Provisórias no sentido de que um modelo esculpido ficaria melhor; nada disso depende
   do Meshy para o C11.
