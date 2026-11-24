# Forja: a Emeth na bancada (especificação, art-director, 2026-11-23)

Para o `ui-ux-designer` (tela) com o `technical-artist` (brasa, faíscas, calor da lâmina). Identidade em
`meta_identities.md` 3 (forma horizontal comprida, ferro, pano e brasa, laranja de brasa e07a2a sobre fuligem, gesto
**três marteladas**, som de bigorna e chiado). Substitui o desenho de `meta_screens_identity.md` 2.1 onde divergir.
Alvo de leitura (o Daniel achou os Dons confusos): **em 3 segundos o jogador vê o que pode forjar, quanto custa e o que
muda**. Tudo abaixo serve a isso; enfeite que disputa com a placa de baixo sai.

## 0. O que muda em relação à `ForgeScreen` de hoje

- Sai o livro (`BookSpread`, páginas, índice em grade, marcadores de couro). A Forja não é papel.
- Saem os três marcadores Emeth, Oficina e Despertar. Ficam **duas bancadas**: a Emeth (Temperar, Refinar, Despertar,
  Inscrever, os quatro na própria arma) e a Oficina (a Picareta, quando houver veio anotado). LB/RB trocam de bancada.
- Sai o "Forjar" de um aperto. Gastar material pede **três marteladas** (o próprio gesto é a confirmação; não há pergunta).
  Usar, Despertar e Adormecer (sem custo) seguem de um aperto só.
- Fica toda a lógica: `Forge` (`state`, `problem`, `buy`, `put_on`, `take_off`, `awake`, `refines_on`, `has_tool`),
  `Oficios.restore`, os sinais `forged(rank)` e `restored`, `Save.write`, os textos `forge_*` que já existem, `EmethView`.

## 1. Composição (1280 x 720; a 1920 x 1080 tudo x1,5)

Ordem das camadas: fundo da oficina, brilho de brasa embaixo, pano, Emeth, marcas dos pontos, faixa de opções, placa da
bancada, alto (título, bancadas, bolsa).

| Peça | 1280 x 720 | Observação |
|---|---|---|
| Fundo | tela inteira | oficina escura (`UiKit.INK` 0c0a0e), vinheta 0,6; gradiente de brasa e07a2a a 30% subindo da borda de baixo até y 420 |
| Título "Forja da Emeth" | Cinzel 30, `UiKit.GOLD`, canto (40, 22) | na Oficina: "Oficina do Forjador" (chave nova `forge_title_workshop`) |
| Bancadas (LB/RB) | duas placas de ferro 132 x 34, centro (574, 40) e (706, 40) | Cinzel 16; a ativa em brasa e07a2a com borda `OLD_GOLD`, a outra fuligem 2a2620 e texto `DIM`; glifos LB/RB (`UiKit.action_label`) 18 px nas pontas; a Oficina só aparece com `workshop_open()` |
| Bolsa | x 1000..1252, y 24..60, Alegreya Sans Bold 20 | só os materiais que a bancada usa: Emeth = Prata e Esmeralda (esta depois da primeira, `MaterialCount.shown`); Oficina = Prata e Pedra Funda. Ícone 24 px |
| Pano | x 60..1220, y 200..330, cantos caídos | pano grosso marrom 3a2a1e com dobra; borda de baixo some no escuro |
| **Emeth deitada** | pomo em (150, 262), ponta em (1150, 262): **1000 px**, 78% da largura | lâmina para a direita, horizontal, gume de cima com os 3 entalhes; guarda vertical em x 300 (y 205..319) |
| Faixa de opções | y 372..436, centrada em x 640 | as escolhas do ponto em foco (seção 3) |
| **Placa da bancada** (leitura) | x 140..1140, y 470..690 (1000 x 220) | ferro escuro 1a1612 a 94%, filete `OLD_GOLD` 2 px, rebites nos cantos (seção 4) |

### 1.1 Os quatro pontos na arma

Cada ponto tem uma **marca de toque** (losango de ferro de 28 px com aro de brasa quando há algo a fazer ali) e um rótulo
acima da arma. Rótulos em Cinzel 18, `UiKit.PALE`; o do ponto em foco em `GOLD` e 20.

| Ponto | Lugar na arma | Marca (centro) | Rótulo (centro) | O que se vê na arma |
|---|---|---|---|---|
| **Despertar** (Esmeralda) | pomo | (150, 262) | (150, 168) | engaste do pomo: vazio (oco escuro) ou a pedra desperta brilhando (Sede âmbar f0a040, Ímpeto azul 6a9ad8, Eco Longo marfim). Nunca esmeralda viva aqui (é da lâmina) |
| **Refinar** (Prata, 2 ações) | guarda | braço de cima (300, 214) = Ataque; braço de baixo (300, 310) = Especial | (300, 168) | um anel de ferro em cada braço da guarda; o refinamento em uso deixa o anel em ouro velho com a letra inicial (F, P, R; L, S, O gravadas em marfim, 12 px) |
| **Inscrever** (Prata) | plano da lâmina | (620, 262) | (620, 168) | letras gravadas em ouro velho no plano (uma linha por Encanto inscrito, 3 linhas de 6 px de altura). Nunca runas (são de Morvath) |
| **Temperar** (Prata) | gume de cima | (900, 236) | (900, 168) | três entalhes no gume em x 840, 900, 960; cada posto forjado acende um entalhe em brasa clara f5a050 e as veias de ouro de `EmethSword.set_temper` |

Distância mínima entre marcas: 120 px (guarda e pomo, 150 px). Ponto sem a ferramenta do Forjador (`Forge.has_tool`
falso): coberto por um **pano cinza 2a2620 com o cadeado** (`SealedMark`, 22 px) e o rótulo em `DIM`; a placa diz o
`forge_no_tool*` (onde achar a ferramenta). Despertar e Inscrever só aparecem com a ferramenta (`arts_open()`), como hoje.

### 1.2 Oficina (segunda bancada)

Mesmo fundo e mesmo pano; no lugar da Emeth, a **Picareta deitada** (`PickMark` grande, 620 x 220, centro (640, 262)) no
estado dela (perdida em contorno, cabeça achada, restaurada). Um ponto só: **Restaurar**, marca na cabeça da Picareta.
Mesma placa, mesmo gesto (três marteladas, `Oficios.restore`, sinal `restored`). O Forjador abre direto na Oficina
enquanto a Picareta espera (`Hub._open_forge`, como hoje).

## 2. Entrada

- **←/→ (direcional, setas, A/D)**: anda pelos pontos da arma na ordem pomo, guarda, lâmina, gume (Despertar, Refinar,
  Inscrever, Temperar). **↑/↓**: anda nas opções da faixa (o foco desce da arma para a faixa e volta). Na guarda, ↑ é o
  braço do Ataque e ↓ o do Especial antes de descer para a faixa.
- **LB/RB, PageUp/PageDown, rodinha**: troca de bancada (Emeth, Oficina).
- **A / Enter / clique esquerdo**: uma martelada (ou Usar, Despertar, Adormecer, que não custam e fazem tudo num aperto).
- **Segurar A / Enter / botão do mouse 1,2 s**: dá as três marteladas sozinho (acessibilidade), na mesma cadência.
- **B / Esc**: com a peça quente (1 ou 2 marteladas), esfria e cancela sem gastar; fria, fecha a tela (`ScreenHost`).
- Mouse: passar sobre uma marca ou opção dá o foco; clicar martela.
- Abre com o foco no ponto que tem algo comprável mais barato; se nada, no Temperar.

## 3. Faixa de opções (o que o ponto em foco oferece)

Fichas de ferro 176 x 56, 12 px entre elas, centradas em x 640; nome em Cinzel 16 e o preço embaixo (ícone 16 + Alegreya
Sans Bold 16). Estado de cada ficha por desenho **e** palavra:

| Estado (`Forge.state`/`problem`) | Ficha | Palavra embaixo |
|---|---|---|
| Comprável (`OK`) | ferro 2a2620, aro brasa e07a2a 2 px | o preço em `PALE` |
| Falta material (`SHORT`) | ferro, aro cinza | o preço em `UiKit.RED` apagado (c05040) |
| Pede o anterior (`NEEDS`) | ferro a 55%, aro tracejado | "Depois de: Temperar I" |
| Forjado e guardado | aro ouro velho, losango cheio | "Guardado" (Usar é de graça) |
| Na lâmina / desperto / inscrito | aro ouro vivo `GOLD`, fundo brasa a 25% | "Na lâmina" |
| Sem ferramenta (`NO_TOOL`) | pano cinza com cadeado | "Falta a ferramenta" |

Conteúdo por ponto: Temperar 3 fichas (I, II, III); Refinar 3 fichas da ação em foco (Fio, Peso, Pressa ou Onda Larga,
Onda Pesada, Onda Pronta; um rótulo "Ataque" ou "Especial" em Alegreya Sans Italic 14 à esquerda da faixa); Despertar 3
(Sede, Ímpeto, Eco Longo); Inscrever 3 (Corte Sísmico, Onda Gêmea, Eco do Passo); Oficina 1 (Picareta).

## 4. Placa da bancada: a leitura em 3 segundos

Três colunas dentro de x 140..1140, y 470..690, margem 20:

1. **O quê** (x 160..440): ícone do ponto 56 px (lingote para Temperar, anel para Refinar, pedra para Despertar, letra
   para Inscrever; desenho na Godot) e o **nome** em Cinzel 26 `STRONG` ("Temperar II"); embaixo a **palavra de estado**
   em Alegreya Sans Bold 16 na cor do estado ("Pronto para forjar" em brasa, "Faltam 12 de Prata" em vermelho apagado,
   "Na lâmina, em toda descida" em ouro).
2. **O que muda** (x 460..860): uma frase só, Alegreya Sans 20 `PALE`, números em negrito (`BoonCard.strong_numbers`):
   o `*_desc` que já existe ("O especial e o Ômega dele causam **20%** a mais de dano."). Embaixo, em Alegreya Sans Italic
   15 `DIM`, o que troca quando troca ("No lugar de Fio" para um Refinar de ação ocupada; `forge_step_use`).
3. **Quanto** (x 880..1120): o **preço grande**, ícone 32 px e número em Alegreya Sans Bold 34 (`GOLD` se pode, vermelho
   apagado se não); embaixo "você tem 47" em 15 `DIM`. Sem custo: "Sem custo" em 20.

No pé da placa, centrado em x 640, y 640..682: o **botão de martelar** 300 x 42 com o glifo da tecla (`UiKit.action_label`),
o verbo e **três pontos** (14 px) que acendem em brasa a cada martelada: "Martelar ● ○ ○". Sem nada a fazer, o botão some
e a linha diz o porquê (`forge_done`, `forge_no_tool*`, `forge_step_needs`).

Regra: nenhum texto de corpo abaixo de 14 px a 720; a placa nunca tem mais de 4 linhas de texto.

## 5. Gesto e animação

- **Martelada 1 e 2**: a arma toma um tranco de 3 px para baixo e volta (0,08 s), clarão branco-brasa no ponto (raio 40,
  0,1 s), 6 faíscas laranja saindo para cima (0,3 s), o ponto **esquenta**: a região da arma em volta do ponto tinge
  de e07a2a a 25% (1ª) e 50% (2ª). Som: bigorna (`mat_armor_*` provisório). Entre marteladas há 1,2 s; parado mais
  que isso, a peça esfria em 0,4 s e o contador volta a zero.
- **Martelada 3**: o gasto acontece aqui (`Forge.buy` ou `Oficios.restore`); clarão maior (raio 80), 14 faíscas, a
  marca nova aparece na arma (entalhe aceso, anel, pedra, letras) com `EmethView.show_rank(grow)` no Temperar; depois a
  **têmpera**: vapor branco subindo do ponto (0,5 s) e o tom brasa sai em 0,6 s. Som: bigorna mais forte e chiado. O
  número da bolsa desce contando (0,3 s).
- **Usar, Despertar, Adormecer** (sem custo): o anel ou a pedra troca de lugar com um clique de metal (0,2 s), sem brasa.
- **Abrir a tela**: o fundo entra (0,2 s), a Emeth desliza da esquerda para o pano (0,35 s), as marcas aparecem do pomo
  para a ponta (40 ms cada). **Trocar de bancada**: a peça sai pela direita e a outra entra pela esquerda (0,3 s).
- Compatibility (navegador): sem faíscas nem brilho aditivo; o tom brasa e o tranco ficam.

## 6. Maga

As trilhas da Forja são só da Emeth (`data/forge/emeth/`). Com a Maga escolhida, a bancada mostra a Emeth e uma linha em
Alegreya Sans Italic 16 sob o título: "A Forja trabalha a Emeth." (chave nova `forge_emeth_only`). Quando houver trilhas
do cajado, o cajado de duas pontas deita no mesmo pano, pontos nas duas pontas e no meio. Não inventar isso antes.

## 7. Até a arte chegar (só peças que já existem)

| Peça | Provisório |
|---|---|
| Fundo da oficina | `UiKit.INK` com o gradiente de brasa desenhado (`_draw`) e vinheta |
| Pano | retângulo 3a2a1e com borda irregular desenhada e sombra |
| Emeth | `EmethView` deitada: inclinação 90 graus (ponta para a direita), sem o balanço; tamanho 1000 x 160 (`setup`) |
| Picareta | `PickMark` |
| Marcas, fichas, placa | `_draw` e `StyleBoxFlat` (`UiKit.box`) |
| Ícones de material | `MaterialCount` / `DoorGlyph.material` (Prata, Esmeralda, Pedra Funda) |
| Som | `mat_armor_0..2` (martelada), `ui_move` (foco); chiado pendente |

Arte final por caminho previsto, sem mexer em código quando chegar (como `DonsArt`): `assets/ui/forge/bg.png`,
`cloth.png`, `emeth_flat.png`, `gem_amber.png`, `gem_blue.png`, `gem_ivory.png`, `ring_iron.png`, `ring_gold.png`,
`pick_whole.png`, `pick_head.png`, `chip.png`, `plate.png`, `mark_on.png`, `mark_off.png`, `icons.png` (prancha de 4),
`sparks.png`, `steam.png` (itens 1 a 11 do pedido). Pedido em
`docs/art/requests/Pedido-ChatGPT-Forja.txt`. Tudo que vier do ChatGPT entra em `docs/steam-ia.md` antes de ir para o jogo.

## 8. Textos novos (`data/text_pt.tres`)

`forge_title_workshop` "Oficina do Forjador", `forge_emeth_only` "A Forja trabalha a Emeth.", `forge_hammer` "Martelar",
`forge_point_awaken`/`refine`/`inscribe`/`temper` (os rótulos dos pontos; podem reusar `forge_awaken`, `forge_inscribe`,
`forge_track_temper`), `forge_stored` "Guardado", `forge_free` "Sem custo", `forge_have` "você tem {n}". Os que já
existem ficam (`forge_state_*`, `forge_step_*`, `forge_no_tool*`, `forge_done`).

## 9. Critério de aprovação (captura real, Forward+, 1280 x 720 e 1920 x 1080)

1. A Emeth deitada ocupa de 75 a 80% da largura, ponta à direita, sobre o pano; os quatro rótulos legíveis acima dela.
2. Com o foco em qualquer ponto, a placa mostra nome, estado, a frase do que muda e o preço com "você tem N", sem rolar.
3. Os seis estados das fichas se distinguem pela cor **e** pela palavra.
4. Três marteladas gastam uma vez só; B entre a 1ª e a 3ª não gasta; segurar faz as três.
5. Teclado, mouse e controle alcançam todos os pontos e fichas; LB/RB trocam de bancada.
6. Corpo de 14 px ou mais a 720; nada de violeta; esmeralda viva só na lâmina; nada de runas na lâmina.
7. `RESULT` da semente 5 igual (a tela não toca na partida) e os testes da Forja (`test_forge*`, `test_fatia3_ui`,
   `test_rj1_ui`) passando ou atualizados para a disposição nova.
