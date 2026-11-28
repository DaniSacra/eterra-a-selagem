class_name ArcaneKit
extends Resource
## The Maga's numbers (redesign 2026-11-24, 04_PLANO C.1 to C.3; Maga Redesign V1 2026-11-28, docs/design/heroes/maga_redesign_v1_pack/):
## Centelha (a fan of three), Sopro Glacial (a cone), Combustão, Inverno Eterno (the old Geada's code), the elemental states (Elementos), the
## Tempestade Celestial (the Supremo), the Passo Etéreo. The Estilhaço, the Arco Voltaico, the Suspensão Arcana and the Convergência left the
## active kit (their code and numbers stay for a Gift or a save to come). The damage, area and cost of the held spells live in their ComboNode
## (power_max, area, magick_cost_max: the release charge). A hero with one has the
## arcane kit (HeroDef.arcane; the Warrior has none). Written by _maga in tools/make_data.gd; played by Arcane
## (scripts/game/arcane.gd); the states and reactions are ElementBook (pure). Prototype numbers: the balance-designer validates them.

@export_group("Centelha")
## Damage of the bolt, how far it flies, hits on one target within `window` seconds that put Queimadura on it, Magia a hit
## (KitFeed.take caps it by HeroDef.gain_cap). GP-5: the Centelha gives no Magia (0).
@export var spark_damage := 11.0
@export var spark_range := 11.0
@export var spark_hits := 1
@export var spark_window := 4.0
@export var shot_magick := 0.0

@export_group("Centelha e Sopro")
## The Centelha's fan: shots at once and degrees over all of them (the three bolts of one cast are ONE conjuration: one reaction at most
## a target, one Reciprocidade). The Sopro Glacial: damage, how far, the cone's opening and the metres it shoves.
@export var spark_fan := 3
@export var spark_fan_deg := 24.0
@export var breath_damage := 12.0
@export var breath_range := 5.0
@export var breath_deg := 90.0
@export var breath_knockback := 2.0

@export_group("Combustão")
## The burst's shove (the damage and the radius ride on the shot: ComboNode power_max, area). `combust_damage` and `combust_radius` are
## the old fixed ones, used by a shot that carries no charge of its own.
@export var combust_damage := 70.0
@export var combust_radius := 2.0
@export var combust_knockback := 4.0
## Radius of the floor Manifestação leaves burning (the Chão Ardente's old number, now the kit's own).
@export var ember_radius := 2.0

@export_group("Estilhaço")
@export var shard_damage := 10.0
@export var shard_slow_time := 2.0

@export_group("Inverno Eterno")
## Where it may be put (meters from her), the radius of a ground with no charge of its own, seconds it stands (5) and damage a second to
## whoever is in it; Frio applied every `frost_step` (the area itself is the node's: 2 m at the least charge, 6 m at the most).
@export var frost_range := 8.0
@export var frost_radius := 2.5
@export var frost_time := 5.0
@export var frost_dps := 6.0
@export var frost_step := 1.0

@export_group("Arco Voltaico")
@export var arc_damage := 20.0
@export var arc_targets := 3
@export var arc_range := 9.0
@export var arc_jump := 5.0

@export_group("Elementos")
## The numbers of ElementBook (these are its defaults).
## V2 (Ressonância, maga_v2 4): the three states last 4 s (1 s more than the book's own 3).
@export var burn_time := 4.0
@export var burn_dps := 4.0
@export var volt_time := 4.0
@export var cold_time := 4.0
@export var cold_freeze_at := 3
@export var slow_pct := 0.3
@export var react_gap := 0.5
@export var thermal := 45.0
@export var overload := 30.0
@export var overload_radius := 1.8
@export var crystal_freeze := 0.8
@export var crystal_boss_poise := 25.0
## Seconds an enemy hit by Frio is frozen when the third hit lands (Frio completo).
@export var freeze_time := 0.8

@export_group("Supremo e Dons")
## Charge of the Convergência a reaction gives, and the most one cast may give (GP-5 7; never while the Convergência runs).
@export var react_charge := 5.0
## Ressonância (V2 passive, always on): the Magia a reaction gives back, once a conjuration (the Reciprocidade adds its own on top).
## Maga Redesign V1: OFF by default (the pack proposes no Magia back from a reaction in the basic kit); a number here turns it on.
@export var reaction_magick := 0.0
@export var react_charge_cap := 10.0

@export_group("Tempestade Celestial")
## The Supremo (ChainPlan): the first bolt's damage, the distinct bodies it may cross, how far it jumps (the first target is up to
## storm_reach from her), the share of damage each jump loses, the strikes on one body when nothing else is near (an isolated boss) and
## the seconds between jumps (so each leap reads).
@export var storm_damage := 90.0
@export var storm_targets := 6
@export var storm_jump := 5.0
@export var storm_reach := 9.0
@export var storm_falloff := 0.1
@export var storm_solo := 3
@export var storm_step := 0.1
## The share of the damage Morvath takes (the common bodies take it all, an elite and a guardian their UltDef shares).
@export var storm_boss_share := 0.5

@export_group("Convergência Elemental")
## Out of the active kit (Maga Redesign V1): the numbers stay for a reserve Supremo.
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


## The unit directions of a fan of `count` shots opened `total_deg` degrees in all around `dir` (one: `dir` itself).
static func fan(dir: Vector2, count: int, total_deg: float) -> Array[Vector2]:
	var out: Array[Vector2] = []
	if count <= 1:
		out.append(dir)
		return out
	for i in count:
		var k := float(i) / float(count - 1) - 0.5
		out.append(dir.rotated(deg_to_rad(total_deg * k)))
	return out


## The plan of the Tempestade Celestial with this kit's numbers.
func storm_plan() -> ChainPlan:
	var p := ChainPlan.new()
	p.targets = storm_targets
	p.jump = storm_jump
	p.reach = storm_reach
	p.falloff = storm_falloff
	p.solo = storm_solo
	return p
