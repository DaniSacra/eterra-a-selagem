# Ciclo 12: arenas variadas, avaliação e plano do game-director

- **Data**: 2026-11-16 (tarde). **Commit lido**: `61f591e` (HEAD de `arpg-3d`). **Pedido**: `docs/design/cycle12_arenas_brief.md`.
- **Estado**: **PROPOSTA**. Nenhuma das oito arenas está aprovada; o escopo abaixo espera o Daniel (decisões D-25 a D-32 no
  `docs/backlog.md`). Nada foi implementado nesta avaliação.
- O que é conta está com a fonte; o que é opinião minha está escrito como opinião.

## 1. As imagens, olhadas uma a uma

| Imagem | O que mostra de útil para o jogo | O que não serve como está |
|---|---|---|
| `01` prancha | plataforma irregular com borda quebrada sobre o abismo; ponte em arco ligando dois patamares; sarcófagos e blocos de ruína como cobertura no meio do chão; três escalas (pequena, média, comprida) com o boneco; oito miniaturas; módulos (bloco, coluna, borda de abismo, ponte, escada, sarcófago, braseiro, velas, cristal) | pontes estreitas demais para lutar (cerca de 2 corpos); muitos objetos soltos no caminho |
| `02` salão da fenda | um rasgo comprido no meio do chão, com balaustrada quebrada numa borda e borda viva na outra; as duas metades ligadas pelas pontas; inscrição de ouro no chão | a fenda é a única ideia; o chão em volta é um anel estreito (3 a 5 m nos lados) |
| `03` árvore e pontes | árvore enorme sobre um patamar próprio; três patamares ligados por pontes em arco; raízes atravessando a ponte | a copa cobre um terço da tela (esconderia o herói); muitos níveis de altura (o jogo é um plano só) |
| `04` jardim da árvore | um salão largo e assimétrico, tronco a noroeste, raízes rastejando pelo chão, sarcófagos soltos, círculos de inscrição | é o mais "jogável" dos cinco: chão contínuo, um obstáculo central, cobertura baixa |
| `05` quatro faixas | (a) chão com vários buracos e o medalhão no meio; (b) a árvore com mureta em volta; (c) duas plataformas redondas e uma ponte comprida; (d) cripta com sarcófagos, colunas, muros baixos e nichos | as faixas são panorâmicas, a câmera do jogo (30°, girada 35°) nunca vê assim |

Leitura geral (opinião): a paleta das cinco é a nossa (pedra azul-acinzentada, abismo violeta, fogo âmbar, cristal
esmeralda, estandartes vermelhos com o leão); o que elas acrescentam é **forma de chão** (bordas quebradas, buracos,
pontes, ilhas) e **cobertura no meio da luta**. As duas coisas o jogo não sabe fazer hoje (seção 2).

## 2. O que existe no código e o que falta

| Peça | Hoje | Falta para as arenas |
|---|---|---|
| Forma do chão | `FloorShape` (`core/floor_shape.gd`): retângulo ou círculo, `contains`, `clamp`, `edge_distance`, `cut`; `Arena.walk` soma retângulos extras (o patamar do salão) | polígonos com **buracos** (abismo dentro da sala), união de vários pedaços (ilhas, pontes) |
| Colisão | `Arena.resolve`: chão, pilares em círculo (`pillars`), caixas (`boxes`), 4 passes | só empurra para o ponto mais perto: com um buraco estreito, um avanço de 0,2 s (cerca de 0,5 m por quadro a 60 FPS) que passe do meio sai do outro lado. Precisa de movimento **varrido** (cortar o passo na borda) |
| Inimigos andando | `Horde`: reto ao alvo, desvio lateral, separação, `resolve` contra pilares e caixas; `flee_dir` gira ao longo da parede; sem busca de caminho | com uma fenda no meio, todo inimigo do outro lado fica parado na borda para sempre. Precisa de **caminho** |
| Tiros | `Projectiles` não olha o cenário (nenhuma referência a `arena`, pilares ou caixas); some fora de `Arena.HALF * 2` (72 m) em volta da origem | **bloqueio por obstáculo** e limite pela sala real |
| Cobertura | o mago do `c666f4a` se esconde atrás do pilar mais perto (`Horde.cover_spot`) | os tiros atravessam o pilar: a cobertura não cobre (BUG-015) |
| Linha de tiro | não existe; atirador atira de onde estiver | atirador só prepara com linha livre; se não tiver, anda até ter |
| Nascimento | `Rooms._spawn_point`: ponto ao acaso no retângulo, a mais de 6 m do herói, `resolve` | com buracos e ilhas pode nascer onde não se chega; precisa de **zonas de nascimento** e conferir o caminho |
| Saídas | o salão calcula as portas (`CatacombHall._doors`, `Arena.exit_at`) | portas por arena, em dado, com caminho garantido do início até cada uma |
| Câmera | `Game` limita o alvo pela metade da sala menos `CAM_MARGIN` e `CAM_SOUTH` (medidos a 60 m), e `CamFrame.keep` segura o herói a 18% das bordas; a câmara do chefe usa `cam_target` e `cam_reach` | limites de câmera **por arena** (um retângulo ou polígono para o alvo), porque a sala não é mais um retângulo |
| Escolha da sala | `StageDef.layouts` já é uma lista; `RunMap._layout()` sorteia qualquer uma; a loja tem `shop_layout`, o chefe `boss_layout` | sortear por profundidade e dificuldade, sem repetir a anterior, com semente |
| Robô | `Bot._steer` e `_escape` testam pontos em volta (desvio local) | sem caminho ele também fica preso na fenda; todas as métricas dependem dele |
| Cenário | `ArenaKit` e `Masonry` já têm prisma de polígono qualquer (`prism`), balaustrada, escada, obelisco, arcos, estátua encapuzada, vela, pote, caixote, corrente, estandarte, braseiro, brilho do abismo, e o `see_through` em volta do herói; sarcófagos e pilaretes no `BossChamber` | árvore, estante e água não existem; nada pode vir do Meshy (regra deste ciclo) |

Conclusão: a base de dados e de colisão é boa e já foi generalizada uma vez (a câmara, ciclo C11). O que não existe é
**chão com buracos, caminho, linha de tiro e câmera por sala**. Sem isso, nenhuma arena com fenda, ponte ou árvore funciona.

## 3. Números que mandam no tamanho

| Número | Valor | Fonte |
|---|---|---|
| Andar, corrida | 6,75 m/s; 11,1 m/s | `_feel`, `boss_arena.md` |
| Esquiva | 5,6 m em 0,2 s | `_feel` |
| Corpo do herói; inimigos | 0,5 m; 0,55 a 1,1 m (Morvath 1,4) | `Player.RADIUS`, `_enemies` |
| Alcance de quem atira | mago 13,1 m (elite 16,25); besteiro 12 m; sacerdote 22,5 m | `c666f4a` |
| Câmera | distância 54, inclinação 30°, campo vertical 24° | `_feel` |
| Chão visto em 16:9 (minha conta) | cerca de **41 m** de largura na altura do alvo; em profundidade, cerca de 17 m para o lado da câmera e 36 m para o fundo (o fundo bem achatado) | `Feel.cam_offset_of`: altura 27 m, bordas a 42° e 18° abaixo do horizonte |
| Moldura segura | o herói fica nos 64% do meio da tela (18% de cada borda) | `CamFrame.SAFE` |
| Salão atual | 32 x 30 m, cerca de 800 m² andáveis, cabe inteiro na tela | `CatacombHall.HALF`, `boss_arena.md` |

Tempo de travessia a pé: 24 m em 3,6 s; 36 m em 5,3 s; 52 m em 7,7 s; 65 m em 9,6 s (correndo, 5,9 s).

**Faixas que eu valido** (dimensão andável, sem o cenário de fora):

| Categoria | Proposta do pedido | Minha faixa | Por quê |
|---|---|---|---|
| Pequena | 18 a 24 m | **20 a 24 m** | abaixo de 20 m o sacerdote (22,5 m) e o mago (13 m) não têm onde manter distância e atiram encostados (`flee_dir` encurralado); a sala inteira cabe na tela com folga de 8 m de cada lado que precisa de parede ou abismo desenhado |
| Média | 25 a 36 m | **26 a 34 m** | o tamanho do salão; câmera quase parada |
| Grande | 37 a 52 m | **38 a 48 m** | passa da largura da tela (41 m): a câmera anda, como pedido; acima de 48 m o inimigo do outro lado fica fora da tela por muito tempo |
| Comprida | 45 a 65 m | **45 a 56 m no eixo, 14 a 20 m de largura** | 56 m a pé são 8,3 s; o eixo comprido deve correr na **horizontal da tela** (com a câmera girada 35°, isso é um eixo do mundo girado), nunca para baixo: para o lado da câmera o herói vê só cerca de 17 m à frente |

Regras de geometria que proponho (opinião minha, a testar):
1. **Vão de abismo**: todo buraco que corta caminho tem 6 m ou mais (claramente maior que a esquiva de 5,6 m) ou tem ponte.
   Um vão de 3 a 5 m "parece pulável" e frustra.
2. **Corredor**: pelo menos 3,5 m de largura (dois corpos passam, e o herói ainda esquiva de lado); ponte de luta 5 m ou
   mais; ponte de passagem 4 m ou mais.
3. **Plataforma de luta**: pelo menos 14 m de diâmetro livre (a foice de Morvath mede 5 m; um esqueleto alcança cerca de 2 m;
   14 m deixam fugir de dois lados).
4. **Ninguém ataca de fora da tela**: atirador só prepara o tiro com o corpo dentro de 5% a 95% da tela (regra nossa,
   barata com `CamFrame.screen_of`), senão anda para dentro.
5. **Nada alto entre a câmera e o herói** sem o `see_through` (o pontilhado que já abre obeliscos, velas e o arco da câmara).
6. **Sem colisão invisível**: toda colisão nasce do mesmo dado que desenha a peça (seção 5).

## 4. As oito arenas, avaliadas

Dificuldade espacial: o quanto a forma do chão pesa na luta. Custo de arte: com o kit atual (`ArenaKit`, `Masonry`).

| Arena | Tamanho (minha proposta) | O que exige de sistema | Inimigos de pé | Custo de arte sem Meshy | Risco | Entrega |
|---|---|---|---|---|---|---|
| 04 Cripta dos Esquecidos | pequena, 22 x 20 m | obstáculos que bloqueiam tiro, linha de tiro, caminho em volta | **4 a 6**; no máximo 2 de longe, sem sacerdote | baixo (sarcófagos, colunas, nichos com estátua, velas: tudo existe) | baixo | **1** |
| 01 Salão das Fendas | grande, 40 x 30 m, fenda de 6 a 9 m cortando 60% do chão, 2 pontes de 5 m e uma passagem lateral | chão com buracos, movimento varrido, caminho, nascimento validado | **6 a 8** | médio (borda quebrada em `prism`, abismo e brilho existem) | médio (navegação) | **1** |
| 02 Jardim das Raízes Mortas | média, 34 x 28 m, tronco de 3,5 m de raio fora do centro, 4 a 6 raízes baixas | o mesmo da cripta, com um obstáculo grande | **6 a 8** | **alto**: a árvore não existe; proponho árvore **petrificada** (pedra do `Masonry`, tronco e raízes por torno e varredura), copa no pontilhado | médio (arte) | **1**, se a D-30 aceitar a árvore de pedra |
| 08 Santuário Desmoronado | grande, 44 x 32 m | só obstáculos | **8 a 12**, guardiões | baixo a médio (arcos, altares, estátuas, vitral só como cartão) | baixo | **2** (é a casa natural do guardião) |
| 03 Ponte dos Condenados | comprida, 54 x 18 m, 2 plataformas de 16 m e uma ponte de 5 m | tudo da fenda, mais regra de onda por plataforma (ninguém nasce na ponte) | **3 a 5** por plataforma | médio (ponte em arco, correntes existem) | alto (bloqueio injusto, câmera na comprida) | **2** |
| 05 Câmara das Runas Instáveis | média, 30 m, redonda imperfeita | sistema novo de perigo de chão, por baixo dos avisos dos inimigos | **4 a 6** (as runas valem por 1 ou 2) | baixo (runa e chão ritual existem) | **alto de leitura**: desde hoje "círculos no chão são só de Morvath" (`da35721`); runas em círculo quebram essa regra | **2**, com a D-29 |
| 06 Biblioteca Sepultada | em L, 46 x 30 m | destrutíveis que abrem passagem e mudam o caminho | 5 a 7 | alto (estantes e livros não existem) | alto (destruição e caminho) | **3** |
| 07 Reservatório das Almas | grande, 44 x 36 m | terreno que desacelera (inimigos e herói), água com reflexo | 6 a 8 | alto (água) | alto (lentidão é a mesma sensação que a maldição de Morvath: 30% mais lento) | **3**, com a D-31 |

E o **Salão das Catacumbas** de hoje (a pintura de referência do Daniel) continua: é a arena de abertura, da fonte e da
loja (proposta D-26). Ele é a única arena média e "baixa" pronta.

## 5. Estrutura de dados proposta (integrada, sem sistema paralelo)

Nada de `ArenaDefinition` nova: o `RoomLayout` já é a definição de uma sala e já foi estendido para a câmara.

- **`RoomLayout`** ganha: `id`, `size_class` (pequena, média, grande, comprida), `difficulty` (0 baixa, 1 média, 2 alta),
  `depth` (faixa da descida onde pode sair), `max_alive` (teto da sala, nunca acima da faixa do tier), `look` (quem desenha:
  `&"hall"`, `&"crypt"`, `&"rift"`, `&"garden"`), `obstacles`, `spawns`, `exits`, `cam_bounds`, `variants`. Já tem
  `floor`, `hero_spawn`, `hero_facing`, `cam_target`, `cam_reach`, `pillars` (os pilares viram obstáculos em círculo).
- **`FloorShape`** ganha `Kind.POLY`: uma lista de polígonos andáveis (união) e uma lista de buracos; `contains`, `clamp`,
  `edge_distance` e `cut` passam a valer para ele (o `cut` é o que dá o movimento varrido do avanço e dos empurrões).
- **`ArenaObstacle`** (Resource novo, pequeno): forma (círculo, caixa girada, polígono), `blocks_move`, `blocks_shots`,
  `see_through`, `hp` (0 = indestrutível; só na entrega 3), `piece` (o que desenha: sarcófago, coluna, raiz, tronco). As
  classes A a F do pedido viram campos: A sem colisão = não é obstáculo (é cenário); B `blocks_move`; C `blocks_shots`;
  D `hp`; E buraco no `FloorShape`; F `ArenaHazard` (entrega 2).
- **`NavGrid`** (core, puro, testado): grade de 0,5 m feita do `FloorShape` e dos obstáculos; campo de fluxo até o herói
  refeito quando ele muda de célula (no máximo 4 vezes por segundo); `reachable(a, b)`, `next_step(from)`, `clear_line(a, b)`.
  Em sala aberta o inimigo continua andando reto (o comportamento de hoje); o campo só entra quando a linha reta está
  bloqueada. O robô usa a mesma grade. Opinião: campo de fluxo próprio e não o `NavigationServer2D` da Godot, porque é
  determinístico com semente, roda no GUT sem cena e serve igual para 20 inimigos e para o robô.
- **Tiros**: `Projectiles` testa o segmento do passo contra obstáculos com `blocks_shots`; o tiro morre neles com uma
  faísca; limite pela caixa da sala real em vez de `Arena.HALF`. Os atiradores só preparam com `clear_line`. Morvath não
  muda: a câmara não tem obstáculo.
- **Nascimento e saídas**: `RoomLayout.spawns` (polígonos ou retângulos onde se pode nascer) e `exits` (posição e direção
  de cada porta). Teste: de `hero_spawn` há caminho até cada saída e até cada zona de nascimento, em toda variante.
- **Câmera**: `cam_bounds` (retângulo do alvo da câmera, no mundo) substitui `half` menos as margens quando existir;
  `CamFrame.keep` continua mandando (o herói nunca a menos de 18% da borda). Sem zoom por sala nesta entrega (o pedido
  pede para evitar mudança brusca; o salão e a câmara usam 54).
- **Variantes**: `ArenaVariant` (Resource): espelhar no eixo x, trocar um conjunto de obstáculos, trocar as saídas, clima
  (`RoomMood.Look`). Semente da sala já existe (`1406 + depth * 31 + layout` em `Rooms._enter`).
- **Escolha**: `RunMap._layout()` passa a filtrar por `depth`, `difficulty` e a não repetir a arena anterior.
- **Desenho**: um construtor por `look`, como `CatacombHall` e `BossChamber` (`scripts/game/`), que lê o mesmo
  `RoomLayout`: a peça e a colisão saem do mesmo dado.
- **Ferramentas**: `--arena=id --variant=n` (começar numa arena), `tools/arena_lab.gd` (vista sem personagens, de cima com a
  grade de caminho desenhada, e na câmera do jogo), RESULT com `arena`, `stuck` por inimigo, `shots_blocked`.

## 6. Progressão da Fase 1 (proposta)

Descida inteira (D-06, ainda não confirmada): 10 salas e Morvath na 11.

| Sala | O que | Arenas possíveis |
|---|---|---|
| 1 | abertura com dom | Salão (baixa) ou Cripta |
| 2 e 3 | combate | Cripta, Jardim, Fendas (média) |
| 4 a 6 | guardião numa delas | Santuário (entrega 2) ou Salão |
| 5 a 8 | uma fonte (descanso, sem luta) | Salão, tratamento próprio |
| 7 a 9 | combate difícil | Fendas, Ponte, Runas (alta) |
| 10 | loja | Salão |
| 11 | Morvath | Câmara do Selo (só dele) |

Duração: o Daniel chegou a Morvath em 107 a 113 s na descida curta (`runs.jsonl`, 3 partidas). Uma sala de luta grande
acrescenta de 4 a 8 s de travessia. Minha estimativa para a descida inteira com arenas: 7 a 9 min até Morvath e 10 a 13 min
de partida. Para o teste da entrega 1 proponho uma **descida de teste de 7 salas** (3 lutas em arenas diferentes, fonte,
guardião, loja, Morvath), cerca de 4 a 5 min até o chefe (D-27).

## 7. Testes de navegação (obrigatórios na entrega 1)

Todos com semente fixa, sem tela, no GUT ou no `--smoke`:
1. **Caminho**: em cada arena e variante, `NavGrid.reachable` do início a cada saída, a cada zona de nascimento e a cada
   célula andável maior que um corpo (nenhuma ilha morta).
2. **Avanço perto do abismo**: de 200 posições na borda de cada buraco, avanço em 16 direções: o herói nunca termina
   dentro do buraco nem do outro lado de um vão maior que 0,5 m; o mesmo com quadros de 33 ms (30 FPS).
3. **Empurrão**: golpe que empurra um inimigo para a borda; ele para nela (até a D-28).
4. **Inimigo preso**: 64 lutas por arena com o robô; nenhum inimigo parado sem caminho por mais de 3 s (`stuck` no RESULT);
   tempo até o primeiro contato e duração da sala.
5. **Linha de tiro**: um atirador atrás de um obstáculo com `blocks_shots` não prepara; um tiro na direção de um pilar morre
   nele; o tiro do herói também.
6. **Cercado**: herói num corredor de 3,5 m com 2 inimigos de cada lado; sempre há uma esquiva que sai (como
   `test_boss_exits.gd`).
7. **Desempenho**: passo da simulação com 8 inimigos e o campo de fluxo (`step_ms_peak` abaixo de 2 ms no PC); quadro a
   1080p na RTX 5060 por arena; e uma medida no Compatibility (DT-003).

## 8. Riscos

1. **Navegação** (o maior): sem caminho, a fenda prende metade dos inimigos e o robô; com caminho malfeito, inimigos que
   tremem na borda. Mitigação: campo de fluxo só quando a linha reta está bloqueada; testes 1 e 4 antes de qualquer arte.
2. **Avanço atravessando buraco** por arredondamento: o `resolve` de hoje escolhe o ponto mais perto. Mitigação: `cut` no
   passo (teste 2).
3. **Balanceamento**: os atiradores novos já deixaram as salas mais difíceis (o robô vence 1 a 2 em 4 a 6; o Daniel
   chegou a Morvath com pouca vida e morreu 2 vezes em 3). Cobertura que bloqueia tiro **facilita**; salas pequenas com
   atirador **dificultam**. Mudar as duas coisas junto com o teste humano dos atiradores confunde a medida. Mitigação: a
   métrica por inimigo e por sala no registro (QW-011) e o teto por arena.
4. **Arte sem Meshy**: a árvore é a peça mais difícil; feita de pedra pelo código pode ficar genérica perto das imagens.
   Mitigação: ela é a última da entrega 1 e só entra com a revisão do `art-director`; se não ficar boa, sai e fica a fenda.
5. **Câmera** em sala grande ou comprida: alvo que salta ao bater no limite. Mitigação: o limite é só um retângulo para o
   alvo, a mola atual da câmera continua; captura de travessia em vídeo.
6. **Desempenho**: salas grandes têm mais peças e mais luzes; o salão já custa cerca de 5 ms a 1080p na RTX 5060 e nunca foi
   medido em máquina fraca. Mitigação: no máximo 8 luzes com sombra por arena e `Masonry.merge`.
7. **Tempo de partida**: mais travessia e mais salas alongam a partida. Mitigação: descida de teste de 7 salas e medida do
   tempo até o chefe no `runs.jsonl`.
8. **Escopo**: oito arenas e cinco sistemas novos (buracos, caminho, linha de tiro, perigos de chão, destrutíveis, terreno)
   são vários ciclos. Por isso a entrega 1 tem 3 arenas e os 4 primeiros sistemas.

## 9. Escopo recomendado (aguarda o Daniel)

**Entrega 1 (ciclo C12)**: fundação (chão com buracos e movimento varrido, `NavGrid`, linha de tiro e tiros que param na
pedra, nascimento e saídas em dado, câmera por arena, escolha sem repetir, robô com caminho, laboratório e testes) e
**três arenas**: Cripta dos Esquecidos, Salão das Fendas e Jardim das Raízes Mortas (árvore de pedra), cada uma com 2
variantes. O Salão de hoje fica como quarta base.

Por que tirei a Câmara das Runas Instáveis da primeira entrega (o Daniel a sugeriu): ela é a única que precisa de um
sistema de perigo de chão novo, é de dificuldade alta (não pode sair cedo na descida, então pouco aparece numa descida de
teste) e esbarra numa regra decidida hoje, os círculos no chão serem só de Morvath. Ela vai para a entrega 2 com a forma
decidida (D-29), junto da Ponte (que reaproveita o chão com buracos da fenda) e do Santuário (casa do guardião).
Biblioteca e Reservatório ficam para a entrega 3: cada uma pede um sistema inteiro (destrutíveis com caminho que muda;
terreno que desacelera).

**Ordem dentro do ciclo**: fundação e testes de navegação primeiro (sem arte), depois a Cripta (só obstáculos, prova linha
de tiro e cobertura), depois a Fendas (prova buracos e caminho), por último o Jardim (prova o obstáculo grande e a arte).
Evidências em `docs/gallery/cycle12_maps/` como o pedido descreve (seção 16), com vídeo de travessia de cada uma.
