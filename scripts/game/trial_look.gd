class_name TrialLook
extends ArenaRoom
## The look of the Provação (the trial, E5 spec docs/art/e5_spec.md section 5): a closed, low chamber of dark violet
## stone, quiet before the choice. Walls of 8 m on the sides away from the camera, the low cut wall in front; broken
## pillars engaged in the chamfered corners; a floor of small dark slabs with thin lilac veins running through them
## (trial_veins.gdshader) that stop short of the block; the block of the layout (&"trial_block") in the middle with the
## cross crack of lilac light on its top and front (x_crack.gdshader), lit from above by one ivory spot, the room's only
## shadow; the way out north under its arch with cold ivory lanterns on the wall. After the choice (settle) the veins
## and the crack lose 60% of their light. The entry slab with the same crack, in the room before the trial, is
## entry_slab (the gameplay places it where the door to the trial is offered).

## Veins and crack after the choice: this share of their light (spec 5.3: 60% less), in this many seconds by default.
const SETTLED := 0.4
const SETTLE_TIME := 1.5
## The walls (spec 5.2): height, the dark violet stone.
const WALL_HEIGHT := 8.0
const STONE := Color(0.62, 0.58, 0.72)
## The pillars in the corners: how far out along the corner's diagonal from the floor's cut, radius, broken heights.
const PILLAR_OUT := 0.75
const PILLAR_R := 0.42
const PILLAR_TOPS: Array[float] = [3.4, 2.1, 1.5, 2.7]
## The floor (spec 5.2): small dark slabs.
const FLOOR := {
	&"unit": 1.6, &"stone_a": Color(0.24, 0.23, 0.27), &"stone_b": Color(0.30, 0.29, 0.33),
	&"joint_color": Color(0.06, 0.05, 0.07), &"moss_color": Color(0.24, 0.23, 0.27), &"petal_color": Color(0.24, 0.23, 0.27),
	&"missing": 0.05, &"cracked": 0.6,
}
## The air (spec 5.4).
const AIR := {
	&"sky": Color(0.09, 0.085, 0.11), &"fog": Color(0.13, 0.12, 0.15), &"fog_depth": Vector2(40.0, 90.0),
	&"ambient": Color(0.24, 0.22, 0.28), &"ambient_gain": 2.0, &"moon": Color(0.6, 0.58, 0.7), &"moon_energy": 0.5,
	&"moon_shadow": false,
}
const MIST := Color(0.065, 0.055, 0.085)
## The lilac of the cracks, the veins' and the crack's brightest channel.
const LILAC := Color(0.52, 0.36, 0.78)
const VEIN_GLOW := 0.5
const CRACK_GLOW := 0.8
const VEIN_CLEAR := 1.5
## The spot over the block (spec 5.2): ivory, energy, cone, height; with shadow.
const SPOT := Color(1.0, 0.95, 0.85)
const SPOT_ENERGY := 3.0
const SPOT_CONE := 20.0
const SPOT_HEIGHT := 10.0
## A soft fill from above so the floor reads (no shadow).
const FILL := Color(0.6, 0.55, 0.75)
const FILL_ENERGY := 5.0
## The cold ivory lanterns of the way out, hung on the wall beside the arch (height, bracket).
const LANTERN_AT := 2.3
const LANTERN_BRACKET := Vector3(0.24, 0.12, 0.24)
## The block (spec 5.2): plinth and top lip, its crack quads.
const BLOCK_PLINTH := Vector2(0.18, 0.15)
const BLOCK_LIP := Vector2(0.1, 0.06)
## The entry slab (spec 5.1): side, frame, the wisps over it (size, alpha, height).
const SLAB_SIDE := 2.4
const SLAB_FRAME := 0.15
const WISP := Vector2(1.6, 0.8)
const WISP_ALPHA := 0.25
const WISP_Y := 0.6
const VEIN_SHADER := preload("res://assets/shaders/trial_veins.gdshader")
const CRACK_SHADER := preload("res://assets/shaders/x_crack.gdshader")

static var _cold: TombKit.Lamp

var _level := 1.0
var _veins: ShaderMaterial
var _cracks: Array[ShaderMaterial] = []
var _tween: Tween


func floor_look() -> Dictionary:
	return FLOOR


func stone_tint() -> Color:
	return STONE


func air() -> Dictionary:
	return AIR


func mist() -> Color:
	return MIST


func in_wall(i: int) -> bool:
	var u := layout.exits[i].inward
	return u.y > 0.5 or u.x > 0.5


func door_lamp() -> TombKit.Lamp:
	return cold_lamp()


## The cold ivory lantern of the trial's way out (no shadow).
static func cold_lamp() -> TombKit.Lamp:
	if _cold == null:
		_cold = TombKit.Lamp.new(Color(0.9, 0.9, 0.95), Color(1.5, 1.45, 1.3), Color(0.92, 0.9, 0.86), 1.4, 4.5)
	return _cold


func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		super.edge(a, b, out, kind, faces)
		return
	closed_edge(a, b, out, WALL_HEIGHT, ashlar())


func piece(o: ArenaObstacle) -> void:
	if o.piece == &"trial_block":
		_block(o)
		return
	super.piece(o)


func dress() -> void:
	_corners()
	_vein_sheet()
	var block := Vector2.ZERO
	for o in layout.obstacles:
		if o.piece == &"trial_block":
			block = o.center
	moon_shaft(block, SPOT, SPOT_ENERGY, SPOT_CONE, SPOT_HEIGHT, true, true)
	var fill := key_light(FILL, FILL_ENERGY, 9.0)
	fill.shadow_enabled = false
	_lanterns()
	backdrop(Color(0.13, 0.12, 0.155), Color(0.06, 0.055, 0.075), Color(0.2, 0.18, 0.26))


## The light of the veins and the cracks (1 before the choice, SETTLED after it).
func vein_level() -> float:
	return _level


## After the choice (spec 5.3): the veins and the cracks lose their light in `seconds` (0: at once).
func settle(seconds := SETTLE_TIME) -> void:
	if _tween != null:
		_tween.kill()
	if seconds <= 0.0 or not is_inside_tree():
		_set_level(SETTLED)
		return
	_tween = create_tween()
	_tween.tween_method(_set_level, _level, SETTLED, seconds)


func _set_level(v: float) -> void:
	_level = v
	if _veins != null:
		_veins.set_shader_parameter(&"level", v)
	for c in _cracks:
		c.set_shader_parameter(&"level", v)


## The lab's states: "after" the choice made.
func demo(state: String) -> void:
	_set_level(SETTLED if state == "after" else 1.0)


## A broken pillar engaged in each chamfered corner (spec 5.2), outside the floor.
func _corners() -> void:
	var poly := layout.floor.polys[0]
	var mid := layout.floor.bounds().get_center()
	var k := 0
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var d := b - a
		if absf(d.x) < 0.05 or absf(d.y) < 0.05:
			continue
		var c := (a + b) * 0.5
		var out := (c - mid).normalized()
		var at := c + Vector2(signf(out.x), signf(out.y)).normalized() * (PILLAR_OUT + PILLAR_R)
		tomb.column(at, PILLAR_R, PILLAR_TOPS[k % PILLAR_TOPS.size()], ashlar(), true)
		k += 1


## The veins: a sheet of the floor's own triangles 1 cm over it.
func _vein_sheet() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for poly in layout.floor.polys:
		var tris := Geometry2D.triangulate_polygon(poly)
		for t in tris:
			st.add_vertex(Vector3(poly[t].x, 0.01, poly[t].y))
	_veins = ShaderMaterial.new()
	_veins.shader = VEIN_SHADER
	_veins.set_shader_parameter(&"color", LILAC)
	_veins.set_shader_parameter(&"glow", VEIN_GLOW)
	_veins.set_shader_parameter(&"clear", VEIN_CLEAR)
	for o in layout.obstacles:
		if o.piece == &"trial_block":
			_veins.set_shader_parameter(&"block_center", o.center)
			_veins.set_shader_parameter(&"block_half", o.half)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _veins
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## The block on its footprint (spec 5.2): a plinth, the body, a lip round its top; the cross crack on its top and on the
## face the camera sees.
func _block(o: ArenaObstacle) -> void:
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var size := Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0)
	var mat := ashlar()
	m.block(foot, Vector3(size.x + BLOCK_PLINTH.y * 2.0, BLOCK_PLINTH.x, size.z + BLOCK_PLINTH.y * 2.0), -o.yaw, mat)
	m.block(foot, Vector3(size.x, size.y - BLOCK_LIP.x, size.z), -o.yaw, mat)
	m.block(foot + Vector3(0, size.y - BLOCK_LIP.x, 0), Vector3(size.x + BLOCK_LIP.y * 2.0, BLOCK_LIP.x, size.z + BLOCK_LIP.y * 2.0), -o.yaw, mat)
	var basis := Basis(Vector3.UP, -o.yaw)
	_cracks.append(crack(self, foot + Vector3(0, size.y + 0.006, 0), basis * Basis(Vector3.RIGHT, -PI * 0.5), Vector2(size.x, size.z)))
	for face: Vector3 in [Vector3(0, 0, 1), Vector3(1, 0, 0)]:
		var f := basis * face
		var w := size.x if face.z != 0.0 else size.z
		var b := Basis.looking_at(-f, Vector3.UP)
		_cracks.append(crack(self, foot + f * (w * 0.5 + 0.006) + Vector3(0, (size.y - BLOCK_LIP.x) * 0.55, 0), b, Vector2(w * 0.9, (size.y - BLOCK_LIP.x) * 0.8)))


## A quad of the cross crack under `parent`, its face along basis.z, `size` across.
static func crack(parent: Node3D, at: Vector3, basis: Basis, size: Vector2) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = CRACK_SHADER
	mat.set_shader_parameter(&"color", LILAC)
	mat.set_shader_parameter(&"glow", CRACK_GLOW)
	var q := QuadMesh.new()
	q.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = q
	mi.material_override = mat
	mi.transform = Transform3D(basis, at)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mat


## The cold ivory lanterns hung on the wall each side of the way out's arch.
func _lanterns() -> void:
	for i in layout.exits.size():
		if i >= exits_used or not in_wall(i):
			continue
		var e := layout.exits[i]
		var u := e.inward
		var side := Vector2(-u.y, u.x)
		var w := absf(e.mouth.size.dot(side))
		var edge_mid := e.mouth.get_center() + u * absf(e.mouth.size.dot(u)) * 0.5
		for sd: float in [-1.0, 1.0]:
			var p := edge_mid + side * sd * (w * 0.5 + JAMB + 0.6) - u * (FACE_SET + LANTERN_BRACKET.z * 0.5)
			tomb.lantern(Vector3(p.x, LANTERN_AT, p.y), atan2(u.x, u.y), ashlar(), cold_lamp(), ~Arena.CROWD_LAYER, LANTERN_BRACKET)


## The entry slab of the trial (spec 5.1), laid in the floor of the room before it at `at` under `parent`: a dark slab
## in a frame of stone, the cross crack of lilac light on it pulsing, wisps of violet mist over it. Flush with the floor
## (nothing to trip on); returns the node (free it to take the slab away).
static func entry_slab(parent: Node3D, at: Vector2, yaw := 0.0) -> Node3D:
	var root := Node3D.new()
	root.name = "TrialSlab"
	parent.add_child(root)
	var kit := ArenaKit.new(root, hash(at))
	var mm := kit.masonry
	var stone := mm.stone(0.0, STONE * 0.8)
	var foot := Vector3(at.x, -0.2, at.y)
	mm.box(foot + Vector3(0, 0.1, 0), Vector3(SLAB_SIDE, 0.2, SLAB_SIDE), yaw, stone, false)
	var inner := SLAB_SIDE - SLAB_FRAME * 2.0
	mm.box(foot + Vector3(0, 0.105, 0), Vector3(inner, 0.2, inner), yaw, mm.stone(0.0, STONE * 0.55), false)
	mm.merge()
	crack(root, Vector3(at.x, 0.012, at.y), Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -PI * 0.5), Vector2(inner, inner))
	kit.mist_bank(Vector3(at.x, WISP_Y, at.y), WISP, LILAC * 0.6, WISP_ALPHA, 0.5, 0.0)
	return root
