# Descida, arenas, eventos e perigos de sala

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Descida de Valmor (DV-1, frente de gameplay: MAP-01, MAP-02, MAP-04; backlog seção "Descida de Valmor")
- **Grafo da descida** (`RunMap`, `core/run_map.gd`, puro; a API que as salas, as placas e o HUD leem está descrita no topo do
  arquivo): gerado no começo da descida num dado próprio (`Rooms.new_map`: `hash([semente da partida, Rooms.MAP_SALT])`;
  a mesma `--seed` dá o mesmo mapa, seja o que for que a partida sorteie antes). Desde o DM-1
  (2026-11-22, pedido do Daniel) ninguém vê o grafo e **toda sala tem 2 portas** (`RunMap.DOORS`): camadas 2 a 9 com 2
  salas, cada sala leva às duas da frente; só o segundo guardião, a loja (10) e Morvath (11) ficam atrás de uma. A camada do
  guardião (5 ou 6, GP-8) tem sempre o Cavaleiro e o Ancião lado a lado (`Room.guardian`). **Dois guardiões** (Daniel,
  2026-11-22, "enfrentar os 2 minibosses e só depois o boss"): o que ele não escolheu espera na 8 ou 9 (`miniboss2_depth`, pelo
  menos `miniboss_gap` 3 salas depois; `RunMap._leave_other` troca quando ele entra no primeiro), noutra variante do Santuário (que
  fica livre de lutas comuns até lá) e com escolta (`EnemyDef.escort`: Cavaleiro com 2 feiticeiros, Ancião com 1 Escudo, na segunda
  onda). A placa diz o nome do guardião e, desde o PT-8 (2026-11-23), o anjo que abençoa lá (`meeting` falso no guardião; `Encounters.door_angel(r, taken)` nunca repete o anjo da porta ao lado, `Rooms.shows_angel`). `--short` e `--medium` têm um só. Fonte: sempre uma das duas portas antes de cada
  guardião (GP-2; `fountain_more_chance`, hoje 0, põe outra depois dele até a 8); altar em no máximo
altar em no máximo
  um nó (2 a 8, 20% por camada), Provação num nó de luta marcado `trial` e `hidden` (até a laje aparecer,
  Q-25 a; `trial_chance` por nó, só onde a maldição mais curta cabe no pior caminho, nunca dois na mesma rota). Recompensas
  do baralho no gerador, camada por camada, nenhuma repetida na camada (então nunca em duas portas da mesma sala), romã só
  desde a sala 3 (`pom_from_depth`); ao abrir as portas, a romã que não puder subir vira Bênção antes da placa
  (`RunMap.settle`, `pom_turned`). Cada nó tem `fight_seed` (a mesma luta por qualquer caminho, `Rooms._prepare`). Arena
  por nó com as regras de antes valendo em toda rota (nunca a da luta anterior, o altar passa adiante a de antes dele;
  nenhuma mais de 3 vezes numa rota, contado por programação dinâmica; a menos usada primeiro; salas da mesma camada em
  arenas diferentes quando dá; a camada antes do guardião deixa o Santuário livre); o grafo é conferido
  (`_keeps_rules`) e gerado de novo se quebrar alguma (`failures`: 369 tentativas a mais em 1000 sementes, no máximo 5).
  `fights_left` (BUG-101) é o pior caminho: o menor número de lutas em qualquer rota até a loja. `--arena`, `--short`,
  `--medium`, `--start=` (o primeiro nó daquele tipo; `altar` gera o mapa de novo com o altar certo) e Juramentos seguem.
- **Portas = ligações** (MAP-02): `Rooms._enter` toma as portas do nó (`map.doors()`, porta i = `next[i]`); sala fora do
  grafo (testes) pega as portas do primeiro nó da profundidade. `door_info` ganhou `node`, `hidden`, `guardian_id` e
  `guardian_key`; `door_word` leva o guardião. A laje só aparece no nó `trial` (`Trials.open_at`) e revela o "?"
  (`RunMap.reveal`). `RESULT` e registro (`RunLog.VERSION` 4, `normalized` lê as versões antigas com `map` vazio e
  `node` -1): `map` (semente, nós `[profundidade, tipo, recompensa, arena, guardião?, "trial"?]`, arestas, caminho,
  `failures`, `pom_turned`), `rooms[].node`, evento `door` com `node` e `offered` e evento novo `reward` (o que a sala
  deu, ao lado do que a porta prometeu).
- **Tecla de usar na descida** (C19, Q-13, o Daniel pediu a letra na tela): recompensa, item da loja e porta só com
  `interact` (E, A no controle), parado neles (`Rooms.usable`, `use_kind`). Enquanto há algo para usar, a plaqueta
  da `StationSign` sem nome (só a tecla real e o verbo: "Pegar", "Comprar", "Entrar", `hub_use_reward`/`shop`/`door`)
  fica sobre a cabeça do herói (`Rooms.prompt`, `_step_prompt`; escondida fora do modo PLAY e para o robô); clique nela usa.
- **Robô**: `Rooms.bot_door(doors, altar_useful, life, gold)` escolhe só pelo gosto da porta da frente (com as duas portas
  levando às mesmas salas, olhar adiante não muda nada).
- **O que vem depois** (`Rooms.ahead_text`, `Hud.ahead`, ao lado de "Sala N de 11"): com as portas abertas, "Depois: Romã ou
  Fonte" para quem tem Discernimento II ou a Prévia dos anjos (uma camada cada). O achado procurado tem o nome na placa
  da porta (`door_text`, `door_find`).
- Testes: `tests/test_descent.gd` reescrito (BUG-109: só sementes fixas, contagem de asserções igual em toda rodada):
  1000 grafos com todas as regras, 100 sementes com pelo menos 95 grafos diferentes, pior caminho conferido por todas
  as rotas, 200 descidas do robô em que a sala é a que a placa disse, a recompensa dada numa sala real; mais
  `test_trial.gd` (500 grafos), `test_rooms.gd`, `test_economy.gd`, `test_altar.gd`, `test_e5_wiring.gd`,
  `test_run_log.gd`.

## Arenas (ciclo C12, Arenas I; plano em `docs/design/cycle12_arenas_plan.md`, plantas em `docs/art/cycle12_arenas_spec.md`)
- **Desde 2026-11-22 a descida tem 14 salas: quatro salas, minichefe na 5, quatro salas, minichefe na 10, duas salas, loja na 13 e
  Morvath na 14** (`StageDef.rooms` 13; minichefes fixos em 5 e 10, o segundo é o que ele não escolheu). `arena_max_uses` 4, arenas
  de meio de descida desde 0,4 do caminho (eram 0,5), `depth_ramp` 13, altar 2 a 11, Provação 2 a 11 (só onde cabem 3 lutas), fonte
  antes de cada minichefe, loja de rota 7 a 11 (20% por camada). Antes: 10 salas e Morvath na 11 desde a E3 (era a de teste de 7, D-27, hoje `--medium`): abertura no Salão das
  Catacumbas, lutas sorteadas entre a Cripta dos Esquecidos, o Salão das Fendas e o Jardim das Raízes Mortas (nunca a
  mesma duas vezes seguidas, nenhuma mais de 3 vezes, a menos usada primeiro, `RunMap._layout`, `RunMap.uses`),
  guardião na 4 a 6, fonte uma vez na 5 a 8 (no salão), loja na 10 (no salão), Morvath na 11. `--short` volta à de 5.
- Cada arena é dado no `_stage` do `make_data.gd` (`_crypt`, `_rift`, `_garden`): `RoomLayout` com `id`, `name_key`,
  `look`, tamanho, dificuldade, faixa da descida (`depth`), teto de inimigos (`max_alive`, `max_ranged`,
  `banned_roles`), chão `FloorShape.POLY` (polígonos menos buracos), obstáculos `ArenaObstacle` (círculo ou caixa
  girada; `blocks_move`, `blocks_shots`, `see_through`, altura e peça), zonas de nascimento (`spawns`, `late_spawns`
  só da 2ª onda), saídas `ArenaExit` (boca de 4 x 2,4 m além da borda, que só vira chão quando a porta é usada),
  caixa da câmera (`cam_bounds`) ou alvo fixo (`cam_target`), variantes `ArenaVariant` (outros obstáculos, outro chão,
  espelho). A mesma peça desenha e colide (`Arena._build_arena`). Regra do tiro: topo acima de 1,25 m bloqueia, até
  1,0 m passa por cima (o ramo rasteiro do sacerdote para em tudo que bloqueia corpo, `Arena.cover_low`).
- Movimento varrido (`Arena.sweep`, passos de 0,2 m) para herói, inimigos e corpos empurrados: nada atravessa buraco
  nem cai (D-28). Inimigos andam reto quando a linha está livre, senão pela grade `NavGrid` (0,5 m, folga 0,55) e pelo
  campo de fluxo `FlowField` (busca em largura fatiada, no máximo 4 vezes por segundo); o robô usa os mesmos. Atirador
  só prepara com linha de tiro livre e dentro de 5 a 95% da tela (`Horde._can_fire`); tiros morrem na pedra com faísca
  (`Projectiles.blocked`). O nome da arena aparece por 2 s ao entrar (`Hud.show_place`, chaves `arena_*`).
- Visual: `ArenaRoom` (`scripts/game/arena_room.gd`) monta o comum (chão em células de 8 m com `floor_look`, bordas por tipo
  `Edge` OUTER/HOLE/MOUTH com `broken_edge`, `balustrade_edge` (pontilhado nas bordas viradas para a câmera) e `filet` de
  ouro, peças de `ArenaObstacle`, portas com escada ou arco na parede `door_arch`, `key_light` sem sombra); cada arena
  sobrescreve `dress`, `air`, `floor_look`, `stone_tint`, `mist`, `cliff_look`, `edge`, `in_wall`. O ar de cada sala é
  aplicado por ela e devolvido ao sair (`ArenaRoom.leave_air` no começo de `Arena._build`, porque a sala nova se veste
  antes da velha sair da árvore). Peças de túmulo em `TombKit` (`scripts/game/tomb_kit.gd`, vindas do `BossChamber`, que
  ficou igual: sarcófago, espada em relevo, lanterna `Lamp`, pilarete, coluna inteira ou quebrada, mureta, túmulo
  grande, nicho, laje sem texto, grade). Estandarte com o leão do selo: `ArenaKit.banner(..., ArenaKit.Emblem.LION)`
  (`banner_lion.gdshader`, um material só); o salão e as arenas usam o leão, a Câmara do Selo a espada (`Emblem.SWORD`).
  Cripta (`crypt_look.gd`): paredes de 6,5 m com nichos ao norte e oeste, frente cortada a 0,9 m, ossuário divisor na
  variante B, feixe frio sobre o túmulo (`COLD_*`), 6 luzes com sombra. Fendas (`rift_look.gd`): pontes em arco de 5 m
  (`BRIDGES`; a de cima caída na variante B, com tocos e pedaços pendurados), balaustrada quebrada na borda oeste da
  fenda e filete de ouro na leste e no buraco, violeta de baixo (`DEEP_*`), arcos cegos nas paredes da fenda,
  fachada com pórtico, estátuas e estandartes, torre e correntes; 3 a 4 luzes com sombra. Correções F-1 a F-6 e G-1 da
  revisão (`docs/gallery/cycle12_maps/ART_REVIEW.md`; antes e depois em `work/fix_rift_*`): lábios quebrados (`broken_lip`,
  `LIP_*`: lascas da beira com as lajes do chão saindo da queda, falhas, pedras caídas), paredes de dentro e penhascos
  de fora na pedra das profundezas escura logo abaixo da beira (`CLIFF`), bruma violeta em três folhas dentro da fenda e
  dos buracos (`HAZE_*`, `rift_haze.gdshader`, saindo pela boca norte) e o violeta pintado na beira das lajes (sem luz);
  pontes com lajes próprias no sentido do vão, meio-fio claro, junta escura nas cabeceiras, parapeito vazado de 0,9 m,
  pilares de 1,4 m sobre os pegões (`DECK_*`, `KERB`, `PARAPET*`, `HEAD`, `ABUTMENT`; arco, enchimento e pegões na pedra
  escura); a lua faz a luz principal (sem a omni do meio, que deixava os cantos em metade); inscrições de ouro entre a
  fenda e o buraco (`INSCRIPTION_*`, `garden_inscription.gdshader`); no Compatibility ar mais neutro e bruma mais clara
  (`AIR_COMPAT`, `HAZE_COMPAT`). Nada disso muda colisão nem o `_rift` do `make_data.gd`. `tools/arena_lab.gd` imprime
  `SHADOWED LIGHTS`. Evidências: `docs/gallery/cycle12_maps/work/` (`before_*`, `w4_*`).
- Revisão de arte das arenas (`docs/gallery/cycle12_maps/ART_REVIEW.md`, 2026-11-16): Cripta e Jardim aprovados (a árvore
  fica, D-30), Fendas segurado até F-1 a F-3. Correções C e J: facho da Cripta 1,6 e tampa do túmulo no valor da pedra
  (`TOMB_LID_LIGHT`, `sarcophagus` sobrescrito só na Cripta; o `TombKit` e a câmara não mudam), colunas com capitel e aduelas,
  degraus no valor da cantaria (`Masonry.stairs(..., mat)`); árvore com camada própria (`StoneTree.LAYER` 32) e luz de
  preenchimento só dela (`GardenLook.TREE_FILL*`), casca torcida 100 graus com cordas desiguais, grão, líquen e fraturas, tocos
  quebrados (`STUBS`), cristais esmeralda corrompido escuro (`CRYSTAL_GLOW`), raízes com dois lombos e pontas abertas
  (`TIP_ROOTS`); compensação de luz no Compatibility por sala (`COMPAT_*` na Cripta e no Jardim). Para estas arenas o Daniel
  pediu variedade de salas, não fidelidade às imagens conceituais (2026-11-16).
  C12c (ENV-01 a ENV-03; evidências em `docs/gallery/cycle12c/work/env_*`): chão da luta na Cripta entre 45 e 60 longe das
  velas (lajes mais claras em `CryptLook.FLOOR`, a luz de cima mais alta, mais larga e de queda lenta, deslocada para as
  baías do oeste: `KEY_ENERGY` 1,8, `KEY_HEIGHT` 11, `KEY_FALLOFF` 0,5, `KEY_REACH` 26, `KEY_SHIFT`; sem luz nova, paredes
  continuam escuras); fraturas da árvore no marfim velho, nunca brancas (`fracture_color` 0,5 no `stone_tree.gdshader`);
  no Compatibility a lua do Jardim não faz sombra (`GardenLook.COMPAT_MOON_SHADOW`, menos 270 chamadas de desenho).
- **Pacote de direção de arte, etapa 4, cenário (2026-11-17, prancha `07-salas-combate.png`, só local em
  `docs/art/ref/direcao_2026-11-17/`; antes e depois na GPU em `docs/gallery/artpack/stage4/`)**: o desenho fica onde a
  colisão para. `tools/fit_probe.gd -- --arena=garden|rift [--variant=n] [--png=x]` mede numa grade de 0,1 m vista de cima
  o que está desenhado acima do joelho no chão livre (`phantom`), peça que bloqueia sem desenho (`bare`), chão sem
  superfície (`void`) e superfície de chão fora do chão (`ledge`). Jardim: o peitoril das janelas sai só `SILL_OUT`
  0,12 m da parede, o contraforte do canto noroeste corre ao longo do corte e a mureta quebrada fica `CUT_WALL_OUT` 0,8 m
  fora; as raízes desenham os lombos do tronco até o último ponto (`StoneTree.ROOT_BODY` 0,8 do perfil) e mergulham no
  chão nos `ROOT_PAST` 0,75 m depois (acima de 0,15 m até o fim quadrado da cápsula; o mergulho invisível não conta no
  `footprint`, `FOOT_SEEN`); musgo no chão ao longo das raízes, em volta do tronco e no pé das paredes norte e oeste
  (`GardenLook._moss`, `MOSS_*`, `root_moss.gdshader`: uma malha, um material, verde-cinza abaixo do valor das lajes;
  no Compatibility menos dele, `MOSS_COMPAT_COVER` 0,55).
  Fendas: lascas dos lábios um degrau abaixo do chão (`ArenaRoom.LIP_SINK` 0,2 a 0,42 m; eram 3 a 16 cm e liam como
  chão), balaustrada quebrada longe das pontas da borda (`BALUSTRADE_END`: passava por cima da cabeceira da ponte). Toda
  arena: os pilaretes da boca da porta ficam fora do chão, sobre as bochechas (`DOOR_POST_OUT`). Medido (m²,
  antes e depois): Jardim A fantasma 8,8 para 2,0, peça sem desenho 3,0 para 1,6; Fendas A fantasma 3,7 para 1,5, borda falsa 11,1
  para 5,1 (o que sobra fica nas bocas das portas e longe da borda). Placa de ouro da porta: a gema é uma moeda de pé
  girando (`Rooms.gem_mesh`, `GEM_COIN`; Bênção prisma, romã fruta). Câmara do Selo: meias-luas de Morvath em violeta
  frio com núcleo marfim-lilás (`Boss.SOUL_VIOLET`, `core_color` e `edge_pale` no `soul_crescent.gdshader`; o rastro e o
  ajuntar das almas também; eram o verde espectral) e a rachadura e os veios do selo descem a `SealLook.HUSH` 0,45 da luz
  enquanto ele prepara e lança um ataque (`hush_for`, chamado pelo `BossChamber.on_cue` nos avisos de foice, lâminas,
  tempestade, maldição, investida e runas; nunca na quebra do escudo nem na vitória). Testes em
  `tests/test_artpack_env.gd`.
- `RESULT` e o registro trazem `rooms` (por sala: profundidade, arena, vida ao entrar, dano por fonte, tempo e primeiro
  contato), `hp_at_boss`, `arena`, `stuck`/`stuck_by` (inimigo que queria andar e ficou 3 s parado) e `shots_blocked`;
  desde o C12c também os campos do GP-02 por sala e `boons_at_boss`, `shop`, `fountain_used` (ver Registro das partidas).
- **RP-07, variante pela profundidade**: cada variante tem a faixa da descida em que pode sair (`RoomLayout.variant_depth`
  para a A, `ArenaVariant.depth` para as outras; `RoomLayout.variants_at(progresso)`, a primeira quando nenhuma cabe); o
  `RunMap` sorteia só entre as que cabem, com o mesmo dado de antes (sem faixa, o mapa de antes). Faixas do room-designer:
  Fendas A 0,1 a 0,6 e B 0,34 a 1; Ponte A 0,5 a 0,8 e B 0,67 a 1; Runas B 0,5 a 0,8 e A 0,67 a 1 (`_stage`). A
  intensidade do perigo pela faixa (Runas A tardia mais densa) não entrou: é número. Teste
  `test_rp07_no_variant_out_of_its_band` (1000 grafos).
- **LR-03 (Santuário)**: a primeira onda nasce também no leste das duas naves laterais (`_rect(4, 12, 8, 12)`,
  `_rect(-2, 6, -12, -8.5)`). LR-04 (Jardim, atiradores ao norte do tronco) e LR-06 (Cripta B, muro de 12 m) foram
  provados e voltaram (sem efeito com o robô; números em `rooms_progression.md`). `--trace-thirds` soma em
  `rooms[].zones` os segundos do herói por terço da sala (`hero_x0..2` oeste a leste, `hero_z0..2` norte a sul) e dos
  inimigos (`foe_x0..2`); sem ela o `RESULT` é o de antes.
- Opções: `--hazards` (captura: todos os perigos da sala armados como no fundo da descida), `--arena=crypt|rift|garden|hall` (a primeira sala), `--variant=n`, `--short`, `--trace-steps` (imprime os
  passos acima de 4 ms e onde o tempo foi), `--trace-cam` (maior salto do alvo da câmera por sala, GP-06). Laboratório sem personagens, com grade, bordas, peças, zonas e câmera:
  `tools/arena_lab.gd` (comando no topo; `--top` vista de cima). Testes: `test_arenas.gd`, `test_descent.gd`,
  `test_killing_blow.gd`.
- **E5, cenário das arenas novas e das câmaras de evento** (`docs/art/e5_spec.md`; capturas em `docs/gallery/e5/env/`):
  cinco looks novos em `ArenaRoom.LOOKS`, escolhidos por `RoomLayout.look`, que desenham o `RoomLayout` que recebem
  (peças por `ArenaObstacle.piece`, nada do plano no código): `sanctuary` (`SanctuaryLook`, Santuário Desmoronado: nave
  de colunas, paredes norte e oeste com janelas cegas, presbitério elevado atrás da grade em frente ao `boss_spawn`, dois
  fachos de lua `moon_shaft` com poeira; variante B com o buraco para a cripta de baixo, `UNDER`), `bridge` (`BridgeLook`,
  Ponte dos Condenados: plataformas e pontes lidas do chão, polígono de 4 cantos até `DECK_WIDE` 5,2 m é ponte e o largo
  entre duas é o patamar da ponte longa da B; lábios quebrados ao norte, balaustradas nas outras bordas, estátuas nas
  cabeceiras, pilone `pylon` com correntes, bruma que corre de lado, `ArenaKit.mist_bank(..., drift)`), `runes`
  (`RunesLook`, Câmara das Runas Instáveis: chão em lajes de 3 m com moldura de ouro velho e marcas retas,
  `rune_floor.gdshader` = o chão das catacumbas com `#define RUNES` e `rune_tiles.gdshaderinc`; estado por laje numa
  textura 10 x 8 que o gameplay escreve: `set_tile(t, arm, fire, ember)`, `set_chevrons(dir)`, `apply()` uma vez por
  quadro, `tile_at`, `tile_rect`, `clear_tiles`, `heat`, `is_quiet`; a lâmina do disparo em `rune_flash.gdshader` sob o
  teto da tela, até 4 luzes âmbar sem sombra só no Forward+; pilares `rune_pillar` com sulcos que esquentam; estelas
  com marcas retas; laje quieta `quiet` da B lisa; nada redondo, D-29), `trial` (`TrialLook`, Provação: veias lilás
  `trial_veins.gdshader`, bloco `trial_block` com a rachadura em X `x_crack.gdshader`, um foco marfim com a única
  sombra, lanternas frias, `settle(s)` apaga 60%, `vein_level`, `SETTLED`; a laje de entrada na sala anterior é
  `TrialLook.entry_slab(pai, onde)`), `altar` (`AltarLook`, Altar Esquecido: arco cego com faixa gasta sem texto,
  leão em relevo na frente do `altar` (`altar_lion.gdshader`, o campo do selo), 11 velas apagadas, estandartes
  desbotados (um rasgado), facho frio; `kindle(s)` acende as velas com uma luz com sombra, `lit()`). Comum em
  `ArenaRoom`: a ponte e os lábios do Salão das Fendas (`bridge(r, ..., arches, open)`, `broken_lip`, `deck`, `parapet`;
  as Fendas não mudaram, antes e depois na GPU), `wall`, `wall_part`, `cut_wall`, `door_gaps`, `closed_edge` (sala
  fechada: parede ao norte e oeste, corte baixo na frente), `blind_window`, `round_column` (a coluna da Cripta),
  `drums`, `moon_shaft`, banco `TombKit.bench` (peças `bench`, `bench_broken`), toco `column_base`, `door_lamp()` e o
  bafo de luz da porta (`breath(i, look)`: cartão de 4 x 3 m na boca da porta usada, na cor do ar da próxima arena,
  `BREATH`, maior canal 0,6, sem luz; chamado quando as portas abrem). Plantas de laboratório com as medidas da spec em
  `tools/e5_layouts.gd` (`arena_lab.gd` cai nelas quando o estágio não tem o id; `--state=arm|fire|after` chama
  `demo`, `--measure=s` imprime `FRAME`); capturas em lote `tools/e5_shots.sh`. Sombras por sala no Forward+: santuário 5 (B 4),
  ponte 2 (B 1) mais a lua, runas 2 (B 3), provação 1, altar 2; no Compatibility os fachos `moon_shaft` não fazem sombra
  (`ArenaRoom.compat()`; listras). Quadro na GPU a 1080: 1,4 a 2,3 ms. Testes em `tests/test_e5_looks.gd`.

- **C18, a tela de um jogo acabado (cenário; antes e depois e a tabela de luma e saturação em `docs/gallery/c18/`)**:
  recompensas de verdade (QW-106): disco de ouro velho sobre pedestal da pedra do salão, o medalhão pintado
  (`assets/ui/events`: romã, selo da Provação, velas) ou a marca da `DoorGlyph` cunhada em esmalte da cor da recompensa,
  virado para a câmera e balançando devagar (`RewardGem`, `scripts/game/reward_gem.gd`, `reward_gem.gdshader`; halo
  `reward_halo.gdshader` abaixo do glow; um material por tipo, nenhuma luz própria); no `rooms.gd` só a chamada mudou
  (`Rooms.gem_mesh` saiu). Paleta num tom só: bruma, brilho e névoa do abismo e céu do salão menos saturados
  (`ArenaKit.MIST`, `ABYSS_*`, `RUIN_EDGE`, `Game.SKY`/`FOG`, `CatacombHall.ABYSS_LIGHT`, `BossChamber.ABYSS_COLOR`,
  `BLUE_COLOR`), metade das velas acesas que restavam no salão apagada, clareiras pálidas em todo chão
  (`clearing*` no `catacomb_floor.gdshaderinc`) e o ar de cada arena mais claro (`ambient_gain` e lua no `air()` de cada
  look), luz das portas acesas metade para um branco morno (`ArenaKit.DOOR_LIGHT_*`; o vermelho de Morvath fica inteiro),
  preenchimento das paredes do fundo na Cripta e no Santuário (`ArenaRoom.wall_fill`, `WALL_FILL`), Fendas, câmara e o
  ar da fase 4 (`RoomMood.LAST_BREATH`) violeta mas abaixo de 0,45 de saturação. Verdes de Morvath longe do herói: domo do ritual no matiz 165 (`BossShield.DOME_*`), erupções translúcidas com
  miolo vermelho até 0,35 sobre o que está atrás (`eruption_color`, `danger_alpha` no `ritual_rune.gdshader`, que agora é
  `blend_premul_alpha`; alfa até 0,24), runa de invocação no matiz 165 sem ciano (`color`, `spirit`), partículas espectrais até 0,12 m e nunca a menos de 1,5 m do herói (`Fx.CLEAR_OF_HERO`,
  `HERO_CLEAR_M`). Leitura do chão: Ponte B com o parapeito contornando o patamar (Q-10 a, `BridgeLook._read_floor`),
  Santuário B com `broken_lip` nos buracos, Runas B com a pedra quieta clara e um fio de ouro (`quiet_*` no
  `rune_tiles.gdshaderinc`); parapeito das pontes virado para a câmera em pontilhado em volta do herói
  (`ArenaRoom.faces_camera`). Runas (QW-108): preenchimento até 0,25 e âmbar acinzentado (`fill_*`, `fill_grey`,
  `heat_glow`), sulcos dos pilares em `rune_groove.gdshader` (`RunesLook.GROOVE_HEAT`). Colunas inteiras com ábaco
  quadrado, sem os arcos que liam como "Y"; no Santuário três silhuetas pelo lugar (capitel, capitel com imposta e anel,
  quebrada; `ArenaRoom.column_kind`, `IMPOST`, `ANNULET`, `COLUMN_BROKEN`; colisão igual). Câmaras da Provação e do
  Altar com ruínas em duas profundidades e bruma embaixo (`ArenaRoom.backdrop`, `BACKDROP_*`). Entulho do KayKit fora do
  salão (`CatacombHall._rubble`, `RUBBLE*`; as velas da pedra leste bloqueiam como se leem, `EAST_CLUTTER`), e o
  `tools/fit_probe.gd` conta também os círculos e caixas da própria sala (`Arena.overlaps`). Jardim: cristais escuros com brilho só na aresta
  (`crystal_edge.gdshader`) e copa de cartões procedurais (Q-21 a, `GardenLook._canopy`, `canopy.gdshader`, `CANOPY_*`,
  um MultiMesh, abre em volta do herói). Onda do especial 25% maior no desenho e rastro mais claro, acerto igual
  (QW-111, `look_scale`, `wake_light` no `emeth_wave.gdshader`). Medir uma captura: `python3 -I tools/frame_stats.py
  imagens... [--box=x,y,w,h]` (luma e saturação como o relatório de arte, violeta acima de 60%, verde e rosa na caixa). Com `--hue` (RS-0.5) sai uma tabela por região (quadro, `--scene` = sem HUD, x 5 a 95% e y 8 a 85%, e cada `--box`, que se repete): matiz médio circular pesado pela saturação HSV (o da matriz do redesenho), matiz p10/p50/p90 dos pixels acima de `--sat-min` (0,1), saturação HSV p50, luma p10/p50/p90 e as faixas quente, vermelho, verde, ciano, verde+ciano e violeta em % dos pixels (só biblioteca padrão e ffmpeg).
- **AP-1 "Nada de protótipo" (cenário; itens ART-01.2, 01.3, 01.4, 01.6, 02.3, 02.5, 03.7 e 04.2 do
  `docs/art/art_polish_backlog.md`; antes e depois na GPU e as medidas em `docs/gallery/ap1/`)**: o medalhão de cada
  recompensa tem o esmalte da família (`RewardGem.ENAMEL_*`: matiz, saturação e valor, teto `ENAMEL_MAX` 0,5 / 0,45;
  Bênção petróleo com a marca em marfim, Ouro sem esmalte, a própria moeda com serrilha, `all_gold`), a marca a 60% da
  face (`mark_size`, cada marca escalada pela própria extensão, `mark_extent`), disco de 2 m (`RADIUS` 1,0, cerca de 90 px
  a 1080) com o topo abaixo do pé da placa (`Rooms.MARK_SIGN_Y` 2,7), o halo atrás do disco na linha da vista
  (`HALO_BACK`; atravessando o disco ele velava meia face) e a face sem receber sombra. Onde se pega a recompensa ele
  pousa num relicário de pedra (`RewardGem.Stand`, `_reliquary`: degrau de pisar à frente, `STEP`, sobre o ponto do
  toque, que não mudou; corpo atrás, longe da câmera, `RELIQUARY` até 0,5 m; filete de ouro velho; pano petróleo com o
  leão de ouro velho, Q-22, `reliquary_cloth.gdshader`; haste e berço de ouro velho); sobre a boca da porta ele continua
  solto (`RewardGem.at_door`, pelo `Arena.door_label`). A chamada no `rooms.gd` não mudou (`Stand.AUTO`). Estela da
  Provação no lugar do cubo com X (`TrialLook._block`, `STELE*`, `SEAL`: pedra em pé virada para a câmera, rachada do
  ombro ao pé com a parte direita inclinada, o selo em relevo, a luz lilás só na fenda, `stele_crack.gdshader`; colisão
  igual). Câmaras de evento assentadas (`ArenaRoom.closed_edge`): a ponta da parede alta que encontra a frente baixa cai
  em degraus com entulho (`RUIN_END`, `RUIN_STEPS`, `_ruin_end`; só em canto de verdade, `_side_out`, `_low`) e além da
  frente baixa o chão continua quebrado sobre rocha que desce para a bruma (`_apron`, `APRON_*`, portas livres);
  Provação com luz só do chão (`TrialLook.FLOOR_FILL*`, `floor_layers`), céu, névoa, fundo e rocha mais claros
  (`AIR`, `CLIFF`, `BACKDROP_*`): luma 43 para 56. `tools/fit_probe.gd -- --arena=trial|altar` mede as câmaras. Fonte de pedra (`ArenaKit.fountain`, chamada pelo
  `Game._spawn_fountain`; bacia baixa em blocos, água escura com anéis e brilho pálido, `fountain_water.gdshader`, bica
  com taça e o borbotão marfim-azulado baixo; `fountain_spent` apaga a água quando ele bebe). Portal do salão com
  profundidade (`portal.gdshader`: oco escuro, anéis partidos que entram, veios, coração pálido pequeno, esmeralda
  escuro `body_saturation`, `body_value`, `body_tint`, teto `cap`). Braseiros sem miolo branco (`ArenaKit.FLAME*`,
  `FLAME_CORE` âmbar, chama um terço mais baixa, `BRAZIER_FIRE`; a luz igual). Janelas da Câmara do Selo em lanceta com
  caixilho, montante e travessa e luz em degradê (`far_window.gdshader`, `BossChamber.FAR_WINDOW_*`, um par aceso e um
  apagado; a janela da torre também).

## E5, eventos e exploração (spec de arte `docs/art/e5_spec.md`; métricas em `docs/qa/e5_metrics.md`)
- **Três arenas novas** no `_stage` do `make_data.gd` (`_sanctuary`, `_bridge`, `_runes`, duas variantes cada, dificuldade 2):
  Santuário Desmoronado (casa do guardião: `RoomLayout.guardian_home`, `RunMap._layout` manda o MINIBOSS para ela em qualquer
  profundidade se não foi a sala anterior; ele nasce em `boss_spawn` diante da grade; variante B com a nave afundada),
  Ponte dos Condenados (comprida, três plataformas e duas pontes de 5 m, portas só na plataforma leste, sem sacerdote,
  ninguém nasce numa ponte; B com a ponte longa e o patamar) e Câmara das Runas Instáveis (4 a 6 inimigos, no máximo 2
  atiradores, câmera fixa). Partes do chão com nome (`RoomLayout.areas`, `area_names`, `area_at`): o tempo do herói em
  cada uma vai para `rooms[].zones` do `RESULT` (`RoomTally.zone_time`); desde o RP-01 em toda sala de luta (Cripta
  `north`/`middle`/`south`, B `west_of_wall`/`east_of_wall`/`south_open`; Fendas `bridge_n`/`bridge_s`/`south_way`/`west`/
  `east`; Jardim `tree_shade`/`east_field`/`rest`; Runas A `pillars`/`middle`/`edge`, B `quiet`/`middle`/`edge`; números
  e leitura em `docs/design/rooms_progression.md`). Ponte A (RP-04): a luta nasce toda na plataforma leste e um bloco de
  ruína (`block` 1,0 x 2,4 m, 2,2 m) fica 1,5 m depois do fim da ponte 2; Fendas A (RP-05): três tocos de coluna de 1,5 m
  (barram tiro), um de cada lado da fenda entre as cabeceiras e um na luta do leste. Desenhadas pelos looks do E5 (ver a seção de
  cenário acima; o `PlainLook` provisório saiu). Peças do dado com o nome que o look desenha: `column` (5 m ou mais ganha
  capitel), `column_base` (toco, para corpo e não tiro), `drums`, `bench`/`bench_broken`, `pylon`, `rune_pillar`, `quiet`
  (a pedra quieta da B das Runas, caixa que não barra nada), `trial_block`, `altar`; braseiros de parede (`brazier`) a 0,9 m
  ou mais fora do chão, os da grade do Santuário são do look. Cada porta que abre sopra o ar da sala de trás
  (`ArenaRoom.breath`, `Rooms.door_look`; Morvath = `chamber`). Opções: `--arena=sanctuary|bridge|runes`, `--start=trial|altar`.
- **Runas** (`HazardDef` no `RoomLayout.hazard`, lógica pura `ArenaHazard`, no jogo `RuneFloor`): grade de 10 x 8 ladrilhos
  de 3 m; padrões só em faixas e ladrilhos (A: `sweep`, `comb`, `cut`; B: `checker`, `frame`, `islands` e a pedra quieta no
  meio); aviso 1,2 s, golpe 0,25 s, descanso 2,4 s, nada nos 3 s do começo, nas portas nem em ladrilho cortado pela borda;
  nem em ladrilho com chão a menos de 6 m da entrada (RP-02: `RUNES_ENTRY` no `make_data.gd`, somado ao `HazardDef.quiet`
  das duas variantes, só regra, o `RunesLook` não pinta; GUT com 2000 padrões por variante em `test_hazard.gd`);
  no máximo 35% aceso (os densos, 50%, só com até 3 inimigos de pé) e todo ladrilho aceso tem um vizinho apagado. Fere o
  herói 7 (RP-03 passo 1, era 4; o Hades fere 10 sobre os mesmos 30 de vida; como aviso, `Ground.add_hazard`) e todo inimigo
  comum em cima 60 (era 35; `Ground.hazard_landed`); "Derrotado por: Runas
  Instáveis" (`killer_runes`). Desenho: estilo `GroundLook.Style.HAZARD` (âmbar `HAZARD_COLOR`, moldura por ladrilho
  `tile_m`, preenchimento fraco, `render_priority` -1, abaixo dos avisos vermelhos), mas na sala de verdade quem desenha é o
  próprio chão: o `RuneFloor` escreve a cada quadro o estado de cada ladrilho no `RunesLook` (`RuneFloor.paint`:
  `ArenaHazard.state` = preparo, golpe e brasa de 0,4 s, `ArenaHazard.EMBER`; divisas da varredura por `ArenaHazard.chevron`
  só no preparo; um `apply`, nada quando em repouso) e os avisos do `Ground` ficam invisíveis (`add_hazard(..., drawn)`,
  nada desenhado duas vezes; continuam ferindo). Grade conferida contra o look (`RuneFloor.fits`, 10 x 8 de 3 m desde
  (-15; -12)); em outro look o âmbar volta. `rooms[].hazard` no `RESULT`, com `patterns` (até 16
  `[segundo da sala, padrão, ladrilhos acesos]`, `RuneFloor.patterns`, AT-RB2). Som: `rune_arm` ao armar e `rune_crack` no
  golpe, um por padrão (ver o som do combate).
- **Laje Rachada (RP-06, H-2; RP-13; plano e medidas em `docs/design/rooms_progression.md`)**: segundo tipo de
  `HazardDef` (`kind` `GRID` as Runas, `PLATES` as lajes; campos `plates`, `rearm`, `from_progress`, e por laje
  `plate_hero_damage` e `plate_push`), dado no `_stage` (`_plates`, `PLATES_FROM` 0,34). Lajes de 3 x 3 m que qualquer
  um arma ao pisar (herói ou inimigo, como o vapor do Hades II): 1,0 s de aviso acendendo da borda para o meio, golpe de
  0,25 s em quem está em cima (herói 7, inimigo 60, os números do RP-03), recarga 5 s; nada nos 3 s do começo, nada em
  laje na boca de porta, no máximo 2 armadas ao mesmo tempo (`PlateHazard.MOST_AT_ONCE`, R9); antes do progresso 0,34 (salas
  2 e 3) ficam desenhadas e dormem. Lógica pura `PlateHazard` (`core/plate_hazard.gd`), no jogo `PlateFloor`
  (`game/plate_floor.gd`, criado por `Rooms._start_hazard` em luta e no guardião): o golpe é o `Ground.add_hazard(...,
  drawn = false, Ground.PLATE_SOURCE)`; o desenho é dele, um nó por laje pendurado na arena (`GroundLook.plate`,
  `set_plate`: moldura e duas rachaduras em osso apagado em repouso, `PLATE_REST_COLOR`, nunca âmbar; armando, o âmbar das
  Runas entrando da borda; `plate` e `crack_m` no estilo HAZARD do `ground.gdshaderinc`; placeholder até a peça do
  `environment-artist`, SW-G7). Onde: Cripta A (quatro, junto das paredes, fora dos corredores do sarcófago), Cripta B
  (duas no pé do muro divisor), Santuário A e B (duas em cada nave lateral). RP-13, a borda que desmorona (Santuário
  B): duas lajes nas pontas do buraco ferem 5 e jogam todos 2,5 m para longe dele (`plate_push`, por `Arena.sweep`,
  ninguém cai), zona `hole_edge`. "Derrotado por: Laje Rachada" (`killer_plates`, nome provisório para o Daniel); som
  `plate_arm`/`plate_fire` = `rune_arm`/`rune_crack`. `rooms[].hazard` com `kind` `plates`, `hero_damage`, `enemy_damage`,
  `kills`, `strikes`, `armed_by_hero`, `armed_by_enemy` e `hero_on_s` (segundos dele em cima); o das Runas ganhou
  `hero_damage`. Testes em `tests/test_plates.gd` (ritmo, inimigo arma, dormente, porta, duas de cada vez, lugares
  contra chão, peças, portas, nascimentos e 6 m da entrada, saída andando de 12 x 12 pontos, sala real, empurrão).
- **Corrente da Ponte (RP-11, H-3; `docs/design/rooms_progression.md`)**: terceiro tipo de `HazardDef` (`LINE`: `bands`,
  `band_push`, `cycle`), faixas que golpeiam uma por vez e em ordem no relógio da sala (`BandHazard`, `core/band_hazard.gd`;
  no jogo `BandFloor`, `game/band_floor.gd`, pelo `Rooms._start_hazard`, `Rooms.bands`): 3 s de calma, uma a cada 6 s,
  aviso 1,2 s desenhado como a faixa âmbar (`Ground.add_hazard`, `Ground.CHAIN_SOURCE`; placeholder até a corrente do
  `environment-artist`), golpe 0,25 s de 7 no herói e 60 no inimigo, empurrão de 2,5 m ao longo da ponte para a
  plataforma (`PlateFloor.strike`, comum às lajes); faixa na boca de porta nunca golpeia. Ponte A: uma faixa de 2 m em
  cada ponte, alternando; B: as duas metades da ponte longa, a 6 m do patamar (`_chain`, `CHAIN_PUSH` no `make_data.gd`).
  "Derrotado por: Corrente da Ponte" (`killer_chain`, provisório); `rooms[].hazard` `kind` (`band_source`), `hero_in_s`; som
  `chain_arm`/`chain_fire` = os das Runas. Testes em `tests/test_chain.gd`.
- **Fenda que respira (RP-08, H-4)**: o `LINE` sem dano nas Fendas (`HazardDef.band_source` `breath`, `Ground.BREATH_SOURCE`;
  `_breath`, `RIFT_BREATH` no `make_data.gd`): quatro trechos da beira onde a luta acontece, um por vez a cada 7 s, o
  com mais inimigos primeiro (`HazardDef.band_busy`, `BandHazard._busiest`), aviso 1,2 s, empurrão de 2,5 m para longe
  da beira que corta a preparação ou o ataque de quem foi empurrado (`PlateFloor.strike(..., cut)`; nunca investida
  imune nem guardião); o aviso do chão sem dano não fere (`Ground.Zone.floor_own`: aterrissa e avisa `hazard_landed`
  mesmo sem dano, `hit_player` só com `power` acima de 0). Som `breath_arm` = `rune_arm`, `breath_fire` = `dodge`.
  `rooms[].hazard` `kind` `breath` com `pushed` e `cut` (a corrente também). Testes em `tests/test_breath.gd`.
  **S (2026-11-25, RD2-04c)**: o respiro agora fere 10 só em inimigo (`BREATH_ENEMY` no `make_data.gd`, `enemy_damage` 10, `hero_damage` 0; o
  corte da preparação continua, `BandFloor._on_landed`); chave "Derrotado por" é a do `breath` do `DefeatCause`.
- **Coluna rachada que tomba (RP-09, a árvore que cai do Érebo do Hades II)**: `ArenaObstacle.hits_to_fall` (0 = nunca),
  `fall_length` 5, `fall_width` 1,2, `fall_time` 0,6, `fall_damage` 50 (`_cracked` no `make_data.gd`): Santuário A e B
  (15; -6) e (-9; 6), Jardim A (4,5; 7), Cripta B (6,5; -6). Só os golpes do herói contam (`Combat.reached`: forma,
  origem, direção, alcance e largura de todo golpe do combo com dano; `ColumnFall.touches`): o 1º racha, o 2º tomba
  para onde o golpe foi (nunca de volta nele): faixa âmbar de 1,2 x 5 m por 0,6 s enquanto inclina
  (`Ground.add_fall`, `FALL_SOURCE` `column`, sem `power`), 50 a todo inimigo cujo corpo toca a faixa
  (`PlateFloor.strike(..., bodies)`), nada ao herói; fica o toco no mesmo lugar (para corpos, não tiros: sai do
  `Arena.cover`; a grade de andar não muda). Uma vez por coluna por sala. Lógica pura `ColumnFall`
  (`core/column_fall.gd`), no jogo `ColumnFloor` (`game/column_floor.gd`, criado pelo `Rooms._start_hazard` em luta e
  guardião, `Rooms.columns`); `rooms[].columns` (`cracked`, `toppled`, `enemy_damage`, `kills`). Som `column_crack` =
  `rune_crack`, `column_fall` = `boss_down`. Robô: vai a uma coluna a até 10 m que cairia sobre um inimigo ou mais,
  contorna para o outro lado e golpeia na direção do bando (`Bot.column_plan`, `COLUMN_*`). **Visual provisório, para o
  environment-artist**: as malhas da coluna ficam fora do `merge` (`ArenaRoom.toppling`, `Masonry.take_since`) sob um
  pivô no pé; a racha só balança 3 graus com poeira, o tombo gira o pivô até 82 graus em 0,6 s e ao bater ela some e
  aparece um `TombKit.column` quebrado baixo com poeira ao longo da faixa e tremor. Falta: racha desenhada na pedra
  (fissura que acende ou abre no 1º golpe), a coluna caindo de verdade (tambores se separando, pedaços rolando na faixa,
  a coluna deitada ou em pedaços no chão depois, sem colidir), o toco com a quebra (topo irregular, lascas em volta) e
  pó mais grosso no impacto; nada pode mudar a colisão nem a faixa. Testes em `tests/test_columns.gd`.
- **Raiz que golpeia (RP-10, H-1)**: as lajes do RP-06 ganharam faixas giradas (`HazardDef.strips`: segmentos de `a` a
  `b` com `strip_width` 3 m, numerados depois dos retângulos; `PlateHazard.on`, `bounds`, `from`/`dirs`/`lengths`/`widths`),
  espera para armar (`dwell`: segundos que alguém fica em cima; 0 nas lajes), empurrão para longe da linha do meio
  (`push_out`; `PlateFloor.strike(..., out)`, `PlateFloor.away`) e nome próprio (`plate_source`; sons `<nome>_arm` e
  `_fire`, as lajes seguem `plate_arm`). Jardim (`_roots` no `make_data.gd`): as duas raízes de fora de cada variante
  (A: a do norte e a do oeste, cortada antes de 6 m da entrada; B: a do oeste, cortada, e o toco junto da parede oeste),
  faixa da face do tronco até a ponta; quem fica nela acorda (herói 0,5 s, inimigo 0,2 s, `HazardDef.enemy_dwell`): 1,2 s de aviso âmbar com poeira,
  golpe 0,25 s de 7 no herói e 60 no inimigo, empurrão de 1 m para fora da raiz, 6 s até acordar de novo; dormente
  antes da sala 4 (`PLATES_FROM`). `Ground.add_band` (o `add_hazard` sobre qualquer faixa), `GroundLook.plate_band`
  (placeholder: a moldura da laje ao longo da raiz; a raiz que racha é do environment-artist), `Ground.ROOT_SOURCE`
  `roots`, "Derrotado por: Raiz Morta" (`killer_roots`, provisório para o Daniel). `rooms[].hazard` `kind` `roots`. A 1ª onda nascendo a oeste e ao sul do tronco foi provada e voltou (2026-11-20: pátio do Jardim a 9% na A e 15% na B, meta 20%; `rooms_progression.md`).
  Testes em `tests/test_roots.gd`.
- **Seteira ligada à laje (RP-16)**: uma laje do RP-06 com `HazardDef.aims[i]` (segmento da boca da seteira até onde os
  virotes param, `aim_width` 1 m; `aims_away(i)`) arma a seteira em vez de golpear a si mesma: a faixa da seteira avisa
  1,0 s em âmbar desenhada (`Ground.add_band`, `Ground.SLIT_SOURCE` `slit`) e golpeia quem está nela (7 no herói, 60 no
  inimigo), recarga 5 s pela laje. Cripta B (`_slit`, `SLIT_WEST`, `SLIT_EAST` no `make_data.gd`): uma seteira na parede
  norte de cada lado do muro divisor, peça `bolt_slit` de 0,5 x 0,6 m e 1,2 m (barra corpo e tiro; bloco provisório até a
  seteira com a divisa do environment-artist), atirando para o sul até a fileira dos sarcófagos; a laje de um lado arma a
  seteira do outro. "Derrotado por: Seteira" (`killer_slit`, provisório), som `slit_fire` = `bolt`; `rooms[].hazard` com
  `slit_damage` e `slit_struck`. Robô: pisa na laje a até 8 m quando 2 inimigos ou mais estão na faixa e ele não
  (`Bot.slit_plan`, `in_band`, `SLIT_*`). Testes em `tests/test_slits.gd`.
- **Aviso de área padronizado (SR-P4, lote 3, 2026-11-21)**: um só estilo de aviso de área no chão, o do inimigo comum:
  vermelho de aviso (`GroundLook.WARNING_COLOR`), contorno limpo de `RIM_METERS`, chão fraco subindo até `FILL_MAX`
  (0,35). Passaram a usá-lo os perigos que eram âmbar com moldura por ladrilho: corrente, respiro, seteira, raiz, nicho,
  planta, laje armando, pedras, urna, óleo e a armadilha de parede (`GroundLook.HAZARD_COLOR/STRENGTH/RIM` agora são as do
  inimigo; só a prioridade de desenho continua abaixo dos avisos dos inimigos). Seguem como estavam, de propósito: os
  ladrilhos das Runas (`RunesLook`, peça própria), a assinatura violeta dos avisos de Morvath (contorno e preenchimento
  já eram os padrões; só o fio e as runas são dele) e a mira fina do besteiro (`GroundLook.aim`, é uma mira, não uma
  área). Já usavam o padrão: círculos de atiradores e mágicos, cone do soldado, golpes de chefe.
- **Armadilha de parede (SR-P1, lote 3)**: bloco na parede que lança lâminas numa faixa de 1,2 m. É um `HazardDef`
  LINE com `band_source` `trap` (a corrente sem empurrão): `bands` são as linhas, `band_dir` o sentido (`band_dir_of`),
  `band_busy` faz a linha com mais inimigos ir primeiro (atrair o bando), `from_progress` a deixa dormindo (o bloco
  fica, nada voa; `BandFloor(awake)`). 1,2 s de aviso na faixa (padrão P4), 10 no herói, 60 no inimigo, calma de 5 s,
  uma linha por vez. O bloco é o obstáculo `trap_block` (corpo e tiro, 1,2 x 0,6 m) com a peça da seteira (`HazardPiece.slit`,
  boca acendendo, três chevrons no sentido do tiro; placeholder). Fonte `Ground.TRAP_SOURCE`, "Derrotado por: Armadilha de
  Lâminas" (`killer_trap`), sons `trap_arm`/`trap_fire`, `rooms[].hazard.fired`. Dado: `_trap`, `_trap_blocks`,
  `GARDEN_TRAPS`, `SANCTUARY_TRAPS` no `make_data.gd`: Jardim A (2 linhas, desde 0,3, ciclo 6 s), Santuário A (3 linhas,
  desde 0,5, ciclo 4,5 s) e C Colunata (2). Testes em `tests/test_traps.gd`. Plano e métricas em `rooms_progression.md`.
- **SR-P2, P3, P5 e a armadilha mais dura (2026-11-21, room-designer)**. Dois campos novos no `HazardDef` valem para
  qualquer perigo `LINE` ou `PLATES`: `late_from` (0,7 da descida), `cycle_late` e `rearm_late` (`cycle_at(p)`,
  `rearm_at(p)`; `BandHazard` e `PlateHazard` recebem o progresso e guardam `cycle`/`rearm`). Só o descanso encurta; o
  aviso e a duração do golpe nunca mudam. `Rooms._start_hazard` agora percorre toda a cadeia `also` (um slot por tipo:
  até 2 `PLATES`, 1 `LINE`, 1 de cada o resto; `test_hazard_sr.gd` trava).
  **Laje que cede** (`plate_source` `sag`, `_sag`): `PLATES` com `dwell` 0,7 s (inimigo 0,35 s), aviso 1,4 s (mais longo
  que o dos inimigos: dá para sair), 10 e 60, descanso 8 s (6 s desde 0,7), calma 5 s, dormente antes de `from`. Peça
  `HazardPiece.Kind.SAG` (a laje do RP-06 sem setas: rachaduras, poeira e o afundar). Fendas A (2 lajes a leste, desde
  0,4) e Santuário A (3 lajes, desde 0,5; é a casa do guardião). **Grade de fosso** (`band_source` `spikes`, `_spikes`):
  `LINE` em quadrados de 2,4 m, uma por vez, a com mais inimigos primeiro (`band_busy`), aviso 1,2 s, espinhos de pé 1,0
  s, ciclo 3,5 s (2,8 s desde 0,7), 10 e 60. Peça `Kind.GRATE` (moldura de ferro, fosso escuro, 16 espinhos que
  espiam a 25% no aviso, sobem cheios no golpe e recolhem; placeholder). Cripta A e B (desde 0,4) e Santuário B (desde
  0,55). Fontes `Ground.SAG_SOURCE`/`SPIKES_SOURCE`, "Derrotado por: Laje que Cedeu" e "Grade de Espinhos", sons
  `sag_*`/`spikes_*`. **Armadilha de parede mais dura**: linha de 1,6 m (era 1,2), Santuário A e C ciclo 3,5 s (era 4,5)
  e 2,8 s desde 0,7; Jardim A 5 s e 4 s (era 6). **Relíquia na pedra (SR-P5)**: `RoomLayout.relic_spots` (Cripta,
  Fendas, Jardim, Santuário), `StageDef.relic_*` (50% das lutas desde a sala 3, dados da própria sala: nunca os da
  descida), `RelicFloor` (pedra com anel claro, placeholder), `Rooms._relic_cleared/_step_relic`: depois da luta, F
  junto dela dá 30 de ouro ou 6 de Prata Antiga (sorteio da sala), uma vez; o robô vai até ela antes da recompensa.
  Texto de trabalho (`hub_use_relic` "Tocar"); **tema a confirmar com o Daniel**. Testes: `tests/test_hazard_sr.gd`.
- **Mureta (RP-17)**: só dado, caixas baixas de 0,9 m (`_capsule(..., 0.5, 0.9)`, peça `block` desenhada como mureta
  baixa; o corpo dá a volta, o tiro passa por cima): Cripta A uma de 5,5 m ao sul do túmulo grande ((-3,5..2; 3,8));
  Jardim A duas quebradas num arco a 6 m do tronco (`_low_arc`: leste de -6 a 21 graus, sul de 64 a 98), as raízes que
  cruzam o arco as três entradas de 4,5 m. Testes em `tests/test_low_walls.gd`.
- **Lote A, frente A1 (2026-11-21; `docs/design/rooms_progression.md` seção "Lote A, frente A1"; critérios em
  `docs/design/combat_cadence.md` 9), valendo sobre os números acima**: todo perigo de sala tira 10 do herói
  (`HAZARD_HERO` no `make_data.gd`; era 7) e a borda que desmorona 7 (`CRUMBLE_HERO`; era 5); inimigos seguem 60.
  Laje Rachada com aviso de 1,2 s (era 1,0; P0 do combat-feel-director com o 10). **R9, dois avisos de sala no máximo**:
  `PlateHazard.MOST_AT_ONCE` 2 (era 3) e contado com os outros perigos da sala (`PlateHazard.step(..., others)`,
  `Ground.room_live` e `room_rects` sobre `Ground.ROOM_SOURCES`; um padrão das Runas ou uma descarga conta um). **Dois
  perigos na mesma sala**: `HazardDef.also` (Santuário B lajes e pedras, Fendas B fôlego e pedras, Cripta A lajes e
  urnas), iniciado pelo `Rooms._start_one`; o `RESULT` guarda o segundo em `rooms[].hazard.also`
  (`RoomTally.hazard`, `hurt_in_room`).
- **Cristal Instável (RP-14, H-5)**: campos `crystals`, `crystal_cols`, `crystal_hits` 3, `crystal_radius`,
  `crystal_from` no `HazardDef` GRID; Runas B com dois cristais fora do chão junto da parede norte, (-4,5; -12,6) na
  coluna 3 e (10,5; -12,6) na coluna 8. Cada golpe do herói que toca um cristal o carrega (`Combat.reached`,
  `ColumnFall.touches`; nada nos 3 s do começo nem com uma descarga no chão); no 3º ele descarrega na hora pela coluna
  (`ArenaHazard.discharge`: só ladrilhos que podem acender, nunca a pedra quieta, a entrada nem porta; 1,2 s de aviso
  com as divisas para o sul, golpe das Runas, 10 / 60; o padrão das Runas que esquentava apaga sem golpear, nunca dois
  no chão), e da 2ª carga a coluna fica um degrau mais clara em repouso (`ArenaHazard.hint`, `RuneFloor.HINT` 0,3).
  Lógica pura `CrystalHazard` (`core/crystal_hazard.gd`), no jogo pelo `RuneFloor` (marca provisória: uma laje de
  1,6 x 0,8 m no chão diante de cada cristal, `GroundLook.plate`, acende com a carga). "Derrotado por: Cristal
  Instável" (`killer_crystal`, provisório), sons `crystal_charge` = `ward`, `crystal_arm`/`_fire` = os das Runas;
  `rooms[].hazard` com `crystal_charges`, `discharges`, `crystal_damage`, `crystal_kills`, `crystal_hero_damage`. Testes
  em `tests/test_crystals.gd`.
- **Pedras da Abóbada (RP-20)**: `HazardDef.Kind.DROPS` (`drop_zones`, `drop_size` 2, `drop_count` 2, `drop_every` 4,
  `drop_aim` 0,5; `_rocks` no `make_data.gd`, desde a sala 4): quadrados de 2 m caindo um a cada 4 s depois dos 3 s,
  metade mirada nele quando está numa zona, 1,2 s de aviso (o quadrado inteiro desde o primeiro quadro, o âmbar das
  Runas enchendo; a pedra cai nos últimos 0,25 s e toca o chão no quadro do golpe), 10 / 60; nunca sobre outra pedra,
  outro aviso da sala, porta nem fora do chão, e nunca com a sala já com dois avisos (R9). Entulho só desenhado por
  3 s (não para corpo). Santuário B: a nave em volta do buraco (x -8 a 13); Fendas B: a plataforma leste (dois
  retângulos). Lógica pura `DropHazard` (`core/drop_hazard.gd`, dado próprio pela `fight_seed` do nó), no jogo
  `DropFloor` (`game/drop_floor.gd`; pedra provisória em caixa cinza, poeira caindo, tremor). "Derrotado por: Pedras da
  Abóbada" (`killer_rocks`, provisório), sons `rocks_arm` = `rune_arm`, `rocks_fire` = `boss_down`; `rooms[].hazard`
  `kind` `rocks`, `hero_in_s`, `aimed`. Testes em `tests/test_rocks.gd` (também o R9 das lajes).
- **Urna de Óleo (RP-12, o barril do Hades II)**: `HazardDef.Kind.URNS` (`urns`, `urn_radius` 2,5, `urn_flows`,
  `flow_*`, `burn`; `_urns`, `_urn`, `CRYPT_URNS`, `CRYPT_OIL`, `URNS_FROM` 0,67): Cripta A, duas urnas de bronze ao pé
  das paredes leste (11,2; -1,6) e norte (-1,6; -10), peça `oil_urn` de 0,45 m e 1 m (barra corpo, tiro passa;
  desenho genérico até a peça do environment-artist). Um golpe do herói acende: o aro de 2,5 m inteiro em âmbar desde o
  primeiro quadro (`Ground.add_round`, `GroundLook.hazard_round`, ramo novo do estilo 3 no `ground.gdshaderinc`) por
  1,3 s (P0 do combat-feel-director) e explode 10 nele e 80 em cada inimigo; o óleo corre pelo canal a 3 m/s em trechos
  de 2 m, cada um avisado 1,0 s antes da chama (faixa âmbar desenhada), 5 nele e 40 no inimigo quando a chama chega, e
  arde 2 s (quem entra leva uma vez por trecho). Uma vez por urna por sala; antes de dois terços da descida o golpe só
  faísca. Lógica pura `UrnHazard` (`core/urn_hazard.gd`), no jogo `UrnFloor` (`game/urn_floor.gd`). "Derrotado por: Urna
  de Óleo" e "Óleo em Chamas" (`killer_urn`, `killer_oil`, provisórios), sons `urn_arm` = `tell_ember`, `urn_fire` =
  `enemy_burst`, `oil_arm`/`_fire` = os das Runas; `rooms[].hazard` `kind` `urn`, `lit`, `blasts`, `oil_damage`,
  `oil_hero_damage`. Testes em `tests/test_urns.gd`.
- **Robô com o cristal e a urna (Lote A, no molde do `Bot.column_plan`; `tests/test_bot_hazards.gd`)**:
  `Bot.crystal_plan` vai a um cristal a até `CRYSTAL_NEAR` 18 m (desperto, sem descarga nem calma no chão) quando a
  coluna dele tem `CRYSTAL_PACK` 2 inimigos ou mais (pelo corpo), golpeia de `CRYSTAL_SIDE` 2,1 m ao lado (fora da
  coluna) e `CRYSTAL_BACK` 1,4 m ao sul até descarregar; `Bot.urn_plan` vai a uma urna acordada e apagada a até
  `URN_NEAR` 10 m com `URN_PACK` 2 inimigos no anel e golpeia de `URN_REACH` 1,5 m do lado longe do bando (depois foge
  do anel pelo `_danger`). Ordem: coluna, cristal, urna. Medido em 12 sementes (`smoke 700`): o cristal só acorda na
  sala 7 (`crystal_from` 0,5); na semente 1 o robô carregou 4 vezes e descarregou 1 (120 de dano); a urna foi acesa nas
  2 salas acordadas, mas o bando sai do anel em 1,3 s (0 a 120 de dano). Nenhum `stuck`.
- **Colunata (RP-18)**: Santuário C (`depth` 0,5 a 1): o leste da nave vira uma grade de nove colunas baixas de 2,5 m
  (`COLONNADE`, x 3, 7 e 11 por z -4, 0 e 4, raio 0,5: barram corpo e tiro mas nunca escondem um preparo, critério do
  combat-feel-director), duas reduzidas a tocos (`column_base`, corpo sim, tiro não) e uma rachada que tomba 3 m
  (RP-09); o oeste da nave fica aberto para a investida do guardião; lajes da A; zona `colonnade`. Só dado.
- **Portas no fundo (RP-19)**: `tests/test_exits.gd` confere em toda sala de luta e variante cada porta a 8 m ou mais da
  entrada, fora de toda zona de nascimento e 5 m ou mais das outras; todas já passavam, nenhuma porta mudou.
- **Protótipos do atlas (AT-H1 a AT-H3, Lote D; Q-AT3 a, Q-AT4 a; `rooms_progression.md` seção "Lote D")**: **AT-H1, laje de
  pressão do Santuário** = o RP-06 que já existe; a isca (inimigo que pisa e arma) já vale (`armed_by_enemy`), cada laje
  das naves tem uma faixa de 1 m livre ao lado (teste); o robô não atrai inimigos de propósito (o `Bot.lure_plan` é do
  gameplay-engineer). **AT-H2, Esqueleto do Nicho (Cripta B)**: faixa de laje (`_niche`, `NICHE_AT` (-12; -6,5) na parede
  oeste, 2,2 x 2,2 m) no `hazard.also` da B, desde a sala 4: acorda com ele 0,3 s (inimigo 0,2), 1,2 s de aviso, agarra
  0,25 s, 10 / 60 e **puxa 1 m para o nicho sem prender** (`HazardDef.pull`; no herói em `PlateFloor.PULL_TIME` 0,12 s,
  quadro a quadro por `Arena.sweep`, encurtado na borda de outro aviso do chão ou da pedra, R10, `PlateFloor.pull_reach`;
  a esquiva corta), recarga 6 s; o grupo de quebráveis da parede oeste da B saiu dali. **AT-H3, Planta Hostil (Jardim
  B)**: no lugar da raiz do toco junto da parede oeste (as raízes da B ficam com uma), `_plant`, `PLANT_AT` (-16,6; -1,5),
  faixa de 2,5 x 1,5 m para o leste, como a raiz: 0,5 s (inimigo 0,2), 1,2 s, 10 / 60, empurrão de 1 m para fora, 6 s.
  Nos dois a Emeth só faísca (`HazardDef.sparks`, `spark_radius` 0,6, pelo `Combat.reached` e `ColumnFall.touches`: nada
  ferido, não é inimigo, então a mira assistida nunca o escolhe, sem número nem hit stop). Segundo PLATES da sala em
  `Rooms.plates_also`; `rooms[].hazard.also` com `kind` `niche`/`plant`, `pulled`, `sparked`. "Derrotado por: Esqueleto do
  Nicho" e "Planta Hostil" (`killer_niche`, `killer_plant`, provisórios para o Daniel); sons `niche_arm`/`plant_arm` =
  `rune_arm`, `niche_fire` = `bone`, `plant_fire` = `enemy_swing`. Desenho provisório: a moldura de laje ao longo da faixa
  (`GroundLook.plate_band`) e faísca; a mão do esqueleto e a planta são do environment-artist (SW-G7 3.5). Testes em
  `tests/test_niche_plant.gd`.
- **AT-SA2, o 1º aviso na tela**: `tools/first_warning.gd -- --bot --autopick --nosave --seed=N [--cam=far]` joga a
  primeira sala e imprime `FIRST_WARNING` com onde o contorno do primeiro aviso de inimigo cai na tela (0 a 1) no
  quadro em que aparece; no Salão, inteiro em 8 de 8 sementes na Perto e na Longe (`rooms_progression.md`).
- **Hipóteses de planta do atlas (AT-CA2, AT-SE2, AT-PB2, AT-FO2; `rooms_progression.md`)**: contador novo
  `rooms[].dodge_blocked_by` (esquiva cortada pela pedra ou pela borda, uma vez por esquiva: sinal `Player.dodge_blocked`,
  `Arena.blocker_at` dá `peça@x,z` da planta ou `edge`, `RoomTally.dodge_blocked`). Cripta A, Santuário B e Ponte B
  ficaram como estavam (medidas abaixo do limite). A Fonte do Salão nasce em `Rooms.FOUNTAIN_SPOT` (-8; 10), na tela das
  duas câmeras quando ele chega pelo patamar (antes (0; -2), fora das duas); `test_the_fountain_is_seen_on_arrival` em
  `test_arenas.gd`.
- **Morte de elite** (V-14): elite de aço dourado (`EnemyDef.elite` com `gild`; guardiões não) cai com duas lascas de
  ouro velho a mais (`CrowdRenderer.GILD_COLOR`, `Horde.damage`); teste em `test_vfx_lote1.gd`.
- **Provação** (o Caos; `Trials`, `TrialDef` em `data/trials/`, parte `trials`; números no grupo Events do `StageDef`): laje
  numa sala de luta vencida (20%, profundidades 2 a 7, intervalo de 10 salas, nunca com maldição em curso), custo
  `ceil(10 + 0,5 x profundidade)` só com mais vida que isso; pisar paga e leva à câmara (`stage.trial_layout`), com 3
  cartas (Bênção forte com raridade sorteada, maldição por 3 a 5 encontros) e as portas da sala de antes (fechadas até
  pegar uma). A laje é a do look (`TrialLook.entry_slab`, com a placa e um fio de luz marfim de 1,2 s ao surgir, sem
  lâmpada própria); escolhida a carta, `TrialLook.settle`; feita a troca do altar, `AltarLook.kindle` (`Rooms._to_look`).
  A maldição age em `Horde.speed_scale`, `Player.heal_scale`, `Player.hurt_scale`, ondas (`wave_extra`) e
  ouro (`gold_pct`); depois do último encontro vira a Bênção (`BoonState.grant`, "Provação vencida").
  Para a UI: `Rooms.trials` (`active`, `left`, `won`), `trial_cards`
  (`Trials.Card.view()`), `take_trial(i)`, sinais `trial_slab_shown`, `trial_entered`, `trial_offered`, `trial_taken`,
  `trial_turned`. Robô: paga se sobrar 60% da vida (`Trials.bot_accepts`) e pega a primeira carta.
  **Interface (spec 5.3)**: pisar diante do bloco (`Rooms.TRIAL_SPOT`) abre as cartas numa tela (`EventChoice.open_trial`,
  `scripts/ui/event_choice.gd`, filha da `BoonChoice`; `Game.open_screen`/`close_screen`; escolher chama `take_trial`):
  `BoonCard.setup_trial` com a Bênção em cima (nome, "Bênção" e a raridade, que também é a borda) e a maldição numa
  faixa de tinta lilás-escura com por quantas lutas; o medalhão é o da Bênção (`BoonIcon.setup_glyph`, `TrialSeal.blessing_look`) com o losango rachado pequeno como selo. Robô e `--autopick` pegam
  a primeira sem tela. No HUD, acima do medalhão, o selo `TrialSeal` (losango lilás acinzentado de 33 px a 1080, encontros
  que faltam dentro, nome da maldição ao lado, escondido enquanto o selo da maldição de Morvath está de pé; nada no herói,
  E5-D7); na virada a rachadura enche de ouro velho em 0,4 s e o `EloBanner.show_trial` diz "Provação vencida" com o nome e
  o efeito da Bênção (`Hud.show_trial_won`, no lugar do aviso). A laje mostra o losango e troca "Pisar custa N de vida" por "Vida
  insuficiente" no rosa apagado enquanto falta vida (`DoorSign.set_short`).
  **T5 (o PO não entendeu Provação nem Altar)**: cada tela de evento tem uma linha sob o título (`BoonChoice._page(...,
  lead)`, nó `Lead`): "A maldição começa agora. Vença as lutas e a Bênção fica com você até o fim da descida." e, embaixo,
  "A vida já foi paga. Escolha uma carta para abrir as portas."; a carta da Provação (`TRIAL_SIZE` 320 x 404) diz
  "Bênção · Rara", "VOCÊ RECEBE DEPOIS DE N LUTAS", o número e "e fica até o fim da descida" e, na faixa,
  "VOCÊ CARREGA NAS PRÓXIMAS N LUTAS" (a Bênção só vem na virada, `Rooms._fight_won`; testado). A laje ganha uma nota
  (`DoorSign.add_note`, uma linha por rótulo, entrelinha `LINE_PITCH` 1,15, véu escuro atrás): "Uma Bênção forte, com uma maldição" e "Para recusar, não pise". Altar: "Uma troca só, ou
  nenhuma. O que mudar vale até o fim desta descida."; cada carta com VOCÊ ENTREGA e VOCÊ RECEBE, os números e o antes e
  depois (vida máxima, ouro, Magia máxima: `Altar.options` devolve `give_from`/`give_to`/`get_from`/`get_to`, `why` e
  `short`, só informação), o porquê exato ("Faltam N de ouro", "Nenhuma Bênção sua pode subir de nível", "Vida máxima
  baixa demais") e "Seguir em frente" com Nada e Nada; a porta do altar diz "Uma troca, sem luta" (`door_altar`).
  Capturas em `docs/gallery/t5/ui/`.
- **Altar Esquecido** (`Altar`, `stage.altar_layout`): porta uma vez por descida (profundidades 2 a 8, 20%), sem luta,
  uma troca ou nenhuma: 10 de vida máxima por uma romã (`Game.open_grow_choice`) ou 75 de ouro por 25 de Magia máxima.
  `Rooms.altar_options`, `take_altar(option)`, sinal `altar_used`. Robô: `Altar.bot_choice`. Pisar na laje gasta diante
  do degrau (`Rooms.ALTAR_SPOT`) abre uma tela pequena (`EventChoice.open_altar`, `BoonCard.setup_altar`, 290 x 392 a
  720): as duas trocas com medalhão de selo (`SealMedal`: romã, chama de vela; arco aberto em "Seguir em frente") e o que pedem, a que não cabe agora apagada com o porquê,
  e "Seguir em frente" (nada); sair da laje e voltar abre de novo.
- **Portas que mostram o caminho**: a luta atrás de cada porta é sorteada ao abrir a sala de antes (`Rooms._prepare`,
  `RunMap.Room.fight`, na semente do nó desde o DV-1) e entra igual; a placa diz "Difícil" para luta com elite e "Guardião" (`Rooms.door_text`);
  `Rooms.door_info(i)` dá `kind`, `reward`, `depth`, `tier`, `guardian`, `hard`, `elites`, `arena`, chaves de texto.
  Pictograma à esquerda do nome na placa (`DoorGlyph`, `DoorGlyph.of(door_info)`, `DoorSign.make(..., glyph)`; spec 7.1):
  uma divisa de ouro velho para "Difícil", duas para o guardião, três para Morvath, gota na fonte, moeda na loja, chama no
  altar, losango rachado na laje da Provação; luta comum sem nada. Testes em `tests/test_e5_ui.gd`; capturas
  `tools/ui_lab.gd -- --trial|--altar|--slab` (comando no topo), galeria `docs/gallery/e5/ui/`.
- **Registro**: `events` no `RESULT` e no registro (`RoomTally.event`: `door`, `trial_shown`, `trial_paid`,
  `trial_refused`, `trial_offered`, `trial_taken`, `trial_turned`, `altar`), mais `trial` (`active`, `left`, `won`).
  Testes: `test_hazard.gd`, `test_trial.gd`, `test_altar.gd`, `test_arenas.gd`, `test_descent.gd`, `test_e5_wiring.gd`.

## Quebráveis (AT-Q1, Lote D; arte em `docs/art/at_q0_breakables.md`, cadência em `docs/design/combat_cadence.md` 9.6; testes em `tests/test_breakables.gd`)
- Dado: `RoomLayout.breakables` e `ArenaVariant.breakables` (`BreakablePiece`, `core/breakable_piece.gd`: `form` vaso,
  urna, oferenda, vaso de água, caixote, tábua, banco, galho, muda; `at`, `radius` até `Breakables.MAX_RADIUS` 0,45,
  `height` 0,35 a 1,0, `group`), postos pelo `_place_breakables` do `make_data.gd` (parte `stage`): Salão 10 em 4 grupos
  (bordas e pé das balaustradas, longe do eixo, do medalhão, da fonte e da fileira da loja), Cripta A e B 8 em 3 grupos;
  AT-Q4 (room-designer): todas as outras salas e variantes, a Provação e o Altar, de 7 a 10 em 3 ou 4
  grupos de 2 ou 3 nos cantos e encostados (Fendas e Ponte madeira, Jardim galhos, mudas e vasos de água, Santuário
  oferendas, Runas caixas baixas e tigelas, Provação e Altar cerâmica), conferidos em `test_arenas.gd`
  (`test_breakables_stand_where_they_may`: 4 a 10 em 2 a 4 grupos de 2 a 5, cada grupo encostado, 1,5 m ou mais de
  porta, marca da porta, entrada, recompensa, nascimento, ponto de uso, guardião e toda laje ou faixa de perigo, também do
  `also`). Regras de cada sala (Atlas, coluna 3) em `tests/test_breakable_rules.gd`: nunca no tabuleiro das Fendas
  (`RiftLook.BRIDGES`) nem da Ponte (os tabuleiros do `BridgeLook`, 2,5 m ou mais da linha das pontes, no patamar da B só
  na borda), vasos de água do Jardim B a até 2 m da borda oeste úmida, nas Runas nunca tocando ladrilho que arma
  (`ArenaHazard.live`; só cabem no chão quieto da entrada, `RUNES_ENTRY`) e na B a 3 m da pedra quieta, no Santuário 4 m
  ou mais da linha entre o `boss_spawn` e a entrada e só na periferia, na loja 3 m ou mais de todo relicário com 1 a 5
  itens. **Câmara do Selo (AT-CS3)**: 8 de cerâmica no patamar da escada sul e na borda noroeste e nordeste, de 11 a
  12 m do selo, longe da câmera e além do anel do ritual; o `test_boss_exits` refeito com elas inteiras (como pedra
  sólida, mais duro que o jogo) e quebradas, e na câmara de verdade elas não param nada. Nenhum no hub. Regras puras em `Breakables` (`core/breakables.gd`): material por forma (`Stuff` CERAMIC, WATER, WOOD,
  BRANCH), um golpe e o caixote dois (o 1º racha), quebra uma vez só, por golpe do herói (`swing`, pelo `Combat.reached`,
  que só sai do golpe que saiu: golpe cortado pela esquiva não quebra), pela onda dele (`circle`, tiros não hostis), por
  golpe de inimigo e perigo de sala quando o aviso aterrissa (`reached_by`, pelo sinal novo `Ground.zone_landed`), nunca
  por andar; `tally` (`total`, `broken`, `by_hero`, `by_enemy`, `by_hazard`) vai para `rooms[].breakables` do `RESULT`
  (`RoomTally.breakables`; sala sem quebráveis igual a antes: o `smoke 600 --seed=5` dá o mesmo `RESULT` fora dessa
  chave). No jogo `BreakFloor` (`game/break_floor.gd`, criado pelo `Game.rebuild_room` debaixo da arena, passo no
  `Game._step` depois dos tiros): nada barra corpo nem tiro (não é `ArenaObstacle`, fora da `NavGrid`), a mira assistida
  nunca o escolhe (só a `Horde`), nenhum hit stop, número, combo, Magia, passiva, carga da ultimate nem câmera lenta.
  Desenho provisório para o AT-Q2: forma simples por material na cor do bioma (`BreakFloor.CLAY`, `WOOD`), achata
  `SQUASH_TIME` 0,04 s e some, cacos pelo `Fx.chips` e pó pelo `Fx.wisps` (dado do `Fx`); som por material com os sons
  que existem (`Breakables.SOUND`, um por material por golpe, pela `VoiceGate`) até os `break_*` do AT-Q3. Sonda:
  `PROBE_VASES=1` põe 6 vasos em volta do herói, inteiros de novo antes de cada caso (`BreakFloor.restore`): 41/41 com os
  mesmos quadros.


## C1b, Frente 2: grupos com respiro e comuns maiores (`docs/design/combate_c1b.md`; testes em `tests/test_c1b_rooms.gd`)
- **Orçamento por sala**: `StageDef.room_budget` (por profundidade, 1.0 fora da lista) multiplica a dificuldade só em `EncounterGen.generate`
  (`EncounterGen.difficulty` não muda). Começa em 0.65, sobe e cai em vale depois de sala difícil (4, 8 e 12); calculado supondo o comum com
  1,6 vez a vida (Frente 1). Os vivos de uma vez continuam `tier_alive` (3 a 6 no comum); as pools já dão dois papéis ou mais da sala 3 em diante.
- **Versão maior**: `skeleton_big` e `runner_big` (`EnemyDef.big`, dado em `_bigger_ones` de `tools/make_data.gd`; `big_version` no comum, nunca
  no elite). Mesma malha e comportamento, maior (`size`), vida 5 vezes a do comum de antes da C1b (300 e 225), sem blindagem, não é elite, aviso
  próprio mais longo (1,1 e 1,25 s), `strikes` 2 (segundo golpe do esqueleto em arco largo, segunda explosão do corredor 0,6 s depois): nenhum código
  de comportamento novo. `rating` 20 e 28: o ouro vem do `GoldPurse` por rating, então paga mais sem tocar em nada.
- **Quando**: `StageDef.big_from_depth` 4 e `big_chance` 0.5; `EncounterGen.add_big` troca uma cabeça da última onda (que tem todos os papéis)
  pela versão maior, pagando com cabeças do mesmo tipo pelo rating (sobra ao menos uma), só em luta com outro papel, no máximo uma por luta, nunca
  em arena com perigo (`RoomLayout.hazard`) nem em evento. `pick_kinds` ignora `big`. Teto de 20 corpos intacto (`Fight.ceiling`).
- **Livro**: as duas entram em `CodexScreen.ENEMIES` com nomes provisórios (`enemy_skeleton_big`, `enemy_runner_big`: "Esqueleto Maior", "Corredor Maior"; o Daniel aprova).

## C1e, lote A: o sorteio por faixa de sala (`docs/design/inimigos_c1e.md`; testes em `tests/test_c1e_a.gd`)
- **Faixas (progresso = (sala - 1) / 11)**: Gritador de 0,40 (sala 6; a 5 é o guardião) e Coveiro de 0,60 (sala 8), cada um em 2 ou 3 pools
  novas de `_stage` (papéis `rally` e `grave`, sempre ao lado de papéis já vistos, uma peça nova por luta): Gritador com Esqueleto e Corredor, ou
  Escudo e Esqueleto (comum), ou Corredor e Besteiro (difícil, elite 0,5); Coveiro com Feiticeiro e Esqueleto (comum) ou Escudo e Besteiro
  (difícil). `per_room` 1 nos dois (`limit_per_room`).
- **Regras de sorteio** (`EncounterGen`): `never_with` (`clashes`, no `pick_kinds`: Coveiro e Trinca nunca juntos); a luta não repete o
  conjunto de papéis da sala de antes (`generate(..., avoid)`, até `REDRAWS` 4 novos sorteios; `Rooms._prepare` passa os papéis da sala em que o
  herói está, e a primeira porta preparada fica, então a mesma sala segue com a mesma luta; guardião conta como papel `guardian`);
  modificadores como em `gameplay.md` (C1e, lote A). Teto de 20 corpos intacto.
- Ainda fora (lotes B e C): o par proibido Canalizador e Varredor, Armadilheiro e corrente, a sala de respiro depois de 2 novos (no lote A nenhuma
  pool tem 2 peças novas).

## C1e, lote B: onde entram o Saltador e o Lançador (`tests/test_c1e_b.gd`)
- Saltador de 0,18 (sala 3) e Lançador de 0,27 (sala 4), seis pools novas em `_stage`: Saltador com Esqueleto (0,18 a 0,46), com Besteiro e Esqueleto
  (0,30 a 0,80) ou com Escudo (0,30 a 0,60); Lançador com Esqueleto (0,27 a 0,60) ou com Trinca e Esqueleto (0,46 em diante); os dois juntos
  com o Escudo só no fundo (difícil, 0,80 em diante, elite 0,5). `per_room` 2 em cada (`limit_per_room`); `EncounterGen` e o teto de 20 corpos intactos.
- Ainda fora: a sala de respiro depois de 2 novos (lote C não fez).

## C1e, lote C: onde entram o Canalizador e o Armadilheiro (`tests/test_c1e_c.gd`)
- Canalizador de 0,40 (sala 6): `pressure`+`beam` (0,40 a 0,70), `block`+`beam`+`pressure` (0,46 em diante), difícil `pressure`+`beam`+`flank` (0,70 em diante, elite 0,5). Armadilheiro de 0,64 (sala 9):
  `pressure`+`trap`+`flank`, `leap`+`trap`+`pressure` e, difícil, `block`+`trap`+`flank` (0,70 em diante). `per_room` 1 nos dois; o Canalizador nunca com o Varredor (`never_with` `sweep`);
  a sala da corrente (RP-11) proíbe `trap` além de `area` e `sweep` (`banned_roles`). Modificadores: 5 no sorteio. Teto de 20 corpos intacto.

## Salas dos guardiões, 2026-11-23 (`tests/test_guardian_rooms.gd`)
- Pedido do Daniel: salas de guardião menores, para dificultar a fuga. O Cavaleiro e o Ancião deixaram o Santuário (agora uma sala de luta
  comum, difícil, `guardian_home` e `guardian` falsos) e têm casa própria: `RoomLayout.guardian_id` (`knight`, `priest_elder`) com
  `guardian_home`; `RunMap.home_of(id)` acha a casa, `_layout` manda o MINIBOSS para ela em qualquer profundidade (a menos que tenha sido a
  sala anterior) e `_fits` nunca dá uma casa a luta comum. O segundo guardião só é conhecido depois que o primeiro é escolhido: `_leave_other`
  refaz `layout`, `arena` e `variant` do nó dele. `--start=miniboss --guardian=x` pega o nó do guardião pedido.
- **Salão do Cavaleiro** (`knight_hall`, `_knight_hall`): quadrado de 22 m (canto NE cortado em 2,5 m para o monte de blocos da `CryptLook`). Em
  cada canto, pedras da abóboda (`_rocks`, 4 zonas de 3,8 m, a 6,2 m ou mais da entrada, metade mirada nele) e, ao lado, uma **laje de
  espinhos** (`_spike_plates`, `plate_source` `spikeplate`: `PLATES` sem `dwell`, pisar arma na hora, aviso 1,2 s, espinhos 0,6 s, 10 nele e 60
  no inimigo, descanso 6 s; peça `HazardPiece.grate`, "Derrotado por: Laje de Espinhos"). Acordam em 0,3 do trajeto (`HOUSE_FROM`: o primeiro
  guardião, sala 5, tem 0,333), nada nos primeiros 3 s (pedras) e 5 s (lajes). O meio fica livre para a investida (que atordoa na parede).
- **Câmara do Ancião** (`elder_hall`, `_elder_hall`): quadrado de 24 m, quatro colunas altas (5,2 m, raio 0,9) a (+-4,5, +-4,5) que barram corpo e
  tiro; sem perigo. O teste prova que cada coluna para as cinco linhas do leque (84 graus) que acertariam quem está 1,4 m atrás dela. As
  orbes do Ancião são barradas por `Arena.shot_hit`.
- Visual provisório: as duas usam a `CryptLook` (`l.look = &"crypt"`; a entrada da arcada acompanha `hero_spawn.y` quando `guardian_home`) e o ar
  do Santuário (`Ambience.BY_ARENA`). Falta arte própria (colunas e braseiros de guardião, laje de espinhos como peça) com o environment-artist.
- Medida (robô, 12 sementes, `--start=miniboss`): ver `docs/design/rooms_progression.md`, "Salas dos guardiões".
- **Lote S (2026-11-25)**: as 4 lajes de espinhos do Salão do Cavaleiro estão **encostadas nas paredes** onde a investida termina (meios oeste e
  leste, parede sul dos dois lados da entrada, a 6 m dela): o Cavaleiro atordoado 1,5 s em cima de uma arma na hora e a pisada fere aos 1,2 s.
  `WallMark` (`scripts/game/wall_mark.gd`, `WallAim` puro em `scripts/core/wall_aim.gd`, criado por `Rooms._start_hazard` na casa do Cavaleiro) põe
  um anel âmbar (`Ground.add_round`, fonte `wallmark`, 0 de dano) onde a linha da investida encontra a parede, seguindo a linha enquanto ela
  segue o herói, e conta as batidas (`rooms[].walls`: `wall_hits`, `marked`). Placeholder: o desenho final é do `environment-artist`.
- **PT-2, medalhão no arco da porta** (`ArenaExit.medal_up` 3,8, `medal_in`, `sign_up` 0,9; `Arena.door_anchor/door_sign_y`): o disco da recompensa pende do arco da própria porta ou sobre a escada (`RewardGem.DOOR_SCALE` 0,8, haste do coroamento), no vão de 4 m e sob a coroa de 5,2 m, e o texto da `DoorSign` começa logo abaixo dele. `Arena.door_label` segue como ponto de uso e exclusão no chão. Imagem de cada recompensa, tipo de sala e anjo: `RewardIcon` (`assets/ui/rewards/<id>.png`, 512x512, ids em `LEIAME.txt`); sem arquivo vale o desenho de hoje. `tests/test_pt2_door_medallion.gd`.

## Lote S, ritmo e perigos que ensinam (2026-11-25; `tests/test_long_waves.gd`, `test_plate_cycle.gd`, `test_hazard.gd`)
- **Salas longas (RD2-06)**: `StageDef.long_depths` (2, 3, 4, 6 a 9): a luta vem sempre em 3 ondas mais leves (`EncounterGen.waves`, o mínimo de
  corpos por onda vira `long_fewest` 2; a vida total é a mesma), a 3a com 1 elite de um tipo da luta da sala 4 em diante
  (`EncounterGen.elite_last`, `long_elite_from`), os corpos nascem um a um a cada 0,45 a 0,75 s (`long_gap`) e a onda seguinte espera 0,8 s
  (`long_delay`); só em luta comum (`Rooms._step_fight`), nunca nos guardiões.
- **Laje de aprender por ciclo (RD2-08)**: `HazardDef.auto_cycle` 6 s, `auto_near` 2,5 m, `auto_until` 0,26 (até a sala 4): a laje parada há 6 s
  arma sozinha, aviso 1,5 s, quando há inimigo a até 2,5 m; vale para as lajes da Cripta A/B, as que cedem das Fendas A e a do Jardim A
  (`_teach` no `make_data.gd`). `PlateHazard.auto`, `armed_by_cycle`; `rooms[].hazard.armed_by_cycle`.
- **Runas, bando (RD2-07)**: padrão novo `herd` (`ArenaHazard._herd`): até dois blocos 2 x 2 onde mais inimigos estão, nunca na casa do herói;
  duas entradas em cada variante da lista de padrões; `ArenaHazard.bodies` é preenchido pelo `RuneFloor.step`.
- **Raízes e planta (S-1)**: faixa 4,8 m (planta 3,2 x 3,5 m) e aviso 1,8 s; o fluxo da horda não mudou (decisão do Daniel: pergunta B2 aberta).

## PT-6, o herói entra por baixo e sai por cima (2026-11-23; `tests/test_pt6_rooms.gd`)
- Regra: em toda sala o herói nasce na borda sul (a mais perto da câmera) olhando para o norte (`hero_spawn`, `hero_facing` (0,-1)) e as portas
  ficam no norte (o terço de cima do piso). `_gate(l, spawn, norte, xs)` em `tools/make_data.gd` põe a entrada e as portas na parede norte
  (`_doors` para as variantes: a Cripta B tem portas próprias por causa do muro divisório). O teste vale para toda arena, toda variante, a
  Provação e o Altar: entrada no terço sul, portas no terço norte (o Altar, com o altar na parede toda, tem só duas portas, nas laterais da
  metade norte), a entrada alcança toda porta (`nav.reachable`). O Salão (fonte e loja) e a Câmara do Selo já eram assim (entrada sul, saída
  e Morvath ao norte).
- Salas largas (Fendas, Ponte, Santuário) entram no canto sul de um lado e saem pelo norte do lado de lá (a travessia continua a pergunta da
  sala). A Ponte ganhou a quina NE reta na plataforma leste (cabem duas portas ao norte e uma na parede leste); a câmera dela cobre mais ao sul
  (`cam_bounds` 4 m de altura).
- Portas a 6 m ou mais uma da outra (as lanternas ficam a 3,6 m da porta); os braseiros que ladeiam uma porta (`_bowl`) ficam na que a `look`
  desenhava (Cripta, Fendas, Jardim, Santuário, Runas) e a `look` põe lanterna nas outras. Lajes, jarros, lajes de espinhos, pedras, armadilhas,
  relíquia, quebráveis e as casas rúnicas "quietas" (`RUNES_ENTRY`) foram refeitos para ficar a 6 m ou mais da entrada nova e fora das portas.
- Provisório (arte, `environment-artist`): as `look`s ainda desenham o arco da entrada antigo na parede oeste (agora selado, em posição fixa,
  `entry` de `CryptLook`/`RunesLook`/`GuardianLook`/`BridgeLook`); falta o portal de entrada na borda sul (e o `_front_walls` da `CryptLook` já corre inteiro, sem vão ao sul).
  O Altar não aceita porta ao norte sem a `AltarLook` abrir o nicho.

## PT-11, loja junto da parede (2026-11-23; `tests/test_shop_wall.gd`)
- `Rooms.SHOP_SLOTS` (5 pontos no chão do Salão, na ordem em que enchem; a loja da rota usa os 3 primeiros): o 1º (a Bênção, destaque) fica um pouco
  à frente, sobre o medalhão gravado (-2,5; 1); os outros ao longo da parede norte (-3,5 e -8,8; z -10,8/-10,2) e das laterais (-11,6; -3,2) e (11,6; -7,5).
  O meio fica livre, a entrada (sul) e a porta (norte, x 2,8) ficam a 5 m ou mais de qualquer item. Cada um mantém a bolha de luz (`RewardShaft`) e a
  plaquinha de preço (`DoorSign.shop`); a `dress_shop` põe um tapete pequeno e uma coluna de pedra fina (`SHOP_COLUMN`) atrás de cada item de parede, no
  lugar das lanternas de braço da fila antiga. Os quebráveis do Salão ficam a 3 m ou mais dos pontos (testes `test_breakables`, `test_breakable_rules`).
- Provisório (arte): coluna é caixa de pedra; falta a coluna fina esculpida e a plaquinha de pergaminho com a moeda do `environment-artist`.
- Captura: `tools/gpu.sh shot x.png --start=shop --gold=400 --bot --autopick --seed=5 --shot-at=4` (a sessão principal).

## Cura base e PT-6/PT-11 juntados (2026-11-24)
PT-6 e PT-11 entraram na `arpg-3d` (merge sem conflito, dados regerados sem diferença). Junto veio a cura base por sala vencida: `Rooms._room_cleared` chama `Rooms.base_room_heal(room.kind, stage.room_heal_base)` (3 de vida em `COMBAT` e `MINIBOSS`, 0 nas demais), além do `hero_gifts.room_won()` (Respiro). Medida e tabela em `docs/design/balance.md`.

- **PT-6b (2026-11-25)**: as portas em uso são as primeiras da lista `exits` (`exit_count`), então as duas primeiras ficam juntas no canto nordeste (4,2 m entre centros, fora da parede leste) e a terceira à esquerda; Altar com as duas na parede leste. `tests/test_door_corner.gd` trava a regra.
- **PT-6b, sala 1 (Salão)**: `CatacombHall.PORTAL_X` foi para 10,5 (o lance de degraus `FLIGHT`, estátuas, contrafortes, nichos, bandeira e urnas andam junto) e a escada leste desceu para o canto norte da parede (`EAST_GAP` z -13,6 a -10): portas em (10,5; -13,8) e (14,2; -11,8), 4,2 m. As pilhas de caixas do pé dos degraus foram para o lado oeste e a bilha/velas da parede leste para z -7,4. Teste em `tests/test_door_corner.gd`.

## Fase 2 do Plano SWORN, ritmo das salas e da descida (SW-R1 a SW-R3; 2026-11-25; `tests/test_sw_r.gd`)
Números de referência: `docs/design/sworn_rea_kingswood_2026-11-25.md` seções 3.1 e 3.2. Plano e tabelas: `docs/design/rooms_progression.md`
("Fase 2 SWORN").
- **SW-R1, orçamento de inimigos.** `EnemyDef.cost` (dado em `ENEMY_COST` do `make_data.gd`; 0 vale 0,6 do `rating`, `cost_of()`): pequeno 1
  (Rato de osso), comum 3, atirador 4, pesado 5, elite o dobro do tipo (6 a 12), maior 8 ou 9, Capitão 12. `StageDef.cost_curve` (um número por
  sala 1 a 12; depois da lista, a dificuldade antiga x `cost_per_rating`) é o orçamento de UMA onda inteira (`EncounterGen.cost_budget`).
  Cada sala de luta sorteia como é lutada (`EncounterGen.plan`, `Fight.mode`): `horde_share` 0,5 de horda (duas ondas de `horde_initial` e
  `horde_reserve` 0,75, a reserva entra atrás da primeira assim que a fila esvazia, sem esperar o chão limpar: `Rooms._horde`), o resto
  uma onda de `wave_coef_one` 1,0 ou, em `two_wave_share` 0,5, duas de `wave_coef_two` (0,6; SWORN 0,75, mas a nossa espera o chão limpar entre
  as duas e leva 10 s a mais). A onda deixou de ser cortada no máximo de corpos de pé: é uma fila (no máximo `wave_most` 20) que sobe conforme há
  lugar (`Fight.cap`, o que já valia). Sala longa (`long_depths`) virou toda sala de luta: corpos um a um e a última onda com 1 elite. `rooms[].budget`
  e `rooms[].mode` (`horde`, `waves1`, `waves2`) no `RESULT` (`RoomTally.note`). `tools/budget_probe.gd` imprime cabeças, custo e modos por sala.
- **SW-R2, âncoras.** `StageDef.rest_after_guardian`: uma das duas portas da sala depois de cada guardião (6 e 11) é uma fonte (o descanso, o
  `Kind.FOUNTAIN` de sempre, 40% de cura; as duas portas seguem juntas; a fonte não gasta o uso do Salão em `arena_max_uses`).
  `StageDef.fixed_rewards` (profundidade -> recompensas em ordem de slot, só nas portas de luta; as demais saem do baralho como sempre; as fixas
  não tiram carta dele): 2 Bênção e Coração, 7 Romã e Magia, 11 Bênção e Ouro. A 1 já era Bênção, a loja é sempre a 13, os guardiões na 5 e na 10.
  `Rooms.short_stage` zera os dois campos. Um caminho tem até 4 fontes (antes 2). `tools/run_map_probe.gd` conta as tentativas do grafo.
- **SW-R3, zonas mortas.** `RoomLayout.far_spawn` (Fendas e Santuário 1,5): o peso de cada zona de nascimento (`Rooms.spawn_weights`) é a área
  vezes (distância do centro dela ao herói sobre 8 m, entre 0,25 e 3) elevada a isso, então o próximo inimigo sobe do lado em que o herói não
  está; as zonas tardias abrem depois de 4 cabeças (`Rooms.LATE_AFTER`) e não só na 2a onda, para a horda e a sala de uma onda também as usarem.
  As áreas do Santuário `aisles` viraram `aisle_n` e `aisle_s`.

## Primeira descida guiada e Antessala (SW-O3, SW-O4; lote 3A1, 2026-11-25; `tests/test_first_descent.gd`; especificação `docs/design/onboarding_sw_o.md`)
- **Quando.** `FirstDescent.active(data, flags)` (`scripts/core/first_descent.gd`, puro): `--first` liga sempre (também com robô, sem save, `--smoke`);
  `--first=arrival` só a chegada e a Antessala (a porta não leva adiante, para capturas). Sem `--first`: falso com `--bot`, `--smoke`, `--start`, `--horde`, `--stress`,
  `--arena`, `--short`, `--medium`, `--nosave` ou `Save.enabled` falso; senão verdadeiro se `save.first == 0`. O robô, o `--smoke`, as capturas e a suíte seguem a
  descida normal, com o mesmo `RESULT` (provado com `tools/smoke.sh 900 --seed=1..6` antes e depois). `Game.first_run` guarda a decisão (calculada uma vez no `_ready`).
- **Save 16.** Campo `first`: 0 pendente, 1 feita, 2 pulada. `SaveData.merged`: versão menor com `runs` > 0 vira 1, sem descida fica 0. `Boot.first_scene` leva ao Santuário
  quem pulou (`first` 2). Fim da descida (`FirstDescent.finish`): morte e Morvath curto gravam 1 com `runs += 1` e **sem** `wins`, `firsts.victory` nem `firsts.guardian`
  (o `RunAward.award` não conta o guardião da guiada) nem a ferramenta da Forja (`Rooms` não chama `find_tool` na guiada); `Game.skip_first_descent()` (a pausa) grava 2 e vai ao Santuário.
  Fechar o jogo no meio deixa 0. O registro (`RunLog` 9) ganha `first: true` e `tools/runs_report.py` não conta essas linhas; `outcome` "first" é o Morvath curto.
- **Dados.** `data/first_descent.tres` (`FirstDescentDef`, `FirstRoomDef`; parte `first` de `tools/make_data.gd`, é onde se muda sala, onda, recompensa, anjo, vida, perigo):
  9 passos (0 a 8). Passos com duas salas são escolhas de porta; toda sala abre para todas as do passo seguinte (como a descida longa). Ondas escritas à mão, sem orçamento,
  sem elite, sem modificador, sem Provação nem Altar (`FirstDescent.stage_for` zera `trial_chance`, `altar_chance`, `route_shop_chance`, `long_depths`, `fixed_rewards`).
  `RunMap.scripted(stage, def, seed, arrival)` monta o grafo (`RunMap.is_scripted`, `Kind.ANTE` = 7, camada 0 = a Antessala, `_keeps_rules` não roda). A vida do guardião
  (`hp_scale`) é aplicada em `Rooms._spawn`; o perigo da sala liga por `hazards` e a distância da descida em que vale por `hazard_progress` (a Cripta B acorda as lajes
  de aprender em 0,2; a Casa do Cavaleiro em 0,36, como a primeira descida normal).
- **Sala a sala** (`Sala N de 8`; N é `depth`, a Antessala é 0):

| # | Sala (arena, variante) | Ondas | Recompensa | Portas |
|---|---|---|---|---|
| 0 | Antessala (`hall`, 1) | nenhuma | nada | 1: Bênção (Sarael) |
| 1 | Cripta A (`crypt`, 1, sem perigo) | `[skeleton]`; `[skeleton x2]` | Bênção do Sarael (3 cartas) | 1: Ouro |
| 2 | Fendas A (`rift`, sem quedas) | `[archer]`; `[archer x2, skeleton]` | Ouro | 2: Bênção (Nivael) ou Romã |
| 3 | Jardim A (`garden`) | `[bone_rat x5]`; `[runner x2]` | a escolhida | 2: Fonte ou Cripta B (Bênção) |
| 4 | Fonte (`hall`) ou Cripta B (`crypt`, 0, lajes de aprender) | `[skeleton, archer, bone_rat x3]`; `[guard, skeleton, archer]` | Bênção | 1: o guardião |
| 5 | Casa do Cavaleiro (`knight_hall`) | `[knight]`, vida x0,7, sem escolta | Bênção do guardião | 1 |
| 6 | Santuário (`sanctuary`, sem perigo) | `[skeleton x2, archer]`; `[mage, runner, bone_rat x4]` | Ouro | 1: loja |
| 7 | Salão (loja) | nenhuma | 3 itens | 1: Morvath |
| 8 | Câmara do Selo | Morvath curto: vida x0,6, só a fase 1 | fim da guiada | nenhuma |

  Desvio do documento: a Cripta A é a variante 1 (Ossário, sem perigo) e a B a 0 (as lajes de aprender são as da variante 0), para as duas não serem iguais; a Fonte da 4 é uma das portas
  da 3 (o documento a punha "na 3 ou na 4").
- **Antessala** (`RunMap.Kind.ANTE`): sem luta, `_open_doors` logo na entrada (`phase` OPEN), sem recompensa, sem cura de sala nem Prata, sem aviso "Sala N" (`notice` não sai).
  As lajes (variante `ante` do `hall`, `docs/design/rooms_progression.md` "Antessala") rodam no `Rooms._step_ante`; ele conta `plates_crossed` (o herói passou do lado norte da faixa),
  `broke_one` (um quebrável do `BreakFloor.rules` com vida 0) e `idle_blink` (25 s parado); `Rooms.ante_ctx()` dá `near_plates`, `near_breakable`, `crossed_plates`, `broke_one`
  para o `Objective.pick`.
- **Chegada** (SW-O1): `Rooms._play_arrival` carrega `scripts/game/arrival_scene.gd` se existir (`play(game, at)`, `finished`, `skip()`), uma vez, na Antessala da guiada; o preto de
  `Rooms._fade` abre em `arrival_open_at`/`arrival_open_s` do dado e qualquer ataque, esquiva ou interação depois de `arrival_skip_after` chama `skip()`. Sem o arquivo: a sala abre como as outras.
- **RESULT** com a guiada: `first` 1, `ante_s` (segundos de jogo até a porta da Antessala) e `first_boon_s` (a primeira Bênção oferecida). Sem a guiada o `RESULT` é o de sempre.
- **Pendências de integração**: `Milestones.ult_open` (o `Game._ult_open` pergunta se o arquivo existir, senão a Ultimate segue aberta), `ArrivalScene`, `Objective`, a condição `ult` do
  `HubGuide.due`, as chaves de texto novas (`room_ante`, `first_tip_*`, `first_done`, `arrival_line`, `obj_*`, `guide_ult`), `MilestoneDef` (a parte `milestones` do `make_data` só escreve quando a classe existe),
  `Boss.last_phase` e `Boss.tutorial_end` (o `Game._shorten_boss` os usa se existirem; sem eles Morvath cai inteiro e o `Game` termina a guiada do mesmo jeito).
