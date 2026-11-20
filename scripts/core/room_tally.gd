class_name RoomTally
extends RefCounted
## The rooms of one run in numbers (QW-011, for the human tests): for each room entered, its depth, the arena it was
## (RoomLayout.id) and its variant, the paladin's life, gold and gifts walking in, the damage he took there by what
## dealt it (DefeatCause.key: an enemy kind or a boss attack) and how many blows, his dodges, the enemies' shots by
## kind (fired, hit, blocked) and what stone stopped them, the seconds spent in it and the seconds to the first blow
## given or taken (contact). For the whole run (GP-02 of cycle C12c): every blow taken in its context (hurt_ctx: was
## it warned, could he dash, was the attacker on the screen), the gifts held at Morvath, the shop and the fountain.
## Pure; Game feeds it, RESULT and the run's log carry rooms() and the rest.

## At most this many blows are kept in hurt_ctx (a run of a person rarely takes more; the log stays small).
const HURT_CTX_MAX := 60
## What happens to a shot (shots: per enemy kind, how many of each).
const SHOT_FIRED := "fired"
const SHOT_HIT := "hit"
const SHOT_BLOCKED := "blocked"

var _rooms: Array[Dictionary] = []
var _started := 0.0
## Life when the boss room was entered (-1: not yet).
var hp_at_boss := -1.0
## Gifts held when the boss room was entered (-1: not yet).
var boons_at_boss := -1
## Every blow taken (up to HURT_CTX_MAX): {by, t, room, dmg, warn_s, dash_ready, offscreen}.
var hurt_ctx: Array[Dictionary] = []
## The shop: gold walking in and what was bought ({} before it).
var shop := {}
## DV-2 (MAP-09): the route shop's, the same fields ({} when the way passed none).
var route_shop := {}
var _route := false
## The fountain healed him.
var fountain_used := false
## E5: every decision of the events, in order ({type, room, t, ...}: the Provação's slab shown, refused, paid, the card
## taken and turned; the altar's door offered, its trade; each door taken and what the others showed).
var events: Array[Dictionary] = []


## A room is entered at play time `time` with `hp` life, `gold` and `boons` gifts held; node: its id in the descent's
## graph (DV-1, RunMap; -1: none). The room before it is closed.
func enter(depth: int, layout: String, hp: float, time: float, boss := false, variant := 0, gold := 0, boons := 0, node := -1) -> void:
	close(time)
	_started = time
	_rooms.append({"depth": depth, "node": node, "layout": layout, "variant": variant, "hp_in": snappedf(hp, 0.1), "gold_in": gold,
		"boons_in": boons, "hurt_by": {}, "hits": 0, "hits_by": {}, "dodges": 0, "shots": {}, "blocked_by": {},
		"time": 0.0, "contact": -1.0, "zones": {}})
	if boss:
		hp_at_boss = snappedf(hp, 0.1)
		boons_at_boss = boons


## The paladin lost `amount` life to `by` in the current room (one blow).
func hurt(by: String, amount: float) -> void:
	if _rooms.is_empty() or amount <= 0.0:
		return
	var r := _rooms[-1]
	var h: Dictionary = r.hurt_by
	h[by] = snappedf(float(h.get(by, 0.0)) + amount, 0.1)
	r.hits = int(r.hits) + 1
	_count(r.hits_by, by)


## A blow taken, in its context: by (DefeatCause.key), at play time `time`, `amount` lost, warn_s (seconds its
## warning was shown before it landed; -1: none), dash_ready (a dodge charge was there to use), offscreen (whoever
## dealt it was off the screen when it struck or fired).
func hurt_context(by: String, time: float, amount: float, warn_s: float, dash_ready: bool, offscreen: bool) -> void:
	if hurt_ctx.size() >= HURT_CTX_MAX:
		return
	hurt_ctx.append({"by": by, "t": snappedf(time, 0.1), "room": int(_rooms[-1].depth) if not _rooms.is_empty() else 0,
		"dmg": snappedf(amount, 0.1), "warn_s": snappedf(warn_s, 0.01) if warn_s >= 0.0 else -1.0,
		"dash_ready": dash_ready, "offscreen": offscreen})


## The paladin dodged in the current room.
func dodge() -> void:
	if not _rooms.is_empty():
		_rooms[-1].dodges = int(_rooms[-1].dodges) + 1


## An enemy's shot (by: its kind, or the boss) was fired, hit him or was stopped (SHOT_*); a stopped one names the
## piece of stone it died on (blocked_by).
func shot(by: String, what: String, piece := "") -> void:
	if _rooms.is_empty():
		return
	var shots: Dictionary = _rooms[-1].shots
	if not shots.has(by):
		shots[by] = {SHOT_FIRED: 0, SHOT_HIT: 0, SHOT_BLOCKED: 0}
	shots[by][what] = int(shots[by].get(what, 0)) + 1
	if what == SHOT_BLOCKED and piece != "":
		_count(_rooms[-1].blocked_by, piece)


## E5: seconds the paladin spent in a named part of the current room's floor (RoomLayout.area_at) in a fight: the
## decision each arena asks (the nave or the aisles, the island or the crossing).
func zone_time(zone: String, dt: float) -> void:
	if _rooms.is_empty() or dt <= 0.0:
		return
	var z: Dictionary = _rooms[-1].zones
	z[zone] = float(z.get(zone, 0.0)) + dt


## E5: what the floor of the runes did in the current room: life it took from the enemies, enemies it felled and how
## many times it struck; hero_damage, what it took from him (hurt_by of its source, "runes"). RP-06: the slabs (source
## "plates") add their own numbers in extra (PlateFloor.tally: kind, who armed them, seconds he stood on one).
func hazard(enemy_damage: float, kills: int, strikes: int, source := "runes", extra := {}) -> void:
	if not _rooms.is_empty():
		var r := _rooms[-1]
		r.hazard = {"enemy_damage": snappedf(enemy_damage, 0.1), "kills": kills, "strikes": strikes,
			"hero_damage": snappedf(float((r.hurt_by as Dictionary).get(source, 0.0)), 0.1)}
		(r.hazard as Dictionary).merge(extra, true)


## RP-09: the room's toppling columns (ColumnFloor.tally: how many, cracked, toppled, what they dealt, kills).
func columns(data: Dictionary) -> void:
	if not _rooms.is_empty():
		_rooms[-1].columns = data


## E5: a decision of an event (type: what happened; data: its details), at play time `time`, in the current room.
func event(type: String, time: float, data := {}) -> void:
	var e := {"type": type, "room": int(_rooms[-1].depth) if not _rooms.is_empty() else 0, "t": snappedf(time, 0.1)}
	e.merge(data)
	events.append(e)


## The shop was walked into with `gold`.
## DV-2 (MAP-09): a route shop (before the last one) keeps its own in route_shop; what is bought goes to the shop
## walked into last.
func shop_entered(gold: int, route := false) -> void:
	_route = route
	if route:
		route_shop = {"gold": gold, "bought": [], "spent": 0}
	else:
		shop = {"gold": gold, "bought": [], "spent": 0}


## Bought `item` (a RunMap.Reward's name) for `price` in the shop.
func bought(item: String, price: int) -> void:
	if (route_shop if _route else shop).is_empty():
		shop_entered(0, _route)
	var s: Dictionary = route_shop if _route else shop
	(s.bought as Array).append(item)
	s.spent = int(s.spent) + price


## The fountain healed him.
func fountain() -> void:
	fountain_used = true


## The first blow given or taken in the current room, at play time `time` (contact: seconds after walking in; only
## the first counts).
func touch(time: float) -> void:
	if not _rooms.is_empty() and float(_rooms[-1].contact) < 0.0:
		_rooms[-1].contact = snappedf(time - _started, 0.1)


## Sets the seconds spent in the current room, as of `time`.
func close(time: float) -> void:
	if not _rooms.is_empty():
		_rooms[-1].time = snappedf(time - _started, 0.1)


## Every room so far, the current one timed up to `time` (a copy).
func rooms(time: float) -> Array:
	close(time)
	var out := _rooms.duplicate(true)
	for r: Dictionary in out:
		var z: Dictionary = r.get("zones", {})
		for k: String in z:
			z[k] = snappedf(float(z[k]), 0.1)
	return out


## The run's own fields (GP-02) for the log: boons_at_boss, shop, fountain_used and hurt_ctx (copies).
func run_fields() -> Dictionary:
	return {"boons_at_boss": boons_at_boss, "shop": shop.duplicate(true), "route_shop": route_shop.duplicate(true), "fountain_used": fountain_used,
		"hurt_ctx": hurt_ctx.duplicate(true), "events": events.duplicate(true)}


static func _count(d: Dictionary, key: String) -> void:
	d[key] = int(d.get(key, 0)) + 1
