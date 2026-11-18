class_name VisualProfile
extends RefCounted
## The visual profile (stylized art proof of concept, STY-03; docs/art/stylized_poc_plan.md 2.1 and
## docs/art/stylized_spec.md): CLASSIC (the game as it was) or STYLIZED (painted stone and light in the catacomb hall).
## Reversible and live: `--look=classic|stylized` picks it for a run (CLASSIC without it), the action `look_toggle`
## (F7, every build, so it can be compared in the exe) flips it while playing.
##
## What differs between the two is registered here, never branched on in the scenery's code: `vary(object, values)`
## records the object's own values of those properties as its classic ones and `values` as its stylized ones, and
## puts the ones of the look in use; `set_look` puts every registered object's values of the new look. Anything with
## properties takes it: a ShaderMaterial (its `shader`, a `shader_parameter/<name>`), a light, a node's `visible`, the
## world's Environment. So the classic look is the object exactly as it was built (the same shader, the same numbers:
## the frame does not change), and the stylized one is a list of numbers next to the piece it belongs to.
## Shaders that want to branch on the look read the global `art_style` (0 classic, 1 stylized; project.godot).
## Objects freed are dropped (only a weak reference is kept).

enum Look { CLASSIC, STYLIZED }

const NAMES: Array[String] = ["classic", "stylized"]
## The shader global every shader may read (0 or 1).
const GLOBAL := &"art_style"

## The world in the stylized look (stylized_spec.md 1.3, T1, T5, T7): a warm-neutral ambient strong enough that the
## middle of the floor reads light with no fire near (never a light washing a wall), the fog in the air down to 40%,
## the frame a little less saturated (the painting comes from value, not colour: the R1's p90 saturation is 15).
const AMBIENT := Color(0.78, 0.74, 0.68)
const AMBIENT_GAIN := 2.4
const FOG_IN_AIR := 0.4
const SATURATION := 0.88
## The key: one directional light from high behind the camera, a little to its right, with a sharp shadow
## (rotation in degrees: pitch, yaw; colour; energy; shadow blur).
const KEY_ROTATION := Vector3(-60.0, 52.0, 0.0)
const KEY_COLOR := Color(1.0, 0.94, 0.84)
const KEY_ENERGY := 0.55
const KEY_BLUR := 0.7

static var _look := -1
## [WeakRef, classic values, stylized values]
static var _entries: Array[Array] = []


## The look in use: set_look's, else the command line's (--look=classic|stylized), else CLASSIC.
static func current() -> Look:
	if _look < 0:
		_look = parse(Dev.arg("look", NAMES[Look.CLASSIC]))
	return _look as Look


static func stylized() -> bool:
	return current() == Look.STYLIZED


## A name (or its number) to a look; anything unknown is CLASSIC.
static func parse(name_: String) -> Look:
	var a := name_.strip_edges().to_lower()
	if a == NAMES[Look.STYLIZED] or a == "1" or a == "stylised" or a == "paint":
		return Look.STYLIZED
	return Look.CLASSIC


## Puts a look: the shader global and every registered object's values.
static func set_look(look: Look) -> void:
	_look = look
	RenderingServer.global_shader_parameter_set(GLOBAL, art_style())
	refresh()


## The value of the shader global for the look in use (0 classic, 1 stylized).
static func art_style() -> float:
	return 1.0 if stylized() else 0.0


## Flips between the two (the F7 key).
static func toggle() -> Look:
	set_look(Look.CLASSIC if stylized() else Look.STYLIZED)
	return current()


## Registers what an object takes in the stylized look (property: value). Its present values of those properties are
## its classic ones. Puts the look in use at once. Registering the same object again adds to (or replaces) its values.
static func vary(object: Object, values: Dictionary) -> void:
	if object == null or values.is_empty():
		return
	var e := _entry(object)
	if e.is_empty():
		e = [weakref(object), {}, {}]
		_entries.append(e)
	var classic: Dictionary = e[1]
	var styl: Dictionary = e[2]
	for k: StringName in values:
		# a property not registered yet still holds its classic value, whatever the look in use
		if not classic.has(k):
			classic[k] = object.get(k)
		styl[k] = values[k]
	_put(e, current())


## The stylized value registered for an object's property (or the fallback): for tests and for pieces that read it.
static func styled(object: Object, property: StringName, fallback: Variant = null) -> Variant:
	var e := _entry(object)
	return fallback if e.is_empty() else (e[2] as Dictionary).get(property, fallback)


## The classic value registered for an object's property (or the fallback).
static func classic_of(object: Object, property: StringName, fallback: Variant = null) -> Variant:
	var e := _entry(object)
	return fallback if e.is_empty() else (e[1] as Dictionary).get(property, fallback)


## Puts the look in use on every registered object again (a room rebuilt the world's air under it).
static func refresh() -> void:
	var look := current()
	var alive: Array[Array] = []
	for e in _entries:
		if (e[0] as WeakRef).get_ref() != null:
			alive.append(e)
			_put(e, look)
	_entries = alive


## How many objects are registered and alive (tests).
static func count() -> int:
	var n := 0
	for e in _entries:
		if (e[0] as WeakRef).get_ref() != null:
			n += 1
	return n


## Forgets an object: it gets its classic values back.
static func release(object: Object) -> void:
	var e := _entry(object)
	if e.is_empty():
		return
	_put(e, Look.CLASSIC)
	_entries.erase(e)


## The world: the Environment and the key light (Game._build_world). Their classic values are as built (with the
## browser's compensation, Game.COMPAT_*), the stylized ones a share of them where they scale.
static func dress_world(env: Environment, key: DirectionalLight3D) -> void:
	if env != null:
		vary(env, {
			&"ambient_light_color": AMBIENT,
			&"ambient_light_energy": env.ambient_light_energy * AMBIENT_GAIN,
			&"volumetric_fog_density": env.volumetric_fog_density * FOG_IN_AIR,
			&"adjustment_saturation": env.adjustment_saturation * SATURATION,
		})
	if key != null:
		vary(key, {
			&"rotation_degrees": KEY_ROTATION, &"light_color": KEY_COLOR, &"light_energy": KEY_ENERGY,
			&"shadow_blur": KEY_BLUR,
		})
	set_look(current())


static func _entry(object: Object) -> Array:
	for e in _entries:
		if (e[0] as WeakRef).get_ref() == object:
			return e
	return []


static func _put(e: Array, look: Look) -> void:
	var o: Object = (e[0] as WeakRef).get_ref()
	if o == null:
		return
	var values: Dictionary = e[2] if look == Look.STYLIZED else e[1]
	for k: StringName in values:
		o.set(k, values[k])
