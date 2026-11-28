class_name Prologue
extends RefCounted
## The two rooms before a descent's first room (2026-11-26, package antessala_sala00): the Antessala (a new save's guided
## descent only, once: the lessons) and the Sala 00, the Câmara de Preparação (every descent: the Blessing of the descent at its
## altar). Neither is a room of the graph, none counts as a room (the HUD's "Sala 1 de 14" stays the first room's) and none
## moves a depth, a guardian, the shop or a count. Pure rules; Rooms plays them.
##   Prologue.kinds(guided, data)        -> [ANTE, SALA00] the first time of a new save, [SALA00] every other descent
##   Prologue.arrival(kind, from_ante)   -> how the hero comes in (FULL: the comet of the first arrival, SHORT: after the Antessala)
##   Prologue.cross_ante(data)           -> writes that the Antessala was crossed (never met again)
##   var altar := Prologue.Grant.new()   -> the Blessing of the Sala 00: offered once, taken once, the door waits for it

## How the hero comes into a room of the prologue.
enum Arrival { NONE, FULL, SHORT }

## Seconds of the comet's clock a short arrival begins at (ArrivalTimeline: T_OPEN, the black goes and the comet falls at once).
const SHORT_FROM := 1.6


## Whether the save still has the Antessala ahead: only the guided first descent of a save that never crossed it.
static func ante_due(data: Dictionary, guided: bool) -> bool:
	return guided and int(data.get("ante", 0)) == 0


## The rooms of the prologue of this descent, in order (RunMap.Kind.ANTE, RunMap.Kind.SALA00).
static func kinds(guided: bool, data: Dictionary) -> Array[RunMap.Kind]:
	var out: Array[RunMap.Kind] = []
	if ante_due(data, guided):
		out.append(RunMap.Kind.ANTE)
	out.append(RunMap.Kind.SALA00)
	return out


## How the hero comes into this room: the Antessala (it is only met on the first descent) and the Sala 00 from the Santuário with the
## whole comet; the Sala 00 from the Antessala with the short one. Any other room: none.
static func arrival(kind: RunMap.Kind, from_ante: bool) -> Arrival:
	match kind:
		RunMap.Kind.ANTE:
			return Arrival.FULL
		RunMap.Kind.SALA00:
			return Arrival.SHORT if from_ante else Arrival.FULL
	return Arrival.NONE


## The Antessala was crossed: the save never meets it again (written when the hero goes through its door).
static func cross_ante(data: Dictionary) -> void:
	data["ante"] = 1


## Whether this kind is a room outside the count of the graph: the prologue's (Antessala, Sala 00) and the Átrio (Chapter II, A-2): no tally, no log, its name on the HUD.
static func is_prologue(kind: RunMap.Kind) -> bool:
	return kind == RunMap.Kind.ANTE or kind == RunMap.Kind.SALA00 or kind == RunMap.Kind.ATRIO


## The Blessing of the Sala 00: offered once and taken once. The altar opens its choice a single time; the screen is modal (its angels' pair
## and its cards go back and forth inside it, drawn on the dice of the run and the room: the same cards each time), so leaving it and coming
## back never draws anew nor gives a second Blessing, and once taken the altar is spent.
class Grant extends RefCounted:
	enum State { READY, OFFERED, TAKEN }
	var state := State.READY
	## Steps with the run back in play since it was offered (a choice screen over it is not "taken").
	var _calm := 0

	## The altar may be used now (nothing offered yet).
	func may_offer() -> bool:
		return state == State.READY

	## The choice opened.
	func offer() -> void:
		if state == State.READY:
			state = State.OFFERED
			_calm = 0

	## One step of the room: `playing` is whether the run is in play (no screen over it). The offer is taken once the screen
	## is gone for two steps in a row.
	func step(playing: bool) -> void:
		if state != State.OFFERED:
			return
		_calm = _calm + 1 if playing else 0
		if _calm >= 2:
			state = State.TAKEN

	## The door may open: the Blessing was taken.
	func door_open() -> bool:
		return state == State.TAKEN
