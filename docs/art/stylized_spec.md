# Eterra Stylized Art: especificação visual da prova de conceito (STY-01)

- **Data**: 2026-11-18. **Autor**: art-director. **Commit lido**: `5269bfa`. **Escopo**: só o Salão das Catacumbas
  (`CatacombHall`), STY-01 a STY-09 do `docs/art/stylized_poc_plan.md`. Nada implementado aqui; nenhum crédito do Meshy.
- **Referência principal** (só local, imagem de IA, nunca asset nem evidência):
  `docs/art/ref/stylized_2026-11-18/01_referencia_principal_gameplay_stylized.png` (1328 x 746). Chamada aqui de **R1**.
- **Referência secundária** (só apoio conceitual, não se mistura com a R1):
  `docs/art/ref/stylized_2026-11-18/02_prancha_conceitual_relicarios_cripta_livro_morvath.png`. Chamada de **R2**. Dela
  vale só: estandartes petróleo com o leão em ouro velho (confirma a Q-22) e o facho frio de lua da "Cripta". O resto
  (relicários, Livro, Morvath) é de outras entregas.
- **Capturas usadas (nossas, RTX 5060, Forward+, 1920 x 1080, `--bot --autopick --seed=5 --shot-at=9`)**, no scratchpad
  da sessão: câmera do jogo (distância 54) e duas de estudo mais perto (distância 40 e 32), mais
  `docs/gallery/ap1/after/vitrine_1080.jpg` e `docs/gallery/c18/after/jogo.jpg`.
- **Como medi**: caixas de pixels na R1 e nas nossas capturas (média RGB, matiz, saturação e valor HSV, luma Rec. 709
  p10, p50 e p90) e `python3 -I tools/frame_stats.py` no quadro inteiro. Toda cor de tela abaixo é sRGB de 0 a 255; toda
  cor de material é `source_color` de 0 a 1. "Medido" é da R1 ou das capturas; "proposta" é o ponto de partida que o
  `environment-artist` ajusta até bater a medida de tela.

---

## 0. O que a R1 é, medido

| Medida | R1 | Nosso jogo hoje (d54) | Leitura |
|---|---|---|---|
| Luma média do quadro (`frame_stats`) | 67 | 54 | R1 mais clara no todo |
| Saturação média / p90 (`frame_stats`) | 8 / 15 | 13 / 23 | **R1 menos saturada**: a pintura vem do valor e da pincelada, não da cor |
| Chão aberto, centro da laje | rgb(86, 77, 59), matiz 39, sat 0,31, valor 0,34, luma 75 a 80 | rgb(44, 41, 58), matiz 244 a 252, sat 0,30, luma 44 a 49 | R1: pedra **umbra-oliva morna**; nosso chão é **lilás** e 30 níveis mais escuro |
| Variação entre lajes | luma 63 a 79 entre lajes vizinhas, matiz 35 a 40 | luma 20 a 62 dentro da mesma caixa | R1 varia por laje com borda definida; o nosso varia com ruído fotográfico |
| Juntas e vãos do chão | luma 22 a 33, 2 a 3 px a 746 (3 a 4 px a 1080) | luma 9 a 20 | R1: junta escura mas não preta; razão laje / junta de 2,5:1 |
| Sombra projetada do herói | rgb(46, 45, 41), sat 0,10, luma 40 | sombra suave, quase invisível | R1: sombra de borda definida, neutra |
| Parede em sombra | matiz 28, sat 0,16, luma p10 26, p50 52 | matiz 218, sat 0,44, luma 23 | R1: sombra **neutra quente** dentro da sala |
| Vão de porta, interior escuro | rgb(18, 20, 23), matiz 218 | | o frio da R1 fica **na profundidade** |
| Abismo | rgb(33, 51, 68), matiz 209, sat 0,51, luma 43 | rgb(25, 38, 53), matiz 211, sat 0,53 | **já bate**; o nosso só é um pouco mais escuro |
| Face de pilar ao lado do braseiro | matiz 32, sat 0,53, luma p90 145 | | a luz quente faz poça curta e definida |
| Núcleo da chama | rgb(206, 140, 68), luma p50 149, p90 193 | velas p90 219, braseiro sat 0,98 | R1: fogo âmbar **mais baixo** que o nosso |
| Miolo da meia-lua esmeralda | rgb(157 a 169, 235 a 241, 166 a 174), matiz 124 a 126, sat 0,30 a 0,33, luma 212 a 231 | | menta pálida quase marfim; matiz da Emeth (133) |
| Aviso: aro / preenchimento | aro rgb(142, 83, 58), luma 88 a 113; preenchimento rgb(117, 76, 56), luma 83 | | preenchimento translúcido que deixa a laje ver; aro só 25 níveis acima |
| Borda de luz no herói | rgb(184, 155, 124), matiz 30, luma 164 | | rim **morno** (luz da tocha), corpo escuro (luma p50 39) |
| Corpo dos personagens | herói luma p10 16, p50 39, p90 84; esqueleto p50 46, p90 120 | | corpo **mais escuro que o chão**, separado por rim e contorno |
| Herói na tela | cerca de 120 px a 746 (cerca de 174 px a 1080) | cerca de 105 px a 1080 | R1 é um enquadramento **mais perto** |
| Câmera | bordas das lajes a cerca de 17 e 32 graus da horizontal, verticais quase paralelas | giro 35, inclinação 30, campo 24 | **os ângulos batem com os nossos**; a diferença é distância (zoom) |

Conclusões que guiam tudo abaixo:
1. A câmera da R1 tem o mesmo giro e a mesma inclinação que a nossa; só está mais perto (o herói lê 1,6 vez maior). A
   câmera do jogo não muda; a captura de estudo usa só `--cam-dist` (seção 5.3).
2. A R1 é **menos saturada e mais clara** que o nosso quadro. O "pintado" vem de: valor por laje e por bloco, aresta
   clara, junta desenhada, sombra projetada definida, corpo escuro com borda de luz e contorno. Não vem de cor forte nem
   de filtro.
3. A pedra da R1 é **morna** (matiz 28 a 40); o frio fica no abismo e nos vãos. Isso contraria a nossa regra "cenário
   frio" (`art_direction.md` 1.2) e precisa da decisão do Daniel (pergunta S-Q5, seção 7). Esta especificação segue a R1
   no perfil estilizado e deixa o clássico como está.

---

## 1. Ambiente e iluminação

### 1.1 O que a R1 demonstra
- Sala lida inteira de uma vez: chão claro e calmo no meio, arquitetura escura e detalhada na moldura (paredes, nichos,
  estátuas, ponte). O valor sobe para o centro.
- Luz quente só nas fontes (braseiros em pedestal, a chama de cada um faz uma poça de 2 a 3 m com borda definida); a
  sala no meio tem uma luz geral morna e suave sem fonte visível.
- Frio só na profundidade: abismo azul sob a ponte, interior das portas e vãos. Sombras dentro da sala neutras.
- Sombras projetadas curtas e definidas sob personagens e pedestais (luz de cima, um pouco de frente).
- Ar limpo: quase nenhuma névoa sobre o chão; a atmosfera está no abismo.
- Moldura organizada: cada parede tem um papel (porta com estátuas dos dois lados e braseiros à frente, nicho com potes,
  estandarte entre pilares); o entulho fica no pé das paredes, nunca no chão de luta.

### 1.2 O que já existe em Eterra
- O salão inteiro com as mesmas classes de peças: estátuas encapuzadas, braseiros, velas, potes, balaustradas,
  estandartes, abismo com ponte a oeste, fachada com portal (`CatacombHall`, `arena_reference.md`).
- Abismo azul já no matiz e saturação da R1 (209 a 211, 0,5).
- `RoomMood` para o ar por sala, `ArenaRoom.moon_shaft` (facho com poeira), luzes de vela e braseiro, vinheta que poupa
  os claros (`screen.gdshader`), metade das velas apagadas (VX-13, C18).
- Falta: chão claro e morno, poça de luz definida, sombra projetada nítida dos personagens, sombra neutra.

### 1.3 O que reproduzir no Godot (valores)

| Item | Valor (alvo de tela medido, ou proposta de material) | Onde |
|---|---|---|
| Chão, laje no meio da sala | **tela**: luma p50 de 65 a 80, matiz 34 a 42, sat 0,22 a 0,32. **Proposta de material**: `stone_a` (0,27; 0,25; 0,21), `stone_b` (0,40; 0,36; 0,29) | `catacomb_floor.gdshaderinc` pelo perfil |
| Chão na borda da sala (2 m das balaustradas) | luma p50 de 50 a 62 (a sala escurece para fora; o meio fica o mais claro) | o mesmo, mais a luz |
| Pedra das paredes e pilares | **tela**: face iluminada luma 50 a 90, sombra 26 a 50, matiz 25 a 35, sat 0,15 a 0,35 | `masonry.gdshader` pelo perfil |
| Luz geral da sala (sem fonte) | ambiente morno-neutro: cor (0,78; 0,74; 0,68), suficiente para o chão bater o alvo sem tocha por perto; nunca a omni que clareia parede inteira (`art_direction.md` 5) | `VisualProfile`, ambiente do `WorldEnvironment` |
| Chave direcional | uma só, de cima e de trás da câmera, com sombra; cor (1,0; 0,94; 0,84); inclinação 55 a 65 graus | `CatacombHall` (só números) |
| Sombra projetada | borda definida: penumbra no máximo 0,15 m no chão (sombra direcional sem desfoque grande, `shadow_blur` 0,5 a 1,0); cor na tela luma 35 a 45 sobre laje de 75, sat até 0,12 | luz chave e `light()` do `paint.gdshaderinc` |
| Faixas de luz | três faixas na pedra e no chão: sombra 0,0 a 0,3 de N·L vira 0,42 do valor aceso; meio 0,3 a 0,65 vira 0,72; luz acima de 0,65 vira 1,0; largura da transição 0,10 (de 0,08 a 0,15), nunca degrau duro | `paint.gdshaderinc`, `light()` |
| Cor da sombra dentro da sala | multiplicador (0,92; 0,93; 0,98): matiz 220, saturação até 0,10. Quase neutra | `paint.gdshaderinc` |
| Cor da profundidade (abismo, vãos de porta, sob a ponte) | matiz 205 a 220, saturação 0,30 a 0,55, valor 0,07 a 0,27; nunca preto puro (luma mínima 15) | ambiente do abismo, `ABYSS_*` no perfil |
| Poça da tocha e do braseiro | raio útil 2,0 a 2,5 m no chão; dentro, a laje vai até luma 120 a 150, matiz 28 a 34, sat até 0,55; borda da poça marcada pela faixa de luz (não por queda suave longa): `OmniLight3D` com `omni_attenuation` 1,5 a 2,0 e `omni_range` 3,5 a 4,5 m | `CatacombHall` (só números), `light()` |
| Núcleo da chama | luma até 200, matiz 28 a 34, sat 0,55 a 0,7; nada com os três canais acima de 235 | material da chama, `ScreenTone` |
| Névoa sobre o chão | densidade da névoa volumétrica no salão a 40% da atual no perfil; a bruma fica abaixo da borda, no abismo | `VisualProfile` |
| Facho de lua (R2, opcional) | um só, sobre a metade norte, sem sombra no Compatibility, maior canal 0,6, poeira com até 20 partículas | `ArenaRoom.moon_shaft` (reuso), STY-05 |
| Estandartes | pano petróleo escuro: proposta (0,07; 0,17; 0,19), o mesmo pano do relicário do AP-1 (`RewardGem.CLOTH_COLOR`); na tela sat até 0,45 e valor até 0,25, assim fica 0,3 de valor abaixo do petróleo do herói; leão em ouro velho `banner_lion.gdshader` `gold` (0,65; 0,47; 0,18); borda rasgada em um dos dois | `ArenaKit.banner` pelo perfil |
| Vinheta | a de hoje (0,45, poupando os claros); nada a mais | `screen.gdshader` sem mudança |

Ordem do valor na tela (a regra que tudo acima serve): **meio do chão (65 a 80) > borda do chão (50 a 62) > paredes
acesas (50 a 90, só onde a tocha bate) > paredes em sombra (26 a 50) > profundidade (15 a 43)**. Personagens ficam
fora dessa escala (seção 2).

### 1.4 O que depende de mudar asset
- Paredes e pilares do KayKit do salão: tijolo de brinquedo. No perfil estilizado viram cantaria `Masonry` (já está no
  STY-05; geometria procedural, sem Meshy).
- Nichos com potes nas paredes (R1 tem nas paredes norte e leste): dá para montar com `Masonry` e os potes do KayKit,
  fora do chão andável. **Opcional** no STY-05, só se o `fit_probe` do salão não ganhar fantasma.
- Arcos sob a balaustrada sul, como a ponte da R1: o `ArenaRoom.bridge(..., arches)` já faz arcos; levar ao penhasco sul
  é geometria nova. Opcional no STY-05, mesmo critério.
- Crânios e ossos no pé das paredes: não temos modelo. **Fora** (não se gera no Meshy nesta prova).

### 1.5 Fora desta prova
- As outras salas e a Câmara do Selo (recebem uma captura cada só para provar que não quebram).
- Mudar a planta, a colisão, a posição de qualquer peça que bloqueia, ou a câmera do jogo.
- Composição da R1 (porta com estrela, porta violeta, ponte no canto sudeste): o salão segue a pintura aprovada de
  2026-11-14 (`arena_reference.md`).

---

## 2. Guerreiro e inimigos

### 2.1 O que a R1 demonstra
- Personagens com corpo de valor **médio-escuro** (luma p50 39 a 46) sobre o chão claro (75 a 80): a silhueta se separa
  pelo valor, não pela cor.
- Borda de luz morna (luma 160 a 175, matiz 30) nos ombros, no topo da cabeça e no lado da tocha; contorno escuro fino
  em volta de cada figura (cerca de 1,5 a 2 px a 746, 2 a 3 px a 1080 na escala da R1).
- Sombreamento em poucos tons: luz, meio e sombra com transição curta; detalhe pintado (fivelas, ornamentos) sem ruído
  fotográfico.
- Silhuetas expressivas: pose larga, arma grande, capa e panos soltos.

### 2.2 O que já existe em Eterra
- Guerreiro do Meshy (`hero_explorer`, `HeroBody`, `StandardMaterial3D` com preenchimento `_fill`), Emeth do Meshy
  (`emeth.gdshader`), nove inimigos e Morvath do Meshy assados (`crowd.gdshader`, luz `diffuse_lambert`, `rim_color` e
  `rim_power` já existem, hoje 0).
- Contorno escuro só das elites (`crowd_outline.gdshader`, `CrowdRenderer.OUTLINE_WIDTH` 0,022 m, cor (0,1; 0,08;
  0,06)).
- Raio-x do herói em três passes, anel petróleo, luz pintada nos ombros (`Player.KEY_LIGHT` 0,3).
- Multidão "cinza clara sobre chão escuro" (`lift`, `flat_light`): no chão claro da R1 essa regra se inverte (2.3).

### 2.3 O que reproduzir no Godot (valores)

| Item | Valor | Onde |
|---|---|---|
| Faixas no corpo | as mesmas três do cenário (1.3), transição 0,10; o corpo inteiro passa pelo `light()` do include, para herói e cenário serem pintados pela mesma mão | `paint.gdshaderinc` no `crowd.gdshader` e no `hero_paint.gdshader` novo |
| Valor do corpo na tela | herói e inimigos com luma p50 de 40 a 60 sobre o chão de 65 a 80: **mais escuros que o chão** (inverte o `lift` da multidão no perfil; `lift` 0 e `flat_light` baixo) | `crowd.gdshader` pelo perfil |
| Borda de luz (rim) | largura: fresnel de potência 3,0 a 4,0; cor morna (1,0; 0,82; 0,62) para todos; força na tela: luma 150 a 180 na borda do herói, 110 a 140 nos inimigos. O herói tem a borda mais clara da tela | `rim_color`/`rim_power` no `crowd.gdshader`; `hero_paint.gdshader` |
| Contorno | o `crowd_outline.gdshader` (casca invertida, funciona no Compatibility) em **todos** os inimigos no perfil: largura 0,04 m (1,6 px a 1080 na câmera do jogo, 2,6 px na captura de estudo); cor (0,07; 0,06; 0,06); elites continuam com a borda de ouro velho por cima. Herói: o mesmo contorno, 0,045 m, cor (0,05; 0,07; 0,08) | `crowd_outline.gdshader`, `CrowdRenderer.OUTLINE_*` pelo perfil; passe novo no `hero_paint` |
| Menos detalhe fotográfico | `paint_flat` 0,35: mistura da cor da textura com a média dela num raio de mip 3 (só o ruído some; as manchas grandes da pintura ficam) | `crowd.gdshader`, `hero_paint.gdshader` |
| Cores de cada um | não mudam: cabelo vermelho, cachecol petróleo, Emeth esmeralda; osso marfim apagado, pano ferrugem, metal escuro dos inimigos | nenhum |
| Sombra no chão | todo personagem projeta sombra da luz chave (hoje a multidão não recebe as tochas, camada 2; continua); a sombra do herói é a mais nítida | luz chave |
| O que não pode mudar | pisca do golpe abaixo do `flash_cap` 1,0; "vai bater" (`tell_light`); queimadura; ouro das elites; raio-x (`xray_depth`, `xray`, `xray_edge`) e o anel | testes `test_burn_flash.gd`, `test_hero_look.gd` |

### 2.4 O que depende de mudar asset
- Textura dos personagens pintada à mão de verdade: o shader só aplaina; o detalhe pintado do Meshy fica. Se a captura
  mostrar que destoa, o lote A do plano (`retexture`, 10 créditos cada, 12 modelos, 120) vira **estimativa** para o
  Daniel. Gasto autorizado: zero.
- Armas com silhueta própria (cutelo, foice, cajado, besta): forma, não cor. Lote C do plano, só estimativa.
- Personagens maiores na tela: depende da câmera. Não se muda; a captura de estudo mostra o efeito.

### 2.5 Fora desta prova
- Repintura, reassado, modelo novo, animação nova, troca de proporção.
- Copiar as figuras da R1 (o paladino de capa, o esqueleto com auréola de espinhos, o sacerdote de máscara): os nossos
  são os aprovados pelo Daniel.

---

## 3. Combate e efeitos

### 3.1 O que a R1 demonstra
- Meia-lua esmeralda larga com miolo menta pálido (luma 212 a 231, sat 0,30), corpo esmeralda que afina e uma cauda
  feita de **pinceladas partidas** (riscos curtos soltos na borda de trás), mais lascas esmeralda finas voando.
- Lâmina de cristal esmeralda com fio claro.
- Aviso de ataque: retângulo no chão com preenchimento translúcido vermelho-alaranjado que deixa a laje aparecer
  (luma 83 sobre laje de 75), aro fino claro (luma 88 a 113) e uma marca interna.
- Nada estoura em branco: o mais claro da tela (miolo do corte, gema, chama) fica abaixo de 235.

### 3.2 O que já existe em Eterra
- Corte em fita (`slash.gdshader` e `slash_ink.gdshader`): fio marfim-menta na borda de ataque, miolo pálido, tinta
  escura translúcida, varre em 3 quadros; onda do especial (`emeth_wave.gdshader`); lascas alongadas (`chip.gdshader`).
- Avisos com aro, preenchimento fraco até os últimos 30% (`fill_max` 0,35), mira em fio de 6 px (`AIM_PX`), divisas na
  direção do golpe, stencil sem soma.
- Tetos: `ScreenTone.SAFE` 226 e 235, glow só acima de 1,3.

### 3.3 O que reproduzir no Godot (valores)

| Item | Valor | Onde |
|---|---|---|
| Cauda do corte em pinceladas | na metade de trás da fita, o alfa é cortado por um ruído em faixas ao longo do arco: 5 a 8 riscos, cada um de 0,08 a 0,18 m de largura, sumindo em 0,12 s a partir da cauda; a borda de ataque fica inteira | `slash.gdshader`, `slash_ink.gdshader` (uniforms novas pelo perfil) |
| Miolo do corte | luma na tela 205 a 230, matiz 124 a 133, sat 0,25 a 0,35 (já perto do nosso); nada acima de 235 | números do `slash.gdshader` |
| Lascas do acerto | as de hoje (cinza-pedra, `Combat.CHIP_*`); no corte sem acerto, 4 a 6 riscos esmeralda finos (0,03 m) saindo da borda de ataque, 0,15 s | `chip.gdshader` (reuso), `Fx` |
| Emeth | lâmina em duas faixas de esmeralda (fundo matiz 140 valor 0,45; face matiz 133 valor 0,75) e fio marfim-menta; nada de luz nova; maior canal abaixo de 1,0 | `emeth.gdshader` pelo perfil |
| Aviso, contraste sobre o chão novo | o chão fica mais claro e morno (1.3): o aviso `blend_add` perde contraste. Meta: aro com luma pelo menos 40 acima da laje em volta a 1080 (a R1 tem só 25, pouco); preenchimento nos últimos 30% com pelo menos 20 acima. Se não der por `blend_add`, o perfil escurece a laje sob o aviso (fundo multiplicado por 0,8 dentro da forma) antes de somar | `ground.gdshaderinc`, `ground_fill.gdshader` (só números ou um passe de escurecer), medido no STY-08 |
| Forma e tempo dos avisos | **não mudam** (forma, divisas, tempo, cor `WARNING_COLOR`) | nenhum |
| Fogo | chama em 2 tons (âmbar e laranja), núcleo âmbar, luma até 200 (1.3) | material da chama |
| Números de dano, HUD | não mudam | nenhum |

### 3.4 O que depende de mudar asset
- Nada. Todo efeito é shader e partícula nossos.

### 3.5 Fora desta prova
- Marca de alvo circular dentro do aviso (a R1 tem): círculo no chão é só de Morvath e do Círculo de luz. Mantemos as
  divisas.
- Ícones do HUD da R1 (estrela de quatro pontas, cristais, corredor): o HUD é o nosso.
- Câmera lenta, hit stop, tempos: são do combate, não da arte.

---

## 4. Materiais e texturas

### 4.1 O que a R1 demonstra
- Pedra pintada à mão: cada bloco ou laje com valor próprio (luma 63 a 79 entre vizinhas), manchas de 2 a 3 tons dentro
  dele, aresta de cima clara e lascada, junta escura desenhada (2,5:1 contra a laje), rachaduras finas desenhadas.
- Pedra fosca, sem brilho especular.
- Uma laje em umas oito puxa para o verde (musgo seco) ou para o marrom.
- Metal (braseiros, ornamentos) em ouro velho pintado: luz em faixa e não reflexo.

### 4.2 O que já existe em Eterra
- `masonry.gdshader`: cantaria triplanar com juntas, lascas (`chipped`), quinas claras (`top_light` 1,3, `bevel_light`
  1,45), sujeira na base, relevo da rocha por textura (`rock_relief` 0,45, `rock_value` 0,35), rachaduras.
- `catacomb_floor.gdshaderinc`: lajes com valor por laje (`slab_value` 0,72 a 1,25), juntas, chanfro, partidas, faltando,
  rachadas, clareiras pálidas, musgo, relevo da rocha (`rock_relief` 0,5), molhado nas poças.
- Falta: pincelada em mundo; o relevo fotográfico é o que mais destoa da pintura; a luz é física (`diffuse_burley`,
  `specular_schlick_ggx`).

### 4.3 O que reproduzir no Godot (valores)

| Item | Valor | Onde |
|---|---|---|
| Pincelada em mundo | ruído de valor em duas escalas, **0,6 m e 0,15 m** (o "pincel" grande e o pequeno), alongado 2:1 na direção do bloco; quebra a cor em 2 a 3 tons: valor de 0,88 a 1,12 do bloco, matiz de -4 a +4 graus; quantização suave em 3 degraus (transição 0,12). Sem textura nova; se a GPU pedir, uma de 512 em BC4 | `paint.gdshaderinc` (função `brush(pos)`), usado pelo `masonry` e pelo chão |
| Variação por bloco ou laje | valor de 0,85 a 1,12 por bloco (o `slab_value` do chão vai de 0,72 a 1,25 para 0,85 a 1,12: menos contraste, mais tons); matiz de -5 a +5 graus; 1 em 8 puxa para o oliva (matiz 60, sat +0,05) | `masonry`, `catacomb_floor` pelo perfil |
| Aresta de cima | faixa clara de 0,04 a 0,07 m na quina de cima de cada bloco, valor 1,35 do bloco, matiz +4 graus (mais quente); lascada pelo `chipped` que existe (0,25 para 0,4) | `masonry` (`top_light`, `bevel_light` em faixa) |
| Junta | largura 0,03 a 0,05 m (3 a 4 px a 1080 na câmera do jogo), valor 0,35 do bloco, levemente fria (matiz 220, sat 0,1); nunca preto | `joint_color`, `joint_width` |
| Rachadura desenhada | as de hoje, mais finas (0,015 m) e no valor da junta | `cracks`, `crack_color` |
| Relevo fotográfico | `rock_relief` de 0,45 / 0,5 para 0,15; `rock_value` de 0,35 / 0,45 para 0,12 | `masonry`, `catacomb_floor` |
| Brilho | pedra fosca: especular 0,1 a 0,2, rugosidade 0,9 ou mais; o molhado das poças continua só onde está | `render_mode` e saídas do perfil |
| Clareiras pálidas | ficam, mais fracas (`clearing` 0,4 para 0,25): o chão já é claro | `catacomb_floor` |
| Medalhão do chão | linhas no valor da junta, sem ouro aceso e sem brilho; traço de pelo menos 3 px a 1080 para sobreviver ao filtro, se o filtro existir | `catacomb_floor` (números) |
| Ouro velho pintado | braseiros, ornamentos e o leão: luz em faixa (as três do include), especular baixo; matiz 34 a 42, sat até 0,6 (`art_direction.md` 2.2) | `paint.gdshaderinc` |
| KayKit do salão (velas, potes, barris, caixotes, entulho) | o material único `kaykit_material.tres` ganha a versão pintada no perfil: as três faixas, `paint_flat` 0,3 e o mesmo rim fraco do cenário (0,3 do dos personagens) | material novo `kaykit_paint.tres` |

### 4.4 O que depende de mudar asset
- Estátuas encapuzadas, moldura do portal, obeliscos com volume esculpido: pregas e ornamento pedem forma (lote B do
  plano, só estimativa).
- Textura pintada à mão de verdade nos personagens (lote A, só estimativa).

### 4.5 Fora desta prova
- Texturas pintadas à mão feitas por artista ou IA para a pedra (o shader procedural é a aposta).
- Mudar UV ou malha de qualquer modelo do Meshy.

---

## 5. Regras transversais

### 5.1 O que tem de funcionar sem pós-processamento
A prova é aprovada ou reprovada **com o filtro desligado**. Sem `PaintPass`, no Forward+ e no Compatibility, tem de
aparecer: chão claro e morno com laje de valor próprio, pincelada, aresta clara, junta desenhada (seção 4); poças das
tochas definidas, sombra projetada nítida, frio só na profundidade (seção 1); personagens escuros com rim e contorno de
casca (seção 2); corte com cauda em pinceladas (seção 3). Tudo isso é material, luz e geometria.

### 5.2 Filtro de pintura (Kuwahara) e contorno de tela: opcionais
- Só Forward+, só qualidade Alta (e Média se o custo deixar), só sobre o opaco (avisos, fitas, partículas, raio-x e
  números ficam por cima e nítidos). Kuwahara de 4 setores, raio 2 px a 1080 (3 no máximo), raio escalado pela escala 3D.
  Contorno de tela por profundidade e normal: 1,5 px a 1080, cor (0,07; 0,08; 0,10), alfa 0,6; nunca linha preta.
- **Critério de descarte** (qualquer um descarta o filtro inteiro, e a prova segue sem ele):
  1. **Borrão**: na mesma captura com e sem filtro, a junta das lajes (3 a 4 px) ou o fio da mira (6 px) perde mais de
     15% de contraste local, ou o fio marfim do raio-x deixa de ser contínuo.
  2. **Perda de detalhe**: na captura de estudo (5.3), rosto do herói (olhos e boca), cabelo, guarda da Emeth ou as runas
     do medalhão ficam indistintos onde sem o filtro se leem.
  3. **Custo**: mais de 1,0 ms de GPU na RTX 5060 a 1080 na Alta, ou mais de 1,5 ms na Média; nunca entra na Baixa, na
     iGPU nem no Compatibility.
  4. **Ganho nulo**: lado a lado com e sem filtro no mesmo quadro, se eu não apontar uma diferença de pintura que o
     material ainda não dá, ele sai (custo sem ganho).

### 5.3 Câmera e captura de estudo
- **A câmera do jogo não muda** (giro 35, inclinação 30, campo 24, distância 54; vitrine 60). Toda aprovação é na câmera
  do jogo.
- **Captura de estudo, só para avaliação**, mesma câmera com `--cam-dist=33` (o herói fica com cerca de 160 a 175 px a
  1080, a escala da R1; medido: a 40 ele tem cerca de 135 px, a 32 cerca de 155 a 165): 
  `RES=1920x1080 tools/gpu.sh shot <saída> --bot --autopick --seed=5 --shot-at=9 --cam-dist=33` e a vitrine
  `--showcase --seed=5 --shot-at=2 --cam-dist=33 --cam-at=<x,z>` com o portal e as estátuas no terço de cima. Sempre
  rotulada "estudo, câmera fora do jogo".

### 5.4 Paleta e leitura (valem no perfil estilizado)
- Quadro de luta: luma média 60 a 72; saturação p90 de 14 a 22 (`frame_stats`).
- Cores reservadas (`art_direction.md` 2.1) iguais em matiz; vermelho saturado só nos avisos; nenhum pixel acima de 235
  sobre o herói.
- Ordem de destaque de sempre: aviso que fere agora > herói > inimigo que prepara > recompensa e porta > inimigos parados
  > efeitos depois do acerto > cenário.

---

## 6. Matriz de correspondência

| # | Traço da R1 | Implementação no Godot | Arquivo ou shader | Responsável |
|---|---|---|---|---|
| T1 | Pedra morna umbra-oliva, frio só na profundidade | cores do chão e da cantaria e ambiente pelo perfil; abismo e vãos com `ABYSS_*` | `visual_profile.gd`, `catacomb_floor.gdshaderinc`, `masonry.gdshader` | STY-03, STY-04 |
| T2 | Chão claro no meio, escuro para a borda | valor do chão (65 a 80 / 50 a 62), luz geral e chave | `catacomb_floor.gdshaderinc`, `CatacombHall` (números) | STY-04 |
| T3 | Luz em poucos tons | três faixas no `light()`, transição 0,10 | `paint.gdshaderinc` | STY-04 |
| T4 | Poça quente das tochas com borda | `omni_attenuation` 1,5 a 2,0, alcance 3,5 a 4,5 m, faixa de luz | `CatacombHall` (números), `paint.gdshaderinc` | STY-04 |
| T5 | Sombra projetada nítida e neutra | luz chave com sombra, penumbra até 0,15 m, cor da sombra (0,92; 0,93; 0,98) | `CatacombHall`, `paint.gdshaderinc` | STY-04 |
| T6 | Chama âmbar, não branca | núcleo até luma 200 | material da chama | STY-04 |
| T7 | Ar limpo sobre o chão | névoa volumétrica do salão a 40% | `visual_profile.gd` | STY-03 |
| T8 | Pincelada na pedra | `brush()` em duas escalas (0,6 e 0,15 m), 3 degraus | `paint.gdshaderinc`, `masonry`, `catacomb_floor` | STY-04 |
| T9 | Valor por bloco e laje | 0,85 a 1,12, matiz de -5 a +5, 1 em 8 oliva | `masonry`, `catacomb_floor` | STY-04 |
| T10 | Aresta de cima clara e lascada | faixa de 0,04 a 0,07 m, 1,35, `chipped` 0,4 | `masonry` | STY-04 |
| T11 | Junta e rachadura desenhadas | junta 0,03 a 0,05 m a 0,35 do valor; rachadura 0,015 m | `masonry`, `catacomb_floor` | STY-04 |
| T12 | Pedra fosca, sem foto | `rock_relief` 0,15, `rock_value` 0,12, especular 0,1 a 0,2 | `masonry`, `catacomb_floor` | STY-04 |
| T13 | Paredes de cantaria (sem tijolo de brinquedo) | KayKit das paredes trocado por `Masonry` só no perfil | `catacomb_hall.gd` | STY-05 |
| T14 | Estandartes rasgados | pano petróleo (0,07; 0,17; 0,19), leão em ouro velho, um rasgado | `ArenaKit.banner` pelo perfil | STY-05 |
| T15 | Nichos com potes, arcos sob a borda | opcionais, fora do chão, `fit_probe` sem fantasma | `catacomb_hall.gd` | STY-05 (opcional) |
| T16 | Facho frio (R2) | um `moon_shaft` | `ArenaRoom.moon_shaft` (reuso) | STY-05 (opcional) |
| T17 | Props pintados | material KayKit pintado | `kaykit_paint.tres` | STY-05 |
| T18 | Corpo escuro, sombra em faixas | `light()` do include, `lift` 0 no perfil | `crowd.gdshader`, `hero_paint.gdshader` | STY-06 |
| T19 | Borda de luz morna | rim (1,0; 0,82; 0,62), fresnel 3 a 4 | `crowd.gdshader`, `hero_paint.gdshader` | STY-06 |
| T20 | Contorno fino dos personagens | casca 0,04 m (herói 0,045) em todos | `crowd_outline.gdshader`, passe do herói | STY-06 |
| T21 | Textura sem ruído fotográfico | `paint_flat` 0,35 | `crowd.gdshader`, `hero_paint.gdshader` | STY-06 |
| T22 | Lâmina de cristal esmeralda | duas faixas e fio marfim-menta | `emeth.gdshader` | STY-06 |
| T23 | Meia-lua com cauda em pinceladas | alfa cortado em 5 a 8 riscos na metade de trás | `slash.gdshader`, `slash_ink.gdshader` | STY-06 |
| T24 | Lascas esmeralda no corte | 4 a 6 riscos de 0,03 m por 0,15 s | `chip.gdshader`, `Fx` | STY-06 |
| T25 | Aviso claro sobre o chão | aro 40 acima da laje, preenchimento 20 acima no fim; escurecer a laje sob o aviso se preciso | `ground.gdshaderinc`, `ground_fill.gdshader` (números) | STY-06 (medido no STY-08, aprovado pelo combat-feel no STY-09) |
| T26 | Acabamento de pintura na tela | Kuwahara 2 px e contorno de tela, opcionais, com critério de descarte | `paint_pass.gd`, `paint_pass.glsl` | STY-07 |
| T27 | Enquadramento mais perto | só captura de estudo `--cam-dist=33` | nenhum (opção que já existe) | STY-08 |
| T28 | Lado a lado, medidas, custo | capturas, vídeo, `frame_stats`, ms de GPU | `docs/gallery/stylized_poc/` | STY-02, STY-08 |
| T29 | Parecer | critérios da seção 8 | `docs/gallery/stylized_poc/ART_REVIEW.md` | STY-09 |

---

## 7. O que recusei da R1 e perguntas

| Elemento da R1 | Decisão | Por quê |
|---|---|---|
| Estrela de quatro pontas em ouro sobre a porta e no HUD | recusado | símbolo proibido (`art_direction.md` 7); o símbolo é o leão |
| Losango violeta na segunda porta | recusado | violeta é de Morvath; a porta do salão é o portal verde da pintura aprovada |
| Estandartes vermelhos com cruz e círculo | recusado | estandartes são petróleo com o leão (Q-22); vermelho é do perigo; cruz proibida |
| Rosa dos ventos e círculo no chão | recusado | círculo no chão é de Morvath e do Círculo de luz; o salão já tem o medalhão gravado da pintura aprovada |
| Marca circular de alvo dentro do aviso | recusado | idem; nossos avisos usam divisas |
| Auréola de espinhos no esqueleto e no sacerdote | recusado | não é das nossas figuras e lê como halo santo; os inimigos são os aprovados |
| Personagens, HUD, layout da sala | recusados | regra do projeto: nada se copia; HUD é o nosso; a sala é a da pintura de 2026-11-14 |
| Crânios empilhados | fora (sem modelo) | gerar pede Meshy (zero autorizado) e não é essencial à prova |

Perguntas ao Daniel (pelo Game Director):
- **S-Q5, pedra morna ou fria.** A R1 tem pedra morna (umbra-oliva, matiz 28 a 40) e frio só no abismo; o nosso guia
  diz "cenário frio" e hoje o chão do salão sai lilás. Opções: (a) o perfil estilizado segue a R1 (pedra morna, frio só
  na profundidade); (b) mantém a pedra fria e só pinta. **Recomendo (a)**: é a imagem que você escolheu, e o calor
  ajuda o herói e a Emeth (frios) a saltarem. Esta especificação já está escrita para (a); com (b), a seção 1.3 troca
  matiz 34 a 42 por 210 a 225 e o resto vale.
- **S-Q6, medalhão do salão.** O medalhão gravado do salão (da sua pintura aprovada) tem quatro pontas longas, que leem
  como estrela de quatro pontas, que está proibida. Opções: (a) fica, sem ouro nem brilho, no valor da junta (o que esta
  especificação faz); (b) as pontas viram oito curtas ou somem e fica só o anel com as runas. **Recomendo (b)** numa
  entrega própria; a prova segue com (a).

---

## 8. Critérios do parecer STY-09 (art-director)

Avalio nesta ordem, sempre lado a lado no mesmo quadro (clássico e estilizado, mesma semente, mesmo commit), a 1080 e a
720, na câmera do jogo; a captura de estudo entra só como apoio. Cada critério recebe "passa", "passa com ressalva" ou
"não passa", com a captura citada.

1. **Leitura sem filtro** (5.1): com o `PaintPass` desligado, a pedra lê pintada (pincelada, aresta, junta) a 1080.
   Se só passar com o filtro, a direção não está provada.
2. **Valor da sala**: ordem da 1.3 (meio do chão o mais claro, profundidade a mais escura); chão no meio com luma p50 de
   65 a 80; luma média do quadro de 60 a 72; saturação p90 de 14 a 22.
3. **Luz**: poças das tochas com borda visível e raio de 2 a 2,5 m; sombra projetada do herói visível e definida; frio
   só na profundidade; nenhuma parede inteira lavada por luz sem fonte.
4. **Material**: laje vizinha com valor diferente; 2 a 3 tons dentro de um bloco; aresta clara visível nas balaustradas e
   pilares a 1080; nenhum ruído fotográfico de rocha visível a 1080.
5. **Personagens**: herói achado em 1 s nas capturas de luta; corpo mais escuro que o chão e borda de luz mais clara da
   tela no herói; contorno contínuo nos inimigos a 1080; elites ainda se distinguem.
6. **Coerência**: herói, inimigos, props e pedra parecem da mesma mão (mesmas faixas, mesmo rim morno); nada fotográfico
   ao lado de nada pintado.
7. **Combate**: corte com cauda em pinceladas no quadro `--shot-on=swing`; miolo abaixo de 235; aviso com aro pelo menos
   40 acima da laje (medido pelo STY-08); fio da mira e fio marfim do raio-x visíveis. A palavra final da leitura é do
   `combat-feel-director`.
8. **Identidade**: nenhum símbolo recusado (seção 7); estandartes petróleo com o leão; cores reservadas no matiz;
   vermelho saturado só nos avisos.
9. **Fantasia sombria, não infantil**: nada de cor de doce, contorno grosso de desenho animado, proporção mudada ou
   brilho de brinquedo. Contorno de personagem até 2 px a 1080 na câmera do jogo.
10. **Filtro** (se existir): critério de descarte da 5.2, um por um.
11. **Clássico intacto**: o perfil clássico igual à linha de base (diferença até 2 por canal).
12. **O que depende de asset**: lista do que só o Meshy ou um artista resolveria, com a estimativa do plano, sem gasto.

Veredito possível: "pronto para o Daniel julgar" (todos passam ou passam com ressalva) ou "volta ao STY-04/05/06" com o
pedido de correção em valores. Não declaro semelhança em porcentagem: descrevo as diferenças que sobram. A aprovação da
direção é do Daniel.
