# Ciclo 4: revisão final do Art Director (2026-11-15)

Commits até `37631ab` (cenário B0 a B8, inimigos pela prancha, herói e multidão corrigidos, HUD novo). Meta:
`docs/art/ref/arena_catacumbas_1672.png` (pintura do Daniel) e `docs/art/ref/inimigos_fase1.png` (prancha). As duas
ficam fora do git. Diagnóstico e aceite de origem: `docs/art/cycle4_spec.md`.

## Evidência

Capturas reais tiradas nesta revisão (Vulkan, 1672 x 941, `--fixed-fps 30`), na pasta da sessão
`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/ad2/`:

- `vitrine.png`: `--showcase --seed=5`, 2 s (idêntica à `env4/v9.png` do Environment Artist: o estado é estável).
- `jogo9.png`: `--bot --autopick --seed=5`, 9 s.
- `jogo14.png`: o mesmo, 14 s (a máquina estava com carga 15 a 29 e a primeira tentativa passou de 500 s; ver o
  bloco em `visual_review.md`).
- Recortes lado a lado (pintura à esquerda): `c_portal.png`, `c_abismo.png`, `c_chao.png`, `c_chars.png`
  (personagens), `c_hero.png` (herói 4x), `c_hud.png` (HUD, pintura em cima).
- **Comparação**: `comparacao.png` (3344 x 1882: em cima pintura | vitrine, embaixo pintura | luta de 9 s) e
  `comparacao_small.png` (a mesma, 1672 de largura).
- Inimigos: galeria do Gameplay Engineer `.../scratchpad/en/lab4_game.png` e `en/prancha_vs_jogo.png`, comparadas
  com a prancha.
- Medidas: `python3 -I tools/art_metrics.py` e o script de estudo `.../scratchpad/tools/extra.py`.

Medidas da vitrine agora (pintura entre parênteses): aceite das regiões do ciclo 4 **8 de 13**. Passam: verde na
fachada 17% (13%), portal sd 37,6 e mediana #32ca24 (64; #33f953), verde nas estátuas 4% (10%), detalhe da fachada
11,1 (13,3), halo quente no braseiro leste 13,9% (13,6%), detalhe ali 10,3 (13,5), `abyss_left_cols` mediana #002c35
(#052f44), obelisco sul 8,5 (6,8). Falham: fachada à direita 6,8 (9,8; meta 7), estátuas do portal 8,9 (15,1; meta
10), chão limpo 7,6 (10,9; meta 8,5), sd do chão ao fundo 18,9 (33; meta 25), detalhe das colunas do abismo 3,3 (5,6;
meta 4,5). Globais: p50 47 (46), p95 110 (116), p99 165 (201), escuros 18% (13%), quentes estourados 0,5% (0,9%),
violeta à direita 0,1% (4,9%). Herói na luta de 9 s: 0,2% de pixels dourados na caixa dele (meta <= 3%).

## 1. Fidelidade por área

Graus: ALTA = lê como a pintura num lado a lado, com diferença só de acabamento; MÉDIA = a peça certa no lugar
certo, mas com forma, material ou luz visivelmente de outro nível; BAIXA = lê como outra coisa ou como
placeholder. Nenhum percentual de semelhança: as diferenças estão descritas.

| Área | Grau | O que ainda difere |
|---|---|---|
| Composição e câmera | ALTA | Portal, escada, obeliscos, braseiros, balaustradas, correntes e estátua noroeste caem onde a pintura os tem; só a ponta da ogiva do portal sai pelo topo do quadro. |
| Herói | MÉDIA | Já é escuro com cabelo cobre, cachecol petróleo e a lâmina verde (o dourado sumiu: 0,2%), mas o cachecol é pequeno e rígido, sem o pano que voa, e ele tem cerca de 75 px contra cerca de 100 na pintura. |
| Inimigos | BAIXA | Cores e peças seguem a prancha (elmo, panos vermelhos, capuzes roxos, coroas), mas os corpos são do KayKit, cabeçudos e atarracados, ao lado de um herói esguio; os elites e guardiões vêm embrulhados num halo rosa e roxo em vez do friso dourado; o Escudo (três deles na luta de 14 s) tem elmo de chifres, couro marrom e broquel redondo de madeira, e lê como anão guerreiro, não como esqueleto de armadura de bronze com escudo-torre. |
| Portal | MÉDIA | Lê como arco gótico fundo com ordens, colunelos, pendentes e janela em losango, e o verde ficou no vão, no degrau e no chão; o véu é um verde-amarelado liso (#32ca24) sem o miolo claro nem o brilho de borda da pintura (#33f953 com picos #92fc8b), as ordens se separam pouco e os pendentes parecem recortes. |
| Piso | MÉDIA | Lajes irregulares sem as faixas retas, com valor, lasca e canto faltando; ainda é lilás e uniforme no centro, com juntas de contorno de desenho animado, sem o brilho úmido e as pétalas visíveis (detalhe 7,6 contra 10,9; sd ao fundo 18,9 contra 33). |
| Medalhão | BAIXA | Na tela continua lendo como traço dourado fino com anéis e espirais (círculo de ritual desenhado), não como a faixa larga de pedra esculpida da pintura. |
| Arquitetura | MÉDIA | Pedra chanfrada e lascada, cantaria grande, cornijas, nichos e pináculos chegaram; a massa ainda é de cubos, a fachada à direita tem pouco relevo (6,8 contra 9,8) e os estandartes são placas vermelhas curtas sem ponta em V, borda nem queda até a altura da pintura. |
| Estátuas | BAIXA | São sólidos de revolução: a do noroeste lê como vulto marrom liso e as do portal como cones cinza; sem rosto, mãos, dobras nem o capuz fundo com máscara (detalhe 8,9 contra 15,1). |
| Iluminação | MÉDIA | Fogo em línguas, halo do braseiro na medida (13,9%) e verde localizado; mas a luz-chave lilás sobre o medalhão faz do centro a área mais clara e chapada (a pintura é escura ali, com poças quentes), o aro do braseiro lê como anel amarelo e as velas como palitos esverdeados. |
| Abismo | BAIXA | Tem planos e o violeta ficou embaixo à esquerda, mas lê como um fundo petróleo saturado e liso com lajes escuras retas e faixas verticais azul-violeta (detalhe 3,3 contra 5,6); sem o violeta à direita (0,1% contra 4,9%), a lanterna ainda lê como pentágono amarelo nessa escala; na luta de 14 s, indo para o leste, o cartão violeta do leste vira um painel lilás liso grande (luminância 136, logo abaixo do limite de 140). |
| HUD | MÉDIA | A linguagem é a da pintura (retrato em moldura redonda, barras em ângulo com números, ações em losango com a tecla, sala no alto à esquerda, relógio no centro, ouro à direita, contador de golpes com traço de pincel); o retrato é um ícone chapado, as barras são vermelho e azul saturados sem moldura escura, e os ícones vazios são traço branco (os da pintura são pinturas laranja acesas, o que no jogo só aparece com dom). |

Resumo honesto: os defeitos que o Daniel apontou no início do ciclo (herói dourado, inimigos de gesso, fachada
lavada de verde, bolhas de brilho, tijolos regulares, faixas retas no chão) saíram e há captura que mostra. A
distância que sobra é de modelagem (inimigos, estátuas, herói) e de valor e atmosfera (centro claro demais, abismo
liso). Fidelidade alta só na composição.

## 2. Comparação lado a lado

`/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/ad2/comparacao.png`
(versão reduzida: `comparacao_small.png` na mesma pasta). Fica no scratchpad porque contém a pintura (fora do git).

## 3. Correções rápidas e seguras para esta noite

No máximo seis, todas de constante, sem lógica nova; o Game Director decide quais aplica. Depois de aplicar:
recapturar a vitrine e a luta de 9 s e rodar `tools/art_metrics.py` (as globais e as 8 regiões que passam não podem
cair).

| # | Responsável | Arquivo e valor | Ganho | Aceite |
|---|---|---|---|---|
| 1 | Gameplay Engineer | `scripts/render/crowd_renderer.gd`: `OUTLINE_INTENSITY` 2.4 para 1.1 | Abaixo do limiar do glow (`Game.GLOW_THRESHOLD` 1,3): o contorno dos elites e guardiões vira friso dourado (o `ELITE_RIM` já é ouro) em vez do halo rosa e roxo que engole a figura | Na galeria `enemy_lab` e na luta, nenhum halo mais largo que 3 px em volta de elite ou guardião; a borda continua visível contra o chão |
| 2 | Environment Artist | `scripts/game/catacomb_hall.gd`: `KEY_LIGHT` Color(0.95, 0.82, 0.88) para Color(0.95, 0.8, 0.68); `KEY_ENERGY` 6.0 para 4.5; `KEY_RANGE` 18.0 para 14.0 | Tira o lilás e o chapado do centro e faz poça de luz que cai para as bordas, como na pintura | Pixel (800, 500) da vitrine com luminância <= 60 (hoje cerca de 85; pintura cerca de 46); `floor_center` mediana com R >= B; p50 global de 42 a 50; `floor_blue_dominant` de 40% a 65% |
| 3 | Environment Artist | `scripts/game/arena_kit.gd`: `PORTAL_SHEET` Color(0.2, 1.0, 0.14) para Color(0.22, 1.0, 0.34) | O véu passa do verde-amarelado ao verde-esmeralda claro da pintura | `portal_open` mediana com B >= 60 e G >= R + 120, mediana L >= 150; verde na fachada <= 20% |
| 4 | Environment Artist | `scripts/game/arena_kit.gd`: `RIM_GLOW_ENERGY` 0.6 para 0.3; `RIM_GLOW` Color(0.9, 0.4, 0.12) para Color(0.85, 0.3, 0.08) | A bacia volta a ser bronze escuro com a borda de dentro laranja, em vez do anel amarelo aceso | Recorte 2x do braseiro leste: aro escuro distinto da chama; halo quente ali <= 16%; quentes estourados não caem abaixo de 0,4% |
| 5 | Environment Artist | `scripts/game/catacomb_hall.gd`: `GLOW_EAST` 2.6 para 1.5 (igual ao oeste) | Na câmera de jogo indo para o leste (`jogo14.png`), o cartão violeta largo do leste vira um painel lilás liso de cerca de 170 x 300 px com luminância 136 (o limite do aceite era 140): é a "parede violeta chapada" que o Daniel já apontou | Na luta de 14 s, o canto direito embaixo com luminância <= 100 em (1600, 600) e o violeta ainda presente; a vitrine não muda (o cartão não entra nela) |
| 6 | Environment Artist | `scripts/game/catacomb_hall.gd` (`_facade`, `banner_thin_red`): escala Vector3(1.6, 2.1, 1.6) para Vector3(1.6, 3.4, 1.6), descendo o centro para manter o topo onde está | Os estandartes descem até a altura da pintura e voltam a marcar a fachada em vermelho | Na vitrine, o estandarte da direita do topo até perto de y 260 e o da esquerda até perto de y 130 (pintura: 30 a 270 e 0 a 130), sem atravessar estátua nem portal |

Sétima, se sobrar tempo (trivial): `scripts/game/masonry.gd` `WAX` Color(0.92, 0.86, 0.72) para Color(0.9, 0.76, 0.56),
para as velas pararem de ler como palitos verde-claros sob a luz petróleo.

Não entram como rápidas (precisam de trabalho de verdade): o medalhão em relevo legível, o abismo com silhuetas
detalhadas e bruma menos saturada, o escudo-torre do Escudo, o tamanho do herói na câmera de jogo (`Feel.cam_distance`
60 para 50 continua sendo decisão do Daniel).

## 4. O que só modelo esculpido resolve (ordem para quando houver créditos)

Gerar exige autorização do Daniel; tudo o que vier do Meshy entra em `docs/steam-ia.md`. Plano e prompts do cenário:
`docs/art/meshy_asset_plan.md`; inimigos: `docs/art/enemies_phase1.md`; herói: `docs/art/hero_explorer.md`.

1. **Esqueleto base adulto e esguio, com esqueleto de ossos humanoide** (soldado da prancha). É a maior diferença
   na luta: o KayKit cabeçudo ao lado do herói esguio. Um corpo serve ao Soldado, ao Corredor, ao Besteiro e, com
   capuz e manto como peças, ao Feiticeiro e ao Sacerdote (as paletas e peças nos ossos já existem).
2. **Herói Explorador** da folha aprovada (cachecol e manto de pano, ombreiras, cabelo em mechas): o cachecol que voa
   é a marca da figura na pintura.
3. **Estátua encapuzada de mãos postas** (quatro usos: gigante, par do portal, noroeste): o marco mais visível do
   cenário e o pior grau hoje.
4. **Escudo e Cavaleiro** (armadura pesada, escudo-torre com emblema; o Cavaleiro reaproveita o corpo com coroa e
   capa) e **Morvath** (rei esqueleto, cabelo longo, mantos).
5. **Moldura do portal gótico** (aduelas, colunelos e pendentes esculpidos; o procedural chegou à MÉDIA e o ganho
   restante é de lasca e ornamento).
6. **Obelisco lascado, braseiro de pedra e ferro, pilar de balaustrada** (itens 3 a 5 do plano de cenário).
7. **Ruínas do abismo** (arcos, pontes, pilares quebrados): antes de gerar, conferir os pacotes CC0 (Quaternius,
   Kenney) com licença verificada, que podem resolver sem crédito nenhum.

## Veredito

Aprovado para o teste do Daniel como a versão do ciclo 4: os defeitos que ele apontou saíram e as capturas mostram
isso, e nada quebra a leitura do combate (herói, inimigos, avisos vermelhos e números legíveis em `jogo9.png` e
`jogo14.png`). Não é fidelidade alta: só a composição chega lá. Recomendo aplicar antes as correções 1, 2 e 5 (as que
mais aparecem na luta), recapturar e conferir os aceites. A aprovação artística final é do Daniel.
