# E1a "Inimigos vivos": DEPOIS

- Data: 2026-11-16. Testado: a cópia de trabalho de `arpg-3d` com a E1a inteira **não commitada** sobre o `10944b1`
  (assados novos, `BakedModel` com `mesh`/`positions`/`normals`/`frames`/`first`/`ground_speed`, `crowd_pose.gdshaderinc`,
  `HitRecoil`, `Horde.walk_rate`, `Game.result_line`, armas). O QA não mudou código, arte nem testes.
- Base para o lado a lado: `git archive 10944b1` no scratchpad (rodadas na CPU) e o espelho
  `C:/Users/danie/tools/eterra-gpu-head` (rodadas na GPU, sincronizado a partir dessa cópia do `10944b1`).
- Depois na GPU: espelho próprio `C:/Users/danie/tools/eterra-gpu-e1a` (Godot 4.7.2 de Windows, Vulkan, Forward+, RTX 5060
  Laptop). **Na tomada** durante todas as medidas de quadro: `BatteryStatus=2`, `PowerOnline=True`, carga 87% a 92%, lido
  no Windows antes e depois de cada bloco (`logs/gpu_perf_*.log`).
- Mesmos comandos do `before/BEFORE.md` seção 3. Diferenças: o `qa_e1a_strip.gd` ajustado (`tools/qa_e1a_strip.gd`, abaixo),
  um script de leitura dos assados (`tools/qa_e1a_poses.gd`) e duas medidas a mais (base e depois intercalados na GPU, e o
  `RESULT` campo a campo com a mesma semente nas duas versões).

## 1. Números, antes e depois

| Medida | Antes (`10944b1`) | Depois (E1a) |
|---|---|---|
| `--import` e `tools/check.gd` | 0 erros | **0 `SCRIPT ERROR`, 0 `Parse Error`**, `CHECK ok` (`logs/import.log`, `logs/check.log`) |
| `tools/test.sh` | 55 scripts, 541/541, 0 arriscados | **58 scripts, 557/557, 0 falhando, 0 arriscados**, 104 890 asserções, 124,4 s (`logs/test_summary.log`) |
| Sonda de game feel | 31/31 | **`FEEL_SUMMARY 31/31 ok`**, 0 `LOST` (`logs/feel_probe.log`) |
| `tools/smoke.sh 300` (sem semente) | Morvath sala 7 aos 122,6 s, vence, `step_ms_avg` 0,22, pico 8,49 | Morvath sala 7 aos 135,4 s, **vence** (hp 8), 50 abates, `max_alive` 7, **`step_ms_avg` 0,18**, pico 4,77 (sem semente: a partida é outra, não comparar os números de jogo) |
| `tools/smoke.sh 120 --start=boss --boons=25` (sem semente) | vence em 52,8 s, avg 0,20, pico 4,91 | **vence** em 69,2 s, 10 dons, **avg 0,18**, pico 9,78 |
| 8 descidas `--seed=1..8` | 8/8 vencem, `stuck` 0 | **8/8 vencem, `stuck` 0, `bot.stuck` 0**; tempo, hp, abates e `max_alive` **idênticos** aos do antes nas 8 (tabela 1.1); avg 0,18 a 0,20 (antes 0,18 a 0,22), pico 4,54 a 6,3 (antes 4,56 a 10,14) |
| `--stress=150 --seed=5` (sem tela) | avg **1,28**, pico 11,18, 160 abates, dano 19 692 | avg **1,02**, pico 12,66, **160 abates, dano 19 692** (iguais) |
| `RESULT` com a mesma semente, campo a campo (base e depois rodados agora) | | `--seed=5` 300 s e `--start=boss --boons=25 --seed=5`: **0 diferenças** fora de `step_ms*` e `fps` (`logs/base_rerun.log`, `logs/after_rerun.log`) |
| `RESULT` é JSON | não (`&"scythe"`) | **sim**: as 13 linhas `RESULT` desta sessão (`--start=boss` incluído) passam no `json.loads` do Python; antes era preciso tirar o `&` |
| `du -sh assets/baked` | 45 MB (46 714 106 bytes) | **38 MB (39 070 051 bytes)**, teto 70 MB (`baked_sizes.txt`) |
| Quadro na GPU, 150 inimigos, 1080 sem vsync, 3 vezes (`gpuperf9`) | frame 9,41 / 8,88 / 8,77; gpu 5,63 / 5,87 / 5,85 (outra sessão) | frame 6,76 / 7,50 / 7,11; gpu 6,55 / 6,68 / 6,34; cpu_render 0,89 a 1,09; **995 chamadas de desenho** (antes 1032) (`logs/gpu_perf_stress150.log`) |
| **Mesma medida, base e depois intercalados** (B, D, B, D, B, D, mesma sessão) | frame 7,60 / 7,09 / 7,79 (média **7,49**); gpu 6,31 / 6,36 / 6,31 (**6,33**); cpu_render 1,21 / 1,08 / 1,23 | frame 7,25 / 6,86 / 7,82 (média **7,31**, **menos 0,18 ms**); gpu 6,72 / 6,56 / 6,60 (**6,63, mais 0,30 ms**; por par +0,41 / +0,20 / +0,29); cpu_render 1,03 / 0,92 / 1,11 (menos 0,15) (`logs/gpu_perf_interleaved.log`) |
| `gpu.sh shot --stress=150 --seed=5 --shot-at=8` (vsync, 1672x941, só referência) | fps 128 / 115 / 120 | fps 117 / 127 / 132 (`logs/gpu_stress150.log`, `stills/stress150_shot*.jpg`) |

A diferença entre a sessão do antes (frame 8,8 a 9,4) e a base rodada hoje (7,1 a 7,8) é maior que o efeito medido: só a
comparação intercalada vale para o aceite.

### 1.1 Descidas com semente (antes e depois)

| Semente | antes: tempo, hp, abates | depois: tempo, hp, abates, dano, `boss_at`, dons no chefe |
|---|---|---|
| 1 | 238,3, 30, 36 | 238,3, 30, 36, 11 500, 111,1, 4 |
| 2 | 256,2, 30, 47 | 256,2, 30, 47, 12 676, 139,8, 3 |
| 3 | 230,2, 3, 60 | 230,2, 3, 60, 13 539, 122,8, 3 |
| 4 | 281,9, 36, 57 | 281,9, 36, 57, 13 028, 148,2, 2 |
| 5 | 282,5, 45, 52 | 282,5, 45, 52, 12 789, 122,9, 2 |
| 6 | 216,4, 30, 55 | 216,4, 30, 55, 13 190, 120,9, 2 |
| 7 | 205,3, 8, 49 | 205,3, 8, 49, 11 834, 115,4, 2 |
| 8 | 191,6, 50, 46 | 191,6, 50, 46, 12 035, 107,6, 3 |

### 1.2 Poses assadas (`baked_poses.txt`, lidas do `BakedModel` novo)

| Inimigo | andar | golpe sofrido | parado | morte | passo medido (`ground_speed`) | pé de apoio desliza (`slide_per_step`) | taxa do andar no jogo (`walk_rate`), antes |
|---|---|---|---|---|---|---|---|
| esqueleto | 20 poses, 18,7 qps | 8, 24 | 12, 4,8 | 16, 8,4 | 3,83 m/s | **2,4 cm** | 0,85x (antes 1,6x) |
| corredor | 20, 18,7 | 8 | 12 | 16 | 4,03 | 1,1 cm | |
| mago | 20, 18,7 | 8 | 12, 9,5 | 16 | 3,75 | **1,8 cm** | 0,74x (antes 1,52x) |
| besteiro | 20, 18,7 | 8 | 12 | 16 | 3,56 | 1,7 cm | |
| Escudo (guard) | 20, 15 | 8 | 12 | 16 | 1,08 | **10,7 cm** | **2,01x** (antes 1,41x) |
| sacerdote | 20, 15 | 8 | 12 | 16 | 0,93 | 9,7 cm (não anda: velocidade 0) | |
| Cavaleiro | 20, 15 | 8 | 12 | 16 | 1,13 | **10,2 cm** | |
| sacerdote ancião | 20, 15 | 8 | 12 | 16 | 1,37 | 4,5 cm | |
| Morvath | 20, 15 | 8 | 12 | 16 (+ 12 clipes, 8 a 20 poses) | 1,19 | **5,8 cm** | 1,25x (antes 1,6x) |

Os três acima de 5 cm (Escudo, Cavaleiro, Morvath) são a exceção escrita no próprio teste (`STRIDE_PENDING` em
`tests/test_living_crowd.gd`: "no worse than measured", conserto na E1b).

### 1.3 Pose repetida em quadros seguidos a 30 qps

Hash dos pixels de cada quadro contra o anterior (`pose_repeats.txt`) e o índice da mistura (`strip_blend_index.txt`:
pose, pose seguinte e fração em cada quadro):

| Inimigo | andar (23 pares) | golpe sofrido (9) | morte (39) |
|---|---|---|---|
| esqueleto | **0** (antes 10) | 0 (antes 6) | **0** (antes 32) |
| mago | **0** (antes 11) | 0 (6) | 0 (32) |
| Escudo | **0** (antes 15) | 0 (6) | 0 (32) |
| Morvath | **0** (antes 14) | 0 (6) | 0 (32) |

PSNR entre quadros seguidos do andar (`pose_psnr_walk.txt`): antes alternava `inf` (igual) e cerca de 24 dB (salto);
depois todos os pares mudam, de forma regular, entre 25 e 35 dB (o par mais parecido: mago, 35,1 dB). O golpe sofrido
das tiras leva o deslocamento do `HitRecoil` (o hash muda também por ele; a mistura sozinha já muda a pose em todo quadro,
ver o índice).

## 2. Arquivos

- `skeleton_walk_contact_12.png`: 12 quadros seguidos do esqueleto andando a 30 qps. `compare/skeleton_walk_contact_before_after.png`.
- `strips/poses_walk_hit_death_{1x,025x}.mp4`: esqueleto, mago, Escudo e Morvath (andar 24, golpe 10, morte 40 quadros).
  `compare/strip_before_after_{1x,025x}.mp4`: antes à esquerda, depois à direita.
- `compare/skeleton_hit_recoil_after.jpg`: 10 quadros do golpe sofrido com grade de 60 px: o corpo vai 0,21 m no 2º quadro,
  0,24 m no 3º e volta a 0 no 10º (valores em `strip_blend_index.txt`, `x=`).
- `video/fight_skeleton_mage_guard_{1x,025x}.mp4`, `video/morvath_fight_*`, `video/morvath_death_bosshp02_*`: mesmos
  comandos do `movie.sh` do antes (espelho próprio), mesma duração. `compare/*_before_after_{1x,025x}.mp4`: lado a lado.
  A simulação é a mesma quadro a quadro (mesma semente): `stills/fight_f100.jpg` e `before/stills/fight_f100.jpg` têm todos
  nas mesmas posições; muda só a pose.
- `compare/fight_f90_101_before_after.jpg`: quadros 90 a 101 da luta, recortados, antes em cima e depois embaixo.
- `stills/*.jpg`: quadros da luta e de Morvath, 3 capturas do estresse de 150.
- `logs/`: saídas brutas. `tools/`: os dois scripts usados. AVIs brutos em `C:/Users/danie/tools/e1a_lab/after_*.avi`,
  PNGs das tiras em `C:/Users/danie/tools/e1a_lab/after_out/`.
- `weapons/` é do `environment-artist` (não refeito); `art_review/` é do `art-director`.

## 3. Comandos (além dos do `before/BEFORE.md`)

```sh
M=/mnt/c/Users/danie/tools/eterra-gpu-e1a
MIRROR=$M tools/gpu.sh sync && cp docs/gallery/e1a/after/tools/qa_e1a_strip.gd $M/tools/
flock /tmp/eterra-gpu.lock $G --path 'C:\Users\danie\tools\eterra-gpu-e1a' --rendering-driver vulkan --resolution 640x720 \
  -s res://tools/qa_e1a_strip.gd -- C:/Users/danie/tools/e1a_lab/after_out
~/tools/godot/godot --headless --path . -s docs/gallery/e1a/after/tools/qa_e1a_poses.gd
# base: git archive 10944b1 | tar -x -C <scratch>/base; nela --import e os smokes com semente; na GPU
#   MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-head <scratch>/base/tools/gpu.sh run ... gpuperf9 (intercalado com o depois)
```

Ajuste do `qa_e1a_strip.gd`: o andar usa a taxa do jogo novo (`Horde.walk_rate`: velocidade do inimigo sobre
`ground_speed` vezes o tamanho), o golpe sofrido soma `HitRecoil.offset(t, heavy)` de lado na tela, e o índice grava a
mistura (`blend_at`). A chamada `CrowdRenderer.add` não mudou de assinatura.

## 4. Aceite da E1a

| Item | Aceite | Resultado |
|---|---|---|
| E1a-1 (VX-04) | pose repetida a 30 qps no andar = 0; andar 20+, golpe 8, parado 12, morte 16 | **passa**: 0 de 23 nos quatro; 20 / 8 / 12 / 16 em todos os nove |
| E1a-1 | assados até 70 MB | **passa**: 38 MB (era 45) |
| E1a-1 | `step_ms` sem piora | **passa**: estresse 150 avg 1,28 para 1,02; descidas 0,18 a 0,20 |
| E1a-1 | quadro na GPU sem piora acima de 0,3 ms (estresse 150) | **passa no limite**: tempo de quadro 0,18 ms menor; o tempo só da GPU sobe 0,30 ms na média (0,20 a 0,41 por par). Ver o relatório |
| E1a-2 (VX-05) | pé de apoio desliza menos de 5 cm por passo | **parcial**: esqueleto, corredor, mago, besteiro, ancião passam (1,1 a 4,5 cm); **Escudo 10,7, Cavaleiro 10,2, Morvath 5,8 não** (exceção escrita no teste) |
| E1a-3 (VX-06) | recuo de 0,15 a 0,3 m visível em 3 quadros e volta; números de combate iguais | **passa** nas tiras (0,24 m leve, 0,15 m pesado, pico no 3º quadro a 30 qps, volta em 0,3 s) e nos números (0 diferenças); na partida a 1080 o recuo é de uns 11 px e pouco se distingue no meio do golpe (`compare/fight_f90_101_before_after.jpg`). `--shot-on=hit` não rodado |
| E1a-4 (VX-07) | armas | do `environment-artist` e `art-director` (não refeito aqui) |
| E1a-5 (B-c) | `RESULT` em JSON | **passa** (13 de 13 linhas; teste `test_result_json.gd` na suíte) |
| E1a-QA | 541+ testes, sonda 31/31, 8 descidas, vídeos 1x e 0,25x | **passa**: 557, 31/31, 8/8, vídeos e lado a lado |
