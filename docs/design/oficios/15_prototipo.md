# Ofícios e Descobertas: protótipo vertical, "A Primeira Picareta"

- 2026-11-20, `game-director`. Só planejamento. Legenda no `README.md`. Histórias em `17_backlog.md` (OF-01 a OF-18).

## 1. Avaliação da sugestão do Daniel

A "Jornada da Primeira Picareta" é **a melhor escolha de protótipo**: é a menor história que liga descida, mapa, sala,
Forjador, Vendedor, Livro e save, e prova a ideia central do pedido ("vi algo que não podia abrir, voltei e abri").

O que muda na sugestão [PROPOSTA NOVA]:
- **A picareta é achada partida e restaurada**, não fabricada de madeira e ferro (não há madeira no bioma; ferro seria
  Prata com outro nome; dois componentes criam duas moedas e um risco de ciclo).
- **Nenhum NPC novo**: o Forjador restaura (o "Artesão"), o Vendedor encomenda (o "Mercador").
- **Um só contável novo**, a Pedra Funda, que só existe com a Picareta e só serve ao Vendedor.
- **Coleta mínima**: um veio físico por sala elegível, um aperto, depois da luta, só depois da camada do guardião.
- O que fica de fora do protótipo: Inscrever, Despertar, manuscritos, objetivo fixado, Alquimista, outros recursos.

## 2. A jornada, passo a passo (o que o jogador vive)

| Passo | Onde | O que acontece | Sistemas |
|---|---|---|---|
| 1 | descida, Fendas ou Runas depois do guardião | sala vencida: um veio escuro na borda acende com fio cinza-pedra; placa "Extrair" apagada e "Pede: Picareta"; apertar anota | `RunMap` (`Room.vein`), `Rooms.usable` (`use_kind` `vein`), `StationSign.under` |
| 2 | saudação | "Anotado no Livro de Ahk" (primeira vez) | `EloBanner` |
| 3 | hub | placa do Forjador: "Tem um pedido"; folha: PEDE Cabeça da Picareta e 20 Prata; ONDE ACHAR "Numa sala marcada no mapa da descida" | `HubPanel`, `OrderDef` |
| 4 | descida seguinte, mapa | uma sala de luta (profundidade 4 a 8) com o losango do achado; a placa da porta não muda | `Room.find`, `FIND_SALT`, `MapGraph` |
| 5 | a sala marcada | vencida, a cabeça cai junto da recompensa (sem ponto: é automático) com a saudação "Achado: Cabeça da Picareta" | `FindSources`, `Rooms.found` |
| 5b | piedade | se em 2 descidas que passaram do guardião a sala marcada não foi visitada, o guardião vencido a entrega | `oficios.pity` |
| 6 | morte ou vitória | o achado é guardado como os materiais | `Game.log_run`, `bank` |
| 7 | hub, Forjador, aba Oficina | "Restaurar Picareta: 20 Prata" contra "Temperar II: 35 Prata": a primeira escolha de Prata | `ForgeScreen`, `Ledger` |
| 8 | descida | veios das Fendas e Runas (depois do guardião) abrem: "Extrair", um aperto de 1 s, "+1 Pedra Funda" | veio, `MaterialPurse` estendida |
| 9 | hub | a primeira Pedra muda a placa do Vendedor de "Balcão fechado" para "Tem um pedido": 2 Pedra Funda e 30 Prata | `OrderDef` |
| 10 | hub, entrega | o Vendedor abre as Obras e faz a 1ª, "Prévia dos anjos"; o Livro mostra a cadeia inteira em tinta | `RecipeDef`, Livro |
| 11 | descida | o mapa mostra o anjo das salas de Bênção da camada seguinte | `MapScreen`, `Encounters` |

Tempo esperado (meta E1, `20_metricas.md`): a Picareta restaurada entre a 3ª e a 5ª descida (p50), a Obra 1 entre a 5ª
e a 8ª. Nenhum passo depende de vencer Morvath.

## 3. O que entra (escopo do protótipo)

1. Correção do farming, independente (OF-05).
2. Fundação: `Ledger`, `ForgeRank.extra`, save 8 com fixtures v6 a v8, registro 6, linha `hub` (OF-01 a OF-04).
3. Catálogo de achados com a cabeça; marca no mapa com sal próprio; piedade (OF-07).
4. Veio: peça nas Fendas (A e B) e nas Runas (A e B) com `gather_spots`, três estados, um aperto (OF-08, OF-10).
5. Oficina no Forjador (OF-09); Pedra Funda contável com teto 10 (OF-07).
6. Encomenda do Vendedor e Obra 1 (OF-13, OF-14, OF-15).
7. Livro: capítulo Ofícios com Recursos, Ferramentas e Pedidos, "Onde achar" (OF-16); Compêndio conta (OF-18).
8. Robô colhe e leva achados; `RESULT` com `finds`, `gather`, `pity` (OF-11).
9. UI: placa do veio, saudação "Achado", Bolsa com a Pedra Funda quando houver (OF-12).

## 4. Aceite do protótipo (medível)

| # | Critério | Como |
|---|---|---|
| P1 | mesma `--seed`, mesmo mapa e mesmo `RESULT` sem os campos novos, com e sem o catálogo | `test_finds_leave_the_map_as_it_was`, `test_finds_leave_the_run_as_it_was` (200 sementes; smoke 600 seed 5) |
| P2 | nenhum ciclo, todo essencial alcançável de um save vazio só com fontes de derrota | `test_the_oficios_graph_has_no_cycle`, `test_every_essential_is_reachable_from_a_fresh_save` |
| P3 | achado guardado uma vez na morte, na vitória e na saída; nunca ao carregar | `test_a_run_banks_once`, `test_loading_gives_nothing`, `test_quit_mid_run_keeps_finds` |
| P4 | encomenda entregue uma vez, nem com o save recarregado | `test_an_order_is_delivered_once` |
| P5 | saves v1 a v7 abrem inteiros como v8 | `test_every_fixture_opens_whole_as_8` |
| P6 | coleta abaixo de 10 s por descida (robô r25 e r45, 32 sementes) e chegada a Morvath no máximo 8 s acima de 233 s | `gather_s` no `RESULT` |
| P7 | Picareta restaurada até a 5ª descida (p50) e a 7ª (p90) na campanha do robô r45 | campanha (OF-23) |
| P8 | vitória r45 com tudo do protótipo dentro de 10 pontos da mesma Forja sem ele | 32 sementes |
| P9 | nenhuma fonte acima de 1,2 vez a taxa por minuto da descida inteira saindo logo depois dela | `--materials-keep`, `--smoke` curto, r45 |
| P10 | veio: sem colisão nova, 12 x 12 posições saem andando, `NavGrid` igual, nunca sobre laje que fere | teste do veio por arena e variante |
| P11 | a 1280 x 720: placa do veio, folha do Forjador e do Vendedor, capítulo Ofícios sem reticência, corpo 14 px | capturas na GPU (uma por vez) |
| P12 | o Daniel joga 5 descidas seguidas num save novo e diz se a jornada fez sentido | relato dele, `runs.jsonl` |

## 5. Custo e responsáveis

| Frente | Agente | Custo |
|---|---|---|
| Fundação, achados, mapa, veio, encomendas, robô, testes | `gameplay-engineer` | cerca de 1,5 ciclo |
| Folhas, Oficina, capítulo Ofícios, placa, saudação, marca no mapa | `ui-ux-designer` | 1 ciclo, em paralelo a partir dos dados |
| Lugares do veio por arena (`gather_spots`), desvio até 6 m, fora de perigo | `room-designer` | P |
| Peça do veio (3 estados) nas Fendas e nas Runas, na pedra de cada uma, sem âmbar, vermelho, violeta nem esmeralda | `environment-artist` com a spec do `art-director` | P a M |
| Medalhões da cabeça e da Pedra Funda (`RewardGem`, `DoorGlyph.of_material`) | `technical-artist` | P |
| Medição E1 a E8 | `balance-designer`, `qa-performance` | M |

Meshy zero; texto todo em `data/text_pt.tres`, sem travessão.

## 6. Riscos do protótipo

- **Pedra Funda pouca** (Runas só de 5 a 9, Fendas cedo): medir; se faltar, A2 do `14_propostas.md` (Cavaleiro).
- **Veio pulado** (gente não para): é sinal de que o gesto não vale; não forçar.
- **Exposição**: o veio só depois do guardião; quem morre antes do guardião nas primeiras descidas não vê nada do
  protótipo (é desejado: as primeiras descidas são do combate). Ver `19_experiencia.md`.
- **Mapa poluído**: só um losango, só do achado já anunciado.
