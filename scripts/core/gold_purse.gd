class_name GoldPurse
extends RefCounted
## The gold a fight can give (C13-04, Hades II's MoneyDropOnDeath): each fight has a ceiling drawn between
## StageDef.gold_cap_min and gold_cap_max plus gold_per_depth a room of depth; every enemy that falls has
## gold_drop_chance of leaving its share of that ceiling (the ceiling times its rating over the fight's whole rating),
## until the ceiling is spent. On average a fight gives about gold_drop_chance of its ceiling. Pure.

## Gold still to give in this fight, and the fight's whole rating (EnemyDef.rating of every enemy in its waves).
var left := 0
var ceiling := 0
var total_rating := 1.0
var chance := 0.7


## The purse of one fight at this depth: its ceiling drawn now.
static func for_fight(stage: StageDef, depth: int, total: float, rng: RandomNumberGenerator) -> GoldPurse:
	var p := GoldPurse.new()
	p.ceiling = ceiling_at(stage, depth, rng)
	p.left = p.ceiling
	p.total_rating = maxf(total, 1.0)
	p.chance = stage.gold_drop_chance
	return p


## The ceiling of a fight at a depth: min to max, plus gold_per_depth a room (rounded down).
static func ceiling_at(stage: StageDef, depth: int, rng: RandomNumberGenerator) -> int:
	return rng.randi_range(stage.gold_cap_min, stage.gold_cap_max) + floori(stage.gold_per_depth * depth)


## An enemy of this rating fell: the gold it leaves (0 most of a time it does not, or once the ceiling is spent).
func drop(rating: float, rng: RandomNumberGenerator) -> int:
	if left <= 0 or rng.randf() >= chance:
		return 0
	var share := maxi(1, roundi(ceiling * maxf(rating, 0.0) / total_rating))
	var out := mini(share, left)
	left -= out
	return out
