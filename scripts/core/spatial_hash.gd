class_name SpatialHash
extends RefCounted
## Buckets of things by grid cell, rebuilt every frame without allocating (bucket arrays are kept and cleared).

var cell := 16.0
var _buckets: Dictionary = {}
var _used: Array[Array] = []


func _init(cell_size: float = 16.0) -> void:
	cell = cell_size


func clear() -> void:
	for b in _used:
		b.clear()
	_used.clear()


static func key(cx: int, cy: int) -> int:
	return cx * 73856093 ^ cy * 19349663


func insert(pos: Vector2, item: Variant) -> void:
	var k := key(int(floor(pos.x / cell)), int(floor(pos.y / cell)))
	var b: Variant = _buckets.get(k)
	if b == null:
		b = []
		_buckets[k] = b
	if (b as Array).is_empty():
		_used.append(b)
	(b as Array).append(item)


## The bucket of a cell (possibly empty). Do not keep or modify it.
func at_cell(cx: int, cy: int) -> Array:
	var b: Variant = _buckets.get(key(cx, cy))
	return b if b != null else _EMPTY


const _EMPTY: Array = []
