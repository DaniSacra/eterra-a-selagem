# Relatório de QA e desempenho: C12d "Game feel I: a mão" (QA final)

- **Data**: 2026-11-16.
- **Branch**: `arpg-3d`, **commit testado `1d06613`** (C12d integrado: `aaaacfc`, `4c560eb`, `491c6d4`, `1d06613`). Antes: sonda
  no `1e25f21` (`docs/gallery/c12d/PROBE.md`), vídeos no `beb6c27` (`docs/gallery/game_feel/`), base de desempenho `6f9bbc7`.
  Árvore limpa no começo. O QA não mudou código de jogo, arte nem testes; acrescentou `docs/gallery/c12d/after/`,
  `docs/gallery/c12d/AFTER.md` (tabelas, vídeos, como foi medido) e este relatório.
- **Ambiente**: WSL2 (Linux 6.18) para importação, testes, sonda e robô (Godot 4.7.2 Linux, sem tela). Vídeos, capturas e
  latência na **placa real** pela Godot 4.7.2 de Windows (Vulkan 1.4.357, Forward+, RTX 5060 Laptop), espelho
  `C:/Users/danie/tools/eterra-gpu-qa`, monitor a 144 Hz. **Notebook na bateria** durante a sessão (ver seção 4). Som só
  gravado, ninguém ouviu; sem controle; nenhum teste com gente.

## Veredito

**Pronto para o Daniel testar.** O aceite de game feel do C12d passa inteiro: sonda **31/31** (antes 4/31), nenhum aperto
perdido, **532/532** testes, `check` e fluxo do título ok, robô sem ninguém preso, chefe e partida inteira vencidos,
estresse sem erro, nenhum número de dano, vida ou aviso mudado, vitória de Morvath e câmera lenta voltando a 1 nos menus.
Nenhuma falha crítica, alta ou regressão encontrada. **Uma pendência de medição**: o tempo de quadro na placa (sem piora
acima de 0,3 ms) não pôde ser comparado porque o notebook estava na bateria (quadro preso em 60 por segundo); repetir na
tomada antes de fechar o C12d como "sem custo". A latência de ponta a ponta (GF-13) foi medida até o quadro do Windows,
não até o pixel (sem câmera rápida).

## 1. Checagem e testes

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | **0 SCRIPT ERROR, 0 Parse Error** |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok`, saída 0 |
| `tools/test.sh` | **54 arquivos, 532 testes, 532 passando, 0 falhando, 0 arriscados** (o `test_only_finishers_glint` passa), 104085 asserções, 117,1 s |
| `godot --headless --path . -s tools/title_flow_check.gd` | **`FLOW ok`** (inclui a opção nova de vibração) |
| `godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain` | **`FEEL_SUMMARY 31/31 ok`, saída 0, 0 linhas LOST** (`docs/gallery/c12d/after/feel_probe.txt`) |
| `git diff fffd677 -- tools/make_data.gd data/` | só `_combos` (sons de disparo; seta `recovery` 18/60, `cooldown` 0,7, `root_time` 0,71) e `_feel` (`dodge_iframes` 18/60, `slash_sweep_time` 0,05); `data/` igual a isso mais `text_pt.tres`. **Nenhum dano, vida, inimigo, chefe, onda ou aviso** |

Exportação de Windows e Web: não pedida, não feita.

## 2. Aceite do C12d, item a item

| Item | Medida | Resultado |
|---|---|---|
| Sonda com metas (GF-14) e GF-01 a GF-10 | 31/31; as 27 que falhavam passam (tabela antes e depois no `AFTER.md`); GF-07b (f49) e GF-10c (4 quadros) no limite da folga | **passa** |
| Testes, `check`, título | seção 1 | **passa** |
| 8 descidas, reação 0,25 (`--smoke=420`, sementes 5, 7, 13, 21, 3, 9, 11, 17) | **4 vitórias** (5, 7, 13, 17); derrotas na fase 3 (21), fase 2 (3, 11), sala 5 guardião (9); `stuck` 0 e `bot.stuck` 0 nas 8; `boons_at_boss` 2 a 3; `hp_at_boss` 5 a 55 | **passa** (preso 0; mesmo resultado que o commit diz) |
| Chefe, 25 dons | venceu em 88,9 s | **passa** |
| Partida inteira `tools/smoke.sh 300 --seed=5` | chega em Morvath (sala 7) aos 122,9 s e **vence** | **passa** |
| Estresse `--stress=300` | 0 erro, 300 de pé; sozinho, `step_ms_avg` 2,02 e 2,03 (base `6f9bbc7` 3,15 e 3,00) | **passa** |
| Quadro a 1080 por arena | cinco capturas na placa (`after/arena_*_combate.jpg`): cenário, luz e HUD iguais ao `cycle12c/AFTER.md`, corte e avisos novos | **passa no visual**; tempo de quadro **não medido** (seção 4) |
| Números de combate | seção 1 | **passa** |
| Vitória de Morvath | cena real com o robô: tela de fim 4,1 s depois da queda, `time_scale` 1,0; "Continuar" ao título com 1,0; no vídeo f4 a selagem aos 17 a 20 s | **passa** |
| Menus e câmera lenta | cena real: câmera lenta 0,2, Esc abre a pausa e `Engine.time_scale` volta a 1,0 no mesmo quadro; continuar 1,0; sair da partida no meio de câmera lenta com hit stop: 1,0 | **passa** |
| Vídeos depois e comparação | seção 5 | feito |
| GF-13 latência | seção 3 | medido em parte (até o quadro do Windows) |

## 3. Latência de ponta a ponta (GF-13)

Do `SendInput` (tecla ou clique) ao primeiro quadro composto pelo Windows em que a região do herói muda, lido por GDI,
mesmo relógio (`QueryPerformanceCounter`); 20 tentativas por ação, janela 1280 x 720, sala da fonte, monitor 144 Hz.
Método, limiar e brutos: `docs/gallery/c12d/AFTER.md` seção 2 e `after/latencia/`.

| Ação | vsync ligado (padrão) | vsync desligado |
|---|---|---|
| Andar | 34,8 ms (34,3 a 35,4) | 13,8 ms (6,7 a 14,8) |
| Esquiva | 41,7 ms (21,5 a 42,2) | 14,0 ms (12,9 a 21,2) |
| Golpe | 34,7 ms (33,7 a 41,9) | 13,8 ms (7,9 a 15,6) |

O vsync ligado custa cerca de 21 ms (3 quadros a 144 Hz). **Não medido**: USB do teclado e mouse, varredura e resposta do
monitor (pedem câmera rápida); tela cheia exclusiva; controle. Resolução de um quadro composto (7 ms), fase do aperto fixa
logo depois de um quadro.

## 4. Desempenho

- Simulação sem tela, estresse de 300 sozinho: `1d06613` 2,02 e 2,03 ms por passo contra 3,15 e 3,00 na base `6f9bbc7`.
- **Placa: não medido de forma válida.** A sonda `gpuperf9.gd` (1080, base e depois alternados) passou a dar quadro de
  16,67 ms nas duas versões a partir da 2ª cena e o tempo da placa subiu rodada a rodada (base 4,82 a 7,99, depois 5,68 a
  7,07); o Windows dizia `PowerOnline False` (bateria, 99% e 96%). Parei. Chamadas de desenho iguais (700 e 725, 673 e
  669, 856 e 837). Repetir na tomada com o comando do `cycle12c/AFTER.md`.
- FPS da linha `RESULT` no `gpu.sh shot --stress=300`: não rodado pelo mesmo motivo.
- Celular e placa fraca: não medidos (sem aparelho).

## 5. Vídeos e capturas

Em `docs/gallery/c12d/after/`, com os mesmos comandos e cortes de `docs/gallery/game_feel/VIDEOS.md` (1920 x 1080, câmera
do jogo, com som; os lentos sem som): `a_movimento_esquiva`, `b_combo_finalizador`, `c_acertos_reacao`,
`d_especial_circulo_omegas`, `e_grupo_misto`, `f1` a `f4` de Morvath (f4 com 22 s em vez de 15, para chegar à vitória, que
agora sai aos 17 s), `g_combo_finalizador_0_25x`, `g_acertos_reacao_0_25x`, e **`comparacao_combo_finalizador_0_25x.mp4`
e `comparacao_acertos_reacao_0_25x.mp4`**: antes e depois lado a lado, o mesmo quadro do jogo a 0,25x. O que observar em
cada um: `docs/gallery/c12d/AFTER.md` seção 5. Visto nos quadros: o corte deixou de ser a folha verde opaca longe da
lâmina e virou um fio marfim na ponta da Emeth que some em 3 quadros; os avisos sob o grupo viraram contorno com
preenchimento leve; o grupo de 8 do (b) cai antes.

## 6. Falhas e regressões por gravidade

Nenhuma crítica. Nenhuma alta. Nenhuma regressão encontrada.

**Média**
- **M-a. Tempo de quadro do C12d na placa sem medida válida** (não é falha do jogo; o aceite "sem piora acima de 0,3 ms"
  está aberto). Reproduzir na tomada: `MIRROR=... tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080
  --fixed-fps 60 --disable-vsync -s C:/Users/danie/tools/qa/gpuperf9.gd -- --probe-res=1920x1080 --nosave --seed=5 --bot
  --bot-reaction=0.25 --probe-settle=240 --arena=<a>`, base `6f9bbc7` e `1d06613` alternados. O C12d acrescentou um 2º
  passe nos avisos (stencil 2) e mexeu nos shaders do corte e das lascas. Responsável: `qa-performance` (remedir).

**Baixa**
- **B-a. `tests/test_slash_wire.gd.uid` fora do commit.** A importação criou o arquivo (o `.gd` está no `1d06613`, o `.uid`
  não; os outros 54 testes têm o seu). Fica como não rastreado na árvore. Responsável: Game Director (juntar no próximo
  commit).
- **B-b. Com vsync, a esquiva aparece um quadro composto (7 ms) depois do andar e do golpe** (41,7 contra 34,8 ms; sem
  vsync, 14,0 e 13,8). A sonda diz que ela sai no quadro do aperto; a primeira mudança visível vem um quadro do jogo
  depois. Reproduzir: `after/latencia/latency.cs` (`latency.exe run space 20 90 290 400 300` com o jogo na fonte).
  Responsável: `gameplay-engineer` (conferir se o deslocamento ou a pose do 1º quadro da esquiva é desenhado no quadro do
  aperto).
- **B-c. A linha `RESULT` não é JSON válido**: `boss.attacks` sai com chaves `&"scythe"` (StringName). Anterior ao C12d
  (`3b22cea`). Atrapalha ler o `RESULT` por script (o registro `runs.jsonl` não foi conferido aqui). Responsável:
  `gameplay-engineer`.
- **B-2 (aberto desde o C12c). O robô nunca usa a fonte**: `fountain_used: false` nas 8 descidas. Responsável:
  `gameplay-engineer`.
- Duas metas da sonda no limite da folga do QA: GF-07b (2ª seta em f49, alvo 48) e GF-10c (clarão de 4 quadros, 0,07 s,
  alvo 0,05). Passam pela regra escrita; anotar se o `art-director` quiser o clarão mais curto.

Abertos de antes que este QA não remediu: A-1 e B-1 (colunas e gemas; o `6f9bbc7` diz que corrigiu, sem captura minha
neste ciclo), M-1 (chão da Cripta), B-3 (limitador).

## 7. Limitações

- Notebook na bateria: tempo de quadro na placa não comparável; a latência foi medida antes de eu notar, sem confirmar a
  energia naquele momento (a dispersão pequena sem vsync sugere que não havia limite de 60).
- Latência até o quadro do Windows, não até o pixel; GDI com resolução de 7 ms; aperto injetado, não de um teclado real.
- Robô e roteiro de entrada não são gente; som gravado e não ouvido; vibração sem controle para testar.
- As 8 descidas rodaram 4 de cada vez (os passos delas não valem como desempenho).
- Brutos (AVI de cerca de 2 GB, PNG, BMP) em `C:/Users/danie/tools/qa/c12d/` apagados no fim; a cópia da base
  (`/home/dani/games/qa-c12d-base`) e o espelho dela (`C:/Users/danie/tools/eterra-gpu-head`) apagados.
