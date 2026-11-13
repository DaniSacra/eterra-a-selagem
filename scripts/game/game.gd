class_name Game
extends Node2D
## One run in the catacombs. Owns the clock: every system is stepped from here,
## so hit stop, pause and the level-up screen are just "do not step".

const VIEW := Vector2(320, 180)

var arena: Arena
var world: Node2D
var ground: Ground
var player: Player
var enemies: EnemySystem
var projectiles: Projectiles
var combat: Combat
var boons: BoonState
var fx: Fx
var hud: Hud
var camera: Camera2D
var bot: Bot
var time := 0.0
var level := 1
var xp := 0
var kills := 0
var _cam_pos := Vector2.ZERO
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	world = Node2D.new()
	world.y_sort_enabled = true
	arena = Arena.new()
	add_child(arena)
	ground = Ground.new()
	ground.z_index = -5
	add_child(ground)
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

	ground.enemies = enemies
	ground.player = player
	ground.fx = fx
	ground.on_zone_hit = combat.on_zone_hit
	projectiles.enemies = enemies
	projectiles.player = player
	fx.enemies = enemies

	player.struck.connect(combat.strike)
	player.was_hurt.connect(combat.drop_combo)
	projectiles.wave_hit.connect(combat.on_wave_hit)
	for source: Object in [enemies, ground, projectiles]:
		source.hit_player.connect(_on_hit_player)
	enemies.killed.connect(_on_killed)

	camera = Camera2D.new()
	add_child(camera)
	camera.make_current()
	_cam_pos = player.position

	var ui := CanvasLayer.new()
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

	_setup()
	if Dev.has("bot"):
		bot = Bot.new()
		Controls.virtual = bot.pad
	if Dev.has("shot"):
		_shot.call_deferred()


## Milestone 2: a training ring of skeletons that comes back when cleared.
func _setup() -> void:
	_spawn_ring()


func _spawn_ring() -> void:
	for i in 14:
		var at := player.position + Vector2.from_angle(TAU * i / 14.0) * _rng.randf_range(50, 90)
		enemies.spawn(enemies.def(&"skeleton"), arena.resolve(at, 5.0), true)


func _exit_tree() -> void:
	Controls.virtual = null


func _process(delta: float) -> void:
	var shake := fx.tick(delta)
	fx.animate(delta)
	if bot:
		bot.step(delta, self)
	if fx.stop_left <= 0.0:
		_step(minf(delta, 0.05))
	_follow(delta, shake)


func _step(dt: float) -> void:
	time += dt
	player.step(dt, Controls.aim(_screen_pos(player.position + Vector2(0, -8)), get_viewport().get_mouse_position()))
	enemies.target = player.position
	enemies.target_alive = player.alive()
	enemies.step(dt)
	projectiles.step(dt)
	ground.step(dt)
	combat.step(dt)
	if enemies.count() == 0:
		_spawn_ring()


func _on_hit_player(amount: float, from: Vector2) -> void:
	player.hurt(amount, from)


func _on_killed(_e: Enemy) -> void:
	kills += 1


func xp_ratio() -> float:
	return 0.0


## The elite or boss whose life bar is on screen, if any.
func boss_enemy() -> Enemy:
	for e in enemies.list:
		if e.def.elite or e.def.behavior == EnemyDef.Behavior.BOSS:
			return e
	return null


func _screen_pos(world_pos: Vector2) -> Vector2:
	return world_pos - camera.get_screen_center_position() + VIEW * 0.5


func _follow(delta: float, shake: Vector2) -> void:
	_cam_pos = _cam_pos.lerp(player.position + Vector2(0, -8), 1.0 - exp(-delta * 10.0))
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
		"enemies": enemies.count(), "damage": int(combat.damage_dealt), "moves": Save.data.moves.size(), "fps": Engine.get_frames_per_second()}
