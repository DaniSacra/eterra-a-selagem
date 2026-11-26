class_name ButtonIntent
extends RefCounted
## GP-1 (docs/design/heroes/warrior_v1_2026-11-26.md 3): tap or hold on one blow button. Pure, no nodes, no clock of its own.
## A press waits (WAIT): let go before `threshold` seconds it is a TAP (one blow, on the release); held past it, it is a hold: the
## held blow's charge runs (HOLDING) when the Magia is there for it, otherwise the button is REFUSED (the Magia bar says why, once)
## and nothing strikes. Each press yields at most one thing: never the tap and the held blow, never a tap after a refusal. The
## dodge (cancel) drops it to rest with the button ignored until it is let go; a held blow that strikes (fire) does the same.
##
## Use: each frame `var out := intent.update(dt, pressed_edge, is_down, can_hold, threshold)`; Out.TAP: play the tap's blow;
## Out.REFUSED: flash the Magia bar. While `state == HOLDING`, `held_t` counts the seconds since the press (the charge's clock).

enum State { REST, WAIT, HOLDING, REFUSED, SPENT }
## REFUSED_TAP: refused and the tap's blow comes out all the same (Feel.hold_fallback_tap).
enum Out { NONE, TAP, REFUSED, REFUSED_TAP, HOLD_BEGAN }

var state := State.REST
## Seconds since the press (the held blow's charge counts from the press, not from the threshold).
var held_t := 0.0


## One frame. `pressed`: the button went down since the last frame (latched presses count); `down`: it is down now; `can_hold`:
## the held blow is paid for (Magia) and exists; `fallback_tap`: with no Magia, strike the tap's blow at the threshold (Feel.hold_fallback_tap).
func update(dt: float, pressed: bool, down: bool, can_hold: bool, threshold: float, fallback_tap := false) -> Out:
	match state:
		State.REST:
			if not pressed:
				return Out.NONE
			if not down:
				return Out.TAP  # pressed and let go inside one frame (a click during a hit stop)
			state = State.WAIT
			held_t = 0.0
			return Out.NONE
		State.WAIT:
			if not down:
				state = State.REST
				return Out.TAP
			held_t += dt
			if held_t >= threshold:
				if can_hold:
					state = State.HOLDING
					return Out.HOLD_BEGAN
				if fallback_tap:
					state = State.SPENT
					return Out.REFUSED_TAP
				state = State.REFUSED
				return Out.REFUSED
			return Out.NONE
		State.HOLDING:
			if not down:
				state = State.REST  # let go before the charge filled: nothing comes
				held_t = 0.0
				return Out.NONE
			held_t += dt
		State.REFUSED, State.SPENT:
			if not down:
				state = State.REST
				held_t = 0.0
	return Out.NONE


## The held blow is out (its charge filled): the button is ignored until it is let go.
func fire() -> void:
	state = State.SPENT


## The dodge, a pause, a new room or a curse: back to rest; a button still down is ignored until it is let go.
## `down`: whether the button is down now.
func cancel(down: bool) -> void:
	held_t = 0.0
	state = State.SPENT if down else State.REST


func reset() -> void:
	state = State.REST
	held_t = 0.0


func holding() -> bool:
	return state == State.HOLDING


func waiting() -> bool:
	return state == State.WAIT
