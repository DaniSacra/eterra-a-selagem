class_name DefeatCause
extends RefCounted
## What hurt the paladin last, named for the end screen ("Derrotado por: Tempestade das Seis Almas"): a boss's attack
## by its own text (killer_<attack> in data/text_pt.tres), else the kind of enemy whose blow, warning or shot it was
## (its EnemyDef.name_key), else killer_unknown. Game.last_hurt keeps it; Game.defeated_by() names it.

## The boss attacks with a name of their own (Boss: the source of their warnings and shots). "ritual" is an eruption
## of the ritual; "adds" (his dead) is not here: the kind of the dead names it.
## E5: "runes" is the floor of the Câmara das Runas Instáveis (Ground.HAZARD_SOURCE), named the same way; RP-06:
## "plates" the slabs that strike when stepped on (Ground.PLATE_SOURCE).
const BOSS_ATTACKS: Array[StringName] = [&"scythe", &"reap", &"blades", &"storm", &"eruptions", &"ritual", &"curse", &"dash", &"runes",
	&"plates"]
const UNKNOWN := &"killer_unknown"


## The cause of one blow: attack, the boss attack's id (&"" when none); enemy, the kind that dealt it (&"": none).
static func of(attack: Variant, enemy: Variant) -> Dictionary:
	var a: StringName = attack if attack is StringName else &""
	var by: StringName = enemy if enemy is StringName else &""
	return {"attack": a if BOSS_ATTACKS.has(a) else &"", "enemy": by}


## A short name for a cause, to count damage by (RoomTally): the boss attack's id, else the enemy kind's id, else
## "unknown".
static func key(cause: Dictionary) -> String:
	var attack: StringName = cause.get("attack", &"")
	if attack != &"":
		return String(attack)
	var enemy: StringName = cause.get("enemy", &"")
	return String(enemy) if enemy != &"" else "unknown"


## The text key that names a cause. name_key: the enemy kind's EnemyDef.name_key (&"" when none or unknown).
static func text_key(cause: Dictionary, name_key: StringName = &"") -> StringName:
	var attack: StringName = cause.get("attack", &"")
	if attack != &"":
		return StringName("killer_" + String(attack))
	if name_key != &"":
		return name_key
	return UNKNOWN
