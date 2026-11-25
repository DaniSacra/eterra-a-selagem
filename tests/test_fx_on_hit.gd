extends GutTest
## The effects of a blow landing only exist when a blow really lands (cycle 7, docs/art/cycle7_spec.md 2.4): a swing
## that reaches nobody shows its own arc and motes and nothing else: no cut, no chips, no number, no jolt of the
## camera, no shake, no hit stop, no colour split, no impact frame.

const TREE := "res://data/combos/paladin.tres"

var horde: Horde
var fx: Fx
var combat: Combat


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


func _moves() -> Array[ComboNode]:
	var out: Array[ComboNode] = []
	for node in (load(TREE) as ComboTree).all_nodes():
		if node.damage > 0.0:
			out.append(node)
	return out


func _node(shape: ComboNode.Shape, tags: Array[StringName]) -> ComboNode:
	var node := ComboNode.new()
	node.shape = shape
	node.reach = 5.0
	node.width = 150.0 if shape == ComboNode.Shape.ARC else 1.6
	node.damage = 1.0
	node.hit_stop_ms = 40.0
	node.shake = 1.0
	node.tags = tags
	return node


func _assert_no_hit_effects(what: String, swing_motes: int) -> void:
	assert_eq(fx.showing(&"gashes"), 0, "%s: no cut" % what)
	assert_eq(fx.showing(&"numbers"), 0, "%s: no number" % what)
	assert_lte(fx.showing(&"motes"), swing_motes, "%s: no chips, only the motes of the swing" % what)
	assert_eq(fx.stop_left, 0.0, "%s: no hit stop" % what)
	assert_eq(fx.split, 0.0, "%s: no colour split" % what)
	assert_eq(fx.frame_left, 0.0, "%s: no impact frame" % what)
	assert_eq(fx.tick(0.0), Vector3.ZERO, "%s: no jolt and no shake of the camera" % what)


func test_the_tree_has_moves_to_check() -> void:
	assert_gt(_moves().size(), 3)


func test_a_swing_in_the_air_shows_no_hit() -> void:
	for node in _moves():
		before_each()
		combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
		var ways := 2 if node.both_ways else 1
		# (2026-11-24: the Brado's shock throws up to SHOCK_CHIPS.y stones and the Investida's trail 6 slivers)
		_assert_no_hit_effects(String(node.id), Combat.SWING_MOTES.y * ways + Fx.SHOCK_CHIPS.y)
		if node.shape != ComboNode.Shape.CIRCLE:
			assert_eq(fx.showing(&"rings"), 0, "%s: no ring" % node.id)
		assert_eq(combat.combo, 0, "%s: no blow counted" % node.id)


func test_an_enemy_out_of_reach_shows_no_hit() -> void:
	var node := _node(ComboNode.Shape.ARC, [&"light", &"finisher"])
	var far := horde.spawn(horde.def(&"skeleton"), Vector2(node.reach + 4.0, 0.0), false)
	var behind := horde.spawn(horde.def(&"skeleton"), Vector2(-2.0, 0.0), false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	_assert_no_hit_effects("out of reach", Combat.SWING_MOTES.y + Fx.ARC_SPARKS)
	assert_eq(fx.showing(&"rings"), 0, "no finisher ring")
	assert_eq(far.hp, far.max_hp)
	assert_eq(behind.hp, behind.max_hp)


func test_a_blow_that_lands_shows_the_hit_once_per_enemy() -> void:
	var node := _node(ComboNode.Shape.ARC, [&"light"])
	horde.spawn(horde.def(&"skeleton"), Vector2(2.0, 0.5), false)
	horde.spawn(horde.def(&"skeleton"), Vector2(2.0, -0.5), false)
	horde.spawn(horde.def(&"skeleton"), Vector2(node.reach + 4.0, 0.0), false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.showing(&"gashes"), 2, "one cut for each enemy reached")
	assert_eq(fx.showing(&"numbers"), 2, "one number for each")
	assert_gte(fx.showing(&"motes"), Combat.SWING_MOTES.x + 2 * Combat.GASH_CHIPS.x, "chips fly off both")
	assert_gt(fx.stop_left, 0.0, "hit stop")
	assert_ne(fx.tick(0.0), Vector3.ZERO, "the camera jolts")
	assert_eq(fx.split, 0.0, "the colour split is the finisher's")
	assert_eq(fx.showing(&"rings"), 0, "the ring is the finisher's")


func test_a_finisher_that_lands_adds_one_ring_and_a_mild_split() -> void:
	var node := _node(ComboNode.Shape.ARC, [&"light", &"finisher"])
	for i in 3:
		horde.spawn(horde.def(&"skeleton"), Vector2(2.0, i - 1.0), false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.showing(&"gashes"), 3)
	assert_eq(fx.showing(&"rings"), 3, "one ring and the shock's two for the blow, not one set for each enemy")
	assert_almost_eq(fx.split, Combat.FINISHER_SPLIT, 0.001)
	assert_lte(Combat.FINISHER_SPLIT, 0.5)


func test_a_crowd_gets_a_bounded_number_of_cuts() -> void:
	var node := _node(ComboNode.Shape.CIRCLE, [&"light"])
	for i in 20:
		horde.spawn(horde.def(&"skeleton"), Vector2.from_angle(i * TAU / 20.0) * 3.0, false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.showing(&"gashes"), Combat.MAX_STARS)
	assert_lte(fx.showing(&"motes"), Fx.MOTE_POOL)


func test_the_cut_follows_the_blade_so_opposite_sides_differ() -> void:
	var left := Combat.cut_axis(ComboNode.Shape.ARC, Vector2.ZERO, Vector2(3, 2), Vector2.RIGHT, false)
	var right := Combat.cut_axis(ComboNode.Shape.ARC, Vector2.ZERO, Vector2(3, -2), Vector2.RIGHT, false)
	assert_gt(absf(left.angle_to(right)), deg_to_rad(30.0), "two enemies on opposite sides of the arc are cut at different angles")
	assert_almost_eq(left.dot(Vector2(3, 2).normalized()), 0.0, 0.001, "across the line from the paladin")
	var flipped := Combat.cut_axis(ComboNode.Shape.ARC, Vector2.ZERO, Vector2(3, 2), Vector2.RIGHT, true)
	assert_almost_eq(flipped.dot(left), -1.0, 0.001, "the other sweep cuts the other way")
	assert_eq(Combat.cut_axis(ComboNode.Shape.LINE, Vector2.ZERO, Vector2(3, 2), Vector2.RIGHT, false), Vector2.RIGHT, "a thrust cuts along itself")


func test_number_colours_keep_emerald_for_the_big_blows() -> void:
	var plain: Array[StringName] = [&"light"]
	var omega: Array[StringName] = [&"light", &"omega"]
	var gift: Array[StringName] = [&"skill", &"luz"]
	var flame: Array[StringName] = [&"chama"]
	assert_eq(combat.number_color(plain, false), Combat.NUMBER_PALE, "a common blow: pale")
	assert_eq(combat.number_color(plain, true), Combat.EMETH, "a finisher: emerald")
	assert_eq(combat.number_color(omega, false), Combat.EMETH, "a held blow: emerald")
	assert_eq(combat.number_color(gift, false), Combat.LIGHT, "a gift of Elun: gold")
	assert_eq(combat.number_color(flame, true), Combat.FIRE, "fire stays fire")


func test_numbers_in_a_crowd_keep_only_the_biggest() -> void:
	for i in Fx.NUMBER_CROWD:
		fx.number(Vector3(i * 0.1, 2.0, 0.0), 10.0 + i, Color.WHITE)
	assert_eq(fx.showing(&"numbers"), Fx.NUMBER_CROWD)
	# each next hit in a frame of its own: within one frame, past NumberTally.GROUP_FROM they join one total
	await wait_process_frames(1)
	fx.number(Vector3(0.2, 2.0, 0.0), 5.0, Color.WHITE)
	assert_eq(fx.showing(&"numbers"), Fx.NUMBER_CROWD, "a smaller one does not show")
	assert_false(_shown().has("5"))
	await wait_process_frames(1)
	fx.number(Vector3(0.2, 2.0, 0.0), 99.0, Color.WHITE)
	assert_eq(fx.showing(&"numbers"), Fx.NUMBER_CROWD, "a bigger one takes the place of the smallest")
	assert_true(_shown().has("99"))
	assert_false(_shown().has("10"))
	await wait_process_frames(1)
	fx.number(Vector3(Fx.NUMBER_CROWD_RADIUS + 2.0, 2.0, 0.0), 1.0, Color.WHITE)
	assert_eq(fx.showing(&"numbers"), Fx.NUMBER_CROWD + 1, "far from the crowd every number shows")
	fx.word(Vector3(0.2, 2.0, 0.0), "x", Color.WHITE)
	assert_eq(fx.showing(&"numbers"), Fx.NUMBER_CROWD + 2, "words are not numbers")


func test_a_number_starts_clear_of_the_life_bar() -> void:
	# the bar sits BAR_ABOVE over the head and is BAR_HEIGHT tall; the number's middle starts NUMBER_LIFT over the head
	var bar_top := CrowdRenderer.BAR_ABOVE + CrowdRenderer.BAR_HEIGHT * 0.5
	assert_gte(Fx.NUMBER_LIFT - bar_top, 0.25 + 0.3, "a quarter of a meter above the bar, plus half the height of the digits")


func test_effects_end_on_their_own() -> void:
	var node := _node(ComboNode.Shape.ARC, [&"light", &"finisher"])
	horde.spawn(horde.def(&"skeleton"), Vector2(2.0, 0.0), false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	for i in 40:
		fx.animate(1.0 / 60.0)
	for kind: StringName in [&"gashes", &"motes", &"rings", &"crescents", &"thrusts"]:
		assert_eq(fx.showing(kind), 0, "%s gone in 0.6 s" % kind)
	for i in 30:
		fx.animate(1.0 / 60.0)
	assert_eq(fx.showing(&"slashes"), 0)
	assert_eq(fx.showing(&"numbers"), 0)


## Cycle 8: hits that follow each other on one enemy join one number that counts up.
func test_a_combo_on_one_enemy_shows_one_number_counting_up() -> void:
	var node := _node(ComboNode.Shape.ARC, [&"light"])
	horde.spawn(horde.def(&"skeleton"), Vector2(2.0, 0.0), false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	fx.animate(0.1)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	assert_eq(fx.showing(&"numbers"), 1, "one number for the one enemy")
	assert_true(_shown().has("2"), "the two hits added up")


## Cycle 8: what may start in one frame is bounded (FxBudget); the next frame has the whole budget again.
func test_effects_started_in_one_frame_are_bounded() -> void:
	var node := _node(ComboNode.Shape.CIRCLE, [&"light", &"finisher"])
	for i in 20:
		horde.spawn(horde.def(&"skeleton"), Vector2.from_angle(i * TAU / 20.0) * 3.0, false)
	combat.strike(node, Vector2.ZERO, Vector2.RIGHT)
	assert_lte(fx.showing(&"motes"), Fx.BUDGET_MOTES)
	assert_lte(fx.showing(&"gashes"), Fx.BUDGET_GASHES)
	assert_lte(fx.showing(&"numbers"), NumberTally.MAX_SHOWN)
	var before := fx.showing(&"motes")
	fx.chips(Vector3.ZERO, Vector3.UP, Color.WHITE, 10)
	assert_eq(fx.showing(&"motes"), before, "nothing more this frame")
	fx.animate(0.0)
	fx.chips(Vector3.ZERO, Vector3.UP, Color.WHITE, 10)
	assert_eq(fx.showing(&"motes"), before + 10, "a new frame")


## Cycle 8 (B4): a struck enemy is its own body lighter and warmer; the ivory of a strong blow lasts one frame at
## most and nothing it adds passes the glow threshold (no ball of light over the paladin).
func test_the_hit_flash_never_blooms_and_its_ivory_is_one_frame() -> void:
	var code: String = load("res://assets/shaders/crowd.gdshader").code
	assert_false(code.contains("EMISSION = vec3(3.0)"), "no flat white body")
	var white_from := _uniform(code, "white_from")
	assert_lte(Horde.FLASH_TIME * (1.0 - white_from), 1.0 / 30.0 + 0.001, "ivory for one frame at most")
	assert_lt(_uniform(code, "flash_cap"), Game.GLOW_THRESHOLD, "under the glow threshold")
	assert_lt(_uniform(code, "flash_white"), 0.5, "the ivory keeps the body's shading")


func _uniform(code: String, name: String) -> float:
	var re := RegEx.create_from_string("uniform float %s = ([0-9.]+);" % name)
	var m := re.search(code)
	assert_not_null(m, name)
	return float(m.get_string(1)) if m else 0.0


func _shown() -> Dictionary:
	var out := {}
	for l in fx._labels:
		if l.visible:
			out[l.text] = true
	return out


func test_tick_numbers_are_never_grey_nor_dim() -> void:
	var grey := Fx.tick_color(Color(0.62, 0.62, 0.66))
	assert_gte(grey.s, Fx.TICK_MIN_SAT, "grey takes a family colour")
	for c: Color in [Color(0.62, 0.62, 0.66), Color(0.3, 0.1, 0.05), Color(1.0, 0.5, 0.2)]:
		assert_gte(Fx.tick_color(c).v, Fx.TICK_VALUE, "value at least 0.75")
	assert_eq(Fx.tick_color(Color(1.0, 0.5, 0.2)).h, Color(1.0, 0.5, 0.2).h, "a family colour keeps its hue")
	assert_gte(ceili(Fx.NUMBER_BIG * Fx.TICK_SHARE), 17, "a tick is 70% of a big number at least")


func test_hit_lights_are_capped_and_fade() -> void:
	for i in 10:
		fx.hit_light(Vector3(i, 1, 0), Color.WHITE, 2.0)
	var lit := 0
	for n in fx.get_children():
		if n is OmniLight3D and (n as OmniLight3D).visible:
			lit += 1
	assert_lte(lit, Fx.LIGHT_POOL, "never more than the pool lit")
	fx.animate(1.0)
	for n in fx.get_children():
		if n is OmniLight3D:
			assert_false((n as OmniLight3D).visible, "a hit light is gone after its time")


func test_plain_contact_lights_and_sparks_at_the_target() -> void:
	var at := Vector3(3.0, 1.0, 2.0)
	fx.contact(at, Vector3.RIGHT, Color(0.2, 1.0, 0.5), false, 1)
	var best := 0.0
	for n in fx.get_children():
		if n is OmniLight3D and (n as OmniLight3D).visible:
			best = maxf(best, (n as OmniLight3D).light_energy)
			assert_eq((n as OmniLight3D).position, at, "the light is on the one struck")
	assert_almost_eq(best, Fx.CONTACT_LIGHT[1], 0.01, "blow 2 lights it 1.4")
	assert_gt(fx.showing(&"motes"), 0, "slivers fly from it")


func test_brado_echo_ring_comes_later() -> void:
	fx.ring_later(Vector2.ZERO, 3.0, Color.WHITE, 0.08)
	assert_eq(fx.showing(&"rings"), 0, "not yet")
	fx.animate(0.1)
	assert_eq(fx.showing(&"rings"), 1, "the second ring after its wait")
