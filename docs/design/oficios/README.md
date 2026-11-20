# Ofícios e Descobertas do Santuário: leia primeiro

- **Data**: 2026-11-20. **Commit lido**: `0a182f0` (os estudos dos especialistas leram `9271e95`; nada nos sistemas
  auditados mudou entre os dois). **Autor da síntese**: `game-director`. **Só planejamento**: nenhuma linha de código,
  dado ou save mudou. **Estado**: aguardando aprovação do PO.
- **Pedido**: `00_pedido_po.md` (diretriz de 23 seções do Daniel, 2026-11-20).

Legenda usada em todos os arquivos desta pasta:
**[EXISTENTE]** está no jogo hoje, com teste. **[APROVADO]** decidido pelo Daniel (com a referência). **[PROPOSTA
NOVA]** ideia deste estudo, espera aprovação. **[HIPÓTESE]** suposição a medir. **[CÂNONE]** vem de
`../dungeon-rpg/docs/mundo/canone.md`. **[PENDENTE]** depende de decisão do Daniel (lista em `22_decisoes_pendentes.md`).

## A recomendação em uma página

**1. Não abrir uma camada paralela.** [EXISTENTE] Metade do pedido já existe com outro nome: o laço "acha na descida,
gasta no hub, muda a próxima descida" é a Rejogabilidade (Prata, Memória, Esmeralda, Forja, ferramenta `tool_refine`
que abre o Refinar, Dons abertos com Memória, anjos, Encantos). Os Ofícios são a **continuação** desse laço, nas estações
que já existem, e não um segundo sistema de recursos.

**2. O que de fato falta** (medido pelo `balance-designer` e lido no código pelo `gameplay-engineer`):
gasto, não renda. A Esmeralda não tem gasto nenhum; a Prata acaba na 12ª a 14ª descida do robô com reação de gente e
sobra até a Maestria 20 (25ª a 30ª); o Vendedor está "Balcão fechado"; nenhum NPC se relaciona com outro; toda arena
rende igual; o Compêndio não registra ferramentas nem achados. E existe um laço de farming já hoje: porta de Memória na
sala 2 e sair rende 3 a 3,5 vezes a Memória por minuto de uma descida inteira.

**3. Decisões desta síntese** (as divergências entre os especialistas e o que escolhi):

| Ponto | room-designer | balance-designer | gameplay-engineer / ui-ux | **Decisão** |
|---|---|---|---|---|
| Moedas | 5 recursos por bioma, 2 no protótipo (Ferro, Pedra Funda) | zero moeda; no máximo a Pedra Funda | itens de teto baixo, não moeda | **Uma só coisa contável nova, a Pedra Funda (nome de trabalho), como item de ofício e não moeda.** O Ferro de Corrente é Prata com outro nome. Cera, Fungo, Pó de Runa e madeira ficam fora do capítulo 1 |
| Coleta | híbrida, ponto físico só depois da luta, 0 ou 1 por sala, ~1,8 por descida | menos de 10 s por descida; nenhuma fonte acima de 1,2 vez a taxa da descida | ponto só depois da luta, um aperto | **Híbrida mínima**: Prata, Memória e Esmeralda seguem como recompensa; a Pedra Funda vem de um **veio físico** que acorda no último abate, um aperto, só nas Fendas e nas Runas, **só depois da camada do guardião**, no máximo 2 por descida (esperado perto de 1) |
| Ferramenta | Picareta fabricada de Ferro e Prata | achada partida e restaurada com Prata | ferramentas 2 e 3 da Fatia 3 como primeiros ofícios | **Achada partida, restaurada no Forjador com Prata** (a 2ª e a 3ª pedem Esmeralda). Nenhuma ferramenta se fabrica do zero |
| Primeiros ofícios | Picareta | Picareta e obras | Inscrever e Despertar | **Roteiro A**: Picareta e uma Obra. **Roteiro B**: Inscrever e Despertar (o destino da Esmeralda). O Despertar pede efeito de combate novo e o combat-feel-director; fica para depois de o laço provar que diverte |
| NPCs | Artesão, Alquimista, Ervanário | nenhum novo | Vendedor vira estação de encomendas | **Nenhum NPC novo.** Artesão = Forjador; Mercador = Vendedor; Guardião dos Manuscritos = o Livro de Ahk (sem NPC). Alquimista e Ervanário descartados no capítulo 1 |
| Mapa | sinal na placa, neblina de 2 camadas | | marca só com objetivo fixado | **Marca no mapa** (losango pequeno) só do que já foi visto e, no Roteiro B, só do objetivo fixado. **Nada na placa da porta** além da recompensa. Sorteio com sal próprio, o grafo idêntico |
| Livro e Compêndio | | | capítulo "Ofícios" no Livro | **Capítulo Ofícios no Livro** (Recursos, Ferramentas, Pedidos); o Compêndio só conta |
| Vertical ou horizontal | | só horizontal; o hub inteiro até +10 a +15 pontos de vitória, a Forja já usa +9 | | **Só horizontal.** Ofício abre opção, informação ou fonte, nunca vida, dano, cura ou Magia |
| Farming | chance sobe com a profundidade | porta de Prata da 4, de Memória da 7 | | **Corrigir antes de tudo, independente dos Ofícios**: Prata da profundidade 4, Memória depois da camada do guardião (5 a 7) [PENDENTE Q-OF3] |

**4. O que do pedido do Daniel não funciona como está, e o que proponho no lugar** (detalhe em `14_propostas.md`):
- *Óleo do Alquimista para o Forjador*: pede um NPC novo, uma estação nova no hub (planta, arte, boneco) e um
  "consumível" que vira Bênção fabricada. A relação entre NPCs que o Daniel quer sai mais barata entre os dois que já
  existem: a encomenda do Vendedor pede o que só a ferramenta do Forjador colhe.
- *Manuscritos ligados aos Dons*: os Dons já têm dois portões (a Maestria revela, a Memória abre, D-57). Um terceiro
  atrasa o começo. Manuscrito pode dar **pista** (de Salmo, de receita) e linha no Compêndio, nunca abrir Dom. E o que
  é um manuscrito é cânone (Ahk, o Livro Sagrado de Yah) [PENDENTE Q-OF8].
- *Recurso próprio para cada região*: 5 recursos novos sobre 3 materiais vira planilha. A identidade por região vem do
  **que a sala esconde** (o veio nas Fendas e nas Runas, o achado marcado), não de uma moeda por bioma.
- *Coleta física como pilar*: sem tensão (depois da luta) ela é um gesto de recompensa, não jogabilidade; durante a
  luta é armadilha. Serve para **ver a ferramenta que falta**. Um veio por descida, não "mineração".
- *A Jornada da Primeira Picareta*: **funciona e é o protótipo**, mas com a picareta achada partida e restaurada, não
  fabricada de madeira e ferro (`15_prototipo.md`).

**5. O protótipo** [PROPOSTA NOVA]: "A Primeira Picareta" (`15_prototipo.md`): o herói vê um veio preso nas Fendas ou
nas Runas, o Livro anota; nas descidas seguintes o mapa marca uma sala com um achado; a cabeça da picareta cai; o
Forjador a restaura por 20 de Prata (contra o Temperar II: escolha de verdade); os veios abrem e dão Pedra Funda; o
Vendedor, que estava fechado, pede 2 Pedras e 30 de Prata para a primeira Obra (o mapa passa a mostrar os anjos da
camada seguinte). Três estações conversam, nenhuma moeda nova, nenhum NPC novo, nenhum número de força.

**6. Roteiro** (`18_roadmap.md`): **A agora** (cerca de um ciclo e meio do gameplay-engineer, a UI em paralelo, uma peça
de arte), **B depois que o Daniel jogar A** (Inscrever, Despertar, encomendas, objetivo fixado, manuscritos se o cânone
deixar), **C só se A e B divertirem** (NPC novo, recursos por bioma). A correção do farming (OF-05) pode entrar já, sem
esperar os Ofícios.

**7. Perguntas ao Daniel**: 15, cada uma com a minha recomendação, em `22_decisoes_pendentes.md`. As que travam o
Roteiro A: Q-OF1 (aprovar A), Q-OF2 (coleta híbrida mínima), Q-OF3 (portas de material mais fundas), Q-OF4 (Pedra
Funda como único contável), Q-OF5 (nomes de trabalho), Q-OF6 (Vendedor abre pela encomenda).

## Índice

| Arquivo | Seção do pedido | Autor | Conteúdo |
|---|---|---|---|
| `00_pedido_po.md` | todas | game-director | resumo do pedido do Daniel |
| `01_diagnostico.md` | 2, 17 | gameplay-engineer | o que existe, matriz por sistema, decisões que não podem ser contrariadas |
| `02_visao_e_grafo.md` | 3, 4 | game-director | visão do ecossistema e grafo de dependências (Mermaid) |
| `05_coleta_e_regioes.md` | 5, 6, 11 | room-designer | coleta física, identidade por região, sorteio pela semente, descobertas |
| `07_npcs_e_encomendas.md` | 7, 8 | game-director | NPCs (só os existentes) e 5 cadeias completas |
| `09_receitas_e_ferramentas.md` | 9 | game-director | ferramentas, receitas, obras, custos |
| `10_economia.md` | 10, 12, 13, 20 | balance-designer | economia medida, matriz de recursos, farming, vertical e horizontal |
| `10_ux.md` | 10, 11 (UI) | ui-ux-designer | coleta, Bolsa, folhas de NPC, objetivo fixado, mapa, capítulo Ofícios |
| `11_integracao.md` | 11 | game-director | cada sistema existente e como conversa com os Ofícios |
| `14_propostas.md` | 14 | game-director | 27 propostas com recomendação, crítica ao pedido |
| `15_prototipo.md` | 15 | game-director | a Primeira Picareta, passo a passo, aceite |
| `16_arquitetura.md` | 16, 17 | gameplay-engineer | arquitetura mínima, save v8, integridade e testes |
| `17_backlog.md` | 18 | game-director | épicos e histórias OF-01 a OF-30 |
| `18_roadmap.md` | 19 | game-director | roteiros A, B, C comparados |
| `19_experiencia.md` | 21 | game-director | as primeiras descidas, com derrotas |
| `20_metricas.md` | 20 | game-director (com o balance-designer) | metas separadas de medidas |
| `21_riscos.md` | 22 | game-director | riscos com mitigação e teste |
| `22_decisoes_pendentes.md` | 23 | game-director | perguntas ao Daniel com recomendação |

Ordem de leitura para o Daniel: este arquivo, `15_prototipo.md`, `19_experiencia.md`, `22_decisoes_pendentes.md`. O
resto é consulta.
