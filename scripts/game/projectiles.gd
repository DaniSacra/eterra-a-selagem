class_name Projectiles
extends Node2D
## Arrows, shadow bolts and falling blades of the enemies, and the paladin's wave of light. Pooled records, one draw.

signal hit_player(amount: float, from: Vector2)
signal wave_hit(e: Enemy, shot: Shot)

enum Kind { ARROW, BOLT, WAVE }


class Shot:
	var kind: Kind
	var pos: Vector2
	var vel: Vector2
	var damage := 0.0
	var life := 3.0
	var radius := 3.0
	var id := 0
	var family: StringName = &"luz"
	var knockback := 0.0


var shots: Array[Shot] = []
var enemies: EnemySystem
var player: Player
var _found: Array[Enemy] = []
var _next_id := 1000000


func fire(kind: Kind, from: Vector2, dir: Vector2, speed: float, damage: float, life: float = 3.0) -> Shot:
	var s := Shot.new()
	s.kind = kind
	s.pos = from
	s.vel = dir * speed
	s.damage = damage
	s.life = life
	s.radius = 2.0 if kind == Kind.ARROW else 3.0
	shots.append(s)
	return s


## The paladin's wave: flies forward and passes through every enemy once.
func fire_wave(from: Vector2, dir: Vector2, damage: float, distance: float, radius: float, family: StringName) -> Shot:
	var s := fire(Kind.WAVE, from, dir, 190.0, damage, distance / 190.0)
	s.radius = radius
	s.family = family
	s.knockback = 60.0
	_next_id += 1
	s.id = _next_id
	return s


func step(dt: float) -> void:
	var target := player.position + Vector2(0, -7)
	var i := shots.size() - 1
	while i >= 0:
		var s := shots[i]
		s.pos += s.vel * dt
		s.life -= dt
		var done := s.life <= 0.0
		if s.kind == Kind.WAVE:
			enemies.in_circle(s.pos + Vector2(0, 8), s.radius, _found)
			for e in _found:
				if e.hit_mark != s.id:
					e.hit_mark = s.id
					wave_hit.emit(e, s)
		elif s.pos.distance_squared_to(target) < (s.radius + 4.0) * (s.radius + 4.0):
			hit_player.emit(s.damage, s.pos - s.vel.normalized() * 4.0)
			done = true
		if done:
			shots[i] = shots[shots.size() - 1]
			shots.pop_back()
		i -= 1
	queue_redraw()


func clear_hostile() -> void:
	shots = shots.filter(func(s: Shot) -> bool: return s.kind == Kind.WAVE)


func _draw() -> void:
	for s in shots:
		var d := s.vel.normalized()
		match s.kind:
			Kind.ARROW:
				draw_line(s.pos - d * 5.0, s.pos, Palette.c(&"materia", 3), 1.0)
				draw_rect(Rect2(s.pos.x - 1, s.pos.y - 1, 2, 2), Palette.c(&"neve", 0))
			Kind.BOLT:
				draw_circle(s.pos, 3.0, Palette.c(&"misterio", 3))
				draw_circle(s.pos, 2.0, Palette.c(&"misterio", 1))
				draw_rect(Rect2(s.pos.x - 1, s.pos.y - 1, 1, 1), Palette.c(&"misterio", 0))
			Kind.WAVE:
				var a := d.angle()
				draw_arc(s.pos - d * s.radius * 0.6, s.radius, a - 0.9, a + 0.9, 10, Palette.c(s.family, 1), 3.0)
				draw_arc(s.pos - d * s.radius * 0.6, s.radius + 1.0, a - 0.7, a + 0.7, 10, Palette.c(s.family, 0), 1.0)
