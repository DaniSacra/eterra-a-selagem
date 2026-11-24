class_name DonsArt
extends RefCounted
## The painted pieces of the Gifts medallion by file name (docs/art/dons_medallion_spec.md 9): the final art of the
## ChatGPT pack goes to these paths and is picked up as it appears, no code to change; until then a placeholder of what
## the repository has (the title's ground, the Warrior's portrait, the Maga's cut-out) or a drawing stands in.
##   assets/ui/dons/<hero>_bg.png      the ground, full screen (placeholder: the title's, blurred and darkened)
##   assets/ui/dons/<hero>_figure.png  the hero cut-out on transparency, top of the head at y 140 of 720, cut at the foot
##   assets/ui/dons/frame.png          the outer ring with the four-pointed stars (680 x 680 on the medallion's centre)
##   assets/ui/dons/disc.png           the Devoção's small gold disc (the counter, the panel's cost)
##   assets/ui/dons/memory.png         the Memória's crystal (placeholder: DoorGlyph's mark of the material)

const DIR := "res://assets/ui/dons/"
const TITLE_BG := "res://assets/ui/title/title_bg.png"
## The part of the title's painting without its logo (pixels).
const TITLE_BG_REGION := Rect2(0, 0, 960, 941)
const WARRIOR_PAGE := "res://assets/ui/hero/warrior_page.png"
const MAGA_CUT := "res://assets/models/meshy/hero_maga_img/hero_maga_img.png"
## Visible height of a final figure (from y 140 to the foot of the 720).
const FIGURE_TOP := 140.0
const FIGURE_H := 580.0


static func texture(file: String) -> Texture2D:
	var path := DIR + file
	return load(path) if ResourceLoader.exists(path) else null


## The ground and whether it is the placeholder (blur and darken only then).
static func bg(hero: String) -> Dictionary:
	var tex := texture("%s_bg.png" % hero)
	if tex != null:
		return {"tex": tex, "placeholder": false}
	var at := AtlasTexture.new()
	at.atlas = load(TITLE_BG)
	at.region = TITLE_BG_REGION
	return {"tex": at, "placeholder": true}


## The figure, its rectangle in the 1280 x 720 stage and whether it is the placeholder (soft edge mask then).
static func figure(hero: String) -> Dictionary:
	var tex := texture("%s_figure.png" % hero)
	if tex != null:
		var w := FIGURE_H * tex.get_width() / float(tex.get_height())
		return {"tex": tex, "rect": Rect2(MedallionDef.CENTER.x - w * 0.5, FIGURE_TOP, w, FIGURE_H), "placeholder": false}
	var t: Texture2D = load(MAGA_CUT if hero == "maga" else WARRIOR_PAGE)
	var h := 600.0 if hero == "maga" else 560.0
	var w := h * t.get_width() / float(t.get_height())
	return {"tex": t, "rect": Rect2(MedallionDef.CENTER.x - w * 0.5, 360.0 - h * 0.5, w, h), "placeholder": hero != "maga"}


## The Memória's blue crystal (never the Esmeralda) h tall around c: the painted icon when the pack brings
## assets/ui/dons/memory.png, else the game's own mark of the material (DoorGlyph).
static func memory_mark(ci: CanvasItem, c: Vector2, h: float) -> void:
	var tex := texture("memory.png")
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(c - Vector2(h, h) * 0.5, Vector2(h, h)), false)
	else:
		DoorGlyph.material(ci, DoorGlyph.Kind.MEMORY, c, h)


## The Devoção's disc at c, radius r: the painted one or a gold disc with an inner line.
static func disc(ci: CanvasItem, c: Vector2, r: float) -> void:
	var tex := texture("disc.png")
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false)
		return
	ci.draw_circle(c, r, UiKit.OLD_GOLD)
	ci.draw_circle(c, r - 1.5, UiKit.GOLD)
	ci.draw_arc(c, r * 0.6, 0.0, TAU, 20, UiKit.OLD_GOLD, 1.2, true)


static func shader_material(blur: float, dark: float, vignette: float, edge_fade: float, warm: float = 0.0) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://assets/shaders/dons_art.gdshader")
	m.set_shader_parameter(&"blur", blur)
	m.set_shader_parameter(&"dark", dark)
	m.set_shader_parameter(&"vignette", vignette)
	m.set_shader_parameter(&"edge_fade", edge_fade)
	m.set_shader_parameter(&"warm", warm)
	return m
