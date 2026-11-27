> Índice: [ui.md](../ui.md)

## Objetivo, legenda da chegada e primeira descida (Fase 3, lote 3A3, 2026-11-25; `docs/design/onboarding_sw_o.md`; testes em `tests/test_objective.gd`)
- **Objetivo (SW-O2).** `Objective` (`scripts/core/objective.gd`, puro): `pick(ctx) -> StringName` devolve a chave `obj_*` da linha
  (&"" nenhuma); `enabled(data, tutorial)` (tutorial sempre; senão `runs <= 3` e `options.objective`, padrão ligado); `text(key)` troca
  `{attack}`, `{dodge}`, `{interact}` pelas teclas reais (`UiKit.action_label`); `tutorial()` pergunta a `FirstDescent.active` quando o
  arquivo existir (senão só `--first`). Precedência: tela aberta esconde (a da Bênção devolve `obj_bless`, que o HUD não mostra);
  Morvath e guardião nomeiam a sala; luta vence explorar; loja; recompensa no chão vence portas; Antessala: lajes (a 6 m, antes de
  atravessar), vaso (a 5 m, se nenhum quebrou), depois "Encontre um caminho".
- **Linha** (`ObjectiveLine`, `scripts/ui/objective_line.gd`): losango de ouro e Alegreya 18 sob "Sala N de M" (`Hud.OBJ_TOP`), a antiga some
  em 0,2 s, a nova entra em 0,3 s e um filete de ouro corre por baixo (0,5 s); `pulse()` pisca uma vez (herói parado 25 s na Antessala).
  `Hud._update_objective` lê o contexto a cada 0,2 s (`objective_context`) e esconde a linha sobre telas, pausa e para o robô.
  Lajes e vasos vêm de `Rooms.plates.nodes` e `Game.breaks.rules`; "atravessou" é a mudança de lado do centro das lajes.
- **Antessala e Sala 00 (2026-11-26, `docs/reference/rooms.md`)**: a linha de objetivo na Antessala lê as dicas (`lesson_attack`, `lesson_heavy`, `lesson_power`, `lesson_special`, `lesson_dodge`, `lesson_trap`; a Maga
  `_maga`); na Sala 00 diz `obj_altar` ("Receba a Bênção no altar") e, com a Bênção tomada, `obj_find_way`. O botão de usar sobre o altar é a `StationSign` `altar_bless` (verbo `hub_use_altar_bless`). A primeira
  vez de um save aparece `altar_intro` (aviso de 7 s, `hud.show_notice`, uma vez: `FirstTips` id `altar`). O HUD mostra o nome da sala no lugar de "Sala N de M" na Antessala e na Sala 00 ("Caminho para Valmor" é o
  nome do lugar, 2 s; "Câmara de Preparação" o da sala). A porta não leva placa nem medalhão. A chegada do cometa fecha o HUD (`ArrivalScene` esconde `game.ui`) e devolve os botões ao fim.
- **Opção** "Mostrar objetivo" na página Conforto das Configurações (`opt_objective`, lê `options.objective` com `get` e padrão ligado).
- **Dicas.** `FirstTips.pick` ganha `ctx.tutorial`: na descida guiada a dica `fight` não vem e a `hold` vem sem ela. Chaves das dicas
  próprias das salas: `first_tip_fight|archer|hold|armor|knight`.
- **Legenda da chegada** (`ArrivalCaption`, `scripts/ui/arrival_caption.gd`, filho do `Hud` em `Hud.arrival_caption`):
  `show_line(key, seconds = 0)` (padrão 0,5 + 4,0 + 0,6 s; pulada, `ArrivalCaption.SKIPPED` 2,5 s), `clear()`. Marfim, sombra, sem
  caixa, 190 px acima da base. O `show` do doc virou `show_line` porque `Control.show()` já existe.
- **Pular a primeira descida** (D-O2 b): a pausa da descida guiada ganha o link "Pular a primeira descida" (`PauseMenu.skip_first`,
  pergunta em `AskPage`, "Voltar" em foco); a escolha de save, ao criar um save novo quando outro espaço já tem descidas, pergunta
  "Fazer a primeira descida guiada?" (`SaveSlotScreen.needs_first_ask`; "Ir direto ao Santuário" grava `first = 2` antes de `chosen`,
  Esc volta aos cartões). `FirstTips.mark_skipped(data)`: `first` 0 vira 2, 1 fica 1.
- **Quinto losango** (SW-O5): `Hud.ult_open()` pergunta a `Milestones.ult_open(Save.data)` (aberto sem o arquivo e sem save); fechado, o
  losango do Golpe Supremo e a carga fina não aparecem (antes aparecia trancado com "Maestria N").
- Os textos novos da fase foram aprovados pelo Daniel como estão (2026-11-26).

## Regar segurando e Espólios (PT-25-3 e PT-25-6, 2026-11-25; testes em `tests/test_spoils_hold.gd`)
- **`HoldPress`** (`scripts/ui/hold_press.gd`): componente comum de "segure para confirmar" sobre um `Button`, em cima do
  `HoldGauge` dos Dons. `HoldPress.attach(botão, tempo, dreno)`; segurar Enter/A (com o foco no botão) ou o botão esquerdo do
  mouse enche um anel dourado sobre o botão (`TIME` 0,8 s); ao encher emite `completed` uma vez; soltar ou perder o foco
  cancela e o anel esvazia. O clique do botão é consumido (`pressed` nunca dispara por ele). Botão desabilitado não segura.
  A Videira usa: `VineScreen.hold.completed` chama `confirm()` (compra e aloca de uma vez; a Enter da barra de baixo só
  seleciona, o mouse segura no botão). O texto do botão virou "Segure · Regar · N material" (`vine_water`).
  Os Dons seguem com a barra própria no botão (`DonsPanel`); migrar para o `HoldPress` é opcional e fica para depois.
- **Espólios = a tela de fim (`EndScreen`) nos dois finais, inclusive a primeira descida** (o título é "A luz não se apaga" /
  "Morvath foi selado"). Ganhou: "Salas vencidas" e "Ouro" na fileira de números (`_stat_rooms`; `stats.rooms_won`, `stats.gold`)
  e **"Liberado nesta descida"** (`_opened`; `stats.opened`, ids de marco), uma linha por peça do Santuário aberta pela descida
  (`end_open_<id>`: Dons, Forjador, Livro de Ahk, Videira, Vendedor, Golpe Supremo, Estandarte dos Heróis). `Game` guarda
  `milestones_before` (`Milestones.reached`) ao começar e `RunSpoils.opened(antes, depois)` (puro) dá os novos ao abrir o fim.
  O botão do Santuário agora diz "Continuar" (`end_menu`) e continua sendo o primeiro (vitória) ou o segundo caminho (derrota);
  na primeira descida (`home_only`) é o único. Materiais, Bênçãos e Maestria já vinham antes.

## PT-26 (2026-11-25, teste do exe e2a59f82): Videira, anjo, aviso de substituir, Forja
- **Videira compra como os Dons** (`VineScreen`, `HoldPress`): cada estrela tem seu `HoldPress` (anel sobre a própria estrela); segurar o
  botão esquerdo (também sobre a etiqueta, `HoldPress.forward`), o botão de aceitar ou o do controle numa estrela que pode crescer
  (`_can_hold`: figura aberta e estado AVAILABLE) enche o anel e compra (`_water_hold` -> `confirm`). Do céu inteiro, ou numa raiz que
  não pode crescer, o toque abre a figura ou mostra o motivo (o `gate` do `HoldPress` deixa o toque passar). O botão Regar do painel segue
  funcionando do mesmo modo. Testes em `tests/test_spoils_hold.gd`.
- **Anjo sozinho** (`EncounterScreen._meet`): com 1 anjo não há tela de entrada; vai direto às cartas (`_take`), que mantêm a arte do
  anjo (`BoonChoice.by_angel`). Com 2, a tela de sempre. `--encounter=sarael` (um id) também vai direto às cartas; para ver a tela do
  par, `--encounter=sarael,nivael`.
- **"Substitui: <Bênção>"** (`BoonCard._replace_warning`, nó `ReplaceWarning`, chave `choice_replaces`): numa carta que ocupa a mesma
  ação de uma Bênção já tida (`BoonState.replaced_by`, a regra de slot), aviso em cor de alerta acima do "Sai / Entra". Troca de raridade
  (carta de upgrade) mantém só a aba "Sobe uma raridade".
- **Forja mais clara** (`ForgeScreen`, `ForgePlate`): linha fixa sob o título (`forge_how_line`; na Oficina, `forge_workshop_lead`), cabeçalhos
  nas três colunas da placa (Este ponto, O que muda, Custo), "Vale a partir da próxima descida, em todas as seguintes" sob o preço de
  qualquer ação da Emeth, dica do martelo com "Voltar não gasta". Na primeira visita de cada save abre a folha "Como a Forja funciona"
  (`intro`, 4 frases; confirmar, voltar ou clique fecham; guarda `forge` em `data.hub.tips`, `FirstTips`); nunca sem save, com o robô ou nos
  testes. Para capturar a folha: `--forge-intro` (não grava). Sem mecânica nova.

## PT-26 (2026-11-25): ícone de mouse e HUD mais legível
- **Ícone de mouse** (`MouseGlyph`, `scripts/ui/mouse_glyph.gd`; o desenho em `MouseGlyphArt`, sem autoloads, salvo como
  `assets/ui/keys/mouse_1|2|3.png` por `tools/make_mouse_icons.gd`): um mouse visto de cima com o botão certo aceso
  (esquerdo, direito, meio). Onde o texto dizia "Clique esquerdo/direito": o losango do HUD (`ActionSlot._draw_mouse`),
  a caixinha de tecla (`StationSign.KeyCap.mouse`, usada na barra de ações, Como jogar, Configurações), a placa da
  carta e da lista de Habilidades (`BoonCard.key_plaque` vira `TextureRect`), a frase da carta (`BoonChoice.key_in_text`
  com `marked`, `[img]`), a linha de objetivo e a dica (`UiKit.keyed_line` + `MouseGlyph.keyed(texto)`, que troca os
  nomes por `[img]` e escapa `[`), e o valor da linha de tecla em Configurações. Com controle ou tecla continua o nome.
  Para pôr em outro texto: `RichTextLabel` com `MouseGlyph.keyed(palavras)`. Teste: `tests/test_pt26_ui.gd`.
- **Coluna de Bênçãos (direita) mostra todas** (`BuildColumn`): antes só a última Bênção de cada botão (`by_button`
  sobrescrevia) e as passivas ficavam numa fileira escondida no canto de baixo (`Hud._passives`, agora oculta). Agora as
  seis linhas por botão seguem, e as demais (passivas, repetidas no botão) vêm em linhas compactas (`extras`, até
  `MAX_EXTRAS` 8 e "+N"). Estado: em recarga (varredura escura sobre o medalhão e os segundos, `hud_build_wait`),
  pronta (ponto verde, `Entry.ready_dot`), passiva (sem ponto nem varredura, só o nível). `BuildColumn.tick(skills)` a cada quadro.
- **Leitura do HUD**: legenda nas barras finas (`HudBar.caption`, "Supremo" na dourada, "Magia" na azul); segundos
  restantes sobre os losangos Q e E em recarga (`ActionSlot.secs_left`, `Player.move_secs`).
- **PT-26-4, segunda volta (HUD legível)**: o Daniel achou o HUD difícil de entender. `BuildColumn` agora tem uma linha por
  Bênção com o medalhão (32 px) à esquerda e o NOME à direita (`boon_<id>`), e embaixo o estado (segundos de recarga, ou
  "Nv. N" só quando N maior que 1; "Nv. 1" em tudo era ruído). Largura 168, margem segura `BuildColumn.MARGIN` (14) da
  borda direita (`Hud.EDGE_RIGHT` acompanha), no máximo `MAX_ROWS` (12) linhas, o resto vira "+N" (antes a última fileira
  saía da tela). Escolha: nome sempre ao lado (e não painel no Tab) porque ler o que cada ícone é não pode custar uma
  tecla na horda; o texto é pequeno (13) e fica no canto. Barra de ações: nome curto fixo sob cada losango
  (`ActionSlot.label_text`, chaves `hud_slot_*`: Ataque, Especial, Brado, Investida, Supremo, Esquiva) e o mouse maior
  (`ActionSlot.MOUSE_H` 30). Ícone de mouse redesenhado (`MouseGlyphArt`: 18x26, PNG a 3x, botão aceso em dourado forte
  `LIT`, corpo escuro); nas cartas e na lista de Habilidades 1,25x. O nome do golpe que aparece acima da fileira
  (`_move`) é o golpe executado, continua. Ouro: fica sem rótulo (a moeda diz); decisão do designer.
  Capturas a olhar: `--bot --autopick --seed=5 --shot-at=9` em 1280x720 e 1920x1080, e com 8+ Bênçãos.

## Revisão de UI de 2026-11-26 (ART_REVIEW itens 1, 13 a 16 e quickwins)
- **Placa do rodapé** (`Hud._build_floor_veil`, nó `FloorVeil`): gradiente de tinta de 0 a 55% (`FLOOR_VEIL_ALPHA`), 100 px a
  720 linhas (150 a 1080), entre 25% e 75% da largura, sob a barra de ações; o braseiro do cenário não aparece mais atrás dos losangos.
- **Maestria do Supremo**: selado, o losango não tem legenda flutuante; o nome embaixo troca "Supremo" por "Maestria N"
  (`label_text`). A legenda "Pronta"/"Carga N%" fica como estava (`Hud.ult_caption`).
- **Contador de recarga** (`ActionSlot._draw_secs`): desenhado por último, sobre uma placa de tinta em losango, para o traço
  de recarga e as cargas não formarem "(4)" ou "-2-". Mesmo estilo em todo losango.
- **Cartas de Bênção de botão**: `BoonChoice.facts` não mostra "A cada" (o `cooldown` delas não é usado); mostra "Intervalo"
  (`gap`) quando há. Só Bênção automática (`SkillDef.alone`) diz "A cada N s".
- **Forja**: a folha "Como a Forja funciona" tem 3 frases (`forge_how_1..3`) e o fecho é "{key}  Começar" em dourado.
- **Videira**: sem rosto no Leão; os vértices da juba sem nó viram estrelas fracas (`VineLayout.FAINT`, `faint()`), desenhadas
  em `VineSky`; rótulo de raiz crescida com filete verde `#94A76A` (`VineTag.VINE_GREEN`); "Raízes crescidas no céu todo: n de m"
  (a contagem é do total das três figuras); a barra diz "Segure para regar".
- Texto "Clique esquerdo/direito" só nas chaves `mouse_1`/`mouse_2`; em todo o resto o ícone do mouse (`MouseGlyph`).

## Lote 1 de 2026-11-26 (BG-2, QW-5, QW-6)
- **Linha de objetivo** (`ObjectiveLine`): largura máxima `WIDTH` 420 px do canvas (em 1280 x 720 termina bem antes do relógio); dica longa quebra
  na palavra (até 3 linhas) e o filete dourado vai sob a última linha. Teste em `tests/test_objective.gd`.
- **Santuário sem linha** (decisão do Daniel): as chaves `obj_hub_tree`/`obj_hub_portal` e o ramo `place: hub` de `Objective.pick` foram apagados;
  `pick` com `place: hub` devolve `&""`. A linha só existe nas salas da descida.
- **Provação** (BG-2): o aviso "Provação"/"Altar" do HUD não aparece mais (a placa do ponto já diz o nome); os medalhões das duas portas da câmara
  ficam 22% menores (`RewardGem.TRIAL_DOOR_K`) para não se encostarem. A bolinha escura era o `DoorSeal` do anjo duplo, já com glifo desde `3da7495c`.

## GP-1: interface do Guerreiro V1 (2026-11-26; testes em `tests/test_gp1_ui.gd`)
- **HUD, quatro grupos** (`Hud._build_actions`): botão esquerdo, botão direito, Espaço e Shift (o losango do Supremo, antes da esquiva). Sem Q nem E
  para o Guerreiro (`Controls.MAGA_ONLY` só constrói `shout`/`rush` quando `game.hero.arcane != null`; a Maga segue com Q e C no caminho antigo).
  A dica "Q: Brado" (`_update_shout_tip`, `FirstTips.shout_due`) foi removida.
- **Cada metade mostra toque e segurar** (`ActionSlot`): nome "Ataque · Esmagador" e "Poder · Lança" (`full_name`, `hud_slot_*` e `hud_hold_*`; o
  espaço alarga com o nome), desenho do mouse embaixo (`MouseGlyph`), gema de custo em Magia no canto superior esquerdo (toque, `tap_cost`) e no superior
  direito com anel (segurar, `hold_cost`); custo grátis não desenha gema. Cada gema escurece sozinha quando falta Magia (`tap_starved`/`hold_starved`;
  o traço azul do losango segue o do segurar). Os custos vêm do nó da árvore com Força Titânica e desconto (`Hud._update_button`, `Player.cost_of`).
- **Carga do segurar**: anel que enche o contorno do losango do botão segurado (`ActionSlot.charge`, `Player.charge_progress()`), azul e verde-água
  ao encher; soltar cedo apaga sem custo.
- **Recusa**: o sinal `magick_refused` acende o contorno vermelho do botão apertado por meio segundo (`ActionSlot.refuse`) e mantém o aviso "Sem Magia".
- **Ritmo de Batalha**: arco dourado fino do lado de fora dos dois losangos enquanto armado (`ActionSlot.rhythm`, `BattleRhythm.share()`); sem barra
  nova. A barra de Magia fina ganha marcas leves nos custos 8, 12 e 20 e acorda também enquanto há carga (`HudBar.ticks`).
- **Telas**: `HowToScreen.ROWS` sem Brado e Investida (e em `HIDDEN`); `BuildColumn` e `AbilityList` com quatro botões (esquerdo, direito, Supremo,
  esquiva); `HeroScreen` lista Ataque, Poder, Especial e Esquiva; `CodexScreen.move_marks` usa o Poder (toque) e o Especial (segurado) do botão direito;
  a carta de Bênção escreve o gesto (`Boon.gesture_key`: toque, segurar, toque ou segurar) ao lado da marca do botão (`BoonCard._meta`, nome `Gesture`).
- **Dicas**: `FirstTips` ganha `rhythm` (uma vez, ao armar o Ritmo, saves novos) e `controls_v1` (uma vez, em qualquer momento calmo, só para save com
  descida feita; save novo tem a Antessala); placeholders `{power}` e `{interact}` em `TipToast.text_of`. Antessala já vinha no núcleo (`AnteLesson.ORDER`).
- **Textos**: `howto_heavy_attack` e `action_heavy_attack` = "Poder e Especial"; `hero_skill_*`, `hero_passive_desc`, `gloss_armor_text`, `gloss_dash_cut_text`
  e `howto_tip` sem Brado nem Investida.

## HUD v3 (2026-11-27, nova referência do Daniel `docs/art/ref/hud_2026-11-27/hud_gpt.png`; testes em `tests/test_hud_v3.gd`)
- **Layout** (px a 720 linhas; 1080 = 1,5x): canto superior esquerdo `RoomHeader` (losango, "Sala N de M", filete dourado) com a
  `ObjectiveLine` logo abaixo; no topo ao centro o relógio na `Cartouche` (ampulheta; com chefe vai para o canto superior direito);
  embaixo à esquerda o retrato redondo (`HeroCrest`, 104), `RhythmMeter` ("Ritmo de Batalha", leão e filete que enche com
  `BattleRhythm.share()`) e três `StatBar` (ouro Supremo em %, azul Magia "22/30", vermelho Vida "32/40", medalhão redondo e ponta à
  direita, valor na ponta); embaixo ao centro quatro `ActionSlot` quadrados (toque e segurar do esquerdo, depois do direito, com o
  mouse embaixo e o custo em Magia como gota no canto: 0, 12, 8, 20 de `Player.cost_of`), `HudDivider`, a esquiva (Espaço) e o
  Supremo redondo (Shift, anel dourado que enche com a carga); borda direita `BuildColumn` só com medalhões em losango; canto
  inferior direito `CoinCorner` entre dois filetes dourados. Saíram: barras finas e legendas, nomes sob os losangos, o card da sala.
- **Arte** (`HudArt`, `assets/ui/hud_v3/*.png`, 16 peças, cada uma opcional): `HudArt.tex(nome)` devolve null sem o arquivo e o HUD
  desenha a sua (painel escuro, aro dourado, glifos de golpe, leão, ampulheta). Ícones sem fundo: o slot pinta um fundo escuro por
  trás; `portrait_warrior` é reduzido para caber na abertura do anel (`HeroCrest`, 0,84 do raio); `divider` (horizontal) é girado.
- **`ActionSlot` ganhou forma** (`Shape.SQUARE|ROUND`, canto cortado, `piece`, `hold`, `row_side`): cada slot tem um gesto, então
  `tap_cost`/`hold_cost`/`hold_text` saíram; vale `cost`/`starved` do slot. Mantidos: varredura de recarga, recusa vermelha, anel
  do segurar (só no slot de segurar), arco do Ritmo (nos golpes fortes), trava da maldição (os dois da direita), luzes do Pastor
  (Poder), translucidez atrás do herói. A Maga usa dois slots (esquerdo e direito) com os glifos dela; sem Q/C.
- **Linha de ação (mock do Daniel `docs/art/ref/hud_2026-11-27/slots_mock.png`)**: seis slots quadrados do mesmo tamanho (`Hud.ROW_SLOT`): Ataque (esquerdo
  toque), Poder (direito toque), Esmagador (esquerdo segurar), Lança (direito segurar), o Supremo (leão, Shift), divisória, esquiva. Ícones são
  telas cheias (`icon_*.png`, 256 px, sem moldura) desenhadas até a abertura da moldura (`r - FRAME`) sobre um fundo radial escuro quente
  (`HudArt.fill_tile`). **Regra do mouse: botão aceso branco = clique (toque), dourado = segurar** (`MouseGlyphArt.Style.TAP|HOLD`, PNGs
  `mouse_N_tap|hold.png` com aro claro; o resto do jogo usa `Style.DEFAULT`, dourado). Shift é uma caixa arredondada com seta para cima, Espaço uma barra
  longa vazia (`ActionSlot._draw_cap`; no controle volta a placa com a letra).
- **Coluna de Bênçãos sem nome fixo** (reverte PT-26-4): o nome aparece à esquerda do medalhão por `NAME_TIME` 4 s quando a Bênção
  é ganha (`_note_gained`; o que a partida já trazia não conta), enquanto o mouse está sobre o medalhão e sempre na pausa
  (`names_all`). Recarga (varredura e segundos no medalhão), ponto verde de pronta e pontos de nível seguem. Não há lista no Tab.
- **Modo horda** e Maga seguem funcionando (mesmos nós; sem Supremo a barra dourada some, sem Ritmo o medidor some).
- Removidos: `Hud.magick_wakes` (Magia fina que acordava), `_layout_bars(thin)`, `HOLD_TEXT`, `_clock_veil`.
