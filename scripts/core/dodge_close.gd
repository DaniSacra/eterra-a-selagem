class_name DodgeClose
extends RefCounted
## C1e: the dodge made at the last instant. A blow that would have landed within `window` seconds of the dodge's start
## is a close one: a small reward (a short slow motion, a glint, a sound), never a stun (rule F8), at most once per
## `cooldown` seconds. Pure rules; Player feeds it, Game shows it.


## True when a blow reaching the paladin `since` seconds into a dodge is a close one and the reward is not cooling.
static func counts(since: float, window: float, cooldown_left: float) -> bool:
	return since <= window and cooldown_left <= 0.0
