extends GutTest
## ART-05.5, Morvath's entrance in his chamber: he rises out of the seal in Boss.RISE_TIME (only his drawn height,
## Enemy.y: never where he stands), then roars until Boss.ENTER_TIME, when the fight begins as before (the same 2.4 s:
## the first attack comes when it did).

const F := 1.0 / 60.0


func after_each() -> void:
	Engine.time_scale = 1.0


func test_the_rise_eases_out_of_the_seal() -> void:
	assert_almost_eq(Boss.rise_depth(0.0, 1.0), Boss.RISE_SINK, 0.001, "sunk under the seal at first")
	assert_eq(Boss.rise_depth(Boss.RISE_TIME, 1.0), 0.0, "up at RISE_TIME")
	assert_eq(Boss.rise_depth(Boss.ENTER_TIME, 1.0), 0.0)
	var last := INF
	for i in 61:
		var d := Boss.rise_depth(i * Boss.RISE_TIME / 60.0, 1.3)
		assert_true(d <= last, "always rising")
		assert_true(last == INF or last - d < 0.3, "no jump between frames")
		last = d
	assert_lt(Boss.ENTER_TIME - Boss.RISE_TIME, 1.0, "the roar under a second")


func test_in_his_chamber_he_rises_and_the_fight_begins_on_time() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	var boss := game.boss
	var e := boss.e
	var at := e.pos
	var risen := [false]
	boss.moment.connect(func(n: StringName) -> void:
		if n == &"risen":
			risen[0] = true)
	var left_at := -1.0
	var t := 0.0
	game.player.place(Vector2(0, 10))
	for i in int(3.0 / F):
		game.player.invuln = 10.0
		game._step(F)
		t += F
		if t < 0.5:
			assert_lt(e.y, -0.5, "under the seal early on")
			assert_eq(e.pos, at, "where he stands never moves")
		if boss.state != Boss.State.ENTER and left_at < 0.0:
			left_at = t
	assert_true(risen[0], "he rose")
	assert_eq(e.y, 0.0, "and stands on the seal")
	assert_almost_eq(left_at, Boss.ENTER_TIME, 0.05, "the fight begins when it did")
