class_name WallMark
extends RefCounted
## RD2-10 (the Knight's hall, docs/design/rooms_progression.md): the wall a charge will end against. While a guardian with a
## wall stun (EnemyDef.wall_stun) braces for its charge, a round mark lies on the floor where its line meets the wall (it
## follows the line while the line follows the paladin, then stays), for as long as the line itself: "that is where he will
## stop, stunned". Counts the stuns (the room's walls tally) so the room's design is measured. Placeholder amber ring (the
## hazards' own), the environment artist's drawing replaces it. It hurts nobody and stops no one.

const SOURCE := &"wallmark"
const RADIUS := 1.5
## A mark that moved less than this is not laid again.
const MOVE := 0.4

var game: Game
var _marks := {}
var _at := {}
var _stunned := {}
## How many charges ended in the wall (stunned the guardian) and how many marks were laid.
var hits := 0
var marked := 0


func _init(g: Game) -> void:
	game = g


func step(_dt: float) -> void:
	for e in game.horde.list:
		if not e.alive or e.def.wall_stun <= 0.0:
			continue
		_mark(e)
		var now := e.stun_t > 0.0 and absf(e.stun_len - e.def.wall_stun) < 0.001
		if now and not _stunned.get(e, false):
			hits += 1
		_stunned[e] = now
	for e in _marks.keys():
		if not is_instance_valid(e) or not e.alive:
			_clear(e)


func _mark(e: Enemy) -> void:
	var z := e.warning as Ground.Zone
	var bracing := e.state == Enemy.State.WINDUP and z != null and z.life > 0.0 and z.shape == Ground.Shape.LINE and e.memo == 0
	if not bracing:
		_clear(e)
		return
	var d := e.def
	var reach := d.lunge_speed * d.lunge_time
	var arena := game.arena
	var s := WallAim.hit_at(e.pos, e.aim, reach, func(p: Vector2) -> bool:
		return arena.resolve(p, d.radius).distance_squared_to(p) > 0.0025)
	if s < 0.0:
		_clear(e)
		return
	var at := e.pos + e.aim.normalized() * s
	if _marks.has(e) and (_at[e] as Vector2).distance_to(at) < MOVE:
		return
	_clear(e)
	_marks[e] = game.ground.add_round(at, RADIUS, maxf(z.life, 0.05), 0.0, 0.0, SOURCE)
	_at[e] = at
	marked += 1


func _clear(e: Enemy) -> void:
	if _marks.has(e):
		Ground.end_zone(_marks[e])
		_marks.erase(e)
		_at.erase(e)


func stop() -> void:
	for e in _marks.keys():
		_clear(e)
	_stunned.clear()


func tally() -> Dictionary:
	return {"wall_hits": hits, "marked": marked}
