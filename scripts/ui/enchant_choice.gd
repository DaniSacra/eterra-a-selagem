class_name EnchantChoice
extends BoonChoice
## The choice of an Encanto (Rejogabilidade, Fatia 2; sistemas.md 1.7 and 5.3), in the gift screen's page
## (BoonChoice: the darkened fight, the title, a line under it, the row of cards, the hint, the action bar, the
## GUARD_MS guard, mouse, keys and gamepad): up to three Encanto cards (BoonCard.setup_enchant), the first in focus.
## Game.open_enchant_choice opens it when no screen listens to Game.enchant_offered (a door of Encanto, the shop's).
##   var s := EnchantChoice.new(); game.open_screen(s); s.open_enchants(options); s.chosen_enchant.connect(...)

signal chosen_enchant(enchant: EnchantDef)

## The altar's share of the screen's width.
const ALTAR_SHARE := 0.2


func open_enchants(options: Array) -> void:
	var row := _page(T.t(&"enchant_title"), T.t(&"enchant_pick_hint"), T.t(&"enchant_hint"))
	_add_altar(row)
	for e: EnchantDef in options:
		var card := BoonCard.new().setup_enchant(e)
		card.name = String(e.id)
		card.pressed.connect(_take.bind(e))
		_cards.append(card)
		row.add_child(card)
	_ready_cards()


## PT-10: the Emeth planted in stone and lit at the left; the page moves right by the altar's width.
func _add_altar(row: Control) -> void:
	var center := row.get_parent().get_parent() as Control
	var altar := EnchantAltar.new()
	altar.anchor_bottom = 1.0
	altar.offset_bottom = -ActionBar.RESERVE
	add_child(altar)
	var fit := func() -> void:
		var w := clampf(size.x * ALTAR_SHARE, 0.0, 380.0)
		altar.offset_right = w
		center.offset_left = w * 0.7
	resized.connect(fit)
	fit.call_deferred()


func _take(e: EnchantDef) -> void:
	if Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	chosen_enchant.emit(e)
