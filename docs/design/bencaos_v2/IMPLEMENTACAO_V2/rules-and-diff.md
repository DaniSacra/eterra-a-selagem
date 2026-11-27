> Índice: [IMPLEMENTACAO_V2.md](../IMPLEMENTACAO_V2.md)

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
