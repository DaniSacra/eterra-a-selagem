class_name Ultimates
extends Node3D
## The hero's ultimate in play (D-54, E2-08 and E2-10; docs/design/warrior_spec.md 3.2, ultimate_u2_proposals.md
## section 1 and proposal A). One per descent (Game.ultimate, from the save or --ultimate=id), charged by the Magia
## spent on Omegas and (T5) the damage dealt and the life lost (UltCharge), let go by the action "ultimate" when full. The Player plays the protected gesture
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
const VORTEX_VEIL := 0.15  # V-10 (it was 0.3)
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
	## The Tempestade: it is one (its tick lays Selos and its end detonates them).
	var storm := false

var game: Game
var def: UltDef
var charge := UltCharge.new()
## Times let go and damage dealt in this run (RESULT ultimate).
var uses := 0
var damage := 0.0
## The same in Morvath's room only (E6: does it charge there?).
var boss_uses := 0
var boss_damage := 0.0
## Where the charge came from in this run (RESULT ultimate.charged: magick, damage, hurt; T5).
var charged := {"magick": 0.0, "damage": 0.0, "hurt": 0.0}
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
	game.player.was_hurt.connect(_on_hurt)


## The ultimate of this descent (null: none). The charge starts empty.
func equip(u: UltDef) -> void:
	def = u
	charge = UltCharge.new(u.charge if u else 60.0)
	# (only what is spent and dealt from now on counts)
	charge.feed(game.player.magick.spent)
	charge.feed_from(&"damage", _dealt(), 0.0)
	game.player.ult = u
	game.player.ult_ready = false


func step(dt: float) -> void:
	var p := game.player
	if def == null:
		p.ult_ready = false
		return
	var rate := game.boons.stat(&"ult_charge_pct")
	var v := charge.value
	charge.feed(p.magick.spent, rate)
	charged.magick += charge.value - v
	v = charge.value
	charge.feed_from(&"damage", _dealt(), def.damage_charge, rate)
	charged.damage += charge.value - v
	p.ult_ready = charge.ready()
	if _warn != null and _warn.visible:
		GroundLook.put(_warn.material_override as ShaderMaterial, &"progress", p.ult_progress())
		if p.state != Player.State.ULT:
			_warn.visible = false
	_step_rift(dt)
	if vortex != null:
		if vortex.storm:
			_step_storm(dt)
		else:
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


## The damage the hero dealt so far in the run, without the ultimate's own hits (they never charge the next one).
func _dealt() -> float:
	if game.horde == null:
		return 0.0
	return game.horde.dealt.total() - float(game.horde.dealt.by.get("ultimate", 0.0))


## Life lost charges it too (UltDef.hurt_charge a point).
func _on_hurt(amount: float) -> void:
	if def == null:
		return
	var v := charge.value
	charge.add(amount * def.hurt_charge, game.boons.stat(&"ult_charge_pct"))
	charged.hurt += charge.value - v


func stats() -> Dictionary:
	return {"id": String(def.id) if def else "", "uses": uses, "damage": int(damage), "charge": snappedf(charge.value, 0.1),
		"boss_uses": boss_uses, "boss_damage": int(boss_damage),
		"charged": {"magick": roundi(charged.magick), "damage": roundi(charged.damage), "hurt": roundi(charged.hurt)}}


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
			# V-09: the heavy snap of the contact (V-05), never a 4-point star
			game.fx.contact(Vector3(e.pos.x, 1.0 + e.y, e.pos.y), Vector3(dir.x, 0, dir.y), Combat.EMETH, true)
		_hit(e, amount, dir, def.knockback, def.stun)
	_show_rift(origin, dir)
	var fx := game.fx
	fx.kick(dir, Combat.KICK_FINISHER)
	fx.shake(3.0)
	fx.buzz(Combat.RUMBLE_OMEGA.x, Combat.RUMBLE_OMEGA.y, Combat.RUMBLE_OMEGA.z)
	for k in 5:
		var at := origin + dir * def.length * (k + 0.5) / 5.0
		fx.burst(&"dust", Vector3(at.x, 0.2, at.y))
	_spikes(origin, dir)
	Audio.play(CombatSounds.EVENTS[&"ult_cleave"])
	if struck > 0:
		var k := Feel.live().hit_stop_scale
		fx.blow_stop(STOP_WAIT_MS * k, STOP_SLOW_MS * k)
		Audio.play(CombatSounds.EVENTS[&"hit_heavy"])
		var m := CombatSounds.material(CombatSounds.loudest(mats))
		if m != &"":
			Audio.play(m)


## V-09: crystal spikes break out of the rift, CLEAVE_SPIKES of them in two alternating rows along its axis, leaning out
## CLEAVE_LEAN degrees, CLEAVE_SPIKE_TALL m, from the paladin to the far end over CLEAVE_SPIKE_SPAN s (Fx.crystal_spike).
const CLEAVE_SPIKES := 10
const CLEAVE_LEAN := Vector2(15.0, 30.0)
const CLEAVE_SPIKE_TALL := Vector2(1.2, 2.4)
const CLEAVE_SPIKE_SPAN := 0.12
const CLEAVE_SPIKE_ROW := 0.45


func _spikes(origin: Vector2, dir: Vector2) -> void:
	var side := Vector2(-dir.y, dir.x)
	for k in CLEAVE_SPIKES:
		var along := (k + 0.6) / CLEAVE_SPIKES
		var row := 1.0 if k % 2 == 0 else -1.0
		var at := origin + dir * def.length * along + side * row * CLEAVE_SPIKE_ROW
		var out := Vector3(side.x * row, 0.0, side.y * row)
		# their scatter from k only (never a random generator: the run stays the same with the same seed)
		var h1 := fposmod(sin(k * 12.9898) * 43758.5453, 1.0)
		var h2 := fposmod(sin(k * 39.3468 + 1.7) * 24634.6345, 1.0)
		var tilt := deg_to_rad(lerpf(CLEAVE_LEAN.x, CLEAVE_LEAN.y, h1))
		var axis := out.cross(Vector3.UP).normalized()
		var lean := Basis(axis, -tilt) if axis.length_squared() > 0.0 else Basis()
		var tall := lerpf(CLEAVE_SPIKE_TALL.x, CLEAVE_SPIKE_TALL.y, h2) * (0.75 + 0.25 * sin(along * PI))
		game.fx.crystal_spike(Vector3(at.x, 0.0, at.y), tall, lean, CLEAVE_SPIKE_SPAN * along, Combat.EMETH)


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
	v.storm = def.kind == UltDef.Kind.STORM
	v.at = at
	v.radius = def.vortex_radius(game.boons.stat(&"cast_size_pct", def.tags))
	v.life = def.duration
	v.tick = def.tick
	v.node = _vortex_node(at, v.radius, _color())
	vortex = v
	game.fx.ring(at, v.radius, _color(), 0.3, 0.15, true)
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
func _vortex_node(at: Vector2, radius: float, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE
	mi.mesh = plane
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.extra_cull_margin = radius
	var m := ShaderMaterial.new()
	m.shader = VORTEX_SHADER
	m.render_priority = FLOOR_PRIORITY
	var peaks := vortex_peaks(color)
	m.set_shader_parameter(&"color", color)
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
static func vortex_peaks(color: Color = Combat.EMETH) -> Dictionary:
	return {"veil": minf(1.0, ScreenTone.linear_peak(color)), "arm": minf(1.0, ScreenTone.linear_peak(VORTEX_IVORY)),
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


# ---------- the Maga's Tempestade dos Selos ----------

## The ultimate's colour: the Emeth's emerald for the Warrior's, amber for the Maga's Tempestade.
func _color() -> Color:
	return Arcane.AMBER if def.kind == UltDef.Kind.STORM else Combat.EMETH


## Every `tick` seconds each enemy inside takes the tick and a Selo (its clock restarts); at the end every Selo inside
## detonates (UltDef.storm_share: elites half, guardians a quarter, Morvath the ticks only and keeps his Selo).
func _step_storm(dt: float) -> void:
	var v := vortex
	v.life -= dt
	_draw_vortex(v, dt)
	v.tick -= dt
	var ticking := false
	if v.tick <= 0.0:
		v.tick += def.tick
		ticking = true
	if ticking:
		game.horde.in_circle(v.at, v.radius, _found)
		for e: Enemy in _found.duplicate():
			if not e.alive or e.invulnerable:
				continue
			var boss := e.def.behavior == EnemyDef.Behavior.BOSS
			if game.arcane.lay(e):
				game.arcane.tally.storm_seals += 1
			_hit(e, def.tick_damage * def.storm_share(boss, not boss and e.def.stun_time <= 0.0, e.def.elite, false), Vector2.ZERO, 0.0, 0.0)
	if v.life <= 0.0:
		_detonate_storm(v)


func _detonate_storm(v: Vortex) -> void:
	vortex = null
	v.node.visible = false
	v.node.queue_free()
	game.horde.in_circle(v.at, v.radius, _found)
	var n := 0
	for e: Enemy in _found.duplicate():
		var boss := e.def.behavior == EnemyDef.Behavior.BOSS
		if boss or not e.alive or not game.arcane.detonate(e):
			continue
		n += 1
		var away := (e.pos - v.at).normalized() if e.pos.distance_to(v.at) > 0.01 else Vector2.RIGHT
		_hit(e, def.detonate_damage * def.storm_share(false, e.def.stun_time <= 0.0, e.def.elite, true), away, def.knockback, 0.0)
	game.arcane.resonance.add(mini(n, game.hero.arcane.storm_resonance))
	var fx := game.fx
	fx.ring(v.at, v.radius, Arcane.AMBER, 0.3, 0.15, true)
	fx.ring(v.at, v.radius * 0.6, Arcane.IVORY, 0.25)
	fx.burst(&"fire", Vector3(v.at.x, 0.6, v.at.y))
	fx.shake(2.5)
	Audio.play(CombatSounds.EVENTS[&"ult_implode"])


func _floor_mark(style: GroundLook.Style, shape: GroundLook.Shape, at: Vector2, dir: Vector2, size: float, width: float) -> void:
	if _warn == null:
		_warn = GroundLook.new_node()
		add_child(_warn)
	GroundLook.dress(_warn, style, shape, _color(), WARN_STRENGTH, Ground.RIM_METERS, at, dir, size, width, 0.066)
	_warn.visible = true
