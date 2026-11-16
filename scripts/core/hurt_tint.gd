class_name HurtTint
extends RefCounted
## The tint at the edges of the screen when the paladin takes a blow (BUG-007): red, short and discreet, all of it
## only from Feel.hurt_tint_heavy damage, with a small colour split on those; under a boss's curse it is the curse's
## violet instead (Feel.curse_tint for Feel.curse_tint_time), never with a split. Game feeds it each blow and reads
## red and violet into screen.gdshader every frame. All its numbers are in Feel (data/feel.tres).

## Edge alpha of each colour now (0..1) and the seconds each fades over.
var red := 0.0
var violet := 0.0
var _red_time := 0.2
var _violet_time := 0.2


## A blow of amount damage; cursed, the paladin is under a boss's curse. Returns the colour split it asks of the
## screen (0 for none).
func hit(amount: float, cursed: bool, feel: Feel) -> float:
	if cursed:
		violet = maxf(violet, feel.curse_tint)
		_violet_time = feel.curse_tint_time
		return 0.0
	var heavy := amount >= feel.hurt_tint_heavy
	red = maxf(red, feel.hurt_tint * (1.0 if heavy else feel.hurt_tint_small))
	_red_time = feel.hurt_tint_time
	return feel.hurt_split if heavy else 0.0


## Fades both by real seconds (linear, to 0 in their time from their full strength).
func step(delta: float, feel: Feel) -> void:
	red = maxf(0.0, red - delta * feel.hurt_tint / maxf(_red_time, 0.01))
	violet = maxf(0.0, violet - delta * feel.curse_tint / maxf(_violet_time, 0.01))
