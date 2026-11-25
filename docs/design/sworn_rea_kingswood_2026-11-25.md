# SWORN: engenharia reversa de design da primeira região (Kingswood), 2026-11-25

Estudo só de leitura, feito a pedido do Daniel ("faz um REA na primeira fase inteira do SWORN"), para copiar e adaptar
**mecânicas e números** em A Selagem. Nada de arte, áudio, modelo ou texto do SWORN entrou no projeto; os nomes em
inglês abaixo são só identificadores para o estudo.

## 0. Fontes e método

- Jogo: `SWORN` (Unity 2022.3.28f1, IL2CPP), bundles Addressables em `SWORN_Data/StreamingAssets/aa/StandaloneWindows64/`
  (`base_*` e `patch_*`). Lidos com UnityPy (typetrees dos MonoBehaviours). Despejos e scripts só no scratchpad da sessão.
- Bundles lidos: `base_player_*` (personagens, habilidades, prefabs), `base_weapon_*` (20 armas), `base_blessing_asset`,
  `base_metaupgrade_asset`, `base_misc_kingswood` (dados do bioma), `base_asset_borealisgamemode(_dependency)`,
  `base_leftovers_asset`, `base_mobinfo`, `base_mob_*` dos inimigos de Kingswood, `base_level_kingswood_*`,
  tabela de texto em inglês (`localization-string-tables-english(en)`) para nomes e descrições.
- Enums (valores numéricos dos campos) lidos de `il2cpp_data/Metadata/global-metadata.dat` (v29), tabela de valores
  padrão dos campos: `PlayerState`, `AbilitySlot`, `BlessingClassification`, `Mechanic`, `ParagonType`, `RoomGroup`,
  `RoomType`, `ObjectiveType`, `RewardType`, `MobType`.
- **Os tempos de golpe estão nos Timelines** (cada habilidade é um `TimelineAsset`): duração, clipes de ativação da
  hitbox (janela ativa), marcadores de transição (`m_transitionMask`, a máscara de cancelamento) e marcadores de sinal
  (efeito de antecipação). Isso dá windup, ativo, recuperação e janelas de cancelamento com precisão de quadro (60 fps).
- Convenção: **FATO** = lido nos dados (com o campo); **INFERÊNCIA** = minha leitura do que o campo faz.

### 0.1 A máscara de cancelamento (chave para ler os tempos)

FATO: `PlayerState` é um enum de bits: Idle 1, LightAttack 2, HeavyAttack 4, Dash 8, LightDashAttack 16, Interact 32,
Mark 64, Block 128, Interrupt 256, Spell 512, Ultimate 1024, LinkedAbility 2048, HeavyDashAttack 4096, Potion 8192,
Emote 16384; `Recovery` = 9742 (Leve, Pesado, Dash, Magia, Ultimate, Poção). Cada habilidade tem marcadores
`PlayerStateTransistionMarker` com `m_transitionMask` num tempo: a partir dali, as ações da máscara podem cortar o golpe.

Exemplo, Espada golpe 1: em 0,0 s máscara 524 (Magia + Dash + Pesado), em 0,3 s máscara 1550 (+ Leve + Ultimate).
Ou seja: **dash, pesado e magia cortam o golpe desde o quadro 0; o próximo golpe leve só sai em 0,3 s.**

## 1. Jogador

### 1.1 Personagens (FATO, `movementStats`/`healthStats`/`manaStats`/`playerStats` nos prefabs)

| Classe (tipo técnico) | Vida | Velocidade | Giro | Mana máx. | Regen. mana | Graça após golpe |
|---|---|---|---|---|---|---|
| Vigilante (light physical) | 50 | 6,0 m/s | 1200 graus/s | 1 | 0,15/s, começa cheia | 0,2 s |
| heavy physical (Rook, INFERÊNCIA pelo texto) | 75 | 5,0 | 1200 | 1 | 0,15/s | 0,2 s |
| light magical | 50 | 6,0 | 1200 | 1 | 0,15/s | 0,2 s |
| heavy magical | 75 | 5,0 | 1200 | 1 | 0,15/s | 0,2 s |

- Aceleração e desaceleração 100 (instantâneas). `baseHazardResist` 0,9 (INFERÊNCIA: perigos de sala dão 10% a menos).
- `baseBackstab` 1,0 com arco de 60 graus (INFERÊNCIA: golpe pelas costas tem bônus; o valor real vem das Bênçãos de Sombra).
- O Vigilante (rogue) é o personagem inicial (`Light Physical (unlock)` custa 1 Fairy Ember) e leva a Espada.

### 1.2 Esquiva (FATO, `Dodge - Light Physical (ability)`)

- `cooldown` **0,8 s**, `maxCharges` **1**; meta `Light Physical Dash Charges` dá +1 carga (custo 1).
- `baseRange` **2,5 m** (`maxRange` 5,0, `idealLength` 4,0: INFERÊNCIA, alcance maior quando há obstáculo a atravessar
  ou com upgrade), duração do timeline **0,2 s** (`AbilityActiveDurationClip` 0 a 0,2).
- Troca de camada para a de esquiva de 0 a 0,2 s (`Layer Change`): INFERÊNCIA, **invulnerável a esquiva inteira (0,2 s)**.
- Máscaras: 0 em 0,0 (nada corta), **5656 em 0,033 s** (Dash, Dash Attack leve e pesado, Magia, Ultimate), 1550 em 0,2.
  Ou seja, o ataque na esquiva sai a partir do 2º quadro.

### 1.3 Ao ser atingido (FATO, `Player - Get Hit`)

- `invulnerabilityDuration` **0,85 s**. Máscara 0 até 0,1 s, depois 1614 (Leve, Pesado, Dash, Magia, Ultimate):
  o herói fica 0,1 s sem agir e pode esquivar a partir daí. `Player - Hitstun` (atordoamento do herói) 1,5 s.

### 1.4 Espada (arma inicial): tempos e números (FATO, timelines `Sword - *`)

Combo leve (`m_WeaponAbilities.lightAttacks`): Combo 1 → Combo 2 → **Combo 3 Slash**. Pesado: `Sword - Spin`.
Dash leve: `Sword - Dash Attack`. Dash pesado: `Sword - Spin Dash Attack`. Auto-mira de 3 m no começo de cada golpe.

| Golpe | Dano | Hitbox ativa | Próximo leve | Dash/pesado/magia cortam | Parada (`m_freezeDuration`) | Empurrão |
|---|---|---|---|---|---|---|
| Combo 1 | 20 | 0,083 a 0,133 s | 0,30 s | desde 0,0 | 0,20 s | não |
| Combo 2 | 20 | 0,083 a 0,133 s | 0,30 s | desde 0,0 | 0,20 s | não |
| Combo 3 Slash (finalizador) | 40 | 0,233 a 0,283 s | 0,633 s | desde 0,0 (+ Ultimate) | 0,20 s | 10 por 0,2 s |
| Spin (pesado, área) | 40 | 0,067 a 0,217 s | 0,50 s | Magia e Dash desde 0; pesado em 0,25 | 0,075 s | 10 por 0,2 s; `cooldown` **0,9 s** |
| Dash Attack (estocada) | 20 | 0,05 a 0,25 s | 0,333 s | Magia e Pesado desde 0 | 0,075 s | não; camada protegida 0 a 0,167 s |
| Spin Dash Attack | 40 | 0,067 a 0,217 s | 0,50 s | Magia | 0,075 s | 10; `cooldown` 0,9 s |

- Ciclo do combo leve: 0,30 + 0,30 + 0,633 = **1,23 s para 80 de dano (cerca de 65 de dano por segundo)** num alvo.
- Variantes no mesmo bundle (INFERÊNCIA: trocadas por Bênção de arma ou árvore): `Combo 3` estocada 40 com avanço
  (`CharacterMovementClip` 0,133 a 0,383), `Spin Charging` (segurar; indicador de raio 2,5 a 4,25 m, `Perfect Shot
  Marker` em 0,5 s), `Spin Charged` 30 com empurrão 24, `Corkscrew` 6 x 10, `Spinning Dash Attack` 3 x 10.
- `sweetspotMultiplier` 1,6 (INFERÊNCIA: soltar a carga no marcador "Perfect Shot" multiplica o dano por 1,6).
- Movimento no golpe (INFERÊNCIA): clipes `MovementModifierClip` tipo 0 ("MovementMultiplier") com 0 antes do corte,
  1,1 durante o corte (o passo vem da animação) e 0 depois; tipo 2 com 10 no começo e 0 depois = giro livre só nos
  primeiros 0,05 a 0,12 s, depois a direção trava. **Os pés ficam presos no golpe e a mira só gira no início.**
- Recurso de magia por dano: `damageToMana` **0,009** por ponto de dano (111 de dano = 1 Magia), `multiHitManaPenalty`
  0,5 (acertos múltiplos rendem metade).

### 1.5 Magia ("Crest", botão de feitiço) do Vigilante (FATO)

Cada uma custa `manaCost` 1 (a barra inteira do Vigilante): Blade Rush (`Slash Dash`: 100 de dano, avança 9 m,
recarga 0,75 s, hitbox 0,167 a 0,383), Dagger Flurry (`BackFlip Dagger`: salto para trás 3,5 m e leque de 3 adagas),
Shadow Strike (`Teleport Stab`: 80, alcance 12 m, hitbox 0,35 a 0,467), Assassin Dagger (100, alcance 20 m, voo 0,4 s).
Com regen 0,15/s, sai uma Magia a cada **6,7 s** sem atacar, mais rápido batendo.

### 1.6 Ultimate (FATO e lacunas)

- Toda Ultimate vem de uma **Bênção de núcleo do slot 5 de uma Fae** ("embody"): Gogmagog 250 a 370 x 3 golpes,
  Lugh lança 450 a 650 (50% crítico x2), Titania gato 200 x 1,4 a 2,0, Oberon 10 x 30 + 100 final. `ultimateCost` **100**.
- Meta: as Ultimates só aparecem depois de **6 partidas** (`runsRequiredForUltimates` 6) e de comprar `1_Ultimate`
  (10 Moonstone); Companheiros depois de 4 partidas (`runsRequiredForCompanions` 4, `4_Companion` 15 Moonstone).
- DESCONHECIDO: a taxa de carga da barra de Ultimate não está em dado (há classes `UltimateOnHitBlessing` e
  `UltimatePassiveRechargeBlessing` no código: INFERÊNCIA, carrega ao acertar e passivamente).
- `Imbue` (habilidade do Vigilante, "o próximo golpe libera o potencial das Bênçãos"), máscara -1025: INFERÊNCIA,
  efeito especial da classe, não a Ultimate de Fae.

### 1.7 Outras armas (FATO, resumo: dano do combo leve, hitbox do 1º golpe, próximo leve, pesado)

| Arma | Combo leve (dano) | 1º ativo | Próximo leve | Pesado | `sweetspot` |
|---|---|---|---|---|---|
| Espada | 20, 20, 40 | 0,083 | 0,30 | giro 40, recarga 0,9 | 1,6 |
| Bo Staff | 15 x 4, 40 | 0,033 | 0,167 | 60 (ativo 0,567); carregado 70 | 1,4 |
| Garras | 15, 15, 25, 30 | 0,033 | 0,133 | rajada 40, recarga 0,9 | 1,6 |
| Manoplas | 18 alternado | 0,067 | 0,25 | 40 alternado | 1,6 |
| Maça | 40, 40, 60 (golpe ativo 0,2 a 0,33) | 0,2 | 0,5 | 30, recarga 1,5 | 1,4 |
| Grande martelo | 60, 60, 120 | 0,30 | 0,667 (3º: 1,133) | giro carregado 60 por tique | 1,4 |
| Lança | 15, 15, 25 | 0,167 | 0,367 | 25 com empurrão 10 | 1,6 |
| Foice | 20, 20, 20 | 0,183 | 0,467 | execução 60 | 1,4 |
| Tomo | tiro em leque | n/d | 0,5 | rajada 40 (70 ampliada), recarga 1,0 | 1,6 |
| Arco | carga por distância | n/d | 0,333 | chuva de flechas 10 cada | 1,5 |

Regra visível: **arma lenta = golpe mais forte na mesma proporção** (martelo 60 com 0,667 s por golpe dá cerca de 90
por segundo; bastão 15 a cada 0,167 s também cerca de 90); a espada fica no meio.

## 2. Bênçãos

### 2.1 Estrutura (FATO, `base_blessing_asset`)

| Tipo (nome do asset) | Quantos | O que é |
|---|---|---|
| paragon blessing | 384 | Bênçãos das 8 Fae ("Paragon"); 31 a 39 por Fae nas categorias |
| weapon blessing | 191 | por arma (Espada: 10, ex.: Long Sword +15% dano e +20% alcance do leve) |
| kiss blessing / kiss curse blessing | 12 / 18 | "Merlin's Guidance" (só bônus) e "Morgana's Corruption" (bônus forte + penalidade) |
| duo blessing (+ 70 com `requiredBlessingsDuoAny`) | 6 | combinações de duas Fae |
| round table blessing | 4 | efeitos gerais (ex.: +25% velocidade de ataque e +15% dano) |
| shop / event / health / gold | 30 / 13 / 1 / 1 | loja, eventos, Longevity (+20 ou +30 de vida), Money Bag (100 ouro) |
| Bênçãos de Crest | 3 por Magia | upgrades da Magia |

As 8 Fae (`ParagonType`): Courage 1 (Gogmagog), Flame 2 (Titania), Frost 3 (Beira), Venom 4 (Mab), Shadow 5 (Badb),
Wind 6 (Oberon), Death 7 (Cliona), Crit 8 (Lugh). Cada Fae tem **6 Bênçãos de núcleo, uma por botão**
(`reservedAbilitySlot`: 1 Leve, 2 Pesado, 3 Magia, 4 Dash, 5 Ultimate, 6 Companheiro) e 21 a 30 de apoio (slot 0),
que pedem pré-requisitos (`requiredBlessingsAny/All/None`) e destravam mecânicas (`mechanicsUnlocked`: Stun 1,
Quake 2, Crit 10, Mark 14, Weak 20, Ignite 30, Chill 40, Backstab 50, Venom 60, Fury 70, Whirlwind 73 e outras).

### 2.2 Raridade e sorteio (FATO, `Blessing Generator`)

- 5 raridades: comum, incomum, rara, épica, lendária. Chance base: incomum **14%**, rara **4,5%**, épica **1,5%**,
  lendária **0,5%** (comum, o resto: 79,5%). `Rarity Boost` (Mesa Redonda) e `Treasure Trove`: +25% de chance de raridade.
- Ordem de montagem das opções (`BlessingClassification`): sem Bênçãos ainda: sorteia um slot de núcleo e enche com
  núcleo, depois não-núcleo, depois mecânica nova, upgrade de mecânica, à la carte, duo, Mesa Redonda, depois as já
  recusadas e o reserva. Com Bênçãos: rola Mesa Redonda, Duo, Núcleo, Mecânica nova, À la carte, nessa ordem.
- Pesos: `chanceOfPrioritizingCoreSlotBlessing` 1,0; não-núcleo 0,5; upgrade 0,5; à la carte 0,33. Chance de duo por
  total de Bênçãos: 0 até 2, sobe a **50% com 10**. Mecânica nova: prioriza 100% com 0 ou 1 mecânica da Fae, 0% com 2+.
- Escolha da Fae da porta: `repeatParagonWeightsByCurrentParagonCount` **3** (até 3 Fae), 8 com 8; Fae nova peso **1**.
  A partida **concentra** em poucas Fae (3 para 1 a favor das que você já tem).
- DESCONHECIDO: quantas opções a tela mostra (fica na UI; o jogo mostra 3) e a escala por nível do "Horn of Strength"
  (`ParagonLevelUp`): só uma Bênção traz `levelDamageMultipliers` [2,5; 2,75; 3,0].

### 2.3 Valores típicos por raridade (FATO, campos com `common..legendary`)

Padrões: **+5 pontos percentuais por raridade** nos multiplicadores de núcleo; dano fixo sobe cerca de 10 a 15% por raridade.

| Bênção (Fae, slot) | Efeito | Comum, inc., rara, épica, lend. |
|---|---|---|
| Mighty Touch / Strike / Flourish (Gogmagog, Leve/Pesado/Magia) | +dano e Stagger | +30, 35, 40, 45, 50% |
| Mighty Dash (Gogmagog, Dash) | tremor de 20 onde cai | x0,25, 0,40, 0,55, 0,70, 0,85 |
| Wrath of the Giant (Gogmagog, Ult) | 3 punhos | 250, 280, 310, 340, 370 |
| Lucky Touch / Strike / Flourish (Lugh) | +dano, 15% crítico x2 | +25, 30, 37,5, 45, 50% |
| Stroke of Luck (Lugh, Ult) | lança, 50% crítico | 450, 500, 550, 600, 650 |
| Burning Touch / Strike / Flourish (Titania) | Ignite a cada X s | x1,40, 1,55, 1,70, 1,85, 2,0 |
| Burning Dodge (Titania, Dash) | Immolate | 7, 8, 9, 10, 12 |
| Lion Claw (Titania, Ult) | gato de 200 | x1,40 a 2,0 |
| Tempest Touch / Strike / Flourish (Oberon) | +Fúria por acerto | +7, 8, 9, 10, 11% por carga |
| Tempest Dash (Oberon) | redemoinho no caminho | 15, 18, 21, 24, 27 |
| Chilling Touch (Beira, Leve) | +dano fixo e Chill | +5, 6, 7, 8, 9 |
| Chilling Dash (Beira) | Frost Nova | 25, 28, 31, 34, 37 |
| Caustic Finale (Mab) | explosão por carga de Veneno | 5, 5,25, 5,5, 6,75, 7 |
| Spirit Siphon (Cliona) | carga por segundo por inimigo Fraco | 8, 9, 10, 11, 12 |
| Deadly Precision (Lugh, apoio) | +dano em Marcado | +30, 40, 50, 60, 70% |
| Greed (Lugh, apoio) | dano por 50 de ouro | +3, 4, 5, 6, 7% |
| Collector (Lugh) | ouro a mais | +25, 30, 35, 40, 45% |
| Kiss: Pure Haste | velocidade | +10, 12,5, 15, 17,5, 20% |
| Kiss: Pure Wisdom / Ultimate | dano da Magia ou Ult | +30, 35, 40, 45, 50% |
| Kiss: Leve ou Pesado | dano | +20, 22,5, 25, 27,5, 30% |
| Curse: Lethargic Skill | +40 a 60% no leve | e -10% de velocidade |
| Curse: Vulnerable Wisdom | +60 a 80% na Magia | e +30% de dano recebido |
| Duo: Bone Collector | +1% de dano por abate | até 100, no máx. 15 por sala |
| Duo: Helpless Prey | sombra golpeia o Fraco | 25 a cada 2,5 s |
| Espada: Fencing Foil / Acceleration / Double Edge | | 3º golpe e estocada +50%; +10% andar e +30% leve; pesado 2 vezes com -25% |

Regra de desenho visível: **Kiss Curse = dobro do bônus de um Kiss puro com uma penalidade** (Pure Wisdom 30 a 50%,
Vulnerable Wisdom 60 a 80% com +30% de dano recebido).

## 3. Primeira região (Kingswood)

### 3.1 Estrutura da partida (FATO, `Kingswood (biome data)`)

15 posições (`rooms`), índice: tipo, objetivo, recompensa da porta 1 / porta 2.

| Sala | Tipo e objetivo | Recompensa fixa |
|---|---|---|
| 0 | Combate, ondas (nível `Kingswood - Intro`) | Fae Banner (Bênção de Fae) |
| 1 | aleatório | Bênção avulsa / Bênção avulsa |
| 2 | aleatório | Fae Banner / Coração (vida máx.) |
| 3 a 5 | aleatório | por grupo de sala |
| 6 | **Minichefe** (Major Enemy): Questing Beast ou Bane of Crows | War Stone (meta) |
| 7 | aleatório | Grail Water / Crystal Shard |
| 8 a 10 | aleatório | por grupo |
| 11 | aleatório | Horn of Strength (nível de Bênção) / Ouro |
| 12 | aleatório (grupo loja de fim de bioma a partir daqui) | |
| 13 | **Chefe**: Gawain ou Lady Kay | Grail Water |
| 14 | Descanso (`Wirral Rest`, fonte) | |

- Grupos garantidos, cada um 1 vez, com sala mínima (`roomGroups`): Crystal Shard e Fairy Ember desde a 1; Fae Banner
  desde a 2; Bênção de arma, **primeira loja** e Bênção de uma Fae escolhida desde a 4; Vida, Evento, Horn e Moonstone
  desde a 8; loja de fim de bioma desde a 12. Enchimento: sala de Crystal Shard com Fairy Ember.
- Cavaleiro Negro (invasor elite entre salas): entre as salas 2 e 10 (`min/maxBlackKnightIndex`).
- Combate comum: **50% ondas, 50% horda** (`combatTypeProbabilities`). Ondas: 50% uma onda com coeficiente 1,0,
  50% **duas ondas com 0,75 cada** (`waveCombatData`). Horda: onda inicial 0,75 e reserva 0,75 do orçamento.
  Major Enemy (minichefe ou sala com capitão): seleção 1,0, ondas de apoio 0,5, menores 0,9.
- Eventos (iguais): Onslaught, cristais (5 geradores, 8 s entre eles, acelera 0,5 até 2 s), Obstacle Course, Luna
  Blossom. Santuários de Merlin: 25 s, 2 a 3 tipos, até 8 inimigos, um a cada 8 s.
- Pós-sala (`postLevelEventPools`): 94% nada; pequenos % de eventos (3 a 20%).

### 3.2 Orçamento de inimigos (FATO, `intensityCurve` x `mobinfo.difficulty`)

Orçamento da sala pela curva: **4 na sala 0, 8 na sala 5, cai para 6 na sala 7 (depois do minichefe), 11 da sala 11
em diante**. Cada inimigo custa sua `difficulty`: Snake 1, Hammer Mob 3, Axe Thrower 3, Boar 3, Mortoad 5,
Major (capitão) 10, Buff Totem 0. Exemplo: sala 0 = 1 martelo + 1 cobra; sala 5 com duas ondas = 6 por onda.
Escala de jogadores: x1 com 1, x2 com 4 (vida dos chefes x4 com 4).

Arena (objetivo Arena, rodadas FATO): 1 capitão; 1 capitão + 2 comuns; 2 capitães; 2 capitães + Totem; 2 capitães +
2 comuns; Questing Beast.

### 3.3 Dificuldades (FATO, seletor de dificuldade)

| Nível | Vida inimiga | Dano inimigo | Corrupções | Inimigo corrompido | Meta |
|---|---|---|---|---|---|
| 0 | x0,70 | x0,85 | 0 | 0 | x1,0 |
| 1 (normal) | x1,0 | x1,0 | 0 | 0 | x1,0 |
| 2 | x1,3 | x1,15 | 0,8 | 5% | x1,1 |
| 3 | x1,6 | x1,3 | 1,6 | 10% | x1,15 |
| 4 | x2,0 | x1,5 | 2,4 | 15% | x1,2 |
| 5 | x2,5 | x2,0 | 3,2 | 20% | x1,25 |

### 3.4 Tutorial ("Wirral Forest", `Tutorial (biome data)` + `tutorialRoomWaveOverrides`)

A primeira partida é um bioma de tutorial com salas fixas e ondas escritas à mão (FATO):

| Sala | Nível | O que tem | Recompensa |
|---|---|---|---|
| 0 | Tutorial Spawn | acordar, andar ("Find a way forward", "Press Dash") | |
| 1 | Tutorial Dodgeball | onda 1: **1 Hammer Mob**; onda 2: **2 Axe Throwers** (esquivar machados) | Fae Banner |
| 2 | Figure 8 | 2 Boars; depois 5 Snakes | Crystal Shard |
| 3 | Dragon Bones | 2 Mortoads; depois 1 Mortoad + 2 Hammer Mobs | Banner / Vida |
| 4 | Overlook | 2 Axe; depois 2 Axe + 1 Boar | Fairy Ember |
| 5 | Minichefe Questing Beast | (vida e dano com `tutorialQuestingBeast...ScaleFactor` 2,0) | War Stone |
| 6 a 10 | Nook, Pit, Plus, Nexus, Island | ondas e hordas normais | Banner, Shard/Ember, Ouro, Ember, Horn |
| 11 | Loja | | |
| 12 | Chefe Gawain | | Grail Water |
| 13 | Descanso | | |

Ordem de ensino (FATO, `tutorial info`): Dash, Leve, Pesado, Dash Attack, Magia, mira travada (Lock On), "Defeat all
foes", "Find a way forward"; depois "Claim your reward", "Defeat the captain enemy and its summons", e no hub
"Unlock a Squire with Grail Water", "Purchase a new weapon with your Fairy Embers". Cada inimigo entra **sozinho ou
em dupla antes de se misturar** (martelo, depois machados; javalis, depois cobras).

## 4. Inimigos da primeira região

FATO: `healthStats`, `movementStats`, `combatStats.baseAttack`, `mobStats` (`poise`, imunidades), timelines das
habilidades. O dano do golpe corpo a corpo é `baseDamage` da habilidade x `baseAttack` (Hammer Mob 1,0 x 10 = 10);
projéteis trazem o dano em `settings.baseDamage`. "Aviso" = início da hitbox (ou do disparo) desde o começo da
habilidade; "sinal" = marcador do efeito de antecipação.

| Inimigo | Vida | Vel. | Dano | Ataque e aviso | Poise | Atordoado | Custo |
|---|---|---|---|---|---|---|---|
| Snake | 20 | 3,0 | 3 | mordida: ativa 0,483 s | 10 | imune a hitstun | 1 |
| Hammer Mob | 250 | 2,25 | 10 | marretada: sinal 0,18, **ativa 0,667 a 0,783**, ataque inteiro 2,08 s | 125 | 2,0 s | 3 |
| Axe Thrower | 150 | 2,5 | 5 (1 machado) / 7 (3 em leque de 20 graus) | solta em 0,5 a 0,7 s; alcance 20 m, voo 2,5 s | 75 | 2,0 s | 3 |
| Boar | 200 | 2,25 | 7 | investida: sinais 0,167 e 0,467, **corre de 0,667 a 2,1 s**; bate na parede e atordoa 1 s | 100 | 2,0 s | 3 |
| Mortoad | 175 a 200 | 1,0 | 7 a 9 | morteiro: sinal 0,0 e 0,467, disparo 0,5; projétil 3 s; salta para longe | 100 | 2,0 s | 5 |
| Buff Totem | 420 | 0 | | dá +50% dano e -50% dano recebido aos vizinhos | 0 | imune | 0 |
| Major Hammer (capitão) | 1500 | 1,75 | 12 | onda de choque: aviso 1,23 s, 6 anéis até 1,75 s; **invoca 5** | 400 | 2,5 s | 10 |
| Major Axe | 1250 | 2,5 | | invoca 5 | 300 | 2,5 s | 10 |
| Major Boar | 1350 | 1,75 | 9 | investida igual; invoca 5 | 300 | 2,5 s | 10 |
| Major Mortoad | 1300 | 1,0 | 7 a 9 | 3 morteiros (0,8, 1,33, 1,87 s); invoca 5 | 300 | 2,5 s | 10 |
| **Questing Beast** (minichefe) | 3000 | 5,0 | 7 a 10 | cauda 10 (ativa 0,667); 3 tiros 7 (0,667); salto; 5 morteiros a cada 0,42 s; chama 5 ajudantes | 750 | 3,5 s | |
| **Bane of Crows** (minichefe) | 2500 | parado | 5 a 10 | raio 5 a cada 0,5 s de 0,72 a 5,0 s (90 graus, 1 s de graça); salto 10 (aterrissa 1,0 s); 3 rajadas; morteiro 7 (1,05 s); invoca 2 | 800 | 3,5 s | |
| **Gawain** (chefe) | 6000 | 6,0 | 7 a 15 | golpes selvagens 6 x 10 (primeiro aos 0,833 s, um a cada 0,53 s); salto 15 (aterrissa 1,58 s); 3 saltos 15 (0,833); ondas no chão 4 x 15 (0,833); Erupção 10 x 10 (8 s); tiro múltiplo; invoca 3 | 800 | 3,5 s | |
| Lady Kay (chefe alternativo) | 4500 | 2,0 | 10 a 15 | golpe 15 (ativo **1,033 s**); giros 240 graus 15 (0,73 a 0,87); espinhos; investida com escudo 15 (8 m/s) | 800 | 3,5 s | |
| Cavaleiros de Gawain | 500 a 3000 | 3,5 a 6 | 10 a 15 | martelo (giro 12 aos 0,667; anel 15 aos 0,833), arco (3 x 10, sniper 15 aos 0,667), mago (morteiros, 10) | 250 a 500 | 4,0 s | 5 a 7,5 |

Regras de combate dos inimigos (FATO + INFERÊNCIA):
- **Stagger**: "No máximo de Stagger o inimigo fica atordoado; o Stagger soma o dano do golpe" (texto do jogo). `poise`
  é o teto. Cada novo atordoamento pede **x1,25** de Stagger (`subseqentStunResistMultiplier` 1,25). Atordoamento:
  2,0 s comum, 2,5 s capitão, 3,5 s chefe e minichefe, 4,0 s cavaleiro (duração dos timelines `hitstun`).
  INFERÊNCIA: com a espada, um martelo (poise 125, vida 250) cai atordoado uma vez no meio da vida.
- "Armored": barra amarela, não atordoa (texto do jogo). Capitães e chefes são imunes a empurrão (`immuneToKnockback`).
- Gelo: `hitsToFreeze` 4 a 6 comuns, 10 a 20 capitães, 20 a 30 chefes.
- Ouro: 5 com 40% de chance por comum; 5% de item.
- O aviso padrão de comum fica em **0,48 a 0,67 s** até o golpe, com sinal de antecipação 0,3 a 0,5 s antes.
  Chefes e cavaleiros: **0,83 a 1,03 s**; ataques em área grandes 1,2 a 1,6 s.
- DESCONHECIDO: recargas da IA, distâncias de ataque e limiares de fase dos chefes ficam nas árvores do Behavior
  Designer (`mBehaviorSource`, dados binários com nomes em hash); não decodifiquei.

## 5. Meta e onboarding (FATO, `base_metaupgrade_asset`)

- Moedas por recompensa (`baseAmountToAdd`, escala com a sala): Crystal Shard 20 (poder na "Source"), Fairy Ember 10
  (armas, Magias, personagens), Grail Water 5 (melhorar armas), Moonstone 5 (restaurar Camelot: funções do hub),
  Silk 10 (cosméticos), Emerald 1 (upgrades fortes de arma), Pedras de vidência 1 (War/Treasure/Wealth/Devotion).
- Desbloqueios de arma (Fairy Ember): Espada, Maça, Martelo e Varinha 1; Arco 10; Staff 20; Hand Cannon 30; Foice 40;
  Bo Staff 50; Tomo 60; Great Sword 70; Adagas Arcanas 80; Chakrams 120; Sinos 140; Punhos 160; Garras 180.
  Personagens: heavy magical 20, heavy physical 30, light magical 40.
- Funções do hub (Moonstone): Trove 5, Ultimate 10, Secret Shop 10, Accolade 10, Companion 15, Loot Goblin 20,
  Portal 25, Corruption Shrine 25, Blessing Altar 25, Shrine 30, Potion Station 35, Codex 40, Currency Exchange 50,
  Emote 75, Dice 100.
- Atributos por classe: Vitality +10 a +50 de vida (custos 1 a 5), +1 carga de esquiva (custo 1), Sturdy Dodge
  15/30/45%, Strong Willed 10/20/30%. Árvores de arma: 377 nós, a maioria em Grail Water (custos de 10 e 25).
- Primeira partida: Vigilante + Espada, bioma de tutorial, sem Ultimate nem Companheiro (só depois de 6 e 4 partidas).

## 6. O que ficou desconhecido e onde provavelmente está

| Item | Onde deve estar |
|---|---|
| Carga da Ultimate (quanto por acerto, passiva) | código (`UltimateOnHitBlessing`, `UltimatePassiveRechargeBlessing`), `GameAssembly.dll` |
| Número de opções por Bênção, rerrolagem | UI (`rewardElementBackgrounds`) e código |
| Escala por nível de Bênção (Horn of Strength) | código; só uma Bênção traz multiplicadores por nível |
| Recargas da IA, alcance de ataque, fases de chefe | `mBehaviorSource` (Behavior Designer, binário) |
| Pool de inimigos comuns por bioma | código ou o asset `mobSpawnData` (GUID único em todos os níveis); inferido aqui pelo tutorial e pela arena: martelo, machado, javali, sapo, cobra |
| Distância exata do recuo dos golpes | animação (root motion) |

## 7. O que copiar e adaptar para A Selagem

Comparação com o nosso estado (`tools/make_data.gd`, `warrior_spec.md`, `combat_cadence.md`, `gameplay.md`): Guerreiro
40 de vida, combo 15/15/20 (giro), esquiva 0,2 s protegida inteira com recarga 0,8 e 1 carga, 0,7 s de proteção após
golpe, poise 100 com pesos por botão, atordoamento de 0,5 s (leve) e 1,1 s (forte) em todo golpe nos comuns,
Morvath 8500.

1. **Máscara de cancelamento por quadro, como dado.** O SWORN deixa dash, pesado e magia cortarem o golpe desde o
   quadro 0 e só libera o próximo leve em 0,30 s (golpes 1 e 2) e 0,63 s (finalizador). Nós já temos windup e trava
   por golpe; vale adicionar ao `ComboNode` uma lista "a partir de t, libera: dash, especial, círculo, leve", em vez
   de regras soltas. Mantém a regra do Daniel (esquiva corta tudo) e deixa o pesado cortar o leve.
2. **Finalizador = 2 vezes o golpe comum.** Espada 20, 20, **40** (com empurrão só no 3º). O nosso 15, 15, 20 deixa o
   giro fraco demais para o peso que a cadência dá a ele. Proposta: 15, 15, 30 (ou 18, 18, 36 se a vida dos comuns
   subir, item 4). DPS do combo leve da espada: cerca de 65 por segundo.
3. **Parada de impacto por tipo de golpe.** 0,2 s nos golpes de um alvo, 0,075 s nos de área e na estocada. Copiar a
   regra "muitos alvos, parada curta" (INFERÊNCIA sobre a quem a parada se aplica: medir em captura antes).
4. **Escala de vida e dano.** Herói 50; comum bate 5 a 10 (10 a 20% da vida), capitão 12, chefe 15 (30%); comum tem
   150 a 250 de vida (8 a 12 golpes leves), a cobra 20 (1 golpe) é a "bucha". O nosso guarda (14 de dano em 40 de vida,
   35%) está acima da faixa; o esqueleto (95 de vida, 6 golpes) abaixo. Proposta: dano dos comuns 10 a 20% da vida do
   herói e um inimigo de 1 golpe para dar ritmo às hordas.
5. **Capitão ("Major") em vez de só elite com armadura.** 5 a 6 vezes a vida do comum, imune a empurrão, poise 3 vezes,
   golpe com aviso de 1,2 s e **invoca 5 comuns**; custa 10 no orçamento contra 3 do comum; atordoa 2,5 s.
   Cabe como variante de dado dos nossos inimigos (comportamento que já existe: invocação do ancião).
6. **Stagger por dano acumulado com atordoamento longo e resistência crescente.** No SWORN o comum não pisca a cada
   golpe: enche a barra (poise = 50% da vida no martelo) e fica **2,0 s** atordoado; capitão 2,5 s, chefe 3,5 s; cada
   atordoamento seguinte pede x1,25. Sugestão: manter o nosso flinch curto nos comuns (pedido do Daniel, Hades II) e
   adotar a barra com atordoamento longo e o x1,25 para elites, guardiões e Morvath (hoje nunca atordoam).
7. **Avisos.** Comuns 0,48 a 0,67 s até o golpe, com o efeito de antecipação 0,3 a 0,5 s antes; chefe 0,83 a 1,03 s;
   área grande 1,2 a 1,6 s; ataques longos de chefe com acertos a cada 0,5 s (golpes selvagens, raio). Usar como faixa
   de referência no `combat_cadence.md` (o Daniel já achou nossos windups lentos: o SWORN confirma 0,5 a 0,7 s).
8. **Orçamento por sala com curva e custo por inimigo.** Curva 4, 8 (sala 5), cai para 6 depois do minichefe, 11 da
   sala 11; 50% ondas (1 x 1,0 ou 2 x 0,75) e 50% horda (0,75 + reserva 0,75). O nosso `EncounterGen` já tem `rating`;
   copiar a **queda logo depois do minichefe** e o 2 x 0,75 (duas ondas somam 1,5 do orçamento).
9. **Descida com salas âncora e portas fixas.** 15 posições: minichefe na 6, chefe na 13, descanso depois do chefe,
   portas pré-definidas nas salas 1, 2, 7 e 11, e grupos garantidos com sala mínima (loja desde a 4, vida e evento
   desde a 8, loja final desde a 12). Bom molde para o nosso capítulo de 14 salas: fixar 4 a 5 âncoras e sortear o resto.
10. **Bênçãos: uma por botão por fonte, +5 pontos por raridade, e o sorteio puxa para as fontes que você já tem.**
    Cada Fae tem 6 de núcleo (leve, pesado, magia, dash, ultimate, companheiro) com o mesmo efeito em todos os botões
    (ex.: +30 a 50% e Stagger) e 20 a 30 de apoio com pré-requisito. A Fae repetida pesa 3 contra 1 da nova; duo começa
    em 0 com 2 Bênçãos e chega a 50% com 10. Raridades 79,5 / 14 / 4,5 / 1,5 / 0,5. Para a regra "Bênção define a
    partida", copiar o **peso 3 para 1** e o **duo só depois de 3+ Bênçãos**; as nossas 85,5 / 9,5 / 5 já estão perto.
11. **Onboarding.** Primeira partida escrita à mão (inimigo sozinho, depois em dupla, depois misturado; minichefe na 5
    e chefe na 12), Ultimate só depois de 6 partidas e Companheiro depois de 4, armas a partir de 1 moeda. Para as
    crianças (pedido de 2026-11-23) vale uma "descida de tutorial" fixa com ondas por sala em dado.

Ressalva: valores de dano dos inimigos aqui são da dificuldade normal (1) e de 1 jogador.
