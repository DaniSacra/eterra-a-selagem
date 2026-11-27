> Índice: [rooms_progression.md](../rooms_progression.md)

# Progressão das salas (room-designer)

Plano de progressão das salas da descida: a ideia de jogo de cada arena, tamanho, perigos, em que profundidade aparece,
como evolui e as métricas do robô que provam que ela joga diferente. Base das medidas de forma e de exposição:
`docs/design/room_redesign_level_review.md` (seções 0 e 1). Plantas: `_stage` do `tools/make_data.gd`.

## Estado em 2026-11-19 (o que existe)

| Sala | Tamanho, andável | Ideia de jogo (a pergunta da sala) | Profundidade (progresso) | Teto de pé | Perigo |
|---|---|---|---|---|---|
| Salão das Catacumbas | 32 x 30 m, cerca de 900 m² | abertura no claro; também fonte e loja | 1, 5 a 8 (fonte), 10 | 4 a 8 | nenhum |
| Cripta A | 24 x 21 m, 498 m² | cobertura: contornar o sarcófago do meio contra até 2 atiradores | 0,1 a 1,0 | 4 a 6, sem sacerdote | quatro lajes rachadas junto das paredes (RP-06), dormentes nas salas 2 e 3 |
| Cripta B (Ossuário) | igual | de que lado do muro divisor | igual | igual | duas lajes no pé do muro (RP-06) |
| Fendas A | 42 x 30 m, cerca de 1060 m² | em que ponte cruzar, ou dar a volta pelo sul; três tocos de apoio (RP-05) | 0,1 a 1,0 | 6 a 8 | nenhum |
| Fendas B | igual, ponte norte caída | uma ponte só e a volta sul | igual | igual | nenhum |
| Jardim A / B | 34 x 28 m, 875 m² | o tronco como escudo, raízes que cortam o passo | 0,1 a 1,0 | 6 a 8 | nenhum |
| Santuário A | 44 x 28 m, 1192 m² | nave aberta ou naves laterais (casa do guardião) | 0,4 a 1,0; guardião em qualquer uma | 6 a 8 | duas lajes em cada nave lateral (RP-06), também no guardião |
| Santuário B | igual, buraco na nave | o buraco entre o herói e o guardião | igual | igual | as lajes das laterais e a borda que desmorona nas pontas do buraco (RP-13) |
| Ponte A | 56 x 18 m, 771 m² | atravessar sob fogo: todos nascem no leste, bloco no fim da ponte 2 (RP-04) | 0,5 a 1,0 | 6 a 8, sem sacerdote | nenhum |
| Ponte B | 56 x 18 m, 701 m² | a ponte longa com patamar | igual | igual | nenhum |
| Runas A | 30 x 24 m, 702 m² | atrair os inimigos para a faixa que vai acender | 0,5 a 1,0 | 4 a 6 | faixas (sweep, comb, cut); herói 7, inimigos 60, nada a 6 m da entrada (RP-02, RP-03) |
| Runas B | igual | ilhas e a pedra quieta | igual | igual | ladrilhos (checker, frame, islands); idem |
| Provação, Altar | 16 x 14, 18 x 14 m | escolha sem luta | 2 a 7, 2 a 8 | sem luta | nenhum |
| Câmara do Selo | círculo de 12,5 m | Morvath | 11 | Morvath + até 6 | os ataques dele |

---

## Fase 2 SWORN, ritmo das salas e da descida (2026-11-25; `room-designer`; SW-R1 a SW-R3)

Referência: Kingswood (`docs/design/sworn_rea_kingswood_2026-11-25.md` 3.1 e 3.2): orçamento 4 na sala 0, 8 na 5, 6 logo depois do minichefe,
11 do fim em diante; pequeno 1, comum 3, pesado 5, capitão 10; combate comum 50% ondas (uma de 1,0 ou duas de 0,75) e 50% horda (0,75 + 0,75);
sala 2 com Bênção garantida e a 6 minichefe. Código e dados: `docs/reference/rooms.md` (Fase 2 do Plano SWORN).

**A nossa escala.** O custo de uma cabeça (`EnemyDef.cost`): Rato de osso 1; comuns 3 (Soldado, Corredor, Saltador, Lançador, Gritador, Coveiro,
Armadilheiro); atiradores 4 (Maga, Besteiro); pesados 5 (Escudeiro, Sacerdote, Trinca, Varredor, Canalizador); elites o dobro do tipo (6 a 12);
maiores 8 e 9; Capitão 12 (o de SWORN é 10, o nosso tem 5,5 vezes a vida). O orçamento é o de UMA onda inteira, e o que um custo vale em segundos
cresce com a profundidade (as elites e os pesados entram, a vida dos comuns é 1,6 vezes a de antes), por isso a nossa curva não é a de SWORN
multiplicada: a forma é a dele (sobe até o guardião, cai na sala depois, sobe de novo) e os números saíram do tempo medido no robô.

| Sala | SWORN | Nossa curva (custo de uma onda) | Tempo de luta no robô, antes | depois (n) | Vida ao entrar, antes | depois |
|---|---|---|---|---|---|---|
| 1 | 4 | 20 | 32 s | 29 s (6) | 40 | 40 |
| 2 | 5,3 | 28 | 37 | 31 (6) | 38 | 38 |
| 3 | 6,7 | 30 | 44 | 36 (6) | 34 | 38 |
| 4 | 8 | 34 | 32 (3) | 44 (5) | 33 | 40 |
| 5 guardião | 8 | (a luta de guardião de sempre) | 55 | 55 | 37 | 46 |
| 6 respiro | 6 | 14 | 63 | 33 (3) | 31 | 44 |
| 7 | 6,5 | 18 | 56 | 43 (6) | 27 | 46 |
| 8 | 7 | 21 | 75 | 54 (5) | 29 | 46 |
| 9 | 8,5 | 27 | 41 (1) | 51 (4) | 32 | 42 |
| 10 guardião | | (idem) | 61 | 61 | 44 | 43 |
| 11 respiro | 9 | 20 | 53 (4) | 62 (2) | 41 | 35 |
| 12 | 11 | 22 | 32 (4) | 45 (6) | 38 | 46 |
(Robô, `smoke 900`, sementes 1 a 6, só as salas de luta com 3 cabeças ou mais; n entre parênteses; a sala 11 tem poucas porque o robô toma a fonte.)
Média de luta por sala 47,8 s antes (66% das salas entre 25 e 55 s) e 41,3 s depois (76% entre 25 e 55 s). Por modo: uma onda 28 s, duas ondas 40 s,
horda 46 s. Chegada em Morvath: 4 de 6 antes, 5 de 6 depois (a semente 6 morreu na sala 12); `stuck` 0 nas duas.

**O respiro.** A sala 6 pede 14 de orçamento contra 34 da 4 e 27 da 9 (a 11 pede 20): a luta mais leve da descida vem logo depois de cada guardião,
e uma das duas portas da sala 6 e da 11 é uma fonte (SW-R2). Vida do robô ao entrar na sala 6: 31 antes, 44 depois.

**Salas âncora (SW-R2).** Guardiões nas salas 5 e 10; loja na 13; Bênção na 1 e na 2; Coração na outra porta da 2; Romã e Magia na 7; Bênção
e Ouro na 11; descanso (fonte) em uma porta da 6 e da 11. O resto sai do baralho como sempre. O teste (`test_sw_r.gd`, 300 descidas) trava tudo.
Risco: 4 fontes possíveis num caminho (eram 2); a cura sobe se o jogador as tomar todas. Se o equilíbrio pedir, o descanso pode ganhar cura própria
(`fountain_heal` menor) sem código novo no mapa.

**Zonas mortas (SW-R3).** Fendas e Santuário sorteiam a zona de nascimento mais longe do herói (`far_spawn` 1,5). Fendas, herói na plataforma leste:
167 de 300 cabeças sobem a oeste do vão contra 83 sem o peso (`test_sw_r.gd`). O tempo do herói por zona no robô quase não mudou nas Fendas
(leste 82% antes, 77% depois, o herói luta onde os inimigos chegam; a meta de 60% **não** foi atingida, o que puxa o herói para o oeste é ouro e
quebráveis nos cantos, que ficam com o `environment-artist`/AT-Q2). Santuário: as duas naves laterais, que antes eram uma zona só (`aisles` 61 a 65%),
viraram `aisle_n` e `aisle_s`: nave 36%, naves 30% e 26%, colunata 6%, nenhuma acima de 60%; as de borda juntas passam de 15%.

## Salas dos guardiões (2026-11-23, room-designer; pedido do Daniel)
Pedido: as salas dos minichefes menores, para dificultar a escapada; Cavaleiro em sala quadrada com perigo nos quatro cantos (coisas caindo
e laje que sobe espinhos); Ancião em sala quadrada com só quatro colunas para o herói se esconder das bolinhas.

| Sala | Ideia | Tamanho | Perigos | Aparece | Prova no robô |
|---|---|---|---|---|---|
| Salão do Cavaleiro (`knight_hall`) | fugir da investida sem cair nos cantos | 22 x 22 m (era 44 x 28) | pedras da abóboda (4 zonas) e 4 lajes de espinhos, uma por canto | casa do Cavaleiro, 1o ou 2o guardião | a luta passa dos cantos (`corner_*` em `zones`), as lajes ferem o Cavaleiro (`plates_enemy` no `hazard`) |
| Câmara do Ancião (`elder_hall`) | esconder-se atrás de uma coluna das orbes | 24 x 24 m | nenhum; 4 colunas (barram corpo e tiro) | casa do Ancião, 1o ou 2o guardião | tempo em `columns` vs `walls`, dano do Ancião |

- Aviso e dano como as outras salas: pedras 1,2 s, lajes 1,2 s, 10 no herói e 60 no inimigo; no máximo dois avisos de sala juntos (R9, a conta é
  a de `Ground.room_live`), nada a menos de 6 m da entrada, uma saída livre de cada laje andando antes do golpe (teste).
- Recebem o segundo guardião e a escolta (dois magos do Cavaleiro, um guarda do Ancião): `max_alive` (6, 8) cabe.

### Medida (robô, `--start=miniboss --smoke=300`, 12 sementes, sem `--bot-reaction`; novato / evoluído `--boons=4 --forge=2 --account=6`)
| Guardião | Vitórias | Tempo da luta (média, min a max) | Dano no herói por fonte (média por partida) | Perigos nos inimigos |
|---|---|---|---|---|
| Cavaleiro novato | 12 de 12 | 65,8 s (48 a 91) | cavaleiro 9,0; esqueleto 0,8 | lajes 27,9; pedras 15,4 |
| Cavaleiro evoluído | 12 de 12 | 42,1 s (27 a 61) | esqueleto 0,4 | lajes 25,8 |
| Ancião novato | 7 de 12 | 142,3 s (68 a 235) | ancião 22,5; esqueleto 1,2 | nenhum |
| Ancião evoluído | 12 de 12 | 87,6 s (58 a 130) | ancião 9,8; esqueleto 1,8 | nenhum |
Com `--bot-reaction=0.25` (8 sementes, novato): Cavaleiro 8 de 8, 58,7 s, dano dele 2,2; Ancião 2 de 8, 90,7 s, dano dele 25,0. Nenhum `stuck`.
O robô quase não pisa em laje nem fica sob pedra (0 de dano de perigo no herói); quem sofre é o Cavaleiro, que investe por cima das lajes.
Quem pagar o Cavaleiro mais caro deve mexer em `HOUSE_FROM`, no tempo entre pedras (`drop_every` 4 s) ou no tamanho das zonas, não no aviso.


## Lote R6 (2026-11-24): Ancião novato e laje de aprender (BL-01, RD-02)
- Ancião (`--start=miniboss --guardian=priest_elder`, 12 sementes, novato, sem Maestria). Sem `--bot-reaction`: 12 de 12 vencem, luta 85 s
  (64 a 112), dano levado 18 em média (soma de `hurt_by`), então a medida antiga de 7 de 12 já está vencida pela câmara nova. Com
  `--bot-reaction=0.6`: 5 de 12.
  Escada tentada com R 0,6: colunas a 8 m em vez de 9 m (5 de 12, sem ganho; desfeito); `max_alive` da câmara de (6, 8) para (3, 5)
  (resultado idêntico, a escolta não depende dele; desfeito); `attack_damage` das orbes do Ancião 5 para 4 (x0,8): **9 de 12**,
  luta 61 a 96 s, dano do Ancião 8 a 34 (média 22); dano de contato 9 para 7 sem efeito (desfeito); chamado dos arqueiros mais
  espaçado (14 a 18 s): 8 de 12, pior (desfeito). Ficou só o x0,8 nas orbes. Falta 1 vitória para os 10 de 12 em R 0,6; o resto do
  dano vem dos arqueiros chamados (comuns, 4 a 20 por luta), que não foram tocados.
- Laje da Cripta A: acorda desde a fração 0,15 (3a sala da descida) com aviso 1,5 s, 10 no herói e 60 no inimigo (`TEACH_FROM`,
  `TEACH_WARN`); a Cripta B e as outras lajes seguem em 0,34 com 1,2 s. R 0,6, 12 sementes, até a sala 4: a Cripta aparece em 6
  descidas (metade na variante B, dormindo), 3 delas com a laje acordada, uma com 3 golpes sem acertar inimigo, dano ao herói 0.
  O aceite (8 de 12 com golpe em inimigo) não é atingido: a Cripta sai pouco até a sala 4. Próximo passo se importar: lajes de aprender
  na variante B também, ou em outra sala do início.

## Lote R7 (2026-11-24): arqueiros chamados, laje de aprender em mais salas, Provação com vida (BL-01, RD-02, BL-03)
- Ancião: campo novo `EnemyDef.raise_damage` (escala do dano de quem ele chama; `Enemy.dmg_scale`, lido em `Horde._out`), 0,6 no
  Ancião (`make_data.gd`); arqueiros comuns intocados (teste em `test_c1d_elder`). R 0,6, 12 sementes `--start=miniboss`:
  antes (orbes x0,8) 9 de 12, dano 22 do Ancião + 7 de arqueiros; depois 12 de 12 sobrevivem à sala, luta 63 a 102 s (média 85),
  dano levado 31 em média (arqueiros 7, Ancião 24). O dano abaixo de 16 NÃO foi atingido: vem das orbes do próprio Ancião.
- Laje de aprender (`TEACH_FROM` 0,15, aviso 1,5 s): Cripta A e B (laje e grade), Fendas A (lajes que cedem, maiores) e Jardim A (uma
  laje de 5 x 5 m no campo leste). Jardim B não cabe (a sala guarda no máximo 2 PLATES) e uma grade não entra em Fendas e Jardim (uma
  LINE por sala). R 0,6, 12 sementes, até a sala 4: golpe em inimigo em 6 de 12 descidas (era 3 a 4); aceite de 8 de 12 não
  atingido; dano ao herói 0 em todas. Próximo passo: laje que arma por tempo no lugar do pisão (o bando não pisa nela sozinho).
- Provação: `StageDef.trial_min_hp_frac` 0,6; a laje não aparece com vida abaixo de 60% (`Trials.healthy`, antes de `open_at`: o
  descanso não começa) e o cartão traz a linha `trial_slab_risk`.

### R8 (2026-11-25, RD2-01 a RD2-04 e RD2-07)
- Ancião: colunas do norte em (±7,5, -2,5), fora da linha da câmera até o chefe (`ELDER_COLUMNS`); `tests/test_spawn_points.gd`
  trava que nenhuma coluna fica entre y -9 e -3 com |x| < 6 e que nenhum ponto de nascimento de nenhuma arena cai em colisão.
- Fim da sala de luta: `Rooms._warn_exits` acende as luzes de todas as portas de uma vez (dourado) com o tique `ult_ready`
  quando a última onda cai, antes do prêmio; posição das portas intacta.
- Raízes: faixa 4 m, acorda com toque de inimigo (0,05 s), aviso 1,5 s. Planta: alcance 2,5 m, 0,05 s, 1,5 s. Pedras: 2,4 m, uma a
  cada 3 s, 40% mirada no herói. O sopro das Fendas continua só empurrando (`test_breath` trava 0 de dano; o dano em inimigo
  pedido no RD2-04 (c) ficou de fora: muda a regra da sala).
- Runas: aviso 1,5 s e no máximo 30% das lajes acesas (era 1,2 s e 35%), para o dano do herói cair abaixo de 15% do da sala 7.

## Lote S (2026-11-25, room-designer): ritmo, laje por ciclo, runas do bando, investida do Cavaleiro
Medida do robô: `smoke 900 --bot-reaction=0.25`, sementes 1 a 12 (antes = árvore sem o lote, depois = final); Cavaleiro `--start=miniboss --guardian=knight --smoke=300`.

| Item | Antes | Depois | Aceite |
|---|---|---|---|
| S-3 tempo médio por sala (salas de luta, sem descanso) | 1 a 4: 27,1 s (d2 20,7); 6 a 9: 34,4 s | 1 a 4: 38,4 s (d2 35,3, d3 44,1, d4 42,9); 6 a 9: 50,8 s | 25 a 45 e 30 a 55: atingido |
| S-3 chegou em Morvath, `stuck` | 9 de 12, 0 | 8 de 12, 0 | sem `stuck`; 1 a menos chegou (as salas ficaram mais longas) |
| S-4 laje de aprender até a sala 4: descidas com golpe em inimigo | 3 de 12, 0 de dano no herói | 6 de 12, 0 de dano no herói (17 armadas pelo ciclo) | 8 de 12: **não atingido** (6) |
| S-2 runas: dano em inimigo / no herói | 3025 / 69 (12 de 12 com golpe em inimigo) | 3359 / 60 (12 de 12) | atingido já antes; o padrão `herd` só reforça |
| S-1 raiz com golpe em inimigo (salas em que aparece) | 1 de 18 | 0 de 18 (3 golpes, só 2 salas acordadas) | metade: **não atingido** |
| S-5 Cavaleiro: batidas na parede por luta | 4 a 8 | 2 a 8 (11 de 12 com 3 ou mais) | 3 ou mais: quase |
| S-5 Cavaleiro: luta (média, max) | 74,6 s (97,2) | 70,4 s (85,9) | abaixo de 90: atingido |
| S-5 Cavaleiro: laje de espinhos com golpe em inimigo | 6 de 12 (310 de dano) | 8 de 12 (545 de dano) | 6 de 12: atingido |

- **S-3**: `StageDef.long_depths` (2 a 4 e 6 a 9) força 3 ondas mais leves, a 3a com 1 elite da sala 4 em diante (a elite da sala 2 e 3 pesava
  demais: com ela e sem escalonar, 6 de 9 chegavam ao Morvath), nascimento a cada 0,45 a 0,75 s, 0,8 s entre ondas. A sala 1 (um tipo só) e as
  casas dos guardiões ficam como estavam.
- **S-4**: `HazardDef.auto_cycle/auto_near/auto_until`: a laje parada há 6 s arma sozinha com o bando a 2,5 m (aviso 1,5 s), até a sala 4. Com
  `auto_near` 4 m o resultado foi pior (4 de 12, ruído do sorteio), voltou a 2,5 m. O que falta para 8 de 12 é o bando passar pela laje.
- **S-2**: o robô já fazia as runas ferirem o bando (12 de 12); novo padrão `herd` (dois blocos 2 x 2 onde o bando está, nunca no herói) em
  duas das cinco entradas da lista de cada variante.
- **S-1**: faixa 4,8 m e aviso 1,8 s nas raízes, planta 3,2 x 3,5 m e 1,8 s. Tentei `enemy_dwell` 0,8 (acordar só com quem fica): 0 golpes em
  12 descidas, desfeito. Sem mexer no fluxo da horda (decisão) a raiz quase nunca acorda em sala funda; o que falta é a pergunta B2.
- **S-5**: lajes de espinhos coladas nas paredes (meios oeste e leste e parede sul a 6 m da entrada) onde a investida acaba; `WallMark` marca no
  chão onde a linha encontra a parede. Uma luta de 12 teve 2 batidas (a semente em que o Cavaleiro ficou longe das paredes).
- Sopro das Fendas (RD2-04c): 10 só em inimigo, 7 de 17 salas com golpe (antes 0 de 17), 8 empurrados.
- Arte: anel âmbar do `WallMark`, lajes de espinhos no chão da parede, e a marca da laje de aprender armando sozinha são placeholders.

## Antessala (SW-O3, 2026-11-25, lote 3A1; `tests/test_first_descent.gd`)

A sala da primeira descida guiada (`docs/design/onboarding_sw_o.md`): o Salão (`hall`) sem luta, a porta aberta desde a entrada, nada dado.
É a **variante 1 do `hall`** (`ante`), que nenhuma faixa da descida longa sorteia (`ArenaVariant.depth` = (-1, -1)); só o `RunMap.scripted`
a pede. A posição da faixa ficou com o dono do lote (o room-designer não escreveu), em dado (`ANTE_PLATES`, `ANTE_Z` em `tools/make_data.gd`):

| Peça | Onde (x, z em m do centro do Salão) | Regra que cumpre |
|---|---|---|
| Entrada (`arena.start`) | (-11,6; 18,1), o patamar sudoeste | |
| Porta (a do canto nordeste, `PORTAL_X` 10,5) | (10,5; -14,0), zona x 4,5 a 12,7, z -17 a -12,6 | |
| 3 lajes de 2,4 x 2,4 lado a lado | x de -1,0 a 6,2 (cortes em -1,0 / 1,4 / 3,8 / 6,2), z de -3,2 a -0,8 | no caminho natural do sul para a porta (a reta entre as duas cruza z -2 em x 2,2); 11,8 m da porta, mais de 20 m da entrada (regra do PT-6: 6 m ou mais) |
| Quebráveis do Salão (os 4 grupos do AT-Q4, sem mudança) | os mais perto: (14,3; -2,6) a 8 m da faixa, (-13,8; -6,6) a 12 m | nenhum a menos de 3 m das lajes |

- O chão do Salão é aberto (16 x 15 m): a faixa de 7,2 m não fecha o caminho. Quem não quer atravessar contorna pelo norte ou pelo sul; a
  dica de esquiva só fala das lajes a 6 m (`obj_dodge_near`) e o objetivo muda quando o herói passa da faixa (`Rooms.plates_crossed`), de qualquer jeito.
- As lajes (`HazardDef` do `_ante_variant`): aviso de 1,0 s, golpe de 0,25 s, 1,5 s de descanso e a próxima 2,5 s depois (`auto_cycle`, `auto_near` 0:
  armam sozinhas, sem ninguém em cima), acordadas desde o primeiro segundo (`from_progress` 0, `start_delay` 1,0). **Dano 0** ao herói e aos
  inimigos; só o empurrão curto (0,86 m para o sudoeste, `plate_push`) e o som. O dano 0 não manda `hit_player` (o `Ground` só acerta com `power` > 0).
- O realce de ouro do quebrável mais perto do caminho (SW-O3) não entrou: é arte (`environment-artist`); o `Rooms.ante_ctx()` já diz
  quando um vaso inteiro está a 5 m.
- O robô com `--first`: sai da Antessala em cerca de 15 s de jogo (ver `docs/reference/rooms.md`, "Primeira descida guiada").

### Antessala que ensina e o riacho (PT-25-8 e PT-25-9, 2026-11-25, E2)

- **Mudou**: as 3 lajes de aprender saíram. No lugar, um **riacho** de parede a parede (`ANTE_GAP`, x -16,5 a 16,5, z -10,6 a -8,0, 2,6 m de largura) entre a entrada
  (sudoeste, z 18,1) e a porta (nordeste, mouth z -17 a -12,6): só a esquiva (5,6 m) atravessa; andar para na margem. entre as jarras do oeste (z -6,6 e -12,4) e a 1,5 m ou mais da boca da porta, com
  espaço na margem norte para treinar Brado e Investida. Sem dano (`gap_fall` 0).
- **Ideia de jogo**: a esquiva deixa de ser uma regra no papel e vira o caminho; uma pessoa que nunca jogou só sai da sala fazendo o gesto. A porta só acende depois das dicas e da
  Bênção, então a Antessala sempre termina com a pessoa tendo usado ataque, especial, esquiva, Brado e Investida e tendo uma Bênção.
- **Regra do perigo/obstáculo reaproveitável** (E4): `RoomLayout.gaps` (retângulos de 2 a 4 m) e `gap_fall` (dano de cair, devolve à margem mais perto, nunca mata); um
  obstáculo novo com esse comportamento é só dado. Nas salas comuns será opcional (nunca a única passagem) com um quebrável ou baú do outro lado.
- **Métricas** (robô `--first`, 4 sementes: 3, 5, 7, 11): sai da Antessala em 7,7 s, primeira Bênção aos 7,2 s (era 68 s antes e 2 min de meta), `stuck` 0, chega a Morvath nas 4.
  Descida normal (sementes 5 e 9, 900 s): chega a Morvath, `stuck` 0.
- **Riscos**: texto das dicas passa de 70 caracteres (a linha de objetivo tem 380 px de base, o `ui-ux-designer` confere em 720p); os inimigos de uma sala com riacho ainda o
  atravessam andando (a E4 decide o caminho deles); a recompensa do 1 virou Ouro (a Bênção veio na Antessala), a conta de Bênçãos da guiada fica igual (4).

### Travessias opcionais, lajes 2 x 2 e inimigos contra o riacho (PT-25-9 e PT-25-10, 2026-11-25, E4)
- **Inimigos e o riacho (decidido)**: o riacho é chão que ninguém pisa. `Arena.nav` o fecha (as ilhas de caminho mudam, os nascimentos só caem do lado do herói, o `FlowField` contorna);
  `Horde` segura cada inimigo na margem (`Arena.keep_out_of_gaps`, vale também para empurrão e investida); atirador atira por cima. `Arena.nav_dash` guarda a grade aberta para o herói e o robô.
- **Santuário** (A, B, C, profundidade 0,4 a 1): uma ilha 3 x 2 m na nave, a oeste, ao redor 2 m de água; prêmio, 2 quebráveis (urna e oferenda). A pergunta: gastar uma esquiva (e a posição
  no meio do combate) por um prêmio pequeno. Custa à nave aberta cerca de 7 x 6 m de chão que os inimigos contornam. B: as pedras da abóbada saíram de cima da ilha.
- **Fendas** (A e B, profundidade 0,05 a 1): uma ilha 3,5 x 3 m colada à parede oeste, longe do combate do leste; prêmio, 2 caixotes. Nunca no caminho do robô nem da porta (as portas ficam no leste).
- Salas sem travessia por falta de canto livre (nascimento, laje, raiz, porta): Jardim, Cripta, Runas, Ponte, casas dos guardiões. O Salão (SL-01) fica com o environment-artist.
- **Laje 2 x 2**: 2,5 m de lado (4 placas de 1,25 m), mesmo centro das de antes; fere junto; aviso e dano iguais. Métrica: lajes por sala, `hazard.hero_damage` e `armed_by_*` no `RESULT` não
  mudaram de forma nas sementes 1 a 4 (a área caiu de 9 para 6,25 m2, então pisam menos).
- **Métricas** (robô, 900 s, `--bot-reaction=0.25`, sementes 1 a 4): chega a Morvath nas 4 (boss_at 449, 412, 325, 379 s), `stuck` 0. O robô não busca as ilhas (os quebráveis de lá contam 0 a
  partir dele); quem mede o prêmio é o jogador.
- **Pendências**: bolsa de ouro de verdade do outro lado (quebrável não dá ouro: gameplay-engineer); pilar com vaso (não há peça de pilar com vaso; anotado para o environment-artist, o dado já
  aceita um `ArenaObstacle` com `piece` novo); arte da água da ilha e da junta em cruz da laje (placeholder `GapFloor` e `hazard_mark`).

## Varredura 2026-11-26b (room-designer, pedido do PO: achar e corrigir o que for contido)
- **Novo teste** `tests/test_room_sweep.gd` (3 testes, todas as plantas e variantes, mais a Provação e o Altar): (1) relíquia e veia (`relic_spots`, `gather_spots`) em chão livre, alcançáveis a pé a
  partir da entrada e fora de ilha de esquiva; (2) nenhum perigo que fere o herói a menos de 2 m da entrada nem a 1 m do centro de uma porta, e `start_delay` de pelo menos 3 s (o sopro das Fendas só
  empurra, 0 de dano, e fica de fora da regra); (3) toda sala com travessia tem ao menos uma zona de nascimento andável da entrada. Passam sem mudar dado: nenhum achado a corrigir nesses pontos.
- **Robô** (900 s, `--bot-reaction=0.25`, sementes 1 a 8): `stuck` 0 em todas; 6 chegam a Morvath (boss_at 390 a 522 s); as sementes 5 (sala 7, Santuário) e 6 (sala 10, Casa do Ancião) morreram em
  combate (vida 0, golpes de mago, padre e corpo a corpo), não por trava. Sem inimigo preso, sem porta nem quebrável inalcançável (os testes de `test_arenas` e `test_room_gaps` seguem verdes).
- **Tempo por sala** (média das 8 sementes): Salão 13 s (abertura curta de propósito), Jardim 30 s, Cripta 34 s, Runas 36 s, casa do Cavaleiro 37 s, Ponte 41 s, Fendas 50 s, Santuário 50 s,
  casa do Ancião 57 s. A curva é crescente e sem sala fora de faixa; o Santuário e as Fendas são as mais longas por causa das ilhas e dos magos.
- **Dano do perigo ao herói** (soma das 8 sementes): Runas 50 (5 golpes de 10), armadilha de lâmina do Santuário 10 (1 golpe), nenhum nas Fendas, Jardim, Cripta e Ponte. Nada de golpe no começo de sala.
- **Em aberto** (não contido): o robô não busca ilhas de esquiva nem relíquias de propósito (quem mede o prêmio é o jogador); o dano do perigo aos inimigos não aparece em `rooms[]` (só o
  `hurt_by` do herói), então a proporção herói e inimigos continua só pelos testes de `hazard`; `Rooms.spawn_point` cai no centro da primeira zona se nenhuma tentativa for alcançável (hoje
  nenhuma planta chega lá, o teste 3 trava o caso das travessias).


## Lote 2 (2026-11-26 noite): PM-3 Fendas e PM-4 fontes por caminho (`room-designer`)

**PM-3, o herói ficava 77% no leste.** O robô vai sempre ao inimigo mais perto e o herói entra no sudoeste, mas as três zonas de nascimento
cedo eram todas no leste e o sorteio pelo lado oposto (`far_spawn` 1,5) trazia o resto até ele: a luta caía no brinco leste. Agora as Fendas
nascem em duas zonas do oeste (a de x -18,5 a -12, z 1 a 6, a 7 m da entrada, e a do canto noroeste) e três do leste (nordeste, parede leste e a
cabeça sul pequena); a cabeça sul inteira e a parede oeste ficam para os tardios; `far_spawn` 0. Medida (robô 0,25, 12 sementes, tempo de luta
nas Fendas, 600 a 650 s): antes leste 71%, oeste 13%, ponte sul 8%, caminho sul 6%; depois leste 52%, oeste 34%, caminho sul 9%, ponte sul 4%.
Nenhuma zona acima de 60%. Ouro e quebráveis já estão nos cantos (3 grupos mais a ilha); o robô não os busca, então só o nascimento move o jogo.
Tentativas: só zona oeste cedo com `far_spawn` 1,5 deixou 71% leste; oeste 58% com o sul inteiro cedo (zona a 3,4 m da entrada, reprovada);
oeste 67% com leste menor. Chegada em Morvath 8 de 12 antes e depois, `stuck` 0.

**PM-4, fontes por caminho.** 300 descidas do `RunMap` (`tools/fountain_probe.gd`): ANTES todo mapa tinha um caminho com 4 fontes (a de antes de cada
guardião, salas 4 e 9, e o descanso depois, 6 e 11), e o mínimo era 0 (cada sala tem duas portas); cura total possível 4 x 40% = 160% da vida.
DEPOIS `StageDef.fountains_per_path` = 2: ficam as das camadas mais cedo (a da sala 4 antes do primeiro guardião e o descanso da 6); nada de fonte
na segunda metade (salas 7 a 13); máximo por caminho 2 em 300 de 300, cura possível 80% da vida. O teste `test_sw_r` trava os dois números.
Robô (12 sementes): vida média ao entrar nas salas 7 a 13 de 40,0 para 27,1, chegada em Morvath 8 de 12 nas duas; é a descida "mais difícil sem
upgrades" pedida, e o respiro depois do segundo guardião passa a ser só a sala leve (orçamento 20) e a cura da sala (`room_heal_base`).

## Portas afastadas, com uma peça entre elas (Daniel, 2026-11-27)

Regra: em toda sala com duas ou mais portas, as duas primeiras ficam a 5,5 m ou mais uma da outra (no máximo 13 m, para a escolha não pedir
caminhada) e algo fica entre elas. Reverte o canto das portas juntas (PT-6b, 2026-11-25). O salão já cumpria (`CatacombHall.DOOR_X`, estátua do meio).
Números em `tools/make_data.gd` (`_gate`, `_guardian_doors`, `CRYPT_DOORS`); trava em `tests/test_door_corner.gd` (distância, peça entre, boca livre).

| Sala | Antes (entre as duas primeiras) | Agora | Peça entre elas |
|---|---|---|---|
| Cripta (A e B) | 4,2 m (2,8 e 7,0) | 8,8 m (6,6 e -2,2; a terceira em -8,6) | tigela de fogo na parede (3,1) e a urna (1,0); na B o muro divisor |
| Fendas | 4,2 m (14,0 e 18,2) | 6,0 m (13,0 e 19,0; a terceira em 7,2) | candelabro de pé com chama (16,0, `_stand_brazier`) e tigela na parede (10,1); o pórtico da fachada abraça as três portas |
| Jardim | 4,2 m (8,8 e 13,0) | 6,8 m (6,6 e 13,4; a terceira em -0,8) | a estátua do nicho (10,0, `GardenLook.STATUES`); janelas do norte em -10,4 e -7,0 |
| Santuário | 4,2 m (7,3 e 11,5) | 8,6 m (-5,3 e 3,3; a terceira em 11,0) | a estátua do nicho (-1,0) sobre o sarcófago; a armadilha do norte foi para x 7,15 |
| Ponte | 4,2 m (21,3 e 25,5) | 7,5 m (17,5 e 25,0) | estátua na parede (21,25, `_statue`) |
| Runas | 4,2 m (6,8 e 11,0) | 7,8 m (7,3 e -0,5; a terceira em -8,8) | tigela de fogo na parede (3,4); na B também o cristal (-4,5) |
| Provação | 4,2 m (0,3 e 4,5) | 7,2 m (-3,4 e 3,8) | duas tigelas frias, a faixa e a prateleira (`TrialLook`) |
| Altar | 4,2 m (z -5,2 e -1,0) | 5,7 m (z -5,5 e 0,2) | braseiro de pé (8,1; -2,65) |
| Casa do Cavaleiro e do Ancião | 4,2 m | 7,4 m | tigelas de fogo na parede entre as portas |

Rastreio: o teste dos buracos (`test_a_dash_never_crosses_the_abyss`) passou a aceitar a boca da porta como chão.


## Ajustes depois da revisão das salas pintadas (Daniel, 2026-11-27, segunda leva)

| Item | O que mudou | Teste |
|---|---|---|
| Entrada (todas as salas de `ArenaRoom`) | patamar de pedra colado à borda sul, meios-fios, lance de 5 degraus descendo para fora do quadro e abertura no parapeito ou no muro baixo; no lugar do arco preto solto (`art_rooms.md`, "Entrada ao sul") | `test_room_style` (nada sobre o piso aberto), `test_pt6_rooms` |
| Altar (Sala 18) | as duas portas na parede do fundo (x -6,2 e 6,2, 12,4 m), o túmulo com o arco cego entre elas; estandartes em x +-3,7 e prateleiras do norte fora (as portas ocupam a parede); braseiro foi para (8,1; 1,6) | `test_door_corner`, `test_altar`, `test_e5_wiring` |
| Ponte A e B (Salas 13 e 14) | as duas portas na parede norte da plataforma leste em x 17,0 e 22,6 (5,6 m), estátua entre elas em 19,8; o túmulo saiu da aproximação para (25,6; -0,9). Dentro do quadro `--cam-at=-4,3 --cam-dist=94` (a porta de fora a cerca de 96% da largura). Terceira porta continua na parede leste | `test_door_corner` |
| Runas B (Sala 16) | o pilar de (-9,-6) ficava diante da terceira porta (x -8,8): foi para (-12,2; -6) | `test_no_solid_piece_in_a_doors_approach` (novo; nenhuma peça sólida na faixa de 4 m diante de nenhuma boca) |
| Ponte B | ziguezague: o primeiro lance sai da plataforma oeste pelo lado sul (z 0,5 a 5,5), o patamar passa a 6 x 11 m, o segundo lance sai dele pelo lado norte (z -5,5 a -0,5) para a plataforma leste; a corrente varre cada lance (bandas no lugar). A é reta, com três plataformas. `BridgeLook` entende patamar entre decks desalinhados (`_landing_zigzag`) | `test_room_style` (RS-C7) |
| Cripta B, Santuário | coluna rachada da B em (6,5; -5,2) e tambores caídos até z -9,3: fora da aproximação da porta 0 da Cripta e da porta 1 do Santuário | `test_door_corner` |

Pares A e B (leitura das capturas): Cripta e Jardim ainda se parecem demais (mesma planta e mesma árvore ou sala, só a mobília muda; a Cripta B
ganha o muro divisor e o Jardim B troca raízes e o altarzinho). Santuário A e B já diferem nos dados (a B tem o buraco da nave de 8,4 x 7 m), mas as
pinturas perderam o buraco: o prompt da B precisa nomeá-lo. Fendas (buraco no meio e ilhas) e Runas (pedra quieta e ilhas soltas na B) já se leem
diferentes; a Ponte B agora é o ziguezague. Próximo lote: Jardim B com o terreno em desnível, Cripta B com um poço rebaixado, Santuário B com o
buraco aberto até a borda sul.

## Pares A e B mais diferentes, árvore pintada, Fendas (room-designer, 2026-11-27)

Cada B passa a mudar como se luta (dado em `_crypt`, `_garden`, `_sanctuary`; trava em `tests/test_variant_b_shapes.gd`):
- **Cripta B**: poço de 9 x 6 m (x -4,5 a 4,5, z -1,5 a 4,5) no meio da metade sul, à frente do fim do muro divisor: duas pistas de 7 m, oeste e leste; tiro cruza o poço, a horda não. Sarcófagos do sul foram para (-8,5; 6,5) e (7; 6,5); espinhos para (-8; -5,5) e (8,5; -3); molduras de laje da arte (`STY_FRAMES_B`) para z 5,8. A entrada ao sul segue livre.
- **Jardim B**: terraço leste: muro de contenção baixo (0,9 m) no x 8 de z -9 a 11 com duas escadas (z -4,5 a -1,5 e 3 a 6); sarcófago do sul foi para (4,5; 8,5). Largura das escadas 3 m; folga estreita 1,3 m entre o muro e outras peças.
- **Santuário B**: o buraco da nave corre até z 13,9 (aro de 0,1 m que ninguém pisa): a nave fica cortada e só o corredor norte liga leste (entrada) e oeste. Banco leste e laje sudeste saíram (a laje foi para o corredor norte, x 6 a 9, z -11 a -8); zonas de nascimento da B próprias (sem a do sul do buraco). Arte: `SanctuaryLook` lê `floor.holes` e centra poeira e bocas no meio do buraco, que agora é mais comprido.
- **Árvore pintada**: `StoneTree` marca suas malhas com a meta `painted_hide`; `PaintedHall._walk` as esconde nas salas pintadas (colisão intacta).
- **Fendas (PM-3)**: nascimentos cedo: duas zonas oeste (nordeste do oeste e (-18 a -13,5; 10 a 12,5)) e três leste. Robô: o lado do herói oscila muito por semente (com 1 zona oeste, 85% leste; agora cerca de 30 a 90% oeste conforme a semente).
- **Testes de salas ajustados** (entradas novas e placas pintadas): `test_room_style` desliga as placas pintadas (`Dev.put("painted","off")`, como `test_hall_artpack`), `test_columns` espera a coluna rachada da Cripta B em (6,5; -5,2), Ponte B: quebráveis em 2,5 m das duas linhas do zigue-zague (z 3 e -3), grupo do oeste agora na parede norte da plataforma oeste (-16; -8,3).
