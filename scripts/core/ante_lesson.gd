class_name AnteLesson
extends RefCounted
## PT-25-8, the Antessala that teaches (Daniel, 2026-11-25): short tips one at a time, each waiting for the gesture before
## the next. Pure: Rooms feeds it what the paladin did (`feed`) and the HUD's objective line shows `key()`. The steps are data
## (`ORDER`, the keys in data/text_pt.tres); a step the hero has no button for (no Brado nor Investida) is left out. A gesture
## made out of its turn still counts (he crossed the stream before the third click: that step is done), the line asks the
## first one not done. 2026-11-26: the Blessing is no step of the Antessala any more (the altar of the Sala 00 gives it); the
## last step is the trap's slab, passed by its side.
##   var l := AnteLesson.new(false)
##   l.feed(&"light"); l.feed(&"light"); l.feed(&"finisher")   # the three clicks
##   l.key() -> &"lesson_heavy"   (the next tip)
##   l.done() -> true when every step is done (the door opens)

## The steps in the order they are told, and the gesture each waits for. GP-1: the Warrior's are the attack (the three clicks),
## the Golpe Esmagador (the attack held), the Poder (the Corte Circular), the Especial (the Lança), the dodge (over the stream)
## and the trap (its slab passed by the side).
const ORDER: Array[StringName] = [&"attack", &"heavy", &"power", &"special", &"dodge", &"trap"]
## Maga Redesign V1 (F6): her four blows are the four steps, tap then hold, each told with her own words (KEYS_MAGA).
const ORDER_MAGA: Array[StringName] = [&"spark", &"breath", &"combust", &"winter", &"dodge", &"trap"]
## The text key of each step (Objective's line).
const KEYS := {&"attack": &"lesson_attack", &"heavy": &"lesson_heavy", &"special": &"lesson_special", &"power": &"lesson_power",
		&"dodge": &"lesson_dodge", &"trap": &"lesson_trap"}
## The Maga's own tips (the dodge and the trap are told as the Warrior's).
const KEYS_MAGA := {&"spark": &"lesson_spark_maga", &"breath": &"lesson_breath_maga", &"combust": &"lesson_combust_maga",
		&"winter": &"lesson_winter_maga", &"dodge": &"lesson_dodge", &"trap": &"lesson_trap"}
## Clicks of the attack that make the step (the chain's three blows; the finisher alone counts as the third).
const CLICKS := 3
## The events fed: &"light" (a blow of the attack's chain), &"finisher", &"heavy" (the Golpe Esmagador), &"special" (the Lança),
## &"power" (the Corte Circular), &"crossed" (over the stream), &"passed" (beyond the trap's slab). The Maga's Estilhaço is the
## power, her Geada the special. The Maga's are the id of the blow struck: spark, breath, combust, winter.
const EVENT_OF := {&"spark": &"spark", &"breath": &"breath", &"combust": &"combust", &"winter": &"winter", &"heavy": &"heavy", &"special": &"special", &"power": &"power", &"crossed": &"dodge", &"passed": &"trap"}

var steps: Array[StringName] = []
## The Maga's tips (KEYS_MAGA).
var arcane := false
var _done := {}
var _clicks := 0


## is_arcane: the Maga's tips (her four blows, then the dodge and the trap).
func _init(is_arcane := false) -> void:
	arcane = is_arcane
	steps.assign(ORDER_MAGA if is_arcane else ORDER)


## One thing the paladin did (see the events above).
func feed(event: StringName) -> void:
	if event == &"light" or event == &"finisher":
		_clicks += CLICKS if event == &"finisher" else 1
		if _clicks >= CLICKS:
			_done[&"attack"] = true
		return
	var step: StringName = EVENT_OF.get(event, &"")
	if step != &"":
		_done[step] = true


## Marks a step done at once (the robot's: it never reads a tip).
func skip(step: StringName) -> void:
	_done[step] = true


func is_done(step: StringName) -> bool:
	return bool(_done.get(step, false))


## The step the line asks now (&"": all done).
func current() -> StringName:
	for s in steps:
		if not is_done(s):
			return s
	return &""


## The text key of the tip now (&"": none left).
func key() -> StringName:
	var s := current()
	if s == &"":
		return &""
	return KEYS_MAGA[s] if arcane else KEYS[s]


## Every step done: the door may open.
func done() -> bool:
	return current() == &""
