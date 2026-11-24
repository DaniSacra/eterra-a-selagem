class_name EmethView
extends SubViewportContainer
## The Emeth itself on a page (the Forja, ciclo visual 2026-11-20, item 3; UI-HB4): the game's own model
## (EmethSword.make, the same blade, guard and grip, Meshy zero), lit in a small world of its own and laid slantwise
## across the page with the tip up, turning a few degrees to and fro so the crystal catches the light. Its rank of
## Temperar shows on the blade (EmethSword.set_temper: the gold veins and the pale thread of the edge), and grows in
## when it goes up (show_rank with grow). The background is see-through: the page's paper shows behind it.
##   var v := EmethView.new().setup(Vector2(300, 380))
##   v.show_rank(Forge.temper(Save.data))

## The sword's slant on the page (degrees from upright), the sway's reach and its period (seconds).
const SLANT := -38.0
const SWAY := 9.0
const SWAY_TIME := 6.0
## Seconds a new rank takes to grow on the blade.
const GROW := 0.9
## The view's height against the sword's length.
const FRAME := 1.12
## The light: a warm key from the upper left and a cool fill, as the Livro's portrait page.
const KEY := Color(1.0, 0.9, 0.76)
const FILL := Color(0.55, 0.66, 0.72)

var rank := 0.0
## Lying flat, the tip to the right and no sway (the Forja's bench, docs/art/forge_spec.md 7).
var flat := false
var _target := 0.0
var _blade: ShaderMaterial
var _holder: Node3D
var _t := 0.0


func setup(px: Vector2, lying := false) -> EmethView:
	flat = lying
	name = "emeth"
	custom_minimum_size = px
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp := SubViewport.new()
	vp.name = "view"
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = FILL
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	env.environment = e
	vp.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, -40, 0)
	key.light_color = KEY
	key.light_energy = 1.3
	vp.add_child(key)
	# pommel to tip in the sword's space (EmethSword: the model's y_m stands at GRIP_TOP + (y_m - MODEL_GRIP_TOP) * scale)
	var bottom := EmethSword.GRIP_TOP + (EmethSword.MODEL_POMMEL - EmethSword.MODEL_GRIP_TOP) * EmethSword.scale()
	var length := EmethSword.TIP - bottom
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	# the whole sword, slanted, with a little air round it (size is the view's height)
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	# flat: the sword's length is the view's width (pommel and tip on its edges)
	cam.size = length * (px.y / px.x) if flat else length * FRAME
	cam.position = Vector3(0, 0, 4)
	cam.current = true
	vp.add_child(cam)
	_holder = Node3D.new()
	_holder.name = "holder"
	_holder.rotation_degrees.z = -90.0 if flat else SLANT
	vp.add_child(_holder)
	var sword := EmethSword.make()
	# the sword's middle (pommel to tip) on the camera's
	sword.position.y = -(bottom + EmethSword.TIP) * 0.5
	_holder.add_child(sword)
	var blade := sword.get_node_or_null("Blade") as MeshInstance3D
	_blade = blade.material_override as ShaderMaterial if blade != null else null
	return self


## The rank on the blade; grow: it comes in over GROW seconds (the moment of the upgrade), else at once.
func show_rank(r: float, grow := false) -> void:
	_target = clampf(r, 0.0, float(EmethSword.TEMPER_MAX))
	if not grow:
		rank = _target
	_apply()


func _apply() -> void:
	if _blade != null:
		EmethSword.set_temper(_blade, rank)


func _process(delta: float) -> void:
	_t += delta
	if _holder != null and not flat:
		_holder.rotation_degrees.y = sin(_t * TAU / SWAY_TIME) * SWAY
	if not is_equal_approx(rank, _target):
		rank = move_toward(rank, _target, delta / GROW)
		_apply()
