extends GutTest
## Maga M1a (docs/design/heroes/maga.md 2.2 and 3): the loop mark, gather, detonate. The Explosão Rúnica (25, plus 35 on each
## Selo, consuming it), the Ressonância (6 points, full: amplified, 0 Magia, no points), the ceilings of the Magia, the Círculo's
## pull and the Suspensão that holds enemy shots.

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
	game.player.magick.value = 30.0
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
	e.stun_t = 1000.0  # (stands where it was put)
	return e


func _blast() -> void:
	pad.press(&"heavy_attack")
	_step(40)


# ---------- the numbers ----------

func test_the_blast_numbers() -> void:
	var kit := HeroDef.maga().arcane
	assert_eq(kit.blast_hit(false, false), 25.0)
	assert_eq(kit.blast_hit(true, false), 60.0, "25 and 35 on a Selo")
	assert_eq(kit.blast_hit(true, true), 90.0, "amplified: times 1.5")
	assert_eq(kit.blast_hit(false, true), 37.5)
	assert_eq([kit.blast_size(false), kit.blast_size(true)], [3.2, 4.5])


func test_the_blast_clings_to_the_nearest_selo_and_never_past_ten_metres() -> void:
	var kit := HeroDef.maga().arcane
	var seals: Array[Vector2] = [Vector2(6, 1.0), Vector2(6.3, 0.0)]
	assert_eq(kit.blast_at(Vector2.ZERO, Vector2(6, 0), seals), Vector2(6.3, 0.0), "the nearer to the cursor")
	assert_eq(kit.blast_at(Vector2.ZERO, Vector2(6, 3), seals), Vector2(6, 3), "none within 1.5 m: the cursor")
	assert_eq(kit.blast_at(Vector2.ZERO, Vector2(30, 0), []), Vector2(10, 0))
	assert_eq(kit.circle_at(Vector2.ZERO, Vector2(0, 30)), Vector2(0, 8))


func test_the_circle_pulls_one_and_a_fifth_metres_in_four_tenths() -> void:
	var kit := HeroDef.maga().arcane
	var p := Vector2(3, 0)
	for i in 24:
		p += kit.pull_step(p, Vector2.ZERO, 0.4 / 24.0)
	assert_almost_eq(p.x, 3.0 - 1.2, 0.001)
	var near := Vector2(0.5, 0)
	near += kit.pull_step(near, Vector2.ZERO, 1.0)
	assert_eq(near, Vector2.ZERO, "never past the centre")


func test_the_resonance_fills_and_the_amplified_blast_empties_it() -> void:
	var r := Resonance.new(6)
	r.add(5)
	assert_false(r.take_amplified(), "not full: the plain blast, nothing changes")
	assert_eq(r.points, 5)
	r.add(3)
	assert_eq(r.points, 6, "never past six")
	assert_eq([r.diamonds(), r.half()], [3, false])
	assert_true(r.take_amplified())
	assert_eq(r.points, 0)


func test_the_magia_gains_have_ceilings() -> void:
	var hero := HeroDef.maga()
	var feed := KitFeed.new(hero)
	var got := 0.0
	for i in 40:
		got += feed.take(hero.arcane.shot_magick)
	assert_almost_eq(got, hero.gain_cap, 0.001, "shots give at most 3 Magia a second")
	assert_eq(hero.arcane.seal_magick_cap, 6)
	assert_eq(hero.magick_on_finisher, 1.0, "a finisher gives 1 more")


# ---------- in play ----------

func test_the_blast_hits_all_and_consumes_the_selos_for_the_extra() -> void:
	_start()
	var marked := _dummy(Vector2(6, 0))
	var bare := _dummy(Vector2(7.5, 1.0))
	var out := _dummy(Vector2(6, 8))
	game.arcane.lay(marked)
	var magick := game.player.magick.value
	_blast()
	assert_eq(marked.hp, 5000.0 - 60.0)
	assert_eq(bare.hp, 5000.0 - 25.0)
	assert_eq(out.hp, 5000.0, "outside its 3.2 m")
	assert_false(game.arcane.seals.has(marked), "the Selo is consumed")
	assert_eq(game.arcane.resonance.points, 1, "a point for the Selo detonated")
	# 10 Magia paid; back: 1 for the passive's finisher and 1 for the Selo
	assert_almost_eq(game.player.magick.value, magick - 10.0 + 2.0, 0.01)


func test_the_amplified_blast_costs_nothing_and_gives_no_points() -> void:
	_start()
	var marked := _dummy(Vector2(6, 0))
	var wide := _dummy(Vector2(6, 4.0))  # 4 m off: only the amplified radius (4.5) reaches
	game.arcane.lay(marked)
	game.arcane.resonance.add(6)
	_step()  # (Arcane lets the special go free on the step after it fills)
	var magick := game.player.magick.value
	_blast()
	assert_eq(marked.hp, 5000.0 - 90.0, "60 times 1.5")
	assert_eq(wide.hp, 5000.0 - roundf(37.5), "reached by the wider ring")
	assert_eq(game.arcane.resonance.points, 0, "the Ressonância went into it and gave no point back")
	assert_gte(game.player.magick.value, magick, "no Magia spent")


func test_without_a_full_resonance_the_blast_is_plain_and_costs_ten() -> void:
	_start()
	_dummy(Vector2(6, 0))  # (the cursor of the stick goes to the nearest enemy)
	var wide := _dummy(Vector2(6, 4.0))
	game.arcane.resonance.add(5)
	var magick := game.player.magick.value
	_blast()
	assert_eq(wide.hp, 5000.0, "4 m off: outside the plain 3.2 m")
	assert_almost_eq(game.player.magick.value, magick - 10.0 + 1.0, 0.01, "10 paid, 1 back for the finisher")
	assert_eq(game.arcane.resonance.points, 5)


func test_a_blast_gives_back_magia_for_six_selos_at_most() -> void:
	_start()
	for i in 8:
		game.arcane.lay(_dummy(Vector2(6.0 + (i % 4) * 0.4, (i / 4) * 0.8 - 0.4)))
	var magick := game.player.magick.value
	_blast()
	assert_eq(game.arcane.tally.detonated, 8)
	# -10 paid, +1 finisher, +6 (the ceiling of the Selos' Magia, not 8)
	assert_almost_eq(game.player.magick.value, magick - 10.0 + 1.0 + 6.0, 0.01)
	assert_eq(game.arcane.resonance.points, 6, "the points are not capped by it, only by the diamonds")


func test_the_circle_gathers_the_commons_and_slows_all_but_the_boss() -> void:
	_start()
	var centre := _dummy(Vector2(6, 0))  # (the stick's cursor goes to the nearest enemy: the circle falls on it)
	var common := _dummy(Vector2(6, 2.5))
	var guardian := _dummy(Vector2(6, -2.0), &"guard_elite")
	pad.press(&"shout")
	_step(60)
	assert_not_null(game.arcane.circle)
	assert_almost_eq(common.pos.distance_to(centre.pos), 2.5 - 1.2, 0.2, "drawn in 1.2 m")
	assert_almost_eq(guardian.pos.y, -2.0, 0.3, "a guardian is only slowed")
	assert_gt(common.slow_t, 0.0, "slowed")
	assert_gt(guardian.slow_t, 0.0)


func test_the_dome_holds_the_enemy_shots_and_drops_them_with_it() -> void:
	_start()
	var shot := game.projectiles.fire(Projectiles.Kind.BOLT, Vector2(4, 0), Vector2(-1, 0), 8.0, 5.0)
	pad.press(&"rush")
	_step(30)
	assert_not_null(game.arcane.dome)
	assert_true(shot.frozen, "stopped in the air")
	var held := shot.pos
	_step(30)
	assert_eq(shot.pos, held)
	assert_eq(game.player.hp, game.player.max_hp, "and harmless")
	_step(int(2.5 / DT))
	assert_null(game.arcane.dome)
	_step(2)
	assert_false(game.projectiles.shots.has(shot), "gone with the dome")


func test_the_passo_goes_four_and_a_half_metres_through_a_body_with_two_charges() -> void:
	_start()
	_dummy(Vector2(2.0, 0))
	assert_eq(game.player.dodge_charges, 2)
	pad.move = Vector2.RIGHT
	pad.press(&"dodge")
	_step(2)
	assert_gt(game.player.pos.x, 4.0, "through the dummy, out the other side")
	assert_eq(game.player.dodge_charges, 1)
	assert_true(game.player.invulnerable(), "14 frames of safety")
	assert_ne(game.player.state, Player.State.DODGE)
