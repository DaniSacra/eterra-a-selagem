class_name ModDef
extends Resource
## C1e (docs/design/inimigos_c1e.md): a modifier a common enemy may be born with in the deep rooms (StageDef.mods), one on a head,
## shown by a thin ring of its colour at the feet (no reserved colour: not the red of danger, the emerald, the violet, the elites'
## gold). Data in data/mods, written by tools/make_data.gd; what each one does is only these numbers.

@export var id: StringName
@export var name_key: StringName
@export var ring := Color.WHITE
## Furioso: its attacks come this much faster (its cooldown runs 1 + attack_pace times as fast; its warning is never cut).
@export var attack_pace := 0.0
## Detonante: felled, it leaves burst_arms short lances in a cross (burst_reach m long, burst_width across, burst_damage), warned burst_time s.
@export var burst_arms := 0
@export var burst_reach := 3.0
@export var burst_width := 0.7
@export var burst_damage := 8.0
@export var burst_time := 0.7
## Escoltado: it is born with this many of escort_kind (an EnemyDef id) round it.
@export var escort_count := 0
@export var escort_kind: StringName = &"skeleton_raised"
## Regenerante: every regen_after s without a blow it takes regen_hp of its life back.
@export var regen_hp := 0.0
@export var regen_after := 3.0
## Eco: felled the first time, it lies as a mound echo_time s and rises with echo_share of its life, once (0: none).
@export var echo_time := 0.0
@export var echo_share := 0.4
