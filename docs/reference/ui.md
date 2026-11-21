# Interface (telas, HUD, livro, menus)

Referência detalhada movida do `CLAUDE.md` em 2026-11-21. Ler só a seção que a tarefa pede (grep pelo nome da classe ou do item).

## Tela de título (2026-11-15)
- **Fluxo de entrada (2026-11-21, pedido do Daniel)**: o título vem primeiro; **Iniciar abre a escolha de save** (Esc
  volta ao título). Save com descida vai ao hub; **save vazio vai direto à primeira descida** (`boot.gd` `first_scene`:
  `runs` 0), e o Santuário só aparece depois dela: a tela de fim da primeira descida de um save só tem "Voltar ao
  Santuário" (`EndScreen.home_only`, `Game._open_end`). O canto "Save N · Trocar de save" saiu (a chave `slot_switch`
  ficou sem uso). Sem save (`--nosave`, testes) Iniciar vai ao hub. Testes em `tests/test_save_slots.gd` e no
  `tools/title_flow_check.gd`.
- **Escolha de save (2026-11-19; capturas em `docs/gallery/save_slots/`)**: escolha entre Save 1, 2 e 3
  (`SaveSlotScreen`, `scripts/ui/save_slot_screen.gd`, na página dos menus, `UiKit.page`, sobre a arte do título
  escurecida). Cada cartão mostra o medalhão do Guerreiro,
  Maestria, descidas, vitórias, Bolsa (Prata e Memória, `MaterialCount`) e "Última partida" (data e hora do fim da última
  descida, `played_at` gravado no `Game.log_run`); vazio diz "Espaço vazio" e escolher cria um save novo na hora.
  "Apagar" fica embaixo de cada save que existe e pergunta numa página própria "Apagar o Save N? Não há volta.", com
  Cancelar em foco (`slot_erase_*`). Esquerda e direita andam nos cartões, baixo vai ao Apagar; Esc e B fecham a pergunta
  e só fecham a tela quando aberta do título com um save em uso. No título, o canto de baixo à esquerda diz "Save N ·
  Trocar de save (Esc)" (clique, ou Esc/B no título, reabre a escolha). Regras em `SaveSlots` (`core/save_slots.gd`,
  puro): cada save é um arquivo inteiro gravado pelo `SaveFile` com `.bak`; `user://profile.json` guarda o save em uso
  (`active`) e as **opções, que são do computador e valem para os três** (`Save.set_option` grava só o perfil,
  `write_options`; trocar de save não muda volume, tela nem teclas). O `save.json` de antes lê como Save 1 enquanto o
  Save 1 não existe e vira ele no primeiro `Save.write` (`SaveSlots.migrate`: copia o arquivo e o `.bak` e renomeia o
  antigo para `save_legacy.json`, nunca mais lido; o progresso inteiro fica, testado com todos os `tests/fixtures/save_v*.json`).
  Ler nunca grava. `Save.use(n)` põe o save em uso (cria o vazio), `Save.erase(n)` apaga o arquivo, a cópia, o `.tmp` e os
  `.broken` (o Save 1 também aposenta o `save.json` antigo, que não volta). `runs.jsonl` continua um só, com `slot` em cada
  linha. Sem a tela: `--nosave`, os testes (o gancho desliga o save), `--title` (capturas) e `--slot=N` (usa aquele save);
  `--title --screen=slots` captura a tela, `--save-dir=pasta` lê saves de outra pasta (só leitura com o `--nosave` do
  `tools/gpu.sh`), `--slot-ask=N` abre a pergunta. Testes em `tests/test_save_slots.gd`; fluxo por teclado no
  `tools/title_flow_check.gd` (numa pasta própria). Benchmark de interface com o Hades II e propostas P0 a P2:
  `docs/design/benchmark_hades2_ui.md`.
- A arte cinematográfica aprovada pelo Daniel (`assets/ui/title/title_screen_reference.png`, feita por IA; quatro heróis,
  fortaleza, portal, logotipo pintado) é o fundo, contida sem corte (`TitleBackdrop`, `scripts/ui/title_backdrop.gd`; faixas
  desfocadas nas outras proporções; névoa, brasas e partículas do portal que não tocam rosto, lâmina nem logotipo). Os botões
  pintados foram apagados numa cópia limpa (`title_bg.png`, `tools/make_title_bg.sh`) e os reais (`TitleMenu`, `TitleButton`,
  vetor, Alegreya Sans Bold) ficam exatamente por cima, na escala da arte. Medidas: `docs/art/title_screen_spec.md`.
- `scripts/boot.gd` compõe: Iniciar entra na partida (o único fluxo), O Guerreiro (`HeroScreen`, E2-06), Como Jogar
  (`HowToScreen`, teclas reais lidas do mapa, com o Compêndio dentro), Configurações (`OptionsScreen`), Sair só no desktop.
  Os quatro botões pequenos ficam numa coluna de 52 px de altura a cada 62 px a partir de y 506 da arte
  (`TitleButton.SMALL_*`; antes três a cada 71). Fluxo testado por `tools/title_flow_check.gd` (teclado, sem tela, passa
  pela tela do herói e pelo Compêndio). Os outros três heróis da arte ainda não têm nome nem papel no jogo.
- **Tela do herói** (E2-06, `scripts/ui/hero_screen.gd`): medalhão e "O Guerreiro", Maestria (`MasteryBar`, nível num
  losango de ouro velho, barra de XP e "O nível N revela: ..." do que o próximo nível dá), Devoção em losangos (usada e livre),
  a árvore de Dons em losango (`TalentTree`, `TalentNode`: passiva no centro, Combo em cima, Fúria à direita, Magia
  embaixo, Emeth à esquerda, entrada, meio e ápice para fora, pontes nas diagonais, sustento no canto de baixo à esquerda;
  trancado mostra cadeado e o nível; custo em losangos pequenos embaixo de cada nó; linha acesa entre dois equipados;
  equipado = losango cheio da cor do ramo, fio esmeralda mais grosso e brilho em volta (`TalentNode.EQUIPPED_*`,
  `GLOW_*`), só destravado = tinta escura com fio de ouro velho e o símbolo na cor do ramo; Combo em carmesim, a cor do
  punho da Emeth, antes um cinza que lia como desligado, `TalentNode.BRANCH_COLOR`) e as
  duas ultimates (`UltCard`, trancada mostra o nível). O painel da direita conta o Dom ou a ultimate em foco e, quando
  não dá para equipar, por quê, nas regras do `Talents` (`HeroLoadout`, `core/hero_loadout.gd`: `state`, `why`,
  `toggle` que tira junto o que dependia, `choose_ult`). A dica de teclas do rodapé troca ao vivo entre teclado e
  controle (`Controls.device_changed`). Enter, A ou clique equipa e tira; grava na hora em
  `heroes.warrior.equipped`/`ultimate`. Nome da passiva: "Ímpeto da Emeth" (1ª opção da spec, `hero_passive`).
  Capturas: `--title --screen=hero` com `--hero-xp=N`, `--hero-equip=a,b`, `--hero-ult=id` (só na sessão, nada gravado,
  `Save._dev_hero`). Testes em `tests/test_hero_screen.gd`.
- **Compêndio** (E2-11, `CodexScreen`): abas Dons (os do Guerreiro na ordem em que destravam; antes, "???" e "Maestria N")
  e Golpes (a antiga `MovesScreen`, que saiu); aberto pelo Como Jogar e pela pausa; `--screen=codex|moves`. E4-05: oito
  abas numa fileira (Dons, Bênçãos, Elos, Salmos, Inimigos, Morvath, Arenas, Golpes; `CodexScreen.TAB_WIDTH` 120,
  cabe a 720): Salmos (descoberto: medalhão `PsalmIcon`, nome, efeito, vezes tomado; não: selo fechado, "???" e
  "Pista:" com o `hint_key`), Inimigos (`CodexScreen.ENEMIES`, nome, papel `codex_role_<role>` e derrotados, elites à
  parte; nunca derrotado "???"), Morvath (vezes enfrentado e selado, as 4 fases com nome e dica quando alcançadas,
  `phase_text` corta o `boss_phase_N` no primeiro ponto), Arenas (salão, as três arenas e a Câmara do Selo, vezes).
  Só texto de jogo (D-62 a). Dados no fim da partida por `Game.codex_run` (no `award_mastery`): `codex.enemies.<id>`
  `defeated`/`elite` (de `Game.defeated`, a elite conta para o comum), `codex.enemies.morvath` `met`, `phase` (o maior,
  `SaveData.codex_max`), `defeated`; seção nova `codex.arenas.<id>.entered` (`Game.arenas_seen`, `hall` para o salão).
  Testes em `tests/test_e4_ui.gd`.
- **Livro de Ahk (etapa 2 do pacote de arte, 2026-11-18; pranchas 04, 05 e 09 só locais; antes e depois em
  `docs/gallery/artpack/stage2/`)**: a tela do herói e o Compêndio são páginas de um livro aberto (`BookSpread`,
  `scripts/ui/book_spread.gd`: capa de couro, folhas, dois pergaminhos em `book_page.gdshader` com a dobra em `spine`,
  cantoneiras de ouro velho, fita petróleo; as páginas são `left`/`right` e se refazem quando o conteúdo muda de
  tamanho) na linguagem `Book` (`scripts/ui/book.gd`: tinta `INK`, `FADED`, rubrica `RUBRIC`, ouro que lê no papel `GILT`,
  `Book.theme()` sem contorno, `heading`, `section` "◆ EFEITO", `index_entry`, `ink(cor)` para escurecer cores de família
  e ramo no papel). `HeroScreen` tem três capítulos em marcadores (`HeroScreen.Chapter`: OPENING "Abertura", HERO "O
  Guerreiro", GIFTS "Dons"; abre em HERO com foco em "Dons"; `open(data, chapter)`): Abertura com as palavras de Ahk do
  cânone (`book_epigraph`, assinado "Ahk, o Escriba") e a descida em três passos (os mesmos sinais e textos do Como
  Jogar, `HowToScreen.step_glyph`); O Guerreiro com o retrato pintado (`assets/ui/hero/warrior_page.png`, recortado da
  prancha 04, IA, `docs/steam-ia.md`), Arma, Estilo e Habilidades com as marcas do HUD (`ActionSlot.mark`,
  `ActionSlot.glyph_mark` para a ultimate) e a passiva; Dons com a árvore numa lousa e o painel Efeito, Custo,
  Pré-requisito (`HeroLoadout.needs_text`), Estado e Próximo passo (`next_step`, `xp_missing`). "Descer às catacumbas" na
  Abertura e no Guerreiro emite `descend`, e o título faz o mesmo que o Iniciar (`boot._open_hero`; Juramentos antes
  depois da primeira vitória). Só o Guerreiro: nenhum outro herói, nenhuma vaga trancada. Árvore (prancha 09): cada Dom
  com o próprio glifo pelo efeito (`TalentGlyph`, nunca cruz nem sol; sem glifo cai no do ramo,
  `TalentNode.branch_glyph`), moldura de ouro velho com pontas, quatro estados (equipado, aberto, `BLOCKED` com a
  moldura cortada nas pontas e o glifo apagado, trancado com cadeado e nível), o foco acende em marfim o caminho do que
  o Dom pede (`TalentTree.path_of`, `TalentNode.on_path`) e o losango se ajusta ao espaço (`TalentTree.fit`). Compêndio
  (`CodexScreen`): índice na página esquerda (`SPINE` 0,3) com marca a tinta por capítulo (`CodexMark`) e quanto foi
  achado (`progress`, `codex_count`), cima e baixo andam no índice, direita vai ao Voltar; a lista na página direita em
  tinta, os Dons com o nó da árvore (`TalentGlyph.mark`). Capturas: `--title --screen=hero|gifts|book|codex` e
  `tools/book_lab.gd` (comando no topo). Testes em `tests/test_book.gd`.
- **Benchmark de interface contra o Hades II (P0 e P1 de `docs/design/benchmark_hades2_ui.md`, UI-HB1, HB2, HB5 de
  `docs/art/benchmark_hades2_style.md`, item 3 do `docs/design/ciclo_visual_2026-11-20.md`; testes em
  `tests/test_bench_ui.gd`; capturas em `docs/gallery/ciclo_visual_1120/ui_*`)**: a tecla de usar da partida
  (`Rooms.prompt`) fica pendurada embaixo do que se usa, não em cima do herói (`StationSign.under`, `place_under`,
  `UNDER_GAP`; âncora em `Rooms.use_spot`: a recompensa, o item da loja, o medalhão da porta), e onde o herói cobre
  esse ponto desce para baixo dos pés dele (`StationSign.hero_box`); na loja sem ouro a linha diz "Faltam N de ouro"
  (`shop_use_short`). Placas da loja em duas linhas, nome e preço, a falta pela cor do preço (`DoorSign.set_gold`,
  `SHORT_COLOR`; a palavra do grupo saiu). **Barra de ações** (`ActionBar`, `scripts/ui/action_bar.gd`):
  `ActionBar.attach(tela, [ActionBar.entry(ação, verbo, ao_clicar, extra)])` põe no rodapé a tecla real de cada ação
  (`StationSign.KeyCap`, `UiKit.action_label`; A e B do controle para `ui_accept`/`ui_cancel` por `UiKit.MENU_PAD`) e
  o verbo, que troca ao vivo entre teclado e controle e é clicável; `ActionBar.RESERVE` é a margem de baixo dos livros.
  Nas Bênçãos, nos anjos, no Livro (o verbo segue o capítulo: Confirmar, Equipar ou tirar, Abrir com Memória;
  `HeroScreen.bar`), no mapa, no Compêndio, na Forja, na escolha de save e na pausa; as frases de teclas saíram
  (`hero_hint*`, `slot_hint*`, `map_close_hint` ficaram sem uso). **Contador de golpes** fora da luta (UI-HB5): uma linha
  só sobre a barra de vida, à direita do medalhão (`Hud._combo_row`: número `FONT_COMBO` 24 com contorno, sem véu, a
  palavra e o nome do golpe em Alegreya Sans Bold 14), que sobe quando o selo da maldição aparece. **Cartas de
  Bênção** (UI-HB1, HB2): altura pelo conteúdo, de `BoonCard.MIN_H` 300 até `SIZE.y` 450 (`fit_height`), descrição em
  `UiKit.rich` com o corpo em marfim mais quieto (`BoonCard.BODY`) e números e palavras-chave em negrito no marfim
  cheio (`UiKit.strong`, `UiKit.STRONG`; `BoonChoice.describe(..., marked)`, `Glossary.emphasize`), alinhada à
  esquerda; os números do efeito em linhas rótulo e valor (`BoonChoice.facts`, `fact_value`, chaves `fact_*`; nós
  `Facts`, `Fact_<stat>`, `Value`, e `Was` com o valor de antes quando a carta troca uma Bênção que tem o mesmo número).
  Troca sempre com Sai e Entra (`Replaces`). **Glossário** (`Glossary`, `scripts/ui/glossary.gd`) à direita da fileira
  de cartas: os termos da carta em foco (congelar, queimadura, atordoar, Ômega, Magia, armadura, Corte Veloz; chaves
  `gloss_<id>`, `_text` e `_words`, as raízes que acham a palavra no texto), no máximo 2. **Encontro dos anjos**: o selo
  de cada anjo maior (`EncounterScreen.SEAL` 176) sobre uma luz da cor dele abaixo do limiar (`GLOW_*`); nada de figura.
  **Forja**: a Emeth de verdade na página esquerda (`EmethView`, `scripts/ui/emeth_view.gd`: `SubViewport` com mundo
  próprio, o modelo do `EmethSword` com o `set_temper` do posto, câmera ortográfica, balanço lento; `show_rank(r, grow)`
  faz o veio crescer ao forjar) com "Posto da Emeth" embaixo; à direita o índice dos postos, "Melhoria seguinte" ou
  "Forjado", Efeito, Estado, Próximo passo e, junto do Forjar, Custo e Saldo lado a lado (nó `deal`).
  Segundo lote (ciclo visual 2026-11-20, item 3; capturas `docs/gallery/ciclo_visual_1120/ui2_*`): **Compêndio** com o
  detalhe da entrada selecionada na página do índice (`CodexScreen.detail`): em Inimigos a própria figura assada
  (`FigureView`, `scripts/ui/figure_view.gd`: `SubViewport` com mundo próprio e um `CrowdRenderer` de uma figura, no
  `idle`, girando devagar; nunca derrotado, silhueta em tinta e "Derrote um para conhecer."), em Dons a marca do Dom
  grande (`TalentGlyph.mark`); as linhas dessas abas tomam o foco (direita do índice entra, esquerda volta, mouse
  seleciona; `CodexScreen.selected`). **Árvore**: equipado com um selo redondo esmeralda com visto no canto
  (`TalentNode._badge_tick`), selado com a moldura tracejada sem pontas e um lacre de cera (`_badge_seal`,
  `SEAL_WAX`), além da cor; no painel Custo e Pré-requisito lado a lado em negrito (nó `glance`). **Menus**: a
  `ActionBar` também nos Juramentos (`ActionBar.STEP`, a placa "← →" para o nível), nas Configurações (abas, Mudar,
  Confirmar, Voltar), nas Músicas, na tela de fim e na página das estações do hub (`HubPanel`), sempre no mesmo lugar;
  `ActionBar.press_focus(tela)` aperta o botão em foco (as frases `jur_hint_*` saíram). Fim de partida: primeiro o que
  fica (os materiais trazidos em 24 px, `EndScreen.BROUGHT_SIZE`, e a Maestria), depois as Bênçãos da descida e os
  números. **Molduras (UI-HB3)**: toda página de menu (`UiKit.page`), a pausa e o resumo da vitória ganham um remate no
  topo (arco com o losango) e cantoneiras de ouro velho com losango (`UiKit.crown`). **Selo do anjo (UI-HB4)**: na
  escolha de Bênção trazida por um anjo, o selo grande numa coluna à esquerda das cartas (`BoonChoice.ANGEL_FIGURE`
  220 a 720, cerca de 330 a 1080, luz da cor dele) com o nome e o glossário embaixo. **Selo de salvo (P2-4)**: todo
  `Save.write` que grava o save em uso emite `Save.written` e mostra por 1 s um selo pequeno com "Salvo" no canto de
  baixo à direita (`SaveSeal`, `scripts/ui/save_seal.gd`); nunca sem save; a escolha de save diz quando ele grava
  (`slots_saves_when`). Toda `UiKit.column` (páginas de menu, cartas, fim) centra acima da fileira da `ActionBar`
  (`ActionBar.RESERVE`); nas Configurações a dica fica no pé da página (`tip` dentro do quadro). Testes em `tests/test_bench_ui.gd`.
  Terceiro lote (capturas `docs/gallery/ciclo_visual_1120/ui3_*`, `_side_` lado a lado): o nome do golpe sai mais
  longe do medalhão e acima do fio da barra (`Hud.COMBO_INSET` 14, `COMBO_RISE` 9; encostava nele na horda). **P1-4,
  a fileira, é o padrão** (aprovada pelo art-director com os ajustes A a C de `ART_REVIEW.md` 3.1; `--hud=classic` volta
  aos losangos no meio de baixo para comparar): os cinco losangos menores (`Hud.ROW_DIAMOND` 36, 54 px a 1080;
  `ActionSlot.side`) numa fileira sobre as barras a partir do ombro do medalhão, a tecla pendurada sob a ponta
  (`ActionSlot.key_drop`, `ROW_KEY_DROP`), nada entre 30 e 70% da largura embaixo (a fileira acaba em 28%); uma faixa de
  tinta atrás dela (`HudVeil` sobre os losangos, `Hud._row_band`) e o véu dos losangos só pelo herói atrás
  (`_someone_behind(..., true)`): corpo do losango com luma p50 12 sobre a horda de 300; o contador e o nome do golpe na
  mesma linha, à direita do último losango à mostra (`Hud._follow_row`, `ROW_COUNT_GAP`; o robô não tem o da
  ultimate), o bloco todo com cerca de 197 px a 1080 (teto 200); selo da maldição e selo da Provação sobem a altura da
  fileira e das legendas (`Hud._row_lift`; só com eles à mostra o bloco passa dos 200); as Bênçãos que agem sozinhas no
  canto de baixo à direita, cada grupo com o próprio véu; divisas da borda acima da fileira (`Hud.edge_bottom()`,
  `ROW_EDGE_BOTTOM` 168). Capturas do aceite em `ui3_after_*` (Salão e Ponte A com a horda a 720 e 1080, ultimate
  trancada e pronta, maldição, Provação, herói na borda sul, `classic`).
- **Fatia 2 na interface** (`docs/design/rejogabilidade/sistemas.md` 5.3 "Fatia 2"; testes em `tests/test_ui_fatia2.gd`;
  capturas `docs/gallery/ciclo_visual_1120/ui4_*`): **Encanto** nas cartas (`EnchantChoice`, filha da `BoonChoice`:
  título, linha de baixo, dica "Até dois Encantos por descida", barra de ações, `GUARD_MS`; `open_enchants(opções)`,
  sinal `chosen_enchant`; aberta pelo `Game.open_enchant_choice` quando ninguém ouve `enchant_offered`):
  `BoonCard.setup_enchant` com a aba "Encanto", medalhão de tinta com a marca, nome, "Muda: <ação>" com o símbolo do HUD, a regra,
  o texto com os números em negrito (`BoonCard.strong_numbers`) e "Até o fim da descida"; borda e brilho esmeralda
  pálido (`ENCHANT_EDGE`, `ENCHANT_GLOW`), sem raridade nem nível. **Marcas** desenhadas (`DoorGlyph.Kind`): `ENCHANT` a
  lâmina inclinada com uma centelha de ouro velho de quatro pontas (`DoorGlyph.enchant`; nunca de pé com a guarda, que
  lê como cruz, nem com um aro, que lia como o sinal de Vênus), `PSALM` o arco ogival das cartas de Salmo com a luz
  lilás e um losango, `EMERALD` a pedra lapidada mais alta que larga no esmeralda da Emeth (a gema da Magia é redonda e
  azul); `of_reward` (ENCHANT, PSALM), `of_material` (EMERALD), na legenda do mapa e nas placas da loja. **Anjo na
  porta**: a linha do anjo sob a recompensa ganha o selo da casa e o nome na cor dele, ou dois selos e "Dois anjos"
  (`DoorSign.show_angel`, `angel_row`, chamada pelo `Rooms._sign_angel`; o texto do `door_text` não mudou e sai do
  detalhe, que fica com "Difícil"). **Forja** (`ForgeScreen`): o índice é uma grade de três colunas que cabe em 720
  (Temperar I a III, Refinar Ataque e Especial com três escolhas cada; `Book.index_entry` com altura, fonte e margens
  compactas), cada entrada com a marca do estado (`ForgeScreen.Mark`: lingote e preço esperando, losango de ouro velho
  forjado, losango esmeralda na lâmina, losango apagado sem a ferramenta), sobre o Refinar "Ferramenta: Encontrada" ou
  "Ainda perdida nas catacumbas"; o botão diz o que faz: Forjar (a primeira de uma ação entra na lâmina), Usar (troca
  a da ação, sem custo, `Forge.put_on`) ou Em uso; sem a ferramenta, Estado "Falta a ferramenta" e o `forge_no_tool`.
  **Esmeralda**: na Bolsa (`MaterialCount.purse`, `shown`) depois da primeira, no cartão do save, em Trazidos (todo
  `MaterialPurse.IDS`) e na saudação de material; a ferramenta achada também em Trazidos. Capturas: `tools/ui_lab.gd --
  --enchant`, `--doors=boon,meeting,enchant,psalm`, `--shop --route --want-enchant`, `--cursed`; Forja com
  `--tools=tool_refine --refined=refine_fio,refine_peso` (só na sessão, `Save._dev_materials`).
  Medalhões do mundo (`RewardGem`): Encanto (`Mark.ENCHANT`, a lâmina inclinada com a centelha, esmalte verde
  `ENAMEL_ENCHANT` matiz 148) e Salmo (`Mark.PSALM`, o arco ogival com o losango, lilás `ENAMEL_PSALM` matiz 255, longe
  da Provação), desenhados no `reward_gem.gdshader`; `tools/gem_lab.gd --rewards=10,11,1`. Cores das famílias: toda tela
  lê `Boon.color()` (`FAMILY_COLOR`, Vigília em sálvia) e o selo do anjo o `AngelSeal.TINT`, nada copiado.
- **Mapa da descida** (DV-1, MAP-03, lê o grafo do MAP-01): ação `map` em `Controls` (M, Back
  no controle; remapeável no teclado nas Configurações, linha "Mapa" no Como Jogar), botão discreto "Mapa [M]" ao lado do
  "Sala N de 11" no HUD (`Hud.map_button`: nunca toma o foco, abre no aperto para o clique, que também é o ataque, não
  golpear; tecla real) e "Mapa" na pausa logo abaixo de Continuar (M também abre de lá). `Hud.open_map` abre por
  `Game.open_screen` (a partida para) e fecha por `Game.close_screen` (`Controls.clear_presses`); a tecla é lida no
  `Hud._unhandled_input`, como a pausa lê a dela. Página do Livro (`MapScreen`, `scripts/ui/map_screen.gd`, `BookSpread`
  com `SPINE` 0,37): à direita o desenho (`MapGraph`: entrada no topo, Morvath embaixo, número da sala na margem,
  medalhão de tinta com a marca do `DoorGlyph` de cada nó, divisas de difícil e guardião ao lado, nome curto do guardião
  "Cavaleiro"/"Ancião" (`map_guardian_<id>`), caminho feito em rubrica, sala atual com aro duplo petróleo, portas abertas
  com aro e ligação de ouro, o que ainda alcança em tinta, ramos deixados apagados a 0,3); à esquerda a sala em foco
  (nome, "Sala N de 11", recompensa, difícil, arena, estado) e a legenda. Foco começa na primeira porta; setas, direcional
  e o ponteiro andam pelos nós (`DescentMap.step`); M, Back, Esc, Start ou Voltar fecham. `DoorGlyph.Kind.UNKNOWN` é o
  "?" do nó escondido (Q-25 a). Dados por `DescentMap` (`scripts/ui/descent_map.gd`, puro): `from_dict` lê
  o `RunMap.view()` (`{layers: [[{id, depth, slot, kind, reward, guardian, hidden, arena, next}]], path, here, doors}`;
  aceita também `current` e `hard`); `from_game` lê o `Rooms.map` da partida e marca "difícil" nas portas abertas pelo
  `Rooms.door_info`. Grafo fixo de teste `MapSample`
  (`--title --screen=map --map-at=start|middle|doors`, `tools/ui_lab.gd -- --map [--map-at=...]`). Testes em
  `tests/test_map_screen.gd` e `tests/test_input_leak.gd`; fluxo por teclado, controle e mouse em
  `tools/map_flow_check.gd`; capturas em `docs/gallery/dv1/ui/` (mapa no começo, no meio e diante das portas a 720 e 1080, sobre a partida, a linha de hoje numa partida real, HUD com o botão, horda de 300, Controles).
- **Tela de fim com Maestria** (E2-04, `MasteryReport`): "+N XP" ao lado da barra que enche do XP de antes ao de depois,
  de onde veio (só as fontes que deram algo), "Nível N alcançado" e "Dons revelados: ..." (o nível revela, a Memória abre) e "Nova ultimate: ..."; dados do
  `Game.mastery_report` (o `mastery_gain` e o XP antes, guardados no `log_run`, passados no `stats.mastery`).
- **Bênção no texto** (QW-018, D-50): o texto do jogador chama as cartas de Bênção (raridades no feminino: Comum, Rara,
  Épica, Heroica); "Dom" só nos Dons do herói (`talent_*`, `hero_*`, `codex_*`, `end_unlocked*`; teste em
  `test_hero_screen.gd`). Chaves, classes (`Boon`) e registro não mudaram.
- **C17, texto e HUD** (testes em `tests/test_c17_ui.gd`; capturas em `docs/gallery/c17/ui/`): o especial se chama
  **Onda de Luz** em todo lugar (QW-109, D-69; `move_bolt` também diz "Onda de Luz" até o `make_data.gd` trocar o título
  do nó para `move_wave`; o teste falha com "seta" em qualquer texto do jogador). **Um vocabulário só** para as ações
  (QW-110, Q-16): Ataque, Especial, Círculo, Esquiva, Ultimate nos Controles (`action_*` = `slot_*`), no Como Jogar, nas
  cartas ("O ataque incendeia", "O especial congela") e no Compêndio > Golpes, que mostra as entradas com os símbolos do
  HUD (`CodexScreen.move_marks`, `ActionSlot.mark`, "segurado" no Ômega), nunca E/D nem Leve/Pesado; "Avanço" só no Dom
  Avanço Feroz; "Descer de novo" e "Voltar ao menu" nos dois finais (`end_again`, `end_menu`). Maiúsculas (QW-118):
  nomes de Bênção, provação e maldição em Title Case, "Bênção" e "Magia" sempre maiúsculas. Números (BUG-113): vida,
  Magia, ouro e dano inteiros como no HUD (`BoonMod.WHOLE`, `UiKit.whole`; segundos ficam com uma casa). Como Jogar
  (BUG-106) com a ultimate de hoje (carga pela Magia e pelo dano causado e sofrido) e um quarto passo, "Provação e
  Altar" (`HowToScreen.STEPS`, selo pintado da Provação), também na Abertura do Livro. HUD: a fileira das Bênçãos que
  agem sozinhas para em 96% da largura e o último lugar diz "+N" (BUG-105, `Hud.PASSIVE_EDGE`, `passive_fit`,
  `passives_shown`: as com recarga primeiro); com tela aberta (escolha, pausa, evento) a fileira some e as saudações
  esperam paradas (`EloBanner.held`, BUG-107) e, na luta, saem sobre um véu escuro em elipse (`EloBanner.VEIL_*`); as
  divisas de fora da tela giram pelo meio e ficam acima da legenda da ultimate (`EDGE_INSET` 128, BUG-111); o nome do
  golpe some junto com o contador (`on_combo(0)`, BUG-112) e as transições do HUD correm em tempo real (`Fx.real_dt`);
  legenda da ultimate e tecla dos losangos em 14 px (`ActionSlot.CAPTION_FONT`, `KEY_FONT`). Compêndio e Livro inteiros
  a 720 (QW-114): nada de reticências, a lista do Compêndio rola (`CodexScreen._scroll`: roda do mouse, ou direita a
  partir do índice e cima e baixo; esquerda volta ao índice), corpo mínimo 14 px (as habilidades do Livro em 15 px na
  tinta). LB e RB (PageUp e PageDown) trocam abas e capítulos nas Configurações, no Como Jogar, no Livro e no Compêndio
  (`Controls.MENU_KEYS`, ações `tab_prev`/`tab_next`, `UiKit.step_tabs`; DT-103 em parte, o `title_flow_check` testa com
  eventos reais do controle). Juramentos e Músicas no painel das Configurações (`UiKit.page`, QW-113).

## Rejogabilidade, Fatia 3, interface (ui-ux-designer; testes em `tests/test_fatia3_ui.gd`, capturas em `docs/gallery/fatia3_ui/`, `tools/fatia3_lab.gd`)
- **Forja**: terceiro marcador "Despertar" (`ForgeScreen.Tab.ARTS`, `arts_open()`: aparece com qualquer ferramenta do
  Forjador achada; ordem dos marcadores em `_tab_order`, LB e RB andam nela) com duas colunas, Despertar (Esmeralda) e
  Inscrever (Prata), cada uma com o estado da ferramenta; a marca do preço é a do material do posto (`Mark.paid_in`,
  `MaterialCount.set_id`). Despertar: forjado e dormindo diz "Despertar" (`put_on`, grátis), desperto "Adormecer"
  (`take_off`); Inscrever: "Inscrever" e depois "Inscrito"; sem a ferramenta, o `forge_no_<ferramenta>`.
- **Sortear de novo** na escolha de Bênçãos (Discernimento I): com `Game.can_reroll()` a `BoonChoice` põe
  "Sortear de novo (N)" na `ActionBar` (`reroll_item`, `reroll()` chama `Game.reroll_choice`); ação de menu
  `menu_reroll` em `Controls.MENU_KEYS` (Y no controle, R no teclado, só nos menus).
- **Discernimento** no capítulo Ofícios do Livro: um botão por grau (`HeroScreen.discern_buttons`), dois apertos como
  abrir um Dom ("Confirmar: N de Memória"), `Discern.buy` e grava; o II diz que pede o I.
- **Banca do Vendedor** (`VendorScreen`, `scripts/ui/vendor_screen.gd`): aberta pelo Vendedor depois da encomenda
  entregue (`Hub._use_vendor`); à esquerda as Obras (custo com marcas, o que falta em rubrica, Erguer, "Erguida"), à
  direita as trocas (Dá, seta, Recebe, Trocar) e o Saldo; sinais `built`, `traded`.
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
  `DoorGlyph.of_reward` para `RunMap.Reward.SILVER`/`MEMORY` (placas das portas e mapa) e `DoorGlyph.of_material(id)`;
  `DoorGlyph.material(ci, kind, centro, altura)` desenha a marca em qualquer canvas. `MaterialCount`
  (`scripts/ui/material_count.gd`): marca e número no `UiKit.number_font` (nunca Cinzel), `named` acrescenta "Prata",
  `plus` escreve "+3"; `MaterialCount.purse(data)` é a Bolsa (Prata e Memória lado a lado) e `refresh(row, data)`. A
  legenda do mapa (`MapScreen.legend_kinds`) só mostra os tipos que a descida tem (Prata e Memória entram quando há).
- **Forja da Emeth** (`ForgeScreen`, `scripts/ui/forge_screen.gd`, aberta pelo Forjador em `Hub._open_forge` pelo `ScreenHost`):
  `BookSpread` de duas páginas. Esquerda: título, uma linha do que a Forja faz, "Temperar" com uma entrada por posto
  (`Book.index_entry`, marca de Prata e o custo, "Forjado" quando já tem) e a Bolsa no pé. Direita: o posto em foco com
  Efeito, Custo (`MaterialCount` com o nome), Estado e Próximo passo (pelo `Forge.problem`: pronto, falta Prata com quanto,
  pede o anterior, forjado), Forjar (ação principal, só habilitado e focável quando pode) e Voltar. Mover o foco só mostra;
  Enter numa entrada leva ao Forjar; comprar gasta (`Forge.buy`), grava (`Save.write`, só nos dados do jogo), emite
  `forged` e passa ao próximo posto. `forge_done` sem "nesta versão".
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
  (`Controls.rebind_pad`, `PAD_REMAPPABLE`: ataque, especial, esquiva, círculo, ultimate, mapa, usar; troca com quem tinha
  o botão; o andar fica no analógico), gravado em `bindings` como `pad:<ação>` (`pad_button_for`), Start cancela, Teclas
  padrão volta tudo. O botão aparece numa plaqueta (`StationSign.KeyCap`, redonda nos botões de face) e uma linha embaixo
  diz que botão também liga (`options_pad_note`). Como Jogar com as teclas e botões em plaquetas (`HowToScreen.Plates`,
  `key_parts`, `pad_parts`; P2-3). `tools/title_flow_check.gd` faz uma volta só de controle (Como Jogar, Configurações,
  remapear o Ataque para Y, Teclas padrão) e uma só de clique (Como Jogar, Configurações, Estilo visual ida e volta).
- **Mapa (MAP-07, MAP-08)**: com o foco numa sala atrás de uma porta aberta, a porta acende na sala com o facho das
  recompensas na cor da recompensa (`MapScreen._light_door`, `RewardShaft` "MapDoorLight" sobre o `arena.door_label(i)`;
  outra sala apaga, `lit_door()`); ao fechar ela fica acesa `DOOR_LINGER` 4 s e o HUD aponta a porta na borda da tela
  quando ela está fora (`Hud.point_door(onde, nome, s)`, divisa com o nome, some nos últimos `DOOR_FADE` 0,6 s,
  `clear_door`). A página vira ao abrir (0,22 s em volta da lombada) e ao fechar (0,16 s, numa camada que não toma entrada;
  o `closed` sai na hora) e, a primeira vez que o mapa abre numa sala, o trecho novo do caminho se desenha a tinta
  (`MapGraph.ink`, `draw_in`); sem animação sem tela (`MapScreen.turns`). `tools/map_flow_check.gd` confere a luz.
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
- **Mapa**: `DescentMap.Room.find` e `vein` (lidos do `view()`); o nó com `find` ganha um losango de ouro velho de 6 px no
  alto à direita do medalhão (`MapGraph.find_diamond`, `FIND`) e a legenda "Achado" só quando há; a página da sala diz
  "Guarda um achado: Cabeça da Picareta" e "Um veio de Pedra Funda" (`DescentMap.find_name`); depois de achada, o
  `from_game` tira o losango. `MapSample` tem o achado no nó 14 e o veio no 12.
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

