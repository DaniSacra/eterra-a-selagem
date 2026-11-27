> Índice: [ui.md](../ui.md)

## Botões do Guerreiro no HUD, Como Jogar e Golpes (2026-11-21; testes em `tests/test_shout.gd`)
- **HUD**: a fileira tem seis losangos na ordem botão esquerdo, botão direito, Q (círculo), E (Brado), Shift (ultimate) e Espaço
  (esquiva): `Hud.ACTIONS`/`SLOTS` com `ULT_AT = 4` (o losango da ultimate entra antes da esquiva). O do Brado tem glifo próprio
  (`BoonIcon.SHOUT_GLYPH` 105: um ponto e três arcos para os dois lados), slot `NONE` (ainda sem Bênção), mostra a recarga de 10 s
  (`Player.shout_wait()`) e some para herói sem esse golpe. A fileira ficou mais larga (termina em cerca de 32% da largura): os testes
  `test_bench_ui` passaram de 30% para 35%. A contagem de golpes continua à direita do último losango (`_follow_row` lê a esquiva).
- **Como Jogar** (Controles): linha nova "Brado de Guerra" depois do Círculo; Ultimate antes da Esquiva; as teclas e botões são lidos do
  `InputMap`, então mostram E, Shift e F (e R3 no controle) e seguem o remapeamento. Configurações > Controles lista o Brado
  (remapeável, com o botão do controle na placa). A tela de título lista as teclas novas (`title_controls`, `title_pad`).
- **Compêndio de Golpes**: "Brado de Guerra" aparece entre os golpes (marca do Brado no lugar do botão esquerdo ou direito,
  `CodexScreen.move_marks`) e se acende no primeiro uso.
- **A conferir em captura** (não feitas): a página Controles do Como Jogar com a linha a mais (o quadro tem 420 px; a medida sem
  tela não é confiável) e a fileira do HUD com seis losangos em 720p e 1080p.

## HUD do Lote 2 (2026-11-21, layout aprovado pelo Daniel; referência SWORN só em princípios)
- **Canto inferior esquerdo**: retrato (`HeroCrest`) e ao lado, empilhadas e alinhadas à esquerda, **Magia em cima, Vida embaixo
  (números nas duas) e a carga da ultimate fina no pé** (`Hud._charge`, ouro, esverdeia ao encher). Selo da Provação em cima do
  retrato; a insígnia da maldição em cima das barras.
- **Fileira de habilidades centrada na base** (`Hud._action_row`, seis losangos 36 px, faixa de tinta atrás): a rajada mostra o
  custo (8) numa gema azul (`ActionSlot.cost`) e a legenda "Sem Magia" quando falta; o buff do Brado (5 s) fica sobre o losango
  do Q (`BuffMark`, anel que esvazia e os segundos). Contagem de golpes à direita do último losango. O modo `--hud=classic` saiu.
- **Coluna de Bênçãos na borda direita** (`BuildColumn`, 58 px de largura, centro em 46% da altura): estandarte escuro, um
  medalhão por botão (esquerdo, direito, Q, E, Shift, Espaço) com o nível ("Nv. 2") na cor da raridade; vazio em cinza com o
  símbolo do botão (E e Shift ainda não têm slot de Bênção); embaixo os Elos e o Salmo. Fica translúcida quando alguém está atrás
  (mesma regra dos losangos). As setas de borda respeitam `Hud.EDGE_RIGHT`.
- **Portas com anel, selo e caixa (PT-10)** (`DoorRing`, `DoorSeal`, `DoorTip`, `door_ring.gdshader`; teste `test_door_tip`): a
  moldura de cada porta aberta ganha um anel aditivo de energia na cor da sala (pulsa devagar, acende e alarga quando o herói chega
  a 7,5 m da porta, cheio a 4,2 m). `DoorSeal` é o selo pequeno do modificador principal (crânio = inimigo maior, crânio coroado =
  guardião, losango rachado = Provação, marca do anjo, gema = achado) no canto inferior direito do medalhão. A porta mais perto
  dentro de `DoorTip.NEAR` (4,2 m) mostra ao lado do medalhão uma caixa escura ("Recompensa: X", uma linha por modificador com o seu
  selo, e a tecla de interagir); some em 0,15 s, foge do herói, dos outros medalhões e da borda. Só leitura: `DoorTip.describe` é
  puro e testado. A porta de guardião mostra o anjo (PT-8). A coluna de Bênçãos da borda (acima) já cumpria o `build_column.png`.
- **Moedas no canto inferior direito** (`CoinCorner`): ouro (ou Abatidos no modo horda), Prata e Memória só depois de ter; o
  aviso de coleta ("+10 Prata", soma enquanto aparece) saiu do banner do topo para cá (`Hud._greet_materials` chama `pickup`).
  Os dons que agem sozinhos sobem 40 px, acima das moedas. O relógio com chefe vai para o canto superior direito (o ouro saiu de lá).
- **Vinheta de vida baixa** (`LifeVignette`): bordas escuras de tinta de sangue com gotas, pulso lento, a partir de 30% da vida;
  centro limpo, só no jogo (não sob telas). **Palavras-chave** (H4): `Glossary.COLORS` dá uma cor a cada termo (no texto da carta
  e no título da caixinha de significado); termo novo `fury` (Fúria). **Placa de interação** (H5): já é uma só, `StationSign`
  (hub, recompensa, loja, porta e veio): título dourado onde o objeto não tem outro (estações), a tecla real e o verbo; nas
  portas e recompensas o título dourado é o da `DoorSign` logo acima.
- **Retratos dos anjos (AN-1)**: `assets/ui/angels/angel_1..4.jpg` (512 x 768; recorte do busto em `AngelArt.CROP`) na coluna da
  esquerda das cartas do Encontro (`BoonChoice.by_angel`), no lugar do selo; sem arquivo o selo continua. Anjos 5 a 7: ainda sem
  Bênçãos, sem arquivo. Os originais ficam em `docs/art/angels_src/` (fora do pacote: `docs/*` no `export_presets.cfg`).
- Bugs: B1 era `tools/title_flow_check.gd` lendo a placa da Forja numa conta nova, onde a estação está fechada (HubGate) e não
  tem placa; o check abre a Forja antes. B2: `MAGICK_GLYPH` agora 107 (era 105, o do Brado); `tests/test_hud_lote2.gd` trava ids únicos.


## Cartela do título da sala (Lote N1, 2.4, 2026-11-22; testes em `tests/test_hud_place_card.gd`)
- Defeito: na Fonte a barra do Sacerdote Ancião caía em cima do nome da sala (o nome ficava a 42 px fixos sob a caixa da
  barra, que tem mais que isso). Agora `Hud._place_phase_box` põe o bloco sob a barra pela altura real (`get_combined_minimum_size`
  + `PHASE_GAP`), todo quadro; sem barra do chefe, fica sob o relógio (`PLACE_TOP`).
- O nome da sala vira cartela (`Hud._style_phase(true)`): marfim, 24 px, entre dois filetes de ouro (`GoldRule`, 300 px), sem caixa;
  dura `PLACE_TIME` 2,5 s. A fase do chefe continua em ouro 18 px sem filetes. O nome do chefe já é Cinzel (versalete natural).
- Só interface: mesma semente dá o mesmo `RESULT`. Capturar: Fonte com o Ancião e uma sala de luta, 720 e 1080.

## A Videira e a escolha de herói, telas (V2 e PT-9, 2026-11-23; testes em `tests/test_videira_v2.gd`, `tests/test_hero_station.gd`)
- **`VineScreen`** (3d, `scripts/ui/vine_screen.gd`, `host.open(VineScreen.new(), [Save.data])`): **mapa de constelações (SW-M1, 2026-11-25)**.
  Céu escuro (`SkyGround` + `StarField`, estrelas que piscam, nuvens de cor) com uma figura por ramo, montada com os nós que existem:
  Vida = o Leão, Provisão = o Cálice, Perseverança = a Espada (nomes aprovados; selo e videira ficam para ramos futuros). Dados em `VineLayout`
  (`CENTER`, `NODES`, `ROOT`, `OUTLINE`, `TINT`: coordenadas do mundo em px do palco; um ramo com um nó a mais pede uma linha, não código).
  `VineSky` desenha (cada nó é uma estrela por estado: acesa, anel pulsando, anel apagado, ponto escuro; linhas de luz da raiz ao nó; traços
  fracos que fecham a figura; anel e brilho ao regar). `SkyCamera` (pura) faz o zoom suave: abre no céu inteiro (zoom 1), escolher uma figura
  (Enter/clique numa estrela, ou a rodinha para cima) aproxima (zoom 2,4, figura à esquerda do painel), Esc/B ou a rodinha para baixo afasta,
  Esc no céu inteiro fecha; o foco passando a outra figura leva a câmera. Aproximado, aparecem as etiquetas de barro (`VineTag`) e o painel.
  Teste de captura: `--title --screen=vine --vine=N [--vine-zoom=vida|provisao|perseveranca]`.
  **Dica do nó (SW-M2)**: o painel é montado por `NodeTip` (pura): nome, "Ramo · Nª raiz", texto, "Total agora e depois: +5 → +10" com os números
  reais do dado (`vida_*` e `respiro` em valor, `ainda_de_pe` e as Colheitas em %, o que é interruptor como o Viajante não mostra número; nó
  trancado mostra o total quando o caminho abrir), "Antes: <nó anterior>" e o botão "Abra o anterior primeiro", preço com o ícone do material,
  "você tem N". Sem pergunta: Regar é a confirmação. Lógica em `Vine` (`state`, `buy`); vizinhança do foco em `VineLayout.neighbor`.
- **Dons (SW-M1)**: o medalhão ganhou o mesmo céu (`SkyGround` em `DonsScreen._ground`; um `<herói>_bg.png` pintado, se vier, ganha), linhas de
  luz finas e o brilho de quatro pontas nos Dons acesos (`StarGlyph`). Dom que custa Devoção diz "livres N" na linha de preço (SW-M2).
- **Carteira (SW-M3)**: Dons, Videira, Forja e Vendedor já levavam a carteira (`CoinCorner.wallet`: Prata, Memória, Esmeralda com ícone) no canto
  superior direito; o Livro de Ahk passou a tê-la lá também (`CoinCorner.corner`, ancorada, em placa escura), saindo da barra de baixo.
  Arte final em `assets/ui/vine/` (`VineArt`: bg, vase, bud_dry, bud_closed, bud_ready, cluster, tag, tag_back, panel) entra sozinha por caminho.
  Captura: `--title --screen=vine [--vine=N --silver=N --memory=N]` (N raízes já crescidas e bolsa para ver os quatro estados).
  Pendente: sons (água, folhas, madeira), saldo descendo contando, Compatibility sem brilho, arte do ChatGPT (bark, leaf, can, drops).
- **`HeroPickScreen`** (`scripts/ui/hero_pick_screen.gd`): folha pequena centralizada com um cartão por herói (`SaveData.HEROES`): nome, uma
  frase, estado (Escolhido / Escolher / Travada). A Maga travada leva o cadeado (`SealedMark`) e a frase "Ela é liberada quando você selar
  Morvath pela primeira vez."; clicar nela não faz nada. Escolher grava `data.hero` na hora (vale para a próxima descida) e sinal `picked(id)`.
- Ambas escalam por âncoras e contêineres (margens do `BookSpread`, `ActionBar.RESERVE` no pé), medidas nos testes contra o retângulo visível.


- **Árvore da Maga em triângulo (M2, 2026-11-23)**: `HeroScreen` abre com o herói escolhido (`SaveData.picked_hero`, ou `--hero=maga` nas capturas) e `TalentTree.triangle` liga sozinho quando o livro tem um Dom de `PIRO`. Três ramos a 120 graus num círculo verdadeiro (`HALF_TRIANGLE`), pontes entre vizinhos, Sustento em coluna à esquerda (`SUSTAIN_AT_TRIANGLE`) e o ciclo dos ápices como anel tracejado no sentido horário (Piromancia, Arcanismo, Selos, Piromancia; âmbar antigo quando o ápice e um Dom do ramo parceiro estão equipados, rubrica no ápice em foco). Cores âmbar e marfim em `TalentNode.BRANCH_COLOR`, glifos próprios (`Glyph.PIRO/ARCA/CTRL`, `TalentNode.glyph_of`). O Guerreiro não muda. Pendente: as páginas Abertura, O Guerreiro e Ofícios do Livro ainda são do Guerreiro (texto e retrato); só Dons é da Maga. Captura: `tools/shot.sh out.png 3 --title --screen=gifts --hero=maga`.

## Livro de Ahk como códice de pergaminho (2026-11-23, `docs/art/meta_screens_identity.md` 1)

**Substitui as árvores de nós dos Dons** (o losango do Guerreiro e o triângulo da Maga acima são históricos; `TalentTree`
foi apagada; `TalentNode` fica só como biblioteca de cores e glifos que o Compêndio e `TalentGlyph` ainda usam). O capítulo
Dons do `HeroScreen` é o `CodexBook` (`scripts/ui/codex_book.gd`), na página da esquerda:
- **Fitas** (`GiftRibbon`): uma por ramo, na tinta do ramo (`GiftArt.INK`, baixada para o papel); Guerreiro 6 (Combo,
  Fúria, Emeth, Magia, Pontes, Sustento), Maga 5 (Piromancia, Arcanismo, Selos, Pontes, Sustento), mais a dourada "Poder
  maior" (ultimates). A aberta desce mais; na ponta, um ponto de ouro por Dom equipado ali (até 3, depois "+N"). Foco ou
  mouse numa fita vira a página; Enter/clique entra nela.
- **Página do capítulo**: nome em Cinzel 30 na tinta do ramo, miniatura (faixa de até 110 px; encolhe sozinha para caberem as
  5 ou 6 entradas de Pontes e Sustento) e as **entradas** (`GiftEntry`) em ordem de leitura Entrada, Meio, Ápice. Capitular
  por degrau (`DropCap.gift`, `DropCap.Rung`: letra de 28 px, 34 px com filigrana, 44 px iluminada); Pontes parte a capitular
  na diagonal nas tintas dos dois ramos (`GiftArt.ink2`). **Fio na margem** (verdadeiro em ouro quando o pré-requisito está
  equipado, tracejado quando falta; `GiftEntry.Cord`, `Talents.needs_met`), só nos ramos de três degraus. Ápice com nota de
  margem "com um Dom de Fúria"; ponte com os dois ramos que une. Dois Dons no mesmo botão (`slot`) ficam seguidos por um
  "ou" em rubrica; o glifo da ação (`ActionSlot.mark`) fica à direita. Custo em velas pequenas (`Candles.paint`).
- **Cinco estados** (`HeroLoadout.State`), por desenho e por palavra: `LOCKED` pautas a lápis, contorno, "Maestria N";
  `SEALED` o texto preso por um cordão e um **lacre** de cera com a Memória gravada (`SealedMark.lacre`; a palavra é
  "lacre", nunca "selo"); `OPEN` tinta cheia, capitular só a traço; `EQUIPPED` capitular cheia na cor do ramo (enche de
  baixo para cima em 0,3 s) e folha de ouro na margem; `BLOCKED` tinta apagada, manícula e o motivo curto
  (`HeroLoadout.short_why`: "Pede: X", "Já há um Dom no botão Y: X", "Faltam 2 velas"). Romper o lacre mantém os dois
  apertos do `HeroScreen` (`arming`, 3 s), e a cera racha e cai em 0,38 s.
- **Pé da página**: "O nível N revela: X" em rubrica (some do alto da página nesse capítulo). **Cantoneiras** (`GiftArt.corner`):
  o leão do Guerreiro e a estrela de 8 pontas da Maga (nunca violeta), nos dois cantos de baixo. Título do herói na tinta dele
  (`GiftArt.title_ink`: Guerreiro `Book.INK`, Maga âmbar 6a3a14).
- **Poder maior** (`UltCard`, agora iluminura larga com miniatura): travada só o desenho de base a lápis e "Maestria N";
  aberta em cor; escolhida com moldura dupla de ouro.
- **Página da direita**: igual a antes (`_gifts_right`), com a **Devoção em velas** (`Candles`, até 25, 16 px, passo menor
  quando são muitas; vela acesa = livre, apagada com fio de fumaça = gasta) e o número escrito ao lado; as velas que a
  entrada em foco custaria (ou ocupa) tremulam (`Candles.set_preview`).
- **Entrada**: ↑/↓ andam nas entradas (a primeira sobe para a fita), ←/→ passam para a fita ao lado caindo na mesma linha,
  Enter/A equipa, tira ou rompe o lacre, mouse toma o foco ao passar e clica para o verbo. PageUp/PageDown seguem trocando as
  abas do Livro (Abertura, herói, Dons, Ofícios).
- **Miniaturas por id** (`GiftArt.texture`): `assets/ui/book/<id>.png` se existir, senão o substituto desenhado (a
  capitular grande do ramo, ou a letra a lápis da ultimate). Os ids estão em `assets/ui/book/LEIAME.txt`
  (`branch_combo|furia|emeth|magia|piro|arca|ctrl|bridge|sustain`, `ult_cleave|vortex|storm|dome_abs`); a arte do ChatGPT
  entra em `docs/steam-ia.md` antes.
- Capturas: `--title --screen=gifts [--hero=maga] --hero-xp=N --hero-opened=a,b --hero-equip=a,b [--ribbon=N]` (`--ribbon`
  abre numa fita; `--hero-*` agora valem para a Maga com `--hero=maga`). Testes: `tests/test_codex_book.gd`.
- Pendente: "Pavio Longo ou Cadeia Curta" da Maga estão em fitas diferentes, então o "ou" só liga Dons do mesmo capítulo; a
  rodinha do mouse não anda entre entradas; o clique é um só (o foco já lê, o clique faz o verbo); sem som de papel nem
  animação de dobra ao trocar de fita (só 0,15 s de opacidade).

## Quatro dicas da primeira descida (GP-9 e 10B-2, 2026-11-23; testes em `tests/test_first_tips.gd`)
- `FirstTips` (`scripts/core/first_tips.gd`, puro): `pick(data, ctx)` devolve a dica devida, uma por vez. Ordem: `armor` (inimigo com blindagem
  a menos de 14 m), `fight` (1,5 s de combate: atacar e esquivar), `hold` (8 s de combate e `fight` já vista: Ômega), `elo` (fora do combate, 2
  Bênçãos ou mais e nenhum Elo). Uma vez por save em `data.hub.tips` (ids; save sem a lista ganha a lista). Só vale em save novo: menos de
  `FIRST_RUNS` (2) descidas.
- `TipToast` (`scripts/ui/tip_toast.gd`, filho do `Hud`): caixa escura baixa e centrada (172 px acima da borda, acima da fileira de ações), 5,5 s
  com fade, 3 s de pausa entre dicas, nunca pausa nem pega entrada. Teclas por `UiKit.action_label` (`{attack}`, `{special}`, `{dodge}`), então
  teclado, mouse e controle dizem certo. Textos `tip_*` em `data/text_pt.tres`. Escreve o save ao aparecer.
- Fora para o robô, `--smoke` e `--nosave` (`FirstTips.enabled`). `--tips` força todas, sem gravar (capturas). Não toca na partida: o `RESULT`
  da semente 5 não muda.

## Dons em medalhão (PT-12, 2026-11-23; especificação `docs/art/dons_medallion_spec.md`, testes em `tests/test_dons_medallion.gd`)
A estação "Árvore de Dons" do Santuário abre `DonsScreen` (`--title --screen=dons [--hero=warrior|maga] [--dons-focus=<id>]`,
mais `--hero-xp`, `--hero-opened`, `--hero-equip` de sempre). **O medalhão substituiu o capítulo Dons do Livro de Ahk** (decisão do Daniel: "não quero ele no formato de livro"): saíram
`CodexBook`, `GiftEntry`, `GiftRibbon`, `Candles`, `UltCard`, `test_codex_book`, `test_c2_tree` e as chaves `codex_*` só dele.
O Livro tem Abertura, O Guerreiro e Ofícios (`HeroScreen.Chapter`: OPENING, HERO, OFICIOS); o botão "Dons" da página do
herói abre o `DonsScreen` por cima do livro (Esc e B fecham e devolvem o foco). `--title --screen=gifts` e `--screen=dons`
abrem o medalhão; `--ribbon` não existe mais. As descrições de capítulos antigos abaixo (tela de Dons em pergaminho, fitas,
velas, lacres) são histórico.
- **Dado**: `data/heroes/<herói>_medallion.tres` (`MedallionDef` com `MedallionNodeDef`: id, tipo coroa/Dom/ultimate, ângulo
  do meio-dia no sentido do relógio, raio, diâmetro), escrito por `_medallion` em `tools/make_data.gd` (tabelas
  `MEDALLION_WARRIOR` e `MEDALLION_MAGA`; Dom novo é linha nova). Espaço de projeto 1280 x 720, centro (620, 378), anel 254.
- **Peças**: `MedallionNav` (puro: posições, linhas de pré-requisito, direção por cone de 60 graus, salto de setor com
  LB/RB), `HoldGauge` (o "segure" de 1 s, solta e a barra volta em 0,2 s), `MedallionView` (moldura, anel, linhas acesas com
  brilho aditivo, nós por estado, foco, anel de segurar, clarão e 12 faíscas ao abrir), `DonsPanel` (disco, nome, "Dom · ramo ·
  degrau", descrição, custo em Devoção ou Memória, botão com a tecla ou botão do controle via `UiKit.action_label`),
  `DonsScreen` (fundo, halo, figura, faixa, contadores, traço do nó ao painel, entrada). Palco de 1280 x 720 centrado na tela
  (a 16:9 vale x1,5 em 1080; em outras proporções sobra fundo nas laterais).
- **Regras**: as do Livro, pelo `HeroLoadout` (`toggle`, `open`, `choose_ult`, `can_open`); toda mudança grava o save na hora.
  Apertar equipa e tira; um Dom selado abre **segurando** 1 s (sem Memória, o botão diz "Faltam N de Memória"); coroa mostra o
  herói (nível, barra de Maestria, "o nível N revela", frase); as ultimates se escolhem no aro (aro duplo, a escolhida cheia).
  Direcional anda ao nó mais perto no lado apertado, LB/RB (`tab_prev`/`tab_next`) saltam de setor, Y (`menu_reroll`) troca o
  herói (só heróis liberados), B/Esc fecha (o `ScreenHost`).
- **Arte final**: cada peça tem caminho previsto em `DonsArt` (`assets/ui/dons/<herói>_bg.png`, `<herói>_figure.png`,
  `frame.png`, `disc.png`, `memory.png`); o arquivo que aparecer é usado sem mexer em código. Provisório: fundo do título
  (sem o logo, desfocado, escurecido e aquecido para sair o violeta, shader `dons_art.gdshader`), retrato do Guerreiro com
  máscara de borda, recorte da Maga, moldura e faixa desenhadas, cristal de Memória do `DoorGlyph`.
- **Pendências conhecidas**: som (nota que sobe ao segurar, sino ao equipar, tom ao abrir) e o cristal que voa para o
  contador; o traço do nó ao painel só sai dos nós da metade direita (da esquerda cruzaria a figura); a estação do
  Santuário ainda é a árvore de pedra (o medalhão de bronze é peça do `environment-artist`).

### Dons em medalhão, clareza (teste com crianças, 2026-11-23)
Nome de cada ramo escrito dentro do aro; instrução fixa e legenda de quatro estados na coluna da direita; uma frase sobre
cada contador (Devoção: vagas que voltam ao tirar; Memória: gasta uma vez para abrir); nós maiores (48 e 72) e linhas mais
grossas; cadeado e custo só no Dom selado (pede Memória), número da Maestria no nó escuro; linha curta com o efeito, ou o
motivo ("Pede: X", "Faltam N de Memória"), ao lado do nó em foco; o foco começa no primeiro Dom que dá para equipar.
Porta: `DoorTip.near_door` usa `Arena.exit_at`, o mesmo teste de `Rooms.usable` e do interagir, sem alcance próprio.

## Livro de Ahk refeito (3e, 2026-11-23; `docs/art/book_spec.md`, `docs/art/meta_identities.md` 2)
`HeroScreen` (`scripts/ui/hero_screen.gd`) agora é um livro aberto sobre uma mesa que **só se lê**: duas páginas iguais
(`SPINE` 0,5), três fitas (`BookRibbon`: Abertura sépia com pena, o herói na tinta dele com o leão ou a estrela de 8 pontas,
Ofícios ocre com martelo; a aberta cai sobre a página com o nome na vertical), folio no pé (`FOLIO`: i ii, 1 2, 3 4) e orelhas
dobradas nos cantos de fora (`BookRibbon.ear`, clique vira). Cabeçalho: nome do capítulo com capitular em rubrica à esquerda
(`name_cap`, `name_rest`) e a Maestria à direita (`MasteryBar` e "O nível N revela: X"); **sem Devoção, sem bolsa, sem lugares
selados, sem rosto de Ahk**. `BookDesk`: mesa 1a120c com veio, vinheta e luz; as velas só aparecem onde sobra mesa ao lado do
livro (o livro não passa de 1,9 alturas de largura, `BookDesk.side_room`, ou seja, telas mais largas que 16:9 ultralargas).
- **Página do herói segue o herói** (`SaveData.picked_hero` ou `--hero=maga`): retrato (`warrior_page.png`; Maga
  `hero_maga_img.png`; `assets/ui/book/warrior_ink.png` e `maga_ink.png` quando chegarem), arma, jeito, habilidades com as marcas
  do HUD (`Hud.MAGA_GLYPHS` para ela), os **Dons equipados** só para leitura (`gifts_equipped`, 3 por linha, `TalentGlyph`; vazio:
  "Nenhum Dom equipado.") e dois botões: **Ver os Dons** (`to_gifts`, abre o `DonsScreen`, foco inicial) e **Compêndio**. Textos da
  Maga em chaves `*_maga` (`hero_weapon_name_maga`, `hero_skill_*_maga`, `hero_passive_maga`; `HeroScreen._hk`). Não há mais
  "Descer" nem "Voltar" nessa página: descer é só da Abertura (`descend`, único botão de destaque), voltar é Esc ou B.
- **Virar a página** (`BookTurn`, `HeroScreen.go`): LB/RB e PageUp/PageDown (`tab_prev`, `tab_next`), rodinha, orelha, fita (uma
  virada de 0,25 s por capítulo de distância; `BookTurn.route`) e direcional que não achou vizinho (`HeroScreen.page_step`); em
  laço (Ofícios para Abertura). A virada é uma folha: captura das duas páginas (`get_image`), a folha que sai fecha contra a
  lombada e a que chega abre por cima da antiga em 0,35 s, escurecendo ao ficar de pé; o conteúdo novo já está embaixo (a troca
  é síncrona, `chapter` muda na hora; a captura da página nova sai de `RenderingServer.force_draw(false)`, sem piscar). Sem tela
  (headless) e no navegador a troca é instantânea (`BookTurn.can_animate`). Pendente: shader de enrolar a folha (curva e sombra
  projetada), som de papel e de couro, fita que sobe e desce com animação, capa que abre.
- **Discernimento**: só leitura na página dos Ofícios (compra no Vendedor, `Discern.buy`), como já estava. Arte final em
  `assets/ui/book/` (`desk.png`, `spread.png`, `ribbon.png`, `ribbon_marks.png`, `opening_desk.png`, `warrior_ink.png`,
  `maga_ink.png`, `candle.png`, `pick_ink.png`, `pick_ink_broken.png`); hoje tudo é `_draw`. Testes: `tests/test_book.gd` (fim) e
  `test_hero_screen.gd`. Captura: `RES=1280x720 tools/gpu.sh shot out.png --title --screen=hero [--hero=maga]`.
- **Magia de volta, só nos golpes de segurar (2026-11-27, teste do Daniel)**: o "sem Magia" da tarde foi desfeito. Esmagador (segurar o esquerdo) 12 e Lança (segurar o direito) 20; os toques (combo e Corte Circular) são de graça. A barra de Magia volta, num azul mais claro (`3a7ee8`, `StatBar`, `HudArt.MAGIC_BLUE`, gota de custo). A linha do Ritmo de Batalha saiu do HUD (a mecânica fica; `_rhythm.visible = false`, pilha só com Vida, Magia e Supremo). A coluna de Bênçãos não mostra mais o nome ao ganhar (`BuildColumn.NAME_TIME` 0); o nome só aparece com o mouse em cima e na pausa.
