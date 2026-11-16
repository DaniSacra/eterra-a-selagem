# Câmara do Selo: a arena de Morvath (ciclo C11, jogabilidade)

Pedido do Daniel: `docs/design/boss_arena_brief.md`. Planejamento: `docs/backlog.md`, C11. Arte e medidas da pintura:
`docs/art/boss_chamber_spec.md`. Este documento é a parte da jogabilidade: o raio, as contas refeitas com os números
reais, as decisões e os testes que as provam.

## O chão
- Círculo de **12,5 m** até a balaustrada, centro do selo em (0; 0). O centro do herói (raio 0,5) anda até **12 m**; o de
  Morvath (raio 1,4) até 11,1 m. Área andável do herói: cerca de 452 m² (o salão tem cerca de 800).
- O herói entra em (-0,9; 10,4) olhando para o norte; Morvath começa em (0; -1,2), sobre o selo. A energia do fim da luta
  vai para o meio do selo (`Arena.door_pos`).
- A borda é a única colisão (nada de pilar, caixa, patamar ou saída): `FloorShape` (`scripts/core/floor_shape.gd`) dá
  `contains`, `clamp`, `edge_distance` e `cut` (raio até a borda, com margem do corpo; margem negativa passa da borda).
  `Arena.shape()` devolve o chão de qualquer sala (o salão é o retângulo menos `Arena.WALL` 1,2 m, como sempre foi), e
  `resolve`, `inside`, `on_floor` e a esquiva usam a mesma forma. Não há limite retangular invisível.
- Os dados ficam no `RoomLayout` do chefe (`chamber`, `floor`, `hero_spawn`, `hero_facing`, `boss_spawn`, `cam_target`,
  `cam_reach`), gerados por `_chamber()` no `tools/make_data.gd`. As salas comuns e a loja continuam no salão.

## O raio, conferido com os números reais

| Número | Valor | Fonte |
|---|---|---|
| Andar, corrida | 6,75 m/s; 11,1 m/s | `_feel` |
| Esquiva | 5,6 m em 0,2 s, 1 carga | `_feel` |
| Corpo do herói, de Morvath | 0,5 m; 1,4 m | `Player.RADIUS`, `_enemies` |
| Foice | 5 m, 180°, preparo 0,8 s | `_bosses` |
| Lâminas, tempestade | faixas de 3 m, 11 m/s; 6 faixas a 48° ou mais, 2 ondas giradas 30°, 1 s entre elas | `_bosses` |
| Investida | 16 x 2,8 m, só com o herói a 9 m ou mais, preparo 0,8 s | `_bosses` |
| Ritual | mortos num anel de 6,5 m em volta dele, escudo 2,9 m | `BossDef.ritual_ring`, `shield_radius` |
| Diretor | perto 6 m, longe 10 m | `BossDef.near`, `far` |

1. **Investida.** De Morvath no selo até a borda há 12,5 − 1,4 = 11,1 m de faixa livre (acima dos 8 m exigidos,
   `BossDef.dash_min_free`), e o herói fica a até 12 m dele: a investida existe. Encostado na borda, para o lado da
   borda, ela não sai (`Boss._choose` mede `_dash_room`); a faixa e o corpo dele param na borda (`FloorShape.cut` com o
   raio do corpo). Nas simulações com `--bot-kite=0.2` saiu em 23 de 24 lutas (de 1 a 4 por luta; no salão também 23 de 24 com o mesmo robô).
2. **Tempestade.** Entre duas faixas vizinhas a 48°, o vão para o centro do herói a d metros de Morvath é
   2 d sen 24° − 3 − 1 = 0,81 d − 4 m: 2,5 m a 8 m, 4,1 m a 10 m, 5,7 m a 12 m. Com Morvath no meio (ele abre a fase 4 de
   lá, ver abaixo) toda a coroa de 8 a 12 m tem vão maior que uma esquiva sem precisão. A segunda onda gira 30°: a 10 m
   isso é 5,2 m de arco em 1 s, menos que os 6,75 m que ele anda. O teste de saída simula as duas ondas.
3. **Foice.** Do contato (1,9 m) até fora (5,5 m) são 3,6 m em 0,8 s (4,5 m/s): andando dá, de qualquer ponto, porque ele
   nunca encosta o herói na borda sem lado livre (o arco é de 180° e a borda é convexa).
4. **Ritual.** O anel dos mortos fica a 6,5 m dele (mais 0,5 do morto): com Morvath no meio sobra a coroa de 7 a 12 m
   para lutar fora do anel. As invocações fora do ritual usam `summon_ring` 5 m e `summon_clear` 4 m do herói; todo ponto
   é empurrado para o chão com a margem da runa (`_ring_spots`), então nenhuma runa pinta fora do círculo.
5. **Câmera.** Distância 54, campo 24°, inclinação 30°: com o alvo fixo em (0,40; 0,57) a câmara inteira cabe numa tela
   16:9 com o herói sempre a mais de 18% das bordas (o teste confirma que a câmera nem se mexe em 16:9). Em 16:10, 4:3 e
   21:9 e com o zoom do Ômega ela se desloca no máximo 3 m (`RoomLayout.cam_reach`, `CamFrame.hold`).
6. **Fuga.** O círculo não tem canto: correr em volta dá cerca de 75 m de borda (11 s a pé), e Morvath cruza pelo meio
   (24 m). Longe dele vêm lâminas e investida; perto, foice. A faixa de 9 a 12 m é onde a investida e as lâminas cobrem
   a fuga.

**Conclusão: 12,5 m (12 m para o centro do herói) fica.** Abaixo de cerca de 11 m a investida sai pouco e o vão da
tempestade cai para menos de 3 m nas bordas; acima de 13 m a câmera precisaria andar.

## Mudanças na luta (sem mexer em vida, dano nem preparo)
- **Faixas recortadas na borda**: lâminas, tempestade, maldição e investida (`Boss._lane`). As meias-luas se desfazem
  0,3 m depois da borda (`BossDef.soul_overrun`), não voam sobre o abismo.
- **Investida** só com 8 m livres e parando com o corpo na borda (`dash_min_free`, `_dash_room`, `_dash_len`).
- **Erupções** recebem o chão (`BossRules.eruptions(..., floor, rng)`): a primeira, a que persegue, é mantida com o centro
  pelo menos meio raio para dentro (o resto do círculo é cortado pelo desenho); as outras só nascem inteiras no chão,
  com 0,3 m de folga (`ERUPTION_EDGE`).
- **Centro nas transições**: além do ritual (fase 2), ele vai ao meio ao abrir as fases 3 e 4 (`BossDef.center_phases`)
  e espera lá o descanso de sempre (0,4 s a mais que o da fase) antes de abrir a fase com o próprio padrão (maldição,
  tempestade). Assim a tempestade da fase 4 sai sempre do meio, com os vãos da conta 2.
- **Anéis como dado**: `summon_ring`, `summon_clear`, `ritual_ring` saíram de constantes do `boss.gd` para o `BossDef`.
- `near` e `far` do diretor (6 e 10 m) continuam dado e cabem no círculo (o herói fica a até 24 m dele), por isso não
  mudaram.

## Avisos com a assinatura de Morvath (ART-001)
- Todo aviso dele (menos runas e erupções, que já têm o círculo ritual) é redesenhado por `Ground.sign_boss`
  (`GroundLook.signed_warning`): miolo 0,35, frente de 0,12 m, aro de 0,18 m com fio violeta de 2 px na tela e uma faixa
  de runas espectrais correndo por fora (`SIGN_PAD` 0,38 m). Usa a origem do aviso (`Zone.source`, do ciclo 10).
- Tempestade: a ordem de saída aparece em cada faixa (`Ground.storm_rank`): de 1 a 6 pontos perto da raiz (a partir de
  2,2 m, fora do corpo dele; a especificação pedia 1,2 m, que fica dentro dele) e o aro em degraus (a próxima a sair
  inteira, as seguintes mais apagadas, `GroundLook.ORDER_LEVELS`), refeitos a cada passo.
- Nenhum aviso pinta além da borda: global `floor_round` (x, z, raio; 0 = sem recorte) lido pelo `ground.gdshader` e pelo
  `ritual_rune.gdshader`.

## Para a cenografia (`BossChamber`)
- O visual entra em `Arena._chamber_look(layout, seed_)` (hoje um disco provisório com o fio dourado na borda e uma
  luz): trocar o corpo por `chamber = BossChamber.new(); add_child(chamber); chamber.build(self, layout, seed_)`. O
  `RoomLayout` traz `floor` (centro e raio), `hero_spawn`, `boss_spawn`, `cam_target`.
- `Arena.open_door`, `final_phase` e `seal_portal` repassam para `chamber` quando ele existe (`seal_portal(seconds, from)`
  se o `BossChamber` tiver; senão `seal_restore(seconds)`).
- Global `boss_pos` (x, 0, z; `Arena.NO_BOSS` sem chefe) para o `see_through` de peças do perímetro.

## Câmera
- Na câmara o alvo é fixo (`RoomLayout.cam_target`), não segue o herói: `CamFrame.hold` limita o desvio a `cam_reach`
  (3 m), aplica a regra dos 18% (`CamFrame.keep`) e limita de novo. As margens do salão não valem ali.

## Robô e métricas
- `Bot._escape` escolhe para onde fugir entre as direções com chão e sem outro aviso (na tempestade, o vão).
- "Preso": parado mais de 1 s querendo andar, contra corpo ou borda (`Bot._track_pinned`); `RESULT` traz
  `bot.stuck` e `bot.died_stuck`.
- Opções: `--no-boss` (a sala do chefe vazia), `--hero-at=x,z`.

## Testes
- `tests/test_floor_shape.gd`: círculo e retângulo (contém, empurra, distância, recorte).
- `tests/test_boss_exits.gd`: Morvath em 12 posições x herói em 12, com 0,25 s de reação e os menores preparos: foice,
  lâminas (os dois lados), investida (recortada e só com espaço), erupções (3 sementes, 2 sequências), tempestade (as duas
  ondas, com as meias-luas da primeira voando) e maldição (andando ou esquivando). Hoje todos os pares saem andando.
- `tests/test_boss_chamber.gd`: dados, colisão só no círculo, deslizar na borda, esquiva parando na borda, cerco de mortos
  contra a borda (a esquiva sempre tira), volta inteira na borda, câmera (4 proporções, com e sem zoom do Ômega), luta
  real (faixas na borda, meias-luas, mortos no chão, assinatura), fases 3 e 4 abertas do meio, investida só com espaço,
  ordem da tempestade.

## Simulações (robô, `--boons=6`, 24 sementes)
Comandos: `tools/smoke.sh 240 --start=boss --boons=6 --bot-reaction=0.25 --seed=1..24`, o mesmo com `--bot-kite=0.2`, e
`tools/smoke.sh 300 --seed=1..4`. "Salão" é o HEAD dcf6632 (antes do C11); "salão + robô novo" é o mesmo com o `bot.gd`
deste ciclo, para separar o efeito da arena do efeito do robô.

| Conjunto | Arena | Vitórias | Duração média | Investidas por luta | Mortes por fase | Preso | Erros |
|---|---|---|---|---|---|---|---|
| reação 0,25 | salão | 16/24 | 103 s | 0,04 | 2: 1, 3: 2, 4: 5 | | 0 |
| reação 0,25 | salão + robô novo | 16/24 | 103 s | 0 | 3: 4, 4: 4 | 0 | 0 |
| reação 0,25 | câmara | 15/24 | 104 s | 0 | 4: 9 | 0 | 0 |
| com afastamento 0,2 | salão | 9/24 | 119 s | 2,5 (0 em nenhuma) | 2: 4, 3: 2, 4: 9 | | 0 |
| com afastamento 0,2 | salão + robô novo | 15/24 | 122 s | 2,6 (1 luta sem) | 1: 1, 2: 2, 3: 4, 4: 2 | 0 | 0 |
| com afastamento 0,2 | câmara | 19/24 | 127 s | 2,2 (1 luta sem) | 2: 1, 3: 1, 4: 3 | 0 | 0 |
| partida inteira | câmara | 4/4 | 107 s de luta | | | 0 | 0 |

- Somando os dois conjuntos de luta: salão 25/48, salão com o robô novo 31/48, câmara 34/48. O dano total sofrido é
  praticamente o mesmo (salão 522, câmara 520 nas 24 lutas de reação 0,25); na câmara as mortes se concentram na fase 4
  (a tempestade sai sempre do meio e o robô de reação 0,25 luta colado nele, onde o vão é estreito; 101 do dano das
  derrotas veio dela). Nenhuma morte com o robô preso; nenhuma luta com o robô preso mais de 1 s.
- Morvath chega entre 61 e 75 s nas partidas inteiras, como antes.
