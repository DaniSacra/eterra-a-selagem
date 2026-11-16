# Relatório de QA e desempenho: C12 "Arenas I" (Cripta, Fendas, Jardim, descida de 7 salas)

- **Data**: 2026-11-16.
- **Branch**: `arpg-3d`, **commit testado `91cc656`** (C12 = `f25ae5f`, `e2297ee`, `91cc656`). Árvore limpa no começo; o QA
  não mudou código de jogo, arte, testes nem ferramentas do projeto. Mudou só `docs/gallery/cycle12_maps/` (capturas,
  índice, métricas, limpeza do `work/`) e este relatório.
- **Ambiente**: WSL2 (Linux 6.18) para importação, testes e simulações (Godot 4.7.2 Linux, sem tela). Capturas, vídeos e
  quadros na **placa de vídeo real** pela Godot 4.7.2 de Windows (Vulkan 1.4.357, Forward+, NVIDIA GeForce RTX 5060 Laptop
  GPU; Compatibility pelo OpenGL 3.3 da mesma placa), na tomada (`BatteryStatus` 2, 100%). **Sem som.** Nenhum teste com gente.
- Evidências: `docs/gallery/cycle12_maps/` (`CAPTURAS.md` com o comando de cada arquivo, `METRICAS.md` com as tabelas).

## Veredito

**Pronto para o Daniel testar**, do lado do QA: nenhuma falha alta. Os três mapas abrem, jogam e saem nas duas variantes;
**0 inimigo preso e 0 robô preso em 192 lutas e 8 descidas**; nenhuma esquiva atravessou buraco nem peça em 6720 esquivas
na borda da fenda e 569 tentativas contra obstáculos; o herói cercado num corredor sai em 12 a 15 de 16 direções; quadro
a 1080p de 3,3 a 4,7 ms (meta 6). O julgamento visual (fidelidade às referências, leitura da fenda) é do `art-director` e
do Daniel; o balanceamento (4 vitórias em 8 descidas com reação 0,25), do Gameplay Engineer e do Daniel.

## 1. Checagem e testes

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | código 0, **0 SCRIPT ERROR, 0 Parse Error** |
| `godot --headless --path . -s tools/check.gd` | código 0, `CHECK ok` |
| `tools/test.sh` | **48 arquivos, 462 testes, 462 passando, 0 falhando, 0 arriscados**, 103626 asserções, 75,6 s |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** (0 SCRIPT ERROR) |

Exportação de Windows e Web: não pedida nesta rodada, não feita.

## 2. Robô (detalhes no `METRICAS.md`)

- **Por arena e variante** (32 sementes cada, sala 1, reação 0,25; 192 lutas): `stuck` 0, `bot.stuck` 0, 0 mortes;
  primeiro contato mediana 2,4 a 3,7 s (máx. 7,2, Fendas B); sala 13,9 a 15,8 s (máx. 30,1); dano levado 0,6 a 1,8 por luta
  (máx. 18); tiros barrados por luta Cripta 1,1 a 1,3, Fendas 0,25 a 0,31, Jardim 0,47 a 0,50; `max_alive` 4 na Cripta e 6
  nas outras. Nas salas 3 e 5 (mesmas partidas seguidas) o dano sobe a 4,3 a 6,4 por sala, puxado pelo feiticeiro (sala 3) e
  pelo Ancião (sala 5).
- **8 descidas de 7 salas** (reação 0,25): **4 vitórias**; Morvath alcançado em 7 de 8, aos 94,8 a 120,4 s (mediana 113);
  `hp_at_boss` 12 a 53 (mediana 24); derrotas: fase 3 (2), fase 2 (1) e uma no guardião (Ancião) no Jardim, sala 5.
- **Regressão** (reação 0): `300 --seed=5` venceu (Morvath na sala 7 aos 129,5 s); `120 --start=boss --boons=25 --seed=5`
  venceu; `120 --stress=300 --seed=5` 309 abates, 300 de pé, sem erro.

## 3. Situações à mão (seção 15 do pedido)

Roteiro com o jogador e o jogo de verdade, comandados por um controle virtual (`METRICAS.md`, seção 4), e capturas na GPU
com `--hero-at` (`CAPTURAS.md`):
- andar 2 s e esquivar contra cada peça que barra corpo, de 12 lados, a 60 e 30 FPS: **0 quadros dentro de uma peça**;
- 6720 esquivas na borda dos buracos das Fendas (para o buraco e de lado, a 60 e 30 FPS): **0 fora do chão, 0 sobre buraco**;
- cercado por 4 esqueletos nos 4 corredores mais estreitos de cada arena (3,6 a 6,8 m): 12 a 15 de 16 esquivas saem;
- na borda oeste da fenda a balaustrada fica fora do chão (0,55 m) e abre em pontilhado na frente do herói; um
  `--hero-at` no meio da fenda leva o herói para a ponte.

## 4. Desempenho

| Cena (1920 x 1080, Forward+) | Quadro mediana | p90 |
|---|---|---|
| Cripta A / B | 3,32 a 3,45 ms | até 3,97 |
| Fendas A / B | 4,25 a 4,37 ms | até 4,85 |
| Jardim A / B | 4,55 a 4,66 ms | até 5,16 |
| Salão | 5,09 ms | 5,69 |
| Câmara do Selo | 3,92 a 4,06 ms | 4,67 |

Compatibility (OpenGL 3.3, mesma placa): Cripta 3,21, Fendas 3,74, **Jardim 5,35 ms (p90 6,03)**, salão 4,37.
Simulação: `step_ms_avg` 0,16 a 0,25 ms; `step_ms_peak` 2,3 a 2,95 ms de mediana (meta do plano: 2 ms; o salão dá 2,1 a 3,1).

## 5. Falhas e regressões por gravidade

Nenhuma alta. Nenhuma regressão no salão, na câmara, no título nem nos testes.

**Média**
- **M-1. Referência de IA em tamanho cheio dentro de `docs/gallery`** (regra do projeto: as referências ficam só locais).
  `docs/gallery/cycle12_maps/work/garden_vs_04.png` (3838 x 1080, entrou no `91cc656`) tinha a `04` inteira à esquerda.
  Refeito pelo QA como `garden_vs_04.jpg` com a miniatura de 480 px e o rótulo "referência (IA)". **O PNG antigo continua
  no histórico do git**; se ele não pode ir para fora do computador, a decisão sobre o histórico é do Game Director (sem
  push forçado). Responsável: Game Director.

**Baixa**
- **B-1. Pico do passo acima de 2 ms** (`step_ms_peak` mediana 2,3 a 2,95 ms nas arenas; 5 passos isolados de 4,2 a
  11,4 ms em 48 lutas, em `player` ou `horde`, um deles fora dos laços medidos). O salão sem campo de fluxo tem o mesmo
  pico (2,1 a 3,1), então não é da navegação; o médio continua em 0,16 a 0,25 ms. Reproduzir: `~/tools/godot/godot --headless
  --path . --fixed-fps 60 -- --bot --nosave --smoke=17 --arena=garden --variant=1 --seed=<1..8> --bot-reaction=0.25
  --trace-steps` e ler as linhas `SLOW_STEP`. Responsável: `gameplay-engineer` (decidir se a meta de 2 ms vale para o pico
  de uma passada no WSL ou para um percentil).
- **B-2. `--hero-at` no centro exato de um obstáculo deixa o herói dentro dele** (só a opção de desenvolvimento: no jogo
  ninguém chega lá, ver a seção 3). `shot --arena=crypt --variant=0 --hero-at=0.5,0 --shot-at=1.2`: o herói aparece em pé
  sobre o túmulo grande (`crypt/vA_g_hero_at_dentro_do_tumulo.jpg`). Provável: `Arena.resolve` sem direção para empurrar
  quando o ponto é o centro da caixa. Responsável: `gameplay-engineer`.
- **B-3. O teste 6 do plano ("cercado") no GUT só olha o chão**: `test_no_dead_end_traps_a_cornered_paladin` confere 16
  direções de 1,5 m sem inimigos; o plano pedia 2 inimigos de cada lado e uma esquiva que sai. O roteiro do QA cobriu à
  mão (seção 3) e passa; vale virar teste. Responsável: `gameplay-engineer`.
- **B-4. Jardim no Compatibility: p90 de 6,03 ms a 1080p** (a meta de 6 ms é do Forward+; no navegador e em placa fraca o
  Jardim é a arena mais cara). Responsável: `environment-artist`, se o navegador importar.

**Para o `art-director` (observação, não falha)**
- Nas Fendas, a fenda lê como dois poços retangulares e um octógono, com as pontes como faixas de chão entre eles; na `02`
  é um rasgo contínuo de borda quebrada (`rift/vA_f_referencia.jpg`, `vA_d_obstaculo.jpg`). No Compatibility a sala fica
  bem mais clara e azul que no Forward+ (`rift/vA_h_compatibility_combate.jpg`).

## 6. Limitações

WSL2 sem Vulkan da GPU (as capturas e quadros vêm da Godot de Windows no espelho `C:/Users/danie/tools/eterra-gpu`); sem
som; nenhum teste com gente; celular e placa fraca não medidos; o salto do alvo da câmera entre quadros (C12-F6) não foi
medido em número, só visto nos vídeos; as simulações de comportamento rodaram 4 de cada vez (os tempos de passo valem só
da seção 3 do `METRICAS.md`, rodada uma de cada vez). O `/tmp` do WSL (tmpfs de 3,9 GB) encheu durante o trabalho com
pastas de outras sessões; os arquivos de trabalho do QA ficaram em `/home/dani/games/qa-c12-work/` (fora do repositório,
pode ser apagado).
