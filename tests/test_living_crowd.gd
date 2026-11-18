extends GutTest
## E1a "Inimigos vivos": the crowd and Morvath move between their poses (a vertex animation blended on the video card,
## BakedModel, crowd_pose.gdshaderinc), with more poses a clip; the walk plays at the pace its planted foot is
## measured for; a wounded body jolts back from the blow and returns, only drawn.

const DIR := "res://data/enemies/"
const FIGURES: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder", &"morvath"]
## Poses a clip at least (VX-04): walk 20, hit 8, idle 12, death 16, attacks 14 where the figure has one.
const LEAST := {&"walk": 20, &"hit": 8, &"idle": 12, &"death": 16, &"attack": 14, &"slash1": 14, &"slash2": 14, &"slash3": 14}
## Seconds of every clip before E1a (read from the baked files of 10944b1): the tells of the attacks are timed on them,
## so more poses never change how long a clip plays (the walk is timed by its stride, E1a-2).
const BEFORE := {
	# E1c (AUDIT.md P7): the crossbowman stands with the crossbow low (the Idle, 2.5 s; it was the pistol's 1.667)
	&"archer": {&"aim": 1.667, &"attack": 0.633, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rise": 0.9},
	# T5-06, T5-07 (combat_cadence.md 6.3): the charge of the brute and the knight is its own clip (the shield's push,
	# 0.5 s, drawn from the start of the charge), the spent recovery after it Idle_Shield_Break (1.07 s, played at its
	# pace and faded to the guard; Horde.render), the knight braces as the brute does (its brace a one-shot of 0.3 s
	# drawn by Horde.windup_arm over the wind-up). A-T5-1: the charge is run (a loop of 0.45 s, the Sprint quickened, the
	# trunk held behind the shield) and loops for the whole charge (it was the 0.5 s push once, its last pose held)
	&"guard": {&"attack": 1.1, &"brace": 1.15, &"charge": 0.45, &"recover": 1.067, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rise": 0.9},
	&"knight": {&"attack": 1.1, &"brace": 0.3, &"charge": 0.45, &"recover": 1.067, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rise": 0.9},
	# T5-03, T5-13: the staff rises (cast, Spell_Simple_Enter 0.53 s) over the arm of the wind-up (Horde.windup_arm, no
	# longer a loop played as long as the wind-up), is held (cast_hold, the loop that was cast), each orb its own
	# thrust (shot, 0.17 s: the bursts' interval) and comes down in the recovery (exit); the "aim" it never used is gone
	&"mage": {&"attack": 0.5, &"cast": 0.533, &"cast_hold": 2.1, &"shot": 0.17, &"exit": 0.433, &"death": 1.9, &"hit": 0.333, &"idle": 1.267, &"rise": 0.9},
	# T5-15: the charge's own crouch (0.12 s of Sword_Dash_RM, armed by Boss over the wind-up; it was a still guard
	# loop of 1.067 s) and the Blades' draw (blades_windup)
	&"morvath": {&"attack": 1.1, &"dash": 0.6, &"dash_windup": 0.12, &"blades_windup": 0.2, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rain": 2.1,
		&"rise": 0.9, &"roar": 1.033, &"slash1": 0.433, &"slash2": 0.533, &"slash3": 1.1, &"stunned": 2.933, &"summon": 4.3, &"volley": 0.5},
	&"priest": {&"attack": 0.5, &"cast": 0.8, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rise": 0.9},
	# T5-03: as the sorcerer's, and raising its dead is the priests' summon (0.8 s)
	&"priest_elder": {&"attack": 0.5, &"cast": 0.533, &"cast_hold": 2.1, &"summon": 0.8, &"death": 1.9, &"hit": 0.333, &"idle": 1.267, &"rise": 0.9},
	# T5-04: the runner gathers (windup, 0.15 s of Jump_Start, armed over its wind-up; it was a crouch loop of 2.933 s)
	# and bursts spinning (attack, 2H_Melee_Attack_Spinning 0.667 s; it was a punch of 1.0)
	&"runner": {&"attack": 0.667, &"death": 1.9, &"hit": 0.333, &"idle": 1.333, &"rise": 0.9, &"windup": 0.15},
	# T5-02: the soldier's wind-up is the whole rise of the blade, 0 to 0.35 s of the clip, armed by Horde.windup_arm over
	# its 0.9 s (it was 0.1 to 0.3 stretched to 0.9); its blow starts there, 0.35 to 1.2 s
	&"skeleton": {&"attack": 0.85, &"death": 1.9, &"hit": 0.333, &"idle": 2.5, &"rise": 0.9, &"windup": 0.35},
}
## E1b-A1: how far the planted foot may slide in a step, in the game's meters (the baked slide times EnemyDef.size):
## 5 cm for those who run, 8 cm for the big ones who walk. The priest never walks (speed 0).
const SLIDE_RUN := 0.05
const SLIDE_WALK := 0.08
const BIG_WALKERS: Array[StringName] = [&"guard", &"knight", &"morvath", &"priest_elder"]
## E1b-A2 and A3: steps a minute in the game, at the enemy's speed and size (the walk's two steps a loop): the brute's
## heavy walk, the knight's and Morvath's long stride, the sorcerer's and the crossbowman's short trot.
const CADENCE := {&"guard": Vector2(110, 140), &"knight": Vector2(90, 120), &"morvath": Vector2(90, 120),
	&"mage": Vector2(120, 150), &"archer": Vector2(120, 150),
	# E1c (AUDIT.md P6): the soldier runs about 150 a minute (it floated at 96), the elder walks about 90 (it was 67);
	# T5-11: the soldier jogs at 160 to 170 (Jog_Fwd, no longer the hop of a gazelle)
	&"skeleton": Vector2(155, 170), &"priest_elder": Vector2(80, 100)}
## The ceiling of the baked figures on disk (E1a: 70 MB).
const BAKED_MB := 70.0


func _model(id: StringName) -> BakedModel:
	return load("res://assets/baked/%s.res" % id)


func test_every_clip_has_the_poses_it_needs() -> void:
	for id in FIGURES:
		var m := _model(id)
		for anim: StringName in LEAST:
			if m.frame_count(anim) > 0:
				assert_gte(m.frame_count(anim), int(LEAST[anim]), "%s %s: %d poses" % [id, anim, m.frame_count(anim)])


func test_more_poses_never_change_how_long_a_clip_plays() -> void:
	for id: StringName in BEFORE:
		var m := _model(id)
		for anim: StringName in BEFORE[id]:
			assert_almost_eq(m.duration(anim), float(BEFORE[id][anim]), 0.002, "%s %s" % [id, anim])


## A loop goes round, the next of its last pose is its first; a one-shot reaches its last pose when it ends and stays.
func test_the_blend_between_poses() -> void:
	assert_eq(BakedModel.blend(10, 10.0, true, 0.0), Vector3(0, 1, 0))
	var mid := BakedModel.blend(10, 10.0, true, 0.25)
	assert_eq(Vector2(mid.x, mid.y), Vector2(2, 3))
	assert_almost_eq(mid.z, 0.5, 0.0001)
	var wrap := BakedModel.blend(10, 10.0, true, 0.95)
	assert_eq(Vector2(wrap.x, wrap.y), Vector2(9, 0), "the last pose blends into the first")
	assert_almost_eq(BakedModel.blend(10, 10.0, true, 1.05).z, 0.5, 0.0001, "and goes round")
	var m := _model(&"skeleton")
	var end := m.blend_at(&"death", m.duration(&"death"))
	assert_eq(end, Vector3(15, 15, 0), "a one-shot ends on its last pose")
	assert_eq(m.blend_at(&"death", 99.0), end, "and stays there")
	assert_eq(m.blend_at(&"death", -1.0), Vector3(0, 1, 0))


## The acceptance of VX-04: frames in a row at 30 FPS of a soldier walking never show the same pose.
func test_a_walking_soldier_never_repeats_a_pose_at_30_fps() -> void:
	var d: EnemyDef = load(DIR + "skeleton.tres")
	var m := _model(d.model)
	var rate := Horde.walk_rate(d.speed, float(m.ground_speed[&"walk"]), d.size)
	var last := Vector3(-1, -1, -1)
	for f in 120:
		var shown := m.blend_at(&"walk", f / 30.0 * rate)
		assert_ne(shown, last, "frame %d" % f)
		last = shown


## The poses kept in the images are the ones baked (half floats: a millimeter or two; normals to a degree or two).
func test_the_pose_images_keep_the_poses() -> void:
	var a := PackedVector3Array([Vector3(0.1, 1.9, -0.3), Vector3(-0.5, 0.02, 0.7), Vector3(0, 0, 0)])
	var b := PackedVector3Array([Vector3(0.12, 1.85, -0.2), Vector3(-0.4, 0.0, 0.6), Vector3(2, 1, 0)])
	var n := PackedVector3Array([Vector3.UP, Vector3(0.3, -0.8, 0.5).normalized(), Vector3(-1, 0, 0)])
	var mesh := BoxMesh.new()
	var m := BakedModel.new()
	m.pack(mesh, {"walk": [[a, n], [b, n]], "idle": [[b, n]]})
	assert_eq(m.vertices, 3)
	assert_eq(m.first, {"walk": 0, "idle": 2})
	assert_eq(m.positions.get_format(), Image.FORMAT_RGBAH)
	for v in 3:
		assert_almost_eq(m.position(&"walk", 0, v), a[v], Vector3.ONE * 0.002)
		assert_almost_eq(m.position(&"walk", 1, v), b[v], Vector3.ONE * 0.002)
		assert_almost_eq(m.position(&"idle", 0, v), b[v], Vector3.ONE * 0.002)
		assert_gt(m.normal(&"walk", 0, v).dot(n[v]), 0.999, "normal %d" % v)
	for i in 200:
		var dir := Vector3(sin(i * 1.7), cos(i * 0.9), sin(i * 2.3 + 1.0)).normalized()
		assert_gt(BakedModel.oct_decode(BakedModel.oct_encode(dir)).dot(dir), 0.99999, str(dir))


## Every figure: as many vertices in its mesh as in each pose of its images, the shape its first idle pose.
func test_every_figure_is_one_mesh_and_its_poses() -> void:
	for id in FIGURES:
		var m := _model(id)
		assert_eq(m.mesh.surface_get_array_len(0), m.vertices, String(id))
		var rows := 0
		for anim: StringName in m.frames:
			rows += m.frame_count(anim)
		assert_eq(m.positions.get_height(), ceili(float(rows * m.vertices) / BakedModel.WIDTH), String(id))
		assert_eq(m.normals.get_height(), m.positions.get_height())
		var verts: PackedVector3Array = m.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		for v in [0, m.vertices / 2, m.vertices - 1]:
			assert_almost_eq(m.position(&"idle", 0, v), verts[v], Vector3.ONE * 0.004, "%s vertex %d" % [id, v])


func test_the_baked_figures_fit_their_ceiling() -> void:
	var total := 0
	for f in DirAccess.get_files_at("res://assets/baked"):
		if f.ends_with(".res"):
			total += FileAccess.get_file_as_bytes("res://assets/baked/" + f).size()
	gut.p("baked figures: %.1f MB" % (total / 1048576.0))
	assert_lt(total / 1048576.0, BAKED_MB)


## VX-05 and E1b-A1: the planted foot of every walk strays from where it was put, in a step, less than its ceiling in
## the game's meters (the figure drawn at its size), at the speed measured in the bake, and the horde plays the walk at
## that speed for the enemy's own (its size and pace).
func test_the_planted_foot_stays_put() -> void:
	for id in FIGURES:
		var m := _model(id)
		assert_true(m.ground_speed.has(&"walk"), "%s: the walk is measured" % id)
		var ground: float = m.ground_speed[&"walk"]
		assert_gt(ground, 0.0, String(id))
		if id == &"priest":
			continue
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		var slide := BakedModel.slide_per_step(m.feet[&"walk"], 1.0 / float(m.fps[&"walk"]), ground) * d.size
		gut.p("%s: the floor runs %.2f m/s under the walk, the foot slides %.3f m a step in the game" % [id, ground, slide])
		assert_lt(slide, SLIDE_WALK if BIG_WALKERS.has(id) else SLIDE_RUN, "%s: %.3f m a step in the game" % [id, slide])
	for f in DirAccess.get_files_at(DIR):
		if not f.ends_with(".tres"):
			continue
		var d: EnemyDef = load(DIR + f)
		var m := _model(d.model)
		if d.speed <= 0.0:
			continue
		var rate := Horde.walk_rate(d.speed, float(m.ground_speed[&"walk"]), d.size)
		# the foot goes back as fast as the body goes forward
		assert_almost_eq(rate * float(m.ground_speed[&"walk"]) * d.size, d.speed, 0.001, String(d.id))


## E1b-A2 and A3: each walk takes the steps a minute of its figure's weight at its speed in the game.
func test_the_steps_a_minute_fit_the_figure() -> void:
	for id: StringName in CADENCE:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		var m := _model(d.model)
		var rate := Horde.walk_rate(d.speed, float(m.ground_speed[&"walk"]), d.size)
		var steps := 120.0 * rate / m.duration(&"walk")
		gut.p("%s: %.0f steps a minute" % [id, steps])
		var band: Vector2 = CADENCE[id]
		assert_between(steps, band.x, band.y, String(id))


## The walk is measured on a foot that bears the figure: a made-up stride, the foot on the floor going back 0.1 m a
## pose, the other in the air.
func test_the_stride_is_read_from_the_foot_on_the_floor() -> void:
	var left: Array = []
	var right: Array = []
	for i in 10:
		var down := i < 5
		var z := 0.2 - 0.1 * i if down else -0.3 + 0.1 * (i - 5)
		left.append(PackedVector3Array([Vector3(0.1, 0.0 if down else 0.2, z)]))
		var rz := 0.2 - 0.1 * (i - 5) if not down else -0.3 + 0.1 * i
		right.append(PackedVector3Array([Vector3(-0.1, 0.0 if not down else 0.2, rz)]))
	var feet := [left, right]
	assert_almost_eq(BakedModel.ground_of(feet, 0.1), 1.0, 0.01, "0.1 m a pose, a pose every 0.1 s")
	assert_lt(BakedModel.slide_per_step(feet, 0.1, 1.0), 0.001)
	assert_almost_eq(BakedModel.slide_per_step(feet, 0.1, 0.8), 0.1, 0.001, "too slow: 2 cm a pose, 5 steps of a pose on the floor")


## VX-06: a blow pushes the drawn body back 0.15 to 0.3 m within three frames, then it returns.
func test_the_recoil_of_a_blow() -> void:
	for heavy in [false, true]:
		var peak := 0.0
		var at := 0.0
		for f in 30:
			var o := HitRecoil.offset(f / 60.0, heavy)
			if o > peak:
				peak = o
				at = f / 60.0
		assert_between(peak, 0.15, 0.3, "heavy %s" % heavy)
		assert_lte(at, 3.0 / 60.0 + 0.0001, "seen in three frames")
		assert_gt(HitRecoil.offset(1.0 / 60.0, heavy), peak * 0.5, "most of it on the first frame after the blow")
		assert_eq(HitRecoil.offset(HitRecoil.BACK, heavy), 0.0, "back in place")
		assert_eq(HitRecoil.offset(-1.0, heavy), 0.0, "no blow")


## Only drawn: the struck soldier is drawn away from the blow and back, where it stands in the simulation never moves.
func test_the_recoil_is_only_drawn() -> void:
	var horde := Horde.new()
	add_child_autofree(horde)
	var e := horde.spawn(load(DIR + "skeleton.tres"), Vector2(2, 0), false)
	e.state = Enemy.State.WALK
	horde.damage(e, 1.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.pos, Vector2(2, 0), "the blow pushed nothing (no knockback)")
	var drawn: Array[float] = []
	for f in 25:
		horde.render()
		var clip: CrowdRenderer.Clip = horde.renderer._clip(horde.renderer.kind(e.def), &"hit")
		drawn.append(clip.batch.data[3] if clip.batch and clip.batch.count > 0 else 2.0)
		horde._timers(e, 1.0 / 60.0)
		e.pos = Vector2(2, 0)
	assert_gt(drawn.max(), 2.15, "pushed back from the blow")
	assert_almost_eq(drawn[drawn.size() - 1], 2.0, 0.02, "and back")
