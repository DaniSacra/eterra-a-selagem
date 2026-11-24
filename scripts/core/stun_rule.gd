class_name StunRule
extends RefCounted
## Which of the paladin's blows stun a common enemy and cut the attack it winds up (an experiment, Daniel 2026-11-21: "o que
## eu to achando fácil é bater e meio que dar stun nos inimigos"; reversible). F8 steps through them while playing (every
## build), `--stun=all|strong|none` picks one for a run. Only EnemyDef.stun_time's blows ask here (Horde.damage): an
## armour breaking, an ultimate, ice and a gift's own stun are never touched.
##   ALL: every blow (as it was, Hades II's). STRONG: only the combo's last blow and the Omegas. NONE: no blow.

enum Mode { ALL, STRONG, NONE }

const IDS: Array[StringName] = [&"all", &"strong", &"none"]
const TEXT: Array[StringName] = [&"stun_rule_all", &"stun_rule_strong", &"stun_rule_none"]
## Daniel, 2026-11-21: "não pode interromper ninguém, para ficar mais emocionante".
const DEFAULT := Mode.NONE

static var live: Mode = from_id(Dev.arg("stun")) if Dev.has("stun") else DEFAULT


static func from_id(id: String) -> Mode:
	var i := IDS.find(StringName(id))
	return i as Mode if i >= 0 else DEFAULT


static func step() -> void:
	live = ((live + 1) % IDS.size()) as Mode


static func stuns(strong: bool) -> bool:
	return live == Mode.ALL or (live == Mode.STRONG and strong)


## The one exception of the rule (redesign 2026-11-24, B.4): with Investida Implacável (dash_pierce above 0) the Investida
## stuns whoever it goes through, for dash_stun seconds, but only a common enemy: elites, guardians (armor takes the
## Quebra instead) and bosses (Postura) are never stunned this way. Not asked of live: it holds in every mode.
static func dash_stuns(common: bool, pierce: float) -> bool:
	return pierce > 0.0 and common


## The second exception (decision B4, 2026-11-24): with Voz do Leão (stun_pct above 0 on the Brado) the cry interrupts every common
## enemy it reaches for SHOUT_STUN seconds, whatever the mode. Elites, guardians and bosses are never stunned this way.
const SHOUT_STUN := 1.0


static func shout_stuns(common: bool, stun_pct: float) -> bool:
	return stun_pct > 0.0 and common
