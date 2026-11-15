# Sistemas do Hades II que faltam em A Selagem

Para que serve: levantar com precisão as regras e os números do Hades II nos sistemas que ainda não temos e propor
como cada um entraria em Eterra, antes de implementar. Decisão do Daniel: do Hades II copiamos as mecânicas e os
números, fielmente, como base; nomes e temas são nossos (`docs/design/comparativo.md`).

Todos os nomes de Eterra abaixo são **sugestões** para o Daniel decidir. Nenhum deles cria lore: são descritivos.

## Fontes

Duas fontes, nesta ordem de confiança:

1. **Os dados do próprio jogo**, na cópia do Daniel (Steam, build 25481925, novembro de 2026). As citações de arquivo e
   linha ficam só na cópia local deste documento (fora do repositório público). Só lemos números e regras; nada do jogo é
   copiado para o repositório.
2. **A wiki do Hades na Fandom**, lida pela API (`https://hades.fandom.com/api.php`, páginas citadas pelo endereço
   normal). A wiki.gg (`hades2.wiki.gg`) bloqueia leitura automática; não foi usada.

Guias de terceiros (Game8, Switchblade, Mobalytics) só aparecem como apoio. Onde fonte e dado divergem, vale o dado do
jogo e a divergência fica marcada **a confirmar**.

## Resumo dos números (o que mais importa)

| Sistema | Número do Hades II | Fonte principal |
|---|---|---|
| Romã | +1 nível (grande +2, tripla +3); escolhe 1 de até 3 dons; loja 100 (fatia 50, grande 300) |  |
| Curva por nível | cada dom tem o ganho por nível fixo (`AbsoluteStackValues`), o último se repete; raridade não muda o ganho |  |
| Raridade | rara 10%, épica 5%, heroica só por troca/melhoria; padrão 1 / 1,3 a 1,5 / 1,8 a 2 / 2,3 a 2,5 |  |
| Duplos | 37 (9 deuses, um por par e mais um); 12% por carta; um dom de cada deus |  |
| Lendários | 11 (10 olímpicos e Caos); 10% por carta; um dom de cada um de três grupos do mesmo deus |  |
| Infusões | 11; aparecem com 1 a 4 de um elemento e ativam com 2 a 8 |  |
| Martelo | no máximo 2 por partida; o 2º só depois da 2ª região; 3 opções; loja 200 |  |
| Caos | portal com 20% de chance por sala; custa `teto(10 + 0,5 x profundidade)` de vida; maldição dura 3 a 5 encontros |  |
| Selene | 1 feitiço por partida (3 opções); pronto depois de gastar 30 a 130 de Magia; Caminho das Estrelas dá 1, 3 ou 5 pontos | wiki `Selene/Gifts_of_the_Moon` |
| Arcana | 25 cartas; Fôlego 10 até 30; custo 0 a 5 por carta | wiki `Arcana_Cards` |
| Votos | 17 votos, Medo máximo 67 | wiki `Oath_of_the_Unseen`, `Fear` |
| Ouro | 10 a 15 por encontro + 0,5 por sala de profundidade; recompensa de ouro 100 |  |

## Um achado sobre o que já temos

O baralho de recompensas e a raridade do Hades II funcionam um pouco diferente do que fizemos:

- **Raridade é sorteio em sequência, não peso.** Para cada carta o jogo começa em Comum e tenta Rara, depois Épica,
  depois Duplo, depois Lendário, cada um com a sua chance; o último que passar vale (,
  ordem em ). Com rara 10% e épica 5%, dá 85,5% comum, 9,5% rara e 5% épica, perto dos nossos pesos
  `RARITY_WEIGHT` (85/10/5/0). Heroica nunca sai no sorteio.
- **O guardião não dá heroica.** O guardião do Érebo troca as chances por `Legendary = 0.05, Epic = 0.07, Rare = 0.90`
  : os 5% são de **lendário**, não de heroico. Nosso `RARITY_WEIGHT_GUARDIAN` (0/90/7/5) põe 5 em
  HEROIC. Também não é "nunca comum": pelo sorteio em sequência, sai comum em 9,3% das cartas.
- **As recompensas das portas saem de um baralho, não de pesos.** O baralho da partida (`RunProgress`,
  ) tem 2 corações, 2 tônicos de Magia, 2 de ouro, 2 romãs, 2 martelos (com as regras do
  martelo), 1 Hermes, 1 Selene, 1 Caminho das Estrelas, 1 sala de duas divindades e 4 dons. Cada porta tira uma carta
  sem repor; quando não sobra carta válida, o baralho é reabastecido . Isso garante variedade
  sem repetir demais. Nós usamos pesos (`reward_weights` em `_stage`).

---

## 1. Romã (Pom of Power)

### Como é no Hades II

- **Níveis por romã.** A romã comum dá **+1 nível** (`StackNum` padrão 1, ). Existem a
  romã grande, **+2** (`StackUpgradeBig`, ), e a tripla, **+3** (`StackUpgradeTriple`,
  ). A grande aparece na loja da segunda metade da partida por **300** de ouro
  ; a tripla está no baralho de recompensas do Tártaro e do chefe Tífon .
  A Mobalytics fala em "três variações, +1, +2 e +3", o que bate com os dados.
- **Como se escolhe.** Abre a tela de escolha com **até 3** dons que podem subir (`MaxChoices = 3`,
  ; lista em `GetEligibleUpgrades`, ). O jogador escolhe um.
  A tela mostra "nível antigo e nível novo" .
- **Fatia de romã** (`StoreRewardRandomStack`): +1 nível num dom sorteado, sem escolha, **50** de ouro
  .
- **Quem não sobe.** Duplos, lendários e infusões têm `BlockStacking` ; dons de Caos e
  alguns de apoio também não. A romã só aparece se houver pelo menos 1 dom que suba (`StackUpgradeLegal`,
  ).
- **Onde aparece.** Duas cartas de romã no baralho de recompensas das portas (uma só depois do primeiro dom de deus)
  ; na loja do Caronte por **100** , no mesmo grupo que tônico de Magia,
  fatia, Selene e Caminho das Estrelas (um item sai de cada grupo). Wiki: https://hades.fandom.com/wiki/Pom_of_Power/Hades_II
  (preço 100). Game8 confirma 100: https://game8.co/games/Hades-2/archives/453894
- **Como os números crescem (as curvas).** A fórmula está em `GetProcessedValue` :
  - nível 1: `valor_base x multiplicador_de_raridade`;
  - cada nível acima soma um ganho **que não depende da raridade**:
    - quase todo dom tem a lista `AbsoluteStackValues`: o ganho do nível 2, do 3, do 4...; **o último valor se repete**
      para sempre;
    - alguns usam `IdenticalMultiplier`: o nível `n` soma `base x (1 + M) x 0,5^(n-2)`, com piso de `0,1 x base`
      (`TraitMultiplierData`, ). Com M = -0,6 (o padrão `DuplicateMultiplier`) os ganhos são
      +40%, +20%, +10%, +10%... da base.
  - Exemplos lidos nos dados:

| Dom (Hades II) | Nível 1 (comum) | Ganho por nível (2, 3, 4...) | Fonte |
|---|---|---|---|
| Golpe de Ares (ataque) | +20% de dano | +10%, depois +5% sempre | `AresWeaponBoon` |
| Golpe de Deméter (ataque) | +30% | +15%, +10%, depois +5% sempre | `DemeterWeaponBoon` |
| Golpe de Afrodite (ataque, perto) | +80% | +25%, +15%, depois +10% sempre | `AphroditeWeaponBoon` |
| Golpe de Héstia (queimadura) | 30 | +15, +10, +10, +10, depois +5 sempre | `HestiaWeaponBoon` |
| Golpe de Zeus (eco) | 80 de dano | +20, depois +15 sempre | `ZeusWeaponBoon` |

  O padrão: o 2º nível vale cerca de metade da base, o 3º cerca de um terço, e daí em diante um ganho pequeno e fixo.
  Raridade e nível somam por fora: uma épica de nível 3 é `base x 2 + ganho2 + ganho3`.
- Wiki (Hades I) descreve a mesma ideia, "metade a cada 2 níveis até o 6, depois linear":
  https://hades.fandom.com/wiki/Pom_of_Power . **A confirmar**: a lista de quais dons do Hades II não sobem por romã
  (a wiki não tem a lista do II).

### Como entraria em A Selagem

- Nome sugerido: **Brasa da Vigília**, ou **Óleo da Lamparina** (subir o nível = avivar a chama). A grande seria
  "Brasa Viva" (+2).
- Já temos a recompensa `R.POM`, a tela de subir (`open_grow_choice`) e o preço 100. O que muda é **a curva**: hoje cada
  `BoonMod` tem `values` com 3 entradas (níveis 1 a 3, `max_level := 3`) e a raridade multiplica o valor inteiro.
- Dados novos:
  - `BoonMod.base: float` (o nível 1, multiplicado pela raridade) e `BoonMod.per_level: PackedFloat32Array` (os ganhos
    dos níveis 2, 3, 4...; o último se repete; não multiplicados pela raridade). Some `max_level`: o nível não tem teto.
    O mesmo para os números de `SkillDef` (dano, raio, recarga).
  - `Boon.can_level := true` (false nos Elos, lendários, infusões e Provação).
  - `RewardDeck` (Resource) em `StageDef`: lista de `RewardCard` (`reward`, `after_first_boon: bool`, `count`), no lugar
    de `reward_weights`, tirada sem repor como o `RunProgress`.
  - `RunMap.Reward.POM_BIG` (+2) para a loja da segunda metade, 300.
  - Fatia (`R.POM_SLICE`, +1 num dom sorteado, 50) na loja.
- Converter os 32 dons de `_boons` para `base` e `per_level` copiando a forma das curvas acima (ex.: `golpe_radiante`
  de `[0.25, 0.4, 0.55]` para `base 0.25, per_level [0.125, 0.0625]`, no molde do Ares).
- Testes: curva de valor por nível com raridade, romã sem dom que suba não aparece, baralho reabastece.

**Esforço:** médio. **Prioridade:** alta (é o sistema que mais muda a sensação de crescer na partida).

---

## 2. Raridades

### Como é no Hades II

- **Chances base por carta** (`BoonData.RarityChances`, ): rara **10%**, épica **5%**, duplo
  **12%**, lendário **10%**. Hermes: rara 6%, épica 3%, lendário 1% . Romã e martelo saem
  sempre comuns (`ForceCommon`, ). Tabela igual na wiki:
  https://hades.fandom.com/wiki/Boons/Hades_II (seção "Rarity Appearance Chance").
- **Sorteio em sequência** comum, rara, épica, duplo, lendário; o último que passar vale .
  **Heroica não sai no sorteio**: vem da **troca** (oferta de outro deus para um espaço já ocupado, que entra com +1 de
  raridade e o mesmo nível, 10% de chance por carta, `ReplaceChance = 0.1`, ,
  ) e de efeitos que sobem raridade.
- **Multiplicadores.** O padrão (`BaseTrait`, ): comum 1,0; rara sorteada entre **1,3 e 1,5**;
  épica entre **1,8 e 2,0**; heroica entre **2,3 e 2,5**. Muitos dons fixam a sua própria tabela: 1 / 1,5 / 2 / 2,5
  (Ares, Deméter, Héstia), 0,8 / 1,2 / 1,6 / 2,0 sobre uma base 1,0 (Zeus, o que dá 80/120/160/200 na wiki), 1 / 1,25 /
  1,5 / 1,75 (Afrodite).
- **Guardião** (minichefe): rara 90%, épica 7%, lendário 5% no Érebo ; a tabela por região está na
  wiki (Tártaro e Olimpo sobem duplo e lendário para 20%).
- **O que aumenta as chances:** cartas de Arcana Excelência (+30/40/50/60% de rara ou lendário), Rainha (+6/8/10/12% de
  duplo), Divindade (+10/15/20/25% de épica); a bênção Favor do Caos (rara +40% a +100%, épica +10%, lendário +10%); o
  Fio de Ariadne do Poço de Caronte (+100% rara, +25% épica, +10% lendário numa carta). Fonte: wiki `Boons/Hades_II`
  (seção "Rarity Modifier") e https://hades.fandom.com/wiki/Arcana_Cards . Os bônus somam às chances
  (`GetRarityChances`, ).

### Como entraria em A Selagem

- Nomes: comum, rara, épica, heroica (já estão em `text_pt.tres`).
- Trocar os pesos por chances em sequência: `Boon.RARITY_CHANCE` (rara 0,10, épica 0,05) e
  `StageDef.guardian_rarity` (rara 0,90, épica 0,07, lendário 0,05). Corrige o 5% que hoje vai para heroica.
- `Boon.rarity_mult: PackedFloat32Array` por dom (padrão `[1, 1.5, 2, 2.5]`), para copiar as tabelas próprias.
  A faixa sorteada (1,3 a 1,5) fica de fora por KISS; **a confirmar com o Daniel** se vale o sorteio.
- Heroica pela **troca**: com 10% de chance, uma carta oferece substituir o dom de um espaço ocupado com +1 de raridade
  e o mesmo nível. Já temos "um dom por ação"; falta a oferta com a raridade subida.
- Campo `rarity_bonus` (por raridade) nos dados que dão bônus (cartas, Provação), somado em uma função pura.

**Esforço:** pequeno. **Prioridade:** alta (corrige um número e prepara Elo e lendário).

---

## 3. Dons duplos (Elo)

### Como é no Hades II

- **37 dons duplos** (37 entradas `SynergyTrait`), entre **9 deuses** (Afrodite, Apolo, Ares,
  Deméter, Hefesto, Hera, Héstia, Posêidon, Zeus): **um para cada par** (36 pares) e mais um. Fonte da contagem também na
  wiki: https://hades.fandom.com/wiki/Duo_Boons/Hades_II . **A confirmar** qual par tem dois.
- **Requisito:** ter **um dom de cada lista**, uma lista por deus (`OneFromEachSet` com 2 listas, 
  `LinkedTraitData`); normalmente a lista é o ataque, o especial, o círculo, a corrida ou um dom de apoio específico.
- **Chance:** 12% por carta, quando o requisito está cumprido ; 20% no guardião do Tártaro, Olimpo e
  Cume (wiki). Pode vir de qualquer um dos dois deuses.
- Não sobem com romã (`BlockStacking`), contam como o elemento **Éter** (`SynergyTrait` herda `AetherBoon`,
  ) e ficam fora do sorteio normal (a wiki diz que o Voto da Negação não aumenta a chance deles).

### Como entraria em A Selagem

- Nome: **Elo** (já decidido). Temos 6 Elos, um por par das 4 famílias: proporção igual à do Hades II (um por par).
- Dados novos: `Boon.requires_sets: Array[PackedStringArray]` (uma lista por família, como `OneFromEachSet`) no lugar de
  `requires` (que hoje exige dons exatos). Ex.: Vapor = um dom de Chama da lista [brasas, golpe_brasa, pesado_brasa,
  circulo_brasa] e um de Geada da lista [toque_geada, golpe_geada, circulo_geada, passo_geada].
- Chance de 12% por carta (`Boon.ELO_CHANCE`), sorteada depois da épica; não sobe com romã; conta como a 5ª afinidade
  (ver Infusões).

**Esforço:** pequeno. **Prioridade:** alta (o Elo já é o próximo passo do `comparativo.md`).

---

## 4. Lendários

### Como é no Hades II

- **11 lendários**: um de cada deus olímpico com lendário (Afrodite, Apolo, Ares, Deméter, Hefesto, Hera, Hermes,
  Héstia, Posêidon, Zeus) e um do Caos. Wiki:
  https://hades.fandom.com/wiki/Legendary_Boons/Hades_II
- **Requisito:** um dom de **cada um de três grupos** daquele deus (`OneFromEachSet` com 3 listas; ex. Zeus em
  : um dom principal, um de raio, um de eco). Hermes pede um dom qualquer dele; Caos, outra
  bênção do Caos.
- **Chance:** 10% por carta (Hermes 1%, Caos 5%); guardião 5% a 20% por região. Não sobem com romã; custo de troca 120
  (`LegendaryTrait`, ).

### Como entraria em A Selagem

- Um lendário por família: 4 ao todo, cada um um efeito grande e único (proposta de efeitos para o Daniel aprovar, com
  estatísticas que já existem: ex. Chama, toda queimadura espalha ao matar; Geada, o congelado que morre estilhaça
  em onda; Luz, cada finalizador solta o leque de luz; Vigília, o escudo volta a cada sala).
- Dados: `Boon.Kind { CORE, SUPPORT, ELO, LEGENDARY, INFUSION }` (substitui o `Family.DUO` como marcador de tipo),
  `requires_sets` com 3 listas, chance 10%. Cor e moldura própria na carta.
- Um lendário que pede mecânica nova exige código; os que só combinam estatísticas existentes, não.

**Esforço:** médio. **Prioridade:** média (depois de romã e Elo, quando houver mais dons por família).

---

## 5. Infusões elementais

### Como é no Hades II

- **Elementos:** Fogo, Água, Terra, Ar (os quatro de base) e Éter (`TraitElementData`, ).
  Cada dom tem um ou dois elementos pelo deus; todo duplo é Éter. **Conta-se 1 por dom** que tem o elemento
  (`CurrentRun.Hero.Elements`). Dons de Selene, Caos e Hades não contam. Wiki:
  https://hades.fandom.com/wiki/Infusion
- Desbloqueio: o encantamento "Adivinhação dos Elementos" (5 de Psique, depois de enfrentar Cila e falar com Zeus).
- **11 infusões** (10 de deuses em  e uma do Caos). Cada uma tem **duas regras**: o mínimo
  para **aparecer** (`GameStateRequirements`) e o mínimo para **valer** (`ActivationRequirements`):

| Infusão (deus) | Aparece com | Vale com | Efeito | Fonte |
|---|---|---|---|---|
| Tall Order (Hermes) | 4 do maior elemento | 8 do maior | +25% de dano |  |
| Proper Upbringing (Hera) | 1 de cada base | 2 de cada base | dons comuns sobem de raridade | `:64-150` |
| Martial Art (Hefesto) | 2 Terra | escala | +5% ataque e especial por Terra | `:151-226` |
| Rallying Cry (Ares) | 4 Terra | 8 Terra | +50% no dano dos dons | `:227-280` |
| Slow Cooker (Héstia) | 2 Fogo | escala | +2 de poder por Fogo | `:281-348` |
| Self Healing (Apolo) | 2 Fogo | 3 Fogo | cura ao levar dano | `:349-404` |
| Air Quality (Zeus) | 3 Ar | 5 Ar | dano mínimo por golpe | `:405-447` |
| Wispy Wiles (Afrodite) | 2 Ar | escala | chance de esquiva por Ar | `:448-510` |
| Frosty Veneer (Deméter) | 4 Água | 6 Água | teto de dano por golpe | `:511-562` |
| Water Fitness (Posêidon) | 2 Água | escala | +15 de vida por Água | `:563-` |
| Chant (Caos) | Éter | escala | +30% nos Ômega por Éter | wiki `Boons/Hades_II` |

- Divergências **a confirmar**: Air Quality, dado 50 e wiki 30 de dano mínimo; Wispy Wiles, dado 2% e wiki 3% por Ar.
- Infusões são sempre comuns, não sobem com romã e não são afetadas por bônus de raridade (`UnityTrait`,
  ).

### Como entraria em A Selagem

- Nossos "elementos" são as **famílias**: Chama, Geada, Luz, Vigília, e o Elo faz o papel do Éter. Nome sugerido para a
  contagem: **Afinidade** (ex.: "3 de Afinidade da Chama"); para a infusão, **Ressonância**.
- Dados: `Boon.affinities: Array[Boon.Family]` (padrão: a própria família; Elo conta as duas e o Elo), e
  `InfusionRule` (Resource) com `family`, `offer_min`, `active_min` e `per_affinity` (o `BoonMod` que escala pela
  contagem). Uma função pura `Affinity.count(boons)` com teste.
- Com 4 famílias e cerca de 8 dons cada, os limiares do Hades II (2 a 8) servem quase sem mudar: propor 2 para aparecer e
  3 a 5 para valer, no molde de Self Healing e Air Quality.

**Esforço:** médio. **Prioridade:** baixa (precisa de mais dons por família para fazer sentido).

---

## 6. Martelo de Dédalo

### Como é no Hades II

- **Quantos por partida: no máximo 2.** O 1º só se a partida ainda não teve martelo (`HammerLootRequirements`,
  ); o 2º só depois de entrar em mais de 2 regiões e tendo exatamente 1 martelo
  (`LateHammerLootRequirements`, ). Há 2 cartas de martelo no baralho de recompensas
  ; não sai em salas fáceis do caminho (`HubCombatRoomEasyBans`, ).
  Guias dizem o mesmo ("quase sempre dois"): https://mobalytics.gg/hades-2/guides/resources
- **Loja:** 200 de ouro (`WeaponUpgradeDrop`, ), no grupo de cura, coração e armadura.
- **Escolha:** 3 opções (`MaxChoices = 3`), sempre comuns (`WeaponData.ForceCommon`). Cada arma tem a sua lista (o
  cajado tem 28 entradas na wiki: https://hades.fandom.com/wiki/Witch%27s_Staff ); algumas se excluem (ex.: duas que
  reescrevem o mesmo golpe). Exemplos do cajado: ataque +30 de poder; especial dispara 2 projéteis com -40% de alcance;
  Ômega do ataque +50% de dano e também para os lados.
- Desbloqueio: depois de pegar dons de 4 dos deuses olímpicos pela primeira vez (`HammerLootRequirements`).

### Como entraria em A Selagem

- Nome sugerido: **Lapidação da Emeth** (a esmeralda da espada é lapidada; muda a lâmina, não o paladino). Alternativa
  neutra: "Forja".
- Dados: `WeaponUpgrade` (Resource) com `id`, `mods: Array[BoonMod]`, `node_overrides` (troca de campos de
  `ComboNode` em `data/combos/paladin.tres`: alcance, número de cortes, dano, avanço), `excludes: Array[StringName]`.
  Lista em `data/upgrades/emeth/*.tres`.
- Regras no `RunMap`: carta `R.HAMMER` no baralho, no máximo 2 por partida; com a região única de teste, o 2º a partir da
  metade da descida (**a confirmar com o Daniel**).
- Precisamos de umas 8 a 10 lapidações para a Emeth (o Hades II tem de 6 a 9 por aspecto).

**Esforço:** médio a grande (cada lapidação mexe em golpes; parte vira dado, parte exige código novo em `ComboNode`).
**Prioridade:** média.

---

## 7. Caos (bênção com maldição)

### Como é no Hades II

- **Como se entra:** um portal no chão aparece ao limpar a sala, com **20% de chance** por sala elegível
  (`SecretSpawnChance = 0.2`, ); nunca na antessala nem na sala do chefe, nem no Tártaro, em Éfira ou
  no Cume , e nunca com outro portal nas últimas **10 salas** (`NoRecentChaosEncounter`,
  ). Entrar custa vida: **`teto(10 + 0,5 x profundidade)`**
  (`GetSecretDoorCost`, ); não entra quem tem essa vida ou menos .
  Os guias divergem ("10 ou mais", "pelo menos 15"); o dado resolve.
- **A bênção:** cada oferta junta uma **maldição** e uma **bênção** sorteadas. A maldição dura um número de encontros e
  depois vira a bênção para o resto da partida. A raridade só afeta a bênção. Bênçãos repetidas somam. Não sobem com
  romã. Wiki: https://hades.fandom.com/wiki/Chaos/Boons_(Hades_II)
- **Duração da maldição:** o padrão é **3 a 5 encontros** (`RemainingUses BaseMin 3, BaseMax 5`,
  ); algumas contam salas (4 a 6, `:811-817`) e as que contam dons, 2 a 3 ou 2 a 4
  (`:1011,1100`). Exemplos (wiki): sem ouro por 3/5 encontros; -20/-29 de vida máxima; +20%/+50% de dano recebido;
  3/6 de vida por ataque usado; os próximos 2/3 dons só comuns.
- **Exemplos de bênção (wiki):** ataque +20% a +50% (comum), +30% a +75% (rara), +40% a +100% (épica), +50% a +125%
  (heroica); especial +30% a +60% (comum); vida +26 a +35 (comum). Chances do Caos: rara 40%, épica 10%, lendário 5%.

### Como entraria em A Selagem

- Sem divindade nova: proposta **Provação**. Uma porta selada no chão das catacumbas; quem paga com vida aceita uma
  provação (a maldição) que, vencida, vira recompensa (a bênção). Cabe na alegoria sem criar personagem.
  **A confirmar com o Daniel** (tema e se a porta precisa de um dono).
- Dados: `TrialCurse` (Resource: `mods`, `duration_min`, `duration_max`, `counts`: encontros, salas ou dons) e
  `TrialBlessing` (Resource: `mods` com faixa por raridade, `value_min` e `value_max`). Combinação sorteada em código,
  conteúdo em `data/trials/*.tres`. `StageDef.trial_chance := 0.2`, `trial_cooldown_rooms := 10`,
  `trial_cost_base := 10`, `trial_cost_per_depth := 0.5`.
- Com a descida de teste de 5 salas, 20% por sala dá pouca chance de ver; para teste, `--start` ou `trial_chance` maior.

**Esforço:** médio. **Prioridade:** média para baixa.

---

## 8. Selene: feitiço (Hex) e Caminho das Estrelas

### Como é no Hades II

- **O feitiço:** a primeira recompensa de Selene oferece **3 feitiços** e o jogador fica com **um por partida**
  (wiki https://hades.fandom.com/wiki/Selene/Gifts_of_the_Moon ). Ele **carrega gastando Magia** (usar os Ômega): fica
  pronto depois de gastar 30 a 130 de Magia, conforme o feitiço: Lunar Ray 30, Twilight Curse 40, Wolf Howl 50,
  Night Bloom 60, Sky Fall 60, Moon Water 70, Total Eclipse 90, Dark Side 110, Phase Shift 130 (wiki, mesma página).
- **Onde aparece:** a carta de Selene sai uma vez por partida (`SpellDropRequirements`; uma carta no baralho,
  ) e na loja por **100** .
- **Caminho das Estrelas:** cada recompensa seguinte de Selene dá pontos para a árvore do feitiço escolhido: **3** na
  normal, **1** na fraca (Campos de Luto), **5** na brilhante (Tártaro, Cume). Cada feitiço vem com um brilho de lua que
  soma pontos na próxima: cheia +2, meia +1, crescente 0. A árvore tem 4 desenhos sorteados por noite e nós de três
  níveis (comum, "Bright" e "Sublime"). Ex. de nós do Phase Shift: carrega sozinho como se gastasse 1 de Magia por
  segundo; começa a sala 40% carregado; dura +0,5 s.
- O Caminho sai **uma vez por região, a partir da 2ª** (`TalentDrop`, ) e na loja por **60**
  .
- Versão "Godsent" (equivalente ao duplo): exige ter um dom do deus ligado àquele feitiço.

### Como entraria em A Selagem

- Sem divindade: proposta **Invocação** (o paladino ergue a Emeth e chama a luz de Elun) e **Caminho da Vela** ou
  **Constelação** para a árvore. **A confirmar com o Daniel**: o que é teologicamente certo dizer aqui (é a luz de Elun
  agindo; não pode parecer magia própria).
- Dados: `InvocationDef` (Resource: `magick_to_ready`, efeito por `SkillDef`, `nodes: Array[StarNode]`) e `StarNode`
  (Resource: `tier`, `mods`, `requires: Array[StringName]` na árvore). Nova ação na entrada (`invoke`) e um medidor no HUD.
- Como só temos uma região, o Caminho viria a partir da metade da descida (**a confirmar**).

**Esforço:** grande (ação nova, medidor, árvore e tela). **Prioridade:** baixa por enquanto.

---

## 9. Progressão entre partidas

### Como é no Hades II

**Cartas de Arcana** (https://hades.fandom.com/wiki/Arcana_Cards):

- 25 cartas numa grade 5 x 5; no começo **9 visíveis**; pegar uma revela as vizinhas.
- **Desbloqueio com Cinzas**, de 1 a 50 (ex.: Feiticeira 1, Filho Pródigo 3, Morte 25, Julgamento 50 e 1 Pena).
- **Fôlego (Grasp):** cada carta custa 0 a 5 de Fôlego para ficar ativa; o limite começa em **10** e sobe com Psique até
  **29**; o 30º pede 500 de Psique, 2 Sombras e 2 Escuridão. Total de todas as cartas: 56. Seis montagens guardadas.
- Cartas de custo 0 se ativam por regra (ex.: Lua, ative qualquer vizinha; Rainha, no máximo 2 cartas de mesmo custo).
- Cada carta sobe até épica com Pó Lunar (rara e épica), sem mudar o custo.
- Exemplos: Persistência (+20/30/40/50 de vida e de Magia, custo 2), Morte (+1/2/3/4 desafios à morte, custo 4),
  Barqueiro (+200/250/300/350 de ouro, custo 5), Excelência (+30% a +60% de rara ou lendário, custo 5).

**Encantamentos no caldeirão** (https://hades.fandom.com/wiki/Incantations): cerca de 90 (86 entradas em
94 linhas na wiki; **a confirmar**). Custam recursos coletados (ex.: Adivinhação dos Elementos,
5 de Psique, ) e **ligam sistemas**: infusões, poços de Caronte, poço de purificação,
melhorar Arcana, mais votos.

**Recursos coletados:** Cinzas (cartas), Psique (Fôlego e encantamentos; https://hades.fandom.com/wiki/Psyche ), Pó
Lunar (melhorar cartas), Pesadelo (aspectos das armas, 118 no total; https://hades.fandom.com/wiki/Nightmare ), ossos,
plantas, minérios, peixes (ferramentas de coleta). O ouro se perde ao voltar
(https://hades.fandom.com/wiki/Gold_Crowns ).

**Votos da Noite e Medo** (https://hades.fandom.com/wiki/Oath_of_the_Unseen ): só depois de vencer Cronos uma vez.
17 votos, **Medo máximo 67** (https://hades.fandom.com/wiki/Fear ). Medo por nível entre parênteses:

| Voto | Efeito por nível | Medo |
|---|---|---|
| Dor | inimigos +20% / +60% / +100% de dano | 1, 2, 2 (5) |
| Firmeza | inimigos +10% / +20% / +30% de vida | 1, 1, 1 (3) |
| Proteções | inimigos com 1 / 2 escudos | 1, 1 (2) |
| Frenesi | inimigos +20% / +40% mais rápidos | 3, 3 (6) |
| Hordas | +20% / +40% / +60% de inimigos | 1, 1, 1 (3) |
| Ameaça | 10% / 25% dos inimigos da próxima região | 1, 2 (3) |
| Retorno | +25% / +50% de chance de o morto voltar em 5 s | 1, 1 (2) |
| Presas | inimigos com armadura ganham 1 / 2 vantagens | 2, 3 (5) |
| Cicatrizes | cura vale 75% / 50% / 0% | 1, 1, 2 (4) |
| Dívida | preços +40% / +80% | 1, 1 (2) |
| Sombra | encontros com guardião têm 1 servo sombrio | 2 (2) |
| Renúncia | o 1º dom de cada região vira cebola | 3 (3) |
| Tempo | 9:00 / 7:00 / 5:00 por região, depois 5 de dano por segundo | 1, 2, 3 (6) |
| Vazio | só 60% / 40% / 20% / 0% do Fôlego | 1, 1, 1, 2 (5) |
| Soberba | escolher dom acima de comum trava 3 / 6 de Magia por nível de raridade | 1, 1 (2) |
| Negação | depois de escolher, 2 dons não escolhidos somem da noite | 2 (2) |
| Rivais | guardiões das 1 / 2 / 3 / 4 primeiras regiões mais fortes | 2, 3, 3, 4 (12) |

Vencer um guardião com o Medo pedido pelo "Testamento" dá 1 a 3 de Pesadelo.

### Como entraria em A Selagem

- **Cartas:** sugestão **Vitrais** da igreja velha de Valmor (cada vitral é uma carta; o paladino "acende" o vitral
  antes de descer). Fôlego vira **Devoção** ou simplesmente **Capacidade**. **A confirmar com o Daniel** (os desenhos dos
  vitrais não podem inventar lore: podem ser só os paladinos e símbolos já do cânone).
  - Dados: `CardDef` (Resource: `id`, `grid_pos: Vector2i`, `cost: int`, `unlock: Dictionary` de recurso e quantidade,
    `mods_by_rank: Array[BoonMod]`, `awaken_rule` para as de custo 0) e `MetaState` em `core/save_data.gd` (cartas
    desbloqueadas, ativas, nível, capacidade). Os números das 25 cartas cabem como estão onde a estatística já existe
    (vida, Magia, dano no círculo, ouro inicial, chance de raridade).
- **Encantamentos:** sugestão **Obras da Capela** (restaurar a igreja em cima das catacumbas). `WorldUpgradeDef`
  (Resource: custo, requisito, sistema que liga). É o lugar natural para ligar Provação, infusões e votos em ordem.
- **Recursos:** começar com dois: **Cinzas** (cartas) e um segundo para a capacidade. Coleta pelas salas como
  recompensa menor (o Hades II tem um baralho próprio para isso, `MinorRunProgress`, ).
- **Votos:** sugestão **Juramentos** e **Peso** no lugar de Medo. `VowDef` (Resource: `fear_per_rank`,
  `mods_by_rank`). Quase todos já têm estatística no nosso jogo (dano, vida, velocidade, quantidade de inimigos, cura,
  preço); Tempo, Retorno e Renúncia pedem código pequeno.

**Esforço:** grande (tela no hub, save, três telas novas). **Prioridade:** média, depois do teste do Daniel com a
partida completa; os Juramentos podem vir antes das cartas por serem só modificadores.

---

## 10. Economia por região

### Como é no Hades II

- **Ouro dos inimigos:** cada encontro tem um teto de ouro sorteado entre **10 e 15**, mais **0,5 por sala de
  profundidade** . Cada inimigo morto tem **70%** de chance de
  soltar uma parcela proporcional à dificuldade dele, até esgotar o teto (`MoneyDropOnDeath`, ;
  ). Nas regiões seguintes, o teto do modo sonho vai de 10 a 15 até 25 a 40
  .
- **Recompensa de ouro:** 100 (`RoomMoneyDrop`, ); 300 no Tártaro (wiki
  https://hades.fandom.com/wiki/Gold_Crowns ).
- **Loja do Caronte:** 3 itens, **um de cada grupo** (`WorldShop`, ):

| Grupo | Itens e preço (ouro) | Fonte |
|---|---|---|
| Dom | dom de um deus 150; dom misterioso 125; dom de Hermes | ;  |
| Melhoria e cura | martelo 200; cura de 40% da vida 50; coração +25 de vida 125; armadura +20 por 40; recursos |  |
| Crescimento | tônico +30 de Magia 100; romã 100; fatia de romã 50; Selene 100; Caminho das Estrelas 60 | ; ;  |

  Na segunda metade da partida entram a romã grande (300), o dom reforçado (450) e itens caros; a última loja antes do
  chefe final tem 5 itens (Game8: https://game8.co/games/Hades-2/archives/453681 ; Switchblade:
  https://www.switchbladegaming.com/hades-2/charon-shop-guide/ ). Os guias citam "dom aleatório 125" e "tônico 125";
  nos dados, o dom misterioso custa 125 e o tônico 100.
- **Onde fica a loja:** no meio da região antes do guardião e na antessala do chefe (wiki `Charon`; Switchblade dá as
  salas por região, **a confirmar** no Érebo).

### Como entraria em A Selagem

- Já batem: recompensa de ouro 100, coração +25 por 125, tônico +30, romã 100, dom 150, cura de 40%.
- Ajustes: `room_gold_min/max` ganham `room_gold_per_depth := 0.5` e o ouro passa a cair dos inimigos (70% por morte,
  até o teto), em vez de aparecer de uma vez; cura na loja de 60 para **50**; a loja vira **3 grupos com um item cada**
  (`ShopGroup` Resource: `options`, `weights`, `cost`), com romã grande e fatia.
- Ouro continua só da partida (se perde ao voltar), como no Hades II.

**Esforço:** pequeno. **Prioridade:** alta (junto com a romã, mexe nos mesmos dados).

---

## Ordem de implementação recomendada

1. **Economia e raridade** (pequeno): baralho de recompensas no lugar dos pesos, raridade em sequência, guardião com
   lendário em vez de heroico, ouro por inimigo com teto, loja em 3 grupos, cura 50. Uma versão só, com testes.
2. **Romã** (médio): `base` e `per_level` nos `BoonMod`, níveis sem teto, migrar os 32 dons, romã grande e fatia.
3. **Elo** (pequeno): renomear, requisitos por lista de família, 12% por carta, troca com +1 de raridade (heroica).
4. **Lapidação da Emeth** (médio a grande): 8 a 10 melhorias da espada, no máximo 2 por partida.
5. **Lendários** (médio): um por família, com 3 listas de requisito.
6. **Provação** (médio): portas com custo de vida, maldição de 3 a 5 encontros que vira bênção.
7. **Afinidade e Ressonância** (médio): contagem por família e as infusões, quando houver mais dons.
8. **Juramentos** (médio): dificuldade extra só com modificadores, sem hub.
9. **Vitrais, Obras da Capela e recursos** (grande): o hub entre partidas.
10. **Invocação e Caminho** (grande): a 5ª ação, por último.

Os itens 1 a 3 cabem numa mesma versão MVP para o Daniel testar de uma vez.

## Perguntas para o Daniel

- Nomes: Brasa da Vigília, Lapidação da Emeth, Provação, Afinidade e Ressonância, Vitrais, Juramentos e Peso,
  Invocação e Caminho da Vela.
- A Provação pode ser uma porta sem dono, ou precisa de alguém do cânone?
- A Invocação (feitiço) pode ser a luz de Elun chamada pelo paladino?
- Com a descida de teste curta, quando liberar o 2º martelo e o Caminho?
- Vale copiar a faixa sorteada de raridade (rara entre 1,3 e 1,5) ou fixar 1,5?
