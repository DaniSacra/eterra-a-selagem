# C12c, depois (QA-02)

Autor: `qa-performance`, 2026-11-16. Commit testado: `beb6c27` (`arpg-3d`, C12c integrado; árvore limpa, o QA só
acrescentou as ferramentas de captura `tools/movie.sh`, `tools/feel_driver.gd` e `tools/feel_driver_bot.gd`, fora de
`scripts/`, e esta pasta). Mesma máquina, mesma placa (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan 1.4.357, Forward+), mesma
Godot 4.7.2 de Windows, mesmo espelho `MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-qa`, mesmos comandos e mesmos recortes do
`BEFORE.md`. Nenhuma imagem gerada por IA, editada ou retocada; cada quadro é o que o jogo salvou ou um quadro do Movie
Maker, regravado em JPG pelo ffmpeg (`-q:v 3`). Medidas como no `BEFORE.md` (mediana de 0,299 R + 0,587 G + 0,114 B, maior
canal, fração acima de 235).

Abreviações: `shot` = `RES=1920x1080 MIRROR=... tools/gpu.sh shot <saída>`; `run` = `MIRROR=... tools/gpu.sh run
--rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 --`; `movie` = `MIRROR=... tools/movie.sh <saída.avi>
<quadros>` (novo, ver "Movie Maker a 1080").

## Movie Maker a 1080 (achado 3 do BEFORE, resolvido na ferramenta)

O Movie Maker da Godot toma o tamanho do vídeo da janela do projeto (`display/window/size`, 1280 x 720), não do
`--resolution` (o log dizia "recording movie in 1280×720"); e o jogo volta a janela ao tamanho salvo
(`App.apply_options`) a não ser com `--shot` ou `--frames`. `tools/movie.sh` grava um `override.cfg` só no espelho
(`window/size/window_width_override=1920`, `window_height_override=1080`, apagado no fim) e passa um `--frames` que nunca
dispara (`--shot-at=1000000 --count=0`; ao contrário do `--shot`, não cala o som). Resultado: "recording movie in
1920×1080 @ 30 FPS", `ffprobe` 1920 x 1080 com áudio a 48 kHz. A base do jogo continua 1280 x 720 esticada (HUD igual ao
do jogo em tela cheia a 1080; conferido em `morvath_entrada_sequencia.jpg`). Nada do jogo mudou.

## Arquivos (`after/`)

| Arquivo | Comando | O que se vê |
|---|---|---|
| `descida_com_som.mp4` | `movie 'C:\...\descida.avi' 9000 --bot --bot-reaction=0.25 --seed=7 --runlog=C:/.../descida_run.jsonl`; cortado em 266 s (`ffmpeg -t 266 -c:v libx264 -preset slow -crf 32 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart`); AVI bruto de 2,1 GB apagado | **a descida inteira de 7 salas a 1920 x 1080 com som (DT-004)**, 4:26, 49 MB: salão, Jardim, Cripta, fonte, Fendas (Cavaleiro), loja, Morvath. Desta vez o robô **vence** com 1/30 de vida (antes morria na fase 4); tela de vitória aos 4:19 |
| `descida_run.jsonl` | o `--runlog` da mesma partida (versão 2 do registro) | `outcome: victory`, `boss_at` 128,3, `hp_at_boss` 14,8, `boons_at_boss` 3, `shop` 37 de ouro e nada comprado, `fountain_used: false`, 6 `hurt_ctx` |
| `coluna_recompensa_criptaA.jpg` | `run ... --nosave --arena=crypt --variant=0 --seed=5 --bot --autopick --bot-reaction=0.25 --frames=<p> --shot-at=12.5 --count=45 --every=0.1`, quadro `_16` (a sala agora é vencida aos 14,0 s do relógio, não aos 14,5: começo diferente, mesma semente) | a coluna da recompensa 0,2 s depois do último abate |
| `aviso_sob_heroi_ultimo_abate_criptaA.jpg` | o mesmo, quadro `_14` | o último abate com um aviso vermelho em linha ainda sob o herói |
| `sem_dano_apos_sala_vencida.jpg` | quadros `_13` a `_24`, recorte 700 x 450 em (760, 250) | o aviso some no quadro seguinte a "Sala vencida"; vida 30/30 até o fim; o herói entra na coluna (o rastro fica fraco sobre ele) |
| `gemas_portas_criptaA.jpg` | o mesmo, quadro `_30` | gemas Fortalecer dom (vermelha), Mais magia (azul), Dom (amarela) e as placas novas (UI-01) |
| `coluna_fonte.jpg` | `run ... --nosave --start=fountain --seed=5 --frames=<p> --shot-at=0.2 --count=6 --every=0.1`, quadro `_02` | a coluna da fonte, gemas Dom e Ouro |
| `morvath_entrada_0_5s.jpg` | `shot --start=boss --seed=5 --shot-at=0.5` | Morvath entra com um aro espectral no chão, **sem coluna sobre ele** |
| `morvath_entrada_sequencia.jpg` | `movie <x>.avi 45 --start=boss --seed=5` (1920 x 1080), quadros 0, 8, 15, 23, 30 e 44, recorte 960 x 720 em (480, 120) reduzido a 640 x 480 | tela escura em 0; Morvath visível a partir do quadro 8 (0,27 s) com o aro, igual até 1,47 s |
| `crypt_vA_c_combate.jpg`, `crypt_vB_c_combate.jpg` | `shot --arena=crypt --variant=n --seed=5 --bot --autopick --bot-reaction=0.25 --shot-at=5 --shot-on=hit --shot-after=0.05` | o golpe que acerta aos 5,7 s (A) e 5,9 s (B), mesmos instantes do antes |
| `crypt_vA_c_recortes.jpg`, `crypt_vB_c_recortes.jpg` | os mesmos com os retângulos do antes | ciano: chão; amarelo: tampa |
| `jardim_arvore_heroi.jpg`, `jardim_arvore_de_perto_recorte.jpg` | `shot --arena=garden --variant=0 --seed=5 --shot-at=1.2 --hero-at=-8,-0.8`; recorte 960 x 600 em (420, 0) | a árvore com o herói |
| `jardim_vA_a_cenario.jpg` | `MIRROR=... tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- <saída> --arena=garden --variant=0 --bare` | o cenário sem personagens |

## Tabela antes e depois

### GP-01: colunas, gemas, entrada de Morvath (aceite: maior canal das colunas até 235; Morvath aos 0,5 s com mediana acima de 30)

| Recorte (1920 x 1080) | Antes: lum., máx., > 235 | Depois: lum. (R, G, B), máx., > 235 | Aceite |
|---|---|---|---|
| Coluna da recompensa, Cripta A (905, 220, 90 x 300) | 255, 255, 97,7% | 255 (255, 255, 255), **255**, 98,7% | **não passa** |
| A mesma, miolo (915, 120, 90 x 330), quadros `_15` a `_23` (0,1 s cada) | | 255, 255, 255, 255, 247, 222, 170, 90, 24; máx. 255 até o `_21` (0,6 s depois do abate), 247 a 240 depois | **não passa** |
| Herói dentro da coluna (antes 990, 470; depois 960, 490, 45 x 70, quadro `_20`) | 252, 255, 85,7% | 217 (241, 215, 164), 255, 54,2% | melhorou, não passa |
| Rastro fraco da coluna sobre o herói (1020, 280, 60 x 150, `_20` e `_21`) | | 138 e 123, máx. 216 e 208, 0% | passa (é a coluna "fraca perto do herói") |
| Coluna da fonte (1440, 200, 40 x 150, `_02`) | 255, 255, 100% | 255 (255, 255, 255), **255**, 100% (`_01` e `_03` iguais) | **não passa** |
| Morvath, corpo inteiro aos 0,5 s (945, 300, 90 x 280) | (com coluna: 219 na caixa) | **45** (51, 35, 68), 255 (a gema), 2,2% | **passa** |
| Morvath, recorte do antes (988, 470, 34 x 40) | 83 (verde da coluna por cima) | 20 (26, 10, 52), 88, 0% | o recorte cai no manto escuro, que é escuro de propósito (o antes sem coluna, a 1,0 s, dava 20) |
| Coluna sobre Morvath (945, 220, 90 x 200) | 253, 255, 100% | 47, 255 (coroa e gema), 3,7% | **passa: não há coluna** |
| Gema Fortalecer dom, vermelha (576, 585, 24 x 24) | 254 (255, 255, 248), 100% | 163 (**255**, 127, 104), 255, 100% | a cor voltou; o canal dominante ainda bate 255 |
| Gema Mais magia, azul (1286, 700, 28 x 32) | 255 (branco), 100% | 199 (145, 216, **255**), 255, 100% | idem |
| Gema Dom, amarela (1338, 312, 16 x 22) | 250, 95,6% | 208 (250, 213, 72), 252, 75,6% | idem |
| Gema Dom na fonte (1625, 270, 26 x 22) | 255, 100% | 239 (255, 255, 116), 255, 94,1% | quase branca ainda |
| Gema Ouro na fonte (1578, 795, 30 x 30) | 255, 100% | 238 (255, 255, 103), 255, 100% | quase branca ainda |
| Sequência do Movie Maker (recorte 640 x 480), quadros 8 a 44 | coluna branca em 0,27, silhueta em 0,5 e 0,77 | mediana 35 a 42, máx. 255 só em pontos (0 a 1,1% acima de 235): nenhuma coluna | passa |

Leitura: a entrada de Morvath está resolvida (sem coluna, ele lê inteiro desde 0,27 s). As gemas recuperaram a cor
(vermelha, azul, amarela em vez de branco), mas o canal dominante ainda satura em 255; pela letra do aceite ("até 235")
elas não passam, pela intenção (deixar de ser branco acima do glow) a vermelha, a azul e a amarela da porta passam e as
amarelas da fonte (Dom e Ouro) ficam quase brancas (239 e 238). **As colunas de luz da recompensa e da fonte continuam
brancas, 255 em todos os canais**, apesar do teto do `Fx.beam` (`BEAM_CORE_CAP` 1,0, `Game.column`): o teste GUT confere o
parâmetro, não o pixel. Hipótese para o dono: a coluna soma camadas aditivas sobre o chão aceso e passa pela exposição 1,25
e pela curva fílmica; o 1,0 do material não é 1,0 na tela. Só o rastro "fraco" (perto do herói) fica abaixo de 235.

### ENV-01: chão da Cripta na luta (aceite: chão longe das velas 45 a 60; tampa até 150; quadro sem piora acima de 0,3 ms)

| Recorte (mesmos do antes) | Antes | Depois: lum. (R, G, B), máx. |
|---|---|---|
| A, oeste (230, 440, 150 x 70) | 12 | **19** (19, 18, 26), 68 |
| A, norte (650, 330, 150 x 60) | 22 | **34** (35, 32, 42), 79 |
| A, sul (700, 620, 150 x 80) | 37 | **50** (54, 46, 58), 92 |
| A, sudeste (1120, 640, 140 x 70) | 45 | **56** (63, 52, 56), 95 |
| A, tampa do túmulo (940, 425, 80 x 30) | 130, máx. 215 | 120 (109, 116, 167), máx. 216 |
| A, quadro inteiro | 10 | 11 |
| B, oeste (280, 470, 150 x 60) | 19 | **40** (42, 37, 46), 79 |
| B, norte (730, 320, 150 x 55) | 21 | **31** (33, 29, 39), 79 |
| B, sul (780, 650, 150 x 70) | 39 | **56** (61, 52, 62), 92 |
| B, leste (1280, 575, 140 x 60) | 41 | **47** (48, 44, 56), 94 |
| B, quadro inteiro | 9 | 10 |

Leitura: todos os oito recortes subiram (de +6 a +21); mediana dos oito de **30 para 43,5**; **4 de 8 dentro de 45 a 60**
(sul e sudeste da A, sul e leste da B; antes 1 de 8). O oeste da A (19) e os dois do norte (31 e 34) continuam abaixo de
45. A tampa passa (120, máximo 216). Pela letra, ENV-01 **passa em parte**: o `work/env_crypt_vA_c_antes_depois.jpg` do
`environment-artist` diz "45 a 56" com outros recortes; nos do QA, o oeste e o norte (longe das velas) ficam de fora.

### ENV-02: fraturas dos galhos (aceite: maior canal até 200)

| Recorte | Antes: lum., máx. | Depois: lum., máx. |
|---|---|---|
| `jardim_vA_a_cenario`, fratura 1 (641, 180, 16 x 20) | 94, 186 | 80, 163 |
| `jardim_vA_a_cenario`, fratura 2 (832, 157, 18 x 18) | 169, 196 | 148, 175 |
| `jardim_vA_a_cenario`, fratura 3 (486, 50, 14 x 14) | 78, 145 | 78, 145 |
| `jardim_arvore_heroi`, fratura 1 (765, 228, 20 x 20) | 119, 197 | 102, 198 |
| `jardim_arvore_heroi`, fratura 2 (962, 205, 20 x 20) | 167, **206** | 145, **183** |

**Passa**: maior canal 198 (antes 206).

### GP-05: som da descida (aceite: pico até -1,0 dBFS)

PCM do AVI (antes da conversão), a mesma semente 7:

| Medida | Antes (0 a 245 s) | Depois (0 a 245 s) | Depois (0 a 266 s, até a tela de vitória) |
|---|---|---|---|
| Pico (`astats` `Peak level`, `volumedetect` `max_volume`) | **0,0 dBFS** (232 amostras em 0 dB) | **-2,94 dBFS** | -2,94 dBFS |
| RMS | -23,2 dB | -23,4 dB | -23,9 dB (0 a 300) |
| Janelas de 0,1 s acima de -1 dBFS | 5 | **0** | 0 |
| Janelas de 0,1 s acima de -3 dBFS | 75 | | 67, todas exatamente em -2,94 (o teto que o limitador entrega) |
| Silêncios de 2 s ou mais abaixo de -50 dB | 11 trechos, 36,8 s (15,0%) | **11 trechos, 36,8 s (15,0%)**, nos mesmos tempos (0:00, 0:21, 0:48, 0:51, 0:57, 0:59, 1:24, 1:29, 1:35, 2:05, 2:09) | 12 trechos, 43,9 s (16,5%), com a vitória desde 4:18,9 |
| AAC do `.mp4` | 0,0 dB | | -2,5 dB |

**GP-05 passa** (pico -2,94 dBFS, nada acima de -1). Os silêncios não são aceite do C12c (música desligada; é o C15): ficam
iguais. O limitador trabalha com frequência (67 janelas no teto), a acompanhar no C15 (mixagem).

### Quadro na placa de vídeo, 1920 x 1080 (aceite: sem piora acima de 0,3 ms por arena)

Mesma sonda (`C:/Users/danie/tools/qa/gpuperf9.gd`, 240 quadros para assentar, 300 medidos), **base `fffd677` e `beb6c27`
alternados na mesma sessão**, duas rodadas cada (base num espelho próprio: `git archive fffd677` em
`/home/dani/games/qa-c12c-base`, `MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-head`). Mediana do quadro em ms:

| Cena | Antes (BEFORE, outra sessão) | Base, rodadas 1 e 2 | `beb6c27`, rodadas 1 e 2 | Diferença média | Chamadas, base / depois |
|---|---|---|---|---|---|
| `--arena=crypt --variant=0` | 3,69 | 3,49, 3,64 | 3,56, 3,80 | **+0,12** | 699 a 700 / 699 a 702 |
| `--arena=crypt --variant=1` | 3,64 | 3,60, 3,93 | 3,67, 3,77 | **-0,05** | 673 a 680 / 668 a 692 |
| `--arena=rift --variant=0` | 4,44 | 4,56, 4,50 | 4,59, 4,53 | **+0,03** | 856 / 856 |
| `--arena=garden --variant=0` | 4,99 | 5,03, 5,22 | 5,24, 5,35 | **+0,17** | 804 / 804 |
| `--arena=hall` | 5,22 | 5,92, 5,61 | 5,92, 5,85 | **+0,12** | 935 a 936 / 935 |

**Passa**: nenhuma arena piora mais de 0,3 ms (pior caso uma rodada do salão, +0,24). Medidas soltas no começo da sessão,
antes de alternar, deram 5,53 a 5,96 no salão: o notebook varia 0,4 ms entre rodadas, por isso valem as alternadas.
Janela 1920 x 1080, 3D desenhado em 2880 x 1620 (escala do Windows), tela 1920 x 1200.

### Câmera (GP-06; aceite: maior salto do alvo abaixo de 0,5 m por quadro a 60 FPS)

`godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=<s> --trace-cam --bot-reaction=0.25` (as linhas
`CAM_TRACE`; o `tools/smoke.sh` as filtra, por isso direto): 4 descidas (sementes 1, 2, 3, 5; 7 salas cada, Câmara do Selo
incluída) e 6 começos `--arena=crypt|rift|garden --variant=0|1 --seed=3` (40 s, 3 salas cada). **Maior salto de todas as
46 salas: 0,400 m** (o teto de 24 m/s); o menor máximo por sala 0,111 m. **Passa** (antes do C12c: 2,9 m na troca de sala).

## O bug "aviso fere depois da sala vencida" (achado 1 do BEFORE)

Mesmo comando do antes (Cripta A, semente 5, reação 0,25). O começo da partida não é mais idêntico (a sala é vencida aos
14,0 s, não aos 14,5), mas a situação se repete: no último abate (quadro `_14`) há um aviso vermelho em linha sob o
herói. No quadro seguinte, com "Sala vencida", **o aviso sumiu**, a vida fica em 30/30 até a troca de sala e o `RESULT`
termina com `hp: 30` e `hurt_by` vazio na sala 1 (antes 27). **Corrigido.** Em 96 lutas de sala 1 e 8 descidas, nenhuma
sala registra dano depois do fim (não há campo específico; conferido só neste caso à mão).

## Limitações

- Uma partida de cada para as capturas; o começo da Cripta A mudou de tempo com o código novo, então os quadros da coluna
  são os mesmos momentos (0,2 s depois do abate), não os mesmos números de quadro.
- Som medido só na mistura do Movie Maker (sem placa de som; ninguém ouviu).
- Compatibility (ENV-03, p90 do Jardim) não remedido neste QA; vale a medida do `environment-artist`.
- Brutos (AVI de 2,1 GB, PNG de 1080) ficaram em `C:/Users/danie/tools/qa/c12c2/` só durante o trabalho e foram apagados.
