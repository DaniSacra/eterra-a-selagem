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
## Daniel, 2026-11-23: the rest after an attack's recovery is random (AttackGap): uniform in [gap_min, gap_max] at full
## life, sliding to [gap_min0, gap_max0] at none. gap_max 0: the phase's `rest`. Rests after a roar, a stun or the ritual keep `rest`.
@export var gap_min := 0.0
@export var gap_max := 0.0
@export var gap_min0 := 0.0
@export var gap_max0 := 0.0
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
## Phases he opens from the middle of the floor (after the roar he walks there first, as for the ritual): the round
## chamber's patterns are read the same from every side (cycle C11).
@export var center_phases := PackedInt32Array([3, 4])

@export_group("Director")
@export var attacks: Array[BossAttack] = []
## Seconds of rest before the second attack of a combination (BossAttack.then).
@export var chain_rest := 0.35
## Under near the paladin is close (more scythe), over far he is far (more blades); still after this many seconds.
@export var near := 6.0
@export var far := 10.0
@export var still_after := 0.8
## Daniel 2026-11-23: he does not walk after the paladin (the scythe walks in only scythe_approach s). A new attack waits only
## while one of his shots is closer than shots_gate meters to the paladin (0: while any is flying).
@export var shots_gate := 0.0
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
## His dead rise on a ring this far around him (m), never closer than summon_clear to the paladin; the ritual's on a
## ring of ritual_ring around the middle (cycle C11: data, fitted to the chamber's 12.5 m, docs/design/boss_arena.md).
@export var summon_ring := 5.0
@export var summon_clear := 4.0
@export var ritual_ring := 6.5
## Seconds between one rise and the next: a rune glows on the floor, the energy comes up, the dead rises and the
## rune goes; each in turn, never all at once.
@export var rise_stagger := 0.45

@export_group("Layers")
## Who rises when a summon is laid over another attack (BossAttack.layers, E2): one soldier and one caster.
@export var layer_raise: Array[StringName] = [&"skeleton", &"mage"]
## Circles of eruptions laid over another attack (one volley, the first under the paladin, the free lane at that
## attack's way out: BossRules.free_way).
@export var layer_eruption_count := Vector2i(2, 2)

@export_group("Scythe")
@export var scythe_reach := 5.0
@export var scythe_degrees := 180.0
@export var scythe_windup := 0.8
@export var scythe_recovery := 1.0
@export var scythe_damage := 12.0
## Seconds he may walk in before the swing.
@export var scythe_approach := 1.2

@export_group("Double reap")
## C19-3 (Q-09 a; Hades II's Hecate: right 0.85 / 0.4 / 0.35 s and at once left 0.5 / 0.5 / 2.2 s): two sweeps
## close in. The first's wind-up reap_windup; reap_active seconds after it lands the second's warning is born (aimed
## where the paladin is then), filling over reap_pause and reap2_windup; reap_recovery after the second.
@export var reap_reach := 4.5
@export var reap_degrees := 150.0
@export var reap_windup := 0.85
@export var reap_active := 0.4
@export var reap_pause := 0.35
@export var reap2_windup := 0.5
@export var reap2_active := 0.5
@export var reap_recovery := 2.2
@export var reap_damage := 10.0

@export_group("Blades of the souls")
@export var blade_spread := 38.0
@export var blade_speed := 11.0
@export var blade_width := 3.0
@export var blade_range := 26.0
@export var blade_windup := 0.7
@export var blade_recovery := 0.8
@export var blade_damage := 10.0
## C17, Q-09 (b): the Blades come at any distance; with the paladin closer than blade_step_within he first steps
## blade_step meters back from him (over blade_step_time at the start of the wind-up, swept along the floor), and the
## lanes are laid from where he will stand, so they never start behind him nor under the paladin's feet.
@export var blade_step := 0.0
@export var blade_step_within := 0.0
@export var blade_step_time := 0.25
## A crescent comes undone this many meters past the floor's edge (it never flies on over the abyss).
@export var soul_overrun := 0.3

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
## C1d, the Condutores: each of these (the ritual's first dead of these ids) that falls cuts ritual_shorten seconds off the ritual.
@export var ritual_conductors: Array[StringName] = [&"mage"]
@export var ritual_shorten := 0.0
@export var shield_radius := 2.9

@export_group("Barrage")
## Daniel 2026-11-23, the machine gun of the last phases: barrage_count soul crescents (by phase; 0: none) leave one after the other,
## barrage_gap seconds apart (by phase), each aimed at where the paladin stands as it leaves (no lead, no fan), after
## barrage_windup (shown only by the "!"). He stands and turns after the paladin; to dodge, the paladin runs.
@export var barrage_count := PackedFloat32Array([0.0, 0.0, 8.0, 12.0])
@export var barrage_gap := PackedFloat32Array([0.25, 0.25, 0.25, 0.2])
@export var barrage_windup := 0.7
@export var barrage_speed := 12.0
@export var barrage_width := 1.3
@export var barrage_damage := 8.0
@export var barrage_recovery := 0.6
## How fast his body turns after the paladin while he fires (degrees a second).
@export var barrage_turn := 220.0

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
## C1d, the Corte do rastro: the paladin's wave (the special, an Omega) that touches the bolt undoes it (no damage, no curse); the Brado that
## takes it undoes its curse too (the blow is the Brado's, the status never lands).
@export var curse_cut := false

@export_group("Dash")
@export var dash_length := 16.0
@export var dash_time := 0.42
@export var dash_windup := 0.8
@export var dash_width := 2.8
@export var dash_damage := 12.0
@export var dash_recovery := 1.1
## The charge ends at the floor's edge (its lane cut there) and only comes when this many meters are free ahead.
@export var dash_min_free := 8.0

@export_group("Stagger")
## From this phase, stagger_hits heavy blows within stagger_forget seconds make him kneel stagger_time seconds.
@export var stagger_from_phase := 3
@export var stagger_hits := 3
@export var stagger_forget := 4.0
@export var stagger_time := 2.6

@export_group("Rupture")
## C1d, phase rupture_phase on: the first Ruptura rupture_first seconds into it, then every rupture_every seconds: a warning of
## rupture_windup s over the whole floor (no free lane), rupture_damage on whoever it finds, and he stands exposed rupture_window
## seconds after (x posture_vuln, no Postura). Only the Brado takes it whole; a dodge in time passes through it (0: none).
@export var rupture_every := 0.0
@export var rupture_first := 12.0
@export var rupture_phase := 4
@export var rupture_windup := 1.5
@export var rupture_damage := 16.0
@export var rupture_window := 3.0

@export_group("Posture")
## C1d, phase 1 on: a bar over his life, worn by the button of each blow (Feel.poise_weights, as the common's Quebra); at 0 he
## kneels posture_stun seconds and takes posture_vuln more damage, then stands with it full (0: none). The blows of a
## recovery he was punished in no longer count for it: the buttons do.
@export var posture := 0.0
@export var posture_stun := 2.6
@export var posture_vuln := 0.4
## Seconds without a blow that wears it for it to fill again.
@export var posture_idle := 5.0
## The weights of Feel.poise_weights are shares of a common's 100 poise; for him they count this much.
@export var posture_mult := 0.5
## SW-C5: each break after the first asks this many times more of the bar (SWORN 1.25; 1: always the same).
@export var posture_growth := 1.0


## The value of a per-phase list for this phase (the last value holds after; fallback when empty).
static func by_phase(list: PackedFloat32Array, phase: int, fallback: float = 1.0) -> float:
	if list.is_empty():
		return fallback
	return list[clampi(phase - 1, 0, list.size() - 1)]
