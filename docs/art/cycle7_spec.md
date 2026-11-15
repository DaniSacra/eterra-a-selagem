# Ciclo 7: impacto da Emeth, leitura do herói e dos inimigos, retoques de arena e HUD (especificação, 2026-11-15)

Autor: Art Director. Nada aqui foi implementado. Pedido do Daniel, por prioridade: P0 tela de título (outros agentes
estão terminando; fora desta especificação, só entra no contrato de capturas), P1 impacto da Emeth, P1 leitura do
Explorador em lutas de 40 e 90 inimigos, P1 leitura do papel de cada inimigo, P2 retoques de arena, P2 polimento do HUD.

**Não muda neste ciclo:** mecânica, balanceamento, dano, alcance, tempos, história; a arena (só retoques), os modelos
dos inimigos, o Explorador, a Emeth e Morvath continuam os mesmos; escala e colisão do herói; nada de Meshy nem de
serviço pago; nada de lore novo (símbolos e emblemas: perguntar ao Daniel).

## 0. Evidência e linha de base

Capturas reais na placa do Daniel (RTX 5060 Laptop, Vulkan Forward+), árvore de trabalho sobre o HEAD `c561101`
(havia mudanças sem commit da tela de título em `scripts/boot.gd`, `scripts/ui/title_*`; nenhum arquivo de jogo alterado).

"Antes" que já existia (1672 x 941 salvo indicação), em `docs/gallery/`:
`jogo/11_titulo.jpg`, `jogo/final_vitrine.jpg`, `jogo/final_luta.jpg`, `jogo/final_boss.jpg`, `jogo/8_horda90.jpg`,
`jogo/9_cercado40.jpg`, `jogo/3_sacerdote.jpg`, `jogo/4_elite.jpg`, `jogo/5_medalhao.jpg`, `jogo/10_combate_1920.jpg`,
`enemies/_todos_game.jpg`, `enemies/_todos_front.jpg` e as faixas por inimigo.

"Antes" que faltava e foi capturado para este ciclo, em `docs/art/shots/cycle7_before/`:

| Arquivo | Comando (depois de `--`) | O que mostra |
|---|---|---|
| `emeth_ataque.jpg` (1280 x 720) | rajada `--bot --autopick --seed=5 --frames=<prefixo> --shot-at=5 --count=24 --every=0.03`, quadro 1 | corte leve no ar |
| `emeth_impacto.jpg` (1280 x 720) | a mesma rajada, quadro 9 | acerto de golpe forte |
| `emeth_especial.jpg` (1280 x 720) | rajada `... --shot-at=2 --count=40 --every=0.1`, quadro 19 | Seta de Luz voando |
| `emeth_circulo.jpg` (1280 x 720) | a mesma, quadro 14 | círculo de luz no chão |
| `emeth_omega.jpg` (1280 x 720) | a mesma, quadro 38 | Lança de Luz (Ômega) com a meia-lua |
| `explorador_idle.jpg` | `--start=fountain --seed=5 --cam-dist=26 --shot-at=3` | herói parado, câmera perto |
| `explorador_corrida.jpg` | `--start=fountain --bot --seed=5 --cam-dist=26 --shot-at=1.5` | herói correndo |
| `guardiao_cavaleiro.jpg` | `--start=miniboss --bot --autopick --seed=5 --shot-at=9` | Cavaleiro (guardião) |
| `sala_fonte.jpg` | `--start=fountain --seed=5 --shot-at=3` | sala da fonte, porta amarela |

As rajadas saíram em 1280 x 720 porque `--frames` sem `--shot` deixa o `App.apply_options` redimensionar a janela
(`scripts/app.gd:21`); ver a seção 8.

Medidas: `tools/art_metrics.py` (caixas do enquadramento `--showcase --seed=5`) e scripts de `python3 -I` com ffmpeg
(média e desvio de luminância L, parcelas de cor por caixa). Coordenadas abaixo: pixels da captura citada,
`(x0,y0)-(x1,y1)`.

## 1. Regras que valem para as cinco áreas

1. **Só apresentação.** Nenhuma constante de dano, alcance, tempo, velocidade, vida, colisão ou IA muda. Prova:
   `tools/smoke.sh 300 --seed=5`, `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` e
   `tools/smoke.sh 120 --stress=300 --seed=5` devolvem a mesma linha `RESULT` (tempo, abates, dons, vida de Morvath)
   antes e depois. O QA tira a linha de base no `c561101` antes de qualquer agente começar.
2. **Aleatório de enfeite fora do sorteio do jogo.** Tremor, faísca e variação visual usam um gerador próprio ou um
   número derivado do índice do inimigo, nunca `Horde._rng`, `Game._rng` nem o do `Boss` (senão a regra 1 quebra).
3. **Nada permanente na tela.** Todo efeito nasce de um evento real do combate (golpe solto, acerto, preparo de
   ataque, armadura quebrada, morte) e some em no máximo 0,6 s. Exceções que já existem: anel do herói, barras de
   vida, avisos de ataque, o círculo de luz (dura o que a mecânica manda, mas discreto: seção 2.6).
4. **Vermelho é do perigo.** Nenhum efeito novo usa vermelho no chão. Verde esmeralda é da Emeth e do portal;
   violeta é da magia inimiga; ouro velho é de elite e armadura; branco puro só por 1 ou 2 quadros.
5. **Custo.** Efeitos em reservas fixas (como `Fx.*_POOL`), sem nó novo por inimigo, sem luz nova com sombra. Medido
   na mesma sessão, antes e depois (sonda do QA, 300 quadros): `--showcase` no máximo +0,1 ms; luta no máximo
   +0,2 ms; `--stress=90` no máximo +0,4 ms; `--stress=300` no máximo +0,5 ms por quadro.
6. Placeholder continua placeholder: estátuas, moldura do portal e ruínas seguem provisórias até os modelos do
   `meshy_asset_plan.md`; ninguém declara fidelidade alta por causa deste ciclo.

## 2. P1: impacto da Emeth

Dono: Gameplay Engineer, frente A (efeitos). Arquivos na seção 7.

### 2.1 Problemas vistos

| # | Captura e caixa | Problema |
|---|---|---|
| E1 | `emeth_ataque.jpg` (600,265)-(690,365) | o corte leve é um leque de 4 ou 5 faixas concêntricas iguais (lê como radar ou leque de papel), com a ponta cortada reta; começo e fim do leque têm o mesmo brilho, então a imagem parada não diz para que lado a lâmina girou |
| E2 | `emeth_impacto.jpg` (525,295)-(640,375) e `emeth_omega.jpg` (485,300)-(585,415) | no golpe forte o miolo estoura em branco: herói e inimigos viram uma mancha branca única de cerca de 100 x 115 px (em 720 linhas); a Emeth vira holofote e some o próprio herói |
| E3 | `emeth_ataque.jpg` (540,310)-(610,355) | a marca de acerto é um anel branco com cruz (lê como mira de interface, não como corte); igual em todo golpe, sem direção |
| E4 | `emeth_omega.jpg` (90,385)-(1030,620) | a meia-lua do Ômega tem 940 px de largura em 1280 (73% da tela) e cerca de 60 px de espessura com miolo branco; cobre obelisco, velas e chão; mais as faixas retas listradas de preto e verde em (400,155)-(480,215) e (590,420)-(700,545), que leem como escada ou película |
| E5 | `emeth_especial.jpg` (570,300)-(740,410) | a Seta de Luz é uma fileira de bolas de fogo amarelas com halo quente, uns 170 px de comprimento: não parece vir da Emeth (verde), não tem forma de seta e se confunde com braseiro e com dom de fogo |
| E6 | `emeth_circulo.jpg` (285,240)-(570,385) | o círculo de luz é um disco creme opaco de 285 x 145 px (em 720 linhas): L médio 146 contra 56 do chão; apaga as lajes, achata a cena por 3 s e tira contraste do herói que luta em cima dele |
| E7 | `9_cercado40.jpg` (330,395)-(660,580) | 24 números verdes numa área de 330 x 185 px, do mesmo verde da Emeth, uns sobre os outros e sobre as barras de vida |
| E8 | `emeth_impacto.jpg`, rajada quadros 8 a 10 | inimigo atingido por golpe forte fica branco chapado por 3 quadros seguidos a 30 qps (0,1 s) sem pose de reação visível |
| E9 | `emeth_omega.jpg`, velas em (170,420)-(250,480) | aberração cromática forte na tela toda (franjas verdes e magenta nas velas) junto do clarão |

O que já está certo e fica: estrela e tranco só existem dentro do laço dos atingidos (`Combat.strike`), tinta escura
sob o corte, câmera lenta, cortes do verde da Emeth, cor dos dons.

### 2.2 Rastro do golpe normal (curto e com direção)

- Forma: uma fita só, não faixas concêntricas. Larga na ponta que avança (até `Fx.SLASH_INNER` atual) e afinando
  até zero na cauda; a cauda cobre no máximo 60% do arco do golpe (o alcance desenhado continua igual ao que acerta:
  a borda de fora do arco não muda).
- Direção: o terço da frente (lado para onde a lâmina vai, já dado por `ComboNode.sweep` e `flip`) é o mais claro;
  o brilho cai ao longo da fita. Dois fios finos claros podem acompanhar a borda de fora (o fio da lâmina).
- Cor: esmeralda `Combat.EMETH` no corpo, miolo claro (não branco puro) só no terço da frente.
- Tempo: golpe leve claro por no máximo 0,12 s; pesado 0,16 s; finalizador 0,3 s (como hoje). A tinta some em até
  0,3 s depois.
- Pequenas partículas de magia: 4 a 8 por golpe, saindo da ponta da fita na direção do giro, esmeralda com um ponto
  de ouro velho a cada 4, tamanho no máximo 0,12 m, vida no máximo 0,4 s.

Aceite (rajada `06_emeth_ataque`, seção 9):
- A1. Na imagem parada, o L médio do terço da frente do arco é pelo menos 1,6 vez o do terço de trás.
- A2. Nenhuma faixa concêntrica separada: um corte radial pelo meio da fita cruza uma única banda clara.
- A3. O verde do golpe leve aparece em no máximo 4 quadros seguidos a 30 qps; 10 quadros depois não resta nada dele.
- A4. Pixels com os três canais acima de 235 numa caixa de 300 x 220 px centrada no herói: no máximo 3% no golpe
  leve, 6% no pesado, 10% no finalizador (medir o antes com a mesma caixa e registrar).

### 2.3 Brilho controlado (a Emeth não é holofote)

- Nenhuma luz (`OmniLight3D`) nova acesa pelo golpe. O chão fora do arco não clareia: L médio de uma caixa de
  200 x 100 px de chão a mais de 6 m do herói varia no máximo 8% entre o quadro anterior ao golpe e o do golpe.
- Lâmina: `EmethSword.BLADE_GLOW` continua abaixo do limiar do glow parada; durante o golpe pode subir até 1,6 por
  no máximo 0,15 s (pulso), voltando ao valor parado.
- Quadro de impacto preto e branco: regra de hoje (finalizador em 6 ou mais, elite, chefe). Não ampliar.
- Aberração cromática (`kick_split`): só no finalizador, no máximo 0,5 (hoje 0,8), e só perto das bordas da tela;
  no centro (raio de 30% da altura) nenhuma franja visível nas velas.
- Meia-lua do finalizador e do Ômega (`Fx.crescent`): largura na tela no máximo 45% da largura da captura,
  espessura no máximo 28 px em 720 linhas, miolo claro em no máximo um terço da espessura, vida 0,3 s. As faixas
  retas do golpe em linha (Lança de Luz) viram uma estocada: um feixe fino esmeralda que afina na ponta, sem
  listras transversais.

Aceite (captura `06b_emeth_omega`, auxiliar): B1 largura e espessura acima; B2 herói reconhecível no quadro do
golpe (cabelo cobre visível: pelo menos 30 pixels com R > 150, R > G + 40, R > B + 60 na caixa do herói); B3 nenhuma
faixa listrada.

### 2.4 Acerto de verdade

- Só em acerto real (já é assim; fica travado por teste): novo teste GUT em que `Combat.strike` sem inimigo no
  alcance não gera estrela, partícula de acerto, número, tranco, tremor nem hit stop.
- Marca de acerto: troca o anel com cruz por um talho: um risco curto (0,9 a 1,4 m; 1,8 m no pesado) alinhado com
  a tangente do giro no ponto atingido, miolo claro e borda esmeralda, vida 0,12 a 0,18 s, mais 4 a 6 lascas
  esmeralda de até 0,1 m voando para o lado de `away`, vida até 0,35 s. Continua limitado por `Combat.MAX_STARS`.
- Diferença por golpe: leve um talho; pesado talho maior com um segundo risco cruzado fino; finalizador o talho mais
  um anel fino que cresce até 1,5 m e some em 0,2 s (uma vez por golpe, não por inimigo).
- Números: branco pálido (`UiKit.PALE`) para o dano comum, esmeralda só no finalizador e no Ômega, ouro no dano de
  dom de Elun (as cores de fogo e gelo dos dons ficam). Com mais de 8 números novos num raio de 3 m em 0,25 s,
  mostrar os 8 maiores. O número nasce 0,25 m acima da barra de vida, nunca em cima dela.

Aceite (`07_emeth_impacto` e `19_combate_40_inimigos`): C1 teste GUT passa; C2 nenhum anel com cruz; C3 o talho tem
ângulo diferente em dois inimigos atingidos de lados opostos do arco; C4 em `19` no máximo 8 números sobrepostos por
grupo e nenhum cobrindo mais de 30% de uma barra de vida.

### 2.5 Especial diferente do ataque

- Ataque: arco (fita curva). Especial (Seta de Luz): **reta**. Um dardo esmeralda de 1,6 a 2,0 m de comprimento por
  no máximo 0,3 m de largura (proporção na tela de pelo menos 4 para 1), ponta clara, um fio de ouro velho no eixo
  (os veios da Emeth), rastro de 1,5 m que some em 0,2 s. Sem halo quente no chão, sem bola.
- Acerto do especial: uma estocada (risco alongado na direção do voo, 1,2 m) em vez do talho do ataque.
- Ômega do especial: o mesmo dardo mais largo (0,45 m) com dois dardos finos colados; nunca a meia-lua do ataque.
- O dom que muda a cor do golpe continua mudando a cor do dardo.

Aceite (`08_emeth_especial`): D1 caixa do projétil com proporção de 4 para 1 ou mais; D2 cor dominante verde
(G > R + 40 em mais de 60% dos pixels claros do projétil); D3 nenhum pixel quente (R > 200 e R > B + 70) a mais de
0,5 m do dardo que não seja vela ou braseiro.

### 2.6 Círculo de luz

- Mesma área e mesma duração. O preenchimento cai para um véu: L médio dentro do círculo no máximo 18 acima do chão
  ao lado (hoje +90). A leitura fica na borda: aro fino claro com largura fixa (`RIM_METERS`), mais 6 a 8 marcas
  curtas girando devagar por dentro da borda. Cor: a de hoje (`Combat.CAST_COLOR`), sem creme chapado.
- Avisos vermelhos por cima do círculo continuam com a mesma cor e o mesmo brilho que fora dele.

Aceite (captura auxiliar `08b_emeth_circulo`): F1 a diferença de L acima; F2 as juntas das lajes continuam visíveis
dentro do círculo; F3 aviso vermelho que cruza a borda do círculo não muda de cor (diferença de L média até 8).

### 2.7 Reação dos inimigos ao golpe (com a frente C)

- Branco chapado por no máximo 0,07 s (2 quadros a 30 qps); depois a pose `hit` do próprio inimigo (todos têm)
  por `Horde.HURT_TIME`, com o achatamento de hoje. Inimigo pesado (`def.heavy`) e guardião: sem recuo de pose
  inteira, só um tranco curto do tronco (a pose `hit` a meia força) para não parecer leve.
- Armadura: golpe absorvido solta 3 ou 4 fagulhas de ouro velho e um brilho curto na borda, sem branco chapado
  (o jogador vê que não feriu). Quebra da armadura: estilhaços de ouro velho (10 a 14, 0,35 s), uma vez.
- O `flash_power` é escrito em `combat.gd` (frente A) e lido em `horde.gd` (frente C): a frente A não muda o valor;
  a duração e a pose são da frente C.

## 3. P1: leitura do Explorador em lutas de 40 e 90 inimigos

Dono: Gameplay Engineer, frente B (herói). Sem mudar escala, colisão, cabelo ruivo, cachecol petróleo, couro e Emeth.

### 3.1 Problemas vistos

| # | Captura e caixa | Problema |
|---|---|---|
| H1 | `8_horda90.jpg` (565,380)-(640,460) | no meio do bolo o herói é uma silhueta ciano chapada com traço branco azulado: nenhuma cor dele (o guia diz "nas cores dele"; a captura mostra um fantasma ciano). Não dá para ver para onde olha nem onde está a espada |
| H2 | `final_boss.jpg` (780,370)-(870,480) e `explorador_corrida.jpg` (1190,200)-(1290,260) | coberto pela metade (Morvath, obelisco), metade do corpo fica ciano e metade normal: lê como dois personagens |
| H3 | `9_cercado40.jpg` (250,500)-(360,625) e `emeth_omega.jpg` (485,300)-(585,415) | ao levar golpe (e no clarão do golpe forte) o herói vira silhueta branca inteira; branco também é a cor do inimigo atingido, então herói e inimigo se confundem |
| H4 | `8_horda90.jpg`, mesma caixa | a Emeth não aparece dentro do bolo; a lâmina é o que identifica o herói e some |
| H5 | `final_luta.jpg` (805,388)-(880,478) | em campo aberto está bom (L médio da caixa 77 contra 46 do chão em volta); a direção do corpo só se lê pela espada; o anel petróleo fino não aponta para lugar nenhum |
| H6 | `emeth_circulo.jpg` | sobre o disco creme (E6) o herói perde contraste; resolvido pela seção 2.6 |

### 3.2 O que fazer

1. **Raio-x nas cores dele.** Onde algo cobre o herói, desenhar a textura dele (cabelo cobre, cachecol petróleo,
   couro), com as sombras levantadas (o `dark` de hoje vira só um piso de luz, não a cor da silhueta) e opacidade
   0,85. A passagem de coberto para descoberto não pode mudar a cor do corpo.
2. **Borda discreta.** A linha clara do raio-x (`xray_edge`) vira um fio quente claro (marfim, não ciano) de no
   máximo 1,5 px em 941 linhas e opacidade até 0,5, só onde ele está coberto. Descoberto, só a borda fria fina de
   hoje (`Player.EDGE`), sem engrossar. Nada de contorno branco grosso.
3. **Sem silhueta branca.** Ao levar golpe: 1 quadro (até 0,05 s) de clarão, depois o pisca alterna a cor normal
   com a cor normal 35% mais clara, nunca branco chapado. No clarão do golpe forte o herói fica de fora do branco.
4. **A Emeth sempre visível.** A lâmina entra no raio-x (desenhada por cima do que a cobre, a 80%), com o brilho
   de sempre (abaixo do limiar do glow).
5. **Direção do corpo.** O anel do chão ganha uma cunha mais clara de 30 graus do lado para onde ele olha
   (`Player.facing`), 1,4 vez o brilho do resto do aro; o aro continua fino e petróleo. Sem seta nova.
6. **Luz.** A luz própria e o `HeroBody.FILL` ficam. Acrescentar uma luz de recorte pintada no shader do herói
   (vinda de cima e da esquerda da tela, a mesma direção `KEY` da multidão), no máximo 0,25 de ganho, para o ombro
   e o cabelo destacarem do bolo. Sombra de contato de hoje.
7. A multidão não muda de cor por causa do herói (isso é da frente C); o herói precisa ser o único corpo saturado.

### 3.3 Aceite (capturas `19_combate_40_inimigos` e `20_combate_90_inimigos`, mesmos comandos do antes)

- G1. Caixa justa do herói: pixels de cabelo cobre (R > 150, R > G + 40, R > B + 60) em pelo menos 5% da caixa e
  pixels petróleo ou verde do cachecol (G > R + 25, B > R + 5, L > 60) em pelo menos 5%, com ele coberto ou não.
- G2. Ciano puro (G > 170, B > 170, R < 140) em no máximo 3% da caixa do herói.
- G3. Nenhum quadro de uma rajada de 24 quadros com mais de 10% da caixa do herói em branco (três canais > 235),
  fora 1 quadro no instante do golpe recebido.
- G4. Lâmina: um segmento verde contínuo de pelo menos 20 px visível em `19` e `20`.
- G5. Campo aberto (`04_explorador_idle`, `05_explorador_corrida`): L médio da caixa do herói pelo menos 1,4 vez o
  do chão em volta (hoje 1,67 em `final_luta`): não piorar.
- G6. Largura da borda: no recorte 4x, nenhum trecho de contorno claro com mais de 2 px (em 941 linhas).
- G7. A cunha do anel aponta para o lado da espada estendida em `05` e em `06`.
- G8. `--outline=0` continua desligando o raio-x.

## 4. P1: leitura do papel de cada inimigo (sem trocar modelo, não só por cor)

Dono: Gameplay Engineer, frente C (inimigos). Permitido: material, acessório pequeno preso no assado (`held`),
postura das animações, variação discreta de cor, efeito de preparo do ataque, leitura da arma, retorno da armadura.

### 4.1 Problemas vistos

| # | Captura e caixa | Problema |
|---|---|---|
| I1 | `_todos_front.jpg` (440,290)-(600,375); `8_horda90.jpg` (300,420)-(700,640) | Esqueleto e Corredor têm a mesma paleta (osso e tanga ferrugem); no bolo só a altura separa (o Corredor tem 1,72 m contra 2,2 m), e curvado ele some atrás dos outros |
| I2 | `_todos_front.jpg` (655,265)-(710,370) | Feiticeiro: o cajado de caveira não brilha parado; as gemas aparecem como quadrados brancos estourados (texels sem cor) e não como magia violeta |
| I3 | `_todos_front.jpg` (760,285)-(800,370); `archer_aim_side.jpg` | Arqueiro: a besta é um toco marrom sobre capa escura; de frente (câmera do jogo) não lê como arma de longe; capuz escuro igual ao do Sacerdote |
| I4 | `final_vitrine.jpg` (345,435)-(430,545); `guard_hit_side.jpg` | Escudo: a silhueta é boa, mas o escudo é carvão sobre chão escuro (some a 54 m) e nas poses de andar e de levar golpe o escudo vai para o lado ou para trás: não parece defensivo |
| I5 | `_todos_front.jpg` (965,285)-(1030,370); `priest_cast_side.jpg` | Sacerdote: figura encapuzada roxo escuro sem cajado e sem brilho; o gesto de lançar é só um braço apontando; nada diz ritual |
| I6 | `4_elite.jpg` (735,350)-(800,460) | Elite: o ouro velho cobre o corpo todo, inclusive a caveira (fica amarela); perde o marfim que identifica o esqueleto |
| I7 | `final_boss.jpg` (830,330)-(940,520); `_todos_front.jpg` (1180,160)-(1390,370) | Morvath: no laboratório a túnica é violeta com ouro e a gema do peito brilha; no jogo ele lê cinza e marrom, a gema não aparece, e o orbe do cajado do Ancião (guardião) brilha mais que o chefe inteiro |
| I8 | `8_horda90.jpg` (300,420)-(700,640) | barras de vida vermelhas ocupam 3,4% da caixa do bolo e formam uma grade por cima das cabeças |
| I9 | `guardiao_cavaleiro.jpg`, `3_sacerdote.jpg` | guardiões: a escala está certa (4,2 e 4,5 m contra 2,75 m do herói) e a barra do topo ajuda; falta retorno claro da armadura (ter, absorver, quebrar) no corpo |

### 4.2 Assinatura de cada papel (silhueta, postura, preparo)

Todos os preparos duram o `attack_windup` que já existe; nenhum usa vermelho; todos somem ao soltar o ataque.

| Inimigo | Silhueta e postura (parado e andando) | Preparo do ataque | Material |
|---|---|---|---|
| Esqueleto (corpo a corpo) | ereto, lâmina visível além do corpo (pelo menos 0,5 m fora da silhueta na câmera do jogo) | lâmina erguida acima da cabeça; brilho pálido curto no fio a partir de 50% do preparo | o mais apagado da multidão: é a linha de base |
| Corredor (rápido, instável) | tronco inclinado 35 graus ou mais, braços soltos até o joelho, sem arma; ao correr, balanço lateral do tronco de 6 a 8 graus a 9 Hz e passo irregular (só desenho: `tilt` e achatamento do `CrowdRenderer.add`; a posição não muda) | agacha (clipe `windup`) com tremor de 0,04 m a 14 Hz; poeira no arranque e dois riscos de velocidade de 1 m atrás dele durante a investida | osso mais quente e sujo que o Esqueleto, tanga mais curta e escura |
| Feiticeiro (magia) | cajado mais alto que a cabeça em pelo menos 0,4 m; orbe do cajado aceso sempre, fraco (violeta frio `magic_color`, 1,2, abaixo do limiar do glow) | orbe cresce de 1 para 1,8 e passa do limiar; 3 ou 4 faíscas sobem em espiral do orbe | corrigir os quadrados brancos (brilho da pintura tingido por `magic_color`, nunca branco puro) |
| Arqueiro (à distância) | besta na horizontal, saindo pelo menos 0,6 m à frente do corpo parado e andando (hoje só na mira); corpo de lado para o alvo, pés afastados | para e planta os pés; a linha de aviso de hoje fica; faísca pálida na ponta do virote ao disparar | arco e ponta da besta em metal claro (a besta pode crescer até 1,25 no `held`) |
| Esqueleto de Escudo (pesado, defensivo) | escudo sempre na frente do corpo, cobrindo pelo menos 45% da largura e da altura da figura vista da câmera do jogo; passo curto e baixo | escudo sobe e recua; traço pálido na borda do escudo na batida | borda do escudo em metal claro gasto (fio de 3 a 4 cm) e arranhões claros na face, para a chapa ler no escuro |
| Sacerdote dos Mortos (ritual) | túnica até o chão com base de pelo menos 1,4 vez a largura dos ombros, mãos afastadas do corpo com as palmas para cima; olhos com brilho violeta fraco constante | as duas mãos sobem; aro fino violeta de 1,2 m no chão em volta dele (opacidade até 0,3, não é aviso) e 3 partículas girando entre as mãos | roxo um pouco mais vivo que o do Arqueiro; nenhum objeto novo com símbolo (não inventar lore) |
| Cavaleiro e Ancião (guardiões) | como estão (escala e barra do topo) | os de hoje | borda de ouro velho fraca enquanto a armadura está de pé; some quando quebra, com o estilhaço da seção 2.7 |
| Morvath (chefe) | coroa recortada contra o chão (luz de recorte pálida no alto), túnica violeta legível, gema do peito e olhos acesos sempre | os avisos de hoje | túnica com a saturação da pintura original (menos cinza da multidão: `CROWD_GREY` próprio do chefe), gema e olhos acima do limiar do glow; nada dele muda de tamanho |

Elites: ouro velho só no metal (lâmina, elmo, ombreira, escudo, fivelas); caveira e ossos continuam marfim; pano
continua na cor do comum. Contorno escuro fino e barra amarela como hoje.

Barras de vida com muita gente: acima de `Horde.BARS_FOR_ALL` a regra de hoje fica (só os feridos); as barras passam
a 70% de opacidade e 75% da altura enquanto houver mais de 24 inimigos de pé.

### 4.3 Aceite

- J1. Teste de silhueta: `09_inimigos_comparativo` convertida para preto e branco chapado (limiar de L 40): os seis
  comuns se distinguem dois a dois pelas medidas da tabela (lâmina fora do corpo, cabeça do Corredor abaixo de 78% da
  do Esqueleto e tronco a 35 graus, cajado 0,4 m acima da cabeça, besta 0,6 m à frente, escudo cobrindo 45%, base da
  túnica 1,4 vez os ombros).
- J2. Teste sem cor: `10_inimigos_em_combate` em tons de cinza; o Art Director identifica o tipo de cada inimigo da
  cena; registra em `visual_review.md` quais errou.
- J3. Orbe do Feiticeiro: pelo menos 12 pixels acesos violeta (B > 150, B > G + 40) na câmera do jogo, parado; nenhum
  pixel branco puro no cajado.
- J4. Elite (`11_inimigo_elite`): matiz da caveira do elite a até 10 graus da caveira do comum ao lado.
- J5. Morvath (`13_morvath`): na caixa do corpo, pixels violeta (B > R + 10, R > G + 8) em pelo menos 25%; pelo menos
  20 pixels com L > 180 na gema e nos olhos; saturação média da caixa pelo menos 1,5 vez a de um inimigo comum.
- J6. Preparo: numa rajada de `10`, cada tipo mostra o preparo descrito pelo menos 2 quadros antes do ataque; nenhum
  efeito de preparo em vermelho.
- J7. Barras: pixels de barra vermelha (R > 200, G < 60, B < 60) em no máximo 2% da caixa do bolo em `20`.
- J8. Regras 1, 2 e 5 da seção 1.

## 5. P2: retoques de arena (sem reconstruir)

Dono: Environment Artist. Enquadramento de medida: `--showcase --seed=5 --shot-at=4` (1672 x 941), caixas do
`tools/art_metrics.py` quando existem. Pendências do ciclo 6 (`cycle6_final.md`, correções 2, 3 e 6) continuam valendo.

### 5.1 Estátuas

Visto em `final_vitrine.jpg`:
- gigante (275,5)-(360,240): L médio 34,6, desvio 19,7; o vão do capuz é um oval preto chapado em (305,20)-(330,55)
  que lê como furo ou anel, não como capuz; o corpo é um torno liso sem dobras; só a faixa dos braços cruzados dá volume;
- estátua direita do portal (1415,110)-(1480,270): L médio 32,6, desvio 11,5 (quase uma silhueta chapada);
  esquerda (1150,70)-(1215,225): desvio 23,1;
- estátua nordeste (910,40)-(960,140): amarela ocre sob o braseiro, parece outro material (plástico).

Pedido (em `Masonry._build_statue` e nos chamadores; peça provisória até o modelo do Meshy):
- capuz com aba: uma borda saliente em volta do vão (0,06 da altura), topo do capuz caindo em ponta para trás;
  dentro do vão, uma face recuada escura com gradiente (não preto chapado);
- manto: 7 a 9 pregas verticais (o `pleat` do `_lathe`) da cintura à base, mais fundas embaixo; ombros com 1,6 vez a
  largura da cabeça; mangas largas onde os braços se cruzam; base do manto mais larga que o plinto;
- sombra: escurecer por altura sob a aba do capuz, sob os braços e na base (cor de vértice), mais a sombra de contato
  no plinto;
- material: a mesma pedra `Masonry` nas cinco, com tinta por estátua variando só o valor; a nordeste deixa de ficar
  amarela (reduzir a luz do braseiro sobre ela ou a camada de luz, não a cor do fogo).

Aceite: K1 desvio de L de pelo menos 18 em cada uma das três caixas; K2 no recorte 4x a aba do capuz é pelo menos
25 de L mais clara que o vão, e o vão não tem pixel mais claro que a aba; K3 pelo menos 5 pregas contáveis no manto
do gigante no recorte 4x; K4 matiz médio das cinco estátuas dentro de 20 graus entre si; K5 primitivas da vitrine
no máximo +6 mil.

### 5.2 Abismo

Visto em `final_vitrine.jpg`: canto de baixo à direita (1500,820)-(1672,941) L médio 24, desvio 10,3 (plano chapado
azul petróleo); colunas violeta da esquerda (0,280)-(260,700) são painéis lisos de borda reta (leem como vidro);
canto de baixo à esquerda (0,760)-(330,941) sem nada além do muro; `final_boss.jpg` (1400,500)-(1672,780) painel
violeta de borda reta (pendência do ciclo 6). Ciclo 6: 7 janelas chapadas na vitrine e 9 na luta.

Pedido:
- profundidade em três planos de valor: perto escuro (muro e pilares), meio com névoa (silhuetas 15 a 25 de L acima
  do perto), fundo claro e sem detalhe; a névoa sobe do fundo (mais densa embaixo);
- silhuetas de ruína distantes: pelo menos três formas diferentes (torre quebrada, arco, pilar tombado) visíveis no
  canto de baixo à direita e atrás das colunas da esquerda, pelos cartões que já existem (`abyss_ruins.gdshader`);
- nenhuma superfície grande chapada: os painéis violeta ganham gradiente vertical, borda rasgada e pelo menos um
  fuste escuro na frente; o plano do canto direito ganha bruma em faixas;
- custo: sem malha nova pesada; no máximo 4 cartões e 2 chamadas de desenho a mais.

Aceite: L1 janelas chapadas (96 x 96 px com desvio de L < 4, script `flat6.py` do ciclo 6) no máximo 5 na vitrine e
8 na luta; L2 nenhuma borda reta com mais de 150 px nos painéis violeta (vitrine e sala de Morvath); L3 pelo menos 3
silhuetas distintas na caixa (1500,700)-(1672,941) ou na (0,560)-(200,830); L4 `abyss_left_cols` detalhe de pelo
menos 5,0; L5 `--showcase` no máximo +0,1 ms.

### 5.3 Portal

Visto: `final_vitrine.jpg`, caixa `portal_open` (1270,110)-(1350,240): 75% dos pixels com um canal em 250 ou mais
(estourado), mediana de L 199, folha verde lisa sem estrutura; `sala_fonte.jpg` (1540,20)-(1672,180): a porta
amarela tem 54% de pixels estourados em R e G e mancha a fachada. Degraus (1060,240)-(1320,300): RGB médio
(20, 88, 55); o verde lava a pedra mas não mostra o relevo dos umbrais.

Este pedido troca a meta do ciclo 6 ("mais claro"): o Daniel quer menos área estourada.

Pedido (arquitetura intacta):
- a folha do portal com estrutura: miolo claro pequeno (até 25% da área), escurecendo para as bordas, com véus
  verticais lentos; cor do miolo perto de #33f953, bordas em verde profundo; vale para as três cores (verde,
  vermelho de Morvath, amarelo da recompensa);
- luz verde na pedra: luz mais baixa e rasante (`ArenaKit.PORTAL_LIGHT`, `PORTAL_LIGHT_AHEAD`, `PORTAL_SIDE`),
  para as faces de dentro dos umbrais e os espelhos dos degraus ficarem claros e os topos escuros; o derrame no chão
  em frente fica (é a assinatura da pintura).

Aceite: M1 `portal_open`: canal em 250 ou mais em no máximo 25% da caixa; mediana de L entre 150 e 190; desvio de L
de pelo menos 40; M2 a mesma medida na porta amarela (`sala_fonte`) e na vermelha (`13_morvath`); M3 `stairs` detalhe
de pelo menos 9 e `green_spill_floor` entre 12% e 20% (hoje 18,1%); M4 `facade` green até 0,20 e `statues_portal`
green até 0,25; M5 no recorte 4x contam-se as quatro ordens do arco e as juntas dos umbrais iluminadas de verde.

### 5.4 Medalhão

Visto: `final_vitrine.jpg`: aro (700,400)-(880,412) L médio 62,5, miolo (700,440)-(880,520) 77,2, chão de fora
(1000,560)-(1200,640) 56,6: o aro quase não separa do chão; as runas são riscos de 2 px; o relevo do centro
(760,470)-(830,510) é um rabisco quase invisível. `final_luta.jpg` (740,460)-(1020,545): o aviso vermelho por cima
do aro lê bem (as runas aparecem escuras através dele).

Pedido (posição e tamanho intactos; `ArenaKit.MEDALLION_GLOW` continua 0, sem emissão):
- relevo por valor: sulco escuro dos dois lados do aro (L até 35) e chanfro claro do lado da luz (L 85 a 100);
- runas mais grossas (o dobro do traço) e mais fundas, com a borda de cima clara; as mesmas formas de hoje (nenhum
  símbolo novo: se o Daniel quiser um selo, é pergunta para ele);
- centro: o desenho que já existe, com traço mais largo e sulco escuro;
- as quatro pontas da estrela com uma aresta central clara.

Aceite: N1 na câmera do jogo, diferença de L entre o sulco e o chanfro do aro de pelo menos 40, e do aro para o
chão de dentro de pelo menos 15; N2 pelo menos 12 runas contáveis no recorte 2x de `14_arena_geral` e todas no
`18_medalhao`; N3 nenhum pixel do medalhão com L acima de 110 (os avisos ficam sempre mais claros e mais saturados
que ele); N4 aviso vermelho sobre o medalhão contra aviso sobre chão liso no mesmo quadro (`07` ou `12`): diferença
de L média até 8 e de matiz até 5 graus; N5 `floor_center` desvio até 26.

## 6. P2: polimento do HUD (sem HUD novo)

Dono: UI/UX Designer. Medidas em `final_luta.jpg` (1672 x 941) e `10_combate_1920.jpg`.

| # | Onde | Problema | Pedido | Aceite |
|---|---|---|---|---|
| U1 | retrato (30,815)-(125,910) | desenho vetorial simples (rosto rosa, espada de palito) em outro estilo que o Explorador pintado | busto do próprio `HeroBody` renderizado uma vez num `SubViewport` (cabelo, cachecol, punho da Emeth) e guardado como textura; aro de ouro velho igual ao dos losangos | o retrato usa o modelo do jogo; custo zero por quadro depois de montado |
| U2 | vida (120,835)-(435,862) e Magia (120,866)-(370,888) | a parte vazia da Magia é preta com corte duro; número da Magia com 13 de fonte (cerca de 8 px de altura em 720 linhas) | fundo vazio em ardósia escura translúcida (não preto), brilho curto na ponta quando muda; rastro claro de 0,4 s mostrando o que perdeu; números com altura de maiúscula de pelo menos 9 px em 720 linhas | legível em `21_hud_1280`; a queda de vida deixa rastro visível numa rajada |
| U3 | ações (655,835)-(1010,920) | os quatro ícones são iguais em cor e peso; a recarga (parte escura) e as cargas do avanço (losango de 5 px) quase não se veem; sem estado "sem Magia" | ícone em marfim quando pronto, 45% quando em recarga, com a varredura clara na borda do losango; cargas do avanço com 8 px; ação com Ômega sem Magia suficiente ganha um traço azul apagado embaixo; brilho de 0,25 s ao ficar pronta (já existe: conferir) | em `21` e `22`, pronto e em recarga se distinguem em tons de cinza |
| U4 | ações, `final_luta.jpg` (880,790)-(940,920) | um Feiticeiro fica atrás da barra de ações (B2 do QA) | o grupo de ações fica 50% transparente enquanto o herói, um elite, um guardião ou o chefe estiver projetado atrás dele; decisão de câmera (`Game.CAM_SOUTH`) fica com o Game Director | captura com inimigo atrás da barra mostra o inimigo através dela |
| U5 | contador (1525,285)-(1655,445) | nome do golpe em verde claro sobre o chão iluminado de verde do portal (pouco contraste); ao sumir vira um fantasma ilegível (`8_horda90.jpg` (1480,420)-(1640,445)) | nome do golpe em marfim com sombra escura de 2 px; some em 0,25 s (corte mais curto, sem fantasma longo); número em ouro velho como hoje; o bloco inteiro some com contagem abaixo de 3 (já é assim) | contraste do texto contra o fundo de pelo menos 4,5 para 1 em `21` e `22` |
| U6 | topo: sala (28,20)-(158,45), relógio (805,18)-(865,45), ouro (1515,18)-(1645,45) | o relógio some sobre a corrente clara (`8_horda90.jpg` (808,18)-(865,45)) | a mesma sombra escura de 2 px a 60% em todos os textos do HUD | relógio legível em `20` |
| U7 | barra do chefe, `final_boss.jpg` (520,58)-(1150,110) | nome em roxo com contorno sobre fundo movimentado | nome em marfim com a mesma sombra; preenchimento roxo e armadura amarela como hoje | contraste de pelo menos 4,5 para 1 em `13` |
| U8 | avisos de inimigos especiais | só existe a etiqueta de texto da fonte fora da tela | reaproveitar a lógica de `_update_arrow`: uma divisa pequena de ouro velho na borda da tela apontando para elite, guardião ou chefe fora da vista (no máximo 3); a etiqueta da fonte ganha a mesma divisa | visível em captura com guardião fora da tela; nada aparece com todos na tela |
| U9 | molduras e cores | aro do retrato, losangos, teclas e barras com ouros diferentes | um só ouro velho (`UiKit.GOLD`) e uma só espessura de moldura (2 px em 720 linhas) | conferido no recorte 4x |
| U10 | resoluções | | sem corte nem sobreposição em 1280 x 720, 1672 x 941, 1920 x 1080 e 2560 x 1080 (ultralargo: o HUD prende nas bordas, não estica) | `21`, `22` e uma captura auxiliar `RES=2560x1080` |
| U11 | área ocupada | | o HUD parado ocupa no máximo o que ocupa hoje; nada novo no terço central da tela | comparar máscaras de `21` com `10_combate_1920.jpg` reduzida |

Os números de dano e as barras sobre as cabeças não são do HUD: são das frentes A e C (seções 2.4 e 4.2).

## 7. Donos e arquivos (ninguém divide arquivo)

| Dono | Área | Arquivos que pode editar | Não toca |
|---|---|---|---|
| Game Director (antes de todos) | opções de desenvolvimento da seção 8, integração | `scripts/game/game.gd`, `scripts/app.gd`, `scripts/boot.gd` (depois que a tela de título fechar), sinal em `scripts/game/combat.gd` antes de entregar o arquivo à frente A, `tools/gpu.sh`, `CLAUDE.md`, `docs/gallery/` | |
| Gameplay Engineer, frente A | efeitos da Emeth (seção 2) | `scripts/game/fx.gd`, `scripts/game/combat.gd` (só chamadas de efeito e constantes visuais), `scripts/game/projectiles.gd` (aparência dos tiros do herói), `scripts/game/ground.gd` e `assets/shaders/ground.gdshader` (aparência das zonas do herói; `WARNING_STRENGTH` e avisos intactos), `scripts/render/emeth_sword.gd`, `assets/shaders/slash.gdshader`, `slash_ink.gdshader`, `crescent.gdshader`, `impact.gdshader`, `glint.gdshader`, `ring.gdshader`, `beam.gdshader`, `emeth.gdshader`, `screen.gdshader` (só aberração e quadro de impacto; vinheta intacta), shaders novos `assets/shaders/emeth_*.gdshader`, teste novo `tests/test_fx_on_hit.gd` | `player.gd`, `horde.gd`, `make_data.gd`, `game.gd` |
| Gameplay Engineer, frente B | herói (seção 3) | `scripts/game/player.gd` (só apresentação: `XRAY_*`, `RING_*`, `EDGE`, pisca, luz), `scripts/render/hero_body.gd`, `assets/shaders/flash.gdshader`, `xray.gdshader`, `xray_depth.gdshader`, `xray_edge.gdshader`, `hero_ring.gdshader`, `tools/pose_lab.gd` | `fx.gd`, `emeth_sword.gd` (pedir à frente A o que precisar da lâmina no raio-x), `crowd*` |
| Gameplay Engineer, frente C | inimigos (seção 4, 2.7) | `scripts/game/horde.gd`, `scripts/game/enemy.gd`, `scripts/game/boss.gd` (só apresentação), `scripts/render/crowd_renderer.gd`, `scripts/render/baked_model.gd`, `scripts/core/enemy_def.gd` (só campos novos do grupo Look), `tools/make_data.gd` (só campos de aparência em `_enemies`; regenerar `data/enemies/*.tres`), `tools/bake.gd` e `assets/baked/*.res`, `tools/enemy_lab.gd`, `assets/shaders/crowd.gdshader`, `crowd_outline.gdshader`, `life_bar.gdshader`, arquivo novo `scripts/game/enemy_fx.gd` e shader novo `assets/shaders/enemy_tell.gdshader` para os preparos | `fx.gd` (usa a API que existe: `ring`, `burst`, `glint`), `combat.gd`, `ground.gd` |
| Environment Artist | arena (seção 5) | `scripts/game/catacomb_hall.gd`, `scripts/game/masonry.gd`, `scripts/game/arena_kit.gd`, `scripts/game/arena.gd` (só aparência), `assets/shaders/masonry.gdshader`, `catacomb_floor.gdshader`, `floor_detail.gdshader`, `portal.gdshader`, `abyss_fog.gdshader`, `abyss_glow.gdshader`, `abyss_mist.gdshader`, `abyss_ruins.gdshader`, `depth_stone.gdshader` | `game.gd` (se precisar do ambiente, pedir ao Game Director), `ground.gdshader`, `screen.gdshader` |
| UI/UX Designer | HUD (seção 6) | `scripts/ui/hud.gd`, `hud_bar.gd`, `hero_crest.gd`, `action_slot.gd`, `hud_mark.gd`, `elo_banner.gd` | `ui_kit.gd` e `data/text_pt.tres` enquanto a tela de título estiver aberta (pedir ao Game Director); `fx.gd`; `game.gd` (só lê `game.boss_enemy()`, `game.horde.list`, `game.camera`) |
| Agentes da tela de título (P0, em andamento) | título | `scripts/ui/title_*.gd`, `scripts/boot.gd`, `assets/ui/title/`, `assets/shaders/title_*.gdshader`, `tools/title_*.gd`, `tools/make_title_bg.*` | tudo acima |
| QA / Performance | linha de base, medidas, capturas finais | `docs/qa/latest_report.md`, `docs/gallery/cycle7/` (junto com o Game Director) | código |
| Art Director | especificação e revisão | `docs/art/cycle7_spec.md`, `docs/art/visual_review.md`, `docs/art/shots/` | código |

Valores de `Feel` (`_feel` em `tools/make_data.gd`, por exemplo `slash_intensity`, `ink_life`): a frente A não edita o
`make_data.gd`; lista os números no relatório e o Game Director aplica depois que a frente C terminar.
As três frentes do Gameplay Engineer podem rodar em paralelo (worktree) porque os arquivos não se cruzam.

## 8. Opções de desenvolvimento que faltam (mínimas; dono: Game Director, antes das frentes)

| Opção | Para quê | Onde | Tamanho |
|---|---|---|---|
| `--shot-on=swing\|hit\|special\|omega` com `--shot-after=<s>` (padrão 0,066) | congelar no quadro do golpe: depois de `--shot-at`, esperar o primeiro evento e capturar `--shot-after` segundos depois | `Game._shot` espera um sinal novo `Combat.swung(node: ComboNode, struck: int)` emitido no fim de `strike` (`swing`: qualquer; `hit`: `struck > 0`; `special`: nó com a marca do especial; `omega`: nó com custo de Magia) | cerca de 15 linhas em `game.gd`, 2 em `combat.gd` |
| `--frames` respeitar `--resolution` | as rajadas saem em 1280 x 720 | `scripts/app.gd:21`: tratar `frames` como `shot` | 1 linha |
| `--cam-at=x,z` | aproximar a vitrine de um ponto (portal, estátuas, abismo) | `Game._place_camera`, ramo `showcase`: trocar `arena.showcase` pelo ponto dado | 3 linhas |
| `--stress-ids=a,b,c` | escolher os inimigos do `--stress` (elite, sacerdote) | `game.gd:143`, lista `kinds` | 3 linhas |
| `--hover=N` (0 a 3) na tela de título real | captura do botão sob o mouse | `scripts/boot.gd` repassa ao `TitleMenu` (hoje só existe em `tools/title_menu_lab.gd`, sobre a pintura de referência) | dono: quem fecha a tela de título |

Enquanto não existirem: os golpes saem de rajada (`tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941
--fixed-fps 30 -- --nosave ... --frames=C:/.../prefixo --shot-at=5 --count=24 --every=0.03`, escolher o quadro à
mão e anotar qual); portal, estátuas e abismo saem de recorte da `14_arena_geral`; o elite sai do laboratório do QA.

## 9. Contrato de capturas: `docs/gallery/cycle7/`

Todas na placa (`tools/gpu.sh`), `--seed=5`, 1672 x 941 salvo indicação, JPG com qualidade alta (`ffmpeg -q:v 3`),
abertas e olhadas uma a uma antes de entrar. `shot` = `tools/gpu.sh shot <saída.png>` seguido das opções da coluna.
Comandos marcados com (v) existem hoje e já foram rodados (nesta revisão ou no QA do ciclo 6); os marcados com (8) dependem da seção 8.

| Arquivo | Comando | Momento | Comparar com (antes) |
|---|---|---|---|
| `01_titulo_1280` | `RES=1280x720` shot `--title --shot-at=3` | tela assentada, foco em Iniciar | `docs/gallery/jogo/11_titulo.jpg` |
| `02_titulo_1920` | `RES=1920x1080` shot `--title --shot-at=3` | idem | `jogo/11_titulo.jpg` |
| `03_titulo_hover` | `RES=1280x720` shot `--title --hover=1 --shot-at=3` (8) | mouse sobre Como Jogar, brilho do botão no máximo | `01_titulo_1280` (repouso) |
| `04_explorador_idle` | shot `--start=fountain --seed=5 --cam-dist=26 --shot-at=3` (v) | parado no patamar de entrada, sem inimigos | `docs/art/shots/cycle7_before/explorador_idle.jpg` |
| `05_explorador_corrida` | shot `--start=fountain --bot --seed=5 --cam-dist=26 --shot-at=1.5` (v) | correndo, passando atrás do obelisco (raio-x parcial) | `cycle7_before/explorador_corrida.jpg` |
| `06_emeth_ataque` | shot `--bot --autopick --seed=5 --shot-at=5 --shot-on=swing --shot-after=0.066` (8); hoje: rajada (v), quadro 1 | 2 quadros depois de soltar o golpe leve: fita no auge, antes da tinta | `cycle7_before/emeth_ataque.jpg` |
| `07_emeth_impacto` | shot `--bot --autopick --seed=5 --shot-at=5 --shot-on=hit --shot-after=0.066` (8); hoje: rajada (v), quadro 9 | 2 quadros depois do acerto: talho, lascas, inimigo em reação, número | `cycle7_before/emeth_impacto.jpg` |
| `08_emeth_especial` | shot `--bot --autopick --seed=5 --shot-at=2 --shot-on=special --shot-after=0.1` (8); hoje: rajada `--shot-at=2 --count=40 --every=0.1` (v), quadro 19 | dardo em voo, a meio caminho do alvo | `cycle7_before/emeth_especial.jpg` |
| `09_inimigos_comparativo` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- C:/Users/danie/tools/labout/c7/todos idle 0`; empilhar `todos_game.png` sobre `todos_front.png` (`ffmpeg ... vstack`) | parados; fila da frente os nove, atrás as elites, herói à esquerda | `docs/gallery/enemies/_todos_game.jpg` e `_todos_front.jpg` |
| `10_inimigos_em_combate` | shot `--bot --autopick --stress=18 --stress-ids=skeleton,runner,mage,archer,guard,priest --seed=5 --shot-at=5` (8); hoje sem `--stress-ids` (sem Sacerdote) | pelo menos um preparo de ataque visível (se não houver, rajada e escolher) | o mesmo comando no `c561101` (o QA gera pelo espelho `MIRROR=C:/Users/danie/tools/eterra-gpu-head`) |
| `11_inimigo_elite` | shot `--bot --autopick --stress=6 --stress-ids=guard_elite,guard,skeleton_elite,skeleton,mage_elite,mage --seed=5 --shot-at=4` (8) | elite e comum do mesmo tipo lado a lado, armadura de pé | `jogo/4_elite.jpg` |
| `12_guardiao` | shot `--start=miniboss --bot --autopick --seed=5 --shot-at=9` (v) | Cavaleiro com aviso no chão; auxiliar `12b` com `--seed=2` (Ancião) | `cycle7_before/guardiao_cavaleiro.jpg`; `jogo/3_sacerdote.jpg` |
| `13_morvath` | shot `--start=boss --bot --autopick --seed=5 --shot-at=12` (v) | Morvath com arco de aviso, portal vermelho, barra do topo | `jogo/final_boss.jpg` |
| `14_arena_geral` | shot `--showcase --seed=5 --shot-at=4` (v) | enquadramento da pintura | `jogo/final_vitrine.jpg` e `jogo/referencia_arena.jpg` |
| `15_portal` | shot `--showcase --cam-at=2.8,-17 --cam-dist=24 --seed=5 --shot-at=4` (8); hoje: recorte (1040,20)-(1600,350) da `14`, ampliado 2x | portal, umbrais, degraus e as duas estátuas | o mesmo recorte de `jogo/final_vitrine.jpg` |
| `16_estatuas` | shot `--showcase --cam-at=-21,2 --cam-dist=34 --seed=5 --shot-at=4` (8); hoje: recorte (200,0)-(1000,330) da `14`, 2x | gigante, estátua noroeste e nordeste | o mesmo recorte de `jogo/final_vitrine.jpg` |
| `17_abismo` | shot `--showcase --cam-at=-16,6 --cam-dist=72 --seed=5 --shot-at=4` (8); hoje: recortes (0,0)-(560,520) e (1300,560)-(1672,941) da `14` lado a lado | lado oeste com as colunas violeta e as ruínas distantes | os mesmos recortes de `jogo/final_vitrine.jpg` |
| `18_medalhao` | shot `--showcase --cam-dist=32 --seed=5 --shot-at=2` (v; aos 4 s um golpe cobre a tela) | medalhão de perto, sem aviso por cima | `jogo/5_medalhao.jpg` |
| `19_combate_40_inimigos` | shot `--bot --autopick --stress=40 --seed=5 --shot-at=7` (v) | herói cercado no patamar oeste | `jogo/9_cercado40.jpg` |
| `20_combate_90_inimigos` | shot `--bot --autopick --stress=90 --seed=5 --shot-at=6` (v) | herói dentro do bolo | `jogo/8_horda90.jpg` |
| `21_hud_1280` | `RES=1280x720` shot `--bot --autopick --seed=5 --shot-at=9` (v) | contador de golpes e nome do golpe na tela, Magia gasta | `jogo/final_luta.jpg` reduzida para 1280 |
| `22_hud_1920` | `RES=1920x1080` shot `--bot --autopick --seed=5 --shot-at=9` (v) | idem | `jogo/10_combate_1920.jpg` |
| `before_after_titulo` | `ffmpeg -i docs/gallery/jogo/11_titulo.jpg -i 01_titulo_1280.jpg -filter_complex "[0]scale=1280:720[a];[a][1]hstack"` | | |
| `before_after_arena` | `ffmpeg -i docs/gallery/jogo/final_vitrine.jpg -i 14_arena_geral.jpg -filter_complex hstack` | | |
| `before_after_combate` | grade 2 x 2: em cima `jogo/final_luta.jpg` e uma captura nova de shot `--bot --autopick --seed=5 --shot-at=9`; embaixo `jogo/8_horda90.jpg` e `20_combate_90_inimigos` (`hstack` de cada linha, depois `vstack`) | | |

Auxiliares (mesma pasta, para os critérios): `06b_emeth_omega` (`--shot-on=omega`; hoje rajada `--shot-at=2
--count=40 --every=0.1`, quadro 38; antes: `cycle7_before/emeth_omega.jpg`), `08b_emeth_circulo` (rajada, quadro 14;
antes: `cycle7_before/emeth_circulo.jpg`), `12b_guardiao_anciao`, `15b_porta_amarela` (shot `--start=fountain
--seed=5 --shot-at=3`; antes: `cycle7_before/sala_fonte.jpg`), `22b_hud_2560` (`RES=2560x1080`).

As posições de `--cam-at` são pontos de partida tirados das constantes do salão (portal em x 2,8 e z -20, gigante em
x -26 e z 8,3, medalhão em x -2,5 e z 1): ajustar uma vez, congelar o comando neste documento e usar o mesmo no antes
(pelo espelho do `c561101` com a opção aplicada) e no depois.

Como a mecânica não muda e o robô é determinístico por semente, o herói e os inimigos ficam no mesmo lugar no antes e
no depois: se a posição mudar numa captura de mesmo comando, alguma regra mudou (ver regra 1).

## 10. Ordem, riscos e perguntas

Ordem: (1) Game Director aplica a seção 8 e o QA tira a linha de base (smoke, desempenho, capturas de antes que
faltam: `10`); (2) frentes A, B, C, Environment Artist e UI/UX em paralelo; (3) QA mede e captura a seção 9; (4) Art
Director revisa contra os critérios e registra em `visual_review.md`.

Riscos:
- o raio-x nas cores do herói pode ler menos que o ciano no bolo de 90: se G1 a G4 passarem e ele ainda não for
  achável em 1 s, subir primeiro a luz de recorte e a cunha do anel, nunca voltar ao ciano chapado nem engrossar a borda;
- posturas novas (escudo à frente, besta na horizontal, mãos do Sacerdote) dependem de clipes que existam nas
  bibliotecas já usadas (Quaternius, KayKit); se não houver, travar o braço por pose no assado (como o braço da
  espada do herói em `bake_hero.gd`); nenhum clipe comprado ou gerado;
- o orbe e a gema acima do limiar do glow somam brilho em hordas de feiticeiros: limite de 1,8 e conferir em `20`;
- a meta nova do portal contradiz a do ciclo 6 (mais claro); vale a do Daniel (menos estouro).

Perguntas para o Daniel (pelo Game Director):
1. Medalhão: fica o desenho geométrico de hoje ou ele quer um selo específico no centro?
2. Estandartes e acessório do Sacerdote: algum símbolo de Morvath ou da igreja que possamos usar? Sem resposta,
   nada de símbolo novo.
3. Números de dano em branco pálido (esmeralda só nos golpes grandes): confirma?

Steam: nada novo a declarar por este ciclo de jogo (sem IA, sem recurso externo novo); a arte da tela de título (P0)
é declarada por quem a fechou.
