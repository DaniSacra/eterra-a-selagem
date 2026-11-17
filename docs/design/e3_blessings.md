# E3 "Bênçãos e combinações": regras e números (parte de jogo)

Entrega do `gameplay-engineer` (2026-11-17). Regras e números do Hades II (D-39) levantados em
`docs/design/hades2_sistemas.md`; o que é nosso está marcado. Todo número é dado em `tools/make_data.gd` (`_boons`,
`_stage`), regerado. Métricas do robô em `docs/qa/e3_metrics.md`.

## O que entrou

| Item | Regra | Onde |
|---|---|---|
| C13-01 descida | 10 salas e Morvath na 11: abertura no salão, lutas sorteadas entre Cripta, Fendas e Jardim (nunca a mesma duas vezes seguidas, nenhuma arena mais de 3 vezes, a menos usada primeiro), guardião na 4 a 6, fonte uma vez na 5 a 8 (35% por sala, forçada na 8), loja na 10, elites desde a profundidade 3. `--medium` é a descida de 7 do C12 (fonte na 4, guardião na 5, loja na 6, elites desde a 2) e `--short` a de 5 | `StageDef.rooms`, `arena_max_uses`; `RunMap._layout`, `RunMap.uses`; `Rooms.short_stage` |
| C13-02 baralho | as portas tiram cartas de um baralho sem repor; quando nada que sirva sobra (já tirado, já mostrado por outra porta da sala, romã sem Bênção que cresça), o baralho volta inteiro. 6 Bênçãos, 2 romãs, 2 corações, 2 Magia, 2 ouro (o do Hades II tem 4 Bênçãos, Hermes e a sala de dois deuses, que aqui são Bênçãos; martelo, Selene e o caminho das estrelas ainda não existem) | `StageDef.reward_deck`, `RewardDeck` (`core/reward_deck.gd`), `RunMap.deck` |
| C13-03 raridade | em sequência: a carta começa comum e tenta rara (10%), épica (5%) e lendária (0), vale a última que passar: 85,5 / 9,5 / 5. Guardião: rara 90%, épica 7% (9,3 / 83,7 / 7), sem lendária (os 5% de lendário do Hades II são o Salmo, E4). Quatro raridades (D-52 (a)): comum 1, rara 1,5, épica 2, lendária 2,5 (D-53 (a), fixos) | `Boon.RARITY_CHANCE`, `RARITY_CHANCE_GUARDIAN`, `StageDef.rarity_chance`, `guardian_rarity_chance`, `BoonState.roll_rarity`, `rarity_odds` |
| E3-01 troca | 10% por carta, quando há Bênção ainda não tida para uma ação já ocupada: a carta troca a da ação por essa, uma raridade acima da que sai (no mínimo; a da própria carta se for maior) e no nível dela. É o único caminho da lendária | `Boon.TRADE_CHANCE`, `StageDef.trade_chance`, `BoonState.trade_card`, `BoonState.Card.trade` |
| C13-05 romã | cada número tem `base` (nível 1, vezes a raridade) e `per_level` (o ganho fixo dos níveis 2, 3...; o último se repete; a raridade nunca multiplica o ganho). Migrados com os mesmos números de antes numa carta comum (ganhos = os degraus antigos); o dano das Bênçãos que agem sozinhas segue a mesma regra (`SkillDef.damage_at`) | `BoonMod.base`, `per_level`, `at`, `gains`; `SkillDef.damage_at` |
| C13-06 Elo | 12% por carta quando um Elo pode ser formado | `Boon.ELO_CHANCE`, `StageDef.elo_chance`, `BoonState.draw` |
| E3-02 `requires_sets` | o Elo pede uma Bênção de cada lista (uma lista por família): Vapor, qualquer de Chama e qualquer de Geada; Aurora Gelada e Chama Viva, a luz que acerta sozinha (Onda Maior, Flagelo); Bastião, o Escudo e qualquer de Luz; Rastro e Passo Frio, qualquer de Vigília. O primeiro de cada lista é o de antes (a carta mostra o que se tem, senão ele) | `Boon.requires_sets`, `BoonState.forged`, `sources` |
| BUG-017 | o Elo não tem raridade nem nível: sempre comum, no nível 1, com o número do nível 1 de antes; a romã nunca o oferece | `Boon.has_rarity`, `max_level` 1, `BoonState.take` |
| C13-07 (D-10) | sem bônus de sequência de golpes (era 1% por golpe até 40%); o contador continua no HUD | `DamageCalc.hit` |
| C13-04 economia | ouro cai dos inimigos: cada luta tem um teto de 10 a 15 mais 0,5 por profundidade, cada inimigo que cai tem 70% de soltar a parte dele (teto vezes a dificuldade dele sobre a da luta), até o teto; recompensa de ouro 100. Loja em 3 grupos: Bênção 150; cura 50 (40% da vida) e coração 125; dois de Magia 100, romã 100 e fatia de romã 50 (+1 nível numa Bênção sorteada, sem escolha) | `StageDef.gold_*`, `GoldPurse` (`core/gold_purse.gd`), `StageDef.shop_groups`, `ShopGroup` (`core/shop_group.gd`), `RunMap.Reward.POM_SLICE` |
| E3-05 `dealt_by` (DT-016) | dano feito por fonte no `RESULT` e no registro | `DealtBy` (`core/dealt_by.gd`), `Horde.dealt`, `Horde.dealing`, `Combat.source` |

## Decisões tomadas sem perguntar (o Daniel autorizou E2 a E6; seguem a recomendação da seção 7 do backlog)

| ID | Pergunta | Tomada | Por quê |
|---|---|---|---|
| D-52 | As quatro raridades | (a): comum, rara, épica e lendária, a lendária só pela troca | recomendação |
| D-53 | Multiplicador | (a): fixo 1,5, 2, 2,5 | recomendação |
| D-61 | Descida de 10 salas | (a): na E3 | recomendação |
| D-10 | Bônus de sequência | fora | decidido pelo Daniel |
| E3-D1 | Teto de nível das Bênçãos (o Hades II não tem) | **fica em 3** nesta entrega; a lógica já aceita sem teto (`Boon.max_level` 0) e os ganhos já repetem o último | a carta e o HUD desenham "Nível n de 3" e as bolinhas pelo teto; tirar o teto é uma mudança da tela (UI) e de balanço que pede medida |
| E3-D2 | Bênção que já se tem volta nas cartas? | **não**, como no Hades II: cresce só pela romã (porta, loja, fatia) | fidelidade (D-39); a carta é sempre algo novo, e o robô chega com 5 a 7 Bênçãos |
| E3-D3 | Números das curvas | os mesmos de antes numa carta comum (ganhos = degraus antigos); só a raridade deixou de multiplicar o ganho | "não mudar balanceamento sem pedido"; a forma do Hades II (o 2º nível metade da base, o 3º um terço) fica para a E6 |
| E3-D4 | Loja de 5 itens | a loja da sala 10 é a antessala de Morvath, a última antes do chefe final: 5 itens como no Hades II (1 Bênção, cura e coração, dois de crescimento) | com um item de cada grupo o robô comprou em 4 de 8 partidas; com 5, em 7 de 8 |
| E3-D5 | Robô escolhe a porta | fonte, Bênção, romã, coração, ouro, Magia (antes sempre a primeira porta) | o robô mede o que um jogador escolhe; com a primeira porta as Bênçãos eram o sorteio do baralho |
| E3-D6 | Cor da lendária | ouro velho `Color(0.78, 0.62, 0.34)` em `Boon.RARITY_COLOR` (a heroica era vermelha) | E3-06 pede ouro velho, nunca amarelo vivo; a moldura é da frente de UI |

## Para a frente de UI (não mexi em `scripts/ui/` nem `hud.gd`, fora o indicado)

- Por carta: `Game.offer_cards` (`Array[BoonState.Card]`): `boon`, `rarity`, `replaces` (a Bênção trocada ou null),
  **`trade`** (true na troca com +1 de raridade), `level` (o nível com que ela entra: na troca, o da que sai), `grow`
  (carta de romã). `Game._offer_rarity` continua com a raridade por id, como a `BoonChoice` lê hoje.
- Elo: `Boon.has_rarity()` é false; a carta não deve mostrar raridade nem "Novo"/nível (BUG-017); `BoonState.sources(b)`
  dá as duas de origem (as que se tem, senão a primeira de cada lista).
- Raridade 3 agora é **lendária** (`Boon.Rarity.LEGENDARY`, chave `rarity_legendary` "Lendária"; a `rarity_heroic` ficou
  no texto sem uso).
- Loja: `Rooms.shop()` dá cada item na prateleira (`item`, `price`, `group`, `at`, `affordable`) e `Rooms.gold` o ouro;
  item novo `RunMap.Reward.POM_SLICE` (chave `reward_pom_slice` "Fortalecer ao acaso"). O ouro de cada inimigo aparece
  como palavra "+n ouro" onde ele cai.
- Única mudança em `scripts/ui/`: `BoonChoice.describe` usa `BoonMod.at(level, mult)` e `SkillDef.damage_at` (a raridade
  só no nível 1), senão o texto da carta mostraria outro número que o jogo usa.
