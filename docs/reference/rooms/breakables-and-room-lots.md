> Índice: [rooms.md](../rooms.md)

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
