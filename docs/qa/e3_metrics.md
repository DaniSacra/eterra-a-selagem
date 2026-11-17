# E3 "Bênçãos e combinações": métricas do robô (parte de jogo)

Medido em 2026-11-17 no worktree do `gameplay-engineer`, descida padrão de 10 salas com Morvath na 11.
Comando (8 sementes, 4 por vez, a partida inteira):

```
godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=900 --seed=N --bot-reaction=0.25
```

Script e saídas brutas fora do repositório: `/home/dani/tools/e3/metrics.sh`, `summary.py`, `m1/` (primeira medida),
`m2/` (a entregue). Robô com reação de 0,25 s, sem Dons equipados, sem ultimate.

## Aceite

| Meta | Resultado | Situação |
|---|---|---|
| Chega a Morvath com 5 a 8 Bênçãos em 6 de 8 | 7 de 8 (5, 6, 6, 7, 7, 7, 6; a semente 8 caiu no guardião) | ok |
| Compra na loja em 6 de 8 | 7 de 8 (6 compram a cura, 1 a Bênção; a semente 8 não chegou à loja) | ok |
| Vence 3 a 6 de 8 | 5 de 8 (as duas outras mortes na fase 4) | ok |

## Tabela (medida entregue, `m2`)

| semente | Morvath aos (s) | Bênçãos em Morvath | ouro ao entrar na loja | comprou | resultado | fase da morte | tempo total (s) | vida em Morvath | dano por fonte (3 maiores) |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 278.2 | 6 | 88 | cura | vitória | - | 428 | 55 | ataque 7084, especial 3260, flagelo 3109 |
| 2 | 250.6 | 7 | 69 | cura | morte | 4 | 368 | 24.8 | ataque 6012, especial 4058, onda_maior 1892 |
| 3 | 266.3 | 7 | 177 | Bênção | vitória | - | 362 | 33 | ataque 4746, especial 3629, brasas 2549 |
| 4 | 254.1 | 5 | 81 | cura | vitória | - | 372 | 40 | ataque 6347, especial 3158, queimadura 2270 |
| 5 | 269.7 | 6 | 65 | cura | morte | 4 | 401 | 50 | ataque 5000, especial 3206, queimadura 2138 |
| 6 | 235.2 | 7 | 79 | cura | vitória | - | 339 | 50 | ataque 5531, especial 2843, queimadura 2626 |
| 7 | 263.2 | 6 | 82 | cura | vitória | - | 353 | 95 | ataque 5214, especial 3553, Ômega do especial 1669 |
| 8 | - | - | - | - | morte (sala 6, guardião Ancião) | - | 186 | - | ataque 2868, especial 1563, Ômega do ataque 995 |

O robô chega a Morvath entre 3 min 55 s e 4 min 40 s e a partida inteira dura 5 min 40 s a 7 min 10 s (gente bate
menos e anda mais: a meta do C13-01 é 10 a 13 min para gente, ainda não medida). Ouro ao entrar na loja: 65 a 177
(mediana 81), quase todo dos inimigos (o robô prefere Bênção a ouro nas portas).

## O que mudou entre as duas medidas

| | `m1` | `m2` (entregue) |
|---|---|---|
| Loja | um item de cada grupo (3 itens) | 1 + 2 + 2 = 5 itens, como a última loja antes do chefe final no Hades II |
| 5 a 8 Bênçãos em Morvath | 7 de 8 | 7 de 8 |
| Compra na loja | 4 de 8 (sem cura nem fatia na prateleira, 69 a 88 de ouro não compravam nada) | 7 de 8 |
| Vence | 3 de 8 | 5 de 8 |

Nas duas o robô já escolhia a porta como um jogador (`Rooms.bot_door`: fonte, Bênção, romã, coração, ouro, Magia);
antes da E3 ele passava sempre pela primeira porta, e as Bênçãos que recebia eram o sorteio do baralho, não uma escolha.
Morvath não mudou.

## Para o QA

- `tools/smoke.sh 300 --seed=5` não chega mais em Morvath (ele chega aos 4 a 5 min): usar `tools/smoke.sh 600 --seed=5`,
  ou `--medium` (a descida de 7) para o tempo de antes.
- O `RESULT` traz `dealt_by` (dano por fonte: `attack`, `special`, `cast`, `cast_omega`, `dash`, `omega_attack`,
  `omega_special`, `ultimate`, cada Bênção que age sozinha pelo id, `burn`, `shatter`, `embers`, `bastiao`, `other`) e
  `elos` (Elos formados).
- Falta a medida com gente (C13-08 é do `qa-performance`, com o registro das partidas).
