extends GutTest
## Maga M1a (docs/design/heroes/maga.md 2.1): the Selo. The pure rules (SealBook, ArcaneKit) and the shots in play: three shots
## that end on the first enemy, the third lays the Selo (the second too inside the Círculo), nothing before.

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
	return e


## One shot of the chain: press, then wait for it to leave and land.
func _shoot() -> void:
	pad.press(&"light_attack")
	_step(20)


# ---------- the rules ----------

func test_a_seal_lives_its_time_and_the_clock_stops_where_told() -> void:
	var book := SealBook.new(8.0, 1)
	var a := RefCounted.new()
	var b := RefCounted.new()
	assert_true(book.lay(a))
	assert_true(book.lay(b))
	assert_eq(book.total(), 2)
	book.step(7.0)
	assert_eq(book.total(), 2)
	var gone := book.step(2.0, func(k: Object) -> bool: return k == b)
	assert_eq(gone, [a], "the one held by the circle keeps its clock")
	assert_true(book.has(b))
	assert_eq(book.take(b), 1)
	assert_false(book.has(b))


func test_one_seal_an_enemy_and_a_second_only_renews_it() -> void:
	var book := SealBook.new(8.0, 1)
	var a := RefCounted.new()
	assert_true(book.lay(a))
	book.step(5.0)
	assert_false(book.lay(a), "at the cap: not a new Selo")
	assert_eq(book.count(a), 1)
	assert_almost_eq(book.left(a), 8.0, 0.001, "but its clock starts over")
	var two := SealBook.new(8.0, 2)
	two.lay(a)
	assert_true(two.lay(a), "Selo Duplo (a Dom to come): two")
	assert_eq(two.count(a), 2)


func test_the_third_shot_lays_it_and_the_second_only_inside_the_circle() -> void:
	var kit := HeroDef.maga().arcane
	var tree: ComboTree = load(HeroDef.maga().combos)
	var one := ComboTree.find(tree.neutral, ComboNode.In.LIGHT)
	var two: ComboNode = one.following()[0]
	var three: ComboNode = two.following()[0]
	assert_false(kit.seals_on(one.tags, true))
	assert_false(kit.seals_on(two.tags, false))
	assert_true(kit.seals_on(two.tags, true), "the second one inside the Círculo")
	assert_true(kit.seals_on(three.tags, false))
	assert_eq([one.effect_power, two.effect_power, three.effect_power], [8.0, 8.0, 12.0])
	assert_true(three.following().is_empty(), "the chain is three shots")


# ---------- in play ----------

func test_the_shots_end_on_the_first_enemy_and_the_third_marks_it() -> void:
	_start()
	var near := _dummy(Vector2(5, 0))
	var far := _dummy(Vector2(8, 0))
	var arcane := game.arcane
	_shoot()
	assert_eq(near.hp, 4992.0, "8 on the first enemy")
	assert_eq(far.hp, 5000.0, "the shot did not go through")
	assert_false(arcane.seals.has(near), "one shot: no Selo")
	_shoot()
	assert_eq(near.hp, 4984.0)
	assert_false(arcane.seals.has(near), "two shots: no Selo")
	_shoot()
	assert_eq(near.hp, 4972.0, "the third hits for 12")
	assert_true(arcane.seals.has(near), "the third lays the Selo")
	assert_false(arcane.seals.has(far))
	assert_eq(far.hp, 5000.0)


func test_inside_the_circle_the_second_shot_marks() -> void:
	_start()
	var e := _dummy(Vector2(5, 0))
	pad.press(&"shout")
	_step(40)
	assert_not_null(game.arcane.circle, "the Círculo stands")
	game.arcane.seals.clear()
	e.pos = game.arcane.circle.at
	_shoot()
	assert_false(game.arcane.seals.has(e))
	_shoot()
	assert_true(game.arcane.seals.has(e), "the second shot, inside it")


func test_a_common_blow_never_stuns() -> void:
	_start()
	var rule := StunRule.live
	StunRule.live = StunRule.DEFAULT
	var e := _dummy(Vector2(5, 0))
	for i in 3:
		_shoot()
	assert_eq(e.stun_t, 0.0, "F8: no shot stuns a common enemy")
	StunRule.live = rule
