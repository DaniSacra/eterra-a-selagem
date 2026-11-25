extends GutTest
## The first region's enemies after Daniel's sheet (docs/art/enemies_phase1.md): each one drawn by its own baked
## model (the Meshy figures since 2026-11-15), the elites by the same figure in old gold, sizes in the sheet's order,
## magic in its colours.

const DIR := "res://data/enemies/"
## The sheet's scale, the soldier at 1.15 (docs/art/enemies_phase1.md).
const SHEET_SIZE := {
	&"skeleton": 1.15, &"runner": 1.04, &"mage": 1.27, &"archer": 1.27, &"guard": 1.5, &"priest": 1.3,
	&"knight": 2.07, &"priest_elder": 2.19, &"morvath": 2.53,
}


func _defs() -> Array[EnemyDef]:
	var out: Array[EnemyDef] = []
	for f in DirAccess.get_files_at(DIR):
		if f.ends_with(".tres"):
			out.append(load(DIR + f) as EnemyDef)
	return out


func test_every_enemy_has_its_baked_model() -> void:
	for d in _defs():
		assert_true(ResourceLoader.exists("res://assets/baked/%s.res" % d.model), "%s draws %s" % [d.id, d.model])


func test_each_enemy_of_the_sheet_has_a_figure_of_its_own() -> void:
	var models := {}
	for id: StringName in SHEET_SIZE:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		assert_false(models.has(d.model), "%s shares its model %s" % [id, d.model])
		models[d.model] = true


func test_sizes_follow_the_sheet() -> void:
	for id: StringName in SHEET_SIZE:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		assert_almost_eq(d.size, float(SHEET_SIZE[id]), 0.001, String(id))
		if d.elite_version != &"":
			assert_almost_eq((load(DIR + "%s.tres" % d.elite_version) as EnemyDef).size, d.size, 0.001, "the elite is as big")


## The Meshy figures are painted, not coloured by a palette: the elite is the same baked model with its steel in old
## gold (EnemyDef.gild, crowd.gdshader), the faint edge and the armor bar.
func test_elites_are_the_same_figure_in_old_gold() -> void:
	for d in _defs():
		if d.elite_version == &"":
			continue
		var e: EnemyDef = load(DIR + "%s.tres" % d.elite_version)
		# (or its own bake of the same figure, "<model>_elite": the elite runner's longer stride, Lote 2B)
		if e.model != d.model:
			assert_eq(e.model, StringName(String(d.model) + "_elite"), "the elite of %s is the same figure" % d.id)
			var own: BakedModel = load("res://assets/baked/%s.res" % e.model)
			var common: BakedModel = load("res://assets/baked/%s.res" % d.model)
			assert_eq(own.vertices, common.vertices, "the elite of %s is the same mesh" % d.id)
			assert_almost_eq(own.height, common.height, 0.01, "the elite of %s as tall" % d.id)
		assert_gt(e.gild, 0.5, "the elite of %s wears old gold" % d.id)
		assert_eq(d.gild, 0.0, "the common %s does not" % d.id)
		assert_true(e.armor > 0.0, "the elite of %s keeps its armor bar" % d.id)
		assert_gt(e.rim, 0.0, "the elite of %s keeps its edge and outline" % d.id)


## Every enemy of the sheet is drawn by its Meshy model, made light for the crowd (tools/bake.gd, MeshSlim), at the
## height the KayKit figure it replaced stood idle (so EnemyDef.size, the bars and the warnings did not move).
const STANDING := {
	&"skeleton": 1.92, &"runner": 1.65, &"mage": 1.92, &"archer": 1.92, &"guard": 2.03, &"priest": 1.93,
	&"knight": 2.03, &"priest_elder": 2.07, &"morvath": 2.02,
}


func test_the_figures_are_the_painted_models_made_light() -> void:
	for id: StringName in SHEET_SIZE:
		var baked: BakedModel = load("res://assets/baked/%s.res" % id)
		assert_true(baked.painted, "%s is a painted figure" % id)
		assert_not_null(baked.albedo, "%s carries its own texture" % id)
		var idle: Mesh = baked.mesh
		var triangles := (idle.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		assert_between(triangles, 2000, 6000, "%s: light enough for a crowd of hundreds (%d)" % [id, triangles])
		assert_almost_eq(baked.height, float(STANDING[id]), 0.011, "%s stands as tall as before" % id)
		# what it holds may stand taller than its head (a staff), never the body by much
		assert_between(idle.get_aabb().end.y, baked.height - 0.05, baked.height + 0.9, "%s: the baked body is that tall" % id)
		assert_almost_eq(idle.get_aabb().position.y, 0.0, 0.12, "%s has its feet on the floor" % id)


## Every animation the horde and Morvath ask for is baked (a missing one falls back to the walk without a word).
func test_every_animation_the_game_asks_for_is_baked() -> void:
	var common: Array[StringName] = [&"walk", &"idle", &"attack", &"hit", &"death", &"rise"]
	var more := {
		&"runner": [&"windup"], &"mage": [&"cast", &"cast_hold", &"shot", &"exit"], &"priest": [&"cast", &"shot"],
		&"priest_elder": [&"cast", &"cast_hold", &"summon"], &"archer": [&"aim"],
		# cycle 7: the soldier raises its blade before it lunges, the brute braces behind its shield before it charges;
		# T5: the knight too, both run their charge and sag after it
		&"skeleton": [&"windup", &"strafe_l", &"strafe_r", &"back"], &"guard": [&"brace", &"charge", &"recover"],
		&"knight": [&"brace", &"charge", &"recover"],
		&"morvath": [&"slash1", &"slash2", &"slash3", &"dash_windup", &"blades_windup", &"dash", &"summon", &"rain", &"volley", &"roar", &"stunned"],
	}
	for id: StringName in SHEET_SIZE:
		var baked: BakedModel = load("res://assets/baked/%s.res" % id)
		for anim: StringName in common + Array(more.get(id, []), TYPE_STRING_NAME, &"", null):
			assert_gt(baked.frame_count(anim), 0, "%s: %s" % [id, anim])
	# the rise fits the time the horde gives it
	assert_almost_eq((load("res://assets/baked/skeleton.res") as BakedModel).duration(&"rise"), 0.9, 0.01)
	# T5-01: every wind-up clip is one gesture (never a loop: a loop held still is what the PO saw), armed by
	# Horde.windup_arm over the wind-up whatever its length; the archer's aim is the loop it holds the crossbow in
	for id: StringName in [&"skeleton", &"runner", &"mage", &"guard", &"priest", &"knight", &"priest_elder"]:
		var baked: BakedModel = load("res://assets/baked/%s.res" % id)
		for clip: StringName in [&"windup", &"cast", &"brace", &"summon"]:
			if baked.frame_count(clip) > 0:
				assert_false(baked.loops.get(clip, false), "%s %s is one gesture" % [id, clip])


## The renderer draws a painted figure by its own texture and passes the elite's gold on.
func test_the_renderer_gilds_the_elite_of_a_painted_figure() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var common: EnemyDef = load(DIR + "guard.tres")
	var elite: EnemyDef = load(DIR + "guard_elite.tres")
	renderer.register(common)
	renderer.register(elite)
	var plain: ShaderMaterial = renderer._materials[common.id]
	var gilded: ShaderMaterial = renderer._materials[elite.id]
	assert_eq(plain.get_shader_parameter(&"albedo"), renderer.model(&"guard").albedo)
	assert_eq(gilded.get_shader_parameter(&"albedo"), plain.get_shader_parameter(&"albedo"), "the same painting")
	assert_eq(plain.get_shader_parameter(&"gild"), 0.0)
	assert_almost_eq(float(gilded.get_shader_parameter(&"gild")), elite.gild, 0.001)
	assert_gt(float(plain.get_shader_parameter(&"paint_glow")), 0.0, "eyes and gems of the painting glow")
	assert_not_null(gilded.next_pass, "the elite keeps its thin dark outline")
	assert_null(plain.next_pass)


func test_magic_colours() -> void:
	var mage: EnemyDef = load(DIR + "mage.tres")
	var priest: EnemyDef = load(DIR + "priest.tres")
	var archer: EnemyDef = load(DIR + "archer.tres")
	# vfx_pass_spec.md 4 and 5.4 (V-11, Lote 1): the magic of the dead is the danger's, crimson for the bolt and the
	# burst, sickly green for the orbs and the vines (sweep 2026-11-25: magenta had no owner in the palette; violet is Morvath's)
	assert_true(mage.magic_color.g > mage.magic_color.r and mage.magic_color.g > mage.magic_color.b, "the sorcerer's sickly green")
	assert_eq(mage.magic_color, priest.magic_color, "the orbs and the vines one green")
	assert_true(archer.magic_color.r > archer.magic_color.g and archer.magic_color.g > archer.magic_color.b, "orange bolts (C1)")


## Cycle 5 (docs/art/cycle5_spec.md A1): the figure is costume, so its gold is old and calm; yellow on the screen
## is left for the armor bar. Elites and guardians read by their trims and the bar, with a faint edge (no halo);
## Morvath keeps an edge of his own purple.
func test_gold_is_old_gold_and_the_edges_are_faint() -> void:
	for id: String in ["skeleton_elite", "knight", "priest_elder", "morvath"]:
		var d: EnemyDef = load(DIR + "%s.tres" % id)
		assert_lt(d.rim, 0.35, "%s: a faint edge, not a halo" % id)
		assert_lt(d.rim_color.get_luminance(), 0.55, "%s: the edge is not a bright gold" % id)
	var morvath: EnemyDef = load(DIR + "morvath.tres")
	assert_true(morvath.rim_color.b > morvath.rim_color.r and morvath.rim_color.r > morvath.rim_color.g, "his own purple")
	# the old gold cell of the palettes (tools/make_palettes.gd, 25) is not a saturated yellow
	var img := (load("res://assets/models/palettes/priest_elder.png") as Texture2D).get_image()
	img.decompress()
	var cell := 25
	var px := Vector2i(int((cell % 8 + 0.5) * img.get_width() / 8.0), int((cell / 8 + 0.1) * img.get_height() / 4.0))
	var gold := img.get_pixelv(px)
	assert_lt(gold.s, 0.55, "old gold, not yellow: %s" % gold.to_html(false))
	assert_between(gold.h * 360.0, 25.0, 50.0, "still gold")
