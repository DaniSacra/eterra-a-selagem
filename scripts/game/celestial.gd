class_name Celestial
extends RefCounted
## Blessings V1 (docs/design/bencaos_v1): the Blessing layer that sits on Combat. The hero's own actions are not changed:
## this listens to what they do (a direct hit lands, an action begins, a dodge, the ultimate, a kill) and adds what the
## Blessings in hand say. Every number is a mod of the Blessing (BoonState.slot_stat for what rides on one action, stat
## for a complement's global one) or a constant of CelRules. What it puts on an enemy is its CelState (Enemy.cel).
##
## Limits kept here (02_REGRAS): one status a blow and target (CelState.once), nothing a Blessing deals on its own
## (secondary: burns, zones, echoes, Combustão, Turbilhão...) crits, echoes, stacks or sets anything off, fire that
## jumped does not jump again, bosses do not freeze nor stun, Fraqueza stops at 40%, speed at +50%, recharge at 30%,
## crit chance at 60% and its multiplier at 250%.
##
## Blessings V2 (docs/design/bencaos_v2/IMPLEMENTACAO_V2.md): Veneno, Sangramento, Eletrificação with Descarga, the anticipation
## of a DoT, one propagation, the Abertura of a boss or guardian, and the lineage (CelChain, CelRules.EDGES) with its budget, so
## no reaction ever feeds on itself.

const CEL_TAG := &"cel"

var combat: Combat
## The game (null in a bare Combat): the player, the Magia and the speed come through it.
var game: Game
var _rng := RandomNumberGenerator.new()
var _tracked: Array[Enemy] = []
var _echoes: Array[Dictionary] = []
## Cadência: stacks and seconds left; Turbilhão's recharge.
var cadence := 0
var cadence_t := 0.0
var _whirl_cd := 0.0
## Vendaval: seconds left and what it gives.
var haste_t := 0.0
var _haste_speed := 0.0
var _haste_move := 0.0
var _applied_move := 0.0
## Clarão: seconds left of the armed chance, and the action it was spent on (0: not yet).
var clarao_t := 0.0
var _clarao_key := 0
## Luz Crescente: stacks and seconds left.
var luz := 0
var luz_t := 0.0
## Passo Firme: its recharge, seconds of the shield it lent and whether that shield is still ours.
var guard_cd := 0.0
var guard_t := 0.0
var _guard_ours := false
## Essência Restauradora's recharge, Cristais Errantes' and the Brado's echo (and the action it covers).
var mana_cd := 0.0
var crystal_cd := 0.0
var _q_echo_cd := 0.0
var _q_echo_key := 0
## Exército de Ecos: seconds left.
var army_t := 0.0
## Blessings V2: the lineage budget (reactions spent by action, the last CelRules.ACTIONS_KEPT actions, and in this frame), the
## DoT tick clock, what the last direct hit did (its crit and whether it shattered), the button before this one (Fluxo
## Contínuo), the seconds of the next Impact that Amparo strengthens, and the copies of each gust.
var _spent: Dictionary = {}
var _spent_order: Array[int] = []
var _frame_spent := 0
var _tick_t := 0.0
var _hit_crit := 1.0
var _hit_shattered := false
var _last_slot := Boon.Slot.NONE
var guard_bonus_t := 0.0
var _gusts: Dictionary = {}
## What happened (tests and the RESULT): how many times each effect went off.
var tally: Dictionary = {}


func _init(c: Combat = null) -> void:
	combat = c
	Dev.seed_rng(_rng, 11)


## The tally as the RESULT prints it (string keys: how many times each effect went off in the run).
func report() -> Dictionary:
	var out := {}
	for k: Variant in tally:
		out[String(k)] = tally[k]
	return out


func _count(what: StringName) -> void:
	tally[what] = int(tally.get(what, 0)) + 1


## True when the hero holds any Blessing of the V1 catalog (everything below returns at once when not).
func active() -> bool:
	return combat != null and combat.boons != null and combat.boons.celestial_held()


func _slot(stat: StringName, slot: Boon.Slot) -> float:
	return combat.boons.slot_stat(stat, slot)


func _glob(stat: StringName) -> float:
	return combat.boons.stat(stat)


func state_of(e: Enemy) -> CelState:
	if e.cel == null:
		e.cel = CelState.new()
		_tracked.append(e)
	return e.cel


func _is_boss(e: Enemy) -> bool:
	return e.def.behavior == EnemyDef.Behavior.BOSS


# ---------- time ----------

func step(dt: float) -> void:
	_whirl_cd = maxf(0.0, _whirl_cd - dt)
	mana_cd = maxf(0.0, mana_cd - dt)
	crystal_cd = maxf(0.0, crystal_cd - dt)
	_q_echo_cd = maxf(0.0, _q_echo_cd - dt)
	guard_cd = maxf(0.0, guard_cd - dt)
	clarao_t = maxf(0.0, clarao_t - dt)
	if clarao_t <= 0.0:
		_clarao_key = 0
	army_t = maxf(0.0, army_t - dt)
	if cadence > 0:
		cadence_t -= dt
		if cadence_t <= 0.0:
			cadence = 0
	if luz > 0:
		luz_t -= dt
		if luz_t <= 0.0:
			luz = 0
	if haste_t > 0.0:
		haste_t -= dt
	guard_bonus_t = maxf(0.0, guard_bonus_t - dt)
	_frame_spent = 0
	_step_move()
	_step_guard(dt)
	_step_echoes(dt)
	_tick_t += dt
	var ticking := _tick_t >= CelRules.POISON_TICK - 0.0005  # (sixty steps of a second are half a second twice, floats aside)
	if ticking:
		_tick_t = maxf(0.0, _tick_t - CelRules.POISON_TICK)
	var i := _tracked.size() - 1
	while i >= 0:
		var e := _tracked[i]
		if not e.alive or e.cel == null:
			e.cold_slow = 0.0
			_tracked.remove_at(i)
		else:
			var st := e.cel
			st.step(dt)
			if e.burn_t <= 0.0:
				st.burn_apps = 0
			e.cold_slow = CelRules.slow_of(st.cold, 0.10 + _glob(&"cel_slow_add")) if st.cold > 0 else 0.0
			if ticking:
				_tick(e, st)
		i -= 1


## The player's speed bonus: the Blessings' (move_speed_pct, read by Game) plus Vendaval's while it lasts.
func _step_move() -> void:
	if game == null or game.player == null:
		return
	var want := _haste_move if haste_t > 0.0 else 0.0
	if want != _applied_move:
		_applied_move = want
		game.player.speed_bonus = combat.boons.stat(&"move_speed_pct") + want


## Game took a Blessing: the speed bonus is read again with Vendaval's share kept.
func refresh_move() -> void:
	_applied_move = -1.0


## The speed bonus the Blessing layer gives the move with these tags (HeroGifts adds it to the Gifts').
func attack_speed(tags: Array[StringName]) -> float:
	if not active():
		return 0.0
	var slot := CelRules.slot_of(tags)
	if slot != Boon.Slot.ATTACK and slot != Boon.Slot.SPECIAL and slot != Boon.Slot.CAST:
		return 0.0
	var sum := _slot(&"cel_speed", slot)
	sum += cadence * _glob(&"cel_cadence")
	if haste_t > 0.0:
		sum += _haste_speed
	return CelRules.speed_bonus(sum)


## The share of a move's recharge the Blessings take off (the Brado's: Poder da Tempestade).
func cooldown_cut(tags: Array[StringName]) -> float:
	if not active() or CelRules.slot_of(tags) != Boon.Slot.CAST:
		return 0.0
	return CelRules.cooldown_cut(_slot(&"cel_cd_cut", Boon.Slot.CAST))


## The factor a direct hit on `e` is dealt with: what the target's state gives (weakened, stunned or in the Abertura, frozen to
## shatter) and the Blessing crit. 1.0 for anything else. Weakness and the Abertura add up with the others (one sum).
func direct_mult(e: Enemy, tags: Array[StringName]) -> float:
	var slot := CelRules.slot_of(tags)
	var key := combat.kill_blow
	var mult := 1.0
	var st := e.cel
	if e.weak_t > 0.0:
		mult += _glob(&"cel_weak_dmg_pct")
		var per := _glob(&"cel_weak_div")
		if per > 0.0:
			mult += per * minf(state_of(e).diversity(e), CelRules.DIVERSITY_CAP)
	var open := st != null and st.window_t > 0.0
	if e.stun_t > 0.0 or open:
		mult += _glob(&"cel_stunned_dmg_pct")
	if open:
		mult += CelRules.WINDOW_VULN
	if st != null and st.shatterable():
		var more := _glob(&"cel_shatter_pct") + _slot(&"cel_slot_shatter", slot)
		if more > 0.0:
			mult += more
			st.shattered = true
			_hit_shattered = true
			_count(&"shatter")
			combat.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
	_hit_crit = _crit(slot, key)
	return mult * _hit_crit


## A Blessing's own blow (a meteor of Peso do Inverno) also shatters a frozen enemy when its Blessing says so. The factor of it.
func skill_mult(e: Enemy, tags: Array[StringName]) -> float:
	if e.cel == null or not e.cel.shatterable() or tags.size() < 3 or not active():
		return 1.0
	var b := combat.boons.find(tags[2])
	if b == null or b.slot == Boon.Slot.NONE:
		return 1.0
	var more := _slot(&"cel_slot_shatter", b.slot)
	if more <= 0.0:
		return 1.0
	e.cel.shattered = true
	_count(&"shatter")
	combat.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
	return 1.0 + more


## The crit of a direct hit (1.0: none). The chance is only the Blessings' (zero without a source), rolled once a hit.
func _crit(slot: Boon.Slot, key: int) -> float:
	var chance := _slot(&"cel_crit", slot) + _glob(&"cel_crit_global")
	if clarao_t > 0.0:
		if _clarao_key != 0 and key != _clarao_key:
			clarao_t = 0.0
			_clarao_key = 0
		else:
			_clarao_key = key if key != 0 else -1
			chance += _slot(&"cel_crit", Boon.Slot.DASH)
	if chance <= 0.0:
		return 1.0
	return _roll(chance, _slot(&"cel_crit_mult", slot))


## One die against a chance; the factor of the hit and, when it crits, the Luz Crescente stacks.
func _roll(chance: float, mult_bonus: float) -> float:
	if not CelRules.crits(chance, _rng.randf()):
		return 1.0
	var stack := _glob(&"cel_crit_stack")
	var bonus := mult_bonus + _glob(&"cel_crit_mult_global") + luz * stack
	if stack > 0.0:
		luz = mini(luz + 1, CelRules.LUZ_STACKS)
		luz_t = CelRules.LUZ_TIME
	_count(&"crit")
	return CelRules.crit_mult(bonus)


## A crit rolled for a Blessing's own ray (Julgamento da Luz: its chance is the Blessing's).
func skill_crit(chance: float) -> float:
	return _roll(chance + _glob(&"cel_crit_global"), 0.0) if active() else 1.0


# ---------- the lineage and its budget ----------

## The next event of a reaction: the chain it follows enters `kind` (the table of CelRules.EDGES, depth three) and the budget of
## the target, action and frame is spent. null (counted in `blocked`) when it may not or there is nothing left to spend.
func _go(chain: CelChain, kind: StringName) -> CelChain:
	var next := chain.enter(kind)
	if next == null:
		_count(&"blocked")
		return null
	if _frame_spent >= CelRules.FRAME_REACT_CAP:
		_count(&"blocked")
		return null
	if chain.action != 0:
		var n := int(_spent.get(chain.action, 0))
		if n >= CelRules.ACTION_REACT_CAP:
			_count(&"blocked")
			return null
		if n == 0:
			_spent_order.append(chain.action)
			if _spent_order.size() > CelRules.ACTIONS_KEPT:
				_spent.erase(_spent_order.pop_front())
		_spent[chain.action] = n + 1
	_frame_spent += 1
	return next


## A hit that came of no action of the hero's (a zone, a skill): its own root event.
func _root(chain: CelChain, key: int) -> CelChain:
	return chain if chain != null else CelChain.new(key)


# ---------- a direct hit ----------

## After a direct hit landed (dmg: what it dealt; shut: the guard shut it): the statuses of the action's Blessings and the echo
## of it. Nothing sticks to a blow that dealt nothing, died or was shut by a guard (a state comes only of a blow that hurts).
func after_hit(e: Enemy, tags: Array[StringName], dmg: float, died: bool, shut := false) -> void:
	var shattered := _hit_shattered
	_hit_shattered = false
	var crit := _hit_crit
	_hit_crit = 1.0
	var key := combat.kill_blow
	var chain := CelChain.new(key)
	if shattered:
		_shatter(e, dmg, chain)
	if died or not e.alive or shut or dmg <= 0.0:
		return
	var slot := CelRules.slot_of(tags)
	var held := DealtBy.source(tags) == &"omega_attack"
	var strong := crit > 1.0 and _glob(&"cel_crit_apply") > 0.0
	var apply_mult := 1.0 + (CelRules.CRIT_APPLY if strong else 0.0)
	var extra := 1 if strong else 0
	var st := state_of(e)
	# the anticipation first, so what was there is paid before the new application renews it
	var antic := _slot(&"cel_antic", slot)
	if antic > 0.0:
		_antic(e, antic, false, chain)
	var force := _slot(&"cel_force_discharge", slot)
	if force > 0.0 and st.shock >= CelRules.DISCHARGE_FORCE:
		_discharge(e, chain)
	var burn := _slot(&"cel_burn_dps", slot)
	if burn > 0.0:
		apply_burn(e, CelRules.hold_rate(burn, held) * apply_mult, key, chain)
	var poison := _slot(&"cel_poison", slot)
	if poison > 0.0:
		apply_poison(e, roundi(CelRules.hold_count(poison, held)) + extra, key, _slot(&"cel_poison_dps", slot) * apply_mult, &"hit", 0.0, chain)
	var charges := _slot(&"cel_shock", slot)
	if charges > 0.0:
		apply_shock(e, roundi(CelRules.hold_count(charges, held)) + extra, key, _slot(&"cel_shock_zap", slot), &"hit", 0.0, chain)
	var share := _bleed_share(e, st, slot, crit)
	if share > 0.0:
		apply_bleed(e, CelRules.hold_rate(share, held) * apply_mult, dmg, key)
	var cold := _slot(&"cel_cold", slot)
	if cold > 0.0:
		apply_cold(e, roundi(CelRules.hold_count(cold, held)), key)
	var points := _slot(&"cel_impact", slot)
	if points > 0.0:
		apply_impact(e, roundi(CelRules.hold_count(points, held)), key, chain)
	var weak := _slot(&"cel_weak", slot)
	if weak > 0.0:
		apply_weak(e, weak, key)
	var mark := _slot(&"cel_mark", slot)
	if mark > 0.0:
		apply_mark(e, mark)
	_echo(e, state_of(e), slot, key, dmg, chain)


## The share of the blow that bleeds (0: none): the Especial on a marked one, the Supremo's army on a marked one, a crit on a
## marked one that does not bleed yet. The greater of them, with Eco Crescente's more, under its ceiling.
func _bleed_share(e: Enemy, st: CelState, slot: Boon.Slot, crit: float) -> float:
	if st.mark_t <= 0.0:
		return 0.0
	var share := 0.0
	if slot == Boon.Slot.SPECIAL:
		share = _slot(&"cel_bleed", slot)
	if army_t > 0.0:
		share = maxf(share, _slot(&"cel_bleed", Boon.Slot.ULT))
	if crit > 1.0 and st.bleed_t <= 0.0:
		share = maxf(share, _glob(&"cel_bleed_crit"))
	return share * (1.0 + _glob(&"cel_bleed_pct")) if share > 0.0 else 0.0


func apply_burn(e: Enemy, dps: float, key: int, chain: CelChain = null) -> void:
	if e.invulnerable or not state_of(e).once(&"burn", key):
		return
	var st := e.cel
	var more := 1.0 + _glob(&"cel_burn_dps_pct")
	var per := _glob(&"cel_burn_div")
	if per > 0.0:
		var others := st.diversity(e) - (1 if e.burn_t > 0.0 else 0)  # (the condition of the Blessing itself is not "another")
		more += per * minf(maxi(others, 0), CelRules.DIVERSITY_CAP)
	combat.burn_for(e, dps * more, Combat.BURN_TIME * (1.0 + _glob(&"cel_burn_time_pct")))
	st.no_spread = false
	_count(&"burn")
	var boom := _glob(&"cel_combust_dmg")
	if boom > 0.0:
		st.burn_apps += 1
		if st.burn_apps >= CelRules.COMBUST_APPS and st.combust_cd <= 0.0:
			st.burn_apps = 0
			st.combust_cd = CelRules.COMBUST_CD
			var c := _go(_root(chain, key), &"combust")
			if c != null:
				_combust(e, boom, c)


## Combustão: the fire bursts on the target (and half of it on up to four round it), and may bring forward a share of what its
## conditions still owed.
func _combust(e: Enemy, boom: float, chain: CelChain) -> void:
	combat.fx.burst(&"fire", Vector3(e.pos.x, 1.0, e.pos.y))
	_secondary(e, boom, &"combustao", Combat.FIRE)
	_count(&"combustion")
	for o in _neighbours(e, CelRules.COMBUST_SPLASH_RADIUS, CelRules.REACT_TARGETS - 1):
		_secondary(o, boom * 0.5, &"combustao", Combat.FIRE)
	var share := _glob(&"cel_antic_all")
	if share > 0.0:
		_antic(e, share, true, chain)


## Fire from a Blessing's zone (the same Blessings' time and strength; no Combustão count: a zone is no application).
func zone_burn(e: Enemy, dps: float) -> void:
	if e.invulnerable:
		return
	combat.burn_for(e, dps * (1.0 + _glob(&"cel_burn_dps_pct")), Combat.BURN_TIME * (1.0 + _glob(&"cel_burn_time_pct")))
	state_of(e).no_spread = false


## Frio: `stacks`, once for an action and target. source and gap: a periodic source (the flakes) puts more on the same
## target only every `gap` seconds. A boss does not freeze nor slow: its stacks fill the meter of the Abertura.
func apply_cold(e: Enemy, stacks: int, key: int, source: StringName = &"", gap := 0.0) -> void:
	if stacks <= 0 or e.invulnerable:
		return
	var st := state_of(e)
	if gap > 0.0 and not st.ready(StringName("cold_" + String(source)), gap):
		return
	if not st.once(&"cold", key):
		return
	if _is_boss(e):
		_meter(e, &"c", stacks)
		return
	var more := 1.0 + _glob(&"cel_cold_time_pct")
	var freeze := st.add_cold(stacks, CelRules.COLD_WINDOW * more, CelRules.FREEZE_TIME * more)
	e.cold_slow = CelRules.slow_of(st.cold, 0.10 + _glob(&"cel_slow_add"))
	_count(&"cold")
	if freeze > 0.0:
		e.frozen_t = maxf(e.frozen_t, freeze * (0.4 if e.def.heavy else 1.0))
		combat.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
		_count(&"freeze")
		var keep := _glob(&"cel_cold_keep")
		if keep > 0.0:
			extend(e, keep, CelRules.EXTEND_CAP)  # (once a freeze: the immunity after it stops the cycle)


## Impacto: points for a common enemy (elites do not count, a boss never stuns); a boss or a guardian takes them into the meter.
func apply_impact(e: Enemy, points: int, key: int, chain: CelChain = null) -> void:
	if points <= 0 or e.invulnerable:
		return
	var meter := CelRules.meter_target(e.def)
	if not meter and not Combat.is_common(e.def):
		return
	var st := state_of(e)
	if not st.once(&"impact", key):
		return
	if _glob(&"cel_cold_impact") > 0.0 and (st.cold > 0 or st.meter_c > 0):
		points += 1
	if guard_bonus_t > 0.0:
		points += roundi(_glob(&"cel_guard_impact"))
		guard_bonus_t = 0.0
	if meter:
		_meter(e, &"i", points)
		return
	var need := maxi(1, CelRules.IMPACT_NEED + roundi(_glob(&"cel_impact_need")))
	var window := CelRules.IMPACT_WINDOW * (1.0 + _glob(&"cel_impact_time_pct"))
	_count(&"impact")
	if st.add_impact(points, window, need):
		combat.horde.flinch(e, CelRules.STUN_TIME)
		combat.fx.burst(&"dust", Vector3(e.pos.x, 1.0, e.pos.y))
		_count(&"stun")
		_rupture(e, st, _root(chain, key))


## A stun of Impacto: Ruptura brings forward a share of the conditions, Força Inabalável passes a point on to three round it.
func _rupture(e: Enemy, st: CelState, chain: CelChain) -> void:
	var c := _go(chain, &"rupture")
	if c == null:
		return
	var share := _glob(&"cel_stun_antic")
	if share > 0.0:
		_antic(e, share, true, c)
	if _glob(&"cel_stun_pulse") > 0.0 and st.ready(&"pulse", CelRules.PULSE_COOLDOWN):
		var p := _go(c, &"pulse")
		if p != null:
			for o in _neighbours(e, CelRules.PULSE_RADIUS, CelRules.PULSE_TARGETS):
				apply_impact(o, 1, 0, p)
			_count(&"pulse")


func apply_weak(e: Enemy, seconds: float, key: int) -> void:
	if e.invulnerable or not state_of(e).once(&"weak", key):
		return
	var was := e.weak_t > 0.0
	combat.weaken(e, seconds * (1.0 + _glob(&"cel_weak_time_pct")))
	_count(&"weak")
	var more := _glob(&"cel_weak_extend")
	if was and more > 0.0 and e.cel.ready(&"weak_extend", CelRules.WEAK_EXTEND_GAP):
		extend(e, more, CelRules.WEAK_EXTEND_CAP)


## A weakening skill landed (Crepúsculo): the conditions on the enemy last longer, once a casting.
func after_weak(e: Enemy, tags: Array[StringName]) -> void:
	if not active() or e.invulnerable or tags.size() < 3:
		return
	var b := combat.boons.find(tags[2])
	if b == null or b.slot == Boon.Slot.NONE:
		return
	var more := _slot(&"cel_extend", b.slot)
	if more > 0.0:
		extend(e, more, CelRules.EXTEND_CAP)


## The conditions on `e` (burn, poison, bleed, frost, mark; never the Fraqueza that asks for it) last `seconds` longer, none past `cap`
## seconds left (what already lasts longer is never cut).
func extend(e: Enemy, seconds: float, cap: float) -> void:
	var st := state_of(e)
	if e.burn_t > 0.0:
		e.burn_t = maxf(e.burn_t, minf(e.burn_t + seconds, cap))
	if st.poison > 0:
		st.poison_t = maxf(st.poison_t, minf(st.poison_t + seconds, cap))
	if st.bleed_pool > 0.0:
		st.bleed_t = maxf(st.bleed_t, minf(st.bleed_t + seconds, cap))
	if st.cold > 0:
		st.cold_t = maxf(st.cold_t, minf(st.cold_t + seconds, cap))
	if st.mark_t > 0.0:
		st.mark_t = maxf(st.mark_t, minf(st.mark_t + seconds, cap))
	_count(&"extend")


func apply_mark(e: Enemy, seconds: float) -> void:
	if e.invulnerable:
		return
	var st := state_of(e)
	if st.mark_t <= 0.0:
		combat.fx.burst(&"dust", Vector3(e.pos.x, 1.4, e.pos.y))
	st.mark_t = maxf(st.mark_t, seconds * (1.0 + _glob(&"cel_mark_time_pct")))
	_count(&"mark")


# ---------- Veneno (Zerael) ----------

## Veneno: `stacks` of `dps` each, once for an action and target (a periodic source, `gap` seconds on the same one). One clock
## for all the stacks: a new application only returns it to its full time (a boss and a guardian take it too).
func apply_poison(e: Enemy, stacks: int, key: int, dps: float, source: StringName = &"", gap := 0.0, chain: CelChain = null) -> void:
	if stacks <= 0 or e.invulnerable:
		return
	var st := state_of(e)
	if gap > 0.0 and not st.ready(StringName("poison_" + String(source)), gap):
		return
	if not st.once(&"poison", key):
		return
	var time := CelRules.POISON_TIME * (1.0 + _glob(&"cel_poison_time_pct"))
	st.add_poison(stacks, time, dps)
	_count(&"poison")
	if st.poison >= CelRules.POISON_MAX:
		_saturate(e, st, _root(chain, key))


## Saturação: five stacks burst the enemy (and half of it on up to four round it), two stacks go; a recharge on the target.
func _saturate(e: Enemy, st: CelState, chain: CelChain) -> void:
	var boom := _glob(&"cel_sat_dmg")
	if boom <= 0.0 or st.sat_cd > 0.0:
		return
	var c := _go(chain, &"saturate")
	if c == null:
		return
	st.poison -= CelRules.SAT_COST
	st.sat_cd = CelRules.SAT_COOLDOWN
	combat.fx.burst(&"dust", Vector3(e.pos.x, 1.0, e.pos.y))
	_secondary(e, boom, &"saturacao", Combat.PLAGUE)
	for o in _neighbours(e, CelRules.SAT_RADIUS, CelRules.SAT_TARGETS):
		_secondary(o, boom * CelRules.SAT_SPLASH, &"saturacao", Combat.PLAGUE)
	_count(&"saturate")


# ---------- Sangramento (Qeshael) ----------

## Sangramento: `share` of the blow's damage (`dmg`, its crit counted) falls over BLEED_TIME. A direct blow only, once an action.
func apply_bleed(e: Enemy, share: float, dmg: float, key: int) -> void:
	if share <= 0.0 or dmg <= 0.0 or e.invulnerable or not state_of(e).once(&"bleed", key):
		return
	e.cel.add_bleed(CelRules.bleed_add(share, dmg))
	_count(&"bleed")


# ---------- Eletrificação and Descarga (Saarael, thunder) ----------

## Eletrificação: `charges`, once for an action and target, and a spark of `zap` damage a charge right away. A boss takes charges
## too (and is never stunned by them).
func apply_shock(e: Enemy, charges: int, key: int, zap: float, source: StringName = &"", gap := 0.0, chain: CelChain = null) -> void:
	if charges <= 0 or e.invulnerable:
		return
	var st := state_of(e)
	if gap > 0.0 and not st.ready(StringName("shock_" + String(source)), gap):
		return
	if not st.once(&"shock", key):
		return
	st.add_shock(charges)
	_count(&"shock")
	if zap > 0.0:
		_secondary(e, zap * charges, &"faisca", Combat.VOLT)
	if e.alive and st.shock >= CelRules.SHOCK_MAX:
		_discharge(e, _root(chain, key))


## Descarga: five charges (or three, forced by the Peso do Trovão) go off as electric damage a charge, with the resonance of
## the charged round it; Condução makes it jump (without charges). A recharge on the target.
func _discharge(e: Enemy, chain: CelChain) -> void:
	var per := _glob(&"cel_discharge")
	var st := state_of(e)
	if per <= 0.0 or st.shock <= 0 or st.discharge_cd > 0.0:
		return
	var c := _go(chain, &"discharge")
	if c == null:
		return
	var n := st.shock
	st.shock = 0
	st.over_acc = 0.0
	st.discharge_cd = CelRules.DISCHARGE_CD
	var charged := 0
	var reson := _glob(&"cel_reson")
	if reson > 0.0:
		for o in _neighbours(e, CelRules.DISCHARGE_REACH, CelRules.RESON_MAX + 8):
			if o.cel != null and o.cel.shock > 0:
				charged += 1
	var dmg := CelRules.discharge_dmg(per, n, reson, charged)
	combat.fx.burst(&"light", Vector3(e.pos.x, 1.0, e.pos.y))
	_secondary(e, dmg, &"descarga", Combat.VOLT)
	_count(&"discharge")
	var jumps := clampi(roundi(_glob(&"cel_conduct")), 0, CelRules.RESON_MAX)
	if jumps > 0:
		var j := _go(c, &"conduct")
		if j != null:
			for o in _neighbours(e, CelRules.CONDUCT_RADIUS, jumps):
				_secondary(o, dmg * CelRules.CONDUCT_SHARE, &"conducao", Combat.VOLT)
			_count(&"conduct")


# ---------- the DoTs, each half second ----------

## One tick of the DoTs of an enemy (every CelRules.POISON_TICK): the poison and the bleed deal their share (never the three
## together past DOT_DPS_CAP: the burn is the game's and counts, the others shrink), the clocks run, the deterioration grows and
## Sobrecarga charges whoever is charged and burns, bleeds or is poisoned.
func _tick(e: Enemy, st: CelState) -> void:
	var step := CelRules.POISON_TICK
	var burn := e.burn_dps if e.burn_t > 0.0 else 0.0
	if st.poison > 0:
		st.poison_age += step * (2.0 if (e.burn_t > 0.0 or st.bleed_t > 0.0) else 1.0)
	var grow := minf(_glob(&"cel_poison_grow") * st.poison_age, CelRules.POISON_GROW_MAX) if st.poison > 0 else 0.0
	var poison_rate := st.poison * st.poison_dps * (1.0 + grow) if st.poison > 0 else 0.0
	var bleed_rate := st.bleed_pool / st.bleed_t if st.bleed_t > 0.0 else 0.0
	var scale := CelRules.dot_scale(burn, poison_rate, bleed_rate)
	if st.poison > 0:
		var hurt := CelRules.poison_tick(st.poison, st.poison_dps * scale, grow)
		_dot(e, hurt, &"veneno", Combat.PLAGUE)
		var slow := 0.5 if (_glob(&"cel_poison_cold") > 0.0 and (st.cold > 0 or e.frozen_t > 0.0)) else 1.0
		st.poison_t -= step * slow
		if st.poison_t <= 0.0:
			st.clear_poison()
	if st.bleed_t > 0.0:
		_dot(e, st.bleed_tick(step) * scale, &"sangramento", Combat.BLEED)
	if e.alive and st.shock > 0 and (e.burn_t > 0.0 or st.poison > 0 or st.bleed_t > 0.0):
		var rate := _glob(&"cel_overload")
		if rate > 0.0:
			st.over_acc += rate * step
			if st.over_acc >= 1.0:
				var n := int(st.over_acc)
				st.over_acc -= n
				st.add_shock(n)
				_count(&"overload")
				if st.shock >= CelRules.SHOCK_MAX:
					var c := CelChain.new(0, &"tick").enter(&"overload")
					if c != null:
						_discharge(e, c)


## A tick of a DoT: damage that is no blow (no flash, no flinch, nothing of the layer sets off on it).
func _dot(e: Enemy, amount: float, source: StringName, color: Color) -> void:
	if not e.alive or e.invulnerable or amount <= 0.0:
		return
	var horde := combat.horde
	horde.dealing = source
	horde.damage(e, amount, Vector2.ZERO, 0.0, color, amount >= 1.0, false, false)
	horde.dealing = &""


# ---------- the Abertura of a boss or guardian ----------

## Points of Frio (a boss) or Impacto (a boss or guardian) fill the meter; when it fills, the Abertura opens for WINDOW_TIME and
## the meters rest a while. Nothing of the enemy's own (poise, frost, stun, scripts) is touched.
## Points that fill the Impacto's meter (the HUD's dots read it).
func impact_need() -> int:
	return maxi(1, CelRules.METER_IMPACT + 2 * roundi(_glob(&"cel_impact_need")))


func _meter(e: Enemy, kind: StringName, points: int) -> void:
	var st := state_of(e)
	var need := CelRules.METER_COLD if kind == &"c" else impact_need()
	if st.add_meter(kind, points, need):
		combat.fx.burst(&"dust", Vector3(e.pos.x, 1.6, e.pos.y))
		_count(&"window")


# ---------- anticipation and propagation ----------

## Brings forward `share` of what the conditions on `e` still owed (only the burn, or all of them: burn, poison, bleed) as one
## damage, and takes the same share out of them: nothing is paid twice. Once an action and target, a recharge between.
func _antic(e: Enemy, share: float, all: bool, chain: CelChain) -> void:
	if share <= 0.0 or not e.alive or e.invulnerable:
		return
	var st := state_of(e)
	var owed := e.burn_dps * e.burn_t if e.burn_t > 0.0 else 0.0
	if all:
		owed += st.poison * st.poison_dps * st.poison_t + st.bleed_pool
	if owed <= 0.0 or not st.once(&"antic", chain.action) or not st.ready(&"antic", CelRules.ANTIC_COOLDOWN):
		return
	var c := _go(chain, &"antic")
	if c == null:
		return
	var paid := 0.0
	if e.burn_t > 0.0:
		var r := CelRules.anticipate(e.burn_dps * e.burn_t, share)
		paid += r[0]
		e.burn_t *= 1.0 - clampf(share, 0.0, 1.0)
	if all:
		if st.poison > 0:
			var rp := CelRules.anticipate(st.poison * st.poison_dps * st.poison_t, share)
			paid += rp[0]
			st.poison_t *= 1.0 - clampf(share, 0.0, 1.0)
		if st.bleed_pool > 0.0:
			var rb := CelRules.anticipate(st.bleed_pool, share)
			paid += rb[0]
			st.bleed_pool = rb[1]
	_secondary(e, paid, &"antecipacao", Combat.FIRE)
	_count(&"antic")


## The nearest `n` living enemies within `radius` of `e` (never `e`, never a ward).
func _neighbours(e: Enemy, radius: float, n: int) -> Array[Enemy]:
	var near: Array[Enemy] = []
	combat.horde.in_circle(e.pos, radius, near)
	var out: Array[Enemy] = []
	for o in near:
		if o != e and o.alive and not o.invulnerable:
			out.append(o)
	out.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.pos.distance_squared_to(e.pos) < b.pos.distance_squared_to(e.pos))
	return out.slice(0, n)


## Copies a share of `src`'s DoTs (burn: its DPS; poison: its stacks; bleed: its pool) to `dst` that lacks them, with half the
## time left (at least CelRules.COPY_MIN_TIME), and locks `dst` so a copy never copies. `only`: one kind (&"poison"), or all.
## Returns true when something went over.
func _copy_dots(src: Enemy, dst: Enemy, share: float, only: StringName = &"") -> bool:
	var ss := state_of(src)
	var ds := state_of(dst)
	if ds.copy_lock > 0.0 or ss.copy_lock > 0.0 or dst.invulnerable or not dst.alive:
		return false  # (what a copy put here does not copy: the lock is on both ends)
	var any := false
	if (only == &"" or only == &"burn") and src.burn_t > 0.0 and dst.burn_t <= 0.0:
		combat.burn_for(dst, src.burn_dps * share, maxf(CelRules.COPY_MIN_TIME, src.burn_t * 0.5))
		ds.no_spread = true
		any = true
	if (only == &"" or only == &"poison") and ss.poison > 0 and ds.poison <= 0:
		ds.add_poison(maxi(1, roundi(ss.poison * share)), maxf(CelRules.COPY_MIN_TIME, ss.poison_t * 0.5), ss.poison_dps)
		any = true
	if (only == &"" or only == &"bleed") and ss.bleed_pool > 0.0 and ds.bleed_pool <= 0.0:
		ds.bleed_pool = ss.bleed_pool * share
		ds.bleed_t = maxf(CelRules.COPY_MIN_TIME, ss.bleed_t * 0.5)
		any = true
	if any:
		ds.copy_lock = CelRules.COPY_LOCK
		_count(&"copy")
	return any


## Copies to the nearest neighbours of `src` (up to `n` of them within `radius`) that take it. Returns how many did.
func _copy_to_neighbours(src: Enemy, share: float, radius: float, n: int, only: StringName = &"") -> int:
	var done := 0
	for o in _neighbours(src, radius, CelRules.REACT_TARGETS * 3):
		if done >= n:
			break
		if _copy_dots(src, o, share, only):
			done += 1
	return done


## Galael's gust landed on `e` (status spread of Peso do Maré): it passes `share` of its conditions to one neighbour, up to four
## copies a gust (the shot's id is its action).
func spread(e: Enemy, share: float, action: int) -> void:
	if not active() or share <= 0.0 or e.invulnerable:
		return
	var used := int(_gusts.get(action, 0))
	if used >= CelRules.GUST_COPIES:
		return
	if _go(CelChain.new(action), &"copy") == null:
		return
	if _copy_to_neighbours(e, share, CelRules.GUST_RADIUS, 1) > 0:
		if _gusts.size() > 8:
			_gusts.clear()
		_gusts[action] = used + 1


## Estilhaçamento's shatter happened with a direct blow: fragments of it fall on up to three round, and the frost jumps (and
## a share of the DoTs with it). `dmg`: what the blow dealt.
func _shatter(e: Enemy, dmg: float, chain: CelChain) -> void:
	var c := _go(chain, &"shatter")
	if c == null:
		return
	var frag := _glob(&"cel_shatter_frag")
	if frag > 0.0:
		var f := _go(c, &"frag")
		if f != null:
			for o in _neighbours(e, CelRules.FRAG_RADIUS, CelRules.FRAG_TARGETS):
				_secondary(o, dmg * frag, &"estilhaco", Combat.FROST)
			_count(&"frag")
	if _glob(&"cel_crystal") > 0.0 and crystal_cd <= 0.0:
		var k := _go(c, &"crystal")
		if k != null:
			_crystals(e, _glob(&"cel_crystal_dot"))


# ---------- echoes ----------

func _echo(e: Enemy, st: CelState, slot: Boon.Slot, key: int, dmg: float, chain: CelChain) -> void:
	var cut := 1.0 - minf(_glob(&"cel_echo_cd_cut"), 0.5)
	var share := 0.0
	var source := &""
	match slot:
		Boon.Slot.SPECIAL:
			share = _slot(&"cel_echo", slot) if st.mark_t > 0.0 else 0.0
			source = &"special"
		Boon.Slot.CAST:
			share = _slot(&"cel_echo", slot)
			source = &"cast"
	var army := _slot(&"cel_echo", Boon.Slot.ULT) if army_t > 0.0 else 0.0
	if army > share:
		share = army
		source = &"army"
	if share <= 0.0:
		return
	if source == &"cast":
		# the Brado's echo: one recharge for the whole action (every one it struck echoes)
		if _q_echo_cd > 0.0 and key != _q_echo_key:
			return
		if key != _q_echo_key:
			_q_echo_cd = CelRules.Q_ECHO_COOLDOWN * cut
		_q_echo_key = key
	elif not st.ready(StringName("echo_" + String(source)), CelRules.ECHO_COOLDOWN * cut):
		return
	if _go(chain, &"echo") == null:
		return
	var more := 1.0 + _glob(&"cel_echo_pct")
	if st.mark_t > 0.0:
		more += _glob(&"cel_echo_marked_pct")
	_echoes.append({"e": e, "dmg": dmg * share * more, "t": CelRules.ECHO_DELAY})
	_count(&"echo")


func _step_echoes(dt: float) -> void:
	var i := _echoes.size() - 1
	while i >= 0:
		var x: Dictionary = _echoes[i]
		x.t = float(x.t) - dt
		if float(x.t) <= 0.0:
			_echoes.remove_at(i)
			var e: Enemy = x.e
			if e.alive and not e.invulnerable:
				_secondary(e, float(x.dmg), &"penumbra_eco", Combat.MARK)
		i -= 1


# ---------- the other events ----------

## An action of the hero's begins (Combat.strike): Cadência counts it. The Investida and the dodge are not counted.
func on_action(node: ComboNode) -> void:
	if not active():
		return
	var slot := CelRules.slot_of(node.tags)
	if slot != Boon.Slot.ATTACK and slot != Boon.Slot.SPECIAL and slot != Boon.Slot.CAST:
		return
	var before := _last_slot
	_last_slot = slot
	if _glob(&"cel_cadence") <= 0.0:
		return
	# Fluxo Contínuo: the action of another button than the one before gives a stack more
	var mix := roundi(_glob(&"cel_cadence_mix")) if before != Boon.Slot.NONE and before != slot else 0
	cadence = mini(cadence + 1 + mix, CelRules.CADENCE_STACKS)
	cadence_t = CelRules.CADENCE_TIME * (1.0 + _glob(&"cel_cadence_time_pct"))
	var whirl := _glob(&"cel_whirl_dmg")
	if cadence >= CelRules.CADENCE_STACKS and whirl > 0.0 and _whirl_cd <= 0.0 and game != null:
		_whirl_cd = CelRules.WHIRL_COOLDOWN
		var p := game.player.pos
		combat.fx.ring(p, CelRules.WHIRL_RADIUS, Combat.TIDE, 0.4)
		var near: Array[Enemy] = []
		combat.horde.in_circle(p, CelRules.WHIRL_RADIUS, near)
		for e in near:
			_secondary(e, whirl, &"turbilhao", Combat.TIDE)
		_count(&"whirl")
		var share := _glob(&"cel_whirl_spread")
		if share > 0.0 and _go(CelChain.new(combat.kill_blow), &"copy") != null:
			var copies := 0
			for e in near:
				if copies >= CelRules.WHIRL_COPIES:
					break
				if e.alive:
					copies += _copy_to_neighbours(e, share, CelRules.GUST_RADIUS, 1)


## The dodge began: Clarão, Passo Firme's shield and Olhar Rápido's marks (the fire's trail and the skills are Game's).
func on_dodge() -> void:
	if not active() or game == null:
		return
	if _slot(&"cel_crit", Boon.Slot.DASH) > 0.0:
		clarao_t = CelRules.CLARAO_TIME  # (never adds: it only renews)
		_clarao_key = 0
		_count(&"clarao")
	var guard := _slot(&"cel_guard_time", Boon.Slot.DASH)
	if guard > 0.0 and guard_cd <= 0.0 and not game.player.shield_ready:
		game.player.shield_ready = true
		_guard_ours = true
		guard_t = guard * (1.0 + _glob(&"cel_guard_time_pct"))
		guard_cd = CelRules.GUARD_COOLDOWN
		combat.fx.burst(&"heal", Vector3(game.player.pos.x, 1.2, game.player.pos.y))
		_count(&"guard")
	var look := _slot(&"cel_mark", Boon.Slot.DASH)
	if look > 0.0:
		var near: Array[Enemy] = []
		combat.horde.in_circle(game.player.pos, _slot(&"cel_radius", Boon.Slot.DASH), near)
		for e in near:
			apply_mark(e, look)


## The shield Passo Firme lent runs out when unused; one that was taken (or spent on a blow) is gone already.
func _step_guard(dt: float) -> void:
	if not _guard_ours or game == null:
		return
	if not game.player.shield_ready:
		_guard_ours = false
		if guard_t > 0.0 and _glob(&"cel_guard_impact") > 0.0:
			guard_bonus_t = CelRules.GUARD_IMPACT_TIME  # Amparo: the shield was spent on a blow (not run out)
			_count(&"amparo")
		return
	guard_t -= dt
	if guard_t <= 0.0:
		game.player.shield_ready = false
		_guard_ours = false


## The ultimate fell: Vendaval's haste and Exército de Ecos' window.
func on_ult() -> void:
	if not active():
		return
	var speed := _slot(&"cel_haste_speed", Boon.Slot.ULT)
	if speed > 0.0:
		_haste_speed = speed
		_haste_move = _slot(&"cel_haste_move", Boon.Slot.ULT)
		haste_t = _slot(&"cel_haste_time", Boon.Slot.ULT)
		_count(&"haste")
	var echo_time := _slot(&"cel_echo_time", Boon.Slot.ULT)
	if echo_time > 0.0:
		army_t = echo_time
		_count(&"army")


## An enemy fell (Game): the fire jumps from one that burned, and Essência Restauradora's mana from a weakened one.
func on_killed(e: Enemy) -> void:
	if not active():
		return
	var share := _glob(&"cel_spread_pct")
	var st := e.cel
	if share > 0.0 and e.burn_t > 0.0 and (st == null or not st.no_spread):
		var near: Array[Enemy] = []
		combat.horde.in_circle(e.pos, CelRules.SPREAD_RADIUS, near)
		for o in near:
			if o != e and o.alive and not o.invulnerable:
				combat.burn_for(o, e.burn_dps * share, CelRules.SPREAD_TIME)
				state_of(o).no_spread = true
				_count(&"spread")
	var mana := _glob(&"cel_weak_mana")
	if mana > 0.0 and e.weak_t > 0.0 and mana_cd <= 0.0 and game != null:
		mana_cd = CelRules.MANA_COOLDOWN
		if st != null and st.diversity(e) >= CelRules.DIVERSITY_CAP:
			mana += _glob(&"cel_weak_mana_div")
		game.player.magick.gain(mana)
		_count(&"mana")
	if st == null:
		return
	# Contágio: the poison jumps once, to two near it. Marca Persistente: the Mark passes once to the nearest unmarked
	var root := CelChain.new(0)
	var spread_poison := _glob(&"cel_poison_spread")
	if spread_poison > 0.0 and st.poison > 0 and _go(root, &"copy") != null:
		_copy_to_neighbours(e, spread_poison, CelRules.COPY_RADIUS, 2, &"poison")
	if _glob(&"cel_mark_pass") > 0.0 and st.mark_t > 0.0 and not st.mark_passed:
		for o in _neighbours(e, CelRules.MARK_PASS_RADIUS, 12):
			var os := state_of(o)
			if os.mark_t <= 0.0:
				os.mark_t = st.mark_t
				os.mark_passed = true
				combat.fx.burst(&"dust", Vector3(o.pos.x, 1.4, o.pos.y))
				_count(&"mark_pass")
				break


## Estilhaçamento's frost jumps to the ones round the shattered (Cristais Errantes): one stack each, a recharge between.
func _crystals(e: Enemy, dot_share := 0.0) -> void:
	if _glob(&"cel_crystal") <= 0.0 or crystal_cd > 0.0:
		return
	crystal_cd = CelRules.CRYSTAL_CD
	var near: Array[Enemy] = []
	combat.horde.in_circle(e.pos, CelRules.CRYSTAL_RADIUS, near)
	for o in near:
		if o != e:
			apply_cold(o, roundi(_glob(&"cel_crystal")), 0)
			if dot_share > 0.0:
				_copy_dots(e, o, dot_share)  # Cristais Errantes: a share of the conditions goes with the frost
	_count(&"crystals")


## Damage a Blessing deals on its own: through the horde, never a blow of the hero's (nothing of the layer sets off on it).
func _secondary(e: Enemy, amount: float, source: StringName, color: Color) -> void:
	if not e.alive or e.invulnerable or amount <= 0.0:
		return
	var horde := combat.horde
	var was := horde.stun_scale
	horde.stun_scale = 0.0
	horde.dealing = source
	horde.damage(e, maxf(1.0, roundf(amount)), Vector2.ZERO, 0.0, color)
	horde.dealing = &""
	horde.stun_scale = was
