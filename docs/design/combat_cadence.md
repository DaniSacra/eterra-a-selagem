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


### 6.9 Prova estilizada (STY-09, `03fc59b`, 2026-11-18)

Parecer em `docs/design/stylized_combat_review.md`. O perfil não muda tempo nem estado (sonda 40/40 nos dois). Avisos
dos inimigos no salão passam (aro 51 a 79 acima da laje); reprovado para adoção pelo **P1-1**: na fase 4 de Morvath o
chão da câmara vai de luma 63 para 120 a 132 (ciano) e a tempestade perde o vermelho (saturação 0,48 para 0,24).
P2: avisos alaranjados no chão morno, Morvath sem violeta, corte mais véu que lâmina, herói perto do chão em matiz,
"vai bater" a 85%.


## 7. Runas Instáveis com peso (RP-02 e RP-03, `6762dbc`, 2026-11-19)

Revisão do dano novo no herói (4 para 7 de 30; inimigos 35 para 60; aviso 1,2 s, golpe 0,25 s, descanso 2,4 s iguais).
Evidência em `docs/gallery/rooms_rp/cadence/` (armado aos 3,9 s, 0,9 s do aviso, semente 5, Runas A, estilizado).

- **Medido (robô, reação 0,25, `--ultimate=cleave`, CPU 60 f/s fixos)**: 120 salas de abertura nas Runas (60 por
  variante, `--arena=runes --smoke=45`): runas 9 (A) e 12 (B) acertos, 0,15 a 0,2 por sala, nenhuma morte. Descida
  inteira, sementes 1 a 48 com `--runlog`: 39 vitórias, 44 salas de Runas, runas 6 acertos e 42 de dano (maior fonte
  nelas; mago 32 + 4), nenhuma morte nas Runas (as 9 mortes: 3 pelo mago nas salas, 6 em Morvath). Os 6 acertos vieram
  todos com a esquiva gasta (`hurt_ctx.dash_ready` false, `warn_s` 1,2); só 1 golpe de outro inimigo a menos de 3 s de um
  acerto das runas (mago, 2,1 s depois, fora da proteção de 1,3 s). Sem soma no mesmo instante: o acerto dá 1,3 s de
  proteção e só fere no quadro em que o aviso enche.
- **Tempo de reação (inferência pelos números)**: com a regra do vizinho apagado, sair de uma laje de 3 m pede no máximo
  1,5 m, 0,22 s andando. Pior caso: pernas presas do especial (0,71 s) com a esquiva gasta: 1,2 - 0,71 - 0,22 = 0,27 s
  para reagir; finalizador (30 quadros) deixa 0,48 s. Justo para 7; apertado para 10.
- **Leitura no Forward+ estilizado**: laje armada luma p50 113 a 115 contra 74 das vizinhas, saturação 0,21 a 0,29,
  âmbar (matiz 12 a 15) separado do vermelho da mira do besteiro. Passa.
- **P1 Compatibility**: a mesma laje armada lê só pela moldura e pelas marcas: p50 101 a 104 contra 91 a 100 das
  vizinhas (+4 a +13, era +40), saturação 0,04. Aceite: armada a 0,75 do aviso com pelo menos +25 de luma p50 e
  saturação 0,15 sobre as vizinhas no Compatibility estilizado (dono: environment-artist, `rune_floor_paint` /
  `rune_tiles.gdshaderinc`, como o LC-5 fez para os avisos do `Ground`).
- **P1 som**: as runas não têm som ao armar nem ao golpear (`RuneFloor` e `RunesLook` não chamam `Audio`); o jogador que
  olha o mago não tem aviso que não seja o chão. Aceite: um som curto ao armar (no `ARMED`) e o estalo no quadro do golpe
  (`FIRED`), por `CombatSounds`, abaixo dos avisos de Morvath (dono: gameplay-engineer).
- **Veredito**: 7 aprovado com ressalva (as duas P1 antes da exportação para o Daniel, ou ele joga sabendo). Passo 2
  (10) espera o teste do Daniel e as duas P1: o robô lê o âmbar perfeitamente, então a média dele (0,14 acerto por sala)
  não é a de gente, e com 10 o pior caso deixa 0,27 s com 33% da vida em jogo.


## 8. Lote 1C de 2026-11-19 noite: aprovações pendentes, LC-P1 e critérios do C19 (HEAD `c3011c0`)

Medido numa cópia isolada do `c3011c0` (`git archive`; outros agentes mexiam no repositório). CPU sem tela a 60 f/s
fixos: `tools/enemy_motion_probe.gd` sementes 1 a 3 (40 s, `--play --hero-hp=9999`); 8 descidas do robô
(`tools/smoke.sh 900 --seed=1..8 --bot-reaction=0.25 --ultimate=cleave --runlog`), 7 vitórias e 1 morte; GUT
`test_enemy_windup` 16/16, `test_special_wave` 5/5, `test_indicators` 17/17, `test_rune_sounds` 3/3,
`test_runes_compat` 2/2. Capturas medidas com `tools/frame_stats.py --hue`.

### 8.1 Pareceres

| Item | Veredito | Classe do que sobra |
|---|---|---|
| QW-104 corpo que acende no "vai bater" | **Aprovado** na cadência (a aprovação visual é do art-director) | P2 |
| QW-107 mira em fio do besteiro e do bote | **Aprovado** | nenhum |
| QW-111 onda do especial 25% maior no desenho | **Aprovado** (desenho dentro do acerto real) | nenhum |
| RP-03 Runas 7 no herói e 60 nos inimigos | **Aprovado sem ressalva** (as duas P1 da seção 7 resolvidas) | passo 2 (10) segue esperando o Daniel |
| LC-P1 preparo mais longo de algum atirador | **Não recomendado** (arquivar; reabrir só pelo critério abaixo) | |

**QW-104.** [D] `crowd.gdshader` 276: `ready = smoothstep(1 - tell_hold, 1, tell) * tell_light` (estilizado vezes
`STYLE_TELL` 1,6), somado só até `flash_cap` 1,0; `tell_hold` = `EnemyDef.windup_hold` 0,3 de todos. Rampa por tipo
[D]: besteiro e sacerdote 0,24 s (preparo 0,8), esqueleto 0,27 (0,9), mago, corredor e ancião 0,30 (1,0), Escudo 0,35
(1,15). [M] o corpo chega ao máximo no quadro do golpe e o golpe sai com o aviso cheio: esqueleto 0 f em 50 de 50
botes (sementes 1 e 3), corredor 0 f em 24 de 24, Escudo 0 f em 22 de 23 e +3 f em 1 (o caso conhecido do herói
empurrado, P2 da 6.7); `test_the_body_clears_in_the_hold` passa. Visto: no `archer_aim_strip_before_after.jpg` do LC
(`docs/gallery/lc/windup/after2/`) o besteiro clareia morno só no último quadro antes do tiro, sem virar silhueta
branca. **P2-QW104**: o Hades acende nos últimos `min(0,5 s, preparo)` [H] (seção 4.1 do estudo); nossa rampa dura
metade (0,24 a 0,35 s), presa ao `windup_hold`, que também é a pose segurada. Recomendação para o C19 (2B), sem
urgência: campo próprio `EnemyDef.tell_time` 0,5 s (rampa = `min(tell_time, preparo)`), soltando o brilho do corpo da
pose segurada. Aceite: rampa medida de 0,5 s em todo tipo com preparo de 0,5 s ou mais, pico ainda no quadro do golpe
(0 a 1 f), nenhum canal acima de 1,0.

**QW-107.** [D] `GroundLook.AIM_PX` 6 px de tela (o mesmo em 720 e 1080, pela derivada do pixel), `AIM_LIGHT` 0,5,
ponta até 1, faixa só nos últimos 30% até `AIM_FILL` 0,22; no estilizado o fio soma `style_rim_gain` 2,0 sobre o chão
escurecido a 0,8. Aceite do item: largura até 10 px (passa: 6), nenhum trecho acima de 0,6 fora da ponta (passa: fio
0,5, faixa 0,22), aviso x dano 0 a 1 f (passa: 0 f em todos os 50 botes do esqueleto, que usam o fio; o virote sai no
último quadro dos 0,8 s da mira, que é a vida do aviso, `Horde` 571). [M] `warn_s` do besteiro nas 8 descidas: 6
golpes, mínimo 1,15 s. [M] GPU (RTX, Forward+ estilizado, 1920 x 1080, `--stress=4 --stress-ids=archer,skeleton
--seed=5 --hero-at=0,0 --shot-at=3`, e o salão da semente 5 com o robô): o fio vermelho tem 7 px de altura por coluna
num fio quase deitado e 9 a 10 px num fio a 25 graus (cerca de 9 px na perpendicular, com o anti-serrilhado e a faixa
dos últimos 30%), sempre até 10; lê como fio, não como faixa, também passando sob o herói. Capturas em `docs/gallery/lote1c/cadence/`.

**QW-111.** [D] `emeth_wave.gdshader`: `look_scale` 1,25 em ondas abaixo de 3 m (só a do especial comum), 1,6 m
desenhada vira 2,0 m; o acerto não muda (`test_special_wave`: dano 40, alcance 11 m, círculo 0,7 m, 62,5 m/s, pernas
0,71 s). Sincronia desenho x lógica [D, conta]: o acerto pega quem tem o centro a até 0,7 + raio do corpo
(`Horde.in_circle`: 0,5 esqueleto, mago, besteiro, sacerdote; 0,55 Escudo; 0,75 corredor) do centro da onda, isto é
1,2 a 1,45 m de lado; a ponta desenhada vai a 1,0 m. Antes a onda desenhada (0,8 m de lado) ficava bem mais estreita que
o que acertava; agora fica dentro e mais perto dele, e nenhum inimigo tocado só pela ponta desenhada escapa do acerto
(corpo tocando a ponta = centro a até 1,5 m; acerto a até 1,2 m: a sobra de 0,3 m é o corpo do lado de fora da ponta).
Tamanho na tela [I, pela câmera: 54 m, campo 24, inclinação 30]: cerca de 47 px por metro no meio da tela a 1080, a
onda de 2,0 m dá cerca de 94 px quando voa para cima ou para baixo na tela e cerca de 47 quando voa de lado (era 75 e
38); na câmera Perto (37 m) cerca de 137 e 69 (a captura na GPU do salão pegou a onda já no acerto, a 1,6 m, atrás do inimigo: o tamanho fica como conta, não medida). Sem efeito na cadência (o golpe e as travas são os mesmos).

**RP-03.** As duas ressalvas da seção 7 foram resolvidas:
- **Som** (`c79802f`): `RuneFloor` toca `rune_arm` no `ARMED` (começo do aviso de 1,2 s) e `rune_crack` no `FIRED`
  (quadro do golpe), um por padrão, nunca por ladrilho, fora de `Audio.WARN_CUES` (sem ducking). [M] amostras: pico
  -14,1 dBFS (armar) e -8,3 dBFS (estalo), abaixo dos avisos de Morvath. `test_rune_sounds` 3/3.
- **Compatibility** (`c6d6aab`): [M] nas capturas de `docs/gallery/rooms_rp/cadence/` (1672 x 941, Runas A, 0,9 s
  do aviso = 0,75 dele): laje armada luma p50 135 a 145 e saturação 0,39 a 0,42, matiz 30 (âmbar); antes 91 a 105 e
  0,04. Vizinhas apagadas 74 a 137 (p50 típico 110 a 119, saturação 0,04 a 0,09, matiz 220 a 230). Aceite (+25 de luma
  p50 e +0,15 de saturação): saturação passa com folga (+0,30 ou mais); luma +25 a +26 sobre a vizinha típica e +53 a
  +71 sobre as do canto escuro, e só empata com a laje que está na poça da luz de cima (137), onde o âmbar contra o
  cinza-azulado (matiz 30 contra 220) separa sozinho. Forward+ da mesma tomada: armada 100 a 116 contra 65 a 102,
  saturação 0,21 a 0,29: o Compatibility agora lê **mais** que o desktop. O golpe (`runes_a_strike_compat_sty_after.jpg`)
  enche a laje de marfim-âmbar por cerca de 0,1 s e a brasa esfria em degraus, sem flash branco.
- [M] Robô nas 8 descidas: runas 2 golpes, `warn_s` 1,2 nos dois. O veredito da seção 7 sobe para **aprovado**; o
  passo 2 (10) continua esperando o teste do Daniel.

**LC-P1 (preparo mais longo de algum atirador).** O problema do LC era **quem** mira e **por onde**, não quanto tempo:
[M] `warn_s` dos atiradores nas 8 descidas, todos com aviso: mago 20 golpes, mínimo 1,07 s, p10 1,45; besteiro 6,
mínimo 1,15; ancião 5, mínimo 1,21; sacerdote 2, mínimo 0,83 (a trepadeira, lenta). Nenhum abaixo de 0,8 s; a regra
do C19 pede 0,4. Os tempos já são os do Hades [H]: mago 1,0 s (Mage), sacerdote 0,8 (SiegeVine), besteiro 0,8 mais
0,6 s médios de voo. Depois do LC-1b e do LC-3b [M, `docs/gallery/lc/windup/after2/`]: besta de 64 a 70 px a 1080 com
a linha de mira descendo da ponta ao fio do chão, orbe crescendo no cajado (LC-2 passou), V do Sacerdote lido de costas
(cerca de 80 px). Esticar a preparação deixaria o mago, que já é a maior fonte de dano nas salas, mais fácil sem tornar
a leitura mais clara. **Reabrir** só se o registro do Daniel (`runs.jsonl`, `hurt_ctx`) mostrar um atirador com mais de
30% dos golpes com `offscreen` verdadeiro ou com o herói de costas para ele; aí o remédio é tempo (0,2 s a mais só no
preparo daquele tipo, com a mesma pose segurada) e o critério é o mesmo `warn_s`.

Observado de passagem (sem ação): na semente 2 da sonda um corredor encostado na borda norte (z 18,85) soma 98 giros
acima de 8 graus em 10 s; são giros contínuos de 20 graus por quadro (o `TURN_RATE` de 1200 graus/s) seguindo o herói
preso na parede, não tremor de vai e volta (0,8 inversões/s, nenhuma de 2 quadros).

### 8.2 Critérios de aceite de cadência do C19 (para o gameplay-engineer, antes do Lote 2)

Valem junto dos números da seção 3 do backlog (fase 1 de Morvath, `warn_s`). Medição: sonda e
`enemy_motion_probe` a 60 f/s fixos, `tools/boss_cadence.gd --cadence-log` para Morvath, 24 descidas do robô
(`--bot-reaction=0.25 --ultimate=cleave`) e um vídeo na GPU a 0,25x de cada golpe novo. Todo golpe novo: preparação
com o corpo (pico de movimento 1,0 ou mais, 6.1), aviso cheio no quadro do dano (0 a 1 f), dano saindo do corpo ou da
arma desenhada, recuperação viva (pose parada até 0,3 s), troca de clipe com mistura (nenhum salto do centro acima de
0,3 m entre quadros), sonda 40/40 e `boss_probe`/`enemy_motion_probe` sem regressão.

**C19-1 Esqueleto elite, dois golpes (Q-11, [H] Guard elite: dois golpes a 0,2 s, não para, recuperação 1,5 s).**
- Os dois golpes em dado (`strikes` 2, `strike_gap` 0,2 s), o segundo sem nova preparação longa: o corpo emenda
  (pose do fim do 1º para a subida do 2º em até 0,2 s), sem `idle` no meio.
- Os dois avisos visíveis antes do 1º golpe: o 2º fio aparece já na preparação (fraco, enchendo nos últimos 30% do
  intervalo), porque 0,2 s (12 f) não dá para reagir a um aviso que só nasce depois do 1º golpe. Cada aviso cheio no
  quadro do próprio golpe (0 a 1 f, os dois contados na sonda).
- O 2º golpe mira onde o herói estava no fim da preparação (não persegue): quem esquivou do 1º para o lado sai dos dois.
- Atordoar no 1º golpe corta o 2º (o aviso some no mesmo quadro, `Ground.end_zone`); a armadura segue absorvendo antes.
- Recuperação depois do 2º: 1,5 s (a do Hades para a elite), parado, com o clipe seguindo; janela de punição medida
  (`windups` com `struck` e um campo novo de golpes recebidos na recuperação).
- Aceite no robô: dano por esqueleto elite por sala no máximo 1,5 vez o de hoje (a dobra vem do 2º golpe); nenhum dano
  com `warn_s` abaixo de 0,4.

**C19-2 Corredor elite, explosão dupla (Q-11).**
- Dois giros com `strike_at` cada, intervalo em dado; o 2º anel de aviso nasce no quadro da 1ª explosão e enche no
  quadro da 2ª (intervalo mínimo 0,5 s [I]: um anel novo precisa de tempo de leitura; com 0,2 s o 2º é invisível).
- O corpo não para entre as duas (giro contínuo, `2H_Melee_Attack_Spinning` em laço); o 2º anel no lugar do corpo no
  quadro da 2ª explosão, não no do 1º (se ele anda no giro, o anel anda com ele).
- Recuperação depois da 2ª: a do Hades para o Radiator elite, 0,5 s [H]; a janela vem do giro longo, não da espera.

**C19-3 Segundo golpe de Morvath de perto (Q-09 a; [H] Hécate: direita 0,85 / 0,4 / 0,35 s e logo esquerda
0,5 / 0,5 / 2,2 s).**
- Par: o 1º golpe com preparação de 0,85 s e o 2º emendado com 0,5 s; avisos dos dois no chão, o 2º nascendo no fim
  do 1º golpe (0,4 s ativos + 0,35 de recuperação curta antes dele: 0,85 s de leitura, mais que a preparação inteira
  do esqueleto), cada um cheio no quadro do próprio dano (0 a 1 f, `slash3:N` medido como na foice).
- Depois do 2º, recuperação de 2,2 s (janela longa, `State.RECOVER`, `stats.windows`/`punished`): é a razão do par.
- Clipe novo com `in_place` (centro de toda pose a no máximo 0,45 m, `tools/pose_drift.gd`), duas mãos como a foice,
  giro do corpo no limite `BODY_TURN` 720 graus/s entre os dois (não estala para o lado do 2º).
- Distribuição (aceite do backlog): fase 1 com o herói a menos de 4 m, nenhum ataque acima de 50% e nunca 3 iguais
  seguidos, em 3 sementes do `boss_cadence --cadence-log`.

**C19-4 Ômega carregando no número do Hades (Q-12).**
- Ômega do ataque: andar a 3% da velocidade enquanto carrega (0,2 m/s) e o giro do corpo quase travado [H, `Swing5`];
  a esquiva corta a carga no quadro do aperto (a Magia não é gasta); nenhum quadro de `Run` ou `Sprint` com a carga
  segurada.
- Ômega do especial: o número do Hades da ação, lido pelo gameplay-engineer em `WeaponData_Staff.lua` 474-501; se o
  dado não trouxer velocidade própria, a do especial comum na carga (60%, `InstantStop`, linha 1313) e marcar como
  inferência no documento. Ômega do círculo segue `cast_slow`.
- O corpo mostra a carga: pose de carga própria (ou a preparação do golpe segurada), não a corrida em câmera lenta;
  o andar desenhado no ritmo da velocidade real (o passo não escorrega, como os inimigos).
- O som `charge_up` segue o tempo da carga e corta com 0,2 s de fade ao soltar ou cancelar [H].
- Aceite no robô e na sonda: `omega_charges_cancelled` registrado; distância andada do aperto ao disparo no máximo
  0,2 m no Ômega do ataque; a sonda ganha a meta.

**C19-5 Linha da mira no orbe e no leque do Ancião (Q-14 a) e a regra da trepadeira (Q-14 b).**
- Orbe do mago: `add_aim_warning` do começo da preparação (1,0 s) até o 1º orbe, no rumo do tiro, com o comprimento
  do `arena.shot_reach` (para na pedra); fio na gramática do besteiro (até 10 px a 1080, faixa só nos últimos 30%).
  Como o orbe vira 20 graus/s nos primeiros 0,8 s, o fio marca o rumo da saída; a rajada (3 orbes a 0,17 s) usa um
  fio só.
- Leque do Ancião: cinco fios fracos ou só as duas bordas e o do meio (escolha do art-director pela SW-G7), todos
  nascendo e cheios juntos; aviso cheio no quadro do tiro (0 a 1 f).
- Trepadeira (b): a regra passa a "todo ataque tem aviso, no chão ou no corpo": o rito do sacerdote (V dos braços e
  chama, LC-3b) é o aviso; a trepadeira lenta (1,9 m/s) se lê no voo. Aceite: `warn_s` da trepadeira 0,8 ou mais em
  100% dos golpes.
- Aceite geral (backlog): todo tiro com `warn_s` de 0,4 ou mais nas 24 descidas; hoje [M] o menor é 0,83 s.

**C19-6 LC-P1:** não pedido (8.1).

### 8.3 Parecer do C19 (HEAD `8dc0fea`, 2026-11-20)

Medido numa cópia isolada do `8dc0fea` (`git archive`), CPU sem tela a 60 f/s fixos: sonda `feel_probe_run`;
`enemy_motion_probe` sementes 1 a 3 sem estresse e com `--stress=4 --stress-ids=skeleton_elite,runner_elite` (40 s),
mais `--stress=4` só de `runner` e só de `runner_elite` (sementes 1 e 3, 30 s); `boss_cadence --cadence-log` sementes 1,
2, 3 e 5 (reação 0,25, 5 Bênçãos); `boss_probe` sementes 5 e 1; `pose_drift` de Morvath. Vídeos e folhas de
`docs/gallery/c19/` lidos quadro a quadro com ffmpeg. As 24 descidas do robô não foram refeitas (outros agentes rodavam
`smoke` na mesma máquina): valem os números do gameplay-engineer no `CLAUDE.md`, seção C19.

**Veredito: aprovado** na cadência, com uma P2 do próprio C19 a resolver no AP-2 e uma P1 antiga que o C19 deixou
mais visível (fora do escopo, item próprio). Nenhum P0.

| Critério 8.2 | Medido | |
|---|---|---|
| Sonda | 41/41 [M] | passa |
| Aviso cheio no quadro do dano | [M] comuns 0 f em 94 golpes (sem estresse; Escudo +3 f em 1, o caso conhecido); elites: 1º golpe do esqueleto e 1ª explosão "-1 f" na sonda, que é sobra de 0,003 s de vida do aviso (0,2 ms, um arredondamento, não um quadro); 2º golpe 0 f (esqueleto) e +1 f (corredor). 270 golpes de elite nas 3 sementes, nenhum fora de -1 a +1 | passa |
| 2º golpe do esqueleto elite | [M] 0,2 s depois do 1º (12 f), a 0,93 a 1,97 m do herói (a lâmina alcança 2,21); o fio do 2º nasce com a preparação (vida 1,336 s contra 1,136 do 1º) | passa |
| Corpo emenda os dois golpes | [D] `Horde.render`: o clipe do golpe recomeça do alto com mistura de 0,1 s (`strike_gap` x 0,5) do fim do 1º, e desce no 0,1 s seguinte; nenhum `idle` entre eles [M] | passa |
| Pose parada | [M] recuperação até 0,22 s, preparo até 0,17 s (teto 0,3) | passa |
| Explosão dupla do corredor elite | [D] 2º anel nasce no quadro da 1ª onde o corpo está (ele não anda em ATTACK), vida 0,5 s + 1 f; giro em laço (`fposmod`); fim 0,3 s depois, recuperação 0,5 | passa, ver P2-C19a |
| Ceifa Dupla: tempos | [M] `boss_cadence`: ataque 2,59 a 3,33 s com a aproximação, recuperação 2,20 a 2,22 s (0,22 e 0,55 só quando a troca de fase corta); [D] o dano é a própria zona do aviso no chão, então o aviso está cheio por construção; o corte visual sai no mesmo `windup` (0 a 1 f) | passa |
| Ceifa: clipe e corpo | [M] `pose_drift`: `slash1` pior 0,34 m, `slash2` 0,43 m (teto 0,45); `boss_probe`: maior passo 0,258 m (teto 0,3), na Lâmina com o passo atrás do C17, não na Ceifa; na Ceifa `slash1`/`slash2` tocam 1045 e 1115 quadros e `idle` 1 quadro na entrada do estado (dentro da mistura de 0,18 s) | passa |
| Ceifa: direita e depois esquerda | [O] vídeo: o 1º corte varre de um lado, o 2º volta do outro; 2º aviso nasce depois do 1º corte e enche até o 2º | passa |
| Fase 1 perto | [M] maior parte 43 / 43 / 50 / 43% (Ceifa ou foice), nunca 3 iguais, 6 a 8 ataques por semente | passa (no limite em 1 de 4) |
| Janela de punição | [M] vida perdida por janela da Ceifa 62 a 188 contra 26 a 50 da foice: a janela longa existe e é usada | passa (o efeito no tempo da luta é do balance-designer) |

**Ancião 45 para 126 (C19-4): é equilíbrio, não cadência.** Os golpes do leque têm `warn_s` de 1,04 s ou mais, o aviso
nasce e enche junto do tiro e os orbes saem no quadro do fio cheio: nada na leitura piorou. O que mudou é o custo de
carregar o Ômega a 3% da velocidade (o número do Hades, de propósito: carregar é se comprometer). O robô começa o Ômega
com um atirador preparando por perto e, sem carga de esquiva, sai a pé soltando o botão, o que dispara ou encerra o
golpe plantado; gente pode cortar a carga na esquiva no quadro do aperto (meta `C19-4` da sonda). Recomendação: não
mexer nos 3%; o gameplay-engineer faz o robô não começar o Ômega do ataque com um tiro preparando a menos de 12 m
(`Bot`, mesma regra do `_danger`), e o balance-designer relê o dano do Ancião depois disso e no registro de gente
(`hurt_ctx` com `by: priest_elder`). Aceite: Ancião no robô até 1,5 vez o de antes (até 68 nas 24 descidas) com essa
regra; se continuar acima, é número do leque (balance), não tempo.

**P2-C19a, 2º anel do corredor elite tapado pela 1ª explosão.** [M] vídeo a 0,25x (`runner_elite_quarter_speed.mp4`,
1 quadro do vídeo = 1 quadro do jogo): a 1ª explosão sai no quadro 22 e o disco claro dela cobre a área até o 33; o aro
do 2º anel só se lê do 34 ao 54 (2ª explosão): 0,33 s de leitura dos 0,5 s pedidos. Pouco grave hoje (quem levou a 1ª
está protegido 1,3 s; o 2º só pega quem esquivou e voltou), mas é o tempo de leitura do critério. Correção
(gameplay-engineer com o art-director): o disco da explosão do corredor some em até 0,12 s ou o 2º anel desenha por
cima dele. Aceite: no vídeo a 0,25x, aro do 2º anel visível 0,4 s ou mais antes da 2ª explosão.

**P1 antiga, corredor elite tremendo encostado no herói (não é do C19).** [M] parado no `WALK` esperando a recarga, o
corredor elite é empurrado para fora pela separação (cerca de 1 m/s) e volta 0,12 m num quadro só quando a distância
passa de `attack_range` 1,6 (um quadro de andar a 7,375 m/s): dente de serra de 12 cm a uns 8 Hz. Inversões de lugar de
2 quadros: até 29/s num corredor elite (estresse de elites, sementes 1 e 3), até 11,7/s só de corredores elite, até
5,7/s nos corredores comuns (4,875 m/s, passo de 8 cm). [D] a lógica de andar do `_behave_pulse` não mudou desde o
`c3011c0`; o C19 só põe mais corredores elite na tela. Correção (gameplay-engineer): a mesma histerese do Cavaleiro e do
Escudo (`MELEE_WALK_BAND` 0,8 m, `Enemy.closing`) no `_behave_pulse`: parado dentro do alcance, só volta a andar acima
de 1,6 + 0,8 m. Aceite: até 2 inversões de lugar por segundo por corredor no mesmo estresse, golpes com aviso de -1 a
+1 f iguais.

**P2, evidência.** O `reap_quarter_speed.mp4` não está a 0,25x: os 0,85 s do preparo ocupam 12 quadros do vídeo a 15 f/s
(cerca de 0,07 s do jogo por quadro, uns 0,9x), e a recuperação de 2,2 s não aparece inteira. Os números do
`boss_cadence` cobrem a falta; na próxima captura de Morvath, a 0,25x de verdade e até o fim da janela.

**Observado, para o art-director (não é cadência do C19):** nos três vídeos, ao levar golpe o herói vira silhueta
marfim chapada por 2 quadros (esqueleto quadros 41 e 42, corredor 23 e 24, Ceifa 18), contra a regra do
`Player.HURT_*` (clarear morno 0,05 s, nunca silhueta branca). Conferir no estilizado.


## 9. Perigos do Lote A1, protótipos do atlas, dano 10 e quebráveis (critérios, HEAD `07688f5`, 2026-11-21)

Só critérios, escritos antes do código; a aprovação de cada entrega vem depois, com medida. Base: backlog "Estado e
ordem de 2026-11-20" (resposta 6: dano 10; resposta 8: RP-14), "Pacotes do PO de 2026-11-20" (P.2, P.3 AT-Q, P.4
AT-H1 a AT-H3), `docs/design/po_2026-11-20/layout_salas/PROMPT-CLAUDE-CODE.md` ("Cada perigo precisa comunicar o que
fará antes de causar dano, na câmera normal") e `docs/design/rooms_progression.md` (RP-12, RP-14, RP-18, RP-20).
Câmera de todas as medidas: **Perto** (`--cam=near`, 37 m, cerca de 28 m de chão na largura da tela), estilizado,
Forward+ e Compatibility.

### 9.1 Números de partida (o que limita a reação)

- [D] Herói anda 6,75 m/s; esquiva 5,6 m em 0,2 s com 19 f de proteção, 1 carga, recarga 0,74 s; proteção depois de
  ferido 1,3 s; vida 30. Travas que só a esquiva corta: pernas do especial e do Ômega do especial 0,71 s (pior caso),
  finalizador 30 f (0,5 s), golpe 2 19 f (0,32 s).
- [D] Perigos de hoje: Runas 1,2 s de aviso, Corrente 1,2 s, Raiz 1,2 s de aviso depois de 0,5 s de espera do herói,
  Laje Rachada 1,0 s, Seteira 1,0 s; golpe de 0,25 s que fere **num quadro só**, o do aviso cheio (seção 7).
- [I] **Janela de reação de pior caso** = aviso, menos a pior trava sem esquiva (0,71 s), menos o tempo de sair andando
  do ponto mais fundo da área até a borda mais perto (distância / 6,75). Tempo de reação de gente: 0,25 s (o
  `--bot-reaction` que usamos). Com a esquiva carregada a janela é o aviso inteiro (ela corta a trava e cobre 5,6 m).

### 9.2 Regras comuns a todo perigo novo (valem para os sete abaixo)

Quadro t0 = primeiro quadro em que o aviso aparece na tela.

| # | Regra | Medida | Classe se falhar |
|---|---|---|---|
| R1 | O alcance final inteiro desenhado já em t0 (moldura, aro ou faixa no tamanho do golpe); o que cresce é só o preenchimento. Nunca um ponto que vira área | quadro t0 no vídeo a 60 f | P0 |
| R2 | Dano no quadro em que o aviso enche, de 0 a +1 f; quem entra durante os 0,25 s do golpe não é ferido (como hoje) | sonda do perigo (log do `Ground` e do `hurt_ctx`) | P0 |
| R3 | O evento físico (pedra toca o chão, mão fecha, folhas abrem e a raiz bate, urna explode, cristal descarrega) cai no quadro do dano, de -1 a +1 f | vídeo a 60 f com `--fixed-fps 60` | P1 |
| R4 | A peça se anuncia no corpo dela também, começando em t0 (de 0 a +2 f): afundar, mão, folhas, pavio, poeira | vídeo | P1 |
| R5 | Som `<nome>_arm` em t0 (0 a +1 f) e `<nome>_fire` no quadro do dano; abaixo dos `Audio.WARN_CUES` de Morvath, sem ducking, `VoiceGate` | `--sound-log` contra o log do perigo | P1 |
| R6 | Janela de reação de pior caso (9.1) de 0,25 s ou mais **com dano 10**. Onde não dá, o aviso sobe para 1,2 s (tabela 9.4) | conta pelos números do dado; GUT do pior ponto | P0 (é a regra "nada inevitável") |
| R7 | Com o herói dentro da área ou a até 2 m dela, a área inteira fica entre 5 e 95% da tela da Perto | captura em 8 pontos da sala; teste com `CamRig.look_at` | P0 se a borda some, P1 se só a peça some |
| R8 | Perigo âmbar por baixo do vermelho dos inimigos: `render_priority` abaixo do `Ground` dos inimigos, preenchimento até 0,25, nada soma no stencil dos avisos | captura com a mira do besteiro e o bote do esqueleto cruzando o perigo armado: fio da mira com saturação 0,45 ou mais e luma +30 ou mais sobre o âmbar logo abaixo | P1 |
| R9 | No máximo 2 avisos de sala ao mesmo tempo na sala inteira (a regra "nunca 3") e nunca 2 sobre o mesmo ponto | GUT | P0 |
| R10 | Empurrão ou puxão de um perigo nunca deixa o herói dentro de outro aviso ativo (de sala ou de inimigo) nem em pedra | GUT com 12 x 12 pontos e avisos sorteados | P1 (P0 se cair em pedra) |
| R11 | Fora dos 6 m da entrada, dos 3 s do começo, das bocas de porta; dormente antes do progresso do dado | GUT (os testes de hoje dos RP) | P0 |
| R12 | Compatibility estilizado: armado a 0,75 do aviso com +25 de luma p50 e saturação 0,15 sobre o chão vizinho (a regra que as Runas passaram) | `frame_stats.py --hue` | P1 |
| R13 | Robô (reação 0,25, 8 sementes): dano do perigo no herói 0,5 a 1,5 por sala onde ele está, nenhum `stuck`; com gente, o registro (`hurt_ctx`) decide | `smoke 900 --runlog` | P1 |
| R14 | Depois do golpe a área some em até 0,1 s (o que fica no chão, fogo e entulho, tem desenho próprio e regra própria, abaixo) | vídeo | P2 |

### 9.3 Critérios por perigo

**RP-14 Cristal que descarrega (Runas B).**
- Preparo: a descarga começa no quadro da 3ª carga (sem espera escondida) e avisa **1,2 s** na língua das Runas: as
  lajes da fileira inteira com a moldura âmbar desde t0 e as divisas apontando para onde a descarga corre
  (`RunesLook.set_chevrons`). Alcance: a fileira de lajes de 3 m; saída andando de 1,5 m no pior ponto.
- Cargas 1 e 2 legíveis **sem ver o cristal** (ele fica ao norte, fora do chão, e pode sair da Perto): um som curto por
  carga e, desde a 2ª, a fileira alvo com a marca de repouso um degrau mais clara. P1.
- Nunca no mesmo intervalo de um padrão das Runas que deixe mais de 35% aceso nem tire o vizinho apagado de uma laje
  acesa (GUT junto dos 2000 padrões de hoje). P0.
- A pedra quieta nunca recebe a descarga (é para onde se foge). P0.
- Golpe no cristal (se o herói o alcança): conta carga, sem hit stop de inimigo (ver 9.6). P2.

**RP-12 Urna de óleo (Cripta tardia).**
- Pavio de 1,0 s com o aro de 2,5 m inteiro desde t0, o pavio queimando visível na urna; com 10 no herói o pior caso é
  quem a acendeu com o finalizador ou o especial: 1,0 - 0,71 - 2,5 / 6,75 = -0,08 s. **Aviso 1,2 s ou aro de 1,8 m**
  (1,2 - 0,71 - 0,37 = 0,12; com aro 1,8 e 1,2 s, 0,22): recomendo **1,3 s com 2,5 m** (0,22 s, o mesmo da Seteira, e o
  barril do Hades também avisa mais que os golpes). P0 até a conta passar.
- Acesa por qualquer fonte (golpe do herói, golpe de inimigo, outro perigo): o pavio é sempre o mesmo tempo a partir do
  quadro em que acende, nunca encurtado. P0.
- Fogo que corre no canal de 6 m a 3 m/s: o aviso vai **1,0 s à frente da chama** (faixa âmbar 3 m adiante dela); o
  chão em chamas fere uma vez por entrada (a proteção de 1,3 s cobre), fica desenhado inteiro enquanto fere e apaga em
  2 s com o desenho sumindo junto do dano (0 a +2 f). P1.
- Silhueta nunca a de um quebrável (bronze escuro, pavio, isolada; AT-Q0): confundir os dois é P0 de leitura (o
  jogador quebra o que acha que é vaso e explode).

**RP-18 Colunata (variante tardia, sem perigo novo, a coluna que tomba do RP-09).**
- A cobertura não pode esconder aviso: a 30 graus de inclinação uma coluna de altura h tapa o chão atrás dela por
  1,73 h (5 m de coluna, 8,7 m de chão). Critério: na Perto, todo aviso de inimigo dentro da colunata com 70% ou mais da
  área à vista, e o fio da mira do besteiro inteiro do pé dele até 3 m à frente. Caminhos: colunas baixas (até 2,5 m:
  4,3 m tapados) ou pontilhado também em volta de quem prepara um ataque. P1.
- Preparo do inimigo atrás de coluna: os sinais por cima do corpo (`EnemyFx` acima da pedra) seguem lidos. P1.
- Coluna que tomba: faixa 1,2 x 5 m por 0,6 s, não fere o herói; com três ou mais na grade, nunca duas tombando ao mesmo
  tempo sobre o mesmo inimigo sem aviso inteiro de cada uma. P2.
- Robô sem `stuck` e esquiva de 5,6 m nunca parada em coluna a menos de 2,5 m em 16 de 16 (o "cercado" do GP-04). P0.

**RP-20 Pedras da abóbada (Santuário B; depois Fendas B se a medida pedir).**
- Aviso **1,2 s**: o quadrado 2 x 2 m inteiro desde t0 (R1) e a sombra enchendo; poeira caindo do teto no mesmo ponto
  desde t0, vinda do alto da tela (o teto não aparece na Perto, então a poeira tem de entrar pela borda de cima e
  chegar ao chão). Saída de pior ponto 1,0 m: 1,2 - 0,71 - 0,15 = 0,34 s. Passa.
- A pedra aparece caindo nos últimos 0,2 a 0,3 s e toca o chão no quadro do dano (R3). P1.
- No máximo 2 por vez e a cada 4 s; nunca uma pedra cuja área toque a de outra pedra ou de uma Laje Rachada armada
  (R9). P0.
- Entulho de 3 s: **não barra corpo** (barrar mudaria a `NavGrid` no meio da luta, o risco que tirou o H-6); se barrar,
  é P0 até o teste de saída e o robô passarem. Desenho do entulho baixo e cinza, nunca âmbar (não pode ler como aviso).
- Nunca sobre o `boss_spawn` nos 3 s em que o guardião surge, nem sobre a barra de vida dele na tela. P1.

**AT-H1 Laje de pressão (Santuário A e B, é o RP-06).**
- O afundar de 4 cm e a rachadura começam em t0 (R4); o afundar lê na Perto como sombra na junta (4 cm são cerca de 1 px
  a 1080: só a sombra e a poeira contam). P1.
- **Aviso sobe de 1,0 para 1,2 s com dano 10** quando um inimigo arma a laje com o herói em cima (o herói não escolheu):
  1,0 - 0,71 - 0,22 = 0,07 s hoje. Armada pelo próprio herói andando, 1,0 s basta (ele não está travado ao pisar), mas
  um número só é mais simples: 1,2 s para toda laje. P0.
- Isca: o inimigo que pisa e se fere tem de ser visível como causa (a laje acende sob o pé dele, golpe com a marca de
  dano 60). Sem critério de cadência além de R2 e R3.
- Laje ativa distinta das emolduradas e tumulares na Perto em repouso (o atlas pede): repouso em osso apagado, nunca o
  relevo do SW-G3. P1.

**AT-H2 Esqueleto do nicho (Cripta B).**
- Repouso: a mão à mostra e o leque de 2,2 m marcado fraco no chão sempre (como a laje em repouso), lidos na Perto com o
  herói a até 4 m do nicho; o nicho na parede norte não pode sair pelo topo da tela nesse raio. P0 (é a única pista antes
  da espera de 0,3 s).
- Tempo total da entrada ao golpe: espera 0,3 s + aviso. Pior caso: o herói já dentro quando a recarga de 6 s acaba e
  solta o especial no quadro em que o aviso começa: 1,0 - 0,71 - saída lateral. Com a saída de 1,1 m (metade da
  largura do leque) dá 0,13 s. **Aviso 1,2 s** (0,33 s). P0.
- Preparo: a mão sai e os ossos mexem desde t0, a pedra raspando (`niche_arm`) em t0; a mão fecha no quadro do dano. P1.
- Agarrar: 10 e puxão de 1 m para o nicho em 0,1 a 0,15 s (nunca teleporte de um quadro), o herói mantém a esquiva no
  quadro seguinte (sem prender, Q-AT3 a). Puxão que poria o herói dentro de outro aviso: encurta até a borda dele (R10).
  P0 se prender ou teletransportar.
- Golpe da Emeth no esqueleto: faísca sem número, sem combo, sem Magia, sem passiva e **sem hit stop de inimigo** (o do
  escudo do ritual); o golpe segue o tempo normal. A mira assistida (`Player.ASSIST_*`) nunca gira o golpe para ele. P1.
- Fora das faixas das seteiras e a 1,5 m das lajes (R9). Nunca dois avisos de sala da Cripta B sobre o mesmo herói. P0.

**AT-H3 Planta hostil (Jardim B, pele do RP-10).**
- Espera do herói 0,5 s (o da raiz) e aviso **1,2 s** (o RP-10 de hoje; a P.4 escreve 1,0, vale 1,2 com dano 10): faixa
  de 2,5 m de comprimento; saída lateral no pior ponto até 0,75 m pede faixa de até 1,5 m de largura (com 3 m da raiz,
  1,5 m de saída, a conta dá 0,27 s, ainda passa).
- As folhas se fecham desde t0 e a raiz bate no quadro do dano (R3, R4). Na Perto, a contração lê como mudança de forma
  da silhueta (não só de cor): a planta encolhe pelo menos 25% da largura na tela até o golpe. P1.
- Golpe na planta: faísca e folhas encolhendo, sem hit stop de inimigo, sem número, nunca alvo da mira assistida. P1.
- Empurrão de 1 m para fora da faixa nunca para a água do lago J5 nem para pedra (R10).

### 9.4 Parecer sobre o dano 10 no herói (era 7; resposta 6 do Daniel)

**Aprovado com condições.** 10 é o número do Hades sobre os mesmos 30 de vida [H]; três acertos matam, então a regra
"nada inevitável" tem de valer no pior caso, não na média do robô (que lê o âmbar perfeitamente: 0,14 acerto por sala
nas Runas, seção 7).

| Perigo | Aviso | Saída no pior ponto | Janela de pior caso | Parecer com 10 |
|---|---|---|---|---|
| Runas | 1,2 s | 1,5 m (0,22 s) | 0,27 s | passa, no limite |
| Corrente da Ponte | 1,2 s | 1,0 m (0,15 s) | 0,34 s | passa |
| Raiz Morta | 0,5 + 1,2 s | 1,5 m (0,22 s) | 0,27 s | passa, no limite |
| Seteira | 1,0 s | 0,5 m (0,07 s) | 0,22 s | P2: aceita (faixa de 1 m e armada por laje à vista) |
| Laje Rachada | 1,0 s | 1,5 m (0,22 s) | 0,07 s | **P0: aviso 1,2 s** (0,27 s) |
| Borda que desmorona (RP-13) | 1,0 s | 1,5 m | 0,07 s | hoje fere 5, fora da resposta 6; se subir (7, a mesma proporção), aviso 1,2 s |
| Cristal (RP-14) | 1,2 s | 1,5 m | 0,27 s | passa |
| Urna de óleo (RP-12) | 1,0 s, aro 2,5 m | 2,5 m (0,37 s) | -0,08 s | **P0: 1,3 s** (0,22 s) |
| Pedras (RP-20) | 1,2 s | 1,0 m | 0,34 s | passa |
| Nicho (AT-H2) | 0,3 + 1,0 s | 1,1 m (0,16 s) | 0,13 s | **P0: aviso 1,2 s** (0,33 s) |
| Planta (AT-H3) | 0,5 + 1,2 s | até 0,75 m | 0,38 s | passa com faixa até 1,5 m |

Condições:
- **P0** os três avisos acima (Laje, Urna, Nicho) antes de o 10 entrar nessas peças. Subir o aviso não deixa mais fácil
  na média (quem não reage leva 10 em vez de 7); só tira o golpe sem saída.
- **P1** perigo sobre ferida: no registro de gente (`hurt_ctx`), pares "inimigo e perigo a menos de 2 s um do outro"
  até 1 a cada 10 salas; acima disso o perigo arma 0,3 s depois do fim da proteção de 1,3 s quando o herói está nele
  (regra do `Ground`, sem mudar o aviso).
- **P1** Compatibility (R12) e som (R5) em todo perigo antes do exe: com 10, o perigo que não se ouve nem se lê fora do
  Forward+ é o mais caro da sala.
- **P1** a soma da sala: dano de perigos no herói por sala com o robô até 1,5 vez o de antes da troca (o 10 multiplica
  por 1,43 sozinho; mais que isso é colocação, não número); o `balance-designer` confere com o Lote B.
- **P2** teste com gente obrigatório antes de qualquer subida além de 10: a janela de 0,27 s das Runas e da Raiz é a
  mesma que eu já marquei como "apertado para 10" na seção 7.

### 9.5 Sobreposição com avisos de inimigos (todas as salas com perigo)

- [D] Avisos de sala em âmbar com `render_priority` -1 e os dos inimigos em vermelho por cima, segunda passada sem somar
  (stencil 2). Critério: em toda captura de cruzamento (R8) o vermelho é o mais saturado e o mais claro na área comum.
- O pior momento a medir em cada sala: herói dentro de um perigo armado, um atirador preparando e um corpo a corpo no
  bote. Nesse quadro: os três avisos inteiros, nenhum preenchimento acima de 0,35 somado, o herói lido (raio-x e anel).
  P1.
- Perigo e golpe de inimigo que enchem no mesmo quadro sobre o herói: a proteção de 1,3 s deixa um só ferir; o registro
  deve dizer qual (o primeiro processado), e o som do segundo não toca. P2.

### 9.6 Quebráveis (AT-Q)

O golpe que acerta um vaso tem de continuar sendo o golpe que acerta inimigo: peso, tempo e controle iguais.

- **P0 mira assistida**: o giro do golpe para o inimigo mais perto (`Player.ASSIST_*`, 5 m, 130 graus) **nunca** escolhe
  um quebrável, nem com só vasos em volta. Teste: herói entre um vaso a 1 m e um esqueleto a 4 m, golpe sem mouse vai ao
  esqueleto.
- **P0 tempo do golpe**: acertar um vaso não muda preparação, quadro do golpe, `recovery`, trava de pernas, buffer nem
  janela de emendar (sonda de sensação 41/41 com 6 vasos à volta, mesmos quadros). Golpe cortado pela esquiva não
  quebra nada (`ComboRunner.can_cancel`, como não acerta inimigo).
- **P0 corpo**: no MVP nenhum quebrável barra o herói andando, correndo, na esquiva nem no golpe; nenhum barra tiro.
- **P1 hit stop**: golpe que acerta inimigo e vaso juntos tem o hit stop do inimigo intacto (25, 65, 70, 50 ms e o
  `KILL_HOLD_MS`), nada somado, nada encurtado. Golpe que acerta **só** quebráveis: hit stop curto e fixo de 25 ms (o do
  golpe 1, lentidão do `HitStop`, nunca congelar), uma vez por golpe por mais vasos que quebre; nunca maior que o do
  golpe que o causou. Medir no `Fx.rate` pela sonda: três casos (só vaso, vaso e inimigo, só inimigo).
- **P1 o que o vaso não conta**: nenhum número de dano, nada no contador de golpes, Magia, passiva (P-A), carga da
  ultimate, Dons que leem `landed`, câmera lenta "3 de uma vez" nem quadro de impacto. Tranco de câmera no máximo o do
  golpe comum (0,09 m), vibração nenhuma.
- **P1 som**: `break_*` sai no quadro do contato do golpe com a peça (0 a +1 f), abaixo do impacto em inimigo
  (`hit`/`hit_heavy` 6 dB ou mais acima quando os dois tocam) e pela `VoiceGate` (2 vozes, 70 ms): seis vasos num giro
  soam como uma quebra cheia, não como rajada.
- **P1 cacos não tapam aviso**: cacos, poeira e água desenhados por baixo de todo aviso (de inimigo e de sala), com luma
  no máximo a do chão +20 e cinza ou cor do material, nunca âmbar, vermelho, esmeralda nem lilás; o decalque de água
  sem aro nem borda clara (não pode ler como aviso no chão). Cacos dentro de uma área que começa a avisar somem em até
  0,1 s ou ficam por baixo dela. Medida: captura com 3 quebras juntas sobre a mira do besteiro e a moldura de uma laje
  armada: fio da mira com saturação e luma iguais (até 5% a menos) às da mesma captura sem cacos.
- **P1 cacos não tapam o herói**: nenhum caco acima de 0,6 m depois de 0,15 s, nenhum sobre o corpo dele na tela
  (como as lascas de luz, `HERO_SHOULDER`); orçamento de 3 quebras cheias por quadro respeitado.
- **P1 quebra por inimigo e perigo**: o vaso quebra no quadro do dano do golpe ou do perigo, nunca no início do aviso (um
  vaso que estoura antes do golpe vira aviso falso).
- **P2 sensação**: o vaso responde no quadro do contato com um achatar de 2 a 3 f antes de estourar (o mesmo "dá e
  cede" do inimigo, sem recuo); caixote de 2 golpes mostra a rachadura no 1º. Cacos assentam no chão em até 0,4 s e
  ficam 4 s sem barrar nada.
- **P2 circulação**: AT-Q5 mede o tempo da sala vencida à porta (`clear_to_door_s`); se gente gastar mais de 5 s a mais
  quebrando, o "obrigado a quebrar tudo" é assunto do Game Director, não de cadência.

### 9.7 Como vou aprovar (próxima chamada)

Por perigo: um vídeo na GPU a 60 f fixos na Perto (`tools/movie.sh` ou `tools/gpu.sh` com `--frames=`, `--fixed-fps 60`,
sempre com `--quit-after`) com o aviso, uma reação boa e a consequência de ignorar; o log do perigo e o `--sound-log`
para R2, R3 e R5; GUT de R6, R9, R10 e R11; `frame_stats.py --hue` para R8 e R12; 8 sementes do robô para R13. Se faltar
quadro de dano no log de algum perigo novo, peço ao gameplay-engineer o mesmo registro do `Ground` que as Runas têm.
Quebráveis: sonda de sensação com vasos em volta, os três casos de hit stop no `Fx.rate`, a captura dos cacos sobre os
avisos e o teste da mira assistida.

## 10. C1d: lutas de chefe (2026-11-22, `docs/design/chefes_c1d.md`; robô headless 60 fps, `--bot-reaction=0.25`, 12 sementes, novato e evoluído)
Medidas por lote (hurt = dano médio no herói por encontro, tempo em s). Antes do C1d (partida com o C1b): Cavaleiro 72 (novato) e 52 (evoluído) s; Ancião 74 e 98 s, hurt 31,1 e 27,9.
- **Lote 2 (Cavaleiro K1 a K4)**: g1 72 s novato (0 de 5 morrem) e 52 s evoluído (1 de 5), g2 63 e 61 s. Dentro de 50 a 70 s e no máximo 3 mortes de 12.
- **Lote 3 (Ancião A2 e A3)**: hurt do Ancião evoluído 31,5 (g1, 1,13x) e 27,5 (g2, só 2 encontros); tempo 93 a 101 s (era 74 a 98, a blindagem dos servos alonga). Com `volley_life` 5 s o hurt subia a 38,1 (1,37x), por isso 4 s.
- **Lote 4 (Postura)**, `--start=boss`, robô 0,25, 12 sementes: fase 1 mediana 51 s (novato) e 39 s (evoluído, 29 a 48), 12 de 12 passam da fase 1 nos dois; quebras de Postura por luta 2 a 19 (a maioria por ataque, 14 golpes, e Investida).
- **Lote 5 (Condutores)**: ritual 15 a 20 s (antes 20 quase sempre; o robô derruba um condutor na maioria, dois em poucas), mínimo 10,4 s; nenhum estado trancou. Fase 2 mediana 53 a 58 s.
- **Lote 6 (Corte do rastro)**: maldições que pegam o herói 9 para 2 nas 12 evoluídas (o Brado leva a maldição junto; o robô cortou 1 com a onda, joga a onda só com Magia e a maldição a menos de 9 m); nenhuma morte por maldição a mais.
- **Lote 7 (Ruptura)**: 0 a 2 por luta (a primeira 12 s dentro da fase 4, depois a cada 25 s; nunca duas em menos de 25 s); a fase 4 dura 17 a 58 s.
- **Lote 8 (ajuste)**: Postura 900 para 1300 e vulnerabilidade x1,4 para x1,3 (as lutas ganhas duravam 111 a 144 s); depois: ganhas de 132 e 183 s (só 2 de 12), fases medianas 39 / 55 (com o ritual) / 25 / 19 s: **a luta ainda não chega a 2:40 a 3:00 na maioria** (o dano do robô evoluído é de uns 50 de vida de Morvath por segundo, 6050 de vida pedem uns 120 s mais 15 s de ritual sem dano; chegar lá pede mais vida ou menos dano, decisão do Daniel/balance-designer). Teclas: partida inteira com todas as teclas, evoluído chega a Morvath 6 de 12 (novato 0, morre no Ancião como antes do C1d); só mouse (`--bot-mouse`) chega 1 de 12 (aceite: no máximo metade, ok). Ataque 51% do dano do evoluído, 69 a 75% só mouse.

## 11. Avisos mais curtos e o Cavaleiro de 2026-11-23 (Daniel: "no outro jogo o ataque já assusta quando a animação começa; no nosso o aviso vermelho fica muito tempo")
Referência (`sworn_numeros.md`, `sworn_gawain.md`): comum corpo a corpo avisa 0,33 a 0,83 s (mediana 0,67 s); o chefe cavaleiro tem dois ritmos, rápido (cerca de 0,8 s com recuperação aberta de 0,7 s) e lento e grande (1,6 s com consequência que se estende).
Um botão só: `ENEMY_WINDUP` 0,8 em `_enemy` (`tools/make_data.gd`), vale para `attack_windup`, `close_windup`, `recharge_windup`, `guard_up_hit_windup` e `volley_windup` de todo inimigo que não é Morvath, com piso de 0,5 s (leve) e 0,6 s (pesado), nunca alonga. O Cavaleiro tem números próprios (`exact_windup`). Morvath: `windup_scale` por fase de 1, 1, 0,95, 0,9 para 0,85, 0,85, 0,82, 0,8 (`eruption_delay` 1,2 para 1,35, a leitura do círculo de 4 m fica igual: 1,08 s na fase 4).

| Inimigo | Aviso antes | Aviso depois |
|---|---|---|
| Esqueleto, soldado levantado | 0,75 | 0,60 |
| Esqueleto elite | 0,90 | 0,72 |
| Esqueleto grande | 1,10 | 0,88 |
| Corredor | 0,85 | 0,68 |
| Corredor elite / grande | 1,00 / 1,25 | 0,80 / 1,00 |
| Feiticeiro (comum e elite) | 1,00 | 0,80 |
| Besteiro, Lançador, Saltador, padre (comum) | 0,80 | 0,64 |
| Guarda (e elite), golpe de perto | 1,15 e 0,85 | 0,92 e 0,68 |
| Gritador, Coveiro, Canalizador, Trinca, Varredor | 0,90 | 0,72 |
| Armadilheiro | 0,50 | 0,50 (já no piso) |
| Ancião (leque e salva) | 1,00 | 0,80 |
| **Cavaleiro**, investida / segunda / golpe de perto / atrás do escudo | 1,00 / 0,80 / 0,80 / 0,85 | **0,60 / 0,45 / 0,50 / 0,60** |
| Morvath, golpes de fase 4 (foice 0,8, ceifa 0,85, lâminas 0,7, tempestade 0,9) | 0,72 / 0,77 / 0,63 / 0,81 | 0,64 / 0,68 / 0,56 / 0,72 |

Medido com o robô (headless 60 fps, 12 sementes, `--start=miniboss --guardian=knight`, hp do novato 30 e do evoluído 46; evoluído é `--boons=4 --forge=2 --account=6`):

| | Antes | Depois |
|---|---|---|
| Novato: vitórias, tempo médio, dano do Cavaleiro por luta | 11 de 12 (12 de 12 na medição do Daniel), 55 s, 7 | 5 de 12 (42%), 71 s (vitórias de 74 a 134 s), 23 |
| Evoluído: vitórias, tempo médio, dano do Cavaleiro | 12 de 12, 42 s, perto de 0 | 11 de 12 (92%), 59 s (46 a 67 s), 28 |

O que fez a diferença: o aviso curto com a linha que segue o herói até 0,15 s antes, o escudo arremessado (quadrado no chão, depois o anel de 12 m/s que só a esquiva atravessa) e a armadura de 1700 que só os golpes fortes abrem de verdade (`armor_soft` 0,3). O dano baixou de 18 para 14 (investida e golpe de perto), 10 (aterrissagem do escudo) e 7 (anel) porque o herói do novato tem 30 de vida e dois golpes de 16 a 18 já o matavam. O robô erra o anel 25% das vezes de propósito (`Bot.RING_SKILL`).


## 12. A pausa entre golpes dos chefes (Daniel, 2026-11-23: "o Cavaleiro fica parado muito tempo; Morvath igual; o Ancião tem boa cadência")
Medido com o robô (headless 60 fps, 6 sementes, `--start=miniboss --guardian=knight` e `--start=boss`; evoluído `--boons=4 --forge=2 --account=6` (Morvath `--boons=10`), novato `--hero-hp=30`), pelo `RESULT.idle` e `RESULT.boss.idle` (`IdleStats`). **Pausa** é do fim da recuperação ao próximo aviso; **parado** é do fim do golpe (recuperação incluída) ao próximo aviso; aberturas ganhas (parede, escudo longe, armadura quebrada, Postura, ritual, rugido) ficam fora.

| | Pausa média / p90 / máxima | Parado médio / p90 | Luta parada (andando / com a recuperação) |
|---|---|---|---|
| Cavaleiro antes (evoluído) | 0,60 / 1,10 / 1,5 s | 1,11 / 1,88 s | 30% / 55% |
| Cavaleiro depois (evoluído) | 0,65 / 1,20 / 2,5 s | 0,93 / 1,53 s | 34% / 51% |
| Morvath antes (evoluído) | 0,70 / 1,15 / 2,0 s | 1,83 / 2,83 s | 16% / 45% |
| Morvath depois (evoluído) | 0,70 / 1,15 / 2,0 s | 1,58 / 2,79 s | 17% / 43% |

O que se descobriu: a pausa depois da recuperação já era curta (0,25 a 0,75 s no Cavaleiro); o que o Daniel via parado era a recuperação (0,8 s) mais essa pausa, de 1,1 s a 1,8 s por golpe. A mudança pedida por ele: a pausa passa a ser sorteada, uniforme de 0,3 a 1,5 s com a vida cheia e encolhendo até 0,2 a 0,7 s sem vida (`AttackGap`), então a média no começo da luta é 0,9 s e cai com a vida; as recuperações do Cavaleiro (0,8 para 0,55) e de Morvath (foice 1,0 para 0,75, lâminas 0,8 para 0,6, tempestade 1,2 para 0,9, erupções 0,8 para 0,6, investida 1,1 para 0,8) encolheram; a Dupla Ceifa (2,2 s), a Ruptura, a Postura e o ritual ficaram, e o aviso de nenhum golpe mudou. Camadas simultâneas de Morvath saíram (um golpe de cada vez).
Resultados: Cavaleiro evoluído 6 de 6 (era 5 de 6 na mesma amostra), novato 3 de 6 (50%; com o dano da investida e do golpe de perto em 8, arremesso 8, anel 6 e golpe da guarda 8, que com 14 e a pausa curta deixavam o novato em 0 de 6); Morvath evoluído 4 de 6 (antes 2 de 6), novato 0 de 6 (só relatório). Ancião: ver a seção de gameplay (arqueiros).
Ancião: a pausa dele continua a de antes (média 2,3 s, `IdleStats` 64% da luta andando e atirando, que o Daniel gosta); agora chama dois arqueiros de 10 a 14 s na borda da sala: evoluído 6 de 6, novato 1 de 6, dano dos arqueiros de 0 a 15 por luta.

## CF2-01/02/05/06 (2026-11-25): peso do toque

- Hit stop (espera em ms, depois 10 ms lentos a 6%): golpe 1 25 para 35, golpe 2 65 para 60, giro/golpe 3 70 para 100; golpes 3 e 4 da Maestria (thrust4, cut4) 50/30 para 85. Tremor (`shake`, vezes 0,12 m): 0,6/0,8/1,6 para 0,9/1,1/2,4 (e 1,8 nos da Maestria). Fonte: `tools/make_data.gd` (`_tree`, `_extra_blows`). Na árvore de 3 golpes o giro é o 3.
- Sonda (`GF-01f`): esperas medidas 2, 3 e 6 quadros a 60 FPS (golpes 1, 2 e giro), crescentes; 43 de 43 verdes (`GF-10b` agora aceita até 0,12 m).
- CF2-01: não reproduzido. Com o robô em sala 1 o `_slow_cd` estava em 0 em todos os acertos (nenhum stop engolido) e a sonda mostra stop nos três golpes. Mesmo assim a cooldown de 0,15 s agora só vale para o mesmo golpe (`_slow_node`), então um golpe novo da corrente nunca é engolido.
- CF2-05: Investida 35 ms por alvo, no máximo 3 (105 ms).
- CF2-06 (parcial): pitch do som de acerto 1,00 / 0,94 / 0,86 (golpe 1 / 2 / finalizador) e o grave `hit_heavy` por baixo do finalizador. Sem o abaixamento da música no Apogeu/Brado.
- Não feitos: CF2-03 (precisa de `Fx.punch` em `fx.gd`, fora do escopo de hoje) e CF2-04 (recuo do inimigo, mexe na `horde.gd`).


## 13. Plano SWORN, fase 1 (SW-C1, C2, C3, C6; 2026-11-25): tempos novos do herói

Fonte dos números do SWORN: `docs/design/sworn_rea_kingswood_2026-11-25.md` 1.2 e 1.4. A regra do PO (golpe parado, 1 < 2 < 3,
preparação-golpe-recuperação) não mudou. Tempos em segundos desde o aperto; "próximo leve" = quando o golpe seguinte do
combo pode sair; as janelas moram em `ComboNode.cancel_*_from` (`tools/make_data.gd`).

| Golpe | Dano antes / depois | Empurrão (m) antes / depois | Impacto aos | Próximo leve (nosso / SWORN) | Esquiva corta | Especial, Brado, Investida cortam | Pausa 1 corpo / 2 / 3 ou mais (ms) antes / depois |
|---|---|---|---|---|---|---|---|
| cut1 | 15 / 15 | 0,36 / 0,10 | 0,08 | 0,21 / 0,30 | desde 0 | desde 0 | 35 de espera + 10 / 120, 90, 60 |
| cut2 | 15 / 15 | 0,43 / 0,10 | 0,13 | 0,35 / 0,30 | desde 0 | desde 0 | 60 + 10 / 120, 90, 60 |
| cut3 (giro) | 20 / **30** | 2,3 / 2,3 | 0,36 | 0,66 / 0,63 | desde 0 (antes só depois do impacto) | desde 0 | 100 + 10 / 160, 110, 60 |
| Brado, Investida, Ômegas | iguais | iguais | iguais | | desde 0 | | iguais (`hit_stop_ms`) |

- Antes, especial e Brado esperavam a recuperação inteira; agora cortam a preparação e a recuperação (o golpe cortado antes do impacto não acerta).
- A pausa antes era só o "espera" em velocidade cheia mais 10 ms a 6% (o que se sente é o trecho lento); agora a pausa total é o número da tabela (20 ms em velocidade cheia e o resto a 6%), constantes `Combat.PAUSE_*` num lugar só.
- Esquiva medida (SW-C6): 0,2 s (SWORN 0,2), 5,6 m (SWORN 2,5), protegido de 0 a 0,2 s (SWORN igual), recarga 0,8 s a contar do começo da esquiva (SWORN 0,8), 1 carga (+1 pela Bênção Passos; SWORN 1, +1 na meta). Igual ou melhor, sem mudança.


## 14. Recuperação e espera depois do golpe, e o Cavaleiro do Butcher (2026-11-25, `docs/design/sworn_rea_butcher_2026-11-25.md`; testes em `tests/test_knight_phases.gd`)

Pedido do Daniel: "ainda acho os bosses meio lentos, tanto no ataque quanto na recuperação... a janela de contra-ataque fica meio grande... o nosso cavaleiro é parecido com o butcher do SWORN, vamos pegar os mesmos números e mecânicas, só não coloca o pulo". Medido: os chefes de SWORN (Butcher, Lady Kay) não esperam nada entre um ataque e outro, só a cauda da animação; os comuns leves ficam parados 0,6 a 0,85 s.

**Parado depois do golpe (`recover_time`) e tempo até o próximo dano** (recuperação + espera 0,25 a 0,75 dos comuns + aviso final):

| Inimigo | Parado antes | Parado agora | Até o próximo dano antes | Agora |
|---|---|---|---|---|
| Esqueleto (elite) | 1,2 (1,0) | 0,75 (0,65) | 2,05 a 2,55 | 1,6 a 2,1 |
| Corredor | 1,35 | 0,8 | 2,3 a 2,8 | 1,75 a 2,25 |
| Trinca (elite) | 1,0 (0,8) | 0,7 (0,6) | 1,9 a 2,4 | 1,6 a 2,1 |
| Rato de osso | 0,7 | 0,6 | 1,45 a 1,95 | 1,35 a 1,85 |
| Saltador | 1,0 | 0,8 | 1,9 a 2,4 | 1,7 a 2,2 |
| Escudo (elite) | 1,1 (1,1) | 1,0 (0,9) | 2,3 a 2,8 (aviso 0,92) | 1,95 a 2,45 (aviso 0,70) |
| Esqueleto grande | 1,4 | 1,1 | 2,5 a 3,0 (aviso 0,88) | 2,05 a 2,55 (aviso 0,70) |
| Corredor grande | 1,2 | 1,0 | 2,65 a 3,15 | 2,45 a 2,95 |
| Varredor | 1,4 | 1,1 | 2,6 | 2,3 |
| Feiticeiro | 0,8 | 0,65 | pelo `attack_cooldown` | igual |
| Capitão | 1,1, espera 0,4 a 1,4 (0,3 a 0,8 no fim) | 1,0, espera 0,2 a 0,8 (0,1 a 0,4) | 2,7 a 3,7 | 2,4 a 3,0 |
| Cavaleiro | 0,55, espera 0,3 a 1,5 (0,2 a 0,7) | 0,9, espera 0 a 0,15 (0 a 0,05) | 1,45 a 2,65 | 1,55 a 1,70 |
| Morvath | espera 0,1 a 0,7 (0,05 a 0,3); ceifa dupla 1,4; tempestade 0,9 | espera 0 a 0,3 (0 a 0,1); 1,1; 0,8 | 1,3 a 2,9 | 1,0 a 2,5 |

O Ancião e os atiradores (besteiro, lanceiro) ficam como estão. Os avisos finais do Escudo e do Esqueleto grande saem de 0,875 no `make_data` (o `_quick` multiplica por 0,8 e dá 0,70) em vez de `exact_windup`, para o golpe de perto do Escudo seguir o `_quick`. Nos chefes e guardiões o sorteio some, mas `gap_max` fica acima de 0 (0,15 no Cavaleiro, 0,3 em Morvath): `gap_max` 0 devolve o jogo ao `AFTER_RECOVER`.

**Cavaleiro, "Butcher sem pulo"**: vida 500 e armadura 1400, 6,0 m/s (o herói anda 6,75), investida com aviso 0,65, arranque 24 m/s por 0,3 s (7,2 m), dano 12, uma por vez, alcance 12, cooldown 1,8; arremesso de escudo com anel (cooldown 10, primeiro 5, sem distância máxima; aviso da queda 0,85 s, voo 1,1, anel 7,5 m/s, 22 m, dano 12 e 6); golpe de perto 8; guarda por tempo no papel do giro louco (a cada 10 s, aviso 0,85, 3,2 s, anda a 50%, golpe a cada 0,53 s a até 4 m, dano 8); `raise_max` 4. Mantidos: investida rápida, onda que só a esquiva atravessa, golpe forte tira o escudo, `wall_stun`, barra de atordoamento x1,25.

**Fases por vida** (`KnightPhase`, `EnemyDef.roar_marks`, `guard_up_life`, `raise_life`, `KnightMove.from_life`; porcentagem da resistência total, vida mais armadura):

| Fase | Entra em | Soma | Rugido |
|---|---|---|---|
| 1 | 100% | investida, golpe de perto, arremesso do escudo | |
| 2 | 80% | guarda por tempo, só com o herói a até 6 m; termina com 2 s parado | sim, 1,78 s parado e atingível |
| 3 | 60% | chamado de 3 esqueletos, no máximo 4 vivos, a cada 30 s (o primeiro a 10 s da luta) | |
| 4 | 40% | investida dupla (a única coisa que o Cavaleiro já tinha e o Butcher não) | sim |

Fica de fora: as ondas no chão que perseguem (fase 2 do Butcher) e as erupções (fase 4), que pedem zonas novas; no lugar, a fase 4 usa a investida em fileira de 2 que o Cavaleiro já tinha. Risco: com espera zero e dano 12 o Cavaleiro bate muito mais no robô (ver `balance.md`, SW-REA).


## 15. Passinho em todo golpe (PT-25-4 e PT-25-11, 2026-11-25): a regra "parado" do início deste documento foi substituída

Pedido do Daniel: "atacar e andar um pouquinho é sempre melhor, mesmo que seja um passinho pequeno". A preparação continua parada
e as pernas continuam presas (`move_hold`); no instante do impacto o corpo dá um passo curto na mira (`ComboNode.step`, `STEP` em
`tools/make_data.gd`), que para nos corpos e nas paredes. Nada mudou nos tempos de preparação, recuperação e janela da matriz de
`sworn_phase1` (seção 13).

| Golpe | Preparação | Impacto | Passo à frente (novo) | Recuperação | Pernas presas |
|---|---|---|---|---|---|
| E1 (`cut1`) | 0,08 s | f5 | **0,3 m** (era 0) | 8 f | 11 f |
| E2 (`cut2`) | 0,13 s | f8 | **0,3 m** (era 0) | 13 f | 19 f |
| E3 (`cut3`, giro) | 0,28 s + 0,08 de brilho | f22 | **0,8 m** (era 0) | 18 f | 30 f |
| 5 golpes (`cut4`, `thrust4`) | 0,12 / mesmo da estocada | no impacto | 0,3 m / 0,3 m | 9 f | 12 f |

Soma do combo: 1,4 m (medido no teste: 1,4 m com 0,15 de folga). O passo largo do final é para alcançar quem os golpes 1 e 2 empurraram
(0,1 m cada, `COMBO_PUSH`). Não toca na Investida (`lunge`, da pressão do botão), nem no especial, nem nas Ômegas. A julgar
no jogo: se parecer deslize, baixar `STEP` ou encurtar o decaimento (`Player.LUNGE_DECAY`).


## Revisão 2026-11-26 (combat-feel-director, antes da entrega; leitura de código e dados mais 2 partidas do robô, `--start=miniboss`, sementes 5 e 6, `--runlog`)

Sem capturas nesta revisão: tudo abaixo é **medido no código/dados** (arquivo citado) ou **hipótese** (marcada). Dono de todos os itens: gameplay-engineer. Nada foi implementado.

**Resultado do passinho (PT-25-4/11).** Conferido: `Player._step_in` soma `facing * step * LUNGE_DECAY (9)` no impacto e o decaimento por quadro a 60 fps devolve quase exatamente `step` metros (soma geométrica de `v0*dt/(1-(1-9dt))`). O passo respeita corpos (`stop_walker`), paredes (`arena.sweep`) e buracos (`keep_out_of_gaps`); a esquiva zera `_lunge` (linha 978); a Investida sobrescreve (linha 1054). Sem bug de lógica encontrado. Soma do combo de 3: 1,4 m (5 golpes: 2,0 m).

**Cavaleiro com armadura 550 e `armor_soft` 0,5.** Duas partidas do robô: luta de 21 s (sementes 5 e 6), `breaks.special` 1, o Cavaleiro bate 1 vez (12) na semente 5 e 0 na 6; `idle` do Cavaleiro: média 0,13 s, máximo 0,65, 7% da luta parado; avisos iniciados 13 e 15, cortados 2 e 2. A quebra da guarda agora existe; o risco é o contrário, ficar fácil (ver P1-1).

### P0
Nenhum encontrado. Nenhum comando involuntário, teleporte ou estado preso nas duas partidas (`stuck` 0, `died_stuck` falso).

### P1
- **P1-1 Cavaleiro cai depressa demais com o robô.** Causa: hipótese forte (número medido). Número atual: ~21 s de luta focada, com `hp_scale` 0,7 na Casa do Cavaleiro (`make_data.gd` linha ~3078) e `hurt_by` 0 a 12 em 90 s. Proposta: manter 550/0,5 (o Daniel precisa quebrar a guarda) e compensar na vida: tirar o `hp_scale` 0,7 da Casa ou subir `hp` 500 para ~650, para a luta ficar entre 30 e 40 s do robô. Critério: 12 sementes, duração 30 a 40 s e dano ao herói de 12 a 36. Decisão de dificuldade é do Game Director (a memória diz "ainda fácil demais").
- **P1-2 Passo do final em 7,2 m/s inicial.** Causa: hipótese (precisa de captura quadro a quadro). `STEP[2]` 0,8 m com `LUNGE_DECAY` 9 sai a 7,2 m/s no primeiro quadro, acima da corrida (6,75), com as pernas "presas" (`move_hold` 30 f): pode ler como patinada, a mesma queixa do Daniel de E1c ("eu fico patinando"). Proposta: `LUNGE_DECAY` próprio do passo, 6 (pico 4,8 m/s, 0,8 m em ~0,4 s, cabe no `move_hold` de 0,5 s), ou manter 9 e baixar `STEP` do final para 0,6. Critério: captura 60 fps do E3 sem deslize visível, ou Daniel aprova. Pedir ao Game Director uma captura do combo 1-2-3 em Perto (`--bot`, sem opção extra) se for medir.
- **P1-3 Passo rouba o recuo do alvo no final.** Causa: dado. E3 empurra 2,3 m e passa 0,8 m; E1 e E2 empurram 0,1 e passam 0,3 (o herói fecha 0,2 por golpe, até encostar no corpo e parar). Em grupo o passo para no corpo e só o primeiro inimigo é "empurrado", o resto fica. Proposta: nenhuma mudança agora; reavaliar na captura do P1-2. Hipótese, sem número novo.

### P2
- **P2-1 Residual do passo atravessa o cancelamento.** Causa: leitura de código. Especial/Brado cortam o golpe desde o instante 0 e só a esquiva zera `_lunge`; o passo restante (até ~0,1 m) escorrega durante a preparação do especial. Proposta: zerar `_lunge` em `_on_move_started` quando `node.lunge == 0` e o golpe não é do combo (ou aceitar). Critério: especial logo depois do E1 sem deslizar.
- **P2-2 O passo pode levar o herói a perigos de chão.** Hipótese: placas de espinho e runas não bloqueiam (`sweep` só trata paredes e buracos), então 2,0 m de combo (5 golpes) empurram o herói para dentro de uma placa na mira. Proposta: o passo ignora o golpe se o ponto final cair em perigo armado (`plate_floor`), ou aceitar como regra de leitura. Dano de perigo é 10.
- **P2-3 Documentação e comentários velhos.** `tools/make_data.gd` linhas ~109 a 112 ainda dizem "struck standing still (no lunge)" e a linha ~430 ainda diz "Armor 1220"; a seção 14 deste documento diz armadura 1400 e a frase de abertura do documento ("golpe parado") só está corrigida na seção 15. `gameplay.md` linha 779 está certa (550 e 0,5).

### Quickwins
- **QW-1** Corrigir os comentários do P2-3 (sem mudar número, regenerar não é preciso).
- **QW-2** Teste de `_step_in`: o de 1,4 m já existe; falta um teste para cut4/thrust4 (2,0 m) e para parada no corpo.
- **QW-3** Adicionar ao relatório do `--runlog` o tempo de luta do guardião (hoje só se deduz de `rooms[].time`).

### Chefes e inimigos (cadência do Daniel: ataque e recuperação mais rápidos)
Não auditados a fundo nesta passada (sem captura): os números da seção 14 estão no código (Cavaleiro espera 0 a 0,15, Morvath 0 a 0,3) e o robô os confirma (`idle` médio 0,13 s). Pendente para a próxima revisão, com captura do Game Director de Morvath na fase 2 e do esqueleto grande: aviso no chão contra golpe real, e recuperação da ceifa dupla (1,1 s).
