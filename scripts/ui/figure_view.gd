class_name FigureView
extends SubViewportContainer
## One enemy of the game standing on a page (the Compêndio's selected entry, ciclo visual 2026-11-20, item 3): its own
## baked figure (assets/baked/<model>.res, the crowd's painted body by a CrowdRenderer of its own with one figure, as the
## hub's people, HubNpc) in its idle, lit in a small world of its own, three-quarters to the camera and turning slowly.
## Unknown (never defeated): the same figure in ink, a silhouette only. The background is see-through.
##   var v := FigureView.new().setup(Vector2(150, 180))
##   v.show_enemy(load("res://data/enemies/skeleton.tres"), true)
## Only drawing (Meshy zero): nothing of the game is read or changed.

## Degrees the figure stands turned from the camera, how far it turns to and fro and over how many seconds.
const SWAY := 18.0
const SWAY_TIME := 8.0
## The view's height against the figure's height (air above the head and under the feet).
const FRAME := 1.18
const KEY := Color(1.0, 0.9, 0.78)
const FILL := Color(0.6, 0.66, 0.74)
## The silhouette of an unknown one: the page's ink.
const INK := Color(0.12, 0.09, 0.07)

var def: EnemyDef
var known := true
var _vp: SubViewport
var _cam: Camera3D
var _holder: Node3D
var _renderer: CrowdRenderer
var _kind: CrowdRenderer.Kind
var _t := 0.0


func setup(px: Vector2) -> FigureView:
	name = "figure"
	custom_minimum_size = px
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vp = SubViewport.new()
	_vp.name = "view"
	_vp.own_world_3d = true
	_vp.transparent_bg = true
	_vp.msaa_3d = Viewport.MSAA_4X
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_CLEAR_COLOR
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = FILL
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.25
	env.environment = e
	_vp.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, -30, 0)
	key.light_color = KEY
	key.light_energy = 1.4
	_vp.add_child(key)
	_cam = Camera3D.new()
	_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_cam.keep_aspect = Camera3D.KEEP_HEIGHT
	_cam.rotation_degrees.x = -12.0
	_cam.current = true
	_vp.add_child(_cam)
	_holder = Node3D.new()
	_holder.name = "holder"
	_vp.add_child(_holder)
	return self


## The figure of an enemy; known false draws it as a silhouette in ink.
func show_enemy(d: EnemyDef, p_known: bool) -> void:
	if d != def or p_known != known or _renderer == null:
		known = p_known
		def = d
		if _renderer != null:
			_renderer.queue_free()
		_renderer = CrowdRenderer.new()
		_renderer.name = "Figure"
		_holder.add_child(_renderer)
		_renderer.register(def)
		if known:
			# AP-4: a defeated one is drawn in the Livro's ink (technical-artist's FigureSketch); the unknown keep the silhouette
			FigureSketch.apply(_renderer, def, Book.INK, size.y if size.y > 0.0 else custom_minimum_size.y)
		_kind = _renderer.kind(def)
		var h := _kind.model.height * def.size
		_cam.size = h * FRAME
		# the camera looks down a little: raised so the middle of its view is the middle of the figure
		_cam.position = Vector3(0, h * 0.5 + 10.0 * tan(deg_to_rad(-_cam.rotation_degrees.x)), 10.0)
	# the unknown: a silhouette in the page's faded ink at 0.3 (AP-4 1.6)
	modulate = Color.WHITE if known else Color(Book.FADED, 0.3)
	_draw()


func _process(delta: float) -> void:
	_t += delta
	if def != null:
		_draw()


func _draw() -> void:
	if _renderer == null:
		return
	# AP-4: the sketch's own three-quarter view of this figure (FigureSketch.yaw), swaying a little round it
	var yaw := FigureSketch.yaw(_kind.model) + deg_to_rad(sin(_t * TAU / SWAY_TIME) * SWAY)
	_renderer.begin()
	var length := maxf(_kind.model.duration(&"idle"), 0.01)
	_renderer.add_kind(_kind, def, &"idle", fmod(_t, length), Vector3.ZERO, yaw, Color(0, 0, 0, 0))
	_renderer.commit()
