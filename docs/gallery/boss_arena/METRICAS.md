# Métricas do C10 e do C11 (Câmara do Selo): simulações do robô

**Tudo aqui é SIMULAÇÃO do robô (`scripts/game/bot.gd`), não teste com gente.** O robô joga sem tela, no Linux (Godot
4.7.2, `--headless --fixed-fps 60`), com a lógica do jogo. Ele não erra a mira e lê o perigo pelo aviso no chão;
`--bot-reaction=0.25` atrasa em 0,25 s o que ele vê; `--bot-kite=0.2` faz ele passar 20% de cada período longe de Morvath
(para a investida existir). Servem para comparar versões e configurações, não para dizer quão difícil é para o Daniel.

- Data: 2026-11-16. **Câmara** = `6bab080` (HEAD). **Salão C10** = `196f33c` (fim do C10, salão retangular, robô do C10).
  **Salão C9** = `2de07b0` (fim do ciclo 9; não tem `--bot-kite` nem a contagem de "preso", então só roda sem afastamento).
  As duas versões antigas foram extraídas com `git archive` em `/home/dani/games/qa1011-*` (apagadas ao fim).
- **368 partidas, 0 com `SCRIPT ERROR` ou `Parse Error`** (todas com o `ERROR: ... resources still in use at exit` de sempre).
- Comando de cada partida: `godot --headless --path <versão> --fixed-fps 60 -- --bot --nosave --smoke=600 --seed=<1..8>
  --start=boss --bot-reaction=<0|0.25> --bot-kite=<0|0.2> <kit>`; partidas inteiras com `--smoke=900` sem `--start`. A saída é a
  linha `RESULT` (campos `boss` e `bot`). Mesmo semente, mesmo resultado: a semente 1 do kit do ciclo 9 deu Morvath com 51 de
  vida na simulação sem tela e na gravação da GPU.

## Kits (6 dons, um de defesa em cada)

| Kit | `--boon-ids` |
|---|---|
| fogo | `golpe_brasa,pesado_brasa,circulo_brasa,passo_brasa,brasas,firmeza` |
| geada | `golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,firmeza` |
| luz | `golpe_radiante,pesado_radiante,circulo_radiante,passo_radiante,firmeza,consolo` |
| sorteados | `--boons=5 --boon-ids=firmeza` (cinco sorteios, ficam 3 a 5 porque o mesmo botão substitui, mais a `firmeza`) |
| partida inteira | sem kit: as 4 salas antes de Morvath (o robô chega com 1 a 3 dons) |
| kit do vídeo do C9 | `golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno` (sem dom de defesa; só para escolher a semente do vídeo) |

## Resumo

| Arena | Reação 0 sem afastamento | Reação 0 com afastamento | Reação 0,25 sem afastamento | Reação 0,25 com afastamento | Partidas inteiras (0,25) |
|---|---|---|---|---|---|
| câmara (`6bab080`) | **32/32** | **32/32** | **29/32** | **28/32** | 4/8 sem e 4/8 com afastamento |
| salão C10 (`196f33c`) | 32/32 | 31/32 | 22/32 | 21/32 | 1/8 e 1/8 |
| salão C9 (`2de07b0`) | 31/32 | - | 25/32 | - | 1/8 |

- **Câmara contra salão, mesmos kits, reação 0,25**: 57 de 64 contra 43 de 64 (C10). Por kit, a câmara vence igual ou mais em
  sete das oito linhas; a exceção é sorteados sem afastamento (7/8 contra 8/8 no C10).
- **Investida com `--bot-kite=0.2` na câmara**: em todas as 72 lutas com afastamento (64 começando no chefe e 8 partidas
  inteiras) houve pelo menos 1 (média 1,6 a 3,2 por luta); sem afastamento, 0 (a regra pede o herói a 9 m ou mais).
- **Preso**: 0 em todas as 136 lutas da câmara (`bot.stuck` 0, `died_stuck` false). As versões antigas não medem.
- **Ritual**: mediana de 6,2 a 15,6 s por configuração na câmara; 10,8 e 11,8 s nas partidas inteiras com reação 0,25
  (meta do C10: abaixo de 15 s). No salão C9 era 11,3 a 20,0 s.
- **Duração da luta nas vitórias** (medianas por configuração): 92 a 128 s sem afastamento, 113 a 162 s com afastamento (o robô longe bate menos).
- Mortes na câmara com reação 0,25: sem afastamento as 3 são na fase 4; com afastamento 4, nas fases 2, 3, 3 e 4 (as três primeiras
  na geada: de longe as lâminas pesam, 100 de dano em 10 golpes nas 8 lutas).

## Todas as configurações

"Preso (lutas)": total de vezes que o robô ficou parado mais de 1 s querendo andar, contra corpo ou borda (lutas em que
aconteceu). "Morte presa": derrotas com ele preso. "n/d": a versão não mede. Duração é `boss.time` nas vitórias.
| Kit | Reação | Afastamento | Arena | Vitórias | Mortes (fase: n) | Duração nas vitórias, mediana (faixa), s | Investidas por luta (mín.) | Lutas sem investida | Preso (lutas) | Morte presa | Ritual, mediana s | Vida de Morvath nas derrotas | Erros |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| fogo | 0 | não | câmara (6bab080) | **8/8** | - | 93,6 (88,4 a 96,5) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 6,2 | - | 0 |
| fogo | 0 | não | salão C10 (196f33c) | **8/8** | - | 94,3 (85,6 a 99,4) | 0,0 (0) | 8/8 | n/d | n/d | 6,3 | - | 0 |
| fogo | 0 | não | salão C9 (2de07b0) | **7/8** | 4: 1 | 101,7 (95,6 a 108,4) | 0,0 (0) | 8/8 | n/d | n/d | 11,3 | 699 | 0 |
| fogo | 0 | 0,2 | câmara (6bab080) | **8/8** | - | 113,0 (106,8 a 120,1) | 1,6 (1) | 0/8 | 0 (0 lutas) | 0 | 7,5 | - | 0 |
| fogo | 0 | 0,2 | salão C10 (196f33c) | **8/8** | - | 109,7 (108,0 a 120,3) | 2,8 (2) | 0/8 | n/d | n/d | 8,1 | - | 0 |
| fogo | 0,25 | não | câmara (6bab080) | **8/8** | - | 93,2 (92,3 a 105,0) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 6,6 | - | 0 |
| fogo | 0,25 | não | salão C10 (196f33c) | **4/8** | 4: 4 | 98,2 (97,3 a 100,7) | 0,0 (0) | 8/8 | n/d | n/d | 7,7 | 588,537,615,476 | 0 |
| fogo | 0,25 | não | salão C9 (2de07b0) | **7/8** | 4: 1 | 107,4 (98,2 a 117,8) | 0,0 (0) | 8/8 | n/d | n/d | 14,1 | 18 | 0 |
| fogo | 0,25 | 0,2 | câmara (6bab080) | **8/8** | - | 117,2 (109,8 a 124,3) | 2,2 (1) | 0/8 | 0 (0 lutas) | 0 | 7,0 | - | 0 |
| fogo | 0,25 | 0,2 | salão C10 (196f33c) | **7/8** | 2: 1 | 114,4 (108,1 a 126,6) | 2,1 (1) | 0/8 | n/d | n/d | 8,4 | 2674 | 0 |
| geada | 0 | não | câmara (6bab080) | **8/8** | - | 114,2 (102,7 a 129,7) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 8,3 | - | 0 |
| geada | 0 | não | salão C10 (196f33c) | **8/8** | - | 124,5 (114,4 a 135,8) | 0,0 (0) | 8/8 | n/d | n/d | 10,4 | - | 0 |
| geada | 0 | não | salão C9 (2de07b0) | **8/8** | - | 129,0 (119,0 a 134,1) | 0,0 (0) | 8/8 | n/d | n/d | 14,7 | - | 0 |
| geada | 0 | 0,2 | câmara (6bab080) | **8/8** | - | 161,4 (147,5 a 180,9) | 3,0 (2) | 0/8 | 0 (0 lutas) | 0 | 15,6 | - | 0 |
| geada | 0 | 0,2 | salão C10 (196f33c) | **7/8** | 3: 1 | 163,4 (147,3 a 172,7) | 2,8 (2) | 0/8 | n/d | n/d | 11,5 | 1270 | 0 |
| geada | 0,25 | não | câmara (6bab080) | **7/8** | 4: 1 | 127,5 (126,1 a 134,1) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 10,8 | 104 | 0 |
| geada | 0,25 | não | salão C10 (196f33c) | **5/8** | 3: 1, 4: 2 | 128,1 (121,7 a 131,1) | 0,0 (0) | 8/8 | n/d | n/d | 12,4 | 747,1624,312 | 0 |
| geada | 0,25 | não | salão C9 (2de07b0) | **4/8** | 3: 1, 4: 3 | 136,4 (128,9 a 143,2) | 0,0 (0) | 8/8 | n/d | n/d | 20,0 | 1798,752,705,719 | 0 |
| geada | 0,25 | 0,2 | câmara (6bab080) | **5/8** | 2: 1, 3: 2 | 163,1 (156,3 a 186,3) | 2,8 (1) | 0/8 | 0 (0 lutas) | 0 | 9,8 | 3508,1732,932 | 0 |
| geada | 0,25 | 0,2 | salão C10 (196f33c) | **2/8** | 1: 1, 2: 2, 3: 1, 4: 2 | 179,9 (176,8 a 183,0) | 2,5 (0) | 1/8 | n/d | n/d | 10,5 | 3270,203,4268,759,1028,2579 | 0 |
| luz | 0 | não | câmara (6bab080) | **8/8** | - | 94,4 (82,9 a 102,7) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 9,7 | - | 0 |
| luz | 0 | não | salão C10 (196f33c) | **8/8** | - | 93,2 (89,0 a 102,0) | 0,0 (0) | 8/8 | n/d | n/d | 8,8 | - | 0 |
| luz | 0 | não | salão C9 (2de07b0) | **8/8** | - | 100,1 (93,0 a 105,2) | 0,0 (0) | 8/8 | n/d | n/d | 14,6 | - | 0 |
| luz | 0 | 0,2 | câmara (6bab080) | **8/8** | - | 119,7 (109,0 a 132,4) | 2,0 (1) | 0/8 | 0 (0 lutas) | 0 | 10,4 | - | 0 |
| luz | 0 | 0,2 | salão C10 (196f33c) | **8/8** | - | 125,8 (119,7 a 135,6) | 2,6 (1) | 0/8 | n/d | n/d | 11,1 | - | 0 |
| luz | 0,25 | não | câmara (6bab080) | **7/8** | 4: 1 | 102,0 (95,0 a 108,9) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 8,6 | 124 | 0 |
| luz | 0,25 | não | salão C10 (196f33c) | **5/8** | 4: 3 | 106,6 (98,2 a 112,5) | 0,0 (0) | 8/8 | n/d | n/d | 9,1 | 295,359,439 | 0 |
| luz | 0,25 | não | salão C9 (2de07b0) | **7/8** | 4: 1 | 111,3 (96,9 a 117,8) | 0,0 (0) | 8/8 | n/d | n/d | 17,6 | 624 | 0 |
| luz | 0,25 | 0,2 | câmara (6bab080) | **7/8** | 4: 1 | 133,8 (126,5 a 136,4) | 2,9 (1) | 0/8 | 0 (0 lutas) | 0 | 9,7 | 268 | 0 |
| luz | 0,25 | 0,2 | salão C10 (196f33c) | **5/8** | 4: 3 | 129,4 (119,1 a 139,2) | 2,8 (1) | 0/8 | n/d | n/d | 11,1 | 672,235,864 | 0 |
| sorteados | 0 | não | câmara (6bab080) | **8/8** | - | 91,8 (73,4 a 114,3) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 8,9 | - | 0 |
| sorteados | 0 | não | salão C10 (196f33c) | **8/8** | - | 97,8 (75,3 a 121,2) | 0,0 (0) | 8/8 | n/d | n/d | 9,4 | - | 0 |
| sorteados | 0 | não | salão C9 (2de07b0) | **8/8** | - | 102,4 (74,1 a 132,3) | 0,0 (0) | 8/8 | n/d | n/d | 17,2 | - | 0 |
| sorteados | 0 | 0,2 | câmara (6bab080) | **8/8** | - | 116,5 (85,7 a 142,8) | 2,2 (1) | 0/8 | 0 (0 lutas) | 0 | 9,1 | - | 0 |
| sorteados | 0 | 0,2 | salão C10 (196f33c) | **8/8** | - | 117,8 (99,5 a 143,3) | 2,2 (1) | 0/8 | n/d | n/d | 8,0 | - | 0 |
| sorteados | 0,25 | não | câmara (6bab080) | **7/8** | 4: 1 | 93,6 (78,7 a 125,2) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 8,0 | 43 | 0 |
| sorteados | 0,25 | não | salão C10 (196f33c) | **8/8** | - | 102,3 (81,2 a 149,8) | 0,0 (0) | 8/8 | n/d | n/d | 8,2 | - | 0 |
| sorteados | 0,25 | não | salão C9 (2de07b0) | **7/8** | 4: 1 | 100,2 (83,2 a 148,0) | 0,0 (0) | 8/8 | n/d | n/d | 13,2 | 583 | 0 |
| sorteados | 0,25 | 0,2 | câmara (6bab080) | **8/8** | - | 121,3 (96,4 a 153,0) | 2,8 (1) | 0/8 | 0 (0 lutas) | 0 | 8,2 | - | 0 |
| sorteados | 0,25 | 0,2 | salão C10 (196f33c) | **7/8** | 4: 1 | 121,4 (96,8 a 176,0) | 2,6 (1) | 0/8 | n/d | n/d | 7,8 | 625 | 0 |
| partida inteira | 0,25 | não | câmara (6bab080) | **4/8** | 3: 1, 4: 3 | 125,6 (105,8 a 146,4) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 10,8 | 1280,397,85,670 | 0 |
| partida inteira | 0,25 | não | salão C10 (196f33c) | **1/8** | 2: 1, 3: 2, 4: 4 | 124,7 (124,7 a 124,7) | 0,0 (0) | 8/8 | n/d | n/d | 10,3 | 2188,172,1720,918,790,202,137 | 0 |
| partida inteira | 0,25 | não | salão C9 (2de07b0) | **1/8** | 2: 4, 3: 2, 4: 1 | 114,8 (114,8 a 114,8) | 0,0 (0) | 8/8 | n/d | n/d | 20,0 | 1418,3799,3866,3704,1622,68,3837 | 0 |
| partida inteira | 0,25 | 0,2 | câmara (6bab080) | **4/8** | 2: 1, 3: 1, 4: 2 | 137,3 (132,9 a 153,2) | 3,2 (1) | 0/8 | 0 (0 lutas) | 0 | 11,8 | 307,2682,690,1441 | 0 |
| partida inteira | 0,25 | 0,2 | salão C10 (196f33c) | **1/8** | 1: 3, 2: 3, 4: 1 | 150,5 (150,5 a 150,5) | 1,5 (0) | 2/8 | n/d | n/d | 10,8 | 2999,3999,4464,373,4935,3554,3514 | 0 |
| kit do vídeo do C9 | 0,25 | não | câmara (6bab080) | **4/8** | 3: 1, 4: 3 | 119,3 (115,3 a 127,9) | 0,0 (0) | 8/8 | 0 (0 lutas) | 0 | 9,1 | 51,362,1683,146 | 0 |

| Kit | Reação | Afastamento | Arena | Dano recebido por ataque, soma das 8 lutas (golpes) |
|---|---|---|---|---|
| fogo | 0 | não | câmara (6bab080) | adds 4(1) storm 10(1) |
| fogo | 0 | não | salão C10 (196f33c) | adds 8(2) eruptions 10(1) storm 20(2) |
| fogo | 0 | não | salão C9 (2de07b0) | blades 10(1) scythe 60(5) storm 14(2) |
| fogo | 0 | 0,2 | câmara (6bab080) | - |
| fogo | 0 | 0,2 | salão C10 (196f33c) | blades 10(1) curse 6(1) eruptions 10(1) scythe 24(2) storm 10(1) |
| fogo | 0,25 | não | câmara (6bab080) | adds 27(7) curse 48(8) eruptions 20(2) storm 20(2) |
| fogo | 0,25 | não | salão C10 (196f33c) | adds 40(10) blades 10(1) curse 36(6) eruptions 40(4) ritual 20(2) scythe 38(4) storm 114(12) |
| fogo | 0,25 | não | salão C9 (2de07b0) | adds 60(15) blades 10(1) curse 60(10) eruptions 10(1) storm 144(15) |
| fogo | 0,25 | 0,2 | câmara (6bab080) | adds 44(11) blades 40(4) curse 54(9) scythe 12(1) storm 30(3) |
| fogo | 0,25 | 0,2 | salão C10 (196f33c) | adds 55(14) blades 80(8) curse 18(3) scythe 48(4) storm 40(4) |
| geada | 0 | não | câmara (6bab080) | - |
| geada | 0 | não | salão C10 (196f33c) | adds 12(3) eruptions 10(1) |
| geada | 0 | não | salão C9 (2de07b0) | adds 12(3) ritual 10(1) scythe 48(4) storm 10(1) |
| geada | 0 | 0,2 | câmara (6bab080) | adds 16(4) blades 10(1) curse 6(1) |
| geada | 0 | 0,2 | salão C10 (196f33c) | adds 24(6) blades 50(5) eruptions 20(2) scythe 72(6) storm 10(1) |
| geada | 0,25 | não | câmara (6bab080) | adds 79(20) curse 48(8) eruptions 40(4) ritual 10(1) scythe 68(6) storm 50(5) |
| geada | 0,25 | não | salão C10 (196f33c) | adds 64(16) blades 14(2) curse 50(9) eruptions 30(3) scythe 48(4) storm 112(12) |
| geada | 0,25 | não | salão C9 (2de07b0) | adds 152(38) blades 30(3) curse 42(7) ritual 10(1) scythe 12(1) storm 108(11) |
| geada | 0,25 | 0,2 | câmara (6bab080) | adds 84(22) blades 100(10) curse 48(8) eruptions 31(4) scythe 48(4) storm 10(1) |
| geada | 0,25 | 0,2 | salão C10 (196f33c) | adds 67(17) blades 143(15) curse 44(8) eruptions 40(4) scythe 70(6) storm 16(2) |
| luz | 0 | não | câmara (6bab080) | adds 8(2) |
| luz | 0 | não | salão C10 (196f33c) | adds 12(3) curse 6(1) eruptions 10(1) |
| luz | 0 | não | salão C9 (2de07b0) | adds 4(1) storm 20(2) |
| luz | 0 | 0,2 | câmara (6bab080) | - |
| luz | 0 | 0,2 | salão C10 (196f33c) | adds 8(2) blades 40(4) curse 6(1) ritual 10(1) scythe 60(5) storm 40(4) |
| luz | 0,25 | não | câmara (6bab080) | adds 60(15) blades 10(1) curse 54(9) eruptions 50(5) scythe 48(4) storm 62(7) |
| luz | 0,25 | não | salão C10 (196f33c) | adds 72(18) blades 20(2) curse 72(12) eruptions 30(3) ritual 10(1) scythe 36(3) storm 121(15) |
| luz | 0,25 | não | salão C9 (2de07b0) | adds 92(23) curse 36(6) ritual 20(2) storm 116(12) |
| luz | 0,25 | 0,2 | câmara (6bab080) | adds 95(24) blades 20(2) curse 54(9) eruptions 30(3) storm 74(8) |
| luz | 0,25 | 0,2 | salão C10 (196f33c) | adds 79(20) blades 90(9) curse 18(3) eruptions 20(2) ritual 10(1) scythe 36(3) storm 61(8) |
| sorteados | 0 | não | câmara (6bab080) | storm 10(1) |
| sorteados | 0 | não | salão C10 (196f33c) | adds 4(1) eruptions 10(1) storm 10(1) |
| sorteados | 0 | não | salão C9 (2de07b0) | scythe 12(1) |
| sorteados | 0 | 0,2 | câmara (6bab080) | adds 8(2) storm 10(1) |
| sorteados | 0 | 0,2 | salão C10 (196f33c) | adds 16(4) blades 10(1) eruptions 10(1) scythe 12(1) |
| sorteados | 0,25 | não | câmara (6bab080) | adds 36(9) blades 10(1) curse 42(7) eruptions 10(1) scythe 60(5) storm 72(8) |
| sorteados | 0,25 | não | salão C10 (196f33c) | adds 40(10) curse 48(8) eruptions 10(1) ritual 10(1) scythe 24(2) storm 110(11) |
| sorteados | 0,25 | não | salão C9 (2de07b0) | adds 72(18) curse 48(8) eruptions 30(3) ritual 20(2) storm 105(11) |
| sorteados | 0,25 | 0,2 | câmara (6bab080) | adds 52(13) blades 30(3) curse 24(4) eruptions 10(1) storm 10(1) |
| sorteados | 0,25 | 0,2 | salão C10 (196f33c) | adds 43(11) blades 70(7) curse 18(3) eruptions 10(1) scythe 24(2) storm 30(3) |
| partida inteira | 0,25 | não | câmara (6bab080) | adds 87(22) curse 69(12) eruptions 20(2) ritual 10(1) scythe 12(1) storm 38(5) |
| partida inteira | 0,25 | não | salão C10 (196f33c) | adds 71(18) blades 10(1) curse 69(13) eruptions 50(5) scythe 12(1) storm 45(6) |
| partida inteira | 0,25 | não | salão C9 (2de07b0) | adds 97(26) blades 10(1) curse 39(7) eruptions 16(2) ritual 10(1) scythe 36(3) storm 40(4) |
| partida inteira | 0,25 | 0,2 | câmara (6bab080) | adds 63(16) blades 44(5) curse 25(5) ritual 10(1) scythe 36(3) |
| partida inteira | 0,25 | 0,2 | salão C10 (196f33c) | adds 40(10) blades 139(15) curse 7(2) eruptions 30(3) ritual 10(1) scythe 48(4) storm 10(1) |
| kit do vídeo do C9 | 0,25 | não | câmara (6bab080) | adds 56(14) curse 52(9) eruptions 40(4) scythe 24(2) storm 30(5) |

`adds` são os mortos que ele levanta; `ritual` as erupções durante o ritual. Um golpe de cada: foice 12, lâminas 10, erupção
10, investida 12, maldição 6, tempestade 10, morto 4. Na câmara com afastamento a **investida não acerta ninguém** em 64
lutas (aparece em todas, nenhum dano dela).

## O que não foi medido
- Nada com gente: a dificuldade para o Daniel continua desconhecida.
- Partidas inteiras com reação 0 (o pedido era só 0,25).
- A comparação com o salão C9 com afastamento (a versão não tem a opção).

## Desempenho na placa de vídeo, 1920 x 1080 (medida, não simulação)

Sonda `C:/Users/danie/tools/qa/gpuperf9.gd` (a do ciclo 9, sem mudança): espera a cena, descarta os quadros de assentar e
mede 300 quadros (5 s): mediana, média e p90 do quadro (relógio), tempo de GPU e de CPU de desenho, chamadas e
primitivas. Comando: `MIRROR=<espelho> tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60
--disable-vsync -s C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave --seed=5 --start=boss --bot <cena>`;
fase 1: nada mais; ritual: `--boss-hp=0.67 --probe-wait=ritual --probe-settle=30` (Morvath em `RITUAL` nos 300 quadros);
fase 4: `--boss-hp=0.14 --probe-wait=phase4` (perseguição, foice e tempestade). Janela de 1920 x 1080 conferida em cada
rodada (`PROBE window (1920, 1080)`; o 3D é desenhado em 2880 x 1620 nas três versões). 3 rodadas, ordem alternada
(r1 câmara, C10, C9; r2 C10, C9, câmara; r3 como r1). **Na tomada em todas as 27 medidas**: `Win32_Battery.BatteryStatus`
2 e 100% de carga, lidos antes de cada uma.

| Cena | Câmara `6bab080`: quadro (3 rodadas) | p90 | GPU | Salão C10 `196f33c` | p90 | Salão C9 `2de07b0` | p90 | Chamadas câmara / C10 / C9 | Primitivas câmara / C10 / C9 |
|---|---|---|---|---|---|---|---|---|---|
| fase 1 | **3,99 ms** (4,05; 3,91; 3,99) | 4,25 a 4,47 | 3,91 | 4,92 (4,95; 4,92; 4,91) | 5,25 a 5,31 | 4,97 (4,97; 5,06; 4,96) | 5,20 a 5,38 | 991 / 938 / 936 | 737 mil / 739 mil / 737 mil |
| ritual | **4,07 ms** (4,04; 4,17; 4,07) | 4,47 a 4,65 | 3,96 | 5,21 (5,19; 5,21; 5,31) | 5,79 a 5,83 | 5,15 (5,16; 5,15; 5,11) | 5,72 a 5,77 | 1083 / 1041 / 1039 | 868 mil / 859 mil / 1,155 milhão |
| fase 4 | **4,11 ms** (4,14; 4,11; 3,95) | 4,24 a 4,78 | 4,00 | 4,93 (4,89; 5,00; 4,93) | 5,37 a 5,60 | 4,86 (4,86; 4,96; 4,85) | 5,23 a 5,47 | 1019 / 948 / 967 | 726 mil / 766 mil / 732 mil |

- **C11**: a câmara é **0,8 a 1,1 ms mais leve** que o salão nas três cenas (cerca de 245 FPS contra 200); p90 máximo 4,78 ms,
  abaixo da meta de 6,5 ms. Mais chamadas (+50 a +70), primitivas iguais ou menos.
- **C10** (C10 contra C9, ainda no salão): +0,06 ms no ritual, +0,07 na fase 4, -0,05 na fase 1: dentro da meta de no
  máximo +0,2 ms. O ritual do C10 desenha 25% menos primitivas (o escudo sem os pontos).
- Simulação sem tela, `tools/smoke.sh 30 --stress=300 --seed=5` (185 a 212 de pé no fim): `step_ms` 1,74 (câmara), 1,47
  (C10), 1,79 (C9); aos 10 s (243 de pé) 2,31 / 2,27 / 2,15. Dentro do ruído de uma medida só. O `step_ms` do
  `--smoke=120` (0,17 contra 0,05) é medido depois da sala limpa e não serve para comparar (ver o relatório).
