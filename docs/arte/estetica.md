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
  chegando de todos os lados. A nossa (`Feel`: distância 44, inclinação 50, campo de visão 32) está perto.

## 5. Personagens

- Proporções adultas e esguias: cabeça pequena, pernas longas. Nada de cabeçudo.
- Textura pintada à mão, cores apagadas e um único acento forte (no nosso paladino, a capa vermelha).
- Modelos do Meshy: ver `tools/meshy/` (prompts, tarefas e créditos) e `assets/models/meshy/`.

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

## Pendências

1. Colocar o `paladin_1` no jogo. Não foi feito: o esqueleto do Meshy (24 ossos, `Hips`, `LeftArm`...) é outro, e os
   golpes do Knight precisam ser redirecionados. Caminho: importar os dois GLB com `BoneMap` para o
   `SkeletonProfileHumanoid` (Godot reaproveita as animações entre esqueletos do mesmo perfil), conferir a pose de
   descanso (o Meshy vem em pose A) e prender a espada na mão direita (`RightHand`). Sem créditos.
2. Arena do chefe puxando para o roxo azulado (hoje só a porta muda de luz).
3. Explosões de cristais ou espinhos brotando do chão nos finalizadores grandes.
4. Medir desempenho em placa de vídeo fraca (o contorno dos elites é uma passada a mais só nos elites e no chefe).
