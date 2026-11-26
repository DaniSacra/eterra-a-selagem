extends GutTest
## The elemental Maga (redesign 2026-11-24, 04_PLANO C; GP-5 buttons and Gifts, test_maga_v1): her 12 Gifts, the kit in the combo tree, the three elements
## and their reactions in play (Arcane over ElementBook), the Convergência and the clearing of every state. The pure rules are
## test_element_book and test_converge.

const DT := 1.0 / 60.0

var game: Game
var pad := Controls.VirtualPad.new()


func after_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	Dev.drop("hero")


func _start() -> void:
	Dev.put("hero", "maga")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	for e in game.horde.list.duplicate():
		e.alive = false
	game.horde.list.clear()
	Controls.virtual = pad
	pad.aim = Vector2.RIGHT
	game.player.pos = Vector2.ZERO
	game.player.facing = Vector2.RIGHT
	game.player.magick.value = 50.0
	_step()


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


func _dummy(at: Vector2, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func _shot(tags: Array[StringName], damage := 8.0) -> Projectiles.Shot:
	var s := Projectiles.Shot.new()
	s.tags = tags
	s.damage = damage
	return s


const SPARK: Array[StringName] = [&"light", &"bolt", &"arcane", &"fire"]
const COMBUST: Array[StringName] = [&"omega", &"light", &"bolt", &"arcane", &"fire"]
const SHARD: Array[StringName] = [&"shout", &"cast", &"bolt", &"arcane", &"ice"]


# ---------- the data ----------

func test_twelve_gifts_in_three_branches_with_needs_and_player_text() -> void:
	var cat := HeroDef.maga().talents().catalog
	assert_eq(cat.size(), 12)
	var B := TalentDef.Branch
	var by := {}
	for t in cat:
		by[t.branch] = int(by.get(t.branch, 0)) + 1
		assert_ne(T.t(t.name_key), String(t.name_key), "%s has a name" % t.id)
		assert_ne(T.t(t.desc_key), String(t.desc_key), "%s has a description" % t.id)
		assert_false(T.t(t.desc_key).contains("provis"), "provisional only in the backlog, not in the player's text")
		assert_false(T.t(t.desc_key).contains("—"))
		assert_false(SaveData.LEGACY_DONS.maga.has(String(t.id)), "no legacy id reused")
		if t.tier == TalentDef.Tier.ENTRY:
			assert_eq(t.needs, &"")
		else:
			assert_ne(t.needs, &"", "%s needs a Gift" % t.id)
	assert_eq([by[B.ELEMENTALISMO], by[B.CONJURACAO], by[B.FEITICARIA]], [4, 4, 4])


func test_the_tree_has_the_four_moves_of_the_kit() -> void:
	var tree := (load(HeroDef.maga().combos) as ComboTree)
	var N := ComboNode.In
	var spark := ComboTree.find(tree.neutral, N.LIGHT)
	var arc := ComboTree.find(tree.neutral, N.CHARGE_LIGHT)
	var shard := ComboTree.find(tree.neutral, N.HEAVY)
	var frost := ComboTree.find(tree.neutral, N.CHARGE)
	assert_eq(tree.neutral.size(), 4, "no Combustão, no Suspensão, no Q or E move")
	assert_true(spark.has_tag(&"fire") and spark.next.is_empty(), "the Centelha has no chain")
	assert_eq([arc.magick_cost, arc.charge_time, arc.effect], [10.0, 0.6, ComboNode.Effect.ARC])
	assert_eq([shard.magick_cost, shard.cooldown, shard.wave_stops], [5.0, 0.0, false])
	assert_eq([frost.magick_cost, frost.effect], [20.0, ComboNode.Effect.FROST])
	assert_eq(tree.dodge_window, 0.0)


func test_one_ultimate_the_convergence_at_mastery_2() -> void:
	var hero := HeroDef.maga()
	assert_eq(hero.ultimates.size(), 1)
	var u := hero.ultimates[0]
	assert_eq([u.id, u.kind, u.mastery_level, u.weapon], [&"converge", UltDef.Kind.CONVERGE, 2, &"bastao"])
	assert_eq(u.charge, 60.0, "the reactions fill it too (GP-5)")
	assert_eq(hero.arcane.converge_plan().count(), 9)


# ---------- the elements in play ----------

func test_three_sparks_in_four_seconds_set_the_target_alight_and_it_burns() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	for i in 2:
		game.arcane.shot_landed(e, _shot(SPARK))
	assert_false(game.arcane.book.has_fire(e))
	game.arcane.shot_landed(e, _shot(SPARK))
	assert_true(game.arcane.book.has_fire(e), "the third hit lights it")
	var hp := e.hp
	_step(150)
	assert_lt(e.hp, hp, "Queimadura hurts")
	assert_gt(float(game.horde.dealt.by.get("elemental", 0.0)), 0.0, "counted as elemental")


func test_the_hits_of_the_window_start_over_when_it_runs_out() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.shot_landed(e, _shot(SPARK))
	game.arcane.shot_landed(e, _shot(SPARK))
	game.arcane.book.tick(5.0)
	game.arcane.shot_landed(e, _shot(SPARK))
	assert_false(game.arcane.book.has_fire(e))


func test_the_combustion_burns_everyone_in_its_burst_and_not_those_outside() -> void:
	_start()
	var a := _dummy(Vector2(4, 0))
	var b := _dummy(Vector2(5.2, 0))
	var far := _dummy(Vector2(9, 0))
	var hp := b.hp
	game.arcane.shot_landed(a, _shot(COMBUST, 35.0))
	assert_true(game.arcane.book.has_fire(a))
	assert_true(game.arcane.book.has_fire(b))
	assert_lt(b.hp, hp, "the neighbour takes the burst")
	assert_false(game.arcane.book.has_fire(far))


func test_the_shard_chills_slows_and_freezes_at_the_third_hit() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.shot_landed(e, _shot(SHARD, 6.0))
	game.arcane.shot_landed(e, _shot(SHARD, 6.0))
	assert_gt(e.slow_t, 0.0)
	assert_eq(e.frozen_t, 0.0)
	game.arcane.shot_landed(e, _shot(SHARD, 6.0))
	assert_gt(e.frozen_t, 0.0, "frozen at the third")


func test_a_boss_is_never_frozen_by_cold() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	e.def = e.def.duplicate()
	e.def.behavior = EnemyDef.Behavior.BOSS
	for i in 4:
		game.arcane.apply_element(e, ElementBook.ICE)
	assert_eq(e.frozen_t, 0.0)


func test_fire_then_ice_makes_the_thermal_shock_once_and_clears_both() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, ElementBook.FIRE)
	var hp := e.hp
	game.arcane.apply_element(e, ElementBook.ICE)
	assert_lt(e.hp, hp - 30.0, "35 of Choque Térmico")
	assert_eq(game.arcane.tally.thermal, 1)
	assert_false(game.arcane.book.has_fire(e))
	assert_false(game.arcane.book.has_ice(e))
	game.arcane.apply_element(e, ElementBook.FIRE)
	assert_eq(game.arcane.tally.thermal, 1, "no second reaction at once (react_gap)")


func test_overload_hurts_the_neighbours_without_putting_a_state_on_them() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	var n := _dummy(Vector2(5, 0))
	game.arcane.apply_element(e, ElementBook.FIRE)
	var hp := n.hp
	game.arcane.apply_element(e, ElementBook.VOLT)
	assert_lt(n.hp, hp, "25 in the area")
	assert_false(game.arcane.book.has_fire(n))
	assert_false(game.arcane.book.has_volt(n), "a reaction applies no state")
	assert_eq(game.arcane.tally.overload, 1)


func test_crystal_freezes_a_common_for_less_than_a_second() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, ElementBook.ICE)
	game.arcane.apply_element(e, ElementBook.VOLT)
	assert_almost_eq(e.frozen_t, 0.8, 0.01)


func test_the_arc_hits_up_to_three_and_marks_them_volt() -> void:
	_start()
	var near: Array[Enemy] = []
	for i in 5:
		near.append(_dummy(Vector2(3 + i * 1.5, 0)))
	var node := ComboTree.find(game.player.tree.neutral, ComboNode.In.CHARGE_LIGHT)
	game.arcane.cast(node, game.player.pos, Vector2.RIGHT)
	var hit := 0
	for e in near:
		if game.arcane.book.has_volt(e):
			hit += 1
	assert_eq(hit, 3)
	assert_true(game.arcane.book.has_volt(near[0]) and game.arcane.book.has_volt(near[2]), "nearest first, each once")


func test_the_frost_ground_chills_whoever_stands_in_it() -> void:
	_start()
	var e := _dummy(Vector2(5, 0))
	var node := ComboTree.find(game.player.tree.neutral, ComboNode.In.CHARGE)
	game.arcane.cast(node, game.player.pos, Vector2.RIGHT)
	assert_not_null(game.arcane.frost)
	_step(200)
	assert_true(game.arcane.book.has_ice(e) or e.frozen_t > 0.0 or e.thaw_t > 0.0)
	_step(300)
	assert_null(game.arcane.frost, "it ends after its seconds")


func test_a_death_and_a_new_room_clear_the_states() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	var f := _dummy(Vector2(6, 0))
	game.arcane.apply_element(e, ElementBook.FIRE)
	game.arcane.apply_element(f, ElementBook.VOLT)
	e.alive = false
	_step()
	assert_false(game.arcane.book.has_fire(e), "the dead are forgotten")
	assert_true(game.arcane.book.has_volt(f))
	game.arcane.clear()
	assert_eq(game.arcane.book.tracked(), 0)


func test_no_seal_or_resonance_is_left_in_her_kit() -> void:
	_start()
	assert_false("seals" in game.arcane)
	assert_false("resonance" in game.arcane)
	assert_false("circle" in game.arcane)


func test_the_dome_still_slows_and_holds_what_comes_in() -> void:
	_start()
	var e := _dummy(Vector2(1.5, 0))
	var node := ComboNode.new()  # (the Suspensão left her tree in GP-5; its code waits for a Gift)
	node.effect = ComboNode.Effect.DOME
	game.arcane.cast(node, game.player.pos, Vector2.RIGHT)
	assert_not_null(game.arcane.dome)
	_step(3)
	assert_gt(e.slow_t, 0.0)


# ---------- the Convergência ----------

func test_the_convergence_runs_three_phases_and_makes_the_reactions() -> void:
	_start()
	var def := HeroDef.maga().ultimates[0]
	game.ults.equip(def)
	var e := _dummy(Vector2(4, 0))
	var n := _dummy(Vector2(5, 1))
	game.ults._open_vortex(Vector2(4.5, 0))
	assert_not_null(game.ults.vortex)
	var hp := e.hp + n.hp
	_step(int(4.7 / DT))
	assert_null(game.ults.vortex, "it ends after 4.5 s")
	assert_lt(e.hp + n.hp, hp - 150.0, "90 of direct damage to each plus the reactions")
	assert_gt(game.arcane.tally.thermal, 0, "fire after ice: Choque Térmico")
	assert_gt(game.arcane.tally.overload, 0, "the volt phase reapplies fire: Sobrecarga")
	assert_gt(game.arcane.tally.crystal, 0, "and ice at the last tick: Cristalização")


func test_the_boss_takes_a_quarter_of_the_convergence() -> void:
	var def := HeroDef.maga().ultimates[0]
	assert_eq(def.converge_share(true, false, false, 0.25), 0.25)
	assert_eq(def.converge_share(false, true, false), def.guardian_share)
	assert_eq(def.converge_share(false, false, true), def.elite_share)
	assert_eq(def.converge_share(false, false, false), 1.0)
