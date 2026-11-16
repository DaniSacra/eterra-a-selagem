extends SceneTree
## Turns animation clips made for other rigs into the hero's own clips (Retarget) and saves them as one
## AnimationLibrary next to the hero's model. Edit CLIPS and run:
## ~/tools/godot/godot --headless --path . -s tools/bake_hero.gd
## It also prints where the sword hand moves fastest in each clip (the swing peak, for PEAK in make_data.gd).

## The bones of the sword arm (taken from the arm clip, see CLIPS).
const SWORD_ARM: Array[StringName] = [&"RightShoulder", &"RightArm", &"RightForeArm", &"RightHand"]
const OUT := HeroBody.ANIMS
const FPS := 30.0
## How far (degrees) the blade leans from the line of the knuckles toward the fingers.
const GRIP_TILT := 25.0
const SOURCES := {
	&"ual": "res://assets/models/anim/ual_standard.glb",
	&"ual2": "res://assets/models/anim/ual2_standard.glb",
}
## Hero clip -> [source rig, source clip, loops, from (s), to (s, 0 = end), bob, guard]. Root motion is always dropped.
## bob (optional): how much of the hips' rise and fall to keep above their lowest point. The library's jog lifts
## the hips 38 cm a step at the hero's size, which reads as hopping; a run of his size rises about 10.
## guard (optional, degrees): the sword arm is held in the GUARD stance instead of the clip's own (the library's runs
## are unarmed, so the sword would flail), the upper arm turned this much forward of it. The upper arm keeps the
## stance's direction on the body whatever the chest does (a run twists the chest, and an arm that followed it swung
## the blade through the legs). GUARD [source rig, clip, at (s)] is the still sword stance the second library's
## swings start from: the hand by the hip, the blade ahead of him and a little down (Ember & Blade's carry; the
## first library's Sword_Idle holds the hand behind the hip, and the blade trailed behind him).
const GUARD := [&"ual2", &"Sword_Regular_A", 0.0]
const GUARD_IDLE := 12.0
const GUARD_RUN := 20.0
## How far (degrees) the held blade dips below where the stance points it (the stance holds it level).
const GUARD_DOWN := 15.0
const CLIPS := {
	&"Idle": [&"ual", &"Sword_Idle", true, 0.0, 0.0, 1.0, GUARD_IDLE],
	&"Run": [&"ual", &"Jog_Fwd", true, 0.0, 0.0, 0.28, GUARD_RUN],
	&"Sprint": [&"ual", &"Sprint", true, 0.0, 0.0, 0.5, GUARD_RUN],
	&"Roll": [&"ual", &"Roll", false, 0.0, 0.0],
	&"Dash": [&"ual2", &"Sword_Dash_RM", false, 0.12, 0.72, 1.0, GUARD_RUN],
	&"Slash_A": [&"ual2", &"Sword_Regular_A", false, 0.0, 0.0],
	&"Slash_A_Rec": [&"ual2", &"Sword_Regular_A_Rec", false, 0.0, 0.0],
	&"Slash_B": [&"ual2", &"Sword_Regular_B", false, 0.0, 0.0],
	&"Slash_B_Rec": [&"ual2", &"Sword_Regular_B_Rec", false, 0.0, 0.0],
	&"Slash_C": [&"ual2", &"Sword_Regular_C", false, 0.0, 0.0],
	&"Slash_Combo": [&"ual2", &"Sword_Regular_Combo", false, 0.0, 0.0],
	&"Sword_Attack": [&"ual", &"Sword_Attack", false, 0.0, 0.0],
	&"Cast": [&"ual", &"Spell_Simple_Shoot", false, 0.0, 0.0],
	&"Throw": [&"ual2", &"OverhandThrow", false, 0.0, 0.0],
	&"Hit": [&"ual", &"Hit_Chest", false, 0.0, 0.0],
	&"Knockback": [&"ual2", &"Hit_Knockback", false, 0.0, 0.0],
	&"Death": [&"ual", &"Death01", false, 0.0, 0.0],
}


func _initialize() -> void:
	_bake.call_deferred()


func _bake() -> void:
	var hero := (load(HeroBody.MODEL) as PackedScene).instantiate() as Node3D
	root.add_child(hero)
	var hs := PoseBaker.find_skeleton(hero)
	var hero_player := PoseBaker.find_player(hero)
	var base := hero_player.get_node(hero_player.root_node).get_path_to(hs)
	var hand := hs.find_bone(&"RightHand")
	var space := Retarget._space(hs, hero)
	var lib := AnimationLibrary.new()
	var rigs := {}
	for id: StringName in SOURCES:
		var src := (load(SOURCES[id]) as PackedScene).instantiate() as Node3D
		root.add_child(src)
		var sk := PoseBaker.find_skeleton(src)
		rigs[id] = [src, PoseBaker.find_player(src), Retarget.new(sk, src, hs, hero, Retarget.RIGS[id])]
	# the sword stance, solved once (a still pose)
	var g: Array = rigs[GUARD[0]]
	(g[1] as AnimationPlayer).play(GUARD[1])
	(g[1] as AnimationPlayer).seek(GUARD[2], true)
	var guard := (g[2] as Retarget).solve()
	guard[&"arm"] = (g[2] as Retarget).turn(hs.find_bone(&"RightArm"), guard)
	guard[&"hand"] = (g[2] as Retarget).turn(hs.find_bone(&"RightHand"), guard)
	for name: StringName in CLIPS:
		var c: Array = CLIPS[name]
		var rig: Array = rigs[c[0]]
		var ap: AnimationPlayer = rig[1]
		var rt: Retarget = rig[2]
		if not ap.has_animation(c[1]):
			push_error("no clip %s in %s" % [c[1], c[0]])
			continue
		var from: float = c[3]
		var to: float = c[4] if c[4] > 0.0 else ap.get_animation(c[1]).length
		var anim := Animation.new()
		anim.length = to - from
		anim.loop_mode = Animation.LOOP_LINEAR if c[2] else Animation.LOOP_NONE
		var tracks := {}
		for b: int in rt.solve():
			var tr := anim.add_track(Animation.TYPE_ROTATION_3D)
			anim.track_set_path(tr, NodePath("%s:%s" % [base, hs.get_bone_name(b)]))
			tracks[b] = tr
		var hips_tr := anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(hips_tr, NodePath("%s:%s" % [base, hs.get_bone_name(rt.hips_bone())]))
		var frames := int(ceil(anim.length * FPS))
		var peak := 0.0
		var peak_speed := 0.0
		var peak_dir := Vector3.ZERO
		var last_hand := Vector3.INF
		var feet: Array[Vector3] = []
		var hips_low := INF
		var hips_high := -INF
		var hips_keys: Array = []
		for f in frames + 1:
			var t := minf(f / FPS, anim.length)
			ap.play(c[1])
			ap.seek(from + t, true)
			var pose := rt.solve()
			if c.size() > 6:
				_hold_guard(pose, guard, c[6], rt, hs, space)
			for b: int in pose:
				anim.rotation_track_insert_key(tracks[b], t, pose[b])
			var hips := rt.hips_position(true)
			var hy := (space * hips).y
			hips_low = minf(hips_low, hy)
			hips_high = maxf(hips_high, hy)
			hips_keys.append([t, hips])
			# the sword hand, from the solved pose
			var at := _bone_origin(hs, hand, pose, hips, rt.hips_bone())
			var p := space * at
			if last_hand != Vector3.INF:
				var speed := p.distance_to(last_hand) * FPS
				if speed > peak_speed:
					peak_speed = speed
					peak = t
					peak_dir = p - last_hand
			last_hand = p
			feet.append(space * _bone_origin(hs, hs.find_bone(&"LeftToeBase"), pose, hips, rt.hips_bone()))
		var bob: float = c[5] if c.size() > 5 else 1.0
		for k: Array in hips_keys:
			var at: Vector3 = space * (k[1] as Vector3)
			at.y = hips_low + (at.y - hips_low) * bob
			anim.position_track_insert_key(hips_tr, k[0], space.inverse() * at)
		lib.add_animation(name, anim)
		# which way the blade crosses at the peak: the hero faces +Z, his left is +X
		var across := "right to left" if peak_dir.x > 0.0 else "left to right"
		if absf(peak_dir.y) > absf(peak_dir.x) * 1.5:
			across += " (mostly %s)" % ("down" if peak_dir.y < 0.0 else "up")
		var line := "%s: %.2f s, peak %.2f s (%.1f m/s, %s)" % [name, anim.length, peak, peak_speed, across]
		if c[2]:
			line += ", hips bob %.0f cm (kept %.0f)" % [(hips_high - hips_low) * 100.0 * HeroBody.HEIGHT / HeroBody.MODEL_HEIGHT,
				(hips_high - hips_low) * bob * 100.0 * HeroBody.HEIGHT / HeroBody.MODEL_HEIGHT]
			line += ", ground pace %.2f m/s at the game's size" % (_pace(feet) * HeroBody.HEIGHT / HeroBody.MODEL_HEIGHT)
		print(line)
	# the sword's grip: the handle runs across the knuckles of the mannequin's right fist, through the middle of the
	# hand, with the blade out of the thumb and index side as a fist holds it, leaning GRIP_TILT toward the fingers
	# (a handle crosses the palm on a slant). (Until 2026-11-15 the blade came out of the pinky side, the fist held
	# upside down: from the old idle it trailed behind his back, and raised in a swing it hung down.)
	var ual: Retarget = rigs[&"ual"][2]
	var index := ual.source_rest(&"DEF-f_index.01.R")
	var pinky := ual.source_rest(&"DEF-f_pinky.01.R")
	var wrist := ual.source_rest(&"DEF-hand.R")
	var grip := ual.carry(&"RightHand", grip_line(index, pinky, wrist), (index + pinky) * 0.5 - wrist)
	lib.set_meta(&"grip_dir", grip[0])
	lib.set_meta(&"grip_at", grip[1])
	print("grip ", grip)
	ResourceSaver.save(lib, OUT)
	print("saved ", OUT)
	quit()


## Holds the sword arm of a solved pose in the guard stance: the shoulder as the stance has it on the chest, the
## upper arm turned as in the stance on the body (skeleton space; guard[&"arm"]) and raise degrees forward, the
## forearm as in the stance, the hand turned as in the stance on the body and GUARD_DOWN lower (guard[&"hand"]).
func _hold_guard(pose: Dictionary, guard: Dictionary, raise: float, rt: Retarget, hs: Skeleton3D, space: Basis) -> void:
	for bone in SWORD_ARM:
		var bi := hs.find_bone(bone)
		if guard.has(bi):
			pose[bi] = guard[bi]
	var arm := hs.find_bone(&"RightArm")
	# forward: the arm hanging down (-Y) swings toward the front (+Z), around the hero's left (+X)
	var side := space.orthonormalized().inverse() * Vector3.RIGHT
	var want := Basis(side.normalized(), deg_to_rad(-raise)) * (guard[&"arm"] as Basis)
	pose[arm] = (rt.turn(hs.get_bone_parent(arm), pose).inverse() * want).get_rotation_quaternion()
	# the wrist keeps the blade where the stance points it, GUARD_DOWN lower, however far the arm is raised
	var hand := hs.find_bone(&"RightHand")
	want = Basis(side.normalized(), deg_to_rad(GUARD_DOWN)) * (guard[&"hand"] as Basis)
	pose[hand] = (rt.turn(hs.get_bone_parent(hand), pose).inverse() * want).get_rotation_quaternion()


## The way the blade leaves a right fist (model space), from the rest of its index and pinky knuckles and its wrist:
## out of the index side, leaning GRIP_TILT toward the fingers.
static func grip_line(index: Vector3, pinky: Vector3, wrist: Vector3) -> Vector3:
	var across := (index - pinky).normalized()
	var fingers := (index + pinky) * 0.5 - wrist
	fingers = (fingers - across * fingers.dot(across)).normalized()
	return (across * cos(deg_to_rad(GRIP_TILT)) + fingers * sin(deg_to_rad(GRIP_TILT))).normalized()


## Where a bone sits (skeleton space) in a solved pose.
func _bone_origin(sk: Skeleton3D, bone: int, pose: Dictionary, hips: Vector3, hips_bone: int) -> Vector3:
	var chain: Array[int] = []
	var b := bone
	while b >= 0:
		chain.push_front(b)
		b = sk.get_bone_parent(b)
	var t := Transform3D.IDENTITY
	for i in chain:
		var rest := sk.get_bone_rest(i)
		var rot: Quaternion = pose[i] if pose.has(i) else rest.basis.get_rotation_quaternion()
		var origin := hips if i == hips_bone else rest.origin
		t = t * Transform3D(Basis(rot), origin)
	return t.origin


## How fast a looping clip's planted foot slides back (meters a second, model size): the speed it walks at.
func _pace(feet: Array[Vector3]) -> float:
	var low := INF
	for f in feet:
		low = minf(low, f.y)
	var sum := 0.0
	var n := 0
	for i in range(1, feet.size()):
		if feet[i].y < low + 0.03 and feet[i - 1].y < low + 0.03:
			sum += absf(feet[i].z - feet[i - 1].z) * FPS
			n += 1
	return sum / maxf(n, 1)
