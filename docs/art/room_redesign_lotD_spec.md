# Redesenho das salas, Lote D: Câmara das Runas Instáveis A e B, Câmara da Provação, Altar Esquecido

- **Data**: 2026-11-18. **Autor**: art-director. **Para**: environment-artist, depois do Lote C.
- **Depende de**: biblioteca do Lote A (preset `style()`, `paint_look`, `stylize_fires`, ar e F7, `backdrop`, urna,
  metal). Regras e aceite comum: `room_redesign_matrix.md` 0.3, 0.4 e 4. Decisões: P-4 (nenhum círculo no chão), P-5
  (âmbar só na laje acesa das Runas), P-8 (Provação lilás, sem cara de arena), P-9 (Altar sem figura alada nem auréola),
  D-29 (Runas: nada redondo).
- Só STYLIZED; clássico igual; nada barra; nada novo acima de 0,3 m no chão andável; Meshy zero.
- Conceitos (clima): `conceitos/12_runas_A.png`, `13_runas_B.png`, `14_camara_provacao.png`, `15_camara_altar.png`.

## 1. Câmara das Runas Instáveis (`RunesLook`, layout `runes`)

Planta real: 30 x 24 m, grade de 10 x 8 lajes de 3 m desde (-15; -12) (`HazardDef`, `RuneFloor.fits`), câmera fixa;
A com quatro pilares de runas (`rune_pillar`, sulcos que esquentam), B com dois pilares e a pedra quieta de 6 x 6 m no
meio (`quiet`, caixa que não barra nada, lisa com fio de ouro). Chão `rune_floor.gdshader` (o chão das catacumbas com
`#define RUNES` e `rune_tiles.gdshaderinc`), estado por laje numa textura 10 x 8 que o gameplay escreve.

### 1.1 O ponto delicado: o gêmeo pintado do chão de runas

- Criar `rune_floor_paint.gdshader` = `catacomb_floor_paint` com `#define RUNES` (os dois `#define` no mesmo arquivo; o
  `rune_tiles.gdshaderinc` lido igual). **O estado das lajes não pode mudar**: mesma textura, mesmos uniforms, mesmos
  tempos; o `RunesLook.set_tile`, `apply`, `set_chevrons` escrevem nos dois materiais (ou no que estiver em uso: o
  `vary` troca só o `shader`, o material é o mesmo, então os uniforms seguem).
- O preparo, o golpe e a brasa ficam como hoje na cor (âmbar `HAZARD_COLOR`, preenchimento até 0,25, `fill_grey`). O
  estilizado só pinta a pedra em volta. Aceite numérico: na captura com laje armada (`tools/arena_lab.gd -- --arena=runes
  --state=arm` e `--state=fire`, `--look=stylized`), a moldura acesa da laje 40 ou mais acima da laje apagada vizinha, e
  matiz da laje acesa 26 a 36 (o mesmo do clássico, medir os dois).
- Teste: `tests/test_e5_looks.gd` estendido (ou o do Lote A) conferindo que `set_tile` muda o mesmo parâmetro nos dois
  perfis e que o F7 com uma laje acesa não apaga nem duplica o estado.

### 1.2 Medida e alvo

| | Hoje estilizado A / B | Conceito | Alvo |
|---|---|---|---|
| Matiz do quadro | 231 / 231 | 173 / 199 | chão 220 a 235, quase cinza |
| Chão de luta (laje apagada no meio) | luma 45 a 48 | | luma p50 62 a 75, sat HSV p50 0,03 a 0,10 |
| Âmbar no quadro em repouso (`--state=after` com tudo apagado) | | | **0%** fora dos braseiros de parede (até 1%) |

A sala clara e fria é a que deixa o âmbar ler sozinho: é o motivo do valor alto do chão.

### 1.3 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,344; 0,349; 0,366), matiz 225 |
| `shadow` | (0,902; 0,921; 0,98) |
| `floor_stone` | (0,33; 0,335; 0,35) |
| `olive_share` | 0 |
| `slab_hue` | 2 |
| `fire` | números do Salão; luzes âmbar do disparo (`rune_flash`, até 4, só Forward+) **não** passam pelo `stylize_fires` (são do perigo: ficam como estão) |
| `air` | `sky` (0,05; 0,05; 0,06), `fog` (0,10; 0,10; 0,12), `ambient` (0,70; 0,71; 0,76), `ambient_gain` 1,7, `moon` (0,86; 0,88; 0,95), `moon_energy` 0,9, `moon_shadow` falso |

### 1.4 Peças novas (só estilizado)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| R1 | Glifos dos pilares | os sulcos (`rune_groove.gdshader`) em repouso em marfim apagado (0,55; 0,52; 0,46) e, quando a laje vizinha arma, o calor que já existe (`GROOVE_HEAT`) | sem nova luz; nunca verde |
| R2 | Mecanismo ao fundo | na parede norte, fora do chão: painel em losango de 5 m de lado (girado 45 graus), anéis quadrados concêntricos em ouro velho apagado (0,42; 0,31; 0,13), metálico 0,35, rugosidade 0,75, com quatro barras radiais e quatro blocos de contrapeso | **nada redondo** (D-29); sem luz própria; um facho fraco frio de cima para separá-lo da parede |
| R3 | Estelas | as que existem ganham marcas retas em marfim apagado (as mesmas do relevo) | sem brilho |
| R4 | Mesa de estudo ao fundo | no recanto noroeste, fora do chão: caixotes (`Masonry.crate`), urnas, velas apagadas, um pano dobrado | só no parapeito e além |
| R5 (B) | Cristal | **fora do chão, ao norte**, atrás da borda, em frente ao eixo da pedra quieta: aglomerado de 5 a 7 prismas de 1,2 a 3,0 m, marfim-azulado frio (0,62; 0,68; 0,75), matiz 210, sat até 0,25, brilho só na aresta (reaproveitar `crystal_edge.gdshader` com essa cor), maior canal até 0,8 | nunca no meio, nunca verde |

### 1.5 Riscos

- Qualquer marca luminosa no chão que não seja estado de laje: proibida.
- `fit_probe` Runas: fantasma 2,6, borda falsa 0,5: nada sobe.

## 2. Câmara da Provação (`TrialLook`, layout `trial`)

Planta real: 16 x 14 m, sem luta; estela no lugar do cubo (`TrialLook._block`, `stele_crack.gdshader`, colisão igual);
veias lilás no chão (`trial_veins.gdshader`); um foco marfim com a única sombra; lanternas frias; `settle(s)` apaga 60%;
paredes norte e oeste altas, frente baixa com chão quebrado e rocha caindo na bruma (`_apron`, AP-1); `backdrop` em duas
profundidades. Luma de hoje 32 (laboratório; AP-1 diz 56 na partida).

### 2.1 Alvo

| | Hoje (laboratório) | Conceito | Alvo estilizado |
|---|---|---|---|
| Matiz do quadro | 246 | 9 (vermelho: recusado) | 265 a 285, lilás acinzentado |
| Luma p50 do quadro | 32 | 64 | 45 a 60 |
| Vermelho (matiz 345 a 15, sat acima de 0,4) | 0 | muito | **0%** |

### 2.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,338; 0,317; 0,352), matiz 275 |
| `shadow` | (0,923; 0,843; 0,98) |
| `floor_stone` | (0,31; 0,295; 0,325) |
| `olive_share` | 0 |
| `air` | `sky` (0,15; 0,14; 0,18), `fog` (0,2; 0,19; 0,235), `ambient` (0,62; 0,58; 0,70), `ambient_gain` 1,8, `moon` (0,72; 0,68; 0,84), `moon_energy` 0,5, `moon_shadow` falso |
| `fire` | nenhum fogo (lanternas frias ficam como estão) |

### 2.3 Peças novas (só estilizado)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| T1 | Piso em losangos concêntricos | pintado no chão: três losangos quadrados concêntricos (lados de 4, 7 e 10 m, girados 45 graus) centrados na estela, sulcos de 0,08 m no valor da junta, sem ouro, sem brilho | relevo pintado (0 m); **nenhum círculo**; o selo rachado da estela é o símbolo central (decisão) |
| T2 | Estandartes petróleo desbotados | dois, nas paredes norte e oeste, rasgados | `ArenaKit.banner` leão, `BANNER_FADE` como os do Altar |
| T3 | Braseiros apagados | dois, fora do chão, nos cantos do fundo: tigela fria com cinza, sem fogo nem luz | o conceito tem fogo; aqui o vazio conta a maldição |
| T4 | Urnas quebradas | no parapeito das paredes do fundo | urna (Lote A) com a boca partida |

A única luz lilás é a fenda da estela e as veias. Nada vermelho. Aceite extra: `settle` continua apagando 60% (medir a
luma das veias antes e depois na captura do laboratório, nos dois perfis).

## 3. Altar Esquecido (`AltarLook`, layout `altar`)

Planta real: 18 x 14 m; arco cego com faixa gasta sem texto; leão em relevo na frente do altar
(`altar_lion.gdshader`); 11 velas apagadas que se acendem (`kindle`, uma luz com sombra); estandartes desbotados em x
-6 e 6 (um rasgado); facho frio `SHAFT` (0,70; 0,78; 0,92) 2,0; ar `AIR` ambiente 1,35, céu quase preto. Luma de hoje
26 (laboratório).

### 3.1 Alvo

| | Hoje (laboratório) | Conceito | Alvo estilizado |
|---|---|---|---|
| Matiz do quadro | 211 | 45 | chão 28 a 42 (pedra morna calma) |
| Luma p50 do quadro | 26 | 52 | 45 a 58 antes do `kindle`; depois, as velas fazem a poça |
| Parte quente depois do `kindle` | | | 4 a 10% |

### 3.2 Preset `style()`

| Chave | Valor |
|---|---|
| `stone` | (0,354; 0,339; 0,319), matiz 35 |
| `shadow` | (0,88; 0,9; 0,98) |
| `floor_stone` | (0,33; 0,318; 0,3) |
| `olive_share` | 0,06 |
| `fire` | velas do altar: `candle_range` 3,0, `candle_gain` 1,2; a luz com sombra do `kindle` fica com sombra (é a única) |
| `air` | `sky` (0,03; 0,03; 0,035), `fog` (0,08; 0,075; 0,07), `ambient` (0,68; 0,66; 0,62), `ambient_gain` 1,4, `moon` (0,9; 0,88; 0,84), `moon_energy` 0,6, `moon_shadow` falso |
| Facho | `SHAFT` vira ouro velho pálido (0,96; 0,88; 0,70) no estilizado, energia 1,6 (o "facho dourado fraco" do conceito) |

### 3.3 Peças novas (só estilizado)

| # | Peça | Onde | Medidas |
|---|---|---|---|
| A1 | Oferendas | no degrau do altar (em cima da peça) e no parapeito do fundo: urnas, potes, panos dobrados petróleo e umbra, uma tigela de ouro velho vazia | até 0,35 m |
| A2 | Hera e musgo | no arco cego e na faixa gasta, cartões presos à pedra | verde-cinza (0,20; 0,24; 0,17), nunca acima de 0,3 de sat |
| A3 | Pétalas | decalque pálido no chão em volta do degrau, abaixo de 0,02 m | marfim e lilás apagados, como na Fonte |

Proibido (P-9): figura alada, auréola, raios, sol, cruz. O leão em relevo continua o centro.

## 4. Medir e entregar

- Runas: mesma linha da galeria (`--arena=runes --variant=0|1`), mais `tools/arena_lab.gd -- --arena=runes
  --state=arm|fire|after --look=stylized` (o `arena_lab` precisa honrar o `--look`; conferir).
- Provação e Altar: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd --
  C:/<saída>.png --arena=trial|altar --look=stylized` (a vista 14 e 15 da galeria) e na partida `--start=trial|altar
  --look=stylized --bot --autopick --seed=5 --shot-at=5`.
- Saída em `docs/gallery/redesign/lotD/`; `fit_probe` (`--arena=runes|trial|altar`), `test_arenas`, `test_e5_looks`,
  `test_hazard`, 8 sementes do robô nas Runas, `sty_probe` RTX Alta e iGPU Baixa nas Runas (as luzes do disparo
  contam), Compatibility uma por sala.

Esforço: gêmeo do chão de runas e teste 1,5 sessões; Runas 1,5; Provação 1; Altar 1; correções 1. **Total 5 a 6.**
