> Índice: [ui.md](../ui.md)

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
  `HeroScreen.bar`), no Compêndio, na Forja, na escolha de save e na pausa; as frases de teclas saíram
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
  azul); `of_reward` (ENCHANT, PSALM), `of_material` (EMERALD) e nas placas da loja. **Anjo na
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
- **Mapa da descida**: removido no DM-1 (2026-11-22): tela, botão, ação `map`, textos e testes. Ver `rooms.md`.
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
