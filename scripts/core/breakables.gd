class_name Breakables
extends RefCounted
## The rules of the things that break in a room (AT-Q1; art in docs/art/at_q0_breakables.md, cadence in
## docs/design/combat_cadence.md 9.6). Each piece (BreakablePiece) has a material, a life of one blow (a crate two) and
## a state; any blow that reaches it breaks it: the paladin's swings (Combat.reached, as the cracked columns of RP-09)
## and his waves, an enemy's blow and a room's hazard when they land (Ground), never walking into it. Nothing it gives
## (Q-AT2 (a)): no gold, no Magia, no number. Pure (no nodes); BreakFloor plays it in a room.

enum Stuff { CERAMIC, WATER, WOOD, BRANCH }
## Who broke it (RoomTally: by_hero, by_enemy, by_hazard).
enum Source { HERO, ENEMY, HAZARD }

## The widest a breakable is where blows reach it (MVP: nothing stops a body, so it stays small).
const MAX_RADIUS := 0.45
const MATERIAL_OF := {
	BreakablePiece.Form.VASE: Stuff.CERAMIC, BreakablePiece.Form.URN: Stuff.CERAMIC,
	BreakablePiece.Form.OFFERING: Stuff.CERAMIC, BreakablePiece.Form.WATER: Stuff.WATER,
	BreakablePiece.Form.CRATE: Stuff.WOOD, BreakablePiece.Form.PLANK: Stuff.WOOD,
	BreakablePiece.Form.BENCH: Stuff.WOOD, BreakablePiece.Form.BRANCH: Stuff.BRANCH,
	BreakablePiece.Form.SAPLING: Stuff.BRANCH,
}
## Blows it takes: one, a crate two (the first cracks a board).
const HITS := {BreakablePiece.Form.CRATE: 2}
## The sound of each material breaking, from the sounds that exist until the technical-artist's break_* (AT-Q3);
## Audio's VoiceGate keeps a family to 2 voices and 70 ms apart, and BreakFloor plays one a material a blow.
const SOUND := {
	Stuff.CERAMIC: &"mat_bone", Stuff.WATER: &"mat_bone", Stuff.WOOD: &"mat_shield", Stuff.BRANCH: &"bone",
}

var pieces: Array[BreakablePiece] = []
## Blows left on each piece (0: broken).
var life := PackedInt32Array()
var by := {Source.HERO: 0, Source.ENEMY: 0, Source.HAZARD: 0}


func _init(list: Array[BreakablePiece] = []) -> void:
	pieces = list
	life.resize(list.size())
	for i in list.size():
		life[i] = HITS.get(list[i].form, 1)


static func material_of(form: BreakablePiece.Form) -> Stuff:
	return MATERIAL_OF.get(form, Stuff.CERAMIC)


## Where blows reach a piece of this form and height (never past MAX_RADIUS).
static func radius_of(form: BreakablePiece.Form, height: float) -> float:
	var r := 0.3
	match form:
		BreakablePiece.Form.URN, BreakablePiece.Form.WATER:
			r = 0.32
		BreakablePiece.Form.OFFERING, BreakablePiece.Form.SAPLING:
			r = 0.25
		BreakablePiece.Form.CRATE, BreakablePiece.Form.BENCH, BreakablePiece.Form.PLANK:
			r = 0.4
	return minf(MAX_RADIUS, r * clampf(height / 0.6, 0.8, 1.2))


func count() -> int:
	return pieces.size()


func broken(i: int) -> bool:
	return life[i] <= 0


func broken_count() -> int:
	var n := 0
	for l in life:
		if l <= 0:
			n += 1
	return n


## A swing of the paladin (Combat.reached): every standing piece it reaches takes a blow. {cracked, broken}: indexes.
func swing(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> Dictionary:
	return _blow(func(p: BreakablePiece) -> bool: return ColumnFall.touches(shape, origin, dir, reach, width, p.at, p.radius),
		Source.HERO)


## A round blow (a wave's head, a burst) of `radius` at `center`.
func circle(center: Vector2, radius: float, source: Source) -> Dictionary:
	return _blow(func(p: BreakablePiece) -> bool: return p.at.distance_to(center) <= radius + p.radius, source)


## Any blow that says itself whether it reaches a point with a margin (a zone of the Ground landing).
func reached_by(reaches: Callable, source: Source) -> Dictionary:
	return _blow(func(p: BreakablePiece) -> bool: return reaches.call(p.at, p.radius), source)


## The room's numbers (RoomTally.breakables).
func tally() -> Dictionary:
	return {"total": count(), "broken": broken_count(), "by_hero": by[Source.HERO], "by_enemy": by[Source.ENEMY],
		"by_hazard": by[Source.HAZARD]}


func _blow(reaches: Callable, source: Source) -> Dictionary:
	var cracked: Array[int] = []
	var gone: Array[int] = []
	for i in pieces.size():
		if life[i] <= 0 or not reaches.call(pieces[i]):
			continue
		life[i] -= 1
		if life[i] <= 0:
			gone.append(i)
			by[source] += 1
		else:
			cracked.append(i)
	return {"cracked": cracked, "broken": gone}
