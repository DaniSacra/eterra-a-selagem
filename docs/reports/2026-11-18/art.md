# Relatório de arte, fim do ciclo (2026-11-18)

Autor: art-director. HEAD `dd1f5ba` (`arpg-3d`). Capturas reais na RTX 5060, Vulkan Forward+, 1920 x 1080, pelo
`tools/gpu.sh shot` (cópia padrão), salvas em `docs/reports/2026-11-18/art/`. Nada aqui é imagem gerada por IA. O
renderizador do navegador (Compatibility) ficou fora desta rodada.

## Resumo em 5 linhas

1. O jogo já tem uma linguagem visual própria e coerente (pedra ardósia, ouro velho, Emeth esmeralda, leão), e Cripta,
   Ponte e Câmara do Selo estão perto do nível das pranchas; as cartas, a pausa e o Livro de Ahk seguem as pranchas 01, 05 e 06.
2. O que mais derruba a imagem é o placeholder que aparece em toda sala: recompensas, itens da loja, altar e Provação são
   cubos, prismas, esferas e moedas chapados sem luz (`Rooms.gem_mesh`) (P0).
3. A diferença para o Ember & Blade é de valor e de cor: o cenário deles é um tom frio só, claro (luma média 67 a 75) e com
   picos de saturação baixos. O nosso é mais escuro (37 a 61) e põe três cores saturadas no cenário ao mesmo tempo
   (abismo violeta, portal verde, velas laranja). O 90º percentil de saturação chega a 35 a 51, contra 24 a 25 deles.
4. Do pacote do PO faltam a etapa 3 (prancha 09, motivos pintados dos nós), a parte do título da etapa 4 (prancha 08: a
   maga aprovada com o Cometa, alinhamento do elenco) e as ilustrações do Livro (cena de Ahk e esboços do Compêndio).
5. Corrida nova: corredor aprovado; feiticeiro aprovado com ressalva (cajado rígido e longe do corpo); besteiro sem
   evidência nova de perto. Veredito: pode ir para o teste do Daniel como versão do ciclo, com o P0 das recompensas
   avisado como provisório.

## O que foi avaliado

| Captura | Comando (depois de `tools/gpu.sh shot <saída>`, `RES=1920x1080`) | O que mostra |
|---|---|---|
| `art/vitrine.jpg` | `--showcase --seed=5 --shot-at=2` | salão no enquadramento da referência |
| `art/jogo.jpg` | `--bot --autopick --seed=5 --shot-at=9` | salão em luta, HUD |
| `art/crypt.jpg`, `rift.jpg`, `garden.jpg`, `sanctuary.jpg`, `bridge.jpg`, `runes.jpg` | `--arena=<id> --bot --autopick --seed=5 --shot-at=7` (runas 8) | as seis arenas de luta |
| `art/trial.jpg`, `altar.jpg`, `shop.jpg` | `--start=trial|altar|shop --shot-at=3` | câmaras de evento e loja |
| `art/boss1.jpg` | `--start=boss --bot --autopick --seed=5 --shot-at=7` | Câmara do Selo, fase 1 |
| `art/ritual.jpg` | `--start=boss --bot --seed=5 --boss-hp=0.68 --shot-on=boss:ritual --shot-after=2.5 --shot-at=0.5` | fase 2, ritual com escudo e erupção |
| `art/boss3.jpg` | `--start=boss --boss-hp=0.3 --boss-only=curse --shot-on=boss:cursed --shot-after=0.5` | fase 3, maldição com erupções |
| `art/storm.jpg` | `--start=boss --boss-hp=0.14 --boss-only=storm --shot-on=boss:storm_fire --shot-after=0.4 --shot-at=1` | fase 4, tempestade |
| `art/victory.jpg` | `--start=boss --bot --seed=5 --boss-hp=0.02 --shot-on=boss:victory --shot-after=1.5` | queda de Morvath e selagem |
| `art/title.jpg` | `--title --shot-at=4` | tela de título |

Também lidas (capturas reais na GPU feitas hoje pelas outras frentes): cartas, altar, Provação, troca e Salmo em
`docs/gallery/artpack/stage1a/`; pausa, vitória, derrota, Configurações e Como Jogar em `docs/gallery/artpack/stage1b/after/`;
Livro de Ahk e Compêndio em `docs/gallery/artpack/stage2/after/`; corrida do corredor e trote do feiticeiro em
`docs/gallery/t5b/runner/` e `docs/gallery/t5b/boss/`. Comparação com as pranchas 01 a 10 do PO
(`docs/art/ref/direcao_2026-11-17/pranchas/`, só locais) e com duas capturas do Ember & Blade da pasta do Daniel (fora do
repositório, só para medir sensação).

### Medida de valor e saturação (ffmpeg `signalstats`, imagem reduzida a 640 px)

| Imagem | Luma média | Saturação média | Saturação alta (p90) |
|---|---|---|---|
| Ember & Blade, captura 1 | 67 | 16 | 24 |
| Ember & Blade, captura 2 | 75 | 16 | 25 |
| Salão em luta (`jogo`) | 56 | 17 | 40 |
| Salão vitrine | 56 | 16 | 35 |
| Cripta | 37 | 5 | 9 |
| Fendas | 46 | 20 | 30 |
| Jardim | 51 | 10 | 18 |
| Santuário | 62 | 6 | 13 |
| Ponte | 45 | 13 | 25 |
| Runas (lajes armadas) | 46 | 10 | 15 |
| Câmara, fase 1 | 50 | 21 | 50 |
| Câmara, fase 4 | 61 | 24 | 51 |

A saturação média é parecida. O que nos separa são os picos (as manchas saturadas grandes do cenário) e o valor médio
mais baixo, que no Ember & Blade vem das clareiras claras pintadas no chão.

## Pacote do PO: o que está feito e o que falta

| Prancha | Estado no HEAD | O que falta |
|---|---|---|
| 01 cartas | feito (1A): três cartas comparáveis, moldura por raridade, foco marfim, troca "Sai/Entra" | metade de baixo da carta fica vazia com texto curto (P2-1) |
| 02 atlas | feito em parte: Brasas, Toque da Geada, Maré de Luz, Escudo, romã, velas, passagem e selo entraram | o medalhão de Salmo do atlas não entrou (cruz no livro; certo não usar). Faltam medalhões pintados das outras 19 Bênçãos e dos 6 Elos, que ainda usam o glifo desenhado |
| 03 eventos | feito (1A e T5) | nada de interface; a sala em volta é o problema (P1-8) |
| 04 Livro de Ahk | feito em parte (etapa 2): abertura, página do Guerreiro com retrato, Compêndio como índice | a cena de Ahk e do anotador, e o desenho do inimigo na página de detalhe do Compêndio (hoje uma tabela de texto) |
| 05 árvore | feito (etapa 2): cruz de ramos, pontes, sustento, painel com efeito, custo, pré-requisito, próximo passo | moldura de livro com couro e cantos (hoje página lisa com borda fina) |
| 06 menus | feito (1B) | pausa mostra as Bênçãos duas vezes e a saudação "Bênção nova" por cima (P2-4) |
| 07 salas | feito em parte (etapa 4): raízes e lábios no chão, meias-luas violeta, selo que se aquieta | Jardim sem copa nem flores; Fendas sem o abismo largo da prancha (decisão: variedade antes de fidelidade); recompensa da porta segue placeholder (P0-1) |
| 08 título | **não feito** | a maga aprovada (capa marfim sobre índigo, cabelo preto curto, Cometa com brasa âmbar nas duas pontas) e o alinhamento do elenco; hoje a maga é a antiga, de roxo com magia violeta |
| 09 nós da árvore | **não feito** (etapa 3) | os glifos dos Dons são vetores simples; a prancha pede motivos pintados por nó, cruzados com o efeito real |
| 10 telas de apoio | feito em parte (1B): Configurações em abas, Como Jogar, derrota | escolha de capítulo não se aplica (uma região só); as ilustrações do Como Jogar da prancha não entraram |

## Achados

### P0

- **P0-1 Recompensas, loja, altar e Provação são primitivos chapados.** O que paira sobre cada porta e cada item da loja
  é `PrismMesh`, `SphereMesh`, `CylinderMesh` ou `BoxMesh` sem sombreamento (`Rooms.gem_mesh`,
  `SHADING_MODE_UNSHADED`), em amarelo, vermelho, verde e azul puros. Aparece em toda sala vencida e é a peça mais
  "protótipo" da tela. Na Provação há um cubo violeta flutuando ao lado da placa. Capturas: `art/shop.jpg` (quatro cubos
  coloridos em fila), `art/altar.jpg` (prisma amarelo, moeda), `art/trial.jpg` (cubo violeta). A prancha 07 (porta
  "Recompensa") mostra o símbolo como relevo de ouro velho no arco, sem objeto solto. Placeholder, não arte final.

### P1

- **P1-1 Título (prancha 08) não feito, e a arte do título tem cruzes.** `art/title.jpg`: a maga é a antiga, de roxo com
  magia violeta, não a "Maga de Fogo com Cometa" aprovada (`referencias-aprovadas/maga-de-fogo-e-cometa.png`). O clérigo
  segura uma cruz de ouro e tem cruzes no peito, e o estandarte da fortaleza traz uma cruz. No jogo as cruzes foram
  trocadas por leão e espada (D-16, D-17), e o símbolo do herói é o leão. A prancha 08 também tem as cruzes. **Pergunta ao
  Daniel, pelo Game Director:** a cruz pode ficar no clérigo e nos estandartes da arte do título, ou vira o leão?
- **P1-2 Paleta do cenário: três cores saturadas competindo com os efeitos.** No salão (`art/jogo.jpg`, `art/vitrine.jpg`)
  disputam a tela o abismo violeta à esquerda, o portal verde em cima à direita e mais de dez grupos de velas laranja. Na
  câmara (`art/boss1.jpg`, `art/storm.jpg`) as nuvens violeta dos lados vão a saturação cheia, p90 50 a 51. No Ember & Blade
  só os efeitos saturam: o cenário fica num tom frio só (p90 24 a 25), mais claro (luma 67 a 75), com clareiras pálidas no
  chão. Nossa Cripta tem luma média 37, escura demais para o olho descansar.
- **P1-3 Lajes das runas em âmbar cheio.** `art/runes.jpg`: as lajes armadas saem em âmbar sólido e saturado, com sulcos
  claros (um terço do chão), e os pilares têm listras laranja acesas. Lê como chão de discoteca e briga com a mira vermelha
  do besteiro que passa por cima. A regra dos avisos (preenchimento fraco até os últimos 30%) não aparece nas lajes.
- **P1-4 Verde demais perto do herói nas fases 2 a 4.** Em `art/storm.jpg` e `art/victory.jpg` as partículas espectrais
  de Morvath e dos invocados são bolhas ciano-verdes grandes e acesas em volta do herói e na mão de Morvath. Em
  `art/ritual.jpg` o domo do escudo é ciano saturado, do mesmo matiz do anel petróleo do herói. A Emeth (esmeralda),
  o anel do herói (petróleo) e a necromancia (verde espectral) ficam numa família só e o herói se perde nelas.
- **P1-5 Capitéis das colunas lidos como forquilha.** Santuário (`art/sanctuary.jpg`) e Cripta (`art/crypt.jpg`): as
  colunas terminam num "Y" de duas pontas que lê como chifre ou pássaro, igual em todas, alinhadas em grade como peças de
  xadrez. A prancha 07 tem colunas com capitel e ábaco, ou quebradas de forma irregular.
- **P1-6 Mira do besteiro como barra vermelha sólida.** `art/bridge.jpg`, `art/runes.jpg`: a linha da mira trava como
  uma faixa vermelha opaca de ponta a ponta, mais forte que qualquer outra coisa na tela, sem o degradê para a ponta clara
  pedido no ciclo 8.
- **P1-7 Jardim: árvore sem copa e cristais de plástico.** `art/garden.jpg`: o tronco cinza-lilás não tem copa nem flores
  (a prancha 07 tem a copa violeta, que dá o motivo da sala), e os cristais no pé do tronco são manchas verde-menta
  chapadas e acesas, não "esmeralda corrompido escuro" (`CRYSTAL_GLOW`). O musgo das raízes quase não se vê nesta câmera.
- **P1-8 Câmaras de evento como maquete no vazio.** `art/trial.jpg` e `art/altar.jpg`: as salas são caixas flutuando
  sobre fundo liso (preto-violeta e azul-petróleo), com o corte das paredes à mostra. O Ember & Blade nunca mostra o fim do
  mundo; as nossas arenas de luta resolvem isso com abismo, ruínas e bruma, as câmaras não.
- **P1-9 Livro de Ahk sem ilustração além do retrato.** `docs/gallery/artpack/stage2/after/1080_opening.png` e
  `1080_codex_4.png`: a abertura é só texto e a página de detalhe do Compêndio (Inimigos) é uma tabela. A prancha 04 tem a
  cena de Ahk e um esboço do inimigo em tinta em cada página.
- **P1-11 Erupções da fase 3 em magenta opaco.** `art/boss3.jpg`: os círculos das erupções saem como discos rosa-magenta
  quase opacos, com aro ciano. O herói de pé dentro de um fica tingido de rosa e quase some, e a área perigosa é a
  maior mancha saturada da tela. O pedido do ART-001 era miolo a 0,35 e aro a 0,18.
- **P1-10 Nós da árvore sem os motivos da prancha 09.** `1080_gifts_furia_plena.png`: os glifos são marcas vetoriais
  pequenas (barra, divisas, gota), legíveis mas genéricos. Etapa 3 do pacote não começou.

### P2

- **P2-1 Cartas com a metade de baixo vazia.** `stage1a/bless_1080_after.jpg`: com uma linha de descrição, 40% da carta é
  tinta escura sem nada.
- **P2-2 Legenda da vitória sem apoio.** `art/victory.jpg`: "A magia de Morvath se desfaz..." em versalete fino, marfim
  apagado sobre a balaustrada e as velas, sem véu atrás. Contraste baixo.
- **P2-3 Números e ouro sobrepostos.** `art/jogo.jpg` ("60" sobre "+1 ouro"), `art/rift.jpg` ("20", "20" e "+2 ouro"
  empilhados sobre o grupo).
- **P2-4 Pausa repete as Bênçãos.** `stage1b/after/1080_pause_many.jpg`: o painel da pausa e a fileira do HUD mostram as
  mesmas 20 Bênçãos ao mesmo tempo, e a saudação "Bênção nova" fica por cima da pausa.
- **P2-5 Barras de vida dos inimigos mais vivas que o herói.** `docs/gallery/t5b/runner/runners_gpu_after.jpg`: num grupo,
  as barras vermelhas e amarelas saturadas são a mancha mais forte em volta dele.
- **P2-6 Selo "Morvath foi selado" com mancha amarela chapada atrás.** `stage1b/after/1080_victory_seal.jpg`: um disco
  amarelo-oliva liso atrás do medalhão, sem degradê, lê como erro de brilho.
- **P2-7 Obelisco no primeiro plano do salão.** `art/jogo.jpg`: o obelisco do meio de baixo cobre a parte de baixo da ação
  em boa parte da luta. É da composição da referência e já abre em pontilhado atrás do herói, mas cobre inimigos.
- **P2-8 Emeth da ilustração do Livro diferente do modelo.** `stage2/after/1080_hero.png`: a lâmina do retrato é curta e
  reta, sem a guarda de chifres nem o punho vermelho da Emeth aprovada. Arte de IA da prancha 04: não dá para corrigir
  sem imagem nova.

## Inimigos: a corrida nova

- **Corredor (`Jog_Fwd`, pés travados, balanço pelo passo): aprovado.** `docs/gallery/t5b/runner/runner_walk_after.jpg`:
  os pés pousam na sombra em todos os quadros, a passada é longa e o tronco vai à frente. Lê como "rápido, vem para cima".
  Ressalva leve: em 3 dos 24 quadros (linha 1, quadros 4 a 6) o tronco torce para a câmera mais do que o resto do ciclo.
  Conferir em vídeo na câmera do jogo; se lê como tropeço, baixar o `stride_lean` nessa fase.
- **Feiticeiro (trote do `Running_B` com meio pulo): aprovado com ressalva.**
  `docs/gallery/t5b/boss/mage_trot_side_24f.jpg`: não pula mais como antes, mas o cajado fica rígido, a prumo e longe
  do corpo, e na linha 1 os dois pés saem do chão em 6 de 8 quadros. Pedido: cajado inclinado uns 15 graus para trás e
  colado ao ombro, e `"lift"` de 0,5 para 0,3.
- **Besteiro:** sem tira de perto nesta rodada (a captura de laboratório não saiu por causa da fila da GPU). Em luta
  (`art/runes.jpg`, `art/bridge.jpg`) ele lê bem, besta baixa andando e no ombro na mira. Fica pendente a tira de lado.
- **Meias-luas violeta de Morvath:** aprovadas (`art/storm.jpg`): violeta frio com miolo claro, como na prancha 07, e o
  selo se apaga por baixo.

## As 10 melhorias de maior ganho

| # | Melhoria | Dono | Critério de aprovação (captura real na GPU, 1080) |
|---|---|---|---|
| 1 | Recompensas de verdade (P0-1): trocar os primitivos pelo medalhão pintado que já existe (`assets/ui/boons`, `assets/ui/events`) num disco de ouro velho com aro, sombreado, girando devagar sobre um pedestal baixo de pedra, com halo da cor da recompensa abaixo do glow; marcador da Provação igual (selo rachado) | environment-artist (peça e material), ui-ux-designer (escolha do medalhão por recompensa) | nenhuma `BoxMesh`, `PrismMesh` ou `SphereMesh` sem luz em `shop`, `altar`, `trial` e no fim de uma luta; cada recompensa reconhecível pelo símbolo a 1280 x 720 sem ler a placa; maior canal na tela até 226 |
| 2 | Cenário num tom só (P1-2): baixar a saturação da bruma violeta do abismo e das nuvens da câmara (para p90 de saturação do quadro abaixo de 32 sem efeitos), deixar o portal como único verde do salão e apagar ou esfriar mais grupos de velas | environment-artist | `art/vitrine` e `art/boss1` refeitas com p90 de saturação até 32 (hoje 35 e 50) e nenhuma área violeta acima de 60% de saturação maior que 5% da tela; portal continua o ponto mais claro do salão |
| 3 | Clareiras claras no chão e mais valor (P1-2): manchas pálidas de pedra gasta ou pó no `catacomb_floor.gdshader` e nos chãos das arenas, e luz de preenchimento na Cripta | environment-artist | luma média do quadro de luta entre 55 e 70 em todas as arenas (Cripta hoje 37); herói e inimigos com o mesmo contraste de hoje sobre o chão (medir na caixa do herói) |
| 4 | Título da prancha 08 (P1-1), depois da resposta sobre as cruzes | Game Director pergunta ao Daniel; ui-ux-designer integra a arte que o PO aprovar | maga aprovada (capa marfim, índigo, cabelo preto curto, Cometa com as duas brasas acesas) na arte; logotipo e botões nas mesmas áreas clicáveis (`tools/title_flow_check.gd` passa); nenhuma cruz se o Daniel decidir pelo leão |
| 5 | Família de verdes separada e erupções mais leves (P1-4, P1-11): miolo das erupções translúcido (alfa até 0,35, vermelho da assinatura e não magenta), aro sem ciano; partículas espectrais menores (até 0,12 m), maior canal até 0,9, matiz puxado para o azul (175 a 185) e nunca a menos de 1,5 m do herói; domo do ritual mais translúcido e no matiz do esmeralda corrompido (165, valor 0,7), longe do petróleo do anel | environment-artist (efeitos de Morvath), com o combat-feel-director conferindo a leitura | em `art/storm`, `art/ritual` e `art/boss3` refeitas, o herói dentro de uma erupção com as cores próprias legíveis (sem tinta rosa), nenhuma bolha verde ou ciano na caixa de 300 x 300 px em volta do herói; herói achado em menos de 1 s por quem não jogou (teste rápido com o Daniel) |
| 6 | Runas no tom dos avisos (P1-3): laje armada com moldura e sulcos âmbar e preenchimento fraco (até 0,25) até os últimos 30% do preparo; pilares sem listra acesa em repouso | environment-artist (`rune_floor.gdshader`) | `art/runes` em preparo: área âmbar saturada abaixo de 12% da tela; mira vermelha legível por cima |
| 7 | Mira do besteiro em degradê (P1-6): fio fino com a ponta de longe clara e o corpo translúcido, como os outros avisos de linha | gameplay-engineer (`GroundLook`), com spec deste relatório | largura na tela até 10 px a 1080; nenhum trecho com alfa acima de 0,6 fora da ponta |
| 8 | Capitéis e ritmo das colunas (P1-5): capitel com ábaco quadrado ou quebra irregular por coluna, duas ou três alturas diferentes no Santuário | environment-artist | nenhuma coluna com o "Y" de duas pontas em `art/sanctuary` e `art/crypt`; pelo menos três silhuetas diferentes entre as colunas da nave |
| 9 | Fundo das câmaras de evento (P1-8): bruma, ruínas ao longe e o abismo do salão em volta da Provação e do Altar, sem corte de parede à mostra | environment-artist | em `art/trial` e `art/altar` nenhuma face de corte de parede visível; fundo com pelo menos duas camadas de profundidade (bruma e silhuetas) |
| 10 | Etapa 3 do pacote e ilustrações do Livro (P1-9, P1-10): motivos da prancha 09 nos 19 Dons e esboço em tinta de cada inimigo no Compêndio. O esboço pode ser o nosso próprio modelo assado desenhado em traço (sem IA) | ui-ux-designer (nós e páginas), technical-artist (render em traço dos modelos) | cada nó com motivo do próprio efeito, legível a 720; página de cada inimigo descoberto com o desenho dele; desconhecido com silhueta apagada |

Fora das dez, mas baratas: P2-2 (véu atrás da legenda da vitória, ui-ux-designer), P2-3 (ouro sobe ao lado do número,
não por cima), P2-4 (esconder a fileira de Bênçãos do HUD durante a pausa), P2-6 (degradê no halo do selo), feiticeiro
(cajado e `"lift"`, gameplay-engineer no `tools/bake.gd`).

## Depende de asset que não existe

- Arte do título com a maga aprovada (IA do PO ou do Daniel; registrar em `docs/steam-ia.md`).
- Cena de Ahk e do anotador (prancha 04): só se o Daniel aprovar o visual de Ahk. O pacote diz para tratá-los como
  silhuetas até lá.
- Medalhões pintados das outras Bênçãos e dos Elos (atlas novo do PO, ou pintura nossa).
- Copa da árvore do Jardim: dá para fazer com cartões de folhagem procedurais; um modelo do Meshy só com autorização
  (sobram 546 créditos, o Daniel pediu para segurar).
- Estátuas, moldura do portal e ruínas do salão continuam provisórias (`docs/art/meshy_asset_plan.md`).

## Veredito

Aprovado para o teste do Daniel como versão do ciclo, com ressalvas: o P0-1 (recompensas em primitivos) deve ser dito a
ele como provisório, e o título segue sem a prancha 08. Para a meta de "arte magnífica no molde do Ember & Blade", as
melhorias 1 a 3 (recompensas, um tom só no cenário, chão mais claro) são as que mais mudam a primeira impressão e não
dependem de créditos nem de IA. A aprovação artística final é do Daniel.
