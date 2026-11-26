class_name CelState
extends RefCounted
## Blessings V1: what the Blessings have put on one enemy (Frio, Impacto, Marca, the count of Combustão, the recharges
## kept by target), pure and timed by step(dt). Enemy.cel holds one. Burn, Fraqueza and the freeze itself stay the
## game's own timers (Enemy.burn_t, weak_t, frozen_t); this only keeps the extra count each rule needs.

## Frio: stacks, seconds left of the window, the seconds it cannot be frozen again (from the moment it froze).
var cold := 0
var cold_t := 0.0
var freeze_block := 0.0
## Seconds of its freeze left (ours: the Estilhaçamento waits on it) and whether that freeze was already shattered.
var frozen_left := 0.0
var shattered := false
## Impacto: points, seconds left of the window, seconds it cannot be stunned again.
var impact := 0
var impact_t := 0.0
var stun_block := 0.0
## Marca (the Blessings' own, no damage of its own): seconds left.
var mark_t := 0.0
## Combustão: fire applications in a row on this one, and the seconds before it bursts again.
var burn_apps := 0
var combust_cd := 0.0
## Fire that jumped here (Chama Contagiosa) does not jump again.
var no_spread := false
## The action that last put each status on it (a status once per action and target): status -> action key.
var acted: Dictionary = {}
## Recharges kept on this target: key -> seconds left (an echo of a source, a flake's stack).
var gaps: Dictionary = {}


func step(dt: float) -> void:
	cold_t = maxf(0.0, cold_t - dt)
	if cold_t <= 0.0:
		cold = 0
	freeze_block = maxf(0.0, freeze_block - dt)
	frozen_left = maxf(0.0, frozen_left - dt)
	if frozen_left <= 0.0:
		shattered = false
	impact_t = maxf(0.0, impact_t - dt)
	if impact_t <= 0.0:
		impact = 0
	stun_block = maxf(0.0, stun_block - dt)
	mark_t = maxf(0.0, mark_t - dt)
	combust_cd = maxf(0.0, combust_cd - dt)
	for k: Variant in gaps.keys():
		gaps[k] = float(gaps[k]) - dt
		if float(gaps[k]) <= 0.0:
			gaps.erase(k)


## True the first time an action puts a status on this target (action: 0 or less: no dedupe, a periodic source).
func once(status: StringName, action: int) -> bool:
	if action == 0:
		return true
	if acted.get(status, 0) == action:
		return false
	acted[status] = action
	return true


## True when the keyed recharge is over (and starts it again for `seconds`).
func ready(key: StringName, seconds: float) -> bool:
	if gaps.has(key):
		return false
	if seconds > 0.0:
		gaps[key] = seconds
	return true


## Adds Frio stacks. Returns the seconds of freeze it now gets (0: none). window/freeze_time already carry the
## Blessings' extensions; the immunity runs from the moment of the freeze for freeze_time plus CelRules.FREEZE_IMMUNE.
func add_cold(stacks: int, window: float, freeze_time: float, need: int = CelRules.COLD_NEED) -> float:
	cold = mini(cold + stacks, need)
	cold_t = window
	if cold >= need and freeze_block <= 0.0:
		cold = 0
		freeze_block = freeze_time + CelRules.FREEZE_IMMUNE
		frozen_left = freeze_time
		shattered = false
		return freeze_time
	return 0.0


## True while its freeze (ours) can still be shattered once.
func shatterable() -> bool:
	return frozen_left > 0.0 and not shattered


## Adds Impacto points. Returns true when they stun it now (they clear; it is immune for CelRules.STUN_IMMUNE after).
func add_impact(points: int, window: float, need: int = CelRules.IMPACT_NEED) -> bool:
	if stun_block > 0.0:
		return false
	impact += points
	impact_t = window
	if impact >= need:
		impact = 0
		stun_block = CelRules.STUN_IMMUNE
		return true
	return false
