# Bênção x botão: o Guerreiro e a Maga elemental (HD-06, item 25 do backlog)

- **Data**: 2026-11-24. **Autor**: `hero-designer`. **Base**: `docs/backlog_proposals/heroes_2026-11-24.md` (HD-06), `redesign_2026-11-24/04_PLANO.md` C.5.
- **Conferido contra o código atual** (nada foi alterado): `data/boons/` (77 Bênçãos, lidas pelo `Boon`), `scripts/core/boon.gd`, `scripts/game/skills.gd`
  (`trigger_of`), `scripts/game/combat.gd` (`hit_enemy`, `throw_wave`, `on_shot_hit`), `scripts/game/arcane.gd`, `scripts/game/ultimates.gd`,
  `scripts/game/game.gd` (`_on_dodged`), `tools/make_data.gd` (`_tree`, `_maga_tree`, `_maga`). `scripts/core/hero_loadout.gd` só trata dos Dons (o que a
  tela do herói edita): não decide nada de Bênção, só diz o nome da ação de cada slot em palavras da Maga (`action_key`).
- **Só vale para as quatro famílias de jogo** (Chama, Geada, Luz, Vigília). As três de anjo (Véu, Maré, Marca) têm Bênção nos 4 botões (esquerdo, direito, Q, E) e
  nenhuma no Espaço nem no Shift; o que elas fazem em cada herói segue as mesmas regras de tag abaixo (nota no fim da seção 4).

## 1. Como uma Bênção chega a um botão (o que o código faz hoje)

1. Cada Bênção tem um **slot** (`Boon.Slot`: ATTACK, SPECIAL, CAST, DASH, RUSH, ULT). Ele diz em que botão a carta aparece e qual tag ela lê
   (`SLOT_TAG`: light, heavy, cast, dash, dash, ultimate).
2. O efeito vem das **tags do golpe**: cada `BoonMod` tem `tag` e só vale em golpe com essa tag (`BoonState.stat`). Por isso Bênção "vaza" para qualquer golpe que
   leve a mesma tag, de qualquer herói. As tags dos botões:

| Botão | Guerreiro (`_tree`) | Maga (`_maga_tree`) |
|---|---|---|
| Esquerdo | `cut1/2`: light; `cut3` (giro): light, spin, finisher; segurar, Lança: light, thrust, finisher, omega | toque, Centelha: light, bolt, arcane, fire; segurar, Combustão: omega, light, bolt, arcane, fire |
| Direito | `bolt` (onda da espada): heavy, wave | toque, Estilhaço: heavy, bolt, arcane, ice; segurar, Geada: omega, heavy, cast, arcane, ice |
| Q | Brado: shout, cast | Arco Voltaico: shout, cast, arcane, volt |
| E | Investida: light, dash | Suspensão Arcana (domo): dash, arcane, dome |
| Shift | Corte do Juízo: ultimate, light | Convergência Elemental: ultimate, cast |
| Espaço | esquiva (dispara `Trigger.DODGE`; `dodge_ember_dps`, `dodge_charges` e `move_speed_pct` valem) | Passo Etéreo (idem; `Arcane._on_dodged` põe o rastro de brasa nas duas pontas) |

3. Bênção de **habilidade própria** (`skill`) dispara pelo `SkillDef.Trigger` do botão: o golpe cuja tag manda (`Skills.trigger_of`: omega, depois dash, shout,
   heavy, finisher) dispara RUSH, SHOUT, SPECIAL, OMEGA ou FINISHER; a esquiva dispara DODGE; o Supremo, ULT.
4. Efeitos de **estado** (Queimadura, Congelamento, Fraqueza, Marca) que a Bênção aplica são os do inimigo (`e.burn_t`, `e.frozen_t`, `e.weak_t`, `e.mark_t`). Os
   estados nativos da Maga (`ElementBook`: Queimadura, Frio, Eletrizado) são outra conta. Detalhe na seção 5.

Legenda das tabelas: **faz** (efeito inteiro), **parcial** (parte do efeito não existe naquele herói, dito na célula), **nada** (a Bênção existe no sorteio do botão e não
muda nada), **vazio** (a família não tem Bênção desse slot).

## 2. Guerreiro: 4 famílias x 5 botões e a travessia

Fúria saiu (nenhuma Bênção nem Dom lê `fury_*`; conferido). O encaixe que ela dava às famílias não existe mais, e o que segura o herói agora são as tags acima.

| Família | Esquerdo | Direito | Q (Brado) | E (Investida) | Shift (Corte do Juízo) | Espaço |
|---|---|---|---|---|---|---|
| **Chama** | faz: `golpe_brasa` (light:burn_dps; vale na Investida, na Lança e no Supremo, que levam light) | faz: `pesado_brasa` (chão em brasa quando a onda sai) | parcial: `circulo_brasa` só detona queimadura de Bênção, então pede `golpe_brasa` antes | faz: `redemoinho` (orbes queimam depois da Investida) | faz: `ultimo_brasa` | faz: `passo_brasa` (rastro de brasa) |
| **Geada** | parcial: `golpe_geada` (spin:freeze_time) só no giro, o 3º golpe; é de propósito, o giro é o fecho | faz: `toque_geada` (a onda tem a tag `wave`, então estilhaça o que está congelado) | faz: `circulo_geada` (congela; o alcance vale) | faz: `passo_geada` | faz: `ultimo_geada` | faz: `floco_errante` |
| **Luz** | faz: `golpe_radiante` | faz: `pesado_radiante` | faz: `circulo_radiante` (dano do Brado) | parcial: `passo_radiante` (dano sim; a cura do domo, `dome_heal`, só a Maga lê) | **vazio** | **vazio** |
| **Vigília** | faz: `golpe_firme` (alcance e dano do golpe) | parcial: `pesado_firme` (dano sim; o alcance `reach_pct` não vale, porque o alcance da onda do Guerreiro é o da lâmina: `Combat.throw_wave`) | parcial: `circulo_firme` (alcance do Brado sim; `cast_size_pct` só serve ao círculo antigo e à Voragem, nada no Brado) | **vazio** | **vazio** | faz: `passos` (carga de esquiva e velocidade) |

**Resultado: 4 células vazias** (Luz no Shift e no Espaço, Vigília no E e no Shift) e 3 parciais por estatística que o Guerreiro não lê. Toda família tem efeito em algum botão,
mas Luz e Vigília ficam sem Bênção em 2 dos 6 lugares, e é aí que o jogador do Guerreiro com Q e E "sem retorno" sente falta (uma das queixas de `kits_review_2026-11-24.md`).

### 2.1 Como preencher as 4 células (só dado, sem código novo)

As quatro usam estatísticas e gatilhos que já existem (`SkillDef.Trigger.DODGE/RUSH/ULT`, `ult_charge_pct`, `damage_pct` com tag `ultimate`). Ids e nomes são
**provisórios**; os números copiam as Bênçãos irmãs e o `balance-designer` ajusta. Nenhuma carrega nome próprio nem lore.

| Id proposto | Família, slot | O que faz | Usa | Irmã de números |
|---|---|---|---|---|
| `ultimo_radiante` | Luz, ULT (Shift) | o Supremo causa mais dano e carrega mais rápido | `ultimate:damage_pct` e `ult_charge_pct` (as duas já são lidas: `Combat.hit_enemy` e `Ultimates`); sem habilidade própria | `pesado_radiante` (dano), Dom Tempestade Contida (carga 25%) |
| `ultimo_firme` | Vigília, ULT (Shift) | ao soltar o Supremo, chão firme sob o herói que prende quem fica | `SkillDef` kind CONSECRATE, status `slow`, trigger ULT | `ultimo_brasa` (gatilho), `firmeza` (CONSECRATE slow) |
| `passo_claro` | Luz, DASH (Espaço) | a esquiva deixa um anel de luz que fere em volta | `SkillDef` kind NOVA, trigger DODGE, intervalo 1 s | `floco_errante` (gatilho DODGE, intervalo 0,5 s) |
| `investida_firme` | Vigília, RUSH (E) | a Investida (ou o domo, na Maga) deixa chão firme que prende | `SkillDef` kind CONSECRATE, status `slow`, trigger RUSH | `pesado_brasa` (CONSECRATE, trigger SPECIAL) |

Aceite: com as quatro, a tabela da seção 2 não tem célula vazia. O `make_data.gd` precisa de 4 chamadas `_boon(...)` (slot e gatilho existem) e 4 pares de texto em `data/text_pt.tres`.
As cartas de Elo e as listas `requires_sets` não mudam.

**Tamanho do sorteio**: Luz e Vigília passam a ter 6 Bênçãos de botão (hoje 4 e 4 de 6 lugares), igual a Chama e Geada. Cuidado com o risco do `kits_review` item 7: carta de Q e E
passa a aparecer mais; o peso de "botão mais ocioso" é do `gameplay-engineer`, não daqui.

## 3. O que vira Dom e não Bênção

- **Fúria**: não volta. O "encaixe" que ela dava (Brado dá carga, cargas aceleram o golpe) é agora do ramo Ímpeto do Guerreiro, que é Dom e define o herói. Bênção define a partida.
- **Alcance da onda do Guerreiro** (`pesado_firme`): se o Daniel quiser que a Vigília alargue a onda, é Dom de Domínio (a onda já lê `wave_size_pct` com tag `heavy`; `onda_clara` da Luz
  faz isso e funciona). Para a Bênção, a correção barata é trocar o `reach_pct` por `wave_size_pct` com a mesma tag (dado, mexe nos dois heróis).
- **Brado ligado às Bênçãos de Chama** (`circulo_brasa` só detona queimadura de Bênção): ok como está; é a razão de "Brasa antes, Brado depois" ser uma combinação só do Guerreiro.

## 4. Maga elemental: 4 famílias x 5 botões e a travessia

As tags da Maga são as da tabela 1. Duas regras dela mudam o que uma Bênção faz:
- **A Geada (direito segurado) e a Convergência levam a tag `cast`**, então as Bênçãos de Q (`circulo_*`, com tag `cast`) também mudam a Geada e o Supremo, além do Arco.
- **Nenhum golpe da Maga leva `finisher` nem `spin`** (conferido em `_maga_tree`), e o tiro entra por `Combat.on_shot_hit` com `counts = false`.

| Família | Esquerdo (Centelha, Combustão) | Direito (Estilhaço, Geada) | Q (Arco Voltaico) | E (Suspensão) | Shift (Convergência) | Espaço (Passo) |
|---|---|---|---|---|---|---|
| **Chama** | faz: `golpe_brasa` põe a Queimadura de Bênção a cada Centelha, em paralelo à nativa (não reage) | faz: `pesado_brasa` só no Estilhaço (a Geada segurada dispara OMEGA, não SPECIAL) | parcial: `circulo_brasa` detona só queimadura de Bênção (vem de `golpe_brasa`) | faz: `redemoinho` | faz: `ultimo_brasa`; `circulo_brasa` também alcança a Convergência (tag cast) | faz: `passo_brasa` (rastro nas duas pontas do passo) |
| **Geada** | **nada**: `golpe_geada` lê a tag `spin` | **nada**: `toque_geada` pede `wave`, `blast` ou golpe contado, e o tiro da Maga não leva nenhum | parcial: `circulo_geada` congela; o alcance (`reach_pct`) não vale, o Arco tem alcance fixo | faz: `passo_geada` | faz: `ultimo_geada` | faz: `floco_errante` |
| **Luz** | faz: `golpe_radiante` | faz: `pesado_radiante` | faz: `circulo_radiante` (também na Geada e na Convergência) | parcial: `passo_radiante` (a cura do domo vale; `dash:damage_pct` não, o domo não fere) | **vazio** (só `circulo_radiante` de carona, por `cast`) | **vazio** |
| **Vigília** | faz: `golpe_firme` (o tiro voa mais longe, mais dano) | faz: `pesado_firme` (alcance vale na Maga: `throw_wave` soma `reach_pct` quando há `arcane`) | parcial: `circulo_firme` (alcance não; `cast_size_pct` alarga a Convergência, até o teto 6,5 m) | **vazio** (a Bênção solta `escudo` dá escudo ao domo, mas sem botão) | **vazio** | faz: `passos` |

### 4.1 Bênçãos que não fazem nada para a Maga (no sorteio hoje, fora da reserva)

**Nada, por estatística que ela nunca lê:**
1. `golpe_geada` (Geada, esquerdo): lê `spin`, tag do giro do Guerreiro. Nada na Maga leva `spin`.
2. `toque_geada` (Geada, direito): `shatter_pct` só vale com `wave`, `blast` ou golpe contado; o Estilhaço leva `bolt, arcane, ice`. **Conserto de dado**: dar a tag `wave` ao Estilhaço
   em `_maga_tree` (a Cristalização já deixa `frozen_t` nos inimigos, então o estilhaçar passa a funcionar); conferir antes que nenhuma Bênção com `wave` mude o Estilhaço
   por acidente além de `onda_clara`, que é desejada.
3. `final_radiante` (Luz) e, nos anjos, `golpe_certeiro` (Marca) e `final_veu` (Véu): leem `finisher`; a Maga não tem golpe com essa tag. Nenhum conserto barato: são "de espada".

**Parcial (a metade que a Maga não lê):**
- `circulo_geada`, `circulo_firme`: o alcance de Q (`cast:reach_pct`) não vale no Arco. `circulo_firme` mantém a Convergência maior.
- `passo_radiante`: o dano de E não vale (domo não fere); a cura vale.
- `circulo_brasa`: só detona a queimadura de Bênção.
- `pesado_brasa`: dispara só com o Estilhaço, não com a Geada segurada.

**Leem o que ela tem e funcionam** (para não confundir com o acima): `golpe_brasa`, `golpe_radiante`, `golpe_firme`, `pesado_radiante`, `pesado_firme`, `circulo_radiante`, `redemoinho`,
`passo_geada`, `passo_brasa`, `floco_errante`, `passos`, `ultimo_brasa`, `ultimo_geada`; as de Elo `cinza_viva` (light), `nevoa_gelida` e `olho_firme` (heavy), `mare_ardente` (cast), `correnteza` (dash, o aro do domo empurra); e as de Ômega dos anjos (`omega_veu`, `omega_mare`, `omega_marca`), porque Combustão e Geada levam `omega`.

**Cartas só de anjo (nota)**: no Guerreiro e na Maga funcionam por tag (`golpe_veu` light, `pesado_mare` heavy, `circulo_marca` cast, `passo_veu` dash...). Só as de `finisher`
são mortas para a Maga.

### 4.2 Células vazias da Maga e o que fazer

As mesmas quatro do Guerreiro (Luz Shift e Espaço, Vigília E e Shift): as 4 Bênçãos da seção 2.1 as preenchem **sem código**, porque o gatilho da Maga é o mesmo:
`passo_claro` (DODGE, `Game._on_dodged` dispara para os dois), `investida_firme` (RUSH, o domo dispara por ter a tag `dash`), `ultimo_*` (ULT, `Player.ult_landed`). Fica só
a revisão do `balance-designer` para o quanto o `ultimo_radiante` vale com a Convergência (o dano da Convergência é de 90 em 4,5 s).

## 5. A decisão do `bless_cross` (R4) na Maga

**O que o código faz hoje**: o campo `bless_cross` **não existe** (`grep` em `scripts/`, `tools/` e `tests/` só acha o plano). A separação é de construção: a Queimadura e o Frio
nativos vivem no `ElementBook` e as da Bênção em `e.burn_t`, `e.frozen_t`, `e.slow_t`; não se leem. Duas pontes já existem sem querer: (1) a Cristalização escreve `e.frozen_t`
(`arcane.gd:189`), então Bênção que age sobre o inimigo "congelado" (`shatter`, dano em congelado) vê a reação da Maga; (2) a Convergência aplica os elementos nativos por
`Arcane.apply_element`, e as Bênçãos `cast` de Chama e Geada aplicam os delas pelo mesmo golpe, os dois em paralelo.

**Efeito no jogador**: Maga com `golpe_brasa` põe duas queimaduras sobre o mesmo inimigo (a nativa pelo 3º acerto da Centelha, a da Bênção a cada tiro), com números e pips
diferentes, e **nenhuma das duas reage com o Frio da outra**. É o que o R4 temia: "Bênção de Chama não combina com a Maga".

**Número do QA**: **não existe**. Nenhum relatório de `docs/qa/` mede reações da Maga com Bênção de Chama ou Geada, e o `Arcane.tally` já conta reações (`thermal`, `overload`, `crystal`, `reactions`), mas o `RunLog` não as grava (`grep` em `run_log.gd`). Recomendo registrar a decisão assim:

1. **Esta rodada: manter separado** (é o que já roda e o que o plano chamou de decisão segura). Nenhum código.
2. **Medir antes de mudar** (`balance-designer`, 12 sementes, `--smoke` com a Maga e `--boons=N`): por partida, reações nativas disparadas, quantas com `golpe_brasa` ou
   `circulo_geada` em jogo, e a mediana de dano por sala com e sem elas. Se Chama e Geada derem **menos** de ~10% a mais de dano do que Luz ou Vigília na Maga, o cruzamento vale.
3. **Se vale, não como chave global**: como **Dom** de Elementalismo (por exemplo um Ápice "o fogo de fora também conta"), porque "Dom define o herói": a Queimadura de Bênção passa a
   chamar `Arcane.apply_element(e, FIRE)` e o congelamento de Bênção `apply_element(e, ICE)`, uma vez por golpe, sem aplicar estado novo e sem cadeia. Custo: **P** (duas chamadas em
   `Combat._burn` e `_freeze`, um stat novo `bless_cross` lido pelo `Arcane`, 1 teste). Não exige tocar nas Bênçãos.
4. Até lá, a carta de Chama e Geada na Maga mostra o texto da Bênção como está (Queimadura de Bênção). Não prometer reação no texto.

## 6. Resumo para quem implementa

| Item | Onde | Tamanho |
|---|---|---|
| 4 Bênçãos que fecham as células vazias (Luz Shift e Espaço, Vigília E e Shift), por dado | `tools/make_data.gd` (`_boon`), `data/text_pt.tres` | P |
| Tag `wave` no Estilhaço (revive `toque_geada` na Maga); conferir `onda_clara` e o brilho do tiro | `tools/make_data.gd` (`_maga_tree`) | P (dado) |
| `pesado_firme` e `circulo_firme`: trocar a estatística morta (`reach_pct` da onda do Guerreiro, `cast_size_pct` do Brado) por uma que o herói lê | `tools/make_data.gd` | P (dado) |
| `bless_cross` como Dom (opcional, depende da medida) | `Arcane`, `Combat._burn/_freeze` | P |
| Gravar o `Arcane.tally` (reações) no `RunLog` junto das Bênçãos da partida (para ter o número) | `RunLog`, `Arcane` | P |

## 7. Perguntas ao Daniel

1. As 4 Bênçãos novas (Luz e Vigília no Shift, Luz no Espaço, Vigília no E) entram agora, já com nomes provisórios que você aprova depois?
2. `pesado_firme` e `circulo_firme` podem trocar o que lêem (alcance da onda e do Brado) para algo que os dois heróis usam?
3. O cruzamento de Chama e Geada com as reações da Maga fica separado nesta rodada e vira Dom se a medida pedir (recomendo)?
