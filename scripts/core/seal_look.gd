class_name SealLook
extends RefCounted
## The look of the Chamber's seal over time (pure; docs/art/boss_chamber_spec.md section 6): which state it is in,
## how long it has been there and what that means for the seal's shader (BossChamber hands the values over each
## frame). Five states (normal, ritual's wind-up, ritual, the last phase, victory) and the short breaking of the ritual
## between the ritual and normal. Every light value is the greatest channel of the seal's emission, at most 1.0 (under
## the glow's threshold, Game.GLOW_THRESHOLD 1.3: nothing on the floor blooms).

enum State { NORMAL, PREP, RITUAL, BREAK, FINAL, VICTORY }
## The five states of the spec, by name (the labs' options and BossChamber.set_seal_state).
const NAMES := {&"normal": State.NORMAL, &"prep": State.PREP, &"ritual": State.RITUAL, &"final": State.FINAL, &"victory": State.VICTORY}

## Morvath's timing (the same numbers as Boss: VICTORY_TIME, VICTORY_STREAM, VICTORY_PORTAL, VICTORY_RITUAL,
## VICTORY_CALM, VICTORY_SEAL, PORTAL_PULSE_HZ; kept here so this stays pure, and tests/test_boss_chamber.gd checks they
## match).
const VICTORY_TIME := 3.6
const VICTORY_STREAM := Vector2(0.5, 2.3)
const VICTORY_PORTAL := 2.3
const VICTORY_RITUAL := 2.8
const VICTORY_CALM := 3.1
const VICTORY_SEAL := 2.4
const PORTAL_PULSE_HZ := 0.35
## The crack's core at rest, its pulse (amount, Hz), and the seconds it takes to grow to a new phase's length.
const CRACK_REST := 0.75
const CRACK_PULSE := Vector2(0.15, 0.33)
const CRACK_FULL := 1.0
const CRACK_GROW_TIME := 1.0
## The ritual's wind-up: one more of the eight points lights every this many seconds; the outer ring's light and the
## runes' over RAMP seconds; the rings' turning (degrees a second, outer and inner) reached over SPIN_RAMP.
const POINT_STEP := 0.12
const PREP_RAMP := 1.2
const PREP_RING := 0.6
const PREP_RUNES := 0.3
const SPIN_RAMP := 1.6
const PREP_SPIN := Vector2(8.0, -12.0)
## The ritual: rings and runes, the wave from the heart to the tips (Hz, amount), the stone under the shield darker.
const RITUAL_RING := 0.85
const RITUAL_RUNES := 0.6
const RITUAL_SPIN := Vector2(12.0, -18.0)
const WAVE := Vector2(0.7, 0.25)
const SHIELD_DARK := 0.2
## The ritual breaking: a flash of violet and gold (to FLASH, held FLASH_HOLD seconds, gone by BREAK_TIME), the rings
## stopping within SPIN_STOP, the warm rest left in the gold (amount, seconds).
const BREAK_TIME := 1.2
const FLASH := 1.0
const FLASH_HOLD := 0.15
const SPIN_STOP := 0.6
const RESIDUE := Vector2(0.1, 2.0)
## The last phase: the veins of corruption run out along the floor's joints to VEIN_REACH meters at VEIN_SPEED m/s, then
## pulse between VEIN_LIGHT.x and .y with the door (PORTAL_PULSE_HZ); the rings' light flickers between FLICKER.x
## and .y; the light layer trembles TREMOR degrees (noise at TREMOR_HZ).
const VEIN_REACH := 7.5
const VEIN_SPEED := 4.7
const VEIN_LIGHT := Vector2(0.45, 0.8)
const FLICKER := Vector2(0.2, 0.45)
const TREMOR := 3.0
const TREMOR_HZ := 2.0
## Victory (seconds from Morvath's last blow, Boss.VICTORY_*): the crack flares (to CRACK_FULL for FLARE seconds), the
## veins go back to the crack, the eight traces of old gold run down the points to the heart (CONVERGE seconds, light
## CONVERGE_LIGHT), the rings' last turn (degrees a second, slowing to 0 by VICTORY_CALM), the crack closes from
## its tips to the lion's heart (HEAL seconds), the lion's outline lights (LION_LIGHT for LION_TIME), and the seal
## rests with its gold faintly lit (CALM_GOLD).
const FLARE := 0.2
const CONVERGE := 0.5
const CONVERGE_LIGHT := 0.86
const LAST_TURN := 40.0
const HEAL := 0.4
## When the crack starts closing: as soon as the veins are back in it (VICTORY_STREAM.y), so it is shut for good well
## before the calm and the victory's words (O-2 of the C11 QA: closing only from VICTORY_RITUAL, with the last kill's
## slow motion on the seal's clock, a violet line still crossed the lion at victory + 3.3 s).
const HEAL_FROM := VICTORY_STREAM.y
const LION_LIGHT := 1.0
const LION_TIME := 0.4
const CALM_GOLD := 0.12
## At rest the inlaid gold keeps a faint light of its own (spec 3: the stroke between #6a5844 and #8e7444 on screen).
const REST_GOLD := 0.08
## Art pack 2026-11-17 (section 4): while Morvath winds up or throws an attack the crack's light and the veins of the
## last phase go down to HUSH of their light (eased in over HUSH_IN seconds and out over HUSH_OUT), so the seal never
## competes with his warnings and crescents; held HUSH_HOLD seconds past the wind-up (the blow and its flight).
## Never in the ritual's breaking nor the victory (their own light is the story there).
const HUSH := 0.45
const HUSH_IN := 0.15
const HUSH_OUT := 0.6
const HUSH_HOLD := 0.8

var state := State.NORMAL
## Seconds in the state.
var t := 0.0
## Morvath's phase (1 to 4): how long the crack is.
var phase := 1
## Which of the eight points (0 = the one pointing up the screen, then clockwise on the screen) lights first in the
## wind-up: the one pointing at Morvath.
var first_point := 0
## The rings' turn (radians; outer, inner): they only turn in the light layer, never the stone.
var turn := Vector2.ZERO
## How long the crack is drawn (0 to 4: up to each phase's length) and the length it grows to.
var crack_grow := 1.0
## How far the corruption has spread (0..1 of VEIN_REACH); -1: as the state wants it (set_corruption overrides it).
var corruption := -1.0
## The victory's length (seal_restore may stretch it), and the seconds over which time flows (the clock of pulses).
var victory_time := VICTORY_TIME
var clock := 0.0
var _spin := Vector2.ZERO
var _veins := 0.0
## Seconds the hush still holds (an attack under way), and how far it has eased in (0 none, 1 all of HUSH).
var _hush_left := 0.0
var hushed := 0.0


## An attack of Morvath starts (its wind-up `seconds` long): the crack and the veins go quiet until it has flown.
func hush_for(seconds: float) -> void:
	_hush_left = maxf(_hush_left, maxf(seconds, 0.0) + HUSH_HOLD)


## Enters a state, as if `at` seconds had passed in it already (the labs show the middle of a state).
func enter(s: State, at := 0.0) -> void:
	state = s
	t = 0.0
	if s == State.FINAL:
		phase = 4
	if s == State.VICTORY:
		phase = 4
		_veins = 1.0 if _veins <= 0.0 else _veins
		crack_grow = 4.0
	if s == State.NORMAL and phase >= 4:
		phase = 3
	if s == State.FINAL:
		_veins = 0.0
	step(at)


## The crack's length for a phase.
func set_phase(p: int) -> void:
	phase = clampi(p, 1, 4)


## Advances the clock by dt seconds.
func step(dt: float) -> void:
	var left := dt
	# in small steps, so the integrated turns and spreads do not depend on the frame rate
	while left > 0.0:
		var h := minf(left, 1.0 / 60.0)
		_advance(h)
		left -= h
	if dt <= 0.0:
		_advance(0.0)


func _advance(h: float) -> void:
	t += h
	clock += h
	_hush_left = maxf(0.0, _hush_left - h)
	var quiet := _hush_left > 0.0 and state != State.BREAK and state != State.VICTORY
	hushed = move_toward(hushed, 1.0 if quiet else 0.0, h / (HUSH_IN if quiet else HUSH_OUT))
	if state == State.BREAK and t >= BREAK_TIME:
		state = State.NORMAL
		t -= BREAK_TIME
	match state:
		State.PREP:
			_spin = _spin.move_toward(PREP_SPIN, PREP_SPIN.length() / SPIN_RAMP * h)
		State.RITUAL:
			_spin = _spin.move_toward(RITUAL_SPIN, RITUAL_SPIN.length() / SPIN_RAMP * h)
		State.VICTORY:
			_spin = Vector2(LAST_TURN, -LAST_TURN) * _last_turn_share()
		_:
			_spin = _spin.move_toward(Vector2.ZERO, RITUAL_SPIN.length() / SPIN_STOP * h)
	turn += Vector2(deg_to_rad(_spin.x), deg_to_rad(_spin.y)) * h
	# the crack grows to its phase over CRACK_GROW_TIME (heals only in the victory)
	crack_grow = move_toward(crack_grow, float(phase), h / CRACK_GROW_TIME) if crack_grow < phase else crack_grow
	if state == State.FINAL:
		_veins = minf(1.0, _veins + VEIN_SPEED / VEIN_REACH * h)
	elif state == State.VICTORY:
		var stream := (t - VICTORY_STREAM.x) / (VICTORY_STREAM.y - VICTORY_STREAM.x)
		_veins = 1.0 - clampf(stream, 0.0, 1.0) if t >= VICTORY_STREAM.x else _veins
	elif state != State.FINAL:
		_veins = 0.0


## The share of LAST_TURN the rings turn at in the victory: from the energy converging to the calm.
func _last_turn_share() -> float:
	var a := _victory(VICTORY_PORTAL)
	var b := _victory(VICTORY_CALM)
	if t < a or t > b:
		return 0.0
	return 1.0 - (t - a) / (b - a)


## A moment of the victory's timeline (Boss.VICTORY_*), stretched to victory_time.
func _victory(at: float) -> float:
	return at * victory_time / VICTORY_TIME


## How far the veins reach (m).
func veins() -> float:
	return (corruption if corruption >= 0.0 else _veins) * VEIN_REACH


## The values the seal's shader takes (BossChamber sets them as `seal_<key>`).
func values() -> Dictionary:
	var v := {
		&"gold_glow": REST_GOLD, &"ring_light": Vector2.ZERO, &"runes": 0.0, &"points": 0.0, &"first_point": float(first_point),
		&"point_light": 0.0, &"wave": 0.0, &"inside_dark": 0.0, &"crack_core": CRACK_REST, &"crack_grow": crack_grow,
		&"crack_heal": 0.0, &"scar": 0.0, &"spot": 1.0, &"veins": veins(), &"vein_light": 0.0, &"tremor": 0.0,
		&"converge": -1.0, &"lion_glow": 0.0, &"flash": 0.0, &"violet": 1.0, &"turn": turn, &"clock": clock,
		&"ring_mix": Vector2(0.0, 1.0), &"gold_eaten": 0.0,
	}
	var pulse := sin(TAU * CRACK_PULSE.y * clock)
	v[&"crack_core"] = CRACK_REST + CRACK_PULSE.x * pulse
	match state:
		State.PREP:
			var k := clampf(t / PREP_RAMP, 0.0, 1.0)
			v[&"points"] = minf(8.0, t / POINT_STEP)
			v[&"point_light"] = PREP_RING
			v[&"ring_light"] = Vector2(PREP_RING * k, PREP_RING * k * 0.6)
			v[&"runes"] = PREP_RUNES * k
			v[&"crack_core"] = lerpf(CRACK_REST, CRACK_FULL, k)
		State.RITUAL:
			v[&"points"] = 8.0
			v[&"point_light"] = RITUAL_RING
			v[&"ring_light"] = Vector2(RITUAL_RING, RITUAL_RING)
			v[&"runes"] = RITUAL_RUNES
			v[&"wave"] = WAVE.y
			v[&"inside_dark"] = SHIELD_DARK
			v[&"crack_core"] = CRACK_FULL
		State.BREAK:
			var f := FLASH if t < FLASH_HOLD else FLASH * (1.0 - clampf((t - FLASH_HOLD) / (BREAK_TIME - FLASH_HOLD), 0.0, 1.0))
			v[&"flash"] = f
			v[&"ring_light"] = Vector2(f, f)
			v[&"points"] = 8.0
			v[&"point_light"] = f
			v[&"gold_glow"] = RESIDUE.x * (1.0 - clampf(t / RESIDUE.y, 0.0, 1.0)) + f * 0.5
		State.FINAL:
			var beat := 0.5 + 0.5 * sin(TAU * PORTAL_PULSE_HZ * clock)
			v[&"vein_light"] = lerpf(VEIN_LIGHT.x, VEIN_LIGHT.y, beat) if _veins >= 1.0 else VEIN_LIGHT.y
			v[&"tremor"] = deg_to_rad(TREMOR) * (sin(TAU * TREMOR_HZ * clock) * 0.6 + sin(TAU * TREMOR_HZ * 1.7 * clock + 1.3) * 0.4)
			var flick := 0.5 + 0.5 * sin(TAU * TREMOR_HZ * 2.3 * clock) * sin(TAU * 0.9 * clock + 0.4)
			v[&"ring_light"] = Vector2.ONE * lerpf(FLICKER.x, FLICKER.y, flick)
			v[&"ring_mix"] = Vector2(0.0, 0.0)
			v[&"crack_core"] = CRACK_FULL
			v[&"gold_eaten"] = 1.0
		State.VICTORY:
			_victory_values(v)
	if state != State.VICTORY and corruption >= 0.0 and state != State.FINAL:
		v[&"vein_light"] = VEIN_LIGHT.x
	if hushed > 0.0 and state != State.VICTORY:
		var keep := lerpf(1.0, HUSH, hushed)
		v[&"crack_core"] = float(v[&"crack_core"]) * keep
		v[&"vein_light"] = float(v[&"vein_light"]) * keep
	return v


func _victory_values(v: Dictionary) -> void:
	var s := victory_time / VICTORY_TIME
	v[&"gold_eaten"] = 1.0 - clampf((t - _victory(VICTORY_STREAM.x)) / (_victory(VICTORY_STREAM.y) - _victory(VICTORY_STREAM.x)), 0.0, 1.0)
	# the veins stop pulsing and hold their light while they go back
	v[&"vein_light"] = VEIN_LIGHT.y
	v[&"crack_core"] = CRACK_FULL if t < FLARE * s else CRACK_REST
	var converge_at := _victory(VICTORY_PORTAL)
	if t >= converge_at and t < converge_at + CONVERGE * s * 2.0:
		v[&"converge"] = clampf((t - converge_at) / (CONVERGE * s), 0.0, 1.0)
		v[&"ring_light"] = Vector2.ONE * CONVERGE_LIGHT * (1.0 - clampf((t - converge_at - CONVERGE * s) / (CONVERGE * s), 0.0, 1.0))
		v[&"ring_mix"] = Vector2(-1.0, -1.0)
	var heal_at := _victory(HEAL_FROM)
	v[&"crack_heal"] = clampf((t - heal_at) / (HEAL * s), 0.0, 1.0)
	if t >= heal_at and t < heal_at + LION_TIME * s:
		v[&"lion_glow"] = LION_LIGHT * sin(PI * (t - heal_at) / (LION_TIME * s))
	var calm := _victory(VICTORY_CALM)
	var k := clampf((t - heal_at) / (calm - heal_at), 0.0, 1.0)
	v[&"gold_glow"] = CALM_GOLD * k
	v[&"scar"] = k
	v[&"spot"] = 1.0 - k
	v[&"violet"] = 1.0 - k
