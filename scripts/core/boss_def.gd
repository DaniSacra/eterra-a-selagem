class_name BossDef
extends Resource
## Every number of a boss fight, so it is tuned without code: phases, the attacks the director chooses among, and
## the timings, sizes and damage of each attack. data/bosses/<id>.tres, written by tools/make_data.gd (the source of
## truth). Distances in meters, times in seconds, damage on the scale of the paladin's 30 life.

@export var id: StringName = &""
## The EnemyDef that stands for the boss (life, speed, model, colour of its magic).
@export var enemy: StringName = &""

@export_group("Phases")
## Share of life where each next phase begins (descending): 3 values make 4 phases. The blow that crosses one stops
## at it: every phase begins exactly once, in order.
@export var thresholds := PackedFloat32Array([0.66, 0.33, 0.15])
## Phase that begins with the ritual (0: none).
@export var ritual_phase := 2
## Seconds he rests between attacks, by phase (the last value holds after).
@export var rest := PackedFloat32Array([1.1, 1.0, 0.9, 0.75])
## Wind-ups of every attack times this, by phase.
@export var windup_scale := PackedFloat32Array([1.0, 1.0, 0.95, 0.9])
## The roar that opens a phase (he does not attack, the paladin is thrown back push meters).
@export var roar_time := 1.6
@export var roar_push := 4.0
## Phase from which the arena's light turns to his spectral fire.
@export var final_light_phase := 4
## The first attack of each phase, right after its roar (empty: the director's choice): the new pattern is shown at
## once, so the player reads that something changed.
@export var phase_openers: Array[StringName] = [&"", &"", &"curse", &"storm"]

@export_group("Director")
@export var attacks: Array[BossAttack] = []
## Seconds of rest before the second attack of a combination (BossAttack.then).
@export var chain_rest := 0.35
## Under near the paladin is close (more scythe), over far he is far (more blades); still after this many seconds.
@export var near := 6.0
@export var far := 10.0
@export var still_after := 0.8
## A moving paladin is aimed at this share of the way he goes during the flight (never a perfect lead).
@export var lead := 0.45

@export_group("Reinforcements")
## Most of his summons standing at once outside the ritual, by phase.
@export var adds_cap := PackedInt32Array([0, 4, 4, 4])
## The occasional summon: who rises, and the wind-up (a warning on each spot).
@export var summon_raise: Array[StringName] = [&"skeleton", &"skeleton"]
@export var summon_windup := 1.1
## Most of his summons over the whole fight (the ritual's included); past it he calls nobody.
@export var adds_total_cap := 20
## Seconds between one rise and the next: a rune glows on the floor, the energy comes up, the dead rises and the
## rune goes; each in turn, never all at once.
@export var rise_stagger := 0.45

@export_group("Scythe")
@export var scythe_reach := 5.0
@export var scythe_degrees := 180.0
@export var scythe_windup := 0.8
@export var scythe_recovery := 1.0
@export var scythe_damage := 12.0
## Seconds he may walk in before the swing.
@export var scythe_approach := 1.2

@export_group("Blades of the souls")
@export var blade_spread := 38.0
@export var blade_speed := 11.0
@export var blade_width := 3.0
@export var blade_range := 26.0
@export var blade_windup := 0.7
@export var blade_recovery := 0.8
@export var blade_damage := 10.0

@export_group("Storm of the six souls")
@export var storm_count := 6
@export var storm_jitter := 7.0
## No two neighbouring crescents closer than this (degrees): a way out always stays open.
@export var storm_min_gap := 48.0
@export var storm_waves := 2
## The second wave turns this much from the first, after storm_gap seconds.
@export var storm_turn := 30.0
@export var storm_gap := 1.0
@export var storm_windup := 0.9
@export var storm_recovery := 1.2
@export var storm_damage := 10.0
## Seconds between one crescent of a wave and the next (each its own lane and its own warning): never one burst.
@export var storm_stagger := 0.08

@export_group("Eruptions")
@export var eruption_radius := 2.0
@export var eruption_delay := 0.9
@export var eruption_count := Vector2i(2, 3)
## Degrees of the lane kept free around the way to the middle of the hall.
@export var eruption_lane := 120.0
@export var eruption_sequences := 2
@export var eruption_gap := 1.0
@export var eruption_damage := 10.0
@export var eruption_recovery := 0.8

@export_group("Ritual")
@export var ritual_time := 20.0
@export var ritual_raise: Array[StringName] = [&"skeleton", &"skeleton", &"mage", &"mage"]
@export var ritual_cap := 6
@export var ritual_reinforce_every := 6.0
@export var ritual_reinforce: Array[StringName] = [&"skeleton", &"mage"]
@export var ritual_eruption_every := 2.8
## He kneels this long when the shield breaks.
@export var ritual_stun := 2.0
@export var shield_radius := 2.9

@export_group("Curse")
@export var curse_windup := 0.8
@export var curse_speed := 7.0
## Degrees a second the curse turns after the paladin, for curse_homing seconds of its flight.
@export var curse_turn := 75.0
@export var curse_homing := 1.4
@export var curse_life := 4.0
@export var curse_radius := 0.55
@export var curse_damage := 6.0
@export var curse_time := 3.0
@export var curse_slow := 0.3
@export var curse_immunity := 2.0
@export var curse_recovery := 0.6

@export_group("Dash")
@export var dash_length := 16.0
@export var dash_time := 0.42
@export var dash_windup := 0.8
@export var dash_width := 2.8
@export var dash_damage := 12.0
@export var dash_recovery := 1.1

@export_group("Stagger")
## From this phase, stagger_hits heavy blows within stagger_forget seconds make him kneel stagger_time seconds.
@export var stagger_from_phase := 3
@export var stagger_hits := 3
@export var stagger_forget := 4.0
@export var stagger_time := 2.6


## The value of a per-phase list for this phase (the last value holds after; fallback when empty).
static func by_phase(list: PackedFloat32Array, phase: int, fallback: float = 1.0) -> float:
	if list.is_empty():
		return fallback
	return list[clampi(phase - 1, 0, list.size() - 1)]
