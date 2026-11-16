# C12d "Game feel I: a mão", depois (QA final)

Autor: `qa-performance`, 2026-11-16. **Commit testado: `1d06613`** (`arpg-3d`, C12d integrado: `aaaacfc`, `4c560eb`,
`491c6d4`, `1d06613`; árvore limpa no começo). Antes: a sonda no `1e25f21` (`PROBE.md`, `before/feel_probe.txt`), os vídeos
no `beb6c27` (`docs/gallery/game_feel/`), a base de desempenho no `6f9bbc7` (último commit antes do C12d, cópia por
`git archive` em `/home/dani/games/qa-c12d-base`, apagada no fim). O QA não mudou código de jogo, arte nem testes.

Ambiente: WSL2 para importação, testes, sonda e robô (Godot 4.7.2 Linux, sem tela). Vídeos, capturas e latência na placa
real pela Godot 4.7.2 de Windows (Vulkan 1.4.357, Forward+, NVIDIA GeForce RTX 5060 Laptop GPU), espelho
`MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-qa`; monitor a 144 Hz. **O notebook estava na bateria** (às 17:10 e 17:20:
`PowerOnline False`, 99% e 96%): ver "Desempenho na placa". Nenhuma imagem gerada por IA, editada ou retocada.

## 1. Sonda de game feel (GF-14), antes e depois

`~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain`

**Antes `1e25f21`: 4 de 31, saída 1. Depois `1d06613`: `FEEL_SUMMARY 31/31 ok`, saída 0**, nenhuma linha `LOST`
(saída inteira em `after/feel_probe.txt`).

| Meta | Antes | Depois |
|---|---|---|
| GF-01a hit_stop_shape_cut1 | 1 quadro parado, sem espera | 0 parados, espera 1, 1 a 6%, volta em f8 |
| GF-01b no_freeze_combo | 6 quadros parados | 0 |
| GF-01c hit_stop_shape_spin | 4 parados, sem espera | 0 parados, espera 4, 1 a 6% |
| GF-01d hit_stop_shape_kill | 3 parados, sem espera | 0 parados, espera 1, 4 a 6% |
| GF-02a dodge_in_windup | LOST (golpe d1 a d4, seta d1 a d7) | todos saem |
| GF-02b cut_blow_no_damage | nenhum (ok) | nenhum |
| GF-02c dodge_cuts_spin | f23 | f1 |
| GF-03a attack_in_dodge | LOST d1 a d13 | todos |
| GF-03b attack_at_dodge_end | LOST d11 a d13 | todos |
| GF-03c attack_while_hurt | ataque e especial LOST | ataque f3 sai f10, especial f5 sai f10 |
| GF-04a buffer_cut1 | LOST d1 a d3 | todos |
| GF-04b buffer_spin | LOST d1 a d31 | todos |
| GF-05 slow_mo_visible | 17 parados, 0 lentos | 0 parados, 8 lentos andando |
| GF-06 pad_in_hit_stop | teclado f8, controle virtual LOST | os dois em f6 |
| GF-07a bolt_attack_lock | f42 | f25 |
| GF-07b bolt_recharge | f42 | f49 (faixa 47 a 49) |
| GF-07c bolt_speed | 30,0 m/s | 62,5 m/s |
| GF-07d bolt_holds_legs | anda em f8 | parado, anda de novo em f50 |
| GF-07e dodge_cuts_bolt | f20 (ok) | f20 |
| GF-08 omega_when_full | f56 | f48 |
| GF-09a turn_facing | f10 | f0 |
| GF-09b turn_body | f14 | f7 |
| GF-09c plant_on_press | 0,11 m | 0,00 m |
| GF-09d dodge_safety_19 | 17 quadros | 19 |
| GF-10a kick_cut1 | 0,315 m | 0,087 m |
| GF-10b shake_cut1 | 0,076 m (ok) | 0,076 m |
| GF-10c flash_cut1 | 9 quadros (0,15 s) | 4 quadros (0,07 s; faixa 2 a 4) |
| D-44a dodge_frame_0 | f0 (ok) | f0 |
| D-44b cast_no_safety | 26 quadros protegidos | nenhum |
| D-44c cast_attack_lock | 1 quadro depois | 8 quadros depois |
| ALL no_lost_press | 28 linhas LOST | 0 |

Duas metas passam no limite da folga escrita no `PROBE.md`: GF-07b (f49, alvo 48 com 1 de folga) e GF-10c (4 quadros,
0,07 s, alvo 0,05 s com faixa 2 a 4).

## 2. Latência de ponta a ponta na placa (GF-13)

**O que foi medido**: do envio do aperto ao Windows (`SendInput`, tecla por código de varredura ou clique esquerdo) até o
primeiro quadro composto pelo Windows (DWM) em que a região em volta do herói muda, lido da área de trabalho por GDI
(`BitBlt`, o que a tela recebe). Relógio único: `QueryPerformanceCounter` no mesmo processo. Ferramenta própria, fora do
jogo: `after/latencia/latency.cs` (compilada com o `csc` do .NET Framework do Windows; nada no repositório).

**Como**: o jogo na placa (`MIRROR=... tools/gpu.sh run --rendering-driver vulkan [--disable-vsync] --resolution 1920x1080
-- --nosave --start=fountain --seed=5`; o jogo volta a janela ao tamanho salvo, 1280 x 720), sala da fonte vazia, herói
parado. Região de 400 x 300 px em volta dele. Para cada tentativa: 0,7 s medindo o ruído parado (fogo, velas, respiração)
como mudança em 60 ms; limiar = 1,3 vez esse ruído + 40 pixels (pixel "mudou" se os três canais somam mais de 60); aperto;
leitura da região a cada 7 ms até passar do limiar; depois o herói volta para o lugar. 20 tentativas por ação; cada
tentativa só se o jogo estava em primeiro plano. A sequência de leituras de duas tentativas foi impressa para conferir que
a detecção é um salto (por exemplo, andar: 56, 120, 155, 193 e então 1330 pixels aos 34 ms), não ruído acumulado.

| Ação (entrada) | vsync ligado (padrão), mediana (mín. a máx.) | vsync desligado |
|---|---|---|
| Andar (D) | **34,8 ms** (34,3 a 35,4), 20 de 20 | **13,8 ms** (6,7 a 14,8), 20 |
| Esquiva (Espaço) | **41,7 ms** (21,5 a 42,2), 18 (1 pulada sem foco, 1 sem detecção) | **14,0 ms** (12,9 a 21,2), 20 |
| Golpe (clique esquerdo) | **34,7 ms** (33,7 a 41,9), 20 | **13,8 ms** (7,9 a 15,6), 20 |

Leitura: o vsync ligado acrescenta cerca de **21 ms** (3 quadros a 144 Hz) a todas as ações. Com vsync, a esquiva aparece
um quadro composto (7 ms) depois do andar e do golpe, embora a sonda diga que ela sai no quadro do aperto (f0): a
primeira mudança visível dela vem um quadro do jogo depois (sem vsync o quadro do jogo é curto e a diferença some).

**Não medido** (pede câmera rápida apontada para a tela, que não há): o tempo do teclado e do mouse até o Windows (sondagem
USB, 1 a 8 ms), a varredura do monitor e a resposta do pixel (até 7 ms a 144 Hz, mais alguns ms). Somar isso para ter "do
dedo ao fóton". Outros limites: a leitura por GDI anda presa ao ritmo do DWM (7 ms), então cada número tem resolução de um
quadro composto; o aperto sai logo depois de uma leitura, ou seja, logo depois de um quadro composto, então a fase é fixa
(com fase aleatória, como a de gente, o número médio varia até 7 ms para baixo); janela 1280 x 720 em modo janela (com
DWM; tela cheia exclusiva não medida); controle não medido; notebook na bateria (não sei se já estava durante estas
tentativas, 16:55 a 17:08; a dispersão pequena sem vsync sugere que o jogo não estava preso a 60 quadros). Brutos em
`after/latencia/vsync_on_*.txt` e `vsync_off_*.txt`.

## 3. Aceite do C12d, item a item

| Item | Comando | Resultado |
|---|---|---|
| Sonda 31/31, saída 0 | acima | **passa** (31/31, saída 0, 0 LOST) |
| Testes | `tools/test.sh` | **532 de 532 passando**, 0 falhando, 0 arriscados (o `test_only_finishers_glint` passa), 54 arquivos, 104085 asserções, 117,1 s |
| `check.gd` e importação | `--import`; `-s tools/check.gd` | `CHECK ok`; 0 `SCRIPT ERROR`, 0 `Parse Error` |
| Fluxo do título | `-s tools/title_flow_check.gd` | **`FLOW ok`** (inclui a opção nova de vibração: liga, desliga, foco fica) |
| 8 descidas, reação 0,25 | `--bot --nosave --smoke=420 --bot-reaction=0.25 --seed=N` | **4 vitórias de 8**, preso 0 (`stuck` 0, `bot.stuck` 0, `stuck_by` vazio), `boons_at_boss` 2 a 3; tabela abaixo |
| Chefe com 25 dons | `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` | **venceu** (88,9 s, vida 20, fases em 26,1, 55,4, 68,7 s), 0 erro |
| Partida inteira | `tools/smoke.sh 300 --seed=5` | **venceu** (Morvath, sala 7, aos 122,9 s; 282,5 s no total; vida 45) |
| Estresse | `tools/smoke.sh 120 --stress=300 --seed=5` | 0 erro; 300 de pé; sozinho: `step_ms_avg` **2,02 e 2,03** (base `6f9bbc7`: 3,15 e 3,00), pico 19,5 e 16,7 (base 19,4 e 16,6); 314 abates (base 258) |
| Quadro a 1080 por arena | `RES=1920x1080 tools/gpu.sh shot ... --arena=<a> --variant=n --seed=5 --bot --autopick --bot-reaction=0.25 --shot-at=5 --shot-on=hit --shot-after=0.05` | as cinco salas desenham como no `cycle12c/AFTER.md` (mesmo cenário, luz e HUD); muda só o corte (fio marfim, não a folha verde) e o aviso; `after/arena_*_combate.jpg`. **Tempo de quadro: não medido de forma válida** (bateria, abaixo) |
| Nenhum número de dano, vida ou aviso mudou | `git diff fffd677 -- tools/make_data.gd data/` | só `_combos` (som de disparo em `cut3`, `bolt`, `burst`, `lance`; `bolt`: `recovery` 0,6 para 18/60, `cooldown` 0,7, `root_time` 0,71) e `_feel` (`dodge_iframes` 16/60 para 18/60, `slash_sweep_time` 0,1 para 0,05); `data/` igual (`feel.tres` perdeu a linha `dodge_iframes` porque 0,3 virou o padrão do `Feel`), `data/text_pt.tres`. Nenhum `damage`, `hp`, inimigo, chefe, onda ou aviso: **passa** |
| Vitória de Morvath | sonda própria (cena real, `--bot --start=boss --boss-hp=0.15 --hero-hp=200 --seed=5`) | `victory_started` aos 22,96 s; `victory_finished` e tela de fim 4,1 s depois, `Engine.time_scale` 1,000 na tela, `mode` ENDING; "Continuar" leva ao título com `time_scale` 1,000. No vídeo (f4) a selagem e as falas aparecem aos 17 a 20 s |
| Menus e câmera lenta | sonda própria (cena real, `--start=fountain`) | câmera lenta ligada (`time_scale` 0,200); Esc abre a pausa (`mode` PAUSE) e `time_scale` volta a **1,000** no mesmo quadro; ao continuar fica 1,000; câmera lenta com hit stop (0,060) e sair da partida no meio: **1,000**. Passa |

### Descidas (reação 0,25, 60 quadros por segundo sem tela, 4 de cada vez)

| Semente | Resultado | Morvath aos | `hp_at_boss` | `boons_at_boss` |
|---|---|---|---|---|
| 5 | venceu (233,2 s) | 110,2 s | 46 | 2 |
| 7 | venceu (242,5 s) | 108,0 s | 51 | 2 |
| 13 | venceu (285,0 s, vida 8) | 134,3 s | 30 | 2 |
| 21 | perdeu na fase 3 | 135,4 s | 5 | 2 |
| 3 | perdeu na fase 2 | 116,3 s | 12 | 3 |
| 9 | perdeu na sala 5 (Jardim, guardião) | | | |
| 11 | perdeu na fase 2 | 132,2 s | 9 | 2 |
| 17 | venceu (254,2 s) | 120,1 s | 55,2 | 3 |

4 de 8 (o commit `4c560eb` diz 4 de 8; no C12c, com as sementes 1 a 8, 5 de 8). `max_alive` 7; `step_ms_avg` 0,19 a 0,26.

## 4. Desempenho na placa (não medido de forma válida)

Rodei a mesma sonda do C12c (`C:/Users/danie/tools/qa/gpuperf9.gd`, base `6f9bbc7` e `1d06613` alternados, 1920 x 1080,
`--fixed-fps 60 --disable-vsync`). A partir da 2ª cena **o quadro ficou preso em 16,67 ms** (60 quadros por segundo) nas
duas versões, e o tempo da placa subiu rodada a rodada (base: Cripta A 4,82, Cripta B 4,92, Fendas 6,99, Jardim 7,99 ms;
`1d06613`: Cripta A 5,88, Cripta B 5,68, Fendas 7,07; no C12c, na tomada, 3,5 a 5,9). O notebook estava na **bateria**
(`PowerOnline False`): limite de quadros e relógio da placa de economia. Parei a rodada: os números não comparam. O
"sem piora acima de 0,3 ms" fica **por medir na tomada** (mesmo comando, `docs/gallery/cycle12c/AFTER.md`). Chamadas de
desenho iguais (Cripta A 700 e 725, Cripta B 673 e 669, Fendas 856 e 837). A simulação sem tela, que não depende da
placa, melhorou (estresse acima).

## 5. Vídeos (`after/`)

Mesmos comandos e cortes de `docs/gallery/game_feel/VIDEOS.md` (Movie Maker a 1920 x 1080, 30 quadros por segundo, com som;
os `0_25x` sem som, gravados a 120 e tocados a 30), só no `1d06613`. Brutos (AVI) apagados.

| Vídeo | O que observar contra o antes (`docs/gallery/game_feel/`, `beb6c27`) |
|---|---|
| `comparacao_combo_finalizador_0_25x.mp4` | **lado a lado, antes à esquerda, depois à direita, mesmo quadro do jogo** (o contador no canto é o quadro a 120 por segundo). Dos 4 aos 6 s: antes, a folha verde opaca aparece a 2 m da lâmina e fica vários quadros; depois, um fio marfim fino sai na ponta da Emeth no quadro do golpe e some em 3 quadros. A conferir quadro a quadro: nos acertos, antes a tela parava (hit stop congelado); depois o mundo anda um instante e desacelera (a sonda mede 0 quadros parados) |
| `comparacao_acertos_reacao_0_25x.mp4` | igual, sobre os acertos de perto. Visto nos quadros (6 a 8 s): os avisos vermelhos sob o grupo, no depois, são contorno com preenchimento leve onde antes eram uma massa vermelha cheia. A conferir no vídeo (não medi pixel a pixel): pisca do inimigo mais curto (a sonda mede 0,07 s, antes 0,15), tranco de câmera menor no golpe comum (0,087 m, antes 0,315), lascas alongadas, câmera lenta do último abate andando |
| `a_movimento_esquiva.mp4` | virada instantânea (direção no quadro do aperto), esquiva parada e em movimento, corrida segurando |
| `b_combo_finalizador.mp4` | o combo inteiro; a conferir de ouvido: som de lâmina no disparo de cada golpe e do giro (GF-11; o QA não ouviu); o brilho do finalizador fora do corpo; avisos que só se enchem no fim do preparo. Visto: o grupo de 8 cai até uns 8 s (antes ainda lutava aos 11 s) |
| `c_acertos_reacao.mp4` | pisca e empurrão de cada golpe, o tranco menor, "Atordoado" do esqueleto de elite (visto aos 7 s) |
| `d_especial_circulo_omegas.mp4` | a conferir: a seta mais rápida (dardo a 62,5 m/s na sonda) e as pernas presas 0,71 s, o círculo com aro fino (visto aos 5 e 6 s), a lança do Ômega acertando quando a carga enche (f48 na sonda) |
| `e_grupo_misto.mp4` | o robô contra 8 de seis papéis; avisos sobrepostos sem somar |
| `f1_morvath_despertar.mp4`, `f2_morvath_ritual.mp4`, `f3_morvath_maldicao_e_fase4.mp4` | Morvath por fase com o robô (mesma luta, outro ritmo; o ritual com escudo e losangos aparece aos 3 s em f2) |
| `f4_morvath_ultimo_suspiro.mp4` | **22 s (antes 15)**: o robô agora derruba Morvath aos 17 s (antes 12), então o corte foi até o fim do bruto para mostrar a selagem e as falas da vitória |
| `g_combo_finalizador_0_25x.mp4`, `g_acertos_reacao_0_25x.mp4` | os lentos sozinhos (a mesma tomada das comparações) |

As comparações: `ffmpeg` com os dois `g_*_0_25x` (antes e depois) reduzidos a 960 x 540 cada, faixa de rótulo em cima
(Alegreya Sans Bold do projeto), `hstack`, 25 s, `libx264 -crf 26`.

## 6. Capturas (`after/`)

| Arquivo | Comando | O que se vê |
|---|---|---|
| `arena_crypt_0_combate.jpg`, `arena_crypt_1_combate.jpg`, `arena_rift_0_combate.jpg`, `arena_garden_0_combate.jpg`, `arena_hall_0_combate.jpg` | `RES=1920x1080 MIRROR=... tools/gpu.sh shot <saída> --arena=<a> --variant=<n> --seed=5 --bot --autopick --bot-reaction=0.25 --shot-at=5 --shot-on=hit --shot-after=0.05` (PNG da Godot, JPG `-q:v 3`) | o golpe que acerta perto dos 5 a 6 s em cada sala. Comparado com `cycle12c/after/crypt_vA_c_combate.jpg`: cenário, luz, chão e HUD iguais; o corte é o fio marfim (antes a folha verde opaca); os avisos vermelhos só cheios no fim. Momento diferente do antes (o combate mudou de ritmo) |

## 7. Limitações

- Bateria: o tempo de quadro na placa não pôde ser comparado; a latência foi medida no mesmo dia, sem confirmar a energia
  durante as tentativas.
- Latência sem câmera rápida: medida até o quadro composto do Windows, não até o pixel do monitor.
- Robô e roteiro não são gente: a sonda e os vídeos mostram que os apertos não somem; se a mão "sente" o jogo só o teste
  do Daniel diz. Som só gravado (ninguém ouviu); vibração do controle não testada (sem controle).
- As 8 descidas rodaram 4 de cada vez (os passos delas não valem como desempenho; o estresse foi rodado sozinho).
