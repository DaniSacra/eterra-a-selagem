class_name DamageCalc
extends RefCounted
## Every damage number of the paladin goes through here.

## No bonus for the combo counter (C13-07, decision D-10: Hades II has none; it was 1% a hit up to 40%). The counter
## stays on the HUD.
const LAUNCHED_MULT := 1.5


## A blow against armor: returns [armor left, damage that reaches the life bar]. The blow that breaks the armor
## does not spill over (breaking it is its own reward: the stagger).
static func against_armor(armor: float, amount: float) -> Array[float]:
	if armor <= 0.0:
		return [0.0, amount]
	return [maxf(0.0, armor - amount), 0.0]


## base: the move's damage. bonus_pct: sum of percentage bonuses from gifts (0.2 = +20%).
## launched: target is in the air. frozen + shatter_pct: breaking a frozen target adds that share.
## undead + undead_mult: the Luz gift against the risen dead.
static func hit(base: float, bonus_pct: float, launched: bool, frozen: bool, shatter_pct: float, undead: bool, undead_mult: float) -> float:
	var dmg := base * (1.0 + bonus_pct)
	if launched:
		dmg *= LAUNCHED_MULT
	if frozen:
		dmg *= 1.0 + shatter_pct
	if undead:
		dmg *= maxf(1.0, undead_mult)
	return maxf(1.0, roundf(dmg))
