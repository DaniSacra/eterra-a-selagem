# Revisões visuais

Registro das revisões do Art Director: capturas reais do jogo comparadas com a referência aprovada pelo Daniel.
Critérios e métricas da arena: `docs/art/arena_reference.md`, seção "Critérios de fidelidade".

## 2026-11-14: diagnóstico da arena para a missão de reprodução

- Capturas: `c0_showcase` (vitrine, `--showcase --seed=5`, 1672 x 941, Vulkan) e `c0_game` (em luta), no scratchpad da
  sessão; experimento de névoa e luz numa cópia do projeto (`x1` a `x4`), sem mudança no repositório.
- Bate: câmera, losango da sala, posição do medalhão, da escada, do portal, dos braseiros e dos obeliscos (erros de
  20 a 50 px); tamanho do herói.
- Difere (P0): faixa de valor estreita e azul por causa da névoa sobre a sala; abismo sem profundidade nem violeta;
  medalhão lido como círculo de ritual; portal fraco em forma de casinha, sem verde no chão.
- Difere (P1): chão em pranchas com serrilhado nas juntas; obeliscos finos e pontudos; balaustradas miúdas; estátuas
  do KayKit; estátua gigante cortada no topo; velas e potes pequenos e apagados; braseiros rasos; correntes fora do
  quadro; estandartes curtos; multidão cor de gesso.
- Depende de modelo: escultura das estátuas, relevos da fachada, herói e inimigos da pintura.
- Pedidos: Environment Artist, P0-1 a P1-9 com valores na seção de critérios; P1-10 com dono a definir; UI/UX remover
  a barra de 8 px do topo (`xp_back`).
- Veredito: não aprovado para teste do Daniel; refazer a captura depois dos P0.

## 2026-11-14: ciclo 1 (P0-1, P0-2, P0-3)

- Capturas: `c3/showcase` (Vulkan) e `c3/compat_1.25` (`DRIVER=opengl3`), 1672 x 941, `--showcase --seed=5`, no
  scratchpad da sessão.
- Feito: névoa só depois da sala e névoa de altura no abismo; ambiente petróleo; luz de chave malva sobre o medalhão;
  braseiros com poças menores; profundezas e muralha numa camada de luz própria (`ArenaKit.DEPTH_LAYER`), fora do fogo,
  com três fileiras de colunas e arcos a oeste, luzes violetas baixas só nas laterais, cartões de brilho violeta
  (`abyss_glow.gdshader`) e `FogVolume` violeta no desktop; foco do portal na escada mais forte; medalhão refeito como
  rosa dos ventos de 8 pontas com anéis duplos, 16 volutas, folhas nos vãos e roseta (sem linhas cruzando o miolo),
  pontas longas na horizontal da tela, brilho 0,1.
- Medidas (vitrine, desktop): p1/p5 0/3 (alvo 4 a 10 / 10 a 16), p50 38 (42 a 50), p95/p99 106/167 (>= 105 / >= 170),
  < 20: 27% (9% a 17%), chão azul dominante 40% (40% a 65%), violeta esquerda/direita 7% / 2,9% (>= 6% / >= 3%),
  quentes estourados 0,3% (>= 0,7%), verde no chão 5% (>= 8%).
- Falta: pretos ainda fundos demais nas profundezas e na muralha da frente (subir um pouco a bruma ou o tint); brilhos
  quentes fracos; verde do portal no chão (P0-4); lanterna do abismo como janela ogival (P0-2).
- Navegador: `COMPAT_EXPOSURE` 0,72 para 1,25 e `COMPAT_AMBIENT` 0,3 para 0,4 (p50 36); o violeta do abismo sai azul
  e o chão fica azul dominante 75%: a acertar.

## 2026-11-14: ciclo 2 (P0-4, P1-1, P1-2)

- Referência guardada em `docs/art/ref/arena_catacumbas_1672.png` (fora do git: o repositório é público).
- Feito: chão em lajes quase quadradas (`stone_size` 1,9, `len` 1,0, `jit` 0,35), juntas de 0,055 m, chanfro 0,55, sem
  a normal por derivada (o serrilhado sumiu); poça molhada fixa em frente à escada do portal (`CatacombHall.WET`);
  portal como vão de luz com três pedras pendentes no alto e mais claro embaixo; janela em losango verde acima do vão;
  obeliscos grossos (2,2 e 2,3 m) em três blocos girados, topo em tronco de pirâmide torto, nicho ogival; colisão
  dos obeliscos pelo raio novo; fundo do abismo na cor da bruma e névoa de profundidade até 170 m.
- Medidas (vitrine): p50 37, p95/p99 101/167, < 20: 30%, verde no chão 4,6% a 7,5%, portal com mediana #21ca63.
- Falta: colunas do fundo a oeste e ao norte lidas como painéis azuis lisos (precisam de textura ou silhueta mais
  escura na bruma); pretos ainda fundos demais; o vão do portal ainda fecha em ponta (a fachada corta o alto);
  estátuas encapuzadas (P1-4), balaustradas (P1-3), velas e potes maiores (P1-6).

## 2026-11-14: ciclo 3 (abismo, portal, P1-3, P1-4, P1-6, P1-7, pretos)

- Capturas: `c3_vitrine`, `c3_luta` (Vulkan) e `c3_compat` (`DRIVER=opengl3`), 1672 x 941, `--seed=5`, no scratchpad
  da sessão.
- Abismo: as profundezas usam um material próprio sem luz (`assets/shaders/depth_stone.gdshader`,
  `Masonry.depth_stone`): pedra escura em fiadas, aresta fria na face voltada para a bruma, desbota na cor da bruma com
  a distância e afunda nela embaixo, violeta fraco de baixo nas laterais. Fica fora da lua e das luzes da sala; segue
  na camada `ArenaKit.DEPTH_LAYER`. Três fileiras de pilares com capitel e agulha e arcos ogivais, de frente para a
  câmera da vitrine, a 68, 82 e 98 m dela (`ROW_*` em `catacomb_hall.gd`); a torre das correntes no meio do alto; a
  janela acesa da pintura numa parede da fileira da frente (`_lantern`). Os cartões violetas foram para trás da
  fileira da frente (os pilares ficam escuros contra o violeta). Descoberto: o fundo da tela é a cor da névoa
  (`fog_sky_affect`), não `SKY`; a bruma é `Game.FOG` (petróleo claro, 0,07 0,28 0,31) e o material das profundezas
  desbota nela. A névoa volumétrica global foi zerada (`VOLUMETRIC_DENSITY` 0: iluminada pela lua, ela pintava
  painéis azul-claros lisos no fundo); os `FogVolume` violetas continuam.
- Correntes: os elos estavam de lado (o furo ao longo da corrente, viravam tracinhos); agora deitados ao longo dela,
  alternando um quarto de volta (`LINK_STRETCH`).
- Estátua gigante (P1-5): pés em y -0,4, 7 m, capuz no alto do quadro, luz do braseiro só na barra e nas mãos
  (`GIANT_UPLIGHT` 2,5).
- Portal (P0-4): vão retangular entre ombreiras grossas sob um lintel, três pedras pendentes, duas ordens em ogiva por
  fora com a pedra mais clara (`PORTAL_ORDER_*`), janela em losango de 1,0 x 1,2 m no tímpano, 1,4 m acima do vão;
  o véu de luz a 0,7 m da frente e num verde mais fundo que a luz (`PORTAL_SHEET`), para o miolo não estourar em
  branco. Vão de 3,4 x 4,8 m.
- Estátuas (P1-4): `Masonry.hooded_statue`, uma malha por torno (manto com 10 pregas, ombros, capuz com ponta atrás,
  rosto escuro por cor de vértice, braços até as mãos juntas), um material por tom; troca o boneco do KayKit em
  `ArenaKit.statue` (base em `Masonry.block`; colisão, quando sólida, 0,25 da altura). Estátuas do portal com 5 m.
- Balaustradas (P1-3): pilar 0,9 x 1,3, degrau e tampa de 1,1 m, vão de 3 m, corrimão 0,3 x 0,45 com topo a 1,05,
  rodapé 0,26, 3 balaústres com bojo; `top_light` 1,3.
- Velas e potes (P1-6): círios de cera creme de 0,3 a 0,9 m com escorrido e chama (`Masonry.candle`), halo de 0,9 m,
  luz 1,5 / 3,5 por grupo; grupos movidos para os pontos da pintura (balaustrada oeste em z 7,1 / 1,4 / -6,3 /
  -10,4 com o altarzinho e dois potes, junto ao obelisco sul o maior, patamar, leste, pé e alto da escada); potes de
  0,8 a 1,05 m com gargalo, lábio e boca escura.
- Braseiros (P1-7): bacia funda de bronze (0,65 / 0,35 / 0,45) com aro sobre pilar de balaustrada de 0,9 m; chama em
  línguas que afinam do branco-ouro ao laranja (30 línguas, vida 0,8). Colisão continua 0,6 (com 0,7 o teste de
  layout de três portas falhava junto ao obelisco leste).
- Pretos: juntas do chão e da cantaria menos pretas, ambiente 0,45 para 0,65, muralha sob a plataforma com tint 0,9.
- Medidas da vitrine (antes, no início do ciclo, e agora): p1/p5 0/2 para 2/9 (alvo 4 a 10 / 10 a 16); p50 37 para
  49 (42 a 50); p95/p99 99/166 para 140/187 (>= 105 / >= 170); < 20: 30% para 16% (9% a 17%); chão azul dominante
  42% para 50% (40% a 65%); quentes estourados 0,3% para 1,2% (>= 0,7%); violeta esquerda/direita 7% / 2,9% para
  8,5% / 3,6% (>= 6% / >= 3%); verde no chão 4,6% para 13,9% (>= 8%); `portal_open` mediana #21c962 para #3ad94f;
  `abyss_top_teal` mediana #0e1220 para #21343d (pintura #094256).
- Navegador: não quebrou; p50 33 para 35, < 20: 42% para 39%; sem violeta (como antes).
- Falta: p5 9 e p1 2 ainda um pouco abaixo da faixa (juntas do chão longe das luzes e faces de sombra dos obeliscos);
  as ordens do portal quase não leem na luz verde (a ogiva de fora fica acima do quadro); o braseiro leste ainda é
  um borrão de brilho atrás do entulho; potes pequenos na tela perto da pintura; estandartes (P1-9), manchas
  vermelhas (P2) e multidão (P1-10) não foram tocados; composição do lado esquerdo baixo (a pintura tem abismo onde
  o jogo tem o patamar) é da planta da sala, não do cenário.

## 2026-11-14 (noite): ciclo 4, diagnóstico

- Pedido do Daniel: "ainda distante da qualidade visual desejada"; meta `docs/art/ref/arena_catacumbas_1672.png`.
- Capturas: `ad_vitrine`, `ad_luta` (9 s) e `ad_luta14` (Vulkan, 1672 x 941, `--seed=5`) e recortes `ref_*` / `g_*`
  no scratchpad da sessão; a captura do Daniel (1901 x 1010, sala 1) descrita pelo Game Director confirma o mesmo.
- Achado: as oito métricas globais do ciclo 3 estão na faixa, mas a imagem não lê como a pintura. A distância agora
  é de forma, material e forma da luz: medida nova de detalhe (laplaciano) fica de 1,5x a 9x abaixo da pintura na
  fachada, no miolo do portal, nas estátuas, no braseiro, no chão e no abismo; o verde cobre 49% da fachada (ref 13%)
  e 63% das estátuas do portal (ref 10%); o halo quente do braseiro leste é o dobro. `abyss_left_cols` (#26215d)
  reprova o aceite P0-2 que o ciclo 3 não mediu.
- Mais perceptível: herói dourado translúcido (suspeita: passe de raio X aditivo sem teste de profundidade sobre o
  corpo todo), multidão de gesso sem preto interno nem sombra, portal retângulo liso lavando a fachada de verde,
  fogo em bolhas de glow, cantaria de tijolos regulares e caixas sem chanfro, chão com fileiras contínuas.
- Especificação completa, valores, donos e aceite: `docs/art/cycle4_spec.md`.
- Veredito: não aprovado para teste do Daniel.

## 2026-11-15 (madrugada): ciclo 4, implementação (Environment Artist)

Capturas (Vulkan, 1672 x 941, `--seed=5`) no scratchpad da sessão, pasta `env4/`: `v0.png` (início do ciclo) a
`v9.png` (final, vitrine), `l4.png`, `l7.png` e `l9.png` (luta, 9 s), `o8.png` (navegador, `DRIVER=opengl3`);
recortes lado a lado `c_*.png` (pintura à esquerda). Medidas com `tools/art_metrics.py` e o script de estudo do Art
Director (regiões do aceite (e)).

| Medida (vitrine) | Pintura | Início (v0) | Final (v9) | Meta |
|---|---|---|---|---|
| Verde na fachada | 13% | 49% | 17% | <= 20% ok |
| sd do miolo do portal | 64 | 9 | 38 | >= 35 ok |
| Mediana do portal (L; G - R) | 195; 198 | 173; 86 | 158; 152 | >= 150; >= 120 ok |
| Verde nas estátuas do portal | 10% | 63% | 4% | <= 25% ok |
| Detalhe da fachada | 13,3 | 6,3 | 11,1 | >= 9 ok |
| Detalhe da fachada à direita | 9,8 | 5,8 | 6,8 | >= 7 falta pouco |
| Detalhe das estátuas do portal | 15,1 | 6,4 | 8,9 | >= 10 não |
| Halo quente no braseiro leste | 13,6% | 28% | 14% | <= 16% ok |
| Detalhe no braseiro leste | 13,5 | 4,9 | 10,1 | >= 9 ok |
| Detalhe do chão | 10,9 | 5,1 | 7,6 | >= 8,5 não |
| sd do chão ao fundo | 33 | 17 | 19 | >= 25 não |
| `abyss_left_cols` mediana (G - R; B - R) | 23; 61 | -5; 41 | 44; 53 | >= 20; >= 25 ok |
| Detalhe `abyss_left_cols` | 5,6 | 2,7 | 3,3 | >= 4,5 não |
| Detalhe do obelisco sul | 6,8 | 5,8 | 8,5 | >= 6,5 ok |
| Globais p1 / p5 / p50 | 7 / 14 / 46 | 2 / 9 / 49 | 2 / 9 / 47 | 4-10 / 10-16 / 42-50 (p1, p5 baixos, como antes) |
| Globais p95 / p99 | 116 / 201 | 139 / 188 | 110 / 166 | >= 105 / >= 170 (p99 caiu com o fim do estouro) |
| Pixels < 20 | 13% | 16% | 18% | 9% a 17% (um ponto acima) |
| Chão azul dominante | 54% | 50% | 56% | 40% a 65% ok |
| Quentes estourados | 0,9% | 1,2% | 0,5% | >= 0,7% não (o estouro saiu com o glow) |
| Violeta esquerda / direita | 11% / 4,9% | 8,5% / 3,6% | 7,4% / 0,1% | >= 6% / >= 3% (direita não) |
| Verde do portal no chão | 13% | 13,9% | 13,4% | >= 8% ok |
| `stairs` mediana | #136462 | #1c5f1f | #0a4a4b | #0f5050 a #1a7068 (no limite) |

O que mudou, por área:
- Luz (B5): glow com limiar 1,3 e o nível mais largo a 0,3 (`Game.GLOW_*`), SSAO 3,0 / raio 1,0 / 0,2 na luz direta
  (`Game.SSAO_*`), ambiente 0,65 para 0,85 (o SSAO mais forte escurecia tudo). Fogo em línguas de verdade: cartão em
  gota pontuda que gira em Y (`ArenaKit.tongue`), línguas laranja em volta de um miolo branco-ouro (`FLAME`,
  `FLAME_HEART`, cores abaixo de 2), aro de bronze aceso por dentro (`RIM_GLOW`), brasas menos estouradas; velas na
  mesma forma, halo 0,5 a 35%. O braseiro lê como bacia com chama em línguas (recorte `c_se8.png`).
- Portal (B1): pórtico que avança 1,6 m da parede (`PORTAL_PORCH`; com o vão fundo dentro da parede o portal saía
  35 px alto e 25 px à direita da pintura; agora vão em x 1265 a 1374), quatro ordens de aduelas separadas em arco
  quebrado (`Masonry.voussoir_arch`, raio 0,8 do vão), colunelos com base e capitel, véu 2,2 m atrás da ordem de fora
  com degradê, bordas escuras, fiapos subindo e duas manchas claras no pé (`portal.gdshader`), pendentes escuros
  serrilhados em duas peças (o do meio com 2,3 m), tímpano recuado com a janela em losango com moldura e cruz de
  pedra, gablete de 60 graus, pináculos com ganchos nos contrafortes ao lado. Luz verde: omni de alcance 5,5 dentro do
  pórtico mais duas pequenas nas faces internas; o foco da escada não acende mais a fachada nem as estátuas
  (`ArenaKit.FACADE_LAYER`), virou verde-petróleo e abriu para 60 graus (os degraus pegam o verde como na pintura).
- Fachada (B2): cantaria grande e irregular (`Masonry.ashlar`: fiadas de 0,9 a 1,4 m, blocos de 1,2 a 2,6 m, lascas
  nos cantos, tom petróleo), plinto, duas cornijas, nichos ogivais cegos e janelas altas com mainel, e uma luz fria
  rasante só na fachada (`FACADE_FILL`) para as pedras e as estátuas lerem petróleo escuro, nunca pretas.
- Pedra (B0): toda caixa de `Masonry` é chanfrada (`bevel_mesh`, 0,06 m e 0,1 m nos blocos grandes), as pequenas com
  giro de até 1,5 grau, tamanho de 96% a 100% e 30% com um canto lascado; o shader acende o chanfro de cima (1,45) e
  o do lado da luz (1,15), escurece juntas e lascas; obeliscos com rachaduras verticais e moldura no nicho. A normal
  por `dFdx` saiu (era o serrilhado dos degraus). Relevo de pedra real CC0 (Poly Haven "Rock Surface", só normal e
  altura, sob a nossa cor; `docs/art/asset_credits.md`).
- Chão (B3): as duas faixas escuras retas eram um defeito do `stones()` antigo (quando a borda de cima de uma fileira
  caía abaixo da linha inteira, a faixa entre as duas virava junta preta de ponta a ponta), não sombra. Chão novo em
  amarelinha (lajes de 2,4 m e 1,2 m, 30% das grandes partidas em duas e 10% em três; nenhuma junta reta passa de
  3,6 m), cantos arredondados, borda tremida por laje, valor e tom por laje, inclinação de até 3 graus e chanfro com
  normal analítica, cantos faltando com cascalho, lascas, rachaduras em 25%, pétalas vermelhas raras; molhado só em
  frente ao portal e num anel em volta de cada braseiro (`ArenaKit.BRAZIER_WET`).
- Medalhão (B4): faixa larga em relevo, mais clara, com volutas em S em sulco, pontas cheias com metade clara e
  metade escura e uma crista no meio, sulco escuro com fio de ouro velho sem emissão; as juntas passam por baixo a 40%.
- Abismo (B7): quatro planos (o último com pilares quebrados), fileira da frente mais alta e fina com arcos acima do
  chão, aqueduto sobre os capitéis, faixas nos fustes, aresta fria só no topo, pedra mais escura e petróleo; bancos de
  bruma clara entre os planos (`abyss_mist.gdshader`); cartões violetas viram para a câmera real e têm borda de
  ruído, do -10 ao 0 (sem faixa violeta acima disso); lanterna como janela ogival de vidro em degradê com moldura e
  halo pequeno. Luzes violeta em -12.
- Estátuas e correntes (B6): pregas mais fundas até o peito, cinto, mangas largas sobre as mãos, máscara clara no
  capuz escuro, base em dois degraus, ruído menos contrastado e rim 0,15; gigante mais escura; elos de corrente mais
  grossos com um rim frio.
- Desempenho: a pedra estática é juntada por material, camada e quadrado de 8 m depois de montada
  (`Masonry.merge`): a sala de três portas passou de 1043 malhas (antes do ciclo) para 300; luzes 18 omni + 4 com
  sombra + 2 spots para 20 omni + 4 com sombra + 3 spots (nenhuma luz com sombra nova); partículas 10 para 14.

O que ainda difere da pintura (honesto):
- Estátuas: continuam bonecos de revolução; leem como vulto encapuzado com pregas, sem rosto, mãos nem dobras
  esculpidas (detalhe 8,9 contra 15). Precisa de modelo.
- Chão: mais vivo, mas ainda mais uniforme e mais "contornado" que a pintura (detalhe 7,6 contra 10,9); falta a
  pincelada fina e o brilho de borda das lajes.
- Abismo: a esquerda tem planos e violeta embaixo, mas a arquitetura é de caixas (detalhe 3,3 contra 5,6); a direita
  de baixo é ocupada pela escada leste (planta), então o violeta da direita sumiu (0,1%).
- Quentes estourados caíram de 1,2% para 0,5% com o fim dos halos; a pintura tem 0,9% em chamas com forma. Mais
  línguas e velas maiores ajudaram pouco.
- Portal: lê como arco fundo com ordens, pendentes e janela, mas as ordens se separam pouco (falta sombra entre elas)
  e a ponta da ogiva sai do quadro.
- Estandartes (P1-9) não foram tocados.
- Navegador: sem quebra; violeta do abismo continua sem aparecer no Compatibility (como no ciclo 3) e o relevo do
  chão fica mais forte que no desktop.
- Luta (9 s e 14 s, `--bot --seed=5`): a câmera de jogo não mostra cartão violeta de lado nem faixa reta; o "ponto
  vermelho" no alto da corrente não é do cenário: é o projétil violeta do mago (aparece também no meio do chão aos
  9 s); nenhum emissor vermelho existe no cenário. Perto do canto leste, aos 14 s, o violeta do abismo fica forte e
  recortado pelos blocos da escada leste (silhueta de pedra contra a luz, como na pintura, mas grande na tela).
- Verificação: `check.gd` sem erros; `tools/test.sh` 134 testes, 133 passando, 1 sem asserção (`test_only_finishers_glint`,
  de outro dono); `tools/smoke.sh 120` step_ms 0,1; com `--stress=300` step_ms 0,11.

## 2026-11-15: ciclo 4, revisão final (Art Director)

- Capturas próprias (Vulkan, 1672 x 941, `--fixed-fps 30`, commits até `37631ab`), no scratchpad da sessão, pasta
  `ad2/`: `vitrine.png` (`--showcase --seed=5`, 2 s; idêntica à `env4/v9.png`), `jogo9.png` e `jogo14.png`
  (`--bot --autopick --seed=5`). A máquina estava com carga de 15 a 29: a captura de 14 s passou dos 500 s na primeira
  tentativa e foi refeita com prazo maior. Recortes lado a lado `c_portal`, `c_abismo`, `c_chao`, `c_chars`, `c_hero`,
  `c_hud`; comparação inteira em `ad2/comparacao.png`. Inimigos pela galeria `en/lab4_game.png` contra a prancha.
- Medidas: aceite das regiões do ciclo 4 em 8 de 13 (passam verde da fachada, portal, verde das estátuas, detalhe da
  fachada, halo e detalhe do braseiro, cor das colunas do abismo, obelisco; falham fachada à direita 6,8, estátuas
  8,9, chão 7,6, sd do chão ao fundo 18,9, detalhe das colunas do abismo 3,3). Herói com 0,2% de dourado (meta 3%).
- Bate: composição e câmera (todas as peças no lugar da pintura); herói escuro com cabelo cobre, cachecol petróleo e
  lâmina verde; verde só no vão, no degrau e no chão em frente; fogo com línguas; pedra chanfrada; chão sem as faixas;
  HUD na linguagem da pintura (retrato, barras em ângulo, losangos com tecla, contador de golpes com pincel).
- Difere, por prioridade: (1) inimigos cabeçudos do KayKit ao lado do herói esguio, elites e guardiões com halo rosa
  e roxo, o Escudo lê como anão de chifres; (2) centro do chão claro e lilás pela luz-chave do medalhão, onde a
  pintura é escura com poças quentes; (3) abismo liso e saturado, e na luta de 14 s um painel lilás chapado no canto
  leste; (4) estátuas sem rosto nem mãos; (5) medalhão ainda lê como traço; (6) véu do portal verde-amarelado liso;
  (7) estandartes curtos; (8) aro do braseiro como anel amarelo e velas esverdeadas.
- Depende de modelo: esqueleto base adulto, herói Explorador, estátua encapuzada, Escudo, Cavaleiro e Morvath,
  moldura do portal, obelisco, braseiro e balaustrada, ruínas do abismo (ordem em `docs/art/cycle4_final.md`).
- Pedidos: seis correções de constante em `docs/art/cycle4_final.md`, seção 3 (contorno dos elites para o Gameplay
  Engineer; luz-chave, véu do portal, aro do braseiro, cartão violeta do leste e estandartes para o Environment
  Artist), cada uma com aceite medido.
- Veredito: aprovado para o teste do Daniel como a versão do ciclo 4, sem declarar fidelidade alta (só a composição
  é ALTA; personagens, portal, piso, arquitetura, luz e HUD em MÉDIA; inimigos, estátuas, medalhão e abismo em BAIXA).
  Recomendo aplicar antes as correções 1, 2 e 5 (as que mais aparecem na luta) e recapturar.

## 2026-11-15: ciclo 7, diagnóstico (Art Director)

Antes de qualquer mudança. Capturas: `docs/gallery/jogo/` (ciclo 6) e as novas de `docs/art/shots/cycle7_before/`
(golpes da Emeth em rajada, herói parado e correndo, Cavaleiro, sala da fonte). Especificação com problemas por
caixa, critérios de aceite, donos por arquivo e contrato de capturas: `docs/art/cycle7_spec.md`.

- Bate: herói legível em campo aberto (L 77 contra 46 do chão), escala dos guardiões e de Morvath, avisos vermelhos
  inteiros sobre o medalhão, efeitos de acerto só em acerto real.
- Difere do pedido do Daniel: corte em leque de faixas sem direção; clarão branco que apaga herói e inimigos no golpe
  forte; meia-lua do Ômega com 73% da largura da tela; Seta de Luz como bola de fogo amarela; círculo de luz como
  disco creme opaco; herói ciano chapado quando coberto e branco inteiro ao levar golpe; Esqueleto e Corredor com a
  mesma paleta; Sacerdote sem sinal de ritual; ouro do elite cobrindo a caveira; Morvath cinza no jogo; portal com 75%
  da folha estourada (porta amarela 54%); estátuas com capuz que lê como furo; painéis violeta lisos no abismo; aro do
  medalhão quase sem relevo; retrato do HUD em outro estilo; nome do golpe e relógio com pouco contraste.
- Depende de modelo que não existe: estátuas, moldura do portal e ruínas (provisórias até o `meshy_asset_plan.md`).
- Veredito: nada a aprovar ainda; ciclo 7 não começou.

## 2026-11-15: ciclo 7, revisão final (Art Director)

Capturas reais na RTX 5060 (Vulkan Forward+, commit `7fb5b4b`): `docs/gallery/cycle7/` (22 do contrato, `06b`, `12b`
e quatro montagens de antes e depois); antes em `docs/gallery/jogo/`, `docs/gallery/enemies/` e
`docs/art/shots/cycle7_before/`. Revisão completa, com imagens e medidas refeitas nos JPG:
`docs/gallery/cycle7/ART_REVIEW.md`.

- Bate: tela de título com a arte aprovada; herói nas próprias cores quando coberto (cobre 21%, petróleo 5,0%, ciano
  1,3% na caixa dele em `20`) e sem silhueta branca ao levar golpe; fita única, dardo verde reto, estocada sem
  listras, círculo de luz em aro fino, meia-lua do Ômega em cerca de 25% da largura; Morvath violeta (36% da caixa);
  orbe violeta do Feiticeiro; caveira do elite marfim; portal sem estouro (18% de canais em 250, mediana de L 159,
  desvio 53); fachada com verde 0,146; estátuas com pregas (desvio 18,5 e 27,1 nas do portal); medalhão com relevo;
  retrato do HUD no estilo do título; textos do HUD com sombra.
- Difere: B5 herói mais difícil de achar no bolo de 90 que o ciano antigo (multidão mais colorida, orbes, números);
  B4 inimigos atingidos em branco chapado cobrindo o herói no Ômega (14,3% de brancos na caixa de 300 x 220, meta 10%);
  B2 verde nos degraus com o portal vermelho (`13`); B3 herói atrás do obelisco parece em cima dele; cerca de 16
  números num grupo em `19` (meta 8); barras vermelhas 2,3% do bolo (meta 2%); ouro do elite quase invisível;
  estátua gigante com desvio 17,3 (meta 18); capuz ainda lê como furo de perto; B6 herói a cerca de 17% da borda em `19`.
- Sem evidência: `08b_emeth_circulo`, `15b_porta_amarela`, `22b_hud_2560`; aro de ritual do Sacerdote; divisa para
  guardião fora da tela; teste de silhueta J1 (figuras pequenas demais no laboratório `09`).
- Depende de modelo que não existe: estátuas, moldura do portal e ruínas (provisórias, `meshy_asset_plan.md`).
- Desempenho: 90 inimigos +0,48 ms e 300 inimigos +1,19 ms por quadro, acima do orçamento da especificação (M1, em
  correção; medir de novo). Retrato do HUD recortado da arte do título feita por IA: registrar em `docs/steam-ia.md`.
- Veredito: título, Explorador, Emeth, inimigos, arena e HUD aprovados com ressalvas; combate com hordas pendente
  (B5). Pode ir para o teste do Daniel como versão do ciclo, com B5, B4 e B2 como os três pedidos seguintes.

## 2026-11-15: C11, Câmara do Selo, análise da referência e especificação (Art Director)

Sem captura do jogo (nada implementado ainda). Referência `docs/art/ref/morvath/camara_do_selo.png` (só local) medida
pela câmera do jogo; especificação em `docs/art/boss_chamber_spec.md`.

- Medido: a pintura fecha com giro 35°, inclinação 27°, campo 24° e distância 51 (a do jogo é 30° e 54); com esse giro
  a porta fica ao norte (rumo 1°) e a escadaria de entrada ao sul (178°, embaixo à esquerda da tela); a fachada encara
  a câmera (frente para o rumo 165°), não o centro. Selo: anel externo em r 3,5 a 3,66, interno em 2,82 a 2,96, oito
  raios iguais até r 5,0.
- Decidido pela regra de colisão (tudo na borda ou fora): o par de sarcófagos de baixo à direita sai de dentro do chão
  para a borda; velas sobem para um ressalto da balaustrada. Cruzes trocadas por leão e espada erguida (D-16, D-17).
- Câmera: alvo fixo 0,7 m do centro na direção da câmera; em 16:9 a câmara cabe inteira com o herói a 20% da borda no pior ponto.
- Depende de modelo que não existe: nada obrigatório; estátuas e leão em relevo são procedurais.
- Veredito: especificação pronta para o `environment-artist` e o `gameplay-engineer`; revisão quando houver capturas.
