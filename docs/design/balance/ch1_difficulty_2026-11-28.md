# F1: dificuldade do Capítulo I (2026-11-28, balance-designer)

Medido no HEAD de 2026-11-28 (elites x1,0, PT-28), só leitura, um processo por vez. O robô não é gente: serve para comparar versões, não como taxa real; calibrar com o `RunLog` do Daniel.

Comandos (12 sementes fixas 1 a 12, `tools/smoke.sh 600 --seed=N --bot-reaction=0.25`):
- **Base** (Maestria 0, sem Dons).
- **Meio**: `--talents=disciplina,cadencia,determinacao,forca_concentrada,concentracao` (5 Dons de número; `--vine=N` só age na tela da Videira, não na descida, então o "meio do caminho" é por Dons).
- **Maga**: `--hero=maga`, sementes 1 a 6.

Meta: de 12, 6 a 9 chegam a Morvath e 1 a 4 vencem.

## Resultado

| | chegam a Morvath | vencem | morrem na sala 5 (Ancião) | morrem antes de Morvath, sala 10 a 12 |
|---|---|---|---|---|
| Base | 6 de 12 (1,2,3,4,6,10) | 0 | 3 (7, 9, 12) | 3 (5, 8, 11) |
| Meio (5 Dons) | 7 de 12 (2,3,4,6,7,8,9) | 0 | 0 | 5 (1, 5, 10, 11, 12) |


### Base, por semente (tempos por sala em s; a última é a sala onde morreu)

| sem. | sala | Morvath aos | fase / vida do chefe que sobrou | causa (vida perdida) | tempos |
|---|---|---|---|---|---|
| 1 | 14 | 499 s | fase 1, 12138 | priest_elder 30, knight 26 | 18,36,19,29,115,5,70,28,5,90,33,38,5,31 |
| 2 | 14 | 352 s | fase 2, 6456 | mage 42, melee 36 | 14,26,2,20,34,57,41,22,5,5,65,22,24,6,132 |
| 3 | 14 | 367 s | fase 2, 4850 | melee 42, mage 28 | 15,25,24,22,57,39,2,29,2,5,59,27,46,6,133 |
| 4 | 14 | 436 s | fase 3, 4119 | melee 44, archer 23 | 13,33,36,27,54,37,37,49,5,58,42,28,6,119 |
| 5 | 11 | não | sala 11 | archer 42, priest_elder 35 | 14,26,2,17,30,79,6,45,74,70,133,36 |
| 6 | 14 | 451 s | fase 2, 8334 | melee 50, priest_elder 27 | 16,18,23,23,67,5,62,59,5,92,34,34,6,143 |
| 7 | 5 | não | Ancião | priest_elder 55 | 11,22,20,34,99 |
| 8 | 12 | não | sala 12 | archer 22, priest_elder 20 | 15,29,2,15,22,42,5,26,38,39,66,40,14 |
| 9 | 5 | não | Ancião | priest_elder 47 | 14,39,14,30,66 |
| 10 | 14 | 425 s | fase 2, 6245 | mage 53, melee 50 | 14,26,19,30,43,32,28,6,56,52,62,43,6,115 |
| 11 | 11 | não | sala 11 (runas) | priest_elder 25, mage 21 | 14,22,17,39,2,78,6,42,53,5,84,35 |
| 12 | 5 | não | Ancião | priest_elder 41 | 15,16,19,15,79 |

### Meio (5 Dons), por semente

| sem. | sala | Morvath aos | fase / vida do chefe que sobrou | causa |
|---|---|---|---|---|
| 1 | 12 | não | | archer 29, mage_elite 27 |
| 2 | 14 | 403 s | fase 4, **1191** | mage 42, priest_elder 40 |
| 3 | 14 | 356 s | fase 4, **1734** | mage 70, melee 41 |
| 4 | 14 | 389 s | fase 2, 5630 | melee 43, runner_elite 27 |
| 5 | 10 | não | | priest_elder 57, archer 24 |
| 6 | 14 | 453 s | fase 2, 6082 | archer 50, mage 41 |
| 7 | 14 | 403 s | fase 3, 3058 | mage 70, priest_elder 35 |
| 8 | 14 | 349 s | fase 1, 10674 | melee 37, archer 29 |
| 9 | 14 | 340 s | fase 4, **2045** | melee 36, archer 25 |
| 10 | 12 | não | | runner_elite 47 |
| 11 | 10 | não | | priest_elder 26, archer 13 |
| 12 | 11 | não | | knight 27, mage 25 |

Nota: a semente 12 do Meio e a Maga rodaram depois de dois merges de outros agentes (Capítulo II e Santuário; nenhum muda o Capítulo I).

### Maga (6 sementes, limite de 600 s)

2 de 6 chegam a Morvath (sementes 1 e 2, aos 555 e 457 s; sobram 11972 e 5149 de vida do chefe); 4 de 6 batem o relógio de 600 s nas salas 11 e 12 (tempos de 165 e 190 s numa só sala), não morrem. Vida perdida é baixa (15 a 44 por semente, contra 50 a 120 do Guerreiro), então ela é lenta, não frágil: dano grátis só rende a menos de 4 m e o robô não escolhe alvo (já dito em `heroes/maga_redesign_v1.md`). Não vence em 600 s; com 900 s o doc dela registra vitória. Sem ajuste agora: medir de novo com 900 s e com gente.

## Leitura

1. **Alcance de Morvath está na faixa** (6 a 7 de 12; meta 6 a 9). Dentro do pedido do PO (descida muito difícil).
2. **Vitórias fora da meta (0 de 12 nos dois perfis).** O chefe é a barreira: 14400 de vida (6000 x 2,4), 4 fases, 109 a 157 s por tentativa (a luta sozinha leva 34 a 157 s). No Meio, 3 sementes morrem com 1191, 1734 e 2045 de vida dele sobrando (8 a 14%).
3. **Ancião (sala 5, `elder_hall`) é um muro para o Base**: 3 de 12 (25%) morrem ali, com 41 a 55 de vida perdida só do `priest_elder` (orbe, `attack_damage` 5, recarga 3,9 s, vida 2500 x 1,5). O Meio não morre ali. Isso é coerente com "difícil sem Dons", mas morrer na sala 5 em 25% das tentativas é cedo demais para ensinar; o tempo da luta chega a 100 a 134 s.
4. Dano que mais machuca: melee e mage (sala a sala), `priest_elder` na sala 5 e `archer` nas salas 10 a 12.

## Proposta (números em `tools/make_data.gd`, ninguém mexeu; dono: gameplay-engineer aplica)

| prio | o quê | antes | depois | efeito esperado | como medir |
|---|---|---|---|---|---|
| P1 | `MORVATH_HP_X` | 2,4 (14400) | **2,1 (12600)** | no Meio as sementes 2 e 3 (e talvez 9) viram vitória: 2 a 3 de 12; no Base continua 0 a 1 | `--talents=` do Meio, 12 sementes; regenerar com `make_data.gd -- enemies` |
| P2 | `priest_elder` `attack_cooldown` (linha 485) | 3,9 | 4,6 | morte na sala 5 do Base cai de 3 de 12 para cerca de 1 | Base, 12 sementes; passa pelo `combat-feel-director` (muda o tempo de um ataque) |
| P2 | não mexer em elites, `BIG_HP_X`, `GUARDIAN_HP_X`, vida do herói | | | o alcance de Morvath já está em 6 a 7 de 12 | |

Se com a mudança P1 o Meio passar de 4 vitórias de 12, voltar para 2,25. Maestria alta e Juramentos não foram medidos aqui.

## Depois do teste do Daniel

Comparar com o `RunLog`: se humanos morrem mais cedo que o robô (esperado), manter os números; se vencem mais que 1 de 3 sem Dons, subir o `MORVATH_HP_X` de volta.
