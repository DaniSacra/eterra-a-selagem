# HUB-A: auditoria do código para o Santuário da Vigília

Marco HUB-A da diretriz `docs/design/hub/po_directive_hub01.md` (seções 0, 3 a 5). Feita pelo `gameplay-engineer` em
2026-11-19 lendo o código do HEAD (`47d06a7`, ramo `arpg-3d`), não o backlog nem o `CLAUDE.md`. Nada foi alterado.
Linhas citadas são do HEAD; podem andar alguns números se outros agentes mexerem nesses arquivos.

Resumo em uma linha: **todo o progresso permanente já é gravado antes da tela de fim abrir**; o hub pode entrar no
lugar do "Voltar ao menu" e do "Continuar" da tela de fim sem tocar em Maestria, Compêndio ou registro. Árvore de Dons,
Livro e Portal são reuso direto. **Vendedor e Forjador não têm sistema nenhum fora da descida**: não existe moeda
persistente nem evolução da Emeth; os dois precisam de decisão do PO.

---

## 1. Fluxo atual de ponta a ponta

### 1.1 Cenas
- Cena principal: `scenes/boot.tscn` (`project.godot` `run/main_scene`), script `scripts/boot.gd`.
- Partida: `scenes/game.tscn`, script `scripts/game/game.gd` (`Game`). Só existem essas duas cenas.
- Autoloads: `Save`, `T`, `Controls`, `Audio`, `Music` (`project.godot` `[autoload]`). `Dev` é classe estática
  (`scripts/dev.gd`), lê a linha de comando uma vez.

### 1.2 Título e entrada na partida
| Passo | Onde | O que faz |
|---|---|---|
| Abrir o jogo | `boot.gd:_ready` (27) | `App.apply_options()`. Se `--bot`, `--smoke`, `--start`, `--stress` ou `--play` (ou `--shot` sem `--title`): `change_scene_to_file(GAME)` direto, sem título. Senão `_build()` e, com `--title --screen=...`, abre o painel pedido. |
| Título | `boot.gd:_build` (63) | `TitleBackdrop` + `TitleMenu`; sinais `start_pressed`, `hero_pressed`, `howto_pressed`, `settings_pressed`, `quit_pressed`; `Music.play(&"title")`. |
| Iniciar | `boot.gd:_start` (94) | Se `Juramentos.unlocked(Save.data)` (`wins > 0`, `core/juramentos.gd:45`) e ainda não jurou: abre `JuramentoScreen` com "Descer". Senão escurece e `change_scene_to_file(GAME)`. |
| Juramentos | `boot.gd:_open_juramentos` (108) | `JuramentoScreen.open(with_descend)`; mudar um voto grava na hora (`juramento_screen.gd:_changed` 192, `Save.write`). `descend` volta ao `_start`. |
| O Guerreiro (Livro) | `boot.gd:_open_hero` (118) | `HeroScreen.open({}, chapter)`; `descend` fecha o painel e chama `_start`. |
| Painéis | `boot.gd:_open` (136), `_close_sub` (150), `_unhandled_input` (162) | O título é o "anfitrião": guarda o botão que abriu, esconde o menu, fecha no `closed` do painel **ou no `ui_cancel`** (o Esc/B dos painéis é tratado pelo título, não pelo painel). |
| Começo da partida | `game.gd:_ready` (142) | `Controls.clear_presses()` (o clique de Iniciar não vira golpe); `Dev.seed_rng(_rng, 1)` (`--seed` ou aleatório); monta mundo e UI; `BoonState` novo; `_equip_talents()` (1548: Dons do save validados pelo nível, ultimate escolhida e gravada se mudou); `_swear_juramentos()` (1584: votos do save só com save, sem robô, depois da 1ª vitória); `Psalms` novo; `Rooms.setup` (`rooms.gd:86`: estágio, `Trials`, `new_map` com `hash([_rng.seed, MAP_SALT])`) e `rooms.start()` ou `start_at(--start)`. |

### 1.3 Fim da partida e onde o save é gravado
| Momento | Onde | Gravação |
|---|---|---|
| Morte | `game.gd:_on_player_died` (1064) | `mode = OVER`; `Save.data.runs += 1`; **`Save.write()`**; `log_run("death")`; `Music.play(&"catacombs", WALK)`; espera 1,8 s; `_open_end(false, false)`. |
| Morvath cai | `game.gd:_on_boss_falling` (1081) | Só a legenda e `victory_started`; nada gravado. |
| Vitória | `game.gd:_on_boss_defeated` (1087, ligado em 748) | `mode = ENDING`; `runs += 1`, `wins += 1`; `SaveData.record_win_time` (só com save); **`Save.write()`**; `log_run("victory")`; `await _play_ending` (1103: some a legenda, `victory_finished.emit(boss_stats)`); `_open_end(true, new_best)`. |
| Registro e Maestria | `game.gd:log_run` (1524) | Uma vez só (`_logged`). `mastery_gain` (1619) calcula o XP; `kept = Save.enabled and (bot == null or --mastery)`; se `kept`: `award_mastery` (1643: XP, Dons destravados, `firsts`, Compêndio de Bênçãos, Elos, Salmos, `codex_run` (1669: inimigos, Morvath, arenas), `Juramentos.record_win`) e **`Save.write()`**. Depois `RunLog.append` (só gente com save, ou `--runlog`) e `run_logged`. |
| Tela de fim | `game.gd:_open_end` (1136), `scripts/ui/end_screen.gd:open` (65) | Só lê. Sinais `retry` e `menu` (14, 15). Derrota: "Descer de novo" (`retry`, com foco) e "Voltar ao menu" (`menu`). Vitória: selagem, resumo, "Voltar ao menu" (`continue`, com foco) e "Descer de novo". |
| Descer de novo | `game.gd:1142` | `get_tree().reload_current_scene()`: um `Game` novo, **sem passar pelo título nem pelos Juramentos** (os votos salvos valem igual). |
| Voltar ao menu | `game.gd:1143` | `change_scene_to_file("res://scenes/boot.tscn")`. |
| Sair no meio (pausa) | `pause_menu.gd:74` "Sair para o menu", `:80` "Sair do jogo" | Troca para o título ou `get_tree().quit()`. |
| Saída no meio | `game.gd:_exit_tree` (412) | `log_run("quit")`: se a partida não foi registrada, registra como `quit` e **dá a Maestria das salas vencidas** (gravando o save). Não soma `runs`. Também zera `Controls.virtual` e `Engine.time_scale`. |

Outros pontos em que o save é gravado (todos fora do fim da partida): golpe novo visto (`game.gd:205`,
`SaveData.discover_move`), ultimate gravada ao começar (`_equip_talents`), Dons e ultimate no Livro
(`hero_screen.gd:_save` 501, só quando os dados são o `Save.data`), Juramentos, opções e teclas (`Save.set_option`).

### 1.4 Momento seguro para trocar de cena para o hub
- **O progresso permanente está inteiro no disco antes de `_open_end` ser chamado**, tanto na morte quanto na vitória
  (`runs`, `wins`, melhor tempo, XP, Dons destravados, `firsts`, Compêndio, `juramentos.best`, linha do registro).
- Portanto **qualquer troca de cena disparada pela tela de fim** (os sinais `menu` e `retry`) é segura: o
  `Game._exit_tree` chama `log_run("quit")`, que não faz nada porque `_logged` já é verdadeiro. Nada duplica.
- O ponto certo: trocar o destino do `end.menu` em `game.gd:_open_end` (1143) de `boot.tscn` para a cena do hub. A
  apresentação da vitória (selagem, `EndScreen` com `SealEmblem`, `SUMMARY_AT`) fica como está, como a diretriz pede.
- Na derrota o hub pode vir logo depois do painel de derrota (o PO pede sem animação longa): o painel já é curto e o
  foco cai num botão.
- Saída no meio pela pausa: trocar para o hub também é seguro (o `_exit_tree` registra `quit` e grava). Decidir se
  "Sair para o menu" vai ao hub ou ao título (seção 4).
- **Não** trocar de cena dentro de `_on_player_died` ou `_on_boss_defeated` antes do `log_run`, nem instanciar o hub
  como filho do `Game` (o `_exit_tree` do `Game` é o que fecha a partida).

### 1.5 Comportamento com as opções de teste
| Opção | Hoje | Com o hub (proposta) |
|---|---|---|
| `--nosave` | `Save.enabled = false` (`save.gd:11`): nada lido nem gravado; Maestria não somada (`kept` falso), sem recorde, sem registro. | Hub funciona com o save padrão em memória; nada gravado. |
| `--hero-xp`, `--hero-equip`, `--hero-ult`, `--wins`, `--juramentos` no título | Desligam a gravação na sessão (`save.gd:_dev_hero` 26, `_dev_juramentos` 41). | Iguais; úteis para capturar o hub com Maestria alta. |
| Robô (`--bot`) | O título é pulado; sem Dons do save (só `--talents`), sem Juramentos, sem Maestria (salvo `--mastery`), sem registro (salvo `--runlog`). Na morte a tela de fim abre e fica. | Nunca entrar no hub: os switches que vão direto à partida continuam indo. |
| `--smoke` | `game.gd:_smoke` (1743): imprime `RESULT` e `quit()` ao fim; nunca chega à tela de fim. | Igual. O exe exportado é conferido com `--smoke` (`CLAUDE.md`), também igual. |
| `--start=...`, `--stress`, `--play`, `--shot` | Vão direto à partida (`boot.gd:29`). | Iguais. Sugestão: `--hub` (abre direto no hub) e `--title --screen=` sem mudança. |
| `--showcase` | Só câmera fixa dentro do `Game` (`_place_camera` 1314); não roteia nada. | Igual; o hub pode ter a própria vitrine. |
| Testes GUT | `tests/hooks/pre_run.gd`: `Save.enabled = false` e `--seed=1`. Instanciam `scenes/game.tscn` direto (por exemplo `test_input_leak.gd:72`); não passam pelo título. | Não mudam, a menos que testem os sinais `retry`/`menu` (ver riscos). |

---

## 2. As cinco estações

### A. Vendedor
- **Existe**: a loja da descida, só dela. `Rooms._build_shop` (`rooms.gd:922`), `Rooms.shop()` (956), `_step_shop`
  (964: pisar compra quando há ouro). Itens e preços em `StageDef.shop_groups` (`ShopGroup`, dado no `_stage` do
  `make_data.gd`): Bênção 150; cura 50 e coração 125; Magia 100, romã 100, fatia de romã 50. Placas `DoorSign.shop`.
- **Moeda**: `Rooms.gold` (`rooms.gd:42`), começa em 0 em toda partida, cai dos inimigos (`GoldPurse`), gasta na loja e
  no altar. **Não vai para o save**: `SaveData.defaults()` não tem ouro nem moeda nenhuma. Ao fim, o ouro só aparece no
  resumo da vitória (`end_screen.gd`, `hud_gold`) e no `RESULT`.
- **Dados persistidos**: nenhum.
- **Lacuna**: tudo. Os itens da loja só fazem sentido dentro da descida (cura, vida, Magia, romã, Bênção).
- **Decisão proposta**: **precisa do PO**. No HUB-B o Vendedor é NPC com fala e o estado honesto "a definir", sem
  compra. Propostas de economia para o PO escolher (nenhuma implementada):
  1. Nenhuma moeda nova: o Vendedor vende cosméticos ou músicas já existentes (`MusicCatalog`) por marcos de Maestria
     (sem loja de verdade).
  2. Moeda persistente nova (no molde das "cinzas"/recursos do Hades II): uma fração do ouro da descida ou um recurso
     que cai só de guardiões e de Morvath, gasto em coisas do metajogo (não em poder bruto). Exige `SaveData` versão 6,
     tela própria e balanceamento (o E6 mede a diferença Maestria 1 x 20 em 18 pontos, teto 25).
  3. Vendedor como "ofertas da próxima descida" (por exemplo começar com uma Bênção escolhida entre três), pagas
     com a moeda do item 2.

### B. Forjador
- **Existe**: nada. Não há forja, nível de arma nem evolução da Emeth em script, dado ou save (busca por
  `forge|forja|anvil|bigorna|smith` em `scripts/`, `data/text_pt.tres` e `tools/make_data.gd` só acha "Elo forjado" nas
  Bênçãos). A Emeth é visual (`scripts/render/emeth_sword.gd`) e os números dos golpes vêm dos combos
  (`data/combos/paladin*.tres`).
- **O mais perto**: o ramo **Emeth** da árvore de Dons (`TalentDef.Branch.EMETH`: Corte Crescente, Fio Longo, Onda
  Atravessante; pontes Onda Carregada e Fio do Passo), destravado pela Maestria. Mostrar isso no Forjador seria uma
  segunda porta para a mesma árvore (a diretriz proíbe árvore duplicada).
- **Restrição já decidida**: `docs/design/one_hero_directive.md` item 9, "Sem equipamentos tradicionais nem troca de
  armas". Uma forja que dá dano por nível é progressão nova e mexe no balanceamento do E6.
- **Dados persistidos**: nenhum.
- **Decisão proposta**: **precisa do PO**. No HUB-B o Forjador é NPC com fornalha e animação de trabalho e o estado
  "a definir". MVP para aprovação (nada implementado):
  1. "Aspectos da Emeth" no molde dos Aspectos do Hades: 3 ou 4 formas da Emeth que trocam o comportamento de uma ação
     (não somam dano), uma escolhida por descida, abertas por marcos (Maestria, vitórias, Peso). Dado em Resource
     (`EmethAspect`), save `heroes.<id>.aspect`.
  2. Ou só cosmético: acabamentos da Emeth (cor dos veios, brilho) por marcos; sem números.
  3. Se o PO quiser níveis de poder: recurso persistente (o mesmo do Vendedor), 3 a 5 níveis com teto pequeno e o
     teste de balanceamento do E6 refeito antes de entregar.

### C. Árvore de Dons
- **Existe e está completa**: `HeroScreen` capítulo `GIFTS` (`scripts/ui/hero_screen.gd`, `open(data, start)` 86),
  `TalentTree` (`scripts/ui/talent_tree.gd`), regras em `HeroLoadout` (`core/hero_loadout.gd`: `state`, `toggle`,
  `choose_ult`, `why`, `next_step`) sobre `Talents` (`core/talents.gd`) e `MasteryCurve` (`core/mastery.gd`). Devoção
  5 + nível, pré-requisitos, um Dom por ação. 19 Dons em `data/talents/warrior/`.
- **Dados persistidos**: `heroes.warrior.mastery_xp`, `unlocked`, `equipped`, `ultimate`, `firsts` (`SaveData.hero_defaults`).
  Gravados na hora pela própria tela (`_save`, 501). A partida lê em `Game._equip_talents` e revalida pelo nível
  (`Talents.sanitized`).
- **Como abrir fora do título**: `HeroScreen.new()`, adicionar numa `CanvasLayer`, `open({}, HeroScreen.Chapter.GIFTS)`.
  Sinais: `closed` (botão Voltar) e `descend`. **O Esc/B não é da tela**: quem hospeda trata `ui_cancel`
  (`boot.gd:_unhandled_input` 166). O hub precisa do mesmo anfitrião: `_open`/`_close_sub` do `boot.gd`, mais
  `Controls.clear_presses()` ao fechar (como `Game._back_to_play`) para o Enter que fechou não virar nada.
- **Lacuna**: o anfitrião de painéis está dentro do `boot.gd`; o botão "Descer às catacumbas" do Livro (`descend`)
  precisa ir ao Portal ou sumir no hub (decisão de UX, não de dado).
- **Decisão**: **reusar**. Extrair o anfitrião de painéis do `boot.gd` para uma peça comum (por exemplo `ScreenHost`)
  usada pelo título e pelo hub, sem duplicar.

### D. Livro de Ahk
- **Existe**: `HeroScreen` com três capítulos (`Chapter.OPENING`, `HERO`, `GIFTS`), `BookSpread`
  (`scripts/ui/book_spread.gd`), linguagem `Book` (`scripts/ui/book.gd`), Compêndio `CodexScreen`
  (`scripts/ui/codex_screen.gd`, `open(start, data)`, 8 abas, sinal `closed`), Mapa `MapScreen` (só dentro da partida:
  precisa do `Game`).
- **Dados persistidos**: `codex.boons`, `elos`, `psalms`, `talents`, `enemies`, `arenas`; `moves`; os do herói acima.
- **Heróis**: só existe `HeroDef.warrior()` (`core/hero_def.gd:61`, `data/heroes/warrior.tres`); `HeroScreen` e
  `HeroLoadout` usam ele fixo; `SaveData.FIRST_HERO`. Não há lista de heróis nem seleção.
- **Conflito a resolver**: a diretriz do hub pede "quatro lugares previstos, futuros indisponíveis". A etapa 2 do pacote
  de arte decidiu o contrário: "Use apenas o elenco jogável conforme os dados"
  (`docs/art/ref/direcao_2026-11-17/PROMPT-CLAUDE-CODE.md`, seção 3) e o `CLAUDE.md` registra "Só o Guerreiro: nenhum
  outro herói, nenhuma vaga trancada". Além disso os outros três heróis da arte do título não têm nome nem papel; o
  cânone fala em um paladino do leão e quatro guardiões, e os nomes dos paladinos são `PALADIN_2` a `PALADIN_4` (o
  Daniel define). Mostrar três vagas exige pelo menos o que escrever nelas.
- **Decisão proposta**: reusar o Livro inteiro; as três vagas trancadas **precisam do PO**: (a) silhuetas sem nome e
  "Ainda não desperto" (nada de cânone novo), (b) manter só o Guerreiro como hoje. Em qualquer caso, a vaga trancada não
  pode chamar `descend` nem gravar herói (o save só conhece `heroes.warrior`; `SaveData.hero` criaria um bloco novo se
  chamado com outro id).

### E. Portal da Descida
- **Existe**: o começo de partida é `change_scene_to_file("res://scenes/game.tscn")` (`boot.gd:_start` 104). O
  `Game._ready` monta tudo do zero (ver 1.2); a Provação, o mapa, o baralho, o ouro, as Bênçãos, os Salmos, o robô, as
  ondas, a maldição e o registro da sala são membros do `Game` e do `Rooms` e morrem com a cena.
- **Tela de preparação existente**: `JuramentoScreen` (depois da primeira vitória, `wins > 0`), aberta pelo `_start`
  antes de descer. Integrar no Portal, não substituir.
- **Semente**: `Dev.seed_rng(_rng, 1)`: com `--seed=N`, `N * 1000 + 1`; sem, aleatória. O mapa usa
  `hash([_rng.seed, MAP_SALT])`. Com `--seed` toda descida repete a mesma (é assim hoje no "Descer de novo").
- **O que poderia vazar entre partidas** (estado estático, vive além da cena):
  - `VisualProfile._look`, `_entries` (`core/visual_profile.gd:47`): o look do F7 fica na sessão (desejado).
  - `ArenaRoom._saved`, `_air_env`, `_air_moon`, `_dresser` (`arena_room.gd:1719`): o ar guardado da sala anterior;
    `leave_air` devolve num `Environment` antigo. Hoje o "Descer de novo" já passa por aqui sem efeito visível; com um
    hub que use `Arena`/`ArenaRoom` e o próprio `WorldEnvironment`, conferir a ida e a volta.
  - `Feel._live`, `HeroDef._warrior`, caches de material (`ArenaKit`, `RewardGem`, `Masonry._see_twins`, `UiKit`,
    `BoonArt`): só leitura ou caches de desenho.
  - `Controls`: `clear_presses` no `Game._ready`; `forget_devices` também. `Music`: o autoload segue tocando (o
    `Rooms._enter` troca a música e o ar; `Rooms._exit_tree` apaga o ar).
  - O caminho "um `Game` novo depois de outro" já é exercitado pelo `reload_current_scene` do "Descer de novo".
- **Dados persistidos**: nenhum próprio; lê `heroes.warrior.equipped`/`ultimate` e `juramentos.ranks`.
- **Decisão**: **reusar**. O Portal faz o que o `boot.gd:_start` faz (Juramentos se abertos, depois a cena da partida).
  Extrair esse começo para uma função comum (título, Livro e Portal chamam a mesma).

---

## 3. Infraestrutura para o hub

| Peça | Onde | Serve sem tocar o `Game`? | Observação |
|---|---|---|---|
| Herói jogável | `Player` (`scripts/game/player.gd`) | Em parte | Precisa de `arena` (`sweep`, `resolve`) e `fx` (não nulos); `horde` pode ser nulo (protegido em `step` 506 e `_strike_dir`). **Mas `step` (425) sempre lê ataque, especial, círculo, esquiva e ultimate** (`_read_buttons` 510): no hub ele golpearia. Falta um modo "em paz" no `Player` (só andar e correr), dono `gameplay-engineer`. |
| Modelo sem lógica | `HeroBody.make()` (`scripts/render/hero_body.gd`) | Sim | Útil para NPC ou vitrine; sem animação de andar própria fora do `Player`. |
| Câmera | `CamFrame` (`core/cam_frame.gd`: `keep`, `follow`, `hold`), `Feel.cam_offset_of`, `Feel.cam_yaw` | Sim (puro) | O seguir da câmera (`Game._follow`, `_place_camera`, `cam_look_at`, 1295 a 1360) é método do `Game` (usa `arena`, `player`, `fx.zoom`, carga do Ômega). O hub precisa de um seguidor pequeno sobre o `CamFrame`; enquadramento combinado com o `art-director`. |
| Ar do mundo | `Game._build_world` (285) | Não | `WorldEnvironment`, lua, glow, névoa, SSAO, `VisualProfile.dress_world` estão inline no `Game`. Extrair para uma função comum (mesma saída, provar com o `RESULT` igual) ou o hub monta o seu. |
| Cenário | `Arena.build(layout)` (`arena.gd:86`), `ArenaRoom` e `ArenaRoom.LOOKS` (`arena_room.gd:13`), `RoomLayout`, `FloorShape.POLY`, `ArenaObstacle` | Sim | Um `RoomLayout` com `look = &"hub"` e um `HubLook extends ArenaRoom` dá chão, colisão (`sweep`, `resolve`), peças, `style()` estilizado e `VisualProfile`. O hub não deve entrar no `StageDef` da descida. Dono da planta e do look: `environment-artist`/`room-designer`; colisão: `gameplay-engineer`. |
| Interação | nada pronto | | **Não existe ação de interagir**. `Controls.ACTIONS` (`controls.gd:8`) não tem `interact`; a loja compra ao pisar, a Provação e o Altar abrem ao pisar num ponto (`Rooms._step_spots` 829, com o "saiu e voltou"). Propor ação nova `interact` (E no teclado, livre hoje; A no controle, livre na luta; remapeável), com cuidado: quem já remapeou teclas pode ter o E em outra ação. |
| Abrir tela e devolver controle | `Game.open_screen`/`close_screen` (1159, 1168) e `_back_to_play` (`Controls.clear_presses`) | Não (são do `Game`) | O padrão é o certo; o hub precisa do seu (ou do `ScreenHost` comum com o título). |
| Placa e prompt | `DoorSign.make(nome, detalhe, glifo)`, `add_note`, `set_short` (`scripts/ui/door_sign.gd`) | Sim | Placa 3D com tamanho fixo na tela e contraste medido; serve para nome e descrição curta da estação. O "E Interagir" com a tecla real: `Controls.label(action)` e `ActionSlot.mark`. |
| Pausa | `PauseMenu` | Sim, quase | Sem `Game` acima ela some com o Mapa e lista Bênçãos vazias; "Sair para o menu" vai a `boot.tscn` (decidir). |
| Música | `Music.play(place)`, `MusicCatalog.PLACES` (`title`, `catacombs`, `morvath`), `Ambience.BY_ARENA` | Sim | MVP: tocar a peça do `title`. Lugar novo `hub` pede uma linha no `MusicCatalog`, opção `music_hub` no save (os `_fixed_keys` preenchem o padrão sem migração) e a linha na tela Músicas. |
| Transições | `TitleBackdrop.fade_out`, o `ColorRect` de fade do `Rooms` | Sim | Simples de repetir. |
| NPCs | nenhum modelo de NPC | | Meshy 0. Opções: bonecos do KayKit guardados (`assets/models/characters`: Knight, Mage, Rogue_Hooded; fora do pacote hoje) assados por `tools/bake.gd -- kaykit` com o `Slender` e repintura, ou peças procedurais. Dono: `technical-artist`. |

Separar do `Game` de combate: o hub deve ser cena própria (`scenes/hub.tscn`, `scripts/hub/...`), sem `Horde`,
`Rooms`, `Combat`, `Ground`, HUD de luta. O que hoje só existe dentro do `Game` e o hub precisa: o ar do mundo, o
seguidor de câmera e o anfitrião de telas. Os três pedem pequenas extrações, não cópias.

---

## 4. Matriz e riscos

### 4.1 Matriz
| Item | Já existe | Reutilizar | Falta | Precisa de decisão |
|---|---|---|---|---|
| Registro do fim da partida e save seguro | sim (`log_run`, `award_mastery`, `Save.write`) | sim | nada | não |
| Troca de cena para o hub | não | o sinal `end.menu` | a cena e a troca | destino da pausa ("Sair para o menu": hub ou título); manter "Descer de novo" na tela de fim? |
| Primeiro acesso | título e Livro (Abertura) | sim | o ponto em que o hub entra | Iniciar vai ao hub sempre, ou a 1ª descida direta e o hub depois dela? |
| A. Vendedor | loja só da descida, ouro só da partida | NPC e placa | moeda persistente, itens, tela | **sim** (economia) |
| B. Forjador | nada | NPC, fornalha | todo o sistema | **sim** (aspectos, cosmético ou níveis) |
| C. Árvore de Dons | `HeroScreen` GIFTS, `TalentTree`, `HeroLoadout`, save | sim, inteira | anfitrião de telas fora do título | não |
| D. Livro de Ahk | `HeroScreen`, `BookSpread`, `CodexScreen` | sim, inteiro | vagas de herói, se aprovadas | **sim** (quatro lugares contra "nenhuma vaga trancada"; o que mostrar nas vagas) |
| E. Portal | `boot.gd:_start`, `JuramentoScreen`, `Game._ready` | sim | função comum de começo | confirmação breve antes de descer (UX) |
| Herói andando | `Player`, `HeroBody` | sim | modo em paz (sem golpes) | não |
| Interagir | não | padrão de "pisar" do `Rooms` | ação `interact` em `Controls`, Controles e Como Jogar | tecla e botão (proposta E e A) |
| Câmera | `CamFrame`, `Feel` | sim | seguidor do hub | enquadramento com o `art-director` |
| Cenário | `Arena`, `ArenaRoom`, `RoomLayout`, `VisualProfile`, `ArenaKit`, `Masonry`, `TombKit` | sim | `HubLook` e planta | arte (`art-director`) |
| Música e ar | `Music`, `MusicCatalog`, `Ambience` | sim (título no MVP) | lugar `hub` | peça própria? |
| NPCs | nenhum | KayKit guardado, procedural | modelos e animação | Meshy segue 0 |
| Nome e lugar | nada no cânone | | | **sim** (ver seção 5) |

### 4.2 Riscos
1. **Saves antigos**: `SaveData.VERSION` 5. `merged` cria do `defaults()` e só guarda chaves conhecidas: qualquer dado
   novo do hub (moeda, forja, flags de visita) **tem que entrar no `defaults()`** (ou no `hero_defaults()`), senão some
   na próxima leitura. Chave nova com padrão não precisa de migração; mudar o sentido de uma existente pede versão 6 e
   um passo no `merged` com fixture nova em `tests/fixtures/`. Um build antigo lendo um save novo descarta as chaves
   novas (rebaixar perde o progresso do hub).
2. **Saída no meio dá Maestria** (`_exit_tree` com `quit`): se o hub tiver "abandonar a descida", ela deve passar pelo
   mesmo caminho (troca de cena), nunca por um `Game` reaproveitado.
3. **Fechar a janela no meio**: o `log_run("quit")` roda no `_exit_tree` durante o `quit()`; não verifiquei se o
   `Save` autoload ainda grava nessa ordem de saída. Conferir no HUB-E (fechar no meio de uma sala e reabrir).
4. **Testes e ferramentas que assumem título e partida**:
   - `tools/title_flow_check.gd` (190 a 247): "Descer starts the run" confere `game.tscn` como cena atual depois do
     Descer e "back to the title from the run" volta ao `boot.tscn`. Se Iniciar passar pelo hub, ele muda.
   - `tools/start_driver.gd`, `tools/map_flow_check.gd`, `tools/menu_lab.gd`, `tools/ui_lab.gd`, `tools/book_lab.gd`:
     abrem `boot.tscn` ou a partida; conferir cada um.
   - Testes da tela de fim: `test_menus_1b.gd` (190 a 194: nomes `retry` e `menu`, foco, texto `end_menu`),
     `test_curse_hud.gd` (190 a 200), `test_c17_ui.gd` (71, 72: `end_again` = "Descer de novo"). Trocar o texto para
     "Voltar ao Santuário" muda chave e testes.
   - `--title --screen=hero|gifts|book|codex|juramentos|map` seguem no título; não quebram, mas o hub vai querer os
     mesmos atalhos (`--hub --screen=...`).
   - `tools/smoke.sh` e a conferência do exe com `--smoke`: não passam pelo título; não mudam se o roteamento do
     `boot.gd:_ready` ficar como está.
5. **Exportação**: `export_filter="all_resources"`; cena e scripts novos entram sozinhos. Bonecos do KayKit em
   `assets/models/characters/*` estão no `exclude_filter`: NPC tirado deles tem que ser assado para `assets/baked/`.
   `convert_text_resources_to_binary=false` continua necessário para Resources novos do hub.
6. **Entrada**: tecla E livre no padrão, mas os saves com teclas remapeadas (`options.bindings`) podem ter o E em
   outra ação; o remapeamento precisa recusar ou trocar. A ação nova tem de entrar em `Controls.ACTIONS`,
   `REMAPPABLE`, Controles das Configurações e Como Jogar.
7. **Estado estático** (seção 2.E): ar do `ArenaRoom` e `VisualProfile` atravessam cenas; testar F7 no hub, ida ao
   hub depois da Câmara do Selo (fase 4 com `RoomMood.LAST_BREATH`) e volta.
8. **Balanceamento**: qualquer forja ou vendedor com poder muda a régua do E6 (`docs/qa/e6_metrics.md`).
9. **Outros agentes**: `make_data.gd`, dados de salas, runas e chão estão em uso por outras frentes; o hub não deve
   pôr a sua planta no `StageDef` da descida (layout próprio, fora de `stage.layouts`, para não entrar no sorteio de
   arenas nem no Compêndio > Arenas).

---

## 5. Grafia e cânone

- **Ahk**: `data/text_pt.tres` usa "Ahk" nas três ocorrências (`howto_map_desc` linha 250, `book_title` 642,
  `book_epigraph_by` 645). **Nenhum "Akh"** no texto do jogo nem em `scripts/`. "Akh" só aparece em documentos que
  registram a grafia errada da diretriz e na prancha local `04-livro-akh.png` (nome de arquivo de referência, fora do
  jogo; citado em `docs/steam-ia.md:30`). O cânone fixa Ahk (`../dungeon-rpg/docs/mundo/canone.md:157`, "Ahk (não
  Akh)"), e "Ahk, o Escriba" é o narrador da "Cronologia e Lore" (`canone.md:339`, `414`).
- **Vigília / Santuário da Vigília**: **não existem no cânone** (`canone.md` e os demais arquivos de
  `../dungeon-rpg/docs/mundo/` não têm "Vigília", "vigília" nem "santuário" com esse sentido; só "atentos e vigilantes"
  na fala de Ahk e um "santuário de Formeth" em `em-aberto.md:52`). **Proposta para o PO.**
- **Colisão de nome no jogo**: "Vigília" já é o nome de uma família de Bênçãos, `family_vigilia` = "Vigília[, voto de
  {P1}]", com "Escudo da Vigília" (`text_pt.tres:32`, `54`) e é provisoriamente "voto do PALADIN_1" (`CLAUDE.md`,
  pendências). Chamar o hub de "Santuário da Vigília" liga o lugar a esse voto; o PO decide se é intencional.
- **Onde fica o hub**: o cânone situa a descida sob a igreja velha de Valmor; um lugar seguro "acima" (a igreja, a
  vila) ou um refúgio novo é escolha de lore do PO. Os NPCs (vendedor, ferreiro) não têm nome nem existência no
  cânone: propostas, sem inventar nomes.
- **Leão**: o leão é de Hanokh e de Elun no cânone (`canone.md:30`, `47` a `57`) e já é o símbolo do herói (D-64 a
  D-71); dois leões no portal estão dentro disso. Nada de sol, cruz ou "Aliança".

---

## 6. Decisões que precisam do PO
1. Economia do Vendedor (nenhuma moeda, moeda persistente nova, ou ofertas para a próxima descida).
2. Forjador (aspectos sem dano, só cosmético, ou níveis com recurso) diante do "sem equipamentos" do item 9 da
   diretriz de um herói.
3. Quatro lugares no Livro contra a decisão da etapa 2 ("só o elenco jogável", "nenhuma vaga trancada"), e o que
   mostrar nas vagas sem nomes.
4. Nome "Santuário da Vigília" (fora do cânone; colide com a família Vigília) e onde ele fica.
5. Primeiro acesso: Iniciar vai sempre ao hub, ou a primeira descida sai direto e o hub aparece depois dela.
6. Tela de fim: "Descer de novo" continua como atalho ou toda descida passa pelo Portal; "Sair para o menu" da pausa
   vai ao hub ou ao título.
