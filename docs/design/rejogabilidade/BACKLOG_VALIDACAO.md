# Backlog proposto e riscos
| Ordem | Slice | Critério |
|---|---|---|
| 0 | Auditoria do HEAD/cânone/código/decisões | matriz rastreável, sem implementação |
| 1 | Taxonomia de recompensas | portas distintas, ícones claros, seed estável |
| 2 | Distribuição do mapa | testes de muitas seeds e nenhuma rota inviável |
| 3 | Encontro 2 entidades → 3 bênçãos | pool elegível, fallback, UI |
| 4 | Integração com Elo/raridades | regras e tags preservadas |
| 5 | Materiais + uma melhoria permanente | persistência e save legado |
| 6 | Forja Emeth | upgrade completo, custo e feedback |
| 7 | 3 Encantos de run | exclusões e impacto real |
| 8 | 3 Encantos adicionais | total 6, balanceados |
| 9 | 1 ferramenta perdida do Forjador | missão e unlock funcional |
| 10 | Discernimento I | reroll limitado, sem garantia |
| 11 | Fragmentos de Memória | só se aprovados após análise |
| transversal | Métricas e testes | bots, vídeos, screenshots e teste humano ao final |

## Proteção de decisões e cânone
`docs/design/warrior_spec.md` é referência para identidade e limitações do Guerreiro. `docs/design/po_directive_guardian.md` contém D-50, D-54, D-56 a D-61. Há conflitos canônicos D-64 a D-69 e origem das Bênçãos D-51 pendente. Consultar diretamente o cânone `../dungeon-rpg/docs/mundo/canone.md` antes de nomear anjos e ferramentas; **não foi lido integralmente na montagem deste pacote**.

## Critérios de aceite transversais
- Testes unitários de ofertas, pré-requisitos, exclusões e custo.
- Testes de integração de run, boss, hub e save legado.
- Mesmo seed + mesmo estado = mesmo mapa/ofertas.
- Bot para distribuição de recompensas e balanceamento; teste humano no fim da versão.
- Sem regressão do combate com pés plantados, esquiva, câmera e runas.

## Não fazer
Outros heróis; múltiplas armas equipáveis; escudo/aparo; barra nova de Fúria; novo baralho de tarô; dezenas de moedas; anjos canônicos inventados; reescrita total do mapa.

## Referências verificadas
- GitHub `arpg-3d`: `docs/design/warrior_spec.md`, `docs/design/po_directive_guardian.md`, `docs/design/hades2_sistemas.md`, `scripts/game/rooms.gd` e `docs/backlog.md` (consulta parcial).
- Commit mais recente encontrado: `29039f1331d0a7002cf98b498575cd054403d408`; confirmar HEAD local.
- Inspirações: Hades II, SWORN, Ravenswatch. Arte do pacote é conceitual, não extraída desses jogos.
