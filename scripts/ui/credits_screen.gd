class_name CreditsScreen
extends Control
## "Créditos" (C15-05, E4-07; art pack board 06), opened from Como Jogar: who made what the game uses and under which
## licence, in blocks (Equipe, Áudio, Arte, Ferramentas, Licenças), one line per source (texts credits_<id>; the same
## list as audio/LICENSES.md, docs/art/asset_credits.md and docs/steam-ia.md for what was made with AI). The blocks
## scroll: each takes the focus, so up and down (keys, gamepad) and the mouse wheel walk them; Voltar stays below.

signal closed

## The blocks in order on screen: the block's text (credits_head_<id>) and its lines (credits_<id>).
const BLOCKS: Array[Dictionary] = [
	{"id": "team", "lines": ["team"]},
	{"id": "audio", "lines": ["music", "music_own", "sfx", "blade", "rpg_sfx", "fantasy", "synth"]},
	{"id": "art", "lines": ["meshy", "ai_art", "models", "anims", "rock", "fonts"]},
	{"id": "tools", "lines": ["engine", "ai_code"]},
	{"id": "licences", "lines": ["licences"]},
]
## Every line, in order on screen (each in exactly one block). T5: the recorded music (CC BY 4.0) and sound effects
## (CC0, one pack CC BY 3.0) have their own lines.
const LINES: Array[String] = [
	"team", "music", "music_own", "sfx", "blade", "rpg_sfx", "fantasy", "synth", "meshy", "ai_art", "models", "anims", "rock",
	"fonts", "engine", "ai_code", "licences",
]
const WIDTH := 980.0
const LIST_HEIGHT := 470.0
const LINE_SIZE := 17

## The blocks, in focus order.
var blocks: Array[Control] = []


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.page(self, T.t(&"credits_title"), WIDTH, 0.85, 34)
	var scroll := ScrollContainer.new()
	scroll.name = "list"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.custom_minimum_size.y = LIST_HEIGHT
	v.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override(&"separation", 8)
	scroll.add_child(list)
	for block: Dictionary in BLOCKS:
		var panel := UiKit.focus_row(12)
		panel.name = "block_" + String(block.id)
		list.add_child(panel)
		blocks.append(panel)
		var col := VBoxContainer.new()
		col.add_theme_constant_override(&"separation", 4)
		col.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(col)
		col.add_child(UiKit.section(T.t("credits_head_" + String(block.id)), UiKit.GOLD.darkened(0.1), 19))
		for id: String in block.lines:
			var l := UiKit.label(T.t("credits_" + id), UiKit.PALE, LINE_SIZE)
			l.name = "credits_" + id
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size.x = WIDTH - 110.0
			col.add_child(l)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	var f := UiKit.foot()
	f.add_child(back)
	v.add_child(f)
	blocks[-1].focus_neighbor_bottom = blocks[-1].get_path_to(back)
	back.focus_neighbor_top = back.get_path_to(blocks[-1])
	blocks[0].grab_focus.call_deferred()
