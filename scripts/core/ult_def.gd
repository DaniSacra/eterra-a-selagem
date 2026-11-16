class_name UltDef
extends Resource
## A hero's ultimate (D-54; docs/design/warrior_spec.md 3.2, ultimate_u2_proposals.md): charged by the Magia spent on
## Omegas, one chosen before the descent, unlocked by Mastery. Only the numbers for now (no behaviour yet): written by
## _ultimates in tools/make_data.gd, read by HeroDef.ultimates.

## CLEAVE: a band in front of the hero (U-1). VORTEX: an area thrown ahead that pulls the pack in a spiral and
## implodes (U-2, the Voragem).
enum Kind { CLEAVE, VORTEX }

@export var id: StringName
@export var name_key: StringName
@export var desc_key: StringName
@export var kind: Kind = Kind.CLEAVE
## Magia spent on Omegas to fill it (Hades II: Sky Fall 60, Moon Water 70).
@export var charge := 60.0
@export_range(1, 20) var mastery_level := 2
## The protected gesture that starts it (cuts the blow in progress, as the dodge does).
@export var gesture := 0.3
## What the Blessings see (one action's tags plus ultimate; never finisher nor omega).
@export var tags: Array[StringName] = [&"ultimate"]

@export_group("Cleave")
## The band: meters ahead and across; its middle strip (core_width) takes core_damage, the rest damage.
@export var length := 12.0
@export var width := 4.0
@export var core_width := 1.5
@export var core_damage := 300.0
@export var damage := 200.0
## Seconds common enemies stay stunned; how many times the damage armor takes.
@export var stun := 1.0
@export var armor_mult := 2.0

@export_group("Vortex")
## Where it lands: meters ahead on the aim (up to aim_max with the mouse); its radius (never past radius_cap with
## Blessings) and how long it stays.
@export var ahead := 4.0
@export var aim_max := 8.0
@export var radius := 6.0
@export var radius_cap := 7.5
@export var duration := 4.0
## Damage every tick seconds to whoever is inside, then the implosion within implode_radius (stun for commons).
@export var tick := 0.25
@export var tick_damage := 8.0
@export var implode_damage := 120.0
@export var implode_radius := 3.0
@export var implode_stun := 0.8
## The pull, meters a second at the edge, falling to nothing at the core: towards the middle and along the spiral.
@export var pull := 3.5
@export var swirl := 2.0
@export var core := 1.2
## Share of the pull elites and guardians feel (Morvath is never pulled, only slowed).
@export var elite_pull := 0.5
@export var guardian_pull := 0.25
