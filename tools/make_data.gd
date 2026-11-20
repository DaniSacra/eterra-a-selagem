extends SceneTree
## One-off generator of the content files in data/ (combos, enemies, gifts, waves) for the 3D version.
## The .tres files it writes are the source of truth afterwards: tune them in the editor or by hand.
## ~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [bosses] [feel]
##   [talents] [ultimates] [mastery] [hero] [psalms] [trials] [juramentos]

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
## The clip that brings the blade back to the guard after each swing clip that ends away from it (ComboNode.recover_anim).
const RECOVER := {&"Slash_A": &"Slash_A_Rec", &"Slash_B": &"Slash_B_Rec"}
## Seconds every finisher holds its glint on the blade before it lands (ComboNode.glint; the anticipation beat of the
## Ember & Blade, kept short so the timings of Hades II barely move: backlog BUG-003, 0.06 to 0.1 s).
const FINISHER_GLINT := 0.08
## Seconds the special and its Omega hold the legs after the dart leaves (ComboNode.move_hold; Hades II's
## Special1DisableMoveHold, D-44 (3)); only the dodge cuts it.
const SPECIAL_HOLD := 0.71
## Push of cut1 and cut2 (m/s; Horde.KNOCKBACK_DECAY 7 makes it about a seventh of that in meters). E1c: with no lunge
## to follow the enemy, 8 and 10 threw it 2.6 m back, out of the spin's 3 m; 2.5 and 3 keep the three blows on it
## (0.8 m in all).
const COMBO_PUSH := [2.5, 3.0]


func _initialize() -> void:
	var only := OS.get_cmdline_user_args()
	# the hero last: it points at the talents, ultimates and Mastery written before it
	for part in ["combos", "enemies", "boons", "waves", "stage", "bosses", "feel", "talents", "ultimates", "mastery", "hero", "psalms", "trials", "juramentos", "forge", "angels", "enchants"]:
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
	n.next.assign(next)
	if tags.has(&"finisher"):
		n.glint = FINISHER_GLINT
	# start the clip a little before the swing so the blade lands exactly when the windup ends
	n.sweep = SWEEP.get(anim, 0)
	n.recover_anim = RECOVER.get(anim, &"")
	var peak: float = PEAK.get(anim, 0.3)
	# (a quick move squeezes the last 0.22 s of the lift into its windup; a slow one plays the clip at its own speed
	# from windup seconds before the peak, so the blade never lands before the blow does)
	n.anim_from = maxf(0.0, peak - maxf(0.22, n.windup))
	n.anim_speed = maxf(1.0, (peak - n.anim_from) / maxf(n.windup, 0.01))
	return n


## C17, QW-103: when the recorded swishes peak after they start (audio/blade_spin_*.ogg 30 to 90 ms, thrust_* 20 to
## 30 ms, measured on their envelope): a delayed sound starts this much before its blade's frame.
const SWISH_PEAK := 0.06
const THRUST_PEAK := 0.025


## Hades II measures distances in its own units: its heroine walks 540 a second and stands 200 tall. 80 of them make
## a meter here (6.75 m/s, a 2.5 m tall paladin), so every distance below is written as Hades units / U.
const U := 80.0


## The paladin's moves, built on the timings, damage and reach of the first weapon of Hades II (study only:
## our own sword, animations, names and look). Frames are at 60 a second.
func _tree(fourth: bool) -> ComboTree:
	# attack: three swings, the third a turn of the blade all around. E1c (Daniel's E1 test: "tem que atacar parado",
	# "o primeiro ataque é muito rápido", "diferença de tempo entre os 3"; his Hades II video of 2026-11-16): every
	# blow is struck standing still (no lunge), windup (+ the finisher's glint), the frame it lands, then the clip's
	# return (ComboNode.follow_speed). Numbers of Hades II's staff (docs/design/hades2_feel_study.md, "O que aplicar"),
	# seconds after the press / after the blow: windup, attack lock (recovery: the next blow of the combo starts there),
	# legs held (move_hold, only the dodge cuts it): cut1 0.08 / 8 frames / 11 frames (press to walking 0.26 s),
	# cut2 0.13 / 13 / 19 (0.45 s), the spin 0.28 + 0.08 of glint = 0.36 / 18 / 30 (0.86 s).
	var cut3 := _move(&"cut3", L, &"Slash_C", [&"light", &"spin", &"finisher"],
		{"damage": 60.0, "shape": ComboNode.Shape.CIRCLE, "reach": 240.0 / U, "knockback": 16.0, "windup": 0.36 - FINISHER_GLINT,
		"recovery": 18.0 / 60.0, "move_hold": 30.0 / 60.0, "chain_window": 0.6, "hit_stop_ms": 70.0, "shake": 1.6, "move_scale": 0.0, "sound": &"blade_spin",
		# QW-103: the spin's swish (its samples peak 30 to 90 ms in) on the blade's frame, 0.36 s after the press; the
		# press only gathers
		"sound_at": 0.36 - SWISH_PEAK, "sound_press": &"spin_gather"}, [], &"move_spin")
	var after_cut2: Array[ComboNode] = [cut3]
	if fourth:
		after_cut2 = [_fourth(cut3)]
	var cut2 := _move(&"cut2", L, &"Slash_B", [&"light"],
		{"damage": 25.0, "reach": 430.0 / U, "width": 150.0, "knockback": COMBO_PUSH[1], "windup": 0.13, "recovery": 13.0 / 60.0,
		"move_hold": 19.0 / 60.0,
		"chain_window": 0.4, "hit_stop_ms": 65.0, "shake": 0.8, "move_scale": 0.0, "sound": &"blade_heavy"}, after_cut2)
	var cut1 := _move(&"cut1", L, &"Slash_A", [&"light"],
		{"damage": 20.0, "reach": 430.0 / U, "width": 150.0, "knockback": COMBO_PUSH[0], "windup": 0.08, "recovery": 8.0 / 60.0,
		"move_hold": 11.0 / 60.0,
		"chain_window": 0.4, "hit_stop_ms": 25.0, "shake": 0.6, "move_scale": 0.0}, [cut2])
	# special: a bolt of light thrown ahead (strikes only with its bolt). Hades II's Special1: the attack is free again
	# 18 frames after the dart, the special itself 0.7 s after it; the dart flies at 62.5 m/s (Projectiles.SPARK_SPEED).
	# The legs stay held 0.71 s after the dart (D-44 (3); Daniel liked it in Hades II), only the dodge cuts it. E1c
	# (Daniel: "trava para andar e eu fico patinando"): while held he plays the throw and holds its pose, never the run.
	var bolt := _move(&"bolt", H, &"Cast", [&"heavy", &"wave"],
		{"damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.1, "recovery": 18.0 / 60.0, "chain_window": 0.2,
		"cooldown": 0.7, "move_hold": SPECIAL_HOLD, "sound": &"dart",
		"hit_stop_ms": 0.0, "shake": 0.3, "move_scale": 0.0, "effect": ComboNode.Effect.WAVE, "effect_power": 40.0, "effect_radius": 880.0 / U,
		"effect_size": 1.4, "wave_bolt": true}, [], &"move_wave")
	# Omega special (special held 0.65 s, 10 Magia): a wide bolt that bursts through the crowd
	var burst := _move(&"burst", C, &"Cast", [&"heavy", &"wave", &"charge", &"omega"],
		{"magick_cost": 10.0, "charge_time": 0.65, "damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.08,
		"recovery": 0.45, "move_hold": SPECIAL_HOLD, "hit_stop_ms": 0.0, "shake": 1.5, "move_scale": 0.0, "sound": &"wave_omega", "effect": ComboNode.Effect.WAVE, "effect_power": 80.0,
		"effect_radius": 880.0 / U, "effect_size": 330.0 / U * 2.0}, [], &"move_burst")
	# Omega attack (attack held 0.8 s, 20 Magia): a long line of light to the front and to the back. Its windup and
	# glint play inside the charge, so it lands when the charge fills (GF-08, Player._charge_lead). Hades II's Swing5:
	# 0.78 s after it without walking or striking.
	var lance := _move(&"lance", CL, &"Sword_Attack", [&"light", &"thrust", &"finisher", &"omega"],
		{"magick_cost": 20.0, "charge_time": 0.8, "damage": 160.0, "shape": ComboNode.Shape.LINE, "reach": 1080.0 / U, "width": 1.8,
		"both_ways": true, "knockback": 18.0, "windup": 0.06, "recovery": 0.78, "move_hold": 0.78, "chain_window": 0.4, "hit_stop_ms": 50.0, "shake": 2.0,
		"move_scale": 0.0, "sound": &"thrust", "sound_at": 0.06 - THRUST_PEAK}, [], &"move_lance")
	# out of a dash: a thrust along the way
	var dash_cut := _move(&"dash_cut", L, &"Slash_A", [&"light", &"dash"],
		{"damage": 30.0, "shape": ComboNode.Shape.LINE, "reach": 640.0 / U, "width": 1.6, "knockback": 10.0, "lunge": 3.2, "windup": 0.06,
		"recovery": 14.0 / 60.0, "chain_window": 0.4, "hit_stop_ms": 25.0, "shake": 0.9, "move_scale": 0.0}, [], &"move_dash_cut")
	var tree := ComboTree.new()
	tree.neutral = [cut1, bolt, burst, lance]
	tree.dodge = [dash_cut]
	tree.dodge_window = 23.0 / 60.0
	return tree


## The tree Quarto Corte equips (TalentDef.combos): the same moves with the thrust between cut2 and the spin.
const FOURTH_TREE := "res://data/combos/paladin_fourth.tres"


func _combos() -> void:
	_save(_tree(false), "res://data/combos/paladin.tres")
	_save(_tree(true), FOURTH_TREE)


## Quarto Corte (warrior_spec.md 4.2): a thrust of 30 between cut2 and the spin, a trade and not a gain. The three
## cuts deal 105 in 1.22 s from press to press (windups, the spin's glint, attack locks): 86 a second; the thrust adds
## 30 and 0.34 s (0.14 of windup, 12 frames of lock): 135 in 1.56 s, 86.5 a second (tests/test_warrior_talents.gd
## keeps it within 10%). A pale thrust of the blade (emeth_thrust), the push of cut2 so the spin still reaches; its
## tags are the attack's (light), so every Blessing of the attack counts on it.
const FOURTH := {"damage": 30.0, "windup": 0.14, "recovery": 12.0 / 60.0, "move_hold": 18.0 / 60.0}


func _fourth(spin: ComboNode) -> ComboNode:
	return _move(&"thrust4", L, &"Sword_Attack", [&"light", &"thrust"],
		{"damage": FOURTH.damage, "shape": ComboNode.Shape.LINE, "reach": 430.0 / U, "width": 1.6, "knockback": COMBO_PUSH[1],
		"windup": FOURTH.windup, "recovery": FOURTH.recovery, "move_hold": FOURTH.move_hold, "chain_window": 0.4,
		"hit_stop_ms": 50.0, "shake": 0.8, "move_scale": 0.0, "sound": &"thrust", "sound_at": FOURTH.windup - THRUST_PEAK}, [spin])


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
## GF-12 (D-42): a blow stuns a common enemy as in Hades II, per enemy (Enemies.sjson, EnemyData_*.lua of the first
## region, study of 2026-11-16). Hades plays each one's StunAnimations, whose length lives in the animations; ours is
## the hit pose (Horde.HURT_TIME). A Heavy stun plays the same pose at half speed (GrannyAnimationSpeed 0.5: Guard,
## Mage); the Brawler (our guard) plays its Default at 1.3 and its long one at 0.6; Radiator, Screamer and SiegeVine
## have only the Default. Elites flinch once their armor is broken (Hades: ImmuneToStun only while the HealthBuffer
## holds); guardians and Morvath never (ImmuneToStun).
## E1c (AUDIT.md P5, Game Director: Hades II faithfully): how long the stun lasts is the heroine's blow's, not the
## pose's: OnHitStun 0.5 s on the light blows and OnHitStunHeavy 1.1 s on the strong ones (study 1.1 and 4.1), for
## every common enemy; the hit pose is stretched over it (Horde.render).
const STUN := 0.5
## The magic of the dead (vfx_pass_spec.md 4 and 5.4, V-11, Lote 1): the danger's crimson and magenta over a dark core,
## the opposite of the hero's language; violet is Morvath's alone (the caster's cold violet, Daniel 2026-11-14, went
## to magenta with the spec). Crimson: the crossbow's bolt and the runner's burst (hue 350 to 355 on the screen);
## magenta: the caster's orbs, the priest's vine and the elder's fan (320 to 330).
const DEAD_CRIMSON := Color(1.4, 0.16, 0.3)
## (ART_REVIEW P2: the spec's (1.2, 0.18, 0.85), hue 321, showed 313 on the screen; 333 in the material lands in 320 to 330)
const DEAD_MAGENTA := Color(1.2, 0.18, 0.64)
const STUN_HEAVY := 1.1
## E1c (AUDIT.md P2): Hades II's PostAttackDuration of each one's counterpart (study 4.2), the window it stands
## still after its blow (EnemyDef.recover_time): Guard 2.1 (elite 1.5), Radiator 1.35 (elite 0.5), Brawler 1.1 after
## the slam (and after our charge), Screamer 0.6 before it backs off, Mage 0.7 to 0.9. The SiegeVine's 3.25 is its
## attack_cooldown already (it never moves: a recovery would only freeze the end of its cast).
const ENEMY_RECOVER := {"skeleton": [2.1, 1.5], "runner": [1.35, 0.5], "guard": [1.1, 1.1], "archer": [0.6, 0.6], "mage": [0.8, 0.8]}


func _enemies() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the foot soldier: walks up, raises its blade 0.9 s and lunges (Hades: the common melee shade)
	_pair({"id": &"skeleton", "model": &"skeleton", "behavior": B.RUNNER, "size": 1.15, "hp": 60.0, "speed": 300.0 / U, "damage": 3.0, "radius": 0.5,
		"attack_damage": 3.0, "attack_range": 290.0 / U, "attack_cooldown": 1.4, "attack_windup": 0.9, "lunge_speed": 700.0 / U, "lunge_time": 0.3,
		"rating": 5.0, "role": &"pressure", "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "vivid": -0.1,
		# at most 2 soldiers wind up at once (AUDIT.md P9: their red lines piled into one block)
		"max_attackers": 2, "recover_time": ENEMY_RECOVER.skeleton[0],
		# T5-02, T5-09: it trembles in the hold of its wind-up; its blade comes down 0.1 s into its pounce, reaching
		# 1.1 m (at its size) past its body in an arc of 120 degrees ahead, as its body lands
		"windup_shake": 0.025, "strike_at": 0.1, "strike_reach": 1.1, "strike_degrees": 120.0,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY}, {"armor": 80.0, "speed": 380.0 / U, "rating": 12.0, "recover_time": ENEMY_RECOVER.skeleton[1],
		# C19-1 (Q-11, Hades' Guard elite): two blades 0.2 s apart, the second where he stood at the end of the wind-up
		"strikes": 2, "strike_gap": 0.2})
	# the fast one that bursts all around itself (sheet: 0.9 of the soldier, stooped, embers in the chest); C17,
	# QW-102: 1.0 s of wind-up, its last 0.3 s held trembling (0.7 was the shortest warning of the game: the PO took 9
	# blows with 0.70 to 0.82 s; Hades' Radiator winds up 1.5 s)
	_pair({"id": &"runner", "model": &"runner", "behavior": B.PULSE, "size": 1.04, "hp": 45.0, "speed": 390.0 / U, "damage": 5.0, "radius": 0.45,
		"attack_damage": 5.0, "attack_range": 1.6, "attack_width": 2.6, "attack_cooldown": 1.4, "attack_windup": 1.0,
		"magic_color": DEAD_CRIMSON, "rating": 7.0, "role": &"react", "tell": T.TREMBLE, "sway": 7.0, "windup_shake": 0.04,
		# T5-04, T5-09: it bursts as its arms open in its spin, 0.1 s into its attack
		"strike_at": 0.1,
		"tint": Color(1.0, 0.72, 0.5), "vivid": 0.1, "stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "recover_time": ENEMY_RECOVER.runner[0]},
		# C19-2 (Q-11): the elite bursts twice in one spin, 0.5 s apart (combat_cadence.md 8.2: a new ring needs that to
		# be read), then Hades' 0.5 s of the Radiator elite
		# (its own bake, runner_elite.res: the same figure with a longer stride for its 7.4 m/s, 199 steps a minute; the
		# common one's would be 259, Lote 2B)
		{"armor": 85.0, "speed": 590.0 / U, "rating": 17.0, "recover_time": ENEMY_RECOVER.runner[1], "strikes": 2, "strike_gap": 0.5,
			"model": &"runner_elite"})
	# Ranged enemies with the numbers of Hades II's ranged ones in its first region (study of 2026-11-16) and Daniel's
	# rule of the same day: they stay at their farthest and shoot, never close in (keep_away is ours: Hades' mage hides
	# instead of running). The caster (Hades: the Mage, its life and rating): 3.5 m/s; from up to 13.1 m (elite 16.25),
	# 1 s of aim following the paladin, a burst of 3 orbs 0.17 s apart (elite 7), each pushing it back at 5 m/s; orbs at
	# 7 m/s for 20 m that turn after him (how fast the files do not say: 20 degrees a second is ours, was 40) only in their
	# first 0.8 s, then straight (C17, QW-101: they caught him late in their flight, the PO's most unfair blow; the robot
	# took 46% of its blows in the rooms from them, 35% with both), 4 damage; then
	# 0.7 to 0.9 s and 1.5 to 2.2 s behind a pillar (elite 0.8 to 1.2), 3.1 m past it; at most 6 at once.
	# Cold violet (Daniel, 2026-11-14) until the VFX pass: magenta, DEAD_MAGENTA.
	_pair({"id": &"mage", "model": &"mage", "behavior": B.ARCHER, "size": 1.27, "hp": 80.0, "speed": 280.0 / U, "damage": 4.0, "radius": 0.5,
		"attack_damage": 4.0, "attack_range": 1050.0 / U, "attack_cooldown": 0.8 + 1.85, "attack_windup": 1.0, "magic_color": DEAD_MAGENTA,
		"shot_orb": true, "shot_speed": 560.0 / U, "shot_range": 1600.0 / U, "shot_turn": 20.0, "shot_homing": 0.8, "shot_ticks": 3, "shot_interval": 0.17,
		"recoil": 400.0 / U, "cover_hug": 250.0 / U, "max_attackers": 6, "keep_away": 0.7,
		"rating": 12.0, "role": &"control", "tell": T.ORB, "tell_at": Vector3(-0.96, 2.0, 0.58), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY,
		"recover_time": ENEMY_RECOVER.mage[0]},
		{"armor": 155.0, "attack_range": 1300.0 / U, "shot_ticks": 7, "attack_cooldown": 0.8 + 1.0, "rating": 24.0})
	# the crossbowman (Hades: the Screamer's life and rating; it has no shot there, a cone held on itself): a fast
	# orange bolt along a line marked on the floor (the aim locks there) from 12 m, Daniel's request of 2026-11-16;
	# from Hades, after each attack it runs 8.75 m from him for 1.5 to 1.75 s, and at most 2 wind up at once; 3.6 m/s
	_pair({"id": &"archer", "model": &"archer", "behavior": B.ARCHER, "size": 1.27, "hp": 130.0, "speed": 290.0 / U, "damage": 3.0, "radius": 0.55,
		"attack_damage": 3.0, "attack_range": 12.0, "attack_cooldown": 1.8, "attack_windup": 0.8, "magic_color": DEAD_CRIMSON,
		"shot_speed": 16.0, "shot_line": true, "keep_away": 0.65, "retreat_far": 700.0 / U, "retreat_time": Vector2(1.5, 1.75), "max_attackers": 2,
		# T5-05: the crossbow rises to the shoulder over its settle (it rose in 0.1 s)
		"windup_settle": 0.25,
		"rating": 13.0, "role": &"flank", "tell": T.BOLT, "tell_at": Vector3(-0.05, 1.62, 1.42), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY,
		"recover_time": ENEMY_RECOVER.archer[0]}, {"armor": 190.0, "rating": 34.0})
	# the brute: a long charge (1.15 s warning) and a slam on whoever comes close
	_pair({"id": &"guard", "model": &"guard", "behavior": B.KNIGHT, "size": 1.5, "hp": 255.0, "speed": 260.0 / U, "damage": 9.0, "radius": 0.75,
		"heavy": true, "attack_damage": 9.0, "attack_range": 500.0 / U + 3.0, "attack_cooldown": 1.9, "attack_windup": 1.15, "lunge_speed": 15.0,
		"lunge_time": 0.4, "close_damage": 7.0, "close_range": 2.6, "close_windup": 0.65,
		# T5-06: braced in three beats, 0.15 s to settle and the last 0.35 s held with a tremble
		"windup_settle": 0.15, "windup_hold": 0.3, "windup_shake": 0.03,
		"rating": 18.0, "role": &"block", "tell": T.SHIELD, "tell_at": Vector3(0.45, 1.1, 0.4), "material": &"shield",
		# its charge in flight is not cut (Hades: the charging Brute, WeaponSetImmuneToStun while it runs)
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "stun_immune_attacking": true, "recover_time": ENEMY_RECOVER.guard[0]}, {"armor": 330.0, "speed": 340.0 / U, "rating": 39.0})
	# the one rooted in place (Hades: the SiegeVine's life, rating and attack): from up to 22.5 m, 0.8 s of warning,
	# one shadow vine creeping along the floor after the paladin at 1.9 m/s, turning 90 degrees a second at first and
	# 15 less each second, for 12 s, 6 damage; then 3.25 s (elite: 3 vines 0.7 s apart, then 2.25 s). Before
	# 2026-11-16 it dropped circles under him: those are Morvath's alone now.
	_pair({"id": &"priest", "model": &"priest", "behavior": B.ARCHER, "size": 1.3, "hp": 290.0, "speed": 0.0, "damage": 6.0, "radius": 0.7,
		"heavy": true, "attack_damage": 6.0, "attack_range": 1800.0 / U, "attack_cooldown": 3.25, "attack_windup": 0.8, "magic_color": DEAD_MAGENTA,
		"shot_orb": true, "shot_speed": 150.0 / U, "shot_turn": 90.0, "shot_turn_decay": 15.0, "shot_range": 150.0 / U * 12.0, "shot_low": true,
		"rating": 22.0, "role": &"area", "tell": T.RITUAL, "tell_at": Vector3(0.0, 1.3, 0.45), "vivid": 0.25,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY},
		{"armor": 390.0, "shot_ticks": 3, "shot_interval": 0.7, "attack_cooldown": 2.25, "rating": 48.0})
	# guardians (Hades: the mid-region bosses): life plus a thick armor
	_enemy({"id": &"knight", "model": &"knight", "size": 2.07, "behavior": B.KNIGHT, "hp": 450.0, "speed": 200.0 / U, "damage": 12.0, "radius": 1.1,
		"heavy": true, "elite": true, "armor": 1220.0, "armor_stagger": 2.5, "attack_damage": 12.0, "attack_range": 14.0, "attack_cooldown": 3.2,
		"attack_windup": 1.0, "lunge_speed": 18.0, "lunge_time": 0.7, "close_damage": 12.0, "close_range": 3.2, "close_windup": 0.8,
		# T5-07: braced behind its shield in three beats (it stood idle), the last 0.3 s held with a tremble
		"windup_settle": 0.12, "windup_hold": 0.3, "windup_shake": 0.03,
		# it stood stunned 0.8 s after its charge (a stun drawn idle); E1c: the same 0.8 s as its recovery, the end of the blow held
		"recover_time": 0.8,
		"rating": 65.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER, "tell": T.SHIELD, "tell_at": Vector3(0.5, 1.1, 0.35), "material": &"armor"})
	_enemy({"id": &"priest_elder", "name_key": &"enemy_priest", "model": &"priest_elder", "size": 2.19, "behavior": B.PRIEST, "hp": 510.0, "speed": 2.0,
		"damage": 9.0, "radius": 1.0, "heavy": true, "elite": true, "armor": 1450.0, "armor_stagger": 2.5, "attack_damage": 9.0, "attack_range": 9.0,
		"attack_cooldown": 3.4, "attack_windup": 1.0, "magic_color": DEAD_MAGENTA, "shot_orb": true, "shot_speed": 7.0,
		"shot_count": 5, "shot_spread": 70.0, "rating": 50.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER,
		"tell": T.ORB, "tell_at": Vector3(-1.02, 2.15, 0.6)})
	# the last of the region: Hades II's first guardian has 6050 life and hits for 4 to 14. His necromancy is the cold
	# spectral green of Daniel's request of 2026-11-15 (SPECTRAL: bluer and paler than Emeth's crystal green); the
	# fight's numbers are data/bosses/morvath.tres (_bosses)
	_enemy({"id": &"morvath", "model": &"morvath", "size": 2.53, "behavior": B.BOSS, "hp": 6050.0, "speed": 600.0 / U * 0.5, "damage": 8.0, "radius": 1.4,
		"heavy": true, "armor": 0.0, "attack_damage": 10.0, "magic_color": SPECTRAL, "rim_color": Color(0.45, 0.3, 0.6), "rim": 0.3,
		"vivid": 0.9, "tint": Color(0.94, 0.86, 1.14), "crest": 0.5, "shine": 1.5, "material": &"spectral"})


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

## One number of a Blessing (C13-05, Hades II's curve): base at level 1 (times the rarity), per_level the fixed gain of
## level 2, 3... (the last one again after it; never scaled by rarity). The numbers of before migrated as they were
## at a common card: base the old level 1, the gains the old steps 1 to 2 and 2 to 3.
func _mod(stat: StringName, base: float, per_level: Array = [], tag: StringName = &"", by_rarity: bool = true) -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.tag = tag
	m.base = base
	m.per_level = PackedFloat32Array(per_level)
	m.by_rarity = by_rarity
	return m


## A number rarity must not change (counts, cooldowns, sizes).
func _fixed(stat: StringName, base: float, per_level: Array = [], tag: StringName = &"") -> BoonMod:
	return _mod(stat, base, per_level, tag, false)


func _skill(kind: SkillDef.Kind, props: Dictionary) -> SkillDef:
	var s := SkillDef.new()
	s.kind = kind
	for k: String in props:
		s.set(k, PackedFloat32Array(props[k]) if props[k] is Array else props[k])
	return s


func _boon(n: int, id: StringName, family: Boon.Family, icon: int, mods: Array[BoonMod], skill: SkillDef = null, slot: Boon.Slot = Boon.Slot.NONE) -> void:
	var b := Boon.new()
	b.id = id
	b.slot = slot
	b.family = family
	b.icon = icon
	b.mods = mods
	b.skill = skill
	_save(b, "res://data/boons/%02d_%s.tres" % [n, id])


## An Elo (E3-02, Hades II's duo): one gift of each list forms it (the first of each list is the one the card shows
## when none is held); no level beyond 1 and no rarity (BUG-017), its number the old level 1.
func _elo(n: int, id: StringName, icon: int, mods: Array[BoonMod], sets: Array) -> void:
	var b := Boon.new()
	b.id = id
	b.family = Boon.Family.DUO
	b.icon = icon
	b.mods = mods
	b.max_level = 1
	for list: Array in sets:
		b.requires_sets.append(PackedStringArray(list))
	_save(b, "res://data/boons/%02d_%s.tres" % [n, id])


func _boons() -> void:
	for f in DirAccess.get_files_at("res://data/boons"):
		DirAccess.remove_absolute("res://data/boons/" + f)
	var F := Boon.Family
	var K := SkillDef.Kind
	var S := Boon.Slot
	_boon(0, &"brasas", F.CHAMA, 0, [], _skill(K.STRIKES, {"damage": [18, 26, 36], "count": [3, 4, 6], "cooldown": [3.5, 3.0, 2.5], "radius": [2.2, 2.4, 2.6], "status": &"burn", "status_power": [5, 7, 9]}))
	_boon(1, &"redemoinho", F.CHAMA, 1, [], _skill(K.ORBIT, {"damage": [10, 14, 19], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"burn", "status_power": [4, 6, 8]}))
	_boon(2, &"lamina_ardente", F.CHAMA, 2, [_mod(&"burn_dps", 6, [3, 3], &"finisher"), _mod(&"damage_pct", 0.2, [0.15, 0.15], &"finisher")])
	_boon(3, &"toque_geada", F.GEADA, 3, [_mod(&"freeze_time", 1.0, [0.5, 0.5], &"heavy")], null, S.SPECIAL)
	_boon(4, &"estilhaco", F.GEADA, 4, [_mod(&"shatter_pct", 0.5, [0.3, 0.2])], _skill(K.NOVA, {"damage": [20, 30, 42], "cooldown": [6, 5, 4], "radius": [5, 6, 7], "status": &"freeze", "status_power": [1.2, 1.5, 1.8]}))
	_boon(5, &"peso_inverno", F.GEADA, 5, [], _skill(K.METEOR, {"damage": [60, 90, 130], "cooldown": [9, 8, 7], "radius": [4.0, 4.5, 5.0], "status": &"freeze", "status_power": [2.0, 2.2, 2.5]}))
	_boon(6, &"consolo", F.LUZ, 6, [_mod(&"heal_on_kill", 0.4, [0.3, 0.3])])
	_boon(7, &"onda_maior", F.LUZ, 7, [], _skill(K.FAN, {"damage": [16, 22, 30], "count": [5, 8, 11], "cooldown": [5.0, 4.5, 4.0], "radius": [12, 13, 14]}))
	_boon(8, &"flagelo", F.LUZ, 8, [], _skill(K.STRIKES, {"damage": [24, 32, 44], "count": [4, 6, 9], "cooldown": [4.5, 4.0, 3.5], "radius": [1.6, 1.8, 2.0], "status": &"stun", "status_power": [0.4, 0.5, 0.6]}))
	_boon(9, &"escudo", F.VIGILIA, 9, [_fixed(&"shield_cooldown", 12, [-3, -3])])
	_boon(10, &"passos", F.VIGILIA, 10, [_fixed(&"dodge_charges", 1, [0, 1]), _fixed(&"move_speed_pct", 0.08, [0.06, 0.06])], null, S.DASH)
	_boon(11, &"firmeza", F.VIGILIA, 11, [_mod(&"max_hp", 20, [15, 15])], _skill(K.CONSECRATE, {"damage": [12, 18, 26], "cooldown": [8, 7, 6], "radius": [4, 5, 6], "status": &"slow", "status_power": [4.0, 4.5, 5.0]}))
	# The Elos (E3-02): one gift of each family's list. Burn and frost come from any gift of the flame or the frost; the
	# light that hits on its own (the fan, the scourge) is what aurora and chama_viva change; bastiao bursts the
	# Vigília's shield; rastro and passo_frio ride the dodge of any Vigília gift.
	var chama := [&"brasas", &"redemoinho", &"lamina_ardente", &"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"omega_brasa", &"chuva_brasas"]
	var geada := [&"toque_geada", &"estilhaco", &"peso_inverno", &"golpe_geada", &"circulo_geada", &"passo_geada", &"geada_final", &"floco_errante", &"omega_geada"]
	var luz_hits := [&"onda_maior", &"flagelo"]
	var luz := [&"consolo", &"onda_maior", &"flagelo", &"golpe_radiante", &"pesado_radiante", &"circulo_radiante", &"passo_radiante", &"final_radiante", &"onda_clara"]
	var vigilia := [&"passos", &"escudo", &"firmeza", &"golpe_firme", &"pesado_firme", &"circulo_firme", &"vigia_firme", &"vigilia_longa", &"guarda_atenta"]
	_elo(12, &"vapor", 12, [_mod(&"steam_time", 2)], [chama, geada])
	_elo(13, &"aurora", 13, [_mod(&"freeze_time", 0.8, [], &"luz")], [luz_hits, geada])
	_elo(14, &"chama_viva", 14, [_mod(&"burn_dps", 5, [], &"luz")], [chama, [&"flagelo", &"onda_maior"]])
	_elo(15, &"bastiao", 15, [_mod(&"shield_burst", 40)], [[&"escudo"], luz])
	_elo(16, &"rastro", 16, [_mod(&"dodge_ember_dps", 8)], [vigilia, chama])
	_elo(17, &"passo_frio", 17, [_mod(&"freeze_time", 1.0, [], &"dash")], [vigilia, geada])
	# One gift per action (Boon.Slot): attack = light moves, special = heavy moves, cast = the circle of light, dash.
	_boon(18, &"golpe_brasa", F.CHAMA, 2, [_mod(&"burn_dps", 4, [2, 2], &"light")], null, S.ATTACK)
	_boon(19, &"golpe_geada", F.GEADA, 3, [_mod(&"freeze_time", 0.3, [0.15, 0.15], &"light")], null, S.ATTACK)
	_boon(20, &"golpe_radiante", F.LUZ, 8, [_mod(&"damage_pct", 0.25, [0.15, 0.15], &"light")], null, S.ATTACK)
	_boon(21, &"golpe_firme", F.VIGILIA, 11, [_fixed(&"reach_pct", 0.12, [0.06, 0.07], &"light"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"light")], null, S.ATTACK)
	_boon(22, &"pesado_brasa", F.CHAMA, 0, [_mod(&"burn_dps", 6, [3, 3], &"heavy")], null, S.SPECIAL)
	_boon(23, &"pesado_radiante", F.LUZ, 7, [_mod(&"damage_pct", 0.3, [0.15, 0.15], &"heavy")], null, S.SPECIAL)
	_boon(24, &"pesado_firme", F.VIGILIA, 15, [_fixed(&"reach_pct", 0.15, [0.07, 0.08], &"heavy"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"heavy")], null, S.SPECIAL)
	_boon(25, &"circulo_brasa", F.CHAMA, 1, [_mod(&"burn_dps", 8, [4, 4], &"cast")], null, S.CAST)
	_boon(26, &"circulo_geada", F.GEADA, 4, [_mod(&"freeze_time", 1.0, [0.4, 0.4], &"cast")], null, S.CAST)
	_boon(27, &"circulo_radiante", F.LUZ, 6, [_mod(&"cast_dps", 16, [8, 8], &"cast"), _mod(&"damage_pct", 0.3, [0.15, 0.15], &"cast")], null, S.CAST)
	_boon(28, &"circulo_firme", F.VIGILIA, 9, [_fixed(&"cast_size_pct", 0.25, [0.15, 0.15])], null, S.CAST)
	_boon(29, &"passo_brasa", F.CHAMA, 16, [_mod(&"dodge_ember_dps", 6, [3, 3])], null, S.DASH)
	_boon(30, &"passo_geada", F.GEADA, 17, [_mod(&"freeze_time", 0.8, [0.4, 0.4], &"dash")], null, S.DASH)
	_boon(31, &"passo_radiante", F.LUZ, 10, [_mod(&"damage_pct", 0.4, [0.2, 0.2], &"dash")], null, S.DASH)
	# Fatia 2 (sistemas.md 1.6, 3.6): 2 to 3 Blessings more a family, all on their own (no action taken), so an angel
	# meets a hand with three offers more often; Geada and Vigília (six each) first. Only stats the game knows.
	_boon(32, &"geada_final", F.GEADA, 3, [_mod(&"freeze_time", 0.6, [0.3, 0.3], &"finisher")])
	_boon(33, &"floco_errante", F.GEADA, 4, [], _skill(K.ORBIT, {"damage": [8, 11, 15], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"freeze", "status_power": [0.5, 0.6, 0.7]}))
	_boon(34, &"omega_geada", F.GEADA, 5, [_mod(&"freeze_time", 1.2, [0.4, 0.4], &"omega")])
	_boon(35, &"vigia_firme", F.VIGILIA, 9, [_fixed(&"stun_pct", 0.3, [0.15, 0.15])])
	_boon(36, &"vigilia_longa", F.VIGILIA, 11, [_mod(&"magick_max", 15, [10, 10])])
	_boon(37, &"guarda_atenta", F.VIGILIA, 10, [_fixed(&"move_speed_pct", 0.06, [0.04, 0.04]), _fixed(&"reach_pct", 0.06, [0.03, 0.03], &"light")])
	_boon(38, &"omega_brasa", F.CHAMA, 2, [_mod(&"burn_dps", 8, [4, 4], &"omega")])
	_boon(39, &"chuva_brasas", F.CHAMA, 0, [], _skill(K.METEOR, {"damage": [40, 60, 85], "cooldown": [9, 8, 7], "radius": [3.5, 4.0, 4.5], "status": &"burn", "status_power": [6, 8, 10]}))
	_boon(40, &"final_radiante", F.LUZ, 8, [_mod(&"damage_pct", 0.2, [0.1, 0.1], &"finisher")])
	_boon(41, &"onda_clara", F.LUZ, 7, [_fixed(&"wave_size_pct", 0.2, [0.1, 0.1], &"heavy"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"heavy")])


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


func _shop_group(items: Array, prices: Array, weights: Array, count: int = 1) -> ShopGroup:
	var g := ShopGroup.new()
	g.count = count
	g.items = PackedInt32Array(items)
	g.prices = PackedInt32Array(prices)
	g.weights = PackedFloat32Array(weights)
	return g


## The catacombs as a region of rooms, with the room generator and rewards of the first region of Hades II.
func _stage() -> void:
	var st := StageDef.new()
	# The whole region of Hades II (C13-01, decision D-61): ten rooms and Morvath in the 11th. The opening in the
	# catacomb hall, fights drawn among the crypt, the rift hall and the garden (never the same twice in a row, none
	# more than arena_max_uses times), the guardian in room 4 to 6, the fountain once in room 5 to 8, the shop in room
	# 10 (Hades II's antechamber shop). --medium plays the test one of 7 of cycle C12, --short the old one of 5
	# (Rooms.short_stage).
	st.rooms = 10
	st.arena_max_uses = 3
	# elites from depth 3, as in Hades II (the shorter descents keep them from the 2nd room)
	st.elite_from_depth = 3
	st.miniboss_depth_min = 4
	st.miniboss_depth_max = 6
	st.minibosses = [&"knight", &"priest_elder"]
	st.fountain_depth_min = 5
	st.fountain_depth_max = 8
	st.fountain_chance = 0.35
	# DV-1: a second fountain at the last of its depths on another branch whenever no way passes two (the line of rooms
	# before the map offered the fountain again until its last depth; the robot drank there in 10 of 19 descents)
	st.fountain_more_chance = 1.0
	st.boss = &"morvath"
	# The descent's graph (DV-1, the Descida de Valmor; RunMap): 2 to 4 rooms a layer between the hall and the shop
	# (35%, 45%, 20%), a room linked to 2 of the next five times as likely as to 1 and to 3 twice (most rooms show two
	# doors, as the doors of the line before the map), the Knight and the Elder side by
	# side in the guardian's layer half the time (Q-27 a), a pomegranate behind a door from room 3 (Q-25 a)
	st.map_widths = PackedFloat32Array([0.35, 0.45, 0.2])
	st.map_doors = PackedFloat32Array([1.0, 5.0, 2.0])
	st.guardian_pair_chance = 0.5
	st.pom_from_depth = 3
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
	# The doors' deck (C13-02, Hades II's RunProgress: 4 Blessings, 2 hearts, 2 Magia tonics, 2 gold, 2 pomegranates,
	# 2 hammers, Hermes, Selene, the star path and a room of two gods). What we do not have yet is left out (hammer,
	# Selene, star path); Hermes and the two gods' room are Blessings here. Drawn without putting back, filled again.
	# Rejogabilidade, Fatia 1 (sistemas.md 3.1): one door of Prata and one of Memória more, nothing taken (14 to 16).
	# Fatia 2 (sistemas.md 1.7, 3.6): two Encantos (Hades II's two hammer cards) and a Psalm's door, and two Blessings
	# more so they keep their share of the deck (6 of 16, now 8 of 21: with the six of before the robot reached Morvath
	# with a Blessing less and won 46 of 72 against 58, 2026-11-20); of the Blessings two in six are a meeting of two
	# angels and the rest show one angel (angel_deck, Q-RJ5 a).
	st.reward_deck = PackedInt32Array([R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.POM, R.POM,
		R.HEART, R.HEART, R.MAGICK, R.MAGICK, R.GOLD, R.GOLD, R.SILVER, R.MEMORY, R.ENCHANT, R.ENCHANT, R.PSALM])
	st.angel_deck = PackedInt32Array([1, 1, 0, 0, 0, 0])
	# the Psalm's door from the 4th room (a Psalm needs three things of the hand); at most two Encantos on a way, the
	# second from the 5th room (Hades II's late hammer: past half the run)
	st.psalm_from_depth = 4
	st.enchant_max = 2
	st.enchant_second_from = 5
	# What a descent brings home (sistemas.md 1.2, starting numbers for the balance-designer): Prata by an elite 1, a
	# door 10, a guardian 6, Morvath 2 a phase reached (up to 8) and 10 at the sealing; Memória by a door 3, a guardian 2,
	# a Provação won 2 and the sealing 3.
	st.silver_elite = 1
	st.silver_door = 10
	st.silver_guardian = 6
	st.silver_phase = 2
	st.phase_max = 4
	st.silver_victory = 10
	st.memory_door = 3
	st.memory_guardian = 2
	st.memory_trial = 2
	st.memory_victory = 3
	# Esmeralda (Fatia 2): 1 when Morvath's phase 3 is reached, 1 at the sealing
	st.emerald_phase_at = 3
	st.emerald_phase = 1
	st.emerald_victory = 1
	# Gold (C13-04, Hades II): a fight's ceiling 10 to 15 plus 0.5 a room of depth, 70% that each enemy leaves its
	# share; a gold reward 100.
	st.gold_cap_min = 10
	st.gold_cap_max = 15
	st.gold_per_depth = 0.5
	st.gold_drop_chance = 0.7
	st.gold_reward = 100
	# Blessings (C13-03, C13-06, E3-01): rarity tried in turn (rare 10%, epic 5%; the legendary only by a trade), the
	# guardian's (rare 90%, epic 7%; Hades II's 5% legendary is the Psalm, none yet), Elo 12% a card, trade 10% a card.
	st.rarity_chance = [0.10, 0.05, 0.0] as Array[float]
	st.guardian_rarity_chance = [0.90, 0.07, 0.0] as Array[float]
	st.elo_chance = 0.12
	st.trade_chance = 0.1
	# a Psalm (E4): 10% of the cards once one can be offered, 5% at the guardian (guardian_spec.md 11.1)
	st.psalm_chance = 0.1
	st.guardian_psalm_chance = 0.05
	# The shop (C13-04, Hades II's WorldShop): items from three groups. A Blessing 150; healing 50 (40% of life) and a
	# heart 125; growth: two of a Magia tonic 100, a pomegranate 100 and its slice 50. Ours is the last shop before the
	# final boss, which in Hades II shows five items (one of each group in the shops along the way): 1 + 2 + 2. With one
	# of each (E3 first measure) the robot bought in 4 of 8 runs: healing and the slice were often not on the shelf.
	st.shop_groups = [
		_shop_group([R.BOON], [150], [1.0], 1),
		_shop_group([R.HEAL, R.HEART], [50, 125], [1.0, 1.0], 2),
		# an Encanto 200 with the growth (Fatia 2; Hades II keeps the hammer by the healing, ours keeps the healing on
		# the shelf always)
		_shop_group([R.MAGICK, R.POM, R.POM_SLICE, R.ENCHANT], [100, 100, 50, 200], [1.0, 1.0, 1.0, 1.0], 2),
	]
	st.shop_heal = 0.4
	# The arenas (cycle C12; docs/design/cycle12_arenas_plan.md, plans in docs/art/cycle12_arenas_spec.md). The catacomb
	# hall of Daniel's reference image (CatacombHall: its pieces and collision live there) is the opening, the fountain
	# and the shop (decision D-26); the fights after it are drawn among the crypt, the rift hall and the garden
	# (RunMap._layout), never the same twice in a row. Each is data: floor with holes, obstacles (collision and look),
	# spawn zones, doors, camera box, two variants.
	var hall := _layout(CatacombHall.HALF, [], [])
	hall.platform = true
	_arena(hall, &"hall", RoomLayout.Size.MEDIUM, 0, Vector2(0.0, 0.0))
	hall.fountain = true
	# E5 (docs/art/e5_spec.md): the Santuário (the guardian's house, high, from 40% of the descent), the Ponte and the
	# Câmara das Runas (high, from half of it); the rooms of the two events
	st.layouts = [hall, _crypt(), _rift(), _garden(), _sanctuary(), _bridge(), _runes()]
	st.shop_layout = hall
	st.trial_layout = _trial_room()
	st.altar_layout = _altar_room()
	# The Provação (Hades II's Chaos, hades2_sistemas.md 7): 20% a room won, from the 2nd room to the 7th (a curse of 3
	# to 5 fights must have fights to be carried in before the shop), once in 10 rooms (once in a descent), at
	# ceil(10 + 0.5 x depth) life; three cards, the blessing's rarity as the Chaos's (rare 40%, epic 10%).
	st.trial_chance = 0.2
	st.trial_depth_min = 2
	st.trial_depth_max = 7
	st.trial_cooldown = 10
	st.trial_cost_base = 10.0
	st.trial_cost_per_depth = 0.5
	st.trial_cards = 3
	st.trial_rarity_chance = [0.4, 0.1, 0.0] as Array[float]
	# The Altar Esquecido (ours): a door to it once, 20% a room from the 2nd to the 8th; 10 of the most life for a
	# pomegranate, or 75 gold (half a Blessing in the shop) for 25 more Magia
	st.altar_depth_min = 2
	st.altar_depth_max = 8
	st.altar_chance = 0.2
	# DV-2 (MAP-09): a route shop of three items (a Blessing, healing or a heart, the growth's) on one branch of the
	# 6th to 8th rooms, 35% a layer where it may stand (about a third of the maps), beside the last one in the 10th
	st.route_shop_depth_min = 6
	st.route_shop_depth_max = 8
	st.route_shop_chance = 0.35
	st.route_shop_items = 3
	st.altar_life_cost = 10.0
	st.altar_gold_cost = 75
	st.altar_magick = 25.0
	# Morvath fights in his own round chamber (cycle C11, the Seal Chamber: docs/design/boss_arena.md for the radius,
	# docs/art/boss_chamber_spec.md for the plan): a circle of 12.5 m to the balustrade's inner face, so the paladin's
	# middle walks up to 12 m from the seal; he comes in at the mouth of the south stairs facing north, Morvath stands
	# on the seal; the camera keeps to a point 0.7 m from the seal toward it and moves off it at most 3 m
	st.boss_layout = _chamber()
	_save(st, "res://data/stages/catacombs.tres")


# ---------- arenas (cycle C12) ----------

## What an arena is: its id and name, who draws it, its size, difficulty and place in the descent.
func _arena(l: RoomLayout, id: StringName, size: RoomLayout.Size, difficulty: int, depth: Vector2) -> void:
	l.id = id
	l.name_key = StringName("arena_" + String(id))
	l.look = id
	l.size_class = size
	l.difficulty = difficulty
	l.depth = depth


## A polygon from flat pairs of numbers (x, z, x, z...).
func _poly(xz: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, xz.size(), 2):
		out.append(Vector2(xz[i], xz[i + 1]))
	return out


func _rect(x0: float, x1: float, z0: float, z1: float) -> Rect2:
	return Rect2(x0, z0, x1 - x0, z1 - z0)


## Obstacles of the spec's tables. A piece blocks shots when its top passes 1.25 m (spec 0.3); up to 1.0 m a shot
## flies over it. Columns and tall pieces open in a stipple round the paladin (see_through).
func _column(x: float, z: float, top: float, r := 0.7) -> ArenaObstacle:
	return ArenaObstacle.circle(Vector2(x, z), r, &"column", top, top >= 1.25, true)


## RP-09: a cracked column that topples (the falling tree of the Hades II's Erebus): the first blow of the paladin
## cracks it, the second topples it away from him: a band of 1.2 x 5 m shown 0.6 s while it leans, 50 to each enemy on
## it (a whole skeleton almost), 0 to him; then a stump. Santuário (15, -6) and (-9, 6), Jardim A (4.5, 7), Cripta B
## (6.5, -6).
func _cracked(o: ArenaObstacle) -> ArenaObstacle:
	o.hits_to_fall = 2
	o.fall_length = 5.0
	o.fall_width = 1.2
	o.fall_time = 0.6
	o.fall_damage = 50.0
	return o


## A box lying along x (or along z when turned), of size w x d.
func _sarcophagus(x: float, z: float, w: float, d: float, top := 1.35, piece := &"sarcophagus", see := false) -> ArenaObstacle:
	return ArenaObstacle.box(Vector2(x, z), Vector2(w, d) * 0.5, 0.0, piece, top, top >= 1.25, see)


## A capsule of the spec (a low wall, a root) from a to b, `width` across: a box over it, its round ends taken square.
func _capsule(a: Vector2, b: Vector2, width: float, top: float, piece := &"block") -> ArenaObstacle:
	var d := b - a
	return ArenaObstacle.box((a + b) * 0.5, Vector2(d.length() * 0.5 + width * 0.5, width * 0.5), d.angle(), piece, top, top >= 1.25)


## A root along points (each leg a capsule), from inside the trunk at `trunk` (radius r) out to its tip.
func _root(trunk: Vector2, r: float, pts: Array, top := 0.6) -> Array[ArenaObstacle]:
	var out: Array[ArenaObstacle] = []
	var first: Vector2 = pts[0]
	var prev := trunk + (first - trunk).normalized() * (r - 0.5)
	for p: Vector2 in pts:
		out.append(_capsule(prev, p, 1.0, top, &"root"))
		prev = p
	return out


## A fire bowl or lantern of a door, off the walkable floor: drawn, never blocking.
func _bowl(x: float, z: float) -> ArenaObstacle:
	var o := ArenaObstacle.circle(Vector2(x, z), 0.45, &"brazier", 1.2, false)
	o.blocks_move = false
	return o


func _variant(obstacles: Array[ArenaObstacle], floor: FloorShape = null, late: Array[Rect2] = []) -> ArenaVariant:
	var v := ArenaVariant.new()
	v.obstacles = obstacles
	v.floor = floor
	v.late_spawns = late
	return v


## RP-06 (H-2, docs/design/rooms_progression.md): slabs of 3 x 3 m that anyone stepping on arms (the paladin or an enemy:
## the steam trap of the Hades II), marked at rest; 1.0 s lighting from the edge to the middle (never under an enemy's
## wind-up), a strike of 0.25 s on whoever stands on it with the runes' numbers (RP-03: 7 to him, 60 to an enemy), 5 s
## before it may arm again, nothing in the first 3 s; asleep (drawn, never striking) before the descent reaches `from`.
## Each slab at least 6 m from the way in and off the doors' mouths (test_plates.gd).
func _plates(rects: Array[Rect2], from := 0.0) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	h.plates = rects
	h.warn = 1.0
	h.fire = 0.25
	h.rearm = 5.0
	h.start_delay = 3.0
	h.from_progress = from
	h.hero_damage = 7.0
	h.enemy_damage = 60.0
	return h


## RP-06: the slabs wake from the 4th room (progress 0.34); in the 2nd and 3rd they lie at rest and teach.
const PLATES_FROM := 0.34


## Cripta dos Esquecidos (spec section 2): small, closed, sarcophagi and columns as cover; 4 to 6 enemies, at most 2
## shooters, no priest.
func _crypt() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"crypt", RoomLayout.Size.SMALL, 1, Vector2(0.1, 1.0))
	l.floor = FloorShape.poly([_poly([-12, -10.5, 8.5, -10.5, 12, -7, 12, 10.5, -12, 10.5])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(4, 6)
	l.max_ranged = 2
	l.banned_roles = [&"area"]
	l.guardian = false
	var bowls: Array[ArenaObstacle] = [_bowl(1.5, -11.0), _bowl(7.1, -11.0)]
	var a: Array[ArenaObstacle] = [
		_sarcophagus(0.5, 0.0, 4.0, 2.0, 1.5),
		_column(-6.0, -5.6, 5.2, 0.65), _column(7.0, -5.6, 5.2, 0.65), _column(-5.5, 5.6, 5.2, 0.65),
		_sarcophagus(0.5, -5.6, 2.5, 1.2), _sarcophagus(4.0, 5.6, 2.5, 1.2), _sarcophagus(-11.4, -6.0, 1.2, 2.5),
		_capsule(Vector2(-12, 0), Vector2(-8, 0), 0.6, 0.9), _capsule(Vector2(12, 0.5), Vector2(8, 0.5), 0.6, 0.9),
	]
	a.append_array(bowls)
	l.obstacles = a
	# variant B, "Ossuary": a dividing wall from the north wall, the south half open (LR-06, the wall to 12 m, was tried
	# on 2026-11-20 and put back: with the robot the fight went south, 40 to 55% of his time in the south third)
	var b: Array[ArenaObstacle] = [
		_sarcophagus(0.5, -7.0, 0.8, 7.0, 3.2, &"block", true),
		_sarcophagus(-5.5, -9.25, 1.2, 2.5), _cracked(_column(6.5, -6.0, 5.2, 0.65)),
		_sarcophagus(-4.0, 3.0, 2.5, 1.2), _sarcophagus(3.0, 3.0, 2.5, 1.2),
		_capsule(Vector2(-12, -2.5), Vector2(-8, -2.5), 0.6, 0.9), _capsule(Vector2(12, 1.0), Vector2(8, 1.0), 0.6, 0.9),
	]
	b.append_array(bowls)
	l.variants = [_variant(b)]
	l.hero_spawn = Vector2(-10.0, 4.5)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(4.3, -10.5), Vector2(0, 1)), ArenaExit.at_edge(Vector2(12, 5.5), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(-2, 10.5), Vector2(0, -1))]
	l.spawns = [_rect(2, 7, -9.5, -7.5), _rect(8.5, 11.2, -4, -0.5), _rect(6.5, 11, 7, 9.5), _rect(-10, -7.5, -10, -8)]
	# the whole crypt fits the screen: the camera keeps to one point, as in the Seal Chamber
	l.cam_target = Vector2(1.0, 1.5)
	l.cam_reach = 2.5
	# RP-01: the rows of the crypt (the north one behind the columns, the middle round the great tomb, the south one
	# of the way in); B: either side of the dividing wall, and the open south
	_areas(l, ["north", _rect(-12, 12, -10.5, -3), "middle", _rect(-12, 12, -3, 3), "south", _rect(-12, 12, 3, 10.5)])
	_areas(l.variants[0], ["west_of_wall", _rect(-12, 0.5, -10.5, -3), "east_of_wall", _rect(0.5, 12, -10.5, -3),
		"south_open", _rect(-12, 12, -3, 10.5)])
	# RP-06: slabs by the walls, off the 4 m ways round the great tomb, off the spawns and 6 m or more from the way in
	# (its south-west corner is the way in: three corners and the east side). B: at the foot of the dividing wall, one
	# on each side of its end.
	l.hazard = _plates([_rect(-7.2, -4.2, -10.3, -7.3), _rect(8.0, 11.0, -7.5, -4.5), _rect(2.0, 5.0, 7.3, 10.3),
		_rect(8.0, 11.0, 1.3, 4.3)], PLATES_FROM)
	l.variants[0].hazard = _plates([_rect(-3.4, -0.4, -6.3, -3.3), _rect(1.4, 4.4, -6.3, -3.3)], PLATES_FROM)
	return l


## The rift of the hall of the rifts, cut by its two bridges (each bridge is the floor left between two pieces of it)
## or by one (variant B: the north bridge fell). It runs out through the north edge into the abyss outside.
const RIFT_NORTH := [-7, -17, -7, -12, 2, -12, 2, -17]
const RIFT_MIDDLE := [-7, -7, -7.8, -5, -6.6, -3, -7, -1, 2, -1, 1.6, -3, 2.8, -5, 2, -7]
const RIFT_SOUTH := [-7, 4, -7.6, 6, -6.4, 8, -5, 9.4, -2.5, 10, 0.3, 9.2, 1.6, 8, 2.6, 6, 2, 4]
const RIFT_FALLEN := [-7, -17, -7, -12, -7, -7, -7.8, -5, -6.6, -3, -7, -1, 2, -1, 1.6, -3, 2.8, -5, 2, -7, 2, -12, 2, -17]


## Salão das Fendas (spec section 3): big, a rift across 83% of its depth, two bridges of 5 m and a way round its
## south end; every door on the east platform. 6 to 8 enemies.
func _rift() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"rift", RoomLayout.Size.LARGE, 1, Vector2(0.1, 1.0))
	var outline := _poly([-21, -12, -18, -15, 21, -15, 21, 9, 15, 15, -15, 15, -21, 10])
	l.floor = FloorShape.poly([outline], [_poly(RIFT_NORTH), _poly(RIFT_MIDDLE), _poly(RIFT_SOUTH),
		_poly([8, -6.5, 9.5, -8.2, 12.5, -8.4, 14.6, -6.2, 14, -2.6, 11, -1.8, 8.4, -3.4])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	var bowls: Array[ArenaObstacle] = [_bowl(8.5, -15.6), _bowl(15.5, -15.6)]
	var a: Array[ArenaObstacle] = [
		_sarcophagus(14.0, 7.0, 3.6, 1.0, 2.6, &"block", true), _column(7.5, 3.0, 3.8),
		_sarcophagus(-14.0, -5.5, 1.2, 2.5), _column(-13.0, 3.0, 3.2),
		# RP-05: low stumps (1.5 m, they stop shots): one each side of the rift between the two bridge heads, off their
		# line (a foothold for the crossing), and one in the east fight, where he spends half the room (one each side
		# blocked 6% of the shots (4% before), the three 11%; the open hall stays the most open room)
		_column(-10.5, -4.0, 1.5, 0.6), _column(5.5, -4.0, 1.5, 0.6), _column(12.5, 1.0, 1.5, 0.6),
	]
	a.append_array(bowls)
	l.obstacles = a
	var b: Array[ArenaObstacle] = [
		_sarcophagus(14.0, 7.0, 3.6, 1.0, 2.6, &"block", true), _column(8.0, -4.0, 3.8), _column(13.0, -8.5, 3.4),
		_column(15.0, -1.0, 2.9), _sarcophagus(-13.5, -10.5, 2.5, 1.2),
	]
	b.append_array(bowls)
	var fallen := FloorShape.poly([outline], [_poly(RIFT_FALLEN), _poly(RIFT_SOUTH),
		_poly([-17.5, -3, -16, -5.2, -13, -5.6, -11.3, -3.5, -11.6, -0.4, -14, 0.6, -16.6, -0.6])])
	# RP-08: the rift breathes along its brink where the fight is (RIFT_BREATH: the east brink by the south bridge and
	# the south way) and on the west of the middle hole (B: along the fallen bridge), off the bridge heads and the spawns
	l.hazard = _breath(RIFT_BREATH + [_rect(-10.8, -8.0, -7, -1)], RIFT_BREATH_PUSH + [Vector2(-BREATH_PUSH, 0)])
	l.variants = [_variant(b, fallen, [_rect(-19.5, -15.5, -12, -7)])]
	# B (the north bridge fallen): its west stretch along the fallen bridge's brink, away from the second hole
	l.variants[0].hazard = _breath(RIFT_BREATH + [_rect(-10.0, -7.2, -13, -7)], RIFT_BREATH_PUSH + [Vector2(-BREATH_PUSH, 0)])
	# RP-07 (the room-designer's bands, by the damage measured): A early to the middle, B from the 4th room on
	l.variant_depth = Vector2(0.1, 0.6)
	l.variants[0].depth = Vector2(0.34, 1.0)
	l.hero_spawn = Vector2(-18.0, 6.5)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(12, -15), Vector2(0, 1)), ArenaExit.at_edge(Vector2(21, 2), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(8, 15), Vector2(0, -1))]
	# nobody rises on a bridge or in the south way; the first wave across the rift, the west zone from the second
	l.spawns = [_rect(5, 11, -13.5, -10.5), _rect(16, 19.5, -8, -2), _rect(5, 11, 7, 12)]
	l.late_spawns = [_rect(-17, -11, -13, -9)]
	l.cam_bounds = _rect(-6, 7, -4, 5)
	# RP-01: which bridge, or the way round the south
	_areas(l, ["bridge_n", _rect(-7, 2, -12, -7), "bridge_s", _rect(-7, 2, -1, 4), "south_way", _rect(-8, 3, 9, 15),
		"west", _rect(-21, -7, -15, 15), "east", _rect(2, 21, -15, 15)])
	return l


## Jardim das Raízes Mortas (spec section 4): a petrified tree off the middle (its trunk stops bodies and shots),
## low roots that stop bodies only, sarcophagi and broken columns. 6 to 8 enemies.
const TRUNK := Vector2(-8.0, -5.0)
const TRUNK_RADIUS := 3.5


func _garden() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"garden", RoomLayout.Size.MEDIUM, 1, Vector2(0.1, 1.0))
	l.floor = FloorShape.poly([_poly([-17, -10, -13, -14, 17, -14, 17, 8, 11, 14, -12, 14, -17, 9])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	var trunk := ArenaObstacle.circle(TRUNK, TRUNK_RADIUS, &"trunk", 4.5, true, true)
	var bowls: Array[ArenaObstacle] = [_bowl(10.5, -14.6), _bowl(15.5, -14.6), _bowl(17.6, -2.6)]
	var a: Array[ArenaObstacle] = [trunk]
	for pts: Array in [[Vector2(-4.5, -7.0), Vector2(-2.5, -7.7), Vector2(-0.4, -8.1), Vector2(1.8, -8.1)],
			[Vector2(-5.2, -2.2), Vector2(-3.5, -0.8), Vector2(-1.6, 0.3), Vector2(0.3, 1.2)],
			[Vector2(-10.0, -1.5), Vector2(-10.8, 0.1), Vector2(-11.4, 1.9), Vector2(-11.9, 3.6)],
			[Vector2(-11.5, -7.0), Vector2(-12.8, -7.8)]]:
		a.append_array(_root(TRUNK, TRUNK_RADIUS, pts))
	a.append_array([_sarcophagus(7.5, -5.0, 2.5, 1.2), _sarcophagus(-16.4, -1.5, 1.2, 2.5),
		_capsule(Vector2(9, 5), Vector2(13, 5), 0.8, 1.0), _cracked(_column(4.5, 7.0, 3.6))])
	a.append_array(bowls)
	l.obstacles = a
	var b: Array[ArenaObstacle] = [trunk]
	for pts: Array in [[Vector2(-4.1, -5.7), Vector2(-2.4, -5.8), Vector2(-0.7, -5.7), Vector2(0.9, -5.4)],
			[Vector2(-6.6, -1.2), Vector2(-6.2, 0.7), Vector2(-6.1, 2.7), Vector2(-6.3, 4.7)],
			[Vector2(-11.5, -3.0), Vector2(-12.2, -2.5)]]:
		b.append_array(_root(TRUNK, TRUNK_RADIUS, pts))
	b.append_array([_sarcophagus(11.5, -6.0, 1.2, 2.5), _sarcophagus(6.5, 5.0, 2.5, 1.2), _column(12.0, 3.0, 3.4), _column(-12.5, 4.0, 3.0)])
	b.append_array(bowls)
	l.variants = [_variant(b)]
	l.hero_spawn = Vector2(-12.0, 9.0)
	l.hero_facing = Vector2(1, -1).normalized()
	l.exits = [ArenaExit.at_edge(Vector2(13, -14), Vector2(0, 1)), ArenaExit.at_edge(Vector2(17, 0), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(5, 14), Vector2(0, -1))]
	# (LR-04, the north group north of the trunk, x -12 to -5, was tried on 2026-11-20 and put back: tree_shade stayed 5
	# to 7%, the trunk stopped 0.1 shot a room)
	l.spawns = [_rect(6, 12, -12.5, -9.5), _rect(13, 16, -4, 3), _rect(-6, 0, -13.2, -10.5), _rect(-2, 6, 9, 12.5)]
	l.late_spawns = [_rect(-15, -13, -6, -3.5)]
	l.cam_bounds = _rect(-3, 4, -2, 3)
	# RP-01: the tree as a shield (12 m round the trunk), the open field east, the rest
	_areas(l, ["tree_shade", _rect(TRUNK.x - 6, TRUNK.x + 6, TRUNK.y - 6, TRUNK.y + 6), "east_field", _rect(2, 17, -14, 14),
		"rest", _rect(-17, 2, -14, 14)])
	return l


## The Seal Chamber (cycle C11). Every number is the spec's (docs/art/boss_chamber_spec.md, sections 2 and 4).
func _chamber() -> RoomLayout:
	var c := RoomLayout.new()
	c.chamber = true
	# named only for the run's log (QW-011); its look and its name stay the chamber's own
	c.id = &"seal_chamber"
	c.floor = FloorShape.circle(12.5)
	c.half = Vector2(12.5, 12.5)
	c.hero_spawn = Vector2(-0.9, 10.4)
	c.hero_facing = Vector2.UP
	c.boss_spawn = Vector2(0.0, -1.2)
	c.cam_target = Vector2(0.40, 0.57)
	c.cam_reach = 3.0
	return c


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
	# E2 (Daniel's test of E1: "Morvath is too easy"; docs/qa/e2_morvath.md): shorter rests, the last phase most
	b.rest = PackedFloat32Array([1.1, 1.0, 0.6, 0.4])
	b.windup_scale = PackedFloat32Array([1.0, 1.0, 0.95, 0.9])
	b.final_light_phase = 4
	b.adds_cap = PackedInt32Array([0, 4, 4, 4])
	# E2: what rises when a summon is laid over another attack, and the circles of eruptions laid over one
	b.layer_raise = [&"skeleton", &"mage"] as Array[StringName]
	b.layer_eruption_count = Vector2i(2, 2)
	# each phase opens on its own pattern, right after the roar: the ritual (by itself), the curse, the storm
	b.phase_openers = [&"", &"", &"curse", &"storm"] as Array[StringName]
	# the curse and the storm are opened from the middle of the floor, as the ritual is (cycle C11)
	b.center_phases = PackedInt32Array([3, 4])
	var numbers := {
		"roar_time": 1.6, "roar_push": 4.0, "near": 6.0, "far": 10.0, "still_after": 0.8, "lead": 0.45,
		"summon_raise": [&"skeleton", &"skeleton"] as Array[StringName], "summon_windup": 1.1,
		# reinforcements rise one by one (a rune, the energy, the body, 0.45 s apart), 20 at most in the whole fight
		"adds_total_cap": 20, "rise_stagger": 0.45,
		# where they rise (cycle C11, fitted to the chamber's 12.5 m: the ritual's ring of 6.5 around the seal leaves
		# 5.5 m of floor outside it to fight in; summons 5 m around him, never within 4 m of the paladin)
		"summon_ring": 5.0, "summon_clear": 4.0, "ritual_ring": 6.5,
		# the crescents come undone 0.3 m past the floor's edge; the charge stops at the edge and needs 8 m free
		"soul_overrun": 0.3, "dash_min_free": 8.0,
		# a combination waits for nothing of the first to be left, then rests only this long
		"chain_rest": 0.35,
		# the Sepulchral Scythe: half a circle 5 m from his middle (3.6 m past his body), 0.8 s to read it, 1 s to punish
		"scythe_reach": 5.0, "scythe_degrees": 180.0, "scythe_windup": 0.8, "scythe_recovery": 1.0, "scythe_damage": 12.0, "scythe_approach": 1.2,
		# C19-3, the Double Reap (Q-09 a; Hades II's Hecate: right 0.85 / 0.4 / 0.35, at once left 0.5 / 0.5 / 2.2): two
		# sweeps of 150 degrees and 4.5 m close in, the second born where the paladin is as the first ends, then 2.2 s
		"reap_reach": 4.5, "reap_degrees": 150.0, "reap_windup": 0.85, "reap_active": 0.4, "reap_pause": 0.35, "reap2_windup": 0.5,
		"reap2_active": 0.5, "reap_recovery": 2.2, "reap_damage": 10.0,
		# the Blades of the Souls: two crescents 3 m wide, 38 degrees apart, across the hall at 11 m/s
		"blade_spread": 38.0, "blade_speed": 11.0, "blade_width": 3.0, "blade_range": 26.0, "blade_windup": 0.7, "blade_recovery": 0.8, "blade_damage": 10.0,
		# C17, Q-09 (b): phase 1 was the scythe in a loop with him close (91% scythe over 3 seeds): the Blades come at
		# any distance, a step back first when he is within 4 m
		"blade_step": 2.0, "blade_step_within": 4.0, "blade_step_time": 0.25,
		# the Storm of the Six Souls: six crescents all around (never two closer than 48 degrees), a second wave turned 30
		"storm_count": 6, "storm_jitter": 7.0, "storm_min_gap": 48.0, "storm_waves": 3, "storm_turn": 30.0, "storm_gap": 1.0, "storm_windup": 0.9,
		"storm_recovery": 1.2, "storm_damage": 10.0, "storm_stagger": 0.08,
		# the Sepulchral Eruptions: 2 or 3 circles of 4 m (2 m until Daniel's test of 2026-11-16: too easy to step out of; the warning 0.9 to 1.2 s so they can still be walked out of), one on the paladin, the lane to the middle of the hall kept free
		"eruption_radius": 4.0, "eruption_delay": 1.2, "eruption_count": Vector2i(2, 3), "eruption_lane": 120.0, "eruption_sequences": 2,
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
		# E2: from the curse's phase, eruptions with its warning, their free lane away from his half circle
		_attack(&"scythe", {"weight": 3.0, "max_dist": 11.0, "near_bias": 2.2, "far_bias": 0.35, "streak": 2, "then": &"storm", "then_chance": 0.6, "then_from_phase": 4,
			"layers": [&"eruptions"] as Array[StringName], "layer_from_phase": 3, "layer_chance": 1.0, "layer_share": 0.0}),
		# C19-3: close in, the Double Reap shares the near choices with the scythe (phase 1 with him within 4 m: no
		# attack over half, never three alike)
		_attack(&"reap", {"weight": 3.5, "max_dist": 6.0, "near_bias": 2.2, "streak": 1}),
		# far: the blades (until the storm takes their place); E2: in the curse's phase his dead rise as they fly
		_attack(&"blades", {"weight": 2.0, "until_phase": 3, "cooldown": 3.0, "min_dist": 0.0, "near_bias": 1.0, "far_bias": 2.2,
			"layers": [&"summon"] as Array[StringName], "layer_from_phase": 3, "layer_chance": 1.0, "layer_share": 0.0}),
		# the paladin keeps away: the dash closes in
		_attack(&"dash", {"weight": 1.0, "cooldown": 6.0, "min_dist": 9.0, "far_bias": 1.5}),
		# the eruptions drive the paladin; in the last phase the scythe waits where he lands
		_attack(&"eruptions", {"from_phase": 2, "weight": 1.4, "cooldown": 5.0, "still_bias": 3.0, "then": &"scythe", "then_chance": 0.6, "then_from_phase": 4}),
		_attack(&"summon", {"from_phase": 2, "weight": 0.8, "cooldown": 9.0}),
		# E2: as the bolt leaves, eruptions whose free lane is off its way
		_attack(&"curse", {"from_phase": 3, "weight": 1.6, "cooldown": 6.0, "min_dist": 3.0,
			"layers": [&"eruptions", &"summon"] as Array[StringName], "layer_from_phase": 3, "layer_chance": 1.0, "layer_share": 1.0}),
		# after the storm, a paladin far away is charged (only when he is far: the dash needs 9 m); E2: the storm with
		# everything at once, eruptions (their free lane in the gap nearest the paladin) and his dead rising
		_attack(&"storm", {"from_phase": 4, "weight": 2.2, "cooldown": 4.0, "near_bias": 1.3, "far_bias": 1.3, "then": &"dash", "then_chance": 0.4, "then_from_phase": 4,
			"layers": [&"eruptions", &"summon"] as Array[StringName], "layer_from_phase": 4, "layer_chance": 1.0, "layer_share": 0.0}),
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
	# protected 19 frames from the press, as Hades II (3 of charge and 16 of the jump; ours leaves on the press frame)
	f.dodge_iframes = 18.0 / 60.0
	# (the dodge charges, 1, and their 0.74 s to come back are the hero's: _hero)
	f.sprint_scale = 890.0 / 540.0
	f.move_scale_light = 0.0
	f.move_scale_heavy = 0.0
	f.move_scale_finisher = 0.0
	# the frame of Daniel's reference image of the catacomb hall (2026-11-14): high and turned, the square room seen
	# as a diamond from its south-east corner (docs/art/arena_reference.md); cycle 5 brings it 10% closer (60 to 54,
	# Daniel's "discreet camera adjustments") so the figures read the size of the painting's; --showcase keeps 60
	f.cam_distance = 54.0
	# the near camera of the options (Daniel, 2026-11-19): Hades II's Erebus rooms are as big as ours in meters, but its
	# ZoomFraction about 0.85 shows about 28 m across (ours 41 at 54) and the room is bigger than the screen; 37 m shows
	# the same 28 m (CamRig.near, the save's "camera"; the default since LR-01; the far 54 stays in the options)
	f.cam_distance_near = 37.0
	f.cam_pitch = 30.0
	f.cam_yaw = 35.0
	f.cam_fov = 24.0
	f.cam_lead = 1.2
	f.cam_smooth = 9.0
	f.hit_stop_scale = 1.0
	f.glint_scale = 1.0
	f.shake_scale = 1.0
	f.kick_scale = 1.0
	# the black and white impact frame only on an Omega that lands and on the blow that ends a boss's phase, at most
	# one every 10 s (decision D-08 of cycle 10: it hid the boss's warnings 24 times in a 2 minute fight)
	f.impact_frame = 0.05
	f.impact_frame_every = 10.0
	# a blow taken (BUG-007, cycle 10): a short red at the edges only, half of it under 10 damage, a small colour
	# split only on the heavy ones; under the curse a violet edge (alpha 0.2 for 0.2 s) and no split
	f.hurt_tint = 0.42
	f.hurt_tint_time = 0.22
	f.hurt_tint_heavy = 10.0
	f.hurt_tint_small = 0.5
	f.hurt_split = 0.35
	f.curse_tint = 0.2
	f.curse_tint_time = 0.2
	f.outline = 0.5
	# effects a little quieter after the first test ("everything is too big"): dimmer cut, ink gone sooner
	f.slash_intensity = 1.7
	f.slash_sweep_time = 0.05  # C12d (VX-01): the head sweeps in 3 frames with the blade (Fx.SLASH_LEAD the first)
	f.ink_opacity = 0.85
	f.ink_life = 2.0
	_save(f, Feel.PATH)


# ---------- the hero ----------

const HERO_DIR := "res://data/heroes/"
const TALENT_DIR := "res://data/talents/warrior/"
const ULT_DIR := "res://data/ultimates/"
const MASTERY_PATH := "res://data/heroes/warrior_mastery.tres"


## The Warrior's Mastery (guardian_spec.md 7; warrior_spec.md 4.4): 20 levels, 40 + 10 (n - 1) XP from n to n + 1
## (2470 in all), Devotion 5 + level; XP by source and first times; older saves get 40 a run and 60 a win once, up to
## level 5 (D-57).
func _mastery() -> void:
	var m := MasteryCurve.new()
	var numbers := {
		"max_level": 20, "xp_base": 40, "xp_step": 10, "devotion_base": 5,
		"room_xp": 10, "guardian_xp": 25, "phase_xp": 10, "phase_max": 4, "victory_xp": 50,
		"first_boon_xp": 2, "first_elo_xp": 10, "first_psalm_xp": 25, "first_guardian_xp": 25, "first_victory_xp": 100,
		"retro_run_xp": 40, "retro_win_xp": 60, "retro_max_level": 5,
	}
	for k: String in numbers:
		m.set(k, numbers[k])
	DirAccess.make_dir_recursive_absolute(HERO_DIR)
	_save(m, MASTERY_PATH)


## The ultimate's charge besides Magia (T5): per point of damage dealt and of life lost.
const ULT_DAMAGE_CHARGE := 0.02
const ULT_HURT_CHARGE := 1.0


func _ult(n: int, id: StringName, kind: UltDef.Kind, props: Dictionary) -> void:
	var u := UltDef.new()
	u.id = id
	u.kind = kind
	u.name_key = StringName("ult_" + id)
	u.desc_key = StringName("ult_%s_desc" % id)
	for k: String in props:
		u.set(k, props[k])
	_save(u, ULT_DIR + "%02d_%s.tres" % [n, id])


## The two ultimates (D-54; warrior_spec.md 3.2; played by Ultimates, E2-08 and E2-10). U-1: a band 12 x 4 m ahead,
## 300 on the middle strip and 200 on the rest, charged by 60 of Magia spent (Sky Fall), Mastery 2. U-2, the Voragem
## (ultimate_u2_proposals.md, proposal A): 6 m thrown 4 m ahead for 4 s, ticks of 8 every 0.25 s and an implosion of
## 120 within 3 m, charged by 70 (Moon Water), Mastery 6. Names are pending (D-55, D-68: none with Elun). The gesture's
## clip lands its blade as the 0.3 s gesture ends: the overhead cut (Slash_C, peak 0.67 s, PEAK) for the cleave, the
## sword driven down (Sword_Attack, 0.40 s) for the Voragem.
func _ultimates() -> void:
	DirAccess.make_dir_recursive_absolute(ULT_DIR)
	for f in DirAccess.get_files_at(ULT_DIR):
		DirAccess.remove_absolute(ULT_DIR + f)
	# T5 (docs/design/t5_ultimate.md): it also fills with the damage dealt (ULT_DAMAGE_CHARGE a point, 3000 for the
	# cleave) and the life lost (ULT_HURT_CHARGE a point): a player who never holds an Omega still gets it
	_ult(0, &"cleave", UltDef.Kind.CLEAVE, {"charge": 60.0, "damage_charge": ULT_DAMAGE_CHARGE, "hurt_charge": ULT_HURT_CHARGE, "mastery_level": 2, "gesture": 0.3,
		"tags": [&"ultimate", &"light"] as Array[StringName], "anim": &"Slash_C", "anim_peak": PEAK[&"Slash_C"], "knockback": 6.0,
		"length": 12.0, "width": 4.0, "core_width": 1.5, "core_damage": 300.0, "damage": 200.0, "stun": 1.0, "armor_mult": 2.0})
	_ult(1, &"vortex", UltDef.Kind.VORTEX, {"charge": 70.0, "damage_charge": ULT_DAMAGE_CHARGE, "hurt_charge": ULT_HURT_CHARGE, "mastery_level": 6, "gesture": 0.3,
		"tags": [&"ultimate", &"cast"] as Array[StringName], "anim": &"Sword_Attack", "anim_peak": PEAK[&"Sword_Attack"], "knockback": 2.0,
		"ahead": 4.0, "aim_max": 8.0, "radius": 6.0, "radius_cap": 7.5, "duration": 4.0, "tick": 0.25, "tick_damage": 8.0,
		"implode_damage": 120.0, "implode_radius": 3.0, "implode_stun": 0.8, "pull": 3.5, "swirl": 2.0, "core": 1.2,
		"elite_pull": 0.5, "guardian_pull": 0.25, "stun": 0.0, "armor_mult": 2.0})


func _talent(n: int, id: StringName, branch: TalentDef.Branch, tier: TalentDef.Tier, cost: int, unlock: int, props: Dictionary = {}) -> void:
	var t := TalentDef.new()
	t.id = id
	t.name_key = StringName("talent_" + id)
	t.desc_key = StringName("talent_%s_desc" % id)
	t.branch = branch
	t.tier = tier
	t.cost = cost
	t.unlock_level = unlock
	# Rejogabilidade, Fatia 1 (sistemas.md 1.4): opening costs its Devotion in Memória, the first Gift (Mastery 1) comes
	# open so the first descent is no poorer than before
	t.memory_cost = 0 if unlock <= 1 else cost
	for k: String in props:
		t.set(k, props[k])
	_save(t, TALENT_DIR + "%02d_%s.tres" % [n, id])


## The Warrior's tree of Gifts (warrior_spec.md 4): four branches (Combo, Furia, Emeth, Magia), each an entry, a middle
## and an apex; four bridges; three sustain Gifts. Costs of the six first Gifts from 4.2, the rest proposals; unlock
## levels in the order of 4.4 (transforming Gifts first; levels 2 and 6 are the ultimates; 20 unlocks two apexes).
## Every number is a stat of its mods (BoonState.stat, read by GiftState and Combat; a tag limits it to the moves that
## carry it); Quarto Corte is a combo tree (TalentDef.combos). Choices of E2-07/E2-09: warrior_spec.md 4.5.
func _talents() -> void:
	DirAccess.make_dir_recursive_absolute(TALENT_DIR)
	for f in DirAccess.get_files_at(TALENT_DIR):
		DirAccess.remove_absolute(TALENT_DIR + f)
	var B := TalentDef.Branch
	var T := TalentDef.Tier
	var S := Boon.Slot
	# Combo: a 4th blow (a thrust of 30 before the spin, FOURTH); the Corte Veloz counts as the 1st blow (the next press
	# is cut2); the spin that lands on 3 or more starts the combo over at cut2
	_talent(0, &"quarto_corte", B.COMBO, T.ENTRY, 3, 1, {"slot": S.ATTACK, "combos": FOURTH_TREE})
	_talent(1, &"passo_encadeado", B.COMBO, T.MIDDLE, 2, 7, {"slot": S.DASH, "mods": [_fixed(&"dash_chain", 1, [], &"dash")] as Array[BoonMod]})
	_talent(2, &"golpe_sem_fim", B.COMBO, T.APEX, 4, 15, {"partner": B.FURIA, "mods": [_fixed(&"spin_loop_hits", 3, [], &"spin")] as Array[BoonMod]})
	# Furia (charges that fade in 3 s, no new bar: D-70): a charge a kill, up to 3, all gone 3 s after the last kill, 6%
	# more speed of every blow a charge; a kill by a finisher gives the dodge's charge back; with 3 charges a finisher
	# stuns 0.5 s longer, those with armor too
	_talent(3, &"impeto", B.FURIA, T.ENTRY, 2, 3, {"mods": [_fixed(&"fury_per_kill", 1), _fixed(&"fury_max", 3),
		_fixed(&"fury_time", 3.0), _fixed(&"fury_speed", 0.06)] as Array[BoonMod]})
	_talent(4, &"avanco_feroz", B.FURIA, T.MIDDLE, 3, 8, {"mods": [_fixed(&"dash_back_on_kill", 1, [], &"finisher")] as Array[BoonMod]})
	_talent(5, &"furia_plena", B.FURIA, T.APEX, 4, 18, {"partner": B.COMBO, "mods": [_fixed(&"fury_stun", 0.5, [], &"finisher")] as Array[BoonMod]})
	# Emeth: the spin throws an emerald wave 6 m ahead for 16 (3 m across); the special's wave goes through stone
	_talent(6, &"corte_crescente", B.EMETH, T.ENTRY, 3, 4, {"mods": _wave(&"spin", 16.0, 6.0, 3.0)})
	_talent(7, &"fio_longo", B.EMETH, T.MIDDLE, 1, 9, {"mods": [_fixed(&"reach_pct", 0.15, [], &"light")] as Array[BoonMod]})
	_talent(8, &"onda_atravessante", B.EMETH, T.APEX, 4, 20, {"partner": B.MAGIA, "mods": [_fixed(&"wave_through", 1, [], &"wave")] as Array[BoonMod]})
	# Magia: an Omega begun within 1 s of a finisher that landed costs half (the glint stays on the tip that long); the
	# ultimate charges 25% faster (ult_charge_pct, read by the ultimate) and the passive gives 1 more
	_talent(9, &"lamina_faminta", B.MAGIA, T.ENTRY, 2, 5, {"mods": [_fixed(&"hungry_time", 1.0, [], &"finisher"), _fixed(&"omega_discount", 0.5)] as Array[BoonMod]})
	_talent(10, &"reserva", B.MAGIA, T.MIDDLE, 3, 10, {"mods": [_fixed(&"magick_max", 20)] as Array[BoonMod]})
	_talent(11, &"coracao_da_emeth", B.MAGIA, T.APEX, 4, 20, {"partner": B.EMETH, "mods": [_fixed(&"ult_charge_pct", 0.25), _fixed(&"finisher_magick", 1)] as Array[BoonMod]})
	# bridges between neighbouring branches: the Corte Veloz that kills gives the dodge back; a kill by an Omega gives 2
	# charges; the special's Omega throws the spin's wave; the Corte Veloz throws a short wave (the special's look, 12,
	# 9.6 m: just past the cut's 8 m)
	_talent(12, &"investida", B.BRIDGE, T.BRIDGE, 3, 11, {"joins": [B.COMBO, B.FURIA] as Array[TalentDef.Branch], "mods": [_fixed(&"dash_back_on_kill", 1, [], &"dash")] as Array[BoonMod]})
	_talent(13, &"sangue_quente", B.BRIDGE, T.BRIDGE, 3, 12, {"joins": [B.FURIA, B.MAGIA] as Array[TalentDef.Branch], "mods": [_fixed(&"fury_per_kill", 1, [], &"omega")] as Array[BoonMod]})
	_talent(14, &"onda_carregada", B.BRIDGE, T.BRIDGE, 3, 13, {"joins": [B.MAGIA, B.EMETH] as Array[TalentDef.Branch], "slot": S.SPECIAL, "mods": _wave(&"charge", 16.0, 6.0, 3.0)})
	_talent(15, &"fio_do_passo", B.BRIDGE, T.BRIDGE, 3, 14, {"joins": [B.EMETH, B.COMBO] as Array[TalentDef.Branch], "slot": S.DASH, "mods": _wave(&"dash", 12.0, 9.6, 1.6)})
	# sustain, off the branches: a room won heals 2; once a descent he gets up with half his life, but never in Morvath's
	# room (E6: no rise_boss_share; with the rise there the Mastery 20 robot won 72 of 72, docs/design/e6_balance.md)
	_talent(16, &"firmeza", B.SUSTAIN, T.SUSTAIN, 2, 16, {"mods": [_fixed(&"max_hp", 10), _fixed(&"magick_max", 10)] as Array[BoonMod]})
	_talent(17, &"respiro", B.SUSTAIN, T.SUSTAIN, 3, 17, {"mods": [_fixed(&"room_heal", 2)] as Array[BoonMod]})
	_talent(18, &"ainda_de_pe", B.SUSTAIN, T.SUSTAIN, 5, 19, {"mods": [_fixed(&"rise_share", 0.5)] as Array[BoonMod]})


## A wave a blow throws (Combat._gift_wave) on the moves with this tag: damage, meters it runs, meters across.
func _wave(tag: StringName, damage: float, reach: float, width: float) -> Array[BoonMod]:
	return [_fixed(&"blow_wave", damage, [], tag), _fixed(&"blow_wave_m", reach, [], tag), _fixed(&"blow_wave_w", width, [], tag)]


## The Warrior (DT-013; warrior_spec.md): the numbers the paladin had in constants (Player, Combat, Feel), unchanged:
## life 30 and 1.3 s safe after a blow (Hades II), 1 dodge charge back in 0.74 s, 50 of Magia, the circle of light
## (5.4 m, 3 s, Omega 20 of Magia held 0.6 s, bursts for 150). The passive gives 2 of Magia a finisher (D-56).
func _hero() -> void:
	var h := HeroDef.new()
	h.id = &"warrior"
	h.name_key = &"hero_warrior"
	h.model = &"hero_explorer"
	h.combos = "res://data/combos/paladin.tres"
	var numbers := {
		"max_hp": 30.0, "hurt_time": 0.18, "hurt_invuln": 1.3, "dodge_charges": 1, "dodge_recharge": 0.74,
		"magick_max": 50.0,
		"cast_charge": 0.25, "cast_slow": 0.6, "cast_cooldown": 0.2, "cast_attack_lock": 8.0 / 60.0, "cast_omega_time": 0.6,
		"cast_omega_cost": 20.0, "cast_radius": 5.4, "cast_time": 3.0, "cast_burst": 150.0,
		"magick_on_finisher": 2.0,
		# C19-4 (Q-12): Hades II's Swing5 charge walks at 3% with the body all but locked; the special's 60% is an
		# inference (WeaponStaffBoltInstantStop; its Omega stage has no speed of its own)
		"charge_move_light": 0.03, "charge_turn_light": 0.0, "charge_move_heavy": 0.6,
	}
	for k: String in numbers:
		h.set(k, numbers[k])
	# the passive's finishers (warrior_spec.md 3.1): the spin, the Corte Veloz that lands, the Omegas; never the ultimate
	h.passive_tags = [&"finisher", &"dash", &"omega"] as Array[StringName]
	h.passive_never = [&"ultimate"] as Array[StringName]
	var ults: Array[UltDef] = []
	var files := DirAccess.get_files_at(ULT_DIR)
	files.sort()
	for f in files:
		ults.append(ResourceLoader.load(ULT_DIR + f, "", ResourceLoader.CACHE_MODE_REPLACE))
	h.ultimates = ults
	h.talents_dir = TALENT_DIR
	h.mastery = ResourceLoader.load(MASTERY_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	DirAccess.make_dir_recursive_absolute(HERO_DIR)
	_save(h, HeroDef.WARRIOR)


# ---------- Psalms (E4) ----------

const PSALM_DIR := "res://data/psalms/"


func _psalm(n: int, id: StringName, theme: StringName, slot: Boon.Slot, effect: PsalmDef.Effect, requires: Array, props: Dictionary) -> void:
	var p := PsalmDef.new()
	p.id = id
	p.theme = theme
	p.name_key = StringName("psalm_" + id)
	p.desc_key = StringName("psalm_%s_desc" % id)
	p.hint_key = StringName("psalm_%s_hint" % id)
	p.line_key = StringName("psalm_%s_line" % id)
	p.slot = slot
	p.effect = effect
	for group: Array in requires:
		p.requires.append(PackedStringArray(group))
	for k: String in props:
		p.set(k, props[k])
	_save(p, PSALM_DIR + "%02d_%s.tres" % [n, id])


## The four Psalms of E4 (D-59 (a): named by theme, no number, no verse; D-60: Sentinela, Abrigo, Pastor and Rocha;
## docs/design/e4_psalms.md). Each transforms one action with a system the game has; three groups each (a Blessing or
## an Elo of a list, or an equipped Gift: PsalmDef.GIFT before its id), one held thing a group, never the same for two.
## The lists are wide on purpose so the robot (no Gifts) can meet them too; numbers are starting points for E6.
func _psalms() -> void:
	DirAccess.make_dir_recursive_absolute(PSALM_DIR)
	for f in DirAccess.get_files_at(PSALM_DIR):
		DirAccess.remove_absolute(PSALM_DIR + f)
	var S := Boon.Slot
	var E := PsalmDef.Effect
	var G := PsalmDef.GIFT
	# watching: the circle of light walks with him and strikes each one that comes in (30, the Corte Veloz's damage)
	_psalm(0, &"sentinela", &"watch", S.CAST, E.SENTINEL, [
		["circulo_brasa", "circulo_geada", "circulo_radiante", "circulo_firme"],
		["escudo", "passos", "firmeza", "golpe_firme", "pesado_firme"],
		["bastiao", "rastro", "passo_frio", G + "reserva", G + "lamina_faminta", G + "coracao_da_emeth"]],
		{"damage": 30.0})
	# sheltering: the dodge leaves a shelter of 2.6 m for 3 s where it ends (two at most) that undoes enemy shots
	_psalm(1, &"abrigo", &"shelter", S.DASH, E.SHELTER, [
		["passos", "passo_brasa", "passo_geada", "passo_radiante"],
		["escudo", "firmeza", "consolo", "circulo_firme"],
		["rastro", "passo_frio", "bastiao", G + "passo_encadeado", G + "fio_do_passo", G + "investida"]],
		{"radius": 2.6, "duration": 3.0, "count": 2})
	# guiding: each kill gathers a light (three at most); the special throws one more wave for each, 14 degrees apart
	_psalm(2, &"pastor", &"shepherd", S.SPECIAL, E.FLOCK, [
		["toque_geada", "pesado_brasa", "pesado_radiante", "pesado_firme"],
		["consolo", "onda_maior", "flagelo", "golpe_radiante", "circulo_radiante", "passo_radiante"],
		["aurora", "chama_viva", G + "corte_crescente", G + "onda_carregada", G + "onda_atravessante"]],
		{"count": 3, "spread": 14.0})
	# firmness: the spin plants a stone of light: 30 within 4 m, the common ones stunned 1 s, then 3 s slowing there
	_psalm(3, &"rocha", &"rock", S.ATTACK, E.STONE, [
		["golpe_brasa", "golpe_geada", "golpe_radiante", "golpe_firme"],
		["firmeza", "escudo", "pesado_firme", "estilhaco", "peso_inverno"],
		["vapor", "bastiao", G + "quarto_corte", G + "golpe_sem_fim", G + "furia_plena", G + "fio_longo"]],
		{"damage": 30.0, "radius": 4.0, "stun": 1.0, "duration": 3.0})


# ---------- E5: the Provação ----------

const TRIAL_DIR := "res://data/trials/"


func _trial(n: int, id: StringName, kind: TrialDef.Kind, mods: Array[BoonMod], encounters := Vector2i(3, 5)) -> void:
	var t := TrialDef.new()
	t.id = id
	t.kind = kind
	t.name_key = id
	t.desc_key = StringName("%s_desc" % id)
	t.mods = mods
	t.encounters = encounters
	_save(t, TRIAL_DIR + "%02d_%s.tres" % [n, id])


## The Provação's cards (E5; Hades II's Chaos, docs/design/hades2_sistemas.md section 7, without a god: E5-D6). A
## blessing is a strong number the game already reads, scaled by its rarity like a Blessing (Hades II's Chaos: attack
## +20% to +50% at common, life +26 to +35); a curse is carried for 3 to 5 fights (Hades II's RemainingUses 3 to 5)
## and never scales. Our numbers, starting points for E6.
func _trials() -> void:
	DirAccess.make_dir_recursive_absolute(TRIAL_DIR)
	for f in DirAccess.get_files_at(TRIAL_DIR):
		DirAccess.remove_absolute(TRIAL_DIR + f)
	var B := TrialDef.Kind.BLESSING
	var C := TrialDef.Kind.CURSE
	_trial(0, &"trial_golpe", B, [_mod(&"damage_pct", 0.3, [], &"light")])
	_trial(1, &"trial_pesado", B, [_mod(&"damage_pct", 0.4, [], &"heavy")])
	_trial(2, &"trial_circulo", B, [_mod(&"damage_pct", 0.5, [], &"cast")])
	_trial(3, &"trial_vigor", B, [_mod(&"max_hp", 15.0)])
	_trial(4, &"trial_reserva", B, [_mod(&"magick_max", 20.0)])
	# the curses: the dead walk faster, healing is halved, one more enemy a wave, blows hurt more, no gold falls
	_trial(10, &"trial_pressa", C, [_fixed(&"enemy_speed_pct", 0.25)])
	_trial(11, &"trial_ferida", C, [_fixed(&"heal_pct", -0.5)])
	_trial(12, &"trial_horda", C, [_fixed(&"wave_extra", 1.0)])
	_trial(13, &"trial_fragil", C, [_fixed(&"hurt_pct", 0.25)])
	_trial(14, &"trial_pobreza", C, [_fixed(&"gold_pct", -1.0)])


# ---------- E5: three arenas and the two rooms of the events (docs/art/e5_spec.md) ----------

## A piece of the spec's tables standing along x (or z), w x d, of its height (a bench, an altar, a pillar).
func _piece(x: float, z: float, w: float, d: float, top: float, piece: StringName, see := false) -> ArenaObstacle:
	return _sarcophagus(x, z, w, d, top, piece, see)


## Named parts of the floor (RoomLayout.areas, ArenaVariant.areas): pairs of a name and a rectangle.
func _areas(l: Resource, pairs: Array) -> void:
	var rects: Array[Rect2] = []
	var names := PackedStringArray()
	for i in range(0, pairs.size(), 2):
		names.append(pairs[i])
		rects.append(pairs[i + 1])
	l.set(&"areas", rects)
	l.set(&"area_names", names)


## Santuário Desmoronado (spec section 1, C14-A4): the guardian's house. A nave of a church under the earth, two rows of
## columns that stop shots, the nave 10.7 m free between them (the knight's charge), the side aisles 7.35 m; the
## guardian rises before the presbytery's grille (west). Variant B: the floor of the nave fell in (a hole of 8.4 x 7 m),
## the four columns over it with it.
func _sanctuary() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"sanctuary", RoomLayout.Size.LARGE, 2, Vector2(0.4, 1.0))
	var outline := _poly([-22, -14, 14, -14, 22, -6, 22, 14, -18, 14, -22, 10])
	l.floor = FloorShape.poly([outline])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	l.max_ranged = 3
	l.guardian = true
	l.guardian_home = true
	# fire bowls of the north door's recesses, 0.9 m out of the floor (drawn, never blocking; the bowl and its fire are
	# 0.7 m round); the grille's two are the look's own, on its end pillars (SanctuaryLook), never in the data
	var bowls: Array[ArenaObstacle] = [_bowl(4.3, -14.9), _bowl(8.7, -14.9)]
	var walls: Array[ArenaObstacle] = [_sarcophagus(-12.0, -13.4, 2.5, 1.2), _sarcophagus(-4.0, -13.4, 2.5, 1.2),
		_piece(-12.0, 10.2, 2.0, 0.6, 0.9, &"bench_broken"), _piece(6.0, 10.2, 2.0, 0.6, 0.9, &"bench_broken")]
	var a: Array[ArenaObstacle] = []
	for x: float in [-15.0, -9.0, -3.0, 9.0]:
		a.append(_column(x, -6.0, 5.2, 0.65))
	for x: float in [-15.0, -3.0, 3.0, 9.0, 15.0]:
		a.append(_column(x, 6.0, 5.2, 0.65))
	a.append_array([_cracked(_column(15.0, -6.0, 3.4, 0.65)), _cracked(_column(-9.0, 6.0, 3.0, 0.65)),
		ArenaObstacle.circle(Vector2(3.0, -6.0), 0.65, &"column_base", 0.6, false),
		_capsule(Vector2(3.0, -6.9), Vector2(3.0, -9.8), 1.1, 1.0, &"drums")])
	a.append_array(walls)
	a.append_array(bowls)
	l.obstacles = a
	# B, "Nave partida": the nave's floor fell (a hole), the columns of x 3 and 9 with it; the north (-9) one broken
	var b: Array[ArenaObstacle] = [_column(-15.0, -6.0, 5.2, 0.65), _column(-9.0, -6.0, 3.2, 0.65),
		_column(-3.0, -6.0, 5.2, 0.65), _cracked(_column(15.0, -6.0, 3.4, 0.65)), _column(-15.0, 6.0, 5.2, 0.65),
		_cracked(_column(-9.0, 6.0, 3.0, 0.65)), _column(-3.0, 6.0, 5.2, 0.65), _column(15.0, 6.0, 5.2, 0.65)]
	b.append_array(walls)
	b.append_array(bowls)
	var fallen := FloorShape.poly([outline], [_poly([1, -3.2, 4.5, -3.5, 9, -3.1, 9.4, 0, 9, 3.1, 4.5, 3.5, 1, 3.2, 0.6, 0])])
	l.variants = [_variant(b, fallen)]
	l.hero_spawn = Vector2(19.5, 2.0)
	l.hero_facing = Vector2(-1, 0)
	l.boss_spawn = Vector2(-17.0, 0.0)
	l.exits = [ArenaExit.at_edge(Vector2(6.5, -14), Vector2(0, 1)), ArenaExit.at_edge(Vector2(-6, 14), Vector2(0, -1)),
		ArenaExit.at_edge(Vector2(-22, -10.5), Vector2(1, 0))]
	# LR-03: the first wave rises also in the south aisle's east and the middle of the north one, so the fight opens in
	# both aisles and the east third is no corridor (it was the hero's 5 s walk to a fight all in the west)
	l.spawns = [_rect(-20, -14, -3, 3), _rect(-19, -15, 8, 11), _rect(-8, -2, -12, -8.5), _rect(4, 12, 8, 12),
		_rect(-2, 6, -12, -8.5)]
	l.late_spawns = [_rect(10, 16, 8, 12)]
	l.cam_bounds = _rect(-10, 10, -2, 2)
	# the question of the room (spec 0.2): the open nave or the aisles behind the columns
	_areas(l, ["nave", _rect(-22, 22, -5.35, 5.35), "aisles", _rect(-22, 22, -14, -5.35), "aisles", _rect(-22, 22, 5.35, 14)])
	# RP-06: the aisles get a price (the nave has the knight's charge, the aisles the slabs): two in each, between the
	# columns, off the spawns and the doors; B the same (its hole is in the nave)
	var aisle_slabs: Array[Rect2] = [_rect(-13.5, -10.5, -11.0, -8.0), _rect(10.5, 13.5, -11.0, -8.0),
		_rect(-7.5, -4.5, 8.0, 11.0), _rect(0.0, 3.0, 8.0, 11.0)]
	l.hazard = _plates(aisle_slabs, PLATES_FROM)
	# RP-13 (B): the edge that crumbles, the slabs at the two ends of the hole (the nave is 1.85 m wide along its long
	# sides, no room for a slab there): 5 to him (not 7) and everyone on them thrown 2.5 m away from the hole, to the
	# firm floor (nobody falls, D-28); the same hazard as the aisles' (one hazard that hurts per room)
	var edge_slabs := aisle_slabs.duplicate()
	edge_slabs.append_array([_rect(-2.6, 0.4, -1.5, 1.5), _rect(9.6, 12.6, -1.5, 1.5)])
	var crumble := _plates(edge_slabs, PLATES_FROM)
	crumble.plate_hero_damage = PackedFloat32Array([0, 0, 0, 0, 5, 5])
	crumble.plate_push = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2(-2.5, 0),
		Vector2(2.5, 0)])
	l.variants[0].hazard = crumble
	_areas(l.variants[0], ["hole_edge", _rect(-2.6, 0.4, -1.5, 1.5), "hole_edge", _rect(9.6, 12.6, -1.5, 1.5),
		"nave", _rect(-22, 22, -5.35, 5.35), "aisles", _rect(-22, 22, -14, -5.35), "aisles", _rect(-22, 22, 5.35, 14)])
	return l


## Ponte dos Condenados (spec section 2, C14-A5): three platforms over the abyss joined by bridges of 5 m (A), or two
## and a long bridge of 24 m with a landing in its middle (B); every door on the far platform (E5-D5), nobody rises on
## a bridge, the shooters on the far side. The ruin in the middle stands east of it: the cover against them.
func _bridge() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"bridge", RoomLayout.Size.LONG, 2, Vector2(0.5, 1.0))
	var west := _poly([-28, -6, -25, -9, -15, -9, -14, -7, -14, 7, -16, 9, -26, 9, -28, 7])
	var middle := _poly([-7, -6, -5, -8, 5, -8, 7, -6, 7, 6, 5, 8, -5, 8, -7, 6])
	var east := _poly([14, -7, 15, -9, 25, -9, 28, -6, 28, 7, 26, 9, 16, 9, 14, 7])
	# the bridges reach 0.05 m into the platforms, so the union never opens a crack at a seam
	l.floor = FloorShape.poly([west, FloorShape.box(_rect(-14.05, -6.95, -2.5, 2.5)), middle,
		FloorShape.box(_rect(6.95, 14.05, -2.5, 2.5)), east])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	l.max_ranged = 3
	l.banned_roles = [&"area"]
	l.guardian = false
	var ends: Array[ArenaObstacle] = [_column(-21.0, -4.0, 3.0), _sarcophagus(21.0, -4.8, 2.5, 1.2), _column(20.0, 4.5, 3.6)]
	var a: Array[ArenaObstacle] = ends.duplicate()
	a.append_array([_piece(0.0, -7.2, 2.8, 1.6, 6.0, &"pylon", true), _piece(2.5, 2.5, 1.0, 3.2, 2.2, &"block", true),
		_column(-2.5, 3.5, 3.4)])
	# RP-04: a block of ruin before the east end of bridge 2, 1.5 m off the deck: the one who crosses lands in cover
	a.append(_piece(16.0, 0.0, 1.0, 2.4, 2.2, &"block", true))
	l.obstacles = a
	var west_b := _poly([-28, -6, -25, -9, -13, -9, -12, -7, -12, 7, -14, 9, -26, 9, -28, 7])
	var east_b := _poly([12, -7, 13, -9, 25, -9, 28, -6, 28, 7, 26, 9, 14, 9, 12, 7])
	var long_bridge := FloorShape.poly([west_b, FloorShape.box(_rect(-12.05, 12.05, -2.5, 2.5)),
		FloorShape.box(_rect(-3, 3, -4.5, 4.5)), east_b])
	var b := _variant(ends.duplicate(), long_bridge)
	b.spawns = [_rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	_areas(b, ["west", _rect(-28, -12, -9, 9), "landing", _rect(-3, 3, -4.5, 4.5), "bridge", _rect(-12, 12, -3, 3),
		"east", _rect(12, 28, -9, 9)])
	# RP-11: the chain across the long bridge, one half then the other, never within 4 m of the landing (the shelter)
	b.hazard = _chain([_rect(-11, -9, -2.5, 2.5), _rect(9, 11, -2.5, 2.5)], [Vector2(-CHAIN_PUSH, 0), Vector2(CHAIN_PUSH, 0)])
	l.variants = [b]
	# RP-11: on A one bridge at a time, in turn
	l.hazard = _chain([_rect(-11.5, -9.5, -2.5, 2.5), _rect(9.5, 11.5, -2.5, 2.5)],
		[Vector2(-CHAIN_PUSH, 0), Vector2(CHAIN_PUSH, 0)])
	# RP-07: A in the middle of the descent, B (the long bridge) late
	l.variant_depth = Vector2(0.5, 0.8)
	l.variants[0].depth = Vector2(0.67, 1.0)
	l.hero_spawn = Vector2(-24.5, 0.0)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(21, -9), Vector2(0, 1)), ArenaExit.at_edge(Vector2(28, 0.5), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(21, 9), Vector2(0, -1))]
	# RP-04: everybody rises on the east platform (the middle no more): the room asks to cross under fire
	l.spawns = [_rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	# the second wave closes behind the one who crossed
	l.late_spawns = [_rect(-26, -20, -7, -4)]
	l.cam_bounds = _rect(-14, 14, -1, 1)
	# the question of the room: hold the island or cross
	_areas(l, ["west", _rect(-28, -14, -9, 9), "bridge1", _rect(-14, -7, -3, 3), "middle", _rect(-7, 7, -8, 8),
		"bridge2", _rect(7, 14, -3, 3), "east", _rect(14, 28, -9, 9)])
	return l


## RP-11 (H-3): the chain that sweeps a bridge. A band of 2 m across the deck warms up 1.2 s (as the runes), strikes
## 0.25 s with the numbers of RP-03 (7 to the paladin, 60 to an enemy) and pushes everyone in it 2.5 m along the bridge
## toward the platform it leads to (never off it); one band every 6 s, in turn, after 3 s of calm.
const CHAIN_PUSH := 2.5


func _chain(bands: Array[Rect2], pushes: Array[Vector2]) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.LINE
	h.bands = bands
	h.band_push = PackedVector2Array(pushes)
	h.warn = 1.2
	h.fire = 0.25
	h.cycle = 6.0
	h.start_delay = 3.0
	h.hero_damage = 7.0
	h.enemy_damage = 60.0
	return h


## RP-08 (H-4): the rift that breathes, the flood trap of the Hades II (0 damage, it pushes): every 7 s a stretch of
## the brink (6 x 2 to 3 m) warms up 1.2 s (the mist rising) and pushes everyone in it 2.5 m away from the brink, cutting
## a wind-up or an attack there; after 3 s of calm.
const BREATH_PUSH := 2.5
## The stretches of the Salão das Fendas where the bot's fights go (measured: the south bridge, the south way and the
## east): the east brink of the middle hole, east of the south hole (by the south bridge) and the south way.
const RIFT_BREATH: Array[Rect2] = [Rect2(2.9, -7, 2.3, 6), Rect2(2.9, 4.2, 2.0, 4.8), Rect2(-8, 10.2, 10, 2)]
const RIFT_BREATH_PUSH: Array[Vector2] = [Vector2(BREATH_PUSH, 0), Vector2(BREATH_PUSH, 0), Vector2(0, BREATH_PUSH)]


func _breath(bands: Array, pushes: Array) -> HazardDef:
	var h := _chain(Array(bands, TYPE_RECT2, &"", null), Array(pushes, TYPE_VECTOR2, &"", null))
	h.band_source = &"breath"
	h.band_busy = true
	h.fire = 0.3
	h.cycle = 7.0
	h.hero_damage = 0.0
	h.enemy_damage = 0.0
	return h


## RP-02: the tiles any part of which lies within 6 m of the way in (hero_spawn (-12.5, 3.5)) never light: columns 0
## and 1 from row 3 to 7, column 2 from row 3 to 6 (the rule of every hazard: never near the door he came in by).
const RUNES_ENTRY: Array[Rect2] = [Rect2(-15, -3, 6, 15), Rect2(-9, -3, 3, 12)]


## The runes' floor (spec 3.4): tiles of 3 m, 1.2 s warming up, 0.25 s striking, 2.4 s of rest, never in the first
## 3 s; at most 35% of the tiles lit (50% for the dense patterns, with 3 enemies or fewer). It hurts everyone: 7 to the
## paladin (RP-03 step 1, was 4; the Hades hurts 10 on the same 30 of life), 60 to an enemy (a
## whole soldier; was 35): drawing them onto the band that will light is the room's play.
func _hazard(patterns: Array[StringName], quiet: Array[Rect2] = []) -> HazardDef:
	var h := HazardDef.new()
	h.origin = Vector2(-15, -12)
	h.tile = 3.0
	h.cols = 10
	h.rows = 8
	h.warn = 1.2
	h.fire = 0.25
	h.rest = 2.4
	h.start_delay = 3.0
	h.max_share = 0.35
	h.dense_share = 0.5
	h.dense_standing = 3
	h.patterns = patterns
	h.islands = 4
	h.quiet = quiet
	h.hero_damage = 7.0
	h.enemy_damage = 60.0
	return h


## Câmara das Runas Instáveis (spec section 3, C14-A6; name D-33): square, the floor of tiles is the room. A: bands
## (sweep, comb, cut) and four rune pillars at the grid's nodes; B: tiles (checker, frame, islands), two pillars and the
## quiet stone in the middle that never lights. The camera keeps the whole room in view.
func _runes() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"runes", RoomLayout.Size.MEDIUM, 2, Vector2(0.5, 1.0))
	l.floor = FloorShape.poly([_poly([-15, -9, -12, -12, 12, -12, 15, -9, 15, 9, 12, 12, -12, 12, -15, 9])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(4, 6)
	l.max_ranged = 2
	l.banned_roles = [&"area"]
	l.guardian = false
	# the north door's fire bowls, 0.9 m out of the floor (drawn, never blocking)
	var bowls: Array[ArenaObstacle] = [_bowl(3.8, -12.9), _bowl(8.2, -12.9)]
	var a: Array[ArenaObstacle] = []
	for p: Vector2 in [Vector2(-6, -6), Vector2(6, -6), Vector2(-6, 6), Vector2(6, 6)]:
		a.append(_piece(p.x, p.y, 1.2, 1.2, 4.0, &"rune_pillar", true))
	a.append_array(bowls)
	l.obstacles = a
	l.hazard = _hazard([&"sweep", &"comb", &"cut"], RUNES_ENTRY.duplicate())
	var b: Array[ArenaObstacle] = [_piece(-9, -6, 1.2, 1.2, 4.0, &"rune_pillar", true), _piece(9, 6, 1.2, 1.2, 4.0, &"rune_pillar", true)]
	# the quiet stone in the middle (its four tiles never light, HazardDef.quiet): drawn smooth, it stops nothing
	var quiet := ArenaObstacle.box(Vector2.ZERO, Vector2(3, 3), 0.0, &"quiet", 0.0, false)
	quiet.blocks_move = false
	b.append(quiet)
	b.append_array(bowls)
	var vb := _variant(b)
	var quiet_b: Array[Rect2] = [_rect(-3, 3, -3, 3)]
	quiet_b.append_array(RUNES_ENTRY)
	vb.hazard = _hazard([&"checker", &"frame", &"islands"], quiet_b)
	# RP-01: the quiet stone, the cross round it, the edge (B's two pillars stand on the edge)
	_areas(vb, ["quiet", _rect(-3, 3, -3, 3), "middle", _rect(-9, 9, -9, 9), "edge", _rect(-15, 15, -12, 12)])
	l.variants = [vb]
	# RP-07: B (the quiet stone, easier) in the middle, A late
	l.variant_depth = Vector2(0.67, 1.0)
	l.variants[0].depth = Vector2(0.5, 0.8)
	l.hero_spawn = Vector2(-12.5, 3.5)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(6, -12), Vector2(0, 1)), ArenaExit.at_edge(Vector2(15, 0), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(-4.5, 12), Vector2(0, -1))]
	l.spawns = [_rect(-4, 3, -11, -8), _rect(10, 13.5, -4, 4), _rect(0, 9, 8, 11)]
	l.late_spawns = [_rect(-13, -9, -9.5, -6)]
	l.cam_target = Vector2(0.5, 1.0)
	l.cam_reach = 3.5
	# RP-01: the four tiles round each pillar, the cross between them, the edge
	_areas(l, ["pillars", _rect(-9, -3, -9, -3), "pillars", _rect(3, 9, -9, -3), "pillars", _rect(-9, -3, 3, 9),
		"pillars", _rect(3, 9, 3, 9), "middle", _rect(-9, 9, -9, 9), "edge", _rect(-15, 15, -12, 12)])
	return l


## The Provação's chamber (spec 5.2): small, no fight, the square block in the middle under the light that holds the
## corruption; the cards are taken in front of it, then its doors open (the doors of the room the slab was in: 0 north,
## 1 west, 2 east).
func _trial_room() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"trial", RoomLayout.Size.SMALL, 0, Vector2(0.0, 0.0))
	l.floor = FloorShape.poly([_poly([-8, -5.5, -6.5, -7, 6.5, -7, 8, -5.5, 8, 5.5, 6.5, 7, -6.5, 7, -8, 5.5])])
	l.half = l.floor.extent()
	l.guardian = false
	l.obstacles = [_piece(0.0, 0.0, 1.2, 1.2, 1.1, &"trial_block")]
	l.hero_spawn = Vector2(-5.5, 4.5)
	l.hero_facing = Vector2(1, -1).normalized()
	l.exits = [ArenaExit.at_edge(Vector2(0, -7), Vector2(0, 1)), ArenaExit.at_edge(Vector2(-8, -2), Vector2(1, 0)),
		ArenaExit.at_edge(Vector2(8, -2), Vector2(-1, 0))]
	l.cam_target = Vector2(0.0, 0.5)
	l.cam_reach = 1.5
	return l


## The Altar Esquecido (spec 6.3): a chapel, the altar against the north wall, two stone benches facing it; its two
## trades stand on the worn slabs before the step; its doors open on the east (and the south front).
func _altar_room() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"altar", RoomLayout.Size.SMALL, 0, Vector2(0.0, 0.0))
	l.floor = FloorShape.poly([FloorShape.box(_rect(-9, 9, -7, 7))])
	l.half = l.floor.extent()
	l.guardian = false
	# a whole bench and a broken one (spec 6.3)
	l.obstacles = [_piece(0.0, -6.2, 3.6, 1.6, 1.3, &"altar"), _piece(-3.0, -1.0, 2.0, 0.6, 0.9, &"bench"),
		_piece(3.0, -1.5, 2.0, 0.6, 0.9, &"bench_broken")]
	l.hero_spawn = Vector2(-6.5, 4.5)
	l.hero_facing = Vector2(1, -1).normalized()
	l.exits = [ArenaExit.at_edge(Vector2(9, 2), Vector2(-1, 0)), ArenaExit.at_edge(Vector2(9, -3.5), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(4.5, 7), Vector2(0, -1))]
	l.cam_target = Vector2.ZERO
	l.cam_reach = 1.5
	return l


# ---------- E6: the Juramentos (D-63; docs/design/e6_juramentos.md) ----------

const JURAMENTO_DIR := "res://data/juramentos/"


func _juramento(order: int, id: StringName, stat: StringName, values: Array, weights: Array, shown := JuramentoDef.Shown.MORE) -> void:
	var j := JuramentoDef.new()
	j.id = id
	j.order = order
	j.name_key = StringName("jur_%s" % id)
	j.desc_key = StringName("jur_%s_desc" % id)
	j.stat = stat
	j.values = PackedFloat32Array(values)
	j.weights = PackedInt32Array(weights)
	j.shown = shown
	_save(j, JURAMENTO_DIR + "%02d_%s.tres" % [order, id])


## The vows of Hades II's Oath of the Unseen that map to what the run already has, with its numbers and its Fear per
## rank (the Peso; docs/design/hades2_sistemas.md, Votos da Noite e Medo). Pain, Grit, Frenzy, Hordes, Scars, Debt and
## Denial as there; Menace (foes of the next region) as more elites; Rivals (new moves) as a Morvath who rests less and
## raises more. Left out: Wards, Return, Fangs, Shadow, Forfeit, Time, Void, Hubris (docs/design/e6_juramentos.md).
func _juramentos() -> void:
	DirAccess.make_dir_recursive_absolute(JURAMENTO_DIR)
	for f in DirAccess.get_files_at(JURAMENTO_DIR):
		DirAccess.remove_absolute(JURAMENTO_DIR + f)
	_juramento(0, &"pain", &"enemy_damage_pct", [0.2, 0.6, 1.0], [1, 2, 2])
	_juramento(1, &"grit", &"enemy_hp_pct", [0.1, 0.2, 0.3], [1, 1, 1])
	_juramento(2, &"frenzy", &"enemy_speed_pct", [0.2, 0.4], [3, 3])
	_juramento(3, &"hordes", &"enemy_count_pct", [0.2, 0.4, 0.6], [1, 1, 1])
	_juramento(4, &"menace", &"elite_pct", [0.1, 0.25], [1, 2])
	_juramento(5, &"scars", &"heal_pct", [-0.25, -0.5, -1.0], [1, 1, 2], JuramentoDef.Shown.LEFT)
	_juramento(6, &"debt", &"price_pct", [0.4, 0.8], [1, 1])
	_juramento(7, &"denial", &"boon_denial", [2.0], [2], JuramentoDef.Shown.COUNT)
	_juramento(8, &"rivals", &"boss_rival", [0.25], [2])


# ---------- Rejogabilidade, Fatia 1 ----------

const FORGE_DIR := "res://data/forge/emeth/"


func _forge_rank(n: int, id: StringName, rank: int, cost: int, mods: Array[BoonMod], track: StringName = &"temper",
		slot: StringName = &"", tool: StringName = &"") -> void:
	var r := ForgeRank.new()
	r.id = id
	r.track = track
	r.slot = slot
	r.tool = tool
	r.rank = rank
	r.name_key = StringName("forge_" + id)
	r.desc_key = StringName("forge_%s_desc" % id)
	r.material = MaterialPurse.SILVER
	r.cost = cost
	r.mods = mods
	_save(r, FORGE_DIR + "%02d_%s.tres" % [n, id])


## The Forja da Emeth (sistemas.md 1.5; Q-RJ7 a: the first rank early and small): Temperar I, the attack 10% more
## damage (tag light: the three cuts, the Corte Veloz and the attack's Omega), 15 Prata; Temperar II, the special and
## its Omega 10% more (tag heavy), 35 Prata. A blow sums each matching mod once, so no move gets both but the
## lance (light) never counts II: "the Omegas" are the attack's by I and the special's by II.
func _forge() -> void:
	DirAccess.make_dir_recursive_absolute(FORGE_DIR)
	for f in DirAccess.get_files_at(FORGE_DIR):
		DirAccess.remove_absolute(FORGE_DIR + f)
	_forge_rank(0, &"temper_1", 1, 15, [_fixed(&"damage_pct", 0.1, [], &"light")] as Array[BoonMod])
	_forge_rank(1, &"temper_2", 2, 35, [_fixed(&"damage_pct", 0.1, [], &"heavy")] as Array[BoonMod])
	# Fatia 2: Temperar III, every blow of the Emeth 5% more (the attack's and the special's tags; no blow has both), 60
	_forge_rank(2, &"temper_3", 3, 60, [_fixed(&"damage_pct", 0.05, [], &"light"), _fixed(&"damage_pct", 0.05, [], &"heavy")] as Array[BoonMod])
	# Refinar (sistemas.md 1.5): a choice on each action, 25 Prata each, opened by the Forjador's first tool; Fio
	# (reach), Peso (the flinch longer) and Pressa (the blows faster) on the attack, their twins on the special
	var R := Forge.REFINE
	var tool := Forge.TOOL_REFINE
	_forge_rank(10, &"refine_fio", 1, 25, [_fixed(&"reach_pct", 0.1, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(11, &"refine_peso", 1, 25, [_fixed(&"stun_pct", 0.5, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(12, &"refine_pressa", 1, 25, [_fixed(&"blow_speed", 0.08, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(13, &"refine_onda_larga", 1, 25, [_fixed(&"wave_size_pct", 0.2, [], &"heavy")] as Array[BoonMod], R, &"special", tool)
	_forge_rank(14, &"refine_onda_pesada", 1, 25, [_fixed(&"stun_pct", 0.5, [], &"heavy")] as Array[BoonMod], R, &"special", tool)
	_forge_rank(15, &"refine_onda_pronta", 1, 25, [_fixed(&"blow_speed", 0.08, [], &"heavy")] as Array[BoonMod], R, &"special", tool)


const ANGEL_DIR := "res://data/angels/"
const ENCHANT_DIR := "res://data/enchants/"


func _enchant(n: int, id: StringName, slot: Boon.Slot, mods: Array[BoonMod], excludes: Array[StringName] = []) -> void:
	var e := EnchantDef.new()
	e.id = id
	e.name_key = StringName("enchant_" + id)
	e.desc_key = StringName("enchant_%s_desc" % id)
	e.slot = slot
	e.mods = mods
	e.excludes = excludes
	e.learned = true
	_save(e, ENCHANT_DIR + "%02d_%s.tres" % [n, id])


## The Encantos of the Fatia 2 (sistemas.md 1.7, auditoria.md 3.1: the Lapidação of hades2_sistemas.md 6, Hades II's
## hammer), all three learned from the start: Lâmina Tríplice, the spin throws three waves in a fan, 12 each, 6 m (the
## Corte Crescente's substitute: never with it); Eco da Verdade, the spin strikes again 0.3 s later for half; Retorno
## do Corte, within 1 s of a Corte Veloz the next blow reaches 30% farther and wider (never with the dash's chains).
func _enchants() -> void:
	DirAccess.make_dir_recursive_absolute(ENCHANT_DIR)
	for f in DirAccess.get_files_at(ENCHANT_DIR):
		DirAccess.remove_absolute(ENCHANT_DIR + f)
	var S := Boon.Slot
	var fan := _wave(&"spin", 12.0, 6.0, 3.0)
	fan.append(_fixed(&"blow_wave_fan", 2, [], &"spin"))
	_enchant(0, &"lamina_triplice", S.ATTACK, fan, [&"corte_crescente"] as Array[StringName])
	_enchant(1, &"eco_da_verdade", S.ATTACK, [_fixed(&"echo_pct", 0.5, [], &"spin"), _fixed(&"echo_delay", 0.3, [], &"spin")] as Array[BoonMod])
	_enchant(2, &"retorno_do_corte", S.DASH, [_fixed(&"return_time", 1.0, [], &"dash"), _fixed(&"return_reach", 0.3, [], &"dash")] as Array[BoonMod],
		[&"passo_encadeado", &"fio_do_passo"] as Array[StringName])


func _angel(n: int, id: StringName, family: Boon.Family, symbol: int, color: Color) -> void:
	var a := AngelDef.new()
	a.id = id
	a.family = family
	a.name_key = StringName("angel_" + id)
	a.line_key = StringName("angel_%s_line" % id)
	a.symbol = symbol
	a.color = color
	_save(a, ANGEL_DIR + "%02d_%s.tres" % [n, id])


## The four angels (sistemas.md 4, Q-RJ4 approved 2026-11-19, working names): one a family, the seal in the family's
## colour (the seal's, AngelSeal.TINT: calmer than Boon.FAMILY_COLOR).
func _angels() -> void:
	DirAccess.make_dir_recursive_absolute(ANGEL_DIR)
	for f in DirAccess.get_files_at(ANGEL_DIR):
		DirAccess.remove_absolute(ANGEL_DIR + f)
	var F := Boon.Family
	# the colors are the seals' (AngelSeal.TINT): Chama earthy amber, Geada, Luz, Vigília sage
	_angel(0, &"sarael", F.CHAMA, 0, Color(0.82, 0.5, 0.27))
	_angel(1, &"nivael", F.GEADA, 1, Color(0.58, 0.76, 0.88))
	_angel(2, &"lumael", F.LUZ, 2, Color(0.92, 0.82, 0.56))
	_angel(3, &"shomael", F.VIGILIA, 3, Color(0.58, 0.68, 0.43))
