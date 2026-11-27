> Índice: [IMPLEMENTACAO_V2.md](../IMPLEMENTACAO_V2.md)

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
