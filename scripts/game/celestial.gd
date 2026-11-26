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
## What happened (tests and the RESULT): how many times each effect went off.
var tally: Dictionary = {}


func _init(c: Combat = null) -> void:
	combat = c
	Dev.seed_rng(_rng, 11)


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
	_step_move()
	_step_guard(dt)
	_step_echoes(dt)
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


# ---------- a direct hit ----------

## The factor a direct hit on `e` is dealt with: what the target's state gives (weakened, stunned, frozen to shatter) and
## the Blessing crit. 1.0 for anything else.
func direct_mult(e: Enemy, tags: Array[StringName]) -> float:
	var slot := CelRules.slot_of(tags)
	var key := combat.kill_blow
	var mult := 1.0
	if e.weak_t > 0.0:
		mult += _glob(&"cel_weak_dmg_pct")
	if e.stun_t > 0.0:
		mult += _glob(&"cel_stunned_dmg_pct")
	var st := e.cel
	if st != null and st.shatterable():
		var more := _glob(&"cel_shatter_pct")
		if more > 0.0:
			mult += more
			st.shattered = true
			_count(&"shatter")
			combat.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
			_crystals(e)
	return mult * _crit(slot, key)


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


## After a direct hit landed (dmg: what it dealt): the statuses of the action's Blessings and the echo of it.
func after_hit(e: Enemy, tags: Array[StringName], dmg: float, died: bool) -> void:
	if died or not e.alive:
		return
	var slot := CelRules.slot_of(tags)
	var key := combat.kill_blow
	var burn := _slot(&"cel_burn_dps", slot)
	if burn > 0.0:
		apply_burn(e, burn, key)
	var cold := _slot(&"cel_cold", slot)
	if cold > 0.0:
		apply_cold(e, roundi(cold), key)
	var points := _slot(&"cel_impact", slot)
	if points > 0.0:
		apply_impact(e, roundi(points), key)
	var weak := _slot(&"cel_weak", slot)
	if weak > 0.0:
		apply_weak(e, weak, key)
	var mark := _slot(&"cel_mark", slot)
	if mark > 0.0:
		apply_mark(e, mark)
	_echo(e, state_of(e), slot, key, dmg)


func apply_burn(e: Enemy, dps: float, key: int) -> void:
	if e.invulnerable or not state_of(e).once(&"burn", key):
		return
	var st := e.cel
	combat.burn_for(e, dps * (1.0 + _glob(&"cel_burn_dps_pct")), Combat.BURN_TIME * (1.0 + _glob(&"cel_burn_time_pct")))
	st.no_spread = false
	_count(&"burn")
	var boom := _glob(&"cel_combust_dmg")
	if boom > 0.0:
		st.burn_apps += 1
		if st.burn_apps >= CelRules.COMBUST_APPS and st.combust_cd <= 0.0:
			st.burn_apps = 0
			st.combust_cd = CelRules.COMBUST_CD
			combat.fx.burst(&"fire", Vector3(e.pos.x, 1.0, e.pos.y))
			_secondary(e, boom, &"combustao", Combat.FIRE)
			_count(&"combustion")


## Fire from a Blessing's zone (the same Blessings' time and strength; no Combustão count: a zone is no application).
func zone_burn(e: Enemy, dps: float) -> void:
	if e.invulnerable:
		return
	combat.burn_for(e, dps * (1.0 + _glob(&"cel_burn_dps_pct")), Combat.BURN_TIME * (1.0 + _glob(&"cel_burn_time_pct")))
	state_of(e).no_spread = false


## Frio: `stacks`, once for an action and target. source and gap: a periodic source (the flakes) puts more on the same
## target only every `gap` seconds.
func apply_cold(e: Enemy, stacks: int, key: int, source: StringName = &"", gap := 0.0) -> void:
	if stacks <= 0 or e.invulnerable or _is_boss(e):
		return  # a boss does not freeze nor slow (the Blessings leave his scripts alone)
	var st := state_of(e)
	if gap > 0.0 and not st.ready(StringName("cold_" + String(source)), gap):
		return
	if not st.once(&"cold", key):
		return
	var more := 1.0 + _glob(&"cel_cold_time_pct")
	var freeze := st.add_cold(stacks, CelRules.COLD_WINDOW * more, CelRules.FREEZE_TIME * more)
	e.cold_slow = CelRules.slow_of(st.cold, 0.10 + _glob(&"cel_slow_add"))
	_count(&"cold")
	if freeze > 0.0:
		e.frozen_t = maxf(e.frozen_t, freeze * (0.4 if e.def.heavy else 1.0))
		combat.fx.burst(&"frost", Vector3(e.pos.x, 1.0, e.pos.y))
		_count(&"freeze")


## Impacto: points for a common enemy (nothing else is stunned: elites and guardians do not count, a boss never).
func apply_impact(e: Enemy, points: int, key: int) -> void:
	if points <= 0 or e.invulnerable or _is_boss(e) or not Combat.is_common(e.def):
		return
	var st := state_of(e)
	if not st.once(&"impact", key):
		return
	var need := maxi(1, CelRules.IMPACT_NEED + roundi(_glob(&"cel_impact_need")))
	var window := CelRules.IMPACT_WINDOW * (1.0 + _glob(&"cel_impact_time_pct"))
	_count(&"impact")
	if st.add_impact(points, window, need):
		combat.horde.flinch(e, CelRules.STUN_TIME)
		combat.fx.burst(&"dust", Vector3(e.pos.x, 1.0, e.pos.y))
		_count(&"stun")


func apply_weak(e: Enemy, seconds: float, key: int) -> void:
	if e.invulnerable or not state_of(e).once(&"weak", key):
		return
	combat.weaken(e, seconds * (1.0 + _glob(&"cel_weak_time_pct")))
	_count(&"weak")


func apply_mark(e: Enemy, seconds: float) -> void:
	if e.invulnerable:
		return
	var st := state_of(e)
	if st.mark_t <= 0.0:
		combat.fx.burst(&"dust", Vector3(e.pos.x, 1.4, e.pos.y))
	st.mark_t = maxf(st.mark_t, seconds * (1.0 + _glob(&"cel_mark_time_pct")))
	_count(&"mark")


# ---------- echoes ----------

func _echo(e: Enemy, st: CelState, slot: Boon.Slot, key: int, dmg: float) -> void:
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
	if _glob(&"cel_cadence") <= 0.0:
		return
	cadence = mini(cadence + 1, CelRules.CADENCE_STACKS)
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
		game.player.magick.gain(mana)
		_count(&"mana")


## Estilhaçamento's frost jumps to the ones round the shattered (Cristais Errantes): one stack each, a recharge between.
func _crystals(e: Enemy) -> void:
	if _glob(&"cel_crystal") <= 0.0 or crystal_cd > 0.0:
		return
	crystal_cd = CelRules.CRYSTAL_CD
	var near: Array[Enemy] = []
	combat.horde.in_circle(e.pos, CelRules.CRYSTAL_RADIUS, near)
	for o in near:
		if o != e:
			apply_cold(o, roundi(_glob(&"cel_crystal")), 0)
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
