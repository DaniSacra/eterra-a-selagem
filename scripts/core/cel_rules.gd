class_name CelRules
extends RefCounted
## Blessings V1 (docs/design/bencaos_v1/02_REGRAS.md): the limits and fixed numbers of the Blessing layer, in one place
## ("valores provisórios e configuráveis"), and the pure rules that read them. Nothing here touches a node. The numbers a
## card shows as its own (a Blessing's DPS, stacks, seconds) are the Blessing's mods in tools/make_data.gd; what sits
## here is shared by many Blessings or is a ceiling.

## Frio: this many stacks inside the window freeze a common enemy, clear the stacks and make it immune for a while.
const COLD_NEED := 3
const COLD_WINDOW := 4.0
const FREEZE_TIME := 0.8
const FREEZE_IMMUNE := 2.0
## Slow by stack (Geada Profunda adds to it) and its ceiling.
const SLOW_PER_STACK := 0.10
const SLOW_MAX := 0.40
## Impacto: points inside the window stun a common enemy for a while, then it is immune.
const IMPACT_NEED := 5
const IMPACT_WINDOW := 4.0
const STUN_TIME := 0.6
const STUN_IMMUNE := 3.0
## Fraqueza: the most damage a weakened enemy can lose (the base cut is Combat.WEAK_CUT).
const WEAK_MAX := 0.40
## Crítico de bênção: no chance of its own, 150% damage, ceilings 60% and 250%.
const CRIT_BASE_MULT := 1.5
const CRIT_MAX := 0.60
const CRIT_MULT_MAX := 2.5
## Totals of the Blessing layer: speed of blows and cut of a recharge.
const SPEED_MAX := 0.50
const CDR_MAX := 0.30
## Combustão (Sarael): applications of fire in a row, and the seconds before the same enemy bursts again.
const COMBUST_APPS := 3
const COMBUST_CD := 3.0
## Chama Contagiosa: where the fire jumps to, for how long (the share of DPS is the Blessing's number).
const SPREAD_RADIUS := 3.0
const SPREAD_TIME := 2.0
## Cristais Errantes: where the frost jumps to (one stack) and its recharge.
const CRYSTAL_RADIUS := 2.5
const CRYSTAL_CD := 3.0
## Clarão: how long the next blow keeps its chance. Luz Crescente: the stacks and how long they last.
const CLARAO_TIME := 3.0
const LUZ_STACKS := 3
const LUZ_TIME := 4.0
## Passo Firme: the recharge of the shield it lends.
const GUARD_COOLDOWN := 8.0
## Essência Restauradora: the recharge of the whole Blessing (not by enemy).
const MANA_COOLDOWN := 2.0
## Cadência: stacks, how long they last; Turbilhão: where it blows and its recharge.
const CADENCE_STACKS := 5
const CADENCE_TIME := 3.0
const WHIRL_RADIUS := 3.0
const WHIRL_COOLDOWN := 5.0
## Echoes: how long after the blow they land, the recharge of the Brado's echo (one for the whole action) and of the others
## (on the same enemy).
const ECHO_DELAY := 0.4
const Q_ECHO_COOLDOWN := 3.0
const ECHO_COOLDOWN := 1.0
## Combustão and other secondary hits carry this tag (no new echo, crit or stack comes of them).
const SECONDARY_TAG := &"celestial"


## The fixed numbers a card's sentence names ({name} in the text of a Blessing, BoonChoice.describe), so a number on a card
## is always the one in play.
static func text_args() -> Dictionary:
	return {"burn_time": UiKit.format_number(3.0), "combust_apps": str(COMBUST_APPS), "combust_cd": UiKit.format_number(COMBUST_CD),
		"spread_r": UiKit.format_number(SPREAD_RADIUS), "spread_t": UiKit.format_number(SPREAD_TIME), "cold_need": str(COLD_NEED),
		"cold_win": UiKit.format_number(COLD_WINDOW), "freeze": UiKit.format_number(FREEZE_TIME), "slow_max": "%d%%" % roundi(SLOW_MAX * 100.0),
		"crystal_r": UiKit.format_number(CRYSTAL_RADIUS), "crystal_cd": UiKit.format_number(CRYSTAL_CD),
		"clarao_t": UiKit.format_number(CLARAO_TIME), "luz_n": str(LUZ_STACKS), "luz_t": UiKit.format_number(LUZ_TIME),
		"impact_need": str(IMPACT_NEED), "impact_need_less": str(IMPACT_NEED - 1), "impact_win": UiKit.format_number(IMPACT_WINDOW),
		"stun": UiKit.format_number(STUN_TIME), "guard_cd": UiKit.format_number(GUARD_COOLDOWN), "mana_cd": UiKit.format_number(MANA_COOLDOWN),
		"cad_n": str(CADENCE_STACKS), "cad_t": UiKit.format_number(CADENCE_TIME), "whirl_r": UiKit.format_number(WHIRL_RADIUS),
		"whirl_cd": UiKit.format_number(WHIRL_COOLDOWN), "echo_delay": UiKit.format_number(ECHO_DELAY),
		"q_echo_cd": UiKit.format_number(Q_ECHO_COOLDOWN), "echo_cd": UiKit.format_number(ECHO_COOLDOWN),
		"weak_max": "%d%%" % roundi(WEAK_MAX * 100.0), "trail_t": UiKit.format_number(Combat.TRAIL_TIME)}


## The Blessing slot a blow with these tags belongs to: the action that dealt it. The Investida is RUSH (E: no Blessing of
## its own in V1) and the dodge deals no blow. A charged attack is its source's (an Omega of the attack is the attack's, of
## the special the special's). NONE for what is no action of the hero's (a Blessing's own hit, a burn, an echo, a zone).
static func slot_of(tags: Array[StringName]) -> Boon.Slot:
	var source := DealtBy.source(tags)
	match source:
		&"attack", &"omega_attack":
			return Boon.Slot.ATTACK
		&"special", &"omega_special":
			return Boon.Slot.SPECIAL
		&"shout":
			return Boon.Slot.CAST
		&"dash":
			return Boon.Slot.RUSH
		&"ultimate":
			return Boon.Slot.ULT
	return Boon.Slot.NONE


## A hit of an action of the hero's (its own tags say so), never one a Blessing made.
static func is_direct(tags: Array[StringName]) -> bool:
	return slot_of(tags) != Boon.Slot.NONE and not tags.has(SECONDARY_TAG)


## The chance of a critical blow and its multiplier from the sums asked of the Blessings (never past the ceilings).
static func crit_chance(sum: float) -> float:
	return clampf(sum, 0.0, CRIT_MAX)


static func crit_mult(bonus: float) -> float:
	return clampf(CRIT_BASE_MULT + bonus, CRIT_BASE_MULT, CRIT_MULT_MAX)


## True when a die (0 to 1) falls inside the chance.
static func crits(chance: float, die: float) -> bool:
	return chance > 0.0 and die < crit_chance(chance)


static func speed_bonus(sum: float) -> float:
	return clampf(sum, 0.0, SPEED_MAX)


static func cooldown_cut(sum: float) -> float:
	return clampf(sum, 0.0, CDR_MAX)


## The slow a Frio stack count gives (stacks times the share, with the ceiling).
static func slow_of(stacks: int, per_stack: float) -> float:
	return minf(stacks * per_stack, SLOW_MAX)


## The damage cut of a weakened enemy: the base plus the deepening, under its ceiling.
static func weak_cut(base: float, deepen: float) -> float:
	return minf(base + deepen, WEAK_MAX)
