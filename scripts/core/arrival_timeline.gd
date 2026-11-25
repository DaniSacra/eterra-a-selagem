class_name ArrivalTimeline
extends RefCounted
## The arrival scene's clock (SW-O1, docs/design/onboarding_sw_o.md): what is on the screen at second t of the Guerreiro's
## first descent: black, a star, the light of Elun coming down, the seal opening, Emeth's crystals rising, sparks running
## to the light, the Guerreiro forming in it, then the light going out and the hero walking. Pure numbers, no nodes:
## ArrivalScene reads state_at(t) every frame and dresses it; tests/test_arrival.gd reads it with no screen.
##   var s := ArrivalTimeline.state_at(3.7)   # s.hero_visible, s.hero_form, s.beam, s.control ...

## The moments (s). The hero may walk from T_CONTROL; the scene is over at T_END.
const T_STAR := 0.6
const STAR_FADE := 0.4
const T_OPEN := 1.6
const OPEN_TIME := 0.8
const T_RING := 2.4
const RING_TIME := 0.6
const T_CRYSTALS := 2.4
const CRYSTAL_TIME := 0.6
const T_MOTES := 3.0
const MOTES_TIME := 0.5
const T_HERO := 3.6
const FORM_TIME := 0.4
const T_CONTROL := 4.0
const BEAM_OFF_TIME := 0.8
const LIGHT_UP_TIME := 1.0
const T_CAPTION := 4.2
const T_END := 5.0
## A press before this does not skip; after it, the scene jumps to T_CONTROL.
const SKIP_FROM := 1.0
## The room's light while the scene runs (a share of it) and the crystals' glow once they are scenery.
const DIM := 0.25
const CRYSTAL_LOW := 0.4


## Everything on the screen at second t (a Dictionary, all numbers 0..1 unless said):
##   black: the cover's alpha; star: its light; star_move: how far it has come down to the birth spot;
##   dim: the room's light share (DIM to 1); beam: the light of Elun (0 before T_OPEN, up to 1, down after T_CONTROL);
##   beam_on / beam_off: it should be lit / be taken now (bools); ring: the seal's opening (and fading with the beam);
##   crystals: how risen they are; crystal_glow: their light (1 while the beam stands, CRYSTAL_LOW after);
##   motes_on: sparks running (bool), motes: their travel 0..1; hero_visible (bool), hero_form: how much of the hero is
##   formed (bottom up), hero_flash: the one glow held in the beam (a bump over the forming);
##   control: the player may move (bool); caption: the line may show (bool); done: nothing left to dress (bool).
static func state_at(t: float) -> Dictionary:
	var open := _ramp(t, T_OPEN, OPEN_TIME)
	var beam_down := _ramp(t, T_CONTROL, BEAM_OFF_TIME)
	var form := _ramp(t, T_HERO, FORM_TIME)
	var light_up := _ramp(t, T_CONTROL, LIGHT_UP_TIME)
	var star_in := _ramp(t, T_STAR, STAR_FADE)
	return {
		&"black": 1.0 - _ease(open),
		&"star": star_in * (1.0 - open),
		&"star_move": _ease(open),
		&"dim": lerpf(DIM, 1.0, _ease(light_up)),
		&"beam": (1.0 if t >= T_OPEN else 0.0) * (1.0 - beam_down),
		&"beam_on": t >= T_OPEN,
		&"beam_off": t >= T_CONTROL,
		&"ring": _ease(_ramp(t, T_RING, RING_TIME)) * (1.0 - beam_down),
		&"crystals": _ease(_ramp(t, T_CRYSTALS, CRYSTAL_TIME)),
		&"crystal_glow": lerpf(1.0, CRYSTAL_LOW, _ease(beam_down)),
		&"motes_on": t >= T_MOTES and t < T_MOTES + MOTES_TIME,
		&"motes": _ramp(t, T_MOTES, MOTES_TIME),
		&"hero_visible": t >= T_HERO,
		&"hero_form": form,
		&"hero_flash": sin(form * PI),
		&"control": t >= T_CONTROL,
		&"caption": t >= T_CAPTION,
		&"done": t >= T_END,
	}


## Where a press at second t takes the clock: nowhere before SKIP_FROM, to T_CONTROL up to it, as it was after.
static func skip_to(t: float) -> float:
	if t < SKIP_FROM or t >= T_CONTROL:
		return t
	return T_CONTROL


static func _ramp(t: float, from: float, over: float) -> float:
	return clampf((t - from) / over, 0.0, 1.0)


static func _ease(k: float) -> float:
	return k * k * (3.0 - 2.0 * k)
