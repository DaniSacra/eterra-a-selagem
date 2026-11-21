# Equilíbrio de A Selagem

Dono: `balance-designer`. **Só medida e proposta**: nenhum número, código ou dado do repositório foi mudado por este
documento. Os números vão para o `gameplay-engineer` pelo Game Director; o que mexe no tempo de um ataque passa antes
pelo `combat-feel-director`.

## Meta nova do Daniel (2026-11-21, noite): "me sentir muito fraco no começo"

> "Eu queria me sentir muito fraco no começo do jogo onde eu mais perco do que venço no minichefe... pq só desta
> maneira eu vou sentir as evoluções do santuário."

- **Herói novo (Maestria 1, sem Forja, sem Dons): perde mais do que vence no guardião da sala 6.** Régua do robô 0,25:
  das descidas que chegam ao guardião, menos de 50% passam dele; vitória sobre Morvath quase nunca (0 a 10%).
- **Cada evolução do Santuário tem de se sentir**: o mesmo robô com a Forja, os Dons e a Maestria das primeiras ~5
  descidas passa do guardião na maioria das vezes. A diferença sem e com evolução é o que importa (meta: 25 a 40
  pontos no "passa do guardião").
- O dano inicial do herói desce (a rajada, o Brado e a Fúria somados estavam limpando as primeiras salas); quem paga a
  diferença é o Santuário, não as Bênçãos da partida.
- Substitui a primeira linha da tabela B.3 (Maestria 1 a 5).
- **Medido (12 sementes, robô 0,25, depois da rajada 35/12, Investida +2, Brado 15%)**: novato morre em 40% dos
  guardiões (Ancião 3, Cavaleiro 1), 0 vitórias; evoluído (`--talents=quarto_corte,impeto,corte_crescente,lamina_faminta
  --forge=2`) morre em 33%, 1 vitória. **A diferença é de só 7 pontos: as evoluções do Santuário estão fracas** (meta
  25 a 40). Cavaleiro endurecido (investe a cada 2,4 s, golpe 18). Próximo: árvore da conta (Lote 5) e Dons/Forja mais
  fortes, não guardião mais forte.

## Lote B (2026-11-21): "mais difícil, principalmente sem os upgrades"

### B.0 Pedido do Daniel (substitui as metas de 2026-11-19)

O jogo fica mais difícil, **principalmente sem os upgrades**: a primeira descida, sem Maestria, Forja nem Dons, tem de
ser bem mais difícil que hoje; com os upgrades (Maestria, Dons, Forja, o que o hub der) a curva continua a crescer.
**Proibido inflar a vida dos inimigos**: a dificuldade vem do dano, da ordem em que a força chega e das salas. Os
Juramentos seguem sendo a dificuldade depois da primeira vitória.

### B.1 Como medi

- Cópia isolada do código `07688f5` (fora do repositório) e uma segunda cópia "proposta" com o pacote abaixo aplicado
  no `make_data.gd` (regerados `enemies bosses stage`) e a OF-05 provisória no `RunMap._may` (Prata desde a
  profundidade 4, Memória depois da camada do guardião). O HEAD `343d251` (perigos 10) chegou durante a medida: a base
  daqui ainda tem os perigos a 7; a proposta já tem 10.
- `godot --headless --fixed-fps 60 -- --bot --nosave --smoke=900 --seed=N --bot-reaction=R` (o `tools/smoke.sh 900`),
  no máximo 4 ao mesmo tempo (máquina dividida com outros agentes). **Medida incompleta**: as montagens principais
  com as sementes 1 a 23 (22 a 23 descidas cada), as secundárias com 1 a 12; o plano era 48. Erro de uma taxa com 23
  descidas: uns 10 pontos; com 12, uns 14. Diferenças menores que isso são ruído.
- Montagens (o robô não lê o save; Dons por `--talents=`, ultimate por `--ultimate=cleave`, Forja por `--forge=3
  --refine=refine_fio,refine_onda_larga` = Temperar I a III e um Refinar em cada ação):

| | Hoje (escada atual) | Proposta (escada B-3, ultimate na Maestria 6) |
|---|---|---|
| M1 | nada | nada |
| M5 | `quarto_corte, impeto, corte_crescente, lamina_faminta` + ultimate | as mesmas, **sem ultimate** |
| M10 | ofensiva (`quarto_corte, impeto, avanco_feroz, corte_crescente, fio_longo, lamina_faminta`) + ultimate | `quarto_corte, impeto, firmeza, lamina_faminta, corte_crescente, passo_encadeado, fio_longo` + ultimate |
| M15 | `quarto_corte, impeto, corte_crescente, lamina_faminta, passo_encadeado, avanco_feroz, fio_longo, reserva` + ultimate | `quarto_corte, impeto, firmeza, respiro, lamina_faminta, corte_crescente, passo_encadeado, fio_longo` + ultimate |
| M20 | sustento do E6 (`ainda_de_pe, firmeza, respiro, quarto_corte, impeto, lamina_faminta, reserva, corte_crescente, fio_longo`) + ultimate | igual |

- Pacote medido na cópia "proposta" (P-50): dano de todo inimigo comum e de Morvath vezes cerca de 1,5 (esqueleto 5,
  corredor 8, feiticeiro 6, besteiro 5, Escudo 14 e 11 de perto, sacerdote 9; Morvath 12/15, Foice 18, Ceifa,
  Lâminas, Tempestade e Erupções 15, Maldição 9, Investida 18), Cavaleiro 16 e Ancião 12 (B-5), perigos 10 (a
  borda que desmorona 7), `base_difficulty` 70 e `depth_ramp` 17 (B-4), OF-05.

### B.2 Estado medido (vitórias do robô)

| Montagem | Hoje 0,25 | P-50 0,25 | Hoje 0,45 | P-50 0,45 |
|---|---|---|---|---|
| M1, sem Forja | **11/23 (48%)** | **8/23 (35%)** | 3/22 (14%) | 2/23 (9%) |
| M1, Forja III + Refinar | 15/21 (71%) | 8/22 (36%) | 5/12 (42%) | 2/12 (17%) |
| M5 | 13/22 (59%) | 7/22 (32%) | 4/12 (33%) | 0/12 (0%) |
| M10 | 17/22 (77%) | 10/22 (45%) | 3/22 (14%) | 7/23 (30%) |
| M10, Forja | 7/12 (58%) | 8/12 (67%) | | |
| M15 | 15/21 (71%) | 12/21 (57%) | 4/12 (33%) | 4/12 (33%) |
| M20 | 19/23 (83%) | 16/23 (70%) | 12/22 (55%) | 7/22 (32%) |
| M20, Forja | 18/21 (86%) | 15/22 (68%) | 7/12 (58%) | 6/12 (50%) |

Leitura:

1. **Hoje a curva é plana e alta no começo**: M1 48%, M5 59%, M10 77%, M15 71%, M20 83% (0,25). A Forja sozinha leva a
   M1 de 48% a 71% (+23, no limite do ruído): hoje um jogador sem Dons com a Forja vence quase como a Maestria 10.
2. **Com o P-50 a curva sobe em toda a escada** (35, 32, 45, 57, 70), a diferença M1 para M20 é a mesma de hoje (35
   pontos), mas tudo desceu 13 a 32 pontos. A M5 sem ultimate fica igual à M1 (os Dons ofensivos não mexem na taxa,
   como em 2026-11-19); a ultimate e a Firmeza juntas (M10) valem +10 a +13, o Respiro (M15) +12, o Ainda de Pé (M20)
   +13.
3. **A Maestria 1 ainda vence demais**: 35% contra a meta de 20 a 30% (robô 0,25). +50% de dano tirou só 13 pontos da
   M1 (em 2026-11-19, +60% tiravam 25): o limiar fica entre 50 e 60%. Daí B-1 a 1,6.
4. **Régua 0,45**: a M1 já está em 9 a 14% hoje (a queda da Fatia 2, o robô leva menos corações); o que muda com o
   pacote é o topo (M20 55% para 32%), que fica um pouco abaixo da meta: o Morvath a 1,5 pesa mais que as salas para
   quem reage tarde (14 das 15 mortes da M20 0,45 nele, fases 3 e 4).
5. **Onde se morre (P-50, 0,25, M1)**: 10 antes de Morvath (6 no Santuário, a casa do guardião; Runas 2; Ponte e
   Cripta 1), 5 nele (fase 4 quatro vezes). O Santuário tem 40% das mortes (meta 25 a 35%). Fontes de dano nas salas:
   Cavaleiro 25%, feiticeiro 18%, Ancião 17%, besteiro 13%, Runas 11% (com 10 de dano; eram 1% com 7).
6. **Dano por sala (M1, 0,25), hoje e P-50**: salas 1 a 3 0,1 / 0,3 / 1,5 e 0 / 0,5 / 0,4 (B-4 sozinho não fez as
   primeiras salas ferirem; a orçamento maior vira mais inimigos, não mais perigo para quem esquiva); guardião 7,3 e
   5,9 (o Cavaleiro e o Ancião mais brandos do B-5); salas 7 a 9 4,3 / 0,8 / 3,8 e 6,1 / 3,8 / 4,9 (agora sobem depois do
   guardião, a meta da seção 5); Morvath 25 e 29.
7. **Forja**: no P-50 a Forja vale 0 a +22 conforme a faixa (M1 +1, M10 +22, M20 -2, todos dentro do ruído com 12 a
   23 descidas). Ela é dano, e dano não salva quem apanha: pesa mais no meio da escada.
8. **OF-05**: a Prata pela porta cai de 3,0 para 0,9 por descida e a Memória pela porta de 0,1 para 0,4 a 0,7 (o robô
   pega mais Memória porque ela aparece mais perto do fim, quando ele já tem Bênçãos); Prata total mediana 31 para 26
   (M1) e 36 para 34 (M20), Memória 5 para 2 (M1) e 5 igual (M20). Não muda a vitória (o robô quase nunca troca uma
   Bênção por material).

### B.3 Metas (para o Daniel; o robô não é gente: são réguas de comparação, a de gente é o `runs.jsonl`)

| Faixa (descidas aprox.) | Robô 0,25 sem Forja | Robô 0,25 com Forja | Robô 0,45 sem Forja | Gente (expectativa) |
|---|---|---|---|---|
| Maestria 1 a 5 (1 a 4) | **20 a 30%** | 25 a 35% | **5 a 10%** | quase nunca vence |
| Maestria 6 a 9 (4 a 8, ultimate) | 35 a 50% | 40 a 55% | 15 a 25% | 5 a 15% |
| Maestria 10 a 14 (9 a 15, Firmeza, Respiro) | 50 a 65% | 55 a 70% | 25 a 35% | 20 a 35% (primeira vitória típica) |
| Maestria 15 a 20 (16 em diante, Ainda de Pé) | 70 a 85% | 75 a 90% | 35 a 50% | 40 a 60%; depois, Juramentos |

- A curva tem de subir a cada faixa (10 a 20 pontos por faixa no robô 0,25) e **a Maestria 1 sem Forja é a mais baixa
  de todas**; diferença M1 para M20 de 45 a 60 pontos (0,25).
- A Forja vale de 5 a 15 pontos numa faixa, nunca mais que um passo de Maestria.
- Dentro da descida: salas 1 a 3 com 0,5 a 1,5 de dano por sala; guardião com 25 a 35% das mortes; salas 7 a 9 acima
  das 4 a 6 sem o guardião; Morvath com 40 a 50% do dano da descida.
- Nenhuma vida de inimigo muda; nenhum perigo de sala acima de 10.

### B.4 Propostas (com o lugar no `tools/make_data.gd` do HEAD `343d251`)

**B-1 (P0) Dano dos inimigos vezes 1,6** (medido a 1,5: insuficiente na M1). Dono: gameplay-engineer.

| Quem | Linha | Campo | Hoje | Proposto |
|---|---|---|---|---|
| esqueleto (e elite, herdado pelo `_pair`) | 237 a 238, `_enemies` | `damage`, `attack_damage` | 3 | 5 |
| corredor | 251 a 252 | `damage`, `attack_damage` | 5 | 8 |
| feiticeiro | 272 a 273 | `damage`, `attack_damage` | 4 | 6 (fica: já é a maior fonte nas salas) |
| besteiro | 282 a 283 | `damage`, `attack_damage` | 3 | 5 |
| Escudo | 290 a 292 | `damage`, `attack_damage` / `close_damage` | 9 / 7 | 14 / 11 |
| sacerdote | 302 a 303 | `damage`, `attack_damage` | 6 | 10 |
| Morvath (corpo) | 325 a 326 | `damage` / `attack_damage` | 8 / 10 | 13 / 16 |
| Morvath, `_bosses` | 1312 | `scythe_damage` | 12 | 19 |
| | 1316 | `reap_damage` | 10 | 16 |
| | 1318 | `blade_damage` | 10 | 16 |
| | 1324 | `storm_damage` | 10 | 15 (a Tempestade já é 38% do dano dele; fica a 1,5) |
| | 1327 | `eruption_damage` | 10 | 16 |
| | 1335 | `curse_damage` | 6 | 10 |
| | 1336 | `dash_damage` | 12 | 19 |

- Efeito esperado (extrapolado entre o P-50 medido e o +60% de 2026-11-19): M1 0,25 de 35% para 25 a 30%, M20 de 70%
  para 65 a 70%. Medir de novo.
- Perigos: ficam em 10 (`HAZARD_HERO`, já no HEAD) e a borda que desmorona em `CRUMBLE_HERO`; as Runas viraram 11% do
  dano das salas: não subir mais.

**B-2 (P0) A ultimate abre na Maestria 6 e a Voragem na 10.** Linhas 1480 e 1483 (`_ult`): `"mastery_level": 2` para
**6** e `6` para **10**. Medido no P-50: sem ela a M5 fica com a M1 (32 contra 35%); com ela e a Firmeza, +13.

**B-3 (P1) O sustento no meio da escada** (`_talents`, só o 6º argumento, `unlock`; custos e efeitos iguais):

| Dom | Linha | Hoje | Proposto |
|---|---|---|---|
| `impeto` | 1527 | 3 | 2 |
| `corte_crescente` | 1532 | 4 | 3 |
| `lamina_faminta` | 1537 | 5 | 4 |
| `passo_encadeado` | 1522 | 7 | 5 |
| `avanco_feroz` | 1529 | 8 | 7 |
| `fio_longo` | 1533 | 9 | 8 |
| `firmeza` | 1549 | 16 | **9** |
| `respiro` | 1550 | 17 | **12** |
| `sangue_quente` | 1544 | 12 | 13 |
| `onda_carregada` | 1545 | 13 | 14 |
| `fio_do_passo` | 1546 | 14 | 15 |
| `golpe_sem_fim` | 1523 | 15 | 16 |
| `ainda_de_pe` | 1551 | 19 | **17** |

Os outros iguais (Quarto Corte 1, Reserva 10, Investida 11, Fúria Plena 18, ápices 20). O nível 19 fica sem Dom novo
(Devoção). Medido (P-50): M10 45%, M15 57%, M20 70%, a curva sobe a cada peça. O texto "O nível N revela" e o
`MasteryReport` leem do dado.

**B-4 (P2) Primeiras salas e a subida depois do guardião.** `_stage`, logo depois de `st.pom_from_depth = 3` (linha
565): `st.base_difficulty = 70.0` (padrão 55 no `StageDef`) e `st.depth_ramp = 17.0` (padrão 15). Medido junto do
pacote: as salas 7 a 9 passaram a ferir mais que as 4 a 6 sem o guardião (bom), as salas 1 a 3 continuam em 0 a 0,5
(não chega à meta de 0,5 a 1,5; o que falta é composição, não orçamento: proposta para o `room-designer`, um
`_pool(Tier.COMMON, 0.0, 0.34, 2.0, [&"pressure", &"control"])` com o feiticeiro, que é quem mais fere, nas salas 2 e
3; não medido).

**B-5 (P1) Ancião e Cavaleiro fora do 1,6** (a parede do guardião já mata 40% das vezes no P-50):

| Quem | Linha | Campo | Hoje | Proposto |
|---|---|---|---|---|
| Cavaleiro | 309 a 311 | `damage`, `attack_damage`, `close_damage` | 12 | 16 |
| Ancião | 317 a 318 | `damage`, `attack_damage` | 9 | 12 |

Medido no P-50: o Santuário com 6 das 15 mortes (40%, meta 25 a 35). Se depois do B-1 a 1,6 passar de 35%, o Ancião
vai a 11 (é a maior fonte para o robô 0,45, 28%).

**OF-05 (P1) Portas de material mais fundas.** Dois campos novos no `StageDef` lidos no `RunMap._may` (o filtro do
baralho, como o `pom_from_depth`; o `settle` não precisa mudar): `st.silver_from_depth = 4` e
`st.memory_after_guardian = true` (Memória só numa camada depois da do guardião, que varia de 4 a 6), no `_stage` ao lado
do `st.pom_from_depth` (linha 565). Medido (P-50, protótipo): Prata pela porta 3,0 para 0,9 por descida, Memória pela
porta 0,1 para 0,4 a 0,7; Memória total mediana 5 para 2 na M1 (o risco R15, "Memória lenta no começo": medir os Dons
abertos nas 10 primeiras descidas da campanha r45; se faltar, Memória desde a profundidade 5). A vitória não muda.

### B.5 Antes e depois previsto (robô 0,25, sem Forja; 0,45 entre parênteses)

| Faixa | Hoje medido | P-50 medido | Pacote proposto (B-1 a 1,6, B-2, B-3, B-4, B-5, OF-05), previsto | Meta |
|---|---|---|---|---|
| M1 | 48% (14%) | 35% (9%) | 25 a 30% (5 a 9%) | 20 a 30% (5 a 10%) |
| M5 | 59% (33%) | 32% (0%) | 25 a 30% (0 a 5%) | 20 a 30% (5 a 10%) |
| M10 | 77% (14%) | 45% (30%) | 40 a 45% (25%) | 50 a 65% (25 a 35%) |
| M15 | 71% (33%) | 57% (33%) | 50 a 55% (30%) | 50 a 65% / 70 a 85% |
| M20 | 83% (55%) | 70% (32%) | 65 a 70% (30%) | 70 a 85% (35 a 50%) |

O que fica fora da meta e o que fazer: a M10 e o topo da 0,45 ficam um pouco abaixo. Se o remedir confirmar, a
Tempestade fica em 15 (já está na tabela) e a Firmeza ganha +5 de vida (`firmeza` `max_hp` 10 para 15, linha 1549)
antes de mexer em outra coisa.

### B.6 O que falta medir

1. Completar 48 sementes nas montagens principais e 24 nas secundárias (a medida parou em 23 e 12).
2. O pacote final (B-1 a 1,6) nas duas réguas, M1, M5, M10, M15 e M20, com e sem Forja, no HEAD com os perigos a 10 e
   os quebráveis (AT-Q1) do `343d251`.
3. Morte no Santuário (meta 25 a 35%) e dano das salas 1 a 3 depois do B-4.
4. A Memória da OF-05 nas 10 primeiras descidas (campanha r45, R15).
5. Gente: o `runs.jsonl` do exe novo; a régua 0,45 só se recalibra com ele.

---

## Medição de 2026-11-19 (histórico; metas substituídas pelo Lote B)

Primeira versão: 2026-11-19, código `0293f79` (depois do RP-01 a RP-05).

## 1. Direção do PO (2026-11-19)

A primeira descida tem de ser **muito difícil de completar** e ir ficando possível **aos poucos**: o jogador melhora na
mão e o herói cresce com a Maestria, os Dons e, no futuro, o que o hub der. Vencer cedo é exceção. A dificuldade extra
depois da primeira vitória vem dos Juramentos. Hades II é a referência de números; as decisões de Eterra vão por cima.

## 2. Como medi

- Cópia isolada do projeto (`git archive HEAD` + `.godot`, fora do repositório, apagada no fim). Nenhuma captura.
  Até 8 processos sem tela.
- Comando: `godot --headless --path . --fixed-fps 60 -- --bot --nosave --smoke=900 --seed=N --bot-reaction=R [opções]`
  (o mesmo do `tools/smoke.sh 900`). Sementes 1 a 48 nas montagens principais, 1 a 24 ou 1 a 32 nas variações; toda
  comparação de alavanca é feita nas **mesmas** sementes. Com 48 descidas o erro de uma taxa perto de 70% é de uns 7
  pontos; com 24, uns 10. Diferenças menores que isso são ruído.
- Montagens (o robô não lê o save; Dons por `--talents=`, Devoção 5 + nível respeitada):

| Rótulo | Maestria | Dons | Ultimate | Devoção |
|---|---|---|---|---|
| M1 | 1 | nenhum | nenhuma (U-1 abre na 2) | 0 de 6 |
| R0 (régua do E6, DV-1, RP) | 2 | nenhum | Corte do Juízo | 0 de 7 |
| M5 | 5 | as quatro entradas: `quarto_corte, impeto, corte_crescente, lamina_faminta` | Corte do Juízo | 10 de 10 |
| M10 | 10 | ofensiva: `quarto_corte, impeto, avanco_feroz, corte_crescente, fio_longo, lamina_faminta` | Corte do Juízo | 14 de 15 |
| M10s | (10) | sustento antecipado: `quarto_corte, impeto, firmeza, respiro, ainda_de_pe` | Corte do Juízo | 15 de 15 |
| M20 | 20 | sustento do E6: `ainda_de_pe, firmeza, respiro, quarto_corte, impeto, lamina_faminta, reserva, corte_crescente, fio_longo` | Corte do Juízo | 24 de 25 |

- Reação do robô: **0,25** é a régua de sempre; **0,45** é o "robô-gente" (ver 3.2); 0,6 também medida.
- Alavancas sem mudar dado: os Juramentos servem de proxy de número base (`pain` = dano dos inimigos, `grit` = vida,
  `rivals` = Morvath descansa menos). Uma ultimate com metade da carga por dano foi medida numa segunda cópia com
  `ULT_DAMAGE_CHARGE` 0,01.
- Gente: o registro do Daniel (`runs.jsonl` do save dele, 17 linhas de 16 a 19/11: 10 descidas de 11 salas na Maestria
  8 a 16, 4 da descida antiga de 7 salas, 3 saídas; teclado).

## 3. Estado medido

### 3.1 Vitórias por Maestria (hoje)

| Montagem | Reação 0,25 | Reação 0,45 | Reação 0,6 |
|---|---|---|---|
| M1 (sem ultimate) | **29 de 48 (60%)** | 14 de 32 (44%) | 0 de 24 (0%) |
| R0 (só a ultimate) | **39 de 48 (81%)** | | |
| M5 | 34 de 48 (71%) | | |
| M10 ofensiva | 38 de 48 (79%) | 16 de 32 (50%) | 1 de 24 (4%) |
| M10s (sustento) | 31 de 32 (97%) | | |
| M20 sustento | **45 de 48 (94%)** | 19 de 24 (79%) | 1 de 24 (4%) |
| **Daniel** (Maestria 8 a 16) | | | **3 de 10 descidas de 11 salas (30%)** |

Leitura:

1. **A curva entre descidas é um degrau, não uma rampa.** O degrau é a ultimate: M1 sem ela 60%, R0 com ela 81% (+21,
   e ela abre na Maestria 2, a partir da segunda ou terceira descida). Depois disso os Dons ofensivos não mexem na taxa
   (M5 71%, M10 79%, dentro do ruído do R0); eles só encurtam a luta de Morvath (100 s para 87 a 92 s). O que mexe é o
   **sustento** (Firmeza, Respiro, Ainda de Pé: M10s 97%, M20 94%), e hoje ele só abre nas Maestrias 16, 17 e 19.
2. Com reação 0,45 a mesma forma: 44% sem nada, 50% com 10 Maestrias de Dons ofensivos, 79% com o sustento.
3. **O robô de 0,25 não é gente**: vence 2,5 vezes mais que o Daniel com a mesma faixa de Maestria. O de 0,6 cai num
   precipício (não sai da Foice, 0,8 s de preparo, nem da investida do Cavaleiro, 1,0 s) e não serve de régua. O de 0,45
   é o mais perto do Daniel e ainda otimista (50% contra 30%; morre antes de Morvath em 19% das descidas, o Daniel em
   40%). Proposta: **0,45 vira a segunda régua** (a das metas para gente), 0,25 continua a de regressão.

### 3.2 Gente (registro do Daniel, 10 descidas de 11 salas)

- 3 vitórias, 7 mortes: 4 antes de Morvath (Cavaleiro na sala 5; Runas na 6; Ancião na 4; um sacerdote na 8,
  `enemy_priest` é o nome dos dois) e 3 nele (fases 2, 3 e 4: Erupções duas vezes, um mago do ritual uma).
- Dano antes de Morvath: 4 a 27 nas que chegaram, 30 a 55 nas que não chegaram. As salas de guardião são o pico
  (18 a 35 de dano no Santuário com o Ancião). Maiores fontes de dano nas salas (as 14 descidas): Ancião 80 de 382,
  mago 64, corredor 45, besteiro 45, mago elite 36, Cavaleiro 31.
- Vida ao chegar em Morvath: 3 a 51 (mediana 27); Bênçãos 4 a 8.
- **Nunca comprou na loja** (37 a 84 de ouro ao entrar, 50 ou mais em 5 de 8; a cura custa 50). O robô compra a cura em 60% das descidas.
- Primeira vitória dele: Maestria 8 na descida de 7 salas, Maestria 10 na de 11. Quem não fez o jogo vai pior.

### 3.3 Onde se morre (reação 0,25)

| Montagem | Mortes | Em Morvath | Antes (onde) | Fase de Morvath das mortes |
|---|---|---|---|---|
| M1 | 19 | 11 | Santuário 5, Ponte 2, Jardim 1 | 1: 3, 2: 1, 3: 2, 4: 5 |
| R0 | 9 | 6 | Santuário 2, Ponte 1 | 2: 2, 3: 1, 4: 3 |
| M20 | 3 | 3 | nenhuma | 4: 3 |
| M1, reação 0,45 | 18 | 8 | Santuário 6, Runas 2, Fendas 1, Jardim 1 | 4: 7, 3: 1 |

O Santuário é a casa do guardião: as mortes antes de Morvath são quase todas o Cavaleiro e o Ancião (salas 4 a 6).
Com a Maestria 20 ninguém morre antes de Morvath (Ainda de Pé, Respiro, Firmeza).

### 3.4 Curva dentro da descida (vida perdida por sala, média; reação 0,25, sem guardião separado)

| Profundidade | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 (loja) | 11 (Morvath) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 0,2 | 0,1 | 0,1 | 5,5 | 4,1 | 5,0 | 2,7 | 2,1 | 4,7 | 0 | 20,7 |
| R0 | 0,2 | 0,1 | 0,3 | 3,8 | 3,0 | 2,4 | 1,9 | 2,0 | 3,2 | 0 | 22,6 |
| M20 | 0 | 0,2 | 0,1 | 4,4 | 2,1 | 4,1 | 3,1 | 0,8 | 1,4 | 0 | 22,7 |
| M1, 0,45 | 0,4 | 0 | 0,1 | 12,8 | 5,6 | 6,2 | 4,3 | 2,2 | 7,9 | 0 | 33,9 |

- **As salas 1 a 3 não pedem nada** (2% a 4% delas ferem o robô; o Daniel também sai delas inteiro quase sempre).
- O pico é o guardião (4 a 6): Santuário 9,9 de dano por sala na M1 (p90 27), 5,7 na R0. Depois a curva **cai** (7 e 8)
  em vez de subir, e volta na 9. Morvath é metade de todo o dano da descida (21 a 23 de 40).
- Vida ao chegar em Morvath (mediana): M1 44, R0 55, M5 50, M10 53, M20 65. Bênçãos: 5 a 6 em todas.
- Tempo: Morvath aos 3 min 37 s a 4 min 13 s (mediana), luta de 86 a 101 s nas vitórias.

### 3.5 Morvath

- Dano levado nele por ataque (R0): Tempestade 38%, Maldição 19%, Lâminas das Almas 18%, invocados 14%, Erupções 9%,
  Foice 1%. Na M1 sem ultimate as **Lâminas** sobem a 37% (a fase 1 dura mais sem o Corte do Juízo) e 3 das 11 mortes
  são na fase 1.
- Para o robô lento (0,6) a Foice vira 62 a 70% do dano: é o ataque de preparo mais curto que ele não lê.
- A vida dele (6050) não é alavanca de vitória (E6-D4); o que decide é quantos golpes cabem na vida do herói.

### 3.6 O que domina e o que não pesa

- **Domina**: a ultimate (16% de todo o dano causado, 3,8 usos na luta de Morvath, +21 pontos de vitória sozinha) e os
  três Dons de sustento. O ataque básico é 28 a 33% do dano, o especial 15 a 18%.
- **Nenhuma Bênção domina**: a maior (Flagelo, Brasas, queimadura) fica em 2 a 6% do dano.
- **Não pesa**: os Dons ofensivos para a taxa de vitória (só para o tempo); o Altar (1 troca em 48 descidas do robô);
  Elos (0,3 por descida); Salmos quase só aparecem com Dons equipados (40% das descidas M10/M20, 4 a 12% sem Dons).
- **A carga da ultimate por dano** (T5): metade dela (`ULT_DAMAGE_CHARGE` 0,02 para 0,01) tira 1,7 uso por descida e
  0,6 em Morvath e **não muda a vitória** (26 de 32 nas duas, sementes 1 a 32). A força da ultimate é existir.

### 3.7 Sensibilidade (o que o robô sente; Juramentos como proxy de número base, sementes 1 a 24)

| Alavanca | M1 | R0 | M20 |
|---|---|---|---|
| hoje | 14 (58%) | 20 (83%) | 22 (92%) |
| dano dos inimigos +20% (`pain:1`) | 13 | | 21 |
| dano dos inimigos +60% (`pain:2`) | **8 (33%)** | **15 (62%)** | **21 (88%)** |
| vida dos inimigos +20% (`grit:2`) | 13 | | 22 |
| Morvath descansa 25% menos, +2 invocados (`rivals`) | 14 | | 23 |
| reação 0,45 | 11 (46%) | | 19 (79%) |
| +60% e só a Firmeza (`--talents=firmeza`) | **16 (67%)** | | |
| +60% e as três entradas ofensivas (Quarto Corte, Ímpeto, Corte Crescente) | 11 (46%) | | |
| reação 0,45 e +60% | 5 (21%) | | 13 (54%) |

O dano dos inimigos só pesa quando passa de um limiar (+20% nada, +60% muito) e **pesa mais em quem tem menos**: com
+60% a M1 perde 25 pontos, a R0 21 e a M20 só 4. É a alavanca que abre a curva. Com ela, cada peça de sustento vira
um degrau grande: a Firmeza sozinha (+10 de vida) leva a M1 de 33% a 67%, a ultimate a 62%; os Dons ofensivos, +13
(dentro do ruído). Vida dos inimigos e um Morvath mais
apressado não mudam a vitória do robô (só o tempo).

## 4. Metas propostas em 2026-11-19 (substituídas pelo B.3)

Faixas de Maestria pelas descidas: com a curva de XP de hoje (`40 + 10 (n - 1)`), uma derrota dá 70 a 110 de XP e uma
vitória 200 a 300. A Maestria 5 chega na 3ª ou 4ª descida, a 10 na 8ª a 10ª, a 20 depois de 25 a 30.

| Faixa | Descidas (aprox.) | Robô 0,25 | Robô 0,45 ("gente") | Gente (expectativa) |
|---|---|---|---|---|
| Maestria 1 a 4 | 1 a 3 | 25 a 40% | 10 a 25% | 0 a 5% (vencer é exceção) |
| Maestria 5 a 9 | 4 a 8 | 45 a 65% | 25 a 35% | 5 a 20% |
| Maestria 10 a 14 | 9 a 15 | 65 a 80% | 35 a 50% | 20 a 40% (primeira vitória típica aqui) |
| Maestria 15 a 20 | 16 em diante | 80 a 92% | 50 a 65% | 40 a 60%; depois, Juramentos |

- Diferença Maestria 1 para 20 no robô 0,25: **40 a 60 pontos** (hoje 34 com a M1 sem ultimate e 13 com a régua R0).
  A meta antiga do E6 (diferença até 25) e a D-11 (primeira vitória em até 3 tentativas para quem jogou Hades) deixam
  de valer: a direção nova pede o contrário.
- Cada passo de faixa vale de 10 a 30 pontos; as peças que mais pesam (ultimate, Firmeza, Respiro, Ainda de Pé) abrem
  em faixas diferentes, nunca duas na mesma.
- A gente: só o registro de partidas confirma. Meta de verdade: primeira vitória entre a 8ª e a 15ª descida para quem
  jogou Hades, depois disso cerca de uma em três.

## 5. Curva dentro da descida (metas)

| | Salas 1 a 3 | Guardião (4 a 6) | Salas 7 a 9 | Morvath |
|---|---|---|---|---|
| Hoje, robô 0,25 R0 (dano por sala) | 0,1 a 0,3 | 4 a 6 | 2 a 3 | 22 (50% da descida) |
| Meta, robô 0,25 | 0,5 a 1,5 | 5 a 8 | 3 a 5, subindo | 40 a 45% do dano da descida |
| Meta, mortes (gente e 0,45) | quase nenhuma | 25 a 35% das mortes | 15 a 25% | 45 a 55% |
| Vida ao chegar em Morvath, robô 0,25 | | | | 50 a 70% da vida máxima (o `RESULT` não traz a máxima: pedir o campo) |

O guardião como primeira parede está certo (é onde o Daniel e o robô lento morrem); o que falta é a subida
depois dele (as salas 7 e 8 ferem menos que a 4) e algum risco nas três primeiras.

## 6. As mudanças de maior efeito (propostas, em ordem)

Medidas com as mesmas sementes. As três primeiras formam um pacote: juntas fazem a curva; sozinhas, não.

### B-1 (P0) Dano dos inimigos +60% na base (o número antigo vezes 1,6)

- **Observado**: o robô quase não sente +20%; com +60% a M1 cai de 58 para 33%, a R0 de 83 para 62%, a M20 de 92 para
  88% (3.7). Com reação 0,45: M1 46% para **21%**, M20 79% para **54%**.
- **Inferência**: os números do Hades II são os da **primeira de quatro regiões**, a mais fácil; aqui a região é o jogo
  inteiro e Morvath é o último chefe. Para a primeira descida ser muito difícil, a região tem de bater como uma corrida
  inteira do Hades, não como o Érebo.
- **Proposta** (`_enemies` e `_bosses` do `make_data.gd`, arredondado): esqueleto `damage`/`attack_damage` 3 para 5;
  corredor 5 para 8; mago 4 para 6; besteiro 3 para 5; Escudo 9 para 14 e `close_damage` 7 para 11; sacerdote 6 para 10;
  Cavaleiro 12 para 19 (e `close_damage`); Ancião 9 para 14; Morvath `damage` 8 para 13, `attack_damage` 10 para 16,
  `scythe_damage` 12 para 19, `blade_damage` 10 para 16, `storm_damage` 10 para 16, `eruption_damage` 10 para 16,
  `curse_damage` 6 para 10, `dash_damage` 12 para 19 (e o que mais tiver dano no `_bosses`). As Runas (7 no herói) ficam
  (são perigo de sala, `room-designer`). Os Juramentos continuam por cima (Golpes Duros +20/60/100% sobre a base nova).
- Alternativa mais branda para medir antes: +40% (só medi +20 e +60; o limiar fica entre os dois).
- **Medir de novo**: régua 0,25 e 0,45, sementes 1 a 48, M1, R0, M10, M20.

### B-2 (P0) A ultimate abre mais tarde: Corte do Juízo na Maestria 2 para **6**, Voragem 6 para **10**

- **Observado**: a ultimate vale +21 pontos sozinha hoje (M1 60% para R0 81%) e +29 com B-1 (33% para 62%), e chega na
  2ª ou 3ª descida: a curva dá o salto logo no começo e fica plana depois. A carga por dano não é a alavanca (3.6).
- **Proposta**: `_ult(0, &"cleave", ...)` `"mastery_level": 2` para 6; `_ult(1, &"vortex", ...)` 6 para 10. No Hades II
  o Hex não vem com a heroína: chega pela Selene dentro da corrida.
- **Efeito esperado**: Maestria 1 a 5 sem ultimate; ela vira o marco do meio do caminho (Maestria 6 chega na 4ª ou 5ª descida).

### B-3 (P1) O sustento entra na escada da Maestria, espaçado (hoje nas Maestrias 16, 17 e 19)

- **Observado**: Firmeza, Respiro e Ainda de Pé são o que faz o robô vencer (M10 com eles 97% contra 79% sem eles), e
  só abrem no fim. Com B-1, cada peça de força é um degrau de 15 a 35 pontos (3.7), então elas precisam vir uma de cada
  vez, a cada 3 a 4 níveis, depois dos Dons que mudam o golpe.
- **Proposta** (`_talents`, só o argumento `unlock`; custos e efeitos iguais):

| Nível | Hoje | Proposto |
|---|---|---|
| 1 | Quarto Corte | Quarto Corte |
| 2 | U-1 | Ímpeto |
| 3 | Ímpeto | Corte Crescente |
| 4 | Corte Crescente | Lâmina Faminta |
| 5 | Lâmina Faminta | Passo Encadeado |
| 6 | U-2 | **U-1 Corte do Juízo** |
| 7 | Passo Encadeado | Avanço Feroz |
| 8 | Avanço Feroz | Fio Longo |
| 9 | Fio Longo | **Firmeza** |
| 10 | Reserva | **U-2 Voragem**, Reserva |
| 11 | Investida | Investida |
| 12 | Sangue Quente | **Respiro** |
| 13 | Onda Carregada | Sangue Quente |
| 14 | Fio do Passo | Onda Carregada |
| 15 | Golpe sem Fim | **Ainda de Pé** |
| 16 | Firmeza | Fio do Passo |
| 17 | Respiro | Golpe sem Fim |
| 18 | Fúria Plena | Fúria Plena |
| 19 | Ainda de Pé | (nada novo: Devoção para equipar mais) |
| 20 | Onda Atravessante, Coração da Emeth | Onda Atravessante, Coração da Emeth |

- Números: `impeto` 3 para 2, `corte_crescente` 4 para 3, `lamina_faminta` 5 para 4, `passo_encadeado` 7 para 5,
  `avanco_feroz` 8 para 7, `fio_longo` 9 para 8, `firmeza` 16 para 9, `respiro` 17 para 12, `sangue_quente` 12 para 13,
  `onda_carregada` 13 para 14, `ainda_de_pe` 19 para 15, `fio_do_passo` 14 para 16, `golpe_sem_fim` 15 para 17; os
  outros iguais. Os que transformam o golpe continuam primeiro (D-57), só o sustento sai do fim.
- **Curva medida com B-1 e esta escada** (cada faixa pela montagem mais próxima já medida, 24 sementes, mesmas sementes):

| Faixa | O que tem | Montagem medida | Robô 0,25 | Robô 0,45 | Meta 0,25 / 0,45 |
|---|---|---|---|---|---|
| 1 a 5 | Dons ofensivos de entrada | sem Dons / três entradas | 33% / 46% | 21% (sem Dons) | 25 a 40 / 10 a 25 |
| 6 a 8 | + ultimate | R0 com +60% | 62% | | 45 a 65 / 25 a 35 |
| 9 a 11 | + Firmeza | Firmeza sem ultimate 67%; com a ultimate, estimado 70 a 75% | 67 a 75% | | 65 a 80 / 35 a 50 |
| 12 a 14 | + Respiro | `N10` (Quarto Corte, Firmeza, Ímpeto, Respiro, Lâmina Faminta, Passo Encadeado, U-1) | 75% | 33% | 65 a 80 / 35 a 50 |
| 15 a 20 | + Ainda de Pé e o resto | M20 com +60% | 88% | 54% | 80 a 92 / 50 a 65 |

  A forma bate com a meta; os pontos fracos são a faixa 1 a 5 com as três entradas (46%, um pouco acima) e o robô 0,45
  na faixa 12 a 14 (33%, um pouco abaixo). A diferença Maestria 1 para 20 vai a 55 pontos (0,25) e 33 (0,45).
- **Medir de novo**: as montagens que cada nível permite (a mais forte que a Devoção deixa) nas Maestrias 1, 5, 6, 9,
  12, 15 e 20, 48 sementes, nas duas réguas.

### B-4 (P1) As três primeiras salas pedem alguma coisa e a curva sobe depois do guardião

- **Observado**: salas 1 a 3 ferem o robô em 2 a 4% das vezes (0,1 a 0,3 de dano), mesmo com +60% (0,2 a 0,5); as salas
  7 e 8 ferem menos que a 4.
- **Proposta** (com o `room-designer`, dono das salas): `st.base_difficulty` 55 para 70 no `_stage` (hoje o padrão do
  `StageDef`; a sala 2 passa de 85 para 100 de orçamento, a 9 de 190 para 205) e `st.depth_ramp` 15 para 17 (a 9 vai a
  223). Os conjuntos de papéis (`st.pools`) ficam. Não medido.
- **Meta**: seção 5 (0,5 a 1,5 de dano por sala nas salas 1 a 3; salas 7 a 9 acima das 4 a 6 sem o guardião).

### B-5 (P2) Ancião e Cavaleiro: a parede certa, mas sem morte em um erro

- **Observado**: o Ancião é a maior fonte de dano antes de Morvath para o robô (22 a 37%) e para o Daniel (80 de 382);
  com B-1 um orbe do leque dele (`attack_damage` 9 para 14) tira 47% da vida base e a investida do Cavaleiro (12 para
  19) 63%. Com +60% as mortes no Santuário sobem (M1: 8 das 16 mortes; reação 0,45: 10 de 19).
- **Proposta**: se B-1 entrar, o Ancião fica em 12 por orbe (não 14) e o Cavaleiro em 16 (não 19); medir antes as mortes
  no Santuário (meta: 25 a 35% das mortes, 3.4).

## 7. O que depende do Daniel

1. **Trocar a meta**: aceitar a tabela de 4 (primeira vitória entre a 8ª e a 15ª descida para quem jogou Hades) no
   lugar da D-11 e da diferença de 25 pontos do E6.
2. **B-1**: subir o dano da região acima do Hades II (com o argumento de 6.B-1) ou manter os números do Hades e buscar a
   dificuldade em outro lugar (salas e guardião mais pesados, menos cura). É a decisão de maior efeito.
3. **B-2 e B-3**: a Maestria da ultimate (6 e 10) e o sustento no meio da escada (a ordem da D-57 muda só aí).
4. **O hub**: o que ele der de forma permanente (vendedor, forjador: hoje "a definir") entra nesta curva. Proposta:
   cada coisa permanente vale no máximo 5 a 10 pontos e só depois da 5ª descida.
5. **Ainda de Pé em Morvath** (E6-D1): fica fora da Câmara do Selo nesta proposta.
6. **A loja**: o Daniel nunca comprou (com ouro para a cura em 6 de 8 vezes). É leitura (UX) ou preferência? Se for
   leitura, é do `ui-ux-designer`; se for preço, é deste documento.

## 8. O que medir depois do teste do Daniel

- O registro de partidas dele e de quem mais jogar: taxa por faixa de Maestria, sala da morte, vida e Bênçãos ao chegar
  em Morvath, `hurt_ctx` (aviso em segundos de cada golpe levado) para separar injusto de difícil.
- Calibrar a régua 0,45 contra gente (hoje 50% contra 27% do Daniel na mesma faixa).
- Depois do pacote B-1 a B-3: as duas réguas, 48 sementes, Maestria 1, 5, 10, 15 e 20 com as montagens que cada nível
  permite; aceite = tabela de 4 dentro da faixa.

## Nota do Game Director (2026-11-19, depois desta medição)
As 17 partidas do registro do Daniel (16/11 a 19/11 08:38) são todas de exes anteriores à correção `ed5a980`
(19/11 10:40): a exportação convertia os recursos e esvaziava o baralho das portas, então **a loja aparecia vazia** e
toda porta dava Bênção (sem portas de ouro, romã, coração ou Magia). "Nunca comprou na loja" não é preferência nem
leitura da tela, e o ouro (37 a 84 ao chegar à loja) e a vida ao chegar em Morvath dessas partidas também não valem
como régua da economia de hoje. Recalibrar a régua 0,45 só com partidas do exe novo.

## Para o equilíbrio (gameplay-engineer, 2026-11-20; observações, nenhum número mudado)

- **Ancião contra o robô** (C19, `combat_cadence.md` 8.3 (a)): o dano do Ancião ao robô 0,25 nas 24 descidas (sementes
  1 a 24, `smoke 900 --ultimate=cleave`) foi de 45 para 126 com a carga do Ômega a 3% do andar (C19-4, número do
  Hades); não são as linhas do leque (sem elas, 126 igual). O robô agora não começa o Ômega do ataque com um tiro
  preparando a menos de 12 m (`Bot.shot_coming`): 126 para **81**, ainda acima da meta de 68. Os golpes chegam com
  aviso de 1,04 s ou mais enquanto ele está plantado num golpe comum: é leitura de gente, não injustiça. Vitórias nas
  24: 20 antes, 18 depois (ruído). Proposta a medir: o leque do Ancião com uma onda a menos ou o intervalo entre
  leques maior, ou nada (o Ancião é a parede do guardião, B-5).
- **Renda da loja e combinações** (Q-15, `docs/qa/q15_economy.md`, 72 sementes): ouro mediano ao entrar na loja 81,5
  (meta 150 a 220; dois montes, 60 a 90 sem a porta de ouro e 160 a 190 com ela); compra além da cura em 29% (meta
  33%); Elo em 24% das descidas (meta 35%); Salmo em 5,6% (meta 15%). O encontro com anjos concentra a mão numa
  família (o robô escolhe por afinidade), o que reduz Elos e Salmos possíveis. A porta de Salmo e o anjo à mostra na
  porta (Fatia 2) mudam essas contas: medir de novo depois dela.
- **Prata**: a Fatia 1 medida pelo `balance-designer` fica como estava; a Fatia 2 soma a Prata a mais da porta Difícil
  só na placa (é a de sempre, 1 por elite) e Temperar III (60) e Refinar (25 cada, seis escolhas) como sumidouros.
  Esmeralda: 2 numa vitória (fase 3 e selagem), 1 numa derrota depois da fase 3; ainda sem uso (Despertar, Fatia 3).
- **Fatia 2 e o robô** (72 sementes, `smoke 900 --bot-reaction=0.25 --ultimate=cleave`): vitórias 58 para 47, vida ao
  entrar em Morvath mediana 51,5 para 30, Bênçãos em Morvath 6 para 5 a 6, 15 mortes antes de Morvath (eram 2). Não são
  as portas novas: com o baralho, o encontro e a loja da Fatia 1 (24 sementes) 16 de 24 e vida 30; sem as Bênçãos novas,
  13 de 24 e vida 30; a medida do C19 (24 sementes, antes da Fatia 2) dava 18 e vida 48. O que caiu foi o coração: 0,61
  por descida no Q-15 para 0,24 a 0,31 agora. A bifurcação por grupos (RJ-3) põe a Bênção ao lado de uma porta de corpo
  (coração, Magia, ouro), e o robô sempre leva a Bênção; antes coração e ouro dividiam porta. Propostas a medir: o
  coração no grupo POWER (fica ao lado do ouro e da Magia de novo), o robô levar o coração abaixo de 60% da vida, ou o
  coração com mais vida. O baralho ganhou 2 Bênçãos para elas manterem a fatia de antes (6 de 16, agora 8 de 21); a
  porta de Encanto fica depois do coração no gosto do robô (antes da romã ele largava metade dos corações).
- **Porta de Salmo**: nas 72 descidas nenhuma ficou de pé (o robô quase nunca tem as três coisas de um Salmo, e
  `settle` a troca por Bênção); Salmo continua em 0 a 5% das descidas do robô (meta 15%). Proposta: a porta de Salmo
  conta uma coisa a menos (dois grupos), ou o Salmo pela porta com 100% quando ela fica.
- **Loja de rota (DV-2, MAP-09)**: em 45% dos mapas, num ramo de 6 a 8. O robô chega à sala 6 com 50 de ouro ou mais
  em 29% das descidas, à 7 em 62%, à 8 em 86% (mediana 44, 52, 62,5): a meta "ouro para um item em 2 de 3 de quem
  passa" só fecha nas camadas 7 e 8. Depende da renda (Q-15): se a renda subir, a loja de rota ganha sentido.
