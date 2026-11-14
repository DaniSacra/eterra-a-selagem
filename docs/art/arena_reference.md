# Arena das Catacumbas: análise da referência e reconstrução

Referência: imagem do Daniel "Arena das Catacumbas: Golpe Dourado" (1672 x 941, feita por IA, 2026-11-14; fica fora
do repositório, ver `docs/steam-ia.md`). Implementação: `scripts/game/catacomb_hall.gd` (`CatacombHall`), peças de pedra em
`scripts/game/masonry.gd` (`Masonry`) e `scripts/game/arena_kit.gd` (`ArenaKit`), materiais em `assets/shaders/`.

## Câmera da imagem

Medida pelas bordas da sala, que são paralelas duas a duas: na imagem, as bordas norte e sul sobem 0,26 para cada 1 na
horizontal, e as bordas oeste e leste descem 0,5. Disso saem um giro de 35° (a câmera fica no sudeste, olhando para o
noroeste) e uma inclinação baixa. A lente é longa: as verticais dos obeliscos e da fachada são quase paralelas.

| | Referência (medida) | Jogo |
|---|---|---|
| Campo de visão (vertical) | cerca de 24° | 24° (`Feel.cam_fov`) |
| Giro horizontal | 35° | 35° (`Feel.cam_yaw`) |
| Inclinação | 26° a 30° | 30° (`Feel.cam_pitch`; 30 preserva a leitura do combate) |
| Distância | herói de 2,5 m com 88 px de altura | 60 m (`Feel.cam_distance`) |
| Projeção | perspectiva, quase ortográfica | perspectiva |

Dois modos: o de jogo segue o herói com esses ângulos; `--showcase` fixa a câmera no enquadramento da imagem
(`CatacombHall.SHOWCASE`, `Game.SHOWCASE_DISTANCE`) para comparar lado a lado. O teclado e o controle giram com a
câmera (cima na tela é cima no jogo: `Feel.screen_to_floor`).

## Como as posições foram tiradas

Cada marco da imagem (pontas das bordas, pés dos obeliscos, escada, braseiros, centro e bordas do medalhão) foi
projetado no chão (ou na altura certa, para as bacias dos braseiros) pela câmera acima. Assim cada peça cai, vista
pela câmera do jogo, onde a pintura a tem. O resultado não é a sala quadrada que parecia à primeira vista:

| Elemento | Na imagem | No mundo (m; x leste, z sul) |
|---|---|---|
| Sala de combate | losango central | 32 x 30 (`HALF` 16 x 15) |
| Medalhão (estrela de 8 pontas, anéis) | centro-esquerda | centro (-2,5; 1), raio 7,5 |
| Escada do altar | alto à direita, larga | x -3,8 a 5,6 na borda norte, 4 degraus até 1 m |
| Portal verde | no alto da escada, metade direita | x 2,8, fachada em z -20, vão de 3,4 x 5,4 |
| Estátuas encapuzadas do portal | ladeando o vão | x -1,4 e 7,2, 4,4 m |
| Estandartes vermelhos | nos contrafortes da fachada | x -3,6 e 12,6 |
| Braseiro e estátua do canto noroeste | alto, centro | píer no abismo em (-12,4; -18,3) |
| Estátua gigante e seu braseiro | alto à esquerda | torre em (-26; -4,4), 7,6 m; braseiro em (-23; -4,4) |
| Balaustrada oeste com velas e potes | borda esquerda inteira | x -16, de z -15 até o patamar |
| Obelisco sul | embaixo à esquerda do centro | (-2,6; 15,3), 5,2 m |
| Patamar de entrada ("entrada na esquerda baixo") | embaixo à esquerda | x -16 a -3,6, z 15 a 20,5, degraus descendo |
| Obelisco e braseiro leste | embaixo à direita | (16,3; 2,1) e braseiro ao lado |
| Escada descendo à direita | direita, entre o obelisco e o braseiro do alto | vão na borda leste, z -5,8 a 0,6 |
| Braseiro do canto direito | alto à direita | píer em (17; -7) |
| Caixotes, potes e velas | pé da escada, à direita | (7,2; -14) |

A imagem não é fisicamente coerente em tudo (é uma pintura): a melhor câmera deixa erros de cerca de 1 m nos marcos
mais distantes. O que se viu na imagem prevaleceu sobre simetria.

## Arquitetura e materiais

- Plataforma de pedra sobre o abismo, com muralha de blocos descendo até a névoa roxa e contrafortes sob a borda.
- Altar elevado com escada larga, fachada gótica de 10,5 m com três arcos ogivais encaixados, frontão, contrafortes
  com pontas, janelas ogivais escuras e o véu verde do portal no fundo do vão.
- Balaustradas de pedra com pilares largos de capitel, corrimão grosso, rodapé e balaústres (`Masonry.balustrade`).
- Obeliscos de blocos que afinam, com ponta e nicho escuro (`Masonry.obelisk`).
- No abismo: arcada ogival a oeste com uma lanterna, torre no noroeste, arcos atrás da fachada, correntes grandes
  ligando a estátua gigante, a torre e a fachada.
- Pedra: `masonry.gdshader`, cantaria em fiadas no mundo (triplanar), juntas fundas com relevo, lavagem pintada de
  ardósia e violeta, lascas e rachaduras, sujeira subindo do pé, topos mais claros. Vale para toda pedra construída e
  para as peças de pedra do KayKit.
- Chão: `catacomb_floor.gdshader`, lajes grandes quase quadradas (2,1 m) em fileiras de profundidade variável, algumas
  partidas, rachaduras, poças úmidas que refletem (SSR) e o medalhão gravado em ouro velho.

## Luz e atmosfera

- Desktop em Forward+ (o navegador e o celular seguem em Compatibility): névoa volumétrica leve, SSAO, reflexos de
  tela nas poças, sombras dos braseiros.
- Ar frio azul-petróleo (fundo, névoa de distância), luz ambiente violeta-acinzentada baixa.
- Quente: 4 braseiros (luz 7, alcance 16, com sombra) e 13 grupos de velas (10 com luz própria, de alcance 5).
- Verde: o portal (luz forte mesmo fechado, mais forte aberto) e um foco descendo a escada até o chão molhado.
- Violeta: cinco luzes no abismo, sob as bordas, que pintam a muralha e a névoa.
- Lua fria vinda do noroeste, por trás, para recortar pedra e lutadores.

## Ciclos de comparação (capturas reais da Godot)

1. Primeira montagem (sala quadrada de 28 m, câmera de 47°): losango certo, mas câmera alta, tudo escuro, fogo estourado.
2. Câmera mais baixa, menos brilho, pedra e chão mais claros: elementos no lugar, mas fachada cortada e blocos miúdos.
3. Ajuste da câmera pela projeção dos marcos: a sala virou 32 x 30, escada larga, obelisco no meio da borda sul,
   patamar de entrada; composição batendo com a imagem.
4. Luz: chão mais quente, poças dos braseiros maiores, verde do portal na escada, roxo do abismo.
5. Correntes grandes no alto, roxo só nas laterais, saturação e exposição mais perto da pintura.

Capturas: `docs/art/shots/` (vitrine e jogo, 1280 x 720 e 1920 x 1080). Comparação lado a lado com a referência:
fora do repositório, em `C:\Users\danie\ASelagem-teste\arena-comparacao.png`.

## Situação: PARCIALMENTE CONCLUÍDA

Composição, posições, câmera, paleta e luz seguem a imagem. O que ainda separa o jogo da pintura depende de modelos e
texturas que não existem no projeto (plano em `meshy_asset_plan.md`):

- Estátuas encapuzadas: hoje é o encapuzado do KayKit em pedra lisa; a pintura tem estátuas esculpidas, de mãos postas.
- Fachada do portal: feita de caixas; a pintura tem cantaria esculpida, arquivolta e gárgulas.
- Obeliscos, balaustradas, braseiros: caixas com material de cantaria; a pintura tem pedra lascada e volumosa.
- Potes, caixotes e velas: KayKit e formas simples; menores e mais limpos que os da pintura.
- Estandartes: lisos (o símbolo da pintura é cânone pendente com o Daniel).
- Herói e inimigos: os da pintura (minotauro de escudos, esqueletos) são outros modelos.
- HUD da pintura (retrato, losangos Q/E/R) não foi copiado: o HUD do jogo é outro trabalho.
- No navegador (Compatibility) a luz rende diferente: mais claro e azulado mesmo com a compensação
  (`Game.COMPAT_EXPOSURE`).
