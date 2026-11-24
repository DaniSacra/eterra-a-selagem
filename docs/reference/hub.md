# Santuário (hub)

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## SV-R, o Santuário da Vigília refeito (2026-11-25, `docs/art/ref/hub01_2026-11-25/eterra_hub/`; testes em `tests/test_hub_sv.gd`)
**Vale este bloco onde ele contradiz os de baixo**: a praça de 50 x 32,5 m, a fonte, a escada do Retorno, a fachada com o
portal ao norte, o terraço, as muralhas laterais, as lajes pavimentadas e as peças decorativas (postes, bancos, urnas, ciprestes,
canteiros) **não existem mais**. Ficam as peças das estações (balcão e toldo, bigorna e forja, dais da Árvore, atril e estante,
arco da Videira, estandarte dos heróis, banca do Alquimista), reposicionadas.
- **Planta** (`HubPlan`): contorno do JSON (`OUTLINE`, 71 x 54 m, em u/v; u para a direita da tela, v para cima) menos três
  bacias de água (`WATER_1..3`, buracos do `FloorShape`, ninguém anda) e menos os dois quartos futuros (`FUTURE_CUT`, o piso
  acaba em v -17). `floor_polys()`, `water()` e `layout(yaw, closed)`. Eixo: Ponto de Vigília (chegada, -24,-7, canto
  oeste) -> Videira (use -7,-5, 17 m, 2,5 s) -> eixo -> Portão (use 32,-6, 8,8 s) com ramais para Dons (10,-3), Mercador
  (12,6), Aposento (-1,19), Biblioteca (19,19) pela galeria alta e Forja (u -17,6, v 16,2) pela passagem do Alquimista.
- **Altura**: o piso é plano (y 0). O `FloorShape` é um plano e o herói não muda de altura, então os patamares de 1,2 m e os
  quartos futuros de -1,2 m do pacote **não existem na simulação** (desvio registrado, sem escadas falsas). Rampas e degraus
  ficam para o acabamento (decal ou degrau fora do caminho, nunca bloqueando) e pedem altura no piso para valer.
- **Prédios** (`HubPlan.BUILDINGS`): massas sólidas nas pegadas do JSON (aparadas: Vigília, Alquimista, Dons, Biblioteca,
  Mercador). `GATE`: massa do Portão com a abertura na face oeste (u 37), arco de aduelas, escuro e folha de luz
  (`station_lights[PORTAL]`). O desenho de ambos é do `HubBlockout` (`scripts/game/hub_blockout.gd`): só massa, plinto,
  cornija, portas e o portão com a pedra que o `HubLook` já tem; o acabamento é do environment-artist.
- **Portas** (`HubPlan.DOORS`, `HubPlan.layout(yaw, closed)`): cada estação do `HubGate.GATED`, o Alquimista (flag
  `HubGate.FLAGS`) e os dois quartos futuros têm porta física na face do prédio (ou na boca do corredor, os futuros).
  Fechada: obstáculo sólido no layout + folha de madeira; aberta: umbral. Quem decide é `Hub.closed_doors()` (lê o
  `HubGate`, inclusive saves antigos e `--hub-open=all`) e a lista fica fixa na visita (o `HubGate` já fixa uma abertura por
  visita). Nenhuma porta fecha rota (teste). A ordem dos `Milestones` não mudou.
- **Câmera**: `CAM_TARGET` (-6,-3), `CAM_REACH` 48, `NEAR_SOUTH` -40 (o Perto segue o herói, sem piso sul a esconder). O
  olhar de chegada (`ARRIVAL_LOOK`) mostra o Ponto de Vigília e a Videira. Testes de enquadramento por estação em
  `test_hub_d` seguem valendo (herói e estação na tela, 16:9, 4:3, 21:9, Perto e Longe). O "portal inteiro de qualquer
  lugar" e o "borda sul sob 0,85" morreram com a praça.
- **Ajustes do look**: `STY_RIM_FLOOR.calm_radius` 60 (o escurecimento do anel de borda estava calibrado para 25 m); as poças de luz
  das estações (`STY_POOLS`) seguem as peças; a cascata distante (`CASCADE`) ficou onde estava, atrás de tudo.
- **Capturas** (só o Game Director): `--hub --look=stylized --cam=near` com `--hub-open=all` (tudo aberto) ou sem (portas
  fechadas), `--hero-at=<estação>` (portal, vendor, tree, smith, book, vine, heroes) e `--hub-use=<estação>`.
- **Acabamento (environment-artist, 2026-11-25; `scripts/game/hub_scenery.gd`, `HubScenery`, chamado no fim do `HubLook.dress`)**:
  só visual, nada colide (o piso é plano). Telhados de quatro águas de terracota (`PAINT_OWN` mantém a cor no look
  estilizado), beirais com fascia, pilastras nos cantos, janelas na face sul (moldura de calcário, cabeça em ponta, vidro
  quente emissivo `#F4DBAB`, caixilho, venezianas alternadas; pulam portas e peças) com flores e glicínia pendurada no beiral.
  Água nas três bacias (`shallow_water.gdshader` via `Canal.water`, azul `#527F8C`, a -0,5 m) com borda de pedra baixa e um
  peixe dourado pequeno na borda mais longa. Ponte: o caminho sul (v -15,5 a -10,5) com guarda-corpos (`RAILS`), três
  arcos ogivais sob a face sul, pilares, cornija e duas cascatas (`waterfall.gdshader`, `FALLS`) mais uma na ponta do
  Portão. Pérgola da Videira (colunas, vigas e caibros, glicínia, folhagem). Posto do Ponto de Vigília: bacia de pedra
  com fogo aceso (a única luz nova), estandarte e o leão no muro. Quartos futuros: pátio rebaixado (-1,2 m) com escada e
  lanternas atrás de cada porta. Portão: leão sobre o arco, dois estandartes, lanternas, capa de pedra. Arbustos, canteiros
  de flores, ciprestes e lanternas ao longo das bordas do piso (`_edge_points`: longe das rotas, estações, portas e
  chegada); árvores redondas em prateleiras de rocha só nas bordas norte e laterais (as do sul esconderiam o piso). Fundo:
  três camadas de montanha (`hub_ridge.gdshader`, cartões ao norte em `RIDGES`) e névoa clara sob o piso; saíram a
  cascata cinza antiga (`CASCADE`) e os cartões de ruínas do `backdrop` (as barras cinzas).
- **Mais claro que as salas**: `AIR`, `STYLE`, `STY_AMBIENT_GAIN` 1,1, `STY_MOON` 0,9, `STY_KEY_SHARE` 0,8, pedra calcário
  `(0.68, 0.62, 0.52)`, céu e névoa azul claro, `CLIFF`/`MIST` claros. **Valores às cegas (sem captura)**: se estourar ou
  ficar chapado, mexer nessas constantes primeiro.
- `HubLook`: removidas as constantes mortas da praça (111: `FACADE_*`, `ARCADES`, `LIONS`, `MEDALLION*`, `BASIN*`, `WAY_*`,
  `WALL_*`, `ORDER*`, `STAIRS_*`, `RAIL_*` etc.), `_far`, `_cascade`, `VISTA`; `_crowns` virou `add_crowns(..., round_crown)`
  (copas redondas para as árvores).
- **Pendente**: conferir em captura (claridade, janelas, bacias, quedas, árvores); interiores das casas; rampas de verdade
  (pedem altura no piso); lanternas só emissivas (sem luz própria, por orçamento).

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
  leão; Árvore de Dons = medalhão de bronze (disco de 1,25 m inclinado 22 graus, aro, leão em relevo, brilho quente aditivo; fase 3a, 2026-11-23, no lugar da `StoneTree`, que era concorrente da Videira) num pedestal de pedra sobre o estrado octogonal, luz quente sem sombra (`DISC_*`, `PEDESTAL`; fechada, só o brilho some); Livro de Ahk aberto no atril
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
  postes, `AWNING_*`, prateleiras atrás, mercadorias, duas lanternas; mercadorias encostadas, `GOODS`); Árvore de Dons (medalhão de bronze, ver acima) sobre
  o estrado no lóbulo leste (as placas baixas dão a volta inteira, sem raízes a evitar); forja no chão a noroeste da bigorna
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
  `HubGate` aberta), `always`, `wins` (Morvath selado: Juramentos), `account` (A Videira aberta, V2), `maga` (a Maga liberada, PT-9). Hoje: portal, tree (Dons), book (Livro e Compêndio), forge, vendor,
  account (estação da Videira), maga (Estandarte dos Heróis), sworn.
- Uma vez por save: `hub.guided` (versão 11 do save); save antigo conta o que já está devido como visto (`SaveData.merged`). Gravado
  ao começar o guia. A linha `hub_open_*` de uma estação que tem guia na visita não aparece duas vezes.
- Nada com `--bot`, `--smoke`, `--nosave`, `--hero-at` ou `--hub-open=all` (a suíte). Para ver: `--hub --guide=<id>` (`portal`, `tree`,
  `book`, `forge`, `vendor`, `account`, `maga`, `sworn`; `--guide=all` encadeia todos); forçado não grava. Ex.:
  `tools/gpu.sh shot saida.png --hub --guide=tree --shot-at=5`.
- Pendente: Encantos, anjos, Videira e a escolha de herói como destrave próprio (hoje a escolha de herói está sempre aberta e vai na
  frase do Portal); entram como linhas novas no `_hub_guide` quando tiverem estação e condição.
## PT-4, caminhos sem notação (2026-11-23)
- O fio de ouro no meio de cada caminho (`WAY_FILET`) saiu: lia como linha de interface. Agora `_pave_way` põe as lajes do
  terço do meio mais claras (`WORN_TINT`, material `_worn_stone`) e 6 mm mais altas (`WORN_RISE`, `WORN_SHARE` é a largura
  do miolo gasto); o meio-fio escuro e a junta escura enquadram a trilha. Sem shader nem material novo além de uma pedra
  mais clara; colisão e `HubPlan` iguais. Os losangos riscados nas lajes de uso das estações também saíram (`USE_SLAB`); os anéis do medalhão ficam. Captura de CPU: `docs/gallery/hub/pt4/hub_way_cpu.png`; ver com `tools/gpu.sh shot x.png --hub --look=stylized --cam=near`.

## A Videira e o Estandarte dos Heróis (V2 e PT-9, 2026-11-23; testes em `tests/test_videira_v2.gd` e `tests/test_hero_station.gd`)
- **Duas estações novas** em `HubPlan.STATIONS` (`VINE`, `HEROES`; `CORE` são as cinco antigas, que mantêm a regra de no máximo 4 s a pé,
  as novas ficam em `EXTRA_WALK` 6,5 s). **Videira**: arco de pedra no lobo leste (peça `hub_vine`, centro (19,0; 10,0), uso (19,0; 8,2)),
  aberta pela mesma condição do antigo Preparo (`Vine.open`, `HubGate`). **Estandarte dos Heróis**: no lobo oeste ao lado do balcão do
  Vendedor (peça `hub_heroes`, centro (-17,5; 9,5), uso (-17,5; 7,4)), abre junto do Vendedor (3ª volta ou Pedra Funda) ou com a 1ª vitória.
  Placa, âncora, `SHOW`, anel de foco e luz de poça (`STY_POOLS`) como as outras; textos `hub_vine*`, `hub_heroes*`, `hub_open_*`. O canteiro leste
  encolheu e foi para (22,4; 1,6) para o caminho da chegada à Videira não cortá-lo.
- **Peça provisória, nó de `HubLook`**: `VineStation` (`scripts/game/vine_station.gd`, nó "VineStation" no quadro do hub, vaso e 3 hastes
  de 3 estágios) com **`grown(branches_bought)`**: dicionário ramo para nós comprados (0 a 3), `Vine.growth(save)` o monta;
  `HubLook.grow_vine` o repassa em `Hub.evolve` (a cada compra). A V3 troca os meshes sem mexer em quem chama. `HeroStation` (dois
  estandartes, o da Maga cinza travada) idem, `HubLook.show_heroes(save)`.
- **V3 (2026-11-23, `tests/test_videira_v3.gd`)**: `VineStation` virou videira procedural: tronco retorcido do vaso (sempre, com um broto) e três ramos
  (Vida a oeste, Provisão ao centro, Perseverança a leste) de 3 estágios cada (`PATHS`, Catmull-Rom; tubo e folhas esferoides achatadas fundidos em uma malha
  por estágio; estágio 3 com cachos e flores âmbar emissivos); musgo escuro (`LEAF_A/B`). Mesma `grown()`; depois da primeira chamada, cada estágio que aparece cresce de escala 0,15 a 1 em 1,1 s (`_swell`, `GROW_FROM`, `GROW_TIME`) ao voltar da tela de compra. `HeroStation`: estandartes de pano em travessa de ferro
  (`BAR_Y`), Guerreiro vermelho com leão dourado, Maga âmbar com estrela de 8 pontas; Maga travada = pano cinza enrolado (`rolls`, `ROLLED`) sem emblema, abre
  com `hero_open`; pé com suporte de espada e de cajado. A estante do Livro (`SHELF`, `SHOW`) foi para (15,1; -3,1) para não cobrir a Videira na câmera Perto.
  Ver: `tools/gpu.sh shot x.png --hub --look=stylized --cam=near --vine=9` (e `--vine=0`).
- **O Portal só desce** (Descer, Ficar; a frase do herói escolhido continua). A troca de herói é `HeroPickScreen` (folha pequena do Livro, um
  cartão por herói). `SaveData.hero_open(data, id)`: **a Maga só com `wins > 0`**; `picked_hero` devolve o Guerreiro se a Maga escolhida
  estiver travada; `next_hero` anda só pelos abertos. Guia `maga` (condição `maga`) quando ela abre.
- O Forjador volta a abrir só a Forja (`Hub._use_smith`); `VineSheet` e as chaves `vine_smith_*` saíram.
- Ver (só a sessão principal): `tools/gpu.sh shot x.png --hub --hub-open=all --hero-at=vine --look=stylized --cam=near` e `--hero-at=heroes`;
  telas: `--hub --hub-open=all --hub-use=vine` e `--hub-use=heroes`; guias: `--hub --guide=account` e `--guide=maga`.

## Marcos do Santuário (SW-O5, 2026-11-25, `Milestones`, `MilestoneDef`; spec em `docs/design/onboarding_sw_o.md`)
- Quando cada estação abre é **dado**: `MilestoneDef` (`id`, `order`, `opens`, `runs_min`, `needs`, `any_of`), em `data/milestones/NN_id.tres`
  (parte `milestones` do `make_data.gd`, do 3A1); sem a pasta, `Milestones.defaults()` traz a mesma tabela. `needs`: `first` (descida-tutorial
  feita ou pulada, ou `runs > 0`), `guardian` (`firsts.guardian` ou `firsts.guardian_run`; a tutorial não grava nenhum), `win`, `stone`
  (primeira Pedra Funda, pedido ou receita: o mesmo teste do uso do Vendedor), `mastery2`.
- Tabela (D-O1 a): 0 `tree` Árvore (`first`); 1 `forge` Forja (3 descidas **ou** guardião); 2 `book` Livro e Compêndio (3); 3 `account` Videira (4);
  4 `vendor` Vendedor (5 **ou** Pedra Funda); 5 `ult` Ultimate (6 descidas **e** Maestria 2; abre como `ult`, não é estação); 6 `maga`
  Estandarte dos Heróis (primeira vitória; os Juramentos seguem `Juramentos.unlocked`).
- **Uma coisa nova por visita**: `HubGate.begin_visit` (chamado no `Hub._ready`) fixa `Milestones.next_to_present` (o marco mais baixo
  alcançado e ainda não apresentado); `is_open` só abre essa e o que já foi apresentado (`hub.presented`) ou usado (`HubGate.used`: Dom aberto,
  Forja/Temperar, Ofícios, nó da Videira). Os outros esperam a próxima volta. `end_visit` no `_exit_tree`. Fora do Hub (testes, `SaveData`) a
  pergunta usa o próximo vivo; `open_ids` (o que o save ganhou, sem o limite) é o que a migração v9 marca como apresentado.
- Nada que já está aberto fecha: apresentado ou usado continua aberto. `Milestones.grandfather(data)` marca como apresentado/guiado o que o
  save antigo tinha (a Ultimate de quem já tem Maestria 2); `SaveData.merged` deve chamá-la ao migrar para a versão dos marcos (3A1).
- Guias: condição nova `ult` (`HubGuide.CONDITIONS`), que pergunta a `HubGate.is_open(&"ult")`; `account` pergunta a `HubGate` (não a `Vine.open`).
  O guia `ult` (estação `tree`, texto `guide_ult`) entra no `_hub_guide` do `make_data.gd`. A frase de abertura `hub_open_ult` está em `HubGate.TEXT`.
- Mudou em relação a antes: a Prata (15 de Prata não abre mais a Forja), Videira não abre mais com o primeiro guardião, Estandarte
  só com a primeira vitória (antes com o Vendedor). Quem já tinha apresentado fica como estava.

## Revisão de arte 2026-11-26 (Portão e céu; environment-artist, sem captura ainda)
- Portão (`HubBlockout._gate`, `HubScenery._gate_dressing`): os muros ao lado da abertura baixaram para `GATE_WALL_H` (3,2 m);
  só a cabeça do arco (a abertura mais `GATE_HEAD_SIDE` de cada lado) sobe até `HubPlan.GATE_HEIGHT`, com capa própria. Colisão
  e ponto de uso intactos. Luz do Portão dourada de Elun: folha e luzes por `light_portal(..., GATE_LIGHT_TINT)`, coluna
  `GATE_LIGHT_COLOR`, poça `STATION_POOLS` do portal em dourado (nada de verde).
- Céu: com a câmera Perto (pitch 30, fov 24) o fundo é o mar de nuvens e a faixa de montanhas a 160 m ou mais não aparecia.
  `RIDGES` aproximadas (v 70, 110, 160) com a crista entre y 12 e 42, `SEA_Y` -30, `SEA_CLOUD_SCALE` 0,07 (nuvens que a
  câmera distingue), cartão do céu mais baixo (gradiente se vê). Ajustar à vista se ainda sair chapado.

## Refino do Santuário, rodada 1 (2026-11-26; environment-artist, SEM captura: tudo às cegas, conferir na GPU)
Pedido do Daniel: o hub estava feio ("fundo branco, paredão cinza, prédios caixa, piscina, postes pretos, bolas verdes").
Meta: ficar perto de `docs/art/ref/hub01_2026-11-25/eterra_hub/01-arte-aprovada.jpg`. Só visual: colisão, planta, pontos de uso
e `HubPlan` intactos (testes `test_hub*` passam). Arquivos: `hub_scenery.gd`, `hub_facades.gd` (novo, `HubFacades`),
`hub_blockout.gd`, `hub_look.gd`, `arena_room.gd` (gancho `cliff_material()`), shaders `hub_cliff` e `hub_vista` (novos).
- **Fundo (item 1)**: o branco era o plano opaco do abismo (`kit.abyss`, a -22 m, cor `MIST` x ruído), não o céu. `HubLook.MIST`
  agora lilás de crepúsculo `(0.44, 0.33, 0.46)` (o plano opaco fica ~0,5 disso; as três camadas translúcidas, mais claras,
  viram bancos de névoa lilás). Céu `SKY_TOP` violeta, `SKY_HORIZON` pêssego, mar `SEA_*` e as três serras `RIDGES` em
  roxo/pêssego/verde-escuro (antes azul-claro); `AIR` com névoa lilás-rosada e lua dourada (`DUSK_GOLD`), `STY_MOON` 1,05 e
  `STY_AMBIENT_GAIN` 0,98 (mais contraste, sombras seguem azuladas).
- **Penhascos (item 2)**: `ArenaRoom.cliff_material()` (gancho novo, `null` nas outras salas) devolve, no hub, o
  `hub_cliff.gdshader`: rocha quente em estratos com rachaduras, musgo/capim nos primeiros metros sob a borda, lavagem dourada
  no alto e, descendo (`CLIFF_FADE` 2 a 19 m), afunda na névoa lilás do abismo. Por cima (`HubScenery._cliffs`): tufos de
  arbusto, flores e glicínia pendendo da face (a cada 2,2 m de borda) e saliências de rocha (a cada 6 m, blocos com o mesmo
  material, musgo em cima), menos sob a ponte e as quedas. Uma queda nova no sul do Portão (`FALLS`).
- **Muretas**: balaústre baixo (`RAIL_LOW` 0,8) por todas as bordas externas que olham para a câmera ou para os lados
  (`_balustrades`: fora das atrás de prédio, da ponte e das bocas dos quartos futuros), a cada 2º poste uma lanterna;
  canteiros de pedra com flores lilás/magenta junto a elas (`_planters`, substituem os tufos soltos).
- **Prédios (item 3)**: parede em calcário creme (`HubLook.facade_stone()`, cor própria `OWN_KEEP`, no lugar do ashlar azul-cinza),
  telhas terracota mais vivas, janelas de vidro âmbar (`WINDOW_GLOW`), caixas de flores sob as janelas (antes tufos no chão),
  pilastras com base e capitel, portas abertas mostram o interior aceso (`DOOR_GLOW`), duas lanternas em cada porta
  (`HubFacades._door_lanterns`, um MultiMesh com as do balaústre). Por estação (`HubFacades`): **Aposento** = grande arco
  ogival de vidro âmbar com travessas, dois estandartes vinho com o leão, tapete vermelho com bordas douradas para o sul;
  **Biblioteca** e **Capela dos Dons** = vitral colorido (cunhas vermelho/ouro/turquesa/violeta) em arco de aduelas; Capela
  com pináculo dourado; **Alquimista** = estufa de vidro (moldura dourada, painéis, telhado de quatro águas de vidro, plantas
  em flor, luz); **Mercador** = toldo vinho e creme (`AWNING_CLOTH`, `AWNING_STRIPE`); **Ponto de Vigília** = bacia redonda
  de pedra em dois degraus (antes um bloco quadrado), estandarte vinho; **Portões das Áreas Futuras** = cadeado de ouro.
  Estandartes do Portão e da Vigília trocados pelos de `HubFacades.banner` (vinho; o `fk.banner` estilizado é petróleo).
  **Portão** = dois leões de pedra sentados (caixas) nos pés dos pilares e a vista violeta no vão (`hub_vista.gdshader`
  atrás da folha de luz: céu dourado-violeta, duas serras, estrada clara).
- **Videira (item 4)**: o tanque grande (`WATER_2`) virou **jardim elevado** (`GARDEN_BASIN`: terra a 0,36 m em meio-fio de
  pedra, flores lilás/magenta, arbustos, alguns ciprestes; é buraco do piso, ninguém anda) e a bacia pequena ficou só nas
  outras duas; **fonte redonda** no meio da pérgola, em cima do canteiro (`HubScenery._fountain`: borda em blocos, água,
  pedestal, taça, cortina e jato com `waterfall.gdshader`, uma luz quente). O canteiro (`_bed`) não põe arbustos onde a
  fonte fica (`FOUNTAIN_CLEAR`).
- **Postes (item 5)**: os de ferro preto saíram; `_lamp` agora é pilar de calcário com lanterna acesa, a cada 21 m de borda
  (antes 9,5) mais as lanternas dos balaústres e das portas (emissivo, um MultiMesh; sem luz própria).
- **Vegetação (item 6)**: nas prateleiras de rocha, 3 de cada 4 viram pares de ciprestes escuros (antes bolas verdes); árvore
  vermelha grande no canto noroeste (`RED_TREE_AT`); glicínia pendente nas paredes e nos penhascos; canteiros e jardim.
- **Chão (item 7)**: faixa de brilho dourado discreto (`_path_glow`, aditivo, 1,5 m) no caminho Vigília, Videira, Dons/Aposento
  e no ramal do Portão; só onde os dois lados são piso (verificado: 100% das amostras no piso).
- **Luz (item 8)**: crepúsculo (lua dourada, névoa lilás) e, de pontual, só 5 OmniLights novas (arco do Aposento, vitral da
  Biblioteca, vitral dos Dons, estufa, fonte; `NOT_FIRE`, `~CROWD_LAYER`, sem sombra), o resto emissivo.
- **Shaders novos (para o aquecimento)**: `assets/shaders/hub_cliff.gdshader`, `assets/shaders/hub_vista.gdshader`.
- **Opções de captura**: chegada `--hub --hub-open=all --shot-at=3`; estações `--hero-at=<portal|vendor|tree|smith|book|vine|heroes>`;
  o Aposento (arco e tapete) com `--hero-at=heroes`, o Portão com `--hero-at=portal`.
- **Ficou de fora / para a rodada 2**: rampas e escadas de verdade (o piso é plano e a planta não muda); o Aposento sem
  escada (só tapete); interiores; telhado da Forja aberto com toldo (a peça da forja ocupa a fachada); árvores de folha
  vermelha só uma; céu e serras só se veem de fato com a câmera Longe; o brilho do caminho e as cores do penhasco/névoa foram
  escolhidos sem ver, ajustar por `HubLook.MIST`, `CLIFF_*`, `PATH_GLOW`, `STY_MOON`.

## Refino do Santuário, rodada 2 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: ficar crepúsculo (a rodada 1 saiu meio-dia lavado). Só visual; colisão, `HubPlan` e pontos de uso intactos
(`test_hub*` passam). Nenhum shader novo (só `hub_cliff.gdshader` editado).
- **1 Exposição** (`hub_look.gd`): `DUSK_AMBIENT` violeta frio (0,6/0,58/0,82), `DUSK_FOG` índigo escuro, `STY_AMBIENT_GAIN` 0,62,
  `STY_MOON` 0,85, `KEY_ENERGY` 0,4, `STY_SHADOW_GLOW` violeta, pedra/piso/sombra do `STYLE` mais escuros e frios,
  `WALL_A/B` do calcário mais escuros. As luzes quentes (janelas, lanternas, fogo) ficam como estavam e saltam.
- **2 Vazio**: `MIST` índigo escuro (0,15/0,1/0,27); céu, serras e mar escurecidos (`SKY_*`, `SEA_*`, `RIDGES`); cachoeiras
  mais longas (`FALLS`, 14 a 17 m) com `FALL_MIST` violeta; copas escuras de ciprestes e árvores lá embaixo
  (`HubScenery._cliffs`, `DEEP_*`, listas `_deep_*`, `DEEP_A/B`).
- **3 Penhasco** (`hub_cliff.gdshader`): blocos facetados (`facet_size`, cada célula com luz própria e fresta escura), sombra
  fria `shade_color` (`CLIFF_SHADE`), escurece com a profundidade (`deep_dark`, `CLIFF_DEEP_DARK`), `CLIFF_FADE` 1 a 15 m,
  rocha `CLIFF_ROCK_A/B` e musgo `CLIFF_MOSS` mais escuros.
- **4 Vãos**: `HubLook.lit_opening(cor, energia, topo)` (emissão em gradiente vertical, escuro em cima, quente embaixo) nas
  portas abertas (`HubBlockout.DOOR_GLOW`, `DOOR_TOP`) e nas janelas (`HubScenery.WINDOW_TOP`, `GLASS_GLOW`). A porta aberta
  da Videira não desenha mais batentes nem lintel nem brilho (a pérgola aparece).
- **5 Telhados**: `TERRACOTTA` (1,05/0,5/0,38), beiral `FASCIA` 0,2 em `FASCIA_COLOR` escuro.
- **6 Flores**: jardim da Videira com `GARDEN_LILAC` 0,2 e `GARDEN_MAGENTA` 0,1 (antes 0,4 e 0,3), canteiros com 3 plantas
  em vez de 4, `WISTERIA_*` e `MAGENTA_*` menos saturados.
- **7 Caminho**: sem faixa; trilha de pedrinhas acesas (`_path_glow`, `PATH_DOT_STEP` 1,3, `PATH_DOT_OFFSET`, `PATH_GLOW`).
- **8 Chegada**: a Vigília ("vigil") não ganha telhado nem janelas (massa e colisão iguais), bacia aberta ao céu.
  Ficou de fora: o arco de pedra atrás da fogueira.
- **9 Portas futuras** (`HubBlockout._arched_door`): arco de aduelas, folha de madeira ogival com tiras de ferro, ombreiras e
  cadeado; escada visual do pátio com 5 degraus (`YARD_STEPS`).
- Ajuste fino: `HubLook.STY_AMBIENT_GAIN/STY_MOON/KEY_ENERGY/MIST/DUSK_*`, `CLIFF_*`, `HubScenery.DEEP_*`, `PATH_GLOW`.

## Refino do Santuário, rodada 3 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: piso quente com poças de luz, vazio menos chapado, lanternas menores, Vigília proposital, escadas de pedra, pérgola densa,
penhasco com relevo e glicínias presas. Só visual; colisão, `HubPlan` e pontos de uso intactos (`test_hub*` passam). Luzes: nenhuma
nova (as poças são malha aditiva). **Shaders editados** (nenhum arquivo de shader novo; entrar no aquecimento se já listado):
`abyss_fog.gdshader` (uniforms `rim_color`, `rim_range`, desligados nas outras salas) e `waterfall.gdshader` (uniform `vanish`).
- **1 Piso quente** (`hub_look.gd`): `STY_FLOOR_STONE` (0,8/0,66/0,56) e `STY_STONE` creme-rosados, `shadow`/`joint_cold` menos frios,
  `KEY` quente `(1,0,9,0,78)` com `KEY_ENERGY` 0,5, `STY_AMBIENT_GAIN` 0,72, escurecimento de borda a partir de `calm_radius` 40 (era 60).
  Poças: `HubGlow` (`scripts/game/hub_glow.gd`, classe nova): discos suaves aditivos (centro e 3 anéis, cor de vértice, uma malha "WarmPools"),
  vértices fora do piso são puxados para dentro. Uma por lanterna (`LANTERN_POOL` raio 2,1, força 0,34) e as das praças em
  `HubScenery.SQUARE_POOLS` (chegada e fogo, Videira, Aposento, Mercador, Dons, Forja, Livro, Portão, praça central).
- **2 Vazio**: `HubLook.MIST` índigo-azul `(0,075/0,085/0,17)`; `HubLook._abyss()` põe `MIST_RIM` violeta `(0,2/0,16/0,32)` nos planos do abismo
  com a distância (`MIST_RIM_RANGE` 46 a 150 m do meio: escuro embaixo da plataforma, mais claro no horizonte); `STY_SHADOW_GLOW` menos azul.
  Copas fundas mais claras e mais densas (`DEEP_A/B`, `DEEP_EVERY` 2,4); cachoeiras brancas (`FALL_COLOR`) que somem na névoa (`FALL_VANISH`
  0,4) e mais 3 (`EXTRA_FALLS`, escolhidas na borda sul, `EXTRA_FALL_*`).
- **3 Lanternas**: `RAIL_LANTERN_EVERY` 4 (um poste em quatro), `LANTERN_SIZE` 0,2, `LAMP_LANTERN` 0,24; âmbar `LANTERN_COLOR` com
  `LANTERN_ENERGY` 1,5, capelinha de ferro (prisma, `LANTERN_CAP`) e halo (cartão voltado à câmera, `LANTERN_HALO*`), três MultiMeshes
  ("Lanterns", "LanternCaps", "LanternHalos") sobre as mesmas transformadas.
- **4 Vigília** (`_vigil_post`, `_vigil_bed`, `_vigil_niche`): a massa virou canteiro elevado (terra, balaústre, flores, dois ciprestes,
  glicínia caindo pelas faces sul e leste) com nicho de aduelas na face sul (fundo escuro, estandarte, duas lanternas); a base da fogueira
  em dois degraus redondos de pedra creme (`facade_stone`, antes invisíveis na cor do piso). Constantes `VIGIL_*`.
- **5 Escadas futuras**: degraus em `facade_stone` creme com friso claro (`STEP_NOSING`), pátio `YARD_FLOOR` mais claro.
- **6 Caminho**: sem pedrinhas; duas fileiras contínuas de lajotas um pouco mais claras (`PATH_TILE`, `PATH_TILE_GAP`, `PATH_TILE_COLOR`,
  malha "PathTiles").
- **7 Pérgola**: telhado de folhas fechado (`PERGOLA_LEAF`, `PERGOLA_LEAF_EVERY`, metade sul mais rala por `PERGOLA_GAP` para ver a fonte),
  cachos de uva roxos pendurados (`GRAPE_*`, cartões pequenos em `add_crowns(..., hanging, card_scale)`), glicínia mais longa; água da fonte
  clara (`FOUNTAIN_DEEP/SHALLOW/SPARKLE`).
- **8 Penhasco**: pilhas de rocha que descem em degraus saindo da face (`ROCK_STEP_*`), mais saliências (`LEDGE_EVERY` 4), cortinas de hera
  pendente (`IVY_*`).
- **9 Glicínias**: `add_crowns(..., hanging := true)` vira o cacho de cabeça para baixo (largo no alto, ponta embaixo); nos penhascos o topo
  fica no nível do piso junto à rocha e o cacho tem `HANG_TALL` 2 a 3,8 m (`HANG_WIDTH`).
- Ajuste fino: `SQUARE_POOLS` e `LANTERN_POOL` (poças), `STY_FLOOR_STONE`, `MIST*`, `PERGOLA_*`, `ROCK_STEP_*`. Pontos de risco sem ver: a poça
  da lanterna da borda sai pela metade (o resto fica sobre o vazio e é cortado); o telhado da pérgola pode esconder a fonte na câmera Perto.

## Refino do Santuário, rodada 4 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Pedido: Portão virado para a câmera, vitrais góticos, cachoeiras finas, arcos pretos, faixa clara, vazio azul-noite, rochas cinza.
Só visual; colisão (`HubPlan.GATE` continua a caixa sólida de 6 m), `HubPlan` e pontos de uso intactos. **Shader novo**:
`assets/shaders/hub_stained.gdshader` (vitral). Editados: `waterfall.gdshader` (uniforms `gap`, `lip`).
- **1 Portão** (`HubBlockout._gate`, `HubFacades.gate`): a abertura olhava para o oeste (de lado para a câmera). Agora o bloco é um
  terraço baixo (`GATE_TERRACE` 0,55 m, a mesma pegada) e sobre ele a FACHADA para o sul: parede (`GATE_WALL_U` u 37,6 a 42, face em
  `GATE_FRONT` v -9, espessura `GATE_DEPTH`, crista `GATE_TOP` 5,7 < 6), arco ogival de aduelas (`GATE_W` 2,4, `GATE_SPRING` 1,5,
  `GATE_RING`), cornija, folha de luz dourada (`portal_glow` de yaw 0, mesmas luzes e `station_lights`), vista violeta no vão
  (`hub_vista`), dois estandartes vinho com o leão na parede ao lado do anel (`GATE_BANNER`), leão dourado sobre a chave
  (`GATE_MEDAL`), dois degraus até a soleira e dois leões de pedra sentados no terraço de frente (`LION_OFFSET`). A parede fica
  fora do ponto de uso (u 37, a borda oeste). Saíram a moldura solta de pilares e a coluna de luz de 16 m (`_gate_dressing`,
  `_light_column`: o cartão translúcido alto era um dos "planos soltos"). `HubBlockout.gate_apex()`/`gate_arc()` dão a curva.
- **2 Vitrais** (`hub_stained.gdshader`, `HubFacades._stained_glass`): losangos pequenos em quatro tons joia dessaturados
  (`STAINED`: âmbar, vinho, azul profundo, verde-musgo) com chumbo escuro, mainel e travessa, mais escuro na borda e aceso por trás;
  `ogive_mesh` sem cores de vértice no vitral.
- **3 Cachoeiras**: fita estreita (`FALL_NARROW` 0,55 da largura), azul pálido (`FALL_COLOR`), listras com vãos transparentes
  (`FALL_GAP`), faixa de espuma na boca (`FALL_LIP`), somem na névoa (`FALL_VANISH` 0,55), alfa `FALL_ALPHA`. Só onde o vazio à frente
  está aberto (`_open_void`: 3, 6, 9 e 12 m para fora, e 2 m de cada lado, sem piso, bacia nem pátio): a "placa branca no buraco" era
  uma queda extra na borda sul do pátio dos Dons, num vão de 1,5 m entre ele e a ponte. Teste em `test_hub_refine.gd`.
- **4 Arcos pretos**: a folha de `HubFacades.ogive_mesh` tinha o enrolamento (winding) voltado para trás (o Godot desenha o lado
  horário), era cortada e o vão mostrava o preto de trás. Corrigido (vale também para o nicho da Vigília, que ganha o fundo escuro).
  Arcos das Áreas Futuras mais baixos (`ARCH_SPRING` 0,8, `ARCH_ARC` 0,52: de 4,1 m para 3 m) e madeira mais clara (`DOOR_WOOD`).
- **5 Faixa clara**: eram as lajotas aditivas do caminho (`_path_glow`, `PathTiles`, rodada 3), duas fileiras translúcidas por cima das
  lajes. Removidas (o caminho segue gasto por `_pave_way`). Além disso `HubGlow` não estica mais vértices fora do piso para dentro (isso
  gerava triângulos longos e inclinados): descarta o triângulo que tem vértice fora do piso.
- **6 Vazio**: a causa do roxo chapado e das copas fantasmas era a névoa de altura do mundo (`WorldAir.FOG_HEIGHT_DENSITY` 0,6, cor
  `DUSK_FOG`): opaca poucos metros abaixo do piso, o que está lá embaixo (planos do abismo com `rim_color`, copas) virava só a cor da
  névoa. No hub `HubLook.HUB_FOG_HEIGHT` 0,05 (chave nova `fog_height_density` em `RoomMood.air_values`; outras salas não pedem) e
  `DUSK_FOG` azul-noite pouco saturado (0,1/0,105/0,16); `MIST` (0,07/0,075/0,14), `MIST_RIM` cinza-azulado mais claro (0,17/0,17/0,3)
  de 24 a 110 m; céu, mar, serras e `DEEP_A/B` (copas fundas, mais escuras que o plano) em azul-noite.
- **7 Rochas**: `CLIFF_ROCK_A/B` cinza-quente (0,4/0,36/0,31 e 0,23/0,22/0,24), `CLIFF_MOSS` mais verde, `CLIFF_SHADE` sem rosa.
- Ajuste fino se algo sair errado: `HUB_FOG_HEIGHT` (mais alto = mais névoa embaixo), `GATE_*`/`LION_OFFSET`/`GATE_BANNER`, `FALL_*`,
  `hub_stained` (`cells`, `lead`, `brightness`). Risco sem ver: a fachada do Portão (5,7 m) pode tapar o que está atrás dela; o shader do
  vitral ainda não foi visto; a névoa mais fina pode deixar os planos do abismo visíveis demais.

## Refino do Santuário, rodada 5 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
Só visual; colisão, `HubPlan` e pontos de uso intactos; nenhum shader novo.
- **1 Arcos pretos do primeiro plano de `r4_tree`**: eram os arcos da PONTE do caminho sul (`HubScenery._bridge`), não os das Áreas
  Futuras. A linha de arranque estava em +2,2 m (acima do piso) e eles subiam até ~4,5 m na frente da câmera, com um painel preto
  (`GATE_DARK`) no vão. Agora `ARCH_SPRING` -4,1 (o anel todo abaixo da cornija, ápice ~ -0,7 m) e o vão é uma ogiva (`ogive_mesh`)
  de pedra escura (`ARCH_BACK` 0,38 do tom interno), nunca preto chapado. As portas das Áreas Futuras já tinham folha de madeira.
- **2 Estufa** (`HubFacades._glasshouse`): vidro verde-âmbar escuro (`GLASS_PANE`, `GLASS_ALPHA` 0,34, `GLASS_EMIT*` baixo), caixilhos
  de ferro escuro mais grossos (`GLASSHOUSE_IRON`, `FRAME_THICK`), telhado em duas águas (`inset` 0) com caibros em cada poste, painel
  âmbar aceso atrás das plantas (`lit_opening`) e luz interna menor (`GLASSHOUSE_GLOW`).
- **3 Portão**: folha e luzes a 60% (`HubBlockout.GATE_SHEET_DIM`), para a vista violeta aparecer; a borda dourada fica.
- **4 Portas abertas**: `lit_opening` ganhou o parâmetro `mid` (gradiente de três pontos: interior escuro na metade de cima, luz
  junto ao chão); `DOOR_TOP` 0,03, `DOOR_MID` 0,22, energia 0,8, mais faixas escuras de batente (`DOOR_REVEAL`) e soleira de pedra.
- **5 Glicínia de quina**: tufos/cortinas pendurados na borda (`_cliffs`) não nascem a menos de `HANG_CLEAR` (4 m) da chegada, de
  pontos de uso e de portas (`_near_avoid`).
- **6 Muretas e lanternas**: balaústre só onde a borda dá para o vazio (`_facing_court`: com piso de novo a 2,5 ou 4,5 m para fora,
  é vala entre pátios e fica só o lado sul); lanterna de poste ou de lampião no máximo a cada `LANTERN_APART` (6 m,
  `_lantern_free`; os lampiões das Áreas Futuras são exceção); canteiros a cada 13 m (era 9).
- **7 Rochas**: `_rock_size` (um terço alto e estreito, o resto com os três tamanhos variados), chanfro `ROCK_CHAMFER` 0,28 com
  quina quebrada, giro de até 0,5 rad e inclinação `ROCK_TILT` 0,14.
- Ajuste fino: `GATE_SHEET_DIM`, `RAIL_TRENCH`, `LANTERN_APART`, `ROCK_*`, `GLASS_*`. Risco sem ver: `_facing_court` pode tirar um
  balaústre que ainda era borda; a ponte sem o arco alto deixa o rosto sul dela mais baixo.

## Refino do Santuário, rodada 6 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU)
- Vitrais (`hub_stained.gdshader`, `HubFacades.STAINED`): cerca de 60% âmbar/mel (jewel_a e jewel_d), vinho e azul profundo dessaturados como acento, chumbo mais fino (`lead` 0.05), brilho 0.78.
- Vão do Portão: `GATE_SHEET_DIM` 0.3 (folha) e `GATE_LIGHT_DIM` 0.4 (luzes que douram o chão); `hub_vista.gdshader` com céu baixo, brilho do sol e estrada mais escuros, para a vista violeta aparecer.
- Portas e janelas: janelas (`WINDOW_TOP` 0.06, `WINDOW_MID` 0.25) e o arco do Aposento (`_warm_glass`) usam `HubLook.lit_opening` com interior escuro; portas abertas ganham faixa escura sob o lintel (`DOOR_HEAD`).
- Escadas das Áreas Futuras: degrau em tom quente escuro (`STEP_TREAD`), friso mais escuro (`STEP_NOSING`) e faixa de sombra no espelho (`STEP_SHADOW`).
- Canteiro da Vigília: mureta contínua com coroamento (`VIGIL_WALL`) e só 2 pilares (cantos sul), sem balaústres.
- Não feito: árvore vermelha extra e glicínia nova no Aposento/Biblioteca (já há glicínia de `_wall_flowers` onde não há peça).

## Rodada 2 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU; testes em `tests/test_hub_levels.gd`)
Pedido: níveis e escadas de verdade, escada do Aposento, flores limpas, mais uma árvore vermelha, glicínias nos beirais. A simulação segue
no plano (colisão, `FloorShape`, `NavGrid`); só os pés do herói e o desenho seguem um campo de altura.
- **Níveis** (`HubPlan`, `HubLevels`, classe nova `scripts/game/hub_levels.gd`): terraço alto (`TIER_H` 1,2) = todo o piso com v >= `TIER_V`
  (14,06): galerias, Forja, Aposento, Biblioteca (menos a bacia do jardim, que fica baixa: a borda da galeria sobre ela é o muro de
  arrimo). Dois lances de escada sobem para +v em `STAIR_STEPS` 6 degraus: `STAIR_A` (u -17..-13, v 10..14,06: o caminho da Forja, as
  duas laterais são borda do piso: contorno e bacia) e `STAIR_B` (u 1,5..12,4, v 10,4..14,06: o eixo principal, até o Aposento e a
  Biblioteca; a lateral leste é a fenda `STAIR_CUT` na planta, um buraco de 0,6 m entre o lance e a praça do Mercador, coberto por um
  parapeito de pedra). A piscina do Mercador (`WATER_3`) acaba em v 10 para não invadir o lance. `HubPlan.TIER_H = 0` desliga tudo (hub plano).
  - `HubPlan.ramp_at(p)` é o campo liso (o que levanta o desenho), `height_at(p)` o em degraus (os pés), `ground(world)`; contínuo em todo o piso
    (teste varre o piso a cada 0,25 m: nenhum salto maior que um degrau). `Arena.ground_at(p)` (só `hub` devolve algo) e `Player._ground`
    (suavizado, `GROUND_EASE` 28) põem `position.y` do herói; câmera e colisão seguem no plano. Placas de estação e luz-guia usam
    `HubPlan.anchor/ramp_at` (altura da estação); `hero_at.y` é o `position.y` do herói.
  - **Como o cenário sobe**: tudo é construído plano, como antes; o último passo do build (`HubLook.build_steps`, depois de `merge` e de
    `stylize`) roda `HubLevels.raise_steps(look)`: soma `ramp_at` aos vértices de cada `ArrayMesh` próprio (pedra fundida, piso, falésias,
    balaústres, poças), às instâncias de cada `MultiMesh`, à origem de luzes, partículas, `HubNpc` e de meshes primitivos ou compartilhados
    (barras, estátuas). Sem auditar peça por peça; ignora meshes chamados `Garden` (`KEEP_NAMES`, o solo do jardim). Passos de 60 mil vértices.
    Depois `HubLevels.stairs(look)` desenha os degraus (altura absoluta): bloco por degrau, friso e faixa de sombra no espelho (as constantes
    `HubScenery.STEP_*`), e o parapeito escalonado sobre a fenda.
  - **Aposento** (item 2): degraus de pedra creme com tapete vermelho e filetes dourados (`HubLook._hero_steps`, peça `hub_heroes_steps`,
    obstáculo sólido `HERO_STEPS` v 20..21,2, 5 degraus até `HERO_PLINTH` 0,8) e o estandarte sobre o plinto (`HERO_STAND` v 21,2..22, plinto + friso, `HeroStation` a
    `HERO_PLINTH` + 0,1). O tapete do chão (`HubFacades.CARPET_RUN`) começa no pé dos degraus (v 20). É uma escada de monumento (sólida), a porta
    do Aposento continua o vão ao lado; o ponto de uso (-1, 19) fica a 1 m do primeiro degrau.
- **Flores** (item 3): `hub_flower.gdshader` (novo) desenha o tufo inteiro num cartão: lâminas verdes pontudas e 7 flores em disco com miolo
  claro e borda escura, bordas cortadas limpas (sem ruído nem tracejado; sem `see_through`, sem sombra). `HubLook.add_blooms` (3 cartões por
  ponto, `BLOOM_*`) substitui `add_crowns` para "Flowers", "Magentas" e "Wisteria"; os discos ficam redondos pelo `squash` (altura sobre largura do cartão).
- **Árvore vermelha** (item 4): `RED_TREE_2` (u -31,6, v 6,5, 85% do tamanho) atrás do Alquimista, na falésia oeste; `_red_tree_at` desenha as duas.
- **Glicínia** (item 5): cachos do beiral mais densos e longos (`WALL_WISTERIA_EVERY`, 1,2 a 2 m) e cortinas nos dois cantos da frente
  dos telhados da Biblioteca, do Aposento, da Forja, da Capela e do Mercador (`_cascades`, `CASCADE_*`: 3 cachos de 2,2 a 3,4 m escalonados),
  fora de portas, arcos e estações; cachos agora são o tassel de `hub_flower` (flores em fila que afinam e balançam).
- Testes: `test_hub_levels.gd` (campo, degraus, sem salto, `Arena.ground_at`, hub construído levantado, degraus desenhados); `test_hub_sv`
  (4 buracos: 3 bacias e a fenda) e `test_hub_ui` (a placa livra o herói na altura dele) ajustados. Shader novo: `hub_flower` (conjunto de aquecimento refeito).
- Ajuste fino: `HubPlan.TIER_H/TIER_V/STAIR_*`, `HubLevels` (`TREAD_THICK`, `PARAPET_*`), `HubLook.BLOOM_*/TASSEL_*`, `HubScenery.CASCADE_*`, `RED_TREE_2`.
  Riscos sem ver: a fatia de piso entre o parapeito e a praça do Mercador; balaústres/falésias nas laterais dos lances seguem a rampa lisa
  e os degraus em bloco ficam por cima (pode aparecer o chão liso entre eles); o solo do jardim (`Garden`) na borda sul fica 0,84 m abaixo da
  galeria (muro de arrimo = a falésia); coisas criadas depois do build (nada conhecido) ficariam sem a altura.

## Rodada 3 (2026-11-26; environment-artist, SEM captura: às cegas, conferir na GPU; lista em `docs/art/ART_REVIEW_2026-11-26b.md`)
Os 10 itens do art-director. Tudo provisório (formas simples).
1. **Praça baixa no lugar do abismo** (`HubPlan`, `HubLevels`, `HubScenery._plaza`): o recorte do `OUTLINE` entre os dois corredores das Áreas
   Futuras segue como está (paredes do recorte = borda do piso com corrimão); dentro dele há um piso novo, `PLAZA` (0,4 m `PLAZA_GAP` para dentro
   das paredes, então uma fresta de vazio separa a praça dos corredores e do caminho do Portão), `PLAZA_DROP` 1,2 abaixo do terraço baixo, com
   dois lances largos (`PLAZA_FLIGHTS`, 6 degraus, descem para -v a partir de v -8,2, lado da Videira), um jardineira de pedra entre eles
   (`PLANTER_BOX`, obstáculo `hub_planter`) e um canteiro grande de flores no meio (`PLAZA_BED`, `hub_plaza_bed`). `floor_polys()` junta
   (`merge_polygons`) contorno, praça e lances num piso só (sem buraco novo: o espaço entre os lances é piso sob a jardineira, uma aba de
   `PLAZA` sobe até v -8,3). Campo de altura: `ramp_at` ganha `_plaza_ramp` (lances lisos e `PLAZA_DROP` em `PLAZA_LOW`), `height_at` os degraus
   (descendo). `HubLevels` agora também abaixa o que está na faixa da praça (`PLAZA_FOOT`..`PLAZA_TOP`) e `stairs` desenha os degraus
   (`_plaza_flights`). Decoração do cenário some perto da praça (`HubPlan.near_plaza`: plantas, pedras, hera, corrimão da própria praça; o corrimão
   das paredes do recorte fica, olhando para baixo); lampiões e flores da praça em `_plaza`. `EXTRA_FALLS` 0: cachoeira só em `FALLS` (u >= 16).
   `PLAZA_DROP` 0 devolve o chão plano. Sem mudança em portas, `USE`, `ANCHOR`, `ARRIVAL`, `HubGate`; os pátios das Áreas Futuras continuam a -1,2
   (no mesmo nível da praça). Segurança: a praça é alcançável só pelos lances; as Áreas Futuras seguem fechadas (as portas estão nos corredores, a 0).
2. **Videira, gazebo redondo** (`HubScenery._pergola`, `GAZEBO_*`): anel de 8 colunas creme em volta da fonte, cornija de pedra, coroa de folhas
   aberta sobre a fonte e mais rala para a câmera, cachos e uvas entre as colunas; piso: degrau redondo de pedra (`HubLook._bed`, `GAZEBO_DAIS`),
   sem terra escura; fonte mais larga (`FOUNTAIN_BASIN` 1,9). O pórtico de pedra saiu (`_vine_arch`: só o vaso numa base redonda; o colisor
   `VINE_ARCH` fica). Não mexi no `USE` da Videira (-7, -5, a 2,3 m do vaso, dentro do foco de 2,2 m do vaso... a conferir na captura).
3. **Piso**: `STY_FLOOR_STONE` (0.86, 0.75, 0.58), `slab_hue` 3, lajes de 0,6 m (`HUB_SLAB`, era 1,2) e juntas de 0,03 (`HUB_JOINT`).
4. **Fundo**: céu `SKY_TOP` azul só no alto, `SKY_HORIZON` lilás; falésia cinza-lilás (`CLIFF_ROCK_*`) e rocha em pé atrás das bordas oeste e norte
   (`HubScenery._backdrop`, `BACKDROP_*`: blocos de 6 a 9,5 m, musgo e cipreste no topo).
5. **Flores** (`HubLook.BLOOM_*`): 0,6 de altura, 14 flores por tufo, largura `BLOOM_CLUMP` 1,0; três tons por canteiro (roxo, magenta, creme 15% `CREAM_SHARE`).
6. **Balaustrada fina** (`HubScenery._thin_rail`, `RAIL_*`): pilar 0,5 m, 0,8 m com o capitel, corrimão creme (pedra de fachada), balaústres pequenos,
   lanterna a cada 4 pilares.
7. **Hera e ciprestes**: `IVY_EVERY` 4; nenhum cipreste a menos de `PATH_CLEAR` 3 m dos caminhos (`_clear_cypresses`).
8. **Ponto de Vigília**: arco ogival alto (vão 2,4, 3 m) num pano de parede (`HubPlan.VIGIL_ARCH`, obstáculo `hub_vigil_arch`) logo a oeste do braseiro,
   voltado para a praça, com dois estandartes e lampiões (`_vigil_niche`, `VIGIL_ARCH_*`). O nicho baixo antigo saiu.
9. **Folhagem**: `IVY_A`, `TREE_DARK`, `LEAF_DARK`, `CYPRESS_A` e o cipreste do cenário mais claros (~30%); `STY_CROWN_RAGGED` 0,08.
10. **Toldo do Mercador**: vinho `AWNING_CLOTH` e creme `AWNING_STRIPE` (0.9, 0.82, 0.68).

## PM-2 (2026-11-26 noite; environment-artist, SEM captura: conferir na GPU)
- Fundo (item 4): `HubLook.MIST` (o plano opaco do abismo e a névoa das falésias) e `MIST_RIM` de azul-marinho para lilás
  `(0.2, 0.18, 0.3)` / `(0.38, 0.31, 0.48)`; mar de nuvens `SEA_FAR`/`SEA_NEAR` lilás, `SEA_CLOUD` 1,2 e escala 0,11 (mais
  mancha); céu `SKY_TOP` mais azul e `SKY_HORIZON` lilás. Novas serras a oeste, `RIDGES_WEST` (cartões virados para leste em
  u -38, -58, -92, `_ridge_card`), para o vazio ao lado do piso não ser liso. Se o canto esquerdo da `r8_arrive` ainda sair
  chapado, subir `SEA_CLOUD` ou aproximar a primeira serra.
- Folhagem (item 9): `IVY_A` e `TREE_DARK` com o valor subido cerca de 30% (sombra oliva), cipreste `CYPRESS_SHADE` 1,2 (era
  0,95), borda das folhas `STY_CROWN_RAGGED` 0,05 (era 0,08).
- Hera e cipreste (item 7), nicho em arco (8) e Portão de lado: já feitos na rodada 3 (`IVY_EVERY` 4 só nas bordas, `VIGIL_ARCH`,
  `GATE_WALL_H`); só conferir nas capturas.
