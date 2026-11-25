extends GutTest
## The slabs that strike when stepped on (RP-06, H-2; docs/design/rooms_progression.md): anyone stepping on one (the
## paladin or an enemy) arms it, 1.0 s lighting from the edge to the middle, a strike of 0.25 s on whoever stands on
## it (7 to him, 60 to an enemy: RP-03), 5 s before it may arm again; nothing in the first 3 s, nothing asleep before
## the descent's progress 0.34, nothing over a door, at most two at once (R9). In the data: every slab whole on the
## floor, off every piece that stops a body, off the doors and the spawns, 6 m or more from the way in, and a way off it
## walking before it strikes (as test_boss_exits.gd). In a real room it hurts both and the room counts it.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
## The paladin's walk (Hades II: 540 units, 6.75 m/s) and a human's reaction (the bot's 0.25).
const WALK := 6.75
const REACTION := 0.25

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _def(plates: Array[Rect2]) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	h.plates = plates
	h.warn = 1.0
	h.fire = 0.25
	h.rearm = 5.0
	h.start_delay = 3.0
	h.hero_damage = 7.0
	h.enemy_damage = 60.0
	return h


func _run(h: PlateHazard, seconds: float, hero: Vector2, bodies := PackedVector2Array()) -> Dictionary:
	var armed := 0
	var fired := 0
	for i in roundi(seconds / DT):
		var did := h.step(DT, hero, bodies)
		armed += (did.armed as PackedInt32Array).size()
		fired += (did.fired as PackedInt32Array).size()
	return {"armed": armed, "fired": fired}


func test_the_rhythm_arm_strike_rest() -> void:
	var h := PlateHazard.new(_def([Rect2(0, 0, 3, 3)]), [])
	var on := Vector2(1.5, 1.5)
	assert_eq(_run(h, 2.95, on).armed, 0, "nothing in the first 3 s")
	_until_armed(h, on)
	assert_eq(h.phase[0], PlateHazard.Phase.ARM, "standing on it arms it")
	assert_eq(_run(h, 0.95, Vector2(10, 10)).fired, 0, "stepping off does not stop it")
	assert_eq(_run(h, 0.1, Vector2(10, 10)).fired, 1, "it strikes 1.0 s after it armed")
	_run(h, 0.3, on)
	assert_eq(h.phase[0], PlateHazard.Phase.REST, "then it rests")
	assert_eq(_run(h, 4.6, on).armed, 0, "and may not arm for 5 s")
	assert_eq(_run(h, 0.5, on).armed, 1, "then it arms again")
	assert_eq(h.armed_by_hero, 2)


## Steps until slab 0 arms (it must within 3.2 s).
func _until_armed(h: PlateHazard, at: Vector2) -> void:
	for i in roundi(3.2 / DT):
		if h.phase[0] == PlateHazard.Phase.ARM:
			return
		h.step(DT, at, PackedVector2Array())
	assert_eq(h.phase[0], PlateHazard.Phase.ARM, "it arms")


func test_an_enemy_arms_it_too() -> void:
	var h := PlateHazard.new(_def([Rect2(0, 0, 3, 3)]), [])
	_run(h, 3.1, Vector2(50, 50))
	var r := _run(h, 1.2, Vector2(50, 50), PackedVector2Array([Vector2(1, 1)]))
	assert_eq(r.armed, 1)
	assert_eq(r.fired, 1)
	assert_eq(h.armed_by_enemy, 1)
	assert_eq(h.armed_by_hero, 0)


func test_asleep_over_a_door_and_three_at_once() -> void:
	var asleep := PlateHazard.new(_def([Rect2(0, 0, 3, 3)]), [], false)
	assert_eq(_run(asleep, 10.0, Vector2(1, 1)).armed, 0, "asleep it never arms (drawn at rest)")
	var door: Array[Rect2] = [Rect2(3.2, 0, 2, 2)]
	var by_door := PlateHazard.new(_def([Rect2(0, 0, 3, 3)]), door)
	assert_eq(_run(by_door, 10.0, Vector2(1, 1)).armed, 0, "a slab at a door's mouth never arms")
	var four: Array[Rect2] = [Rect2(0, 0, 3, 3), Rect2(10, 0, 3, 3), Rect2(20, 0, 3, 3), Rect2(30, 0, 3, 3)]
	var h := PlateHazard.new(_def(four), [])
	_run(h, 3.1, Vector2(-50, 0))
	var bodies := PackedVector2Array([Vector2(1, 1), Vector2(11, 1), Vector2(21, 1), Vector2(31, 1)])
	var most := 0
	for i in 600:
		h.step(DT, Vector2(-50, 0), bodies)
		most = maxi(most, h.busy())
	assert_eq(most, PlateHazard.MOST_AT_ONCE, "never more than two of the room's own warnings at once")


func test_the_state_reaches_from_the_edge_and_the_ember_fades() -> void:
	var h := PlateHazard.new(_def([Rect2(0, 0, 3, 3)]), [])
	_until_armed(h, Vector2(1, 1))
	_run(h, 0.5, Vector2(9, 9))
	assert_almost_eq(h.state(0).x, 0.5, 0.05, "half the warning, half the way in")
	_run(h, 0.55, Vector2(9, 9))
	assert_gt(h.state(0).y, 0.0, "striking")
	_run(h, 0.3, Vector2(9, 9))
	assert_gt(h.state(0).z, 0.0, "the ember after it")
	_run(h, 0.5, Vector2(9, 9))
	assert_eq(h.state(0), Vector3.ZERO, "and at rest again")


## Every room with slabs: the numbers of the plan, whole slabs of 3 x 3 m on the floor, off every piece that stops a
## body, off the doors' mouths and the spawns, 6 m or more from the way in.
func test_where_the_slabs_lie() -> void:
	var seen := 0
	for id: StringName in [&"crypt", &"sanctuary"]:
		var base := _layout(id)
		for v in base.variant_count():
			var l := base.variant(v)
			var h := l.hazard
			assert_not_null(h, "%s %d has slabs" % [id, v])
			assert_eq(h.kind, HazardDef.Kind.PLATES)
			assert_gte(h.warn, 1.0, "never under an enemy's wind-up")
			assert_almost_eq(h.hero_damage, 10.0, 0.001)
			assert_almost_eq(h.enemy_damage, 60.0, 0.001)
			assert_almost_eq(h.rearm, 5.0, 0.001)
			assert_almost_eq(h.start_delay, 3.0, 0.001)
			if id == &"crypt" and v == 0:
				assert_almost_eq(h.from_progress, 0.15, 0.001, "RD-02: the Crypt A teaches from the 3rd room")
				assert_almost_eq(h.warn, 1.5, 0.001, "RD-02: the long warning")
			else:
				assert_almost_eq(h.from_progress, 0.34, 0.001)
			for i in h.plates.size():
				var r := h.plates[i]
				var tag := "%s %d slab %d" % [id, v, i]
				seen += 1
				assert_eq(r.size, Vector2(3, 3), tag)
				for x in 13:
					for z in 13:
						var p := r.position + Vector2(x, z) * 0.25
						assert_true(l.floor.covers(p), "%s: on the floor at %s" % [tag, p])
						for o in l.obstacles:
							if o.blocks_move:
								assert_lt(o.depth(p, 0.0), 0.0, "%s: off the %s at %s" % [tag, o.piece, p])
				for e in l.exits:
					assert_false(e.mouth.grow(0.5).intersects(r), "%s: off a door" % tag)
				for s in l.spawns:
					assert_false(s.intersects(r), "%s: off a spawn" % tag)
				var near := l.hero_spawn.clamp(r.position, r.end)
				assert_gte(near.distance_to(l.hero_spawn), 6.0, "%s: 6 m or more from the way in" % tag)
	assert_eq(seen, 4 + 2 + 4 + 6 + 4,
		"crypt A 4, B 2; sanctuary A 4, B 4 and the two of the crumbling edge (RP-13), C (RP-18) the A's 4")


## From 12 x 12 spots on every slab a person walks off it before it strikes (the warning less a reaction), on the
## floor and clear of every piece, as test_boss_exits.gd for Morvath's attacks.
func test_a_way_off_every_slab() -> void:
	var reach := (1.0 - REACTION) * WALK
	for id: StringName in [&"crypt", &"sanctuary"]:
		var base := _layout(id)
		for v in base.variant_count():
			var l := base.variant(v)
			for r in l.hazard.plates:
				for x in 12:
					for z in 12:
						var p := r.position + Vector2(x + 0.5, z + 0.5) * (r.size.x / 12.0)
						if not _stand(l, p):
							continue  # nobody stands there (a column's foot on the slab's edge)
						assert_true(_walks_off(l, r, p, reach), "%s %d: a way off from %s" % [id, v, p])


func _walks_off(l: RoomLayout, r: Rect2, p: Vector2, reach: float) -> bool:
	for k in 16:
		var d := Vector2.RIGHT.rotated(TAU * k / 16.0)
		var s := 0.0
		while s <= reach:
			var q := p + d * s
			if not _stand(l, q):
				break
			if not r.grow(Player.RADIUS * 0.6).has_point(q):
				return true
			s += 0.1
	return false


func _stand(l: RoomLayout, q: Vector2) -> bool:
	if not l.floor.contains(q, Player.RADIUS * 0.5):
		return false
	for o in l.obstacles:
		if o.blocks_move and o.depth(q, Player.RADIUS) > 0.0:
			return false
	return true


## In a real room: the slab he steps on strikes him 7 a second later and an enemy standing on it 60; "Derrotado por:
## Laje Rachada"; the slabs are drawn at rest (the cracked frame in bone, never the amber) and the room counts it all.
func test_in_a_real_room_it_hurts_both_and_is_counted() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(&"crypt")
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	var pf := game.rooms.plates
	assert_not_null(pf, "a fight in the crypt has its slabs")
	assert_true(pf.hazard.awake, "awake at room 6")
	assert_eq(pf.nodes.size(), 4)
	var m := pf.nodes[0].material_override as ShaderMaterial
	assert_gt(float(m.get_shader_parameter(&"plate")), 0.0, "drawn as a slab")
	assert_eq(m.get_shader_parameter(&"color"), GroundLook.PLATE_REST_COLOR, "at rest in bone, not amber")
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	var slab := l.hazard.plates[2]
	game.player.place(slab.get_center())
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"skeleton"), slab.get_center() + Vector2(0.8, 0.8), false)
	var hp := game.player.hp
	for i in roundi(5.0 / DT):
		game.player.place(slab.get_center())
		e.pos = slab.get_center() + Vector2(0.8, 0.8)
		pf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(game.player.hp, hp - 10.0, 0.01, "the paladin on it loses 10")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "the enemy on it 60")
	assert_eq(game.last_hurt.get("attack", &""), &"plates")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Laje Rachada")
	game.rooms._room_cleared()
	assert_null(game.rooms.plates, "the slabs stop with the fight")
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	assert_eq(hz.get("kind"), "plates")
	assert_almost_eq(float(hz.get("enemy_damage", 0.0)), 60.0, 0.01)
	assert_almost_eq(float(hz.get("hero_damage", 0.0)), 10.0, 0.01, "what it took from him")
	assert_gt(float(hz.get("hero_on_s", 0.0)), 4.0, "the seconds he stood on a slab")
	assert_eq(int(hz.get("strikes", 0)), 1)


## Before the 4th room the slabs lie at rest: drawn, never striking.
func test_asleep_early_in_the_descent() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var l := _layout(&"crypt")
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 2, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	assert_not_null(game.rooms.plates)
	assert_false(game.rooms.plates.hazard.awake, "room 2: asleep")
	r = RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(l), 0)
	game.rooms._enter(r)
	assert_true(game.rooms.plates.hazard.awake, "room 6: awake")


## RP-13's push: whoever a slab with a push strikes is thrown toward the firm floor, swept (never through stone).
func test_a_push_throws_off_the_slab() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rebuild_room(_layout(&"crypt"), 2, 1406)
	game.horde.clear_crowd()
	var def := _def([Rect2(-1.5, 4.5, 3, 3)])
	def.plate_push = PackedVector2Array([Vector2(0, 2.5)])
	def.plate_hero_damage = PackedFloat32Array([5.0])
	var pf := PlateFloor.new(game, def)
	var at := Vector2(0, 6)
	game.player.place(at)
	game.player.invuln = 0.0
	var hp := game.player.hp
	for i in roundi(4.3 / DT):
		if game.player.pos.distance_to(at) < 0.01:
			game.player.place(at)
		pf.step(DT)
		game.ground.step(DT)
	assert_almost_eq(game.player.hp, hp - 5.0, 0.01, "the slab's own damage")
	assert_gt(game.player.pos.y, 7.5, "thrown off toward the firm floor")
	pf.stop()


## RP-13, the edge that crumbles (Santuário B): the two slabs at the ends of the hole hurt 5 (not 7) and throw
## everyone on them away from the hole: from any spot on them the push lands on firm floor; the aisles' slabs as in A.
func test_the_crumbling_edge_of_the_sanctuary_b() -> void:
	var l := _layout(&"sanctuary").variant(1)
	var h := l.hazard
	assert_eq(h.plates.size(), 6)
	for i in 4:
		assert_almost_eq(h.hero_damage_of(i), 10.0, 0.001, "aisle slab %d as in A" % i)
		assert_eq(h.push_of(i), Vector2.ZERO)
	for i in [4, 5]:
		assert_almost_eq(h.hero_damage_of(i), 7.0, 0.001, "edge slab %d: 7" % i)
		var r := h.plates[i]
		var push := h.push_of(i)
		assert_almost_eq(push.length(), 2.5, 0.001)
		var to_hole := Vector2(5.0, 0.0) - r.get_center()
		assert_lt(push.dot(to_hole), 0.0, "edge slab %d throws away from the hole" % i)
		for x in 7:
			for z in 7:
				var p := r.position + Vector2(x, z) * 0.5
				assert_true(l.floor.contains(p + push, Player.RADIUS), "edge slab %d: %s lands on firm floor" % [i, p])
	assert_eq(l.area_at(h.plates[4].get_center()), "hole_edge")
	assert_eq(l.area_at(h.plates[5].get_center()), "hole_edge")
	assert_eq(_layout(&"sanctuary").hazard.plates.size(), 4, "A has no hole: no crumbling edge")


## RD-02: the slab to learn from lies awake before the 5th room, and the 3rd room of the descent is past its progress.
func test_the_teaching_slab_is_awake_before_the_fifth_room() -> void:
	var h := _layout(&"crypt").hazard
	assert_lte(h.from_progress, EncounterGen.progress(stage, 3), "awake at the 3rd room")
	assert_lt(h.from_progress, EncounterGen.progress(stage, 5))
	assert_gte(h.warn, 1.2, "never under the enemies' warning")
	assert_gte(h.start_delay, 3.0, "calm at the start")
