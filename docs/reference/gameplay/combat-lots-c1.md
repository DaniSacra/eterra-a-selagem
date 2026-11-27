> Índice: [gameplay.md](../gameplay.md)

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
