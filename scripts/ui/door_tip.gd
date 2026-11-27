class_name DoorTip
extends Control
## What an exit door tells (Daniel 2026-11-23, principle from another game, nothing copied). While the descent's doors
## stand open, each one's medallion carries the small seal of its main modifier at the lower right (DoorSeal: a skull
## for a bigger enemy, the crowned skull for a guardian, the Provação's diamond, the angel's mark, a find), and its
## ring of energy (DoorRing) burns stronger as the hero comes near. The door the hero stands at (the one F enters, Arena.exit_at) also shows a
## dark box beside its medallion: "Recompensa: <name>" with its mark, one line per modifier with its seal and what it
## means, and the key that enters. The box fades in and out in FADE seconds, stays off the hero and off the other
## medallions. Display only: it reads the rooms' public values and never touches the run.
##   describe(room, silver, angel_family) -> {title, glyph, mods: [{id, text, family?}]}   (pure, tested)

## Metres from a door's use spot where the ring is full and where it starts to answer (the box itself follows Arena.exit_at).
const NEAR := 4.2
## U-1: the box and the "F enters" key show only with the doors open and the hero this close (metres) to the door's spot.
const TIP_RANGE := 6.0
const RING_FAR := 7.5
const FADE := 0.15
const WIDTH := 270.0
const GAP := 12.0
const EDGE := 8.0
const SEAL_PX := 22.0
const BADGE_MIN := 16.0
const BADGE_MAX := 34.0
const VEIL := Color(0.035, 0.027, 0.04, 0.9)
const TITLE_PX := 17
const LINE_PX := 15
const GLYPH_PX := 20.0

var game: Game
var _seals := {}
var _box: PanelContainer
var _shown_door := -1
var _built_for: RunMap.Room
var _alpha := 0.0
var _key: StationSign.KeyCap


## What the box says of a room: the title ("Recompensa: Ouro", or the room's name when it gives nothing), the mark of
## it (DoorGlyph.Kind) and the modifiers in order of weight. silver: what the elite leaves (Rooms.sign_silver);
## angel_family: the angel's Boon.Family (-1: unknown).
static func describe(r: RunMap.Room, silver := 0, angel_family := -1) -> Dictionary:
	var info := r.sign()
	var title := T.t(RunMap.KIND_KEY[r.kind])
	var glyph := DoorGlyph.of(info)
	if r.reward != RunMap.Reward.NONE:
		title = T.t(&"door_tip_reward", {"name": T.t(RunMap.REWARD_KEY[r.reward])})
		glyph = DoorGlyph.of_reward(r.reward)
	elif r.kind == RunMap.Kind.TRIAL:
		# BG-2: the sign over the door already says "Provação": the box says what it gives instead of the same word
		title = T.t(&"trial_slab_offer")
	var mods: Array[Dictionary] = []
	if r.kind == RunMap.Kind.MINIBOSS:
		mods.append({"id": &"guardian", "text": T.t(&"door_mod_guardian")})
	elif bool(info.hard):
		var text := T.t(&"door_mod_hard_silver", {"n": silver}) if silver > 0 else T.t(&"door_mod_hard")
		mods.append({"id": &"hard", "text": text})
	if r.kind == RunMap.Kind.TRIAL or (r.trial and not r.hidden):
		mods.append({"id": &"trial", "text": T.t(&"door_mod_trial")})
	if r.reward == RunMap.Reward.BOON:
		if r.meeting:
			mods.append({"id": &"angel", "text": T.t(&"door_mod_angels"), "family": Boon.Family.DUO})
		elif r.angel != &"":
			mods.append({"id": &"angel", "text": T.t(&"door_mod_angel", {"name": T.t(StringName("angel_" + String(r.angel)))}),
				"family": angel_family if angel_family >= 0 else Boon.Family.LUZ})
	if r.find != &"":
		mods.append({"id": &"find", "text": T.t(&"door_mod_find", {"name": UiKit.find_name(r.find)})})
	return {"title": title, "glyph": glyph, "mods": mods}


func _ready() -> void:
	name = "DoorTip"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## The doors that stand open now (rooms in the OPEN phase, the paladin in control), else none.
func _doors() -> Array[RunMap.Room]:
	var none: Array[RunMap.Room] = []
	if game == null or game.rooms == null or game.arena == null or game.player == null:
		return none
	if game.mode != Game.Mode.PLAY or game.rooms.phase != Rooms.Phase.OPEN:
		return none
	return game.rooms.next_rooms


## The door the key works on now (-1: none): the same test as Rooms.usable and the interact press, the exit zone the hero
## stands in (Arena.exit_at), so the box shows exactly while F enters.
## SW-C9: the hero is by the open doors (within BANNER_RANGE m of a door's sign): the HUD's greetings wait, so they never
## hide the medallions he is choosing between.
const BANNER_RANGE := 9.0


func hero_by_doors() -> bool:
	for i in _doors().size():
		if game.player.pos.distance_to(game.arena.door_label(i)) <= BANNER_RANGE:
			return true
	return false


func near_door() -> int:
	var doors := _doors()
	var i := door_at(game.arena, game.player.pos, doors.size())
	return i if i >= 0 and tip_allowed(true, game.player.pos.distance_to(game.arena.door_label(i))) else -1


## U-1 (pure): the tip is for open doors only (Rooms.Phase.OPEN) and a hero within TIP_RANGE of the door.
static func tip_allowed(doors_open: bool, distance: float) -> bool:
	return doors_open and distance <= TIP_RANGE


## The test itself (pure): the exit zone of `pos` when it is one of the `count` open doors, else -1.
static func door_at(arena: Arena, pos: Vector2, count: int) -> int:
	var door := arena.exit_at(pos)
	return door if door >= 0 and door < count else -1


## Whether the box shows now (tests).
func box_visible() -> bool:
	return _box != null and _box.visible


## The lines the box shows now: title then each modifier's text (tests).
func box_lines() -> PackedStringArray:
	var out := PackedStringArray()
	if _box == null:
		return out
	for l in _box.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return out


func _process(delta: float) -> void:
	var rooms := _doors()
	var cam := get_viewport().get_camera_3d()
	if rooms.is_empty() or cam == null:
		_hide_all(delta)
		return
	var screen := get_viewport().get_visible_rect().size
	var discs: Array[Rect2] = []
	for i in rooms.size():
		var at := game.arena.door_anchor(i) + game.rooms.door_pull(i)
		var behind := cam.is_position_behind(at)
		var centre := cam.unproject_position(at)
		var rad := centre.distance_to(cam.unproject_position(at + cam.global_transform.basis.x * RewardGem.RADIUS * RewardGem.DOOR_SCALE))
		discs.append(Rect2(centre - Vector2(rad, rad), Vector2(rad, rad) * 2.0))
		var away := game.hud != null and game.hud.door_arrow != null and game.hud.door_arrow.shown  # the arrow stands for them
		_seal(i, rooms[i], centre + Vector2(rad, rad) * 0.7, clampf(rad * 0.62, BADGE_MIN, BADGE_MAX), not behind and not away)
		var d := game.player.pos.distance_to(game.arena.door_label(i))
		_ring(i, clampf((RING_FAR - d) / (RING_FAR - NEAR), 0.0, 1.0))
	for i in _seals.keys():
		if i >= rooms.size():
			(_seals[i] as Control).queue_free()
			_seals.erase(i)
	var near := near_door()
	if near >= 0:
		if near != _shown_door or _built_for != rooms[near]:
			_build(near, rooms[near])
		_alpha = minf(_alpha + delta / FADE, 1.0)
		_place(discs, near, screen, cam)
	else:
		_alpha = maxf(_alpha - delta / FADE, 0.0)
	if _box != null:
		_box.modulate.a = _alpha
		_box.visible = _alpha > 0.0
		if _key != null and _key.text != UiKit.action_label(&"interact"):
			_key.set_key(UiKit.action_label(&"interact"), Controls.using_pad)


func _hide_all(delta: float) -> void:
	for s: Control in _seals.values():
		s.visible = false
	_alpha = maxf(_alpha - delta / FADE, 0.0)
	if _box != null:
		_box.modulate.a = _alpha
		_box.visible = _alpha > 0.0


func _seal(i: int, r: RunMap.Room, at: Vector2, px: float, shown: bool) -> void:
	var mods: Array = describe(r, Rooms.sign_silver, _family(r)).mods
	var s: DoorSeal = _seals.get(i)
	# BG-2: the Provação's own medallion needs no badge (it was a dark dot with a tiny diamond beside it)
	if mods.is_empty() or not shown or r.kind == RunMap.Kind.TRIAL:
		if s != null:
			s.visible = false
		return
	var main: Dictionary = mods[0]
	if s == null or s.id != main.id:
		if s != null:
			s.queue_free()
		s = DoorSeal.new().setup(main.id, px, main.get("family", Boon.Family.LUZ))
		s.name = "Seal%d" % i
		add_child(s)
		_seals[i] = s
	s.custom_minimum_size = Vector2(px, px)
	s.size = s.custom_minimum_size
	s.position = (at - s.size * 0.5).round()
	s.visible = true


func _family(r: RunMap.Room) -> int:
	if r.angel != &"" and game.encounters != null:
		var who := game.encounters.book.find(r.angel)
		if who != null:
			return who.family
	return -1


func _ring(i: int, k: float) -> void:
	for n in get_tree().get_nodes_in_group(DoorRing.GROUP):
		var ring := n as DoorRing
		if ring != null and ring.door == i:
			ring.target = k


func _build(i: int, r: RunMap.Room) -> void:
	if _box != null:
		_box.queue_free()
	_shown_door = i
	_built_for = r
	var d := describe(r, Rooms.sign_silver, _family(r))
	_box = PanelContainer.new()
	_box.name = "box"
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := UiKit.box(VEIL, UiKit.OLD_GOLD, 1, 10, 3)
	sb.content_margin_top = 7
	sb.content_margin_bottom = 8
	_box.add_theme_stylebox_override(&"panel", sb)
	add_child(_box)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", 5)
	_box.add_child(v)
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override(&"separation", 8)
	if d.glyph != DoorGlyph.Kind.NONE:
		var g := DoorGlyph.new().setup(d.glyph, GLYPH_PX)
		g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(g)
	var title := UiKit.label(d.title, DoorSign.TITLE_COLOR, TITLE_PX, UiKit.TITLE_FONT)
	title.name = "title"
	head.add_child(title)
	v.add_child(head)
	for m: Dictionary in d.mods:
		var row := HBoxContainer.new()
		row.name = "mod_%s" % m.id
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override(&"separation", 8)
		var s := DoorSeal.new().setup(m.id, SEAL_PX, m.get("family", Boon.Family.LUZ))
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(s)
		var l := UiKit.label(m.text, UiKit.PALE, LINE_PX, UiKit.TEXT_FONT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = WIDTH - SEAL_PX - 28.0
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		v.add_child(row)
	var use := HBoxContainer.new()
	use.name = "use"
	use.mouse_filter = Control.MOUSE_FILTER_IGNORE
	use.alignment = BoxContainer.ALIGNMENT_CENTER
	use.add_theme_constant_override(&"separation", 7)
	_key = StationSign.KeyCap.new()
	_key.set_key(UiKit.action_label(&"interact"), Controls.using_pad)
	use.add_child(_key)
	use.add_child(UiKit.label(T.t(&"hub_use_door"), DoorSign.HINT_COLOR, 14, UiKit.BOLD_FONT))
	v.add_child(use)
	_box.custom_minimum_size.x = WIDTH
	_box.reset_size()


## Beside the medallion: to its right, else its left; clear of the other medallions, the hero and the screen's edges.
func _place(discs: Array[Rect2], near: int, screen: Vector2, cam: Camera3D) -> void:
	var s := _box.get_combined_minimum_size()
	_box.size = s
	var me := discs[near]
	var hf := cam.unproject_position(Vector3(game.player.pos.x, 0.0, game.player.pos.y))
	var hh := cam.unproject_position(Vector3(game.player.pos.x, StationSign.HERO_HEIGHT, game.player.pos.y))
	var hero := StationSign.hero_box(hh, hf)
	var others: Array[Rect2] = []
	for i in discs.size():
		if i != near:
			others.append(discs[i].grow(4.0))
	var best := Vector2.ZERO
	var best_cost := INF
	for side: int in [1, -1]:
		var x := me.end.x + GAP if side == 1 else me.position.x - GAP - s.x
		for lift: float in [0.0, -1.0, 1.0]:
			var y := me.get_center().y - s.y * 0.5 + lift * (s.y * 0.5 + 6.0)
			var p := Vector2(clampf(x, EDGE, maxf(EDGE, screen.x - EDGE - s.x)), clampf(y, EDGE, maxf(EDGE, screen.y - EDGE - s.y)))
			var rect := Rect2(p, s)
			var cost := absf(p.x - x) * 2.0 + absf(lift) * 20.0 + (0.0 if side == 1 else 5.0)
			if rect.intersects(hero):
				cost += 1000.0
			for o in others:
				if rect.intersects(o):
					cost += 500.0
			if rect.intersects(me.grow(2.0)):
				cost += 800.0
			if cost < best_cost:
				best_cost = cost
				best = p
	_box.position = best.round()
