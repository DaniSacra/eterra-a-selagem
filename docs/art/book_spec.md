# Livro de Ahk: o códice que se lê (especificação, art-director, 2026-11-23)

Para o `ui-ux-designer` (tela `HeroScreen`) com o `technical-artist` (virada de página). Identidade em
`meta_identities.md` 2: retângulo duplo (livro aberto), pergaminho e couro, tinta ferro-gálica, cor pergaminho d8c8a8 e
sépia, gesto **virar a página**, som de papel e pena. **Lê-se; não se compra nada nele.** Os Dons saíram (medalhão,
`dons_medallion_spec.md`); ficam três capítulos: **Abertura**, **O Guerreiro** (o herói escolhido) e **Ofícios**.
Alvo de leitura: **em 3 segundos** o jogador sabe em que capítulo está, o que a página conta e para onde ir.
Lore: só o cânone (`../dungeon-rpg/docs/mundo/canone.md`): Ahk, o Escriba, anotava os ensinamentos de Elun em papiros;
o testemunho dele é a Abertura. Nada de rosto, roupa ou cena de Ahk (o cânone não descreve).

## 0. O que muda em relação ao `HeroScreen` de hoje

- **Virar a página** vira o gesto: os capítulos trocam com uma virada de folha de verdade (seção 5), não com troca de
  aba. Os marcadores viram **fitas** de seda saindo do alto do livro (uma por capítulo).
- **Sem compra no livro.** O Discernimento (hoje no capítulo Ofícios, comprado com Memória) sai do livro (seção 6).
- **Sem Devoção no cabeçalho** (ela é do medalhão). Fica a Maestria (é leitura: nível e o que o próximo nível revela).
- **A página do herói segue o herói escolhido** (`SaveData.picked_hero`): Guerreiro ou Maga, retrato, arma, jeito e
  habilidades dele. Hoje as três páginas são sempre do Guerreiro (pendência registrada em `docs/reference/ui.md`).
- A página do herói ganha a **lista dos Dons equipados** (só leitura) e o botão "Ver os Dons" (abre o `DonsScreen`, como
  o botão de hoje).
- Velas e lacre ficam como **decoração** fora do livro (seção 1), sem função.
- Fica: `BookSpread`, `Book` (tintas, `section`, `text`, `button`), `book_page.gdshader`, `MasteryBar`, `ActionSlot`,
  `PickMark`, o fluxo de descer (`descend`), a abertura do Compêndio, `HeroScreen.Chapter` (OPENING, HERO, OFICIOS).

## 1. Composição (1280 x 720; a 1920 x 1080 x1,5)

| Peça | 1280 x 720 | Observação |
|---|---|---|
| Fundo | tela inteira | mesa de madeira escura 1a120c com vinheta 0,6 e luz quente vinda de cima à esquerda |
| Livro aberto | x 40..1240, y 62..700 (1200 x 638) | capa de couro `Book.LEATHER` 3 px para fora do miolo; lombada em x 640 (as duas páginas **iguais**, 560 x 600 cada; hoje a esquerda é 0,55) |
| Página esquerda | x 70..626, y 80..684 | margem interna 36 px |
| Página direita | x 654..1210, y 80..684 | margem interna 36 px |
| Fitas (3) | saem de cima do livro em x 520, 600, 680; 44 px de largura | caídas 70 px acima do miolo (y 10..80); a do capítulo aberto **desce sobre a página** até y 150 |
| Velas (decoração) | duas, em (24, 560) e (1256, 560), 30 x 120 | cera marfim, chama com tremor (shader pequeno); só aparecem a 16:9 ou mais largo |
| Folio (número da página) | pé de cada página, centro, Cinzel 14 `Book.FADED` | "i", "ii" na Abertura; "1", "2" no herói; "3", "4" nos Ofícios |
| Canto dobrado (orelha) | 40 x 40 nos cantos de baixo de fora das duas páginas | clicar vira a página para aquele lado |

Fitas: Abertura em couro sépia 6a4a2e, herói na tinta dele (Guerreiro petróleo `Book.RIBBON` 0f4545; Maga âmbar 6a3a14),
Ofícios ocre 8a6a2a. Na ponta de cada fita, a marca do capítulo em ouro velho 20 px (pena, o leão ou a estrela de 8 pontas,
o martelo). Fita em foco sobe 6 px; a aberta fica caída sobre a página com o nome do capítulo em Cinzel 13 marfim na
vertical.

Cabeçalho (alto das duas páginas, y 92..150): esquerda o **nome do capítulo** em Cinzel 30 `Book.INK` com capitular em
rubrica; direita a **Maestria** (`MasteryBar` 250 px, "Maestria N" e "O nível N revela: X" em Alegreya Sans Italic 15
`Book.RUBRIC`). Sem Devoção, sem bolsa.

## 2. Os três capítulos (conteúdo por página)

### 2.1 Abertura (fita sépia)
- **Esquerda**: vinheta da mesa do escriba (papiros, pena, tinteiro, lamparina, em sépia, 420 x 240, centro x 348, y 280),
  embaixo as palavras de Ahk do cânone (`book_epigraph` e `book_epigraph_by` de hoje) em Alegreya Sans Italic 17, máximo 9 linhas.
- **Direita**: "A descida em três passos" com os mesmos sinais e palavras do Como Jogar (`HowToScreen.STEPS`), e no pé o
  botão **Descer às catacumbas** (`Book.primary`, o único botão de destaque do livro).

### 2.2 O herói (fita na tinta do herói)
- **Esquerda**: o retrato do herói escolhido em tinta e aquarela (Guerreiro `assets/ui/hero/warrior_page.png`; Maga o
  recorte `hero_maga_img.png` com máscara de papel), 440 x 540, centro (348, 400); nome ("O Guerreiro", "A Maga") em
  Cinzel 26 sob o cabeçalho.
- **Direita**, de cima para baixo: Arma (nome Cinzel 20, uma frase), Jeito de lutar (uma frase), **Habilidades** (a grade
  de hoje: as quatro ações, a ultimate e a passiva, marca 26 px e uma linha cada), um filete, **Dons equipados** (até 6
  linhas: glifo `TalentGlyph` 20 px na tinta do ramo e o nome em Alegreya Sans 16; nenhum: "Nenhum Dom equipado." em
  `FADED`), e no pé dois botões de papel: **Ver os Dons** e **Compêndio**.

### 2.3 Ofícios (fita ocre)
- **Esquerda**: **Recursos** (Pedra Funda "N de 10" e onde achar, ou "???" com a pista) e **Ferramentas** (a Picareta,
  `PickMark` 120 px, no estado dela), como hoje.
- **Direita**: **Pedidos** (Forjador, Vendedor: o que pedem e quanto falta, em tinta e rubrica) e **Obras** (as erguidas e a
  prévia, voz neutra), como hoje.
- Antes do primeiro veio: a página diz "Ainda não há nada anotado." e uma linha de onde começar (texto que já existe).

## 3. Leitura: o que cada página tem de dizer em 3 segundos

- O **nome do capítulo** e a **fita caída** dizem onde se está; o folio confirma.
- Uma página nunca tem mais de **três seções** (cabeça em `Book.section`, filete fino) e nenhum texto rola.
- Corpo em Alegreya Sans 16 a 17 na tinta `Book.INK` sobre o papel; nada abaixo de 14 px a 720; rubrica só para "falta",
  "revela" e capitulares.
- Botões só para **ir a algum lugar** (Descer, Ver os Dons, Compêndio); nenhum gasta nada.

## 4. Entrada

- **LB/RB, PageUp/PageDown, rodinha do mouse** (fora de lista com rolagem): viram a página para o capítulo anterior ou
  seguinte, em laço (Ofícios para Abertura).
- **Clique na orelha** de baixo da página: vira para aquele lado. **Clique numa fita**: vira até o capítulo dela (uma
  virada por capítulo de distância, 0,25 s cada).
- **Direcional e setas**: andam pelos botões da página (↑/↓) e, na borda de fora da página da direita, → vira a página;
  na borda de fora da esquerda, ← vira para trás.
- **A / Enter / clique**: aperta o botão em foco. **B / Esc**: fecha o livro (`ScreenHost`; no Santuário volta ao jogo).
- Abre no capítulo do herói (como hoje, `start`), foco em "Ver os Dons"; pela tela de título "Livro" abre na Abertura.

## 5. Virar a página (gesto e animação)

- Uma virada: a folha da direita levanta pela lombada e cai sobre a esquerda (para a frente) ou o contrário (para trás),
  **0,35 s**, com curva (shader de enrolar a folha sobre uma captura da página, `ViewportTexture` da página que sai);
  sombra da folha passando sobre a página de baixo (gradiente escuro a 35%). O conteúdo novo já está desenhado embaixo.
- A fita do capítulo que fecha sobe (0,15 s) e a do que abre desce sobre a página (0,2 s).
- Som: papel virando (pendente; provisório nenhum, melhor que um som errado). Ao abrir o livro, som de couro.
- Abrir o livro: a capa abre da direita para a esquerda (0,4 s) e mostra o capítulo de entrada.
- Compatibility (navegador) e "reduzir movimento" (se a opção existir): troca por opacidade de 0,15 s (como hoje).

## 6. O Discernimento sai do livro (recomendação; decide o Game Director)

O livro não vende. O Discernimento (graus I e II, Memória, `Discern.buy`, `HeroScreen.discern_buttons`) muda de casa.
Recomendo, em ordem:
1. **Vendedor, coluna Obras** (`shop_spec.md` B): é uma compra de conta com material, e a balança já tem o gesto "pôr no
   prato". Entra como duas etiquetas "Discernimento I" e "II" (a II "Depois de: Discernimento I"), mesmo desenho das Obras.
   Pede código pequeno (a tela do Vendedor lista o Discernimento ao lado das Obras; a lógica `Discern` fica igual).
2. Se o GD preferir não tocar no Vendedor agora: fica no livro **sem cara de loja**, como uma nota de margem "Anotar"
   com o custo escrito à mão em rubrica, e o resto do livro segue sem compra. É a exceção registrada, não o padrão.
Até a decisão, a página dos Ofícios continua com o Discernimento como hoje.

## 7. Até a arte chegar (só peças que já existem)

| Peça | Provisório |
|---|---|
| Livro, papel, couro | `BookSpread` + `book_page.gdshader` (com as páginas iguais) |
| Mesa | `_draw` (madeira 1a120c, veio em linhas) |
| Fitas | `StyleBoxFlat` nas cores da seção 1, ponta em V desenhada; marcas: `HeroCrest`/`GiftArt.corner` (leão, estrela), pena e martelo em `_draw` |
| Velas | duas colunas marfim desenhadas, chama em `_draw` com tremor por tempo |
| Retratos | `warrior_page.png`; Maga `hero_maga_img.png` com máscara |
| Vinheta da Abertura | `assets/ui/events/candles.png` em sépia (provisório) |
| Picareta | `PickMark` |
| Virada | opacidade 0,15 s até o shader de enrolar existir |

Arte final por caminho previsto: `assets/ui/book/desk.png`, `spread.png` (livro aberto vazio, com as
orelhas), `ribbon.png` (cinza, tingível), `ribbon_marks.png` (prancha de 4), `opening_desk.png`, `warrior_ink.png`,
`maga_ink.png`, `candle.png`, `pick_ink.png`, `pick_ink_broken.png` (itens 1 a 9 do pedido).
Pedido em `docs/art/requests/Pedido-ChatGPT-Livro.txt`; entra em `docs/steam-ia.md` antes do jogo.

## 8. Critério de aprovação (captura real, Forward+, 1280 x 720 e 1920 x 1080, Guerreiro e Maga)

1. Livro aberto com duas páginas iguais e três fitas; a do capítulo aberto caída sobre a página.
2. Cada capítulo cabe sem rolar; no máximo três seções por página; corpo 14 px ou mais a 720.
3. Nenhum botão de compra no livro (depois da decisão do item 6); sem Devoção no cabeçalho.
4. Com a Maga escolhida, a página do herói mostra a Maga (retrato, nome, arma, habilidades) e a fita âmbar com a estrela.
5. LB/RB, PageUp/PageDown, rodinha, orelha e fita viram a página; teclado, mouse e controle alcançam todos os botões.
6. Nada de metal brilhante, círculo de nós nem plantas; nada de violeta; nenhum rosto ou cena de Ahk.
