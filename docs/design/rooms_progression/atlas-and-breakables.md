> Índice: [rooms_progression.md](../rooms_progression.md)

## Lote A, frente A1 (2026-11-21)

Pedido do Daniel (o jogo tem de ficar mais difícil) e critérios do combat-feel-director em `combat_cadence.md` 9.2 a
9.4 (R1 a R14). Tudo em dado no `_stage` do `make_data.gd`; nomes e chaves de "Derrotado por" provisórios, para o Daniel.

### 1. O que mudou

| Item | O que é | Onde e quando | Números |
|---|---|---|---|
| Dano 10 | todo perigo de sala tira 10 do herói (era 7; o Hades II tira 10 sobre os mesmos 30) | Runas, Lajes, Corrente, Raiz, Seteira, e os novos | herói 10, inimigo 60; borda que desmorona 7 (era 5) |
| P0 com o 10 | aviso da Laje Rachada 1,2 s (era 1,0); a raiz segue 1,2 s; a urna 1,3 s com aro de 2,5 m | todas as lajes | |
| R9 | no máximo dois avisos de sala no chão ao mesmo tempo, contando os dois perigos da sala | `PlateHazard.MOST_AT_ONCE` 2 (era 3), `Ground.room_live` | |
| Dois perigos numa sala | `HazardDef.also` | Santuário B (lajes + pedras), Fendas B (fôlego + pedras), Cripta A (lajes + urnas) | `rooms[].hazard.also` no `RESULT` |
| RP-14 Cristal Instável | três golpes do herói num cristal o descarregam pela coluna de ladrilhos dele (o cubo de vapor do Hades II, perigo que o jogador usa) | Runas B (meio da descida em diante), dois cristais na parede norte, colunas 3 e 8 | aviso 1,2 s, 10 / 60; da 2ª carga a coluna clareia em repouso |
| RP-20 Pedras da Abóbada | quadrados de 2 m caem da abóbada rasgada, metade mirada nele | Santuário B (nave em volta do buraco), Fendas B (plataforma leste), desde a sala 4 | aviso 1,2 s, uma a cada 4 s, no máximo duas, 10 / 60; entulho só desenhado |
| RP-12 Urna de Óleo | o golpe acende; o aro explode e o óleo corre pelo canal | Cripta A, desde dois terços da descida, duas urnas (leste e norte) | aro 2,5 m, 1,3 s, 10 / 80; óleo 3 m/s em trechos de 2 m avisados 1,0 s, 5 / 40, arde 2 s |
| RP-18 Colunata | o leste da nave vira grade de nove colunas de 2,5 m (duas em toco, uma rachada); o oeste fica aberto para a investida | Santuário C, do meio da descida em diante | colunas de 2,5 m (nunca escondem um preparo) |
| RP-19 Portas no fundo | teste em toda sala e variante: porta a 8 m da entrada, fora dos nascimentos, 5 m das outras | `tests/test_exits.gd` | todas já passavam; nenhuma porta mudou |

Regras comuns, todas testadas: aviso de 1,0 s ou mais com o alcance inteiro desenhado desde o primeiro quadro; o dano
no quadro em que o aviso enche; fere inimigos também; nada nos 3 primeiros segundos nem a menos de 6 m da entrada nem
em porta; saída livre (pedras: de dentro de qualquer quadrado um passo de 1,6 m chega a chão fora de toda pedra; óleo:
um passo de 1,5 m de lado; cristal: a coluna tem 3 m de largura e chão apagado dos dois lados); nenhum empurrão novo.

### 2. Medidas do robô (16 descidas, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 16)

Descida inteira: 9 vitórias em 16, 14 em Morvath, `stuck` 0 (a queda de vitórias não vem dos perigos: eles tiraram
20 de vida do robô nas 16 descidas, um golpe da Corrente e um das Runas). Por perigo, salas em que apareceu e soma:

| Perigo | Salas | Dano no robô | Dano nos inimigos | Abates | Golpes |
|---|---|---|---|---|---|
| Runas A | 8 | 10 | 1998 | 22 | 54 |
| Runas B (com cristais) | 11 | 0 | 1959 | 25 | 58; cristal carregado 3 vezes, nenhuma descarga |
| Laje Rachada | 40 | 0 | 528 | 3 | 59 |
| Pedras da Abóbada | 16 | 0 | 330 | 5 | 93 |
| Corrente da Ponte | 13 | 10 | 466 | 4 | 50 |
| Raiz Morta | 18 | 0 | 0 | 0 | 2 |
| Urna de Óleo | 4 (tardia) | 0 | 0 | 0 | 2 acesas, 2 explosões, sem inimigo perto |

Primeira sala em cada sala nova ou mudada (`--arena=... --variant=n`, 8 sementes, `smoke 150`): `stuck` 0 nas 40.
Santuário C: o herói passa 30% do tempo na colunata (53 s de 175), 31% na nave, 38% nas naves laterais; a sala dura em
média 26,7 s contra 21,4 s da B. `fit_probe` do Santuário C: fantasma 1,20 m², peça sem desenho 0 (a A tem 0,17).

### 3. Riscos

- O robô desvia de todo aviso do chão (lê o `Ground`), então quase não leva dano dos perigos: o que eles tiram de gente
  só se mede com gente. O robô também quase nunca carrega um cristal (bate nos inimigos, não no cristal) e acende urna
  só por acaso: o uso a favor é para o jogador e não aparece nas métricas do robô.
- A urna bloqueia corpo (0,45 m) a 0,35 m da parede leste: um inimigo não passa atrás dela (o `NavGrid` contorna).
- As lajes emolduradas desenhadas do Santuário (SW-S3) ficam na nave; na C a grade de colunas fica no mesmo trecho
  (só desenho, nada colide, mas o environment-artist pode querer tirá-las da C).

### 4. O que precisa de arte (`environment-artist` com a spec do `art-director`)

- Cristal: peça de cristal fora do chão, junto da parede norte das Runas B (x -4,5 e 10,5), três estados de carga
  (0, 1, 2) lidos sem olhar para ele (brilho que sobe, rachaduras), a descarga como um raio que corre a coluna para o
  sul no tempo do aviso; hoje é uma laje de 1,6 x 0,8 m no chão diante dele (`GroundLook.plate`).
- Pedras: a sombra que cresce no quadrado (hoje o âmbar das Runas), poeira caindo do alto desde o primeiro quadro, a
  pedra caindo nos últimos 0,25 s, o entulho baixo que some em 3 s (hoje uma caixa cinza), o rasgo na abóbada sobre as
  zonas (Santuário B já tem a abóbada rasgada do Lote B; as Fendas B não).
- Urna: bronze, pavio que se vê, silhueta que nunca lembre um quebrável; o pavio aceso com a chama no aro; o canal de
  óleo no chão (sulco escuro) e a chama correndo; hoje a urna é um cilindro genérico e o óleo a faixa âmbar.
- Colunata: nove colunas baixas de 2,5 m, dois tocos e a rachada de 2,5 m que tomba 3 m.

## Lote D, protótipos do atlas e quebráveis (2026-11-21)

Pedido: AT-H1 a AT-H3 (backlog, "Pacotes do PO de 2026-11-20", P.4) com Q-AT3 (a), dano e puxão de 1 m sem prender, e
Q-AT4 (a), só os três, com o nicho a partir da sala 4; depois AT-Q4, os quebráveis de toda sala. Critérios da 9.3 do
`combat_cadence.md` e forma do `sw_g7_hazard_grammar.md`. Visual em placeholder.

### 1. O que mudou
- **AT-H1, laje de pressão do Santuário**: é o RP-06 sem mudança de número. A isca já existe (todo inimigo que pisa arma,
  `armed_by_enemy`); conferido que cada laje das naves tem uma faixa de 1 m livre ao lado em toda a extensão (teste
  `test_the_santuario_slabs_have_a_way_round`). O robô não atrai ninguém de propósito: um `Bot.lure_plan` (levar o bando
  por cima da laje e sair pelo lado) é do gameplay-engineer.
- **AT-H2, Esqueleto do Nicho (Cripta B)**: faixa de 2,2 x 2,2 m diante de um nicho da parede oeste em (-12; -6,5), fora das
  faixas das seteiras, 1,5 m ou mais das lajes e 6 m da entrada, no `hazard.also` da B, desde a sala 4. Acorda com o herói
  0,3 s em cima (inimigo 0,2), 1,2 s de aviso, agarra 0,25 s, 10 no herói e 60 no inimigo, puxa 1 m para o nicho em 0,12 s
  quadro a quadro (nunca um salto, nunca para dentro de outro aviso nem da pedra, R10; a esquiva corta e o herói nunca fica
  preso), recarga 6 s. Golpe da Emeth nele só faísca (não é inimigo: a mira assistida nunca o escolhe). O grupo de
  quebráveis que ficava ali foi para o pé do sarcófago noroeste.
- **AT-H3, Planta Hostil (Jardim B)**: no lugar da raiz do toco junto da parede oeste (as raízes da B ficam com uma), faixa
  de 2,5 x 1,5 m de (-16,6; -1,5) para o leste, a raiz com pele nova: 0,5 s (inimigo 0,2), 1,2 s, 10 / 60, empurrão de 1 m
  para fora da faixa, 6 s. Lado de fuga de 0,75 m no máximo. A Emeth só faísca.
- **AT-Q4, quebráveis**: todas as salas e variantes além do Salão e das Criptas, a Provação e o Altar, de 7 a 10 peças em
  3 ou 4 grupos de 2 ou 3, nos cantos e encostados em parede ou peça, com os materiais do bioma da spec AT-Q0; Salão com o
  grupo oeste encostado na balaustrada (ficava 1,8 m dela). Teste em `test_arenas.gd` para toda vista, variante e câmara
  de evento: 1,5 m ou mais de porta, marca da porta, entrada, recompensa, nascimento, ponto de uso, guardião e toda laje
  ou faixa de perigo (também do `also`). `fit_probe` igual (os quebráveis não são `ArenaObstacle`).

### 2. Medidas do robô (12 descidas, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 12)
- 11 de 12 chegam em Morvath, 8 vitórias, `stuck` 0.
- Santuário (24 salas nas três variantes): lajes golpearam 35 vezes, armadas 20 pelo herói e 15 por inimigos, 457 de
  dano em inimigos; herói 0 de dano (ele sai de todas).
- Cripta B (7 salas): o nicho nunca acordou (o robô e os inimigos não param no canto oeste); 7 faíscas de golpes nele.
  Jardim B (8 salas): a planta e a raiz nunca acordaram.
- Quebráveis quebrados por sala de 0 (Altar, Jardim A) a 73% (Runas, sala pequena e cheia); Salão 3%, Santuário 4 a 12%.

### 3. Riscos
- O nicho e a planta ficam em cantos: com o robô não acordam. É escolha (Q-AT4: protótipo, o jogador decide se usa), mas
  se gente também não passa por ali eles não contam como perigo; medir no teste com gente antes de mover para a luta.
- O puxão do nicho em inimigos é um empurrão instantâneo de 1 m (o do herói é gradual).

### 4. O que precisa de arte
- Esqueleto do Nicho: a mão e o braço saindo do nicho, preparo de 1,2 s, o agarrão e a volta (SW-G7 3.5); hoje a moldura
  de laje ao longo da faixa e a faísca.
- Planta Hostil: escura, alta e pontuda sobre laje com divisa, folhas fechando no aviso e o chicote (SW-G7 3.5 e AT-Q0 2.4,
  contra a muda frágil).
- Quebráveis: as peças por material (AT-Q2) e os sons (AT-Q3).

## Lote D, hipóteses de planta do atlas (AT-CA2, AT-SE2, AT-PB2, AT-FO2) e decisões de movimento (2026-11-21)

Medidas com o robô (`smoke 900 --bot-reaction=0.25 --ultimate=cleave`): 12 descidas inteiras (sementes 1 a 12) e 8
começando em cada sala tocada (`--arena=crypt --variant=0`, `--arena=bridge --variant=1`, `--arena=sanctuary
--variant=1`, sementes 1 a 8). Contador novo por sala: `rooms[].dodge_blocked_by` (esquiva cortada pela pedra ou pela
borda, uma vez por esquiva; `Player.dodge_blocked`, `Arena.blocker_at` dá `peça@x,z` da planta ou `edge`,
`RoomTally.dodge_blocked`).

| Hipótese | Medida | Decisão |
|---|---|---|
| **AT-CA2**, Cripta A: esquivas barradas pelo sarcófago e pela mureta | 12 salas, 48 esquivas: túmulo grande (1; 0) 3 e mureta (-3,5..2; 3,8) 4, juntos 7 de 48 (15%, abaixo de 1 em 6); cobertura secundária: sarcófago sul (4; 5,6) 5 e cápsula leste (8..12; 0,5) 4 (19%); borda 8. Esquivas cortadas na sala 54%, a mais alta das salas de luta fora da Ponte B (Salão 12%, Santuário 17 a 29%, Jardim 18 a 33%) | Nada muda: a regra pede mexer só acima de 1 em 6 perto do túmulo. Se o teste com gente subir, o primeiro passo é levar o sarcófago sul e a cápsula leste 1 m para a borda, não aumentar a sala |
| **AT-SE2**, Santuário B: respiro nas bocas do desvio do buraco | 11 salas: tempo na borda do buraco 7%, nave 47%, naves laterais 46%; esquivas cortadas 28% (borda 9 de 64, colunas 7, bancos 2); `fit_probe` sem peça sem desenho (`bare` 0) | Sem colisão nova (nem a medida nem o `fit_probe` mostram aperto). O respiro visual nas bocas e a borda decorativa separada das lajes ficam para o environment-artist (AT-SE1) |
| **AT-PB2**, Ponte B: patamar como recuperação sob fogo | 11 salas: herói 21% do tempo no patamar (o 2º lugar depois da plataforma leste), 2 golpes levados na sala inteira; esquivas cortadas 53%, quase todas pela borda (33 de 37) | O alargamento que existe basta; nada novo. As esquivas cortadas na borda são o preço das pontes sem queda (D-28) |
| **AT-FO2**, Fonte (e Loja) no Salão: descoberta na chegada | No ponto de antes (0; -2) a Fonte ficava fora da tela das duas câmeras na chegada pelo patamar sudoeste (Perto x 1,49, Longe 1,11 da tela), com a luz dela junto: luz e placa não podiam bastar | A Fonte nasce em `Rooms.FOUNTAIN_SPOT` (-8; 10): Perto 0,72 / 0,49 e Longe 0,55 / 0,51 da tela na chegada, 8,9 m dele e no caminho das portas, 5 m ou mais de todo quebrável (AT-FO3). Mapa igual. A Loja já mostra a fileira na chegada (`docs/gallery/e3/ui/shop_real_*`); nada muda nela |

Decisões de movimento da P.2 que são dado de sala: além das quatro acima, todas dizem "nada muda" (AT-SA2, CB2, FA2,
FB2, JA2, JB2, SD2, PA2, RA2, RB2, GU2, PR2, AL2, CS2) e as medidas confirmam: Cripta B passagem sul 50% do tempo do
herói, Fendas A e B leste 61 a 66% com a volta pelo sul 6%, Jardim A leste 69%, Runas A borda 51%. O aceite do AT-SA2
(1º aviso inteiro na tela da Perto em 8 de 8 sementes) pede captura, não dado.

## Atlas, colunas 2 e 3: regras dos quebráveis por sala, Câmara do Selo, AT-SA2 e AT-RB2 (2026-11-21)

Regras de cada sala que o teste geral não pegava, agora em `tests/test_breakable_rules.gd`:

- **Fendas e Ponte (AT-FA3, FB3, PA3, PB3)**: nenhum quebrável no tabuleiro. Nas Fendas a regra é `RiftLook.BRIDGES`
  com 0,5 m de folga além do raio; na Ponte, os tabuleiros que o `BridgeLook` lê (polígono de 4 cantos até
  `DECK_WIDE`). Na Ponte também vale ficar a 2,5 m ou mais da linha das pontes, e no patamar da B só na borda. O
  caixote do grupo oeste da Ponte estava a 2,2 m da linha: o grupo foi para (-27,5; 3 a 3,8), longe também do
  nascimento tardio.
- **Jardim B (AT-JB3)**: os vasos de água ficam a até 2 m da borda oeste, a borda úmida do lago J5. Pelo menos dois.
- **Runas (AT-RA3, RB3)**: o círculo do quebrável nunca toca ladrilho que arma (`ArenaHazard.live`, com as portas que o
  `RuneFloor` passa). Na B ficam a 3 m ou mais da pedra quieta. Achado: dois dos três grupos estavam sobre ladrilhos
  vivos, no canto nordeste e junto da parede norte. Só o chão quieto da entrada (`RUNES_ENTRY`) e os cantos cortados não
  armam, então os três grupos foram para a entrada: parede oeste em z -2,4, canto sudoeste e parede sul a oeste da porta.
- **Guardião (AT-GU3)**: em toda variante do Santuário, 4 m ou mais da linha entre o `boss_spawn` e a entrada do herói,
  e sempre na periferia (a mais de 2,5 m do chão para dentro não). Já passava.
- **Loja (AT-LO3)**: 3 m ou mais de todo relicário, com 1 a 5 itens na fileira do `Rooms._build_shop`: a de rota tem
  3, a última 5. Já passava.

**Câmara do Selo (AT-CS3)**. Oito peças de cerâmica em três grupos, no `_place_breakables`, que agora roda depois do
`boss_layout`:

- no patamar da escada sul (rumo 203 a 211, ao lado da entrada);
- na borda a noroeste e a nordeste, de 11 a 12 m do selo, na metade longe da câmera (fora do arco da frente, cuja pedra
  abre em volta dele);
- além do anel do ritual (6,5 m) e das runas dele, e longe do vão da porta.

As faixas da Tempestade saem em qualquer direção, então nenhuma borda fica fora delas. Os golpes e avisos de Morvath
quebram as peças (`Ground.zone_landed`).

O `test_boss_exits` foi refeito. Com as peças inteiras, cada uma é tratada como pedra sólida: os padrões e as camadas
precisam ter saída sem passar por elas, e ninguém começa dentro de uma. Isso é mais duro que o jogo, onde elas não
param nada. Com as peças quebradas fica só o chão, que são os testes de antes. Numa câmara de verdade
(`Game.rebuild_room`), inteiras e quebradas, cada ponto delas é chão livre e a varredura do herói atravessa. Em 15
testes, todos com saída.

**AT-SA2**. `tools/first_warning.gd` joga a primeira sala com o robô e mede onde o contorno do primeiro aviso de inimigo
cai na tela, no quadro em que ele aparece:

| Câmera | Sementes | Aviso inteiro | Faixa na tela |
|---|---|---|---|
| Perto | 1 a 8 | 8 de 8 | x 0,31 a 0,62, y 0,40 a 0,71 |
| Longe | 1 a 8 | 8 de 8 | x 0,27 a 0,58, y 0,47 a 0,65 |

O primeiro aviso é do esqueleto em 7 sementes e do Escudo em 1, aos 3,3 a 10,9 s. O mais baixo é o Escudo da semente 2
na Perto, que vai a 0,71 da altura, acima da fileira do HUD.

**AT-RB2**. O `RESULT` das Runas traz agora `rooms[].hazard.patterns`, com até 16 entradas
`[segundo da sala, padrão, ladrilhos acesos]`. O ciclo medido é de 3,87 s: 1,2 s de aviso, 0,25 s de golpe e 2,4 s de
descanso.

| Semente | Padrões |
|---|---|
| 5 | 8 de 9 `islands` (7 a 14 ladrilhos), 1 `frame` |
| 1 | `frame`, 3 `islands`, 2 `checker` |
| 2 | 2 `frame`, 1 `checker` |

Quando há mais de 3 inimigos de pé, o `checker` (o único denso da B) não sai e o sorteio fica entre `frame` e
`islands`. Com a sala cheia a B pode ficar quase só em ilhas, como na semente 5. É número (`dense_standing`, `DENSE`),
fica para o balance-designer se a medida com gente pedir. A captura do ciclo
na GPU (semente 1, estilizado) está no relatório da entrega.
