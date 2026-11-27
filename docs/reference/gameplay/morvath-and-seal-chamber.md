> Índice: [gameplay.md](../gameplay.md)

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
