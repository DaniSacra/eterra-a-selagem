# Ciclo 6: cenário mais perto da pintura (especificação, 2026-11-15)

Autor: Art Director (ciclo rodado no modelo Fable, experimento do Daniel para comparar com o ciclo 5). Nada aqui foi
implementado. Dono de tudo abaixo: **Environment Artist** (`scripts/game/catacomb_hall.gd`, `arena_kit.gd`,
`masonry.gd`, `assets/shaders/` do cenário, bloco de ambiente de `game.gd`). Meta:
`docs/art/ref/arena_catacumbas_1672.png` (fora do git).

**Fora do escopo:** personagens e inimigos (outro agente está trocando pelos modelos do Meshy), HUD, gameplay,
colisão, câmera, Meshy e qualquer serviço pago, subir o brilho geral (exposição, ambiente).

Ordem de impacto na semelhança: A (abismo), B (fogo e velas), C (medalhão), D (luz), E (o que o ciclo 5 não cobriu).

## 0. Evidência e linha de base

Capturas reais na placa do Daniel (RTX 5060 Laptop, Vulkan Forward+, 1672 x 941, `--seed=5`), por `tools/gpu.sh shot`,
na árvore de trabalho sobre o HEAD `5694624` (o `gpu.sh` espelha a árvore: havia mudanças sem commit de outros
agentes em `scripts/ui/` e `scripts/render/mesh_slim.gd`; nenhum arquivo de cenário estava alterado). Pasta (fora do git):
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/c6/ad/`

| Arquivo | Comando (depois de `shot <saída>`) | Observação |
|---|---|---|
| `vitrine.png` | `--showcase --seed=5 --shot-at=4` | enquadramento da pintura |
| `luta.png` | `--bot --autopick --seed=5 --shot-at=9` | câmera de jogo (distância 54) |
| `medalhao.png` | `--showcase --cam-dist=32 --seed=5 --shot-at=2` | **2 s, não 4**: aos 4 s o herói leva um golpe e o clarão vermelho com aberração cromática cobre a tela (a captura de 4 s não serve para medir) |
| `crop_topleft.png`, `crop_left.png`, `crop_fire.png`, `crop_facade.png`, `crop_east.png`, `crop_med.png`, `crop_candle.png`, `crop_runes.png`, `ref_tl2.png` | recortes pintura (em cima ou à esquerda) contra a captura | |
| `gpu_base.txt` | sonda de desempenho (seção F) | |

Scripts de medida (mesma pasta, mais `.../scratchpad/tools/c5flat.py` e `c5d.py` do ciclo 5; todos rodam com
`python3 -I`, só precisam de ffmpeg): `m6.py` (`g` percentis globais, `fire` e `det` por caixa), `q6.py` (parcelas de
cor por caixa), `wax.py` (velas), `flat6.py` (janelas chapadas com a posição). O scratchpad pode ser apagado: os
predicados estão escritos nos critérios abaixo para refazer.

**Atenção à comparação com o ciclo 5:** os números do ciclo 5 saíram do Vulkan por software (llvmpipe). Na placa a
mesma cena dá p95 107,3 (era 104,4) e 11 janelas chapadas na vitrine. **Tudo neste ciclo é medido só em captura da
placa**; não comparar com os números antigos.

Linha de base (pintura entre parênteses):

| Medida | Vitrine | Luta |
|---|---|---|
| Global p50 / p95 / p99 (`art_metrics.py`) | 43,7 / 107,3 / 168,0 (45,5 / 116,2 / 201,0) | |
| Parcela L > 150 / L > 200 (`m6.py g`) | 1,9% / 0,38% (2,8% / 1,08%; sem o corte de luz do herói 2,4% / 0,81%) | 1,6% / 0,39% |
| `warm_hot_px` | 0,005 (0,009) | |
| Critérios globais do ciclo 3 / regiões do ciclo 4 | 8 de 11 / 7 de 13 | |
| Faixa alta (0,0)-(1672,300): chapadas / detalhe / L < 25 | 11 de 748 / 9,14 / 29,5% (3 / 10,48 / 26,1%) | 21 / 7,56 / 29,3% |
| Esquerda (0,120)-(250,600): detalhe / L < 25 | 6,26 / 31,8% (6,29 / 22,6%) | 5,58 / 38,4% |
| Bruma alta (440,0)-(760,120): média L / desvio / detalhe | 37,1 / 16,4 / 5,41 (58,1 / 27,1 / 7,90) | 32,9 / 17,4 / 4,59 |
| Azul saturado acima de y 160, (0,0)-(1050,160) | 3,0% (0,0%) | 2,9% |
| Azul sob o arco central (500,190)-(660,330) | 2,5% (35,3%) | |
| Azul na coluna esquerda (0,250)-(260,700) | 2,5% (16,2%) | |
| `abyss_left_cols`: detalhe / mediana | 4,19 / #0e1d34 (5,58 / #132a50) | |

"Azul saturado" = `B > R + 60 e B > G + 40 e B > 130`. "Chapada" = janela de 48 x 48 (passo 24) com desvio de L < 4 e
média > 35. "Detalhe" = média do módulo do laplaciano de L.

## A. Abismo e arquitetura distante (prioridade 1)

### Diferença observada
Pintura (`ref_tl2.png`, coordenadas na imagem de 1672 x 941):
- **Massas irregulares, não uma arcada**: (1) ponte oeste, tabuleiro em y 200 a 235 de x 0 a 290, com uma torre de
  três blocos empilhados que diminuem (x 120 a 195, y 125 a 200), um cubo solto (x 45 a 100, y 195 a 225), arcos
  escuros embaixo (x 185 a 270, y 245 a 330) e a lanterna (centro em (133, 280), lanceta de 30 x 47 px, laranja
  #fca745 no pé); (2) portão central, bloco de x 440 a 705 com topo em y 165 a 185, um arco largo de ponta (x 515 a
  630, y 185 até sumir atrás da balaustrada) com **violeta dentro dele** e um arco menor à esquerda (x 430 a 470,
  y 215 a 290); (3) pilone de ferro que segura as correntes, x 465 a 505, y 0 a 120, pousado no portão.
- **Fundo em camadas de bruma**: torres de blocos apagadas em x 590 a 690, y 0 a 130 e x 715 a 760, y 60 a 130;
  fustes finos e estalactites em x 410 a 440, y 0 a 60 e x 545 a 560, y 30 a 110; teto de caverna quase preto no canto
  (x 0 a 110, y 0 a 180; x 150 a 280, y 0 a 110). A bruma é clara (mediana #094256, claros #16788b), mais clara em
  x 290 a 420, y 0 a 90 e x 540 a 600, y 60 a 130.
- **Violeta só embaixo**: dentro dos arcos e na coluna esquerda abaixo de y 250. Acima de y 160 não há azul nem violeta.

Jogo (`vitrine.png`, `luta.png`, `crop_topleft.png`):
- Quatro planos de pilares iguais, igualmente espaçados, com arcos de ponta iguais: lê como nave de igreja inteira,
  não como ruína. O pilar do plano próximo em x 440 a 560 (vitrine, y 0 a 250; na luta y 0 a 290) é a peça mais clara
  e nítida da faixa alta, onde a pintura tem o portão escuro e largo.
- **Faixas verticais de azul saturado** entre os pilares, de borda reta, até o topo da tela: na luta em x 110 a 135,
  320 a 360, 590 a 640, 790 a 830 e 1050 a 1080 (janelas chapadas em (600,0), (600,168), (624,192), (1056,96) a
  (1056,192), (144,192), (168,216)); na vitrine em (744,0), (792,96), (984,96), (600,144), (216,144 a 192).
- Fundo petróleo liso e escuro (mediana #062a3a contra #094256), sem silhuetas apagadas nem teto de caverna.
- Lanterna em (175, 268), amarela (#ad861e nos claros, R - G = 39) com grade; a da pintura é laranja (R - G = 85).

### Solução: combinação (geometria perto, cartões pintados por shader longe)
Avaliação das quatro opções pedidas:

| Opção | Veredito |
|---|---|
| Só geometria `Masonry` | Boa para o plano próximo (a câmera de jogo anda e a paralaxe aparece), cara e dura para o fundo: mais pilares finos = mais primitivas e o mesmo ritmo regular. |
| Só cartões com silhueta por shader | Leve e com contorno livre (blocos, ameias, estalactites), mas chapado de perto: o plano próximo perderia volume e a luz da lanterna. |
| Textura CC0 | **Descartada.** Não há no repositório nem conheço textura CC0 de silhueta de ruína gótica pintada; foto destoaria da pintura e exigiria baixar, conferir licença e registrar. A única textura externa continua sendo a `rock_surface` (Poly Haven, CC0, já em `docs/art/asset_credits.md`), que pode dar grão ao plano próximo pelo `depth_stone` se o Environment Artist quiser; nenhuma textura nova. |
| **Combinação** | **Escolhida:** A1 + A2 + A3 abaixo. Nada de IA, nada pago, nada a declarar na Steam. |

**A1. Plano próximo em geometria (`_depths`, substitui os planos 0 e 1 de `ROW_*`).** Três massas, não uma fileira,
com o `depth_stone` de hoje. Posição pela mesma conta do código (`eye + ahead * d + right * lat * d`); a parcela
lateral sai do x de tela: `lat = (x - 836) / 836 * 0,378`.

| Massa | Caixa na vitrine | `lat` (d cerca de 68 a 76) | Forma |
|---|---|---|---|
| Ponte oeste | x 0 a 290, topo do tabuleiro y 200 a 235 | -0,378 a -0,247 | tabuleiro de 1,2 m, dois arcos de ponta embaixo, torre de 3 blocos (larguras 100%, 78%, 58%), cubo solto, parapeito quebrado; a parede da lanterna sob ela |
| Portão central | x 440 a 705, topo y 165 a 185 | -0,179 a -0,059 | bloco largo com 3 a 4 ameias desiguais, arco de ponta com 115 px de vão na vitrine (cerca de 3,6 m a 70 m do olho: 941 px cobrem 0,425 x d metros), arco menor a oeste, uma quina lascada |
| Pilone das correntes | x 465 a 505, y 0 a 120 | -0,168 a -0,150 | torre fina (o `TOWER` de hoje, reposicionado sobre o portão); as correntes passam a sair dele |

Sem pilar isolado claro em primeiro plano: nenhuma peça do abismo com média de L acima de 45 na faixa x 400 a 600,
y 0 a 250 da vitrine (hoje o pilar próximo passa disso).

**A2. Fundo em três cartões de silhueta (`assets/shaders/abyss_ruins.gdshader`, novo; `ArenaKit.ruin_card`).**
Substituem os planos 2 e 3 de `ROW_*` e a faixa lisa atrás.
- Três quadriláteros fixos (não giram para a câmera: a paralaxe entre eles é o que dá profundidade quando a câmera de
  jogo anda), perpendiculares ao `ahead` da vitrine, a cerca de 100, 125 e 155 m do olho. Largura e altura para que
  nenhuma borda apareça com a câmera de jogo em qualquer canto da sala (ordem de 200 x 70 m; conferir).
- O shader desenha a silhueta em coordenada do cartão, por colunas com sorteio (`hash` da coluna): torre presente em
  cerca de 55% das colunas, feita de 2 ou 3 blocos empilhados que estreitam, topo reto, lascado ou com ameia; arco de
  ponta ou tabuleiro quebrado ligando torres vizinhas em cerca de 35% dos vãos; no cartão mais distante, estalactites
  e teto de caverna descendo do alto, mais fechado a oeste (o canto escuro da pintura). Larguras de coluna diferentes
  por cartão (por exemplo 9, 6,5 e 5 m) e deslocadas, para não alinhar.
- Cor por cartão: pedra #0a1c26 misturada à bruma (`Game.FOG` clareada) em 35%, 55% e 75%, do mais próximo ao mais
  distante; juntas de fiada a 8% de valor; aresta fria #16788b a 25% no topo dos blocos. O pé afunda na bruma (some
  abaixo de y -6 m).
- Sem luz, sem névoa (`unshaded, fog_disabled`), **recorte por alfa (`ALPHA_SCISSOR_THRESHOLD`) na passada opaca**,
  não mistura: custa um teste de profundidade, sem sobredesenho transparente. Ruído de valor barato (o `hash1` e o
  `noise` que os shaders do abismo já têm; no máximo 3 oitavas).
- Os bancos de bruma (`MIST_BANKS`) ficam entre os cartões; o véu (`VEIL`) atrás de tudo.

**A3. Bruma e violeta.**
- Véu mais claro e manchado atrás de tudo: alvo na caixa (440,0)-(760,120) da vitrine média de L 48 a 62, desvio
  >= 22 (hoje 37 e 16). Caminho provável: `VEIL_LIGHT` 1,6 para cerca de 2,4, `VEIL_ALPHA` 0,16 para cerca de 0,3,
  duas manchas mais claras nas posições da pintura. O p50 global não pode sair de 42 a 50.
- Violeta: os cartões de `abyss_glow` não passam de y de tela 160 em x < 1050. `GLOW_TOP` 0 para cerca de -4 e
  `reach` menor nos cartões largos (`GLOW_LATS`); um cartão dentro do arco do portão central e outro no arco menor;
  coluna esquerda com mais energia baixa (`GLOW_WEST`). Cor mais violeta que azul: `ABYSS_GLOW` (0.4, 0.3, 0.75) para
  cerca de (0.5, 0.3, 0.8) (a pintura tem #7b54d7 nos claros da esquerda).
- Lanterna: centro em (133 +- 12, 280 +- 12) na vitrine (`LANTERN_LAT` de -0,33 para cerca de -0,35), vidro laranja
  (`LANTERN_GLASS` para cerca de (1.3, 0.62, 0.2), `LANTERN_TOP` 0,5), sem grade clara: só 1 travessa e 1 montante
  escuros; halo maior (`LANTERN_HALO` 0,5 para 0,9).

### Arquivos
`scripts/game/catacomb_hall.gd` (`_depths`, `_pier`, `_arch`, `_bridge`, `_aqueduct`, `_lantern`, constantes `ROW_*`,
`GLOW_*`, `VEIL*`, `MIST_*`, `TOWER*`, `LANTERN*`), `scripts/game/arena_kit.gd` (`abyss_glow`, `mist_bank`,
`ruin_card` novo, `ABYSS_GLOW*`), `assets/shaders/abyss_ruins.gdshader` (novo), `abyss_glow.gdshader`,
`abyss_mist.gdshader`, `depth_stone.gdshader`.

### Aceite (captura na placa, vitrine e luta deste documento)
| Medida | Hoje | Aceite |
|---|---|---|
| Janelas chapadas, faixa (0,0)-(1672,300), vitrine / luta (`c5flat.py`) | 11 / 21 | <= 5 / <= 8 |
| Detalhe da faixa alta, vitrine / luta (`c5d.py`) | 9,14 / 7,56 | >= 10,0 / >= 9,0 |
| Azul saturado em (0,0)-(1050,160), vitrine e luta (`q6.py`) | 3,0% / 2,9% | <= 0,3% |
| Azul saturado sob o arco central (500,190)-(660,330), vitrine | 2,5% | >= 20% |
| Azul saturado na coluna esquerda (0,250)-(260,700), vitrine | 2,5% | >= 10%; `violet_left` >= 0,06 mantido |
| Bruma alta (440,0)-(760,120), vitrine: média / desvio / detalhe (`m6.py det`) | 37,1 / 16,4 / 5,41 | 48 a 62 / >= 22 / >= 6,5 |
| Esquerda (0,120)-(250,600): L < 25, vitrine / luta | 31,8% / 38,4% | <= 26% / <= 32% |
| `abyss_left_cols`: detalhe; mediana | 4,19; G = R + 15 | >= 5,0; G >= R + 20 e B >= R + 25 |
| Lanterna: posição; cor dos claros (os 200 pixels mais claros de (90,240)-(180,320)) | (175,268); R - G = 39 | (133 +- 12, 280 +- 12); R - G >= 70, R >= 235 |
| Silhuetas | regulares | em recorte 2x da faixa alta, contar pelo menos 3 topos de torre de alturas diferentes atrás do plano próximo e nenhuma sequência de 3 pilares iguais com o mesmo vão |
| Bordas de cartão | faixas retas | nenhuma borda reta de cartão em 4 capturas de luta com o herói em cada canto da sala, nem em `--start=boss --bot --autopick --shot-at=12` (o B3 do relatório de QA) |

### Não pode piorar
Correntes no lugar (saem do gigante, passam pelo pilone e chegam à fachada); `violet_right` (hoje 0,014, já abaixo da
meta de 0,03: não cair; se subir sem virar painel, melhor); navegador (`DRIVER=opengl3`): nenhuma peça faltando, os
cartões aparecem (sem `FogVolume` lá); primitivas da vitrine não sobem (os planos 2 e 3 saem: devem cair).

## B. Fogo e velas (prioridade 2)

### Diferença observada (`crop_fire.png`, `crop_east.png`, `crop_candle.png`)
Miolo "quase branco" = `R > 240 e G > 215 e B > 120`; "quente" = `L > 170 e R >= G >= B e R - B > 60` (`m6.py fire`).

| Braseiro (caixa na vitrine) | Quente / miolo / L máximo no jogo | Na pintura (caixa dela) |
|---|---|---|
| Noroeste, do gigante (340,120)-(440,230) | 419 / **0** / 217 | 588 / 355 / 251 |
| Norte (850,70)-(940,160) | 916 / 306 / 251 | 587 / 263 / 254 em (850,60)-(930,150) |
| Leste (1580,430)-(1672,540) | **0 / 0 / 145** | 838 / 275 / 251 em (1580,440)-(1672,560) |
| Sudeste (1310,590)-(1420,700) | 1018 / **0** / 212 | 1367 / 529 / 251 em (1350,590)-(1460,700) |

- A chama do jogo é um pente de 4 a 6 espetos finos separados, com cerca de 20 x 30 px; a da pintura é um corpo só, em
  gota, de cerca de 40 x 55 a 70 px (1,5 a 1,9 m), com miolo quase branco em cerca de 40% da área, borda laranja e
  fagulhas acima. O miolo do jogo só aparece quando as partículas coincidem (1 braseiro em 4 nesta captura).
- O braseiro leste quase não acende (L máximo 145): parece um disco laranja lavado, sem línguas.
- A taça do jogo tem cerca de 45 px de boca e lê como um disco laranja inteiro; a da pintura tem cerca de 62 px, é
  bronze escuro por fora e só a borda de dentro e as brasas brilham.
- Velas: no jogo finas (cerca de 8 px de largura, raio 0,07 a 0,11 m), todas parecidas, amarelas com o lado de sombra
  **oliva** (#9b9951 em (60,530)-(190,600), 473 pixels oliva; a pintura tem 0). Na pintura são círios grossos (até
  20 px de largura, raio até 0,25 m, alturas de 0,3 a 1,2 m, o mais alto é o mais grosso), creme #fcf6b0 na luz e
  âmbar na sombra (média dos claros #f7c355, R - G = 52; no jogo #dbc060, #dbd171 e #9e9e59, R - G de 27, 10 e 0),
  chama com miolo branco e borda laranja, cera escorrida em poça larga.
- O chão a oeste fica claro demais com as velas: `floor_clean_b` média 66,3 contra 50,1.

### Alvo
**B1. Chama do braseiro (`ArenaKit.fire`, `_flames`, `tongue`, constantes `FLAME*`, `HEART*`, `TONGUE`,
`BRAZIER_FIRE`).**
- Miolo **fixo**, não partícula: um cartão de língua de cerca de 0,45 x 0,9 m, cor por volta de (2.6, 2.3, 1.4), que
  tremula por escala (+-12%, 9 a 13 Hz, fase diferente por braseiro). Garante o miolo em todo quadro.
- Línguas de fora maiores e sobrepostas: `BRAZIER_FIRE.z` 0,4 para cerca de 0,62, `TONGUE` (0.75, 1.7) para cerca de
  (0.9, 2.0), raio de emissão `radius * 0.6` para cerca de `radius * 0.35`, quantidade 36 para cerca de 28. Altura
  total da chama 1,4 a 1,8 m (52 a 67 px na vitrine).
- Fagulhas: 6 para cerca de 10, subindo até 1,5 m acima da chama.
- Taça: boca `BRAZIER_BOWL.x` 0,65 para cerca de 0,85 (só o desenho; `BRAZIER_RADIUS` da colisão **não muda**),
  parede de fora escura (bronze, sem emissão), brilho só na borda de dentro e nas brasas (`RIM_GLOW`, `COALS`).
- Braseiro leste: achar por que não acende (névoa, máscara, posição) e deixá-lo igual aos outros.

**B2. Velas (`Masonry.candle`, `WAX`, `WAX_GLOW`, `CANDLE_FLAME`, `CANDLE_FIRE`; `CatacombHall._candles`,
`CANDLE_*`).**
- Proporção: `CANDLE_RADIUS` (0.07, 0.11) para (0.12, 0.22), `CANDLE_HEIGHT` (0.3, 0.9) para (0.3, 1.1), raio
  crescendo com a altura; por grupo 1 alta, 1 ou 2 médias, 1 ou 2 tocos (3 a 5 velas, não 5 iguais); poça de cera
  1,8 vez o raio.
- Cor: `WAX` (0.95, 0.7, 0.5) para creme, cerca de (1.0, 0.86, 0.62); `WAX_GLOW` (0.12, 0.05, 0.015) para cerca de
  (0.42, 0.2, 0.07), mais forte no topo que no pé (cor por vértice), para a sombra ficar âmbar e não oliva sob o
  ambiente petróleo.
- Chama: miolo quase branco (cerca de (2.6, 2.0, 1.1)) dentro da língua laranja de hoje; `CANDLE_FLAME` 0,3 para 0,34.
- Poça de luz menor: `CANDLE_LIGHT` 2,6 para cerca de 1,8 e `CANDLE_RANGE` 3,5 para cerca de 2,8.

### Aceite
| Medida | Hoje | Aceite |
|---|---|---|
| Miolo por braseiro, nos 4, em 3 vitrines (`--shot-at=3`, `4` e `5`) | 0 / 306 / 0 / 0 | >= 150 px em cada um, em cada captura |
| Quente por braseiro; L máximo | 419 / 916 / 0 / 1018; 217 / 251 / 145 / 212 | >= 550 cada; >= 245 cada |
| Altura da chama, braseiro noroeste (px na vitrine, do topo da taça à ponta) | cerca de 30 | 50 a 70 |
| `warm_hot_px` (vitrine) | 0,005 | 0,007 a 0,012 |
| Velas: pixels oliva (`70 < L <= 200, G >= R - 12, G > B + 35`) nas caixas (400,340)-(470,390), (260,390)-(345,450), (535,660)-(630,760), (1290,680)-(1330,720), (60,530)-(190,600) (`wax.py`) | 0 / 15 / 0 / 0 / 473 | 0 em todas |
| Velas: média dos claros (L > 150) em cada caixa | R - G de 40, 27, 34, 10, 0 | R - G >= 35 e R >= 235 em todas |
| Largura do círio mais grosso do grupo sudoeste (535,660)-(630,760) | cerca de 8 px | >= 14 px |
| `floor_clean_b` média | 66,3 | 48 a 58 |
| `east_brazier` warmhalo | 0,133 | <= 0,16 (mantido) |

### Não pode piorar
Halo dos braseiros sem aumentar (a língua mantém a forma: o brilho só amacia); a luz que os braseiros jogam no chão
(`BRAZIER_LIGHT`, alcance) igual; avisos vermelhos no chão perto dos braseiros tão legíveis quanto em `luta.png`; a
multidão continua fora da luz das velas (`~Arena.CROWD_LAYER`).

## C. Medalhão (prioridade 3)

### Diferença observada (`crop_runes.png`, `medalhao.png`, `crop_med.png`)
- A 32 m, no arco de baixo da faixa (600,610)-(960,680), as runas têm traço de cerca de 2 px e só 16 de L abaixo da
  pedra (traço 47 a 52 contra mediana 64 a 69): dois ou três riscos soltos, não uma inscrição. A 60 m (`vitrine.png`,
  (640,520)-(960,585)) não se vê nenhuma. Motivo provável: `rune_stroke` 0,05 m dá menos de 2 px a 60 m, e
  `rune_size` 0,3 deixa cada glifo com um terço da faixa.
- Registro, sem pedido de mudança neste ciclo: o anel do jogo tem cerca de 354 px de diâmetro na vitrine contra cerca
  de 287 px na pintura, e a pintura é uma gravura de linhas ocre (estrela de oito pontas, dois círculos, desenho por
  dentro), não uma faixa de pedra mais clara. O chão no centro do jogo também é mais claro (mediana de L 69 contra
  cerca de 50 fora do clarão do golpe). O ciclo 5 escolheu a faixa esculpida e o Daniel ainda não a julgou.

### Alvo (`assets/shaders/catacomb_floor.gdshader`, função `medallion`; valores passados em `ArenaKit.floor_plate`)
- `runes` 32 para 24; `rune_stroke` 0,05 para 0,10; `rune_size` 0,3 para 0,6; `rune_dark` 0,6 para 0,85;
  `rune_worn` 0,3 para 0,2, e o desgaste apaga pedaços do traço, não o glifo inteiro.
- Cada traço ganha um lábio claro de cerca de 0,03 m no lado oposto à luz (`relief_light`, valor por volta de 1,25),
  como os chanfros da faixa: escuro mais claro lado a lado é o que lê como entalhe.
- Um fio de bronze gasto no fundo de 1 em cada 3 runas (`gold_dark`), sem brilho.
- Glifos continuam abstratos (riscos, barra, anel): nenhuma letra, número ou símbolo com significado (sem lore).

### Aceite
| Medida | Hoje | Aceite |
|---|---|---|
| `medalhao.png` (32 m, 2 s), arco de baixo (600,610)-(960,680): largura do traço; L do traço contra a mediana da faixa | 2 px; -16 | >= 4 px; <= -22 |
| Mesmo recorte ampliado 3x: glifos inteiros contáveis | 2 ou 3 riscos | >= 6 |
| Mesma caixa: parcela de pixels com L < mediana - 25 (`q6.py`, campo `dark`) | 14,3% | >= 20% |
| `vitrine.png` (60 m): traços de runa visíveis no anel inteiro | 0 | >= 8, com 2 px ou mais |

### Não pode piorar
Aviso vermelho contínuo sobre o medalhão (`luta.png`: o retângulo vermelho cruza o anel sem falha); nenhum vermelho
nem pixel com L > 150 no medalhão sem efeito por cima; o medalhão segue mais calmo que os inimigos (desvio de L da
caixa (560,430)-(980,600) de `medalhao.png` <= 24; hoje 20,3); as 16 juntas, os chanfros e as lascas do ciclo 5 ficam.

## D. Luz: brilhos (prioridade 4)

### Diferença observada
Na placa: p95 107,3 (pintura 116,2), p99 168,0 (201,0), L > 200 em 0,38% da tela (0,81% na pintura sem contar o corte
de luz do herói). O meio da curva bate (p50 43,7 contra 45,5; L < 20 em 14% contra 13%). **Falta só o topo**: a pintura
tem cerca de 1% da tela quase branca e o jogo não. De onde vem na pintura:
- Vão do portal (1270,110)-(1350,240): mediana de L 195 e 27,5% acima de 200, cor #33f953. No jogo mediana 163 e
  **0%** acima de 200, cor #33ca6b.
- Miolo dos fogos e das velas (seção B).
- Reflexo molhado no chão: laranja do braseiro norte e verde do portal em (1280,350)-(1340,420).
- Degraus e chão verdes mais puros: degraus claros #42f477 (jogo #25c7a2, G - B de 37 contra 125); chão verde claros
  #43be6b (jogo #6ec898, G - B de 48 contra 83).

### Alvo
- **Não mexer** em `EXPOSURE`, `AMBIENT`, `AMBIENT_ENERGY` nem `ADJUST_CONTRAST`. `GLOW_INTENSITY` pode ir de 0,45 a no
  máximo 0,55; `GLOW_THRESHOLD` fica.
- Portal (`portal.gdshader`, `ArenaKit.PORTAL_SHEET`): miolo mais claro embaixo e no centro (`mouth` 0,45 para cerca
  de 0,8, mancha central subindo até meia altura), cor para cerca de (0.3, 1.0, 0.4), variação interna maior (`wisp`
  0,15 para cerca de 0,22: o desvio da pintura é 64, o do jogo 42).
- Derrame verde (`SPILL_COLOR` (0.25, 0.95, 0.7) para cerca de (0.3, 1.0, 0.5)): menos ciano.
- Reflexo: a zona molhada (`WET`) já fica diante da escada; garantir um brilho especular laranja e um verde legíveis
  nela (`wet_roughness` 0,25 para cerca de 0,18 se for preciso).
- Fogos e velas: seção B.

### Aceite (`art_metrics.py` e `m6.py g` na vitrine)
| Medida | Hoje | Aceite |
|---|---|---|
| p95 | 107,3 | >= 108 |
| p99 | 168,0 | >= 182 |
| Parcela L > 200 | 0,38% | 0,6% a 1,1% |
| p50; L < 20 | 43,7; 14% | 42 a 50; 9% a 17% (não sobem) |
| `portal_open`: mediana de L; parcela L > 200; mediana G - R; desvio | 163; 0%; 151; 41,7 | >= 180; >= 15%; >= 150; >= 50 |
| `stairs` claros G - B; `floor_green` claros G - B | 37; 48 | >= 80; >= 60 |
| `green_spill_floor`; `facade` green | 0,181; 0,161 | 0,08 a 0,20; <= 0,20 |
| Critérios globais do ciclo 3 | 8 de 11 | >= 10 de 11 (o `violet_right` pode continuar falhando) |

### Não pode piorar
Luta (`luta.png`): p95 113,3 não passa de 120 (a sala não clareia); o herói e os inimigos seguem sendo o que mais
contrasta no chão; o verde do portal não toma a fachada inteira nem as estátuas (`statues_portal` green <= 0,25).

## E. Diferenças grandes que o ciclo 5 não cobriu (prioridade 5, na ordem)

**E1. Vão do portal é retangular; na pintura é um arco de ponta.** (`crop_facade.png`) Mesmo tamanho (jogo x 1275 a
1381, y 89 a 233; pintura x 1275 a 1369, y 94 a 237), mas o jogo tem verga reta com dentes pendurados e a folha de luz
é um retângulo. Alvo: a folha de luz recortada em arco de ponta (máscara no `portal.gdshader`: nascença a cerca de 62%
da altura, vértice no centro), verga reta (`PORTAL_LINTEL`) fora da vista, dentes (`PENDANTS`) acompanhando o arco.
Arquivos: `portal.gdshader`, `catacomb_hall.gd` (`_facade`, `PORTAL_*`, `PENDANTS`). Aceite: cantos de cima do vão,
(1277,92)-(1297,120) e (1360,92)-(1380,120), com verde claro (`G > R + 60 e L > 110`) em <= 10% (hoje 51% e 15%;
pintura 2% e 1%); vértice do arco visível. Não piora: as medidas de `portal_open` da seção D; o portal apagado
(sala não vencida) e o vermelho de Morvath usam a mesma máscara.

**E2. Estandartes curtos e fora do lugar.** Pintura: esquerdo em x 1030 a 1095, do topo até a ponta em y 165
(cerca de 1,7 x 4,6 m), vermelho #bd3b25 nos claros; direito em x 1578 a 1672, y 30 a 300, cortado pela borda; os dois
com barra em ponta, friso ocre e borla. Jogo: peça `banner_thin_red` do KayKit (provisória), esquerdo em x 1100 a
1150, y 0 a 72; direito em x 1600 a 1672, y 0 a 185, quase preto. Alvo: estandarte próprio (malha simples em
`ArenaKit` ou `Masonry`: pano com ponta, friso de 0,08 m em ouro velho, borla), 1,7 x 4,6 m, carmesim por volta de
(0.55, 0.10, 0.12) com emissão fraca para não ficar preto na luz fria nem verde no derrame do portal; pregas por
sombra em faixas verticais. **Emblema: nenhum por enquanto** (a pintura tem um símbolo; qual é o de Eterra é pergunta
para o Daniel, ver G). Arquivos: `catacomb_hall.gd` (`_facade`, linha do `banner_thin_red`), `arena_kit.gd`. Aceite:
vermelho (`R > G + 50, R > B + 30, R > 110`) em (1040,0)-(1100,170) >= 30% (hoje 0%; pintura 37%) e em
(1570,0)-(1672,300) >= 4% (hoje 0%; pintura 5,6%).

**E3. Estátua gigante: laranja inteira, estreita e lisa.** Pintura: x 290 a 400 (110 px), a cabeça encosta no topo
(y 0 a 235); pedra escura neutra (mediana de #161214 a #221d1d, conforme a caixa) com o quente só na frente, na face
virada para o braseiro; capuz com vão escuro, ombros, mãos juntas no peito, pregas. Jogo: x 285 a 355 (70 px), y 40 a
240, mediana #2d130b a #4c220e (laranja saturado no corpo todo), forma de pino torneado. Alvo com o que há
(`Masonry.hooded_statue`, `_build_statue`, `GIANT`, `GIANT_TINT`, `GIANT_UPLIGHT`): altura `GIANT.z` 7,0 para cerca
de 8,3 e ombros cerca de 1,4 vez mais largos; vão escuro no capuz; mangas unidas no peito (dois volumes); pregas mais
fundas (`pleat`); luz quente só de um lado (a luz de baixo `GIANT_UPLIGHT` 2,5 para cerca de 1,2, com alcance curto).
Vale para as quatro estátuas (mesma malha). **Provisório**: a figura esculpida de verdade é o item 1 do
`meshy_asset_plan.md`. Aceite: caixa da estátua na vitrine com >= 100 px de largura e topo em y <= 10; `statue_nw`
(300,20)-(400,220) mediana com R - B <= 20 e L de 20 a 40 (hoje R - B = 62), claros (bright10) ainda quentes
(R - B >= 90). Não piora: `statues_portal` green <= 0,25 e detalhe (hoje 8,75; subir para >= 10 se as pregas saírem).

**E4. Pedestal do gigante parece um prédio de tijolo.** Jogo: plataforma larga x 250 a 540, y 235 a 330, com o topo
claro e fiadas regulares. Pintura: pilha de blocos brutos x 245 a 440, y 220 a 340, escura, subindo do abismo. Alvo:
`_north_west` / `_west` (`NW_PIER`): topo visível mais estreito (cerca de 195 px na vitrine), blocos grandes e
desiguais (3 ou 4 por face), topo sem luz direta (média de L da face de cima <= 45). Atenção: se o `NW_PIER` for chão
andável ou colisão, **só o desenho muda**; qualquer mudança de pegada passa pelo Gameplay Engineer.

**E5. Caixotes do KayKit com moldura azul clara.** Em (675,195)-(725,235) e (1355,325)-(1415,385) da vitrine: a
moldura branca azulada é a coisa mais clara e fria daquele canto e não existe na pintura (caixotes de madeira escura
com ferragem, #3a2c26). Alvo: caixote próprio em `Masonry` (caixa chanfrada, tábuas por sombra, cantoneiras escuras)
ou a peça do KayKit com material trocado; madeira por volta de (0.22, 0.15, 0.11). Arquivos: `catacomb_hall.gd`
(as quatro chamadas de `kit.piece("box_small", ...)`), `arena_kit.gd` (`STONE_PIECES` ou material novo). Aceite: em
recorte 3x, nenhum pixel do caixote com L > 110 e B > R. A colisão do caixote sólido (o do leste, `solid` 0,7) não muda.

**E6. Monte de entulho ao pé da escada do altar.** Jogo: monte escuro e pontudo em (1035,215)-(1105,280). Pintura:
nesse lugar há caixotes baixos, potes e velas (955 a 1075, y 200 a 250). Alvo: trocar o desenho por 2 caixotes baixos
(E5), 1 pote e um grupo de 3 velas, **na mesma pegada de colisão** (se a peça for sólida, a caixa de `Arena.boxes`
fica como está).

**E7. Potes de barro saturados demais.** Jogo laranja vivo; pintura terracota escura com sombra. `Masonry.pot`: cor
para cerca de (0.45, 0.18, 0.10), sem emissão. Sem métrica: conferir no recorte `crop_fire.png` refeito.

**O que já bate e não deve mudar:** posição do portal, da escada larga e do derrame verde; balaustradas e postes;
obeliscos (o do sul está um pouco claro, média 33,4 contra 24,5: aceitável); correntes (traçado e grossura); escadas
leste e sul; chão de lajes.

## F. Orçamento de desempenho

Limite: **no máximo +0,5 ms por quadro na luta**, medido na placa.

Como medir: a linha `RESULT` do `tools/gpu.sh shot` traz `fps`, mas ele **fica travado em 60** (a janela roda com
sincronismo vertical; foi 60,0 nas três capturas deste documento e 11 na de 2 s, por causa da compilação de shaders).
Serve para ver se caiu de 60, não para medir 0,5 ms. A medida do orçamento é a sonda do QA, sem sincronismo:

```
tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 --fixed-fps 30 --disable-vsync \
  -s C:/Users/danie/tools/qa/gpuperf.gd -- --nosave --seed=5 --bot --autopick
```

(imprime `GPUPERF frame_ms [median ...] gpu_ms [...] draw_calls ... primitives ...`; descarta 300 quadros e mede 300).

Linha de base na mesma árvore de trabalho (HEAD `5694624` mais interface em andamento), três rodadas (`gpu_base.txt`):

| Cena | Quadro (mediana das 3 medianas; as 3) | GPU | Chamadas de desenho | Primitivas |
|---|---|---|---|---|
| Luta `--bot --autopick` | **2,77 ms** (2,58 / 2,93 / 2,77) | 2,40 | 986 | 678 mil |
| Vitrine `--showcase` | **0,96 ms** (0,96 / 0,98 / 0,95) | 0,92 | 62 | 65 mil |

Regras:
- Antes e depois medidos **na mesma sessão, em rodadas alternadas** (3 de cada), como o QA fez no ciclo 5: entre
  sessões a mesma cena variou de 2,8 a 3,5 ms (o relatório do ciclo 5 mediu 3,48 no mesmo código); entre rodadas
  iguais, 0,35 ms. O "antes" roda de uma cópia do HEAD com `MIRROR=` (método em `docs/qa/latest_report.md`).
- Aceite: mediana das medianas da luta depois <= antes + 0,5 ms; vitrine depois <= antes + 0,3 ms; `RESULT` continua
  com `fps` 60 na luta e no `--stress=90`.
- Guardas de construção: primitivas da vitrine <= 70 mil (os planos 2 e 3 de pilares saem; os três cartões somam 6
  triângulos); chamadas de desenho da vitrine <= 70; nenhuma luz nova com sombra; no máximo 2 luzes novas sem sombra
  (arco do portão, lanterna já existe); os cartões de ruína na passada opaca (recorte por alfa), nunca três camadas
  transparentes de tela cheia; o miolo fixo dos fogos são 4 quadriláteros.
- Navegador: uma captura com `DRIVER=opengl3 tools/shot.sh` (CPU, minutos) para ver que nada falta. Desempenho no navegador não é meta deste ciclo.

## G. Validação, dependências e perguntas

Capturas de revisão (todas com `tools/gpu.sh shot`, 1672 x 941, `--seed=5`): as três da seção 0; vitrine também em
`--shot-at=3` e `5` (fogo); `--start=boss --bot --autopick --shot-at=12` (cartões a leste, portal vermelho com a
máscara nova); 4 de luta com o herói em cada canto (bordas de cartão); uma em `RES=1920x1080`; uma com
`DRIVER=opengl3 tools/shot.sh`. Rodar `python3 -I tools/art_metrics.py` e os scripts da seção 0 em cada vitrine.
Também `tools/check.gd`, `tools/test.sh` e `tools/smoke.sh 300 --seed=5` com a linha `RESULT` idêntica à de antes
(nenhum número de combate muda).

Ordem sugerida: A3 (violeta e bruma, só constantes) -> A2 (cartões) -> A1 (massas próximas) -> B1, B2 -> D -> C ->
E1, E2 -> E3 a E7. Medir a cada bloco: A e D se influenciam (a bruma mais clara mexe no p50).

Depende de modelo que não existe (não entra): estátua esculpida com rosto e mãos, moldura gótica do portal com
arquivoltas, obelisco lascado, braseiro de ferro com rebites, potes e caixotes pintados (`docs/art/meshy_asset_plan.md`,
itens 1 a 7; nada gerado, gerar exige o Daniel). O que este ciclo faz nessas peças é provisório.

Perguntas para o Daniel (pelo Game Director):
1. Qual é o emblema dos estandartes? A pintura mostra um símbolo; sem resposta ficam lisos (E2).
2. Medalhão: fica a faixa esculpida do ciclo 5 com runas mais fortes (seção C), ou ele prefere a gravura de linhas
   ocre da pintura, com a estrela de oito pontas vazando do anel menor?

Steam: nada novo a declarar (sem IA, sem recurso externo novo). Se alguma textura externa entrar, registrar antes em
`docs/art/asset_credits.md`.
