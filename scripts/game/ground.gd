class_name Ground
extends Node2D
## Everything painted on the floor under the characters: shadows, the paladin's lasting marks,
## and every enemy warning. Each attack in the game is announced here before it lands.

signal hit_player(amount: float, from: Vector2)

enum Kind { MARK, EMBER, STEAM, WARNING }
enum Shape { CIRCLE, LINE, ARC }

const TICK := 0.25


class Zone:
	var kind: Kind
	var shape: Shape = Shape.CIRCLE
	var pos: Vector2
	var dir := Vector2.RIGHT
	var radius := 10.0
	var width := 10.0
	var life := 1.0
	var total := 1.0
	var power := 0.0
	var tick := 0.0
	var family: StringName = &"luz"


var zones: Array[Zone] = []
var enemies: EnemySystem
var player: Player
var fx: Fx
## Called for each enemy a lasting zone touches: (enemy, zone).
var on_zone_hit: Callable
var _found: Array[Enemy] = []
var _t := 0.0


## Colour that survives the darkness of the crypt (the canvas is multiplied by the ambient light).
static func glow(c: Color, alpha: float = 1.0) -> Color:
	return Color(c.r / Arena.AMBIENT.r, c.g / Arena.AMBIENT.g, c.b / Arena.AMBIENT.b, alpha)


func add_zone(kind: Kind, at: Vector2, radius: float, time: float, power: float, family: StringName = &"luz") -> Zone:
	var z := Zone.new()
	z.kind = kind
	z.pos = at
	z.radius = radius
	z.life = time
	z.total = time
	z.power = power
	z.family = family
	zones.append(z)
	return z


## A circle that hurts the paladin when the warning runs out.
func add_warning(at: Vector2, radius: float, delay: float, damage: float) -> Zone:
	return add_zone(Kind.WARNING, at, radius, delay, damage, &"perigo")


func add_line_warning(from: Vector2, dir: Vector2, length: float, width: float, delay: float, damage: float) -> Zone:
	var z := add_warning(from, length, delay, damage)
	z.shape = Shape.LINE
	z.dir = dir
	z.width = width
	return z


func add_arc_warning(at: Vector2, dir: Vector2, reach: float, degrees: float, delay: float, damage: float) -> Zone:
	var z := add_warning(at, reach, delay, damage)
	z.shape = Shape.ARC
	z.dir = dir
	z.width = degrees
	return z


func step(dt: float) -> void:
	_t += dt
	var i := zones.size() - 1
	while i >= 0:
		var z := zones[i]
		z.life -= dt
		if z.kind == Kind.WARNING:
			if z.life <= 0.0:
				_land(z)
		else:
			z.tick -= dt
			if z.tick <= 0.0:
				z.tick = TICK
				enemies.in_circle(z.pos, z.radius, _found)
				for e in _found:
					on_zone_hit.call(e, z)
		if z.life <= 0.0:
			zones[i] = zones[zones.size() - 1]
			zones.pop_back()
		i -= 1
	queue_redraw()


func _land(z: Zone) -> void:
	fx.burst(&"shadow", z.pos if z.shape != Shape.LINE else z.pos + z.dir * z.radius * 0.5)
	if z.power > 0.0 and inside(z, player.position):
		hit_player.emit(z.power, z.pos)


static func inside(z: Zone, p: Vector2) -> bool:
	var d := p - z.pos
	match z.shape:
		Shape.LINE:
			var along := d.dot(z.dir)
			return along >= 0.0 and along <= z.radius and absf(d.cross(z.dir)) <= z.width * 0.5
		Shape.ARC:
			return d.length() <= z.radius and (d.length() < 6.0 or absf(z.dir.angle_to(d)) <= deg_to_rad(z.width) * 0.5)
	return d.length() <= z.radius


func _draw() -> void:
	var shadow := Color(0.02, 0.01, 0.05, 0.38)
	for e in enemies.list:
		var r := e.def.radius
		draw_rect(Rect2(e.pos.x - r, e.pos.y - 1, r * 2.0, 3), shadow)
		if e.state == Enemy.State.WINDUP:
			_draw_enemy_warning(e)
	draw_rect(Rect2(player.position.x - 5, player.position.y - 1, 10, 3), shadow)
	for z in zones:
		match z.kind:
			Kind.WARNING:
				_draw_warning(z)
			Kind.MARK:
				_draw_mark(z)
			Kind.EMBER:
				_draw_embers(z)
			Kind.STEAM:
				_draw_steam(z)


## Aimed attacks of common enemies show their line while they wind up.
func _draw_enemy_warning(e: Enemy) -> void:
	var k := clampf(e.state_t / maxf(e.def.attack_windup, 0.01), 0.0, 1.0)
	var c := glow(Palette.c(&"perigo", 0), 0.35 + 0.4 * k)
	match e.def.behavior:
		EnemyDef.Behavior.ARCHER:
			draw_line(e.pos + Vector2(0, -8), e.pos + Vector2(0, -8) + e.dir * 110.0, c, 1.0)
		EnemyDef.Behavior.WOLF:
			draw_line(e.pos, e.pos + e.dir * 60.0, c, 3.0)
		EnemyDef.Behavior.KNIGHT:
			var side := e.dir.orthogonal() * 8.0
			var far := e.pos + e.dir * 150.0
			draw_colored_polygon(PackedVector2Array([e.pos + side, far + side, far - side, e.pos - side]), glow(Palette.c(&"perigo", 1), 0.25 + 0.3 * k))
			draw_line(e.pos + side, far + side, c, 1.0)
			draw_line(e.pos - side, far - side, c, 1.0)


func _draw_warning(z: Zone) -> void:
	var k := clampf(1.0 - z.life / z.total, 0.0, 1.0)
	var rim := glow(Palette.c(&"perigo", 0), 0.9)
	var fill := glow(Palette.c(&"perigo", 1), 0.3)
	var core := glow(Palette.c(&"perigo", 0), 0.45)
	match z.shape:
		Shape.CIRCLE:
			draw_circle(z.pos, z.radius, fill)
			draw_circle(z.pos, z.radius * k, core)
			draw_arc(z.pos, z.radius, 0.0, TAU, 24, rim, 1.0)
		Shape.LINE:
			var side := z.dir.orthogonal() * z.width * 0.5
			var far := z.pos + z.dir * z.radius
			draw_colored_polygon(PackedVector2Array([z.pos + side, far + side, far - side, z.pos - side]), fill)
			var mid := z.pos + z.dir * z.radius * k
			draw_colored_polygon(PackedVector2Array([z.pos + side, mid + side, mid - side, z.pos - side]), core)
			draw_line(z.pos + side, far + side, rim, 1.0)
			draw_line(z.pos - side, far - side, rim, 1.0)
		Shape.ARC:
			var a := z.dir.angle()
			var half := deg_to_rad(z.width) * 0.5
			draw_colored_polygon(_fan(z.pos, z.radius, a - half, a + half), fill)
			draw_colored_polygon(_fan(z.pos, z.radius * maxf(k, 0.1), a - half, a + half), core)
			draw_arc(z.pos, z.radius, a - half, a + half, 16, rim, 1.0)


func _fan(center: Vector2, radius: float, a0: float, a1: float) -> PackedVector2Array:
	var pts := PackedVector2Array([center])
	var steps := 12
	for i in steps + 1:
		pts.append(center + Vector2.from_angle(lerpf(a0, a1, float(i) / steps)) * radius)
	return pts


## The cross of light left by the E E D cut.
func _draw_mark(z: Zone) -> void:
	var blink := int(_t * 8.0) % 2
	var fade := 1.0 if z.life > 0.6 else 0.5
	var c0 := glow(Palette.c(z.family, 0), 0.85 * fade)
	var c1 := glow(Palette.c(z.family, 1 + blink), 0.6 * fade)
	var r := z.radius
	for d: Vector2 in [Vector2(1, 1).normalized(), Vector2(1, -1).normalized()]:
		draw_line(z.pos - d * r, z.pos + d * r, c1, 5.0)
		draw_line(z.pos - d * r * 0.85, z.pos + d * r * 0.85, c0, 1.0)
	draw_arc(z.pos, r, 0.0, TAU, 24, c1, 1.0)


func _draw_embers(z: Zone) -> void:
	var step := int(_t * 10.0)
	var n := 3 + int(z.radius / 3.0)
	for i in n:
		var h := hash(i * 7919 + int(z.pos.x) * 31 + int(z.pos.y) + step / 3 * 13)
		var p := z.pos + Vector2((h % 1000) / 1000.0 - 0.5, ((h / 1000) % 1000) / 1000.0 - 0.5) * z.radius * 1.7
		if p.distance_to(z.pos) > z.radius:
			continue
		var hot := (h / 7) % 3
		draw_rect(Rect2(p.x, p.y - (step + i) % 3, 2 if hot == 0 else 1, 2 if hot == 0 else 1), glow(Palette.c(&"luz" if hot == 0 else &"perigo", 1 if hot == 0 else hot - 1)))
	draw_arc(z.pos, z.radius, 0.0, TAU, 16, glow(Palette.c(&"perigo", 1), 0.35), 1.0)


func _draw_steam(z: Zone) -> void:
	var step := int(_t * 6.0)
	for i in 7:
		var h := hash(i * 104729 + int(z.pos.x) + step / 2 * 17)
		var p := z.pos + Vector2((h % 1000) / 1000.0 - 0.5, ((h / 1000) % 1000) / 1000.0 - 0.5) * z.radius * 1.6
		draw_circle(p + Vector2(0, -(step % 4)), 3.0 + (h / 13) % 3, glow(Palette.c(&"neve", (h / 3) % 3), 0.5))
