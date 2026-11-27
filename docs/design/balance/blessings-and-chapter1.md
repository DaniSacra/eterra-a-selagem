> Índice: [balance.md](../balance.md)

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

## Capítulo 1 = SWORN Kingswood (2026-11-27, gameplay-engineer, pedido do Daniel)

> "Pega o dano e a vida dos inimigos exatamente como no SWORN, porque lá a progressão é boa; usa igual no capítulo 1 e depois a
> gente pensa no que mudar." E: "não gosto da barra amarela, tira; depois pode ter escudo nos fortes, como o energy shield do
> PoE, mas por ora só vida, ou fica difícil demais."

Fonte: `docs/design/sworn_rea_kingswood_2026-11-25.md` seções 1 e 4 (fatos dos arquivos do jogo). Números em `tools/make_data.gd`
(regerar `combos enemies bosses hero first`, nunca editar os `.tres`).

### Barra amarela removida
Nenhum inimigo tem `armor`, `ward_armor` nem `guard_up_armor`: elites, guardiões e Morvath só têm vida. O que a armadura segurava
passa para a Quebra (a barrinha clara): um elite não estremece mais com um golpe (`stun_time` 0 na versão elite, o Major do SWORN só
cambaleia pelo poise) e o Cavaleiro levanta a guarda sem olhar a armadura. O sacerdote deixou de blindar os outros (sem
`ward_count`: o "A3" do Ancião e o fio do sacerdote saem; o código de blindagem e a barra seguem no jogo, sem uso, para o escudo futuro).
O caminho de código (`Enemy.armor`, desenho da barra, `_step_ward`) ficou: removê-lo mexe em 20 arquivos e nos testes de efeitos; nenhum dado o aciona.
A dica "barra amarela" virou a dica da Quebra (`first_tip_poise`, `tip_poise`) e o termo "Armadura" do glossário virou "Quebra".

### Herói (papel: combo leve, pesado, esquiva)
| Item | Antes | Agora | SWORN |
|---|---|---|---|
| Vida | 40 | 50 | Vigilante 50 |
| Golpes 1 e 2 do combo | 15 e 15 | 20 e 20 | Combo 1 e 2: 20 |
| Golpe 3 (giro) | 30 | 40 | Combo 3 Slash: 40 |
| Corte Circular (pesado, toque) | 35 | 40 | Spin: 40 |
| Quarto e quinto golpe (Maestria Marcial) | 15 | 20 | (igual ao leve) |
| Esmagador 75, Lança da Emeth 150, Brado 150 | sem mudança | sem mudança | Magias do SWORN: 100; sem equivalente exato (ver abaixo) |
| Golpe na esquiva | não existe | não existe | Dash Attack 20 |
| Perigos de sala | 10 | 10 (sem mudança) | `baseHazardResist` 0,9 (INFERÊNCIA) |

### Inimigos (vida / dano de cada golpe)
| Inimigo nosso | Papel | Par no SWORN | Vida antes → agora | Dano antes → agora | Quebra (poise do SWORN) |
|---|---|---|---|---|---|
| `bone_rat` (rato de osso) | enxame rápido | Snake | 10 → 20 | 3 → 3 | sem barra |
| `skeleton_raised` (morto invocado) | fraco invocado | Snake | 40 → 20 | 4 → 3 | sem barra |
| `trinca` (3 figuras) | enxame | Snake | 45 → 20 cada | 4 → 3 | sem barra |
| `skeleton` | corpo a corpo comum | Hammer Mob | 95 → 250 | 5 → 10 | 125 |
| `varredor` | corpo a corpo parado | Hammer Mob (sem par exato) | 160 → 250 | 8 → 10 | sem barra |
| `runner` | investida e explosão | Boar | 70 → 200 | 8 → 7 | 100 |
| `guard` | escudo e investida | Boar | 255 → 200 | 8 → 7 | sem barra (como antes) |
| `archer` | atirador | Axe Thrower | 180 → 150 | 5 → 5 | 75 |
| `lancador` | atirador do machado | Axe Thrower | 150 → 150 | 8 → 7 | 75 |
| `canalizador` | raio parado (sem par exato) | Axe Thrower | 130 → 150 | 5 → 5 | 75 |
| `gritador`, `coveiro`, `armadilheiro` | apoio (sem par exato) | Axe Thrower (só a vida) | 120, 90, 110 → 150 | placa 8 → 7 | 75 |
| `mage` | morteiro | Mortoad | 115 → 175 | 6 → 7 | 100 |
| `priest` | vinha parada | Mortoad | 290 → 200 | 8 → 9 | sem barra |
| `saltador` | pulo com mira | Mortoad ("salta") | 140 → 175 | 8 → 9 | 100 |
| `skeleton_big`, `runner_big` | versão maior | Cavaleiro de Gawain (500) | 300, 225 → 500 | 7, 8 → 12, 10 | sem barra |
| `skeleton_elite`, `varredor_elite` | elite | Major Hammer | 60, 220 de armadura + vida → 1500 | 5 → 12 | 400 |
| `runner_elite`, `guard_elite` | elite | Major Boar | 45+85, 255+330 → 1350 | 8 → 9 | 300 |
| `archer_elite` | elite | Major Axe | 130+190 → 1250 | 4,8 → 7 | 300 |
| `mage_elite`, `priest_elite` | elite | Major Mortoad | 80+155, 290+390 → 1300 | 4,8 → 9 (mage: 3 morteiros, eram 7) | 300 |
| `trinca_elite` | elite (4 figuras) | sem Major de enxame: Snake | 45+60 → 20 cada | 4 → 3 | 300 |
| `capitao` | capitão | Major Hammer | 520 → 1500 | 8 → 12 | 400 |
| `knight` (Cavaleiro) | guardião do meio | Questing Beast | 650 + 550 de armadura → 3000 | 15 (investida), 8 (perto), 12 (escudo), 6 (anel), 8 (guarda) → 10, 10, 10, 7, 7 | 750 |
| `priest_elder` (Ancião) | guardião do meio | Bane of Crows | 420 + 900 → 2500 | 3 (leque), 9 → 5, 10 | 800 |
| `morvath` | chefe | Gawain | 8500 → 6000 | golpes 6 a 19 → 7 a 15 (foice 15, ceifa 12, lâminas 10, rajada 7, investida 15, erupções 15, ruptura 15) | 800 |

Quebra (poise do SWORN): o SWORN soma o dano do golpe no stagger e quebra ao passar do teto; a nossa barra gasta uma fração por
botão (ataque 0,15 do teto). Para dar o mesmo número de golpes leves de 20 por quebra, cada `sw_poise` vira `poise_mult = 133,3 / teto`
(Hammer 1,07; Boar e Mortoad 1,33; Axe 1,78; Major 0,33 a 0,44; Questing Beast 0,18; Bane e Gawain 0,17; `posture_mult` do Morvath 0,5 → 0,17).
Atordoamento ao quebrar: comum 2,0 s (era 1,2), elite 2,5 s, guardião e Morvath 3,5 s (já eram). x1,25 a cada quebra seguinte (já era).

### O que não mudou (para decidir)
- Poderes de dano fixo: escalados no passo seguinte (seção abaixo, "Dano fixo x2,5").
- Orçamento das salas, ondas e custos (`ENEMY_COST`): iguais. Um elite de 1500 de vida custa 6 a 12 e o Hammer comum 3, como no SWORN (Major 10, Hammer 3).
- Refinos da Forja "Peso" e "Onda Pesada" e o talento "Ruptura" (e o "Esquiva Implacável") agora gastam mais Quebra (seção abaixo).
- Perigos de sala: 10 de dano, como estava (o `baseHazardResist` 0,9 do SWORN é inferência, fica para depois).

### Dano fixo x2,5 (2026-11-27, segundo passo)
Inimigos com 2,5 a 3 vezes a vida: todo poder de dano próprio (que não é parte de um golpe) leva o mesmo fator, `FIXED_X` 2,5 em
`tools/make_data.gd`. Esmagador e Lança foram acertados pelo que matavam, não pelo fator puro. O combo, a vida do herói e os inimigos não mudaram.
| Poder | Antes | Agora | Conferência |
|---|---|---|---|
| Esmagador (smash) | 75 | 200 | ainda mata o Corredor (70 -> 200 de vida) de um golpe; os de 150 a 175 de vida também |
| Lança da Emeth | 150 | 375 | mata de uma vez tudo que é comum (até 250); o Esqueleto/Corredor Maior (500) pede 2, como antes (300 e 225 pediam 2) |
| Brado (`cast_burst`) | 150 | 375 | idem à Lança |
| Corte Circular e combo | 40, 20/20/40 | iguais | (do passo anterior) |
| Ultimate Corte Largo: miolo / fora | 180 / 120 | 450 / 300 | |
| Ultimate Voragem: tique / implosão | 5 / 72 | 12 / 180 | |
| Dons com `skill` (consagrar 12-26, fogo, geada, flagelo...) | números x `FLAT` 0,6 | x `FLAT` 1,5 | consagrar 12 -> 18 (efetivo 7 -> 18), brasas 18 -> 27, estilhaço 20 -> 30 |
| `burn_dps` dos Dons, Queimadura de `status_power` | x 0,6 | x 1,5 | |
| `dodge_ember_dps`, `detonate_dmg`, `shield_burst` (Bastião) | 6-8 / 14 / 40 | x2,5: 15-20 / 35 / 100 | |
| Bênçãos V1/V2 de dano próprio (`cel_burn_dps`, `cel_poison_dps`, `cel_combust_dmg`, `cel_sat_dmg`, `cel_shock_zap`, `cel_discharge`, `cel_whirl_dmg`, `dodge_plague_dps`) e as `skill` delas (`_vs`, campo `damage`) | spec | x 2,5 | ex.: Combustão 9 -> 22,5; Descarga 3 -> 7,5; Redemoinho 18 -> 45 |
| `CelRules.POISON_SKILL_DPS`, `SHOCK_SKILL_ZAP`, `DOT_DPS_CAP` | 1, 1, 16 | 2,5, 2,5, 40 | |
| Salmos: Sentinela, Rocha / Pastor | 30 / 55 | 75 / 140 | |
| Encantos: Lâmina Tríplice (onda) / Onda Gêmea / Corte Sísmico | 12 / 15 / 15 | 30 / 38 / 38 | |
| Forja (refinos e Temperar) | só `damage_pct` | sem mudança | já são proporções |
Fora desta rodada: a Maga (pausada, números próprios em `ArcaneKit`) e os perigos de sala (10).

### Peso, Onda Pesada, Ruptura: gastam mais Quebra
O stat `armor_pct` virou `poise_pct` (o mesmo nome em Forja e Dons, mesmos valores: Peso +20% no ataque, Onda Pesada +30% no especial, Ruptura
+50% nos finalizadores e no Esmagador, Esquiva Implacável +50% na esquiva). `Combat` põe `horde.poise_scale = 1 + poise_pct` ao redor do
golpe; `Horde._wear_poise` e a Postura de Morvath (`Boss._on_blow`) multiplicam a fração que o botão tira por ele. Textos reescritos em `text_pt.tres`.

### Medida depois do dano fixo (12 sementes, robô `--bot-reaction=0.25 --ultimate=cleave`)
| | Antes (so os inimigos SWORN) | Depois |
|---|---|---|
| Salas alcancadas (media) | 9,1 | 11,2 |
| Chegou em Morvath (900 s) | 3 de 12 | 4 de 12 (1 vitoria, com 7 de vida) |
| Chefe, vida que sobra (`--start=boss --boons=25`, 300 s) | 1012 a 5075 de 6000 | 978 a 3823; 1 vitoria |
| Duracao media da partida | 565 s | 537 s |

## SW-R1b: menos inimigos por sala, as quatro primeiras escritas à mão (2026-11-27, gameplay-engineer, pedido do Daniel)
Pedido: "muitos inimigos por sala; no SWORN são menos; as 4 primeiras salas com poucos, para aprender". Fonte: `sworn_rea_kingswood_2026-11-25.md` 3.1, 3.2 e 3.4.
- **Curva** (`StageDef.cost_curve`, orçamento de UMA onda a coeficiente 1,0; o custo por cabeça não mudou: Rato 1, comum 3, atirador 4, pesado 5,
  elite o dobro, Capitão 12): era a de SWORN x5 (20, 28, 30, 34, 34, 14, 18, 21, 27, 27, 20, 22), passou a SWORN x1,5 (nossas cabeças têm mais
  vida): `6, 9, 11, 12, 12, 9, 11, 13, 16, 16, 14, 16` (salas 1 a 12; 5 e 10 são guardiões). Vale de depois do guardião (9) e de novo depois do
  segundo (14); as salas 11 e 12 são as mais cheias, como "11 da sala 11 em diante". Sala de duas ondas 0,6 cada, horda 0,75 + 0,75, como antes.
- **Salas 1 a 4 escritas** (`StageDef.opening_waves`, `EncounterGen.opening`; sem dado, sem elite, sem modificador, sem maior; 4 em pé no máximo,
  `opening_cap`; a luta sobe uma cabeça por vez como as demais salas longas): 1 o esqueleto (1, depois 2); 2 o besteiro para esquivar (1, depois
  2 com um esqueleto); 3 os rápidos (2 corredores, depois 5 ratos de osso); 4 a mistura (2 esqueletos e 1 besteiro, depois o escudo e um esqueleto).
  Total de cabeças 3, 4, 7 e 5 (antes 8, 13, 14 e 13). Salas "especiais" com mais gente: as de 11 em diante (e a Provação, que é uma maldição sobre
  luta comum, sem luta própria); não há Onslaught no jogo. A primeira descida guiada (`first_descent.tres`) continua a dela.
- **Medida** (`RoomTally.alive`: `rooms[].peak`, `alive_s`, `fight_s`; média viva = alive_s / fight_s). `smoke.sh 900 --seed=1..12 --bot-reaction=0.25
  --ultimate=cleave`, mesmo HEAD, só mudam curva e salas escritas:

| Sala | Cabeças antes | Cabeças depois | Pico antes | Pico depois | Média viva antes | Média viva depois |
|---|---|---|---|---|---|---|
| 1 | 7,9 | 3,0 | 3,0 | 3,0 | 2,43 | 2,22 |
| 2 | 12,6 | 4,0 | 5,5 | 4,0 | 3,87 | 2,61 |
| 3 | 13,7 | 7,2 | 5,0 | 3,6 | 3,73 | 1,93 |
| 4 | 13,3 | 5,0 | 5,7 | 3,0 | 3,81 | 2,21 |
| 6 | 6,7 | 5,2 | 4,3 | 4,7 | 2,69 | 2,53 |
| 7 | 7,7 | 6,8 | 6,0 | 5,9 | 3,00 | 2,97 |
| 8 | 10,1 | 6,9 | 6,0 | 5,4 | 3,44 | 3,07 |
| 9 | 12,6 | 8,6 | 6,2 | 6,1 | 4,24 | 3,43 |
| 11 | 9,0 | 6,1 | 6,0 | 5,3 | 3,56 | 3,20 |
| 12 | 8,8 | 7,7 | 6,2 | 6,6 | 3,27 | 4,02 |

  (amostras pequenas nas salas fundas: o robô morre antes; as salas 6 a 12 são mais próximas porque o sorteio já era enxuto ali.) Partida do robô,
  12 sementes: antes chegou a Morvath em 6 e venceu 2, mortes por sala {5: 3, 7: 1, 9: 1, 10: 1, 14: 4}; depois chegou em 5, venceu 0, mortes
  {8: 1, 10: 4, 12: 2, 14: 5}, sala final média 10,4 para 11,8. Nada de trivial: a dificuldade se desloca do começo (nenhuma morte nas salas 1 a 4,
  nem no primeiro guardião) para o segundo guardião e Morvath; as vitórias (0 de 12) caem dentro do ruído do robô, a olhar com mais sementes.
