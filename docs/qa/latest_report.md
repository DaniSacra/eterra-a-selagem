# Relatório de QA e desempenho: fechamento do ciclo 7

- **Data**: 2026-11-15, 17:00 a 17:45
- **Branch**: `arpg-3d`, **commit testado `7fb5b4b`**. Working tree: só `CLAUDE.md` modificado (texto, do Game Director,
  sem código) e `tests/test_fx_on_hit.gd.uid` gerado pela importação (ver B1).
- **Antes**: `5429394` (início do ciclo 7), extraído por `git archive` em `/home/dani/games/eterra-before-5429394` e
  espelhado em `C:/Users/danie/tools/eterra-gpu-before`.
- **Ambiente**: WSL2 (Linux 6.18). Testes e partidas do robô sem tela (Godot 4.7.2 Linux). Capturas e medidas de quadro na
  **placa de vídeo real** (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan 1.4.357, Forward+, Godot 4.7.2 Windows) por
  `tools/gpu.sh`. **Sem som** (não verificado).

Saídas brutas em `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/c7qa/`
(abaixo `c7qa/`): `out/` (testes, partidas, desempenho), `shots/` (PNG originais), `before/` (capturas do `5429394`).
Galeria do ciclo: `docs/gallery/cycle7/` (comandos em `docs/gallery/cycle7/CAPTURAS.md`).

## Veredito

**Pronto para o Daniel testar**, do ponto de vista de QA: 0 `SCRIPT ERROR` e 0 `Parse Error` no commit testado; 219
testes, 218 passando, 0 falhando, 1 arriscado (o conhecido); fluxo do título ok; o robô chega em Morvath nas cinco
sementes com os mesmos números do ciclo 6 (nenhuma regra de jogo mudou). Uma regressão média de desempenho do lado da
CPU com hordas grandes (M1: +1,2 ms por quadro com 300 inimigos, ainda 112 quadros por segundo). O julgamento visual é
do `art-director` e do Daniel; os pontos visuais abaixo são observações para eles.

## 1. Checagem, testes e partidas do robô

| Comando | Resultado | Saída |
|---|---|---|
| `godot --headless --path . --import` | código 0, 0 SCRIPT ERROR, 0 Parse Error | `out/import.txt` |
| `godot --headless --path . -s tools/check.gd` | código 0, 0 SCRIPT ERROR, 0 Parse Error | `out/check.txt` |
| `tools/test.sh` | **21 arquivos, 219 testes, 218 passando, 0 falhando, 1 arriscado** (`test_only_finishers_glint`, "Did not assert"), 14475 asserções, 4,6 s | `out/test.txt` |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** (12 de 12: abre, foco, Como Jogar, Esc, Configurações, Sair, Iniciar começa, volta ao título) | `out/title_flow.txt` |

Partidas do robô, rodadas cruas (`godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=N ...`, saída
inteira, sem o `head` do `tools/smoke.sh`):

| Opções | Sala | Modo | Tempo | Abates | Dons | Vida de Morvath | step_ms | Linhas ERROR |
|---|---|---|---|---|---|---|---|---|
| `300 --seed=5` | 5 | OVER | **183,5** | **20** | 2 | **2623** (fase 2) | 0,06 | 1 |
| `120 --start=boss --boons=25 --seed=5` | 5 | PLAY | 118,3 | 21 | 8 | 5 (fase 3) | 0,12 | 1 |
| `120 --stress=300 --seed=5` | 1 | PLAY | 118,1 | 259 (41 de pé) | 0 | | 0,36 | 1 |
| `120 --start=miniboss --seed=5` (guardião) | 5 | OVER | 95,2 | 1 | 1 | 4181 (fase 1) | 0,07 | 1 |
| `120 --start=miniboss --seed=2` (Ancião) | 5 | PLAY | 117,4 | 14 | 1 | 3413 (fase 2) | 0,09 | 1 |
| `60 --start=fountain --seed=5` | 5 | PLAY | 58,6 | 14 | 1 | 5455 | 0,05 | 1 |
| `60 --start=shop --seed=5` | 5 | PLAY | 59,6 | 0 | 0 | 4556 | 0,05 | 1 |
| `300 --seed=1` | 5 | OVER | 200,7 | 32 | 2 | 1382 (fase 3) | 0,11 | 1 |
| `300 --seed=2` | 5 | OVER | 153,1 | 16 | 2 | 3106 (fase 2) | 0,15 | 1 |
| `300 --seed=3` | 5 | OVER | 130,0 | 10 | 2 | 4001 (fase 1) | 0,06 | 1 |
| `300 --seed=7` | 5 | OVER | 213,4 | 51 | 2 | 994 (fase 3) | 0,18 | 1 |

- A linha pedida confere: `--seed=5` dá tempo 183,5, 20 abates, Morvath com 2623. Todas as linhas de semente 1, 2, 3,
  5 e 7 e as de chefe e estresse são **idênticas** às do relatório do ciclo 6 (só o `step_ms` oscila).
- Transições de sala: as partidas de 300 s passam sala 1, fonte (2), guardião (3), loja (4) e Morvath (5); a partir do
  guardião, da fonte e da loja também chegam em Morvath. Morvath chega à fase 3 (`--boons=25`, sementes 1 e 7).
- **Linhas `ERROR` numa partida inteira**: 1 por execução, sempre a mesma, ao sair:
  `ERROR: 1 resources still in use at exit` (com o aviso `2 ObjectDB instances were leaked`), igual ao ciclo 6 (B4).
  Nenhum `SCRIPT ERROR`. Saídas `out/raw_*.txt`.
- Elites: o robô sempre pega a porta 0 (a fonte na sala 2), então não encontra elite numa partida normal (como no ciclo
  6). Os elites foram vistos pelo `--stress-ids` (`11_inimigo_elite`) e no laboratório (`09`).

## 2. Desempenho na placa de vídeo

RTX 5060 Laptop, Vulkan Forward+, 1672 x 941, `--fixed-fps 30 --disable-vsync`, `--seed=5`. Sonda
`C:/Users/danie/tools/qa/gpuperf.gd` (descarta 300 quadros, mede 300). Três rodadas alternando antes e depois; a
tabela traz a mediana das três medianas. Linhas cruas em `out/gpu_perf.txt` (script `c7qa/perf.sh`).

| Cena (`--seed=5 ...`) | Quadro antes | Quadro depois | Diferença | FPS antes / depois | GPU antes / depois | CPU de desenho antes / depois | Chamadas antes / depois | Primitivas depois |
|---|---|---|---|---|---|---|---|---|
| `--bot --autopick` (luta) | 2,67 ms | 2,76 ms | +0,09 | 375 / 362 | 2,56 / 2,66 | 0,86 / 0,87 | 1002 / 971 | 938 mil |
| `--bot --autopick --stress=40` | 2,71 ms | 2,74 ms | +0,03 | 369 / 365 | 2,62 / 2,68 | 0,85 / 0,88 | 1021 / 995 | 788 mil |
| `--bot --autopick --stress=90` | 3,65 ms | 4,13 ms | **+0,48** | 274 / 242 | 2,58 / 2,60 | 1,00 / 1,07 | 1100 / 1080 | 1,35 milhão |
| `--bot --autopick --stress=300` | 7,70 ms | 8,89 ms | **+1,19** | 130 / 112 | 3,04 / 3,12 | 1,16 / 1,32 | 1002 / 978 | 2,29 milhões |

Rodadas individuais (quadro, mediana): `--stress=90` antes 3,65 / 3,49 / 3,82, depois 4,13 / 4,17 / 3,81;
`--stress=300` antes 7,70 / 7,58 / 8,17, depois 8,89 / 8,96 / 8,32. FPS = 1000 / quadro mediano.

Salão sem luta, sonda por tempo `C:/Users/danie/tools/qa/gpuperf_arena.gd` (7 s de espera, 5 s de medida;
`out/gpu_perf_arena.txt`), duas rodadas: `--start=fountain` 2,41 e 2,40 ms antes, 2,46 e 2,46 ms depois (+0,06; GPU 2,27
para 2,32 ms).

Leitura:
- A GPU quase não mudou (no máximo +0,1 ms em todas as cenas). A alta com hordas é do lado da CPU: com 300 inimigos o
  desenho na CPU sobe 0,16 ms e o resto (cerca de 1 ms) está fora da simulação, porque o `step_ms` sem tela é o mesmo
  do ciclo 6 (0,36 ms com 300). Ver M1.
- Guarda do ciclo anterior (no máximo +0,5 ms com 90): passa no limite (+0,48), e a 3ª rodada deu empate.
- **Vitrine `--showcase`: NÃO MEDIDO.** As duas sondas leem só 192 chamadas e cerca de 2,8 mil primitivas no
  viewport principal com `--showcase` (antes e depois), o que não é o salão desenhado; o número (0,9 ms) não é
  confiável e ficou fora da tabela.
- **NÃO MEDIDO**: celular, navegador real, placa de vídeo fraca, versões exportadas (não pedidas neste ciclo).
- No `gpu.sh shot` de 90 inimigos (uma amostra, janela em 30 quadros) o `step_ms` foi 1,02 antes e 1,56 depois; é uma
  amostra só, citada como indício, não como medida.

## 3. Capturas (abertas e olhadas uma a uma)

25 arquivos em `docs/gallery/cycle7/` (22 do contrato, `06b`, `12b` e quatro montagens), 15,0 MB no total. Comandos,
resolução, renderizador, commit e momento de cada uma em `docs/gallery/cycle7/CAPTURAS.md`. Ajustes feitos:
- `07_emeth_impacto`: com `--shot-at=5` o golpe que acerta é o mesmo do `06` (quadros quase iguais, PSNR 47 dB); usei
  `--shot-at=7`, que mostra a estocada, o inimigo em reação e o número.
- `08_emeth_especial`: com `--shot-after=0.1` o dardo já chegou; usei `--shot-after=0.05` (dardo saindo da lâmina). O
  alvo está a cerca de 2 m nesta semente, então nenhum quadro mostra o dardo longe no ar.
- Os auxiliares `08b_emeth_circulo`, `15b_porta_amarela` e `22b_hud_2560` não foram feitos (não pedidos nesta tarefa).

Antes e depois de mesmo comando deram a mesma linha `RESULT` (luta: 8,8 s, 2 abates, 761 de dano; 90 inimigos:
5,9 s, 8 abates, 1933; 18 inimigos: 4,9 s, 1 abate, 384), então as montagens comparam o mesmo instante.

## 4. Falhas e regressões por gravidade

Nenhuma crítica nem alta.

### Média

**M1. Custo de CPU por quadro subiu com hordas grandes** (regressão do ciclo 7). `--stress=300`: 7,70 para 8,89 ms
(130 para 112 FPS); `--stress=90`: 3,65 para 4,13 ms. GPU e simulação sem tela não mudaram, então o custo está no
trabalho por quadro do desenho (candidatos: `EnemyFx` dos preparos de ataque, barras mais finas e efeitos de armadura
do commit `760f335`; raio-x e borda do herói do `31098c5`; não isolei qual). Reproduzir: `c7qa/perf.sh` (ou
`tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 --fixed-fps 30 --disable-vsync -s
C:/Users/danie/tools/qa/gpuperf.gd -- --nosave --seed=5 --bot --autopick --stress=300` no antes e no depois).
Responsável sugerido: Gameplay Engineer (`scripts/render/`, `EnemyFx`, `CrowdRenderer`), com perfil por commit. Ainda
acima de 100 FPS no notebook; sem medida em máquina fraca.

### Baixa (visuais: decisão do `art-director`)
- **B2. Luz do portal continua verde na sala de Morvath com o portal vermelho.** `scripts/game/catacomb_hall.gd:578-581`
  cria a luz que escorre pelos degraus (`SPILL_COLOR` verde, linha 151), mas `ArenaKit.light_portal`
  (`scripts/game/arena_kit.gd:574`) só pinta a folha e as luzes do próprio portal; `Arena.open_door`
  (`scripts/game/arena.gd:253`) deixa o derrame verde. Evidência: `13_morvath.jpg` (portal vermelho, degraus e chão
  verdes). Vem do ciclo 6 (`37631ab`), não é regressão. Responsável: Environment Artist.
- **B3. Herói atrás do obelisco parece em pé em cima dele.** Desenhado inteiro através da pedra, com o anel por cima
  (`05_explorador_corrida.jpg`, `11_inimigo_elite.jpg`). É o raio-x pedido, mas lê como se estivesse no topo.
  Responsável: Art Director decide.
- **B4. Inimigos atingidos ficam brancos chapados de corpo inteiro** por um ou dois quadros (`06`, `07`, `08`, `06b`); no
  Ômega, dois inimigos viram uma mancha branca que cobre o herói (`06b_emeth_omega.jpg`). Art Director decide.
- **B5. Herói menos achável no bolo de 90 do que no antes** (`before_after_combate.jpg`, linha de baixo: o ciano antigo
  saltava; agora são as cores dele, dá para achar mas leva mais tempo). Risco já previsto no `cycle7_spec.md` seção
  10. Art Director.
- **B6. No `19_combate_40_inimigos.jpg` o herói fica perto da borda esquerda**, aparentemente perto do limite de 18% do
  `CamFrame.SAFE`; não medi em pixels. Gameplay Engineer confere se quiser.
- **B1. `tests/test_fx_on_hit.gd.uid` não está no commit**: a importação gera e o working tree fica sujo. Game Director.
- **B7. Vazamento ao sair** (`2 ObjectDB instances leaked`, `1 resources still in use`), igual a antes.

### Resolvidos desde o ciclo 6
- **M1 antigo (elite comum com a barra de chefe)**: `game.gd:777-785` (`boss_enemy`) só devolve chefe e
  `stage.minibosses`; `11_inimigo_elite.jpg` sem barra no topo.
- **SCRIPT ERROR do `5429394`**: na captura de antes com `--stress=90` saiu `Invalid call. Nonexistent function
  'finish_intro' in base 'Nil'` (`c7qa/before.log`); o `7fb5b4b` tem a guarda em `scripts/boot.gd:117-119`
  (`if _menu == null`) e não repete (0 SCRIPT ERROR em todas as capturas de agora, `c7qa/shots.log`).
- B3 antigo (espaçamento da premissa no título): a tela nova não tem esse texto.

## 5. Limitações
- Desempenho só no notebook do Daniel (RTX 5060), janela 1672 x 941; rodadas iguais variam até cerca de 0,6 ms com
  300 inimigos. Vitrine não medida (ver seção 2).
- Sem som; sem gente jogando (só o robô): sensação e leitura em movimento ficam para o Daniel.
- As capturas abrem uma janela na tela do Daniel durante a execução.
- Não alterei código de jogo nem arte. Criei fora do projeto `/home/dani/games/eterra-before-5429394` (cópia do
  `5429394`) e o espelho `C:/Users/danie/tools/eterra-gpu-before`; podem ser apagados. Nenhum commit.
