class_name BossAttack
extends Resource
## One attack a boss may choose (BossDirector): when it is allowed, how often, and how the paladin's distance and
## stillness tilt the choice. The attack itself (its warning, timings, damage) is the boss's own (BossDef numbers).

@export var id: StringName = &""
## First phase it is used in, and the last (0: every phase after).
@export var from_phase := 1
@export var until_phase := 0
@export var weight := 1.0
## Daniel 2026-11-23: from late_from_phase on (0: never) the weight is late_weight (the last phases lean on the far attacks).
@export var late_from_phase := 0
@export var late_weight := 0.0
## Seconds before it may be chosen again.
@export var cooldown := 0.0
## Only chosen with the paladin between these distances (m).
@export var min_dist := 0.0
@export var max_dist := INF
## Its weight times these when the paladin is near (under BossDef.near), far (over BossDef.far) or standing still.
@export var near_bias := 1.0
@export var far_bias := 1.0
@export var still_bias := 1.0
## Most times in a row it may come.
@export var streak := 1
## A combination: from then_from_phase on, right after this attack's recovery the boss follows with `then` (chance
## then_chance) after only BossDef.chain_rest, but never while anything of the first is still on the floor or in
## the air: each blow keeps its whole warning (BossRules.chain_ready).
@export var then: StringName = &""
@export var then_chance := 0.0
@export var then_from_phase := 0
## Layers (E2, the harder end of the fight): from layer_from_phase on, with chance layer_chance, other patterns are
## laid over this attack while it runs (&"eruptions": circles on the floor whose free lane points at this attack's
## way out, BossRules.free_way; &"summon": BossDef.layer_raise rising around him under the phase's ceiling). They
## are laid layer_share of this attack's wind-up after it begins (0: with its first warning, 1: as it lands).
@export var layers: Array[StringName] = []
@export var layer_from_phase := 0
@export var layer_chance := 0.0
@export var layer_share := 0.0


## The weight in this phase (late_weight from late_from_phase on).
func weight_in(phase: int) -> float:
	return late_weight if late_from_phase > 0 and phase >= late_from_phase else weight


func allowed_in(phase: int) -> bool:
	return phase >= from_phase and (until_phase <= 0 or phase <= until_phase)


## The layers laid over this attack in this phase (empty when it has none yet).
func layers_in(phase: int) -> Array[StringName]:
	if layers.is_empty() or layer_from_phase <= 0 or phase < layer_from_phase:
		return []
	return layers
