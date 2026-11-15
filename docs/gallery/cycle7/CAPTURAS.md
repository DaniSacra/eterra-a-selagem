# Capturas do ciclo 7

Todas são capturas reais da Godot 4.7.2 (Windows) na placa de vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU,
Vulkan, renderizador Forward+), tiradas em 2026-11-15 por `tools/gpu.sh shot` (janela em `--fixed-fps 30`, `--nosave`).
Nenhuma imagem foi gerada por IA, editada ou retocada: cada arquivo é o quadro que o jogo salvou (`--shot`), só
convertido de PNG para JPG (`ffmpeg -q:v 2`). As montagens de antes e depois só juntam quadros inteiros lado a lado e
põem uma faixa com o rótulo **acima** de cada quadro (`pad` e `drawtext`), sem cobrir nem mudar o conteúdo.

- **Commit "depois"**: `7fb5b4b` (branch `arpg-3d`; no momento só havia uma mudança de texto no `CLAUDE.md`, sem código).
- **Commit "antes"**: `5429394` (início do ciclo 7, já com as opções de captura), extraído por `git archive` em
  `/home/dani/games/eterra-before-5429394` e espelhado em `C:/Users/danie/tools/eterra-gpu-before`
  (`MIRROR=... tools/gpu.sh` rodado dessa cópia).
- Resolução 1672 x 941 salvo indicação. Semente 5 salvo indicação. "Momento" é o relógio da partida na captura.
- O robô é determinístico: as capturas de mesmo comando no antes e no depois deram a mesma linha `RESULT` (mesmo tempo,
  abates e dano), então herói e inimigos estão no mesmo lugar; só o desenho mudou.
- A arte de fundo da tela de título (`01` a `03`) é a ilustração do jogo feita por IA e declarada em `docs/steam-ia.md`;
  a captura em si é a tela real do jogo.

`shot` abaixo = `tools/gpu.sh shot <saída.png>` seguido das opções.

| Arquivo | Comando | Resolução | Momento e o que se vê |
|---|---|---|---|
| `01_titulo_1280.jpg` | `RES=1280x720` shot `--title --shot-at=3` | 1280 x 720 | 3 s, tela assentada, foco em Iniciar |
| `02_titulo_1920.jpg` | `RES=1920x1080` shot `--title --shot-at=3` | 1920 x 1080 | idem |
| `03_titulo_hover.jpg` | `RES=1280x720` shot `--title --hover=1 --shot-at=3` | 1280 x 720 | mouse sobre Como Jogar (moldura e ícone acesos) |
| `04_explorador_idle.jpg` | shot `--start=fountain --seed=5 --cam-dist=26 --shot-at=3` | 1672 x 941 | 3,0 s, sala 2 (fonte), herói parado no patamar, sem inimigos |
| `05_explorador_corrida.jpg` | shot `--start=fountain --bot --seed=5 --cam-dist=26 --shot-at=1.5` | 1672 x 941 | 1,5 s, correndo atrás do obelisco (desenhado através dele) |
| `06_emeth_ataque.jpg` | shot `--bot --autopick --seed=5 --shot-at=5 --shot-on=swing --shot-after=0.066` | 1672 x 941 | 5,2 s, 2 quadros depois do golpe: fita verde no auge, dois inimigos atingidos |
| `06b_emeth_omega.jpg` | shot `--bot --autopick --seed=5 --shot-at=2 --shot-on=omega --shot-after=0.066` | 1672 x 941 | 6,8 s, Lança de Luz (Ômega), números esmeralda 176 e 178, Magia 30/50 |
| `07_emeth_impacto.jpg` | shot `--bot --autopick --seed=5 --shot-at=7 --shot-on=hit --shot-after=0.066` | 1672 x 941 | 8,1 s, estocada (feixe estreito), inimigo em reação, número 34. **Ajuste**: com `--shot-at=5` (comando do contrato) o primeiro golpe que acerta é o mesmo do `06` e o quadro sai quase idêntico (PSNR 47 dB entre os dois); por isso `--shot-at=7` |
| `08_emeth_especial.jpg` | shot `--bot --autopick --seed=5 --shot-at=2 --shot-on=special --shot-after=0.05` | 1672 x 941 | 4,2 s, Seta de Luz: dardo verde saindo da lâmina para o inimigo. **Ajuste**: com `--shot-after=0.1` o dardo já tinha chegado (o alvo está a cerca de 2 m) e mal aparece; nenhum valor mostra o dardo "a meio caminho" de longe nesta semente |
| `09_inimigos_comparativo.jpg` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- C:/Users/danie/tools/labout/c7qa/todos idle 0`; `todos_game.png` sobre `todos_front.png` (`ffmpeg vstack`) | 1672 x 1882 | parados (clipe `idle`, 0 s). Em cima a câmera do jogo, embaixo de frente. Herói à esquerda; fila: Esqueleto, Corredor, Feiticeiro, Arqueiro, Escudo, Sacerdote, Cavaleiro, Ancião, Morvath; elites atrás |
| `10_inimigos_em_combate.jpg` | shot `--bot --autopick --stress=18 --stress-ids=skeleton,runner,mage,archer,guard,priest --seed=5 --shot-at=5` | 1672 x 941 | 4,9 s, 17 de pé; preparo do Sacerdote (orbe violeta) com aviso vermelho no chão |
| `11_inimigo_elite.jpg` | shot `--bot --autopick --stress=6 --stress-ids=guard_elite,guard,skeleton_elite,skeleton,mage_elite,mage --seed=5 --shot-at=4` | 1672 x 941 | 3,9 s, elites e comuns lado a lado, aviso em linha |
| `12_guardiao.jpg` | shot `--start=miniboss --bot --autopick --seed=5 --shot-at=9` | 1672 x 941 | 8,8 s, sala 3, Cavaleiro Esqueleto com aviso em linha e a barra do topo |
| `12b_guardiao_anciao.jpg` | shot `--start=miniboss --bot --autopick --seed=2 --shot-at=9` | 1672 x 941 | 8,8 s, semente 2, Sacerdote dos Mortos (Ancião) com esqueletos chamados |
| `13_morvath.jpg` | shot `--start=boss --bot --autopick --seed=5 --shot-at=12` | 1672 x 941 | 11,9 s, sala 5, Morvath com arco de aviso, portal vermelho, barra do chefe |
| `14_arena_geral.jpg` | shot `--showcase --seed=5 --shot-at=4` | 1672 x 941 | 4,0 s, enquadramento da pintura de referência (câmera fixa) |
| `15_portal.jpg` | shot `--showcase --cam-at=0.6,-23.6 --cam-dist=28 --seed=5 --shot-at=4` | 1672 x 941 | portal, umbrais, degraus e as duas estátuas encapuzadas |
| `16_estatuas.jpg` | shot `--showcase --cam-at=-21.5,-15.7 --cam-dist=46 --seed=5 --shot-at=4` | 1672 x 941 | estátua encapuzada noroeste, portão violeta, correntes e ruínas distantes |
| `17_abismo.jpg` | shot `--showcase --cam-at=-16,6 --cam-dist=72 --seed=5 --shot-at=4` | 1672 x 941 | lado oeste: brilhos violeta do abismo, arcos, ruínas na névoa |
| `18_medalhao.jpg` | shot `--showcase --cam-dist=32 --seed=5 --shot-at=2` | 1672 x 941 | 2,0 s, medalhão de perto (um Feiticeiro preparando o feitiço sobre ele) |
| `19_combate_40_inimigos.jpg` | shot `--bot --autopick --stress=40 --seed=5 --shot-at=7` | 1672 x 941 | 6,9 s, 29 de pé, herói cercado no patamar oeste |
| `20_combate_90_inimigos.jpg` | shot `--bot --autopick --stress=90 --seed=5 --shot-at=6` | 1672 x 941 | 5,9 s, 82 de pé, herói dentro do bolo |
| `21_hud_1280.jpg` | `RES=1280x720` shot `--bot --autopick --seed=5 --shot-at=9` | 1280 x 720 | 8,8 s, contador 14 golpes, "Corte Veloz", Magia 30/50 |
| `22_hud_1920.jpg` | `RES=1920x1080` shot `--bot --autopick --seed=5 --shot-at=9` | 1920 x 1080 | idem |
| `before_after_titulo.jpg` | `docs/gallery/jogo/11_titulo.jpg` (reduzida para 1280 x 720) ao lado de `01_titulo_1280` | 2560 x 776 | ANTES: título antigo (QA do ciclo 6, `78b0642`); DEPOIS: `7fb5b4b` |
| `before_after_arena.jpg` | `docs/gallery/jogo/final_vitrine.jpg` ao lado de `14_arena_geral` | 3344 x 997 | ANTES: vitrine do ciclo 6 (`78b0642`, mesmo comando `--showcase --shot-at=4`); DEPOIS: `7fb5b4b` |
| `before_after_combate.jpg` | grade 2 x 2; em cima shot `--bot --autopick --seed=5 --shot-at=9`, embaixo shot `--bot --autopick --stress=90 --seed=5 --shot-at=6`; esquerda no `5429394`, direita no `7fb5b4b` | 3344 x 1994 | 8,8 s e 5,9 s; `RESULT` iguais nos dois commits |
| `before_after_inimigos.jpg` | shot `--bot --autopick --stress=18 --stress-ids=skeleton,runner,mage,archer,guard,priest --seed=5 --shot-at=5` no `5429394` e no `7fb5b4b` | 3344 x 997 | 4,9 s; `RESULT` iguais |

Montagens: `-q:v 2` (título e arena) e `-q:v 3` (combate e inimigos, para a galeria caber em cerca de 15 MB).
Fonte do rótulo: Alegreya Sans Bold do projeto.
