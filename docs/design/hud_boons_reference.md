# Bênçãos no HUD e na tela do Tab: Hades II, SWORN e Ravenswatch

Pesquisa de 2026-11-27 (pedido do Daniel). Só o princípio da interface; nada de arte, nomes ou números de tela deles.
Legenda: **[C]** confirmado no arquivo do jogo, **[I]** inferido (nome de classe, texto ou captura, sem ler o código que roda).

## 1. Hades II (Lua legível em `Content/Scripts/`)

| Pergunta | Resposta | Evidência |
|---|---|---|
| O que aparece na coluna da partida | Só as bênçãos **de botão** (campo `Slot`): Ataque (`Melee`), Especial (`Secondary`), Conjuro (`Ranged`), Corrida (`Rush`), Magia/Ômega (`Mana`). Uma por botão, porque o botão é exclusivo. Mais 2 posições que só aparecem no Tab: Aspecto (arma) e Familiar. **[C]** | `HUDData.lua` `SlottedTraitOrder = {Aspect, Familiar, Melee, Secondary, Ranged, Rush, Mana}`; `HUDLogic.lua` `ShowTraitUI` (só acende `Attack/Special/Cast/Dash/ManaSlotIcon` fora do Tab; `WeaponSlotIcon` e `FamiliarSlotIcon` só com `ForceShow`) |
| Onde | Coluna vertical à esquerda, de cima para baixo na ordem acima, espaço fixo por botão (90 px), com um ícone vazio do botão quando não há bênção. **[C]** | `TraitTrayData.lua` `TraitStartX = 50`, `TraitSpacingY = 90`; `HUDData.lua` `AttackSlotIcon`...`ManaSlotIcon` (moldura vazia `SlotIcon_*`) |
| Segunda fileira | Uma fileira **horizontal** embaixo da coluna com os "ativos": Lembrança (`Keepsake`), Feitiço (`Spell`), Assistência, e depois qualquer bênção que tenha contador (usos, salas restantes, recarga) ou `ShowInHUD = true`. **[C]** | `HUDData.lua` `ActiveTraitOrder = {Keepsake, Spell, Assist}`; `TraitTrayLogic.lua` `IsShownInHUD()`; `HUDLogic.lua` `TraitUIAdd` (posição `TraitStartX + i * TraitSpacingX`) |
| Como mostra o nível | Um rótulo pequeno sob o ícone **só quando o nível passa de 1**: `+N` com seta para cima (N = `StackNum`, o nível vindo das romãs). Nível 1 não mostra nada. **[C]** | `HUDLogic.lua` `TraitUICreateText` (ramo `traitCount > 1` → `UI_TraitLevel`); `Game/Text/en/HelpText.en.sjson` `UI_TraitLevel = "+{Amount}{UpArrow}"`; `TraitLogic.lua` `GetTraitCount` (= `StackNum`) |
| Raridade | Pela **moldura** do ícone (`Frame_Boon_Menu_<Raridade>`), não por texto. Se a raridade sobe, troca a moldura no lugar. **[C]** | `HUDLogic.lua` `GetTraitFrame`, `UpdateTraitNumber` |
| Estado vivo | Ícone acende/pisca quando o efeito está ativo e faz varredura de recarga (ex.: bênção com tempo de recarga). **[C]** | `HUDLogic.lua` `TraitUIActivateTrait`, `TraitUIActivateTraits` |
| O que fica de fora da partida | Toda bênção **passiva** (sem `Slot`, sem contador): não aparece no HUD. Martelos idem. **[C]** | `IsShownInHUD()` devolve falso para elas |
| O que muda no Tab | Aparece a coluna inteira (com Aspecto e Familiar) e, **à direita, em colunas de 7**, todas as bênçãos que não estão no HUD; passando de 28 (4 colunas), uma aba "Bênçãos, extra". Outras abas: Arcanos (cartas meta) e Votos (dificuldade). Clicar num ícone **fixa** o cartão de detalhes (até 8 cartões; abre com até 5 fixados sozinhos: épicas, lendárias, heroicas, duos, martelos e as de nível 2+). **[C]** | `TraitTrayLogic.lua` `TraitTrayShowTraits`, `IsPossibleTraitAutoPin`; `TraitTrayData.lua` `ItemCategories`, `TraitsPerColumn = 7`, `MaxPins = 8`, `MaxAutoPins = 5` |

Resumo: **coluna = um lugar fixo por botão**, nível como `+N` só acima de 1, raridade pela moldura; passivas só no Tab.

## 2. SWORN (Unity IL2CPP; nomes lidos do `global-metadata.dat` com o REA, versão 29)

| Pergunta | Resposta | Evidência |
|---|---|---|
| O que aparece na coluna da partida | **Seis lugares fixos**, um por ação: ataque leve, ataque pesado, esquiva, feitiço, supremo e companheiro. Não há campo para outras bênçãos no HUD. **[C]** (os nomes) | classe `OverlayUI`: campos `blessingSlots`, `lightAttackBlessing`, `heavyAttackBlessing`, `dashBlessing`, `spellBlessing`, `ultimateBlessing`, `companionBlessing` |
| Por que só as de habilidade | O jogo separa bênçãos de **lugar central** (`CoreSlotBlessings`) das **outras** (`NonCoreSlotBlessings`); as de habilidade têm campo `abilitySlot` e categoria `AbilityBlessingCategory` (`BlessingType.Ability`). O HUD só tem os 6 lugares centrais. Logo a observação do Daniel está certa: **passiva não entra na coluna**. **[C]** nomes, **[I]** a regra exata (o código de `UpdateBlessingsUI` não foi descompilado) | `BlessingGenerator.BlessingSelectionContext`: `CoreSlotBlessings`, `NonCoreSlotBlessings`; `BlessingGenerator.chanceOfPrioritizingCoreSlotBlessing`; `HasSlotBlessing` |
| Onde | Coluna lateral que **desliza para dentro e para fora** (eventos `OnShowBlessingSideBar` / `OnHideBlessingSideBar`, métodos `SlideInBlessingSlots` / `SlideOutBlessingSlots`, classe de estilo `k_BlessingSlideOutClass`). HUD em UI Toolkit. **[C]** nomes, **[I]** quando desliza (provavelmente some em cena/diálogo e volta no combate) | `OverlayUI` |
| Como mostra o nível | Selo `Lv.N` no ícone. **[I]**: o texto `Lv.{0}` está na tabela de textos em inglês (pacote comprimido, achado como trecho), e a bênção tem nível base (`IBlessingLevel.BaseLevel`); o nível sobe por uma recompensa própria (`BlessingType.BlessingLevel`, `BlessingLevelRewardEntity`), o equivalente da romã. | `localization-string-tables-english(en)` (trecho `Lv.{`); tipos `IBlessingLevel`, `BlessingType` |
| Cor por fada | A cor vem da **categoria** da bênção (a fada/Paragon): `BlessingCategory.localizedNameColor` e `icon`. **[C]** os campos, **[I]** que o HUD pinta com eles | `BlessingCategory` |
| Raridade | Comum, Incomum, Rara, Épica, Lendária, Duo, Távola Redonda. **[C]** (enum); como aparece no HUD **[I]** (moldura) | enum `BlessingRarity` |
| O que muda no Tab | Painel por jogador (co-op): nome, retrato e cor do jogador, ícone da **arma** e do **feitiço**, os **6 lugares centrais** de novo, e embaixo uma **grade rolável das "outras" bênçãos** (as passivas), N por linha; passar o mouse mostra a descrição. Cabeçalho com relógio e moedas meta. **[C]** nomes | `TabMenuUI` (`m_playerPanels`, `m_timerLabel`, `m_metaCurrencyController`, `mainSlotOffset`, `otherBlessingSlotOffset`); `TabMenuPlayerPanel` (`m_weaponIcon`, `m_spellIcon`, `m_lightAttackBlessingIcon`...`m_companionBlessingIcon`, `m_otherBlessingScrollRect`, `m_otherBlessingsContainer`, `defaultOtherBlessingsPerRow`, `OnOtherBlessingIconHoverEntered`) |
| Dica "Tab" sob a coluna | Não está no código; deve estar no layout (UXML). **[I]** (só pela captura) | |

Resumo: igual ao Hades II no princípio. **Coluna = lugares fixos de ação com `Lv.N`; passivas só no Tab, numa grade.**

## 3. Ravenswatch (só pela captura do Daniel; nada lido do jogo) **[I]**

| Pergunta | Resposta |
|---|---|
| O que aparece | Todos os talentos e itens da partida, cada um num losango pequeno (quadrado girado). |
| Onde | À esquerda, num **caminho em ziguezague de duas colunas** que sobe conforme se ganha; um vão; um segundo ziguezague embaixo (provavelmente a outra categoria, itens). |
| Nível | Número pequeno (2, 3, 4) só em alguns: o nível do talento, sem marca no nível 1. |
| Tab / fora | Não visto. |

O efeito é de "trilha da partida": mostra **tudo** e mostra a **ordem** em que veio, mas não diz de relance qual botão está mudado.

## 4. Como está hoje em A Selagem

- `Boon.Slot`: `ATTACK` (Ataque), `SPECIAL` (Especial), `CAST` (Poder; no Guerreiro é o Brado), `DASH` (Esquiva), `RUSH` (sem bênção no Guerreiro), `ULT` (Supremo). Uma bênção por botão; `NONE` = complemento/passiva, quantas quiser (`scripts/core/boon.gd`).
- Nível: `BoonState.levels`, começa em 1, sobe pela romã ("Fortalecer Bênção", `R.POM`, e "Fortalecer ao acaso", `R.POM_SLICE`); teto `max_level = 3` (1 se a bênção não cresce; Elo sempre 1) em `tools/make_data.gd` (linha ~956). Raridade multiplica o primeiro nível (`RARITY_MULT`) e tem cor (`RARITY_COLOR`). Família = anjo, cor em `FAMILY_COLOR` (9 anjos + Elo).
- HUD: `BuildColumn` na borda **direita** mostra **todas** as bênçãos (as de botão primeiro, depois as passivas), nível como pontinhos; no Tab, `BlessingGroups` agrupa por anjo; na pausa, `BoonsScreen` lista tudo com descrição.

## 5. Proposta para A Selagem

**Recomendado (opção A, molde Hades II/SWORN):**

1. **Coluna fixa de 5 lugares** no HUD, um por botão, na ordem da fileira de baixo: Ataque, Poder, Especial, Esquiva, Supremo. Lugar vazio mostra só o contorno apagado do botão (sabe-se o que falta). O Supremo fica apagado até abrir.
2. **Ícone** na cor do anjo (moldura/gema em `FAMILY_COLOR`); **raridade pela borda** (`RARITY_COLOR`), sem texto.
3. **Nível**: selo pequeno só do nível 2 em diante (`Nv 2`, `Nv 3`; ou `+1`, `+2` no molde Hades II). No teto, selo dourado "Máx". Tira os pontinhos.
4. **Passivas e Elos saem da coluna.** Em troca, uma linha curta embaixo da coluna só para o que tem **estado vivo** (recarga, cargas, contador), como a fileira de ativos do Hades II; passiva sem estado não aparece em combate. Sob a coluna, a dica da tecla Tab (ícone do teclado ou do controle, sem texto solto).
5. **Tab (segurar)**: a mesma coluna fica parada e, ao lado, **todas** as outras bênçãos em grade, **agrupadas por anjo** (o `BlessingGroups` atual serve: cabeçalho na cor do anjo, ícones com selo de nível); Elos e Salmo num grupo próprio no fim. Passar o mouse (ou o foco do controle) mostra o cartão de descrição; clique fixa até 3 cartões (versão curta do "pin" do Hades II). A pausa continua com o `BoonsScreen` completo.
6. Coluna à **esquerda** (como os dois jogos) ou mantida à direita: o retrato e as barras já estão embaixo à esquerda; a coluna pode subir a partir de cima delas sem tocar no centro. Decisão do Daniel.

**Opção B (trilha Ravenswatch):** todos os ganhos em losangos num ziguezague de duas colunas subindo, na ordem em que vieram, botões e passivas juntos, número de nível a partir de 2. Prós: mostra a história da partida e já usamos losangos. Contras: com 9 anjos e várias passivas a trilha fica longa e não responde de relance "o que meu Ataque faz agora"; o Tab ainda precisaria agrupar.

**Opção C (mista):** coluna de 5 lugares (opção A) e, só no Tab, a trilha em ziguezague das passivas no lugar da grade. Fica com a leitura rápida dos botões e o charme da trilha onde há espaço.

Código afetado (para quem implementar): `scripts/ui/build_column.gd` (lugares fixos, selo de nível, filtrar `Slot.NONE`), `scripts/ui/blessing_groups.gd` (grade do Tab ao lado da coluna, cartão ao passar o mouse), `scripts/ui/boon_icon.gd` (selo em vez de pontinhos); textos novos em `data/text_pt.tres`. A lógica de quais bênçãos vão à coluna (`slot != NONE` e dono do lugar, `BoonState.in_slot`) já existe e é testável.
