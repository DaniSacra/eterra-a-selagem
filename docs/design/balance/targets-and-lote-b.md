> Índice: [balance.md](../balance.md)

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
