# Capturas e vídeos do C12 (Arenas I)

Capturas reais da Godot 4.7.2 de Windows na placa de vídeo do Daniel (NVIDIA GeForce RTX 5060 Laptop GPU, Vulkan
1.4.357, Forward+), tiradas em 2026-11-16 pelo QA sobre o commit `91cc656` (`arpg-3d`), espelho padrão
`C:/Users/danie/tools/eterra-gpu` (sincronizado uma vez com `tools/gpu.sh sync`; depois a Godot de Windows chamada direto,
com a mesma linha de comando do `tools/gpu.sh`), notebook na tomada (`Win32_Battery.BatteryStatus` 2, 100%). Nenhuma
imagem foi gerada por IA, editada ou retocada: cada quadro é o que o jogo salvou, só regravado de PNG para JPG pelo
ffmpeg (`-q:v 3`). As montagens (`_e_` e `_f_`) só juntam quadros inteiros, com uma faixa de rótulo acima de cada um
(ffmpeg `scale`, `pad`, `drawtext`, Alegreya Sans Bold do projeto).

**Referência**: nas montagens `_f_referencia` a coluna da esquerda é uma **miniatura de 480 px de largura da imagem de
referência feita por IA** (rotulada "referência (IA)", de `docs/art/ref/cycle12_maps/`, que fica só local); o resto é o
jogo. Cripta com a `05`, Fendas com a `02`, Jardim com a `04` (as que o `docs/art/cycle12_arenas_spec.md` usa).

Abreviações: `lab` = `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/arena_lab.gd -- <saída>`;
`shot` = `RES=1920x1080 tools/gpu.sh shot <saída>` (janela a `--fixed-fps 30`, câmera do jogo, `--nosave`). `<a>` é
`crypt`, `rift` ou `garden`; `vA` = `--variant=0`, `vB` = `--variant=1`.

## Por arena e variante (pastas `crypt/`, `rift/`, `garden/`)

| Arquivo | Comando | O que se vê |
|---|---|---|
| `vX_a_cenario.jpg` | `lab --arena=<a> --variant=n --bare` | (a) o cenário inteiro na câmera do jogo, sem personagens nem sobreposições |
| `vX_a_planta_lab.jpg` | `lab --arena=<a> --variant=n --top` | vista de cima com a grade de caminho (verde), colisões (laranja: barra tiro; branco: só corpo), zonas de nascimento (azul), portas (ouro), caixa da câmera (ciano) |
| `vX_b_explorador.jpg` | `shot --arena=<a> --variant=n --seed=5 --shot-at=1.2` | (b) o Explorador onde nasce, com o nome da arena; o primeiro inimigo já se erguendo |
| `vX_c_combate.jpg` | `shot --arena=<a> --variant=n --seed=5 --bot --autopick --bot-reaction=0.25 --shot-at=5 --shot-on=hit --shot-after=0.05` | (c) um golpe que acerta, 5,6 a 6,3 s (3 a 5 inimigos de pé) |
| `vX_d_obstaculo.jpg` | `shot --arena=<a> --variant=n --seed=5 --shot-at=1.2 --hero-at=...` | (d) o herói junto do obstáculo principal: Cripta A `-2.2,1.8` (túmulo grande), Cripta B `-1.3,-4.6` (muro do ossário); Fendas A e B `-2.5,1.5` (na ponte sul; na B a ponte norte caída ao fundo); Jardim A e B `-8,-0.8` (ao sul do tronco) |
| `garden/vA_d_atras_do_tronco.jpg` | o mesmo com `--hero-at=-11,-9.5` | o herói atrás do tronco, visto pelo pontilhado da copa |
| `vX_e_entrada_saida.jpg` | esquerda: o `_b_`; direita: um quadro de `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 -- --nosave --arena=<a> --variant=n --seed=5 --bot --autopick --bot-reaction=0.25 --frames=<prefixo> --shot-at=8 --count=30 --every=1` | (e) entrada e as saídas abertas com o sinal da recompensa, depois da sala vencida pelo robô (quadros usados: Cripta A 0:15, B 0:14; Fendas A 0:14, B 0:14; Jardim A 0:12, B 0:10) |
| `vX_f_referencia.jpg` | miniatura da referência + o `_a_cenario` | (f) comparação lado a lado |
| `travessia.mp4` | `tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 --fixed-fps 60 --write-movie <x>.avi -- --nosave --arena=<a> --variant=0 --seed=5 --bot --autopick --bot-reaction=0.25 --shot=<fim>.png --shot-at=21`, cortado em 20 s com `ffmpeg -t 20 -c:v libx264 -preset slow -crf 26 -pix_fmt yuv420p -movflags +faststart -an` | vídeo de 20 s, 1280 x 720, 60 FPS, sem som: o robô entra, atravessa a arena lutando, a sala é vencida, ele anda até uma porta e entra na sala 2 (Fendas, conferido numa folha de um quadro por segundo: luta perto da ponte sul, sala vencida perto de 0:09, portas abertas de 0:11 a 0:13, sala 2 a partir de 0:14; nas três o fim mostra a sala seguinte) |

## Situações à mão (seção 15 do pedido)

| Arquivo | Comando | O que se vê |
|---|---|---|
| `rift/vA_g_heroi_na_borda_da_fenda.jpg` | `shot --arena=rift --variant=0 --seed=5 --hero-at=-8.3,-4 --shot-at=1.2` | o herói encostado na borda oeste da fenda; a balaustrada quebrada fica 0,55 m para fora da borda e abre em pontilhado na frente dele |
| `rift/vA_g_hero_at_dentro_do_buraco.jpg` | o mesmo com `--hero-at=-2.5,-4` (o meio da fenda) | o herói levado para o chão mais perto (a ponte norte), nunca dentro do buraco |
| `crypt/vA_g_hero_at_dentro_do_tumulo.jpg` | `shot --arena=crypt --variant=0 --seed=5 --hero-at=0.5,0 --shot-at=1.2` | **o herói fica desenhado em cima do túmulo** quando o `--hero-at` cai no centro exato dele (ver o relatório de QA, B-2; no jogo isso não acontece) |
| `garden/vA_g_corredor_estreito.jpg` | `shot --arena=garden --variant=0 --seed=5 --hero-at=14.2,4.9 --shot-at=1.2` | o herói no corredor mais estreito que o roteiro achou no Jardim A (3,6 m, entre a mureta e a borda leste) |
| `rift/vA_h_compatibility_combate.jpg` | `DRIVER=opengl3`, o mesmo `_c_combate` | o renderizador do navegador (Compatibility) na mesma placa: mais claro e mais azul que o Forward+, sem erro |

Os testes mecânicos dessas situações (esquiva na borda, andar e esquivar contra cada obstáculo, cercado num corredor)
estão no `METRICAS.md`, seção 4.

## `work/` (do ciclo, mantido)

Antes e depois do environment-artist e do Game Director, regravados em JPG pelo QA (mesmos nomes): `before_*` (cinza
antes do cenário), `w4_*` (a última rodada da Cripta e das Fendas), `garden_*` (antes, vitrine, grade do herói atrás da
copa, Compatibility), `after_*` (o salão, a câmara e o Compatibility depois do ciclo), `game_rift_grey` (as Fendas em
cinza). Apagados por serem rodadas intermediárias já cobertas: `w1_*`, `w2_*`, `w3_*` e `lab_*_top` (os `vX_a_planta_lab`
acima os substituem). `garden_vs_04` **trazia a referência de IA em tamanho cheio (1919 px) dentro de `docs/gallery`**;
foi refeito com a miniatura de 480 px e o rótulo, mantendo a metade do jogo como estava. O arquivo antigo continua no
histórico do git (commit `91cc656`).

## Correções da revisão de arte na Cripta e no Jardim (C-1 a C-4, J-1 a J-4, G-1)

Depois da `ART_REVIEW.md`, o environment-artist refez **todas as capturas da Cripta e do Jardim** desta pasta (`crypt/`,
`garden/`, inclusive `travessia.mp4`, e `work/garden_grid_a`/`_b`) com os mesmos comandos acima, na mesma placa (RTX 5060,
Forward+), espelho `C:/Users/danie/tools/eterra-gpu-garden`, 2026-11-16. As Fendas (`rift/`) não mudaram. Antes e depois em
`work/`: `fix_crypt_antes`/`_depois` e `fix_garden_antes`/`_depois` (o laboratório, `lab --arena=<a> --variant=0 --bare`),
`fix_crypt_detalhe_antes_depois` e `fix_garden_arvore_antes_depois` (recortes dos mesmos quadros), `fix_crypt_compat` e
`fix_garden_compat` (o `_c_combate` no Forward+, no Compatibility antes e no Compatibility depois da compensação por sala).
As grades `work/garden_grid_a`/`_b` foram tiradas com `--autopick` a mais (`tools/garden_grid.gd -- <saída> --arena=garden
--variant=n --nosave --autopick`): sem ele a tela de dom da sala vencida cobria as últimas células da folha. Quadros das
saídas abertas nos `_e_`: Cripta A 0:15, B 0:14; Jardim A 0:12, B 0:10.
## Fendas refeitas depois das correções F-1 a F-6 e G-1 (environment-artist, 2026-11-16)

Todos os arquivos de `rift/` (inclusive `travessia.mp4`, as montagens `_e_` e `_f_` e os `_g_` e `_h_`) foram refeitos com
os mesmos comandos das tabelas acima, na mesma placa (RTX 5060, Forward+; o `_h_` em Compatibility pelo `opengl3`), a
partir de uma worktree com espelho próprio (`MIRROR=C:/Users/danie/tools/eterra-gpu-wt`). Quadros usados no `_e_`: A e B
0:14. Antes e depois em `work/fix_rift_*`: `*_antes_*` são os arquivos desta pasta no commit `fd72101` (e uma captura do
laboratório com o alvo (-2; 0)), `*_depois_*` os novos; `fix_rift_vA_antes_depois_*` lado a lado, `fix_rift_vA_miniatura_320`
as duas a 320 px (critério da F-2), `fix_rift_vA_compat_vs_forward` o mesmo combate nos dois renderizadores (G-1). A
Cripta e o Jardim não mudaram (nada do código comum foi tocado).

## Cripta refeita no C12c (ENV-01; environment-artist, 2026-11-16)

Todos os arquivos de `crypt/` (inclusive `travessia.mp4` e as montagens `_e_` e `_f_`) foram refeitos com os mesmos
comandos das tabelas acima, na mesma placa (RTX 5060, Forward+), espelho `C:/Users/danie/tools/eterra-gpu-env2`, depois
do chão da luta subir para 45 a 60 (lajes mais claras e a luz de cima mais larga, `CryptLook.KEY_*`). Quadros das saídas
abertas nos `_e_`: A 0:15, B 0:14. Do Jardim só `vA`/`vB_a_cenario` e `_f_referencia` foram refeitos (fraturas da árvore no
marfim velho, ENV-02); o resto do Jardim e as Fendas não mudaram. Antes e depois em `docs/gallery/cycle12c/work/env_*`.
