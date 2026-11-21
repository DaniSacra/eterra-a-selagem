# Relatório de QA e desempenho: Lote A, frente A8 (HUB-E, BUG-110, RS-F1, DT-RS3, MAP-05)

- **Data**: 2026-11-21. **Testado**: `arpg-3d` no **`07688f5`** (worktree isolada `/home/dani/games/qa-a8`) e, depois que
  o HEAD andou durante o trabalho, o **`343d251`** (worktree `/home/dani/games/qa-a8b`) para o que mudou no meio
  (controle, suíte, robô). As medidas de GPU são do `07688f5`; o `343d251` não traz aquecimento de shader nem mudança no
  que o DT-RS3 mede (nada de `warm`/`precompile` em `scripts/`).
- **Ambiente**: WSL2, sem som (ALSA cai no driver mudo). GPU pelo `tools/gpu.sh` (Godot de Windows, espelho próprio
  `C:\Users\danie\tools\eterra-qa`): RTX 5060 (Forward+ Vulkan e OpenGL 3.3) e iGPU Intel RaptorLake-S (`--gpu-index 1`).
  Outros agentes usavam os dois espaços da GPU ao mesmo tempo (as filas esperaram até 20 min) e escreviam no mesmo cache de
  shader; isso contamina as medidas "frias" (ver Limitações). Exe Linux exportado do `07688f5` (`build/linux` da worktree)
  rodado pelo OpenGL da RTX via D3D12 do WSL (`GALLIUM_DRIVER=d3d12`, `xvfb-run`). Exe do Windows não foi exportado
  nesta passada (não pedido nos itens).
- **Evidências**: `docs/qa/a8/` (capturas do hub, `logs/`, `scripts/` com as ferramentas de QA em `.txt`; as worktrees, o espelho `eterra-qa` e o vídeo bruto foram apagados no fim),
  `docs/gallery/dv1/map05/` (mapas de duas sementes).

## Veredito

**Sem P0 no HEAD `343d251`.** O controle não fechava nenhuma tela com B nem apertava botão com A no `07688f5` (P0 de
controle, achado aqui); o `343d251` corrigiu (DT-103) e conferi com eventos reais do controle. **Fica um P1 sério de
desempenho (DT-RS3)**: com o cache de shader vazio (primeira vez que o jogo roda, ou exe com shaders mudados), a iGPU
congela 11,7 s ao entrar na 1ª sala, 4 s nas Fendas e **17,6 s ao entrar na Câmara do Selo**, e há travadas de 1 a 3 s no
meio das salas nos primeiros efeitos. Com o cache quente cai para 0,5 a 1,9 s na entrada de cada sala, ainda muito acima
dos 50 ms do aceite. Não medido frio na RTX (ver Limitações).

| Item | Resultado |
|---|---|
| Importação (`--import`) | 0 `SCRIPT ERROR`, 0 `Parse Error` nos dois commits; 4 linhas `ERROR` da fonte AlegreyaSans só na 1ª importação de cópia limpa (conhecido, benigno) |
| `tools/check.gd` | `CHECK ok` |
| `tools/test.sh` `07688f5` | 133 scripts, **1383/1383**, 404 034 asserções, 0 arriscados (o `test_only_finishers_glint` não ficou arriscado), 0 `ERROR` no log, 657 s |
| `tools/test.sh` `343d251` | não concluída: a 1ª rodada se perdeu (outro agente apagou o log no scratchpad compartilhado), a 2ª parei com 77 de 142 scripts sem falha, por ordem do Game Director (WSL sem memória; ele roda a suíte). Rodei só `test_qa_pad_menus` (passa) e a verificação do hub por controle |
| Robô no `343d251` (semente 5) | `smoke 300`: Morvath aos 232,8 s, 7 Bênçãos, `stuck` 0; `--start=boss --boons=25`: vitória aos 65,5 s; `--smoke=900 --look=stylized`: vitória aos 324,5 s, 0 erros. `step_ms_avg` 0,66 (era 0,33), medido com a suíte e outros agentes rodando juntos: não comparável, medir de novo com a máquina livre |
| `title_flow_check` / `map_flow_check` | `FLOW ok` / `MAP_FLOW ok` (`07688f5`) |
| `smoke.sh 300 --seed=5` (`07688f5`) | sala 11 (Morvath) aos 254,5 s, 7 Bênçãos, `max_alive` 8, `step_ms_avg` 0,33, pico 8,81, `stuck` 0 |
| `smoke.sh 120 --start=boss --boons=25 --seed=5` (`07688f5`) | vitória aos 65,5 s (`mode` ENDING, `boss_hp` -1), vida 50/50 |
| RS-F1 `--smoke=900 --look=stylized`, sem tela | vitória aos 381,6 s, 0 erros (renderizador mudo: não compila shader, ver abaixo) |
| RS-F1 na GPU real, estilizado, descida inteira | iGPU Forward+ Vulkan: vitória, **0 erros de shader** no log; exe Linux no OpenGL (Compatibility) 10 min: 0 erros de shader; hub no OpenGL da RTX: 0 erros |
| BUG-110 (exe Linux, 10 min, `--watchdog`, robô) | 115 amostras `WATCH`, partida até a vitória e tela final; nenhuma parada com o jogo parado; **uma janela de 7,2 s com 9 quadros** (motor, não jogo) |
| DT-RS3 (iGPU 1280 x 720 Baixa, `--fast=2`) | **falha**: nenhum bioma abaixo de 50 ms na entrada; tabela na seção 2 |
| HUB-E | GUT do hub verde; saves v1 a v5 abrem no hub e no Livro sem erro; F7 ida e volta exato no hub; Compatibility sem erro; controle P0 no `07688f5`, corrigido no `343d251`; hub na iGPU 17,5 / 17,9 ms |
| MAP-05 | capturas do mapa de duas sementes com grafos diferentes; vídeo: ver seção 4 |

## 1. Achados por gravidade

### P0
Nenhum aberto no `343d251`.

**P0 corrigido no meio (registro)**: no `07688f5` o controle não tinha A em `ui_accept` nem B em `ui_cancel` (Godot 4.7.2
só traz Enter/Espaço e Esc; `Controls.apply_bindings` não acrescentava). Com só o controle: A não apertava Iniciar no
título, nem Descer no Portal; B não fechava o Livro, a Forja, o Vendedor, a Árvore nem o menu do Santuário (7 falhas em
`qa_hub_pad`, iguais no headless e na janela da RTX, `docs/qa/a8/logs/hub_pad_rtx.log`). O `343d251` acrescenta os dois
(`Controls.MENU_BUTTONS`); a mesma verificação passa inteira (`PADHUB ok`, A no título leva ao hub). Teste que travaria a
regressão: `docs/qa/a8/scripts/test_qa_pad_menus.gd.txt` (falha no `07688f5`, passa no `343d251`); sugiro ao
`gameplay-engineer` incorporar em `tests/` junto com a verificação do hub por controle (`qa_hub_pad.gd.txt`), porque o
`title_flow_check` manda ações (`ui_cancel`), não botões do controle, e por isso nunca pegou isso.

### P1

**P1-1. DT-RS3: primeira entrada de cada sala congela de 0,5 a 17,6 s na iGPU (compilação de shader e montagem da sala).**
Medido com `frame_spikes.gd` (registra todo quadro acima de 50 ms e o pior dos 90 primeiros de cada sala), descida inteira
do robô, semente 5, iGPU 1280 x 720 Baixa, Vulkan Forward+. Pior quadro na entrada, em ms:

| Sala | Estilizado, cache vazio | Estilizado, cache quente | Clássico, cache em parte quente |
|---|---|---|---|
| Carregar o jogo (antes da sala 1) | 5 214 | 4 213 | 4 505 |
| 1 Salão | **11 699** | 5 580 | 4 838 |
| 2 Fendas | 4 043 | 1 222 | 990 |
| 3 Jardim | 1 711 | 1 896 | 1 469 |
| 4 Cripta | 500 | 583 | 610 |
| 5 Ponte | 809 | 682 | 772 |
| 6 Santuário | 663 | 531 | 591 |
| 7 Runas | 1 585 | 527 | **6 508** |
| 8 Santuário | 771 | 461 | 601 |
| 9 Cripta | 600 | 478 | 573 |
| 10 Salão (loja) | 751 | 733 | 781 |
| 11 Câmara do Selo | **17 625** | 992 | 1 075 |

Mais, no estilizado frio: 30 quadros lentos dentro das salas, 9 acima de 500 ms (Salão 3,3 s, 1,6 s, 1,1 s nos
primeiros golpes; Câmara 1,1 s e 1,1 s nas primeiras fases). Quente: só 18 dentro das salas, nenhum acima de 250 ms. O
clássico rodou depois do estilizado, então só os shaders próprios dele estavam frios (Runas 6,5 s: o chão de runas
clássico). Leitura: (a) o grosso no frio é compilação de shader/pipeline (cai 17 vezes na Câmara com o cache); (b) a
entrada de toda sala custa 0,46 a 0,73 s mesmo quente, o que parece ser a montagem da sala na CPU (sem tela a mesma troca
mede cerca de 190 ms; no Windows com a iGPU, mais), coberta ou não pelo escurecimento. Logs:
`docs/qa/a8/logs/dtrs3_igpu_*.log`.
- Reproduzir: apagar `%APPDATA%\EterraASelagem\shader_cache` e `vulkan`, `tools/gpu.sh run --rendering-driver vulkan
  --gpu-index 1 --resolution 1280x720 -s tools/frame_spikes.gd -- --nosave --bot --seed=5 --look=stylized --quality=baixa
  --smoke=420 --fast=2` (ferramenta em `docs/qa/a8/scripts/frame_spikes.gd.txt`, vai para `tools/`).
- Responsável sugerido: `technical-artist` (aquecer materiais e pipelines das salas e dos efeitos no carregamento ou numa
  tela de "preparando", como o próprio DT-RS3 propõe; o Godot 4 tem `RenderingServer` com compilação de pipeline em
  segundo plano a conferir) e `gameplay-engineer` (montar a sala seguinte antes do escurecimento acabar, ou em partes).

**P1-2. BUG-110: o exe ficou 7,2 s com 9 quadros desenhados no meio da descida.** Exe Linux do `07688f5`, 10 min com
`--watchdog` e o robô (`docs/qa/a8/logs/bug110_linux_exe_watchdog.log`): amostras a cada 5 s, mediana 14,4 quadros/s
(OpenGL da RTX pelo D3D12 do WSL), a partida chega à vitória aos 553 s reais e fica na tela final até o fim. Nenhuma
amostra com o relógio parado em `PLAY` e `rate` normal, a não ser **uma**: entre 252,3 s e 259,5 s reais só 9 quadros,
`mode` PLAY, `rate` 1,0, relógio do jogo 167,7 a 168,2 s. É o motor parado, não o jogo (o vigia separa os dois como
pretendido). Pelo tempo, é a entrada de uma sala nova (sala 6 ou 7 da semente 5), o mesmo engasgo do P1-1 no
Compatibility. A parada de 2,2 s da 1ª sala do registro original não se repetiu. Responsável: o mesmo do P1-1.

### P2

- **P2-1. Nome da estação cortado na borda**: na chegada ao Santuário com a câmera Perto, "Livro de Ah" (sem o k) na borda
  direita, a 1080 e no Compatibility a 720 (`docs/qa/a8/hub_sty_1080.jpg`, `hub_compat_720.jpg`). `HubLabels` deveria
  esconder ou recuar o nome que não cabe. Responsável: `ui-ux-designer`.
- **P2-2. Sem fixture de save v6 e v7** em `tests/fixtures` (só v1 a v5); a versão atual é 7. Responsável:
  `gameplay-engineer` (gravar um save v6 e um v7 de verdade como fixture).
- **P2-3. Mapa: Ouro e Loja quase iguais** a 1080 (moeda e loja são círculos com traços verticais; na semente 9 a
  camada 8 tem os dois lado a lado, `docs/gallery/dv1/map05/seed9_map_1080.jpg`). Responsável: `ui-ux-designer`.
- **P2-4. F7 do hub sem teste na suíte**: o aceite do HV-A pede "F7 exato (`test_room_style` do hub)". Escrevi o teste
  (`docs/qa/a8/scripts/test_qa_hub_f7.gd.txt`) e ele **passa** no `07688f5` (6 asserções: ida, volta, ida, volta, mesma
  colisão); sugiro ao `gameplay-engineer` incorporá-lo.
- **P2-5. Hub na iGPU um pouco mais caro que o registrado**: `sty_probe` 720 Baixa, `--hub`: clássico quadro 17,5 ms
  (GPU 17,2, 829 chamadas), estilizado 17,9 ms (GPU 17,6, 867 chamadas), 125 MB de vídeo. O `CLAUDE.md` registra 15,2 a 15,3
  ms, mas com `--play` e quadro preso no vsync; não é a mesma medida, então não chamo de regressão. Medir de novo no mesmo
  arranjo (`docs/qa/a8/logs/hub_probe_*.log`).

## 2. DT-RS3 em detalhe
Ver P1-1. Critério do item: "nenhum quadro acima de 50 ms na primeira entrada de cada bioma, nos dois perfis, iGPU Baixa".
**Não atendido** em nenhum bioma, frio nem quente. O pior caso real de um jogador é o primeiro (instalação nova ou exe com
shaders novos): 17,6 s de tela parada ao entrar em Morvath.

## 3. HUB-E
- GUT: `test_hub.gd`, `test_hub_d.gd`, `test_hub_d_assets.gd`, `test_hub_ui.gd` dentro dos 1383 verdes.
- Saves antigos: cada `tests/fixtures/save_v1` a `v5` posto como `save_1.json` numa pasta própria e aberto com
  `--hub --nosave --save-dir=... --slot=1` e `--title --screen=hero`: nenhum erro, nada gravado (só leitura conferida).
- Controle: ver P0 corrigido; no `343d251`, por eventos reais do controle (`InputEventJoypadButton`/`Motion`): o
  analógico anda (5,4 m em 0,8 s), A abre Livro, Forja, Vendedor, Árvore e Portal, B fecha cada um e o menu, Start abre
  o menu, A em Descer começa a descida; no título A em Iniciar leva ao hub.
- F7: ida e volta exata no hub (P2-4).
- Compatibility: hub no OpenGL da RTX a 720 sem erro (`docs/qa/a8/hub_compat_720.jpg`); clássico e estilizado a 1080
  (`hub_cls_1080.jpg`, `hub_sty_1080.jpg`); Forjador na câmera Longe (`hub_smith_far_1080.jpg`): Portal, Vendedor, Árvore
  e Livro na tela, placa com a tecla.
- Desempenho: P2-5.

## 4. MAP-05
- Capturas do mapa na partida real (`tools/ui_lab.gd -- --map`, RTX 1920 x 1080): sementes 5 e 9 com grafos diferentes
  (larguras, guardiões Cavaleiro na camada 6 contra Ancião e Cavaleiro na 4, loja de rota na 6 da semente 9), todas as
  rotas descendo até a loja da 10 e Morvath na 11 (`docs/gallery/dv1/map05/seed{5,9}_map_1080.jpg` e `_hud_1080.jpg`).
- Vídeo (Movie Maker na RTX, 1920 x 1080 a 30 qps, reduzido a 1280 x 720 para o repositório, 44 s):
  `docs/gallery/dv1/map05/map05_seed5_720.mp4`, quadros em `map05_video_frames.jpg`. Descida real do robô, semente 5:
  a sala 1 vencida abre três portas; o mapa abre por cima (`Hud.open_map`, o mesmo do M) com o foco na porta da
  esquerda (Encanto, Salão das Fendas) e passa para as outras (Magia; Prata, Cripta dos Esquecidos): duas portas com
  recompensa e arena diferentes e o que cada uma alcança embaixo. Fecha, o robô entra na da esquerda e, na sala 2, o
  mapa aberto mostra o caminho feito em rubrica, a sala atual com o aro duplo e os ramos deixados apagados. Roteiro em
  `docs/qa/a8/scripts/map05_driver.gd.txt`. Diferença do aceite: quem escolhe a porta é o robô (pela recompensa, não
  "pela arena"); o `comparativo.md` e o `CLAUDE.md` não foram tocados (não são do QA).

## 5. Limitações
- Cache de shader: movi o cache do Daniel (`%APPDATA%\EterraASelagem\shader_cache` e `vulkan`) para
  `*.qa_orig` para medir frio e o devolvi no fim. Outros agentes rodavam na GPU ao mesmo tempo e escreveram no cache novo:
  o "frio" pode estar um pouco mais quente do que o de uma instalação nova. Cache do driver (Intel e NVIDIA) não foi
  apagado. Frio na RTX não foi medido (fila da GPU ocupada por outros agentes; o PC já caiu com mais de duas execuções).
- O RS-F1 sem tela usa o renderizador mudo (não compila shader); por isso a descida estilizada também rodou na iGPU
  (Vulkan) e o exe no OpenGL. As 18 vistas da galeria final (`docs/gallery/redesign/final/`) não foram feitas.
- BUG-110 rodou no Linux pelo D3D12 do WSL, não no Windows nativo; quadros/s baixos (14) são desse caminho.
- Celular e som: não medidos.
