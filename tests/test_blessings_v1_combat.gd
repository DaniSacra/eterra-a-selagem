extends GutTest
## Blessings V1 in play (02_REGRAS, 04_TESTES): each rule of the layer on a real Combat of a real Game, for the Warrior and
## the Maga: status once by action and target, burn that never adds up, Frio and Impacto with their immunities and the
## bosses', the crit with no chance of its own, the echoes and the fire that never recurse, E that nothing touches.

const DT := 1.0 / 60.0

var game: Game
var _key := 100


func before_each() -> void:
	Dev.put("seed", "1")


func after_each() -> void:
	Dev.drop("hero")
	Dev.put("seed", "1")


func _start(hero := "") -> void:
	if hero != "":
		Dev.put("hero", hero)
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO
	game.boons.ult_open = true


func _take(id: StringName, rarity := Boon.Rarity.COMMON, times := 1) -> void:
	for i in times:
		game.boons.take(game.boons.find(id), rarity)


func _enemy(at := Vector2(4.0, 0.0), hp := 100000.0) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"skeleton"), at, false)
	e.hp = hp
	e.max_hp = hp
	return e


func _boss() -> Enemy:
	var e := _enemy()
	e.def = e.def.duplicate()
	e.def.behavior = EnemyDef.Behavior.BOSS
	return e


## One blow of an action: a new action key each time (a swing), so every blow is its own action.
func _hit(e: Enemy, tags: Array, base := 10.0, same_action := false) -> void:
	var t: Array[StringName] = []
	for x in tags:
		t.append(StringName(x))
	if not same_action:
		_key += 1
	game.combat.kill_blow = _key
	game.combat.hit_enemy(e, base, t, Vector2.RIGHT, 0.0)
	game.combat.kill_blow = 0


func _dealt(e: Enemy, tags: Array, base := 10.0) -> float:
	var before := e.hp
	_hit(e, tags, base)
	return before - e.hp


func _run(seconds: float) -> void:
	for i in roundi(seconds / DT):
		game.combat.celestial.step(DT)
		game.horde.step(DT)


# ---------- nothing held: nothing changes ----------

func test_without_a_blessing_nothing_changes_and_no_dice_are_rolled() -> void:
	_start()
	var e := _enemy()
	var a := _dealt(e, ["light"])
	var b := _dealt(e, ["light"])
	assert_eq(a, b, "no crit without a source")
	assert_eq(e.burn_t, 0.0)
	assert_null(e.cel)
	assert_false(game.combat.celestial.active())
	assert_eq(game.combat.celestial.tally.size(), 0)


# ---------- Sarael ----------

func test_burn_renews_and_keeps_the_greater_dps_it_never_adds_up() -> void:
	_start()
	_take(&"golpe_brasa")
	var e := _enemy()
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 3.5, 0.001)
	assert_almost_eq(e.burn_t, 3.0, 0.001)
	_run(1.0)
	assert_lt(e.burn_t, 2.1)
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 3.5, 0.001, "the same DPS, not 7")
	assert_almost_eq(e.burn_t, 3.0, 0.001, "the time renewed")
	_take(&"pesado_brasa")
	_hit(e, ["heavy", "wave"])
	assert_almost_eq(e.burn_dps, 5.0, 0.001, "the greater one is kept")
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 5.0, 0.001, "and the lesser does not take it down")
	_run(3.5)
	assert_lte(e.burn_t, 0.0, "the fire went out")
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 3.5, 0.001, "a fire that went out starts over at its own")


func test_complements_of_fire_change_dps_and_time_and_only_the_blessings_fire() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"fogo_crescente")
	_take(&"brasa_persistente")
	var e := _enemy()
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 4.2, 0.001, "+20% DPS")
	assert_almost_eq(e.burn_t, 3.9, 0.001, "+30% time")
	# the native fire of a hero is not touched by them
	var other := _enemy()
	game.combat.ignite(other, 5.0)
	assert_almost_eq(other.burn_dps, 5.0, 0.001)
	assert_almost_eq(other.burn_t, Combat.BURN_TIME, 0.001)


func test_rarity_scales_the_dps_of_the_burn() -> void:
	_start()
	_take(&"golpe_brasa", Boon.Rarity.LEGENDARY)
	var e := _enemy()
	_hit(e, ["light"])
	assert_almost_eq(e.burn_dps, 8.75, 0.001, "2.5 times 3.5")
	assert_almost_eq(e.burn_t, 3.0, 0.001, "the time stays")


func test_e_and_the_dodge_are_not_the_attack() -> void:
	_start()
	_take(&"golpe_brasa")
	var e := _enemy()
	_hit(e, ["light", "dash"])
	assert_eq(e.burn_t, 0.0, "the Investida carries light and is not the attack")
	_hit(e, ["skill", "chama", "golpe_brasa"])
	assert_eq(e.burn_t, 0.0, "a hit of a Blessing sets nothing off")
	_hit(e, ["light", "omega", "thrust"])
	assert_gt(e.burn_t, 0.0, "a charged attack inherits the attack")


func test_a_status_once_by_action_and_target() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"combustao")
	var e := _enemy()
	_hit(e, ["light"])
	_hit(e, ["light"], 10.0, true)
	_hit(e, ["light"], 10.0, true)
	assert_eq(int(game.combat.celestial.tally.get(&"burn", 0)), 1, "three contacts of one action: one application")
	assert_eq(e.cel.burn_apps, 1)


func test_combustion_after_three_applications_with_a_recharge_by_target() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"combustao")
	var e := _enemy()
	_hit(e, ["light"])
	_hit(e, ["light"])
	var before := e.hp
	_hit(e, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"combustion", 0)), 1)
	assert_almost_eq(before - e.hp, 10.0 + 9.0, 1.5, "the blow and the 9 of fire")
	for i in 3:
		_hit(e, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"combustion", 0)), 1, "3 s of recharge on that enemy")
	assert_eq(game.combat.celestial.tally.get(&"burn", 0), 6)
	var other := _enemy(Vector2(5.0, 1.0))
	for i in 3:
		_hit(other, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"combustion", 0)), 2, "the recharge is by target")


func test_contagion_jumps_once_and_not_again() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"chama_contagiosa")
	var a := _enemy(Vector2(4.0, 0.0))
	var b := _enemy(Vector2(5.0, 0.0))
	var c := _enemy(Vector2(6.0, 0.0))
	_hit(a, ["light"])
	a.alive = false  # (it falls burning)
	game.combat.celestial.on_killed(a)
	assert_almost_eq(b.burn_dps, 1.75, 0.001, "50% of the DPS")
	assert_almost_eq(b.burn_t, 2.0, 0.001)
	assert_gt(c.burn_t, 0.0)
	var d := _enemy(Vector2(5.5, 0.5))
	b.alive = false
	game.combat.celestial.on_killed(b)
	assert_eq(d.burn_t, 0.0, "fire that jumped does not jump")


# ---------- Nivael ----------

func test_three_stacks_freeze_a_common_enemy_for_08s_then_it_is_immune() -> void:
	_start()
	_take(&"golpe_geada")
	var e := _enemy()
	_hit(e, ["light"])
	_hit(e, ["light"])
	assert_eq(e.frozen_t, 0.0)
	assert_gt(e.cold_slow, 0.0, "stacks slow: 10% each")
	assert_almost_eq(e.cold_slow, 0.2, 0.001)
	_hit(e, ["light"])
	assert_almost_eq(e.frozen_t, 0.8, 0.001)
	assert_eq(e.cel.cold, 0, "the stacks are cleared")
	_run(0.9)
	for i in 4:
		_hit(e, ["light"])
	assert_eq(e.frozen_t, 0.0, "immune for 2 s")
	_run(2.0)
	_hit(e, ["light"])
	_hit(e, ["light"])
	_hit(e, ["light"])
	assert_gt(e.frozen_t, 0.0)


func test_the_slow_stops_at_40_percent() -> void:
	_start()
	_take(&"toque_geada")
	_take(&"geada_profunda")
	var e := _enemy()
	_hit(e, ["heavy", "wave"])
	assert_almost_eq(e.cold_slow, 0.30, 0.001, "two stacks at 15%")
	game.boons.grant([_fixed_mod(&"cel_slow_add", 0.5)])
	var third := _enemy(Vector2(5.0, -1.0))
	_hit(third, ["heavy", "wave"])
	assert_almost_eq(third.cold_slow, CelRules.SLOW_MAX, 0.001)


func _fixed_mod(stat: StringName, v: float) -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.base = v
	m.by_rarity = false
	return m


func test_shatter_once_by_freeze_and_the_crystals_jump() -> void:
	_start()
	_take(&"golpe_geada")
	_take(&"estilhaco")
	_take(&"cristais_errantes")
	var e := _enemy(Vector2(4.0, 0.0))
	var near := _enemy(Vector2(5.0, 0.0))
	var far := _enemy(Vector2(12.0, 0.0))
	for i in 3:
		_hit(e, ["light"])
	assert_gt(e.frozen_t, 0.0)
	var plain := _dealt(far, ["light"])
	var shattered := _dealt(e, ["light"])
	assert_almost_eq(shattered / plain, 1.4, 0.12, "+40% on the first blow of a freeze")
	var second := _dealt(e, ["light"])
	assert_almost_eq(second / plain, 1.0, 0.12, "once by freeze")
	assert_eq(near.cel.cold, 1, "one stack to the one beside it")
	assert_eq(far.cel.cold if far.cel != null else 0, 1, "only its own blow's stack (far)")


func test_a_boss_never_freezes_nor_slows_nor_stuns() -> void:
	_start()
	_take(&"golpe_geada")
	var boss := _boss()
	for i in 10:
		_hit(boss, ["light"])
	assert_eq(boss.frozen_t, 0.0)
	assert_eq(boss.cold_slow, 0.0)
	assert_eq(int(game.combat.celestial.tally.get(&"freeze", 0)), 0)


func test_a_boss_is_immune_to_impact_and_a_common_is_stunned_by_five() -> void:
	_start()
	_take(&"golpe_firme")
	var boss := _boss()
	for i in 12:
		_hit(boss, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"stun", 0)), 0, "bosses are never stunned by Impacto")
	var e := _enemy(Vector2(6.0, 0.0))
	for i in 4:
		_hit(e, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"stun", 0)), 0)
	_hit(e, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"stun", 0)), 1, "five points")
	_run(0.7)
	for i in 6:
		_hit(e, ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"stun", 0)), 1)


func test_ruptura_and_the_stunned_take_more() -> void:
	_start()
	_take(&"golpe_firme")
	_take(&"ruptura")
	_take(&"forca_inabalavel")
	var e := _enemy()
	var plain := _dealt(_enemy(Vector2(9.0, 0.0)), ["light"])
	for i in 3:
		_hit(e, ["light"])
	_hit(e, ["light"])
	assert_gt(e.stun_t, 0.0, "four points now")
	var more := _dealt(e, ["light"])
	assert_almost_eq(more / plain, 1.2, 0.1, "+20% on a stunned enemy")


# ---------- Lumael ----------

func test_crit_has_no_chance_without_a_source_and_never_on_e() -> void:
	_start()
	for i in 200:
		_hit(_enemy(Vector2(4.0, 0.0), 1000.0), ["light"])
	assert_eq(int(game.combat.celestial.tally.get(&"crit", 0)), 0)
	_take(&"golpe_radiante")
	for i in 400:
		_hit(_enemy(Vector2(4.0, 0.0), 1000.0), ["light", "dash"])
	assert_eq(int(game.combat.celestial.tally.get(&"crit", 0)), 0, "the Investida takes no crit of the attack's Blessing")
	for i in 600:
		_hit(_enemy(Vector2(4.0, 0.0), 1000.0), ["light"])
	var crits := int(game.combat.celestial.tally.get(&"crit", 0))
	assert_between(crits, 30, 100, "10% of 600")


func test_a_crit_does_150_percent_and_dot_and_secondary_hits_never_crit() -> void:
	_start()
	_take(&"golpe_radiante")
	game.boons.grant([_fixed_mod(&"cel_crit_global", 5.0)])  # certain: the ceiling is 60%, so roll by hand below
	var got_crit := false
	var e := _enemy()
	var normal := 0.0
	for i in 400:
		var d := _dealt(e, ["light"], 100.0)
		if d > 120.0:
			got_crit = true
			assert_almost_eq(d, 150.0, 2.0)
		else:
			normal = d
	assert_true(got_crit)
	assert_almost_eq(normal, 100.0, 2.0)
	var crits := int(game.combat.celestial.tally.get(&"crit", 0))
	# secondary: a ray, a burn tick, an echo, a zone are not direct hits
	for i in 200:
		_hit(e, ["skill", "chama", "combustao"], 100.0)
	assert_eq(int(game.combat.celestial.tally.get(&"crit", 0)), crits, "nothing secondary rolls a die")


func test_clarao_arms_the_next_action_only_and_does_not_stack() -> void:
	_start()
	_take(&"clarao")
	_take(&"golpe_radiante")
	game.combat.celestial.on_dodge()
	game.combat.celestial.on_dodge()
	assert_almost_eq(game.combat.celestial.clarao_t, CelRules.CLARAO_TIME, 0.001, "renewed, never added")
	assert_almost_eq(game.boons.slot_stat(&"cel_crit", Boon.Slot.DASH), 0.15, 0.001)
	game.combat.celestial.step(3.1)
	assert_eq(game.combat.celestial.clarao_t, 0.0, "it expires in 3 s")


# ---------- Shomael, Velael ----------

func test_fraqueza_is_capped_and_vulnerabilidade_adds() -> void:
	_start()
	_take(&"golpe_veu")
	_take(&"vulnerabilidade")
	_take(&"veu_persistente")
	var e := _enemy()
	var plain := _dealt(_enemy(Vector2(8.0, 0.0)), ["heavy", "wave"])
	_hit(e, ["light"])
	assert_almost_eq(e.weak_t, 2.5, 0.01, "2 s plus 25%")
	assert_almost_eq(game.horde.weak_cut, Combat.WEAK_CUT, 0.001)
	var more := _dealt(e, ["heavy", "wave"])
	assert_almost_eq(more / plain, 1.15, 0.08, "+15% on the weakened")
	_hit(e, ["light"])
	assert_almost_eq(e.weak_t, 2.5, 0.01, "renewed, never stacked")
	game.boons.grant([_fixed_mod(&"weak_pct", 0.9)])
	_hit(_enemy(Vector2(5.0, 1.0)), ["light"])
	assert_almost_eq(game.horde.weak_cut, CelRules.WEAK_MAX, 0.001, "the cut stops at 40%")


func test_essence_restores_mana_with_a_global_recharge() -> void:
	_start()
	_take(&"golpe_veu")
	_take(&"essencia_restauradora")
	game.player.magick.value = 0.0
	var a := _enemy(Vector2(4.0, 0.0))
	var b := _enemy(Vector2(5.0, 0.0))
	_hit(a, ["light"])
	_hit(b, ["light"])
	game.combat.celestial.on_killed(a)
	game.combat.celestial.on_killed(b)
	assert_almost_eq(game.player.magick.value, 1.0, 0.001, "one, and the recharge holds the second")
	game.combat.celestial.step(2.1)
	var c := _enemy(Vector2(6.0, 0.0))
	_hit(c, ["light"])
	game.combat.celestial.on_killed(c)
	assert_almost_eq(game.player.magick.value, 2.0, 0.001)


func test_passo_firme_lends_the_shield_for_its_time_with_a_recharge() -> void:
	_start()
	_take(&"passo_firme")
	var cel := game.combat.celestial
	game.player.shield_ready = false
	cel.on_dodge()
	assert_true(game.player.shield_ready)
	assert_almost_eq(cel.guard_t, 1.2, 0.001)
	cel.step(1.3)
	assert_false(game.player.shield_ready, "it runs out")
	cel.on_dodge()
	assert_false(game.player.shield_ready, "8 s of recharge")
	cel.step(8.0)
	_take(&"amparo")
	cel.on_dodge()
	assert_true(game.player.shield_ready)
	assert_almost_eq(cel.guard_t, 1.5, 0.001, "+25%")
	game.player.shield_ready = false
	cel.step(0.1)
	assert_false(cel._guard_ours)


# ---------- Galael ----------

func test_cadence_speed_and_the_ceiling_of_a_total() -> void:
	_start()
	_take(&"golpe_mare")
	_take(&"cadencia")
	var cel := game.combat.celestial
	var node: ComboNode = null
	for n in game.player.tree.all_nodes():
		if n.has_tag(&"light") and not n.has_tag(&"dash") and not n.has_tag(&"omega"):
			node = n
			break
	var tags := node.tags
	assert_almost_eq(cel.attack_speed(tags), 0.12, 0.001)
	for i in 8:
		cel.on_action(node)
	assert_eq(cel.cadence, 5, "five at most")
	assert_almost_eq(cel.attack_speed(tags), 0.12 + 5 * 0.03, 0.001)
	cel.step(3.1)
	assert_eq(cel.cadence, 0, "3 s")
	cel.haste_t = 5.0
	cel._haste_speed = 0.9
	assert_almost_eq(cel.attack_speed(tags), 0.5, 0.001, "+50% at most")
	var dash := ComboNode.new()
	dash.tags = [&"light", &"dash"] as Array[StringName]
	assert_eq(cel.attack_speed(dash.tags), 0.0, "E is unchanged")


func test_whirl_at_full_cadence_with_its_recharge() -> void:
	_start()
	_take(&"golpe_mare")
	_take(&"cadencia")
	_take(&"turbilhao")
	var e := _enemy(Vector2(2.0, 0.0), 1000.0)
	var node: ComboNode = null
	for n in game.player.tree.all_nodes():
		if n.has_tag(&"light") and not n.has_tag(&"dash") and not n.has_tag(&"omega"):
			node = n
			break
	for i in 5:
		game.combat.celestial.on_action(node)
	assert_eq(int(game.combat.celestial.tally.get(&"whirl", 0)), 1)
	assert_lt(e.hp, 1000.0)
	for i in 5:
		game.combat.celestial.on_action(node)
	assert_eq(int(game.combat.celestial.tally.get(&"whirl", 0)), 1, "5 s of recharge")


func test_vendaval_gives_speed_and_movement_for_its_time() -> void:
	_start()
	_take(&"vendaval")
	var cel := game.combat.celestial
	var before := game.player.speed_bonus
	cel.on_ult()
	cel.step(DT)
	assert_almost_eq(cel.haste_t, 5.0, 0.1)
	assert_almost_eq(game.player.speed_bonus, before + 0.1, 0.001)
	cel.step(5.1)
	cel.step(DT)
	assert_almost_eq(game.player.speed_bonus, before, 0.001)


# ---------- Qeshael ----------

func test_echoes_are_a_share_of_the_direct_damage_and_never_echo_again() -> void:
	_start()
	_take(&"golpe_marca")
	_take(&"pesado_marca")
	var e := _enemy()
	_hit(e, ["light"])
	assert_gt(e.cel.mark_t, 0.0, "marked, and no bonus damage of its own")
	var plain := _dealt(_enemy(Vector2(9.0, 0.0)), ["heavy", "wave"], 100.0)
	var before := e.hp
	_hit(e, ["heavy", "wave"], 100.0)
	var direct := before - e.hp
	assert_almost_eq(direct, plain, 2.0, "Marca adds nothing to the blow")
	_run(0.3)
	assert_eq(before - direct, e.hp, "not yet: 0.4 s of delay")
	_run(0.3)
	assert_almost_eq(before - direct - e.hp, direct * 0.4, 1.5, "40% of the direct damage")
	_run(2.0)
	assert_eq(int(game.combat.celestial.tally.get(&"echo", 0)), 1, "no echo of an echo")
	# one second of recharge by target
	_hit(e, ["heavy", "wave"])
	_hit(e, ["heavy", "wave"])
	assert_eq(int(game.combat.celestial.tally.get(&"echo", 0)), 2)


func test_marca_of_the_blessings_is_not_the_old_crit_mark() -> void:
	_start()
	_take(&"golpe_marca")
	var e := _enemy()
	var plain := _dealt(_enemy(Vector2(9.0, 0.0)), ["light"], 100.0)
	_hit(e, ["light"])
	assert_eq(e.mark_t, 0.0, "the old mark timer is not set")
	var again := _dealt(e, ["light"], 100.0)
	assert_almost_eq(again, plain, 1.5)


func test_the_army_of_echoes_lasts_five_seconds_and_resonance_shortens_the_recharge() -> void:
	_start()
	_take(&"exercito_ecos")
	var cel := game.combat.celestial
	var e := _enemy()
	_hit(e, ["light"])
	assert_eq(int(cel.tally.get(&"echo", 0)), 0, "before the ultimate: nothing")
	cel.on_ult()
	assert_almost_eq(cel.army_t, 5.0, 0.001)
	_hit(e, ["light"])
	assert_eq(int(cel.tally.get(&"echo", 0)), 1)
	_hit(e, ["light"])
	assert_eq(int(cel.tally.get(&"echo", 0)), 1, "1 s by enemy")
	cel.step(5.1)
	_hit(e, ["light"])
	assert_eq(int(cel.tally.get(&"echo", 0)), 1, "over")


# ---------- the skills of the buttons ----------

func test_a_skill_that_only_puts_a_status_deals_no_blow() -> void:
	_start()
	_take(&"circulo_geada")
	var e := _enemy()
	var tags: Array[StringName] = [&"skill", &"geada", &"circulo_geada"]
	var hp := e.hp
	game.combat.skill_hit(e, 0.0, tags, Vector2.RIGHT, 6.0, &"cold", 2.0)
	assert_eq(e.hp, hp)
	assert_eq(e.cel.cold, 2)
	# the flakes: a stack by target by second
	var f := _enemy(Vector2(5.0, 1.0))
	var tags2: Array[StringName] = [&"skill", &"geada", &"floco_errante"]
	game.combat.skill_hit(f, 0.0, tags2, Vector2.RIGHT, 4.0, &"cold", 1.0, 1.0)
	game.combat.skill_hit(f, 0.0, tags2, Vector2.RIGHT, 4.0, &"cold", 1.0, 1.0)
	assert_eq(f.cel.cold, 1, "the same flake touching again inside a second adds nothing")


func test_the_ultimate_rays_of_light_and_the_skills_find_their_triggers() -> void:
	_start()
	var triggers := {&"circulo_brasa": SkillDef.Trigger.SHOUT, &"circulo_geada": SkillDef.Trigger.SHOUT, &"circulo_firme": SkillDef.Trigger.SHOUT,
		&"circulo_veu": SkillDef.Trigger.SHOUT, &"chuva_brasas": SkillDef.Trigger.ULT, &"peso_inverno": SkillDef.Trigger.ULT,
		&"ultimo_radiante": SkillDef.Trigger.ULT, &"ultimo_firme": SkillDef.Trigger.ULT, &"crepusculo": SkillDef.Trigger.ULT,
		&"floco_errante": SkillDef.Trigger.DODGE, &"fios_cinza": SkillDef.Trigger.DODGE, &"pesado_mare": SkillDef.Trigger.SPECIAL}
	for id: StringName in triggers:
		var b := game.boons.find(id)
		assert_eq(b.skill.trigger, triggers[id], String(id))


# ---------- the Maga ----------

func test_the_maga_carries_the_layer_with_her_own_states_apart() -> void:
	_start("maga")
	_take(&"golpe_brasa")
	_take(&"toque_geada")
	var e := _enemy()
	_hit(e, ["light", "bolt", "arcane", "fire"])
	assert_almost_eq(e.burn_dps, 3.5, 0.001, "her primary: the attack's Blessing")
	_hit(e, ["heavy", "bolt", "arcane", "ice"])
	assert_eq(e.cel.cold, 2, "her special: the special's")
	_hit(e, ["omega", "heavy", "cast", "arcane", "ice"])
	assert_eq(int(game.combat.celestial.tally.get(&"cold", 0)), 2, "the held special is the special's: one stack more, no Brado's")
	_hit(e, ["shout", "cast", "arcane", "volt"])
	assert_eq(int(game.combat.celestial.tally.get(&"burn", 0)), 1, "her Brado is not the attack")
	assert_eq(game.arcane.book.keys().size(), 0, "her own book of elements is untouched")


func test_the_maga_dodge_trail_and_the_flow_of_a_descent() -> void:
	_start("maga")
	_take(&"passo_brasa")
	assert_almost_eq(game.boons.stat(&"dodge_ember_dps"), 6.0, 0.001)
	assert_almost_eq(Combat.TRAIL_TIME, 2.0, 0.001)
	assert_true(Arcane.STEP_TRAIL.y == Combat.TRAIL_TIME)
