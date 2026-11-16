# Métricas da luta de Morvath (ciclo 9): simulações do robô

**Tudo aqui é SIMULAÇÃO do robô (`scripts/game/bot.gd`), não teste com gente.** O robô joga sem tela, no Linux (Godot
4.7.2, `--headless --fixed-fps 60`), com a mesma lógica do jogo. Ele não erra a mira, não se distrai e conhece o
próximo perigo pelo aviso no chão; `--bot-reaction=0.25` só atrasa em 0,25 s o que ele vê (um tempo de reação humano),
o resto continua perfeito. Servem para comparar configurações e achar extremos, não para dizer quão difícil é para o Daniel.

- Data: 2026-11-15. Commit testado: `b29e372` (o `1f9d49c` de agora só muda `.claude/agents/` e `CLAUDE.md`; nenhum
  arquivo de `scripts/`, `data/`, `assets/` ou `tools/`).
- 80 partidas, nenhuma com `SCRIPT ERROR` (todas com o `ERROR: 1 resources still in use at exit` de sempre).
- Script: `/home/dani/games/c9qa/tools/metrics.sh` (apagado ao fim; o comando de cada linha está abaixo). Saída de cada
  partida: a linha `RESULT` (campo `boss`, `Boss.stats`).

## Configurações

`godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=600 --start=boss <dons> --bot-reaction=<0 ou 0.25> --seed=<1..8>`

| Nome | Dons (`--boon-ids`, 6 dons, um estilo) |
|---|---|
| fogo | `golpe_brasa,pesado_brasa,circulo_brasa,passo_brasa,brasas,lamina_ardente` |
| geada | `golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno` |
| luz | `golpe_radiante,pesado_radiante,circulo_radiante,passo_radiante,onda_maior,consolo` |
| sorteados | `--boons=6` (seis sorteios; ficam 4 a 6, porque um dom do mesmo botão substitui o anterior) |
| partida inteira | `--smoke=900` sem `--start` (as 4 salas antes de Morvath; o robô chega com 1 ou 2 dons) |

8 sementes por linha (1 a 8), reação 0 e 0,25: 4 x 2 x 8 = 64 lutas começando no chefe e 16 partidas inteiras.

## 1. Vitórias, tempo e fases

"Tempo da luta" é `boss.time` (da entrada de Morvath até a queda). As fases são `boss.phase_time` das vitórias.
Nas derrotas, "vida de Morvath" é o que sobrava dos 6050.

| Configuração | Reação | Vitórias | Mortes (fase: n) | Tempo da luta nas vitórias, mediana (faixa) | Fase 1 / 2 / 3 / 4 nas vitórias (mediana, s) | Vida que sobrou nas vitórias | Vida de Morvath nas derrotas |
|---|---|---|---|---|---|---|---|
| fogo | 0 | **8 de 8** | 0 (-) | 99,7 (95,5 a 108,3) | 26,8 / 42,0 / 15,8 / 16,1 | 30, 30, 27, 30, 30, 20, 20, 30 | - |
| fogo | 0,25 | **2 de 8** | 6 (2: 1, 3: 1, 4: 4) | 101,1 (98,1 a 104,1) | 28,0 / 38,6 / 18,2 / 16,2 | 24, 10 | 818, 598, 49, 1082, 2094, 651 |
| geada | 0 | **8 de 8** | 0 (-) | 127,6 (112,3 a 129,2) | 32,0 / 52,8 / 18,4 / 19,4 | 30, 30, 22, 30, 30, 18, 16, 14 | - |
| geada | 0,25 | **3 de 8** | 5 (3: 1, 4: 4) | 125,3 (120,3 a 127,3) | 35,4 / 52,9 / 17,2 / 18,3 | 26, 12, 8 | 383, 1813, 761, 686, 646 |
| luz | 0 | **8 de 8** | 0 (-) | 97,8 (94,5 a 100,1) | 25,6 / 39,8 / 14,7 / 16,1 | 30, 30, 30, 29, 25, 30, 20, 30 | - |
| luz | 0,25 | **1 de 8** | 7 (4: 7) | 112,3 (112,3 a 112,3) | 26,3 / 50,7 / 20,0 / 15,3 | 1 | 290, 802, 94, 200, 612, 648, 676 |
| sorteados | 0 | **8 de 8** | 0 (-) | 109,0 (82,4 a 129,4) | 27,8 / 48,5 / 15,5 / 17,3 | 21, 50, 55, 30, 27, 30, 50, 18 | - |
| sorteados | 0,25 | **8 de 8** | 0 (-) | 107,6 (83,2 a 137,3) | 29,4 / 44,7 / 17,5 / 15,1 | 2, 34, 9, 20, 28, 2, 30, 24 | - |
| partida inteira | 0 | **7 de 8** | 1 (4: 1) | 128,7 (112,3 a 142,8) | 31,1 / 56,2 / 18,6 / 20,0 | 52, 27, 18, 14, 30, 44, 11 | 560 |
| partida inteira | 0,25 | **1 de 8** | 7 (2: 4, 3: 2, 4: 1) | 114,8 (114,8 a 114,8) | 40,2 / 38,1 / 18,6 / 17,9 | 28 | 1418, 3799, 3866, 3704, 1622, 68, 3837 |

## 2. Dano recebido por ataque (soma das 8 partidas; entre parênteses, quantos golpes)

`boss.hurt_by` e `hits_by`. `adds` são os mortos que ele levanta; `ritual` são as erupções durante o ritual; `dash`
é a investida. Um golpe de cada: foice 12, lâminas 10, erupção 10, investida 12, maldição 6, tempestade 10, morto 4.

| Configuração | Reação | scythe | blades | dash | eruptions | ritual | adds | curse | storm | total |
|---|---|---|---|---|---|---|---|---|---|---|
| fogo | 0 | 0 | 0 | 0 | 0 | 0 | 3 (1) | 0 | 20 (2) | 23 |
| fogo | 0,25 | 0 | 20 (2) | 0 | 20 (2) | 0 | 64 (16) | 54 (9) | 48 (7) | 206 |
| geada | 0 | 12 (1) | 0 | 0 | 10 (1) | 10 (1) | 12 (3) | 6 (1) | 0 | 50 |
| geada | 0,25 | 0 | 0 | 0 | 0 | 10 (1) | 72 (18) | 48 (8) | 64 (7) | 194 |
| luz | 0 | 0 | 0 | 0 | 0 | 0 | 4 (1) | 6 (1) | 10 (1) | 20 |
| luz | 0,25 | 0 | 10 (1) | 0 | 0 | 10 (1) | 104 (26) | 54 (9) | 88 (12) | 266 |
| sorteados | 0 | 12 (1) | 10 (1) | 0 | 0 | 0 | 4 (1) | 0 | 10 (1) | 36 |
| sorteados | 0,25 | 0 | 0 | 0 | 0 | 10 (1) | 64 (16) | 42 (7) | 60 (6) | 176 |
| partida inteira | 0 | 48 (4) | 10 (1) | 0 | 10 (1) | 0 | 20 (5) | 6 (1) | 20 (2) | 114 |
| partida inteira | 0,25 | 36 (3) | 10 (1) | 0 | 16 (2) | 10 (1) | 97 (26) | 39 (7) | 40 (4) | 248 |

## 3. Ataques usados, janelas e punições

`boss.attacks` (soma das 8), `chains` (combinações da fase 4), `windows` (recuperações depois de um ataque) e `punished`
(janelas em que o robô acertou Morvath).

| Configuração | Reação | scythe | blades | dash | eruptions | summon | curse | storm | combinações | janelas | punidas | % |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fogo | 0 | 87 | 21 | 0 | 23 | 18 | 15 | 9 | 1 | 156 | 137 | 88 |
| fogo | 0,25 | 87 | 22 | 0 | 25 | 16 | 12 | 7 | 2 | 153 | 135 | 88 |
| geada | 0 | 121 | 21 | 0 | 30 | 16 | 14 | 14 | 7 | 202 | 171 | 85 |
| geada | 0,25 | 114 | 24 | 0 | 28 | 16 | 13 | 11 | 3 | 190 | 124 | 65 |
| luz | 0 | 84 | 19 | 0 | 25 | 16 | 12 | 12 | 5 | 154 | 139 | 90 |
| luz | 0,25 | 90 | 21 | 0 | 24 | 12 | 13 | 11 | 3 | 158 | 122 | 77 |
| sorteados | 0 | 93 | 18 | 0 | 29 | 11 | 14 | 13 | 6 | 161 | 140 | 87 |
| sorteados | 0,25 | 107 | 26 | 0 | 23 | 21 | 14 | 12 | 5 | 186 | 130 | 70 |
| partida inteira | 0 | 118 | 36 | 0 | 29 | 17 | 15 | 14 | 2 | 211 | 166 | 79 |
| partida inteira | 0,25 | 91 | 23 | 0 | 13 | 11 | 9 | 3 | 2 | 145 | 111 | 77 |

## 4. Reforços, ritual e maldições

`adds_total` (mortos levantados na luta), `adds_peak` (mais de pé ao mesmo tempo), `ritual` (segundos do ritual; 20 é o
limite `ritual_time`, ou seja, o robô não derrubou os mortos a tempo), `curses` (maldições que pegaram).

| Configuração | Reação | Reforços por luta (mediana, faixa) | Pico de pé | Ritual (s, mediana, faixa) | Maldições que pegaram | Chegada em Morvath (s) | Dons |
|---|---|---|---|---|---|---|---|
| fogo | 0 | 11,0 (8 a 14) | 4 | 11,4 (10,3 a 20,0) | 0 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| fogo | 0,25 | 10,0 (8 a 14) | 4 | 14,1 (5,0 a 17,7) | 9 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| geada | 0 | 12,0 (8 a 16) | 4 | 16,8 (9,4 a 20,0) | 1 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| geada | 0,25 | 11,0 (8 a 14) | 4 | 13,2 (9,7 a 20,0) | 7 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| luz | 0 | 10,0 (6 a 12) | 4 | 9,9 (5,5 a 17,6) | 1 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| luz | 0,25 | 12,0 (8 a 12) | 4 | 20,0 (11,0 a 20,0) | 9 | - | 6, 6, 6, 6, 6, 6, 6, 6 |
| sorteados | 0 | 10,0 (8 a 14) | 4 | 17,4 (9,5 a 20,0) | 0 | - | 5, 5, 5, 6, 4, 6, 5, 4 |
| sorteados | 0,25 | 11,5 (10 a 16) | 4 | 11,6 (4,4 a 20,0) | 11 | - | 5, 5, 5, 6, 4, 6, 5, 4 |
| partida inteira | 0 | 12,0 (8 a 15) | 4 | 20,0 (11,8 a 20,0) | 1 | 64,5 (57,8 a 73,9) | 2, 2, 2, 2, 2, 2, 2, 1 |
| partida inteira | 0,25 | 11,0 (4 a 15) | 6 | 20,0 (12,0 a 20,0) | 5 | 64,7 (56,9 a 77,2) | 2, 2, 2, 2, 2, 2, 2, 1 |

## 5. Leitura (QA; o balanceamento é do Gameplay Engineer e do Daniel)

1. **Reação perfeita (0)**: 32 de 32 vitórias começando no chefe e 7 de 8 nas partidas inteiras. Quase não leva dano
   (20 a 50 de vida somando 8 lutas). Com reação zero o robô não serve para medir dificuldade, só para regressão.
2. **Reação de 0,25 s**: com seis dons de um só estilo vence pouco (fogo 2, geada 3, luz 1 de 8); com dons sorteados
   vence 8 de 8; na partida inteira (1 ou 2 dons) vence 1 de 8. Das 18 derrotas com estilo fixo, 15 são na fase 4.
   Nas sorteadas a vida que sobra varia de 2 a 34; 3 das 8 sementes sorteadas trazem dons de vida (terminaram com 50 ou 55
   com reação 0), o que pode explicar parte da diferença; não investiguei além disso.
3. **O que mais fere com reação 0,25**: os mortos invocados (16 a 26 golpes de 4 por configuração, a maior soma em
   todas), a Tempestade das Seis Almas (6 a 12 golpes de 10) e a maldição (7 a 9 golpes de 6). A foice quase nunca acerta
   (0 golpes nas lutas a partir do chefe com reação 0,25; o aviso de 0,8 s basta).
4. **A investida (`dash`) nunca saiu em 80 lutas** (`attacks.dash` = 0 em todas): ela só vale com o paladino a 9 m ou
   mais (`min_dist` 9) e o robô fica perto. Um jogador que se afaste vai vê-la; o robô não testa esse ataque. Ela foi
   vista em `--boss-only=dash` (capturas `05_investida*`, vídeo de ataques).
5. **Ritual**: nas partidas inteiras dura 20 s (o limite) na mediana: o robô com 1 ou 2 dons não derruba os 2 esqueletos e
   os 2 feiticeiros a tempo. Começando no chefe com 6 dons, 10 a 17 s. Pico de mortos de pé: 4 (6 numa partida inteira,
   dentro do teto do ritual).
6. **Janelas punidas**: 79 a 90% com reação 0, 65 a 88% com reação 0,25.
7. **Partida inteira, reação 0,25**: 4 das 7 mortes são na fase 2 (ritual e mortos), com 1 ou 2 dons.
8. **Limite da medida**: `ritual`, `ritual_raised` e `phase_time` só são gravados quando o ritual acaba ou quando alguém
   cai (`boss.gd:801`, `record_death`); se o paladino morre durante o ritual, `ritual` fica 0 (3 partidas inteiras com
   reação 0,25: sementes 3, 4 e 5). Por isso a mediana do ritual da tabela 4 só conta rituais que terminaram.

## Comparação com o antes (`3b22cea`, mesma semente, reação 0, partidas inteiras de `tools/smoke.sh 300`)

| Semente | `3b22cea` | `b29e372` |
|---|---|---|
| 1 | venceu, 175,4 s | venceu, 194,0 s |
| 2 | venceu, 187,0 s | venceu, 199,4 s |
| 3 | perdeu na fase 3 (Morvath com 1888), 137,9 s | venceu, 182,1 s |
| 5 | venceu, 202,2 s | venceu, 206,2 s |
| 7 | venceu, 193,2 s | venceu, 207,9 s |
| `120 --start=boss --boons=25 --seed=5` | venceu, 92,3 s | venceu, 95,6 s |

O `3b22cea` não tinha `--bot-reaction` nem `--boon-ids`, então só essa comparação é possível.
