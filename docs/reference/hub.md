# Santuário (hub)

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Hub (HUB-01; HUB-B1 fundação, plano em `docs/design/hub_spec.md`, espaço em `hub_spec_art.md`, auditoria em `hub_audit.md`)
- Fluxo: título, Iniciar, **hub** (`scenes/hub.tscn`, `Hub`, `scripts/game/hub.gd`), Portal (interagir e "Descer às
  catacumbas?" Descer/Ficar, `HubPanel`; Juramentos antes depois da primeira vitória, como era o Iniciar), partida. Tela de
  fim "Voltar ao {HUB}" e pausa "Sair para o {HUB}" voltam ao hub; "Descer de novo" segue direto. No hub, Esc abre o
  `PauseMenu` com `hub = true` (Compêndio, Configurações, Voltar ao título). Toda troca de cena por `SceneGo.to`
  (`TITLE`, `HUB`, `GAME`; `SceneGo.catch` nos testes). Nome do lugar só na chave `hub_name` ("Santuário", provisório,
  D-H4): `TextTable` troca `{HUB}` por ele em qualquer texto.
- Ação `interact` (E, A no controle; remapeável; linha no Como Jogar). Save que já usava o E em outra ação: `interact`
  vai para a primeira livre de `Controls.SPARE_KEYS` (F, G, T, C, V; `keys_for`); remapear para uma tecla usada troca
  as duas (`rebind`).
- Herói em paz (`Player.peaceful`): só anda e corre (segurar a esquiva); nenhum golpe, especial, círculo, ultimate nem
  esquiva; empurrado no meio de uma peça redonda desliza em volta (`RoundSlide`, só no hub). Sem HUD de combate.
- Planta (`HubPlan`, `core/hub_plan.gd`, fora do `StageDef`: chão, chegada, cinco pontos de uso, âncoras, obstáculos, eixo
  (u, v) girado pelo `cam_yaw`). **Chão de 50 x 33 m** (o PO achou o primeiro, 25 x 16,5, pequeno: a Encruzilhada do Hades II
  espalha os NPCs por uns 80 x 35 m; `HALF_U`, `NORTH`, `SOUTH`, `CUT`), fonte no meio (origem), portal ao norte, Vendedor
  em cima à esquerda, Forjador embaixo à esquerda, Árvore em cima à direita, Livro embaixo à direita, de 3 a 5 s de
  caminhada entre eles; peças em constantes (`FOUNTAIN`, `COUNTER`, `ANVIL`, `SMITH_SPOT`, `DAIS`, `LECTERN`, `LAMPS`,
  `BENCHES`, `BEDS`, `URNS`), todas fora das linhas retas da chegada às estações. Câmera: ponto `CAM_TARGET` com
  `CAM_REACH` 16 m (`CamFrame.hold`: anda só o que a margem de 18% do herói pede, então chega a qualquer estação e na
  borda mostra o hub, não o penhasco; uma caixa `cam_bounds` no mundo não serve, o hub está a 35 graus dos eixos); a
  câmera Perto segue o herói (`CamRig.near`). Foco por distância com histerese (`HubFocus`: entra a 2,2 m, sai a 2,8, troca por
  0,4 m mais perto; sinal `Hub.focus_changed`).
- **Cenário (HUB-B2, `HubLook`, `scripts/game/hub_look.gd`, look `hub` sobre `ArenaRoom`; capturas em `docs/gallery/hub/b2/`)**:
  pátio aberto ao entardecer, montado no eixo do hub dentro de um nó girado pelo `cam_yaw` (`HubLook.frame`, `at(u, y, v)`,
  `world(u, y, v)`; kit e `Masonry` próprios, `fk`/`fm`). Bordas só penhasco (`edge`), peças `hub_*` desenhadas pelo
  `dress` sobre a pegada do `HubPlan.layout()` (a mesma que colide; `piece` pula as `hub_*`). Fachada em duas camadas
  com vãos cortados por `_wall` (blocos inteiros entre os vãos, fatias de `BAND` só sobre cada arco), portal com três
  ordens de aduelas e a aduela do leão (nunca estrela), escada de 6 degraus que **não** é chão (o portal é usado ao pé
  dela, `HubPlan` sem mudança), terraço com duas estelas do leão em relevo (`altar_lion.gdshader`), braseiros sem
  sombra, floreiras; arcadas de quatro arcos de cada lado abertas para as ruínas e a cascata; paredes laterais com o forno (oeste,
  única luz de fogo com sombra, `KEEP_SHADOW`) e a estante de rolos (leste), um nicho com figura encapuzada em cada
  uma e um degrau de 1 m entre o chão e a parede com urnas, caixotes e velas (`_ledge`); nichos com figuras na fachada;
  na praça anel de ouro em volta da fonte com fios para as estações, bancos, urnas grandes em plintos e canteiros; mureta baixa com balaústres (abaixo de
  0,72 m), escada de chegada com grade e dois postes com lanterna. Praça: leão do medalhão em ouro velho embutido
  (`INLAY_GOLD`) com dois anéis e o fio de ouro no eixo, lajes de losangos sulcados nos cinco pontos de uso, fonte do
  leão só decorativa (bacia em blocos, água escura `dark_water`, estela com o leão e o fio d'água, musgo com flores
  ocre e terra). Estações: toldo listrado terra e ocre com o leão sobre o balcão do Vendedor, mercadorias em âmbar,
  marfim e azul-ardósia, duas lanternas; forno, bigorna e cavalete com três lâminas de ponta para cima e o escudo do
  leão; Árvore de Dons = `StoneTree` a 0,65 em ouro velho (sem cristais, veios de ouro, folhas de ouro pálido no
  `canopy.gdshader`) sobre o estrado octogonal, luz quente sem sombra; Livro de Ahk aberto no atril
  (`hub_page.gdshader`: pergaminho com linhas de tinta e rubrica, nada legível), fita petróleo, velas, tapete. Luz por
  estação em `HubLook.station_lights` (`station_light(id)`, para o HUB-B3). Ar e pintura próprios (`AIR`, `STYLE`:
  calcário morno, sombra petróleo; ambiente e lua um pouco mais neutros que a spec para a saturação ficar na meta) e
  no Compatibility `STY_COMPAT_*`; no clássico (F7) o chão é o calcário `CLASSIC_FLOOR`, não a laje rosada do salão. `tools/fit_probe.gd -- --arena=hub`. A cantaria e as lajes seguem o quadro girado (HUB-D,
  global `frame_yaw`, ver abaixo).
- **Placa e páginas (HUB-B3 e a interface do HUB-C; testes em `tests/test_hub_ui.gd`, capturas em `docs/gallery/hub/ui/`)**:
  uma placa só, da estação em foco (`StationSign`, `scripts/ui/station_sign.gd`, na língua da `DoorSign`: nome em ouro
  claro, linha curta em marfim, véu escuro de cantos cortados, e embaixo a tecla real na plaqueta do HUD,
  `ActionSlot.key_plate`, redonda num botão do controle, e "Interagir", `hub_use`); a tecla troca ao vivo por
  `Controls.device_changed` e relê o mapa quando uma tela fecha (`refresh`). Presa à âncora do `HubPlan`, dentro da tela
  e nunca sobre o herói (`StationSign.place`: sobe acima da cabeça, `HERO_GAP`), aparece em 0,15 s, some com tela aberta;
  clique nela usa a estação (`pressed`). Portal: "Descer às catacumbas?" numa folha do Livro (`HubPanel`: `BookSpread`
  com `single`, uma página com as duas bordas tostadas e sem dobra, `single` no `book_page.gdshader`, do tamanho do
  conteúdo; marca da porta do Como Jogar, título Cinzel em rubrica, filete, uma linha do que fica e do que não fica,
  `hub_descend_line`, Descer em destaque e com foco, Ficar). Vendedor e Forjador: a mesma folha com o medalhão trancado
  (`SealedMark`), "◆ A DEFINIR", "Ainda não há nada para comprar/forjar aqui nesta versão." e só Voltar (nada de compra
  falsa). Livro de Ahk: ao lado do medalhão do Guerreiro, três lugares selados (`HeroScreen.SEALED`, `SealedMark` com
  silhueta encapuzada sem rosto e cadeado; sem nome, texto, foco nem clique, D-H3) e "Compêndio" no rodapé (abre o
  `CodexScreen` sobre o livro; Esc ou B volta com o foco no botão). Menu do hub (`PauseMenu.hub`) com Como Jogar.
  Música: lugar próprio `MusicCatalog.HUB` ("{HUB}" na tela Músicas, opção `music_hub` do save), toda peça do título,
  padrão a do título (do título ao hub a música segue sem emenda). Capturas: `--hub --hero-at=x,z`,
  `--hub --hero-at=<estação>` (no ponto de uso dela), `--hub-use=portal|vendor|tree|smith|book`, `--hub-menu`, `--pad`.
- Peças comuns tiradas do `Game` (mesmo RESULT, `smoke 300` e `--start=boss --boons=25`, semente 5): câmera `CamRig`
  (`game/cam_rig.gd`: segue, segura o ponto fixo, trace; `Game.cam`), ar do mundo `WorldAir` (`game/world_air.gd`;
  `Game.air`), anfitrião de telas `ScreenHost` (`ui/screen_host.gd`, do título e do hub: Esc/B fecha,
  `Controls.clear_presses`, nada vaza). `--hub` entra direto no hub (`--hero-at`, `--shot`); `--bot`, `--smoke`,
  `--start`, `--stress`, `--play` e `--shot` sem `--title` seguem pulando título e hub (`boot.route`). Testes em `tests/test_hub.gd`; fluxo por teclado em `tools/title_flow_check.gd`.
- **HUB-D, parte do technical-artist (Meshy zero; capturas em `docs/gallery/hub/d/`, testes em
  `tests/test_hub_d_assets.gd`)**: **gente do hub**: Vendedor e Forjador são bonecos do KayKit Adventurers (CC0)
  assados como a multidão antiga, `tools/bake.gd -- npcs` (`NPCS`, 1 s cada) em `assets/baked/npc_vendor.res` e
  `npc_smith.res` (no pacote; a paleta própria, `tools/make_palettes.gd -- npcs`, vai comprimida dentro do `.res`,
  `"embed"`, porque `assets/models/palettes` é excluído): `Rogue_Hooded` sem armas, capuz petróleo escuro e manto
  terra; `Knight` sem elmo, escudo, espada nem capa, braços nus e pernas de lã por `remap`, avental de couro e martelo
  procedural `NPC_HAMMER` na mão (peça `hammer`); `Slender`, `height` 1,90 e 1,95 m com as solas no chão, cabeça a
  `head_shrink` 0,9; 4 005 + 4 232 triângulos (teto 12 mil). Opções novas do modo KayKit do assado: `height`,
  `head_shrink`, `embed` e o 4º campo do clipe `{from, to, bend}`. Desenhados por `HubNpc`
  (`scripts/render/hub_npc.gd`: um `CrowdRenderer` próprio com uma figura, a mesma pintura, contorno e faixas do
  estilizado da multidão, F7 ao vivo, mas mais claros que os mortos: T-1 da re-revisão, `HubNpc.STYLE_LIGHT` 0,5,
  `STYLE_SCENE` 0,3 e `STYLE_RIM` 0,35 contra 0,2 / 0,1 / 0,18 da multidão, o Vendedor, de capuz escuro sob o toldo,
  vezes `STYLE_VENDOR` 2,2; corpo na câmera Perto de luma p50 cerca de 55 para 79 no Forjador e 45 para 76 no
  Vendedor, o herói ao lado 94 a 97; `HubNpc.make(HubNpc.Who.VENDOR|SMITH)`, `face(ponto)`, `gesture()`): parado no
  `Idle` e um gesto de vez em quando (Vendedor `Interact` a cada 6 a 9 s; Forjador em séries de 3 a 5 golpes do
  `1H_Melee_Attack_Chop` a cada 1,2 s, cortado onde a cabeça do martelo pousa na face da bigorna a 0,94 m com o
  tronco 12 graus para trás, `HubNpc.landing`, `strike_point`, e 4 a 7 s de descanso), fagulhas âmbar pequenas
  (`CPUParticles3D`, 10, 0,4 s, nenhum canal acima de 1,0) no quadro do golpe. Postos pelo `HubLook._people`: o Vendedor
  atrás do balcão (`VENDOR_STAND`, virado 30 graus para a câmera), o Forjador a oeste da bigorna olhando para ela de
  perfil, onde o martelo pousa nela (0,79 m da bigorna; o `HubPlan.SMITH_SPOT` de colisão fica 1,7 m dela e deve ir
  para esse ponto, dono gameplay-engineer). **`frame_yaw`**: global de shader (`project.godot`, padrão 0) que
  `frame_yaw.gdshaderinc` (`frame_in`, `frame_out`) usa para assentar a cantaria (`masonry.gdshaderinc`) e as lajes
  (`catacomb_floor.gdshaderinc`, fora das lajes emolduradas e das Runas) no quadro da sala; o `HubLook.dress` o põe no
  `cam_yaw` (`HubLook.FRAME_YAW`) e o `_exit_tree` volta a 0; com 0 nenhuma conta muda (as salas iguais).
- **HUB-D, planta e cenário (environment-artist; revisão `docs/gallery/hub/ART_REVIEW.md` H-P0-1 a H-P0-4, LR-07 do
  room-designer; capturas em `docs/gallery/hub/d/`, testes em `tests/test_hub_d.gd`)**, valendo sobre a Planta e o
  Cenário acima: a câmera Longe vê uns 25 m de chão entre a margem do herói e o portal a um quinto da tela, então o
  portal veio 4,5 m para dentro (fachada em v 17,5, folha `SHEET_V` 18,75, escada do pé `HubPlan.NORTH` 12) e o chão
  sobe ao lado do terraço em dois lóbulos até `LOBE` (16, a partir de |u| 9), onde ficam Vendedor e Árvore; o herói
  chega pela escada num poço cortado na borda sul (`WELL`: meia largura 3,5, topo em -9; 20 degraus que descem até a
  bruma, sem grade) e aparece em `ARRIVAL` (0; -7,8) na borda do medalhão (0; -4,6). Chão 50 x 32,5 m. Estações a 11,5 m
  do eixo (`USE`; nenhum par a mais de 4 s andando, `test_no_two_stations_more_than_four_seconds_apart`), portal usado ao
  pé da escada (0; 11), a placa na metade direita da escada (fora do portal e do herói). Câmera: `CAM_TARGET` (0; 5,6) deixa a soleira do portal a 0,22 da tela e o
  arco inteiro (`PORTAL_TOP`, a 3ª ordem a 7,8 m) da chegada e de toda estação, sem a câmera se mexer ao chegar no portal
  (o `SHOW` dele fica mais baixo; `test_far_the_portal_shows_whole_from_everywhere`);
  na Perto o `Hub.lean` sempre segue o herói por `HubPlan.near_want` (nunca olha ao sul de `NEAR_SOUTH` -6), a borda sul
  fica abaixo de 0,85 da tela (`test_near_the_south_edge_stays_low`); ao chegar pela escada a Perto olha primeiro o ponto
  da Longe (`HubPlan.CAM_TARGET`) por `HubPlan.ARRIVAL_LOOK` 1,5 s, com a margem de 18% do herói valendo, e só então o
  segue (`HubPlan.near_want_at`, `Hub.arrived`; P1-A2 da revisão `ciclo_visual_1120`: o portal no alto do quadro, verde
  36,8% na caixa 690,0,300,150 a 1672 x 941 no `--shot-at=1`; a Longe igual; `--hero-at` pula isso); com estação em foco a câmera ainda se inclina pelo
  `HubPlan.frame_for` (`SHOW`, `CamRig.lean`). Estações com lugar próprio e de frente para a câmera: barraca do Vendedor
  no lóbulo oeste (`COUNTER` com `COUNTER_HALF`, toldo de 5,8 m listrado terra e ocre de 5 a 3,5 m de altura sobre quatro
  postes, `AWNING_*`, prateleiras atrás, mercadorias, duas lanternas; mercadorias encostadas, `GOODS`); Árvore a 0,56 (inteira na tela da Longe, re-revisão E-3) em ouro mais velho sobre
  o estrado no lóbulo leste (folhas em cartões maiores e em menos lugares, H-P2-1); forja no chão a noroeste da bigorna
  (`FORGE`, `FORGE_HALF`: bloco de 3,8 x 3 m e 3,4 de altura, boca em arco para o sul com brasas, fogo e brilho, coifa,
  chaminé de 5,8 m com fumaça, a única luz de fogo com sombra), bigorna 1,5 vez maior, os dois NPCs com círculo de corpo onde são desenhados (`HubPlan.SMITH_SPOT` onde o martelo do
  Forjador pousa, `VENDOR_SPOT` 0,4 m atrás do balcão, `test_the_npcs_block_where_they_stand`), pátio a oeste (`YARD`: cavalete com
  quatro lâminas e o escudo do leão de frente, cocho, carvão, rebolo; o desenho no `hub_yard`, as outras partes só
  colidem, `hub_yard_part`); Livro num atril de 1,5 m sobre degrau, dois castiçais de ferro, tapete, estante alta de 4 x 4,6
  m de frente (`SHELF`, `_shelf`: livros, rolos, escada, velas) e a mesa de escrita (`DESK`); os pátios de baixo fechados
  ao sul por muretas de 0,65 m (`YARD_WALL`). Praça: fonte de 5,6 m com estela de 2,8 e o leão em ouro velho (H-P1-5,
  H-P2-2), lajes em anel nela e no medalhão e caminhos de lajes com meio-fio e um fio de ouro de 0,18 m que termina na
  laje de uso (`_pave_way`, `WAY_FILET`, `WAY_SHORT`; as de cima saem da fonte, as de baixo do medalhão, H-P1-2),
  ciprestes em floreiras (`CYPRESSES`), canteiros elevados com arbustos de cobre (`BEDS`, `ARBOUR`, `_crowns`
  "Shrubs", `SHRUB_*`; os de flores pareciam caixões), urnas grandes abertas com um arbusto de cobre (fechadas e altas pareciam espetos pretos), bancos ao lado do eixo do portal, braseiros em pé
  ao lado da escada de chegada (`ARRIVAL_FIRES`, sem sombra, luz quente na praça, H-P1-7) e postes com lanterna; nichos
  de fora da fachada com urna no lugar da figura (H-P1-4); estelas do leão do terraço a 1,7 vez (H-P1-3, procedural).
  `HubLook.focus(id)` (chamado pelo `Hub` no `focus_changed`): a luz da estação em foco sobe `FOCUS_GAIN` 25% por uma
  gêmea sem sombra e um fio de ouro fraco (`FOCUS_RIM`, `ScreenTone.fit`) contorna a laje de uso, entrando e saindo em
  `FOCUS_EASE` 0,3 s. `HubLook.set_forge_rank(n)` (0 a `FORGE_RANKS` 3, para o gameplay-engineer pelo `hub.arena.look`):
  brilho do fundo da forja mais forte, uma gêmea de luz `FORGE_RANK_LIGHT` 0,3 por posto e duas línguas de fogo a mais
  desde o posto 2. Medalhões da Fatia 1 no `RewardGem`: Prata Antiga em prata com a barra (`Mark.INGOT`, aro de prata) e
  Fragmento de Memória em pergaminho com a folha rasgada a tinta (`Mark.LEAF`, `parchment` no `reward_gem.gdshader`);
  Re-revisão do art-director (E-1 a E-4): os braseiros do terraço acendem difuso no estilizado (`light_specular` 0, sem
  os discos de borda dura na fachada), a luz da forja fica `FORGE_LIGHT_EAST` 1,5 m a leste da boca (a poça chega à
  bigorna e ao Forjador) e dois canteiros baixos partem os quadrantes de baixo da praça (`BEDS`, u ±7,4, v -1,5; o
  maior quadrado livre de peça é o do medalhão da chegada, 8,5 m). `tools/gem_lab.gd` mostra os medalhões lado a lado (`docs/gallery/hub/d/medallions_silver_memory_720.png`). Capturas do hub
  com a câmera Longe pedem `--cam=far` (a Perto é o padrão desde o LR-01).
- **Santuário da Vigília Rev. 02, HV-A e HV-B (gameplay; backlog P.5, Q-HV1 a, Q-HV2 a; `tests/test_hub_rev02.gd`)**,
  valendo sobre a planta acima: o poço sul saiu; toda chegada (save novo, carregar, morte, vitória, pausa, todas por
  `SceneGo.HUB`) é no selo do Retorno `HubPlan.ARRIVAL` (18; -11,4), sobre a escada de 7 m na borda sul
  (`ARRIVAL_STAIRS` u 14,5 a 21,5; o canto sudeste deixou de ser cortado); "Descer de novo" segue direto. Usos:
  Vendedor (-10,3; 5,2), Árvore (10,1; 5,0), Forja (-10,3; -5,2), Livro (10,1; -5,1), Portal (0; 11) igual; cada
  estação leva as peças no mesmo lugar em volta do uso (`COUNTER`, `DAIS`, `ANVIL`, `SMITH_SPOT`, `FORGE` ao sul do
  Alquimista, `LECTERN`, `SHELF`, `DESK`, `YARD`, âncoras e `SHOW`); Fonte com 3,1 m; Alquimista reservado
  (`ALCHEMIST`, bancada `ALCHEMIST_BENCH` que barra, peça `hub_alchemist`, fora de `STATIONS`: sem foco, placa nem
  uso); muro do pátio só a oeste; bancos nos lóbulos norte; ciprestes e urnas dos lados para as paredes; canteiros,
  braseiros (os dois do Retorno), lampião e urna fora do caminho do Retorno. `HubLook` só o mínimo: escada nova com
  muretas, leão gasto no selo (`SEAL_LION`, `SEAL_GOLD`), bancada provisória do Alquimista, poças do `STY_POOLS`
  movidas com as estações; a forja continua com a boca para o sul (girar é do HV-C). Câmera (HV-B): do selo nenhuma
  câmera mostra o arco inteiro do Portal com ele a 18% da borda, então por `ARRIVAL_LOOK` 1,5 s as duas olham de
  `ARRIVAL_DISTANCE` 60 m com o herói a `ARRIVAL_SAFE` 0,14 (soleira a 0,23, topo do arco a 0,04, Fonte e duas
  estações à vista) e voltam em `ARRIVAL_EASE` 1 s à própria distância e aos 18% (`HubPlan.arrival_share`,
  `CamRig.wide`, `wide_distance`, `safe`, `dist()`; `CamFrame.hold(..., safe)`). Caminhadas medidas pelo campo de
  fluxo: entre estações 1,47 a 3,40 s; do selo ao Portal 4,25, à Forja 4,25, ao Vendedor 4,88 (a chegada não é
  estação). `fit_probe --arena=hub`: fantasma 6,11, sem desenho 7,20 (antes 6,09 / 7,18).
- **Fatia 1, parte do technical-artist (`docs/design/rejogabilidade/sistemas.md` 3.4; provas em `docs/gallery/rj1/`,
  `tools/rj1_lab.gd`)**: a Emeth por posto de Temperar: `temper` no `emeth.gdshader` (0 a 2, padrão 0 = a lâmina de
  sempre; frações fazem crescer), `EmethSword.set_temper(blade, posto)` e `EmethSword.TEMPER_MAX`: cada posto põe um
  veio de ouro velho num lado do meio da lâmina (`temper_gold`, até `temper_reach`) e estende o fio pálido do gume
  (`temper_thread`, `temper_edge`: posto 1 até a metade, 2 até a ponta), nada acima de 1,0, no estilizado sob o
  `style_cap`; o gameplay-engineer liga ao `ForgeRank`. Selos dos quatro anjos em código (`AngelSeal`,
  `scripts/ui/angel_seal.gd`: `AngelSeal.new().setup(Boon.Family.X, px, lit)` ou `AngelSeal.mark(ci, família, centro,
  raio, linha, cor)`): o selo da casa (`SealMedal.draw_seal`) e a marca da família (Chama brasa em losango com três
  línguas de fogo, Geada floco de seis braços, Luz um feixe sem ponta que desce sobre um losango, o topo reto esmaecendo (alfa 0,2 no alto a 0,9 embaixo) e alargando até a largura do losango com dois fios nas bordas, T-2, nunca pedra em pé nem raios, Vigília a trombeta do
  vigia, oliva, T-3), cores calmas em `AngelSeal.TINT`; nunca sol, cruz, leão, escudo nem olho; o Elo não tem selo.

## HV-C, pintura do Santuário da Vigília (`docs/art/hv_santuario_vigilia_art.md`; capturas em `docs/gallery/hub/hv_c/`)
- No `HubLook`: toldo do Vendedor em duas águas, a de trás mais longa (`AWNING_RIDGE`), listras terra e vinho apagado
  (`AWNING_STRIPE`); Pátio do Retorno com anel de lajes gastas em volta do selo, falhas escuras no leão
  (`SEAL_PAVING`, `SEAL_FAULTS`), caminho de lajes até o medalhão, braseiros menores (`RETURN_FIRE` 0,65) e um lampião
  âmbar baixo sem sombra na mureta leste da escada (`RETURN_LAMP`); placas baixas dos Dons em volta do estrado da Árvore,
  apagadas (`_gift_plaques`, `PLAQUE_*`, para o HV-E acender); Alquimista com estante e frascos, bancada com pano,
  pilão e balança de ferro, telheiro de tábuas sobre dois postes (sempre acima de 2,6 m sobre o chão, `ALCH_ROOF`),
  ervas penduradas e um lampião âmbar baixo sem sombra (`ALCH_LAMP`). Colisão e `HubPlan` iguais.

## HV-E, o Santuário que cresce com o save (gameplay; `docs/backlog.md` HV-E; testes em `tests/test_hub_evolution.gd`)
- `HubEvolution` (`core/hub_evolution.gd`, puro, só lê o save) dá o `State` do hub em cinco estados, cada um atrás de uma
  bandeira (`FLAGS`; peça sem a mecânica fica escondida): **E1 Forja** `forge_rank` (o Temperar, 0 a 3) e
  `forge_tools` (cada ferramenta só depois de usada: o Refinar, o Despertar ou o Inscrever comprado; a Picareta
  restaurada); **E2 Vendedor** `vendor` (`Stall.CLOSED` até a primeira Pedra Funda, `ORDER` "Tem um pedido", `OPEN`
  entregue) e `obras`; **E3 Árvore** `tree_lit` de `tree_total` 18 placas (um por Dom pago com Memória e aberto; a
  Maestria só em `mastery`, nunca acende placa); **E4 Livro** `book_spines` (uma lombada por capítulo do Compêndio com
  80% achado, `BOOK_SHARE`; Morvath só selado; `Hub.codex_chapters` conta como o Compêndio) e a prateleira de Ofícios
  (`shelf`, `shelf_items` = ferramentas e Obras dos Ofícios); **E5 Alquimista** sempre a bancada vazia (bandeira
  desligada até o Roteiro C). E2 e E4 ligados (o Lote C existe). Nada acende na primeira morte (`State.grown()`):
  tudo sobe só por algo comprado, aberto, entregue ou selado.
- O `Hub.evolve()` aplica ao chegar, depois de forjar, de um Ofício e ao fechar qualquer tela (`HubEvolution.apply`):
  `HubLook.set_forge_rank(n)` (existe) e, **para o environment-artist implementar no `HubLook`** (chamadas só se
  existirem): `set_forge_tools(Array[StringName])`, `set_vendor(estado: int, obras: int)` (0 escondido nunca chega,
  1 fechado, 2 pedido, 3 aberto), `set_tree_plates(acesas, total, nível da Maestria)`, `set_book(lombadas, prateleira,
  itens)`, `set_alchemist(abastecido)`.

## Santuário que abre aos poucos (2026-11-21, `HubGate`, `scripts/core/hub_gate.gd`)
- Gate puro lido do save, um por estação: Portal sempre; Livro e Árvore de Dons com `runs >= 1` (ou um Dom aberto);
  Forja ao vencer o 1º guardião (`firsts.guardian`) ou com Prata para o Temperar I (custo vem do dado, `temper_cost()`);
  Vendedor com `runs >= 3` ou a 1ª Pedra Funda; Juramentos seguem na 1ª vitória; Alquimista desligado. Quem já usou a
  estação (Temperar comprado, ferramenta, pedido, Obra, Dom aberto) a tem aberta. Constantes no topo da classe.
- Estação fechada: `Hub.is_open(id)` falso tira do foco (sem placa nem uso) e do nome flutuante (`HubLabels`); o visual
  apaga a luz e a brasa (`HubLook.set_closed`); o Vendedor já tem o pano (`HubEvolution`). Pendente para o
  environment-artist: uma boca fria da forja e raízes nuas da árvore (hoje só a luz some).
- Apresentação: ao voltar com estação nova aberta, uma linha por estação (`hub_open_*` em `text_pt.tres`) sobre o nome
  do lugar (`HubLabels.announce`, 4 s cada); gravada em `hub.presented` do save (versão 9, uma vez só). Save antigo
  (< 9) conta as abertas como já apresentadas (migração em `SaveData.merged`).
- `--hub-open=all` abre tudo e não apresenta nada (capturas, robô); `tests/hooks/pre_run.gd` o liga para toda a suíte,
  `tests/test_hub_gate.gd` o desliga. `tools/first_tour.gd` pula estação fechada.

## Guia de destrave (PT-5, 2026-11-23, `HubGuide`, `HubGuideOverlay`; testes em `tests/test_pt5_unlock_guide.gd`)
- Pedido do Daniel: toda coisa nova que abre no Santuário é explicada na primeira vez. Ao entrar com algo recém-destravado, depois
  do olhar de chegada, a câmera aproxima suave (`GUIDE_ZOOM` 0,62 da distância, `CamRig.wide`/`lean` sobre o ponto `SHOW` da
  estação), um anel e uma seta apontam o lugar e uma placa diz a frase com a tecla real de `interact` (`{key}`: teclado, controle,
  remapeada). Um guia por vez, em fila; qualquer tecla, botão ou clique avança (meio segundo de carência); depois do último a câmera
  volta ao herói. O herói fica parado enquanto isso.
- A lista é dado: `data/hub_guide/NN_id.tres` (`HubGuideDef`: id, ordem, estação, `text_key`, condição), gerada por `_hub_guide` em
  `tools/make_data.gd`. Guia novo = uma linha lá e um texto `guide_*`. Condições (`HubGuide.CONDITIONS`): `open` (porta da
  `HubGate` aberta), `always`, `wins` (Morvath selado: Juramentos), `account` (O Preparo no Forjador). Hoje: portal (também troca de
  herói), tree (Dons), book (Livro e Compêndio), forge, vendor, account, sworn.
- Uma vez por save: `hub.guided` (versão 11 do save); save antigo conta o que já está devido como visto (`SaveData.merged`). Gravado
  ao começar o guia. A linha `hub_open_*` de uma estação que tem guia na visita não aparece duas vezes.
- Nada com `--bot`, `--smoke`, `--nosave`, `--hero-at` ou `--hub-open=all` (a suíte). Para ver: `--hub --guide=<id>` (`portal`, `tree`,
  `book`, `forge`, `vendor`, `account`, `sworn`; `--guide=all` encadeia todos); forçado não grava. Ex.:
  `tools/gpu.sh shot saida.png --hub --guide=tree --shot-at=5`.
- Pendente: Encantos, anjos, Videira e a escolha de herói como destrave próprio (hoje a escolha de herói está sempre aberta e vai na
  frase do Portal); entram como linhas novas no `_hub_guide` quando tiverem estação e condição.
## PT-4, caminhos sem notação (2026-11-23)
- O fio de ouro no meio de cada caminho (`WAY_FILET`) saiu: lia como linha de interface. Agora `_pave_way` põe as lajes do
  terço do meio mais claras (`WORN_TINT`, material `_worn_stone`) e 6 mm mais altas (`WORN_RISE`, `WORN_SHARE` é a largura
  do miolo gasto); o meio-fio escuro e a junta escura enquadram a trilha. Sem shader nem material novo além de uma pedra
  mais clara; colisão e `HubPlan` iguais. Os losangos riscados nas lajes de uso das estações também saíram (`USE_SLAB`); os anéis do medalhão ficam. Captura de CPU: `docs/gallery/hub/pt4/hub_way_cpu.png`; ver com `tools/gpu.sh shot x.png --hub --look=stylized --cam=near`.
