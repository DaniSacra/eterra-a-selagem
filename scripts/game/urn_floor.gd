class_name UrnFloor
extends RefCounted
## The oil urns in a fight (RP-12; docs/design/rooms_progression.md, combat_cadence.md 9.3): runs an UrnHazard on the
## paladin's blows (Combat.reached). A blow that reaches an urn lights it: its ring warns in the hazards' amber
## (Ground.add_round, URN_SOURCE) with fire on the urn from that frame, and blasts (hero_damage to him as any warning,
## enemy_damage to every enemy in it); the oil runs down its channel, each stretch a drawn band warning (OIL_SOURCE)
## flow_lead seconds ahead of the flame, struck as the flame reaches it, then burning `burn` seconds drawn whole (whoever
## walks in is struck once: flow_hero, flow_enemy). Placeholders until the environment artist's urn (bronze, the fuse
## showing, never a breakable's look) and running oil. Rooms makes one for a room whose hazard (or its `also`) is URNS.

## How far round an urn a blow reaches it (its body).
const URN_RADIUS := 0.45

var hazard: UrnHazard
var game: Game
## The warnings on the floor now, each [urn, stretch (-1: the ring)].
var zones := {}
## The burning stretches drawn (a node each, by "urn:stretch"), and who each has struck (ids; "hero" for him).
var burn_nodes := {}
var burn_struck := {}
var enemy_damage := 0.0
var kills := 0
var oil_damage := 0.0


## awake: whether the descent reached HazardDef.from_progress.
func _init(g: Game, def: HazardDef, awake := true) -> void:
	game = g
	hazard = UrnHazard.new(def, awake)
	g.combat.reached.connect(_on_reached)
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	var def := hazard.def
	var did := hazard.step(dt)
	for i: int in did.blasted:
		Audio.play(CombatSounds.EVENTS[&"urn_fire"])
		var at := def.urns[i]
		game.fx.burst(&"fire", Vector3(at.x, 0.5, at.y))
		game.fx.shake(0.12)
	for pair: Array in did.armed:
		var s: Dictionary = hazard.stretches[pair[0]][pair[1]]
		var z := game.ground.add_band(s.from, s.dir, s.length, def.flow_width, def.flow_lead, def.flow_hero, def.flow_enemy,
			true, Ground.OIL_SOURCE)
		zones[z] = pair
		if int(pair[1]) == 0:
			Audio.play(CombatSounds.EVENTS[&"oil_arm"])
	for pair: Array in did.reached:
		var s: Dictionary = hazard.stretches[pair[0]][pair[1]]
		var n := GroundLook.new_node()
		game.arena.add_child(n)
		GroundLook.plate_band(n, s.from, s.dir, s.length, def.flow_width, PlateFloor.Y)
		GroundLook.set_plate(n, Vector3(0, 1, 0))
		var key := "%d:%d" % [pair[0], pair[1]]
		burn_nodes[key] = n
		# standing on it as the flame reached it, the Ground's warning struck him: never twice by one stretch
		# (and the enemies on it: the Ground's warning strikes them as the flame reaches it)
		var seen := {"hero": _on(s, game.player.pos)}
		for e in game.horde.list:
			if e.alive and _on(s, e.pos):
				seen[e.get_instance_id()] = true
		burn_struck[key] = seen
		var mid: Vector2 = s.from + s.dir * s.length * 0.5
		game.fx.burst(&"fire", Vector3(mid.x, 0.3, mid.y))
		if int(pair[1]) == 0:
			Audio.play(CombatSounds.EVENTS[&"oil_fire"])
	_burn()


## Whoever walks into a burning stretch is struck once by it.
func _burn() -> void:
	var def := hazard.def
	for key: String in burn_nodes.keys():
		var parts := key.split(":")
		var i := int(parts[0])
		var k := int(parts[1])
		if not hazard.burning(i, k):
			var n: MeshInstance3D = burn_nodes[key]
			if is_instance_valid(n):
				n.queue_free()
			burn_nodes.erase(key)
			burn_struck.erase(key)
			continue
		var s: Dictionary = hazard.stretches[i][k]
		var seen: Dictionary = burn_struck[key]
		var h := game.horde
		h.dealing = Ground.OIL_SOURCE
		for e in h.list.duplicate():
			if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or seen.has(e.get_instance_id()):
				continue
			if _on(s, e.pos):
				seen[e.get_instance_id()] = true
				var before: float = e.hp
				if h.damage(e, def.flow_enemy, Vector2.ZERO, 0.0, RuneFloor.NUMBER_COLOR):
					kills += 1
				enemy_damage += maxf(0.0, before - e.hp)
				oil_damage += maxf(0.0, before - e.hp)
		h.dealing = &""
		var p := game.player.pos
		if game.player.alive() and _on(s, p) and not seen.get("hero", false):
			seen["hero"] = true
			game.ground.strike(def.flow_hero, p, Ground.OIL_SOURCE, def.flow_lead)


static func _on(s: Dictionary, p: Vector2) -> bool:
	var d: Vector2 = p - s.from
	var along := d.dot(s.dir)
	return along >= 0.0 and along <= s.length and absf(d.cross(s.dir)) <= 0.75


## The fight is over (or the room left): what warms up goes away unstruck, the fire with it.
func stop() -> void:
	for z in zones:
		Ground.end_zone(z)
	zones.clear()
	for n in burn_nodes.values():
		if is_instance_valid(n):
			n.queue_free()
	burn_nodes.clear()
	burn_struck.clear()
	hazard.stop()
	if game.combat.reached.is_connected(_on_reached):
		game.combat.reached.disconnect(_on_reached)
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## How many of its warnings are on the floor now (one per lit urn: its ring and its oil are one event).
func busy() -> int:
	var n := 0
	for i in hazard.count():
		if hazard.stage[i] == UrnHazard.Stage.LIT:
			n += 1
	return n


## The room's numbers (RoomTally.hazard).
func tally() -> Dictionary:
	return {"kind": "urn", "lit": hazard.lit_count, "blasts": hazard.blasts, "oil_damage": snappedf(oil_damage, 0.1)}


func _on_reached(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> void:
	var def := hazard.def
	for i in hazard.count():
		if hazard.stage[i] != UrnHazard.Stage.IDLE:
			continue
		if not ColumnFall.touches(shape, origin, dir, reach, width, def.urns[i], URN_RADIUS):
			continue
		var at := def.urns[i]
		if not hazard.light(i):
			game.fx.burst(&"spark", Vector3(at.x, 0.5, at.y))
			continue
		var z := game.ground.add_round(at, def.urn_radius, def.warn, def.hero_damage, def.enemy_damage, Ground.URN_SOURCE)
		zones[z] = [i, -1]
		Audio.play(CombatSounds.EVENTS[&"urn_arm"])
		game.fx.burst(&"fire", Vector3(at.x, 0.7, at.y))


func _on_landed(z: Ground.Zone) -> void:
	if not zones.has(z):
		return
	zones.erase(z)
	var dealt := PlateFloor.strike(game, z, Vector2.ZERO, z.source)
	enemy_damage += dealt.x
	kills += int(dealt.y)
	if z.source == Ground.OIL_SOURCE:
		oil_damage += dealt.x
