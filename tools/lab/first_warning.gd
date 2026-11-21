extends Node
## The body of tools/first_warning.gd (AT-SA2): see there.

const POINTS := 24
## Seconds of play before giving up.
const LIMIT := 60.0

var game: Game
var _t := 0.0


func _ready() -> void:
	# headless the window is square: the game's screen is 16:9 (project.godot, 1280 x 720)
	get_tree().root.size = Vector2i(1280, 720)
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(game)


func _process(dt: float) -> void:
	if game == null or not game.is_inside_tree() or game.ground == null:
		return
	_t += dt
	if _t > LIMIT:
		print("FIRST_WARNING ", JSON.stringify({"seed": Dev.num("seed", 0), "none": true}))
		get_tree().quit()
		return
	for z: Ground.Zone in game.ground.zones:
		if z.kind == Ground.Kind.WARNING and z.by != &"" and not z.floor_own:
			_tell(z)
			get_tree().quit()
			return


func _outline(z: Ground.Zone) -> PackedVector2Array:
	var out := PackedVector2Array()
	match z.shape:
		Ground.Shape.LINE:
			var side := z.dir.orthogonal() * z.width * 0.5
			for k in POINTS + 1:
				var along := z.dir * z.radius * k / POINTS
				out.append(z.pos + along + side)
				out.append(z.pos + along - side)
		Ground.Shape.ARC:
			out.append(z.pos)
			var half := deg_to_rad(z.width) * 0.5
			for k in POINTS + 1:
				out.append(z.pos + z.dir.rotated(-half + 2.0 * half * k / POINTS) * z.radius)
		_:
			for k in POINTS:
				out.append(z.pos + Vector2.from_angle(TAU * k / POINTS) * z.radius)
	return out


func _tell(z: Ground.Zone) -> void:
	var cam := get_viewport().get_camera_3d()
	var size := get_viewport().get_visible_rect().size
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	var whole := true
	for p in _outline(z):
		var w := Vector3(p.x, 0.0, p.y)
		var s := cam.unproject_position(w) / size
		if cam.is_position_behind(w):
			whole = false
		lo = lo.min(s)
		hi = hi.max(s)
		if s.x < 0.0 or s.y < 0.0 or s.x > 1.0 or s.y > 1.0:
			whole = false
	print("FIRST_WARNING ", JSON.stringify({"seed": Dev.num("seed", 0), "t": snappedf(_t, 0.01), "by": z.by,
		"shape": z.shape, "min": [snappedf(lo.x, 0.001), snappedf(lo.y, 0.001)],
		"max": [snappedf(hi.x, 0.001), snappedf(hi.y, 0.001)], "whole": whole, "screen": [size.x, size.y],
		"room": game.arena.layout.id if game.arena.layout != null else &""}))
