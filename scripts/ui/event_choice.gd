class_name EventChoice
extends BoonChoice
## The choice screens of the E5 events, in the gift screen's page (BoonChoice: the darkened fight, the title, the row of
## cards, the hint, the GUARD_MS guard, mouse, keys and gamepad):
## - open_trial: the Provação's cards (BoonCard.setup_trial), opened when he steps before the block in its chamber; one
##   must be taken (its doors stay shut until then).
## - open_altar: the altar's trades (BoonCard.setup_altar, smaller) and a last card that takes nothing; a trade out of
##   reach is shown dimmed with why and cannot be picked.
## picked(index) says which: the card's index in Rooms.trial_cards, or the Altar.Option (-1: none).
##   var screen := EventChoice.new()
##   game.open_screen(screen)
##   screen.open_trial(rooms.trial_cards)
##   screen.picked.connect(func(i: int) -> void: game.close_screen(); rooms.take_trial(i))

signal picked(index: int)

## The index picked for the altar's "take nothing".
const NONE := -1


func open_trial(cards: Array[Trials.Card]) -> void:
	var row := _page(T.t(&"trial_title"), T.t(&"trial_hint"))
	for i in cards.size():
		_add(row, BoonCard.new().setup_trial(cards[i]), i)
	_ready_cards()


## options: Altar.options ({option, id, cost, gain, ok}); a card that takes nothing comes last.
func open_altar(options: Array[Dictionary]) -> void:
	var row := _page(T.t(&"room_altar"), T.t(&"altar_hint"))
	for o in options:
		_add(row, BoonCard.new().setup_altar(o), int(o.option))
	_add(row, BoonCard.new().setup_altar({"id": &"none"}), NONE)
	_ready_cards()


func _add(row: HBoxContainer, card: BoonCard, index: int) -> void:
	card.pressed.connect(_choose.bind(index))
	_cards.append(card)
	row.add_child(card)


func _choose(index: int) -> void:
	if Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	picked.emit(index)
