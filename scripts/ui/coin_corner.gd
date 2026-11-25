class_name CoinCorner
extends VBoxContainer
## H3 of the SWORN reference (2026-11-21): the coins in the bottom right corner. Above, the greeting of what was just
## picked up ("+10 Prata", fading, adding up while it shows); under it one quiet row on a veil of ink: the gold (or, in
## the old horde mode, the kills) and the materials this descent carries (Prata Antiga, Fragmento de Memória), each
## only once there is one. Pure display, read each frame by Hud. px at 720 lines.
##   var corner := CoinCorner.new().setup()
##   corner.show_counts("Ouro: 40", silver, memory)
##   corner.pickup(MaterialPurse.SILVER, 10)

## Seconds a greeting stays, and the last ones it fades over.
const NOTE_TIME := 2.2
const NOTE_FADE := 0.5
const COIN := 17.0
const FONT := 19
const NOTE_FONT := 18
const VEIL := Color(0.035, 0.027, 0.04, 0.6)

var coin: HudMark
var gold: Label
var counts: HBoxContainer
var note: MaterialCount
var _note_t := 0.0
var _silver: MaterialCount
var _memory: MaterialCount


func setup() -> CoinCorner:
	name = "CoinCorner"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_END
	add_theme_constant_override(&"separation", 4)
	note = MaterialCount.new()
	note.plus = true
	note.setup(MaterialPurse.SILVER, 0, UiKit.PALE, NOTE_FONT, MaterialCount.MARK, true)
	note.name = "note"
	note.size_flags_horizontal = Control.SIZE_SHRINK_END
	note.modulate.a = 0.0
	add_child(note)
	var plate := PanelContainer.new()
	plate.name = "plate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.size_flags_horizontal = Control.SIZE_SHRINK_END
	var sb := UiKit.box(VEIL, Color(0, 0, 0, 0), 0, 0, 6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	plate.add_theme_stylebox_override(&"panel", sb)
	add_child(plate)
	counts = HBoxContainer.new()
	counts.name = "counts"
	counts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	counts.add_theme_constant_override(&"separation", 14)
	plate.add_child(counts)
	var gold_row := HBoxContainer.new()
	gold_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_row.add_theme_constant_override(&"separation", 6)
	counts.add_child(gold_row)
	coin = HudMark.new().setup(HudMark.Kind.COIN, Vector2(COIN, COIN))
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	gold_row.add_child(coin)
	gold = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT, UiKit.number_font()))
	gold.name = "gold"
	gold_row.add_child(gold)
	_silver = MaterialCount.new().setup(MaterialPurse.SILVER, 0, UiKit.PALE, FONT - 2)
	_memory = MaterialCount.new().setup(MaterialPurse.MEMORY, 0, UiKit.PALE, FONT - 2)
	for m in [_silver, _memory]:
		m.visible = false
		counts.add_child(m)
	return self


## The gold's words ("Ouro: 40") and the materials carried; a material at 0 stays hidden.
func show_counts(gold_text: String, silver: int, memory: int, with_coin: bool = true) -> void:
	gold.text = gold_text
	coin.visible = with_coin
	_silver.set_amount(silver)
	_silver.visible = silver > 0
	_memory.set_amount(memory)
	_memory.visible = memory > 0


## A material picked up: its greeting under the last, adding up while it still shows.
func pickup(id: StringName, n: int) -> void:
	if n <= 0:
		return
	var same := _note_t > 0.0 and note.id == id
	note.set_id(id)
	note.set_amount(note.amount + n if same else n)
	_note_t = NOTE_TIME
	note.modulate.a = 1.0


## The greeting's words now ("" when none shows; tests).
func note_text() -> String:
	return note.number.text if _note_t > 0.0 else ""


func tick(delta: float) -> void:
	_note_t = maxf(0.0, _note_t - delta)
	note.modulate.a = clampf(_note_t / NOTE_FADE, 0.0, 1.0)


# ---- the wallet of the full screens (UI 8 and 18) ----

## The coins of every screen that stops the game, always the same three in the same order (Prata, Memória, Esmeralda)
## with their short names, so the corner reads the same in the Dons, the Videira, the Forja, the Vendedor and the Livro.
##   var row := CoinCorner.wallet(data); CoinCorner.place(row, 1256.0, 24.0); ...; MaterialCount.refresh(row, data)
const WALLET_ORDER: Array[StringName] = [MaterialPurse.SILVER, MaterialPurse.MEMORY, MaterialPurse.EMERALD]
const WALLET_WIDTH := 400.0


static func wallet(data: Dictionary, size: int = 18, mark_px: float = 22.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "purse"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override(&"separation", 16)
	for m in WALLET_ORDER:
		row.add_child(MaterialCount.new().setup(m, MaterialCount.amount_of(data, m), UiKit.PALE, size, mark_px, true))
	return row


## SW-M3: the wallet on a dark plate in the top right corner of a full-window screen (anchored, any resolution), on top of
## whatever the screen paints (the Livro's parchment). The wallet stays the row `wallet` made, so refresh() still reads it.
static func corner(host: Control, row: HBoxContainer, margin: float = 16.0) -> PanelContainer:
	var plate := PanelContainer.new()
	plate.name = "wallet_plate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override(&"panel", UiKit.box(Color(0.045, 0.032, 0.04, 0.94), UiKit.OLD_GOLD, 2, 8, 16))
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.custom_minimum_size = Vector2.ZERO
	plate.add_child(row)
	host.add_child(plate)
	plate.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	plate.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	plate.offset_right = -margin
	# half the margin from the top: at the full margin the plate sat on the Livro's frame (UI review P2-7)
	plate.offset_top = margin * 0.5
	return plate


## Right edge and top of the wallet in a 1280 x 720 stage.
static func place(row: Control, right: float, top: float) -> void:
	row.size = Vector2(WALLET_WIDTH, 32.0)
	row.position = Vector2(right - WALLET_WIDTH, top)
