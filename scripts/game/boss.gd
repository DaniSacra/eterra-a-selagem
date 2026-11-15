class_name Boss
extends RefCounted
## Morvath, the king who betrayed the light. Three phases; every attack is announced on the floor before it lands.
## 1: sword sequences and a dash. 2 (60%): rings of skeletons and a rain of shadow blades.
## 3 (25%): the dark mist closes the hall, bullet patterns that ask for dodging, and heavy hits stagger him.

signal defeated

enum State { ENTER, CHASE, SLASHES, DASH_WARN, DASH, SUMMON, RAIN, VOLLEY, ROAR, STUNNED, DYING }

const DASH_LENGTH := 16.0
const DASH_TIME := 0.42
const MIST_FROM := 46.0
const MIST_TO := 12.0
const MIST_TIME := 12.0
const MIST_DPS := 3.0
const BOLT_SPEED := 9.0
const SLASH_RANGE := 4.6
const SHADOW := Color(0.75, 0.3, 1.0)

var game: Game
var e: Enemy
var phase := 1
var state := State.ENTER
var center := Vector2.ZERO
var mist: MeshInstance3D
var mist_radius := MIST_FROM
var _t := 0.0
var _step := 0
var _cooldown := 1.0
var _dir := Vector2.DOWN
var _from := Vector2.ZERO
var _stagger := 0
var _stagger_t := 0.0
var _mist_t := 0.0
var _mist_tick := 0.0
var _last := -1
var _rng := RandomNumberGenerator.new()


func setup(g: Game, def: EnemyDef) -> void:
	game = g
	Dev.seed_rng(_rng, 3)
	center = g.arena.door_pos + Vector2(0, 14)
	e = g.horde.spawn(def, g.arena.door_pos + Vector2(0, Arena.STAIRS_DEPTH + def.radius), false)
	e.invulnerable = true
	e.dir = Vector2.DOWN
	e.hp = e.max_hp * Dev.num("boss-hp", 1.0)
	g.combat.enemy_struck.connect(_on_struck)
	g.horde.killed.connect(_on_killed)
	g.fx.burst(&"shadow", Vector3(e.pos.x, 1.0, e.pos.y))
	g.fx.beam(e.pos, SHADOW, 2.0, 14.0, 1.0)


func step(dt: float) -> void:
	if state == State.DYING:
		_step_dying(dt)
		return
	if e == null or not e.alive:
		return
	_t += dt
	_cooldown -= dt
	_stagger_t -= dt
	if _stagger_t <= 0.0:
		_stagger = 0
	_step_mist(dt)
	var p := game.player.pos
	var to := p - e.pos
	var toward := to.normalized() if to.length() > 0.2 else Vector2.DOWN
	if state != State.ENTER and state != State.ROAR:
		var want := BossRules.phase_for(e.hp / e.max_hp)
		if want > phase:
			_change_phase(want)
			return
	match state:
		State.ENTER:
			e.pos += Vector2.DOWN * 3.2 * dt
			_anim(&"walk")
			if _t > 2.4:
				e.invulnerable = false
				_go(State.CHASE)
		State.CHASE:
			e.dir = e.dir.slerp(toward, minf(1.0, dt * 6.0))
			if to.length() > SLASH_RANGE * 0.7:
				e.pos += toward * e.def.speed * (1.0 + 0.15 * (phase - 1)) * dt
			_anim(&"walk")
			if _cooldown <= 0.0 and game.player.alive():
				_choose(to.length())
		State.SLASHES:
			_step_slashes(toward)
		State.DASH_WARN:
			_anim(&"dash_windup")
			if _t >= 0.8:
				_from = e.pos
				_go(State.DASH)
				Audio.play(&"boss_dash")
		State.DASH:
			_anim(&"dash")
			e.pos = _from + _dir * DASH_LENGTH * minf(_t / DASH_TIME, 1.0)
			if int(_t * 30.0) % 2 == 0:
				game.fx.burst(&"shadow", Vector3(e.pos.x, 0.6, e.pos.y))
			if _t >= DASH_TIME:
				_rest(1.1)
		State.SUMMON:
			_anim(&"summon")
			if _t >= 1.1 and _step == 0:
				_step = 1
				var skeleton := game.horde.def(&"skeleton")
				var n := _summon_count()
				for k in n:
					var at := game.arena.resolve(p + Vector2.from_angle(TAU * k / n) * 7.0, 0.5)
					game.horde.spawn(skeleton, at, true)
					game.fx.burst(&"shadow", Vector3(at.x, 0.4, at.y))
				Audio.play(&"summon")
			if _t >= 2.2:
				_rest(1.2)
		State.RAIN:
			_anim(&"rain")
			if _step < 3 and _t >= _step * 0.7:
				_step += 1
				game.ground.add_warning(p, 2.2, 0.9, e.def.attack_damage, e.def.magic_color)
				for k in 4 + phase:
					var at := p + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(3.0, 11.0)
					game.ground.add_warning(at, 2.0, _rng.randf_range(0.9, 1.5), e.def.attack_damage, e.def.magic_color)
				Audio.play(&"rain")
			if _t >= 2.6:
				_rest(1.0)
		State.VOLLEY:
			_step_volley(toward)
		State.ROAR:
			_anim(&"roar")
			if _t >= 1.6:
				e.invulnerable = false
				_rest(0.6)
		State.STUNNED:
			_anim(&"stunned")
			e.stun_t = 0.1
			if _t >= 2.6:
				_stagger = 0
				e.armor = e.max_armor
				_rest(0.5)
	e.pos = game.arena.resolve(e.pos, e.def.radius)


## Picks the next attack: never the same twice in a row, and only what the phase allows.
func _choose(dist: float) -> void:
	var options: Array[State] = [State.SLASHES, State.DASH_WARN]
	if phase >= 2:
		options.append(State.RAIN)
		if _summon_count() > 0:
			options.append(State.SUMMON)
	if phase >= 3:
		options.append(State.VOLLEY)
		options.append(State.VOLLEY)
	if dist > 12.0:
		options.erase(State.SLASHES)
	options.erase(_last as State)
	var pick: State = options[_rng.randi() % options.size()]
	_last = pick
	_go(pick)
	if pick == State.DASH_WARN:
		_dir = (game.player.pos - e.pos).normalized()
		e.dir = _dir
		game.ground.add_line_warning(e.pos, _dir, DASH_LENGTH, 2.8, 0.8, e.def.attack_damage * 1.2)


## Skeletons a summon raises now: never past his reinforcements' ceiling of the phase (StageDef.boss_adds) nor the
## fight's (Horde.room_for). The endless hall (--horde) keeps its old limit of 30 standing.
func _summon_count() -> int:
	var want := BossRules.summon_want(phase)
	if game.rooms == null:
		return want if game.horde.count() < 30 else 0
	var adds := game.horde.count() - (1 if e.alive else 0)
	return mini(BossRules.summon_count(phase, adds, game.rooms.stage.boss_adds), game.horde.room_for(want))


## Three cuts in a row: each one shows its arc, steps in and lands.
func _step_slashes(toward: Vector2) -> void:
	var windup := 0.6 * (0.85 if phase > 1 else 1.0)
	var beat := windup + 0.3
	var local := _t - _step * beat
	if _step >= 3:
		_rest(0.9)
		return
	var reach := SLASH_RANGE + _step * 0.8
	var width := 120.0 + _step * 30.0
	if local < 0.05 and e.memo != _step + 1:
		e.memo = _step + 1
		_dir = toward
		e.dir = toward
		game.ground.add_arc_warning(e.pos, _dir, reach, width, windup, e.def.attack_damage)
		e.anim = [&"slash1", &"slash2", &"slash3"][_step]
		e.anim_t = 0.0
	if local >= windup and e.memo == _step + 1:
		e.memo = -1
		game.fx.slash(e.pos, _dir, reach, width, SHADOW, 0.22, _step % 2 == 1, 1.6)
		game.fx.shake(1.5)
		Audio.play(&"boss_slash")
	if local >= beat:
		_step += 1
		e.pos += toward * 1.2


## Bullet patterns: rings that turn, then a fan aimed at the paladin. Announced by the raised arm.
func _step_volley(toward: Vector2) -> void:
	_anim(&"volley")
	if _t < 0.7:
		return
	var wave := int((_t - 0.7) / 0.55)
	if wave > _step and _step < 5:
		_step = wave
		var dirs := BossRules.ring(14, _step * 0.22) if _step % 2 == 1 else BossRules.fan(toward, 7, 1.5)
		for d in dirs:
			game.projectiles.fire(Projectiles.Kind.ORB, e.pos + d * 1.5, d, BOLT_SPEED if _step % 2 == 1 else BOLT_SPEED * 1.35, e.def.attack_damage * 0.8, 0.45, 6.0)
		game.fx.burst(&"shadow", Vector3(e.pos.x, 2.0, e.pos.y))
		Audio.play(&"bolt")
	if _t >= 0.7 + 0.55 * 5.5:
		_rest(1.3)


func _change_phase(next: int) -> void:
	phase = next
	e.invulnerable = true
	_go(State.ROAR)
	game.fx.shake(5.0)
	game.fx.hit_stop(90)
	game.fx.kick_split(1.0)
	game.fx.impact_frame()
	game.fx.ring(e.pos, 9.0, SHADOW, 0.6)
	game.fx.beam(e.pos, SHADOW, 2.5, 18.0, 0.9)
	game.fx.burst(&"shadow", Vector3(e.pos.x, 2.0, e.pos.y))
	game.projectiles.clear_hostile()
	game.ground.clear_warnings()
	game.hud.show_notice(T.t("boss_phase_%d" % next), 3.0)
	Audio.play(&"roar")
	# the roar throws the paladin back, out of the king's reach
	var away := (game.player.pos - e.pos).normalized()
	game.player.place(game.player.pos + away * 4.0)
	if next == 3:
		center = e.pos
		mist = _make_mist()
		game.add_child(mist)


func _step_mist(dt: float) -> void:
	if mist == null:
		return
	_mist_t += dt
	mist_radius = BossRules.mist_radius(_mist_t, MIST_FROM, MIST_TO, MIST_TIME)
	(mist.material_override as ShaderMaterial).set_shader_parameter(&"radius", mist_radius)
	if e.pos.distance_to(center) > mist_radius - 3.0:
		e.pos = e.pos.move_toward(center, 6.0 * dt)
	_mist_tick -= dt
	if _mist_tick <= 0.0:
		_mist_tick = 0.5
		if game.player.pos.distance_to(center) > mist_radius:
			game.player.hurt(MIST_DPS * 0.5, game.player.pos * 2.0 - center)


## His armor broke: he staggers, and stands up armored again.
func break_armor() -> void:
	if state == State.STUNNED or state == State.DYING:
		return
	_go(State.STUNNED)
	game.fx.shake(4.0)
	game.fx.burst(&"light", Vector3(e.pos.x, 2.5, e.pos.y))
	game.fx.word(Vector3(e.pos.x, 5.0, e.pos.y), T.t(&"word_stagger"), Combat.LIGHT)
	Audio.play(&"stagger")


## In the last phase the paladin's heavy blows stagger the king.
func _on_struck(target: Enemy, tags: Array[StringName], _damage: float) -> void:
	if target != e or phase < 3 or state == State.STUNNED or state == State.ROAR or not tags.has(&"heavy") or tags.has(&"mark"):
		return
	_stagger += 1
	_stagger_t = BossRules.STAGGER_FORGET
	if _stagger >= BossRules.STAGGER_HITS:
		_go(State.STUNNED)
		game.fx.shake(4.0)
		game.fx.burst(&"light", Vector3(e.pos.x, 2.5, e.pos.y))
		game.fx.word(Vector3(e.pos.x, 5.0, e.pos.y), T.t(&"word_stagger"), Combat.LIGHT)
		Audio.play(&"stagger")


func _on_killed(dead: Enemy) -> void:
	if dead != e:
		return
	state = State.DYING
	_t = 0.0
	game.projectiles.clear_hostile()
	game.ground.clear()
	game.horde.clear_crowd.call_deferred()
	game.fx.hit_stop(120)
	game.fx.slow_mo(0.15, 1.0, 0.8, 1.2, 1.0)
	game.fx.shake(6.0)
	game.fx.kick_split(1.0)
	game.fx.impact_frame()
	Audio.play(&"boss_down")
	Audio.music(&"")


func _step_dying(dt: float) -> void:
	_t += dt
	if mist:
		mist_radius += 30.0 * dt
		(mist.material_override as ShaderMaterial).set_shader_parameter(&"radius", mist_radius)
	if _t > 0.2 and int(_t * 6.0) != int((_t - dt) * 6.0):
		game.fx.burst(&"light", Vector3(e.pos.x + _rng.randf_range(-1.5, 1.5), _rng.randf_range(0.5, 4.0), e.pos.y + _rng.randf_range(-1.5, 1.5)))
	if _t >= 2.4:
		if mist:
			mist.queue_free()
		center = e.pos
		state = State.ENTER
		game.boss = null
		defeated.emit()


func _go(next: State) -> void:
	state = next
	_t = 0.0
	_step = 0
	e.memo = 0


func _rest(cooldown: float) -> void:
	_cooldown = cooldown * (1.0 - 0.12 * (phase - 1))
	_go(State.CHASE)


func _anim(anim: StringName) -> void:
	if e.anim != anim:
		e.anim = anim
		e.anim_t = 0.0


## The dark mist of the last phase: a huge dark disc with a hole of light around the fight.
func _make_mist() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(240, 240)
	mi.mesh = plane
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
uniform vec2 center;
uniform float radius = 40.0;
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	float d = distance(wp.xz, center);
	float edge = smoothstep(radius - 0.6, radius + 2.5, d);
	float glow = exp(-abs(d - radius) * 1.5);
	ALBEDO = mix(vec3(0.6, 0.25, 1.0) * glow * 2.0, vec3(0.04, 0.0, 0.07), edge);
	ALPHA = clamp(edge * 0.9 + glow * 0.6, 0.0, 0.95);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter(&"center", center)
	mat.set_shader_parameter(&"radius", MIST_FROM)
	mi.material_override = mat
	mi.position.y = 0.35
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi
