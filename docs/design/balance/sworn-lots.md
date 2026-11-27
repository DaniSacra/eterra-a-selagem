> Índice: [balance.md](../balance.md)

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

## PM-4 (2026-11-26 noite, room-designer): fontes por caminho

**Integração (Game Director):** PM-3 nas Fendas: as zonas da parede oeste (cedo e tardia) caíam no riacho e em chão fora de alcance (`test_arenas`, `test_room_gaps`); ficou só a do noroeste cedo e o `far_spawn` 0. Ficou `fountains_per_path = 3`, não 2: uma fonte antes do segundo guardião (cura possível 120% em vez de 80%), porque o teste das crianças já achou difícil. Medir de novo com o Guerreiro V1.
Antes: 4 fontes em todo caminho possível (salas 4, 6, 9 e 11; 300 mapas), cura 160% da vida. Depois: `fountains_per_path` 2 (salas 4 e 6), cura 80%,
sem fonte da sala 7 à 13. Robô 12 sementes: vida média ao entrar nas salas 7 a 13 de 40,0 para 27,1; Morvath alcançado 8 de 12 nas duas medidas.
Se for duro demais para o novato, o botão é `st.fountains_per_path = 3` em `make_data` (uma fonte antes do segundo guardião) e regerar `stage`.
