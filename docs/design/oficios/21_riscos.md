# Ofícios e Descobertas: riscos

- 2026-11-20, `game-director`. Legenda no `README.md`. Probabilidade e impacto em B (baixo), M (médio), A (alto).
  Testes técnicos detalhados em `16_arquitetura.md` 5.

| # | Risco | Prob. | Impacto | Mitigação | Como se percebe (teste ou medida) | Dono |
|---|---|---|---|---|---|---|
| R1 | **Planilha**: recursos demais, cada um com um uso pequeno | M | A | orçamento do `02_visao_e_grafo.md` 5: um contável novo no capítulo 1; todo recurso com uso visível | contar no catálogo; Livro sem rolar a 720 | game-director |
| R2 | **Simulador de mineração**: coleta repetida, hub de tarefas | M | A | um veio por sala, no máximo 2 por descida, um aperto, só depois da luta, só onde a ferramenta faz diferença | E2, S2 | room-designer, balance-designer |
| R3 | **Força escondida**: Obra, Encanto ou Despertar somando vitória | M | A | só horizontal; teto +5 para todos os ofícios (alvo 0); a 2ª romã da loja descartada | E5, E13, 32 sementes r45 | balance-designer |
| R4 | **Farming**: sair cedo rende mais por minuto | A (já existe) | M | OF-05; veio só depois do guardião; regra dos 1,2 vez | E3 | balance-designer |
| R5 | **Softlock ou sorte que nunca vem** | B | A | piedade de 2 descidas; nenhum essencial depende de vitória nem do próprio produto | `test_every_essential_is_reachable_from_a_fresh_save`, `test_pity_marks_within_n_runs` | gameplay-engineer |
| R6 | **Ciclo de dependência** | B | A | grafo conferido; restauro nunca pede o que abre | `test_the_oficios_graph_has_no_cycle` | gameplay-engineer |
| R7 | **Duplicar ou perder** (carregar, entregar duas vezes, sair no meio, travamento) | M | A | `bank` só no `log_run`; entrega na mesma mutação; ler nunca dá; diário de descida só se necessário | 5.1 a 5.6, 5.13, 5.14 | gameplay-engineer, qa-performance |
| R8 | **Save antigo quebrado** ou item renomeado que some | B | A | fixtures v1 a v8; `retired` | `test_every_fixture_opens_whole_as_8`, `test_an_unknown_id_is_kept_aside` | gameplay-engineer |
| R9 | **Semente mudada** (mapa ou luta diferentes) | M | M | sal próprio depois do grafo; nenhuma carta nova no baralho | `test_finds_leave_the_map_as_it_was`, `..._run_as_it_was` | gameplay-engineer |
| R10 | **Lore inventada** (manuscrito, Ahk, nomes, NPC canônico, leão como achado) | M | A | nomes de trabalho; voz neutra; perguntas Q-OF5, Q-OF8, Q-OF9, Q-OF10 | revisão do texto antes do merge | game-director |
| R11 | **O veio ler como perigo ou como Emeth** | M | M | cores proibidas (âmbar, vermelho, violeta, esmeralda, coluna de luz); revisão do art-director nos dois looks e no Compatibility | capturas na GPU | art-director |
| R12 | **Mapa e placa poluídos** | M | M | nada na placa da porta; um losango por nó; só o que já foi visto | capturas a 720 | ui-ux-designer |
| R13 | **Hub lento** (muitas estações com novidade, folhas longas) | M | M | 2 estações com novidade por volta; entrega em 2 toques | E6 | ui-ux-designer |
| R14 | **Primeiras descidas tomadas por sistemas** | B | A | nada dos Ofícios antes do guardião | `19_experiencia.md`; relato | game-director |
| R15 | **Memória lenta no começo** pelo OF-05 (D-57) | M | M | medir E9; se passar, Memória desde a profundidade 5 | E9 | balance-designer |
| R16 | **Pedra Funda pouca** (exposição das arenas) | M | M | veio nas Fendas e nas Runas; A2 (Cavaleiro) se faltar | E1, contagem por descida | room-designer |
| R17 | **Custo de arte** subestimado (peça do veio em 2 arenas, 2 variantes, 2 looks) | M | B | peça simples, uma por arena; provisória serve para o teste | revisão do art-director | environment-artist |
| R18 | **Robô diferente de gente** (colhe sempre, vai sempre à sala marcada) | A | M | metas de sensação só com o Daniel; o robô com peso pequeno | E7 com gente | balance-designer |
| R19 | **Desempenho** (peça nova, MultiMesh, luz) | B | M | sem luz própria no veio; menos de 0,3 ms na iGPU Baixa | `tools/sty_probe.gd` | technical-artist |
| R20 | **Escopo cresce para o C** antes de A ser jogado | M | A | este roteiro; C descartado até o Daniel pedir de novo | backlog | game-director |
