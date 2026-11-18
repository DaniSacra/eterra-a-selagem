# Cadência do combate (matriz e problemas)

Mantido pelo `combat-feel-director`. Cada ação vista como Preparação, Impacto (ativo), Recuperação e volta do movimento.
Regra do PO que prevalece sobre qualquer referência: **golpe básico do Guerreiro parado** (sem avanço, ímã nem
translação), golpe 1 rápido, 2 intermediário, 3 o mais lento, cada um com preparação, golpe e retorno visíveis.

Legenda das fontes: **[M]** medido (com FPS e fonte), **[D]** dado do jogo (arquivo citado), **[PO]** pedido do Daniel,
**[H]** estudo do Hades II (`docs/design/hades2_feel_study.md`, dados do jogo e vídeo do Daniel a ~29 qps reais),
**[I]** inferência nossa. "f" = quadro a 60 por segundo.

## 1. ANTES: versão 18b0785 (a que o Daniel jogou em 2026-11-16)

Como foi medido (nada disso entrou no jogo): worktree separado em 18b0785, Godot 4.7.2 sem tela com
`--fixed-fps 60` e um roteiro de entradas próprio (cópia do `tools/feel_driver.gd` que imprime por quadro posição,
estado, fase do `ComboRunner`, golpe, clipe tocando e `rooted` do herói, e os estados de cada inimigo e de Morvath).
Roteiros: herói na loja (`--start=shop`, golpe parado, golpe andando, golpes apertados a cada 0,1 s, especial andando,
Ômegas, círculo, esquiva); partida inteira com o robô (`--seed=7 --bot-reaction=0.25 --boons=3`); luta de Morvath
(`--start=boss --boons=5 --seed=5 --bot-reaction=0.25`). Poses assadas lidas direto dos `assets/baked/*.res`
(`BakedModel.pose`). Vídeos na placa de vídeo (Movie Maker, 60 qps, 1280x720) em `docs/gallery/e1c/cadence/before/`.

### 1.1 Guerreiro

Dados de `tools/make_data.gd` `_combos` (18b0785), gerados em `data/combos/paladin.tres`. A velocidade do clipe vem de
`_move`: `anim_speed = (PEAK - anim_from) / windup`, com `PEAK` Slash_A 0,23, Slash_B 0,27, Slash_C 0,67.

| Ação | Preparação | Impacto / ativo | Recuperação | Volta do movimento | Movimento durante | Som | Avaliação | Alvo recomendado |
|---|---|---|---|---|---|---|---|---|
| E1 (`cut1`, Slash_A) | [M] 4 f, 0,067 s ([D] `windup` 0,06) | [M] acerto no f4 | [M] fim no f12 (0,20 s; [D] `recovery` 8/60); clipe de 0,43 s tocado a **3,67x** desde 0,01 s: vira Idle no f13 | [M] parado: anda já no f5 (fim da preparação); andando: **clipe de corrida no f5**, o golpe aparece só 4 quadros | [M] **1,0 m de avanço** sem inimigo (`lunge` 1,0), deslizando por 55 f (0,92 s), 40 deles já no clipe Idle | [D] `blade` sintetizado no f0 (começo da preparação), sempre igual, sem variar tom (`audio.gd` linha 15) | Reprovado: rápido demais na ida (3,67x) e na volta (Idle no f13), anda e desliza | [PO] parado; [H] preparação 0,06 a 0,12 s, ataque livre +0,13 s, pernas presas +0,18 s (total 0,24 a 0,30 s); [I] 0,10 a 0,12 s pela queixa "rápido demais"; clipe a no máximo 1,5x |
| E2 (`cut2`, Slash_B) | [M] 7 f, 0,117 s ([D] 0,11) | [M] f7 | [M] fim no f20 (0,33 s); clipe a 2,0x | [M] andando: corrida no f8 | [M] 1,15 m (golpes apertados), 1,50 m andando ([D] `lunge` 1,2) | [D] `blade`, igual ao E1 | Reprovado: avança, pouca diferença para o E1 | [PO] parado; [H] preparação 0,11 a 0,16, ataque livre +0,22, pernas +0,32 (total 0,43 a 0,48 s) |
| E3 (`cut3`, Slash_C, giro) | [M] 22 f, 0,367 s ([D] 0,28 + brilho 0,08) | [M] f22 | [M] fim no f40 (0,67 s); clipe a 1,0x de 0,39 s | [M] andando: corrida no f23, logo depois do acerto (a recuperação do finalizador some) | [M] 0,80 m parado, 1,62 m andando ([D] `lunge` 0,8) | [D] `blade_spin` no f0: **0,37 s antes do impacto** | Reprovado: avança; recuperação some andando; som fora do golpe | [PO] parado; [H] preparação 0,36, ativo 0,1 a 0,3, ataque livre +0,30, pernas +0,50 (total 0,86 s) |
| Cadência E1 para E2 para E3 (apertando a cada 0,1 s) | | | | [M] E1 para E2 0,20 s; E2 para E3 0,33 s; E3 até o próximo 0,67 s | [M] 2,81 m somados sem inimigo | | Razão 1 : 1,7 : 3,3, mas tudo curto demais | [H] 0,27 s e 0,53 s (vídeo), ciclo 0,19 / 0,33 / 0,66 s |
| D (`bolt`, especial) | [M] 7 f, 0,117 s ([D] 0,1) | [M] f7 (a onda sai) | [M] fim no f25 (0,42 s); clipe Cast de 0,5 s até o f30 | [M] pernas presas 0,71 s (43 f) desde o acerto ([D] `root_time` 0,71) | [M] 0 m/s preso, **mas com a direção segura o clipe Run toca do f8 ao fim da trava**: corre parado no lugar por 0,71 s | [D] `dart` no f0 | **Reprovado (P0): patinação** | [H] 0,71 s preso com o clipe do disparo e depois o do retorno, nunca o de correr; mistura de 11 f para a corrida |
| Ômega do ataque (`lance`) | [M] começa 0,65 s depois do aperto, acerta 0,80 s depois ([D] `charge_time` 0,8) | [M] f9 do golpe | [M] fim no f45 (0,75 s); clipe Sword_Attack de 1,53 s cortado no f46 | [M] parado | [M] 0 m | [D] `thrust` no começo, `charge_up` aos 0,12 s de carga | Aceitável no tempo; o clipe é cortado ao meio | [H] carga 0,8 a 3% de velocidade, depois 0,78 s sem andar nem atacar |
| Ômega do especial (`burst`) | [M] começa 0,57 s depois do aperto, acerta 0,65 s ([D] 0,65) | [M] f5 | [M] fim no f32 (0,53 s) | [D] **sem `root_time`**: pernas livres no fim | [M] 0 m | [D] `dart` | Diferente do especial comum | [H] as mesmas 0,71 s de pernas presas do especial |
| Círculo (`cast`) | [M] solto 0,25 s depois do toque ([D] `cast_charge`), Ômega 0,58 s segurando | [M] zona no chão ao soltar | [D] 8 f sem golpe (`cast_attack_lock`) | [M] anda durante (`cast_slow`) | [M] 0 m parado | [D] receita do círculo | **O herói não tem animação**: fica no Idle o tempo todo | [I] um gesto curto de 0,25 s (ergue a Emeth) para o círculo e um mais longo no Ômega |
| Esquiva | [M] sai no quadro seguinte ao aperto | [M] 13 f, cerca de 5,5 m ([D] 0,2 s) | [M] nenhuma: corrida a 6,75 m/s no f14 | [M] imediata | [M] 36 m/s caindo a 19 m/s | [D] `dodge` | Bom no tempo; sem mistura para a corrida | [H] 0,2 s, 5,6 m, mistura curta |

Entrada involuntária (P0, confirmada): com 18b0785, um clique esquerdo do mouse na tela de título (o mesmo botão do
ataque) seguido de "Iniciar" faz o Guerreiro dar o `cut1` sozinho **68 quadros depois** de a partida começar; sem o
clique, nenhum golpe em 600 quadros (roteiro `cfd_leak`, sem tela). Causa: `Controls._process` (autoload com
`PROCESS_MODE_ALWAYS`) guarda todo `just_pressed` em `_latched` em qualquer tela, e só o `Game` limpa (`flush`, linha 402
do `game.gd`) quando dá um passo; o clique do título fica guardado até o primeiro passo da partida.

### 1.2 Inimigos comuns e elites (ataque principal)

Dados: `_enemies` do `tools/make_data.gd` (18b0785), gerados em `data/enemies/*.tres`. Medido na partida do robô
(60 f/s, 6 salas e Morvath): "completa" = preparação que chegou ao golpe.

| Inimigo | Preparação | Impacto / ativo | Recuperação (espera até o próximo) | Volta do movimento | Movimento durante | Som | Avaliação | Alvo recomendado |
|---|---|---|---|---|---|---|---|---|
| Esqueleto (`skeleton`) | [D] 0,9 s; [M] 0,90 (3 completas de 15; 12 cortadas pelo atordoamento) | [M] ataque 0,27 a 0,33 s (investida 700/80 m/s por 0,3 s) | [D] `attack_cooldown` 1,4 | [M] uma preparação nova a cada 0,75 s (mediana) depois de cortada | [D] investida cerca de 2,6 m | [D] som de preparação `tell` lâmina | Cortado o tempo todo: ergue a lâmina, leva golpe, ergue de novo (hipótese de "estranho") | [H] Guard: 0,9 s andando e mirando, golpe 0,3, **2,1 s** de janela depois |
| Corredor (`runner`) | [D] 0,7 s | [D] explosão em volta, 1,6 m | [D] 1,4 | pendente (nenhuma completa na partida) | 0 | [D] brasas | pendente | [H] Radiator: 1,5 / 1,6 / 1,35 |
| Feiticeiro (`mage`) | [D] 1,0; [M] 1,00 (4 completas) | [M] rajada 0,57 s (3 orbes a 0,17 s) | [D] 0,8 + 1,85 | anda depois | [D] recua 5 m/s por orbe | [D] orbe | Coerente com o Hades | [H] 1,0 / 3 orbes / 0,7 a 0,9 |
| Besteiro (`archer`) | [D] 0,8; [M] 0,80 (9 completas) | [M] 0,42 s | [D] 1,8; foge 1,5 a 1,75 s | | | [D] besta | Coerente | [H] Screamer: 1,2 / cone / 0,6 e recua |
| Escudo (`guard`) | [D] 1,15 (clipe `brace`) | [D] carga 15 m/s por 0,4 s (6 m); golpe curto com 0,65 de preparação | [D] 1,9 | [M] **nenhuma das 11 preparações chegou ao golpe** (todas cortadas pelos golpes do robô) | | [D] escudo | O papel de bloquear sumiu: nunca carrega | [H] Brawler: 1,15 / carga 4,9 m / emenda golpe curto / 1,1 s |
| Sacerdote (`priest`) | [D] 0,8 | [D] trepadeira 1,9 m/s por 12 s | [D] 3,25 | parado | 0 | [D] ritual | pendente (não apareceu) | [H] SiegeVine igual |
| Elites (todos) | [D] mesmas preparações; armadura (80 a 330) impede o atordoamento até quebrar | | [D] mago elite 0,8 + 1,0 | | [D] mais rápidos | | pendente de medição própria | [H] Guard elite: dois golpes a 0,2 s, 1,5 s |
| Cavaleiro (guardião `knight`) | [D] 1,0 (perto 0,8); [M] 0,80 (mediana de 3) | [M] 0,53 a 0,57 s; [D] carga 18 m/s por 0,7 s | [D] 3,2 | [M] 3,4 a 6,1 s entre preparações | | [D] armadura | pendente de vídeo | [I] manter a janela longa |
| Ancião (guardião `priest_elder`) | [D] 1,0 | [D] leque de 5 orbes | [D] 3,4 | | | | pendente | |

A auditoria dos inimigos comuns do qa-performance (`docs/gallery/e1c/enemies/AUDIT.md`) ainda não existia quando esta
matriz foi escrita; cruzar quando sair.

### 1.3 Morvath

Dados: `_bosses` do `tools/make_data.gd` (18b0785) em `data/bosses/morvath.tres`. Medido na luta do robô (60 f/s), fases 1 a 4
até a morte. **Nenhum salto de posição lógica**: o maior passo entre quadros ficou abaixo de 12 m/s em 8533 quadros
(nenhuma investida saiu nessa luta). O "some e reaparece" está no desenho, não na lógica (ver P0-3).

| Ataque | Preparação | Impacto / ativo | Recuperação | Volta do movimento | Movimento durante | Som | Avaliação | Alvo recomendado |
|---|---|---|---|---|---|---|---|---|
| Foice Sepulcral (`scythe`) | [D] `scythe_windup` 0,8, aproximação 1,2 m; [M] anda 7 a 45 f e depois `slash3` 53 a 61 f | [D] meio círculo de 5 m | [D] 1,0; [M] 51 a 55 f ainda no `slash3` | [M] volta ao Idle ou à caminhada | [M] 1,2 a 4,1 m de caminhada antes do golpe | pendente | **Reprovado (P0)**: o clipe `slash3` leva o corpo desenhado 1,41 a 2,94 unidades à frente (vezes `size` 2,53 = **3,6 a 7,4 m**); entra adiantado 3,6 m num quadro e volta de uma vez no fim | [H] golpes de perto da Hécate 0,85 / 0,4 / 0,35 e 0,5 / 0,5 / 2,2 s; desenho sempre sobre a posição lógica |
| Lâminas das Almas (`blades`) | [D] 0,7; [M] 41 f no clipe `dash_windup` (o preparo da investida) | [D] meias-luas a 11 m/s | [D] 0,8; [M] `slash2` 29 f + Idle 19 f | | [M] 0 m | pendente | Reprovado: o arremesso (`slash2`) toca **depois** de as lâminas saírem, e o `slash2` também começa 0,98 x 2,53 = 2,5 m adiantado | [I] pico do arremesso no quadro em que as lâminas saem (±3 f) |
| Maldição (`curse`) | [D] 0,8; [M] 47 a 51 f no clipe `summon` | [D] projétil 7 m/s | [D] 0,6; [M] `volley` 22 f na recuperação | | [M] 0,7 a 0,8 m | pendente | O arremesso (`volley`) toca **depois** do tiro | [I] o mesmo: pico do arremesso no tiro |
| Erupções | [D] aviso 1,2 s; [M] `rain` 167 a 209 f | [D] círculos de 4 m em 2 sequências | [D] 0,8; [M] Idle 47 a 51 f | | [M] 0,9 a 3,2 m | pendente | Coerente no tempo; pendente de vídeo | |
| Invocação | [D] `summon_windup` 1,1; [M] `summon` 93 a 96 f | runas | [M] 29 a 31 f + Idle | | [M] 0,6 a 1,8 m | pendente | pendente de vídeo | |
| Investida (`dash`) | [D] 0,8 | [D] 16 m em 0,42 s | [D] 1,1 | | | pendente | **pendente** (não saiu na luta medida; precisa `--boss-only=dash`) | [H] Hécate: 0,25 / 0,13 s / 0,27 |
| Tempestade das Seis Almas (fase 4) | [D] 0,9 por onda; [M] `rain` 50, `volley` 24, `roar` 61 f, duas ondas | [D] 6 meias-luas | [D] 1,2; [M] `roar` 44 a 47 + Idle 28 f | | [M] 1,2 a 2,3 m | pendente | pendente de vídeo | |
| Rugido e ida ao meio (troca de fase) | [M] `roar` 99 a 106 f, depois anda 32 a 71 f | [D] empurrão 4 m | | | | pendente | Coerente | |
| Ritual (fase 2) | [M] 757 f (12,6 s) | | [M] atordoado 123 a 163 f depois | | | | Coerente | |

Poses assadas com deslocamento de raiz (centro da figura afastado da posição lógica, em unidades do modelo, antes do
`size`): todos os inimigos ficam abaixo de 0,45 em todo clipe que não é morte; Morvath `slash1` até 1,13, `slash2` 0,98 a
1,26, **`slash3` 1,41 a 2,94**. Os outros clipes de Morvath ficam abaixo de 0,45.

### 1.4 Morvath depois da E1c e na E2 (gameplay-engineer, 2026-11-16)

Medido com `tools/boss_cadence.gd` (estados do `Boss` quadro a quadro, 60 qps fixos, sem tela): luta do robô com
`--start=boss --boons=5 --bot-reaction=0.25`, sementes 1, 3 e 5, e a investida à parte (`--boss-only=dash --bot-kite=0.6`,
56 investidas). "Estado do ataque" = do começo do ataque ao começo da recuperação (aproximação, preparo e ativo);
"Punida" = recuperações em que o paladino o acertou. Depois da E1c os arremessos (lâminas, maldição) já soltam no quadro
do tiro e os golpes ficam no lugar (P0-3 e P1-5 resolvidos). Números da E2 em `docs/qa/e2_morvath.md`.

| Ataque | Fases | Preparo [D] (fase 1 / 3 / 4) | Estado do ataque [M] (mediana) | Ativo [D] | Recuperação = janela [D] / [M] | Descanso depois [M] (fases 1 / 2 / 3 / 4) | Punida [M] | Camada E2 |
|---|---|---|---|---|---|---|---|---|
| Foice Sepulcral | 1 a 4 | 0,8 / 0,76 / 0,72, mais até 1,2 s de aproximação | 1,16 s (0,96 a 2,19) | varredura 0,16 s | 1,0 / 0,84 (mais a varredura) | 1,11 / 1,01 / 0,62 / 0,37 | 48 de 58 | erupções desde a fase 3 |
| Lâminas das Almas | 1 a 3 | 0,7 / 0,67 / - | 0,71 s | meias-luas a 11 m/s, 26 m | 0,8 / 0,80 | 1,12 / 1,00 / 0,63 | 9 de 10 | mortos (esqueleto e feiticeiro) na fase 3 |
| Investida | 1 a 4 (de 9 m) | 0,8 / 0,76 / 0,72 | 1,23 s (preparo + 0,42 de corrida) | 16 m em 0,42 s | 1,1 / 1,10 | 1,12 / 1,00 / 0,62 / 0,42 | 50 de 56 | - |
| Erupções | 2 a 4 | aviso 1,2 / 1,14 / 1,08, duas levas a 1,0 s | 3,41 / 3,28 / 3,17 s | círculos de 4 m | 0,8 / 0,80 | - / 1,01 / 0,62 / 0,37 | 13 de 14 | - (na fase 4 a foice pode vir depois) |
| Invocação | 2 a 4 | 1,1 + 0,45 entre mortos | 1,56 s | 2 esqueletos | 0,8 / 0,81 | - / 1,01 / 0,62 / 0,42 | 9 de 10 | - |
| Maldição | 3 e 4 | 0,8 / 0,76 / 0,72 | 0,77 / 0,73 s | projétil a 7 m/s, segue 1,4 s | 0,6 / 0,60 | - / - / **3,1 a 3,4** / 0,4 a 3,4 | 5 de 8 | erupções e mortos quando o projétil sai |
| Tempestade das Seis Almas | 4 | 0,81 por onda, 0,08 entre meias-luas, 1,0 entre ondas | **5,72 s** (3 ondas; antes 3,48 com 2) | 6 meias-luas por onda | 1,2 / 1,21 | 0,37 a 0,42 | 2 de 3 | erupções e mortos com a 1ª onda |
| Rugido (troca de fase) | | 1,6 s | | empurrão 4 m | | | | |

Leitura:
- Antes da E2 o robô punia 70 a 90% das recuperações e quase só se feria nas fases 3 e 4; os ataques da fase 1 não o feriram em
  nenhuma das 8 lutas medidas (foice, lâminas e investida: 0 de vida tirada). A foice (48 de 58 janelas punidas) é o ritmo da luta: preparo de 0,8 s, varredura de
  0,16 s e 0,84 s de janela, parecido com os golpes de perto da Hécate do Hades (0,85 / 0,4 / 0,35 e 0,5 / 0,5 / 2,2).
- **Folga medida na fase 3**: depois da maldição ele espera 3,1 a 3,4 s (não escolhe outro ataque com um tiro dele no
  ar, `Boss._shots_flying`, e o projétil vive 4 s). A E2 enche essa espera com as erupções e os mortos postos quando o
  projétil sai, em vez de encurtar o tempo de vida do projétil.
- Descansos da E2: fases 3 e 4 de 0,9 e 0,75 para 0,6 e 0,4 s. Nas fases 1 e 2 ficaram (1,1 e 1,0): descansos menores ali
  deram mais janelas ao robô e encurtaram a luta sem feri-lo mais (`docs/qa/e2_morvath.md`, tentativas descartadas).

## 2. Problemas priorizados (ANTES, 18b0785)

| Id | Prioridade | Problema | Causa | Confirmada? |
|---|---|---|---|---|
| P0-1 | P0 | Golpe sozinho ao começar a partida | `Controls._latched` guarda cliques em qualquer tela (título incluído) e só a partida limpa | **Confirmada**: reproduzida (clique no título = `cut1` aos 68 f; sem clique, nada) |
| P0-2 | P0 | Patinação depois do D | `Player._show` só segura o clipe enquanto `is_swinging` (preparação); com `rooted` e a direção segura toca `Run` parado | **Confirmada**: 43 f de `Run` a 0 m/s depois de cada especial andando |
| P0-3 | P0 | Morvath some e reaparece, "todo bugado" | Clipes `slash1/2/3` assados com deslocamento de raiz (até 7,4 m em jogo); corpo desenhado longe da posição lógica e de volta num quadro | **Confirmada** nos dados (poses assadas) e no vídeo: `morvath_scythe_frames.jpg` (10 qps, 7,6 a 9,2 s do `morvath_scythe_1x.mp4`), entre 0,1 e 0,2 s o corpo salta do selo para fora do semicírculo de aviso e o arco da foice corre a metros dele |
| P1-1 | P1 (regra do PO) | Herói anda ao golpear | `lunge` 1,0 / 1,2 / 0,8 no `_combos` e `LUNGE_DECAY` deslizando 0,9 s; andar corta a recuperação (`Player.step`, ramo "after the blow lands") | Confirmada (1,0 m parado, 2,8 m no combo, até 2,6 m andando) |
| P1-2 | P1 | E1 rápido demais na ida e na volta; 1, 2 e 3 pouco distintos | Clipe Slash_A a 3,67x e Slash_B a 2,0x (`_move`); recuperação de 8 e 13 f; corrida volta no fim da preparação | Confirmada |
| P1-3 | P1 | Som de "pacman" no E repetido | Uma receita sintetizada só (`blade`: ruído varrendo de 1800 para 5200 Hz em 0,09 s), mesmo tom sempre, sobre o impacto 4 f depois | Causa do som confirmada; a percepção "pacman" é hipótese (varredura subindo, idêntica, a cada 0,2 s) |
| P1-4 | P1 | Som do finalizador fora do golpe | `ComboNode.sound` toca no começo da preparação: no E3, 0,37 s antes do impacto | Confirmada |
| P1-5 | P1 | Arremessos de Morvath depois do tiro | Lâminas e Maldição: o clipe do arremesso está na `RECOVER` | Confirmada no registro de estados |
| P1-6 | P1 | Inimigos "estranhos" | Hipóteses: esqueleto erguendo e baixando a lâmina a cada 0,75 s (12 de 15 preparações cortadas); Escudo nunca carrega (11 de 11 cortadas); janela depois do golpe 1,4 s contra 2,1 do Hades | Hipótese (aguarda o `AUDIT.md` e vídeo) |
| P1-7 | P1 | Círculo sem gesto do herói | Nenhum clipe no `cast` | Confirmada |
| P2-1 | P2 | Ômega do especial sem trava de pernas | `burst` sem `root_time` | Confirmada nos dados |
| P2-2 | P2 | Clipes cortados no meio (Slash_C de 2,0 s, Sword_Attack de 1,53 s) e troca seca para Idle ou Run | `_play` sem mistura na volta | Confirmada |
| P2-3 | P2 | Esquiva para corrida sem mistura | `_show` | Confirmada |

## 3. Recomendações e critérios de aceite

Cada critério é medido com o mesmo roteiro (60 f/s fixos, sem tela) e confirmado num vídeo na placa de vídeo a 0,25x.

**P0-1 Entrada involuntária.** Só guardar apertos enquanto a partida está em `PLAY` e limpar o guardado ao entrar na
partida, ao abrir e ao fechar qualquer tela (título, dom, loja, pausa, fim); um clique consumido por um botão da
interface nunca vira golpe. Aceite: clique esquerdo no título e depois "Iniciar" = 0 golpes nos primeiros 600 f;
escolher um dom com o mouse = 0 golpes nos 30 f depois de a tela fechar; o mesmo com o botão do controle; teste GUT.

**P0-2 Especial sem patinar.** Enquanto `rooted > 0`: velocidade zero, entrada de movimento ignorada (não guardada) e
o corpo no clipe do disparo e depois no do retorno, nunca `Run` [H]. A corrida só começa quando a trava acaba, com
mistura de 0,18 s (11 f) [H]. Aceite: 0 quadros com clipe `Run` ou `Sprint` com velocidade abaixo de 1 m/s e direção
segura, no especial, no Ômega do especial, nos golpes e no círculo; volta do movimento 0,71 s depois do disparo
(±1 f), só a esquiva corta antes.

**P0-3 Morvath no lugar.** Tirar o deslocamento de raiz no assado dos golpes de Morvath (o centro da figura não passa
de 0,45 unidades em nenhuma pose, como os outros clipes), ou mover a posição lógica junto se o avanço for desejado (aí
o aviso no chão e o acerto acompanham). Aceite: centro de toda pose de todo clipe de Morvath a no máximo 0,45 do
centro; na troca de clipe o centro desenhado não salta mais que 0,3 m em jogo entre dois quadros; vídeo de 3 foices,
3 lâminas e 1 investida (`--boss-only=`) a 0,25x sem nenhum quadro em que ele desapareça ou reapareça.

**P1-1 Golpe parado (regra do PO).** `lunge` 0 nos três golpes; a mira gira o golpe para o inimigo mais perto (o
`AutoLock` do Hades, 4,9 a 6,1 m em 130 graus [H]) em vez de levar o corpo. Aceite: do aperto ao fim da trava, o herói
anda no máximo 0,02 m nos golpes 1, 2 e 3, com e sem inimigo à frente, com e sem direção segura; a sonda deixa de
exigir avanço (`E1b-L35` vira "não avança").

**P1-2 Cadência 1, 2, 3.** Alvo (segundos depois do aperto; [H] com a ponta de cima pela queixa do [PO]):

| Golpe | Preparação (impacto) | Ataque livre | Pernas presas até | Clipe |
|---|---|---|---|---|
| E1 | 0,10 a 0,12 | impacto + 0,13 | impacto + 0,18 (total 0,28 a 0,30) | no máximo 1,5x, retorno visível até o fim da trava |
| E2 | 0,14 a 0,16 | impacto + 0,22 | impacto + 0,32 (total 0,46 a 0,48) | no máximo 1,3x, outro arco |
| E3 | 0,36 (com o brilho) | impacto + 0,30 | impacto + 0,50 (total 0,86) | 1,0x, preparação com o corpo carregando |

Andar não corta a trava (só a esquiva corta), e na trava toca o retorno do golpe, nunca a corrida [H]. Aceite: os
tempos acima com ±1 f; E2/E1 entre 1,4 e 1,8 e E3/E1 entre 2,8 e 3,4 no tempo total; nenhum clipe de golpe acima de
1,5x; nenhum `Run` antes do fim da trava.

**P1-3 e P1-4 Som da espada.** Arquivos com pelo menos 5 variações por golpe, sorteio sem repetir a anterior, tom
±4% [I a partir do H], duas camadas no disparo (lâmina e esforço ou passo) [H]; o sopro sai quando a lâmina começa a
varrer (no impacto menos 1 a 2 f), não no começo da preparação; no E3 um sopro próprio maior. Aceite: em 10 E seguidos
nenhuma amostra repete duas vezes seguidas; o sopro do E3 a no máximo 2 f do início da varredura; pico abaixo de -1 dBFS;
o Daniel ouve e não chama de "pacman".

**P1-5 Arremessos de Morvath.** O pico da mão do arremesso (`tools/clip_probe.gd`) cai no quadro em que as lâminas e a
maldição saem (±3 f); a preparação das lâminas com um clipe próprio, não o preparo da investida. Aceite por registro
de estados e vídeo a 0,25x.

**P1-6 Inimigos.** Esperar o `AUDIT.md`. Proposta para medir: depois de uma preparação cortada, uma espera mínima
antes de preparar de novo (o fim do atordoamento mais 0,3 a 0,5 s [I]) e a janela depois do golpe do esqueleto em 2,1 s
[H]; o Escudo deve chegar a carregar pelo menos às vezes contra o robô com reação humana. Aceite: em uma partida do
robô (`--bot-reaction=0.25`), pelo menos 40% das preparações do Escudo chegam ao golpe e nenhum esqueleto reergue a
lâmina antes de 0,6 s depois do atordoamento.

**P1-7 Círculo.** Gesto curto do herói (erguer a Emeth) durante os 0,25 s até soltar, e um gesto mais longo no Ômega.
Aceite: clipe próprio no `cast`, nenhum `Idle` do aperto ao soltar.

**P2.** Ômega do especial com a mesma trava de 0,71 s [H]; misturas de 4 a 10 f do retorno dos golpes e da esquiva
para a corrida [H]; clipes longos (Slash_C, Sword_Attack) terminando no retorno, não cortados secos.

## 4. Evidências

- Vídeos do ANTES: `docs/gallery/e1c/cadence/before/` (`hero_actions_1x.mp4` com todas as ações do roteiro na loja;
  `hero_combo_mash_025x.mp4`, `hero_combo_walking_025x.mp4`, `hero_special_walking_025x.mp4` recortados no herói a
  0,25x; `morvath_scythe_1x.mp4`, `morvath_scythe_025x.mp4` e `morvath_scythe_frames.jpg`, foice com `--boss-only=scythe`). No vídeo do herói os
  primeiros toques do roteiro (E parado e E andando, 1,0 e 2,7 s) caíram antes de ele entrar na sala; os golpes
  apertados começam aos 4,5 s do vídeo.
- Registros por quadro e scripts de medição: fora do repositório (worktree descartável).

## 5. Histórico

- 2026-11-16: matriz criada com o ANTES (18b0785). Aguarda o DEPOIS das correções da E1c.
- 2026-11-16 (E2): seção 1.4, Morvath medido depois da E1c e com as camadas da E2 (`tools/boss_cadence.gd`).
- 2026-11-17 (T5): seção 6, preparação física, tremor no andar e corrida dos esqueletos, sincronia do dano com o corpo
  (inimigos e Morvath), medidos em `5dfe97f`; relatório `docs/qa/t5_enemy_motion.md`. Aguarda as correções T5-01 a T5-19.
- 2026-11-17 (T5, revisão): DEPOIS em `24c298e` medido na CPU com os mesmos roteiros e sementes (seção 6.7); T5
  aprovado com ressalvas, T5-11 fora do critério, T5-20 novo (P1).

## 6. T5: o corpo prepara o golpe (ANTES em `5dfe97f`, especificação)

Relatos do PO: (1) P0 "mostram o aviso vermelho, mas não parecem preparar fisicamente o ataque"; (2) P1 "o esqueleto
da primeira sala anda tremendo"; (3) P1 "os esqueletos invocados correm como uma gazela". Medição, causas e números
por figura: `docs/qa/t5_enemy_motion.md`; quadros e dados: `docs/gallery/t5/motion/before/`.

### 6.1 Padrão obrigatório (PO) e como medir

Toda ação inimiga é **APROXIMAÇÃO, PREPARAÇÃO, ATAQUE, RECUPERAÇÃO**:

- **Aproximação**: o andar no ritmo da velocidade real (já feito na E1c); para ou muda o andar ao entrar na preparação.
- **Preparação em três tempos**, todos medidos a partir do primeiro quadro do estado `WINDUP`:
  1. *assentar* (0,10 a 0,15 s): o corpo para, os pés plantam, mistura do andar para a guarda de combate;
  2. *armar* (até 70% da preparação): o corpo carrega o golpe com o clipe da antecipação, acelerando e desacelerando
     (o braço sobe, o tronco gira ou recua, o quadril baixa; o pesado mais lento e mais fundo);
  3. *segurar* (os últimos 30%, no máximo 0,5 s, como o "vai bater" do Hades [H]): a pose no alto, com o tremor do
     `windup_shake` e o pico do `EnemyFx.ramp`; nunca uma pose de `idle`.
  O aviso no chão começa no primeiro quadro da preparação e enche até o **quadro do dano** (não até o fim da
  preparação, quando o dano sai depois).
- **Ataque**: o golpe sai no quadro em que a preparação termina; o **dano sai do corpo** (lâmina, escudo, explosão) no
  quadro em que o desenho bate, com o som de impacto nesse quadro (o sopro no começo do ataque, como hoje).
- **Recuperação**: a janela parada do Hades, mas **viva**: o resto do golpe e a volta à guarda, nunca a última pose
  segurada mais de 0,3 s.

Medidas e critérios (mesma sonda e mesmo índice da medição do ANTES; propostos como teste GUT
`tests/test_enemy_windup.gd` e ferramenta `tools/enemy_motion_probe.gd`, a partir de
`docs/gallery/t5/motion/before/data/t5_probe.gd.txt` e `pose_metrics.gd.txt`):

| Medida | Como | Critério |
|---|---|---|
| Movimento da preparação | pico da velocidade média dos vértices do clipe desenhado na preparação, tamanho 1 (`pose_metrics`) | **1,0 m/s ou mais** em todo inimigo e elite (hoje 0,01 a 0,30, menos Escudo 0,62 e sacerdote 2,77) |
| Pose armada | distância média dos vértices entre a pose final da preparação e a da guarda | 0,30 m ou mais (tamanho 1) |
| Pose parada na preparação | maior trecho com pico abaixo de 0,1 m/s, sem contar o *segurar* com tremor | 0,3 s no máximo |
| Recuperação | maior trecho com a mesma pose desenhada em `RECOVER` | 0,3 s no máximo (hoje 1,76 s no esqueleto) |
| Dano x corpo | no quadro do dano, distância do herói ao contorno do corpo (investida) ou ao alcance da lâmina (golpe) | dentro do alcance em 100% dos casos (hoje até 2,4 m no esqueleto, 3,5 m no Escudo, 15,7 m em Morvath) |
| Aviso x dano | quadro em que o aviso termina de encher x quadro do dano | 0 a 1 f |
| Vídeo | `tools/movie.sh` a 60 qps, 0,25x, um de cada tipo; o PO reconhece o golpe pela pose sem olhar o chão | aprovação do art-director e do PO |

### 6.2 Problemas T5 (classificação)

| Id | Classe | Problema | Causa | Confirmada? |
|---|---|---|---|---|
| T5-P1 | **P0** | Preparação sem corpo: corredor, feiticeiro, besteiro, ancião, investida do Cavaleiro e preparação de Lâminas e Investida de Morvath com laços quase parados (pico 0,01 a 0,14 m/s); esqueleto só com o braço (0,30) | clipes `windup`/`cast`/`aim`/`dash_windup` em `tools/bake.gd` `MODELS` são `idle` de outra coisa; Cavaleiro pede `idle` (`horde.gd` `_behave_knight`) e não tem `brace` | **Confirmada** (poses assadas e quadros `lab_*_side.jpg`, `sheet_windups_*.jpg`) |
| T5-P2 | **P0** | Dano antes do corpo chegar nas investidas: Escudo e Cavaleiro no último quadro da preparação (corpo a 3,5 m, chega 13 f depois); Morvath com o corpo a até 15,7 m | o dano é o `power` do aviso em linha (`ground.add_line_warning(..., dano)`) que aterra no fim da preparação | **Confirmada** (`st_guard.csv.gz` f130 a 145, `morvath_dash2.txt` f723) |
| T5-P3 | P1 | Bote do esqueleto fere a até 2,4 m do corpo (alcance da lâmina cerca de 1,4 m em jogo) | aviso em linha de 4,1 m que aterra 0,15 s dentro do bote | Confirmada (`cycles.txt`, `dland 2.43`) |
| T5-P4 | P1 | Esqueleto que espera treme (gira 20 graus por quadro, vai e volta, pisca andar/parado) | espera em círculo para fora abaixo de 2,2 m; `straight` alternando em `WAY_NEAR` 1,2 m (campo de fluxo para dentro); `FACE_SPLIT` sem histerese a 1200 graus/s; `idle` de 1 quadro; `_separate` a cada 2 quadros | **Confirmada** (`jitter_r1i_s2.txt`, f600 a 642) |
| T5-P5 | P1 | Corrida "gazela" do esqueleto (comum, elite, invocados) | `Running_B` com `SOLDIER_RUN` (`stride` 0,68, `lift` 0,5): pés no ar em 16 de 20 poses, tronco a 3 a 5 graus, pé de trás até 29 cm | **Confirmada** (`walk_metrics`, `skeleton_run_side_24f.jpg`) |
| T5-P6 | P1 | Recuperação congelada: esqueleto 1,76 s (elite 1,16), Escudo 1,1 s, Cavaleiro 0,8 s na última pose | `RECOVER` segura `blow_t` no fim do clipe (`Horde.render`); o clipe acaba 0,34 s depois | Confirmada |
| T5-P7 | P1 | Tiro sem gesto: o feiticeiro elite solta 7 orbes parado na última pose do tiro por 1,4 s; tiros com pico 0,3 a 0,7 m/s | `Spell_Simple_Shoot` tocado uma vez por rajada | Confirmada |
| T5-P8 | P1 | Foice de Morvath fere no quadro do alto, 10 f antes de a lâmina descer | o aviso aterra em `_t - _mark >= windup` e a descida (`SCYTHE_SWEEP`) vem depois | Confirmada (`morvath_scythe.txt`) |
| T5-P9 | P1 | Lâminas e Investida de Morvath com a mesma preparação, parada | os dois tocam `dash_windup` (`2H_Melee_Idle`) | Confirmada |
| T5-P10 | P1 | Investida do Escudo desenhada com o golpe de espada do meio do clipe `attack` | `Horde.render` toca `attack` desde `IMPACT_SHARE` quando o tipo não tem `windup` | Confirmada (`st_guard` f131 a 155: `attack:9` a `:15`) |
| T5-P11 | P2 | Corredor: preparação agachada parada e golpe de soco para frente para uma explosão em volta; dano antes do soco | clipes `Crouch_Idle` e `Punch_Cross` | Confirmada |
| T5-P12 | P2 | Maldição de Morvath usa o mesmo gesto do invocar; 2ª leva das erupções parada 1,1 s | `summon` na maldição; `rain` acaba na 1ª leva | Confirmada |
| T5-P13 | P2 | Besta sobe ao ombro em 0,1 s (a mistura) e o disparo quase não recua | `aim` sem subida; `Pistol_Shoot` 0,48 m/s | Confirmada |
| T5-P14 | P2 | Posição alterna 3 cm quadro a quadro com corpos encostados | `_separate` em quadros alternados | Confirmada |

### 6.3 Especificação P0

**T5-01 Preparação em três tempos no desenho (todas as figuras, `horde.gd` `render`, dados no `EnemyDef`).**
Campo novo `windup_hold` (parte do fim que segura, padrão 0,3) e o tempo de assentar `windup_settle` (padrão 0,12 s);
no `WINDUP` com clipe próprio de preparação (assado só até o alto do golpe), desenhar
`t = duração_do_clipe * suave((state_t - assentar) / (prep * (1 - hold) - assentar))` com `suave` = subida e descida
(smoothstep), 0 durante o assentar (a mistura de `CLIP_FADE` faz o andar virar guarda) e 1 no segurar. O tremor
`windup_shake` só no segurar (hoje dura a preparação toda): esqueleto 0,025 m, corredor 0,04, Escudo e Cavaleiro 0,03,
atiradores 0. Conteúdo é dado: tudo no `_enemies` do `make_data.gd`.

**T5-02 Esqueleto (e elite e invocados).** `windup`: `ual:Sword_Attack` de **0,00 a 0,35 s** (a mão sobe de 1,14 a
1,79 m em tamanho 1, o alto em 0,35 s; `clip_probe`), 10 poses, com `bend` do tronco: coluna para trás e girada para o
lado da espada (valor inicial `Spine01` -10 graus em X e 15 em Y, quadril baixando uns 5 cm; ajustar no
`tools/pose_lab.gd` e o art-director aprova). Tempos na preparação de 0,9 s: assentar 0 a 0,12, armar 0,12 a 0,63,
segurar 0,63 a 0,90. `attack`: `Sword_Attack` de 0,35 a 1,20 s, a 1,4x (a descida de 0,35 a 0,50 s cai em 0,00 a
0,11 s do ataque). Alternativa para o art-director comparar: `kaykit:1H_Melee_Attack_Chop` (antecipação própria até
0,49 s, o alto em 46% do clipe, o golpe em 56%). Aceite: pico de movimento da preparação 1,0 m/s ou mais, pose
armada com a lâmina acima da cabeça (alto da figura 2,1 m ou mais em tamanho 1; hoje 2,07 só no fim).

**T5-03 Feiticeiro, ancião (e elite).** `windup` próprio: `ual:Spell_Simple_Enter` (0,53 s, o cajado subindo) no
armar, `Spell_Simple_Idle` só no segurar (com o orbe crescendo pelo `EnemyFx`). Ancião: o mesmo para o leque; para
erguer os mortos o `Spellcast_Summon` do sacerdote (`cast` do `priest`), outro gesto. Aceite: 6.1.

**T5-04 Corredor (e elite).** Preparação que encolhe e carrega: tronco descendo e braços puxados ao peito (queda do
centro do corpo de 15 cm ou mais em tamanho 1 até o fim do armar). Candidatos no rig KayKit que temos:
`Spellcast_Raise` (primeira metade, juntando) ou `Crouch_Fwd` da UAL cortado no agachar; o engenheiro mede com
`tools/clip_probe.gd` e `pose_metrics`, o art-director escolhe no `tools/enemy_lab.gd`. Golpe: um gesto que abre em
volta (braços e tronco abrindo, ou o giro `kaykit:2H_Melee_Attack_Spinning`, 0,67 s), nunca o soco para frente; o
dano (explosão) no quadro em que os braços abrem (T5-09).

**T5-05 Besteiro (e elite).** Subida da besta ao ombro em 0,25 s no assentar (hoje 0,1 s): `CLIP_FADE` por tipo
(`EnemyDef.windup_fade` 0,25) ou clipe `aim_raise` de `ual:Pistol_Aim_Down` para `Pistol_Aim_Neutral`; a mira parada é
aceitável (o Hades também segura a mira) desde que com o fio no chão já existente. P2: recuo do tiro (T5-19).

**T5-06 Escudo (e elite).** Investida: `brace` com assentar 0,15 s, armar até 0,80 s e segurar 0,35 s com tremor
0,03 m (hoje o clipe estica uniforme em 1,15 s); a **corrida** com clipe próprio `charge` = `ual2:Shield_Dash_RM` de
0,30 a 0,80 s com `in_place` (o empurrão de escudo que continua o `brace`), no lugar do golpe de espada (T5-P10).
Golpe curto: já lê; manter.

**T5-07 Cavaleiro.** Ganha `brace` e `charge` como o Escudo (o escudo do KayKit na mão esquerda), preparação de
1,0 s em três tempos (assentar 0,12, armar até 0,70, segurar 0,30 com tremor 0,03 m) e `_behave_knight` pede
`brace` (hoje `idle`). Elites herdam todos os clipes da figura comum (só a velocidade e a armadura mudam).

**T5-08 Dano no corpo nas investidas (Escudo, Cavaleiro, Morvath).** O aviso em linha passa a ser só desenho
(`power` 0) e dura até o corpo passar (vida = preparação + tempo da corrida, apagando atrás dele). O dano sai no
primeiro quadro em que o contorno do corpo, varrido do lugar de antes ao de agora, toca o herói (`Player.RADIUS`),
uma vez por investida, com o som de impacto nesse quadro. Morvath: o mesmo na `DASH` (`boss.gd` `_step_dash`),
mantendo `hurt_ctx.warn_s` igual ao tempo de aviso que o herói teve. Aceite: no quadro do dano, distância do herói ao
contorno de 0 a 0,3 m em 100% (sonda); esquiva atravessando continua sem dano.

**T5-09 Bote do esqueleto e explosão do corredor no quadro do golpe.** Esqueleto: dano no quadro em que a lâmina chega
embaixo (0,10 s dentro do ataque com T5-02), num arco de 120 graus à frente com alcance de `radius + 1,1 * size`
(cerca de 1,8 m) a partir de onde o corpo está nesse quadro; o aviso em linha com vida = preparação + 0,10 e
comprimento = o bote que o corpo vai fazer de fato (para no contorno do herói) + alcance. Corredor: aviso com vida =
preparação + o quadro em que os braços abrem (cerca de 0,1 s). Aceite: tabela 6.1 (dano x corpo e aviso x dano).

### 6.4 Especificação P1

**T5-10 Esqueleto esperando sem tremor (`horde.gd`).**
1. Anel de espera: pronto mas sem vez (`max_attackers`) ou com recarga, a menos de `attack_range`, ele mira um anel a
   `0,75 * attack_range` (2,7 m) e só anda se estiver a mais de 0,5 m dele (histerese de 1 m); de lado a 0,35 da
   velocidade, sempre para o mesmo lado (`side`) por pelo menos 1,2 s; olhando o herói.
2. Nada de campo de fluxo a menos de 2,5 m (`WAY_NEAR` 1,2 para 2,5, e volta a `straight = false` só acima de 3,0).
3. Rosto: virar para onde anda só acima de 1,0 m/s e com mais de 70 graus; voltar ao herói abaixo de 45 graus
   (histerese no `FACE_SPLIT`).
4. Andar e parado: trocar para `idle` só depois de 0,15 s abaixo de `WALK_FROM`, e para o andar só depois de 0,10 s
   acima de `WALK_START`.
5. Separação todo quadro com metade da força (`_separate`), ou o desenho seguindo a posição com 0,05 s (só desenho).
6. Andando de lado devagar (abaixo de 1,2 m/s, mais de 60 graus do rosto) toca os `Running_Strafe_Left`/`Right` do
   KayKit (rig que já temos), ou o andar a passo, nunca a corrida para frente de lado.
Aceite (sonda nos roteiros `--play --seed=1..4 --hero-hp=9999`, herói parado, e no robô): por esqueleto em `WALK`,
no máximo 1 quadro com mais de 8 graus de giro por 10 s fora da troca de alvo, inversões de giro até 0,3 por segundo,
trocas andar/parado até 0,5 por segundo, nenhum `idle` de 1 a 3 quadros, inversões de posição de 2 quadros até 0,2 por
segundo (hoje 35 quadros, 1,07, até 2,8, vários, 3,5).

**T5-11 Corrida do esqueleto sem "gazela" (`tools/bake.gd`, art-director aprova).** Trocar o `SOLDIER_RUN`: clipe
`ual:Jog_Fwd` (0,93 s) ou `kaykit:Running_A` (0,80 s), com `lock`, `stride` para 160 a 170 passos por minuto a 3,75
m/s, `lift` 0,25 e tronco inclinado para frente (`bend` na coluna até a inclinação medida ficar entre 8 e 15 graus); o
braço da espada na guarda com o antebraço balançando um pouco. Aceite (`walk_metrics` e `tools/walk_strip.gd`): os dois
pés no ar em no máximo 6 de 20 poses (hoje 16), pé de trás até 15 cm em jogo (hoje 29), sobe e desce até 7 cm em jogo
(hoje 13), escorregamento até 5 cm (`test_living_crowd.gd`). Decisão para o Daniel, se ainda parecer leve: o Guard do
Hades anda a 1,6 m/s; o esqueleto poderia correr a 3,75 m/s só longe (mais de 6 m) e andar a 2,0 m/s com
`kaykit:Walking_D_Skeletons` ao chegar perto.

**T5-12 Recuperações vivas.** `RECOVER` toca, em ordem, o resto do golpe à velocidade própria do clipe (não 1,4x) e
a volta à guarda (esqueleto: `Sword_Attack` 0,50 a 1,20 s em 0,7 s, depois `kaykit:2H_Melee_Idle` ou a guarda
respirando até o fim dos 2,1 s, com os últimos 0,3 s misturando para a guarda); Escudo e Cavaleiro depois da investida:
`ual2:Idle_Shield_Break` (1,07 s, o escudo baixando, cansado) esticado nos 1,1 e 0,8 s. E a próxima preparação nunca
no quadro seguinte ao fim da recuperação: pelo menos 0,25 s na guarda ou andando (`cooldown` mínimo = recuperação +
0,25; hoje 1 quadro). Aceite: nenhuma pose igual por mais de 0,3 s em `RECOVER`.

**T5-13 Tiro com gesto por tiro (feiticeiro, ancião, sacerdote).** Cada orbe da rajada reinicia o trecho do disparo do
`Spell_Simple_Shoot` (o pedaço em volta da soltura, a 1,5x, para caber nos 0,17 s entre orbes) com um recuo pequeno do
tronco; depois do último, `ual:Spell_Simple_Exit` (0,43 s) dentro da recuperação. Aceite: pico de movimento de 1,5 m/s
ou mais a cada orbe.

**T5-14 Foice de Morvath com o dano na descida.** O aviso enche até o quadro em que a lâmina cruza a cintura: vida do
aviso = preparação + 0,07 s (4 f; a descida de `slash3:6` a `:9` leva 10 f) e o golpe (`step 2`, o `boss_scythe`, o
som `scythe`) começa na preparação, como hoje; `hurt` 4 f depois do sopro. Aceite: dano entre `slash3:7` e `:8`.

**T5-15 Lâminas e Investida de Morvath com preparação própria.** Lâminas: `blades_windup` = o recuo do arremesso,
`ual2:Sword_Regular_B` de 0 a 0,20 s em duas mãos (`TWO_HANDS`) esticado no armar, depois o `slash2` que já solta no
quadro do tiro. Investida: `dash_windup` = `ual2:Sword_Dash_RM` de 0,00 a 0,12 s (o agachar antes do `dash`, que começa
em 0,12) com `in_place` e o tronco para frente, assentar 0,12, armar até 0,56, segurar 0,24 com tremor de 0,04 m.
Aceite: 6.1 e as duas preparações com poses diferentes (distância média dos vértices entre as poses armadas de 0,3 m
ou mais).

### 6.5 Especificação P2

- **T5-16 Corredor**: ver T5-04 (gesto em volta); hoje o dano sai antes do soco.
- **T5-17 Maldição de Morvath**: gesto próprio (o recuo do `volley`, `OverhandThrow` 0 a 0,26 s esticado) em vez do
  começo do `summon`.
- **T5-18 Erupções de Morvath**: cada leva com o trecho do `rain` que ergue as mãos (0,6 a 1,4 s do clipe), nada de
  `rain:13` parado na 2ª leva.
- **T5-19 Besteiro**: recuo do disparo (tronco 5 graus para trás em 0,06 s e volta em 0,2 s, por `bend` no assado).
- **T5-P14**: coberta pelo T5-10 item 5.

### 6.6 Ordem para o gameplay-engineer e quem aprova

1. T5-08 e T5-09 (dano no corpo): só `horde.gd`, `boss.gd`, `ground.gd`; teste GUT de distância no quadro do dano.
2. T5-10 (tremor): só `horde.gd`; a sonda como teste de regressão.
3. T5-01, T5-02, T5-06, T5-07, T5-03, T5-04 (assado e desenho): `tools/bake.gd`, `horde.gd` `render`,
   `make_data.gd`; reassar (`tools/bake.gd -- skeleton runner mage archer guard knight priest_elder morvath`); o
   art-director aprova as poses em `tools/enemy_lab.gd` antes do vídeo.
4. T5-11, T5-12, T5-13, T5-14, T5-15; depois os P2.
Depois de cada lote o combat-feel-director refaz a sonda (mesmos roteiros e sementes) e a tabela 6.1 e registra o
DEPOIS aqui; vídeo na GPU a 0,25x de cada tipo quando ela estiver livre.

### 6.7 DEPOIS (`24c298e`, revisão do combat-feel-director, 2026-11-17)

Medido na CPU, 60 f/s fixos, mesmos roteiros e sementes; detalhes e evidência em `docs/qa/t5_enemy_motion.md` seção 7 e
`docs/gallery/t5/motion/after/data/review/`.

| Medida (6.1) | ANTES `5dfe97f` | DEPOIS `24c298e` | Critério | Situação |
|---|---|---|---|---|
| Movimento da preparação (pico, tamanho 1) | 0,01 a 0,30 (Escudo 0,62, sacerdote 2,77) | 1,56 a 11,85 no clipe; Escudo 0,62 no clipe e 1,0 ou mais desenhado | 1,0 | passa |
| Pose armada | | 0,30 (besteiro) a 0,82 | 0,30 | passa (esqueleto 0,31 no limite; alto 1,85 m, pedido 2,1: não) |
| Pose parada na preparação | até 0,9 s (laços) | 0,13 a 0,28 s | 0,3 | passa |
| Recuperação parada | 1,76 s esqueleto | 0,00 a 0,28 s | 0,3 | passa |
| Dano x corpo | até 2,4 / 3,5 / 15,7 m | 100% dentro (esqueleto 160 golpes; investidas a 0,08 a 0,16 m do contorno) | 100% | passa |
| Aviso x dano | | 157 em 0 f, 1 em +1, 1 em -1, 1 em +7 (Escudo com o herói empurrado) | 0 a 1 f | passa com 1 caso fora (P2) |
| Tremor do esqueleto esperando (sementes 1 a 4) | 42 giros/10 s, 1,07 inv/s | 0 / 0 / 0 / 2,4 giros/10 s; 0,34 inv/s na semente 4 (um estalo em `FACE_SPEED`) | 1/10 s, 0,3/s | passa em 3 de 4 (P2) |
| Corrida do esqueleto | 16/20 no ar, pé 29 cm, 13 cm, tronco 3 a 5 | 5/20, pé 30 cm, 10,6 cm, tronco 13 a 17, 161 ppm, 3 cm; corpo 23 cm mais baixo | 6/20, 15 cm, 7 cm, 8 a 15 | 3 de 6 (decisão de arte e do Daniel) |
| Tiro por orbe | 0,3 a 0,7 | 1,57 (mago), 5,42 (sacerdote elite) | 1,5 | passa |
| Foice de Morvath | dano 10 f antes da descida | dano em `slash3:7`, 5 de 5 | `:7` a `:8` | passa |
| Vídeo 0,25x, PO reconhece pela pose | | não feito (GPU ocupada) | | pendente |

Problema novo **T5-20 (P1)**: besteiro (e quem foge) balança o corpo 20 graus a cada 3 a 5 quadros correndo reto
(robô semente 2: 8,7 inversões/s); `Horde.flee_dir` alterna entre os candidatos 0 e 35 graus e o rosto segue o `e.dir`
cru. Correção: candidato de fuga guardado 0,3 s ou mais e rosto pela velocidade suavizada; aceite com os números do
T5-10. Pendentes: T5-17 a T5-19 (P2), histerese de velocidade no `FACE_SPEED` (P2), aviso da investida do Escudo até o
contato real (P2), olho humano na seção 7.4 do relatório.


### 6.8 T5b, luta de Morvath depois do T5 (`fe07159`, 2026-11-17)

Relato do PO: "tem uns esqueletos pulando novamente". Medido no desenho real (sonda que lê os MultiMesh do
`CrowdRenderer`), CPU, 60 f/s; relatório e especificação em `docs/qa/t5b_boss_fight.md`, evidências em
`docs/gallery/t5b/boss/`. Quem pula é o **Esqueleto feiticeiro**: trote `Running_B` com meio pulo (`MAGE_TROT`), 14 de 20
poses no ar, 65% dos quadros de corrida com os pés acima de 12 cm (até 38 cm), mais um pulo de 0,5 m ao terminar o
`rise` (o clipe acaba curvado). Igual em `5dfe97f`; o T5 tirou o pulo do esqueleto (59% para 1%) e fez o feiticeiro
correr 27% mais (fuga). Outros achados: mistura de clipe em degraus (alvo sem interpolação, saltos de até 0,55 m em
Morvath), Morvath estalando 100 a 137 graus num quadro no começo da foice e da maldição, invocados atacando 0,02 s
depois de levantar. Ordem: P1-1 trote, P1-2 erguer, P1-3 mistura, P1-4 giro de Morvath, P1-5 chegada dos invocados.
