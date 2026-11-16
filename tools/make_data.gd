extends SceneTree
## One-off generator of the content files in data/ (combos, enemies, gifts, waves) for the 3D version.
## The .tres files it writes are the source of truth afterwards: tune them in the editor or by hand.
## ~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [bosses] [feel]

## Elites wear a faint old-gold edge (the rim of crowd.gdshader; cycle 5: the gilded halo is gone, the elite reads by
## its gold trims, its armor bar and a thin dark outline, CrowdRenderer.OUTLINE_COLOR).
const ELITE_RIM := Color(0.62, 0.46, 0.22)
const ELITE_RIM_POWER := 0.3
## Elites are the common figure with its steel in old gold (EnemyDef.gild, crowd.gdshader).
const ELITE_GILD := 0.85
## Finishers that swing an arc sweep this wide.
const FINISHER_ARC := 270.0
## The run: 5 plays the 15-minute timeline in 3 (Morvath at 3:00); 1 = the full run. Spawning keeps its rate per
## second of play, so the bot still meets him around level 35 with 18 gifts.
const RUN_PACE := 5.0

const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY
const C := ComboNode.In.CHARGE
const CL := ComboNode.In.CHARGE_LIGHT

## Swing peak (seconds into the clip) of the hero's attack clips, measured from the sword hand by tools/bake_hero.gd.
const PEAK := {
	&"Slash_A": 0.23, &"Slash_B": 0.27, &"Slash_C": 0.67, &"Sword_Attack": 0.40, &"Cast": 0.10, &"Throw": 0.40,
}
## Which way the blade crosses in each clip (ComboNode.sweep: 1 from the right to the left, 2 the other way).
const SWEEP := {
	&"Slash_A": 1, &"Slash_B": 2, &"Slash_C": 1, &"Sword_Attack": 2,
}


func _initialize() -> void:
	var only := OS.get_cmdline_user_args()
	for part in ["combos", "enemies", "boons", "waves", "stage", "bosses", "feel"]:
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
	n.sweep = SWEEP.get(anim, 0)
	var peak: float = PEAK.get(anim, 0.3)
	# (a quick move squeezes the last 0.22 s of the lift into its windup; a slow one plays the clip at its own speed
	# from windup seconds before the peak, so the blade never lands before the blow does)
	n.anim_from = maxf(0.0, peak - maxf(0.22, n.windup))
	n.anim_speed = maxf(1.0, (peak - n.anim_from) / maxf(n.windup, 0.01))
	return n


## Hades II measures distances in its own units: its heroine walks 540 a second and stands 200 tall. 80 of them make
## a meter here (6.75 m/s, a 2.5 m tall paladin), so every distance below is written as Hades units / U.
const U := 80.0


## The paladin's moves, built on the timings, damage and reach of the first weapon of Hades II (study only:
## our own sword, animations, names and look). Frames are at 60 a second.
func _combos() -> void:
	# attack: three swings, the third a turn of the blade all around
	var cut3 := _move(&"cut3", L, &"Slash_C", [&"light", &"spin", &"finisher"],
		{"damage": 60.0, "shape": ComboNode.Shape.CIRCLE, "reach": 240.0 / U, "knockback": 16.0, "lunge": 0.8, "windup": 0.28, "recovery": 18.0 / 60.0,
		"chain_window": 0.6, "hit_stop_ms": 70.0, "shake": 1.6, "move_scale": 0.0}, [], &"move_spin")
	var cut2 := _move(&"cut2", L, &"Slash_B", [&"light"],
		{"damage": 25.0, "reach": 430.0 / U, "width": 150.0, "knockback": 10.0, "lunge": 1.2, "windup": 0.11, "recovery": 13.0 / 60.0,
		"chain_window": 0.4, "hit_stop_ms": 65.0, "shake": 0.8, "move_scale": 0.0}, [cut3])
	var cut1 := _move(&"cut1", L, &"Slash_A", [&"light"],
		{"damage": 20.0, "reach": 430.0 / U, "width": 150.0, "knockback": 8.0, "lunge": 1.0, "windup": 0.06, "recovery": 8.0 / 60.0,
		"chain_window": 0.4, "hit_stop_ms": 25.0, "shake": 0.6, "move_scale": 0.0}, [cut2])
	# special: a bolt of light thrown ahead (strikes only with its bolt)
	var bolt := _move(&"bolt", H, &"Cast", [&"heavy", &"wave"],
		{"damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.1, "recovery": 0.6, "chain_window": 0.2,
		"hit_stop_ms": 0.0, "shake": 0.3, "move_scale": 0.0, "effect": ComboNode.Effect.WAVE, "effect_power": 40.0, "effect_radius": 880.0 / U,
		"effect_size": 1.4, "wave_bolt": true}, [], &"move_bolt")
	# Omega special (special held 0.65 s, 10 Magia): a wide bolt that bursts through the crowd
	var burst := _move(&"burst", C, &"Cast", [&"heavy", &"wave", &"charge", &"omega"],
		{"magick_cost": 10.0, "charge_time": 0.65, "damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.08,
		"recovery": 0.45, "hit_stop_ms": 0.0, "shake": 1.5, "move_scale": 0.0, "effect": ComboNode.Effect.WAVE, "effect_power": 80.0,
		"effect_radius": 880.0 / U, "effect_size": 330.0 / U * 2.0}, [], &"move_burst")
	# Omega attack (attack held 0.8 s, 20 Magia): a long line of light to the front and to the back
	var lance := _move(&"lance", CL, &"Sword_Attack", [&"light", &"thrust", &"finisher", &"omega"],
		{"magick_cost": 20.0, "charge_time": 0.8, "damage": 160.0, "shape": ComboNode.Shape.LINE, "reach": 1080.0 / U, "width": 1.8,
		"both_ways": true, "knockback": 18.0, "windup": 0.06, "recovery": 0.6, "chain_window": 0.4, "hit_stop_ms": 50.0, "shake": 2.0,
		"move_scale": 0.0}, [], &"move_lance")
	# out of a dash: a thrust along the way
	var dash_cut := _move(&"dash_cut", L, &"Slash_A", [&"light", &"dash"],
		{"damage": 30.0, "shape": ComboNode.Shape.LINE, "reach": 640.0 / U, "width": 1.6, "knockback": 10.0, "lunge": 3.2, "windup": 0.06,
		"recovery": 14.0 / 60.0, "chain_window": 0.4, "hit_stop_ms": 25.0, "shake": 0.9, "move_scale": 0.0}, [], &"move_dash_cut")
	var tree := ComboTree.new()
	tree.neutral = [cut1, bolt, burst, lance]
	tree.dodge = [dash_cut]
	tree.dodge_window = 23.0 / 60.0
	_save(tree, "res://data/combos/paladin.tres")


# ---------- enemies ----------

func _enemy(props: Dictionary) -> void:
	var d := EnemyDef.new()
	for k: String in props:
		d.set(k, props[k])
	if d.name_key == &"":
		d.name_key = StringName("enemy_" + String(d.id))
	_save(d, "res://data/enemies/%s.tres" % d.id)


## Each enemy takes the numbers of the Hades II enemy that plays the same part in its first region (life, speed,
## damage, attack timings, room-generator rating, elite armor), with our own creatures, names and look.
## Look: Daniel's sheet of the first region's enemies (docs/art/enemies_phase1.md): each one its own baked model
## (the painted Meshy figures, tools/bake.gd), sizes from the sheet's scale with the soldier at 1.15, the colour
## of its magic. Radius: what it blocks and where blows reach it; it grows less than the figure (a taller enemy is
## not much wider). Every body is solid as in Hades II (EnemyDef.blocks_body, true by default: the paladin stops at
## it and it at him, only the dash goes through); a kind he walks through takes "blocks_body": false.
## Cycle 7, the part each one plays read at a glance (only drawn, EnemyDef's Look group): `tell` and `tell_at` (the
## light of its wind-up and where it sits on the figure), `sway` and `windup_shake` (the unsteady runner), `vivid`
## (the soldier is the greyest, the base line; the priests and Morvath keep their purple), `tint`, `crest`, `shine`.
## Cycle 8, the part each plays in a fight (`role`, drawn by the pools of _stage): the soldier presses, the runner asks
## for a quick answer, the caster closes space, the crossbowman makes him move sideways, the shield-bearer blocks the
## front, the priest threatens ground. Guardians and Morvath have none (their own rooms).
func _enemies() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the foot soldier: walks up, raises its blade 0.9 s and lunges (Hades: the common melee shade)
	_pair({"id": &"skeleton", "model": &"skeleton", "behavior": B.RUNNER, "size": 1.15, "hp": 60.0, "speed": 300.0 / U, "damage": 3.0, "radius": 0.5,
		"attack_damage": 3.0, "attack_range": 290.0 / U, "attack_cooldown": 1.4, "attack_windup": 0.9, "lunge_speed": 700.0 / U, "lunge_time": 0.3,
		"rating": 5.0, "role": &"pressure", "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "vivid": -0.1}, {"armor": 80.0, "speed": 380.0 / U, "rating": 12.0})
	# the fast one that bursts all around itself (sheet: 0.9 of the soldier, stooped, embers in the chest)
	_pair({"id": &"runner", "model": &"runner", "behavior": B.PULSE, "size": 1.04, "hp": 45.0, "speed": 390.0 / U, "damage": 5.0, "radius": 0.45,
		"attack_damage": 5.0, "attack_range": 1.6, "attack_width": 2.6, "attack_cooldown": 1.4, "attack_windup": 0.7,
		"magic_color": Color(3.0, 1.1, 0.25), "rating": 7.0, "role": &"react", "tell": T.TREMBLE, "sway": 7.0, "windup_shake": 0.04,
		"tint": Color(1.0, 0.72, 0.5), "vivid": 0.1}, {"armor": 85.0, "speed": 590.0 / U, "rating": 17.0})
	# the caster that shoots bolts from afar (cold violet: Daniel, 2026-11-14)
	_pair({"id": &"mage", "model": &"mage", "behavior": B.ARCHER, "size": 1.27, "hp": 80.0, "speed": 340.0 / U, "damage": 4.0, "radius": 0.5,
		"attack_damage": 4.0, "attack_range": 9.0, "attack_cooldown": 1.9, "attack_windup": 0.8, "magic_color": Color(1.7, 1.25, 3.2),
		"rating": 12.0, "role": &"control", "tell": T.ORB, "tell_at": Vector3(-0.96, 2.0, 0.58)}, {"armor": 155.0, "speed": 440.0 / U, "rating": 24.0})
	# the crossbowman that plants itself and looses a wide fan of orange bolts
	_pair({"id": &"archer", "model": &"archer", "behavior": B.CONE, "size": 1.27, "hp": 130.0, "speed": 340.0 / U, "damage": 3.0, "radius": 0.55,
		"attack_damage": 3.0, "attack_range": 5.0, "attack_width": 70.0, "attack_cooldown": 1.8, "attack_windup": 0.8, "magic_color": Color(3.0, 1.3, 0.3),
		"rating": 13.0, "role": &"flank", "tell": T.BOLT, "tell_at": Vector3(-0.05, 1.62, 1.42)}, {"armor": 190.0, "speed": 390.0 / U, "rating": 34.0})
	# the brute: a long charge (1.15 s warning) and a slam on whoever comes close
	_pair({"id": &"guard", "model": &"guard", "behavior": B.KNIGHT, "size": 1.5, "hp": 255.0, "speed": 260.0 / U, "damage": 9.0, "radius": 0.75,
		"heavy": true, "attack_damage": 9.0, "attack_range": 500.0 / U + 3.0, "attack_cooldown": 1.9, "attack_windup": 1.15, "lunge_speed": 15.0,
		"lunge_time": 0.4, "close_damage": 7.0, "close_range": 2.6, "close_windup": 0.65,
		"rating": 18.0, "role": &"block", "tell": T.SHIELD, "tell_at": Vector3(0.45, 1.1, 0.4)}, {"armor": 330.0, "speed": 340.0 / U, "rating": 39.0})
	# the one rooted in place that drops purple blows from above
	_pair({"id": &"priest", "model": &"priest", "behavior": B.CASTER, "size": 1.3, "hp": 290.0, "speed": 0.0, "damage": 6.0, "radius": 0.7,
		"heavy": true, "attack_damage": 6.0, "attack_range": 16.0, "attack_cooldown": 2.2, "attack_windup": 1.0, "magic_color": Color(1.9, 0.45, 3.0),
		"rating": 22.0, "role": &"area", "tell": T.RITUAL, "tell_at": Vector3(0.0, 1.3, 0.45), "vivid": 0.25}, {"armor": 390.0, "rating": 48.0})
	# guardians (Hades: the mid-region bosses): life plus a thick armor
	_enemy({"id": &"knight", "model": &"knight", "size": 2.07, "behavior": B.KNIGHT, "hp": 450.0, "speed": 200.0 / U, "damage": 12.0, "radius": 1.1,
		"heavy": true, "elite": true, "armor": 1220.0, "armor_stagger": 2.5, "attack_damage": 12.0, "attack_range": 14.0, "attack_cooldown": 3.2,
		"attack_windup": 1.0, "lunge_speed": 18.0, "lunge_time": 0.7, "close_damage": 12.0, "close_range": 3.2, "close_windup": 0.8,
		"rating": 65.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER, "tell": T.SHIELD, "tell_at": Vector3(0.5, 1.1, 0.35)})
	_enemy({"id": &"priest_elder", "name_key": &"enemy_priest", "model": &"priest_elder", "size": 2.19, "behavior": B.PRIEST, "hp": 510.0, "speed": 2.0,
		"damage": 9.0, "radius": 1.0, "heavy": true, "elite": true, "armor": 1450.0, "armor_stagger": 2.5, "attack_damage": 9.0, "attack_range": 9.0,
		"attack_cooldown": 3.4, "attack_windup": 1.0, "magic_color": Color(1.9, 0.45, 3.0), "rating": 50.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER,
		"tell": T.ORB, "tell_at": Vector3(-1.02, 2.15, 0.6)})
	# the last of the region: Hades II's first guardian has 6050 life and hits for 4 to 14. His necromancy is the cold
	# spectral green of Daniel's request of 2026-11-15 (SPECTRAL: bluer and paler than Emeth's crystal green); the
	# fight's numbers are data/bosses/morvath.tres (_bosses)
	_enemy({"id": &"morvath", "model": &"morvath", "size": 2.53, "behavior": B.BOSS, "hp": 6050.0, "speed": 600.0 / U * 0.5, "damage": 8.0, "radius": 1.4,
		"heavy": true, "armor": 0.0, "attack_damage": 10.0, "magic_color": SPECTRAL, "rim_color": Color(0.45, 0.3, 0.6), "rim": 0.3,
		"vivid": 0.9, "tint": Color(0.94, 0.86, 1.14), "crest": 0.5, "shine": 1.5})


## An enemy and its elite version: the same, wearing an armor bar (Hades II "HealthBuffer"), faster and outlined.
func _pair(base: Dictionary, elite: Dictionary) -> void:
	base["elite_version"] = StringName(String(base.id) + "_elite")
	_enemy(base)
	var e := base.duplicate()
	e.erase("elite_version")
	e["id"] = StringName(String(base.id) + "_elite")
	e["name_key"] = StringName("enemy_" + String(base.id))
	e["elite"] = true
	e["rim_color"] = ELITE_RIM
	e["rim"] = ELITE_RIM_POWER
	# the same figure with its steel in old gold (the KayKit figures wore a gilded palette, EnemyDef.palette:
	# assets/models/palettes/<id>_elite.png, tools/make_palettes.gd)
	e["gild"] = ELITE_GILD
	for k: String in elite:
		e[k] = elite[k]
	_enemy(e)


# ---------- gifts ----------

func _mod(stat: StringName, values: Array, tag: StringName = &"", by_rarity: bool = true) -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.tag = tag
	m.values = PackedFloat32Array(values)
	m.by_rarity = by_rarity
	return m


## A number rarity must not change (counts, cooldowns, sizes).
func _fixed(stat: StringName, values: Array, tag: StringName = &"") -> BoonMod:
	return _mod(stat, values, tag, false)


func _skill(kind: SkillDef.Kind, props: Dictionary) -> SkillDef:
	var s := SkillDef.new()
	s.kind = kind
	for k: String in props:
		s.set(k, PackedFloat32Array(props[k]) if props[k] is Array else props[k])
	return s


func _boon(n: int, id: StringName, family: Boon.Family, icon: int, mods: Array[BoonMod], skill: SkillDef = null, requires: Array[StringName] = [], slot: Boon.Slot = Boon.Slot.NONE) -> void:
	var b := Boon.new()
	b.id = id
	b.slot = slot
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
	var S := Boon.Slot
	_boon(0, &"brasas", F.CHAMA, 0, [], _skill(K.STRIKES, {"damage": [18, 26, 36], "count": [3, 4, 6], "cooldown": [3.5, 3.0, 2.5], "radius": [2.2, 2.4, 2.6], "status": &"burn", "status_power": [5, 7, 9]}))
	_boon(1, &"redemoinho", F.CHAMA, 1, [], _skill(K.ORBIT, {"damage": [10, 14, 19], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"burn", "status_power": [4, 6, 8]}))
	_boon(2, &"lamina_ardente", F.CHAMA, 2, [_mod(&"burn_dps", [6, 9, 12], &"finisher"), _mod(&"damage_pct", [0.2, 0.35, 0.5], &"finisher")])
	_boon(3, &"toque_geada", F.GEADA, 3, [_mod(&"freeze_time", [1.0, 1.5, 2.0], &"heavy")], null, [], S.SPECIAL)
	_boon(4, &"estilhaco", F.GEADA, 4, [_mod(&"shatter_pct", [0.5, 0.8, 1.0])], _skill(K.NOVA, {"damage": [20, 30, 42], "cooldown": [6, 5, 4], "radius": [5, 6, 7], "status": &"freeze", "status_power": [1.2, 1.5, 1.8]}))
	_boon(5, &"peso_inverno", F.GEADA, 5, [], _skill(K.METEOR, {"damage": [60, 90, 130], "cooldown": [9, 8, 7], "radius": [4.0, 4.5, 5.0], "status": &"freeze", "status_power": [2.0, 2.2, 2.5]}))
	_boon(6, &"consolo", F.LUZ, 6, [_mod(&"heal_on_kill", [0.4, 0.7, 1.0])])
	_boon(7, &"onda_maior", F.LUZ, 7, [], _skill(K.FAN, {"damage": [16, 22, 30], "count": [5, 8, 11], "cooldown": [5.0, 4.5, 4.0], "radius": [12, 13, 14]}))
	_boon(8, &"flagelo", F.LUZ, 8, [], _skill(K.STRIKES, {"damage": [24, 32, 44], "count": [4, 6, 9], "cooldown": [4.5, 4.0, 3.5], "radius": [1.6, 1.8, 2.0], "status": &"stun", "status_power": [0.4, 0.5, 0.6]}))
	_boon(9, &"escudo", F.VIGILIA, 9, [_fixed(&"shield_cooldown", [12, 9, 6])])
	_boon(10, &"passos", F.VIGILIA, 10, [_fixed(&"dodge_charges", [1, 1, 2]), _fixed(&"move_speed_pct", [0.08, 0.14, 0.2])], null, [], S.DASH)
	_boon(11, &"firmeza", F.VIGILIA, 11, [_mod(&"max_hp", [20, 35, 50])], _skill(K.CONSECRATE, {"damage": [12, 18, 26], "cooldown": [8, 7, 6], "radius": [4, 5, 6], "status": &"slow", "status_power": [4.0, 4.5, 5.0]}))
	_boon(12, &"vapor", F.DUO, 12, [_mod(&"steam_time", [2, 3, 4])], null, [&"brasas", &"toque_geada"])
	_boon(13, &"aurora", F.DUO, 13, [_mod(&"freeze_time", [0.8, 1.2, 1.6], &"luz")], null, [&"onda_maior", &"toque_geada"])
	_boon(14, &"chama_viva", F.DUO, 14, [_mod(&"burn_dps", [5, 8, 11], &"luz")], null, [&"brasas", &"flagelo"])
	_boon(15, &"bastiao", F.DUO, 15, [_mod(&"shield_burst", [40, 70, 100])], null, [&"escudo", &"consolo"])
	_boon(16, &"rastro", F.DUO, 16, [_mod(&"dodge_ember_dps", [8, 12, 16])], null, [&"passos", &"brasas"])
	_boon(17, &"passo_frio", F.DUO, 17, [_mod(&"freeze_time", [1.0, 1.5, 2.0], &"dash")], null, [&"passos", &"toque_geada"])
	# One gift per action (Boon.Slot): attack = light moves, special = heavy moves, cast = the circle of light, dash.
	_boon(18, &"golpe_brasa", F.CHAMA, 2, [_mod(&"burn_dps", [4, 6, 8], &"light")], null, [], S.ATTACK)
	_boon(19, &"golpe_geada", F.GEADA, 3, [_mod(&"freeze_time", [0.3, 0.45, 0.6], &"light")], null, [], S.ATTACK)
	_boon(20, &"golpe_radiante", F.LUZ, 8, [_mod(&"damage_pct", [0.25, 0.4, 0.55], &"light")], null, [], S.ATTACK)
	_boon(21, &"golpe_firme", F.VIGILIA, 11, [_fixed(&"reach_pct", [0.12, 0.18, 0.25], &"light"), _mod(&"damage_pct", [0.1, 0.15, 0.2], &"light")], null, [], S.ATTACK)
	_boon(22, &"pesado_brasa", F.CHAMA, 0, [_mod(&"burn_dps", [6, 9, 12], &"heavy")], null, [], S.SPECIAL)
	_boon(23, &"pesado_radiante", F.LUZ, 7, [_mod(&"damage_pct", [0.3, 0.45, 0.6], &"heavy")], null, [], S.SPECIAL)
	_boon(24, &"pesado_firme", F.VIGILIA, 15, [_fixed(&"reach_pct", [0.15, 0.22, 0.3], &"heavy"), _mod(&"damage_pct", [0.1, 0.15, 0.2], &"heavy")], null, [], S.SPECIAL)
	_boon(25, &"circulo_brasa", F.CHAMA, 1, [_mod(&"burn_dps", [8, 12, 16], &"cast")], null, [], S.CAST)
	_boon(26, &"circulo_geada", F.GEADA, 4, [_mod(&"freeze_time", [1.0, 1.4, 1.8], &"cast")], null, [], S.CAST)
	_boon(27, &"circulo_radiante", F.LUZ, 6, [_mod(&"cast_dps", [16, 24, 32], &"cast"), _mod(&"damage_pct", [0.3, 0.45, 0.6], &"cast")], null, [], S.CAST)
	_boon(28, &"circulo_firme", F.VIGILIA, 9, [_fixed(&"cast_size_pct", [0.25, 0.4, 0.55])], null, [], S.CAST)
	_boon(29, &"passo_brasa", F.CHAMA, 16, [_mod(&"dodge_ember_dps", [6, 9, 12])], null, [], S.DASH)
	_boon(30, &"passo_geada", F.GEADA, 17, [_mod(&"freeze_time", [0.8, 1.2, 1.6], &"dash")], null, [], S.DASH)
	_boon(31, &"passo_radiante", F.LUZ, 10, [_mod(&"damage_pct", [0.4, 0.6, 0.8], &"dash")], null, [], S.DASH)


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
		# The first three minutes are sparse on purpose: about 140 enemies, each falling in one or two blows,
		# so every hit lands on someone you can see; the first elite closes them.
		_segment(0, 60, [&"skeleton"], [1], Vector2(0.5, 0.75), Vector2i(12, 20)),
		_segment(60, 180, [&"skeleton", &"archer", &"guard"], [8, 1, 0.6], Vector2(0.75, 0.95), Vector2i(20, 40)),
		_segment(180, 300, [&"skeleton", &"archer", &"guard", &"runner"], [7, 1.2, 0.8, 1.6], Vector2(1.2, 5.5), Vector2i(40, 170)),
		_segment(300, 480, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.3, 1.0, 1.8, 0.9], Vector2(5.5, 7.0), Vector2i(170, 230)),
		_segment(480, 600, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.4, 1.2, 2.0, 1.1], Vector2(7.0, 8.5), Vector2i(230, 270)),
		_segment(600, 900, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.5, 1.4, 2.2, 1.3], Vector2(8.5, 10.0), Vector2i(270, 300)),
	]
	t.events = [_event(180, WaveEvent.Kind.ELITE, &"knight"), _event(420, WaveEvent.Kind.FOUNTAIN), _event(600, WaveEvent.Kind.ELITE, &"priest"), _event(900, WaveEvent.Kind.BOSS, &"morvath")]
	t.hp_per_minute = 0.2
	t.damage_per_minute = 0.05
	# Short test run while the game is an MVP: the same 15-minute timeline played in 3 (pace 1 is the full run).
	t.pace = RUN_PACE
	_save(t, "res://data/waves/catacombs.tres")


# ---------- the descent room by room ----------

func _layout(half: Vector2, pillars: Array[Vector3], shafts: Array[Vector2]) -> RoomLayout:
	var l := RoomLayout.new()
	l.half = half
	l.pillars = pillars
	l.shafts = shafts
	return l


func _pool(tier: StageDef.Tier, from: float, until: float, weight: float, roles: Array[StringName], elite_chance: float = 0.0) -> EncounterPool:
	var p := EncounterPool.new()
	p.tier = tier
	p.from = from
	p.until = until
	p.weight = weight
	p.roles = roles
	p.elite_chance = elite_chance
	return p


## The catacombs as a region of rooms, with the room generator and rewards of the first region of Hades II.
func _stage() -> void:
	var st := StageDef.new()
	# short descent for testing (Daniel, 2026-11-14): fight, fountain, guardian, shop, Morvath in room 5.
	# Hades II's region: rooms 10, guardian 4 to 6, fountain 5 to 8.
	st.rooms = 4
	# elites from the 2nd room while the descent is short (Hades II: from depth 3); back to 3 with the full region
	st.elite_from_depth = 2
	st.miniboss_depth_min = 3
	st.miniboss_depth_max = 3
	st.minibosses = [&"knight", &"priest_elder"]
	st.fountain_depth_min = 2
	st.fountain_depth_max = 2
	st.boss = &"morvath"
	st.enemies = [&"skeleton", &"skeleton_elite", &"runner", &"runner_elite", &"mage", &"mage_elite", &"archer", &"archer_elite",
		&"guard", &"guard_elite", &"priest", &"priest_elite"]
	# Few enemies at once, each with its part, a fight won by skill as in Hades II (Daniel, 2026-11-15: not a horde
	# survivor). Standing at once: common 4 to 8, hard 8 to 12 (guardians, elites), special 12 to 16, never past 20;
	# Morvath's summons have their own ceiling (BossDef.adds_cap, ritual_cap). A room may have several waves: the next one comes when
	# one enemy is left (wave_remaining), and only while there is room under the cap.
	var Tier := StageDef.Tier
	st.alive_cap = 20
	st.tier_alive = [Vector2i(4, 8), Vector2i(8, 12), Vector2i(12, 16)]
	st.miniboss_tier = Tier.HARD
	# The fights by how far down the region (0 the first room, 1 the last fight before the shop; EncounterGen.progress).
	# The parts (EnemyDef.role): pressure the soldier, react the runner, control the caster, flank the crossbowman,
	# block the shield-bearer, area the priest. Never every kind at once without a reason.
	st.pools = [
		# the top: two simple parts, the pressing soldier with one other
		_pool(Tier.COMMON, 0.0, 0.34, 3.0, [&"pressure", &"react"]),
		_pool(Tier.COMMON, 0.0, 0.34, 2.0, [&"pressure", &"flank"]),
		_pool(Tier.COMMON, 0.0, 0.34, 1.0, [&"block", &"react"]),
		# the middle: three parts that complete each other
		_pool(Tier.COMMON, 0.34, 0.67, 3.0, [&"pressure", &"flank", &"control"]),
		_pool(Tier.COMMON, 0.34, 0.67, 2.0, [&"block", &"react", &"flank"]),
		_pool(Tier.COMMON, 0.34, 0.67, 2.0, [&"pressure", &"block", &"area"]),
		_pool(Tier.HARD, 0.34, 0.67, 1.0, [&"pressure", &"react", &"control"], 1.0),
		# the bottom: demanding mixes, elites likely, and a rare special fight of four parts
		_pool(Tier.HARD, 0.67, 1.0, 3.0, [&"block", &"flank", &"area"], 0.6),
		_pool(Tier.HARD, 0.67, 1.0, 3.0, [&"pressure", &"control", &"area"], 0.6),
		_pool(Tier.HARD, 0.67, 1.0, 2.0, [&"react", &"flank", &"control"], 0.6),
		_pool(Tier.COMMON, 0.67, 1.0, 1.0, [&"pressure", &"block", &"control"]),
		_pool(Tier.SPECIAL, 0.8, 1.0, 1.0, [&"pressure", &"react", &"flank", &"area"], 0.5),
	]
	var R := RunMap.Reward
	st.rewards = PackedInt32Array([R.BOON, R.POM, R.HEART, R.MAGICK, R.GOLD])
	st.reward_weights = PackedFloat32Array([6.0, 2.5, 1.5, 1.0, 1.5])
	st.shop_items = PackedInt32Array([R.BOON, R.POM, R.HEART, R.HEAL])
	st.shop_prices = PackedInt32Array([150, 100, 125, 60])
	# every room is the catacomb hall of Daniel's reference image (redesign of 2026-11-14, CatacombHall: a 28 m square
	# by 30 m platform over the abyss, built in code to match the picture); its size and pieces live in CatacombHall, so the
	# layout only says "the hall". The boss and the shop fight in it too (Morvath's portal burns red).
	var hall := _layout(CatacombHall.HALF, [], [])
	hall.platform = true
	st.layouts = [hall]
	st.boss_layout = hall
	st.shop_layout = hall
	_save(st, "res://data/stages/catacombs.tres")


func _save(r: Resource, path: String) -> void:
	var err := ResourceSaver.save(r, path)
	if err != OK:
		push_error("could not save %s: %d" % [path, err])


# ---------- bosses ----------

## Morvath's necromancy and the souls he throws: a cold, pale spectral green (never Emeth's warm crystal green).
const SPECTRAL := Color(0.38, 1.55, 1.1)


func _attack(id: StringName, props: Dictionary) -> BossAttack:
	var a := BossAttack.new()
	a.id = id
	for k: String in props:
		a.set(k, props[k])
	return a


## Morvath, the first boss, in four phases (Daniel's request of 2026-11-15; docs/design/morvath_boss_fight.md):
## 1 "O Despertar" (100 to 66%): the Sepulchral Scythe and the Blades of the Souls, the dash to close in.
## 2 "O Ritual dos Mortos" (66 to 33%): the ritual behind a shield (the only time he cannot be hurt), then
##   eruptions and a few summons. 3 "A Maldicao dos Condenados" (33 to 15%): the curse. 4 "O Ultimo Suspiro"
##   (15 to 0%): the blades become the Storm of the Six Souls, shorter rests.
## Distances from his middle (he is 1.4 m wide of radius, the paladin walks 6.75 m/s and dodges 5.6 m in 0.2 s):
## every warning leaves time to walk out of it (tests/test_boss.gd proves each).
func _bosses() -> void:
	var b := BossDef.new()
	b.id = &"morvath"
	b.enemy = &"morvath"
	b.thresholds = PackedFloat32Array([0.66, 0.33, 0.15])
	b.ritual_phase = 2
	b.rest = PackedFloat32Array([1.1, 1.0, 0.9, 0.75])
	b.windup_scale = PackedFloat32Array([1.0, 1.0, 0.95, 0.9])
	b.final_light_phase = 4
	b.adds_cap = PackedInt32Array([0, 4, 4, 4])
	# each phase opens on its own pattern, right after the roar: the ritual (by itself), the curse, the storm
	b.phase_openers = [&"", &"", &"curse", &"storm"] as Array[StringName]
	var numbers := {
		"roar_time": 1.6, "roar_push": 4.0, "near": 6.0, "far": 10.0, "still_after": 0.8, "lead": 0.45,
		"summon_raise": [&"skeleton", &"skeleton"] as Array[StringName], "summon_windup": 1.1,
		# reinforcements rise one by one (a rune, the energy, the body, 0.45 s apart), 20 at most in the whole fight
		"adds_total_cap": 20, "rise_stagger": 0.45,
		# a combination waits for nothing of the first to be left, then rests only this long
		"chain_rest": 0.35,
		# the Sepulchral Scythe: half a circle 5 m from his middle (3.6 m past his body), 0.8 s to read it, 1 s to punish
		"scythe_reach": 5.0, "scythe_degrees": 180.0, "scythe_windup": 0.8, "scythe_recovery": 1.0, "scythe_damage": 12.0, "scythe_approach": 1.2,
		# the Blades of the Souls: two crescents 3 m wide, 38 degrees apart, across the hall at 11 m/s
		"blade_spread": 38.0, "blade_speed": 11.0, "blade_width": 3.0, "blade_range": 26.0, "blade_windup": 0.7, "blade_recovery": 0.8, "blade_damage": 10.0,
		# the Storm of the Six Souls: six crescents all around (never two closer than 48 degrees), a second wave turned 30
		"storm_count": 6, "storm_jitter": 7.0, "storm_min_gap": 48.0, "storm_waves": 2, "storm_turn": 30.0, "storm_gap": 1.0, "storm_windup": 0.9,
		"storm_recovery": 1.2, "storm_damage": 10.0, "storm_stagger": 0.08,
		# the Sepulchral Eruptions: 2 or 3 circles of 2 m, one on the paladin, the lane to the middle of the hall kept free
		"eruption_radius": 2.0, "eruption_delay": 0.9, "eruption_count": Vector2i(2, 3), "eruption_lane": 120.0, "eruption_sequences": 2,
		"eruption_gap": 1.0, "eruption_damage": 10.0, "eruption_recovery": 0.8,
		# the ritual: at most 20 s behind the shield, 2 soldiers and 2 casters, never more than 6 of his standing
		"ritual_time": 20.0, "ritual_raise": [&"skeleton", &"skeleton", &"mage", &"mage"] as Array[StringName], "ritual_cap": 6,
		"ritual_reinforce_every": 6.0, "ritual_reinforce": [&"skeleton", &"mage"] as Array[StringName], "ritual_eruption_every": 2.8,
		"ritual_stun": 2.0, "shield_radius": 2.9,
		# the curse: a slow bolt that follows a little (75 degrees a second for 1.4 s), 3 s of 30% slower walking and
		# no special, then 2 s immune
		"curse_windup": 0.8, "curse_speed": 7.0, "curse_turn": 75.0, "curse_homing": 1.4, "curse_life": 4.0, "curse_radius": 0.55,
		"curse_damage": 6.0, "curse_time": 3.0, "curse_slow": 0.3, "curse_immunity": 2.0, "curse_recovery": 0.6,
		"dash_length": 16.0, "dash_time": 0.42, "dash_windup": 0.8, "dash_width": 2.8, "dash_damage": 12.0, "dash_recovery": 1.1,
		"stagger_from_phase": 3, "stagger_hits": 3, "stagger_forget": 4.0, "stagger_time": 2.6,
	}
	for k: String in numbers:
		b.set(k, numbers[k])
	b.attacks = [
		# close: the scythe; it walks in first (scythe_approach)
		# in the last phase the scythe may be followed by the storm from where he stands
		_attack(&"scythe", {"weight": 3.0, "max_dist": 11.0, "near_bias": 2.2, "far_bias": 0.35, "streak": 2, "then": &"storm", "then_chance": 0.5, "then_from_phase": 4}),
		# far: the blades (until the storm takes their place)
		_attack(&"blades", {"weight": 2.0, "until_phase": 3, "cooldown": 3.0, "min_dist": 3.5, "near_bias": 0.5, "far_bias": 2.2}),
		# the paladin keeps away: the dash closes in
		_attack(&"dash", {"weight": 1.0, "cooldown": 6.0, "min_dist": 9.0, "far_bias": 1.5}),
		# the eruptions drive the paladin; in the last phase the scythe waits where he lands
		_attack(&"eruptions", {"from_phase": 2, "weight": 1.4, "cooldown": 5.0, "still_bias": 3.0, "then": &"scythe", "then_chance": 0.4, "then_from_phase": 4}),
		_attack(&"summon", {"from_phase": 2, "weight": 0.8, "cooldown": 12.0}),
		_attack(&"curse", {"from_phase": 3, "weight": 1.6, "cooldown": 7.0, "min_dist": 3.0}),
		# after the storm, a paladin far away is charged (only when he is far: the dash needs 9 m)
		_attack(&"storm", {"from_phase": 4, "weight": 2.2, "cooldown": 5.0, "near_bias": 1.3, "far_bias": 1.3, "then": &"dash", "then_chance": 0.4, "then_from_phase": 4}),
	]
	_save(b, "res://data/bosses/morvath.tres")


# ---------- feel ----------

## How the game feels in the hands (scripts/core/feel.gd). The F1 panel tunes these live; copy good values here.
## Movement, dash and camera of Hades II at our scale (80 of its units to a meter): walk 540, dash 450 in 0.2 s
## with 16 frames of safety and 0.74 s to come back, sprint 1.65 times the walk; a near-flat camera 30 degrees above
## the floor (its circles are drawn half as tall as wide) showing about 28 m across (ours a little farther: about 32 m).
func _feel() -> void:
	var f := Feel.new()
	f.speed = 540.0 / U
	f.dodge_time = 0.2
	# the roll slows to half by its end, so it covers 0.75 * speed * time
	f.dodge_speed = 450.0 / U / 0.2 / 0.75
	f.dodge_iframes = 16.0 / 60.0
	f.dodge_charges = 1
	f.dodge_recharge = 0.74
	f.sprint_scale = 890.0 / 540.0
	f.move_scale_light = 0.0
	f.move_scale_heavy = 0.0
	f.move_scale_finisher = 0.0
	# the frame of Daniel's reference image of the catacomb hall (2026-11-14): high and turned, the square room seen
	# as a diamond from its south-east corner (docs/art/arena_reference.md); cycle 5 brings it 10% closer (60 to 54,
	# Daniel's "discreet camera adjustments") so the figures read the size of the painting's; --showcase keeps 60
	f.cam_distance = 54.0
	f.cam_pitch = 30.0
	f.cam_yaw = 35.0
	f.cam_fov = 24.0
	f.cam_lead = 1.2
	f.cam_smooth = 9.0
	f.hit_stop_scale = 1.0
	f.glint_scale = 1.0
	f.shake_scale = 1.0
	f.kick_scale = 1.0
	f.impact_frame = 0.05
	f.outline = 0.5
	# effects a little quieter after the first test ("everything is too big"): dimmer cut, ink gone sooner
	f.slash_intensity = 1.7
	f.slash_sweep_time = 0.1
	f.ink_opacity = 0.85
	f.ink_life = 2.0
	_save(f, Feel.PATH)
