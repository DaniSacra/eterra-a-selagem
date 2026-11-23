class_name AttackGap
extends RefCounted
## The random rest between a boss's attacks (Daniel, 2026-11-23: "the gap should be random, 0.3 to 1.5 s, and shrink as he
## loses life"): uniform between a minimum and a maximum that both slide from their full-life values to their zero-life
## values by the share of life (or toughness) he has left. Pure rule; the caller owns the seeded RNG.


## The range [min, max] at `share` of life (1 full, 0 none).
static func range_at(min_full: float, max_full: float, min_zero: float, max_zero: float, share: float) -> Vector2:
	var s := clampf(share, 0.0, 1.0)
	var lo := lerpf(min_zero, min_full, s)
	return Vector2(lo, maxf(lo, lerpf(max_zero, max_full, s)))


## One gap, seconds.
static func pick(min_full: float, max_full: float, min_zero: float, max_zero: float, share: float, rng: RandomNumberGenerator) -> float:
	var r := range_at(min_full, max_full, min_zero, max_zero, share)
	return rng.randf_range(r.x, r.y)
