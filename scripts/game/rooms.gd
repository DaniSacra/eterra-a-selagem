class_name Rooms
extends Node3D
## The descent room by room (the structure of Hades II's first region, with our rooms and rewards): each room is
## closed until its waves are beaten, leaves its reward, then its doors light up showing what lies behind each.
## Owned and stepped by Game; RunMap draws the rooms, EncounterGen the fights.

## EVENT: the Provação's chamber before its card is taken (its doors stay shut).
enum Phase { FIGHT, REWARD, OPEN, LEAVING, BOSS, EVENT }

## E5, for the screens and the scenery (docs/art/e5_spec.md 5 and 6): the Provação's slab appeared (where, the life it
## asks), was paid (he walks into its chamber), its cards are on offer (Array of Trials.Card; take_trial(i) takes one),
## one was taken, and its curse turned into the blessing (the "Provação vencida" banner, the seal's turn). The altar's
## trade (Altar.IDS, or &"" for none) as he leaves it or takes one.
signal trial_slab_shown(at: Vector2, cost: int)
signal trial_entered(cost: int)
signal trial_offered(cards: Array)
signal trial_taken(card: Trials.Card)
signal trial_turned(card: Trials.Card)
signal altar_used(option: StringName)

const STAGE := "res://data/stages/catacombs.tres"
## The descent's graph is drawn on dice of its own (DV-1): the run's seed with this salt (the same --seed, the same map
## whatever else the run draws before it).
const MAP_SALT := 7411
## Seconds after walking in before the first wave rises (Hades II starts a fight as you step into the room).
const START_DELAY := 1.0
## Meters from the reward or a pedestal that count as touching it.
const TOUCH := 1.6
## C19, Q-13 (Hades II): the reward, a shop's item and a door are used with the interact action (E, A on the gamepad),
## standing at them; touching them does nothing more (before, stepping on a pedestal bought it, on a door's foot left).
## use() is the same press from elsewhere (a click on a sign, a test).
var _use_queued := false


func use() -> void:
	_use_queued = true


## The interact action this step (or a use() queued), once.
func _used() -> bool:
	var want := _use_queued or Controls.pressed(&"interact")
	_use_queued = false
	return want


## Whether the paladin stands at something to use now (the reward, a shop's item, a door): the robot presses then,
## and the HUD may show the key.
func usable() -> bool:
	match phase:
		Phase.REWARD:
			return _reward_node != null and game.player.pos.distance_to(_reward_at) < TOUCH
		Phase.OPEN:
			for p in _pedestals:
				if game.player.pos.distance_to(p.at) < TOUCH:
					return true
			var door := game.arena.exit_at(game.player.pos)
			return door >= 0 and door < next_rooms.size()
	return false
const FADE := 0.35
## The last kill of a room: world speed, seconds held and seconds back to normal (Hades II: 0.35, about 0.6, 0.4).
const LAST_KILL_SLOW := 0.35
const LAST_KILL_HOLD := 0.55
const LAST_KILL_OUT := 0.4
const GOLD_COLOR := Color(1.0, 0.82, 0.35)
## The words of the materials where they fall ("+10 Prata"; Rejogabilidade, Fatia 1): silver cold and pale, the
## Memória a parchment.
const SILVER_COLOR := Color(0.78, 0.8, 0.86)
const MEMORY_COLOR := Color(0.86, 0.78, 0.6)

var game: Game
var stage: StageDef
var map: RunMap
var room: RunMap.Room
var next_rooms: Array[RunMap.Room] = []
var phase := Phase.FIGHT
var gold := 0:
	set(v):
		gold = v
		for p in _pedestals:
			(p.sign as DoorSign).set_gold(gold)
## The kinds of the rooms won in this run (fights and the guardian's), for the Mastery (Game.mastery_gain).
var won: Array[RunMap.Kind] = []
## The gold this fight can still give, dropped by the enemies that fall (C13-04; null outside a fight).
var purse: GoldPurse
var _waves: Array[Array] = []
var _queue: Array[StringName] = []
var _wave := -1
var _spawn_t := 0.0
var _wave_wait := 0.0
var _cap := 4
var _reward_at := Vector2.ZERO
var _reward_node: Node3D
var _pedestals: Array[Dictionary] = []
var _door_labels: Array[Node3D] = []
var _defs: Dictionary = {}
## The arena of this room as it is dressed (its variant), or null.
var _layout: RoomLayout
## E5: the Provação of this run (its curse carried now: trials.active, trials.left; for the HUD's seal).
var trials: Trials
## The Provação's slab in the room just won (null: none): {at, cost, armed (seconds until it may be stepped on)}.
var slab: Variant = null
## The cards of the Provação on offer in its chamber, and the altar's trades (Altar.options) in its room.
var trial_cards: Array[Trials.Card] = []
var altar_options: Array[Dictionary] = []
## The floor of the runes in a fight there (null: none).
var runes: RuneFloor
## RP-06: the slabs that strike when stepped on in a fight there (null: none).
var plates: PlateFloor
var _slab_node: Node3D
var _slab_sign: DoorSign
## The spot before the trial's block and before the altar's step where its choice screen opens: {at, node, away (he
## has stepped off since it last opened)}; empty once the choice is made.
var _spots: Array[Dictionary] = []
## The robot's mind on the slab of this room (decided once when it shows).
var _bot_trial := false
var _rng: RandomNumberGenerator
var _fade: ColorRect
## The floating signs turn slowly.
var _gems: Array[Node3D] = []


func setup(g: Game, rng: RandomNumberGenerator) -> void:
	game = g
	_rng = rng
	stage = load(STAGE)
	if Dev.has("short"):
		stage = short_stage(stage, 4)
	elif Dev.has("medium"):
		stage = short_stage(stage, 6)
	if g.juramentos:
		stage = g.juramentos.stage_for(stage)  # E6: more elites, dearer shop
	trials = Trials.new(Trials.load_catalog())
	var forced := -1
	if Dev.has("arena"):
		# dev: --arena=id makes the opening room that arena (--variant=n dresses it)
		for i in stage.layouts.size():
			if String(stage.layouts[i].id) == Dev.arg("arena"):
				forced = i
	map = new_map(stage, forced)
	for id in stage.enemies:
		_defs[id] = game.horde.def(id)
	game.horde.killed.connect(_on_killed)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.ui.add_child(_fade)


## The shorter descents kept for tests (C13-01): rooms 4 is the old one of 5 (fight, fountain, guardian, shop, Morvath
## in room 5; --short), rooms 6 the test one of 7 of cycle C12 (three fights, fountain in room 4, guardian in 5, shop
## in 6, Morvath in 7; --medium). Elites from the 2nd room, as they were.
static func short_stage(full: StageDef, rooms_: int) -> StageDef:
	var st: StageDef = full.duplicate()
	st.rooms = rooms_
	st.elite_from_depth = 2
	if rooms_ <= 4:
		st.fountain_depth_min = 2
		st.fountain_depth_max = 2
		st.miniboss_depth_min = 3
		st.miniboss_depth_max = 3
	else:
		st.fountain_depth_min = rooms_ - 2
		st.fountain_depth_max = rooms_ - 2
		st.miniboss_depth_min = rooms_ - 1
		st.miniboss_depth_max = rooms_ - 1
	# the events (E5) inside the shorter descent: the altar before the shop, the slab with a fight left after it
	st.altar_depth_max = mini(st.altar_depth_max, rooms_ - 1)
	st.trial_depth_max = mini(st.trial_depth_max, rooms_ - 2)
	return st


## The descent's graph of a run (DV-1), on its own dice: the run's seed and MAP_SALT.
func new_map(st: StageDef, forced := -1) -> RunMap:
	return RunMap.new(st, hash([_rng.seed, MAP_SALT]), forced, trials.shortest_curse())


func start() -> void:
	_enter(map.first())


## Dev: jumps straight to a room kind (--start=boss|miniboss|shop|fountain|trial|altar): the first room of that kind
## in the graph (the altar's graph is drawn again with the altar sure to come; the trial's chamber as if a fight of
## depth 3 had shown its slab, its doors those of that room).
func start_at(kind: RunMap.Kind) -> void:
	if kind == RunMap.Kind.ALTAR and stage.altar_layout != null:
		var st: StageDef = stage.duplicate()
		st.altar_chance = 1.0
		map = new_map(st, map.forced_layout)
	if kind == RunMap.Kind.TRIAL:
		var at := map.layer(3).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.COMBAT)
		map.enter(at[0] if not at.is_empty() else map.layer(3)[0])
		next_rooms = map.doors()
		_prepare(next_rooms)
		_enter(map.trial(map.depth))
		return
	for r in map.nodes:
		if r.kind == kind:
			_enter(r)
			return
	_enter(map.first())


func depth() -> int:
	return map.depth


func step(dt: float) -> void:
	_step_prompt()
	match phase:
		Phase.FIGHT:
			_step_fight(dt)
		Phase.REWARD:
			if _reward_node != null and game.player.pos.distance_to(_reward_at) < TOUCH and _used():
				_collect()
		Phase.OPEN:
			var use := _used()
			_step_shop(use)
			_step_slab(dt)
			_step_spots()
			var door := game.arena.exit_at(game.player.pos)
			if door >= 0 and door < next_rooms.size() and use:
				_leave(next_rooms[door])
		Phase.EVENT:
			_step_spots()
			_use_queued = false
		_:
			_use_queued = false


## The key to press over the hero while he stands at something to use (the reward, a shop's item, a door): the
## StationSign's plate without a name, the real key and the verb ("Pegar", "Comprar", "Entrar"); none for the robot.
var prompt: StationSign
var _prompt_kind := &""


## What the paladin stands at to use now: &"reward", &"shop", &"door" or &"" (usable()'s places, by kind).
func use_kind() -> StringName:
	match phase:
		Phase.REWARD:
			if _reward_node != null and game.player.pos.distance_to(_reward_at) < TOUCH:
				return &"reward"
		Phase.OPEN:
			for p in _pedestals:
				if game.player.pos.distance_to(p.at) < TOUCH:
					return &"shop"
			var door := game.arena.exit_at(game.player.pos)
			if door >= 0 and door < next_rooms.size():
				return &"door"
	return &""


func _process(_delta: float) -> void:
	if prompt != null:
		prompt.visible = game.mode == Game.Mode.PLAY  # nothing over a screen, the pause or the end


func _step_prompt() -> void:
	var kind := &"" if game.bot != null else use_kind()
	if kind != _prompt_kind:
		_prompt_kind = kind
		if is_instance_valid(prompt):
			prompt.queue_free()
		prompt = null
		if kind != &"":
			prompt = StationSign.make(kind, "", "")
			prompt.pressed.connect(use)
			add_child(prompt)
	if prompt != null:
		var at := Vector3(game.player.pos.x, 0.0, game.player.pos.y)
		prompt.position = at
		prompt.hero_at = at


# ---------- entering ----------

func _exit_tree() -> void:
	Music.ambience(&"")  # back to the title: no room, no air


func _enter(next: RunMap.Room) -> void:
	room = next
	map.enter(room)
	if room.kind != RunMap.Kind.TRIAL:
		# the rooms its links lead to (DV-1; the Provação's chamber keeps the doors of the room its slab was in)
		next_rooms = map.doors()
		_prepare(next_rooms)
	var layout: RoomLayout = stage.layouts[room.layout] if not stage.layouts.is_empty() and room.layout >= 0 else null
	match room.kind:
		RunMap.Kind.BOSS:
			layout = stage.boss_layout
		RunMap.Kind.SHOP:
			layout = stage.shop_layout
		RunMap.Kind.TRIAL:
			layout = stage.trial_layout
		RunMap.Kind.ALTAR:
			layout = stage.altar_layout
	var variant := room.variant
	if layout != null:
		if Dev.has("variant") and room.depth == 1:
			variant = int(Dev.num("variant", 0))
		layout = layout.variant(variant)
	var exits := 0 if room.kind == RunMap.Kind.BOSS else next_rooms.size()
	game.rebuild_room(layout, exits, 1406 + room.depth * 31 + room.layout)
	_layout = layout
	_clear_props()
	game.player.place(game.arena.start)
	game.player.facing = game.arena.start_facing
	if Dev.has("hero-at"):
		# dev, for captures: --hero-at=x,z puts the paladin there (kept on the floor)
		var xz := Dev.arg("hero-at").split(",")
		if xz.size() == 2:
			game.player.place(Vector2(float(xz[0]), float(xz[1])))
	game.player.magick.gain(game.player.magick.max_value)  # Magia is full in every room (Hades II)
	game.room_tally.enter(room.depth, String(game.arena.id), game.player.hp, game.time, room.kind == RunMap.Kind.BOSS,
		variant, gold, game.boons.owned().size(), room.id)
	if room.kind == RunMap.Kind.SHOP:
		game.room_tally.shop_entered(gold)
	_queue.clear()
	_waves.clear()
	_wave = -1
	_wave_wait = START_DELAY
	# nobody stands past the stage's ceiling, summons included; a fight lowers it to its tier's most
	game.horde.alive_cap = stage.alive_cap
	purse = null
	# the rooms' music (E4-06): the fight's layer comes in for a fight and goes when it is won; Morvath has his own
	if room.kind != RunMap.Kind.BOSS:
		var fighting := room.kind in [RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS, RunMap.Kind.TRIAL]
		Music.play(&"catacombs", Music.FIGHT if fighting else Music.WALK)
	Music.ambience(game.arena.id if game.arena.layout != null else &"hall")  # the room's air, crossfaded (E6, C15-04)
	_stop_runes()
	slab = null
	_slab_node = null
	_slab_sign = null
	_spots.clear()
	trial_cards.clear()
	altar_options.clear()
	_apply_curse()
	match room.kind:
		RunMap.Kind.COMBAT:
			var fight := room.fight if room.fight != null else EncounterGen.generate(stage, room.depth, _defs, _rng, 1.0, layout)
			_waves = _cursed_waves(game.juramentos.more_waves(fight.waves) if game.juramentos else fight.waves)
			var rating := 0.0
			for w: Array in fight.waves:
				for id: StringName in w:
					rating += (_defs[id] as EnemyDef).rating if _defs.has(id) else 0.0
			purse = GoldPurse.for_fight(stage, room.depth, rating, _rng)
			_cap = fight.cap
			game.horde.alive_cap = fight.ceiling
			phase = Phase.FIGHT
			_start_hazard(layout)
		RunMap.Kind.MINIBOSS:
			var guardian: Array[StringName] = [room.fight.kinds[0] if room.fight != null and not room.fight.kinds.is_empty()
				else room.guardian if room.guardian != &"" else stage.minibosses[_rng.randi() % stage.minibosses.size()]]
			_waves = [guardian]
			var alive := EncounterGen.in_room(EncounterGen.alive_range(stage, stage.miniboss_tier), layout)
			_cap = mini(EncounterGen.cap(stage, stage.miniboss_tier, room.depth), alive.y)
			game.horde.alive_cap = alive.y
			phase = Phase.FIGHT
			if layout != null and layout.hazard != null and layout.hazard.kind == HazardDef.Kind.PLATES:
				_start_hazard(layout)  # the slabs of the guardian's house (RP-06); the runes never hold a guardian
		RunMap.Kind.FOUNTAIN:
			game.spawn_fountain(Vector2(0, -2.0))
			_open_doors()
		RunMap.Kind.SHOP:
			_build_shop()
			_open_doors()
		RunMap.Kind.TRIAL:
			_build_trial()
		RunMap.Kind.ALTAR:
			_build_altar()
			_open_doors()
		RunMap.Kind.BOSS:
			phase = Phase.BOSS
			# dev, for captures of the empty chamber: --no-boss
			if not Dev.has("no-boss"):
				game.start_boss(stage.boss)
	game.hud.show_notice(T.t(RunMap.KIND_KEY[room.kind]) if room.kind != RunMap.Kind.COMBAT else T.t(&"notice_room", {"n": room.depth}), 2.0)
	if room.kind != RunMap.Kind.BOSS and game.arena.name_key != &"":
		# the arena's name for 2 s (decision D-33)
		game.hud.show_place(T.t(game.arena.name_key))
	game.snap_camera()
	_fade_in()


# ---------- the fight ----------

func _step_fight(dt: float) -> void:
	if _layout != null and not _layout.areas.is_empty():
		game.room_tally.zone_time(_layout.area_at(game.player.pos), dt)
	if runes != null:
		runes.step(dt)
	if plates != null:
		plates.step(dt)
	if _wave_wait > 0.0:
		_wave_wait -= dt
		if _wave_wait <= 0.0:
			_next_wave()
		return
	if not _queue.is_empty():
		_spawn_t -= dt
		if _spawn_t <= 0.0 and game.horde.count() < _cap:
			_spawn(_next_in_queue())
			_spawn_t = _rng.randf_range(stage.spawn_interval_min, stage.spawn_interval_max)
		return
	var alive := game.horde.count()
	if _wave + 1 < _waves.size():
		if alive <= stage.wave_remaining:
			_wave_wait = stage.wave_delay
	elif alive == 0:
		_room_cleared()


func _next_wave() -> void:
	_wave += 1
	if _wave < _waves.size():
		_queue.assign(_waves[_wave])
		_spawn_t = 0.0


func _spawn(id: StringName) -> void:
	var d := game.horde.def(id)
	var at := _spawn_point()
	if room.kind == RunMap.Kind.MINIBOSS and _layout != null and _layout.guardian_home and _layout.boss_spawn != Vector2.ZERO \
			and _wave == 0 and game.horde.count() == 0:
		# the guardian rises in his own house, before the presbytery's grille (E5, spec 1.4)
		at = game.arena.resolve(_layout.boss_spawn, d.radius)
	game.horde.spawn(d, at, true)
	game.fx.burst(&"shadow", Vector3(at.x, 0.6, at.y))
	if d.elite:
		game.column(at, d.rim_color, 1.2, 8.0, 0.8)
		if room.kind == RunMap.Kind.MINIBOSS:
			game.hud.show_notice(T.t(&"notice_elite", {"name": T.t(d.name_key)}), 3.0)
			Audio.play(&"elite")


## The next of the wave to rise: the first in line, unless the arena already has its most shooters standing
## (RoomLayout.max_ranged), then the first that does not shoot (the shooter waits its turn).
func _next_in_queue() -> StringName:
	var most := _layout.max_ranged if _layout != null else 0
	if most > 0:
		var standing := 0
		for e in game.horde.list:
			if EncounterGen.ranged(e.def):
				standing += 1
		if standing >= most:
			for i in _queue.size():
				if not EncounterGen.ranged(_defs.get(_queue[i], game.horde.def(_queue[i]))):
					return _queue.pop_at(i)
	return _queue.pop_front()


## Meters from the paladin an enemy rises at least, and the tries for a spot.
const SPAWN_CLEAR := 6.0
const SPAWN_TRIES := 16


## Where an enemy rises (cycle C12, BUG-016): in one of the arena's spawn zones (anywhere on its floor when it has
## none), on free floor reached from where the paladin stands, never within SPAWN_CLEAR of him.
func _spawn_point() -> Vector2:
	return spawn_point(game.arena, game.player.pos, _rng, _wave > 0)


static func spawn_point(arena: Arena, hero: Vector2, rng: RandomNumberGenerator, late := false) -> Vector2:
	var zones: Array[Rect2] = arena.spawns.duplicate()
	if late:
		zones.append_array(arena.late_spawns)
	if zones.is_empty():
		zones.append(arena.shape().bounds().grow(-2.5))
	var area := PackedFloat32Array()
	for z: Rect2 in zones:
		area.append(maxf(z.get_area(), 0.01))
	var best := arena.resolve(zones[0].get_center(), 0.6)
	for attempt in SPAWN_TRIES:
		var z := zones[rng.rand_weighted(area)]
		var at := Vector2(rng.randf_range(z.position.x, z.end.x), rng.randf_range(z.position.y, z.end.y))
		at = arena.resolve(at, 0.6)
		if not arena.nav.reachable(at, hero) or not arena.nav.walkable(at):
			continue
		best = at
		if at.distance_to(hero) > SPAWN_CLEAR:
			break
	return best


func _room_cleared() -> void:
	phase = Phase.REWARD
	Music.set_level(Music.WALK)
	won.append(room.kind)
	_stop_runes()
	_fight_won()
	game.hero_gifts.room_won()  # Respiro
	# the last blow of a fight: the world slows to a third, the camera closes in, the screen streaks (Hades II)
	game.fx.slow_mo(LAST_KILL_SLOW, LAST_KILL_HOLD, LAST_KILL_OUT, 1.1, 0.85)
	game.projectiles.clear_hostile()
	# a warning still on the floor never hurts him once the room is won (QA-01)
	game.ground.clear_warnings()
	Audio.play(&"elite_down")
	purse = null
	game.hud.show_notice(T.t(&"notice_room_clear"), 2.0)
	if room.kind == RunMap.Kind.MINIBOSS:
		# the guardian won: Prata and Memória for home (Rejogabilidade, Fatia 1)
		found(MaterialPurse.SILVER, &"guardian", stage.silver_guardian)
		found(MaterialPurse.MEMORY, &"guardian", stage.memory_guardian)
	if room.reward == RunMap.Reward.NONE:
		_open_doors()
		return
	_reward_at = game.arena.resolve(game.arena.middle, 1.0)
	_reward_node = _marker(_reward_at, room.reward, "")
	game.column(_reward_at, _reward_color(room.reward), 1.4, 12.0, 1.0)


## An enemy fell: in a fight it may leave its share of the fight's gold (GoldPurse), shown where it fell. An elite
## (not a guardian nor Morvath) leaves Prata Antiga too (Rejogabilidade, Fatia 1).
func _on_killed(e: Enemy) -> void:
	if e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS and not stage.minibosses.has(e.def.id) \
			and room != null and room.kind != RunMap.Kind.BOSS:
		found(MaterialPurse.SILVER, &"elite", stage.silver_elite, e.pos)
	if purse == null or phase != Phase.FIGHT:
		return
	var found := floori(purse.drop(e.def.rating, _rng) * maxf(0.0, 1.0 + trials.curse(&"gold_pct")))
	if found <= 0:
		return
	gold += found
	game.fx.gold(Vector3(e.pos.x, 2.4, e.pos.y), found)


func _collect() -> void:
	var reward := room.reward
	_reward_node.queue_free()
	_reward_node = null
	# what the room gave, beside the door that promised it (DV-1, MAP-02: the log checks the promise)
	game.room_tally.event("reward", game.time, {"node": room.id, "reward": (RunMap.Reward.keys()[reward] as String).to_lower()})
	_give(reward, room.kind == RunMap.Kind.MINIBOSS, true)
	_open_doors()


## Hands over a reward (from a room or bought in the shop). meeting: a room's Blessing comes by the meeting with two
## angels (Rejogabilidade, Fatia 1: Encounters); the shop's Blessing is drawn as before.
func _give(reward: RunMap.Reward, guardian: bool = false, meeting: bool = false) -> void:
	var p := game.player
	match reward:
		RunMap.Reward.BOON:
			game.open_boon_choice(stage.guardian_rarity_chance if guardian else stage.rarity_chance,
					stage.guardian_psalm_chance if guardian else stage.psalm_chance, meeting)
		RunMap.Reward.SILVER:
			found(MaterialPurse.SILVER, &"door", stage.silver_door)
		RunMap.Reward.MEMORY:
			found(MaterialPurse.MEMORY, &"door", stage.memory_door)
		RunMap.Reward.POM:
			game.open_grow_choice()
		RunMap.Reward.POM_SLICE:
			game.grow_random()
		RunMap.Reward.HEART:
			game.add_max_life(stage.heart_life)
		RunMap.Reward.MAGICK:
			p.magick.max_value += stage.magick_more
			p.magick.gain(stage.magick_more)
			game.fx.word(Vector3(p.pos.x, 3.0, p.pos.y), "+%d %s" % [int(stage.magick_more), T.t(&"hud_magick")], Color(0.5, 0.75, 1.0))
		RunMap.Reward.GOLD:
			gold += stage.gold_reward
			game.fx.gold(Vector3(p.pos.x, 3.0, p.pos.y), stage.gold_reward)
		RunMap.Reward.HEAL:
			p.heal(p.max_hp * stage.shop_heal)
			game.fx.burst(&"heal", Vector3(p.pos.x, 1.2, p.pos.y))
	Audio.play(&"heal" if reward == RunMap.Reward.HEAL or reward == RunMap.Reward.HEART else &"orb")


# ---------- Rejogabilidade, Fatia 1: the materials brought home ----------

## Picks up n of a material for home (the run's MaterialPurse, game.materials), from a source (elite, door, guardian,
## trial, boss), the word "+n Prata" shown where it falls (at; the paladin when none). Never a counter in the HUD
## (sistemas.md 1.2): the end screen and the hub show the totals.
func found(material: StringName, source: StringName, n: int, at: Variant = null) -> void:
	if game.materials.add(material, source, n) <= 0:
		return
	if not at is Vector2:
		return  # (a door's or a guardian's: the HUD's greeting says it; the word fell on the damage numbers)
	var where: Vector2 = at
	var color := SILVER_COLOR if material == MaterialPurse.SILVER else MEMORY_COLOR
	game.fx.word(Vector3(where.x, 3.0, where.y), "+%d %s" % [n, T.t(MaterialPurse.SHORT_KEY[material])], color)


## Morvath reached a phase (1 when he rises, Boss.phase_changed after): silver_phase Prata for each phase not paid yet,
## up to StageDef.phase_max.
var _phases_paid := 0


func boss_phase(n: int) -> void:
	var upto := mini(n, stage.phase_max)
	while _phases_paid < upto:
		_phases_paid += 1
		found(MaterialPurse.SILVER, &"boss", stage.silver_phase)


## Morvath is sealed: the victory's Prata and Memória.
func victory() -> void:
	found(MaterialPurse.SILVER, &"boss", stage.silver_victory)
	found(MaterialPurse.MEMORY, &"boss", stage.memory_victory)


# ---------- doors ----------

func _open_doors() -> void:
	phase = Phase.OPEN
	if room.kind == RunMap.Kind.COMBAT or room.kind == RunMap.Kind.MINIBOSS:
		_roll_slab()
	# a pomegranate behind a door when nothing can grow turns into a Blessing before its sign shows (Q-25 a); the
	# Blessing of this room counts as one to grow
	map.settle(next_rooms, game.boons.can_grow() or room.reward == RunMap.Reward.BOON)
	for i in next_rooms.size():
		var r := next_rooms[i]
		game.arena.light_exit(i, true, _reward_color(r.reward) if r.reward != RunMap.Reward.NONE else _kind_color(r.kind))
		if game.arena.look != null:
			# the air of the room behind it breathes out of the doorway (ArenaRoom.breath)
			game.arena.look.breath(i, door_look(i))
		_door_labels.append(_marker(game.arena.door_label(i), r.reward, door_text(r), r.kind, DoorGlyph.of(door_info(i))))
	if not next_rooms.is_empty():
		Audio.play(&"door")


## A door's sign (E5-D8, docs/art/e5_spec.md 7.1): the reward of a fight, under it "Difícil" for one with an elite
## and "Guardião" for the guardian's; the room's kind for the others (the pictogram beside it: DoorGlyph.of(door_info)).
## The altar's says what it is in a line (T5): a trade with no fight.
static func door_text(r: RunMap.Room) -> String:
	match r.kind:
		RunMap.Kind.COMBAT:
			var hard := bool(r.sign().hard)
			return T.t(RunMap.REWARD_KEY[r.reward]) + ("\n" + T.t(&"door_hard") if hard else "")
		RunMap.Kind.MINIBOSS:
			return T.t(RunMap.REWARD_KEY[r.reward]) + "\n" + T.t(RunMap.KIND_KEY[r.kind])
		RunMap.Kind.ALTAR:
			return T.t(RunMap.KIND_KEY[r.kind]) + "\n" + T.t(&"door_altar")
	return T.t(RunMap.KIND_KEY[r.kind])


func _leave(next: RunMap.Room) -> void:
	_log_leaving(next)
	phase = Phase.LEAVING
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func() -> void: _enter(next))


func _fade_in() -> void:
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, FADE)


# ---------- E5: the doors that show the way ----------

## Draws the fights behind the doors before they open (E5-D8: the sign can say "Difícil" or "Guardião"), in the arena
## (and its variant) each door leads to, on the room's own seed (DV-1: the same room, the same fight, whatever the way
## to it); the guardian's is the one the graph put there.
func _prepare(doors: Array[RunMap.Room]) -> void:
	for r in doors:
		if r.fight != null:
			continue
		match r.kind:
			RunMap.Kind.COMBAT:
				var l: RoomLayout = stage.layouts[r.layout].variant(r.variant) if r.layout >= 0 and r.layout < stage.layouts.size() else null
				var dice := RandomNumberGenerator.new()
				dice.seed = r.fight_seed
				r.fight = EncounterGen.generate(stage, r.depth, _defs, dice, 1.0, l)
			RunMap.Kind.MINIBOSS:
				var f := EncounterGen.Fight.new()
				f.kinds = [r.guardian if r.guardian != &"" else stage.minibosses[_rng.randi() % stage.minibosses.size()]]
				f.tier = stage.miniboss_tier
				f.waves = [f.kinds.duplicate()]
				r.fight = f


## What door i tells (for the sign, the scenery of its doorway and the log): RunMap.Room.sign() and the arena it leads
## to (&"" for none: the boss, a room of its own) and its name keys (kind_key, reward_key; guardian_key, the name of
## the guardian who waits there). {} when there is no such door.
func door_info(i: int) -> Dictionary:
	if i < 0 or i >= next_rooms.size():
		return {}
	var r := next_rooms[i]
	var info := r.sign()
	var arena: StringName = &""
	match r.kind:
		RunMap.Kind.BOSS:
			arena = stage.boss_layout.id if stage.boss_layout else &""
		RunMap.Kind.ALTAR:
			arena = stage.altar_layout.id if stage.altar_layout else &""
		RunMap.Kind.SHOP:
			arena = stage.shop_layout.id if stage.shop_layout else &""
		_:
			arena = stage.layouts[r.layout].id if r.layout >= 0 and r.layout < stage.layouts.size() else &""
	info.merge({"arena": arena, "kind_key": RunMap.KIND_KEY[r.kind], "reward_key": RunMap.REWARD_KEY[r.reward]})
	if r.guardian != &"":
		info["guardian_key"] = game.horde.def(r.guardian).name_key  # who waits there, for the map (Q-27 a)
	return info


## The look of the room behind door i (ArenaRoom.BREATH's keys: the arena's id, &"chamber" for Morvath's).
func door_look(i: int) -> StringName:
	if i >= 0 and i < next_rooms.size() and next_rooms[i].kind == RunMap.Kind.BOSS:
		return &"chamber"
	return door_info(i).get("arena", &"")


## A door in a word for the run's log: kind, reward, "hard" and the guardian (combat/boon/hard, altar,
## miniboss/boon/knight).
static func door_word(r: RunMap.Room) -> String:
	var info := r.sign()
	var w := (RunMap.Kind.keys()[r.kind] as String).to_lower()
	if r.reward != RunMap.Reward.NONE:
		w += "/" + (RunMap.Reward.keys()[r.reward] as String).to_lower()
	if info.hard:
		w += "/hard"
	if r.guardian != &"":
		w += "/" + String(r.guardian)
	return w


## The log of a room left by a door: the doors there were and the one taken; a slab not stepped on is refused; an
## altar left without a trade.
func _log_leaving(next: RunMap.Room) -> void:
	var t := game.room_tally
	if slab != null:
		t.event("trial_refused", game.time, {"cost": slab.cost, "hp": snappedf(game.player.hp, 0.1)})
		slab = null
	if room.kind == RunMap.Kind.ALTAR and not _spots.is_empty():
		t.event("altar", game.time, {"choice": "none", "max_hp": game.player.max_hp, "gold": gold})
		altar_used.emit(&"")
	if next_rooms.size() > 1:
		t.event("door", game.time, {"chosen": next_rooms.find(next), "doors": next_rooms.map(door_word), "node": next.id,
			"offered": next_rooms.map(func(r: RunMap.Room) -> int: return r.id)})


# ---------- E5: the Provação ----------

## The curse carried now on the fight's numbers (heal_pct, hurt_pct, enemy_speed_pct; the others where they act).
## The Juramentos (E6) multiply in: enemy speed, healing and the enemies' damage.
func _apply_curse() -> void:
	var vows := game.juramentos if game.juramentos else Juramentos.new()
	game.horde.speed_scale = maxf(0.1, 1.0 + trials.curse(&"enemy_speed_pct")) * vows.scale(&"enemy_speed_pct")
	game.player.heal_scale = maxf(0.0, 1.0 + trials.curse(&"heal_pct")) * vows.scale(&"heal_pct")
	game.player.hurt_scale = maxf(0.0, 1.0 + trials.curse(&"hurt_pct")) * vows.scale(&"enemy_damage_pct")


## The waves of a fight with the curse carried now: wave_extra more of each wave's first kind.
func _cursed_waves(waves: Array[Array]) -> Array[Array]:
	var extra := roundi(trials.curse(&"wave_extra"))
	var out: Array[Array] = []
	for w in waves:
		var copy: Array = w.duplicate()
		for i in extra:
			if not w.is_empty():
				copy.append(w[0])
		out.append(copy)
	return out


## A fight was won: one less to carry; when the curse turns, its blessing is his for the rest of the run.
func _fight_won() -> void:
	var done := trials.fight_won()
	if done == null:
		return
	var p := game.player
	var old_hp := game.boons.stat(&"max_hp")
	var old_magick := game.boons.stat(&"magick_max")
	game.boons.grant(Trials.blessing_mods(done))
	var more_hp := game.boons.stat(&"max_hp") - old_hp
	p.max_hp += more_hp
	p.heal(more_hp)
	var more_magick := game.boons.stat(&"magick_max") - old_magick
	p.magick.max_value += more_magick
	p.magick.gain(more_magick)
	_apply_curse()
	game.fx.hero_burst(&"light", Vector3(p.pos.x, 1.2, p.pos.y))
	game.hud.show_trial_won(done)
	game.room_tally.event("trial_turned", game.time, {"blessing": String(done.blessing.id), "rarity": done.rarity})
	found(MaterialPurse.MEMORY, &"trial", stage.memory_trial)  # a Provação won brings Memória home (Fatia 1)
	trial_turned.emit(done)


## After the reward of a fight: maybe the slab (Trials.roll), on free floor away from the doors, the pieces, the edges
## and the paladin (_free_spot); it may be stepped on SLAB_ARM seconds later.
const SLAB_HALF := 1.2
const SLAB_ARM := 1.2
const SLAB_CLEAR := 4.0
const TRIAL_COLOR := Color(0.52, 0.36, 0.78)


## DV-1: the slab shows where the graph put the "?" (RunMap.Room.trial; its dice were thrown when the map was drawn),
## when it still may (Trials.open_at), and the "?" turns into the room it is (RunMap.reveal).
func _roll_slab() -> void:
	if not room.trial or map.depth >= stage.rooms or not trials.open_at(stage, map.depth, map.fights_left()):
		return
	var at: Variant = _free_spot(SLAB_CLEAR)
	if at == null:
		at = _free_spot(SLAB_CLEAR * 0.6)
	if at == null:
		return
	var cost := Trials.cost(stage, map.depth)
	slab = {"at": at, "cost": cost, "armed": SLAB_ARM}
	_slab_node = _slab_marker(at, cost)
	map.reveal(room)
	_bot_trial = Trials.bot_accepts(stage, map.depth, game.player.hp, game.player.max_hp)
	game.room_tally.event("trial_shown", game.time, {"cost": cost, "hp": snappedf(game.player.hp, 0.1),
		"max_hp": game.player.max_hp})
	trial_slab_shown.emit(at, cost)


## A spot of floor at least `clear` meters from the edges, the pieces, the doors and the paladin, reached from where he
## stands, the nearest to the middle of the room (null: none).
func _free_spot(clear: float) -> Variant:
	var a := game.arena
	var f := a.shape()
	var box := f.bounds()
	var best: Variant = null
	var best_d := INF
	for x in range(ceili(box.position.x), floori(box.end.x) + 1):
		for z in range(ceili(box.position.y), floori(box.end.y) + 1):
			var p := Vector2(x, z)
			if f.edge_distance(p) < clear or a.overlaps(p, clear) or p.distance_to(game.player.pos) < clear:
				continue
			var near_door := false
			for e in a.exits:
				if e.distance_to(p) < clear + 2.0:
					near_door = true
			for zr in a.exit_zones:
				if zr.grow(clear).has_point(p):
					near_door = true
			if near_door or not a.nav.walkable(p) or not a.nav.reachable(p, game.player.pos):
				continue
			var d := p.distance_to(a.middle)
			if d < best_d:
				best_d = d
				best = p
	return best


## Stepping on the slab: with more life than it asks, he pays and goes down into the Provação's chamber; without, a
## word once.
func _step_slab(dt: float) -> void:
	if slab == null:
		return
	slab.armed = maxf(0.0, float(slab.armed) - dt)
	var d: Vector2 = game.player.pos - (slab.at as Vector2)
	var cost := int(slab.cost)
	if _slab_sign != null:
		# the price, or "Vida insuficiente" while he has not life enough (spec 5.1)
		_slab_sign.set_short(not Trials.can_pay(stage, map.depth, game.player.hp), T.t(&"trial_short"), T.t(&"trial_cost", {"n": cost}))
	if slab.armed > 0.0 or absf(d.x) > SLAB_HALF or absf(d.y) > SLAB_HALF:
		return
	if not Trials.can_pay(stage, map.depth, game.player.hp):
		if not slab.get("warned", false):
			slab.warned = true
			game.hud.show_notice(T.t(&"trial_short"), 1.5)
		return
	var p := game.player
	p.hp -= cost
	game.fx.word(Vector3(p.pos.x, 3.0, p.pos.y), "-%d" % cost, Color(0.82, 0.76, 0.92))
	game.room_tally.event("trial_paid", game.time, {"cost": cost, "hp": snappedf(p.hp, 0.1)})
	slab = null
	trial_entered.emit(cost)
	phase = Phase.LEAVING
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func() -> void: _enter(map.trial(map.depth)))


## The slab on the floor: the cracked slab of the Provação's look (TrialLook.entry_slab, spec 5.1), the ivory thread
## of light that holds it as it rises, and its sign ("Provação", "Pisar custa n de vida") with what it is and how to
## refuse it under the price (T5: "Uma Bênção forte, com uma maldição", "Para recusar, não pise").
const SLAB_THREAD := Color(0.95, 0.92, 0.85)
const SLAB_THREAD_RADIUS := 0.125
const SLAB_THREAD_HEIGHT := 14.0


func _slab_marker(at: Vector2, cost: int) -> Node3D:
	var root := Node3D.new()
	add_child(root)
	TrialLook.entry_slab(root, at)
	game.column(at, SLAB_THREAD, SLAB_THREAD_RADIUS, SLAB_THREAD_HEIGHT, SLAB_ARM)
	var sign := DoorSign.make(T.t(&"room_trial"), T.t(&"trial_cost", {"n": cost}), DoorGlyph.Kind.TRIAL)
	sign.add_note(T.t(&"trial_slab_offer") + "\n" + T.t(&"trial_slab_refuse"))
	sign.position = Vector3(at.x, MARK_SIGN_Y, at.y)
	root.add_child(sign)
	_slab_sign = sign
	return root


## The Provação's chamber: stepping before the block (TRIAL_SPOT, on his way from the stairs of the south west) opens
## its cards (EventChoice.open_trial, spec 5.2), its doors shut until one is taken.
const TRIAL_SPOT := Vector2(-1.5, 1.5)


func _build_trial() -> void:
	phase = Phase.EVENT
	trial_cards = trials.offers(_rng, stage.trial_cards, stage.trial_rarity_chance, map.fights_left())
	_spots.append({"at": TRIAL_SPOT, "away": true, "node": _marker(TRIAL_SPOT, RunMap.Reward.NONE,
		T.t(&"room_trial") + "\n" + T.t(&"trial_step"), RunMap.Kind.TRIAL, DoorGlyph.Kind.TRIAL)})
	game.room_tally.event("trial_offered", game.time, {"cards": trial_cards.map(func(c: Trials.Card) -> Dictionary:
		return {"blessing": String(c.blessing.id), "rarity": c.rarity, "curse": String(c.curse.id), "encounters": c.encounters})})
	trial_offered.emit(trial_cards)


## Takes card i of the Provação (what its card screen calls, EventChoice.picked; the robot and --autopick take the
## first): its curse is carried from the next fight on, the doors open.
func take_trial(i: int) -> void:
	if room == null or room.kind != RunMap.Kind.TRIAL or phase != Phase.EVENT or i < 0 or i >= trial_cards.size():
		return
	var c := trial_cards[i]
	trials.take(c)
	_apply_curse()
	_clear_spots()
	var p := game.player
	game.fx.ring(p.pos, 3.0, TRIAL_COLOR, 0.5)
	game.room_tally.event("trial_taken", game.time, {"blessing": String(c.blessing.id), "rarity": c.rarity,
		"curse": String(c.curse.id), "encounters": c.encounters, "card": i})
	_to_look(&"settle")
	trial_taken.emit(c)
	_open_doors()


# ---------- E5: the Altar Esquecido ----------

## The worn slab before the altar's step (spec 6.3), where its choice opens.
const ALTAR_SPOT := Vector2(0.0, -3.8)
const ALTAR_COLOR := Color(0.95, 0.85, 0.65)


## The altar's trades (Altar.options) open from the worn slab before its step (EventChoice.open_altar).
func _build_altar() -> void:
	altar_options = Altar.options(stage, gold, game.player.max_hp, game.boons.can_grow(), game.player.magick.max_value)
	_spots.append({"at": ALTAR_SPOT, "away": true, "node": _marker(ALTAR_SPOT, RunMap.Reward.NONE,
		T.t(&"room_altar") + "\n" + T.t(&"altar_step"), RunMap.Kind.ALTAR, DoorGlyph.Kind.ALTAR)})


## Takes the altar's trade (Altar.Option): pays and gives; false when it cannot be taken now.
func take_altar(option: int) -> bool:
	if room == null or room.kind != RunMap.Kind.ALTAR or _spots.is_empty():
		return false
	altar_options = Altar.options(stage, gold, game.player.max_hp, game.boons.can_grow(), game.player.magick.max_value)
	if option < 0 or option >= altar_options.size() or not altar_options[option].ok:
		return false
	var p := game.player
	match option:
		Altar.Option.LIFE:
			game.life_bonus -= stage.altar_life_cost
			p.max_hp -= stage.altar_life_cost
			p.hp = minf(p.hp, p.max_hp)
			game.open_grow_choice()
		Altar.Option.CANDLES:
			gold -= stage.altar_gold_cost
			p.magick.max_value += stage.altar_magick
			p.magick.gain(stage.altar_magick)
			game.fx.word(Vector3(p.pos.x, 3.0, p.pos.y), "+%d %s" % [int(stage.altar_magick), T.t(&"hud_magick")], Color(0.5, 0.75, 1.0))
	game.room_tally.event("altar", game.time, {"choice": String(Altar.IDS[option]), "max_hp": p.max_hp, "gold": gold})
	_clear_spots()
	_to_look(&"kindle")
	Audio.play(&"heal")
	altar_used.emit(Altar.IDS[option])
	return true


# ---------- E5: the spot that opens the choice (the trial's cards, the altar's trades) ----------

## Stepping on the spot opens its choice once; stepping off and on again opens it again (the altar left untouched).
func _step_spots() -> void:
	if _spots.is_empty():
		return
	var s: Dictionary = _spots[0]
	if game.player.pos.distance_to(s.at) >= TOUCH:
		s.away = true
		return
	if not s.away:
		return
	s.away = false
	if room.kind == RunMap.Kind.TRIAL:
		_choose_trial()
	elif room.kind == RunMap.Kind.ALTAR:
		_choose_altar()


## Whether the choices are made with no screen: the robot and the captures (--autopick).
func _no_screen() -> bool:
	return game.bot != null or Dev.has("autopick")


## The Provação's cards on their screen; the robot and --autopick take the first.
func _choose_trial() -> void:
	if _no_screen():
		# the robot weighs the curses against its plan (E6); --autopick takes the first, for captures
		take_trial(Trials.bot_card(trial_cards, map.depth < stage.rooms) if game.bot != null else 0)
		return
	var screen := EventChoice.new()
	game.open_screen(screen)
	screen.open_trial(trial_cards)
	screen.picked.connect(func(i: int) -> void:
		game.close_screen()
		take_trial(i))


## The altar's trades on their screen (a last card takes nothing); the robot and --autopick take Altar.bot_choice.
func _choose_altar() -> void:
	altar_options = Altar.options(stage, gold, game.player.max_hp, game.boons.can_grow(), game.player.magick.max_value)
	if _no_screen():
		var pick := Altar.bot_choice(altar_options, game.player.max_hp, gold)
		if pick >= 0:
			take_altar(pick)
		return
	var screen := EventChoice.new()
	game.open_screen(screen)
	screen.open_altar(altar_options)
	screen.picked.connect(func(option: int) -> void:
		game.close_screen()
		if option != EventChoice.NONE:
			take_altar(option))


func _clear_spots() -> void:
	for s in _spots:
		if is_instance_valid(s.node):
			(s.node as Node3D).queue_free()
	_spots.clear()


## Tells the arena's look (the environment artist's) a moment of an event, if it listens: settle (TrialLook, the
## veins dim after the choice), kindle (AltarLook, the candles light after the trade).
func _to_look(what: StringName) -> void:
	var look := game.arena.look
	if look != null and look.has_method(what):
		look.call(what)


## The floor that strikes on its own in this fight, by its kind (RuneFloor for the runes' grid, PlateFloor for the
## slabs of RP-06, asleep before the descent reaches HazardDef.from_progress).
func _start_hazard(layout: RoomLayout) -> void:
	if layout == null or layout.hazard == null:
		return
	if layout.hazard.kind == HazardDef.Kind.PLATES:
		plates = PlateFloor.new(game, layout.hazard, EncounterGen.progress(stage, room.depth) >= layout.hazard.from_progress)
	else:
		runes = RuneFloor.new(game, layout.hazard, _rng)


func _stop_runes() -> void:
	if plates != null:
		plates.stop()
		game.room_tally.hazard(plates.enemy_damage, plates.kills, plates.hazard.fired, String(Ground.PLATE_SOURCE),
			plates.tally())
		plates = null
	if runes == null:
		return
	runes.stop()
	game.room_tally.hazard(runes.enemy_damage, runes.kills, runes.hazard.fired)
	runes = null


# ---------- the shop ----------

## The items of each shop group (C13-04: ShopGroup.count of each), on pedestals in a row; a pomegranate (or its slice)
## only when a gift can grow.
## The shop's items stand in a row level on the screen (along the camera's right, Feel.cam_yaw), STEP apart: at 4 m
## the signs of five items ("Fortalecer ao acaso" and a price with "faltam" the widest, about 150 px at 720 lines)
## keep about 20 px between them at 1280 x 720 and at 1920 x 1080 (measured: docs/gallery/e3/ui/shop_real_*). The row's
## middle sits SHOP_SHIFT m to the left of the hall's, toward the landing the hero comes in by, so the last sign is on
## screen as he arrives.
const SHOP_STEP := 5.0
const SHOP_SHIFT := 3.5
## The word of each shop group (StageDef.shop_groups, in order), over the item's name.
const SHOP_GROUP_KEY: Array[StringName] = [&"shop_group_boon", &"shop_group_care", &"shop_group_growth"]
## Height over the floor of the point a marker's sign stands on.
const MARK_SIGN_Y := 2.7


func _build_shop() -> void:
	var can_grow := game.boons.can_grow()
	var valid := func(item: int) -> bool:
		return can_grow or (item != RunMap.Reward.POM and item != RunMap.Reward.POM_SLICE)
	var picks: Array[Dictionary] = []
	for g in stage.shop_groups.size():
		var group := stage.shop_groups[g]
		for i in group.pick_all(_rng, valid):
			picks.append({"item": group.items[i] as RunMap.Reward, "price": group.prices[i], "group": g})
	var n := picks.size()
	var right := Feel.screen_to_floor(Vector2.RIGHT, Feel.live().cam_yaw)
	for k in n:
		var p := picks[k]
		var at := right * ((k - (n - 1) * 0.5) * SHOP_STEP - SHOP_SHIFT)
		p.at = at
		p.node = _marker(at, p.item, "")
		# the group's word over the name, the price under it (C13-04); a group named as its only item says it once
		var name_text := T.t(RunMap.REWARD_KEY[p.item])
		var group_text := T.t(SHOP_GROUP_KEY[p.group]) if p.group < SHOP_GROUP_KEY.size() else ""
		var sign := DoorSign.shop(name_text, p.price, "" if group_text == name_text else group_text, DoorGlyph.of_reward(p.item))
		sign.position.y = MARK_SIGN_Y
		sign.set_gold(gold)
		(p.node as Node3D).add_child(sign)
		p.sign = sign
		_pedestals.append(p)
	# the stylized look dresses the row (room redesign lot A 3.3; nothing of it blocks)
	var points: Array[Vector2] = []
	for p in picks:
		points.append(p.at)
	game.arena.dress_shop(points)


## What the shop shows now, for a screen (one entry per item left: item (RunMap.Reward), price, group (index in
## StageDef.shop_groups), at (on the floor), affordable).
func shop() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for p in _pedestals:
		out.append({"item": p.item, "price": p.price, "group": p.group, "at": p.at, "affordable": gold >= int(p.price)})
	return out


## Interact at an item buys it when there is gold for it (C19, Q-13: standing on it no longer does).
func _step_shop(use: bool) -> void:
	for p in _pedestals.duplicate():
		if game.player.pos.distance_to(p.at) >= TOUCH or not use:
			continue
		if gold < p.price:
			game.hud.show_notice(T.t(&"notice_no_gold"), 1.5)
			continue
		gold -= p.price
		game.room_tally.bought(RunMap.Reward.keys()[p.item].to_lower(), p.price)
		(p.node as Node3D).queue_free()
		_pedestals.erase(p)
		_give(p.item)


## The order in which the bot picks a door, as a player would (E3: before it took the first door, so the rewards it
## got were the deck's draw, not a choice): the fountain, a Blessing, a pomegranate, a heart, gold, Magia.
const BOT_PREFERENCE: Array[RunMap.Reward] = [RunMap.Reward.BOON, RunMap.Reward.POM, RunMap.Reward.HEART, RunMap.Reward.GOLD, RunMap.Reward.MAGICK]
## The doors of a material for home (Rejogabilidade, Fatia 1, MAP-04's taste): between the heart and gold, Memória a
## little before Prata; never over the power of this descent (a Blessing, a pomegranate, a heart).
const BOT_MATERIAL_RANK := {RunMap.Reward.MEMORY: 2.4, RunMap.Reward.SILVER: 2.6}


## A reward's place in the robot's taste (BOT_PREFERENCE, BOT_MATERIAL_RANK; -1 for none of them).
static func _bot_rank(r: RunMap.Reward) -> float:
	return float(BOT_MATERIAL_RANK.get(r, BOT_PREFERENCE.find(r)))


## Where the altar's door stands in that order (E5): after a Blessing and a pomegranate (its trade grows a Blessing).
const BOT_ALTAR_RANK := 1.5


## The door the bot walks through (index in doors). altar_useful: it would trade something there (E6: before it walked
## into the altar with nothing to trade, a room lost); otherwise the altar comes last. life: its share of its most
## life (C17, QW-112: it took the fountain with full life, a Blessing's door lost; now only below BOT_FOUNTAIN_BELOW,
## otherwise the fountain comes after every reward).
const BOT_FOUNTAIN_BELOW := 0.8


## DV-1 (MAP-04), the robot reads the map as a player would: the same taste for the door in front of it (its rank),
## plus BOT_AHEAD of the best way on after that door (what the rooms on it give, in the same order; a fountain ahead
## worth two Blessings, BOT_FOUNTAIN_AHEAD: it keeps one in reach for when it is hurt). The one-step rule first tried (a fountain kept in reach below 80% of life)
## left the robot without a fountain in 12 of 24 descents (it drank in 19 of 24 before the map) and won 20 of 24.
## map: the descent's graph; null: the doors alone, as before the map.
const BOT_AHEAD := 1.0
const BOT_FOUNTAIN_AHEAD := 12.0


static func bot_door(doors: Array[RunMap.Room], altar_useful: bool = true, life: float = 0.0, map: RunMap = null) -> int:
	var best := 0
	var top := -INF
	var memo := {}
	for i in doors.size():
		var rank := _bot_rank(doors[i].reward)
		if doors[i].kind == RunMap.Kind.FOUNTAIN:
			rank = -1.0 if life < BOT_FOUNTAIN_BELOW else BOT_PREFERENCE.size() + 0.5
		elif doors[i].kind == RunMap.Kind.ALTAR:
			rank = BOT_ALTAR_RANK if altar_useful else BOT_PREFERENCE.size() + 1.0
		elif rank < 0.0:
			rank = BOT_PREFERENCE.size()
		var score := -rank
		if map != null:
			score += BOT_AHEAD * bot_way(map, doors[i], altar_useful, memo)
		if score > top:
			top = score
			best = i
	return best


## The most the robot sees to gain on any way after room r (r left out): each room's worth by its taste (a Blessing
## BOT_PREFERENCE.size(), down to 1 for Magia; a fountain BOT_FOUNTAIN_AHEAD; a useful altar between the pomegranate
## and the heart; the shop and Morvath nothing).
static func bot_way(map: RunMap, r: RunMap.Room, altar_useful: bool = true, memo: Dictionary = {}) -> float:
	if memo.has(r.id) and r.id >= 0:
		return memo[r.id]
	var most := 0.0
	for id in r.next:
		var n := map.at(id)
		most = maxf(most, _bot_worth(n, altar_useful) + bot_way(map, n, altar_useful, memo))
	if r.id >= 0:
		memo[r.id] = most
	return most


static func _bot_worth(r: RunMap.Room, altar_useful: bool) -> float:
	match r.kind:
		RunMap.Kind.FOUNTAIN:
			return BOT_FOUNTAIN_AHEAD
		RunMap.Kind.ALTAR:
			return BOT_PREFERENCE.size() - BOT_ALTAR_RANK if altar_useful else 0.0
		RunMap.Kind.SHOP, RunMap.Kind.BOSS:
			return 0.0
	var rank := _bot_rank(r.reward)
	return float(BOT_PREFERENCE.size()) - rank if rank >= 0.0 else 0.0


## The altar's trade the robot would make now (Altar.bot_choice; -1: none).
func _bot_altar_pick() -> int:
	return Altar.bot_choice(Altar.options(stage, gold, game.player.max_hp, game.boons.can_grow(), game.player.magick.max_value), game.player.max_hp, gold)


## Where the bot should walk when the room has no fight left (null: stay).
func bot_goal() -> Variant:
	if phase == Phase.REWARD and _reward_node != null:
		return _reward_at
	if phase == Phase.EVENT and not _spots.is_empty():
		# the Provação's chamber: the spot before the block (the robot takes Trials.bot_card)
		return _spots[0].at
	if phase == Phase.OPEN:
		for p in _pedestals:
			if gold >= p.price:
				return p.at
		if slab != null and _bot_trial and float(slab.armed) <= 0.0:
			return slab.at
		if room.kind == RunMap.Kind.ALTAR and not _spots.is_empty():
			var pick := _bot_altar_pick()
			if pick >= 0 and _spots[0].away:
				return _spots[0].at
		if not game.arena.exits.is_empty():
			# the foot of its stairs (stepping on them leaves the room)
			return game.arena.door_goal(clampi(bot_door(next_rooms, _bot_altar_pick() >= 0, game.player.hp / maxf(game.player.max_hp, 1.0), map),
				0, game.arena.exits.size() - 1))
	return null


# ---------- markers ----------

## How bright a door's or a reward's gem is: its colour lifted this much, no channel past GEM_CAP (GP-01 of cycle
## C12c: at 2.2 times its colour it went past the glow threshold and bloomed yellow; it glows by its light), and then
## no channel past ScreenTone.SAFE on the screen (B-1: at 1.0 the exposure and the saturation still took it to 255).
const GEM_LIFT := 2.2
const GEM_CAP := 1.0


## The gem's colour: lifted by GEM_LIFT, then scaled down (hue kept) until its strongest channel is GEM_CAP and its
## strongest on the screen ScreenTone.SAFE.
static func gem_color(c: Color) -> Color:
	var lifted := Color(c.r * GEM_LIFT, c.g * GEM_LIFT, c.b * GEM_LIFT)
	var top := maxf(lifted.r, maxf(lifted.g, lifted.b))
	if top > GEM_CAP:
		var k := GEM_CAP / top
		lifted = Color(lifted.r * k, lifted.g * k, lifted.b * k)
	return ScreenTone.fit(lifted)


## A floating sign over the floor: a ring of light and a word (what a door leads to, or a reward to take).
## glyph: the pictogram left of the sign's name (E5, DoorGlyph); a reward's sign also carries the reward's own mark
## (stage 1A, DoorGlyph.of_reward), the glyph then going by the line under the name.
func _marker(at: Vector2, reward: RunMap.Reward, text: String, kind: RunMap.Kind = RunMap.Kind.COMBAT,
		glyph: DoorGlyph.Kind = DoorGlyph.Kind.NONE) -> Node3D:
	var root := Node3D.new()
	root.position = Vector3(at.x, 0, at.y)
	add_child(root)
	var color := _reward_color(reward) if reward != RunMap.Reward.NONE else _kind_color(kind)
	# the reward's medallion over its pedestal (RewardGem, QW-106): it turns, the room's lights shade it
	_gems.append(RewardGem.make(root, reward, kind, color))
	if text != "":
		# the reward's name in gold, a second line (the shop's price) in pale under it (UI-01)
		var lines := text.split("\n", true, 1)
		var sign := DoorSign.make(lines[0], lines[1] if lines.size() > 1 else "", glyph, DoorGlyph.of_reward(reward))
		sign.position.y = MARK_SIGN_Y
		root.add_child(sign)
	return root


func _clear_props() -> void:
	for c in get_children():
		c.queue_free()
	_reward_node = null
	_gems.clear()
	_pedestals.clear()
	_door_labels.clear()


static func _reward_color(r: RunMap.Reward) -> Color:
	match r:
		RunMap.Reward.BOON:
			return Color(1.0, 0.82, 0.38)
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return Color(1.0, 0.4, 0.35)
		RunMap.Reward.HEART:
			return Color(1.0, 0.3, 0.45)
		RunMap.Reward.MAGICK:
			return Color(0.45, 0.65, 1.0)
		RunMap.Reward.GOLD:
			return GOLD_COLOR
		RunMap.Reward.HEAL:
			return Color(0.5, 1.0, 0.6)
		RunMap.Reward.SILVER:
			return SILVER_COLOR
		RunMap.Reward.MEMORY:
			return MEMORY_COLOR
	return Color.WHITE


static func _kind_color(k: RunMap.Kind) -> Color:
	match k:
		RunMap.Kind.MINIBOSS:
			return Color(1.0, 0.22, 0.3)
		RunMap.Kind.FOUNTAIN:
			return Color(0.6, 1.0, 0.8)
		RunMap.Kind.SHOP:
			return GOLD_COLOR
		RunMap.Kind.BOSS:
			return Color(0.7, 0.3, 1.0)
		RunMap.Kind.TRIAL:
			return TRIAL_COLOR
		RunMap.Kind.ALTAR:
			return ALTAR_COLOR
	return Color.WHITE
