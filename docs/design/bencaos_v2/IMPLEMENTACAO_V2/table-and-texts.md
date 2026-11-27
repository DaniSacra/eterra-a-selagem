> Índice: [IMPLEMENTACAO_V2.md](../IMPLEMENTACAO_V2.md)

## 3. Tabela dos 81

Notação: `n1` é o valor do nível 1 comum; `+g` é o ganho por nível 2 e 3 (a V1 usa `[g, g]`); **R** marca o que a raridade multiplica (x1 / x1,5 / x2 / x2,5 sobre `n1`; ganhos de nível nunca escalam; durações, contagens, raios, chances, recargas e acúmulos ficam fixos). `cel_*` é o stat do mod. Slot: A Ataque, S Especial, P Poder, E Esquiva, U Supremo, C complementar (`NONE`). "Pede" é `needs_all`; "Dá" é `grants`. Quando o número é igual ao da V1 escrevo "V1".

### Sarael (Chama), `F.CHAMA`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_brasa` | MANTÉM | Queimadura `cel_burn_dps` 3,5 +1,5 **R**, 3 s; Esmagador x1,5 | dá burn |
| S | `pesado_brasa` | MUDA | Queimadura 5 +2,5 **R** (V1) e `cel_antic` 0,5 (fixo): antecipa 50% da Queimadura que faltava no alvo, antes de reaplicar | dá burn |
| P | `circulo_brasa` | MANTÉM | zona de fogo 2,5 m, 3 s, 6/9/12 por s, Queimadura 3 | dá burn |
| E | `passo_brasa` | MANTÉM | rastro `dodge_ember_dps` 6 +3 **R**, 2 s | dá burn |
| U | `chuva_brasas` | MANTÉM | 8 brasas 20/30/42, 2,2 m, Queimadura 4 | dá burn |
| C | `combustao` | MUDA | explosão `cel_combust_dmg` 9 +4,5 **R** no alvo (3 aplicações, recarga 3 s), agora 50% em até 4 vizinhos a 2,0 m; `cel_antic_all` 0,2 antecipa 20% de todos os DoTs do alvo central | pede burn |
| C | `chama_contagiosa` | MANTÉM | ao morrer queimando, 50% do dps salta (3 m, 2 s), uma vez | pede burn |
| C | `brasa_persistente` | MANTÉM | `cel_burn_time_pct` 0,3 +0,1 (a duração nunca soma: renova até o teto) | pede burn |
| C | `fogo_crescente` | MUDA | `cel_burn_dps_pct` 0,2 +0,1 **R** e `cel_burn_div` 0,05 por outra condição no alvo (máx 3, foto na aplicação) | pede burn |

### Nivael (Geada), `F.GEADA`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_geada` | MANTÉM | `cel_cold` 1 (Esmagador x2) | dá cold |
| S | `toque_geada` | MANTÉM | `cel_cold` 2 | dá cold |
| P | `circulo_geada` | MANTÉM | gelo 3 m, 2 de Frio | dá cold |
| E | `floco_errante` | MANTÉM | 2 flocos, 3 s, 1 de Frio por alvo por s | dá cold |
| U | `peso_inverno` | MUDA | meteoro 55/80/115, 4 m, 3 de Frio (V1) e `cel_slot_shatter` 0,25: o próprio golpe estilhaça um congelado (+25%, uma vez por congelamento) sem exigir Estilhaçamento | dá cold |
| C | `estilhaco` | MUDA | `cel_shatter_pct` 0,4 +0,15 **R** (V1) e `cel_shatter_frag` 0,3: o estilhaço solta fragmentos de 30% do dano do golpe em até 3 inimigos a 2,0 m (`direct->shatter->frag`) | pede cold |
| C | `inverno_prolongado` | MUDA | `cel_cold_time_pct` 0,25 e `cel_cold_keep` 1,0: ao congelar, Queimadura, Veneno e Sangramento do alvo ganham +1,0 s, uma vez por congelamento (a imunidade de 2 s impede o ciclo) | pede cold |
| C | `geada_profunda` | MUDA | `cel_slow_add` 0,05 (teto 40%) e `cel_cold_impact` 1: Impacto aplicado em alvo com Frio vale +1 ponto | pede cold |
| C | `cristais_errantes` | MUDA | `cel_crystal` 1 acúmulo (V1) e `cel_crystal_dot` 0,3: copia 30% dos DoTs do estilhaçado aos vizinhos de 2,5 m (recarga 3 s, `copy`) | pede estilhaco |

### Lumael (Luz), `F.LUZ`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_radiante` | MANTÉM | `cel_crit` 0,10 +0,03 | dá crit |
| S | `pesado_radiante` | MANTÉM | `cel_crit` 0,10 +0,03 e `cel_crit_mult` 0,25 | dá crit |
| P | `circulo_radiante` | MANTÉM | `cel_crit` 0,15 +0,03 | dá crit |
| E | `clarao` | MANTÉM | o próximo golpe (3 s) ganha `cel_crit` 0,15 +0,03 | dá crit |
| U | `ultimo_radiante` | MANTÉM | 3 raios 24/36/50, 1,5 m, chance 15% | dá crit |
| C | `luz_crescente` | MANTÉM | `cel_crit_stack` 0,05 (até 3 acúmulos, 4 s) | pede crit |
| C | `prosperidade` | MANTÉM | `gold_pct` 0,10 | pede fam:luz |
| C | `fortuna_celestial` | MANTÉM (número) | `cel_crit_global` 0,05 **+0,03 por nível** (hoje fixo; sem isto Peste+Luz fica em 5% de crítico) | pede crit |
| C | `esplendor` | MUDA | `cel_crit_mult_global` 0,2 e `cel_crit_apply` 0,5: golpe crítico intensifica as aplicações dele (2.9) | pede crit |

### Shomael (Vigília), `F.VIGILIA`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_firme` | MANTÉM | `cel_impact` 1 (Esmagador x2) | dá impact |
| S | `pesado_firme` | MUDA | `cel_impact` 2 (V1) e `cel_slot_shatter` 0,25 (estilhaça congelado) | dá impact |
| P | `circulo_firme` | MANTÉM | onda 3 m, 14/21/30, 2 de Impacto | dá impact |
| E | `passo_firme` | MANTÉM | escudo `cel_guard_time` 1,2 s, recarga 8 s | |
| U | `ultimo_firme` | MANTÉM | onda 6 m, 45/66/96, 3 de Impacto (no chefe enche o medidor) | dá impact |
| C | `ruptura` | MUDA | `cel_impact_need` -1 (V1) e `cel_stun_antic` 0,25: ao atordoar um comum, antecipa 25% dos DoTs dele (`rupture->antic`) | pede impact |
| C | `forca_inabalavel` | MUDA | `cel_stunned_dmg_pct` 0,3 +0,12 **R** (também na Abertura) e `cel_stun_pulse` 1: ao atordoar, 1 ponto de Impacto em até 3 vizinhos a 2,0 m (recarga 2 s) | pede impact |
| C | `peso_vigilia` | MANTÉM | `cel_impact_time_pct` 0,3 | pede impact |
| C | `amparo` | MUDA | `cel_guard_time_pct` 0,25 e `cel_guard_impact` 2: o escudo gasto num golpe dá +2 pontos ao próximo Impacto em 4 s (sem aparo nativo) | pede passo_firme |

### Velael (Véu), `F.VEU`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_veu` | MANTÉM | Fraqueza `cel_weak` 2 s +1 | dá weak |
| S | `pesado_veu` | MANTÉM | `cel_weak` 3 s +1 | dá weak |
| P | `circulo_veu` | MANTÉM | 3 m, 4/5,5/7 s | dá weak |
| E | `fios_cinza` | MANTÉM | 2 m, 2/3/4 s, recarga 3 s | dá weak |
| U | `crepusculo` | MUDA | 7 m, 5/6,5/8 s (V1); novo status `weak_extend`: todas as condições do alvo (Queimadura, Veneno, Sangramento, Frio, Marca) ganham +2 s, teto de 8 s restantes, uma vez por conjuração | dá weak |
| C | `vulnerabilidade` | MUDA | `cel_weak_dmg_pct` 0,15 +0,07 **R** e `cel_weak_div` 0,03 por condição distinta (máx 3) | pede weak |
| C | `essencia_restauradora` | MUDA | `cel_weak_mana` 1 e `cel_weak_mana_div` 1: com 3 ou mais condições distintas devolve 2 (recarga 2 s) | pede weak |
| C | `veu_persistente` | MUDA | `cel_weak_time_pct` 0,25 e `cel_weak_extend` 1,0: renovar a Fraqueza prolonga +1 s as outras condições (teto 6 s restantes, uma vez por 3 s por alvo) | pede weak |
| C | `entardecer` | MANTÉM | Névoa Profunda, `weak_pct` 0,08 global (teto 40%) | pede weak |

### Galael (Vento), `F.MARE`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_mare` | MANTÉM | `cel_speed` 0,12 +0,04 | dá wind |
| S | `pesado_mare` | MUDA | rajada 14/21/30 (V1) e status `spread` 0,3: cada alvo atingido copia 30% dos DoTs a 1 vizinho a 3 m (teto 4 cópias por rajada) | dá wind |
| P | `circulo_mare` | MUDA | `cel_speed` 0,12 +0,04 no slot `CAST`: o Corte Circular fica mais rápido (preparo e recuperação); não há recarga para cortar | dá wind |
| E | `passos_leves` | MANTÉM | `dodge_charges` +1 (provisório até o playtest) | dá wind |
| U | `vendaval` | MANTÉM | +30% velocidade, +10% movimento, 5 s | dá wind |
| C | `cadencia` | MANTÉM | `cel_cadence` 0,03 por acúmulo, 5 acúmulos, 3 s | pede fam:mare |
| C | `turbilhao` | MUDA | `cel_whirl_dmg` 18 +9 **R** (3 m, recarga 5 s) e `cel_whirl_spread` 0,25: copia 25% dos DoTs (até 2 cópias por Turbilhão) | pede cadencia |
| C | `brisa_favoravel` | MANTÉM | `move_speed_pct` 0,05 | pede fam:mare |
| C | `fluxo_continuo` | MUDA | `cel_cadence_time_pct` 0,3 e `cel_cadence_mix` 1: a ação de **outro botão** que a anterior dá +1 acúmulo a mais (máx 5) | pede cadencia |

### Qeshael (Penumbra), `F.MARCA`

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_marca` | MANTÉM | Marca `cel_mark` 3 s +1 | dá mark |
| S | `pesado_marca` | MUDA | eco `cel_echo` 0,4 (V1, só em marcado) e `cel_bleed` 0,4 **R**: o golpe em alvo marcado sangra 40% do próprio dano em 4 s | dá echo; pede mark |
| P | `circulo_marca` | MANTÉM | eco 35%, recarga 3 s por ação | dá echo |
| E | `olhar_rapido` | MANTÉM | marca 3 s +1 em 3 m | dá mark |
| U | `exercito_ecos` | MUDA | ecos 40% por 5 s (V1) e `cel_bleed` 0,2 **R** no slot `ULT`: na janela, golpe direto em marcado sangra 20% | dá echo |
| C | `eco_crescente` | MUDA | `cel_echo_pct` 0,3 +0,15 **R** e `cel_bleed_pct` 0,3 (multiplica a fatia de sangramento, teto 0,8) | pede echo |
| C | `marca_persistente` | MUDA | `cel_mark_time_pct` 0,3 e `cel_mark_pass` 1: ao morrer marcado, a Marca passa (uma vez, tempo restante) ao mais próximo sem Marca a 4 m | pede mark |
| C | `sombra_revelada` | MUDA | `cel_echo_marked_pct` 0,2 +0,08 **R** e `cel_bleed_crit` 0,25: golpe crítico em marcado sem sangramento aplica Sangramento de 25% | pede mark e echo |
| C | `ressonancia` | MANTÉM | `cel_echo_cd_cut` 0,1 (teto 50%) | pede echo |


### Zerael (Peste), `F.PESTE`, angel id `zerael`

Acúmulos máx 5, tique 0,5 s, relógio único de 5 s (teto 8 s). Mods em ordem: o primeiro é o `{a}` da carta, o segundo o `{b}`.

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_peste` | NOVO | `cel_poison_dps` 0,8 +0,3 **R** (por acúmulo), `cel_poison` 1 acúmulo (Esmagador x2) | dá poison |
| S | `pesado_peste` | NOVO | `cel_poison_dps` 1,2 +0,4 **R**, `cel_poison` 3 acúmulos | dá poison |
| P | `circulo_peste` | NOVO | zona `PLAGUE` 2,5 m, 4 s: 1 acúmulo por inimigo a cada 1,0 s (dps `POISON_SKILL_DPS` 1,0), sem dano de contato (`damage` [0]); `CONSECRATE`, `status = poison`, `status_power` [1], `status_gap` 1,0, `gap` [3,0] | dá poison |
| E | `passo_peste` | NOVO | rastro `dodge_plague_dps` 1,0 +0,5 **R** (por acúmulo), 2 s, 1 acúmulo por s por alvo | dá poison |
| U | `epidemia_celestial` | NOVO | `NOVA` 7 m, dano [24, 36, 52], `status = poison`, `status_power` [3] (3 acúmulos, dps 1,0) | dá poison |
| C | `saturacao` | NOVO | `cel_sat_dmg` 12 +6 **R**: em 5 acúmulos explode em 2,0 m (50% em até 4 vizinhos), consome 2 acúmulos, recarga 4 s por alvo | pede poison |
| C | `peste_persistente` | NOVO | `cel_poison_time_pct` 0,3 +0,1 e `cel_poison_cold` 1 (com Frio no alvo o relógio cai pela metade) | pede poison |
| C | `deterioracao` | NOVO | `cel_poison_grow` 0,06 +0,03 por s, teto +30%; em dobro com Queimadura ou Sangramento no alvo | pede poison |
| C | `contagio` | NOVO | `cel_poison_spread` 0,5 +0,1: ao morrer envenenado, copia essa fração dos acúmulos (mín 1) e metade do tempo a 2 inimigos a 3 m, uma vez | pede poison |

### Saarael (Trovão) (`F.TROVAO`, angel id `thunder`)

Cargas máx 5, janela 6 s, Descarga em 5 cargas, recarga 4 s por alvo, nunca atordoa.

| Slot | id | V1 para V2 | Efeito V2 e números | Pede / Dá |
|---|---|---|---|---|
| A | `golpe_trovao` | NOVO | `cel_shock` 1 carga (Esmagador x2), `cel_shock_zap` 1 +0,5 **R** de faísca por carga | dá shock |
| S | `pesado_trovao` | NOVO | `cel_shock` 3 cargas, `cel_shock_zap` 1,5 +0,5 **R**, `cel_force_discharge` 1: com Descarga na mão, a Lança descarrega o alvo que já tenha 3 ou mais cargas | dá shock |
| P | `circulo_trovao` | NOVO | `NOVA` 3 m, dano [6, 9, 12], `status = shock`, `status_power` [2] | dá shock |
| E | `passo_trovao` | NOVO | `NOVA` na esquiva, 2 m, dano [0], `status = shock`, `status_power` [1], `gap` [2,0] | dá shock |
| U | `tempestade_celestial` | NOVO | `STRIKES` 6 raios, dano [24, 36, 50], 1,5 m, `status = shock`, `status_power` [2] | dá shock |
| C | `descarga` | NOVO | `cel_discharge` 3 +1,5 **R** por carga, ao chegar em 5 cargas (15 de dano no nível 1 comum); recarga 4 s por alvo | pede shock |
| C | `conducao` | NOVO | `cel_conduct` 2 +1 alvos a 3,5 m com 50% do dano, sem cargas | pede descarga |
| C | `sobrecarga` | NOVO | `cel_overload` 0,5 +0,2 cargas por segundo em alvo carregado e com Queimadura, Veneno ou Sangramento | pede shock |
| C | `ressonancia_eletrica` | NOVO | `cel_reson` 0,10 +0,03 de Descarga a mais por outro inimigo carregado a 3 m (máx 4) | pede descarga |

### Raridade dos novos, explícita (nível 1)

| Poder | Comum | Raro | Épico | Lendário |
|---|---|---|---|---|
| `golpe_peste`, Veneno por acúmulo | 0,8 | 1,2 | 1,6 | 2,0 |
| `pesado_peste` | 1,2 | 1,8 | 2,4 | 3,0 |
| `passo_peste` | 1,0 | 1,5 | 2,0 | 2,5 |
| `saturacao` explosão | 12 | 18 | 24 | 30 |
| `golpe_trovao` faísca por carga | 1 | 1,5 | 2 | 2,5 |
| `pesado_trovao` | 1,5 | 2,3 | 3 | 3,8 |
| `descarga` por carga | 3 | 4,5 | 6 | 7,5 |
| `pesado_marca` fatia de Sangramento | 40% | 60% | 80% (teto) | 80% (teto) |
| `exercito_ecos` fatia | 20% | 30% | 40% | 50% (teto 80% somado) |

Epic e Lendário do Veneno em 5 acúmulos dão 8 e 10 por segundo: é o motivo do `DOT_DPS_CAP` de 16 somando os três DoTs.

## 4. Cor e família visual (Peste e Trovão)

Paletas já enviadas no pedido de arte dos anjos (definidas pelo coordenador; usar estas): **Peste (Zerael)** enxofre `#C9B458`, líquen `#9FAE7A`, carvão `#2E2B26`; **Trovão** (`thunder`, nome em aberto) ardósia `#4E5866`, cinza-tempestade `#7D8590`, amarelo-relâmpago `#F1E08A`. Nenhuma é violeta nem esmeralda vivo; nenhuma cai perto do vermelho do perigo, da Emeth, do verde espectral ou dos violetas de Morvath.

Uso proposto (regras de `art_direction.md` 2.1 e 2.1.1: distância RGB mínima 0,25 das reservadas, Bênção usa a cor da família, chão âmbar é do perigo):

| Família | `Boon.FAMILY_COLOR` | Selo do anjo | Papel das cores |
|---|---|---|---|
| Peste | enxofre `#C9B458` | líquen `#9FAE7A` | enxofre = cor da carta, do pip e do brilho das bolhas; líquen = o corpo das bolhas e da zona `PLAGUE`; carvão = contorno e sombra das gotas. Zona e rastro são bolhas, **nunca aro nem divisa** (aro é âmbar do perigo). Pip: gota, com pontinhos pelo número de acúmulos |
| Trovão | cinza-tempestade `#7D8590` | ardósia `#4E5866` | cinza-tempestade = carta e arco em repouso; ardósia = fundo da carta e do selo; **amarelo-relâmpago só no clarão de 2 a 3 quadros** do zigue-zague, nunca cor de carta nem de zona. Nunca círculo no chão. Pip: faísca em ponta |

Distâncias de RGB medidas (script, 0 a 1): enxofre a Marca 0,13, ao Duo/Elo (0,78/0,62/0,34) 0,09, à Vigília 0,19, ao âmbar do perigo 0,25 (no limite); líquen a Vigília 0,11, a Marca 0,20, ao Duo 0,22, ao Véu 0,21; carvão sem conflito; ardósia ao petróleo do herói 0,29; cinza-tempestade ao petróleo 0,25 (no limite); amarelo-relâmpago a Lumael 0,17, ao Véu 0,28, ao VOLT da Maga 0,26.

**Conflitos a decidir pelo `art-director` (o teste `test_element_look` exige 0,25 e vai falhar para estes pares se for estendido às famílias):** (1) enxofre e líquen ficam amarelo-esverdeados e muito próximos de Marca, Vigília e do Elo; separam por **forma** (gota e bolha contra escudo e eco), por **valor** (carvão no contorno) e por quase nunca aparecerem juntos; se o art-director não aceitar, escurecer o enxofre ou afastar o matiz para o verde-azulado, sem chegar ao esmeralda. (2) O amarelo-relâmpago fica a 0,17 de Lumael: por isso só vale no clarão curto, e a carta do Trovão é cinza. A decisão fica registrada como exceção, como a de Emeth e verde espectral.

Sangramento (efeito do Qeshael, cor da Marca): gota inclinada **ferrugem escura** `Color(0.62, 0.30, 0.20)` (distância ao vermelho do perigo 0,41), nunca o vermelho do perigo. Medidor do chefe: pontinhos na cor da família (Frio ciano da Geada, Impacto pedra de Vigília).

Arte pendente: selo e glifo dos dois anjos (índices de símbolo 7 e 8 em `_angel(...)`), 18 ícones (glifo desenhado de `BoonIcon` provisório, como na V1), pintura dos medalhões, VFX de bolhas, zigue-zague e gota. Nada disso gasta Meshy; fica para o `art-director` e o `technical-artist`.

## 5. Textos para `data/text_pt.tres` (português do Brasil, sem travessão)

**Marcados para o Daniel (frase e nome do anjo novo, neutros, provisórios):** `angel_zerael_line`, `angel_thunder`, `angel_thunder_line`. Os nomes "Zerael" e "Saarael" (de sa'ar, tempestade; Daniel 2026-11-26) estão aceitos; o id técnico continua `thunder`. Nada de lore novo.

```
"angel_zerael": "Zerael",
"angel_zerael_line": "Paciente e quieto, espera o tempo trabalhar.",
"angel_thunder": "Saarael",
"angel_thunder_line": "Veloz e direto, chega antes do aviso.",
"family_peste": "Peste",
"family_trovao": "Trovão",
"need_cap_poison": "Veneno",
"need_cap_shock": "Eletrificação",
```

Boas práticas das cartas: `{key}` é o botão (a legenda do Poder e do Especial é do GP-1); `{a}` e `{b}` são o primeiro e o segundo mod; os outros números vêm de `CelRules.text_args()` (novos nomes ao fim da seção).

Novos (18):

```
"boon_golpe_peste": "Golpe Pestilento",
"boon_golpe_peste_desc": "O ataque{key} aplica um acúmulo de Veneno: {a} de dano por segundo por acúmulo, por {poison_time} s, até {poison_max} acúmulos. O Golpe Esmagador aplica o dobro.",
"boon_pesado_peste": "Peso da Peste",
"boon_pesado_peste_desc": "O Especial{key} aplica {b} acúmulos de Veneno: {a} de dano por segundo por acúmulo, por {poison_time} s.",
"boon_circulo_peste": "Poder da Peste",
"boon_circulo_peste_desc": "O Poder{key} contamina o chão em {radius} m por {duration} s: cada inimigo recebe um acúmulo de Veneno por segundo.",
"boon_passo_peste": "Passo Pestilento",
"boon_passo_peste_desc": "A esquiva{key} deixa um rastro que aplica um acúmulo de Veneno por segundo ({a} de dano por segundo por acúmulo), por {trail_t} s.",
"boon_epidemia_celestial": "Epidemia Celestial",
"boon_epidemia_celestial_desc": "O Golpe Supremo{key} atinge {radius} m: {dmg} de dano e {status} acúmulos de Veneno.",
"boon_saturacao": "Saturação",
"boon_saturacao_desc": "Com {poison_max} acúmulos de Veneno, o inimigo explode em {sat_r} m: {a} de dano, e perde {sat_cost} acúmulos. Recarga de {sat_cd} s por inimigo.",
"boon_peste_persistente": "Peste Persistente",
"boon_peste_persistente_desc": "O Veneno dura {a} mais (até {poison_cap} s). Com Frio no inimigo, ele passa mais devagar.",
"boon_deterioracao": "Deterioração",
"boon_deterioracao_desc": "O Veneno causa {a} mais de dano a cada segundo, até {grow_max}. Cresce em dobro se o inimigo também queima ou sangra.",
"boon_contagio": "Contágio",
"boon_contagio_desc": "Ao derrotar um inimigo envenenado, {a} dos acúmulos saltam para até {copy_n} inimigos a {copy_r} m.",
"boon_golpe_trovao": "Golpe Voltaico",
"boon_golpe_trovao_desc": "O ataque{key} aplica uma carga elétrica e uma faísca de {a} de dano por carga. Até {shock_max} cargas, por {shock_win} s. O Golpe Esmagador aplica o dobro.",
"boon_pesado_trovao": "Peso do Trovão",
"boon_pesado_trovao_desc": "O Especial{key} aplica {b} cargas elétricas e faíscas de {a} por carga. Com Descarga, esvazia o inimigo que já tenha {force_need} cargas ou mais.",
"boon_circulo_trovao": "Poder da Tormenta",
"boon_circulo_trovao_desc": "O Poder{key} faz estalar uma área de {radius} m: {dmg} de dano e {status} cargas elétricas.",
"boon_passo_trovao": "Passo Voltaico",
"boon_passo_trovao_desc": "A esquiva{key} solta faíscas em {radius} m: uma carga elétrica por inimigo. Recarga de {gap} s.",
"boon_tempestade_celestial": "Tempestade Celestial",
"boon_tempestade_celestial_desc": "O Golpe Supremo{key} faz cair {count} raios de {dmg} de dano, cada um com {status} cargas elétricas.",
"boon_descarga": "Descarga",
"boon_descarga_desc": "Com {shock_max} cargas, o inimigo descarrega: {a} de dano por carga. Recarga de {discharge_cd} s por inimigo.",
"boon_conducao": "Condução",
"boon_conducao_desc": "A Descarga salta para {a} inimigos a {conduct_r} m, com {conduct_pct} do dano e sem cargas.",
"boon_sobrecarga": "Sobrecarga",
"boon_sobrecarga_desc": "Inimigo carregado que também queima, sangra ou está envenenado ganha {a} carga por segundo.",
"boon_ressonancia_eletrica": "Ressonância Elétrica",
"boon_ressonancia_eletrica_desc": "A Descarga causa {a} a mais de dano por outro inimigo carregado a {reson_r} m (até {reson_n}).",
```

Mudam a descrição (26 ids; os 11 do Poder e do Especial usam as legendas novas do GP-1; só listo o que muda de sentido):

```
"boon_pesado_brasa_desc": "O Especial{key} aplica Queimadura intensa: {a} de dano por segundo, por {burn_time} s. Se o inimigo já queimava, adianta {antic} do dano que faltava (a Queimadura encurta na mesma medida).",
"boon_combustao_desc": "Após {combust_apps} aplicações seguidas de Queimadura no mesmo inimigo, o fogo explode em {combust_r} m: {a} de dano nele e metade nos vizinhos, e adianta {antic_all} do dano que falta dos efeitos dele. Recarga de {combust_cd} s por inimigo.",
"boon_fogo_crescente_desc": "A Queimadura causa {a} mais de dano por segundo, e {burn_div} a mais por outra condição no inimigo (até {div_cap}).",
"boon_peso_inverno_desc": "O Golpe Supremo{key} faz cair gelo em {radius} m: {dmg} de dano e {status} acúmulos de Frio. Estilhaça inimigos congelados sem precisar do Estilhaçamento.",
"boon_estilhaco_desc": "O primeiro golpe direto num inimigo congelado causa {a} a mais de dano, uma vez por congelamento, e solta fragmentos de {frag} do dano em até {frag_n} inimigos a {frag_r} m.",
"boon_inverno_prolongado_desc": "O Frio e o congelamento duram {a} mais. Ao congelar, Queimadura, Veneno e Sangramento do inimigo duram {keep} s a mais.",
"boon_geada_profunda_desc": "Cada acúmulo de Frio atrasa {a} mais (a lentidão para em {slow_max}). Inimigo com Frio recebe um ponto de Impacto a mais.",
"boon_cristais_errantes_desc": "O Estilhaçamento espalha {a} acúmulo de Frio a quem está a {crystal_r} m e {crystal_dot} dos efeitos de dano ao longo do tempo do inimigo estilhaçado. Recarga de {crystal_cd} s.",
"boon_esplendor_desc": "O dano crítico de todas as ações cresce {a}. Um golpe crítico aplica seus efeitos com mais força (Queimadura, Veneno e Sangramento {crit_apply} a mais, e um acúmulo ou carga extra).",
"boon_pesado_firme_desc": "O Especial{key} acumula {a} pontos de Impacto. {impact_need} pontos em {impact_win} s atordoam um inimigo comum por {stun} s. Estilhaça inimigos congelados.",
"boon_ruptura_desc": "Inimigos comuns ficam atordoados com {impact_need_less} pontos de Impacto, em vez de {impact_need}. Ao atordoar, adianta {a} do dano que falta dos efeitos do inimigo.",
"boon_forca_inabalavel_desc": "Inimigos atordoados e chefes na Abertura recebem {a} a mais de dano. Ao atordoar, um ponto de Impacto salta para até {pulse_n} vizinhos a {pulse_r} m.",
"boon_amparo_desc": "A proteção do Passo Firme dura {a} mais. Se ela absorver um golpe, o próximo Impacto em {guard_win} s vale {b} pontos a mais.",
"boon_crepusculo_desc": "O Golpe Supremo{key} enfraquece por {status} s os inimigos a {radius} m e prolonga em {extend} s os outros efeitos neles (até {extend_cap} s).",
"boon_vulnerabilidade_desc": "Inimigos enfraquecidos recebem {a} a mais de dano, e {weak_div} a mais por outro efeito neles (até {div_cap}).",
"boon_essencia_restauradora_desc": "Derrotar um inimigo enfraquecido devolve {a} de Magia, ou {b} a mais se ele tinha {div_full} efeitos ou mais. Recarga de {mana_cd} s.",
"boon_veu_persistente_desc": "A Fraqueza dura {a} mais. Renovar a Fraqueza prolonga em {extend_weak} s os outros efeitos do inimigo.",
"boon_pesado_mare_desc": "O Especial{key} solta uma rajada extra na mesma direção: {dmg} de dano. Cada inimigo atingido passa {status} dos efeitos de dano que tem a um vizinho. Recarga de {gap} s.",
"boon_circulo_mare_desc": "O Poder{key} fica {a} mais rápido.",
"boon_turbilhao_desc": "Na Cadência máxima, um vento explode em {whirl_r} m: {a} de dano, e espalha {whirl_spread} dos efeitos de dano dos atingidos. Recarga de {whirl_cd} s.",
"boon_fluxo_continuo_desc": "A Cadência dura {a} mais. Uma ação de outro botão dá {b} acúmulo a mais.",
"boon_pesado_marca_desc": "O Especial{key} contra um alvo marcado cria um eco de {a} do dano direto e o faz sangrar {b} desse dano em {bleed_time} s. Recarga de {echo_cd} s por inimigo.",
"boon_exercito_ecos_desc": "Após o Golpe Supremo{key}, por {b} s, as ações diretas criam ecos de {a} do dano e fazem o alvo marcado sangrar {c} do golpe. Recarga de {echo_cd} s por inimigo.",
"boon_eco_crescente_desc": "Os ecos causam {a} mais de dano, e o Sangramento {bleed_more} a mais.",
"boon_marca_persistente_desc": "A Marca dura {a} mais. Ao derrotar um marcado, a Marca passa ao inimigo mais próximo, a {mark_r} m, uma vez.",
"boon_sombra_revelada_desc": "Os ecos causam {a} mais de dano em inimigos marcados. Um golpe crítico num marcado o faz sangrar {bleed_crit} do golpe.",
```

`{c}` (terceiro mod) só existe se `BoonChoice.describe` o formatar; se não, o `gameplay-engineer` troca por `{bleed_ult}` em `text_args`. Fatos de carta (`fact_<stat>`), um por stat novo:

```
"fact_cel_poison": "Acúmulos de Veneno", "fact_cel_poison_dps": "Veneno por acúmulo", "fact_cel_poison_time_pct": "Duração a mais",
"fact_cel_poison_cold": "Veneno sob Frio", "fact_cel_poison_grow": "Crescimento por segundo", "fact_cel_poison_spread": "Veneno que salta",
"fact_cel_sat_dmg": "Explosão", "fact_dodge_plague_dps": "Veneno do rastro",
"fact_cel_shock": "Cargas", "fact_cel_shock_zap": "Faísca por carga", "fact_cel_force_discharge": "Esvazia com cargas",
"fact_cel_discharge": "Descarga por carga", "fact_cel_conduct": "Saltos", "fact_cel_overload": "Cargas por segundo", "fact_cel_reson": "Descarga por vizinho",
"fact_cel_bleed": "Sangramento", "fact_cel_bleed_pct": "Sangramento a mais", "fact_cel_bleed_crit": "Sangramento no crítico",
"fact_cel_antic": "Dano adiantado", "fact_cel_antic_all": "Dano adiantado", "fact_cel_stun_antic": "Dano adiantado",
"fact_cel_burn_div": "Queimadura por efeito", "fact_cel_slot_shatter": "Estilhaço do golpe", "fact_cel_shatter_frag": "Fragmentos",
"fact_cel_crystal_dot": "Efeitos espalhados", "fact_cel_cold_keep": "Efeitos preservados", "fact_cel_cold_impact": "Impacto extra com Frio",
"fact_cel_stun_pulse": "Impacto que salta", "fact_cel_guard_impact": "Impacto após o escudo", "fact_cel_weak_div": "Dano por efeito",
"fact_cel_weak_mana_div": "Magia a mais", "fact_cel_weak_extend": "Efeitos prolongados", "fact_cel_whirl_spread": "Efeitos espalhados",
"fact_cel_cadence_mix": "Acúmulo de outro botão", "fact_cel_mark_pass": "Marca que passa", "fact_cel_crit_apply": "Crítico intensifica efeitos",
```

Glossário (`gloss_X`, `_text`, `_words`, as palavras ativam o realce na carta):

```
"gloss_poison": "Veneno",
"gloss_poison_text": "Até 5 acúmulos; cada um causa dano por segundo por 5 s. Aplicar de novo renova o tempo, não o aumenta. Vale também em chefes.",
"gloss_poison_words": "veneno,envenena",
"gloss_bleed": "Sangramento",
"gloss_bleed_text": "Uma parte do dano do golpe cai ao longo de 4 s. Só golpes diretos aplicam, e o saldo nunca passa de três golpes.",
"gloss_bleed_words": "sangramento,sangra",
"gloss_shock": "Eletrificação",
"gloss_shock_text": "Até 5 cargas por 6 s; cada carga aplicada dá uma faísca na hora. Com Descarga, 5 cargas explodem em dano elétrico. Não atordoa.",
"gloss_shock_words": "carga,cargas,eletrificação,elétrica",
"gloss_window": "Abertura",
"gloss_window_text": "Quando o medidor de Frio ou de Impacto de um chefe ou guardião enche, ele recebe 25% a mais de dano dos seus golpes por 4 s. Depois, 10 s sem novo medidor. Nunca interrompe o ataque dele.",
"gloss_window_words": "abertura",
"gloss_antic": "Adiantar dano",
"gloss_antic_text": "Entrega de uma vez uma parte do dano que um efeito ainda causaria. Essa parte sai do efeito: nada é pago duas vezes.",
"gloss_antic_words": "adianta",
```


Argumentos novos de `CelRules.text_args()` (todos números fixos que as cartas citam): `poison_max` 5, `poison_time` 5, `poison_cap` 8, `grow_max` 30%, `sat_r` 2, `sat_cost` 2, `sat_cd` 4, `copy_n` 2, `copy_r` 3, `shock_max` 5, `shock_win` 6, `force_need` 3, `discharge_cd` 4, `conduct_r` 3,5, `conduct_pct` 50%, `reson_r` 3, `reson_n` 4, `bleed_time` 4, `bleed_ult` 20%, `antic` 50%, `antic_all` 20%, `combust_r` 2, `burn_div` 5%, `div_cap` 3, `div_full` 3, `frag` 30%, `frag_n` 3, `frag_r` 2, `keep` 1, `pulse_n` 3, `pulse_r` 2, `guard_win` 4, `extend` 2, `extend_cap` 8, `extend_weak` 1, `weak_div` 3%, `whirl_spread` 25%, `mark_r` 4, `crit_apply` 50%, `window_time` 4, `window_pct` 25%, `window_lock` 10.
