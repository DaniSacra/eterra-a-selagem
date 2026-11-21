class_name Warmup
extends Node3D
## Shader warm-up (P1-1 of docs/qa/latest_report.md, DT-RS3): the first entry of each room froze 0.5 to 17.6 s on the
## iGPU while its shaders compiled. At the start (behind the title, or a black screen when the game goes straight to a
## run) this draws one frame of every material in the warm-up set (assets/warmup/warmup_set.res, harvested by
## tools/make_warmup.sh from real runs: every arena, both looks, both renderers), each on a tiny quad in front of its own
## camera, lit by a sun, a lamp and a spot that cast shadows and under an environment like the run's (glow, fog,
## SSAO/SSR by the quality), so the shadow, depth and colour passes are all compiled; and the multimesh ones on a
## multimesh. When done, emits `done` and frees itself (the shader cache keeps the rest for the next start).
##   var w := Warmup.start(self)   # null when nothing to do
##   if w: await w.done

signal done

const SET := "res://assets/warmup/warmup_set.res"
## Materials drawn per frame: compiling is the cost, not drawing; a few frames keep the title breathing.
const PER_FRAME := 40
## The quads: this small, this far, in a grid filling the camera.
const SIZE := 0.05
const DEPTH := 2.0
const GRID := 12

var _items: Array = []
var _at := 0
var _shown: Array[Node] = []
var _quad: QuadMesh
var _multi_mesh: QuadMesh
var _cover: CanvasLayer
var _camera: Camera3D
var _env: WorldEnvironment
var _settle := 0
var started_ms := 0


## Whether there is anything to warm: a screen, the set, and not switched off (--no-warmup).
static func wanted() -> bool:
	return DisplayServer.get_name() != "headless" and not Dev.has("no-warmup") and ResourceLoader.exists(SET)


## Adds a warm-up under `parent` (a scene's root). `cover`: a black screen over the 3D (when no title art hides it).
static func start(parent: Node, cover: bool = false) -> Warmup:
	if not wanted():
		return null
	var w := Warmup.new()
	w.name = &"Warmup"
	w._cover_screen = cover
	parent.add_child(w)
	return w


var _cover_screen := false


func _ready() -> void:
	started_ms = Time.get_ticks_msec()
	_items = (load(SET) as Resource).get_meta(&"items", [])
	_quad = QuadMesh.new()
	_quad.size = Vector2.ONE * SIZE
	_multi_mesh = _quad
	_camera = Camera3D.new()
	_camera.fov = 40.0
	_camera.near = 0.05
	_camera.far = 10.0
	add_child(_camera)
	_camera.make_current()
	_lights()
	_env = WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color.BLACK
	e.glow_enabled = true
	e.fog_enabled = true
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	GraphicsQuality.apply_environment(e, GraphicsQuality.current(int(Save.option("quality"))))
	_env.environment = e
	add_child(_env)
	# a black screen over the 3D: over everything when no title is shown, under the title's art when it is
	_cover = CanvasLayer.new()
	_cover.layer = 100 if _cover_screen else -1
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.add_child(black)
	add_child(_cover)


func _lights() -> void:
	var sun := DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-50, 30, 0)
	add_child(sun)
	var lamp := OmniLight3D.new()
	lamp.shadow_enabled = true
	lamp.omni_range = 4.0
	lamp.position = Vector3(0.3, 0.3, -DEPTH + 0.6)
	add_child(lamp)
	var spot := SpotLight3D.new()
	spot.shadow_enabled = true
	spot.spot_range = 4.0
	spot.position = Vector3(-0.3, 0.2, -DEPTH + 1.0)
	add_child(spot)


func _process(_delta: float) -> void:
	for n in _shown:
		n.queue_free()
	_shown.clear()
	if _at >= _items.size():
		# two more frames: the last batch drawn, then gone
		_settle += 1
		if _settle >= 2:
			print("WARMUP %d materials in %d ms" % [_items.size(), Time.get_ticks_msec() - started_ms])
			done.emit()
			queue_free()
		return
	var end := mini(_at + PER_FRAME, _items.size())
	for i in range(_at, end):
		var node := _make(_items[i], i - _at)
		if node != null:
			add_child(node)
			_shown.append(node)
	_at = end


## Where the k-th quad of a batch sits: a grid filling the middle of the camera, in front of the lights.
func _spot(k: int) -> Vector3:
	var step := SIZE * 1.1
	var x := (k % GRID - GRID * 0.5) * step
	var y := (k / GRID - 2) * step
	return Vector3(x, y, -DEPTH)


func _make(item: Array, k: int) -> Node:
	var kind: String = item[0]
	var res: Resource = item[2]
	match kind:
		"mesh":
			var mi := MeshInstance3D.new()
			mi.mesh = _quad
			mi.material_override = res as Material
			mi.position = _spot(k)
			return mi
		"multi":
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.use_colors = true
			mm.use_custom_data = true
			mm.mesh = _multi_mesh
			mm.instance_count = 1
			mm.set_instance_transform(0, Transform3D.IDENTITY)
			var mmi := MultiMeshInstance3D.new()
			mmi.multimesh = mm
			mmi.material_override = res as Material
			mmi.position = _spot(k)
			return mmi
		"canvas":
			# under the cover and the title art: drawn, never seen
			var layer := CanvasLayer.new()
			layer.layer = -100
			var rect := ColorRect.new()
			rect.size = Vector2(2, 2)
			rect.material = res as Material
			layer.add_child(rect)
			return layer
		"fog":
			var fog := FogVolume.new()
			fog.size = Vector3.ONE * 0.2
			fog.material = res as Material
			fog.position = _spot(k)
			return fog
		"label":
			var label := Label3D.new()
			label.text = "a"
			label.pixel_size = 0.001
			_flags(label, res)
			label.position = _spot(k)
			return label
		"sprite":
			var sprite := Sprite3D.new()
			sprite.texture = _stand_in()
			sprite.pixel_size = 0.01
			_flags(sprite, res)
			sprite.position = _spot(k)
			return sprite
	return null


func _flags(n: Node, res: Resource) -> void:
	var flags: Dictionary = res.get_meta(&"flags", {})
	for p: String in flags:
		n.set(p, flags[p])


var _stand: ImageTexture


func _stand_in() -> ImageTexture:
	if _stand == null:
		var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_stand = ImageTexture.create_from_image(img)
	return _stand
