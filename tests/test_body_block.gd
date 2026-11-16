extends GutTest
## Solid bodies as in Hades II (Daniel, 2026-11-15: walking into enemies should not shove them): the paladin walking
## stops at an enemy's edge and slides along it, pushing no one; an enemy walking stops at his edge; the dash goes
## through; surrounded, the dash always gets him out; a kind that does not block (EnemyDef.blocks_body) is walked
## through. BodyBlock (pure), Horde (bare, no scene) and the real game.

const DT := 1.0 / 60.0
const EPS := 0.01
## Meters from him to the ring that surrounds him.
const RING := 1.65


# ---------- BodyBlock ----------

func test_hold_stops_at_the_edge_and_never_deeper_than_allowed() -> void:
	var c := PackedVector2Array([Vector2.ZERO])
	var r := PackedFloat32Array([1.0])
	var free := PackedFloat32Array([0.0])
	assert_almost_eq(BodyBlock.hold(Vector2(-0.4, 0), c, r, free).x, -1.0, EPS, "out by the shortest way")
	assert_eq(BodyBlock.hold(Vector2(-2, 0), c, r, free), Vector2(-2, 0), "outside: untouched")
	var deep := PackedFloat32Array([0.5])
	assert_almost_eq(BodyBlock.hold(Vector2(-0.2, 0), c, r, deep).x, -0.5, EPS, "as deep as allowed, no snap")
	assert_true(BodyBlock.fits(Vector2(-0.5, 0), c, r, deep))
	assert_false(BodyBlock.fits(Vector2(-0.3, 0), c, r, deep))
	assert_almost_eq(BodyBlock.allowance(0.5, 0.1), 0.5 - BodyBlock.EASE * 0.1, 0.0001, "the overlap melts")
	assert_eq(BodyBlock.allowance(0.01, 0.1), 0.0)


# ---------- Horde, bare ----------

func _horde(at: Array[Vector2], blocks := true, radius := 0.5) -> Horde:
	var h := Horde.new()
	var d := EnemyDef.new()
	d.radius = radius
	d.blocks_body = blocks
	for p in at:
		var e := Enemy.new()
		e.def = d
		e.pos = p
		h.list.append(e)
	h.rehash()
	return h


## Walks a body of the paladin's radius from `from` along `dir` for `seconds` at his speed; returns where it ends,
## and fails if it ever stands inside an enemy.
func _walk(h: Horde, from: Vector2, dir: Vector2, seconds: float) -> Vector2:
	var p := from
	var speed := Feel.live().speed
	for i in int(seconds / DT):
		p = h.stop_walker(p, p + dir.normalized() * speed * DT, Player.RADIUS)
		for e in h.list:
			if e.def.blocks_body:
				assert_gte(p.distance_to(e.pos), e.def.radius + Player.RADIUS - EPS, "walked into a body")
	return p


func test_walking_into_an_enemy_stops_at_its_edge_and_it_does_not_move() -> void:
	var h := _horde([Vector2.ZERO])
	var end := _walk(h, Vector2(-3, 0), Vector2.RIGHT, 1.0)
	assert_almost_eq(end.x, -1.0, EPS, "stops at the edge (both radii)")
	assert_almost_eq(end.y, 0.0, EPS)
	assert_eq(h.list[0].pos, Vector2.ZERO, "the enemy was not pushed")
	h.free()


func test_walking_slides_along_an_enemy() -> void:
	var h := _horde([Vector2.ZERO])
	var end := _walk(h, Vector2(-3, 0.25), Vector2.RIGHT, 1.5)
	assert_gt(end.x, 1.5, "went around it")
	assert_eq(h.list[0].pos, Vector2.ZERO)
	h.free()


func test_wedged_between_two_enemies_he_stays_put_and_walks_back_out() -> void:
	var h := _horde([Vector2(0, 0.9), Vector2(0, -0.9)])
	var end := _walk(h, Vector2(-3, 0), Vector2.RIGHT, 1.0)
	assert_lt(end.x, 0.0, "the gap is narrower than he is")
	var back := _walk(h, end, Vector2.LEFT, 0.5)
	assert_lt(back.x, end.x - 2.0, "never trapped: walking away works")
	h.free()


func test_an_enemy_he_walks_through() -> void:
	var h := _horde([Vector2.ZERO], false)
	var end := _walk(h, Vector2(-3, 0), Vector2.RIGHT, 1.0)
	assert_gt(end.x, 3.0, "no body in the way")
	h.free()


func test_an_enemy_walking_into_him_stops_at_his_edge() -> void:
	var h := _horde([Vector2(4, 0)])
	h.target = Vector2.ZERO
	var e := h.list[0]
	for i in 120:
		var was := h.depth_in_target(e)
		e.pos += (h.target - e.pos).normalized() * 4.0 * DT
		h.keep_off_target(e, was, DT)
		assert_gte(e.pos.distance_to(h.target), 1.0 - EPS, "inside the paladin")
	assert_almost_eq(e.pos.x, 1.0, EPS, "stands at his edge")
	assert_eq(h.target, Vector2.ZERO, "he was not pushed")
	h.free()


func test_an_enemy_left_inside_him_works_out_without_a_snap() -> void:
	var h := _horde([Vector2(0.2, 0)])
	h.target = Vector2.ZERO
	var e := h.list[0]
	var last := e.pos
	for i in 30:
		var was := h.depth_in_target(e)
		h.keep_off_target(e, was, DT)
		assert_lte(e.pos.distance_to(last), BodyBlock.EASE * DT + 0.0001, "no jump out")
		last = e.pos
	assert_almost_eq(e.pos.x, 1.0, EPS, "out after a moment")
	h.free()


func test_an_enemy_of_a_kind_that_does_not_block_walks_into_him() -> void:
	var h := _horde([Vector2(0.2, 0)], false)
	h.target = Vector2.ZERO
	h.keep_off_target(h.list[0], h.depth_in_target(h.list[0]), DT)
	assert_eq(h.list[0].pos, Vector2(0.2, 0))
	h.free()


func test_every_kind_blocks_today() -> void:
	for f in DirAccess.get_files_at(Horde.DEFS_DIR):
		if f.ends_with(".tres"):
			var d: EnemyDef = load(Horde.DEFS_DIR + f)
			assert_true(d.blocks_body, "%s blocks" % d.id)


# ---------- the real game ----------

var game: Game


func _game() -> Player:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	for e in game.horde.list:
		e.alive = false
	game.horde.list.clear()
	var p := game.player
	p.place(Vector2.ZERO)
	p.invuln = 100.0
	return p


## An enemy that stands still (stunned for the test).
func _still(at: Vector2, blocks := true) -> Enemy:
	var d := game.horde.def(&"skeleton")
	if not blocks:
		d = d.duplicate()
		d.blocks_body = false
	var e := game.horde.spawn(d, at, false)
	e.stun_t = 1000.0
	return e


func _play(seconds: float, move: Vector2) -> void:
	for i in int(seconds / DT):
		game.player.step(DT, move, Vector2.ZERO)
		game.horde.target = game.player.pos
		game.horde.step(DT)


func test_in_game_walking_stops_at_an_enemy_and_does_not_push_it() -> void:
	var p := _game()
	var e := _still(Vector2(2.5, 0))
	game.horde.rehash()
	_play(1.0, Vector2.RIGHT)
	var reach := e.def.radius + Player.RADIUS
	assert_almost_eq(p.pos.distance_to(e.pos), reach, 0.05, "stops at its edge")
	assert_almost_eq(e.pos.x, 2.5, 0.01, "the enemy stayed where it was")


func test_in_game_the_dash_goes_through_an_enemy() -> void:
	var p := _game()
	var e := _still(Vector2(1.5, 0))
	game.horde.rehash()
	p._start_dodge(Vector2.RIGHT)
	_play(Feel.live().dodge_time + DT, Vector2.RIGHT)
	assert_gt(p.pos.x, e.pos.x + e.def.radius, "came out the other side")
	assert_almost_eq(e.pos.x, 1.5, 0.05, "and did not shove it")


func test_in_game_a_kind_that_does_not_block_is_walked_through() -> void:
	var p := _game()
	_still(Vector2(1.5, 0), false)
	game.horde.rehash()
	_play(1.0, Vector2.RIGHT)
	assert_gt(p.pos.x, 3.0)


func test_in_game_surrounded_walking_is_held_but_the_dash_always_gets_out() -> void:
	for k in 8:
		var p := _game()
		var ring: Array[Enemy] = []
		# ten bodies shoulder to shoulder (a gap narrower than he is between each two)
		for j in 10:
			ring.append(_still(Vector2.from_angle(TAU * j / 10.0) * RING))
		game.horde.rehash()
		var way := Vector2.from_angle(TAU * k / 8.0 + 0.2)
		_play(0.5, way)
		assert_lt(p.pos.length(), RING - 0.9, "the ring holds him walking")
		p.dodge_charges = p.dodge_max
		p._start_dodge(way)
		_play(Feel.live().dodge_time + DT, way)
		for e in ring:
			assert_almost_eq(e.pos.length(), RING, 0.05, "the ring was not shoved")
		assert_gt(p.pos.length(), RING + 1.0, "the dash took him out of the ring (way %d)" % k)
		var out := p.pos
		_play(0.5, way)
		assert_gt(p.pos.distance_to(out), 1.0, "and he walks on, free (way %d)" % k)
		game.queue_free()
		await wait_process_frames(1)


func test_in_game_a_pressing_crowd_neither_enters_him_nor_shoves_him() -> void:
	var p := _game()
	var d: EnemyDef = game.horde.def(&"skeleton").duplicate()
	d.behavior = EnemyDef.Behavior.CHASE
	d.attack_cooldown = 1000.0
	for j in 14:
		var e := game.horde.spawn(d, Vector2.from_angle(TAU * j / 14.0) * (3.0 + j % 3), false)
		e.cooldown = 1000.0
	var start := p.pos
	for i in 180:
		_play(DT, Vector2.ZERO)
		for e in game.horde.list:
			assert_gte(p.pos.distance_to(e.pos), e.def.radius + Player.RADIUS - EPS, "an enemy inside him")
	assert_lt(p.pos.distance_to(start), 0.02, "the crowd did not move him")
	var close := 0
	for e in game.horde.list:
		if p.pos.distance_to(e.pos) < e.def.radius + Player.RADIUS + 0.1:
			close += 1
	assert_gt(close, 3, "they did come up to him")


func test_left_inside_an_enemy_he_never_goes_deeper_and_walks_out() -> void:
	var h := _horde([Vector2.ZERO])
	var inside := Vector2(-0.7, 0)
	var deeper := h.stop_walker(inside, Vector2(-0.5, 0), Player.RADIUS)
	assert_almost_eq(deeper.x, -0.7, EPS, "no deeper than he was")
	var out := h.stop_walker(inside, Vector2(-0.9, 0), Player.RADIUS)
	assert_almost_eq(out.x, -0.9, EPS, "walking out is free")
	h.free()
