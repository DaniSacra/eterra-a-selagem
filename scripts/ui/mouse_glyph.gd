class_name MouseGlyph
extends RefCounted
## PT-26-1: a mouse seen from above with the bound button lit (left, right, middle), the one drawing the game uses
## wherever it would say "Clique esquerdo": the HUD's diamonds, the key plates, the tips, the cards' sentences.
## The drawing is made by MouseGlyphArt.rasterize() (supersampled, no art file needed); tools/make_mouse_icons.gd saves it as the
## PNGs of assets/ui/keys/ so a RichTextLabel can show it with [img].
##   MouseGlyph.keyed("Aperte Clique esquerdo")   # BBCode with the icon where the name is
##   MouseGlyph.draw(self, centre, MOUSE_BUTTON_LEFT)

## Size in the UI (pixels) and the sharpness of the PNG (the icon is saved at SCALE times that).
const W := MouseGlyphArt.W
const H := MouseGlyphArt.H
const BUTTONS: Array[int] = [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]

static var _cache := {}


## The path of the PNG of a button (assets/ui/keys/mouse_1.png).
static func path(button: int) -> String:
	return "res://assets/ui/keys/mouse_%d.png" % button


## The button a key label names ("Clique esquerdo": MOUSE_BUTTON_LEFT; 0 for anything else).
static func button_of(label: String) -> int:
	for b in BUTTONS:
		if label == T.t("mouse_%d" % b):
			return b
	return 0


## The icon of a button: the saved PNG, or the same drawing made now when the file is not imported yet.
static func texture(button: int) -> Texture2D:
	if not _cache.has(button):
		var tex: Texture2D = load(path(button)) if ResourceLoader.exists(path(button)) else null
		_cache[button] = tex if tex != null else ImageTexture.create_from_image(MouseGlyphArt.rasterize(button))
	return _cache[button]


## Draws the icon centred at `at` on a CanvasItem; `h` is its height (W:H kept).
static func draw(ci: CanvasItem, at: Vector2, button: int, h: float = H) -> void:
	var size := Vector2(W, H) * (h / H)
	ci.draw_texture_rect(texture(button), Rect2(at - size * 0.5, size), false)


## The icon as BBCode for a RichTextLabel (its height h in pixels).
static func bbcode(button: int, h: int = int(H)) -> String:
	return "[img=%dx%d]%s[/img]" % [roundi(W * h / H), h, path(button)]


## A plain text as BBCode with the names of the mouse buttons turned into icons ("[" is escaped).
static func keyed(text: String, h: int = int(H)) -> String:
	var out := text.replace("[", "[lb]")
	for b in BUTTONS:
		out = out.replace(T.t("mouse_%d" % b), bbcode(b, h))
	return out


## True when the text names a mouse button (so the caller needs a RichTextLabel).
static func has_mouse(text: String) -> bool:
	for b in BUTTONS:
		if text.contains(T.t("mouse_%d" % b)):
			return true
	return false
