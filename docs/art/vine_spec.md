# A Videira: a planta que cresce (especificação, art-director, 2026-11-23)

Para o `ui-ux-designer` (tela) com o `technical-artist` (ramos, folhas, crescimento). Identidade em `meta_identities.md`
6 (crescimento de baixo para cima, madeira viva, folha e barro, verde oliva e musgo 5f6b2e com flores âmbar, gesto
**regar**, som de madeira e folhas). Substitui o esboço de `meta_screens_identity.md` 2.3 onde divergir.
Alvo de leitura: **em 3 segundos** o jogador vê qual raiz pode crescer agora, quanto custa e o que ela dá.

## 0. O que muda em relação à `VineScreen` de hoje

- Sai a folha do Livro (`BookSpread`) e os cartões de papel em três colunas. Entra a planta: vaso, tronco, três ramos
  curvos numa latada sob o arco de pedra, os nós como **brotos** com **etiquetas de barro**.
- Sai a pergunta "Comprar X por N Prata?". O passo de confirmação é o botão **Regar** com o preço escrito nele (B.2).
- Fica toda a lógica: `Vine` (`state`, `problem`, `buy`, `balance`, `nodes_of`, `branches`, `growth`), o sinal
  `bought(id)`, a gravação do save, os textos `vine_*`, a `VineStation` do Santuário (já cresce com `Vine.growth`).

## 1. Composição (1280 x 720; a 1920 x 1080 x1,5)

Ordem das camadas: fundo (arco e latada), vaso, tronco, ramos, folhas e flores, brotos, etiquetas, painel, alto.

| Peça | 1280 x 720 | Observação |
|---|---|---|
| Fundo | tela inteira | o arco de pedra do Santuário visto de frente, à noite com luz quente de lanterna; latada de ferro fino em losangos dentro do arco (x 120..900, y 80..600); vinheta 0,55 |
| Título "A Videira" | Cinzel 30 `GOLD`, canto (40, 24) | linha `vine_line` em Alegreya Sans Italic 16 `DIM` embaixo |
| Saldo | x 1000..1256, y 24..60 | Prata e Memória (`MaterialCount.purse`), Bold 20, ícone 24 |
| Vaso | centro (490, 660), 150 x 110 | barro cozido 8a5a3a com faixa escura; corta na borda de baixo |
| Tronco | de (490, 615) a (490, 500), retorcido | 26 px na base, 18 px no garfo |
| Ramos | três curvas saindo de (490, 500) | Vida para a esquerda e para cima, Provisão reta para cima, Perseverança para a direita; 14 px no começo, 6 px na ponta |
| Painel de leitura | x 960..1264, y 110..560 (304 x 450) | madeira escura 241a12 a 94%, filete de barro 8a5a3a 2 px (seção 4) |

### 1.1 Os nove brotos (centro) e as etiquetas

Broto 44 px (comprado vira cacho de 64 px). Etiqueta de barro 128 x 46 presa ao broto por um fio de 22 px, **para fora**
do tronco (Vida à esquerda do broto, Provisão e Perseverança à direita). Nada se sobrepõe nesta tabela.

| Ramo | Raiz (`id`) | Broto | Etiqueta (x, y do canto) |
|---|---|---|---|
| Vida | Seiva (`vida_1`) | (390, 450) | (240, 427) |
| Vida | Caule (`vida_2`) | (290, 330) | (140, 307) |
| Vida | Raiz Funda (`vida_3`) | (220, 200) | (70, 177) |
| Provisão | O Viajante (`viajante`) | (490, 390) | (512, 367) |
| Provisão | Estoque (`estoque`) | (490, 275) | (512, 252) |
| Provisão | Reserva (`reserva`) | (490, 160) | (512, 137) |
| Perseverança | Colheita de Prata (`prata`) | (590, 450) | (612, 427) |
| Perseverança | Colheita de Memória (`memoria`) | (690, 330) | (712, 307) |
| Perseverança | Colheita Farta (`materiais`) | (760, 200) | (782, 177) |

O nome do ramo fica na ponta, acima do último broto: "Vida" em (220, 150), "Provisão" em (490, 112), "Perseverança" em
(760, 150), Cinzel 18 `PALE`. As posições são dado (a ordem e o ramo vêm de `Vine.nodes_of`); um ramo de 4 nós pede
uma linha nova na tabela, não código novo: guardar as posições numa tabela por `step` e ramo.

**Etiqueta de barro**: plaquinha de terracota 9a6a48 com borda queimada 5a3a24, furo no alto, o nome em Alegreya Sans
Bold 15 escuro 2a1a10 e, embaixo, o preço: ícone 16 + número Bold 16. Sem material, o número em rubrica
(`Book.RUBRIC`). Comprada: a etiqueta vira para o verso (liso, só um ✓ desenhado em verde musgo; nunca texto).

## 2. Estados (`Vine.state`), por desenho e por palavra (a palavra no painel)

| Estado | Broto e ramo | Etiqueta | Palavra no painel |
|---|---|---|---|
| `OWNED` | cacho aberto: 3 folhas oliva 5f6b2e e duas flores âmbar f0a040 com brilho leve; o trecho do ramo até ele grosso e verde | verso liso com ✓ | "Já cresceu" (`vine_owned` passa a "Já cresceu") |
| `AVAILABLE` | broto inchado verde claro 8a9a4a, brilho que respira (0,9 a 1,0 em 2 s) | frente, preço em escuro | "Pode crescer" |
| `SHORT` | broto inchado sem brilho | frente, preço em rubrica | "Faltam N de Prata" (número calculado) |
| `LOCKED` (pede o anterior) | broto seco, marrom 5a4a3a, ramo fino e cinza depois dele | frente a 55% | "Depois de: Seiva" (`vine_locked`) |
| Foco | anel de luz âmbar 3 px a 6 px do broto, pulso 0,6 s; a etiqueta sobe 4 px | aro âmbar | o painel mostra o broto |

## 3. Entrada

- **Direcional e setas**: ↑/↓ andam no ramo (para cima é crescer: Seiva, Caule, Raiz Funda); ←/→ passam ao ramo vizinho
  na mesma altura (`step`). Para a direita do ramo Perseverança, o foco vai ao botão Regar do painel.
- **A / Enter / clique no broto**: escolhe; o foco vai ao botão **Regar** com o preço ("Regar · 10 Prata").
- **A / Enter / clique em Regar**: rega (compra). Desligado sem material ou pedindo o anterior, com o motivo no botão.
- **B / Esc**: com o foco no Regar, volta ao broto; no broto, fecha a tela (`ScreenHost`).
- **LB/RB, PageUp/PageDown**: saltam de ramo (Vida, Provisão, Perseverança).
- Mouse: passar dá o foco; rodinha sobe e desce no ramo.
- Abre com o foco no primeiro broto `AVAILABLE` (de baixo para cima, Vida primeiro); se nenhum, em Seiva.

## 4. Painel de leitura (3 segundos)

De cima para baixo, margem 18:
1. O **nome** em Cinzel 24 `STRONG` e, embaixo, "Vida · 2ª raiz" em Alegreya Sans Italic 15 `DIM`.
2. A **palavra de estado** em Bold 17 na cor dele (âmbar "Pode crescer", rubrica clareada "Faltam 5 de Memória",
   musgo "Já cresceu", `DIM` "Depois de: Seiva").
3. **O que muda**: a frase `vine_*_desc` em Alegreya Sans 19 `PALE`, números em negrito (`BoonCard.strong_numbers`).
   Para a Vida, uma segunda linha com o total: "Vida máxima: **+10** com esta" (soma das raízes de Vida já crescidas mais
   esta; o número vem dos `mods`).
4. Filete de barro.
5. **Quanto**: ícone 32 e número Bold 32 (`GOLD` se pode, rubrica se não) e "você tem N" em 15 `DIM`.
6. **Botão Regar** 270 x 50 no pé do painel (y 490..540): glifo da tecla (`UiKit.action_label`), "Regar" e o preço.
   Desligado: o motivo no lugar do verbo.
7. Embaixo do painel, fora dele (y 580..700): "Raízes crescidas: 4 de 9" em Bold 16 e uma frase curta que já existe
   (`vine_none` quando é 0).

## 5. Regar (gesto e animação)

- Ao regar: um **regador** de barro (desenho, 70 px) aparece sobre o broto e inclina (0,2 s), 8 gotas caem no broto
  (0,3 s), som de água curto. O broto **cresce sozinho** (0,6 s): incha, abre em 3 folhas, as duas flores âmbar
  desabrocham, e o trecho do ramo até o próximo broto engrossa e esverdeia (o seco vira inchado se puder ser o próximo).
  Folhas tremem (0,4 s) com som de folhas. A etiqueta vira para o verso (0,25 s). O saldo desce contando (0,3 s).
- Abrir a tela: o fundo entra (0,2 s), a planta "cresce" do vaso até o estado salvo em 0,6 s (ramos desenhados por
  comprimento), os brotos aparecem de baixo para cima (30 ms cada).
- Compatibility: sem brilho dos brotos nem gotas; o crescimento fica.

## 6. Até a arte chegar (só peças que já existem)

| Peça | Provisório |
|---|---|
| Fundo | `UiKit.INK` com o arco desenhado (dois pilares e o arco em `_draw`, pedra 50473f) e a latada em linhas finas `OLD_GOLD` a 35% |
| Ramos e tronco | `Line2D` com Catmull-Rom, largura que afina (`width_curve`), cor `VineStation.WOOD` 42301c; o trecho vivo mistura com `LEAF_A` |
| Folhas, brotos, flores | `_draw` (elipses e círculos nas cores de `VineStation`: `LEAF_A`, flor âmbar) |
| Vaso | `_draw` em `VineStation.STONE`/barro |
| Etiquetas, painel | `StyleBoxFlat` (`UiKit.box`) |
| Ícones | `MaterialCount` (Prata, Memória) |
| Som | `ui_move`; água e folhas pendentes (`fountain` curto provisório para a água) |

Alternativa aceita para o provisório: a própria `VineStation` num `SubViewport` com câmera frontal, se der a mesma
posição dos brotos da tabela 1.1 (o 2D é preferido: posições exatas e Compatibility).

Arte final por caminho previsto (como `DonsArt`): `assets/ui/vine/bg.png`, `vase.png`, `bark.png` (textura em tira
para o `Line2D`), `bud_dry.png`, `bud_closed.png`, `bud_ready.png`, `cluster.png`, `leaf.png`, `tag.png`,
`tag_back.png`, `can.png`, `drops.png`, `panel.png` (itens 1 a 9 do pedido). Pedido em `docs/art/requests/Pedido-ChatGPT-Videira.txt`; entra em
`docs/steam-ia.md` antes do jogo.

## 7. Textos novos

`vine_can` "Pode crescer", `vine_short_n` "Faltam {n} de {m}", `vine_after` "Depois de: {a}" (ou reusar `vine_locked`
mudando o texto), `vine_water` "Regar", `vine_step` "{b} · {n}ª raiz", `vine_life_total` "Vida máxima: +{n} com esta",
`vine_count` "Raízes crescidas: {n} de {m}", `vine_have` "você tem {n}". `vine_owned` passa a "Já cresceu". Saem
`vine_confirm`, `vine_buy`, `vine_cancel` se ninguém mais usar.

## 8. Critério de aprovação (captura real, Forward+, 1280 x 720 e 1920 x 1080)

1. Planta crescendo de baixo para cima a partir do vaso, três ramos curvos, nenhuma linha reta de grafo.
2. Os nove brotos nas posições da tabela (5 px), nenhuma etiqueta sobre outra nem sob o painel.
3. Os quatro estados distintos pelo desenho **e** pela palavra no painel; a etiqueta mostra nome e preço legíveis.
4. Com o foco num broto, o painel mostra nome, estado, o que muda e o preço com "você tem N" sem rolar.
5. Regar gasta uma vez só e a planta cresce; B no Regar volta sem gastar; teclado, mouse e controle andam em tudo.
6. Corpo 14 px ou mais a 720; nada de violeta, metal polido nem ouro como cor dominante.
7. A estação do Santuário (`VineStation`) mostra o mesmo crescimento depois de fechar a tela (já faz; conferir).
