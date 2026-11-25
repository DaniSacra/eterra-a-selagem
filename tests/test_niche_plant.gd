extends GutTest
## The atlas's hazard prototypes AT-H2 and AT-H3 (docs/backlog.md P.4, combat_cadence.md 9.3; Q-AT3 a, Q-AT4 a).
## The skeleton in the Cripta B's niche: a strip of 2.2 m before the niche on the west wall wakes with someone in it
## (him 0.3 s, an enemy 0.2 s), warns 1.2 s, grabs 10 / 60 and pulls 1 m toward the niche over 0.12 s without holding,
## the pull cut short at another warning (R10); a blow of the Emeth only sparks. The hostile plant of the Jardim B (RP-10's
## new skin, where the stub root was): a strip of 2.5 x 1.5 m, 0.5 s, 1.2 s, 10 / 60 and a push of 1 m out of it; the
## Emeth only sparks. Both asleep before the 4th room, off the doors, 6 m off the way in.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const ARC := ComboNode.Shape.ARC

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _base(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


## The data: where they stand and their numbers.
func test_where_the_niche_and_the_plant_are() -> void:
	var crypt := _base(&"crypt").variant(1)
	var garden := _base(&"garden").variant(1)
	var niche := crypt.hazard.also
	var plant := garden.hazard.also
	assert_not_null(niche, "Cripta B has the niche")
	assert_not_null(plant, "Jardim B has the plant")
	assert_eq(niche.plate_source, Ground.NICHE_SOURCE)
	assert_eq(plant.plate_source, Ground.PLANT_SOURCE)
	for h: HazardDef in [niche, plant]:
		assert_almost_eq(h.warn, 1.2 if h == niche else 1.5, 0.001, "1.2 s with the 10 (the plant 1.5 s, RD2-04)")
		assert_almost_eq(h.hero_damage, 10.0, 0.001)
		assert_almost_eq(h.enemy_damage, 60.0, 0.001)
		assert_almost_eq(h.from_progress, 0.34, 0.001, "from the 4th room")
		assert_eq(h.sparks.size(), 1, "a blow sparks on it")
	assert_almost_eq(niche.pull, 1.0, 0.001, "a pull of 1 m (Q-AT3 a)")
	assert_almost_eq(niche.dwell, 0.3, 0.001)
	assert_almost_eq(plant.push_out, 1.0, 0.001)
	assert_almost_eq(plant.dwell, 0.5, 0.001)
	assert_lte(plant.strip_width, 2.5, "a side way out of 1.25 m at most (RD2-04: wider so the horde meets it)")
	for pair: Array in [[crypt, niche], [garden, plant]]:
		var l: RoomLayout = pair[0]
		var h: HazardDef = pair[1]
		var ph := PlateHazard.new(h, [])
		var box := ph.bounds(0)
		for k in 11:
			for j in 11:
				var p := box.position + box.size * Vector2(k / 10.0, j / 10.0)
				p = p.clamp(box.position + Vector2(0.05, 0.05), box.end - Vector2(0.05, 0.05))
				assert_true(l.floor.contains(p), "%s: whole on the floor at %s" % [h.plate_source, p])
				assert_gte(p.distance_to(l.hero_spawn), 6.0, "%s: 6 m off the way in" % h.plate_source)
		for e in l.exits:
			assert_false(e.mouth.grow(0.5).intersects(box), "%s: off the doors" % h.plate_source)
	# the niche: off the slits' bands and 1.5 m and more from the slabs
	var nbox := PlateHazard.new(niche, []).bounds(0)
	var slabs := crypt.hazard
	for i in slabs.aims.size():
		var a := slabs.aims[i]
		var band := Rect2(Vector2(a.x - slabs.aim_width * 0.5, minf(a.y, a.w)), Vector2(slabs.aim_width, absf(a.w - a.y)))
		assert_false(band.grow(0.5).intersects(nbox), "off the slit %d" % i)
	for r in slabs.plates:
		assert_false(r.grow(1.5).intersects(nbox), "1.5 m from the slab %s" % r)


func _room(id: StringName, variant: int) -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(_base(id)), variant)
	game.rooms._enter(r)
	game.horde.clear_crowd()
	game.rooms._queue.clear()
	game.rooms._waves.clear()
	return game


## In a real room: he stands in the niche's strip, it grabs him 10 and pulls him toward the niche over several frames
## (never in one), an enemy in it takes 60; "Esqueleto do Nicho"; counted.
func test_the_niche_grabs_and_pulls_without_holding() -> void:
	var game := _room(&"crypt", 1)
	var pf := game.rooms.plates_also
	assert_not_null(pf, "a fight in the Cripta B has its niche")
	assert_not_null(game.rooms.plates, "beside its slabs")
	var h := pf.hazard.def
	var at := Vector2(-10.6, -6.5)
	game.player.place(at)
	game.player.invuln = 0.0
	var e := game.horde.spawn(game.horde.def(&"guard"), Vector2(-10.4, -5.6), false)
	var hp := game.player.hp
	var struck_at := -1
	var step := 0
	var first_move := 0.0
	for i in roundi(6.0 / DT):
		if struck_at < 0:
			game.player.place(at)
			e.pos = Vector2(-10.4, -5.6)
		var before := game.player.pos
		pf.step(DT)
		game.ground.step(DT)
		if struck_at < 0 and game.player.hp < hp:
			struck_at = i
		elif struck_at >= 0 and step == 0:
			first_move = before.distance_to(game.player.pos)
			step = 1
	assert_gt(struck_at, 0, "it grabbed him")
	assert_almost_eq(hp - game.player.hp, 10.0, 0.01, "10 to him")
	assert_lt(first_move, 0.6, "the pull is no teleport (one frame moves part of it)")
	assert_almost_eq(game.player.pos.x, at.x - 1.0, 0.15, "pulled about 1 m toward the niche (the wall stops it at its body)")
	assert_almost_eq(e.max_hp - e.hp, 60.0, 0.01, "60 to the enemy in it")
	assert_lt(e.pos.x, -10.4, "the enemy pulled toward the niche too")
	assert_eq(game.last_hurt.get("attack", &""), &"niche")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Esqueleto do Nicho")
	game.rooms._room_cleared()
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	var hz: Dictionary = room.get("hazard", {})
	var niche: Dictionary = RoomTally.find_hazard(hz, "niche")
	assert_eq(niche.get("kind"), "niche")
	assert_eq(int(niche.get("pulled", 0)), 1)
	assert_almost_eq(float(niche.get("hero_damage", 0.0)), 10.0, 0.01)


## R10: a pull that would end in another warning stops at its edge; a dodge cuts the pull off.
func test_the_pull_never_lands_him_in_another_warning() -> void:
	var game := _room(&"crypt", 1)
	var pf := game.rooms.plates_also
	var dir := Vector2.LEFT
	for k in 12:
		var p := Vector2(-10.0 - k * 0.1, -6.5 + (k % 3) * 0.5)
		var w := game.ground.add_warning(p + dir * 1.3, 0.5, 5.0, 0.0)
		var reach := pf.pull_reach(p, dir, 1.0, null)
		var end := p + dir * reach
		assert_false(Ground.inside(w, end), "pulled from %s: outside the other warning" % p)
		assert_lt(reach, 1.0, "cut short")
		Ground.end_zone(w)
	# and with nothing in the way the whole metre (until the wall: the niche is at x -12)
	assert_almost_eq(pf.pull_reach(Vector2(-10.4, -6.5), dir, 1.0, null), 1.0, 0.06)


## A blow of the Emeth on the skeleton or the plant only sparks: nothing hurt, nothing struck, counted as a spark.
func test_a_blow_only_sparks() -> void:
	for pair: Array in [[&"crypt", Vector2(-12.0, -6.5)], [&"garden", Vector2(-16.6, -1.5)]]:
		var game := _room(pair[0], 1)
		var pf := game.rooms.plates_also
		var at: Vector2 = pair[1]
		var from := at + Vector2(1.6, 0.0)
		game.player.place(from)
		var hp := game.player.hp
		game.combat.reached.emit(ARC, from, Vector2.LEFT, 2.5, 120.0)
		assert_eq(pf.sparked, 1, "%s: a spark" % pair[0])
		assert_eq(game.player.hp, hp)
		assert_eq(pf.hazard.phase[0], PlateHazard.Phase.IDLE, "%s: a blow does not wake it" % pair[0])


## In a real room: the plant lashes him 10, pushes him 1 m out of its strip, "Planta Hostil".
func test_the_plant_lashes_and_pushes() -> void:
	var game := _room(&"garden", 1)
	var pf := game.rooms.plates_also
	assert_not_null(pf, "a fight in the Jardim B has its plant")
	assert_not_null(game.rooms.plates, "beside its root")
	var at := Vector2(-15.0, -1.3)
	game.player.place(at)
	game.player.invuln = 0.0
	var hp := game.player.hp
	var struck := false
	for i in roundi(6.0 / DT):
		if not struck:
			game.player.place(at)
		pf.step(DT)
		game.ground.step(DT)
		struck = struck or game.player.hp < hp
	assert_true(struck)
	assert_almost_eq(hp - game.player.hp, 10.0, 0.01)
	assert_gt(game.player.pos.y, -0.8, "pushed out of the strip (north side to south)")
	assert_eq(T.t(DefeatCause.text_key(game.last_hurt)), "Planta Hostil")


## AT-H1 (the pressure slab of the Santuário is RP-06): every aisle slab of each variant lies in a flank with a way
## round it: a lane of 1.0 m beside it (north or south), along its whole length, on the floor and clear of every piece.
func test_the_santuario_slabs_have_a_way_round() -> void:
	var base := _base(&"sanctuary")
	for v in base.variant_count():
		var l := base.variant(v)
		for r in l.hazard.plates:
			if absf(r.get_center().y) < 5.0:
				continue  # RP-13's edge slabs by the hole (in the nave)
			var found := false
			for side: float in [-1.0, 1.0]:
				var lane := Rect2(r.position.x, r.position.y - 1.2 if side < 0 else r.end.y + 0.2, r.size.x, 1.0)
				var clear := true
				for k in 13:
					for j in 5:
						var p := lane.position + lane.size * Vector2(k / 12.0, j / 4.0)
						if not l.floor.contains(p):
							clear = false
						for o in l.obstacles:
							if o.blocks_move and o.depth(p, Player.RADIUS) > 0.0:
								clear = false
				found = found or clear
			assert_true(found, "sanctuary %d: a way round the slab %s" % [v, r])


## SW-G7: in a real Cripta A the slabs are the room's pieces: at rest the drawn frame hides and the piece rests; warming
## up the amber frame shows and the piece is told the windup.
func test_the_slabs_drive_the_room_pieces() -> void:
	var game := _room(&"crypt", 0)
	var pf := game.rooms.plates
	assert_not_null(pf)
	assert_not_null(pf.pieces[0], "the slab has its piece")
	assert_false(pf.nodes[0].visible, "at rest: only the piece")
	var r: Rect2 = pf.hazard.def.plates[0]
	game.player.place(r.get_center())
	game.player.invuln = 99.0
	var seen_arm := false
	for i in roundi(4.0 / DT):
		game.player.place(r.get_center())
		pf.step(DT)
		game.ground.step(DT)
		if pf.hazard.state(0).x > 0.0:
			seen_arm = true
			assert_true(pf.nodes[0].visible, "warming: the amber frame shows")
			assert_gt(pf.pieces[0]._arm, 0.0, "and the piece is told")
			break
	assert_true(seen_arm, "it armed")
