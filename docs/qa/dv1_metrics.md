# DV-1, Descida de Valmor: régua do robô antes e depois do grafo (MAP-04)

Régua da E6: `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, Maestria 1, sementes 1 a 72.
Base: `90e069b` (fila de salas do C17). Depois: o grafo da descida (`RunMap`, MAP-01/02) com o robô que lê o mapa
(`Rooms.bot_door`, `bot_way`) e a segunda fonte (`StageDef.fountain_more_chance` 1,0).

## Resultado

| | base 1-24 | grafo 1-24 | base 25-72 | grafo 25-72 | **base 1-72** | **grafo 1-72** |
|---|---|---|---|---|---|---|
| vitórias | 24 | 19 | 34 | 37 | **58** | **56** |
| chegaram a Morvath | 24 | 22 | 45 | 47 | 69 | 69 |
| fonte bebida | 19 | 12 | 35 | 30 | 54 | 42 |
| vida ao chegar a Morvath (mediana) | 55 | 55 | 50 | 49 | 55 | 51,4 |
| Provação tomada | 8 | 10 | 21 | 23 | 29 | 33 |
| altar usado | 0 | 1 | 3 | 1 | 3 | 2 |

- Chegada a Morvath: mediana 239,4 s na base, 233,2 s no grafo.
- Bênçãos ao chegar a Morvath: mediana 6 nos dois (3 a 8).
- Ouro ao entrar na loja: mediana 79 (54 a 196) na base, 85 (62 a 275) no grafo; compraram em 69 de 69 nos dois.
- Presos (`stuck` + `bot.stuck`): 0 nos dois.
- Promessa (`dv1_regua.py`): em 72 descidas, toda porta tomada levou ao nó que mostrava, com a recompensa e a arena
  prometidas, e todo passo do caminho é uma ligação do grafo: 0 quebras.

As sementes 1 a 24 da base foram uma série boa (24 de 24; nas 48 seguintes a base vence 71%). Por isso a régua foi
estendida a 72 sementes: 56 contra 58, dentro do aceite (no máximo 2 abaixo da base).

## O que mudou no caminho até aqui

| rodada | robô | fonte | vitórias 1-24 |
|---|---|---|---|
| r_new | um passo à frente abaixo de 80% da vida | uma por rota (35% por camada, senão a 8) | 19 |
| r_new2 | um passo à frente com qualquer ferida | igual | 20 |
| r_new3 | lê o mapa inteiro (`bot_way`, `BOT_AHEAD` 0,5) | igual | 19 |
| r_new4 | igual | segunda fonte na última profundidade, em outro ramo | 17 |
| r_new5 | `BOT_AHEAD` 1,0, fonte à frente vale 12 | igual | 19 (56 de 72) |

O que pesa: antes do mapa a fonte vinha sempre, oferecida de novo até a última profundidade, e o robô bebia em 54
de 72; no grafo cerca de metade das rotas tem fonte e o robô precisa escolher o ramo antes de estar ferido. A
segunda fonte (na profundidade 8, num ramo que não passa pela primeira) devolve a fonte tardia de antes para quem
passou bem pela primeira.

## Como refazer

Scripts de trabalho (fora do repositório): `regua.sh <projeto> <saida> sementes...` roda 4 de cada vez;
`dv1_regua.py <pastas>` resume (vitórias, Morvath, Bênçãos, ouro, presos, promessa); `dv1_more.py` dá a tabela acima.
