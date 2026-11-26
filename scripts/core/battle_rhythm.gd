class_name BattleRhythm
extends RefCounted
## GP-1 (docs/design/heroes/warrior_v1_2026-11-26.md 6): the Ritmo de Batalha, the Warrior's passive. A finisher of the Combo that
## lands arms it for `hero.rhythm_time` seconds (armed again: only the time renews); the next strong blow that strikes (the
## Esmagador, the Corte Circular or the Lança) takes its bonus and the state is gone. The Combo and the ultimate never consume it.
## Pure: HeroGifts feeds it, Combat reads what the blow gets. The magnitudes are HeroDef's (rhythm_*).

enum Kind { NONE, SMASH, POWER, SPECIAL }

var hero: HeroDef
## Seconds left (0: not armed).
var left := 0.0
## For the RESULT (balance): times armed, the blows that used it by kind, the times it ran out unused.
var tally := {"rhythm_armed": 0, "rhythm_used_smash": 0, "rhythm_used_power": 0, "rhythm_used_special": 0, "rhythm_expired": 0}


func _init(h: HeroDef) -> void:
	hero = h


## The Ritmo exists for this hero (rhythm_time above 0).
func enabled() -> bool:
	return hero.rhythm_time > 0.0


func armed() -> bool:
	return left > 0.0


## Share (0..1) of its time still to run, for the HUD's thin gold arc (0: not armed).
func share() -> float:
	return clampf(left / hero.rhythm_time, 0.0, 1.0) if enabled() else 0.0


func step(dt: float) -> void:
	if left <= 0.0:
		return
	left -= dt
	if left <= 0.0:
		left = 0.0
		tally.rhythm_expired += 1


## A finisher of the Combo landed on at least one enemy.
func arm() -> void:
	if not enabled():
		return
	if left <= 0.0:
		tally.rhythm_armed += 1
	left = hero.rhythm_time


## Which consuming action a move is (NONE for the Combo, the ultimate and anything else).
static func kind_of(node: ComboNode) -> Kind:
	if node.has_tag(&"smash"):
		return Kind.SMASH
	if node.has_tag(&"sweep"):
		return Kind.POWER
	if node.has_tag(&"lance"):
		return Kind.SPECIAL
	return Kind.NONE


## A consuming blow strikes: returns its kind when the Ritmo was armed (and clears it), else NONE.
func consume(node: ComboNode) -> Kind:
	var kind := kind_of(node)
	if kind == Kind.NONE or left <= 0.0:
		return Kind.NONE
	left = 0.0
	match kind:
		Kind.SMASH:
			tally.rhythm_used_smash += 1
		Kind.POWER:
			tally.rhythm_used_power += 1
		Kind.SPECIAL:
			tally.rhythm_used_special += 1
	return kind


## The room changed, he fell or the ultimate went off: gone, not counted as expired.
func clear() -> void:
	left = 0.0
