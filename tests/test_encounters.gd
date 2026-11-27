extends GutTest
## How many enemies stand at once and how a fight is put together (cycle 8, Daniel 2026-11-15: few enemies, each
## with its part, as in Hades II): the tiers' ranges, the ceiling of 20, the parts by depth, Morvath's reinforcements.

var stage: StageDef
## The same region at its full length (10 rooms, elites from depth 3), as in Hades II.
var full: StageDef
var defs: Dictionary
var rng: RandomNumberGenerator


func before_each() -> void:
	stage = load("res://data/stages/catacombs.tres")
	full = stage.duplicate()
	full.rooms = 10
	full.elite_from_depth = 3
	defs = {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	rng = RandomNumberGenerator.new()
	rng.seed = 23


func _elites(kinds: Array[StringName]) -> int:
	var n := 0
	for id in kinds:
		if (defs[id] as EnemyDef).elite:
			n += 1
	return n


func test_the_numbers_daniel_asked_for() -> void:
	assert_eq(stage.alive_cap, 20)
	assert_eq(stage.tier_alive[StageDef.Tier.COMMON], Vector2i(3, 6))
	assert_eq(stage.tier_alive[StageDef.Tier.HARD], Vector2i(7, 11))
	assert_eq(stage.tier_alive[StageDef.Tier.SPECIAL], Vector2i(11, 15))
	assert_eq(stage.miniboss_tier, StageDef.Tier.HARD, "the guardian's room is hard")


func test_cap_grows_down_the_region_inside_the_tier() -> void:
	assert_eq(EncounterGen.progress(full, 1), 0.0)
	assert_eq(EncounterGen.progress(full, 9), 1.0, "the last fight before the shop")
	assert_eq(EncounterGen.cap(full, StageDef.Tier.COMMON, 1), 3)
	assert_eq(EncounterGen.cap(full, StageDef.Tier.COMMON, 9), 6)
	assert_eq(EncounterGen.cap(full, StageDef.Tier.HARD, 1), 7)
	assert_eq(EncounterGen.cap(full, StageDef.Tier.SPECIAL, 9), 15)
	for depth in range(1, 10):
		var c := EncounterGen.cap(full, StageDef.Tier.COMMON, depth)
		assert_between(c, 3, 6)
	var tight := full.duplicate() as StageDef
	tight.alive_cap = 10
	assert_eq(EncounterGen.alive_range(tight, StageDef.Tier.SPECIAL), Vector2i(10, 10), "the ceiling wins over any tier")


func test_room_for_summons() -> void:
	assert_eq(EncounterGen.room_for(0, 20, 3), 3)
	assert_eq(EncounterGen.room_for(18, 20, 3), 2, "a summon past the ceiling raises fewer")
	assert_eq(EncounterGen.room_for(20, 20, 3), 0, "at the ceiling, none")
	assert_eq(EncounterGen.room_for(25, 20, 3), 0)


func test_no_wave_and_no_floor_past_the_tier_or_twenty() -> void:
	for st: StageDef in [stage, full]:
		for depth in range(1, st.rooms):
			if st.opening_waves.has(depth):
				continue  # (SW-R1b: written by hand, a few heads a wave)
			for i in 60:
				var fight := EncounterGen.generate(st, depth, defs, rng)
				var r := EncounterGen.alive_range(st, fight.tier)
				assert_between(fight.cap, r.x, r.y, "the floor stays in the tier's range")
				assert_lte(fight.ceiling, st.alive_cap)
				assert_lte(fight.cap, fight.ceiling)
				assert_between(fight.waves.size(), 1, 3)
				for w: Array in fight.waves:  # (C5: a head of a trinca stands for its figures: bodies, not heads)
					# (SW-R1: a wave is a queue that rises as the floor has room, the tier's range is what stands at once: cap)
					assert_between(EncounterGen.bodies(w, defs), mini(r.x, st.long_fewest) if EncounterGen.is_long(st, depth) else r.x, st.wave_most + 1, "a wave fits its queue (depth %d, tier %d)" % [depth, fight.tier])


func test_parts_grow_with_depth() -> void:
	var elites_late := 0
	for i in 200:
		var top := EncounterGen.generate(full, 1, defs, rng)
		assert_eq(top.kinds.size(), 1, "room 1 of the region: a single part (C2)")
		assert_eq(_elites(top.kinds), 0, "no elite before elite_from_depth")
		assert_eq(top.tier, StageDef.Tier.COMMON)
		var middle := EncounterGen.generate(full, 5, defs, rng)
		assert_between(middle.kinds.size(), 2, 3, "the middle: two or three parts")
		var bottom := EncounterGen.generate(full, 9, defs, rng)
		assert_between(bottom.kinds.size(), 3, 4, "the bottom: demanding mixes, never every kind at once")
		assert_lte(_elites(bottom.kinds), full.max_elite_types)
		elites_late += _elites(bottom.kinds)
		for fight: EncounterGen.Fight in [top, middle, bottom]:
			var roles := {}
			for id in fight.kinds:
				var d := defs[id] as EnemyDef
				assert_false(roles.has(d.role), "one kind for each part")
				roles[d.role] = true
				assert_false(fight.kinds.has(d.elite_version), "never a kind with its own elite")
			if _elites(fight.kinds) > 0:
				assert_gte(fight.tier, StageDef.Tier.HARD, "an elite makes the fight hard")
	assert_gt(elites_late, 50, "elites are likely at the bottom")


func test_every_part_has_a_plain_kind_and_its_elite_plays_it_too() -> void:
	var roles := {}
	for id in stage.enemies:
		var d := defs[id] as EnemyDef
		assert_ne(d.role, &"", "%s plays a part" % id)
		roles[d.role] = true
		if d.elite_version != &"":
			assert_eq((defs[d.elite_version] as EnemyDef).role, d.role)
	for pool in stage.pools:
		assert_between(pool.roles.size(), 1, 4)
		for role in pool.roles:
			assert_true(roles.has(role), "the part %s is played by someone" % role)


func test_horde_summons_stop_at_its_ceiling() -> void:
	var horde := Horde.new()
	for i in 10:
		horde.list.append(Enemy.new())
	assert_eq(horde.room_for(3), 3, "no ceiling (the endless hall)")
	horde.alive_cap = 12
	assert_eq(horde.room_for(3), 2)
	horde.alive_cap = 10
	assert_eq(horde.room_for(3), 0)
	horde.free()
