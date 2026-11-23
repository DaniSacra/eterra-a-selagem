class_name Resonance
extends RefCounted
## The Maga's passive (maga.md 3): points filled by the Selos her blasts detonate, three diamonds of two points. Full, the
## next Explosão Rúnica comes out amplified (and costs no Magia), and it gives no points. No decay; it starts empty each
## descent. Pure.

var max_points := 6
var points := 0


func _init(most: int = 6) -> void:
	max_points = most


func add(n: int) -> void:
	points = clampi(points + n, 0, max_points)


func full() -> bool:
	return points >= max_points


## 0 to 3: the diamonds lit (a half counts as the diamond half lit: see half()).
func diamonds() -> int:
	return points / 2


func half() -> bool:
	return points % 2 == 1


## The blast being thrown: true when it is the amplified one (and the points go to zero); false and nothing changes else.
func take_amplified() -> bool:
	if not full():
		return false
	points = 0
	return true
