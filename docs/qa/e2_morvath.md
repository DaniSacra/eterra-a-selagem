# E2: Morvath mais difícil (medição antes e depois)

Pedido do Daniel no teste da E1: "Morvath está fácil demais". Meta da entrega (Game Director): o robô com reação de
gente (`--bot-reaction=0.25`) e 5 Bênçãos sorteadas (`--start=boss --boons=5`) vence **3 a 5 de 8 sementes**, luta de
**2 a 4 min**. São simulações do robô, não gente: o robô pune quase toda janela e bate mais que uma pessoa.

Comando de cada luta (60 qps fixos, sem tela):
`tools/smoke.sh 400 --start=boss --boons=5 --bot-reaction=0.25 --seed=N`. Antes = versão 3d82202 (os mesmos scripts com o
`data/bosses/morvath.tres` antigo, que reproduz a 3d82202 quadro a quadro: a semente 1 deu o mesmo RESULT nas duas).

Colunas: duração da luta (da entrada à queda dele ou à morte do paladino), segundos em cada fase, fase em que o robô
caiu, vida que o robô perdeu para cada fonte (`boss.hurt_by`: `adds` são os mortos dele, `ritual` as erupções do
ritual), vida no fim, mortos dele erguidos na luta (teto 20), janelas punidas, camadas postas (E2).

## Resumo

| | Sementes 1 a 8 | Sementes 9 a 16 | Duração mediana (1 a 8) | Lutas de 2 a 4 min (1 a 8) | Vida no fim, média (1 a 8) | Vida perdida para ele (1 a 8) |
|---|---|---|---|---|---|---|
| Antes (3d82202) | **8 vitórias** | 6 vitórias | 2:07 | 4 de 8 | 23,8 | 114 |
| Depois (E2) | **4 vitórias** | 4 vitórias | 2:14 | 5 de 8 | 9,5 | 234 |

Meta: vitórias **cumprida** (4 de 8, e 4 de 8 nas outras 8 sementes: 8 de 16). Duração: mediana 2:14 (1 a 8) e 2:11
(9 a 16), mas 7 das 16 lutas ficam entre 1:35 e 1:56. A vida de Morvath não mudou (6050, a do Hades; o teste
`test_morvath_keeps_hades_life_and_his_numbers_are_data` a guarda): as lutas curtas são as em que o robô cai cedo ou
mata rápido com 5 dons fortes. Gente bate menos que o robô (ele pune 70 a 90% das janelas), então a luta de gente deve
ficar mais longa; medir com o Daniel antes de mexer na vida.

## Antes (3d82202)

| Semente | Resultado | Duração | Fases 1/2/3/4 (s) | Caiu na fase | Vida perdida por fonte | Vida no fim | Mortos dele | Janelas punidas | Camadas |
|---|---|---|---|---|---|---|---|---|---|
| 1 | vitória | 2:43 | 42 / 62 / 34 / 25 | - | curse 12 | 19 | 16 | 16/38 | - |
| 2 | vitória | 1:55 | 29 / 52 / 19 / 15 | - | - | 30 | 12 | 16/23 | - |
| 3 | vitória | 2:32 | 30 / 60 / 36 / 26 | - | adds 36, eruptions 10, storm 10, curse 6 | 7 | 12 | 26/32 | - |
| 4 | vitória | 2:17 | 40 / 51 / 23 / 23 | - | curse 12 | 20 | 15 | 22/34 | - |
| 5 | vitória | 2:36 | 37 / 74 / 23 / 23 | - | adds 12 | 20 | 16 | 24/36 | - |
| 6 | vitória | 1:30 | 23 / 39 / 14 / 14 | - | - | 30 | 8 | 15/16 | - |
| 7 | vitória | 1:32 | 24 / 32 / 23 / 14 | - | storm 10, curse 6 | 34 | 10 | 18/18 | - |
| 8 | vitória | 1:46 | 28 / 43 / 19 / 16 | - | - | 30 | 10 | 19/22 | - |
| 9 | vitória | 3:12 | 46 / 94 / 24 / 28 | - | adds 20, curse 6 | 4 | 17 | 19/43 | - |
| 10 | vitória | 1:25 | 23 / 39 / 12 / 12 | - | adds 4 | 26 | 10 | 13/14 | - |
| 11 | vitória | 2:36 | 43 / 59 / 26 / 28 | - | - | 50 | 15 | 31/36 | - |
| 12 | derrota | 2:00 | 30 / 63 / 21 / 7 | 4 | adds 12, blades 10, curse 6, storm 2 | 0 | 16 | 15/23 | - |
| 13 | derrota | 3:12 | 46 / 83 / 32 / 31 | 4 | adds 16, curse 10, storm 10 | 0 | 16 | 25/47 | - |
| 14 | vitória | 1:44 | 26 / 42 / 20 / 16 | - | curse 6 | 24 | 10 | 17/21 | - |
| 15 | vitória | 1:57 | 30 / 51 / 17 / 20 | - | adds 8 | 22 | 12 | 20/24 | - |
| 16 | vitória | 2:59 | 43 / 82 / 24 / 31 | - | storm 30, curse 6, adds 4 | 10 | 14 | 29/41 | - |

## Depois (E2)

| Semente | Resultado | Duração | Fases 1/2/3/4 (s) | Caiu na fase | Vida perdida por fonte | Vida no fim | Mortos dele | Janelas punidas | Camadas |
|---|---|---|---|---|---|---|---|---|---|
| 1 | derrota | 2:46 | 42 / 62 / 31 / 32 | 4 | storm 30 | 0 | 20 | 21/38 | eruptions 13, summon 9 |
| 2 | vitória | 2:11 | 29 / 52 / 25 / 26 | - | adds 8 | 22 | 20 | 18/26 | eruptions 9, summon 6 |
| 3 | vitória | 2:30 | 30 / 60 / 30 / 30 | - | adds 52, storm 10 | 11 | 20 | 23/30 | eruptions 9, summon 5 |
| 4 | vitória | 2:43 | 40 / 51 / 32 / 40 | - | curse 6, adds 4 | 23 | 20 | 23/39 | eruptions 15, summon 7 |
| 5 | derrota | 2:15 | 37 / 70 / 28 | 3 | adds 16, blades 10, curse 8 | 0 | 20 | 19/34 | eruptions 6, summon 3 |
| 6 | vitória | 1:35 | 23 / 39 / 16 / 18 | - | storm 10 | 20 | 16 | 16/18 | eruptions 5, summon 3 |
| 7 | derrota | 1:44 | 24 / 32 / 25 / 24 | 4 | eruptions 20, storm 20, curse 6, adds 4 | 0 | 20 | 18/22 | eruptions 9, summon 4 |
| 8 | derrota | 1:48 | 28 / 43 / 19 / 17 | 4 | storm 14, eruptions 10, curse 6 | 0 | 16 | 20/23 | eruptions 8, summon 4 |
| 9 | derrota | 3:08 | 46 / 94 / 41 / 7 | 4 | adds 24, storm 6 | 0 | 20 | 18/44 | eruptions 8, summon 5 |
| 10 | derrota | 1:50 | 23 / 39 / 16 / 33 | 4 | adds 20, storm 10 | 0 | 20 | 10/19 | eruptions 7, summon 4 |
| 11 | vitória | 2:55 | 43 / 59 / 43 / 30 | - | curse 6 | 44 | 20 | 35/42 | eruptions 13, summon 8 |
| 12 | derrota | 1:40 | 30 / 63 / 8 | 3 | adds 12, blades 10, curse 6, eruptions 2 | 0 | 16 | 13/20 | eruptions 2, summon 1 |
| 13 | derrota | 2:24 | 46 / 83 / 15 | 3 | adds 19, eruptions 10, curse 6 | 0 | 16 | 20/34 | eruptions 3, summon 2 |
| 14 | vitória | 1:48 | 26 / 42 / 20 / 21 | - | eruptions 10, adds 8, curse 6 | 6 | 20 | 18/22 | eruptions 6, summon 5 |
| 15 | vitória | 1:56 | 30 / 51 / 15 / 20 | - | storm 20, adds 8 | 2 | 16 | 17/22 | eruptions 4, summon 2 |
| 16 | vitória | 3:28 | 43 / 82 / 47 / 37 | - | curse 12, adds 4 | 34 | 20 | 32/48 | eruptions 14, summon 10 |

Leitura:
- As mortes saíram das fases 3 e 4 (5 na 4, 3 na 3); a 1 e a 2 continuam sem matar o robô sozinhas. Na 4 pesa a
  tempestade (agora em três ondas) com as erupções por cima; na 3, os mortos dele erguidos junto da maldição e das
  lâminas.
- As fases 3 e 4 ficaram mais longas (mediana 26,5 e 26 s nas sementes 1 a 8, antes 23 e 19,5): mais coisa para desviar.
- O teto de 20 mortos na luta passou a ser alcançado (11 de 16 lutas); fora do ritual nenhuma invocação (nem de
  camada) ergue além de 4 de pé (`adds_peak` 4 a 6: os picos de 5 e 6 vêm do ritual, teto 6, e dos mortos dele que
  sobram de pé quando o escudo cai, como antes da E2).
## O que mudou (números em `data/bosses/morvath.tres`, `_bosses` do `tools/make_data.gd`)

- **Camadas** (`BossAttack.layers`, novo): padrões postos por cima de um ataque enquanto ele corre, coordenados pelo
  diretor e pelas regras (`BossDirector.layers_for`, `BossRules.free_way`, `Boss._step_layers`):
  - fase 3 em diante: **maldição + erupções + mortos** (sempre; as erupções caem quando o projétil sai, a faixa livre
    delas fora do caminho do projétil); **foice + erupções** (sempre; com o aviso da foice, a faixa livre para longe do
    meio círculo); **lâminas + mortos** (sempre, só na fase 3, onde as lâminas ainda existem).
  - fase 4: **tempestade + erupções + mortos** (sempre; as erupções com a primeira onda, a faixa livre no vão entre as
    faixas mais perto do paladino).
  - Erupções de camada: 2 círculos de 4 m, o primeiro sob o paladino (`layer_eruption_count`); mortos de camada: um
    esqueleto e um feiticeiro (`layer_raise`), pelo mesmo `_call` de sempre (tetos 4 de pé e 20 na luta, nascem a pelo
    menos 4 m do paladino).
- **Tempestade das Seis Almas em 3 ondas** (eram 2; `storm_waves`), recarga 4 s (era 5).
- **Descansos** por fase 1,1 / 1,0 / **0,6 / 0,4** (eram 0,9 e 0,75 nas fases 3 e 4). Nas fases 1 e 2 não mudaram:
  descansos menores ali encurtaram a luta (mais janelas para o robô punir) sem matar mais.
- **Combinações da fase 4 mais frequentes**: foice e depois tempestade 60% (era 50), erupções e depois foice 60% (era
  40). Maldição com recarga 6 s (era 7). Invocação com recarga 9 s (era 12).
- Sem mudança: vida (6050), dano de cada ataque, preparos e escala de preparo por fase, limiares 66/33/15, tetos de
  invocados (4 de pé, 6 no ritual, 20 na luta), o ritual.

Tentativas descartadas (registro): descansos menores nas fases 1 e 2 (0,95 e 0,9) deixaram as lutas mais curtas (mediana
1:48) e as vitórias iguais; a lâmina seguida da foice já na fase 1 (combinação) quebra a regra de que combinações só
existem na fase 4 (`test_combinations_come_only_in_the_last_phase_and_never_repeat`) e saiu.

## Justiça (sempre uma saída)

`tests/test_boss_exits.gd` ganhou as combinações novas, com Morvath em 12 pontos da câmara e o paladino em 12, reação
de 0,25 s e o menor preparo das fases em que a camada vem:
- tempestade em 3 ondas (cada onda a partir de onde ele parou, com as meias-luas das ondas de antes ainda voando);
- tempestade + erupções: 284 pares, 63 saem andando e 221 com a esquiva (erupção de 4 m sob ele e as faixas juntas);
- foice + erupções: todos os pares com a esquiva;
- maldição + erupções: 264 pares saem andando (ele pode andar ao ver o aviso da maldição; as erupções caem onde ele está
  quando o projétil sai; depois anda e esquiva uma vez);
- `BossRules.free_way` sai do ataque que cobre em 20 de 20 pares da foice e 142 de 142 da tempestade;
- `tests/test_boss_refine.gd`: com toda camada sempre, nas fases 3 e 4 no máximo o ataque e as erupções dele ferem ao
  mesmo tempo (nunca dois ataques próprios), os mortos nunca passam do teto e nascem a 4 m ou mais do paladino.

## Como repetir

- 8 sementes: `for s in 1 2 3 4 5 6 7 8; do tools/smoke.sh 400 --start=boss --boons=5 --bot-reaction=0.25 --seed=$s; done`
  (o `RESULT` traz `boss.layers`, as camadas postas na luta).
- Tempos de cada ataque: `tools/boss_cadence.gd` (comando no topo), tabela em `docs/design/combat_cadence.md` 1.4.
