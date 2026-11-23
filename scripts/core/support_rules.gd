class_name SupportRules
extends RefCounted
## C1e, pure rules of the Gritador, the Coveiro and the modifiers (docs/design/inimigos_c1e.md); Horde does the rest.


## How much faster than its own pace an enemy acts: a shout (while it lasts) and a modifier add up.
static func pace(hasted: bool, shout_pace: float, mod_pace: float) -> float:
	return 1.0 + (shout_pace if hasted else 0.0) + mod_pace


## Life after a shout's heal: a share of the most, never past it.
static func healed(hp: float, max_hp: float, share: float) -> float:
	return minf(max_hp, hp + max_hp * share)


## Whether `other` stands in a shout's reach.
static func in_reach(from: Vector2, other: Vector2, radius: float) -> bool:
	return from.distance_to(other) <= radius


## Where the dead rise: n spots on a ring of `ring` m round `from`, fanned `spread` degrees apart on the side away from `hero`;
## a spot nearer the paladin than `far` m is left out (the dead never rise on him).
static func spots(from: Vector2, hero: Vector2, n: int, ring: float, spread: float, far: float) -> Array[Vector2]:
	var out: Array[Vector2] = []
	var away := (from - hero).normalized() if from.distance_to(hero) > 0.01 else Vector2.RIGHT
	for k in n:
		var at := from + away.rotated(deg_to_rad(spread) * (k - (n - 1) * 0.5)) * ring
		if at.distance_to(hero) >= far:
			out.append(at)
	return out


## The chance a head is born with a modifier at `depth`: none before `from`, `base` there, `step` more each room after.
static func mod_chance(depth: int, from: int, base: float, step: float) -> float:
	if base <= 0.0 or depth < from:
		return 0.0
	return minf(1.0, base + step * (depth - from))


## The directions of a cross of n lances (4: the four ways of the floor).
static func cross(n: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for k in n:
		out.append(Vector2.RIGHT.rotated(TAU * k / maxf(1.0, n)))
	return out


## Life after a Regenerante's mending: `amount` more, never past the most.
static func mended(hp: float, max_hp: float, amount: float) -> float:
	return minf(max_hp, hp + amount)


## The life an Eco rises with: a share of its most (never under 1).
static func echo_hp(max_hp: float, share: float) -> float:
	return maxf(1.0, max_hp * share)


## Whether an Eco's mound, lying `t` s, rises now.
static func echo_rises(t: float, time: float) -> bool:
	return t >= time
