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
## Guardians that can stand in that room (one is drawn).
@export var minibosses: Array[StringName] = []
## The fountain room comes once, between these depths (forced at the last one).
@export var fountain_depth_min := 5
@export var fountain_depth_max := 8
@export var fountain_chance := 0.35
@export var boss: StringName = &"morvath"
## Chance that a cleared room shows three doors instead of two.
@export var three_doors_chance := 0.25
## Room shapes the generator draws from (the boss and the shop have their own).
@export var layouts: Array[RoomLayout] = []
@export var boss_layout: RoomLayout
@export var shop_layout: RoomLayout

@export_group("Encounters")
## Enemies of the region, elite versions included (each listed once; an elite blocks its plain version).
@export var enemies: Array[StringName] = []
## Difficulty of a room = (base + depth * ramp), never under min_difficulty.
@export var base_difficulty := 55.0
@export var depth_ramp := 15.0
@export var min_difficulty := 10.0
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
