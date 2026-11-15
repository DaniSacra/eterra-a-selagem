# Capturas do ciclo 8

Todas são capturas reais da Godot 4.7.2 (Windows) na placa de vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU,
Vulkan 1.4.357, renderizador Forward+), tiradas em 2026-11-15 pelo QA. Nenhuma imagem foi gerada por IA, editada ou
retocada: cada arquivo é o quadro que o jogo salvou (`--shot` ou `--frames`), só regravado de PNG para JPG com
qualidade 85 (`Image.save_jpg(caminho, 0.85)` da própria Godot). As montagens de antes e depois só juntam quadros
inteiros (e recortes ampliados deles) lado a lado, com uma faixa de rótulo **acima** de cada quadro (`ffmpeg pad` e
`drawtext`, fonte Alegreya Sans Bold do projeto), sem cobrir nem mudar o conteúdo.

- **Depois**: `84285e8` (branch `arpg-3d`, working tree limpo), espelho padrão `C:/Users/danie/tools/eterra-gpu`.
- **Antes**: `eb1e9d7` (antes do ciclo 8), extraído por `git archive eb1e9d7 | tar -x -C /home/dani/games/c8-before`
  e espelhado em `C:/Users/danie/tools/eterra-gpu-before8` (`MIRROR=... /home/dani/games/c8-before/tools/gpu.sh`).
- Resolução 1920 x 1080 em todas (`RES=1920x1080`), semente 5, `--nosave`, janela em `--fixed-fps 30` (o `gpu.sh shot`).
- `shot` abaixo = `RES=1920x1080 tools/gpu.sh shot <saída.png>` seguido das opções. "Momento" é o relógio da partida
  (`time` da linha `RESULT`); "de pé" é `enemies` da mesma linha.
- **Antes e depois não são o mesmo instante**: o `8b821b1` mudou a geração das salas, o sorteio consome o gerador de
  outro jeito e o primeiro dom sorteado muda (antes "Corte Veloz", depois "Seta de Luz" ou "Giro da Alvorada"). As
  linhas `RESULT` dos dois commits diferem (ex.: 12 inimigos, 675 contra 776 de dano), então as montagens comparam o
  mesmo comando, não a mesma pose.
- Saídas cruas: `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/qa8/`
  (`png/`, `lab/`, `out/shots.log`, `out/extra.log`).

`I6` = `--stress-ids=skeleton,runner,mage,archer,guard,priest`.

| Arquivo | Comando | Momento e o que se vê |
|---|---|---|
| `01_combate_4_inimigos.jpg` | shot `--bot --autopick --stress=4 --stress-ids=skeleton,archer,mage,guard --seed=5 --shot-at=5` | 4,8 s; 4 de pé (1 abatido); herói atacando no patamar oeste com aviso em leque vermelho sob ele |
| `02_combate_8_inimigos.jpg` | shot `--bot --autopick --stress=8 --stress-ids=skeleton,runner,mage,archer --seed=5 --shot-at=1.2` | 1,1 s; 5 de pé (3 já abatidos: o robô mata rápido; com `--shot-at=5` ou `2.5` sobravam 4); números verdes do dom "Giro da Alvorada" |
| `03_combate_12_inimigos.jpg` | shot `--bot --autopick --stress=12 I6 --seed=5 --shot-at=2.5` | 2,4 s; 10 de pé; herói no patamar, aviso em arco no chão |
| `04_combate_16_inimigos.jpg` | shot `--bot --autopick --stress=16 --stress-ids=skeleton,runner,mage,archer,guard,priest,skeleton_elite,guard_elite --seed=5 --shot-at=1.2` | 1,1 s; 13 de pé; herói dentro do bolo, "Atordoado!" de armadura quebrada |
| `05_combate_20_inimigos.jpg` | shot `--bot --autopick --stress=20 --stress-ids=skeleton,runner,mage,archer,guard,priest,runner_elite,mage_elite --seed=5 --shot-at=1.2` | 1,1 s; 14 de pé de 20 (6 abatidos no primeiro segundo) |
| `06_explorador_em_combate.jpg` | shot `--bot --autopick --seed=5 --cam-dist=32 --shot-at=9` | 8,8 s; câmera mais perto (32 m em vez de 54); herói correndo sobre o aviso em linha de um esqueleto |
| `07_emeth_ataque.jpg` | shot `--bot --autopick --seed=5 --shot-at=5 --shot-on=swing --shot-after=0.066` | 5,4 s; fita verde do golpe, números 21, 41 e 62, círculo de luz ativo, aviso em leque de um inimigo sobre o herói |
| `08_emeth_impacto.jpg` | shot `--bot --autopick --seed=5 --shot-at=7 --shot-on=hit --shot-after=0.066` | 7,4 s; o golpe que acerta é a Lança de Luz (Ômega): feixe com veios de ouro, meia-lua, números esmeralda 176 e 178, separação de cor na borda da tela |
| `09_emeth_especial.jpg` | shot `--bot --autopick --seed=5 --shot-at=2 --shot-on=special --shot-after=0.05` | 4,8 s (o robô só usa o especial aí); dardo verde saindo da lâmina para três inimigos a cerca de 3 m |
| `10_inimigos_preparando_ataque.jpg` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 -- --nosave --bot --autopick --stress=8 --stress-ids=archer,mage,priest,guard --seed=5 --frames=C:/Users/danie/tools/labout/qa8/tell --shot-at=1.5 --count=20 --every=0.15`; quadro `tell_09` | cerca de 2,8 s; o Escudo prepara a investida com o aviso em linha apontado para o herói, feiticeiros com o orbe violeta. Escolhido entre 20 quadros seguidos (folha de contato `lab/tell_sheet.png`) |
| `10b_preparo_laboratorio.jpg` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/enemy_lab.gd -- C:/Users/danie/tools/labout/qa8/lab_tell idle 0 --tell=0.85`; recorte 1440 x 360 de `lab_tell_game.png` | galeria parada a 85% do preparo: herói, esqueleto (brilho), corredor, feiticeiro, arqueiro, escudo, sacerdote, cavaleiro, ancião, Morvath (elites atrás). Laboratório, não partida |
| `11_elite.jpg` | shot `--bot --autopick --stress=6 --stress-ids=guard_elite,skeleton_elite,mage_elite,archer_elite,priest_elite,runner_elite --seed=5 --shot-at=4` | 3,9 s; 6 elites de pé, barras com armadura em faixa própria e moldura de ouro velho |
| `12_obstaculo_transparencia.jpg` | shot `--start=fountain --bot --seed=5 --cam-dist=26 --shot-at=1.5` | 1,5 s; sala 2 (fonte); herói correndo atrás do obelisco sul: pernas escurecidas com fio marfim, sem anel sobre a pedra (mesmo comando da frente B em `work/`) |
| `13_hud.jpg` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 -- --nosave --bot --autopick --seed=5 --frames=C:/Users/danie/tools/labout/qa8/hud --shot-at=8 --count=24 --every=0.1`; quadro `hud_14` | cerca de 9,4 s; avanço (Espaço) em recarga com o nível de ouro velho subindo na gema, Magia 30/50, "Seta de Luz", contador 14 golpes, dois avisos (arco e linha). Escolhido pela folha `lab/hud_sheet.png` |
| `14_morvath_atual.jpg` | shot `--start=boss --bot --autopick --seed=5 --shot-at=12` | 11,9 s; sala 5, Morvath com aviso em leque, portal vermelho e degraus e chão em vermelho (o derrame segue o portal), barra do chefe |
| `before_after_combate.jpg` | grade 2 x 2. Em cima: shot `--bot --autopick --stress=12 I6 --seed=5 --shot-at=5` (antes 4,8 s, 10 de pé; depois 4,9 s, 10 de pé). Embaixo: shot `--bot --autopick --stress=20 --stress-ids=skeleton,runner,mage,archer,guard,priest,runner_elite,mage_elite --seed=5 --shot-at=1.2` (antes 1,1 s, 19 de pé; depois 1,1 s, 14 de pé) | 3840 x 2272 |
| `before_after_emeth.jpg` | grade 2 x 2. Em cima o `07` (swing) nos dois commits; embaixo o `08` (hit) nos dois | 3840 x 2272. Antes o atingido vira silhueta branca; depois fica na cor dele |
| `before_after_obstaculo.jpg` | o `12` nos dois commits; embaixo o recorte 640 x 480 em (640, 280) ampliado 3x | 3840 x 2632 |
| `before_after_hud.jpg` | shot `--bot --autopick --seed=5 --shot-at=9` nos dois commits; embaixo o recorte 1200 x 180 em (0, 900) ampliado 1,6x | 3840 x 1480. A câmera difere porque a partida difere (ver acima) |

Capturas tiradas e descartadas (estão em `png/`): `after_02.png` e `after_02b.png` (só 4 de pé), `after_03.png` (usada
só na montagem), `after_04.png`, `after_05.png`, `after_05b.png` (menos inimigos ou herói difícil de achar),
`after_10.png` (herói na borda, preparo pouco legível), `after_13.png` (sem recarga visível; usada na montagem de HUD).
