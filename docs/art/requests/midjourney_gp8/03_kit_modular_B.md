# 03. Kit modular (técnica B, para comparar com a A)

A ideia: 10 peças de catacumba geradas como folha de referência no Midjourney e depois transformadas em 3D (Meshy,
Rodin ou Tripo, com textura pintada), para montar a Sala 01 por peças em vez de projetar uma pintura. As folhas são
referência; nenhuma imagem daqui entra no jogo direto. **Gerar o 3D gasta créditos e precisa do seu sim** (a estimativa
vem antes, pelo `docs/art/meshy_asset_plan.md`).

## Regras das folhas (o que os geradores 3D precisam)

- Uma peça por imagem, inteira, centrada, sem cortar nas bordas, sem chão em volta, sem outras peças.
- Fundo cinza claro liso; luz neutra e uniforme; **sem sombra projetada** (a sombra vira textura e suja o 3D).
- Três vistas lado a lado: frente, três-quartos, lado (ortográficas, mesma escala, mesma altura de base).
- Textura pintada à mão com a luz suave já pintada (como a pedra das imagens do `--sref`), mas sem luz de vela
  colorida forte: o 3D recebe a luz da sala na Godot.
- Medidas reais (do jogo, em metros) estão em cada prompt para o gerador e o technical-artist acertarem a escala.
- Todos levam `--sref SREF_URLS --sw 200` (o mesmo pintor) e `--ar 3:2`.

`--no` comum das peças: `text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic`
(o leão sai do `--no` só na peça K9).

---

## K1. Parede de cantaria (4 m de largura, 5 m de altura, 1 m de espessura)

```
Game asset reference sheet, one modular catacomb wall segment, ancient slate-grey ashlar masonry blocks of uneven sizes, chipped worn edges, thin moss in the lower joints, a simple carved cornice at the top and a plinth at the base, proportions 4 meters wide by 5 meters tall by 1 meter thick, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone, muted moss green --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K2. Arco de porta (vão livre 3,0 x 5,2 m, moldura 0,3 m)

```
Game asset reference sheet, one modular stone doorway arch for a catacomb, round-topped arch with a ring of wedge-shaped voussoir stones, plain stone jambs 0.3 meters wide, clear opening 3 meters wide and 5.2 meters tall, the opening is empty and open through, no door, worn edges, a little moss at the base, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone, tarnished old gold keystone detail --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, symbols, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, glowing portal, cast shadow, background scenery, people, photorealistic
```

## K3. Pilar (1 x 1 m de base, 6 m de altura)

```
Game asset reference sheet, one square stone pillar for a catacomb hall, 1 meter wide and 6 meters tall, simple stepped base and capital, slightly weathered slate-grey stone blocks, one chipped corner, thin moss at the foot, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K4. Piso (textura de lajes, vista de cima, para repetir)

Esta é textura, não modelo: vista de cima, quadrada, para o technical-artist tornar repetível. Se a sua versão
recusar o `--tile`, apague só esse parâmetro; a costura é feita depois na Godot.

```
Seamless tileable game floor texture, top-down orthographic view, worn slate flagstones of irregular rectangular sizes about 1 to 2 meters each, dark narrow grout, rounded chipped edges, pale worn clearings, very sparse thin moss in a few cracks, calm low-contrast mid-value surface so characters stay readable on it, flat even lighting, no shadows, no perspective, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue and grey stone --ar 1:1 --tile --stylize 50 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, symbols, emblem, medallion, circle, logo, watermark, cross, crucifix, halo, sun emblem, lion, purple, violet, emerald, neon green, blood, perspective, objects, people, photorealistic, photo texture
```

## K5. Degrau e lance de escada (degrau de 4 m de largura, 0,25 m de altura, 0,6 m de piso)

```
Game asset reference sheet, one short flight of four wide stone steps leading up to a 1 meter high dais, each step 4 meters wide, 0.25 meters high and 0.6 meters deep, worn rounded nosing on each step, slate-grey stone with pale worn treads, plain stone side cheeks, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K6. Balaustrada (trecho de 4 m, 1 m de altura, pilaretes quadrados nas pontas)

```
Game asset reference sheet, one modular stone balustrade segment, 4 meters long and 1 meter tall, a square stone post at each end with a simple cap, a row of short turned balusters between a base rail and a top rail, one baluster broken, weathered slate-grey stone, a little moss and a few red-ochre leaves on the rail, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K7. Nicho de ossos (2 m de largura, 2,5 m de altura, 0,8 m de fundo)

Osso limpo, arrumado, sem gore (regra do jogo: aventura, não terror; "pó de osso", não sangue).

```
Game asset reference sheet, one carved stone wall niche used as an ossuary, 2 meters wide, 2.5 meters tall, 0.8 meters deep, round-topped, filled with neatly stacked clean ivory skulls and long bones in tidy rows, a stone ledge at the bottom with a few melted candles, weathered slate-grey stone frame, dust, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, calm and reverent, not horror --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, gore, rotting flesh, glowing eyes, cast shadow, background scenery, people, photorealistic
```

## K8. Vela e castiçal (castiçal de ferro de 1,6 m; grupo de velas de chão)

```
Game asset reference sheet, one tall wrought iron floor candelabra 1.6 meters tall with five arms and melted ivory candles, plus a separate small cluster of seven melted floor candles of different heights, two of them unlit, tarnished old gold drip trays, small warm amber flames, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K9. Estátua leonina (2,5 m com o pedestal), só para lugar amigo

O leão é o símbolo do herói (Hanokh e Elun, cânone). **Esta peça não vai na Sala 01** (território inimigo, decisão do
pacote da sala); serve ao Santuário e a lugares amigos. Leão sereno e nobre, não monstro; sem asas, sem coroa com cruz,
sem auréola.

```
Game asset reference sheet, one stone statue of a noble seated lion on a square plinth, 2.5 meters tall including the plinth, calm dignified pose, head raised, mane carved in chunky stylized locks, weathered pale slate stone with tarnished old gold traces in the carved grooves, a little moss on the plinth, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, wings, crown, roaring, purple, violet, emerald, neon green, blood, cast shadow, background scenery, people, photorealistic
```

## K10. Entulho (mancha baixa até 0,3 m e um monte de 1 m)

O baixo é o que entra no piso (O1 a O3, sem colisão); o de 1 m só fora da área andável.

```
Game asset reference sheet, two piles of fallen catacomb masonry rubble: a low flat scatter of broken slate-grey stone fragments no taller than 0.3 meters and about 2.5 by 2 meters wide, with moss and a few red-ochre leaves, and a separate larger heap about 1 meter tall with a broken column drum and chunks of carved cornice, shown in three orthographic views side by side: front view, three-quarter view, side view, same scale, centered, full objects visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky simplified shapes, cool slate-blue stone, muted moss green --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 200 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, purple, violet, emerald, neon green, blood, bones, cast shadow, background scenery, people, photorealistic
```

---

## Critérios de aceite das peças (além do `05_criterios_aceite.md`)

Aprova:
1. Uma peça só, inteira, nas três vistas coerentes (mesma peça, mesmas proporções, mesma base).
2. Proporção visível bate com as medidas do prompt (a parede é mais alta que larga só se o prompt diz; o degrau baixo;
   o entulho baixo é realmente baixo).
3. Pedra da mesma família do `--sref` (a K1 e a K3 lado a lado parecem do mesmo lugar).
4. Fundo liso e sem sombra projetada.

Reprova:
- Peça cortada pela borda, vistas que não combinam (a de lado tem outro desenho), mais de uma peça misturada.
- Sombra no chão, cenário atrás, luz colorida forte.
- Símbolo, runa, texto, cruz, sol; leão fora da K9; violeta ou esmeralda.
- Textura fotográfica ou ruído miúdo em toda a superfície.
- K4: não repete sem costura (abra no site a opção de ver em mosaico) ou tem um desenho central que vira padrão
  repetido visível.
