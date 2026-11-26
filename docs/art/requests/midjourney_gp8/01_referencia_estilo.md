# 01. Referência de estilo da série (o `--sref` fixo)

Objetivo: um "pintor" só para salas, peças, personagens, ícones e texturas. Estas imagens **não entram no jogo**; elas
viram o `--sref` de tudo o que vem depois. Gere cada prompt 2 ou 3 vezes (rodadas novas, sem seed), escolha as
melhores e fique com **3 ou 4 no total**, de prompts diferentes (uma de vista ampla, uma de material, uma de luz de
vela, e opcionalmente a do personagem).

O alvo de qualidade é o do modelo "cenário pintado à mão sobre geometria simples, personagem 3D com textura pintada":
formas grandes e simples, pincelada visível mas controlada, valores bem separados, nada de fotografia, nada de
render plástico.

## Paleta-alvo (do pacote da Sala 01 e do `docs/art/art_direction.md`)

| Cor | Papel |
|---|---|
| #222B38 | abismo, sombras profundas |
| #494D56 | pedra fria de base (ardósia) |
| #77736D | lajes iluminadas, relevo gasto |
| #53613B | musgo e vegetação contida |
| #536F7A | água, névoa fria |
| #B78647 | ouro velho, metal gasto |
| #F3C47D | luz de vela e braseiro (acento, nunca o ar inteiro) |

O Midjourney não lê códigos de cor com exatidão; os prompts descrevem a paleta em palavras. A conferência é a olho
contra esta tabela (critério 3 abaixo).

## Bloco comum (já está dentro de cada prompt; aqui só para você reconhecer)

`hand-painted stylized game art, painterly brushwork with visible confident strokes, simplified chunky shapes, clean
readable silhouettes, cool slate-blue stone, deep teal-grey shadows, warm amber candlelight accents, tarnished old gold
trim, muted moss green, soft cold mist, adventure fantasy mood, not horror`

`--no` comum: `text, letters, runes, logo, watermark, signature, cross, crucifix, halo, sun emblem, star rays, purple,
violet, neon green, blood, gore, photorealistic, 3d render plastic, anime`

---

## R1. Vista ampla: salão das catacumbas sobre o abismo (a mais importante)

```
Hand-painted stylized game environment concept, an ancient underground catacomb hall of Valmor built on a stone platform floating over a misty abyss, seen from a high three-quarter top-down angle with a long telephoto lens, broad worn slate flagstone floor with a calm empty center, low stone balustrades along the edges, a monumental carved facade with arched niches and hooded stone statues at the far side, distant ruined arcades fading into cold blue fog, warm amber candle clusters and two iron braziers only at the edges, a faint shaft of warm light from the upper left, moss in the cracks, a few ochre leaves, painterly brushwork with visible confident strokes, simplified chunky shapes, clean readable silhouettes, cool slate-blue stone, deep teal-grey shadows, tarnished old gold accents, muted moss green, adventure fantasy mood, not horror, no characters --ar 16:9 --stylize 150 --chaos 20 --raw --no text, letters, runes, logo, watermark, signature, cross, crucifix, halo, sun emblem, star rays, purple, violet, neon green, blood, gore, people, characters, photorealistic, anime
```

## R2. Estudo de material: piso e pedra de perto

```
Hand-painted stylized texture study of catacomb stone, close top-down view of worn slate flagstones of irregular sizes with dark grout, chipped rounded edges, pale worn clearings where feet passed, thin moss and tiny ferns in the cracks, a shallow puddle reflecting warm candlelight, a strip of tarnished old gold inlay along a carved stone kerb, painterly brushwork with visible confident strokes, value grouped in big shapes, low noise, cool slate-blue and grey stone, deep teal-grey shadows, muted moss green, warm amber accents, adventure fantasy game art, not horror --ar 16:9 --stylize 100 --chaos 15 --raw --no text, letters, runes, symbols, emblem, logo, watermark, cross, crucifix, halo, sun emblem, purple, violet, neon green, blood, photorealistic, photo texture, noise
```

## R3. Luz de vela: nicho com velas e ossário

```
Hand-painted stylized game art, a carved stone wall niche in an ancient catacomb, rows of clean ivory skulls and bones neatly stacked in the niche like an old ossuary, many melted candles on the ledge, about half of them unlit, warm amber candle glow falling on cool slate stone, strong separation between warm light and deep teal-grey shadow, a dusty tarnished gold candelabra, a faded carmine cloth without any insignia, soft floating dust in the light, painterly brushwork with visible confident strokes, simplified chunky shapes, adventure fantasy mood, calm and reverent, not horror --ar 16:9 --stylize 120 --chaos 15 --raw --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, purple, violet, neon green, blood, gore, rotting, photorealistic, anime
```

## R4. Profundidade: arcadas no abismo

```
Hand-painted stylized game environment, view across a deep underground abyss, several layers of ancient stone arcades and broken bridges receding into cold blue-grey fog, each layer lighter and less detailed with distance, warm amber light shafts slicing through the arches from the upper left, floating dust motes, a stone balustrade in the foreground in silhouette, moss and small red-ochre leaves on the ledges, painterly brushwork with visible confident strokes, simplified chunky shapes, cool slate-blue stone, deep teal-grey shadows, adventure fantasy mood, not horror, no characters --ar 16:9 --stylize 150 --chaos 20 --raw --no text, letters, logo, watermark, cross, crucifix, halo, sun emblem, purple, violet, neon green, people, characters, photorealistic, anime
```

## R5. Natureza-morta de adereços

```
Hand-painted stylized game prop still life on a catacomb floor, clay urns and amphorae of different heights, an iron candelabra with melted candles, a small pile of fallen masonry rubble with moss, a worn wooden chest with tarnished old gold fittings, a faded carmine banner without any insignia hanging from an iron rod, cool slate stone background, warm amber candle light from the left, chunky simplified shapes, clear silhouettes, painterly brushwork with visible confident strokes, deep teal-grey shadows, muted moss green, adventure fantasy game art, not horror --ar 16:9 --stylize 120 --chaos 15 --raw --no text, letters, runes, emblem, logo, watermark, cross, crucifix, halo, sun emblem, purple, violet, neon green, blood, photorealistic, anime
```

## R6. Teste de personagem pintado (como a pincelada trata uma figura)

```
Hand-painted stylized 3D game character, an armored skeleton warrior standing in a relaxed guard pose, ivory bones, dented dark steel round helmet and one pauldron, faded rust-red rag cloth at the waist and neck, a notched short blade, hand-painted texture with soft painted lighting baked into the colors, chunky readable proportions, clean silhouette, three-quarter view, standing on a small patch of slate flagstones, cool teal-grey shadows, warm amber rim light, painterly brushwork with visible confident strokes, adventure fantasy mood, not horror, plain dark background --ar 3:2 --stylize 120 --chaos 10 --raw --no text, letters, logo, watermark, cross, crucifix, halo, sun emblem, purple, violet, neon green, glowing eyes, blood, gore, photorealistic, anime
```

---

## Como escolher as 3 ou 4 do `--sref`

Aprova (precisa de todas):
1. Pincelada visível e **a mesma** nas imagens escolhidas (ponha as candidatas lado a lado: parecem do mesmo pintor?).
2. Formas grandes e simples; dá para ler a silhueta de cada coisa reduzindo a imagem a 25%.
3. Paleta: pedra fria cinza-azulada domina; âmbar só em pontos (velas, braseiros, fachos); musgo apagado; nenhuma área
   grande saturada.
4. Sombras azul-petróleo escuras, não pretas chapadas nem marrons.

Reprova (qualquer uma):
- Violeta/roxo em qualquer área visível, verde neon, cruz, auréola, sol ou estrela de raios, leão, texto ou runas.
- Aparência de foto, de render 3D liso, de anime ou de pixel art.
- Ar inteiro alaranjado (o pôr do sol dentro da catacumba); névoa roxa.
- Terror: sangue, carne, caveira gritando, escuridão total.
- Detalhe miúdo em toda parte (ruído); a pedra precisa ter áreas calmas.

Teste final do `--sref`: rode o R1 de novo **com** `--sref SREF_URLS --sw 250` e duas seeds. Se as duas saírem do
mesmo pintor e com a mesma paleta, o `--sref` está pronto; anote no `gp8_sref.txt`.
