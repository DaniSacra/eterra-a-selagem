class_name RewardDeck
extends RefCounted
## The deck the doors' rewards come from (C13-02, Hades II's RunProgress): every door takes one card off it, never put
## back; when no card left may be drawn (all gone, or none valid for this door) the deck is filled again as it was
## made. Variety without the same reward over and over. Pure: the cards are RunMap.Reward values.

## The deck as it was made (StageDef.reward_deck).
var full: Array[int] = []
## The cards not drawn yet.
var left: Array[int] = []
## How many times it was filled again (for the tests and the tuning).
var refills := 0


func _init(cards: PackedInt32Array = PackedInt32Array()) -> void:
	full.assign(Array(cards))
	left = full.duplicate()


## Draws one card that valid accepts (valid.call(card) -> bool), taking it off the deck; fills the deck again when no
## card left is valid. Returns -1 when not even a full deck has one.
func draw(rng: RandomNumberGenerator, valid: Callable) -> int:
	var found := _valid(valid)
	if found.is_empty():
		left = full.duplicate()
		refills += 1
		found = _valid(valid)
		if found.is_empty():
			return -1
	var i: int = found[rng.randi() % found.size()]
	return left.pop_at(i)


func _valid(valid: Callable) -> Array[int]:
	var out: Array[int] = []
	for i in left.size():
		if valid.call(left[i]):
			out.append(i)
	return out
