# Capturas e vídeos do C11 (Câmara do Selo)

Capturas reais da Godot 4.7.2 (Windows) na placa de vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan
1.4.357, Forward+), tiradas em 2026-11-16 pelo QA, com o notebook na tomada (`Win32_Battery.BatteryStatus` 2, 100%).
Nenhuma imagem foi gerada por IA, editada ou retocada: cada arquivo é o quadro que o jogo salvou (`--shot`), só
regravado de PNG para JPG com qualidade 85 (`Image.save_jpg(caminho, 0.85)` da própria Godot). As montagens só juntam
quadros inteiros (ou recortes, no `selo_estados`) com uma faixa de rótulo **acima** de cada um (`ffmpeg scale`, `pad`,
`drawtext`, fonte Alegreya Sans Bold do projeto). A exceção é `lado_a_lado_referencia.jpg`: cópia de
`work/chamber_09_side_by_side_reference.jpg` feita pelo ciclo; **a metade esquerda é a pintura de referência do Daniel
(feita por IA), não o jogo**; a direita é o jogo.

- **Depois**: `6bab080` (HEAD de `arpg-3d`), espelho padrão `C:/Users/danie/tools/eterra-gpu`.
- **Refeitas em 2026-11-16 pela rodada de correções da revisão de arte (P1, P2, P4, P5, P6 do `ART_REVIEW.md`)**, sobre o
  `76e8fe7` com as correções ainda sem commit, espelho próprio `C:/Users/danie/tools/eterra-gpu-p5`, os mesmos comandos
  abaixo: `01` a `10` e as variantes, `selo_estados`, `borda_e_camera`, `lado_a_lado_referencia`, a metade "depois" dos cinco
  antes e depois (a metade "antes" é a mesma, recortada da montagem anterior) e a nova `11_geada_golpe_forte`. Nesta rodada
  o PNG da Godot virou JPG pelo ffmpeg (`-q:v 3`), não pelo `save_jpg`; as montagens com o mesmo `ffmpeg` (`scale`, `pad`,
  `drawtext`, Alegreya Sans Bold). O texto "o que se vê" das tabelas é o das capturas anteriores: o enquadramento e o
  momento são os mesmos; mudaram o chão (mais claro), o céu (azul), as janelinhas do anel distante, as faixas da
  tempestade (cada uma na sua cunha, nada a 1,2 m de Morvath) e o miolo vermelho das erupções.
- **Antes**: `2de07b0` (fim do ciclo 9, salão retangular), extraído com `git archive 2de07b0 | tar -x -C
  /home/dani/games/qa1011-before`, espelho `C:/Users/danie/tools/eterra-gpu-qa1011b`. A queimadura também foi tirada no
  `196f33c` (fim do C10), espelho `eterra-gpu-qa1011c`. Cópias e espelhos apagados ao fim.
- `shot` abaixo = `RES=1920x1080 tools/gpu.sh shot <saída.png> --nosave --seed=5 --start=boss` seguido das opções (janela em
  `--fixed-fps 30`, câmera do jogo, 1920 x 1080). Nenhuma captura da câmara usa dom de fogo (só o golpe que o
  `--start=boss` já traz). "Momento" é o `time` da linha `RESULT` (segundos de partida).

## As dez capturas pedidas e as variantes

| Arquivo | Opções do `shot` | Momento e o que se vê |
|---|---|---|
| `01_arena_vazia.jpg` | `--no-boss --shot-at=2` | 2,0 s; a câmara inteira sem Morvath: herói na boca da escadaria (sudoeste), selo no estado 1 com o leão e a rachadura violeta, quatro lanternas violeta, porta selada com o raio violeta, torre e correntes, estandartes |
| `02_explorador_e_morvath.jpg` | `--shot-at=1` | 1,0 s; a composição da pintura: herói embaixo à esquerda, Morvath sobre o selo, porta em cima à direita; faixa "A Cripta" (nome da sala) |
| `03_foice_sepulcral.jpg` | `--bot --boss-only=scythe --shot-at=3 --shot-on=boss:scythe_warn --shot-after=0.5` | 4,7 s; foice erguida, meio círculo vermelho com o aro de runas, herói fora do setor |
| `03b_foice_golpe.jpg` | o mesmo com `boss:scythe_strike` e `--shot-after=0.08` | 5,2 s; arco do corte cruzando o setor |
| `04_investida.jpg` | `--bot --bot-kite=1 --boss-only=dash --shot-at=2 --shot-on=boss:dash --shot-after=0.6` | 4,7 s; faixa da investida para oeste, até a balaustrada, com divisas de direção |
| `04b_investida_meio.jpg` | o mesmo com `--shot-after=1.05` | 5,1 s; Morvath no fim da investida, sobre o selo |
| `05a_ritual_preparo.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:phase --shot-after=1.0` | 3,4 s; "O Ritual dos Mortos", Morvath indo ao meio, selo no estado 2 (aro violeta) |
| `05_ritual_central.jpg` | `--bot --boss-hp=0.67 --shot-at=2 --shot-on=boss:ritual --shot-after=1.2` | 5,8 s; escudo no centro do selo (estado 3), runas de invocação dos dois lados, primeiro morto subindo da coluna; barra do chefe com o contador "Derrube os mortos" |
| `06_invocacao_reforcos.jpg` | o mesmo com `--shot-after=3.0` | 7,5 s; mortos de pé dentro do círculo, um aviso de erupção sob o herói |
| `07_erupcoes.jpg` | `--bot --boss-hp=0.5 --boss-only=eruptions --shot-at=2 --shot-on=boss:eruptions --shot-after=0.6` | 17,3 s; dois círculos de runa no chão, herói golpeando Morvath |
| `07b_erupcoes_colunas.jpg` | o mesmo com `--shot-after=1.0` | 17,7 s; as colunas espectrais saindo dos círculos |
| `08_maldicao.jpg` | `--boss-hp=0.3 --boss-only=curse --shot-at=2 --shot-on=boss:curse --shot-after=0.3` (sem robô) | 4,2 s; "A Maldição dos Condenados", faixa da maldição até a escadaria, herói dentro dela |
| `08b_amaldicoado.jpg` | o mesmo com `boss:cursed` e `--shot-after=1.2` | 6,2 s; herói com a aura violeta, selo "Amaldiçoado", especial com cadeado, 24/30 |
| `09_tempestade_seis_almas.jpg` | `--bot --boss-hp=0.14 --boss-only=storm --shot-at=2 --shot-on=boss:storm --shot-after=0.5` | 4,2 s; as seis faixas saindo do centro, cortadas na balaustrada, pontos de ordem nas faixas, veios violeta da fase 4 no chão, raio da porta azul |
| `09b_tempestade_disparo.jpg` | o mesmo com `boss:storm_fire` e `--shot-after=0.25` | 5,3 s; as meias-luas no ar, herói fora delas |
| `10_vitoria_selagem.jpg` | `--bot --boss-hp=0.02 --shot-at=1 --shot-on=boss:victory --shot-after=3.3` | 5,7 s; selo de ouro com a estrela de luz no centro, porta fechada sem o raio, texto da selagem |
| `10a_vitoria_1s2.jpg` | o mesmo com `--shot-after=1.2` | 3,6 s; veios violeta recuando para o selo, a energia verde de Morvath sobre ele |
| `10b_vitoria_2s5.jpg` | o mesmo com `--shot-after=2.5` | 4,9 s; o texto "A magia de Morvath se desfaz..." e o selo clareando |
| `11_geada_golpe_forte.jpg` | `--bot --boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno --shot-at=12 --shot-on=omega --shot-after=0.1` (P3/P4; 0,03 s depois cai no quadro de impacto em preto e branco, que é de propósito) | 26,0 s; o Ômega de geada (203) acaba de atravessar Morvath: o corpo dele fica cinza-lavanda pela geada (congelado), com a coroa e o manto legíveis, sem o quadro marfim de antes (o pisca do chefe para em `Horde.BOSS_FLASH` 0,8, abaixo do `white_from` 0,85). Numa sequência de 150 quadros (0,1 s) com o mesmo kit, nenhum quadro com o corpo dele coberto de branco |

## Extras

| Arquivo | Como |
|---|---|
| `selo_estados.jpg` | recortes de 700 x 400 em volta do selo (x 610, y 330) de `01`, `05a`, `05`, `fase4_clima` (fase 4 sem tempestade: `shot --bot --boss-hp=0.14 --shot-at=6`, 5,9 s; refeita nesta rodada, fora da pasta; na `09` as faixas cobrem o selo) e `10`, com rótulo acima |
| `borda_e_camera.jpg` | cinco `shot --no-boss --shot-at=2` com `--hero-at=0,12`, `12,0`, `0,-12`, `8.5,8.5` e `9.7,5.7`. Em todos o herói fica a mais de 18% das bordas (medido a olho no quadro inteiro: a menor folga é a de `12,0`, herói perto de x 1510 de 1920, 21% da borda direita). Em `12,0` ele aparece em pé **sobre a tampa do sarcófago sudeste**, e em `8.5,8.5` sobre as velas da balaustrada (ver o relatório de QA). Em `9.7,5.7` o herói ficou na frente do pilarete, não atrás: o pontilhado não aparece neste quadro |
| `before_after_arena.jpg` | `shot --shot-at=1` no `2de07b0` e no `6bab080` |
| `before_after_investida.jpg` | **comandos diferentes**: o antes é `--boss-only=dash --shot-at=2 --shot-on=boss:dash --shot-after=1.05` sem robô (o `2de07b0` não tem `--bot-kite`); na câmara esse comando sem robô **nunca dá investida** (esperou 300 s e foi cancelado: o herói parado na boca da escadaria fica perto demais ou sem os 8 m livres que a regra nova pede), então o depois é o `04b` (`--bot --bot-kite=1`) |
| `before_after_ritual.jpg` | ritual + 1,2 s nos dois (o antes ainda tem o ponto branco no escudo que o C10 tirou) |
| `before_after_tempestade.jpg` | tempestade + 0,5 s nos dois |
| `before_after_vitoria.jpg` | vitória + 3,3 s nos dois |
| `lado_a_lado_referencia.jpg` | pintura de IA à esquerda; à direita o jogo, refeito nesta rodada com `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/chamber_lab.gd -- <saída> --hero --boss` (câmara sem HUD, herói na boca da escadaria e Morvath sobre o selo) |

Descartadas: `before_after_investida` com o mesmo comando nos dois (cancelada, acima); `c10_fase4_clima` com
`--shot-on=boss:phase` (com `--boss-hp=0.14` a fase 4 começa antes dos 2 s de espera e o momento não vem de novo:
cancelada aos 300 s).

## Vídeo da luta

Gravado na GPU com `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --write-movie
C:/.../<nome>.avi -- --nosave --start=boss --bot --bot-reaction=0.25 --boon-ids=golpe_geada,toque_geada,circulo_geada,passo_geada,estilhaco,peso_inverno
--shot=C:/.../fim.png --shot-on=end --shot-after=4` (o kit do vídeo do ciclo 9). **Saiu em 1280 x 720** apesar do
`--resolution 1920x1080` (a linha da Godot: "Movie Maker mode enabled, recording movie in 1280×720 @ 60 FPS"; é o tamanho
do projeto, `viewport_width` 1280; mudar isso pediria um `override.cfg` só para a gravação, e a HUD ficaria menor que a do
jogo). **Sem som** (o `--shot` silencia o jogo). Convertido com `ffmpeg -c:v libx264 -preset slow -crf 28 -pix_fmt yuv420p
-movflags +faststart -an`.

| Arquivo | Tamanho | Duração | Como e o que mostra |
|---|---|---|---|
| `boss_arena_full_fight.mp4` | 20,7 MB | 2:07 | `--seed=4`: a luta inteira sem cortes, do carregamento até 4 s da tela "Morvath foi selado". `RESULT`: venceu (`ENDING`), luta de 115,3 s, fases em 32,3 / 74,1 / 97,3 s, ritual 10,4 s, 10 mortos levantados, 1 maldição, terminou com 16 de vida, robô nunca preso |
| `boss_arena_full_fight_semente1_derrota.mp4` | 20,6 MB | 2:10 | `--seed=1`, **a mesma semente do vídeo do ciclo 9** (`docs/gallery/cycle9/morvath_full_fight.mp4`, que venceu no salão): na câmara o robô **perde na fase 4** com Morvath a 51 de vida, "Derrotado por: Tempestade das Seis Almas". Luta de 126,2 s, fases em 33,6 / 85,2 / 104,6 s, ritual 11,5 s; o mesmo resultado da simulação sem tela com a mesma semente |

A semente 4 foi escolhida pela simulação sem tela do mesmo kit (sementes 1 a 8 com reação 0,25: vencem 2, 4, 5 e 6;
perdem 1, 3, 7 e 8; ver `METRICAS.md`, linha "kit do vídeo do C9"). Conferidos por folhas de quadros (um a cada 15 s): fase 1,
escudo do ritual, fase 3, tempestade da fase 4 e a tela final.
