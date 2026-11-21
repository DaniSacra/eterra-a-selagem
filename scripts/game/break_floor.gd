class_name BreakFloor
extends Node3D
## The things that break in a room (AT-Q1; art in docs/art/at_q0_breakables.md, cadence in combat_cadence.md 9.6):
## plays a Breakables on the room's pieces (RoomLayout.breakables). Game.rebuild_room makes one under the arena when
## the layout has any (never in the hub), so it goes with the arena. A piece breaks on the frame a blow lands: the
## paladin's swing (Combat.reached, only a blow that struck: a swing cut by the dodge never reaches), his waves
## (Projectiles, non-hostile), an enemy's blow or a hazard landing (Ground.zone_landed). Never by walking.
## It changes nothing of the fight: no hit stop, no number, no combo, no Magia, no ultimate charge, no slow motion, not
## a target of the aim assist (only the Horde is), stops neither bodies nor shots (not an ArenaObstacle).
##
## The look is a placeholder for the environment-artist and the technical-artist (AT-Q2): a plain lit shape per piece
## in the clay, wood or branch of the room's biome (the spec's section 3), a squash of SQUASH_TIME before it goes,
## shards by Fx.chips and dust by Fx.wisps (both in Fx's own dice: breaking never moves the run's).

## Seconds a struck piece squashes before it goes (the "gives and yields" of a struck enemy, P2), and how flat.
const SQUASH_TIME := 0.04
const SQUASH := 0.75
## Degrees a cracked crate's board leans, and how much darker it reads.
const CRACK_LEAN := 2.0
const CRACK_DARK := 0.8
## The body of each material per room (hue degrees, saturation, value; at_q0_breakables.md section 3); "" the rest.
const CLAY := {
	&"hall": Vector3(26, 0.3, 0.43), &"crypt": Vector3(34, 0.14, 0.5), &"garden": Vector3(22, 0.35, 0.4),
	&"sanctuary": Vector3(36, 0.2, 0.55), &"altar": Vector3(24, 0.35, 0.45), &"runes": Vector3(222, 0.1, 0.45),
	&"seal_chamber": Vector3(240, 0.1, 0.34), &"": Vector3(26, 0.3, 0.43),
}
const WOOD := Vector3(30, 0.22, 0.4)
const BRANCH := Vector3(30, 0.22, 0.4)
const SAPLING := Vector3(48, 0.22, 0.62)
## Shards and dust of a break: how many, how fast, how long they last (placeholder; AT-Q2 makes them settle 4 s).
const SHARDS := {Breakables.Stuff.CERAMIC: 8, Breakables.Stuff.WATER: 8, Breakables.Stuff.WOOD: 7,
	Breakables.Stuff.BRANCH: 6}
const SHARD_SPEED := 2.6
const SHARD_LIFE := 0.6
const DUST := 3

var game: Game
var rules: Breakables
var meshes: Array[Node3D] = []
var _squash := PackedFloat32Array()
var _room: StringName = &""


static func make(g: Game, layout: RoomLayout) -> BreakFloor:
	if layout == null or layout.breakables.is_empty():
		return null
	var f := BreakFloor.new()
	f.name = "Breakables"
	f.game = g
	f._room = layout.id
	f.rules = Breakables.new(layout.breakables)
	g.arena.add_child(f)
	return f


func _ready() -> void:
	_squash.resize(rules.count())
	for p in rules.pieces:
		var m := _piece(p)
		add_child(m)
		meshes.append(m)
	game.combat.reached.connect(_on_reached)
	game.ground.zone_landed.connect(_on_landed)
	# the room's line once the room is entered (Rooms enters it in the tally after the arena is built)
	_tally.call_deferred()


func _exit_tree() -> void:
	if game.combat.reached.is_connected(_on_reached):
		game.combat.reached.disconnect(_on_reached)
	if game.ground.zone_landed.is_connected(_on_landed):
		game.ground.zone_landed.disconnect(_on_landed)


## Each world step (Game._step, after the shots): the paladin's waves on the pieces, the squashes running out.
func step(dt: float) -> void:
	for s in game.projectiles.shots:
		if Projectiles.hostile(s):
			continue
		_show(rules.circle(s.pos, maxf(s.radius, s.half_width), Breakables.Source.HERO))
	for i in _squash.size():
		if _squash[i] > 0.0:
			_squash[i] -= dt
			if _squash[i] <= 0.0:
				meshes[i].visible = false


## Every piece whole again (tools: the feel probe swings among them again and again).
func restore() -> void:
	rules = Breakables.new(rules.pieces)
	for i in meshes.size():
		meshes[i].visible = true
		meshes[i].scale = Vector3.ONE
		meshes[i].rotation = Vector3.ZERO
		_squash[i] = 0.0


func _on_reached(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> void:
	_show(rules.swing(shape, origin, dir, reach, width))


func _on_landed(z: Ground.Zone) -> void:
	var source := Breakables.Source.HAZARD if z.hazard > 0.0 or z.floor_own else Breakables.Source.ENEMY
	if source == Breakables.Source.ENEMY and z.power <= 0.0:
		return  # (a rune that only marks, a summon)
	_show(rules.reached_by(func(p: Vector2, r: float) -> bool: return Ground.inside(z, p, r), source))


func _show(did: Dictionary) -> void:
	var heard := {}
	for i: int in did.cracked:
		var m := meshes[i]
		m.rotation_degrees.z += CRACK_LEAN
		_tint(m, CRACK_DARK)
		_shards(i, 3)
	for i: int in did.broken:
		var p := rules.pieces[i]
		meshes[i].scale.y = SQUASH
		_squash[i] = SQUASH_TIME
		_shards(i, SHARDS[Breakables.material_of(p.form)])
		var dust := _color(p.form).lightened(0.25)
		game.fx.wisps(Vector3(p.at.x, p.height * 0.4, p.at.y), Vector3.UP, dust, DUST, 0.8, 0.35, 0.5, 0.8, 0.6)
		heard[Breakables.SOUND[Breakables.material_of(p.form)]] = true
	for sound: StringName in heard:
		Audio.play(sound)  # one a material a blow; the VoiceGate keeps a family to 2 voices
	if not did.cracked.is_empty() or not did.broken.is_empty():
		_tally()


func _shards(i: int, count: int) -> void:
	var p := rules.pieces[i]
	var c := _color(p.form)
	var away := Vector3(p.at.x - game.player.pos.x, 0.0, p.at.y - game.player.pos.y).normalized()
	game.fx.chips(Vector3(p.at.x, p.height * 0.5, p.at.y), away + Vector3.UP * 0.6, c / Fx.MOTE_GLOW, count, SHARD_SPEED,
		0.08, SHARD_LIFE, 1.0)


func _tally() -> void:
	if is_instance_valid(game) and game.room_tally != null:
		game.room_tally.breakables(rules.tally())


func _color(form: BreakablePiece.Form) -> Color:
	var hsv: Vector3
	match Breakables.material_of(form):
		Breakables.Stuff.WOOD:
			hsv = WOOD
		Breakables.Stuff.BRANCH:
			hsv = SAPLING if form == BreakablePiece.Form.SAPLING else BRANCH
		_:
			hsv = CLAY.get(_room, CLAY[&""])
	var c := Color.from_hsv(hsv.x / 360.0, hsv.y, hsv.z)
	if form == BreakablePiece.Form.WATER:
		c = c.darkened(0.3)  # (the wet band reads "it holds water")
	return c


func _tint(m: Node3D, k: float) -> void:
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var mat := (mi as MeshInstance3D).material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = mat.albedo_color * Color(k, k, k)


## A plain shape for a piece (placeholder): round and full for clay, square for wood, thin sticks for branches.
func _piece(p: BreakablePiece) -> Node3D:
	var root := Node3D.new()
	root.position = Vector3(p.at.x, 0.0, p.at.y)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color(p.form)
	mat.roughness = 1.0
	var mi := MeshInstance3D.new()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var h := p.height
	match p.form:
		BreakablePiece.Form.CRATE:
			var b := BoxMesh.new()
			b.size = Vector3(p.radius * 1.5, h, p.radius * 1.5)
			mi.mesh = b
		BreakablePiece.Form.PLANK, BreakablePiece.Form.BENCH:
			var b := BoxMesh.new()
			b.size = Vector3(p.radius * 2.2, h, p.radius * 0.8)
			mi.mesh = b
		BreakablePiece.Form.BRANCH:
			var c := CylinderMesh.new()
			c.top_radius = 0.03
			c.bottom_radius = 0.06
			c.height = h
			mi.mesh = c
			mi.rotation_degrees.z = 12.0
		BreakablePiece.Form.SAPLING:
			var s := SphereMesh.new()
			s.radius = p.radius
			s.height = h
			mi.mesh = s
		BreakablePiece.Form.OFFERING:
			var c := CylinderMesh.new()
			c.top_radius = p.radius
			c.bottom_radius = p.radius * 0.6
			c.height = h
			mi.mesh = c
		_:
			var c := CylinderMesh.new()
			c.top_radius = p.radius * (0.75 if p.form == BreakablePiece.Form.WATER else 0.45)
			c.bottom_radius = p.radius * 0.7
			c.height = h
			mi.mesh = c
	mi.position.y = h * 0.5
	root.add_child(mi)
	return root
