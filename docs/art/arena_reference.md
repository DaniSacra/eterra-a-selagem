# Arena das Catacumbas: análise da referência e reconstrução

Referência: imagem do Daniel "Arena das Catacumbas: Golpe Dourado" (1672 x 941, feita por IA, 2026-11-14; fica fora
do repositório, ver `docs/steam-ia.md`). Implementação: `scripts/game/catacomb_hall.gd` (`CatacombHall`), peças de pedra em
`scripts/game/masonry.gd` (`Masonry`) e `scripts/game/arena_kit.gd` (`ArenaKit`), materiais em `assets/shaders/`.

## Câmera da imagem

Medida pelas bordas da sala, que são paralelas duas a duas: na imagem, as bordas norte e sul sobem 0,26 para cada 1 na
horizontal, e as bordas oeste e leste descem 0,5. Disso saem um giro de 35° (a câmera fica no sudeste, olhando para o
noroeste) e uma inclinação baixa. A lente é longa: as verticais dos obeliscos e da fachada são quase paralelas.

| | Referência (medida) | Jogo |
|---|---|---|
| Campo de visão (vertical) | cerca de 24° | 24° (`Feel.cam_fov`) |
| Giro horizontal | 35° | 35° (`Feel.cam_yaw`) |
| Inclinação | 26° a 30° | 30° (`Feel.cam_pitch`; 30 preserva a leitura do combate) |
| Distância | herói de 2,5 m com 88 px de altura | 60 m (`Feel.cam_distance`) |
| Projeção | perspectiva, quase ortográfica | perspectiva |

Dois modos: o de jogo segue o herói com esses ângulos; `--showcase` fixa a câmera no enquadramento da imagem
(`CatacombHall.SHOWCASE`, `Game.SHOWCASE_DISTANCE`) para comparar lado a lado. O teclado e o controle giram com a
câmera (cima na tela é cima no jogo: `Feel.screen_to_floor`).

## Como as posições foram tiradas

Cada marco da imagem (pontas das bordas, pés dos obeliscos, escada, braseiros, centro e bordas do medalhão) foi
projetado no chão (ou na altura certa, para as bacias dos braseiros) pela câmera acima. Assim cada peça cai, vista
pela câmera do jogo, onde a pintura a tem. O resultado não é a sala quadrada que parecia à primeira vista:

| Elemento | Na imagem | No mundo (m; x leste, z sul) |
|---|---|---|
| Sala de combate | losango central | 32 x 30 (`HALF` 16 x 15) |
| Medalhão (estrela de 8 pontas, anéis) | centro-esquerda | centro (-2,5; 1), raio 7,5 |
| Escada do altar | alto à direita, larga | x -3,8 a 5,6 na borda norte, 4 degraus até 1 m |
| Portal verde | no alto da escada, metade direita | x 2,8, fachada em z -20, vão de 3,4 x 5,4 |
| Estátuas encapuzadas do portal | ladeando o vão | x -1,4 e 7,2, 4,4 m |
| Estandartes vermelhos | nos contrafortes da fachada | x -3,6 e 12,6 |
| Braseiro e estátua do canto noroeste | alto, centro | píer no abismo em (-12,4; -18,3) |
| Estátua gigante e seu braseiro | alto à esquerda | torre em (-26; -4,4), 7,6 m; braseiro em (-23; -4,4) |
| Balaustrada oeste com velas e potes | borda esquerda inteira | x -16, de z -15 até o patamar |
| Obelisco sul | embaixo à esquerda do centro | (-2,6; 15,3), 5,2 m |
| Patamar de entrada ("entrada na esquerda baixo") | embaixo à esquerda | x -16 a -3,6, z 15 a 20,5, degraus descendo |
| Obelisco e braseiro leste | embaixo à direita | (16,3; 2,1) e braseiro ao lado |
| Escada descendo à direita | direita, entre o obelisco e o braseiro do alto | vão na borda leste, z -5,8 a 0,6 |
| Braseiro do canto direito | alto à direita | píer em (17; -7) |
| Caixotes, potes e velas | pé da escada, à direita | (7,2; -14) |

A imagem não é fisicamente coerente em tudo (é uma pintura): a melhor câmera deixa erros de cerca de 1 m nos marcos
mais distantes. O que se viu na imagem prevaleceu sobre simetria.

## Arquitetura e materiais

- Plataforma de pedra sobre o abismo, com muralha de blocos descendo até a névoa roxa e contrafortes sob a borda.
- Altar elevado com escada larga, fachada gótica de 10,5 m com três arcos ogivais encaixados, frontão, contrafortes
  com pontas, janelas ogivais escuras e o véu verde do portal no fundo do vão.
- Balaustradas de pedra com pilares largos de capitel, corrimão grosso, rodapé e balaústres (`Masonry.balustrade`).
- Obeliscos de blocos que afinam, com ponta e nicho escuro (`Masonry.obelisk`).
- No abismo: arcada ogival a oeste com uma lanterna, torre no noroeste, arcos atrás da fachada, correntes grandes
  ligando a estátua gigante, a torre e a fachada.
- Pedra: `masonry.gdshader`, cantaria em fiadas no mundo (triplanar), juntas fundas com relevo, lavagem pintada de
  ardósia e violeta, lascas e rachaduras, sujeira subindo do pé, topos mais claros. Vale para toda pedra construída e
  para as peças de pedra do KayKit.
- Chão: `catacomb_floor.gdshader`, lajes grandes quase quadradas (2,1 m) em fileiras de profundidade variável, algumas
  partidas, rachaduras, poças úmidas que refletem (SSR) e o medalhão gravado em ouro velho.

## Luz e atmosfera

- Desktop em Forward+ (o navegador e o celular seguem em Compatibility): névoa volumétrica leve, SSAO, reflexos de
  tela nas poças, sombras dos braseiros.
- Ar frio azul-petróleo (fundo, névoa de distância), luz ambiente violeta-acinzentada baixa.
- Quente: 4 braseiros (luz 7, alcance 16, com sombra) e 13 grupos de velas (10 com luz própria, de alcance 5).
- Verde: o portal (luz forte mesmo fechado, mais forte aberto) e um foco descendo a escada até o chão molhado.
- Violeta: cinco luzes no abismo, sob as bordas, que pintam a muralha e a névoa.
- Lua fria vinda do noroeste, por trás, para recortar pedra e lutadores.

## Ciclos de comparação (capturas reais da Godot)

1. Primeira montagem (sala quadrada de 28 m, câmera de 47°): losango certo, mas câmera alta, tudo escuro, fogo estourado.
2. Câmera mais baixa, menos brilho, pedra e chão mais claros: elementos no lugar, mas fachada cortada e blocos miúdos.
3. Ajuste da câmera pela projeção dos marcos: a sala virou 32 x 30, escada larga, obelisco no meio da borda sul,
   patamar de entrada; composição batendo com a imagem.
4. Luz: chão mais quente, poças dos braseiros maiores, verde do portal na escada, roxo do abismo.
5. Correntes grandes no alto, roxo só nas laterais, saturação e exposição mais perto da pintura.
6. Diagnóstico para a missão de reprodução: medidas de valor e cor por região, experimento de névoa e luz numa
   cópia do projeto; critérios em "Critérios de fidelidade" abaixo.

Capturas: `docs/art/shots/` (vitrine e jogo, 1280 x 720 e 1920 x 1080). Comparação lado a lado com a referência:
fora do repositório, em `C:\Users\danie\ASelagem-teste\arena-comparacao.png`.

## Situação: PARCIALMENTE CONCLUÍDA

Composição, posições, câmera, paleta e luz seguem a imagem. O que ainda separa o jogo da pintura depende de modelos e
texturas que não existem no projeto (plano em `meshy_asset_plan.md`):

- Estátuas encapuzadas: monges procedurais em `Masonry.hooded_statue` (manto pregueado, capuz, rosto escuro, mãos
  juntas; ciclo 3); a pintura tem escultura com rosto, mãos e dobras que só um modelo dá.
- Fachada do portal: vão retangular com pedras pendentes, lintel, duas ordens em ogiva e a janela em losango (ciclo
  3), tudo em caixas; a pintura tem cantaria esculpida, arquivolta e gárgulas.
- Obeliscos, balaustradas, braseiros: na massa e nas medidas da pintura (ciclos 2 e 3), em caixas com material de
  cantaria; a pintura tem pedra lascada.
- Potes e velas: círios grossos de cera creme e potes com gargalo e lábio, nos grupos da pintura (ciclo 3); caixotes
  ainda do KayKit.
- Abismo: fileiras de pilares góticos de frente para a câmera da vitrine em pedra sem luz (`depth_stone.gdshader`),
  escuras contra a bruma petróleo e o violeta, mais apagadas a cada fileira (ciclo 3).
- Estandartes: lisos (o símbolo da pintura é cânone pendente com o Daniel).
- Herói e inimigos: os da pintura (minotauro de escudos, esqueletos) são outros modelos.
- HUD da pintura (retrato, losangos Q/E/R) não foi copiado: o HUD do jogo é outro trabalho.
- No navegador (Compatibility) a luz rende diferente: mais escuro, azulado e sem o violeta do abismo, mesmo com a
  compensação (`Game.COMPAT_EXPOSURE`); o Daniel decidiu que só o desktop precisa ficar ótimo.

## Critérios de fidelidade (missão de reprodução, 2026-11-14)

Diagnóstico do Art Director sobre a captura `c0_showcase` (vitrine, 1672 x 941, Vulkan, `--showcase --seed=5`) e a
`c0_game` (em luta), comparadas com a referência no mesmo tamanho. Valores medidos na tela (sRGB 0 a 255). O
Environment Artist implementa; o Art Director revisa com o checklist do fim desta seção.

### Como medir

- Captura: `RES=1672x941 tools/shot.sh <saida.png> 2 --showcase --seed=5` (sem `--bot`, para o enquadramento ficar
  igual a cada ciclo). Em luta: `RES=1672x941 tools/shot.sh <saida.png> 9 --bot --autopick --seed=5`.
- Métricas: script `art_metrics.py` (Python sem dependências + ffmpeg; hoje no scratchpad da sessão, a mover para
  `tools/art_metrics.py` pelo QA). Luminância Rec.709 por pixel, linhas do HUD (y < 60 e y > 820) fora das contas
  globais. Regiões são caixas de pixels no enquadramento da vitrine (lista no script).
- Nenhuma métrica substitui o olho: elas dizem se o valor e a cor estão na faixa; composição e silhueta se julgam
  lado a lado.

### Medidas globais (valor e contraste)

| Medida | Referência | Jogo hoje (c0) | Experimento x4 | Aceite |
|---|---|---|---|---|
| Luminância p1 / p5 | 7 / 14 | 20 / 25 | 2 / 7 | p1 4 a 10, p5 10 a 16 |
| Luminância p50 | 46 | 46 | 38 | 42 a 50 |
| Luminância p95 / p99 | 116 / 201 | 82 / 128 | 108 / 158 | p95 >= 105, p99 >= 170 |
| Pixels com luminância < 20 | 13% | 1% | 19% | 9% a 17% |
| Chão central com azul dominante (B > R + 15) | 54% | 67% | 15% | 40% a 65% |
| Pixels quentes estourados (L > 170, R > G > B) | 0,9% | 0,23% | 0,39% | >= 0,7% |
| Violeta no abismo, esquerda / direita | 11% / 4,9% | 0 / 0 | 0 / 0 | >= 6% / >= 3% |
| Verde do portal no chão em frente à escada | 13% | 1,1% | 5,5% | >= 8% |

Leitura: a referência tem pretos fundos (p1 7), meios-tons parecidos com os nossos e brilhos muito mais altos. A
nossa imagem é uma faixa estreita (20 a 128): pretos levantados por uma névoa azul e brilhos fracos. A causa
principal, confirmada por experimento numa cópia do projeto no scratchpad (captura x4, nada mudou no repositório):
a névoa de distância exponencial (`fog_density` 0,011) cobre a câmera de 60 m até a sala, então a própria sala fica
com cerca de 48% de névoa; a névoa volumétrica com `ambient_inject` 0,15 e o ambiente violeta 0,55 levantam todos os
pretos; as cinco luzes violetas do abismo (energia 14) pintam muralhas, balaustradas e obeliscos de azul.

### P0: sem isto a cena não lembra a pintura

**P0-1. Valor, névoa e luz de base** (Environment Artist; `scripts/game/game.gd` `_build_world`,
`scripts/game/catacomb_hall.gd` `_floor` e `_depths`, `scripts/game/arena_kit.gd` `brazier`)
- Névoa de distância só depois da sala: `fog_mode = FOG_MODE_DEPTH`, `fog_depth_begin` 64, `fog_depth_end` 130,
  `fog_depth_curve` 1,0, `fog_light_color` Color(0.02, 0.2, 0.26). Névoa de altura enchendo o abismo:
  `fog_height` -3,0, `fog_height_density` 0,6 (validado: o abismo vira bruma petróleo e a sala fica limpa).
- Ambiente: `ambient_light_color` Color(0.3, 0.45, 0.5) (petróleo, não violeta), `ambient_light_energy` 0,55 para 0,3.
- Volumétrica: `volumetric_fog_density` 0,008 para 0,003, `volumetric_fog_ambient_inject` 0,15 para 0,
  `volumetric_fog_emission` para preto. `tonemap_exposure` 1,3 para 1,25. Fundo `background_color` Color(0.01, 0.1, 0.14).
- Luz de chave sobre a arena (a pintura tem o meio da sala em malva acinzentado, a periferia em petróleo escuro):
  OmniLight sobre `MEDALLION_AT`, altura 9 m, alcance 18, atenuação 1,0, energia 4, fora da camada da multidão.
  Cor: o experimento usou Color(1.0, 0.78, 0.82) e esquentou o chão demais (15% azul dominante); usar lilás
  Color(0.85, 0.8, 0.95) e conferir a faixa de 40% a 65%.
- Poças dos braseiros menores e menos vermelhas (hoje a mediana do chão perto do braseiro leste é #833f3e; na
  pintura #40303f): `BRAZIER_LIGHT` 7 para 3,5, `BRAZIER_RANGE` 16 para 10, `omni_attenuation` 0,9 para 1,3, cor da
  luz Color(1.0, 0.68, 0.42) (a chama continua laranja e estourada).
- Luzes violetas do abismo (`_depths`): energia 14 para 5, todas abaixo de y -10, e só nas laterais (oeste e leste do
  quadro); não podem tocar o topo da plataforma (usar uma camada de luz própria para muralhas e profundezas e tirar
  essa camada das balaustradas, obeliscos e chão).
- Aceite: as oito linhas da tabela acima dentro da faixa; nenhuma pedra da plataforma com mediana em que B > R + 30.
- Compatibility: a névoa volumétrica não existe no navegador; conferir com `DRIVER=opengl3` que a névoa de altura e a de
  profundidade aparecem e ajustar `COMPAT_EXPOSURE` e `COMPAT_AMBIENT` para a mesma faixa de p50.

**P0-2. Abismo com profundidade** (Environment Artist; `catacomb_hall.gd` `_depths`, `_cliff`, `_floor`;
`arena_kit.gd` `abyss`, `_wisps`)
- Na pintura o abismo é bruma petróleo clara com silhuetas escuras na frente (colunas góticas, arcos, a torre):
  topo do quadro mediana #094256, brilhos #16788b; coluna da esquerda dark10 #020f1b, mediana #052f44. Na nossa, as
  profundezas são paredes de tijolo azul iluminadas (mediana #102035, sem silhueta).
- Pedra das profundezas escura e sem luz de fogo: `far` com tint 0,3 a 0,4, fora de todas as luzes quentes; a bruma
  fica mais clara que a pedra (inverter a relação de hoje).
- Três camadas de silhuetas a oeste (x perto de -24, -32 e -42), colunas de 1,5 a 2,5 m de largura com arcos ogivais
  entre elas e uma ponte em arco, subindo da bruma até uns 10 m acima do chão; cada camada mais apagada pela bruma.
- Brilho violeta de baixo, nas laterais: faixas luminosas na base das colunas, cor de tela alvo #6a48d8 a #7b54d7
  (Color(0.45, 0.3, 0.95) em emissão 1,5 a 2). Em Forward+: `FogVolume` em caixa no abismo (densidade 0,03 a 0,05,
  `emission` Color(0.25, 0.12, 0.5)); no Compatibility: cartões verticais aditivos com degradê (mesma ideia do
  `abyss_fog.gdshader`).
- Muralha sob a plataforma (`_cliff`): tint 0,5 (hoje 0,85), fiadas pouco visíveis, sumindo na bruma 6 a 8 m abaixo
  do chão. Na pintura o paredão de baixo à esquerda tem mediana #0d1431.
- A lanterna do abismo: na pintura é uma janela ogival acesa em (130, 280) na tela, cerca de 25 x 45 px; a nossa é
  uma bola em (105, 75). Trocar por janela ogival de 0,8 x 1,4 m com vidro quente emissivo e baixar até cair perto
  de (130, 280).
- Aceite: `abyss_left_cols` com dark10 <= #061420 e mediana com G >= R + 20 e B >= R + 25; violeta na esquerda >= 6%
  e na direita >= 3%; nenhuma parede de tijolo azul saturada ocupando mais de 10% do quadro.

**P0-3. Medalhão** (Environment Artist; `assets/shaders/catacomb_floor.gdshader` `medallion`, parâmetros em
`arena_kit.gd` `floor_plate` e `catacomb_hall.gd` `MEDALLION`)
- Hoje: dois quadrados vazados cruzados dentro de círculos finos. Na câmera da vitrine lê como círculo de ritual
  (estrela de linhas cruzando o miolo). Isso é proibido pelo tom do jogo: nada de pentagrama, hexagrama, octograma de
  linhas cruzadas, runas ou letras.
- Alvo (a pintura): rosa dos ventos de 8 pontas em pedra embutida. Medidas no mundo (centro em `MEDALLION_AT`):
  - anel externo r 4,7 m e anel interno r 3,8 m (dois traços de 0,10 m), faixa entre eles com ornamento repetido
    (16 volutas ou folhas, traço de 0,06 m);
  - 4 pontas longas com a ponta em r 7,5 m e 4 pontas curtas, nas diagonais, em r 5,6 m; cada ponta é um losango
    alongado que nasce no anel externo (base de 1,4 m nas longas, 1,0 m nas curtas), cheio de pedra 12% mais clara,
    com uma aresta no meio (metade 15% mais escura), contorno dourado de 0,08 m;
  - pequenos ornamentos em folha nos vãos entre as pontas, fora do anel;
  - miolo (dentro do anel interno) liso ou com uma roseta de 8 pétalas de r 1,2 m em baixo contraste; nenhuma linha
    reta atravessa o miolo;
  - cor do traço na tela entre #7a6a4c e #a08a5e (ouro velho apagado), `ring_glow` 0,35 para 0,1 (na pintura o
    medalhão não brilha, lê pelo valor); as juntas das lajes continuam visíveis por baixo.
- Orientação na tela da vitrine: as pontas longas apontam para perto de (530, 445), (1120, 455), (880, 368) e
  (700, 595); centro perto de (815, 480); o anel externo cobre de x 645 a 987.
- Aceite: na captura, o desenho lê como rosa dos ventos com anéis duplos e ornamento; nenhum polígono de linhas
  cruzadas; pontas saindo do anel; anel externo com meia-largura de 160 a 185 px na tela.

**P0-4. Portal e o verde derramando** (Environment Artist; `catacomb_hall.gd` `_facade`; `arena_kit.gd`
`portal_glow`, `PORTAL_*`; `assets/shaders/portal.gdshader`; `catacomb_floor.gdshader` para a área molhada)
- Hoje o véu verde é um pentágono (casinha) chapado e fraco (mediana #236e44); a fachada inteira fica verde
  (mediana #193436, no experimento #012d1b). Na pintura o vão é um retângulo de luz forte (mediana #39f65d, brilhos
  #92fc8b), com pedras pendentes no alto do vão, uma janela em losango acesa acima do arco e a fachada continua
  petróleo escuro (#11313a), verde só nas bordas perto do vão.
- Véu: retângulo de 3,4 x 5,0 m, borda de cima irregular com 3 pendentes escuros de 0,3 a 0,6 m; `PORTAL_DIM` 1,0
  para 2,0 (a pintura mostra o portal aceso durante a luta) e `PORTAL_OPEN` 1,4 para 2,8 com pulso lento.
- Janela em losango de 1,0 x 1,2 m, emissiva verde, centrada 1,4 m acima do topo do vão.
- Arquivolta: 2 a 3 ordens de aduelas (blocos de 0,5 m de profundidade, juntas a cada 0,6 m), cada ordem 0,35 m mais
  larga e 0,3 m mais à frente que a de dentro, laterais quase retas fechando em ponta (a pintura tem ogiva aguda).
- Luz: omni do portal de alcance 14 para 9 e energia 6 para 4 (o verde não pode lavar a fachada); foco descendo a
  escada com energia 7 para 9, alcance 16 para 14, abertura 32 para 40, mirando o pé da escada.
- Chão molhado obrigatório em frente à escada: zona x -1 a 8, z -15 a -10 com rugosidade 0,12 (reflexo de tela no
  desktop). No Compatibility, sem reflexo: riscos verdes pintados (emissão fraca) na mesma zona.
- Aceite: `portal_open` mediana com luminância >= 150 e G >= R + 120; `stairs` mediana entre #0f5050 e #1a7068;
  verde no chão em frente >= 8%; `facade` mediana com G <= 70 e G - B <= 20.

### P1: cada peça com a massa e a quantidade da pintura

**P1-1. Chão** (Environment Artist; `catacomb_floor.gdshader` `stones` e `fragment`)
- Hoje: pranchas compridas em fileiras (comprimento de 1,3 a 4 m, cara de parede de tijolo deitada), juntas finas
  (0,025 m) e um serrilhado em escada ao longo das juntas (normal tirada de `dFdx`/`dFdy`, bem visível ampliando o
  medalhão).
- Alvo: lajes de 1,2 a 2,6 m, proporção em planta entre 1:1 e 1,6:1 (`stone_size` 2,1 para 1,9, `len` 1,25 para 1,0,
  `jit` 0,5 para 0,35); 25% a 30% partidas em 2 ou 3 pedaços de 0,7 a 1,2 m; cantos arredondados e lascados (raio
  de 0,15 m, juntas tortas com amplitude de 0,1 m); juntas de 0,05 a 0,06 m quase pretas (#0a0c12 na tela); chanfro
  escurecido 0,55 ao longo de 0,14 m; borda clara (x1,25) no lado de cada laje voltado para o norte (fundo da tela),
  como as arestas acesas da pintura.
- Relevo: trocar a normal por derivada por uma normal analítica da distância à junta (ou suavizar e reduzir o fator
  -6 para -2). Aceite: nenhum serrilhado visível num recorte ampliado 2x do chão.

**P1-2. Obeliscos** (Environment Artist; `scripts/game/masonry.gd` `obelisk`; chamadas em `_landing` e `_east`)
- Hoje finos (1,5 m de largura para 5,2 m, proporção 0,29) e com ponta aguda. Na pintura são grossos e rombudos:
  largura sobre altura perto de 0,43.
- Alvo: largura 2,2 m (sul, altura 5,2) e 2,3 m (leste, altura 5,6); 3 blocos com junta horizontal funda, cada um 8% a
  10% mais estreito e girado de -3 a 3 graus; topo em tronco de pirâmide baixo (altura 0,45 da largura), torto de 4
  graus, com um canto quebrado; nicho em arco ogival escuro (0,5 da largura por 0,3 da altura, entre 55% e 75% da
  altura); 2 a 4 lascas nos cantos de cada bloco (CSG com subtração, assado em malha estática; nada em tempo real).
- Aceite: obelisco sul ocupa de 120 a 150 px de largura na tela da vitrine; nenhuma ponta aguda; colisão
  (`kit.circles`) atualizada pelo Gameplay Engineer para o raio novo.

**P1-3. Balaustradas** (Environment Artist; `masonry.gd` `balustrade`, `post`, `POST`, `POST_GAP`)
- Hoje pilares de 0,62 m e corrimão fino, que de longe vira uma linha. Na pintura os pilares são blocos com tampa,
  bem maiores que a cabeça do herói.
- Alvo: `POST` 0,9 x 1,3 x 0,9 m; tampa de 1,1 x 0,22 m mais um degrau de 0,95 x 0,1 m; `POST_GAP` 2,8 para 3,0;
  corrimão 0,3 m de altura por 0,45 de profundidade com topo a 1,05 m; 3 balaústres de 0,22 m por vão, com um bojo
  (duas caixas); rodapé 0,26 m. Topos com o clareamento de `top_light` (1,18 para 1,3) para ler a aresta.
- Aceite: na vitrine, os pilares da balaustrada oeste com 35 a 50 px de largura; tampas legíveis contra o abismo.
  O Gameplay Engineer confere que o pilar mais grosso (0,45 m para dentro) não invade o andável.

**P1-4. Estátuas encapuzadas sem modelo novo** (Environment Artist; `arena_kit.gd` `statue`, nova função
`Masonry.hooded_statue`)
- Hoje é o encapuzado do KayKit (cabeçudo, pernas à mostra, cor de barro na luz do fogo, translúcido de verde perto
  do portal). Na pintura: monges de pedra escura, capuz fundo com o rosto em sombra, manto até a base, ombros largos,
  mãos juntas no peito.
- Construção procedural para altura H (sem a base): manto em torno (lathe/ArrayMesh) da base até 0,78H, raio 0,2H na
  barra e 0,13H no peito, 10 pregas verticais (deslocamento radial 0,012H por sin(10 ângulo)) e barra levemente
  aberta; ombros e capa como esfera achatada de 0,3H de largura entre 0,72H e 0,8H; capuz elipsoide de 0,13H de
  largura e 0,17H de altura em 0,86H, puxado 0,03H para a frente, com ponta atrás; rosto como disco fundo e escuro
  (albedo 0,01, sem rim) de 0,07H; braços como cápsulas dos ombros até as mãos juntas na frente a 0,6H. Material
  `Masonry.stone` com tint 0,55 e rim 0,3. Cabeça mais capuz perto de 1/6,5 de H.
- Aceite: silhueta lida como figura de manto e capuz, sem pernas; rosto é a região mais escura da estátua
  (luminância < 12); estátuas do portal com o lado do vão verde e o resto petróleo escuro (mediana perto de #093233).
- Pendência de cânone: o que as estátuas seguram (na pintura uma parece segurar um bastão ou lanterna) e quem elas
  são: perguntar ao Daniel pelo Game Director. Até lá, mãos juntas e vazias.

**P1-5. Estátua gigante e braseiro do alto à esquerda** (Environment Artist; `catacomb_hall.gd` `_west`, `GIANT`)
- Hoje a cabeça sai do quadro (topo cortado) e o corpo fica em cima de uma torre em degraus; cor de barro alaranjada.
- Alvo: topo da torre perto de y 0 a 0,3; a estátua (P1-4, 7,0 a 7,6 m) atrás do braseiro, com a bacia na frente da
  barra do manto; topo do capuz entre y 15 e 40 px na tela da vitrine; mediana da região `statue_nw` perto de
  #221d1d com brilhos quentes só nas mãos e na barra (luz de baixo do braseiro).

**P1-6. Velas e potes** (Environment Artist; `catacomb_hall.gd` `_candles`, `masonry.gd` `pot`, posições em
`_north_west`, `_west`, `_landing`, `_east`, `_dais`)
- Hoje há 14 grupos e cerca de 40 velas, mas pequenas e apagadas (região `candles_w`: brilhos #503c4e; na pintura
  #fadf73). Potes são bolinhas vermelhas.
- Velas: círio grosso de cera creme Color(0.92, 0.86, 0.72), altura 0,3 a 0,9 m, raio 0,07 a 0,11 m, escorridos; 3 a 7
  por grupo, alturas variadas; chama em quad de 0,22 m emissiva Color(4.0, 2.2, 0.8) mais halo aditivo de 0,9 m; luz
  por grupo energia 1,5, alcance 3,5, Color(1.0, 0.7, 0.4).
- Grupos na tela da vitrine (pintura): (318, 445), (440, 360) com potes, (655, 285), (725, 240) sobre um altarzinho
  com 2 potes, (95, 592) no patamar, (575, 735) junto ao obelisco sul (o maior, 6 velas altas), (1335, 705), (1545,
  690), (1375, 335) no pé da escada com potes e caixotes, (1215, 240) no alto da escada. Cerca de 10 a 12 grupos e
  45 velas.
- Potes: altura 0,8 a 1,1 m, barriga de raio 0,3 a 0,4 m, ombro, gargalo e lábio virado (toro), boca escura; 2 a 3
  por grupo, 12 no total; argila `CLAY` Color(0.55, 0.2, 0.1); brilhos na tela >= #c04a20 quando perto de vela.
- Aceite: pixels quentes estourados >= 0,7%; `candles_w` bright10 com luminância >= 180; cada grupo da lista acima a
  menos de 40 px da posição na vitrine.

**P1-7. Braseiros** (Environment Artist; `arena_kit.gd` `brazier`, `fire`; base no `_east`)
- Hoje bacia rasa sobre coluna do KayKit; o braseiro leste fica sobre entulho. Na pintura: bacia funda de bronze
  escuro com aro, 1,3 m de diâmetro, sobre pedestal quadrado de pedra com tampa (1,1 m), chama alta.
- Alvo: bacia raio de cima 0,65, de baixo 0,35, altura 0,45, com aro (toro de 0,06 m); pedestal `Masonry.post` de
  0,9 m de lado; chama de 1,2 a 1,5 m (`fire` com raio 0,6, 30 línguas, quad 0,55, vida 0,8); faíscas iguais.
- Aceite: núcleo da chama com brilhos >= #f8f090 e borda laranja; poça de luz no chão com mediana entre #352838 e
  #4a3442 (não vermelho saturado).

**P1-8. Correntes** (Environment Artist; `catacomb_hall.gd` `_depths`; `arena_kit.gd` `chain`, `LINK_*`)
- Hoje viram tracinhos pretos encostados no topo da tela (ancoradas alto demais). Na pintura três correntes grossas
  cruzam o quarto de cima à esquerda, escuras contra a bruma.
- Alvo na tela da vitrine: corrente A entra pela borda esquerda em y 200 a 230 e chega ao ombro da estátua gigante
  perto de (290, 150); corrente B sai do alto da estátua perto de (400, 90) e sobe até a borda de cima em x 600 a
  700; corrente C vai de (520, 140) com barriga até perto de (650, 135) e sobe até a borda de cima em x 830 a 900.
  Elos de 0,9 a 1,1 m (cerca de 33 px na tela), arame de 0,12 m; ferro escuro Color(0.06, 0.065, 0.07), metálico
  0,8, rugosidade 0,5. Baixar as âncoras e aumentar a barriga até bater.
- Aceite: as três correntes visíveis inteiras no quadro, cada uma com 8 ou mais elos legíveis.

**P1-9. Estandartes** (Environment Artist; `catacomb_hall.gd` `_facade`, hoje `banner_thin_red` do KayKit)
- Hoje curtos e cortados no topo. Na pintura: compridos, carmim, borda dourada, ponta em V com borla.
- Alvo: pano de 1,5 x 5,0 m mais a ponta em V de 0,6 m, preso a y `DAIS_Y` + 8,5 na frente do contraforte, com
  barra no topo; QuadMesh subdividido com leve ondulação no vértice; albedo Color(0.5, 0.08, 0.12), borda de 0,08 m
  Color(0.75, 0.55, 0.2), borla dourada. Sem símbolo (cânone pendente com o Daniel).
- Aceite: estandarte da esquerda de x 1035 a 1095 com a ponta em y 150 a 170; o da direita de x 1575 em diante, ponta
  perto de y 290; mediana entre #5a1a30 e #702040, brilhos >= #a03020.

**P1-10. Multidão legível como na pintura** (dono a definir pelo Game Director: `scripts/render/crowd_renderer.gd`
`CROWD_*`)
- Hoje os esqueletos parecem gesso cinza translúcido, sem contraste interno. Na pintura: osso marfim (#e6dccb nos
  brilhos) com sombras e armadura marrom escuras.
- Alvo inicial (validar com `--stress=150`): `CROWD_FLAT` 0,45 para 0,25, `CROWD_LIFT` 0,45 para 0,2, `CROWD_SHADE`
  para Color(0.86, 0.82, 0.74), `CROWD_GREY` 0,92 para 0,7.
- Aceite: cada inimigo com luminância média pelo menos 2 vezes a do chão em volta e com partes escuras visíveis
  dentro da silhueta; leitura confirmada pelo QA com 150 inimigos.

### P2: acabamento

- Manchas vermelhas no chão (pétalas ou cera vermelha, nunca poça de sangue): 8 a 10 grupos de 0,8 a 1,5 m, 5 a 15
  manchas de 0,06 a 0,15 m, albedo Color(0.45, 0.06, 0.05); na pintura perto de (1360, 660), (1250, 560), (930, 490),
  (250, 600) e (380, 330). `catacomb_floor.gdshader`.
- Escada do altar: quina de cada degrau clareada (x1,3) e lascada; pedestais com urna ao lado da escada, como na
  pintura (`_dais`).
- Fachada: ressaltos e nichos rasos nos contrafortes (caixas recuadas de 0,15 m) para quebrar o plano.
- Lajes do patamar de entrada e do altar com o mesmo shader e as mesmas regras de P1-1.
- Pedra: trocar o tom violeta do `masonry.gdshader` (multiplicador Color(1.08, 0.95, 1.15)) por um frio leve
  (0,95; 1,0; 1,04); o violeta da pintura vem da luz do abismo, não da pedra.
- Conferir tudo no navegador (`DRIVER=opengl3`): mesmas faixas de p5, p50 e p95 com tolerância de 10%.

### O que não dá para fazer sem modelos novos

- Estátuas esculpidas com rosto, mãos e dobras da pintura: o manto procedural (P1-4) aproxima a silhueta e o valor,
  não a escultura.
- Relevos, gárgulas e cantaria esculpida da fachada: só volumes, juntas e nichos.
- Herói e inimigos da pintura (o guerreiro de escudos com chifres, os esqueletos de lá): são outros modelos; o nosso
  herói é o "Sombra" do Meshy e os inimigos seguem o KayKit.
- Lascas e pedra quebrada no nível de detalhe da pintura: CSG e caixas tortas chegam perto de longe, não de perto.
- Símbolo dos estandartes: cânone pendente com o Daniel.

### HUD na comparação

- A barra escura de 8 px no topo da tela (fundo da barra de experiência, `xp_back` em `scripts/ui/hud.gd`) cobre o
  alto da cena e não existe na pintura; o jogo não tem mais experiência. Pedido para o UI/UX Designer: remover ou
  esconder.
- O resto do HUD fica nas linhas que as métricas já ignoram (y < 60 e y > 820).

### Checklist de revisão (cada ciclo)

1. Captura da vitrine sem `--bot` e captura em luta, 1672 x 941; lado a lado com a referência.
2. `art_metrics.py` nas duas: as oito linhas da tabela global dentro da faixa.
3. Composição: braseiros, obeliscos, escada, portal, estandartes, correntes e estátua gigante a menos de 40 px das
   posições da pintura; nada importante cortado pela borda.
4. Abismo: bruma petróleo mais clara que a pedra, silhuetas em camadas, violeta só nas laterais e embaixo.
5. Medalhão: rosa dos ventos de 8 pontas, anéis duplos com ornamento, nenhum desenho de ritual.
6. Portal: vão retangular estourado em verde, janela em losango, verde na escada e no chão molhado, fachada escura.
7. Massa das peças: obeliscos grossos e rombudos, pilares de balaustrada com tampa, braseiros em pedestal, potes e
   velas do tamanho da pintura.
8. Chão: lajes quase quadradas e variadas, juntas escuras, sem serrilhado, poças com reflexo.
9. Leitura do combate: herói, inimigos, barras e avisos no chão legíveis sobre o chão mais escuro e sobre o verde.
10. Navegador: mesma captura com `DRIVER=opengl3`.
11. Registrar em `docs/art/visual_review.md`: data, capturas, o que bate, o que difere, pedidos com valores.
