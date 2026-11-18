# Combate: cadência e sensação, auditoria do fim do ciclo (2026-11-18, `dd1f5ba`)

Autor: `combat-feel-director`. Só medição; nada de código, dado ou outro documento mudou. Evidências em
`docs/reports/2026-11-18/combat_feel/`. Legenda: **[M]** medido (comando e FPS), **[D]** dado do jogo (arquivo),
**[H]** Hades II (`docs/design/hades2_feel_study.md`), **[I]** inferência, **[O]** observado nos registros do PO.

## Resumo

1. A mão do Guerreiro está no molde do Hades II: a sonda passa **40 de 40** (golpes parados, 1/2/3 com 13 e 21 f, buffer, esquiva no quadro, hit stop sem congelar, ultimate); nenhum P0 achado em herói, inimigos ou Morvath.
2. O T5/T5b se sustenta: em 160 golpes medidos o aviso enche no quadro do dano (+0 f, um caso +1), o dano sai do corpo, nenhuma pose parada acima de 0,22 s; Morvath sem saltos de desenho (1 quadro estranho em 6411, na queda).
3. O que mais tira o "gostoso" agora é **justiça e variedade**, não tempo do herói: os orbes do feiticeiro são 33% dos golpes que o PO levou (aviso mediano 2,2 a 2,6 s, esquiva pronta), o corredor bate com 0,7 s de aviso (Hades 1,5 s) e a fase 1 de Morvath vira laço da foice (12 de 15 ataques) com o herói perto.
4. Faltam camadas de peso: o sopro do giro sai 0,27 a 0,33 s antes da lâmina, elites só ganham armadura (o Guard elite do Hades golpeia duas vezes), e o corpo do inimigo não clareia no "vai bater" como no Hades.
5. As 10 melhorias abaixo são quase todas de dado ou de uma função, uma a duas tardes cada; o robô não serve para medir a ameaça dos inimigos de perto (0 golpes de perto em 4 descidas, contra 19 do PO), então o aceite final depende de uma partida do PO com o `runs.jsonl`.

## Como foi medido

Todos na CPU, Godot 4.7.2 sem tela, `--fixed-fps 60`, HEAD `dd1f5ba`.

| Medida | Comando | Saída |
|---|---|---|
| Sonda da mão | `godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain` | `combat_feel/feel_probe.txt` (40/40) |
| Inimigos parados contra herói parado | `-s tools/enemy_motion_probe.gd -- --play --seed=1` e `--seed=2 --hero-hp=9999 --probe-secs=60`, lido por `tools/enemy_motion_probe.py` | `combat_feel/enemy_motion_play_s1_s2.txt` |
| Inimigos contra o robô | `-s tools/enemy_motion_probe.gd -- --bot --nosave --seed=2` e `--seed=3 --bot-reaction=0.25 --probe-secs=200` | `combat_feel/windup_outcomes.txt` |
| Guardião (Cavaleiro) | `-s tools/enemy_motion_probe.gd -- --play --nosave --start=miniboss --seed=1` e `2 --hero-hp=9999 --probe-secs=45` | idem |
| Morvath, desenho x lógica | `-s res://tools/boss_probe.gd -- --start=boss --bot --nosave --seed=5 --bot-reaction=0.25 --boons=5 --probe-secs=150 [--probe-log]` | `combat_feel/boss_probe_s5.txt`, `morvath_idle_slide_s5.txt` |
| Morvath, cadência | `-s res://tools/boss_cadence.gd -- --start=boss --bot --nosave --seed=1 --boons=5 --bot-reaction=0.25` | `combat_feel/boss_cadence_s1.txt` |
| Descidas inteiras | `tools/smoke.sh 900 --seed=1..4 --bot-reaction=0.25` | `combat_feel/robot_runs.txt` |
| Partidas do PO | `user://runs.jsonl` (12 partidas de 2026-11-16 a 2026-11-18, teclado), `hurt_ctx` agregado | `combat_feel/human_runs_hurt.txt` |
| Sopro x impacto | envelope de `audio/blade*.ogg`, `thrust_0`, `hit*` por ffmpeg (8 kHz, janelas de 10 ms) | números no achado CF-03 |

Vídeo na GPU (`FPS=60 RES=1280x720 PRE="-s res://tools/feel_driver.gd" tools/movie.sh ... 720 --bot --start=miniboss --feel=hits --seed=3`):
não gravado; a fila da GPU estava com quatro capturas de outros agentes e cancelei o meu antes de pegar a trava (o
`override.cfg` do espelho não chegou a ser escrito). Fica pendente para o `qa-performance`.

## O que já está bom (medido, para não mexer)

- Guerreiro [M]: preparações 5 / 8 / 22 f, pernas 11 / 19 / 30 f, golpe 2 aos 13 f e giro aos 21 f do anterior com o ataque apertado; 0,00 m andados; nenhum quadro de corrida preso; esquiva no f0 com 19 f de proteção; hit stop 25/65/70 ms com 0 quadros parados; tranco 0,088 m; clarão 4 f. Tudo igual ao cajado do Hades [H] (0,24 / 0,43 / 0,86 s).
- Inimigos [M]: esqueletos esperando sem tremor (0 giros acima de 8 graus por 10 s, 0 a 0,03 inversões/s); bote fere de 0,93 a 2,0 m do herói com a lâmina de 2,21 m; recuperação parada no máximo 0,22 s; preparação parada no máximo 0,17 s.
- Morvath [M]: giro limitado e mistura sem degraus seguram (boss_probe: `bad=1` em 6411 quadros, o da queda; maior passo 0,15 m por quadro andando ao centro).
- Ameaça para gente [O]: o PO leva golpe de quase todos (14 fontes), nenhum fora da tela, aviso mínimo 0,65 s; a foice de Morvath é o golpe que mais fere nas lutas dele (12 a 18 de dano por luta) e já o derrubou uma vez. Morvath tem dente.

## Achados

### P0

Nenhum. Nada de comando involuntário, herói preso, teleporte, ataque sem estado ou dano fora do corpo nas medições acima.

### P1 (game feel)

| Id | Problema | Evidência (comando e número) | Causa | Confirmada? |
|---|---|---|---|---|
| CF-01 | **Orbes do feiticeiro são o maior dano do jogo e parecem injustos**: acertam depois de muito tempo no ar | [O] PO: feiticeiro 13 + elite 9 = **22 de 67 golpes (33%)**, aviso mediano **2,21 s e 2,63 s** (até 3,8 s), 19 de 22 com a esquiva pronta, nenhum fora da tela; morreu 2 vezes para o feiticeiro. [M] robô: 15 de 25 golpes nas salas (60%) | Orbe a 7 m/s por 20 m (2,9 s de vida) que vira 40 graus/s atrás do herói (`shot_turn` 40 no `_enemies` do `make_data.gd`; o arquivo do Hades não diz quanto, o 40 é nosso); elite com 7 orbes | Efeito confirmado; a curva como causa é **hipótese** (o aviso longo mostra orbes que pegam no fim do voo, não no começo) |
| CF-02 | **Corredor bate com pouco aviso** | [O] PO: 9 golpes (13%), aviso **0,70 a 0,82 s**, todos com a esquiva pronta. [D] `attack_windup` 0,7 (`make_data.gd`, runner) contra o Radiator do Hades **1,5 s** de preparação e 1,6 s girando [H 4.2] | Número nosso abaixo do Hades (a regra do projeto é copiar os números) | Divergência de dado **confirmada**; que ela causa os golpes é **hipótese** forte (é o menor aviso do jogo depois do golpe curto do Escudo, 0,65) |
| CF-03 | **Sopro do giro (e da lança) sai antes da lâmina** | [M] `blade_spin_0/1/2.ogg`: pico do envelope 90 / 70 / 30 ms depois do aperto; o giro acerta no **f22 (0,36 s)**: o sopro chega **0,27 a 0,33 s antes**. Golpe 2: pico 70 ms, acerto 0,13 s (cerca de 4 f antes, aceitável); golpe 1 dentro de 1 a 4 f | `Player._on_move_started` toca `node.sound` no começo da preparação (`scripts/game/player.gd:730`); o Hades toca o giro de lâmina no quadro 14 da preparação e o passo pesado no quadro do golpe [H 5] | **Confirmada** (código e amostras) |
| CF-04 | **Fase 1 de Morvath com o herói perto é a foice em laço** | [M] `boss_cadence` semente 1: fase 1 = **12 foices, 3 lâminas, 0 investidas** (80% foice); semente 5: `RECOVER/slash2` só 29 quadros (uma lâmina), nenhuma investida na luta inteira | `_bosses` do `make_data.gd`: lâminas pedem `min_dist` 3,5 m, investida 9 m; perto só sobra a foice (`streak` 2 e "nunca vazio" do `BossDirector`) | **Confirmada** (dado e medida) |
| CF-05 | **Elites sem golpe próprio**: só armadura, velocidade e janela menor | [D] `_pair(...)` do esqueleto elite muda `armor`, `speed`, `rating`, `recover_time`; nenhum golpe novo em nenhum elite. [H 4.2]: Guard elite **dois golpes a 0,2 s** e não para; Radiator elite gira a 500 graus/s (o dobro) | Escopo: a E1b copiou atordoamento e armadura, não os ataques de elite | **Confirmada** |
| CF-06 | **O corpo não acende no "vai bater"** | [D] `crowd.gdshader:158`: o `tell` (estado.b) só acende a lâmpada do orbe; o corpo só treme no segurar (`windup_shake`). [H 4.1]: nos últimos `min(0,5 s, preparação)` o Hades treme **e** clareia o corpo até 0,95 em branco | Não copiado (o clarão de golpe sofrido usa o mesmo canal de cor; seria uma rampa nova abaixo do `flash_cap`) | **Confirmada** (código) |
| CF-07 | **Morvath desliza parado**: posição lógica andando com o desenho em `idle` | [M] `boss_probe --probe-log` s5: **77 trechos, 158 quadros** em `idle` com o corpo a mais de 1 m/s; piores 12 f a 5,2 e 5,5 m/s (**1,04 e 1,10 m**, f599 e f5124 em `CHASE/idle`), 8 f a 5,9 m/s (0,78 m, f2991 em `RECOVER/idle`) | Nesses trechos a distância ao herói cai de 3,4 para 0,5 m em 10 f: o herói esquiva por dentro dele e ele é tirado de cima a 5 a 6 m/s, acima do `BodyBlock.EASE` 3 m/s; caminho exato (empurrão, `keep_off_target` ou o passo do `CHASE` sem trocar o clipe) **não isolado** | Efeito **confirmado**; causa **hipótese** |

### P2 (polimento e medição)

| Id | Problema | Evidência | Causa | Confirmada? |
|---|---|---|---|---|
| CF-08 | Cadência de metrônomo: com o herói parado cada esqueleto bate a cada **215 f exatos (3,58 s)**, 15 vezes seguidas; o Cavaleiro dá **9 golpes curtos idênticos** a cada 195 f e nunca mais investe enquanto está perto | `enemy_motion_play_s1_s2.txt` (s2: f1118, 1333, 1548... o mesmo esqueleto); `mb_2.csv` (`WINDUP/attack 48, ATTACK 31, RECOVER 48, WALK 68` repetido) | `AFTER_RECOVER` 0,25 s fixo, recargas fixas; Cavaleiro só escolhe a investida de longe | Confirmada (medida); que o Hades sorteia a espera é **[I] a confirmar** |
| CF-09 | Clipes do herói comprimidos: golpe 1 a **2,75x**, corte da esquiva e lança a **3,67x**; o critério da matriz era no máximo 1,5x (`combat_cadence.md` 3, P1-2) e nunca foi cumprido | `data/combos/paladin.tres` (`anim_speed`) | `_move`: `anim_from = peak - max(0,22, windup)` espreme 0,22 s de subida em 0,08 s | Confirmada nos dados; o efeito na tela precisa de vídeo (o PO ainda não reclamou depois da E1c) |
| CF-10 | Golpe sem a segunda camada: o Hades dá sopro + voz de esforço no disparo e passo pesado no quadro do golpe; nós só sopro (e pano no golpe 2) e o impacto se acertar | `tools/make_sfx.sh` (linhas `blade_heavy_*`), [H 5] | Escopo do T5 de áudio | Confirmada |
| CF-11 | Cavaleiro troca andar/parado **0,88 vez/s** (s2; critério do T5-10 0,5) | `enemy_motion_probe.py` em `mb_2.csv` | Histerese do andar pensada para o esqueleto | Confirmada (medida); visual não conferido |
| CF-12 | O robô não mede a ameaça de perto: preparações do esqueleto que chegam ao golpe **4 de 26 e 0 de 14**, Escudo 50%, **0 golpes de perto** no robô em 4 descidas; o PO levou 19 (esqueleto 7, corredor 9, Cavaleiro 3) | `windup_outcomes.txt`, `robot_runs.txt`, `human_runs_hurt.txt` | O robô esquiva com 0,25 s e bate sem parar (atordoamento de 0,5/1,1 s corta tudo) | Confirmada; consequência: **não balancear inimigos de perto pelo robô** |
| CF-13 | Ômega quase não usado por gente: 0 a 9 por partida (mediana 1); ultimate nunca medida (o robô não tem save) | `runs.jsonl` (`omegas`); `robot_runs` (`ult.uses` 0) | Hipótese: carga de 0,8 s sentida como lenta ou Magia guardada; não dá para separar sem perguntar ou registrar | Hipótese |
| CF-14 | Ritual (fase 2) é 25 a 38% da luta do robô (30 a 55 s) | `robot_runs.txt` (`phase_time`) | Teto de 20 s mais as erupções depois | Medido só no robô; precisa da duração do PO |

## Comparação com o Hades II (o que falta para "perfeito e gostoso")

| Aspecto | Hades II [H] | Eterra hoje [M]/[D] | Lacuna |
|---|---|---|---|
| Tempo dos 3 golpes, buffer, esquiva, hit stop | 0,24 / 0,43 / 0,86 s; buffer; esquiva corta | igual (sonda 40/40) | nenhuma |
| Som do golpe | sopro com 13 amostras + voz de esforço; giro de lâmina no f14 da preparação; passo pesado no quadro do golpe | 3 a 5 amostras, uma camada, tocada no aperto (giro 0,3 s adiantado) | CF-03, CF-10 |
| Preparação do inimigo | último 0,5 s: tremor **e corpo clareando até 0,95** | tremor no segurar e luz localizada (lâmina, orbe, besta) | CF-06 |
| Elites | ataques diferentes (Guard duplo, Radiator rápido) e atributos | só armadura, velocidade, janela | CF-05 |
| Avisos de área | Radiator 1,5 s | corredor 0,7 s | CF-02 |
| Atiradores | orbes do Mage, curva não documentada | orbes que pegam no fim do voo, 33% do dano | CF-01 |
| Chefe | Hécate alterna golpes de perto em par (0,85/0,4/0,35 e 0,5/0,5/2,2), divisão, investida | fase 1 perto = foice repetida | CF-04 |
| Ritmo da sala | ritmos desencontrados entre tipos [I] | esperas fixas (215 f exatos) | CF-08 |

## As 10 melhorias de maior ganho por esforço

Ordem por ganho dividido por esforço. "Dado" = linha no `make_data.gd` e regerar; o resto é uma função.

| # | Melhoria | Dono sugerido | Esforço | Critério de aceite |
|---|---|---|---|---|
| 1 | **Orbe que pega cedo ou não pega** (CF-01): a curva do orbe só nos primeiros 0,8 s do voo (depois reto) ou `shot_turn` 40 para 20; orbe do elite 7 para 5 só se ainda passar | `gameplay-engineer` (dado e `Projectiles`) | pequeno | GUT: herói correndo de lado a 6,75 m/s a partir de 1,2 s de voo nunca é atingido; robô s1 a s4: feiticeiro abaixo de 35% dos golpes nas salas (hoje 60%); próxima sessão do PO: feiticeiro abaixo de 20% e aviso mediano dos orbes que acertam abaixo de 1,6 s |
| 2 | **Corredor com aviso legível** (CF-02): `attack_windup` 0,7 para 1,0 s (segurar 0,3 s com tremor) | `gameplay-engineer` (dado) | mínimo | sonda `enemy_motion_probe`: aviso x dano 0 a 1 f mantido; PO: corredor abaixo de 8% dos golpes; nenhum golpe com aviso abaixo de 0,9 s fora o golpe curto do Escudo |
| 3 | **Sopro no quadro da lâmina** (CF-03): campo `sound_at` no `ComboNode` (segundos depois do aperto; padrão 0), giro e lança com `windup - 0,05`; no aperto do giro fica só um som curto de carga | `gameplay-engineer` (dado + `Player`) | pequeno | registro `Audio.listen`: pico do sopro do giro e da lança a no máximo 2 f do quadro do acerto (hoje 16 a 20 f antes); golpes 1 e 2 sem mudança; sonda 40/40 |
| 4 | **Corpo acende no "vai bater"** (CF-06): no segurar, rampa do corpo mais claro e morno até `flash_cap` (abaixo do glow), além do tremor | `art-director` (números) e `gameplay-engineer` (`crowd.gdshader`, `Horde.render`) | pequeno | captura GPU a 1080 na distância 54 de um esqueleto, um Escudo e um feiticeiro no segurar: corpo lido como "vai bater" sem olhar o chão (art-director aprova); nenhum canal acima de 1,0; `test_enemy_windup.gd` com a rampa só nos últimos 30% |
| 5 | **Fase 1 de Morvath variada perto** (CF-04): segundo golpe de perto (o par da Hécate: golpe rápido e logo um lento com janela longa) ou as lâminas com um passo atrás a qualquer distância | Game Director decide; `gameplay-engineer` | médio | `boss_cadence` em 3 sementes: na fase 1 nenhum ataque acima de 50% e nunca 3 iguais seguidos; avisos e janelas com as mesmas regras do T5 (aviso x dano 0 a 1 f) |
| 6 | **Elite com golpe próprio** (CF-05): esqueleto elite com dois golpes a 0,2 s (Hades) e corredor elite com a explosão dupla; campos de dado (`strikes`, `strike_gap`) | `gameplay-engineer`; `art-director` aprova a pose do segundo golpe | médio | o elite usa o mesmo aviso cobrindo os dois golpes (aviso x dano 0 a 1 f nos dois); vídeo 0,25x no `enemy_lab`; um elite novo sem código |
| 7 | **Morvath não desliza parado** (CF-07): isolar quem o move nesses quadros e tocar o andar quando a lógica anda mais de 0,4 m/s, ou limitar a saída a `BodyBlock.EASE` | `gameplay-engineer` | pequeno | `boss_probe --probe-log` s1 a s5: 0 trechos de 3 f ou mais em `idle` com o corpo acima de 1 m/s (hoje 77) |
| 8 | **Espera sorteada** (CF-08): 0 a 0,4 s somados ao `AFTER_RECOVER` por inimigo e o Cavaleiro escolhendo a investida também de perto (recuando 2 passos) | `gameplay-engineer` (dado) | mínimo | `--play` s1 e s2: desvio padrão do intervalo entre golpes do mesmo esqueleto de 0,1 s ou mais (hoje 0); Cavaleiro investe pelo menos 1 vez a cada 4 golpes |
| 9 | **Segunda camada no golpe** (CF-10): passo ou esforço curto no quadro do acerto dos golpes 2, giro e lança, sorteado sem repetir | `gameplay-engineer` (áudio, `make_sfx.sh`) | pequeno | pico abaixo de -1 dBTP na mistura (`mix_probe`); 10 giros seguidos sem a mesma amostra duas vezes; PO ouve |
| 10 | **Golpe 1 sem espremer o clipe** (CF-09): começar o `Slash_A` mais perto do pico (`anim_from` 0,11) para tocar a 1,5x; corte da esquiva igual | `art-director` (pose no `pose_lab`), `gameplay-engineer` (`_move`) | pequeno | nenhum clipe de golpe acima de 1,5x; tempos da sonda iguais (E1c-P4 a P6); vídeo 60 qps a 0,25x aprovado |

## Pendências de medição

- Vídeo da GPU (60 qps, 1280x720) do herói nos golpes e de Morvath com som: `FPS=60 RES=1280x720 PRE="-s res://tools/feel_driver.gd" tools/movie.sh <saída C:/...avi> 720 --bot --start=miniboss --feel=hits --seed=3` e `--boss-only=scythe`; para o `qa-performance` quando a fila estiver livre.
- Uma sessão do PO com o executável (o `runs.jsonl` já registra `hurt_ctx`) depois das melhorias 1 a 4: é a única medida válida para inimigos de perto (CF-12).
- Instrumentação sugerida (barata, para o `gameplay-engineer`): no `RESULT` e no registro, por tipo de inimigo, preparações começadas, que chegaram ao golpe e cortadas; tempo de voo do tiro que acertou (separa CF-01 de "não viu"); `omega_charges_started` e `cancelled` (CF-13).
- Reavaliar e registrar em `docs/design/combat_cadence.md` depois de cada lote (este relatório não o altera).
