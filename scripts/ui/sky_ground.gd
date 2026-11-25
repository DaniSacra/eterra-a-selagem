class_name SkyGround
extends Control
## The dark night sky behind the meta screens (SW-M1): a deep blue-black, a few soft colour clouds and a fixed scatter of
## twinkling stars (StarField). Full screen at any resolution (the stars sit on fractions of the window). `shift` (px) slides
## the stars by their depth, so the sky seems to follow a camera that moves. Drawn by code.
##   var sky := SkyGround.new().setup(5, [Color("3a2a6a")])
##   sky.shift = -cam.center * 0.1

const TOP := Color("05060f")
const BOTTOM := Color("0c0a1c")
const COUNT := 240
const CLOUDS := 3

var stars: Array[Dictionary] = []
var clouds: Array[Dictionary] = []
var shift := Vector2.ZERO
var _t := 0.0


## tints: the colours of the clouds (a screen's own mood); seed_value: which sky.
func setup(seed_value: int, tints: Array[Color]) -> SkyGround:
	name = "ground"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stars = StarField.make(seed_value, COUNT)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 77
	for i in CLOUDS:
		clouds.append({"p": Vector2(rng.randf_range(0.15, 0.85), rng.randf_range(0.2, 0.8)), "r": rng.randf_range(0.28, 0.45),
			"tint": tints[i % tints.size()] if not tints.is_empty() else Color("3a2a6a")})
	return self


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var s := size
	# the sky: darker at the top
	var steps := 12
	for i in steps:
		draw_rect(Rect2(0, s.y * i / steps, s.x, s.y / steps + 1.0), TOP.lerp(BOTTOM, float(i) / (steps - 1)))
	for cl: Dictionary in clouds:
		var c: Vector2 = (cl.p as Vector2) * s + shift * 0.3
		var r: float = float(cl.r) * s.y
		for k in 16:
			var f := 1.0 - float(k) / 16.0
			draw_circle(c, r * (0.15 + 0.85 * f), Color(cl.tint, 0.024))
	var k := s.y / 720.0
	for st: Dictionary in stars:
		var p: Vector2 = (st.p as Vector2) * s + shift * float(st.depth)
		p = Vector2(fposmod(p.x, s.x), fposmod(p.y, s.y))
		var tw := 0.62 + 0.38 * sin(_t * (0.8 + float(st.depth)) + float(st.phase))
		var col := Color(0.78, 0.84, 1.0).lerp(Color(1.0, 0.9, 0.7), float(st.warm))
		draw_circle(p, float(st.r) * k, Color(col, tw * (0.35 + 0.65 * float(st.depth))))
