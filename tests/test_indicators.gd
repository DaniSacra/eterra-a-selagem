extends GutTest
## Cycle 8, each enemy read on its own (4 to 20 in a room): the life bars (pale trail, armor in its own strip, the
## elite's frame, the nearest drawn last), the wind-ups that peak just before the blow, the recoil of a blow, the
## warnings' look, and the HUD's recharge level. All of it only drawn.

const DIR := "res://data/enemies/"


func _def(id: StringName) -> EnemyDef:
	return load(DIR + "%s.tres" % id)


func _enemy(id: StringName, at := Vector2.ZERO) -> Enemy:
	var e := Enemy.new()
	e.def = _def(id)
	e.pos = at
	e.dir = Vector2.DOWN
	e.aim = Vector2.DOWN
	return e


func _renderer() -> CrowdRenderer:
	var r := CrowdRenderer.new()
	add_child_autofree(r)
	return r


# ---------- the pale trail on a bar ----------

func test_a_trail_holds_what_a_blow_took_then_drains() -> void:
	var t := BarTrails.new()
	var who := RefCounted.new()
	assert_eq(t.shown(who, 1.0, 0.0), 1.0, "nothing lost, no trail")
	assert_eq(t.shown(who, 0.6, 1.0), 1.0, "the trail starts where the bar was")
	assert_eq(t.shown(who, 0.6, 1.0 + BarTrails.HOLD * 0.9), 1.0, "and holds a moment")
	assert_between(t.shown(who, 0.6, 1.0 + BarTrails.HOLD + BarTrails.DRAIN * 0.5), 0.61, 0.99, "then drains")
	assert_almost_eq(t.shown(who, 0.6, 1.0 + BarTrails.HOLD + BarTrails.DRAIN), 0.6, 0.001, "down to the life")
	assert_lte(BarTrails.HOLD + BarTrails.DRAIN, 0.6, "short: the bar is not a second number")


func test_a_second_blow_keeps_the_older_trail_and_healing_leaves_none() -> void:
	var t := BarTrails.new()
	var who := RefCounted.new()
	t.shown(who, 1.0, 0.0)
	t.shown(who, 0.7, 0.1)
	assert_eq(t.shown(who, 0.4, 0.15), 1.0, "from where the first blow found it")
	t.shown(who, 0.4, 5.0)
	assert_eq(t.shown(who, 0.8, 5.1), 0.8, "a gain leaves no trail")


func test_trails_of_the_dead_are_forgotten() -> void:
	var t := BarTrails.new()
	var a := _enemy(&"skeleton")
	var b := _enemy(&"skeleton")
	t.shown(a, 1.0, 0.0)
	t.shown(b, 1.0, 0.0)
	b.alive = false
	t.prune(func(who: Object) -> bool: return (who as Enemy).alive)
	assert_eq(t.size(), 1)


# ---------- the bar itself ----------

func test_armor_has_its_own_strip_and_the_top_edge_stays() -> void:
	var r := _renderer()
	var d := _def(&"guard_elite")
	r.begin()
	r.add_bar(d, Vector3.ZERO, 0.5, 0.0)
	r.add_bar(d, Vector3.ZERO, 0.5, 0.6)
	var data := r._bars.data
	var per := CrowdRenderer.FLOATS
	var plain_h := data[5]
	var armored_h := data[per + 5]
	assert_almost_eq(armored_h, plain_h + CrowdRenderer.BAR_ARMOR_HEIGHT, 0.0001, "taller by the armor's strip")
	assert_almost_eq(data[per + 7] + armored_h * 0.5, data[7] + plain_h * 0.5, 0.0001, "it grows down: the top edge is where it was")
	assert_almost_eq(data[per + 13], 0.6, 0.0001, "the armor left")
	assert_almost_eq(data[per + 12], 0.5, 0.0001, "and the life whole beside it")


func test_the_damage_numbers_start_clear_of_any_bar() -> void:
	var top := CrowdRenderer.BAR_ABOVE + CrowdRenderer.BAR_HEIGHT * 0.5
	assert_gte(Fx.NUMBER_LIFT - top, 0.55)
	assert_lte(CrowdRenderer.BAR_HEIGHT, 0.2)


func test_an_elite_bar_has_a_frame_of_its_own_and_is_wider() -> void:
	var r := _renderer()
	var plain := _def(&"skeleton")
	var elite := _def(&"skeleton_elite")
	r.begin()
	r.add_bar(plain, Vector3.ZERO, 1.0, 0.0)
	r.add_bar(elite, Vector3.ZERO, 1.0, 0.0)
	r.add_bar(elite, Vector3.ZERO, 1.0, 0.0, true)
	var data := r._bars.data
	var per := CrowdRenderer.FLOATS
	assert_almost_eq(data[14], 1.0, 0.0001, "plain: opacity only")
	assert_almost_eq(data[per + 14], 3.0, 0.0001, "elite: 2 + its opacity (the shader reads > 1.5 as elite)")
	assert_almost_eq(data[2 * per + 14] - 2.0, CrowdRenderer.BAR_CROWD_FADE, 0.0001, "and still fades on a full floor")
	assert_almost_eq(data[per], data[0] * CrowdRenderer.BAR_ELITE_WIDTH, 0.0001)


func test_the_trail_never_reads_below_the_life() -> void:
	var r := _renderer()
	r.begin()
	r.add_bar(_def(&"skeleton"), Vector3.ZERO, 0.7, 0.0, false, 0.2)
	r.add_bar(_def(&"skeleton"), Vector3.ZERO, 0.7, 0.0, false, 0.9)
	assert_almost_eq(r._bars.data[15], 0.7, 0.0001)
	assert_almost_eq(r._bars.data[CrowdRenderer.FLOATS + 15], 0.9, 0.0001)


func test_the_nearest_bar_is_drawn_last() -> void:
	var r := _renderer()
	var d := _def(&"skeleton")
	r.begin()
	# the camera looks toward -z: the bar at z = 5 is the nearest
	for z: float in [5.0, -3.0, 1.0]:
		r.add_bar(d, Vector3(0, 2, z), z * 0.1 + 0.5, 0.0)
	r.sort_bars(Vector3(0, 0, -1))
	var per := CrowdRenderer.FLOATS
	var order: Array[float] = []
	for i in 3:
		order.append(r._bars.data[i * per + 11])
	assert_eq(order, [-3.0, 1.0, 5.0] as Array[float], "far to near")
	assert_almost_eq(r._bars.data[2 * per + 12], 1.0, 0.0001, "each bar keeps its own life")


func test_every_enemy_of_a_room_shows_its_bar() -> void:
	assert_gte(Horde.BARS_FOR_ALL, 20, "a room holds up to 20 at once")
	var horde := Horde.new()
	add_child_autofree(horde)
	for i in 20:
		horde.spawn(_def(&"skeleton"), Vector2(i, 0), false)
	horde.render()
	assert_eq(horde.renderer._bars.count, 20, "fresh or hurt, each one shows its life")


# ---------- the recoil of a blow ----------

func test_a_blow_tips_the_body_back_away_from_where_it_faces() -> void:
	var horde := Horde.new()
	add_child_autofree(horde)
	var e := horde.spawn(_def(&"skeleton"), Vector2.ZERO, false)
	e.state = Enemy.State.WALK
	e.anim = &"walk"
	e.anim_t = 0.0
	e.dir = Vector2.DOWN  # faces +z
	e.flash_t = Horde.FLASH_TIME
	e.flash_power = 1.0
	var pos := e.pos
	horde.render()
	# (E1c: standing still it is drawn idle, the drawing follows the body)
	var clip: CrowdRenderer.Clip = horde.renderer._clip(horde.renderer.kind(e.def), e.drawn_anim)
	var data := clip.batch.data
	assert_lt(data[9], 0.0, "the body's up leans toward -z, away from its front")
	assert_eq(e.pos, pos, "only drawn")
	e.absorbed = true
	horde.render()
	assert_almost_eq(clip.batch.data[9], 0.0, 0.0001, "armor takes it: the body does not give")


# ---------- the wind-ups ----------

func test_the_cue_peaks_just_before_the_blow_and_is_gone_when_it_lands() -> void:
	assert_eq(EnemyFx.ramp(0.3, 0.45, 0.85), 0.0)
	assert_almost_eq(EnemyFx.ramp(0.88, 0.45, 0.85), 1.0, 0.001, "fullest just before the blow")
	assert_eq(EnemyFx.ramp(1.0, 0.45, 0.85), 0.0)
	assert_gt(EnemyFx.ramp(0.9, 0.45, 0.85), EnemyFx.ramp(0.6, 0.45, 0.85), "it grows toward the blow")


func test_the_bolt_is_drawn_back_along_its_aim() -> void:
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	var e := _enemy(&"archer", Vector2(2, 3))
	e.aim = Vector2.RIGHT
	fx.begin()
	fx.tell(e, EnemyFx.BOW_FROM * 0.5)
	assert_eq(fx.count, 0, "nothing at first")
	fx.begin()
	fx.tell(e, 0.9)
	var streaks := fx.put().filter(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.STREAK)
	# LC-1: the crossbow drawn in light (its bow across and its bolt) and the sight ahead of its tip
	assert_eq(streaks.size(), 3)
	var tip := EnemyFx.anchor(e.pos, e.y, e.yaw(), e.def.size, e.def.tell_at)
	var sight: Array = streaks[2]
	assert_gt((sight[1] as Vector3).x, tip.x + 1.0, "ahead of the bolt's tip, the way it flies")
	assert_almost_eq((sight[1] as Vector3).z, tip.z, EnemyFx.BOW_TIP * e.def.size + 0.01, "along its aim, from the tip of the crossbow")


func test_the_shield_reads_early_in_a_long_charge() -> void:
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	fx.begin()
	fx.tell(_enemy(&"guard"), 0.5)
	assert_gt(fx.count, 0, "half way through the charge's wind-up the shield already gleams")


# ---------- the floor's warnings ----------

func test_a_line_warning_knows_its_length_and_lies_along_the_blow() -> void:
	var node := GroundLook.new_node()
	add_child_autofree(node)
	GroundLook.warning(node, GroundLook.Shape.LINE, Vector2(1, 2), Vector2.RIGHT, 6.0, 1.3, 0.06)
	var m := node.material_override as ShaderMaterial
	assert_almost_eq(float(m.get_shader_parameter(&"length_m")), 6.0, 0.0001)
	assert_almost_eq(node.position, Vector3(4, 0.06, 2), Vector3.ONE * 0.0001, "its middle half way along")
	assert_eq(int(m.get_shader_parameter(&"shape")), GroundLook.Shape.LINE)
	assert_eq(GroundLook.Shape.LINE, Ground.Shape.LINE as int, "the same shapes as Ground")
	assert_eq(GroundLook.Shape.ARC, Ground.Shape.ARC as int)
	assert_eq(Ground.COLORS[Ground.Kind.WARNING], GroundLook.WARNING_COLOR)


# ---------- the HUD's recharge ----------

func test_the_recharge_level_rises_from_the_bottom() -> void:
	var c := Vector2(50, 50)
	var empty := ActionSlot.band(c, 20.0, 1.0, 1.0)
	assert_eq(empty.size(), 0, "nothing back yet")
	var half := ActionSlot.band(c, 20.0, 0.5, 1.0)
	assert_eq(half.size(), 1)
	for p in half[0]:
		assert_gte(p.y, 50.0 - 0.001, "the lower half")
	assert_almost_eq(_area(half[0]), 20.0 * 20.0, 0.5, "half the diamond (2 r^2 / 2)")


func test_someone_behind_fades_only_the_body() -> void:
	var s := ActionSlot.new().setup(&"cast", Boon.Slot.CAST)
	add_child_autofree(s)
	s.veil = 1.0
	assert_eq(s.modulate.a, 1.0, "the glyph, the recharge and the key stay whole")
	assert_lt(ActionSlot.SEE_THROUGH, 0.6)


static func _area(poly: PackedVector2Array) -> float:
	var twice := 0.0
	for i in poly.size():
		twice += poly[i].cross(poly[(i + 1) % poly.size()])
	return absf(twice) * 0.5


func test_the_elite_frame_is_the_hud_old_gold() -> void:
	assert_eq(CrowdRenderer.BAR_ELITE_FRAME, UiKit.OLD_GOLD)
