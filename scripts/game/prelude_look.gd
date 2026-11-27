class_name PreludeLook
extends AltarLook
## The look of the two rooms before the first one (2026-11-26, docs/art/ref/antessala_sala00_2026-11-26): the Antessala (the
## corridor of 14 x 48 m: the stream, the trap's slab, the breakables) and the Sala 00 (the chamber of 18 x 16 m with the altar of
## the Blessing). Built on the altar chapel's stone, air and floor (no medallion, no sun: the floor is plain slabs) with what is
## theirs: the wall of the door's side 7 m high with the monumental door in it (3 x 5.5 m clear, shut leaves, the black inside, no
## stairs: HallDoor, the Salão's and the Cripta's), the long sides of the Antessala low (a mureta of 1.3 m, the mountain beyond),
## the Sala 00's walls those of the chapel. The art of both is to be a painting projected on this form (GP-8): the form, the
## collision and the door are what matter here. Nothing here collides: the layout's obstacles do (Arena._build_arena).
##   the door: closed until Rooms asks open_door_leaves(0)
##   the altar (Sala 00): its candles burn and the shaft stands on it until `spend()` (the Blessing taken)

## The wall of the door's side, the low wall of the corridor's long side.
const FACADE := 7.0
const MURETA := 1.3
## The door: clear width and height (m), its recess's depth, and the dim way light before it.
const DOOR := Vector2(3.0, 5.5)
const DOOR_RECESS := 1.2
const DOOR_LIGHT_UP := 3.0
const DOOR_LIGHT_OUT := 0.8
## The fill of the corridor, one light every FILL_EVERY m (energy, reach); the Antessala's air a little brighter than the chapel's.
const FILL_EVERY := 14.0
const FILL_LIGHT := 1.1
const FILL_REACH := 15.0
const OUTSIDE_AMBIENT := 1.2
const OUTSIDE_MOON := 1.3
## The altar after the Blessing: the shaft keeps this share of its light.
const SPENT_SHAFT := 0.45

var _door: HallDoor


## The Antessala (a corridor, outdoors) or the Sala 00 (the chamber).
func is_ante() -> bool:
	return layout != null and layout.id == &"ante"


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	var h := WALL_HEIGHT
	if out.y < -0.5:
		h = FACADE
	elif is_ante():
		h = MURETA
	closed_edge(a, b, out, h, ashlar())


func dress() -> void:
	var box := layout.floor.bounds()
	var north := box.position.y
	var altar := box.get_center()
	for o in layout.obstacles:
		if o.piece == &"altar":
			altar = o.center
	if is_ante():
		_shaft = moon_shaft(Vector2(0.0, box.get_center().y + 6.0), SHAFT, SHAFT_ENERGY, SHAFT_CONE * 1.6, SHAFT_HEIGHT, true, false)
		var z := box.end.y - FILL_EVERY * 0.5
		while z > north:
			_fill(Vector3(0.0, 6.0, z))
			z -= FILL_EVERY
	else:
		_shaft = moon_shaft(altar, SHAFT, SHAFT_ENERGY, SHAFT_CONE, SHAFT_HEIGHT, true, true)
		key_light(FILL, FILL_ENERGY, 10.0)
		kindle(0.0)  # (its candles burn until the Blessing is taken)
	var from := get_child_count()
	backdrop(MIST * 2.0, Color(0.035, 0.045, 0.06), Color(0.14, 0.2, 0.24))
	_far = added_since(from)


func _fill(at: Vector3) -> void:
	var l := OmniLight3D.new()
	l.position = at
	l.light_color = FILL
	l.light_energy = FILL_LIGHT
	l.omni_range = FILL_REACH
	l.shadow_enabled = false
	l.light_cull_mask = ArenaKit.WARM_MASK
	add_child(l)


func style() -> Dictionary:
	var st := super.style()
	if is_ante():
		st[&"air"][&"ambient_gain"] = float(st[&"air"][&"ambient_gain"]) * OUTSIDE_AMBIENT
		st[&"air"][&"moon_energy"] = float(st[&"air"][&"moon_energy"]) * OUTSIDE_MOON
	return st


## The Blessing was taken (Sala 00): the candles go out and the shaft keeps part of its light, the room's own lights stay.
func spend(seconds := KINDLE_TIME) -> void:
	if _lit != null:
		_lit.visible = false
	if _out != null:
		_out.visible = true
	if _candle_light != null:
		_candle_light.visible = false
	if _shaft != null:
		var to := _shaft.light_energy * SPENT_SHAFT
		if seconds <= 0.0 or not is_inside_tree():
			_shaft.light_energy = to
		else:
			create_tween().tween_property(_shaft, "light_energy", to, seconds)


## The monumental door in the north wall, shut: two leaves in a pointed arch, the black inside, no stairs; The medallion rod and the stairs of the other rooms' doors are not drawn.
func _doors() -> void:
	arena.exit_rod = false
	var north := layout.floor.bounds().position.y
	for i in mini(exits_used, layout.exits.size()):
		var e := layout.exits[i]
		var x := e.mouth.get_center().x
		var order := m.ashlar(0.0, CatacombHall.PORTAL_ORDER_TINT)
		_door = HallDoor.doorway(m, kit.root, order, Vector3(x, 0.0, north - FACE_SET), DOOR, CatacombHall.DOOR_ARC,
			CatacombHall.DOOR_FRAME, DOOR_RECESS, CatacombHall.DOOR_FACE_OUT)
		var l := OmniLight3D.new()
		l.position = Vector3(x, DOOR_LIGHT_UP, north + DOOR_LIGHT_OUT)
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = DOOR_DIM
		l.omni_range = 7.0
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
		arena._exit_lights.append(l)


## Opens the leaves (Rooms takes the stone off the mouth: Rooms._lock_door).
func open_door_leaves(i: int) -> void:
	if i == 0 and _door != null:
		_door.open()
