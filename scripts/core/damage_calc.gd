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


## Blows that take a real chunk of a tough armor (EnemyDef.armor_soft): the finisher, the special's wave, the dash cut, the
## Omegas, the Brado's shout and the ultimates. The common light blows (cut1, cut2, the fourth thrust) and the zones' ticks are not.
const STRONG_TAGS: Array[StringName] = [&"finisher", &"heavy", &"wave", &"dash", &"omega", &"ultimate", &"shout"]


## The share of a blow that reaches armor with `soft` (1: all of it): only a strong blow takes it all.
static func armor_scale(soft: float, tags: Array[StringName]) -> float:
	if soft >= 1.0:
		return 1.0
	for t in STRONG_TAGS:
		if tags.has(t):
			return 1.0
	return soft


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


## Fraqueza (the Veu family): a weakened enemy deals `cut` less (0.25 = a quarter less; never more than MAX_WEAK_CUT).
const MAX_WEAK_CUT := 0.6


static func weakened(damage: float, cut: float, weak: bool) -> float:
	return damage * (1.0 - clampf(cut, 0.0, MAX_WEAK_CUT)) if weak else damage


## Marca (the Marca family): a marked enemy takes `bonus` more from every blow (the base mark plus the Blessings'),
## always, no dice, so a run keeps its seed.
static func marked(damage: float, bonus: float, mark: bool) -> float:
	return maxf(1.0, roundf(damage * (1.0 + bonus))) if mark else damage


## Mare (the Mare family): a blow on an enemy still sliding from a push hits `bonus` harder.
static func shoved(damage: float, bonus: float, sliding: bool) -> float:
	return maxf(1.0, roundf(damage * (1.0 + bonus))) if sliding else damage
