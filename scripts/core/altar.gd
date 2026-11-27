class_name Altar
extends RefCounted
## The Altar Esquecido (E5; docs/art/e5_spec.md section 6): a short room with no fight behind a door, where one simple
## trade may be made, or none: LIFE gives up StageDef.altar_life_cost of the most life for a pomegranate (one more level
## for a Blessing held, the paladin picks which); CANDLES lights the candles for StageDef.altar_gold_cost gold and gives
## StageDef.altar_magick more Magia at most. Only one; walking out takes nothing. Both last for the run only (nothing
## goes to the save). Pure: Rooms puts each on the floor.

enum Option { LIFE, CANDLES }
## Ids for the log and the text (altar_<id>).
const IDS: Array[StringName] = [&"life", &"candles"]
## Least most life left after the trade.
const MIN_LIFE := 10.0


## What each option asks and gives, and whether it can be taken now: {option, id, cost, gain, ok}. For the screen (T5;
## nothing here changes a rule): what is paid before and after (give_from, give_to), what is won before and after
## (get_from, get_to; the life trade wins a pomegranate, no number) and, when it cannot be taken, why (a text key, &""
## when it can) and the gold missing (short). magick_max: the Magia at most now.
## life_gain above 0: the candles give most life instead of Magia (a hero that spends none).
static func options(stage: StageDef, gold: int, max_hp: float, can_grow: bool, magick_max: float = 0.0, life_gain: float = 0.0) -> Array[Dictionary]:
	var life_why := &""
	if not can_grow:
		life_why = &"altar_why_grow"
	elif max_hp - stage.altar_life_cost < MIN_LIFE:
		life_why = &"altar_why_life"
	var short := maxi(stage.altar_gold_cost - gold, 0)
	var candles := {"option": Option.CANDLES, "id": IDS[Option.CANDLES], "cost": stage.altar_gold_cost, "gain": stage.altar_magick,
			"ok": gold >= stage.altar_gold_cost, "why": &"altar_why_gold" if short > 0 else &"", "short": short,
			"give_from": gold, "give_to": gold - stage.altar_gold_cost,
			"get_from": magick_max, "get_to": magick_max + stage.altar_magick}
	if life_gain > 0.0:
		candles.merge({"gain": life_gain, "life": true, "get_from": max_hp, "get_to": max_hp + life_gain}, true)
	return [
		{"option": Option.LIFE, "id": IDS[Option.LIFE], "cost": stage.altar_life_cost, "gain": 1,
			"ok": can_grow and max_hp - stage.altar_life_cost >= MIN_LIFE, "why": life_why,
			"give_from": max_hp, "give_to": max_hp - stage.altar_life_cost},
		candles,
	]


## The robot's choice (E5): the pomegranate when it has life to spare (BOT_LIFE of the most after the trade), else the
## candles when the gold left still buys the shop's healing (BOT_GOLD_KEEP; E6: the altar comes before the shop), else
## nothing (-1).
const BOT_LIFE := 35.0
const BOT_GOLD_KEEP := 50


static func bot_choice(opts: Array[Dictionary], max_hp: float, gold: int = 0) -> int:
	var life: Dictionary = opts[Option.LIFE]
	if life.ok and max_hp - float(life.cost) >= BOT_LIFE:
		return Option.LIFE
	var candles: Dictionary = opts[Option.CANDLES]
	if candles.ok and gold - int(candles.cost) >= BOT_GOLD_KEEP:
		return Option.CANDLES
	return -1
