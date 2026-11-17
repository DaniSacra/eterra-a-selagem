# E2: métricas do QA (E2-12)

- **Data**: 2026-11-17. **Testado**: `arpg-3d` no `ec8529c` (E2 integrada), mais a correção dos dois testes instáveis
  deste QA (só `tests/`). **Base**: `3d82202` (E1c aprovada), copiada por `git archive` para `/home/dani/tools/e2/qa/base_3d82202`
  (robô sem tela) e espelhada em `C:/Users/danie/tools/eterra-gpu-head` (GPU).
- Logs: `docs/gallery/e2/qa/logs/` (as 32 descidas em `logs/descents/`). PNG originais em `/home/dani/tools/e2/qa/`.
- São simulações do robô, não gente. O robô pune quase toda janela de Morvath.

## 1. Maestria 1 contra Maestria 20 (meta da E6: até 25 pontos)

Comando, sementes 1 a 16, 60 qps fixos, sem tela:
- Maestria 1 (sem Dons, sem ultimate): `tools/smoke.sh 400 --seed=N --bot-reaction=0.25`
- Maestria 20 simulada: o mesmo com `--talents=quarto_corte,passo_encadeado,impeto,avanco_feroz,corte_crescente,lamina_faminta,fio_longo,reserva,firmeza --ultimate=cleave`
  (os seis iniciais, Fio Longo, Reserva e Firmeza: custo 21 de Devoção 25). Conferido no registro da partida
  (`--runlog`): os nove ficam equipados e a ultimate é `cleave`.

| | Vitórias 1 a 8 | Vitórias 9 a 16 | **Total** | Vida média ao chegar em Morvath | Dano levado antes de Morvath (soma das 16) | Luta média | Descida média | Chega em Morvath aos |
|---|---|---|---|---|---|---|---|---|
| Maestria 1 | 4 de 8 | 4 de 8 | **8 de 16 (50%)** | 34,9 | 76 | 116,5 s | 243,0 s | 108 a 151 s |
| Maestria 20 | 6 de 8 | 6 de 8 | **12 de 16 (75%)** | 40,3 | 123 | 101,9 s | 211,8 s | 93 a 117 s |

**Diferença: +25 pontos** (nas duas metades da amostra separadas: +25 e +25). Fica **no limite** da meta da E6, não acima.
Todas as 8 derrotas da Maestria 20 e 6 das 8 da Maestria 1 foram nas fases 3 e 4. A ultimate U-1 foi usada 3 a 5 vezes por
descida e tirou 491 a 1842 de vida (Morvath tem 6050). Amostra de 16 por lado: um ponto a mais ou a menos muda a conta em
6 pontos; tratar como indicação.

Observação: com os Dons o robô leva **mais** dano antes de Morvath (123 contra 76 nas 16), mesmo descendo 31 s mais
rápido. Causa não medida (hipótese: combo de 4 golpes plantado deixa o robô parado mais tempo).

Tabela por semente: `docs/gallery/e2/qa/logs/descents_table.md`.

## 2. Regressão do robô (`--seed=5`)

| Comando | Base `3d82202` | E2 `ec8529c` |
|---|---|---|
| `tools/smoke.sh 300 --seed=5` | vence, 254,7 s, Morvath (sala 7) aos 131,5 s, hp 50, 41 abates, avg 0,17, pico 7,64 | **vence, 261,2 s, Morvath (sala 7) aos 131,5 s**, hp 40, 49 abates, avg 0,18, pico 5,70 |
| `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` | (não rodado com 120) | **não termina em 120 s**: Morvath com 21 de vida, fase 4, hp 27 |
| `tools/smoke.sh 240 --start=boss --boons=25 --seed=5` | vence em 103,1 s de luta (106,7 s), hp 24 | **vence em 124,0 s**, hp 28, fases 28,7 / 42,4 / 21,4 / 27,9 s |
| o mesmo, 120 s, com os nove Dons e `--ultimate=vortex` | | vence em 91,6 s de luta, hp 29, Voragem 1 uso, 268 de dano |

A luta de 25 Bênçãos ficou 21 s mais longa (Morvath com camadas nas fases 3 e 4): o comando de regressão do `CLAUDE.md`
com 120 s não chega mais ao fim nessa semente.

## 3. Desempenho

| Medida | Base `3d82202` | E2 |
|---|---|---|
| `tools/smoke.sh 120 --stress=300 --seed=5`, sem tela, sozinho | avg **2,37** ms, pico 20,28, 312 abates | avg **2,41** ms, pico 20,22, 312 abates |
| GPU, `tools/gpu.sh shot ... --stress=300 --seed=5 --shot-at=8` (1672x941, Forward+, RTX 5060), intercalado E, B, E, B | `fps` 52 / 52; `step_ms_avg` 12,81 / 12,77 | `fps` **52 / 53**; `step_ms_avg` 11,87 / 12,50 |

Sem diferença de desempenho. O `gpu.sh` roda com `--fixed-fps 30`; o `step_ms_avg` dele inclui os passos com 300 de pé na
Godot de Windows e não se compara com o sem tela. Não medido: placa fraca, celular, Compatibility em tempo de quadro.

## 4. Capturas na GPU (1920x1080, Forward+, abertas e olhadas)

| Arquivo | Comando (`RES=1920x1080 tools/gpu.sh shot <saída> ...`) | O que mostra |
|---|---|---|
| `qa/u1_cleave_gesture_1080.jpg` | `--bot --autopick --seed=5 --ultimate=cleave --ult-full --shot-at=6 --shot-on=ult-gesture --shot-after=0.15` | U-1 Corte do Juízo: o herói erguendo a Emeth e a faixa 12 x 4 m marcada no chão (Cripta, sala 2) |
| `qa/u1_cleave_1080.jpg` | o mesmo com `--shot-on=ult --shot-after=0.05` | o golpe: corte verde pela faixa, três esqueletos com 300, 300 e 200 |
| `qa/u2_vortex_1080.jpg` | `--ultimate=vortex ... --shot-on=ult-gesture --shot-after=0.6` | U-2 Voragem: aro verde no chão em volta do herói, inimigos dentro com tiques de 9 |
| `qa/spin_corte_crescente_1080.jpg` | `--bot --autopick --seed=5 --talents=corte_crescente --shot-at=4 --shot-on=spin --shot-after=0.12` | giro com Corte Crescente: meia-lua do giro, brilho, traço verde da onda e o acerto dela num esqueleto (salão) |
| `qa/spin_corte_crescente_wave_1080.jpg` | o mesmo com `--shot-after=0.3` | 0,3 s depois: a onda já se desfez, número 17 no esqueleto |
| `qa/hero_screen_1080.jpg` | `--title --screen=hero --hero-xp=2470 --hero-equip=<os nove> --shot-at=3` | tela do herói: Maestria 20 completa, Devoção 21 de 25, árvore, detalhe do Golpe sem Fim, as duas ultimates |
| `qa/stress300_head_941.jpg` | `--stress=300 --seed=5 --shot-at=8` (1672x941) | os 300 do estresse (a captura da medida de FPS) |
