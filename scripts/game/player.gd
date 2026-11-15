class_name Player
extends Node3D
## The paladin. Moves on the floor plane (pos is (x, z) in meters), rolls out of danger, and fights with the combo
## tree: the ComboRunner decides which move comes next, this node plays it (animation, lunge) and reports when it lands.

signal struck(node: ComboNode, origin: Vector2, dir: Vector2)
## A finisher holds at the top of its swing for time seconds before it lands.
signal glinted(node: ComboNode, origin: Vector2, dir: Vector2, time: float, tip: Node3D)
signal move_shown(node: ComboNode)
signal was_hurt(amount: float)
signal died
signal dodged(dir: Vector2)
signal shield_broke
## The circle of light (cast) is let go at a point; omega: it was held and paid for, so it bursts at the end.
signal cast_released(at: Vector2, omega: bool)

enum State { MOVE, DODGE, HURT, DEAD, REST }

const COMBOS := "res://data/combos/paladin.tres"
const RADIUS := 0.5
## Life and the moments of safety after a hit, as in Hades II (30 life, 1.3 s).
const MAX_HP := 30.0
const HURT_TIME := 0.18
const HURT_INVULN := 1.3
const TURN := 18.0
## Meters per second the run and sprint clips cover at their own speed (tools/bake_hero.gd measures them), so the
## clips play as fast as the paladin moves and the feet keep up.
const RUN_CLIP_PACE := 7.8
const SPRINT_CLIP_PACE := 11.8
## The dash clip (0.6 s of a low lunge) squeezed into the 0.2 s dodge, with its end blending into the run.
const DASH_CLIP_SPEED := 2.4
## How fast the swing animation creeps while a finisher holds its glint (it lands when the hold ends).
const GLINT_ANIM_SPEED := 0.15
## Soft lock: a swing without a clear aim turns to the closest enemy in front, within this distance.
const ASSIST_RANGE := 6.0
const LOOPS: Array[StringName] = [&"Idle", &"Run", &"Sprint"]
const FLASH := preload("res://assets/shaders/flash.gdshader")
const XRAY := preload("res://assets/shaders/xray.gdshader")
const OUTLINE := Color(1.0, 0.78, 0.35)
## The thin edge on his body and his silhouette through what hides him: cold and light, never gold over the body
## (docs/art/cycle4_spec.md, c).
const EDGE := Color(0.75, 0.9, 1.0)
## The dark blot under his feet, as under every figure of the reference painting: meters across and deep, opacity.
const CONTACT_SHADOW := Vector2(1.2, 0.8)
const CONTACT_SHADOW_ALPHA := 0.5
## The look of his state on the body (flash.gdshader), kept small so he reads as the explorer in the fight
## (Daniel's capture of 2026-11-14 showed him all gold or white): after a hit he blinks white this strong every
## BLINK_PERIOD seconds (only after a hit, not after a dodge or a cast); the Omega's gold shows past this share of
## its charge, up to CHARGE_GLOW; the ready shield is a faint green edge.
const HURT_BLINK := 0.3
const BLINK_PERIOD := 0.16
const CHARGE_GLOW_FROM := 0.25
const CHARGE_GLOW := 0.55
const SHIELD_GLOW := Color(0.4, 1.0, 0.6, 0.12)
## The point near the tip of the sword (in the sword's own space, HeroBody) where a finisher's glint sits.
const BLADE_TIP := Vector3(0, 1.15, 0)
## Magia: full at the start of every room (Game refills it), spent by the held Omega moves.
const MAGICK_MAX := 50.0
## The circle of light rises around the paladin. It takes CAST_CHARGE seconds to draw (walking slowed to
## CAST_SLOW), only one can stand at a time, and holding the button CAST_OMEGA_TIME (with Magia) arms it to burst.
const CAST_CHARGE := 0.25
const CAST_SLOW := 0.6
const CAST_COOLDOWN := 0.2
const CAST_OMEGA_TIME := 0.6
const CAST_OMEGA_COST := 20.0

var arena: Arena
var horde: Horde
var fx: Fx
var pos := Vector2.ZERO
var facing := Vector2.DOWN
var state := State.MOVE
var hp := MAX_HP
var max_hp := MAX_HP
var dodge_max := 2
var dodge_charges := 2
var speed_bonus := 0.0
var damage_reduction := 0.0
var shield_cooldown := 0.0
var shield_ready := false
var runner: ComboRunner
var tree: ComboTree
var invuln := 0.0
var charging := false
var charge_t := 0.0
## The button being held for an Omega move, and what it plays when let go early or late.
var _charge_action := &""
var _charge_tap := ComboNode.In.HEAVY
var _charge_held := ComboNode.In.CHARGE
var magick := Magick.new(MAGICK_MAX)
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
var _lunge := Vector2.ZERO
## The lunge's speed fades this fast (1/s): its distance is speed / LUNGE_DECAY, mostly covered in 0.25 s.
const LUNGE_DECAY := 9.0
## A lunge toward an enemy stops when it stands this share of the blow's reach away.
const LUNGE_STANDOFF := 0.45
var _push := Vector2.ZERO
var _shield_t := 0.0
var _flash := 0.0
## Seconds of the white blink after a hit (the safety after a dodge or a cast does not blink).
var _blink := 0.0
var _model: Node3D
var _anim: AnimationPlayer
var _overlay: ShaderMaterial
var _xray: ShaderMaterial
var _current_anim := &""
var _light: OmniLight3D
## A point near the tip of the sword (moves with the swing).
var blade_tip: Node3D
var _sword: MeshInstance3D


func _ready() -> void:
	tree = load(COMBOS)
	runner = ComboRunner.new(tree)
	runner.move_started.connect(_on_move_started)
	runner.move_hit.connect(func(node: ComboNode) -> void:
		_anim.speed_scale = 1.0
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
	_xray = ShaderMaterial.new()
	_xray.shader = XRAY
	_xray.render_priority = 2
	_overlay.next_pass = _xray
	dodge_max = Feel.live().dodge_charges
	dodge_charges = dodge_max
	_prepare(_model)
	if _sword:
		blade_tip = Node3D.new()
		blade_tip.position = BLADE_TIP
		_sword.add_child(blade_tip)
	_anim.playback_default_blend_time = 0.08
	_play(&"Idle")
	_light = OmniLight3D.new()
	# ahead of the paladin and clear of the head (2.5 m tall): close to it the light burns the model white
	_light.position = Vector3(0, 4.0, 2.5)
	_light.light_color = Color(1.0, 0.78, 0.5)
	_light.light_energy = 1.7
	_light.omni_range = 12.0
	_light.omni_attenuation = 1.2
	_light.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(_light)
	_model.add_child(_contact_shadow())


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


func _prepare(n: Node) -> void:
	for c in n.get_children():
		if c is MeshInstance3D:
			(c as MeshInstance3D).material_overlay = _overlay
		_prepare(c)


func alive() -> bool:
	return state != State.DEAD


func invulnerable() -> bool:
	return invuln > 0.0 or state == State.DODGE or state == State.DEAD or state == State.REST


## Every frame of play. move: stick or keys. aim: where the paladin wants to strike (unit vector, or zero).
func step(dt: float, move: Vector2, aim: Vector2) -> void:
	_state_t += dt
	invuln = maxf(0.0, invuln - dt)
	cast_cooldown = maxf(0.0, cast_cooldown - dt)
	_flash = maxf(0.0, _flash - dt * 6.0)
	_blink = maxf(0.0, _blink - dt)
	if shield_cooldown > 0.0 and not shield_ready:
		_shield_t += dt
		if _shield_t >= shield_cooldown:
			shield_ready = true
			fx.burst(&"heal", Vector3(pos.x, 1.2, pos.y))
	if dodge_charges < dodge_max:
		_dodge_recharge += dt
		if _dodge_recharge >= Feel.live().dodge_recharge:
			_dodge_recharge = 0.0
			dodge_charges += 1
	match state:
		State.DEAD, State.REST:
			_show(dt)
			return
		State.HURT:
			pos += _push * dt
			_push *= maxf(0.0, 1.0 - 10.0 * dt)
			if _state_t >= HURT_TIME:
				state = State.MOVE
		State.DODGE:
			var feel := Feel.live()
			pos += _dodge_dir * feel.dodge_speed * dt * (1.0 - _state_t / feel.dodge_time * 0.5)
			if _state_t >= feel.dodge_time:
				state = State.MOVE
				runner.on_dodge_end()
				invuln = maxf(invuln, feel.dodge_iframes - feel.dodge_time)
				sprinting = Controls.held(&"dodge")
		State.MOVE:
			_read_buttons(dt, move, aim)
			if state == State.MOVE:
				var sp := Feel.live().speed * (1.0 + speed_bonus)
				if sprinting and (runner.is_attacking() or charging or move.length() < 0.1 or not Controls.held(&"dodge")):
					sprinting = false
				if sprinting:
					sp *= Feel.live().sprint_scale
				if _casting:
					sp *= CAST_SLOW
				if runner.is_swinging():
					pos += move * sp * runner.move_scale(Feel.live()) * dt + _lunge * dt
				else:
					# after the blow lands, walking cuts the follow-through short (the legs run, no sliding)
					pos += move * sp * dt + _lunge * dt
					if move.length() > 0.1:
						facing = facing.slerp(move.normalized(), minf(1.0, dt * TURN)).normalized()
	runner.glint_scale = Feel.live().glint_scale
	runner.step(dt)
	_lunge *= maxf(0.0, 1.0 - LUNGE_DECAY * dt)
	pos = arena.resolve(pos, RADIUS)
	_show(dt, move)


func _read_buttons(dt: float, move: Vector2, aim: Vector2) -> void:
	_aim = aim
	if Controls.pressed(&"dodge") and dodge_charges > 0 and runner.can_cancel():
		_start_dodge(move)
		return
	_press_attack(&"light_attack", ComboNode.In.LIGHT, ComboNode.In.CHARGE_LIGHT)
	_press_attack(&"heavy_attack", ComboNode.In.HEAVY, ComboNode.In.CHARGE)
	if charging:
		charge_t += dt
		if not Controls.held(_charge_action):
			charging = false  # let go before the charge filled: nothing more comes
		elif charge_t >= _charge_time():
			charging = false
			runner.press(_charge_held)
			fx.burst(&"light", Vector3(pos.x, 1.4, pos.y))
			Audio.play(&"charged")
	_read_cast(dt)


## A press of an attack button plays the move at once (as in Hades II). Holding the button on charges its Omega
## version when there is Magia for it; the Omega fires by itself when the charge fills.
func _press_attack(action: StringName, tap: ComboNode.In, held: ComboNode.In) -> void:
	if not Controls.pressed(action):
		return
	runner.press(tap)
	if not charging and _affordable(held):
		charging = true
		charge_t = 0.0
		_charge_action = action
		_charge_tap = tap
		_charge_held = held


func _affordable(held: ComboNode.In) -> bool:
	var node := ComboTree.find(tree.neutral, held)
	return node != null and magick.can_pay(node.magick_cost)


## How far an Omega's charge has got (0..1; 0 when nothing charges).
func charge_progress() -> float:
	return clampf(charge_t / maxf(_charge_time(), 0.01), 0.0, 1.0) if charging else 0.0


func _charge_time() -> float:
	var node := ComboTree.find(tree.neutral, _charge_held)
	return node.charge_time if node != null else tree.charge_time


## The circle of light: a tap draws it around the paladin; holding on (with Magia) arms it to burst at the end.
## Only one circle stands at a time (cast_active is kept by Game while the zone lives).
func _read_cast(dt: float) -> void:
	if Controls.pressed(&"cast") and cast_cooldown <= 0.0 and not _casting and not cast_active:
		_casting = true
		_cast_t = 0.0
	if not _casting:
		return
	_cast_t += dt
	if _cast_t >= CAST_OMEGA_TIME and _cast_t - dt < CAST_OMEGA_TIME and magick.can_pay(CAST_OMEGA_COST):
		fx.burst(&"light", Vector3(pos.x, 1.4, pos.y))
		Audio.play(&"charged")
	var held := Controls.held(&"cast") and magick.can_pay(CAST_OMEGA_COST)
	if _cast_t >= CAST_CHARGE and (not held or _cast_t >= CAST_OMEGA_TIME):
		_casting = false
		var omega := _cast_t >= CAST_OMEGA_TIME and magick.spend(CAST_OMEGA_COST)
		cast_cooldown = CAST_COOLDOWN
		cast_active = true
		invuln = maxf(invuln, 0.2)
		cast_released.emit(pos, omega)


var _aim := Vector2.ZERO


func _start_dodge(move: Vector2) -> void:
	charging = false
	_casting = false
	state = State.DODGE
	_state_t = 0.0
	dodge_charges -= 1
	_dodge_dir = move.normalized() if move.length() > 0.2 else facing
	facing = _dodge_dir
	runner.on_dodge()
	_play(&"Dash", DASH_CLIP_SPEED)
	fx.burst(&"dust", Vector3(pos.x, 0.2, pos.y), Vector3(-_dodge_dir.x, 0, -_dodge_dir.y))
	Audio.play(&"dodge")
	dodged.emit(_dodge_dir)


func _on_move_started(node: ComboNode) -> void:
	var dir := _aim if _aim.length() > 0.1 else facing
	if not Controls.aims_with_mouse():
		var target := horde.nearest(pos, ASSIST_RANGE) if horde else null
		if target and absf(dir.angle_to(target.pos - pos)) < 1.2:
			dir = (target.pos - pos).normalized()
	facing = dir.normalized()
	if node.magick_cost > 0.0:
		magick.spend(node.magick_cost)
	_anim.speed_scale = 1.0
	_lunge = facing * node.lunge_toward(_gap_ahead(node)) * LUNGE_DECAY
	_play(node.anim, node.anim_speed, node.anim_from)
	if node.title != &"":
		move_shown.emit(node)


## How far the enemy ahead stands beyond striking distance (INF: nobody within reach of a lunge).
func _gap_ahead(node: ComboNode) -> float:
	if horde == null or node.lunge <= 0.0:
		return INF
	var strike := node.reach * LUNGE_STANDOFF
	var e := horde.nearest_ahead(pos, facing, strike + node.lunge + ComboNode.LUNGE_MAGNET, 0.6)
	if e == null:
		return INF
	return pos.distance_to(e.pos) - e.def.radius - strike


func heal(amount: float) -> void:
	if amount <= 0.0 or not alive():
		return
	hp = minf(max_hp, hp + amount)


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
	amount = maxf(1.0, roundf(amount * (1.0 - damage_reduction)))
	hp -= amount
	invuln = HURT_INVULN
	_blink = HURT_INVULN
	_flash = 1.0
	charging = false
	runner.reset()
	_anim.speed_scale = 1.0
	var away := (pos - from).normalized() if pos.distance_to(from) > 0.01 else -facing
	_push = away * 9.0
	fx.number(Vector3(pos.x, 2.4, pos.y), amount, Color(1.0, 0.3, 0.25), true)
	fx.burst(&"spark", Vector3(pos.x, 1.2, pos.y), Vector3(away.x, 0, away.y))
	fx.shake(2.0)
	fx.kick_split(1.0)
	Audio.play(&"hurt")
	was_hurt.emit(amount)
	if hp <= 0.0:
		hp = 0.0
		state = State.DEAD
		_play(&"Death", 1.0)
		died.emit()
		return
	state = State.HURT
	_state_t = 0.0
	_play(&"Hit", 1.6)


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
	_model.rotation.y = lerp_angle(_model.rotation.y, want, minf(1.0, dt * (30.0 if runner.is_attacking() else TURN)))
	var glow := Color(OUTLINE, inverse_lerp(CHARGE_GLOW_FROM, 1.0, maxf(charge_progress(), CHARGE_GLOW_FROM)) * CHARGE_GLOW)
	if shield_ready and not charging:
		glow = SHIELD_GLOW
	var blink := HURT_BLINK if _blink > 0.0 and fmod(_blink, BLINK_PERIOD) < BLINK_PERIOD * 0.5 else 0.0
	_overlay.set_shader_parameter(&"flash", maxf(_flash, blink))
	_overlay.set_shader_parameter(&"glow", glow)
	var edge := Dev.num("outline", Feel.live().outline)
	_overlay.set_shader_parameter(&"outline", Color(EDGE, edge))
	_xray.set_shader_parameter(&"color", Color(EDGE, edge))
	RenderingServer.global_shader_parameter_set(&"hero_pos", position)
	if state != State.MOVE or runner.is_swinging():
		return
	if move.length() > 0.1:
		var pace := Feel.live().speed * (1.0 + speed_bonus) * (Feel.live().sprint_scale if sprinting else 1.0)
		if sprinting:
			_play(&"Sprint", pace / SPRINT_CLIP_PACE)
		else:
			_play(&"Run", pace / RUN_CLIP_PACE)
	elif runner.is_attacking() or (_anim.is_playing() and not LOOPS.has(_current_anim)):
		return  # let the follow-through of a swing finish
	else:
		_play(&"Idle")


func _play(anim: StringName, speed: float = 1.0, from: float = -1.0) -> void:
	if from >= 0.0:
		_anim.play(anim, 0.05, speed)
		_anim.seek(from, true)
	elif _current_anim != anim or not _anim.is_playing():
		_anim.play(anim, -1, speed)
	_current_anim = anim
