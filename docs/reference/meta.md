# Herói, progressão, rejogabilidade e Ofícios

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Guerreiro: HeroDef, Maestria, Dons (E2a, fundação; especificação em `docs/design/warrior_spec.md`)
- **`HeroDef`** (`core/hero_def.gd`, `data/heroes/warrior.tres`, parte `hero` do `make_data.gd`; DT-013): id técnico `warrior`,
  modelo `hero_explorer`, combos, vida 30, `hurt_time`, proteção 1,3 s, 1 carga de esquiva em 0,74 s (saíram do `Feel`), Magia
  50, os números do círculo (saíram de `Player.CAST_*` e `Combat.CAST_*`), passiva `magick_on_finisher` 2 (sem
  comportamento ainda), as duas ultimates (`UltDef`, `core/ult_def.gd`, `data/ultimates/`, parte `ultimates`: U-1 faixa
  12 x 4 m 300/200, carga 60, Maestria 2; U-2 Voragem, carga 70, Maestria 6; só dados), a pasta dos Dons e a curva.
  `HeroDef.warrior()`; `Player.hero`, `Combat.hero` e `Game.hero` leem dele. `Player.RADIUS` continua constante.
  Prova: mesma semente, mesmo `RESULT` antes e depois (smoke 300 e `--start=boss --boons=25`, `--seed=5`).
- **Maestria** (`MasteryCurve`, `core/mastery.gd`, `data/heroes/warrior_mastery.tres`, parte `mastery`): 20 níveis, do n
  para o n+1 `40 + 10 (n - 1)` (2470 no todo), Devoção 5 + nível; XP por sala de luta 10, guardião 25, fase de Morvath
  alcançada 10 (até 40), vitória 50 e primeiras vezes (Bênção vista 2, Elo 10, Salmo 25, guardião 25, vitória 100). No
  fim de toda partida (vitória, morte, saída) `Game.log_run` calcula (`mastery_gain`) e soma ao save (`award_mastery`:
  XP, Dons destravados, primeiras vezes, Compêndio); nunca sem save nem com o robô (`--mastery` deixa o robô somar).
- **Save versão 3** (DT-012, `SaveData`): `heroes.<id>` (`mastery_xp`, `unlocked`, `equipped`, `ultimate`, `firsts`) e
  `codex` (`boons`, `elos`, `psalms`, `talents`, `enemies`: id para contagens); dicionários de chaves livres sobrevivem a
  ler e gravar. Saves 1 e 2 ganham a Maestria retroativa uma vez (40 por partida, 60 por vitória, até o nível 5).
  Arquivos fixos em `tests/fixtures/save_v1.json` a `save_v3.json`.
- **Registro versão 3** (DT-015, `RunLog`): `hero`, `xp`, `xp_by`, `mastery_level`, `talents`, `ultimate`; linhas antigas
  lidas por `RunLog.normalized` (`tests/fixtures/runs_v2.jsonl`).
- **Dons** (`TalentDef`, `core/talent_def.gd`; regras em `Talents`, `core/talents.gd`; 19 em `data/talents/warrior/`, parte
  `talents`): a árvore da seção 4 (Combo, Fúria, Emeth, Magia com entrada, meio e ápice; quatro pontes; três de sustento),
  custo, ramo, degrau, nível que destrava (ordem da 4.4), `slot` quando troca a ação, `partner` do ápice, `joins` da ponte.
  Pré-requisito só vale equipado; ápice pede o meio e um Dom do ramo parceiro (vizinho); ponte pede as duas entradas; um
  Dom por ação; `check`, `can_add`, `sanitized` (o que vem do save). Equipados na descida por `Game._equip_talents`
  (do save, validado pelo nível; `--talents=a,b` para testes); só os de número já agem: Fio Longo (`reach_pct` light 0,15),
  Reserva e Firmeza (`magick_max`, `max_hp`), somados às Bênçãos em `BoonState.stat` (`equip_talents`). Tela do herói: `HeroScreen` (ver Tela de título). Testes:
  `test_hero_def.gd`, `test_mastery.gd`, `test_talents.gd`, `test_save.gd`, `test_run_log.gd`.
- **Passiva e os 19 Dons agindo (E2-07, E2-09; escolhas na `warrior_spec.md` 4.5)**: todo efeito é estatística dos `mods`
  do Dom (com a tag do golpe) lida por `GiftState` (`core/gift_state.gd`, puro) e feita por `HeroGifts`
  (`game/hero_gifts.gd`, `Game.hero_gifts`, criado depois do `_equip_talents`; `Game.equip_talents(ids)` para testes),
  `Combat` (sinal `landed(node, tags, hits)`, uma vez por golpe que acerta alguém, e uma por onda no primeiro inimigo;
  `kill_tags`/`kill_blow` dizem o que derrubou cada abate; Fúria Plena e as ondas dos Dons em `_gift_wave`) e `Player`
  (`omega_discount`, `give_dodge_back`, `show_fury`, `use_tree`, Ainda de Pé em `hurt`, sinal `rose`). Passiva P-A: 2 de
  Magia por golpe com `HeroDef.passive_tags` (finisher, dash, omega) e nenhuma `passive_never` (ultimate), nunca acima
  do máximo; `--no-passive` desliga (com ela desligada e sem Dons a partida é igual à de antes, mesma semente). Quarto
  Corte troca a árvore (`TalentDef.combos`, `data/combos/paladin_fourth.tres`, estocada `thrust4` de 30, DPS do combo
  86,5 contra 86,1); Passo Encadeado e Golpe sem Fim por `ComboRunner.chain_from(opener())`; Ímpeto por
  `ComboRunner.speed` (preparo, brilho, trava, pernas e clipe); ondas de Dom pelo `Projectiles.fire_wave` (`Shot.counted`,
  `Shot.through` da Onda Atravessante, que atravessa a pedra: a seta já atravessava todos os inimigos); Respiro no
  `Rooms._room_cleared`; Coração da Emeth expõe `ult_charge_pct` para a ultimate. Testes em `tests/test_warrior_talents.gd`.

- **Ultimates (E2-08, E2-10)**: ação `ultimate` (Shift desde 2026-11-21, era R; LB no controle), carga `UltCharge` (`core/ult_charge.gd`) pela Magia gasta (`Magick.spent`; U-1 60, U-2 70; `ult_charge_pct` do Coração da Emeth acelera) e, desde a T5 (`docs/design/t5_ultimate.md`), pelo dano causado (`UltDef.damage_charge` 0,02 por ponto, sem os acertos da própria ultimate) e pela vida perdida (`hurt_charge` 1,0; `RESULT` `ult.charged`); sem escolha no save, a descida joga a primeira que a Maestria abre (`HeroDef.ult_for`, gravada no save); o 5º losango aparece trancado com "Maestria 2" antes de abrir, pulsa e diz "Pronta" cheio, e R sem poder diz por quê (`Player.ult_refused`, `Hud.ult_caption`; testes em `tests/test_t5_ultimate.gd`), gesto `Player` estado `ULT` 0,3 s protegido que corta o golpe como a esquiva; efeitos em `scripts/game/ultimates.gd`: U-1 Corte do Juízo (faixa 12 x 4 m, 300 no miolo e 200, armadura em dobro, atordoa 1 s, `ult_rift.gdshader`), U-2 Voragem (6 m a 4 m à frente ou no cursor até 8, 4 s, tiques de 8, implosão 120, espiral por `Arena.sweep`; elites 50%, guardiões 25%, Morvath só lento; `ult_vortex.gdshader`: véu esmeralda até 0,3, três braços marfim, aro de ouro velho que se fecha na implosão, tetos em `Ultimates.vortex_peaks`). Golpes com tag `ultimate` nunca são finalizador nem Ômega. 5º losango no HUD. `--ultimate=cleave|vortex`, `--ult-full`, `--shot-on=ult`. Testes em `tests/test_ultimate.gd`; sonda 40 metas (E2-U1 a U3).

- **Kit novo do Guerreiro (2026-11-21, Lote 1, aprovado pelo Daniel; estado em `docs/design/heroes/guerreiro.md`; testes em `tests/test_shout.gd` e
  `tests/test_warrior_kit.gd`)**: **Q = Brado** (`shout`, RB), **E = Investida** (`rush`, R3), **Shift = ultimate**, **F = interagir**, Espaço só esquiva,
  direito = rajada (8 de Magia, toque), esquerdo igual. O círculo (`cast`) não tem tecla nem é remapeável (`HeroDef.circle = false`; o
  código `Player._read_cast`, `Combat.cast` e o dado ficam para o Paladino). Save antigo não quebra (o save guarda só o remapeado; padrão novo
  que bata com tecla guardada vai para a reserva, `SPARE_KEYS`: interagir G, Brado e Investida Z, ultimate X). Tudo é dado em `_tree`:
  **Brado** `ComboNode.In.SHOUT`, `Effect.SHOUT` (15 em 4 m, empurra 1,5 m com `knockback` 10,5, `_no_stun` para todos; `effect_time` 5 s, `buff_speed`
  0,2, `buff_guard` 0,15, `effect_power` 1 carga de Ímpeto, recarga 12 s), `GiftState.rally` (buff e carga; `rallied()`, `guard()` lido por `Player.hurt`,
  `attack_speed` soma a velocidade), tags `shout` e `cast` (as Bênçãos do slot `CAST` agem nele: Brado em Brasa, de Geada, Radiante, Firme);
  **Investida** `In.RUSH`, nó `dash_cut` (tags `light`, `dash`: 35, linha de 4 m, `lunge` 4, recarga 5 s, `magick_per_hit` 3 lido por `HeroGifts._on_landed`, mais os 2
  da passiva); **rajada** nó `bolt` (60, 6 m, `magick_cost` 8, recarga 0,5 s; `Player._press_special` não aceita o toque sem Magia e emite `magick_refused`, o HUD
  diz "Sem Magia"; sem `burst` na árvore o segurar não carrega nada); `tree.dodge` vazio e `dodge_window` 0 (atacar depois da esquiva é o cut1). Dons: Onda
  Carregada solta a onda do giro na rajada (tag `heavy`); Passo Encadeado, Estocada Certeira (era Investida), Fio do Passo, Retorno do Corte e Eco do Passo
  seguem a Investida pela tag `dash`; Salmo da Sentinela não é oferecido sem círculo (`Psalms.circle`). HUD: losangos esquerdo, direito, Q (Brado, slot `CAST`,
  glifo do grito), E (Investida, glifo `BoonIcon.RUSH_GLYPH`), Shift, Espaço; recargas por `Player.shout_wait` e `rush_wait`. Robô: `Bot.shout_worth` (3 ou mais
  inimigos a 4 m; `--bot-no-shout`), `Bot.rush_worth` (entrar a 4,5 a 8 m, ou para Magia quando a rajada não tem; `--bot-no-rush`), rajada só com Magia. Faltam: slots
  `TECH`/`ULT` e as Bênçãos por família do E e do Shift; os 3 Dons do Brado.

### Guerreiro V1 (GP-1, 2026-11-26; spec `docs/design/heroes/warrior_v1_2026-11-26.md`; testes `tests/test_warrior_v1.gd`, `tests/test_button_intent.gd`)
- Botões: esquerdo toque = Combo (3 golpes), segurar = **Golpe Esmagador** (`smash`, 75, 12 Magia); direito toque = **Corte Circular** (`sweep`, 35, 8 Magia), segurar = **Lança da Emeth** (`lance`, o golpe carregado de antes, 150, 20 Magia); Shift = Supremo; Q sem ação; Brado e Investida não são mais botões; interagir em E (A no controle). Maga mantém Q e C (`Controls.MAGA_ONLY`).
- `ButtonIntent` (`core/button_intent.gd`): toque ou segurar, limiar `Feel.hold_threshold` 0,20 s, sem disparo duplo; esquiva cancela a carga sem custo; sem Magia a recusa é visível (`Player.refusals`, sinal `magick_refused`). A Magia sai no `move_hit` (`Player._on_move_hit`), não no início do golpe.
- `BattleRhythm` (`core/battle_rhythm.gd`, parâmetros `rhythm_*` no `HeroDef`): o último golpe do Combo arma 3 s; o próximo Esmagador, Corte ou Lança consome (Quebra extra, atordoamento, dano e alcance do especial). Criado em `HeroGifts`; limpo ao entrar na sala, no Supremo e na morte. `share()` e `armed()` são o que a UI lê.
- Magia máxima 30; sem reembolso de recarga (`cd_refund_*` 0); `Combat.dodge_through(from, to)` (sinal `Player.dodge_ended`) dá a Investida Implacável pela esquiva (atordoa comuns, Quebra nos demais).
- Dons: Voz do Leão saiu, **Alcance Marcial** entrou (`reach_pct` 0,25 e `push_pct` 0,3 na tag `cast`); Força Titânica é dado (custo x2, dano x3, `magick_max` +10); Ruptura dá `armor_pct` 0,5 ao Esmagador.
- Bênçãos: slot CAST = Poder (Corte Circular), SPECIAL = Lança (tags `lance`, `heavy`); `circulo_mare` = `cel_speed`; Pastor e Onda Gêmea na Lança. Encantos `reserve` (Eco do Passo) não entram no sorteio.
- Save versão 17 (`SaveData.migrate_removed_dons`, idempotente): devolve a Memória dos Dons removidos e limpa as teclas guardadas.

## A Maga, M2 (2026-11-23; plano em `docs/design/heroes/maga_m2.md`, kit em `maga.md`; testes em `tests/test_maga_m2.gd`)
- **Maestria própria**: `data/heroes/maga_mastery.tres` (cópia dos números do Guerreiro, `make_data.gd` `_mastery`; nível 0, sem retroativo). A Maga só tem
  Tempestade e Suspensão Absoluta pelo nível (2 e 6); o robô e `--talents` jogam a Tempestade (`Game._equip_talents`).
- **Árvore em triângulo**: `TalentDef.Branch.PIRO`, `ARCA`, `CTRL` (depois dos ramos do Guerreiro, os inteiros salvos não mudam; `NEIGHBOURS` ligam os três entre
  si; títulos "Piromancia", "Arcanismo", "Selos"). `TalentTree.AXIS` os põe a 120 graus; `HeroLoadout.action_key` dá os nomes dos botões dela. Os 23 Dons são
  `data/talents/maga/` (`make_data.gd` `_maga_talents`; números sem o `FLAT` do `burn_dps`: `_raw`). Ápices em ciclo: Inferno Rúnico com Arcanismo, Ruptura com
  Selos, Contenção Perfeita com Piromancia. Escolha entre Pavio Longo e Cadeia Curta (mesmo slot).
- **Estatísticas lidas por `Arcane`** (`_stat`): `seal_burn`, `seal_magick`, `seal_at` e `circle_seal_at` (`ArcaneKit.lays_seal`), `seal_cap` (Selo Duplo: `SealBook`
  com teto 2, bônus `blast_hit_n`, +40% por Selo a mais), `seal_leap` (Ruptura, 4 m, 4 s), `twin_blast` (Brasa Gêmea, 0,5 s depois, `Twin`), `inferno_dps` e
  `inferno_time` (zona `EMBER`), `circle_time`, `circle_root`, `circle_seal`, `circle_burst` (ao fechar o puxão, `_close_circle`), `dome_size_pct`, `dome_time`,
  `step_flash` (Passo de Brasa: clarão onde estava, brasa onde chega, `Player.last_blink_from`), `blink_pct` (Passo Longo). A queimadura dura os 3 s do jogo
  (`Combat.BURN_TIME`): os 2 s do Pavio Longo viram 3.
- **Suspensão Absoluta** (`UltDef.Kind.DOME`, `data/ultimates/maga/01_dome_abs.tres`, Maestria 6, carga 100): cúpula de 5,5 m que anda com ela por 8 s
  (`Arcane.open_absolute`, `_step_ultra`); tiros inimigos de comuns e elites param no ar (os do Morvath e de guardião não, `_spared`), lentidão em todos
  (Morvath incluso), todo tiro dela põe Selo e bate +30% (`shot_mult`, `Combat.on_shot_hit`), a Explosão custa 5 (`Player.blast_discount`). Glifo `ULT_GLYPH + 3`.
  A Tempestade põe 1 Selo mesmo com Selo Duplo (`SealBook.lay(e, 1)`). A película tem hexágonos dourados e borda âmbar (`assets/shaders/dome_film.gdshader`, um passe sem textura) e o relógio é um anel âmbar no chão que esvazia (`dome_clock.gdshader`, pisca nos 2 últimos segundos com a esfera).
- **Bênçãos afinadas**: a Suspensão tem a tag `dash` (Bênçãos da E e gatilho `RUSH`); ao fechar o puxão o Círculo e ao entrar o domo põem os status das Bênçãos de suas
  tags (`Combat.touch`: queimar, congelar, enfraquecer, marcar); `reach_pct` nos tiros, `wave_size_pct` e `shatter_pct` na Explosão, `push_pct` no puxão; a skill do
  especial cai no ponto da Explosão e a do Q no Círculo (`Arcane.spot_of`). **Domo, Passo e especial** (2026-11-23, depois da M2): `dome_shield` (Escudo da Vigília: o domo abre com o escudo pronto), `dome_heal` (Luz, Passo Radiante: cura por inimigo preso quando o domo acaba por tempo, até 6), `push_pct` com a tag `dash` empurra a borda do domo (a partir de 70% do raio, 4 m/s por unidade; o chefe não). São estatísticas só dela: o Guerreiro as ignora e as Bênçãos `escudo` e `passo_radiante` mantêm o resto. Não criei uma Bênção nova de Shomael na E (mudaria o baralho do Guerreiro e o `RESULT`). Rastro de brasa (`dodge_ember_dps`) do Passo sai na saída e na chegada (`Arcane._on_dodged`; `Game._on_dodged` só põe a linha do Guerreiro). As skills FAN saem da Maga, não do ponto da Explosão (ORBIT já gira nela). XP de primeira vez: `first_seal` (10 de XP, uma vez por herói, `firsts.seal`) quando algum Selo foi detonado (`MasteryCurve.first_seal_xp`).
- **Robô**: `bot.gd` paga a Explosão com o desconto da Suspensão Absoluta; as Dons não entram no robô sem `--talents=a,b`.

## A Videira (V1, 2026-11-23; substituiu "O Preparo"; pacote em `docs/design/videira_pacote_2026-11-23/`; testes em `tests/test_videira_v1.gd`)
- **O que é**: 3 ramos de 3 nós, sem dano, melhorias permanentes para todos os heróis. Subtítulo "Raízes que fortalecem todas as
  jornadas" (sem citação bíblica, D-59). Dado: `VineNode` (`core/vine_node.gd`), `data/vine/*.tres` escrito por `_vine` no
  `make_data.gd`. Regras puras em `Vine` (`core/vine.gd`, o antigo `Account`; a API para a tela está no topo do arquivo).
- **Nós** (custos 5, 10, 20 por ramo; o nó pede o de antes no ramo): **Vida** (Prata): Seiva, Caule, Raiz Funda, +5 de vida
  máxima cada (`max_hp`). **Provisão** (Memória): O Viajante (`traveler`), Estoque (`shop_extra`), Reserva (`shop_care`).
  **Perseverança** (Prata): Colheita de Prata, de Memória e Farta (`silver_pct`, `memory_pct`, `material_pct`, +10% cada).
- **Efeitos**: `Game._equip_vine` soma os `mods` no `BoonState.grant` e põe o bônus na `MaterialPurse` (`bonus`, com resto
  guardado em `carry`: +10% de 1 Esmeralda chega na décima). O Viajante: `RunMap` ganha `traveler` (5º argumento); na camada
  antes de cada guardião a fonte fica e **a outra porta vira um mercador de rota** (`Kind.SHOP`, `is_route_shop`, a loja de
  fim de descida continua a de sempre). Escolha: reusa a loja de rota do DV-2, sem tocar nas 2 portas por sala nem nas
  regras; essa camada deixa de ter luta (a regra "uma luta ao lado da fonte" não vale ali), e o grafo pode ser sorteado de
  novo mais vezes (`failures`). Estoque e Reserva: `Rooms._vine_stock` em toda loja (a de rota também): a cura entra no lugar
  do item do grupo de cuidado quando não há `HEAL`, e Estoque acrescenta um item diferente dos mostrados.
- **Opção do robô**: `--vine=N` (também `--account=N`, o nome de antes) leva os N primeiros nós, um degrau de cada ramo por vez
  (Vida 1, Viajante, Prata, Vida 2, Estoque, Memória, ...); o `RESULT` ganha `vine` (N).
- **Save versão 12**: bloco `vine.bought` (ids) no lugar de `account`. A migração devolve o que o arquivo comprou do Preparo na
  moeda que pagou, exato (`SaveData.LEGACY_PREPARO`, `refund_preparo`, `MaterialPurse.refund`: sem teto e sem contar nos
  materiais trazidos). Saíram Mão Firme, Vigor, Fôlego da Sala, Água Clara, Bolsa Cheia, Coração Atento e Segunda Chance
  (`Player.revives`, `Account.better`, `room_heal_pct` foram removidos).
- **Santuário (V2, 2026-11-23)**: estação própria (`HubPlan.VINE`, leste, junto à Árvore), tela `VineScreen` e o Forjador só da Forja
  (detalhe em `hub.md` "A Videira e o Estandarte dos Heróis"). **V3** faz a planta crescer (`VineStation.grown`). A condição `account`
  do guia do Santuário (`HubGuide`) mantém o id (está no save), agora aponta para a estação, e abre com `Vine.open`.

## Salmos (E4-01 e E4-02; regras, números e escolhas em `docs/design/e4_psalms.md`)
- `PsalmDef` (`core/psalm_def.gd`, `data/psalms/`, parte `psalms` do `make_data.gd`): nome só por tema, sem número nem
  texto bíblico (D-59 (a); teste nas chaves `psalm_*`), `theme`, `slot` (a ação que transforma), três grupos `requires`
  (id de Bênção ou Elo, ou `dom:` + id de Dom equipado), `effect` (SENTINEL, SHELTER, FLOCK, STONE) e os números.
  Regras puras em `Psalms` (`core/psalms.gd`): uma coisa por grupo e nunca a mesma para dois (`met`), 10% por carta e 5%
  no guardião (`StageDef.psalm_chance`, `guardian_psalm_chance`, `Psalms.fill`; o dado só é lido quando algum pode vir),
  um por tema, dois por partida (`MAX_PER_RUN`). Efeitos em `PsalmPlay` (`game/psalm_play.gd`): **Sentinela** (o círculo
  anda com ele e golpeia com 30 quem entra, `Ground.Zone.follow`/`strike`), **Abrigo** (onde a esquiva termina, abrigo de
  2,6 m por 3 s, até 2, que desfaz tiros inimigos menos as meias-luas, `Ground.Kind.SHELTER`, `Projectiles.shelter`),
  **Pastor** (abate reúne luz, até 3; o especial solta uma onda a mais por luz em leque de 14 graus, `Combat.throw_wave`),
  **Rocha** (o giro planta pedra de luz: 30 em 4 m, atordoa comuns 1 s, fica 3 s deixando lento, `Ground.Kind.STONE`).
  Carta: `BoonState.Card.psalm`; `Game.psalm_offered(psalm, first)` e `psalm_taken(psalm, first)`, `Game.choose_card`;
  gente recebe carta de Salmo desde a E4-03 (`BoonChoice.open_cards`, sinal `card_chosen`, ver Tela de dons). Robô e `--autopick` pegam o Salmo; `--psalm=a,b` toma no começo. Compêndio `codex.psalms` (`seen`,
  `taken`) e Maestria (`new_psalms`) no fim da partida; `RESULT` e registro com `psalms`; dano em `dealt_by.psalm`.
  Testes em `tests/test_psalms.gd`.

## Juramentos (E6, D-63; regras, números e escolhas em `docs/design/e6_juramentos.md`)
- Os votos do Juramento do Hades II, abertos depois da primeira vitória (`Juramentos.unlocked`: `wins > 0`), Medo vira
  **Peso**. Nove em `data/juramentos/` (`JuramentoDef`, parte `juramentos` do `make_data.gd`: `stat`, `values` e
  `weights` por nível): Golpes Duros (dano), Mortos Resistentes (vida de todos, Morvath também), Passo Ligeiro (andar),
  Mais Mortos (ondas maiores), Mais Elites, Feridas Abertas (cura), Preço Alto (loja), Escolhas Perdidas (2 Bênçãos não
  escolhidas saem da descida, `BoonState.banned`), Morvath Implacável (descansa menos, ergue mais); Peso máximo 30.
  Regras puras em `Juramentos` (`core/juramentos.gd`: Peso, `scale`, `stage_for`, `boss_for`, `more_waves`, `denial`);
  ganchos em `Game._swear_juramentos` (`Horde.vow_hp`), `Rooms.setup`/`_apply_curse`/ondas, `Boss.setup`, `Game._take`.
  Save versão 4 (`juramentos`: `ranks`, `best`); `RESULT` e registro com `juramentos` e `weight`; vitória dá
  `MasteryCurve.weight_xp` 3 por Peso (fonte `juramentos`). Tela `JuramentoScreen`: depois da primeira vitória o Iniciar
  abre os Juramentos com "Descer" em foco. Sem save (testes, `--nosave`) e para o robô, nenhum. Opções:
  `--juramentos=pain:2,grit:1`, `--wins=N` (abre só na sessão), `--title --screen=juramentos`. Testes em
  `tests/test_juramentos.gd`.

## Balanceamento da região (E6; decisões em `docs/design/e6_balance.md`, números em `docs/qa/e6_metrics.md`)
- Medir com `tools/smoke.sh 900 --seed=N --bot-reaction=0.25`, 72 sementes; Maestria 20 = `--talents=` (o robô não lê o
  save nem `--hero-equip`; Dons que ficam de fora agora geram aviso, `Talents.why_dropped`). Robô 0,25: Maestria 1 vence
  72%, Maestria 20 (montagem de sustento, a mais forte) 90%, diferença 18 (teto 25).
- Ainda de Pé não levanta na sala de Morvath (`GiftState.boss_room`, estatística `rise_boss_share`, hoje 0): com ele lá
  a Maestria 20 nunca perdia. Vida de Morvath fica 6050; carga da ultimate segue pela Magia gasta (`ult.boss_uses` e
  `boss_damage` no `RESULT`).
- O robô escolhe a carta da Provação pelo custo da maldição (`Trials.bot_card`; Pobreza só depois da loja), só entra no
  altar para trocar (`Rooms.bot_door(doors, altar_useful)`) e guarda 50 de ouro para a loja (`Altar.BOT_GOLD_KEEP`).

## Rejogabilidade, Fatia 1 (gameplay; spec `docs/design/rejogabilidade/sistemas.md` 1, 3 a 5; API para a UI em 5.3)
- **Três materiais, sem Brasa** (Q-RJ1 a Q-RJ3): Prata Antiga, Fragmento de Memória e Esmeralda (nomes de trabalho),
  `MaterialPurse` (`core/material_purse.gd`, puro: soma por fonte na descida, teto 999/999/99, `bank` no fim, `give`,
  `spend`, `parse`). Na descida (`game.materials`): elite comum abatida 1 de Prata (não guardião nem chefe,
  `Rooms._on_killed`), porta de Prata 10 e de Memória 3 (`RunMap.Reward.SILVER` e `MEMORY`, `_give`), guardião 6 e 2
  (`_room_cleared`), Provação vencida 2 de Memória (`_fight_won`), cada fase de Morvath alcançada 2 (até 4, uma vez,
  `Rooms.boss_phase`) e a vitória 10 e 3 (`Rooms.victory`); números no grupo Materials do `StageDef` (`_stage` do
  `make_data.gd`). Baralho das portas com 16 cartas (uma Prata, uma Memória a mais; nada saiu). Guardados no save no
  fim de toda descida (`Game.log_run`, `Game.banks_materials`): nunca o robô nem sem save (`--materials-keep` deixa o
  robô guardar, para medir). Robô: porta de material com peso 2,6 / 2,4 (`Rooms.BOT_MATERIAL_RANK`, entre Magia e romã).
- **Forja** (`Forge`, `core/forge.gd`; `ForgeRank` em `data/forge/emeth/`, parte `forge`): Temperar I 15 de Prata (+10%
  no ataque, tag `light`, a lança junto) e II 35 (+10% no especial, tag `heavy`); somados ao `BoonState.stat` pelo
  `equip_forge` (`Game._equip_forge`: do save para gente, `--forge=N` também para o robô). No hub o Forjador abre a
  Forja (`ForgeScreen`, ver a interface da Fatia 1 abaixo), que compra, grava e emite `Hub.forged(rank)`.
- **Dons abertos com Memória** (Q-RJ11: a Maestria revela um Dom por nível): `TalentDef.memory_cost` (o custo de
  Devoção; 0 no Dom do nível 1, o Quarto Corte), `opened` no bloco do herói; `Talents` com `SEALED`, `OPENED`, `SHORT`,
  `open_in`, `open_problem`, `is_open` (`opened` nulo = tudo aberto, o robô e `--talents`). `HeroLoadout.State.SEALED`;
  abrir é só pela confirmação na página do Livro (`HeroLoadout.open`; `toggle` nunca abre um selado).
- **Anjos e o Encontro** (Q-RJ4 a Q-RJ6, nada canônico): Sarael (Chama), Nivael (Geada), Lumael (Luz), Shomael
  (Vigília) e, desde o AN-2 (2026-11-21), Velael (Véu), Galael (Maré) e Qeshael (Marca; ver "Anjos 5 a 7" abaixo), `AngelDef` em `data/angels/` (parte `angels`). Toda Bênção de sala e do guardião vem de dois anjos
  (`Encounter.pair` no dado da sala, `Encounter.dice`, sal 9241; a Bênção da loja segue o sorteio de antes); o anjo
  escolhido oferece até 3 Bênçãos da família (`BoonState.draw` com filtro, `Encounter.belongs`: o Elo pertence se uma
  das listas tem a família), raridade, troca, Elo e Salmo como antes, dado próprio por anjo (`cards_dice`). Só um anjo
  com carta: vem sozinho; nenhum: o Fôlego. `Encounters` (`game/encounters.gd`, `game.encounters`) conduz; gente vê a
  o Encontro (`EncounterScreen`, ver abaixo; a `AngelChoice` provisória só abre se ninguém ouvir `Encounters.opened`) e depois a `BoonChoice`; robô e `--autopick` escolhem por
  afinidade (`Encounter.affinity`). `--angels=a,b`, `--no-angels`.
- **Anjos 5 a 7 (AN-2, 2026-11-21)**: `Boon.Family` ganhou `VEU`, `MARE`, `MARCA` depois de `DUO` (os índices velhos não
  mudam; `FAMILY_COLOR/TAG/KEY`, `AngelSeal.TINT` e o selo desenhado em código acompanham; glifos 20 a 22 do `BoonIcon`),
  cada um com 9 Bênçãos como dado (`tools/make_data.gd` `_boons`, 42 a 68: ataque, especial, Brado, Investida, Ômega,
  passivas e 2 que agem sozinhas) e 6 Elos novos (69 a 74, 12 no total). Código novo, uma vez: **Fraqueza**
  (`weak_time` por golpe tagueado ou status `weak` de habilidade; o inimigo causa `Combat.WEAK_CUT` 25% menos, mais
  `weak_pct`, tampa em `DamageCalc.MAX_WEAK_CUT`; `Enemy.weak_t`, `Horde._out(e)` nos golpes corpo a corpo, avisos de chão
  e tiros; Morvath e o `boss.gd` não leem, ficam como estavam), **Marca** (`mark_time`/status `mark`: o marcado sofre
  `Combat.MARK_CRIT` 25% a mais de todo golpe, mais `crit_pct`; sem dado aleatório, a semente se mantém;
  `DamageCalc.marked`) e **empurrar** (`push_pct` multiplica o empurrão do golpe e marca `Enemy.shove_t` 0,6 s;
  `shove_pct` bate mais forte em quem ainda desliza; `DamageCalc.shoved`). Textos: `gloss_weak`/`gloss_mark` (Glossário,
  SR-H4), `fact_*` dos stats novos. Teste: `tests/test_an2.gd`. Números ao nível das Bênçãos atuais, a medir pelo
  `balance-designer`. Detalhe das 27 Bênçãos e dos Elos: `docs/design/rejogabilidade/sistemas.md` 4.1.
- **Save versão 6** (`materials`, `materials_total`; no herói `opened`, `forge`, `tools`): a migração abre de graça
  todo Dom que a Maestria já destravava e dá 5 de Prata por descida jogada, até 30 (Q-RJ8). `_fixed_keys` entra nos
  blocos com chaves conhecidas (`forge`). Fixture `tests/fixtures/save_v5.json`. **Registro e `RESULT` versão 5**:
  `materials` (por fonte e total), `forge`, `talents_opened`, `angels` (um por encontro: `room`, `node`, `offered`,
  `chose`, `cards`, `fallback`). Opções `--materials=silver:30,memory:5` e `--forge=N` (só na sessão).
- Testes: `tests/test_rejogabilidade.gd` (puros, A1, A3, A4, A6) e `tests/test_rejogabilidade_game.gd` (cena: o
  encontro, robô por afinidade, materiais por fonte, A2, Forjador).

## Rejogabilidade, Fatia 2 e DV-2 (gameplay; spec `sistemas.md` 1.5 a 1.7 e 3.6, API para a UI em 5.3 "Fatia 2"; testes em `tests/test_fatia2.gd`)
- **Portas (RJ-2, RJ-3)**: baralho de 21 (mais 2 `ENCHANT`, 1 `PSALM` e 2 `BOON`, para a Bênção manter a fatia de antes); grupos `RunMap.Group` POWER (Bênção, romã,
  Encanto, Salmo), BODY (coração, Magia, ouro, cura), HOME (Prata, Memória), `RunMap.group_of`; o gerador prefere a
  carta de um grupo que as portas irmãs ainda não mostram (`RewardDeck.draw_prefer`): bifurcações com dois grupos 77,8%
  para 93,9% em 1000 grafos, três grupos 3,8% para 9,4% (`tools/door_forks.gd`). Encanto no máximo 2 num caminho
  (`StageDef.enchant_max`), o segundo desde a sala 5 (`enchant_second_from`); Salmo desde a 4 (`psalm_from_depth`);
  `RunMap.settle(portas, romã, salmo, encanto)` troca por Bênção o que não pode vir. Caminhos com menos de 3 portas de
  Bênção 9,7% para 10,4%; encontros de dois 30% das salas de Bênção.
- **Anjo na porta (Q-RJ5 a)**: sala de Bênção é encontro de dois (`Room.meeting`: a sala 1, o guardião e 2 de cada 6,
  `StageDef.angel_deck`, dado próprio `RunMap.ANGEL_SALT`) ou mostra um anjo (`Room.angel`, sorteado ao abrir as portas
  por `Encounters.door_angel`); a placa diz o nome ou "Dois anjos"; o encontro abre direto nas cartas dele
  (`fallback` "door").
- **Encantos** (`EnchantDef`, `Enchants`, `data/enchants/`, parte `enchants`): Lâmina Tríplice (o giro solta 3 ondas
  em leque, `blow_wave_fan`, `Psalms.fan`), Eco da Verdade (o giro golpeia de novo 0,3 s depois com metade,
  `Combat._echo`, tag `echo`), Retorno do Corte (1 s depois do Corte Veloz o golpe alcança e abre 30% mais,
  `return_time`, `return_reach`, `Combat.swing_shape(..., largura)`); exclusões com os Dons (`excludes`); `BoonState.enchants`
  somados no `stat`; `Game.open_enchant_choice`, `take_enchant`, `enchant_offers` (dado da sala, `ENCHANT_SALT`), sinal
  `enchant_offered` (sem ninguém ouvindo, a `EnchantChoice` provisória); loja: Encanto 200 no grupo da Magia e da romã.
- **Porta de Salmo**: `Game.open_psalm_choice` (três Bênçãos, a primeira carta um Salmo elegível). O mapa nunca promete
  um Salmo que não vem: a carta de Salmo do baralho cai no mapa como Bênção (`Room.psalm`, nunca encontro de dois, desde
  a sala 4) e a porta só vira de Salmo ao abrir, quando um pode vir (`RunMap.settle(..., can_psalm)`, padrão `false`);
  antes o mapa mostrava o Salmo e a porta trocava por Bênção (o robô sem Dons nunca tinha um elegível). `--start=shop`
  é a loja antes de Morvath, nunca a de rota.
- **Forja**: Temperar III (60 Prata, +5% em `light` e `heavy`); Refinar (`Forge.REFINE`, 25 Prata, uma escolha por ação:
  Fio `reach_pct`, Peso `stun_pct` (novo: `Horde.stun_scale`), Pressa `blow_speed` (novo: `GiftState.attack_speed(tags)`)
  no ataque; Onda Larga, Onda Pesada, Onda Pronta no especial), aberto pela ferramenta `tool_refine` achada no primeiro
  guardião vencido (`Game.find_tool`, `tools_found`, guardada no fim como os materiais); `Forge.ranks_for(data)`,
  `--refine=a,b`. Save: `forge.refine`, `refined`, `inscribed` (`HERO_LISTS`).
- **Esmeralda**: 1 na fase 3 de Morvath alcançada, 1 na vitória (`MaterialPurse.SOURCES[EMERALD]` = `boss`).
- **Bênçãos novas** (todas sem ação, `Slot.NONE`, só estatísticas que existem; entram nas listas dos Elos): Geada Final,
  Flocos Errantes, Ômega de Gelo; Vigia Firme, Vigília Longa, Guarda Atenta; Ômega em Brasa, Chuva de Brasas; Final
  Radiante, Onda Clara (9 por família).
- **DV-2, loja de rota (MAP-09, Q-26 b)**: num ramo de uma camada de 6 a 8 (`StageDef.route_shop_*`, 35% por camada
  onde cabe, nunca na camada da fonte nem do altar, só em camada de 2 salas ou mais), 3 itens, um de cada grupo da
  loja (`Rooms._build_shop`, `RunMap.is_route_shop`); loja não gasta usos de arena (`_place_arenas`). `RESULT`
  `route_shop` à parte do `shop` (`RoomTally.shop_entered(ouro, rota)`). Robô entra com 100 de ouro ou mais
  (`Rooms.BOT_ROUTE_SHOP_GOLD`, `bot_door(..., ouro)`). Em 300 grafos, 45% têm a loja de rota.
- `RESULT`: `enchants`, `tools`, `forge.refine`, `route_shop`, `materials` com `emerald`.
- **Medido (72 sementes, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`)**: Encantos escolhidos 28 / 36 / 36%
  (Lâmina Tríplice, Eco, Retorno; meta 20 a 45%); 384 encontros, nenhum com menos de 3 cartas (meta: 95% com 3);
  171 de 384 pela porta de um anjo; ferramenta em 69 de 72; Esmeralda 2 em 47, 1 em 9. Porta de Salmo: o robô nunca a
  viu (a mão dele quase nunca abre um Salmo: `settle` a troca por Bênção). Robô 47 de 72 vitórias, vida em Morvath
  mediana 30 (Q-15: 58 e 51,5); a mesma queda aparece sem as portas da Fatia 2 (16 de 24, vida 30) e sem as Bênçãos
  novas (13 de 24): vem de o robô levar 0,3 coração por descida (0,61 no Q-15), RJ-3 põe Bênção ao lado de corpo e ele
  escolhe a Bênção. Para o `balance-designer` (`balance.md`). Loja de rota: o robô passa com 50 de ouro ou mais
  em 29% (sala 6), 62% (7) e 86% (8) das descidas, entra só com 100 (ou 50 ferido): 5 visitas em 72.

## Rejogabilidade, Fatia 3 "o fim de jogo" (gameplay; spec `sistemas.md` 1.5, 1.7 e 3.6; nomes de trabalho; testes em `tests/test_fatia3.gd`)
- **Ferramentas 2 e 3**: `Forge.TOOL_AWAKEN` na primeira fase 3 de Morvath alcançada (`Rooms.boss_phase`) e
  `TOOL_INSCRIBE` na primeira Provação vencida (`Rooms._fight_won`), guardadas como a primeira (`Game.find_tool`).
- **Despertar** (trilha `Forge.AWAKEN`, Esmeralda, um desperto por vez: `forge.awake`, `put_on`, `take_off(data,
  Forge.AWAKEN)`, lista `forge.awakened`): Sede (0,5 de vida por abate, 2), Ímpeto (3 de Magia a mais por finalizador,
  3), Eco Longo (o finalizador golpeia de novo 0,25 s depois com um terço, 4). Levado na descida pelo `ranks_for`;
  `--awaken=id`. **Inscrever** (trilha `Forge.INSCRIBE`, 20 Prata, o id do posto é o do Encanto, guardado em
  `forge.inscribed`, lido pelo `Enchants.learned`): os Encantos 4 a 6 (`EnchantDef.learned` falso; `INSCRIBED` no
  `make_data.gd`): Corte Sísmico (o giro solta um pulso de 4,5 m de 25, `ground_pulse`, `Combat._ground_pulse`, tag
  `pulse`), Onda Gêmea (o especial solta duas ondas de 15 em leque, `blow_wave_side` tira a do meio; nunca com a Onda
  Carregada), Eco do Passo (o Corte Veloz ecoa a metade em 0,3 s; nunca com o Retorno do Corte). `--inscribed=a,b`.
- **Discernimento** (`Discern`, `core/discern.gd`; `heroes.<id>.discern`, Memória 8 e 12, em ordem): I, uma vez por
  descida a escolha de Bênçãos na tela é sorteada de novo (`Game.can_reroll`, `reroll_choice`, `rerolls_left`, sinal
  `rerolled`; com anjo escolhido, as cartas da família dele por outro dado, `Encounters.reroll_cards`; nunca na porta de
  Salmo nem na romã); II, o que dão as salas uma camada depois das portas, com o anjo, numa linha do HUD (`Rooms._preview_angels`, `ahead_text`, somado à
  Obra da prévia). `--discern=N`. O botão na tela e a compra no Livro são do ui-ux-designer.
- **Obras e troca no Vendedor** (`Vendor`, `core/vendor.gd`; `ObraDef` em `data/obras/`, parte `obras`): abertas com a
  primeira encomenda entregue; Altar Restaurado (`altar_chance` 0,35, 40 Prata e 4 Memória), Fonte Viva
  (`fountain_heal` 0,55, 30 e 3), Banca da Rota (`route_shop_items` 4, 50 Prata e 1 Esmeralda), números do `StageDef`
  postos por cima no `Rooms.setup` (`Vendor.stage_for`); guardadas nas `oficios.recipes`; `--oficios=obra_x`. Troca com
  perda (`OficiosDef.trades`: 10 Prata por 1 Memória, 2 Memória por 5 Prata, 40 Prata por 1 Esmeralda; `Vendor.trade`).
  A folha do Vendedor é do ui-ux-designer.
- **Esmeralda por recorde de Peso**: vitória acima do melhor Peso dá 1 por degrau de 5 cruzado
  (`Juramentos.record_emeralds`, até 6), fonte `juramentos` do `MaterialPurse` (`RunAward.keep`).
- **Aba Anjos** (`AngelCodex`, `core/angel_codex.gd`; seção `codex.angels`: `met`, `chosen`, `blessed`, guardada pelo
  `RunAward.codex`; `entries`, `count`); a página é do ui-ux-designer (textos `codex_tab_angels`, `codex_angel_*`).
- RJ-11 (a Memória como as Cinzas) já está coberta pela Fatia 1 (a Memória abre os Dons).
- `RESULT`: `forge` com `awaken`, `discern`, `rerolls_used`; `materials.emerald.juramentos`; `tools` com as três.

## Ofícios, Roteiro A, "A Primeira Picareta" (gameplay; `docs/design/oficios/15_prototipo.md`, decisões Q-OF1 a Q-OF4 e Q-OF6 a; testes em `tests/test_oficios.gd` e `tests/test_oficios_game.gd`)
- **OF-05**: porta de Prata só da profundidade 4 (`StageDef.silver_from_depth`) e de Memória só depois da camada do
  guardião (`memory_after_guardian`), filtradas no `RunMap._may` como a romã; dado em `_oficios_stage` do `make_data.gd`.
- **Números** num recurso só (`OficiosDef`, `data/oficios/oficios.tres`, parte `oficios`): Picareta restaurada por 20 de
  Prata, Pedra Funda com teto 10, veios nas Fendas e nas Runas depois do guardião (no máximo 2 por descida, um aperto e
  `vein_hold` 1 s parado nele), sala da cabeça entre as profundidades 4 e 8, piedade depois de 2 descidas, encomenda do
  Vendedor de 2 Pedra Funda e 30 de Prata que faz a Obra 1 (`angel_preview`). Nomes de trabalho (Q-OF5).
- **Regras puras** em `Oficios` (`core/oficios.gd`) sobre o bloco `oficios` do save (versão 8: `items`, `items_total`,
  `finds`, `tools`, `orders`, `recipes`, `pity`, `seen`; saves 1 a 7 abrem com o bloco vazio, fixtures `save_v6.json` e
  `save_v7.json`): `noted`, `head_wanted`, `pity_due`, `add_item` (teto), `restore`/`restore_problem`, `order_state`
  (LOCKED até a primeira Pedra Funda, OPEN, DONE), `order_missing`, `deliver` (uma vez), `bank` (no fim da descida, pelo
  `RunAward.keep`, junto dos materiais e nas mesmas condições). A parte da descida é `OficiosRun` (`game.oficios`: do save,
  ou `--oficios=noted,pity,pick,preview` também para o robô; nada para o robô sem a opção, então o `RESULT` dele é o de antes).
- **Mapa**: `RunMap.mark_finds` (dado próprio, `FIND_SALT`, depois do grafo: o mapa e a partida não mudam) marca
  `Room.vein` (luta depois do guardião numa arena de `vein_arenas`) e, quando a cabeça é pedida (veio anotado, sem a
  cabeça nem a Picareta), `Room.find` numa sala de luta sem Provação; `view()` traz `find` e `vein`, o `summary()` traz
  `"find"`. Desde o DM-1 a placa da porta diz o achado.
- **Sala** (`Rooms`): vencida a sala marcada, a cabeça é achada ("Achado: Cabeça da Picareta", evento `find`); o
  guardião vencido a entrega por piedade (`head_by` "pity"). O veio (`VeinFloor`, `game/vein_floor.gd`, **placeholder**:
  bloco escuro com fio cinza, três estados, sem colisão; a peça é do environment-artist) aparece no
  `RoomLayout.gather_spots[0]` (Fendas (3,5; 7), Runas (0,5; -10), lugares provisórios para o room-designer) quando a sala é
  vencida: sem a Picareta, `use_kind` `vein_note` ("Anotar") e o aperto anota ("Anotado no Livro de Ahk"; só para gente);
  com ela, `vein` ("Extrair"): um aperto e 1 s parado nele (sair dele esquece) dá 1 Pedra Funda, até 2 por descida
  (`gather_s` conta o tempo). Robô com a Picareta vai ao veio antes da recompensa e das portas (`Rooms.bot_goal`).
- **Obra 1, Prévia dos anjos**: ao abrir as portas, as salas de Bênção (um anjo) atrás delas já ganham o anjo
  (`Rooms._preview_angels`, `Encounters.door_angel`) e a porta o guarda quando abrir e o HUD diz (`Rooms.ahead_text`).
- **Santuário** (folhas mínimas no `HubPanel`, `Hub._use_smith`, `_use_vendor`, sinal `Hub.oficio_done`): com o veio
  anotado o Forjador pede a cabeça e 20 de Prata ("Onde achar: atrás de uma porta da descida, com o nome na placa") e restaura; o Vendedor fica
  fechado até a primeira Pedra Funda, depois mostra a encomenda e entrega; a placa diz "Tem um pedido"
  (`Hub.station_line`). **Para o ui-ux-designer**: aba Oficina na Forja, folha da encomenda com marcas e números, Bolsa e
  Trazidos com a Pedra Funda, saudação "Achado", placa do veio com "Pede: Picareta", capítulo Ofícios no Livro.
- `RESULT` e registro (`RunLog.VERSION` 6): `oficios` (`finds`, `find_by`, `marked`, `gather`: `veins`, `stones`,
  `gather_s`, `noted`; `pity`: `due`, `passed_guardian`).


## Coragem e cura do Supremo (2026-11-24)
- Coragem (`scripts/core/courage.gd`, BL-02): cada morte na sala 5 ou antes dá à descida seguinte +3 de vida máxima e 1 romã (a primeira Bênção pega cresce um nível), até 3 pilhas; zera ao passar da sala 5, ao vencer ou com Juramento. Salvo por herói em `heroes.<id>.courage` (sem migração); nunca no robô nem em `--nosave`. Linha no início: `courage_start`.
- O Supremo cura `Game.ULT_HEAL` (10%) da vida máxima ao começar (`player.ult_started` em `game.gd`).

## Ultimate e Morvath curto (SW-O4/SW-O5, 2026-11-25)
- **Ultimate por marco**: `HeroLoadout.ultimate()` devolve `&""` até `Milestones.ult_open(data)` (6 descidas e Maestria 2 no `runs`/`mastery_xp`
  do Guerreiro; ou apresentada, `hub.presented` com `ult`). A ultimate em si segue abrindo na Maestria do `UltDef.mastery_level` (3 no dado
  hoje: a tabela do documento diz 2, o dado manda). O `Game` (3A1) e o 5º losango do `Hud` (3A3) devem fazer a mesma pergunta onde chamam
  `ult_for_weapon`.
- **Morvath curto** (`Boss`): `last_phase` (0 = todas as fases) e `hp_scale` (vida mantida, 1,0); com `last_phase > 0` a vida máxima é
  multiplicada por `hp_scale` e, quando a vida dessa fase acaba (a vida fica no piso dela), em vez de `_change_phase` ele entra em
  `State.TUTORIAL_END`: invulnerável, de joelhos (anim `stunned`), sem atacar, e emite `tutorial_end` (também `moment`/`cue` `tutorial_end`,
  `stats.tutorial_end`). Não emite `defeated`; quem ouve (o `Game`) toca o fim curto. Opção só de teste: `--boss-short` (fase 1, escala 0,6).
  Testes: `tests/test_boss_short.gd`.
