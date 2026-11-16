# Relatório de QA e desempenho: C12c "Qualidade da experiência" (QA-02) e vídeos de game feel

- **Data**: 2026-11-16.
- **Branch**: `arpg-3d`, **commit testado `beb6c27`** (C12c integrado); antes = `fffd677` (`docs/gallery/cycle12c/BEFORE.md`).
  Árvore limpa no começo. O QA não mudou código de jogo, arte nem testes; acrescentou só ferramentas de captura fora de
  `scripts/` (`tools/movie.sh`, `tools/feel_driver.gd`, `tools/feel_driver_bot.gd`), `docs/gallery/cycle12c/after/` +
  `AFTER.md`, `docs/gallery/game_feel/` + `VIDEOS.md` e este relatório.
- **Ambiente**: WSL2 (Linux 6.18) para importação, testes e simulações (Godot 4.7.2 Linux, sem tela). Capturas, vídeos e
  quadros na **placa de vídeo real** pela Godot 4.7.2 de Windows (Vulkan 1.4.357, Forward+, NVIDIA GeForce RTX 5060 Laptop
  GPU), espelho `C:/Users/danie/tools/eterra-gpu-qa`. Som medido só na mistura do Movie Maker (ninguém ouviu). Nenhum teste
  com gente.

## Veredito

**Pronto para o Daniel testar, com uma ressalva visual.** Nenhuma falha crítica; nenhuma regressão; testes, checagens,
robô, câmera, som e quadro passam. **Uma falha alta de aceite**: as colunas de luz da recompensa e da fonte continuam
brancas na tela (maior canal 255 em 93 a 100% do miolo), apesar do teto no material (GP-01). Ela não trava o jogo; a
entrada de Morvath, que era a pior parte do GP-01, está resolvida. Decidir se o teste do Daniel espera a correção é do Game
Director. O chão da Cripta subiu (mediana 30 para 43,5) mas só 4 de 8 recortes chegam a 45 (ENV-01 em parte).

## 1. Checagem e testes

| Comando | Resultado |
|---|---|
| `godot --headless --path . --import` | código 0, **0 SCRIPT ERROR, 0 Parse Error** |
| `godot --headless --path . -s tools/check.gd` | `CHECK ok` |
| `tools/test.sh` | **50 arquivos, 495 testes, 495 passando, 0 falhando, 0 arriscados**, 103200 asserções, 114,5 s; nenhuma linha "leaked" ou "still in use" (DT-005 não apareceu) |
| `godot --headless --path . -s tools/title_flow_check.gd` | **FLOW ok** |
| `git diff --stat fffd677 beb6c27 -- tools/make_data.gd data/` | só `data/text_pt.tres` (+3 chaves: `end_room`, `end_where`, `end_gifts`); **`make_data.gd` sem mudança, nenhum número de combate** |

Exportação de Windows e Web: não pedida, não feita.

## 2. Aceite do C12c (roadmap_plan.md, seção D), item a item

| # | Aceite | Medida | Resultado |
|---|---|---|---|
| 1 | 0 inimigo e 0 robô preso em 96 lutas e 8 descidas | 96 lutas (16 sementes x Cripta, Fendas, Jardim x A, B; `tools/smoke.sh 45 --arena=<a> --variant=n --seed=1..16 --bot-reaction=0.25`): `stuck` 0, `bot.stuck` 0; 8 descidas (`tools/smoke.sh 600 --seed=1..8 --bot-reaction=0.25`): `stuck` 0, `bot.stuck` 0 | **passa** |
| 2 | Sala 1 vencida 16 de 16 em cada arena e variante | 16/16 nas seis; sala mediana 13,3 a 17,7 s (máx. 31,2), 1º contato 2,3 a 3,6 s (máx. 4,4), dano médio 0 a 1,3 (máx. 18, Cripta B), 0 mortes | **passa** |
| 3a | Nenhum clarão acima do glow sobre o herói ou Morvath (GP-01) | Morvath aos 0,5 s sem coluna, corpo 45 de mediana; **coluna da recompensa 255 (98,7% acima de 235)**, **coluna da fonte 255 (100%)**, herói dentro da coluna 217 (54% acima de 235; antes 252 e 86%); gemas com cor de volta mas canal dominante em 255 | **não passa** (colunas) |
| 3b | Chão da Cripta na luta 45 a 60 (ENV-01) | mesmos 8 recortes do antes: 19, 34, 50, 56 (A) e 40, 31, 56, 47 (B); mediana 43,5 (antes 30); tampa 120, máx. 216 | **em parte** (4 de 8) |
| 4 | Salto do alvo da câmera abaixo de 0,5 m a 60 FPS (GP-06) | `--trace-cam`, 46 salas (4 descidas e 6 começos por arena): máximo **0,400 m** (o teto de 24 m/s) | **passa** |
| 5 | Pico até -1,0 dBFS na descida com som (GP-05) | **-2,94 dBFS** no PCM do AVI (antes 0,0); 0 janelas de 0,1 s acima de -1 dB; AAC do mp4 -2,5 dB | **passa** |
| 6 | Registro com os campos do GP-02 e `source: bot`; derrota com sala, arena e dons (UI-02) | `tools/smoke.sh 120 --seed=5 --runlog=<arq>`: `version` 2, `source: bot`, `boons_at_boss`, `shop`, `fountain_used`, `hurt_ctx`; por sala `variant`, `gold_in`, `boons_in`, `dodges`, `hits`, `hits_by`, `shots`, `blocked_by` | **passa** (registro); tela de derrota não recapturada pelo QA (`work/ui_after_end_1080.jpg` do `ui-ux-designer`, coberta por `tests/test_end_screen_run.gd`) |
| 7 | Testes, `check.gd`, `title_flow_check.gd`, smoke `300 --seed=5` vence, quadro sem piora acima de 0,3 ms | seção 1; `300 --seed=5` **venceu** (Morvath aos 129,5 s, 247,4 s no total); `120 --start=boss --boons=25 --seed=5` venceu (86,9 s); `120 --stress=300 --seed=5` 258 abates, 300 de pé no pico, `step_ms_avg` 3,3, sem erro; quadro: diferença média -0,05 a +0,17 ms por arena (seção 4) | **passa** |
| 8 | Evidências em `docs/gallery/cycle12c/` e relatório | `after/` + `AFTER.md` (tabela antes e depois), este relatório | **passa** |
| 9 | Nenhum número de combate mudado | seção 1 | **passa** |

Outros itens com número: ENV-02 fraturas **198** de máximo (antes 206, aceite 200) **passa**; UI-01 placa "Fortalecer dom"
com maiúscula de cerca de 17 a 18 px a 1080 (zoom no quadro `gemas_portas_criptaA`) passa no tamanho; o bug do BEFORE
"aviso fere depois da sala vencida" **corrigido** (mesmo comando: o aviso some no quadro de "Sala vencida", vida 30/30,
`hurt_by` vazio; `after/sem_dano_apos_sala_vencida.jpg`). DT-004 (descida inteira com som a 1080) **feito**:
`after/descida_com_som.mp4`.

## 3. Robô: descidas (reação 0,25)

| Semente | Resultado | Morvath aos | `hp_at_boss` | `boons_at_boss` | Loja |
|---|---|---|---|---|---|
| 1 | venceu (215,0 s) | 106,8 s | 53 | 4 | 33 de ouro, nada |
| 2 | venceu (238,2 s) | 113,5 s | 14 | 3 | comprou romã (100) |
| 3 | venceu (224,3 s) | 118,1 s | 12 | 3 | comprou romã (100) |
| 4 | perdeu na fase 4 | 120,4 s | 19 | 3 | nada |
| 5 | venceu (245,7 s) | 111,6 s | 40 | 2 | nada |
| 6 | venceu (236,7 s) | 113,0 s | 24 | 2 | comprou romã (100) |
| 7 | perdeu na sala 5 (Jardim, guardião) | | | | |
| 8 | perdeu na fase 4 | 94,8 s | 30 | 3 | nada |

5 vitórias em 8 (C12: 4); `boons_at_boss` 2 a 4 (mediana 3); `max_alive` 7; `fountain_used` falso nas 8 (ver B-2).
`step_ms_avg` 0,19 a 0,27 ms, `step_ms_peak` 2,6 a 11,1 ms (rodadas 4 de cada vez). A descida gravada (semente 7 a 30 FPS)
venceu com 1 de vida; a mesma semente a 60 FPS sem tela perde na sala 5 (o resultado depende da taxa de quadros, como no
antes).

## 4. Desempenho

Quadro a 1920 x 1080 (Forward+), mediana em ms, base `fffd677` e `beb6c27` alternados na mesma sessão, duas rodadas cada
(sonda `gpuperf9.gd`, 300 quadros):

| Cena | Base | `beb6c27` | Diferença |
|---|---|---|---|
| Cripta A | 3,49, 3,64 | 3,56, 3,80 | +0,12 |
| Cripta B | 3,60, 3,93 | 3,67, 3,77 | -0,05 |
| Fendas A | 4,56, 4,50 | 4,59, 4,53 | +0,03 |
| Jardim A | 5,03, 5,22 | 5,24, 5,35 | +0,17 |
| Salão | 5,92, 5,61 | 5,92, 5,85 | +0,12 |

O notebook varia até 0,4 ms entre rodadas da mesma cena (o salão deu 5,53 a 5,96 antes de alternar). Compatibility não
remedido (ENV-03 vale pela medida do `environment-artist`). Celular e placa fraca: não medidos (não há aparelho).

## 5. Falhas e regressões por gravidade

Nenhuma crítica. Nenhuma regressão.

**Alta**
- **A-1. Colunas de luz brancas na tela apesar do teto (GP-01).** Reproduzir: `MIRROR=... tools/gpu.sh run
  --rendering-driver vulkan --resolution 1920x1080 --fixed-fps 30 -- --nosave --arena=crypt --variant=0 --seed=5 --bot
  --autopick --bot-reaction=0.25 --frames=C:/.../cA --shot-at=12.5 --count=45 --every=0.1`; quadros `_15` a `_21`, recorte
  (915, 120, 90 x 330): mediana 255, 255, 255, 255, 247, 222, 170 (máx. 255 até 0,6 s depois do abate). Fonte: `--start=fountain
  --seed=5 --frames=... --shot-at=0.2 --count=6`, recorte (1440, 200, 40 x 150) 255 em 100%. `after/coluna_recompensa_criptaA.jpg`,
  `after/coluna_fonte.jpg`. O teste GUT confere `cap` do `Fx.beam` (1,0), não o pixel: a coluna é aditiva sobre o chão
  aceso e passa pela exposição 1,25 e pela curva; no último abate há ainda o brilho da câmera lenta. Sugestão: medir o
  pixel num teste de captura ou baixar o teto efetivo até a tela dar 235 (a coluna "fraca", com 0,2 da luz, dá 216).
  Responsável: `gameplay-engineer` (o `art-director` decide o valor).

**Média**
- **M-1. Chão da Cripta abaixo de 45 longe das velas (ENV-01 em parte).** Oeste da A 19, norte da A 34, norte da B 31
  (recortes do BEFORE, `after/crypt_vA_c_recortes.jpg`, `crypt_vB_c_recortes.jpg`); sul e leste já em 47 a 56. Reproduzir com o
  `shot` do `AFTER.md`. Responsável: `environment-artist` (ou o `art-director` aceita os cantos escuros e o aceite passa a
  valer só para o terço central).

**Baixa**
- **B-1. Gemas das portas com o canal dominante em 255** (cor de volta, mas saturada: vermelha 255, 127, 104; azul 145,
  216, 255; Dom e Ouro da fonte 255, 255, 116 e 255, 255, 103, quase brancas). `after/gemas_portas_criptaA.jpg`,
  `coluna_fonte.jpg`. Responsável: `gameplay-engineer` (`Rooms.gem_color`), se o `art-director` mantiver "até 235".
- **B-2. O robô nunca usa a fonte** (`fountain_used: false` nas 8 descidas; na semente 7 sem tela ele entrou na sala da fonte com 14
  de 30, abaixo dos 60% em que deveria ir até ela, e saiu com 14). Causa: em `Bot.step`, com a sala sem inimigos ele vai direto para `rooms.bot_goal()` e retorna antes do trecho da
  fonte (`fountain_target`, linha 189 do `bot.gd`). Só afeta métricas do robô (`hp_at_boss` menor que o de gente que usa a
  fonte). Responsável: `gameplay-engineer`.
- **B-3. O limitador trabalha muito**: 67 janelas de 0,1 s no teto (-2,94 dBFS) na descida, desde os 3,4 s. Sem corte; a
  avaliar na mixagem do C15 (C15-01). Responsável: `gameplay-engineer`.
- Silêncios de 2 s ou mais iguais ao antes (11 trechos, 15,0% de 0 a 245 s): música desligada, é o C15, não falha do C12c.

## 6. Vídeos de game feel (diretriz do Daniel, seção Testes)

Em `docs/gallery/game_feel/` (1920 x 1080, câmera do jogo, mp4 com som, menos os lentos), com comando e o que observar em
`VIDEOS.md`: (a) movimentação e esquiva, (b) combo inteiro e finalizador, (c) acertos de perto e reação dos inimigos, (d)
especial, círculo e os três Ômegas, (e) grupo misto de 8 com o robô, (f) Morvath fases 1, 2, 3 (até a 4) e 4, (g) (b) e (c)
a 0,25x sem som (gravados a 120 quadros por segundo e tocados a 30, então cada quadro é um quadro do jogo). (a) a (d) e (g)
usam um roteiro de entrada fixo (`tools/feel_driver.gd`), não o robô; o resto, o robô.

## 7. Limitações

- WSL2 sem Vulkan da GPU; capturas pela Godot de Windows. Som só medido (sem ouvir). Nenhum teste com gente; o robô vencer
  não prova game feel.
- Uma captura de cada momento; a partida da Cripta A mudou de tempo com o código novo (mesmo momento, não mesmo quadro).
- As 96 lutas e 8 descidas rodaram 4 de cada vez (os tempos de passo delas não valem como desempenho).
- Ferramenta: o Movie Maker só sai a 1080 por `tools/movie.sh` (override no espelho); `tools/gpu.sh run --write-movie
  --resolution 1920x1080` continua saindo a 1280 x 720.
- Brutos (AVI e PNG) em `C:/Users/danie/tools/qa/c12c2/` apagados no fim; a cópia da base para medir o antes
  (`/home/dani/games/qa-c12c-base/`) e o espelho dela (`C:/Users/danie/tools/eterra-gpu-head`) também foram apagados.
