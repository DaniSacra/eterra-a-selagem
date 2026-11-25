class_name DefeatCause
extends RefCounted
## What hurt the paladin last, named for the end screen ("Derrotado por: Tempestade das Seis Almas"): a boss's attack
## by its own text (killer_<attack> in data/text_pt.tres), else the kind of enemy whose blow, warning or shot it was
## (its EnemyDef.name_key), else killer_unknown. Game.last_hurt keeps it; Game.defeated_by() names it.

## The boss attacks with a name of their own (Boss: the source of their warnings and shots). "ritual" is an eruption
## of the ritual; "adds" (his dead) is not here: the kind of the dead names it.
## E5: "runes" is the floor of the Câmara das Runas Instáveis (Ground.HAZARD_SOURCE), named the same way; RP-06:
## "plates" the slabs that strike when stepped on (Ground.PLATE_SOURCE); RP-11: "chain" the chain that sweeps the bridge
## (Ground.CHAIN_SOURCE); RP-10: "roots" the roots that strike in the Jardim (Ground.ROOT_SOURCE); RP-16: "slit" the arrow slit (Ground.SLIT_SOURCE); SR-P1: "trap" the wall trap's blades (Ground.TRAP_SOURCE);
## A1: "crystal" the crystal's discharge (RP-14), "rocks" the stones of the vault (RP-20), "urn" the oil urn's blast
## and "oil" its running flame (RP-12); AT-H2 "niche" the skeleton of the niche, AT-H3 "plant" the hostile plant; SR-P2 "sag" the slab that gives, SR-P3 "spikes" the pit grate; 2026-11-23 "spikeplate" the plate that raises spikes; S (2026-11-25) "breath" the rift's breath (only enemies are hurt, the key is there for the tally).
const BOSS_ATTACKS: Array[StringName] = [&"scythe", &"reap", &"blades", &"storm", &"barrage", &"eruptions", &"ritual", &"rupture", &"curse", &"dash", &"runes",
	&"plates", &"chain", &"roots", &"slit", &"trap", &"crystal", &"rocks", &"urn", &"oil", &"niche", &"plant", &"sag", &"spikes", &"spikeplate", &"breath", &"gap"]
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
