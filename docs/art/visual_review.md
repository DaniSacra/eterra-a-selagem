# Revisões visuais

Registro das revisões do Art Director: capturas reais do jogo comparadas com a referência aprovada pelo Daniel.
Critérios e métricas da arena: `docs/art/arena_reference.md`, seção "Critérios de fidelidade".

## 2026-11-14: diagnóstico da arena para a missão de reprodução

- Capturas: `c0_showcase` (vitrine, `--showcase --seed=5`, 1672 x 941, Vulkan) e `c0_game` (em luta), no scratchpad da
  sessão; experimento de névoa e luz numa cópia do projeto (`x1` a `x4`), sem mudança no repositório.
- Bate: câmera, losango da sala, posição do medalhão, da escada, do portal, dos braseiros e dos obeliscos (erros de
  20 a 50 px); tamanho do herói.
- Difere (P0): faixa de valor estreita e azul por causa da névoa sobre a sala; abismo sem profundidade nem violeta;
  medalhão lido como círculo de ritual; portal fraco em forma de casinha, sem verde no chão.
- Difere (P1): chão em pranchas com serrilhado nas juntas; obeliscos finos e pontudos; balaustradas miúdas; estátuas
  do KayKit; estátua gigante cortada no topo; velas e potes pequenos e apagados; braseiros rasos; correntes fora do
  quadro; estandartes curtos; multidão cor de gesso.
- Depende de modelo: escultura das estátuas, relevos da fachada, herói e inimigos da pintura.
- Pedidos: Environment Artist, P0-1 a P1-9 com valores na seção de critérios; P1-10 com dono a definir; UI/UX remover
  a barra de 8 px do topo (`xp_back`).
- Veredito: não aprovado para teste do Daniel; refazer a captura depois dos P0.

## 2026-11-14: ciclo 1 (P0-1, P0-2, P0-3)

- Capturas: `c3/showcase` (Vulkan) e `c3/compat_1.25` (`DRIVER=opengl3`), 1672 x 941, `--showcase --seed=5`, no
  scratchpad da sessão.
- Feito: névoa só depois da sala e névoa de altura no abismo; ambiente petróleo; luz de chave malva sobre o medalhão;
  braseiros com poças menores; profundezas e muralha numa camada de luz própria (`ArenaKit.DEPTH_LAYER`), fora do fogo,
  com três fileiras de colunas e arcos a oeste, luzes violetas baixas só nas laterais, cartões de brilho violeta
  (`abyss_glow.gdshader`) e `FogVolume` violeta no desktop; foco do portal na escada mais forte; medalhão refeito como
  rosa dos ventos de 8 pontas com anéis duplos, 16 volutas, folhas nos vãos e roseta (sem linhas cruzando o miolo),
  pontas longas na horizontal da tela, brilho 0,1.
- Medidas (vitrine, desktop): p1/p5 0/3 (alvo 4 a 10 / 10 a 16), p50 38 (42 a 50), p95/p99 106/167 (>= 105 / >= 170),
  < 20: 27% (9% a 17%), chão azul dominante 40% (40% a 65%), violeta esquerda/direita 7% / 2,9% (>= 6% / >= 3%),
  quentes estourados 0,3% (>= 0,7%), verde no chão 5% (>= 8%).
- Falta: pretos ainda fundos demais nas profundezas e na muralha da frente (subir um pouco a bruma ou o tint); brilhos
  quentes fracos; verde do portal no chão (P0-4); lanterna do abismo como janela ogival (P0-2).
- Navegador: `COMPAT_EXPOSURE` 0,72 para 1,25 e `COMPAT_AMBIENT` 0,3 para 0,4 (p50 36); o violeta do abismo sai azul
  e o chão fica azul dominante 75%: a acertar.

## 2026-11-14: ciclo 2 (P0-4, P1-1, P1-2)

- Referência guardada em `docs/art/ref/arena_catacumbas_1672.png` (fora do git: o repositório é público).
- Feito: chão em lajes quase quadradas (`stone_size` 1,9, `len` 1,0, `jit` 0,35), juntas de 0,055 m, chanfro 0,55, sem
  a normal por derivada (o serrilhado sumiu); poça molhada fixa em frente à escada do portal (`CatacombHall.WET`);
  portal como vão de luz com três pedras pendentes no alto e mais claro embaixo; janela em losango verde acima do vão;
  obeliscos grossos (2,2 e 2,3 m) em três blocos girados, topo em tronco de pirâmide torto, nicho ogival; colisão
  dos obeliscos pelo raio novo; fundo do abismo na cor da bruma e névoa de profundidade até 170 m.
- Medidas (vitrine): p50 37, p95/p99 101/167, < 20: 30%, verde no chão 4,6% a 7,5%, portal com mediana #21ca63.
- Falta: colunas do fundo a oeste e ao norte lidas como painéis azuis lisos (precisam de textura ou silhueta mais
  escura na bruma); pretos ainda fundos demais; o vão do portal ainda fecha em ponta (a fachada corta o alto);
  estátuas encapuzadas (P1-4), balaustradas (P1-3), velas e potes maiores (P1-6).

## 2026-11-14: ciclo 3 (abismo, portal, P1-3, P1-4, P1-6, P1-7, pretos)

- Capturas: `c3_vitrine`, `c3_luta` (Vulkan) e `c3_compat` (`DRIVER=opengl3`), 1672 x 941, `--seed=5`, no scratchpad
  da sessão.
- Abismo: as profundezas usam um material próprio sem luz (`assets/shaders/depth_stone.gdshader`,
  `Masonry.depth_stone`): pedra escura em fiadas, aresta fria na face voltada para a bruma, desbota na cor da bruma com
  a distância e afunda nela embaixo, violeta fraco de baixo nas laterais. Fica fora da lua e das luzes da sala; segue
  na camada `ArenaKit.DEPTH_LAYER`. Três fileiras de pilares com capitel e agulha e arcos ogivais, de frente para a
  câmera da vitrine, a 68, 82 e 98 m dela (`ROW_*` em `catacomb_hall.gd`); a torre das correntes no meio do alto; a
  janela acesa da pintura numa parede da fileira da frente (`_lantern`). Os cartões violetas foram para trás da
  fileira da frente (os pilares ficam escuros contra o violeta). Descoberto: o fundo da tela é a cor da névoa
  (`fog_sky_affect`), não `SKY`; a bruma é `Game.FOG` (petróleo claro, 0,07 0,28 0,31) e o material das profundezas
  desbota nela. A névoa volumétrica global foi zerada (`VOLUMETRIC_DENSITY` 0: iluminada pela lua, ela pintava
  painéis azul-claros lisos no fundo); os `FogVolume` violetas continuam.
- Correntes: os elos estavam de lado (o furo ao longo da corrente, viravam tracinhos); agora deitados ao longo dela,
  alternando um quarto de volta (`LINK_STRETCH`).
- Estátua gigante (P1-5): pés em y -0,4, 7 m, capuz no alto do quadro, luz do braseiro só na barra e nas mãos
  (`GIANT_UPLIGHT` 2,5).
- Portal (P0-4): vão retangular entre ombreiras grossas sob um lintel, três pedras pendentes, duas ordens em ogiva por
  fora com a pedra mais clara (`PORTAL_ORDER_*`), janela em losango de 1,0 x 1,2 m no tímpano, 1,4 m acima do vão;
  o véu de luz a 0,7 m da frente e num verde mais fundo que a luz (`PORTAL_SHEET`), para o miolo não estourar em
  branco. Vão de 3,4 x 4,8 m.
- Estátuas (P1-4): `Masonry.hooded_statue`, uma malha por torno (manto com 10 pregas, ombros, capuz com ponta atrás,
  rosto escuro por cor de vértice, braços até as mãos juntas), um material por tom; troca o boneco do KayKit em
  `ArenaKit.statue` (base em `Masonry.block`; colisão, quando sólida, 0,25 da altura). Estátuas do portal com 5 m.
- Balaustradas (P1-3): pilar 0,9 x 1,3, degrau e tampa de 1,1 m, vão de 3 m, corrimão 0,3 x 0,45 com topo a 1,05,
  rodapé 0,26, 3 balaústres com bojo; `top_light` 1,3.
- Velas e potes (P1-6): círios de cera creme de 0,3 a 0,9 m com escorrido e chama (`Masonry.candle`), halo de 0,9 m,
  luz 1,5 / 3,5 por grupo; grupos movidos para os pontos da pintura (balaustrada oeste em z 7,1 / 1,4 / -6,3 /
  -10,4 com o altarzinho e dois potes, junto ao obelisco sul o maior, patamar, leste, pé e alto da escada); potes de
  0,8 a 1,05 m com gargalo, lábio e boca escura.
- Braseiros (P1-7): bacia funda de bronze (0,65 / 0,35 / 0,45) com aro sobre pilar de balaustrada de 0,9 m; chama em
  línguas que afinam do branco-ouro ao laranja (30 línguas, vida 0,8). Colisão continua 0,6 (com 0,7 o teste de
  layout de três portas falhava junto ao obelisco leste).
- Pretos: juntas do chão e da cantaria menos pretas, ambiente 0,45 para 0,65, muralha sob a plataforma com tint 0,9.
- Medidas da vitrine (antes, no início do ciclo, e agora): p1/p5 0/2 para 2/9 (alvo 4 a 10 / 10 a 16); p50 37 para
  49 (42 a 50); p95/p99 99/166 para 140/187 (>= 105 / >= 170); < 20: 30% para 16% (9% a 17%); chão azul dominante
  42% para 50% (40% a 65%); quentes estourados 0,3% para 1,2% (>= 0,7%); violeta esquerda/direita 7% / 2,9% para
  8,5% / 3,6% (>= 6% / >= 3%); verde no chão 4,6% para 13,9% (>= 8%); `portal_open` mediana #21c962 para #3ad94f;
  `abyss_top_teal` mediana #0e1220 para #21343d (pintura #094256).
- Navegador: não quebrou; p50 33 para 35, < 20: 42% para 39%; sem violeta (como antes).
- Falta: p5 9 e p1 2 ainda um pouco abaixo da faixa (juntas do chão longe das luzes e faces de sombra dos obeliscos);
  as ordens do portal quase não leem na luz verde (a ogiva de fora fica acima do quadro); o braseiro leste ainda é
  um borrão de brilho atrás do entulho; potes pequenos na tela perto da pintura; estandartes (P1-9), manchas
  vermelhas (P2) e multidão (P1-10) não foram tocados; composição do lado esquerdo baixo (a pintura tem abismo onde
  o jogo tem o patamar) é da planta da sala, não do cenário.
