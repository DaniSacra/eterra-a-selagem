# Relatório de QA e desempenho: ciclo 8 (poucos inimigos)

- **Data**: 2026-11-15, 18:55 a 20:00
- **Branch**: `arpg-3d`, **commit testado `84285e8`** (frentes A `8b821b1`, B `84285e8` e C `41f532b` do ciclo 8
  integradas). Working tree limpo no início; o QA só acrescentou arquivos em `docs/gallery/cycle8/` e este relatório.
- **Antes**: `eb1e9d7` (fim do ciclo 7), extraído por `git archive eb1e9d7 | tar -x -C /home/dani/games/c8-before` e
  espelhado em `C:/Users/danie/tools/eterra-gpu-before8`.
- **Ambiente**: WSL2 (Linux 6.18) para testes e partidas do robô sem tela (Godot 4.7.2 Linux). Capturas e medidas de
  quadro na **placa de vídeo real** pela Godot 4.7.2 de Windows (`tools/gpu.sh`, Vulkan 1.4.357, Forward+). **Sem som**.

Saídas brutas em `/tmp/claude-1000/-home-dani-games-eterra-a-selagem/9a4c8b90-ded5-40ad-bc10-27c4c52b9e83/scratchpad/qa8/`
(abaixo `qa8/`): `out/` (testes, partidas, desempenho), `png/` e `lab/` (capturas originais), `mont/` (montagens),
`tools/` (sondas). Galeria: `docs/gallery/cycle8/` (comandos em `docs/gallery/cycle8/CAPTURAS.md`).

## Máquina (lida pelo PowerShell `Get-CimInstance` e `nvidia-smi`, `qa8/out` não guarda; repetir com o comando da seção 6)

| Item | Valor |
|---|---|
| Modelo | ASUS TUF Gaming F16 FX608JMI (notebook), na tomada (bateria 100%, `BatteryStatus` 2), plano de energia "PD Performance" |
| CPU | Intel Core i7-14650HX, 16 núcleos, 24 linhas |
| GPU usada | NVIDIA GeForce RTX 5060 Laptop GPU, 8151 MiB, driver 621.01 (Windows 32.0.16.2101), relógio máximo 3090 MHz |
| GPU integrada | Intel UHD Graphics (não usada; o Vulkan escolhe a NVIDIA, linha `Using Device #0: NVIDIA`) |
| RAM | 16 GB (2 x 8 GB, 5600 MT/s) |
| Sistema | Windows 11 Home Single Language 10.0.26300; testes em WSL2 Linux 6.18 |
| Tela | a janela do jogo abre na tela 1 (1920 x 1200 nativa, 144 Hz, escala 1,0, 96 dpi segundo a Godot) |

## Veredito

**Pronto para o Daniel testar**, do ponto de vista de QA. Evidência: 0 `SCRIPT ERROR` e 0 `Parse Error` na
importação, no `check.gd`, em todas as partidas, capturas e medidas; 260 testes, 259 passando, 0 falhando, 1 arriscado
(o conhecido); fluxo do título ok; o robô chega em Morvath nas cinco sementes e vence na semente 7; nenhuma partida
passa de 20 inimigos de pé (máximo 8). A 1920 x 1080 na RTX 5060 o quadro mediano fica entre 4,8 e 4,9 ms com 4 a 20
inimigos (cerca de 205 FPS, mais de três vezes a meta de 60); o ciclo 8 custa no máximo +0,27 ms (dentro do ruído de
cerca de 0,5 ms entre rodadas). Nenhuma falha crítica, alta ou média. O julgamento visual é do `art-director` e do
Daniel; as observações visuais estão em 4 (baixa).

## 1. Checagem, testes e partidas do robô

| Comando | Resultado | Saída |
|---|---|---|
| `godot --headless --path . --import` | código 0, **0 SCRIPT ERROR, 0 Parse Error** | `out/import.txt` |
| `godot --headless --path . -s tools/check.gd` | código 0, **0 SCRIPT ERROR, 0 Parse Error** | `out/check.txt` |
| `tools/test.sh` | **24 arquivos, 260 testes, 259 passando, 0 falhando, 1 arriscado** (`test_only_finishers_glint`, "Did not assert", o conhecido), 24101 asserções, 4,6 s | `out/test.txt` |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** (12 de 12) | `out/title_flow.txt` |

Partidas do robô (`godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=N ...`, saída inteira em
`out/raw_*.txt`; as mesmas no `eb1e9d7` em `out/before_raw_*.txt`). Rodadas em paralelo, então o `step_ms` sobe um
pouco por disputa de CPU e não serve para comparar desempenho.

| Opções | Sala | Modo | Tempo | Abates | Dons | Morvath (fase) | `max_alive` | `boss_at` | No `eb1e9d7` |
|---|---|---|---|---|---|---|---|---|---|
| `300 --seed=1` | 5 | OVER | 233,2 | 29 | 2 | 127 (3) | 6 | 61,8 | OVER 200,7 s, Morvath 1382 |
| `300 --seed=2` | 5 | OVER | 228,9 | 40 | 2 | 816 (3) | 7 | 73,9 | OVER 153,1 s, 3106 |
| `300 --seed=3` | 5 | OVER | 200,5 | 39 | 2 | 1364 (3) | 5 | 66,2 | OVER 130,0 s, 4001 |
| `300 --seed=5` | 5 | OVER | 171,1 | 17 | 2 | 3038 (2) | 5 | 62,9 | OVER 183,5 s, 2623 |
| `300 --seed=7` | 5 | **ENDING (venceu)** | 229,5 | 60 | 2 | morto | 6 | 72,4 | OVER 213,4 s, 994 |
| `120 --start=boss --boons=4 --seed=1` | 5 | PLAY | 118,3 | 16 | 3 | 2404 (2) | 5 | 0 | PLAY, 2381 |
| `120 --start=boss --boons=4 --seed=2` | 5 | OVER | 109,6 | 20 | 3 | 638 (3) | 5 | 0 | igual |
| `120 --start=boss --boons=4 --seed=3` | 5 | PLAY | 118,5 | 12 | 4 | 2129 (2) | 5 | 0 | igual |
| `120 --start=boss --boons=4 --seed=4` | 5 | PLAY | 118,0 | 19 | 4 | 1145 (3) | 6 | 0 | igual |
| `120 --start=boss --boons=4 --seed=5` | 5 | PLAY | 118,3 | 14 | 3 | 1588 (2) | 5 | 0 | OVER 111,5 s, 1895 |
| `120 --start=boss --boons=25 --seed=5` | 5 | PLAY | 118,3 | 21 | 8 | 5 (3) | 6 | 0 | (não rodado no antes) |
| `120 --start=miniboss --seed=5` (Cavaleiro) | 5 | OVER | 95,2 | 1 | 1 | 4181 (1) | 1 | 38,3 | igual |
| `120 --start=miniboss --seed=2` (Ancião) | 5 | PLAY | 117,4 | 14 | 1 | 3413 (2) | 5 | 47,8 | (não rodado no antes) |
| `60 --start=fountain --seed=5` | 5 | PLAY | 58,6 | 8 | 1 | 5115 (1) | 8 | 29,7 | |
| `60 --start=shop --seed=5` | 5 | PLAY | 59,6 | 0 | 0 | 4556 (1) | 1 | 5,3 | |
| `120 --stress=300 --seed=5` | 1 | PLAY | 118,0 | 300 | 0 | | **300** | | 259 abates, 41 de pé |

- **`max_alive` nunca passa de 20 numa partida** (máximo 8, na partida que começa na fonte; 5 a 7 nas partidas inteiras).
  A única linha acima de 20 é o `--stress=300`, que é a opção de teste que põe 300 de uma vez por fora das salas
  (`game.gd:144-152`, `horde.spawn` direto); não é o jogo.
- **Salas comuns em 4 a 8**: a sonda `qa8/tools/enc_probe.gd` (só leitura, chama `EncounterGen.generate` com os dados
  reais para 500 sementes por profundidade; `out/enc_probe.txt`) dá, nas salas comuns, limite de 4 (sala 1), 6 (sala 2)
  e 8 (sala 3) de pé, maior onda de 4 a 8 e teto 8; difíceis com limite 10 a 12 e teto 12; especiais 16 e teto 16. Os
  testes `test_encounters.gd` cobrem o mesmo (`test_the_numbers_daniel_asked_for`,
  `test_no_wave_and_no_floor_past_the_tier_or_twenty`).
- Todas as partidas chegam em Morvath (sala 5); o robô agora chega aos 62 a 74 s (`boss_at`) e a semente 7 **vence**
  Morvath (`ENDING`, 60 abates). As partidas ficaram mais longas e Morvath cai mais (sementes 1, 2, 3 e 7). Mudança
  esperada do `8b821b1` (menos inimigos de pé), não uma falha; o balanceamento é do Gameplay Engineer e do Daniel.
- **Linhas `ERROR`**: 1 por execução, sempre `ERROR: 1 resources still in use at exit` com `2 ObjectDB instances were
  leaked`, igual ao ciclo 7 (B7). Nenhum `SCRIPT ERROR` em nenhuma partida, captura ou medida (`out/shots.log`,
  `out/extra.log`, `out/gpu_perf.txt`).
- Elites: o robô sempre pega a porta 0, então não encontra elite numa partida normal; elites vistos pelo `--stress-ids`
  (`11_elite.jpg`, `04`, `05`).

## 2. Desempenho na placa de vídeo, 1920 x 1080

Sonda nova `C:/Users/danie/tools/qa/gpuperf8.gd` (fora do projeto): carrega o jogo, descarta 180 quadros (3 s de
partida), mede os 300 seguintes (5 s) e devolve mediana, média e p90 do quadro (relógio), tempo de GPU e de CPU de
desenho do viewport, chamadas, primitivas e **quantos inimigos estavam de pé** em cada quadro (lido da `horde` do jogo).
Comando: `tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 60 --disable-vsync -s
C:/Users/danie/tools/qa/gpuperf8.gd -- --probe-res=1920x1080 --nosave --seed=5 <cena>` (antes: `MIRROR=...-before8
/home/dani/games/c8-before/tools/gpu.sh`). VSync desligado; `--fixed-fps 60` mantido para que as duas versões simulem
o mesmo trecho (cada quadro avança 1/60 s de jogo, como a 60 FPS de verdade; o quadro em si roda o mais rápido que
der). Três rodadas alternando a ordem (r1 antes primeiro, r2 depois primeiro, r3 antes primeiro); a tabela traz a
mediana das três medianas. Linhas cruas: `qa8/out/gpu_perf.txt` (script `qa8/perf.sh`). Resolução conferida em cada
rodada pela imagem do viewport (`image (1920, 1080)` na linha `PROBE`).

As cenas de 8 a 20 são `--autopick --stress=N --stress-ids=skeleton,runner,mage,archer,guard,priest` **sem o robô**: o
herói (vida 99999) fica parado e os inimigos o atacam, então os N ficam de pé o tempo todo (de pé: N em todos os
quadros). Com o robô eles morriam antes da medida (rodada abortada em `qa8/out/gpu_perf_bot_aborted.txt`: 2 a 7 de
pé). A "partida" é `--bot --autopick` (sala 1 de verdade, herói lutando).

| Cena (`--seed=5`) | De pé | Quadro antes | Quadro depois | Diferença | FPS antes / depois | p90 depois | GPU antes / depois | CPU de desenho antes / depois | Chamadas depois | Primitivas antes / depois | `step_ms` depois |
|---|---|---|---|---|---|---|---|---|---|---|---|
| partida `--bot --autopick` | 2 antes, 4 depois | 4,51 ms | 4,78 ms | +0,27 | 222 / 209 | 5,43 | 4,43 / 4,67 | 1,26 / 1,13 | 909 | 674 mil / 831 mil | 0,14 |
| 8 inimigos | 8 | 4,68 | 4,78 | +0,10 | 214 / 209 | 5,38 | 4,59 / 4,70 | 1,21 / 0,90 | 900 | 776 mil / 799 mil | 0,21 |
| 12 inimigos | 12 | 4,73 | 4,84 | +0,11 | 211 / 207 | 5,36 | 4,61 / 4,76 | 0,92 / 1,09 | 908 | 877 mil / 965 mil | 0,25 |
| 16 inimigos | 16 | 4,74 | 4,82 | +0,08 | 211 / 207 | 5,38 | 4,65 / 4,71 | 1,08 / 1,24 | 913 | 825 mil / 838 mil | 0,33 |
| 20 inimigos | 20 | 4,73 | 4,82 | +0,09 | 211 / 207 | 5,41 | 4,64 / 4,72 | 1,02 / 1,32 | 917 | 784 mil / 866 mil | 0,40 |
| 90 (referência, 1 rodada) | 90 | 5,16 | 5,54 | +0,38 | 194 / 181 | 6,05 | 4,93 / 5,44 | 1,13 / 1,10 | 966 | 1,09 / 1,34 milhão | 1,11 |
| 300 (referência, 1 rodada) | 300 | 8,30 | 8,34 | +0,04 | 120 / 120 | 9,00 | 5,22 / 7,37 | 1,28 / 1,29 | 1057 | 2,01 / 2,09 milhões | 3,17 |

Rodadas (quadro mediano, r1 / r2 / r3): partida antes 5,08 / 4,50 / 4,51, depois 4,96 / 4,78 / 4,62; 8 antes 4,70 /
4,67 / 4,68, depois 4,98 / 4,72 / 4,78; 12 antes 4,73 / 4,78 / 4,62, depois 5,17 / 4,72 / 4,84; 16 antes 5,24 / 4,70 /
4,74, depois 5,15 / 4,77 / 4,82; 20 antes 4,80 / 4,73 / 4,71, depois 4,82 / 4,83 / 4,80. FPS = 1000 / quadro mediano.

Leitura:
- **Meta de 60 FPS em 1080p: cumprida com folga** em todas as cenas (pior p90 com até 20 inimigos: 5,43 ms, cerca de
  184 FPS). O quadro é quase todo GPU (4,6 a 4,8 ms); o custo por inimigo é pequeno (de 8 para 20 inimigos o quadro
  não muda).
- O ciclo 8 custa de +0,08 a +0,11 ms com 8 a 20 inimigos e +0,27 ms na partida (que agora tem 4 de pé contra 2 no
  antes, porque a sala mudou); a variação entre rodadas da mesma cena chega a 0,5 ms (r1 sempre mais lenta), então só
  a tendência de +0,1 ms é firme. As primitivas sobem (barras maiores, avisos e faixa de armadura).
- Com 300 inimigos a GPU sobe 2,1 ms (5,22 para 7,37) mas o quadro não muda (8,3 ms), porque ali quem segura é a CPU
  (`step_ms` 3,17); uma rodada só, citada como referência técnica.
- **Correção do relatório anterior**: as medidas do ciclo 7 diziam 1672 x 941, mas com `-s` a sonda antiga não lê o
  `--resolution` e o jogo devolve a janela ao tamanho salvo (`App.apply_options`, `scripts/app.gd:12-23`: 1280 x 720
  sem `--shot`/`--frames`). A sonda deste ciclo, antes da correção, registrou `window (1280, 720) render (1280.0, 720.0)` mesmo com `--resolution 1920x1080` (a sonda antiga não imprimia o tamanho). Os números do ciclo 7
  eram, então, de 1280 x 720. A sonda nova repõe o tamanho pedido (`--probe-res`) e confere pela imagem.
- **NÃO MEDIDO**: celular, navegador (Compatibility), placa fraca, versão exportada, 1440p ou 4K, tela cheia.

## 3. Capturas (abertas e olhadas uma a uma)

19 arquivos em `docs/gallery/cycle8/` (os 14 do contrato, `10b_preparo_laboratorio.jpg` e as quatro montagens), JPG
de qualidade 85 regravado pela própria Godot, 1920 x 1080 (montagens 3840 de largura). Comando, momento e o que se vê
em `docs/gallery/cycle8/CAPTURAS.md`. Notas:
- Com o robô os inimigos caem rápido: com `--shot-at=5` sobravam 4 de 8 e 12 de 20. Os quadros de 8, 16 e 20 foram
  tirados a 1,1 s (`--shot-at=1.2`) e o de 12 a 2,4 s; o número real de pé está na tabela do `CAPTURAS.md` (5, 10, 13
  e 14). Sem o robô o herói fica parado, então não usei.
- `10_inimigos_preparando_ataque` saiu do jogo (20 quadros seguidos, escolhido o do Escudo preparando a investida com o
  aviso em linha); o laboratório `--tell=0.85` foi junto como `10b`.
- `13_hud` saiu de `--frames` (o avanço em recarga só aparece por uns 0,7 s; não há `--shot-on=dash`).
- Antes e depois não são o mesmo instante: o `8b821b1` muda o sorteio da partida (a linha `RESULT` difere). As
  montagens comparam o mesmo comando.

## 4. Falhas e regressões por gravidade

Nenhuma crítica, alta ou média.

### Baixa
- **B1. Herói atrás do obelisco ainda pode ler como em cima dele** (era o B3 do ciclo 7, melhorado). A frente B
  escureceu as pernas cobertas, manteve o fio marfim e tirou o anel de cima da pedra
  (`before_after_obstaculo.jpg`, recorte 3x), mas o corpo inteiro continua desenhado sobre o topo do obelisco e o
  fio marfim contorna os pés sobre a pedra (`12_obstaculo_transparencia.jpg`). Reproduzir: `RES=1920x1080
  tools/gpu.sh shot x.png --start=fountain --bot --seed=5 --cam-dist=26 --shot-at=1.5`. Responsável: Art Director
  decide; Environment Artist/Gameplay se mudar.
- **B2. Pilha de números com muitos atingidos.** Com o dom "Giro da Alvorada" e 13 a 14 inimigos em volta, 12 ou mais
  números verdes e "Atordoado!" se amontoam sobre o herói (`04_combate_16_inimigos.jpg`, `05_combate_20_inimigos.jpg`,
  linha de baixo de `before_after_combate.jpg`). O `NumberTally` soma por alvo, então cada alvo ainda tem o seu. Art
  Director e UI/UX decidem se é demais.
- **B3. Herói difícil de achar no bolo de 20** em alguns quadros (com o orbe branco do feiticeiro ao lado, em
  `qa8/png/after_05b.png`, descartada). Risco já conhecido (B5 do ciclo 7). Art Director.
- **B4. Separação de cor no Ômega**: o inimigo perto da borda direita fica com franjas vermelho, verde e azul
  (`08_emeth_impacto.jpg`, x 1700 a 1850). É a separação de cor dos finalizadores (`screen.gdshader:26-28`, ciclo 7),
  feita de propósito; registro para o Art Director avaliar se lê como defeito.
- **B5. Balanceamento mudou** com menos inimigos: partidas inteiras do robô 171 a 233 s (antes 130 a 213), Morvath
  termina mais baixo e a semente 7 vence (`ENDING`). Esperado do `8b821b1`; o Gameplay Engineer e o Daniel decidem.
- **B6. O robô nunca encontra elite numa partida** (pega sempre a porta 0, a fonte), como no ciclo 7. Elites só por
  `--stress-ids`. Gameplay Engineer, se quiser cobertura automática.
- **B7. Vazamento ao sair** (`2 ObjectDB instances leaked`, `1 resources still in use`), igual a antes.

### Corrigidos desde o ciclo 7 (vistos nas capturas)
- Inimigo atingido não vira mais silhueta branca chapada (era o B4 do ciclo 7): `before_after_emeth.jpg`, colunas da
  esquerda (antes, branco) e da direita (depois, nas cores dele).
- Luz do portal vermelho nos degraus da sala de Morvath (era o B2 do ciclo 7): `14_morvath_atual.jpg`.
- Anel do herói sobre a pedra do obelisco: sumiu (`before_after_obstaculo.jpg`).

## 5. Limitações
- Desempenho só no notebook do Daniel (RTX 5060 Laptop); nada medido em celular, navegador real, placa fraca ou
  versão exportada (não pedidos). Sem som; sem gente jogando (só o robô).
- As capturas e medidas abrem uma janela na tela do Daniel; a janela fica na tela 1 (1920 x 1200).
- Não alterei código de jogo, arte nem ferramentas do projeto. Ferramentas novas, fora do projeto:
  `C:/Users/danie/tools/qa/gpuperf8.gd` (sonda de quadro, ver seção 2) e `C:/Users/danie/tools/qa/wintest.gd`
  (diagnóstico da janela), `qa8/tools/enc_probe.gd` (leitura dos encontros), `qa8/tools/tojpg.gd` (PNG para JPG 85).
  Criei `/home/dani/games/c8-before` (cópia do `eb1e9d7`) e o espelho `C:/Users/danie/tools/eterra-gpu-before8`;
  podem ser apagados. Nenhum commit.

## 6. Como repetir
- Testes e partidas: `qa8/cpu.sh` (depois) e `qa8/cpu_before.sh` (antes).
- Capturas: `qa8/shots.sh`, `shots2.sh`, `shots3.sh` (`after|before` e os números), `qa8/extra.sh` (quadros de HUD,
  preparo e laboratório), montagens `qa8/montage.sh`.
- Desempenho: `qa8/perf.sh`, tabela `python3 qa8/tools/perf_table.py qa8/out/gpu_perf.txt`.
- Máquina: `powershell.exe -NoProfile -Command "Get-CimInstance Win32_Processor; Get-CimInstance Win32_VideoController;
  Get-CimInstance Win32_ComputerSystem; Get-CimInstance Win32_OperatingSystem; Get-CimInstance Win32_PhysicalMemory"`
  e `nvidia-smi --query-gpu=name,memory.total,driver_version,clocks.max.graphics --format=csv`.
