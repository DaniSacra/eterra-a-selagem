# Relatório de QA e desempenho: E1b (atordoamento, som do combate, pés travados)

- **Data**: 2026-11-16.
- **Testado**: `arpg-3d` no `18b0785` (E1b inteira commitada; árvore limpa). **Base de comparação**: `ec5d757` (HEAD da
  E1a), copiado por `git archive` para o scratchpad (robô sem tela) e espelhado em `C:/Users/danie/tools/eterra-gpu-head`
  (GPU). Atenção: entre os dois também entrou a fundação da E2a (`d9943c9`); o que muda abaixo não é só da E1b.
- **Ambiente**: WSL2 (Godot 4.7.2 Linux, sem tela) para importação, testes, sonda e robô. GPU real pela Godot 4.7.2 de
  Windows (Vulkan 1.4.357, Forward+, RTX 5060 Laptop) no espelho `C:/Users/danie/tools/eterra-gpu-e1b-qa`; Compatibility
  pelo OpenGL 3.3 da mesma placa. **Na tomada** durante as medidas (`PowerLineStatus Online`, carga 99%, lido antes e
  depois; `docs/gallery/e1b/qa/logs/power.txt`). O som foi **medido** no arquivo do Movie Maker (ffmpeg), **não ouvido**:
  o QA não tem ouvidos. Sem controle, sem celular, nenhum teste com gente.
- O QA não mudou código, arte nem testes. Evidências em `docs/gallery/e1b/qa/` (logs em `logs/`).

## Veredito

**Pronto para o Daniel testar.** Nada quebra a partida: 617/617 testes, sonda 34/34, `check.gd` limpo, 0 `SCRIPT ERROR`,
o robô chega em Morvath e vence (`--seed=5`), 0 preso em 11 partidas, sem clipping no som, custo de GPU igual ao da E1a.
Três coisas para ele saber (nenhuma bloqueia):
1. **Com reação humana o robô perde um pouco mais**: 5 de 8 vitórias (base 6 de 8), chega em Morvath com menos vida (média
   24,9 contra 36,4) e leva mais dano antes dele (91 contra 49 somados nas 8). Amostra pequena e as partidas divergem
   (o atordoamento muda tudo depois do primeiro golpe); é o ponto que o teste do Daniel deve confirmar ou não.
2. **A fonte nunca foi usada pelo robô** nas 11 partidas (`fountain_used: false` em todas): ele só bebe abaixo de 60% da
   vida (`Bot.DRINK_BELOW`) e nunca chegou na sala 4 tão ferido. A regra tem teste (`test_bot_kite.gd`), mas não foi vista
   acontecer numa partida.
3. **Silêncio total entre as salas**: 9 s de 60 no vídeo são silêncio digital (`-inf`), sempre na caminhada até a porta e
   na troca de sala (música desligada, sem ambiente). Não é defeito da E1b, mas vai se notar agora que o combate tem som.

## 1. Checagem e testes

| Comando | Resultado | Evidência |
|---|---|---|
| `godot --headless --path . --import` | 0 `SCRIPT ERROR`, 0 `Parse Error` | (log no scratchpad) |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok` | `logs/check.log` |
| `tools/test.sh` | **64 scripts, 617 testes, 617 passando, 0 falhando, 0 arriscados**, 105 624 asserções, 140,8 s (E1a: 557) | `logs/test_summary.log` |
| `godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain` | **`FEEL_SUMMARY 34/34 ok`**, 0 `LOST` | `logs/feel_probe.log` |

Exportação de Windows e Web: não pedida, não feita.

## 2. Robô (sem tela, `--fixed-fps 60`), E1b contra a base `ec5d757`

| Comando | Base `ec5d757` | E1b `18b0785` |
|---|---|---|
| `tools/smoke.sh 300 --seed=5` | vence, 282,5 s, Morvath (sala 7) aos 122,9 s, hp 45 | **vence, 242,1 s, Morvath (sala 7) aos 118,9 s**, hp 55, 51 abates, `flinches` 66, `interrupts` 18, avg 0,18 |
| `tools/smoke.sh 120 --start=boss --boons=25 --seed=5` | vence em 88,9 s, hp 20 | **vence em 88,5 s**, hp 30, avg 0,17 |
| `tools/smoke.sh 120 --stress=150 --seed=5` | avg **1,12**, 160 abates, dano 19 692 | avg **0,79**, 176 abates, dano 21 973, `flinches` 389 |

`flinches` e `interrupts` são campos novos (não existem na base). Os números de jogo mudaram com a mesma semente: era o
esperado (atordoamento e avanço do golpe mudam a luta).

### 2.1 Oito descidas com reação humana (`tools/smoke.sh 300 --seed=N --bot-reaction=0.25`)

| Semente | E1b: resultado, tempo, hp final | hp ao chegar em Morvath | dano antes de Morvath | dons no chefe | flinches / interrupts | dano em Morvath por | Base: resultado, hp em Morvath, dano antes |
|---|---|---|---|---|---|---|---|
| 1 | vence, 273,8 s, 26 | 30 | 0 | 3 | 54 / 24 | invocados 4 | vence, 30, 0 |
| 2 | **perde** (fase 4), 233,8 s | 30 | 0 | 2 | 66 / 26 | tempestade 30 | vence, 30, 0 |
| 3 | **perde** (fase 4), 210,0 s | 12 | 18 | 3 | 82 / 30 | invocados 4, maldição 6, tempestade 2 | perde (fase 2), 12, 18 |
| 4 | vence, 239,7 s, 24 | 28 | 27 | 2 | 70 / 24 | invocados 4 | vence, 52, 3 |
| 5 | vence, 238,7 s, **1** | 23 | 32 | 2 | 57 / 14 | maldição 12, tempestade 10 | vence, 46, 9 |
| 6 | vence, 244,5 s, 3 | 27 | 3 | 2 | 61 / 24 | invocados 8, maldição 6, tempestade 10 | vence, 55, 0 |
| 7 | **perde** (fase 3), 217,9 s | 19 | 11 | 2 | 62 / 20 | maldição 9, ritual 10 | vence, 51, 4 |
| 8 | vence, 180,5 s, 16 | 30 | 0 | 3 | 58 / 14 | invocados 4, tempestade 10 | perde (fase 3), 15, 15 |
| **Total** | **5 de 8** | média **24,9** | **91** | | 54 a 82 / 14 a 30 | | **6 de 8**, média 36,4, **49** |

- `stuck` 0 e `bot.stuck` 0 em todas (E1b e base); `max_alive` 7 em todas; `fountain_used` falso em todas (as duas versões).
- Mesma semente, mesmo resultado: `--seed=1` rodado de novo com `--trace-steps` deu o mesmo `RESULT` (273,8 s, hp 26, 44
  abates, dano 12 528; `logs/trace1.log`).
- Todos os `RESULT`: `logs/results_e1b.jsonl` e `logs/results_base_ec5d757.jsonl`.

## 3. Desempenho

| Medida | Base `ec5d757` | E1b |
|---|---|---|
| `step_ms_avg` nas 8 descidas (4 processos ao mesmo tempo) | 0,19 a 0,22 | 0,21 a 0,23 |
| `step_ms_peak` nas 8 descidas (4 ao mesmo tempo, ruidoso) | 5,1 a 9,1 | 7,5 a 12,1 |
| `--seed=1` sozinho, `--trace-steps` | | avg 0,17, pico **7,55** (só 3 passos acima de 4 ms: `horde` 7,48 e 4,43, `skills` 5,03) |
| `step_ms_avg` estresse 150 | 1,12 | **0,79** |
| **Quadro na GPU, 150 inimigos, 1920x1080 sem vsync, `gpuperf9`, intercalado (E, B, E, B, E, B)** | frame 8,40 / 8,52 / 8,55 (**8,49**); gpu 8,27 / 8,38 / 8,48 (**8,38**); cpu_render 1,10 / 1,00 / 1,08; 994 a 995 chamadas | frame 8,50 / 8,32 / 8,58 (**8,47**); gpu 8,39 / 8,27 / 8,44 (**8,37**); cpu_render 0,91 / 0,96 / 1,12; **985 chamadas** |

Leitura: **sem diferença de GPU** (-0,01 ms, dentro do ruído), 10 chamadas a menos (velas apagadas). Os valores absolutos
não se comparam com a tabela da E1a (7,3 ms): nesta sessão a sonda relata o render a 2880x1620 (`render (2880.0, 1620.0)`
no `logs/gpu_perf_interleaved.log`), mais pixels que antes; por isso a base foi rodada de novo, intercalada. Os picos de
`step_ms` com 4 processos em paralelo não valem como medida; o pico isolado (7,55 ms, um passo da multidão) fica abaixo de
um quadro de 60 Hz. Não medido: placa fraca, celular, Compatibility em tempo de quadro.

## 4. Som (Movie Maker, 60 s, `--bot --seed=5`, 1920x1080, 48 kHz estéreo)

Comando: `MIRROR=/mnt/c/Users/danie/tools/eterra-gpu-e1b-qa RES=1920x1080 FPS=30 tools/movie.sh C:/Users/danie/tools/e1b_out/qa_movie.avi 1800 --bot --seed=5`;
medido com `ffmpeg -af astats,ebur128=peak=true` e `silencedetect=n=-50dB:d=0.7` (`logs/audio_stats.log`, `logs/silence.txt`,
`logs/audio_peak_per_second.txt`). Vídeo: `docs/gallery/e1b/qa/partida_60s_som_1080.mp4` (10,4 MB, H.264 + AAC).

| Medida | Valor | Leitura |
|---|---|---|
| Pico de amostra | **-2,94 dBFS** (maior amostra 23 365 de 32 767) | **sem clipping**; abaixo do teto do limitador (-1 dB) |
| Pico verdadeiro (ebur128) | -2,9 dBFS | sem estouro entre amostras |
| Sonoridade integrada | -20,0 LUFS, faixa 5,0 LU | normal para jogo de ação; sem música |
| RMS | -23,0 dB | |
| Silêncio digital | 0 a 2,2 s (carregando), **18,2 a 23,1 s** e **40,5 a 44,6 s** | os dois do meio são as trocas de sala (quadros 540 a 660 e 1230 a 1335: "Sala vencida", caminhada até a porta, nome da arena); nenhum silêncio no meio de luta |
| Pico por segundo | -2,9 dBFS em 16 dos 60 segundos, sempre o mesmo valor | o mais alto é sempre o mesmo som na mesma altura (provavelmente a mesma amostra de golpe, sem variar volume). **Não medi** quais sons repetem: o Movie Maker grava só a mistura e o jogo não registra os `Audio.play`. Se o Daniel achar repetitivo, pedir registro por som ao dono do áudio |

## 5. Capturas na GPU (abertas e olhadas)

- `docs/gallery/e1b/qa/fight_forward_1080.jpg`: `RES=1920x1080 tools/gpu.sh shot ... --bot --autopick --seed=5 --shot-at=9`
  (Forward+). Salão com metade das velas da borda, Guerreiro em luta com o Escudo, onda verde do especial à direita dele,
  número 43, contador "8 Golpes / Seta de Luz". Herói e inimigos legíveis.
- `docs/gallery/e1b/qa/fight_compat_1080.jpg`: o mesmo quadro no **Compatibility** (`--rendering-driver opengl3`,
  `OpenGL API 3.3.0 NVIDIA 621.01`). Sem erro; mesma cena, chão mais contrastado e portal menos aceso, como antes.
- `docs/gallery/e1b/qa/boss_forward_1080.jpg`: `--start=boss --boons=5 --seed=5 --shot-at=20`. Morvath no meio da foice,
  aviso em meio círculo vermelho com o fio violeta, herói dentro do arco do próprio golpe de fogo, barra com as marcas de
  fase. Morvath aparece acima do chão nesse quadro (corpo inclinado sobre o aviso); não sei dizer de um quadro só se é o
  clipe novo da foice de cima ou se ele flutua. Fica para o `art-director` olhar no vídeo `morvath/scythe_after.mp4`.
- Quadros do vídeo nas trocas de sala: `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/ef535818-db08-4d33-9659-643b5faf66d3/scratchpad/silence_frames.jpg` (não versionado).

## 6. Falhas e regressões, por gravidade

Nenhuma crítica nem alta.

| Gravidade | Item | Como reproduzir | Responsável sugerido |
|---|---|---|---|
| Média (observar no teste) | Robô com reação humana chega em Morvath mais ferido e vence 5 de 8 (base 6 de 8); dano antes de Morvath 91 contra 49 | seção 2.1, `tools/smoke.sh 300 --seed=5 --bot-reaction=0.25` (hp 1 no fim, 32 de dano antes do chefe) | `gameplay-engineer` (avanço do golpe a 0,3 do alcance deixa o herói mais perto; conferir com o teste do Daniel antes de mexer) |
| Baixa | A fonte não é usada pelo robô em nenhuma partida medida | `fountain_used` em `logs/results_e1b.jsonl` | `gameplay-engineer` (se a métrica importa, um `--hero-hp` que só baixe a vida atual, ou limiar maior) |
| Baixa | Silêncio digital entre salas (cerca de 4 a 5 s por troca) | `logs/silence.txt` | dono do áudio (ambiente de sala) |
| Baixa | O nome do golpe no contador ainda diz "Seta de Luz" com o especial desenhado como onda | `fight_forward_1080.jpg` | `ui-ux-designer` / Game Director (texto) |
| Baixa | Morvath parece acima do chão num quadro da foice | `boss_forward_1080.jpg` | `art-director` |

## 7. Avaliação pelas perguntas da diretriz (`docs/design/po_directive_guardian.md`)

Sem teste humano não há como dizer se é divertido; abaixo só o que as medidas e imagens mostram.

- **Comandos respondem na hora?** A sonda passa 34/34 (inclui toques em hit stop pelo teclado e pelo controle virtual,
  0 `LOST`). Medido pela máquina, não pela mão.
- **Ataques têm impacto?** Agora cada golpe tem som (pico chega a -2,9 dBFS em 16 de 60 s sem estourar) e os comuns param
  no golpe: 54 a 82 atordoamentos e 14 a 30 preparos cortados por descida. Se isso "pesa" na mão é pergunta para o Daniel.
- **Dá para encadear?** O contador mostra 8 a 11 golpes seguidos nas capturas (`best_combo` 8 a 11 nos `RESULT`).
- **Alguma pausa atrapalha?** No som, a pausa perceptível é o silêncio de troca de sala (seção 4). Nada travou.
- **Visual: legível?** Sim nas três capturas (herói, Escudo, esqueleto, Morvath e avisos distinguíveis a 1080, nos dois
  renderizadores). A onda do especial é pequena a 1080 (mesma ressalva do `docs/gallery/e1b/ART_REVIEW.md`).
- **Parece jogo comercial acabado?** Não cabe ao QA; o critério é do `art-director` e do Daniel.

## 8. Limitações

- WSL sem Vulkan da placa: tudo que é tela foi pela Godot de Windows; o robô e os testes rodam sem tela no WSL.
- Robô em 4 processos simultâneos: `step_ms_peak` desses runs é ruidoso (o isolado está na seção 3).
- O som foi medido, não ouvido; o Movie Maker grava a mistura final, sem saber qual som tocou.
- Base inclui diferença da fundação E2a; não separei E1b de E2a.
- Exportação, celular, placa fraca e controle físico: não testados.
