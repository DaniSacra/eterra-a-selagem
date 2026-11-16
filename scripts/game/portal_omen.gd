class_name PortalOmen
extends Node3D
## Morvath's hold on the hall's portal (cycle 9), made by Arena when first asked (Arena.final_phase, seal_portal).
## Last phase: the portal grows restless (faster veils, a slow violet pulse: ArenaKit.portal_mood), its light rises
## and wavers a little, and a few spectral motes drift high in the air, never near the paladin. Sealing: his energy
## gathers from where he fell back into the portal, a ring of light closes on its core, and it calms to its own green
## and dims (sealed). Only drawn; nothing here touches the run.

## Seconds the unrest takes to come or go.
const RAMP := 1.5
## The portal's light (and the light it spills down the steps) in the last phase, times its open light, and how much
## it wavers (a share, slow).
const FINAL_GAIN := 1.4
const WAVER := 0.1
const WAVER_RATE := 1.7
## Motes in the air of the last phase: violet and green counts, the box they drift in (m, over the hall's middle) and
## its foot over the floor, their size and light.
const AIR_MOTES := Vector2i(16, 12)
const AIR_BOX := Vector3(34.0, 6.0, 32.0)
const AIR_FOOT := 3.0
const AIR_SIZE := 0.16
const AIR_LIGHT := 1.1
const VIOLET := Color(0.45, 0.18, 0.95)
const GREEN := Color(0.32, 0.95, 0.62)
## The air's green motes are his corrupted emerald (cycle 10, ART-006), not the portal's own green of the sealing.
const AIR_GREEN := BossShield.COLOR
## The sealing: its seconds unless told, the motes that gather (count, size, light, how far around where he fell they
## start, m), the share of the time they take to arrive, when the ring closes (shares of the time), the light at the
## moment the portal takes the energy in (times its open light), and the light it is left with (closed).
const SEAL_TIME := 2.4
const SEAL_MOTES := 48
const SEAL_SIZE := 0.22
const SEAL_LIGHT := 1.3
const SEAL_SPREAD := 2.5
const SEAL_TRAVEL := 0.6
const SEAL_RING := Vector2(0.4, 0.9)
const SEAL_PEAK := 1.25

var kit: ArenaKit
## Which of the kit's portals is the crypt's.
var index := 0
var _unrest := 0.0
var _want := 0.0
var _air: Array[SpectralMotes] = []
var _gather: SpectralMotes
var _seal_t := -1.0
var _seal_time := SEAL_TIME
var _seal_from := Color.WHITE
var _clock := 0.0


func _init(k: ArenaKit, i: int = 0) -> void:
	kit = k
	index = i
	name = "PortalOmen"


## The last phase begins (on) or is over (off: it calms over RAMP seconds).
func final(on: bool) -> void:
	_want = 1.0 if on else 0.0
	if on and _air.is_empty():
		for k in 2:
			var m := SpectralMotes.make(SpectralMotes.Mode.DRIFT, AIR_MOTES[k], VIOLET if k == 0 else AIR_GREEN, AIR_SIZE, AIR_LIGHT, 21 + k)
			m.set_param(&"box_size", AIR_BOX)
			m.position = Vector3(0, AIR_FOOT, 0)
			add_child(m)
			_air.append(m)


## Morvath is sealed: over `seconds` his energy gathers from `from` (x, z) into the portal and it closes.
func seal(seconds: float, from: Vector2) -> void:
	_want = 0.0
	_seal_t = 0.0
	_seal_time = maxf(seconds, 0.1)
	_seal_from = kit.portal_tints.get(index, ArenaKit.PORTAL)
	if _gather == null:
		_gather = SpectralMotes.make(SpectralMotes.Mode.GATHER, SEAL_MOTES, GREEN, SEAL_SIZE, SEAL_LIGHT, 33)
		add_child(_gather)
	_gather.visible = true
	_gather.set_param(&"from", Vector3(from.x, 0.0, from.y))
	_gather.set_param(&"from_spread", SEAL_SPREAD)
	_gather.set_param(&"to", kit.portal_centers[index] if index < kit.portal_centers.size() else Vector3.ZERO)
	_gather.set_param(&"travel", 0.0)


## True while the portal is restless or being sealed (tests).
func busy() -> bool:
	return _unrest > 0.0 or _want > 0.0 or _seal_t >= 0.0


func _process(delta: float) -> void:
	_clock += delta
	var was := _unrest
	_unrest = move_toward(_unrest, _want, delta / RAMP)
	for m in _air:
		m.set_param(&"power", _unrest)
		m.visible = _unrest > 0.0
	if _seal_t >= 0.0:
		_step_seal(delta)
		return
	if _unrest <= 0.0 and was <= 0.0:
		return
	var waver := 1.0 + WAVER * sin(_clock * WAVER_RATE * TAU) * sin(_clock * WAVER_RATE * 2.3)
	kit.portal_mood(index, _unrest, 0.0, lerpf(1.0, FINAL_GAIN, _unrest) * lerpf(1.0, waver, _unrest))
	if _unrest <= 0.0:
		kit.portal_mood(index, 0.0, 0.0, -1.0)


func _step_seal(delta: float) -> void:
	_seal_t += delta
	var s := clampf(_seal_t / _seal_time, 0.0, 1.0)
	_gather.set_param(&"travel", clampf(s / SEAL_TRAVEL, 0.0, 1.0))
	var ring := clampf((s - SEAL_RING.x) / (SEAL_RING.y - SEAL_RING.x), 0.0, 1.0)
	# his colour gives way to the portal's own green as the energy comes home
	var green := smoothstep(0.25, SEAL_RING.y, s)
	kit.light_portal(index, true, _seal_from.lerp(ArenaKit.PORTAL, green) if green < 1.0 else ArenaKit.PORTAL)
	# the light rises as it takes the energy in, then settles down to the closed portal's
	var closed := ArenaKit.PORTAL_LIGHT_DIM / ArenaKit.PORTAL_LIGHT
	var gain := lerpf(1.0, SEAL_PEAK, sin(ring * PI)) if ring < 0.5 else lerpf(closed, SEAL_PEAK, sin(ring * PI))
	kit.portal_mood(index, _unrest * (1.0 - s), ring, gain)
	if s >= 1.0:
		_seal_t = -1.0
		_unrest = 0.0
		_gather.visible = false
		kit.light_portal(index, false, ArenaKit.PORTAL)
		kit.portal_mood(index, 0.0, 0.0, -1.0)
