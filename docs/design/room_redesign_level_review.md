# Redesenho das salas: leitura de level design (room-designer, 2026-11-18)

Estudo do pacote do PO (`docs/art/po_directive_room_redesign_2026-11-18.md`, 18 conceitos, 2 pranchas, referências de
Sworn) contra as plantas reais (`_stage` do `tools/make_data.gd`), as capturas de hoje (`docs/gallery/rooms_2026-11-18/`)
e medições feitas para este estudo. Nada de código nem de dado mudou. A matriz de arte e a especificação do Lote A são
do art-director (`docs/art/room_redesign_matrix.md`); este documento só cobre o que cada sala pede do jogador.

Observação: o `docs/design/rooms_progression.md` (plano de progressão, meu) ainda não existe. As seções 0 e 5 daqui
são a base dele; ele nasce na primeira tarefa que mexer nas plantas.

## 0. Medidas de partida

### 0.1 O que a câmera do jogo vê (e o conceito não)

- Câmera do jogo: distância 54 m, campo de visão 24°, inclinação 30, girada 35° (a sala vira losango). A 16:9 isso dá
  cerca de 23 x 41 m de vista; **o chão ocupa de 65 a 75% da tela** (ver as capturas `atual/`). Paredes e fundo só
  aparecem numa faixa no alto da tela (norte e oeste) e nas bordas do abismo.
- Os conceitos estão em vista baixa e cinematográfica, numa tira de 548 x 146 px (3,75:1). São recortes da prancha
  principal, em resolução baixa, e alguns foram cortados fora do quadro (04 a 09 trazem uma faixa da vista vizinha no
  alto). Servem como clima e paleta, nunca para medir.
- Consequência para o redesenho: **a identidade de cada sala tem de morar no chão, nas bordas e na faixa do norte**. A
  riqueza de parede que os conceitos mostram aparece pouco no jogo. Peças altas na frente da câmera (o primeiro plano
  de baixo dos conceitos 01, 02, 04, 08, 12, 13 e 14) no jogo ficariam entre a câmera e a luta; hoje a frente é
  cortada baixa (Cripta 0,9 m) ou abre em pontilhado (`see_through`).
- Sworn (referências) confirma isso: na câmera de jogo dele o chão é escuro e calmo, de pouco contraste, com placas
  grandes; as cores vivas ficam para avisos vermelhos, recompensa e golpes; a riqueza fica nas bordas (água, muro,
  vegetação). É a lição mais útil do pacote: **fundo rico, chão quieto**.

### 0.2 Tamanho, densidade e estado do desenho (fit_probe)

Área andável calculada dos polígonos do `_stage`; `fit_probe` rodado em todas as plantas e variantes
(`tools/fit_probe.gd -- --arena=id --variant=n`).

| Sala | Andável (m²) | De pé | m² por inimigo | Câmera | Fantasma | Peça sem desenho | Borda falsa |
|---|---|---|---|---|---|---|---|
| Salão (abertura, fonte, loja) | cerca de 900 (32 x 30 menos a parede) | 4 a 8 | 110 a 225 | segue | 3,0 | 0 | 39,1 (patamar e escadas) |
| Cripta A / B | 498 | 4 a 6 | 83 a 125 | fixa (alcance 2,5) | 0,3 / 0,3 | 0,04 | 0 |
| Fendas A / B | cerca de 1060 | 6 a 8 | 132 a 177 | segue | 1,5 / 1,5 | 0 | 5,1 / 5,0 |
| Jardim A / B | 875 (tronco fora) | 6 a 8 | 109 a 146 | segue | 2,0 / 2,0 | 1,6 / 1,6 | 2,7 |
| Santuário A / B | 1192 / cerca de 1130 | 6 a 8 + guardião | 149 a 199 | segue | 1,2 / 1,2 | 0,2 / 0 | 9,2 / 9,5 |
| Ponte A / B | 771 / 701 | 6 a 8 | 88 a 128 | segue (faixa de 28 x 2) | 4,1 / 2,8 | 0 | 11,1 |
| Runas A / B | 702 | 4 a 6 | 117 a 175 | fixa (3,5) | 2,6 / 2,6 | 0 | 0,5 |
| Provação | 220 | sem luta | | fixa (1,5) | 1,1 | 0 | 0 |
| Altar | 252 | sem luta | | fixa (1,5) | 3,4 | 0 | 0 |
| Câmara do Selo | 491 (círculo de 12,5 m) | Morvath + até 6 | | fixa (3,0) | | | |

Leitura: a sala mais apertada é a Cripta (83 m² por inimigo no teto) e as plataformas da Ponte (cada uma de 216 a 243 m²);
as mais folgadas são Santuário e Fendas. O fantasma restante das câmaras e da Ponte B vem da alvenaria (`masonry`) das
bordas, não de peça no meio. O redesenho não pode subir nenhum desses números: **fantasma e peça sem desenho são o teste
de aceite de toda sala nova** (meta: não piorar, e Jardim e Ponte A abaixo de 2 m²).

### 0.3 Quantas vezes cada sala aparece numa descida

500 grafos (`RunMap`, o mesmo do jogo) com um caminho ao acaso em cada um (script de sondagem no scratchpad, nada no
repositório):

| Sala | Vezes por descida | Em quantas descidas | Profundidades |
|---|---|---|---|
| Salão | **2,5** (abertura 1, loja 1, fonte 0,5) | 100% | 1, 5 a 8 (fonte), 10 |
| Santuário | **1,57** (guardião 1, luta 0,57) | 100% | 4 a 9 |
| Câmara do Selo | 1 | 100% | 11 |
| Fendas / Jardim / Cripta | 1,2 cada | 84 a 85% | 2 a 4 no mais, até 9 |
| Ponte / Runas | 1,08 / 1,0 | 78% | 5 a 9 |
| Altar | 0,25 | 25% | 2 a 7 |
| Provação | menos de 0,2 (laje em 20% das salas vencidas, uma por descida) | | 2 a 7 |

Duas consequências de jogo: o Salão é de longe a sala mais vista e hoje é o mesmo lugar para abertura, fonte e loja; e
as salas "fáceis" (Cripta, Fendas, Jardim) concentram-se no começo, as "difíceis" (Ponte, Runas, Santuário) do meio
para o fim. O redesenho deve reforçar essa curva, não apagá-la.

### 0.4 Cores que o jogo já reservou

Antes de dar cor a um bioma, estas já têm dono e precisam continuar únicas na tela:

| Cor | Dono no jogo | Risco no pacote |
|---|---|---|
| Vermelho saturado | avisos dos inimigos (`ground`), fio da mira, investidas | estandartes vermelhos (14, 16), folhagem vermelha (06, 07) |
| Âmbar | ladrilho aceso das Runas (`HAZARD_COLOR`), fogo | braseiros sobre o chão das Runas; o âmbar não pode virar enfeite de chão nas Runas |
| Esmeralda quente | a Emeth, o especial, o herói | braseiros verdes (03, 04), obeliscos (12, 13), figura do Altar (15), fonte turquesa (17), cascatas (06, 07) |
| Verde espectral frio (matiz 165) e violeta | Morvath, tiros do feiticeiro e dos sacerdotes, meias-luas das almas | abismo violeta das Fendas (04, 05) e da Câmara (18), vórtice (05) |
| Ouro velho em círculo no chão | medalhão do salão, selo da Câmara, círculo de luz do herói (aro fino), runas de invocação e erupções de Morvath (círculos) | círculo dourado no chão em **10 dos 18 conceitos** (01, 04, 05, 08, 09, 12, 13, 14, 16, 18) |

## 1. Sala por sala

Formato de cada sala: o que aprender, o que cabe na forma real sem mudar o combate, o que não cabe, riscos de jogo.

### 01 Salão das Catacumbas (abertura; mesma sala que 16 e 17)

- Real: 32 x 30 m sobre o abismo, altar com escada e portal ao norte, patamar de entrada a sudoeste, portas a leste e
  ao sul, medalhão no chão, câmera que segue. Construído da imagem de referência do Daniel (CLAUDE.md, Direção de arte).
- Aprender: o conceito é praticamente a sala de hoje vista de baixo. Bom de levar: a **porta verde como marco no fim de
  um eixo** (o portal lido de longe), as estátuas em nichos emoldurando o eixo, e luz quente em dois grupos simétricos
  que apontam o centro. Isso já existe; o ganho é de acabamento (a diretriz pede o portal "não neon": AP-1 já deu
  profundidade).
- Cabe: mais variação de altura aparente na borda do abismo (balaustrada quebrada em trechos, como a borda das Fendas)
  sem mexer na colisão; o centro já é limpo.
- Não cabe: o conceito fecha o salão com paredes e nichos dos dois lados; o real é aberto sobre o abismo a oeste e ao
  sul. Fechar mudaria a leitura de "sala sobre o abismo" que é a identidade da imagem de referência aprovada.
- Riscos: a vela em forma de cruz no canto esquerdo do conceito fere a regra "nunca sol nem cruz". A borda falsa de
  39 m² do salão (patamar e escadas que parecem chão e são abismo, `ledge` do `fit_probe`) é o maior número do jogo:
  não é bug de jogo (ninguém cai, `Arena.sweep`), mas o redesenho não deve aumentá-la com mais degraus decorativos.

### 02 Cripta dos Esquecidos A

- Real: 24 x 21 m, fechada (paredes de 6,5 m ao norte e oeste, frente cortada a 0,9 m), câmera fixa. Cobertura é o
  jogo: sarcófago de 4 x 2 m no meio, três colunas, dois sarcófagos pequenos, muretas de 0,9 m saindo das paredes leste e
  oeste. Corredores de 4 m entre o sarcófago do meio e as fileiras. Sala mais apertada do jogo (83 a 125 m² por inimigo).
- Aprender: nichos com velas agrupadas, frio azul com bolsões quentes, sarcófagos com efígie. Os nichos dão ritmo à
  parede norte, que é exatamente a faixa que a câmera vê; as velas agrupadas marcam a **porta e os cantos**, não o meio.
- Cabe: efígie e tampa trabalhada nos sarcófagos que já existem (mesma caixa), urnas e velas só fora do chão andável ou
  encostadas à parede (o `fit_probe` não pode subir de 0,3 m²), névoa fria baixa só fora do chão.
- Não cabe: a diretriz diz "sarcófagos apenas nas margens"; **na Cripta o sarcófago do meio é a cobertura que faz a sala
  jogar diferente** (atiradores, máximo 2, contornados por ele). Tirar do meio mata a ideia da sala. Ver pergunta P-3.
- Riscos: o conceito põe sarcófagos novos na diagonal no meio da sala; qualquer peça nova acima de 0,3 m no chão livre
  é barreira falsa ou rota cortada. Velas no chão perto dos corredores de 4 m ficariam a menos de 1 m da rota.

### 03 Cripta dos Esquecidos B ("Ossuário")

- Real: a mesma caixa com um muro divisor de 7 m saindo da parede norte no meio (0,8 m de largura, 3,2 m de altura, em
  pontilhado), metade sul aberta. A pergunta da sala é "de que lado do muro".
- Aprender: a figura velada monumental como marco, verticalidade, vazio central.
- Cabe muito bem: **a figura velada na ponta do muro divisor** (é onde a câmera olha e o muro já é peça alta); urnas no
  pé do muro, dentro da caixa de colisão dele. O "vazio central" do conceito já existe na metade sul.
- Não cabe: os braseiros verdes. Verde vivo ao nível do chão compete com a Emeth e com o verde frio de Morvath.
  Pequenas escadas no meio da sala (o conceito tem degraus que levam a estrados): degrau no chão andável lê como
  desnível que não existe. Só como relevo pintado, sem altura.
- Riscos: a diretriz pede diferenciar a B "pela monumentalidade e pelo vazio central"; o que já a diferencia é o muro.
  Manter o muro como protagonista.

### 04 Salão das Fendas A

- Real: 42 x 30 m, uma fenda que corta 83% da profundidade, duas pontes de 5 m, passagem de 5 m ao sul, um buraco a
  leste, todas as portas na plataforma leste; câmera segue. Borda falsa 5,1 m², fantasma 1,5 m².
- Aprender: as **bordas quebradas com pedra escura abaixo** dizem "não dá para andar" sem aviso: é o que a sala já faz
  (`broken_lip`, `LIP_SINK`). Correntes e arcos fraturados ao fundo dão altura aparente.
- Cabe: correntes e arcos só do lado de fora (norte, onde a fenda sai para o abismo), pilares quebrados nas cabeceiras
  das pontes fora do chão, balaustrada em trechos.
- Não cabe: o conceito não mostra a fenda; mostra um pátio redondo com o círculo de ouro no meio. A forma real (o corte
  de norte a sul com duas pontes) é a ideia de jogo da sala (decidir em que ponte cruzar, usar a passagem sul).
- Riscos: **violeta saturado vindo de baixo do chão em toda a borda**: os orbes do feiticeiro, as trepadeiras do sacerdote
  e os tiros dos atiradores são violeta e voam exatamente sobre a fenda. A regra do C18 (abaixo de 0,45 de saturação)
  precisa valer aqui com folga. Braseiros verdes sobre as cabeceiras: mesma objeção do 03.

### 05 Salão das Fendas B (ponte de cima caída)

- Real: a ponte norte caiu (uma só passagem pelo meio), um buraco novo a oeste, segunda onda nasce no noroeste.
- Aprender: fragmentos suspensos e um arco partido dão profundidade ao fundo.
- Não cabe: o conceito é outra sala: chão redondo amplo, vórtice gigante ao fundo, nenhuma fenda. Adotar o vórtice como
  ponto focal tira o peso do portal do salão e da Câmara do Selo (o "portal cósmico" já é a imagem do clímax).
- Riscos: vórtice violeta brilhante no alto da tela cobre a faixa onde os inimigos do norte ficam (as zonas de
  nascimento do norte estão a 1 a 3 m da borda) e onde os orbes chegam. **Recomendo repensar esta vista** (P-6): o
  marco da B deveria ser a **ponte caída** (tocos, pedaços pendurados, que já existem), não um vórtice.

### 06 Jardim das Raízes Mortas A

- Real: 34 x 28 m, a árvore de pedra fora do meio (tronco de 3,5 m de raio em (-8; -5), barra corpo e tiro), quatro
  raízes baixas (0,6 m, só corpo) saindo dela, uma delas até (0,3; 1,2), perto do centro. Árvore aprovada (D-30).
  Fantasma 2,0 m², peça sem desenho 1,6 m² (as raízes).
- Aprender: a árvore como marco gigante é exatamente o que já temos. Bom de levar: **o contraste orgânico na borda**
  (vegetação engolindo ruínas nas paredes norte e oeste) e a água como fundo.
- Cabe: cascata e água atrás das paredes, nas janelas cegas ou além do corte do noroeste (fora do chão); musgo e fungos
  no pé das paredes (já há `_moss`); folhagem só acima de 2,6 m (a copa, que já abre em volta do herói).
- Não cabe: a água turquesa dentro do chão (vira buraco ou zona que não existe); flores e moitas no chão livre (barreira
  falsa); a árvore viva e frondosa: o nome é **Raízes Mortas** e a árvore aprovada é de pedra. Ver P-7.
- Riscos: folhas vermelhas saturadas na borda do chão disfarçam o vermelho dos avisos que chegam à borda (os inimigos
  do Jardim nascem junto das paredes). Turquesa e verde brilhantes de fungos no chão competem com a Emeth. As raízes já
  são o ponto fraco do encaixe (1,6 m² sem desenho); mais raízes decorativas pioram isso.

### 07 Jardim das Raízes Mortas B

- Real: a mesma árvore, raízes mais curtas e para o sul, peças trocadas de lugar. O centro de luta já é o leste, mais
  amplo (a diretriz pede "centro mais amplo e seco": já é assim).
- Aprender: cascatas e lago como **borda que lê como "não dá"** (água é a borda mais legível que existe, melhor que
  abismo, se ficar fora do chão).
- Cabe: lago e cascata do lado de fora da borda oeste (hoje parede): trocaria parede por borda baixa com água,
  sem mudar o polígono do chão. É a única mudança de forma aparente que recomendo nos Jardins, porque dá ao Jardim uma
  borda própria (Cripta e Runas são paredes, Fendas e Ponte são abismo).
- Não cabe: o chão redondo de pedra no meio do lago (a sala é retangular); o lago dentro do chão.
- Riscos: "evitar excesso de brilho verde" (diretriz): a cascata turquesa luminosa ao lado do herói é exatamente esse
  excesso. Brilho só na espuma e baixo (abaixo do glow).

### 08 Santuário Desmoronado A (casa do guardião)

- Real: a maior sala (44 x 28 m, 1192 m²), nave de 10,7 m entre duas fileiras de colunas a cada 6 m (vãos de 4,7 m),
  naves laterais atrás delas; o guardião nasce diante da grade a oeste (-17; 0), o herói entra a leste (19,5; 2). A
  pergunta da sala é "nave aberta ou naves laterais" (`areas`). É a 2ª sala mais vista (1,57 por descida).
- Aprender: grandeza perdida, fachos de luz dourada (já há `moon_shaft`), escadaria cerimonial ao fundo, estátuas
  encapuzadas. A escadaria ao fundo é o **marco que diz onde o guardião está**: casa com o presbitério que já existe
  atrás da grade.
- Cabe: estátuas e estandartes entre as colunas só do lado de fora das naves laterais (contra as paredes norte e oeste);
  entulho dentro das caixas das colunas quebradas; facho de luz caindo sobre o `boss_spawn` para a área do guardião
  ficar legível (pedido da diretriz) sem mexer em nada.
- Não cabe: o conceito tira as colunas do meio e põe um círculo dourado no chão; as colunas são a cobertura e a
  pergunta da sala.
- Riscos: fachos de luz forte sobre a nave clareiam o chão onde os avisos vermelhos caem; o contraste aviso/chão tem de
  ser medido com o facho (o art-director já mede luma do chão). Velas no pé das colunas: a coluna tem 0,65 m de raio e o
  vão 4,7 m; vela no chão da nave a menos de 0,6 m do contorno é barreira falsa.

### 09 Santuário Desmoronado B ("nave partida")

- Real: o chão da nave caiu entre x 0,6 e 9,4 (um buraco de cerca de 9 x 7 m no meio da nave), duas colunas foram junto.
  A ideia de jogo da B é esse buraco no meio do caminho entre o herói e o guardião.
- Aprender: abertura para fora, céu, arcos partidos: contraste com o interior da A.
- Não cabe: o pôr do sol (a descida é subterrânea; a diretriz já desconfia). E o conceito **não tem o buraco**: mostra
  uma plataforma circular inteira. Adotar o conceito apaga a B.
- Proposta: a abertura vira a **abóbada caída** (o teto que desabou e levou o chão junto), luz fria de cima entrando
  pelo rasgo e caindo no buraco, com a cripta de baixo visível (`UNDER` já existe). Assim o marco (o rasgo de luz) e a
  regra de jogo (o buraco) são a mesma coisa.

### 10 Ponte dos Condenados A

- Real: 56 x 18 m, três plataformas (216 a 243 m² cada) ligadas por duas pontes de 5 x 7 m, portas só na plataforma
  leste, ninguém nasce numa ponte, atiradores do outro lado; a ruína do meio (pilone e bloco) é a cobertura contra eles.
  Pergunta: "segurar a ilha ou atravessar". Fantasma 4,1 m² (o maior das arenas de luta; vem do pilone e das bordas).
- Aprender: a composição longitudinal guia o olho para a saída; **marcos nas cabeceiras** (pilares, braseiros) dizem
  onde a ponte começa; arcos de sustentação embaixo dão a altura que a câmera de cima não mostra.
- Cabe: pilares com braseiro nas cabeceiras, **fora do tabuleiro de 5 m**; arcos e correntes embaixo e ao lado; cascata
  ao fundo (norte) como na B.
- Não cabe: o conceito é uma ponte longa sem plataformas; os braseiros e correntes no tabuleiro (no conceito ficam nos
  dois cantos do primeiro plano, sobre o caminho). Num tabuleiro de 5 m, um pilar de 1 m de cada lado deixa 3 m: a
  esquiva atravessa, mas o bote do esqueleto e a investida do Escudo ficam sem saída lateral.
- Riscos: o fundo azul-ciano luminoso no alto da tela é onde ficam os atiradores da plataforma leste. Silhueta escura
  sobre fundo claro é boa (lê bem); só não pode ser ciano saturado perto do verde da Emeth.

### 11 Ponte dos Condenados B (ponte longa com patamar)

- Real: duas plataformas e uma ponte de 24 x 5 m com patamar de 6 x 9 m no meio.
- Aprender: passarelas e pilares ao fundo, lanternas suspensas: ritmo, profundidade.
- Cabe: passarelas e ponte desabada **só no fundo**, fora do chão, como paisagem; lanternas suspensas acima de 2,6 m
  (fora da faixa de barreira) e sem luz forte no tabuleiro.
- Não cabe: "ponte parcialmente desabada" lida como parte jogável. A diretriz já diz "sem buracos jogáveis novos"; o
  risco é o desenho: tabuleiro quebrado na borda lê como "dá para cair" ou "dá para andar" onde não dá. Ponte B tem
  hoje o fantasma de 2,8 m² vindo da alvenaria do patamar: corrigir antes de enfeitar.

### 12 Câmara das Runas Instáveis A

- Real: 30 x 24 m, câmera fixa, o chão é uma grade de 10 x 8 lajes de 3 m que acendem em faixas (o perigo da sala),
  quatro pilares de runas nos nós da grade, 4 a 6 inimigos. Regra de desenho já decidida: nada redondo (D-29).
- Aprender: os **obeliscos com glifos como marco** e o mecanismo dourado ao fundo como peça narrativa ("esta sala é uma
  máquina"). Os pilares do jogo podem ser esses obeliscos.
- Cabe: glifos nos pilares que **esquentam junto com as lajes** (já há os sulcos que esquentam, `GROOVE_HEAT`): o
  conceito dá a ideia de o pilar ser o anúncio vertical do perigo, visível mesmo com inimigos em cima da laje.
- Não cabe: o círculo dourado e os glifos verdes acesos no chão. O chão das Runas é o aviso de perigo; **qualquer marca
  luminosa no chão que não seja o estado real da laje é um falso aviso**. Círculo contradiz D-29 e a grade de 3 m.
- Riscos: verde nos glifos (Emeth) e âmbar nos braseiros sobre o chão (âmbar é a cor do ladrilho aceso). Nas Runas o
  fogo decorativo tem de ser frio ou ficar fora da vista do chão.

### 13 Câmara das Runas Instáveis B

- Real: a mesma câmara com dois pilares e a **pedra quieta** no meio (6 x 6 m que nunca acendem, não barra nada).
- Aprender: um objeto central que explica a sala (o cristal).
- Cabe: o cristal **embutido na pedra quieta**, rente ao chão, como a razão pela qual ela nunca acende (lore a validar).
  Ou o cristal grande fora do chão, ao norte, atrás da borda.
- Não cabe: cristal alto no meio. Se barrar, a pedra quieta (a ilha segura) vira obstáculo e a B perde a ideia; se não
  barrar, um cristal de 4 m no meio da câmera fixa esconde inimigos e lê como parede (fantasma).
- Riscos: ciano-esmeralda brilhante no meio do quadro, o lugar mais disputado da sala, onde os avisos vermelhos e as
  lajes âmbar mais caem.

### 14 Câmara da Provação

- Real: 16 x 14 m, sem luta, a estela rachada no meio (1,2 m), as cartas tiradas diante dela, as portas da sala anterior.
  Identidade aprovada: lilás frio da maldição (veias, selo do HUD, `TrialSeal`).
- Aprender: "comunica desafio antes de qualquer texto": arena ritual, simetria, um centro.
- Não cabe: a paleta vermelha e de fogo do conceito (o vermelho é dos avisos; a Provação é lilás no jogo todo, no HUD, na
  carta e na laje) e os pedestais de fogo dentro do chão de 16 x 14 m, que cercariam o ponto de escolha.
- Riscos: o conceito parece uma sala de luta; o jogador espera inimigos e não vêm. Ver P-8.

### 15 Altar Esquecido

- Real: 18 x 14 m, capela, o altar na parede norte, dois bancos (um quebrado), as trocas diante do degrau; o leão em
  relevo na frente do altar.
- Aprender: recolhimento, velas, estandartes desbotados: bate com o que já existe (velas que se acendem na troca).
- Não cabe: a figura alada com auréola raiada e o brilho verde no colo. A auréola raiada lê como sol e cruz (regra
  "nunca sol nem cruz"), asas e auréola são lore que não está no cânone que conhecemos (Yah é Deus, Elun é Jesus, não
  existem outros deuses; anjo não aparece em nada aprovado), e o verde é da Emeth. Ver P-9.
- Riscos: nenhum de jogo (sala sem luta); só os de lore e de símbolo.

### 16 Loja (hoje: o Salão na sala 10)

- Real: a loja **é o Salão**: 5 placas numa fileira reta na tela (`SHOP_STEP` 5 m, deslocada `SHOP_SHIFT` 3,5 m para o
  lado da entrada), pisar compra. Nada de balcão.
- Aprender: tenda, panos vermelhos, prateleiras, a área de compra óbvia.
- Cabe: uma tenda e prateleiras **atrás da fileira** (do lado norte, longe da câmera), panos e lanternas acima de 2,6 m,
  tapete como relevo no chão sob a fileira (marca "aqui se compra" sem altura).
- Não cabe: balcão e caixotes na frente da fileira (cortam o caminho entre as placas) ou dentro dos 5 m entre placas.
- Riscos: pano vermelho saturado ao lado das placas: o preço sem ouro já é rosa apagado e "faltam N" precisa contrastar.

### 17 Fonte (hoje: o Salão entre as salas 5 e 8)

- Real: a fonte é uma bacia pequena (`ArenaKit.fountain`) posta **num lugar sorteado** a 13 m do herói
  (`Game._spawn_fountain`). Nada de pátio.
- Aprender: o pátio com uma fonte monumental reconhecível em 1 segundo (pedido da diretriz).
- Não cabe hoje: um marco reconhecível em 1 segundo não pode mudar de lugar a cada visita. Para o conceito valer, a
  fonte precisa de lugar fixo (mudança de jogo pequena, mas de jogo). E bica de leão: o leão é o símbolo do herói
  (D-64 a D-71); boca de leão jorrando água é lore nova (P-10).
- Riscos: água turquesa luminosa é a mesma família da Emeth; o brilho tem de ficar abaixo do glow.

### 18 Câmara do Selo (Morvath)

- Real: círculo de 12,5 m sobre o abismo, selo com o leão no chão, câmera fixa; nada pode ficar dentro do círculo
  (`test_chamber_look.gd` testa por vértice). Muito trabalhada (C11, C12a, ciclos 9 e 10, STY-10).
- Aprender: arcos destruídos e correntes emoldurando, o selo como centro.
- Não cabe: os braseiros sobre o anel do chão (o conceito tem quatro dentro da borda). E o **sol negro gigante** no alto: o
  próprio conceito contradiz a diretriz ("Morvath é o centro da narrativa, não o portal").
- Riscos: tudo violeta. As meias-luas das almas são violeta (`SOUL_VIOLET`), o fio dos avisos de Morvath é violeta, a
  maldição é violeta. Fundo violeta saturado apaga as três. O ar da fase 4 já está no limite (`LAST_BREATH` abaixo de
  0,45). Correntes e arcos sim; mais violeta no fundo, não.

## 2. Riscos de jogo do pacote, no geral

1. **Círculo de ouro no chão em 10 de 18 vistas.** No jogo, círculo no chão é linguagem de combate: o círculo de luz
   do herói (aro fino), as erupções e as runas de invocação de Morvath (círculos com borda exata da área), e o selo da
   Câmara. Espalhar círculos dourados tira o peso do medalhão do salão e do selo, homogeneíza as salas (a diretriz pede
   o contrário) e nas Runas contradiz D-29. Recomendo: círculo no chão só no Salão (o medalhão que já existe) e na
   Câmara do Selo; o resto marca o centro com o **padrão das lajes**, não com um emblema.
2. **Peças no primeiro plano.** Todo conceito tem pedra alta na faixa de baixo. No jogo, isso fica entre a câmera e a
   luta. Regra: do lado sul de cada sala, nada acima de 0,9 m dentro de 2 m da borda (a Cripta corta a frente a 0,9 m;
   o resto abre em pontilhado).
3. **Props no chão andável.** Qualquer peça nova acima de 0,3 m (o joelho do `fit_probe`) no chão livre é barreira
   falsa; qualquer peça que barre muda o `NavGrid`, o `FlowField`, o robô e os testes "cercado" (GP-04, 16 de 16 esquivas
   saem mais de 2,5 m). Regra: decoração nova fica fora do polígono do chão ou abaixo de 0,15 m (relevo, decalque,
   pintura). Só o room-designer move peça que barra, e com os testes.
4. **Brilhos que competem.** Verde (Emeth), violeta (inimigos e Morvath), vermelho (avisos) e âmbar (Runas) aparecem
   como cor de bioma em 13 das 18 vistas. Proposta de paleta de acento por bioma que respeita os donos: Cripta aço frio
   e vela; Fendas índigo dessaturado só abaixo da borda; Jardim musgo e ferrugem (folha morta, não vermelho vivo), água
   só fora do chão e escura; Santuário ouro de facho de luz; Ponte azul de bruma; Runas pedra clara e fio de ouro, o
   âmbar só na laje acesa; Provação lilás; Altar vela e ouro velho; Loja tecido terroso; Fonte água azul escura;
   Câmara violeta só no fundo distante e dessaturado.
5. **Bordas que leem como armadilha.** Ponte desabada (11), plataformas quebradas (04), lago (06, 07): boas como borda
   se a borda tiver lábio quebrado e queda escura. O que não pode é uma borda decorativa **dentro** do chão (degrau,
   tabuleiro rachado, poça) que pareça perigo sem ser.
6. **Fundos claros atrás dos inimigos.** Vórtice (05), céu do poente (09), cascatas (06, 07, 10). Silhueta escura sobre
   fundo claro lê bem; o risco é a cor (ciano, violeta), não o claro. Medir com `tools/frame_stats.py` na caixa do
   fundo: saturação abaixo de 0,45 e matiz longe de 140 a 170 (Emeth e Morvath).

## 3. Melhorias ao pacote (respostas sim ou não para o PO)

- **P-1. Conceitos em alta resolução.** As 18 vistas são recortes de 548 x 146 px da prancha e 6 deles foram cortados
  fora do quadro. Pedir ao gerador as 18 em 1920 x 1080, de preferência numa vista próxima da câmera do jogo (de cima,
  inclinação 30), para a arte medir em vez de adivinhar. Sim ou não?
- **P-2. Uma vista de jogo por sala.** Acrescentar à diretriz: "cada sala é julgada na câmera do jogo; o que o conceito
  mostra de parede e fundo vale para a faixa do norte e o abismo; o chão é a identidade". Sim ou não?
- **P-3. "Centro de combate limpo" quer dizer "nada novo no chão".** As peças que barram hoje (sarcófago da Cripta,
  colunas do Santuário, árvore e raízes do Jardim, ruína do meio da Ponte, pilares das Runas) **ficam onde estão e viram
  os marcos**; "sarcófagos só nas margens" vale para os decorativos novos. Sim ou não?
- **P-4. Círculo no chão só no Salão e na Câmara do Selo.** Nas outras salas o centro se lê pelo padrão das lajes, sem
  emblema. Sim ou não?
- **P-5. Cores reservadas na diretriz.** Acrescentar a tabela 0.4 à diretriz como regra de todos os lotes (nenhum
  bioma usa verde Emeth, violeta saturado, vermelho saturado nem âmbar perto do chão). Sim ou não?
- **P-6. Repensar a vista 05 (Fendas B).** O marco vira a ponte caída (que é a regra da B), sem vórtice. Sim ou não?
- **P-7. Jardim "das Raízes Mortas".** Folhagem morta e ferrugem, não floresta viva e vermelha; a árvore continua de
  pedra (D-30). Sim ou não?
- **P-8. Provação lilás e sem cara de arena.** Manter o lilás da maldição e o recolhimento da câmara; nada de pedestais
  de fogo no chão. Sim ou não?
- **P-9. Altar sem figura alada nem auréola.** A figura do Altar (se houver) passa pelo cânone; nunca auréola raiada
  (sol ou cruz), nunca brilho verde. Sim ou não?
- **P-10. Fonte e Loja como salas próprias.** Hoje o Salão aparece 2,5 vezes por descida (abertura, fonte em metade
  delas, loja sempre). Dar à Fonte e à Loja câmaras pequenas próprias, como Provação e Altar (sem luta, câmera fixa), com
  a fonte num lugar fixo. Melhora o ritmo e é o único jeito de os conceitos 16 e 17 valerem. Custo: dois `RoomLayout`
  novos, dois looks, `Rooms` e `Game._spawn_fountain` (gameplay-engineer, pequeno). Alternativa barata: a fonte só ganha
  lugar fixo no Salão e a loja um canto vestido. Sim (salas próprias) ou não (Salão vestido)?
- **P-11. Bica de leão na fonte.** Depende do cânone (o leão é o símbolo do herói). Sim ou não?
- **P-12. Variantes A e B diferentes por regra, não só por arte.** Toda variante já muda a forma (ponte caída, muro,
  buraco, pedra quieta). Pedir que o conceito de cada B mostre essa diferença (05 e 09 hoje não mostram). Sim ou não?
- **P-13. Ordem dos lotes pela exposição real** (tabela 0.3):
  - Lote A: Salão (com loja e fonte, 2,5 vezes por descida) e Cripta. Mantém a ordem da diretriz.
  - Lote B: **Santuário** (1,57 por descida, toda descida tem o guardião lá) e Fendas.
  - Lote C: Jardim e Ponte.
  - Lote D: Runas, Provação, Altar.
  - Lote E: Câmara do Selo, só fundo e atmosfera (já é a sala mais medida; mexer nela por último e pouco).
  Sim ou não?
- **P-14. Teste de aceite de jogo em todo lote.** Além das capturas: `fit_probe` sem piorar fantasma e peça sem desenho,
  `test_arenas.gd` (pontos dentro de peças, invocações, "cercado") e 8 sementes do robô por sala tocada sem `stuck`.
  Sim ou não?

## 4. Perigos e interações que os conceitos inspiram (propostas separadas)

**Nada aqui está autorizado pela diretriz. Todas precisam de aprovação do PO**, e nenhuma deve entrar no redesenho
artístico. Regras de todas: aviso no chão ou na peça antes de ferir, nunca menor que 1,0 s (o preparo do corredor e a
mira do mago, os mais curtos dos inimigos comuns); fere inimigos também, com chave "Derrotado por" (`DefeatCause`);
nunca a menos de 6 m da porta de entrada nem nos primeiros 3 s; sempre uma saída livre (teste no molde do
`test_boss_exits.gd`); queda fere e devolve ao chão. Números de dano no molde das Runas (herói 4, um golpe comum;
inimigo comum 35, meio esqueleto) até o estudo dos perigos de sala do Hades II (Érebo e Oceanus) fixar os números
fiéis antes da implementação.

| # | Perigo | Sala e profundidade | Aviso | Efeito (herói / inimigos) | Risco | Código |
|---|---|---|---|---|---|---|
| H-1 | **Raiz que golpeia** (06, 07) | Jardim, a partir de 0,34 da descida (salas 4 a 9) | a raiz que já existe racha e solta poeira por 1,2 s, linha de 1 x 4 m no chão ao longo dela | 4 / 35, empurra 1 m para fora da raiz; dispara quando alguém fica 0,5 s a menos de 1,5 m; recarga 6 s por raiz | raiz perto do centro (a de (0,3; 1,2)) dispararia o tempo todo: só as de fora | comportamento novo (zona de linha com gatilho de proximidade) |
| H-2 | **Laje de pisar** (02, 08) | Cripta (cantos) e Santuário (naves laterais), a partir da sala 4 | moldura rachada sempre visível; pisar arma e a laje acende por 1,0 s | 4 / 35, inimigos também armam; recarga 5 s | nunca nas rotas de 4 m da Cripta nem na nave do Santuário | reusa `ArenaHazard` com um padrão "gatilho" (pouco código) |
| H-3 | **Corrente que varre** (04, 10, 18) | Ponte A e B, a partir da metade | a corrente range e balança, faixa de 2 m atravessando a ponte marcada no chão por 1,2 s | 4 / 35, empurra ao longo da ponte (nunca para fora; ninguém cai, D-28) | ponte de 5 m: a faixa nunca pega as duas pontes ao mesmo tempo; sempre uma plataforma livre | comportamento novo (faixa em movimento, como a varredura das Runas) |
| H-4 | **Fenda que respira** (04, 05) | Fendas, a partir da sala 3 | a bruma sobe da fenda num trecho de 6 m por 1,2 s | sem dano; empurra 2 m para longe da borda todos os corpos no trecho | cortar o bote de inimigos que estão na beira (bom), empurrar o herói para dentro de um grupo (ruim): só em trechos sem nascimento perto | comportamento novo (empurrão em área) |
| H-5 | **Cristal que se descarrega** (13) | Runas B, a partir da metade | o cristal fora do chão, ao norte, enche de luz a cada golpe do herói; cheio (3 golpes) brilha 1,0 s | descarrega na fileira de lajes para onde aponta: 4 / 35 | é o "cubo que explode" do Hades: perigo que o jogador escolhe usar; o robô precisa aprender a ignorá-lo | pouco: reusa a fileira do `ArenaHazard` com gatilho por golpe |
| H-6 | **Chão que cede** (09, 11) | Santuário B (beira do buraco) e Ponte B (patamar), no fim | lajes rachadas sempre visíveis; pisadas tremem 1,5 s | quem estiver em cima cai: 3 de dano, volta à beira mais perto; inimigo comum 50% da vida; a laje volta em 8 s | muda o chão em jogo: `NavGrid`, `FlowField`, `Arena.walk` e o robô precisam aceitar chão que some; risco técnico alto | muito código |
| H-7 | **Água rasa** (06, 07, 17) | Jardim B (borda oeste trocada por lago, P-7) | água sempre visível | sem dano; todos 20% mais lentos nela, a esquiva atravessa sem perda | lentidão no herói irrita; só se for pouca área e na borda | pouco (zona permanente, como o `BIND` lento) |

Onde não pôr perigo nenhum: Salão (abertura, loja, fonte), Provação, Altar e a Câmara do Selo (Morvath já é o perigo
da sala; as correntes ficam cenário). Progressão proposta: começo da descida (salas 2 a 4: Cripta, Fendas, Jardim) só
terreno; meio (Santuário, 4 a 6) um perigo simples e lento (H-2); fim (Ponte, Runas, 5 a 9) perigos ativos (Runas, H-3,
H-5). Prioridade se o PO quiser um só: **H-2** (barato, reusa o `ArenaHazard`, lê como Hades) e depois **H-3** (dá à
Ponte uma razão para atravessar). H-6 por último ou nunca.

## 5. Resumo: recomendações priorizadas

1. **Chão quieto, fundo rico** (a lição de Sworn e da câmera real): a identidade de cada sala no chão, nas bordas e na
   faixa do norte; nada novo acima de 0,3 m no chão andável; nada acima de 0,9 m a 2 m da borda sul.
2. **As peças que barram ficam e viram os marcos** (P-3): sarcófago da Cripta, muro do Ossuário, colunas do Santuário,
   árvore do Jardim, ruína da Ponte, pilares das Runas. O conceito decora o marco, não o tira.
3. **Cores reservadas** (P-5): Emeth, violeta de inimigos e Morvath, vermelho dos avisos e âmbar das Runas fora da
   paleta dos biomas perto do chão; medir saturação e matiz do fundo em cada lote.
4. **Um círculo no chão por jogo, não por sala** (P-4): só o medalhão do Salão e o selo da Câmara.
5. **A variante B mostra a regra da B** (P-6, P-12): Fendas B pela ponte caída, Santuário B pela abóbada que caiu com o
   chão (luz fria de cima sobre o buraco, sem céu de poente).
6. **Ordem dos lotes pela exposição** (P-13): Salão e Cripta, depois Santuário (toda descida) com Fendas.
7. **Fonte e Loja**: decidir se viram câmaras próprias (P-10); no mínimo a fonte num lugar fixo, senão o conceito 17
   não vale.
8. **Lore e símbolo antes da arte** (P-9, P-11): figura alada e auréola do Altar, bica de leão, vela em cruz do 01.
9. **Teste de aceite de jogo por lote** (P-14): `fit_probe` sem piorar, `test_arenas`, 8 sementes do robô sem `stuck`.
10. **Perigos novos fora do redesenho**: se o PO quiser, H-2 (laje de pisar) e H-3 (corrente na Ponte) depois do Lote B,
    cada um com aprovação própria.
