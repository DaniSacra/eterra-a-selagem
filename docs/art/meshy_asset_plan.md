# Plano de modelos no Meshy para a Arena das Catacumbas

Saldo: **546 créditos** (o Daniel comprou 1000 em 2026-11-15 e pediu para segurar depois dos inimigos e da Emeth;
em 2026-11-14 eram 6). Custos: prévia 5, textura 10 (um modelo parado com textura custa 15), esqueleto 5,
animação 3 por ação. Nada aqui foi gerado: cada item espera o Daniel aprovar o gasto (CLAUDE.md). A arena já está
montada sem eles (`CatacombHall`); cada modelo só troca uma peça provisória, no mesmo lugar.

Só entra aqui o que a Godot não faz bem com caixas e shaders: formas esculpidas, figuras, ornamento. Pedra lisa,
degraus, balaustradas simples, chão e muralhas continuam procedurais (`Masonry`, `masonry.gdshader`).

Estilo comum a todos os prompts (acrescentar ao fim de cada um): *"Stylized hand-painted dark fantasy game asset,
chunky readable shapes, worn carved stone in cool slate grey with violet undertones, painterly textures, no base
unless stated, no text, no logos."*

| Prioridade | Peça | Função visual | Tamanho no jogo | Quantas | Reuso | Textura | Animação | Créditos |
|---|---|---|---|---|---|---|---|---|
| 1 | Estátua encapuzada de mãos postas | o marco da pintura: gigante no abismo, pares no portal, canto noroeste | 3,8 a 7,6 m | 4 | todas as salas, escala variável | sim | não | 15 |
| 2 | Moldura do portal gótico | a fachada verde, foco da sala | vão de 3,4 x 5,4, conjunto 8 x 9 m | 1 | toda sala (e Morvath em vermelho) | sim | não | 15 |
| 3 | Obelisco de pedra lascada com nicho | primeiro plano, dois por sala | 1,5 x 5,5 m | 2 | todas as salas | sim | não | 15 |
| 4 | Braseiro de pedra e ferro | as poças de luz quente | 1,1 x 1,4 m | 4 | todas as salas | sim | não | 15 |
| 5 | Pilar de balaustrada com capitel | a borda que mais se vê | 0,6 x 1,2 m | cerca de 40 | todas as balaustradas | sim | não | 15 |
| 6 | Conjunto de potes de barro (3 formas) | cor quente nas bordas | 0,5 a 0,8 m | 12 | sim | sim | não | 15 |
| 7 | Caixote de madeira velha com ferragens | volume no pé da escada | 0,8 m | 4 | sim | sim | não | 15 |
| 8 | Grupo de velas derretidas sobre pedra | o brilho miúdo das bordas | 0,6 m | 13 | sim | sim | não | 15 |

Total do conjunto: 120 créditos. Só a prioridade 1 já muda muito a leitura da sala (aparece 4 vezes, em tamanhos
diferentes).

## Prompts

1. **Estátua encapuzada** (pose em pé, de frente): "Tall stone statue of a hooded robed figure standing upright,
   deep hood hiding the face in shadow, hands joined in prayer at the chest, long heavy robe falling in straight
   folds to the feet, carved from a single weathered block, chipped edges, moss in the cracks, solemn and mysterious,
   on a simple square plinth." (Quem são as estátuas é cânone pendente com o Daniel; o prompt evita símbolos.)
2. **Moldura do portal**: "Gothic stone doorway frame for a crypt, tall pointed arch with three nested receding
   archivolts, thick carved jambs, a pointed gable above with a plain round medallion, flanking buttresses with
   pointed pinnacles, empty opening (no door), front view, flat back to sit against a wall."
3. **Obelisco**: "Tall tapering stone obelisk made of stacked rough-hewn blocks, chipped and cracked, a small arched
   dark niche on one face near the top, pointed capstone, broad square base."
4. **Braseiro**: "Stone pedestal brazier, short thick carved column holding a wide shallow iron fire bowl with
   riveted rim, empty bowl (no fire), sturdy and old."
5. **Pilar de balaustrada**: "Single chunky stone balustrade post, square shaft with a wide flat cap and a moulded
   plinth, chipped corners, weathered."
6. **Potes**: "Set of three terracotta clay pots of different shapes (round belly, tall amphora, small jar), dark
   red-orange glaze worn away in places, chipped rims, grouped on the ground."
7. **Caixote**: "Old wooden storage crate with dark iron corner brackets and bands, scuffed planks, slightly warped
   lid."
8. **Velas**: "Cluster of melted church candles of different heights on a small flat stone, thick wax drips pooling
   at the base, wicks unlit."

## Depois de gerar

Para cada modelo: baixar em `assets/models/meshy/<chave>/`, registrar em `tools/meshy/tasks.json` (a Steam pede a
declaração; atualizar `docs/steam-ia.md`) e trocar a peça no lugar dela (`ArenaKit.statue`, `Masonry.obelisk`,
`ArenaKit.brazier`, `Masonry.post`, `Masonry.pot`, `CatacombHall._candles`, `CatacombHall._facade`).
