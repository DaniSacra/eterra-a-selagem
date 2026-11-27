> Índice: [gameplay.md](../gameplay.md)

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
- **Bênçãos V1 (2026-11-26, pedido do PO; especificação em `docs/design/bencaos_v1/`, o que foi feito, a tabela de ids e o que
  ficou de fora em `docs/design/bencaos_v1/IMPLEMENTACAO.md`)**: sete anjos, nove poderes cada, 63 em `data/boons/v1_NN_<id>.tres`
  (gerados por `tools/make_data.gd boons`). Cinco principais por anjo, um por botão (ataque `light`, especial `heavy`, Brado,
  esquiva, Golpe Supremo; o E, a Investida, não tem Bênção) e quatro complementares (`Boon.Slot.NONE`) que pedem uma capacidade
  (`Boon.grants` e `needs_all`: queimadura, frio, crítico, impacto, fraqueza, marca, eco, cadência, ou `fam:luz`, `fam:mare`).
  Sorteio sem substituição: botão ocupado sai do baralho antes de sortear (`BoonState.offerable`, `still_free` ao pegar a carta),
  não existe `trade` nem "Substitui:", o Elo e os Encantos ficam fora do sorteio dos anjos (os recursos continuam). Um anjo mostra
  de 0 a 3 cartas (`Encounter.supply`, `MIN_CARDS` 1); sem nenhuma, ele sai antes da porta e a carta de descanso de sempre é a
  resposta. Principal pesa o dobro de um complementar. Maré aparece como Vento e Marca como Penumbra (os ids de família ficam).
  Comportamento novo na camada `Celestial` (`game/celestial.gd`, filha de `Combat`, chamada por `Combat.hit_enemy`), regras puras em
  `core/cel_rules.gd` (todos os limites e números fixos num lugar) e `core/cel_state.gd` (Frio, Impacto, Marca e contagens por
  inimigo). A ação de um golpe vem de `CelRules.slot_of` (`DealtBy.source`), nunca da etiqueta solta: a Investida leva `light` e
  `dash` e é do E. Queimadura, Fraqueza e congelamento usam os relógios que já existiam (`burn_t`, `weak_t`, `frozen_t`); uma
  Bênção nunca soma Queimadura (renova o tempo e fica o maior dano por segundo). Frio: 3 acúmulos em 4 s congelam um comum por 0,8 s
  e o deixam imune por 2 s; Impacto: 5 pontos em 4 s atordoam por 0,6 s, imune por 3 s; chefes nunca congelam, atrasam nem atordoam.
  Crítico sem chance própria (só as fontes de Lumael), 150% do dano, tetos de 60% e 250%; DOT, eco e golpes secundários não rolam
  dado. Eco e propagação não geram eco nem propagação. Tetos de totais: velocidade 50%, recarga 30%, lentidão 40%, Fraqueza 40%.
  Os números de texto fixos vêm de `CelRules.text_args()` (`{marcadores}` da frase). A Maga leva a mesma camada, ao lado do
  `Arcane` dela (queima e frio nativos não mudam). Ids antigos continuam carregando (reserva): um save ou um teste ainda os pega.
- **Bênçãos V2 (2026-11-26, GP-2; especificação `docs/design/bencaos_v2/IMPLEMENTACAO_V2.md`)**: nove anjos, 81 poderes (63 da V1 com os
  mesmos ids, 26 deles com efeito novo, e 18 de Zerael (Peste, `F.PESTE`, id `zerael`) e Saarael (Trovão, `F.TROVAO`, id técnico `thunder`)),
  gerados por `tools/make_data.gd boons angels` (`assert(_v1_n == 81)`). Motor novo por cima de `Celestial`, `CelState` e `CelRules`, sem
  reescrevê-los: **Veneno** (até 5 acúmulos, um relógio só de 5 s que renova até 8, tique de 0,5 s com `dealing` `veneno`, Saturação,
  Deterioração, Peste Persistente, Contágio), **Sangramento** (fatia do golpe direto, saldo de no máximo 3 fatias, 4 s, `sangramento`),
  **Eletrificação e Descarga** (5 cargas, 6 s, faísca na hora, Descarga em 5 cargas com recarga de 4 s por alvo, Condução, Sobrecarga,
  Ressonância; nunca atordoa), **antecipação** de DoT (`Celestial._antic`: entrega uma fração do que faltava e tira a mesma fração do
  efeito), **propagação única** (`_copy_dots`, `copy_lock` de 3 s nos dois lados: cópia não copia), a **Abertura** de chefe e guardião
  (medidor de Frio 8 e de Impacto 10; 4 s com +25% nos golpes diretos somado a `direct_mult`, depois 10 s sem somar; o guardião só por
  Impacto; não toca `frozen_t`, `stun_t` nem `poise`) e a **diversidade** de condições (`CelState.diversity`, 0 a 6, máx 3 nas
  Bênçãos que a leem). Linhagem e orçamento: `core/cel_chain.gd` (`CelChain`, tabela `CelRules.EDGES`, profundidade 3) e `Celestial._go`
  (8 reações por ação nas 3 últimas ações, 24 por quadro; o recusado conta em `tally[&"blocked"]`); `CelRules.DOT_DPS_CAP` 16 encolhe veneno
  e sangramento, nunca a queimadura. `after_hit` só aplica estado se o golpe causou dano e não foi barrado pela guarda (`shut`);
  o Golpe Esmagador (`omega_attack`) vale x2 nas contagens e x1,5 nas taxas (`CelRules.hold_count/hold_rate`); o crítico do golpe
  (`_hit_crit`) intensifica as aplicações dele com o Esplendor. Zona `Ground.Kind.PLAGUE` (um acúmulo por segundo por inimigo, sem dano de contato;
  o rastro do Passo Pestilento usa a mesma) e habilidades `poison`/`shock`/`spread` em `Combat._apply_status`. Cores: `Combat.PLAGUE` (enxofre)
  e `Combat.VOLT` (cinza-tempestade; o amarelo-relâmpago só vale no clarão do VFX), sangramento ferrugem `Combat.BLEED`. Textos em
  `data/text_pt.tres` (`gloss_poison/bleed/shock/window/antic` são termos de `Glossary.TERMS`). Ícones das 18 novas: provisórios (12 da Peste, 4 do Trovão).
  Fica para o Guerreiro V1: Poder/Especial nos rótulos, `circulo_mare` virar velocidade do Poder (`cel_speed` no slot `CAST`), as tags `lance`/`heavy`
  em `trigger_of`. Fica para o VFX: bolhas, zigue-zague, gota e a UI do medidor do chefe (dois pontinhos sob a barra). Testes
  `tests/test_blessings_v2_*.gd`.
- **Bênçãos e economia da E3 (Hades II; regras, números e decisões em `docs/design/e3_blessings.md`, métricas do robô em
  `docs/qa/e3_metrics.md`; a V1 acima desligou a troca por raridade e o Elo no sorteio dos anjos, o que resta aqui vale para
  portas, raridade, romã e loja)**: as portas tiram cartas de um baralho sem repor que volta inteiro quando nada serve
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
