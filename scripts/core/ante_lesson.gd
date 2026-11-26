class_name AnteLesson
extends RefCounted
## PT-25-8, the Antessala that teaches (Daniel, 2026-11-25): short tips one at a time, each waiting for the gesture before
## the next. Pure: Rooms feeds it what the paladin did (`feed`) and the HUD's objective line shows `key()`. The steps are data
## (`ORDER`, the keys in data/text_pt.tres); a step the hero has no button for (no Brado nor Investida) is left out. A gesture
## made out of its turn still counts (he crossed the stream before the third click: that step is done), the line asks the
## first one not done.
##   var l := AnteLesson.new(true, true)
##   l.feed(&"light"); l.feed(&"light"); l.feed(&"finisher")   # the three clicks
##   l.key() -> &"lesson_special"   (the next tip)
##   l.done() -> true when every step and the Blessing are done (the door opens)

## The steps in the order they are told, and the gesture each waits for. GP-1: the Warrior's are the attack, the Poder (the Corte
## Circular), the dodge, the Especial (the Lança) and the Blessing; the Esmagador is taught by the hold tip (tip_hold), not by a step.
const ORDER: Array[StringName] = [&"attack", &"power", &"dodge", &"special", &"blessing"]
## The Maga's (her tree still has the Brado and the Investida buttons).
const ORDER_ARCANE: Array[StringName] = [&"attack", &"special", &"dodge", &"shout", &"rush", &"blessing"]
## The text key of each step (Objective's line).
const KEYS := {&"attack": &"lesson_attack", &"special": &"lesson_special", &"power": &"lesson_power", &"dodge": &"lesson_dodge",
		&"shout": &"lesson_shout", &"rush": &"lesson_rush", &"blessing": &"obj_bless"}
## Clicks of the attack that make the step (the chain's three blows; the finisher alone counts as the third).
const CLICKS := 3
## The events fed: &"light" (a blow of the attack's chain), &"finisher", &"special" (the Lança), &"power" (the Corte Circular),
## &"crossed" (over the stream), &"shout", &"rush" (the Maga's), &"blessing" (the Blessing's choice opened).
const EVENT_OF := {&"special": &"special", &"power": &"power", &"crossed": &"dodge", &"shout": &"shout", &"rush": &"rush", &"blessing": &"blessing"}

var steps: Array[StringName] = []
var _done := {}
var _clicks := 0


## arcane: the Maga's steps (ORDER_ARCANE), else the Warrior's.
func _init(arcane := false) -> void:
	steps.assign(ORDER_ARCANE if arcane else ORDER)


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
	return KEYS[s] if s != &"" else &""


## Every step and the Blessing done: the door may open.
func done() -> bool:
	return current() == &""


## True when only the Blessing is left (Rooms opens its choice then).
func blessing_due() -> bool:
	return current() == &"blessing"
