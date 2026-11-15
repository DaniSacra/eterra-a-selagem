# Ciclo 5: polimento visual e identidade artística (especificação, 2026-11-15)

Pedido do Daniel: "reconhecer o mesmo jogo, com os mesmos personagens e a mesma arena, mas com acabamento artístico
claramente superior". Metas: `docs/art/ref/arena_catacumbas_1672.png` (arena) e `docs/art/ref/inimigos_fase1.png`
(prancha; decisões em `docs/art/enemies_phase1.md`). As duas ficam fora do git.

Autor: Art Director. Nada aqui foi implementado. Donos: Gameplay Engineer (seção A), Environment Artist (B),
UI/UX Designer (C). Ordem de prioridade do Daniel: A1, A2, B1, B2, B3, C.

**Fora do escopo (decisão do Daniel):** inimigos novos, mecânica, balanceamento, regras de combate, reconstruir a
arena, Meshy ou serviço pago, trocar modelos por assets genéricos, qualquer coisa que piore a leitura do combate,
aumentar o brilho geral.

## 0. Evidência

Capturas reais, Vulkan, 1672 x 941, `--seed=5` (script do Game Director
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/c5/shots.sh`),
pasta `.../scratchpad/c5/antes/`:

| Arquivo | O que mostra |
|---|---|
| `0_daniel.png` (1393 x 746, do Daniel) | sala 3, guardião Ancião (Sacerdote dos Mortos) com dois soldados |
| `1_arena.png` | vitrine (`--showcase`), 4 s |
| `2_combate.png` | luta de 9 s (`--bot --autopick`), aviso vermelho cruzando o medalhão |
| `4_elite.png` | Cavaleiro guardião, **no modo horda antigo** (`--horde --start=elite1`): trocar, ver seção E |
| `5_medalhao.png` | vitrine com `--cam-dist=32` (medalhão de perto) |

| `6_horda.png` | `--stress=90`, 6 s: o herói some dentro do bolo em (330,340)-(780,640) (só uma mancha clara do raio-x); cartão lilás chapado no abismo em (60,250)-(440,370) |

`3_lab_*` e `7_morvath` ainda não existiam quando esta especificação foi escrita; entram na revisão.
Recortes ampliados desta análise: `.../scratchpad/c5/ad/` (`elder4x.png`, `hero4x.png`, `hero_c4x.png`,
`medal_cmp.png`, `abyss_cmp.png`, `hud_cmp.png`).

Medidas: `python3 -I tools/art_metrics.py` e três scripts de estudo em `.../scratchpad/tools/`:
- `c5m.py img x0 y0 x1 y1`: **amarelo saturado** (matiz 36 a 65 graus, saturação > 0,55, valor > 0,6), **roxo
  saturado** (matiz 259 a 310, s > 0,45, v > 0,45) e fração com L > 200 numa caixa.
- `c5d.py img x0 y0 x1 y1`: média e desvio de L, **detalhe** (média do módulo do laplaciano de L), saturação
  mediana, fração com L < 25.
- `c5flat.py img x0 y0 x1 y1`: janelas de 48 x 48 (passo 24) **chapadas** (sd de L < 4 e média > 35).

Se o QA quiser fixar estes testes, as definições acima bastam para pô-los no `tools/art_metrics.py`.

Medidas de partida (pintura entre parênteses):

| Medida | Antes |
|---|---|
| Ancião em `0_daniel` (1010,205)-(1170,340): amarelo saturado | 10,7% (o manto da pintura: 0) |
| Cavaleiro em `4_elite` (405,325)-(530,535): amarelo saturado / L > 200 | 14,4% / 14,2% |
| Herói em `2_combate`: altura na tela | cerca de 70 px (pintura cerca de 100); esqueleto comum cerca de 60 a 66 px (`0_daniel` escalado; pintura 75) |
| Cabelo / manto / lâmina do herói (`2_combate`) | #ff6008 (laranja estourado) / #4ab29f / #20ffc5 (ciano, não esmeralda) |
| Couro: colete e calça (`2_combate` (845,432) e (840,445)) | #4a261e e #45261a (mesmo valor) |
| Medalhão em `5_medalhao`: traço dourado | 1 a 2 px, contínuo; juntas das lajes atravessam a faixa |
| Faixa alta do abismo (0,0)-(1672,300) em `2_combate`: detalhe / saturação mediana / janelas chapadas | 7,6 / 0,98 / 26 de 748 (10,5 / 0,84 / 3) |
| Esquerda (0,120)-(250,600) em `2_combate`: detalhe / L < 25 | 4,2 / 42% (6,3 / 23%) |
| Vitrine global: p1 / p50 / p99 / < 20 / quentes / violeta à direita | 1,6 / 44,8 / 167 / 19% / 0,5% / 0,0% (6,8 / 45,5 / 201 / 13% / 0,9% / 4,9%) |

## 1. Princípio: visual permanente contra indicador funcional

O que é **sinal de jogo** fica saturado e claro; o que é **figurino e cenário** desce para ouro velho, roxo
dessaturado e pedra. Assim o amarelo e o vermelho que sobram na tela significam alguma coisa.

| Elemento | Tipo | Regra neste ciclo |
|---|---|---|
| Barra amarela de armadura (`life_bar.gdshader` `armor_color` (1,0.82,0.25)) | funcional | **não muda** |
| Barra de vida sobre a cabeça, barra do chefe no topo | funcional | não muda de cor (UI/UX só refina moldura, seção C) |
| Clarão branco do golpe (`state.r`, `white_from`), gelo, queimadura, dissolver | funcional | **não muda** |
| Avisos vermelhos no chão (`Ground.add_*warning`) | funcional | **não muda**; nada novo pode ser vermelho saturado no chão |
| Cor da magia (`EnemyDef.magic_color`, quadrados 28 a 31 que brilham) | funcional (de onde vem o golpe) | fica luminosa: olhos, orbe, gema e projéteis seguem acima do limiar do glow |
| Elite e guardião se distinguem do comum | funcional | o sinal passa a ser: barra de armadura (já existe) + frisos de ouro velho na paleta + friso fino de borda; **o contorno grosso brilhante sai** |
| Dourado da paleta (`FACTION[GOLD]`), `ELITE_RIM`, `ELITE_SHADE`, contorno (`OUTLINE_*`) | permanente | pode e deve mudar (seção A1) |
| Roxo das vestes (`ROYAL_PURPLE`, `PURPLE`) | permanente | dessaturar (A1) |

Paleta-alvo do ciclo (valores de albedo, sRGB):

| Papel | Claro | Sombra |
|---|---|---|
| Ouro velho (frisos, coroas, guarda da espada) | `8e7444` | `34281a` |
| Bronze escuro (medalhão) | `7a6238` | `4e3f26` |
| Roxo das vestes (dessaturado) | `54386a` | `1a1022` |
| Metal escuro dos sacerdotes | `4e4a52` | `18161c` |
| Osso envelhecido (sacerdotes, Ancião) | `d8cbb0` | `4e3e30` |
| Azul-petróleo do cachecol | `2c7478` (barra `3e9094`) | `0f3036` |
| Esmeralda da Emeth (lâmina) | `18d961` (fio central `9dffc0`) | |

## A. Gameplay Engineer

Arquivos: `tools/make_palettes.gd`, `tools/make_data.gd` (`ELITE_RIM`, `_feel`), `tools/bake.gd` (`MODELS`),
`scripts/render/crowd_renderer.gd`, `assets/shaders/crowd.gdshader`, `crowd_outline.gdshader`,
`tools/recolor_hero.gd`, `scripts/render/hero_gear.gd`, `hero_body.gd`, `emeth_sword.gd`. Depois: regerar paletas,
`make_data.gd -- enemies feel`, reassar (`bake.gd`), `--import`, `tools/recolor_hero.gd`.

### A1. Sacerdote dos Mortos, Ancião e demais inimigos (prioridade 1)

**Diferença** (`0_daniel.png`, Ancião em (1010,205)-(1170,340), ampliado em `ad/elder4x.png`): manto roxo-magenta
saturado (#5f1977, #531568), capa e frisos amarelo-limão (#decb38, #e0d15d), contorno amarelo de 2 px em volta de
tudo, inclusive do cajado; o crânio é uma massa creme sem órbitas legíveis; sem capuz (a prancha, bloco 8, tem capuz
sob a coroa). Em `4_elite.png` o Cavaleiro (405,325)-(530,535) é um vulto amarelo: 14% de amarelo saturado e 14% de
pixels acima de L 200. Três fontes somam: quadrado `GOLD` da paleta (`e0b45a`), o termo `edge` do `crowd.gdshader`
com `ELITE_RIM` (1.0, 0.68, 0.28) x 0,7, e o contorno (`crowd_outline.gdshader`, cor = `rim_color`); `ELITE_SHADE`
(1.15, 1.1, 1.1) ainda clareia elites e guardiões.

**Alvo:**
1. `make_palettes.gd`: `FACTION[GOLD]` `["e0b45a","6a4618"]` para `["8e7444","34281a"]` (vale para todo friso de
   elite, Cavaleiro, Ancião e Morvath). `ROYAL_PURPLE` `["6c3a96","22102e"]` para `["54386a","1a1022"]`;
   `FACTION[PURPLE]` `["7a46a8","26123c"]` para `["5e4474","1e1428"]`.
2. Sacerdote e Ancião em `PALETTES`: metal `3: ["4e4a52","18161c"]`, `4: ["3a3436","121012"]`; osso
   `9: ["d8cbb0","4e3e30"]` (menos branco: o rosto deixa de estourar sob a luz-chave e os olhos roxos se destacam).
   Quadrados que brilham (28 a 31) **iguais**.
3. `bake.gd`, `priest_elder`: acrescentar o capuz do Sacerdote (`Skeleton_Rogue.glb:Skeleton_Rogue_Hood` no osso
   `head`) num quadrado **escuro** (o 2, preto, ou um livre pintado `2e2236` / `0e0a12`), com a `CROWN` erguida para
   assentar sobre o capuz. No `priest`, o capuz passa para o mesmo quadrado escuro (hoje roxo): moldura escura em
   volta do crânio claro é o que faz o rosto ler na prancha.
4. `make_data.gd`: `ELITE_RIM` Color(1.0, 0.68, 0.28) para Color(0.62, 0.46, 0.22); `ELITE_RIM_POWER` 0.7 para 0.3.
   Morvath: `rim_color` (0.7, 0.3, 1.0) para (0.45, 0.3, 0.6), `rim` 0.45 para 0.3.
5. `crowd_renderer.gd`: o contorno ganha cor própria, separada do rim: `OUTLINE_COLOR := Color(0.1, 0.08, 0.06)`
   (tinta escura, como o traço da pintura), `OUTLINE_WIDTH` 0.03 para 0.022, `OUTLINE_INTENSITY` 0.9 para 1.0.
   `ELITE_SHADE` para Color(1, 1, 1). Elites e guardiões com `desaturate` 0.12 (hoje 0).
6. Os demais inimigos herdam 1, 4 e 5 sem trabalho extra; conferir o Escudo (`guard`, `DARK_BRONZE`) e o Besteiro
   (capuz roxo `4c2c5e` fica).

**Aceite:**
- Ancião (captura da seção E, item 3, e `3_lab_game.png`): amarelo saturado <= 2% da caixa do corpo (hoje 10,7%);
  roxo saturado <= 4%; ao menos 0,3% da caixa em roxo luminoso (matiz 259 a 310, L > 150: orbe e olhos).
- Cavaleiro: amarelo saturado <= 2% (hoje 14,4%), L > 200 <= 3% (hoje 14,2%).
- Nenhum halo em volta de elite, guardião ou Morvath mais largo que 2 px a 1672 x 941; o contorno é escuro.
- Rosto do Ancião e do Sacerdote no recorte 4x: órbitas e olhos roxos visíveis dentro de uma moldura escura de capuz.
- Elite distinguível do comum no `6_horda.png`: barra amarela presente e frisos de ouro velho (pixels de matiz 30 a
  50 graus, s 0,3 a 0,55, na caixa do elite) >= 2%.

**Não pode piorar:** barra amarela de armadura, clarão branco, cor dos projéteis e anéis de magia, avisos vermelhos;
inimigo legível contra o chão (contraste de L entre a figura e o chão em volta igual ou maior que hoje no `6_horda`).

### A2. Explorador (prioridade 2)

**Diferença** (`2_combate.png`, herói em (790,395)-(880,475), ampliado em `ad/hero_c4x.png`; `0_daniel` em
(560,380)-(640,455)): cabelo é um disco laranja estourado (#ff6008, R 255); o manto petróleo é uma placa rígida nas
costas que quase não aparece de lado; colete, calça e botas com o mesmo valor (#4a261e, #45261a); a lâmina lê ciano
(#20ffc5, matiz 165) e floresce inteira; fivela e guarda em amarelo vivo.

**Alvo:**
1. `recolor_hero.gd`: `HAIR_SAT` 0.86 para 0.72, `HAIR_LIFT` 1.3 para 1.1, `HAIR_MAX` 0.92 para 0.78, mais mechas:
   escurecer em faixas ao longo do U do cabelo (3 a 4 faixas, valor +-18%). Alvo na tela: meio-tom `b8441c`,
   brilho até `e07a40`, sombra `5a1c0e` (o mesmo cabelo do `HeroCrest`, seção C).
2. Couro com contraste por peça: `TROUSERS` `3d2a26` para `2b211f`, `VEST` `4b2e29` para `5e3a28`, `BELT_LEATHER`
   `7a4a2c` para `3b2619`, `STRAP` `975b36` para `a86c3c`, `BOOTS` `6a3e27` para `74462a`, `BRACER` para `7e5232`,
   `GLOVE` `402621` para `2e1c18`. `TEAL` (pele pintada) para `2c7478`.
3. `hero_gear.gd`, cachecol: volta no pescoço (anel 0,11 m de raio, 0,08 de altura, no osso do pescoço ou `Spine2`) e
   duas pontas atrás (0,12 x 0,55 x 0,015 m cada, em dois segmentos articulados). Balanço: inclinação para trás
   proporcional à velocidade (0 parado, 35 graus a 6,75 m/s) mais um seno de 6 graus a 9 rad/s; na esquiva, 50
   graus. Cor `2c7478` com barra `3e9094`. O manto atual (`MANTLE`) escurece para `1a434a` e encurta para 0,6 m: o
   cachecol é a mancha de cor, o manto é fundo. Só visual (nó no osso, sem física, sem colisão).
4. `hero_gear.gd` `GOLD` (0.9, 0.62, 0.25) para (0.56, 0.45, 0.27); `emeth_sword.gd` `GOLD` (1.0, 0.74, 0.3) para
   (0.6, 0.47, 0.27) (ouro velho, a esmeralda da guarda continua acesa).
5. Emeth: `GREEN` (0.12, 1.0, 0.32) para (0.1, 0.85, 0.38); `BLADE_GLOW` 1.7 para 1.2 (o corpo da lâmina fica abaixo
   do limiar do glow 1,3); um fio central de 30% da largura em Color(0.6, 1.0, 0.75) x 1.6, o único trecho que
   floresce.

**Aceite** (`2_combate.png`, `6_horda.png`, recorte 4x do herói):
- Cabelo: nenhum pixel com R = 255; matiz 12 a 22 graus; ao menos duas faixas de valor distintas (diferença de L
  >= 20) dentro do cabelo.
- Cachecol: >= 40 px (a 1672 x 941) de matiz 178 a 192 graus, s > 0,4, L > 60, visíveis com o herói de costas e de
  lado; as pontas se afastam do corpo quando ele corre (quadros `--frames`).
- Couro: diferença de L >= 18 entre colete e calça e >= 15 entre cinto e colete, amostrados no recorte.
- Lâmina: matiz mediana 138 a 152 graus (hoje 165), B <= 0,6 G; halo que passa da lâmina <= 4 px; pixels da lâmina
  com L > 235 <= 20%.
- Dourado no herói continua <= 3% da caixa (medida do ciclo 4).
- Cercado (`6_horda.png`): hoje ele não é achado no bolo. Alvo: o raio-x mostra a silhueta inteira dele com o cabelo
  e o cachecol na cor (não uma mancha branca), e quem olha a captura acha o herói em menos de 2 s (o QA confirma com
  o recorte 2x do bolo). Se o raio-x precisar mudar, a cor dele vira o petróleo claro `3e9094` com o cabelo `e07a40`.

**Não pode piorar:** o herói segue sendo a figura mais legível do quadro (raio-x e brilho de carga do ciclo 4 ficam);
a cor dos cortes sem dom continua o verde da Emeth (`Combat.EMETH`).

### A3. Tamanho aparente e câmera (prioridade 2)

**Medida:** câmera de jogo distância 60, fov 24, inclinação 30: cerca de 37 px por metro no ponto de mira a 1672 x
941; o herói de 2,5 m dá cerca de 70 a 80 px de pé (pintura cerca de 100); razão herói/esqueleto comum cerca de 1,1
a 1,2 (pintura cerca de 1,33).

**Alvo, em dois passos:**
1. `HeroBody.HEIGHT` 2.5 para 2.75 (só o desenho, também na tela de título; raio, alcance, avanço e caixas de golpe do `Player` e do
   `ComboNode` não mudam; a espada cresce junto com o modelo, os cortes de efeito não). Sozinho: cerca de 80 a 85 px.
2. `Feel.cam_distance` 60 para 54 em `_feel` (`make_data.gd`). Tudo cresce 11% na tela; o herói chega a cerca de 90 a
   95 px. A vitrine usa `Game.SHOWCASE_DISTANCE` (60) e **não muda**, então as métricas da vitrine continuam
   comparáveis. O `CLAUDE.md` registra que mexer na distância é decisão do Daniel: o Game Director confirma com ele
   antes de entregar o passo 2 (o passo 1 vale sozinho).

**Aceite:** herói de pé com 85 a 100 px (passo 1 e 2) ou 80 a 88 px (só passo 1) a 1672 x 941; razão herói/esqueleto
comum de 1,25 a 1,4. Com a distância 54: a meia largura visível fica em cerca de 20 m; em 3 partidas `--bot` de 60 s,
todo aviso vermelho de um inimigo que ataca o herói aparece inteiro na tela antes de o golpe cair (Sacerdote: 16 m de
alcance), e a beira da sala e as portas seguem visíveis quando o herói está nelas.

**Não pode piorar:** colisão, alcance e ritmo (nenhum número de combate muda; `tools/test.sh` e `tools/smoke.sh 300`
iguais); a câmera não corta a barra de chefe nem o HUD.

## B. Environment Artist

Arquivos: `assets/shaders/catacomb_floor.gdshader` (`medallion`, `fragment`), `scripts/game/arena_kit.gd`
(`floor_plate`, `MEDALLION_GLOW`, `abyss_glow`), `scripts/game/catacomb_hall.gd` (`_depths`, `ROW_*`, `GLOW_*`,
`MIST_*`, `LANTERN_*`), `scripts/game/masonry.gd`, `assets/shaders/abyss_*.gdshader`, `depth_stone.gdshader`, e a
luz em `scripts/game/game.gd` `_build_world` (só constantes de ambiente; o resto do `game.gd` é do Gameplay
Engineer).

### B1. Medalhão central (prioridade 3)

**Diferença** (`5_medalhao.png`, centro em cerca de (765,500); pintura em `ad/medal_cmp.png`): é um traço dourado
de 1 a 2 px, contínuo e liso; a faixa entre os anéis é só 20 níveis mais clara que o chão (77 contra 57 em
(850,352)-(900,368) e (850,318)-(900,334)) e sem relevo; as juntas das lajes cortam a faixa como se ela fosse
desenhada por cima; as volutas parecem "S" de caneta e as folhas parecem zeros; as pontas têm o mesmo traço fino. Na
pintura é uma faixa larga de pedra esculpida, de bronze escuro gasto, com bordas grossas e sombra.

**Alvo** (`medallion` e o trecho dele no `fragment`; raio 7,5 e posição ficam):
1. A faixa vira um anel de **16 pedras curvas**: juntas radiais a cada 22,5 graus (0,04 m, `joint_color`); embaixo
   da faixa as juntas das lajes somem (`ring_joints` 0.4 para 0.05 só dentro da faixa).
2. Relevo pintado, além da normal: pedra da faixa `x 0.85`; chanfro de 0,1 m nas duas bordas, o lado voltado para a
   luz-chave (alto à esquerda da tela) `x 1.25`, o lado oposto `x 0.55`; sulco de 0,12 m fora do anel externo e dentro
   do interno (`joint_color x 0.5`).
3. Fio de metal: largura 0.035 para 0.05 m, `gold_dark` para `4e3f26`, `gold_light` para `7a6238` (bronze escuro), e
   **interrompido**: presente em cerca de 55% do comprimento (ruído ao longo do ângulo). `MEDALLION_GLOW` 0.1 para 0.
4. **Runas gastas** no lugar das volutas: 32 sinais na faixa (um por 11,25 graus), cada um um traço vertical mais um
   ou dois de {traço horizontal curto, diagonal, pequeno círculo} sorteados por célula; sulco de 0,035 m
   (`joint_color x 0.6`); 30% deles apagados pelo ruído. As folhas entre as pontas viram losangos rasos (sem o
   contorno oval).
5. **Rachaduras**: 4 rachaduras que cruzam a faixa no sentido do raio e seguem 0,6 a 1,2 m pelas lajes
   (`crack_color`), mais 2 lascas faltando na borda da faixa.
6. Pontas: metade clara `x 1.1`, escura `x 0.7` (hoje 1,15 e 0,94), sulco da borda 0.08 para 0.1 m, ponta com lasca.

**Aceite** (`5_medalhao.png`; caixas no meio da faixa, conferidas pelo QA):
- Bordas da faixa com espessura >= 4 px em `5_medalhao` e >= 3 px em `1_arena`; lado claro >= faixa + 20 de L e lado
  escuro <= faixa - 25, cada um com >= 3 px.
- Detalhe nas caixas da faixa >= 15 (hoje 9,9 a 14), sem juntas de laje atravessando a faixa (só as 16 radiais).
- Metal: no quadro (420,260)-(1300,840) de `5_medalhao`, pixels de matiz 30 a 60 graus com s > 0,45 e L > 100 <=
  0,3%; saturação mediana da faixa <= 0,35.
- Média de L dentro do medalhão entre a do chão em volta - 15 e + 10 (não vira mancha clara nem buraco).
- Aviso vermelho sobre o medalhão (`2_combate`, retângulo em (740,460)-(1000,535)): fração de pixels vermelhos
  (R >= G + 80) no retângulo igual à de antes +-10%, borda do aviso contínua; nenhum pixel do medalhão com matiz < 15
  ou > 345 graus e s > 0,5.

**Não pode piorar:** o centro calmo da luta (`calm_radius`), o chão limpo (`floor_clean_a`), o custo do shader (um
`medallion` por pixel só dentro do raio: manter o teste `under` antes do trabalho pesado).

### B2. Iluminação e materiais (prioridade 4)

**Diferença** (`1_arena`, `2_combate`): pretos esmagados (p1 1,6; 19% abaixo de 20), fachada e abismo
supersaturados de petróleo (saturação mediana 0,88 a 0,98 contra 0,77 a 0,84), fogo com pouco miolo quente (0,5%
contra 0,9%), velas com pavio esverdeado sob a luz fria, personagens com luz própria pintada que não conversa com a
sala (elites mais claros que tudo).

**Alvo:**
1. `game.gd`: `AMBIENT` (0.3, 0.45, 0.5) para (0.3, 0.4, 0.46); `SKY` e `FOG` (0.07, 0.28, 0.31) para (0.06, 0.22,
   0.27); `EXPOSURE` e `GLOW_*` iguais.
2. Pretos: a névoa baixa do abismo (`abyss_mist`, `FOG_HEIGHT_DENSITY`) levanta o fundo mais escuro para perto de
   `0a0f18`, sem mexer na exposição.
3. Fogo: o miolo (`FLAME_HEART`) um pouco maior nos braseiros, sem aumentar halo nem a energia das luzes; `WAX`
   conferido sob a luz fria (vela creme, não verde).
4. Verde só no portal, na escada e no chão diante dele; em nenhuma outra peça (a Emeth é do herói, conta à parte).
5. Personagens na mesma luz: com A1 (`ELITE_SHADE` 1, contorno escuro) e A2, nenhum personagem é mais claro que o
   braseiro mais próximo; o Environment Artist confere a luz-chave da sala (`KEY_*`) junto com o Gameplay Engineer
   na mesma captura.

**Aceite** (`1_arena`): p1 >= 4; L < 20 de 9% a 17%; p50 de 42 a 50 (**não sobe**); p99 >= 170; quentes
estourados >= 0,7%; `facade` saturação mediana <= 0,82; verde fora da caixa (1050,0)-(1672,470) <= 0,3% dos pixels
(sem contar a lâmina); as 8 regiões do ciclo 4 que passam continuam passando.

### B3. Abismo e arquitetura distante (prioridade 5)

**Diferença** (`2_combate`, faixa alta e esquerda; `ad/abyss_cmp.png`): painéis chapados de petróleo e de lilás entre
pilares retos (26 janelas chapadas na faixa alta, a pintura tem 3), arcadas em zigue-zague sem arco nem ruína, a
lanterna é um pentágono amarelo chapado, o violeta da esquerda é um retângulo liso; sem bruma em camadas.

**Alvo** (leve: nada de luz nova, nada de sombra, cartões sem luz e `MultiMesh` onde houver repetição):
1. `abyss_glow`: quebrar o cartão com ruído (`ragged` 0.3 para 0.6) e gradiente vertical (claro só no pé); violeta
   `color` (0.45, 0.3, 0.95) para (0.4, 0.3, 0.75).
2. Arcadas (`ROW_*`): arco de volta perfeita ou ogival entre pilares, topos quebrados (`BROKEN` 0.6 fica), uma
   ponte ou aqueduto partido por fileira; as silhuetas mais próximas mais escuras que a névoa atrás delas (L >= 12 de
   diferença).
3. Bruma: 3 bancos (`MIST_BANKS`) com alfa 0.18 / 0.28 / 0.35 do mais perto ao mais longe, com o ruído deslizando
   (`drift`), cobrindo o pé das ruínas.
4. Lanterna: `LANTERN_GLASS` (1.5, 0.8, 0.28) para (1.1, 0.6, 0.22), com a grade do caixilho visível.
5. Violeta à direita discreto (pedido do ciclo 4 continua): só no pé do penhasco, quebrado.

**Aceite:** em `2_combate`, faixa (0,0)-(1672,300): detalhe >= 9,5, saturação mediana <= 0,88, janelas chapadas
<= 8 de 748; esquerda (0,120)-(250,600): detalhe >= 5,5, L < 25 <= 32%; vitrine: `abyss_left_cols` detalhe >= 4,5,
`violet_right` >= 0,02; luta de 14 s indo para o leste: luminância em (1600,600) <= 100. Custo: tempo de quadro no
desktop sobe no máximo 0,5 ms (QA mede); `DRIVER=opengl3` sem peça faltando.

**Não pode piorar:** o abismo continua mais escuro que o chão da sala (a luta é lida no chão); nada no abismo com L >
150 fora das chamas e da lanterna.

## C. UI/UX Designer: HUD (prioridade 6, só refinamento)

Arquivos: `scripts/ui/hud.gd`, `hud_bar.gd`, `hero_crest.gd`, `action_slot.gd`, `ui_kit.gd`. A organização fica
(retrato e barras embaixo à esquerda, quatro losangos no centro, sala, relógio e ouro no topo, contador de golpes à
direita). Comparação em `ad/hud_cmp.png`.

**Diferença:** barras em vermelho e azul puros sem moldura (a pintura tem moldura escura com friso de ouro velho e
um brilho no topo da barra); Magia em azul royal (0.3, 0.52, 1.0) que não conversa com mais nada; retrato chapado
(cabelo `a9340d`/`e15e26`, cachecol `395c4a` que não é o do herói); losangos vazios com ícone em traço branco puro.

**Alvo:**
1. `HudBar`: moldura de 2 px `0c0a0e` e friso de 1 px `8e7444` (ouro velho); vida `LIFE_COLOR` (0.78, 0.14, 0.12)
   para um degradê `c0302a` no topo a `6a1410` embaixo; Magia `MAGICK_COLOR` para `2a8fb8` a `14506a` (azul-petróleo
   claro, distinto do verde da Emeth e do petróleo do cachecol pelo valor).
2. `HeroCrest`: cabelo com três tons `5a1c0e` / `b8441c` / `e07a40`, `SCARF` `2c7478` e `SCARF_DARK` `0f3036`
   (os mesmos do herói, A2), anel duplo `8e7444` sobre `0c0a0e`.
3. `ActionSlot`: traço dos ícones vazios em pergaminho `d8c8a8` a 85% (não branco puro), moldura `8e7444` de 1,5 px
   com o miolo escuro; com dom, o ícone aceso fica como está.
4. Barra do chefe: mesma moldura das barras do herói; as cores (roxo da vida, amarelo da armadura) **não mudam**.

**Aceite** (capturas a 1280 x 720 e 1920 x 1080, `RES=`): texto das barras com altura >= 12 px a 1280 x 720;
losango >= 40 px a 1280 x 720 e >= 60 px a 1920 x 1080; contraste do texto sobre a barra >= 4,5:1; nada se sobrepõe;
nenhum elemento do HUD com amarelo saturado além do ouro (o amarelo fica para a armadura).

**Não pode piorar:** leitura rápida da vida e da Magia, nomes das teclas, tamanho e posição atuais do conjunto.

## D. Guardas globais (todas as seções)

- p50 da vitrine de 42 a 50 e p95 >= 105: o brilho geral **não sobe**.
- Avisos vermelhos, barra de armadura, clarão branco e números de dano iguais ou mais legíveis que nas capturas
  `antes/`.
- `tools/test.sh`, `tools/check.gd` e `tools/smoke.sh 300` sem regressão; nenhum número de combate muda.
- Desempenho medido pelo QA com `--stress=90`: no máximo +0,5 ms por quadro no desktop.

## E. Capturas de validação (as 7 do Daniel)

Mesmo script e semente das `antes/` (`c5/shots.sh <pasta>`), a 1672 x 941, Vulkan; a revisão final também em 1920 x
1080 e uma com `DRIVER=opengl3`.

| # | Captura | Comando (depois de `--`) | Seções |
|---|---|---|---|
| 1 | Arena vazia | `--showcase --shot-at=4` | B1, B2, B3, D |
| 2 | Explorador em combate | `--bot --autopick --shot-at=9` | A2, A3, B1 (aviso) |
| 3 | Sacerdote e Ancião | `tools/enemy_lab.gd` (`3_lab_game/front/back`) **e** uma sala do guardião na arena das catacumbas: `--start=miniboss --bot --autopick --shot-at=8` com uma semente que sorteie o Ancião | A1 |
| 4 | Elite | trocar o `--horde --start=elite1` (arena antiga) por uma sala comum com elites na arena das catacumbas (`--bot --autopick`, semente e tempo em que haja elite na tela) | A1 |
| 5 | Medalhão | `--showcase --cam-dist=32 --shot-at=4` | B1 |
| 6 | Combate com vários | `--bot --autopick --stress=90 --shot-at=6` | A1, A2, D |
| 7 | Morvath | `--start=boss --bot --autopick --shot-at=12` | A1, C, D |

Mais: 1280 x 720 e 1920 x 1080 do item 2 para o HUD (C); quadros `--frames=<prefixo> --count=12 --every=0.08` do
herói correndo e esquivando para o cachecol (A2).

## F. O que depende de modelo (não entra neste ciclo)

Corpos esguios dos inimigos, mantos com pregas, cabelo longo de Morvath, crânios com expressão, o cachecol de pano de
verdade e o rosto do Explorador: aproximamos por cor, peças rígidas e escala. Pedidos prontos em
`docs/art/enemies_phase1.md`, `docs/art/hero_explorer.md` e `docs/art/meshy_asset_plan.md`; gerar exige o Daniel.
