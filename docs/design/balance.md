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
- **Lote 5 (2026-11-22), medido e fechado**: o herói novo começa com 18 de vida (era 30: ele "sente fraco") e o Santuário
  paga a diferença. A Forja sobe (Temperar I e II: 20% de dano no ataque e no especial, era 10%) e nasce a conta, "A Fonte"
  (`docs/reference/meta.md`, 12 nós; Vigor +8, +8, +9 de vida, Fôlego da Sala 12% de cura por sala, Mão Firme +6% de dano).
  Régua do robô 0,25, 48 sementes por montagem (12 dá erro de 14 pontos, por isso as duas), smoke 600, "morre no
  guardião" = o guardião é o último nó do caminho e a partida não acabou em vitória (de quem chega nele):
  | Montagem | Morre no guardião | Vitórias sobre Morvath |
  |---|---|---|
  | Novato (sem Dons, Forja nem conta) | 59% (24 de 41) | 4 de 48 |
  | Evoluído: 4 Dons + Forja 2 + `--account=6` (Vigor I e II, Fôlego, Mão Firme I, Olhar Atento I, Bolsa I; custa 94 Prata e 6 Memória, as ~5 primeiras descidas) | 23% (11 de 48) | 15 de 48 |
  | Evoluído + `--account=7` (com a Segunda Chance, 20 Memória) | 2% (1 de 48), 19 vitórias (medido com a Forja a 15%) | |
  Primeiras 12 sementes só: 45% contra 17% (ruído). **Diferença: 36 pontos** (meta 25 a 40); novato dentro de 50 a 65%,
  evoluído dentro de 15 a 30%. Sem a Forja nem os Dons, só a conta 6 ficou em 17% a 12 sementes (a conta sozinha pesa
  uns 20 pontos), os Dons e a Forja do tempo antigo só 7. A Segunda Chance vale quase um guardião inteiro: se a conta
  completa ficar fácil demais, é o nó a mexer (40% de vida, custo). Armadilha da medida: a Provação cobra vida do robô
  antes do guardião (o robô evoluído entrava com 20 de 32), o que esconde parte do ganho. Ferramenta: `--account=N`.
  **Conferido com tudo junto** (2026-11-21, Morvath que persegue, anjos 5 a 7 e perigos novos; 12 sementes, erro de uns 14
  pontos): novato morre em 5 de 11 guardiões e vence 1 de 12; evoluído (conta 6) morre em 2 de 12 e vence 4 de 12.

## Dois minichefes por descida (2026-11-22)

Cavaleiro e Ancião em toda descida, depois Morvath (`docs/reference/rooms.md`). Régua do robô 0,25, 24 sementes por montagem
(1 a 12 e 101 a 112), 30 de vida, `NONE`; evoluído = 4 Dons, Forja 2, conta 6. Erro de uns 10 pontos; nas linhas do segundo, mais.

| | Novato | Evoluído |
|---|---|---|
| Morre no primeiro (de quem chega) | 9 de 23 (39%): Cavaleiro 5 de 13, Ancião 4 de 10 | 1 de 24: Cavaleiro 0 de 14, Ancião 1 de 10 |
| Morre no segundo | 2 de 8 | 2 de 20 |
| Chega a Morvath | 6 de 24 | 17 de 24 |
| Vence | 0 de 24 | 7 de 24 (29%) |

Só a estrutura, sem mexer nos dois (12 sementes), ficou mais fácil que antes (duas fontes e mais uma Bênção rara): o novato vencia 1 e o
segundo minichefe matava 1 de 15. Por isso: Cavaleiro com segunda investida, Ancião com orbes a 6 m/s e leque a cada 3,5 s
(era 7 e 3,06), escolta no segundo. Nenhuma vida mudou. Antes: Ancião 5 de 7, Cavaleiro 0 de 3, evoluído 4 vitórias de 12.

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

## C1b: ajuste de números do kit (2026-11-23, robô 0,25, 12 sementes por linha, só números em `tools/make_data.gd`)
Herói 15/15/20 e 30 de vida intactos. Mudado: Investida 35 para 60, Brado 15 para 35, especial (onda) 35 para 55, Ômega de ataque (lance) 100 para 150. Peso de Quebra do ataque ficou 0,15 (0,17 deu 3 vitórias de 12, mas 1/0,17 = 5,9 golpes sai da faixa 6 a 8 do `test_c1b_break`).
| Aceite | Antes | Depois |
|---|---|---|
| Ataque no dano do evoluído (meta até 40%) | 51% | 44% (novato 42%) |
| Só mouse chega a Morvath / todas as teclas (meta até metade) | 4 de 12 / 6 de 12 | 2 de 24 / 7 de 24 |
| Evoluído vence (meta 20 a 40%) | 0 de 12 | 1 de 12 (8%); com peso 0,17: 3 de 12 (25%); o ruído entre rodadas é de 1 a 3 |
| Novato chega a Morvath | 1 de 12 | 1 de 12, nenhuma vitória |
| Luta comum acima de 60 s | alguma | máxima 65 s (evoluído) e 72 s (novato), mediana 32 a 34 s |
Só número não fecha: o ataque ainda leva 42 a 44% e o evoluído vence pouco. Código que ajudaria: kit_c1c item 1 (Magia por acerto de ataque e Brado devolvido por acerto e por Quebra) para o robô usar mais os botões, e um peso de Quebra do ataque de 0,16 com o teste em 5,5 a 8.

## C1c item 1: os botões se alimentam (2026-11-23, robô 0,25, 12 sementes, `smoke.sh 700`; novato e evoluído `--boons=4 --forge=2 --account=6`)
Magia +0,5 por golpe de ataque, +3 por Quebra, Brado -0,3 s por acerto e -1,5 s por Quebra (piso 8 s), tetos 3 por segundo e 8 por onda. Antes = os mesmos números zerados em `make_data` (mesmo código).
| Medida | Novato antes | Novato depois | Evoluído antes | Evoluído depois |
|---|---|---|---|---|
| Ataque no dano total (meta perto de 40%) | 44,1% | 40,3% | 38,0% | 34,1% |
| Chega a Morvath (de 12) | 7 | 10 | 11 | 12 |
| Vence (modo ENDING, de 12) | 3 | 3 | 10 | 10 |
| Ondas por partida | 49,7 | 69,6 | 52,0 | 59,9 |
| Brados por partida (um a cada, na partida toda) | 26,2 (19,1 s) | 33,7 (16,1 s) | 23,6 (20,6 s) | 25,4 (18,3 s) |
| Magia por acerto / por Quebra (por partida) | 0 / 0 | 180 / 27 | 0 / 0 | 139 / 2,6 |
| Segundos de Brado devolvidos por partida | 0 | 85 | 0 | 53 |
Leitura: o ataque cai para perto de 40% (novato), a onda sobe 40% (a Magia por acerto paga a onda), e o novato chega a Morvath mais vezes (7 para 10). O Brado a cada 16 a 18 s é a média da partida inteira (inclui andar, porta e fonte, e o robô só usa o Q quando está perto); fica acima dos 9 a 11 s da meta, e o piso de 8 s nunca é rompido (testado). A Magia por Quebra é pouca (27 por partida no novato; o evoluído quase não quebra porque mata antes): a maior parte do ganho vem do acerto. Evoluído vence igual (10 de 12 nos dois). Nada a rebalancear sem pedido; se o Daniel quiser o Brado mais frequente, subir `cd_refund_hit` para 0,5 em `make_data`.

## Noite de teste com usuários reais (2026-11-23, robô 0,25, `smoke.sh 700 --ultimate=cleave`, sementes 1 a 12; só números em `make_data.gd`)
Observado: o evoluído (`--boons=4 --forge=2 --account=6`) vencia 9 de 12 (75%, não 1 de 12 como no backlog: o robô quase não é acertado por Morvath, 1 a 3 golpes por luta, lutas de 57 a 106 s); o novato (`--hero-hp=30`) chegava ao guardião 12 de 12, passava dele 9 de 12, chegava a Morvath 3 de 12 e vencia 1; a Maga (`--hero=maga`) morria no primeiro guardião 6 de 12 e nunca chegava a Morvath (mediana da sala de morte 6,5 contra 7,5 do novato; dano 28 por segundo contra 42).
| Número (`make_data.gd`) | Antes | Depois |
|---|---|---|
| Vida de Morvath (`_enemy morvath`) | 6050 | 10000 |
| Dano de todos os golpes dele (`BOSS_DAMAGE`, menos a maldição de 10) | escora 19, ceifa 16, lâminas 16, tempestade 15, erupção 16, investida 19, ruptura 16 | x1,8: 34, 29, 29, 27, 29, 34, 29 |
| Pausas entre golpes (`BOSS_REST`) e recargas (`BOSS_COOLDOWN`) | 0,8 e 0,85 | 0,55 e 0,7 (ele ataca mais, aviso igual) |
| Maga: vida | 30 | 40 |
| Maga: tiros 1, 2, 3 | 8, 8, 12 | 10, 10, 15 |
| Maga: Explosão (sozinha, no Selo) | 25 (+35) | 32 (+44) |
| Medida (12 sementes) | Antes | Depois |
|---|---|---|
| Evoluído vence / chega a Morvath | 9 / 9 | 5 / 9 (42%; ruído de 1 a 3) |
| Luta de Morvath do evoluído | 57 a 106 s | 78 a 170 s |
| Novato chega a Morvath / vence | 3 / 1 | 3 / 1 (não mudou: já morre antes) |
| Maga chega a Morvath / vence / sala de morte (mediana) | 0 / 0 / 6,5 | 3 / 0 / 10 |
Passos medidos do evoluído: vida 8000 e dano x1,3 e pausas 0,55: 7 de 12; vida 10000 e dano x1,5: 7 de 12; dano x1,8: 5 de 12. Só a vida de Morvath ou só o dano não mexeu na taxa porque o robô quase não é acertado: o que pesa é o dano por golpe e a frequência.
Leitura e limites: o robô esquiva melhor que gente, então o evoluído humano vence menos que 42% (isso é desejado para a noite; recalibrar com o `runs.jsonl`). Se os testadores acharem Morvath injusto, voltar `BOSS_DAMAGE` para 1,5 (7 de 12 no robô). Novato e Maga ficam como estavam: o primeiro guardião já é passável (9 de 12 no novato) e um jogador de verdade vai morrer antes do robô. Maga com vida 40 contra 30 do Guerreiro: se parecer forte demais depois do teste, voltar a vida e deixar só o dano (~metade do ganho).
Testes ajustados (mudança intencional): `test_boss` (vida 10000, faixa de dano 6 a 42), `test_boss_body` (a investida deixou de ser exigida nessa luta roteirizada), `test_c1d_rupture` (16 vira 29), `test_maga_seal`, `test_maga_loop` (tiros e Explosão).

**Aplicado pela sessão principal para a noite (2026-11-23):** só o dano da Maga (tiros 10/10/15, Explosão 32 + 44). **Não aplicado**: Morvath (vida 10000, golpes x1,8, `BOSS_REST` 0,55, `BOSS_COOLDOWN` 0,7) porque o golpe mais forte passaria a 34 contra 30 de vida do novato (morte de um golpe com vida cheia, ruim para quem nunca jogou); e a vida 40 da Maga, porque o Daniel decidiu 30 (`maga.md` 13). Recalibrar Morvath com o `runs.jsonl` dos testadores, tentando antes `BOSS_DAMAGE` 1,3 (golpe máximo abaixo de 30).

## Passada de 2026-11-23 (tarde): Morvath depois do commit 159f206, Videira e herói de 30 de vida
Robô 0,25 (`--ultimate=cleave`), 12 sementes (1 a 12) por perfil, só números em `tools/make_data.gd` (`morvath`, `_bosses`). O robô não é gente: compara versões, não é a taxa real.
Perfis: novato = descida inteira sem opções; evoluído = descida inteira `--vine=9 --forge=2`; Morvath = `--start=boss --boons=8` (com e sem `--vine=9`). "Vence" = modo ENDING.
| Número (`make_data.gd`) | Antes | Depois |
|---|---|---|
| Vida de Morvath | 6050 | 8500 |
| `blade_damage` (lâminas) | 16 | 11 |
| `reap_damage` (ceifa dupla) | 16 | 14 |
| `barrage_damage` (Rajada das Almas) | 8 | 6 |
| `adds_total_cap` / `adds_cap` fases 2 a 4 | 20 / 4 | 14 / 3 |
| `ritual_cap` / `ritual_reinforce_every` / `ritual_eruption_every` | 6 / 6 s / 2,8 s | 5 / 9 s / 3,5 s |
Golpe único mais forte continua 19 (foice e investida), abaixo dos 30 da meta.
| Medida | Antes | Depois |
|---|---|---|
| Evoluído vence (meta 20 a 40%) | 2 de 12 (17%) | 3 de 12 (25%) |
| Evoluído chega a Morvath | 7 de 12 | 7 de 12 |
| Luta de Morvath do evoluído (meta 120 a 180 s) | mediana 96 s (71 a 117) | mediana 141 s (90 a 154) |
| Evoluído morre em Morvath, fase 3 / 4 | 1 / 4 | 1 / 3 |
| Novato chega a Morvath / vence | 2 de 12 / 0 | 2 de 12 / 0 (mortes na sala 5 a 11; não mexi) |
| Morvath com 8 Bênçãos, vida 30: vence / morre na fase 2 | 0 / 10 de 12 | 0 / 8 de 12 (luta mediana 113 s) |
| Morvath com 8 Bênçãos e `--vine=9`: vence / morre na fase 2 | 0 / 9 de 12 | 0 / 5 de 12 (mediana 135 s) |
Passos medidos: vida 9000 com dano de antes e lâminas 13: 0 de 12 (fase 4 em 4 de 7); mais Rajada 6, invocados 14: 1 de 12; mais ritual: 2 de 12; lâminas 11 e ceifa 14: 3 de 12. O ruído entre rodadas é de 1 a 3 vitórias.
Leitura: o que mais mata Morvath-cedo são os invocados do ritual e as lâminas (fase 2: `adds` 240 e `blades` 197 de vida perdida em 12 lutas); o evoluído morre mais na Rajada (fase 4). A vida maior deu o tempo de luta pedido; o dano menor devolveu a vitória. Com 8 Bênçãos e sem a descida (perfil artificial: sem as Bênçãos extras, Dons e vida de coração) ninguém vence: isso é desejado como "exceção".
Pendente (depende do Daniel): o novato quase não chega (2 de 12; meta "chega ao guardião e às vezes vence" só vale para quem joga bem); recalibrar com o `runs.jsonl`. O Daniel acha Morvath fácil, mas o robô evoluído só vence 25%: se a mão dele ainda o achar fácil, subir a vida para 10000 antes de subir o dano. `ritual_cap` 5 não mudou nada medido contra 4 (reforço só entra quando alguém morre).
Testes ajustados: `test_boss` (vida, `ritual_cap`, contas de `summon_count`), `test_boss_refine` (teto 14). `tools/check.gd` limpo.

## Urgente 2026-11-23 (noite): todos morreram na sala 5, primeira metade mais justa
Observado (`runs.jsonl`, `tools/runs_report.py --since=2026-11-23T15:00`): 7 partidas, 0 vitórias; 4 mortes na sala 5 (Cavaleiro 2x à tarde, Esqueleto e Ancião à noite), 1 na 9, 1 na 2, 1 na 1 (Maga). A sala 5 é o primeiro guardião (`st.miniboss_depth_min/max = 5`; Cavaleiro ou Ancião; a fonte vem como uma das duas portas da sala 4, `RunMap` GP-2, e quem a pula chega sem cura). Vida ao entrar na sala 5: 20, 11, 4, 5, 19, 12 e 52 (de 30 a 40 máximos). Os golpes levados: esqueleto 5, mago 4, arqueiro 5, Cavaleiro 5 a 12, Ancião 10. O herói tem 30 de vida e não há cura entre salas fora da fonte, do coração e do Respiro (Maestria 20); o dano das salas 1 a 4 se acumula e o guardião acaba o resto. Desde 461c414 o `make_data.gd` quase não mexeu no Cavaleiro e no Ancião (só tempos e `throw_half`); o que mudou foi o contexto (14 salas, avisos de chão, Maga), então a sensação de mais difícil vem sobretudo da vida 30 e da falta de cura, não de um número que subiu.
Réguas (12 sementes, 1 a 12, `smoke.sh 700 --bot-reaction=R --ultimate=cleave`, uma partida por vez): R 0,25 (o robô habitual, esquiva bem) e R 0,6 (proxy de criança: avisos lidos tarde, morre onde o registro mostra).
| Número (`make_data.gd`) | Antes | Depois |
|---|---|---|
| Guerreiro, vida (`_hero`) | 30 | 40 |
| Esqueleto e Arqueiro, dano | 5 | 4 |
| Cavaleiro: vida / armadura | 450 / 1700 | 380 / 1100 |
| Cavaleiro: investida / ataque / corpo a corpo / arremesso / onda / escudo erguido | 16 / 8 / 8 / 8 / 6 / 8 | 10 / 6 / 6 / 6 / 5 / 6 |
| Ancião: vida / armadura | 510 / 1450 | 420 / 900 |
| Ancião: dano de orbe (`attack_damage`) / `damage` | 10 / 12 | 5 / 9 |
| Medida | Antes | Depois |
|---|---|---|
| Robô 0,25: passa da sala 5 (de 12) | 8 | 12 |
| Robô 0,25: sala média de morte | 8,6 | 11,8 |
| Robô 0,25: chega a Morvath | 2 | 6 (0 vitórias; Maestria e Dons não entram) |
| Robô 0,6 (criança): passa da sala 5 | 0 | 9 |
| Robô 0,6: sala média de morte | 4,7 | 7,3 (salas 5 a 11) |
Passos medidos: vida 40 e golpes do Cavaleiro e do Ancião menores: 0,25 passou de 8 a 10 de 12 (o Ancião seguia matando o robô com 4 sementes); orçamento das salas 1 a 4 em 0,5 a 0,7 (era 0,65 a 0,85): sem efeito acima do ruído, voltou; vida e armadura menores dos guardiões (luta mais curta, mais atordoamento): criança de 5 para 9 de 12. Ruído entre rodadas: 1 a 3 sementes (o `RunMap` e os sorteios mudam com a mudança de gasto de orçamento).
Leitura e limites: o robô 0,25 agora passa sempre e chega a Morvath em 6 de 12 sem Maestria nem Dons; isso é mais generoso que a meta antiga ("chega ao guardião e às vezes vence") de propósito, a pedido do Daniel (criança passa da sala 5 e chega perto do meio), mas a primeira vitória sobre Morvath (0 de 12) e os Juramentos continuam sendo o teto. Se o Daniel (Maestria 18) achar fácil demais, o primeiro número a voltar é a vida do Guerreiro (40 para 35). Não mexi na Maga (30) nem em Morvath. Não resolvido: o jogador que pula a fonte da sala 4 chega ao guardião com pouca vida; um Respiro base (cura de 2 a 3 por sala vencida) é a próxima alavanca e pede código (`room_heal` hoje só vem da Maestria). Recalibrar com o `runs.jsonl` da próxima noite.

## Cura base e PT-6/PT-11 (2026-11-24)
Cura base: toda sala de combate ou guardião vencida devolve 3 de vida (`StageDef.room_heal_base`, `tools/make_data.gd`), somada ao Respiro da Maestria (`room_heal`), sem passar da vida máxima; fonte, loja, Provação e Altar não curam (`Rooms.base_room_heal`, `tests/test_room_heal_base.gd`). Mesma régua da noite (12 sementes, `smoke.sh 700 --bot-reaction=R --ultimate=cleave`, uma partida por vez): (a) `b8f086f`, (b) com a cura, (c) com a cura + PT-6/PT-11.
| Medida | (a) antes | (b) cura | (c) cura + PT-6/PT-11 |
|---|---|---|---|
| R 0,25: passa da sala 5 (de 12) | 12 | 12 | 12 |
| R 0,25: sala média de morte | 11,8 | 11,7 | 13,0 |
| R 0,25: chega a Morvath (sala 14) | 6 | 6 | 9 |
| R 0,25: termina a partida (ENDING) | 0 | 2 | 3 |
| R 0,6: passa da sala 5 | 9 | 10 | 10 |
| R 0,6: sala média de morte | 7,2 | 7,4 | 8,1 |
Leitura: a cura sozinha mexe pouco (3 de vida por sala, dentro do ruído de 1 a 3 sementes); o PT-6/PT-11 não piorou nada (entrar por baixo e nascer ao norte deram ao robô mais tempo, subiu um pouco). A loja segue igual: `--start=shop --gold=400 --seed=5` compra Bênção, coração e cura (325 de ouro). Maestria e Dons continuam fora; se o Daniel achar fácil, voltar primeiro a vida do Guerreiro (40 para 35).

## Lote D (2026-11-24): o que a criança leva para casa, preços ao alcance, combate para quem lê tarde
Backlog 17 a 19; tudo em `tools/make_data.gd` (regerado), mais os campos novos `StageDef.silver_room` (Prata por sala de luta vencida, `Rooms.room_silver` em `_room_cleared`, fonte `room`) e `memory_guardian_reach` (Memória ao entrar na sala do guardião, fonte `reach`). Testes: `tests/test_lote_d.gd`; ajustados `test_rejogabilidade`, `test_rejogabilidade_game`, `test_videira_v1`, `test_vendor_offer`, `test_fatia3`, `test_rj1_ui`, `test_forge_bench`, `test_hero_def`, `test_maga_m2`, `test_combo`, `test_t5_ultimate` (Carga 48%).

| Número | Antes | Depois |
|---|---|---|
| `silver_room` (novo) / `silver_elite` | 0 / 1 | 1 / 2 |
| `memory_guardian_reach` (novo) | 0 | 1 |
| Dons de Maestria 2 a 5, Memória | 2, 3, 2, 2 (o custo de Devoção) | 1 cada (os de nível 6 em diante seguem) |
| Vendedor, Prata por 1 Memória | 10 | 5 |
| Videira, Provisão (Memória) | 5, 10, 20 | 3, 6, 10 |
| Videira, Perseverança (Prata, Memória, materiais) | +10% | +25% |
| Forja, Temperar I e II | 15 e 35 | 20 e 45 |
| `Feel.bang_lead` | 0,35 | 0,45 |
| Cavaleiro, aviso da segunda investida (`recharge_windup`) | 0,45 | 0,55 |
| Golpe Supremo (cleave e Tempestade dos Selos), carga | 90 | 75 |
| Maga, `shot3.glint` | 0 | 0,12 (dentro do windup de 0,14: a cadência 8, 8, 12 não muda) |
| Hit stop do especial e da Explosão (`hit_stop_ms` no dado) | 0 (25 ms pela constante) | 25 (mesmo efeito) |

Régua (12 sementes, 1 a 12, `smoke.sh 700 --ultimate=cleave --bot-reaction=R`, uma partida por vez; Maga 6 sementes a R 0,25; sem Maestria, Dons nem Forja). Antes = `f564252`.
| Medida | Antes | Depois |
|---|---|---|
| Guerreiro R 0,25: vitórias (ENDING) / chega a Morvath / passa da sala 5 | 2 / 9 / 12 | 1 / 10 / 12 |
| Guerreiro R 0,25: sala média de morte ou fim | 13,1 | 13,2 |
| Guerreiro R 0,6: passa da sala 5 / sala média | 8 de 12 / 6,7 | 8 de 12 / 7,0 |
| Maga R 0,25 (6): vitórias / chega a Morvath / passa da sala 5 | 1 / 1 / 5 | 1 / 2 / 4 |
| Derrota, Prata total p50: R 0,25 / R 0,6 | 24 / 6 | 41 / 11 |
| Derrota, Memória total p50: R 0,25 / R 0,6 | 6 / 2 | 8 / 3 |
| R 0,6 que morre na sala 5 (4 sementes): Prata, Memória | 0 e 0 (todas) | 3 a 4 e 1 |
| R 0,6 que morre nas salas 6 a 8: Prata, Memória | 6 a 12 e 2 a 4 | 10 a 18 e 3 a 5 |
| R 0,6, Cavaleiro (`--guardian=knight`, o robô cai também no Ancião): mortes na sala do Cavaleiro / dos que chegaram nela | 1 de 6 | 2 de 6 |

Leitura. (1) **Economia**: quem morre na sala 6 a 8 já leva 10 a 18 Prata e 3 a 5 Memória (meta 6 a 15 e 1 ou mais); quem morre na sala 5 leva só 3 a 4 Prata e 1 Memória: a Memória bate, a Prata fica abaixo de 6 (quatro salas de luta a 1 mais elites; se o Daniel quiser 6 ali, `silver_room` 2, que dobra o robô forte). O robô forte (0,25) quase dobra a Prata (24 para 41 na derrota): o efeito de `silver_elite` 2 e das salas; as lojas da Forja e da Videira ficam mais baratas ao mesmo tempo, então ele compra o primeiro item mais cedo (mexer primeiro em `silver_elite` se virar fácil). (2) **Vitória a R 0,25 sem Maestria**: 1 de 12 (antes 2), bem abaixo do teto de 6 de 12: não ficou fácil. Maga 1 de 6, abaixo de 5. (3) **Combate para quem lê tarde**: a criança (R 0,6) quase não muda (8 de 12 passam da 5, sala média 7,0 contra 6,7): o ruído de 1 a 3 sementes cobre isso; o ganho de `bang_lead` e do aviso do Cavaleiro é pequeno para este robô, que reage por tempo e não lê o "!". As mortes na sala do Cavaleiro foram de 1 para 2 de 6 que chegaram nela (o robô não separa a segunda investida, só a sala; um terço é o limite do critério, não abaixo): **não reverti** o 0,55; se o critério for estrito, olhar o registro de gente real. (4) **Descidas até o primeiro item** (criança que morre na sala 5, 3 a 4 Prata e 1 Memória por descida): Nó de Vida (5 Prata) 2 descidas (era nunca, 0,7 por descida); Temperar I (20 Prata) 6 descidas só com a sala 5, 2 a 3 se passa o guardião (era nunca / 1 com 18); primeiro Dom de Maestria 2 a 5 (1 Memória) 1 descida (era 2 Memória, nunca); Provisão Viajante (3 Memória) 3 descidas (era 5 Memória, nunca); troca de 5 Prata por 1 Memória no Vendedor ao alcance.
(5) **Dom Respiro (`room_heal` 2) e Provação da Ferida ("cura menor") com a cura base de 3**: conferência de leitura, não medida. Respiro soma 2 aos 3 (5 por sala, 40 de vida: 12,5%), a Provação continua cobrando vida antes do guardião e o robô evoluído seguiria entrando abaixo do máximo. Sem mudança; vale rever se a Maestria 18 do Daniel achar fácil.

## Lote R8 (2026-11-24): DPS por Magia do Guerreiro e da Maga no HEAD `bc13f16`, e a régua M1 contra Dons completos
Só leitura e linha de comando; nenhum número foi mudado. Cálculo à mão a partir de `tools/make_data.gd` e de `combat.gd`/`player.gd`/`kit_feed.gd` (alvo único, sem Quebra, sem Brado, sem hit stop). O robô quase não usa o Golpe Carregado (2% do `dealt_by`), então o Carregado **não foi medido em partida**: é conta, e vale conferir com o Daniel em mão.

### R8.1 Guerreiro: Carregado contra combo
Ciclos: combo de 3 golpes 1,22 s para 50 de dano; combo de 5 golpes 1,81 s para 80; Carregado (lança) 0,8 s de carga + 0,78 s de recuperação = 1,58 s (1,34 s com Concentração), 150 de dano, custa 20 de Magia. Magia do combo: 0,5 por golpe (x2 com Determinação) mais 2 do finalizador; o Carregado devolve 2.
"DPS por Magia" lido como o laço que se paga sozinho: n combos enchem a Magia de um Carregado, e a razão é (laço) sobre (DPS do combo sozinho). Apogeu entra no combo de 5 golpes: o 4º dano de 15 mais o giro de 20 dá +min(150% de 60, 400% de 20) = +80, ou seja o teto de 400% já corta (sem teto seriam +90).

| Montagem | DPS combo | Carregado cru (x combo) | dano por Magia (líquida) | laço (x combo) |
|---|---|---|---|---|
| 3 golpes, sem Dons | 41 | 95 (x2,3) | 8,3 | 52 (x1,26) |
| 5 golpes + Apogeu | 88 | 95 (x1,07) | 8,3 | 90 (x1,01) |
| + Força Concentrada | 88 | 133 (x1,5) | 11,7 | 96 (x1,09) |
| + Determinação + Concentração | 88 | 157 (x1,77) | 11,7 | 104 (x1,17) |
| + Força Titânica x3, custo x2 (Ímpeto completo) | 88 | 470 (x5,3) | 16,6 | **134 (x1,52)** |
| mesma, Apogeu 300% | 77 | 470 (x6,1) | 16,6 | 125 (x1,61) |

Leitura. (1) Tudo passa no critério 1,0 a 1,4 **menos o Ímpeto completo (x1,52)**, o único caso em que a Força Titânica é o que aparece. (2) **Apogeu 300% piora**: derruba o combo (88 para 77) e sobe a razão; não recomendo mexer no teto (fica 400%). (3) Só baixar a Força Titânica para x2,6 não basta (x1,43); o que fecha é subir o custo.
Variantes do Ímpeto completo (laço, razão): x2,6 e custo x2,5: 120 (**x1,35**); x3 e custo x2,5: x1,42; x3 e custo x3: x1,35; x2,4 e custo x2: x1,39; x2,6 e custo x2: x1,43.
**Proposta (P1, `gameplay-engineer`, `tools/make_data.gd` talento `forca_titanica`):** `final_pct` 2,0 para **1,6** (x2,6 no fim) e `omega_cost_pct` 1,0 para **1,5** (custo x2,5, 50 de Magia: o máximo do Guerreiro é 50, então o Carregado só sai com a barra cheia, que é o que dá o peso do golpe); Apogeu fica em 400%. Efeito esperado: laço x1,35, Carregado 546 de dano (era 630) a 11 dano por Magia. Como medir de novo: `--arena` com um alvo e `--talents=forca_concentrada,forca_titanica` com o robô forçado a segurar o ataque, ou a mão do Daniel.

### R8.2 Maga: números do `ArcaneKit` por conta
Rotação de 8 s em alvo único, Centelha contínua (0,25 s, 8 de dano, 1 de Magia, teto de 3 de Magia por segundo), Estilhaço a cada 4 s, Arco a cada 8 s, uma Combustão (15 de Magia): Centelha 193, Queimadura 4 por segundo (renova com 3 acertos) 23, Térmico 2 x 20, Sobrecarga 15, Combustão 35, Estilhaço 12, Arco 12 = **cerca de 41 de DPS** (o combo de 3 do Guerreiro faz 41, o de 5 com Apogeu 88, o laço do Ímpeto completo 134). Os 12 Dons da Maga somam só uns 3 a 5 de DPS em alvo único (Faísca Persistente +25% de Queimadura, Reação Amplificada +50% das reações, Campo Elementar na cúpula); ela escala em área (Arco com 3 a 5 alvos, Sobrecarga, Fissão, Geada), não em alvo único.
Fora da curva: **Combustão** (35 por 15 de Magia, 0,85 s: 41 de DPS cru contra 32 da Centelha, 2,3 de dano por Magia contra 8,3 do Carregado do Guerreiro): quase não vale gastar a Magia. **Choque Térmico 20 e Sobrecarga 15** (adicionam uns 5 e 2 de DPS): baixos para o que pedem (Frio mais Queimadura em 0,5 s). **Geada** (3 por segundo, 20 de Magia): quase só controle. `spark_damage` 8, `burn_dps` 4, Estilhaço 6 e Arco 12 parecem em linha (disparo à distância, 8 contra 15 do golpe do Guerreiro).
**Proposta (P1, passos de 10%+ no `ArcaneKit`, protótipo; o robô decide; `gameplay-engineer`):** `combust_damage` 35 para **70** (4,7 por Magia), `thermal` 20 para **35**, `overload` 15 para **25**, `frost_dps` 3 para **5**; Centelha fica em 8 (e `burn_dps` 4). Efeito esperado: de 41 para uns 55 de DPS de rotação (x1,35), a metade do salto necessário para encostar no 5 golpes mais Apogeu; Dom de alvo único ainda faltaria (a Faísca Persistente escala a Queimadura, mas é só 1 de DPS): ver com o Daniel se a Maga deve ser o herói de área mesmo (então basta o que está acima). Medir: `--hero=maga` 12 sementes R 0,25, `dealt_by.elemental` mais `burn` abaixo de 40% (hoje 25% a 33%).

### R8.3 Régua rápida do robô, 12 sementes (1 a 12), R 0,25, `smoke.sh 900`, Dons completos pelo `--talents=` (a Maestria 1 sem Dons; "alta" é só o que o robô lê, os 12 Dons do herói e nada do save)
| Linha | Vitórias (ENDING) | Chega a Morvath (sala 14) | Passa da sala 5 | Sala de morte (só quem morreu) | `dealt_by` principal |
|---|---|---|---|---|---|
| Guerreiro, M1 | 4 de 12 | 10 | 12 | 8, 11 e seis em 14 | ataque 30%, ultimate 19%, especial 18%, Investida 10% |
| Guerreiro, 12 Dons | 7 de 12 | 11 | 12 | 11 e quatro em 14 | ataque 28%, ultimate 21%, especial 18% |
| Maga, M1 | 3 de 12 | 4 | 10 | 3, 5, 6, 6, 7, 11, 11, 12, 14 | ataque 42%, elemental 20%, ultimate 7% |
| Maga, 12 Dons | 7 de 12 | 7 | 11 | 5, 6, 7, 10 | ataque 41%, elemental 30%, ultimate 5% |
Leitura. (1) O Guerreiro vence 4 de 12 sem Dons contra 1 de 12 do Lote D com a mesma régua: a diferença são os 15 Dons do `bc13f16` (o redesign) mais a vida 40 e a cura; os Dons completos levam a 7 de 12 e as mortes ficam em Morvath (a 11 de 12 chega a ele). O teto de 6 de 12 do robô forte sem Maestria vale para o M1 (4, dentro). O robô a R 0,25 não é gente. Aviso: a cópia foi tirada da árvore de trabalho do dia (com edições de Bênção de outros agentes ainda sem commit), não do `bc13f16` puro. (2) A Maga com o robô novo está **mais forte do que o esperado**: 3 de 12 no M1 contra 1 de 6 do Lote D, 7 de 12 com 12 Dons (igual ao Guerreiro), mas **morre cedo** quando morre (sala média 9,8 e 11,4 contra 13,2 e 13,8): a vitória sai em 40 a 60% e o resto cai nas salas 3 a 7. Não mexo na Maga para cima antes do Daniel jogar; a conta de DPS acima diz que ela é fraca em alvo único, o robô a deixa jogar à distância e usa a área. (3) Nenhuma reação passa de 40% do dano (elemental mais Queimadura: 25% no M1, 33% com Dons). (4) O Carregado fica em 2% do dano em todas as linhas: o robô não o usa, então a Força Titânica não aparece aqui (outra razão para o Daniel conferir em mão).
Resultados crus: 48 partidas, cópia isolada fora do repositório (removida). Comando: `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --hero=warrior|maga [--ultimate=cleave] [--talents=...]`.

## 2026-11-25 M-3 (Morvath do robô) e M-4 (pico do passo com 300 inimigos)

Medido numa cópia do HEAD (`1b2595a`), sem tela, sementes 1 a 12, sem Maestria nem Dons.

### M-3 Robô Guerreiro contra Morvath
| Perfil | Chega a Morvath | Vence | Vida e Bênçãos ao chegar | Luta (s) |
|---|---|---|---|---|
| `--bot-reaction=0.25 --ultimate=cleave` (régua do E6) | 11 de 12 (sem. 6 morre na sala 3) | 5 de 12 (1, 4, 8, 10, 11) | vida 40 a 101 (mediana 63), 7 a 9 Bênçãos | mediana 141 (90 a 177), 11 lutas |
| robô padrão (`tools/smoke.sh 900 --seed=N`, o do QA2-02) | 12 de 12 | 2 de 12 (2, 8) | vida 32 a 90, 6 a 9 Bênçãos | mortes em 28 a 221 s; fase da morte 1 (2), 2 (3), 4 (3) |
| `--start=boss` (vida cheia 40, 0 Bênçãos) | n/a | 0 de 12 (11 morrem na fase 2) | vida 40, 0 Bênçãos | 85 a 216 (mediana 126) |

Leitura:
- **Não é só o robô, mas o robô pesa muito**: a mesma descida vai de 2 de 12 (padrão) para 5 de 12 só trocando a reação (0,25) e a ultimate (cleave). O "9 de 12 perdem" do QA2-02 é o robô padrão (2 de 12 vencem, 10 perdem).
- **O chefe sozinho com vida cheia e sem Bênçãos é intransponível** (0 de 12, morte na fase 2: lâminas e invocados do ritual, `blades` 3 a 22 e `mage` 11 a 41 de dano): é o desenhado ("sem Bênçãos ninguém vence", seção anterior). A chegada real (7 a 9 Bênçãos) é o que decide: de 0 a 5 de 12.
- **Duração**: mediana 141 s a 0,25, dentro da meta de 120 a 180 s. A luta de 287 s (QA2-03, sem. 8 no padrão) é o robô que se perde (sem. 8 agora 298 s com vitória, 46 de vida): luta longa é o robô que não acerta a postura, não é o chefe com vida demais.
- **Taxa**: 5 de 12 com o robô forte sem Maestria fica abaixo do teto de 6 de 12 que o PO pediu ("vencer cedo é exceção"). As crianças acharam o jogo difícil e o robô padrão, mais parecido com elas, vence 2 de 12: **proposta: não mudar números de Morvath**. Qualquer alívio vai para as duas fases que matam (2: lâminas e invocados), e só depois do teste do Daniel; se ele disser que Morvath está duro demais, o primeiro botão é `blades` e `adds` (dano e quantidade) da fase 2 em `_bosses`, 10 a 15% abaixo, e medir de novo com as mesmas 12 sementes.
- Limites do robô: a fase 1 mata em 28 a 29 s duas descidas do padrão (sem. 7 e 12, chega com 34 a 42 de vida): não é Morvath, é a vida baixa ao chegar e a reação lenta; o robô não faz o Preparo/Videira nem usa fonte antes do chefe. Registro humano (`user://runs.jsonl`) é a régua que falta.

### M-4 Pico de 56 ms com `--stress=300 --seed=5`
Causa achada (perfil por trecho do passo, `--trace-steps`, mais um relógio dentro do `Combat.strike`): **o golpe do herói que acerta muitos inimigos de uma vez**. O trecho `player` do passo (que inclui `combat.strike` pelo sinal `struck`) tem os picos; o `horde` fica em 8 a 15 ms estável com 300 de pé. Custo por inimigo atingido em `Combat.hit_enemy`: **cerca de 0,35 ms** (mais de 15 consultas de `boons.stat` por tag, `DamageCalc`, número de dano, efeitos, `enemy_struck`). Medido: Brado (`shout`) com 130 inimigos = 44,8 ms; `cut1` com 68 = 24,5 ms; 43 = 16 ms; 25 = 9,9 ms. O primeiro Brado aos 0,3 s do teste acerta os 130 que o `--stress` joga em volta (4 a 20 m), daí o pico de 42 a 56 ms; depois os picos de 20 a 28 ms são golpes em grupos de 50 a 70.
- **Real**: nas descidas medidas o máximo vivo é 6 a 8 (`max_alive`); a 8 acertos por golpe são cerca de 3 ms. O pico de 56 ms é artificial (300 inimigos empilhados no alcance do Brado, que não existe no jogo). **Causa dita e proposta de aceitar** para o jogo; não é regressão.
- Se um dia houver hordas grandes (modo `--horde`): (1) içar para fora do laço de `Combat.strike` as consultas de `boons.stat(..., tags)` que dependem só das tags do golpe (damage_pct, final_pct, crit_pct, shove_pct, push_pct, stun_pct, freeze_time, weak_time, mark_time, burn_dps, detonate_dmg, shatter_pct: calcular uma vez por golpe num pequeno `StrikeStats`), o que tira a maior parte dos 0,35 ms; (2) limitar a 24 inimigos com número, estrela e efeito por golpe (os demais só recebem o dano). Dono: `gameplay-engineer`, P2; alvo medido: 130 acertos abaixo de 25 ms com a mesma linha.
- Aviso separado (não é M-4): nas 12 descidas do robô a 0,25 o `step_ms_peak` teve 6 picos de 20 ms a 3,4 s (200 a 3372 ms em 5 delas) com 4 processos em paralelo; é carga de recurso na mudança de sala ou contenção da máquina, não passo de simulação (avg 0,4 a 0,9 ms). Vale uma passada do `qa-performance` na GPU antes de dizer que é aceito.

## SW-C4 a C8 (gameplay-engineer, 2026-11-25): dano e aviso dos inimigos, barra de atordoamento, Rato de osso, Capitão
Régua: herói de 40 de vida; SWORN: comuns tiram 10 a 20% (4 a 8), aviso 0,5 a 0,7 s; elite, guardião e chefe 0,8 a 1,0 s; área grande 1,2 a 1,6 s. Dano = `attack_damage` (o golpe), aviso = `attack_windup` já com o `_quick` (x0,8, piso 0,5 e 0,6 para pesado). Só `tools/make_data.gd`.

| inimigo | dano antes -> depois | aviso antes -> depois (s) |
|---|---|---|
| Esqueleto | 5 -> 5 | 0,60 -> 0,60 |
| Corredor | 8 -> 8 | 0,68 -> 0,68 |
| Mago | 6 -> 6 | 0,80 -> 0,70 |
| Besteiro | 5 -> 5 | 0,64 -> 0,64 |
| Guarda (investida e golpe curto) | 14 e 11 -> 8 e 8 | 0,92 -> 0,92 |
| Sacerdote | 10 -> 8 | 0,64 -> 0,64 |
| Saltador | 12 -> 8 | 0,64 -> 0,64 |
| Lançador | 9 -> 8 | 0,64 -> 0,64 |
| Armadilheiro (placa) | 10 -> 8 | 0,50 -> 0,50 |
| Trinca | 4 -> 4 | 0,72 -> 0,68 |
| Varredor (área) | 8 -> 8 | 0,72 -> 1,20 |
| Canalizador (área, 5 pulsos de 5) | 5 -> 5 | 0,72 -> 1,20 |
| Esqueleto Maior | 7 -> 7 | 0,88 -> 0,88 |
| Corredor Maior (área) | 9 -> 8 | 1,00 -> 1,20 |
| Elite esqueleto | 5 -> 5 (2 golpes) | 0,72 -> 0,88 |
| Elite corredor | 8 -> 8 | 0,80 -> 0,80 |
| Elite mago | 6 -> 6 | 0,80 -> 0,80 |
| Elite besteiro | 5 -> 5 | 0,64 -> 0,80 |
| Elite guarda | 14 -> 8 | 0,92 -> 0,92 |
| Elite sacerdote | 10 -> 8 | 0,64 -> 0,80 |
| Elite trinca | 4 -> 4 | 0,72 -> 0,80 |
| Elite varredor | 8 -> 8 | 0,72 -> 1,20 |
| Ancião (leque) | 3 -> 3 | 0,80 -> 0,80 |
| Cavaleiro (investida, golpe, escudo, onda) | 6, 6, 6, 5 -> igual | 0,60 -> 0,60 (exceção: pedido do Daniel de 2026-11-23, o aviso do guardião sobe a 0,8 se ele mandar) |
| Rato de osso (novo) | 3 | 0,50 |
| Capitão esqueleto (novo) | 8 (investida e golpe) | 1,20 |

Barra de atordoamento (C5): peso do botão x `poise_mult`; elite 0,5 (13 golpes leves ou 4 especiais; o especial tira 0,3 da barra), Capitão 0,4, guardião 0,3 (ultimate 4 golpes cheios), Morvath a Postura de 1300 x 0,5 como era. Atordoamento: elite e Capitão 2,5 s, guardião e Morvath 3,5 s; +25% de dano enquanto aberto (Morvath +30%); cada quebra seguinte pede 1,25x mais barra, sempre da base (1, 1,25, 1,56, 1,95). Os comuns: 1,2 s, +40%, sem crescer, como antes.

Rato de osso: um pacote de 4 a 6 por onda (`pack_min` 4, `pack_max` 6; sem o teto, a primeira medição pôs 20 a 26 ratos numa sala, só ratos), das salas 3 em diante. Capitão: um por luta, das salas 4 em diante, na última onda, chama 5 soldados fracos.

Robô, `smoke.sh 900 --seed=N`, sementes 1 a 6 (antes = HEAD `94e74f5`; depois = esta entrega; o conteúdo mudou, então as mesmas sementes não repetem as mesmas salas depois da sala 3):

| semente | antes: sala, fim, tempo | depois: sala, fim, tempo |
|---|---|---|
| 1 | 14, vivo, 894 s (Morvath fase 3) | 14, morreu na fase 1 de Morvath, 722 s |
| 2 | 14, morreu fase 2, 728 s | 14, morreu na fase 3, 622 s |
| 3 | 12, morreu, 519 s | 6, morreu no Cavaleiro, 259 s |
| 4 | 14, venceu, 772 s | 14, venceu, 813 s |
| 5 | 11, morreu, 471 s | 8, morreu, 316 s |
| 6 | 14, morreu fase 3, 709 s | 8, morreu, 416 s |

`stuck` 0 nas 12 partidas. Chegaram a Morvath 4 de 6 nas duas medições, uma vitória em cada. Mortes antes de Morvath: 2 antes (salas 11 e 12), 3 depois (salas 6, 8 e 8: arqueiros, Cavaleiro e Ancião levaram a vida no robô). Dano levado por tipo (soma das 6 partidas, só inimigos e hazards; vida do herói 40): antes arqueiro 93, mago 93, Cavaleiro 55, Ancião 33, Canalizador 33, guarda de elite 29, guarda 10, esqueleto 5; depois arqueiro 60, mago 85, Cavaleiro 45, Ancião 18, guarda 16, esqueleto 15, Armadilheiro 8, corredor 7, arqueiro de elite 5. Os ratos não aparecem entre os que ferem (a mordida de 3 quase nunca acerta o robô), nem o Capitão (2 lutas, 0 de dano). Sinal de saúde: no começo direto na sala do guardião (`--start=miniboss`, sementes 3, 4 e 7, 200 s) a vida levada pelo Cavaleiro caiu de 23 para 5 e a do Ancião de 12 para 6, porque a barra de atordoamento de 3,5 s quebra com especial e Investida (as quebras do robô: especial 4 e Investida 2 contra 0 antes). Seis sementes são pouco para separar ruído de efeito: a morte na sala 6 da semente 3 é a luta do Cavaleiro com 36 de vida na entrada e 28 de dano levado, e o início direto na mesma luta deu o contrário. Se o Daniel achar a descida mais fácil ou difícil, os botões são `poise_mult` (quantas pancadas quebram) e `poise_stun` em `tools/make_data.gd`.


## SW-B2: sorteio das Bênçãos (2026-11-25)

Referência: `docs/design/sworn_rea_kingswood_2026-11-25.md` (raridades 79,5 / 14 / 4,5 / 1,5 / 0,5; fada já tida pesa 3 contra 1;
dupla de 0 a 50% entre 2 e 10 Bênçãos; mesmo passo por raridade).

| | antes | depois | SWORN |
|---|---|---|---|
| `rarity_chance` (rara, épica, lendária) | 10 / 5 / 1% | 16 / 6 / 2% | |
| comum / rara / épica / lendária | 84,6 / 9,4 / 5,0 / 1,0 | 77,4 / 14,7 / 5,9 / 2,0 | 79,5 / 14 / 4,5 / 1,5+0,5 |
| épicas+lendárias oferecidas por descida (24 cartas) | 1,4 | 1,9 | |
| tomadas pelo robô por descida (6 sementes, 900 s) | 5,5 / 2,3 / 0,17 / 0,17 | 5,3 / 1,3 / 0,67 / 0,67 | |
| Elo por carta | 12% fixo | 0 com menos de 3 Bênçãos, 6% com 3, 50% com 10 | 0 a 50% |
| anjo já tido | peso 1 | peso 3 contra 1 | 3 contra 1 |

O guardião (90 / 7 / 3%) e a Provação (40 / 10 / 0%) ficam como estavam. Passo por raridade: multiplicadores 1 / 1,5 / 2 / 2,5
(mesmo passo de 0,5 do primeiro nível), e o teste `test_every_rarity_adds_one_step_to_every_scaled_number` confirma que todo
número que escala com a raridade cresce de comum a lendária; nada precisou mudar. A amostra do robô é pequena (6 descidas, ruído
grande); a conta exata está em `BoonState.rarity_odds`.
## SW-REA (2026-11-25): recuperação mais curta, Cavaleiro do Butcher e Morvath sem espera (gameplay-engineer; `docs/design/sworn_rea_butcher_2026-11-25.md`)

Números novos em `tools/make_data.gd` (`ENEMY_RECOVER`, `recover_time`, `gap_*`, `knight`, `_bosses`); tabela de tempos em `combat_cadence.md` 14. Robô headless 60 fps, `smoke.sh 900`, sementes 1 a 6, mesmo HEAD (`dd53f8c`) antes e depois.

| Semente | Antes | Depois |
|---|---|---|
| 1 | sala 14, 680 s, Morvath na meta | sala 14, 604 s, morreu em Morvath (245 de vida dele) |
| 2 | sala 14, 549 s, morreu em Morvath | **sala 5, 148 s, morreu no Cavaleiro** |
| 3 | sala 14, 487 s, morreu em Morvath | **sala 10, 329 s, morreu no Cavaleiro** |
| 4 | sala 14, 782 s, morreu em Morvath | sala 14, 612 s, sobreviveu (14 de vida) |
| 5 | sala 14, 609 s | sala 14, 548 s, morreu em Morvath |
| 6 | sala 12, 454 s, morreu antes | sala 14, 560 s, morreu em Morvath |

Mortes antes de Morvath: 1 antes, 2 depois (as duas pelo Cavaleiro). Dano levado do Cavaleiro (soma da partida): 0, 16, 16, 0, 5, 12 antes; 30, 35, 55, 8, 6, 20 depois. Intervalo médio entre a recuperação e o próximo aviso do Cavaleiro (`idle.mean`): 0,46 a 0,64 s antes, 0,11 a 0,21 s depois (a espera de IA do Butcher é zero).

`--start=miniboss` (200 s): a semente 7 é a única com Cavaleiro; antes ele durou 36,5 s e tirou 18, agora 33,6 s e tirou 12, com 27 golpes punidos em 24 avisos (10 em 21 antes). Sementes 3 e 4 sem Cavaleiro (Ancião); sem regressão.

Morvath (`--start=boss --boons=25 --seed=5`, 120 s): antes 99 s e 40 de vida, 7 foices, 6 ceifas, 1 rajada; depois 103 s e 40 de vida, 5 foices, 5 ceifas, 2 rajadas, 4 lâminas e 3 chamados. Intervalo médio entre ataques 0,31 s antes e 0,15 s depois.

Velocidade do Cavaleiro: com 6,0 m/s o herói (6,75) ainda se afasta. Teste com 4,5 m/s nas sementes 2, 3 e 6: a 2 passou da sala 5 (chegou em Morvath), a 3 e a 6 continuaram morrendo no Cavaleiro (55 e 36 de dano). A velocidade não é o que pesa; é a espera zero com dano 12. Se o Daniel achar demais, alavancas por ordem: `gap_max` 0,15 para 0,5, `attack_damage` 12 para 10, velocidade 5,0. Ficou 6,0 como pedido.

## Revisão 2026-11-26 (balance-designer, antes da entrega; HEAD `f2aa94d5`, robô 0,25, `smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes 1 a 12, partida inteira)

Régua do robô, não de gente. Nada implementado; dono de todos os itens: gameplay-engineer. Meta vigente (B.3 e "Meta nova do Daniel"): começo duro, guardião de novato perde mais do que vence, Morvath quase nunca na primeira descida, crianças com Coragem automática.

### Medido
- **Resultado**: 3 vitórias em 12 (sementes 4, 5, 12; 25%), 8 mortes em Morvath (fases 2: 3, fase 3: 2, fase 4: 3), 1 morte antes (semente 11, sala 9 Fendas: 66 de dano em 55 s, `mage` 36,5 e `mage_elite` 30). Chegou em Morvath 11 de 12, com 6 a 9 Bênçãos (média 7,3) e 31 a 65 de vida.
- **Dano até Morvath** (salas 1 a 13): 34 a 89, média 55; salas 1 a 4 quase sempre 0 a 10 por sala (tempo de 78 a 150 s nas quatro). Morvath: 44 a 91 de dano, 138 a 249 s de luta.
- **Cavaleiro, sala 5 (`hp_scale` 0,7)**: luta 14,1 a 23,9 s, mediana 16,4 s (7 sementes); dano ao herói 0 em 6 de 7, 6 na semente 10. `breaks.special` presente, avisos iniciados 4 a 6, cortados 1 a 2, punidos 2 a 5. **Cavaleiro, sala 10 (vida cheia 500)**: 16,6 a 35,1 s, mediana 24,9 s; dano 0 em 4, 6 (mago) e 10 (placa de espinho) nas outras. Ancião (salas 5 e 10): 18 a 65 s, mediana 50 s, dano 3 a 15.
- Leitura: a quebra de guarda funciona (550/0,5) e o Cavaleiro caiu abaixo da meta de 30 a 40 s e de 12 a 36 de dano em todas as sementes. É a primeira parede da descida e hoje não é parede.

### Recomendação fechada, Cavaleiro (respeita "preciso conseguir quebrar a guarda")
Manter `KNIGHT_ARMOR` 550 e `KNIGHT_ARMOR_SOFT` 0,5 (a quebra é do Daniel e não se toca). Compensar só na vida, que não mexe na guarda:
1. `_first_room(5, &"knight", ...)` em `tools/make_data.gd` (~linha 3118): `hp_scale` 0,7 para **1,0**.
2. `_enemy(&"knight")` (~linha 432): `hp` 500 para **650**.
Previsão (linear no tempo de luta do robô: 16,4 s a 0,7 x 500 = 350 de vida; 23 a 25 s a 500; 650 dá 30 a 32 s no robô, 35 s na sala 10): luta 30 a 36 s. Dano ao herói sobe de 0 a 6 para algo entre 6 e 20 pela maior exposição; **se medir abaixo de 12**, segunda alavanca: `attack_damage` 12 para 15 (golpe de carga, ainda abaixo do 18 antigo que matava novatos). Não mexer em `gap_max`, velocidade nem espera (o SW-REA já mostrou que a espera zero com dano 12 é o que pesa). Medir: `--start=miniboss` mais as 12 sementes, critério luta 30 a 40 s mediana e dano 12 a 36 mediano. Efeito colateral: o Cavaleiro de elite nas salas 8 a 12 também fica 30% mais duro; conferir a sala 10 (alvo até 40 s).
Para criança: a Coragem automática já cobre; não baixar o Cavaleiro por causa delas.

### Lista priorizada
- **P0**: nenhum. Sem travamento (`stuck` 0 nas 12), nada de sala que quebre a partida.
- **P1-A Cavaleiro**: acima (hp 650, `hp_scale` 1,0).
- **P1-B Fendas (sala 9) com magos**: semente 11 morreu com 66 de dano de `mage` + `mage_elite` em uma sala; os dois mais letais por sala da amostra são magos (28 a 36). Proposta: `make_data.gd`, `mage_elite` `attack_damage` -20% (~linha dos magos de elite) ou tirar o segundo mago da onda da Fendas; dono room-designer decide qual. Medir: sala 9 em 12 sementes, dano médio abaixo de 25 e máximo abaixo de 45.
- **P1-C Salas 1 a 4 sem risco**: 0 a 10 de dano por sala, 78 a 150 s para as quatro. A direção do PO pede muito difícil de completar e se acirra aos poucos; hoje 25% do robô vence e a metade inicial não cobra nada. Antessala (Bênção) mais Cripta A em Ouro tira poder cedo e deve ter ajudado; manter. Proposta: não mexer no número antes do teste dos Daniel (ele achou fácil, as crianças difícil; a régua do robô concorda com o Daniel). Se ele repetir "fácil": `dano dos inimigos` das salas 2 a 4 +25% pelo `budget`/escala da sala (`_first_room`, `hp_scale` só no guardião).
- **P2 Ancião**: mediana 50 s, dano 3 a 15 (queixa de dano baixa); só observar, já é a sala mais longa.
- **P2 Placa de espinho no Cavaleiro (semente 9, 10)**: legítimo (dano de perigo 10); sem mudança.
- **Quickwin**: o `RESULT` já separa `hurt_by` por sala, mas falta tempo de luta do guardião e `win` explícito (hoje se deduz de `boss_hp` -1 e `hp` maior que 0): acrescentar `won` (bool) e `guardian_fight` ao RESULT (QW-3 da revisão do combate).

### Depois do teste do Daniel
Pedir o `runs.jsonl`: sala de morte, tempo no Cavaleiro e se quebrou a guarda (`breaks.special` do robô é só proxy). Remedir as 12 sementes com os mesmos comandos após aplicar P1-A e P1-B e comparar com a tabela acima (3 vitórias, 8 em Morvath, 1 nas Fendas).

## Bênçãos V1 (2026-11-26)

Medido por balance-designer sobre o HEAD `269b87ba` (V1 do CSV, sem ajuste) e de novo depois dos números abaixo. Robô 0,25, `--ultimate=cleave`, sementes 1 a 12, só números em `tools/make_data.gd` (grupo `boons`). Régua do robô, não de gente.

### Como medi
- **Descida inteira** (`smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`): "natural" (sorteio livre de anjos) e um anjo forçado por vez (`--angels=sarael|nivael|lumael|shomael|velael|galael|qeshael`, as cartas vêm pelo sorteio normal daquele anjo). Métrica: vida média que sobra no Morvath (`boss_hp`, menor = melhor), vitórias, fase máxima.
- **Teto no Morvath** (`--start=boss --hero-hp=500 --boon-ids=<as 9 do anjo>`): herói não morre, mede o tempo de luta (`boss.time`) e o dano sofrido (`sum(boss.hurt_by)`). Sem Bênção: 309 s (mediana), dano sofrido 229.
- **Linha de base antes da V1**: o commit anterior (`2fe2b3c1^`, cópia isolada) com as mesmas 12 sementes.

### Achados
1. **A V1 do CSV é bem mais fraca que a antiga** (P0 de ritmo): natural, vida que sobra no Morvath **1444 (antes da V1) para 3588 (V1 do CSV)** de 5146; fase máxima mediana 3 para 2. Vitórias 0 em 12 nos dois (o robô estava em 3 de 12 em `f2aa94d5`; mudou outra coisa no meio). Causa: some a pilha automática (Ômegas, Supremos antigos, chama viva etc.) e a maior parte dos poderes novos é utilidade (estado) sem dano.
2. **Sarael domina** (P1): sozinho, 3 das 3 vitórias da amostra de anjos e 1346 de vida que sobra no Morvath (o melhor); no teto, tempo de luta **213 s contra 309 sem Bênção (-31%)**; Queimadura (16 a 17%) mais Combustão (6%) são 23% de todo o dano. Os outros seis anjos ficam entre -16% e +8%.
3. **Galael é o fraco** (P1): 4287 de vida que sobra (pior), no teto 334 s (+8%, pior que sem Bênção). Isolando por poder (12 sementes, teto): Golpe, Peso, Poder e Vendaval sozinhos = 308 a 318 s (nada); **Passos Leves (carga extra de esquiva) sozinho = 402 s e 337 de dano sofrido** (contra 309 e 229). Leitura: o robô gasta a carga extra no Investida e se expõe. É artefato provável do robô; **não mexi** (é +1 carga fixa, não número), mas pedir ao Daniel que sinta. Cadência + Turbilhão + Fluxo (com o Golpe) = 281 s: o conjunto de ritmo funciona, a velocidade pura não vira dano.
4. **Qeshael, Nivael, Shomael, Velael ficam colados no zero** no teto (-5% a -9%): são estados e proteção. Shomael corta o dano sofrido por segundo em 16% (0,634 contra 0,752) e Velael em 7%: valem pelo que protegem, não pelo dano. Nivael não aparece no teto (o Morvath não congela nem é estilhaçado, o ganho está nos inimigos comuns; não mensurável no teto).
5. **Lumael é o segundo** (-16%, crítico): saudável, deixei os números do crítico como estavam.
6. **Sem quebra**: nenhuma interação fora do controle. Eco não gera eco (tally `echo` 1), Combustão não soma DPS de queimadura, `luz_crescente`, `fortuna` e `esplendor` ficam abaixo do teto de 60% e 250%. Eco de golpe primário não existe (só Peso, Brado e Exército), então `eco_crescente`/`sombra_revelada` só valem com um desses.
7. Brado (`shout`) fica em 1% do dano no teto do Morvath: nenhum Brado de anjo muda isso (são estados).

### Mudanças (números comuns; subem por raridade como já faziam)
| Poder | Antes | Depois | Por quê |
|---|---|---|---|
| Golpe em Brasa (`cel_burn_dps`) | 4 +2 por nível | **3,5 +1,5** | Sarael domina |
| Peso em Brasa | 6 +3 | **5 +2,5** | idem |
| Combustão (`cel_combust_dmg`) | 12 +6 | **9 +4,5** | idem (6% do dano) |
| Peso do Inverno (Supremo de Nivael) | 40/60/85 | **55/80/115** | Nivael sem dano |
| Estilhaçamento | +25% +10 | **+40% +15** | idem |
| Julgamento da Luz (Supremo de Lumael) | 15/22/32 | **24/36/50** | raios de 15 sumiam |
| Poder Inabalável (Shomael) | 10/15/21 | **14/21/30** | |
| Abalo Celestial (Supremo de Shomael) | 30/45/66 | **45/66/96** | |
| Força Inabalável | +20% +10 | **+30% +12** | |
| Vulnerabilidade | +10% +5 | **+15% +7** | Velael |
| Névoa Profunda (`weak_pct`) | +5 pp | **+8 pp** | Velael |
| Peso dos Ventos (rajada) | 8/12/17 | **14/21/30** | Galael |
| Turbilhão | 12 +6 | **18 +9** | Galael |
| Golpe dos Ventos (velocidade) | +10% +3 | **+12% +4** | Galael |
| Vendaval (velocidade 5 s) | +20% | **+30%** | Galael (teto do total, 50%, mantido) |
| Peso da Penumbra (eco) | 30% | **40%** | Qeshael |
| Poder da Penumbra (eco) | 25% | **35%** | Qeshael |
| Exército de Ecos | 25% | **40%** | Qeshael |
| Eco Crescente | +20% +10 | **+30% +15** | Qeshael |
| Sombra Revelada | +15% +5 | **+20% +8** | Qeshael |

O `BALANCEAMENTO.csv` (Daniel) fica como estava; estes números o substituem em jogo. Os testes `test_blessings_v1_*` foram atualizados para os novos valores (nada afrouxado).

### Depois (mesmas sementes e comandos)
| Medida | Antes da V1 | V1 do CSV | V1 ajustada |
|---|---|---|---|
| Natural, vida que sobra no Morvath (média) | 1444 | 3588 | **1989** |
| Natural, vitórias em 12 | 0 | 0 | 1 |
| Teto, Sarael (tempo de luta, média; sem Bênção 306) | n/d | 215 | **225** |
| Teto, Lumael | n/d | 265 | 266 |
| Teto, Velael | n/d | 279 | 275 |
| Teto, Shomael | n/d | 292 | 286 |
| Teto, Nivael | n/d | 291 | 295 |
| Teto, Qeshael | n/d | 292 | **274** |
| Teto, Galael (9 poderes; só o conjunto de ritmo, Golpe + Cadência + Turbilhão + Fluxo) | n/d | 334 (281) | 312 (273) |

Leitura: o ajuste leva o natural a meio caminho do antigo (1989 contra 1444); a meta é ficar na casa de 1500 a 2000 com 1 a 3 vitórias em 12 no robô. Sarael continua na frente (225 s) mas a vantagem caiu de 31% para 27%.

### Pendências
- Passos Leves (Galael): pedir a sensação ao Daniel antes de mexer (ver achado 3).
- Nivael e Velael valem sobre inimigos comuns; falta uma medida de dano sofrido por sala com anjo forçado (o ruído de 12 sementes é maior que o efeito).
- Depois do teste do Daniel: o `runs.jsonl` (`angels` por sala, `chose`) diz que anjos as pessoas pegam e onde morrem; recomparar com estas tabelas.


## PM-4 (2026-11-26 noite, room-designer): fontes por caminho

**Integração (Game Director):** PM-3 nas Fendas: as zonas da parede oeste (cedo e tardia) caíam no riacho e em chão fora de alcance (`test_arenas`, `test_room_gaps`); ficou só a do noroeste cedo e o `far_spawn` 0. Ficou `fountains_per_path = 3`, não 2: uma fonte antes do segundo guardião (cura possível 120% em vez de 80%), porque o teste das crianças já achou difícil. Medir de novo com o Guerreiro V1.
Antes: 4 fontes em todo caminho possível (salas 4, 6, 9 e 11; 300 mapas), cura 160% da vida. Depois: `fountains_per_path` 2 (salas 4 e 6), cura 80%,
sem fonte da sala 7 à 13. Robô 12 sementes: vida média ao entrar nas salas 7 a 13 de 40,0 para 27,1; Morvath alcançado 8 de 12 nas duas medidas.
Se for duro demais para o novato, o botão é `st.fountains_per_path = 3` em `make_data` (uma fonte antes do segundo guardião) e regerar `stage`.


## Bênçãos V2 e retorno 2026-11-26 (balance-designer, HEAD `2eab949a`, robô 0,25, `--ultimate=cleave`, sementes 1 a 12)
Régua do robô, não de gente. Teto = `--start=boss --hero-hp=500 --boon-ids=<as 9 do anjo> --smoke=900`, tempo de luta médio (`boss.time`). Natural = `smoke.sh 900 --seed=N`. Execução com no máximo 2 partidas ao mesmo tempo, cópias fora de `/tmp`.

### 1. Teto dos anjos: o Guerreiro V1 mudou a régua
**Observado/medido:** sem Bênção o Morvath levava **306 s** antes do GP-1 e agora leva **410 s** (12 sementes, dano sofrido 357). Os 245 a 275 s da meta do GP-2 foram escritos para os 306 s; com o herói de hoje todos os anjos sobem em segundos absolutos. Por isso a comparação passa a ser **relativa ao sem Bênção**.
| Anjo (teto, 9 poderes) | Tempo de luta | vs 410 s | Referência antiga (vs 306 s) |
|---|---|---|---|
| Sarael | 272 | -34% | -27% (225 s) |
| Zerael antes do ajuste (corte de 25%) | 307 | -25% | |
| **Zerael depois (esta rodada)** | **302** | **-26%** | |
| Saarael (Trovão) | 331 | -19% | |
| Lumael | 341 | -17% | -13% (266 s) |
| Velael | 377 | -8% | -10% (275 s) |
Meta relativa proposta (equivale à antiga): Zerael e Saarael entre Lumael e Velael, **-8% a -17% (340 a 377 s)**.
- **Saarael: -19%, dentro** (no limite forte). Fontes: ataque 59%, ultimate 14%, descarga 9,4%, faísca 4,5%, tempestade 3,2%; nenhuma fonte de Bênção acima de 30%. **Não mudei.**
- **Zerael: -26%, forte demais para a meta relativa.** Veneno 18,8% + Saturação 5,9% + Epidemia 1,5% = 26% do dano. Apliquei um corte de uns 10% (`golpe_peste` 0,6 +0,22 para **0,55 +0,2**, `pesado_peste` 0,9 +0,3 para **0,8 +0,27**, `saturacao` 9 +4,5 para **8 +4**; `tools/make_data.gd` `_v1_boons`, regerado com `-- boons angels`): **302 s contra 307 s, ou seja, dentro do ruído** (desvio de uns 15 s em 12 sementes). Para chegar a -17% faltaria cortar uns 35% do veneno. **Não fiz**: o Daniel acabou de dizer que o jogo está difícil e que falta dano, e cortar Bênção vai no sentido contrário. Recomendo manter Zerael como está (-26%, atrás do Sarael -34%) e decidir a meta junto com o dano do herói (seção 3). Testes `test_blessings_v2_catalog` e `test_blessings_v2_combat` atualizados (limite do estouro da Saturação 12 para 11, porque 8 + 4 = 12 não passa de 12); 72 de 72 passando.
- Aviso: a meta antiga de "245 a 275 s" tomada em absoluto pediria SUBIR Zerael e Saarael (302 e 331 estão acima de 295) e os faria passar o Sarael (272), quebrando "Sarael é o mais forte". Por isso adotei a leitura relativa.

### 2. Natural (sem anjo forçado, partida inteira, 12 sementes, estado antes do ajuste de Zerael)
- **Vitórias 0 de 12.** Chegam ao Morvath **6 de 12** (sementes 4, 5, 7, 8, 9, 10); mortes: **sala 14 (Morvath) 6**, sala 12 duas, sala 7 duas, sala 5 e sala 10 uma cada.
- Tempo até o Morvath (quem chegou): **521 s** (462 a 603). Luta no Morvath de quem chegou: 29 a 283 s antes de morrer; fase máxima 1 a 3. Vida que sobra no Morvath de quem chegou: **média 4225** de 5146 (1567 a 7655); melhor semente 8 (1567, fase 3).
- Vida ao chegar nele: 27 a 67 (fonte e cura já contam). Dano sofrido nas salas 1 a 5: 5 a 59 no total (a semente 11 morreu na sala 5 com 59).
- Dano do herói: **33 por segundo na partida inteira, 37 por segundo nos primeiros 200 s** (capítulo 1). Fontes: ataque (combo) 66,6%, ultimate 12,3%, Esmagador e Lança (`omega_*`) 10%, Corte Circular (`shout`) 2,1%; **Bênçãos 6 a 7%** (faísca 1,5, queimadura 1,3, veneno 1,1, chuva de brasas 0,6, tempestade 0,7 etc.) e perigos de sala 2% (runas, coluna, placas, espinhos). Sem fonte acima de 30%.
- Leitura: depois do GP-1 o robô quase não ganha mais; antes da V1 do Guerreiro a mesma régua dava 3 de 12 (f2aa94d5) e vida restante 1444 a 1989.

### 3. Retorno do Daniel: "muito difícil", "os personagens tinham que dar mais dano no capítulo 1" (só medida e propostas, nada aplicado)
**Medido** (`smoke.sh 200 --seed=N`, mesmas 12 sementes; "antes" = commit `1429bd90^`, imediatamente antes do GP-1):
| | Antes do GP-1 | Hoje (V1) | Variante A (abaixo) |
|---|---|---|---|
| Dano por segundo nos primeiros 200 s | **50,9** | **37,1** (-27%) | 38,6 |
| Dano sofrido por segundo | 0,10 | 0,14 (+40%) | 0,12 |
| Sala alcançada em 200 s (média) | 7,0 | 5,9 | 5,8 |
| Morvath sem Bênção (410 s hoje; 306 s antes) | 306 | 410 | 362 (-12%) |
| Fontes do dano | combo 34%, Raio (especial) 18%, Investida 10%, Brado 9% | combo 72%, Esmagador/Lança 11%, Corte Circular 2% | combo 74% |
**Inferência (conta à mão, alvo único, Maestria 1, sem Dons):** o combo (15, 15, 30 = 60 de dano) fazia uns 49 de dano por segundo e continua. Antes ele era completado por Investida (60 a cada ~3 s com o desconto por golpe, +2 de Magia por inimigo), Brado (35 a cada 12 s mais 15% de velocidade), Raio do especial (35 por 12 de Magia, quase sem custo de tempo) e Magia máxima 50. Tudo isso saiu ou encolheu: Magia máxima 30, sem desconto de recarga, e os três botões novos pagam pouco pelo tempo que tomam (Esmagador 75 em ~1,3 s = 58 por segundo, Corte Circular 35 em ~0,8 s = 44, Lança 150 em ~1,6 s = 95 por segundo contra 49 do combo). **O melhor laço de Magia hoje vale só +10% a +25% sobre o combo sozinho** (45 a 51 contra 41 a 49). A referência SWORN do repositório (espada 65 de dano por segundo, mediana de 40 contra o Butcher, sem melhorias 3,3 a 5 min de luta) deixa o Guerreiro em 63% a 75% da espada deles só com o combo; o Hades II, de que o combo é cópia, tem os especiais e o Dash-strike como complemento, que aqui saíram.
**Medida da variante A** (cópia fora do repositório, descartada): combo 18, 18, 36 (+20%) e Esmagador 100, Corte Circular 45, Lança 180. Resultado: dano por segundo só +4% (38,6) e **sala alcançada igual**; o Morvath sem Bênção cai de 410 para **362 s (-12%)**, dano sofrido por segundo cai 0,14 para 0,12. Natural 12 sementes: 0 vitórias, 4 de 12 chegam ao Morvath (contra 6; ruído). **Leitura importante: nas salas comuns o robô é limitado pelo ritmo das ondas e pelo caminhar, não pela vida dos inimigos** (quantidade de abates por segundo igual, 0,27); então mais dano sozinho encurta pouco as salas e pouco muda a morte. Em gente a sensação de "dano baixo" é provavelmente a de golpes que demoram para tirar um inimigo (Esqueleto 95 de vida contra 60 por combo: 2 combos) e de ter perdido os botões que sempre davam resposta. Pedir ao Daniel que diga se o incômodo é "demoro para matar" ou "morro antes de matar".
**Propostas numeradas (para o Daniel decidir; cada uma em `tools/make_data.gd`):**
1. **Valor dos botões fortes (P0, `gameplay-engineer` aplica)**: `smash` 75 para **100**, `sweep` 35 para **45**, `lance` 150 para **180** (função `_tree`, `_move` de cada um). Devolve ao laço de Magia a vantagem de uns +40% sobre o combo (calculado, 45 para 58). Efeito medido na variante A: Morvath -12% de tempo com o resto igual.
2. **Combo (P1)**: `cut1` e `cut2` 15 para **18**, `cut3` 30 para **36**, `EXTRA` (5º golpe) 15 para 18. Soma +20% em toda a partida, e todos os Dons de dano em porcentagem escalam. Preferir só se o Daniel sentir "demoro para matar" mesmo com a proposta 1.
3. **Magia (P1)**: `magick_per_hit` do combo 0,5 para **1,0** e `magick_on_finisher` 2 para 3, `gain_cap` 3,0 para 4,5 (hoje o laço do Esmagador fecha a cada 4 combos, uns 5 s). Com 1 e 3, a cada 2 combos. Sozinha ela não muda o dano por segundo da sala (o robô não gasta Magia), muda a frequência da resposta.
4. **Ritmo de Batalha (P2)**: `rhythm_time` 3,0 para **4,0** s e `rhythm_special_dmg` 0,5 para **0,75**: o golpe forte depois do finalizador passa a valer a pena em alvo único. Medir em partida com o robô forçado a usar Esmagador depois do finalizador.
5. **Vida dos inimigos das salas 1 a 5 (P1, `room-designer` confere)**: Esqueleto `hp` 95 para **75** (-21%), Arqueiro 180 para **140**, Runner 70 para **60**, Soldado de guarda (`guard`) e Mago proporcionais (-20%). O Esqueleto cai de 1,6 combo (60 de dano) para 1,25. Vai contra a regra antiga "proibido inflar a vida" só no sentido de baixar, e preserva elites e guardiões. Risco: as salas ficam mais curtas e dão menos Bênção por tempo; como o robô é limitado pelas ondas, o efeito medido deve ser pequeno.
6. **Dano sofrido (P1)**: se o objetivo é "difícil demais" e não "dano baixo", cortar o dano base dos comuns das salas 1 a 5 em **-20%** (Esqueleto `attack_damage` 5 para 4, Runner 8 para 6, Arqueiro e Mago 4 para 3) é mais barato que dar dano: o herói tem 40 de vida e hoje leva 0,14 por segundo contra 0,10 antes. Medir de novo o "morre nas salas 1 a 5" (hoje 1 de 12 no natural, sala 5).
7. **Não fazer agora**: mexer em Maestria ou Dons (a leitura é de M1 sem Dons; os Dons completos já dobram o ganho no R8.3) e nos números do Zerael. Ordem recomendada: 1, depois 6, e o Daniel testa; 2 e 5 só se ainda faltar.
**Como medir de novo:** 12 sementes, `smoke.sh 200` (dano por segundo, sala em 200 s, dano sofrido por segundo) e `--start=boss --hero-hp=500` (410 s sem Bênção hoje), natural 900 s; depois, o `runs.jsonl` do Daniel.

### 4. Outros itens
- **DT-3 feito**: `tools/boons_csv.gd` gera `docs/design/bencaos_v2/BALANCEAMENTO_V2.csv` (81 poderes) do dado, com os números em jogo (`~/tools/godot/godot --headless --path . -s tools/boons_csv.gd`). O CSV de V1 do Daniel fica como histórico.
- **QW-7 (Passos Leves)**: não medido. O robô o usa mal (V1: 402 s contra 309 s); precisa do Daniel em mão. Segue pendente.
