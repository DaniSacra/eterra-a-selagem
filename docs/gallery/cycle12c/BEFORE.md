# C12c, linha de base (QA-01, "antes")

Autor: `qa-performance`, 2026-11-16. Commit testado: `fffd677` (`arpg-3d`, árvore principal limpa). Tudo na placa de
vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan 1.4.357, Forward+) pela Godot 4.7.2 de Windows, espelho
`MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-qa`. Nenhuma imagem foi gerada por IA, editada ou retocada: cada quadro é o
que o jogo salvou (ou um quadro do Movie Maker da Godot), só regravado em JPG pelo ffmpeg (`-q:v 3`). As folhas
(`morvath_entrada_sequencia`, `dano_apos_sala_vencida`) só juntam quadros inteiros ou recortes, com o tempo escrito em cima.
Medidas de cor: recortes lidos pelo ffmpeg em RGB de 8 bits; "lum." é a mediana de 0,299 R + 0,587 G + 0,114 B; "máx."
é o maior canal do recorte; "> 235" é a fração dos pixels com algum canal acima de 235.

Abreviações: `shot` = `RES=1920x1080 MIRROR=... tools/gpu.sh shot <saída>`; `run` = `MIRROR=... tools/gpu.sh run
--rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 --`.

## Arquivos (`before/`)

| Arquivo | Comando | O que se vê |
|---|---|---|
| `descida_com_som.mp4` | `MIRROR=... tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 --fixed-fps 30 --write-movie C:\Users\danie\tools\qa\c12c\descida.avi --quit-after 9000 -- --bot --nosave --bot-reaction=0.25 --seed=7 --runlog=C:/Users/danie/tools/qa/c12c/descida_run.jsonl`; cortado em 245 s (`ffmpeg -t 245 -c:v libx264 -preset slow -crf 30 -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart`); o AVI bruto (1,1 GB) foi apagado | a descida inteira de 7 salas com som, 1280 x 720, 30 FPS, 4:05, 34 MB: salão (sala 1), Jardim (2), Cripta (3), fonte no salão (4), guardião (Cavaleiro) nas Fendas (5), loja (6), Morvath (7). O robô morre na fase 4 pela Tempestade das Seis Almas aos 3:50 do relógio; a tela de derrota aparece aos 4:01 e o vídeo para 4 s depois |
| `descida_run.jsonl` | a linha do `--runlog` da mesma partida | `outcome: death`, `room: 7`, 3 dons, `hp_at_boss` 14,8, `boss_at` 128,3, `defeated_by: killer_storm`, por sala `layout`, `hp_in`, `hurt_by`, `time`, `contact` |
| `coluna_recompensa_criptaA.jpg` | `run ... --nosave --arena=crypt --variant=0 --seed=5 --bot --autopick --bot-reaction=0.25 --frames=<prefixo> --shot-at=14.3 --count=30 --every=0.1`, quadro `_02` | a coluna da recompensa da sala vencida (`rooms.gd:297`) no meio da Cripta A, 0,2 s depois do último abate |
| `coluna_sobre_heroi_criptaA.jpg` | o mesmo, quadro `_08` | o herói pegou a recompensa: dentro da coluna, só a espada aparece |
| `gemas_portas_criptaA.jpg` | o mesmo, quadro `_14` | as gemas das portas (`rooms.gd:418`): Fortalecer dom (vermelha), Dom (amarela), Mais magia (azul) |
| `coluna_fonte.jpg` | `run ... --nosave --start=fountain --seed=5 --frames=<prefixo> --shot-at=0.2 --count=6 --every=0.1`, quadro `_02` | a coluna da fonte (`game.gd:702`) e as gemas Dom e Ouro no salão |
| `morvath_entrada_0_5s.jpg` | `shot --start=boss --seed=5 --shot-at=0.5` | a entrada de Morvath com a coluna espectral (`boss.gd:218`), Morvath em silhueta dentro dela |
| `morvath_entrada_sequencia.jpg` | `run ... --write-movie <x>.avi --quit-after 75 -- --nosave --start=boss --seed=5` (Movie Maker, saiu em 1280 x 720, ver limitações), quadros 0, 8, 15, 23, 30 e 45 recortados em 640 x 480 | a coluna de 0 a 1,5 s: tela ainda escura em 0, coluna branca em 0,27, silhueta em 0,5 e 0,77, Morvath visível só em 1,0 |
| `crypt_vA_c_combate.jpg`, `crypt_vB_c_combate.jpg` | `shot --arena=crypt --variant=n --seed=5 --bot --autopick --bot-reaction=0.25 --shot-at=5 --shot-on=hit --shot-after=0.05` (o mesmo dos `vA_c`/`vB_c` do `cycle12_maps/CAPTURAS.md`) | um golpe que acerta aos 5,7 s (A) e 5,9 s (B) |
| `crypt_vA_c_recortes.jpg`, `crypt_vB_c_recortes.jpg` | os mesmos quadros com os recortes desenhados (ciano: chão; amarelo: tampa do túmulo) | onde foram tiradas as medidas do ENV-01; usar os mesmos retângulos no depois |
| `jardim_arvore_heroi.jpg` | `shot --arena=garden --variant=0 --seed=5 --shot-at=1.2 --hero-at=-8,-0.8` | o herói ao sul do tronco, a árvore inteira |
| `jardim_arvore_de_perto_recorte.jpg` | recorte 960 x 600 em (420, 0) do quadro acima, sem escala | a árvore de perto: casca, galhos quebrados com as fraturas, cristais, raízes |
| `jardim_vA_a_cenario.jpg` | `MIRROR=... tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- <saída> --arena=garden --variant=0 --bare` | o cenário do Jardim A sem personagens (o recorte do ENV-02) |
| `dano_apos_sala_vencida.jpg` | quadros de 15,2 a 16,0 s do vídeo da Cripta A (`run ... --write-movie ... --quit-after 840 -- --nosave --arena=crypt --variant=0 --seed=5 --bot --autopick --bot-reaction=0.25`), recorte 700 x 450 em (700, 250) | o aviso vermelho em linha continua no chão depois de "Sala vencida" e fere o herói (30 para 27); ver Achados |

## Medidas

### GP-01: colunas, gemas e a entrada de Morvath (aceite: maior canal das colunas até 235; mediana de Morvath aos 0,5 s acima de 30)

| Recorte (x, y, largura x altura, em 1920 x 1080 salvo indicação) | Lum. | R, G, B (medianas) | Máx. | > 235 |
|---|---|---|---|---|
| Coluna da recompensa, Cripta A (`coluna_recompensa_criptaA`, 905, 220, 90 x 300) | 255 | 255, 255, 255 | 255 | 97,7% |
| Coluna sobre o herói (`coluna_sobre_heroi_criptaA`, 985, 260, 55 x 180) | 252 | 255, 255, 227 | 255 | 98,2% |
| Herói dentro da coluna (o mesmo, 990, 470, 60 x 70) | 252 | 255, 255, 225 | 255 | 85,7% |
| Coluna da fonte (`coluna_fonte`, 1440, 200, 40 x 150) | 255 | 255, 255, 255 | 255 | 100% |
| Coluna sobre Morvath, 0,5 s (`morvath_entrada_0_5s`, 945, 220, 90 x 200) | 253 | 248, 255, 255 | 255 | 100% |
| Morvath, miolo do corpo, 0,5 s (o mesmo, 988, 470, 34 x 40) | **83** | 43, 103, 90 | 255 | 1,9% |
| Morvath, caixa do corpo com a coluna em volta (955, 440, 100 x 90) | 219 | 143, 255, 238 | 255 | 56,9% |
| Morvath, miolo, quadro 15 do Movie Maker (= 0,50 s, 1280 x 720: 660, 313, 20 x 22) | 131 | 66, 162, 130 | 255 | 9,8% |
| Morvath sem coluna, 1,0 s (Movie Maker, 655, 310, 30 x 30) | 20 | 29, 11, 52 | 77 | 0% |
| Gema Fortalecer dom, vermelha (`gemas_portas_criptaA`, 572, 582, 26 x 26) | 254 | 255, 255, 248 | 255 | 100% |
| Gema Mais magia, azul (1282, 702, 30 x 30) | 255 | 255, 255, 255 | 255 | 100% |
| Gema Dom, amarela (1335, 312, 18 x 24) | 250 | 255, 255, 207 | 255 | 95,6% |
| Gema Dom na fonte (`coluna_fonte`, 1625, 270, 26 x 26) | 255 | 255, 255, 255 | 255 | 100% |
| Gema Ouro na fonte (1574, 794, 32 x 32) | 255 | 255, 255, 255 | 255 | 100% |
| Vídeo 720p, coluna da recompensa do Jardim aos 0:56,6 (495, 100, 60 x 220) | 255 | 255, 255, 255 | 255 | 100% |
| Vídeo 720p, coluna de Morvath aos 2:14,9 (entrada aos 2:14,4 + 0,5 s; 630, 100, 50 x 170) | 253 | 252, 255, 255 | 255 | 92,6% |
| Vídeo 720p, Morvath miolo no mesmo quadro (658, 315, 25 x 35) | 86 | 46, 106, 92 | 255 | 10,5% |
| Vídeo 720p, gemas da loja aos 2:11 (Dom 738, 250; Fortalecer 845, 295; Cura 1080, 340; 16 a 18 px) | 253 / 173 / 252 | branco / 255, 138, 140 / branco | 255 | 100 / 94,5 / 97,5% |

Leitura: toda coluna e toda gema chega a 255 em todos os canais (miolo branco, a cor some). A entrada de Morvath
**já passa no "mediana acima de 30" do aceite** (83 no quadro do `--shot`, 131 no do Movie Maker): o corpo não sai preto
puro, sai verde-escuro porque a coluna é desenhada por cima dele; a silhueta lê pelo contraste com a coluna em volta (83
contra 253). Sem a coluna, aos 1,0 s, o miolo do manto tem 20 (o manto dele é escuro de propósito). Para o depois, o
critério que separa antes de depois é o **maior canal da coluna até 235** (hoje 255); a mediana acima de 30 precisa de
um recorte fixo do corpo e não mede a melhora sozinha. Sugestão ao `gameplay-engineer`/Game Director: trocar ou somar
"diferença de luminância entre o corpo e o que está em volta até 120" (hoje 83 contra 219 na caixa).

### ENV-01: chão da Cripta na luta (aceite: recortes longe das velas com mediana 45 a 60; tampa até 150)

| Recorte (`crypt_vX_c_recortes`, x, y, largura x altura) | Lum. | R, G, B | Máx. |
|---|---|---|---|
| A, oeste (230, 440, 150 x 70) | **12** | 11, 11, 18 | 39 |
| A, norte, entre as colunas (650, 330, 150 x 60) | **22** | 22, 20, 28 | 62 |
| A, sul, entre os túmulos (700, 620, 150 x 80) | **37** | 41, 34, 42 | 67 |
| A, sudeste, na frente do herói (1120, 640, 140 x 70) | **45** | 51, 42, 46 | 76 |
| A, tampa do túmulo grande (940, 425, 80 x 30) | 130 | 122, 125, 172 | 215 |
| A, quadro inteiro | 10 | 11, 8, 13 | 255 |
| B, oeste (280, 470, 150 x 60) | **19** | 20, 17, 24 | 44 |
| B, norte (730, 320, 150 x 55) | **21** | 23, 19, 27 | 69 |
| B, sul (780, 650, 150 x 70) | **39** | 44, 36, 43 | 67 |
| B, leste (1280, 575, 140 x 60) | **41** | 42, 38, 48 | 104 |
| B, quadro inteiro | 9 | 10, 8, 13 | 255 |
| Vídeo da descida, Cripta na sala 3 aos 1:15 (720p): oeste (180, 330, 100 x 45), norte (440, 230, 100 x 40), sul (460, 410, 100 x 45), sudeste (720, 470, 90 x 40) | 16 / 23 / 32 / 25 | 17, 14, 21 a 35, 29, 36 | 40 a 66 |

Leitura: só 1 dos 8 recortes do chão chega a 45 (o sudeste da A, perto do herói e da luz dele); a mediana dos 8 é 30 e a
borda oeste fica em 12 a 19. A tampa está dentro do C-1 (130, máximo 215, nenhum canal acima de 235).

### ENV-02: fraturas dos galhos (aceite: maior canal até 200)

| Recorte | Lum. | R, G, B | Máx. |
|---|---|---|---|
| `jardim_vA_a_cenario`, fratura 1 (641, 180, 16 x 20) | 94 | 108, 90, 96 | 186 |
| `jardim_vA_a_cenario`, fratura 2 (832, 157, 18 x 18) | 169 | 167, 168, 183 | 196 |
| `jardim_vA_a_cenario`, fratura 3 (486, 50, 14 x 14) | 78 | 80, 71, 114 | 145 |
| `jardim_arvore_heroi`, fratura 1 (765, 228, 20 x 20) | 119 | 147, 110, 99 | 197 |
| `jardim_arvore_heroi`, fratura 2 (962, 205, 20 x 20) | 167 | 164, 164, 186 | **206** |

No cenário do laboratório as três ficam até 196; com a câmera do jogo e o herói perto, a fratura 2 passa a 206.

### Som (GP-05; aceite: pico até -1,0 dBFS)

Medido no PCM do AVI (antes da conversão), 0 a 245 s:

| Medida | Valor | Comando |
|---|---|---|
| Pico | **0,0 dBFS** (astats `Peak level` +0,0003 dB; 232 amostras em 0 dB no `volumedetect`) | `ffmpeg -t 245 -i descida.avi -vn -af volumedetect -f null -` e `astats=measure_overall=Peak_level+RMS_level` |
| RMS / volume médio | -23,2 dB | idem |
| Janelas de 0,1 s acima de -1 dBFS | 5: 1:07,8 (0,00 dB, Cripta, armadura quebrando, "Atordoado!"), 2:53,8 (-0,74, ritual), 2:55,8 (-0,28, escudo do ritual se partindo, quadro de impacto), 3:32,1 (-0,09, fase 4), 3:53,6 (0,00, fase 4, quadro de impacto); 75 janelas acima de -3 dBFS | `asetnsamples=n=4800,astats=metadata=1:reset=1,ametadata=print` |
| Silêncios de 2 s ou mais (abaixo de -50 dB; iguais a -60 dB, é silêncio digital) | **12 trechos, 40,6 s de 245 (16,6%)**; sem o fim parado na tela de derrota, 11 trechos e 36,8 s (15,0%) | `silencedetect=noise=-50dB:d=2` |
| Onde | 0:00 a 0:03,0 (3,0 s); 0:21,3 a 0:25,5 (4,2, troca de sala); 0:48,2 a 0:50,2 (2,0); 0:51,6 a 0:53,8 (2,2); 0:57,0 a 0:59,0 (2,0); 0:59,9 a 1:04,9 (5,0, sala vencida e troca); 1:24,3 a 1:26,4 (2,1); 1:29,8 a 1:35,2 (5,5, fonte); 1:35,8 a 1:39,0 (3,2, começo do guardião); 2:05,9 a 2:09,1 (3,1, guardião vencido e troca); 2:10,0 a 2:14,4 (4,4, loja até a câmara); 4:01,2 a 4:05 (3,8, tela de derrota) | |

No AAC do `.mp4` o pico continua 0,0 dB (217 amostras) e os mesmos 12 silêncios. Música desligada (`CLAUDE.md`):
os silêncios são as salas sem luta, as trocas de sala, a fonte e a loja.

### Quadro na placa de vídeo, 1920 x 1080 (para o "sem piora de mais de 0,3 ms" do ENV-01 e do aceite 7)

Sonda `C:/Users/danie/tools/qa/gpuperf9.gd` (a do C12), uma rodada por cena, 240 quadros para assentar e 300 medidos:
`MIRROR=... tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --disable-vsync -s
C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave --seed=5 --bot --bot-reaction=0.25
--probe-settle=240 <cena>`. Janela 1920 x 1080, 3D desenhado em 2880 x 1620, tela 1920 x 1200.

| Cena | Quadro mediana | p90 | GPU mediana | CPU de desenho | Chamadas | Primitivas | De pé (média, máx.) |
|---|---|---|---|---|---|---|---|
| `--arena=crypt --variant=0` | 3,69 ms | 4,21 | 3,60 | 0,66 | 701 | 1,21 M | 2,4, 3 |
| `--arena=crypt --variant=1` | 3,64 ms | 4,12 | 3,49 | 0,76 | 674 | 1,55 M | 3,2, 4 |
| `--arena=rift --variant=0` | 4,44 ms | 4,90 | 4,34 | 0,83 | 856 | 1,52 M | 4,0, 6 |
| `--arena=garden --variant=0` | 4,99 ms | 5,40 | 4,91 | 0,91 | 804 | 1,27 M | 2,9, 6 |
| `--arena=hall` | 5,22 ms | 5,66 | 5,12 | 1,23 | 935 | 0,84 M | 3,6, 4 |

Uma rodada só por cena: comparar o depois com a mesma sonda, na mesma sessão de tomada, e repetir se a diferença ficar
perto de 0,3 ms.

## Achados (para o Game Director)

1. **Média, `gameplay-engineer` (`rooms.gd` `_room_cleared`)**: um aviso de golpe inimigo que já estava no chão continua
   depois de "Sala vencida" e fere o herói. Reproduzir: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080
   --fixed-fps 30 -- --nosave --arena=crypt --variant=0 --seed=5 --bot --autopick --bot-reaction=0.25 --frames=<prefixo>
   --shot-at=14.3 --count=30 --every=0.1`: a sala é vencida aos 14,5 s com o herói em 30/30, a linha vermelha continua sob
   ele, e aos 15,73 s a borda vermelha de golpe aparece e a vida vai a 27/30 (quadro `_08`, número "3";
   `dano_apos_sala_vencida.jpg`). O `RESULT` dessa partida termina com `hp: 27` na sala 2. Causa
   provável: `_room_cleared` chama `projectiles.clear_hostile()` mas não `ground.clear_warnings()` (os avisos de quem morreu
   ficam). Teste que falha a escrever pelo dono: vencer uma sala com um `Ground.add_line_warning` ativo sob o herói e
   conferir que a vida não muda. Não mexi no código.
2. **Baixa, Game Director (aceite do GP-01)**: a mediana de Morvath aos 0,5 s já passa de 30 no antes (83); o aceite não
   distingue antes de depois por esse número. Ver a sugestão na seção GP-01.
3. **Ferramenta**: o Movie Maker com `--resolution 1920x1080` gravou em 1280 x 720 (os três vídeos curtos e o da descida); o
   `--shot` e o `--frames` saem em 1920 x 1080. Por isso os quadros de 1080 vêm do `--frames`, e os do Movie Maker só para
   a sequência no tempo. O `crypt/vA_c_combate.jpg` e o `vB_c` do `cycle12_maps` (refeitos no `95c29c6`) também estão em
   1280 x 720, e a maioria das capturas do `cycle12_maps` está em 1920 x 1080; os recortes do `ART_REVIEW.md` para a Cripta
   não se aplicam sem escala. Os deste arquivo são todos em 1920 x 1080 (os de vídeo, indicados, em 1280 x 720).
4. O DT-004 (descida inteira com som a 1920 x 1080) fica para o QA-02: com o Movie Maker como está, a 1080 depende de
   achar por que a janela do Movie Maker não aceita o tamanho (provável escala de 150% do Windows).

## Limitações

- Uma partida de cada: o vídeo da descida é a semente 7 com reação 0,25; o robô morre na fase 4 (a mesma semente no
  `--smoke` a 30 FPS sem tela também chega em Morvath e morre aos 227 s; a 60 FPS morre na sala 5: o resultado depende da
  taxa de quadros).
- Som medido só no que o Movie Maker mistura (sem placa de som; nada ouvido por gente). Silêncio medido como sinal abaixo
  de -50 dB por 2 s ou mais.
- Quadro na GPU: uma rodada por cena, notebook ligado na tomada (não conferido de novo nesta sessão), outros agentes
  podiam estar usando o WSL (não a GPU: o `tools/gpu.sh` tem trava).
- Testes GUT, `check.gd` e smokes de regressão não foram rodados neste QA-01 (só leitura e capturas); ficam para o QA-02.
- Os brutos (AVI de 1,1 GB e os curtos) foram apagados; os PNG de 1920 x 1080 ficam em
  `C:/Users/danie/tools/qa/c12c/` (fora do repositório) para refazer recortes.
