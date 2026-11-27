> Índice: [rooms_progression.md](../rooms_progression.md)

## Benchmark Hades II (capturas do Daniel, 2026-11-19)

Pedido do Game Director: comparar as capturas do Hades II do Daniel com as nossas salas no código de hoje (`4098f7a`,
câmera Perto padrão) como level designer. Copiamos leitura e números, nunca arte. **Nada implementado**; nenhum dado,
código ou teste do repositório mudou. As propostas ligam às LR (revisão de layout acima) e às RP (Sugestões e Sworn) em
vez de repetir.

### 1. O que foi olhado e como medi

- **Capturas do Hades II** (só locais, fora do repositório): `docs/art/ref/hades2_bench_2026-11-19/01` a `08`. Só três
  mostram espaço: `02` (a tenda de uma estação do hub, com diálogo), `03` (o caldeirão do hub, com o menu de encantos) e
  `08` (a clareira das pedras do hub). `01` e `04` a `07` são telas (escolha de save, loja, reagentes, plantas, Bênçãos):
  ficam para o `ui-ux-designer`, não entram aqui. Para a sala de luta usei a pasta `Hades 2/Boss 1` (9 quadros da arena
  da Hécate no Érebo, de um vídeo 4K do YouTube reduzido a cerca de 1500 x 890: comprimidos e sem a resolução do jogo;
  servem para proporção e valor, não para pixel exato).
- **Nossas salas**: 18 capturas da fila do Game Director (GPU, Forward+, 1920 x 1080, estilizado, Perto, robô aos 8 s)
  em `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/zip/shots/salas/`
  (Salão vitrine e luta, Cripta, Fendas, Jardim, Santuário, Ponte e Runas A e B, guardião, fonte, loja, Provação; Altar,
  Câmara e hub ainda não tinham saído) e as do hub em `docs/gallery/hub/d/`.
- **Valor na tela**: `python3 -I tools/frame_stats.py --hue` com caixas: o meio do quadro (x 30 a 70%, y 30 a 70%)
  contra os quatro cantos (20% x 20%, sem o HUD), e caixas de chão aberto sem peça nem personagem.
- **Planta**: uma sonda só de leitura sobre o `data/stages/catacombs.tres` (grade de 0,5 m sobre o chão de cada vista),
  `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/78898d24-f62f-43d1-9d7c-e7eaa36af8bf/scratchpad/bench/density_probe.gd`
  (rodar com `~/tools/godot/godot --headless --path . -s <arquivo>`). O Salão não está no estágio (é o `CatacombHall`) e
  fica fora dessa tabela.
- Ressalvas: o Hades é uma arena de chefe só (o Érebo comum não está nas capturas); a altura do herói lá foi medida em
  quadros com ele correndo; o vídeo comprime os escuros (as faixas de valor do Hades estão um pouco apertadas a mais).

### 2. As medidas

**2.1 Quadro** (luma p50 de 0 a 255; razão = meio sobre a média dos cantos)

| | Hades II (arena da Hécate, 4 quadros; hub `08`) | Nós (Perto, 1080) |
|---|---|---|
| Altura do herói na tela | 8 a 9% da altura (correndo); de pé, cerca de 10% | cerca de 15% (160 px de 1080 no Salão e no hub); na Longe cerca de 10 a 11% |
| Chão andável na tela | cerca de 80% (a olho: o quadro é chão até os cantos, a vegetação só nos cantos) | Cripta 55%, Fendas 70%, Jardim e Salão 81%, Santuário 84%, Ponte 30 a 42% (LR 2.1) |
| Meio do quadro / cantos | meio 42 a 62, cantos 10 a 27; razão 2,0 a 3,0; hub `08` 105 contra 0 a 16 (13) | razão: Ponte B 0,9, Fonte 1,3, Salão luta 1,6, Jardim A 1,6, Ponte A 1,7, Salão vitrine 1,8; Fendas B, Runas A, Santuário B 2,1; Cripta A, Runas B, guardião 2,2; Santuário A 2,3; Cripta B 2,4; Fendas A 2,6; Jardim B 2,7 |
| Chão aberto sem peça, p10 / p50 / p90 | 22 / 29 / 33, 27 / 35 / 52, 20 / 26 / 31 (faixa p10 a p90 de 11 a 25) | Salão 41 / 71 / 85 (44), Jardim A 30 / 66 / 88 (58), Santuário A 50 / 78 / 105 (55) e 41 / 76 / 109 (68), Cripta A 48 / 84 / 120 (72), Fendas A 67 / 115 / 148 (81) e 74 / 118 / 196 (122) |
| Saturação do chão (p50) | 0,47 a 0,55, frio e escuro | 0,12 a 0,35 |

Leitura: o Hades tem o chão **escuro, frio e quieto** (a faixa de valor do chão aberto é um terço da nossa), o meio do
quadro sempre 2 a 3 vezes mais claro que os cantos, e é sobre esse fundo que os avisos laranja, vermelho e esmeralda
saltam (`184601`, `185206`). Nós temos o chão claro, com lajes de valores bem diferentes, manchas e poças de luz por
todo lado; em seis vistas os cantos são quase tão claros quanto o meio (velas e braseiros nas balaustradas). A cor e a
pintura são do `environment-artist` e do `art-director`; aqui interessam o **contraste do chão sob o aviso** e **para
onde a luz manda o olho**.

**2.2 Altura do herói.** Pela conta do `Feel` a Perto (37 m) é o ZoomFraction 0,85 do Érebo e as salas cabem em 1 a 2,2
telas como lá (LR 2.1). Mas nas capturas a Melinoë ocupa 8 a 10% da altura da tela e o Guerreiro 15%: medido assim, o
nosso herói aparece cerca de 1,5 vez maior que ela, e o enquadramento do Hades, na altura do herói, fica perto da nossa
Longe. Se isso se confirmar numa captura limpa, as nossas salas são do tamanho de tela do Hades, mas **menores em
corpos de herói** (cerca de dois terços), que é a outra metade do "sala pequena, inimigos juntos" que o Daniel sente. Não
dá para decidir com quadros de vídeo de herói correndo (BH-01).

**2.3 Planta das vistas de luta** (sonda da planta; "perto de cobertura" = chão a até 2,5 m de uma peça que barra tiro,
topo acima de 1,25 m; "clareira" = chão a 4 m ou mais de toda peça e da borda; entrada até cada saída em metros)

| Vista | Chão m² | Peças que barram corpo (barram tiro) | Por 100 m² | Chão ocupado por peça | Perto de cobertura | Clareira | Maior clareira (raio) | Entrada até as saídas |
|---|---|---|---|---|---|---|---|---|
| Cripta A | 495 | 9 (7) | 1,82 | 4,8% | 47% | 0% | 3,8 m | 22, 24, **11** |
| Cripta B | 500 | 7 (5) | 1,40 | 3,8% | 36% | 0% | 4,0 m | 22, 24, **11** |
| Fendas A | 1064 | 7 (7) | 0,66 | 1,1% | 20% | 4% | 5,5 m | 38, 41, 28 |
| Fendas B | 1029 | 5 (5) | 0,49 | 0,9% | 17% | 8% | 6,4 m | 38, 41, 28 |
| Jardim A | 870 | 19 (4) | 2,18 | 7,5% | 18% | 10% | 7,0 m | 35, 32, **18** |
| Jardim B | 880 | 15 (5) | 1,71 | 6,5% | 23% | 11% | 6,0 m | 35, 32, **18** |
| Santuário A | 1198 | 17 (13) | 1,42 | 2,2% | 30% | 11% | 6,1 m | 22, 29, 45 |
| Santuário B | 1153 | 12 (10) | 1,04 | 1,4% | 24% | 9% | 6,1 m | 22, 29, 45 |
| Ponte A | 801 | 7 (7) | 0,87 | 1,6% | 29% | 5% | 6,0 m | 47, 54, 47 |
| Ponte B | 737 | 3 (3) | 0,41 | 0,7% | 14% | 8% | 6,3 m | 47, 54, 47 |
| Runas A | 717 | 4 (4) | 0,56 | 1,2% | 18% | 20% | 7,6 m | 25, 30, **13** |
| Runas B | 722 | 2 (2) | 0,28 | 0,6% | 9% | 39% | 10,1 m | 25, 30, **13** |

Na arena da Hécate (`184601`, `185256`, `185313`) há de 6 a 9 peças por quadro (árvores secas e tocos de 2 a 3 m, nada
maior), espalhadas a 6 a 10 m umas das outras, nenhuma no miolo: de qualquer ponto há uma peça a 3 ou 4 m e nenhuma
parede no meio. Com o quadro de cerca de 28 x 16 m da Perto isso dá umas 1,5 a 2 peças por 100 m², parecido com a nossa
Cripta e o nosso Jardim (o Jardim conta raízes que não barram tiro), e o dobro ou o triplo das Fendas, da Ponte e das
Runas. Nossa cobertura é **concentrada** (o sarcófago, o tronco, a nave de colunas); a deles é **espalhada e pequena**.

### 3. O que eles fazem e o que nós fazemos

1. **Forma da sala e quanto cabe.** Hades: a arena é maior que a tela, a câmera anda, o chão vai até os cantos do quadro
   e a borda nunca é uma linha reta à vista (vegetação). Nós: com a Perto as salas têm 1 a 2,2 telas (LR-01 resolveu o
   tamanho em telas), mas as bordas são retas (paredes, balaustradas, beira do abismo) e a Cripta mostra embaixo um terço
   de quadro de parede cortada e vazio (`03_cripta_A`); a Ponte é estreita de propósito (30 a 42% de chão na tela).
2. **Bordas e o que fica além.** Hades: a borda é mata escura que entra no quadro em primeiro plano nos cantos de baixo
   (`185206`, `185235`), fecha a arena sem parecer parede e nunca cobre o miolo; não se vê vazio. Nós: além do chão, o
   abismo ou a parede; peças de primeiro plano **dentro** da área de jogo cobrindo parte da luta (o obelisco do sul na
   fonte, `16_fonte`, cerca de um quinto do quadro; a coluna com braseiro na cabeceira da Ponte A, `11_ponte_A`).
3. **Portas e recompensas.** As capturas não mostram portas (são da arena de chefe). Do jogo (não destas capturas): a
   entrada fica embaixo e as saídas em cima ou nos lados de cima, longe de onde se entrou. Nós: toda sala de luta tem
   saída no norte, no leste e no **sul**, e a do sul fica na beira de baixo da tela e perto da entrada na Cripta (11 m),
   nas Runas (13 m) e no Jardim (18 m). A recompensa aparece no meio da sala (`Rooms`: `arena.middle`), sem lugar próprio.
   É o RP-19, que já pede isso; agora com os números.
4. **Obstáculos e cobertura.** Ver 2.3: Hades espalhado e pequeno; nós concentrado, e as salas grandes e abertas
   (Fendas, Ponte) com pouca cobertura fora da peça principal (17 a 29% do chão perto de cobertura). Runas pouca de
   propósito (o chão é o perigo; não mexer).
5. **Densidade no chão.** Hades: chão liso e escuro, só marcas baixas e espaçadas (redemoinhos, pedras soltas) no
   mesmo valor; o detalhe está na borda e nas peças. Nós: o detalhe está **no chão do meio** (lajes de valores muito
   diferentes, manchas do SW-G1, lajes emolduradas do SW-G3 e SW-C1, poças de luz) e a faixa de valor sob os avisos é 2 a
   5 vezes a do Hades (2.1). O Sworn P1 foi de propósito para o lado contrário (dar vida ao chão); é uma decisão de
   direção (BH-02).
6. **Caminhos e respiro.** Hades: a arena tem largura para esquivar em qualquer direção sem bater em peça (as peças
   estão a 6 a 10 m). Nós: a Cripta não tem nenhum ponto a 4 m de tudo (maior clareira 3,8 a 4,0 m, menos que uma esquiva
   de 5,6 m); as outras têm clareiras de 5,5 a 10 m. Na Cripta é a ideia (sala de cobertura), mas é a sala que o LR-01 já
   marcou como "no limite".
7. **Como a sala conduz o olhar e o passo.** Hades: a luz cai no miolo da arena (razão 2 a 3) e no hub cada lugar de uso
   é uma clareira clara num fundo escuro (`08`: 13 vezes). Nós: em seis vistas a borda é quase tão clara quanto o meio,
   então o olho vai para as velas da balaustrada; os fios de ouro do hub para as estações (`env2_arrival_near_1080`)
   conduzem bem e devem ficar.
8. **Hub.** Hades (`02`, `03`, `08`): cada estação é uma sala dentro da sala, pequena e fechada por peças em volta
   (tapete com borda marcando onde se anda, caixas, velas, plantas nas costas e nos lados), o objeto da estação no meio,
   um anel no chão no lugar de usar, luz só ali; entre as estações, escuro. Ao falar, o mundo escurece atrás do retrato
   (`02`). Nós: depois do HUB-D (LR-07 atendido: estações a 11,5 m do eixo, nenhum par acima de 4 s) cada estação tem lugar
   próprio, mas a praça inteira é igualmente clara (`env2_arrival_near_1080`, `env2_at_smith_near_1080`), as estações
   ficam abertas para a praça em três lados e o lugar de usar é um losango gravado sem luz própria.

### 4. Propostas

Custo: P até meio dia, M 1 a 2 dias, G 3 dias ou mais. Régua de sempre (LR item 1: 24 sementes por câmera,
`--bot-reaction=0.25 --ultimate=cleave`, 0 `stuck`, `test_arenas.gd`, `fit_probe` sem piorar, vitórias dentro de 2 das
de hoje). Medidas de quadro com o método do item 1 (Perto, 1080, semente 5, 8 s), antes e depois, no scratchpad.

#### P0

**BH-01 Medir a escala do Hades numa captura limpa antes de mexer em tamanho de sala.**
- Evidência: 2.2. Em telas as salas batem com o Érebo (LR 2.1); em altura do herói na tela o nosso é cerca de 1,5 vez o
  dela. As duas medidas não podem estar certas juntas com o mesmo quadro.
- Proposta: pedir ao Daniel três capturas nativas a 1080 (print do próprio jogo, não do vídeo): uma sala de luta comum
  do Érebo e uma de Oceanus com a Melinoë **parada**, e a da Hécate. Medir a altura dela e a largura de chão visível
  (pelas lajes ou pelas peças repetidas) e comparar com o `CamFrame.screen_of` da Perto e da Longe. Resultado possível:
  (a) a Perto fica e o herói é que está grande no desenho (`HeroBody.HEIGHT` 2,75 contra 2,5 do combate; é do
  `gameplay-engineer` e do `art-director`); (b) uma distância entre as duas (cerca de 45 m) vira o padrão; (c) as salas
  crescem em metros para ficar do tamanho do Érebo em corpos de herói, a Cripta primeiro (o LR-01 já dizia 2 a 3 m).
- Aceite: altura do herói na tela na câmera padrão dentro de 15% da do Hades **ou** a diferença registrada como decisão
  do Daniel; nenhuma planta muda antes disso.
- Dono: `room-designer` (medida), Game Director (decisão), `gameplay-engineer` (`Feel` ou `HeroBody`). Custo: P.
- Liga: LR-01 (decidido em telas, não em corpos), LR-11 (distância da luta igual em toda sala).

**BH-02 Decidir o chão do meio da luta: quieto (Hades) ou vivo (Sworn P1).**
- Evidência: 2.1 e 3.5. Faixa de valor do chão aberto: Hades 11 a 25, nós 44 a 122; o SW-G1 (manchas) e o SW-G3/C1
  (lajes emolduradas) subiram essa faixa de propósito (Salão 68 para 78, Cripta A 84 para 98, Fendas A 90 para 101). Os
  avisos continuam lendo (Sworn P1 mediu o fio da mira igual), mas o Hades separa "chão" de "perigo" pelo valor do chão,
  e nós pela cor do aviso.
- Proposta (não é de sala, é de direção; fica registrada aqui porque muda o que o chão pode ter): as manchas e as lajes
  emolduradas vão para a borda e para fora das zonas de nascimento e do miolo da luta (o SW-G1 já é mais forte a 3 m da
  borda: baixar a força do meio de 0,8 para cerca de 0,3; nenhuma laje emoldurada a menos de 6 m do meio da zona
  dominante de cada sala), e a variação de valor entre lajes no miolo baixa.
- Aceite: faixa p10 a p90 de uma caixa de chão aberto de 300 x 150 px no miolo de cada sala de luta até 40 (hoje 44 a
  122); fio da mira e aro dos avisos pelo menos +40 de luma sobre o chão em volta (régua do Sworn P1); a borda continua
  com as manchas (o Sworn não se perde, só sai do miolo).
- Dono: `art-director` decide, `environment-artist` faz (números da chave `floor` de cada look). Custo: P na decisão,
  P a M nos números.

#### P1

**BH-03 A luz manda o olho para o miolo.**
- Evidência: 2.1. Razão meio / cantos: Hades 2,0 a 3,0; nós Ponte B 0,9, Fonte 1,3, Salão 1,6, Jardim A 1,6, Ponte A 1,7.
  Nas cinco os cantos claros são velas e braseiros nas balaustradas e nas cabeceiras.
- Proposta: em cada sala de luta a luz da borda fica atrás da borda ou com a poça menor (o `stylize_fires` já tem
  alcance e ganho por sala) e o miolo leva a luz-chave (fachos e chave do look); a Ponte com a luz nas plataformas, não
  nas cabeceiras.
- Aceite: razão meio / cantos de 2,0 ou mais em toda vista de luta (método do item 1), o meio sem passar do teto de
  luma que o `art-director` usa hoje.
- Dono: `environment-artist`; `art-director` revisa. Custo: P a M. Liga: nenhuma LR ou RP (é novo).

**BH-04 Borda grossa: além do chão, peça e escuro; primeiro plano que emoldura sem cobrir a luta.**
- Evidência: 3.1 e 3.2. Cripta A na Perto: um terço de baixo do quadro é a face da parede cortada e o vazio; Fonte: o
  obelisco do sul dentro da área de jogo cobre cerca de um quinto do quadro; Ponte A: a coluna do braseiro da cabeceira
  sobre o grupo. Hades: primeiro plano só nos cantos de baixo, escuro, fora do miolo.
- Proposta: (a) nenhuma peça alta (acima de 2,6 m, a regra de "nada sobre o chão" do redesenho) a menos de 3 m da beira
  de baixo da tela nas vistas de luta, ou com o pontilhado em volta do herói (`see_through`) também em volta da luta;
  (b) além da borda sul e oeste das salas fechadas (Cripta, Santuário), entulho, ruína e bruma escura no lugar do vazio
  liso (o `ArenaRoom.backdrop` e o `_apron` das câmaras de evento já fazem isso). O obelisco do Salão é da imagem de
  referência do Daniel: só o pontilhado, nunca tirar.
- Aceite: em cada vista de luta, nenhum pixel opaco de peça de primeiro plano na caixa central (x 20 a 80%, y 15 a 85%)
  com o herói no `hero_spawn` e no meio da zona dominante; fora do chão, nenhuma área lisa (p90 menos p10 abaixo de 8 e
  p50 abaixo de 20) maior que 15% do quadro, menos a Ponte (o abismo é a ideia dela).
- Dono: `environment-artist` com a especificação do `art-director`; `room-designer` confere com o `fit_probe`. Custo: M.
  Liga: LR 2.1 ("tela cheia").

**BH-05 Cobertura espalhada nas salas abertas.**
- Evidência: 2.3. Perto de cobertura: Fendas 17 a 20%, Ponte B 14%, Ponte A 29% contra 36 a 47% na Cripta; a luta das
  Fendas acontece no leste (49 a 65%, LR 2.3), onde há um toco só (RP-05).
- Proposta (só dado, peças que existem): Fendas A e B, dois tocos de 1,5 m (os do RP-05, `column_base` com tiro barrado)
  no campo leste a 6 a 8 m um do outro e um no caminho sul; Ponte B, um bloco de ruína (o do RP-04) em cada plataforma
  das pontas. Nada no miolo, nada a menos de 6 m da entrada nem dentro das zonas de nascimento.
- Aceite: perto de cobertura de 30% ou mais nas vistas tocadas (sonda do item 1); tiros barrados por sala sobem 30% ou
  mais; zona dominante das Fendas abaixo de 60% (hoje `east` 57 a 65%); 0 `stuck`; primeiro contato sobe no máximo 1 s.
- Dono: `room-designer`; `environment-artist` só confere o desenho (peças prontas). Custo: P. Liga: RP-05 (estende),
  RP-18 (colunata, a mesma ideia levada a uma variante), LR-05 (rota da ponte norte; fazer depois dele, para os tocos não
  fecharem a rota nova).

**BH-06 Saídas do lado de lá, recompensa entre a luta e as portas.**
- Evidência: 3.3. A saída sul fica embaixo na tela e a 11 m da entrada na Cripta, 13 m nas Runas e 18 m no Jardim; a
  recompensa cai no `arena.middle`, sem lugar próprio.
- Proposta: (a) fazer o RP-19 agora (toda saída a 8 m ou mais da entrada e na parede que a câmera vê de frente; as três
  juntas do mesmo lado quando couber), com estes números como a auditoria dele; (b) um ponto de recompensa por vista no
  dado (`RoomLayout.reward_spot`, padrão o meio de hoje): numa clareira de 4 m entre o miolo da luta e as saídas, para o
  passo ir luta, recompensa, portas sem voltar.
- Aceite: (a) o aceite do RP-19; (b) distância da recompensa à saída mais perto menor que a da entrada à mesma saída em
  toda vista, e a recompensa na tela com o herói na zona dominante; `test_arenas.gd` com a asserção nova.
- Dono: `room-designer` (dado e teste); `gameplay-engineer` (o `Rooms` ler o campo novo, uma linha); `environment-artist`
  (as bocas das portas que mudarem de parede). Custo: P (a), P (b). Liga: RP-19.

**BH-07 Hub: cada estação uma clareira de luz, o resto da praça mais escuro.**
- Evidência: 3.8. Hub do Hades: lugar de usar 13 vezes mais claro que os cantos (`08`), estação fechada nas costas e
  nos lados, tapete ou anel marcando onde se anda. O nosso: praça igualmente clara, estações abertas em três lados.
- Proposta: luz de cada estação (`HubLook.station_lights`, que já existe) mais forte e mais curta sobre o lugar de usar
  e a praça entre elas um passo mais escura (a fonte e os fios de ouro ficam); peças da própria estação fechando as
  costas e os lados até uns dois terços da volta, deixando aberto o lado que vem do eixo; o losango do lugar de usar com
  um anel de luz quando a estação está em foco (`HubFocus`).
- Aceite: luma p50 do lugar de usar de cada estação 1,8 vez a da praça entre elas ou mais, com a câmera Perto parada em
  cada estação; caminhadas iguais (nenhum par acima de 4 s, LR-07); `test_hub.gd` verde.
- Dono: `environment-artist` (`HubLook`), `art-director`; `ui-ux-designer` confere a placa. Custo: M. Liga: LR-07 (as
  distâncias, atendidas no HUB-D; isto é a luz e o fechamento).

#### P2

**BH-08 Respiro na Cripta.** A maior clareira é 3,8 a 4,0 m (menos que uma esquiva); nas outras salas 5,5 a 10 m. Só
depois do BH-01: se as salas crescerem, a Cripta primeiro (2 a 3 m na largura, LR-01) até uma clareira de 5 m. Dono
`room-designer`. Custo P no dado, M na arte.

**BH-09 Câmara do Selo como arena, não como prato.** A arena da Hécate é maior que a tela e tem árvores e tocos
espalhados que o jogador usa contra os ataques; a nossa é um círculo de 12,5 m vazio (0,92 x 0,84 tela na Perto). Proposta
só de estudo: três tocos baixos (barram corpo, não tiro) num anel de 8 m, com o `test_boss_exits.gd`, as faixas da
tempestade, a investida (8 m livres, `dash_min_free`) e o ritual medidos antes. Mexe nos padrões de Morvath: só com o
`gameplay-engineer` e o `combat-feel-director`, e depois da sessão do Daniel. Custo M a G.

**BH-10 Telas do Hades (`01`, `04` a `07`) para o `ui-ux-designer`.** Não são de sala; passar ao Game Director como
referência de leitura (loja em lista com preço à direita e o que falta em vermelho, inventário em grade com a descrição ao
lado, Bênçãos em três linhas com o número do efeito em destaque). Nada a propor aqui.

### 5. Riscos

- BH-01 e BH-08 podem levar a crescer salas: isso mexe em todo look, nos `HazardDef` (Runas, lajes) e no `fit_probe`;
  por isso nada muda antes da medida limpa.
- BH-02 desfaz parte do Sworn P1 (aprovado): decisão do `art-director` com o Daniel, não do `room-designer`.
- BH-03 e BH-07 mudam luz em salas aprovadas; o Compatibility (iGPU) precisa ser medido junto (o quadro já está perto de
  16 ms na Baixa).
- BH-05 e BH-06 mudam a luta (cobertura, onde se termina a sala): régua de 24 sementes por câmera e o `balance-designer`.
- As medidas do Hades são de quadros de vídeo de uma arena de chefe; o Érebo comum pode ser diferente. BH-01 resolve a
  escala; o resto vale como direção, com aceite medido nas nossas salas.

### 6. O que precisa de arte

Chão do miolo mais quieto (BH-02, se decidido); luz das bordas e do miolo (BH-03); primeiro plano e o que fica além da
borda (BH-04); bocas de porta que mudarem de parede (BH-06); luz e fechamento das estações do hub (BH-07). Nenhuma peça
nova: tocos, blocos, ruínas, bruma e luzes de estação já existem.
