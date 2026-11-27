> Índice: [combat_cadence.md](../combat_cadence.md)

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
