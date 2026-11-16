# Revisão de arte: C12 "Arenas I" (Cripta, Fendas, Jardim)

Autor: `art-director`, 2026-11-16. Material avaliado: capturas reais na placa de vídeo (RTX 5060, Forward+, 1920 x 1080)
desta pasta (`crypt/`, `rift/`, `garden/`, `work/`), o `CAPTURAS.md`, o `METRICAS.md`, o relatório de QA
(`docs/qa/latest_report.md`), a especificação (`docs/art/cycle12_arenas_spec.md`) e as referências feitas por IA, só
locais (`docs/art/ref/cycle12_maps/02_*.png`, `04_*.png`, `05_*.png`). Nenhuma imagem gerada por IA foi usada como
evidência do jogo. Uma captura nova minha, do laboratório, fora do repositório: Fendas A com o alvo da vitrine (-2; 0)
(`tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- <saída> --arena=rift
--variant=0 --bare --cam-at=-2,0`, commit `fd72101`). Medidas de cor minhas: mediana de recortes das capturas (ffmpeg),
luminância 0 a 255.

**A aprovação artística final é do Daniel.** Esta revisão diz o que as evidências mostram e o que falta. Tudo nas três
arenas é procedural (cantaria, sarcófagos, árvore) e portanto **provisório** no sentido de arte final (ART-010).

## Medidas

| Recorte | Luminância (mediana) | R, G, B (medianas) | Alvo da spec |
|---|---|---|---|
| Cripta A, chão do meio (`vA_a_cenario`) | 47 | 49, 46, 51 | 45 a 60 |
| Cripta B, chão do meio | 45 | 47, 44, 49 | 45 a 60 |
| Cripta A, chão na luta (`vA_c_combate`, junto da coluna 3) | 40 | 44, 38, 45 | 45 a 60 |
| Cripta A, tampa do túmulo sob o facho | 202 (máx. 255) | 194, 201, 237 | (sem alvo; ver C-1) |
| Fendas A, chão do meio (`vA_a_cenario`) | 50 | 40, 48, 96 | 45 a 60 |
| Fendas A, chão longe da luz na luta (`vA_c`, dois recortes) | 25 e 29 | 16 a 20, 23 a 27, 71 a 78 | 45 a 60 |
| Fendas A, o mesmo no Compatibility (`vA_h`) | 22 e 12 | 1 a 6, 10 a 20, 64 a 82 | perto do Forward+ |
| Fendas A, dentro do buraco sul (`vA_a_cenario`) | 64 | 56, 61, 110 | escuro e violeta (ver F-1) |
| Jardim A, chão do meio (`vA_a_cenario`) | 64 | 62, 63, 77 | 45 a 60 |
| Jardim A, chão na luta (`vA_c`) | 51 | 55, 49, 60 | 45 a 60 |
| Jardim A, cristal da base | 206 (máx. 255) | 122, 230, 210 | maior canal da emissão até 0,8, esmeralda corrompido escuro |
| Jardim A, tronco / chão ao lado | 51 / 88 | 48, 50, 65 / 89, 87, 103 | tronco 10 a 20% acima do chão |

Desempenho, luzes e colisão: ver o `METRICAS.md` (3,3 a 4,7 ms a 1080p; 0 corpos dentro de peça; 0 esquivas sobre buraco).

## 1. Cripta dos Esquecidos (referência: faixa de baixo da `05`)

| Aspecto | Bate | Difere |
|---|---|---|
| Composição | sala fechada inteira no quadro com o alvo fixo; túmulo no meio sob o facho frio, é o centro do quadro; nichos e estandartes no fundo, desmoronamento a nordeste | a `05` é mais densa (muretas quebradas, colunas e velas por toda parte); aqui são menos peças, de propósito (spec 2) |
| Geometria e dimensões | 24 x 21 m com o canto nordeste cortado; três faixas leste-oeste; baias com muros baixos; na B a divisória com o ossário e o facho na ponta sul (`vA_a_planta_lab`, `vB_a_planta_lab`) | as colunas leem como pilha de blocos: o capitel e o arranque do arco viram cubos tortos no alto (`vA_a_cenario`) |
| Materiais | lajes pequenas e frias, cantaria um passo mais escura, nichos escuros | a tampa do túmulo sob o facho sai quase branca (luminância 202, máximo 255); as escadas da entrada e da X2 são bem mais claras que tudo em volta e leem como tábuas empilhadas; as lápides não se distinguem a 1080 |
| Luz e atmosfera | velas em poças, dois braseiros na X1, um único azul (o facho); sem céu, sem violeta; o quente não chapa o chão | o facho é forte demais sobre a tampa (C-1) |
| Leitura | herói, anel, inimigos e o orbe do feiticeiro leem sobre o chão (`vA_c`); paredes da frente cortadas baixas não cobrem nada; saídas com luz quente | chão na luta um pouco abaixo do alvo (40) longe das velas |
| Identidade | estandartes com o leão, estátuas encapuzadas de mãos vazias, sem porta verde, fogo âmbar, nenhum vermelho no chão | |

**Veredito da Cripta: aprovada para o teste do Daniel**, com as correções C-1 a C-4 (nenhuma alta).

## 2. Salão das Fendas (referência: `02`; pontes da `01` e `03`)

| Aspecto | Bate | Difere |
|---|---|---|
| Composição | fachada com a porta X1, braseiros e estandarte do leão no alto à direita; plataforma leste maior com todas as saídas; abismo violeta em volta e ruínas ao fundo | **o marco não lê**: na `02` a fenda é um rasgo contínuo de borda quebrada atravessando o salão na diagonal; aqui leem dois poços retangulares e um octógono (o buraco leste), com as pontes como faixas do próprio chão entre eles (`vA_f_referencia`, `vA_c_combate`, minha captura com alvo (-2; 0)) |
| Geometria e dimensões | o dado bate com a spec 3.1 (contorno, fenda em três polígonos com as pontes como o chão entre eles, buraco leste, pontes de 5 m, passagem sul; `make_data.gd` `RIFT_NORTH`, `RIFT_MIDDLE`, `RIFT_SOUTH`) | a forma andável está certa; o que falha é o desenho: cada trecho de abismo entre pontes tem 6 m, e a 30° de inclinação se vê só a parede de fora da ponte seguinte, iluminada, e um "fundo" (arco e pegões), o que faz poço e não fenda. A boca norte (z -15 a -12) fica fechada pelo parapeito da ponte e lê como uma sacada |
| Materiais | lajes grandes azuladas, cantaria fria, filete de ouro na borda viva, balaustrada quebrada na borda oeste | as pontes têm as mesmas lajes do chão e parapeito maciço: não leem como pontes; os dentes da borda quebrada (spec 1.3) quase não aparecem, a borda é reta com cantos vivos; o paredão sob a borda oeste e sul é cantaria azul iluminada (lê como muralha de fortaleza), e pesa no quarto de baixo à esquerda na luta |
| Luz e atmosfera | ar azul-violeta, braseiros da fachada, lanternas das cabeceiras | o violeta "de baixo" quase não aparece nos buracos da A (só na ponte caída da B, `vB_f`, onde a bruma funciona); o interior dos buracos é **mais claro** que o chão (64 contra 50): as luzes da beira (`LIP_*`) acendem as paredes de dentro. Longe das lanternas o chão fica em 25 a 29 na luta, abaixo do alvo |
| Leitura | herói, inimigos e avisos leem; a borda de cada buraco está fechada (filete ou balaustrada, sem falha que pareça passagem); a balaustrada abre em pontilhado junto do herói (`vA_g_heroi_na_borda_da_fenda`) | |
| Compatibility | sem erro, sala inteira | o vermelho some do chão (R 1 a 6 contra 16 a 20), o azul satura; a sala parece outra (`vA_h`) |
| Identidade | leão nos estandartes, fogo âmbar, sem verde no cenário, sem círculo no chão | as inscrições de ouro entre a fenda e o buraco não aparecem |

**Veredito das Fendas: não aprovado como está.** Joga bem (QA), mas o marco da sala, a fenda da `02`, não aparece: é a
diferença principal do C12 contra as referências. F-1 a F-3 antes do teste do Daniel.

## 3. Jardim das Raízes Mortas (referência: `04`)

| Aspecto | Bate | Difere |
|---|---|---|
| Composição | árvore no alto à esquerda, copa aberta para cima e para os lados sobre a parede do fundo, raízes saindo pelo chão, janelas góticas com o violeta atrás, porta X1 com braseiros à direita, balaustrada da frente sobre o abismo | a `04` é muito mais cheia (sarcófagos, velas, capim, arcos de ouro no chão, lajes erguidas); aqui o chão da luta fica quase vazio. A árvore da `04` é maior em relação à sala e de raízes muito mais numerosas |
| Geometria e dimensões | tronco de 3,5 m em (-8; -5), quatro raízes que bloqueiam, sarcófagos e colunas onde a spec diz; corredor mais estreito 3,6 m | |
| Árvore (forma) | silhueta de árvore morta: tronco largo, três pernadas que se dividem até pontas finas, raízes agarrando o chão, galhos contra a parede escura | **lisa e "esculpida"**: os lóbulos do tronco são sulcos verticais regulares (lê como pano drapeado ou cera derretida), a torção de 40° não se vê, sem grão, sem fraturas nem lascas legíveis; as raízes são tubos compridos e lisos que afinam até uma ponta (leem como tentáculos), sem os dois lombos nem as raízes finas da spec 4.4 |
| Árvore (material e luz) | pedra cinza fria, não madeira (D-30) | tronco mais escuro que o chão ao lado (51 contra 88; a spec pede 10 a 20% acima); cordas e sulcos com o mesmo valor; líquen não aparece |
| Cristais | três grupos na base, dentro da colisão | quase brancos, menta-ciano (G 230, máximo 255): longe do esmeralda corrompido escuro (spec 4.6) e perto demais do verde da Emeth; são o ponto mais claro da sala depois do fogo |
| Leitura | herói visível em todas as células da grade de 2 m atrás e em volta do tronco e da copa (`work/garden_grid_a`; células pretas = dentro do tronco ou fora do chão); o tronco abre em pontilhado (`vA_d_atras_do_tronco`); sombra dos galhos não vira faixa preta | atrás do tronco o herói aparece pelo furo do pontilhado com as cores cheias, e lê um pouco como "na frente"; aceitável |
| Compatibility | sem erro | manchas laranja chapadas perto dos braseiros e azul saturado no chão (`work/garden_compat_a`) |
| Identidade | leão nos estandartes, estátuas de mãos vazias, fogo âmbar, inscrição em arcos interrompidos (no código) | a inscrição quase não se vê (contraste até 15% por spec; aceitável) |

### Veredito da árvore pelo critério D-30 (spec 4.4)

| Critério | Estado | Evidência |
|---|---|---|
| Lida como árvore a 1080 na câmera do jogo, sem explicação | SIM | `vA_a_cenario`, `vA_c_combate`: tronco, pernadas, raízes e galhos finos dão a silhueta de árvore morta |
| Galhos finos visíveis contra o fundo | SIM, em parte | as pontas finas leem contra a parede; as pernadas B e C saem pelo alto do quadro, como a spec previa |
| Herói visível em 100% da grade de 2 m | SIM | `work/garden_grid_a` |
| Lado a lado com a `04`, forma geral | SIM, em parte | tronco no alto à esquerda, raízes agarrando, copa aberta: bate; a superfície (lisa, regular) e as raízes (tentáculos) não |

**A árvore fica** (o Jardim entra na entrega 1), como peça provisória, com as correções J-1 a J-3 (médias). Não é arte
final: uma árvore esculpida (Meshy, ART-010) ficaria melhor e depende do Daniel.

**Veredito do Jardim: aprovado para o teste do Daniel**, com J-1 a J-3 antes, se der tempo; nenhuma impede jogar.

## 4. As cinco salas lado a lado (spec 5 e 6.1)

Em miniatura as três arenas se distinguem do salão, da câmara e entre si: a Cripta pela caixa fechada escura com o
facho, as Fendas pelo azul e a fachada, o Jardim pela árvore. Mas as Fendas se distinguem pela cor, não pelo marco: sem
personagens, a fenda não é o que se lembra da sala (F-1 a F-3). Os pontos da vitrine (fenda de (629; 753) a (1281; 294),
pé da árvore em (833; 346)) não foram medidos na câmera da vitrine; no laboratório com alvo (-2; 0) e a câmera do jogo a
ponta sul da fenda cai perto de (830; 770), uns 200 px à direita do previsto (G-2).

## 5. Correções

| # | Sev. | Arena | Pendência | Responsável | O que mudar, onde, e critério de aceite |
|---|---|---|---|---|---|
| F-1 | alta | Fendas | Buracos com fundo claro e legível (leem como poços) | `environment-artist` | `rift_look.gd` `_abyss`: as luzes da beira (`LIP_*`) não podem acender as faces de dentro do buraco (abaixar para y 0,1 e tirar da máscara das faces do penhasco, ou trocar por cor no chão a até 1,5 m da beira); faces de dentro (`broken_edge`, `CLIFF`) escurecendo para quase preto em 1,5 m abaixo da beira e o violeta só no fundo; a névoa de altura enchendo a fenda abaixo de y -2 (spec 3.5); arcos e pegões das pontes sem luz própria e dentro da bruma. **Aceite**: em `vA_a_cenario` refeita, a mediana de um recorte dentro de cada um dos três buracos com luminância até 60% da do chão ao lado e B pelo menos 30 acima de R; nenhum fundo, pegão ou arco reconhecível mais de 3 m abaixo da beira; violeta visível nos três |
| F-2 | alta | Fendas | Pontes leem como faixas do chão | `environment-artist` | `rift_look.gd` `_bridge`: tabuleiro com lajes próprias no sentido do vão (por parâmetro do chão ou malha por cima, 0,01 m) e meio-fio de pedra mais clara de 0,3 m nas duas bordas; junta escura de 0,08 m onde o tabuleiro encontra a plataforma; parapeito vazado (`Masonry.balustrade` sem pontilhado) no lugar do bloco maciço; pilares de cabeceira de 1,4 m nos quatro cantos. **Aceite**: na miniatura de 320 px do `vA_a_cenario` lê-se "duas pontes sobre uma fenda"; a 1080, em cada cabeceira, a borda do tabuleiro se distingue do chão da plataforma |
| F-3 | alta | Fendas | Borda reta com cantos vivos; boca norte fechada como sacada | `environment-artist` | borda quebrada da spec 1.3 visível nos lábios da fenda: dentes e falhas de 0,4 a 1,2 m a cada 0,8 a 2 m, lajes da beira baixadas, sem mexer na colisão (tudo fora do chão); nos cantos onde o lábio encontra a ponte, um pegão de cantaria que mostra a ponte nascendo ali; ao norte da ponte norte a fenda continua aberta para o abismo de fora, com o violeta e o penhasco descendo à vista. **Aceite**: na captura com alvo (-2; 0), um dente ou falha legível a cada 2 m ao longo de cada lábio, e violeta visível ao norte da ponte norte. Se, depois de F-1 a F-3, a fenda ainda ler como poços, o Game Director decide com o `gameplay-engineer` se a variante A fica com uma ponte só (dado em `make_data.gd` `_rift`), para o rasgo ganhar comprimento |
| F-4 | média | Fendas | Chão escuro longe das lanternas (25 a 29 na luta) | `environment-artist` | ar e luz da sala (`rift_look.gd` `AIR`, `KEY_ENERGY`). **Aceite**: em `vA_c_combate` refeita, os recortes (150, 250, 250 x 150) e (1300, 750, 250 x 120) com luminância 40 ou mais, sem passar de 60 no meio |
| F-5 | média | Fendas | Paredão de cantaria azul iluminada sob as bordas de fora | `environment-artist` | penhasco de fora (`CLIFF`, `broken_edge` nas bordas OUTER) em pedra das profundezas escura que some na bruma em 3 m, como a câmara. **Aceite**: no `vA_c` o recorte do paredão embaixo à esquerda com luminância até 60% do chão |
| F-6 | baixa | Fendas | Inscrições de ouro entre a fenda e o buraco não aparecem | `environment-artist` | conferir que estão ligadas (`FLOOR`); contraste até 15% (spec 3.5). **Aceite**: visíveis ampliando a 200% |
| C-1 | média | Cripta | Tampa do túmulo quase branca sob o facho | `environment-artist` | `crypt_look.gd`: energia do facho ou albedo da tampa. **Aceite**: em `vA_a_cenario` a mediana da tampa com luminância até 150 e nenhum canal acima de 235; o facho continua sendo o centro do quadro |
| C-2 | baixa | Cripta | Colunas leem como pilha de blocos no alto | `environment-artist` | capitel redondo moldurado e arranque do arco como aduela curva (spec 1.3). **Aceite**: a 1080, sem cubos tortos acima do capitel |
| C-3 | baixa | Cripta | Escadas da entrada e da X2 claras demais (tábuas) | `environment-artist` | degraus no valor da cantaria das paredes. **Aceite**: mediana dos degraus até 1,2 vez a do chão do meio |
| C-4 | baixa | Cripta | Lápides não se distinguem | `environment-artist` | moldura um passo mais funda. **Aceite**: lápides contáveis nas faixas norte e sul do `vA_a_cenario` a 100% |
| J-1 | média | Jardim | Cristais quase brancos, menta-ciano, perto da Emeth | `environment-artist` | `stone_tree.gd` `CRYSTAL_GLOW` e `CRYSTAL_ALBEDO`, `garden_look.gd` `CRYSTAL_GLOW` e `CRYSTAL_LIGHT`: emissão final no esmeralda corrompido (matiz cerca de 165, escuro), sem somar com a luz própria até o branco. **Aceite**: em `vA_a_cenario` a mediana do recorte do cristal com maior canal até 160 e nenhum pixel acima de 230; no `vA_c` os cristais e a lâmina da Emeth se distinguem lado a lado |
| J-2 | média | Jardim | Casca lisa e regular (pano, cera) | `environment-artist` | `stone_tree.gd` e `stone_tree.gdshader`: lóbulos de larguras desiguais (variação de 30%), torção visível (`TWIST` até 60 a 70° se 40 não aparece), grão fino ao longo da espinha, cordas claras (0,45; 0,43; 0,48) contra sulcos escurecidos, fraturas claras nos três galhos quebrados (`BROKEN`), líquen na metade de baixo. **Aceite**: a 1080, um sulco que gira pelo menos um quarto de volta do pé à forquilha; pelo menos duas pontas quebradas com a fratura clara à vista; dentro do tronco, a diferença entre os percentis 95 e 5 de luminância de 50 ou mais; mediana do tronco entre 1,1 e 1,2 vez a do chão a até 3 m dele |
| J-3 | média | Jardim | Raízes como tentáculos | `environment-artist` | `stone_tree.gd` (`ROOT_TOP`, `ROOT_LOBES`, `ROOTLETS`, `FINE`): os dois lombos por raiz da spec 4.4, nós, e cada raiz se abrindo em duas ou três raízes finas na ponta, entrando nas juntas; lajes erguidas e partidas em volta. **Aceite**: no `vA_a_cenario` cada raiz que bloqueia mostra dois lombos no perfil e termina em pelo menos duas raízes finas; a colisão não muda (teste de cobertura passa) |
| J-4 | baixa | Jardim | Chão da luta vazio contra a `04` | `environment-artist` | velas nos sarcófagos e capim junto das raízes e paredes já previstos (spec 1.3 e 4.6): conferir que aparecem. **Aceite**: capim visível junto das raízes no `vA_a_cenario` |
| G-1 | média | todas | Compatibility: vermelho some, azul e laranja saturam | `environment-artist` | compensação do Compatibility por sala (`Game.COMPAT_*` ou o ar de cada arena). **Aceite**: nos mesmos recortes do `vA_c` em Forward+ e Compatibility, cada canal com diferença de até 15; a fenda continua violeta e a cripta não vira breu (spec 6.4). Prioridade abaixo das outras médias (o desktop é o que precisa ficar ótimo) |
| G-2 | baixa | Fendas e Jardim | Marcos da vitrine não medidos | `qa-performance` | capturar com `--showcase` (ou o lab com a câmera da vitrine) e medir a fenda e o pé da árvore contra os pontos da spec 6.1 (tolerância 40 px); se a câmera do lab for outra, registrar qual |
| G-3 | baixa | todas | Peças procedurais provisórias (sarcófagos, estátuas, árvore) | Daniel (Meshy) | ficam no ART-010 e no `docs/art/meshy_asset_plan.md`; nada gerado sem autorização |

## 6. Veredito

- **Cripta: aprovada** para o teste do Daniel (C-1 é a única média).
- **Jardim: aprovado**, e **a árvore fica** pelo D-30, como peça provisória; J-1 a J-3 melhoram muito a peça e são de
  arte só (sem mexer em colisão).
- **Fendas: não aprovado** como está. A sala joga bem, mas não mostra a fenda da referência; F-1 a F-3 são de cenário
  e luz, sem mexer na forma andável. Recomendo segurar a versão de teste até elas, porque a imagem que o Daniel mandou é o
  que vale para essa sala.
- Não declaro fidelidade alta às referências em nenhuma das três: as imagens são muito mais densas e trabalhadas, e as
  peças são procedurais.

## Adendo de 2026-11-16: reconferência das Fendas (ART-R1, commit `87ba686`)

Autor: `art-director`. Material: `rift/vA_a_cenario.jpg` e `rift/vA_c_combate.jpg` refeitas (idênticas byte a byte a
`work/fix_rift_vA_depois_cenario.jpg` e `work/fix_rift_vA_depois_combate.jpg`), `work/fix_rift_vA_antes_*`,
`work/fix_rift_vA_depois_alvo_-2_0.jpg`, `work/fix_rift_vA_miniatura_320.jpg`, `work/fix_rift_vA_depois_compat.jpg`,
`work/fix_rift_vA_compat_vs_forward.jpg`, `work/fix_rift_vB_antes_depois_cenario.jpg`. Todas reais, Forward+ na RTX 5060,
1920 x 1080 (a de Compatibility no renderizador do navegador). Medidas: mediana de recortes (x, y, largura x altura em
pixels da imagem de 1080), luminância 0 a 255, pelo mesmo método da revisão. Nenhuma captura nova feita por mim. Lembrete
da D-36: nesta entrega o Daniel pede salas diferentes e legíveis, não fidelidade às imagens conceituais; a `02` serve de
norte, não de gabarito.

| # | Resultado | Medida e o que se vê |
|---|---|---|
| F-1 | **passou** (com uma ressalva) | Dentro de cada buraco contra o chão ao lado, `vA_a_cenario`: sul (660, 640, 130 x 50) 14 contra 56 (25%), B 75 e R 21; meio entre as pontes (900, 435, 120 x 30) 24 contra 58 (41%), B 69 e R 33; leste (1460, 570, 130 x 55) 6 contra 47 (13%). As paredes de dentro iluminadas, o arco e os pegões no fundo sumiram (antes, recorte do buraco sul inteiro com percentil 95 de 69 sobre as paredes de cantaria acesas; agora só bruma violeta e pedras caídas na beira). Violeta visível nos três. Ressalva: no buraco leste o recorte inteiro dá B só 19 acima de R (a sombra das pedras caídas domina); a mancha violeta dele (1500, 612, 80 x 25) dá B 81 e R 22. Aceito: o violeta lê |
| F-2 | **passou** | Na miniatura de 320 px lê-se "duas pontes sobre um vão violeta": parapeito vazado dos dois lados, o violeta passando por baixo. A 1080, nas cabeceiras, o tabuleiro tem lajes maiores no sentido do vão, meio-fio claro e pilar de canto com lanterna ou velas; a borda do tabuleiro se distingue da plataforma (degrau e mudança do desenho das lajes junto das lanternas da cabeceira sul e norte) |
| F-3 | **passou** | Com o alvo (-2; 0): no lábio de baixo do trecho sul, cerca de 6 m à vista, quatro a cinco dentes, lajes baixadas e pedras caídas (um a cada 1,2 a 1,5 m). Os lábios de trás ficam escondidos pelas pontes e pela balaustrada e não se medem nesta câmera. Ao norte da ponte norte a boca está aberta: parapeito vazado com o abismo violeta atrás, sem a parede de sacada. A fenda lê como um canal só atravessado por duas pontes, não mais como dois poços; a alternativa de uma ponte só não é necessária |
| F-4 | **passou por pouco não** | `vA_c_combate`: recorte (150, 250, 250 x 150) 38 (era 25; alvo 40), recorte (1300, 750, 250 x 120) 46 (era 29), meio 59 (teto 60). Falta 2 pontos num dos dois; sem efeito na leitura do combate (herói, anel, inimigos e barras leem). Fica como baixa |
| F-5 | **passou** | Paredão embaixo à esquerda (80, 680, 250 x 180) 3 contra o chão perto (250, 430, 180 x 90) 43 (7%; teto 60%). A cantaria azul iluminada virou pedra escura que some no violeta |
| F-6 | **passou** | A 200% (recorte 1050, 470, 500 x 250 da `vA_a_cenario`) os traços de ouro fraco aparecem nas lajes entre a fenda e o buraco leste; continuam discretos, como a spec pede |
| G-1 (Fendas) | **passou nos canais, com ressalva** | Mesmos recortes, Compatibility contra Forward+: (150, 250) R +11, G +11, B +14; (1300, 750) R -5, G -8, B -11; meio R +11, G +2, B +3 (todos até 15; antes o vermelho caía a 1 a 6). Ressalva: no Compatibility os vãos da fenda e o buraco leste ficam quase pretos (vão sul B 14 contra 33 no Forward+), o violeta de baixo quase não se vê. O desktop é o que conta; fica como baixa |

Fendas B (`work/fix_rift_vB_antes_depois_cenario.jpg`): a ponte de cima caída com o violeta de baixo e a ponte de baixo
com o vão escuro leem como a mesma fenda; nada a pedir.

**Veredito das Fendas: aprovada para o teste do Daniel.** A sala agora se lembra pela fenda com pontes, não só pelo azul:
é diferente da Cripta e do Jardim e legível em luta, que é o que a D-36 pede. Não declaro fidelidade à `02`: lá o rasgo
é contínuo, diagonal e de borda muito mais quebrada; aqui é um canal de três trechos com pontes, e o buraco leste
continua octogonal.

Sobra, baixa (`environment-artist`, depois do teste, nada impede jogar):
- F-4b: o canto noroeste do chão na luta em 38; subir 2 pontos (ar ou `KEY_ENERGY`) sem passar de 60 no meio.
- F-7: o filete de ouro segue um polígono reto por cima dos lábios quebrados (no buraco leste desenha o octógono): fazer o
  filete acompanhar os dentes ou parar onde a borda quebra.
- F-8: o buraco leste ainda lê como poço octogonal; quebrar dois ou três lados do contorno visual (sem mexer na colisão).
- G-1c: no Compatibility, um pouco do violeta de baixo na fenda (compensação da bruma `rift_haze` só nesse renderizador).
