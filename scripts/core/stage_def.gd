class_name StageDef
extends Resource
## One region of the descent played room by room, with the room generator and the numbers of the first region of
## Hades II (study only: our rooms, enemies and rewards). data/stages/*.tres, written by tools/make_data.gd.

## How hard a fight is: how many enemies stand at once (tier_alive). Guardians and elites make a fight HARD; the
## rare special fights at the bottom of the region are SPECIAL.
enum Tier { COMMON, HARD, SPECIAL }

@export_group("Rooms")
## Depth of the last room before the boss (the shop). The boss comes right after it.
@export var rooms := 10
## No arena is fought in more than this many times in a descent (C13-01; the hall counts its opening, fountain, shop).
@export var arena_max_uses := 3
## The guardian room comes at one depth between these two.
@export var miniboss_depth_min := 4
@export var miniboss_depth_max := 6
## Guardians that can stand in that room (side by side behind its two doors).
@export var minibosses: Array[StringName] = []
## Daniel, 2026-11-22 ("enfrentar os 2 minibosses e só depois o boss"): the other guardian, the one he did not choose,
## comes at one depth between these two, behind one door, at least miniboss_gap rooms after the first (0: none).
@export var miniboss2_depth_min := 0
@export var miniboss2_depth_max := 0
@export var miniboss_gap := 3
## One of the two doors before the guardian's is always a fountain (GP-2); with fountain_more_chance another one, past
## him and between these depths (RunMap).
@export var fountain_depth_min := 5
@export var fountain_depth_max := 8
@export var fountain_more_chance := 0.35
@export var boss: StringName = &"morvath"
## Room shapes the generator draws from (the boss and the shop have their own).
@export var layouts: Array[RoomLayout] = []
@export var boss_layout: RoomLayout
@export var shop_layout: RoomLayout
## The two rooms of the events (E5): the Provação's chamber and the Altar Esquecido.
@export var trial_layout: RoomLayout
@export var altar_layout: RoomLayout

@export_group("Map")
## The first depth whose door may promise a pomegranate (Q-25 a: the hall gives a Blessing, the room after may still not
## have one to grow).
@export var pom_from_depth := 3
## OF-05 (Ofícios, Q-OF3 a; anti-farming): a door of Prata only from this depth, a door of Memória only past the
## guardian's layer (0 and false: anywhere, the maps of before).
@export var silver_from_depth := 0
@export var memory_after_guardian := false

@export_group("Encounters")
## Enemies of the region, elite versions included (each listed once; an elite blocks its plain version).
@export var enemies: Array[StringName] = []
## Difficulty of a room = (base + depth * ramp), never under min_difficulty.
@export var base_difficulty := 55.0
@export var depth_ramp := 15.0
@export var min_difficulty := 10.0
## C1b (combate_c1b.md, Frente 2): the share of the difficulty each room is given, by depth (depth 1 is the first; a depth
## past the list, or an empty list: 1.0). Lower after a hard room, so a fight is followed by breath (EncounterGen.budget).
@export var room_budget := PackedFloat32Array()
## C1b: from this depth a fight may have one bigger version of a kind (EnemyDef.big_version) with the chance below
## (0: never), always beside another kind and never in an arena with a hazard.
@export var big_from_depth := 4
@export var big_chance := 0.0
## C1e (inimigos_c1e.md): the modifiers (ModDef ids) a head of a fight may be born with, from this depth: the chance of each eligible
## head, then mod_step more each room, at most mod_per_room in a fight, one on a head.
@export var mods: Array[StringName] = []
@export var mod_from_depth := 8
@export var mod_chance := 0.0
@export var mod_step := 0.05
@export var mod_per_room := 2
@export var min_waves := 1
@export var max_waves := 3
## Elite kinds in one fight, at most.
@export var max_elite_types := 1
## Elite versions only appear from this depth on.
@export var elite_from_depth := 3
## Share of the room's difficulty in each wave, by number of waves (1, 2, 3).
@export var wave_split: Array[PackedFloat32Array] = [PackedFloat32Array([1.0]), PackedFloat32Array([0.5, 0.5]), PackedFloat32Array([0.3, 0.15, 0.55])]
## Nobody rises past this many enemies standing at once, summons and reinforcements included (Daniel, 2026-11-15:
## few enemies, each with its part; the technical tests --horde and --stress ignore it).
@export var alive_cap := 20
## The fewest and the most enemies standing at once in a fight of each Tier (COMMON, HARD, SPECIAL); the most grows
## from the fewest at the top of the region to the most at its bottom (EncounterGen.cap).
@export var tier_alive: Array[Vector2i] = [Vector2i(4, 8), Vector2i(8, 12), Vector2i(12, 16)]
## The ways a fight can be put together (EncounterPool: parts, tier, where in the region, weight).
@export var pools: Array[EncounterPool] = []
## The guardian's room is a fight of this tier (its summons stand under the tier's most).
@export var miniboss_tier: Tier = Tier.HARD
@export var spawn_interval_min := 0.2
@export var spawn_interval_max := 0.4
## The next wave comes when this many of the last are left standing, after wave_delay seconds.
@export var wave_remaining := 1
@export var wave_delay := 0.5

@export_group("Rewards")
## The deck the doors' rewards are drawn from (RunMap.Reward, each card listed once per copy; C13-02, Hades II's
## RunProgress): drawn without putting back, filled again when no card left fits (RewardDeck).
@export var reward_deck: PackedInt32Array = []
## The gold of a fight (C13-04, Hades II): a ceiling drawn between gold_cap_min and gold_cap_max plus gold_per_depth a
## room of depth; each enemy that falls leaves its share of it with gold_drop_chance (GoldPurse).
@export var gold_cap_min := 10
@export var gold_cap_max := 15
@export var gold_per_depth := 0.5
@export var gold_drop_chance := 0.7
## The gold of a gold reward.
@export var gold_reward := 100
## A heart: more life (and that much healed). Magia: more Magia.
@export var heart_life := 25.0
@export var magick_more := 30.0
## The fountain heals this share of life.
@export var fountain_heal := 0.4

@export_group("Materials")
## What the descent brings home (Rejogabilidade, Fatia 1; sistemas.md 1.2): Prata Antiga by an elite felled, a door of
## Prata, a guardian won, each of Morvath's phases reached (silver_phase each, up to phase_max) and the sealing;
## Fragmentos de Memória by a door of Memória, a guardian won, a Provação won and the sealing.
@export var silver_elite := 1
@export var silver_door := 10
@export var silver_guardian := 6
@export var silver_phase := 2
@export var phase_max := 4
@export var silver_victory := 10
## SR-P5 (the relic in the stone, an object of the room he uses with interact once the fight is won): the share of the
## fights that hold one (in the arenas with RoomLayout.relic_spots, from relic_from_depth on, drawn from the room's own
## dice, never the run's), what it gives (gold, or Prata Antiga: the room's dice again). Theme to confirm with the Daniel.
@export var relic_chance := 0.5
@export var relic_from_depth := 3
@export var relic_gold := 30
@export var relic_silver := 6
@export var memory_door := 3
@export var memory_guardian := 2
@export var memory_trial := 2
@export var memory_victory := 3
## Fatia 2: Esmeralda by Morvath's phase emerald_phase_at reached (once) and the sealing (sistemas.md 1.2).
@export var emerald_phase_at := 3
@export var emerald_phase := 1
@export var emerald_victory := 1

@export_group("Fatia 2")
## The doors of the Fatia 2 (sistemas.md 1.6, 1.7, 3.6): a Psalm's door from this depth; at most enchant_max Encantos on
## a way (doors and the shop), the second only from enchant_second_from (Hades II's late hammer); the angels' deck: one
## card for each Blessing's door, 1 = a meeting of two angels, 0 = one angel shown on the door.
@export var psalm_from_depth := 4
@export var enchant_max := 2
@export var enchant_second_from := 5
@export var angel_deck: PackedInt32Array = [1, 1, 0, 0, 0, 0]

@export_group("Blessings")
## Rarity chances of a card, tried in turn (rare, epic, legendary; BoonState.roll_rarity), and the guardian's.
@export var rarity_chance: Array[float] = Boon.RARITY_CHANCE
@export var guardian_rarity_chance: Array[float] = Boon.RARITY_CHANCE_GUARDIAN
## Chance a card is an Elo (when one can be formed) and chance it is a trade (E3-01).
@export var elo_chance := Boon.ELO_CHANCE
@export var trade_chance := Boon.TRADE_CHANCE
## Chance a card is a Psalm when one can be offered (E4, Psalms.fill): a room's and the guardian's.
@export var psalm_chance := Psalms.CHANCE
@export var guardian_psalm_chance := Psalms.CHANCE_GUARDIAN

@export_group("Shop")
## The shop shows one item of each group (C13-04, Hades II's WorldShop: a Blessing; healing or life; growth).
@export var shop_groups: Array[ShopGroup] = []
## The cure sold in the shop heals this share of life.
@export var shop_heal := 0.4

@export_group("Events")
## The Provação (E5; Hades II's Chaos, Trials): the chance a room just won shows its slab, the depths where it may
## (a curse of 3 to 5 fights must have fights left to carry it), rooms before it may show again (Hades II: 10), the
## life it asks (ceil(base + per_depth x depth)), the cards in its chamber and their rarity (Hades II's Chaos: rare
## 40%, epic 10%).
@export var trial_chance := 0.2
@export var trial_depth_min := 2
@export var trial_depth_max := 7
@export var trial_cooldown := 10
@export var trial_cost_base := 10.0
@export var trial_cost_per_depth := 0.5
@export var trial_cards := 3
@export var trial_rarity_chance: Array[float] = [0.4, 0.1, 0.0]
## The Altar Esquecido (E5, Altar): a door to it once in a run, within these depths, with this chance a room; what its
## two trades ask and give.
@export var altar_depth_min := 2
@export var altar_depth_max := 8
@export var altar_chance := 0.2
## DV-2 (MAP-09, Q-26 b): a smaller shop on some branches between these depths (one layer at most, never on every way:
## a layer with two rooms or more), route_shop_chance a layer, route_shop_items items (one of each shop group).
@export var route_shop_depth_min := 6
@export var route_shop_depth_max := 8
@export var route_shop_chance := 0.0
@export var route_shop_items := 3
@export var altar_life_cost := 10.0
@export var altar_gold_cost := 75
@export var altar_magick := 25.0
