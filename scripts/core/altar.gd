class_name Altar
extends RefCounted
## The Altar Esquecido (E5; docs/art/e5_spec.md section 6): a short room with no fight behind a door, where one simple
## trade may be made, or none: LIFE gives up StageDef.altar_life_cost of the most life for a pomegranate (one more level
## for a Blessing held, the paladin picks which); CANDLES lights the candles for StageDef.altar_gold_cost gold and gives
## StageDef.altar_magick more Magia at most. Only one; walking out takes nothing. Pure: Rooms puts each on the floor.

enum Option { LIFE, CANDLES }
## Ids for the log and the text (altar_<id>).
const IDS: Array[StringName] = [&"life", &"candles"]
## Least most life left after the trade.
const MIN_LIFE := 10.0


## What each option asks and gives, and whether it can be taken now: {option, id, cost, gain, ok}.
static func options(stage: StageDef, gold: int, max_hp: float, can_grow: bool) -> Array[Dictionary]:
	return [
		{"option": Option.LIFE, "id": IDS[Option.LIFE], "cost": stage.altar_life_cost, "gain": 1,
			"ok": can_grow and max_hp - stage.altar_life_cost >= MIN_LIFE},
		{"option": Option.CANDLES, "id": IDS[Option.CANDLES], "cost": stage.altar_gold_cost, "gain": stage.altar_magick,
			"ok": gold >= stage.altar_gold_cost},
	]


## The robot's choice (E5): the pomegranate when it has life to spare (BOT_LIFE of the most after the trade), else the
## candles when there is gold, else nothing (-1).
const BOT_LIFE := 35.0


static func bot_choice(opts: Array[Dictionary], max_hp: float) -> int:
	var life: Dictionary = opts[Option.LIFE]
	if life.ok and max_hp - float(life.cost) >= BOT_LIFE:
		return Option.LIFE
	if opts[Option.CANDLES].ok:
		return Option.CANDLES
	return -1
