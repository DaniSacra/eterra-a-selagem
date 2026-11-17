class_name ShopGroup
extends Resource
## One shelf of the shop (C13-04, Hades II's WorldShop): the shop shows count items of each group (one in Hades II's
## shops along the way; the last before the final boss shows five), different, drawn by weight. items are
## RunMap.Reward values; prices and weights one per item.

@export var items: PackedInt32Array = []
@export var prices: PackedInt32Array = []
@export var weights: PackedFloat32Array = []
@export var count := 1


## The indices of the items this group shows (up to count, different, in the order drawn), among those valid accepts.
func pick_all(rng: RandomNumberGenerator, valid: Callable) -> Array[int]:
	var out: Array[int] = []
	var free := func(item: int) -> bool:
		for i in out:
			if items[i] == item:
				return false
		return valid.call(item)
	for k in count:
		var i := pick(rng, free)
		if i < 0:
			break
		out.append(i)
	return out


## The index of the item this group shows, among those valid accepts (valid.call(item) -> bool); -1 when none is.
func pick(rng: RandomNumberGenerator, valid: Callable) -> int:
	var found: Array[int] = []
	var w := PackedFloat32Array()
	for i in items.size():
		if valid.call(items[i]):
			found.append(i)
			w.append(weights[i] if i < weights.size() else 1.0)
	if found.is_empty():
		return -1
	return found[rng.rand_weighted(w)]
