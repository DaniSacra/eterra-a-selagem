class_name Ultimates
extends Node3D
## The hero's ultimate in play (D-54, E2-08 and E2-10; docs/design/warrior_spec.md 3.2, ultimate_u2_proposals.md
## section 1 and proposal A). One per descent (Game.ultimate, from the save or --ultimate=id), charged by the Magia
## spent on Omegas (UltCharge), let go by the action "ultimate" when full. The Player plays the protected gesture
## (State.ULT: it cuts the blow under way as the dodge does); this node spends the charge when it begins and plays the
## blow when it ends. Its hits never feed the combo counter nor give Magia back (Combat.hit_enemy counts = false),
## never a finisher nor an Omega (no passive, no impact frame). Numbers: UltDef (data/ultimates/, make_data.gd).
##   CLEAVE (U-1, Corte do Juizo): the gesture marks the band on the floor (the warning, gesture seconds), then the
##     blow lands on the whole band (UltDef.cleave_damage: core_damage on the middle strip, damage on the rest; armor
##     takes armor_mult; commons stunned `stun` seconds); a rift of emerald runs along it (ult_rift.gdshader).
##   VORTEX (U-2, Voragem): an area lands where he aims (UltDef.vortex_at); for `duration` it pulls in a spiral
##     (UltDef.vortex_pull times pull_share, swept by Arena.sweep: nobody crosses stone nor falls), holds the commons
##     inside (as the circle of light does), ticks, and implodes at the end. Inside a circle of light (BIND) nobody is
##     pulled: the circle holds. Morvath is only slowed.

## The band's warning during the gesture: the Emeth's emerald, fainter than an enemy's (it is no danger to him).
const WARN_STRENGTH := 0.7
## Seconds the fissure takes to run the band, and how long it shows after.
const RIFT_RUN := 0.12
const RIFT_TIME := 0.9
## The pale lips of the rift (share toward white): the peak is kept so this colour stays under ScreenTone.SAFE.
const RIFT_PALE := 0.3
## The Voragem's floor (ult_vortex.gdshader; ultimate_u2_proposals.md A.3): an emerald veil up to VORTEX_VEIL of
## opacity (VORTEX_VEIL_EDGE at the rim), three ivory arms in a spiral (VORTEX_TWIST turns from the rim to the middle)
## turning inward at VORTEX_SPIN radians a second (the pattern runs to the middle at radius * spin / (twist * 2 pi),
## 2.5 m/s on 6 m) and a fine rim of old gold. Its last VORTEX_CLOSE seconds the rim closes on the middle: the
## implosion, never a column. Each part's brightest channel is its colour's ScreenTone peak, at most 1 (vortex_peaks).
const VORTEX_SHADER := preload("res://assets/shaders/ult_vortex.gdshader")
const VORTEX_IVORY := Color(0.95, 0.92, 0.82)
const VORTEX_GOLD := Fx.OLD_GOLD
const VORTEX_VEIL := 0.3
const VORTEX_VEIL_EDGE := 0.08
const VORTEX_TWIST := 0.9
const VORTEX_SPIN := 2.4
const VORTEX_ARMS := 3.0
const VORTEX_RIM_M := 0.07
const VORTEX_ARM_M := 0.16
const VORTEX_HEIGHT := 0.065
const VORTEX_FADE_IN := 0.2
const VORTEX_CLOSE := 0.15
## The ultimate's marks on the floor draw before the enemies' warnings (ground.gdshader, priority 0): their red always
## reads over the veil and the rift.
const FLOOR_PRIORITY := -1
## Motes drawn into the middle every this many seconds: ivory slivers running in along the spiral (Fx.chips times
## Fx.MOTE_GLOW 2.2: VORTEX_MOTE's brightest channel 0.48, so 1.05 lit, under the glow), how many and how far
## along the turn they lean (share of the tangent).
const VORTEX_MOTES_EVERY := 0.1
const VORTEX_MOTE := Color(0.48, 0.465, 0.415)
const VORTEX_MOTE_COUNT := 3
const VORTEX_MOTE_SWIRL := 0.7
## The cleave's chips (Fx.chips, lit by Fx.MOTE_GLOW under the glow).
const MOTE_COLOR := Color(0.13, 0.42, 0.22)
## The hit slow of the cleave landing (as a finisher's, Hades II's numbers: ms of wait, ms slowed).
const STOP_WAIT_MS := 70.0
const STOP_SLOW_MS := 50.0
## The Morvath slow inside the Voragem (seconds, renewed each step; as the circle of light's).
const BOSS_SLOW := Ground.TICK * 2.0
## The robot lets it go on this many enemies at least (or one big one: worth).
const WORTH_PACK := 3
const RIFT_SHADER := preload("res://assets/shaders/ult_rift.gdshader")

## One Voragem on the floor.
class Vortex:
	var at := Vector2.ZERO
	var radius := 6.0
	var life := 4.0
	var tick := 0.0
	var motes := 0.0
	## Radians the arms have turned (ult_vortex.gdshader's turn).
	var turn := 0.0
	## Who it already cut out of a wind-up (once on entering).
	var held: Dictionary = {}
	var node: MeshInstance3D

var game: Game
var def: UltDef
var charge := UltCharge.new()
## Times let go and damage dealt in this run (RESULT ultimate).
var uses := 0
var damage := 0.0
## The same in Morvath's room only (E6: does it charge there?).
var boss_uses := 0
var boss_damage := 0.0
var vortex: Vortex
## Where the Voragem will land (chosen on the press) and the band's warning while the gesture lasts.
var _target := Vector2.ZERO
var _warn: MeshInstance3D
var _rift: MeshInstance3D
var _rift_t := -1.0
var _found: Array[Enemy] = []


func setup(g: Game) -> void:
	game = g
	game.player.ult_started.connect(_on_started)
	game.player.ult_landed.connect(_on_landed)


## The ultimate of this descent (null: none). The charge starts empty.
func equip(u: UltDef) -> void:
	def = u
	charge = UltCharge.new(u.charge if u else 60.0)
	charge.feed(game.player.magick.spent)  # (only what is spent from now on counts)
	game.player.ult = u
	game.player.ult_ready = false


func step(dt: float) -> void:
	var p := game.player
	if def == null:
		p.ult_ready = false
		return
	charge.feed(p.magick.spent, game.boons.stat(&"ult_charge_pct"))
	p.ult_ready = charge.ready()
	if _warn != null and _warn.visible:
		GroundLook.put(_warn.material_override as ShaderMaterial, &"progress", p.ult_progress())
		if p.state != Player.State.ULT:
			_warn.visible = false
	_step_rift(dt)
	if vortex != null:
		_step_vortex(dt)


## Everything on the floor goes (a new room, the end of the run). The charge is kept.
func clear() -> void:
	if vortex != null:
		vortex.node.queue_free()
		vortex = null
	if _warn != null:
		_warn.visible = false
	if _rift != null:
		_rift.visible = false
	_rift_t = -1.0


func ratio() -> float:
	return charge.ratio() if def != null else 0.0


func stats() -> Dictionary:
	return {"id": String(def.id) if def else "", "uses": uses, "damage": int(damage), "charge": snappedf(charge.value, 0.1),
		"boss_uses": boss_uses, "boss_damage": int(boss_damage)}


## Whether letting it go from here towards dir would reach WORTH_PACK enemies or a big one (an elite, a guardian,
## Morvath): the robot's choice.
func worth(from: Vector2, dir: Vector2) -> bool:
	if def == null or dir.length_squared() < 0.0001:
		return false
	var n := 0
	var at := def.vortex_at(from, dir)
	var size := def.vortex_radius(game.boons.stat(&"cast_size_pct", def.tags))
	for e: Enemy in game.horde.list:
		if not e.alive or e.invulnerable:
			continue
		var inside := def.cleave_damage(from, dir, e.pos, e.def.radius) > 0.0 if def.kind == UltDef.Kind.CLEAVE \
			else e.pos.distance_to(at) <= size
		if inside:
			n += 1
			if e.def.elite or e.def.behavior == EnemyDef.Behavior.BOSS or n >= WORTH_PACK:
				return true
	return false


func _on_started(dir: Vector2) -> void:
	charge.use()
	uses += 1
	if game.boss != null:
		boss_uses += 1
	Audio.play(CombatSounds.EVENTS[&"ult_gesture"])
	game.fx.hero_burst(&"light", Vector3(game.player.pos.x, 1.4, game.player.pos.y))
	var p := game.player.pos
	if def.kind == UltDef.Kind.CLEAVE:
		_floor_mark(GroundLook.Style.WARNING, GroundLook.Shape.LINE, p, dir, def.length, def.width)
		GroundLook.put(_warn.material_override as ShaderMaterial, &"progress", 0.0)
	else:
		_target = _land_spot(def.vortex_at(p, dir, game.aim_floor() if Controls.aims_with_mouse() else Vector2.INF))
		var size := def.vortex_radius(game.boons.stat(&"cast_size_pct", def.tags))
		_floor_mark(GroundLook.Style.WARNING, GroundLook.Shape.CIRCLE, _target, Vector2.DOWN, size, 0.0)
		GroundLook.put(_warn.material_override as ShaderMaterial, &"progress", 0.0)


func _on_landed(dir: Vector2) -> void:
	if _warn != null:
		_warn.visible = false
	if def.kind == UltDef.Kind.CLEAVE:
		_cleave(game.player.pos, dir)
	else:
		_open_vortex(_target)


## A point on the floor the area can stand on (the abyss and the walls are not: Arena.resolve).
func _land_spot(at: Vector2) -> Vector2:
	return game.arena.resolve(at, 0.5) if game.arena else at


# ---------- U-1, the cleave ----------

func _cleave(origin: Vector2, dir: Vector2) -> void:
	var struck := 0
	var mats: Array[StringName] = []
	for e: Enemy in game.horde.list.duplicate():
		if not e.alive:
			continue
		var amount := def.cleave_damage(origin, dir, e.pos, e.def.radius)
		if amount <= 0.0:
			continue
		struck += 1
		if not e.invulnerable:
			mats.append(CombatSounds.material_of(e))
			game.fx.gash(Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(0, -1, 0).lerp(Vector3(dir.x, 0, dir.y), 0.3), Combat.EMETH, Combat.GASH_HEAVY, true, Combat.GASH_TIME.y)
		_hit(e, amount, dir, def.knockback, def.stun)
	_show_rift(origin, dir)
	var fx := game.fx
	fx.kick(dir, Combat.KICK_FINISHER)
	fx.shake(3.0)
	fx.buzz(Combat.RUMBLE_OMEGA.x, Combat.RUMBLE_OMEGA.y, Combat.RUMBLE_OMEGA.z)
	for k in 5:
		var at := origin + dir * def.length * (k + 0.5) / 5.0
		fx.chips(Vector3(at.x, 0.3, at.y), Vector3(dir.x, 1.2, dir.y), MOTE_COLOR, 4, 5.0, 0.1, 0.45, 0.8, Fx.MOTE_GOLD_EVERY)
		fx.burst(&"dust", Vector3(at.x, 0.2, at.y))
	Audio.play(CombatSounds.EVENTS[&"ult_cleave"])
	if struck > 0:
		var k := Feel.live().hit_stop_scale
		fx.blow_stop(STOP_WAIT_MS * k, STOP_SLOW_MS * k)
		Audio.play(CombatSounds.EVENTS[&"hit_heavy"])
		var m := CombatSounds.material(CombatSounds.loudest(mats))
		if m != &"":
			Audio.play(m)


## One hit of the ultimate: never a blow of the combo (counts false: no combo count, no Magia back), the armor takes
## armor_mult of it; a common body still standing is stunned `stun` seconds (stun 0: only what the hit gives).
func _hit(e: Enemy, amount: float, away: Vector2, knockback: float, stun: float) -> bool:
	var hp_before := e.hp + e.armor
	var died := game.combat.hit_enemy(e, amount * (def.armor_mult if e.armor > 0.0 else 1.0), def.tags, away, knockback, false)
	if not e.invulnerable:
		var dealt := maxf(0.0, hp_before - e.hp - e.armor)
		damage += dealt
		if game.boss != null:
			boss_damage += dealt
	if not died and stun > 0.0 and e.armor <= 0.0 and e.def.stun_time > 0.0:
		game.horde.flinch(e, stun)
	return died


func _show_rift(origin: Vector2, dir: Vector2) -> void:
	if _rift == null:
		_rift = MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2.ONE
		_rift.mesh = plane
		var m := ShaderMaterial.new()
		m.shader = RIFT_SHADER
		m.render_priority = FLOOR_PRIORITY
		_rift.material_override = m
		_rift.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_rift)
	var mat := _rift.material_override as ShaderMaterial
	mat.set_shader_parameter(&"color", Combat.EMETH)
	mat.set_shader_parameter(&"peak", rift_peak())
	mat.set_shader_parameter(&"lip_pale", RIFT_PALE)
	mat.set_shader_parameter(&"length_m", def.length)
	mat.set_shader_parameter(&"width_m", def.width)
	mat.set_shader_parameter(&"seed", fposmod(origin.x * 0.37 + origin.y * 0.21, 1.0))
	_rift.position = Vector3(origin.x, 0.07, origin.y)
	_rift.rotation = Vector3(0, atan2(dir.x, dir.y), 0)
	_rift.visible = true
	_rift_t = 0.0
	_step_rift(0.0)


## The brightest channel of the rift's lips: 1 at most (under the glow), less where its pale emerald would pass
## ScreenTone.SAFE on the screen.
static func rift_peak() -> float:
	return minf(1.0, ScreenTone.linear_peak(Combat.EMETH.lerp(Color.WHITE, RIFT_PALE)))


func _step_rift(dt: float) -> void:
	if _rift_t < 0.0 or _rift == null:
		return
	_rift_t += dt
	var mat := _rift.material_override as ShaderMaterial
	mat.set_shader_parameter(&"opened", clampf(_rift_t / RIFT_RUN, 0.0, 1.0))
	mat.set_shader_parameter(&"fade", clampf((RIFT_TIME - _rift_t) / (RIFT_TIME * 0.6), 0.0, 1.0))
	if _rift_t >= RIFT_TIME:
		_rift.visible = false
		_rift_t = -1.0


# ---------- U-2, the Voragem ----------

func _open_vortex(at: Vector2) -> void:
	if vortex != null:
		vortex.node.queue_free()
	var v := Vortex.new()
	v.at = at
	v.radius = def.vortex_radius(game.boons.stat(&"cast_size_pct", def.tags))
	v.life = def.duration
	v.tick = def.tick
	v.node = _vortex_node(at, v.radius)
	vortex = v
	game.fx.ring(at, v.radius, Combat.EMETH, 0.3, 0.15, true)
	Audio.play(CombatSounds.EVENTS[&"ult_vortex"])


func _step_vortex(dt: float) -> void:
	var v := vortex
	v.life -= dt
	_draw_vortex(v, dt)
	var ticking := false
	v.tick -= dt
	if v.tick <= 0.0:
		v.tick += def.tick
		ticking = true
	game.horde.in_circle(v.at, v.radius, _found)
	for e: Enemy in _found.duplicate():
		if not e.alive:
			continue
		var boss := e.def.behavior == EnemyDef.Behavior.BOSS
		var guardian := not boss and e.def.stun_time <= 0.0
		var share := def.pull_share(boss, guardian, e.armor > 0.0)
		if boss:
			e.slow_t = maxf(e.slow_t, BOSS_SLOW)
		elif share >= 1.0:
			# a common body inside is held as by the circle of light: a wind-up under way is cut once, on entering
			if not v.held.has(e):
				v.held[e] = true
				game.horde.interrupt(e)
			e.stun_t = maxf(e.stun_t, def.tick + 0.05)
		if share > 0.0 and not _bound(e.pos):
			var to := e.pos + def.vortex_pull(e.pos, v.at, v.radius) * share * dt
			e.pos = game.arena.sweep(e.pos, to, e.def.radius) if game.arena else to
		if ticking:
			_hit(e, def.tick_damage, Vector2.ZERO, 0.0, 0.0)
	v.motes -= dt
	if v.motes <= 0.0:
		v.motes = VORTEX_MOTES_EVERY
		var a := float(Engine.get_process_frames()) * 2.39
		var rim := v.at + Vector2.from_angle(a) * v.radius * 0.85
		var inward := (v.at - rim).normalized()
		# in, and along the arms' turn (their angle grows: the tangent that way)
		var way := (inward + Vector2(-sin(a), cos(a)) * VORTEX_MOTE_SWIRL).normalized()
		game.fx.chips(Vector3(rim.x, 0.35, rim.y), Vector3(way.x, 0.05, way.y), VORTEX_MOTE, VORTEX_MOTE_COUNT, 6.0, 0.09, 0.55, 0.25)
	if v.life <= 0.0:
		_implode(v)


## The Voragem's floor (ult_vortex.gdshader): its own quad and material, made when it lands (one at a time).
func _vortex_node(at: Vector2, radius: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE
	mi.mesh = plane
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.extra_cull_margin = radius
	var m := ShaderMaterial.new()
	m.shader = VORTEX_SHADER
	m.render_priority = FLOOR_PRIORITY
	var peaks := vortex_peaks()
	m.set_shader_parameter(&"color", Combat.EMETH)
	m.set_shader_parameter(&"ivory", VORTEX_IVORY)
	m.set_shader_parameter(&"gold", VORTEX_GOLD)
	m.set_shader_parameter(&"veil_peak", peaks.veil)
	m.set_shader_parameter(&"arm_peak", peaks.arm)
	m.set_shader_parameter(&"rim_peak", peaks.rim)
	m.set_shader_parameter(&"veil", VORTEX_VEIL)
	m.set_shader_parameter(&"veil_edge", VORTEX_VEIL_EDGE)
	m.set_shader_parameter(&"radius_m", radius)
	m.set_shader_parameter(&"rim_m", VORTEX_RIM_M)
	m.set_shader_parameter(&"arm_m", VORTEX_ARM_M)
	m.set_shader_parameter(&"arms", VORTEX_ARMS)
	m.set_shader_parameter(&"twist", VORTEX_TWIST)
	m.set_shader_parameter(&"turn", 0.0)
	m.set_shader_parameter(&"fade", 0.0)
	m.set_shader_parameter(&"close", 0.0)
	mi.material_override = m
	mi.position = Vector3(at.x, VORTEX_HEIGHT, at.y)
	add_child(mi)
	return mi


## The Voragem's floor this frame: fading in, its arms turning inward, its rim closing over its last VORTEX_CLOSE.
func _draw_vortex(v: Vortex, dt: float) -> void:
	var m := v.node.material_override as ShaderMaterial
	v.turn += VORTEX_SPIN * dt
	m.set_shader_parameter(&"turn", fposmod(v.turn, TAU))
	m.set_shader_parameter(&"fade", clampf((def.duration - v.life) / VORTEX_FADE_IN, 0.0, 1.0))
	m.set_shader_parameter(&"close", clampf(1.0 - v.life / VORTEX_CLOSE, 0.0, 1.0))


## The brightest channel of each part of the Voragem's floor (veil, arm, rim): 1 at most (under the glow), less where
## its colour would pass ScreenTone.SAFE on the screen.
static func vortex_peaks() -> Dictionary:
	return {"veil": minf(1.0, ScreenTone.linear_peak(Combat.EMETH)), "arm": minf(1.0, ScreenTone.linear_peak(VORTEX_IVORY)),
		"rim": minf(1.0, ScreenTone.linear_peak(VORTEX_GOLD))}


## Inside a standing circle of light: the circle holds, the Voragem does not pull (ultimate_u2_proposals.md section 1).
func _bound(p: Vector2) -> bool:
	for z in game.ground.zones:
		if z.kind == Ground.Kind.BIND and p.distance_to(z.pos) <= z.radius:
			return true
	return false


func _implode(v: Vortex) -> void:
	vortex = null
	v.node.visible = false
	v.node.queue_free()
	game.horde.in_circle(v.at, def.implode_radius, _found)
	for e: Enemy in _found.duplicate():
		var away := (e.pos - v.at).normalized() if e.pos.distance_to(v.at) > 0.01 else Vector2.RIGHT
		_hit(e, def.implode_damage, away, def.knockback, def.implode_stun)
	var fx := game.fx
	fx.ring(v.at, def.implode_radius, Combat.EMETH, 0.25, 0.15, true)
	fx.ring(v.at, def.implode_radius * 1.6, Combat.EMETH, 0.35, 0.15, true)
	fx.burst(&"light", Vector3(v.at.x, 0.6, v.at.y))
	fx.kick((v.at - game.player.pos).normalized() if v.at.distance_to(game.player.pos) > 0.1 else Vector2.DOWN, Combat.KICK_FINISHER)
	fx.shake(2.5)
	Audio.play(CombatSounds.EVENTS[&"ult_implode"])


func _floor_mark(style: GroundLook.Style, shape: GroundLook.Shape, at: Vector2, dir: Vector2, size: float, width: float) -> void:
	if _warn == null:
		_warn = GroundLook.new_node()
		add_child(_warn)
	GroundLook.dress(_warn, style, shape, Combat.EMETH, WARN_STRENGTH, Ground.RIM_METERS, at, dir, size, width, 0.066)
	_warn.visible = true
