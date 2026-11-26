# 04. Personagens: folhas de modelo para gerar 3D

Objetivo: frente, lado e costas de cada personagem, coerentes entre si, para o teste Meshy x Rodin x Tripo (as mesmas
imagens nas três ferramentas). Textura pintada, proporção de jogo, pose que os geradores entendem. **Gerar o 3D gasta
créditos e precisa do seu sim.**

## Como gerar (vale para os 4)

1. **Frente primeiro**, `--ar 2:3`, 2 a 4 rodadas. Escolha a melhor, faça Upscale (Subtle) e anote a seed.
2. **Lado e costas** com a frente escolhida como referência de personagem: arraste a frente para a barra do prompt e
   marque como **Omni Reference** (vira `--oref URL`), com `--ow 250`, e use a **mesma seed** da frente. Troque só a
   linha da vista (`front view` para `left side view, profile facing left` ou `back view`).
3. Se o lado ou as costas trocarem armadura, cor ou cabelo, suba o `--ow` para 400 e tente de novo; acima disso o
   Midjourney copia a pose da frente (fica de frente de novo), então pare em 400.
4. Salve `gp8_char_<nome>_frente_NN.png`, `..._lado_NN.png`, `..._costas_NN.png`.

Regras para os geradores 3D: corpo inteiro com os pés visíveis, pose em A (braços abertos uns 30° do corpo, mãos
abertas, pernas levemente afastadas), câmera ortográfica na altura do peito, fundo cinza claro liso, luz neutra e
uniforme, **sem sombra no chão**, sem cenário, sem efeito brilhando, sem arma na mão (a arma é uma folha à parte:
armas finas na mão estragam o 3D e o jogo já prende a arma no osso da mão).

`--no` comum: `text, letters, logo, watermark, cross, crucifix, halo, sun emblem, star rays, purple, violet, neon green, glowing eyes, blood, gore, weapon in hand, cast shadow, background scenery, dynamic pose, photorealistic, anime`

---

## P1. O Guerreiro (herói)

Fonte: a prancha aprovada `docs/art/ref/warrior_art_bible.png` (as três figuras de corpo inteiro). Preservar:
**cabelo vermelho longo**, **cachecol e manto azul-petróleo**, armadura de placas de aço escuro com **filete de ouro
velho**, couro marrom, botas, silhueta já aprovada. **Trocar o sol do peito e do manto pelo leão** (o símbolo do herói;
o sol não pode, D-66). Nada de "Punho de Elun" nem texto.

Referência opcional: a sessão principal recorta as três figuras de corpo inteiro da prancha num arquivo
`gp8_ref_guerreiro_prancha.png` (sem o resto da prancha, sem o texto) e manda para a pasta `04_personagens`. Use-o como
`--oref` **só na frente**, com `--ow 150`; se o sol da prancha aparecer no resultado, reprova (o prompt pede o leão).

Frente:
```
Character model sheet for 3D modeling, full body front view, a young human paladin warrior, long flowing red hair tied back loosely, determined face, clean-shaven, a teal petrol-blue scarf wrapped around the neck and a long teal petrol-blue cloak, dark steel plate armor with tarnished old gold trim on the edges, layered pauldrons, brown leather straps and belt, armored gauntlets, dark trousers and leather boots, a small embossed lion head emblem in old gold on the chest plate, an empty sword scabbard at the hip, A-pose with arms 30 degrees from the body, open hands, feet slightly apart, orthographic camera at chest height, heroic stylized proportions about seven heads tall, hand-painted stylized texture with soft painted shading, clean readable silhouette, plain flat light grey background, even neutral lighting, no cast shadow --ar 2:3 --stylize 80 --chaos 5 --raw --sref SREF_URLS --sw 120 --no text, letters, logo, watermark, cross, crucifix, halo, sun emblem, star rays, eight-pointed star, purple, violet, neon green, emerald armor, glowing eyes, blood, gore, weapon in hand, helmet, cast shadow, background scenery, dynamic pose, photorealistic, anime
```

Lado: a mesma linha, trocando `full body front view` por `full body left side view, profile facing left`, mais
`--oref FRENTE_URL --ow 250 --seed SEED_DA_FRENTE`.
Costas: trocando por `full body back view, cloak and hair seen from behind, a plain teal cloak without any symbol`, mais
os mesmos `--oref`, `--ow` e `--seed`.

Arma à parte, a Emeth (a única coisa esmeralda viva do jogo):
```
Game asset reference sheet, one longsword lying flat, a straight blade of translucent emerald green crystal with a faint inner glow along the edges, an ornate guard and pommel of tarnished old gold, a dark leather-wrapped grip, about 1.1 meters long, shown in two orthographic views: front view and side view, same scale, centered, full object visible, plain flat light grey background, even neutral lighting, no cast shadows, hand-painted stylized texture with soft painted shading, chunky readable shapes --ar 3:2 --stylize 60 --chaos 0 --raw --sref SREF_URLS --sw 120 --no text, letters, runes, logo, watermark, cross, crucifix, halo, sun emblem, star rays, purple, violet, cast shadow, background scenery, hand, people, photorealistic
```

## P2. Esqueleto comum

Da prancha da fase 1: osso marfim apagado, elmo redondo de aço, uma ombreira, trapos vermelho-ferrugem apagados na
cintura e no pescoço (nunca o vermelho vivo do perigo). Altura de uns 1,9 m. Proporção humana, não cabeçuda.

```
Character model sheet for 3D modeling, full body front view, an undead skeleton soldier, dull ivory bones with clean simple shapes, a dented dark steel round helmet, a single dark steel pauldron on the left shoulder, faded rust-red rag cloth tied at the waist and a torn rust-red scarf at the neck, dark empty eye sockets, about 1.9 meters tall with human proportions, A-pose with arms 30 degrees from the body, open bony hands, feet slightly apart, orthographic camera at chest height, hand-painted stylized texture with soft painted shading, clean readable silhouette, adventure fantasy, not horror, plain flat light grey background, even neutral lighting, no cast shadow --ar 2:3 --stylize 80 --chaos 5 --raw --sref SREF_URLS --sw 120 --no text, letters, logo, watermark, cross, crucifix, halo, sun emblem, star rays, purple, violet, neon green, emerald, glowing eyes, blood, gore, rotting flesh, weapon in hand, shield, cast shadow, background scenery, dynamic pose, photorealistic, anime
```

## P3. Capitão esqueleto (elite que chama ajudantes)

No jogo ele é grande (uns 1,95 vezes o esqueleto em escala de prancha; trate como 2,3 m), pesado, não é empurrado, usa
escudo grande e o aço das elites é ouro velho. Mesma família do esqueleto comum, mais armadura. Sem insígnia no
tabardo (território inimigo, sem símbolo novo).

```
Character model sheet for 3D modeling, full body front view, a large undead skeleton captain, broad heavy frame about 2.3 meters tall, dull ivory bones visible at the face, arms and legs, heavy dark steel breastplate and layered pauldrons with tarnished old gold trim, an open-faced dark steel helmet with a short crest, a long faded rust-red tabard without any insignia, a large rectangular tower shield strapped on the back, dark empty eye sockets, commanding upright stance, A-pose with arms 30 degrees from the body, open gauntleted hands, feet apart, orthographic camera at chest height, hand-painted stylized texture with soft painted shading, clean readable silhouette, adventure fantasy, not horror, plain flat light grey background, even neutral lighting, no cast shadow --ar 2:3 --stylize 80 --chaos 5 --raw --sref SREF_URLS --sw 120 --no text, letters, emblem, insignia, logo, watermark, cross, crucifix, halo, sun emblem, star rays, lion, skull emblem, purple, violet, neon green, emerald, glowing eyes, blood, gore, rotting flesh, weapon in hand, cast shadow, background scenery, dynamic pose, photorealistic, anime
```

Escudo à parte (se o gerador não separar): `Game asset reference sheet, one large rectangular tower shield of dark riveted steel with tarnished old gold rim, dented, no emblem, front and side orthographic views ...` com o mesmo fim de prompt das armas.

## P4. Cavaleiro (guardião de minichefe)

Da prancha da fase 1: elmo fechado com coroa de pontas, capa vermelha (apagada, ferrugem), placas esculpidas de aço com
ouro, espada e escudo. Uns 2,1 m. As pontas da coroa são retas e simples, nunca em forma de cruz.

```
Character model sheet for 3D modeling, full body front view, an imposing undead knight, tall and broad about 2.1 meters, a closed great helm with a ring of short straight spikes like a crude crown, no face visible, only darkness behind the visor slit, sculpted dark steel plate armor with tarnished old gold filigree on the edges, a long heavy faded rust-red cape, chainmail at the joints, a round dark steel shield with gold rim and no emblem strapped on the back, A-pose with arms 30 degrees from the body, open gauntleted hands, feet apart, orthographic camera at chest height, hand-painted stylized texture with soft painted shading, clean readable silhouette, adventure fantasy, not horror, plain flat light grey background, even neutral lighting, no cast shadow --ar 2:3 --stylize 80 --chaos 5 --raw --sref SREF_URLS --sw 120 --no text, letters, emblem, insignia, logo, watermark, cross, crucifix, cross-shaped spikes, halo, sun emblem, star rays, lion, horns, purple, violet, neon green, emerald, glowing eyes, blood, gore, weapon in hand, cast shadow, background scenery, dynamic pose, photorealistic, anime
```

Espada do Cavaleiro à parte: `Game asset reference sheet, one heavy straight broadsword of dark notched steel with a plain tarnished old gold crossguard and pommel, about 1.3 meters long, front and side orthographic views ...` com o mesmo fim de prompt das armas (aqui `crossguard` é a guarda da espada, normal; a reprovação é cruz como símbolo).

---

## Critérios de aceite dos personagens (além do `05_criterios_aceite.md`)

Aprova (precisa de todos):
1. Corpo inteiro, pés visíveis, pose em A, mãos vazias, fundo liso, sem sombra no chão.
2. Frente, lado e costas são **o mesmo personagem**: mesmas cores, mesma armadura, mesmo cabelo, mesma altura.
3. Lado é perfil de verdade (não três-quartos); costas mostram as costas (não o rosto).
4. Guerreiro: cabelo vermelho, cachecol e manto petróleo, aço escuro com ouro velho, leão pequeno no peito (ou peito
   liso); legível como "o herói" ao lado da prancha aprovada.
5. Inimigos lêem como família (o Capitão é o esqueleto promovido; o Cavaleiro é outro patamar), osso marfim apagado,
   pano ferrugem apagado, aço escuro.
6. Proporção humana (cabeça de 1/7 a 1/7,5 da altura), não o boneco cabeçudo do KayKit.

Reprova (qualquer uma):
- Sol, estrela de raios ou cruz em qualquer peça (inclusive o sol da prancha no peito ou no manto do Guerreiro).
- Verde esmeralda em qualquer inimigo; violeta em qualquer um dos quatro.
- Olhos acesos (o brilho é posto na Godot), sangue, carne podre.
- Arma na mão, efeito mágico, partículas, cenário.
- Vista que mudou de personagem (armadura, cor ou cabelo diferentes da frente).
- Capa ou cabelo cobrindo o corpo de um jeito que o 3D não separa (manto fechado na frente escondendo as pernas).
