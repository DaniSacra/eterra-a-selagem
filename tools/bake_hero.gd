extends SceneTree
## Turns animation clips made for other rigs into the hero's own clips (Retarget) and saves them as one
## AnimationLibrary next to the hero's model. Edit CLIPS and run:
## ~/tools/godot/godot --headless --path . -s tools/bake_hero.gd
## It also prints where the sword hand moves fastest in each clip (the swing peak, for PEAK in make_data.gd).

## The bones of the sword arm (taken from the arm clip, see CLIPS).
const SWORD_ARM: Array[StringName] = [&"RightShoulder", &"RightArm", &"RightForeArm", &"RightHand"]
const OUT := HeroBody.ANIMS
const FPS := 30.0
const SOURCES := {
	&"ual": "res://assets/models/anim/ual_standard.glb",
	&"ual2": "res://assets/models/anim/ual2_standard.glb",
}
## Hero clip -> [source rig, source clip, loops, from (s), to (s, 0 = end), bob]. Root motion is always dropped.
## bob (optional): how much of the hips' rise and fall to keep above their lowest point. The library's jog lifts
## the hips 38 cm a step at the hero's size, which reads as hopping; a run of his size rises about 10.
## arm (optional): a clip of the same rig whose sword arm replaces this one's (the library's runs are unarmed, so
## the sword would flail; the guard keeps it steady while the legs run).
const CLIPS := {
	&"Idle": [&"ual", &"Sword_Idle", true, 0.0, 0.0],
	&"Run": [&"ual", &"Jog_Fwd", true, 0.0, 0.0, 0.28, &"Sword_Idle"],
	&"Sprint": [&"ual", &"Sprint", true, 0.0, 0.0, 0.5, &"Sword_Idle"],
	&"Roll": [&"ual", &"Roll", false, 0.0, 0.0],
	&"Dash": [&"ual2", &"Sword_Dash_RM", false, 0.12, 0.72],
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
			var arm := {}
			if c.size() > 6:
				var guard: StringName = c[6]
				ap.play(guard)
				ap.seek(fmod(t, ap.get_animation(guard).length), true)
				var held := rt.solve()
				for bone in SWORD_ARM:
					var bi := hs.find_bone(bone)
					if held.has(bi):
						arm[bi] = held[bi]
			ap.play(c[1])
			ap.seek(from + t, true)
			var pose := rt.solve()
			pose.merge(arm, true)
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
	# hand; the clips swing it with the blade on the pinky side (the index side leaves it behind the back at rest)
	var ual: Retarget = rigs[&"ual"][2]
	var index := ual.source_rest(&"DEF-f_index.01.R")
	var pinky := ual.source_rest(&"DEF-f_pinky.01.R")
	var wrist := ual.source_rest(&"DEF-hand.R")
	var grip := ual.carry(&"RightHand", pinky - index, (index + pinky) * 0.5 - wrist)
	lib.set_meta(&"grip_dir", grip[0])
	lib.set_meta(&"grip_at", grip[1])
	print("grip ", grip)
	ResourceSaver.save(lib, OUT)
	print("saved ", OUT)
	quit()


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
