extends SceneTree
## One-off generator of the content files in data/ (combos, enemies, gifts, waves) for the 3D version.
## The .tres files it writes are the source of truth afterwards: tune them in the editor or by hand.
## ~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves]

const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY
const C := ComboNode.In.CHARGE

## Swing peak (seconds into the clip) of the knight's attack animations, measured from the hand bone.
const PEAK := {
	&"1H_Melee_Attack_Slice_Diagonal": 0.38, &"1H_Melee_Attack_Slice_Horizontal": 0.27, &"1H_Melee_Attack_Chop": 0.59,
	&"1H_Melee_Attack_Stab": 0.40, &"2H_Melee_Attack_Slice": 0.39, &"2H_Melee_Attack_Chop": 0.73, &"2H_Melee_Attack_Spinning": 0.27,
	&"2H_Melee_Attack_Stab": 0.40, &"Spellcast_Raise": 0.28, &"Jump_Full_Short": 0.43,
}


func _initialize() -> void:
	var only := OS.get_cmdline_user_args()
	for part in ["combos", "enemies", "boons", "waves"]:
		if only.is_empty() or only.has(part):
			call("_" + part)
			print("wrote ", part)
	quit()


# ---------- combos ----------

func _move(id: StringName, input: ComboNode.In, anim: StringName, tags: Array[StringName], props: Dictionary, next: Array[ComboNode] = [], title: StringName = &"") -> ComboNode:
	var n := ComboNode.new()
	n.id = id
	n.input = input
	n.anim = anim
	n.tags = tags
	n.title = title
	for k: String in props:
		n.set(k, props[k])
	n.next = next
	# start the clip a little before the swing so the blade lands exactly when the windup ends
	var peak: float = PEAK.get(anim, 0.3)
	n.anim_from = maxf(0.0, peak - 0.22)
	n.anim_speed = maxf(1.0, (peak - n.anim_from) / maxf(n.windup, 0.01))
	return n


func _combos() -> void:
	var spin := _move(&"spin", L, &"2H_Melee_Attack_Spinning", [&"light", &"spin", &"finisher"],
		{"damage": 22.0, "shape": ComboNode.Shape.CIRCLE, "reach": 4.0, "knockback": 12.0, "windup": 0.12, "recovery": 0.26, "hit_stop_ms": 70.0, "shake": 1.5}, [], &"move_spin")
	var thrust := _move(&"thrust", H, &"1H_Melee_Attack_Stab", [&"heavy", &"thrust", &"finisher"],
		{"damage": 30.0, "shape": ComboNode.Shape.LINE, "reach": 7.0, "width": 1.6, "knockback": 9.0, "lunge": 1.5, "windup": 0.14, "recovery": 0.25, "hit_stop_ms": 70.0, "shake": 1.5}, [], &"move_thrust")
	var cut3 := _move(&"cut3", L, &"1H_Melee_Attack_Chop", [&"light"],
		{"damage": 13.0, "reach": 3.3, "width": 160.0, "knockback": 8.0, "lunge": 0.8, "windup": 0.1, "recovery": 0.18, "hit_stop_ms": 45.0, "shake": 0.7}, [spin, thrust])
	var cross := _move(&"cross", H, &"2H_Melee_Attack_Chop", [&"heavy", &"cross", &"finisher"],
		{"damage": 18.0, "reach": 3.4, "width": 170.0, "knockback": 8.0, "windup": 0.16, "recovery": 0.24, "hit_stop_ms": 60.0, "shake": 1.3,
		"effect": ComboNode.Effect.GROUND_MARK, "effect_power": 9.0, "effect_time": 4.0, "effect_radius": 2.8}, [], &"move_cross")
	var cut2 := _move(&"cut2", L, &"1H_Melee_Attack_Slice_Horizontal", [&"light"],
		{"damage": 10.0, "reach": 3.0, "width": 150.0, "knockback": 6.0, "lunge": 0.5, "windup": 0.08, "recovery": 0.16, "hit_stop_ms": 40.0, "shake": 0.5}, [cut3, cross])
	var launch := _move(&"launch", H, &"2H_Melee_Attack_Slice", [&"heavy", &"launch", &"finisher"],
		{"damage": 14.0, "reach": 3.2, "width": 150.0, "knockback": 1.0, "windup": 0.12, "recovery": 0.2, "hit_stop_ms": 60.0, "shake": 1.3,
		"effect": ComboNode.Effect.LAUNCH, "effect_time": 1.0}, [], &"move_launch")
	var cut1 := _move(&"cut1", L, &"1H_Melee_Attack_Slice_Diagonal", [&"light"],
		{"damage": 10.0, "reach": 3.0, "width": 150.0, "knockback": 6.0, "lunge": 0.5, "windup": 0.09, "recovery": 0.16, "hit_stop_ms": 40.0, "shake": 0.5}, [cut2, launch])
	var wave := _move(&"wave", L, &"2H_Melee_Attack_Stab", [&"light", &"wave", &"finisher"],
		{"damage": 14.0, "reach": 3.4, "width": 140.0, "knockback": 8.0, "windup": 0.12, "recovery": 0.24, "hit_stop_ms": 55.0, "shake": 1.3,
		"effect": ComboNode.Effect.WAVE, "effect_power": 24.0, "effect_radius": 12.0}, [], &"move_wave")
	var heavy2 := _move(&"heavy2", H, &"2H_Melee_Attack_Chop", [&"heavy"],
		{"damage": 24.0, "reach": 3.8, "width": 180.0, "knockback": 16.0, "lunge": 0.8, "windup": 0.22, "recovery": 0.24, "chain_window": 0.4, "hit_stop_ms": 65.0, "shake": 1.4}, [wave])
	var heavy1 := _move(&"heavy1", H, &"2H_Melee_Attack_Slice", [&"heavy"],
		{"damage": 20.0, "reach": 3.6, "width": 170.0, "knockback": 14.0, "lunge": 0.8, "windup": 0.2, "recovery": 0.22, "chain_window": 0.4, "hit_stop_ms": 60.0, "shake": 1.2}, [heavy2])
	var burst := _move(&"burst", C, &"Spellcast_Raise", [&"heavy", &"charge", &"finisher"],
		{"damage": 34.0, "shape": ComboNode.Shape.CIRCLE, "reach": 5.5, "knockback": 14.0, "windup": 0.08, "recovery": 0.3, "hit_stop_ms": 80.0, "shake": 2.5,
		"effect": ComboNode.Effect.STUN, "effect_time": 2.0}, [], &"move_burst")
	var dash_cut := _move(&"dash_cut", L, &"1H_Melee_Attack_Stab", [&"light", &"dash", &"finisher"],
		{"damage": 20.0, "shape": ComboNode.Shape.LINE, "reach": 5.5, "width": 1.6, "knockback": 6.0, "lunge": 4.0, "windup": 0.1, "recovery": 0.16, "hit_stop_ms": 55.0, "shake": 1.0}, [], &"move_dash_cut")
	var slam := _move(&"slam", H, &"Jump_Full_Short", [&"heavy", &"slam", &"finisher"],
		{"damage": 28.0, "shape": ComboNode.Shape.CIRCLE, "reach": 4.5, "knockback": 16.0, "lunge": 2.5, "windup": 0.18, "recovery": 0.26, "hit_stop_ms": 80.0, "shake": 2.5,
		"effect": ComboNode.Effect.STUN, "effect_time": 0.6}, [], &"move_slam")
	var tree := ComboTree.new()
	tree.neutral = [cut1, heavy1, burst]
	tree.dodge = [dash_cut, slam]
	_save(tree, "res://data/combos/paladin.tres")


# ---------- enemies ----------

func _enemy(props: Dictionary) -> void:
	var d := EnemyDef.new()
	for k: String in props:
		d.set(k, props[k])
	if d.name_key == &"":
		d.name_key = StringName("enemy_" + String(d.id))
	_save(d, "res://data/enemies/%s.tres" % d.id)


func _enemies() -> void:
	var B := EnemyDef.Behavior
	_enemy({"id": &"skeleton", "model": &"minion", "hp": 22.0, "speed": 2.3, "damage": 6.0, "radius": 0.45, "xp": 1})
	_enemy({"id": &"archer", "model": &"rogue", "behavior": B.ARCHER, "hp": 16.0, "speed": 2.6, "damage": 5.0, "radius": 0.45, "xp": 2,
		"attack_damage": 8.0, "attack_range": 10.0, "attack_cooldown": 3.2, "attack_windup": 0.7, "tint": Color(0.85, 0.95, 0.85)})
	_enemy({"id": &"runner", "model": &"runner", "behavior": B.RUNNER, "hp": 24.0, "speed": 4.0, "damage": 6.0, "radius": 0.45, "xp": 2,
		"attack_damage": 10.0, "attack_range": 5.5, "attack_cooldown": 2.4, "attack_windup": 0.5, "tint": Color(0.8, 0.85, 1.0)})
	_enemy({"id": &"mage", "model": &"mage", "behavior": B.CASTER, "hp": 28.0, "speed": 2.0, "damage": 5.0, "radius": 0.45, "xp": 3,
		"attack_damage": 14.0, "attack_range": 11.0, "attack_cooldown": 4.0, "attack_windup": 0.8})
	_enemy({"id": &"guard", "model": &"warrior", "size": 1.15, "hp": 80.0, "speed": 1.7, "damage": 10.0, "radius": 0.6, "xp": 4, "heavy": true})
	_enemy({"id": &"knight", "model": &"warrior", "size": 1.8, "behavior": B.KNIGHT, "hp": 1100.0, "speed": 2.4, "damage": 12.0, "radius": 1.0, "xp": 60,
		"heavy": true, "elite": true, "attack_damage": 22.0, "attack_range": 12.0, "attack_cooldown": 4.5, "attack_windup": 0.9,
		"rim_color": Color(1.0, 0.35, 0.15), "rim": 1.6})
	_enemy({"id": &"priest", "model": &"mage", "size": 1.8, "behavior": B.PRIEST, "hp": 900.0, "speed": 2.0, "damage": 10.0, "radius": 0.9, "xp": 60,
		"heavy": true, "elite": true, "attack_damage": 18.0, "attack_range": 10.0, "attack_cooldown": 3.8, "attack_windup": 1.0,
		"rim_color": Color(0.75, 0.35, 1.0), "rim": 1.6})
	_enemy({"id": &"morvath", "model": &"morvath", "size": 2.5, "behavior": B.BOSS, "hp": 7000.0, "speed": 3.0, "damage": 16.0, "radius": 1.4, "xp": 0,
		"heavy": true, "attack_damage": 20.0, "tint": Color(0.62, 0.52, 0.82), "rim_color": Color(0.7, 0.3, 1.0), "rim": 2.0})


# ---------- gifts ----------

func _mod(stat: StringName, values: Array, tag: StringName = &"") -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.tag = tag
	m.values = PackedFloat32Array(values)
	return m


func _skill(kind: SkillDef.Kind, props: Dictionary) -> SkillDef:
	var s := SkillDef.new()
	s.kind = kind
	for k: String in props:
		s.set(k, PackedFloat32Array(props[k]) if props[k] is Array else props[k])
	return s


func _boon(n: int, id: StringName, family: Boon.Family, icon: int, mods: Array[BoonMod], skill: SkillDef = null, requires: Array[StringName] = []) -> void:
	var b := Boon.new()
	b.id = id
	b.family = family
	b.icon = icon
	b.mods = mods
	b.skill = skill
	b.requires = requires
	_save(b, "res://data/boons/%02d_%s.tres" % [n, id])


func _boons() -> void:
	for f in DirAccess.get_files_at("res://data/boons"):
		DirAccess.remove_absolute("res://data/boons/" + f)
	var F := Boon.Family
	var K := SkillDef.Kind
	_boon(0, &"brasas", F.CHAMA, 0, [], _skill(K.STRIKES, {"damage": [18, 26, 36], "count": [3, 4, 6], "cooldown": [3.5, 3.0, 2.5], "radius": [2.2, 2.4, 2.6], "status": &"burn", "status_power": [5, 7, 9]}))
	_boon(1, &"redemoinho", F.CHAMA, 1, [], _skill(K.ORBIT, {"damage": [10, 14, 19], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"burn", "status_power": [4, 6, 8]}))
	_boon(2, &"lamina_ardente", F.CHAMA, 2, [_mod(&"burn_dps", [6, 9, 12], &"finisher"), _mod(&"damage_pct", [0.2, 0.35, 0.5], &"finisher")])
	_boon(3, &"toque_geada", F.GEADA, 3, [_mod(&"freeze_time", [1.0, 1.5, 2.0], &"heavy")])
	_boon(4, &"estilhaco", F.GEADA, 4, [_mod(&"shatter_pct", [0.5, 0.8, 1.0])], _skill(K.NOVA, {"damage": [20, 30, 42], "cooldown": [6, 5, 4], "radius": [5, 6, 7], "status": &"freeze", "status_power": [1.2, 1.5, 1.8]}))
	_boon(5, &"peso_inverno", F.GEADA, 5, [], _skill(K.METEOR, {"damage": [60, 90, 130], "cooldown": [9, 8, 7], "radius": [4.0, 4.5, 5.0], "status": &"freeze", "status_power": [2.0, 2.2, 2.5]}))
	_boon(6, &"consolo", F.LUZ, 6, [_mod(&"heal_on_kill", [0.4, 0.7, 1.0])])
	_boon(7, &"onda_maior", F.LUZ, 7, [], _skill(K.FAN, {"damage": [16, 22, 30], "count": [5, 8, 11], "cooldown": [5.0, 4.5, 4.0], "radius": [12, 13, 14]}))
	_boon(8, &"flagelo", F.LUZ, 8, [], _skill(K.STRIKES, {"damage": [24, 32, 44], "count": [4, 6, 9], "cooldown": [4.5, 4.0, 3.5], "radius": [1.6, 1.8, 2.0], "status": &"stun", "status_power": [0.4, 0.5, 0.6]}))
	_boon(9, &"escudo", F.VIGILIA, 9, [_mod(&"shield_cooldown", [12, 9, 6])])
	_boon(10, &"passos", F.VIGILIA, 10, [_mod(&"dodge_charges", [1, 1, 2]), _mod(&"move_speed_pct", [0.08, 0.14, 0.2])])
	_boon(11, &"firmeza", F.VIGILIA, 11, [_mod(&"max_hp", [20, 35, 50])], _skill(K.CONSECRATE, {"damage": [12, 18, 26], "cooldown": [8, 7, 6], "radius": [4, 5, 6], "status": &"slow", "status_power": [4.0, 4.5, 5.0]}))
	_boon(12, &"vapor", F.DUO, 12, [_mod(&"steam_time", [2, 3, 4])], null, [&"brasas", &"toque_geada"])
	_boon(13, &"aurora", F.DUO, 13, [_mod(&"freeze_time", [0.8, 1.2, 1.6], &"luz")], null, [&"onda_maior", &"toque_geada"])
	_boon(14, &"chama_viva", F.DUO, 14, [_mod(&"burn_dps", [5, 8, 11], &"luz")], null, [&"brasas", &"flagelo"])
	_boon(15, &"bastiao", F.DUO, 15, [_mod(&"shield_burst", [40, 70, 100])], null, [&"escudo", &"consolo"])
	_boon(16, &"rastro", F.DUO, 16, [_mod(&"dodge_ember_dps", [8, 12, 16])], null, [&"passos", &"brasas"])
	_boon(17, &"passo_frio", F.DUO, 17, [_mod(&"freeze_time", [1.0, 1.5, 2.0], &"dash")], null, [&"passos", &"toque_geada"])


# ---------- waves ----------

func _segment(from: float, until: float, enemies: Array[StringName], weights: Array, rate: Vector2, cap: Vector2i) -> WaveSegment:
	var s := WaveSegment.new()
	s.from = from
	s.until = until
	s.enemies = enemies
	s.weights = PackedFloat32Array(weights)
	s.rate_start = rate.x
	s.rate_end = rate.y
	s.cap_start = cap.x
	s.cap_end = cap.y
	return s


func _event(time: float, kind: WaveEvent.Kind, enemy: StringName = &"") -> WaveEvent:
	var e := WaveEvent.new()
	e.time = time
	e.kind = kind
	e.enemy = enemy
	return e


func _waves() -> void:
	var t := WaveTable.new()
	t.segments = [
		_segment(0, 60, [&"skeleton"], [1], Vector2(1.4, 2.6), Vector2i(25, 50)),
		_segment(60, 180, [&"skeleton", &"archer", &"guard"], [8, 1, 0.6], Vector2(2.6, 4.0), Vector2i(50, 110)),
		_segment(180, 300, [&"skeleton", &"archer", &"guard", &"runner"], [7, 1.2, 0.8, 1.6], Vector2(4.0, 5.5), Vector2i(110, 170)),
		_segment(300, 480, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.3, 1.0, 1.8, 0.9], Vector2(5.5, 7.0), Vector2i(170, 230)),
		_segment(480, 600, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.4, 1.2, 2.0, 1.1], Vector2(7.0, 8.5), Vector2i(230, 270)),
		_segment(600, 900, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.5, 1.4, 2.2, 1.3], Vector2(8.5, 10.0), Vector2i(270, 300)),
	]
	t.events = [_event(300, WaveEvent.Kind.ELITE, &"knight"), _event(420, WaveEvent.Kind.FOUNTAIN), _event(600, WaveEvent.Kind.ELITE, &"priest"), _event(900, WaveEvent.Kind.BOSS, &"morvath")]
	t.hp_per_minute = 0.2
	t.damage_per_minute = 0.05
	_save(t, "res://data/waves/catacombs.tres")


func _save(r: Resource, path: String) -> void:
	var err := ResourceSaver.save(r, path)
	if err != OK:
		push_error("could not save %s: %d" % [path, err])
