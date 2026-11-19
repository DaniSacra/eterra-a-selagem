# Redesenho das salas, Lote C: Jardim das Raízes Mortas A e B, Ponte dos Condenados A e B

- **Data**: 2026-11-18. **Autor**: art-director. **Para**: environment-artist, depois do Lote B.
- **Depende de**: biblioteca do Lote A; este lote cria **musgo, folha morta e água** pintados. Regras e aceite comum:
  `room_redesign_matrix.md` 0.3, 0.4 e 4. Decisões: P-7 (árvore de pedra, folha morta), cores reservadas.
- Só STYLIZED; clássico igual; nada barra; nada novo acima de 0,3 m no chão andável; Meshy zero.
- Conceitos (clima): `conceitos/06_jardim_A.png`, `07_jardim_B.png`, `10_ponte_A.png`, `11_ponte_B.png`.

## 1. Biblioteca nova deste lote

| Peça | Como | Números |
|---|---|---|
| Musgo pintado | gêmeo `root_moss_paint` (o `root_moss.gdshader` com `#define PAINT` e o `paint.gdshaderinc`), trocado pelo `paint_look` | verde-cinza (0,20; 0,24; 0,17), três degraus de valor, sempre abaixo do valor da laje vizinha; nunca matiz entre 120 e 170 com sat acima de 0,3 |
| Folha morta | a copa em cartões (`canopy.gdshader`, `GardenLook._canopy`) e cachos de folha caída nas bordas: `vary` da cor | ferrugem (0,36; 0,16; 0,09) a (0,30; 0,20; 0,12): matiz 15 a 25, sat até 0,45, valor até 0,4; nunca o vermelho do aviso (valor 1,0, sat 0,82) |
| Fungo pálido | cachos de 5 a 9 chapéus (prisma achatado procedural) sobre peças e no pé das paredes, fora do chão | marfim-cinza (0,62; 0,6; 0,55), brilho próprio só na borda do chapéu, maior canal até 0,6 |
| Água escura | lago e cascata: plano com ondas lentas e espuma; reaproveitar o `fountain_water.gdshader` com outros números | corpo azul escuro (0,05; 0,09; 0,12), matiz 200 a 210; espuma marfim-azulada (0,7; 0,8; 0,85) abaixo do glow (maior canal até 0,9 no material); **nenhum turquesa** (matiz 170 a 190 é o petróleo do herói e fica perto da Emeth) |

## 2. Jardim das Raízes Mortas (`GardenLook`, layout `garden`)

Planta real (`_garden`): contorno (-17; -14) a (17; 14) com cortes; árvore de pedra em (-8; -5), raio 3,5 m (barra
corpo e tiro); raízes baixas de 0,6 m (só corpo); A: sarcófagos (7,5; -5) e (-16,4; -1,5), mureta (9 a 13; 5), coluna
(4,5; 7); B: sarcófagos (11,5; -6) e (6,5; 5), colunas (12; 3) e (-12,5; 4); braseiros em (10,5; -14,6), (15,5;
-14,6), (17,6; -2,6); portas ao norte (13; -14), leste (17; 0) e sul (5; 14). Fantasma 2,0 m², peça sem desenho 1,6
m² (raízes).

### 2.1 Medida e alvo

| | Hoje estilizado A / B | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 234 / 240 | 169 / 194 | chão de luta 70 a 100 (cinza-musgo) |
| Ciano no quadro (sat acima de 0,25, matiz 160 a 230) | 32 / 24% | 41 / 43% | **até 12%**, nenhum na caixa do herói acima de 2% |
| Chão de luta (caixa a leste da árvore, sem personagem) | luma 50 a 56 | | luma p50 55 a 70, sat HSV p50 0,08 a 0,18 |
| Folha ferrugem | 0 | muito | 2 a 6% do quadro, só na copa e nas bordas |

### 2.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,312; 0,331; 0,285), matiz 85 |
| `shadow` | (0,86; 0,92; 0,98) |
| `floor_stone` | (0,29; 0,305; 0,265) |
| `olive_share` | 0,25 (o Jardim é o bioma do oliva) |
| `fire` | números do Salão |
| `air` | `sky` (0,04; 0,05; 0,05), `fog` (0,07; 0,09; 0,09), `ambient` (0,62; 0,68; 0,66), `ambient_gain` 1,3, `moon` (0,78; 0,84; 0,92), `moon_energy` 0,6, `moon_shadow` verdadeiro |
| `off` | a chave do meio (`KEY`, 5,5) se desenhar anel; compensar no ambiente |
| Cristais (`crystal_edge.gdshader`) | ficam (esmeralda corrompido escuro, brilho só na aresta); conferir que a aresta não passa de 1,0 |
| Árvore (`stone_tree.gdshader`) | pedra da sala pelo `paint_recolor` se o shader tiver gêmeo; senão `vary` da cor da casca para o cinza-musgo (matiz 70 a 90, valor do tronco 0,9 da pedra) |

### 2.3 Peças novas (só estilizado)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| J1 | Copa em ferrugem | a copa que já existe (`_canopy`), só cor | acima de 2,6 m, abre em volta do herói (já) |
| J2 | Folha caída | decalque no chão só a até 1,2 m das paredes norte e oeste e em volta do tronco (dentro do raio de 3,5 + 0,5 m) | 0,01 m; densidade até 30% da área da faixa |
| J3 | Fungos | sobre as tampas dos sarcófagos, no pé das colunas (dentro do contorno), no parapeito das paredes | cachos de 0,1 a 0,25 m |
| J4 | Água atrás das janelas | nas janelas cegas e além do corte noroeste: cascata vertical em cartão (2 m de largura) e poça escura no pé, fora do chão | espuma abaixo do glow |
| J5 (B) | Lago da borda oeste | do lado de fora da borda oeste (a parede oeste dá lugar a um peitoril baixo de 0,9 m quebrado, sem mudar o polígono), lago escuro abaixo do nível do chão (y -0,6) com uma cascata ao fundo | lábio de pedra quebrado (`broken_lip`) lê "não dá"; nenhuma água no chão andável |
| J6 | Musgo | o `_moss` que existe passa ao gêmeo pintado | igual de lugar |

O conceito pede "centro mais amplo e seco" na B: já é (leste). Nada de flores ou moitas no chão livre.

### 2.4 Riscos e aceite próprios

- Folha ferrugem perto da borda onde nascem inimigos: captura `--shot-at=9` com aviso perto da parede; o aro do aviso
  40 ou mais acima do que está em volta, e a folha mais escura que o aviso por 100 de luma ou mais.
- `fit_probe` do Jardim: meta da diretriz e do room-designer, fantasma abaixo de 2,0 e peça sem desenho abaixo de 1,6
  (não subir; se der, descer).

## 3. Ponte dos Condenados (`BridgeLook`, layout `bridge`)

Planta real (`_bridge`): A, plataformas oeste (-28 a -14), meio (-7 a 7) e leste (14 a 28), pontes de 5 m (z -2,5 a
2,5) entre x -14 e -7 e entre 7 e 14; peças: colunas (-21; -4) 3,0 m e (20; 4,5) 3,6 m, sarcófago (21; -4,8), pilone
(0; -7,2) 2,8 x 1,6, 6 m, bloco (2,5; 2,5) 1 x 3,2, 2,2 m, coluna (-2,5; 3,5) 3,4 m. B: ponte longa de x -12 a 12 com
patamar de 6 x 9 m no meio. Abismo com bruma azul-cinza (`MIST` (0,18; 0,21; 0,28)), luz de baixo `DEEP` (0,35; 0,42;
0,6). Fantasma A 4,1 m², B 2,8 m².

### 3.1 Medida e alvo

| | Hoje estilizado A / B | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 223 / 224 | 211 / 190 | chão de luta 205 a 220 |
| Ciano no quadro | 81 / 78% (o abismo azul enche a tela) | 43 / 56% | 40 a 65%, mais escuro e menos saturado: sat HSV p50 do quadro 0,25 a 0,35 (hoje 0,39 a 0,40) |
| Chão das plataformas | luma 45 | | luma p50 55 a 70 |
| Parte quente | 0,3 / 1,0% | 17 / 14% | 3 a 7% (braseiros das cabeceiras) |

### 3.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,318; 0,335; 0,354), matiz 212 |
| `shadow` | (0,833; 0,906; 0,98) |
| `floor_stone` | (0,295; 0,31; 0,33) |
| `olive_share` | 0,05 |
| `fire` | números do Salão |
| `air` | `sky` (0,05; 0,06; 0,075), `fog` (0,11; 0,13; 0,16), `ambient` (0,64; 0,68; 0,76), `ambient_gain` 1,8, `moon` (0,82; 0,86; 0,95), `moon_energy` 1,0, `moon_shadow` verdadeiro |
| Bruma do abismo | `MIST` 0,85 da saturação de hoje |

### 3.3 Peças novas (só estilizado; todas fora do tabuleiro de 5 m e das plataformas)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| P1 | Pilares de cabeceira com braseiro | nas quatro cabeceiras (A) e nas duas (B), **sobre a borda da plataforma, fora do polígono do chão**, nunca no tabuleiro | pilar 1,4 m (o `HEAD` que existe) com tigela âmbar; luz de poça sem sombra |
| P2 | Arcos de sustentação | sob as pontes (já existem os arcos): mais um anel de aduelas mais fundo, a 4 m sob o tabuleiro | pedra da sala, um degrau mais escura |
| P3 | Correntes | das cabeceiras para o pilone e para fora, acima de 2,6 m ou abaixo do tabuleiro | `kit.chain` |
| P4 | Cascatas ao norte | no fundo, a 25 m ou mais da borda norte, cartões verticais claros (espuma marfim-azulada abaixo do glow) caindo na bruma | silhueta escura dos inimigos sobre fundo claro (boa), nunca turquesa |
| P5 (B) | Passarelas e ponte desabada ao fundo | só paisagem, ao norte e ao sul, a 15 m ou mais, `ruin_card` e voussoirs procedurais | nenhuma peça junto ao tabuleiro |
| P6 (B) | Lanternas suspensas | sobre o patamar, penduradas da corrente, acima de 3 m | luz simples fraca (0,6), sem poça forte no tabuleiro |

Antes de enfeitar a B: o fantasma de 2,8 m² vem da alvenaria do patamar (room-designer); reduzir é desejável, não
obrigatório neste lote (não pode subir).

### 3.4 Riscos e aceite próprios

- Nenhum decalque dourado no tabuleiro (lê como círculo ou aviso).
- Atiradores da plataforma leste sobre o fundo: silhueta escura com 30 de luma ou mais de diferença do fundo atrás.
- `fit_probe` Ponte: A fantasma até 4,1 (meta da diretriz: abaixo de 2), B até 2,8.

## 4. Medir e entregar

Mesma linha da galeria (`--arena=garden|bridge --variant=0|1`, `--look=stylized`, `--shot-at=5` e `9`, 1080 e 720,
clássico para a prova), saída em `docs/gallery/redesign/lotC/`; `fit_probe`, `test_arenas`, 8 sementes por sala,
`sty_probe` RTX Alta e iGPU Baixa, Compatibility.

Esforço: biblioteca (musgo, folha, fungo, água) 1,5 sessões; Jardim 2; Ponte 1,5; correções 1. **Total 5 a 6.**
