class_name DropFloor
extends RefCounted
## The stones that fall from the torn vault in a fight (RP-20; docs/design/rooms_progression.md, combat_cadence.md
## 9.3): runs a DropHazard and lays each stone, as it comes, on the floor as a drawn floor warning (Ground.add_hazard
## named ROCKS_SOURCE: the square whole from the first frame in the hazards' amber, the fill rising), dust falling
## from above from that frame, the stone itself dropping over the last STONE_FALL seconds to touch the floor on the
## frame it strikes; as it lands it strikes the paladin (as any warning) and every enemy in it (hazard_landed), and a
## low grey rubble stays RUBBLE seconds, drawn only (it never stops a body). Placeholders until the environment
## artist's stone, dust and rubble. Rooms makes one for a room whose hazard (or its `also`) is DROPS.

## Seconds the stone takes to fall onto the square (it touches the floor on the strike's frame).
const STONE_FALL := 0.25
## How high it falls from, and the size of the stone against its square.
const STONE_HEIGHT := 9.0
const STONE_SHARE := 0.7
## Seconds the rubble lies after the strike, drawn only.
const RUBBLE := 3.0
const STONE_COLOR := Color(0.42, 0.4, 0.38)

var hazard: DropHazard
var game: Game
## The warning of each stone warming up, by its square (as Ground.Zone), and its falling stone (a mesh).
var zones := {}
var falling := {}
## The rubble on the floor: each [mesh, seconds left].
var rubble: Array = []
var enemy_damage := 0.0
var kills := 0
var hero_in := 0.0
var _mesh: BoxMesh
var _mat: StandardMaterial3D


## awake: whether the descent reached HazardDef.from_progress; seed: the room's own dice.
func _init(g: Game, def: HazardDef, seed: int, awake := true) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = DropHazard.new(def, g.arena.shape(), doors, seed, awake)
	_mesh = BoxMesh.new()
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = STONE_COLOR
	_mat.roughness = 1.0
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	var def := hazard.def
	var p := game.player.pos if game.player.alive() else Vector2.INF
	for z in def.drop_zones:
		if z.has_point(p):
			hero_in += dt
			break
	var blocked := game.ground.room_rects()
	var free := PlateHazard.MOST_AT_ONCE - game.ground.room_live()
	var did := hazard.step(dt, p, blocked, free)
	for r: Rect2 in did.armed:
		var z := game.ground.add_hazard(r, def.warn, def.hero_damage, def.enemy_damage, true, Ground.ROCKS_SOURCE)
		GroundLook.put(z.mat, &"tile_m", r.size.x)
		zones[r] = z
		Audio.play(CombatSounds.EVENTS[&"rocks_arm"])
		var c := r.get_center()
		for h: float in [6.0, 3.5]:
			game.fx.burst(&"dust", Vector3(c.x, h, c.y))
	for r: Rect2 in did.fired:
		Audio.play(CombatSounds.EVENTS[&"rocks_fire"])
		var c := r.get_center()
		game.fx.burst(&"dust", Vector3(c.x, 0.3, c.y))
		game.fx.shake(0.08)
	# the stone in the air over the last STONE_FALL seconds of each warning, on the floor at the strike as rubble
	for s in hazard.stones:
		var r: Rect2 = s.rect
		if s.phase == DropHazard.Phase.ARM and s.left <= STONE_FALL:
			if not falling.has(r):
				falling[r] = _stone(r)
			var k: float = 1.0 - float(s.left) / STONE_FALL
			var m: MeshInstance3D = falling[r]
			m.position.y = lerpf(STONE_HEIGHT, m.scale.y * 0.5, k * k)
	for r: Rect2 in did.fired:
		if falling.has(r):
			var m: MeshInstance3D = falling[r]
			falling.erase(r)
			m.scale.y *= 0.45
			m.position.y = m.scale.y * 0.5
			rubble.append([m, RUBBLE])
	var i := rubble.size() - 1
	while i >= 0:
		rubble[i][1] -= dt
		if rubble[i][1] <= 0.0:
			if is_instance_valid(rubble[i][0]):
				rubble[i][0].queue_free()
			rubble.remove_at(i)
		i -= 1


## The fight is over (or the room left): the stones warming up go away unstruck, the rubble with them.
func stop() -> void:
	for z in zones.values():
		if z != null:
			Ground.end_zone(z)
	zones.clear()
	for m in falling.values():
		if is_instance_valid(m):
			m.queue_free()
	falling.clear()
	for r in rubble:
		if is_instance_valid(r[0]):
			r[0].queue_free()
	rubble.clear()
	hazard.stop()
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## How many of its warnings are on the floor now.
func busy() -> int:
	return hazard.warming()


## The room's numbers (RoomTally.hazard).
func tally() -> Dictionary:
	return {"kind": "rocks", "hero_in_s": snappedf(hero_in, 0.1), "aimed": hazard.aimed}


func _stone(r: Rect2) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.mesh = _mesh
	m.material_override = _mat
	var side := r.size.x * STONE_SHARE
	m.scale = Vector3(side, side * 0.6, side)
	var c := r.get_center()
	# turned by where it falls (never the run's dice)
	m.rotation.y = fposmod(c.x * 1.7 + c.y * 2.3, TAU)
	m.position = Vector3(c.x, STONE_HEIGHT, c.y)
	game.arena.add_child(m)
	return m


func _on_landed(z: Ground.Zone) -> void:
	var key: Variant = null
	for r in zones:
		if zones[r] == z:
			key = r
	if key == null:
		return
	zones.erase(key)
	var dealt := PlateFloor.strike(game, z, Vector2.ZERO, Ground.ROCKS_SOURCE)
	enemy_damage += dealt.x
	kills += int(dealt.y)
