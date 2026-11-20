# Ofícios e Descobertas: backlog (épicos e histórias)

- 2026-11-20, `game-director`. **Status de todas: aguardando aprovação do PO.** Nada começa sem o Daniel (Q-OF1).
- Campos por história: **Desc** descrição, **Prob** problema, **Valor**, **Pri** prioridade (P0 trava o protótipo, P1
  completa o roteiro, P2 depois), **Dep** dependências, **Est** estimativa relativa (P até meio ciclo de um agente, M um
  ciclo, G mais), **Aceite**, **Testes**, **Riscos**, **Arquivos**, **Evid** evidências esperadas, **Dono**, **Status**.
- Roteiro: A (protótipo), B, C (`18_roadmap.md`). Legenda de estado no `README.md`.

## Épico OF-E0, Fundação (Roteiro A)

**OF-01 Ledger e receita de duas entradas.** Desc: classe pura `Ledger` (`amount`, `can_pay`, `pay` tudo ou nada,
`give`, `room_for`) e `ForgeRank.extra`. Prob: `ForgeRank` paga um material só. Valor: toda compra nova passa por um
lugar. Pri P0. Dep: nenhuma. Est P. Aceite: postos de hoje iguais (mesmo save, mesmos testes); pagar com teto cheio
recusa antes de gastar. Testes: `test_oficios.gd` (`test_a_full_cap_refuses_before_paying`), `test_rejogabilidade*`
verdes. Riscos: mudar a Forja de hoje. Arquivos: `core/ledger.gd` (novo), `core/forge.gd`, `core/forge_rank.gd`,
`tools/make_data.gd`. Evid: GUT. Dono: gameplay-engineer. Status: aguardando PO.

**OF-02 Save versão 8 e fixtures.** Desc: bloco `oficios` (`items`, `items_total`, `orders`, `recipes`, `pity`,
`retired`), `codex.oficios`, migração 7 para 8 idempotente (ferramenta por marco provado; achado partido para marcos
das ferramentas novas), fixtures `save_v6.json`, `save_v7.json` (faltam hoje) e `save_v8.json`. Prob: chave fora do
`defaults()` some; sem fixture não se prova nada. Valor: nada se perde, nada duplica. Pri P0. Dep: OF-01. Est P.
Aceite: v1 a v7 abrem inteiros como v8; `merged(merged(x)) == merged(x)`; id desconhecido vai a `retired`. Testes:
`test_oficios_save.gd` (5.1, 5.14, 5.15, 5.16 do `16_arquitetura.md`). Riscos: o `_fixed_keys` derrubar subchave.
Arquivos: `core/save_data.gd`, `tests/fixtures/`. Evid: GUT. Dono: gameplay-engineer. Status: aguardando PO.

**OF-03 Registro 6 e linha do hub.** Desc: `RunLog.VERSION` 6 com `finds`, `gather` (`gather_s`), `pity`; uma linha
`source: hub` por volta (segundos, estações, compras, gastos). Prob: metas E2 e E6 sem medida. Valor: medir o
protótipo. Pri P0. Dep: OF-02. Est P. Aceite: linhas antigas lidas por `normalized`; `RESULT` com os campos. Testes:
`test_run_log.gd` estendido. Riscos: nenhum. Arquivos: `core/run_log.gd`, `game/game.gd`, `game/hub.gd`. Evid: uma
linha de exemplo no PR. Dono: gameplay-engineer. Status: aguardando PO.

**OF-04 Integridade.** Desc: os testes 5.2 a 5.13 do `16_arquitetura.md` (guardar uma vez, entregar uma vez, saída no
meio, ciclo, alcançabilidade, piedade em 2000 sementes, mapa e luta iguais, teto por descida, robô não guarda). Prob:
duplicar, perder, travar. Valor: confiança no save. Pri P0. Dep: OF-01, OF-02, OF-07. Est M. Aceite: todos verdes,
falham nomeando a causa. Testes: `test_oficios.gd`, `test_oficios_game.gd`. Riscos: cena lenta no GUT. Arquivos:
`tests/`. Evid: GUT. Dono: gameplay-engineer, qa-performance. Status: aguardando PO.

## Épico OF-E1, Anti-farming (pode ir já, independente)

**OF-05 Portas de material mais fundas.** Desc: porta de Prata desde a profundidade 4; de Memória depois da camada do
guardião (no molde do `pom_from_depth`, aplicado no gerador e no `RunMap.settle`). Prob: medido, porta de Memória na
sala 2 e sair rende 3 a 3,5 vezes a taxa (`10_economia.md` 6.2). Valor: fecha um laço de farming que já existe. Pri P0.
Dep: Q-OF3. Est P. Aceite: em 1000 grafos nenhuma porta de Prata antes da 4 nem de Memória antes da camada do
guardião; régua E3 medida (nenhuma fonte acima de 1,2 vez); Dons abertos nas 10 primeiras descidas da campanha r45 no
máximo 1 a menos que hoje. Testes: `test_descent.gd`, `test_economy.gd`. Riscos: Memória lenta no começo (D-57). Arquivos:
`tools/make_data.gd` (`_stage`), `core/run_map.gd`, `core/stage_def.gd`. Evid: `docs/qa/` com E3 antes e depois. Dono:
gameplay-engineer, balance-designer. Status: aguardando PO.

**OF-06 Porta de material que muda sem gasto pendente.** Desc: sem nada a comprar com Prata (ou Memória), a porta vira
ouro ou Bênção no `settle`. Prob: renda morta no fim. Valor: escolha nunca falsa. Pri P2. Dep: OF-01, catálogo completo.
Est P. Aceite: save com tudo comprado nunca mostra porta de Prata; o mapa da semente igual (o `settle` não mexe no grafo).
Testes: `test_economy.gd`. Riscos: confusão; a Forja diz "Tudo forjado". Arquivos: `core/run_map.gd`, `game/rooms.gd`.
Evid: GUT. Dono: gameplay-engineer. Status: aguardando PO (Roteiro B).

## Épico OF-E2, A Primeira Picareta (Roteiro A)

**OF-07 Catálogo de achados, marca no mapa e piedade.** Desc: `FindDef` (cabeça da Picareta, Pedra Funda), `FindSources`,
`Room.find` e `Room.vein` sorteados com `FIND_SALT` depois do grafo; piedade (`oficios.pity`, 2 descidas passando do
guardião); carteira da descida estendida. Prob: nenhum achado fora dos marcos. Valor: a sala promete algo. Pri P0. Dep:
OF-01, OF-02. Est M. Aceite: 200 sementes com o mesmo `summary()` sem os campos; p90 da cabeça até 3 descidas depois do
veio preso. Testes: `test_finds_leave_the_map_as_it_was`, `test_pity_marks_within_n_runs`. Riscos: marca em sala que
ninguém pega. Arquivos: `core/find_def.gd`, `core/find_sources.gd`, `core/run_map.gd`, `core/material_purse.gd`,
`game/rooms.gd`, `game/game.gd`. Evid: GUT, `RESULT`. Dono: gameplay-engineer. Status: aguardando PO.

**OF-08 Veio físico.** Desc: `use_kind` `vein` no `Rooms.usable`; três estados (dormente na luta, pronto ou preso depois
do último abate); um aperto de 1 s, andar ou esquivar corta e guarda o progresso 3 s; só nas Fendas e Runas, só depois da
camada do guardião, no máximo 2 por descida; `RoomLayout.gather_spots` por arena e variante. Prob: a ferramenta não tem
onde valer. Valor: ver o que falta. Pri P0. Dep: OF-07, OF-10 (peça provisória serve). Est M. Aceite: nunca acende com
inimigo de pé; sem colisão nova; 12 x 12 posições saem; nunca sobre laje que fere, boca de porta ou a 6 m da entrada;
desvio até 6 m da linha recompensa-porta. Testes: `test_oficios_game.gd` (veio por arena e variante). Riscos: virar rotina.
Arquivos: `game/rooms.gd`, `tools/make_data.gd` (`_rift`, `_runes`), `game/bot.gd`. Evid: vídeo curto de uma sala com o
veio (GPU, uma por vez). Dono: gameplay-engineer, room-designer. Status: aguardando PO.

**OF-09 Oficina no Forjador.** Desc: aba "Oficina" na `ForgeScreen`: ferramentas achadas e partidas, restaurar com o
`Ledger`. Prob: restaurar não tem tela. Valor: a escolha de Prata. Pri P0. Dep: OF-01, OF-07. Est M (UI). Aceite: 3
toques do hub à restauração; falta em rubrica com "onde achar"; 1280 x 720 sem reticência. Testes: `test_rj1_ui.gd`
estendido. Riscos: a Forja crescer demais (índice com seções). Arquivos: `ui/forge_screen.gd`, `data/text_pt.tres`.
Evid: capturas a 720 e 1080. Dono: ui-ux-designer. Status: aguardando PO.

**OF-10 Peça do veio.** Desc: veio na pedra de cada arena (lábio das Fendas, pilar das Runas), três estados; fio de ouro
velho no pronto, cinza-pedra no preso; nada de âmbar, vermelho, violeta, esmeralda, coluna de luz. Prob: não há peça.
Valor: leitura. Pri P0. Dep: spec do art-director. Est P a M. Aceite: revisão do art-director nos dois looks e no
Compatibility; menos de 0,3 ms na iGPU. Testes: `test_room_style.gd` (ida e volta F7). Riscos: ler como perigo das
Runas (âmbar). Arquivos: `game/rift_look.gd`, `game/runes_look.gd`, shader novo se preciso. Evid: antes e depois na GPU.
Dono: environment-artist, art-director. Status: aguardando PO.

**OF-11 Robô e medição do protótipo.** Desc: o robô colhe dentro do desvio, leva o achado, peso pequeno para a porta da
sala marcada; `RESULT` com `finds`, `gather`, `pity`. Prob: a régua mede uma descida que gente não joga. Valor: P6, P9.
Pri P0. Dep: OF-07, OF-08. Est P. Aceite: chegada a Morvath no máximo 8 s acima de 233 s. Testes: smoke 32 sementes.
Riscos: o robô colher rápido demais. Arquivos: `game/bot.gd`, `game/rooms.gd`. Evid: `docs/qa/oficios_a_metrics.md`.
Dono: gameplay-engineer, balance-designer. Status: aguardando PO.

**OF-12 UI da descida.** Desc: placa do veio (`StationSign.under`, "Extrair" ou "Pede: Picareta"), saudação "Achado" e
"Anotado no Livro", marca do achado no `MapGraph`, Pedra Funda na Bolsa quando houver, medalhões novos. Prob: nada se lê
hoje. Valor: clareza. Pri P0. Dep: OF-07, OF-08. Est M. Aceite: nada novo na HUD da luta; um losango por nó; a 720
legível. Testes: `test_map_screen.gd`, `test_rj1_ui.gd`. Riscos: poluir o mapa. Arquivos: `ui/map_screen.gd`,
`ui/door_glyph.gd`, `ui/elo_banner.gd`, `ui/material_count.gd`, `game/reward_gem.gd`. Evid: capturas. Dono:
ui-ux-designer, technical-artist (medalhões). Status: aguardando PO.

## Épico OF-E3, Vendedor e Obras

**OF-13 Encomendas.** Desc: `OrderDef`, estados oculta, aberta, pronta, entregue; `deliver` paga e dá na mesma mutação.
Prob: nenhum NPC pede nada. Valor: relação entre NPCs. Pri P0 (A, uma encomenda). Dep: OF-01, OF-02. Est M. Aceite:
entregue uma vez (também depois de recarregar); placa da estação muda. Testes: `test_an_order_is_delivered_once`.
Riscos: lista de tarefas. Arquivos: `core/order_def.gd`, `core/oficios.gd`, `game/hub.gd`. Evid: GUT. Dono:
gameplay-engineer. Status: aguardando PO.

**OF-14 Obra 1, Prévia dos anjos.** Desc: o mapa mostra o anjo das salas de Bênção da camada seguinte. Prob: pouca
informação na escolha. Valor: horizontal. Pri P0. Dep: OF-13. Est P. Aceite: mesma semente, mesmos anjos com e sem a
Obra (só se mostra); vitória r45 igual dentro do ruído. Testes: `test_fatia2.gd` estendido. Riscos: prever demais.
Arquivos: `game/encounters.gd`, `ui/map_screen.gd`. Evid: captura do mapa. Dono: gameplay-engineer, ui-ux-designer.
Status: aguardando PO.

**OF-15 Folha do Vendedor.** Desc: o `HubPanel` do Vendedor com PEDE, ONDE ACHAR, DÁ, Entregar; depois folha dupla com
as Obras. Prob: "Balcão fechado". Valor: o hub cresce. Pri P0. Dep: OF-13. Est M. Aceite: 2 toques para entregar diante
do NPC; Entregar só aceso quando pode. Testes: `test_hub_ui.gd`. Riscos: nenhum. Arquivos: `ui/hub_panel.gd`, `game/hub.gd`.
Evid: capturas. Dono: ui-ux-designer. Status: aguardando PO.

**OF-16 Capítulo Ofícios do Livro.** Desc: 4º marcador do `HeroScreen` com Recursos, Ferramentas, Pedidos (Descobertas
no B), "Onde achar", ligações por link. Prob: a rede não se lê. Valor: consulta. Pri P1 (A). Dep: OF-07, OF-13. Est M.
Aceite: 6 a 8 linhas sem rolar a 720; o que não se viu em "???" com pista neutra. Testes: `test_book.gd`. Riscos: voz de
Ahk (Q-OF9). Arquivos: `ui/hero_screen.gd`, `ui/book*.gd`. Evid: capturas. Dono: ui-ux-designer. Status: aguardando PO.

**OF-17 Obras 2 e 3.** Desc: Altar mais frequente; porta de Salmo desde a sala 3. Prob: Prata e Pedra sem gasto no meio.
Valor: variedade. Pri P1 (B). Dep: OF-14. Est P. Aceite: chances medidas em 1000 grafos; vitória r45 dentro do ruído.
Testes: `test_descent.gd`. Riscos: Obra obrigatória; poder desligar. Arquivos: `core/run_map.gd`, `tools/make_data.gd`.
Evid: GUT, métricas. Dono: gameplay-engineer. Status: aguardando PO.

**OF-18 Compêndio dos Ofícios.** Desc: `codex.oficios` contado no `progress`. Prob: o Compêndio não registra achados.
Valor: coleção. Pri P1 (A). Dep: OF-02. Est P. Aceite: contagens no fim da descida. Testes: `test_e4_ui.gd`. Riscos:
nenhum. Arquivos: `core/save_data.gd`, `game/game.gd`. Evid: GUT. Dono: gameplay-engineer. Status: aguardando PO.

## Épico OF-E4, A Esmeralda ganha destino (Roteiro B)

**OF-19 Ferramenta do Inscritor e Inscrever.** Desc: achado na 1ª Provação vencida, restauro 40 Prata e 2 Esmeralda,
trilha Inscrever 20 Prata por Encanto. Prob: Esmeralda sem gasto; Encantos fixos. Valor: variedade. Pri P1. Dep: OF-09,
OF-20. Est M. Aceite: Encanto só sai depois de inscrito; cada Encanto escolhido entre 20 e 45%. Testes:
`test_fatia2.gd`. Riscos: nenhum de força. Arquivos: `core/forge.gd`, `core/enchants.gd`, `tools/make_data.gd`. Evid:
métricas. Dono: gameplay-engineer. Status: aguardando PO.

**OF-20 Encantos 4 a 6.** Desc: três Encantos novos com estatísticas que existem quando der, desenho com o
combat-feel-director. Pri P1. Dep: aprovação do catálogo. Est M a G. Aceite: parecer de cadência sem P0; robô em 32
sementes, nenhum domina. Dono: gameplay-engineer, combat-feel-director. Status: aguardando PO.

**OF-21 Ferramenta do Despertar e Despertar.** Desc: achado na fase 3 de Morvath, restauro 30 Prata e 1 Esmeralda,
três propriedades a 3 Esmeralda cada, uma ativa por vez. Pri P2. Dep: OF-19 provado. Est G. Aceite: vitória r45 com o
Despertar dentro de 5 pontos da mesma Forja; parecer de cadência. Riscos: força escondida. Dono: gameplay-engineer,
combat-feel-director, balance-designer. Status: aguardando PO.

**OF-22 Esmeralda por recorde de Peso.** Desc: um por patamar (já documentado). Pri P2. Dep: OF-21. Est P. Aceite:
nunca duas vezes o mesmo patamar. Testes: `test_juramentos.gd`. Dono: gameplay-engineer. Status: aguardando PO.

## Épico OF-E5, Objetivo e descobertas (Roteiro B)

**OF-23 Campanha do robô.** Desc: sementes em sequência com uma bolsa e compras numa ordem lida de arquivo. Prob: E1, E4
e P7 somados à mão. Valor: medir a curva com a progressão. Pri P0 (necessária ao aceite do A). Dep: OF-03. Est M.
Aceite: reproduz a tabela 1.4 do `10_economia.md` sem os Ofícios. Arquivos: `tools/campaign.gd` (novo). Dono:
balance-designer, gameplay-engineer. Status: aguardando PO.

**OF-24 Objetivo fixado.** Desc: um objetivo por vez (ação `track`, F e Y), na pausa, no mapa (losango só nos nós que
podem dar), no hub e na saudação ("3 de 3"). Pri P1 (B). Dep: OF-16. Est M. Aceite: um toque para fixar; nada na HUD
da luta. Dono: ui-ux-designer, gameplay-engineer. Status: aguardando PO.

**OF-25 Manuscritos do presbitério.** Desc: C6 do `07_npcs_e_encomendas.md`. Pri P2. Dep: **Q-OF8** (cânone). Est M
(texto). Aceite: nenhum texto sem o Daniel. Dono: gameplay-engineer, ui-ux-designer. Status: aguardando PO e cânone.

**OF-26 Pedra quieta lida pelo Inscritor.** Desc: R5 do `14_propostas.md`. Pri P2. Dep: OF-19. Est P. Status:
aguardando PO.

## Épico OF-E6, Teste com gente

**OF-27 Teste do Daniel do Roteiro A.** Desc: save novo, 5 descidas seguidas, `runs.jsonl` com a linha `hub`. Pri P0.
Dep: OF-01 a OF-18 do A. Aceite: o relato dele e E1, E2, E6, E7 medidos nas linhas dele. Dono: Daniel, game-director.
Status: aguardando PO.

## Épico OF-E7, Roteiro C (descartado por agora)

**OF-28 NPC novo (Alquimista).** Só se passar nos três critérios de `07_npcs_e_encomendas.md` 1. Est G. Status:
descartado até A e B serem jogados.
**OF-29 Recursos por bioma (Cera, Fungo).** Pede o OF-28. Est M. Status: descartado por agora.
**OF-30 Pó de Runa.** I5 do `14_propostas.md`. Pede RP-03 medido e um uso. Est P. Status: descartado por agora.

## Ordem sugerida

OF-05 (já, se o Daniel aprovar sozinho) → OF-01, OF-02, OF-03 → OF-07, OF-13, OF-23 → OF-08, OF-10, OF-09, OF-12,
OF-14, OF-15 → OF-11, OF-04, OF-16, OF-18 → OF-27 (teste) → Roteiro B.
