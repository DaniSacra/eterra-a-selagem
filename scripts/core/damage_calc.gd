class_name DamageCalc
extends RefCounted
## Every damage number of the paladin goes through here.

const LAUNCHED_MULT := 1.5
const COMBO_STEP := 0.01
const COMBO_CAP := 40


## Extra damage for keeping the combo counter alive: 1% per hit, up to 40%.
static func combo_bonus(combo_count: int) -> float:
	return clampi(combo_count, 0, COMBO_CAP) * COMBO_STEP


## base: the move's damage. bonus_pct: sum of percentage bonuses from gifts (0.2 = +20%).
## launched: target is in the air. frozen + shatter_pct: breaking a frozen target adds that share.
## undead + undead_mult: the Luz gift against the risen dead.
static func hit(base: float, bonus_pct: float, combo_count: int, launched: bool, frozen: bool, shatter_pct: float, undead: bool, undead_mult: float) -> float:
	var dmg := base * (1.0 + bonus_pct + combo_bonus(combo_count))
	if launched:
		dmg *= LAUNCHED_MULT
	if frozen:
		dmg *= 1.0 + shatter_pct
	if undead:
		dmg *= maxf(1.0, undead_mult)
	return maxf(1.0, roundf(dmg))
