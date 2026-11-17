class_name CreditsScreen
extends Control
## "Créditos" (C15-05, E4-07), opened from Como Jogar: who made what the game uses and under which licence, one line
## per source (texts credits_<id>; the same list as audio/LICENSES.md and docs/art/asset_credits.md).

signal closed

## The lines, in order on screen (text credits_<id>).
## T5: the recorded music (CC BY 4.0) and sound effects (CC0, one pack CC BY 3.0) have their own lines.
const LINES: Array[String] = [
	"music", "music_own", "sfx", "blade", "rpg_sfx", "fantasy", "synth", "models", "anims", "rock", "fonts", "meshy", "engine",
]


func open() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, 1000.0, 0.85)
	v.add_child(UiKit.title(T.t(&"credits_title"), 40))
	var panel := PanelContainer.new()
	v.add_child(panel)
	var list := VBoxContainer.new()
	list.add_theme_constant_override(&"separation", 5)
	panel.add_child(list)
	for id in LINES:
		var l := UiKit.label(T.t("credits_" + id), UiKit.PALE, 17)
		l.name = "credits_" + id
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 900.0
		list.add_child(l)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	back.grab_focus.call_deferred()
