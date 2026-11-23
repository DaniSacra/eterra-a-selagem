extends GutTest
## C15-02: every event of a fight has a sound (CombatSounds x Audio's recipes), every enemy's wind-up, blow, shot,
## material and fall too, every move of the paladin, and no recipe clips on its own.


func _has(sound: StringName) -> bool:
	return Audio.SOUNDS.has(sound)


func test_every_fight_event_has_a_recipe() -> void:
	for event: StringName in CombatSounds.EVENTS:
		assert_true(_has(CombatSounds.EVENTS[event]), "event %s plays %s, which has no recipe" % [event, CombatSounds.EVENTS[event]])
	for sound in CombatSounds.all_names():
		assert_true(_has(sound), "%s has no recipe" % sound)


func test_the_events_the_brief_names_are_all_there() -> void:
	# golpe por tipo, atordoamento, quebra de armadura, Ômega, círculo, esquiva, golpe sofrido, maldição
	for event: StringName in [&"hit", &"hit_heavy", &"dart_hit", &"interrupt", &"armor_break", &"omega_charge", &"omega_ready",
			&"circle", &"circle_omega", &"circle_burst", &"dodge", &"hurt", &"cursed", &"ward"]:
		assert_true(CombatSounds.EVENTS.has(event), String(event))


func test_every_material_has_its_own_hit_and_fall() -> void:
	var seen := {}
	for m in CombatSounds.MATERIALS:
		var sound := CombatSounds.material(m)
		assert_true(_has(sound), "material %s" % m)
		assert_false(seen.has(sound), "%s sounds unlike the others" % m)
		seen[sound] = true
		assert_true(_has(CombatSounds.KILL_SOUND[m]), "fall on %s" % m)
	assert_eq(CombatSounds.loudest([&"bone", &"spectral"] as Array[StringName]), &"spectral")
	assert_eq(CombatSounds.loudest([&"bone", &"armor"] as Array[StringName]), &"armor")
	assert_eq(CombatSounds.loudest([] as Array[StringName]), &"")


func test_every_enemy_sounds_its_material_windup_blow_and_fall() -> void:
	for f in DirAccess.get_files_at("res://data/enemies/"):
		if not f.ends_with(".tres"):
			continue
		var d: EnemyDef = load("res://data/enemies/" + f)
		assert_true(CombatSounds.MATERIALS.has(d.material), "%s: known material %s" % [d.id, d.material])
		assert_true(_has(CombatSounds.kill(d)), "%s falls" % d.id)
		if d.behavior == EnemyDef.Behavior.BOSS:
			assert_eq(CombatSounds.windup(d), &"", "Morvath's beats are his own")
			continue
		assert_true(_has(CombatSounds.windup(d)), "%s: its wind-up is heard" % d.id)
		var loosed := CombatSounds.strike(d)
		var shoots := d.behavior in [EnemyDef.Behavior.ARCHER, EnemyDef.Behavior.PRIEST, EnemyDef.Behavior.CASTER]
		if shoots:
			assert_true(_has(CombatSounds.shot(d)), "%s: its shot is heard" % d.id)
		elif d.behavior != EnemyDef.Behavior.SUPPORT:  # the Gritador and the Coveiro never strike
			assert_true(_has(loosed), "%s: its blow is heard" % d.id)


func test_each_role_has_its_own_windup() -> void:
	var by_role := {}
	for f in DirAccess.get_files_at("res://data/enemies/"):
		if not f.ends_with(".tres"):
			continue
		var d: EnemyDef = load("res://data/enemies/" + f)
		if d.role != &"" and not d.elite:
			by_role[d.role] = CombatSounds.windup(d)
	assert_eq(by_role.size(), 14, "fourteen roles")
	assert_eq(by_role[&"swarm"], by_role[&"pressure"], "the Trinca's lunge is the skeleton's, so it is heard as one")
	by_role.erase(&"swarm")
	var sounds := {}
	for r in by_role:
		sounds[by_role[r]] = true
	assert_eq(sounds.size(), by_role.size(), "a wind-up sound per role: %s" % str(by_role))


func test_every_move_of_the_paladin_has_a_recipe() -> void:
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var seen := {}
	var todo: Array = tree.neutral.duplicate()
	var n := 0
	while not todo.is_empty():
		var node: ComboNode = todo.pop_back()
		if seen.has(node):
			continue
		seen[node] = true
		n += 1
		assert_ne(node.sound, &"", "%s has a sound" % node.id)
		assert_true(_has(node.sound), "%s plays %s" % [node.id, node.sound])
		todo.append_array(node.following())
	assert_gt(n, 4)


func test_no_recipe_clips_on_its_own() -> void:
	for sound: StringName in Audio.SOUNDS:
		var samples := PackedFloat32Array()
		for v: Array in Audio.SOUNDS[sound]:
			samples = Synth.mix(samples, Synth.tone(v[0], v[1], v[2], v[3], v[4], 0.004, v[5]), v[6])
		var peak := 0.0
		for x in samples:
			peak = maxf(peak, absf(x))
		assert_lte(peak, 0.95, "%s peaks at %.2f" % [sound, peak])


func test_the_master_limiter_holds_at_minus_one_db() -> void:
	var limiter := Audio.limit_master()
	assert_almost_eq(limiter.ceiling_db, Audio.LIMIT_DB, 0.001)
	assert_lte(Audio.LIMIT_DB, -1.0, "room under -1 dBTP for the peaks between samples")
