extends GutTest
## The black and white impact frame (BUG-001, decision D-08 of cycle 10): only an Omega that lands and the blow that
## ends a boss's phase flash it, at most one every Feel.impact_frame_every seconds, and never with the option off.

const TREE := "res://data/combos/paladin.tres"

var horde: Horde
var fx: Fx
var combat: Combat
var tree: ComboTree


func before_each() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 30, 30)
	add_child_autofree(camera)
	camera.look_at(Vector3.ZERO)
	var overlay := Control.new()
	add_child_autofree(overlay)
	fx = Fx.new()
	add_child_autofree(fx)
	fx.setup(camera, overlay)
	horde = Horde.new()
	add_child_autofree(horde)
	horde.fx = fx
	var ground := Ground.new()
	add_child_autofree(ground)
	ground.horde = horde
	ground.fx = fx
	var projectiles := Projectiles.new()
	add_child_autofree(projectiles)
	projectiles.horde = horde
	projectiles.fx = fx
	combat = Combat.new()
	combat.horde = horde
	combat.fx = fx
	combat.ground = ground
	combat.projectiles = projectiles
	combat.boons = BoonState.new()
	tree = load(TREE)


func _node(id: StringName) -> ComboNode:
	for n in tree.all_nodes():
		if n.id == id:
			return n
	return null


func _crowd(n: int) -> void:
	for i in n:
		horde.spawn(horde.def(&"skeleton"), Vector2.from_angle(i * TAU / n) * 1.5, false)


func test_the_data_keeps_a_cooldown() -> void:
	assert_gte(Feel.live().impact_frame_every, 10.0, "at most one impact frame every 10 s")
	assert_gt(Feel.live().impact_frame, 0.0)


func test_a_finisher_into_a_crowd_has_none() -> void:
	_crowd(10)
	combat.strike(_node(&"cut3"), Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0, "a finisher is no Omega")


func test_an_omega_that_lands_flashes_once_per_cooldown() -> void:
	var lance := _node(&"lance")
	combat.strike(lance, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0, "an Omega into the air: nothing")
	_crowd(6)
	combat.strike(lance, Vector2.ZERO, Vector2.RIGHT)
	assert_gt(fx.frame_left, 0.0, "an Omega that lands")
	fx.frame_left = 0.0
	combat.step(Feel.live().impact_frame_every * 0.5)
	_crowd(6)  # (the first Omega felled them)
	combat.strike(lance, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0, "a second one inside the cooldown")
	combat.step(Feel.live().impact_frame_every * 0.5 + 0.01)
	_crowd(6)
	combat.strike(lance, Vector2.ZERO, Vector2.RIGHT)
	assert_gt(fx.frame_left, 0.0, "after the cooldown")


func test_the_blow_that_ends_a_phase_flashes() -> void:
	var boss := horde.spawn(horde.def(&"morvath"), Vector2(1.5, 0.0), false)
	boss.armor = 0.0
	boss.hp = boss.max_hp * 0.7
	boss.hp_floor = boss.max_hp * 0.66
	combat.strike(_node(&"cut1"), Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0, "a blow that leaves him above the floor")
	boss.hp = boss.hp_floor + 1.0
	combat.strike(_node(&"cut1"), Vector2.ZERO, Vector2.RIGHT)
	assert_eq(boss.hp, boss.hp_floor)
	assert_gt(fx.frame_left, 0.0, "the blow that ends his phase")


func test_none_on_a_ward() -> void:
	var boss := horde.spawn(horde.def(&"morvath"), Vector2(1.5, 0.0), false)
	boss.invulnerable = true
	combat.strike(_node(&"lance"), Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0, "an Omega on his ritual shield only sparks")


func test_the_option_turns_it_off() -> void:
	fx.impact_frames = false
	_crowd(6)
	combat.strike(_node(&"lance"), Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.frame_left, 0.0)


func test_the_save_has_the_option_on_by_default() -> void:
	assert_true(SaveData.defaults().options.impact_frames)
	var old := {"options": {"shake": false}}
	assert_true(SaveData.merged(old).options.impact_frames, "an older save gets it on")
	assert_false(SaveData.merged({"options": {"impact_frames": false}}).options.impact_frames, "kept off when saved off")
