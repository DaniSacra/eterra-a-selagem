class_name StageDef
extends Resource
## One region of the descent played room by room, with the room generator and the numbers of the first region of
## Hades II (study only: our rooms, enemies and rewards). data/stages/*.tres, written by tools/make_data.gd.

@export_group("Rooms")
## Depth of the last room before the boss (the shop). The boss comes right after it.
@export var rooms := 10
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
## Kinds of enemy in a room: min_types plus types_per_depth for each depth, up to max_types.
@export var min_types := 2
@export var types_per_depth := 0.2
@export var max_types := 3
@export var min_waves := 1
@export var max_waves := 3
@export var max_elite_types := 1
## Elite versions only appear from this depth on.
@export var elite_from_depth := 3
## Share of the room's difficulty in each wave, by number of waves (1, 2, 3).
@export var wave_split: Array[PackedFloat32Array] = [PackedFloat32Array([1.0]), PackedFloat32Array([0.5, 0.5]), PackedFloat32Array([0.3, 0.15, 0.55])]
## Enemies on the floor at once: base + per depth, up to max.
@export var cap_base := 4.0
@export var cap_per_depth := 0.35
@export var cap_max := 10
@export var spawn_interval_min := 0.2
@export var spawn_interval_max := 0.4
## The next wave comes when this many of the last are left standing, after wave_delay seconds.
@export var wave_remaining := 1
@export var wave_delay := 0.5

@export_group("Rewards")
## What a door can promise (RunMap.Reward) and how often.
@export var rewards: PackedInt32Array = []
@export var reward_weights: PackedFloat32Array = []
## Gold left by every cleared fight, and the gold of a gold reward.
@export var room_gold_min := 10
@export var room_gold_max := 15
@export var gold_reward := 100
## A heart: more life (and that much healed). Magia: more Magia.
@export var heart_life := 25.0
@export var magick_more := 30.0
## The fountain heals this share of life.
@export var fountain_heal := 0.4

@export_group("Shop")
## What the shop sells (RunMap.Reward) and the price of each.
@export var shop_items: PackedInt32Array = []
@export var shop_prices: PackedInt32Array = []
## The cure sold in the shop heals this share of life.
@export var shop_heal := 0.4
