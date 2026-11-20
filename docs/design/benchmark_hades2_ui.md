# Benchmark de interface: Hades II contra A Selagem (2026-11-19)

Autor: ui-ux-designer. Fontes: as capturas do Daniel em `docs/art/ref/hades2_bench_2026-11-19/01.jpeg` a `08.jpeg`
(só locais, fora do repositório) e duas da luta com a primeira chefe em `.../Hades 2/Boss 1` (quadros de vídeo do
YouTube, 1510 x 877 com a moldura do player). Nossa interface: o código atual (`scripts/ui/`, `Rooms.prompt`) e as
capturas da revisão de leiaute (`docs/gallery/ui_review_d2ff05d/`, `docs/gallery/rj1/ui/`).

Regra de sempre: do Hades II copiamos **mecânica e leitura** (onde a informação fica, quanto ela pesa, como se pede uma
tecla), nunca arte, nome, ícone, moldura ou texto. As medidas abaixo são estimativas tiradas das capturas (em pixels do
quadro e em fração da tela); servem de régua, não de molde.

## 1. O que cada captura mostra

| # | Tela | O que eles fazem | Medida aproximada |
|---|---|---|---|
| 01 | Escolha do espaço de dados | Uma linha de instrução no topo ("o progresso é salvo sempre que o ícone aparece"); 4 cartões iguais lado a lado; no cheio, pares rótulo (versalete lilás, pequeno) e valor (branco, negrito): região, noites, domínio com o ícone, atualizado com data e hora; o vazio só diz "(Espaço vazio)"; a lixeira fica embaixo do cartão cheio, fora dele; voltar é um botão redondo no rodapé ao centro. | Cartão 350 x 560 de 1900 x 1060 (18% x 53%); rótulo cerca de 22 px, valor 26 px; a moldura ornamentada ocupa 90% da tela. |
| 02 | Diálogo | Retrato grande à esquerda saindo do quadro; placa do nome com o título embaixo em outra cor; caixa de texto escura embaixo à direita; o mundo continua visível e escurecido. | Caixa 960 x 300 (50% x 28%); texto 28 px; o retrato ocupa a altura toda. |
| 03 | Encantos (lista com detalhe) | Faixa de título verde no alto à esquerda; lista de linhas com ícone e nome, o item em foco aceso, os feitos com um visto à direita; o detalhe numa folha clara embaixo com termos destacados em cor e uma frase em itálico; o custo num cartão à parte ("Ossos 10", com o que se tem embaixo); à direita, painéis de glossário dos termos citados; rodapé direito com as ações e a tecla real ("[ícone] ENCANTAR", "[Esc] SAIR"). | Lista 800 px (42%); glossário 440 px (23%); rodapé 30 px. |
| 04 | Loja | Linhas com ícone, quantidade que se leva, quanto se tem, preço; preço em **vermelho** quando não dá para pagar, sem frase; a bolsa numa placa pendurada no alto à direita; Sair com a tecla no canto inferior direito. | Linha 860 x 100; preço 30 px. |
| 05, 06 | Inventário em grade | Abas por ícone; grade 8 x 5 de casas iguais com a contagem embaixo; à direita, um pergaminho com nome, descrição, de onde vem em tópicos ("Recompensa comum por vencer confrontos no Érebo"), "???" para o não descoberto e a frase de sabor em itálico no fim; rodapé com Anterior, Seguinte, Sair e as teclas. | Grade 62% da largura; detalhe 33%. |
| 07 | Escolha de bênção | Retrato do deus à esquerda (fora do conteúdo); título espaçado no alto com uma linha de caráter em itálico; **três linhas largas** (não cartas): ícone à esquerda, nome na cor da raridade, raridade escrita à direita, descrição com **termos em negrito** e uma linha de número ("Dano: **15** (a cada 0,85 s)") com o valor em verde; glossário dos termos à direita da carta em foco; rodapé com "B VER BÊNÇÃOS" à esquerda e "ESCOLHER" à direita. | Linha 1100 x 210 (58% x 20%); nome 34 px; corpo 24 px. |
| 08 | Hub, fala curta | Legenda centrada embaixo numa faixa escura do tamanho do texto, sem moldura. | 290 x 40 px. |
| B1, B2 | Luta com a chefe | Vida e Magia em duas barras finas empilhadas no canto inferior esquerdo, número dentro; as bênçãos em uma **coluna de ícones na borda esquerda** (uma por ação, nesta ordem); moedas no canto superior esquerdo em ícone e número; barra da chefe no alto ao centro com o nome em letra de título; **nada no meio de baixo**, nenhum contador de golpes. | Barras 465 x 67 de 1510 (31% x 8%); coluna 70 x 360 (5% x 41%); barra da chefe 36% da largura. Fora a chefe, cerca de 4 a 5% da tela fica coberta. |

## 2. Princípios de leitura que valem copiar

1. **Pouco permanente, nada no meio.** Na luta só os cantos e a borda esquerda têm interface; o centro de baixo, onde
   o herói anda, fica livre.
2. **Uma linha de ações no rodapé de toda tela**, sempre no mesmo lugar: confirmar à direita, voltar à direita dele,
   ações extras à esquerda, cada uma com a tecla ou o botão real ao lado da palavra.
3. **Rótulo pequeno e apagado, valor grande e claro**, em pares (cartões de save, glossário, custo).
4. **Números em destaque dentro do texto** (cor própria) e termos de regra em negrito com glossário ao lado.
5. **Estado pela cor do número, não por frase**: preço vermelho quando falta, visto quando feito, "???" quando não
   descoberto.
6. **Listas quando há muita informação** (bênçãos, loja, encantos), cartas só quando a escolha é entre poucos objetos
   grandes.
7. **O detalhe do item em foco num painel fixo** (direita ou embaixo), nunca em balão que segue o cursor.

## 3. O nosso hoje, tela por tela

| Tela | Nosso (código atual) | Diferença de leitura |
|---|---|---|
| HUD da luta (`Hud`) | Medalhão e barras no canto inferior esquerdo (cerca de 470 x 120 a 1080, 2,7%); **quatro a cinco losangos de ação no meio de baixo** (415 x 100, 2,0%); sala e "Mapa [M]" no alto à esquerda; relógio no alto ao centro; ouro no alto à direita; **contador "Golpes" e nome do golpe à direita, no meio da altura** (210 x 135, 1,4%, sobre o chão de luta); Bênçãos passivas em fileira ao lado das barras. Soma cerca de 7% da tela a 1920 x 1080, contra 4 a 5% deles. | O centro de baixo e a borda direita têm interface onde inimigos e avisos andam; o contador de golpes é informação que não muda decisão. |
| Tecla de usar (`Rooms.prompt`, novo) | `StationSign` sem nome sobre o herói: plaqueta da tecla real e o verbo ("Pegar", "Comprar", "Entrar"), só enquanto ele está no ponto de uso. | Boa ideia (tecla real e verbo). Diferença: sobre a cabeça ele disputa lugar com os números de dano (que fogem 60 px dela, `NumberTally.clear_of`) e cobre o herói; o Hades põe a dica junto do objeto. |
| Placas das portas e da loja (`DoorSign`) | Nome em ouro claro, preço em marfim, palavra do grupo em cima ("Cura e reforço"), "150 ouro, faltam 40" em rosa; marca da recompensa ao lado; três linhas por item na loja. | Na loja de 5 itens a 720 linhas são 15 linhas de texto no mundo; o "faltam N" é frase onde eles usam só a cor. |
| Escolha de anjo (`AngelChoice`) e de Bênção (`BoonChoice`, `BoonCard` 320 x 450) | Duas cartas de anjo; depois três cartas altas: medalhão, nome, família, ação, "Novo", raridade, descrição; dica em uma linha de texto no rodapé ao centro ("Esc: voltar aos anjos"). | Os números da Bênção ficam no meio do texto, sem destaque; sem glossário dos termos (congelar, Ômega, Magia); a dica de teclas é frase, não ação com a tecla. As cartas são altas e meio vazias (metade de baixo sem texto). |
| Livro (`HeroScreen`, `CodexScreen`) | Livro aberto com capítulos em marcadores, árvore de Dons, painel Efeito, Custo, Pré-requisito, Estado, Próximo passo; Compêndio com índice à esquerda e lista à direita. | Já segue "detalhe fixo ao lado". Falta o "de onde vem" em tópicos e o sabor em itálico no fim de cada entrada; o rodapé de teclas varia de tela para tela. |
| Menus (`PauseMenu`, `OptionsScreen`, `HowToScreen`) | Página de tinta com fio de ouro velho (`UiKit.page`), Continuar em destaque; abas com LB/RB. | Linguagem coerente. Falta a linha de ações com teclas reais no rodapé (só algumas telas têm dica). |
| Mapa (`MapScreen`) | Página do Livro com o grafo, legenda e "M fecha o mapa". | O Hades não tem mapa; nada a copiar. A legenda ocupa metade da página esquerda. |
| Escolha de save (`SaveSlotScreen`, novo, este ciclo) | Três cartões com o medalhão do Guerreiro, Maestria, descidas, vitórias, Bolsa (Prata e Memória), Última partida; vazio diz "Espaço vazio"; Apagar fora do cartão, com pergunta. | Feito no molde da leitura do 01 (pares rótulo e valor, lixeira fora do cartão), na nossa língua visual. |

## 4. Propostas

Cada proposta diz o que muda, o porquê e como medir o aceite. Dono: ui-ux-designer, salvo onde dito.

### P0 (antes do próximo teste do Daniel)

- **P0-1 Tecla de usar junto do objeto, não sobre a cabeça.** A plaqueta do `Rooms.prompt` vai para o pé do objeto
  usado (placa da porta, relicário, item da loja: embaixo da placa que já existe) ou, sem objeto, abaixo dos pés do
  herói. Aceite: em captura a 1280 x 720 e 1920 x 1080 com o herói diante da recompensa, de um item da loja e de uma
  porta, nenhum pixel da plaqueta dentro da caixa do herói na tela (`Hud.BODY_HALF` x `BODY_HEIGHT`) nem a menos de
  60 px (a 720) da cabeça; a plaqueta a até 80 px (a 720) do objeto.
- **P0-2 Linha de ações no rodapé de toda tela que pausa.** Um componente só (`UiKit.action_bar` ou parecido): à
  direita a ação principal ("Escolher", "Comprar", "Voltar") com a plaqueta da tecla real (`ActionSlot.key_plate`),
  à esquerda as extras ("Ver Bênçãos", "Mapa"); troca ao vivo entre teclado e controle (`Controls.device_changed`).
  Substitui as dicas em frase da escolha de Bênção, dos anjos, do Livro, do mapa e da escolha de save. Aceite: teste
  GUT que abre cada tela e acha a barra com a tecla igual a `UiKit.action_label` da ação; a barra a menos de 48 px (a
  720) da borda de baixo nas duas resoluções.
- **P0-3 Nada de interface no meio da altura à direita.** O contador "Golpes" e o nome do golpe saem da borda direita
  (ou somem: não muda decisão, o Hades não tem). Aceite: em `--stress=300` a 1920 x 1080, nenhuma interface entre 15%
  e 80% da altura fora da faixa de 6% de cada borda lateral (medido com `tools/frame_stats.py --box` contra um quadro
  com `--no-hud`, se existir, ou pela árvore de controles visíveis).

### P1 (próximo ciclo de interface)

- **P1-1 Números destacados nas Bênçãos.** Na descrição de toda carta (Bênção, Salmo, Elo, troca), o valor que muda
  com raridade e nível numa cor própria (verde claro de "melhor" e o antes e depois na troca), os termos de regra em
  negrito. Aceite: teste que monta as cartas de todas as Bênçãos e confere que cada número da descrição sai num trecho
  com a cor de número; nenhuma carta com texto cortado a 720.
- **P1-2 Glossário ao lado da carta em foco.** Até dois termos (congelar, queimar, Ômega, Magia, armadura) explicados
  num painel à direita da carta em foco, em pares termo e explicação, sem cobrir as outras cartas. Aceite: os termos
  vêm de uma tabela de dados (texto no `text_pt.tres`), nenhuma sobreposição de retângulos entre o painel e as cartas
  nas duas resoluções.
- **P1-3 Loja com duas linhas e preço pela cor.** Placa do item: nome e preço; o grupo sai (a marca já diz) e o "faltam
  N" vira o preço em rosa apagado (o número do que falta só quando o herói está diante do item, junto da tecla). Aceite:
  loja de 5 itens a 1280 x 720 com no máximo 10 linhas de texto no mundo e 45 px ou mais entre placas.
- **P1-4 Ações da luta fora do meio de baixo.** Estudar levar os losangos das ações para junto das barras (canto
  inferior esquerdo, em linha) ou para uma coluna na borda esquerda como o Hades faz com as bênçãos, deixando o meio
  de baixo livre. Aceite: área permanente da interface na luta abaixo de 5,5% da tela a 1920 x 1080 (hoje cerca de
  7%), nenhum controle entre 30% e 70% da largura na faixa de baixo; o art-director aprova antes.
- **P1-5 Cartas mais baixas ou em linhas.** As cartas de Bênção têm metade de baixo vazia: ou a altura acompanha o
  texto (mínimo do medalhão mais 4 linhas), ou as três viram linhas largas com o medalhão à esquerda. Aceite: nenhuma
  carta com mais de 25% da altura sem conteúdo; a 720 as três cabem sem rolar.

### P2 (quando houver tempo)

- **P2-1 "De onde vem" e sabor no Compêndio e nos materiais.** Cada entrada com tópicos curtos de onde se acha e
  "???" para o que falta descobrir, e uma frase de sabor em itálico no fim (texto do Daniel; não inventar lore).
  Aceite: Prata, Memória e Esmeralda com pelo menos um tópico de origem ligado aos dados (`StageDef` grupo Materials).
- **P2-2 Fala dos NPCs do hub.** Quando o Vendedor e o Forjador falarem: retrato à esquerda, placa com nome e papel,
  caixa de texto embaixo à direita sobre o hub escurecido; fala curta como legenda centrada embaixo. Aceite: a caixa
  dentro de 55% da largura e 30% da altura; o herói continua visível.
- **P2-3 Legenda do mapa recolhível.** A legenda ocupa metade da página esquerda: mostrar só os sinais presentes no
  mapa da descida. Aceite: legenda com no máximo as linhas dos tipos de sala que aparecem no grafo.
- **P2-4 Ícone de "salvo".** Como no 01, dizer na escolha de save quando o jogo grava (fim de cada descida, troca de Dom,
  compra na Forja) e mostrar um selo pequeno no canto quando grava. Aceite: o selo aparece por 1 s em todo `Save.write`
  com save ligado, nunca com `--nosave`.

## 5. Já feito neste ciclo

- **Escolha de save** (pedido do Daniel): ver `CLAUDE.md`, seção "Escolha de save". Leitura do 01 aplicada: pares
  rótulo e valor, vazio claro, apagar fora do cartão e com pergunta, voltar só quando há para onde.
