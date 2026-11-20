class_name PlateFloor
extends RefCounted
## The slabs that strike when stepped on in a fight (RP-06, H-2; docs/design/rooms_progression.md): runs a PlateHazard
## with the paladin and the enemies standing, lays each armed slab on the floor as an undrawn warning
## (Ground.add_hazard with PLATE_SOURCE: as it lands it strikes the paladin, as any warning, and every enemy standing on
## it, hazard_landed, here) and draws every slab itself (GroundLook.plate: the cracked frame at rest, the amber reaching
## in as it arms). A slab with a push (RP-13, the edge that crumbles) throws whoever it struck toward the firm floor.
## Counts what it dealt and the seconds the paladin stood on a slab for the room's numbers. Rooms makes one when the
## room's HazardDef is PLATES; the drawing hangs from the arena and goes with it.

const NUMBER_COLOR := RuneFloor.NUMBER_COLOR
## How high over the floor the slabs are drawn (under every warning: Ground lays them from 0.06).
const Y := 0.05

var hazard: PlateHazard
var game: Game
## The warning of each armed slab (null: none).
var zones: Array[Ground.Zone] = []
var nodes: Array[MeshInstance3D] = []
## Life it took from the enemies, enemies it felled, and the seconds the paladin stood on a slab.
var enemy_damage := 0.0
var kills := 0
var hero_on := 0.0
var _bodies := PackedVector2Array()


## awake: whether the descent reached HazardDef.from_progress (else the slabs lie drawn and never strike).
func _init(g: Game, def: HazardDef, awake := true) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = PlateHazard.new(def, doors, awake)
	zones.resize(hazard.count())
	for r in def.plates:
		var n := GroundLook.new_node()
		g.arena.add_child(n)
		GroundLook.plate(n, r, Y)
		nodes.append(n)
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	var p := game.player.pos if game.player.alive() else Vector2.INF
	if hazard.plate_at(p) >= 0:
		hero_on += dt
	_bodies.clear()
	for e in game.horde.list:
		if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS:
			_bodies.append(e.pos)
	var did := hazard.step(dt, p, _bodies)
	var def := hazard.def
	for i: int in did.armed:
		zones[i] = game.ground.add_hazard(def.plates[i], def.warn, def.hero_damage_of(i), def.enemy_damage, false,
			Ground.PLATE_SOURCE)
		Audio.play(CombatSounds.EVENTS[&"plate_arm"])
	for i: int in did.fired:
		Audio.play(CombatSounds.EVENTS[&"plate_fire"])
	for i in nodes.size():
		if is_instance_valid(nodes[i]):
			GroundLook.set_plate(nodes[i], hazard.state(i))


## The fight is over (or the room left): what is warming up goes away without striking; the slabs stay drawn at rest.
func stop() -> void:
	for i in zones.size():
		if zones[i] != null:
			Ground.end_zone(zones[i])
			zones[i] = null
	hazard.stop()
	for i in nodes.size():
		if is_instance_valid(nodes[i]):
			GroundLook.set_plate(nodes[i], Vector3.ZERO)
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## The room's numbers (RoomTally.hazard): {kind, strikes, armed by him and by them, seconds he stood on one}.
func tally() -> Dictionary:
	return {"kind": "plates", "armed_by_hero": hazard.armed_by_hero, "armed_by_enemy": hazard.armed_by_enemy,
		"hero_on_s": snappedf(hero_on, 0.1)}


func _on_landed(z: Ground.Zone) -> void:
	var i := zones.find(z)
	if i < 0:
		return
	zones[i] = null
	var dealt := strike(game, z, hazard.def.push_of(i), Ground.PLATE_SOURCE)
	enemy_damage += dealt.x
	kills += int(dealt.y)


## A floor warning `z` of the room's own hazard landed: deals its damage to every enemy (not the boss) inside it and
## pushes everyone it struck by `push` (swept: nobody goes through stone nor falls); the paladin's damage is the
## Ground's own. cut: a push that deals nothing cuts the wind-up or attack of whoever it moved (the rift that breathes,
## RP-08: the flood trap of the Hades II; never a charge that cannot be cut, nor a guardian). Returns (life taken,
## enemies felled, enemies pushed). Shared by the slabs and the bands (BandFloor).
static func strike(game: Game, z: Ground.Zone, push: Vector2, source: StringName, cut := false) -> Vector3:
	var dealt := 0.0
	var felled := 0
	var pushed := 0
	var h := game.horde
	h.dealing = source
	for e in h.list.duplicate():
		if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or not Ground.inside(z, e.pos):
			continue
		var before: float = e.hp
		if z.hazard > 0.0 and h.damage(e, z.hazard, Vector2.ZERO, 0.0, NUMBER_COLOR):
			felled += 1
		dealt += maxf(0.0, before - e.hp)
		if push != Vector2.ZERO and e.alive:
			e.pos = game.arena.sweep(e.pos, e.pos + push, e.def.radius)
			pushed += 1
			var charging: bool = e.state == Enemy.State.ATTACK and e.def.stun_immune_attacking
			if cut and e.def.stun_time > 0.0 and not charging:
				h.interrupt(e)
	h.dealing = &""
	if push != Vector2.ZERO and game.player.alive() and Ground.inside(z, game.player.pos, Player.RADIUS * 0.6):
		game.player.pos = game.arena.sweep(game.player.pos, game.player.pos + push, Player.RADIUS)
	return Vector3(dealt, felled, pushed)
