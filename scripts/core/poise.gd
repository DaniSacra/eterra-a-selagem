class_name Poise
extends RefCounted
## C1b (docs/design/combate_c1b.md, Frente 1): the Quebra. A common enemy has a poise (EnemyDef.poise, 0: none) that each
## blow of the paladin wears by the BUTTON it came from, not by its damage (the weights are Feel.poise_weights, a share of the
## full poise; sources are DealtBy's). It breaks at 0: stunned, the wind-up cut, takes more damage, then the poise is full
## again. Burns, zones, echoes and a Blessing's own hits (no weight) never wear it. Pure: the Horde holds the state.

## Share of the full poise a blow from `source` takes (0 for a source with no weight).
static func share(source: StringName, weights: Dictionary) -> float:
	return float(weights.get(String(source), 0.0))


## Poise left after a blow of `share` (of `full`), never under 0.
static func wear(left: float, full: float, shr: float) -> float:
	return maxf(0.0, left - full * shr)


## Poise left after `idle` seconds with no blow that wore it: full again past `after` seconds.
static func settle(left: float, full: float, idle: float, after: float) -> float:
	return full if idle >= after else left


## SW-C5 (SWORN's stagger, subsequentStunResistMultiplier): the full poise after `breaks` breaks, each `growth` times the one before
## (1: always the same, the commons'). The stun it lasts is the def's own.
static func full_after(base: float, breaks: int, growth: float) -> float:
	return base * pow(maxf(growth, 1.0), maxi(breaks, 0))


## Whether a body takes poise now: it has some, and is not frozen, stunned, down or invulnerable.
static func takes(full: float, frozen_t: float, stun_t: float, down: bool, invulnerable: bool) -> bool:
	return full > 0.0 and frozen_t <= 0.0 and stun_t <= 0.0 and not down and not invulnerable
