class_name Rooms
extends Node3D
## The descent room by room (the structure of Hades II's first region, with our rooms and rewards): each room is
## closed until its waves are beaten, leaves its reward, then its doors light up showing what lies behind each.
## Owned and stepped by Game; RunMap draws the rooms, EncounterGen the fights.

enum Phase { FIGHT, REWARD, OPEN, LEAVING, BOSS }

const STAGE := "res://data/stages/catacombs.tres"
## Seconds after walking in before the first wave rises (Hades II starts a fight as you step into the room).
const START_DELAY := 1.0
## Meters from the reward or a pedestal that count as touching it.
const TOUCH := 1.6
const FADE := 0.35
## The last kill of a room: world speed, seconds held and seconds back to normal (Hades II: 0.35, about 0.6, 0.4).
const LAST_KILL_SLOW := 0.35
const LAST_KILL_HOLD := 0.55
const LAST_KILL_OUT := 0.4
const GOLD_COLOR := Color(1.0, 0.82, 0.35)

var game: Game
var stage: StageDef
var map: RunMap
var room: RunMap.Room
var next_rooms: Array[RunMap.Room] = []
var phase := Phase.FIGHT
var gold := 0
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
var _rng: RandomNumberGenerator
var _fade: ColorRect
## The floating signs turn slowly.
var _gems: Array[Node3D] = []


func setup(g: Game, rng: RandomNumberGenerator) -> void:
	game = g
	_rng = rng
	stage = load(STAGE)
	if Dev.has("short"):
		# the old short descent (fight, fountain, guardian, shop, Morvath in room 5), for quick tests
		stage = stage.duplicate()
		stage.rooms = 4
		stage.fountain_depth_min = 2
		stage.fountain_depth_max = 2
		stage.miniboss_depth_min = 3
		stage.miniboss_depth_max = 3
	map = RunMap.new(stage, _rng)
	if Dev.has("arena"):
		# dev: --arena=id makes the opening room that arena (--variant=n dresses it)
		for i in stage.layouts.size():
			if String(stage.layouts[i].id) == Dev.arg("arena"):
				map.forced_layout = i
	for id in stage.enemies:
		_defs[id] = game.horde.def(id)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.ui.add_child(_fade)


func start() -> void:
	_enter(map.first())


## Dev: jumps straight to a room kind at its depth (--start=boss|miniboss|shop|fountain).
func start_at(kind: RunMap.Kind) -> void:
	match kind:
		RunMap.Kind.BOSS:
			map.depth = stage.rooms
		RunMap.Kind.SHOP:
			map.depth = stage.rooms - 1
		RunMap.Kind.MINIBOSS:
			map.depth = map.miniboss_depth - 1
		RunMap.Kind.FOUNTAIN:
			map.depth = stage.fountain_depth_max - 1
			map.miniboss_depth = 0
	for r in map.options(true):
		if r.kind == kind:
			_enter(r)
			return
	_enter(map.options(true)[0])


func _process(delta: float) -> void:
	for g in _gems:
		if is_instance_valid(g):
			g.rotation.y += delta * TAU / 2.4


func depth() -> int:
	return map.depth


func step(dt: float) -> void:
	match phase:
		Phase.FIGHT:
			_step_fight(dt)
		Phase.REWARD:
			if _reward_node != null and game.player.pos.distance_to(_reward_at) < TOUCH:
				_collect()
		Phase.OPEN:
			_step_shop()
			var door := game.arena.exit_at(game.player.pos)
			if door >= 0 and door < next_rooms.size():
				_leave(next_rooms[door])


# ---------- entering ----------

func _enter(next: RunMap.Room) -> void:
	room = next
	map.enter(room)
	next_rooms = map.options(game.boons.can_grow() or room.reward == RunMap.Reward.BOON)
	var layout: RoomLayout = stage.layouts[room.layout] if not stage.layouts.is_empty() else null
	match room.kind:
		RunMap.Kind.BOSS:
			layout = stage.boss_layout
		RunMap.Kind.SHOP:
			layout = stage.shop_layout
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
		variant, gold, game.boons.owned().size())
	if room.kind == RunMap.Kind.SHOP:
		game.room_tally.shop_entered(gold)
	_queue.clear()
	_waves.clear()
	_wave = -1
	_wave_wait = START_DELAY
	# nobody stands past the stage's ceiling, summons included; a fight lowers it to its tier's most
	game.horde.alive_cap = stage.alive_cap
	match room.kind:
		RunMap.Kind.COMBAT:
			var fight := EncounterGen.generate(stage, room.depth, _defs, _rng, 1.0, layout)
			_waves = fight.waves
			_cap = fight.cap
			game.horde.alive_cap = fight.ceiling
			phase = Phase.FIGHT
		RunMap.Kind.MINIBOSS:
			var guardian: Array[StringName] = [stage.minibosses[_rng.randi() % stage.minibosses.size()]]
			_waves = [guardian]
			var alive := EncounterGen.in_room(EncounterGen.alive_range(stage, stage.miniboss_tier), layout)
			_cap = mini(EncounterGen.cap(stage, stage.miniboss_tier, room.depth), alive.y)
			game.horde.alive_cap = alive.y
			phase = Phase.FIGHT
		RunMap.Kind.FOUNTAIN:
			game.spawn_fountain(Vector2(0, -2.0))
			_open_doors()
		RunMap.Kind.SHOP:
			_build_shop()
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
	# the last blow of a fight: the world slows to a third, the camera closes in, the screen streaks (Hades II)
	game.fx.slow_mo(LAST_KILL_SLOW, LAST_KILL_HOLD, LAST_KILL_OUT, 1.1, 0.85)
	game.projectiles.clear_hostile()
	# a warning still on the floor never hurts him once the room is won (QA-01)
	game.ground.clear_warnings()
	Audio.play(&"elite_down")
	var found := _rng.randi_range(stage.room_gold_min, stage.room_gold_max)
	if room.kind == RunMap.Kind.COMBAT:
		gold += found
		game.fx.word(Vector3(game.player.pos.x, 3.0, game.player.pos.y), "+%d %s" % [found, T.t(&"hud_gold_short")], GOLD_COLOR)
	game.hud.show_notice(T.t(&"notice_room_clear"), 2.0)
	if room.reward == RunMap.Reward.NONE:
		_open_doors()
		return
	_reward_at = game.arena.resolve(game.arena.middle, 1.0)
	_reward_node = _marker(_reward_at, room.reward, "")
	game.column(_reward_at, _reward_color(room.reward), 1.4, 12.0, 1.0)


func _collect() -> void:
	var reward := room.reward
	_reward_node.queue_free()
	_reward_node = null
	_give(reward, room.kind == RunMap.Kind.MINIBOSS)
	_open_doors()


## Hands over a reward (from a room or bought in the shop).
func _give(reward: RunMap.Reward, guardian: bool = false) -> void:
	var p := game.player
	match reward:
		RunMap.Reward.BOON:
			game.open_boon_choice(Boon.RARITY_WEIGHT_GUARDIAN if guardian else Boon.RARITY_WEIGHT)
		RunMap.Reward.POM:
			game.open_grow_choice()
		RunMap.Reward.HEART:
			game.add_max_life(stage.heart_life)
		RunMap.Reward.MAGICK:
			p.magick.max_value += stage.magick_more
			p.magick.gain(stage.magick_more)
			game.fx.word(Vector3(p.pos.x, 3.0, p.pos.y), "+%d %s" % [int(stage.magick_more), T.t(&"hud_magick")], Color(0.5, 0.75, 1.0))
		RunMap.Reward.GOLD:
			gold += stage.gold_reward
			game.fx.word(Vector3(p.pos.x, 3.0, p.pos.y), "+%d %s" % [stage.gold_reward, T.t(&"hud_gold_short")], GOLD_COLOR)
		RunMap.Reward.HEAL:
			p.heal(p.max_hp * stage.shop_heal)
			game.fx.burst(&"heal", Vector3(p.pos.x, 1.2, p.pos.y))
	Audio.play(&"heal" if reward == RunMap.Reward.HEAL or reward == RunMap.Reward.HEART else &"orb")


# ---------- doors ----------

func _open_doors() -> void:
	phase = Phase.OPEN
	for i in next_rooms.size():
		var r := next_rooms[i]
		game.arena.light_exit(i, true, _reward_color(r.reward) if r.reward != RunMap.Reward.NONE else _kind_color(r.kind))
		var text := T.t(RunMap.REWARD_KEY[r.reward]) if r.kind == RunMap.Kind.COMBAT else T.t(RunMap.KIND_KEY[r.kind])
		_door_labels.append(_marker(game.arena.door_label(i), r.reward, text, r.kind))
	if not next_rooms.is_empty():
		Audio.play(&"door")


func _leave(next: RunMap.Room) -> void:
	phase = Phase.LEAVING
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func() -> void: _enter(next))


func _fade_in() -> void:
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, FADE)


# ---------- the shop ----------

func _build_shop() -> void:
	var n := stage.shop_items.size()
	for i in n:
		var item := stage.shop_items[i] as RunMap.Reward
		if item == RunMap.Reward.POM and not game.boons.can_grow():
			continue
		var at := Vector2(lerpf(-6.0, 6.0, float(i) / maxf(1.0, n - 1.0)), 0.0)
		var price := stage.shop_prices[i]
		var node := _marker(at, item, "%s\n%d %s" % [T.t(RunMap.REWARD_KEY[item]), price, T.t(&"hud_gold_short")])
		_pedestals.append({"at": at, "item": item, "price": price, "node": node})


## Stepping onto an item buys it when there is gold for it.
func _step_shop() -> void:
	for p in _pedestals.duplicate():
		if game.player.pos.distance_to(p.at) >= TOUCH:
			continue
		if gold < p.price:
			if not p.get("warned", false):
				p.warned = true
				game.hud.show_notice(T.t(&"notice_no_gold"), 1.5)
			continue
		gold -= p.price
		game.room_tally.bought(RunMap.Reward.keys()[p.item].to_lower(), p.price)
		(p.node as Node3D).queue_free()
		_pedestals.erase(p)
		_give(p.item)


## Where the bot should walk when the room has no fight left (null: stay).
func bot_goal() -> Variant:
	if phase == Phase.REWARD and _reward_node != null:
		return _reward_at
	if phase == Phase.OPEN:
		for p in _pedestals:
			if gold >= p.price:
				return p.at
		if not game.arena.exits.is_empty():
			# the foot of its stairs (stepping on them leaves the room)
			return game.arena.door_goal(0)
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
func _marker(at: Vector2, reward: RunMap.Reward, text: String, kind: RunMap.Kind = RunMap.Kind.COMBAT) -> Node3D:
	var root := Node3D.new()
	root.position = Vector3(at.x, 0, at.y)
	add_child(root)
	var color := _reward_color(reward) if reward != RunMap.Reward.NONE else _kind_color(kind)
	var gem := MeshInstance3D.new()
	var shape: PrimitiveMesh = PrismMesh.new() if reward == RunMap.Reward.BOON else SphereMesh.new() if reward == RunMap.Reward.POM else BoxMesh.new()
	if shape is SphereMesh:
		(shape as SphereMesh).radius = 0.35
		(shape as SphereMesh).height = 0.7
	else:
		shape.set(&"size", Vector3(0.6, 0.6, 0.6))
	gem.mesh = shape
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = gem_color(color)
	gem.material_override = m
	gem.position.y = 1.6
	root.add_child(gem)
	_gems.append(gem)
	var light := OmniLight3D.new()
	light.position.y = 1.8
	light.light_color = color
	light.light_energy = 2.0
	light.omni_range = 5.0
	light.light_cull_mask = ~Arena.CROWD_LAYER
	root.add_child(light)
	if text != "":
		# the reward's name in gold, a second line (the shop's price) in pale under it (UI-01)
		var lines := text.split("\n", true, 1)
		var sign := DoorSign.make(lines[0], lines[1] if lines.size() > 1 else "")
		sign.position.y = 2.7
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
		RunMap.Reward.POM:
			return Color(1.0, 0.4, 0.35)
		RunMap.Reward.HEART:
			return Color(1.0, 0.3, 0.45)
		RunMap.Reward.MAGICK:
			return Color(0.45, 0.65, 1.0)
		RunMap.Reward.GOLD:
			return GOLD_COLOR
		RunMap.Reward.HEAL:
			return Color(0.5, 1.0, 0.6)
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
	return Color.WHITE
