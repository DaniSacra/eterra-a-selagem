class_name Player
extends Node3D
## The paladin. Moves on the floor plane (pos is (x, z) in meters), rolls out of danger, and fights with the combo
## tree: the ComboRunner decides which move comes next, this node plays it (animation; every blow is struck standing
## still, only the dash attack carries him) and reports when it lands.

signal struck(node: ComboNode, origin: Vector2, dir: Vector2)
## A finisher holds at the top of its swing for time seconds before it lands.
signal glinted(node: ComboNode, origin: Vector2, dir: Vector2, time: float, tip: Node3D)
signal move_shown(node: ComboNode)
signal was_hurt(amount: float)
signal died
signal dodged(dir: Vector2)
signal shield_broke
## Ainda de Pé stood him up from a fall (once a descent).
signal rose
## The circle of light (cast) is let go at a point; omega: it was held and paid for, so it bursts at the end.
signal cast_released(at: Vector2, omega: bool)
## The ultimate's protected gesture begins (its charge is spent now) and, gesture seconds later, its blow lands
## (Ultimates plays both; dir: where he faces, the aim at the press).
signal ult_started(dir: Vector2)
signal ult_landed(dir: Vector2)
## The ultimate's button was pressed while it cannot go (none this descent, or its charge not full): the HUD says why
## (T5: "a ultimate não funciona" was a press that did nothing and told nothing).
signal ult_refused

## ULT: the ultimate's gesture (UltDef.gesture), protected, planted, the runner locked as in the roll.
enum State { MOVE, DODGE, HURT, DEAD, REST, ULT }

## The body on the floor (meters): every collision and every enemy's reach is measured with it (kept a constant, it
## is read in constant expressions; the hero's other numbers are HeroDef's).
const RADIUS := 0.5
## How fast the drawn body turns to where he faces, as in Hades II (1340 degrees a second: 180 in 8 frames); the way
## he faces turns at once (GF-09). A swing turns the body faster (TURN_SWING, a share per second).
const TURN_BODY := deg_to_rad(1340.0)
const TURN_SWING := 30.0
## A press of the dodge while he cannot move (the stagger, the roll) waits this long once he can (GF-02). Without a
## charge left a press does nothing, as in Hades II.
const DODGE_BUFFER := 0.15
## The Omega's charge sound starts once the button has been held this long (a tap plays none).
const CHARGE_SOUND_AT := 0.12
## Meters per second the run and sprint clips cover at their own speed (tools/bake_hero.gd measures them), so the
## clips play as fast as the paladin moves and the feet keep up.
const RUN_CLIP_PACE := 8.7
const SPRINT_CLIP_PACE := 13.0
## The dash clip (0.6 s of a low lunge) squeezed into the 0.2 s dodge, with its end blending into the run.
const DASH_CLIP_SPEED := 2.4
## How fast the swing animation creeps while a finisher holds its glint (it lands when the hold ends).
const GLINT_ANIM_SPEED := 0.15
## Soft lock: a swing without a clear aim turns (never steps) to the closest enemy within this distance and
## ASSIST_HALF_ARC of where he faces (Hades II's AutoLock: 4.9 to 6.1 m, an arc of 130 degrees).
const ASSIST_RANGE := 5.0
const ASSIST_HALF_ARC := deg_to_rad(65.0)
const LOOPS: Array[StringName] = [&"Idle", &"Run", &"Sprint"]
const FLASH := preload("res://assets/shaders/flash.gdshader")
const XRAY := preload("res://assets/shaders/xray.gdshader")
const XRAY_BEHIND := preload("res://assets/shaders/xray_behind.gdshader")
const XRAY_DEPTH := preload("res://assets/shaders/xray_depth.gdshader")
const XRAY_EDGE := preload("res://assets/shaders/xray_edge.gdshader")
const RING := preload("res://assets/shaders/hero_ring.gdshader")
const RING_THROUGH_SHADER := preload("res://assets/shaders/hero_ring_through.gdshader")
## The paladin through a crowd (docs/art/cycle5_spec.md A2; QA M4; docs/art/cycle7_spec.md 3.2): where enemies cover
## him he shows as his own body, lit like it (xray.gdshader and its two helper passes), drawn after everything else
## in this order: his depth, his colours, the rim (the enemies' life bars are at CrowdRenderer's priority 10).
## The covered body at XRAY_OPACITY with its shadows lifted by XRAY_FLOOR (light added in the painting's own hue)
## and XRAY_LIGHT more of his painting shown as light, so he is a step brighter than the pack in front of him;
## Emeth's blade at XRAY_BLADE_OPACITY with the light it has uncovered; around them a hair of ivory, XRAY_RIM_WIDTH
## pixels on a 941 line screen (never cyan, never a thick white outline).
## Behind stone (an obelisk, a balustrade: wherever the crowd did not draw, by the stencil crowd.gdshader writes) the
## same body shows XRAY_BEHIND_SHARE times as opaque, without the extra light and with its shadows lifted only by
## XRAY_BEHIND_FLOOR, and the ring is hidden: with the rim he reads as behind the stone, not standing on top of it
## (cycle 8, B3 of the cycle 7 review; xray_behind.gdshader).
const XRAY_PRIORITY := 11
const XRAY_OPACITY := 0.85
const XRAY_BLADE_OPACITY := 0.8
const XRAY_FLOOR := 0.25
const XRAY_LIGHT := 0.45
const XRAY_RIM := Color(0.96, 0.9, 0.78, 0.5)
const XRAY_RIM_WIDTH := 1.5
const XRAY_BEHIND_SHARE := 0.45
const XRAY_BEHIND_FLOOR := 0.1
## A thin ring on the floor at his feet, in the petrol of his scarf (never the red of a warning): meters across,
## the colour, how opaque on the open floor and through what stands over it. The side he faces is a wedge
## RING_WEDGE degrees wide and RING_WEDGE_GAIN times brighter: the ring says where he looks.
const RING_SIZE := 2.1
const RING_COLOR := Color("3e9094")
const RING_OPEN := 0.35
const RING_THROUGH := 0.75
const RING_WEDGE := 30.0
const RING_WEDGE_GAIN := 1.4
## The painted light on his shoulders and hair, from the top left of the screen like the crowd's key
## (crowd.gdshader): it lifts him off the pack, covered or not. Alpha is the gain (0.3 since cycle 8: a step more,
## so the red hair and the petrol scarf catch the eye first in a fight of 8 to 20; never a glow).
const KEY_LIGHT := Color(1.0, 0.93, 0.8, 0.3)
const OUTLINE := Color(1.0, 0.78, 0.35)
## The thin edge on his body and his silhouette through what hides him: cold and light, never gold over the body
## (docs/art/cycle4_spec.md, c).
const EDGE := Color(0.75, 0.9, 1.0)
## The dark blot under his feet, as under every figure of the reference painting: meters across and deep, opacity.
const CONTACT_SHADOW := Vector2(1.2, 0.8)
const CONTACT_SHADOW_ALPHA := 0.5
## The look of his state on the body (flash.gdshader), kept small so he reads as the explorer in the fight
## (Daniel's capture of 2026-11-14 showed him all gold or white; a white body is how a struck enemy looks): a hit
## flashes him for HURT_FLASH seconds, then, while he is safe, his own colours go HURT_LIGHTEN lighter and back every
## BLINK_PERIOD seconds (only after a hit, not after a dodge or a cast), never white. BODY_LIGHT is about how much
## light his body gets in the game, which turns that share into the painting shown as light (HeroBody.FILL). The
## Omega's gold shows past this share of its charge, up to CHARGE_GLOW; the ready shield is a faint green edge.
const HURT_FLASH := 0.05
const HURT_LIGHTEN := 0.35
const BODY_LIGHT := 0.8
const BLINK_PERIOD := 0.16
const CHARGE_GLOW_FROM := 0.25
const CHARGE_GLOW := 0.55
const SHIELD_GLOW := Color(0.4, 1.0, 0.6, 0.12)
## The point near the tip of the sword (in the sword's own space, HeroBody) where a finisher's glint sits.
const BLADE_TIP := Vector3(0, 1.15, 0)
## A boss's curse on him (CurseState): a dark violet edge on his body, a few runes turning around him and a haze
## under his feet (CurseAura), Emeth's crystal corrupted by violet veins (EmethSword.set_corrupt), one puff of
## violet when it lands. The special (and its Omega) is locked while it lasts, walking and dodging never.
const CURSE_GLOW := Color(0.55, 0.12, 0.8, 0.65)
const CURSE_ACTION := &"heavy_attack"
## Ímpeto's embers (show_fury, fury_ember.gdshader): where on the blade (the sword's own space: the grip's top at 0.13,
## the tip at 1.5), meters across, the colour (Emeth's green), how far the heart goes toward white (its brightest
## channel, the peak, kept under the glow and ScreenTone.SAFE: ember_peak) and each one's flicker phase. E2: at 0.12 m
## and plain green they vanished on the green blade; a pale heart in a dark ink ring reads on it at 1080.
const EMBER_AT: Array[Vector3] = [Vector3(0, 0.55, 0), Vector3(0, 0.85, 0), Vector3(0, 1.15, 0)]
const EMBER_SIZE := 0.3
const EMBER_COLOR := Color(0.3, 1.0, 0.45)
const EMBER_PALE := 0.5
const EMBER_SHADER := preload("res://assets/shaders/fury_ember.gdshader")
## The ring at his feet when a kill gives the dodge back (Avanço Feroz, Investida): meters.
const DODGE_BACK_RING := 1.1

var arena: Arena
var horde: Horde
var fx: Fx
var pos := Vector2.ZERO
var facing := Vector2.DOWN
var state := State.MOVE
## The hero's numbers (DT-013): life, body, dodge charges, Magia and the circle of light (HeroDef; Magia is full at
## the start of every room, Game refills it; the circle takes cast_charge seconds to draw, walking slowed to
## cast_slow, only one stands at a time, held cast_omega_time with Magia it bursts; for cast_attack_lock seconds after
## it is let go no blow may start, Hades II's 8 frames, D-44).
var hero: HeroDef = HeroDef.warrior()
var hp: float = hero.max_hp
var max_hp: float = hero.max_hp
var dodge_max := 2
var dodge_charges := 2
var speed_bonus := 0.0
var damage_reduction := 0.0
## A Provação's curse (E5, Rooms): life healed and life lost are times these (1: as they are).
var heal_scale := 1.0
var hurt_scale := 1.0
var shield_cooldown := 0.0
var shield_ready := false
var runner: ComboRunner
var tree: ComboTree
var invuln := 0.0
var charging := false
## DT-102 (RESULT omega_charges_started, omega_charges_cancelled): Omega charges held past CHARGE_SOUND_AT (a tap is
## no charge) and those that filled.
var charges_started := 0
var charges_filled := 0
var charge_t := 0.0
## The button being held for an Omega move, and what it plays when let go early or late.
var _charge_action := &""
var _charge_tap := ComboNode.In.HEAVY
var _charge_held := ComboNode.In.CHARGE
var magick := Magick.new(hero.magick_max)
## The Gifts' rules in this run (HeroGifts sets it; null: no Gift). Ainda de Pé reads it when he falls.
var gifts: GiftState
## The share of an Omega's cost taken off if it is begun now (Lâmina Faminta; HeroGifts sets it every step), and the
## share kept for the charge or the circle under way (taken when it began).
var omega_discount := 0.0
var _charge_discount := 0.0
var _cast_discount := 0.0
## Ímpeto's embers on the blade (one per charge; made the first time a charge shows).
var _embers: Array[MeshInstance3D] = []
var curse := CurseState.new()
var _curse_aura: CurseAura
var _blade_mat: ShaderMaterial
var _shown_corrupt := -1.0
## The ultimate chosen for this descent (null: none) and whether its charge is full (both set by Ultimates).
var ult: UltDef = null
var ult_ready := false
## Seconds an ultimate press still waits to be used (made in the roll or the stagger: DODGE_BUFFER, as the dodge's).
var _ult_want := 0.0
## Holding the dodge button after the roll keeps running fast.
var sprinting := false
var cast_cooldown := 0.0
## A circle of light is standing (no second one until it ends).
var cast_active := false
var _casting := false
var _cast_t := 0.0
var _state_t := 0.0
var _dodge_dir := Vector2.DOWN
var _dodge_recharge := 0.0
## Seconds a dodge press still waits to be used (DODGE_BUFFER).
var _dodge_want := 0.0
## The dash attack's lunge (ComboNode.lunge; no other blow moves him). Its speed fades this fast (1/s): its distance
## is speed / LUNGE_DECAY, mostly covered in 0.25 s.
var _lunge := Vector2.ZERO
const LUNGE_DECAY := 9.0
var _push := Vector2.ZERO
var _shield_t := 0.0
var _flash := 0.0
## Seconds of the blink after a hit (the safety after a dodge or a cast does not blink).
var _blink := 0.0
var _model: Node3D
var _anim: AnimationPlayer
var _overlay: ShaderMaterial
## One x-ray material per mesh of his (each paints that mesh's own texture); the rim after them.
var _xrays: Array[ShaderMaterial] = []
var _xray_edge: ShaderMaterial
## His body's own materials (HeroBody), lightened while he blinks after a hit.
var _fills: Array[Material] = []
var _ring_look: ShaderMaterial
var _ring_through: ShaderMaterial
## What the materials were last told (they are only told again when it changes).
var _shown_fill := -1.0
var _shown_edge := -1.0
var _current_anim := &""
## The last move's clip and the clip that brings it back to the guard when it ends (ComboNode.recover_anim).
var _move_anim := &""
var _recover_anim := &""
var _light: OmniLight3D
## A point near the tip of the sword (moves with the swing).
var blade_tip: Node3D
var _sword: MeshInstance3D


func _ready() -> void:
	# the hero may have been set after the node was made (Game sets player.hero)
	max_hp = hero.max_hp
	hp = max_hp
	magick = Magick.new(hero.magick_max)
	tree = load(hero.combos)
	runner = ComboRunner.new(tree)
	runner.move_started.connect(_on_move_started)
	runner.move_hit.connect(func(node: ComboNode) -> void:
		_follow_through(node)
		struck.emit(node, pos, facing))
	runner.move_glint.connect(func(node: ComboNode, time: float) -> void:
		_anim.speed_scale = GLINT_ANIM_SPEED
		glinted.emit(node, pos, facing, time, blade_tip))
	var body := HeroBody.make()
	_model = body[0]
	_anim = body[1]
	_sword = body[2]
	add_child(_model)
	_overlay = ShaderMaterial.new()
	_overlay.shader = FLASH
	var depth := ShaderMaterial.new()
	depth.shader = XRAY_DEPTH
	depth.render_priority = XRAY_PRIORITY
	_xray_edge = ShaderMaterial.new()
	_xray_edge.shader = XRAY_EDGE
	_xray_edge.render_priority = XRAY_PRIORITY + 2
	_xray_edge.set_shader_parameter(&"width", XRAY_RIM_WIDTH)
	_overlay.set_shader_parameter(&"key", KEY_LIGHT)
	_overlay.next_pass = depth
	depth.next_pass = _xray_edge
	dodge_max = hero.dodge_charges
	dodge_charges = dodge_max
	_prepare(_model)
	if _sword:
		blade_tip = Node3D.new()
		blade_tip.position = BLADE_TIP
		_sword.add_child(blade_tip)
	_anim.playback_default_blend_time = 0.08
	_play(&"Idle")
	_light = OmniLight3D.new()
	# ahead of the paladin and clear of the head (2.75 m tall as drawn): close to it the light burns the model white
	_light.position = Vector3(0, 4.4, 2.5)
	_light.light_color = Color(1.0, 0.78, 0.5)
	_light.light_energy = 1.7
	_light.omni_range = 12.0
	_light.omni_attenuation = 1.2
	_light.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(_light)
	_model.add_child(_contact_shadow())
	add_child(_ring())
	_curse_aura = CurseAura.new()
	add_child(_curse_aura)
	if _sword and _sword.has_node(^"Blade"):
		_blade_mat = (_sword.get_node(^"Blade") as MeshInstance3D).material_override as ShaderMaterial


## A soft dark ellipse on the floor under him (it turns with him, longer front to back).
func _contact_shadow() -> MeshInstance3D:
	var plane := PlaneMesh.new()
	# in the model's space (the model is scaled to the hero's height)
	plane.size = Vector2(CONTACT_SHADOW.y, CONTACT_SHADOW.x) / _model.scale.x
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.0, 0.0, 0.02, CONTACT_SHADOW_ALPHA)
	m.albedo_texture = Fx.soft_dot()
	m.disable_receive_shadows = true
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position.y = 0.03 / _model.scale.x
	return mi


## The ring on the floor around his feet: it does not turn with him. On the open floor (hero_ring.gdshader) and,
## in a second pass, through the crowd standing over it (hero_ring_through.gdshader); never over stone.
func _ring() -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE * RING_SIZE
	var m := ShaderMaterial.new()
	m.shader = RING
	m.render_priority = XRAY_PRIORITY
	m.set_shader_parameter(&"color", RING_COLOR)
	m.set_shader_parameter(&"open", RING_OPEN)
	m.set_shader_parameter(&"through", RING_THROUGH)
	m.set_shader_parameter(&"wedge_cos", cos(deg_to_rad(RING_WEDGE * 0.5)))
	m.set_shader_parameter(&"wedge_gain", RING_WEDGE_GAIN)
	_ring_look = m
	_ring_through = m.duplicate() as ShaderMaterial
	_ring_through.shader = RING_THROUGH_SHADER
	m.next_pass = _ring_through
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position.y = 0.05
	return mi


## Every mesh of his gets the x-ray in its own colours, then the passes all of them share (the flash and glow of
## his state, his depth for the x-ray, its rim).
func _prepare(n: Node) -> void:
	for c in n.get_children():
		if c is MeshInstance3D:
			var mesh := c as MeshInstance3D
			mesh.material_overlay = _xray_of(mesh)
			for own in HeroBody.materials(mesh):
				if HeroBody.fills(own):
					_fills.append(own)
		_prepare(c)


## Each mesh: through the crowd (xray.gdshader), then behind stone (xray_behind.gdshader), then the passes they share.
func _xray_of(mesh: MeshInstance3D) -> ShaderMaterial:
	var through := _xray_pass(XRAY, xray_params(mesh.get_active_material(0)))
	var behind := _xray_pass(XRAY_BEHIND, xray_params(mesh.get_active_material(0), true))
	through.next_pass = behind
	behind.next_pass = _overlay
	return through


func _xray_pass(shader: Shader, look: Dictionary[StringName, Variant]) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader
	m.render_priority = XRAY_PRIORITY + 1
	for param: StringName in look:
		m.set_shader_parameter(param, look[param])
	m.set_shader_parameter(&"key", KEY_LIGHT)
	_xrays.append(m)
	return m


## What the x-ray paints for a mesh drawn with this material: [its painted texture or null, its colour].
static func xray_look(mat: Material) -> Array:
	if mat is BaseMaterial3D:
		var c := (mat as BaseMaterial3D).albedo_color
		return [(mat as BaseMaterial3D).albedo_texture, Color(minf(c.r, 1.0), minf(c.g, 1.0), minf(c.b, 1.0))]
	if mat is ShaderMaterial:
		return [(mat as ShaderMaterial).get_shader_parameter(&"albedo") as Texture2D, Color.WHITE]
	return [null, Color.WHITE]


## Everything xray.gdshader needs to draw a mesh as its own material does, by parameter: the body as painted and as
## lit (HeroBody), a piece without light as it is (the pale edge of the blade), Emeth with the light of its blade
## (emeth.gdshader: the numbers are read from the sword's own material, so the two never drift apart).
## behind: the numbers behind stone (XRAY_BEHIND_*), fainter and without the extra light.
static func xray_params(mat: Material, behind := false) -> Dictionary[StringName, Variant]:
	var look := xray_look(mat)
	var out: Dictionary[StringName, Variant] = {
		&"albedo": look[0], &"tint": look[1], &"opacity": XRAY_OPACITY, &"floor_light": XRAY_FLOOR, &"cover_light": XRAY_LIGHT,
		&"fill": HeroBody.FILL,
	}
	if mat is BaseMaterial3D:
		var base := mat as BaseMaterial3D
		out[&"roughness"] = base.roughness
		out[&"metallic"] = base.metallic
		if base.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
			out[&"own_light"] = 1.0
			out[&"opacity"] = XRAY_BLADE_OPACITY
	elif mat is ShaderMaterial:
		var shader := mat as ShaderMaterial
		for param: StringName in [&"fill", &"roughness", &"metallic", &"blade_from", &"blade_color", &"blade_glow", &"blade_paint"]:
			var value: Variant = shader.get_shader_parameter(param)
			if value != null:
				out[param] = value
		if out.has(&"blade_from"):
			out[&"blade"] = 1.0
			out[&"opacity"] = XRAY_BLADE_OPACITY
	if behind:
		out[&"opacity"] = float(out[&"opacity"]) * XRAY_BEHIND_SHARE
		out[&"cover_light"] = 0.0
		out[&"floor_light"] = XRAY_BEHIND_FLOOR
		out[&"cover_pure"] = 1.0
	return out


## How much lighter than usual his colours are drawn with this much of the blink after a hit left: HURT_LIGHTEN
## half of every BLINK_PERIOD, nothing the other half (never a white body).
static func blink_lighten(blink: float) -> float:
	return HURT_LIGHTEN if blink > 0.0 and fmod(blink, BLINK_PERIOD) < BLINK_PERIOD * 0.5 else 0.0


func alive() -> bool:
	return state != State.DEAD


func invulnerable() -> bool:
	return invuln > 0.0 or state == State.DODGE or state == State.DEAD or state == State.REST or state == State.ULT


## Every frame of play. move: stick or keys. aim: where the paladin wants to strike (unit vector, or zero).
func step(dt: float, move: Vector2, aim: Vector2) -> void:
	var start := pos
	# the dash goes through bodies (Hades II: the BLINK), even on the frame it ends
	var dashing := state == State.DODGE
	_state_t += dt
	invuln = maxf(0.0, invuln - dt)
	cast_cooldown = maxf(0.0, cast_cooldown - dt)
	_flash = maxf(0.0, _flash - dt / HURT_FLASH)
	_blink = maxf(0.0, _blink - dt)
	curse.step(dt)
	if shield_cooldown > 0.0 and not shield_ready:
		_shield_t += dt
		if _shield_t >= shield_cooldown:
			shield_ready = true
			fx.burst(&"heal", Vector3(pos.x, 1.2, pos.y))
	if dodge_charges < dodge_max:
		_dodge_recharge += dt
		if _dodge_recharge >= hero.dodge_recharge:
			_dodge_recharge = 0.0
			dodge_charges += 1
	var ran := false
	match state:
		State.DEAD, State.REST:
			_show(dt)
			return
		State.HURT:
			# presses during the stagger wait for its end (GF-03): the runner is locked while it lasts
			_queue_buttons()
			pos += _push * dt
			_push *= maxf(0.0, 1.0 - 10.0 * dt)
			if _state_t >= hero.hurt_time:
				state = State.MOVE
				runner.locked = false
		State.DODGE:
			# an attack pressed in the roll comes out as the dash attack when it ends (Hades II's DashAttackQueue)
			_queue_buttons()
			var feel := Feel.live()
			pos += _dodge_dir * feel.dodge_speed * dt * (1.0 - _state_t / feel.dodge_time * 0.5)
			if _state_t >= feel.dodge_time:
				state = State.MOVE
				runner.on_dodge_end()
				invuln = maxf(invuln, feel.dodge_iframes - feel.dodge_time)
				sprinting = Controls.held(&"dodge")
		State.ULT:
			# planted and safe; attack and special pressed in it wait in the locked runner, a dodge DODGE_BUFFER
			_queue_buttons()
			if _state_t >= ult.gesture:
				state = State.MOVE
				runner.locked = false
				ult_landed.emit(facing)
	if state == State.MOVE and not dashing:
		_read_buttons(dt, move, aim)
		if state == State.MOVE:
			# the runner first: a blow pressed this frame plants him on this very frame (GF-09)
			runner.glint_scale = Feel.live().glint_scale
			runner.step(dt)
			ran = true
			var sp := Feel.live().speed * (1.0 + speed_bonus) * curse.speed_scale()
			if sprinting and (runner.is_attacking() or charging or move.length() < 0.1 or not Controls.held(&"dodge")):
				sprinting = false
			if sprinting:
				sp *= Feel.live().sprint_scale
			if _casting:
				sp *= hero.cast_slow
			if runner.planted():
				# windup, blow and recovery: he stands still (E1c), only the dash attack's lunge carries him
				pos += move * sp * runner.move_scale(Feel.live()) * dt + _lunge * dt
			else:
				# free again (no move, the chain window, or past a special's walk_after): he walks and runs, no sliding
				pos += move * sp * dt + _lunge * dt
				if move.length() > 0.1:
					facing = move.normalized()
	if not ran:
		runner.glint_scale = Feel.live().glint_scale
		runner.step(dt)
	_step_move_sound(dt)
	_lunge *= maxf(0.0, 1.0 - LUNGE_DECAY * dt)
	# swept from where he stood: a dash or a push never comes out across a hole of the floor (cycle C12)
	pos = arena.sweep(start, pos, RADIUS)
	if horde and not dashing:
		# the enemies' bodies stop him: he slides along them and pushes no one (BodyBlock)
		pos = horde.stop_walker(start, pos, RADIUS, arena.resolve)
	_show(dt, move)


func _read_buttons(dt: float, move: Vector2, aim: Vector2) -> void:
	_aim = aim
	if (Controls.pressed(&"dodge") or _dodge_want > 0.0) and dodge_charges > 0 and runner.can_cancel():
		_start_dodge(move)
		return
	_dodge_want = maxf(0.0, _dodge_want - dt)
	if (Controls.pressed(&"ultimate") or _ult_want > 0.0) and ult_ready and ult != null and runner.can_cancel():
		_start_ult()
		return
	if Controls.pressed(&"ultimate"):
		ult_refused.emit()
	_ult_want = maxf(0.0, _ult_want - dt)
	_press_attack(&"light_attack", ComboNode.In.LIGHT, ComboNode.In.CHARGE_LIGHT)
	if curse.active():
		# the curse locks the special: a press does nothing, a charge already under way is dropped
		if charging and _charge_action == CURSE_ACTION:
			charging = false
	else:
		_press_attack(CURSE_ACTION, ComboNode.In.HEAVY, ComboNode.In.CHARGE)
	if charging:
		charge_t += dt
		if charge_t >= CHARGE_SOUND_AT and charge_t - dt < CHARGE_SOUND_AT:
			Audio.play(&"charge_up")
			charges_started += 1
		if not Controls.held(_charge_action):
			charging = false  # let go before the charge filled: nothing more comes
		elif charge_t >= _charge_time() - _charge_lead() and not runner.is_attacking():
			# the held move starts its windup (and glint) inside the charge, so it lands when the charge fills (GF-08)
			charging = false
			charges_filled += 1
			if charge_t < CHARGE_SOUND_AT:
				charges_started += 1
			runner.press(_charge_held)
			fx.hero_burst(&"light", Vector3(pos.x, 1.4, pos.y))
			Audio.play(&"charged")
	_read_cast(dt)


## Presses while he cannot act (the roll, the stagger): attack and special are kept by the runner (it is locked, so
## they wait unaged), the dodge waits DODGE_BUFFER once he can move.
func _queue_buttons() -> void:
	if Controls.pressed(&"dodge"):
		_dodge_want = DODGE_BUFFER
	if Controls.pressed(&"ultimate"):
		_ult_want = DODGE_BUFFER
	if Controls.pressed(&"light_attack"):
		runner.press(ComboNode.In.LIGHT)
	if Controls.pressed(CURSE_ACTION) and not curse.active():
		runner.press(ComboNode.In.HEAVY)


## A press of an attack button plays the move at once (as in Hades II). Holding the button on charges its Omega
## version when there is Magia for it; the Omega fires by itself when the charge fills.
func _press_attack(action: StringName, tap: ComboNode.In, held: ComboNode.In) -> void:
	if not Controls.pressed(action):
		return
	runner.press(tap)
	if charging and _charge_action == action:
		charge_t = 0.0  # pressed again: it was let go in between, the charge starts over
	elif not charging and _affordable(held):
		charging = true
		charge_t = 0.0
		_charge_action = action
		_charge_tap = tap
		_charge_held = held
		_charge_discount = omega_discount


## Omega charges let go, cut (dodge, blow, curse) or out of Magia before they filled; one still under way is not counted.
func charges_cancelled() -> int:
	return charges_started - charges_filled - (1 if charging and charge_t >= CHARGE_SOUND_AT else 0)


func _affordable(held: ComboNode.In) -> bool:
	var node := ComboTree.find(tree.neutral, held)
	return node != null and magick.can_pay(omega_cost(node.magick_cost, omega_discount))


## What an Omega costing base Magia costs with this share taken off (Lâmina Faminta).
static func omega_cost(base: float, discount: float) -> float:
	return base * (1.0 - discount)


## Plays this combo tree from now on (a Gift that changes the attack's chain: TalentDef.combos).
func use_tree(path: String) -> void:
	tree = load(path)
	runner.tree = tree
	runner.reset()


## A kill gave the dodge's charge back (Avanço Feroz, Investida): a thin ring on the floor at his feet. False when
## every charge was already there.
func give_dodge_back() -> bool:
	if dodge_charges >= dodge_max:
		return false
	dodge_charges += 1
	_dodge_recharge = 0.0
	fx.ring(pos, DODGE_BACK_RING, Combat.EMETH, 0.3, 0.06, true)
	return true


## Ímpeto's charges as embers on the blade: n small emerald embers along it, under the glow (ember_peak; the glow
## starts at 1.3), none without a charge. One material for the three.
func show_fury(n: int) -> void:
	if n > 0 and _embers.is_empty() and _sword:
		var m := ShaderMaterial.new()
		m.shader = EMBER_SHADER
		m.render_priority = XRAY_PRIORITY + 3
		m.set_shader_parameter(&"color", EMBER_COLOR)
		m.set_shader_parameter(&"heart_pale", EMBER_PALE)
		m.set_shader_parameter(&"peak", ember_peak())
		for k in EMBER_AT.size():
			_embers.append(_ember(EMBER_AT[k], m, float(k) / EMBER_AT.size()))
	for k in _embers.size():
		_embers[k].visible = k < n


## The brightest channel of an ember's pale heart: 1 at most (under the glow), less where it would pass ScreenTone.SAFE.
static func ember_peak() -> float:
	return minf(1.0, ScreenTone.linear_peak(EMBER_COLOR.lerp(Color.WHITE, EMBER_PALE)))


func _ember(at: Vector3, m: ShaderMaterial, phase: float) -> MeshInstance3D:
	var quad := QuadMesh.new()
	# (in the sword's space, which the body scales: meters on the screen)
	quad.size = Vector2.ONE * EMBER_SIZE / maxf(_sword.global_basis.get_scale().x, 0.001)
	var mi := MeshInstance3D.new()
	mi.mesh = quad
	mi.material_override = m
	mi.set_instance_shader_parameter(&"phase", phase)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	mi.visible = false
	_sword.add_child(mi)
	return mi


## How far an Omega's charge has got (0..1; 0 when nothing charges).
func charge_progress() -> float:
	return clampf(charge_t / maxf(_charge_time(), 0.01), 0.0, 1.0) if charging else 0.0


func _charge_time() -> float:
	var node := ComboTree.find(tree.neutral, _charge_held)
	return node.charge_time if node != null else tree.charge_time


## Seconds the held move takes from its start to its landing (windup and glint), played inside the charge.
func _charge_lead() -> float:
	var node := ComboTree.find(tree.neutral, _charge_held)
	return node.windup + node.glint * Feel.live().glint_scale if node != null else 0.0


## The circle of light: a tap draws it around the paladin; holding on (with Magia) arms it to burst at the end.
## Only one circle stands at a time (cast_active is kept by Game while the zone lives).
func _read_cast(dt: float) -> void:
	if Controls.pressed(&"cast") and cast_cooldown <= 0.0 and not _casting and not cast_active:
		_casting = true
		_cast_t = 0.0
		_cast_discount = omega_discount
	if not _casting:
		return
	_cast_t += dt
	var cost := omega_cost(hero.cast_omega_cost, _cast_discount)
	if _cast_t >= hero.cast_omega_time and _cast_t - dt < hero.cast_omega_time and magick.can_pay(cost):
		fx.hero_burst(&"light", Vector3(pos.x, 1.4, pos.y))
		Audio.play(&"charged")
	var held := Controls.held(&"cast") and magick.can_pay(cost)
	if _cast_t >= hero.cast_charge and (not held or _cast_t >= hero.cast_omega_time):
		_casting = false
		var omega := _cast_t >= hero.cast_omega_time and magick.spend(cost)
		cast_cooldown = hero.cast_cooldown
		cast_active = true
		runner.hold_for(hero.cast_attack_lock)
		cast_released.emit(pos, omega)


var _aim := Vector2.ZERO


func _start_dodge(move: Vector2) -> void:
	charging = false
	_casting = false
	state = State.DODGE
	_state_t = 0.0
	_dodge_want = 0.0
	dodge_charges -= 1
	_dodge_dir = move.normalized() if move.length() > 0.2 else facing
	facing = _dodge_dir
	runner.on_dodge()
	_play(&"Dash", DASH_CLIP_SPEED)
	fx.burst(&"dust", Vector3(pos.x, 0.2, pos.y), Vector3(-_dodge_dir.x, 0, -_dodge_dir.y))
	Audio.play(&"dodge")
	dodged.emit(_dodge_dir)


## The ultimate's gesture (UltDef.gesture): it cuts any blow as the dodge does (a blow cut in its windup never lands),
## the combo starts over, presses wait in the locked runner and come out when it ends. Its clip plays so that the
## blade lands as the gesture ends (UltDef.anim_peak).
func _start_ult() -> void:
	charging = false
	_casting = false
	sprinting = false
	state = State.ULT
	_state_t = 0.0
	_ult_want = 0.0
	_lunge = Vector2.ZERO
	runner.reset(false)
	runner.locked = true
	facing = _strike_dir()
	_play(ult.anim, 1.0, maxf(0.0, ult.anim_peak - ult.gesture))
	ult_started.emit(facing)


## How far the ultimate's gesture has got (0..1; 0 outside it).
func ult_progress() -> float:
	return clampf(_state_t / maxf(ult.gesture, 0.01), 0.0, 1.0) if state == State.ULT and ult != null else 0.0


## Where a blow goes: the aim, or where he faces; without the mouse it turns to the closest enemy ahead (soft lock).
func _strike_dir() -> Vector2:
	var dir := _aim if _aim.length() > 0.1 else facing
	if not Controls.aims_with_mouse():
		var target := horde.nearest(pos, ASSIST_RANGE) if horde else null
		if target and absf(dir.angle_to(target.pos - pos)) < ASSIST_HALF_ARC:
			dir = (target.pos - pos).normalized()
	return dir.normalized()


## The move whose swish still waits for its blade (ComboNode.sound_at) and the seconds left (null: none).
var _sound_node: ComboNode
var _sound_t := 0.0


## QW-103: plays the waiting swish on its time, only while that move still swings (a dodge that cut it drops it).
func _step_move_sound(dt: float) -> void:
	if _sound_node == null:
		return
	if runner.node != _sound_node or not runner.is_swinging():
		_sound_node = null
		return
	_sound_t -= dt
	if _sound_t <= 0.0:
		if _sound_node.sound != &"":
			Audio.play(_sound_node.sound)
		_sound_node = null


func _on_move_started(node: ComboNode) -> void:
	facing = _strike_dir()
	if node.magick_cost > 0.0:
		magick.spend(omega_cost(node.magick_cost, _charge_discount))
	_anim.speed_scale = 1.0
	_sound_node = null
	if node.sound_at > 0.0:
		# QW-103: the swish waits for the blade (_step_move_sound); the press only gathers
		_sound_node = node
		_sound_t = node.sound_at / maxf(0.01, runner.speed)
		if node.sound_press != &"":
			Audio.play(node.sound_press)
	elif node.sound != &"":
		Audio.play(node.sound)
	_lunge = facing * node.lunge * LUNGE_DECAY
	# (Ímpeto plays every blow faster: runner.speed)
	_play(node.anim, node.anim_speed * runner.speed, node.anim_from)
	_move_anim = node.anim
	_recover_anim = node.recover_anim
	if node.title != &"":
		move_shown.emit(node)


## The blow landed: the rest of its clip is the recovery, played over the recovery's length (ComboNode.follow_speed)
## instead of at the windup's speed (cut1's came back 3.7 times too fast); a short clip then holds its last pose.
func _follow_through(node: ComboNode) -> void:
	_anim.speed_scale = 1.0
	if _anim.current_animation == &"":
		return
	var tail := _anim.current_animation_length - _anim.current_animation_position
	_anim.speed_scale = node.follow_speed(tail) * runner.speed / maxf(_anim.get_playing_speed(), 0.01)


func heal(amount: float) -> void:
	if amount <= 0.0 or not alive():
		return
	hp = minf(max_hp, hp + amount * heal_scale)


## A blow lands on the paladin. Rolls, the shield and the moments after a hit ignore it.
func hurt(amount: float, from: Vector2) -> void:
	if invulnerable() or amount <= 0.0:
		return
	if shield_ready:
		shield_ready = false
		_shield_t = 0.0
		invuln = 0.5
		fx.burst(&"heal", Vector3(pos.x, 1.2, pos.y))
		Audio.play(&"shield")
		shield_broke.emit()
		return
	amount = maxf(1.0, roundf(amount * (1.0 - damage_reduction) * hurt_scale))
	hp -= amount
	invuln = hero.hurt_invuln
	_blink = hero.hurt_invuln
	_flash = 1.0
	charging = false
	runner.reset(false)
	# presses in the stagger are kept for its end (GF-03)
	runner.locked = true
	_anim.speed_scale = 1.0
	fx.buzz(0.5, 0.8, 0.2)
	var away := (pos - from).normalized() if pos.distance_to(from) > 0.01 else -facing
	_push = away * 9.0
	fx.number(Vector3(pos.x, 2.4, pos.y), amount, Color(1.0, 0.3, 0.25), true)
	fx.burst(&"spark", Vector3(pos.x, 1.2, pos.y), Vector3(away.x, 0, away.y))
	fx.shake(2.0)
	# the colour split and the edge tint of a blow taken are Game's (HurtTint: never on the whole screen)
	Audio.play(&"hurt")
	was_hurt.emit(amount)
	if hp <= 0.0 and gifts != null and gifts.rise():
		# Ainda de Pé: once a descent he falls and gets up with part of his life (then the stagger of the blow)
		hp = gifts.rise_life(max_hp)
		fx.hero_burst(&"light", Vector3(pos.x, 1.2, pos.y))
		fx.ring(pos, 2.0, Combat.EMETH, 0.5, 0.06, true)
		fx.word(Vector3(pos.x, 3.2, pos.y), T.t(&"word_rise"), Combat.EMETH)
		Audio.play(&"heal")
		rose.emit()
	if hp <= 0.0:
		hp = 0.0
		state = State.DEAD
		_play(&"Death", 1.0)
		died.emit()
		return
	state = State.HURT
	_state_t = 0.0
	_play(&"Hit", 1.6)


## A boss's curse lands (false while one runs or he is still immune to the next).
func apply_curse(seconds: float, slow: float, immunity: float) -> bool:
	if not alive() or not curse.apply(seconds, slow, immunity):
		return false
	if charging and _charge_action == CURSE_ACTION:
		charging = false
	fx.burst(&"curse", Vector3(pos.x, 1.3, pos.y))
	fx.word(Vector3(pos.x, 3.2, pos.y), T.t(&"word_cursed"), Color(CURSE_GLOW, 1.0))
	Audio.play(&"cursed")
	return true


## The fight is over: stand still and look on (the final scene).
func rest() -> void:
	if state == State.DEAD:
		return
	state = State.REST
	runner.reset()
	_play(&"Idle")


## Puts the paladin at a spot (the roar of Morvath throws him back).
func place(at: Vector2) -> void:
	pos = arena.resolve(at, RADIUS)


func _show(dt: float, move: Vector2 = Vector2.ZERO) -> void:
	position = Vector3(pos.x, 0, pos.y)
	var want := atan2(facing.x, facing.y)
	if runner.is_attacking():
		_model.rotation.y = lerp_angle(_model.rotation.y, want, minf(1.0, dt * TURN_SWING))
	else:
		_model.rotation.y = rotate_toward(_model.rotation.y, want, TURN_BODY * dt)
	var glow := Color(OUTLINE, inverse_lerp(CHARGE_GLOW_FROM, 1.0, maxf(charge_progress(), CHARGE_GLOW_FROM)) * CHARGE_GLOW)
	if shield_ready and not charging:
		glow = SHIELD_GLOW
	if curse.active():
		glow = CURSE_GLOW
	_show_curse()
	_overlay.set_shader_parameter(&"flash", _flash)
	# the blink after a hit: more of his own painting as light, on the body and on what shows through a cover
	var fill := HeroBody.FILL + blink_lighten(_blink) * BODY_LIGHT
	if fill != _shown_fill:
		_shown_fill = fill
		for own in _fills:
			HeroBody.set_fill(own, fill)
		for x in _xrays:
			x.set_shader_parameter(&"lighten", fill - HeroBody.FILL)
	_overlay.set_shader_parameter(&"glow", glow)
	var edge := Dev.num("outline", Feel.live().outline)
	_overlay.set_shader_parameter(&"outline", Color(EDGE, edge))
	# --outline=0 (or the feel panel) turns the x-ray off with the edge
	if edge != _shown_edge:
		_shown_edge = edge
		for x in _xrays:
			x.set_shader_parameter(&"show", 1.0 if edge > 0.0 else 0.0)
		_xray_edge.set_shader_parameter(&"color", Color(XRAY_RIM, XRAY_RIM.a if edge > 0.0 else 0.0))
	var faces := Vector2(sin(_model.rotation.y), cos(_model.rotation.y))
	_ring_look.set_shader_parameter(&"facing", faces)
	_ring_through.set_shader_parameter(&"facing", faces)
	RenderingServer.global_shader_parameter_set(&"hero_pos", position)
	if fx:
		fx.hero_head = position + Vector3(0, HeroBody.HEIGHT, 0)
	if state != State.MOVE or runner.planted():
		return  # planted in a blow: its own clip (or its held pose), never the run
	if move.length() > 0.1:
		var pace := Feel.live().speed * (1.0 + speed_bonus) * curse.speed_scale() * (Feel.live().sprint_scale if sprinting else 1.0)
		if sprinting:
			_play(&"Sprint", pace / SPRINT_CLIP_PACE)
		else:
			_play(&"Run", pace / RUN_CLIP_PACE)
	elif runner.is_attacking() or (_anim.is_playing() and not LOOPS.has(_current_anim)):
		return  # let the follow-through of a swing finish
	elif _current_anim == _move_anim and _recover_anim != &"":
		_play(_recover_anim)  # the blade comes back to the guard (walking cuts it), never a cut to the idle
		_move_anim = &""
	else:
		_play(&"Idle")


## The curse's look follows the curse: the runes and the haze ease in and out, Emeth's violet veins with them.
func _show_curse() -> void:
	_curse_aura.on = curse.active() and alive()
	var k := snappedf(_curse_aura.power, 0.02)
	if _blade_mat and k != _shown_corrupt:
		_shown_corrupt = k
		EmethSword.set_corrupt(_blade_mat, k)


func _play(anim: StringName, speed: float = 1.0, from: float = -1.0) -> void:
	_anim.speed_scale = 1.0  # (a follow-through slows the clip it plays; never what comes after it)
	if from >= 0.0:
		_anim.play(anim, 0.05, speed)
		_anim.seek(from, true)
	elif _current_anim != anim or not _anim.is_playing():
		_anim.play(anim, -1, speed)
	_current_anim = anim
