class_name EncounterPool
extends Resource
## One way a fight can be put together (StageDef.pools, written by tools/make_data.gd): the parts its enemies play
## (EnemyDef.role, one kind for each), how hard it is (StageDef.Tier: how many stand at once) and where in the region
## it can be drawn. A few kinds, each with a clear job, as in Hades II: the region starts with two simple parts,
## adds a third that complements them, and ends with demanding mixes that may bring elites.

## How many enemies stand at once (StageDef.tier_alive): COMMON 4 to 8, HARD 8 to 12, SPECIAL 12 to 16.
@export var tier: StageDef.Tier = StageDef.Tier.COMMON
## Where in the region it can be drawn: 0 is the first room, 1 the last fight before the shop (EncounterGen.progress).
@export_range(0.0, 1.0) var from := 0.0
@export_range(0.0, 1.0) var until := 1.0
## How often it is drawn among the pools of that point of the region.
@export var weight := 1.0
## One kind of enemy for each part (EnemyDef.role: pressure, react, control, flank, block, area). The first is the
## highlight of the fight: it comes in every wave.
@export var roles: Array[StringName] = []
## Chance that a part comes in its elite version (at most StageDef.max_elite_types, never before elite_from_depth).
@export_range(0.0, 1.0) var elite_chance := 0.0
