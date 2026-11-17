extends RefCounted
## Laboratory plans of the five rooms of E5 (docs/art/e5_spec.md sections 1, 2, 3, 5.2 and 6.3), with the spec's
## numbers, for the environment's labs and tests until the stage's own plans come from tools/make_data.gd (the
## gameplay engineer's). The looks never read these: they draw whatever RoomLayout they are given (look ids
## &"sanctuary", &"bridge", &"runes", &"trial", &"altar"). Contract with the data, besides the spec's tables:
##   - a fallen column's base is piece &"column_base" (low, stops bodies only), its drums &"drums" (a capsule box);
##   - a stone bench is &"bench" (whole) or &"bench_broken" (half its back gone), a box 2.0 x 0.6, top 0.9;
##   - the bridge's pylon is &"pylon" (a box, 6 m), the rune pillars &"rune_pillar" (boxes of 1.2, 4 m);
##   - the runes' quiet stone (variant B) is a box &"quiet" that stops nothing (blocks_move and blocks_shots false);
##   - the trial's block is &"trial_block" (box 1.2, top 1.1), the altar &"altar" (box 3.6 x 1.6, top 1.3);
##   - fire bowls in a wall's recesses beside a north door are &"brazier" circles of the layout, off the floor (as in
##     the crypt), their middle at least 0.9 m beyond the edge (the bowl and its fire are 0.7 m round); the sanctuary's two chancel braziers are the look's own (on the grille's pillars), never in the data;
##   - the sanctuary's guardian stands at boss_spawn: the chancel is drawn behind the west edge across from it.
## Use: const E5 := preload("res://tools/e5_layouts.gd"); E5.layout(&"runes", 1).

const IDS: Array[StringName] = [&"sanctuary", &"bridge", &"runes", &"trial", &"altar"]


## The plan of `id` in variant n (0: A).
static func layout(id: StringName, n := 0) -> RoomLayout:
	var l: RoomLayout
	match id:
		&"sanctuary":
			l = sanctuary()
		&"bridge":
			l = bridge()
		&"runes":
			l = runes()
		&"trial":
			l = trial()
		&"altar":
			l = altar()
	return l.variant(n) if l != null else null


static func _poly(xz: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, xz.size(), 2):
		out.append(Vector2(xz[i], xz[i + 1]))
	return out


static func _rect(x0: float, x1: float, z0: float, z1: float) -> Rect2:
	return Rect2(x0, z0, x1 - x0, z1 - z0)


static func _column(x: float, z: float, top: float, r := 0.7) -> ArenaObstacle:
	return ArenaObstacle.circle(Vector2(x, z), r, &"column", top, top >= 1.25, true)


static func _box(x: float, z: float, w: float, d: float, top: float, piece: StringName, see := false) -> ArenaObstacle:
	return ArenaObstacle.box(Vector2(x, z), Vector2(w, d) * 0.5, 0.0, piece, top, top >= 1.25, see)


static func _capsule(a: Vector2, b: Vector2, width: float, top: float, piece: StringName) -> ArenaObstacle:
	var d := b - a
	return ArenaObstacle.box((a + b) * 0.5, Vector2(d.length() * 0.5 + width * 0.5, width * 0.5), d.angle(), piece, top, top >= 1.25)


static func _bowl(x: float, z: float) -> ArenaObstacle:
	var o := ArenaObstacle.circle(Vector2(x, z), 0.45, &"brazier", 1.2, false)
	o.blocks_move = false
	return o


static func _base(l: RoomLayout, id: StringName, size: RoomLayout.Size) -> void:
	l.id = id
	l.name_key = StringName("arena_" + String(id))
	l.look = id
	l.size_class = size


## Santuário Desmoronado (spec 1).
static func sanctuary() -> RoomLayout:
	var l := RoomLayout.new()
	_base(l, &"sanctuary", RoomLayout.Size.LARGE)
	var outline := _poly([-22, -14, 14, -14, 22, -6, 22, 14, -18, 14, -22, 10])
	l.floor = FloorShape.poly([outline])
	l.half = l.floor.extent()
	var common: Array[ArenaObstacle] = [
		_box(-12, -13.4, 2.5, 1.2, 1.35, &"sarcophagus"), _box(-4, -13.4, 2.5, 1.2, 1.35, &"sarcophagus"),
		_box(-12, 10.2, 2.0, 0.6, 0.9, &"bench_broken"), _box(6, 10.2, 2.0, 0.6, 0.9, &"bench_broken"),
		_bowl(4.3, -14.9), _bowl(8.7, -14.9),
	]
	var a: Array[ArenaObstacle] = [
		_column(-15, -6, 5.2, 0.65), _column(-9, -6, 5.2, 0.65), _column(-3, -6, 5.2, 0.65), _column(9, -6, 5.2, 0.65),
		_column(-15, 6, 5.2, 0.65), _column(-3, 6, 5.2, 0.65), _column(3, 6, 5.2, 0.65), _column(9, 6, 5.2, 0.65),
		_column(15, 6, 5.2, 0.65), _column(15, -6, 3.4, 0.65), _column(-9, 6, 3.0, 0.65),
	]
	var stump := ArenaObstacle.circle(Vector2(3, -6), 0.65, &"column_base", 0.6, false)
	a.append(stump)
	a.append(_capsule(Vector2(3, -6.9), Vector2(3, -9.8), 1.1, 1.0, &"drums"))
	a.append_array(common)
	l.obstacles = a
	var b: Array[ArenaObstacle] = [
		_column(-15, -6, 5.2, 0.65), _column(-9, -6, 3.2, 0.65), _column(-3, -6, 5.2, 0.65), _column(15, -6, 3.4, 0.65),
		_column(-15, 6, 5.2, 0.65), _column(-9, 6, 3.0, 0.65), _column(-3, 6, 5.2, 0.65), _column(15, 6, 5.2, 0.65),
	]
	b.append_array(common)
	var v := ArenaVariant.new()
	v.obstacles = b
	v.floor = FloorShape.poly([outline], [_poly([1, -3.2, 4.5, -3.5, 9, -3.1, 9.4, 0, 9, 3.1, 4.5, 3.5, 1, 3.2, 0.6, 0])])
	l.variants = [v]
	l.hero_spawn = Vector2(19.5, 2)
	l.hero_facing = Vector2(-1, 0)
	l.boss_spawn = Vector2(-17, 0)
	l.exits = [ArenaExit.at_edge(Vector2(6.5, -14), Vector2(0, 1)), ArenaExit.at_edge(Vector2(-6, 14), Vector2(0, -1)),
		ArenaExit.at_edge(Vector2(-22, -10.5), Vector2(1, 0))]
	l.spawns = [_rect(-20, -14, -3, 3), _rect(-19, -15, 8, 11), _rect(-8, -2, -12, -8.5)]
	l.late_spawns = [_rect(10, 16, 8, 12)]
	l.cam_bounds = _rect(-10, 10, -2, 2)
	return l


## Ponte dos Condenados (spec 2).
static func bridge() -> RoomLayout:
	var l := RoomLayout.new()
	_base(l, &"bridge", RoomLayout.Size.LONG)
	var west := _poly([-28, -6, -25, -9, -15, -9, -14, -7, -14, 7, -16, 9, -26, 9, -28, 7])
	var east := _poly([14, -7, 15, -9, 25, -9, 28, -6, 28, 7, 26, 9, 16, 9, 14, 7])
	l.floor = FloorShape.poly([west, _poly([-14.05, -2.5, -6.95, -2.5, -6.95, 2.5, -14.05, 2.5]),
		_poly([-7, -6, -5, -8, 5, -8, 7, -6, 7, 6, 5, 8, -5, 8, -7, 6]),
		_poly([6.95, -2.5, 14.05, -2.5, 14.05, 2.5, 6.95, 2.5]), east])
	l.half = l.floor.extent()
	var ends: Array[ArenaObstacle] = [_column(-21, -4, 3.0), _box(21, -4.8, 2.5, 1.2, 1.35, &"sarcophagus"), _column(20, 4.5, 3.6)]
	var a: Array[ArenaObstacle] = [_box(0, -7.2, 2.8, 1.6, 6.0, &"pylon", true), _box(2.5, 2.5, 1.0, 3.2, 2.2, &"block", true),
		_column(-2.5, 3.5, 3.4)]
	a.append_array(ends)
	l.obstacles = a
	var v := ArenaVariant.new()
	v.obstacles = ends
	v.floor = FloorShape.poly([_poly([-28, -6, -25, -9, -13, -9, -12, -7, -12, 7, -14, 9, -26, 9, -28, 7]),
		_poly([-12.05, -2.5, -2.95, -2.5, -2.95, 2.5, -12.05, 2.5]), _poly([-3, -4.5, 3, -4.5, 3, 4.5, -3, 4.5]),
		_poly([2.95, -2.5, 12.05, -2.5, 12.05, 2.5, 2.95, 2.5]),
		_poly([12, -7, 13, -9, 25, -9, 28, -6, 28, 7, 26, 9, 14, 9, 12, 7])])
	v.spawns = [_rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	l.variants = [v]
	l.hero_spawn = Vector2(-24.5, 0)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(21, -9), Vector2(0, 1)), ArenaExit.at_edge(Vector2(28, 0.5), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(21, 9), Vector2(0, -1))]
	l.spawns = [_rect(-4, 4, -5.5, -3), _rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	l.late_spawns = [_rect(-26, -20, -7, -4)]
	l.cam_bounds = _rect(-14, 14, -1, 1)
	return l


## Câmara das Runas Instáveis (spec 3).
static func runes() -> RoomLayout:
	var l := RoomLayout.new()
	_base(l, &"runes", RoomLayout.Size.MEDIUM)
	l.floor = FloorShape.poly([_poly([-15, -9, -12, -12, 12, -12, 15, -9, 15, 9, 12, 12, -12, 12, -15, 9])])
	l.half = l.floor.extent()
	var bowls: Array[ArenaObstacle] = [_bowl(3.8, -12.9), _bowl(8.2, -12.9)]
	var a: Array[ArenaObstacle] = []
	for p: Vector2 in [Vector2(-6, -6), Vector2(6, -6), Vector2(-6, 6), Vector2(6, 6)]:
		a.append(_box(p.x, p.y, 1.2, 1.2, 4.0, &"rune_pillar", true))
	a.append_array(bowls)
	l.obstacles = a
	var b: Array[ArenaObstacle] = [_box(-9, -6, 1.2, 1.2, 4.0, &"rune_pillar", true), _box(9, 6, 1.2, 1.2, 4.0, &"rune_pillar", true)]
	var quiet := ArenaObstacle.box(Vector2.ZERO, Vector2(3, 3), 0.0, &"quiet", 0.0, false)
	quiet.blocks_move = false
	b.append(quiet)
	b.append_array(bowls)
	var v := ArenaVariant.new()
	v.obstacles = b
	l.variants = [v]
	l.hero_spawn = Vector2(-12.5, 3.5)
	l.hero_facing = Vector2(1, 0)
	l.exits = [ArenaExit.at_edge(Vector2(6, -12), Vector2(0, 1)), ArenaExit.at_edge(Vector2(15, 0), Vector2(-1, 0)),
		ArenaExit.at_edge(Vector2(-4.5, 12), Vector2(0, -1))]
	l.spawns = [_rect(-4, 3, -11, -8), _rect(10, 13.5, -4, 4), _rect(0, 9, 8, 11)]
	l.late_spawns = [_rect(-13, -9, -9.5, -6)]
	l.cam_target = Vector2(0.5, 1)
	l.cam_reach = 3.5
	return l


## A Câmara da Provação (spec 5.2): no fight.
static func trial() -> RoomLayout:
	var l := RoomLayout.new()
	_base(l, &"trial", RoomLayout.Size.SMALL)
	l.floor = FloorShape.poly([_poly([-8, -5.5, -6.5, -7, 6.5, -7, 8, -5.5, 8, 5.5, 6.5, 7, -6.5, 7, -8, 5.5])])
	l.half = l.floor.extent()
	l.obstacles = [_box(0, 0, 1.2, 1.2, 1.1, &"trial_block")]
	l.guardian = false
	l.hero_spawn = Vector2(-5.5, 4.5)
	l.hero_facing = Vector2(1, -1)
	l.exits = [ArenaExit.at_edge(Vector2(0, -7), Vector2(0, 1))]
	l.cam_target = Vector2(0, 0.5)
	l.cam_reach = 1.0
	return l


## O Altar Esquecido (spec 6.3): no fight.
static func altar() -> RoomLayout:
	var l := RoomLayout.new()
	_base(l, &"altar", RoomLayout.Size.SMALL)
	l.floor = FloorShape.poly([_poly([-9, -7, 9, -7, 9, 7, -9, 7])])
	l.half = l.floor.extent()
	l.obstacles = [_box(0, -6.2, 3.6, 1.6, 1.3, &"altar"), _box(-3, -1, 2.0, 0.6, 0.9, &"bench"),
		_box(3, -1.5, 2.0, 0.6, 0.9, &"bench_broken")]
	l.guardian = false
	l.hero_spawn = Vector2(-6.5, 4.5)
	l.hero_facing = Vector2(1, -1)
	l.exits = [ArenaExit.at_edge(Vector2(9, 2), Vector2(-1, 0))]
	l.cam_target = Vector2.ZERO
	l.cam_reach = 1.0
	return l
