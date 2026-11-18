# AP-1 "Nada de protótipo": evidências

Itens ART-01.2, 01.3, 01.4, 01.6, 02.3, 02.5, 03.7 e 04.2 de `docs/art/art_polish_backlog.md`. Capturas reais na RTX
5060 em Forward+ (`tools/gpu.sh shot`), a 1080 e 720, antes (`before/`) e depois (`after/`): loja (`--start=shop`),
altar, Provação, Fonte (`--start=...`, 3 s), sala vencida (`--arena=crypt --bot --autopick --seed=5 --hero-hp=999`;
antes aos 15,8 s com o disco caindo, depois aos 17,5 s com as portas), vitrine (`--showcase --seed=5`, 2 s) e Morvath
(`--start=boss --seed=5`, 5 s). Sem semente as portas do altar e da loja saem em outra ordem a cada execução.

- `detail/rewards_720_no_sign.jpg`: os medalhões a 720 recortados sem a placa (teste de reconhecimento): Bênção,
  Cura (Fonte), Mais Vida (coração), Mais Magia, Morvath (três divisas), Bênção na porta da sala vencida, Romã pintada,
  Altar (velas pintadas), coração e Bênção nas portas do altar. `detail/altar_gold_blessing_720.jpg`: Ouro e Bênção lado
  a lado em três execuções do altar.
- `detail/reliquary_stele_6s.mp4`: 3 s dos relicários da loja e 3 s da estela da Provação (10 qps, 1280 x 720).
- `detail/*_before_after.jpg`: loja, estela, Fonte, portal, braseiro e janelas da Câmara.
- `compat/`: o mesmo no Compatibility (OpenGL na GPU, `--rendering-driver opengl3`, 1280 x 720).

## Quadro inteiro (`tools/frame_stats.py`, 1080)

| Sala | Luma antes | Luma depois | Sat. p90 antes | Sat. p90 depois | Violeta > 60% antes | depois |
|---|---|---|---|---|---|---|
| Loja | 58 | 57 | 25 | 24 | 0,9 | 0,2 |
| Altar | 53 | 52 | 23 | 23 | 0,1 | 0,0 |
| Provação | 43 | **56** | 12 | 13 | 0,7 | 0,1 |
| Fonte | 61 | 58 | 26 | 24 | 0,0 | 0,0 |
| Sala vencida (Cripta) | 57 | 59 | 12 | 14 | 0,0 | 0,0 |
| Vitrine (salão) | 57 | 55 | 27 | 26 | 0,0 | 0,1 |
| Câmara do Selo | 59 | 58 | 30 | 28 | 4,1 | 4,1 |
| Câmara, faixa de cima (y < 300) | 49 | 45 | **36** | **24** | 6,4 | 6,4 |

A faixa de cima da Câmara inclui a barra de Morvath (HUD) e a bruma violeta, que não mudaram; o violeta acima de 60% do
quadro inteiro fica em 4,1% (meta 5%).

## Caixas (`scratchpad measure.py`: luma BT.601, pixels com os três canais acima de 235, maior canal, matiz mediano dos quentes)

| Peça (caixa a 1080) | Antes | Depois |
|---|---|---|
| Braseiro norte da vitrine (990,80,70,90) | 112 px acima de 235, matiz 27 | 0 px, matiz 18 |
| Braseiro oeste da vitrine (410,150,70,90) | 126 px, matiz 24 | 0 px, matiz 19 |
| Braseiro sudeste da vitrine (1520,680,90,110) | 276 px, matiz 29 | 0 px, matiz 16 |
| Braseiro leste da vitrine (1840,500,80,110) | 234 px, matiz 31 | 0 px, matiz 25 |
| Braseiros da loja (670,90 e 1260,30, 90 x 90) | 154 e 132 px | 0 e 0 px, matiz 19 |
| Braseiros da Câmara (1075,150,75,75 e 1500,215,90,90) | 168 e 188 px | 0 e 0 px, matiz 19 e 20 |
| Miolo do portal (1480,180,90,70) | desvio da luma 15,2, maior canal 255, verde 100% | desvio 26,5 (1,7 vez), maior canal 239, verde 63% |
| Verde saturado do quadro (vitrine) | 2,3% | 2,1% |

## Desempenho e encaixe

- iGPU do notebook na Baixa, 1280 x 720 (`tools/gpu.sh run ... --gpu-index 1`, duas rodadas, qps): salão 58 e 40 antes,
  55 e 55 depois; loja 57 e 59, 57 e 59; Fonte 60 e 60, 60 e 61; Provação 74 e 85, 86 e 87; altar 56 e 81, 84 e 85;
  Câmara 48 e 59, 59 e 59. Nenhuma sala cai mais de 3 qps (o salão, 58 contra 55 na melhor rodada, fica no limite).
- `tools/fit_probe.gd -- --arena=trial|altar` (aceita as câmaras de evento desde o AP-1): Provação fantasma 1,12 m²
  antes e depois, altar 3,36 m² antes e depois; nenhuma peça sem desenho, chão vazio nem borda falsa. O que sobra são os
  pilaretes das bocas das portas, que já estavam lá.
