# Redesenho das salas, Lote B: Santuário Desmoronado A e B, Salão das Fendas A e B

- **Data**: 2026-11-18. **Autor**: art-director. **Para**: environment-artist, depois do Lote A.
- **Depende de**: a biblioteca do Lote A (`room_redesign_lotA_spec.md`, Parte 1: `style()`, `paint_look(style)`,
  `stylize_fires`, ar estilizado e F7, `backdrop`, urna, metal). Regras e aceite comum: `room_redesign_matrix.md` 0.3,
  0.4 e 4. Decisões: `room_redesign_decisions.md` (P-6: Fendas B pela ponte caída; sem céu de poente no Santuário B).
- Só STYLIZED; clássico igual; nada barra; nenhuma peça nova acima de 0,3 m no chão andável; Meshy zero.
- Conceitos (clima): `conceitos/08_santuario_A.png`, `09_santuario_B.png`, `04_fendas_A.png`, `05_fendas_B.png`.

## 1. Santuário Desmoronado (`SanctuaryLook`, layout `sanctuary`)

Planta real (`_sanctuary`, `make_data.gd`): contorno (-22; -14) a (22; 14) com cortes a nordeste e sudoeste; colunas da
nave em z -6 e 6 a cada 6 m (raio 0,65, 5,2 m; quebradas em (15; -6) 3,4 m e (-9; 6) 3,0 m), toco em (3; -6), tambores
(3; -6,9 a -9,8); sarcófagos contra a parede norte em x -12 e -4; bancos quebrados ao sul em x -12 e 6; braseiros dos
recessos da porta norte em x 4,3 e 8,7 (z -14,9); guardião em `boss_spawn` (-17; 0) diante da grade; herói entra a leste
(19,5; 2). B: buraco de x 0,6 a 9,4, z -3,5 a 3,5, com a cripta de baixo (`UNDER` 6 m). Paredes de 9 m ao norte e oeste,
janelas cegas em x -17,5, -10,5, -1, 11,5; pilastras em x -21, -14, -7, 2, 13.

### 1.1 Medida de hoje e alvo (quadro sem HUD, captura da galeria)

| | Hoje estilizado A / B | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 231 / 233 | 25 / 26 | **calcário morno: chão de luta matiz 30 a 45** |
| Luma p50 do quadro | 59 / 59 | 71 / 73 | 58 a 70 |
| Chão de luta (caixa de 192 x 162 px em nave aberta, sem personagem; anotar a caixa) | luma 62 a 68 (C18) | | luma p50 70 a 85, sat HSV p50 0,06 a 0,14 |
| Parte quente da cena | 1,2 / 2,0% | 25 / 30% | 6 a 12% (fachos e velas, não o chão inteiro) |

O Santuário é o único bioma de luta em pedra morna: contraste com Cripta (petróleo) e Fendas (índigo) que vêm antes na
descida, e com a grandeza dourada do conceito.

### 1.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,38; 0,363; 0,334), matiz 38 |
| `shadow` | (0,86; 0,9; 0,98) (sombra fria: a luz quente fica só nos fachos e velas) |
| `floor_stone` | (0,35; 0,335; 0,31) |
| `joint_cold` | (0,9; 0,93; 1,0) |
| `olive_share` | 0,08 |
| `fire` | os números do Salão (`STY_*`) |
| `air` | `sky` (0,05; 0,05; 0,06), `fog` (0,12; 0,11; 0,10), `ambient` (0,72; 0,70; 0,66), `ambient_gain` 1,0, `moon` (0,95; 0,92; 0,86), `moon_energy` 0,7, `moon_shadow` verdadeiro |
| `off` | a chave da nave (`KEY`) se desenhar anel; senão fica a 0,6 da energia |
| `backdrop` | não (sala com paredes altas; o fora é a cripta de baixo na B) |

### 1.3 Fachos (o marco de luz)

- Os dois fachos (`MOON_AT` (-9; 0) e (9; 2); `moon_shaft`) viram **marfim-dourado** no estilizado: cor (0,96; 0,88;
  0,70) (fica abaixo do limiar de fogo do `paint.gdshaderinc`: (r - b) / r = 0,27, então desenha borda e não poça chapada),
  energia 2,2 (A) e 2,8 (B) iguais, poeira igual.
- **Facho novo sobre o guardião**: um `moon_shaft` sem sombra em `boss_spawn` (-17; 0), a mesma cor, energia 1,6, cone 18,
  altura 16, só estilizado. É o pedido da diretriz ("área do guardião legível") sem mexer em nada; com ele, as luzes com
  sombra continuam em 5 (A) e 4 (B).
- Aceite do facho: no chão dentro do facho, aro do aviso vermelho 40 ou mais acima da laje (captura `--shot-at=9` com
  o guardião preparando; `--start=miniboss --arena=sanctuary`).

### 1.4 Peças novas (só estilizado)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| S1 | Velas e oferendas no presbitério | nos degraus do presbitério atrás da grade (fora do chão, além da borda oeste) | 3 grupos de 4 velas (2 acesos), urnas, sem luz nova além do grupo de sombra que já existe (`ALTAR_CANDLES`) |
| S2 | Escadaria cerimonial lida | os degraus do presbitério ganham um passadeiro de pano petróleo desbotado pintado (decalque nos degraus, 1,4 m de largura) | é o marco "onde o guardião está" |
| S3 | Entulho nas colunas quebradas | dentro do contorno das colunas (15; -6) e (-9; 6): tambores caídos encostados ao fuste, topo até 1,2 m | só dentro do círculo de 0,65 m menos 0,1 |
| S4 | Estátuas e estandartes nas naves laterais | contra as paredes norte e oeste, entre as pilastras (x -17,5 a -14 e -7 a -3,5 na parede norte), sobre o parapeito da parede, fora do chão | estátuas encapuzadas de 2,6 m nos nichos das janelas cegas de x -17,5 e -1; estandartes petróleo nas pilastras x -14 e 2 |
| S5 | Musgo e hera discretos | nas janelas cegas e no topo das paredes (decalque e cartões presos à parede, nunca no chão) | verde-cinza (0,20; 0,24; 0,17) |
| S6 (B) | Abóbada rasgada | sobre o buraco: bordas de abóbada quebrada (aduelas penduradas, `Masonry.voussoir_arch` em pedaços) a 9 m ou mais, fora da faixa de 2,6 m; o facho B (2,8) cai pelo rasgo dentro do buraco; poeira mais densa | nenhum céu, nenhuma cor de poente |

### 1.5 O que não muda

Colunas, toco, tambores, sarcófagos, bancos, grade, presbitério, buraco e cripta de baixo, portas, nascimentos, guardião,
câmera. Círculo no chão: nenhum (as lajes de túmulo da nave continuam a marcar o eixo).

## 2. Salão das Fendas (`RiftLook`, layout `rift`)

Planta real (`_rift`): contorno (-21; -15) a (21; 15); a fenda de norte a sul entre x -7 e 2 cortada pelas pontes
`BRIDGES` (z -12 a -7 e -1 a 4; na B a de cima caiu); passagem ao sul; buraco a leste (8 a 14,6; -8,4 a -1,8); todas as
portas na plataforma leste; braseiros em (8,5; -15,6) e (15,5; -15,6). Peças: bloco (14; 7) 3,6 x 1, 2,6 m em
pontilhado; colunas (7,5; 3) 3,8 m e (-13; 3) 3,2 m; sarcófago (-14; -5,5). Fachada ao norte com pórtico, estátuas em
x 4,6 e 19,4, torre em (-27; -24), correntes, bruma violeta em três folhas (`HAZE_*`), luz violeta de baixo (`DEEP`
(0,62; 0,45; 1,0), energia 5, y -10).

### 2.1 Medida e alvo

| | Hoje estilizado A / B | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 242 / 242 | 265 / 250 | chão de luta 235 a 255 (índigo dessaturado); violeta só abaixo da borda |
| Sat HSV p50 do quadro | 0,44 | 0,66 | 0,25 a 0,40 |
| Violeta acima de 60% (`frame_stats`) | 2,5% (C18) | | **até 3%** (com os orbes do feiticeiro em voo: até 5%) |
| Chão de luta (caixa em plataforma leste, sem personagem) | luma 43 a 53 | | luma p50 50 a 65, sat HSV p50 0,06 a 0,14 |

### 2.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,327; 0,319; 0,363), matiz 250 |
| `shadow` | (0,87; 0,833; 0,98) |
| `floor_stone` | (0,30; 0,295; 0,335) |
| `joint_cold` | (0,9; 0,88; 1,0) |
| `olive_share` | 0,04 |
| `fire` | números do Salão |
| `air` | `sky` (0,05; 0,045; 0,08), `fog` (0,10; 0,09; 0,14), `ambient` (0,62; 0,62; 0,74), `ambient_gain` 1,8, `moon` (0,80; 0,82; 0,95), `moon_energy` 1,0, `moon_shadow` verdadeiro |
| Bruma (`HAZE_COLOR`) | `vary` com saturação 0,8 da de hoje (a mais clara (0,23; 0,14; 0,42) vira (0,24; 0,17; 0,38)) |
| `DEEP` | energia 5 para 4 no estilizado se o violeta passar de 3% |

### 2.3 Peças novas (só estilizado; todas fora do chão)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| F1 | Braseiros de cabeceira | um pilarete com tigela âmbar em cada cabeceira das pontes, **do lado de fora do tabuleiro de 5 m**, sobre a borda da fenda (fora do polígono do chão): quatro na A (as pontas oeste e leste das duas pontes, no lado norte de cada), dois na B | pilarete 1,1 m, tigela do `ArenaKit.brazier` reduzida; luz de poça (`stylize_fires`), sem sombra |
| F2 | Cacos suspensos | dentro da fenda, abaixo do nível do chão (y -1 a -6), 12 a 18 blocos da pedra da sala, girados, parados | 0,4 a 1,8 m |
| F3 | Correntes e arcos fraturados | só ao norte, onde a fenda sai para o abismo, além da fachada | `kit.chain`, `Masonry.voussoir_arch` partido |
| F4 (B) | **A ponte caída como marco** (P-6) | sobre os tocos que existem (`_fallen_bridge`): um arco grande partido atrás deles (aduelas de 0,8 m, raio 6 m, metade que falta), pedaços do tabuleiro pendurados por duas correntes | tudo abaixo da borda ou ao norte dela |
| F5 (B) | Vórtice distante | só um acento: cartão no fundo norte, a 60 m ou mais, violeta (0,28; 0,2; 0,42) de maior canal até 0,45, sem luz, girando devagar (0,02 volta por s) | nunca na faixa da tela onde os inimigos do norte nascem: abaixo da linha do topo da fachada na tela |

### 2.4 Riscos e aceite próprios

- Orbes e trepadeiras violeta sobre a fenda: numa captura `--shot-at=9` com o feiticeiro atirando, o orbe tem de ter
  maior canal 40 ou mais acima do fundo da fenda atrás dele (`frame_stats --box` no orbe e no fundo).
- Nenhum fogo verde. Nenhum círculo no chão.
- `fit_probe` das Fendas: hoje fantasma 1,5, borda falsa 5,1 (A) e 5,0 (B); nada sobe.

## 3. Medir e entregar

Mesma linha da galeria: `RES=1920x1080 tools/gpu.sh shot <saída> --look=stylized --arena=sanctuary|rift --variant=0|1
--bot --autopick --seed=5 --shot-at=5`, mais `--shot-at=9`, mais 720, mais o clássico para a prova. Guardião:
`--start=miniboss --arena=sanctuary`. Saída em `docs/gallery/redesign/lotB/`. `fit_probe` com `--look=stylized`;
`test_arenas`; 8 sementes do robô por sala; `sty_probe` RTX Alta e iGPU Baixa (até 3 qps abaixo da linha de base);
Compatibility uma captura por sala.

Esforço: Santuário 2 sessões, Fendas 2 sessões, correções 1. **Total 4 a 5.**
