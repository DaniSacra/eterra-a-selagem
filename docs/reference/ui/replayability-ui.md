> Índice: [ui.md](../ui.md)

## Rejogabilidade, Fatia 3, interface (ui-ux-designer; testes em `tests/test_fatia3_ui.gd`, capturas em `docs/gallery/fatia3_ui/`, `tools/fatia3_lab.gd`)
- **Forja**: terceiro marcador "Despertar" (`ForgeScreen.Tab.ARTS`, `arts_open()`: aparece com qualquer ferramenta do
  Forjador achada; ordem dos marcadores em `_tab_order`, LB e RB andam nela) com duas colunas, Despertar (Esmeralda) e
  Inscrever (Prata), cada uma com o estado da ferramenta; a marca do preço é a do material do posto (`Mark.paid_in`,
  `MaterialCount.set_id`). Despertar: forjado e dormindo diz "Despertar" (`put_on`, grátis), desperto "Adormecer"
  (`take_off`); Inscrever: "Inscrever" e depois "Inscrito"; sem a ferramenta, o `forge_no_<ferramenta>`.
- **Sortear de novo** na escolha de Bênçãos (Discernimento I): com `Game.can_reroll()` a `BoonChoice` põe
  "Sortear de novo (N)" na `ActionBar` (`reroll_item`, `reroll()` chama `Game.reroll_choice`); ação de menu
  `menu_reroll` em `Controls.MENU_KEYS` (Y no controle, R no teclado, só nos menus).
- **Discernimento** só se lê no capítulo Ofícios do Livro (`HeroScreen._discern_part`: nome, o que faz, "Aberto" em
  tinta verde ou "Fechado", e a linha `discern_at_vendor`); a compra passou para a banca do Vendedor (2026-11-23).
- **Banca do Vendedor, a balança** (`VendorScreen`, `docs/art/shop_spec.md` B e C, `meta_identities.md` 4): palco de
  1280 x 720 em escala uniforme (como a Videira), toldo listrado vinho e terra, balcão de madeira, balança de latão no
  meio (`VendorScale`: ângulo `angle`, `put`/`take`/`settle`, pratos que carregam o que se dá e o que se recebe, prévia a
  40%), à esquerda as **Trocas** e à direita as **Obras** com o Discernimento I e II no fim (5 etiquetas, sem rolar),
  placa de leitura no centro (`VendorPlate`: nome e estado em palavra e cor, o que muda com números em negrito, preço
  com "Você tem N"). As etiquetas são `ShopTag` (couro 5a3424, pesponto, ilhó, carimbo "Erguida"; avançam 10 px com aro
  de ouro velho no foco). Lógica toda em `VendorOffer` (core, testado: junta troca, Obra e grau do Discernimento e só
  pergunta a `Vendor` e `Discern`; `state`, `cost`, `gain`, `missing`, `tilt`, `commit`). **Gesto**: 1o aperto (Enter, A,
  clique) `press_tag`/`put` põe no prato e a balança pende (4 a 10 graus para o lado do que se dá), o foco vai ao botão
  do meio ("Fechar a troca", "Erguer a Obra", "Abrir o grau"; sem material fica desligado com o motivo); 2o aperto
  `press_close` faz a troca por `VendorOffer.commit`, grava o save e esvazia os pratos (`settle`); B/Esc tira do prato
  sem gastar (`cancel`), com o prato vazio fecha. Direcionais: cima e baixo na coluna, esquerda e direita trocam de
  coluna na mesma linha (e pelo botão do meio aceso), LB/RB e PageUp/PageDown também; o mouse dá o foco (prévia) e
  clica para pôr. Abre na primeira troca que se paga, senão na primeira Obra. Sinais `built`, `traded`, `discerned`.
  Captura: `--title --screen=vendor [--silver=N --memory=N --emerald=N --made=obra_altar --discern=N --place=<índice>]`
  (save de teste, nunca o do jogador). Arte final por caminho previsto em `assets/ui/shop/` (`ShopArt.texture`:
  `counter_bg`, `awning`, `obra_*`, `stamp_built`...; sem arquivo, o desenho provisório de `ShopArt`). O vermelho dos
  preços sem fundos é e8806c (o c05040 da spec some no couro). Falta (spec B.5): o balcão fechado antes da primeira
  encomenda ainda é a folha do `HubPanel`; sons de moedas e rangido; contagem dos números na bolsa.
- **Compêndio**: aba Anjos (`CodexScreen.Tab.ANGELS`, nona, antes de Golpes; `AngelCodex`): selo aceso, nome na cor
  do anjo, frase e vezes encontrado, escolhido e Bênçãos levadas; nunca encontrado, selo apagado e "???".
- **Esboço a tinta no Compêndio** (AP-4, peça do technical-artist): o `FigureView` chama `FigureSketch.apply(renderer,
  def, Book.INK, altura da vista)` depois do `register` nos inimigos já derrotados (passar de conhecido para não conhecido refaz a
  figura); os nunca derrotados seguem em silhueta. Com nove abas, as entradas do índice ficam com `TAB_HEIGHT` 34 e
  margem vertical de 1 px, para a figura caber embaixo a 720.
- **Ângulo e motivos (AP-4, peças do technical-artist)**: o `FigureView` gira a figura por `FigureSketch.yaw(modelo)`
  com um balanço leve; o `TalentNode` desenha `TalentMotif.draw(..., state)` antes do glifo do Dom (e do ramo), e o
  detalhe dos Dons no Compêndio mostra o motivo (`CodexScreen._motif`; sem motivo, `TalentGlyph.mark`). Na lousa
  escura da árvore os motivos dos nós abertos e não equipados quase somem: resolve quando a 1.5 da `ap4_spec.md` põe a
  árvore no papel.
- **AP-4 seção 1 (ui-ux-designer, 2026-11-21, capturas em `docs/gallery/ap4/book_*_1080.png`, `map_icons_1080.png`)**: feitos
  1.1 capa de couro (`book_cover.gdshader`: grão, gasto, vinco cego, costura; cantoneiras e rebites de ouro na capa, não
  mais na página; `BookSpread` ganhou os nós `cover` e `under`), 1.2 abas como fitas (`Book.mark`: fita com rabo de
  andorinha saindo de baixo da capa, largura pelo texto, a coluna das abas usa separação `-Book.MARK_HIDDEN`), 1.3
  parcial (`Book.index_entry`: aguada com faixa rubrica à esquerda, foco só o losango; marca das Arenas é planta de
  sala), 1.5 árvore de Dons no papel (filete duplo de tinta, nós em papel tostado com aro de ouro, trancado com motivo
  apagado e cadeado no canto, ramos em rubrica) e P2-3 do QA (`DoorGlyph`: Ouro é pilha de moedas cheias, Loja é bolsa
  amarrada). Segunda leva (2026-11-21, `book_opening_1080.jpg`, `codex_enemies_1080.jpg`, `map_middle_1080.jpg`):
  1.3 fechada (`Book.index_entry`: fita rubrica de 3 px que desce 3 px abaixo da entrada, desenhada no `draw`; marca dos Anjos
  agora é anel duplo com ponto, sem losango, para não repetir a das Bênçãos), abas com `MARK_FONT` 19 (versal cerca de 13 px) e
  `MARK_HEIGHT` 32 (fita fechada sobe 22 px, a spec pede 20: com 19 a linha do Cinzel pede 27 px e a 30 a aberta não ficava
  8 px mais alta). 1.4 `AhkVignette` (rolo aberto, pena no tinteiro, rolo fechado com lacre e o leão de `SealEmblem.LION`,
  mesmo shader) e `DropCap.paragraph` (capitular em quadrado de filete gravado com ramagem, 3 linhas, cabeça ao lado e resto
  embaixo; `DropCap.split` testado). 1.6: quadro de prancha duplo em volta da figura (150 x 200), nome em Cinzel rubrica e
  contagem; desconhecido em silhueta `FADED` a 0,3; linhas "???" viram uma só, "N por descobrir" (`CodexScreen._undiscovered`,
  chaves `codex_undiscovered` e `codex_elite_name`) em Bênçãos, Elos sem pista, Inimigos e Anjos; em Inimigos a linha única
  seleciona a silhueta do primeiro desconhecido; elites com entrada própria (`<id>_elite`, esboço dourado) depois que uma
  caiu. 1.7 `MapGraph.medallion` e `wax_seal` (também na legenda): corpo `DISC` (luma cerca de 40), anel de papel, aro de ouro
  gravado, apagado em `FADED` 0,3; ligações alcançáveis em tinta, deixadas tracejadas, caminho com pontas redondas; faixas de
  estrato a cada duas profundidades (4% cada, esmaecidas nas bordas), boca das catacumbas em tinta acima do nó 1
  (`TOP_PAD`), Morvath como lacre violeta 1,5 vez maior, números em `number_font`. 1.10 Iniciar em `PLATE` (OLD_GOLD) e luz só
  com foco ou ponteiro; submenus escurecem mais (`DIM_LEVEL` 0,3) e desfocam a arte (`DIM_LOD`). Sem shader novo.
  Não medido por captura: 1.8, 1.9 (sem alteração de código), 1.10 e o contraste de números.

- **Acabamento de interface (ui-ux-designer, 2026-11-21, capturas a 720 em `docs/gallery/ui_polish/`)**: 1.8 e 1.9 conferidos no
  código (QW-115 no `end_screen`/`SealEmblem`/`fx.gd`, HudVeil, glifos 5, 9, 15 e 110 sem cruz, com testes em
  `test_lote_a_ui`); sem mudança. Cadeado dos Dons trancados agora fora do losango, no canto superior esquerdo (espelho do
  selo), sem cobrir a borda do motivo. Abas: `MARK_HIDDEN` 12 (fita fechada sobe 20 px, aberta 28) e a margem de baixo do
  botão `MARK_HIDDEN - 7`, para o texto não crescer a fita fechada (`test_ui_review` verde). Mapa: a boca da caverna é uma
  porta de pedra (moldura em trapézio, vão escuro com arco, degraus de papel, sem aro de cúpula nem aba, que lia como
  capacete). Conferido a 720: Livro (abertura), Compêndio de Inimigos (figura 150 x 200, entradas de 30) e Configurações
  sobre o título desfocado, sem corte nem sobreposição. `tools/book_lab.gd --codex-only=N` captura só a aba N.

## Rejogabilidade, Fatia 1, interface (ui-ux-designer; capturas em `docs/gallery/rj1/ui/`, testes em `tests/test_rj1_ui.gd`)
- **Marcas dos materiais**: `DoorGlyph.Kind.SILVER` (lingote de prata) e `MEMORY` (folha rasgada com três linhas de tinta),
  `DoorGlyph.of_reward` para `RunMap.Reward.SILVER`/`MEMORY` (placas das portas) e `DoorGlyph.of_material(id)`;
  `DoorGlyph.material(ci, kind, centro, altura)` desenha a marca em qualquer canvas. `MaterialCount`
  (`scripts/ui/material_count.gd`): marca e número no `UiKit.number_font` (nunca Cinzel), `named` acrescenta "Prata",
  `plus` escreve "+3"; `MaterialCount.purse(data)` é a Bolsa (Prata e Memória lado a lado) e `refresh(row, data)`.
- **Forja da Emeth, a bancada (3b, 2026-11-24; `docs/art/forge_spec.md`)**: `ForgeScreen` (`scripts/ui/forge_screen.gd`, aberta pelo Forjador em
  `Hub._open_forge`) deixou de ser livro. Um palco de 1280 x 720 centrado (o resto é fundo; `canvas_items` escala tudo, 1920 x 1080 sai x1,5). Pano com a
  **Emeth deitada** (`EmethView.setup(px, true)`: ponta à direita, sem balanço, dentro do `ForgeBench`) e **quatro pontos** na arma (`ForgeBench.AT`,
  ajustados ao modelo real, não ao esboço da spec): Despertar no pomo, Refinar nos dois braços da guarda (Ataque em cima, Especial embaixo), Inscrever no
  plano da lâmina, Temperar nos três entalhes do gume (acendem por posto). O que se forjou aparece na arma: pedra desperta no engaste, anéis com a letra,
  linhas gravadas. Ponto sem ferramenta: pano cinza com cadeado. Duas **bancadas** (`Tab.EMETH`, `Tab.WORKSHOP` com a Picareta deitada; LB/RB, `_turn`);
  Despertar e Inscrever só com `arts_open()`.
  **Leitura em 3 segundos**: faixa de **fichas** (`ForgeChip`, 176 x 56, seis estados por desenho e palavra: brasa, preço vermelho, tracejada "Depois de",
  "Guardado", "Na lâmina", cadeado) e **placa** (`ForgePlate`: o quê, o que muda com números em negrito, quanto e "você tem N", botão "Martelar ● ○ ○ ou segure").
  As palavras de cada escolha vêm de `ForgeInfo` (`scripts/core/forge_info.gd`, puro: `of(forge, data, rank)`, `pick(data, def)`; `Look` e `Action`).
  **Gesto**: `ForgeHammer` (`scripts/core/forge_hammer.gd`, puro, usa `HoldGauge`): um aperto é uma martelada, a peça esfria em 1,2 s, B esfria sem gastar,
  segurar 1,2 s dá as três (a segunda na metade); a terceira chama `Forge.buy` ou `Oficios.restore` (nenhuma regra nova), grava e emite `forged` ou `restored`.
  Usar, Despertar e Adormecer são de um aperto, sem brasa. Mudar o foco esfria. Entrada por ações (setas e direcional andam nos pontos e na faixa, para baixo
  entra na faixa, para cima volta, na guarda cima e baixo trocam o braço; `ui_accept`, `ui_cancel`, `tab_prev/next`) e mouse (passar dá o foco, clicar martela).
  Efeitos no `ForgeBench` (tranco de 3 px, clarão, faíscas, calor de 25% e 50%, vapor na terceira; sem faíscas na Compatibility). Arte final: `ForgeArt` lê
  `assets/ui/forge/*.png` (ligados: `bg`, `cloth`, `emeth_flat`, `pick_whole`, `pick_head`; o resto da lista em `ForgeArt.FILES`). Captura:
  `--title --screen=forge [--forge-mark=temper|attack|special|awaken|inscribe]` (dados de demonstração em `ForgeScreen.demo_data()`). Testes:
  `tests/test_forge_bench.gd` e os da Forja em `test_ui_fatia2`, `test_fatia3_ui`, `test_rj1_ui`, `test_oficios_ui`.
  Pendente: sons de bigorna e chiado próprios (hoje `mat_armor` com tons), arte final do ChatGPT, a Maga com trilhas do cajado.
- **Abrir Dom com Memória** (`HeroScreen`, `TalentNode`): o Dom revelado e não aberto (`HeroLoadout.State.SEALED`) mostra o
  glifo a meia força e, embaixo, a folha da Memória com o preço (`TalentNode.SEALED_GLYPH`, `MEMORY_MARK`, `MEMORY_SIZE`) no
  lugar dos losangos de Devoção. O painel diz "Abrir: N de Memória" no Custo, "Revelado pela Maestria, ainda fechado" no
  Estado e o próximo passo; a dica do rodapé troca para abrir. O primeiro aperto pergunta na própria página ("Abrir por N
  de Memória? Aperte de novo para confirmar. Não há volta.", em rubrica; `HeroScreen.arming`), o segundo em até
  `CONFIRM_TIME` 3 s abre (`HeroLoadout.open`, grava) e não equipa; mudar o foco ou o tempo esquece; sem Memória o nó
  recusa e diz quanto falta. A Bolsa fica no alto da página direita, ao lado da Devoção.
- **Encontro** (`EncounterScreen`, `scripts/ui/encounter_screen.gd`): na língua da `BoonChoice` (título Cinzel sobre a
  partida escurecida, dica embaixo), um cartão de tinta por anjo (`EncounterScreen.AngelCard`, 300 x 392): selo grande
  (`AngelSeal`), nome, "Bênçãos de {família}", filete, a linha do anjo e quantas Bênçãos da família o herói leva (o fato
  que decide a escolha); foco no primeiro. `EncounterScreen.attach(game)` (o `Hud` liga no `game.ready`) ouve
  `Encounters.opened`; escolher fecha, chama `encounters.choose` e a `BoonChoice` ganha o selo pequeno e "Trazidas por
  {nome}" no alto (`BoonChoice.by_angel(anjo, voltar)`); Esc ou B ali volta ao mesmo par, com o foco no anjo visto, e as
  cartas são as mesmas (`Encounters.cards_of`). Cores dos selos (`AngelSeal.TINT`) longe do vermelho do perigo, do
  esmeralda da Emeth e do petróleo do herói: Chama âmbar terroso (matiz 24), Vigília sálvia (matiz 88; era petróleo, 177);
  testado com 20 graus de folga.
- **PT-10 (2026-11-23, referências do Daniel)**: o Encontro virou palco (`EncounterScreen` + `AngelStage` + `AngelFx`): um anjo em
  cada lado, altura toda, o efeito da família sobre ele, o em foco aceso e um pouco mais perto, caixa de fala embaixo ao centro
  com o nome, a família, a linha e "Ouvir {nome}"; um anjo só ocupa o lado esquerdo e a mesma caixa (BC-4). `--encounter=a,b`
  abre um encontro na hora (captura). A Bênção: a tecla vai **dentro da frase** (`{key}` nos textos `boon_<id>_desc` dos 31
  golpes de botão; `BoonChoice.key_in_text`, "O ataque [Mouse esq.] incendeia..."; segue controle e tecla remapeada; Bênção
  que age sozinha não tem `{key}`). O Encanto (`EnchantChoice`): a Emeth cravada na pedra e acesa à esquerda
  (`EnchantAltar`, desenhada, sem modelo) e o **ichthys** (`Ichthys`, duas curvas deitadas, desenhado) no medalhão de cada
  carta e na face da pedra; a página desloca para a direita pela largura do altar. `--enchant-choice` abre a tela na hora.
- **Trazidos e Bolsa**: a tela de fim mostra "Trazidos" sob as Bênçãos levadas (`EndScreen._brought`: `stats.materials`,
  senão `game.materials_banked`, e sem save o que a descida achou; nada quando nada veio). O hub tem a Bolsa no canto
  de cima à direita sobre um véu de tinta (`HubLabels.purse`, `PURSE_MARGIN`), escondida com tela aberta.
- **Saudação de material** (`EloBanner.show_material`, na fila das outras, 1,8 s, `MATERIAL_TIME`): "+10 Prata" com a marca;
  mais do mesmo enquanto aparece ou espera soma. O `Hud._greet_materials` lê `game.materials.found` a cada quadro e saúda
  tudo menos o abate de elite (fica só a palavra do `Rooms.found` onde ele caiu). Respeita o `keep_out` das placas como
  as outras saudações.
- Texto da Maestria: o nível revela, a Memória abre: "Dom revelado: X" / "Dons revelados: X, Y" no fim
  (`MasteryReport.unlocks`) e "O nível N revela: ..." no Livro (`hero_next`).
- P2 da revisão d2ff05d fechados depois: Juramentos sem caixa por linha, fio entre linhas, foco numa faixa com a linha de
  ouro, "Peso N" à direita só ligado (`JuramentoScreen._thread`); Músicas com cabeçalhos `UiKit.section` e o Ouvir só
  inteiro na linha em foco, sob o ponteiro ou tocando (`MusicRoomScreen.QUIET_LISTEN` 0,3; a largura ficou a de antes,
  1160: com as duas colunas numa de 780 a lista não cabe em 720); Compêndio, Inimigos e Dons com linhas de 34 px
  (`CodexScreen.LIST_ROW`), a marca do papel do inimigo a tinta (`RoleMark`, `scripts/ui/role_mark.gd`) e a contagem
  "64 derrotados · 5 de elite" em `FADED` no `number_font`; menu do Santuário numa folha do Livro (`PauseMenu` com
  `hub`: `BookSpread` única, botões de papel); foco das cartas (Bênção, Provação, Altar, Encontro) em cantoneiras marfim
  por dentro da linha de metal, nunca uma linha inteira (`BoonCard.draw_focus`, `FOCUS_ARM`; a Comum em foco ganha um
  brilho marfim, as outras ficam com o brilho da raridade); os cabeçalhos em versal das cartas de evento ficam em 13
  px (`BoonCard.HEAD_SIZE`: a 14 o da maldição quebra em duas linhas na faixa). Testes no fim de `tests/test_ui_review.gd`.
- Capturas: `--hub --hero-at=smith --hub-use=smith --materials=silver:30,memory:5` (Forja), `--title --screen=gifts
  --hero-xp=160 --hero-opened=quarto_corte --materials=...` (`--hero-opened` só abre esses, os outros revelados ficam
  selados; `Save._dev_hero`), `tools/book_lab.gd` (`gifts_sealed`, `_ask`, `_short`), `tools/ui_lab.gd -- --meeting` e
  `--found`, `tools/menu_lab.gd` (fim com Trazidos), `--hub --hero-at=vendor --materials=...` (Bolsa do hub).

## Revisão de layout da interface (d2ff05d; `docs/gallery/ui_review_d2ff05d/REVIEW.md`, depois em `after/`)
- **Números nunca em Cinzel** (P0-1: o 1 da Cinzel lia como I romano, "SALA I DE II"): sala, relógio, ouro, contador de
  golpes e todo aviso com algarismo em `UiKit.number_font()` (`UiKit.has_digit`); teste em `tests/test_ui_review.gd`.
- Relógio e contador de golpes sobre um véu de tinta de cantos cortados (`HudVeil`, `scripts/ui/hud_veil.gd`: cobre só o
  texto dos rótulos pelo alinhamento, some sem eles); com a barra de um chefe ou guardião o relógio vai para o canto de
  cima à direita, sob o ouro, e o nome do chefe fica sozinho sobre a barra (`Hud._place_clock`, `CLOCK_BOSS_Y`,
  `BOSS_TOP_ALONE`). Na pausa o medalhão e as barras somem sob o painel (P2-7).
- Ouro que cai soma como o dano (`Fx.gold(pos, n)`, `GOLD_SIZE` 15, `GOLD_WORD` ouro velho claro, junta em
  `NumberTally.MERGE_TIME` e `GOLD_JOIN` 6 m: "+3 ouro", nunca "+1 ouro+1 ouro"); o `Rooms` chama `fx.gold`.
- Saudações e placas não se tocam: enquanto o `EloBanner` mostra algo ele marca a faixa dele em `DoorSign.keep_out`
  (`EloBanner.band`) e a placa que cruzaria desce para baixo dela (`DoorSign.KEEP_GAP`).
- **Livro**: botões do papel `Book.button` (tinta sobre papel mais escuro, fio `GILT`, foco fio rubrica e losango à
  esquerda) e `Book.primary` (papel tostado, letras rubrica) na folha do Portal e do Vendedor (`HubPanel`), no Livro, no
  Compêndio e no Mapa; cartas de ultimate no papel com o estado escrito (`UltCard`: Escolhida, Pode escolher, Destrava
  na Maestria N). Capítulos como marcadores de couro saindo da capa (`Book.mark`, `Book.mark_open`: o aberto mais longo
  e com a fita petróleo; `HeroScreen.OUTER` 12 px do topo). Rodapé numa fileira só à direita: Dons (no capítulo O
  Guerreiro), Compêndio, Voltar (`HeroScreen.FOOT_WIDTH`). **Aberto no hub não tem "Descer às catacumbas"**
  (`HeroScreen.open(data, chapter, true)`, `in_hub`; só o Portal desce); no título continua. Folha única com a fita no
  meio (P2-6). Barras de rolagem com tema (`UiKit.scroll_bar`: trilho de 2 px, pegador em losango alongado; no
  `UiKit.theme()` em ouro velho e no `Book.theme()` no ouro do papel) e o pé da lista esmaece quando há mais
  (`UiKit.scroll_fade`, `ScrollFade`, `FADE_HEIGHT` 24, filho interno do `ScrollContainer`) no Compêndio e em Suas
  Bênçãos.
- **Santuário**: placa da estação com o verbo dela no lugar de "Interagir" (`StationSign.verb`, chaves `hub_use_<id>`:
  Descer, Olhar, Ver os Dons, Forjar, Ler); a linha do meio diz o que a estação é ("O caminho para as catacumbas").
  Vendedor sem texto de protótipo: "Balcão fechado" e "Não há nada à venda no balcão." (`hub_soon`, `hub_vendor_soon`).
  Nome do lugar por 2 s ao chegar e um nome fraco sobre cada estação na tela, menos a que está em foco
  (`HubLabels`, `scripts/ui/hub_labels.gd`, posto pelo `Hub._ready`).
- **Fins de partida**: os dois com os caminhos no mesmo lugar ("Voltar ao {HUB}" à esquerda, "Descer de novo" à direita;
  o destaque muda: vitória o hub, derrota a descida; `EndScreen._ways`), HUD escondido nos dois (`_hide_hud`), números
  numa fileira só de células (nome em cima, número embaixo; `STAT_CELL`) e medalhões sem os pontos de nível (P2-12,
  `UiKit.gift_icons(..., levels)`).
- **Configurações**: um controle só para toda opção (`OptionsScreen._setting`): linha-botão com o nome à esquerda e o
  valor entre duas divisas de ouro velho desenhadas (`OptionsScreen.Chevron`, `opt_<id>_-1`/`_1`, sem foco), Cinzel no
  valor sem algarismo e `number_font` com; esquerda e direita mudam, Enter, A ou clique avançam (o interruptor vira
  "Sim"/"Não"); "Janela" apagada e pulada pelo foco com a tela cheia ligada; embaixo da página a linha do que a opção em
  foco faz (`opt_<id>_tip`, `OptionsScreen.tip_text`).
- P2 feitos: ícone de Sair do título é uma porta em arco aberta (`TitleButton._draw_door`, nada de símbolo de energia);
  estado da porta no Mapa em tinta e curto ("Uma porta desta sala leva até aqui."). Ficaram: P2-2 (Juramentos e
  Músicas), P2-3 e P2-4 (Controles), P2-5 (Compêndio), P2-8, P2-10, P2-11 (asset), resto do P2-12; enquadramento do
  Portal pela câmera (P1-8, gameplay).

## Lote A, frente A5, interface (backlog "Estado e ordem de 2026-11-20"; testes em `tests/test_lote_a_ui.gd`, capturas em `docs/gallery/lote_a_ui/`)
- **Estilo visual (DT-RS2)**: Configurações > Vídeo, "Estilo visual" Estilizado ou Clássico (`opt_look*`), pelo
  `OptionsScreen.apply_look(tree, look)`: `Save.choose_look` (aplica e grava a chave `look`) e `Arena.restyle()` de toda arena na árvore, o mesmo
  quadro do F7, gravado na chave `look` por `Save.choose_look`.
  Capturas: `--title --screen=options --options-tab=video|comfort|controls [--options-focus=opt_look]`.
- **Controle (resto do DT-103)**: `ui_accept`/`ui_cancel` ganham A e B do controle (`Controls.MENU_BUTTONS`; antes os
  menus não aceitavam o A). Remapear no controle: nos Controles, escolhida uma ação, um botão do controle a liga
  (`Controls.rebind_pad`, `PAD_REMAPPABLE`: ataque, especial, esquiva, círculo, ultimate, usar; troca com quem tinha
  o botão; o andar fica no analógico), gravado em `bindings` como `pad:<ação>` (`pad_button_for`), Start cancela, Teclas
  padrão volta tudo. O botão aparece numa plaqueta (`StationSign.KeyCap`, redonda nos botões de face) e uma linha embaixo
  diz que botão também liga (`options_pad_note`). Como Jogar com as teclas e botões em plaquetas (`HowToScreen.Plates`,
  `key_parts`, `pad_parts`; P2-3). `tools/title_flow_check.gd` faz uma volta só de controle (Como Jogar, Configurações,
  remapear o Ataque para Y, Teclas padrão) e uma só de clique (Como Jogar, Configurações, Estilo visual ida e volta).
- **Entrada de Morvath (AP-2, ART-05.5)**: quando ele surge, embaixo da barra dele, num véu, "A Câmara do Selo", "Morvath"
  em Cinzel e "O rei que traiu a luz" (o `enemy_morvath` cortado na vírgula) por `Hud.ENTRANCE_TIME` 2,3 s, entrando em
  0,3 e saindo em 0,45 (`Hud.show_entrance`, `entrance_shown`); um `show_notice` do nome da câmara vai para lá.
- **Vitória (QW-115)**: o halo do selo é um degradê radial de ouro velho até nada (`SealEmblem.halo_texture`, `HALO`
  0,42, `HALO_REACH` 1,55; os discos de antes liam como disco amarelo), o leão acende em `EndScreen.LION_GLOW` 0,6 s e o
  título e a frase da selagem ficam sobre um véu escuro em elipse (`words_veil`, `WORDS_VEIL` 0,72). O ouro que cai sobe
  ao lado do número do golpe e menor (`Fx.GOLD_SIDE` 1,1 m para a direita da tela, `GOLD_SIZE` 14).
- **Glifos sem cruz (QW-117, `BoonIcon.glyph`)**: lâmina de gelo (5) é um caco facetado sem travessa; escudo da Vigília
  (9, 15) com divisa e losango no lugar da estrela de quatro pontas; Corte do Juízo (110) é uma lâmina sem guarda descendo
  de lado na fenda.
- **Barras dos comuns (ART-02.6)**: no `life_bar.gdshader` a barra de quem não é elite nem tem armadura tem a vida
  `common_dim` 0,85 mais escura e é `common_cut` 25% mais fina, cortada de baixo (o topo não muda); elites iguais.
- P2-12: número do selo da Provação em 14 px (`TrialSeal.NUMBER_SIZE`). P2-4, P2-5, P2-8 e P2-10 já estavam feitos.
- **HV-D, interface do Santuário da Vigília** (`docs/art/hv_santuario_vigilia_art.md` 6.3): a placa da estação em foco
  pendura no pé do que se usa, nunca flutuando sobre ele (`Hub._show_focus`: a âncora do `HubPlan` levada ao chão e
  `StationSign.under`), e fora do herói (`place_under` com o y arredondado para cima). Os nomes fracos das estações
  (`HubLabels`) nunca sobre o herói nem sobre a Bolsa. O Alquimista não é estação: sem placa, nome nem foco.
- **Ofícios, marca da Pedra Funda**: `DoorGlyph.Kind.STONE` (bloco de ardósia quebrado com dois estratos pálidos),
  `DoorGlyph.of_material(&"pedra_funda")` (`STONE_ID`, o `OficiosDef.stone`), pronta para a Bolsa, Trazidos e a saudação.

## Ofícios, Roteiro A, interface (ui-ux-designer; `docs/design/oficios/10_ux.md`; testes em `tests/test_oficios_ui.gd`)
- **Achado**: o nome na placa da porta (`Rooms.door_text`, `UiKit.find_name`); o mapa saiu no DM-1.
- **Placa do veio**: `StationSign.tool_line` põe sob a tecla "Pede: Picareta" no rosa do que falta (`vein_note`) ou "Com
  a Picareta" (`vein`); `dim_verb()` apaga o verbo (para o `Rooms.prompt` quando o veio já foi anotado).
- **Bolsa e Trazidos**: `MaterialCount` aceita a Pedra Funda (`name_of`, `short_of`, `amount_of` pelo `Oficios.count`); a
  Bolsa a mostra depois da primeira (`shown`, `items_total`); a tela de fim traz as pedras e o achado da descida
  (`stats.oficios`, senão `game.oficios`; `PickMark` com o nome).
- **Saudação** (`EloBanner.show_find`: "Achado", a cabeça desenhada e "Leve ao Forjador no {HUB}"; `show_noted`: "Veio de
  Pedra Funda", "Anotado no Livro de Ahk" e "Pede: Picareta"), pedidas pelo `Hud._greet_oficios` lendo o `game.oficios`
  (também cada Pedra Funda extraída, saudação de material); os `show_notice` do `rooms.gd` com esses textos são
  engolidos (`Hud.oficio_notice`).
- **Picareta desenhada** (`PickMark`, `scripts/ui/pick_mark.gd`: perdida em contorno, só a cabeça com o cabo partido,
  inteira; no papel ou sobre a partida).
- **Forja com a Oficina** (`ForgeScreen.Tab`): depois de anotado um veio, dois marcadores de couro sobre a capa, Emeth e
  Oficina (LB e RB); a Oficina mostra a Picareta grande na página esquerda e, à direita, o índice das ferramentas com os
  mesmos Efeito, Estado, Próximo passo, custo, "Cabeça da Picareta: aqui/perdida" e Restaurar (`restore()`, sinal
  `restored`). O Forjador abre a Forja direto na Oficina enquanto a Picareta espera (`Hub._open_forge`).
- **Encomenda do Vendedor** (`OficioSheets.order`, na folha do `HubPanel`, que ganhou `body` e escolhas apagadas
  `[id, texto, false]`): marca da Pedra Funda, uma fala, "◆ PEDE" com marca, nome e "1 de 2" (falta em rubrica, visto em
  tinta), "◆ ONDE ACHAR", "◆ DÁ" e Entregar só aceso com tudo.
- **Livro, capítulo Ofícios** (`HeroScreen.Chapter.OFICIOS`, quarto marcador): Recursos (Pedra Funda "N de 10" e onde
  achar, ou "???" com a pista), Ferramentas (a Picareta no estado dela), Pedidos (Forjador, Vendedor) e Obras (Prévia dos
  anjos), em voz neutra.
