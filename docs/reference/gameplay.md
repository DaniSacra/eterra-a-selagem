# Combate, inimigos, chefe e golpes

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Primeira fase no molde do Hades II (2026-11-14)
- A partida é por salas, com a estrutura e os números da primeira região do Hades II (estudo dos dados do jogo do
  Daniel; nada de arte, nome, história ou som copiado). Notas do estudo: fora do repositório (scratchpad da sessão).
- Escala: 80 unidades do Hades = 1 m (andar 540 = 6,75 m/s; heroína de 200 de altura = paladino de 2,5 m). `U` em `make_data.gd`.
- Salas: `RunMap` (`core/run_map.gd`; desde o DV-1 um grafo gerado no começo, ver Descida de Valmor: abertura com dom, portas que mostram a recompensa, guardião entre as salas 4 e 6,
  uma fonte entre 5 e 8, loja na 10, Morvath na 11: **a descida padrão desde a E3** (C13-01, D-61; `--medium` é a de 7 do
  ciclo C12, fonte na 4, guardião na 5, loja na 6, e `--short` a de 5, as duas com elites desde a sala 2,
  `Rooms.short_stage`), elites desde a profundidade 3 (`elite_from_depth`), nenhuma arena mais de 3 vezes
  (`arena_max_uses`, a menos usada primeiro), `_stage` em `make_data.gd`), `EncounterGen` (`core/encounter_gen.gd`: dificuldade 55 + 15 por sala,
  1 a 3 ondas, no máximo 1 tipo de elite, próxima onda com 1 inimigo de pé), dados
  em `data/stages/catacombs.tres` (`StageDef`, `EncounterPool`, `RoomLayout`).
  **Poucos inimigos, cada um com seu papel** (ciclo 8; o Daniel, 2026-11-15: não é survivor de horda, a referência é o
  Hades II): de pé ao mesmo tempo, comum 4 a 8, difícil 8 a 12 (guardião e elites), especial 12 a 16, teto absoluto 20
  contando invocações (`StageDef.tier_alive`, `alive_cap`; `Horde.alive_cap` e `room_for` cortam a invocação do Ancião
  e de Morvath); Morvath com até 4 invocados de pé fora do ritual e 6 no ritual (`BossDef.adds_cap`, `ritual_cap`, `BossRules.summon_count`). O limite de
  cada sala vai do mínimo ao máximo da faixa ao longo da região (`EncounterGen.cap`, `progress`); cada onda cabe na faixa
  (sobra vira outra onda). Composição por papel (`EnemyDef.role`: pressure esqueleto, react corredor, control feiticeiro,
  flank besteiro, block Escudo, area sacerdote) em conjuntos `EncounterPool` no `_stage` do `make_data.gd`: começo da
  região 2 papéis, meio 3 que se completam, fim misturas exigentes com elites e uma especial rara de 4. `--horde` e
  `--stress` ignoram os tetos. O RESULT do `--smoke` traz `max_alive` (pico de inimigos de pé, chefe incluído), `boss_at` e o custo do passo da simulação medido só nos quadros com inimigos de pé, `step_ms_avg` e `step_ms_peak` (`StepTimer`, `core/step_timer.gd`; `step_ms` continua, suavizado e lido no fim). Nó `Rooms` (`game/rooms.gd`) conduz: ondas, recompensa,
  portas, fonte, loja (o botão de usar compra, C19), chefe. Magia enche em toda sala; sem experiência nem níveis.
- **Bênçãos e economia da E3 (Hades II; regras, números e decisões em `docs/design/e3_blessings.md`, métricas do robô em
  `docs/qa/e3_metrics.md`)**: as portas tiram cartas de um baralho sem repor que volta inteiro quando nada serve
  (`StageDef.reward_deck`, `RewardDeck`: 6 Bênçãos, 2 romãs, 2 corações, 2 Magia, 2 ouro). Raridade em sequência
  (`BoonState.roll_rarity`: rara 16%, épica 6%, lendária 2%, ou 77,4 / 14,7 / 5,9 / 2 (SW-B2; era 10 / 5 / 1); guardião rara 90%, épica 7%), quatro raridades
  comum 1, rara 1,5, épica 2 e lendária 2,5 (D-52, D-53), a lendária só pela troca (E3-01: 10% por carta, a Bênção de
  uma ação ocupada troca por outra uma raridade acima e no nível dela, `BoonState.trade_card`). Cada carta é
  `BoonState.Card` (`Game.offer_cards`: raridade, `trade`, `replaces`, `level`); Bênção que já se tem não volta nas
  cartas (cresce pela romã). Romã: cada número tem `base` (nível 1, vezes a raridade) e `per_level` (ganho fixo por
  nível, o último se repete, sem raridade; `BoonMod.at`, `SkillDef.damage_at`); teto de nível 3 mantido (E3-D1). Elo
  de 0 a 50% por carta (SW-B2: `StageDef.elo_chance` é o teto e `elo_ramp` a fração por Bênçãos na mão; nada com menos de 3, 50% com 10; `StageDef.elo_now`), pede uma Bênção de cada lista (`Boon.requires_sets`), sem raridade e sem nível
  (BUG-017). Sorteio dos anjos (SW-B2): o anjo de cuja família a mão já tem uma Bênção pesa 3 contra 1 de um novo (`Encounter.weighted_order`, `HELD_WEIGHT`), para o par das salas e o anjo das portas. Sem bônus de sequência de golpes (C13-07, D-10). Ouro cai dos inimigos (`GoldPurse`: teto de 10 a 15 +
  0,5 por profundidade, 70% por inimigo da parte dele), recompensa de ouro 100; loja em 3 grupos (`StageDef.shop_groups`,
  `ShopGroup.count`: Bênção 150; cura 50 e coração 125; dois de Magia 100, romã 100 e fatia de romã 50,
  `RunMap.Reward.POM_SLICE`), 5 itens como a última loja antes do chefe final (`Rooms.shop()` para a tela). O robô
  escolhe a porta como gente (`Rooms.bot_door`). `RESULT` com `dealt_by` (dano por fonte, `DealtBy`, `Horde.dealt`) e
  `elos`. Testes: `test_rarity.gd`, `test_elo.gd`, `test_economy.gd`, `test_descent.gd`, `test_boons.gd`.
- Golpes do Hades: ataque em 3 (20, 25, 60 em volta), especial = onda (40; no Hades, a seta), Ômega do ataque segurando 0,8 s (160, para
  frente e para trás, 20 de Magia), Ômega do especial 0,65 s (80, 10 de Magia), avanço 0,2 s / 5,6 m com 19 quadros de
  proteção desde o aperto (C12d) e 1 carga, círculo em volta do paladino (5,4 m, 3 s, um por vez). Vida 30, 1,3 s de proteção após um golpe.
- Inimigos com os números de Érebo: cada um tem a versão elite (`_elite`, armadura do Hades). Guardiões: `knight` (2 investidas seguidas, `EnemyDef.charges`, a segunda com 0,8 s de aviso e nova mira) e `priest_elder` (orbes a 6 m/s, leque a cada 3,5 s).
- Aparência dos inimigos pela prancha do Daniel "Inimigos da Fase 1" (`docs/art/enemies_phase1.md`; imagem só local em
  `docs/art/ref/`): **os nove são os modelos do Meshy** aprovados pelo Daniel (2026-11-15; `assets/models/meshy/enemy_<id>/`,
  esqueleto de 24 ossos, `-rigged.glb`; tom da 3ª versão do Sacerdote: caveira de marfim, roxo apagado, metal escuro, brilho só
  nos olhos e gemas). `tools/bake.gd` (`MODELS`, entrada com `"meshy"`) faz tudo: reduz a malha de 15,5 mil para cerca de 3,9 mil
  triângulos e repassa a pintura para um atlas novo de 1024 (`MeshSlim`, `scripts/render/mesh_slim.gd`), transfere clipes da
  Quaternius e do KayKit pelo `Retarget`, prende as armas do KayKit que o modelo não tem (`held`: lâmina, cajado, besta, escudo
  do Cavaleiro; o Escudo já traz as dele), põe os pés no chão e a altura da prancha (`height`). Armas do KayKit repintadas no
  assado (E1a-4, VX-07, paliativo até o Meshy): `paint` de cada `held` troca as células da paleta por amostras pintadas no tom das
  figuras (`SWATCHES`: ferro escuro, ferro gasto, osso, madeira escura, metal velho, ouro velho, couro, vermelho; primeira linha da
  faixa da paleta, projetadas ao longo da arma, `_repainted`, `_paint_swatches`), sem faixas de duas cores; cutelo a `CLEAVER_SCALE`
  0,58 (aço 0,52 m = 0,6 do tronco), besta a `CROSSBOW_SCALE` 0,62 em madeira com o arco no ferro gasto da lâmina (ciclo LC; era 0,5 em ferro escuro), cajados em madeira escura com anéis de metal
  velho, gancho de Morvath em ouro velho (na tela matiz 37, saturação 0,44). O Escudo tem a rótula esquerda do rig fora do lugar:
  `even_legs` encurta a perna ao alcance que ela tem em repouso (`_even_leg`) e o pé direito, que flutuava 20 cm, pisa no chão.
  Testes em `tests/test_held_weapons.gd`; antes e depois em `docs/gallery/e1a/after/weapons/`. A textura vai dentro do `.res`
  (`BakedModel.painted`). Cor da magia em `EnemyDef.magic_color` (feiticeiro violeta frio, sacerdotes roxo; a necromancia de Morvath é o verde
  espectral frio do pedido do Daniel de 2026-11-15, `SPECTRAL`, mais azulado e pálido que o verde cristalino da Emeth); olhos, gemas e orbes brilham pela própria pintura (`paint_glow` no `crowd.gdshader`).
  **Elites sem créditos**: a mesma figura com o aço em ouro velho por shader (`EnemyDef.gild`, `ELITE_GILD` no `make_data.gd`,
  `gild` no `crowd.gdshader`), contorno escuro fino, borda fraca e barra de armadura; uma repintura no Meshy (10 créditos cada)
  ficaria melhor e depende do Daniel. Galeria: `tools/enemy_lab.gd` (ids opcionais para ver de perto).
  Ciclo 7 (papel de cada um pela silhueta, arma e pose, não só pela cor): avisos de preparo por `EnemyDef.tell` num MultiMesh só
  (`EnemyFx`, `enemy_tell.gdshader`, lidos de `Enemy.state_t`), campos de aparência `vivid`, `crest`, `shine`, `sway`; peças
  rígidas no assado (`rigid` em `tools/bake.gd`: escudo preso ao antebraço do Escudo); ouro da elite só no aço; armadura com
  centelhas ao absorver e estilhaços ao quebrar; Morvath violeta com coroa pálida.
  Ciclo 8: os avisos de preparo crescem até pouco antes do golpe e somem quando ele sai (`EnemyFx.ramp`): brilho em cruz da
  lâmina, virote puxado com um traço claro na direção da mira, borda do escudo desde 30% do preparo e poeira nos pés; um
  golpe inclina o corpo para trás por um instante (`Horde.RECOIL_TILT`, nada quando a armadura absorve).
  Os bonecos do KayKit e as paletas (`tools/make_palettes.gd`, `assets/models/palettes/`) ficam guardados, sem uso:
  `tools/bake.gd -- kaykit [ids]` volta a assá-los. Prompts e repinturas em `tools/meshy/prompts.json`.

## Onde mexer
- **Elo** (mecânica das Crônicas de Eterra) = dom duplo do Hades: família `DUO` em `scripts/core/boon.gd`, dom com
  `requires_sets` (E3-02: uma lista por família, uma Bênção de cada forma o Elo; `BoonState.forged`), 12% por carta,
  sem raridade e sem nível (BUG-017; `Boon.has_rarity`, `max_level` 1) (12 hoje, 6 deles dos anjos 5 a 7, AN-2: ver `meta.md` "Anjos 5 a 7"; nome "Elo" no texto desde 2026-11-15). A carta mostra os dois dons de origem
  numa corrente de ouro velho com o Elo no meio (`EloLink`, `BoonState.sources`), o medalhão do Elo tem aro de elos,
  a HUD saúda cada Elo novo com "Elo formado" sem pausar (`EloBanner`) e a pausa tem o painel "Suas bênçãos" (`BoonsScreen`).
  Capturas dessas telas numa partida real: `tools/ui_lab.gd` (comando no topo).
- **Pacote de direção de arte, etapa 1B (menus, pranchas 06 e 10, só locais em `docs/art/ref/direcao_2026-11-17/`;
  antes e depois a 720 e 1080 em `docs/gallery/artpack/stage1b/`)**: uma linguagem só para as páginas de menu em
  `UiKit` (`page`: painel de tinta com fio de ouro velho e sombra, título Cinzel sobre o `GoldRule`, o antigo
  `EndScreen.Ornament`; `primary` para a ação principal em bronze; `tab` com a aba à mostra em petróleo; `link` para as
  saídas discretas; `section` "Nome ———"; `focus_row` para linhas que tomam foco dentro de rolagem; `gift_icons` e
  `carried_of` para os medalhões levados). **Pausa** (`PauseMenu`): o quadro congelado fica, escurecido só à esquerda
  (`SHADE_*`), painel compacto à esquerda com Continuar em destaque, Bênçãos, Compêndio, Configurações, os medalhões da
  descida ("Bênçãos da descida: N", até 15 e "+N") e no rodapé Sair para o menu e Sair do jogo; cima e baixo dão a volta,
  e a página aberta devolve o foco ao botão que a abriu. **Suas Bênçãos** (`BoonsScreen`): grupos Ações (pela ordem das
  ações, `Boon.slot`), Efeitos automáticos (`Slot.NONE`) e Elos (`BoonsScreen.group_of`); à esquerda uma entrada por
  grupo com a contagem, que leva o foco à primeira linha; à direita a lista rola com o foco. **Créditos**
  não são tela (o Daniel, 2026-11-18: "não tem nada"): `CREDITOS.txt` na raiz, copiado ao lado do exe e depois na página
  da Steam, com todas as atribuições (CC BY de Kevin MacLeod e Little Robot Sound Factory exigem crédito).
  **Vitória** (`EndScreen`): primeiro a selagem sozinha (`SealEmblem`: aro de ouro velho que se fecha em volta do leão do
  selo da Câmara, `lion_sdf.res`, que acende; nunca sol nem cruz), depois o resumo sobe (`SUMMARY_AT` 2 s); apertar
  durante a selagem mostra tudo (`finish_sealing`). **Derrota**: painel com o título, "Derrotado por", onde caiu, as
  Bênçãos levadas, a Maestria, os números e Tentar de novo (`primary`, com foco) e Menu. **Configurações**
  (`OptionsScreen`): abas Áudio (volumes em régua com losango, clicável, `Gauge`; Músicas), Vídeo, Conforto e Controles
  (teclas com o valor à direita, Teclas padrão); andar sobre uma aba mostra a página dela, baixo entra nela; o foco
  guardado num `_build` abre a página onde está. **Como Jogar** (`HowToScreen`): abas "A descida" (três passos:
  portas, Bênçãos, Morvath na Câmara do Selo; `howto_step_*`) e Controles (a tabela de teclas de antes); Compêndio
  e Voltar no rodapé. A prancha 10 mostra escolha de capítulo: o jogo tem uma região, então não há. Tela do
  herói: só o `GoldRule` (a árvore é da etapa 2). Capturas: `tools/menu_lab.gd` (comando no topo; pausa com poucas e
  muitas Bênçãos, Suas Bênçãos no topo e rolada, derrota, vitória em três momentos e, com `--title-screens`, Como
  Jogar, cada aba das Configurações e Músicas). Testes em `tests/test_menus_1b.gd`.
- **Tela de dons "Um dom chega até você"** (2026-11-16, referências de IA só locais em `docs/art/ref/boon_cards/`):
  `BoonChoice` monta três `BoonCard` (`scripts/ui/boon_card.gd`, 320 x 450 a 720 linhas): arte no topo sobre um brilho
  da cor da família, nome em marfim, família ou "Elo de A e B", ação, nível e raridade numa linha, filete com losango,
  descrição sobre tinta escura e "Substitui X" embaixo. Medalhão pintado pelo id do dom (`BoonArt.medallion`:
  `assets/ui/boons/<id>.png`; hoje `vapor`, `aurora`, `redemoinho`, recortados da prancha por
  `tools/cut_medallions.gd`, 512 px com mipmaps): dom novo com arte é só pôr o PNG com o id. Elo pintado: `EloLink`
  com `art`, as duas origens (`BoonIcon` de 46 px) numa corrente curta que entra no aro pintado (o aro do PNG é o
  único). Sem arte: o `BoonIcon` desenhado (e o `EloLink` desenhado no Elo). HUD e painel "Dons" não usam os PNGs.
  A borda e o brilho de fora seguem a raridade (comum fica no metal, `BoonCard.COMMON_EDGE`); o foco é um filete
  marfim por dentro e a tinta mais clara (`FOCUS_*`), sem escala (borrava o texto). Proteção de 350 ms
  (`BoonChoice.GUARD_MS`). A carta de descanso ("Fôlego") existe na tela, mas a partida por salas aplica o descanso
  direto quando não há oferta (`Game._open_choice`). Capturas: `tools/ui_lab.gd -- --card-only [--offer=a,b,c]
  [--held=x,y] [--rarity=0,2,1] [--upgrade=0,1,0] [--trade] [--rest] [--focus-move]`; galeria em
  `docs/gallery/boon_cards/` e `docs/gallery/e3/ui/`; testes em `tests/test_boon_cards.gd` e `tests/test_e3_ui.gd`.
  **Pacote de direção de arte, etapa 1A (2026-11-17; pranchas só locais em `docs/art/ref/direcao_2026-11-17/`, antes e
  depois em `docs/gallery/artpack/stage1a/`)**: título "Escolha uma bênção" (`choice_title`; a dica embaixo diz que a
  Bênção fica até o fim da descida). Medalhões pintados também de `brasas`, `toque_geada`, `onda_maior` e `escudo`
  (`tools/cut_medallions.gd -- --board=... --grid=4x3 --names=...`, modo grade, 384 px, máscara pelo aro redondo) e
  das trocas do altar e do selo da Provação em `assets/ui/events/` (`BoonArt.event`: `pomegranate`, `candles`,
  `passage`, `trial_seal`); o Salmo do atlas (livro com cruz) não entrou. Glifos pequenos com o mesmo motivo
  (`BoonIcon.glyph`: Brasas três brasas caindo, escudo com estrela de quatro pontas, nunca cruz). A ação da carta e o
  "Transforma" do Salmo levam o símbolo do HUD (`ActionSlot.mark`). Troca: "Sai" e "Entra", cada uma com glifo, nome e
  raridade, nessa ordem (`BoonCard._swap`, nó `Replaces` com `TradeOut` e `TradeIn`; textos `choice_trade_out`/`_in`).
  Altar: medalhão pintado, a marca da recompensa ao lado do que se entrega e recebe (`BoonCard.ALTAR_MARKS`) e "Sem
  custo" em Seguir em frente (`altar_free`). Provação: só o medalhão da Bênção no topo; o selo rachado pintado fica na
  faixa da maldição (`CurseSeal`). Marcas das recompensas (`DoorGlyph.of_reward`: Bênção um aro com o losango do filete
  das cartas, romã, coração, gema da Magia, moeda, gota) nas placas das portas, ao lado do nome (o pictograma da sala
  vai para a linha de baixo, `DoorSign.make(..., glyph, reward_mark)`), na loja e nas cartas do altar. Ultimate pronta:
  anel fechado de luz esmeralda em volta do losango, um pulso breve quando enche e depois só respira
  (`ActionSlot.READY_*`, `ready_ring`, ligado ao `pulse` do `Hud._update_ult`).
  **Carta de Salmo (E4-03)**: `Game._open_choice` chama `BoonChoice.open_cards(cards, state, game)` quando um Salmo vem
  na tiragem; a escolha sai por `card_chosen(card)` para `Game.choose_card` (Bênção ou Salmo). `BoonCard.setup_psalm`:
  moldura própria, octógono de cantos cortados (`PSALM_CUT`) com linha dupla marfim (`PSALM_EDGE`), ouro velho por
  dentro com losangos nos cortes, arco ogival de ouro velho sobre o medalhão e o brilho na cor do `PsalmDef.color`;
  aba "Salmo" (ou "Salmo descoberto" na primeira vez da vida do save) com um arquinho; nome, "Transforma: ação",
  descrição com os números do efeito e "Aberto por A · B · C" (as três coisas da mão que abriram, uma por grupo,
  `Psalms.matching`, `BoonChoice.opened_by`; Dom pelo nome do Dom). Sem raridade, nível, número de salmo nem versículo
  (teste lê toda etiqueta). Medalhão `PsalmIcon` (`scripts/ui/psalm_icon.gd`): selo de tinta, aro de ouro velho e
  marfim, arco ogival na cor do Salmo e um glifo por efeito (aro com três marcas, cúpula com tiro partido, três luzes
  que se juntam, pedra de pé com fenda); nunca sol nem cruz. **"Salmo descoberto" (E4-04)**: `EloBanner.show_psalm`
  (em fila com Elo e Bênção nova), pedido pela HUD (`psalm_offered` com `first`, `psalm_taken`) e mostrado só quando a
  tela de cartas fecha (`Hud._update_psalms`, modo PLAY): título, medalhão e nome, embaixo a frase do Salmo tomado
  (`line_key`) ou "Anotado no Compêndio". **Luzes do Pastor**: losanguinhos na cor do Salmo sobre o losango do
  especial (`ActionSlot.show_lights`, `LIGHT_*`), apagados os que faltam; só com o Pastor. Capturas:
  `tools/ui_lab.gd -- --psalm-card=id`, `--psalm-banner=id`, `--codex=psalms|enemies|morvath|arenas`; galeria em
  `docs/gallery/e4/ui/`.
  **E3 na interface**: uma moldura por raridade (comum no metal com rebites, rara uma linha azul, épica linha dupla
  violeta, lendária linha dupla de ouro velho com floreios nos cantos, `BoonCard.RARITY_LINES`, `FLOURISH`); a cor de
  cada raridade é uma só no jogo todo (`Boon.RARITY_COLOR`: rara `6f9be6`, épica `b07ae6`, lendária ouro velho
  `d4ad66`, nunca amarelo vivo; `BoonCard.rarity_color` usa ela e só a comum fica no metal `COMMON_EDGE`), também na
  palavra da raridade da carta e do painel "Dons" (`BoonsScreen`, ao lado do nível; Elo sem raridade). Elo sem raridade
  nem nível, moldura de corrente. Troca (E3-01) com a aba "Sobe uma raridade" no alto da carta e "Troca X: de A para
  B" embaixo, no nível da Bênção trocada. **Ligação com as regras**: `Game._open_choice` passa as cartas da regra
  (`Game.offer_cards`, `BoonState.Card`) à tela por `BoonChoice.offers_of` (`{rarity, upgrade}` por id, upgrade =
  `Card.trade`); a tela lê com `BoonChoice.offer_of` (aceita também a raridade crua) e `_take` toma a própria carta
  (`BoonState.take_card`: raridade e nível da troca). "Bênção nova" (E3-04): a primeira vez que se toma uma Bênção na
  vida do save, saudação curta no alto sem pausar (`EloBanner`, em fila com "Elo formado", `fresh_boons` contra
  `codex.boons`). Compêndio (`CodexScreen`; 8 abas desde a E4-05: Dons, Bênçãos, Elos, Salmos, Inimigos, Morvath, Arenas, Golpes; desconhecidos como "???", receita
  do Elo quando as duas Bênçãos já foram vistas). Loja: cada item com `DoorSign.shop(nome, preço, grupo)` (palavra do
  grupo em cinza frio por cima, `Rooms.SHOP_GROUP_KEY`, omitida quando é igual ao nome; preço em marfim) e
  `set_gold` sempre que o ouro muda (o `Rooms.gold` tem setter): sem ouro o preço fica rosa apagado com "faltam N".
  Os itens ficam numa fileira reta na tela (ao longo da direita da câmera, `Feel.cam_yaw`), `Rooms.SHOP_STEP` 5 m entre
  eles e o meio `SHOP_SHIFT` 3,5 m para o lado da entrada: com 5 itens sobram 45 px ou mais entre as placas a 1080 e
  a última cabe na tela a 1280 x 720 (`docs/gallery/e3/ui/shop_real_*.jpg`; `tools/ui_lab.gd -- --start=shop --shop
  [--gold=N]`).
- Combos: `data/combos/paladin.tres` (nós `ComboNode`; `tags` é o que os dons enxergam; os seguintes em `next`, um
  `Array[Resource]`, lidos tipados por `following()`: o `Array[ComboNode]` dentro da própria classe vazava o script na saída,
  as linhas "ObjectDB instances were leaked" e "resources still in use" de toda execução, ciclo 10). Dons: `data/boons/*.tres`
  (`Boon.slot`: um dom por ação, ATTACK/SPECIAL/CAST/DASH, o novo substitui o antigo; NONE = age sozinho, sem limite.
  Raridade sorteada por carta em sequência, `Boon.RARITY_MULT` multiplica o nível 1 dos números com `BoonMod.by_rarity`)
  (`BoonMod`: `stat`, `tag`, `base` e `per_level` (E3, C13-05: ganho fixo por nível); as estatísticas que o jogo
  conhece estão em `scripts/game/combat.gd` e `game.gd` `_take`). Baralho das portas, raridade, loja e ouro: dados no
  `_stage` do `make_data.gd` (`reward_deck`, `rarity_chance`, `guardian_rarity_chance`, `elo_chance`, `trade_chance`,
  `gold_*`, `shop_groups`). Inimigos: `data/enemies/*.tres`. Ondas, elites, fonte e chefe: `data/waves/catacombs.tres`.
- **E1c, Morvath sumia e aparecia em outro lugar para atacar (bug 3)**: a posição dele no jogo nunca saltou; o desenho
  sim. Os golpes dele vêm de clipes das bibliotecas com deslocamento de raiz assado no quadril: a foice (`slash3`,
  Sword_Regular_C, desde a E1b `43229d9`) punha o corpo até 8 m à frente (4 m já na primeira pose) e voltava de uma vez no
  fim, longe dos avisos e da colisão; as Lâminas (`slash1`/`slash2`, Sword_Regular_A e B, desde `faef8d6`) 3 m e o
  arremesso (`volley`, OverhandThrow, `43229d9`) 1,8 m. `tools/bake.gd` ganhou `in_place` (quadril fixo no lugar, como os
  `_RM`) nesses clipes; `BakedModel.pose_centre`/`drift` e `tools/pose_drift.gd` medem (toda pose dele a no máximo 0,45 m
  no tamanho 1, fora queda e levantar). Também: a troca de clipe dele é uma mistura de `Horde.BOSS_CLIP_FADE` (0,12 s, 0,18 desde o T5b) da última
  pose para a nova (`CrowdRenderer.add_kind` com `from_row`/`fade`; antes o corpo pulava até 0,96 m num quadro), o
  atordoamento dele desenhava `idle` (o `Horde.render` lia o `stun_t` que o `Boss` segura; desde o marco 5), e as Lâminas
  e a maldição começam o arremesso antes do tiro para a soltura cair no quadro do tiro (`Boss.THROW_PEAK`, `_throw_by`; o
  pico vinha 10 quadros depois). `tools/boss_probe.gd` acompanha a luta quadro a quadro. Testes em `tests/test_boss_body.gd`
  (poses, as 4 fases até a queda, passo simulado e desenhado, clipe desenhado, avisos onde ele está, soltura). Vídeos em
  `docs/gallery/e1c/bugs/`.
- **Morvath mais difícil (E2)**: camadas `BossAttack.layers` (fase 3: maldição, foice e lâminas com erupções e/ou invocados; fase 4: tempestade com erupções e invocados) com a faixa livre das erupções onde o ataque de baixo não alcança (`BossRules.free_way`) e os invocados nos tetos de sempre; tempestade em 3 ondas (recarga 4 s), descansos 0,6 e 0,4 s nas fases 3 e 4, maldição 6 s, invocação 9 s; vida 6050 e dano iguais. Robô 0,25 com 5 Bênçãos: 8 de 16 vitórias (era 14). `RESULT` `boss.layers`; medição em `docs/qa/e2_morvath.md`, tempos em `combat_cadence.md` 1.4 (`tools/boss_cadence.gd`).
- **Morvath mais difícil, como o Cavaleiro (2026-11-23, pedido do Daniel)**: nenhum ataque dele marca o chão, só as erupções (e a Ruptura e os círculos de invocação); cada
  ataque é anunciado pelo "!" amarelo sobre ele (`Horde.strike_in` lê as zonas escondidas via `Enemy.fan`; `Boss._warn` esconde com `Ground.mute`, `_announce` cria a zona
  só do aviso para investida, invocação, erupções e rajada). Ele não persegue: no `CHASE` fica parado e escolhe pela distância (`BossAttack.max_dist`, `near_bias`,
  `far_bias`, `BossDef.near/far`): perto a foice e a ceifa (`max_dist` 8 e 6), longe lâminas (fases 1 e 2), rajada, maldição, invocação (agora os magos) e a investida
  (rara). Menos ócio: descansos 0,9/0,8/0,5/0,35, `gap` 0,1 a 0,7 (0,05 a 0,3 sem vida), ceifa 1,4 s de recuperação, foice se aproxima 0,7 s no máximo; um ataque novo só
  espera um tiro dele a menos de `shots_gate` (7 m) do herói. Fases finais: `BossAttack.late_from_phase/late_weight` (fase 4) pesam mais o que é de longe; a Tempestade
  das Seis Almas saiu da lista e a **Rajada das Almas** (`barrage`, a partir da fase 3) é uma metralhadora: `barrage_count` (8 e 12) tiros um depois do outro, `barrage_gap`
  (0,25 e 0,2 s) entre eles, cada um mirado na posição do herói no instante do tiro (sem antecipação), corpo girando atrás dele (`barrage_turn`). O código da
  tempestade segue para os testes (`tests/boss_layers_fixture.gd` a põe de volta). Testes: `tests/test_morvath_hard.gd`. Robô, 12 sementes `--start=boss --boons=8`:
  vitórias 5 para 4, luta mediana mais curta (o herói morre mais cedo), espera média entre ataques 0,70 para 0,37 s.
- **Morvath, a luta em 4 fases** (pedido do Daniel de 2026-11-15; desenho em `docs/design/morvath_boss_fight.md`): todos os
  números em `data/bosses/morvath.tres` (`BossDef`, gerado por `_bosses` no `make_data.gd`, parte `bosses`); a escolha do
  ataque é do `BossDirector` (`core/boss_director.gd`: fase, distância, paladino parado, recargas, sem repetir, nunca vazio,
  `BossAttack` por ataque); fases, padrões, ritual e teto de invocados em `BossRules`; estados e desenho em `scripts/game/boss.gd`.
  A vida para em cada limiar (`Enemy.hp_floor`): 1 "O Despertar" (100 a 66%: Foice Sepulcral em meio círculo de 5 m, Lâminas
  das Almas, investida), 2 "O Ritual dos Mortos" (66%: vai ao meio, escudo, invulnerável só no ritual, 2 esqueletos e 2
  feiticeiros, até 6, no máximo 20 s ou até esses 4 caírem: os reforços que sobem a cada 6 s pressionam mas não contam, ciclo 10,
  BUG-002; contagem para a barra em `Boss.ritual_left()`, `ritual_total()` e o sinal `ritual_changed(left, total)`; com
  `--boss-hp` na fase 2 o ritual roda; Erupções Sepulcrais; depois invocações ocasionais), 3 "A Maldição dos
  Condenados" (33%: projétil que persegue pouco; maldição de 3 s no paladino, `CurseState`/`Player.apply_curse`: 30% mais
  lento e especial travado, 2 s de imunidade), 4 "O Último Suspiro" (15%: portal verde espectral, Tempestade das Seis Almas
  em duas ondas, descansos menores). Meias-luas: `Projectiles.Kind.SOUL` (`soul_crescent.gdshader`, acerta uma vez), maldição
  `Kind.CURSE`. Cenário da luta (ciclo 9): escudo do ritual de vidro espectral `BossShield` (`boss_shield.gdshader`, círculo de
  runas no chão, partículas em órbita; `Boss` controla pelo `power` do material e passando de 1 ele se parte em cacos);
  erupções e invocações são círculos rituais cuja borda é exatamente a área (`Ground.rune_burst`, `Ground.Rune`,
  `ritual_rune.gdshader`): runas fracas que acendem, pulso duplo, coluna espectral (`spectral_column.gdshader`) e as runas
  se desfazendo; o aviso com `Zone.eruption` vira círculo sozinho; a runa de invocação (`Rune.SUMMON`, sem dano) marca o
  tempo em que cada morto se ergue e a coluna dela é a única do erguer; cancelada (`clear_warnings`, `end_zone`) some sem
  coluna. Fase 4: portal inquieto (`Arena.final_phase`, `PortalOmen`, `unrest` no `portal.gdshader`, partículas no ar).
  Vitória: selagem do portal (`Arena.seal_portal`, 2,4 s, `Boss.VICTORY_SEAL`, terminando em `VICTORY_CALM`, antes da tela).
  Obeliscos abrem em pontilhado em volta do herói atrás deles (`see_through` no `masonry.gdshader`, código comum em
  `see_through.gdshaderinc`; C12a: as velas da frente da Câmara do Selo também, `Masonry.candle(..., open)`, `see_open`,
  `candle_wax_see.gdshader`, `flame_see.gdshader`). C12a na câmara: faixas da tempestade translúcidas (`GroundLook.STORM_*`:
  preenchimento 0,09, aro a 0,75 abaixo de 1, nada perto da raiz até 5 m, `root_rim`, `light_cap`) e o miolo do selo
  escurece enquanto elas estão no chão (`BossChamber.STORM_DARK`); fio violeta dos avisos separado do aro por 2 px
  (`thread_gap_px`); estrela da vitória abaixo do limiar (`seal_converge_light`, `seal_heart_light`); janelinhas em pares
  e nenhuma na bruma oeste (`FAR_WINDOW_PAIR`, `FAR_WINDOW_HIDDEN`); tampa e friso dos sarcófagos mais claros
  (`SARC_LID_LIGHT`, `SARC_FRIEZE`); espada dos estandartes no meio do pano com borda escura (`ArenaKit.BANNER_SWORD_*`);
  névoa volumétrica e SSR só ligadas no Forward+ (`_build_world`; sem aviso no log do Compatibility). HUD (ciclo 9): na barra
  (`HudBar.show_boss`) as marcas de fase ficam escuras à frente da vida e viram ouro velho com losango quando passadas, a
  recém-atingida pisca (`MARK_FLASH`); o nome da fase aparece por 3 s embaixo da barra (`Hud.show_phase`: o `show_notice` da
  fase vai para lá, nome até o primeiro ponto, dica embaixo); escudo do ritual = moldura na cor dele, véu fino e faixas
  inclinadas correndo (`SHIELD_*`); ciclo 10: no meio da barra um losango por morto do ritual (`HudBar.show_ritual`, de
  `Boss.ritual_left`/`ritual_total`; de pé, a cor do escudo dentro de ouro velho; caído, escuro e vazado, com um lampejo) e,
  depois do nome da fase, "Derrube os mortos" embaixo enquanto o escudo está de pé. Maldição no herói: runas pequenas girando na cintura e névoa violeta no chão (`CurseAura`,
  `curse_aura.gdshader`, abaixo do glow), borda violeta no corpo, veios violeta subindo pela lâmina da Emeth
  (`EmethSword.set_corrupt`, `corrupt` no `emeth.gdshader`), um sopro de partículas só quando pega. No HUD: selo
  `ConditionBadge` junto ao medalhão (anel que esvazia, "Amaldiçoado" e "Mais lento e sem especial"), aro do medalhão
  violeta, losango do especial com véu violeta, cadeado e fio que encolhe (`ActionSlot.locked`), anel de luz quando volta.
  Golpe sofrido (ciclo 10, BUG-007): nada de tela inteira vermelha; só as bordas, por 0,22 s, alfa até 0,42 nos cantos (metade abaixo de
  10 de dano), separação de cores pequena só nos fortes; amaldiçoado (ou pelo projétil da maldição), borda violeta da aura com
  alfa 0,2 por 0,2 s e sem separação (`HurtTint`, `core/hurt_tint.gd`; números no grupo Hurt do `Feel`, `_feel` do
  `make_data.gd`; `hurt`, `curse` e `hurt_edge` no `screen.gdshader`). Derrota: "Derrotado por: X" logo abaixo do título
  (`EndScreen`, `stats.defeated_by`) e, embaixo, onde caiu ("Sala 3 de 7, Cripta dos Esquecidos", `EndScreen.where_text`:
  `stats.room`, `rooms_total`, `arena` ou, sem eles, o `Game` de cima; a sala de Morvath diz "A Câmara do Selo", o salão
  "Salão das Catacumbas") e os dons levados em medalhões, como na vitória (`stats.gifts` ou `game.boons`; ciclo C12c, UI-02,
  `tests/test_end_screen_run.gd`). Placas das portas, da recompensa e da loja: `DoorSign` (`scripts/ui/door_sign.gd`, UI-01):
  nome em ouro claro e preço em marfim, Alegreya Sans Bold com contorno escuro, `fixed_size` com maiúsculas de
  `DoorSign.CAP_PX` 19 px a 1080 linhas (proporcional em outras telas, pelo campo de visão da câmera) e contraste de pelo
  menos 4,5:1 com o contorno (`DoorSign.contrast`). "Novo melhor tempo!" nunca sem save (`EndScreen.open` confere `Save.enabled`).
  Configurações: grupo "Conforto" com tremor, clarões de impacto, câmera lenta (com zoom e desfoque) e separação de cores, todos
  ligados por padrão (`OptionsScreen.COMFORT`, `Fx.slow_motion`, `Fx.color_split`, `Game.apply_options`); C12d: vibração do
  controle (`opt_rumble`, chave `rumble` do save, ligada; a partida lê `Save.option("rumble")`; ligar dá um zumbido curto de
  teste em todo controle, `OptionsScreen.RUMBLE_TRY`; linhas da coluna da esquerda com 42 px, `ROW`, para caber em 720); fluxo por teclas
  em `tools/title_flow_check.gd`, testes em `tests/test_comfort_ui.gd`. Capturas: `--shot-on=hurt|hurt-cursed|end|ritual-left:N`.
  Vitória (`EndScreen`, depois da selagem): título, "O poder de Morvath foi contido.", os dons levados, tempo, abates,
  sequência, ouro, "Continuar" (título, com foco) e "Descer de novo". Testes em `tests/test_boss.gd` (saídas sempre
  possíveis, diretor, ritual, maldição e a luta numa cena real). Capturas: `--boss-only=<ataque>`,
  `--shot-on=boss:<momento>` (`Boss.moment`), galeria em `docs/gallery/morvath/`. `RESULT` traz `boss` (`Game.boss_stats`).
  **Ciclo 9 (frente A, refinamento; detalhes na seção 0 do documento)**: paleta do chefe em `Boss` (`VIOLET`, `SPECTRAL`,
  `CORRUPT`); todo efeito cobre só a área que fere. Foice: clipe `slash3` esticado no preparo, `Fx.boss_scythe`
  (`boss_scythe.gdshader`) no setor exato, cinzas, recuperação. Meias-luas com núcleo, fumaça violeta, rastro curto do
  tamanho do alcance (`boss_wake.gdshader`) e dissipação, colisão igual. Investida: preparo, faixa revelada
  (`Fx.boss_dash`), impacto dentro da faixa. Toda recuperação é uma janela (`State.RECOVER`, `stats.windows`/`punished`).
  Fases abrem no próprio padrão (`BossDef.phase_openers`), sem quadro branco. Reforços um por vez com runa
  (`Ground.Rune.SUMMON`, `rise_stagger`, teto 6 vivos e 20 na luta, `BossRules.reinforce_room`). Paladino amaldiçoado: avisos
  mais longos na mesma proporção (`BossRules.cursed_windup`). Fase 4: meias-luas uma por vez (`storm_stagger`,
  `storm_order`), combinações (`BossAttack.then`, `chain_ready`), luz do portal pulsando entre o verde espectral e o violeta
  (`_step_final`, por cima do portal inquieto), borda corrompida. Vitória curta
  (`Boss.VICTORY_TIME` 3,6 s, com controle; ciclo 10: sem pisca no golpe final nem na queda, `Horde.death_flash`, e o corpo
  escurece a pedra violeta, `Boss.VICTORY_DIM` 0,55 e `VICTORY_GREY` 0,5 sobre o `tint` e o `desaturate` do material): o poder dele volta ao altar e ao portal (que se sela, `seal_portal`), a Emeth brilha (`Fx.blade_glow`),
  `Game.victory_started`/`victory_finished(stats)`, depois `await _play_ending(at)` e `_open_end` (a tela de fim). Golpe no
  escudo (alvo invulnerável) só faísca: sem flash, número, combo, fogo ou gelo (`Combat.hit_enemy`, `WARD_SPARK*`). Para as frentes de arte: `Boss.cue(nome, onde,
  direção, tamanho, segundos)`. Simulações: `--boon-ids=a,b,c`, `--bot-reaction=0.25`, `--bot-kite=0.2` (o robô
  passa essa fração de cada 10 s da luta longe do chefe, a mais de 11 m, correndo, e atira o especial de lá: a investida aparece,
  ciclo 10, `Bot.kiting`); métricas por ataque no `RESULT`
  (`hurt_by`, `hits_by`, `phase_time`, `died_phase`). Testes novos em `tests/test_boss_refine.gd`.
- **Câmara do Selo** (ciclo C11, a arena de Morvath; raio e contas em `docs/design/boss_arena.md`, arte em
  `docs/art/boss_chamber_spec.md`): o `StageDef.boss_layout` é um `RoomLayout` com `chamber` e `floor` (`FloorShape`,
  `core/floor_shape.gd`: retângulo ou círculo, `contains`, `clamp`, `edge_distance`, `cut`), círculo de 12,5 m (o herói anda
  até 12), herói nasce em (-0,9; 10,4), Morvath em (0; -1,2) sobre o selo; as salas comuns continuam no salão. `Arena.shape()`
  é o chão de qualquer sala (o salão vira o retângulo menos `Arena.WALL`); `resolve`, `inside` e a esquiva seguem o círculo,
  sem limite invisível. `Arena._build_boss_room` monta os dados e `_chamber_look` o visual: o `BossChamber`
  (`scripts/game/boss_chamber.gd`, plano da spec em constantes; `build(arena, layout, seed)`), que recebe `open_door`,
  `final_phase` e `seal_portal` pelo `Arena.chamber` e os `Boss.cue` pelo `on_cue` (ligado em `Boss.setup`). Cenografia:
  selo de ouro velho com o leão rampante em relevo (campo de distância `assets/textures/seal/lion_sdf.res`, do `lion.svg`
  por `tools/make_seal_lion.gd`) e a rachadura violeta que cresce por fase, desenhados no próprio chão
  (`chamber_floor.gdshader` = o corpo do chão do salão, `catacomb_floor.gdshaderinc`, com `#define CHAMBER` e
  `chamber_seal.gdshaderinc`); cinco estados no tempo por `SealLook` (`core/seal_look.gd`: repouso, preparo do ritual,
  ritual, fase final com veios pelas juntas, vitória), quebra do escudo entre eles; balaustrada com velas, lanternas
  violeta, pilaretes e sarcófagos com a espada erguida, fachada com a porta selada (`chamber_door.gdshader`, costura
  que pulsa na fase 4 e se fecha na selagem), estandartes com a espada (`ArenaKit.banner(..., emblem)`), escada sul com o
  véu de runas (`chamber_veil.gdshader`), muralha de arcos, torre, correntes, anel de arcadas, ar próprio
  (`BossChamber.dress`; guardado em `air_of` e devolvido ao salão quando a câmara sai, `restore_air` no `_exit_tree`,
  testado em `test_boss_chamber.gd`). Polimento C11: céu azul-marinho (cartões das agulhas em silhueta `SPIRE_*`, luz
  azul `BLUE_ENERGY` 1,2), colunas altas de névoa violeta nos lados do abismo (`COLUMNS`), correntes grossas da torre e
  da fachada até as arcadas que cruzam a faixa de cima da câmera do jogo (`CHAINS`, `CHAIN_SIZE`), pontas da estrela
  mais largas com chapa de bronze e espinha de ouro (`seal_point*` no `chamber_seal.gdshaderinc`, só albedo), sarcófagos
  maiores (`SARC_*`, velas do nicho em `NICHE_CANDLES`), veios da fase 4 orgânicos (raízes de ruído torcido, violeta com
  miolo esmeralda corrompido escuro e mancha roxa na pedra, `vein_*`), não mais pelas juntas. O desfazer da morte de
  qualquer inimigo (`state.a` no `crowd.gdshader`) só arde nas partículas que vão sumir, em ouro velho abaixo do glow
  (`dissolve_color`, `dissolve_band`): antes o corpo inteiro brilhava laranja 3,2 e Morvath caído virava uma mancha
  amarela sobre o selo. Nada fica dentro do círculo de 12,5 m (testado por vértice em `tests/test_chamber_look.gd`);
  o arco da frente abre em pontilhado em volta do herói e de Morvath (`see_through` com `boss_pos`). Laboratório:
  `tools/chamber_lab.gd` (comando no topo; `--state=`, `--phase=`, `--hero`, `--boss`, `--showcase`, `--hall`,
  `--measure=`). Capturas: `docs/gallery/boss_arena/work/chamber_*.jpg`. Correções antes do teste do Daniel
  (`work/fix_*`): o par de sarcófagos na metade da borda perto da câmera (`NEAR_HALF`, o leste) recua 0,9 m com o nicho,
  baixo como na spec (`NEAR_SARC`) e com a pedra em pontilhado em volta do herói (`_see_through`), e as velas do arco da
  frente ficam encostadas nos balaústres e mais baixas (`CANDLE_FRONT_R`, `CANDLE_FRONT_MAX` 0,28): o herói na borda não
  parece mais em pé sobre a tampa nem sobre as velas; pilaretes da frente com furo menor e mais pedra (`PINNACLE_SEE`)
  para continuarem lá atrás dele; a espada erguida (sarcófagos, pilaretes, porta: `_sword`, `SWORD_*`; estandartes:
  `ArenaKit.BANNER_SWORD_WIDTH`) com lâmina larga afinando até a ponta, guarda curta e fina, punho fino e pomo, nunca cruz;
  a rachadura fecha a partir de `SealLook.HEAL_FROM` (veios de volta, 2,3 s) e some por inteiro antes da calma
  (`tests/test_seal_victory.gd`). Queimadura (M-1): o tique de fogo não pisca o corpo (`Horde.damage(..., flash = false)`),
  o contorno de elites e de Morvath não vai mais a branco 3,0 no pisca (`flash_color` no `crowd_outline.gdshader`; no
  manto aberto de Morvath o contorno de trás aparecia em manchas brancas) e a borda de fogo substitui a borda fria e a da
  coroa enquanto queima (`crowd.gdshader`); testes em `tests/test_burn_flash.gd`. Morvath: lanes
  recortadas na borda (`Boss._lane`), meias-luas se desfazem `BossDef.soul_overrun` (0,3 m) além da borda, investida só com
  `dash_min_free` (8 m) livres e parando na borda, invocações com a runa inteira no chão (`summon_ring`, `summon_clear`,
  `ritual_ring` no `BossDef`), fases 3 e 4 abertas do meio (`center_phases`), erupções pelo `FloorShape`. Avisos dele com
  assinatura (ART-001: miolo 0,35, aro 0,18, fio violeta de 2 px, runas espectrais por fora; `Ground.sign_boss`,
  `GroundLook.SIGN_*`) e a tempestade com a ordem de saída (`Ground.storm_rank`: pontos na raiz, aro em degraus); nenhum
  aviso pinta além da borda (global `floor_round` no `ground.gdshader` e no `ritual_rune.gdshader`). Global `boss_pos` para o
  `see_through` da cenografia. Câmera: alvo fixo `RoomLayout.cam_target` com `CamFrame.hold` (18%, no máximo `cam_reach` 3 m).
  Opções: `--no-boss`, `--hero-at=x,z`. O robô escolhe o vão (`Bot._escape` evita outros avisos) e conta "preso" (`RESULT`
  `bot.stuck`, `died_stuck`). Testes: `test_floor_shape.gd`, `test_boss_exits.gd` (saída de cada padrão, 12 x 12 posições),
  `test_boss_chamber.gd`, `test_chamber_look.gd`.
  Revisão de arte da câmara (`docs/gallery/boss_arena/ART_REVIEW.md`, P1 a P6, 2026-11-16): chão da câmara mais claro e um
  pouco mais quente só nela (`BossChamber.FLOOR_A`/`FLOOR_B`; o salão não muda); céu, névoa das agulhas e bordas de volta
  ao azul da pintura (`SKY`, `SPIRE_*`); anel distante de arcadas de 200° a 470° (`FAR_SPAN`) com uma janelinha quente em
  cada pilar (`FAR_WINDOW`, `FAR_WINDOW_GLASS`, `WINDOW_EVERY`). Tempestade: cada faixa só desenha a sua cunha em volta da
  raiz (metade do ângulo até cada vizinha, `GroundLook.storm_wedges`, `Ground.storm_wedge`, `wedge` no `ground.gdshader`),
  então nada soma; nada a menos de 1,2 m de Morvath (`GroundLook.STORM_CLEAR`), miolo mais fraco perto dele
  (`STORM_SOFT`, `STORM_ROOT_FILL`) e mais leve no todo (`STORM_FILL` 0,2; testes em `tests/test_storm_wedge.gd`).
  Erupções com o miolo vermelho da assinatura dentro do círculo (`danger*` no `ritual_rune.gdshader`, `Ground.RUNE_DANGER`).
  Colunas de dom sobre o chefe: também as que ficam entre ele e a câmera (`Skills.over_boss` com altura, yaw e pitch),
  fracas e com o miolo limitado ao teto da tela (`Skills.BEAM_CORE_CAP`, `cap` no `beam.gdshader`, ver GP-01); golpe forte no chefe pisca no
  máximo `Horde.BOSS_FLASH` 0,8, abaixo do `white_from` (antes o 1º quadro de um Ômega de geada deixava Morvath marfim).
- Colisão do cenário: pilares são círculos (`RoomLayout.pillars`); escadas, entulho e barris são caixas sólidas
  (`Arena.boxes`, pelo `solid` de `_place`). Sai-se da sala pisando no pé da escada (`Arena.exit_at`).
  `Arena.resolve` nunca deixa ninguém dentro de pedra (ciclo C12c, GP-03): espremido onde duas peças (ou peça e borda) ficam
  mais perto que o corpo é largo, vai para o lugar livre mais perto (`Arena.overlaps`, `_free_near`, anéis de 0,1 m até 3 m);
  invocações do Ancião por `Horde.raise_spot`. Testes em `test_arenas.gd`: o centro e 400 pontos dentro das peças de cada
  arena e variante, 200 invocações do Ancião e 200 de Morvath, e "cercado" (GP-04: 2 esqueletos de cada lado nos 4
  corredores mais estreitos de cada arena e variante, 16 de 16 esquivas saem mais de 2,5 m).
- Corpos sólidos como no Hades II (`StopsUnits` na heroína e nos inimigos; pedido do Daniel, 2026-11-15: "trombar nos
  inimigos e empurrar eles" era estranho): o paladino andando, correndo, levando golpe ou no avanço de um golpe para no
  contorno do inimigo (círculo de `EnemyDef.radius`) e desliza ao longo dele, sem empurrar ninguém
  (`Horde.stop_walker`, pelo hash espacial; lógica pura em `core/body_block.gd`, `BodyBlock`); se ficar espremido sem
  saída, fica onde estava (nunca preso por arredondamento). Só a esquiva atravessa (o BLINK do Hades). Os inimigos param
  no corpo dele (`Horde.keep_off_target`, depois da separação entre eles, para a multidão não empurrá-lo), menos a
  investida em voo (estado ATTACK) e a carga de Morvath; quem terminou dentro dele (esquiva, investida, invocação) sai
  devagar, a `BodyBlock.EASE` m/s, sem salto. `EnemyDef.blocks_body = false` (no `make_data.gd`) faz um tipo
  atravessável; hoje todos bloqueiam, Morvath (raio 1,4) e os guardiões (1,0 e 1,1) também. O robô contorna corpos
  (`Bot._steer`), foge do aviso para onde há chão (`Bot._escape`) e, preso, esquiva através deles. Testes em `tests/test_body_block.gd`.
  Com menos de 60% da vida o robô vai à fonte que ainda tem luz, também entre as lutas (`Bot.drink_at`, `DRINK_BELOW`; B-2).
- Barra de vida fina sobre a cabeça de cada inimigo, como no Hades II (`CrowdRenderer.add_bar`, `life_bar.gdshader`; o chefe usa a barra do topo). Ciclo 8 (salas de 4 a 20 inimigos): todos mostram a barra (`Horde.BARS_FOR_ALL` 24; acima disso, só nos testes de estresse, só os feridos, mais finas); a armadura ganha faixa amarela própria em cima da vida (a barra cresce para baixo, `BAR_ARMOR_HEIGHT`, sem cobrir a vida), elites e guardiões têm moldura de ouro velho e barra um pouco mais larga (`BAR_ELITE_*`, continua dizendo elite depois que a armadura quebra), rastro claro do que o golpe tirou (`BarTrails`), a barra mais perto da câmera desenhada por último (`sort_bars`). O topo da barra não sobe (os números de dano começam acima dela). A barra grande do topo é só de Morvath e dos guardiões (`Game.boss_enemy`); elites comuns não a ganham (no `--horde` ganham).
- **Inimigos de longe** (teste do Daniel, 2026-11-16: "querem ficar na distância máxima atirando e não chegar perto"; números
  dos atiradores do Érebo do Hades II, estudo do mesmo dia, fontes na pasta local `estudo`): mago, besteiro e sacerdote têm o
  comportamento `ARCHER` (`Horde._behave_ranged`): andam só até o fim do alcance, fogem quando o paladino chega a menos de
  `EnemyDef.keep_away` do alcance (nosso; contornando a parede, `Horde.flee_dir`; encurralados atiram de perto) e atiram de lá
  (`Horde.shoot`, campos `shot_*`). Mago = o "Mage" do Hades: 3,5 m/s, alcance 13,1 m (elite 16,25), mira 1 s, rajada de 3
  orbes a cada 0,17 s (elite 7, `shot_ticks`) que o empurram para trás a 5 m/s (`recoil`), orbes a 7 m/s por 20 m que viram
  atrás dele (20 graus/s só no primeiro 0,8 s do voo desde o C17, nosso: o arquivo não diz), depois espera atrás da coluna mais próxima, 3,1 m além dela
  (`cover_hug`, `Horde.cover_spot`), no máximo 6 atacando. Besteiro (vida do "Screamer", que no Hades não atira): virote
  rápido (16 m/s, 12 m) por uma linha marcada no chão onde a mira trava; do Hades, foge 8,75 m por 1,5 a 1,75 s depois de
  cada tiro (`retreat_far`, `retreat_time`) e no máximo 2 atiram ao mesmo tempo (`max_attackers`, `Horde.attackers`).
  Sacerdote = a "SiegeVine": parado, alcance 22,5 m, aviso 0,8 s (clipe `cast` reassado com 0,8 s), uma trepadeira de sombra
  rasteja pelo chão atrás do paladino (1,9 m/s, vira 90 graus/s caindo 15 por s, `shot_turn_decay`, 12 s, `shot_low`,
  `Projectiles.Shot.low`/`turn_decay`), depois 3,25 s (elite: 3 a cada 0,7 s, depois 2,25 s). O sacerdote ancião (guardião)
  solta um leque de 5 orbes entre as invocações. Ficaram de fora: a lentidão de 0,2 s do orbe e a trava de passo da trepadeira.
  Círculos mágicos no chão são só de Morvath (o `CASTER` e o cone ficaram sem uso). Erupções de Morvath com 4 m de raio (eram
  2) e aviso de 1,2 s (era 0,9) para ainda dar para sair andando (`BossRules.ERUPTION_NUDGE` 0,2). Testes em
  `tests/test_ranged_enemies.gd`.
- **Atordoamento pelo golpe (E1b, GF-12, D-42: o Hades II por inimigo)**: golpe que fere um inimigo comum sem armadura o
  atordoa (`Horde.flinch`): para de andar (`stun_t`, `Enemy.helpless`), a preparação ou o ataque em curso é cortado e não
  sai (`Horde.interrupt`: volta a `WALK`, o aviso no chão do ataque some na hora por `Ground.end_zone(Enemy.warning)`, o
  som `interrupt`), e mostra o golpe sofrido (o recuo do E1a, `HitRecoil`, continua). Duração por inimigo em
  `EnemyDef.stun_time` e `stun_heavy_time` (finalizador e Ômega; desde a E1c os do golpe da heroína do Hades, `OnHitStun`
  0,5 s e `OnHitStunHeavy` 1,1 s, para todo comum: `STUN` e `STUN_HEAVY` no `_enemies` do `make_data.gd`; eram 0,3 e 0,6).
  Preparação cortada se anuncia de novo inteira, mas só `Horde.REARM` 0,5 s depois do fim do atordoamento (`Enemy.rearm`,
  a recarga segura toda preparação e o som dela); ataque já solto cortado conta a recarga. Elites só depois que a armadura
  quebra (a barra absorve antes); a quebra da armadura também corta o ataque (`Game._on_armor_broken`, o
  `ArmorBreakStun`). Investida do Escudo em voo não é cortada (`stun_immune_attacking`, a carga do Brute do Hades; a
  preparação é). Guardiões e Morvath nunca (`stun_time` 0, o `ImmuneToStun`). Queimadura e zonas não atordoam (só golpe
  com direção e clarão). `RESULT` traz `flinches` e `interrupts`. Testes em `tests/test_flinch.gd`; sonda `GF-12`.
- **Inimigos comuns no molde do Hades II (E1c; auditoria `docs/gallery/e1c/enemies/AUDIT.md`, P1 a P9; testes em
  `tests/test_enemy_motion.gd`)**: o desenho segue o corpo: velocidade real no chão suavizada em `Horde.VEL_SMOOTH` 0,1 s
  (`Enemy.vel`, sem o empurrão; `Horde._drawn_motion`); abaixo de `WALK_FROM` 0,3 m/s toca `idle` (de `WALK_START` 0,4 para
  cima volta a andar), acima o andar no ritmo dessa velocidade (`Enemy.walk_phase`, `walk_rate`); com mais de
  `FACE_SPLIT` 60 graus entre o movimento e o rosto o corpo vira para onde anda a `TURN_RATE` 1200 graus/s e só volta a
  olhar a mira (`dir`) quando anda para ela ou prepara (`Enemy.face`, `yaw()`; atordoado não gira). O sacerdote parado fica
  em `idle`. Recuperação depois do golpe (o `PostAttackDuration`): `EnemyDef.recover_time` e o estado `Enemy.State.RECOVER`
  (`Horde._end_attack`), parado, com o clipe do golpe seguindo até o fim e segurando a última pose (`Enemy.blow_t`): esqueleto
  2,1 s (elite 1,5), corredor 1,35 (elite 0,5), Escudo 1,1 (também depois da investida, onde era um atordoamento de 0,8),
  besteiro 0,6 antes de fugir, mago 0,8, Cavaleiro 0,8 (o de antes); golpe na recuperação atordoa mas não corta nada. O
  golpe do esqueleto: `attack` assado de 0,3 a 1,2 s do `Sword_Attack`, tocado do começo quando o tipo tem clipe `windup`
  próprio (`CrowdRenderer.Kind.has_windup`, `Horde.ATTACK_PLAY` 1,4): a lâmina desce nos primeiros 0,14 s do bote. Mistura
  entre clipes para todos (a do chefe, `CrowdRenderer.add_kind(..., from_row, fade)`, por `Horde._fade`): `CLIP_FADE` 0,1 s
  (o chefe `BOSS_CLIP_FADE` 0,18 desde o T5b), também na queda; o alvo da mistura é a pose interpolada do clipe novo, não a
  mais perto (T5b P1-3: alfa negativo na cor da instância, `CrowdRenderer.fade_target`/`fade_pick`, lido no
  `crowd_pose.gdshaderinc`; antes o alvo saltava de pose em pose, até 0,55 m num quadro em Morvath); atordoado por golpe, todo corpo (pesado também) mostra o golpe sofrido
  esticado no atordoamento inteiro (`Enemy.stun_len`, `Kind.hit_time`), sem `idle` no meio. Bote do esqueleto para no
  contorno do herói (`keep_off_target` vale para o `RUNNER` em `ATTACK`; investidas de Escudo e Cavaleiro atravessam);
  no máximo 2 esqueletos (com as elites) preparam ou dão o bote juntos (`max_attackers` 2). Assado: esqueleto com o pé
  travado (`SOLDIER_RUN`, 149 passos por minuto; corria a 96; desde o T5 o `Jog_Fwd`, ver abaixo), ancião `ELDER_STRIDE` 0,9 (91 por
  minuto; era 67), besteiro com a besta baixa ao lado do quadril andando e parado (`CROSSBOW_LOW`, guarda do `Sword_Idle`;
  `idle` agora o `Idle`), subindo ao ombro só na mira (`aim`, `Pistol_Idle`) e no tiro.
- **T5, o corpo prepara o golpe (especificação em `docs/design/combat_cadence.md` 6; antes e depois em
  `docs/qa/t5_enemy_motion.md`; quadros em `docs/gallery/t5/motion/after/`; testes em `tests/test_enemy_windup.gd`)**: toda
  preparação em três tempos desenhada pelo `Horde.render` (`Horde.windup_arm`): assentar `EnemyDef.windup_settle` (0,12;
  besteiro 0,25, a besta subindo ao ombro), armar com o clipe próprio em curva suave até `1 - windup_hold` (0,3) e segurar
  a pose (ou o laço `<clipe>_hold`) com o `windup_shake` só aí. Clipes próprios no assado (UAL e KayKit, `tools/bake.gd`,
  opções novas `bend_in`/`bend_out` para o tronco enrolar no preparo e desenrolar no golpe, e `plant`): esqueleto a subida
  inteira da lâmina (`Sword_Attack` 0 a 0,35 s, `SOLDIER_COIL`), corredor o agachar do `Jump_Start` e o giro
  `2H_Melee_Attack_Spinning`, feiticeiro e ancião o cajado subindo (`cast` = `Spell_Simple_Enter`, `cast_hold`, `shot` por
  orbe recomeçado a cada tiro da rajada, `exit` na recuperação), ancião `summon` ao erguer os mortos, sacerdote elite `shot`
  por trepadeira, Escudo e Cavaleiro `brace`, `charge` e `recover` (`Idle_Shield_Break`), Morvath
  `dash_windup` (`Sword_Dash_RM` 0 a 0,12 s, `CHARGE_LEAN`) e `blades_windup` (`Sword_Regular_B` 0 a 0,2 s, `DRAW_BACK`),
  armados pelo `Boss` com o mesmo `windup_arm` (`Boss.WINDUP_*`, tremor `Enemy.shake`, só desenho). **Dano do corpo**: as
  investidas do Escudo, do Cavaleiro e de Morvath ferem no primeiro quadro em que o contorno do corpo, varrido de onde
  estava, toca o herói (`BodyBlock.swept_touch`, `Ground.strike` para Morvath, uma vez por investida); a faixa no chão é
  só desenho e enche até o quadro em que o corpo chegaria (`Boss.dash_contact`). O bote do esqueleto é um salto: o corpo
  percorre a distância anunciada (até o contorno do herói), a lâmina desce `strike_at` 0,1 s depois e fere de onde o corpo
  está, no arco de `strike_degrees` 120 e alcance `Horde.blade_reach` (raio + `strike_reach` 1,1 x tamanho); o corredor
  explode `strike_at` 0,1 s no giro; os avisos da multidão ganham um quadro (`+ dt`, o chão anda depois da multidão no
  mesmo passo) e os tempos `TICK_SLACK`, então o aviso enche no quadro do golpe. Foice de Morvath fere `Boss.SCYTHE_HIT`
  0,07 s na descida (`slash3:7`). **Recuperação viva**: o resto do golpe no ritmo do clipe, ou o clipe `recover`, depois
  a guarda com mistura de `RECOVER_FADE` 0,3 s, virando para o herói no fim a `RECOVER_TURN` 360 graus/s, e pelo menos
  `AFTER_RECOVER` 0,25 s até a próxima preparação. **Esqueleto que espera** (T5-10): anel a `RING_SHARE` 0,75 do alcance
  com folga, passo lateral para o mesmo lado por `RING_SIDE` 1,2 s, no máximo `RING_SPEED` 1 m/s, com os passos laterais
  e de costas próprios (`strafe_l`, `strafe_r`, `back`, `Horde.walk_side`) olhando o herói; histerese no rosto
  (`FACE_SPLIT` 70, `FACE_BACK` 45, `FACE_SPEED`), troca andar/parado só depois de `STAND_AFTER` 0,15 s ou `WALK_AFTER`
  0,1 s, linha reta até `WAY_FAR` 3 m, separação todo quadro com `SEPARATE` 0,25; desde a revisão (7.1) a troca do rosto
  espera `FACE_AFTER` 0,1 s e só volta à mira abaixo de `FACE_SPEED_BACK` 0,9 m/s. **Corrida** (T5-11, A-T5-2): `Jog_Fwd`
  com `SOLDIER_JOG` (`lock`, passada 0,74, `plant` 0,5, `stand` 0,15: o quadril 15 cm mais alto sobre as mesmas pegadas,
  joelho menos dobrado), 161 passos por minuto, pés no ar em 6 de 20 poses, cabeça a 100% da parada.
  **Revisão de arte (A-T5-1 a 4, `docs/gallery/t5/motion/after2/`)**: a investida do Escudo e do Cavaleiro corre com as
  pernas do `Sprint` e o tronco (e o braço do escudo do Cavaleiro) presos no fim do `brace` (`BRUTE_RUSH`, `KNIGHT_RUSH`,
  "guard" com segundo fixo, `RUSH_AT` 0,33 do `Shield_Dash_RM`): escudo 0,47 m ou mais à frente do peito e tronco 13 a
  33 graus em toda pose (`BakedModel.guard_pose`, partes com nome no assado em `BakedModel.parts`: `shield`, `sword`,
  `staff`; `tools/charge_probe.gd`); corredor prepara do `Jump_Start` 0,26 a 0,4 s (sem joelho erguido); cada orbe do
  feiticeiro é o cajado recuando pela subida e voltando (`Spell_Simple_Enter` 0,53 a 0,22 s, `there_and_back`, começa e
  termina na pose de segurar). **Fuga** (T5-20): o atirador guarda a direção de fuga `FLEE_HOLD` 0,4 s enquanto ela está
  livre (`Horde._flee`), foge com folga `FLEE_SLACK` 0,75 m além de onde começa e, correndo por conta própria, o corpo
  olha a velocidade suavizada por `RUN_FACE` 0,3 s (`Enemy.run_t`), nunca a direção crua do quadro.
  Medir: `tools/clip_motion.gd` (pico, pose armada e andar de cada clipe assado, cabeça no andar) e a sonda
  `tools/enemy_motion_probe.gd` com `tools/enemy_motion_probe.py` (tremor, golpe x corpo x aviso, pose parada).
- **T5b, a luta de Morvath sem "esqueletos pulando"** (diagnóstico e números antes e depois em `docs/qa/t5b_boss_fight.md`;
  dados em `docs/gallery/t5b/boss/after/`; testes em `tests/test_t5b_fight.gd` e `tests/test_boss_body.gd`): quem pulava era o
  feiticeiro (trote `Running_B` com meio pulo); ele e o besteiro correm no `Jog_Fwd` de pés travados (`MAGE_JOG`,
  `CROSSBOW_JOG` no `tools/bake.gd`). O `rise` comum fica no lugar (`in_place`) e, com cajado ou escudo redondo, termina na
  guarda (`STAFF_RISE`, `SHIELD_RISE`, opção `"settle"` do assado: os últimos 0,45 s vão para a primeira pose do clipe da
  guarda); a saída do `RISE` mistura em `Horde.RISE_FADE` 0,25 s, o corpo vira no máximo `RISEN_TURN` 480 graus/s por
  `RISEN_TIME` 0,3 s e espera `Horde.ARRIVE` 0,6 s antes da primeira preparação. Mistura de clipe para a pose interpolada do
  clipe novo (`CrowdRenderer.fade_target`). Morvath: o corpo desenhado (`Enemy.face`, girado pelo `Boss._turn_body`) vira no
  máximo `Boss.BODY_TURN` 720 graus/s para o rumo do ataque (que continua instantâneo, avisos iguais); conjurando
  (erupções, invocação, tempestade) e na recuperação ele segue o herói (`FOLLOW_RATE` 2). Sonda do desenho:
  `tools/drawn_probe.gd` (lê o que o `CrowdRenderer` pôs nos MultiMesh), análise em `docs/gallery/t5b/boss/{data,after/data}/*.py`.
- **PT-1 (2026-11-23, Daniel jogando): só golpe de área tem mancha no chão.** `EnemyDef.ground_warning` (dado, `make_data.gd`; hoje o corredor `runner`/`runner_big`/elite, o Varredor e o Canalizador) deixa a zona desenhada; sem ele (bote e espadas do esqueleto e do guarda, investida e golpe de perto do Cavaleiro, besteiro, lanceiro, feiticeiro, Ancião) `Horde._mark` chama `Ground.mute`: a zona existe igual (tempo, dano, o que o robô lê, `Zone.silent`) mas não é desenhada nem faz o estalo de trava. No lugar, o "!" (`EnemyFx.alert`, 2 traços marfim e ouro com contorno de tinta, por cima de tudo, maior em elite e pesado, um pulso curto ao acender) aparece nos `Feel.bang_lead` 0,35 s antes do golpe (`Horde.strike_in`: a zona muda mais próxima de `warning`, `warning2` e `fan`) e some no golpe ou em `Horde.interrupt`; um som (`lock_click`) por golpe, no máximo um a cada 0,12 s (`Horde.BANG_SOUND_GAP`). Morvath, perigos de sala, círculos, erupções, runas e invocações não mudam. Testes em `tests/test_pt1_warning.gd`.
- (Antes do PT-1) Todo ataque inimigo tem aviso no chão (`Ground.add_warning`, `add_line_warning`, `add_arc_warning`; o desenho fica em `GroundLook`, que os laboratórios usam sem o jogo). Ciclo 8, direção do golpe: na linha a ponta de longe é a clara, o preenchimento avança como uma divisa apontando para onde o golpe vai, com divisas fracas na parte ainda vazia; o arco ganhou borda nos lados retos. Laboratório: `tools/enemy_lab.gd ... --bars --warn=0.6`.

## C17 "Justiça e peso", frente de gameplay (backlog `docs/backlog.md` seção C17; evidências em `docs/gallery/c17/`)
- **Provação tardia (BUG-101, Q-08 a)**: a laje só aparece onde a maldição mais curta cabe nas lutas que restam antes de
  Morvath (`RunMap.fights_left`: salas até a loja menos a fonte e o altar ainda não vistos; `Trials.may_show(...,
  fights_left)`, `Trials.shortest_curse`) e nenhuma carta pede mais encontros que isso (`Trials.offers`). Teste em 500 mapas
  com o pior caminho (`test_trial.gd`).
- **Save atômico (BUG-102)**: `SaveFile` (`core/save_file.gd`): grava em `.tmp`, confere o JSON, copia o bom para `.bak` e
  renomeia; leitura cai no `.bak` e o arquivo ilegível vai para `.broken` (nunca é gravado por cima). `tests/test_save_file.gd`.
- **Loja na Câmara (BUG-103)**: artefato do `ui_lab --shop` com `--bot` (o robô já estava em Morvath quando a loja era
  remontada); o `ui_lab` recusa fora da loja; partida real sem placa de loja na câmara (`test_economy.gd`).
- **Morvath não desliza parado (BUG-104)**: sai do corpo do herói uma vez por quadro (`e.was_in_target`, a medida da
  multidão) e mostra o andar quando é movido sob um clipe parado (`Boss._drawn_walk`, `SLIDE_*`); `tools/boss_slide.py`
  sobre o `boss_probe`: 85 trechos em s1 a s5 para 0.
- **Orbe e corredor (QW-101, QW-102)**: o orbe do feiticeiro vira a 20 graus/s (era 40) e só nos primeiros
  `EnemyDef.shot_homing` 0,8 s do voo (depois reto); robô em 24 sementes: golpes do feiticeiro nas salas de 50% para 33%;
  corredor com `attack_windup` 1,0 s (era 0,7).
- **Sopro no quadro da lâmina (QW-103)**: `ComboNode.sound_at` (segundos depois do começo do golpe, divididos pela
  velocidade do combo) e `sound_press` (som no aperto): o giro toca `spin_gather` no aperto e o sopro aos 0,30 s, as
  estocadas aos 0,035 e 0,115 s (picos medidos das amostras, `SWISH_PEAK`, `THRUST_PEAK`); golpe cortado antes da lâmina
  não sopra (`Player._step_move_sound`).
- **Corpo que acende no "vai bater" (QW-104)**: no segurar do preparo (`windup_hold`) o corpo clareia morno até metade do
  clarão de um golpe, sob o `flash_cap` (`tell_hold`, `tell_light` no `crowd.gdshader`, `CrowdRenderer.TELL_LIGHT`).
  Falta a aprovação do art-director.
- **Sem metrônomo (QW-105)**: espera sorteada de 0 a `Horde.AFTER_RECOVER_JITTER` 0,5 s depois de cada recuperação;
  Cavaleiro e Escudo recuam `KNIGHT_BACK_OFF` e investem depois de `KNIGHT_SLAMS` 3 golpes de perto; voltam a andar só
  `MELEE_WALK_BAND` 0,8 m além de onde pararam (`Enemy.closing`); quem espera no anel ou recua olha o herói
  (`Enemy.facing_him`, lido no `_drawn_motion`).
- **Mira em fio (QW-107)**: a mira do besteiro e o bote do esqueleto são `Ground.add_aim_warning` (`GroundLook.aim`,
  `aim_px` no `ground.gdshaderinc`): fio de `AIM_PX` 6 px a `AIM_LIGHT` 0,5, ponta clara, a faixa enche até `AIM_FILL`
  0,22 só nos últimos 30%. Os outros avisos não mudaram. (PT-1: a mira em fio, o fio do leque e o bote deixaram de ser desenhados; a zona fica, muda, e o "!" avisa.)
- **Robô (QW-112)**: porta da fonte só abaixo de `Rooms.BOT_FOUNTAIN_BELOW` 0,8 da vida (`bot_door(..., life)`), e bebe
  abaixo do mesmo (`Bot.DRINK_BELOW`, era 0,6); régua das métricas sempre com `--ultimate=cleave`.
- **Vigia (BUG-110)**: `--watchdog` imprime `WATCH {...}` a cada `Watchdog.EVERY` 5 s reais (`frames`, `fps`, `mode`,
  `rate`, `time_scale`, `time`) e guarda as amostras no registro (`watch`). `tests/test_watchdog.gd`.
- **Instrumentação (DT-102)**: `RESULT` e registro com `windups` por tipo (`started`, `struck`, `cut`; `Horde.windup_report`),
  `shot_flight` por atirador (`hits`, `avg`, `max` do voo do tiro que acertou; `Projectiles.flight_report`),
  `omega_charges_started` (carga segurada além de `Player.CHARGE_SOUND_AT`) e `omega_charges_cancelled`.
- **Lâminas das Almas de perto (Q-09 b)**: a qualquer distância; com o herói a menos de `BossDef.blade_step_within` 4 m
  ele recua `blade_step` 2 m em `blade_step_time` 0,25 s e as faixas saem de onde ele termina. Fase 1 em 3 sementes:
  foice 91% para 62%, maior sequência igual 9 para 2 (`tools/boss_cadence.gd --cadence-log`).

## C19 "Variedade do combate e da descida", frente de gameplay (backlog `docs/backlog.md` Lote 2A; critérios em `docs/design/combat_cadence.md` 8.2; testes em `tests/test_c19.gd`)
- **Golpes por ataque como dado (Q-11)**: `EnemyDef.strikes` e `strike_gap` (`_enemies` do `make_data.gd`); um elite novo
  com dois golpes não pede código. **Esqueleto elite** (C19-1): 2 golpes a 0,2 s (o Guard elite do Hades); o fio do
  segundo nasce com a preparação (`Enemy.warning2`, `Ground.add_aim_warning`, fraco até os últimos 30%) a partir de onde
  o bote termina (`Enemy.lands_at`) e segue o herói até o fim da preparação (`Ground.point_line`); o segundo golpe vai
  para onde ele estava então (`Enemy.aim2`), `Horde.blow_at(e, k)`; atordoar depois do primeiro corta o segundo e o fio
  (`Horde.interrupt`, a morte também); recuperação 1,5 s (`recover_time`). **Corredor elite** (C19-2): explosão dupla a
  0,5 s; o segundo anel nasce no quadro da primeira explosão onde o corpo está e enche na segunda; giro em laço
  (`Horde.render`), `PULSE_AFTER` 0,3 s depois. O `windups` do `RESULT` ganhou `punished` (golpes que o tipo levou na
  recuperação, `_tally_windup(e, 3)`).
- **Ceifa Dupla de Morvath (Q-09 a, C19-3)**: ataque `reap` (`BossAttack`: fase 1 em diante, até 6 m, `near_bias` 2,2,
  `streak` 1, peso 3,5; números em `BossDef` grupo Double reap): meia-lua de 4,5 m e 150 graus, preparo 0,85 s e ativo
  0,4 (clipe `slash1`), pausa 0,35 e o segundo com preparo 0,5 e ativo 0,5 (`slash2`), recuperação 2,2 s; o aviso do
  segundo nasce no fim do ativo do primeiro (0,85 s para ler) na direção do herói; cada aviso cheio no quadro do golpe;
  pico do clipe no fim do preparo (`Boss.REAP_PEAK`, medido com `tools/clip_motion.gd`), corpo virando no `BODY_TURN`.
  Estado `Boss.State.REAP`, `_step_reap`, momentos `reap_warn`/`reap_strike`, "Derrotado por: Ceifa Dupla de Morvath"
  (`killer_reap`). `tools/boss_cadence.gd --cadence-log` imprime `CHOSE <ataque> phase=N dist=X`.
- **Ômega carregando no número do Hades (Q-12, C19-4)**: `HeroDef.charge_move_light` 0,03 (Swing5SelfSlowCharge) com o
  corpo travado (`charge_turn_light` 0, RotationMultiplier 1e-8) e `charge_move_heavy` 0,6 (inferência: o Ômega do
  especial do cajado não tem velocidade própria; WeaponStaffBoltInstantStop 0,6); `Player.charge_move_scale`. Carregando
  o do ataque ele segura a pose do golpe (nada de corrida a 0,2 m/s); a esquiva corta a carga no quadro do aperto sem
  gastar Magia; toda carga que acaba passa por `Player._end_charge`, que apaga o `charge_up` em `CHARGE_SOUND_FADE` 0,2 s
  (`Audio.fade_out(som, segundos)`, novo). Sonda: meta `C19-4` (0,066 m do aperto ao golpe, sem virar, corte em f20 sem
  Magia); 41 metas.
- **Ancião e feiticeiros mais justos (GP-1, GP-6, 2026-11-22)**: o leque do Ancião trava a mira nos últimos `Horde.FAN_LOCK` 0,35 s,
  abre 84 graus e tira 10; no máximo 3 feiticeiros preparando juntos; golpe de perto do guarda com 0,85 s de aviso.
- **Fio da mira do feiticeiro e do Ancião (Q-14 a, C19-5)**: na gramática do besteiro (`Ground.add_aim_warning`): o
  feiticeiro mostra um fio do começo da preparação ao primeiro orbe (um fio para a rajada), virando com a mira; o leque
  do Ancião um fio por orbe (5, `Horde.FAN_THREADS`; com só as bordas e o meio, sair de um fio punha o herói num orbe sem
  fio e o robô levou o dobro do Ancião), todos nascendo e enchendo juntos no quadro do tiro;
  cada fio do comprimento que o tiro voa antes da pedra (`arena.shot_reach`); `Enemy.fan`, `Horde._aim_fan`,
  `_point_fan`, `_end_fan` (golpe que corta, morte). A trepadeira do sacerdote segue a regra (b): o rito é o aviso. Os
  fios levam a etiqueta `Horde.FAN_TAG` e o robô desvia dos orbes, não dos fios (`Bot._danger`, `_threatened`: com a
  folga de 0,9 m dele as faixas de cinco fios se tocavam e ele ficava pulando de uma para outra dentro do leque).
- **Botão de usar (Q-13)**: recompensa, item da loja e porta só com a ação `interact` (E, A no controle) parado neles;
  encostar não compra nem sai (`Rooms._used`, `usable`, `use()` para clique e testes); o robô aperta quando
  `usable()`. A placa com a tecla é do ui-ux-designer.
- `tools/enemy_motion_probe.gd` lê também o `warning2` (o segundo golpe): aviso e dano a 0 ou 1 quadro.
- **Aceite medido (2026-11-20, HEAD `b903eee`)**: GUT 1282/1282 (`test_c19` 10/10, 75 asserções); sonda 41/41;
  `enemy_motion_probe` sementes 1 a 3 iguais à seção 8.1 (corredor da semente 2 na borda, Escudo +3 f conhecido) e com
  `--stress=4 --stress-ids=skeleton_elite,runner_elite`: os dois golpes de cada elite com aviso a -1 a +1 f do dano,
  segundo golpe do esqueleto a 0,99 a 1,78 m, pose parada até 0,22 s; `boss_cadence --cadence-log` sementes 1, 2, 3 e 5
  (reação 0,25, 5 Bênçãos): fase 1 perto, maior parte 43 / 43 / 50 / 43%, nunca 3 iguais, Ceifa com recuperação 2,21 s;
  24 descidas do robô (`smoke 900 --bot-reaction=0.25 --ultimate=cleave`): 20 vitórias, 24 em Morvath, `stuck` 0,
  nenhum golpe com `warn_s` abaixo de 0,97 s (Ancião 1,04), esqueleto elite 0 de dano antes e depois (o robô esquiva
  os botes). Ancião 45 para 126 de dano nas 24 (5 para 14 golpes): não é o fio (sem os fios, 126), é o Ômega a 3%
  (C19-4; com a carga a 100% volta a 45 nas mesmas 8 sementes); os golpes saem com o robô plantado em golpes comuns, aviso
  1,04 s ou mais, então fica para o balance-designer e o teste com gente. Vídeos a 1/4 da velocidade (GPU, 1280 x 720,
  semente 5) em `docs/gallery/c19/` (`skeleton_elite_*`, `runner_elite_*`, `reap_*`).
- **Depois da aprovação do C19 (combat_cadence.md 8.3)**: (a) o robô não começa o Ômega do ataque com um atirador
  (feiticeiro, besteiro, sacerdote, Ancião) preparando a menos de `Bot.SHOT_NEAR` 12 m (`Bot.shot_coming`: toca em vez
  de segurar); Ancião 126 para 81 de dano nas 24 descidas (meta 68: fica para o equilíbrio, `balance.md`). (b) O
  corredor (comum e elite) esperando a recarga encostado no herói usa a folga `Horde.MELEE_WALK_BAND` 0,8 m
  (`Enemy.closing`, como Cavaleiro e Escudo): idas e voltas por segundo 1,5 a 4,6 para 0,2 a 0,63. (c) O disco da
  primeira explosão do corredor elite é um aro fino sem preenchimento que some em `Ground.LAND_QUICK` 0,1 s
  (`Zone.land_quick`): o aro do segundo anel fica 0,4 s à vista antes da segunda explosão. BUG-108: `Game.unhook` no
  `_exit_tree` e no `Boss` derrotado solta os sinais de objetos `RefCounted` (os lambdas seguravam `Boss`, `Enemy`,
  `BossDirector`). QW-104 P2: `EnemyDef.tell_time` 0,5 s (`CrowdRenderer.tell_share`), falta o aceite do
  combat-feel-director. Q-15 medido em `docs/qa/q15_economy.md` (ouro na loja mediana 81,5, Elo 24%, Salmo 5,6%).

## Passada de VFX, Lote 1, parte do gameplay (spec `docs/art/vfx_pass_spec.md` 4, 5.3, 5.4 e 6; testes em `tests/test_vfx_lote1.gd`)
- **Luz sobre o que se pega** (o pedido do Daniel; a peça é o `RewardShaft` do technical-artist,
  `scripts/game/reward_shaft.gd`): a sala vencida não sobe mais coluna (`Rooms._room_cleared`); a recompensa ganha o facho
  (`RewardShaft.make(rooms, ponto, RewardShaft.tint_of(recompensa, família do anjo da porta))`, `appear()` espera o fim da
  câmera lenta) e pegar chama `take()`; a família vem do anjo que a porta mostrou (`Rooms._angel_family`; encontro de dois
  anjos e guardião, marfim). Loja: cada item com o facho na hora (`appear(0, true)`), força `Rooms.shop_light`
  (`RewardShaft.SHOP_CAN` 0,75 com ouro, `SHOP_CANNOT` 0,3 sem), seguida pelo setter do `Rooms.gold`; comprar levanta.
  Fonte: `RewardShaft.FOUNTAIN` 0,8 enquanto há água (`Game.spawn_fountain`, filho do nó da fonte), `take()` junto do
  `fountain_spent`. Elite surgindo sem coluna (`Rooms._spawn`, `Game._spawn_elite`); a peça no chão dela (V-15/V-18) é do
  technical-artist. Bênção e Salmo tomados sem coluna (seção 6: a marca da família no chão,
  `Fx.family_mark`; Elo um anel). Ficaram com coluna: dom que cai (`Skills`, Lote 2) e a morte de elite no `--horde`. `--no-shafts` desliga (a peça).
- **Paleta** (seção 4): `Combat.FIRE` âmbar (1,0; 0,6; 0,16), matiz 31; `Combat.LIGHT` ouro pálido (1,0; 0,92; 0,7);
  `Combat.VIGIL` sálvia (0,66; 0,78; 0,46), matiz 82, e `Combat.color_of` dá a Vigília separada da Luz. **`Boon.FAMILY_COLOR`
  mudou (para o ui-ux-designer: cartas, HUD e medalhões leem dali; conferir as telas)**: Chama e Luz como acima, Geada
  igual, Vigília sálvia (era verde 0,45 / 0,95 / 0,6, perto da Emeth), Elo ouro velho (0,78; 0,62; 0,34), o do
  `PsalmDef.color` (era violeta, o de Morvath). `Rooms.PSALM_COLOR` = esse ouro velho (era marfim-lilás); romã e coração
  saem do vermelho do perigo (`Rooms._reward_color`: matiz 352 sat 0,5 e 340 sat 0,45). Magia dos mortos (V-11, `_enemies` do
  `make_data.gd`): `DEAD_CRIMSON` (1,4; 0,16; 0,3) no corredor e no besteiro, `DEAD_MAGENTA` (1,2; 0,18; 0,64), matiz 333 no material para dar 320 a 330 na tela (P2 da revisão de arte), no
  feiticeiro, no sacerdote e no Ancião (o violeta frio do feiticeiro, do Daniel de 2026-11-14, saiu com a spec); violeta só
  de Morvath. Nenhum tempo, dano nem alcance mudou.


## Golpes de Morvath que perseguem (Daniel, 2026-11-21)
"Os golpes do boss tem q ser igual ao do miniboss que na hora q está carregando vai perseguindo o herói até soltar o
golpe." A Foice, a Ceifa Dupla (os dois arcos), as Lâminas das Almas e a Investida giram para o herói durante a
preparação (`Boss._follow`, `BossRules.follow_aim`): no máximo `Boss.FOLLOW_TURN` (160) graus por segundo, a Foice e a
Ceifa ainda avançam a `FOLLOW_CREEP` (0,45) do passo dele, e tudo trava `FOLLOW_LOCK` (0,3 s) antes de cair: a
esquiva é de tempo, não de distância. Os avisos giram juntos (`Ground.point_zone`, linhas e meias-luas); as lanes das
Lâminas e da Investida são recortadas na borda a cada giro. Testes em `tests/test_boss_refine.gd` (fim).


## Regra do atordoamento pelo golpe (experimento, Daniel, 2026-11-21)
"Bater e meio que dar stun nos inimigos" deixava o jogo fácil; "não pode interromper ninguém". `StunRule`
(`core/stun_rule.gd`): `NONE` (padrão: nenhum golpe do herói atordoa nem corta ataque), `STRONG` (só `finisher` e Ômega) e
`ALL` (como era, GF-12). **F8** troca na luta (ação `stun_toggle`, aviso na tela), `--stun=all|strong|none` escolhe na
linha de comando; os testes rodam em `ALL` (gancho `pre_run`), a regra em `test_stun_rule`. Seguem valendo: quebra de
armadura, ultimate, gelo e atordoamento de Bênção. Em `NONE`, Fúria Plena e o Refinar Peso perdem o efeito (pendente se ficar).
Medido (12 sementes, novato, robô 0,25): `all` 11 chegam ao guardião, 5 morrem nele, 1 vence; `none` 7 chegam, 4 morrem, 0 vence
(8 morrem até a sala 4). Golpes que saem: 55% (`all`) e 80% (`none`) dos preparados.
Essa medida é com 18 de vida. Com **30 de vida** e `none` (2026-11-21, 12 sementes): novato 10 de 12 chegam ao guardião, 5 morrem
nele, 0 vence; evoluído (4 Dons, Forja 2, conta 6) 12 chegam, 1 morre nele, 5 vencem. Erro de uns 14 pontos.


## Lote C1: combate novo (Daniel, 2026-11-22: "não dá para ficar só apertando o botão de atacar"; testes em `tests/test_combat_c1.gd`)
- **Herói fraco**: combo 15/15/20 (desde o SW-C2, 2026-11-25, 15/15/30; Quarto Corte 15), Ômega do ataque 100, ultimates a 60% (Corte do Juízo 180/120 na Maestria 3, Voragem
  5 e 72), dano fixo das Bênçãos x 0,6 (`FLAT`). Onda 35, Investida 35 e Brado 15 ficam.
- **Botões**: a onda (`heavy`) tira 50% a mais da blindagem (`Combat.ARMOR_SPECIAL`); o Brado absorve um golpe de 4 ou mais
  (`ComboNode.buff_ward`, `GiftState.take_ward`, `Player.WARD_MIN`).
- **Gelo** na regra do F8 `NONE`: só finalização, cast, Ômega e ultimate congelam (1 s no máximo, `FREEZE_MAX`); o resto atrasa. Em
  Morvath, gelo e empurrão viram dano (`RESIST_FREEZE` 0,25, `RESIST_PUSH` 0,3; empurrão também em blindado) e a Fraqueza vale metade.
- **Inimigos que pedem resposta** (tudo em `EnemyDef`): esqueleto com mira rastreada (`aim_lock` 0,3, até 3 preparando, nunca dois
  no mesmo `windup_gap` 0,35), descanso 1,2; corredor explode ao morrer (`death_burst` 0,7); besteiro com segunda flecha que mira
  de novo (`shot_relock` 0,4); Escudo barra 70% do ataque de frente em 75 graus (`front_block`), a onda abre por `front_open` 4 s e a
  Investida, o Ômega e a ultimate passam; sacerdote blinda 3 vizinhos (40, a cada 5 s, `ward_*`), e a blindagem some com ele.
- **Cavaleiro**: investida rastreada que trava 0,3 s antes (não rastreia a menos de `CHARGE_FOLLOW_FROM` 5 m) e invoca 3 esqueletos
  (6 no máximo) na abertura e depois de cada par de investidas.
- **Medido** (12 sementes por linha, robô 0,25, 14 salas; novato e evoluído): todas as teclas 0 e 5 chegam a Morvath, 0 e 2 vencem; só
  mouse (`--bot-mouse`) 0 e 3 chegam, 0 vencem. Novato no primeiro minichefe: 2 de 12 morrem com todas as teclas, 7 de 11 só de
  mouse. Ataque 50 a 52% do dano (a meta do CB era 45% ou menos; não bateu). Erro de uns 14 pontos.

## As 42 Bênçãos, base (C4, 2026-11-22; Sarael e Nivael prontos, os outros cinco anjos no C6)
- **Seis botões, uma Bênção por botão**: `Boon.Slot` = NONE, ATTACK, SPECIAL, CAST, DASH (a esquiva, Espaço), RUSH (a Investida, E),
  ULT (a ultimate, Shift). `Boon.button()` lê o encaixe e é a fonte da lista de botões e do HUD; pegar outra do mesmo botão troca
  (`BoonState.replaced_by`). `Boon.acts_alone()`: sem botão e com habilidade `AUTO` (só as dos cinco anjos ainda não feitos).
- **Habilidade nasce do botão** (`SkillDef.trigger`, `duration`, `gap`): `Skills.trigger(...)` é chamado por `Game` quando o golpe do
  botão acerta (`Skills.trigger_of(node)` pelas etiquetas: Investida `dash`, onda `heavy`, Brado `shout`, Ômega, giro `finisher`), na
  esquiva e quando a ultimate cai. Órbita gira `duration` s; a habilidade só dispara de novo depois de `gap` s; sem alvo perto, não gasta o `gap`.
- **Reserva** (`Boon.reserve`): fora do sorteio (`BoonState.offerable`), arquivo e Compêndio mantidos, `take()` ainda funciona (testes,
  saves antigos). Chama e Geada: brasas, lamina_ardente, omega_brasa, chuva_brasas, estilhaco, peso_inverno, geada_final, omega_geada
  (`RESERVE` em `make_data.gd`). Elo sem Bênção-base fora da reserva também não é oferecido.
- **Shift** (`Slot.ULT`) só entra no sorteio com `BoonState.ult_open` (Game: ultimate equipada). O robô sem `--ultimate` não vê essas.
- **Três cartas sempre**: `Encounter.eligible` pede `Encounter.CARDS` (3) de oferta (`supply`: não tidas, trocas, Elos e níveis a
  mais de tidas); `Encounter.cards` completa com cartas `grow` (um nível a mais de uma tida da família).
- **Lendária** 1% no sorteio comum e 3% no guardião (`Boon.RARITY_CHANCE*`, `catacombs.tres`).
- **Novo no golpe**: `detonate_dmg` (Brado de Sarael: quem arde leva o dano de uma vez e apaga), `shatter_pct` por etiqueta (a onda
  de Nivael estilhaça; a onda conta como golpe), `freeze_time` na etiqueta `spin` (só o giro congela). Habilidade com `trigger` ULT leva a
  etiqueta `ultimate` (congela como o golpe da ultimate); `DealtBy` lê a Bênção antes de `ultimate`.


## Lote C5: Trinca e Varredor, a maldição de Morvath (CB-7; testes em `tests/test_c5.gd`)
- **Trinca** (`trinca`, elite com 4 figuras): `group` 3 corpos por cabeça de onda (`Horde.spawn_group`, `Enemy.group_id`), `rise_time` 3,5 s.
  Quem cai vira monte (`Enemy.State.DOWN`, `invulnerable`, pose final de `death`) se outra do grupo está de pé (`_standing_of`); o monte se
  ergue (`State.RISE`) com a vida cheia; o último de pé que cai leva os montes junto (`_end_group`), cada um emite `killed`. Conta como 3 dos
  vivos (`EncounterGen.bodies`; `Rooms` só solta uma cabeça com `room_for(group)`). Anda nos cantos de um triângulo em volta do herói
  (`TrioRules`, gira em 18 s) e bate **uma por vez** (`max_attackers` 1), com o bote do esqueleto (`_behave_runner`, `aim_lock`).
- **Varredor** (`varredor`, comportamento `SWEEP`, `Horde._behave_sweep`; regras puras em `SweepRules`): fincado, 0,9 s de preparo (faixa
  de 5,5 x 1,1 m onde começa, 70 graus atrás da linha do herói, e um fio 32 graus adiante mostrando o sentido), trava nos últimos 0,3 s
  (`lock_line`), varre 200 graus em 1,6 s; fere uma vez por varredura (8) só na faixa e a mais de 1,6 m dele (`sweep_clear`); descansa 1,4 s
  (`recover_time`, sem o atraso de `AFTER_RECOVER`). `per_room` 1 (`EncounterGen.limit_per_room`), papel `sweep` banido na sala da ponte
  (corrente RP-11). Congelado ou morto, a faixa some com ele (`interrupt`, `Ground.end_zone`).
- **Salas**: papéis `swarm` e `sweep` nos pools a partir de 0,46 do progresso (sala 7 em diante). `stand_in` só troca por corpo único.
- **Robô** (`bot.gd`): vai até 1,1 m do Varredor (dentro do bolsão) e não recua dali; na faixa dele sai pelo comprimento (para dentro ou
  para fora da ponta, nunca atravessando); ignora monte (`invulnerable`).
- **Morvath**: maldição 55 graus/s por 0,9 s (era 75 e 1,4; passo 6 do plano revisado).
- Modelos: `trio` (esqueleto sem cutelo, curvado) e `sweeper` (besteiro sem besta, haste e lâmina do cutelo), `tools/bake.gd`, zero créditos. Provisórios.
- Sinais (só desenho, `scripts/game/c5_marks.gd`, `C5Marks`, lê `horde.list` por quadro; testes `tests/test_c5_signals.gd`): anel fino marfim que fecha de 1,5 a 0,35 m no monte em `rise_time` (some sem o grupo de pé); 4 chevrons vermelhos de aviso sobre a faixa do Varredor no preparo, apontando o sentido da varredura (`side`), dentro da faixa (sem área nova).
- Silhueta própria (2026-11-23): `CrowdRenderer.BUILD` (Trinca baixa e larga, Varredor alto e magro), sem assado novo (68,55 de 70 MB). Pendente: aprovação do `art-director` lado a lado na GPU.

## C1b, Frente 1: a Quebra e o preço do erro (2026-11-22; `docs/design/combate_c1b.md`; testes em `tests/test_c1b_break.gd`)
- **Quebra (poise)**: `EnemyDef.poise` (100 nos quatro comuns: esqueleto, corredor, feiticeiro, besteiro; 0 em elites, guardiões, Trinca, Escudo, Sacerdote, Varredor e chefes), `poise_stun` 1,2 s, `poise_vuln` +40% de dano enquanto quebrado, `poise_idle` 4 s sem golpe que tire poise e ele enche. Lógica pura em `scripts/core/poise.gd` (`share`, `wear`, `settle`, `takes`); o estado e a quebra em `Horde._wear_poise` (chamada em `damage()` depois do dano em vida) e `_poise_timers`.
- **Pesos por botão**: `Feel.poise_weights` (gerado por `POISE_WEIGHTS` em `tools/make_data.gd`), chave = fonte do `DealtBy` (`horde.dealing`): ataque 0,15, especial 0,6, Investida 0,5, Ômegas e `cast_omega` 0,7, Brado 0,6, ultimate 1,0. Fonte sem peso (queimadura, brasas, eco, Salmo, estilhaço, Dons que agem sozinhos, zona de Magia) não tira nada.
- **Regras**: com blindagem (inclusive a do Sacerdote) o golpe vai na barra amarela e não tira poise; congelado, já atordoado, no chão ou em monte, morto ou invulnerável: não acumula. A regra F8 (`StunRule`) é sobre o golpe comum e não toca na Quebra, que é como quebrar blindagem (corta o ataque, `interrupt`).
- **Leitura**: medidor claro de 60% do tamanho sob a barra de vida (`CrowdRenderer.add_poise_bar`, `life_bar.gdshader` com +8 em `b`), só depois do primeiro golpe que tira poise; na quebra, estilhaços marfim (`EnemyFx.POISE_BREAK`), o som `stagger` e a palavra "Quebrou!" (`word_poise`).
- **Preço do erro**: invulnerabilidade do herói após dano 1,3 para 0,7 s; aviso do esqueleto 0,9 para 0,75 s e do corredor 1,0 para 0,85 s (elites mantêm os de antes); vida do comum x1,6 (esqueleto 95, corredor 70, feiticeiro 115, besteiro 180; elites mantêm).
- **Ajuste de números (2026-11-23, `docs/design/balance.md`)**: Investida 60, Brado 35, onda 55, lance 150 (textos do Como Jogar atualizados). Ataque 44% do dano do evoluído (era 51%), só mouse chega a Morvath em 2 de 24 contra 7 de 24, evoluído vence 1 de 12 (meta 20 a 40%), salas comuns até 65 a 72 s. Falta código: kit_c1c item 1 (botões que carregam batendo) e, se quiser, peso 0,16.
- **RESULT**: `breaks` (quebras por fonte, para medir o uso dos botões).
- **Os botões se alimentam (C1c item 1, 2026-11-23, `docs/design/kit_c1c.md`)**: Magia +0,5 por golpe do ataque que acerta (uma vez por golpe, não por alvo: `ComboNode.magick_per_hit` no cut1, cut2, cut3 e no Quarto Corte; a Investida segue com 2 por alvo) e +3 por Quebra do ataque, onda, Investida e Ômegas (`HeroDef.magick_on_break`; `Horde.poise_broken(e, fonte)`; nunca a do Brado nem da ultimate). Recarga do Brado: -0,3 s por acerto de ataque e -1,5 s por Quebra (`cd_refund_hit`, `cd_refund_break`), nunca abaixo de `cd_floor` 8 s no total (`ComboRunner.cooldown_refund`, `Player.refund_shout`); o Brado não devolve Brado. Tetos contra laço: ganho de Magia por acerto e Quebra no máximo `gain_cap` 3 por `gain_window` 1 s, e uma onda devolve no máximo `wave_refund_cap` 8. Regra pura em `scripts/core/kit_feed.gd` (`KitFeed`, ligado em `HeroGifts`); `RESULT.kit` traz `magick_hit`, `magick_break`, `refund_s`, `waves`, `shouts`. Testes: `tests/test_kit_c1c.gd`. Ainda não feito do C1c: o ajuste de Lâmina Faminta e o Brado `buff_ward` a cada 12 s (item 5).

## C1e: a esquiva como defesa principal (2026-11-22; `tests/test_dodge_c1e.gd`)
- **Números** (só em `tools/make_data.gd`): esquiva de 0,2 s e 5,6 m como antes; proteção `Feel.dodge_iframes` = `dodge_time` (0,2 s, o trajeto inteiro, antes 0,3 s com 0,1 s de cauda); recarga `HeroDef.dodge_recharge` 0,8 s (era 1,1); 1 carga de base, a segunda vem da Bênção Passos (`dodge_charges` +1 em `Boons`, lido em `game.gd`) ou de Dons.
- **Esquiva no último instante**: golpe ou projétil que chega ao herói até `Feel.close_window` (0,15 s) depois do começo da esquiva (`DodgeClose.counts`, `scripts/core/dodge_close.gd`) dá `Player.dodge_close`; `Game._on_dodge_close` toca câmera lenta curta (`close_fraction` 0,4 por `close_slow` 0,25 s, `Fx.slow_mo`, só com a opção de câmera lenta ligada), anel esmeralda e o som `ward`. No máximo uma a cada `close_cooldown` (2 s). Não atordoa ninguém (regra F8). `Game.dodge_closes` conta na partida.
- **Cancelamento**: a esquiva corta qualquer golpe, janela de recuperação e `move_hold` (`ComboRunner.can_cancel` sempre verdadeiro; o Brado, Ômegas e cargas também; desde o SW-C1 o giro também, ver abaixo). Aperto sem carga ou durante estágio, rolagem/gesto fica guardado `Player.DODGE_BUFFER` (0,15 s) e sai quando puder.
- **Leitura**: o HUD já mostra as cargas e a recarga (`Hud._dash_wait`, lê `hero.dodge_recharge`); nada novo.


## Plano SWORN, fase 1 (SW-C1, C2, C3, C6; 2026-11-25; `tests/test_sworn_c.gd`, `docs/design/combat_cadence.md` 13)
- **Cancelamento em dado (SW-C1)**: `ComboNode.cancel_dodge_from` (0: a esquiva corta desde o quadro 0, inclusive o giro, que antes segurava a preparação, G-2/CF2-08 desfeito), `cancel_special_from` (0: especial D, Brado Q e Investida E cortam a preparação e a recuperação de qualquer golpe; golpe cortado antes do impacto não acerta; nunca corta a si mesmo nem corta com o recarregar em curso) e `cancel_light_from` (-1: o próximo leve sai quando a recuperação acaba, como antes; um número antes disso adianta a corrente). Tempos em segundos desde o aperto, no ritmo do golpe (`ComboRunner._since`, `_cancel_into`). `can_cancel()` lê o dado.
- **Giro vale o dobro e é o único que empurra (SW-C2)**: 15/15/30; empurrão 0,7 nos golpes 1 e 2 (cerca de 0,1 m, `COMBO_PUSH`), o giro mantém 16.
- **Pausa no impacto por tipo (SW-C3)**: golpe do ataque (tag `light`, fora Ômega e Investida) para o mundo por `Combat.PAUSE_*`: 120 ms em 1 corpo, 90 em 2, 60 em 3 ou mais; o giro 160, 110 e 60. 20 ms ficam em velocidade cheia e o resto a `hit_slow_scale` (6%); morte soma 40 ms. Os outros golpes (Brado, Investida, Ômegas) seguem com `hit_stop_ms`.
- **Esquiva (SW-C6)**: 0,2 s, 5,6 m (SWORN 2,5 m), protegido o trajeto inteiro, 1 carga, recarga 0,8 s: igual ou melhor, nada mudou.


## C1e, lote A: Gritador, Coveiro e modificadores (`docs/design/inimigos_c1e.md`; testes em `tests/test_c1e_a.gd`)
- **Comportamento novo, um só: `EnemyDef.Behavior.SUPPORT`** (`Horde._behave_support`, `_call`; regras puras em `SupportRules`, `scripts/core/support_rules.gd`).
  Nunca fere. Fica a `attack_range` do herói, foge dele a menos de `retreat_far` (`flee_speed`), e quando o `attack_cooldown` acaba para
  `attack_windup` (0,9 s, anim `cast`) e chama; golpe cortado (Quebra, `interrupt`) nunca chama. Só chama se há o que fazer (um aliado no
  alcance; ou vaga e ponto livre para o morto). Poise 100, `per_room` 1, sem versão elite.
- **Gritador** (`gritador`, assado próprio `herald` (corpo do feiticeiro ereto, sem cajado, estandarte alto de pano âmbar na mão esquerda) em tinta azul-aço (0,52 0,76 1,0), 1,15; vida 120, anda 3 m/s, foge a menos de 2 m): grito a cada 9 s com
  aviso de anel fino âmbar que fecha em 0,9 s (`C1eMarks`); os outros em 8 m (menos Morvath e quem ergue) andam e voltam de seus golpes
  1,3 vez mais rápido por 8 s (`Enemy.haste_t`, `Horde._speed`, `_pace`: só andar e o `cooldown`; o aviso nunca encurta, fica 0,75 s ou mais)
  e curam 10% da vida, uma vez por grito. Papel `rally`. Da sala 6 (a 5 é o guardião).
- **Coveiro** (`coveiro`, assado próprio `gravedigger` (corpo do sacerdote curvado, pá inclinada na direita e lanterna com brasa na esquerda) em tinta terra (0,86 0,66 0,46), 1,0; vida 90, 3,2 m/s, 5,2 m/s ao fugir a menos de 7 m): a cada 7 s ergue 2
  `skeleton_raised` (vida 40, golpe 4, sem papel: nunca é sorteado) em pontos a 3 m ou mais do herói (`SupportRules.spots`, marcados
  com um X de duas barras finas durante o aviso), no máximo 4 dele de pé (`raise_max`, `Enemy.raised`), sempre sob o teto de 20
  (`room_for`). Papel `grave`, `never_with` papel `swarm` (nunca com a Trinca). Da sala 8.
- **Dado novo em `EnemyDef`**: `raise_kind`, `raise_far`, `shout_*`, `flee_speed`, `never_with`; o Cavaleiro e o Ancião seguem
  levantando `skeleton` (padrão de `raise_kind`).
- **Modificadores** (`ModDef`, `data/mods/*.tres` por `_mods` do `make_data`; `StageDef.mods`, `mod_from_depth` 8, `mod_chance` 0,10,
  `mod_step` 0,05 por sala, `mod_per_room` 2): `EncounterGen.assign_mods` sorteia por cabeça comum e simples (nunca elite, maior, Trinca,
  `per_room` nem SUPPORT; nunca em sala com perigo), no máximo 1 por inimigo e 2 por sala (`Fight.mods`: tipo -> modificadores dos primeiros
  que nascem; `Rooms._take_mod`). Anel fino no pé da cor do modificador (`C1eMarks`; sem disco). **Furioso** (laranja): o `cooldown` corre
  1,25 vez (aviso intacto). **Detonante** (âmbar): morto, 4 lanças curtas em cruz (3 m, 0,7 de largura, 8 de dano, aviso 0,7 s,
  `Horde._cross_burst`, `Ground.add_line_warning`). **Escoltado** (branco): nasce com 2 `skeleton_raised` (`Horde.spawn`, sob o teto).
  Regenerante e Eco: lote C, abaixo.
- Livro: `CodexScreen.ENEMIES` ganhou os dois; `RoleMark` desenha `rally` (corneta) e `grave` (monte com pá). Textos: `enemy_gritador`, `enemy_coveiro`,
  `enemy_skeleton_raised`, `mod_*`, `codex_role_rally`, `codex_role_grave`. O RESULT ganha `rooms[].seen` (cabeças por tipo) e `mods`.
- Não feitos do doc, por serem desenho ou pouco valor agora: o empurrão de 4 de dano do Gritador cercado (ele só foge), os fios âmbar do
  Gritador até cada aliado, o X pontilhado (são duas barras cheias finas) (os modelos ganharam assado próprio depois: ver acima; o anel e o X seguem em âmbar e musgo, `magic_color`).

## C1e, lote B: Saltador e Lançador (`docs/design/inimigos_c1e.md`; testes em `tests/test_c1e_b.gd`)
- **2026-11-23 (Daniel)**: o Saltador e o escudo do Cavaleiro não rastreiam mais: o ponto é onde o herói estava quando o salto começou ou o escudo saiu da mão, marcado por um círculo vermelho no chão (`Ground.add_warning` sem dano, como as erupções de Morvath; `leap_half` 1,8 e `throw_half` 2,4 agora são raios; `LeapRules.in_area` é um círculo; os cantos em L do `C1eMarks` saíram). A onda do escudo continua.
- **Saltador** (`saltador`, `EnemyDef.Behavior.LEAP`, `Horde._behave_leap`; regras puras em `LeapRules`, `scripts/core/leap_rules.gd`): modelo do
  corredor em tinta ferrugem (1,1; sem bake novo), vida 140, anda 4,2, fica a 4 a 7 m (`LEAP_KEEP`) e, pronto, marca o pouso: **4 cantos em L** de
  laranja fino (`C1eMarks`, quadrado de 3 m, abrem 1,9 vezes e fecham no quadrado em 0,8 s), o ponto segue o herói e trava nos últimos 0,3 s
  (`aim_lock`, `LeapRules.follows`); sobe e voa 0,5 s (`leap_time`, `LeapRules.pos_at`/`height_at`, `Enemy.leap_y`/`leap_from`; no ar
  `invulnerable`: nada o atinge) e cai no ponto marcado: 12 de dano a quem está no quadrado (`LeapRules.in_area`, com a margem do corpo do herói),
  poeira, e repousa 1,0 s abaixado (`recover_time`). Aviso total 1,3 s (0,8 de cantos e 0,5 de voo); só o preparo é cortável: golpe de Quebra
  nele cancela o salto. `max_attackers` 1, `windup_gap` 0,5, `per_room` 2, papel `leap`, poise 100.
- **Lançador** (`lancador`, `ARCHER` com `shot_return`; regras puras em `ThrowRules`): esqueleto em tinta cinza-azulada (1,2), vida 150,
  anda 3,6, mantém 6 a 8 m, após lançar recua. Linha pontilhada de 0,8 s da mão até 11 m (travada), depois o machado (bola de aço, provisório:
  falta peça de arte) a 9 m/s, 9 de dano, vai até 11 m (ou até 0,5 m antes de pedra, `ThrowRules.out_range`), vira e volta pela mesma linha até a mão
  (`Shot.back_at`, `Shot.origin`, `Projectiles._returning`); fere uma vez na ida e uma na volta (não some ao acertar na ida); 0,4 s antes de virar
  o fio fino (0,3 m) da volta aparece (`ThrowRules.RETURN_WARN`). Ataque corpo a corpo não o corta. Papel `throw`, `per_room` 2, `max_attackers` 1.
- **Robô**: `Bot.leap_escape` (sai do quadrado de pouso, margem 0,9 m, no último 0,55 s do preparo e no voo); o machado já é lido pelo laço de
  projéteis e pelos fios de aviso do `_danger`.
- Livro: `CodexScreen.ENEMIES` e `RoleMark` (`leap`: quatro cantos; `throw`: linha com ponta nas duas extremidades); textos `enemy_saltador`,
  `enemy_lancador`, `codex_role_leap`, `codex_role_throw`.


## C1e, lote C: Canalizador, Armadilheiro, Regenerante e Eco (`docs/design/inimigos_c1e.md`; testes em `tests/test_c1e_c.gd`)
- **Canalizador** (`canalizador`, `EnemyDef.Behavior.BEAM`, `Horde._behave_beam`; regras puras em `BeamRules`, `scripts/core/beam_rules.gd`): modelo do
  feiticeiro (`mage`, sem assado novo: o orçamento de 70 MB dos assados não comporta outro) em tinta azul-aço claro, 1,3; vida 130, fincado (velocidade 0). A até 12 m do herói: fio
  no chão de 0,9 s (`add_aim_warning` + `track_line`; segue o herói e trava nos últimos 0,3 s, `aim_lock`), depois o raio (zona de linha de 0,5 m mantida
  acesa com a `life` no `BEAM_FILL`, etiqueta `Horde.BEAM_TAG`, como a barra do Varredor) por 5 pulsos de 5 a cada 0,45 s (`shot_ticks`,
  `shot_interval`, `attack_damage`; 2,25 s), a linha virando atrás do herói a 40 graus/s (`shot_turn`, `BeamRules.turned`). Um pulso fere quem está na
  linha (`BeamRules.hits` = `SweepRules.in_bar`, alcance cortado por pedra com `Arena.shot_reach`) e nunca a menos de `sweep_clear` (1,0 m) do pé dele. Recarga 2,4 s
  (x0,9 do `ENEMY_COOLDOWN`), descanso 0,4 s. A Quebra (`interrupt`) e o congelamento cortam o raio (`_holds_bar`, junto da barra do Varredor).
  Papel `beam`, `per_room` 1, `never_with` `sweep` (nunca com o Varredor). Brado, esquiva e Investida absorvem ou atravessam um pulso pelo `hit_player` comum.
- **Armadilheiro** (`armadilheiro`, `SUPPORT` com `plate_*`; `TrapRules`): assado próprio `trapper` (corpo do besteiro curvado, placa de espinho na mão
  esquerda, 3,5 MB), tinta oliva, 1,2; vida 110, anda 3,8, mantém 5 a 7 m e foge a menos de 5 (`retreat_far`). A cada 2,6 s (x0,9) abaixa 0,5 s e planta uma placa de
  1,6 m onde o herói pisa, ou onde terminou a última esquiva se foi há menos de 3 s (`Player.last_dodge_end`, `dodge_age`, `Horde.dodge_end`;
  `TrapRules.spot`); no máximo 4 (`plate_max`, `TrapRules.may_lay`, afastadas 1,28 m). A placa é uma zona de linha quadrada de 1,0 s (`Ground.PLATE_TAG`, seu preenchimento vermelho escondido) cujo aviso é um X
  fino marfim com as quatro bordas (`C1eMarks._put_plate`, que fica mais claro até o fim); ao fim fere 10 em quem está nela (a invulnerabilidade da esquiva passa por cima) e levanta poeira. Depois do X os
  espinhos ficam de pé 0,5 s (`plate_spikes`; ferem uma vez quem pisa neles e não foi ferido no pouso, a esquiva passa por cima) e a placa fica dormente (X apagado, ainda conta no máximo de 4)
  até 6 s depois de plantada (`plate_life`; `TrapRules.phase`, `TrapRules.Plate`, `Horde.plates_laid`, `_step_plates`; `C1eMarks._put_plate`). Papel `trap`, `per_room` 1; a sala da corrente (RP-11) proíbe o papel.
- **Modificadores** (`ModDef`): **Regenerante** (anel azul-claro, `regen_hp` 12 a cada `regen_after` 3 s sem golpe: `Enemy.calm_t`, zerado em `Horde.damage`;
  `SupportRules.mended`) e **Eco** (anel cinza, `echo_time` 3,5, `echo_share` 0,4: a primeira morte deixa um monte invulnerável que se ergue sozinho com 40% da vida, uma vez,
  e perde o anel; `Enemy.echoed`, `_lie_down` e `_step_down` do monte da Trinca; `SupportRules.echo_hp`, `echo_rises`; não conta como morte até cair de vez). O sorteio
  passa a ter 5 modificadores (`StageDef.mods`), 2 por sala no máximo, de 10% na sala 8 com mais 5 pontos a sala.
- **Som de aviso**: `tell_beam` (carga do próprio jogo mais aguda) e `tell_trap` (osso e besta, graves), feitos no fim de `tools/make_sfx.sh`; 14 papéis, 14 sons.
- **Robô**: no pé do Canalizador (até `sweep_clear` + 0,3 m) o raio não é perigo e ele entra para bater; na linha, sai de lado (o fio e o raio entram no `_danger`
  como qualquer linha); a placa entra como linha de aviso. Livro: `CodexScreen.ENEMIES` e `RoleMark` (`beam`, `trap`); textos `enemy_canalizador`,
  `enemy_armadilheiro`, `codex_role_beam`, `codex_role_trap`, `mod_regenerante`, `mod_eco`.


## C1d, lutas de chefe (2026-11-22; `docs/design/chefes_c1d.md`; testes em `tests/test_c1d_*.gd`)
- **Lote 1, dados**: `EnemyDef.guard_up_*` (guarda por tempo do Cavaleiro), `ward_open` (Brado abre o Cavaleiro), `wall_stun` (investida na parede); `BossDef.posture`, `posture_stun`, `posture_vuln`, `posture_idle`, `posture_mult` (Postura de Morvath, desligada até o lote 4). Nada muda no jogo. A regra F8 segue (teste).
- **Lote 2, Cavaleiro** (`knight.tres`, números em `make_data`): K1 `wall_stun` 1,5 s se a investida acaba na parede (colisão dele, `Horde._wall_hit`/`_wall_stun`, sem Quebra nem F8); K2 `ward_open` 1,0 s: o Brado que absorve a pancada de perto (`Player.ward_taken` -> `Horde.ward_taken`, só com `memo == 1`) o deixa aberto; K3 guarda por tempo (`guard_up_*`: a cada 14 s com a armadura acima de 50%, aviso 0,6 s, 4 s de escudo com `front_block` 0,7, anda a 60%, bate a cada 1,6 s a 1,6 m com aviso 0,85 s e dano 12, fora do arco da frente x1,5 para o ataque; a onda abre por `front_open` 4 s). `Horde.guard_up` só vale com `guard_t > 0` nesse caso. K4 (chamado) e a investida rastreada já existiam.
- **Lote 3, Ancião** (`priest_elder.tres`): A2 `volley_*`: depois do leque (fala par) e a cada 12 s ele recua 8 m em 1,5 s (para na parede), ergue o cajado 1,0 s com um fio por orbe e solta 3 orbes a 4 m/s que giram 60 graus/s por 4 s (medido: 5 s subia o dano do Ancião a 1,4x), depois descansa 1,5 s (`Horde._volley_back`, `_volley`; `_aim_fan` aceita contagem, abertura e aviso); A3 `ward_count` 3, 40 de blindagem nos servos a cada 5 s (o `_step_ward` do Sacerdote; some com ele).
- **Lote 4, Postura de Morvath** (`BossDef.posture` 900, `posture_stun` 2,6, `posture_vuln` 0,4, `posture_idle` 5, `posture_mult` 0,5): a mesma ideia da Quebra, sem duplicar: `Horde.boss_blow(e, fonte)` (emitido em `damage` para o chefe) chega a `Boss._on_blow`, que gasta `Poise.share(fonte, Feel.poise_weights) * posture_mult` de 900 (ataque 14 golpes, onda e Brado 3 a 4, Investida 4, ultimate 2; queimadura, eco e Dons sem peso não tiram). Quebrada: `_cancel()` (corta o preparo) e `_stun(posture_stun)`, `e.broken_t` faz `Horde.damage` multiplicar por 1,4 (`Horde.boss_vuln`); cheia de novo ao levantar; 5 s sem golpe que tira também enche. A contagem antiga de golpes pesados (`stagger_hits`) fica desligada com `posture > 0`. A barra amarela do HUD do chefe mostra a Postura (`Boss.posture_ratio`). `RESULT.breaks` traz `boss_<botão>` e `boss.posture_breaks`.
- **Lote 5, Condutores**: `BossDef.ritual_conductors` (`mage`) e `ritual_shorten` 5 s: cada feiticeiro do ritual que cai corta 5 s dele (`BossRules.ritual_limit`, `Boss.conductors_dead`, `ritual_time_left`); com os 2 o escudo abre aos 10 s e ele fica 2,0 s tonto (`ritual_stun`). Palavra "Condutor caiu!".
- **Lote 6, Corte do rastro** (`BossDef.curse_cut`): a onda do herói (`Kind.WAVE` e `Kind.SPARK`, o especial e as Ômegas) que toca o projétil da maldição o desfaz sem dano nem lentidão (`Projectiles._cut_curses`, sinal `curse_cut_at`, `boss.stats.curses_cut`); o Brado (e o escudo) que absorve o golpe leva a maldição junto (`Player.absorbed_last`, `Game._on_status_player`). O robô lança a onda na maldição a menos de 9 m que vem para ele (`Bot.curse_aim`). Ataque comum, Investida e esquiva não cortam (a esquiva só foge).
- **Lote 7, Ruptura** (`BossDef.rupture_*`, estado `Boss.State.RUPTURE`): na fase 4, 12 s depois de entrar e a cada 25 s, no lugar de um golpe do diretor (`BossRules.rupture_due`, só com ele em CHASE e descansado), um círculo do alcance do salão (sem faixa livre; `z.eruption` para o desenho dos círculos dele) avisa 1,5 s e dá 16; depois ele fica 3 s exposto (x1,4, sem Postura: `e.broken_t`, `_posture_open`), então a Postura volta cheia. O Brado e o escudo levam o golpe inteiro (`Player.hurt`); a esquiva de 18 quadros no fim também passa. Durante o aviso a Postura não corta o golpe. `boss.stats.ruptures`, `attacks.rupture`.
- **Lote 8, ajuste**: `posture` 1300 e `posture_vuln` 0,3 (a luta de Morvath durava 2:00 a 2:20 para o evoluído; o plano pede 2:40 a 3:00 e ainda não chegou, ver `combat_cadence.md` 10). Teste de carga do Cavaleiro (`test_enemy_windup`) ignora o escudo erguido por tempo.
- **Pendências conhecidas (não do C1d)**: `test_c1b_rooms` (vida do grande), `test_rooms` (armadura dos elites), `test_waves` (comum cai em uma cadeia) e `test_bench_ui` (Compêndio) falham desde antes, por números do C1b e do Compêndio; o `--smoke=300 --seed=5` do novato morre no Ancião (sala 7) como antes do C1d.

## Cavaleiro, 2026-11-23 (Daniel: "ataca mais rápido", a investida difícil de desviar, o escudo; testes em `tests/test_knight_throw.gd`)
Princípios do estudo `docs/design/sworn_gawain.md` (lista de prioridade, cooldown por habilidade, anel que só a esquiva atravessa), sem nada copiado.
- **Mais rápido e mais assustador** (`knight` em `make_data`, marcado `exact_windup`): investida com aviso 0,6 s (era 1,0), `aim_lock` 0,15 s (a linha segue o herói até 0,15 s antes de sair), arranque 24 m/s por 0,6 s (14,4 m; era 18 por 0,7), segunda e terceira investidas com 0,45 s, golpe de perto 0,5 s (era 0,8), golpe atrás do escudo 0,6 s. Dano 14 na investida e no golpe de perto, 10 atrás do escudo.
- **Lista de prioridade** (`EnemyDef.moves`, `KnightMove`, regra pura `AttackList`; relógios em `Enemy.move_cd`, um por golpe): de cima para baixo, o primeiro aberto é feito, um por vez. Escudo (`throw`, cooldown 18 s, primeiro uso 8 s, a 4 a 16 m), investida tripla (a partir de 40% da dureza, cooldown 10 s), dupla (75%, 5 s), simples. Fases pela **dureza** (`Horde.toughness`: vida mais armadura sobre o total, o que as duas barras mostram), então a luta muda enquanto ele ainda tem escudo. A guarda por tempo (K3) e o chamado dos mortos (CV-2) continuam na frente da lista; o golpe de perto e o recuo de 3 golpes ficam como enchimento.
- **Arremesso do escudo** (`EnemyDef.throw_*`, `ring_*`; `Horde._loose_shield`, `_step_shields`, `_land_shield`, `_step_waves`): 0,5 s de aviso (a pose `summon`), o escudo sobe e cai em 1,0 s onde o herói está (o ponto o segue até 0,35 s antes de pousar); o chão mostra os quatro cantos fechando (`C1eMarks`, mesmo desenho do Saltador, laranja) e o aro do escudo cruza o ar. Pouso: quadrado de 3 m, dano 12. Sem escudo ele fica "aberto" 1,8 s depois do pouso (`Enemy.away_t`): sem guarda, sem investida, e a armadura leva todo golpe inteiro.
- **Onda do escudo** (`ShockRing`, `Fx.wave_ring`): 0,25 s depois do pouso nasce um anel que se expande a 12 m/s (o herói corre a 11), 0,8 m de espessura, até 32 m (a sala toda), dano 9, uma vez por onda e nunca em quem já levou o pouso. **Só a esquiva atravessa**: a proteção dura os 0,2 s da rolada e o anel conta como esquiva no último instante em qualquer momento dela (`Horde.last_wide` e `Player.close_any` alargam a janela de 0,15 s para os 0,2 s inteiros). Exceção do Daniel: o anel é redondo porque é onda em movimento, não marca no chão.
- **Armadura que sente só golpes fortes** (`EnemyDef.armor_soft` 0,3, `DamageCalc.armor_scale`, `STRONG_TAGS`): golpe leve comum (corte 1, corte 2, estocada) leva 30% à armadura; o final (corte 3), a onda do especial, o corte da Investida, as Ômegas, o Brado e as Supremas levam inteiro; com o escudo longe, tudo leva inteiro. Armadura 1700 (era 1220); **PT-25-5 (2026-11-25, Daniel não quebrava a guarda): armadura 550 e `armor_soft` 0,5** (`KNIGHT_ARMOR`, `KNIGHT_ARMOR_SOFT` em `tools/make_data.gd`), medido com o robô (`--start=miniboss`, sementes 5 a 7): a primeira pancada na armadura aos 3,0 s e a barra no fim aos 13 s, cerca de 10 s de luta focada (com 1400 e 0,3 eram 41 a 44 s). A regra F8 não mudou (golpe comum não atordoa; quebrar a armadura abre 2,5 s).
- **Um botão para os avisos** (`ENEMY_WINDUP` 0,8 em `_enemy`, pisos 0,5 s e 0,6 s para pesado): os comuns e o Ancião passam a 80% do aviso; antes e depois em `docs/design/combat_cadence.md` seção 11. Morvath: `windup_scale` por fase.
- **Robô** (`Bot.ring_dash`, `shield_escape`): sai do quadrado do escudo nos últimos 0,6 s e dá a esquiva quando o anel está a 0,09 s de tocar, com 75% de acerto (uma vez por onda).
- **Som**: aviso e arremesso usam os sons do Cavaleiro; pouso `enemy_burst`; nascimento do anel `wave_omega`. Nenhuma receita nova. Nenhum shader novo (o anel é o `ring.gdshader`): o conjunto de aquecimento não precisa ser regenerado.

## Cadência dos chefes: a pausa aleatória e o Ancião que chama arqueiros (Daniel, 2026-11-23; `tests/test_cadence_gap.gd`)
Daniel viu o robô lutar: o Cavaleiro e Morvath faziam um golpe e ficavam muito tempo sem fazer nada. Medidas e números antes e depois em `docs/design/combat_cadence.md` seção 12.
- **Medida** (`IdleStats`, no `RESULT`): `idle` (por guardião, `Horde.idle_report`) e `boss.idle` (Morvath). `mean`, `p90`, `max` são a pausa entre o fim da recuperação e o próximo aviso; `dead_*` é do fim do golpe (recuperação incluída) ao próximo aviso; `share` é a parte da luta andando sem atacar, `share_rec` com a recuperação. Aberturas ganhas (atordoado, escudo longe, armadura quebrada, joelho de Postura, ritual, rugido) não entram.
- **Pausa aleatória** (`AttackGap`, `EnemyDef.gap_*`, `BossDef.gap_*`): depois da recuperação, uniforme entre `gap_min` e `gap_max` (0,3 a 1,5 s com a vida cheia), as duas pontas deslizando até `gap_min0` e `gap_max0` (0,2 a 0,7 s sem vida) pela parte de vida que resta (a do Cavaleiro é a dureza: vida mais armadura). Usa o sorteio da própria luta, então a mesma semente dá o mesmo `RESULT`. O descanso do Cavaleiro era `AFTER_RECOVER` (0,25 a 0,75 s); o de Morvath `BossDef.rest` (0,4 a 1,1 s), que agora só vale depois de rugido, atordoamento e ritual. O Ancião não usa (a cadência dele ficou).
- **Morvath um golpe de cada vez**: `BossAttack.layers` ficou vazio em todos os ataques (erupções e mortos por cima da foice, lâminas, maldição e tempestade saíram); o mecanismo continua no código e os testes de segurança dele (`BossLayersFixture`) usam uma cópia com as camadas.
- **Cavaleiro**: dano da investida e do golpe de perto 14 para 8, arremesso 10 para 8, anel 7 para 6, golpe com a guarda 10 para 8, para o novato (30 de vida) continuar vencendo cerca de metade das lutas com a pausa curta.
- **Ancião chama arqueiros** (`EnemyDef.raise_kind` `archer`, `raise_count` 2, `raise_max` 2, `raise_cd_min`/`max` 10 a 14 s, `raise_first` 4 s; `Horde.edge_spots`): no lugar dos esqueletos de perto, de 10 a 14 s ele para, ergue o cajado (a pose `summon`) e dois arqueiros nascem na borda do chão, o mais longe do herói e um do outro, no máximo 2 de pé. As colunas da sala barram as flechas deles como as do Ancião (`shots_blocked`). Os leques e a salva de orbes ficam.

## A Maga elemental (GE-4, 2026-11-24)
`scripts/game/arcane.gd` aplica o que o `ElementBook` (puro) responde: `apply_element(e, el)` põe Queimadura/Frio/Eletrizado, trata a reação
(Choque Térmico, Sobrecarga, Cristalização; nunca encadeia) e o congelamento (3º acerto de Frio, `thaw_t`). Kit: Centelha (`shot_landed`,
3 acertos em 4 s acendem), Combustão (CHARGE_LIGHT, explode no 1º inimigo), Estilhaço (heavy, atravessa, 4 s), Geada (CHARGE, `Patch`),
Arco (`Effect.ARC`), domo e Passo preservados. Convergência: `Ultimates._step_converge` + `ConvergePlan`. Dano elemental entra por
`Horde.damage` com fonte `elemental` (sem Magia, sem Apogeu). `Horde.crack` desgasta a Postura do chefe ou a Quebra de comum (fonte `crystal`).
`StatePips` desenha os estados. Números em `ArcaneKit`, gerados por `_maga` em `tools/make_data.gd`. Os 12 Dons são provisórios (docs/backlog.md).

## SW-C4, C5, C7 e C8: dano e aviso, barra de atordoamento, Rato de osso e Capitão (2026-11-25; plano SWORN, `docs/design/sworn_rea_kingswood_2026-11-25.md` seções 3.2 e 4; testes em `tests/test_sw_c.gd`)
- **Dano e aviso (C4).** Comuns tiram 4 a 8 dos 40 do herói (10 a 20%) e avisam 0,5 a 0,7 s; elites e Esqueleto Maior, 0,8 a 1,0 s; ataques de área grande (Varredor, Canalizador, Corredor Maior), 1,2 s. Tabela antes e depois em `docs/design/balance.md` (seção SW-C4). Exceção deliberada: o Cavaleiro mantém o aviso de 0,6 s (pedido do Daniel de 2026-11-23, "ataca mais rápido").
- **Barra de atordoamento (C5).** É a Quebra de sempre (`Poise`, pesos por botão em `Feel.poise_weights`) estendida: `EnemyDef.poise_mult` (parte da barra que cada golpe tira: elite 0,5, Capitão 0,4, guardião 0,3), `poise_stun` (elite e Capitão 2,5 s, guardião 3,5 s; o comum segue 1,2 s), `poise_vuln` (+25% de dano enquanto aberto; Morvath +30%) e `poise_growth` 1,25: cada quebra depois da primeira pede 1,25x mais barra (`Poise.full_after`; o golpe tira sempre a mesma fração da base, a barra é que cresce; `Enemy.poise_full`, `poise_breaks`). Os comuns têm `poise_growth` 1 e ficam como eram. Quem tem `poise_growth` > 1 gasta a barra também com a armadura de pé (são duas barras; `Horde.damage`, ramo da armadura) e a barra aparece sob a barra de armadura (`CrowdRenderer.add_poise_bar(..., armored)`). Morvath: a Postura passou a 3,5 s e `BossDef.posture_growth` 1,25 (`Boss._posture_full`, a barra grande do HUD mostra a razão certa). Reaproveita sem duplicar: `StunRule` (F8) só manda no flinch curto dos comuns, a quebra de poise não passa por ele; o atordoamento do Cavaleiro na parede (`wall_stun`) e o `armor_stagger` continuam seus; atordoado, o corpo não gasta poise (`Poise.takes`). O flinch curto dos comuns não mudou.
- **Rato de osso (C7)**, `bone_rat`: a figura do esqueleto a 0,6, 10 de vida (o primeiro golpe do Guerreiro tira 15), 4,2 m/s, 3 de dano, aviso 0,5 s, corpo sólido como todos. Papel `scurry`, `EnemyDef.pack_min` 4: onde entra numa onda, vem com 4 ou mais (`EncounterGen.waves`), e o pacote conta meio corpo para o teto da onda (`bodies`, `_crowded` só encolhe o pacote se nada mais puder ceder). Das salas 3 em diante (faixas novas em `_stage`).
- **Capitão esqueleto (C8)**, `capitao`: a figura do guarda maior e dourada, 520 de vida (5,5x o esqueleto de 95), sem armadura, `no_push` (golpe nunca o empurra), investida e chamado com aviso de 1,2 s, chama 5 esqueletos fracos (o chamado do Cavaleiro, CV-2: a cada 2 filas de investidas, no máximo 5 seus de pé), um por luta (`per_room`), papel `captain`, das salas 4 em diante, na última onda. Não é `elite` (para o sorteio por papel o aceitar); tem a barra de poise de 2,5 s. Não está no Compêndio (`CodexScreen.ENEMIES`) ainda.


## SW-REA (2026-11-25): recuperação curta, Cavaleiro do Butcher e fases por vida (`docs/design/sworn_rea_butcher_2026-11-25.md`; `docs/design/combat_cadence.md` 14; testes em `tests/test_knight_phases.gd`)
- **Recuperação**: `ENEMY_RECOVER` e os `recover_time` literais caíram (esqueleto 0,75, corredor 0,8, trinca 0,7, rato 0,6, saltador 0,8, escudo 1,0, esqueleto grande 1,1, corredor grande 1,0, varredor 1,1, feiticeiro 0,65, Capitão 1,0 com espera 0,2 a 0,8); Escudo e Esqueleto grande avisam 0,70. `Horde.AFTER_RECOVER` fica. Morvath: `gap` 0 a 0,3 (0 a 0,1 no fim), `reap_recovery` 1,1, `storm_recovery` 0,8. O Ancião e os atiradores não mudam.
- **Cavaleiro** (`knight` em `make_data`): ver a tabela em `combat_cadence.md` 14. Chefes e guardiões não esperam entre um ataque e outro (`gap_max` 0,15, nunca 0, senão volta o `AFTER_RECOVER`).
- **Fases** (`KnightPhase`, pura): `EnemyDef.roar_marks` (80% e 40%) e `roar_time` 1,78: o Cavaleiro para e ruge (`Horde.KNIGHT_ROAR`, clipe `summon`, parado e atingível; um golpe que quebra a barra o corta), uma vez por marca (`Enemy.roars`). `guard_up_life` (a guarda por tempo só abre com a resistência abaixo disso), `guard_up_reach` (só com o herói a até 6 m) e `guard_up_rest` (2 s parado quando a guarda cai sozinha, `Enemy.still_t`). `raise_life` e `raise_cooldown` (chamado só abaixo de 60% e a cada 30 s, o primeiro em `raise_first` 10 s; o Capitão segue por filas, valores padrão). `KnightMove.from_life` já existia: a investida dupla abre em 40%. Resistência = vida mais armadura (`Horde.toughness`).
- **Fora**: ondas no chão que perseguem e erupções (zonas novas). O `ring_speed` do escudo (7,5 m/s) agora é menor que a corrida do herói (11): a onda ainda pede a esquiva dentro da sala, mas corre-se dela em campo aberto; `test_knight_throw` compara com a caminhada.

- **Passinho em todo golpe do combo (PT-25-4 e PT-25-11, 2026-11-25; substitui os "golpes plantados" do E1c e do pedido de 2026-11-16)**: `ComboNode.step` (metros, dado em `tools/make_data.gd`, `STEP` = [0,3, 0,3, 0,8]): corte 1 e 2 dão 0,3 m e o final 0,8 m à frente, no instante do impacto (`ComboRunner.move_hit` -> `Player._step_in`, que soma ao `Player._step`, vetor próprio com o decaimento `StepRules.DECAY` 6/s: o final de 0,8 m sai a 4,8 m/s, abaixo da corrida de 6,75, e gasta os mesmos metros em cerca de 0,4 s; revisão 2026-11-26). A preparação segue parada; o passo nunca é andar (`move_scale` 0, as pernas continuam presas pelo `move_hold`). Para nos corpos (`stop_walker`) e nas paredes (`sweep`) como um andar. O quinto golpe (`cut4`, `thrust4`) dá 0,3 e 0,3. Preparação do especial, do Brado e da Investida (todo golpe que não é `LIGHT`) zera o resto do passo; o passo não é dado se terminaria em armadilha de chão armada ou aquecendo (`Ground.room_rects`) em que ele ainda não está. Teste: `tests/test_warrior_strike.gd`, `tests/test_combo.gd`, `tests/test_step_rules.gd`.
- **Oferta do anjo (PT-25-1)**: `Encounter.cards` sempre devolve 3 quando `Encounter.eligible` (sorteio da família, depois um nível a mais de uma Bênção já levada). A causa do "só 1 carta" não se reproduziu na lógica (`tests/test_angel_cards.gd`: 300 descidas, mãos aleatórias, Juramento de Escolhas Perdidas, Ultimate fechada, etiquetas do Guerreiro; também 3 em `--first` com o robô); por isso a tela passou a avisar quando um anjo traz menos de 3 (`BoonChoice.by_angel`, texto `angel_few`).

- **Soft-lock do Jardim (2026-11-26, semente 1)**: dois `skeleton_raised` nasceram (escolta/invocação) num bolsão de 9 células entre o tronco e a raiz norte da
  variante A, uma ilha do `NavGrid` fora do chão da sala; o `FlowField` não tinha caminho (`steps_from` -1), eles andavam reto contra o tronco e a sala
  (que só fecha com 0 vivos) ficou 477 s sem fechar. Correção: `NavGrid.main_island`/`nearest_main`; `FlowField.goal_cell` leva um alvo em bolsão para o
  chão da sala; `Horde.on_floor` põe todo nascido em bolsão no chão (em `spawn`) e socorre quem fica `STUCK_TIME` + `STUCK_RESCUE` (6 s) sem andar.
  Testes: `tests/test_flow_pocket.gd`.
- **Revisão 2026-11-26 (equilíbrio)**: Cavaleiro com 650 de vida, `hp_scale` 1,0 e `attack_damage` 15 (armadura 550 e `armor_soft` 0,5 intactas); `mage_elite`
  com `attack_damage` 4,8 (20% abaixo dos 6 do mago). O `RESULT` ganhou `won` (modo ENDING) e `guardian_fight` (segundos por sala de guardião, `knight_hall` e `elder_hall`).
