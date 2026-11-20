# Ofícios e Descobertas do Santuário: arquitetura mínima

- **Data**: 2026-11-20. **Commit lido**: `9271e95`. **Autor**: `gameplay-engineer`. **Só documento**: nada implementado.
- Vale junto com `01_diagnostico.md` (o que existe e as decisões que mandam). Nomes de classe, campo e arquivo são
  propostas; nomes para o jogador são de trabalho (Q-RJ3, Q-RJ11).
- **Princípio**: estender o que já funciona (`MaterialPurse`, `Forge`/`ForgeRank`, `tools`, `RunMap` com sal,
  `SaveData.merged`, Compêndio) e não abrir um segundo caminho para a mesma coisa. Tudo o que é conteúdo vira
  `Resource` gerado por uma parte nova `oficios` do `tools/make_data.gd`; toda regra nova é pura em `scripts/core/`.

---

## 1. Vocabulário: cinco definições, uma só família de ids

Hoje há três materiais (moedas, `MaterialPurse.IDS`) e uma ferramenta. A camada nova acrescenta **itens contáveis que
não são moeda** (componentes) e **itens únicos** (ferramentas, descobertas). Para nunca ter duas tabelas de "quanto
tenho de X", todo custo e todo prêmio passa a ser um `Dictionary` `{id: n}` cujos ids são materiais **ou** itens do
catálogo, pagos e dados por uma única classe pura (`Ledger`, seção 3).

| Definição | Resource proposto | Campos | Pasta | Observação |
|---|---|---|---|---|
| **Coletável** (achado contável: componente, matéria do ofício) | `FindDef` | `id`, `name_key`, `desc_key`, `kind` (`COMPONENT`, `DISCOVERY`), `cap` (teto no save, 9 a 99), `essential` (bool: entra em alguma receita de que algo depende), `icon` | `data/oficios/finds/` | **não** é moeda: só serve às receitas e encomendas que o citam; nunca compra na loja, nunca paga Provação nem Altar (`auditoria.md` 3.2) |
| **Ferramenta** | a mesma `FindDef` com `kind = TOOL` e `opens: Array[StringName]` (receitas, postos da Forja, fontes que libera) | idem | idem | única (`cap` 1). As de hoje continuam em `heroes.warrior.tools` (`Forge.TOOLS` passa a ser lido do catálogo); `tool_refine` vira um `FindDef` sem mudar o id gravado |
| **Receita** | `RecipeDef` | `id`, `station` (`smith`, `vendor`, ...), `inputs: Dictionary` (id para n), `outputs: Dictionary`, `needs: Array[StringName]` (ferramentas ou descobertas que precisam existir), `once` (bool), `name_key`, `desc_key` | `data/oficios/recipes/` | uma receita de saída "posto da Forja" é o `ForgeRank` de hoje com insumo extra (2.1), não uma receita paralela |
| **Encomenda** | `OrderDef` | `id`, `giver` (estação), `wants: Dictionary`, `gives: Dictionary` (itens, materiais, `unlock:` id), `needs: Array[StringName]` (o que tem de existir para ela aparecer), `name_key`, `line_key` | `data/oficios/orders/` | máquina de estados por id no save (seção 4); entregue uma vez, nunca repetível em laço (anti-farm) |
| **Fonte** (onde um coletável aparece na descida) | `FindSource` (sub-recurso dentro do `FindDef`) | `arena` (`RoomLayout.id`, vazio = qualquer), `event` (`room_cleared`, `elite`, `guardian`, `trial`, `boss_phase`, `site`), `chance`, `amount`, `per_run_max`, `needs` (ferramenta que libera), `outcome_any` (vale também na derrota) | dentro de `data/oficios/finds/` | a "identidade econômica por arena" é este campo `arena`: dado, não código |

Fora daqui, de propósito: nada de "consumível de combate" fabricado (seria Bênção com outro nome, contra o pedido do PO e
o `auditoria.md` 3.2); nada de equipamento.

### 1.1 Por que não um quarto material
`MaterialPurse` foi feito para moedas com gasto exclusivo (Q-RJ2 a). Um componente que só entra em duas receitas é
item, não moeda: fica com teto baixo, sem contador na HUD, e não aparece no `reward_deck` como porta própria (o que
mudaria o mapa de toda semente e daria um quarto grupo de porta). Se o Daniel quiser porta de componente, ver 5.6.

---

## 2. Onde cada peça se pendura no código que existe

### 2.1 Forja (estender, não duplicar)
- `ForgeRank` ganha `extra: Dictionary` (insumos além de `material`/`cost`, padrão vazio). `Forge.problem` passa a
  checar o `Ledger`; `Forge.buy` paga pelo `Ledger`. Postos de hoje ficam iguais (extra vazio): mesmo save, mesmo teste.
- Despertar e Inscrever (Fatia 3 já planejada) entram como `track` novos do `ForgeRank`, abertos por `tool`. Inscrever
  escreve `forge.inscribed`, que o `Enchants.learned` **já lê**: é o primeiro ofício de verdade com custo de código
  quase zero.

### 2.2 Descida (achados)
- A carteira da descida continua sendo `game.materials`; ela passa a aceitar ids do catálogo de achados (o `CAP` vem do
  `FindDef.cap`). Um `MaterialPurse` só por descida: o `report()` ganha os achados, o `bank()` os guarda no mesmo
  instante e pela mesma regra (`Game.banks_materials`). Isso mata, por construção, a classe de bug "guardou os
  materiais e esqueceu os achados".
- Quem chama: os ganchos que já chamam `Rooms.found` (elite, porta, guardião, Provação, fase, vitória) consultam
  `FindSources.roll(evento, arena, dado)` e somam. Ponto de coleta físico (se aprovado) é um quarto `use_kind`
  (`&"site"`) no `Rooms.usable`, com a mesma tecla `interact` (C19, Q-13).
- Dado: **sal próprio** por sala, como o `ENCHANT_SALT`: `hash([run_seed(), FIND_SALT, room.id, evento])`. Nunca o
  `game._rng` nem o `_rng` do mapa.

### 2.3 Mapa (marcar sem mexer no grafo)
- `RunMap` ganha `Room.find: StringName` (o achado que aquela sala promete; vazio por padrão), preenchido **depois** do
  `_build`, num `_find_rng` com `hash([map_seed, FIND_SALT])`, como o `_angel_rng`. O grafo, o baralho, as arenas e o
  `fight_seed` saem idênticos.
- `Room.view()`, `sign()` e `summary()` levam o campo; `MapScreen` e `DoorGlyph` desenham (ui-ux-designer).
- Garantia mínima entre descidas: um contador no save (`oficios.pity`: id para descidas sem achar) que, passando de N,
  força a marcação numa sala do caminho mais curto. O contador entra no hash do `_find_rng` só como entrada, não muda o
  grafo.

### 2.4 Hub
- Receitas e encomendas abrem nas estações que existem (`HubPlan.SMITH`, `VENDOR`, `BOOK`) pelo `Hub.use`. O Vendedor
  sai de "Balcão fechado" para a estação das encomendas. **Nenhuma estação nova na primeira versão**: NPC novo pede
  ponto de uso, âncora, colisão, enquadramento e o teste de 4 s entre estações (`test_hub_d.gd`), custo G de planta e
  cenário além do código.
- Relação entre NPCs: uma encomenda do Vendedor cujo `gives` é um insumo de uma receita do Forjador. É dado (`OrderDef`
  e `RecipeDef`), sem sistema de afinidade.

### 2.5 Compêndio e Livro
- Seção nova `oficios` no `SaveData.CODEX` (id para `{found, made, delivered}`), contada no `Game.codex_run`. Aba nova no
  `CodexScreen` só se a fileira de 8 couber (decisão do ui-ux-designer); senão, entra na aba de Golpes ou num capítulo
  do Livro.
- Descoberta ligada a um Dom: o `FindDef` `DISCOVERY` só **registra** e pode abrir uma variante horizontal (as
  propostas de design dizem quais); nunca abre o Dom (a Memória já abre, D-57).

---

## 3. Regras puras novas

| Classe | Arquivo | Responsabilidade |
|---|---|---|
| `Ledger` | `core/ledger.gd` | `amount(data, id)`, `can_pay(data, cost)`, `pay(data, cost)` **tudo ou nada**, `give(data, gives) -> Dictionary` (o que entrou de fato, respeitando teto), `room_for(data, gives)` (cabe sem estourar?). Materiais delegam ao `MaterialPurse`; itens vão ao bloco `oficios.items` |
| `Oficios` | `core/oficios.gd` | carrega os catálogos; `recipe_problem(data, r)` (`OK`, `SHORT`, `NEEDS`, `DONE`, `FULL`), `craft(data, id)`; `order_state(data, o)`, `deliver(data, id)`; `graph()` (as arestas para o teste de ciclo); `reachable(data_inicial)` (ponto fixo de alcançabilidade) |
| `FindSources` | `core/find_sources.gd` | `roll(evento, arena, dado, achados_da_descida, save)`: o que cai, respeitando `per_run_max` e `needs`; `pity_pick(...)` |

Todas sem nós, testadas por GUT. A tela só chama estas funções e `Save.write()`.

---

## 4. Estado persistente e migração

### 4.1 Save versão 8 (proposta)

| Chave | Onde | Padrão | Leitura no `merged` |
|---|---|---|---|
| `oficios` | raiz do espaço | `{"items": {}, "items_total": {}, "orders": {}, "recipes": [], "pity": {}}` | bloco de chaves conhecidas; `items`, `items_total`, `pity` como seções de chaves livres saneadas (id `String` para `int` maior que 0, só ids do catálogo, teto aplicado); `orders` id para estado (`"open"`, `"done"`); `recipes` lista de ids feitos (receitas `once`) |
| ferramentas | `heroes.warrior.tools` | como hoje | sem mudança |
| `forge.extra` | nenhum | | os postos continuam pelo rank; o insumo extra é só custo |
| `codex.oficios` | `codex` | `{}` | `SaveData.CODEX` ganha `"oficios"` |

- Por que na raiz e não no herói: os materiais já são da casa (`sistemas.md` 5.1); itens do hub idem. A Forja e as
  ferramentas seguem no herói porque já estão lá (não mover dado gravado).
- **Cuidado do `merged`**: `_fixed_keys` derruba subchave desconhecida e deixa inteiro um dicionário padrão vazio sem
  checar tipo. Itens precisam de uma função `_counts(loaded, catálogo)` (como `_entries` do Compêndio) que só guarda
  `int` positivo de id conhecido. Id que sumiu do catálogo: **guardado** num `oficios.retired` em vez de apagado (um
  item renomeado nunca evapora do save de quem o tinha).

### 4.2 Migração (7 para 8, uma vez, idempotente)
1. Cria o bloco `oficios` vazio.
2. Ferramentas por marco já feito (fecha a lacuna do diagnóstico 2.4): `firsts.guardian` > 0 e sem `tool_refine` ganha
   `tool_refine`; o mesmo para as ferramentas novas cujos marcos o save prova (`codex.enemies.morvath.phase` 3 ou mais,
   `codex` de Provação vencida se existir). Nenhum item contável é dado de graça além disso (sem inflação retroativa).
3. Nada mais muda: Dons, Forja, materiais, Juramentos, opções.
- `merged(merged(x)) == merged(x)` vale como regra e como teste.
- Fixtures novos: `tests/fixtures/save_v6.json` e `save_v7.json` (faltam hoje) e `save_v8.json` com tudo preenchido.

### 4.3 Registro (`RunLog.VERSION` 6)
- `KEEP_FIELDS` ganha `finds` (por fonte e arena, como `materials`), `sites` (`[sala, achado, pego]`), `pity` (antes da
  descida). Linhas antigas lidas com vazio por `normalized`. `RESULT` com os mesmos campos (o robô mede ritmo e
  garantias).

---

## 5. Integridade: cada risco, a regra e o teste

Arquivos de teste propostos: `tests/test_oficios.gd` (puro), `tests/test_oficios_save.gd` (save e migração),
`tests/test_oficios_game.gd` (cena, como `test_rejogabilidade_game.gd`).

| # | Risco | Regra | Teste GUT (nome e o que afirma) |
|---|---|---|---|
| 5.1 | **duplicar recompensa ao carregar** | ler o save nunca dá nada; migração só concede ferramenta provada por marco e é idempotente; carregar não roda `bank` | `test_merged_twice_is_merged_once` (todas as fixtures v1 a v8: `merged(merged(f)) == merged(f)`); `test_loading_gives_nothing` (soma de materiais e itens igual antes e depois de `Save.use` no mesmo espaço três vezes) |
| 5.2 | **guardar a descida duas vezes** | `bank` só no `log_run`, protegido por `_logged`; vitória e morte chamam `log_run` uma vez, e o `_exit_tree` depois não guarda de novo | `test_a_run_banks_once` (morte, depois `_exit_tree`: totais somados uma vez; idem vitória; idem saída) |
| 5.3 | **entregar uma encomenda duas vezes** | estado `open` para `done` na mesma mutação que paga e dá; `deliver` em `done` devolve falso e não muda nada | `test_an_order_is_delivered_once` (duas entregas seguidas e entrega depois de recarregar o save: segunda falha, totais iguais) |
| 5.4 | **pagar sem receber** (teto cheio, item sem espaço) | `craft` e `deliver` checam `Ledger.room_for` antes de pagar; tudo ou nada | `test_a_full_cap_refuses_before_paying` (com o item no teto, a receita dá `FULL` e nada é gasto) |
| 5.5 | **perder itens ao sair no meio** | a saída pelo menu, o fechar da janela e o "Voltar ao hub" passam pelo `_exit_tree` e guardam (como hoje) | `test_quit_mid_run_keeps_finds` (cena: acha, sai, o save tem) |
| 5.6 | **perder a descida num travamento** (processo morto) | hoje se perde tudo, sem duplicar. Opcional (custo M): diário `run_pending` com `run_id` gravado ao fim de cada sala; no próximo `Save.use` ele é guardado uma vez e apagado; o `log_run` normal apaga o diário | `test_a_pending_run_is_banked_once` (diário presente, `Save.use` duas vezes: guardado uma vez; diário com o mesmo `run_id` do `log_run`: nada a mais). **Recomendo não fazer na primeira versão**: a Maestria e os materiais de hoje já têm este risco e ninguém relatou |
| 5.7 | **dependência circular** | o grafo "insumo para saída" e "precisa de para abre" (receitas, encomendas, ferramentas) é acíclico | `test_the_oficios_graph_has_no_cycle` (ordenação topológica de todo o catálogo; falha nomeando o ciclo) |
| 5.8 | **material essencial impossível** (bloqueio) | todo insumo de algo marcado `essential` tem pelo menos uma fonte que vale na **derrota** (`outcome_any`) e não depende do próprio produto | `test_every_essential_is_reachable_from_a_fresh_save` (ponto fixo: começando do save vazio, com as fontes de derrota, alcança-se todo `essential`); `test_no_essential_needs_a_victory` |
| 5.9 | **sorte que nunca vem** | contador de garantia por achado essencial; passando de N descidas sem ele, a próxima marca uma sala no caminho | `test_pity_marks_within_n_runs` (2000 sementes simuladas: nenhuma sequência passa de N) |
| 5.10 | **mudar a semente do mapa** | marcação no `RunMap` com `FIND_SALT` depois do `_build`; nenhuma carta nova no `reward_deck` | `test_finds_leave_the_map_as_it_was` (200 sementes: `summary()` sem o campo `find` igual ao do catálogo vazio, e `fight_seed`, anjo e arenas iguais) |
| 5.11 | **mudar a luta da semente** | sorteio dos achados no dado por sala com sal próprio, nunca no `game._rng` | `test_finds_leave_the_run_as_it_was` (`--smoke=600 --seed=5`: `RESULT` sem os campos novos igual com e sem o catálogo, como a prova do `HeroDef` na E2a) |
| 5.12 | **farming** | `per_run_max` por fonte; encomendas e receitas `once` não se repetem; sites somem quando pegos | `test_a_source_gives_at_most_its_max` (sala com 50 elites: o achado para no teto da descida) |
| 5.13 | **robô ou sem save guardando** | `Game.banks_materials` vale para os achados (são a mesma carteira) | o teste A2 da Fatia 1 estendido aos itens |
| 5.14 | **um espaço vazando para outro** | o bloco `oficios` está no arquivo do espaço; o perfil só guarda opções | `test_slots_keep_their_own_finds` (dar no Save 1, abrir o Save 2: vazio) |
| 5.15 | **save antigo quebrado** | fixtures de todas as versões abrem com tudo de antes | `test_every_fixture_opens_whole_as_8` (v1 a v7: Dons, Forja, materiais, Juramentos, opções e Compêndio iguais aos do `merged` de hoje) |
| 5.16 | **id renomeado apagando item** | id fora do catálogo vai a `oficios.retired` | `test_an_unknown_id_is_kept_aside` |
| 5.17 | **descrição ou custo divergindo** | a tela lê `RecipeDef` e `ForgeRank` pelo `Ledger`, nunca número escrito no texto | `test_every_recipe_has_text_and_a_reachable_station` (toda chave no `text_pt.tres`, toda `station` em `HubPlan`) |

---

## 6. Custo relativo por peça e arquivos

P = até meio ciclo de um agente; M = um ciclo; G = mais de um ciclo ou várias frentes.

| Peça | Custo | Arquivos de código e dado | Outras frentes |
|---|---|---|---|
| `Ledger` e insumo extra no `ForgeRank` | P | `core/ledger.gd` (novo), `core/forge.gd`, `core/forge_rank.gd`, `make_data.gd` (`_forge`) | ui-ux-designer: custo com dois itens na `ForgeScreen` (P) |
| Inscrever e Despertar (ferramentas 2 e 3, sumidouro da Esmeralda) | M (Inscrever P, Despertar M pelo efeito novo) | `core/forge.gd`, `make_data.gd`, `data/enchants/` (Encantos 4 a 6), `game/combat.gd` só no Despertar | combat-feel-director nos Encantos e no Despertar; balance-designer |
| `FindDef`, catálogo e carteira estendida | P | `core/find_def.gd`, `core/material_purse.gd`, `game/rooms.gd` (`found`), `game/game.gd` (`log_run`, `run_entry`) | |
| `FindSources` por arena e evento | M | `core/find_sources.gd`, `game/rooms.gd` (ganchos), `core/stage_def.gd` só se a fonte for do estágio | balance-designer (taxas) |
| Marca no mapa com sal próprio e garantia | M | `core/run_map.gd` (`Room.find`, `_find_rng`), `game/rooms.gd` (`new_map` passa o `pity`) | ui-ux-designer: `MapScreen`, `DoorGlyph` (P) |
| Ponto de coleta físico (só se aprovado) | G | `game/rooms.gd` (`use_kind` `site`), peça na arena (`ArenaRoom`), `game/bot.gd` | environment-artist (peça por arena), technical-artist, room-designer (onde cabe sem atrapalhar a luta), ui-ux-designer (placa) |
| `RecipeDef` e `Oficios` (receitas) | M | `core/recipe_def.gd`, `core/oficios.gd`, `make_data.gd` (parte `oficios`) | |
| Encomendas no Vendedor | M | `core/order_def.gd`, `core/oficios.gd`, `game/hub.gd` (`use` do `VENDOR`) | ui-ux-designer: página da encomenda (M) |
| NPC novo no hub (Alquimista ou Artesão) | G | `core/hub_plan.gd`, `game/hub.gd`, `game/hub_look.gd`, `render/hub_npc.gd`, `tools/bake.gd` (`NPCS`) | environment-artist e technical-artist (estação, boneco do KayKit), art-director, room-designer (planta) |
| Save v8, migração, fixtures v6 a v8 | P | `core/save_data.gd`, `tests/fixtures/` | |
| Registro v6 | P | `core/run_log.gd`, `game/game.gd` | |
| Compêndio (seção e aba) | P (dado) a M (aba) | `core/save_data.gd` (`CODEX`), `game/game.gd` (`codex_run`), `ui/codex_screen.gd` | ui-ux-designer |
| Testes da seção 5 | M | `tests/test_oficios*.gd` | qa-performance |
| Robô (escolhe fonte, coleta, entrega não se aplica) | P | `game/bot.gd`, `game/rooms.gd` (`bot_door` com peso para porta com achado) | balance-designer |

Soma (opinião): a versão sem coleta física e sem NPC novo (Ledger, Inscrever, achados por arena, marca no mapa,
receitas de duas entradas, encomendas no Vendedor, save v8, Compêndio) é **um ciclo e meio** do gameplay-engineer com
a UI em paralelo a partir dos dados. Coleta física e NPC novo somam, cada um, outro ciclo de várias frentes.

---

## 7. O que esta arquitetura evita de propósito

1. Quarto material ou moeda (Q-RJ2 a): componentes são itens de teto baixo, sem HUD e sem loja.
2. Carta nova no `reward_deck` (muda o mapa de toda semente): achados são marca no `Room`, com sal próprio.
3. Segunda lista de ferramentas: uma só, `heroes.warrior.tools`, lida do catálogo.
4. Estado que a descida grava no meio: o save só muda no `log_run` e no hub, como hoje.
5. Terceiro portão dos Dons: descoberta registra ou abre variante, nunca o Dom (D-57).
6. Receita que dá força nova sem passar pelo `BoonState.stat`: todo número pela mesma soma da Forja e dos Dons, para o
   balance-designer medir num lugar só.
7. NPC, nome ou objeto canônico (Ahk, Lâmpada, leão como símbolo de achado) sem o Daniel.
