class_name StepRules
extends RefCounted
## The short step a blow of the combo takes as it lands (ComboNode.step, PT-25-4 and PT-25-11), pure. It fades by its own
## decay, slower than the Investida's lunge, so even the finisher's 0.8 m starts under the run (4.8 m/s against 6.75)
## and reads as a step, not a slide; it never carries the paladin into a floor trap armed under his feet.

## 1/s: the step's speed fades this fast; its distance is the speed over this (the same meters as ever).
const DECAY := 6.0


## The step's starting speed (m/s) for `meters` of step.
static func speed(meters: float) -> float:
	return meters * DECAY


## Whether a step of `meters` from `pos` along `dir` would end inside one of the armed `traps` (rectangles, grown by
## `margin`) that does not already hold him: a step out of one, or inside one, is his to make.
static func into_trap(pos: Vector2, dir: Vector2, meters: float, traps: Array[Rect2], margin: float) -> bool:
	var end := pos + dir * meters
	for r in traps:
		var g := r.grow(margin)
		if g.has_point(end) and not g.has_point(pos):
			return true
	return false


## The speed left after `dt` seconds.
static func fade(v: Vector2, dt: float) -> Vector2:
	return v * maxf(0.0, 1.0 - DECAY * dt)
