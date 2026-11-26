# 02. Sala 01, cenário projetável (técnica A)

A ideia: uma pintura só da Sala 01, vista **pelo mesmo ângulo da câmera do jogo**, que a Godot projeta por cima da
geometria que já existe (chão, paredes, fachada, balaustrada). A câmera do jogo nunca gira, só anda; por isso uma
pintura feita desse ângulo serve para qualquer posição do herói. Personagens, inimigos, quebráveis, portas abertas,
ícones e efeitos continuam 3D por cima.

Base: o pacote aprovado `docs/art/ref/sala01_2026-11-25/` (pintura `01-arte-aprovada.jpg`, planta
`02-planta-dados.json`) e o que o código monta hoje (`scripts/game/catacomb_hall.gd`). Onde os dois diferem, vale o
código (portas maiores e piso 32 x 30 m), porque a pintura tem de assentar nele.

## Números da câmera

| | Jogo, câmera Perto (padrão) | Jogo, Longe | **Quadro da pintura** |
|---|---|---|---|
| Inclinação (olhando para baixo) | 30° | 30° | **30°** |
| Giro (yaw) | 35° | 35° | **35°** |
| Campo de visão vertical | 24° (horizontal 41,4° em 16:9) | 24° | **24°** (lente de uns 55 mm em full frame, de muito longe) |
| Distância ao ponto olhado | 37 m | 54 m | **68 m** |
| Altura do olho | 18,5 m | 27 m | **34 m** |
| Ponto olhado no chão (x, z) | segue o herói | segue o herói | **(2; 1)** |
| Posição do olho (x, y, z) | | | **(35,8; 34,0; 49,2)** |
| Largura de chão vista no meio da tela | 28 m | 41 m | 51 m |
| Proporção do quadro | 16:9 | 16:9 | **16:9** (1920 x 1080 na captura) |

Por que 68 m e não o enquadramento da pintura aprovada: a pintura do ChatGPT corta o canto sul do piso. A projeção
precisa do piso inteiro de 32 x 30 m dentro do quadro, com folga. Com 68 m o piso todo cabe e ainda sobra a fachada.

Eixos do jogo: x para leste, z para o sul, y para cima; o piso vai de x -16 a 16 e de z -15 a 15.

## Onde cada coisa cai no quadro da pintura (% da largura, % da altura, a partir do canto superior esquerdo)

O piso aparece como um losango torto. Conferido com a projeção da câmera acima.

| Marco | Posição no jogo (x; z) | No quadro |
|---|---|---|
| Canto NO do piso (fundo, topo do losango) | (-16; -15) | 42%, 19% |
| Canto NE (ponta direita) | (16; -15) | 88%, 42% |
| Canto SE (ponta de baixo) | (16; 15) | 59%, 95% |
| Canto SO (ponta esquerda) | (-16; 15) | 5%, 52% |
| Porta D1 (centro do vão, no chão) | (7,6; -15) | 74%, 35% |
| Porta D2 | (11,8; -15) | 81%, 38% |
| Topo do vão de D1 (5,2 m) | (7,6; -15), altura 5,2 | 75%, 20% |
| Plataforma das estátuas (1 m de altura, degraus) | x -6,5 a 5,5; z -15 a -20 | em torno de 63%, 25% |
| Cabeça da estátua do meio | (-0,4; -17), altura 6 | 64%, 11% |
| Topo da fachada (10,5 m) | z -20 | 68%, sai pelo topo (-5%): a fachada é cortada, tudo bem |
| Entrada (boca sul-oeste) | (-11,6; 15) | 11%, 57% |
| Fim do patamar de entrada | (-11,6; 20,5) | 2%, 66% |
| Córrego, poça norte | (-8; -9) | 46%, 30% |
| Córrego, curva | (-10; -1) | 35%, 37% |
| Córrego, poça sul | (-11; 9) | 21%, 48% |
| Entulho baixo O1 / O2 / O3 | (-11; -3) / (10; 1) / (8; 10) | 36%, 34% / 64%, 58% / perto de 53%, 72% |
| Centro calmo (7,5 m de raio sem nada) | (-2,5; 1) | 43%, 46% |

Bordas do losango: **noroeste para nordeste (borda de cima à direita) é a parede norte** com a fachada, as estátuas
e as duas portas; **noroeste para sudoeste (cima à esquerda) é a borda oeste** sobre o abismo; **sudoeste para sudeste
(baixo à esquerda) é a borda sul**, com a entrada perto da ponta esquerda; **nordeste para sudeste (baixo à direita) é
a borda leste**.

## Luz (a mesma da Godot, para a pintura e os personagens 3D concordarem)

- Chave quente dourada vinda do **noroeste e do alto** (luz no jogo em (-22; 18; -20) mirando o centro): no quadro ela
  vem **de cima e um pouco da esquerda, por trás da fachada**. A sala é levemente contraluz: sombras de pilares e
  balaustradas caem **para baixo e para a direita** do quadro (para o sudeste). Manchas de luz largas e suaves.
- Preenchimento frio fraco do alto da frente (jogo (0; 14; 10)): as sombras são azul-petróleo, nunca pretas.
- Tocha entre as duas portas (jogo (9,7; 3,4; -13,4)): poça âmbar pequena no chão diante delas.
- Braseiros e velas só nas bordas; metade das velas apagadas.
- Nenhuma sombra de personagem, nenhuma luz de efeito, nenhum brilho de porta.

## Capturas que a sessão principal tira do jogo (base de composição)

Uma por vez, na placa de vídeo, depois copiadas para `C:\Users\danie\Downloads\ASelagem-GP8\02_sala01\`:

1. **C1, base estilizada** (a principal):
   `RES=1920x1080 tools/gpu.sh shot <scratchpad>/gp8_sala01_base.png --showcase --cam-at=2,1 --cam-dist=68 --no-hud --no-angels --hero-at=-15,20 --seed=5 --nosave --shot-at=1`
2. **C2, base clássica** (formas mais limpas, menos textura; segunda opção para o Retexture):
   o mesmo comando com `--look=classic` e saída `gp8_sala01_base_classico.png`.

Conferir nas duas: sem HUD; herói no canto esquerdo do patamar (perto de 1%, 66%; se aparecer, tudo bem, ele é
apagado no Editor); nenhum inimigo, anjo, medalhão de porta ou efeito no quadro (se aparecer, repetir com
`--shot-at=0.6`); as duas portas fechadas; os quatro cantos do piso nos lugares da tabela acima (diferença de até 2%).
Se a sala que abre com `--showcase` não for o Salão (ou vier com o riacho de esquiva da Antessala), repetir com
`--start=fountain` e avisar o art-director, porque a fonte entra no quadro.

## Como usar a captura no Midjourney

**Caminho 1 (o principal): Editor, Retexture.** Ele mantém a estrutura (bordas, volumes, perspectiva) da imagem
enviada e repinta as superfícies; é o que garante o ângulo exato.
1. No site, abra **Edit** e envie a C1 (`gp8_sala01_base.png`).
2. Apague com a borracha o herói no canto esquerdo, se ele aparecer (o Retexture repinta o buraco).
3. Clique em **Retexture**, cole o prompt P1 abaixo (com o `--sref` da série) e gere.
4. Escolha pelo critério deste arquivo; faça Upscale (Subtle).
5. Se a pedra sair com textura demais ou os volumes mudarem, repita com a C2 (clássica).

**Caminho 2 (só se o Retexture não existir na sua versão): imagem como referência.** Cole a URL da C1 no começo do
prompt P1 e acrescente `--iw 3`. O Midjourney respeita menos a composição assim: a chance de alinhar é baixa, e a
imagem só serve se passar no teste de sobreposição abaixo.

**Teste de sobreposição (obrigatório, a sessão principal faz):** pôr a pintura a 50% de opacidade por cima da C1. Os
quatro cantos do piso, as duas portas, a borda da plataforma das estátuas e a linha da balaustrada têm de coincidir
com diferença de até 1% da largura (19 px em 1920). Se não coincidir, não serve para projeção, por mais bonita que
seja (pode virar arte de tela de carregamento).

## Prompt P1 (Retexture sobre a C1, ou com a C1 como imagem de referência)

```
Hand-painted stylized game environment, the entrance hall of an ancient catacomb on a stone platform floating over a misty abyss, high three-quarter top-down view, mild perspective, the square floor seen as a tilted diamond, keep the exact layout and camera of the reference image. Wide worn slate flagstone floor in irregular slabs with pale clearings, calm and mostly empty in the middle, low painted detail in the center so figures stay readable. Along the upper right edge, a monumental carved stone facade with three arched niches holding hooded stone statues on a raised dais with a short flight of steps, and further right two tall arched doorways at floor level, closed, dark weathered wooden double doors with iron bands, plain stone frames, a small torch between them. Along the upper left edge, a low stone balustrade over the abyss, layers of ruined arcades fading into cold blue fog beyond. A shallow narrow stream of water winding along the left side of the floor from a small pool near the back to a small pool near the front, mossy wet edges, faint golden reflections. Low stone balustrades with square posts along the lower edges, two iron braziers and small clusters of candles at the corners, about half unlit, a few clay urns against the walls, three low patches of mossy rubble. Faded carmine banners without any insignia on the facade. Warm golden light from the upper left behind the facade, soft broad light pools, shadows falling toward the lower right, cool teal-grey fill in the shadows, no character shadows. Painterly brushwork with visible confident strokes, simplified chunky shapes, cool slate-blue stone, tarnished old gold accents, muted moss green, adventure fantasy mood, not horror, no characters --ar 16:9 --stylize 80 --chaos 5 --raw --sref SREF_URLS --sw 250 --no text, letters, runes, symbols on the floor, floor emblem, medallion, circle on the floor, lion, cross, crucifix, halo, sun emblem, star rays, glowing door, portal, purple, violet, emerald, neon green, people, characters, hero, enemies, blood, gore, photorealistic, anime
```

Variante P1b (se a pintura ficar escura demais ou laranja demais): troque `Warm golden light from the upper left` por
`Gentle warm golden light from the upper left, overall mid-value scene, cool daylight-like fill` e mantenha o resto.

## Critérios de aceite da Sala 01 (além do `05_criterios_aceite.md`)

Aprova (precisa de todos):
1. Passa no teste de sobreposição (cantos, portas, dais, balaustrada a até 1% de diferença).
2. Piso inteiro de 32 x 30 m dentro do quadro e legível; o centro (43%, 46%, com uns 7,5 m de raio) é calmo, sem
   objetos, sem manchas fortes, valor médio (lajes entre #494D56 e #77736D).
3. Duas portas fechadas, de madeira escura, ao rés do chão, lado a lado na parede norte, separadas por alvenaria,
   sem escada, sem brilho, sem ícone.
4. Água rasa só no lado oeste, no traçado da tabela, sem cachoeira e sem ponte.
5. A luz bate com a da Godot: quente de cima à esquerda, sombras para baixo à direita, sombras frias.
6. Fachada com nichos e estátuas encapuzadas (iguais às de hoje), sem estátua gigante à esquerda.

Reprova (qualquer uma):
- Personagem, inimigo, silhueta humana ou sombra de figura; ícones flutuando; quebráveis no meio do piso.
- Qualquer símbolo no chão (círculo, medalhão, leão, runa), leão em qualquer lugar, cruz, sol, auréola.
- Violeta (inclusive a porta violeta da pintura antiga), esmeralda, portal aceso.
- Colunas altas ou entulho alto dentro do piso (o jogo não tem colisão neles; o jogador acharia parede invisível).
- Perspectiva diferente (losango mais achatado ou mais alto, horizonte visível, piso inclinado).
- Velas ou braseiros dentro do piso andável fora das bordas.

## Depois da pintura aprovada (para a sessão principal)

Entregar a pintura, a C1 e os números deste arquivo ao `technical-artist` para o teste de projeção (a pintura como
textura projetada pelo olho (35,8; 34,0; 49,2) olhando (2; 0; 1), campo vertical 24°, 16:9, sobre a geometria do Salão;
material sem luz própria, personagens com as luzes atuais). Densidade: o upscale de 2x dá uns 2900 px de largura para
51 m, perto de 57 px por metro, contra 69 px por metro da câmera Perto em 1080p: um pouco mais macio. Se a
comparação lado a lado mostrar o piso borrado, gerar depois duas pinturas de metade (norte e sul) com o mesmo
processo e `--cam-dist=45`.
