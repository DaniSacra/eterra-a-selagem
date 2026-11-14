class_name Game
extends Node3D
## One run in the catacombs. Owns the clock: every system is stepped from here, so hit stop, pause and the gift
## choice are just "do not step". The world is 3D; the game itself plays on the floor plane (x, z) in meters.

enum Mode { PLAY, CHOICE, PAUSE, OVER, ENDING }

## Magia a kill gives back (Player.magick).
const MAGICK_PER_KILL := 1.0
const MAGICK_PER_ELITE := 40.0
const WAVES := "res://data/waves/catacombs.tres"
const FOUNTAIN_HEAL := 0.4
## Each new level, the gift arrives with a little of the companions' strength.
const LEVEL_HEAL := 0.15
## --start= in the room mode: which room to begin in.
const ROOM_STARTS := {"boss": RunMap.Kind.BOSS, "miniboss": RunMap.Kind.MINIBOSS, "shop": RunMap.Kind.SHOP, "fountain": RunMap.Kind.FOUNTAIN}
const SPAWN_MIN := 19.0
const SPAWN_MAX := 25.0
## How far the point the camera looks at stays from the side walls and from the north and south ends (meters).
const CAM_MARGIN := Vector2(10.0, 5.0)
## The low camera sees far past the south edge: it stops sooner there.
const CAM_SOUTH := 9.0

var arena: Arena
var ground: Ground
var orbs: Orbs
var player: Player
var horde: Horde
var projectiles: Projectiles
var combat: Combat
var skills: Skills
var boons: BoonState
var director: WaveDirector
## The descent room by room (null in the endless hall, --horde).
var rooms: Rooms
## Life gained from hearts (kept when gifts change the life bar).
var life_bonus := 0.0
var boss: Boss
var fx: Fx
var hud: Hud
var ui: CanvasLayer
var _feel_panel: FeelPanel
var camera: Camera3D
var bot: Bot
var mode := Mode.PLAY
var time := 0.0
var level := 1
var xp := 0
var kills := 0
var fast := 1.0
## Smoothed cost of one simulation step, in milliseconds.
var step_ms := 0.0
## When set, the camera looks here instead of at the paladin (the final scene).
var focus: Variant = null
var _pending_levels := 0
## Rarity of each card on the table (Boon.Rarity by gift id).
var _offer_rarity: Dictionary = {}
var _screen: Control
var _screen_fx: ShaderMaterial
var _hurt_flash := 0.0
var _fountain: Node3D
var _fountain_at := Vector2.ZERO
var _fountain_used := false
var _cam_target := Vector3.ZERO
var _rng := RandomNumberGenerator.new()
var _found: Array[Enemy] = []


func _ready() -> void:
	Dev.seed_rng(_rng, 1)
	fast = Dev.num("fast", 1.0)
	_build_world()
	_build_ui()
	boons = BoonState.new(BoonState.load_catalog())
	combat = Combat.new()
	combat.horde = horde
	combat.fx = fx
	combat.ground = ground
	combat.projectiles = projectiles
	combat.boons = boons
	director = WaveDirector.new(load(WAVES), _rng)
	skills = Skills.new()
	skills.game = self
	add_child(skills)

	ground.horde = horde
	ground.player = player
	ground.fx = fx
	ground.on_zone_hit = combat.on_zone_hit
	ground.on_zone_burst = combat.cast_burst
	projectiles.horde = horde
	projectiles.player = player
	projectiles.fx = fx
	horde.arena = arena
	horde.fx = fx
	horde.ground = ground
	horde.projectiles = projectiles

	player.struck.connect(combat.strike)
	player.glinted.connect(combat.glint)
	player.cast_released.connect(combat.cast)
	player.was_hurt.connect(func(_a: float) -> void:
		combat.drop_combo()
		_hurt_flash = 1.0)
	player.died.connect(_on_player_died)
	player.dodged.connect(_on_dodged)
	player.shield_broke.connect(_on_shield_broke)
	player.move_shown.connect(func(node: ComboNode) -> void:
		hud.show_move(node, combat.color_of(node.tags))
		if SaveData.discover_move(Save.data, String(node.id)):
			Save.write())
	projectiles.shot_hit.connect(combat.on_shot_hit)
	for source: Object in [horde, ground, projectiles]:
		source.hit_player.connect(_on_hit_player)
	horde.killed.connect(_on_killed)
	horde.armor_broken.connect(_on_armor_broken)
	combat.combo_changed.connect(hud.on_combo)
	fx.shake_scale = 1.0 if Save.option("shake") else 0.0

	if Dev.has("bot"):
		bot = Bot.new()
		Controls.virtual = bot.pad
	if not Dev.has("horde"):
		rooms = Rooms.new()
		add_child(rooms)
		rooms.setup(self, _rng)
		if Dev.has("start") and Dev.arg("start") in ROOM_STARTS:
			rooms.start_at(ROOM_STARTS[Dev.arg("start")])
		else:
			rooms.start()
	elif Dev.has("start"):
		_dev_start(Dev.arg("start"))
	if Dev.has("boons"):
		for i in int(Dev.num("boons", 0)):
			var offers := boons.offers(_rng, 1)
			if not offers.is_empty():
				_take(offers[0])
	if Dev.has("stress"):
		player.max_hp = 99999.0
		player.hp = 99999.0
		var kinds: Array[StringName] = [&"skeleton", &"skeleton", &"archer", &"runner", &"mage", &"guard"]
		for i in int(Dev.num("stress", 300)):
			horde.spawn(horde.def(kinds[i % kinds.size()]), arena.resolve(player.pos + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(4.0, 20.0), 0.5), false)
	if Dev.has("feel-panel"):
		_toggle_feel_panel.call_deferred()
	if Dev.has("shot"):
		_shot.call_deferred()
	if Dev.has("frames"):
		_frames.call_deferred()
	if Dev.has("smoke"):
		_smoke.call_deferred()
	if Dev.has("lab"):
		_lab.call_deferred()


func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.015, 0.03, 0.04)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# cool slate-teal mid-tone (painterly night look): dark ink strokes and bright effects both read on the floor,
	# torches and the paladin's red stay the warm accents
	e.ambient_light_color = Color(0.42, 0.58, 0.62)
	e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = 1.05
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_strength = 1.0
	e.glow_bloom = 0.04
	e.glow_hdr_threshold = 0.85
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	for i in 7:
		e.set_glow_level(i, 1.0 if i in [1, 2, 3, 4] else 0.0)
	e.fog_enabled = true
	e.fog_light_color = Color(0.05, 0.1, 0.11)
	e.fog_density = 0.008
	e.adjustment_enabled = true
	e.adjustment_contrast = 1.1
	e.adjustment_saturation = 0.6
	env.environment = e
	add_child(env)
	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-58, -32, 0)
	moon.light_color = Color(0.72, 0.88, 0.95)
	moon.light_energy = 0.55
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 80.0
	add_child(moon)

	arena = Arena.new()
	add_child(arena)
	arena.build()
	ground = Ground.new()
	add_child(ground)
	orbs = Orbs.new()
	add_child(orbs)
	horde = Horde.new()
	add_child(horde)
	projectiles = Projectiles.new()
	add_child(projectiles)
	fx = Fx.new()
	add_child(fx)
	player = Player.new()
	player.arena = arena
	player.horde = horde
	player.fx = fx
	player.pos = Vector2(0, 8)
	add_child(player)
	camera = Camera3D.new()
	camera.fov = Dev.num("cam-fov", Feel.live().cam_fov)
	camera.far = 160.0
	add_child(camera)
	camera.make_current()
	_cam_target = Vector3(player.pos.x, 0, player.pos.y)
	_place_camera(Vector3.ZERO, 1.0)


func _build_ui() -> void:
	var screen_layer := CanvasLayer.new()
	screen_layer.layer = 1
	add_child(screen_layer)
	var screen := ColorRect.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen_fx = ShaderMaterial.new()
	_screen_fx.shader = load("res://assets/shaders/screen.gdshader")
	screen.material = _screen_fx
	screen_layer.add_child(screen)
	var numbers_layer := CanvasLayer.new()
	numbers_layer.layer = 2
	add_child(numbers_layer)
	var numbers := Control.new()
	numbers.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	numbers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	numbers_layer.add_child(numbers)
	fx.setup(camera, numbers)
	ui = CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	hud = Hud.new()
	hud.game = self
	ui.add_child(hud)


func _exit_tree() -> void:
	Controls.virtual = null
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	var shake := fx.tick(delta)
	fx.animate(delta)
	if bot:
		bot.step(delta, self)
	var stepped := false
	if mode == Mode.PLAY or mode == Mode.OVER or mode == Mode.ENDING:
		if fx.stop_left <= 0.0:
			var t0 := Time.get_ticks_usec()
			_step(minf(delta, 0.05))
			stepped = true
			step_ms = lerpf(step_ms, (Time.get_ticks_usec() - t0) / 1000.0, 0.05)
	horde.render()
	orbs.render()
	if mode == Mode.PLAY and Controls.pressed(&"pause"):
		_open_pause()
	if OS.is_debug_build() and Controls.pressed(&"feel_panel"):
		_toggle_feel_panel()
	_hurt_flash = maxf(0.0, _hurt_flash - delta * 2.5)
	var low := 1.0 - clampf(player.hp / player.max_hp / 0.3, 0.0, 1.0)
	if mode != Mode.PLAY and mode != Mode.ENDING and not Dev.has("lab"):
		fx.end_slow()
	_screen_fx.set_shader_parameter(&"split", fx.split)
	_screen_fx.set_shader_parameter(&"radial", fx.radial)
	_screen_fx.set_shader_parameter(&"impact", 1.0 if fx.frame_left > 0.0 else 0.0)
	_screen_fx.set_shader_parameter(&"hurt", maxf(_hurt_flash, low * (0.35 + 0.15 * sin(time * 6.0))))
	_follow(delta, shake)
	# a button pressed during a hit stop is kept for the next step (a swing must never be lost)
	if stepped or mode != Mode.PLAY:
		Controls.flush()


func _step(dt: float) -> void:
	if rooms:
		if mode == Mode.PLAY:
			time += dt
			rooms.step(dt)
	else:
		if mode == Mode.PLAY:
			_step_waves(dt)
		# the clock the player sees is play time; the timeline may run faster (WaveTable.pace)
		time = director.time / director.table.pace
	player.cast_active = _circle_standing()
	if mode == Mode.ENDING:
		player.rest()
		player.step(dt, Vector2.ZERO, Vector2.ZERO)
	else:
		player.step(dt, Controls.move(), _aim())
	horde.target = player.pos
	horde.target_alive = player.alive() and mode == Mode.PLAY
	horde.step(dt)
	if boss:
		boss.step(dt)
	projectiles.step(dt)
	ground.step(dt)
	combat.step(dt)
	if mode == Mode.PLAY:
		skills.step(dt)
	var got := orbs.step(dt, player.pos)
	if got > 0 and rooms == null:
		_gain_xp(got)
	_step_fountain()
	if _pending_levels > 0 and mode == Mode.PLAY and player.alive() and rooms == null:
		_open_choice()


## Where the paladin aims: the mouse pointer on the floor, or the stick (Controls).
func _aim() -> Vector2:
	if Controls.aims_with_mouse():
		var mouse := get_viewport().get_mouse_position()
		var from := camera.project_ray_origin(mouse)
		var dir := camera.project_ray_normal(mouse)
		if absf(dir.y) > 0.001:
			var hit := from + dir * ((1.0 - from.y) / dir.y)
			var d := Vector2(hit.x, hit.z) - player.pos
			return d.normalized() if d.length() > 0.2 else Vector2.ZERO
		return Vector2.ZERO
	var a := Controls.aim(Vector2.ZERO, Vector2.ZERO)
	return a


# ---------- waves ----------

func _step_waves(dt: float) -> void:
	for id in director.step(dt * fast, horde.count()):
		horde.spawn(horde.def(id), _spawn_point())
	horde.hp_scale = director.hp_scale()
	horde.damage_scale = director.damage_scale()
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
	var at := player.pos
	for attempt in 8:
		at = player.pos + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(SPAWN_MIN, SPAWN_MAX)
		if arena.inside(at, 1.0):
			return arena.resolve(at, 0.5)
	# near a wall: closer, but still out of reach
	return arena.resolve(player.pos + Vector2.from_angle(_rng.randf() * TAU) * 12.0, 0.5)


func _spawn_elite(id: StringName) -> void:
	var d := horde.def(id)
	var at := _spawn_point()
	horde.spawn(d, at, true)
	fx.burst(&"shadow", Vector3(at.x, 1.0, at.y))
	fx.beam(at, d.rim_color, 1.5, 12.0, 1.0)
	hud.show_notice(T.t(&"notice_elite", {"name": T.t(d.name_key)}))
	Audio.play(&"elite")


func _circle_standing() -> bool:
	for z in ground.zones:
		if z.kind == Ground.Kind.BIND:
			return true
	return false


## A new room: the old one is taken down and this one built (layout null: the great hall).
func rebuild_room(layout: RoomLayout, exits: int, seed_: int) -> void:
	ground.clear()
	projectiles.clear_hostile()
	horde.clear_crowd()
	if _fountain != null:
		_fountain.queue_free()
		_fountain = null
	arena.queue_free()
	arena = Arena.new()
	add_child(arena)
	arena.build(layout, exits, seed_)
	horde.arena = arena
	player.arena = arena


## Gifts by a cleared room or the shop: three cards drawn with these rarity weights.
func open_boon_choice(weights: Array[float] = Boon.RARITY_WEIGHT) -> void:
	_open_choice(boons.offers(_rng), weights)


## A level more for a gift already owned (the paladin picks which).
func open_grow_choice() -> void:
	var offers := boons.grow_offers(_rng)
	_open_choice(offers, Boon.RARITY_WEIGHT, true)


## A heart: more life, and that much healed.
func add_max_life(amount: float) -> void:
	life_bonus += amount
	player.max_hp += amount
	player.heal(amount)
	fx.word(Vector3(player.pos.x, 3.0, player.pos.y), "+%d %s" % [int(amount), T.t(&"hud_life")], Color(1.0, 0.4, 0.5))


func start_boss(id: StringName) -> void:
	_start_boss(id)


func _start_boss(id: StringName) -> void:
	director.stopped = true
	horde.clear_crowd()
	projectiles.clear_hostile()
	arena.open_door()
	hud.show_notice(T.t(&"notice_boss"), 4.0)
	Audio.play(&"door")
	fx.shake(4.0)
	boss = Boss.new()
	boss.setup(self, horde.def(id))
	boss.defeated.connect(_on_boss_defeated)


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


func _open_choice(offers: Array[Boon] = [], weights: Array[float] = Boon.RARITY_WEIGHT, grow: bool = false) -> void:
	mode = Mode.CHOICE
	if rooms == null:
		offers = boons.offers(_rng)
	_offer_rarity.clear()
	for b in offers:
		_offer_rarity[b.id] = boons.rarity(b.id) if grow else BoonState.roll_rarity(_rng, weights)
	if Dev.has("autopick") or offers.is_empty():
		# captures of the fight: take a gift at once, no screen
		_on_chosen(offers[0] if not offers.is_empty() else null)
		return
	var choice := BoonChoice.new()
	_screen = choice
	ui.add_child(choice)
	choice.open(offers, boons, _offer_rarity)
	choice.chosen.connect(_on_chosen)
	fx.burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))
	if bot and not Dev.has("hold"):
		get_tree().create_timer(0.6).timeout.connect(func() -> void:
			if mode == Mode.CHOICE:
				_on_chosen(offers[_rng.randi() % offers.size()] if not offers.is_empty() else null))


func _on_chosen(b: Boon) -> void:
	if mode != Mode.CHOICE:
		return
	_close_screen()
	if rooms == null:
		_pending_levels -= 1
		player.heal(player.max_hp * LEVEL_HEAL)
	if b == null:
		player.heal(BoonChoice.REST_HEAL)
	else:
		_take(b)
	mode = Mode.PLAY


func _take(b: Boon) -> void:
	var old_hp_bonus := boons.stat(&"max_hp")
	boons.take(b, _offer_rarity.get(b.id, Boon.Rarity.COMMON))
	player.dodge_max = Feel.live().dodge_charges + int(boons.stat(&"dodge_charges"))
	player.speed_bonus = boons.stat(&"move_speed_pct")
	var shield := boons.stat(&"shield_cooldown")
	if shield > 0.0 and player.shield_cooldown <= 0.0:
		player.shield_ready = true
	player.shield_cooldown = shield
	var hp_bonus := boons.stat(&"max_hp")
	player.max_hp = Player.MAX_HP + hp_bonus + life_bonus
	player.heal(hp_bonus - old_hp_bonus)
	fx.ring(player.pos, 3.0, b.color(), 0.5)
	fx.beam(player.pos, b.color(), 1.2, 8.0, 0.6)
	fx.burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))


func _on_dodged(dir: Vector2) -> void:
	var dps := boons.stat(&"dodge_ember_dps")
	if dps > 0.0:
		for k in 3:
			ground.add_zone(Ground.Kind.EMBER, player.pos + dir * (k * 2.0), 1.4, 2.5, dps, Combat.EMBER_TAGS)


func _on_shield_broke() -> void:
	fx.word(Vector3(player.pos.x, 3.0, player.pos.y), T.t(&"word_shield"), Color(0.5, 1.0, 0.65))
	var burst := boons.stat(&"shield_burst")
	if burst > 0.0:
		fx.ring(player.pos, 5.5, Combat.LIGHT, 0.35)
		horde.in_circle(player.pos, 5.5, _found)
		for e: Enemy in _found.duplicate():
			if not horde.damage(e, burst, (e.pos - player.pos).normalized(), 12.0) and e.def.behavior != EnemyDef.Behavior.BOSS:
				e.stun_t = maxf(e.stun_t, 1.0)


# ---------- the light fountain ----------

func _spawn_fountain() -> void:
	spawn_fountain(arena.resolve(player.pos + Vector2.from_angle(_rng.randf() * TAU) * 13.0, 2.5))


func spawn_fountain(at: Vector2) -> void:
	if _fountain != null:
		return
	_fountain_used = false
	_fountain_at = at
	_fountain = Node3D.new()
	_fountain.position = Vector3(_fountain_at.x, 0, _fountain_at.y)
	add_child(_fountain)
	var l := OmniLight3D.new()
	l.name = "Light"
	l.position.y = 2.0
	l.light_color = Color(1.0, 0.9, 0.6)
	l.light_energy = 3.0
	l.omni_range = 9.0
	l.light_cull_mask = ~Arena.CROWD_LAYER
	_fountain.add_child(l)
	var spring := CPUParticles3D.new()
	spring.name = "Spring"
	spring.amount = 40
	spring.lifetime = 1.4
	spring.direction = Vector3.UP
	spring.spread = 14.0
	spring.initial_velocity_min = 2.5
	spring.initial_velocity_max = 4.5
	spring.gravity = Vector3(0, -1.0, 0)
	spring.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	spring.emission_sphere_radius = 0.6
	spring.mesh = Fx.quad(0.35, Color(3.0, 2.6, 1.4))
	spring.color_ramp = Fx.fade_ramp(Color.WHITE)
	_fountain.add_child(spring)
	var pool := ground.add_zone(Ground.Kind.HOLY, _fountain_at, 1.8, 9999.0, 0.0)
	pool.tags = []
	fx.beam(_fountain_at, Combat.LIGHT, 1.4, 14.0, 1.2)
	hud.show_notice(T.t(&"notice_fountain"), 4.0)
	Audio.play(&"fountain")


func _step_fountain() -> void:
	if _fountain == null or _fountain_used or not player.alive():
		return
	if player.pos.distance_to(_fountain_at) < 2.0 and player.hp < player.max_hp:
		_fountain_used = true
		player.heal(player.max_hp * FOUNTAIN_HEAL)
		(_fountain.get_node("Light") as OmniLight3D).light_energy = 0.6
		(_fountain.get_node("Spring") as CPUParticles3D).emitting = false
		for z in ground.zones:
			if z.kind == Ground.Kind.HOLY and z.pos == _fountain_at:
				z.life = 0.3
		fx.burst(&"heal", Vector3(player.pos.x, 1.2, player.pos.y))
		fx.ring(player.pos, 4.0, Combat.LIGHT, 0.5)
		hud.show_notice(T.t(&"notice_fountain_used"))
		Audio.play(&"heal")


## Where the fountain is while it still has light (for the HUD marker and the bot).
func fountain_target() -> Variant:
	return _fountain_at if _fountain != null and not _fountain_used else null


# ---------- hits, kills, endings ----------

func _on_hit_player(amount: float, from: Vector2) -> void:
	if mode == Mode.PLAY:
		player.hurt(amount, from)


## An elite's or Morvath's armor broke: a stagger, and a moment to punish.
func _on_armor_broken(e: Enemy) -> void:
	fx.shake(3.0)
	fx.impact(Vector3(e.pos.x, 1.6 * e.def.size, e.pos.y), Horde.ARMOR_COLOR, 2.6)
	if boss and boss.e == e:
		boss.break_armor()
		return
	e.stun_t = maxf(e.stun_t, e.def.armor_stagger)
	fx.word(Vector3(e.pos.x, 2.0 + 2.0 * e.def.size, e.pos.y), T.t(&"word_stagger"), Combat.LIGHT)
	Audio.play(&"stagger")


func _on_killed(e: Enemy) -> void:
	kills += 1
	if rooms == null:
		player.magick.gain(MAGICK_PER_ELITE if e.def.elite else MAGICK_PER_KILL)
	if rooms:
		pass  # no experience in the rooms: gifts come from rewards
	elif e.def.elite:
		for i in 14:
			orbs.drop(e.pos + Vector2.from_angle(TAU * i / 14.0) * 1.2, maxi(1, e.def.xp / 14))
		fx.shake(3.0)
		fx.beam(e.pos, e.def.rim_color, 1.5, 12.0, 0.8)
		Audio.play(&"elite_down")
	elif e.def.behavior != EnemyDef.Behavior.BOSS:
		orbs.drop(e.pos, e.def.xp)
	var heal := boons.stat(&"heal_on_kill")
	if heal > 0.0 and player.alive():
		player.heal(heal)


func _on_player_died() -> void:
	mode = Mode.OVER
	Save.data.runs += 1
	Save.write()
	await get_tree().create_timer(1.8).timeout
	_open_end(false, false)


func _on_boss_defeated() -> void:
	mode = Mode.ENDING
	var at := boss.center if boss else player.pos
	Save.data.runs += 1
	Save.data.wins += 1
	var new_best := SaveData.add_best_time(Save.data, time)
	Save.write()
	await _play_ending(at)
	_open_end(true, new_best)


## The sealing: four swords of light rise around the fallen king, and the epitaph is read.
func _play_ending(at: Vector2) -> void:
	focus = Vector3(at.x, 0, at.y)
	Audio.play(&"seal")
	for k in 4:
		await get_tree().create_timer(0.5).timeout
		var p := at + Vector2.from_angle(PI * 0.25 + PI * 0.5 * k) * 3.5
		fx.beam(p, Combat.LIGHT, 0.6, 14.0, 6.0)
		fx.ring(p, 1.5, Combat.LIGHT, 0.6)
		fx.burst(&"light", Vector3(p.x, 0.5, p.y))
		Audio.play(&"sword_rise")
	await get_tree().create_timer(0.6).timeout
	fx.ring(at, 7.0, Combat.LIGHT, 1.2)
	fx.beam(at, Combat.LIGHT, 3.0, 20.0, 2.0)
	fx.shake(2.0)
	var holder := Control.new()
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.theme = UiKit.theme()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(holder)
	var box := UiKit.column(holder, 900.0, 0.35)
	for key: StringName in [&"ending_1", &"ending_2", &"ending_3"]:
		var l := UiKit.label(T.t(key), UiKit.GOLD if key == &"ending_3" else UiKit.PALE, 30 if key == &"ending_3" else 24, UiKit.TITLE_FONT if key == &"ending_3" else null)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 900
		l.modulate.a = 0.0
		box.add_child(l)
		create_tween().tween_property(l, "modulate:a", 1.0, 0.8)
		await get_tree().create_timer(2.2 if not bot else 0.3).timeout
	await get_tree().create_timer(2.0 if not bot else 0.3).timeout
	for c in ui.get_children():
		if c != hud:
			c.queue_free()


func _open_end(victory: bool, new_best: bool) -> void:
	var end := EndScreen.new()
	_screen = end
	ui.add_child(end)
	end.open(victory, {"time": time, "level": level, "kills": kills, "best_combo": combat.best_combo, "boons": boons.owned().size()}, new_best)
	end.retry.connect(func() -> void: get_tree().reload_current_scene())
	end.menu.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/boot.tscn"))


## F1 (debug builds): the live tuning panel for data/feel.tres. The run keeps going behind it.
func _toggle_feel_panel() -> void:
	if is_instance_valid(_feel_panel):
		_feel_panel.queue_free()
		_feel_panel = null
	else:
		_feel_panel = FeelPanel.new()
		add_child(_feel_panel)


func _open_pause() -> void:
	mode = Mode.PAUSE
	var pause := PauseMenu.new()
	_screen = pause
	ui.add_child(pause)
	pause.open()
	pause.resumed.connect(func() -> void:
		_close_screen()
		fx.shake_scale = 1.0 if Save.option("shake") else 0.0
		mode = Mode.PLAY)


func _close_screen() -> void:
	if _screen:
		_screen.queue_free()
		_screen = null


## The elite or boss whose life bar is on screen, if any.
func boss_enemy() -> Enemy:
	if boss and boss.e and boss.e.alive:
		return boss.e
	for e in horde.list:
		if e.def.elite:
			return e
	return null


## How much closer the camera gets at the end of an Omega's charge.
const OMEGA_ZOOM := 0.08
var _charge_zoom := 0.0
## Where the paladin stood last frame and how fast he walks, smoothed (the camera leads by it).
var _cam_last := Vector2.ZERO
var _cam_vel := Vector2.ZERO


func _follow(delta: float, shake: Vector3) -> void:
	var look: Vector3
	if focus != null:
		look = focus
	else:
		# a little ahead of where the paladin walks (never where he aims: standing still, he stays in the middle)
		var walked := (player.pos - _cam_last) / maxf(delta, 0.001)
		_cam_last = player.pos
		_cam_vel = _cam_vel.lerp(walked, 1.0 - exp(-delta * 5.0))
		var lead := (_cam_vel / maxf(Feel.live().speed, 0.1)).limit_length(1.0) * Feel.live().cam_lead
		look = Vector3(player.pos.x + lead.x, 0, player.pos.y + lead.y)
	_cam_target = _cam_target.lerp(look, 1.0 - exp(-delta * (2.5 if focus != null else Feel.live().cam_smooth)))
	_place_camera(shake, delta)


func _place_camera(shake: Vector3, _delta: float) -> void:
	var h := arena.half
	var t := Vector3(clampf(_cam_target.x, -maxf(0.0, h.x - CAM_MARGIN.x), maxf(0.0, h.x - CAM_MARGIN.x)), 0,
		clampf(_cam_target.z, minf(0.0, -h.y + CAM_MARGIN.y), maxf(0.0, h.y - CAM_SOUTH)))
	camera.look_at_from_position(t + _cam_offset() + shake, t + shake * 0.5, Vector3.UP)


## Camera offset from feel.tres; --cam-dist, --cam-pitch (degrees above the floor) and --cam-fov override it for tuning.
func _cam_offset() -> Vector3:
	var feel := Feel.live()
	# the camera closes in during slow motion and while an Omega charges (Hades II: 8% over the charge)
	var charge := player.charge_progress() * OMEGA_ZOOM
	_charge_zoom = charge if charge > _charge_zoom else lerpf(_charge_zoom, charge, 1.0 - exp(-get_process_delta_time() / maxf(Engine.time_scale, 0.001) * 6.0))
	camera.fov = Dev.num("cam-fov", feel.cam_fov) / (fx.zoom * (1.0 + _charge_zoom))
	return Feel.cam_offset_of(Dev.num("cam-dist", feel.cam_distance), Dev.num("cam-pitch", feel.cam_pitch))


## --shot=file.png: saves what the player would see after --shot-at seconds, then quits.
func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(Dev.arg("shot"))
	print("RESULT ", result())
	get_tree().quit()


## --frames=prefix: saves --count frames, one every --every seconds, starting at --shot-at (to check animations).
func _frames() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	for i in int(Dev.num("count", 12)):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s_%02d.png" % [Dev.arg("frames"), i])
		await get_tree().create_timer(Dev.num("every", 0.1)).timeout
	print("RESULT ", result())
	get_tree().quit()


## --lab: a frozen still for judging effects. A crowd around the paladin, one big finisher slash frozen at
## --lab-t (0..1 of its life), damage numbers on the enemies it covers; pair with --shot.
## --lab-crescent adds the finisher's flying crescent; --lab-glint shows the glint on the blade instead;
## --lab-impact holds the impact frame; --lab-slow shows the last-kill slow motion (zoom, radial blur).
func _lab() -> void:
	player.max_hp = 99999.0
	player.hp = 99999.0
	var dir := Vector2(0.75, 0.45).normalized()
	player.facing = dir
	var lab_rng := RandomNumberGenerator.new()
	lab_rng.seed = 7
	var kinds: Array[StringName] = [&"skeleton", &"skeleton", &"skeleton", &"runner", &"guard"]
	for i in int(Dev.num("lab-count", 70)):
		var at := player.pos + Vector2.from_angle(lab_rng.randf() * TAU) * lab_rng.randf_range(1.6, 11.0)
		horde.spawn(horde.def(kinds[i % kinds.size()]), arena.resolve(at, 0.5), false)
	for i in 3:
		await get_tree().process_frame
	mode = Mode.CHOICE
	fx.freeze_t = Dev.num("lab-t", 0.35)
	var reach := Dev.num("lab-reach", 5.5)
	if Dev.has("lab-glint"):
		# the glint of a finisher at --lab-t of its life (its hold ends at about 0.55)
		fx.glint(Vector3.ZERO, Combat.STEEL, 0.2, player.blade_tip)
	else:
		fx.slash(player.pos, dir, reach, Dev.num("lab-width", 270.0), Combat.STEEL, 0.25)
		if Dev.has("lab-crescent"):
			fx.crescent(player.pos, dir, reach, Dev.num("lab-width", 270.0), Combat.STEEL)
	if Dev.has("lab-impact"):
		fx.frame_left = 1000.0  # hold the impact frame for the still
	if Dev.has("lab-slow"):
		fx.slow_mo(0.35, 1000.0, 0.4, 1.1, 0.85, 0.01)  # the last-kill slow motion at its deepest
	var shown := 0
	for e in horde.list:
		if e.pos.distance_to(player.pos) <= reach + 0.4 and shown < int(Dev.num("lab-numbers", 12)):
			fx.number(Vector3(e.pos.x, 1.6, e.pos.y), 114, Color(1, 1, 1))
			shown += 1


## A line of numbers about the run, for smoke tests and tuning.
func result() -> Dictionary:
	return {"time": snappedf(time, 0.1), "hp": int(player.hp), "level": level, "room": rooms.depth() if rooms else 0, "gold": rooms.gold if rooms else 0, "kills": kills, "spawned": director.spawned, "best_combo": combat.best_combo,
		"enemies": horde.count(), "mode": Mode.keys()[mode], "boss_hp": int(boss.e.hp) if boss and boss.e else -1, "phase": boss.phase if boss else 0,
		"boons": boons.owned().size(), "damage": int(combat.damage_dealt), "step_ms": snappedf(step_ms, 0.01), "fps": Engine.get_frames_per_second()}


## --smoke=seconds: plays without a screen for that long (or until the run ends), prints RESULT and quits.
func _smoke() -> void:
	var limit := Dev.num("smoke", 60.0)
	var t := 0.0
	while t < limit and mode != Mode.OVER and not (mode == Mode.ENDING and boss == null and _screen != null):
		await get_tree().process_frame
		t += get_process_delta_time()
	print("RESULT ", result())
	get_tree().quit()
