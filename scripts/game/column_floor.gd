class_name ColumnFloor
extends RefCounted
## The cracked columns that topple in a fight (RP-09; docs/design/rooms_progression.md): runs a ColumnFall on the
## paladin's swings (Combat.reached). The first blow cracks a column (a shake, dust and the stone's crack), the last
## topples it the way the blow went: its band shows in the hazards' amber for fall_time (Ground.add_fall) while it leans, then it
## lands: fall_damage to every enemy on the band, nothing to him (Ground: no power), dust along it, and a stump stays
## (the same footprint: still stops bodies, no more shots; Arena.cover loses it). Rooms makes one when the room's
## layout has a column with hits_to_fall.
##
## The look is a placeholder (environment-artist): the column's own meshes (ArenaRoom.toppling, kept out of the merge)
## shake on the crack, lean over on a pivot at the foot, and vanish where it lands, the stump drawn by TombKit.column.

## Degrees it leans when cracked, and the most it leans before it lands.
const CRACK_LEAN := 3.0
const FALL_LEAN := 82.0
## Seconds the crack shakes it.
const CRACK_SHAKE := 0.25

var fall: ColumnFall
var game: Game
## Each column's pivot (a Node3D at its foot holding its meshes; null: no look to move), its band on the floor while
## it leans, and the seconds since it began to lean or cracked.
var pivots: Array[Node3D] = []
var zones: Array[Ground.Zone] = []
var lean_t := PackedFloat32Array()
var shake_t := PackedFloat32Array()
var enemy_damage := 0.0
var kills := 0
var cracked := 0
var toppled := 0


func _init(g: Game, obstacles: Array[ArenaObstacle]) -> void:
	game = g
	fall = ColumnFall.new(obstacles)
	var n := fall.columns.size()
	zones.resize(n)
	lean_t.resize(n)
	shake_t.resize(n)
	var look := g.arena.look
	for o in fall.columns:
		var meshes: Array = look.toppling.get(o, []) if look != null else []
		pivots.append(_pivot(look, o, meshes) if not meshes.is_empty() else null)
	g.combat.reached.connect(_on_reached)
	g.ground.hazard_landed.connect(_on_landed)


func count() -> int:
	return fall.columns.size()


func step(dt: float) -> void:
	for i in count():
		var p := pivots[i]
		if fall.stage[i] == ColumnFall.Stage.LEANING:
			lean_t[i] += dt
			if p != null:
				var k := clampf(lean_t[i] / fall.columns[i].fall_time, 0.0, 1.0)
				_tilt(p, i, lerpf(CRACK_LEAN, FALL_LEAN, k * k))
		elif fall.stage[i] == ColumnFall.Stage.CRACKED and shake_t[i] > 0.0:
			shake_t[i] = maxf(0.0, shake_t[i] - dt)
			if p != null:
				_tilt(p, i, CRACK_LEAN + sin(shake_t[i] * 60.0) * shake_t[i] * 6.0)


## The fight is over (or the room left): a column leaning falls at once without striking.
func stop() -> void:
	for i in count():
		if zones[i] != null:
			Ground.end_zone(zones[i])
			zones[i] = null
			_down(i)
	if game.combat.reached.is_connected(_on_reached):
		game.combat.reached.disconnect(_on_reached)
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


## The room's numbers (RoomTally.columns).
func tally() -> Dictionary:
	return {"columns": count(), "cracked": cracked, "toppled": toppled, "enemy_damage": snappedf(enemy_damage, 0.1),
		"kills": kills}


func _on_reached(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> void:
	var did := fall.hit(shape, origin, dir, reach, width)
	for i: int in did.cracked:
		cracked += 1
		shake_t[i] = CRACK_SHAKE
		_dust(fall.columns[i].center, 1.6)
		Audio.play(CombatSounds.EVENTS[&"column_crack"])
	for i: int in did.toppled:
		toppled += 1
		var b := fall.band(i)
		var o := fall.columns[i]
		zones[i] = game.ground.add_fall(b.from, b.dir, b.length, b.width, o.fall_time, o.fall_damage, Ground.FALL_SOURCE)
		_dust(o.center, 1.0)
		Audio.play(CombatSounds.EVENTS[&"column_crack"])


func _on_landed(z: Ground.Zone) -> void:
	var i := zones.find(z)
	if i < 0:
		return
	zones[i] = null
	var dealt := PlateFloor.strike(game, z, Vector2.ZERO, Ground.FALL_SOURCE, false, true)
	enemy_damage += dealt.x
	kills += int(dealt.y)
	var b := fall.band(i)
	for k in 4:
		_dust(b.from + b.dir * b.length * (0.3 + 0.23 * k), 0.4)
	game.fx.shake(0.35)
	Audio.play(CombatSounds.EVENTS[&"column_fall"])
	_down(i)


## Column i is on the floor: a stump in its place, stopping bodies and no more shots.
func _down(i: int) -> void:
	var o := fall.columns[i]
	fall.landed(i)
	game.arena.cover.erase(o)
	var p := pivots[i]
	if p != null and is_instance_valid(p):
		p.visible = false
		var look := game.arena.look
		if look != null:
			look.tomb.column(o.center, o.radius, maxf(0.6, TombKit.COLUMN_BASE + 0.4), look.stone(), true)


## A Node3D at the column's foot with its meshes moved under it (keeping where they are), to lean it.
static func _pivot(look: ArenaRoom, o: ArenaObstacle, meshes: Array) -> Node3D:
	var p := Node3D.new()
	p.name = "Toppling"
	look.add_child(p)
	p.position = Vector3(o.center.x, 0.0, o.center.y)
	for mi: MeshInstance3D in meshes:
		if is_instance_valid(mi):
			var t := mi.global_transform
			mi.get_parent().remove_child(mi)
			p.add_child(mi)
			mi.global_transform = t
	return p


## Leans pivot i by `degrees` toward its fall's way (or away from the blow that cracked it).
func _tilt(p: Node3D, i: int, degrees: float) -> void:
	var w := fall.way[i] if fall.way[i] != Vector2.ZERO else (fall.columns[i].center - game.player.pos).normalized()
	var axis := Vector3(w.x, 0.0, w.y).cross(Vector3.UP).normalized()
	if axis.length_squared() < 0.5:
		return
	p.basis = Basis(axis, -deg_to_rad(degrees))


func _dust(at: Vector2, y: float) -> void:
	game.fx.burst(&"dust", Vector3(at.x, y, at.y))
