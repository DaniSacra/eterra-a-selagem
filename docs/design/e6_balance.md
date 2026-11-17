# E6, balanceamento da primeira região: decisões

Data: 2026-11-17. Dono: `gameplay-engineer`. O Daniel estava fora; as decisões seguem as recomendações do backlog
(seção "E6 Balanceamento da primeira região") e ficam aqui para ele validar no teste. Medidas completas, comandos e
tabelas por semente em `docs/qa/e6_metrics.md`.

## Como medimos

- Robô com reação humana: `tools/smoke.sh 900 --seed=N --bot-reaction=0.25`, descida padrão de 10 salas e Morvath na 11.
- **Maestria 1**: sem Dons e sem ultimate (o robô não lê o save).
- **Maestria 20**: Devoção 25, todos os Dons destravados, por `--talents=` e `--ultimate=cleave`. O robô não escolhe
  Dons, então medimos as montagens que um jogador faria e vale a mais forte:
  - **Ofensiva** (a do QA na E2, 21 de Devoção): `quarto_corte, passo_encadeado, impeto, avanco_feroz,
    corte_crescente, lamina_faminta, fio_longo, reserva, firmeza`.
  - **Sustento** (24 de Devoção, a mais forte medida): `ainda_de_pe, firmeza, respiro, quarto_corte, impeto,
    lamina_faminta, reserva, corte_crescente, fio_longo`.
  - Também medidas: sem Ainda de Pé (`passo_encadeado, avanco_feroz` no lugar) e com os ápices (`golpe_sem_fim`,
    `coracao_da_emeth`), as duas abaixo da de sustento.
- 72 sementes (1 a 72) por montagem, as mesmas para todas. Com 72 partidas um ponto de vitória a mais ou a menos muda
  a conta em 1,4 ponto; o erro de uma taxa perto de 75% é de uns 5 pontos.

## Resultado

| | Antes (HEAD `224782a`, 24 sementes) | Depois (72 sementes) |
|---|---|---|
| Maestria 1 | 16 de 24 (67%) | 52 de 72 (72%) |
| Maestria 20, ofensiva | 21 de 24 (88%) | 62 de 72 (86%) |
| Maestria 20, sustento | 72 de 72 (100%) com o robô novo e Ainda de Pé em Morvath | 65 de 72 (90%) |
| **Diferença (montagem mais forte)** | **+28 pontos** (acima do teto de 25) | **+18 pontos** |

Aceite da E6: Maestria 20 até 25 pontos acima da Maestria 1, com folga: **cumprido, 7 pontos de folga**. Indicador da
meta D-11 (robô 0,25 com Maestria 1 vence 3 a 6 de 8, 37 a 75%): **72%**, dentro, perto do topo.

## Decisões

### E6-D1, Ainda de Pé não levanta na Câmara do Selo (nota 1)

- **Medida**: com Ainda de Pé a Maestria 20 nunca perdeu (72 de 72). As 8 derrotas da mesma montagem sem o Dom viraram
  vitórias: o robô cai uma vez, na fase 4, e o Dom o põe de pé. Sozinho, o Dom vale 11 pontos de vitória.
- **Tentado e descartado**: levantar com 30% da vida em vez de 50% (71 de 72): o resto da luta é curto e o robô termina
  com qualquer vida. Mexer na dificuldade de Morvath também não serve: tudo que derruba a Maestria 1 aumenta a diferença,
  porque quem tem uma segunda vida só perde se cair duas vezes.
- **Decisão**: Ainda de Pé continua "uma vez por descida, com metade da vida", mas não vale na sala de Morvath. Morvath é
  a prova da região para qualquer Maestria; o Dom guarda a descida, que é onde gente cai mais (o robô quase não apanha
  nas salas, gente apanha muito mais). Texto do Dom: "Uma vez por descida, ao cair antes da Câmara do Selo, você levanta
  com metade da vida."
- **Como é dado**: a vida do levantar em Morvath é a estatística `rise_boss_share` (hoje nenhum Dom a tem, então é 0);
  dar o levantar de volta lá é só pôr `_fixed(&"rise_boss_share", x)` no Dom, no `make_data.gd`. Regra em
  `GiftState.boss_room`, ligada por `Game._start_boss`.
- Diferença do Hades II: lá o desafio à morte vale também no chefe. Aqui os Juramentos (D-63) ainda vão dar a dificuldade
  por escolha; quando vierem, dá para medir de novo e devolver o levantar em Morvath.

### E6-D2, o robô joga os eventos como uma pessoa sensata (nota 6)

- **Provação**: o robô ainda paga a laje com 60% da vida sobrando (só vê a maldição lá dentro, como gente), mas escolhe a
  carta: maior raridade da bênção contra o custo da maldição para o plano dele (`Trials.bot_card`, `BOT_CURSE_COST`:
  Frágil 3, Horda 2, Pressa 2, Ferida 1, Pobreza 5 enquanto a loja estiver à frente, 0 depois). Antes pegava a
  primeira e, com Pobreza, chegava à loja sem ouro. Nas 24 primeiras sementes da Maestria 1: Pobreza de 3 vezes para 0,
  e quem chegava à loja sem comprar caiu de 2 para 0.
- **Altar**: o robô só entra pela porta do altar quando vai trocar algo lá (`Rooms.bot_door(doors, altar_useful)`); antes
  entrava e saía sem trocar (3 de 24 partidas da Maestria 1 perdiam uma sala assim). Romã por vida quando sobram 35 de
  vida máxima (como antes); velas só se o ouro que sobra ainda paga a cura da loja (`Altar.BOT_GOLD_KEEP` 50).
- `--autopick` (capturas) segue pegando a primeira carta da Provação.
- Efeito: a Maestria 1 subiu de 67% (24 sementes) para 72% (72 sementes); o robô ficou mais forte, o jogo não mudou.

### E6-D3, ultimate: a carga continua pela Magia gasta (nota 3)

- **Medida**: a carga já passa de uma sala para outra (`Ultimates.clear` guarda a carga). Na sala de Morvath a U-1 sai
  em média 1,8 vez por luta (0 a 3) e tira 580 de vida (cerca de 10% dos 6050); na descida inteira, 5 a 7 usos.
  `RESULT` ganhou `ult.boss_uses` e `ult.boss_damage`.
- **Decisão**: nada muda. A carga pela Magia gasta é a do Hex do Hades II (D-54) e a sala de Morvath não a impede.

### E6-D4, vida de Morvath fica em 6050 (nota 4)

- **Medida** (robô, Maestria 1, 72 sementes): luta de 104 s em média (42 a 166 s); fases nas vitórias 25 / 39 / 20 /
  21 s. Com a vida 10% maior (6650, 24 sementes): luta de 110 s e **a mesma taxa de vitória** (20 de 24 nas duas).
- **Decisão**: a vida não é a alavanca da dificuldade, só do tempo, e o robô bate mais que gente (pune de 70 a 90% das
  janelas de Morvath). Gente com 60 a 70% do dano do robô por segundo leva de 150 a 175 s: dentro dos 2 a 4 min. Fica a
  vida do Hades (6050). Medir de novo com o registro de gente (`user://runs.jsonl`, `boss.phase_time`).

### E6-D5, tempo da descida (nota 5)

- Robô, Maestria 1: chega em Morvath aos 4 min 11 s (3 min 16 s a 5 min 12 s) e vence aos 6 min (5 a 7 min 38 s).
- Gente leva mais e não é preciso atrasar o jogo: o robô não lê cartas (escolhe sem tela), não para na loja, anda
  direto à porta, quase não apanha nas salas (19 de dano por descida) e bate mais. Fator esperado de 1,7 a 2,2 vezes:
  10 a 13 min, a meta. Conferir no primeiro registro de gente.

### E6-D6, mais dano antes de Morvath com Dons (nota 2): não se repete

- A nota da E2 (123 contra 76) era da descida de 7 salas e de 16 sementes, quase tudo do guardião Ancião
  (`priest_elder`: 81 contra 27).
- Hoje, descida de 10 salas, 72 sementes: Maestria 1 leva 1388, ofensiva 1229, sustento 1256: **com Dons leva menos**.
  Na de 7 salas (`--medium`, 16 sementes): 130 contra 145, o Ancião é a maior fonte nas duas (86 e 99).
- Nenhuma regra de Dom deixa o robô mais exposto. Com Dons ele esquiva menos (4066 contra 5214 esquivas nas 72 descidas antes de Morvath)
  porque as salas acabam antes. Sem mudança.

### E6-D7, `--hero-equip=quarto_corte,impeto,reserva` (nota 7): não é erro de regra

- Reserva é o meio do ramo da Magia e pede a entrada do ramo (Lâmina Faminta) equipada (`warrior_spec.md` 4.1), e sem
  `--hero-xp` a Maestria é 1, onde Ímpeto (nível 3) e Reserva (nível 10) ainda estão trancados. Além disso o robô não lê
  o save: com `--bot`, `--hero-equip` não vale (usar `--talents`).
- Mudança: agora o jogo avisa o que ficou de fora e por quê (`Talents.why_dropped`, `Game._warn_dropped`: "Gift reserva
  not equipped at Mastery 20: NEEDS") e que o robô ignora `--hero-equip`.

### Correção achada na medição

- A fatia de romã da loja (`Game.grow_random`) dava `SCRIPT ERROR` (índice fora do vetor): o `_take` limpa
  `offer_cards`, que era o próprio vetor das cartas. A Bênção crescia, mas a palavra na tela quebrava. Corrigido, com
  teste.

## Pendências

- Medir com gente (D-11 pede teste humano): primeira vitória em até 3 tentativas para quem jogou Hades.
- Juramentos (D-63, outro agente): quando existirem, medir Maestria 20 com eles e decidir se o levantar volta em Morvath.
- O robô na loja compra o primeiro item que paga (às vezes a Bênção de 150 em vez da cura); não mexido.
