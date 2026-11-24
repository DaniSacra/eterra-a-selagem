class_name Glossary
extends PanelContainer
## The words of rule a card uses, explained beside the row of cards (benchmark_hades2_ui.md P1-2, UI-HB1): for the card
## in focus, up to MAX terms ("Congelar", "Queimadura", "Golpe Carregado"…), each its name in bold ivory and one line of what
## it does, on the interface's ink. The terms are text (data/text_pt.tres): gloss_<id> the name, gloss_<id>_text the
## line, gloss_<id>_words the beginnings of the words that call it, comma separated ("congela,congelad"). A term new
## to the game is a line in TERMS and three keys in the table.
##   var g := Glossary.new().setup(220.0)
##   g.show_for(card_text)          # empty: the panel stays, with nothing in it

## The terms the cards may call, in the order they are listed when several are.
const TERMS: Array[StringName] = [&"freeze", &"burn", &"stun", &"omega", &"magick", &"armor", &"dash_cut", &"weak", &"mark"]
## Each term's colour in the text and over its box (H4 of the SWORN reference, 2026-11-21): light enough to read on the
## card's ink, none of the rarities' (Boon.RARITY_COLOR) and none of the families' as they are on the gems.
const COLORS := {&"freeze": Color("9fdcf5"), &"burn": Color("ffa85c"), &"stun": Color("f2d98a"), &"omega": Color("c9b6f0"),
	&"magick": Color("7cc4e6"), &"armor": Color("b9bcc4"), &"dash_cut": Color("f4ecd6"),
	&"weak": Color("d8b9a0"), &"mark": Color("cfc66e")}
## The most terms shown at once.
const MAX := 2
const NAME_SIZE := 16
const TEXT_SIZE := 15

var width := 220.0
var shown: Array[StringName] = []
var _box: VBoxContainer


func setup(p_width: float) -> Glossary:
	width = p_width
	name = "glossary"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.x = width
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := UiKit.box(Color(UiKit.PAGE, 0.9), Color(UiKit.OLD_GOLD, 0.55), 1, 0, 6)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	add_theme_stylebox_override(&"panel", sb)
	_box = VBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_constant_override(&"separation", 8)
	add_child(_box)
	self_modulate.a = 0.0
	return self


## The terms a text calls, in TERMS' order, at most MAX.
static func terms_of(text: String) -> Array[StringName]:
	var low := text.to_lower()
	var out: Array[StringName] = []
	for id in TERMS:
		for w in T.t("gloss_%s_words" % id).split(",", false):
			if low.contains(w.strip_edges().to_lower()):
				out.append(id)
				break
		if out.size() >= MAX:
			break
	return out


## A word of a term in its colour and bold (H4; the plain UiKit.strong ivory for a term without a colour).
static func mark(word: String, id: StringName) -> String:
	if not COLORS.has(id):
		return UiKit.strong(word)
	return "[color=#%s][b]%s[/b][/color]" % [(COLORS[id] as Color).to_html(false), word]


## The words of rule in a text marked in their term's colour (UI-HB2, H4: "congela" in cold blue, "queimadura" in
## amber...). The text may already carry marks: only bare words are touched.
static func emphasize(bbcode: String) -> String:
	var out := bbcode
	for id in TERMS:
		for w in T.t("gloss_%s_words" % id).split(",", false):
			var re := RegEx.create_from_string("(?i)(?<![\\p{L}#=])(%s[\\p{L}]*)" % w.strip_edges())
			if re == null:
				continue
			var parts := PackedStringArray()
			var at := 0
			for m in re.search_all(out):
				parts.append(out.substr(at, m.get_start() - at))
				parts.append(mark(m.get_string(), id) if not _inside_mark(out, m.get_start()) else m.get_string())
				at = m.get_end()
			parts.append(out.substr(at))
			out = "".join(parts)
	return out


## Whether a place in a bbcode text is inside a mark already ([b]...[/b]).
static func _inside_mark(text: String, at: int) -> bool:
	return text.rfind("[b]", at) > text.rfind("[/b]", at)


## Shows the terms of a card's text (none: the panel empty and its ink hidden, keeping its width).
func show_for(text: String) -> void:
	var ids := terms_of(text)
	shown = ids
	for c in _box.get_children():
		c.free()
	for id in ids:
		var term := VBoxContainer.new()
		term.name = String(id)
		term.mouse_filter = Control.MOUSE_FILTER_IGNORE
		term.add_theme_constant_override(&"separation", 1)
		term.add_child(UiKit.label(T.t("gloss_%s" % id), COLORS.get(id, BoonCard.IVORY), NAME_SIZE, UiKit.BOLD_FONT))
		var line := UiKit.label(T.t("gloss_%s_text" % id), UiKit.PALE, TEXT_SIZE)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size.x = width - 28.0
		term.add_child(line)
		_box.add_child(term)
	self_modulate.a = 1.0 if not ids.is_empty() else 0.0
