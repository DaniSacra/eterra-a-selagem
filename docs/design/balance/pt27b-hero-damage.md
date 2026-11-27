> Índice: [balance.md](../balance.md)

## PT-27b: dano do herói x2,25 e vida dos fortes (2026-11-27, balance-designer)
Pedido do Daniel: "jogo muito difícil; heróis dão pouco dano no capítulo 1". Régua: robô `tools/smoke.sh 900 --seed=1..12 --bot-reaction=0.25 --ultimate=cleave`
(Maestria baixa = sem Dons; média = `--talents=disciplina,cadencia,determinacao,concentracao,forca_concentrada,maestria_marcial`), HEAD `7a6800a7`.
O robô lê os avisos melhor que gente: serve para comparar versões, não como taxa de vitória real.

### Medido antes (HEAD, sem Dons)
- Chegam a Morvath 7 de 12; vencem 2 (a medida da sessão que pediu deu 5 e 0: a variação de 12 sementes é de 2 a 3 partidas).
- Onde morre (índice da sala, 15 = Morvath fase final): sala 10 (1), 11 (1), 12 (3), Morvath (5). Nenhuma morte nas salas 1 a 9.
- Quem machuca nas salas das mortes: mago 389, corpo a corpo (guardiões) 370, besteiro 336, Ancião 335, Cavaleiro 216 (soma das 12).
- Tempo por sala (médio, s): 1: 20, 2: 41, 3: 22, 4: 25 (as quatro de aprender, escritas curtas), 5 (guardião): 61, 6: 24, 7: 51, 8: 52, 9: 50, 10 (guardião): 66, 11: 47, 12: 48. Comuns 6 a 12 dentro de 24 a 52 s; a meta de 35 a 75 só se cumpre nas salas fundas.
- Golpes: esqueleto 250 de vida contra 20/20/40 do combo = **13 golpes leves** (muito mais que a meta de 3 a 5); elite 1500 = 75 golpes leves.
- Magia: `magick_refused` = 0 nas 12 partidas (nenhum golpe de segurar foi negado por falta de Magia; Esmagador 12 e Lança 20 com os 15 a 20% de volta por acerto do combo bastam). A Magia não limita nada hoje no robô; quem quiser um limite sobe o custo, não baixa.

### Passos medidos (12 sementes, sem Dons)
| Versão | Chega a Morvath | Vence | Tempo sala comum (6 a 12) | Observação |
|---|---|---|---|---|
| Antes | 7 | 2 | 24 a 52 s | |
| A: combo x2,5 (50/50/100) | 11 | 9 | 28 a 41 s | fácil demais, sala 1 em 11 s |
| B: A + elites 1,6x, grandes 1,5x, guardiões 1,5x, Morvath 2,0x | 10 | 5 | 32 a 52 s | |
| C: B com Morvath 2,4x e elites 1,8x, combo x2,5 | 10 | 7 | 33 a 48 s | robô vence demais |
| **D (aplicado): combo x2,25 (45/45/90), elites 1,8x, grandes 1,5x, guardiões 1,5x, Morvath 2,4x** | **11** | **3** | **34 a 53 s** | mortes: sala 14 (4), Morvath (4), 1 preso na sala 8 |
| D com Maestria média (6 Dons de nível 1) | 12 | 8 | | meta pede "mais que sem Maestria": cumpre |
| E (descartado): D com mago 0,875 para 1,05 s e barragem de Morvath 0,7 para 0,85 s de aviso | 12 | 7 | | o robô aproveita o aviso; ver recomendação abaixo |

### Números aplicados (`tools/make_data.gd`, regerados `combos enemies`)
| Item | Antes | Depois |
|---|---|---|
| `HERO_X` (novo, multiplica o combo): golpe 1 e 2 | 20 | **45** |
| golpe 3 (giro) | 40 | **90** |
| Corte Circular (pesado, toque) | 40 | **90** |
| Quarto e quinto golpe da Maestria Marcial (`EXTRA.damage`) | 20 | **45** |
| Elites (`ELITE_HP_X`) e Capitão: vida | 1250 a 1500 | **x1,8** (2250 a 2700; `trinca_elite` fica) |
| Esqueleto e Corredor maiores (`BIG_HP_X`) | 500 | **750** |
| Cavaleiro e Ancião (`GUARDIAN_HP_X`) | 3000 / 2500 | **4500 / 3750** |
| Morvath (`MORVATH_HP_X`) | 6000 | **14400** |
| Esmagador, Lança, Brado, perigos, vida do herói, dano e tempo de aviso dos inimigos | | sem mudança |
Comuns ficam com a vida do SWORN: esqueleto 250 = 45+45+90+45+45 = **5 golpes** (era 13); corredor 200 = 4; besteiro 150, mago 175 = 3 a 4; rato e morto invocado (20) 1 golpe.
Os fortes crescem porque o herói bate 2,25x mais: um elite leva 50 a 60 golpes (antes 75), o Morvath ao redor de 3 vezes mais vida em troca de 2,25x de dano, então a luta com ele fica cerca de 7% mais longa (o Dom e as Bênçãos somam em cima).

### Depois (D)
- Sem Dons: 11 de 12 chegam a Morvath (meta 7 a 9: acima), 3 vencem (meta 2 a 4: dentro). Quase todas as derrotas são no Morvath com 200 a 4500 de vida dele sobrando (variação grande); mortes por sala 14: 4, 15: 4.
- Com Maestria média: 12 chegam, 8 vencem.
- O robô chega mais longe que a meta porque as salas 1 a 12 ficaram bem mais curtas e baratas em vida; a dificuldade de verdade se concentra no Morvath. Se o Daniel achar o meio fácil demais, o próximo botão é `ELITE_HP_X` para 2,2 (elites são onde o robô perde vida nas salas 10 a 12), nunca o dano do herói de novo.
- Mago continua o que mais machuca (154 a 347 nas partidas que morreram) e a barragem do Morvath a seguinte: candidatos para mais aviso.

### Pendências e o que medir depois
1. **Tempo de reação (sem aplicar)**: mudar o aviso do mago (0,875 s para 1,05 s) e da barragem de Morvath (0,7 s para 0,85 s) deixa o robô 12 de 12 em Morvath e 7 vitórias; para gente que não lê tão bem isso é provavelmente o que mais ajuda, mas a regra pede o `combat-feel-director`, e o pedido anterior do Daniel era "ataca mais rápido" nos comuns. Deixei como proposta para ele.
2. Pedir ao Daniel o `runs.jsonl` dessa versão: a sala em que gente morre confirma se o muro continua no Morvath e nos elites das salas 10 a 12.
3. Maestria alta (10 a 20) e Dons com ultimates não foram medidos: a régua com 6 Dons já vence 8 de 12.
4. O `HERO_X` e as vidas dos fortes são constantes no topo de `make_data.gd`, um número para ajustar de volta.
