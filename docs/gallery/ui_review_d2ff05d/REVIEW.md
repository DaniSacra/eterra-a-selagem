# Revisão de layout da interface, build d2ff05d

Pedido do Game Director depois do teste do Daniel ("ainda precisa de muitas melhorias"). Só relatório: nada foi
implementado. Revisão do `ui-ux-designer`, 2026-11-19.

## Como foi feito

- Cópia isolada do HEAD `d2ff05d` (worktree em `/home/dani/games/ui-d2ff05d`, apagada no fim), capturas na RTX 5060 por
  `tools/gpu.sh` (Forward+, look estilizado do exe só onde a captura pede; o resto como o editor), no máximo 2 ao mesmo tempo.
- Fontes: `--title`, `--title --screen=map|juramentos`, `--hub --hero-at=...`, `--hub --hub-use=...`, `--hub-menu`,
  `--pad`, partida com `--bot --autopick --seed=5` (Longe e `--cam=near`), `--stress=300`, `--start=boss`, e os laboratórios
  `tools/ui_lab.gd` (mapa, loja, Provação, Altar, cartas, Elo), `tools/menu_lab.gd` (pausa, Bênçãos, derrota, vitória,
  Configurações por aba, Como Jogar, Músicas) e `tools/book_lab.gd` (Livro e Compêndio).
- Resoluções: 1280 x 720 em tudo e 1920 x 1080 no título, HUD (Longe, Perto, horda), placa do hub, folha do Portal,
  Livro e Configurações. O projeto escala por `canvas_items` a partir de 1280 x 720 com `expand`: a 1080 o layout é o
  mesmo, 1,5 vez maior; nada novo cortado ou sobreposto a 1080 que não esteja a 720. A diferença real entre as duas é
  nitidez (a 1080 o texto pequeno de 12 a 13 px fica legível; a 720 não) e as placas no mundo (`DoorSign`,
  `StationSign`), que seguem a câmera.
- Teclado, mouse e controle: as dicas trocam ao vivo onde existem (`hero_hint_pad`, `jur_hint_pad`, a placa do hub
  com o botão A, conferida em `hub_sign_book_pad_1280x720.jpg`); os problemas de dispositivo estão listados abaixo.
- Nas capturas com `--bot` o 5º losango (ultimate) não aparece: é o robô (`Hud._update_ult` esconde para ele), não um
  defeito. Com gente ele aparece trancado com "Maestria 2" (ver `trial_1280x720_trial.jpg`).

Severidade: **P0** o jogador lê errado ou não consegue usar; **P1** feio, confuso ou com cara de protótipo, visível em
toda partida; **P2** acabamento.

## P0

| # | Onde | Problema | Captura | Correção proposta |
|---|---|---|---|---|
| P0-1 | HUD: "Sala 1 de 11", relógio, "Ouro: 1", contador de golpes | Os números estão em Cinzel (`Hud._room`, `_clock`, `_gold`, `_combo`: `UiKit.TITLE_FONT`), cujo "1" é um traço vertical: "Sala 1 de 11" lê **"SALA I DE II"** (algarismos romanos), "Sala 11 de 11" lê "II DE II", "Ouro: 1" lê "OURO: I". É informação errada no canto que o jogador mais olha. | `fight_far_1280x720.jpg`, `fight_far_1920x1080.jpg`, `boss_1280x720.jpg` | Todo número do HUD em `UiKit.number_font()` (Alegreya Sans Bold com algarismos alinhados e tabulares, como as barras de vida já fazem); a palavra pode ficar em Cinzel ("Sala" em versalete, "1 de 11" em Alegreya). Teste: nenhum `Label` do HUD com dígito usa `TITLE_FONT`. |

## P1

| # | Onde | Problema | Captura | Correção proposta |
|---|---|---|---|---|
| P1-1 | Saudações do HUD (`EloBanner`: Provação vencida, Bênção nova, Elo formado) contra as placas do mundo | A saudação "Provação vencida / Vigor / 15 de vida máxima a mais" encosta na placa da porta "Bênção / Guardião" (os dois textos se tocam em x 712 a 720 a 720 linhas). Na loja a "Bênção nova" fica a 50 px das cinco placas. As duas camadas não sabem uma da outra. | `trial_1280x720_trial_won.jpg`, `shop_1280x720_shop.jpg` | A saudação reserva uma faixa fixa (y 96 a 190 a 720) e as `DoorSign` que caem nela descem abaixo dela enquanto há saudação (ou a saudação sobe para logo abaixo do relógio, y 52, e encolhe a uma linha quando há placas abertas). Simples: `DoorSign` ganha `avoid(rect)` lido do `EloBanner.rect()` no mesmo quadro. |
| P1-2 | Relógio e contador de golpes sobre o cenário | Sem fundo nem contorno forte, os dois ficam sobre os braseiros: "0:09" com a chama do braseiro norte logo atrás; "8 / Golpes / Corte Veloz" sobre o braseiro leste (Longe e Perto, horda, Morvath). Na luta de Morvath o topo empilha relógio, nome e barra (três linhas em 70 px). | `fight_far_1920x1080.jpg`, `fight_stress_1920x1080.jpg`, `boss_1280x720.jpg` | Véu escuro curto atrás do relógio e do contador (o véu de cantos cortados da `DoorSign`, alfa 0,55), contorno de 4 px como o botão do mapa. Na luta de chefe, o relógio vai para o canto de cima à direita, abaixo do ouro (ou some: o Hades não mostra relógio fora do modo), e o nome do chefe fica sozinho sobre a barra. |
| P1-3 | Números e "+1 ouro" na horda | Na horda os números de 40 empilham ("4 40 40 40") e o "+1 ouro" sai em dourado grande, maior que o dano, sobreposto a si mesmo ("+1 ouro+1 ouro"). O ouro somado não passa pelo `NumberTally`. | `fight_stress_1920x1080.jpg` | O ganho de ouro soma como o dano (`NumberTally` com a chave "ouro", janela de 0,6 s, um texto só "+3 ouro"), corpo 15 px no `UiKit.OLD_GOLD` claro, e nunca dentro do raio de 3 m de outro número (já é a regra do dano). |
| P1-4 | Livro de Ahk aberto no hub | A página O Guerreiro e a Abertura têm "Descer às catacumbas" em destaque; no hub a descida é o Portal (com a confirmação). O botão pula a folha do Portal e duplica a função. No Livro há 4 botões em duas fileiras desalinhadas (Dons e Descer numa, Compêndio e Voltar alinhados à direita na outra). | `hub_use_book_1280x720.jpg`, `book_1280x720_opening.jpg` | Aberto no hub, o Livro não mostra "Descer às catacumbas" (`HeroScreen.open(..., hub = true)`; no título continua). A fileira de baixo vira uma só: "Dons" (o capítulo), "Compêndio", "Voltar", alinhada à direita da página. |
| P1-5 | Abas dos capítulos do Livro | "Abertura / O Guerreiro / Dons" são abas escuras do menu (`UiKit.tab`) flutuando fora do livro, coladas no topo da tela (4 px de margem a 720). Não são marcadores do Livro; o Compêndio, também do Livro, não as tem. | `hub_use_book_1280x720.jpg`, `book_1280x720_gifts_furia_plena.jpg` | Marcadores de couro saindo da borda de cima da capa (`BookSpread` desenha 3 linguetas com a fita petróleo e o nome em Cinzel 14 px em ouro velho; a ativa mais longa e clara). Margem mínima de 12 px do topo. |
| P1-6 | Botões escuros do menu sobre o pergaminho | Folha do Portal, Vendedor, Livro e Compêndio usam os botões de tinta escura dos menus (`UiKit.button`) sobre o papel: blocos pretos pesados que não são da língua do Livro (as cartas de ultimate do Livro também: "Voragem" é um retângulo preto vazio). | `hub_use_portal_1280x720.jpg`, `book_1280x720_gifts_furia_plena.jpg`, `book_1280x720_codex_0.jpg` | Um `Book.button` (texto em tinta `Book.INK` sobre papel um tom mais escuro, fio `Book.GILT` de 1 px, foco = fio de rubrica e losango à esquerda; a ação principal com papel tostado e texto rubrica). Mesma altura e foco dos de hoje, só o estilo. As cartas de ultimate no mesmo estilo, com o estado escrito ("Trancada: Maestria 6"). |
| P1-7 | Placa e folha do Vendedor e do Forjador | Em toda visita ao Santuário a placa diz "A definir" e a folha "◆ A DEFINIR / Ainda não há nada para comprar aqui nesta versão.": é texto de protótipo dentro do jogo. | `hub_sign_vendor_1280x720.jpg`, `hub_use_vendor_1280x720.jpg` | Até a Fatia 1: placa com uma linha do lugar ("Mercador das catacumbas", "Forja da Emeth") e a folha com "Fechado por enquanto" no lugar de "A DEFINIR", sem "nesta versão". O Forjador sai disso na Fatia 1 (ver a seção da Fatia 1). |
| P1-8 | Santuário sem orientação | Ao chegar não há nada que diga onde estão as cinco estações: a placa só aparece a 2,2 m. O Portal fica cortado pelo topo da tela quando o herói chega nele (a placa vai para baixo do herói, sobre a praça). | `hub_arrive_1280x720.jpg`, `hub_sign_portal_1280x720.jpg` | Nome curto e fraco (marfim a 0,5, 13 px, sem véu) sobre cada estação visível, que vira a placa inteira no foco; e o nome do lugar ("Santuário") por 2 s ao entrar, como `Hud.show_place` nas arenas. O enquadramento do Portal é da câmera (`HubPlan.CAM_REACH`, gameplay): pedir 1 a 2 m a mais de alcance ao norte. |
| P1-9 | Placa da estação | "[E] Interagir" é genérico e repete o que a linha de cima diz ("Descer às catacumbas"). | `hub_sign_portal_1280x720.jpg`, `hub_sign_book_1920x1080.jpg` | O verbo da estação no lugar de "Interagir": "[E] Descer", "[E] Ler", "[E] Forjar", "[E] Ver os Dons", "[E] Comprar" (chave por estação, `hub_use_<id>`); a linha do meio vira o que a estação é, não o que faz. |
| P1-10 | Fim da partida | Ordem dos botões diferente: derrota "Descer de novo" (destaque) e "Voltar ao Santuário"; vitória "Voltar ao Santuário" (destaque) e "Descer de novo". Na derrota o HUD inteiro continua visível atrás do véu (Mapa, contador de golpes, fileira de Bênçãos), na vitória não. Números em grade com uma célula vazia (Tempo, Inimigos; Maior sequência sozinha). | `menu_1280x720_defeat.jpg`, `menu_1280x720_victory.jpg` | Mesma ordem nos dois (o destaque muda, a posição não: "Voltar ao Santuário" à esquerda, "Descer de novo" à direita); HUD escondido sob qualquer `EndScreen`; os números numa fileira só de 3 ou 4 colunas (rótulo pequeno em cima, número embaixo), que libera a altura que a Fatia 1 precisa para "Trazidos". |
| P1-11 | Configurações, aba Vídeo e Conforto | Duas formas de controle na mesma página: "Janela" e "Câmera" com "<" e ">" de texto ASCII, "Tela cheia" como linha clicável em negrito com "sim" minúsculo. "Janela 1280x720" continua ativa com "Tela cheia sim". "Câmera: Longe" não diz o que muda; Conforto não explica nada. Metade da página vazia. | `title_1280x720_options_tab_video.jpg`, `title_1280x720_options_tab_comfort.jpg` | Um controle só: seletor com divisas de ouro velho desenhadas (as da `HudMark`) no lugar de "<" ">", valor em versalete ("Sim", "Não"). "Janela" apagada e pulada pelo foco quando a tela cheia está ligada. Embaixo da página, a linha da opção em foco: "Perto: a câmera fica mais próxima do Guerreiro e a sala passa a rolar com ele." (uma chave `opt_<id>_tip` por opção). |
| P1-12 | Barras de rolagem | O Compêndio e "Suas Bênçãos" usam a barra de rolagem cinza padrão do Godot, a única peça sem tema no jogo. | `book_1280x720_codex_0.jpg`, `menu_1280x720_boons.jpg` | Tema da `VScrollBar` no `UiKit.theme()` e no `Book.theme()`: trilho de 2 px (`OLD_GOLD` a 0,3 / `Book.GILT` a 0,3) e pegador em losango alongado; e um esmaecer de 24 px na borda de baixo da lista quando há mais (hoje a última linha é cortada no meio). |

## P2

| # | Onde | Problema | Captura | Correção proposta |
|---|---|---|---|---|
| P2-1 | Título | O ícone de "Sair" é o símbolo de energia dos aparelhos, fora do mundo (os outros são espada, livro e engrenagem). | `title_1280x720.jpg` | Uma porta em arco (a marca do Portal, `HowToScreen.step_glyph(0)`) ou uma vela apagada. |
| P2-2 | Juramentos e Músicas | Planilhas: linhas em caixa com texto corrido; Músicas com 14 botões "Ouvir" iguais em coluna e cabeçalhos ("Onde toca", "Ouvir") em Alegreya dourado, não no `UiKit.section`. Painel das Músicas mais largo que o das Configurações de onde se abre. | `juramentos_1280x720.jpg`, `title_1280x720_music.jpg` | Juramentos: o nível como losangos acesos já existe; tirar a caixa de cada linha (só um fio entre linhas), estado à direita só quando ligado. Músicas: um botão Ouvir só para a linha em foco (Enter ou A toca), cabeçalhos com `UiKit.section`, largura igual à das Configurações. |
| P2-3 | Como Jogar, aba Controles | Linhas de altura diferente; o nome da ação centrado na linha e a descrição de duas linhas alinhada em cima: as colunas não batem; a nota final fica colada nos botões. Controle escrito em letra ("X", "RB") em vez da plaqueta redonda que a placa do hub já usa. | `title_1280x720_howto_controls.jpg` | Todas as colunas alinhadas em cima, 6 px entre linhas, a nota com 14 px de margem acima dos botões; teclas e botões na plaqueta `ActionSlot.key_plate` (redonda no controle). |
| P2-4 | Configurações, aba Controles | Só o teclado; o controle não aparece (nem para ler). | `title_1280x720_options_tab_controls.jpg` | Segunda coluna "Controle" com a plaqueta do botão, só leitura até o remapeamento do controle existir. |
| P2-5 | Compêndio, Inimigos e Dons | Tabela sem ícones, linhas de 21 px, "64 derrotados 5 de elite" sem separação, dois terços da página vazios. | `book_1280x720_codex_4.jpg`, `book_1280x720_codex_0.jpg` | Linha de 34 px com uma marca a tinta por papel (`codex_role_*`), contagem "64 · 5 elite" em `FADED`. |
| P2-6 | Folha do Portal e do Vendedor | A fita petróleo cai fora do centro da folha única (x 730 numa folha centrada em 640), atravessando a borda de baixo. | `hub_use_portal_1280x720.jpg`, `hub_use_vendor_1280x720.jpg` | Com `single`, a fita sai do meio (ou do terço direito, mas dentro da capa, como no livro aberto). |
| P2-7 | Pausa | O canto de baixo do painel cobre o medalhão do herói e o começo da barra de vida. | `menu_1280x720_pause_many.jpg` | Painel termina 16 px acima do medalhão (`Hud.CREST` + margem) ou o HUD de baixo some com a pausa. |
| P2-8 | Menu do Santuário | Painel de tinta escura do `PauseMenu`, enquanto tudo o mais no Santuário é folha do Livro. | `hub_menu_1280x720.jpg` | Aceitável (é o menu do jogo); se o Daniel quiser o Santuário inteiro no papel, o menu do hub vira uma `HubPanel` com a lista. Baixa prioridade. |
| P2-9 | Mapa da descida | "Porta aberta nesta sala: atravesse-a na arena para seguir por aqui" em rubrica (lê como erro) e quebra com "aqui" sozinho; legenda de 15 itens com marcas de 14 px; o meio da página esquerda vazio. | `map_doors_1280x720.jpg`, `map_1280x720_map.jpg` | Texto curto em tinta: "Uma porta desta sala leva até aqui."; legenda só com o que aparece no mapa daquela descida, marcas de 18 px. |
| P2-10 | Cartas da Provação | O foco põe a moldura dupla clara em volta de uma carta Comum, que lê como a moldura dourada da Lendária. | `trial_1280x720_trial.jpg` | Foco só com o filete marfim de dentro (o das cartas de Bênção), sem trocar a cor da moldura de fora. |
| P2-11 | Medalhão "Seguir em frente" do Altar | A janela gótica pintada tem uma cruz de quadrifólio no alto (regra 4 da direção de arte: nunca cruz). | `altar_1280x720_altar.jpg` | Asset do `technical-artist` (`assets/ui/events/passage.png`): recortar ou repintar o alto da janela. |
| P2-12 | Texto pequeno a 720 | "No nível 12: Sangue Quente" (12 px), níveis sob os medalhões das Bênçãos na derrota e na vitória (marcas ilegíveis), habilidades do Livro a 13 px, dica do Livro a 12 px. | `book_1280x720_gifts_furia_plena.jpg`, `menu_1280x720_defeat.jpg` | Piso de 14 px a 720 em todo texto que se precisa ler (já é a regra do C17 para o Compêndio); as marcas de nível sob os medalhões saem (o nível já está em "Suas Bênçãos"). |

## O que está bom e fica

- Título: botões reais sobre a arte, legíveis, foco claro.
- Cartas de Bênção, Elo, Provação e Altar: hierarquia boa (medalhão, nome, origem, efeito), molduras por raridade,
  "VOCÊ ENTREGA / VOCÊ RECEBE" claros, o porquê das trocas apagadas.
- HUD da luta: a 1080 é limpo e nada cobre o herói, os inimigos nem os avisos no chão, também na horda de 300 e com a
  câmera Perto (a Perto só aproxima o cenário; o HUD fica igual e continua fora do caminho).
- Mapa da descida: o grafo lê bem (caminho em rubrica, portas abertas em ouro, ramos deixados apagados).
- Livro: a árvore de Dons com o painel Efeito, Custo, Pré-requisito, Estado e Próximo passo é a base certa para a Fatia 1.

## Fatia 1: o que as telas novas precisam conversar com o que existe

As três telas (Forja, Encontro com os anjos, Abrir Dom com Memória) e os pontos de contato, para entrarem sem criar
uma quarta língua visual:

1. **Uma língua só para o Santuário: a folha do Livro.** A Forja abre no Forjador como a `HubPanel` (folha única,
   título rubrica, `GoldRule`), não como menu escuro. Antes dela, fazer o `Book.button` (P1-6), senão a Forja nasce
   com os blocos pretos. A `HubPanel` hoje só tem título, linha e botões: a Forja precisa de uma página de duas colunas
   (à esquerda os postos Temperar I e II como linhas do índice, `Book.index_entry`; à direita o posto em foco com
   "◆ EFEITO", "◆ CUSTO", "◆ ESTADO", "◆ PRÓXIMO PASSO", os mesmos rótulos do painel de Dom do Livro). Ou seja: a Forja
   é um `BookSpread` de duas páginas como o Compêndio, não uma `HubPanel` esticada.
2. **Materiais num lugar fixo e igual em todo lugar.** Prata Antiga e Fragmento de Memória precisam de uma marca cada
   (`DoorGlyph` para a porta e o mapa; o mesmo desenho no canto da página da Forja, do Livro e na tela de fim). Proposta:
   um canto "Bolsa" no alto à direita da página direita do Livro, da Forja e do Compêndio (marca + número em
   `UiKit.number_font`, nunca Cinzel, P0-1). Na Forja o que falta aparece como no Altar ("Faltam 7 de Prata", em `Book.WARN`).
3. **Placas das portas e mapa.** `DoorGlyph.of_reward` ganha PRATA e MEMÓRIA; a legenda do mapa já está longa (P2-9):
   entrar junto com a legenda filtrada pelo que existe na descida. A placa da porta segue o `DoorSign` com a marca à
   esquerda do nome, sem texto novo além do nome.
4. **Abrir Dom com Memória**: o estado novo "revelado, fechado" entra nos quatro estados do `TalentNode` (equipado,
   aberto, bloqueado, trancado) como quinto: moldura inteira, glifo na cor do ramo apagado a 0,5, e embaixo o custo em
   Memória (a marca de Memória pequena com o número) no lugar dos losangos de Devoção. O painel ganha a ação "Abrir"
   ("Enter ou A: abrir por 3 de Memória"), com a dica do rodapé trocando ao vivo como já faz (`hero_hint_pad`), e a
   linha de "Próximo passo" diz "Juntar 2 de Memória" quando falta. Abrir é irreversível: uma confirmação curta na
   própria página (o botão vira "Abrir? Sim / Não" por 3 s), não uma folha nova por cima do livro.
5. **Encontro com dois anjos**: é uma tela da luta, então segue a `BoonChoice` (título em Cinzel sobre a partida
   escurecida, dica embaixo), não o Livro. Dois selos grandes (o `PsalmIcon` como molde: medalhão vetorial de tinta
   com aro de ouro velho, cor e símbolo da família; nunca sol nem cruz, a regra da seção 4 da spec), nome do anjo e a
   linha de temperamento embaixo; foco começa no primeiro (A10: no máximo 2 apertos a mais). Escolhido, as três cartas
   aparecem no lugar com o selo do anjo pequeno no alto, e "Voltar ao par" é o B/Esc (uma linha na dica). A cor do selo
   tem de ficar longe das cores reservadas (a Chama perto do vermelho do perigo; a Vigília no petróleo do herói, que a
   direção de arte reserva a ele): pedir ao `art-director` a cor de cada selo antes de desenhar.
6. **Tela de fim**: "Trazidos" (Prata, Memória) precisa de altura; vem depois de compactar os números (P1-10). Ordem
   proposta: título, causa/onde, Bênçãos levadas, **Trazidos**, Maestria, números numa fileira, botões.
7. **Saudações**: "Prata +3" e "Memória +1" ao pegar a recompensa usam o `EloBanner` em fila (como "Bênção nova"), e
   por isso o P1-1 (saudação contra as placas) deve ser resolvido antes ou junto.
8. **HUD**: os materiais não entram no HUD da luta (pouca informação permanente); só no fim e no hub. O ouro continua
   sendo a única moeda à vista na descida.

## Ordem sugerida

1. P0-1 (fonte dos números), P1-2, P1-3: pequenos, em toda partida.
2. P1-6 (`Book.button`), P1-5, P1-4 e o tema de rolagem (P1-12): a base da Fatia 1.
3. P1-1, P1-10, P1-11, P1-7 a P1-9.
4. P2 junto com as telas da Fatia 1 que tocam cada uma.

## Capturas

Nesta pasta, JPG de qualidade 4 a partir dos PNG da GPU. Nome = tela_resolução (os do Livro e dos menus com o sufixo do
laboratório).
