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
## Blessings V2. Veneno: stacks (0 to 5), the one clock of all of them, the DPS of each and the seconds since the first (Deterioração),
## the recharge of Saturação. Propagation leaves a lock on its target (a copy does not copy).
var poison := 0
var poison_t := 0.0
var poison_dps := 0.0
var poison_age := 0.0
var sat_cd := 0.0
var copy_lock := 0.0
## Sangramento: the damage still owed and the seconds it has left.
var bleed_pool := 0.0
var bleed_t := 0.0
## Eletrificação: charges, the window, the recharge of the Descarga, the fraction of Sobrecarga not yet a charge.
var shock := 0
var shock_t := 0.0
var discharge_cd := 0.0
var over_acc := 0.0
## The meters of a boss or guardian (Frio, Impacto), their window, the Abertura (seconds of it) and the lock after it.
var meter_c := 0
var meter_i := 0
var meter_t := 0.0
var window_t := 0.0
var window_lock := 0.0
## A Marca that passed on at a death does not pass again.
var mark_passed := false
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
	sat_cd = maxf(0.0, sat_cd - dt)
	copy_lock = maxf(0.0, copy_lock - dt)
	discharge_cd = maxf(0.0, discharge_cd - dt)
	shock_t = maxf(0.0, shock_t - dt)
	if shock_t <= 0.0:
		shock = 0
		over_acc = 0.0
	meter_t = maxf(0.0, meter_t - dt)
	if meter_t <= 0.0:
		meter_c = 0
		meter_i = 0
	window_t = maxf(0.0, window_t - dt)
	window_lock = maxf(0.0, window_lock - dt)
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


## Blessings V2: adds poison stacks (the clock of all of them is one: it only returns to `time`, never adds) and keeps the
## greater DPS while it lasts.
func add_poison(stacks: int, time: float, dps: float) -> void:
	if poison <= 0:
		poison_age = 0.0
		poison_dps = dps
	else:
		poison_dps = maxf(poison_dps, dps)
	poison = mini(poison + stacks, CelRules.POISON_MAX)
	poison_t = maxf(poison_t, minf(time, CelRules.POISON_TIME_MAX))


func clear_poison() -> void:
	poison = 0
	poison_t = 0.0
	poison_age = 0.0


## Adds to the bleed pool: never more than CelRules.BLEED_STACKS of this blow's share; the time returns to BLEED_TIME.
func add_bleed(amount: float) -> void:
	bleed_pool = minf(bleed_pool + amount, amount * CelRules.BLEED_STACKS)
	bleed_t = CelRules.BLEED_TIME


## Pays a tick of bleed (seconds long): the pool owed over what is left of the time. Returns the damage; the pool is empty when
## the time is over.
func bleed_tick(seconds: float) -> float:
	if bleed_pool <= 0.0 or bleed_t <= 0.0:
		bleed_pool = 0.0
		return 0.0
	var pay := bleed_pool * minf(seconds / bleed_t, 1.0)
	bleed_pool -= pay
	bleed_t = maxf(0.0, bleed_t - seconds)
	if bleed_t <= 0.0:
		bleed_pool = 0.0
	return pay


## Adds charges (up to CelRules.SHOCK_MAX); the window returns to its full length.
func add_shock(charges: int) -> void:
	shock = mini(shock + charges, CelRules.SHOCK_MAX)
	shock_t = CelRules.SHOCK_WINDOW


## Adds points to a boss's meter ("c" Frio, "i" Impacto) that fills at `need`. Returns true when it fills now and opens the
## Abertura: while it (and its lock) lasts the meters add nothing.
func add_meter(kind: StringName, points: int, need: int) -> bool:
	if window_lock > 0.0:
		return false
	meter_t = CelRules.METER_WINDOW
	if kind == &"c":
		meter_c += points
	else:
		meter_i += points
	if (meter_c if kind == &"c" else meter_i) >= need:
		meter_c = 0
		meter_i = 0
		window_t = CelRules.WINDOW_TIME
		window_lock = CelRules.WINDOW_TIME + CelRules.WINDOW_LOCK
		frozen_left = CelRules.WINDOW_TIME  # (Estilhaçamento waits on it: the first blow of the Abertura shatters)
		shattered = false
		return true
	return false


## How many of the six conditions are on the enemy now (Queimadura, Veneno, Sangramento, Frio, Eletrificação, Marca).
func diversity(e: Enemy) -> int:
	var n := 0
	for on in [e.burn_t > 0.0, poison > 0, bleed_t > 0.0 and bleed_pool > 0.0, cold > 0 or e.frozen_t > 0.0, shock > 0, mark_t > 0.0]:
		if on:
			n += 1
	return n
