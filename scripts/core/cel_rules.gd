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


# ---------- Blessings V2 (docs/design/bencaos_v2/IMPLEMENTACAO_V2.md): Veneno, Sangramento, Eletrificação, Abertura ----------

## The held Golpe Esmagador (omega_attack) counts x2 on stacks and points, x1.5 on rates (a blow of the combo is x1).
const HOLD_COUNT_COEF := 2.0
const HOLD_RATE_COEF := 1.5
## Veneno (Zerael): stacks, one clock for all of them, the tick, the DPS of a skill's stack and the ceiling of the clock.
const POISON_MAX := 5
const POISON_TIME := 5.0
const POISON_TICK := 0.5
const POISON_SKILL_DPS := 2.5
const POISON_TIME_MAX := 8.0
## The poison zone puts one stack on whoever stands in it every this many seconds.
const PLAGUE_GAP := 1.0
## Saturação: the burst radius, the stacks it takes, its recharge on the same target, the share the neighbours take.
const SAT_RADIUS := 2.0
const SAT_COST := 2
const SAT_COOLDOWN := 4.0
const SAT_SPLASH := 0.5
const SAT_TARGETS := 4
## Deterioração: the most the poison can have grown.
const POISON_GROW_MAX := 0.30
## Sangramento (Qeshael): seconds it lasts, the stacks of the pool and the most of a blow it can take.
const BLEED_TIME := 4.0
const BLEED_STACKS := 3.0
const BLEED_SHARE_MAX := 0.8
## Eletrificação (Saarael, id thunder): charges, the window, the recharge of a Descarga, the reach of its resonance.
const SHOCK_MAX := 5
const SHOCK_WINDOW := 6.0
const DISCHARGE_CD := 4.0
const DISCHARGE_REACH := 3.0
const DISCHARGE_FORCE := 3
const CONDUCT_RADIUS := 3.5
const CONDUCT_SHARE := 0.5
const RESON_MAX := 4
const SHOCK_SKILL_ZAP := 2.5
## Antecipação: the recharge on one target. Propagation: where a condition goes, the lock it leaves and the least time.
const ANTIC_COOLDOWN := 2.0
const COPY_RADIUS := 3.0
const COPY_LOCK := 3.0
const COPY_MIN_TIME := 2.0
## A target's DoT ceiling (burn, poison and bleed together; the burn is the game's and is never cut).
const DOT_DPS_CAP := 40.0
## The lineage budget: targets of a reaction, reactions of an action (the last ACTIONS_KEPT actions) and of a frame.
const REACT_TARGETS := 5
const ACTION_REACT_CAP := 8
const FRAME_REACT_CAP := 24
const ACTIONS_KEPT := 3
const CHAIN_DEPTH := 3
## Fragments of a shatter, the pulse of Força Inabalável, Combustão's splash.
const FRAG_TARGETS := 3
const FRAG_RADIUS := 2.0
const FIRE_FRAG := 0.3
const PULSE_TARGETS := 3
const PULSE_RADIUS := 2.0
const PULSE_COOLDOWN := 2.0
const COMBUST_SPLASH_RADIUS := 2.0
## The boss's (and the guardian's) meters and the Abertura they open.
const METER_COLD := 8
const METER_IMPACT := 10
const METER_WINDOW := 8.0
const WINDOW_TIME := 4.0
const WINDOW_LOCK := 10.0
const WINDOW_VULN := 0.25
## Diversity of conditions: the ceiling every Blessing that reads it takes (Essência Restauradora asks this many).
const DIVERSITY_CAP := 3
## The crit that strengthens an application (Esplendor): the share more.
const CRIT_APPLY := 0.5
## Conditions that last longer (Crepúsculo, Véu Persistente): ceilings in seconds left.
const EXTEND_CAP := 8.0
const WEAK_EXTEND_CAP := 6.0
const WEAK_EXTEND_GAP := 3.0
const MARK_PASS_RADIUS := 4.0
const GUARD_IMPACT_TIME := 4.0
const WHIRL_COPIES := 2
const GUST_COPIES := 4
const GUST_RADIUS := 3.0

## Which reaction may come out of which (the lineage). What is not here is forbidden.
const EDGES := {
	&"direct": [&"combust", &"shatter", &"saturate", &"discharge", &"echo", &"whirl", &"rupture", &"antic", &"copy"],
	&"tick": [&"overload"],
	&"overload": [&"discharge"],
	&"combust": [&"antic"],
	&"shatter": [&"frag", &"crystal"],
	&"rupture": [&"antic", &"pulse"],
	&"discharge": [&"conduct"],
}


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
		"weak_max": "%d%%" % roundi(WEAK_MAX * 100.0), "trail_t": UiKit.format_number(Combat.TRAIL_TIME)}.merged(_v2_args())


## Blessings V2: the fixed numbers its cards name.
static func _v2_args() -> Dictionary:
	return {"poison_max": str(POISON_MAX), "poison_time": UiKit.format_number(POISON_TIME), "poison_cap": UiKit.format_number(POISON_TIME_MAX),
		"grow_max": _pct(POISON_GROW_MAX), "sat_r": UiKit.format_number(SAT_RADIUS), "sat_cost": str(SAT_COST), "sat_cd": UiKit.format_number(SAT_COOLDOWN),
		"copy_n": "2", "copy_r": UiKit.format_number(COPY_RADIUS), "shock_max": str(SHOCK_MAX), "shock_win": UiKit.format_number(SHOCK_WINDOW),
		"force_need": str(DISCHARGE_FORCE), "discharge_cd": UiKit.format_number(DISCHARGE_CD), "conduct_r": UiKit.format_number(CONDUCT_RADIUS),
		"conduct_pct": _pct(CONDUCT_SHARE), "reson_r": UiKit.format_number(DISCHARGE_REACH), "reson_n": str(RESON_MAX),
		"bleed_time": UiKit.format_number(BLEED_TIME), "bleed_ult": "20%", "antic": "50%", "antic_all": "20%",
		"combust_r": UiKit.format_number(COMBUST_SPLASH_RADIUS), "burn_div": "5%", "div_cap": str(DIVERSITY_CAP), "div_full": str(DIVERSITY_CAP),
		"frag": _pct(FIRE_FRAG), "frag_n": str(FRAG_TARGETS), "frag_r": UiKit.format_number(FRAG_RADIUS), "keep": "1",
		"pulse_n": str(PULSE_TARGETS), "pulse_r": UiKit.format_number(PULSE_RADIUS), "guard_win": UiKit.format_number(GUARD_IMPACT_TIME),
		"extend": "2", "extend_cap": UiKit.format_number(EXTEND_CAP), "extend_weak": "1", "weak_div": "3%", "whirl_spread": "25%",
		"mark_r": UiKit.format_number(MARK_PASS_RADIUS), "crit_apply": _pct(CRIT_APPLY), "window_time": UiKit.format_number(WINDOW_TIME),
		"window_pct": _pct(WINDOW_VULN), "window_lock": UiKit.format_number(WINDOW_LOCK)}


static func _pct(v: float) -> String:
	return "%d%%" % roundi(v * 100.0)


## The reaction `kind` may come out of `from` at this depth (the lineage: EDGES and CHAIN_DEPTH).
static func may_chain(from: StringName, kind: StringName, depth: int) -> bool:
	return depth < CHAIN_DEPTH and (EDGES.get(from, []) as Array).has(kind)


## The boss's and the guardian's (heavy) meters read their Frio and Impacto.
static func meter_target(def: EnemyDef) -> bool:
	return def.behavior == EnemyDef.Behavior.BOSS or def.heavy


## What a held blow (Golpe Esmagador) adds to a count (stacks, points) and to a rate (burn, bleed).
static func hold_count(base: float, held: bool) -> float:
	return base * (HOLD_COUNT_COEF if held else 1.0)


static func hold_rate(base: float, held: bool) -> float:
	return base * (HOLD_RATE_COEF if held else 1.0)


## An anticipation of a DoT: [paid now, still owed after], so nothing is paid twice.
static func anticipate(remaining: float, share: float) -> Array[float]:
	var s := clampf(share, 0.0, 1.0)
	return [remaining * s, remaining * (1.0 - s)]


## The damage of a poison tick: stacks, DPS of each, the growth of Deterioração (a fraction, under its ceiling).
static func poison_tick(stacks: int, dps: float, growth: float) -> float:
	return stacks * dps * (1.0 + minf(growth, POISON_GROW_MAX)) * POISON_TICK


## The pool a bleeding blow adds: its share (under the ceiling) of the blow's damage.
static func bleed_add(share: float, dmg: float) -> float:
	return minf(share, BLEED_SHARE_MAX) * dmg


## The damage of a Descarga: damage a charge, the charges, the resonance bonus a neighbour (neighbours under their ceiling).
static func discharge_dmg(per_charge: float, charges: int, reson: float, neighbours: int) -> float:
	return per_charge * charges * (1.0 + reson * minf(neighbours, RESON_MAX))


## How far a poison and a bleed (per second) must shrink so the three DoTs together stay under DOT_DPS_CAP (1.0: they fit).
## The burn counts in the total and is never cut.
static func dot_scale(burn: float, poison: float, bleed: float) -> float:
	var own := poison + bleed
	if own <= 0.0:
		return 1.0
	return clampf(maxf(0.0, DOT_DPS_CAP - burn) / own, 0.0, 1.0)


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
