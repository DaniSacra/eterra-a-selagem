extends GutTest
## AT-*3 (backlog P.1, column "Quebráveis"): the rules of each room that the general placement test
## (test_arenas.gd, test_breakables_stand_where_they_may) does not check: never on a deck of the Fendas or the Ponte
## (on the Ponte B's landing only by its edge), the Jardim B's water vases by the wet west edge, never on a rune tile
## that arms (and away from the quiet stone of the Runas B), never between the guardian's spawn and the paladin, and
## 3 m and more from every reliquary of the shop (the last one's 5 items and the route's 3).

const STAGE := "res://data/stages/catacombs.tres"

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l: RoomLayout in stage.layouts:
		if l.id == id:
			return l
	return null


func _arena(l: RoomLayout) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, 3, 1406)
	return a


static func _rect_gap(r: Rect2, p: Vector2) -> float:
	var q := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
	return p.distance_to(q)


## AT-FA3, AT-FB3: never on a bridge's deck (RiftLook.BRIDGES; in the B the north one fell, its floor is gone).
func test_never_on_a_deck_of_the_fendas() -> void:
	var base := _layout(&"rift")
	for v in base.variant_count():
		var l := base.variant(v)
		for p in l.breakables:
			for r in RiftLook.BRIDGES:
				assert_gte(_rect_gap(r, p.at), p.radius + 0.5, "rift %d: %s off the bridge %s" % [v, p.at, r])


## The decks of the Ponte as its look reads them (BridgeLook._read_floor): every floor polygon of 4 corners at most
## DECK_WIDE deep; a wider one between two decks is the landing of the long bridge.
func _decks(l: RoomLayout) -> Array:
	var decks: Array[Rect2] = []
	var wide: Array[Rect2] = []
	for poly in l.floor.polys:
		if poly.size() != 4:
			continue
		var r := Rect2(poly[0], Vector2.ZERO)
		for q in poly:
			r = r.expand(q)
		if r.size.y <= BridgeLook.DECK_WIDE:
			decks.append(r)
		else:
			wide.append(r)
	var landings: Array[Rect2] = []
	for w in wide:
		var west := false
		var east := false
		for d in decks:
			west = west or absf(d.end.x - w.position.x) < 0.2
			east = east or absf(d.position.x - w.end.x) < 0.2
		if west and east:
			landings.append(w)
	return [decks, landings]


## AT-PA3, AT-PB3: never on a bridge; on the B's landing only by its edge, off the line the fight runs along (the
## middle of the decks).
func test_never_on_a_deck_of_the_ponte() -> void:
	var base := _layout(&"bridge")
	for v in base.variant_count():
		var l := base.variant(v)
		var a := _arena(l)
		var found := _decks(l)
		var decks: Array[Rect2] = found[0]
		var landings: Array[Rect2] = found[1]
		assert_false(decks.is_empty(), "bridge %d: its decks" % v)
		for p in l.breakables:
			for d in decks:
				assert_gte(_rect_gap(d, p.at), p.radius + 0.3, "bridge %d: %s off the deck %s" % [v, p.at, d])
				# off the main line: the decks' middle carried over the platforms
				assert_gte(absf(p.at.y - d.get_center().y), 2.5, "bridge %d: %s off the main line" % [v, p.at])
			for w in landings:
				if w.has_point(p.at):
					assert_false(a.inside(p.at, 1.6), "bridge %d: %s on the landing only by its edge" % [v, p.at])


## AT-JB3: the Jardim B's water vases by its wet edge (the lake beyond the west wall, J5): within 2 m of the west
## edge of the floor; at least two of them.
func test_the_garden_b_water_by_the_wet_edge() -> void:
	var l := _layout(&"garden").variant(1)
	var west := l.floor.bounds().position.x
	var water := 0
	for p in l.breakables:
		if p.form == BreakablePiece.Form.WATER:
			water += 1
			assert_lte(p.at.x - west, 2.0, "garden 1: water vase %s by the wet west edge" % p.at)
	assert_gte(water, 2, "garden 1: water vases")


## AT-RA3, AT-RB3: never on a tile that arms (ArenaHazard.live, the doors as the RuneFloor passes them), the piece's
## whole circle; in the B 3 m and more from the quiet stone.
func test_never_on_a_rune_that_arms() -> void:
	var base := _layout(&"runes")
	for v in base.variant_count():
		var l := base.variant(v)
		var a := _arena(l)
		var doors: Array[Rect2] = []
		for z in a.exit_zones:
			doors.append(z)
		for e in l.exits:
			doors.append(e.mouth)
		var rng := RandomNumberGenerator.new()
		rng.seed = 1
		var h := ArenaHazard.new(l.hazard, a.shape(), doors, rng)
		var live := 0
		for i in h.live.size():
			live += h.live[i]
		assert_gt(live, 20, "runes %d: tiles that arm" % v)
		for p in l.breakables:
			for r in l.hazard.rows:
				for c in l.hazard.cols:
					if h.live[r * l.hazard.cols + c] == 1:
						assert_gte(_rect_gap(h.tile_rect(c, r), p.at), p.radius,
							"runes %d: %s off the tile (%d, %d) that arms" % [v, p.at, c, r])
		if v == 1:
			for p in l.breakables:
				for q in l.hazard.quiet:
					if q.get_center().length() < 1.0:
						assert_gte(_rect_gap(q, p.at), 3.0, "runes 1: %s off the quiet stone" % p.at)


## AT-GU3: in the guardians' houses never between his spawn and the paladin's way in (4 m and more from the line between
## them) and only by the edge (the way in and the rim). 2026-11-23: the Knight's hall and the Elder's chamber.
func test_never_between_the_guardian_and_the_paladin() -> void:
	for id: StringName in [&"knight_hall", &"elder_hall"]:
		var base := _layout(id)
		assert_true(base.guardian_home)
		for v in base.variant_count():
			var l := base.variant(v)
			var a := _arena(l)
			for p in l.breakables:
				var q := Geometry2D.get_closest_point_to_segment(p.at, l.boss_spawn, a.start)
				assert_gte(p.at.distance_to(q), 4.0, "%s %d: %s off the guardian's line" % [id, v, p.at])
				assert_false(a.inside(p.at, 2.5), "%s %d: %s by the rim" % [id, v, p.at])


## AT-LO3: 3 m and more from every reliquary of the shop, as Rooms._build_shop lays its row (1 to 5 items: the route
## shop has 3, the last one 5).
func test_three_meters_off_every_reliquary() -> void:
	var l := stage.shop_layout
	assert_not_null(l)
	assert_false(l.breakables.is_empty())
	var right := Feel.screen_to_floor(Vector2.RIGHT, Feel.live().cam_yaw)
	for n in range(1, 6):
		for k in n:
			var item := right * ((k - (n - 1) * 0.5) * Rooms.SHOP_STEP - Rooms.SHOP_SHIFT)
			for p in l.breakables:
				assert_gte(p.at.distance_to(item), 3.0, "shop of %d: %s off the reliquary %d" % [n, p.at, k])
