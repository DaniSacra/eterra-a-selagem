class_name UltDef
extends Resource
## A hero's ultimate (D-54; docs/design/warrior_spec.md 3.2, ultimate_u2_proposals.md): charged by the Magia spent on
## Omegas, one chosen before the descent, unlocked by Mastery. Only the numbers for now (no behaviour yet): written by
## _ultimates in tools/make_data.gd, read by HeroDef.ultimates; played by Ultimates (scripts/game/ultimates.gd), the
## shapes and the pull are the pure functions below (tests/test_ultimate.gd).

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
## The hero's clip for the gesture and the second of it where the blade lands: it plays from anim_peak - gesture, so
## the blow lands as the gesture ends.
@export var anim: StringName = &"Slash_C"
@export var anim_peak := 0.67

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
## How hard the blow pushes (as ComboNode.knockback: m/s along the band, the implosion's outward).
@export var knockback := 6.0

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


## The cleave's damage on a body of this radius at p, for the hero at origin facing dir (unit): core_damage when the
## body touches the middle strip (core_width), damage when it touches the rest of the band, 0 outside it.
func cleave_damage(origin: Vector2, dir: Vector2, p: Vector2, body: float) -> float:
	var d := p - origin
	var along := d.dot(dir)
	if along < -body or along > length + body:
		return 0.0
	var across := absf(d.cross(dir)) - body
	if across > width * 0.5:
		return 0.0
	return core_damage if across <= core_width * 0.5 else damage


## The Voragem's radius with the Blessings' size bonus (circulo_firme), never past radius_cap.
func vortex_radius(size_pct: float) -> float:
	return minf(radius * (1.0 + size_pct), maxf(radius, radius_cap))


## Where the Voragem lands: ahead meters along dir, or at the pointer (aim, the mouse on the floor; INF: none) up to
## aim_max meters away.
func vortex_at(from: Vector2, dir: Vector2, aim: Vector2 = Vector2.INF) -> Vector2:
	if aim != Vector2.INF and aim.distance_to(from) > 0.01:
		return from + (aim - from).limit_length(aim_max)
	return from + dir * ahead


## The pull of the Voragem at p (m/s, before the share a body feels): towards the centre at `pull` and along the spiral
## at `swirl` at the edge, both falling linearly to nothing at `core` meters from the centre; nothing past `size`.
## The spiral turns counterclockwise seen from above.
func vortex_pull(p: Vector2, centre: Vector2, size: float) -> Vector2:
	var to := centre - p
	var dist := to.length()
	if dist > size or dist <= core or size <= core:
		return Vector2.ZERO
	var k := (dist - core) / (size - core)
	var inward := to / dist
	return inward * pull * k + Vector2(inward.y, -inward.x) * swirl * k


## The share of the pull a body feels: Morvath never (only slowed), the guardians guardian_pull, an elite while its
## armor holds elite_pull, everyone else all of it.
func pull_share(boss: bool, guardian: bool, armored: bool) -> float:
	if boss:
		return 0.0
	if guardian:
		return guardian_pull
	return elite_pull if armored else 1.0
