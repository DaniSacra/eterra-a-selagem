> Índice: [combat_cadence.md](../combat_cadence.md)

## 9. Perigos do Lote A1, protótipos do atlas, dano 10 e quebráveis (critérios, HEAD `07688f5`, 2026-11-21)

Só critérios, escritos antes do código; a aprovação de cada entrega vem depois, com medida. Base: backlog "Estado e
ordem de 2026-11-20" (resposta 6: dano 10; resposta 8: RP-14), "Pacotes do PO de 2026-11-20" (P.2, P.3 AT-Q, P.4
AT-H1 a AT-H3), `docs/design/po_2026-11-20/layout_salas/PROMPT-CLAUDE-CODE.md` ("Cada perigo precisa comunicar o que
fará antes de causar dano, na câmera normal") e `docs/design/rooms_progression.md` (RP-12, RP-14, RP-18, RP-20).
Câmera de todas as medidas: **Perto** (`--cam=near`, 37 m, cerca de 28 m de chão na largura da tela), estilizado,
Forward+ e Compatibility.

### 9.1 Números de partida (o que limita a reação)

- [D] Herói anda 6,75 m/s; esquiva 5,6 m em 0,2 s com 19 f de proteção, 1 carga, recarga 0,74 s; proteção depois de
  ferido 1,3 s; vida 30. Travas que só a esquiva corta: pernas do especial e do Ômega do especial 0,71 s (pior caso),
  finalizador 30 f (0,5 s), golpe 2 19 f (0,32 s).
- [D] Perigos de hoje: Runas 1,2 s de aviso, Corrente 1,2 s, Raiz 1,2 s de aviso depois de 0,5 s de espera do herói,
  Laje Rachada 1,0 s, Seteira 1,0 s; golpe de 0,25 s que fere **num quadro só**, o do aviso cheio (seção 7).
- [I] **Janela de reação de pior caso** = aviso, menos a pior trava sem esquiva (0,71 s), menos o tempo de sair andando
  do ponto mais fundo da área até a borda mais perto (distância / 6,75). Tempo de reação de gente: 0,25 s (o
  `--bot-reaction` que usamos). Com a esquiva carregada a janela é o aviso inteiro (ela corta a trava e cobre 5,6 m).

### 9.2 Regras comuns a todo perigo novo (valem para os sete abaixo)

Quadro t0 = primeiro quadro em que o aviso aparece na tela.

| # | Regra | Medida | Classe se falhar |
|---|---|---|---|
| R1 | O alcance final inteiro desenhado já em t0 (moldura, aro ou faixa no tamanho do golpe); o que cresce é só o preenchimento. Nunca um ponto que vira área | quadro t0 no vídeo a 60 f | P0 |
| R2 | Dano no quadro em que o aviso enche, de 0 a +1 f; quem entra durante os 0,25 s do golpe não é ferido (como hoje) | sonda do perigo (log do `Ground` e do `hurt_ctx`) | P0 |
| R3 | O evento físico (pedra toca o chão, mão fecha, folhas abrem e a raiz bate, urna explode, cristal descarrega) cai no quadro do dano, de -1 a +1 f | vídeo a 60 f com `--fixed-fps 60` | P1 |
| R4 | A peça se anuncia no corpo dela também, começando em t0 (de 0 a +2 f): afundar, mão, folhas, pavio, poeira | vídeo | P1 |
| R5 | Som `<nome>_arm` em t0 (0 a +1 f) e `<nome>_fire` no quadro do dano; abaixo dos `Audio.WARN_CUES` de Morvath, sem ducking, `VoiceGate` | `--sound-log` contra o log do perigo | P1 |
| R6 | Janela de reação de pior caso (9.1) de 0,25 s ou mais **com dano 10**. Onde não dá, o aviso sobe para 1,2 s (tabela 9.4) | conta pelos números do dado; GUT do pior ponto | P0 (é a regra "nada inevitável") |
| R7 | Com o herói dentro da área ou a até 2 m dela, a área inteira fica entre 5 e 95% da tela da Perto | captura em 8 pontos da sala; teste com `CamRig.look_at` | P0 se a borda some, P1 se só a peça some |
| R8 | Perigo âmbar por baixo do vermelho dos inimigos: `render_priority` abaixo do `Ground` dos inimigos, preenchimento até 0,25, nada soma no stencil dos avisos | captura com a mira do besteiro e o bote do esqueleto cruzando o perigo armado: fio da mira com saturação 0,45 ou mais e luma +30 ou mais sobre o âmbar logo abaixo | P1 |
| R9 | No máximo 2 avisos de sala ao mesmo tempo na sala inteira (a regra "nunca 3") e nunca 2 sobre o mesmo ponto | GUT | P0 |
| R10 | Empurrão ou puxão de um perigo nunca deixa o herói dentro de outro aviso ativo (de sala ou de inimigo) nem em pedra | GUT com 12 x 12 pontos e avisos sorteados | P1 (P0 se cair em pedra) |
| R11 | Fora dos 6 m da entrada, dos 3 s do começo, das bocas de porta; dormente antes do progresso do dado | GUT (os testes de hoje dos RP) | P0 |
| R12 | Compatibility estilizado: armado a 0,75 do aviso com +25 de luma p50 e saturação 0,15 sobre o chão vizinho (a regra que as Runas passaram) | `frame_stats.py --hue` | P1 |
| R13 | Robô (reação 0,25, 8 sementes): dano do perigo no herói 0,5 a 1,5 por sala onde ele está, nenhum `stuck`; com gente, o registro (`hurt_ctx`) decide | `smoke 900 --runlog` | P1 |
| R14 | Depois do golpe a área some em até 0,1 s (o que fica no chão, fogo e entulho, tem desenho próprio e regra própria, abaixo) | vídeo | P2 |

### 9.3 Critérios por perigo

**RP-14 Cristal que descarrega (Runas B).**
- Preparo: a descarga começa no quadro da 3ª carga (sem espera escondida) e avisa **1,2 s** na língua das Runas: as
  lajes da fileira inteira com a moldura âmbar desde t0 e as divisas apontando para onde a descarga corre
  (`RunesLook.set_chevrons`). Alcance: a fileira de lajes de 3 m; saída andando de 1,5 m no pior ponto.
- Cargas 1 e 2 legíveis **sem ver o cristal** (ele fica ao norte, fora do chão, e pode sair da Perto): um som curto por
  carga e, desde a 2ª, a fileira alvo com a marca de repouso um degrau mais clara. P1.
- Nunca no mesmo intervalo de um padrão das Runas que deixe mais de 35% aceso nem tire o vizinho apagado de uma laje
  acesa (GUT junto dos 2000 padrões de hoje). P0.
- A pedra quieta nunca recebe a descarga (é para onde se foge). P0.
- Golpe no cristal (se o herói o alcança): conta carga, sem hit stop de inimigo (ver 9.6). P2.

**RP-12 Urna de óleo (Cripta tardia).**
- Pavio de 1,0 s com o aro de 2,5 m inteiro desde t0, o pavio queimando visível na urna; com 10 no herói o pior caso é
  quem a acendeu com o finalizador ou o especial: 1,0 - 0,71 - 2,5 / 6,75 = -0,08 s. **Aviso 1,2 s ou aro de 1,8 m**
  (1,2 - 0,71 - 0,37 = 0,12; com aro 1,8 e 1,2 s, 0,22): recomendo **1,3 s com 2,5 m** (0,22 s, o mesmo da Seteira, e o
  barril do Hades também avisa mais que os golpes). P0 até a conta passar.
- Acesa por qualquer fonte (golpe do herói, golpe de inimigo, outro perigo): o pavio é sempre o mesmo tempo a partir do
  quadro em que acende, nunca encurtado. P0.
- Fogo que corre no canal de 6 m a 3 m/s: o aviso vai **1,0 s à frente da chama** (faixa âmbar 3 m adiante dela); o
  chão em chamas fere uma vez por entrada (a proteção de 1,3 s cobre), fica desenhado inteiro enquanto fere e apaga em
  2 s com o desenho sumindo junto do dano (0 a +2 f). P1.
- Silhueta nunca a de um quebrável (bronze escuro, pavio, isolada; AT-Q0): confundir os dois é P0 de leitura (o
  jogador quebra o que acha que é vaso e explode).

**RP-18 Colunata (variante tardia, sem perigo novo, a coluna que tomba do RP-09).**
- A cobertura não pode esconder aviso: a 30 graus de inclinação uma coluna de altura h tapa o chão atrás dela por
  1,73 h (5 m de coluna, 8,7 m de chão). Critério: na Perto, todo aviso de inimigo dentro da colunata com 70% ou mais da
  área à vista, e o fio da mira do besteiro inteiro do pé dele até 3 m à frente. Caminhos: colunas baixas (até 2,5 m:
  4,3 m tapados) ou pontilhado também em volta de quem prepara um ataque. P1.
- Preparo do inimigo atrás de coluna: os sinais por cima do corpo (`EnemyFx` acima da pedra) seguem lidos. P1.
- Coluna que tomba: faixa 1,2 x 5 m por 0,6 s, não fere o herói; com três ou mais na grade, nunca duas tombando ao mesmo
  tempo sobre o mesmo inimigo sem aviso inteiro de cada uma. P2.
- Robô sem `stuck` e esquiva de 5,6 m nunca parada em coluna a menos de 2,5 m em 16 de 16 (o "cercado" do GP-04). P0.

**RP-20 Pedras da abóbada (Santuário B; depois Fendas B se a medida pedir).**
- Aviso **1,2 s**: o quadrado 2 x 2 m inteiro desde t0 (R1) e a sombra enchendo; poeira caindo do teto no mesmo ponto
  desde t0, vinda do alto da tela (o teto não aparece na Perto, então a poeira tem de entrar pela borda de cima e
  chegar ao chão). Saída de pior ponto 1,0 m: 1,2 - 0,71 - 0,15 = 0,34 s. Passa.
- A pedra aparece caindo nos últimos 0,2 a 0,3 s e toca o chão no quadro do dano (R3). P1.
- No máximo 2 por vez e a cada 4 s; nunca uma pedra cuja área toque a de outra pedra ou de uma Laje Rachada armada
  (R9). P0.
- Entulho de 3 s: **não barra corpo** (barrar mudaria a `NavGrid` no meio da luta, o risco que tirou o H-6); se barrar,
  é P0 até o teste de saída e o robô passarem. Desenho do entulho baixo e cinza, nunca âmbar (não pode ler como aviso).
- Nunca sobre o `boss_spawn` nos 3 s em que o guardião surge, nem sobre a barra de vida dele na tela. P1.

**AT-H1 Laje de pressão (Santuário A e B, é o RP-06).**
- O afundar de 4 cm e a rachadura começam em t0 (R4); o afundar lê na Perto como sombra na junta (4 cm são cerca de 1 px
  a 1080: só a sombra e a poeira contam). P1.
- **Aviso sobe de 1,0 para 1,2 s com dano 10** quando um inimigo arma a laje com o herói em cima (o herói não escolheu):
  1,0 - 0,71 - 0,22 = 0,07 s hoje. Armada pelo próprio herói andando, 1,0 s basta (ele não está travado ao pisar), mas
  um número só é mais simples: 1,2 s para toda laje. P0.
- Isca: o inimigo que pisa e se fere tem de ser visível como causa (a laje acende sob o pé dele, golpe com a marca de
  dano 60). Sem critério de cadência além de R2 e R3.
- Laje ativa distinta das emolduradas e tumulares na Perto em repouso (o atlas pede): repouso em osso apagado, nunca o
  relevo do SW-G3. P1.

**AT-H2 Esqueleto do nicho (Cripta B).**
- Repouso: a mão à mostra e o leque de 2,2 m marcado fraco no chão sempre (como a laje em repouso), lidos na Perto com o
  herói a até 4 m do nicho; o nicho na parede norte não pode sair pelo topo da tela nesse raio. P0 (é a única pista antes
  da espera de 0,3 s).
- Tempo total da entrada ao golpe: espera 0,3 s + aviso. Pior caso: o herói já dentro quando a recarga de 6 s acaba e
  solta o especial no quadro em que o aviso começa: 1,0 - 0,71 - saída lateral. Com a saída de 1,1 m (metade da
  largura do leque) dá 0,13 s. **Aviso 1,2 s** (0,33 s). P0.
- Preparo: a mão sai e os ossos mexem desde t0, a pedra raspando (`niche_arm`) em t0; a mão fecha no quadro do dano. P1.
- Agarrar: 10 e puxão de 1 m para o nicho em 0,1 a 0,15 s (nunca teleporte de um quadro), o herói mantém a esquiva no
  quadro seguinte (sem prender, Q-AT3 a). Puxão que poria o herói dentro de outro aviso: encurta até a borda dele (R10).
  P0 se prender ou teletransportar.
- Golpe da Emeth no esqueleto: faísca sem número, sem combo, sem Magia, sem passiva e **sem hit stop de inimigo** (o do
  escudo do ritual); o golpe segue o tempo normal. A mira assistida (`Player.ASSIST_*`) nunca gira o golpe para ele. P1.
- Fora das faixas das seteiras e a 1,5 m das lajes (R9). Nunca dois avisos de sala da Cripta B sobre o mesmo herói. P0.

**AT-H3 Planta hostil (Jardim B, pele do RP-10).**
- Espera do herói 0,5 s (o da raiz) e aviso **1,2 s** (o RP-10 de hoje; a P.4 escreve 1,0, vale 1,2 com dano 10): faixa
  de 2,5 m de comprimento; saída lateral no pior ponto até 0,75 m pede faixa de até 1,5 m de largura (com 3 m da raiz,
  1,5 m de saída, a conta dá 0,27 s, ainda passa).
- As folhas se fecham desde t0 e a raiz bate no quadro do dano (R3, R4). Na Perto, a contração lê como mudança de forma
  da silhueta (não só de cor): a planta encolhe pelo menos 25% da largura na tela até o golpe. P1.
- Golpe na planta: faísca e folhas encolhendo, sem hit stop de inimigo, sem número, nunca alvo da mira assistida. P1.
- Empurrão de 1 m para fora da faixa nunca para a água do lago J5 nem para pedra (R10).

### 9.4 Parecer sobre o dano 10 no herói (era 7; resposta 6 do Daniel)

**Aprovado com condições.** 10 é o número do Hades sobre os mesmos 30 de vida [H]; três acertos matam, então a regra
"nada inevitável" tem de valer no pior caso, não na média do robô (que lê o âmbar perfeitamente: 0,14 acerto por sala
nas Runas, seção 7).

| Perigo | Aviso | Saída no pior ponto | Janela de pior caso | Parecer com 10 |
|---|---|---|---|---|
| Runas | 1,2 s | 1,5 m (0,22 s) | 0,27 s | passa, no limite |
| Corrente da Ponte | 1,2 s | 1,0 m (0,15 s) | 0,34 s | passa |
| Raiz Morta | 0,5 + 1,2 s | 1,5 m (0,22 s) | 0,27 s | passa, no limite |
| Seteira | 1,0 s | 0,5 m (0,07 s) | 0,22 s | P2: aceita (faixa de 1 m e armada por laje à vista) |
| Laje Rachada | 1,0 s | 1,5 m (0,22 s) | 0,07 s | **P0: aviso 1,2 s** (0,27 s) |
| Borda que desmorona (RP-13) | 1,0 s | 1,5 m | 0,07 s | hoje fere 5, fora da resposta 6; se subir (7, a mesma proporção), aviso 1,2 s |
| Cristal (RP-14) | 1,2 s | 1,5 m | 0,27 s | passa |
| Urna de óleo (RP-12) | 1,0 s, aro 2,5 m | 2,5 m (0,37 s) | -0,08 s | **P0: 1,3 s** (0,22 s) |
| Pedras (RP-20) | 1,2 s | 1,0 m | 0,34 s | passa |
| Nicho (AT-H2) | 0,3 + 1,0 s | 1,1 m (0,16 s) | 0,13 s | **P0: aviso 1,2 s** (0,33 s) |
| Planta (AT-H3) | 0,5 + 1,2 s | até 0,75 m | 0,38 s | passa com faixa até 1,5 m |

Condições:
- **P0** os três avisos acima (Laje, Urna, Nicho) antes de o 10 entrar nessas peças. Subir o aviso não deixa mais fácil
  na média (quem não reage leva 10 em vez de 7); só tira o golpe sem saída.
- **P1** perigo sobre ferida: no registro de gente (`hurt_ctx`), pares "inimigo e perigo a menos de 2 s um do outro"
  até 1 a cada 10 salas; acima disso o perigo arma 0,3 s depois do fim da proteção de 1,3 s quando o herói está nele
  (regra do `Ground`, sem mudar o aviso).
- **P1** Compatibility (R12) e som (R5) em todo perigo antes do exe: com 10, o perigo que não se ouve nem se lê fora do
  Forward+ é o mais caro da sala.
- **P1** a soma da sala: dano de perigos no herói por sala com o robô até 1,5 vez o de antes da troca (o 10 multiplica
  por 1,43 sozinho; mais que isso é colocação, não número); o `balance-designer` confere com o Lote B.
- **P2** teste com gente obrigatório antes de qualquer subida além de 10: a janela de 0,27 s das Runas e da Raiz é a
  mesma que eu já marquei como "apertado para 10" na seção 7.

### 9.5 Sobreposição com avisos de inimigos (todas as salas com perigo)

- [D] Avisos de sala em âmbar com `render_priority` -1 e os dos inimigos em vermelho por cima, segunda passada sem somar
  (stencil 2). Critério: em toda captura de cruzamento (R8) o vermelho é o mais saturado e o mais claro na área comum.
- O pior momento a medir em cada sala: herói dentro de um perigo armado, um atirador preparando e um corpo a corpo no
  bote. Nesse quadro: os três avisos inteiros, nenhum preenchimento acima de 0,35 somado, o herói lido (raio-x e anel).
  P1.
- Perigo e golpe de inimigo que enchem no mesmo quadro sobre o herói: a proteção de 1,3 s deixa um só ferir; o registro
  deve dizer qual (o primeiro processado), e o som do segundo não toca. P2.

### 9.6 Quebráveis (AT-Q)

O golpe que acerta um vaso tem de continuar sendo o golpe que acerta inimigo: peso, tempo e controle iguais.

- **P0 mira assistida**: o giro do golpe para o inimigo mais perto (`Player.ASSIST_*`, 5 m, 130 graus) **nunca** escolhe
  um quebrável, nem com só vasos em volta. Teste: herói entre um vaso a 1 m e um esqueleto a 4 m, golpe sem mouse vai ao
  esqueleto.
- **P0 tempo do golpe**: acertar um vaso não muda preparação, quadro do golpe, `recovery`, trava de pernas, buffer nem
  janela de emendar (sonda de sensação 41/41 com 6 vasos à volta, mesmos quadros). Golpe cortado pela esquiva não
  quebra nada (`ComboRunner.can_cancel`, como não acerta inimigo).
- **P0 corpo**: no MVP nenhum quebrável barra o herói andando, correndo, na esquiva nem no golpe; nenhum barra tiro.
- **P1 hit stop**: golpe que acerta inimigo e vaso juntos tem o hit stop do inimigo intacto (25, 65, 70, 50 ms e o
  `KILL_HOLD_MS`), nada somado, nada encurtado. Golpe que acerta **só** quebráveis: hit stop curto e fixo de 25 ms (o do
  golpe 1, lentidão do `HitStop`, nunca congelar), uma vez por golpe por mais vasos que quebre; nunca maior que o do
  golpe que o causou. Medir no `Fx.rate` pela sonda: três casos (só vaso, vaso e inimigo, só inimigo).
- **P1 o que o vaso não conta**: nenhum número de dano, nada no contador de golpes, Magia, passiva (P-A), carga da
  ultimate, Dons que leem `landed`, câmera lenta "3 de uma vez" nem quadro de impacto. Tranco de câmera no máximo o do
  golpe comum (0,09 m), vibração nenhuma.
- **P1 som**: `break_*` sai no quadro do contato do golpe com a peça (0 a +1 f), abaixo do impacto em inimigo
  (`hit`/`hit_heavy` 6 dB ou mais acima quando os dois tocam) e pela `VoiceGate` (2 vozes, 70 ms): seis vasos num giro
  soam como uma quebra cheia, não como rajada.
- **P1 cacos não tapam aviso**: cacos, poeira e água desenhados por baixo de todo aviso (de inimigo e de sala), com luma
  no máximo a do chão +20 e cinza ou cor do material, nunca âmbar, vermelho, esmeralda nem lilás; o decalque de água
  sem aro nem borda clara (não pode ler como aviso no chão). Cacos dentro de uma área que começa a avisar somem em até
  0,1 s ou ficam por baixo dela. Medida: captura com 3 quebras juntas sobre a mira do besteiro e a moldura de uma laje
  armada: fio da mira com saturação e luma iguais (até 5% a menos) às da mesma captura sem cacos.
- **P1 cacos não tapam o herói**: nenhum caco acima de 0,6 m depois de 0,15 s, nenhum sobre o corpo dele na tela
  (como as lascas de luz, `HERO_SHOULDER`); orçamento de 3 quebras cheias por quadro respeitado.
- **P1 quebra por inimigo e perigo**: o vaso quebra no quadro do dano do golpe ou do perigo, nunca no início do aviso (um
  vaso que estoura antes do golpe vira aviso falso).
- **P2 sensação**: o vaso responde no quadro do contato com um achatar de 2 a 3 f antes de estourar (o mesmo "dá e
  cede" do inimigo, sem recuo); caixote de 2 golpes mostra a rachadura no 1º. Cacos assentam no chão em até 0,4 s e
  ficam 4 s sem barrar nada.
- **P2 circulação**: AT-Q5 mede o tempo da sala vencida à porta (`clear_to_door_s`); se gente gastar mais de 5 s a mais
  quebrando, o "obrigado a quebrar tudo" é assunto do Game Director, não de cadência.

### 9.7 Como vou aprovar (próxima chamada)

Por perigo: um vídeo na GPU a 60 f fixos na Perto (`tools/movie.sh` ou `tools/gpu.sh` com `--frames=`, `--fixed-fps 60`,
sempre com `--quit-after`) com o aviso, uma reação boa e a consequência de ignorar; o log do perigo e o `--sound-log`
para R2, R3 e R5; GUT de R6, R9, R10 e R11; `frame_stats.py --hue` para R8 e R12; 8 sementes do robô para R13. Se faltar
quadro de dano no log de algum perigo novo, peço ao gameplay-engineer o mesmo registro do `Ground` que as Runas têm.
Quebráveis: sonda de sensação com vasos em volta, os três casos de hit stop no `Fx.rate`, a captura dos cacos sobre os
avisos e o teste da mira assistida.

## 10. C1d: lutas de chefe (2026-11-22, `docs/design/chefes_c1d.md`; robô headless 60 fps, `--bot-reaction=0.25`, 12 sementes, novato e evoluído)
Medidas por lote (hurt = dano médio no herói por encontro, tempo em s). Antes do C1d (partida com o C1b): Cavaleiro 72 (novato) e 52 (evoluído) s; Ancião 74 e 98 s, hurt 31,1 e 27,9.
- **Lote 2 (Cavaleiro K1 a K4)**: g1 72 s novato (0 de 5 morrem) e 52 s evoluído (1 de 5), g2 63 e 61 s. Dentro de 50 a 70 s e no máximo 3 mortes de 12.
- **Lote 3 (Ancião A2 e A3)**: hurt do Ancião evoluído 31,5 (g1, 1,13x) e 27,5 (g2, só 2 encontros); tempo 93 a 101 s (era 74 a 98, a blindagem dos servos alonga). Com `volley_life` 5 s o hurt subia a 38,1 (1,37x), por isso 4 s.
- **Lote 4 (Postura)**, `--start=boss`, robô 0,25, 12 sementes: fase 1 mediana 51 s (novato) e 39 s (evoluído, 29 a 48), 12 de 12 passam da fase 1 nos dois; quebras de Postura por luta 2 a 19 (a maioria por ataque, 14 golpes, e Investida).
- **Lote 5 (Condutores)**: ritual 15 a 20 s (antes 20 quase sempre; o robô derruba um condutor na maioria, dois em poucas), mínimo 10,4 s; nenhum estado trancou. Fase 2 mediana 53 a 58 s.
- **Lote 6 (Corte do rastro)**: maldições que pegam o herói 9 para 2 nas 12 evoluídas (o Brado leva a maldição junto; o robô cortou 1 com a onda, joga a onda só com Magia e a maldição a menos de 9 m); nenhuma morte por maldição a mais.
- **Lote 7 (Ruptura)**: 0 a 2 por luta (a primeira 12 s dentro da fase 4, depois a cada 25 s; nunca duas em menos de 25 s); a fase 4 dura 17 a 58 s.
- **Lote 8 (ajuste)**: Postura 900 para 1300 e vulnerabilidade x1,4 para x1,3 (as lutas ganhas duravam 111 a 144 s); depois: ganhas de 132 e 183 s (só 2 de 12), fases medianas 39 / 55 (com o ritual) / 25 / 19 s: **a luta ainda não chega a 2:40 a 3:00 na maioria** (o dano do robô evoluído é de uns 50 de vida de Morvath por segundo, 6050 de vida pedem uns 120 s mais 15 s de ritual sem dano; chegar lá pede mais vida ou menos dano, decisão do Daniel/balance-designer). Teclas: partida inteira com todas as teclas, evoluído chega a Morvath 6 de 12 (novato 0, morre no Ancião como antes do C1d); só mouse (`--bot-mouse`) chega 1 de 12 (aceite: no máximo metade, ok). Ataque 51% do dano do evoluído, 69 a 75% só mouse.
