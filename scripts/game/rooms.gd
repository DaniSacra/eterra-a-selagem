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

## SW-O3: the Antessala's slabs were crossed (the hero passed their line) and a vase of the room was broken (the
## objective's rules read them).
signal plates_crossed
signal broke_one

const STAGE := "res://data/stages/catacombs.tres"
## SW-O1: the arrival's scene (the environment artist's; the guided first descent plays it once, in the Antessala).
const ARRIVAL_SCENE := "res://scripts/game/arrival_scene.gd"
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
	if _at_vein() or _at_relic():
		return true
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
## Fatia 2 (provisional, for the art-director): an Encanto's door in the Emeth's green, paler; a Psalm's old gold, the
## PsalmDef's own colour (vfx_pass_spec.md 4: the lilac went, too near Morvath's violet).
const ENCHANT_COLOR := Color(0.45, 0.85, 0.6)
const PSALM_COLOR := Color(0.78, 0.62, 0.34)
## The light that falls on what is taken (vfx_pass_spec.md 6, Daniel's ask; the piece is the technical-artist's
## RewardShaft): on the room's reward once the room is won (it waits RewardShaft.WAIT, the end of the last kill's slow
## motion), on every item of the shop at once (RewardShaft.SHOP_CAN when the gold reaches it, SHOP_CANNOT when not,
## following the gold) and on the fountain while it has water (Game.spawn_fountain). Taking the thing lifts it.

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
			if is_instance_valid(p.get("shaft")):
				(p.shaft as RewardShaft).set_strength(shop_light(gold >= int(p.price)))
## The kinds of the rooms won in this run (fights and the guardian's), for the Mastery (Game.mastery_gain).
var won: Array[RunMap.Kind] = []
## The gold this fight can still give, dropped by the enemies that fall (C13-04; null outside a fight).
var purse: GoldPurse
var _waves: Array[Array] = []
## C1e: the modifiers still to give, by kind (EncounterGen.Fight.mods): the next spawn of the kind takes the first.
var _mods: Dictionary = {}
var _queue: Array[StringName] = []
var _wave := -1
## SW-R3: heads that rose in this room; from LATE_AFTER on the late zones are open even in the first wave (a horde has no second one).
var _rose := 0
## SW-R1: the room is a horde: the reserve rises behind the first wave as soon as its queue is empty, with no wait for the floor to clear.
var _horde := false
const LATE_AFTER := 4
var _spawn_t := 0.0
var _wave_wait := 0.0
var _cap := 4
var _reward_at := Vector2.ZERO
var _reward_node: Node3D
## The room's reward's light (vfx_pass_spec.md 6).
var _reward_shaft: RewardShaft
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
## RP-11: the bands that strike in turn (the chain of the bridge), or null.
var bands: BandFloor
## RP-09: the room's cracked columns that topple, or null.
var columns: ColumnFloor
## A1: RP-20 the stones from the vault, RP-12 the oil urns (null: none in this fight).
var drops: DropFloor
var urns: UrnFloor
## AT-H2, AT-H3: a second PLATES hazard beside the room's first (the niche's skeleton beside the Cripta B's slabs, the
## hostile plant beside the Jardim B's root), or null.
var plates_also: PlateFloor
## RD2-10: the wall the knight's charge will end against, marked on the floor (the knight's hall), or null.
var wall_mark: WallMark
var _slab_node: Node3D
var _slab_sign: DoorSign
## The spot before the trial's block and before the altar's step where its choice screen opens: {at, node, away (he
## has stepped off since it last opened)}; empty once the choice is made.
var _spots: Array[Dictionary] = []
## The robot's mind on the slab of this room (decided once when it shows).
var _bot_trial := false
var _rng: RandomNumberGenerator
## SW-O4: the guided first descent (FirstDescent.active at setup): its data, the room's data (FirstRoomDef; null off the
## guided one) and the numbers its report keeps (seconds of play at the Antessala's door and at the first Blessing; -1: not yet).
var first_def: FirstDescentDef
var first_room: FirstRoomDef
var ante_s := -1.0
var first_boon_s := -1.0
## SW-O3, the Antessala: whether the slabs were crossed, a vase broken, and the arrival's scene in play (null: none).
var ante_crossed := false
var ante_broke := false
var _arrival: Node
var _arrival_t := 0.0
var _ante_idle := 0.0
var _ante_last := Vector2.INF
## The life share the room's enemies are born with (FirstRoomDef.hp_scale; 1.0 off the guided descent).
var _hp_scale := 1.0
var _fade: ColorRect
## The fade running now (_fade_tween).
var _fading: Tween
## The floating signs turn slowly.
var _gems: Array[Node3D] = []


func setup(g: Game, rng: RandomNumberGenerator) -> void:
	game = g
	_rng = rng
	stage = load(STAGE)
	first_def = FirstDescentDef.live() if g.first_run else null
	if first_def != null:
		# SW-O4: the guided first descent: its own stage and graph, no Ofício, Juramento nor shorter descent in it
		stage = FirstDescent.stage_for(stage, first_def)
	elif Dev.has("short"):
		stage = short_stage(stage, 4)
	elif Dev.has("medium"):
		stage = short_stage(stage, 6)
	if first_def == null and g.oficios != null and not g.oficios.works.is_empty():
		stage = Vendor.stage_for(stage, Vendor.load_catalog(), g.oficios.works)  # Fatia 3: the Obras made
	if first_def == null and g.juramentos:
		stage = g.juramentos.stage_for(stage)  # E6: more elites, dearer shop
	trials = Trials.new(Trials.load_catalog())
	sign_silver = stage.silver_elite
	var forced := -1
	if Dev.has("arena"):
		# dev: --arena=id makes the opening room that arena (--variant=n dresses it)
		for i in stage.layouts.size():
			if String(stage.layouts[i].id) == Dev.arg("arena"):
				forced = i
	if first_def != null:
		map = FirstDescent.map(stage, first_def, hash([_rng.seed, MAP_SALT]), FirstDescent.arrival_only())
	else:
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
	st.miniboss2_depth_min = 0  # (one guardian: there is no room for two)
	st.rest_after_guardian = false  # (SW-R2: the fixed doors and the rest are the long descent's)
	st.fixed_rewards = {}
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
	var m := RunMap.new(st, hash([_rng.seed, MAP_SALT]), forced, trials.shortest_curse(), game != null and game.boons.stat(&"traveler") > 0.0)
	var of := game.oficios if game != null else null
	if of != null and game.oficios_def != null:
		# Ofícios, Roteiro A: the veins and the head's room, on dice of their own (the map stays as it was)
		var d := game.oficios_def
		of.marked = m.mark_finds(d.head if of.wants_head else &"", d.find_depth_min, d.find_depth_max, d.vein_arenas)
	return m


func start() -> void:
	await _enter_first(map.first())


## The descent's first room: with a screen built on black over frames like any other (QA P1-1: the opening frame
## was 1,9 s on the iGPU), the caller awaiting it; without one at once, as before (the same RESULT).
func _enter_first(next: RunMap.Room) -> void:
	if hold_frames() <= 0:
		_enter(next)
		return
	_fade.color.a = 1.0
	_hold = 1 << 20
	await _enter_with(next, _frame_drawn)


## Dev: jumps straight to a room kind (--start=boss|miniboss|shop|fountain|trial|altar): the first room of that kind
## in the graph (the altar's graph is drawn again with the altar sure to come; the trial's chamber as if a fight of
## depth 3 had shown its slab, its doors those of that room).
func start_at(kind: RunMap.Kind) -> void:
	if Dev.has("gold"):
		gold = int(Dev.num("gold", 0))  # (--gold=N: the gold to start at, for captures of the shop's lights)
	if kind == RunMap.Kind.ALTAR and stage.altar_layout != null:
		var st: StageDef = stage.duplicate()
		st.altar_chance = 1.0
		map = new_map(st, map.forced_layout)
	if kind == RunMap.Kind.TRIAL:
		var at := map.layer(3).filter(func(r: RunMap.Room) -> bool: return r.kind == RunMap.Kind.COMBAT)
		map.enter(at[0] if not at.is_empty() else map.layer(3)[0])
		next_rooms = map.doors()
		_prepare(next_rooms)
		await _enter_first(map.trial(map.depth))
		return
	for r in map.nodes:
		# --start=shop is the last shop before Morvath, never a route shop (DV-2)
		if r.kind == kind and not (kind == RunMap.Kind.SHOP and map.is_route_shop(r)):
			if kind == RunMap.Kind.MINIBOSS and Dev.has("guardian"):
				# (--guardian=knight|priest_elder: which guardian, for the bot; the room of his own house)
				var want := StringName(Dev.arg("guardian"))
				if r.guardian != want:
					continue
			await _enter_first(r)
			return
	await _enter_first(map.first())


func depth() -> int:
	return map.depth


func step(dt: float) -> void:
	_step_prompt()
	_step_vein(dt)
	_step_relic()
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
			if room.kind == RunMap.Kind.ANTE:
				_step_ante(dt)
			var door := game.arena.exit_at(game.player.pos)
			if door >= 0 and door < next_rooms.size() and use and not (first_def != null and FirstDescent.arrival_only()):
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
	if _at_relic():
		return &"relic"
	if _at_vein():
		return &"vein" if _vein.state == VeinFloor.State.OPEN else &"vein_note"
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
			prompt.under = true
			prompt.pressed.connect(use)
			add_child(prompt)
	if prompt != null:
		# under the thing used, never on the hero (benchmark_hades2_ui.md P0-1)
		var spot := use_spot()
		prompt.position = Vector3(spot.x, 0.0, spot.y)
		prompt.hero_at = Vector3(game.player.pos.x, 0.0, game.player.pos.y)
		if kind == &"shop":
			# a price out of reach says what is missing by the key, not on the sign (P1-3)
			var short := _short_of(spot)
			prompt.prompt.text = T.t(&"shop_use_short", {"n": short}) if short > 0 else StationSign.verb(kind)


## The foot of what the paladin stands at to use (use_kind): the reward, the shop item, the door's medallion; his own
## feet when nothing.
func use_spot() -> Vector2:
	if _at_relic():
		return _relic.at
	if _at_vein():
		return _vein.at
	match use_kind():
		&"reward":
			return _reward_at
		&"shop":
			for p in _pedestals:
				if game.player.pos.distance_to(p.at) < TOUCH:
					return p.at
		&"door":
			return game.arena.door_label(game.arena.exit_at(game.player.pos))
	return game.player.pos


## The gold missing for the shop item at a spot (0: enough, or no item there).
func _short_of(spot: Vector2) -> int:
	for p in _pedestals:
		if p.at == spot:
			return maxi(int(p.price) - gold, 0)
	return 0


# ---------- entering ----------

func _exit_tree() -> void:
	Music.ambience(&"")  # back to the title: no room, no air


func _enter(next: RunMap.Room) -> void:
	_enter_with(next)


## wait: on a screen, the room's build is spread over the black frames (Game.rebuild_room with it, QA P1-1).
func _enter_with(next: RunMap.Room, wait := Callable()) -> void:
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
	first_room = _first_room_of(room)
	_hp_scale = first_room.hp_scale if first_room != null else 1.0
	if layout != null:
		if Dev.has("variant") and room.depth == 1 and first_def == null:
			variant = int(Dev.num("variant", 0))
		layout = layout.variant(variant)
	var exits := 0 if room.kind == RunMap.Kind.BOSS else next_rooms.size()
	await game.rebuild_room(layout, exits, 1406 + room.depth * 31 + room.layout, wait)
	if not is_inside_tree():
		return
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
	if first_def != null and room.depth == 1 and ante_s < 0.0:
		ante_s = snappedf(game.time, 0.1)  # (SW-O3: the seconds from the start to the Antessala's door)
	game.room_tally.enter(room.depth, String(game.arena.id), game.player.hp, game.time, room.kind == RunMap.Kind.BOSS,
		variant, gold, game.boons.owned().size(), room.id)
	if room.kind == RunMap.Kind.SHOP:
		game.room_tally.shop_entered(gold, map.is_route_shop(room))
	_queue.clear()
	_waves.clear()
	_mods.clear()
	_wave = -1
	_rose = 0
	_horde = false
	_wave_wait = START_DELAY
	# nobody stands past the stage's ceiling, summons included; a fight lowers it to its tier's most
	game.horde.alive_cap = stage.alive_cap
	purse = null
	# the rooms' music (E4-06): the fight's layer comes in for a fight and goes when it is won; Morvath has his own
	if room.kind != RunMap.Kind.BOSS:
		var fighting := room.kind in [RunMap.Kind.COMBAT, RunMap.Kind.MINIBOSS, RunMap.Kind.TRIAL]
		Music.room_depth = room.depth
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
	ante_crossed = false
	ante_broke = false
	_ante_idle = 0.0
	_ante_last = Vector2.INF
	if wait.is_valid():
		await wait.call()  # (the room's own pieces, a shop's or an event's, on a black frame of their own)
		if not is_inside_tree():
			return
	match room.kind:
		RunMap.Kind.COMBAT:
			var fight := room.fight if room.fight != null else EncounterGen.generate(stage, room.depth, _defs, _rng, 1.0, layout)
			_waves = _cursed_waves(game.juramentos.more_waves(fight.waves) if game.juramentos else fight.waves)
			_mods = fight.mods.duplicate(true)
			game.room_tally.note("budget", fight.budget)
			_horde = fight.mode == EncounterGen.Mode.HORDE
			game.room_tally.note("mode", "horde" if _horde else "waves%d" % fight.waves.size())
			var rating := 0.0
			for w: Array in fight.waves:
				for id: StringName in w:
					rating += (_defs[id] as EnemyDef).rating if _defs.has(id) else 0.0
			purse = GoldPurse.for_fight(stage, room.depth, rating, _rng)
			_cap = fight.cap
			game.horde.alive_cap = fight.ceiling
			phase = Phase.FIGHT
			if first_room == null or first_room.hazards:
				_start_hazard(layout)
		RunMap.Kind.MINIBOSS:
			var guardian: Array[StringName] = [room.fight.kinds[0] if room.fight != null and not room.fight.kinds.is_empty()
				else room.guardian if room.guardian != &"" else stage.minibosses[_rng.randi() % stage.minibosses.size()]]
			_waves = [guardian]
			if room.depth == map.miniboss2_depth and not game.horde.def(guardian[0]).escort.is_empty():
				_waves.append(game.horde.def(guardian[0]).escort.duplicate())  # (right behind it: wave_remaining)
			var alive := EncounterGen.in_room(EncounterGen.alive_range(stage, stage.miniboss_tier), layout)
			_cap = mini(EncounterGen.cap(stage, stage.miniboss_tier, room.depth), alive.y)
			game.horde.alive_cap = alive.y
			phase = Phase.FIGHT
			found(MaterialPurse.MEMORY, &"reach", stage.memory_guardian_reach)  # (the child who falls here still brings one home)
			if layout != null and (layout.hazard == null or layout.hazard.kind == HazardDef.Kind.PLATES) and (first_room == null or first_room.hazards):
				_start_hazard(layout)  # the slabs of the guardian's house (RP-06), its columns (RP-09); never the runes
		RunMap.Kind.FOUNTAIN:
			game.spawn_fountain(FOUNTAIN_SPOT)
			_open_doors()
		RunMap.Kind.ANTE:
			# SW-O3: no fight, the door open at once, its slabs teaching the dodge (damage 0) and nothing given
			_open_doors()
			_start_hazard(layout)
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
	if wait.is_valid():
		await wait.call()
		if not is_inside_tree():
			return
	var notice := T.t(RunMap.KIND_KEY[room.kind]) if room.kind != RunMap.Kind.COMBAT else T.t(&"notice_room", {"n": room.depth})
	var place := T.t(game.arena.name_key) if room.kind != RunMap.Kind.BOSS and game.arena.name_key != &"" else ""
	# the room's name once: the Provação and the Altar are named alike by their kind and by their arena (the Antessala has
	# no word of its own: the arrival's line and the objective speak there)
	if notice != place and room.kind != RunMap.Kind.ANTE:
		game.hud.show_notice(notice, 2.0)
	if place != "":
		# the arena's name for 2 s (decision D-33)
		game.hud.show_place(place)
	game.snap_camera()
	if not _play_arrival():
		_fade_in()


# ---------- SW-O1 and SW-O3: the arrival and the Antessala ----------

## The room's data of the guided descent (null: not in it).
func _first_room_of(r: RunMap.Room) -> FirstRoomDef:
	if first_def == null or r == null:
		return null
	var here_ := first_def.layer(r.depth)
	for fr in here_:
		if fr.kind == r.kind and fr.reward == r.reward and fr.guardian == r.guardian and fr.layout_id == r.arena:
			return fr
	return here_[r.slot] if r.slot < here_.size() else null


## The arrival's scene (environment-artist: ArrivalScene.play(game, at), finished, skip), once, in the Antessala of the
## guided descent: the screen stays black until its opening, the hero's control comes with the scene. False: none to play
## (the scene is not there, or it is not the Antessala), the screen fades in as in any room.
func _play_arrival() -> bool:
	if first_def == null or room.kind != RunMap.Kind.ANTE or not ResourceLoader.exists(ARRIVAL_SCENE):
		return false
	var scene := (load(ARRIVAL_SCENE) as GDScript).new() as Node
	if scene == null or not scene.has_method(&"play"):
		return false
	_arrival = scene
	_arrival_t = 0.0
	add_child(scene)
	scene.call(&"play", game, ArrivalScene.birth_spot(game.arena))
	if scene.has_signal(&"finished"):
		scene.connect(&"finished", func() -> void:
			if is_instance_valid(_arrival):
				_arrival.queue_free()
			_arrival = null)
	# the black opens on the scene's own time (FirstDescentDef): the one ColorRect of the rooms' fades
	_fade.color.a = 1.0
	_fade_tween().tween_interval(first_def.arrival_open_at)
	_fading.tween_property(_fade, "color:a", 0.0, first_def.arrival_open_s)
	return true


## What the Antessala asks each step: its slabs run (they teach, they never hurt), the slabs crossed and the vase
## broken are told, and a hero standing still for FirstDescentDef.idle_blink_s has the objective blink (idle_blink).
signal idle_blink


func _step_ante(dt: float) -> void:
	if plates != null:
		plates.step(dt)
	if _arrival != null:
		_arrival_t += dt
		if _arrival_t >= first_def.arrival_skip_after and _arrival.has_method(&"skip") \
				and (Controls.pressed(&"attack") or Controls.pressed(&"dodge") or Controls.pressed(&"interact")):
			_arrival.call(&"skip")
	var at := game.player.pos
	if not ante_crossed and plates != null and plates.hazard.count() > 0:
		var top := INF
		for i in plates.hazard.count():
			top = minf(top, plates.hazard.bounds(i).position.y)
		if at.y < top - 0.5:
			ante_crossed = true
			plates_crossed.emit()
	if not ante_broke and game.breaks != null:
		for n in game.breaks.rules.life:
			if n <= 0:
				ante_broke = true
				broke_one.emit()
				break
	if first_def != null and at.distance_to(_ante_last) < 0.05:
		_ante_idle += dt
		if _ante_idle >= first_def.idle_blink_s:
			_ante_idle = 0.0
			idle_blink.emit()
	else:
		_ante_idle = 0.0
	_ante_last = at


## What the objective asks of the Antessala (Objective.pick's ctx fields): how near the hero is to the slabs and to a
## vase still whole, and whether he crossed one and broke the other.
func ante_ctx() -> Dictionary:
	var near_plates := false
	var near_breakable := false
	if room != null and room.kind == RunMap.Kind.ANTE and first_def != null:
		var at := game.player.pos
		if plates != null and not ante_crossed:
			for i in plates.hazard.count():
				if plates.hazard.bounds(i).grow(first_def.obj_dodge_near).has_point(at):
					near_plates = true
		if game.breaks != null and not ante_broke:
			var rules := game.breaks.rules
			for i in rules.pieces.size():
				if rules.life[i] > 0 and rules.pieces[i].at.distance_to(at) < first_def.obj_break_near:
					near_breakable = true
	return {"near_plates": near_plates, "near_breakable": near_breakable, "crossed_plates": ante_crossed, "broke_one": ante_broke}


## The numbers of the guided descent for the RESULT ({} off it).
func first_report() -> Dictionary:
	if first_def == null:
		return {}
	return {"first": 1, "ante_s": ante_s, "first_boon_s": first_boon_s}


# ---------- the fight ----------


## Dev (--trace-thirds, the room-designer's "where the fight happens", rooms_progression.md 2.3): seconds of the hero
## in each third of the room west to east (hero_x0..2) and north to south (hero_z0..2), and enemy-seconds west to east
## (foe_x0..2), added to rooms[].zones. Off by default: the RESULT stays as it was.
var _thirds := Dev.has("trace-thirds")


func _third(v: float, half: float) -> int:
	return clampi(int(floorf((v + half) / (2.0 * half) * 3.0)), 0, 2)


func _tally_thirds(dt: float) -> void:
	var h := _layout.half
	var p := game.player.pos
	game.room_tally.zone_time("hero_x%d" % _third(p.x, h.x), dt)
	game.room_tally.zone_time("hero_z%d" % _third(p.y, h.y), dt)
	for e in game.horde.list:
		if e.alive:
			game.room_tally.zone_time("foe_x%d" % _third(e.pos.x, h.x), dt)


func _step_fight(dt: float) -> void:
	if _layout != null and not _layout.areas.is_empty():
		game.room_tally.zone_time(_layout.area_at(game.player.pos), dt)
	if _layout != null and _thirds:
		_tally_thirds(dt)
	if runes != null:
		runes.step(dt)
	if plates != null:
		plates.step(dt)
	if bands != null:
		bands.step(dt)
	if columns != null:
		columns.step(dt)
	if plates_also != null:
		plates_also.step(dt)
	if wall_mark != null:
		wall_mark.step(dt)
	if drops != null:
		drops.step(dt)
	if urns != null:
		urns.step(dt)
	if _wave_wait > 0.0:
		_wave_wait -= dt
		if _wave_wait <= 0.0:
			_next_wave()
		return
	if not _queue.is_empty():
		_spawn_t -= dt
		if _spawn_t <= 0.0 and game.horde.count() < _cap and game.horde.room_for(_group_of(_queue[0])) >= _group_of(_queue[0]):
			_spawn(_next_in_queue())
			_spawn_t = _rng.randf_range(stage.spawn_interval_min, stage.spawn_interval_max)
			if EncounterGen.is_long(stage, room.depth) and room.kind == RunMap.Kind.COMBAT:
				_spawn_t = _rng.randf_range(stage.long_gap.x, stage.long_gap.y)
		return
	var alive := game.horde.count()
	if _wave + 1 < _waves.size():
		if _horde:
			_next_wave()  # (SW-R1: the reserve is queued behind the heads still waiting; the cap holds those standing)
		elif alive <= stage.wave_remaining:
			_wave_wait = stage.wave_delay
			if EncounterGen.is_long(stage, room.depth) and room.kind == RunMap.Kind.COMBAT:
				_wave_wait = stage.long_delay
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
	if d.group > 1:
		game.horde.spawn_group(d, at, true)  # (C5, the Trinca: one head of a wave is a whole triangle of figures)
		game.room_tally.seen(String(id))
	else:
		var mod := _take_mod(id)
		var born := game.horde.spawn(d, at, true, mod)
		if _hp_scale != 1.0:
			born.max_hp *= _hp_scale  # (SW-O4: the guided descent's guardian with less life)
			born.hp = born.max_hp
		game.room_tally.seen(String(id), String(mod.id) if mod != null else "")
	game.fx.burst(&"shadow", Vector3(at.x, 0.6, at.y))
	if d.elite:
		# (vfx_pass_spec.md 5.4, V-15: no column of light; light from above is only for what is taken) a ring of dark
		# smoke with a dull gold edge closes on it
		game.fx.elite_surge(at, d.radius * 1.6 + 0.6)
		if room.kind == RunMap.Kind.MINIBOSS:
			game.hud.show_notice(T.t(&"notice_elite", {"name": T.t(d.name_key)}), 3.0)
			Audio.play(&"elite")


## C1e: the modifier the next head of this kind is born with (null: none).
func _take_mod(id: StringName) -> ModDef:
	var list: Array = _mods.get(id, [])
	if list.is_empty():
		return null
	var mod_id: StringName = list.pop_front()
	return game.horde.mod(mod_id)


## How many bodies one head of the queue brings (EnemyDef.group).
func _group_of(id: StringName) -> int:
	return maxi(1, game.horde.def(id).group)


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
	_rose += 1
	return spawn_point(game.arena, game.player.pos, _rng, _wave > 0 or _rose > LATE_AFTER)


## The weight of each spawn zone (the arena's, and the late ones when `late`): its area, times (its centre's distance from the paladin over
## 8 m, between a quarter and 3) to the power of RoomLayout.far_spawn (SW-R3).
static func spawn_weights(arena: Arena, hero: Vector2, late := false) -> PackedFloat32Array:
	var zones: Array[Rect2] = arena.spawns.duplicate()
	if late:
		zones.append_array(arena.late_spawns)
	var far: float = arena.layout.far_spawn if arena.layout != null else 0.0
	var out := PackedFloat32Array()
	for z: Rect2 in zones:
		var w := maxf(z.get_area(), 0.01)
		if far > 0.0:
			w *= pow(clampf(z.get_center().distance_to(hero) / 8.0, 0.25, 3.0), far)
		out.append(w)
	return out


static func spawn_point(arena: Arena, hero: Vector2, rng: RandomNumberGenerator, late := false) -> Vector2:
	var zones: Array[Rect2] = arena.spawns.duplicate()
	if late:
		zones.append_array(arena.late_spawns)
	if zones.is_empty():
		zones.append(arena.shape().bounds().grow(-2.5))
	var area := spawn_weights(arena, hero, late)
	if area.size() != zones.size():
		area = PackedFloat32Array([1.0])  # (no zone of its own: the whole floor)
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


## The life a won room gives back before any gift: only the fight rooms (combat, guardian), never events, shop or fountain.
static func base_room_heal(kind: RunMap.Kind, base: float) -> float:
	return base if is_fight_room(kind) else 0.0


## The Prata a won room leaves on top of its reward: the same fight rooms (StageDef.silver_room), never events or the shop.
static func room_silver(kind: RunMap.Kind, per_room: int) -> int:
	return per_room if is_fight_room(kind) else 0


static func is_fight_room(kind: RunMap.Kind) -> bool:
	return kind == RunMap.Kind.COMBAT or kind == RunMap.Kind.MINIBOSS


func _room_cleared() -> void:
	phase = Phase.REWARD
	Music.set_level(Music.WALK)
	won.append(room.kind)
	_stop_runes()
	_fight_won()
	game.hero_gifts.room_won()  # Respiro
	game.player.heal(base_room_heal(room.kind, stage.room_heal_base))
	found(MaterialPurse.SILVER, &"room", room_silver(room.kind, stage.silver_room))
	# the last blow of a fight: the world slows to a third, the camera closes in, the screen streaks (Hades II)
	game.fx.slow_mo(LAST_KILL_SLOW, LAST_KILL_HOLD, LAST_KILL_OUT, 1.1, 0.85)
	game.projectiles.clear_hostile()
	# a warning still on the floor never hurts him once the room is won (QA-01)
	game.ground.clear_warnings()
	Audio.play(&"elite_down")
	purse = null
	game.hud.show_notice(T.t(&"notice_room_clear"), 2.0)
	_warn_exits()
	if room.kind == RunMap.Kind.MINIBOSS:
		# the guardian won: Prata and Memória for home (Rejogabilidade, Fatia 1)
		found(MaterialPurse.SILVER, &"guardian", stage.silver_guardian)
		found(MaterialPurse.MEMORY, &"guardian", stage.memory_guardian)
		if first_def == null:
			game.find_tool(Forge.TOOL_REFINE)  # (Fatia 2: the Forjador's first tool, at the first guardian won; not the guided descent's)
	_oficios_cleared()
	_relic_cleared()
	if room.reward == RunMap.Reward.NONE:
		_open_doors()
		return
	_reward_at = game.arena.resolve(game.arena.middle, 1.0)
	_reward_node = _marker(_reward_at, room.reward, "")
	# the light that falls on it and stays until he takes it (vfx_pass_spec.md 6; the column of 1 s went)
	_reward_shaft = RewardShaft.make(self, Vector3(_reward_at.x, 0, _reward_at.y), RewardShaft.tint_of(room.reward, _angel_family(room)))
	_reward_shaft.appear()


## RD2-03: whether the last wave lights the doors at once (the fight rooms; the doors' signs still wait for the reward).
static func warns_exits(kind: RunMap.Kind, doors: int) -> bool:
	return is_fight_room(kind) and doors > 0


## RD2-03: the end of the last wave: every door's light rises together, in the warm gold, and a chime falls.
func _warn_exits() -> void:
	if not warns_exits(room.kind, next_rooms.size()):
		return
	for i in next_rooms.size():
		game.arena.light_exit(i, true, GOLD_COLOR)
	Audio.play(&"ult_ready")
	Music.room_won()  # MUS-2: the calm transition, until the next room


## An enemy fell: in a fight it may leave its share of the fight's gold (GoldPurse), shown where it fell. An elite
## (not a guardian nor Morvath) leaves Prata Antiga too (Rejogabilidade, Fatia 1).
func _on_killed(e: Enemy) -> void:
	if e.def.elite and e.def.behavior != EnemyDef.Behavior.BOSS and not stage.minibosses.has(e.def.id) \
			and room != null and room.kind != RunMap.Kind.BOSS:
		found(MaterialPurse.SILVER, &"elite", stage.silver_elite, e.pos)
	if purse == null or phase != Phase.FIGHT:
		return
	var found := floori(purse.drop(e.def.rating, _rng) * maxf(0.0, 1.0 + trials.curse(&"gold_pct") + game.boons.stat(&"gold_pct")))
	if found <= 0:
		return
	gold += found
	game.fx.gold(Vector3(e.pos.x, 2.4, e.pos.y), found)


func _collect() -> void:
	var reward := room.reward
	_reward_node.queue_free()
	_reward_node = null
	if is_instance_valid(_reward_shaft):
		_reward_shaft.take()
	_reward_shaft = null
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
			if first_def != null and first_boon_s < 0.0:
				first_boon_s = snappedf(game.time, 0.1)  # (SW-O4: the first Blessing offered; the aim is before 2 minutes)
			game.open_boon_choice(stage.guardian_rarity_chance if guardian else stage.rarity_chance,
					stage.guardian_psalm_chance if guardian else stage.psalm_chance, meeting)
		RunMap.Reward.SILVER:
			found(MaterialPurse.SILVER, &"door", stage.silver_door)
		RunMap.Reward.MEMORY:
			found(MaterialPurse.MEMORY, &"door", stage.memory_door)
		RunMap.Reward.ENCHANT:
			game.open_enchant_choice()
		RunMap.Reward.PSALM:
			game.open_psalm_choice(stage.rarity_chance)
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
			var more := roundi(stage.gold_reward * (1.0 + game.boons.stat(&"gold_pct")))
			gold += more
			game.fx.gold(Vector3(p.pos.x, 3.0, p.pos.y), more)
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
		if _phases_paid == stage.emerald_phase_at:
			found(MaterialPurse.EMERALD, &"boss", stage.emerald_phase)  # (Fatia 2: the phase 3 reached)
			game.find_tool(Forge.TOOL_AWAKEN)  # (Fatia 3: the Forjador's second tool, at the first phase 3 reached)


## Morvath is sealed: the victory's Prata and Memória.
func victory() -> void:
	found(MaterialPurse.SILVER, &"boss", stage.silver_victory)
	found(MaterialPurse.MEMORY, &"boss", stage.memory_victory)
	found(MaterialPurse.EMERALD, &"boss", stage.emerald_victory)


# ---------- Ofícios, Roteiro A: the head's room, the pity and the veins ----------

## The vein of this room (VeinFloor; null: none).
var _vein: VeinFloor


# ---------- SR-P5: the relic in the stone ----------

## The room's relic (RelicFloor; null: none).
var _relic: RelicFloor


## The room was won: its relic, when the arena has a spot, the depth is reached and the room's own dice say so (the
## same fight holds it by any path: never the run's dice). The dice also pick what it gives, half gold and half Prata.
func _relic_cleared() -> void:
	if _relic != null or _layout == null or _layout.relic_spots.is_empty() or room.kind != RunMap.Kind.COMBAT \
			or room.depth < stage.relic_from_depth:
		return
	var dice := RandomNumberGenerator.new()
	dice.seed = hash([room.fight_seed, room.depth, 3331])
	if dice.randf() >= stage.relic_chance:
		return
	var what := &"gold" if dice.randf() < 0.5 else &"silver"
	_relic = RelicFloor.make(self, game.arena.resolve(_layout.relic_spots[0], 0.6), what)


func _at_relic() -> bool:
	return _relic != null and not _relic.spent and (phase == Phase.REWARD or phase == Phase.OPEN) \
			and game.player.pos.distance_to(_relic.at) < TOUCH


## A press at the relic gives what it holds, once.
func _step_relic() -> void:
	if not _at_relic() or not _used():
		return
	_relic.spend()
	var p := game.player
	if _relic.gives == &"gold":
		gold += stage.relic_gold
		game.fx.gold(Vector3(p.pos.x, 3.0, p.pos.y), stage.relic_gold)
	else:
		found(MaterialPurse.SILVER, &"relic", stage.relic_silver, _relic.at)
	Audio.play(CombatSounds.EVENTS[&"relic_use"])
	game.room_tally.event("relic", game.time, {"node": room.id, "gives": String(_relic.gives)})


## The room was won: the head waiting in it (or the guardian's, by pity) is found, and its vein shows.
func _oficios_cleared() -> void:
	var of := game.oficios
	if of == null:
		return
	var d := game.oficios_def
	if room.kind == RunMap.Kind.MINIBOSS:
		of.passed_guardian = true
		if of.pity_due and not of.head_found:
			_find_head(&"pity")
	if room.find != &"" and of.wants_head and not of.head_found:
		_find_head(&"room")
	if room.vein and _vein == null and _layout != null and not _layout.gather_spots.is_empty():
		var open := of.has_pick and of.veins < d.veins_max
		if open or (not of.has_pick and game.bot == null):  # (the closed vein only for a person: the robot's runs stay)
			_vein = VeinFloor.make(self, game.arena.resolve(_layout.gather_spots[0], 0.6), open)


func _find_head(by: StringName) -> void:
	var of := game.oficios
	of.head_found = true
	of.head_by = String(by)
	of.head_id = String(game.oficios_def.head)
	game.hud.show_notice(T.t(&"oficio_found", {"name": T.t(&"oficio_pick_head")}), 2.5)
	game.room_tally.event("find", game.time, {"node": room.id, "find": of.head_id, "by": of.head_by})


## Whether the paladin stands at a vein to use (closed: to note it; open: to extract).
func _at_vein() -> bool:
	return _vein != null and _vein.state != VeinFloor.State.SPENT and (phase == Phase.REWARD or phase == Phase.OPEN) \
			and game.player.pos.distance_to(_vein.at) < TOUCH


## The vein: a press notes it (no pick: "Anotado no Livro de Ahk") or starts the extraction, held vein_hold seconds
## standing at it (walking off stops it); then vein_stones Pedra Funda.
func _step_vein(dt: float) -> void:
	if _vein == null:
		return
	var of := game.oficios
	var d := game.oficios_def
	if _at_vein() and _vein.progress < 0.0 and _used():
		if _vein.state == VeinFloor.State.CLOSED:
			if not of.noted:
				of.noted = true
				game.hud.show_notice(T.t(&"oficio_noted"), 2.5)
				game.room_tally.event("vein_noted", game.time, {"node": room.id})
		elif of.may_extract(d):
			_vein.progress = 0.0
		return
	if _vein.progress < 0.0:
		return
	if game.player.pos.distance_to(_vein.at) >= TOUCH:
		_vein.progress = -1.0
		return
	_vein.progress += dt
	of.gather_s += dt
	if _vein.progress >= d.vein_hold:
		_vein.progress = -1.0
		_vein.set_state(VeinFloor.State.SPENT)
		of.veins += 1
		of.stones += d.vein_stones
		game.fx.word(Vector3(_vein.at.x, 3.0, _vein.at.y), "+%d %s" % [d.vein_stones, T.t(&"oficio_stone")], SILVER_COLOR)
		game.room_tally.event("vein", game.time, {"node": room.id, "stones": d.vein_stones})


## Obra 1, "Prévia dos anjos": as the doors open, the angel of each Blessing's room one layer further (behind the
## doors) is drawn now; its door keeps it when it opens. Discernimento II (Fatia 3) sees one layer further still (alone,
## the layer behind the doors). DM-1: with no map, the HUD says what those rooms give (ahead_text).
func _preview_angels() -> void:
	if game.encounters == null:
		return
	var layers := (1 if game.oficios != null and game.oficios.preview else 0) + (1 if game.discern >= 2 else 0)
	_ahead.clear()
	if layers <= 0:
		return
	var ring: Array[RunMap.Room] = next_rooms.duplicate()
	for k in layers:
		var further: Array[RunMap.Room] = []
		for r in ring:
			for id in r.next:
				var n := map.nodes[id]
				if further.has(n):
					continue
				further.append(n)
				if n.reward == RunMap.Reward.BOON and not n.meeting and shows_angel(n) and n.angel == &"":
					n.angel = game.encounters.door_angel(n, _angels_of(further))
		ring = further
		if not further.is_empty():
			_ahead.append(further)


## The rooms beyond the open doors, layer by layer, as far as he sees (_preview_angels).
var _ahead: Array = []


## "Depois: Romã ou Fonte", a layer after the other; "" with no door open or nothing to see with.
func ahead_text() -> String:
	if phase != Phase.OPEN or _ahead.is_empty():
		return ""
	var words := PackedStringArray()
	for layer: Array in _ahead:
		var names := PackedStringArray()
		for r: RunMap.Room in layer:
			var word := door_text(r, false).replace("\n", ", ")
			if not names.has(word):
				names.append(word)
		words.append(T.t(&"hud_ahead_or").join(names))
	return T.t(&"hud_ahead", {"rooms": T.t(&"hud_ahead_then").join(words)})


# ---------- doors ----------

## Whether a Psalm may come now (a Psalm's door shows only then: RunMap.settle, Room.psalm).
func psalm_can_come() -> bool:
	return game.psalm_cards and not game.psalms.eligible(game.boons, game.talents).is_empty()


func _open_doors() -> void:
	phase = Phase.OPEN
	if room.kind == RunMap.Kind.COMBAT or room.kind == RunMap.Kind.MINIBOSS:
		_roll_slab()
	# a pomegranate behind a door when nothing can grow turns into a Blessing before its sign shows (Q-25 a); the
	# Blessing of this room counts as one to grow
	map.settle(next_rooms, game.boons.can_grow() or room.reward == RunMap.Reward.BOON,
		psalm_can_come(), not game.enchant_offers().is_empty())
	# Fatia 2: a Blessing's door that is no meeting shows the angel who waits there (Encounters.door_angel)
	for r in next_rooms:
		if r.reward == RunMap.Reward.BOON and not r.meeting and shows_angel(r) and game.encounters != null \
				and r.angel == &"":
			r.angel = game.encounters.door_angel(r, _angels_of(next_rooms))  # (one shown before by the preview stays)
	_preview_angels()
	for i in next_rooms.size():
		var r := next_rooms[i]
		game.arena.light_exit(i, true, _reward_color(r.reward) if r.reward != RunMap.Reward.NONE else _kind_color(r.kind))
		if game.arena.look != null:
			# the air of the room behind it breathes out of the doorway (ArenaRoom.breath)
			game.arena.look.breath(i, door_look(i))
		var anchor := game.arena.door_anchor(i)
		var marker := _marker(Vector2(anchor.x, anchor.z), r.reward, door_text(r), r.kind, DoorGlyph.of(door_info(i)))
		_door_labels.append(marker)
		var door_sign := marker.find_child("DoorSign", false, false) as Node3D
		if door_sign != null:
			door_sign.position.y = game.arena.door_sign_y(i)
		_sign_angel(marker, r)
	if not next_rooms.is_empty():
		Audio.play(&"door")


## A door's sign (E5-D8, docs/art/e5_spec.md 7.1): the reward of a fight, under it "Difícil" for one with an elite
## and the guardian's name for a guardian's; the room's kind for the others (the pictogram beside it: DoorGlyph.of(door_info)).
## The altar's says what it is in a line (T5): a trade with no fight.
## The room of a find he looks for names it (find false: the line is left out, for the HUD).
static func door_text(r: RunMap.Room, find := true) -> String:
	match r.kind:
		RunMap.Kind.COMBAT:
			var sign := r.sign()
			var text := T.t(RunMap.REWARD_KEY[r.reward]) + _angel_line(r)
			if find and r.find != &"":
				text += "\n" + T.t(&"door_find", {"name": UiKit.find_name(r.find)})
			if bool(sign.hard):
				# Fatia 2: the Prata its elites leave, on the sign (1 an elite, StageDef.silver_elite)
				var silver := elite_heads(r) * sign_silver
				text += "\n" + (T.t(&"door_hard_silver").format({"n": silver}) if silver > 0 else T.t(&"door_hard"))
			return text
		RunMap.Kind.MINIBOSS:
			# who waits there: the order of the two guardians is his choice (Daniel, 2026-11-22)
			# PT-8: and the angel that blesses there, the line the fight is chosen by
			return T.t(RunMap.REWARD_KEY[r.reward]) + _angel_line(r) + "\n" \
				+ T.t(&"enemy_" + r.guardian if r.guardian != &"" else RunMap.KIND_KEY[r.kind])
		RunMap.Kind.ALTAR:
			return T.t(RunMap.KIND_KEY[r.kind]) + "\n" + T.t(&"door_altar")
	return T.t(RunMap.KIND_KEY[r.kind])


## The Prata an elite leaves, for the signs of the hard doors (the stage's silver_elite; a static sign reads this).
static var sign_silver := 1


## The elites a room's fight brings, every wave (each leaves its Prata: the hard door's sign says how much).
static func elite_heads(r: RunMap.Room) -> int:
	var n := 0
	if r.fight != null:
		for wave in r.fight.waves:
			for id in wave:
				if String(id).ends_with("_elite"):
					n += 1
	return n


## The rooms whose Blessing door shows one angel: fights and, since PT-8, the guardians.
static func shows_angel(r: RunMap.Room) -> bool:
	return r.kind == RunMap.Kind.COMBAT or r.kind == RunMap.Kind.MINIBOSS


## The angels the given doors already show (PT-8: two doors side by side never show the same one).
static func _angels_of(rooms_: Array[RunMap.Room]) -> Array[StringName]:
	var out: Array[StringName] = []
	for r in rooms_:
		if r.angel != &"":
			out.append(r.angel)
	return out


## The angel's line of a door's sign drawn with its seal and colour (DoorSign.show_angel; the text stays the same).
func _sign_angel(marker: Node3D, r: RunMap.Room) -> void:
	var line := _angel_line(r).strip_edges()
	if line == "":
		return
	for c in marker.get_children():
		if c is DoorSign:
			var who: AngelDef = null
			if not r.meeting and game.encounters != null:
				who = game.encounters.book.find(r.angel)
			(c as DoorSign).show_angel(line, who)


## Under a Blessing's reward, the angel its door shows, or "Dois anjos" for a meeting (Fatia 2).
static func _angel_line(r: RunMap.Room) -> String:
	if r.reward != RunMap.Reward.BOON:
		return ""
	if r.meeting:
		return "\n" + T.t(&"door_angels_two")
	if r.angel != &"":
		return "\n" + T.t(StringName("angel_" + String(r.angel)))
	return ""


func _leave(next: RunMap.Room) -> void:
	_log_leaving(next)
	phase = Phase.LEAVING
	var t := _fade_tween()
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func() -> void: _go(next))


## QA P1-1 (DT-RS3): a room is built and first drawn on a black screen, never on a frame of play. The fade reaches
## black, one black frame is shown (the frame before it was still a little lit), the room is built, and the screen
## stays black for HOLD_FRAMES drawn frames (the first draw of a new room compiles its shaders: up to seconds on an
## iGPU) with the world not stepping (holding(); Game._process), then fades in on real time. Without a screen (smoke,
## tests) nothing waits: the same RESULT as before. --hold-frames=N forces it (tests).
const HOLD_FRAMES := 2
var _hold := 0
var _hold_turn := 0


func _go(next: RunMap.Room) -> void:
	if hold_frames() <= 0:
		_enter(next)
		return
	_hold = 1 << 20  # (the world waits from here: holding())
	await _frame_drawn()
	if not is_inside_tree():
		return
	await _enter_with(next, _frame_drawn)


## The world waits while the new room is held black.
func holding() -> bool:
	return _hold > 0


static func hold_frames() -> int:
	if Dev.has("hold-frames"):
		return int(Dev.num("hold-frames", HOLD_FRAMES))
	return 0 if DisplayServer.get_name() == "headless" else HOLD_FRAMES


func _frame_drawn() -> void:
	if DisplayServer.get_name() == "headless":
		await get_tree().process_frame
	else:
		await RenderingServer.frame_post_draw


func _fade_in() -> void:
	if _fading != null:
		_fading.kill()
	_fade.color.a = 1.0
	_hold = hold_frames()
	_hold_turn += 1
	var turn := _hold_turn
	while _hold > 0:
		await _frame_drawn()
		if not is_inside_tree() or turn != _hold_turn:
			return  # (a newer room took the screen: its own hold counts)
		_hold -= 1
	_fade_tween().tween_property(_fade, "color:a", 0.0, FADE)


## A new fade of the screen; the one still running stops (BH-6: a fade-in left running lightened the black of the next
## room).
func _fade_tween() -> Tween:
	if _fading != null:
		_fading.kill()
	_fading = create_tween()
	return _fading


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
				r.fight = EncounterGen.generate(stage, r.depth, _defs, dice, 1.0, l, _parts_of(room.fight if room != null else null))
			RunMap.Kind.MINIBOSS:
				var f := EncounterGen.Fight.new()
				f.kinds = [r.guardian if r.guardian != &"" else stage.minibosses[_rng.randi() % stage.minibosses.size()]]
				f.tier = stage.miniboss_tier
				f.waves = [f.kinds.duplicate()]
				r.fight = f


## C1e: the parts of a fight (the room just left), for the next one not to repeat them.
func _parts_of(f: EncounterGen.Fight) -> Array[StringName]:
	if f == null or f.kinds.is_empty():
		return [] as Array[StringName]
	return EncounterGen.roles_of(f.kinds, _defs)


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
	game.find_tool(Forge.TOOL_INSCRIBE)  # (Fatia 3: the third tool, at the first Provação won)
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
	if not room.trial or map.depth >= stage.rooms or not Trials.healthy(stage, game.player.hp, game.player.max_hp) \
			or not trials.open_at(stage, map.depth, map.fights_left()):
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
	var t := _fade_tween()
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func() -> void: _go(map.trial(map.depth)))


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
	sign.add_note(T.t(&"trial_slab_offer") + "\n" + T.t(&"trial_slab_risk") + "\n" + T.t(&"trial_slab_refuse"))
	sign.position = Vector3(at.x, MARK_SIGN_Y, at.y)
	root.add_child(sign)
	_slab_sign = sign
	return root


## AT-FO2: where the Fonte springs in the Salão: in the frame of both cameras on the paladin's arrival from the south-west
## landing (Perto at 0.72 / 0.49 of the screen, Longe 0.55 / 0.51), 8.9 m from him and on his way to the doors; the old
## spot (0; -2), north of the medallion, was off the screen of both on arrival (Perto x 1.49, Longe 1.11) with its light.
const FOUNTAIN_SPOT := Vector2(-8.0, 10.0)

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
	if layout != null and layout.guardian_home and layout.guardian_id == &"knight" and wall_mark == null:
		wall_mark = WallMark.new(game)
	if layout != null and columns == null:
		var c := ColumnFloor.new(game, layout.obstacles)
		if c.count() > 0:
			columns = c
		else:
			c.stop()
	if layout == null or layout.hazard == null:
		return
	# A1: the room's second hazard (the stones of the vault, the oil urns), SR-P2/P3 a third: one of each kind's slot
	var hz := layout.hazard
	while hz != null:
		_start_one(hz)
		hz = hz.also


func _start_one(def: HazardDef) -> void:
	# captures: --hazards arms every hazard of the room as deep in the descent
	var progress := 1.0 if Dev.has("hazards") else EncounterGen.progress(stage, room.depth)
	if first_room != null and first_room.hazard_progress >= 0.0 and not Dev.has("hazards"):
		progress = first_room.hazard_progress  # (SW-O4: the guided descent's room sets how far down its hazards stand)
	match def.kind:
		HazardDef.Kind.LINE:
			bands = BandFloor.new(game, def, progress >= def.from_progress, progress)
		HazardDef.Kind.PLATES:
			var pf := PlateFloor.new(game, def, progress >= def.from_progress, progress)
			if plates == null:
				plates = pf
			else:
				plates_also = pf
		HazardDef.Kind.DROPS:
			# the room's own dice (the same fight drops the same way by any path, never the run's)
			drops = DropFloor.new(game, def, hash([room.fight_seed, room.depth, 2071]), progress >= def.from_progress)
		HazardDef.Kind.URNS:
			urns = UrnFloor.new(game, def, progress >= def.from_progress)
		_:
			runes = RuneFloor.new(game, def, _rng, progress >= def.crystal_from)


func _stop_runes() -> void:
	if wall_mark != null:
		wall_mark.stop()
		game.room_tally.walls(wall_mark.tally())
		wall_mark = null
	if columns != null:
		columns.stop()
		game.room_tally.columns(columns.tally())
		columns = null
	if plates != null:
		plates.stop()
		game.room_tally.hazard(plates.enemy_damage, plates.kills, plates.hazard.fired, String(plates.hazard.def.plate_source),
			plates.tally())
		plates = null
	if bands != null:
		bands.stop()
		game.room_tally.hazard(bands.enemy_damage, bands.kills, bands.hazard.fired, String(bands.hazard.def.band_source),
			bands.tally())
		bands = null
	if plates_also != null:
		plates_also.stop()
		game.room_tally.hazard(plates_also.enemy_damage, plates_also.kills, plates_also.hazard.fired,
			String(plates_also.hazard.def.plate_source), plates_also.tally())
		plates_also = null
	if drops != null:
		drops.stop()
		game.room_tally.hazard(drops.enemy_damage, drops.kills, drops.hazard.fired, String(Ground.ROCKS_SOURCE),
			drops.tally())
		drops = null
	if urns != null:
		urns.stop()
		var t := urns.tally()
		t["oil_hero_damage"] = game.room_tally.hurt_in_room(String(Ground.OIL_SOURCE))
		game.room_tally.hazard(urns.enemy_damage, urns.kills, urns.hazard.blasts, String(Ground.URN_SOURCE), t)
		urns = null
	if runes == null:
		return
	runes.stop()
	var rt := runes.tally()
	if rt.has("crystal_charges"):
		rt["crystal_hero_damage"] = game.room_tally.hurt_in_room(String(Ground.CRYSTAL_SOURCE))
	game.room_tally.hazard(runes.enemy_damage, runes.kills, runes.hazard.fired, "runes", rt)
	runes = null


# ---------- the shop ----------

## The items of each shop group (C13-04: ShopGroup.count of each), on pedestals in a row; a pomegranate (or its slice)
## only when a gift can grow.
## PT-11 (Daniel, 2026-11-23; docs/art/ref/sworn_daniel/shop_along_wall.png): the middle of the hall stays free. The first
## item (the Blessing, the highlight) stands a little forward on the engraved medallion; the rest line the walls, thin stone
## columns along the back (north) wall and the sides, each in its own bubble of light with the price plaque over it. SHOP_SLOTS
## is the order they fill (1 to 5 items, the route shop's 3 the first three); all on the hall's floor, 6 m and more from the
## way in, off the portal's door and the stairs of the east side (tests/test_shop_wall.gd).
const SHOP_SLOTS: Array[Vector2] = [Vector2(-2.5, 1.0), Vector2(-3.5, -10.8), Vector2(-8.8, -10.2), Vector2(-11.6, -3.2), Vector2(11.6, -7.5)]
## The word of each shop group (StageDef.shop_groups, in order), over the item's name.
const SHOP_GROUP_KEY: Array[StringName] = [&"shop_group_boon", &"shop_group_care", &"shop_group_growth"]
## Height over the floor of the point a marker's sign stands on.
const MARK_SIGN_Y := 2.7


func _build_shop() -> void:
	var can_grow := game.boons.can_grow()
	var can_enchant := not game.enchant_offers().is_empty()
	var valid := func(item: int) -> bool:
		if item == RunMap.Reward.ENCHANT:
			return can_enchant
		return can_grow or (item != RunMap.Reward.POM and item != RunMap.Reward.POM_SLICE)
	var picks: Array[Dictionary] = []
	# DV-2 (MAP-09): the route shop has one item of each group (route_shop_items), the last one all of them
	var route := map != null and map.is_route_shop(room)
	for g in stage.shop_groups.size():
		var group := stage.shop_groups[g]
		var chosen: Array[int] = []
		if route:
			if picks.size() < stage.route_shop_items:
				var i := group.pick(_rng, valid)
				if i >= 0:
					chosen.append(i)
		else:
			chosen = group.pick_all(_rng, valid)
		for i in chosen:
			picks.append({"item": group.items[i] as RunMap.Reward, "price": group.prices[i], "group": g})
	_vine_stock(picks, valid)
	var n := picks.size()
	for k in n:
		var p := picks[k]
		var at := SHOP_SLOTS[k]
		p.at = at
		p.node = _marker(at, p.item, "")
		# two lines, the name and the price (benchmark_hades2_ui.md P1-3: the reward's mark says the group; the price
		# out of reach says it by its colour, and what is missing by the key when he stands at it)
		var sign := DoorSign.shop(T.t(RunMap.REWARD_KEY[p.item]), p.price, "", DoorGlyph.of_reward(p.item))
		sign.position.y = MARK_SIGN_Y
		sign.set_gold(gold)
		(p.node as Node3D).add_child(sign)
		p.sign = sign
		# every item under its light at once, as he comes in; strong when the gold reaches it (vfx_pass_spec.md 6)
		var shaft := RewardShaft.make(self, Vector3(at.x, 0, at.y), RewardShaft.tint_of(p.item), shop_light(gold >= int(p.price)))
		shaft.appear(0.0, true)
		p.shaft = shaft
		_pedestals.append(p)
	# the stylized look dresses the row (room redesign lot A 3.3; nothing of it blocks)
	var points: Array[Vector2] = []
	for p in picks:
		points.append(p.at)
	game.arena.dress_shop(points)


## A Videira's Provisão on a shop's shelf (every shop, the route ones too): Reserva (shop_care) a healing item always
## there (the care group's own pick gives its place to it; when none is shown it is one more), then Estoque (shop_extra)
## one more item, different from those shown, from the group the dice give.
func _vine_stock(picks: Array[Dictionary], valid: Callable) -> void:
	var groups := stage.shop_groups
	if game.boons.stat(&"shop_care") > 0.0:
		var care := -1
		for g in groups.size():
			if groups[g].items.has(RunMap.Reward.HEAL):
				care = g
		if care >= 0 and not picks.any(func(p: Dictionary) -> bool: return p.item == RunMap.Reward.HEAL):
			var i: int = groups[care].items.find(RunMap.Reward.HEAL)
			var heal := {"item": RunMap.Reward.HEAL, "price": groups[care].prices[i], "group": care}
			var slot := -1
			for k in picks.size():
				if picks[k].group == care:
					slot = k
			if slot >= 0:
				picks[slot] = heal
			else:
				picks.append(heal)
	if game.boons.stat(&"shop_extra") > 0.0 and not groups.is_empty():
		var shown := picks.map(func(p: Dictionary) -> int: return p.item)
		var fresh := func(item: int) -> bool: return not shown.has(item) and valid.call(item)
		var from := _rng.randi() % groups.size()
		for k in groups.size():
			var g := (from + k) % groups.size()
			var i := groups[g].pick(_rng, fresh)
			if i >= 0:
				picks.append({"item": groups[g].items[i] as RunMap.Reward, "price": groups[g].prices[i], "group": g})
				break


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
		if is_instance_valid(p.get("shaft")):
			(p.shaft as RewardShaft).take()
		_pedestals.erase(p)
		_give(p.item)


## The order in which the bot picks a door, as a player would (E3: before it took the first door, so the rewards it
## got were the deck's draw, not a choice): the fountain, a Blessing, a pomegranate, a heart, gold, Magia.
const BOT_PREFERENCE: Array[RunMap.Reward] = [RunMap.Reward.BOON, RunMap.Reward.POM, RunMap.Reward.HEART, RunMap.Reward.GOLD, RunMap.Reward.MAGICK]
## The doors of a material for home (Rejogabilidade, Fatia 1, MAP-04's taste): between the heart and gold, Memória a
## little before Prata; never over the power of this descent (a Blessing, a pomegranate, a heart).
const BOT_MATERIAL_RANK := {RunMap.Reward.MEMORY: 2.4, RunMap.Reward.SILVER: 2.6}
## Fatia 2: a Psalm's door just after a Blessing (it holds Blessings and the Psalm), an Encanto's after the heart (put
## before the pomegranate the robot took half the hearts it took before, reached Morvath with 30 of life against 51 and
## won 46 of 72 against 58; 2026-11-20, 72 seeds).
const BOT_FATIA2_RANK := {RunMap.Reward.PSALM: 0.2, RunMap.Reward.ENCHANT: 2.5}


## A reward's place in the robot's taste (BOT_PREFERENCE, BOT_MATERIAL_RANK; -1 for none of them).
static func _bot_rank(r: RunMap.Reward) -> float:
	return float(BOT_FATIA2_RANK.get(r, BOT_MATERIAL_RANK.get(r, BOT_PREFERENCE.find(r))))


## Where the altar's door stands in that order (E5): after a Blessing and a pomegranate (its trade grows a Blessing).
const BOT_ALTAR_RANK := 1.5


## The door the bot walks through (index in doors). altar_useful: it would trade something there (E6: before it walked
## into the altar with nothing to trade, a room lost); otherwise the altar comes last. life: its share of its most
## life (C17, QW-112: it took the fountain with full life, a Blessing's door lost; now only below BOT_FOUNTAIN_BELOW,
## otherwise the fountain comes after every reward).
const BOT_FOUNTAIN_BELOW := 0.8


## DV-2 (MAP-09): a route shop's door ranks after a Blessing when the robot carries BOT_ROUTE_SHOP_GOLD (something
## besides the healing to buy), otherwise last.
const BOT_ROUTE_SHOP_GOLD := 100


static func bot_door(doors: Array[RunMap.Room], altar_useful: bool = true, life: float = 0.0, gold_now := 0) -> int:
	var best := 0
	var top := -INF
	for i in doors.size():
		var rank := _bot_rank(doors[i].reward)
		if doors[i].kind == RunMap.Kind.FOUNTAIN:
			rank = -1.0 if life < BOT_FOUNTAIN_BELOW else BOT_PREFERENCE.size() + 0.5
		elif doors[i].kind == RunMap.Kind.ALTAR:
			rank = BOT_ALTAR_RANK if altar_useful else BOT_PREFERENCE.size() + 1.0
		elif doors[i].kind == RunMap.Kind.SHOP:
			# (hurt, the healing for 50 is worth the door too)
			var worth := gold_now >= BOT_ROUTE_SHOP_GOLD or (gold_now >= BOT_ROUTE_SHOP_GOLD / 2 and life < BOT_FOUNTAIN_BELOW)
			rank = 1.0 if worth else BOT_PREFERENCE.size() + 0.5
		elif rank < 0.0:
			rank = BOT_PREFERENCE.size()
		if -rank > top:
			top = -rank
			best = i
	return best


## The altar's trade the robot would make now (Altar.bot_choice; -1: none).
func _bot_altar_pick() -> int:
	return Altar.bot_choice(Altar.options(stage, gold, game.player.max_hp, game.boons.can_grow(), game.player.magick.max_value), game.player.max_hp, gold)


## Where the bot should walk when the room has no fight left (null: stay).
func bot_goal() -> Variant:
	if _relic != null and not _relic.spent and (phase == Phase.REWARD or phase == Phase.OPEN):
		return _relic.at  # (SR-P5: the robot takes the relic before the reward and the doors)
	if _vein != null and _vein.state == VeinFloor.State.OPEN and game.oficios.may_extract(game.oficios_def) \
			and (phase == Phase.REWARD or phase == Phase.OPEN):
		return _vein.at  # (Ofícios: the robot with the pick extracts before the reward and the doors)
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
			return game.arena.door_goal(clampi(bot_door(next_rooms, _bot_altar_pick() >= 0, game.player.hp / maxf(game.player.max_hp, 1.0), gold),
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
	_reward_shaft = null
	_vein = null
	_relic = null
	_gems.clear()
	_pedestals.clear()
	_door_labels.clear()


static func _reward_color(r: RunMap.Reward) -> Color:
	match r:
		RunMap.Reward.BOON:
			return Color(1.0, 0.82, 0.38)
		# (vfx_pass_spec.md 4 and 6.3: the pomegranate and the heart out of the danger's red, rose and a colder rose)
		RunMap.Reward.POM, RunMap.Reward.POM_SLICE:
			return Color.from_hsv(352.0 / 360.0, 0.5, 1.0)
		RunMap.Reward.HEART:
			return Color.from_hsv(8.0 / 360.0, 0.5, 0.95)  # sweep 2026-11-25: a muted heart red, no rose (pink is the curse's)
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
		RunMap.Reward.ENCHANT:
			return ENCHANT_COLOR
		RunMap.Reward.PSALM:
			return PSALM_COLOR
	return Color.WHITE


## How strong a shop item's light is: RewardShaft.SHOP_CAN when the gold reaches its price, SHOP_CANNOT when not.
static func shop_light(affordable: bool) -> float:
	return RewardShaft.SHOP_CAN if affordable else RewardShaft.SHOP_CANNOT


## The family of the one angel a Blessing's door showed (-1: two angels meet him, the guardian, or none).
func _angel_family(r: RunMap.Room) -> int:
	if r == null or r.meeting or r.angel == &"" or game.encounters == null:
		return -1
	for a: AngelDef in game.encounters.book.catalog:
		if a.id == r.angel:
			return a.family
	return -1


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
