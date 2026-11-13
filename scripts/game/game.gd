extends Node2D
## One run in the catacombs. Owns the clock: every system is stepped from here,
## so hit stop, pause and the level-up screen are just "do not step".

const VIEW := Vector2(320, 180)

var arena: Arena
var world: Node2D
var player: Player
var fx: Fx
var camera: Camera2D
var bot: Bot
var time := 0.0
var _cam_pos := Vector2.ZERO


func _ready() -> void:
	world = Node2D.new()
	world.y_sort_enabled = true
	arena = Arena.new()
	add_child(arena)
	add_child(world)
	arena.build(world)

	var fx_layer := CanvasLayer.new()
	fx_layer.layer = 1
	fx_layer.follow_viewport_enabled = true
	add_child(fx_layer)
	fx = Fx.new()
	fx_layer.add_child(fx)

	player = Player.new()
	player.arena = arena
	player.fx = fx
	player.position = Arena.SIZE * 0.5
	world.add_child(player)

	camera = Camera2D.new()
	add_child(camera)
	camera.make_current()
	_cam_pos = player.position

	if Dev.has("bot"):
		bot = Bot.new()
		Controls.virtual = bot.pad
	if Dev.has("shot"):
		_shot.call_deferred()


func _exit_tree() -> void:
	Controls.virtual = null


func _process(delta: float) -> void:
	var shake := fx.tick(delta)
	if bot:
		bot.step(delta, self)
	if fx.stop_left <= 0.0:
		_step(minf(delta, 0.05))
	_follow(delta, shake)


func _step(dt: float) -> void:
	time += dt
	player.step(dt, Controls.aim(_screen_pos(player.position + Vector2(0, -8)), get_viewport().get_mouse_position()))


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
	get_tree().quit()
