class_name Orbs
extends Node2D
## Orbs of light left by fallen enemies: experience. Records in an array, one draw call each, no nodes.

const MAGNET := 30.0
const PICKUP := 7.0
const FLY_SPEED := 190.0
const MAX_ACTIVE := 260

var pos: PackedVector2Array = PackedVector2Array()
var value: PackedInt32Array = PackedInt32Array()
var flying: PackedByteArray = PackedByteArray()
var _t := 0.0
var _rng := RandomNumberGenerator.new()


func drop(at: Vector2, amount: int) -> void:
	if pos.size() >= MAX_ACTIVE:
		# the hall is full of light: an old orb takes the new one in
		value[_rng.randi() % value.size()] += amount
		return
	pos.append(at + Vector2(_rng.randf_range(-3, 3), _rng.randf_range(-3, 3)))
	value.append(amount)
	flying.append(0)


## Pulls nearby orbs to the paladin. Returns the experience collected this step.
func step(dt: float, target: Vector2, pull_all: bool = false) -> int:
	_t += dt
	var got := 0
	var i := pos.size() - 1
	while i >= 0:
		var d := target - pos[i]
		var dist_sq := d.length_squared()
		if flying[i] == 0 and (pull_all or dist_sq < MAGNET * MAGNET):
			flying[i] = 1
		if flying[i] == 1:
			pos[i] += d.normalized() * FLY_SPEED * dt
			if dist_sq < PICKUP * PICKUP:
				got += value[i]
				var last := pos.size() - 1
				pos[i] = pos[last]
				value[i] = value[last]
				flying[i] = flying[last]
				pos.resize(last)
				value.resize(last)
				flying.resize(last)
		i -= 1
	queue_redraw()
	return got


func _draw() -> void:
	var tex := Art.tex(&"orb")
	var glow := Ground.glow(Color.WHITE)
	var phase := int(_t * 5.0)
	for i in pos.size():
		var frame := (phase + i) % 2
		draw_texture_rect_region(tex, Rect2(pos[i] - Vector2(3, 5), Vector2(7, 7)), Rect2(frame * 7, 0, 7, 7), glow)
