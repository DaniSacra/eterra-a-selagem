class_name DeathWeight
extends RefCounted
## G-3 (CF2-10): a body felled by the third blow or the spin (a finisher) is thrown 1.5 times as far and is gone in
## 0.35 s; one felled by blow 1 or 2 keeps the plain fall (1.5 s on the ground, then dust). Pure numbers, read by Horde.

const SHOW := 1.5
const DISSOLVE_FROM := 0.85
const STRONG_SHOW := 0.35
const STRONG_PUSH := 1.5


## Seconds the fallen body is kept (drawn) for.
static func show_time(strong: bool) -> float:
	return STRONG_SHOW if strong else SHOW


## The second its dissolve starts, in the same share of its time as the plain fall's.
static func dissolve_from(strong: bool) -> float:
	return show_time(strong) * DISSOLVE_FROM / SHOW


## The knockback a killing blow throws the body with.
static func push(knockback: float, strong: bool) -> float:
	return knockback * (STRONG_PUSH if strong else 1.0)
