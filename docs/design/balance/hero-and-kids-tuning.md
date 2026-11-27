> Índice: [balance.md](../balance.md)

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
