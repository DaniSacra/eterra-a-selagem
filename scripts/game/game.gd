class_name Game
extends Node3D
## One run in the catacombs. Owns the clock: every system is stepped from here, so hit stop, pause and the gift
## choice are just "do not step". The world is 3D; the game itself plays on the floor plane (x, z) in meters.

enum Mode { PLAY, CHOICE, PAUSE, OVER, ENDING }

## Morvath fell: his short ending begins (Boss.VICTORY_TIME; the paladin keeps his control through it).
signal victory_started
## The ending is over: the end screen opens right after (the fight's numbers: Boss.stats).
signal victory_finished(stats: Dictionary)
## The run is over and logged (RunLog): outcome is victory, death or quit; entry is the line written (also when the
## log is off: --nosave and the bot write nothing).
signal run_logged(outcome: String, entry: Dictionary)
## A Psalm came on a card (E4): first when the Codex never had it (the "Salmo descoberto" greeting, without pausing).
signal psalm_offered(psalm: PsalmDef, first: bool)
## A Psalm was taken: first when it was never taken before in the save (its short line, PsalmDef.line_key).
signal psalm_taken(psalm: PsalmDef, first: bool)

## Magia a kill gives back (Player.magick).
const MAGICK_PER_KILL := 1.0
const MAGICK_PER_ELITE := 40.0
const WAVES := "res://data/waves/catacombs.tres"
const FOUNTAIN_HEAL := 0.4
## Each new level, the gift arrives with a little of the companions' strength.
const LEVEL_HEAL := 0.15
## --start= in the room mode: which room to begin in.
const ROOM_STARTS := {"boss": RunMap.Kind.BOSS, "miniboss": RunMap.Kind.MINIBOSS, "shop": RunMap.Kind.SHOP, "fountain": RunMap.Kind.FOUNTAIN,
	"trial": RunMap.Kind.TRIAL, "altar": RunMap.Kind.ALTAR}
const SPAWN_MIN := 19.0
const SPAWN_MAX := 25.0
## How far the point the camera looks at stays from the side walls and from the north and south ends (meters), with
## the camera CamFrame.MARGIN_DISTANCE away: a closer camera gets closer to them (CamFrame.margin). The paladin comes
## first: the margins give way so that he never stands near an edge of the screen (CamFrame.keep).
const CAM_MARGIN := Vector2(10.0, 5.0)
## The low camera sees far past the south edge: it stops sooner there.
const CAM_SOUTH := 9.0
## When the ending's lines fade in (s after Morvath falls, real time) and how far apart.
const VICTORY_CAPTION_AT := 0.6
const VICTORY_CAPTION_GAP := 1.1
## The band of the screen the lines are read in (share of its height, from the top).
const VICTORY_CAPTION_BAND := Vector2(0.7, 0.86)

var arena: Arena
var ground: Ground
var orbs: Orbs
var player: Player
var horde: Horde
var projectiles: Projectiles
var combat: Combat
## The passive and the Gifts at play (E2-07, E2-09).
var hero_gifts: HeroGifts
## The Psalms of the run (E4): the rules (taken, seen, the draw) and their effects at play.
var psalms: Psalms
var psalm_play: PsalmPlay
## Whether a draw may hold a Psalm card: the robot and --autopick take one at once; a person only once the choice
## screen shows them (BoonChoice.open_cards; until then the Blessings' screen gets no Psalm card).
var psalm_cards := false
var skills: Skills
## The ultimate of this descent in play (charge, gesture's blow, the Voragem on the floor).
var ults: Ultimates
var boons: BoonState
## The hero played (DT-013) and, for this descent, the Gifts equipped (ids) and the ultimate chosen (id or "").
var hero: HeroDef = HeroDef.warrior()
var talents: Array[StringName] = []
var ultimate := ""
## The Juramentos sworn for this descent (E6, D-63): the save's once unlocked, or --juramentos=id:rank,... (the robot
## swears only those).
var juramentos: Juramentos
## Blessings offered on a card and Elos formed in this run (ids), for the Mastery's first times and the Codex.
var seen_boons := {}
var elos_formed := {}
## E4-05, for the Codex at the end of the run: enemies defeated by kind (EnemyDef.id: count; Morvath apart) and the
## arenas entered (RoomLayout.id, &"hall" for the hall: count).
var defeated := {}
var arenas_seen := {}
var director: WaveDirector
## The descent room by room (null in the endless hall, --horde).
var rooms: Rooms
## Life gained from hearts (kept when gifts change the life bar).
var life_bonus := 0.0
var boss: Boss
## The boss fight in numbers (Boss.stats; kept after he falls), for RESULT.
var boss_stats := {}
var fx: Fx
var hud: Hud
var ui: CanvasLayer
var _feel_panel: FeelPanel
var camera: Camera3D
var bot: Bot
## --watchdog (C17, BUG-110): a WATCH line every Watchdog.EVERY real seconds, kept in the run's log (null: off).
var watchdog: Watchdog = Watchdog.new() if Dev.has("watchdog") else null
var mode := Mode.PLAY
var time := 0.0
var level := 1
var xp := 0
var kills := 0
## Most enemies ever standing at once in this run (the boss and every summon included; RESULT max_alive).
var max_alive := 0
## Play time when Morvath came in (RESULT boss_at; -1: not yet).
var boss_at := -1.0
## Omegas let go (attack, special and circle) and dodges, for the run's log.
var omegas := 0
var dodges := 0
## What hurt the paladin last (DefeatCause.of: {"attack", "enemy"}); empty before any blow. defeated_by() names it.
var last_hurt := {}
## Each room in numbers (QW-011): its arena, life walking in, damage taken by kind, time; RESULT rooms, hp_at_boss.
var room_tally := RoomTally.new()
## The gifts in the order they were taken (ids), for the run's log.
var gifts_taken: Array[StringName] = []
var _logged := false
## The Mastery this run gave, for the end screen (E2-04): {gain (mastery_gain), xp_before (the hero's XP before it)}.
var mastery_report: Dictionary = {}
var fast := 1.0
## Smoothed cost of one simulation step, in milliseconds.
var step_ms := 0.0
## The step's cost while enemies stand (RESULT step_ms_avg, step_ms_peak).
var step_timer := StepTimer.new()
## When set, the camera looks here instead of at the paladin (the final scene).
var focus: Variant = null
var _pending_levels := 0
## The offer of each card on the table by gift id, as the choice screen reads it (BoonChoice.offer_of): {rarity,
## upgrade}, upgrade being a trade one rarity up (E3-01).
var _offer_rarity: Dictionary = {}
## The cards of the choice open now (or last opened): rarity, trade (E3-01), the gift replaced and the level it comes
## at; _offer_rarity is what the screen is given from them.
var offer_cards: Array[BoonState.Card] = []
var _screen: Control
## The two lines read during Morvath's ending.
var _caption: Control
var _screen_fx: ShaderMaterial
## The edge tint of a blow taken (BUG-007): red, or violet under the curse; numbers in Feel.
var _hurt_tint := HurtTint.new()
var _fountain: Node3D
var _fountain_at := Vector2.ZERO
var _fountain_used := false
var _cam_target := Vector3.ZERO
var _rng := RandomNumberGenerator.new()
var _found: Array[Enemy] = []


func _ready() -> void:
	# the click or key that started the run (the title's Iniciar, "Descer de novo") is no swing (E1c, bug 1)
	Controls.clear_presses()
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
	combat.hero = hero
	director = WaveDirector.new(load(WAVES), _rng)
	skills = Skills.new()
	skills.game = self
	add_child(skills)
	ults = Ultimates.new()
	add_child(ults)
	ults.setup(self)

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
	# shooters only wind up on the screen (cycle C12): where a floor point shows, at chest height, in the frame the
	# camera settles on for the paladin where he stands (the simulation's own, not the drawn camera's lag)
	horde.view = func(p: Vector2) -> Vector2:
		var fov := Feel.live().cam_fov
		var distance := Dev.num("cam-dist", Feel.live().cam_distance)
		var size := get_viewport().get_visible_rect().size
		return CamFrame.screen_of(p, 1.0, cam_look_at(player.pos, distance, fov), distance, Dev.num("cam-pitch", Feel.live().cam_pitch),
			cam_yaw(), fov, size.x / maxf(size.y, 1.0))
	combat.swung.connect(func(_n: ComboNode, struck: int) -> void:
		if struck > 0:
			room_tally.touch(time))

	player.struck.connect(combat.strike)
	player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void:
		if node.has_tag(Combat.OMEGA_TAG):
			omegas += 1)
	player.cast_released.connect(func(_at: Vector2, omega: bool) -> void:
		if omega:
			omegas += 1)
	player.glinted.connect(combat.glint)
	player.cast_released.connect(combat.cast)
	# was_hurt is emitted before died: the blow is counted before the run ends (BUG-014)
	player.was_hurt.connect(_on_was_hurt)
	player.died.connect(_on_player_died)
	player.dodged.connect(_on_dodged)
	Controls.forget_devices()
	player.shield_broke.connect(_on_shield_broke)
	player.move_shown.connect(func(node: ComboNode) -> void:
		hud.show_move(node, combat.color_of(node.tags))
		if SaveData.discover_move(Save.data, String(node.id)):
			Save.write())
	projectiles.shot_hit.connect(combat.on_shot_hit)
	projectiles.shot_logged.connect(room_tally.shot)
	projectiles.status_player.connect(_on_status_player)
	for source: Object in [horde, ground, projectiles]:
		source.hit_player.connect(_on_hit_player.bind(source))
	horde.killed.connect(_on_killed)
	horde.armor_broken.connect(_on_armor_broken)
	combat.combo_changed.connect(hud.on_combo)
	apply_options()

	if Dev.has("bot"):
		bot = Bot.new()
		Controls.virtual = bot.pad
	# the Gifts before the first room: it records the life he walks in with
	_equip_talents()
	ults.equip(hero.ultimate(StringName(ultimate)))
	if Dev.has("ult-full"):
		ults.charge.fill()  # dev: the ultimate starts full (captures, --start=boss)
	hero_gifts = HeroGifts.new(self)
	_swear_juramentos()
	psalms = Psalms.new(Psalms.load_catalog())
	psalm_play = PsalmPlay.new(self, psalms)
	psalm_cards = bot != null or Dev.has("autopick") or screen_shows_psalms()
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
	if Dev.has("boon-ids"):
		# --boon-ids=a,b,c: exactly these gifts (Boon ids, in order; an Elo after its two), for the boss simulations
		for id in Dev.arg("boon-ids").split(",", false):
			var b := boons.find(StringName(id))
			if b:
				_take(b)
			else:
				push_warning("--boon-ids: no gift %s" % id)
	if Dev.has("psalm"):
		# --psalm=a,b: these Psalms taken from the start (PsalmDef ids), for tests and captures
		for id in Dev.arg("psalm").split(",", false):
			var p := psalms.find(StringName(id))
			if p == null or not take_psalm(p):
				push_warning("--psalm: cannot take %s" % id)
	if Dev.has("stress"):
		player.max_hp = 99999.0
		player.hp = 99999.0
		var kinds: Array[StringName] = [&"skeleton", &"skeleton", &"archer", &"runner", &"mage", &"guard"]
		if Dev.has("stress-ids"):
			# --stress-ids=a,b,c: these enemies (EnemyDef ids), in turn, for captures of chosen kinds
			kinds.assign(Array(Dev.arg("stress-ids").split(",")).map(func(id: String) -> StringName: return StringName(id)))
		for i in int(Dev.num("stress", 300)):
			horde.spawn(horde.def(kinds[i % kinds.size()]), arena.resolve(player.pos + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(4.0, 20.0), 0.5), false)
	if Dev.has("hero-hp"):
		# dev, for captures: the paladin's life (a defeat in a few blows, or blows taken without falling)
		player.max_hp = Dev.num("hero-hp", hero.max_hp)
		player.hp = player.max_hp
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
	# the catacomb hall of the reference image (2026-11-14): a cold, dark teal air; the warmth comes only from fire
	# and candles, the green from the portal, the violet from the depths
	e.background_mode = Environment.BG_COLOR
	e.background_color = SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = AMBIENT
	e.ambient_light_energy = AMBIENT_ENERGY
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.tonemap_exposure = EXPOSURE
	e.glow_enabled = true
	e.glow_intensity = GLOW_INTENSITY
	e.glow_strength = 1.0
	e.glow_bloom = 0.03
	e.glow_hdr_threshold = GLOW_THRESHOLD
	e.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	# the fires and the portal keep their shape: the widest level only a little, so no big halo washes the stone
	for i in 7:
		e.set_glow_level(i, GLOW_LEVELS[i])
	# haze only past the hall (by depth from the camera), and a height fog filling the abyss below the floor: the
	# depths turn to teal mist, the hall itself stays clear
	e.fog_enabled = true
	e.fog_mode = Environment.FOG_MODE_DEPTH
	e.fog_light_color = FOG
	e.fog_depth_begin = FOG_BEGIN
	e.fog_depth_end = FOG_END
	e.fog_depth_curve = 1.0
	e.fog_height = FOG_HEIGHT
	e.fog_height_density = FOG_HEIGHT_DENSITY
	e.fog_aerial_perspective = 0.2
	# desktop (Forward+) only, ignored by the browser's renderer: a little light in the air around the fires and the
	# portal (no ambient in it: it would lift every black), contact shadows, the wet floor mirroring the light (fog in
	# the air and reflections only switched on there: the browser's renderer warns in the log for each, BUG-011)
	var forward := RenderingServer.get_current_rendering_method() != "gl_compatibility"
	e.volumetric_fog_enabled = forward
	e.volumetric_fog_density = VOLUMETRIC_DENSITY
	e.volumetric_fog_albedo = Color(0.7, 0.72, 0.78)
	e.volumetric_fog_emission = Color.BLACK
	e.volumetric_fog_gi_inject = 0.0
	e.volumetric_fog_length = 90.0
	e.volumetric_fog_ambient_inject = 0.0
	e.ssao_enabled = true
	e.ssao_radius = SSAO_RADIUS
	e.ssao_intensity = SSAO_INTENSITY
	e.ssao_light_affect = SSAO_LIGHT_AFFECT
	e.ssr_enabled = forward
	e.ssr_max_steps = 48
	e.adjustment_enabled = true
	e.adjustment_contrast = ADJUST_CONTRAST
	e.adjustment_saturation = ADJUST_SATURATION
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# the browser's renderer has no fog in the air nor contact shadows and lights the stone brighter: darker
		# exposure and ambient so it keeps the desktop's mood
		e.tonemap_exposure = COMPAT_EXPOSURE
		e.ambient_light_energy = COMPAT_AMBIENT
	env.environment = e
	add_child(env)
	var moon := DirectionalLight3D.new()
	# a cold light from high behind the hall (north-west), rimming the stone and the fighters
	moon.rotation_degrees = Vector3(-50, 150, 0)
	moon.light_color = Color(0.5, 0.75, 0.85)
	moon.light_energy = 0.35
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 90.0
	moon.light_volumetric_fog_energy = 0.3
	add_child(moon)
	# the visual profile (--look, F7): the stylized proof's numbers for the air and the key (VisualProfile)
	VisualProfile.dress_world(e, moon)

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
	player.hero = hero
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
	# left in the middle (to the title, a new descent, the window closed): the run is logged as left
	log_run("quit")
	if _cam_trace != null and _cam_trace.frames > 0:
		_trace_cam_cut(true)
	Controls.virtual = null
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	var shake := fx.tick(delta)
	if watchdog:
		var sample := watchdog.tick(Time.get_ticks_msec() / 1000.0, Engine.get_frames_drawn(), Mode.keys()[mode], fx.rate,
			Engine.time_scale, time)
		if not sample.is_empty():
			print(Watchdog.line(sample))
	# the world's own seconds this frame: real time times the slow motion and the hit stop (Fx.rate, GF-01: a hit
	# stop slows the world to a few percent, it never stops it)
	var world_dt := fx.real_dt * fx.rate
	fx.animate(world_dt)
	if bot:
		bot.step(world_dt, self)
	var stepped := false
	if mode == Mode.PLAY or mode == Mode.OVER or mode == Mode.ENDING:
		if world_dt > 0.0:
			_timed_step(minf(world_dt, 0.05))
			stepped = true
	horde.render(world_dt)
	orbs.render()
	if mode == Mode.PLAY and Controls.pressed(&"pause"):
		_open_pause()
	if OS.is_debug_build() and Controls.pressed(&"feel_panel"):
		_toggle_feel_panel()
	if Controls.pressed(&"look_toggle"):
		VisualProfile.toggle()
	_hurt_tint.step(fx.real_dt, Feel.live())
	var low := 1.0 - clampf(player.hp / player.max_hp / 0.3, 0.0, 1.0)
	if mode != Mode.PLAY and mode != Mode.ENDING and not Dev.has("lab"):
		fx.end_slow()
	_screen_fx.set_shader_parameter(&"split", fx.split)
	_screen_fx.set_shader_parameter(&"radial", fx.radial)
	_screen_fx.set_shader_parameter(&"impact", 1.0 if fx.frame_left > 0.0 else 0.0)
	# low life: a slow red pulse at the edges, as strong as a heavy blow at most
	_screen_fx.set_shader_parameter(&"hurt", maxf(_hurt_tint.red, low * Feel.live().hurt_tint * (0.75 + 0.25 * sin(time * 6.0))))
	_screen_fx.set_shader_parameter(&"curse", _hurt_tint.violet)
	_follow(delta, shake)
	# a button pressed during a hit stop is kept for the next step (a swing must never be lost)
	if stepped or mode != Mode.PLAY:
		Controls.flush()
	else:
		Controls.latch_virtual()


func _step(dt: float) -> void:
	_lap(&"")
	if rooms:
		if mode == Mode.PLAY:
			time += dt
			rooms.step(dt)
	else:
		if mode == Mode.PLAY:
			_step_waves(dt)
		# the clock the player sees is play time; the timeline may run faster (WaveTable.pace)
		time = director.time / director.table.pace
	_lap(&"rooms")
	player.cast_active = _circle_standing()
	if mode == Mode.ENDING:
		player.rest()
		player.step(dt, Vector2.ZERO, Vector2.ZERO)
	else:
		player.step(dt, _move(), _aim())
	# (before the crowd: the Voragem's pull is swept, then the crowd keeps off the paladin)
	ults.step(dt)
	_lap(&"player")
	horde.target = player.pos
	horde.target_alive = player.alive() and mode == Mode.PLAY
	horde.step(dt)
	_lap(&"horde")
	if boss:
		boss.step(dt)
	_lap(&"boss")
	max_alive = maxi(max_alive, horde.count())
	projectiles.step(dt)
	_lap(&"shots")
	ground.step(dt)
	_lap(&"ground")
	combat.step(dt)
	hero_gifts.step(dt)
	psalm_play.step(dt)
	_lap(&"combat")
	if mode == Mode.PLAY:
		skills.step(dt)
	_lap(&"skills")
	var got := orbs.step(dt, player.pos)
	if got > 0 and rooms == null:
		_gain_xp(got)
	_step_fountain()
	if _pending_levels > 0 and mode == Mode.PLAY and player.alive() and rooms == null:
		_open_choice()


## The camera's turn around the up axis, degrees (--cam-yaw overrides it).
func cam_yaw() -> float:
	return Dev.num("cam-yaw", Feel.live().cam_yaw)


## Where the player pushes, on the floor: keys and sticks are screen directions, turned by the camera's yaw; the bot
## (and touch) already give floor directions.
func _move() -> Vector2:
	var v := Controls.move()
	return v if Controls.virtual != null else Feel.screen_to_floor(v, cam_yaw())


## Where the paladin aims: the mouse pointer on the floor, or the stick (Controls).
func _aim() -> Vector2:
	if Controls.aims_with_mouse():
		var hit := aim_floor()
		if hit == Vector2.INF:
			return Vector2.ZERO
		var d := hit - player.pos
		return d.normalized() if d.length() > 0.2 else Vector2.ZERO
	var a := Controls.aim(Vector2.ZERO, Vector2.ZERO)
	return a if Controls.virtual != null else Feel.screen_to_floor(a, cam_yaw())


## The point of the floor (x, z) under the mouse pointer, at the height of a blow (1 m); INF when the ray misses it.
func aim_floor() -> Vector2:
	var mouse := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse)
	var dir := camera.project_ray_normal(mouse)
	if absf(dir.y) <= 0.001:
		return Vector2.INF
	var hit := from + dir * ((1.0 - from.y) / dir.y)
	return Vector2(hit.x, hit.z)


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
	column(at, d.rim_color, 1.5, 12.0, 1.0)
	hud.show_notice(T.t(&"notice_elite", {"name": T.t(d.name_key)}))
	Audio.play(&"elite")


func _circle_standing() -> bool:
	for z in ground.zones:
		if z.kind == Ground.Kind.BIND:
			return true
	return false


## A new room: the old one is taken down and this one built (layout null: the great hall).
## Dev (--trace-cam, GP-06): the largest jump of the camera's target between frames, printed per room (CAM_TRACE).
var _cam_trace: CamFrame.JumpTrace = CamFrame.JumpTrace.new() if Dev.has("trace-cam") else null
## The largest of every room so far.
var _cam_worst := {"worst": 0.0}


## Dev (--trace-cam): prints the room's largest jump of the camera's target and starts over (a new room places the
## camera anew; that first frame is not a jump). last: also the run's largest.
func _trace_cam_cut(last := false) -> void:
	if _cam_trace == null:
		return
	var r := _cam_trace.cut()
	if int(r.frames) > 1:
		print("CAM_TRACE room %s %s: max jump %.3f m over %d frames at %s" % [r.at.get("room", "?"), r.at.get("arena", "?"),
			r.worst, r.frames, r.at])
		if float(r.worst) > float(_cam_worst.worst):
			_cam_worst = r
	if last:
		print("CAM_TRACE run: max jump %.3f m at %s" % [_cam_worst.worst, _cam_worst.get("at", {})])


func rebuild_room(layout: RoomLayout, exits: int, seed_: int) -> void:
	_trace_cam_cut()
	ground.clear()
	ults.clear()
	psalm_play.clear()
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
	var place := arena.id if arena.id != &"" else &"hall"
	arenas_seen[place] = int(arenas_seen.get(place, 0)) + 1


## Gifts by a cleared room or the shop: three cards drawn with these rarity chances (Boon.RARITY_CHANCE; the stage's
## own in the rooms), with the stage's chances of an Elo and of a trade, and of a Psalm (psalm_chance < 0: the stage's
## for a room, StageDef.psalm_chance; the guardian passes its own).
func open_boon_choice(chances: Array[float] = Boon.RARITY_CHANCE, psalm_chance := -1.0) -> void:
	_open_choice(_draw_cards(chances, psalm_chance))


func _draw_cards(chances: Array[float] = Boon.RARITY_CHANCE, psalm_chance := -1.0) -> Array[BoonState.Card]:
	var elo := rooms.stage.elo_chance if rooms else Boon.ELO_CHANCE
	var trade := rooms.stage.trade_chance if rooms else Boon.TRADE_CHANCE
	var cards := boons.draw(_rng, 3, chances, elo, trade)
	# Psalms only in the descent by rooms (the old endless hall, --horde, stays as it was)
	if psalm_cards and rooms != null:
		psalms.fill(cards, _rng, rooms.stage.psalm_chance if psalm_chance < 0.0 else psalm_chance, boons, talents)
	return cards


## True when the choice screen shows Psalm cards (it has open_cards(cards, state, game) and emits
## card_chosen(card); E4-03 is the UI's task).
static func screen_shows_psalms() -> bool:
	var screen: Script = load("res://scripts/ui/boon_choice.gd")
	return screen.get_script_method_list().any(func(m: Dictionary) -> bool: return m.name == "open_cards")


## Takes a Psalm (the card picked, the robot, --psalm). False when the rules say no (Psalms.take).
func take_psalm(p: PsalmDef) -> bool:
	if not psalms.take(p):
		return false
	var codex: Dictionary = (Save.data.get("codex", {}) as Dictionary).get("psalms", {})
	var first := int((codex.get(String(p.id), {}) as Dictionary).get("taken", 0)) == 0
	fx.ring(player.pos, 3.5, p.color, 0.6)
	column(player.pos, p.color, 1.4, 9.0, 0.8)
	fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))
	fx.word(Vector3(player.pos.x, 3.2, player.pos.y), T.t(p.name_key), p.color)
	Music.sting(p.id)  # the Psalm's theme over the bed (E4-06)
	psalm_taken.emit(p, first)
	return true


## Picks one card of the choice open now (a Blessing, an Elo, a trade or a Psalm): what a screen with Psalm cards
## calls (card_chosen) and what the robot does.
func choose_card(c: BoonState.Card) -> void:
	if mode != Mode.CHOICE:
		return
	if c != null and c.psalm != null:
		_close_screen()
		take_psalm(c.psalm)
		offer_cards.clear()
		_back_to_play()
	else:
		_on_chosen(c.boon if c != null else null)


## Juramento Escolhas Perdidas (E6, Hades II's Denial): after a Blessing is chosen from a draw, some of the others
## offered leave the descent (BoonState.banned). Never from a pomegranate's choice (those are held already).
func _deny_others(chosen: Boon) -> void:
	if juramentos == null:
		return
	var offered: Array[StringName] = []
	for c in offer_cards:
		if c.boon != null and c.psalm == null and not c.grow:
			offered.append(c.boon.id)
	if not offered.has(chosen.id):
		return
	for id in juramentos.denial(offered, chosen.id):
		boons.banned[id] = true


## A level more for a gift already owned (the paladin picks which).
func open_grow_choice() -> void:
	_open_choice(boons.grow_cards(_rng))


## A slice of pomegranate (the shop, C13-04): one level more for a Blessing held, drawn, no choice. False when none
## can grow.
func grow_random() -> bool:
	var cards := boons.grow_cards(_rng, 1)
	if cards.is_empty():
		return false
	# _take clears offer_cards, which is this very array: keep the Blessing first
	var b := cards[0].boon
	offer_cards = cards
	_take(b)
	fx.word(Vector3(player.pos.x, 3.0, player.pos.y), T.t("boon_" + String(b.id)), b.color())
	return true


## A heart: more life, and that much healed.
func add_max_life(amount: float) -> void:
	life_bonus += amount
	player.max_hp += amount
	player.heal(amount)
	fx.word(Vector3(player.pos.x, 3.0, player.pos.y), "+%d %s" % [int(amount), T.t(&"hud_life")], Color(1.0, 0.4, 0.5))


func start_boss(id: StringName) -> void:
	_start_boss(id)


func _start_boss(id: StringName) -> void:
	boss_at = time
	if hero_gifts != null:
		hero_gifts.state.boss_room = true  # Ainda de Pé guards the descent, not Morvath's fight (E6)
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
	# his music, one layer more per phase (E4-06)
	Music.boss_phase(boss.phase)
	boss.phase_changed.connect(Music.boss_phase)
	boss.moment.connect(func(name: StringName) -> void:
		if name == &"victory":
			_on_boss_falling())


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


## cards: BoonState.Card (or plain Boon, taken as common cards at one level more: the laboratories and tests).
func _open_choice(cards: Array = []) -> void:
	mode = Mode.CHOICE
	if rooms == null:
		cards = _draw_cards()
	offer_cards.clear()
	for c: Variant in cards:
		offer_cards.append(c if c is BoonState.Card else boons.cards_for([c])[0])
	_offer_rarity = BoonChoice.offers_of(offer_cards)
	var offers: Array[Boon] = []
	var psalm_card: BoonState.Card = null
	for c in offer_cards:
		if c.psalm != null:
			psalm_card = c
			_saw_psalm(c.psalm)
			continue
		offers.append(c.boon)
		if not c.grow:
			seen_boons[c.boon.id] = true
	if (Dev.has("autopick") or bot) and psalm_card != null:
		# the robot and the captures take the Psalm when one comes
		choose_card(psalm_card)
		return
	if Dev.has("autopick") or (offers.is_empty() and psalm_card == null):
		# captures of the fight: take a gift at once, no screen
		_on_chosen(offers[0] if not offers.is_empty() else null)
		return
	var choice := BoonChoice.new()
	_screen = choice
	ui.add_child(choice)
	if psalm_card != null and choice.has_method(&"open_cards"):
		choice.call(&"open_cards", offer_cards, boons, self)
		choice.connect(&"card_chosen", choose_card)
	else:
		choice.open(offers, boons, _offer_rarity)
	choice.chosen.connect(_on_chosen)
	fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))
	if bot and not Dev.has("hold"):
		get_tree().create_timer(0.6).timeout.connect(func() -> void:
			if mode == Mode.CHOICE:
				_on_chosen(offers[_rng.randi() % offers.size()] if not offers.is_empty() else null))


## A Psalm came on a card: seen in this run (the Codex at the end) and greeted the first time ever.
func _saw_psalm(p: PsalmDef) -> void:
	if psalms.seen.has(p.id):
		return
	psalms.seen[p.id] = true
	var codex: Dictionary = (Save.data.get("codex", {}) as Dictionary).get("psalms", {})
	psalm_offered.emit(p, not codex.has(String(p.id)))


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
	_back_to_play()


func _take(b: Boon) -> void:
	var old_hp_bonus := boons.stat(&"max_hp")
	var card: BoonState.Card = null
	for c in offer_cards:
		if c.boon == b:
			card = c
	if card != null:
		boons.take_card(card)
	else:
		boons.take(b, BoonChoice.offer_of(_offer_rarity.get(b.id)).rarity)
	_deny_others(b)
	offer_cards.clear()
	gifts_taken.append(b.id)
	if b.is_duo():
		elos_formed[b.id] = true
	player.dodge_max = hero.dodge_charges + int(boons.stat(&"dodge_charges"))
	player.speed_bonus = boons.stat(&"move_speed_pct")
	var shield := boons.stat(&"shield_cooldown")
	if shield > 0.0 and player.shield_cooldown <= 0.0:
		player.shield_ready = true
	player.shield_cooldown = shield
	var hp_bonus := boons.stat(&"max_hp")
	player.max_hp = hero.max_hp + hp_bonus + life_bonus
	player.heal(hp_bonus - old_hp_bonus)
	fx.ring(player.pos, 3.0, b.color(), 0.5)
	column(player.pos, b.color(), 1.2, 8.0, 0.6)
	fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))


func _on_dodged(dir: Vector2) -> void:
	dodges += 1
	room_tally.dodge()
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
		horde.dealing = &"bastiao"
		for e: Enemy in _found.duplicate():
			if not horde.damage(e, burst, (e.pos - player.pos).normalized(), 12.0) and e.def.behavior != EnemyDef.Behavior.BOSS:
				e.stun_t = maxf(e.stun_t, 1.0)
		horde.dealing = &""


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
	# the basin, its water and its spring (AP-1, ART-01.6: ArenaKit.fountain), and its light in the Fonte's colour
	ArenaKit.fountain(_fountain)
	var l := OmniLight3D.new()
	l.name = "Light"
	l.position.y = 2.0
	l.light_color = ArenaKit.FOUNTAIN_LIGHT
	l.light_energy = 3.0
	l.omni_range = 9.0
	l.light_cull_mask = ~Arena.CROWD_LAYER
	_fountain.add_child(l)
	var pool := ground.add_zone(Ground.Kind.HOLY, _fountain_at, 1.8, 9999.0, 0.0)
	pool.tags = []
	column(_fountain_at, Combat.LIGHT, 1.4, 14.0, 1.2)
	hud.show_notice(T.t(&"notice_fountain"), 4.0)
	Audio.play(&"fountain")


func _step_fountain() -> void:
	if _fountain == null or _fountain_used or not player.alive():
		return
	if player.pos.distance_to(_fountain_at) < 2.0 and player.hp < player.max_hp:
		_fountain_used = true
		room_tally.fountain()
		player.heal(player.max_hp * FOUNTAIN_HEAL)
		(_fountain.get_node("Light") as OmniLight3D).light_energy = 0.6
		(_fountain.get_node("Spring") as CPUParticles3D).emitting = false
		ArenaKit.fountain_spent(_fountain)
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

func _on_hit_player(amount: float, from: Vector2, source: Object = null) -> void:
	if mode != Mode.PLAY:
		return
	# what hurt him: the warning or shot's attack (Ground/Projectiles.last_source) and the kind that laid it
	# (last_by; for a plain blow of the crowd, Horde.last_by). Read before the blow lands: a killing blow emits
	# Player.died inside hurt(), and the run is logged right there (BUG-014: it used to log the blow before).
	var id: Variant = source.get(&"last_source") if source else null
	_blow = {"cause": DefeatCause.of(id, source.get(&"last_by") if source else null), "id": id}
	_blow.merge(_blow_context(source, id))
	player.hurt(amount, from)
	_blow = {}


## The blow being dealt (_on_hit_player), while Player.hurt runs: its cause and attack id, and its context for the
## run's log (_blow_context).
var _blow := {}


## The context of a blow about to land, for the run's log (GP-02): warn_s (seconds its warning showed: the swing
## raised, the warning on the floor, the shooter's aim and the shot's flight; a boss's crescent adds the lane he
## marked first; -1: none known), dash_ready (a dodge charge to use), offscreen (whoever dealt it off the screen as
## it struck or fired; the boss's own warnings read where he stands now) and, for a shot, its shooter.
func _blow_context(source: Object, id: Variant) -> Dictionary:
	var warn: Variant = source.get(&"last_warn") if source else null
	var warn_s := float(warn) if warn != null else -1.0
	if source == projectiles and warn_s >= 0.0 and id is StringName and id != &"":
		warn_s += ground.warned_for(id)
	var flag: Variant = source.get(&"last_offscreen") if source else null
	var off := int(flag) if flag != null else -1
	if off < 0 and boss != null and boss.e != null:
		off = horde.screen_flag(boss.e.pos)
	return {"warn_s": warn_s, "dash_ready": player.dodge_charges > 0, "offscreen": off == 1,
		"shooter": Projectiles.shooter_of(projectiles.last_by) if source == projectiles else ""}


## The paladin lost life (Player.was_hurt, emitted before died): the blow's cause is kept and counted now, so a
## killing blow is in the log, on the end screen and in the boss's numbers (BUG-014).
func _on_was_hurt(amount: float) -> void:
	combat.drop_combo()
	if _blow.is_empty():
		return
	var id: Variant = _blow.id
	last_hurt = _blow.cause
	# what he really lost (a killing blow's overkill is not counted)
	amount += minf(player.hp, 0.0)
	var by := DefeatCause.key(last_hurt)
	room_tally.hurt(by, amount)
	room_tally.hurt_context(by, time, amount, float(_blow.get("warn_s", -1.0)), bool(_blow.get("dash_ready", false)),
		bool(_blow.get("offscreen", false)))
	if String(_blow.get("shooter", "")) != "":
		room_tally.shot(_blow.shooter, RoomTally.SHOT_HIT)
	room_tally.touch(time)
	# the edge of the screen says it: red, or the curse's violet (its bolt too, the curse lands just after)
	fx.kick_split(_hurt_tint.hit(amount, player.curse.active() or id == &"curse", Feel.live()))
	if boss:
		# for the fight's numbers; blows of the crowd are his dead
		boss.record_hurt(id if id is StringName else &"adds", amount)


## A boss's shot with a status struck the paladin: the curse (its numbers are the boss's BossDef).
func _on_status_player(status: StringName) -> void:
	if mode != Mode.PLAY or boss == null or status != &"curse":
		return
	if player.apply_curse(boss.def.curse_time, boss.def.curse_slow, boss.def.curse_immunity):
		boss.on_cursed()


## An elite's or Morvath's armor broke: a stagger, and a moment to punish.
func _on_armor_broken(e: Enemy) -> void:
	# the gold shards of the break are EnemyFx's (one effect, not two)
	fx.shake(3.0)
	Audio.play(CombatSounds.EVENTS[&"armor_break"])
	if boss and boss.e == e:
		boss.break_armor()
		return
	# the stagger of a broken armor is a stun (Hades ArmorBreakStun): the attack it was winding up is cut (GF-12)
	horde.interrupt(e)
	e.stun_t = maxf(e.stun_t, e.def.armor_stagger)
	fx.word(Vector3(e.pos.x, 2.0 + 2.0 * e.def.size, e.pos.y), T.t(&"word_stagger"), Combat.LIGHT)
	Audio.play(CombatSounds.EVENTS[&"stagger"])


func _on_killed(e: Enemy) -> void:
	kills += 1
	if e.def.behavior != EnemyDef.Behavior.BOSS:
		defeated[e.def.id] = int(defeated.get(e.def.id, 0)) + 1
	if rooms == null:
		player.magick.gain(MAGICK_PER_ELITE if e.def.elite else MAGICK_PER_KILL)
	if rooms:
		pass  # no experience in the rooms: gifts come from rewards
	elif e.def.elite:
		for i in 14:
			orbs.drop(e.pos + Vector2.from_angle(TAU * i / 14.0) * 1.2, maxi(1, e.def.xp / 14))
		fx.shake(3.0)
		column(e.pos, e.def.rim_color, 1.5, 12.0, 0.8)
		Audio.play(&"elite_down")
	elif e.def.behavior != EnemyDef.Behavior.BOSS:
		orbs.drop(e.pos, e.def.xp)
	var heal := boons.stat(&"heal_on_kill")
	if heal > 0.0 and player.alive():
		player.heal(heal)


func _on_player_died() -> void:
	mode = Mode.OVER
	if bot:
		bot.on_died()
	if boss:
		boss.record_death()
	Save.data.runs += 1
	Save.write()
	log_run("death")
	# the fight's music goes; the walk stays under the end screen (never silence with the music on)
	Music.play(&"catacombs", Music.WALK)
	await get_tree().create_timer(1.8).timeout
	_open_end(false, false)


## Morvath fell (Boss._on_killed): his ending plays (Boss._step_dying) while two lines are read; the paladin keeps
## his control. The epitaph (ending_1 to ending_3) is the end screen's.
func _on_boss_falling() -> void:
	_victory_caption()
	victory_started.emit()


## The ending is over: the run is won, the sealing closes (_play_ending) and the end screen opens.
func _on_boss_defeated() -> void:
	mode = Mode.ENDING
	var at := boss.center if boss else player.pos
	Save.data.runs += 1
	Save.data.wins += 1
	# a run without a save (--nosave) keeps no record, so it can never be a new best (BUG-008)
	var new_best := SaveData.record_win_time(Save.data, time, Save.enabled)
	Save.write()
	log_run("victory")
	await _play_ending(at)
	_open_end(true, new_best)


## The close of the sealing. Its scene already played while the paladin kept control (Boss._step_dying, VICTORY_TIME,
## during victory_started); here its caption goes and victory_finished tells the end screen. Kept a coroutine so the
## end screen's flow stays "await _play_ending(at), then _open_end".
func _play_ending(_at: Vector2) -> void:
	if is_instance_valid(_caption):
		_caption.queue_free()
	victory_finished.emit(boss_stats)
	await get_tree().process_frame


## What the ending says while it plays (victory_1, victory_2), fading in one after the other.
func _victory_caption() -> void:
	_caption = Control.new()
	_caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption.theme = UiKit.theme()
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_caption)
	# low on the screen and with no veil over it: the ending is seen, not covered
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.anchor_top = VICTORY_CAPTION_BAND.x
	box.anchor_bottom = VICTORY_CAPTION_BAND.y
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.add_child(box)
	var delay := VICTORY_CAPTION_AT
	for key: StringName in [&"victory_1", &"victory_2"]:
		var l := UiKit.label(T.t(key), UiKit.PALE, 24, UiKit.TITLE_FONT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.modulate.a = 0.0
		box.add_child(l)
		create_tween().tween_property(l, "modulate:a", 1.0, 0.6).set_delay(delay)
		delay += VICTORY_CAPTION_GAP


func _open_end(victory: bool, new_best: bool) -> void:
	var end := EndScreen.new()
	_screen = end
	ui.add_child(end)
	end.open(victory, {"time": time, "level": level if rooms == null else 0, "kills": kills, "best_combo": combat.best_combo, "boons": boons.owned().size(),
		"defeated_by": defeated_by() if not victory and not last_hurt.is_empty() else &"", "mastery": mastery_report}, new_best)
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


## A choice screen over the run that stops it (E5: the Provação's cards, the altar's trades; EventChoice). The one
## who opens it closes it with close_screen when its choice is made.
## burst false for a screen that only shows (the descent's map): no light on the hero.
func open_screen(screen: Control, burst: bool = true) -> void:
	mode = Mode.CHOICE
	_screen = screen
	ui.add_child(screen)
	if burst:
		fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))


## Closes the screen opened by open_screen; the run goes on (the press that closed it plays nothing).
func close_screen() -> void:
	_close_screen()
	_back_to_play()


func _open_pause() -> void:
	mode = Mode.PAUSE
	var pause := PauseMenu.new()
	_screen = pause
	ui.add_child(pause)
	pause.open()
	pause.resumed.connect(func() -> void:
		_close_screen()
		apply_options()
		_back_to_play())


## A screen over the run closed: the run goes on, and the press that closed it (a click on a card, Continuar, the
## pause key) plays nothing (Controls.clear_presses; E1c, bug 1).
func _back_to_play() -> void:
	Controls.clear_presses()
	mode = Mode.PLAY


## The comfort options of the save that the run reads (the pause's Options may change them): screen shake, the
## black and white impact frames, slow motion (with its zoom and radial blur) and the colour split.
func apply_options() -> void:
	fx.shake_scale = 1.0 if Save.option("shake") else 0.0
	fx.impact_frames = bool(Save.option("impact_frames"))
	fx.slow_motion = bool(Save.option("slow_motion"))
	fx.color_split = bool(Save.option("color_split"))
	# the gamepad's vibration (GF-11; on by default, also in saves from before the option)
	fx.rumble = bool(Save.option("rumble"))
	# the graphics quality's screen effects (E6, DT-003; the viewport's part is App.apply_options)
	for n in get_children():
		if n is WorldEnvironment:
			GraphicsQuality.apply_environment((n as WorldEnvironment).environment, GraphicsQuality.current(int(Save.option("quality"))))


func _close_screen() -> void:
	if _screen:
		_screen.queue_free()
		_screen = null


## The guardian or boss whose life bar is on screen, if any. In the rooms only guardians and Morvath get the big bar
## (as in Hades II; common elites keep the bar over their heads); the old horde mode still gives it to its elites.
func boss_enemy() -> Enemy:
	if boss and boss.e and boss.e.alive:
		return boss.e
	for e in horde.list:
		if not e.def.elite:
			continue
		if rooms == null or rooms.stage.minibosses.has(e.def.id):
			return e
	return null


## A column standing within this many meters of the paladin is drawn faint (GP-01: the reward's column rose on him).
const BEAM_NEAR_HERO := 2.0


## A column of light at a point (a reward, the fountain, a gift taken or falling, an elite rising): every one under
## the glow threshold (Fx.BEAM_CORE_CAP), and faint (Skills.BEAM_OVER_BOSS) where it would stand on or in front of
## the paladin or the boss on the screen, so neither of them is ever lost in it (GP-01 of cycle C12c).
func column(at: Vector2, color: Color, radius: float, height: float, time: float) -> void:
	var pitch := Dev.num("cam-pitch", Feel.live().cam_pitch)
	var faint := at.distance_to(player.pos) < BEAM_NEAR_HERO \
		or Skills.covers(player.pos, Player.RADIUS, at, radius, height, cam_yaw(), pitch) \
		or Skills.over_boss(boss_enemy(), at, radius, height, cam_yaw(), pitch)
	fx.beam(at, color, radius, height, time, Fx.BEAM_INTENSITY * (Skills.BEAM_OVER_BOSS if faint else 1.0))


## How much closer the camera gets at the end of an Omega's charge.
const OMEGA_ZOOM := 0.08
## How far the fixed showcase camera (--showcase) stands from the hall's middle, to frame all of it like the reference.
const SHOWCASE_DISTANCE := 60.0
## The browser's renderer (GL Compatibility) lights brighter than the desktop's (Forward+): its exposure and ambient.
const COMPAT_EXPOSURE := 1.25
const COMPAT_AMBIENT := 0.4
## The air of the hall (the reference image): cold teal behind and below, a low teal ambient, no violet in the air
## (the violet comes from the abyss lights). Fog by depth starts past the hall; height fog fills the abyss.
const SKY := Color(0.11, 0.2, 0.24)
const AMBIENT := Color(0.3, 0.4, 0.46)
const AMBIENT_ENERGY := 0.9
const EXPOSURE := 1.25
const FOG := Color(0.11, 0.2, 0.24)
const FOG_BEGIN := 64.0
const FOG_END := 170.0
const FOG_HEIGHT := -3.0
const FOG_HEIGHT_DENSITY := 0.6
const VOLUMETRIC_DENSITY := 0.0
## Glow: only colours over the threshold bloom (blades and slashes go past 2, fire tongues stay under 2), weight of
## each glow level (the widest, 4, kept low so fires and the portal have no big halo).
const GLOW_INTENSITY := 0.45
const GLOW_THRESHOLD := 1.3
const GLOW_LEVELS: Array[float] = [0.0, 1.0, 1.0, 1.0, 0.3, 0.0, 0.0]
## Contact shadows (desktop): corners and the feet of every piece dark, also where light falls.
const SSAO_RADIUS := 1.0
const SSAO_INTENSITY := 3.0
const SSAO_LIGHT_AFFECT := 0.2
## Colour adjustment after the tone map. Contrast over 1 cuts every value under 0.5 - 0.5 / contrast to black (1.12
## crushed the darkest teal to pure black and so to full saturation): kept low, the shadows keep their colour.
const ADJUST_CONTRAST := 1.05
const ADJUST_SATURATION := 1.3
var _charge_zoom := 0.0
## Where the paladin stood last frame and how fast he walks, smoothed (the camera leads by it).
var _cam_last := Vector2.ZERO
var _cam_vel := Vector2.ZERO
## The point the camera looked at last frame (INF: place it anew).
var _cam_at := Vector2.INF


## A new room: the camera starts framed on the paladin where he walks in, not flying over from where it looked in
## the room before (GP-06: that flight, behind the fade in, moved its target up to 2.9 m a frame).
func snap_camera() -> void:
	var at := arena.cam_target if arena.cam_reach > 0.0 else player.pos
	_cam_target = Vector3(at.x, 0, at.y)
	_cam_last = player.pos
	_cam_vel = Vector2.ZERO
	_cam_at = Vector2.INF
	if _cam_trace != null:
		_cam_trace.cut()


func _follow(delta: float, shake: Vector3) -> void:
	var look: Vector3
	if focus != null:
		look = focus
	elif arena.cam_reach > 0.0:
		# a boss chamber: the camera keeps to its point (cam_look_at moves it only for the paladin's safe frame)
		look = Vector3(arena.cam_target.x, 0, arena.cam_target.y)
	else:
		# a little ahead of where the paladin walks (never where he aims: standing still, he stays in the middle)
		var walked := (player.pos - _cam_last) / maxf(delta, 0.001)
		_cam_last = player.pos
		_cam_vel = _cam_vel.lerp(walked, 1.0 - exp(-delta * 5.0))
		var lead := (_cam_vel / maxf(Feel.live().speed, 0.1)).limit_length(1.0) * Feel.live().cam_lead
		look = Vector3(player.pos.x + lead.x, 0, player.pos.y + lead.y)
	_cam_target = _cam_target.lerp(look, 1.0 - exp(-delta * (2.5 if focus != null else Feel.live().cam_smooth)))
	_place_camera(shake, delta)


func _place_camera(shake: Vector3, delta: float) -> void:
	if Dev.has("showcase"):
		# the fixed frame of the whole hall, to set side by side with the reference image
		var c := arena.showcase
		if Dev.has("cam-at"):
			# --cam-at=x,z: the fixed camera looks at this floor point instead (close-ups of the hall)
			var xz := Dev.arg("cam-at").split(",")
			c = Vector3(float(xz[0]), 0.0, float(xz[1]))
		var off := Feel.cam_offset_of(Dev.num("cam-dist", SHOWCASE_DISTANCE), Dev.num("cam-pitch", Feel.live().cam_pitch), cam_yaw())
		camera.fov = Dev.num("cam-fov", Feel.live().cam_fov)
		camera.look_at_from_position(c + off, c, Vector3.UP)
		return
	var off := _cam_offset()
	var at := cam_look_at(Vector2(_cam_target.x, _cam_target.z), Dev.num("cam-dist", Feel.live().cam_distance), camera.fov)
	# never faster than CamFrame.MAX_SPEED (GP-06): the safe frame follows a dash or a push without a jump
	if _cam_at.is_finite():
		at = CamFrame.follow(_cam_at, at, delta)
	_cam_at = at
	if _cam_trace != null:
		_cam_trace.add(at, {"t": snappedf(time, 0.01), "room": rooms.depth() if rooms else 0, "arena": String(arena.id),
			"hero": player.pos, "mode": Mode.keys()[mode]})
	var t := Vector3(at.x, 0, at.y)
	camera.look_at_from_position(t + off + shake, t + shake * 0.5, Vector3.UP)


## The floor point the camera looks at, for the point it follows: inside the room's margins, unless the paladin
## would stand near an edge of the screen (the landing by the way in lies outside the room's rectangle).
func cam_look_at(want: Vector2, distance: float, fov: float) -> Vector2:
	if arena.cam_reach > 0.0:
		return chamber_look_at(want, distance, fov)
	var h := arena.half
	var side := maxf(0.0, h.x - CamFrame.margin(CAM_MARGIN.x, distance))
	var at := Vector2(clampf(want.x, -side, side), clampf(want.y,
		minf(0.0, -h.y + CamFrame.margin(CAM_MARGIN.y, distance) - arena.view_north), maxf(0.0, h.y - CamFrame.margin(CAM_SOUTH, distance))))
	if arena.cam_bounds.has_area():
		# an arena's own box for the point the camera looks at (cycle C12; the same spring follows it, no zoom)
		at = want.clamp(arena.cam_bounds.position, arena.cam_bounds.end)
	if focus != null:
		# a scene of its own (the fall of Morvath): the camera looks at it, wherever the paladin stands
		return at
	var view := get_viewport().get_visible_rect().size
	return CamFrame.keep(at, player.pos, distance, Dev.num("cam-pitch", Feel.live().cam_pitch), cam_yaw(), fov, view.x / maxf(view.y, 1.0))


## The floor point the camera looks at in a boss chamber (cycle C11, docs/art/boss_chamber_spec.md section 4): its
## fixed point (Arena.cam_target), moved only as much as the paladin's safe frame needs (CamFrame.keep, 18% of the
## screen), and never more than Arena.cam_reach meters from it.
func chamber_look_at(want: Vector2, distance: float, fov: float) -> Vector2:
	var view := get_viewport().get_visible_rect().size
	return CamFrame.hold(arena.cam_target, want, arena.cam_reach, player.pos, distance, Dev.num("cam-pitch", Feel.live().cam_pitch), cam_yaw(),
		fov, view.x / maxf(view.y, 1.0), focus == null)


## Camera offset from feel.tres; --cam-dist, --cam-pitch (degrees above the floor) and --cam-fov override it for tuning.
func _cam_offset() -> Vector3:
	var feel := Feel.live()
	# the camera closes in during slow motion and while an Omega charges (Hades II: 8% over the charge)
	var charge := player.charge_progress() * OMEGA_ZOOM
	_charge_zoom = charge if charge > _charge_zoom else lerpf(_charge_zoom, charge, 1.0 - exp(-get_process_delta_time() / maxf(Engine.time_scale, 0.001) * 6.0))
	camera.fov = Dev.num("cam-fov", feel.cam_fov) / (fx.zoom * (1.0 + _charge_zoom))
	return Feel.cam_offset_of(Dev.num("cam-dist", feel.cam_distance), Dev.num("cam-pitch", feel.cam_pitch), cam_yaw())


## --shot=file.png: saves what the player would see after --shot-at seconds, then quits. With --shot-on=swing|hit|
## special|omega|spin|boss:<moment> it then waits for the next such swing of the paladin (hit: one that reaches someone;
## special: the special's wave; spin: the combo's spin) and saves --shot-after seconds of real time later, so the swing's effects are on
## screen. Also ritual-left:<n> (n of the ritual's dead standing), hurt, hurt-cursed (a blow taken) and end (the end
## screen).
func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	if Dev.arg("shot-on").begins_with("boss:"):
		# a moment of the boss fight (Boss.moment): an attack's id, scythe_strike, blades_fire, storm_fire, ritual,
		# cursed, fallen
		var name := StringName(Dev.arg("shot-on").trim_prefix("boss:"))
		while true:
			if boss == null:
				await get_tree().process_frame
				continue
			var got: StringName = await boss.moment
			if got == name:
				break
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	elif Dev.arg("shot-on").begins_with("ritual-left:"):
		# the ritual's count on the boss's bar: waits until only N of its dead stand (Boss.ritual_changed)
		var left := int(Dev.arg("shot-on").trim_prefix("ritual-left:"))
		while boss == null or boss.ritual_left() != left or not boss.shielded():
			await get_tree().process_frame
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	elif Dev.arg("shot-on") == "hurt" or Dev.arg("shot-on") == "hurt-cursed":
		# a blow taken (hurt-cursed: one under a boss's curse), --shot-after seconds of real time after it
		var cursed := Dev.arg("shot-on") == "hurt-cursed"
		while true:
			await player.was_hurt
			if not cursed or player.curse.active():
				break
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	elif Dev.arg("shot-on") == "end":
		# the end screen (a defeat or the victory), --shot-after seconds after it opens
		while not _screen is EndScreen:
			await get_tree().process_frame
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	elif Dev.arg("shot-on") == "ult" or Dev.arg("shot-on") == "ult-gesture":
		# the ultimate: as its gesture begins (the band's warning) or as its blow lands, --shot-after seconds later
		if Dev.arg("shot-on") == "ult":
			await player.ult_landed
		else:
			await player.ult_started
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	elif Dev.has("shot-on"):
		var want := Dev.arg("shot-on")
		while true:
			var got: Array = await combat.swung
			var node: ComboNode = got[0]
			if want == "swing" or (want == "hit" and got[1] > 0) or (want == "special" and node.has_tag(&"wave") and not node.has_tag(&"omega")) \
					or (want == "omega" and node.has_tag(&"omega")) or (want == "spin" and node.has_tag(&"spin")):
				break
		# real time: hit stop and slow motion must not stretch the wait
		await get_tree().create_timer(Dev.num("shot-after", 0.066), true, false, true).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(Dev.arg("shot"))
	_trace_cam_cut(true)
	print(result_line())
	get_tree().quit()


## --frames=prefix: saves --count frames, one every --every seconds, starting at --shot-at (to check animations).
func _frames() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	for i in int(Dev.num("count", 12)):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s_%02d.png" % [Dev.arg("frames"), i])
		await get_tree().create_timer(Dev.num("every", 0.1)).timeout
	print(result_line())
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
		fx.glint(Vector3.ZERO, Combat.EMETH, 0.2, player.blade_tip)
	else:
		fx.slash(player.pos, dir, reach, Dev.num("lab-width", 270.0), Combat.EMETH, 0.25)
		if Dev.has("lab-crescent"):
			fx.crescent(player.pos, dir, reach, Dev.num("lab-width", 270.0), Combat.EMETH)
	if Dev.has("lab-impact"):
		fx.frame_left = 1000.0  # hold the impact frame for the still
	if Dev.has("lab-slow"):
		fx.slow_mo(0.35, 1000.0, 0.4, 1.1, 0.85, 0.01)  # the last-kill slow motion at its deepest
	var shown := 0
	for e in horde.list:
		if e.pos.distance_to(player.pos) <= reach + 0.4 and shown < int(Dev.num("lab-numbers", 12)):
			fx.number(Vector3(e.pos.x, 1.6, e.pos.y), 114, Color(1, 1, 1))
			shown += 1


## The text key naming what hurt the paladin last (DefeatCause): a boss attack (killer_<attack>), else the enemy
## kind's name (EnemyDef.name_key), else killer_unknown. The end screen shows it on a defeat ("Derrotado por").
func defeated_by() -> StringName:
	var enemy: StringName = last_hurt.get("enemy", &"")
	var name_key: StringName = &""
	if enemy != &"" and horde.def(enemy) != null:
		name_key = horde.def(enemy).name_key
	return DefeatCause.text_key(last_hurt, name_key)


## The run's entry for the log (RunLog): the RESULT line, the gifts taken, the device, Omegas, dodges, what hurt last
## and (version 3) the hero, the Mastery the run gave (gain, from mastery_gain), the Gifts and the ultimate.
func run_entry(outcome: String, gain: Dictionary) -> Dictionary:
	var gifts: Array = []
	for id in gifts_taken:
		gifts.append({"id": String(id), "level": boons.level(id), "rarity": Boon.Rarity.keys()[boons.rarity(id)].to_lower()})
	var device := "bot" if bot else RunLog.device(Controls.seen_keys, Controls.seen_pad)
	var extra := {"outcome": outcome, "when": Time.get_datetime_string_from_system(), "gifts": gifts,
		"device": device, "omegas": omegas, "dodges": dodges,
		"last_hurt": {"attack": String(last_hurt.get("attack", &"")), "enemy": String(last_hurt.get("enemy", &""))},
		"defeated_by": String(defeated_by()) if outcome == "death" else "", "source": RunLog.source(bot != null)}
	var by := gain.duplicate()
	by.erase("total")
	var xp_now := int(SaveData.hero(Save.data, String(hero.id)).mastery_xp)
	extra.merge({"hero": String(hero.id), "xp": int(gain.get("total", 0)), "xp_by": by,
		"mastery_level": hero.mastery.level_of(xp_now + int(gain.get("total", 0))),
		"talents": talents.map(func(id: StringName) -> String: return String(id)), "ultimate": ultimate})
	extra.merge(room_tally.run_fields())
	if watchdog:
		extra["watch"] = watchdog.samples
	return RunLog.entry(result(), extra)


## Logs the run once, when it ends (victory, death, or quit when left before either). Written to RunLog.PATH for a
## person's run with a save (never with --nosave nor for the bot); --runlog=file writes any run there (QA samples;
## plain --runlog: to RunLog.PATH).
func log_run(outcome: String) -> void:
	if _logged or not is_instance_valid(player):
		return
	_logged = true
	var gain := mastery_gain(outcome, Save.data)
	var e := run_entry(outcome, gain)
	# the Mastery is kept by a death too (D-57); never for the test robot (unless --mastery) nor without a save,
	# and the end screen only shows XP that is really kept (QA T5, Q-T5-2)
	var kept := Save.enabled and (bot == null or Dev.has("mastery"))
	mastery_report = {"gain": gain, "xp_before": int(SaveData.hero(Save.data, String(hero.id)).mastery_xp)} if kept else {}
	if kept:
		award_mastery(gain, outcome, Save.data)
		Save.write()
	if Dev.has("runlog"):
		RunLog.append(RunLog.PATH if Dev.arg("runlog") == "1" else Dev.arg("runlog"), e)
	elif Save.enabled and bot == null:
		RunLog.append(RunLog.PATH, e)
	run_logged.emit(outcome, e)


## The hero's Gifts for this descent (E2a): the loadout saved in heroes.<id>.equipped, kept only where it is valid at
## the Mastery level (Talents.sanitized), with the ultimate chosen if unlocked; or --talents=a,b (any Gift, as at the
## top level, for tests). The test robot without --talents takes none. Their plain numbers (life, Magia, reach) count
## from the first room; with none equipped nothing changes.
func _equip_talents() -> void:
	var book := hero.talents()
	var ids: Array[StringName] = []
	if Dev.has("talents"):
		var top := hero.mastery.max_level
		var asked := Array(Dev.arg("talents").split(",", false))
		ids = book.sanitized(asked, top, hero.mastery.devotion(top))
		_warn_dropped(book, asked, ids, top)
	elif bot == null:
		var block := SaveData.hero(Save.data, String(hero.id))
		var level := hero.mastery.level_of(int(block.mastery_xp))
		ids = book.sanitized(block.equipped, level, hero.mastery.devotion(level))
		if Dev.has("hero-equip"):
			_warn_dropped(book, block.equipped, ids, level)
		# the one chosen or, never chosen (T5), the first the level unlocks, kept in the save as the choice
		var ult := hero.ult_for(StringName(block.ultimate), level)
		ultimate = String(ult.id) if ult != null else ""
		if ultimate != "" and block.ultimate != ultimate and Save.enabled:
			block.ultimate = ultimate
			Save.write()
	elif Dev.has("hero-equip"):
		push_warning("--hero-equip: the robot takes no Gifts from the save; use --talents=a,b")
	if Dev.has("ultimate"):
		# --ultimate=cleave|vortex: that one, whatever the Mastery (tests, captures, the robot)
		var chosen := hero.ultimate(StringName(Dev.arg("ultimate")))
		ultimate = String(chosen.id) if chosen != null else ""
		if chosen == null:
			push_warning("--ultimate: no ultimate %s" % Dev.arg("ultimate"))
	talents = ids
	if not ids.is_empty():
		_apply_talents(ids)


## The Juramentos of this descent (E6): --juramentos=id:rank,... (any, for tests and the robot), else a person's
## saved choice once Morvath was sealed once (never without a save: --nosave, the tests); none for the robot. Their numbers on the enemies' life go to the horde
## now; the rest is read where it acts (Rooms, Boss, _take).
func _swear_juramentos() -> void:
	var chosen := {}
	if Dev.has("juramentos"):
		chosen = Juramentos.parse(Dev.arg("juramentos"))
	elif bot == null and Save.enabled and Juramentos.unlocked(Save.data):
		chosen = Juramentos.block(Save.data).get("ranks", {})
	juramentos = Juramentos.new(Juramentos.load_catalog(), chosen)
	horde.vow_hp = juramentos.scale(&"enemy_hp_pct")


## Says which Gifts asked for by --talents or --hero-equip were left out and why (Talents.why_dropped).
func _warn_dropped(book: Talents, asked: Array, kept: Array[StringName], level: int) -> void:
	var why := book.why_dropped(asked, kept, level, hero.mastery.devotion(level))
	for id: StringName in why:
		push_warning("Gift %s not equipped at Mastery %d: %s" % [id, level, Talents.Problem.keys()[why[id]]])


## Equips these Gifts now, as if the descent began with them (tests): their numbers and their rules (HeroGifts).
func equip_talents(ids: Array[StringName]) -> void:
	talents = ids
	_apply_talents(ids)
	hero_gifts.equip()


func _apply_talents(ids: Array[StringName]) -> void:
	boons.equip_talents(hero.talents().defs(ids))
	player.max_hp = hero.max_hp + boons.stat(&"max_hp") + life_bonus
	player.hp = player.max_hp
	player.magick.max_value = hero.magick_max + boons.stat(&"magick_max")
	player.magick.value = player.magick.max_value


## The Mastery XP this run gives (MasteryCurve.run_xp), by source and in total: fight rooms and guardians won,
## Morvath's highest phase reached, the sealing, and the first times against what the save data has seen (Blessings
## offered, Elos formed, the first guardian, the first victory).
func mastery_gain(outcome: String, data: Dictionary) -> Dictionary:
	var block := SaveData.hero(data, String(hero.id))
	var firsts: Dictionary = block.firsts
	var codex: Dictionary = data.get("codex", {})
	var won: Array[RunMap.Kind] = rooms.won if rooms else ([] as Array[RunMap.Kind])
	var guardians := won.count(RunMap.Kind.MINIBOSS)
	var victory := outcome == "victory"
	var seen: Dictionary = codex.get("boons", {})
	var formed: Dictionary = codex.get("elos", {})
	var known: Dictionary = codex.get("psalms", {})
	return hero.mastery.run_xp({
		"rooms": won.count(RunMap.Kind.COMBAT), "guardians": guardians, "phase": int(boss_stats.get("max_phase", 0)),
		"victory": victory,
		"new_boons": seen_boons.keys().filter(func(id: StringName) -> bool: return not seen.has(String(id))).size(),
		"new_elos": elos_formed.keys().filter(func(id: StringName) -> bool: return not formed.has(String(id))).size(),
		"new_psalms": psalms.seen.keys().filter(func(id: StringName) -> bool: return not known.has(String(id))).size(),
		"first_guardian": guardians > 0 and int(firsts.get("guardian", 0)) == 0,
		"first_victory": victory and int(firsts.get("victory", 0)) == 0,
		"weight": juramentos.weight() if juramentos else 0,
	})


## Adds a run's Mastery to save data: the hero's XP (kept on a death too), the Gifts its level unlocks, the first
## times and the Codex (Blessings seen, Elos formed).
func award_mastery(gain: Dictionary, outcome: String, data: Dictionary) -> void:
	var block := SaveData.hero(data, String(hero.id))
	block.mastery_xp = int(block.mastery_xp) + int(gain.get("total", 0))
	var level := hero.mastery.level_of(block.mastery_xp)
	block.unlocked = hero.talents().unlocked(level).map(func(t: TalentDef) -> String: return String(t.id))
	for id: StringName in seen_boons:
		SaveData.codex_add(data, "boons", String(id), "seen")
	for id: StringName in elos_formed:
		SaveData.codex_add(data, "elos", String(id), "formed")
	# the Psalms (E4): seen on a card (found: the Codex shows them from then on) and taken
	for id: StringName in psalms.seen:
		SaveData.codex_add(data, "psalms", String(id), "seen")
	for p in psalms.taken:
		SaveData.codex_add(data, "psalms", String(p.id), "taken")
	codex_run(outcome, data)
	var guardians := rooms.won.count(RunMap.Kind.MINIBOSS) if rooms else 0
	if guardians > 0:
		block.firsts["guardian"] = int(block.firsts.get("guardian", 0)) + guardians
	if outcome == "victory":
		block.firsts["victory"] = int(block.firsts.get("victory", 0)) + 1
		if juramentos:
			Juramentos.record_win(data, juramentos.weight())


## E4-05: the enemies defeated (an elite counts for its common kind, and as an elite), Morvath met (the highest phase
## reached, defeated on a victory) and the arenas entered, into save data's Codex.
func codex_run(outcome: String, data: Dictionary) -> void:
	for id: StringName in defeated:
		var kind := String(id).trim_suffix("_elite")
		SaveData.codex_add(data, "enemies", kind, "defeated", int(defeated[id]))
		if kind != String(id):
			SaveData.codex_add(data, "enemies", kind, "elite", int(defeated[id]))
	if not boss_stats.is_empty():
		var chief := String(rooms.stage.boss) if rooms else "morvath"
		SaveData.codex_add(data, "enemies", chief, "met")
		SaveData.codex_max(data, "enemies", chief, "phase", int(boss_stats.get("max_phase", 1)))
		if outcome == "victory":
			SaveData.codex_add(data, "enemies", chief, "defeated")
	for id: StringName in arenas_seen:
		SaveData.codex_add(data, "arenas", String(id), "entered", int(arenas_seen[id]))


## One step of the run, timed: step_ms (smoothed, read at any moment) and step_timer (only frames with enemies
## standing, RESULT step_ms_avg and step_ms_peak; BUG-012).
func _timed_step(dt: float) -> void:
	var busy := horde.count() > 0
	var t0 := Time.get_ticks_usec()
	_step(dt)
	var ms := (Time.get_ticks_usec() - t0) / 1000.0
	step_ms = lerpf(step_ms, ms, 0.05)
	step_timer.add(ms, busy)
	if busy and ms > TRACE_SLOW and _tracing:
		# dev (DT-008): which steps are slow, and where in the step the time went
		print("SLOW_STEP %.2f ms at %.1f s, room %d, %d standing: %s" % [ms, time, rooms.depth() if rooms else 0, horde.count(), _laps])


## Dev (--trace-steps, DT-008): a step slower than this many ms prints where its time went.
const TRACE_SLOW := 4.0
var _tracing := Dev.has("trace-steps")
var _laps := {}
var _lap_t := 0


## Dev: the time since the last lap, kept under `what` (&"": starts the step).
func _lap(what: StringName) -> void:
	if not _tracing:
		return
	var now := Time.get_ticks_usec()
	if what == &"":
		_laps.clear()
	else:
		_laps[what] = snappedf((now - _lap_t) / 1000.0, 0.01)
	_lap_t = now


## A line of numbers about the run, for smoke tests and tuning.
func result() -> Dictionary:
	return {"time": snappedf(time, 0.1), "hp": int(player.hp), "level": level, "room": rooms.depth() if rooms else 0, "gold": rooms.gold if rooms else 0, "kills": kills, "spawned": director.spawned, "best_combo": combat.best_combo,
		"enemies": horde.count(), "max_alive": max_alive, "boss_at": snappedf(boss_at, 0.1), "mode": Mode.keys()[mode], "boss_hp": int(boss.e.hp) if boss and boss.e else -1, "phase": boss.phase if boss else 0,
		"boons": boons.owned().size(), "damage": int(combat.damage_dealt), "step_ms": snappedf(step_ms, 0.01),
		"step_ms_avg": snappedf(step_timer.average(), 0.01), "step_ms_peak": snappedf(step_timer.peak, 0.01), "fps": Engine.get_frames_per_second(),
		"boss": boss_stats, "bot": bot.stats() if bot else {}, "rooms": room_tally.rooms(time), "hp_at_boss": room_tally.hp_at_boss,
		"arena": String(arena.id) if arena else "", "stuck": horde.stuck_count(), "stuck_by": horde.stuck_by,
		"shots_blocked": projectiles.blocked, "flinches": horde.flinches, "interrupts": horde.interrupts,
		"windups": horde.windup_report(), "shot_flight": projectiles.flight_report(),
		"omega_charges_started": player.charges_started, "omega_charges_cancelled": player.charges_cancelled(), "boons_at_boss": room_tally.boons_at_boss, "shop": room_tally.shop,
		"fountain_used": room_tally.fountain_used, "ult": ults.stats(), "dealt_by": horde.dealt.report(), "elos": elos_formed.size(),
		"psalms": psalms.ids(), "events": room_tally.events.duplicate(true), "map": rooms.map.summary() if rooms else {},
		"trial": {"active": String(rooms.trials.active.curse.id) if rooms and rooms.trials.active else "",
			"left": rooms.trials.left if rooms else 0, "won": rooms.trials.won.size() if rooms else 0},
		"juramentos": juramentos.to_dict() if juramentos else {}, "weight": juramentos.weight() if juramentos else 0}


## The RESULT line the smoke runs and captures print: "RESULT " and result() as JSON (E1a-5, B-c: printed as a
## Dictionary its StringName keys came out as &"scythe", and no tool could read the line).
func result_line() -> String:
	return "RESULT " + JSON.stringify(result())


## --smoke=seconds: plays without a screen for that long (or until the run ends), prints RESULT and quits.
func _smoke() -> void:
	var limit := Dev.num("smoke", 60.0)
	var t := 0.0
	while t < limit and mode != Mode.OVER and not (mode == Mode.ENDING and boss == null and _screen != null):
		await get_tree().process_frame
		t += get_process_delta_time()
	print(result_line())
	get_tree().quit()
