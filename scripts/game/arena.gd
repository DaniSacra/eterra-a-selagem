class_name Arena
extends Node2D
## The catacombs under the old church of Valmor: one large continuous hall.
## Bakes the floor and the top wall from grid tiles, places props and lights, and answers collision questions.

const SIZE := Vector2(1120, 800)
const TILE := 16
const WALL_H := 40
const CELL := 64.0
const AMBIENT := Color(0.40, 0.42, 0.68)
const CANDLE_LIGHT := Color(1.0, 0.82, 0.5)
const GLASS_LIGHT := Color(1.0, 0.95, 0.72)

var door_pos := Vector2(SIZE.x * 0.5, 0)
var _obstacles: Dictionary = {}
var _door: Sprite2D
var _world: Node2D
var _rng := RandomNumberGenerator.new()

static var _light_tex: Texture2D


## Stepped light pool (three rings, no smooth gradient), shared by every light in the game.
static func light_texture() -> Texture2D:
	if _light_tex == null:
		var n := 64
		var img := Image.create_empty(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d := Vector2(x - n / 2.0 + 0.5, y - n / 2.0 + 0.5).length() / (n / 2.0)
				var a := 1.0 if d < 0.38 else 0.62 if d < 0.66 else 0.3 if d < 0.96 else 0.0
				img.set_pixel(x, y, Color(a, a, a, 1.0))
		_light_tex = ImageTexture.create_from_image(img)
	return _light_tex


static func make_light(color: Color, radius: float, energy: float = 1.0) -> PointLight2D:
	var l := PointLight2D.new()
	l.texture = light_texture()
	l.texture_scale = radius / 32.0
	l.color = color
	l.energy = energy
	return l


func build(world: Node2D) -> void:
	_world = world
	_rng.seed = 20261113
	var mod := CanvasModulate.new()
	mod.color = AMBIENT
	add_child(mod)
	_bake_floor()
	_bake_wall()
	_place_props()


func _draw() -> void:
	# side and bottom walls: plain dark stone, the hall ends there
	var dark := Palette.c(&"noite", 4)
	var edge := Palette.c(&"noite", 3)
	draw_rect(Rect2(-TILE, -WALL_H, TILE, SIZE.y + WALL_H + TILE), dark)
	draw_rect(Rect2(SIZE.x, -WALL_H, TILE, SIZE.y + WALL_H + TILE), dark)
	draw_rect(Rect2(-TILE, SIZE.y, SIZE.x + TILE * 2, TILE), dark)
	draw_rect(Rect2(-2, 0, 2, SIZE.y), edge)
	draw_rect(Rect2(SIZE.x, 0, 2, SIZE.y), edge)
	draw_rect(Rect2(0, SIZE.y, SIZE.x, 2), edge)


func _bake_floor() -> void:
	var tiles: Array[Image] = []
	for i in Art.count(&"floor"):
		tiles.append(GridSprite.to_image(Art.def(&"floor"), i))
	var img := Image.create_empty(int(SIZE.x), int(SIZE.y), false, Image.FORMAT_RGBA8)
	var src := Rect2i(0, 0, TILE, TILE)
	for ty in int(SIZE.y) / TILE:
		for tx in int(SIZE.x) / TILE:
			var roll := _rng.randf()
			var v := 0 if roll < 0.7 else 1 if roll < 0.8 else _rng.randi_range(2, tiles.size() - 1)
			img.blit_rect(tiles[v], src, Vector2i(tx * TILE, ty * TILE))
	var rubble := Art.def(&"rubble")
	for i in 90:
		var piece := GridSprite.to_image(rubble, _rng.randi_range(0, Art.count(&"rubble") - 1))
		var at := Vector2i(_rng.randi_range(8, int(SIZE.x) - 24), _rng.randi_range(8, int(SIZE.y) - 20))
		img.blend_rect(piece, Rect2i(Vector2i.ZERO, piece.get_size()), at)
	var s := Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	s.centered = false
	s.z_index = -10
	add_child(s)


func _bake_wall() -> void:
	var img := Image.create_empty(int(SIZE.x), WALL_H, false, Image.FORMAT_RGBA8)
	var wall := Art.def(&"wall")
	for tx in int(SIZE.x) / TILE:
		var v := 0 if _rng.randf() < 0.7 else _rng.randi_range(1, 2)
		img.blit_rect(GridSprite.to_image(wall, v), Rect2i(0, 0, TILE, WALL_H), Vector2i(tx * TILE, 0))
	var glass := GridSprite.to_image(Art.def(&"glass"))
	var ossuary := GridSprite.to_image(Art.def(&"ossuary"))
	var x := 72
	var i := 0
	while x < int(SIZE.x) - 72:
		if absf(x - door_pos.x) > 70:
			if i % 2 == 0:
				img.blend_rect(glass, Rect2i(Vector2i.ZERO, glass.get_size()), Vector2i(x - 12, 2))
				_add_glass_light(Vector2(x, 0))
			else:
				img.blend_rect(ossuary, Rect2i(Vector2i.ZERO, ossuary.get_size()), Vector2i(x - 16, 10))
		x += 88
		i += 1
	var s := Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	s.centered = false
	s.position = Vector2(0, -WALL_H)
	s.z_index = -9
	add_child(s)
	_door = Art.sprite(&"door")
	_door.position = Vector2(door_pos.x, -WALL_H)
	_door.z_index = -8
	add_child(_door)


## Light falling through a broken window: two stepped bands on the floor and a warm pool.
func _add_glass_light(at: Vector2) -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	for step in 2:
		var beam := Polygon2D.new()
		var w := 9.0 - step * 4.0
		var spread := 26.0 - step * 10.0
		beam.polygon = PackedVector2Array([at + Vector2(-w, 0), at + Vector2(w, 0), at + Vector2(spread + 14, 96), at + Vector2(-spread + 14, 96)])
		beam.color = Color(GLASS_LIGHT, 0.10)
		beam.material = mat
		beam.z_index = -7
		add_child(beam)
	var l := make_light(GLASS_LIGHT, 80.0, 0.45)
	l.position = at + Vector2(8, 50)
	add_child(l)


func _place_props() -> void:
	var start := SIZE * 0.5
	# columns on a lattice, with a candle beside some of them
	for gy in 4:
		for gx in 6:
			var at := Vector2(120 + gx * 176, 130 + gy * 180)
			if at.distance_to(start) < 60:
				continue
			_prop(&"column", at, 6.0)
			if (gx + gy) % 2 == 0:
				_candle(at + Vector2(13 if gx % 2 == 0 else -13, 5))
	# tombs along the walls and a few in the hall
	for i in 8:
		_prop(&"tomb", Vector2(90 + i * 135, 36), 11.0)
		if i % 2 == 0:
			_candle(Vector2(90 + i * 135 + 24, 40))
	for at: Vector2 in [Vector2(210, 400), Vector2(910, 400), Vector2(560, 215), Vector2(560, 610), Vector2(300, 700), Vector2(820, 700)]:
		_prop(&"tomb", at, 11.0)
		_candle(at + Vector2(-22, 2))
	for i in 7:
		_candle(Vector2(60 + i * 166, SIZE.y - 14))


func _prop(sprite: StringName, at: Vector2, radius: float) -> void:
	var s := Art.sprite(sprite)
	s.position = at
	_world.add_child(s)
	add_obstacle(at, radius)


func _candle(at: Vector2) -> void:
	var s := Art.animated(&"candle")
	s.position = at
	s.play(&"burn")
	s.frame = _rng.randi_range(0, 2)
	_world.add_child(s)
	var l := make_light(CANDLE_LIGHT, 44.0, 0.5)
	l.position = Vector2(0, -12)
	s.add_child(l)
	add_obstacle(at, 2.0)


func add_obstacle(at: Vector2, radius: float) -> void:
	var reach := radius + 14.0
	for cy in range(int(floor((at.y - reach) / CELL)), int(floor((at.y + reach) / CELL)) + 1):
		for cx in range(int(floor((at.x - reach) / CELL)), int(floor((at.x + reach) / CELL)) + 1):
			var key := Vector2i(cx, cy)
			if not _obstacles.has(key):
				_obstacles[key] = []
			_obstacles[key].append(Vector3(at.x, at.y, radius))


## Keeps a circle inside the hall and out of columns and tombs. One dictionary lookup per call.
func resolve(pos: Vector2, radius: float) -> Vector2:
	pos.x = clampf(pos.x, radius, SIZE.x - radius)
	pos.y = clampf(pos.y, radius + 2.0, SIZE.y - radius)
	var bucket: Variant = _obstacles.get(Vector2i(int(floor(pos.x / CELL)), int(floor(pos.y / CELL))))
	if bucket != null:
		for o: Vector3 in bucket:
			var d := pos - Vector2(o.x, o.y)
			var min_d := radius + o.z
			var len_sq := d.length_squared()
			if len_sq < min_d * min_d:
				pos = Vector2(o.x, o.y) + (d / sqrt(len_sq) if len_sq > 0.0001 else Vector2.DOWN) * min_d
	return pos


func open_door() -> void:
	_door.frame = 1


func bounds() -> Rect2:
	return Rect2(-TILE, -WALL_H, SIZE.x + TILE * 2, SIZE.y + WALL_H + TILE)
