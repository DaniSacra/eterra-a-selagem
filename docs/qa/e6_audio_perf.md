# E6: mixagem, ambiência por arena e máquina fraca (C15-01, C15-04, B-3, DT-003)

- **Data**: 2026-11-17. **Base**: `arpg-3d` no `224782a`, worktree do `qa-performance` (o commit desta entrega está no
  relatório final). Responsável: `qa-performance`, com licença para mexer na mixagem, no som e nas opções de desempenho.
  O PO está fora: as decisões abaixo foram tomadas e registradas aqui, sem perguntar.
- **Ambiente**: WSL2 (Godot 4.7.2 Linux, sem tela) para importação, testes, robô e as medidas do som (fora de tempo
  real, sobre os arquivos). GPU real pela Godot 4.7.2 de Windows no espelho `C:/Users/danie/tools/eterra-gpu-e6`:
  RTX 5060 Laptop (Vulkan 1.4.357, Forward+; e OpenGL 3.3 para o Compatibility) e a **placa integrada do próprio
  notebook** (Intel RaptorLake-S Mobile Graphics, Vulkan 1.4.323, por `--gpu-index 1`, linha `Using Device #1`).
  **Nenhum som foi ouvido**: tudo o que se diz do som vem de medida (LUFS, pico real, janelas do limitador). Durante as
  medidas da GPU o WSL estava com carga alta de outros agentes (média 7 a 9 em 12 núcleos): o tempo de quadro na RTX,
  que é limitado pela CPU, sai mais alto do que numa máquina parada; o tempo da GPU (`gpu_ms`) não depende disso.

## 1. Mixagem por barramentos (C15-01) e o limitador (B-3)

### O que mudou
- Barramentos `Music`, `SFX`, `UI` e `Ambience`, todos enviando ao `Master`, onde o limitador (`AudioEffectHardLimiter`,
  -1,5 dB) é o último efeito. Tabela `Audio.BUSES`: cada barramento segue uma opção de volume do save e tem um ajuste
  próprio. `Music` +9 dB (opção `music`), `SFX` +2 dB (`sfx`), `UI` -6 dB (`sfx`; os sons de menu `Audio.UI_SOUNDS`
  saíram do `SFX`), `Ambience` 0 dB (`sfx`).
- Ajuste por som, `Audio.GAIN_DB` (só abaixa): os sons que empilhavam no limitador numa partida de verdade. Queda de
  elite -5, osso -5, escudo -5, atordoamento -5, golpe (`hit`) -4, queda de Morvath -4, rugido -4, porta -4, quebra de
  armadura -3, cura -3, aterrissagem da investida -3, subir de nível -3, foice, impacto da foice, erupção, queda do escudo
  do ritual, elite surgindo, troca de fase, ferido, material espectral e de osso -2.
- Ducking (C15-01): os avisos de Morvath (`Audio.WARN_CUES`: foice erguida 0,9 s, investida 0,9 s, erupção 1,2 s,
  maldição 1,0 s, rugido 1,2 s, invocação 0,6 s) chamam `Music.warn(s)`; a música e a ambiência descem a
  `MusicMix.WARN_DUCK` 0,5 (-6 dB) em 0,06 s, ficam enquanto dura o aviso e voltam em 0,5 s. O ducking dos Salmos (E4)
  continua; os dois se multiplicam.
- **Decisão (sem o PO)**: a música subiu 9 dB. Na E4 ela ficava a -29 dBFS RMS, 13,5 dB abaixo de um golpe; a mistura
  inteira ficava abaixo da meta (-19,5 a -20 LUFS nas descidas) enquanto os golpes empilhados já passavam do teto. Subir
  os efeitos aumentaria o trabalho do limitador; subir a música (picos baixos) e baixar os sons que empilham dá a
  sonoridade sem o limitador trabalhar. Consequência medida: o pico real da música sozinha, que era -13 dBTP, ficou em
  -3,5 dBTP; a regra do teste `test_music_sits_under_the_blows` sobre ele passou de "6 dB abaixo do teto do limitador"
  para "1,5 dB abaixo" (a outra regra do mesmo teste, a música no momento mais alto pelo menos 6 dB abaixo do golpe mais
  forte, continua: medido 6,2 dB, `music: ... loudest 0.4 s -16.7 dBFS; blows -10.5 dBFS`). Contra o golpe comum
  (`hit`, -4) a margem é menor, cerca de 2 a 3 dB no auge da fase 4; nos avisos de Morvath a música desce mais 6 dB.
  Quem decide de ouvido: `art-director` (e o Daniel no teste).

### Como foi medido
- O jogo grava o que tocou: `--sound-log=arquivo` (`Audio.log_event`): todo som que passou pelo `VoiceGate` com o tom,
  toda troca de música, nível, fase, tema e ambiência, no relógio do jogo (as partidas sem tela rodam com
  `--fixed-fps 60`).
- `tools/mix_probe.gd -- --log=arquivo` refaz a mistura (`tools/mix_replay.gd`): música e ambiência pelo `MusicMix` no
  relógio do registro (crossfades, camadas, temas, ducking), cada som com o tom e o ajuste dele, no máximo
  `Audio.VOICES` 16 de uma vez (o mais velho cortado), volumes padrão do save e os ajustes dos barramentos; mede LUFS
  integrado (BS.1770-4, `Loudness`, `scripts/core/loudness.gd`), o maior LUFS de 3 s, o pico real (4 vezes entre as
  amostras) antes e depois de um modelo do limitador, e em quantas janelas de 0,1 s o limitador tira mais de 0,5 dB e
  mais de 3 dB. `--before` refaz a mistura como era antes da E6 (sem ajustes, sem ambiência, sem ducking), `--why` lista
  os piores momentos e os sons de cada um, `--parts=` mede só uma parte, `--wav=` grava o resultado.
- Conferido com o `ebur128` do ffmpeg sobre o `--wav`: Morvath antes da E6 -17,9 (nosso) contra -18,0 LUFS (ffmpeg) e
  -1,29 contra -1,3 dBTP; descida 5 (reação 0,25) depois da E6 -17,8 contra -17,8 LUFS e -1,28 contra -1,3 dBTP.
- Partidas gravadas (robô, sem tela): `tools/smoke.sh 600 --seed=5` (descida inteira até a vitória, 392 s),
  `--seed=5 --bot-reaction=0.25` (312 s), `--seed=11 --bot-reaction=0.25` (403 s, vitória) e `180 --start=boss
  --boons=25 --seed=5 --bot-reaction=0.25` (Morvath, 95 s), todas com `--sound-log`.

### Resultado (modelo do limitador; os sons com variação sorteada mudam alguns décimos de uma rodada para outra)

| Partida | Antes da E6: LUFS / pico real antes do limitador / janelas > 0,5 dB / > 3 dB | Depois: LUFS / pico antes / depois / janelas > 0,5 dB / > 3 dB |
|---|---|---|
| Descida, semente 5, reação 0 (3920 janelas) | -19,5 / +2,5 dBTP / 21 / 2 | **-17,7** / +1,2 / **-1,33 dBTP** / **12 (0,3%)** / **0** |
| Descida, semente 5, reação 0,25 (3119) | -20,1 / +1,3 / 20 / 0 | **-17,8** / +0,9 / **-1,34** / **6 (0,2%)** / **0** |
| Descida, semente 11, reação 0,25 (4026) | -19,8 / +1,6 / 24 / 1 | **-17,9** / +0,4 / **-1,31** / **4 (0,1%)** / **0** |
| Morvath, `--boons=25`, reação 0,25 (953) | -17,9 / +0,7 / 11 / 0 | **-17,3** / +0,1 / **-1,44** / **3 a 7 (até 0,7%)** / **0** |

Partes sozinhas, depois (descida reação 0,25 / Morvath): música -19,7 / -22,1 LUFS, pico -3,3 / -3,4 dBTP; efeitos
-20,4 / -18,4 LUFS; ambiência -35,1 / -37,3 LUFS (15 LU abaixo da música, pico -17 dBTP).

Leitura: **metas do C15-01 atingidas** (integrado entre -18 e -14 LUFS em todas as partidas, pico real -1,3 a
-1,4 dBTP depois do limitador). **B-3**: o limitador passa a trabalhar em 0,1 a 0,7% das janelas e nunca tira mais de
3 dB (antes até 2 janelas fundas por descida; o "67 janelas" do QA-02 era de um vídeo do ciclo 12, com a mixagem de
antes da E4). O integrado ficou perto do limite de baixo (-17,3 a -17,9): uma partida de gente, com menos golpes,
tende a ficar mais baixa; se o Daniel achar baixo, sobe-se o volume geral, não o limitador.

## 2. Ambiência por arena (C15-04)

- Dez laços de 24 s sintetizados pelo projeto (`tools/make_ambience.gd`, determinístico, ffmpeg para o .ogg; licença em
  `audio/LICENSES.md`, créditos do jogo em `credits_synth`): salão (ar frio largo, brasas dos braseiros, gotas
  distantes), Cripta (ar parado, gotas com eco, zumbido grave da pedra), Fendas (vento fundo da fenda, ronco, brilho
  frio no alto), Jardim (rajadas secas, rangido de raízes), Santuário (ar quieto, quinta de coro distante, sopros de
  vozes), Ponte (vento aberto, correntes), Runas (zumbido das runas batendo devagar, chiado de luz), Provação (pulso
  grave sob uma quinta), Altar (velas e zumbido morno), Câmara do Selo (zumbido violeta, vento do abismo, sussurros).
  Cada um a -28 dBFS RMS no arquivo (-29 os mais cheios), pico abaixo de -8 dBFS, 275 a 310 KB (2,9 MB no todo).
- Tabela `Ambience.BY_ARENA` (`scripts/core/ambience.gd`; arena nova com um ar que já existe é uma linha), tocada por
  `Music.ambience(id)` no `Rooms._enter`, com o crossfade do `MusicMix` (entra 1,5 s, sai 2,5 s; `Music.air`) no
  barramento `Ambience`, `Ambience.AMBIENCE_DB` -6. Sair da partida (`Rooms._exit_tree`) apaga.
- Testes (`tests/test_mix.gd`): toda arena do `catacombs.tres` (salas, chefe, loja, Provação, Altar) e as dez pedidas
  têm ar e arquivo; cada laço com mais de 15 s, RMS entre -34 e -24 dBFS, pico abaixo de -6 dBFS e sem degrau na
  emenda; trocar de sala faz crossfade (os dois tocam, depois só o novo), a mesma sala não recomeça, sem sala silêncio.
- Espectrogramas conferidos (Cripta: gotas a cada 2 s com cauda; Ponte: rajadas a cada 6 s). **Não ouvido**: o
  `art-director` deve ouvir e decidir o nível (hoje 15 LU abaixo da música; sobe por `Audio.BUSES[&"Ambience"].trim`).

## 3. Máquina fraca (DT-003) e a opção "Qualidade gráfica"

### O que mudou
- Opção nova em Configurações, "Qualidade gráfica: Alta / Média / Baixa" (`GraphicsQuality`,
  `scripts/core/graphics_quality.gd`; chave `quality` do save, 0 a 2, Alta por padrão, saves antigos ficam em Alta;
  textos `opt_quality*`). `App.apply_options` aplica a parte da janela, `Game.apply_options` a do ambiente (a pausa
  reaplica ao fechar). `--quality=alta|media|baixa` vale por uma execução (medidas) e `--gfx-<chave>=valor` troca um
  item só (experimentos).

| | Alta | Média | Baixa |
|---|---|---|---|
| Escala 3D (FSR 1 no Forward+ abaixo de 1, bilinear no Compatibility) | 1,0 | 0,85 | **0,5** |
| MSAA | 2x | 2x | nenhum |
| Névoa volumétrica / SSAO / reflexos SSR | sim / sim / sim | não / sim / não | não / não / não |
| Sombras: atlas das luzes / sol / suavização | 4096 / 4096 / suave baixa | 2048 / 2048 / muito baixa | 1024 / 1024 / dura |
| Brilho (glow) | sim | sim | sim (fogo, portal e Emeth dependem dele) |

- **Decisão (sem o PO)**: a Baixa usa escala 0,5. Medido na placa integrada (seção abaixo): com 0,7 a luta comum ficava
  em 21 ms (46 qps); o custo é quase todo de pixels (desligar todas as sombras das luzes só tirou 1 ms); 0,5 leva a
  15 ms (66 qps). A imagem fica mais mole (a 1080, 960 x 540 por dentro); a Alta continua sendo o jogo como a arte foi
  feita.
- A tela de opções cabe a 1280 x 720 com a linha nova (captura `docs/gallery/e6/options_720.jpg`, olhada: botões de
  baixo em y 642 a 690). `tools/title_flow_check.gd`: `FLOW ok`.

### Medidas na GPU (sonda `C:/Users/danie/tools/qa/gpuperf9.gd`: `--fixed-fps 60 --disable-vsync`, 240 quadros para
assentar, 300 medidos, 240 em Morvath; mediana do quadro, mediana da GPU, CPU do desenho, chamadas)

RTX 5060 Laptop, 1920 x 1080 na janela (a sonda informa o alvo de 2880 x 1620 pela escala do Windows), `--stress=150`:

| Renderizador / nível | Quadro (ms) | GPU (ms) | CPU do desenho (ms) | Chamadas |
|---|---|---|---|---|
| Forward+ Alta (2 rodadas) | 7,24 / 7,26 | **5,51 / 5,78** | 0,95 / 0,97 | 980 |
| Forward+ Média | 7,72 | **3,94** | 1,04 | 980 |
| Forward+ Baixa (escala 0,7, primeira versão) | 6,83 | **2,40** | 0,84 | 980 |
| **Forward+ Baixa (0,5, final)** | 7,69 | **1,62** | 1,00 | 980 |
| Compatibility Alta | 11,11 | **4,09** | 3,45 | 1130 |
| Compatibility Baixa (0,7) | 12,65 | **2,06** | 3,93 | 1130 |
| Forward+ Baixa (0,7) a 1280 x 720 | 10,72 | **1,41** | 1,40 | 980 |

Morvath na fase 4 (tempestade), `--start=boss --boons=25 --seed=5 --bot`, 1920 x 1080: Forward+ Alta quadro 10,27 ms,
GPU **3,92**; Forward+ Baixa (0,7) quadro 11,11, GPU **1,53**. Na RTX o quadro é limitado pela CPU (simulação de 150
inimigos 3,7 a 5,2 ms por passo no Windows com a máquina carregada): a qualidade gráfica corta a GPU pela metade ou mais,
o quadro quase não muda.

**Placa integrada (Intel RaptorLake-S Mobile Graphics), 1280 x 720, `--gpu-index 1`, Forward+**:

| Cena / nível | Quadro (ms) | GPU (ms) | qps |
|---|---|---|---|
| Luta comum (sala 1, robô, 4 inimigos), Alta | 67,85 | 67,53 | 15 |
| Luta comum, Média | 46,49 | 46,17 | 22 |
| Luta comum, Baixa com escala 0,7 | 21,64 | 21,33 | 46 |
| Luta comum, Baixa 0,7 sem sombras das luzes (experimento) | 20,70 | 20,33 | 48 |
| Luta comum, Baixa com escala 0,5 (experimento, virou a Baixa) | 15,25 | 14,88 | 66 |
| Luta comum, 0,5 e sem sombras (experimento) | 14,17 | 13,78 | 71 |
| `--stress=150`, Alta | 78,38 | 77,91 | 13 |
| `--stress=150`, Baixa 0,7 | 30,43 | 29,96 | 33 |
| Morvath fase 4, Alta | 59,29 | 57,52 | 17 |
| Morvath fase 4, Baixa 0,7 | 22,89 | 20,91 | 44 |
| **Luta comum, Baixa final (0,5)** | **15,23** | 14,86 | **66** |
| **`--stress=150`, Baixa final** | 23,71 | 23,14 | 42 |
| **Morvath fase 4, Baixa final** | **16,15** | 14,37 | **62** |
| **Fendas (`--arena=rift`, 6 inimigos), Baixa final** | **14,67** | 14,36 | **68** |
| **Jardim (`--arena=garden`, 6 inimigos), Baixa final** | **15,86** | 15,53 | **63** |
| **Cripta (`--arena=crypt`), Baixa final** | **12,07** | 11,70 | **81** |
| Jardim, Média | 48,23 | 47,83 | 20 |

Leitura: na placa integrada a Alta não é jogável (15 a 17 qps) e a Média também não (20 a 22); **a Baixa final passa de
60 qps no salão, nas Fendas, no Jardim, na Cripta e na fase 4 de Morvath a 1280 x 720** (12 a 16 ms; o quadro é a GPU). Só
o teste de estresse de 150 inimigos (oito vezes o teto do jogo) fica em 42 qps. **DT-003 fechado**: salão, Fendas e
Jardim medidos a 1280 x 720 na iGPU do próprio notebook. Não medido: Compatibility na iGPU (o OpenGL do Windows escolhe a
placa pelo driver, sem `--gpu-index`), placa dedicada fraca, celular, Linux.

Capturas (abertas e olhadas): `docs/gallery/e6/fight_alta.jpg`, `fight_media.jpg`, `fight_baixa.jpg` (RTX, 1920 x 1080,
sala 1 aos 9 s, `--bot --autopick --seed=5`), `igpu_baixa_720.jpg` (iGPU, Baixa, 1280 x 720), `options_720.jpg`. A Média
é quase igual à Alta (sem névoa no ar nem reflexos, a diferença aparece pouco na sala 1); a Baixa fica mais mole e mostra
pontos pretos nas juntas do chão e no pontilhado do raio-x do herói (escala 0,5 com o FSR), mais visíveis na iGPU a 720.

## 4. Falhas e pendências (por gravidade)

- **P2, `art-director`**: pontos pretos nas juntas do chão na Baixa (`fight_baixa.jpg`, `igpu_baixa_720.jpg`). Reproduzir:
  `tools/gpu.sh shot x.png --bot --autopick --seed=5 --shot-at=9 --quality=baixa`. Provável: o detalhe das juntas do
  `catacomb_floor.gdshader` com a escala 0,5 e o realce do FSR; opções: escala 0,6 com bilinear, ou afinar o detalhe por
  distância. Não bloqueia (é a qualidade para máquina fraca).
- **P2, `art-director`**: ouvir a mixagem e a ambiência (nada foi ouvido por QA). Música +9 dB sobre a E4; golpe comum
  2 a 3 dB acima do auge da música na fase 4; ambiência 15 LU abaixo da música. Tudo em tabelas (`Audio.BUSES`,
  `Audio.GAIN_DB`, `Ambience.AMBIENCE_DB`) e medido por `tools/mix_probe.gd -- --log=...`.
- **P3, `qa-performance`**: o modelo do limitador e o corte de vozes no `mix_replay` são modelos; o limitador real é o do
  Godot. Para conferir no som de verdade: gravar uma luta com o Movie Maker na GPU (`tools/movie.sh`) e medir o `.wav`
  com `ffmpeg -af ebur128=peak=true`.
- **P3**: na RTX o quadro é limitado pela CPU (7 a 11 ms com a máquina carregada); a qualidade gráfica não muda isso.
  O passo da simulação com 150 inimigos foi 3,7 a 5,2 ms no Windows com o WSL carregado (sem carga, cerca de 1 ms no
  `--stress=150` dos ciclos anteriores).

## 5. Testes e verificações

| Comando | Resultado |
|---|---|
| `~/tools/godot/godot --headless --path . --import` e `-s tools/check.gd` | `CHECK ok`, 0 `SCRIPT ERROR`, 0 `Parse Error` |
| `tools/test.sh` | **886 passando, 0 falhando** (244 s) |
| `tools/test.sh -gselect=test_mix` | 12/12 (`Morvath's fight: -17.3 LUFS, -1.40 dBTP after the limiter, limiter working in 4 a 7 of 953 windows`) |
| `tools/test.sh -gselect=test_graphics_quality` | 5/5 |
| `tools/test.sh -gselect=test_music` | 8/8 (`music: true peak -3.5 dBTP, loudest 0.4 s -16.7 dBFS; blows -10.5 dBFS`) |
| `~/tools/godot/godot --headless --path . -s tools/title_flow_check.gd` | `FLOW ok` |
| `tools/smoke.sh 600 --seed=5` (duas vezes, e com `--sound-log`) | Morvath aos 260,7 s, vitória aos 371,3 s, 8 Bênçãos, `step_ms_avg` 0,21; igual nas três |
| `tools/smoke.sh 180 --start=boss --boons=25 --seed=5` | vitória aos 83,8 s (igual ao relatório da E4) |
| `tools/smoke.sh 120 --stress=300 --seed=5` | `step_ms_avg` 3,71 ms com a máquina carregada (E4: 2,81 a 2,87 sem a carga dos outros agentes; a E6 não mexe na simulação) |

Testes novos: `tests/test_mix.gd` (medidor de LUFS e pico real, modelo do limitador, barramentos e volumes, ajustes por
som, ducking dos avisos, ar de toda arena, laços quietos e sem emenda, crossfade, e a luta de Morvath gravada dentro
das metas) e `tests/test_graphics_quality.gd` (níveis em ordem de custo, save, textos, ambiente, viewport, linha na tela).
Teste mudado: `tests/test_music.gd`, `test_music_sits_under_the_blows` passa a usar os ajustes dos barramentos e dos
sons (o modelo do jogo de agora) e o teto do pico da música sozinha foi de -7,5 para -3,0 dBTP (decisão da seção 1).
