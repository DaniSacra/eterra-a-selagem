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
## The look (AT-Q2) is BreakableKit's: each piece in the clay, wood or branch of the room's biome (the spec's section
## 3), a squash of SQUASH_TIME before it goes, its shards flying low, lying 4 s and sinking (BreakableKit.shatter, a
## water jar's stain drying), splinters of a crack by Fx.chips and dust by Fx.wisps (Fx's own dice: breaking never
## moves the run's).

## Seconds a struck piece squashes before it goes (the "gives and yields" of a struck enemy, P2), and how flat.
const SQUASH_TIME := 0.04
const SQUASH := 0.75
## The body of each material per room (hue degrees, saturation, value; at_q0_breakables.md section 3); "" the rest.
const CLAY := {
	&"hall": Vector3(26, 0.3, 0.43), &"crypt": Vector3(34, 0.14, 0.5), &"garden": Vector3(22, 0.35, 0.4),
	&"sanctuary": Vector3(36, 0.2, 0.55), &"altar": Vector3(24, 0.35, 0.45), &"runes": Vector3(222, 0.1, 0.45),
	&"seal_chamber": Vector3(240, 0.1, 0.34), &"": Vector3(26, 0.3, 0.43),
}
const WOOD := Vector3(30, 0.22, 0.4)
const BRANCH := Vector3(30, 0.22, 0.4)
const SAPLING := Vector3(48, 0.22, 0.62)
## Splinters of a crack (the break's shards are BreakableKit's) and the dust of a break: how fast, how long, how much.
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
		var whole := _piece(rules.pieces[i])
		meshes[i].replace_by(whole)
		meshes[i].queue_free()
		meshes[i] = whole
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
		BreakableKit.crack(meshes[i])
		_shards(i, 3)
	for i: int in did.broken:
		var p := rules.pieces[i]
		meshes[i].scale.y = SQUASH
		_squash[i] = SQUASH_TIME
		var away := Vector3(p.at.x - game.player.pos.x, 0.0, p.at.y - game.player.pos.y)
		BreakableKit.shatter(self, p, _color(p.form), away)
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
	return Color.from_hsv(hsv.x / 360.0, hsv.y, hsv.z)  # (a water jar's wet band is BreakableKit's)


## A piece whole (AT-Q2, BreakableKit: its body in the room's clay, wood or branch, its lip and contact shadow).
func _piece(p: BreakablePiece) -> Node3D:
	return BreakableKit.build(p, _color(p.form), _room)
