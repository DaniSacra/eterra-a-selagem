> Índice: [rooms.md](../rooms.md)

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
