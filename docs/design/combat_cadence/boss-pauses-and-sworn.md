> Índice: [combat_cadence.md](../combat_cadence.md)

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

**Cavaleiro, "Butcher sem pulo"**: vida 650 (era 500; 2026-11-26) e armadura 550 com `armor_soft` 0,5 (o 1400 de antes foi trocado pela quebra de guarda), 6,0 m/s (o herói anda 6,75), investida com aviso 0,65, arranque 24 m/s por 0,3 s (7,2 m), dano 15 (era 12), uma por vez, alcance 12, cooldown 1,8; arremesso de escudo com anel (cooldown 10, primeiro 5, sem distância máxima; aviso da queda 0,85 s, voo 1,1, anel 7,5 m/s, 22 m, dano 12 e 6); golpe de perto 8; guarda por tempo no papel do giro louco (a cada 10 s, aviso 0,85, 3,2 s, anda a 50%, golpe a cada 0,53 s a até 4 m, dano 8); `raise_max` 4. Mantidos: investida rápida, onda que só a esquiva atravessa, golpe forte tira o escudo, `wall_stun`, barra de atordoamento x1,25.

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


## 16. Revisão 2026-11-26, o que foi feito (gameplay-engineer)
- **Passo do golpe**: `StepRules.DECAY` 6 (era o `LUNGE_DECAY` 9 da Investida); o passo vive em `Player._step`, separado de `_lunge`. Mesmos metros, pico menor:
  o final (0,8 m) sai a 4,8 m/s (a corrida é 6,75). Preparação do especial, do Brado e da Investida (qualquer golpe que não é `LIGHT`) zera o resto do passo.
  O passo não é dado se terminaria dentro de uma armadilha de chão armada ou aquecendo (`Ground.room_rects`, margem do raio do herói) em que ele ainda não está.
  Para em corpo e parede como antes (`stop_walker`, `sweep`). Testes: `tests/test_step_rules.gd` (inclui `cut4`, `thrust4` e a parada contra corpo).
- **Cavaleiro**: vida 650, `hp_scale` 1,0 na sala 5, `attack_damage` 15; armadura 550 e `armor_soft` 0,5 intactas. Robô (reação 0,25, `--start=miniboss`, `--boons=5`,
  6 sementes com Cavaleiro): luta 20,8 a 33,2 s, mediana 28,5 s (antes 14 a 24 s, mediana 16,4); dano ao herói 0 em 4 de 6, 5 e 5 nas outras
  (o robô esquiva quase tudo; o critério de 12 a 36 só o teste de gente confirma).

## Varredura 2026-11-26b (gameplay-engineer, leitura de código, sem mudança de número nem de código)
- **Itens da Revisão 2026-11-26 conferidos**: P1-1 (Cavaleiro 650, `hp_scale` 1,0), P1-2 (`StepRules.DECAY` 6), P2-1 e P2-2 (passo zerado fora do `LIGHT` e recusado em armadilha armada), QW-1 e QW-2 já estavam feitos (seção 16; comentários de `make_data.gd` já dizem "short step"). P1-3 segue sem mudança até haver captura. Abertos: QW-3 (tempo de luta do guardião no `--runlog`, só relatório) e a auditoria de Morvath fase 2 e esqueleto grande (precisa de captura do Game Director).
- **Revisão de `celestial.gd` e `Combat.hit_enemy`** (Bênçãos V1): conferido, sem bug encontrado. Esquiva só dispara Clarão, Escudo do Passo Firme e Marcas (não conta Cadência nem estados de golpe); `after_hit` só roda em golpe direto e vivo, uma vez por status e alvo (`CelState.once`); dano secundário (eco, combustão, turbilhão) passa por `_secondary` com `stun_scale` 0 e não dispara nada; eco do Brado leva um recarregamento por ação e Exército de Ecos não soma com o eco do especial (fica o maior). Observação de design (não mexida): estados ainda se aplicam quando a guarda do alvo reduz o golpe (`shut`); é leitura aceitável, o Daniel decide.
- `test_blessings_v1_combat`: 30 de 30. Smoke RESULT inalterado (nada de gameplay mudou).
