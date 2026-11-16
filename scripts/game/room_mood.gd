class_name RoomMood
extends Node
## The air of a room turned toward a mood (cycle 10, ART-008: Morvath's last phase changed only the portal). Works in
## any scenery: it takes the world's Environment (the WorldEnvironment of the scene) and the scenery's own lights
## (the fires: every warm Light3D under `scenery`, but those in `keep`) as they were the first time it is asked, and blends them
## toward a mood (a Look) over a few seconds; back to 0 they are exactly as they were. The paladin, the crowd and the
## warnings keep their light: the moods change the air, the depths and the fires, never the exposure or the glow.
## Only drawn; nothing here touches the run. Arena makes one (Arena.mood); Arena.final_phase turns on LAST_BREATH.

## A mood: the colours and shares it turns the room toward at full weight.
class Look:
	## Ambient light colour and its energy (times the room's).
	var ambient := Color.WHITE
	var ambient_gain := 1.0
	## The background and the depth/height fog (what fills the abyss and the far halls).
	var sky := Color.BLACK
	var fog := Color.BLACK
	var fog_height_gain := 1.0
	## The directional light (the moon): colour and energy (times the room's).
	var key := Color.WHITE
	var key_gain := 1.0
	## The scenery's warm lights (fires, candles): energy (times theirs), and how far their colour goes to `chill`.
	var fires_gain := 1.0
	var chill := Color.WHITE
	var chill_share := 0.0
	## The deep lights (violet glows from below: blue well over green) times theirs.
	var deep_gain := 1.0
	## The grade of the whole picture (after the tone map): what each channel of the blacks is lifted (or lowered) by,
	## fading out by `shadow_reach` (0..1 of the value): the shadows take the mood's colour, the lights, the paladin
	## and the warnings keep theirs.
	var shadow_lift := Color(0, 0, 0)
	var shadow_reach := 0.6
	## The far air (the scenery's depths that follow room_air.gdshaderinc: the abyss's ruins and mist): the hue it
	## turns to and how far.
	var air := Color(0, 0, 0)
	var air_share := 0.0
	## A slow breath on the ambient and the fires (cycles a second, depth as a share): the air is alive.
	var breath_rate := 0.0
	var breath := 0.0

	func _init(d: Dictionary) -> void:
		for k in d:
			set(k, d[k])


## Morvath's last breath: the hall's teal air goes to a deep violet dusk, the abyss under it fills with violet fog,
## the moon turns to his cold spectral light and the fires gutter low and cold. The middle of the hall keeps its
## light (the paladin's own light, the crowd's painted light and the warnings are untouched).
static var LAST_BREATH := Look.new({
	"ambient": Color(0.36, 0.3, 0.52), "ambient_gain": 0.95,
	"sky": Color(0.1, 0.05, 0.2), "fog": Color(0.16, 0.07, 0.3), "fog_height_gain": 1.5,
	"key": Color(0.42, 0.85, 0.82), "key_gain": 1.8,
	"fires_gain": 0.6, "chill": Color(0.75, 0.6, 1.0), "chill_share": 0.45, "deep_gain": 1.5,
	"shadow_lift": Color(0.04, -0.02, 0.09), "shadow_reach": 0.6,
	"air": Color(0.5, 0.3, 1.0), "air_share": 0.8,
	"breath_rate": 0.25, "breath": 0.12,
})

## Seconds a mood takes to come or go, unless told.
const RAMP := 2.0
## A light is a fire (a mood guttering it) when its red passes its blue by this much: braziers and candles, not the
## cool key over the hall's middle nor a portal's.
const FIRE_FROM := 0.35
## A light is a deep glow (a mood raising it) when its blue passes its green by this much: the violet from the abyss.
const DEEP_FROM := 0.3
## Points of the grade's curve, and how much the weight must move before the curve is redrawn.
const GRADE_POINTS: Array[float] = [0.0, 0.08, 0.18, 0.3, 0.45, 0.6, 1.0]
const GRADE_STEP := 0.02

## Where the scenery's lights are looked for, and the lights that are not the room's to change (a portal's).
var scenery: Node
var keep: Array[Light3D] = []
var _env: Environment
var _key: DirectionalLight3D
var _base := {}
var _lights: Array[Light3D] = []
var _light_base: Array[Array] = []
## For each light: true when it is a fire (guttering), false when a deep glow (rising).
var _light_fire: Array[bool] = []
var _grade: GradientTexture1D
var _grade_w := -1.0
var _look: Look
var _weight := 0.0
var _want := 0.0
var _ramp := RAMP
var _clock := 0.0


## where: the scenery whose fires it turns; env: the environment to turn (by default the world's, read when first asked).
func _init(where: Node = null, env: Environment = null) -> void:
	scenery = where
	_env = env
	name = "RoomMood"


## Turn the room toward `look` (on) or back to how it was (off), over `seconds`.
func blend(look: Look, on: bool, seconds: float = RAMP) -> void:
	if on:
		_look = look
	_want = 1.0 if on else 0.0
	_ramp = maxf(seconds, 0.01)
	if on and _base.is_empty():
		_take()


## How far the room is turned toward its mood (0..1; tests).
func weight() -> float:
	return _weight


func _take() -> void:
	if _env == null:
		var world := get_viewport().find_world_3d() if is_inside_tree() else null
		_env = world.environment if world != null else null
	if _env == null:
		return
	_base = {
		"ambient": _env.ambient_light_color, "ambient_energy": _env.ambient_light_energy,
		"sky": _env.background_color, "fog": _env.fog_light_color, "fog_height": _env.fog_height_density,
	}
	for l in (get_tree().root.find_children("*", "DirectionalLight3D", true, false) if is_inside_tree() else []):
		_key = l as DirectionalLight3D
		_base["key"] = _key.light_color
		_base["key_energy"] = _key.light_energy
		break
	if scenery != null:
		for n in scenery.find_children("*", "Light3D", true, false):
			var c: Color = (n as Light3D).light_color
			var fire := c.r - c.b >= FIRE_FROM
			if n is DirectionalLight3D or keep.has(n) or not (fire or c.b - c.g >= DEEP_FROM):
				continue
			_lights.append(n)
			_light_base.append([(n as Light3D).light_color, (n as Light3D).light_energy])
			_light_fire.append(fire)
	_base["grade"] = _env.adjustment_color_correction
	_base["adjust"] = _env.adjustment_enabled


func _process(delta: float) -> void:
	if _env == null or _base.is_empty() or (_weight == 0.0 and _want == 0.0):
		return
	_clock += delta
	_weight = move_toward(_weight, _want, delta / _ramp)
	_apply(_weight)


## The room leaves (the next room, a new run): the world is left exactly as it was.
func _exit_tree() -> void:
	if _env != null and not _base.is_empty() and _weight > 0.0:
		_weight = 0.0
		_want = 0.0
		_apply(0.0)


func _apply(w: float) -> void:
	var lk := _look
	var b := 1.0 + lk.breath * w * sin(_clock * lk.breath_rate * TAU)
	_env.ambient_light_color = (_base.ambient as Color).lerp(lk.ambient, w)
	_env.ambient_light_energy = (_base.ambient_energy as float) * lerpf(1.0, lk.ambient_gain, w) * b
	_env.background_color = (_base.sky as Color).lerp(lk.sky, w)
	_env.fog_light_color = (_base.fog as Color).lerp(lk.fog, w)
	_env.fog_height_density = (_base.fog_height as float) * lerpf(1.0, lk.fog_height_gain, w)
	if is_instance_valid(_key):
		_key.light_color = (_base.key as Color).lerp(lk.key, w)
		_key.light_energy = (_base.key_energy as float) * lerpf(1.0, lk.key_gain, w)
	for i in _lights.size():
		var l := _lights[i]
		if not is_instance_valid(l):
			continue
		var was: Array = _light_base[i]
		if _light_fire[i]:
			l.light_color = (was[0] as Color).lerp(lk.chill, lk.chill_share * w)
			l.light_energy = (was[1] as float) * lerpf(1.0, lk.fires_gain, w) * lerpf(1.0, b, w)
		else:
			l.light_energy = (was[1] as float) * lerpf(1.0, lk.deep_gain, w)
	_apply_grade(w)
	RenderingServer.global_shader_parameter_set(&"room_air", Vector4(lk.air.r, lk.air.g, lk.air.b, lk.air_share * w))


## The shadows' grade: a curve per channel (a 1D LUT), redrawn only when the weight moved GRADE_STEP; none at 0.
func _apply_grade(w: float) -> void:
	if w <= 0.0:
		_env.adjustment_color_correction = _base.grade
		_env.adjustment_enabled = _base.adjust
		_grade_w = -1.0
		return
	if absf(w - _grade_w) < GRADE_STEP and w < 1.0:
		return
	_grade_w = w
	if _grade == null:
		_grade = GradientTexture1D.new()
		_grade.width = 256
		_grade.gradient = Gradient.new()
	var g := _grade.gradient
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for x in GRADE_POINTS:
		var k := maxf(0.0, 1.0 - x / maxf(_look.shadow_reach, 0.01))
		var lift := _look.shadow_lift * (k * k * w)
		offs.append(x)
		cols.append(Color(clampf(x + lift.r, 0.0, 1.0), clampf(x + lift.g, 0.0, 1.0), clampf(x + lift.b, 0.0, 1.0)))
	g.offsets = offs
	g.colors = cols
	_env.adjustment_enabled = true
	_env.adjustment_color_correction = _grade
