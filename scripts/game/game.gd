class_name Game
extends Node2D
## One run in the catacombs. Owns the clock: every system is stepped from here,
## so hit stop, pause and the level-up screen are just "do not step".

enum Mode { PLAY, CHOICE, PAUSE, OVER, ENDING }

const VIEW := Vector2(320, 180)
const WAVES := "res://data/waves/catacombs.tres"
const FOUNTAIN_HEAL := 0.4
## Each new level, the gift arrives with a little of the companions' strength.
const LEVEL_HEAL := 0.15
const SPAWN_MIN := 190.0
const SPAWN_MAX := 240.0

var arena: Arena
var world: Node2D
var ground: Ground
var orbs: Orbs
var player: Player
var enemies: EnemySystem
var projectiles: Projectiles
var combat: Combat
var boons: BoonState
var director: WaveDirector
var boss: Boss
var fx: Fx
var hud: Hud
var ui: CanvasLayer
var camera: Camera2D
var bot: Bot
var mode := Mode.PLAY
var time := 0.0
var level := 1
var xp := 0
var kills := 0
var fast := 1.0
## Smoothed cost of one simulation step, in milliseconds (performance budget: 300 enemies on a mid phone).
var step_ms := 0.0
var _pending_levels := 0
## Where Morvath fell: the tomb of the final scene is sealed there.
var boss_fell_at := Vector2.ZERO
## When set, the camera looks here instead of at the paladin (the final scene).
var focus: Variant = null
var _screen: Control
var _boss_ref: Boss
var boss_center := Vector2.ZERO
var _fountain: AnimatedSprite2D
var _fountain_used := false
var _cam_pos := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _found: Array[Enemy] = []


func _ready() -> void:
	_rng.randomize()
	fast = Dev.num("fast", 1.0)
	world = Node2D.new()
	world.y_sort_enabled = true
	arena = Arena.new()
	add_child(arena)
	ground = Ground.new()
	ground.z_index = -5
	add_child(ground)
	orbs = Orbs.new()
	orbs.z_index = -4
	add_child(orbs)
	add_child(world)
	arena.build(world)

	var fx_layer := CanvasLayer.new()
	fx_layer.layer = 1
	fx_layer.follow_viewport_enabled = true
	add_child(fx_layer)
	projectiles = Projectiles.new()
	fx_layer.add_child(projectiles)
	fx = Fx.new()
	fx_layer.add_child(fx)

	player = Player.new()
	player.arena = arena
	player.fx = fx
	player.position = Arena.SIZE * 0.5
	world.add_child(player)

	enemies = EnemySystem.new()
	enemies.world = world
	enemies.arena = arena
	enemies.fx = fx
	enemies.ground = ground
	enemies.projectiles = projectiles
	add_child(enemies)

	boons = BoonState.new(BoonState.load_catalog())
	combat = Combat.new()
	combat.enemies = enemies
	combat.fx = fx
	combat.ground = ground
	combat.projectiles = projectiles
	combat.boons = boons
	director = WaveDirector.new(load(WAVES), _rng)

	ground.enemies = enemies
	ground.player = player
	ground.fx = fx
	ground.on_zone_hit = combat.on_zone_hit
	projectiles.enemies = enemies
	projectiles.player = player
	fx.enemies = enemies

	player.struck.connect(combat.strike)
	player.was_hurt.connect(combat.drop_combo)
	player.died.connect(_on_player_died)
	player.dodged.connect(_on_dodged)
	player.shield_broke.connect(_on_shield_broke)
	projectiles.wave_hit.connect(combat.on_wave_hit)
	for source: Object in [enemies, ground, projectiles]:
		source.hit_player.connect(_on_hit_player)
	enemies.killed.connect(_on_killed)

	camera = Camera2D.new()
	add_child(camera)
	camera.make_current()
	_cam_pos = player.position

	ui = CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	hud = Hud.new()
	hud.game = self
	ui.add_child(hud)
	player.move_shown.connect(func(node: ComboNode) -> void:
		hud.show_move(node, combat.family_of(node.tags))
		if SaveData.discover_move(Save.data, String(node.id)):
			Save.write())
	combat.combo_changed.connect(hud.on_combo)
	Audio.music(&"catacombs")

	if Dev.has("bot"):
		bot = Bot.new()
		Controls.virtual = bot.pad
	if Dev.has("start"):
		_dev_start(Dev.arg("start"))
	if Dev.has("boons"):
		for i in int(Dev.num("boons", 0)):
			var offers := boons.offers(_rng, 1)
			if not offers.is_empty():
				_take(offers[0])
	if Dev.has("stress"):
		player.max_hp = 99999.0
		player.hp = 99999.0
		for i in int(Dev.num("stress", 300)):
			enemies.spawn(enemies.def([&"skeleton", &"skeleton", &"archer", &"wolf", &"hooded"][i % 5]), _spawn_point() * 0.5 + player.position * 0.5)
	if Dev.has("shot"):
		_shot.call_deferred()
	if Dev.has("smoke"):
		_smoke.call_deferred()


func _exit_tree() -> void:
	Controls.virtual = null


func _process(delta: float) -> void:
	var shake := fx.tick(delta)
	fx.animate(delta)
	if bot:
		bot.step(delta, self)
	if mode == Mode.PLAY or mode == Mode.OVER or mode == Mode.ENDING:
		if fx.stop_left <= 0.0:
			var t0 := Time.get_ticks_usec()
			_step(minf(delta, 0.05))
			step_ms = lerpf(step_ms, (Time.get_ticks_usec() - t0) / 1000.0, 0.05)
	if mode == Mode.PLAY and Controls.pressed(&"pause"):
		_open_pause()
	_follow(delta, shake)


func _step(dt: float) -> void:
	if mode == Mode.PLAY:
		_step_waves(dt)
	time = director.time
	if mode == Mode.ENDING:
		player.rest()
	else:
		player.step(dt, Controls.aim(_screen_pos(player.position + Vector2(0, -8)), get_viewport().get_mouse_position()))
	enemies.target = player.position
	enemies.target_alive = player.alive() and mode == Mode.PLAY
	enemies.step(dt)
	if boss:
		boss.step(dt)
	projectiles.step(dt)
	ground.step(dt)
	combat.step(dt)
	var got := orbs.step(dt, player.position)
	if got > 0:
		_gain_xp(got)
	_step_fountain()
	if _pending_levels > 0 and mode == Mode.PLAY and player.alive():
		_open_choice()


# ---------- waves ----------

func _step_waves(dt: float) -> void:
	for id in director.step(dt * fast, enemies.count()):
		enemies.spawn(enemies.def(id), _spawn_point(), false)
	enemies.hp_scale = director.hp_scale()
	enemies.damage_scale = director.damage_scale()
	for event in director.due_events():
		match event.kind:
			WaveEvent.Kind.ELITE:
				_spawn_elite(event.enemy)
			WaveEvent.Kind.FOUNTAIN:
				_spawn_fountain()
			WaveEvent.Kind.BOSS:
				_start_boss(event.enemy)


## A point in the hall just outside what the camera shows.
func _spawn_point() -> Vector2:
	var at := player.position
	for attempt in 8:
		at = player.position + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(SPAWN_MIN, SPAWN_MAX)
		if at.x > 8 and at.y > 8 and at.x < Arena.SIZE.x - 8 and at.y < Arena.SIZE.y - 8:
			return at
	return arena.resolve(at, 6.0)


func _spawn_elite(id: StringName) -> void:
	var d := enemies.def(id)
	var at := _spawn_point()
	enemies.spawn(d, at)
	fx.burst(&"shadow", at)
	hud.show_notice(T.t(&"notice_elite", {"name": T.t(d.name_key)}))
	Audio.play(&"elite")


func _start_boss(id: StringName) -> void:
	director.stopped = true
	enemies.clear_crowd()
	projectiles.clear_hostile()
	arena.open_door()
	hud.show_notice(T.t(&"notice_boss"), 4.0)
	Audio.play(&"door")
	Audio.music(&"morvath")
	fx.shake(4.0)
	boss = Boss.new()
	boss.setup(self, enemies.def(id))
	boss.defeated.connect(func() -> void:
		boss_center = _boss_ref.center
		_on_boss_defeated())
	_boss_ref = boss


func _dev_start(what: String) -> void:
	match what:
		"boss":
			director.time = director.table.boss_time() - 1.0
			director.due_events()
		"elite1":
			_spawn_elite(&"knight")
		"elite2":
			_spawn_elite(&"priest")
		"fountain":
			_spawn_fountain()
		_:
			director.time = float(what)
			director.due_events()


# ---------- experience and gifts ----------

func _gain_xp(amount: int) -> void:
	var r := Leveling.add(level, xp, amount)
	level = r.level
	xp = r.xp
	_pending_levels += r.gained
	Audio.play(&"orb")


func xp_ratio() -> float:
	return float(xp) / Leveling.needed(level)


func _open_choice() -> void:
	mode = Mode.CHOICE
	var choice := BoonChoice.new()
	_screen = choice
	ui.add_child(choice)
	var offers := boons.offers(_rng)
	choice.open(offers, boons)
	choice.chosen.connect(_on_chosen)
	fx.burst(&"light", player.position + Vector2(0, -10))
	if bot and not Dev.has("hold"):
		get_tree().create_timer(0.5).timeout.connect(func() -> void:
			if mode == Mode.CHOICE:
				_on_chosen(offers[_rng.randi() % offers.size()] if not offers.is_empty() else null))


func _on_chosen(b: Boon) -> void:
	if mode != Mode.CHOICE:
		return
	_close_screen()
	_pending_levels -= 1
	player.heal(player.max_hp * LEVEL_HEAL)
	if b == null:
		player.heal(BoonChoice.REST_HEAL)
	else:
		_take(b)
	mode = Mode.PLAY


func _take(b: Boon) -> void:
	var old_hp_bonus := boons.stat(&"max_hp")
	boons.take(b)
	player.dodge_max = Player.BASE_DODGES + int(boons.stat(&"dodge_charges"))
	var shield := boons.stat(&"shield_cooldown")
	if shield > 0.0 and player.shield_cooldown <= 0.0:
		player.shield_ready = true
	player.shield_cooldown = shield
	var hp_bonus := boons.stat(&"max_hp")
	player.max_hp = Player.MAX_HP + hp_bonus
	player.heal(hp_bonus - old_hp_bonus)
	fx.burst(Fx.FAMILY_BURST.get(b.color_family(), &"light"), player.position + Vector2(0, -10))


func _on_dodged(dir: Vector2) -> void:
	var dps := boons.stat(&"dodge_ember_dps")
	if dps > 0.0:
		for k in 3:
			ground.add_zone(Ground.Kind.EMBER, player.position + dir * (k * 16.0), 9.0, 2.5, dps, &"perigo")


func _on_shield_broke() -> void:
	fx.word(player.position + Vector2(0, -24), T.t(&"word_shield"), &"vida")
	var burst := boons.stat(&"shield_burst")
	if burst > 0.0:
		fx.ring(player.position, 46.0, &"luz", 0.3)
		enemies.in_circle(player.position, 46.0, _found)
		for e: Enemy in _found.duplicate():
			if not enemies.damage(e, burst, (e.pos - player.position).normalized(), 90.0) and e.def.behavior != EnemyDef.Behavior.BOSS:
				e.stun_t = maxf(e.stun_t, 1.0)


# ---------- the light fountain ----------

func _spawn_fountain() -> void:
	if _fountain != null:
		return
	var at := arena.resolve(player.position + Vector2.from_angle(_rng.randf() * TAU) * 110.0, 20.0)
	_fountain = Art.animated(&"fountain")
	_fountain.position = at
	_fountain.play(&"flow")
	world.add_child(_fountain)
	var l := Arena.make_light(Color(1.0, 0.92, 0.6), 70.0, 0.7)
	l.position = Vector2(0, -6)
	l.name = "Light"
	_fountain.add_child(l)
	fx.burst(&"light", at)
	hud.show_notice(T.t(&"notice_fountain"), 4.0)
	Audio.play(&"fountain")


func _step_fountain() -> void:
	if _fountain == null or _fountain_used or not player.alive():
		return
	if player.position.distance_to(_fountain.position) < 16.0 and player.hp < player.max_hp:
		_fountain_used = true
		player.heal(player.max_hp * FOUNTAIN_HEAL)
		_fountain.play(&"spent")
		_fountain.get_node("Light").queue_free()
		fx.burst(&"light", player.position + Vector2(0, -10))
		fx.ring(player.position, 30.0, &"luz", 0.4)
		hud.show_notice(T.t(&"notice_fountain_used"))
		Audio.play(&"heal")


## Where the fountain is while it still has light (for the HUD arrow and the bot).
func fountain_target() -> Variant:
	return _fountain.position if _fountain != null and not _fountain_used else null


# ---------- hits, kills, endings ----------

func _on_hit_player(amount: float, from: Vector2) -> void:
	if mode == Mode.PLAY:
		player.hurt(amount, from)


func _on_killed(e: Enemy) -> void:
	kills += 1
	if e.def.elite:
		for i in 12:
			orbs.drop(e.pos + Vector2.from_angle(TAU * i / 12.0) * 10.0, maxi(1, e.def.xp / 12))
		fx.shake(3.0)
		Audio.play(&"elite_down")
	elif e.def.behavior != EnemyDef.Behavior.BOSS:
		orbs.drop(e.pos, e.def.xp)
	var heal := boons.stat(&"heal_on_kill")
	if heal > 0.0 and player.alive():
		player.heal(heal)


func _on_player_died() -> void:
	mode = Mode.OVER
	Audio.music(&"")
	Save.data.runs += 1
	Save.write()
	await get_tree().create_timer(1.6).timeout
	_open_end(false, false)


func _on_boss_defeated() -> void:
	mode = Mode.ENDING
	boss_fell_at = boss_center
	Save.data.runs += 1
	Save.data.wins += 1
	var new_best := SaveData.add_best_time(Save.data, time)
	Save.write()
	var ending := Ending.new()
	add_child(ending)
	await ending.play(self)
	_open_end(true, new_best)


func _open_end(victory: bool, new_best: bool) -> void:
	var end := EndScreen.new()
	_screen = end
	ui.add_child(end)
	end.open(victory, {"time": time, "level": level, "kills": kills, "best_combo": combat.best_combo, "boons": boons.owned().size()}, new_best)
	end.retry.connect(func() -> void: get_tree().reload_current_scene())
	end.menu.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/boot.tscn"))


func _open_pause() -> void:
	mode = Mode.PAUSE
	var pause := PauseMenu.new()
	_screen = pause
	ui.add_child(pause)
	pause.open(self)
	pause.resumed.connect(func() -> void:
		_close_screen()
		mode = Mode.PLAY)


func _close_screen() -> void:
	if _screen:
		_screen.queue_free()
		_screen = null


## The elite or boss whose life bar is on screen, if any.
func boss_enemy() -> Enemy:
	if boss and boss.e and boss.e.alive:
		return boss.e
	for e in enemies.list:
		if e.def.elite:
			return e
	return null


func _screen_pos(world_pos: Vector2) -> Vector2:
	return world_pos - camera.get_screen_center_position() + VIEW * 0.5


func _follow(delta: float, shake: Vector2) -> void:
	var look: Vector2 = focus if focus != null else player.position + Vector2(0, -8)
	_cam_pos = _cam_pos.lerp(look, 1.0 - exp(-delta * (3.0 if focus != null else 10.0)))
	var b := arena.bounds()
	var half := VIEW * 0.5
	var target := Vector2(clampf(_cam_pos.x, b.position.x + half.x, b.end.x - half.x), clampf(_cam_pos.y, b.position.y + half.y, b.end.y - half.y))
	camera.position = (target + shake).round()


## --shot=file.png: saves what the player would see (at 4x) after --shot-at seconds, then quits.
func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.resize(img.get_width() * 4, img.get_height() * 4, Image.INTERPOLATE_NEAREST)
	img.save_png(Dev.arg("shot"))
	print("RESULT ", result())
	get_tree().quit()


## A line of numbers about the run, for smoke tests and tuning.
func result() -> Dictionary:
	return {"time": snappedf(time, 0.1), "hp": int(player.hp), "level": level, "kills": kills, "best_combo": combat.best_combo,
		"enemies": enemies.count(), "mode": Mode.keys()[mode], "boss_hp": int(boss.e.hp) if boss and boss.e else -1, "phase": boss.phase if boss else 0, "boons": boons.owned().size(), "damage": int(combat.damage_dealt), "moves": Save.data.moves.size(), "step_ms": snappedf(step_ms, 0.01), "fps": Engine.get_frames_per_second()}


## --smoke=seconds: plays without a screen for that long (or until the run ends), prints RESULT and quits.
func _smoke() -> void:
	var limit := Dev.num("smoke", 60.0)
	var t := 0.0
	while t < limit and mode != Mode.OVER and not (mode == Mode.ENDING and boss == null):
		await get_tree().process_frame
		t += get_process_delta_time()
	print("RESULT ", result())
	get_tree().quit()
