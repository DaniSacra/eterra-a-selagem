class_name ArcaneKit
extends Resource
## The Maga's numbers (redesign 2026-11-24, 04_PLANO C.1 to C.3): Centelha, Combustão, Estilhaço, Geada, Arco Voltaico, the
## elemental states (Elementos), the Suspensão Arcana, the Passo Etéreo and the Convergência Elemental. A hero with one has the
## arcane kit (HeroDef.arcane; the Warrior has none). Written by _maga in tools/make_data.gd; played by Arcane
## (scripts/game/arcane.gd); the states and reactions are ElementBook (pure). Prototype numbers: the balance-designer validates them.

@export_group("Centelha")
## Damage of the bolt, how far it flies, hits on one target within `window` seconds that put Queimadura on it, Magia a hit
## (KitFeed.take caps it by HeroDef.gain_cap).
@export var spark_damage := 8.0
@export var spark_range := 11.0
@export var spark_hits := 3
@export var spark_window := 4.0
@export var shot_magick := 1.0

@export_group("Combustão")
@export var combust_damage := 70.0
@export var combust_radius := 2.0
@export var combust_knockback := 4.0

@export_group("Estilhaço")
@export var shard_damage := 6.0
@export var shard_slow_time := 2.0

@export_group("Geada")
## Where it may be put (meters from her), radius, seconds it stands and damage a second to whoever is in it; Frio applied every `frost_step`.
@export var frost_range := 8.0
@export var frost_radius := 2.5
@export var frost_time := 4.0
@export var frost_dps := 5.0
@export var frost_step := 1.0

@export_group("Arco Voltaico")
@export var arc_damage := 12.0
@export var arc_targets := 3
@export var arc_range := 9.0
@export var arc_jump := 5.0

@export_group("Elementos")
## The numbers of ElementBook (these are its defaults).
@export var burn_time := 3.0
@export var burn_dps := 4.0
@export var volt_time := 3.0
@export var cold_time := 3.0
@export var cold_freeze_at := 3
@export var slow_pct := 0.3
@export var react_gap := 0.5
@export var thermal := 35.0
@export var overload := 25.0
@export var overload_radius := 1.8
@export var crystal_freeze := 0.8
@export var crystal_boss_poise := 25.0
## Seconds an enemy hit by Frio is frozen when the third hit lands (Frio completo).
@export var freeze_time := 0.8

@export_group("Convergência Elemental")
@export var converge_radius := 5.0
@export var converge_phase := 1.5
@export var converge_tick := 0.5
@export var converge_damage := 90.0
@export var converge_aim_max := 9.0
@export var converge_boss_share := 0.25

@export_group("Suspensão Arcana")
@export var dome_radius := 2.6
@export var dome_time := 2.5
@export var dome_slow := 0.4

@export_group("Passo Etéreo")
## Meters, protected seconds (14 frames), and the meters it may pass through a body (it ends on free floor).
@export var blink_distance := 4.5
@export var blink_iframes := 14.0 / 60.0


## A book with these numbers (Gifts add theirs on top: Arcane._configure).
func make_book() -> ElementBook:
	var b := ElementBook.new()
	b.burn_time = burn_time
	b.burn_dps = burn_dps
	b.volt_time = volt_time
	b.cold_time = cold_time
	b.cold_freeze_at = cold_freeze_at
	b.react_gap = react_gap
	b.thermal = thermal
	b.overload = overload
	b.overload_radius = overload_radius
	b.crystal_freeze = crystal_freeze
	b.crystal_boss_poise = crystal_boss_poise
	return b


## The plan of the Convergência with this kit's numbers.
func converge_plan() -> ConvergePlan:
	var p := ConvergePlan.new()
	p.phase_time = converge_phase
	p.tick = converge_tick
	p.direct_damage = converge_damage
	return p


## Where a spell aimed at `cursor` from `from` falls: at most `reach` meters from her.
static func spot(from: Vector2, cursor: Vector2, reach: float) -> Vector2:
	return from + (cursor - from).limit_length(reach)
