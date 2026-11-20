# Ofícios e Descobertas do Santuário: diagnóstico do que existe

- **Data**: 2026-11-20. **Commit lido**: `9271e95` (branch `arpg-3d`; a árvore local tinha mudanças não commitadas de
  cenário, `player.gd`, `make_data.gd` e `run_lean.gd`, nenhuma nos sistemas auditados aqui). **Autor**:
  `gameplay-engineer`. **Só documento**: nenhuma linha de código, dado ou save foi mudada.
- **Pedido**: `00_pedido_po.md`, seções 2 (diagnóstico) e o lado técnico da 17. A arquitetura proposta está em
  `16_arquitetura.md`.
- **Método**: li o código e os dados, não só os documentos. Onde um documento planeja algo que o código não tem, digo
  "só documentado". Base de planejamento anterior: `docs/design/rejogabilidade/auditoria.md` (RJ-0) e `sistemas.md`
  (RJ-1, Fatias 1 a 3).

Legenda: **IMPLEMENTADO** (no jogo, com teste); **PARCIAL** (a base existe, parte falta ou não tem uso);
**SÓ DOCUMENTADO** (planejado, nenhum código).

---

## 0. Resumo crítico

1. **Metade do pedido já existe com outro nome.** O laço "achado na descida, gasto no hub, muda a próxima descida" é a
   Rejogabilidade Fatia 1 e 2 (`MaterialPurse`, `Forge`, `tools_found`, `Talents` com Memória, `Encounters`,
   `Enchants`). A "ferramenta que abre possibilidade" já existe: `Forge.TOOL_REFINE`, achada no 1º guardião, abre o
   Refinar. Um ofício novo deve **estender** esse caminho, nunca abrir um paralelo.
2. **O que falta de verdade** é: (a) sumidouros que já estão prometidos e não existem (a Esmeralda acumula e não se
   gasta em nada; `forge.awaken` e `forge.inscribed` estão no save sem compra); (b) um segundo NPC com função (o
   Vendedor está "Balcão fechado"); (c) qualquer relação entre NPCs; (d) identidade econômica por arena (toda arena dá
   o mesmo); (e) o Compêndio não registra materiais, ferramentas, anjos nem Encantos.
3. **Pontos do pedido que chocam com decisões tomadas**: coleta física nas salas (o `sistemas.md` 2 recusou "pontos de
   coleta nas salas" na Fatia 1 e a Q-RJ9 a pôs as ferramentas em marcos); mais moedas (a auditoria 4.5 proíbe mais de
   três materiais persistentes); "Guardião dos Manuscritos" e "descobertas ligadas aos Dons" esbarram no cânone de Ahk
   (Q-RJ3: nada de "Página de Ahk" sem o Daniel) e na D-57 (os Dons já têm dois portões: Maestria revela, Memória abre;
   um terceiro atrasa o começo); "Mercador" é o Vendedor (D-H1), não um NPC novo.
4. **Riscos técnicos já presentes** que a camada nova herdaria: o save só guarda o que está no `defaults()` (chave nova
   fora dele some na primeira leitura); a carteira da descida só vai ao save no `Game.log_run` (um travamento do
   processo perde a descida inteira, sem duplicar); o baralho das portas é sorteado no mesmo dado do grafo (carta nova
   no baralho muda o mapa de toda semente); não há fixture de save versão 6 nem 7.

---

## 1. Matriz por sistema

| Sistema | Estado | Persiste entre descidas | Só da descida | Onde está (classes, arquivos) |
|---|---|---|---|---|
| Maestria | IMPLEMENTADO | XP, nível, primeiras vezes (`heroes.warrior.mastery_xp`, `firsts`) | XP ganho na descida (`Game.mastery_gain`) | `MasteryCurve` (`core/mastery.gd`), `data/heroes/warrior_mastery.tres`, `Game.award_mastery`, `MasteryReport` |
| Dons e Devoção | IMPLEMENTADO | revelados, abertos, equipados (`unlocked`, `opened`, `equipped`) | os equipados na descida (`Game.talents`) | `TalentDef`, `Talents`, `HeroLoadout`, `GiftState`, `HeroGifts`, `HeroScreen`, `TalentTree`; 19 em `data/talents/warrior/` |
| Dons abertos com Memória | IMPLEMENTADO | `opened` | nada | `TalentDef.memory_cost`, `Talents.open_in`, `HeroLoadout.open`; migração v6 `SaveData.open_revealed` |
| Bênçãos | IMPLEMENTADO | Compêndio (`codex.boons`) | tudo (`BoonState`) | `Boon`, `BoonMod`, `BoonState`, `RewardDeck`; 42 em `data/boons/` (9 por família e 6 Elos) |
| Anjos e Encontro | IMPLEMENTADO (selos, sem figura) | nada (nem Compêndio) | encontros (`Encounters.meetings`, `RESULT.angels`) | `AngelDef` (`data/angels/`, 4), `Encounter`, `Encounters`, `EncounterScreen`, `AngelSeal`; sal próprio (`RunMap.ANGEL_SALT`, sal 9241 do `Encounter`) |
| Elos | IMPLEMENTADO | Compêndio (`codex.elos`) | tudo | família `DUO`, `Boon.requires_sets`, `BoonState.forged`, `EloLink` |
| Salmos | IMPLEMENTADO | Compêndio (`codex.psalms`: `seen`, `taken`) | tudo | `PsalmDef`, `Psalms`, `PsalmPlay`; porta de Salmo `RunMap.Reward.PSALM` com `Room.psalm` |
| Encantos | PARCIAL | nada (o "aprender" não existe na prática) | `BoonState.enchants` | `EnchantDef`, `Enchants`, 3 em `data/enchants/`, todos `learned`; `Enchants.learned` já lê `forge.inscribed`, mas **nada escreve** nele (Inscrever não existe); `EnchantChoice` provisória |
| Forja: Temperar | IMPLEMENTADO | `forge.temper` | soma no `BoonState.stat` (`equip_forge`) | `Forge`, `ForgeRank` (`data/forge/emeth/00..02`), `ForgeScreen`, `Hub.forged`, `EmethSword.set_temper` |
| Forja: Refinar | IMPLEMENTADO | `forge.refined`, `forge.refine` | `Game.forge_refine` | `ForgeRank` `track` `refine` (`10..15`), `Forge.put_on`; precisa de `tool_refine` |
| Forja: Despertar e Inscrever | SÓ DOCUMENTADO (o save tem as chaves) | `forge.awaken` (`""`), `forge.inscribed` (`[]`) sem escrita | nada | `SaveData.forge_defaults`; `sistemas.md` 1.5, Fatia 3 |
| Ferramentas | PARCIAL (uma só) | `heroes.warrior.tools` | `Game.tools_found` | `Forge.TOOLS` = `[tool_refine]`, `Forge.add_tool`, `Game.find_tool` (chamado em `Rooms._room_cleared` no guardião) |
| Ouro e lojas | IMPLEMENTADO | nada (D: ouro é da descida) | `Rooms.gold`, `GoldPurse` | loja da sala 10 e loja de rota (`RunMap.is_route_shop`, `StageDef.route_shop_*`), `ShopGroup`, Altar troca ouro por Magia (`Altar`) |
| Prata, Memória, Esmeralda | IMPLEMENTADO (Esmeralda sem gasto) | `materials`, `materials_total` | `game.materials` (`MaterialPurse` por fonte) | `MaterialPurse`, `StageDef` grupo Materials (`silver_*`, `memory_*`, `emerald_*`), `Rooms.found`, `boss_phase`, `victory`, `MaterialCount`, `DoorGlyph.SILVER/MEMORY` |
| Juramentos | IMPLEMENTADO | `juramentos.ranks`, `best` | Peso da descida | `JuramentoDef`, `Juramentos`, `JuramentoScreen`; Esmeralda por recorde de Peso só documentada (Fatia 3) |
| Mapa e recompensas | IMPLEMENTADO | nada | o grafo (`Rooms.map`) | `RunMap` (`MAP_SALT` 7411 no `Rooms.new_map`), `RewardDeck` (19 cartas), `Room.fight_seed`, grupos `POWER/BODY/HOME`, `settle`, `MapScreen`, `DescentMap` |
| Hub | IMPLEMENTADO (Vendedor sem função) | nada próprio além do save | nada | `HubPlan` (5 estações: portal, vendor, tree, smith, book), `HubLook`, `Hub`, `HubFocus`, `StationSign`, `HubPanel`, `HubNpc` (Vendedor e Forjador assados), `HubLabels` (Bolsa) |
| Livro de Ahk | IMPLEMENTADO | o que ele mostra vem do save | nada | `HeroScreen` (capítulos Abertura, O Guerreiro, Dons), `BookSpread`, `Book`; três vagas seladas sem nome (D-H3) |
| Compêndio | IMPLEMENTADO (sem os sistemas novos) | `codex.{boons, elos, psalms, talents, enemies, arenas}` | nada | `CodexScreen` 8 abas (`Tab`); nenhuma aba de anjos, Encantos, materiais nem ferramentas |
| Save | IMPLEMENTADO, versão 7, três espaços | tudo acima | nada | `SaveData` (regras), `SaveFile` (atômico, `.bak`, `.broken`), `SaveSlots` (`save_1..3.json`, perfil com opções), `Save` (autoload) |
| Registro | IMPLEMENTADO, versão 5 | `user://runs.jsonl` (um só, `slot` por linha) | a linha da descida | `RunLog` (`KEEP_FIELDS`: `materials`, `forge`, `talents_opened`, `angels`), `Game.run_entry`, `RoomTally` |

---

## 2. Notas por sistema (dependências e integrações ausentes)

### 2.1 Maestria, Dons, Devoção
- Dependências: `HeroDef.warrior()` dá a curva e o catálogo; o nível revela (`TalentDef.unlock_level`), a Memória abre
  (`memory_cost`, 0 no Quarto Corte), a Devoção (5 + nível) limita o equipado (`Talents.check`).
- Primeiras vezes em `firsts` (`guardian`, `victory`) dão XP extra; é o único registro de marcos que existe e é o
  gancho natural para "primeira vez que achou X".
- Ausente: Discernimento (Fatia 3, só documentado); nada no hub além do Livro mexe nos Dons.

### 2.2 Bênçãos, anjos, Elos, Salmos
- Toda sorte da descida tem dado próprio por sal: mapa (`MAP_SALT`), anjos (`ANGEL_SALT`, `Encounter`), Encantos e porta
  de Salmo (`Game.ENCHANT_SALT` 5813, com a sala). É o padrão a seguir.
- Restrições já postas: a Bênção nunca é item fabricado (pedido do PO e `auditoria.md` 3.2); anjos são servos de Yah,
  sem leão, espada erguida, olho, sol, cruz, lâmpada nem água como símbolo (`auditoria.md` 4.7).
- Ausente: os anjos não deixam nada no save (nem quantas vezes foi escolhido); o Compêndio não tem aba Anjos (Fatia 3).

### 2.3 Encantos
- `EnchantDef.learned` verdadeiro nos três: o pool é sempre o mesmo. O caminho "a Forja decide o que pode sair" está
  pronto pela metade: `Enchants.learned(catalog, data)` lê `forge.inscribed`, mas não há `ForgeRank` de Inscrever, nem
  ferramenta, nem Encanto 4 a 6. Qualquer ofício que "abra um Encanto" cabe aqui sem código novo de combate.

### 2.4 Forja e ferramentas
- `ForgeRank` paga **um** material (`material`, `cost`). Uma receita com dois insumos (Prata e um componente) não cabe
  no Resource de hoje sem um campo novo.
- `Forge.TOOLS` tem um item; `Forge.has_tool`/`add_tool` gravam em `heroes.warrior.tools` (lista de ids). A
  ferramenta é guardada no `log_run` como os materiais (`Game.tools_banked`), nunca pelo robô.
- Lacuna de migração: um save que venceu guardiões antes da Fatia 2 não ganhou `tool_refine` retroativamente
  (`firsts.guardian` > 0 e `tools` vazio); precisa vencer um guardião de novo. Pequeno, mas é o tipo de buraco que a
  camada nova multiplicaria.

### 2.5 Ouro e lojas
- O ouro some ao voltar ao hub (decisão do Hades e do `sistemas.md` 1.2). Loja da sala 10 e loja de rota vendem Bênção,
  cura, coração, Magia, romã, fatia de romã e Encanto. Nenhum material compra na loja (`auditoria.md` 3.2): um
  componente também não pode.

### 2.6 Prata, Memória, Esmeralda
- Fontes fixas no `StageDef` (dado), soma por fonte no `MaterialPurse`, teto 999/999/99 (`CAP`), `bank` uma vez no
  `log_run`, robô e `--nosave` nunca (`Game.banks_materials`).
- **Esmeralda sem sumidouro**: fonte `boss` (fase 3 e vitória) funciona; nenhum código gasta. O Despertar (2 a 4
  Esmeraldas) é o gasto planejado. Uma camada de ofícios que use a Esmeralda antes do Despertar mudaria o plano da
  Fatia 3.
- Fontes são por evento (elite, porta, guardião, Provação, Morvath), nunca por arena: a mesma sala do Jardim e da
  Cripta rendem igual. Não existe "identidade econômica por bioma" hoje.

### 2.7 Juramentos
- Só mexem em números da descida (vida, dano, ondas, preço, ...). Nenhum vínculo com o hub além da tela antes do
  Portal. Esmeralda por recorde: só documentada.

### 2.8 Mapa e recompensas
- O grafo e o baralho saem do mesmo `_rng` (`hash([semente, MAP_SALT])`): **toda carta nova no `reward_deck` muda o
  mapa de toda semente** (aconteceu na Fatia 1 e 2, aceito lá). O anjo tem dado próprio (`_angel_rng`, `hash([map_seed,
  ANGEL_SALT])`) e não mexe no grafo. É o molde para qualquer marcação nova no mapa.
- `Room` já carrega `arena`, `trial`, `hidden`, `meeting`, `angel`, `psalm`: uma marca "aqui há um achado" é mais um
  campo, mostrado pelo `MapScreen` e pelo `DoorGlyph`.
- `Rooms.usable`/`use_kind` só conhecem `reward`, `shop`, `door`: um ponto de coleta seria um quarto tipo de uso.

### 2.9 Hub
- `HubPlan` tem 5 estações fixas em constantes (`USE`, `ANCHOR`, `SHOW`), chão de 50 x 32,5 m, nenhum par a mais de 4 s
  (teste `test_no_two_stations_more_than_four_seconds_apart`). NPC novo pede ponto de uso, âncora, peça de colisão,
  enquadramento e o teste de distâncias revisto: custo de planta e de cenário, não só de código.
- `Hub.use` despacha por `match`; o Vendedor abre um `HubPanel` com `hub_vendor_soon`. Nenhuma estação conversa com
  outra (não há estado de NPC no save).
- Ausente: relações entre NPCs, encomendas, qualquer estado de NPC.

### 2.10 Livro de Ahk e Compêndio
- O Compêndio guarda contagens por id em seções fixas (`SaveData.CODEX`); seção nova precisa entrar nessa lista, senão
  `merged` não a lê. As abas são um `enum` (`CodexScreen.Tab`) com largura medida para caber a 720 (`TAB_WIDTH`):
  uma 9ª aba pede revisão do ui-ux-designer.
- Ahk é canônico (escriba de Elun; os papiros são o Livro Sagrado): "manuscritos" ou "páginas" como coletável é lore
  nova e precisa do Daniel (Q-RJ3, `auditoria.md` 1).

### 2.11 Save e registro
- `SaveData.merged` monta do `defaults()` e só aceita chaves conhecidas; blocos com chaves livres (heróis, Compêndio,
  `bindings`, `firsts`) são tratados à parte; dentro do bloco do herói, `HERO_LISTS` guarda listas de ids e `forge`
  passa por `_fixed_keys` (subchave desconhecida some).
- Gravação: `Save.write` no fim (`log_run`, morte, vitória), na Forja, ao abrir Dom, na ultimate escolhida. Durante a
  descida o save não muda com o que se acha: não há como duplicar ao carregar, mas um travamento perde a descida.
- Saída no meio: `Game._exit_tree` chama `log_run("quit")`, que guarda tudo (testado na Fatia 1, A2).
- Os três espaços são arquivos inteiros; opções ficam no perfil. Materiais são do espaço, não do computador.
- Fixtures: `save_v1` a `save_v5`; **faltam `save_v6.json` e `save_v7.json`** (a versão 8 de uma camada nova
  precisa delas para provar que nada se perde).
- `RunLog.VERSION` 5 com `KEEP_FIELDS`; `normalized` lê linhas antigas.

---

## 3. O que persiste e o que é da descida (visão única)

| Persiste no espaço de save | Da descida (some ao voltar) |
|---|---|
| Maestria e primeiras vezes; Dons revelados, abertos, equipados; ultimate | Bênçãos, Elos, Salmos tomados, Encantos tomados |
| Prata, Memória, Esmeralda (e o total de vida do save) | ouro, romãs, vida, Magia, maldições da Provação |
| Forja: Temperar, Refinar comprados e postos | os postos somados na descida (cópia, `BoonState.forge`) |
| ferramentas (`tools`) | `tools_found` até o `log_run` |
| Juramentos escolhidos e melhor Peso | Peso da descida |
| Compêndio (6 seções), recordes, vitórias, descidas | o mapa, os encontros, a loja |

O que a camada nova precisa decidir para cada coisa nova: de que lado desta tabela ela fica. Regra que proponho manter:
**o que se fabrica ou se entrega no hub persiste; o que se usa numa descida é cópia lida no começo dela** (como
`_equip_forge`), nunca estado que a descida altera no save.

---

## 4. Decisões que não podem ser contrariadas

| Fonte | Decisão | Efeito sobre os Ofícios |
|---|---|---|
| `CLAUDE.md`, D-64 a D-71 | só o Guerreiro, Emeth arma única, sem bloqueio nem aparo, golpe plantado; nada de "Punho de Elun", poder com nome de Elun, sol como símbolo | nenhuma ferramenta vira arma; nenhum componente muda o golpe (só números que já existem, como a Forja) |
| `CLAUDE.md` | conteúdo é dado; lógica nova com GUT; texto em `text_pt.tres` sem travessão | receitas, encomendas e achados como `Resource` pelo `make_data.gd` |
| Decisões do Daniel de 2026-11-19 (`auditoria.md` topo) | mecânica primeiro, equilíbrio depois; anjos dão Bênçãos; a Forja soma força; os Dons pedem um recurso além da Maestria (a Memória, feito) | a Memória já é o "recurso dos Dons": manuscritos não podem ser um segundo |
| Q-RJ2 a | três materiais e ferramentas como achados; nenhuma moeda nova; a Brasa cortada | componentes e achados não podem ser moeda geral nem ter nome de Bênção |
| Q-RJ3 | nomes neutros; nada com Ahk sem o cânone | "manuscrito de Ahk" e "Guardião dos Manuscritos" dependem do Daniel |
| Q-RJ9 a | ferramentas por marco de primeira vez, não em sala escondida | "picareta achada" pode ser marco; "picareta comprada ou fabricada" é decisão nova |
| Q-RJ11, Q-H3, D-H4 | NPCs e o lugar com nome de trabalho e só função até o Daniel | Artesão, Alquimista, Guardião sem nome nem história |
| D-H1, D-H2 (substituída pela decisão 3) | Vendedor com "loja a definir", Obras na Fatia 3 | o "Mercador" do pedido é o Vendedor |
| D-H3 | três vagas seladas no Livro, sem nome | nada de NPC no lugar dos outros heróis |
| D-57 | desbloqueios frequentes no começo, compatível com saves antigos | nenhum portão novo nos primeiros Dons |
| `auditoria.md` 3.2, 4.3, 4.5, 4.6 | material não compra na loja da descida nem paga Provação e Altar; nenhuma barra nova no HUD; no máximo três materiais; não refazer o grafo | contador de achados só no hub e na tela de fim; marcas no mapa como campo do `Room` |
| `sistemas.md` 1.2 | morrer e sair guardam tudo; teto no save | os achados seguem o mesmo `bank` |
| `sistemas.md` 2 | "sem pontos de coleta nas salas" na Fatia 1 (fica para depois, se o Daniel quiser) | a coleta física é a pergunta aberta, não uma premissa |
| `balance.md` 7.4 | todo permanente cabe na curva (5 a 10 pontos por coisa) | ofícios horizontais (opções, não força) são os que cabem sem refazer a curva |
| `CLAUDE.md` (Rejogabilidade) | `--materials-keep`, robô nunca guarda | achados herdam a regra |
| `auditoria.md` 2.3 | sementes determinísticas, sal próprio por sistema | todo sorteio novo com sal próprio |
| Cânone (`../dungeon-rpg/docs/mundo/canone.md`) | Ahk, a Lâmpada do paladino, o Sopro (água viva), leão, espada erguida, olho cortado | nenhum coletável com esses símbolos ou nomes |

---

## 5. O que do pedido já está coberto, o que seria redundante, o que falta

| Pedido | Já coberto por | Redundante se feito como pedido | Lacuna real |
|---|---|---|---|
| Ferramentas que abrem possibilidades | `tool_refine` (marco, abre o Refinar) | uma segunda lista de ferramentas fora de `heroes.warrior.tools` | ferramentas 2 e 3 (Despertar, Inscrever) planejadas e não feitas |
| Componentes para o Forjador (óleo) | `ForgeRank` paga Prata | um 4º material "óleo" persistente como moeda | `ForgeRank` com insumo extra; quem produz o insumo |
| Descobertas ligadas aos Dons | Maestria revela, Memória abre | manuscrito como 3º portão dos Dons (contra D-57) | descoberta como **variante horizontal** de um Dom já aberto, ou registro no Compêndio |
| NPCs especialistas | Forjador (Forja), Vendedor (fechado), Livro | "Mercador" ao lado do Vendedor | função do Vendedor; um NPC novo no máximo, com planta revista |
| Encomendas e relações | nada | | tudo (estado de NPC no save) |
| Crafting enxuto | Forja (Temperar, Refinar) é um crafting de uma entrada | uma bancada nova que só reempacota Prata | receitas de duas entradas |
| Identidade econômica por bioma | arenas com `RoomLayout.id` por nó do mapa | | fontes por arena; o mapa já sabe a arena de cada nó |
| Mapa mostra oportunidades | portas e `MapScreen` mostram recompensa, anjo, difícil | carta nova no baralho (muda o mapa) | marca em `Room` com dado próprio |
| Garantias, sem farming, sem softlock | tetos por fonte (`phase_max`), uma vez por marco | | contador de garantia (piedade) entre descidas; teste de alcançabilidade |
| Economia sem moedas novas | ouro da descida, três materiais | | sumidouro da Esmeralda; Prata no fim de jogo (Obras) |
| Integração com Juramentos | Peso dá XP | | qualquer vínculo com o hub |
| Livro e Compêndio | Livro com Dons, Compêndio com 8 abas | | registro dos achados, anjos e Encantos |
| Save em três espaços, migração, semente | `SaveSlots`, `merged` com migração por versão, sais | | fixtures v6 e v7; diário da descida contra travamento (opcional) |

**Minha leitura (opinião)**: a menor camada que responde ao pedido sem duplicar nada é (1) receitas de duas entradas na
Forja já existente, (2) as ferramentas 2 e 3 já planejadas como os primeiros "ofícios" de verdade, (3) o Vendedor
abrindo como o segundo NPC com encomendas, (4) achados por arena marcados no mapa com dado próprio e (5) uma aba no
Compêndio. Um NPC novo (Alquimista) só depois de saber se as encomendas agradam; coleta física só se o Daniel quiser
depois de jogar a versão por recompensa de sala.
