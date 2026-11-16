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

### Ciclo 10: brilho limpo na luta de Morvath, verde corrompido, queimadura e a fase 4 (2026-11-15)

Pedido do backlog (BUG-005, BUG-006, ART-005 a ART-008; revisão do ciclo 9, B2, N3, N4, N5, N9 e seção 8). Regra de
leitura: nada acima do limiar do glow (1,3) sobre o herói, sem clarão branco, sem amarelo saturado; paleta de Morvath em
violeta profundo, azul espectral, esmeralda corrompido e ouro antigo. Capturas em `docs/gallery/cycle10/work/`.

- **Escudo do ritual sem pontos brancos** (BUG-005): os borrões brancos com um ponto preto no meio que giravam em
  volta do escudo têm a assinatura de um valor inválido (NaN) espalhado pelo glow; o `boss_shield.gdshader` agora
  protege o vetor e o ângulo de visão (`facing` limitado a 0..1) e as partículas mudaram, e nos 24 quadros seguidos do
  começo do ritual não sobra nenhum. As partículas em órbita (`BossShield.MOTE_*`) são metade
  esmeralda corrompido, metade azul espectral, 0,12 m, cor vezes luz no máximo 1,2. O escudo é `unshaded` e somado: não
  tem especular.
- **Esmeralda corrompido frio e escuro** (ART-006): matiz 165, saturação 0,55, valor 0,7 (`BossShield.COLOR`
  0,315 / 0,7 / 0,604), igual nas colunas (`spectral_column.gdshader`) e nas partículas do ar da fase 4; os círculos
  de runa um pouco mais vivos (0,26 / 0,74 / 0,6) para o perigo ler de relance. O verde-menta vivo fica só da Emeth.
- **Coluna do escudo** (ART-005): o pilar de luz de 12 m sobre Morvath no começo do ritual (`Fx.beam`, com miolo
  branco) saiu. No lugar, uma cortina fina de fogo espectral sobe na borda do escudo, uma vez, por 0,8 s, com luz até
  0,4 (`BossShield.CURTAIN_*`): ele fica lido em todos os quadros.
- **Orbe do feiticeiro** (BUG-006): os tiros inimigos (virote, orbe, maldição) são uma bola no matiz da magia de quem
  atira (canal maior em 1), borda mais escura, miolo de 30% do raio a 1,2 e um halo misturado (não somado) de 1,5 raio
  (`enemy_orb.gdshader`, `enemy_orb_halo.gdshader`, `Projectiles.HALO`); um material por parte para todos os tiros,
  o matiz por instância. Seis feiticeiros juntos não somam branco. As centelhas do preparo do cajado e do rito
  (`EnemyFx.MAGIC_SPARK`) foram de 1,6 para 1,2.
- **Queimadura em brasas** (ART-007): o corpo não fica mais dourado. O albedo não muda; brilha uma borda de fogo laranja
  (`burn_rim` 0,5) e brasas pequenas que sobem pelo corpo, cada uma acendendo e apagando (`burn_coals`, `coal_color`
  1,1 / 0,42 / 0,1), tudo abaixo do glow e nunca amarelo (`crowd.gdshader`). O esqueleto queimando continua esqueleto e
  não se confunde com a elite de ouro velho.
- **Atmosfera da fase 4** (ART-008): `RoomMood` (`scripts/game/room_mood.gd`) vira o ar da sala para um clima
  (`RoomMood.Look`) e devolve tudo exatamente como era; vale para qualquer cenário (lê o `Environment` do mundo e as
  luzes de baixo da arena). `Arena.final_phase` liga `LAST_BREATH`: as profundezas e as ruínas do abismo passam do teal
  para violeta (`room_air`, global de shader em `room_air.gdshaderinc`, mantém o brilho e muda só o matiz), névoa e
  fundo violeta, sombras levantadas para o violeta por uma curva de cor só nos escuros (`shadow_lift`), lua espectral,
  fogos 40% mais baixos e frios, o brilho violeta do abismo 1,5 vez, respiração lenta. Herói, multidão, avisos,
  exposição e glow não mudam. A selagem (`Arena.seal_portal`) devolve o ar da sala no mesmo tempo. Uma sala nova liga
  outro clima com `arena.mood().blend(look, true)`.

## Arenas do ciclo C12 (Cripta, Fendas, Jardim)

Especificação, planta em metros e critérios: `docs/art/cycle12_arenas_spec.md`. Regras que valem para todo cenário novo:
mesma câmera e mesmo valor de chão (mediana 45 a 60) em todas as salas, o matiz do ar é o que muda; norte e oeste são o
fundo (peças altas), sul e leste a frente (só peças baixas ou com pontilhado); peça com topo a 1,25 m ou mais bloqueia
tiro, até 1,0 m não; velas, braseiros e cristais nunca soltos no chão andável; nada de fogo verde, nada de círculo
fechado ou inscrição acesa no chão (círculo é de Morvath); estátuas de mãos vazias; estandartes com o leão do selo
(o Daniel, 2026-11-16; a Câmara do Selo fica com a espada). O ar de cada sala pode ser um `RoomMood.Look` (`arena.mood().blend(look, true)`).

Feito (2026-11-16, environment-artist): mediana do chão na câmera do jogo a 1080p, Cripta 48,6 (A) e 44,6 (B), Fendas
43,9 e 44,7 (antes 70 no cinza). Cripta quente e fechada: pedra cinza morna, luz-chave fraca sem sombra (`KEY`),
braseiros e velas com sombra, um feixe frio azulado sobre o túmulo (`COLD`, a única luz fria). Fendas azul-violeta:
lajes grandes e azuladas, névoa e paredes do abismo violeta (`MIST`, `CLIFF`), luz violeta vinda de dentro da fenda
pintando as bordas (`LIP_*`), lanternas quentes nas cabeças das pontes, fogo só no pórtico da porta. Leão: ouro velho
(`BANNER_LION_GOLD`) com borda escura sobre o vermelho, brilho 0,35, abaixo do glow. Quadro na GPU a 1080p sem vsync:
cerca de 2 a 2,7 ms nas quatro variantes.

## Ciclo C12d: efeitos que não cobrem o que deve ler (VX-01 a VX-03, VX-08 a VX-10, VX-COL)

Medido na GPU (Forward+, 1080p, `--cam-dist=26`); quadros em `docs/gallery/c12d/work/vx_*.jpg`.

- **Corte da Emeth** (`slash.gdshader`, `slash_ink.gdshader`): a luz é só o fio da borda de ataque, marfim-menta
  (`edge_px` 3 px, `edge_pale` 0,8, `edge_light` 0,62) com um miolo pálido logo dentro dele (`core_sat` 0,4 no máximo,
  `core_light` 0,24, `core_depth` 0,45); o corpo é tinta escura translúcida (cor 0,02 / 0,028 / 0,034, `max_alpha` 0,6) do
  fio para dentro (`body_depth` 0,75) e, além dele até o alcance, só um véu (`reach_veil` 0,2). O fio fica onde a ponta
  da lâmina passou: `blade_m` metros do paladino quando o `Fx` passa `reach_m` e `band_from`; sem eles, na borda de fora.
  Pixels da fita com saturação acima de 0,6: 27% antes, 8% depois (vitrine `--lab`). Encaixe no `fx.gd`: `BLADE_REACH`
  2,6 m (a ponta real da Emeth, `EmethSword.TIP`, medida quadro a quadro nos golpes 1 a 3: de 2,3 m quando desce a 2,85 m
  na altura da cintura; o 2,2 pedido deixava a ponta nivelada a 0,64 m do fio), `SLASH_INNER` e `INK_INNER` 0,12 (eram
  0,5 e 0,42). Antes o fio ficava na borda de fora, a 5,25 m do paladino nos golpes 1 e 2: 2,4 a 2,6 m além da ponta;
  agora a diferença no chão é de até 0,3 m com a lâmina na cintura e 0,49 m em 3D no quadro do golpe 3. O corte já
  aparece no quadro do golpe (`Fx.SLASH_LEAD`, um quadro) e varre em 3 (`Feel.slash_sweep_time` 0,1 para 0,05; o
  clipe ainda passa a lâmina 1 a 2 quadros antes do quadro do golpe nos golpes 1 e 2, coisa do `PEAK`). Vitrine vazia na
  GPU (`--lab --lab-count=0 --cam-dist=26`, 1080): fita com saturação acima de 0,6 em 1,1% (t 0,15) e 4,4% (t 0,3) dos
  pixels; `docs/gallery/c12d/work/vx_wire_*.jpg`.
- **Brilho do finalizador** (`glint.gdshader`): anel em metros (`ring_m` 0,5, abre `ring_burst_m` 0,3: diâmetro máximo
  1,6 m, menos de 0,6 da altura do herói), cruz menor (`spike_long` 0,3, `spike_short` 0,12) com o meio vazado
  (`hollow_m` 0,14) e, sobre o corpo do herói visto da câmera (coluna de `body_half_m` 0,5 por `body_height_m` 2,8 sobre
  `hero_pos`), só `over_body` 0,2 da luz. Luz somada sobre o corpo: mediana 41 para 8 (de 255), p99 222 para 179.
- **Avisos** (`ground.gdshaderinc`, `ground.gdshader`, `ground_fill.gdshader`, `GroundLook.put`): o preenchimento vermelho
  dos avisos dos inimigos sai numa segunda passada, fraco (`fill_early` 0,1) e subindo até `fill_max` 0,35 só nos
  últimos 30% do preparo (`fill_late`); onde avisos se cruzam só o primeiro preenchimento aparece (stencil 2, a multidão
  usa 1): três avisos não somam mais que um. Borda, divisa e assinatura de Morvath iguais. Vermelho medido dentro de um
  aviso cheio sob o herói: 146 para 91; no cruzamento 144 para 109; o anel do herói aparece dentro deles.
- **Círculo de luz** (estilo 2 do `ground`): aro a 0,8 da força (0,44), metade da largura (`circle_rim_width` 0,25 do
  `rim_m`), marcas mais finas e fracas (`circle_mark_span` 0,1, `circle_mark_light` 0,45).
- **Queimadura em elites, guardiões e Morvath** (`crowd.gdshader`, quem tem `rim_power`): borda de fogo até
  `burn_rim_own` 0,25, brasas pela metade (`burn_coals_own`), a borda própria fica a `burn_keep_own` 0,7. Morvath
  queimando na fase 3: pixels quentes saturados no recorte dele 11 a 13% para 4 a 5,5%, matiz mediano 269 a 277.
- **Lascas** (`chip.gdshader`, novo): lasca alongada no sentido do voo (2:1 a 4:1), mais clara no meio. Encaixada na
  MultiMesh das partículas do `Fx` (todas: as do golpe e as do acerto; `MOTE_WIDTH` 0,5 do tamanho, comprimento
  `MOTE_STREAK` 0,03 s do voo entre 2 e 4 larguras, `Fx.streak`). Lascas do acerto: `Combat.CHIP_COLOR` 0,42 / 0,4 /
  0,37 (vezes `MOTE_GLOW`), 6 m/s, 0,08 m, vida até 0,22 s. Medido a 60 Hz: num acerto comum a última some 15 quadros
  depois (0,25 s, 7,5 quadros do vídeo de 30); num abate o hit stop estica para 17 (0,28 s), com a última já em 0,09 da
  luz no 8º quadro do vídeo.
- **Colunas de luz** (`beam.gdshader`): continuam pré-multiplicadas sob o teto da tela (235), mas cada face deposita só
  uma parte do teto (`body` 0,68), com lados suaves (`side_soft` 1,6), miolo mais claro e pálido (`core_width` 8,
  `core_light` 0,6, `core_white` 0,45), somem em degradê a partir de 15% da altura (`top_from`, altura pelo vértice),
  pé suave (`foot` 0,55) e veios subindo (`streaks` 0,2). No recorte da coluna da recompensa: maior canal mediano 229
  chapado antes, 224 a 83 em degradê depois, o chão e o sarcófago aparecem através.

## E1b: o especial como onda da lâmina (W-1, D-69), velas do salão (VX-13), chão da Cripta (M-1)

Medido na GPU (Forward+, 1920 x 1080); quadros em `docs/gallery/e1b/vfx/` e `env/` (antes e depois lado a lado).

- **Onda da lâmina** (`emeth_wave.gdshader`, `Projectiles.WAVE_*`): a Seta de Luz é uma meia-lua curta e fina deitada a
  1,1 m, barriga para onde voa (o `Fx.crescent` em pequeno): 1,6 m de ponta a ponta, barriga 0,38 m, faixa 0,2 m, rastro
  até 0,9 m crescendo com o voo, abre de 55% a 100% da largura no primeiro 1,2 m. Borda de ataque pálida (`edge_pale`
  0,35), corpo esmeralda a 0,55 da borda afinando para trás, fio de ouro velho no meio (`vein_at` 0,45, `gold_light`
  0,85). Deposita-se por cima do que está atrás (`blend_premul_alpha`, tinta 0,3 atrás da luz) e abre em volta do herói
  (`hero_hole` 0,7 x 1,45 m, fica 0,15). Brilho: maior canal no material até 1,0 (`WAVE_PEAK`, glow começa em 1,3) e
  rebaixado por cor para a borda não passar de 226 na tela (`Projectiles.wave_peak`, `ScreenTone.linear_peak`; a 1,0 a
  borda ia a 255). Ômega do especial: a mesma onda da largura do acerto (8,25 m), barriga 0,24 da largura, faixa 0,4 m,
  rastro 1,4 m; maior canal medido na onda 228. Some no fim do voo em 0,04 s (Ômega 0,12 s). Regra, velocidade, alcance,
  círculo do acerto, dano e tempos iguais (`tests/test_special_wave.gd`).
- **Velas do salão (VX-13)**: 5 dos 10 grupos da borda apagados (`Masonry.candle_out`, cera a 0,4 da cor, pavio, sem
  chama, halo nem luz): leste, canto nordeste, pedra sul, patamar e o de z 2,2 da balaustrada oeste; 5 luzes de vela a
  menos. Vitrine (`--showcase --seed=5`, pixels com R acima de 200 e B abaixo de 120 entre as linhas 80 e 880): 23091
  para 18025 (menos 22%); o chão central de 57,8 para 53,6, oeste 51,4, sudeste 55,1 (acima de 45). Pela metade não dá
  sem mexer nos braseiros: só eles somam cerca de 10 mil desses pixels (o braseiro do sudeste, perto da câmera, 5 mil).
- **Chão da Cripta (M-1)**: luz de preenchimento só do chão (`CryptLook.FLOOR_FILL*`: omni sem sombra em (-9; -1,5) a
  6 m, 1,8, alcance 16, queda 0,6; `light_cull_mask` = `ArenaRoom.FLOOR_LAYER` 64). Recortes do QA-02 (mediana de luminância,
  `crypt_vX_c`): A norte 34 para 55, A sul 50, A sudeste 49; B oeste 39 para 46, B norte 32 para 47, B sul 56, B leste 46.
  O recorte "A oeste" (230, 440) fica em 19: dois terços dele são a face da parede e o nicho com ossos, que ficam escuros de
  propósito (a parede medida antes e depois: 21,8 e 21,8); o chão dentro dele (345, 495, 60 x 35) foi de 40 para 48.

## Pendências

1. Colocar o `paladin_1` no jogo. Não foi feito: o esqueleto do Meshy (24 ossos, `Hips`, `LeftArm`...) é outro, e os
   golpes do Knight precisam ser redirecionados. Caminho: importar os dois GLB com `BoneMap` para o
   `SkeletonProfileHumanoid` (Godot reaproveita as animações entre esqueletos do mesmo perfil), conferir a pose de
   descanso (o Meshy vem em pose A) e prender a espada na mão direita (`RightHand`). Sem créditos.
2. Arena do chefe puxando para o roxo azulado: feito na fase 4 de Morvath (`RoomMood.LAST_BREATH`, ciclo 10); as fases 1
   a 3 seguem com o ar da sala.
3. Explosões de cristais ou espinhos brotando do chão nos finalizadores grandes.
4. Medir desempenho em placa de vídeo fraca (o contorno dos elites é uma passada a mais só nos elites e no chefe).
