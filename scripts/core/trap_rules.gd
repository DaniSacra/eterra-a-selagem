class_name TrapRules
extends RefCounted
## The Armadilheiro's plates (lote C1e C): where one is laid and how many may lie. Pure: Horde lays them and the floor warns.


## Where the next plate goes: where the paladin's last dodge ended when it was under `window` s ago, else where he stands.
static func spot(hero: Vector2, dodge_end: Vector2, dodge_age: float, window: float) -> Vector2:
	return dodge_end if dodge_age <= window else hero


## Whether another plate may be laid: fewer than `most` lie and none within `gap` m of the spot.
static func may_lay(at: Vector2, laid: Array[Vector2], most: int, gap: float) -> bool:
	if laid.size() >= most:
		return false
	for p in laid:
		if p.distance_to(at) < gap:
			return false
	return true


## A plate's life (inimigos_c1e.md 6): the X warns for `warn` s, the spikes stand for `spikes` s, then the plate lies dormant (a dim X, still
## counted against the most, still a thing to avoid) until `life` s after it was laid; then it is gone.
enum Phase { WARN, SPIKES, DORMANT, GONE }


static func phase(age: float, warn: float, spikes: float, life: float) -> Phase:
	if age >= life:
		return Phase.GONE
	if age < warn:
		return Phase.WARN
	return Phase.SPIKES if age < warn + spikes else Phase.DORMANT


## One plate laid on the floor: where, how old, and whether the paladin was hurt by it already (the landing counts).
class Plate:
	var at := Vector2.ZERO
	var age := 0.0
	var half := 0.8
	var warn := 1.0
	var spikes := 0.5
	var life := 6.0
	var damage := 10.0
	var by: StringName = &""
	var struck := false
	var landed := false

	func phase() -> Phase:
		return TrapRules.phase(age, warn, spikes, life)

	## Whether `p` is within the plate's square (grown by `margin`).
	func covers(p: Vector2, margin: float = 0.0) -> bool:
		var d := (p - at).abs()
		return d.x <= half + margin and d.y <= half + margin
