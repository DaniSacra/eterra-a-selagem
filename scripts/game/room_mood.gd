class_name RoomMood
extends Node
## The one owner of the world's air (DT-RS1). Every value of the Environment and of the moon that the scenery changes
## is written here only, as three layers put together for the visual profile in use (VisualProfile.current):
##   the world's air, per look (set_world: WorldAir's numbers, the stylized ones from VisualProfile.world_values),
##   the room's air, per look (dress_room / undress_room: ArenaRoom.air() and its style's air, the Chamber of the
##     Seal's), only the room that dressed it last takes it off,
##   the mood a boss turns it toward (blend, cycle 10, ART-008: Morvath's last breath), over a few seconds; back to 0
##     the room's air is exactly as it was.
## The look flipped (F7, the options screen) puts the layers of the new look at once (apply on the next frame, or
## Arena.restyle now). Before, four places wrote the Environment (VisualProfile.dress_world, ArenaRoom's air,
## BossChamber's, this mood) and each kept its own copy of "how it was": a room or a look changed in the wrong order
## gave the wrong air back (the STY-10 bug).
## The mood turns the scenery's fires too (every warm Light3D under `scenery`, but those in `keep`), read when it
## starts. The paladin, the crowd and the warnings keep their light: the moods change the air, the depths and the
## fires, never the exposure or the glow. Only drawn; nothing here touches the run.
## WorldAir makes the owner (own) as a child of its WorldEnvironment; RoomMood.of(node) finds it (or makes one for a
## lab or test world without WorldAir, its present values the world's in both looks). Arena.mood() hands it the
## room's scenery. A RoomMood made alone (RoomMood.new(scenery, env), the tests) reads its env as the world's air
## each time it starts from rest.

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
## C18 (one tone for the scenery): still violet, but under 0.45 of saturation (the frame was a third saturated violet).
static var LAST_BREATH := Look.new({
	"ambient": Color(0.36, 0.32, 0.46), "ambient_gain": 0.95,
	"sky": Color(0.1, 0.075, 0.15), "fog": Color(0.16, 0.115, 0.23), "fog_height_gain": 1.5,
	"key": Color(0.5, 0.8, 0.78), "key_gain": 1.8,
	"fires_gain": 0.6, "chill": Color(0.78, 0.7, 0.95), "chill_share": 0.45, "deep_gain": 1.0,
	"shadow_lift": Color(0.03, 0.01, 0.05), "shadow_reach": 0.6,
	"air": Color(0.56, 0.48, 0.8), "air_share": 0.4,
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
## The world's values the layers may change: the Environment's, and the moon's under MOON (keys "moon/<property>").
const ENV_KEYS: Array[StringName] = [&"background_mode", &"background_color", &"ambient_light_source",
	&"ambient_light_color", &"ambient_light_energy", &"fog_enabled", &"fog_mode", &"fog_light_color", &"fog_depth_begin",
	&"fog_depth_end", &"fog_height_density", &"volumetric_fog_density", &"adjustment_saturation", &"adjustment_enabled",
	&"adjustment_color_correction"]
const MOON := "moon/"
const MOON_KEYS: Array[StringName] = [&"rotation_degrees", &"light_color", &"light_energy", &"shadow_enabled", &"shadow_blur"]
## A room's air may give the ambient as a share of the world's classic energy (ArenaRoom.air's ambient_gain).
const AMBIENT_GAIN := &"ambient_gain"
## The node name of the owner under its WorldEnvironment.
const OWNER := "RoomMood"

## Where the scenery's lights are looked for, and the lights that are not the room's to change (a portal's).
var scenery: Node
var keep: Array[Light3D] = []
var _env: Environment
var _key: DirectionalLight3D
## The world's air by look (VisualProfile.Look: values), and whether it was given (set_world) or is read from the env.
var _world: Array[Dictionary] = [{}, {}]
var _own_world := false
## The room's air by look, and the room that dressed it (only it takes it off).
var _room: Array[Dictionary] = [{}, {}]
var _room_by: WeakRef
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
## The fires (and, alone, the world's air) are read on the next frame, not when asked: a room dresses its lights in the
## frame it is built, the chamber its air a frame late (STY-10).
var _take_due := false
## The look last put on the world (-1: nothing put yet).
var _put_look := -1


## where: the scenery whose fires it turns; env: the environment to turn (by default the world's, read when first asked).
func _init(where: Node = null, env: Environment = null) -> void:
	scenery = where
	_env = env
	name = OWNER


## Makes the owner of a world's air under its WorldEnvironment (WorldAir.build; labs): the env's values now are the
## world's classic air, VisualProfile.world_values its stylized one, and the look in use goes on them at once.
static func own(we: WorldEnvironment, moon: DirectionalLight3D) -> RoomMood:
	var m := RoomMood.new(null, we.environment)
	m._key = moon
	var classic := read(we.environment, moon)
	var compat := RenderingServer.get_current_rendering_method() == "gl_compatibility"
	m.set_world(classic, VisualProfile.world_values(classic, compat))
	we.add_child(m)
	return m


## The owner of the air of the world `node` stands in: the one under its WorldEnvironment, or a new one (a lab or a
## test world without WorldAir: what the air is now is its world in both looks; never when `make` is false). Null
## outside a tree or without one.
static func of(node: Node, make := true) -> RoomMood:
	if node == null or not node.is_inside_tree():
		return null
	# the nearest WorldEnvironment up the tree (the run's and the hub's are siblings of their arena), else the world's
	var found: WorldEnvironment = null
	var up := node.get_parent()
	while up != null and found == null:
		for c in up.get_children():
			if c is WorldEnvironment and (c as WorldEnvironment).environment != null:
				found = c
				break
		up = up.get_parent()
	if found == null:
		var env: Environment = node.get_world_3d().environment if node.get_world_3d() != null else null
		for n in node.get_tree().root.find_children("*", "WorldEnvironment", true, false):
			var we := n as WorldEnvironment
			if we.environment != null and (env == null or we.environment == env):
				found = we
				break
	if found == null:
		return null
	var m := found.get_node_or_null(OWNER) as RoomMood
	if m != null or not make:
		return m
	var moon: DirectionalLight3D = null
	for n in node.get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		moon = n as DirectionalLight3D
	m = RoomMood.new(null, found.environment)
	m._key = moon
	var now := read(found.environment, moon)
	m.set_world(now, now.duplicate())
	found.add_child(m)
	return m


## The values of the air an env and moon hold now (ENV_KEYS, and MOON_KEYS under MOON).
static func read(e: Environment, moon: DirectionalLight3D) -> Dictionary:
	var d := {}
	for k in ENV_KEYS:
		d[k] = e.get(k)
	if moon != null:
		for k in MOON_KEYS:
			d[StringName(MOON + String(k))] = moon.get(k)
	return d


## Writes values of the air on an env and moon (keys as read gives them; the moon's skipped without one).
static func write(e: Environment, moon: DirectionalLight3D, values: Dictionary) -> void:
	for k: StringName in values:
		var name_ := String(k)
		if name_.begins_with(MOON):
			if moon != null and is_instance_valid(moon):
				moon.set(StringName(name_.substr(MOON.length())), values[k])
		elif k != AMBIENT_GAIN:
			e.set(k, values[k])


## An arena's air (ArenaRoom.air(): sky, fog, fog_depth, ambient, ambient_gain, moon, moon_energy, moon_shadow) as
## values of the air; empty when it has none. Its ambient is a share of the world's classic energy (ambient_gain, 1
## when not given), as the rooms always had it.
static func air_values(want: Dictionary) -> Dictionary:
	if want.is_empty():
		return {}
	var d := {&"background_mode": Environment.BG_COLOR, AMBIENT_GAIN: float(want.get(&"ambient_gain", 1.0))}
	var names := {&"sky": &"background_color", &"fog": &"fog_light_color", &"ambient": &"ambient_light_color",
		&"moon": &"moon/light_color", &"moon_energy": &"moon/light_energy", &"moon_shadow": &"moon/shadow_enabled"}
	for k: StringName in names:
		if want.has(k):
			d[names[k]] = want[k]
	if want.has(&"fog_depth"):
		var fd: Vector2 = want[&"fog_depth"]
		d[&"fog_depth_begin"] = fd.x
		d[&"fog_depth_end"] = fd.y
	return d


## The world's air for each look (WorldAir; values as read gives them).
func set_world(classic: Dictionary, stylized: Dictionary) -> void:
	_world = [classic.duplicate(), stylized.duplicate()]
	_own_world = true
	apply()


## A room's air for each look (values as read or air_values give them): it replaces the one before, at once.
func dress_room(by: Object, classic: Dictionary, stylized: Dictionary) -> void:
	_room = [classic.duplicate(), stylized.duplicate()]
	_room_by = weakref(by)
	apply()


## The room's air off (the world's back), when `by` dressed it last (or any room's, by null: a new room is built).
func undress_room(by: Object = null) -> void:
	if by != null and (_room_by == null or _room_by.get_ref() != by):
		return
	_room = [{}, {}]
	_room_by = null
	apply()


## The room the air is dressed for (null: the world's own).
func dresser() -> Object:
	return _room_by.get_ref() if _room_by != null else null


## The world's air and the room's together, for a look (no mood).
func composed(look: int = VisualProfile.current()) -> Dictionary:
	var v: Dictionary = (_world[look] as Dictionary).duplicate()
	var room: Dictionary = _room[look]
	for k: StringName in room:
		if k != AMBIENT_GAIN:
			v[k] = room[k]
	if room.has(AMBIENT_GAIN):
		var base: float = (_world[VisualProfile.Look.CLASSIC] as Dictionary).get(&"ambient_light_energy", 1.0)
		v[&"ambient_light_energy"] = base * float(room[AMBIENT_GAIN])
	return v


## Turn the room toward `look` (on) or back to how it was (off), over `seconds`.
func blend(look: Look, on: bool, seconds: float = RAMP) -> void:
	if on:
		_look = look
	_want = 1.0 if on else 0.0
	_ramp = maxf(seconds, 0.01)
	# from rest the fires (and alone, the world's air) are read again (they may have been dressed since), next frame
	if on and _weight == 0.0:
		_take_due = true


## How far the room is turned toward its mood (0..1; tests).
func weight() -> float:
	return _weight


## The scenery `where` leaves (its arena is freed): its mood ends at once and its fires are let go.
func leave(where: Node) -> void:
	if where != scenery:
		return
	if _weight > 0.0:
		_weight = 0.0
		_want = 0.0
		apply()
	scenery = null
	keep.clear()
	_lights.clear()
	_light_base.clear()
	_light_fire.clear()


func _take() -> void:
	_lights.clear()
	_light_base.clear()
	_light_fire.clear()
	if _env == null:
		var world := get_viewport().find_world_3d() if is_inside_tree() else null
		_env = world.environment if world != null else null
	if _env == null:
		return
	if not _own_world:
		if _key == null and is_inside_tree():
			for l in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
				_key = l as DirectionalLight3D
				break
		var now := read(_env, _key)
		_world = [now, now.duplicate()]
	if scenery != null:
		for n in scenery.find_children("*", "Light3D", true, false):
			var c: Color = (n as Light3D).light_color
			var fire := c.r - c.b >= FIRE_FROM
			if n is DirectionalLight3D or keep.has(n) or not (fire or c.b - c.g >= DEEP_FROM):
				continue
			_lights.append(n)
			_light_base.append([(n as Light3D).light_color, (n as Light3D).light_energy])
			_light_fire.append(fire)


func _process(delta: float) -> void:
	if _take_due:
		_take_due = false
		_take()
	var turning := _weight > 0.0 or _want > 0.0
	if turning:
		_clock += delta
		_weight = move_toward(_weight, _want, delta / _ramp)
	if turning or (_own_world and _put_look != VisualProfile.current()):
		apply()


## The room leaves (the next room, a new run): the world is left exactly as it was.
func _exit_tree() -> void:
	if _env != null and not (_world[0] as Dictionary).is_empty() and _weight > 0.0:
		_weight = 0.0
		_want = 0.0
		apply()


## Puts the air on the world: the world's and the room's for the look in use, the mood over them.
func apply() -> void:
	if _env == null or (_world[0] as Dictionary).is_empty():
		return
	var look := VisualProfile.current()
	if look != _put_look and _put_look >= 0:
		_relight_fires(look)
	_put_look = look
	var v := composed(look)
	if _weight > 0.0 and _look != null:
		_turn(v, _weight)
	write(_env, _key, v)
	if _look != null:
		_turn_fires(_weight)
		RenderingServer.global_shader_parameter_set(&"room_air", Vector4(_look.air.r, _look.air.g, _look.air.b, _look.air_share * _weight))


## The mood over the air's values, at weight w.
func _turn(v: Dictionary, w: float) -> void:
	var lk := _look
	var b := 1.0 + lk.breath * w * sin(_clock * lk.breath_rate * TAU)
	v[&"ambient_light_color"] = (v[&"ambient_light_color"] as Color).lerp(lk.ambient, w)
	v[&"ambient_light_energy"] = float(v[&"ambient_light_energy"]) * lerpf(1.0, lk.ambient_gain, w) * b
	v[&"background_color"] = (v[&"background_color"] as Color).lerp(lk.sky, w)
	v[&"fog_light_color"] = (v[&"fog_light_color"] as Color).lerp(lk.fog, w)
	v[&"fog_height_density"] = float(v[&"fog_height_density"]) * lerpf(1.0, lk.fog_height_gain, w)
	if v.has(&"moon/light_color"):
		v[&"moon/light_color"] = (v[&"moon/light_color"] as Color).lerp(lk.key, w)
		v[&"moon/light_energy"] = float(v[&"moon/light_energy"]) * lerpf(1.0, lk.key_gain, w)
	_grade_values(v, w)


func _turn_fires(w: float) -> void:
	var lk := _look
	var b := 1.0 + lk.breath * w * sin(_clock * lk.breath_rate * TAU)
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


## The look changed under the mood: the fires' own values are the new look's (the profile's registered ones), so the
## mood turns those and not the look's of before.
func _relight_fires(look: int) -> void:
	for i in _lights.size():
		var l := _lights[i]
		if not is_instance_valid(l):
			continue
		var was: Array = _light_base[i]
		for j in 2:
			var prop: StringName = [&"light_color", &"light_energy"][j]
			var v: Variant = VisualProfile.styled(l, prop) if look == VisualProfile.Look.STYLIZED else VisualProfile.classic_of(l, prop)
			if v != null:
				was[j] = v


## The shadows' grade: a curve per channel (a 1D LUT), redrawn only when the weight moved GRADE_STEP; none at 0.
func _grade_values(v: Dictionary, w: float) -> void:
	if w <= 0.0:
		_grade_w = -1.0
		return
	if absf(w - _grade_w) >= GRADE_STEP or w >= 1.0 or _grade == null:
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
	v[&"adjustment_enabled"] = true
	v[&"adjustment_color_correction"] = _grade
