# Métricas do C12 (Arenas I)

Medidas do QA em 2026-11-16 sobre o commit `91cc656` (`arpg-3d`). Simulações sem tela na Godot 4.7.2 de Linux (WSL2,
`--headless --fixed-fps 60`) com o robô (`--bot`), que joga pela lógica do jogo e lê o perigo pelo aviso no chão;
`--bot-reaction=0.25` dá a ele um quarto de segundo de reação. Quadros na placa de vídeo pela Godot de Windows.
Dados brutos e roteiros (fora do repositório): `/home/dani/games/qa-c12-work/data/` e `/scripts/`.

## 1. Lutas por arena e variante (testes 4 e 5 do plano)

192 lutas: 32 sementes (1 a 32) por arena e variante, sempre a **primeira sala** (`--arena=<a> --variant=n`, profundidade
1). Para medir só essa sala, cada semente roda duas vezes: a primeira dá o tempo da sala 1 no `rooms`, a segunda para
nesse tempo (`--smoke=<tempo>`), e todas terminaram na sala 1 com 0 inimigos de pé. Comando de cada uma:
`tools/smoke.sh <s> --arena=<a> --variant=n --seed=<1..32> --bot-reaction=0.25`. Rodadas 4 de cada vez (o tempo do passo
desta tabela não vale; ver a seção 3).

| Arena | Lutas | `stuck` (inimigo parado 3 s) | `bot.stuck` | Mortes | 1º contato, mediana (máx.) | Sala, mediana (máx.) | Dano levado: média, máx., lutas com dano | Tiros barrados: total (por luta) | `max_alive` |
|---|---|---|---|---|---|---|---|---|---|
| Cripta A | 32 | **0** | **0** | 0 | 2,7 s (3,3) | 15,8 s (19,8) | 1,4, 9, 8 de 32 | 41 (1,28) | 4 |
| Cripta B | 32 | **0** | **0** | 0 | 2,6 s (3,3) | 15,2 s (20,3) | 1,8, 18, 10 de 32 | 34 (1,06) | 4 |
| Fendas A | 32 | **0** | **0** | 0 | 3,7 s (5,3) | 13,9 s (29,3) | 1,2, 7, 8 de 32 | 10 (0,31) | 6 |
| Fendas B | 32 | **0** | **0** | 0 | 3,7 s (7,2) | 14,9 s (29,0) | 0,6, 9, 4 de 32 | 8 (0,25) | 6 |
| Jardim A | 32 | **0** | **0** | 0 | 2,4 s (4,5) | 14,2 s (28,5) | 1,0, 9, 4 de 32 | 15 (0,47) | 6 |
| Jardim B | 32 | **0** | **0** | 0 | 2,4 s (4,1) | 13,9 s (30,1) | 1,1, 9, 6 de 32 | 16 (0,50) | 6 |

- 0 linhas de `SCRIPT ERROR` ou `Parse Error` nas 384 execuções.
- Tetos de inimigos respeitados: Cripta no máximo 4 de pé (faixa 4 a 6), Fendas e Jardim 6 (faixa 6 a 8). Na profundidade 1
  o limite fica no começo da faixa.
- A cobertura funciona: a Cripta, a mais fechada, barra mais tiros (1,1 a 1,3 por luta).

**Salas mais fundas** (as mesmas 192 partidas seguidas até 120 s e as 8 descidas da seção 2; a última sala de cada
partida, que pode ter sido cortada, fica de fora):

| Arena, profundidade | Salas | Sala, mediana (máx.) | 1º contato, mediana (máx.) | Dano: média, máx., % com dano | Quem mais feriu |
|---|---|---|---|---|---|
| Cripta, 2 | 73 | 20,5 s (26,6) | 3,6 s (6,6) | 1,1, 9, 27% | esqueleto 39, guarda 18 |
| Cripta, 3 | 59 | 21,0 s (33,3) | 3,5 s (7,0) | 2,3, 18, 38% | feiticeiro 64, guarda 41 |
| Fendas, 2 | 65 | 22,4 s (34,8) | 4,2 s (7,1) | 0,8, 9, 20% | besteiro 21 |
| Fendas, 3 | 68 | 27,1 s (39,7) | 4,3 s (7,1) | 5,8, 23, 63% | feiticeiro 288, besteiro 51 |
| Fendas, 5 (guardião) | 75 | 34,5 s (46,5) | 5,1 s (8,1) | 4,3, 21, 34% | Ancião 279, Cavaleiro 36 |
| Jardim, 2 | 62 | 20,4 s (31,8) | 3,4 s (6,1) | 1,3, 9, 27% | guarda 27, besteiro 27 |
| Jardim, 3 | 72 | 25,1 s (39,1) | 3,0 s (6,7) | 5,7, 16, 66% | feiticeiro 276, sacerdote 54 |
| Jardim, 5 (guardião) | 85 | 33,3 s (43,3) | 4,1 s (7,0) | 6,4, 27, 40% | Ancião 459, Cavaleiro 84 |

A Cripta nunca recebe o guardião (`guardian = false`), como na spec. Na profundidade 3 o feiticeiro faz a maior parte do
dano nas três arenas.

## 2. Descida inteira de 7 salas (8 partidas, reação 0,25)

`tools/smoke.sh 600 --seed=<1..8> --bot-reaction=0.25` (sem `--arena`: abertura no salão e as arenas sorteadas).

| Semente | Resultado | Morvath aos | `hp_at_boss` | Onde morreu | Salas 2, 3, 5 |
|---|---|---|---|---|---|
| 1 | **venceu** (215,0 s) | 106,8 s | 53 | | Jardim, Cripta, Fendas |
| 2 | perdeu | 113,5 s | 14 | Morvath, fase 3 (mortos 8, maldição 6) | Jardim, Fendas, Jardim |
| 3 | perdeu | 118,1 s | 12 | Morvath, fase 2 (foice 8, mortos 4) | Fendas, Cripta, Jardim |
| 4 | **venceu** (238,3 s) | 120,4 s | 19 | | Jardim, Fendas, Jardim |
| 5 | **venceu** (248,7 s) | 111,6 s | 40 | | Cripta, Fendas, Jardim |
| 6 | **venceu** (236,7 s) | 113,0 s | 24 | | Jardim, Fendas, Fendas |
| 7 | perdeu | não chegou | | sala 5, guardião no Jardim (Ancião 11) | Jardim, Fendas, Jardim |
| 8 | perdeu | 94,8 s | 30 | Morvath, fase 3 (mortos 28, maldição 2) | Jardim, Cripta, Fendas |

- **4 vitórias em 8**; chegou a Morvath em 7 de 8, aos 94,8 a 120,4 s (mediana 113,0); vida ao chegar 12 a 53 (mediana 24).
- `stuck` 0 e `bot.stuck` 0 em todas; tiros barrados 2 a 14 por partida; `max_alive` 7.
- Regressão com reação 0: `tools/smoke.sh 300 --seed=5` **venceu** (Morvath na sala 7 aos 129,5 s, 247,4 s no total);
  `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` **venceu** (91,6 s); `tools/smoke.sh 120 --stress=300 --seed=5`
  309 abates, `max_alive` 300, sem erro (`step_ms_avg` 2,55, pico 15,86 com até 300 de pé).

## 3. Passo da simulação (teste 7 do plano)

8 sementes por arena e variante, **uma de cada vez**, só a sala 1, com `--trace-steps` (passos acima de 4 ms impressos).
O salão no mesmo modo (`--arena=hall --smoke=15`, 8 sementes) para comparar.

| Arena | `step_ms_avg` mediana (máx.) | `step_ms_peak` mediana (máx.) | Passos acima de 4 ms |
|---|---|---|---|
| Cripta A | 0,16 (0,18) | 2,30 (8,97) | 2 |
| Cripta B | 0,16 (0,17) | 2,47 (5,82) | 1 |
| Fendas A | 0,24 (0,25) | 2,62 (3,19) | 0 |
| Fendas B | 0,23 (0,25) | 2,38 (5,20) | 1 |
| Jardim A | 0,23 (0,25) | 2,95 (3,76) | 0 |
| Jardim B | 0,23 (0,24) | 2,66 (11,38) | 1 |
| Salão (comparação) | 0,19 a 0,21 | 2,14 a 3,11 | |

- O médio fica em 0,16 a 0,25 ms (Fendas e Jardim cerca de 0,04 ms acima do salão, pelo campo de fluxo).
- **O pico passa dos 2 ms do plano em todas as 48 lutas, mas o salão sem grade nem campo de fluxo também passa** (2,1 a
  3,1): o pico de uma só passada nesta máquina (WSL) não separa a arena do resto. Os 5 passos acima de 4 ms: 4,18 ms
  (`player` 4,09, aos 2,0 s), 5,82 (`horde` 5,73), 5,20 (`player` 5,11), 11,38 (`horde` 11,31) e 8,97 ms com os laços somando
  0,2 ms (o tempo foi fora deles). Um a cada cerca de 10 lutas.

## 4. Situações à mão (testes 2, 3 e 6 do plano, pelo jogador de verdade)

Roteiro `hand.gd` (fora do repositório): a cena do jogo, o `Player` e o `Game._step` de verdade, comandados por um
`Controls.VirtualPad`, sem tela. `~/tools/godot/godot --headless --path . -s hand.gd -- --nosave`.

| Situação | Como | Resultado |
|---|---|---|
| Atravessar obstáculo andando e esquivando | cada peça que barra corpo, de 12 lados a 1,4 m da borda: 2 s andando contra ela, depois a esquiva contra ela a 60 e a 30 FPS | Cripta A 93 tentativas, B 68; Fendas A 48, B 60; Jardim A 164, B 136: **0 quadros com o corpo dentro de uma peça, 0 travessias**, entrada máxima 0,000 m |
| Esquiva na borda da fenda | 120 pontos do chão até 1,6 m de cada buraco; esquiva para o buraco e a 0,5, -0,5 e 1,2 rad dele, a 60 e a 30 FPS | Fendas A 3840 esquivas, B 2880: **0 quadros fora do chão, 0 trechos passando sobre buraco** |
| Cercado num corredor | os 4 pontos mais estreitos de cada arena e variante (3,6 a 6,8 m entre bloqueios, abertos ao longo); 2 esqueletos de cada lado a 1,4 e 2,6 m; esquiva em 16 direções | **12 a 15 das 16 esquivas saem mais de 2,5 m** em todos os 24 casos (média 4,1 a 5,6 m); o corredor mais estreito: Jardim A (14,2; 4,9), 3,6 m, 14 de 16 |

## 5. Quadro na placa de vídeo, 1920 x 1080 (meta até 6 ms)

Sonda `C:/Users/danie/tools/qa/gpuperf9.gd` (a mesma do C11): 240 quadros para assentar e 300 medidos.
`tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --disable-vsync -s
C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave --seed=5 --bot --bot-reaction=0.25
--probe-settle=240 <cena>`; janela conferida em 1920 x 1080 (3D desenhado em 2880 x 1620). Notebook na tomada. Duas
rodadas, nada mais rodando no WSL.

| Cena | Quadro mediana, rodadas 1 / 2 | p90 (pior) | GPU mediana | Chamadas | Primitivas | De pé (média, máx.) |
|---|---|---|---|---|---|---|
| Cripta A | 3,32 / 3,39 ms | 3,85 | 3,27 | 691 | 1,22 M | 2,4, 3 |
| Cripta B | 3,38 / 3,45 ms | 3,97 | 3,24 | 651 | 1,55 M | 3,2, 4 |
| Fendas A | 4,29 / 4,37 ms | 4,85 | 4,20 | 769 | 1,57 M | 4,0, 6 |
| Fendas B | 4,25 / 4,34 ms | 4,81 | 4,18 | 730 | 1,46 M | 3,5, 6 |
| Jardim A | 4,55 / 4,60 ms | 4,97 | 4,48 | 790 | 1,26 M | 2,9, 6 |
| Jardim B | 4,66 / 4,60 ms | 5,16 | 4,59 | 792 | 1,28 M | 2,9, 6 |
| Salão (`--arena=hall`) | 5,09 / 5,09 ms | 5,69 | 5,01 | 935 | 0,84 M | 3,6, 4 |
| Câmara (`--start=boss`) | 3,92 / 4,06 ms | 4,67 | 3,84 | 1006 | 0,75 M | 1, 1 |

**Meta cumprida**: as três arenas ficam entre 3,3 e 4,7 ms (p90 até 5,16), todas mais leves que o salão.

**Compatibility** (`--rendering-driver opengl3`, OpenGL 3.3 NVIDIA 621.01, mesma placa, uma rodada, `0 SCRIPT ERROR`):
Cripta A 3,21 ms (p90 3,95), Fendas A 3,74 (p90 4,45), **Jardim A 5,35 (p90 6,03)**, salão 4,37 (p90 5,03). O Jardim é o
único que passa de 6 ms no p90, e só no Compatibility.

## Não medido

FPS em celular ou placa fraca; som (o `--shot` silencia o jogo); dificuldade com gente; o salto do alvo da câmera entre
quadros (C12-F6 pede abaixo de 0,5 m a 60 FPS: os vídeos não mostram salto, mas não foi medido em número).
