# Progressão das salas (room-designer)

Índice. Progressão das salas da descida: tamanho, forma, obstáculos, perigos de sala que pedem pensar (laje, raiz, coluna, fenda, corrente), atlas de plantas, quebráveis, ritmo do Plano SWORN e as revisões datadas. O texto fica nos arquivos da pasta `rooms_progression/`; leia só o que a tarefa pede. As partes de 2026-11-19 a 2026-11-21 que são só histórico de sugestões e revisões estão nos arquivos `historico-*`.

| Arquivo | Do que trata | Seções |
|---|---|---|
| [rooms_progression/state-and-recent-lots.md](rooms_progression/state-and-recent-lots.md) | Estado atual (2.x), Fase 2 SWORN, guardiões, Lotes R6, R7, S, Antessala, varreduras e portas afastadas (2026-11-23 a 27) | Estado em 2026-11-19; Fase 2 SWORN, ritmo das salas e da descida; Salas dos guardiões; Lote R6; ... |
| [rooms_progression/hazards-rp.md](rooms_progression/hazards-rp.md) | Perigos de sala feitos (RP-01 a RP-17, LR-03 a LR-06) e lotes SR-P (laje que cede, grade, relíquia) | Feito em 2026-11-20; Feito em 2026-11-20; Feito em 2026-11-20; Feito em 2026-11-20; ... |
| [rooms_progression/atlas-and-breakables.md](rooms_progression/atlas-and-breakables.md) | Lote A1, protótipos do atlas, plantas AT-CA2/SE2/PB2/FO2 e regras dos quebráveis por sala (2026-11-21) | Lote A, frente A1; Lote D, protótipos do atlas e quebráveis; Lote D, hipóteses de planta do atlas; Atlas, colunas 2 e 3: regras dos quebráveis por sala, C |
| [rooms_progression/historico-suggestions.md](rooms_progression/historico-suggestions.md) | Histórico: Sugestões de 2026-11-19 | Sugestões 2026-11-19 |
| [rooms_progression/historico-sworn-ideas.md](rooms_progression/historico-sworn-ideas.md) | Histórico: Ideias da referência Sworn de 2026-11-19 | Ideias da referência Sworn |
| [rooms_progression/historico-layout-review.md](rooms_progression/historico-layout-review.md) | Histórico: Revisão de layout de 2026-11-19 (build d2ff05d) | Revisão de layout 2026-11-19 |
| [rooms_progression/historico-hades-benchmark.md](rooms_progression/historico-hades-benchmark.md) | Histórico: Benchmark Hades II (capturas do Daniel, 2026-11-19) | Benchmark Hades II |

## Capítulo II, salas do Bosque (A-6, 2026-11-28)
Greybox em `_bosque_gates/_bosque_garden/_bosque_temple` (`tools/make_data.gd`), no `data/stages/bosque.tres` com o Salão (fonte, loja) e as casas dos guardiões do Capítulo I; look `bosque`. Portões (0 a 0,3 da descida, a sala que ensina: 3 a 5 vivos, centro aberto, pátio de estátuas); Jardim dos Esporos (anel de 8 cogumelos baixos em volta de uma ilha, terraços com escada de 4 m); Templo Inundado (dois canais de água rasa cruzados por duas pontes secas, plataforma redonda de 4 colunas). Duas portas afastadas (11,6 a 12,4 m) com estátua entre elas, nada sólido na aproximação. `RoomLayout.water` marca a água rasa (andável, sem dano); o -15% de movimento e a rota seca por jogo são do A-5, onde também entram raízes e esporos (os perigos ficam nas pontas da tela). Sem variantes B ainda (D2-9).
