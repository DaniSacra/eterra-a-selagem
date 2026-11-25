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
## Fatia 2: an Encanto's choice opens (options: Array[EnchantDef], up to three); a screen that listens takes the
## choice with take_enchant (none listening: the EnchantChoice opens). taken after it is taken.
signal enchant_offered(options: Array)
signal enchant_taken(enchant: EnchantDef)
## Fatia 2: a tool of the Forjador found in this descent (kept in the save when the descent ends, as the materials).
signal tool_found(tool: StringName)
signal psalm_offered(psalm: PsalmDef, first: bool)
## A Psalm was taken: first when it was never taken before in the save (its short line, PsalmDef.line_key).
signal psalm_taken(psalm: PsalmDef, first: bool)

## Magia a kill gives back (Player.magick).
const MAGICK_PER_KILL := 1.0
## The Encantos' offers are drawn on dice of the room (the run's seed salted with this).
const ENCHANT_SALT := 5813
const MAGICK_PER_ELITE := 40.0
const WAVES := "res://data/waves/catacombs.tres"
## The Supremo heals this share of the max life as it starts (Q6).
const ULT_HEAL := 0.10
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
var c5_marks: C5Marks
var c1e_marks: C1eMarks
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
## Rejogabilidade, Fatia 1 (docs/design/rejogabilidade/sistemas.md): the materials this descent picked up (banked into
## the save once when it ends, log_run: materials_banked is what went in), the Forja's Temperar carried (forge_temper,
## its ranks summed in boons.stat), the meetings with the angels (encounters) and the Gifts open at the start.
var materials := MaterialPurse.new()
var materials_banked := {}
## Ofícios, Roteiro A: the descent's part (OficiosRun: the pick, the head wanted, what was found and extracted), its
## numbers (OficiosDef) and what went into the save at the end (Oficios.bank).
var oficios: OficiosRun
var oficios_def: OficiosDef
var oficios_banked := {}
## Fatia 2 (sistemas.md 3.6): the Encantos that may come in this descent (learned at the Forja: Enchants.learned), the
## choice open now, the Forjador's tools found in it (tools_banked: those log_run kept) and the Refinar carried (ids).
var enchant_pool: Array[EnchantDef] = []
## Fatia 3: the Despertar awake ("" none), the Discernimento bought (Discern) and the rerolls left in this descent.
var forge_awaken := ""
var discern := 0
var rerolls_left := 0
## The angel whose cards are on the choice screen (Encounters.choose; null: none), for a reroll of the same family.
var choice_angel: AngelDef = null
## BC-4: the way back to the pair the angel's cards came from (EncounterScreen sets it), and the angels whose words
## were heard in each room (room id + angel), so going back or drawing again never repeats them.
var choice_back := Callable()
var intro_seen: Dictionary = {}
signal rerolled
var enchant_options: Array[EnchantDef] = []
var tools_found: Array[StringName] = []
var tools_banked: Array[StringName] = []
var forge_refine: Array[String] = []
var forge_temper := 0
## How many nodes of A Videira this descent carries (the RESULT).
var vine_nodes := 0
var talents_opened := 0
var encounters: Encounters
## The hero played (DT-013) and, for this descent, the Gifts equipped (ids) and the ultimate chosen (id or "").
var hero: HeroDef = hero_option()
## The Maga's kit in play (--hero=maga; null for the Warrior): Selos, Explosão, Círculo, Suspensão, Ressonância.
var arcane: Arcane
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
## AT-Q1: the things that break in this room (BreakFloor, under the arena), or null.
var breaks: BreakFloor
## What the fight leaves on this room's floor (bone dust, cracks), under the arena.
var marks: BattleMarks
## Life gained from hearts (kept when gifts change the life bar).
var life_bonus := 0.0
## Coragem (Courage): the pomegranates still owed to the descent; the first Blessing taken grows (a pomegranate needs one held).
var courage_poms := 0
var courage_stacks := 0
## SW-O4: this descent is the guided first one (FirstDescent.active, decided once in _ready), and whether Morvath's short
## fight ended it (a first descent that ends that way is neither a win nor a record).
var first_run := false
var first_won := false
var boss: Boss
## The boss fight in numbers (Boss.stats; kept after he falls), for RESULT.
var boss_stats := {}
var fx: Fx
var hud: Hud
var ui: CanvasLayer
## Close dodges rewarded this run (C1e).
var dodge_closes := 0
var _feel_panel: FeelPanel
var camera: Camera3D
## The game camera and the world's air (shared with the hub, HUB-B1).
var cam: CamRig
var air: WorldAir
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
## Times each button was used and blows taken with no dodge charge (RunLog.USE_KEYS), for the run's log.
var uses := {}
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
var _rng := RandomNumberGenerator.new()
var _found: Array[Enemy] = []
## While the shaders' warm-up ends before the first room (P1-1): the run waits.
var _warming := false


## "Preparando as catacumbas" and three diamonds that light in turn, over the warm-up's black screen (P1-1; the
## words are the ui-ux-designer's to restyle).
func _preparing_note() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 101  # (over the Warmup's black, layer 100)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override(&"separation", 14)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var words := UiKit.label(T.t(&"warmup_preparing"), UiKit.PALE, 22)
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(words)
	box.add_child(PreparingMark.new())
	layer.add_child(box)
	add_child(layer)
	return layer


## The indicator under the words: three old-gold diamonds lighting one after the other, in real time.
class PreparingMark extends Control:
	const SIDE := 9.0
	const GAP := 26.0
	const PERIOD := 1.2

	func _init() -> void:
		custom_minimum_size = Vector2(GAP * 3.0, SIDE * 2.5)
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var t := fmod(Time.get_ticks_msec() / 1000.0, PERIOD) / PERIOD
		for i in 3:
			var lit := 0.25 + 0.75 * maxf(0.0, 1.0 - absf(fposmod(t * 3.0 - i, 3.0) - 0.5) * 1.5)
			var c := Vector2(GAP * (i + 0.5), size.y * 0.5)
			var d := PackedVector2Array([c + Vector2(0, -SIDE), c + Vector2(SIDE, 0), c + Vector2(0, SIDE), c + Vector2(-SIDE, 0)])
			draw_colored_polygon(d, Color(UiKit.OLD_GOLD, lit))


func _ready() -> void:
	# the click or key that started the run (the title's Iniciar, "Descer de novo") is no swing (E1c, bug 1)
	Controls.clear_presses()
	Input.joy_connection_changed.connect(_on_pad_connection)  # C20: an unplugged controller pauses (auto_pause)
	Dev.seed_rng(_rng, 1)
	fast = Dev.num("fast", 1.0)
	_build_world()
	_build_ui()
	first_run = FirstDescent.active(Save.data, FirstDescent.flags_now(Save.enabled)) and not Dev.has("horde") and FirstDescentDef.live() != null
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
	c5_marks = C5Marks.new()
	c5_marks.horde = horde
	add_child(c5_marks)
	c1e_marks = C1eMarks.new()
	c1e_marks.horde = horde
	c1e_marks.ground = ground
	add_child(c1e_marks)
	horde.projectiles = projectiles
	# shooters only wind up on the screen (cycle C12): where a floor point shows, at chest height, in the frame the
	# camera settles on for the paladin where he stands (the simulation's own, not the drawn camera's lag). The rule
	# reads the far camera's frame whatever the options say (LR-02: the near one is no hidden difficulty setting);
	# the camera in use is for the run's log and the edge marks of shooters winding up off it (Horde.seen)
	horde.view = func(p: Vector2) -> Vector2:
		return _screen_of(p, Feel.live().cam_distance, true)
	horde.seen = func(p: Vector2) -> Vector2:
		return _screen_of(p, CamRig.distance(), false)
	combat.swung.connect(func(_n: ComboNode, struck: int) -> void:
		if struck > 0:
			room_tally.touch(time))

	player.struck.connect(combat.strike)
	# BO-2: a Blessing of a button sets its skill off when that button's move lands (after the blow, so it burns first)
	player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void:
		var which := Skills.trigger_of(node)
		if which >= 0:
			skills.trigger(which as SkillDef.Trigger))
	player.ult_landed.connect(func(_dir: Vector2) -> void: skills.trigger(SkillDef.Trigger.ULT))
	player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void:
		if node.has_tag(Combat.OMEGA_TAG):
			omegas += 1)
	player.cast_released.connect(func(_at: Vector2, omega: bool) -> void:
		if omega:
			omegas += 1)
	player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void: _count_slot(node))
	player.ult_started.connect(func(_dir: Vector2) -> void:
		player.heal(player.max_hp * ULT_HEAL)  # the Supremo gives back a tenth of the life as it starts
		_use(&"shift"))
	player.glinted.connect(combat.glint)
	player.cast_released.connect(combat.cast)
	# was_hurt is emitted before died: the blow is counted before the run ends (BUG-014)
	player.was_hurt.connect(_on_was_hurt)
	player.died.connect(_on_player_died)
	player.dodged.connect(_on_dodged)
	player.dodge_close.connect(_on_dodge_close)
	player.dodge_blocked.connect(room_tally.dodge_blocked)  # AT-CA2
	Controls.forget_devices()
	player.shield_broke.connect(_on_shield_broke)
	player.ward_taken.connect(horde.ward_taken)
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
	# the Gifts and the Forja before the first room: it records the life he walks in with
	_equip_forge()
	_equip_vine()
	_start_oficios()
	_equip_talents()
	encounters = Encounters.new(self)
	enchant_pool = Enchants.learned(Enchants.load_catalog(), Save.data if bot == null else {}, String(hero.id))
	if Dev.has("inscribed"):
		# (tests and the robot: these Encantos learned too, Fatia 3)
		for e in Enchants.load_catalog():
			if not enchant_pool.has(e) and Dev.arg("inscribed").split(",", false).has(String(e.id)):
				enchant_pool.append(e)
	ults.equip(hero.ultimate(StringName(ultimate)))
	boons.ult_open = ults.def != null  # BO-2: the Blessing of Shift is in the draw only with the ultimate open
	boons.set_hero_moves(load(hero.combos) as ComboTree if hero.combos != "" else null)  # no dead Blessing for the Maga
	if Dev.has("ult-full"):
		ults.charge.fill()  # dev: the ultimate starts full (captures, --start=boss)
	hero_gifts = HeroGifts.new(self)
	if hero.arcane != null:
		arcane = Arcane.new()
		add_child(arcane)
		arcane.setup(self)
		combat.arcane = arcane
	_swear_juramentos()
	_start_courage()
	psalms = Psalms.new(Psalms.load_catalog())
	psalms.circle = hero.circle
	psalm_play = PsalmPlay.new(self, psalms)
	psalm_cards = bot != null or Dev.has("autopick") or screen_shows_psalms()
	# P1-1: what the title did not finish of the shaders' warm-up (the player left it early), under a black screen
	# with a word, before the first room (Warmup.reached keeps where it got; null without a screen: the same RESULT)
	var warm := Warmup.start(self, true)
	if warm != null:
		_warming = true
		var note := _preparing_note()
		await warm.done
		note.queue_free()
		_warming = false
		Controls.clear_presses()
		if not is_inside_tree():
			return
	if not Dev.has("horde"):
		rooms = Rooms.new()
		add_child(rooms)
		rooms.setup(self, _rng)
		# (with a screen the first room is built on black over frames: what follows waits for it, as before)
		if Dev.has("start") and Dev.arg("start") in ROOM_STARTS:
			await rooms.start_at(ROOM_STARTS[Dev.arg("start")])
		else:
			await rooms.start()
		if not is_inside_tree():
			return
		ArrivalScene.dev(self)  # (--arrival: the arrival scene over this room, to see it alone; SW-O1)
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
	if Dev.has("enchant-choice"):
		# dev, for captures: the Encanto's choice open at once (PT-10)
		var scr := EnchantChoice.new()
		open_screen.call_deferred(scr)
		scr.open_enchants.call_deferred(Enchants.load_catalog().slice(0, 3))
	if Dev.has("encounter") and encounters != null:
		encounters.dev_open.call_deferred(Dev.arg("encounter"))
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
	# the world's air (WorldAir, shared with the hub: HUB-B1), then the room
	air = WorldAir.build(self)
	arena = Arena.new()
	add_child(arena)
	if Dev.has("horde") or Rooms.hold_frames() <= 0:
		arena.build()
	else:
		arena.build_bare()  # (QA P1-1: the descent builds its first room on black at once; this one is never seen)
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
	add_child(camera)
	camera.make_current()
	# the game camera (CamRig, shared with the hub: HUB-B1)
	cam = CamRig.new(camera, arena, player)
	cam.on_placed = _cam_placed
	cam.place(Vector3.ZERO, 1.0)


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
	ui.visible = not Dev.has("no-hud")  # promotional captures (identidade_c1v.md section 5)


func _exit_tree() -> void:
	# left in the middle (to the title, a new descent, the window closed): the run is logged as left
	log_run("quit")
	if _cam_trace != null and _cam_trace.frames > 0:
		_trace_cam_cut(true)
	Controls.virtual = null
	Engine.time_scale = 1.0
	if boss != null:
		Game.unhook(boss)


## Drops every connection on the signals of `obj` (BUG-108: Boss is RefCounted, and a Callable connected to it that
## holds it back, a test's lambda reading boss._clock, kept both alive past the end of the game).
static func unhook(obj: Object) -> void:
	for sig in obj.get_signal_list():
		for c: Dictionary in obj.get_signal_connection_list(sig.name):
			obj.disconnect(sig.name, c.callable)


func _process(delta: float) -> void:
	if _warming:
		return  # (the shaders' warm-up before the first room: nothing to step yet)
	delta = _frame_delta(delta)
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
		# (a new room held black while it is first drawn does not step: Rooms.holding, QA P1-1)
		if world_dt > 0.0 and not (rooms != null and rooms.holding()):
			_timed_step(minf(world_dt, 0.05))
			stepped = true
	horde.render(world_dt)
	orbs.render()
	if mode == Mode.PLAY and Controls.pressed(&"pause"):
		_open_pause()
	if OS.is_debug_build() and Controls.pressed(&"feel_panel"):
		_toggle_feel_panel()
	if mode == Mode.PLAY and Controls.pressed(&"stun_toggle"):
		# F8: the experiment of the stuns (StunRule), said on the screen
		StunRule.step()
		hud.show_notice(T.t(StunRule.TEXT[StunRule.live]))
	if mode == Mode.PLAY and Controls.pressed(&"look_toggle"):
		# F7 flips the visual style and keeps it in the options, as the options screen does (DT-RS2)
		Save.choose_look(VisualProfile.Look.CLASSIC if VisualProfile.stylized() else VisualProfile.Look.STYLIZED)
		arena.restyle()
	_hurt_tint.step(fx.real_dt, Feel.live())
	var low := 1.0 - clampf(player.hp / player.max_hp / 0.3, 0.0, 1.0)
	if mode != Mode.PLAY and mode != Mode.ENDING and not Dev.has("lab"):
		fx.end_slow()
	_screen_fx.set_shader_parameter(&"split", fx.split)
	_screen_fx.set_shader_parameter(&"radial", fx.radial)
	_screen_fx.set_shader_parameter(&"impact", 1.0 if fx.frame_left > 0.0 else 0.0)
	_screen_fx.set_shader_parameter(&"flash", fx.flash_level())
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
	horde.dodge_end = player.last_dodge_end
	horde.dodge_age = player.dodge_age
	horde.target_safe = player.invulnerable()
	horde.step(dt)
	_lap(&"horde")
	if boss:
		boss.step(dt)
	_lap(&"boss")
	max_alive = maxi(max_alive, horde.count())
	projectiles.step(dt)
	if is_instance_valid(breaks):
		breaks.step(dt)
	_lap(&"shots")
	ground.step(dt)
	c5_marks.step()
	c1e_marks.step()
	_lap(&"ground")
	combat.step(dt)
	hero_gifts.step(dt)
	if arcane != null:
		arcane.step(dt)
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
	fx.burst(&"shadow", Vector3(at.x, 1.0, at.y))  # (no column: vfx_pass_spec.md 5.4, V-15)
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


## wait: when valid (Rooms on a screen, QA P1-1), the room is built over several frames, awaiting it between the
## steps (Arena.build_async); without, at once (the same room either way).
func rebuild_room(layout: RoomLayout, exits: int, seed_: int, wait := Callable()) -> void:
	_trace_cam_cut()
	ground.clear()
	ults.clear()
	combat.apogee.clear()  # (the Apogeu's books go with the room)
	if arcane != null:
		arcane.clear()
	psalm_play.clear()
	projectiles.clear_hostile()
	horde.clear_crowd()
	if _fountain != null:
		_fountain.queue_free()
		_fountain = null
	var built := Arena.new()
	if wait.is_valid():
		# over the black frames the old room stays the one everybody reads (the camera follows it), the new one
		# hidden until it is whole
		built.visible = false
		add_child(built)
		await built.build_async(layout, exits, seed_, wait)
		if not is_inside_tree():
			return
		built.visible = true
		arena.visible = false
		_free_later(arena, wait)  # (freeing a whole room takes its own black frame)
	else:
		add_child(built)
		built.build(layout, exits, seed_)
		arena.queue_free()
	arena = built
	breaks = BreakFloor.make(self, layout)  # AT-Q1: the room's vases and crates (under the arena, gone with it)
	marks = BattleMarks.make(self)
	horde.arena = arena
	player.arena = arena
	cam.arena = arena
	var place := arena.id if arena.id != &"" else &"hall"
	arenas_seen[place] = int(arenas_seen.get(place, 0)) + 1


func _free_later(old: Node, wait: Callable) -> void:
	await wait.call()
	if is_instance_valid(old):
		old.queue_free()


## Gifts by a cleared room or the shop: three cards drawn with these rarity chances (Boon.RARITY_CHANCE; the stage's
## own in the rooms), with the stage's chances of an Elo and of a trade, and of a Psalm (psalm_chance < 0: the stage's
## for a room, StageDef.psalm_chance; the guardian passes its own). meeting: a room's Blessing, which comes by two
## angels (Rejogabilidade, Fatia 1: Encounters; --no-angels draws as before).
func open_boon_choice(chances: Array[float] = Boon.RARITY_CHANCE, psalm_chance := -1.0, meeting := false) -> void:
	choice_angel = null
	choice_back = Callable()
	_no_reroll = false
	_last_chances = chances
	_last_psalm = psalm_chance
	if meeting and encounters != null and encounters.on():
		encounters.open(chances, psalm_chance)
		return
	_open_choice(_draw_cards(chances, psalm_chance))


## A Psalm's door (Fatia 2, sistemas.md 1.7): three Blessings of every family as the shop's, the first card a Psalm
## that may come now (the door turned into a Blessing when none could: RunMap.settle).
func open_psalm_choice(chances: Array[float] = Boon.RARITY_CHANCE) -> void:
	choice_angel = null
	choice_back = Callable()
	_no_reroll = true
	var cards := _draw_cards(chances, 0.0)
	if psalm_cards and rooms != null:
		var dice := RandomNumberGenerator.new()
		dice.seed = hash([run_seed(), ENCHANT_SALT, rooms.room.id if rooms.room else -1, &"psalm"])
		psalms.fill(cards, dice, 1.0, boons, talents, 1)
	_open_choice(cards)


## Opens the choice screen on these cards (the angel's, Encounters; none: the rest card).
func open_cards(cards: Array[BoonState.Card]) -> void:
	_open_choice(cards)


# ---------- Fatia 2: the Encantos ----------

## The Encantos that may be offered now (none once StageDef.enchant_max are taken): up to Enchants.CHOICES, on dice of
## the room (the same offer whatever came before in the run).
func enchant_offers() -> Array[EnchantDef]:
	var most := rooms.stage.enchant_max if rooms else 2
	if boons.enchants.size() >= most:
		return []
	var dice := RandomNumberGenerator.new()
	var room := rooms.room if rooms else null
	dice.seed = hash([run_seed(), ENCHANT_SALT, room.id if room else -1, room.depth if room else 0, boons.enchants.size()])
	return Enchants.offers(enchant_pool, boons.enchants, talents, dice)


## Opens the Encanto's choice (a door of Encanto, the shop's): the robot and --autopick take the first at once; a person
## sees the screen (enchant_offered; none listening: the EnchantChoice). Nothing to offer: a Blessing.
func open_enchant_choice() -> void:
	enchant_options = enchant_offers()
	if enchant_options.is_empty():
		open_boon_choice(rooms.stage.rarity_chance if rooms else Boon.RARITY_CHANCE)
		return
	if bot != null or Dev.has("autopick"):
		take_enchant(enchant_options[0])
		return
	enchant_offered.emit(enchant_options)
	if enchant_offered.get_connections().is_empty():
		var screen := EnchantChoice.new()
		open_screen(screen)
		screen.open_enchants(enchant_options)
		screen.chosen_enchant.connect(func(e: EnchantDef) -> void:
			close_screen()
			take_enchant(e))


## Takes an Encanto of the choice open now: its numbers count from the next blow.
func take_enchant(e: EnchantDef) -> void:
	if e == null or not enchant_options.has(e) or not boons.take_enchant(e):
		return
	enchant_options = []
	room_tally.event("enchant", time, {"id": String(e.id), "room": rooms.room.depth if rooms and rooms.room else 0})
	fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))
	enchant_taken.emit(e)


## A tool of the Forjador found (once a save: Forge.has_tool; the robot finds it each descent, nothing kept).
func find_tool(tool: StringName) -> void:
	if tools_found.has(tool) or (bot == null and Save.enabled and Forge.has_tool(Save.data, tool, String(hero.id))):
		return
	tools_found.append(tool)
	tool_found.emit(tool)
	hud.show_notice(T.t(StringName("tool_found")), 2.5)


func _draw_cards(chances: Array[float] = Boon.RARITY_CHANCE, psalm_chance := -1.0) -> Array[BoonState.Card]:
	var elo := rooms.stage.elo_chance if rooms else Boon.ELO_CHANCE
	var trade := rooms.stage.trade_chance if rooms else Boon.TRADE_CHANCE
	var cards := boons.draw(_rng, 3, chances, elo, trade)
	fill_psalm(cards, psalm_chance, _rng)
	return cards


var _last_chances: Array[float] = Boon.RARITY_CHANCE
var _last_psalm := -1.0
## The Blessings' screen open now may be drawn again (_open_choice; never a Psalm's door's, _no_reroll).
var _rerollable := false
var _no_reroll := false


## Discernimento I (Fatia 3): the choice of Blessings on screen may be drawn again once a descent (a fresh draw of the
## same kind: the chosen angel's family, else every family). For the UI: can_reroll(), reroll_choice(), rerolls_left,
## signal rerolled. Never a Psalm's door's guaranteed Psalm, a growth (romã) or an Encanto's choice.
func can_reroll() -> bool:
	return rerolls_left > 0 and mode == Mode.CHOICE and _rerollable and _screen != null \
		and not offer_cards.any(func(c: BoonState.Card) -> bool: return c.grow)


## BC-1 and BC-4: the angel who brought the cards on the choice screen, with its words first the first time in a room
## (never for the robot nor --autopick, which do not wait).
func _present_angel(choice: BoonChoice) -> void:
	if choice_angel == null:
		return
	var key := "%d:%s" % [rooms.room.id if rooms != null and rooms.room != null else -1, choice_angel.id]
	var hear := not (bot != null or Dev.has("autopick") or intro_seen.has(key))
	intro_seen[key] = true
	choice.by_angel(choice_angel, choice_back, EncounterScreen.held_of(boons, choice_angel) if hear else -1)


func reroll_choice() -> bool:
	if not can_reroll():
		return false
	rerolls_left -= 1
	var cards: Array[BoonState.Card] = []
	if choice_angel != null and encounters != null:
		cards = encounters.reroll_cards(choice_angel)
	else:
		cards = _draw_cards(_last_chances, _last_psalm)
	_close_screen()
	_open_choice(cards)
	rerolled.emit()
	return true


## A Psalm may take a card (Psalms.fill; psalm_chance < 0: the stage's). Psalms only in the descent by rooms (the old
## endless hall, --horde, stays as it was).
func fill_psalm(cards: Array[BoonState.Card], psalm_chance: float, rng: RandomNumberGenerator) -> void:
	if psalm_cards and rooms != null:
		psalms.fill(cards, rng, rooms.stage.psalm_chance if psalm_chance < 0.0 else psalm_chance, boons, talents)


## The seed the run's own dice were drawn from (the map's and the angels' dice salt it: Rooms.MAP_SALT, Encounter.SALT).
func run_seed() -> int:
	return _rng.seed


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
	# (vfx_pass_spec.md 6: light from above is only for what lies to be taken) the Psalm's ring drawn round him
	fx.family_mark(Boon.Family.LUZ, player.pos, 3.5, p.color, 0.8)
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
	if first_run and rooms != null and rooms.first_def != null:
		# SW-O4: Morvath's short fight (the Boss's own fields, when it has them)
		if "last_phase" in boss:
			boss.set("last_phase", rooms.first_def.boss_last_phase)
		if "hp_scale" in boss:
			boss.set("hp_scale", rooms.first_def.boss_hp_scale)
	boss.setup(self, horde.def(id))
	boss.defeated.connect(_on_boss_defeated)
	if first_run:
		_shorten_boss()
	# his music, one layer more per phase (E4-06)
	Music.boss_phase(boss.phase)
	boss.phase_changed.connect(Music.boss_phase)
	if rooms:
		# Prata for each phase reached (Rejogabilidade, Fatia 1)
		rooms.boss_phase(boss.phase)
		boss.phase_changed.connect(rooms.boss_phase)
	boss.moment.connect(func(name: StringName) -> void:
		if name == &"victory":
			_on_boss_falling())


## SW-O4: Morvath of the guided descent: less life (FirstDescentDef.boss_hp_scale) and only the first phase (the Boss's
## `last_phase` and its `tutorial_end`, boss-engineer's: this reads them only if the Boss has them).
func _shorten_boss() -> void:
	var def := rooms.first_def if rooms != null else null
	if def == null or boss == null or boss.e == null:
		return
	if "hp_scale" in boss:
		pass  # (the Boss scales its own life)
	else:
		boss.e.max_hp *= def.boss_hp_scale
		boss.e.hp = boss.e.max_hp
		boss.e.hp_floor *= def.boss_hp_scale
	if "last_phase" in boss:
		boss.set("last_phase", def.boss_last_phase)
	if boss.has_signal(&"tutorial_end"):
		boss.connect(&"tutorial_end", _on_first_end)


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
	_rerollable = not _no_reroll
	_no_reroll = false
	ui.add_child(choice)
	if psalm_card != null and choice.has_method(&"open_cards"):
		choice.call(&"open_cards", offer_cards, boons, self)
		choice.connect(&"card_chosen", choose_card)
	else:
		choice.open(offers, boons, _offer_rarity)
	choice.chosen.connect(_on_chosen)
	_present_angel(choice)
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
	player.max_hp = _base_max_hp() + hp_bonus + life_bonus
	player.heal(hp_bonus - old_hp_bonus)
	if courage_poms > 0:
		courage_poms -= 1
		grow_random()
	# (vfx_pass_spec.md 6 and 5.3: no column over him; the family's own form on the floor, a plain ring for an Elo)
	if Fx.MARK_FORM.has(b.family):
		fx.family_mark(b.family, player.pos, 3.0, b.color(), 0.6)
	else:
		fx.ring(player.pos, 3.0, b.color(), 0.5)
	fx.hero_burst(&"light", Vector3(player.pos.x, 1.2, player.pos.y))


## C1e: the close dodge's reward, a short slow motion with a glint and a chime; nobody is stunned (rule F8).
func _on_dodge_close() -> void:
	var feel := Feel.live()
	fx.slow_mo(feel.close_fraction, feel.close_slow, 0.15, 1.0, 0.0, 0.03)
	fx.ring(player.pos, 1.6, Combat.EMETH, 0.3, 0.1, true)
	Audio.play(&"ward")
	dodge_closes += 1


## Q and E count when their move lands (Skills.trigger_of).
func _count_slot(node: ComboNode) -> void:
	var which := Skills.trigger_of(node)
	if which == SkillDef.Trigger.SHOUT:
		_use(&"q")
	elif which == SkillDef.Trigger.RUSH:
		_use(&"e")


## One more use of a button (RunLog.USE_KEYS).
func _use(key: StringName) -> void:
	uses[String(key)] = int(uses.get(String(key), 0)) + 1


func _on_dodged(dir: Vector2) -> void:
	skills.trigger(SkillDef.Trigger.DODGE)
	dodges += 1
	_use(&"space")
	room_tally.dodge()
	var dps := boons.stat(&"dodge_ember_dps")
	if dps > 0.0 and arcane == null:  # (the Maga's Passo lays its own at both ends: Arcane._on_dodged)
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
	# the light that falls on what is taken, while it has water (vfx_pass_spec.md 6; the column of 1.2 s went)
	_fountain_shaft = RewardShaft.make(_fountain, Vector3(_fountain_at.x, 0, _fountain_at.y), RewardShaft.fountain_tint(), RewardShaft.FOUNTAIN)
	_fountain_shaft.appear(0.0, true)
	hud.show_notice(T.t(&"notice_fountain"), 4.0)
	Audio.play(&"fountain")


func _step_fountain() -> void:
	if _fountain == null or _fountain_used or not player.alive():
		return
	if player.pos.distance_to(_fountain_at) < 2.0 and player.hp < player.max_hp:
		_fountain_used = true
		room_tally.fountain()
		player.heal(player.max_hp * (FOUNTAIN_HEAL + boons.stat(&"fountain_heal")))
		(_fountain.get_node("Light") as OmniLight3D).light_energy = 0.6
		(_fountain.get_node("Spring") as CPUParticles3D).emitting = false
		ArenaKit.fountain_spent(_fountain)
		if is_instance_valid(_fountain_shaft):
			_fountain_shaft.take()
		_fountain_shaft = null
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
	if source == ground or source == projectiles:
		amount *= _boss_weak(source)
	var wide: Variant = source.get(&"last_wide") if source else null
	player.close_any = wide == true
	var hp_before := player.hp
	player.hurt(amount, from)
	if player.hp < hp_before:
		var by := String(source.get(&"last_by")) if source and source.get(&"last_by") != null and String(source.get(&"last_by")) != "" else "melee"
		hurt_by[by] = float(hurt_by.get(by, 0.0)) + hp_before - player.hp
	player.close_any = false
	_blow = {}


## 10A-3: the Fraqueza on Morvath, by half: his own blows (they are his scripts', not the crowd's: Horde._out).
func _boss_weak(source: Object) -> float:
	if boss == null or boss.e == null or boss.e.weak_t <= 0.0 or StringName(source.get(&"last_by")) != &"":
		return 1.0
	return 1.0 - horde.weak_cut * 0.5


## The blow being dealt (_on_hit_player), while Player.hurt runs: its cause and attack id, and its context for the
## run's log (_blow_context).
var _blow := {}
## Life the paladin lost, by the kind of enemy that dealt it (RESULT hurt_by; "melee": a plain blow of the crowd).
var hurt_by := {}


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
	if player.dodge_charges <= 0:
		_use(&"dry_hits")
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
	if player.absorbed_last and boss.def.curse_cut:
		return  # C1d: the Brado took the bolt and its curse with it
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
		fx.elite_surge(e.pos, 2.0)  # (V-15: no column; the old horde's elite falls in a ring of smoke)
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
	if first_run:
		FirstDescent.finish(Save.data, &"death")  # (SW-O4: played once, whatever came of it; the Coragem still counts the death)
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
	if first_run:
		_on_first_end()
		return
	mode = Mode.ENDING
	var at := boss.center if boss else player.pos
	Save.data.runs += 1
	Save.data.wins += 1
	# a run without a save (--nosave) keeps no record, so it can never be a new best (BUG-008)
	var new_best := SaveData.record_win_time(Save.data, time, Save.enabled)
	if rooms:
		rooms.victory()  # the sealing's Prata and Memória, before the run is banked
	Save.write()
	log_run("victory")
	await _play_ending(at)
	_open_end(true, new_best)


## SW-O4: Morvath's short fight is over (Boss.tutorial_end, or his fall if the boss lacks it): the guided descent ends. Not a
## win: no `wins`, no `firsts.victory`, no record time, no Juramento; the descent counts as played (`first` = done), the
## Mastery and the Memória count as in any run. The end screen offers the Santuário only.
func _on_first_end() -> void:
	if mode == Mode.ENDING or mode == Mode.OVER:
		return
	mode = Mode.ENDING
	first_won = true
	Save.data.runs += 1
	FirstDescent.finish(Save.data, &"done")
	Save.write()
	log_run("first")
	Music.play(&"catacombs", Music.WALK)
	# the two lines of the short end (D-O5, a aprovar), one after the other at the foot, while Morvath kneels
	var cap: Variant = hud.get(&"arrival_caption") if hud != null else null
	for key: StringName in [&"first_end_1", &"first_end_2"]:
		if cap != null and cap.has_method(&"show_line"):
			cap.call(&"show_line", key, 2.6)
		await get_tree().create_timer(2.8).timeout
	_open_end(false, false)


## SW-O4: the pause's "Pular a primeira descida" (after its confirmation): the descent is marked skipped (`first` = 2, the
## first milestone opens), the run is left and the Santuário is next.
func skip_first_descent() -> void:
	if not first_run:
		return
	FirstDescent.finish(Save.data, &"skip")
	Save.write()
	SceneGo.to(get_tree(), SceneGo.HUB)


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
	end.open(victory, {"first_done": first_won, "time": time, "level": level if rooms == null else 0, "kills": kills, "best_combo": combat.best_combo, "boons": boons.owned().size(),
		"defeated_by": defeated_by() if not victory and not last_hurt.is_empty() else &"", "mastery": mastery_report}, new_best)
	if first_run or (Save.enabled and int(Save.data.runs) <= 1):
		# a new save's first descent ends in the Santuário, seen for the first time (boot.gd first_scene)
		end.home_only()
	end.retry.connect(func() -> void: SceneGo.to(get_tree(), SceneGo.GAME))
	# Voltar ao Santuário (HUB-01, D-H6): to the hub; everything lasting was saved before the end screen opened
	end.menu.connect(func() -> void: SceneGo.to(get_tree(), SceneGo.HUB))


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


## C20 (GP P2-3): the window lost its focus, or the controller in use was unplugged: the run pauses by itself
## (AutoPause: never the robot, --smoke nor a capture, and only in play). True when it opened the pause.
func auto_pause(why: AutoPause.Why, pad_in_use := true) -> bool:
	if _warming:
		return false
	if not AutoPause.wanted(why, mode == Mode.PLAY and _screen == null, AutoPause.robot_run(bot != null), pad_in_use):
		return false
	_open_pause()
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		auto_pause(AutoPause.Why.FOCUS)


func _on_pad_connection(_device: int, connected: bool) -> void:
	if not connected:
		auto_pause(AutoPause.Why.PAD, Controls.using_pad)


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
	# Eterra Stylized (STY-07): the optional painting filter, only stylized, Forward+ and Alta (PaintPass.wanted)
	PaintPass.attach(camera, GraphicsQuality.current(int(Save.option("quality"))))


func _close_screen() -> void:
	_rerollable = false
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
## The fountain's light while it has water (vfx_pass_spec.md 6, RewardShaft).
var _fountain_shaft: RewardShaft


func column(at: Vector2, color: Color, radius: float, height: float, time: float) -> void:
	var pitch := Dev.num("cam-pitch", Feel.live().cam_pitch)
	var faint := at.distance_to(player.pos) < BEAM_NEAR_HERO \
		or Skills.covers(player.pos, Player.RADIUS, at, radius, height, cam_yaw(), pitch) \
		or Skills.over_boss(boss_enemy(), at, radius, height, cam_yaw(), pitch)
	fx.beam(at, color, radius, height, time, Fx.BEAM_INTENSITY * (Skills.BEAM_OVER_BOSS if faint else 1.0))


## How much closer the camera gets at the end of an Omega's charge (CamRig).
const OMEGA_ZOOM := CamRig.OMEGA_ZOOM
## How far the fixed showcase camera (--showcase) stands from the hall's middle, to frame all of it like the reference.
const SHOWCASE_DISTANCE := CamRig.SHOWCASE_DISTANCE
## The world's air (WorldAir, HUB-B1); these names stay for the tests and the scenery that read them.
const COMPAT_EXPOSURE := WorldAir.COMPAT_EXPOSURE
const COMPAT_AMBIENT := WorldAir.COMPAT_AMBIENT
const SKY := WorldAir.SKY
const AMBIENT := WorldAir.AMBIENT
const AMBIENT_ENERGY := WorldAir.AMBIENT_ENERGY
const EXPOSURE := WorldAir.EXPOSURE
const FOG := WorldAir.FOG
const GLOW_THRESHOLD := WorldAir.GLOW_THRESHOLD
const ADJUST_CONTRAST := WorldAir.ADJUST_CONTRAST
const ADJUST_SATURATION := WorldAir.ADJUST_SATURATION


## A new room: the camera starts framed on the paladin where he walks in, not flying over from where it looked in
## the room before (GP-06; CamRig.snap).
func snap_camera() -> void:
	cam.snap()
	if _cam_trace != null:
		_cam_trace.cut()


## --trace-cam: every point the camera looks at, with where and when (GP-06).
func _cam_placed(p: Vector2) -> void:
	if _cam_trace != null:
		_cam_trace.add(p, {"t": snappedf(time, 0.01), "room": rooms.depth() if rooms else 0, "arena": String(arena.id),
			"hero": player.pos, "mode": Mode.keys()[mode]})


func _follow(delta: float, shake: Vector3) -> void:
	cam.focus = focus
	cam.follow(delta, shake, fx.cam_zoom())


## The floor point the camera looks at, for the point it follows (CamRig.look_at).
func cam_look_at(want: Vector2, distance: float, fov: float) -> Vector2:
	cam.focus = focus
	return cam.look_at(want, distance, fov)


## Where a floor point shows (0 to 1, at chest height) in the frame a camera `distance` meters away settles on for the
## paladin where he stands; as_far: placed as the far camera would be (Horde.view, LR-02), else as the camera in use.
func _screen_of(p: Vector2, distance: float, as_far: bool) -> Vector2:
	var fov := Feel.live().cam_fov
	var size := get_viewport().get_visible_rect().size
	cam.focus = focus
	return CamFrame.screen_of(p, 1.0, cam.look_at(player.pos, distance, fov, as_far), distance, Dev.num("cam-pitch", Feel.live().cam_pitch),
		cam_yaw(), fov, size.x / maxf(size.y, 1.0))


## The floor point the camera looks at in a boss chamber (CamRig.hold_at).
func chamber_look_at(want: Vector2, distance: float, fov: float) -> Vector2:
	cam.focus = focus
	return cam.hold_at(want, distance, fov)


## --shot=file.png: saves what the player would see after --shot-at seconds, then quits. With --shot-on=swing|hit|
## special|omega|spin|boss:<moment> it then waits for the next such swing of the paladin (hit: one that reaches someone;
## special: the special's wave; spin: the combo's spin) and saves --shot-after seconds of real time later, so the swing's effects are on
## screen. Also ritual-left:<n> (n of the ritual's dead standing), hurt, hurt-cursed (a blow taken) and end (the end
## screen), reward (a room won, its reward's light).
func _shot() -> void:
	# Q-T5-7: a boss moment is listened for from the start (_watch_moment): one that came before --shot-at no longer
	# hangs the capture, which then shoots as --shot-at ends (and says so)
	var seen: Array[int] = [0, 0]
	if Dev.arg("shot-on").begins_with("boss:"):
		_watch_moment(StringName(Dev.arg("shot-on").trim_prefix("boss:")), seen)
	await get_tree().create_timer(Dev.num("shot-at", 2.0)).timeout
	if Dev.arg("shot-on").begins_with("boss:"):
		# a moment of the boss fight (Boss.moment): an attack's id, scythe_strike, blades_fire, storm_fire, ritual,
		# cursed, fallen
		var before := seen[0]
		while seen[0] == before:
			if before > 0 and boss == null:
				break
			if before > 0 and seen[1] > 0:
				print("SHOT %s came %d time(s) before --shot-at; shooting now" % [Dev.arg("shot-on"), before])
				break
			seen[1] += 1
			await get_tree().process_frame
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
	elif Dev.arg("shot-on") == "reward":
		# a room won: its reward's light (RewardShaft, vfx_pass_spec.md 6.6), --shot-after seconds of real time later
		while rooms == null or not is_instance_valid(rooms.get(&"_reward_shaft")):
			await get_tree().process_frame
		await get_tree().create_timer(Dev.num("shot-after", 1.2), true, false, true).timeout
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


## Counts every Boss.moment named `name` in seen[0] from the start of the run (Q-T5-7, for _shot).
func _watch_moment(name: StringName, seen: Array[int]) -> void:
	while is_inside_tree():
		if boss == null:
			await get_tree().process_frame
			continue
		var got: StringName = await boss.moment
		if got == name:
			seen[0] += 1


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


## The run's entry for the log (RunLog), by RunReport.entry (DT-106).
func run_entry(outcome: String, gain: Dictionary) -> Dictionary:
	return RunReport.entry(self, outcome, gain)


## Logs the run once, when it ends (victory, death, or quit when left before either), after RunAward.keep put what it
## gave in the save. Written to RunLog.PATH for a person's run with a save (never with --nosave nor for the bot);
## --runlog=file writes any run there (QA samples; plain --runlog: to RunLog.PATH).
func log_run(outcome: String) -> void:
	if _logged or not is_instance_valid(player):
		return
	_logged = true
	var gain := mastery_gain(outcome, Save.data)
	var e := run_entry(outcome, gain)
	RunAward.keep(self, outcome, gain)
	_keep_courage(outcome)
	if not RunLog.worth_keeping(outcome, rooms.won.size(), float(e.get("time", 0.0))):
		pass  # entered the Portal and left: nothing to read in it
	elif Dev.has("runlog"):
		RunLog.append(RunLog.PATH if Dev.arg("runlog") == "1" else Dev.arg("runlog"), e)
	elif Save.enabled and bot == null:
		RunLog.append(RunLog.PATH, e)
	run_logged.emit(outcome, e)


## Coragem after the descent: one more stack for an early death, none past the room or on a win or under a Juramento.
func _keep_courage(outcome: String) -> void:
	if bot != null or not Save.enabled or rooms == null:
		return
	var vowed := juramentos != null and juramentos.weight() > 0
	var next := 0 if vowed else Courage.after(Courage.stacks_of(Save.data, String(hero.id)), outcome, rooms.depth())
	Courage.set_stacks(Save.data, String(hero.id), next)
	Save.write()


## Whether a run's materials go into the save (RunAward.banks_materials).
static func banks_materials(save_enabled: bool, robot: bool, keep: bool) -> bool:
	return RunAward.banks_materials(save_enabled, robot, keep)


## The hero of this run: --hero=warrior|maga when given, else the one picked at the Portal (save "hero", only a person's
## save: the robot and --nosave runs play the Warrior), else the Warrior.
static func hero_option() -> HeroDef:
	var id := Dev.arg("hero") if Dev.has("hero") else SaveData.picked_hero(Save.data) if Save.enabled and not Dev.has("bot") else SaveData.FIRST_HERO
	return HeroDef.maga() if id == "maga" else HeroDef.warrior()


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
		# only the Gifts opened with Memória (Rejogabilidade, Fatia 1; the free ones always)
		var opened := Talents.opened_of(block)
		ids = book.sanitized(block.equipped, level, hero.mastery.devotion(level), opened)
		talents_opened = book.open_ones(level, opened).size()
		if Dev.has("hero-equip"):
			_warn_dropped(book, block.equipped, ids, level)
		# the fixed ultimate of the hero's weapon, once its Mastery level is reached (redesign A.3; no choice, nothing saved)
		var ult := hero.ult_for_weapon(level) if _ult_open() else null
		ultimate = String(ult.id) if ult != null else ""
	elif Dev.has("hero-equip"):
		push_warning("--hero-equip: the robot takes no Gifts from the save; use --talents=a,b")
	if Dev.has("ultimate"):
		# --ultimate=cleave|vortex: that one, whatever the Mastery (tests, captures, the robot)
		var chosen := hero.ultimate(StringName(Dev.arg("ultimate")))
		ultimate = String(chosen.id) if chosen != null else ""
		if chosen == null:
			push_warning("--ultimate: no ultimate %s" % Dev.arg("ultimate"))
	if hero.arcane != null and ultimate == "" and not hero.ultimates.is_empty() and (bot != null or Dev.has("talents")):
		var fixed := hero.ult_for_weapon(99)
		ultimate = String(fixed.id) if fixed != null else ""  # (the robot and --talents play the Tempestade; a person gets it at Mastery 2, as her own curve says)
	talents = ids
	if bot != null or Dev.has("talents"):
		talents_opened = ids.size()
	if not ids.is_empty() or not boons.forge.is_empty() or not boons.granted.is_empty():
		_apply_talents(ids)


## SW-O5: whether the save has the Ultimate open (Milestones.ult_open, the milestone batch's; open while it is not there).
static func _ult_open() -> bool:
	var path := "res://scripts/core/milestones.gd"
	if not ResourceLoader.exists(path):
		return true
	var m := load(path) as GDScript
	return bool(m.call(&"ult_open", Save.data))


## The Ofícios of this descent: --oficios=noted,pity,pick,preview (also the robot's), else a person's save; nothing
## for the robot (its runs stay as they were).
func _start_oficios() -> void:
	oficios_def = OficiosDef.live()
	if Dev.has("oficios"):
		oficios = OficiosRun.from_words(Dev.arg("oficios").split(",", false))
	elif bot == null and Save.enabled:
		oficios = OficiosRun.from_save(Save.data, oficios_def)
	else:
		oficios = OficiosRun.new()


## The Forja's ranks for this descent (Rejogabilidade, Fatia 1): --forge=N (Temperar up to N, also the robot's), else a
## person's save (heroes.<id>.forge.temper); none for the robot. Summed in boons.stat as the Gifts (BoonState.forge).
func _equip_forge() -> void:
	if Dev.has("forge"):
		forge_temper = int(Dev.num("forge", 0))
	elif bot == null:
		forge_temper = Forge.temper(Save.data, String(hero.id))
	var forge := Forge.new(Forge.load_catalog())
	var ranks := forge.up_to(forge_temper)
	# the Refinar on (Fatia 2): --refine=a,b (also the robot's), else a person's save
	var refine: Array[ForgeRank] = []
	if Dev.has("refine"):
		for id in Dev.arg("refine").split(",", false):
			var r := forge.find(StringName(id))
			if r != null and r.track == Forge.REFINE:
				refine.append(r)
	elif bot == null and not Dev.has("forge"):
		refine = forge.refines_on(Save.data, String(hero.id))
	for r in refine:
		ranks.append(r)
		forge_refine.append(String(r.id))
	# the Despertar awake (Fatia 3): --awaken=id (also the robot's), else a person's save
	var awake: ForgeRank = null
	if Dev.has("awaken"):
		awake = forge.find(StringName(Dev.arg("awaken")))
	elif bot == null and not Dev.has("forge"):
		awake = forge.awake(Save.data, String(hero.id))
	if awake != null and awake.track == Forge.AWAKEN:
		ranks.append(awake)
		forge_awaken = String(awake.id)
	# Discernimento (Fatia 3): --discern=N (also the robot's), else a person's save
	if Dev.has("discern"):
		discern = int(Dev.num("discern", 0))
	elif bot == null and Save.enabled:
		discern = Discern.level(Save.data, String(hero.id))
	rerolls_left = Discern.rerolls(discern)
	boons.equip_forge(ranks)
	player.set_temper(forge_temper)  # (G-2: the blade shows its rank)


## A Videira for this descent: --vine=N (also --account=N; the first N nodes, also the robot's), else a person's save
## (vine.bought); none for the robot. Summed in boons.stat as the Forja's (BoonState.grant); life reaches the paladin in
## _apply_talents, which reads the sum; Prata, Memória and materials come as a bonus of the descent's purse; the merchant
## (traveler), the stock and the healing shelf are read by Rooms (the map is drawn after this).
func _equip_vine() -> void:
	var tree := Vine.new(Vine.load_catalog())
	var ids: Array = []
	if Dev.has("vine") or Dev.has("account"):
		ids = tree.first(int(Dev.num("vine" if Dev.has("vine") else "account", 0)))
	elif bot == null and Save.enabled:
		ids = Vine.bought_ids(Save.data)
	vine_nodes = ids.size()
	boons.grant(tree.mods_of(ids))
	materials.bonus = {MaterialPurse.SILVER: boons.stat(&"silver_pct"), MaterialPurse.MEMORY: boons.stat(&"memory_pct"),
		&"all": boons.stat(&"material_pct")}


## The Juramentos of this descent (E6): --juramentos=id:rank,... (any, for tests and the robot), else a person's
## saved choice once Morvath was sealed once (never without a save: --nosave, the tests); none for the robot. Their numbers on the enemies' life go to the horde
## now; the rest is read where it acts (Rooms, Boss, _take).
## Coragem: after early deaths, +3 life and a pomegranate each (Courage), only for a person's save and without a Juramento.
func _start_courage() -> void:
	if bot != null or not Save.enabled:
		return
	var hero_id := String(hero.id)
	var stacks := Courage.active(Courage.stacks_of(Save.data, hero_id), juramentos.weight() > 0)
	courage_stacks = stacks
	if stacks == 0:
		return
	courage_poms = Courage.pomegranates(stacks)
	life_bonus += Courage.life(stacks)
	player.max_hp += Courage.life(stacks)
	player.hp = player.max_hp
	var line := T.t(&"courage_start_1") % int(Courage.life(stacks)) if courage_poms == 1 else T.t(&"courage_start_n") % [int(Courage.life(stacks)), courage_poms]
	fx.word(Vector3(player.pos.x, 3.2, player.pos.y), line, Color(1.0, 0.8, 0.4))


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


## The hero's own life before Bênçãos and the Videira: --hero-hp=N (dev, for captures) holds through Dons and Bênçãos.
func _base_max_hp() -> float:
	return Dev.num("hero-hp", hero.max_hp) if Dev.has("hero-hp") else hero.max_hp


func _apply_talents(ids: Array[StringName]) -> void:
	boons.equip_talents(hero.talents().defs(ids))
	player.max_hp = _base_max_hp() + boons.stat(&"max_hp") + life_bonus
	player.hp = player.max_hp
	player.magick.max_value = hero.magick_max + boons.stat(&"magick_max")
	player.magick.value = player.magick.max_value


## The Mastery XP this run gives, by source and in total (RunAward.gain).
func mastery_gain(outcome: String, data: Dictionary) -> Dictionary:
	return RunAward.gain(self, outcome, data)


## Adds a run's Mastery to save data (RunAward.award).
func award_mastery(gain: Dictionary, outcome: String, data: Dictionary) -> void:
	RunAward.award(self, gain, outcome, data)


## The run's enemies, Morvath and arenas into save data's Codex (RunAward.codex).
func codex_run(outcome: String, data: Dictionary) -> void:
	RunAward.codex(self, outcome, data)


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
## The frame length of a smoke run, in seconds.
const SMOKE_DT := 1.0 / 60.0
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


## A line of numbers about the run, for smoke tests and tuning (RunReport.result, DT-106).
func result() -> Dictionary:
	return RunReport.result(self)


## The RESULT line the smoke runs and captures print (RunReport.line).
func result_line() -> String:
	return RunReport.line(self)


## The frame's delta. A smoke run steps at a fixed 60 fps whatever the machine's load (as `--fixed-fps 60` does), so
## the same seed and the same bot give the same RESULT; the bot's reactions depend on the frame length.
func _frame_delta(delta: float) -> float:
	if Dev.has("smoke") and not Dev.has("smoke-realtime"):
		return SMOKE_DT * Engine.time_scale
	return delta


## --smoke=seconds: plays without a screen for that long (or until the run ends), prints RESULT and quits.
func _smoke() -> void:
	var limit := Dev.num("smoke", 60.0)
	var t := 0.0
	while t < limit and mode != Mode.OVER and not (mode == Mode.ENDING and boss == null and _screen != null):
		await get_tree().process_frame
		t += _frame_delta(get_process_delta_time())
	print(result_line())
	get_tree().quit()
