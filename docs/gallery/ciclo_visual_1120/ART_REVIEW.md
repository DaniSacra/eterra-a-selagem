# Revisão de arte: ciclo visual 2026-11-20, cenário (Salão e Santuário)

Art Director, 2026-11-20. Base: árvore de trabalho sobre `a61349c` (mudanças ainda sem commit). Pedido do Daniel:
`docs/design/ciclo_visual_2026-11-20.md` itens 1 e 2; metas: `docs/art/benchmark_hades2_style.md` ENV-HB1 a HB3 e HB6;
implementação: `CLAUDE.md`, seção "Ciclo visual 2026-11-20, cenário".

Critério do Daniel: passa se o olho encontra primeiro o Guerreiro e o perigo, e se a sala continua reconhecível pela
arquitetura e pela luz.

## O que foi avaliado

- Salão, antes e depois (RTX, 1920 x 1080, semente 5, estilizado): `env_hall_fight_far_*` (Longe), `env_hall_fight_near_*`
  (Perto), `env_hall_showcase_*` (vitrine), `env_hall_fight_far_compat_after.jpg` (Compatibility; apesar do nome, é o
  enquadramento Perto), `env_fountain_near_*`, `env_shop_near_*`.
- Uma captura nova, minha, com avisos no chão (as da galeria não têm nenhum perigo armado):
  `tools/gpu.sh shot ... --look=stylized --cam=near --stress=7 --stress-ids=archer,skeleton,runner,mage --seed=5
  --hero-at=0,0 --shot-at=3.2`, no scratchpad da sessão (fora do repositório; pode ser refeita com o comando).
- Santuário: `env_hub_arrive_*`, `env_hub_mid_*`, `env_hub_smith_*`, `env_hub_book_*`, `env_hub_vendor_after`,
  `env_hub_tree_after`, `env_hub_smith_compat_after`, tiras e vídeos `env_hub_walk_book|smith`.
- Medidas: `python3 -I tools/frame_stats.py --hue` com as caixas padrão do benchmark (Meio `640,360,640,360`, Laterais
  `60,140,320,760` e `1540,140,320,760`, Perto `520,780,880,150`; no hub as bordas do ENV-HB6).

## 1. Salão

### Números (antes / depois)

| | Longe | Perto | Vitrine | Meta |
|---|---|---|---|---|
| Cena: sat p50 | 0,14 / **0,41** | 0,12 / **0,38** | 0,15 / **0,41** | 0,30 a 0,45 |
| Cena: luma p50 | 65 / 54 | 72 / 61 | 67 / 58 | 45 a 65 |
| Cena: matiz | 210 / 205 | 221 / 205 | 206 / 205 | até 15 graus do de antes |
| Meio luma p50 | 80 / 76 | 86 / 87 | 75 / 75 | |
| Lateral E, D (razão ao meio) | 0,56 e 0,56 / **0,45 e 0,54** | 0,63 e 0,74 / **0,49 e 0,60** | 0,61 e 0,67 / **0,51 e 0,60** | até 0,65 |
| Perto (razão) | 0,78 / **0,59** | 1,00 / **0,66** | 1,04 / **0,75** | até 0,65 |
| Chão nu 200 x 150, p90 menos p10 | 44, 58, 42 / **19, 32, 18** | 36, 44, 40 / **23, 20, 22** | | até 30 |
| Herói p90 menos chão vizinho p50 | +88 / **+97** | +106 / **+108** | | 90 ou mais |
| Aviso do corredor (captura nova) | | vermelho 61% da caixa, sat 0,51, luma 124 sobre chão de cerca de 60 | | |

### O que bate

- **Hierarquia**: nas três vistas o olho vai ao Guerreiro (marfim e cobre sobre azul-petróleo, a Emeth é o único verde do
  campo) e, com a captura nova, ao aviso vermelho antes de qualquer coisa do chão. Vermelho sobre petróleo é o par
  complementar: o aro do corredor e as barras de vida leem mais que antes. Os esqueletos (osso morno, matiz cerca de 30)
  saem do chão pelo matiz, como pede o TA-HB3.
- **Chão em duas escalas**: a grade de juntas, que tinha o peso dos contornos dos inimigos, sumiu como linha; ficaram a
  forma das lajes, as lajes emolduradas, o medalhão com as runas e a variação larga (caixas a 6 m diferem 15 a 20 de
  luma).
- **Cor**: a sala ganhou ar (saturação dentro da faixa do Hades II e do Ember & Blade), e o âmbar dos braseiros agora
  marca setores (poças maiores e mais quentes) em vez de virar bege.
- **Moldura**: laterais e faixa de perto descem; a sala parece um terraço iluminado no meio do abismo, não um tabuleiro
  plano de borda a borda.
- **Reconhecível**: portal verde, escada larga, estátuas encapuzadas, balaustradas com velas, obeliscos e medalhão estão
  todos no lugar e legíveis. A sala continua o Salão.
- Fonte e loja continuam lendo; as poças das lanternas da loja saíram do amarelo vivo.

### O que difere ou piora

1. **Manchas do bioma viraram a textura mais forte do chão** (P1, environment-artist). Com as juntas caladas, as manchas
   escuras do SW-G1 (`STY_FLOOR_BIOME`) e o resto do "lavado" ficaram com cara de mancha de umidade ou de nuvem suja, de
   borda serrilhada, espalhadas sem relação com a luz. Não atrapalham o critério (herói e perigo vêm primeiro), mas, se o
   tratamento for espalhado assim, essa mancha vira a assinatura de toda sala. A escala larga deve vir da luz e do
   material (poça morna, zona fria, lajes emolduradas, medalhão), não de ruído.
2. **O Salão foi para o matiz da Cripta** (P1, art-director e environment-artist, antes de replicar). O Salão estava na
   faixa 215 a 235 da matriz (`room_redesign_matrix.md`); agora mede 205 a 207, dentro da faixa da Cripta (198 a 215) e
   colado na Ponte (205 a 220). Foi pedido do Daniel ("devolva azul-petróleo à pedra"), então fica; mas três biomas no
   mesmo matiz e com a mesma saturação perdem identidade. Ver a ordem de replicação abaixo.
3. **Faixa de perto acima de 0,65 na Perto (0,66) e na vitrine (0,75)**: ver a pergunta 3.
4. **Derrame verde do portal no chão** (P2, environment-artist): na Longe a mancha junto às velas do canto nordeste
   passou de matiz 133, sat 0,19, verde 0% para matiz 164, sat 0,36, verde 7,5% (caixa `1440,320,140,60`). Sobre o
   petróleo o derrame lê como mancha esmeralda no chão, e o esmeralda é reservado. Segurar o derrame nos degraus ou
   puxá-lo para o ciano do abismo.
5. **Compatibility contrastado demais** (P2, environment-artist; o navegador é secundário): meio 99 contra laterais 25 e 29
   (0,25 e 0,29) e faixa de perto 20 (0,20); a poça de luz sob o herói vira lima (matiz 60 a 64, sat 0,21, luma 133;
   no Forward+ matiz 40, sat 0,09). Pedir `STY_COMPAT_*` do Salão: chave mais baixa e a poça no matiz 35 a 45.
6. **Mudança de matiz de 16 graus na Perto** (221 para 205), um grau além do aceite do ENV-HB1. Aceito por ser o pedido do
   Daniel; a matriz muda (ver P1-A3).

### Depende de asset (não bloqueia)

Caixotes, barris e velas são do KayKit (provisórios); as colunas quebradas da moldura são procedurais. Nada pede Meshy.

## 2. Santuário (hub)

### Números (HB6, antes / depois)

| Vista | Cena luma | Cena sat | Meio luma | Bordas: cima, baixo, E, D (razão ao meio) |
|---|---|---|---|---|
| Chegada | 80 / 55 | 0,24 / 0,27 | 88 / 60 | 0,88 0,77 0,86 0,82 / 0,88 0,75 0,87 0,90 |
| Meio | 81 / 56 | 0,23 / 0,27 | 95 / 70 | 0,71 0,85 0,80 0,79 / 0,67 0,79 0,74 0,77 |
| Forja | 80 / 56 | 0,23 / 0,27 | 78 / 54 | / 0,80 1,17 1,04 1,02 |
| Livro | 77 / 54 | 0,23 / 0,27 | 84 / 70 | / 0,61 0,79 0,80 0,51 |
| Vendedor, Árvore | / 53, 52 | / 0,27, 0,28 | / 61, 78 | |

Contraste das estações (do environment-artist, conferido a olho nas capturas): Forja 3,2, Livro 2,06, Vendedor 1,82,
Árvore 3,2 vezes a praça.

### O que bate

- **Forja** lê pelo fogo, pela bigorna e pelo Forjador: a poça vai da boca do forno ao homem e à bigorna, e a figura dele
  é a mais clara do canto. **Livro** lê pela mesa, pela página e pela luz de leitura (a página tem p90 249 mas só 0,1% de
  pixels acima de 235: não estoura). Vendedor e Árvore também ganharam a poça própria. É o pedido do item 2.
- Na passagem (tiras `env_hub_walk_*_strip.jpg`) a praça e os caminhos de ouro continuam visíveis.
- O matiz morno (40) separa o hub de toda sala de luta, que agora mede 205 a 255 (menos Santuário e Altar).

### O que difere

1. **O portal não aparece no quadro de chegada** (P1, gameplay-engineer pela câmera, environment-artist pela poça). O
   Daniel pediu "o portal deve continuar fácil de encontrar no quadro de chegada". Na câmera Perto (padrão) a chegada
   mostra a fonte e a estela no alto; a "poça verde-pálida no pé da escada do portal" que deveria apontar o caminho não
   aparece: caixa `700,0,520,110` com verde 0% antes e depois. Já era assim antes desta passada; agora fica mais visível
   porque o resto escureceu.
2. **Escureceu tudo por igual** (P2, environment-artist): a cena caiu de 80 para 55, mas as bordas continuam a 0,75 a 0,90
   do meio na chegada. O foco das estações veio das poças (bom); a moldura do pátio não mudou de relação.
3. **Primeiro quadro das tiras com o herói de pé dentro da fonte, de espada na mão** (P2, verificar; technical-artist
   pelo `tools/hub_walk.gd`, gameplay-engineer se for do jogo): nas duas tiras o quadro 1 mostra o Guerreiro no meio da
   bacia, fora da chegada (0; -7,8) e fora da pose em paz. Pode ser o primeiro quadro da ferramenta antes de pôr o herói
   na chegada; se aparecer no jogo, é bug.
4. A água da fonte (`dark_water`) lê como mármore de veios brancos, não água (P2, environment-artist; já era assim).

## Pedidos de correção

### P1 (antes de espalhar o tratamento)

- **P1-A1, environment-artist, manchas do Salão.** Manchas do bioma maiores, menos numerosas e de borda macia, puxadas
  para onde a luz já cai (perto das poças mornas mais claras, nos cantos mais escuras), sem as manchas escuras isoladas
  no meio do campo. Aceite: na Perto e na Longe (semente 5, 9 s), nenhuma mancha escura fechada menor que 4 m de borda
  serrilhada no campo da luta (conferir a olho com a captura lado a lado); chão nu 200 x 150 continua até 30; duas caixas
  a 6 m ou mais continuam com 10 ou mais de diferença; caixa `1150,560,400,260` na Perto com p90 menos p10 até 35 (hoje
  33: não piorar).
- **P1-A2, gameplay-engineer (câmera) e environment-artist (poça), portal na chegada ao hub.** Na câmera Perto, ao
  chegar, o quadro mostra o portal: ou a câmera olha para o norte nos primeiros 1,5 s e depois passa a seguir o herói
  (como a Longe faz, `HubPlan.near_want`/`NEAR_SOUTH`), ou a poça verde do pé da escada entra no alto do quadro. Aceite:
  `tools/gpu.sh shot x.png --hub --cam=near --shot-at=1` com verde 5% ou mais numa caixa de 300 x 150 no terço de cima;
  `--cam=far` igual a hoje.
- **P1-A3, art-director (eu), matriz dos biomas.** Atualizar `docs/art/room_redesign_matrix.md` e a seção 3 do
  `art_direction.md` com o piso de saturação (cena 0,30 a 0,45), a moldura (até 0,65; regra da faixa de perto abaixo), o
  chão nu (até 30) e o Salão em 200 a 212, e separar os vizinhos de matiz como no plano abaixo. **Feito em 2026-11-20**
  (aprovado pelo Game Director): `benchmark_hades2_style.md` seção 7, `art_direction.md` seção 3, nota na
  `room_redesign_matrix.md`, emenda da `hub_spec_art.md` 4.2.

### P2

- **P2-A4, environment-artist**: derrame do portal no chão do Salão sem verde fora dos degraus (caixa `1440,320,140,60`
  na Longe com verde até 1%).
- **P2-A5, environment-artist**: Compatibility do Salão com laterais e perto entre 0,35 e 0,65 do meio e a poça sob o herói
  no matiz 35 a 45.
- **P2-A6, environment-artist**: na vitrine, os topos da balaustrada sul e do patamar (`STY_NEAR_STONE`) um degrau mais
  escuros, faixa de perto da vitrine até 0,70.
- **P2-A7, environment-artist**: anel de fora do hub (paredes, arcadas, muretas do sul) um degrau mais escuro, bordas do
  HB6 até 0,70 do meio em chegada e meio, praça com luma p50 de 60 a 75 (hoje 60 a 70: manter).
- **P2-A8, technical-artist**: conferir o quadro 1 das tiras do hub (herói na fonte).
- **P2-A9, environment-artist**: água da fonte do hub com menos veio branco (caixa da água com luma p90 até 150 e sem
  linhas contínuas de mais de 60 px).

## Respostas às três perguntas

### (1) O tratamento do Salão pode ser replicado?

**Sim, como método, não como cor.** Passa no critério do Daniel nas três vistas e com perigo armado. Antes de espalhar:
P1-A1 (as manchas não podem virar a assinatura de toda sala) e P1-A3 (cada bioma sobe a saturação no próprio matiz). O que
se replica: (a) saturação da cena de 0,30 a 0,45 no matiz da sala, (b) juntas perto do valor da laje e chão quase sem
grão na escala de 3 m, (c) variação larga por luz, material e marcos, (d) moldura escura e saturada nas bordas, peças de
borda do `EdgeKit` só no terço de fora, abrindo em volta do herói. Ajustes por bioma, na ordem:

1. **Cripta A e B** (a sala que mais se parece com o Salão e a mais frequente). Separar do Salão: Cripta para o
   verde-petróleo fundo (matiz 190 a 198, luma da cena 45 a 55, um degrau abaixo do Salão), com a identidade nas poças
   mornas das velas (coroa da A, quente 5 a 8% da cena) e na lanterna fria da velada na B. Junto entra o item 4 do Daniel
   (efígie domina a A, nichos e urnas dominam a B). A moldura é a própria parede: escurecer o pé das paredes, não pôr peça
   nova na frente.
2. **Fendas A e B** (índigo 240 a 255). Moldura natural na fenda; o violeta só abaixo da borda; saturação até 0,40 para não
   encostar no violeta de Morvath. É o bioma mais perto da Câmara do Selo: usar a Câmara como régua de separação entre
   chão, figura e efeito.
3. **Ponte A e B** (B é referência forte: mexer só no chão e na saturação; a arquitetura fica). Para não colar no Salão:
   ardósia mais clara e mais cinza (matiz 215 a 225, sat 0,30 a 0,35) e o frio na bruma, não no chão. A faixa de perto aqui
   é abismo: atingir 0,65 sem escurecer o tabuleiro das pontes.
4. **Runas A e B** (220 a 235, pedra clara fria). O chão é o perigo: o HB2 só na pedra em volta da grade; a grade em
   repouso fica discreta e o âmbar continua só na laje acesa. Saturação na faixa de baixo (0,30).
5. **Jardim A e B** (referência forte pela silhueta da árvore). Subir a saturação só na ferrugem e na bruma; o oliva fica
   abaixo de 100 de matiz e o verde até 2% da cena (o verde é da Emeth). Moldura pelas raízes e pela cortina de hera.
6. **Santuário A e B** (o único morno das lutas, 30 a 45). Cuidado com o âmbar: subir a saturação da pedra puxa para o
   amarelo do perigo e das recompensas; a cor entra no petróleo dos estandartes e no frio das sombras, a pedra fica em sat
   até 0,25 e a cena atinge 0,30 pelo contraste morno e frio.
7. **Provação e Altar** (câmaras de evento; a Provação já está em 0,35). Só HB2 e moldura.
8. **Câmara do Selo**: não mexer (é a referência, sat 0,50); só medir de novo depois dos outros.

Um lote por vez, cada um com antes e depois na mesma semente e enquadramento, Perto e Longe, e com perigo armado na
captura (a galeria deste ciclo não tem nenhum aviso: pedir sempre uma vista com `--stress`).

### (2) Hub: ENV-HB6 completo contra a spec 4.2

**Recomendação: não adotar o HB6 completo (bordas a 0,35 do meio); emendar a spec 4.2 para "clareira morna", e o BH-07
fica como está.** Razões: o pedido do Daniel no item 2 é foco localizado nas estações com a praça e os caminhos visíveis,
não noite; bordas a 0,35 fazem do hub uma segunda Câmara do Selo e tiram o "abrigo"; e o que separa o hub das salas
agora é o matiz (morno 40 contra 205 a 255), não o brilho. Emenda proposta para a `hub_spec_art.md` 4.2 (dono do texto:
art-director, depois do Game Director decidir):

- cena luma p50 de 50 a 65 (hoje 52 a 56) e sat p50 de 0,25 a 0,35 (hoje 0,27 a 0,28);
- praça (caixa entre fonte e medalhão) luma p50 de 60 a 75, "o chão mais morno e limpo do jogo" no lugar de "o mais claro";
- cada estação com a laje de uso pelo menos 1,8 vez a praça (BH-07, já atingido);
- bordas do HB6 até 0,70 do meio (hoje 0,67 a 0,90: pedido P2-A7);
- o resto da 4.2 (quente 6 a 14%, verde só no portal, violeta e vermelho) igual.

### (3) Faixa de perto 0,66 (Perto) e 0,75 (vitrine)

**Perto 0,66: aceitável.** Na câmera Perto a caixa `520,780,880,150` é inteira chão de luta (a margem de 18% do herói cai
ali); escurecer mais esconderia avisos e o próprio herói quando ele desce na tela. Emenda da regra: a faixa de perto vale
até 0,65 quando é moldura e até 0,70 quando mais da metade da caixa é chão andável. **Vitrine 0,75: aceitável para este
teste** (não é a câmera do jogo e a caixa pega o patamar onde o herói entra), com o P2-A6 para descer os topos da
balaustrada sul até 0,70.

## Veredito

- **Salão: aprovado para o teste do Daniel.** O olho encontra o Guerreiro e o perigo primeiro e a sala continua o Salão.
  Replicar só depois de P1-A1 e P1-A3, na ordem acima.
- **Santuário: BH-07 aprovado** nas quatro estações; **o quadro de chegada não cumpre o pedido do portal** (P1-A2), que
  deve entrar antes de mostrar o trecho de chegada ao Daniel. HB6 completo: recomendo não adotar (emenda acima).
- A aprovação artística final é do Daniel.

## 3. Interface: P1-4 (losangos das ações no canto de baixo à esquerda), pendente

Sem capturas `ui3_*` ainda (2026-11-20). Olhei o lote 1 e o 2 (`ui_after_*`, `ui2_*`) para fixar o critério:

- Hoje os cinco losangos ficam no meio de baixo (x cerca de 750 a 1220 a 1080), sobre o chão da luta: em
  `ui_after_bridge_hud_1080.png` o aro do círculo de luz passa por dentro deles e, na câmera Perto, a faixa de baixo é
  campo de luta (seção 7.3 do benchmark). A ideia do P1-4 está certa: junta todo o HUD do herói num canto, como o Hades II,
  e libera o meio de baixo.
- Cartas dos anjos (`ui2_cards_angel_1080.png`) e Forja (`ui_after_forge_1080.png`) já cumprem o pedido do Daniel: selo do
  anjo com presença à esquerda, as três cartas comparáveis em nome, família, ação, efeito e valor; a Emeth é a peça
  principal da Forja, com custo e saldo junto do Forjar. Nada a pedir antes do P1-4.

Critério de aprovação do P1-4, para quando as `ui3_*` chegarem (720 e 1080, luta na Perto e na Longe, com a ultimate
trancada e pronta, com o selo da maldição e com a Provação):

1. Os losangos numa fileira à direita das barras de vida e Magia, sem cobrir as barras, o rastro da vida nem o
   contador de golpes; nada do HUD do herói passa de 40% da largura da tela a partir da esquerda.
2. Tecla real de cada losango legível (14 px ou mais a 720) e a legenda da ultimate ("Maestria 2", "Pronta") sem cortar.
3. Nenhum losango cobre a margem de 18% do herói na Perto: com o herói descendo até o limite de baixo, nada do HUD sobre ele
   (captura `--hero-at` perto da borda sul).
4. O losango continua o mesmo componente (`ActionSlot`: recarga no aro, nível na gema, véu translúcido com alguém atrás); a
   faixa de baixo do meio fica livre (caixa `520,960,880,120` sem HUD a 1080).
5. As divisas de fora da tela e o selo da Provação e da maldição não colidem com a fileira nova.
