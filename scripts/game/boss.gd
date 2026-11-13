class_name Boss
extends RefCounted
## Morvath, the king who betrayed the light. Three phases; every attack is announced on the floor before it lands.
## 1: sword sequences and a dash. 2 (60%): rings of skeletons and a rain of shadow blades.
## 3 (25%): the dark mist closes the arena, bullet patterns that ask for dodging, and heavy hits stagger him.

signal defeated

enum State { ENTER, CHASE, SLASHES, DASH_WARN, DASH, SUMMON, RAIN, VOLLEY, ROAR, STUNNED, DYING }

const DASH_LENGTH := 170.0
const DASH_TIME := 0.32
const MIST_FROM := 420.0
const MIST_TO := 105.0
const MIST_TIME := 12.0
const MIST_DPS := 7.0
const BOLT_SPEED := 62.0

var game: Game
var e: Enemy
var phase := 1
var state := State.ENTER
var center := Vector2.ZERO
var mist: Mist
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
var _corpse: AnimatedSprite2D
var _rng := RandomNumberGenerator.new()


func setup(g: Game, def: EnemyDef) -> void:
	game = g
	_rng.randomize()
	center = g.arena.door_pos + Vector2(0, 150)
	Art.add_variant(&"morvath", &"wrath", {"#72308e": "#40145a", "#a84ad8": "#72308e", "#40145a": "#3a1448", "#e86a7a": "#fff6c0"})
	e = g.enemies.spawn(def, g.arena.door_pos + Vector2(0, 14))
	e.invulnerable = true
	e.dir = Vector2.DOWN
	e.hp = e.max_hp * Dev.num("boss-hp", 1.0)
	g.combat.enemy_struck.connect(_on_struck)
	g.enemies.killed.connect(_on_killed)
	g.fx.burst(&"shadow", e.pos)


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
	var p := game.player.position
	var to := p - e.pos
	var toward := to.normalized() if to.length() > 0.5 else Vector2.DOWN
	if state != State.ENTER and state != State.ROAR:
		var want := BossRules.phase_for(e.hp / e.max_hp)
		if want > phase:
			_change_phase(want)
			return
	match state:
		State.ENTER:
			e.pos += Vector2.DOWN * 34.0 * dt
			_anim(&"walk")
			if _t > 2.2:
				e.invulnerable = false
				_go(State.CHASE)
		State.CHASE:
			e.dir = toward
			if to.length() > e.def.attack_range * 0.7:
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
			if _t >= DASH_TIME:
				_rest(1.1)
		State.SUMMON:
			_anim(&"summon")
			if _t >= 1.0:
				var skeleton := game.enemies.def(&"skeleton")
				var n := 8 + phase * 2
				for k in n:
					var at := game.arena.resolve(p + Vector2.from_angle(TAU * k / n) * 62.0, 5.0)
					game.enemies.spawn(skeleton, at, true)
					game.fx.burst(&"shadow", at)
				Audio.play(&"summon")
				_rest(1.4)
		State.RAIN:
			_anim(&"rain")
			if _step < 3 and _t >= _step * 0.7:
				_step += 1
				game.ground.add_warning(p, 17.0, 0.9, e.def.attack_damage)
				for k in 4 + phase:
					var at := p + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(24.0, 86.0)
					game.ground.add_warning(at, 15.0, _rng.randf_range(0.9, 1.5), e.def.attack_damage)
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
				_rest(0.5)
	e.pos = game.arena.resolve(e.pos, e.def.radius)


## Picks the next attack: never the same twice in a row, and only what the phase allows.
func _choose(dist: float) -> void:
	var options: Array[State] = [State.SLASHES, State.DASH_WARN]
	if phase >= 2:
		options.append(State.RAIN)
		if game.enemies.count() < 26:
			options.append(State.SUMMON)
	if phase >= 3:
		options.append(State.VOLLEY)
		options.append(State.VOLLEY)
	if dist > 90.0:
		options.erase(State.SLASHES)
	options.erase(_last as State)
	var pick: State = options[_rng.randi() % options.size()]
	_last = pick
	_go(pick)
	if pick == State.DASH_WARN:
		_dir = (game.player.position - e.pos).normalized()
		e.dir = _dir
		game.ground.add_line_warning(e.pos, _dir, DASH_LENGTH, 20.0, 0.8, e.def.attack_damage * 1.2)


## Three cuts in a row: each one shows its arc, steps in and lands.
func _step_slashes(toward: Vector2) -> void:
	var windup := e.def.attack_windup * (0.85 if phase > 1 else 1.0)
	var beat := windup + 0.28
	var local := _t - _step * beat
	if _step >= 3:
		_rest(0.9)
		return
	if local < 0.05 and e.memo != _step + 1:
		e.memo = _step + 1
		_dir = toward
		e.dir = toward
		game.ground.add_arc_warning(e.pos, _dir, e.def.attack_range + _step * 6.0, 120.0 + _step * 30.0, windup, e.def.attack_damage)
		e.anim = [&"slash1", &"slash2", &"slash3"][_step]
		e.anim_t = 0.0
	if local >= windup and e.memo == _step + 1:
		e.memo = -1
		game.fx.slash(e.pos + Vector2(0, -14), _dir, e.def.attack_range + _step * 6.0, 120.0 + _step * 30.0, &"misterio", 0.2, _step % 2 == 1)
		game.fx.shake(1.5)
		Audio.play(&"boss_slash")
	if local >= beat:
		_step += 1
		e.pos += toward * 10.0


## Bullet patterns: rings that turn, then a fan aimed at the paladin. Announced by the raised arm.
func _step_volley(toward: Vector2) -> void:
	_anim(&"volley")
	var from := e.pos + Vector2(0, -16)
	if _t < 0.7:
		return
	var wave := int((_t - 0.7) / 0.55)
	if wave > _step and _step < 5:
		_step = wave
		var dirs := BossRules.ring(14, _step * 0.22) if _step % 2 == 1 else BossRules.fan(toward, 7, 1.5)
		for d in dirs:
			game.projectiles.fire(Projectiles.Kind.BOLT, from, d, BOLT_SPEED if _step % 2 == 1 else BOLT_SPEED * 1.35, e.def.attack_damage * 0.8, 5.0)
		game.fx.burst(&"shadow", from)
		Audio.play(&"bolt")
	if _t >= 0.7 + 0.55 * 5.5:
		_rest(1.3)


func _change_phase(next: int) -> void:
	phase = next
	e.invulnerable = true
	_go(State.ROAR)
	game.fx.shake(5.0)
	game.fx.hit_stop(80)
	game.fx.ring(e.pos, 70.0, &"misterio", 0.5)
	game.fx.burst(&"shadow", e.pos + Vector2(0, -16))
	game.projectiles.clear_hostile()
	game.hud.show_notice(T.t("boss_phase_%d" % next), 3.0)
	Audio.play(&"roar")
	# the roar throws the paladin back, out of the king's reach
	var away := (game.player.position - e.pos).normalized()
	game.player.position = game.arena.resolve(game.player.position + away * 26.0, Player.RADIUS)
	if next == 3:
		e.variant = &"wrath"
		center = e.pos
		mist = Mist.new()
		mist.center = center
		mist.radius = MIST_FROM
		game.fx.get_parent().add_child(mist)
		game.fx.get_parent().move_child(mist, 0)


func _step_mist(dt: float) -> void:
	if mist == null:
		return
	_mist_t += dt
	mist.radius = BossRules.mist_radius(_mist_t, MIST_FROM, MIST_TO, MIST_TIME)
	mist.queue_redraw()
	if e.pos.distance_to(center) > mist.radius - 20.0:
		e.pos = e.pos.move_toward(center, 60.0 * dt)
	_mist_tick -= dt
	if _mist_tick <= 0.0:
		_mist_tick = 0.5
		if game.player.position.distance_to(center) > mist.radius:
			game.player.hurt(MIST_DPS * 0.5, game.player.position * 2.0 - center)


## In the last phase the paladin's heavy blows stagger the king.
func _on_struck(target: Enemy, tags: Array[StringName], _damage: float) -> void:
	if target != e or phase < 3 or state == State.STUNNED or state == State.ROAR or not tags.has(&"heavy") or tags.has(&"mark"):
		return
	_stagger += 1
	_stagger_t = BossRules.STAGGER_FORGET
	if _stagger >= BossRules.STAGGER_HITS:
		_go(State.STUNNED)
		game.fx.shake(4.0)
		game.fx.burst(&"light", e.pos + Vector2(0, -20))
		game.fx.word(e.pos + Vector2(0, -44), T.t(&"word_stagger"), &"luz")
		Audio.play(&"stagger")


func _on_killed(dead: Enemy) -> void:
	if dead != e:
		return
	state = State.DYING
	_t = 0.0
	game.projectiles.clear_hostile()
	game.ground.zones.clear()
	game.enemies.clear_crowd.call_deferred()
	game.fx.hit_stop(80)
	game.fx.shake(6.0)
	_corpse = Art.animated(&"morvath")
	_corpse.position = e.pos
	_corpse.flip_h = e.dir.x < 0.0
	_corpse.play(&"death")
	game.world.add_child(_corpse)
	Audio.play(&"boss_down")
	Audio.music(&"")


func _step_dying(dt: float) -> void:
	_t += dt
	if mist:
		mist.radius += 260.0 * dt
		mist.queue_redraw()
	if _t > 0.2 and int(_t * 6.0) != int((_t - dt) * 6.0):
		game.fx.burst(&"light", _corpse.position + Vector2(_rng.randf_range(-10, 10), _rng.randf_range(-36, -4)))
	if _t >= 2.2:
		var at := _corpse.position
		_corpse.queue_free()
		if mist:
			mist.queue_free()
		center = at
		state = State.ENTER
		e = null
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


## The dark mist of the last phase: everything outside the circle is swallowed.
class Mist:
	extends Node2D
	var center := Vector2.ZERO
	var radius := 400.0

	func _draw() -> void:
		var thick := 700.0
		draw_arc(center, radius + thick * 0.5, 0.0, TAU, 72, Color(Palette.c(&"misterio", 4), 0.88), thick)
		draw_arc(center, radius + 3.0, 0.0, TAU, 72, Color(Palette.c(&"misterio", 3), 0.9), 6.0)
		draw_arc(center, radius, 0.0, TAU, 72, Palette.c(&"misterio", 1), 1.0)
