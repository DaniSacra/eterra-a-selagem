# E6, balanceamento da primeira região: métricas do robô

- **Data**: 2026-11-17. **Medido por**: `gameplay-engineer`, na worktree da E6. Decisões em `docs/design/e6_balance.md`.
- **Antes**: `224782a` (E5 integrada), copiado por `git archive` para `/home/dani/tools/e6/base`. **Depois**: a worktree
  com as mudanças da E6. Saídas de cada partida em `/home/dani/tools/e6/runs/<rótulo>/<semente>.txt` (fora do
  repositório).
- **Comando** (8 por vez, 60 qps fixos, sem tela): `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 [montagem]`,
  sementes 1 a 72 (o "antes" com 1 a 24).
- **Montagens**: Maestria 1 = sem nada. Maestria 20 ofensiva = `--talents=quarto_corte,passo_encadeado,impeto,
  avanco_feroz,corte_crescente,lamina_faminta,fio_longo,reserva,firmeza --ultimate=cleave` (a do QA na E2). Maestria 20
  sustento = `--talents=ainda_de_pe,firmeza,respiro,quarto_corte,impeto,lamina_faminta,reserva,corte_crescente,fio_longo
  --ultimate=cleave`. Sem Ainda de Pé = a de sustento com `passo_encadeado,avanco_feroz` no lugar dele.
- São simulações do robô com 0,25 s de reação, não gente.

## 1. Vitórias, Maestria 1 contra 20

| Montagem | Código | Sementes | Vitórias | Vida ao chegar | Luta (média, mín., máx.) | Chega em Morvath (média) | Vitória aos (média) |
|---|---|---|---|---|---|---|---|
| Maestria 1 | antes | 1 a 24 | 16 (67%) | 40,4 | 99,5 / 42,4 / 146,8 s | 248,5 s | 358,1 s |
| Maestria 20 ofensiva | antes | 1 a 24 | 21 (88%) | 50,5 | 89,9 / 60,3 / 127,0 s | 215,8 s | 306,2 s |
| Maestria 1 | depois | 1 a 72 | **52 (72%)** | 42,5 | 103,6 / 42,4 / 166,4 s | 251,5 s | 359,6 s |
| Maestria 20 ofensiva | depois | 1 a 72 | 62 (86%) | 53,6 | 90,8 / 55,9 / 139,0 s | 220,7 s | 314,0 s |
| Maestria 20 sustento, levantar em Morvath (regra antiga, robô novo) | intermediário | 1 a 72 | 72 (100%) | 55,8 | 97,2 / 62,1 / 148,6 s | 220,3 s | 321,0 s |
| Maestria 20 sustento, levantar com 30% (testado, descartado) | intermediário | 1 a 72 | 71 (99%) | 55,7 | 97,1 s | 220,3 s | 320,6 s |
| Maestria 20 sem Ainda de Pé | depois | 1 a 72 | 64 (89%) | 54,6 | 92,2 / 59,9 / 140,5 s | 220,6 s | 315,1 s |
| **Maestria 20 sustento** | **depois** | 1 a 72 | **65 (90%)** | 55,8 | 96,1 / 62,1 / 140,4 s | 220,3 s | 318,8 s |
| Maestria 20 com ápices (`golpe_sem_fim`, `coracao_da_emeth`) | intermediário | 1 a 24 | 18 (75%) | 45,3 | 94,4 s | 222,4 s | 313,9 s |

**Diferença (montagem mais forte contra a Maestria 1, mesmas 72 sementes)**: antes da E6-D1 **+28 pontos** (100 contra 72);
depois **+18 pontos** (90 contra 72). Teto da E6: 25. Indicador D-11 (Maestria 1 vence 3 a 6 de 8): 72%, dentro.

Vitória (V) ou fase da morte (M4; Md = caiu antes de Morvath) por semente, 1 a 72:

```
Maestria 1         V V V M4 M2 V V V V V V M4 V V V V V Md V V V V V V V V V V V V V V M4 V V M4 V M4 M4 V V M4 V M4 V V V V V M4 V Md V M4 V Md V M4 V V M4 V M4 V V M3 V V V V Md M4
M20 ofensiva       V V V V V V V V V V V V M4 V V V V M4 V V M4 V V V V V V V M4 V V V V V V V V V M4 V V M3 V V M3 M4 V M4 M4 V V V V V V V V V V V V V V V V V V V V V V V
M20 sustento       V V M4 M4 V V V V M4 V V V V V V V V V V V V V V M4 V V V V V V V V V V M4 V V V V V V V V V V V V V V V V V M4 V M3 V V V V V V V V V V V V V V V V V
M20 sem Ainda      V V V V V V V V V V V V M4 V V V V M4 V V M4 V V V V V V V V V V V V V V V V V M4 V V M4 V V M4 V V M4 V V V V V V V V V V V V V V V V V V V V V V M4 V
```

## 2. Morvath

Fases nas vitórias (média, s): Maestria 1 25,5 / 38,6 / 20,0 / 21,3; Maestria 20 sustento 24,4 / 33,3 / 18,5 / 19,4.
Com a vida 10% maior (6650, Maestria 1, sementes 1 a 24, com o robô novo): luta 110,3 s (era 100,0) e 20 vitórias de 24,
as mesmas que com 6050. Dano levado nas derrotas da Maestria 1 (72 sementes): tempestade 131, invocados 97, maldição 84,
erupções 60, lâminas 30, foice 12.

Ultimate na sala de Morvath (`ult.boss_uses`, `ult.boss_damage`, novos no `RESULT`): 1,8 uso por luta e 580 de dano em
média, nas três montagens de Maestria 20.

## 3. Dano antes de Morvath (nota 2)

| | Partidas | Soma | Maior fonte |
|---|---|---|---|
| Maestria 1, 10 salas | 72 | 1388 | mago 428, Ancião 364 |
| Maestria 20 ofensiva, 10 salas | 72 | 1229 | mago 384, Ancião 342 |
| Maestria 20 sustento, 10 salas | 72 | 1256 | mago 411, Ancião 297 |
| Maestria 1, 7 salas (`--medium`) | 16 | 130 | Ancião 86 |
| Maestria 20 ofensiva, 7 salas | 16 | 145 | Ancião 99 |
| E2 (QA, 7 salas, código da E2) | 16 / 16 | 76 / 123 | Ancião 27 / 81 |

## 4. Eventos (sementes 1 a 24, Maestria 1)

| | Antes | Depois |
|---|---|---|
| Provação: maldições tomadas | Pobreza 3, Frágil 2, Ferida 1 | Pressa 3, Ferida 2, Frágil 1, Horda 1 |
| Altar: entrou sem trocar | 3 | 0 |
| Chegou à loja sem comprar | 2 | 0 |

## 5. Regressão

| Comando | Resultado |
|---|---|
| `godot --headless --path . -s tools/check.gd` | `CHECK ok` |
| `tools/test.sh` | 85 scripts, **877 testes, 877 passando**, 239 s |
| `tools/smoke.sh 300 --seed=5` | chega em Morvath aos 260,7 s (sala 11), vida 50; o tempo acaba na fase 2 |
| `tools/smoke.sh 600 --seed=5` | **vence aos 371,3 s**, luta de 107 s, vida 50 |
| `tools/smoke.sh 180 --start=boss --boons=25 --seed=5` | **vence aos 83,8 s** (luta de 80,2 s), vida 50, fase 4 |
