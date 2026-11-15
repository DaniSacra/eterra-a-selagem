# Estética: guia de arte

Alvo: a **sensação visual** do Ember & Blade (Linegames) e do Hades 2, com arte toda nossa. Estudamos
como a imagem funciona (valores, cores, tempo dos efeitos, leitura da tela) e nunca copiamos personagens,
criaturas, ícones, interface, nomes ou composições. Nenhuma imagem desses jogos entra no repositório, vai
para o Meshy ou serve de entrada para IA.

Referências do Daniel (só na máquina dele, fora do repositório):
- Capturas: `C:\Users\danie\OneDrive\Imagens\Ember Blade\`
- Gravações: `C:\Users\danie\Videos\Ember Blade\` (5 vídeos de 10 a 22 s, 30 qps)

Análise feita em 2026-11-14 a partir dessas capturas (folhas de quadros e quadro a quadro com ffmpeg).

## 1. Paleta e valores

- **O cenário é frio, escuro e pouco saturado.** Verde azulado (teal) e ardósia. O mais escuro do cenário é
  um teal profundo, nunca preto puro. Quase não há luz quente no cenário.
- **Os efeitos são a única coisa saturada e brilhante.** Vermelho, ciano, roxo e branco estourado, com bloom.
  O contraste entre um cenário calmo e efeitos que estouram é o coração do visual.
- **Manchas claras no chão.** Clareiras de terra pálida em forma irregular quebram o chão escuro. São da
  textura (tinta), não de luz. Dão ritmo e lugar para o olho descansar.
- **Clima.** Partículas finas (chuva ou neve) caindo na diagonal, sempre presentes, bem discretas.
- Na arena do chefe o fundo escurece e puxa para o roxo azulado; os efeitos ficam mais saturados ainda.

Para A Selagem (catacumbas sob a igreja de Valmor): pedra ardósia fria no lugar da grama, poças de luz
fria caindo de frestas do teto da igreja, tochas quentes só como acento, e o vermelho reservado para a capa
do paladino, os avisos de ataque e o sangue dos efeitos. A luz de Elun é branca e dourada, a cor do herói.

## 2. Leitura da tela

- **O herói é pequeno** (cerca de 3% da altura da tela) e se lê pelo contraste: barra de vida curta
  logo acima da cabeça, silhueta clara contra o chão escuro e os efeitos saindo dele.
- **A multidão é cinza e apagada.** Centenas de inimigos comuns quase sem cor, para não brigar com os efeitos.
- **Elites e chefes têm contorno brilhante grosso** (rosa avermelhado) e o corpo mais claro que a multidão.
  Ao levar golpe forte, o corpo inteiro fica branco por um ou dois quadros.
- **Números de dano pequenos e brancos**, muitos ao mesmo tempo, sem caixa nem sombra pesada.
- Avisos no chão: área translúcida (vermelha para perigo) com borda brilhante e um desenho fino por dentro.

## 3. Golpes e impacto (medido quadro a quadro, 30 qps)

- **Corte em meia-lua grande**: raio de 4 a 5 alturas do herói. Corpo do arco em tinta escura (quase preta)
  com a borda de ataque branca estourada. Aparece inteiro em 1 ou 2 quadros (cerca de 0,05 s).
- **A tinta fica**: a meia-lua escura continua visível e vai sumindo por cerca de 8 a 10 quadros
  (0,3 s) depois do branco apagar.
- **Sem hit stop (corrigido em 2026-11-14)**: a medição antiga achou 1 ou 2 quadros repetidos, mas eles vinham
  da gravação a 30 qps. Na gravação da demo (abaixo) não há nenhum quadro congelado depois de nenhum golpe:
  o impacto vem do brilho, da tinta e da antecipação, não de parar o jogo.
- **Quadro de impacto**: nos golpes enormes, 1 ou 2 quadros da tela inteira em preto e branco chapado
  (silhuetas brancas sobre fundo preto), estilo anime. Usar com muita parcimônia.
- **Aberração cromática** (separação de cores vermelho e azul) e tremor de câmera nos impactos grandes.
- **Explosões de cristais ou espinhos** que brotam do chão, finos e pontudos, em vez de bolas redondas.
- Inimigos arremessados e pedaços voando em todas as direções quando morrem em grupo.

### Medido na demo jogada pelo Daniel (2026-11-14)

Gravação de 95 s do começo da demo (`C:\Users\danie\Videos\Captures\`, cerca de 26 qps). Golpes achados pelo
pico de pixels quase brancos; congelamento, pela diferença entre quadros seguidos.

- **Árvore de combos** da demo: o pesado depois de 1, 2, 3 ou 4 leves dá um finalizador diferente. A nossa
  segue a mesma ideia com golpes e nomes próprios.
- **Golpe leve**: o corte branco fica visível de 70 a 110 ms. Intervalo entre leves: 0,33 a 0,47 s no mais
  rápido. O nosso (cerca de 0,29 s) já está nesse ritmo.
- **Finalizador**: cerca de 0,2 s de preparação, depois um brilho que **segura 0,2 s** na lâmina (o herói continua
  se mexendo devagar): uma cruz fina de quatro pontas, um risco diagonal bem comprido atravessando a tela e um anel
  fino em volta, crescendo. Quando o corte sai, o brilho estoura e o corte é um anel ou meia-lua enorme (quase a
  largura da tela) que some em cerca de 0,4 s. Uns 0,8 s no total.
- **Hit stop**: nenhum quadro congelado (uma parada menor que 35 ms não apareceria nesta gravação).
- Mundo todo cinza, efeitos brancos; vermelho só nos especiais, tingindo a tela inteira.

Aplicado: `Feel.hit_stop_scale` de 1,35 para 0,4, e o brilho dos finalizadores (`ComboNode.glint` de 0,2 s nos
cinco finalizadores das sequências, preparação de 0,2 s, ajuste ao vivo em `Feel.glint_scale` no painel F1).

## 4. Câmera

- Alta e inclinada (perto de 50 a 55 graus), perspectiva leve, enquadramento largo: dá para ver a horda
  chegando de todos os lados. A nossa (`Feel`: distância 50,5, inclinação 30, campo de visão 20, no molde do Hades II)
  mostra cerca de 31 m de largura.

## 5. Personagens

- Proporções adultas e esguias: cabeça pequena, pernas longas. Nada de cabeçudo.
- Textura pintada à mão, cores apagadas e um único acento forte (no nosso paladino, a capa vermelha).
- Modelos do Meshy: ver `tools/meshy/` (prompts, tarefas e créditos) e `assets/models/meshy/`.

### Leitura na luta (correção de 2026-11-14, captura do Daniel: "herói dourado ou branco, inimigos verdes e chapados")

Causas medidas em capturas reais (Forward+, `--bot --seed=5`; recortes no scratchpad da sessão):
- Herói dourado: o contorno do `flash.gdshader` (dourado, `pow(rim, 2.5) * 2,2`) cobria quase todo o corpo a 70 px,
  somado ao raio X (`xray.gdshader`, sem teste de profundidade) que pintava dourado sobre o corpo inteiro mesmo
  sem nada na frente; com `--outline=0` o herói voltou às cores dele. Durante a carga do Ômega o brilho dourado
  cobria o corpo (25% fixo mais a borda) e o robô (e quem segura o botão) carrega quase sempre.
- Herói branco: o pisca de proteção (0,6 x 1,6 de branco somado, a cada 0,16 s) acontecia em toda proteção,
  inclusive depois de cada avanço e de cada círculo, não só depois de levar golpe.
- Herói escuro de costas: a única luz dele fica à frente; de costas (como a câmera mais o vê) o couro virava preto
  e só a borda dourada aparecia.
- Multidão chapada e esverdeada: `CROWD_GREY` 0,92, `CROWD_LIFT` 0,45 e `CROWD_FLAT` 0,45 apagavam a textura e a
  forma (gesso); o ambiente frio, a lua azul-petróleo e os tons frios dos inimigos (`tint` do arqueiro 0,85, 0,95,
  0,85) esverdeavam o cinza.

O que mudou:
- `flash.gdshader`: borda fina e fria (`Player.EDGE` 0,75, 0,9, 1,0; `edge_from` 0,9, `edge_gain` 0,18; mais forte, ela cobria os ombros de branco a 70 px; abaixo do limiar de brilho);
  o brilho da carga fica na borda (`glow_body` 0,06). `xray.gdshader`: só onde algo encobre o herói (compara com a
  profundidade da cena; `hidden_by` 1 m, senão o manto e o cachecol escondem o resto dele e o raio X pinta o
  próprio corpo). `Player`: pisca só depois de levar golpe (`HURT_BLINK` 0,3), o dourado da carga aparece
  depois de 25% dela (`CHARGE_GLOW` 0,55), sombra de contato 1,2 x 0,8 m a 50%.
- `HeroBody.FILL` 0,28: o herói mostra parte da própria cor sem luz (emissão pela textura, modo multiplicar);
  `HeroGear` igual. Cabelo cobre mais claro no `recolor_hero.gd` (`HAIR_*`), ombreira nos dois ombros, manto até
  abaixo do joelho (`HeroGear.MANTLE`).
- Multidão (`crowd.gdshader`, `CrowdRenderer`): cores da textura do KayKit pouco apagadas (`CROWD_GREY` 0,5,
  `CROWD_TINT_KEEP` 0,3), luz pintada fixa vinda do alto à esquerda da tela (`KEY` 0,8, `KEY_FILL` 0,16), pés mais
  escuros (`FOOT_SHADE` 0,55) e borda escura onde o corpo vira (`INK` 0,65); a luz fria da sala só tinge
  (`CROWD_SCENE_LIGHT` 0,55). Partículas de sombra em violeta do abismo (`Fx.BURSTS.shadow`), não magenta.

## O que já foi feito (2026-11-14)

- Luz e ambiente frios em `game.gd` (`_build_world`), pedra do KayKit tingida (`Arena.STONE_TINT`),
  fachos de luz fria (`Arena.SHAFTS`), manchas e névoa do chão frias (`floor_detail.gdshader`).
- `paladin_1` gerado no Meshy (textura e esqueleto, com andar e correr); ainda não está no jogo.

### Pacote visual do MVP (2026-11-14)

- **Brilho do finalizador** (`Fx.glint`, `assets/shaders/glint.gdshader`): cruz fina de quatro pontas (a de pé
  mais longa), um risco diagonal bem comprido e um anel fino, presos à ponta da espada (`Player.blade_tip`).
  Cresce durante a pausa (`ComboNode.glint`, 0,2 s) e estoura quando o golpe sai (`Fx.GLINT_BURST`). Substitui a
  estrela de acerto que parecia um golpe no ar. Tamanho em `Fx.GLINT_SIZE`; partes em uniforms do shader.
- **Finalizadores com peso**: o arco do finalizador fica claro por `Combat.FINISHER_SLASH_TIME` (0,3 s) e solta uma
  meia-lua enorme (`Fx.crescent`, `crescent.gdshader`) de tinta com borda branca, que voa até
  `Fx.CRESCENT_GROW` vezes o alcance e some em `Fx.CRESCENT_TIME` (0,42 s). É só desenho: o que o golpe acerta
  continua sendo o arco de dentro (a regra "o arco desenhado é o alcance" vale para o arco, não para a onda).
- **Quadro de impacto** (`Fx.impact_frame`, uniform `impact` de `screen.gdshader`): a tela em preto e branco chapado
  por `Feel.impact_frame` (0,05 s, painel F1). Só quando um finalizador acerta `Combat.IMPACT_FRAME_CROWD` (6)
  inimigos ou mais, um elite ou o chefe, e nas trocas de fase e na morte de Morvath. Desliga junto com o tremor
  de tela (opção do jogador), por conforto. Aberração cromática mais forte no finalizador (`kick_split` 0,8).
- **Corte comum**: alcance e largura dos leves e pesados maiores em `tools/make_data.gd` (leves 3,6 a 3,9 m e
  170 a 180 graus; pesados 4,1 e 4,3 m), tinta mais gorda (`Fx.INK_INNER` 0,3), mais densa (uniform `density`)
  e mais escura, e durando mais (`Feel.ink_life` 2,6: o branco some em cerca de 0,1 s e a tinta fica até 0,4 s).
- **Multidão cinza**: `CrowdRenderer.CROWD_GREY` (0,85 da cor tirada) e `CROWD_SHADE` (mais escura). Elites com
  as cores e mais claros (`ELITE_SHADE`) e contorno grosso brilhante rosa avermelhado (`crowd_outline.gdshader`,
  segunda passada só no material dos elites e do chefe; `OUTLINE_WIDTH`, `OUTLINE_INTENSITY`; cor em
  `ELITE_RIM` no `make_data.gd`). Golpe forte (pesado ou finalizador) deixa o inimigo branco puro por um ou dois
  quadros (`Enemy.flash_power`, `Horde.WEAK_FLASH`, uniform `white_from` do `crowd.gdshader`).
- **Chão pintado** (`floor_detail.gdshader`, agora iluminado e cortado em `Arena.FLOOR_CHUNKS`² pedaços): uma
  aguada de ardósia escura por cima dos hexágonos (`wash_*`) e clareiras pálidas de borda irregular
  (`clearing_*`). O overlay desenha antes de todo o resto transparente (`render_priority` mínimo), o que também
  corrigiu a tinta dos cortes e os avisos que às vezes sumiam por baixo dele.
- **Clima**: poeira fina caindo devagar na diagonal em cada facho de luz (`Arena._dust`, constantes `DUST_*`).
- Cena mais escura e menos saturada (`ambient_light_energy` 0,45, `adjustment_saturation` 0,6).
- Laboratório: `tools/lab.sh` aceita `--lab-glint`, `--lab-crescent` e `--lab-impact` (quadros parados para julgar).

### Escala e discrição (2026-11-14, depois do 1º teste do Daniel)

O Daniel achou "tudo muito grande": o cenário parecia de brinquedo perto do herói, a câmera mostrava pouca sala,
e efeitos e interface ocupavam espaço demais. Os personagens ficaram como estavam. Antes e depois:

- **Cenário** (`Arena.PROP_SCALE`, colisão acompanha o modelo escalado):
  paredes 4 m para 2,9 m de altura (0,72; seguem cobrindo `TILE` 4 m de largura), tochas de 2,4 m para 1,75 m
  (`TORCH_HEIGHT`); escadas 7 x 5,1 x 4 m para 5,6 x 2,8 x 3,2 m (`STAIRS_DEPTH` 4 para 3,2, `STAIRS_HALF_WIDTH`
  3,3 para 2,65); barris 2 m para 1,1 m; entulho 3,5 m para 1,75 m de altura (0,6 e 0,55 no chão); espada e escudo
  quebrados 0,7; velas 0,7; estandartes 0,7 de altura. Pilares: raio que bloqueia 1,0 para 0,6 (os grandes 1,4 para
  0,85 e 1,2 para 0,72, em `_stage` do `make_data.gd`), desenhados com a largura do raio (`PILLAR_MODEL_RADIUS` 0,82)
  e 4 m para 2,7 m de altura (`PILLAR_HEIGHT` 0,68). Tamanho das salas não mudou.
- **Câmera**: `Feel.cam_distance` 45 para 50,5 (12% mais longe; inclinação 30 e campo de visão 20 iguais).
- **Cortes**: banda clara mais estreita (`Fx.SLASH_INNER` 0,28 para 0,5), tinta mais estreita (`INK_INNER` 0,3 para
  0,42), mais clara e mais curta (`Feel.ink_opacity` 0,92 para 0,85, `ink_life` 2,6 para 2,0), brilho
  `Feel.slash_intensity` 2,2 para 1,7. O alcance desenhado continua igual ao que acerta.
- **Meia-lua do finalizador**: cresce até 1,8 vezes o alcance (era 5), dura 0,42 s (era 0,55), banda de 0,72 do
  alcance para fora (era 0,55), tinta 0,28 (era 0,35).
- **Brilho do finalizador** `GLINT_SIZE` 20 para 13 m; estrela de acerto `IMPACT_SIZE` 2,3 para 1,6; partículas
  70% do tamanho e da quantidade (`BURST_SCALE`, `BURST_AMOUNT`); anéis mais finos e fracos (`ring.gdshader`
  `band` 0,12 para 0,08, `intensity` 2 para 1,5); anel do círculo de luz que explode 1,25 para 1,1 do raio.
- **Áreas no chão** (`Ground`): o tamanho continua sendo o do ataque; a borda clara agora tem largura fixa em metros
  (`RIM_METERS` 0,28, uniforms `size_m` e `rim_m` do `ground.gdshader`) em vez de 14% do raio, então as grandes
  ficam com borda fina. Círculo de luz do paladino mais suave (`BIND_STRENGTH` 0,35 para 0,24), áreas dos dons 1 para
  0,8 (`AREA_STRENGTH`). Avisos com o mesmo brilho (`WARNING_STRENGTH` 1,4), para continuar legíveis.
- **Números e palavras**: `Fx.NUMBER_SIZE` 24 para 17, `NUMBER_BIG` 34 para 24, `WORD_SIZE` 30 para 21, contorno
  8 para 5. Palavras sobre portas e recompensas 25% menores (`Rooms.MARKER_TEXT_PIXEL` 0,012 para 0,009).
- **HUD** (`Hud`, constantes no topo): vida 340 x 26 para 240 x 14, Magia 8 para 5 de altura, avanços 36 x 8 para
  26 x 5, chefe 640 x 14 para 480 x 9, relógio 38 para 26, sala e ouro 26/24 para 18, contador de golpes 64 para 40,
  nome do golpe 30 para 20, ícones dos dons 52 para 38, margem 24 para 20.
  Redesenhado no molde da imagem de referência (ciclo 4, 2026-11-14): medalhão do herói `HeroCrest` (76), vida 244 x 19 e
  Magia 196 x 15 em `HudBar` com ponta em ângulo, as quatro ações em losango (`ActionSlot`) com a tecla real, moeda e
  traço pincelado em `HudMark` (números em unidades de 720 linhas).

## Pendências

1. Colocar o `paladin_1` no jogo. Não foi feito: o esqueleto do Meshy (24 ossos, `Hips`, `LeftArm`...) é outro, e os
   golpes do Knight precisam ser redirecionados. Caminho: importar os dois GLB com `BoneMap` para o
   `SkeletonProfileHumanoid` (Godot reaproveita as animações entre esqueletos do mesmo perfil), conferir a pose de
   descanso (o Meshy vem em pose A) e prender a espada na mão direita (`RightHand`). Sem créditos.
2. Arena do chefe puxando para o roxo azulado (hoje só a porta muda de luz).
3. Explosões de cristais ou espinhos brotando do chão nos finalizadores grandes.
4. Medir desempenho em placa de vídeo fraca (o contorno dos elites é uma passada a mais só nos elites e no chefe).
