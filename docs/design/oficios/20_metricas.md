# Ofícios e Descobertas: métricas (metas separadas de medidas)

- 2026-11-20, `game-director` com o `balance-designer` (`10_economia.md` 7). Legenda no `README.md`.
- **Medida** = número tirado do jogo, com a fonte. **Meta** = o que queremos, [PROPOSTA NOVA] até o Daniel aprovar.
  Métrica do robô é simulação, não diversão: as metas de sensação só o teste com gente responde.
- Réguas: r25 (reação 0,25, sementes 1 a 48), r45 (reação 0,45, robô-gente, sementes 1 a 32), `smoke 900`,
  `--ultimate=cleave`, cópia isolada.

## 1. Medido hoje (base, HEAD `9271e95`)

| # | Medida | r25 | r45 | Gente (Daniel, 3 descidas) | Fonte |
|---|---|---|---|---|---|
| B1 | Prata por descida, p50 | 30 | 17 | 16, 32, 54 | `10_economia.md` 1.2 |
| B2 | Memória por descida, p50 | 5 | 2 | 4, 5, 11 | idem |
| B3 | Esmeralda por descida, média | 1,5 | 0,8 | 0 a 1 | idem |
| B4 | descidas até a Forja inteira (260) | 8 a 10 | 12 a 14 | 7 a 8 (estimado) | 1.4 |
| B5 | descidas até todos os Dons abertos (54) | 11 a 13 | 14 a 21 | | 1.4 |
| B6 | Esmeralda sem uso em 32 descidas | 49 | 24 | | 1.4 |
| B7 | Memória por minuto saindo depois da sala 2 contra a descida inteira | 3 vezes | 3,5 vezes | | 6.2 |
| B8 | força da Forja inteira (pontos de vitória) | +4 | +9 | | 4.1 |
| B9 | chegada a Morvath, mediana | 233 s | | | `docs/qa/dv1_metrics.md` |
| B10 | sala de luta, mediana | 23 a 32 s | | | `rooms_progression.md` 2.1 |

Não medido ainda e necessário: tempo no hub entre descidas (pede a linha `hub`, OF-03); portas de material que gente
pega (o `runs.jsonl` já tem os eventos, falta volume).

## 2. Metas do Roteiro A

| # | Meta | Valor | Como medir | Evidência |
|---|---|---|---|---|
| E1 | a Picareta chega cedo o bastante | restaurada na 3ª a 5ª descida (p50), até a 7ª (p90), r45 | campanha do robô (OF-23) | `docs/qa/oficios_a_metrics.md` |
| E2 | coleta não vira simulador | menos de 10 s de coleta por descida e menos de 4% do tempo; chegada a Morvath no máximo 8 s acima de B9 | `gather_s` no `RESULT` | idem |
| E3 | sem farming | nenhuma fonte (portas de material, veio, achado) acima de 1,2 vez a taxa por minuto da descida inteira saindo logo depois dela | `--materials-keep`, `--smoke` curto, r45, 32 sementes | idem, com antes e depois do OF-05 |
| E5 | horizontal de verdade | todo o Roteiro A: vitória r45 dentro de 10 pontos da mesma Forja sem ele (alvo: dentro do ruído) | 32 sementes, mesmas sementes | idem |
| E6 | o hub não pesa | 90 s ou menos no hub entre descidas (mediana); no máximo 2 estações com novidade por volta | linha `hub` (OF-03), gente | `runs.jsonl` do Daniel |
| E7 | a sala marcada é decisão | gente vai à sala marcada em 40 a 80% das vezes que ela está numa porta aberta | eventos `door` | idem |
| E8 | a derrota rende | morte depois do guardião rende pelo menos 40% de uma vitória em Prata | `RESULT.materials` | idem |
| E9 | Dons não atrasam pelo OF-05 | nas 10 primeiras descidas da campanha r45, no máximo 1 Dom aberto a menos que hoje | campanha | idem |
| E10 | mesma semente, mesmo jogo | `RESULT` sem os campos novos idêntico com e sem o catálogo; 200 mapas idênticos | GUT (P1 do `15_prototipo.md`) | GUT |

## 3. Metas do Roteiro B

| # | Meta | Valor |
|---|---|---|
| E4 | os gastos duram a curva | Prata acaba entre a 18ª e a 22ª descida (r45); nenhum material com mais de 30% de excedente antes da Maestria 15 |
| E11 | Esmeralda gasta | excedente em 32 descidas r45 abaixo de 6 (hoje 24) |
| E12 | Encantos | cada Encanto escolhido entre 20 e 45% das vezes que aparece |
| E13 | teto de força do hub | todos os ofícios juntos dentro de +5 pontos de vitória r45 (alvo 0); o hub inteiro até +10 a +15 |
| E14 | Despertar como troca | as três propriedades escolhidas entre 20 e 50% |

## 4. Metas de sensação (só gente responde)

| # | Pergunta | Como saber |
|---|---|---|
| S1 | ver o veio preso dá vontade de voltar? | relato do Daniel; E7 |
| S2 | extrair é recompensa ou tarefa? | relato; quantos veios prontos ele deixou para trás (`gather.got` contra vistos) |
| S3 | a escolha Picareta contra Temperar II existiu? | relato; ordem das compras na linha `hub` |
| S4 | o hub parece vivo com o Vendedor aberto? | relato |

## 5. O que o registro precisa ganhar (para medir)

`finds`, `gather` (vistos, pegos, `gather_s`), `pity`, linha `source: hub` (segundos, estações, compras, gastos) e a
campanha do robô (OF-03, OF-23). Sem isso, E1, E4 e E6 são chute.
