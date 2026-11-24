class_name GiftArt
extends RefCounted
## What is hand of the Livro de Ahk's Gifts chapter: the inks of each branch (meta_screens_identity.md 1.3), the order of
## the chapters (the ribbons), the miniatures (assets/ui/book/<id>.png when it exists, else a placeholder drawn here:
## the branch's big capital, or the pencil outline of an ultimate), and the corner marks of each hero (the lion's head
## for the Warrior, the eight-pointed star for the Maga, never violet).

const DIR := "res://assets/ui/book/"
## The ribbon of the last chapter: the ultimates ("Poder maior"), a ribbon of gold.
const ULT_BRANCH := -1
## The chapters by branch name (a name the enum no longer has is skipped): the Warrior's three, the Maga's three (the old
## three first, while a Maga catalog still has them).
const WARRIOR_ORDER: Array[StringName] = [&"COMBO", &"IMPETO", &"DOMINIO", &"FURIA", &"EMETH", &"MAGIA"]
const MAGA_ORDER: Array[StringName] = [&"ELEMENTALISMO", &"CONJURACAO", &"FEITICARIA", &"PIRO", &"ARCA", &"CTRL"]
## Inks of the branches, lowered for the paper (the vivid emerald stays the Emeth's own light, not a paper ink).
const INK := {
	&"COMBO": Color("783222"), &"IMPETO": Color("9a5a2a"), &"DOMINIO": Color("2f7a58"),
	&"ELEMENTALISMO": Color("9a4a1c"), &"CONJURACAO": Color("86601a"), &"FEITICARIA": Color("7f5c26"),
	&"FURIA": Color("9a5a2a"), &"EMETH": Color("2f7a58"), &"MAGIA": Color("3d6a8c"),
	&"BRIDGE": Color("7f5c26"), &"SUSTAIN": Color("7a4e3a"),
	&"PIRO": Color("9a4a1c"), &"ARCA": Color("86601a"), &"CTRL": Color("4a5560"),
}
const MAGA_TITLE := Color("6a3a14")
const ULT_INK := Color("b08a2a")


static func is_maga(hero: HeroDef) -> bool:
	return hero != null and hero.id == &"maga"


## The branches of the hero's chapters, in order (the Warrior's three or the Maga's three, only those the hero's catalog has).
static func chapters(hero: HeroDef) -> Array[int]:
	var out: Array[int] = []
	var have := {}
	for t in hero.talents().catalog:
		have[t.branch] = true
	for n in (MAGA_ORDER if is_maga(hero) else WARRIOR_ORDER):
		var b: int = TalentDef.Branch.get(String(n), -1)
		if b >= 0 and have.has(b):
			out.append(b)
	return out


## The painted art key of a branch (assets/ui/book/branch_<name>.png when it exists).
static func branch_art(branch: int) -> StringName:
	return StringName("branch_" + String(TalentNode.branch_name(branch)).to_lower())


static func ink(branch: int) -> Color:
	return INK.get(TalentNode.branch_name(branch), ULT_INK)


## The ink of the page's titles: the Warrior's iron-gall brown, the Maga's dark amber.
static func title_ink(hero: HeroDef) -> Color:
	return MAGA_TITLE if is_maga(hero) else Book.INK


## The ink of a Gift: its branch's.
static func gift_ink(t: TalentDef) -> Color:
	return ink(t.branch)


## The painted miniature (assets/ui/book/<id>.png) or null: the placeholder is drawn by `paint`.
static func texture(id: StringName) -> Texture2D:
	var path := "%s%s.png" % [DIR, id]
	return load(path) if ResourceLoader.exists(path) else null


## The miniature of `id` in `rect`: the painted one if there is, else the placeholder (letter large in the tint, a
## faint ground and, for an ultimate that is `pencil` (locked), only the sepia outline).
static func paint(ci: CanvasItem, rect: Rect2, id: StringName, tint: Color, letter: String, pencil: bool = false) -> void:
	var tex := texture(id)
	if tex != null:
		var k := minf(rect.size.x / tex.get_width(), rect.size.y / tex.get_height())
		var sz := tex.get_size() * k
		var at := rect.position + (rect.size - sz) * 0.5
		ci.draw_texture_rect(tex, Rect2(at, sz), false, Color(1, 1, 1, 0.55) if pencil else Color.WHITE)
		return
	ci.draw_rect(rect, Color(Book.FADED, 0.1))
	ci.draw_rect(rect, Color(Book.GILT, 0.5), false, 1.0)
	var f := UiKit.TITLE_FONT
	var fs := int(minf(rect.size.y * 0.9, rect.size.x * 0.5))
	var w := f.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := rect.position + Vector2((rect.size.x - w) * 0.5, rect.size.y * 0.5 + f.get_ascent(fs) * 0.35)
	if pencil:
		ci.draw_string_outline(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 2, Color(Book.FADED, 0.6))
		ci.draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(Book.PAPER, 0.8))
	else:
		ci.draw_string(f, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(tint, 0.78))


## A corner mark of the hero's hand at `c`, `r` its radius: the lion's head (a mane of locks round a face), or the
## eight-pointed star (two squares turned, a ring).
static func corner(ci: CanvasItem, c: Vector2, r: float, hero: HeroDef, color: Color) -> void:
	if is_maga(hero):
		for k in 2:
			var pts := PackedVector2Array()
			for i in 4:
				pts.append(c + Vector2.from_angle(PI * 0.25 * k + i * PI * 0.5) * r)
			ci.draw_polyline(_close(pts), color, 1.6, true)
		ci.draw_arc(c, r * 0.4, 0.0, TAU, 14, color, 1.2, true)
		return
	# the mane: ten rounded locks round the face (scalloped, not rays)
	for i in 10:
		ci.draw_circle(c + Vector2.from_angle(TAU * i / 10.0) * r * 0.72, r * 0.3, color)
	ci.draw_circle(c, r * 0.62, color)
	ci.draw_circle(c, r * 0.5, Book.PAPER)
	ci.draw_line(c + Vector2(-r * 0.28, -r * 0.1), c + Vector2(-r * 0.1, -r * 0.05), color, 1.4)
	ci.draw_line(c + Vector2(r * 0.28, -r * 0.1), c + Vector2(r * 0.1, -r * 0.05), color, 1.4)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.1, r * 0.08), c + Vector2(r * 0.1, r * 0.08), c + Vector2(0, r * 0.26)]), color)
	ci.draw_polyline(PackedVector2Array([c + Vector2(-r * 0.2, r * 0.36), c + Vector2(0, r * 0.3), c + Vector2(r * 0.2, r * 0.36)]), color, 1.2, true)


static func _close(p: PackedVector2Array) -> PackedVector2Array:
	var out := p.duplicate()
	out.append(p[0])
	return out
