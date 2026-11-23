class_name ArcaneKit
extends Resource
## The Maga's numbers (docs/design/heroes/maga.md 2 and 3): the Selo, the Explosão Rúnica, the Círculo de Contenção, the
## Suspensão Arcana and the Ressonância. A hero with one has the arcane kit (HeroDef.arcane; the Warrior has none).
## Written by _maga in tools/make_data.gd; played by Arcane (scripts/game/arcane.gd); the rules that need no node are the
## pure functions below and SealBook and Resonance (tests/test_maga_*.gd).

@export_group("Selo")
## Seconds a Selo lives on an enemy, and how many one enemy holds.
@export var seal_time := 8.0
@export var seal_cap := 1
## Magia for the shot that lays a Selo, and for each Selo a Explosão detonates (at most seal_magick_cap Selos a blast).
@export var seal_lay_magick := 1.0
@export var seal_magick := 1.0
@export var seal_magick_cap := 6
## Magia for each shot that lands (KitFeed.take caps it by HeroDef.gain_cap).
@export var shot_magick := 0.3
## A boss takes the Selo's bonus once in this many seconds.
@export var boss_seal_gap := 3.0

@export_group("Explosão Rúnica")
## Where it may fall (meters from her) and how far it clings to a Selo near the cursor.
@export var blast_range := 10.0
@export var blast_snap := 1.5
@export var blast_radius := 3.2
@export var blast_damage := 25.0
## Added to each enemy that holds a Selo (it consumes them).
@export var blast_seal_damage := 35.0
## The amplified blast (Ressonância full): damage times, radius, and it costs no Magia.
@export var amp_mult := 1.5
@export var amp_radius := 4.5
@export var blast_knockback := 6.0

@export_group("Ressonância")
## Points a Selo detonated by a blast gives, the points in all (3 diamonds of 2), and what the Tempestade's detonation gives at most.
@export var resonance_per_seal := 1
@export var resonance_max := 6
@export var storm_resonance := 3

@export_group("Círculo de Contenção")
## Meters from her it may be put, its radius, seconds it stands, how far it draws the commons in and in how many seconds.
@export var circle_range := 8.0
@export var circle_radius := 3.2
@export var circle_time := 4.0
@export var circle_pull := 1.2
@export var circle_pull_time := 0.4
## Seconds an enemy inside is slowed (renewed each step; Enemy.slow_t slows to 45%).
@export var circle_slow := 0.3
## Selos a Explosão detonates give back this many seconds of the Círculo's recharge, at most per cast; never under cd_floor.
@export var circle_refund := 1.0
@export var circle_refund_cap := 4.0
## The Selo comes on the 2nd shot of the chain while the target stands in it.
@export var circle_seal_at := 2

@export_group("Suspensão Arcana")
@export var dome_radius := 2.6
@export var dome_time := 2.5
@export var dome_slow := 0.3

@export_group("Passo Etéreo")
## Meters, protected seconds (14 frames), and the meters it may pass through a body (it ends on free floor).
@export var blink_distance := 4.5
@export var blink_iframes := 14.0 / 60.0


## The blast's damage on one enemy: its base, plus the Selo's when it holds one, all times amp_mult when amplified.
func blast_hit(sealed: bool, amplified: bool) -> float:
	var d := blast_damage + (blast_seal_damage if sealed else 0.0)
	return d * (amp_mult if amplified else 1.0)


func blast_size(amplified: bool) -> float:
	return amp_radius if amplified else blast_radius


## Where a blast aimed at `cursor` from `from` falls: at most blast_range from her, clinging to the Selo nearest the
## point (within blast_snap) when `seals` has one.
func blast_at(from: Vector2, cursor: Vector2, seals: Array[Vector2]) -> Vector2:
	var at := from + (cursor - from).limit_length(blast_range)
	var best := INF
	var snap := at
	for s in seals:
		var d := s.distance_to(at)
		if d <= blast_snap and d < best:
			best = d
			snap = s
	return snap


## Where the Círculo falls: the cursor, at most circle_range from her.
func circle_at(from: Vector2, cursor: Vector2) -> Vector2:
	return from + (cursor - from).limit_length(circle_range)


## The Selo a shot lays: the shot's own mark tag decides (the third of the chain always, the second inside the Círculo).
func seals_on(tags: Array[StringName], in_circle: bool) -> bool:
	return tags.has(&"seal") or (in_circle and tags.has(&"seal2"))


## The pull of the Círculo on a body at p when it is cast: the metres this step (dt), at circle_pull in circle_pull_time,
## along the line to the centre and never past it.
func pull_step(p: Vector2, centre: Vector2, dt: float) -> Vector2:
	var to := centre - p
	var step := circle_pull / maxf(circle_pull_time, 0.01) * dt
	return to.limit_length(step) if to.length() > 0.001 else Vector2.ZERO
