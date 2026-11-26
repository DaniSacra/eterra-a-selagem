# Bênçãos V2: especificação de implementação (GP-2)

Autor: balance-designer, 2026-11-26. Só documento: nada foi implementado nem medido. Base: HEAD `9083e79c`, pacote `docs/design/packs_2026-11-26/p0_bencaos_v2/` (01, 02, 03, 05; o 04 está superado), `bencaos_v1/IMPLEMENTACAO.md`, `balance.md` ("Bênçãos V1") e a seção 8 de `heroes/warrior_v1_2026-11-26.md` (slots novos). Os números são **ponto de partida para medir**, não calibrados; o robô compara versões, não dá taxa de vitória de gente.

Decisões do Daniel que valem aqui (não reabertas): 9 anjos x 9 (5 principais + 4 complementares) = 81; Zerael (Peste) aceito; o anjo do Trovão **não** é Baraqel (id técnico `thunder`, nome no jogo "Saarael", escolhido pelo Daniel); estado só com golpe que causa dano; sorteio 3:1 e mão completada por outros anjos como hoje; a Maga não muda.

## 0. Resumo e cortes (KISS)

V2 = 63 poderes da V1 (37 ficam como estão, 26 mudam o efeito sem mudar o id) + 18 novos (Zerael e Saarael (Trovão)). O motor novo é pequeno: três estados (Veneno, Sangramento, Eletrificação), um medidor de chefe, uma antecipação de DoT, uma propagação e um **limite de linhagem** que vale para tudo. Nada reescreve `Celestial`; ele cresce por cima do que existe.

**O que o pacote pede e eu cortei (e por quê):**

| Corte | Motivo | Quando voltar |
|---|---|---|
| Vórtice de agrupamento (Poder da Tempestade, Turbilhão) | puxar inimigos mexe no combate e na leitura (`combat-feel-director`) e o Corte Circular não tem recarga para reduzir. O Poder de Galael vira velocidade (já decidido na seção 8 do Guerreiro) | V2.1, se o Daniel sentir falta de "grupos" |
| Vendaval gera rajadas com recarga | precisa de gerador de rajada fora de habilidade; o Vendaval da V1 já é o Supremo de ritmo | V2.1 |
| Brisa Favorável: esquiva prepara rajada | idem; fica o +5% de movimento | V2.1 |
| Julgamento da Luz prioriza alvos condicionados | mexe na escolha de alvo de `STRIKES`; ganho pequeno | nunca, salvo pedido |
| Luz Crescente "fortalece a próxima aplicação" | redundante com Esplendor (o crítico que intensifica aplicação mora só nele) | não |
| Ressonância (Qeshael): condição distinta reduz a recarga restante | custo de leitura e quase nenhum efeito; mantém o -10% da V1 | não |
| Peso da Vigília e Névoa Profunda com diversidade | a Névoa é global (dano do inimigo) e o Peso já dura 30% mais; manter V1 | não |
| Contágio: bônus por alvos contaminados | só a cópia ao morrer (2 alvos); o bônus é ruído | não |
| Ressonância Elétrica: crítico e ruptura ajudam | só os vizinhos carregados; o resto cria ciclo e leitura ruim | não |
| Exército de Ecos antecipa sangramento | o Supremo já faz eco; ganha só sangramento nos golpes diretos | não |
| Sobrecarga com "todo dano recebido" | exigiria gancho em `Horde.damage` e abre ciclo; vale a presença de DoT no alvo | não |
| Medidor do chefe em elite | elite já congela (40%) e tem armadura; o medidor é só para chefe e guardião | não |
| Duos e Encantos | fora do lote (decisão do pacote) | |

## 1. Diff V1 para V2 por poder

Legenda: **MANTÉM** (mesmo id, mesmo efeito; pode mudar só um número), **MUDA** (mesmo id, efeito novo; save e ids antigos carregam), **NOVO** (id novo). Detalhe numérico na seção 3.

Totais: MANTÉM 37, MUDA 26, NOVO 18 = 81. Principais 45, complementares 36.

| Anjo | MANTÉM | MUDA | NOVO |
|---|---|---|---|
| Sarael (Chama) | `golpe_brasa`, `circulo_brasa`, `passo_brasa`, `chuva_brasas`, `chama_contagiosa`, `brasa_persistente` | `pesado_brasa` (antecipa Queimadura), `combustao` (área e antecipa DoTs), `fogo_crescente` (bônus por condição distinta) | |
| Nivael (Geada) | `golpe_geada`, `toque_geada`, `circulo_geada`, `floco_errante` | `peso_inverno` (estilhaça congelado), `estilhaco` (fragmentos), `inverno_prolongado` (preserva DoTs), `geada_profunda` (Frio ajuda Impacto), `cristais_errantes` (copia DoT) | |
| Lumael (Luz) | `golpe_radiante`, `pesado_radiante`, `circulo_radiante`, `clarao`, `ultimo_radiante`, `luz_crescente`, `prosperidade`, `fortuna_celestial` (ganha +3% por nível) | `esplendor` (crítico intensifica aplicação) | |
| Shomael (Vigília) | `golpe_firme`, `circulo_firme`, `passo_firme`, `ultimo_firme`, `peso_vigilia` | `pesado_firme` (estilhaça congelado), `ruptura` (antecipa DoT ao atordoar), `forca_inabalavel` (vale na Abertura e salta), `amparo` (escudo gasto reforça o Impacto) | |
| Velael (Véu) | `golpe_veu`, `pesado_veu`, `circulo_veu`, `fios_cinza`, `entardecer` | `crepusculo` (prolonga condições), `vulnerabilidade` (+ condições distintas), `essencia_restauradora` (+ diversidade), `veu_persistente` (prolonga outras condições) | |
| Galael (Vento) | `golpe_mare`, `passos_leves`, `vendaval`, `cadencia`, `brisa_favoravel` | `pesado_mare` (rajada propaga DoT), `circulo_mare` (vira velocidade do Poder, seção 8 do Guerreiro), `turbilhao` (propaga DoT), `fluxo_continuo` (ações distintas acumulam mais) | |
| Qeshael (Penumbra) | `golpe_marca`, `circulo_marca`, `olhar_rapido`, `ressonancia` | `pesado_marca` (+ Sangramento), `exercito_ecos` (+ Sangramento), `eco_crescente` (+ Sangramento), `marca_persistente` (passa ao morrer), `sombra_revelada` (crítico sangra) | |
| Zerael (Peste) | | | `golpe_peste`, `pesado_peste`, `circulo_peste`, `passo_peste`, `epidemia_celestial`, `saturacao`, `peste_persistente`, `deterioracao`, `contagio` |
| Saarael (Trovão) (`thunder`) | | | `golpe_trovao`, `pesado_trovao`, `circulo_trovao`, `passo_trovao`, `tempestade_celestial`, `descarga`, `conducao`, `sobrecarga`, `ressonancia_eletrica` |

Slots (nomes novos do Guerreiro; o enum `Boon.Slot` não muda): Ataque = `ATTACK` (toque e segurar), Especial = `SPECIAL` (Lança da Emeth, segurar o direito, 20 de Magia), Poder = `CAST` (Corte Circular, toque do direito, 8 de Magia), Esquiva = `DASH`, Supremo = `ULT`. O E (Interagir) não tem Bênção; a Investida saiu do Guerreiro.

## 2. Regras V2 (em cima de `Celestial` e `CelState`)

### 2.1 Princípios

1. Um estado só entra por **golpe que causa dano** (decisão 11). `after_hit` já só roda depois do dano; acrescenta-se: dano final 0 não aplica, e o golpe **barrado pela guarda** (número cinza, `shut` em `hit_enemy`) **não aplica estado** (a guarda passa a valer algo; resolve a pendência do pacote). Habilidade da própria Bênção (zona, nova, esquiva, Supremo) aplica como na V1 (sem golpe do herói), nunca em inimigo `invulnerable`.
2. **Uma aplicação por ação, alvo e estado** (`CelState.once(status, action)`, já existe). Fonte periódica (zona, flocos, rastro) usa `status_gap`/`ready()` por alvo. O id de ação é o `combat.kill_blow` (um id por golpe do combo, um para a Lança, um para cada Supremo).
3. **Coeficiente por ação**, para o combo de vários golpes não ganhar do golpe segurado: só o Golpe Esmagador (`omega_attack`, 75 de dano, 12 de Magia) difere. Contagens (acúmulos de Frio, Veneno, Cargas, pontos de Impacto) valem **x2** (`HOLD_COUNT_COEF`); taxas (Queimadura por segundo, fatia de Sangramento) valem **x1,5** (`HOLD_RATE_COEF`). Combo 1, 2 e giro valem x1 cada (o giro acerta em círculo e já pega mais alvos). A Lança e o Corte Circular usam os números da própria Bênção, sem coeficiente.
4. Dano de Bênção que não é golpe do herói (queimadura, veneno, sangramento, eco, explosões, descarga) é **secundário**: não critica, não eco, não empilha Cadência, não aplica estado (`SECONDARY_TAG`, como hoje). O crítico rola **uma vez por golpe direto** (`_crit`, sem mudança) e o eco usa o dano já calculado (sem rolar de novo).
5. Tipos de dano são só rótulo (físico, fogo, gelo, elétrico, tóxico...): **sem resistências novas**. Entram no `RESULT` pelo nome da fonte (`dealt_by`).
6. Maga: estados celestiais continuam separados do `Arcane`; a V2 não toca nada dela. Os 18 poderes novos usam só o que a Maga já recebe da V1 (mods por slot, habilidades por gatilho); a lista de testes pede um smoke dela.

### 2.2 Limite de linhagem, orçamento e dedupe (código novo, `scripts/core/cel_chain.gd` + `CelRules`)

Todo efeito secundário nasce de um **evento** com: `action` (id da ação), `target`, `kind` (o que é), `parent` (o que o gerou), `depth`. Uma instância pequena (`CelChain`, `RefCounted`, uma por golpe direto, reaproveitada) viaja pelas funções de reação.

Tipos (`kind`): `direct` (golpe do herói), `tick` (tique de DoT), `combust`, `shatter`, `frag`, `crystal`, `saturate`, `overload`, `discharge`, `conduct`, `copy` (propagação de DoT), `echo`, `whirl`, `rupture` (atordoamento de Impacto), `pulse`, `antic` (antecipação).

**Arestas permitidas** (tabela `CelRules.EDGES`, o resto é proibido):

| De | Para |
|---|---|
| `direct` | `combust`, `shatter`, `saturate`, `discharge`, `echo`, `whirl`, `rupture`, `antic`, `copy` |
| `tick` | `overload` |
| `overload` | `discharge` |
| `combust` | `antic` |
| `shatter` | `frag`, `crystal` |
| `rupture` | `antic`, `pulse` |
| `discharge` | `conduct` |

Proibidos por construção (não estão na tabela): eco->eco, cópia->cópia, descarga->descarga, condução->condução, fragmento->qualquer, antecipação->qualquer, e qualquer volta ao `direct`. Profundidade máxima 3 (`CHAIN_DEPTH`; o caminho mais longo é `tick->overload->discharge->conduct`). `CelChain.may(kind)` devolve falso fora da tabela ou passando da profundidade; reação que não pode simplesmente não acontece (conta em `tally[&"blocked"]` para o relatório).

**Orçamento** (constantes em `CelRules`, valores iniciais):

| Limite | Valor | Onde vale |
|---|---|---|
| `REACT_TARGETS` | 5 | alvos de uma reação (a explosão atinge o alvo e até 4) |
| `ACTION_REACT_CAP` | 8 | reações por ação (soma de todos os alvos dessa ação); `Celestial` guarda um contador pelo `kill_blow` das 3 últimas ações |
| `FRAME_REACT_CAP` | 24 | reações por quadro (proteção de desempenho no stress 300) |
| `DOT_DPS_CAP` | 16 | soma de Queimadura + Veneno + Sangramento por segundo num mesmo alvo; veneno e sangramento escalam para caber (a queimadura é do `Horde` e conta no total, não é cortada) |
| `BLEED_STACKS` | 3 | o saldo de Sangramento nunca passa de 3 vezes a fatia do último golpe |
| `BLEED_SHARE_MAX` | 0,8 | fatia máxima do dano do golpe que vira Sangramento (com Eco Crescente e raridade) |
| recargas por alvo | ver 2.3 a 2.7 | `CelState.ready(chave, s)` |

Antes de cada reação o `Celestial` checa `chain.may(kind)`, o orçamento da ação e a recarga do alvo; só então age. Não existe "dano secundário que alimenta tudo": o dano de reação nunca chama `after_hit`.

**Dedupe**: `CelState.once` por (estado, ação); `CelState.ready` por (fonte, alvo); a cópia de DoT marca o alvo com `copy_lock` (3 s) e não copia de novo; o fogo que saltou continua com `no_spread` como na V1.

### 2.3 Veneno (Peste)

Dado em `CelState`: `poison` (acúmulos, 0 a 5), `poison_t` (segundos restantes, **um relógio para todos os acúmulos**), `poison_dps` (por acúmulo: vale o maior entre as fontes enquanto houver veneno, como a Queimadura), `poison_age` (segundos desde o primeiro acúmulo), `sat_cd`.

- `CelRules`: `POISON_MAX = 5`, `POISON_TIME = 5.0`, `POISON_TICK = 0.5`, `POISON_SKILL_DPS = 1.0` (por acúmulo quando a fonte é uma habilidade e não um botão), `POISON_TIME_MAX = 8.0` (teto do relógio com os bônus).
- `apply_poison(e, stacks, key, dps, source, gap)`: como `apply_cold` (não em `invulnerable`, `once(&"poison", key)`, `gap` por fonte periódica). `poison = min(poison + stacks, 5)`; `poison_t = min(max(poison_t, 5 x (1 + cel_poison_time_pct)), 8)`: renovar **nunca soma duração**, só volta ao teto. `poison_dps = max(...)`. Chefe e guardião aceitam veneno (a Queimadura já aceita).
- **Tique** (código novo, no `step` do `Celestial`, uma passada a cada 0,5 s sobre os `_tracked` com `poison > 0`): dano = `poison x poison_dps x (1 + crescimento) x 0,5`, fracionário, entregue por `horde.damage(..., dot=true)` como a Queimadura (`dealing = &"veneno"`), **não** por `_secondary` (que arredonda para 1 no mínimo e inflaria). O relógio cai 0,5 por tique; quando zera, `poison = 0`.
- **Saturação** (reação, só com a Bênção `saturacao` na mão): ao chegar em 5 acúmulos e `sat_cd` zerado, explosão de 2,0 m (`cel_sat_dmg` no alvo, 50% em até 4 vizinhos), **consome 2 acúmulos** (fica com 3) e arma `sat_cd = 4 s` no alvo. Aresta `direct->saturate`. Sem a Bênção, os 5 acúmulos só ficam no teto.
- **Peste Persistente**: `cel_poison_time_pct` aumenta o `POISON_TIME` (até o teto 8 s); `cel_poison_cold = 1`: enquanto o alvo tem Frio, o relógio do veneno cai pela metade (nunca para: sem bônus infinito).
- **Deterioração**: `poison_age` sobe enquanto há veneno; o dano por acúmulo ganha `cel_poison_grow` por segundo (6%, +3% por nível), **teto +30%**; cresce em dobro se o alvo também tem Queimadura ou Sangramento. Zera quando o veneno some.
- **Contágio** (`on_killed`): ao morrer envenenado, copia `poison x cel_poison_spread` acúmulos (mínimo 1) e metade do tempo restante (mínimo 2 s) em até 2 inimigos a 3,0 m (`copy`, uma vez; o alvo recebe `copy_lock`).
- Raridade multiplica só `cel_poison_dps` e `cel_sat_dmg`.

### 2.4 Sangramento (Penumbra)

Dado em `CelState`: `bleed_pool` (dano que falta), `bleed_t` (segundos). `CelRules`: `BLEED_TIME = 4.0`.

- `apply_bleed(e, share, dmg, key)`: só de **golpe direto elegível** (o `dmg` final do golpe, com crítico). `add = share x dmg`; `pool = min(pool + add, add x BLEED_STACKS)`; `bleed_t = BLEED_TIME`. Uma por ação e alvo (`once`). `share = (cel_bleed do slot) x (1 + cel_bleed_pct)`, limitada a `BLEED_SHARE_MAX`. Proporcional ao golpe, então a Lança (150) sangra 15x mais que um golpe de 10, sem coeficiente extra.
- Tique (mesma passada de 0,5 s): `pool x 0,5 / bleed_t`, `dealing = &"sangramento"`, fracionário, também sob o `DOT_DPS_CAP`. O saldo cai e quando `bleed_t` zera o resto some (orçamento separado e fechado).
- Quem aplica: `pesado_marca` (golpes do Especial em alvo **marcado**), `exercito_ecos` (durante a janela do Supremo, golpe direto em alvo marcado), `sombra_revelada` (golpe crítico em alvo marcado sem sangramento). Eco Crescente só multiplica a fatia.
- **Crítico e sangramento**: o crítico engorda o `dmg` do golpe que aplica (proporcional), mas o tique nunca critica.

### 2.5 Eletrificação e Descarga (Saarael (Trovão))

Dado em `CelState`: `shock` (cargas, 0 a 5), `shock_t` (relógio), `discharge_cd`, `over_acc` (fração da Sobrecarga). `CelRules`: `SHOCK_MAX = 5`, `SHOCK_WINDOW = 6.0`, `DISCHARGE_CD = 4.0`, `DISCHARGE_REACH = 3.0` (raio da ressonância).

- `apply_shock(e, charges, key, zap, source, gap)`: `once(&"shock", key)`; `shock = min(shock + charges, 5)`, `shock_t = 6` (renova até o teto, não soma). Cada carga aplicada dá **uma faísca imediata** `zap x cargas` (`cel_shock_zap`, dano elétrico secundário, `dealing = &"faisca"`), então um principal do Trovão sozinho já tem efeito. Chefe e guardião aceitam carga; **nunca** são atordoados.
- **Descarga** (reação, só com `descarga` na mão): ao chegar em 5 cargas com `discharge_cd` zerado: dano elétrico `cel_discharge x cargas x (1 + ressonância)` no alvo, zera as cargas, `discharge_cd = 4 s`. Aresta `direct->discharge` ou `overload->discharge`. O Peso do Trovão (`cel_force_discharge`) descarrega o alvo já com 3 ou mais cargas (só se a Descarga estiver na mão e fora da recarga).
- **Condução** (`conducao`): a Descarga salta (`conduct`) a `cel_conduct` inimigos a 3,5 m (2 no nível 1, +1 por nível, máximo 4) com 50% do dano e **sem** cargas (descarga->descarga proibida).
- **Sobrecarga** (`sobrecarga`): alvo com cargas **e** alguma DoT (Queimadura, Veneno ou Sangramento) ganha `cel_overload` cargas por segundo (0,5, +0,2 por nível), acumuladas em `over_acc` (cada 1,0 vira uma carga). Roda na mesma passada de 0,5 s (`tick->overload`); pode completar o limiar e disparar a Descarga (`overload->discharge`), nunca mais do que isso.
- **Ressonância Elétrica**: a Descarga ganha `cel_reson` (10%, +3% por nível) por **outro** inimigo carregado a 3 m do alvo, no máximo 4 vizinhos (+40% no teto).
- Raridade multiplica só `cel_shock_zap`, `cel_discharge` (dano).

### 2.6 Antecipação de DoT (consome a fração) e propagação única

**Antecipação** (`Celestial._antic(e, share, chain)`; `once(&"antic", key)` por ação e alvo, e `ready(&"antic", 2.0)` por alvo): para cada DoT do alvo calcula o que falta (`burn_dps x burn_t`; `poison x dps x t`; `bleed_pool`), entrega `share` desse total de uma vez como dano secundário (`dealing = &"antecipacao"`) e **consome a mesma fração**: encurta `burn_t` e `poison_t` por `(1 - share)` (o dps fica) e multiplica `bleed_pool` por `(1 - share)`. Nada é pago duas vezes. Ordem na ação: **antecipa primeiro, aplica depois** (o Peso em Brasa antecipa a queimadura que já havia e só então reaplica a nova). Quem antecipa: `pesado_brasa` (50% da Queimadura), `combustao` (20% de todos os DoTs do alvo central), `ruptura` (25% de todos, ao atordoar um comum; `rupture->antic`).

**Propagação** (`copy`): copia **fração** de um DoT para vizinhos que ainda não têm esse DoT, com o tempo restante pela metade (mínimo 2 s) e `copy_lock` de 3 s no destino (não copia de novo; "propagação não dispara propagação"). Máximo `REACT_TARGETS - 1` cópias por evento. Fontes: `chama_contagiosa` (ao morrer, já existe), `contagio` (ao morrer), `pesado_mare` (a rajada copia 30% dos DoTs de cada alvo atingido para 1 vizinho a 3 m; teto 4 cópias por rajada), `turbilhao` (25%, no máximo 2 cópias por Turbilhão), `cristais_errantes` (30% depois do estilhaço; aresta `shatter->crystal`).

### 2.7 Medidor de Frio e de Impacto em chefe e guardião (a "Abertura")

Alvo do medidor: **chefe** (Frio e Impacto) e **guardião** (`def.heavy`, só Impacto; o Frio dele já congela 40%). Elite fica como na V1. Não toca o `poise` nativo, não interrompe script, não congela nem atordoa.

- `CelState`: `meter_c`, `meter_i` (pontos), `meter_t` (janela, 8 s, renova a cada ponto, como o Frio comum), `window_t` (Abertura aberta), `window_lock` (recarga).
- Cada ponto de Frio ou Impacto que **já seria** aplicado num comum soma no medidor do chefe (mesmo `once` por ação, mesmos coeficientes). Pontos de Impacto contam com `cel_impact_need` (Ruptura: -2 no medidor, o dobro do comum). Enchimento: Frio **8**, Impacto **10** (`METER_COLD`, `METER_IMPACT`).
- Ao encher (qualquer um dos dois): `window_t = 4,0 s` (`WINDOW_TIME`) e depois `window_lock = 10,0 s` (`WINDOW_LOCK`) em que os medidores **não somam** (ciclo de cerca de 18 s com o enchimento). Durante a Abertura:
  - golpes **diretos** do herói causam **+25%** (`WINDOW_VULN`), na mesma soma aditiva de `direct_mult` (Vulnerabilidade e Força Inabalável somam com ela, não multiplicam);
  - `Estilhaçamento` dispara no primeiro golpe da Abertura (reaproveita `frozen_left`/`shatterable` do `CelState`: `frozen_left = WINDOW_TIME`, **sem** mexer em `Enemy.frozen_t`);
  - `Força Inabalável` trata a Abertura como "atordoado".
- Efeito médio esperado: +25% x (4 / 18) = cerca de +6% de dano contra o chefe para quem enche a barra a cada ciclo (Nivael e Shomael saem do zero no teto). Calibrar `METER_*` e `WINDOW_VULN` na medida.
- `Combat.is_common`-like: nova função `CelRules.meter_target(def)` (chefe ou `def.heavy`).
- UI mínima (P2): dois pontinhos finos sob a barra do chefe (Frio, Impacto) com preenchimento e um brilho na Abertura; sem texto.

### 2.8 Diversidade de condições

`CelState.diversity(e)` conta, de 0 a 6, quantas destas existem agora no alvo: Queimadura, Veneno, Sangramento, Frio, Eletrificação, Marca (Fraqueza e Impacto ficam de fora para não contar a própria condição de cada Bênção). Usada por: Fogo Crescente (+5% por condição **outra**, máx 3), Vulnerabilidade (+3% por condição, máx 3), Essência Restauradora (3 ou mais dão +1 Magia). É lida **na hora da aplicação** (foto), não por tique.

### 2.9 Crítico intensifica aplicação (Esplendor)

`direct_mult` guarda `_hit_crit` (o fator do golpe) que `after_hit` lê na sequência (mesmo golpe, sem nova rolagem). Com `cel_crit_apply > 0` (Esplendor) e golpe crítico, as aplicações **desse golpe** ficam mais fortes: Queimadura, Veneno e fatia de Sangramento x1,5 (`CRIT_APPLY = 0,5`); Veneno e Cargas ganham **+1** acúmulo/carga (teto do estado vale). Tique de DoT nunca critica. Frio, Impacto, Fraqueza e Marca ficam de fora.

### 2.10 Ordem de `after_hit` (nova)

1. Guardas: morto, dano 0, golpe barrado pela guarda (`shut`).
2. Coeficiente da ação (Esmagador).
3. Antecipações (`pesado_brasa`), **antes** de reaplicar.
4. Aplicações do slot: Queimadura, Veneno, Carga, Sangramento, Frio, Impacto, Fraqueza, Marca (com a intensificação do crítico).
5. Reações (`combust` na Queimadura, `saturate`, `discharge`, `rupture`+`antic`+`pulse` no Impacto, `shatter`).
6. Eco (como na V1).

### 2.11 O que é dado e o que é código

**Dado** (`tools/make_data.gd` + `data/text_pt.tres`; regenerar com `... -s tools/make_data.gd -- boons angels`):
- 18 linhas `_v(...)` novas no `_v1_boons()` e 18 ids em `V1_IDS`; `assert(_v1_n == 81)`.
- Os números novos e as mudanças da seção 3 (mods `cel_*`, `SkillDef` das zonas, novas, rajada).
- 2 `_angel(...)` novos.
- Todo texto da seção 5.

**Código novo, por arquivo (o `gameplay-engineer` aplica):**

| Arquivo | O quê |
|---|---|
| `scripts/core/boon.gd` | `Family`: acrescentar `PESTE` e `TROVAO` **depois** de `MARCA` (os inteiros dos `.tres` não mudam); `FAMILY_COLOR` e `FAMILY_TAG` (`&"peste"`, `&"trovao"`) com mais dois itens |
| `scripts/core/cel_rules.gd` | constantes novas (2.2 a 2.7), `EDGES`, `HOLD_COUNT_COEF`, `HOLD_RATE_COEF`, `meter_target`, `anticipate(remaining, share)`, `poison_tick`, `bleed_add`, `discharge_dmg`, `text_args()` com os números novos |
| `scripts/core/cel_state.gd` | campos de Veneno, Sangramento, Eletrificação, medidor, `copy_lock`; `step`; `add_poison`, `add_bleed`, `add_shock`, `add_meter`, `diversity` |
| `scripts/core/cel_chain.gd` (novo) | `CelChain`: `action`, `depth`, `last`, `may(kind)`, `enter(kind)` e o contador por ação |
| `scripts/game/celestial.gd` | `apply_poison/bleed/shock`, passada de tiques de 0,5 s, reações (`_saturate`, `_discharge`, `_conduct`, `_overload`, `_frag`, `_pulse`, `_antic`, `_copy`, `_mark_pass`, `_extend`), medidor e Abertura em `direct_mult`/`apply_cold`/`apply_impact`, coeficiente do Esmagador, `_hit_crit`, parâmetro `shut` em `after_hit`, `on_killed` (Contágio, Marca Persistente), `on_action` (Fluxo Contínuo: `_last_slot`), `_step_guard` (Amparo: escudo gasto), `tally` com as chaves novas |
| `scripts/game/combat.gd` | `_apply_status`: casos `poison`, `shock`, `spread`, `weak_extend`; `on_zone_hit`: caso `PLAGUE`; passar `shut` a `after_hit`; Descarga/tique pelo `horde.damage` com `dot=true` |
| `scripts/game/ground.gd` (+ `ground_look.gd`) | `Kind.PLAGUE` (zona de contaminação: bolhas verde-bile, nunca o aro âmbar do perigo); só desenho e a chamada acima |
| `scripts/game/skills.gd`, `game.gd` | `CONSECRATE` com `status = &"poison"` cria `PLAGUE`; o rastro da esquiva `dodge_plague_dps` ao lado do `dodge_ember_dps` (`game.gd` na esquiva) |
| `scripts/ui/boon_choice.gd` | `PER_SECOND` ganha `cel_poison_dps`; `SECONDS` ganha `cel_bleed`? não (é fatia); fatos novos |
| `scripts/ui/angel_seal.gd`, `angel_fx.gd` | um braço de `match` por família nova (selo e efeito do anjo; arte: ver 4) |
| `scripts/render/state_pips.gd` | três pips novos (gota de veneno, faísca, gota de sangue), seção 4 |
| `tools/smoke.sh`/`Dev` | `--angels=` aceita `zerael` e `thunder`; `RESULT.cel` com as chaves novas |

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

## 6. Testes GUT (um arquivo novo `tests/test_blessings_v2_*.gd` por tema; rodar com `-gselect`)

Existentes a **atualizar** (não afrouxar): `test_blessings_v1_catalog` (63 vira 81; 45 principais; 36 complementares; `assert(_v1_n == 81)`), `test_blessings_v1_draw`, `test_blessings_v1_rules`, `test_blessings_v1_combat`, `test_angel_cards`, `test_an2` (9 anjos), `test_element_look` (duas cores).

**`test_blessings_v2_catalog.gd`**
- 81 ativos, 45 principais, 36 complementares, 9 por anjo; 5 slots por anjo (A, S, P, E, U) e nenhum principal no E (`RUSH`); ids únicos; os 63 ids da V1 todos presentes e os 18 novos.
- Pré-requisitos: cada complementar tem fonte do próprio anjo (um complementar nunca fica sem principal do anjo que o alimente; `descarga` e `conducao` encadeiam).
- Famílias novas têm cor, tag e selo; `Boon.Family.MARCA == 7`, `PESTE == 8`, `TROVAO == 9`.
- Save e ids antigos: todo id da V1 resolve; carregar um save com Bênçãos antigas dá a mesma mão; `reserve` continua carregando (50 ids).
- Raridade: só os mods marcados **R** escalam; durações, contagens, acúmulos, cargas e recargas ficam fixos nas quatro raridades.

**`test_blessings_v2_draw.gd`**
- Sorteio determinístico (mesma semente, mesmas cartas) e com 9 anjos; peso 3:1 entre anjo já na mão e anjo novo; mão completada por outros anjos quando um anjo traz menos de 3; nunca carta morta (nenhum complementar sem fonte, nenhum principal em slot ocupado); 1 a 3 cartas válidas; anjo com 0 sai antes da porta.
- `Encounter.affinity` com os novos; `--angels=zerael,thunder` força o par.

**`test_blessings_v2_rules.gd`** (puro, em `CelRules`/`CelState`/`CelChain`)
- Veneno: 5 acúmulos no máximo; renovar não soma duração e respeita `POISON_TIME_MAX`; relógio único; expira e zera; dps é o maior entre fontes; Deterioração cresce até +30% e zera ao acabar; Peste Persistente com Frio cai pela metade e nunca para.
- Saturação: dispara em 5 acúmulos, consome 2, recarga 4 s por alvo; sem a Bênção não dispara.
- Sangramento: proporcional ao dano do golpe (golpe de 150 sangra 15x o de 10); saldo nunca passa de 3 fatias; o tique esvazia o saldo em 4 s; fatia nunca passa de 0,8; **sem crítico no tique**.
- Eletrificação: 5 cargas, janela 6 s, Descarga zera as cargas e arma a recarga; Condução salta com 50% e **sem** cargas; Sobrecarga só com DoT no alvo; Ressonância Elétrica teto +40%.
- Antecipação: consome a mesma fração (dano adiantado + restante = total antes), não duplica; ordem antecipa-depois-aplica; uma por ação e alvo; recarga de 2 s.
- **Linhagem**: toda aresta fora de `EDGES` é recusada; eco->eco, cópia->cópia, descarga->descarga, condução->condução, fragmento->qualquer, antecipação->qualquer **todas recusadas**; `tick->overload->discharge->conduct` passa e uma quarta aresta não; profundidade 3 é o teto.
- Orçamento: no máximo `REACT_TARGETS`, `ACTION_REACT_CAP` e `FRAME_REACT_CAP`; `DOT_DPS_CAP` escala veneno e sangramento sem tocar na queimadura.
- Medidor: Frio enche em 8 e Impacto em 10 (Ruptura -2); Abertura de 4 s com +25% nos golpes diretos, recarga 10 s sem somar; Estilhaçamento dispara no primeiro golpe dela; `Enemy.frozen_t`, `stun_t` e `poise` do chefe **não mudam**; elite fica como na V1; guardião só Impacto.
- Dedupe: um golpe que acerta duas vezes o mesmo alvo aplica o estado uma vez (`once`); o Esmagador aplica x2 contagem e x1,5 taxa; combo de três golpes aplica três vezes (uma por golpe).
- Crítico: `direct_mult` rola uma vez; eco e tique **não** rolam; Esplendor intensifica só aplicações do golpe crítico, e um segundo golpe não crítico não herda; `CRIT_MAX` 60% e `CRIT_MULT_MAX` 250% valem.
- Diversidade: conta de 0 a 6; Fogo Crescente e Vulnerabilidade respeitam o teto 3; foto na aplicação, não por tique.

**`test_blessings_v2_combat.gd`** (com `Combat` e inimigos de teste)
- Estado só com golpe que causa dano: golpe com dano 0 não aplica; golpe barrado pela guarda (`shut`) não aplica; inimigo `invulnerable` não aplica e `hit_enemy` devolve falso; Morvath em escudo de ritual não recebe veneno nem carga.
- Chefe sem congelar, sem atordoar e sem mexer em `frozen_t`/`stun_t`/`poise`; guardião e chefe aceitam Veneno, Sangramento e Carga.
- Zona `PLAGUE` aplica 1 acúmulo por segundo por inimigo; rastro `passo_peste` idem; `epidemia_celestial` aplica 3; `tempestade_celestial` aplica 2 cargas por raio.
- `pesado_mare` copia no máximo 4 DoTs por rajada; `turbilhao` no máximo 2; a cópia não copia (`copy_lock`).
- Contágio e Marca Persistente passam **uma vez** ao morrer; o passado não passa de novo.
- Amparo: escudo **gasto** num golpe dá +2 ao próximo Impacto; escudo **expirado** não dá.
- Fluxo Contínuo: ações de botões diferentes dão +1 acúmulo a mais, do mesmo botão não.
- `circulo_mare` dá velocidade ao `CAST`; nenhum teste espera recarga do Poder.
- **Maga sem regressão**: o `Arcane` continua separado; o smoke da Maga com os 18 novos não dá erro de script (o `Rect2 size is negative` de `fx.gd:1950` é o conhecido e se testa à parte).
- HUD e glossário: toda carta nova mostra números reais (`{a}` etc. resolvem, nenhuma chave `{...}` sobra), `fact_*` existem para todo stat novo, `gloss_*` existem, nenhuma frase tem travessão.

**Rodar ao integrar**: `tools/check.gd`, suíte inteira, `--stress=300` (sem queda de quadros por tique, reação ou zona), uma captura na GPU por família nova (Peste e Trovão), `build/linux/ASelagem.x86_64 --headless -- --smoke=30 --seed=5 --nosave` contra o editor.

## 7. Plano de medida (depois da implementação; nada foi rodado agora)

Régua do `balance.md` (robô sem tela, **não** é gente): `tools/smoke.sh 900 --seed=N --bot-reaction=0.25 --ultimate=cleave`, sementes **1 a 12**, sempre as mesmas; teto: `--start=boss --hero-hp=500 --boon-ids=...`. Registrar, por semente: vida do Morvath que sobra (`boss_hp`), vitória, fase máxima, tempo de luta (`boss.time`), dano sofrido (`sum(boss.hurt_by)`), dano por fonte (`dealt_by`: `veneno`, `sangramento`, `faisca`, `descarga`, `saturacao`, `antecipacao` etc.), `cel` (ativações, `blocked`), mana, tempo por sala e desempenho (`stress 300`). Conferir as flags atuais do `smoke.sh`.

Linha de base (V1 ajustada, `balance.md`): natural, Morvath restante média **1989**, 1 vitória em 12; teto em segundos (média, sem Bênção 306): Sarael 225, Lumael 266, Velael 275, Shomael 286, Nivael 295, Qeshael 274, Galael 312 (273 só o conjunto de ritmo). **Baseline obrigatório antes de mexer**: repetir isto no HEAD da V2 sem os 18 novos (os 63 com as mudanças de efeito já entram, então medir também "63 inalterados" para isolar o que mudou).

### Metas (proposta, o Daniel aprova)

| Medida | Meta |
|---|---|
| Natural, Morvath restante (média das 12) | **1500 a 2000** (a régua do repo; V1 ajustada 1989) e **1 a 3 vitórias em 12** |
| Teto de cada um dos 9 monoanjos (9 poderes, tempo de luta) | **235 a 290 s** (sem Bênção 306); Sarael continua o mais forte, mas **nenhum monoanjo abaixo de 220 s nem acima de 300 s** |
| Zerael e Saarael (Trovão) no teto | **245 a 275 s** (entre Lumael e Velael); se um passar de Sarael, baixar `cel_poison_dps` ou `cel_discharge`; se ficar sobre 295, subir |
| Nenhuma fonte passa de 30% do dano total de um anjo (`dealt_by`) e nenhum anjo tem fonte morta (0% em 12 sementes) | geral |
| Controle e proteção (Shomael, Velael, Nivael) | dano sofrido por segundo **10% abaixo** do sem Bênção (Shomael hoje 0,634 contra 0,752); a Abertura deve aparecer **ao menos 1 vez por luta** em 8 das 12 sementes |
| Chefe com Frio e Impacto | Nivael e Shomael no teto saem de "colados no zero" para **-8% a -15%** do tempo (efeito esperado da Abertura, cerca de +6% de dano) |
| Cartas úteis nos 36 pares + 9 monoanjos | em 12 sementes, **toda mão com ao menos 1 carta útil** (zero carta morta), sem exigir reação exclusiva por par |
| Desempenho | `--stress=300` sem perda de quadro percebida (comparar com a V1) |

Alarme de dominância: qualquer Bênção ou fonte com mais de 30% do dano numa semente, qualquer arquétipo abaixo de 200 s no teto, qualquer anjo que some do sorteio.

### Os 12 arquétipos (8 Bênçãos cada, no teto e na descida; esquiva fica de fora do teto porque o robô a usa mal)

Build = Ataque, Especial, Poder, Supremo | 4 complementares. Teto de cada: **235 a 285 s**; os dois de controle (A6, A12) valem pelo dano sofrido (meta acima), não pelo tempo.

| # | Par e ideia | `--boon-ids` |
|---|---|---|
| A1 | Chama + Vento (propagação) | `golpe_brasa,pesado_mare,circulo_brasa,chuva_brasas,combustao,chama_contagiosa,cadencia,turbilhao` |
| A2 | Chama + Geada (estilhaço) | `golpe_brasa,toque_geada,circulo_brasa,peso_inverno,combustao,estilhaco,cristais_errantes,inverno_prolongado` |
| A3 | Chama + Peste (detonação) | `golpe_brasa,pesado_peste,circulo_brasa,epidemia_celestial,combustao,saturacao,fogo_crescente,contagio` |
| A4 | Peste + Luz (acúmulo crítico) | `golpe_peste,pesado_peste,circulo_radiante,epidemia_celestial,saturacao,deterioracao,fortuna_celestial,esplendor` |
| A5 | Penumbra + Luz (sangramento e eco) | `golpe_marca,pesado_marca,circulo_radiante,exercito_ecos,sombra_revelada,eco_crescente,fortuna_celestial,esplendor` |
| A6 | Geada + Vigília (ruptura) | `golpe_geada,pesado_firme,circulo_firme,peso_inverno,ruptura,geada_profunda,forca_inabalavel,estilhaco` |
| A7 | Véu + Chama (condições) | `golpe_brasa,pesado_veu,circulo_brasa,crepusculo,fogo_crescente,vulnerabilidade,veu_persistente,combustao` |
| A8 | Véu + Peste (deterioração) | `golpe_peste,pesado_veu,circulo_peste,crepusculo,deterioracao,vulnerabilidade,veu_persistente,saturacao` |
| A9 | Trovão + Peste (sobrecarga) | `golpe_trovao,pesado_peste,circulo_peste,epidemia_celestial,sobrecarga,descarga,deterioracao,saturacao` |
| A10 | Trovão + Vento (grupos) | `golpe_trovao,pesado_mare,circulo_trovao,tempestade_celestial,descarga,conducao,cadencia,turbilhao` |
| A11 | Trovão + Penumbra (ressonância) | `golpe_trovao,pesado_marca,circulo_trovao,tempestade_celestial,descarga,sobrecarga,ressonancia_eletrica,eco_crescente` |
| A12 | Vigília + Véu (controle e proteção) | `golpe_firme,pesado_veu,circulo_firme,passo_firme,ultimo_firme,amparo,forca_inabalavel,vulnerabilidade` |

Descida inteira de cada par: `--angels=<a>,<b>` (ids de anjo: `sarael`, `nivael`, `lumael`, `shomael`, `velael`, `galael`, `qeshael`, `zerael`, `thunder`). Os 9 monoanjos: um anjo forçado por vez, como na V1; o teto com as 9 ids do anjo. Os 36 pares só precisam de cartas úteis (teste de sorteio), não de medida de dano.

**Aviso de A10:** sem o vórtice (cortado), "grupos" depende de Condução e Turbilhão; se A10 ficar abaixo de 235 s ou sentir-se vazio, o vórtice (V2.1) volta primeiro. **Aviso de A4:** o crítico de Lumael só chega ao Ataque pelo `golpe_radiante`, que disputa o slot com `golpe_peste`; a ponte é `fortuna_celestial` (5/8/11%); se a build não passar de 6% de crítico, subir `fortuna_celestial` ou `cel_crit_apply`.

### Calibração, em ordem (um número de cada vez, mesmas 12 sementes)

1. Os 63 com mudança de efeito, sem os novos (isolar). 2. Zerael sozinho (`cel_poison_dps`, depois `cel_sat_dmg`). 3. Trovão sozinho (`cel_shock_zap`, depois `cel_discharge`). 4. Medidor e Abertura (`METER_COLD`, `METER_IMPACT`, `WINDOW_VULN`). 5. Os 12 arquétipos. 6. Natural. Escrever cada rodada em `balance.md` ("Bênçãos V2") com número antigo, novo e onde muda no `make_data.gd`.

### O que fica para o Daniel

Sensação do Veneno, da Abertura e da Descarga (o robô lê todo aviso e não procura cobertura); nome do Saarael (Trovão) e as duas frases; `Passos Leves` (pendência da V1); se Zerael e o Saarael (Trovão) aparecem com a frequência certa entre 9 anjos; o `runs.jsonl` das descidas dele (anjos escolhidos por sala e sala da morte) para recalibrar depois de gente.
