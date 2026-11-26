class_name TalentGlyph
extends RefCounted
## One glyph per Gift of the Warrior (art pack stage 2, board 09: the motif of each node read from what the Gift really
## does, not from the board's order): Quarto Corte four cuts, Passo Encadeado a dash running into a cut, Golpe sem Fim a
## cut inside a turning arrow, Ímpeto three chevrons (its three charges), Avanço Feroz an arrow with speed lines, Fúria
## Plena a flame under three charges, Corte Crescente a crescent wave, Fio Longo a blade with the reach past its point,
## Onda Atravessante a crescent through a wall, Lâmina Faminta a gem half full (half the Magia), Reserva a gem inside a
## bigger one, Coração da Emeth a gem in a ring (never rays: never the sun), Investida an arrow through a foe, Sangue
## Quente two flames (two charges), Onda Carregada a crescent with three lights behind, Fio do Passo a dash ending in a
## small wave, Firmeza a drop beside a gem (life and Magia), Respiro a drop with a rising chevron, Ainda de Pé an arrow
## rising from the ground. The Warrior's twelve (disciplina to investida_implacavel) come after. A Gift without its own glyph draws its branch's (draw returns false). Never a cross, never
## a sun. Drawn by TalentNode in the tree and by mark() in the Compendium and on the hero page.

const IVORY := Color(0.97, 0.93, 0.84)
const DROP: Array[Vector2] = [Vector2(0.0, -1.0), Vector2(0.35, -0.4), Vector2(0.6, 0.15), Vector2(0.55, 0.55),
	Vector2(0.3, 0.82), Vector2(0.0, 0.9), Vector2(-0.3, 0.82), Vector2(-0.55, 0.55), Vector2(-0.6, 0.15),
	Vector2(-0.35, -0.4)]
const FLAME: Array[Vector2] = [Vector2(0.1, -1.15), Vector2(0.45, -0.45), Vector2(0.68, 0.15), Vector2(0.55, 0.65),
	Vector2(0.2, 0.92), Vector2(-0.2, 0.92), Vector2(-0.55, 0.65), Vector2(-0.68, 0.15), Vector2(-0.4, -0.35),
	Vector2(-0.2, -0.75)]
const TONGUE: Array[Vector2] = [Vector2(0.05, -0.05), Vector2(0.28, 0.45), Vector2(0.15, 0.78), Vector2(-0.15, 0.78),
	Vector2(-0.28, 0.45)]

## The ids with a glyph of their own.
const IDS: Array[StringName] = [&"quarto_corte", &"passo_encadeado", &"golpe_sem_fim", &"impeto", &"avanco_feroz",
	&"furia_plena", &"corte_crescente", &"fio_longo", &"onda_atravessante", &"lamina_faminta", &"reserva",
	&"coracao_da_emeth", &"investida", &"sangue_quente", &"onda_carregada", &"fio_do_passo", &"firmeza", &"respiro",
	&"ainda_de_pe",
	# the Warrior's twelve (redesign 2026-11-24)
	&"disciplina", &"cadencia", &"maestria_marcial", &"apogeu", &"forca_concentrada", &"determinacao", &"concentracao",
	&"forca_titanica", &"ruptura", &"alcance_marcial", &"imposicao", &"investida_implacavel"]


## The Gifts added after the 19 draw an existing Gift's symbol (no new art): each a different one.
const ALIAS := {&"voz_larga": &"onda_atravessante", &"escudo_de_guerra": &"firmeza", &"folego_de_guerra": &"respiro",
	&"ferro_na_investida": &"investida"}


static func has(id: StringName) -> bool:
	return IDS.has(id) or ALIAS.has(id)


## Draws the Gift's glyph inside radius r around c in col (ink: the colour behind it, for cut-outs). False when the
## id has no glyph of its own (the caller draws the branch's).
static func draw(ci: CanvasItem, id: StringName, c: Vector2, r: float, col: Color, ink: Color) -> bool:
	var th := maxf(1.6, r * 0.17)
	match ALIAS.get(id, id):
		&"quarto_corte":
			var d := Vector2(0.6, -0.8)
			var n := Vector2(0.8, 0.6)
			for k in 4:
				_cut(ci, c + n * r * (k - 1.5) * 0.36, d, r * 0.78, th, col)
		&"passo_encadeado":
			_arrow(ci, c + Vector2(-0.95, 0.55) * r, c + Vector2(0.15, 0.55) * r, r, th, col)
			_cut(ci, c + Vector2(0.4, -0.15) * r, Vector2(0.6, -0.8), r * 0.75, th, col)
		&"golpe_sem_fim":
			ci.draw_arc(c, r * 0.95, PI * 0.15, PI * 1.85, 24, col, th, true)
			var tip := c + Vector2.from_angle(PI * 0.15) * r * 0.95
			_head(ci, tip, Vector2.from_angle(PI * 0.15 + PI * 0.5), r * 0.42, col)
			_cut(ci, c, Vector2(0.6, -0.8), r * 0.55, th, col)
		&"impeto":
			for k in 3:
				var x := (k - 1) * 0.55
				_chevron(ci, c + Vector2(x - 0.1, 0.0) * r, r * (0.4 + 0.12 * k), th, col)
		&"avanco_feroz":
			_arrow(ci, c + Vector2(-0.6, 0.0) * r, c + Vector2(0.75, 0.0) * r, r, th * 1.2, col)
			for y: float in [-0.45, 0.45]:
				ci.draw_line(c + Vector2(-1.0, y) * r, c + Vector2(-0.25, y) * r, col, th * 0.7, true)
		&"furia_plena":
			ci.draw_colored_polygon(_shape(c + Vector2(0, 0.2) * r, r * 0.78, FLAME), col)
			ci.draw_colored_polygon(_shape(c + Vector2(0, 0.2) * r, r * 0.78, TONGUE), ink)
			for k in 3:
				_diamond_at(ci, c + Vector2((k - 1) * 0.55, -1.0) * r, r * 0.15, col)
		&"corte_crescente":
			_crescent(ci, c + Vector2(-0.1, 0) * r, r, col, ink)
		&"fio_longo":
			_blade(ci, c + Vector2(-0.75, 0.75) * r, c + Vector2(0.55, -0.55) * r, r * 0.2, col)
			for k in 2:
				var at := c + Vector2(0.78 + k * 0.22, -0.78 - k * 0.22) * r
				ci.draw_line(at + Vector2(-0.14, -0.14) * r, at + Vector2(0.14, 0.14) * r, col, th * 0.7, true)
		&"onda_atravessante":
			ci.draw_rect(Rect2(c + Vector2(-0.12, -0.9) * r, Vector2(0.24, 1.8) * r), Color(col, 0.55))
			_crescent(ci, c + Vector2(-0.45, 0) * r, r * 0.7, col, ink)
			_crescent(ci, c + Vector2(0.55, 0) * r, r * 0.7, col, ink)
		&"lamina_faminta":
			var h := r * 0.95
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h), c + Vector2(0, h), c + Vector2(-h * 0.62, 0)]), col)
			ci.draw_polyline(_closed(_gem(c, h)), col, th * 0.8, true)
		&"reserva":
			ci.draw_polyline(_closed(_gem(c, r * 1.0)), col, th * 0.8, true)
			ci.draw_colored_polygon(_gem(c, r * 0.55), col)
		&"coracao_da_emeth":
			ci.draw_arc(c, r * 0.95, 0.0, TAU, 28, col, th * 0.8, true)
			ci.draw_colored_polygon(_gem(c, r * 0.62), col)
		&"investida":
			ci.draw_arc(c + Vector2(0.2, 0) * r, r * 0.42, 0.0, TAU, 18, col, th * 0.8, true)
			_arrow(ci, c + Vector2(-1.0, 0) * r, c + Vector2(0.95, 0) * r, r, th, col)
		&"sangue_quente":
			for x: float in [-0.42, 0.42]:
				ci.draw_colored_polygon(_shape(c + Vector2(x, 0.1) * r, r * 0.55, FLAME), col)
				ci.draw_colored_polygon(_shape(c + Vector2(x, 0.1) * r, r * 0.55, TONGUE), ink)
		&"onda_carregada":
			_crescent(ci, c + Vector2(0.25, 0) * r, r * 0.85, col, ink)
			for k in 3:
				ci.draw_circle(c + Vector2(-0.85, (k - 1) * 0.5) * r, r * 0.12, col)
		&"fio_do_passo":
			_arrow(ci, c + Vector2(-1.0, 0.2) * r, c + Vector2(0.05, 0.2) * r, r, th, col)
			_crescent(ci, c + Vector2(0.45, 0.0) * r, r * 0.55, col, ink)
		&"firmeza":
			ci.draw_colored_polygon(_shape(c + Vector2(-0.38, 0.05) * r, r * 0.68, DROP), col)
			ci.draw_colored_polygon(_gem(c + Vector2(0.52, 0.1) * r, r * 0.5), col)
		&"respiro":
			ci.draw_colored_polygon(_shape(c + Vector2(-0.25, 0.15) * r, r * 0.8, DROP), col)
			_chevron_up(ci, c + Vector2(0.62, -0.25) * r, r * 0.35, th, col)
			_chevron_up(ci, c + Vector2(0.62, 0.25) * r, r * 0.35, th, col)
		&"ainda_de_pe":
			ci.draw_line(c + Vector2(-0.95, 0.85) * r, c + Vector2(0.95, 0.85) * r, col, th, true)
			_arrow(ci, c + Vector2(0, 0.7) * r, c + Vector2(0, -0.95) * r, r, th, col)
		&"disciplina":
			# the same cut twice over a ground line: the trained stroke
			for k in 2:
				_cut(ci, c + Vector2((k - 0.5) * 0.7, -0.2) * r, Vector2(0.6, -0.8), r * 0.62, th, col)
			ci.draw_line(c + Vector2(-0.95, 0.85) * r, c + Vector2(0.95, 0.85) * r, col, th, true)
		&"cadencia":
			# three cuts in a row, each a little longer: the rhythm of the combo
			for k in 3:
				_cut(ci, c + Vector2((k - 1) * 0.62, 0.0) * r, Vector2(0.6, -0.8), r * (0.4 + 0.18 * k), th, col)
		&"maestria_marcial":
			_blade(ci, c + Vector2(-0.75, 0.75) * r, c + Vector2(0.65, -0.65) * r, r * 0.2, col)
			ci.draw_arc(c, r * 0.98, PI * 0.55, PI * 1.45, 14, col, th * 0.8, true)
			ci.draw_arc(c, r * 0.98, -PI * 0.45, PI * 0.45, 14, col, th * 0.8, true)
		&"apogeu":
			_blade(ci, c + Vector2(0, 0.95) * r, c + Vector2(0, -0.45) * r, r * 0.2, col)
			_chevron_up(ci, c + Vector2(0, -0.78) * r, r * 0.4, th, col)
			_chevron_up(ci, c + Vector2(0, -1.0) * r, r * 0.3, th * 0.8, col)
		&"forca_concentrada":
			ci.draw_colored_polygon(_gem(c, r * 0.4), col)
			for a in 4:
				var d := Vector2.from_angle(a * PI * 0.5 + PI * 0.25)
				_head(ci, c + d * r * 0.55, -d, r * 0.34, col)
				ci.draw_line(c + d * r * 0.95, c + d * r * 0.62, col, th * 0.7, true)
		&"determinacao":
			ci.draw_rect(Rect2(c + Vector2(-0.9, 0.35) * r, Vector2(1.8, 0.5) * r), col)
			ci.draw_colored_polygon(_gem(c + Vector2(0, -0.3) * r, r * 0.6), col)
		&"concentracao":
			ci.draw_arc(c, r * 0.95, 0.0, TAU, 28, col, th * 0.8, true)
			ci.draw_arc(c, r * 0.55, 0.0, TAU, 20, col, th * 0.8, true)
			ci.draw_circle(c, r * 0.2, col)
		&"forca_titanica":
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.38, -1.0) * r, c + Vector2(0.38, -1.0) * r, c + Vector2(0.3, 0.3) * r,
				c + Vector2(0, 0.62) * r, c + Vector2(-0.3, 0.3) * r]), col)
			for x: float in [-0.7, 0.7]:
				ci.draw_line(c + Vector2(x, 0.85) * r, c + Vector2(x * 1.35, 0.55) * r, col, th * 0.8, true)
			ci.draw_line(c + Vector2(-0.95, 0.95) * r, c + Vector2(0.95, 0.95) * r, col, th, true)
		&"ruptura":
			# a gem split in two halves by a crack
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.05, -0.95) * r, c + Vector2(-0.6, 0.0) * r, c + Vector2(-0.12, 0.95) * r,
				c + Vector2(-0.22, 0.2) * r]), col)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0.1, -0.85) * r, c + Vector2(0.62, 0.0) * r, c + Vector2(0.02, 0.95) * r,
				c + Vector2(0.14, 0.1) * r]), col)
		&"alcance_marcial":
			ci.draw_colored_polygon(_gem(c + Vector2(-0.7, 0.0) * r, r * 0.38), col)
			for k in 3:
				ci.draw_arc(c + Vector2(-0.55, 0.0) * r, r * (0.55 + 0.3 * k), -PI * 0.3, PI * 0.3, 10, col, th * 0.8, true)
		&"imposicao":
			ci.draw_circle(c + Vector2(0, 0.6) * r, r * 0.28, col)
			_chevron_down(ci, c + Vector2(0, -0.55) * r, r * 0.8, th, col)
			_chevron_down(ci, c + Vector2(0, -0.1) * r, r * 0.55, th, col)
		&"investida_implacavel":
			ci.draw_arc(c + Vector2(0.45, 0) * r, r * 0.38, 0.0, TAU, 16, col, th * 0.8, true)
			_arrow(ci, c + Vector2(-0.8, 0) * r, c + Vector2(0.95, 0) * r, r, th * 1.2, col)
			for y: float in [-0.5, 0.5]:
				ci.draw_line(c + Vector2(-1.0, y) * r, c + Vector2(-0.4, y) * r, col, th * 0.7, true)
		_:
			return false
	return true


## A small node of the tree (the Gift's diamond with its glyph) as a control, for lists: the Compendium's Gifts and
## the hero page. side: the diamond's width; open false draws a closed one (a hollow diamond in faded ink, no glyph).
static func mark(t: TalentDef, side: float, open: bool = true) -> Control:
	var m := Control.new()
	m.name = &"TalentMark"
	m.custom_minimum_size = Vector2(side, side)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	m.draw.connect(func() -> void:
		var c := m.size * 0.5
		var h := side * 0.5
		var tint := TalentNode.branch_color(t.branch) if t != null else TalentNode.CENTRE
		if not open:
			# not reached: a hollow diamond in faded ink, as the page's own marks
			m.draw_polyline(TalentNode._closed(TalentNode._diamond(c, h - 1.0)), Book.FADED, 1.4, true)
			return
		m.draw_colored_polygon(TalentNode._diamond(c, h), UiKit.OLD_GOLD.lightened(0.15))
		var fill := UiKit.INK.lerp(tint.darkened(0.45), 0.8)
		m.draw_colored_polygon(TalentNode._diamond(c, h - 1.6), fill)
		if t == null or not draw(m, t.id, c, h * 0.48, IVORY, fill):
			TalentNode.branch_glyph(m, TalentNode.Glyph.CENTRE if t == null else TalentNode.glyph_of(t.branch), c, h * 0.48, IVORY))
	return m


static func _cut(ci: CanvasItem, mid: Vector2, d: Vector2, half: float, th: float, col: Color) -> void:
	var a := mid - d * half
	var b := mid + d * half
	var n := d.orthogonal() * th * 0.55
	ci.draw_colored_polygon(PackedVector2Array([a, mid + n, b, mid - n]), col)


static func _arrow(ci: CanvasItem, from: Vector2, to: Vector2, r: float, th: float, col: Color) -> void:
	var d := (to - from).normalized()
	ci.draw_line(from, to - d * r * 0.25, col, th, true)
	_head(ci, to, d, r * 0.42, col)


static func _head(ci: CanvasItem, tip: Vector2, d: Vector2, s: float, col: Color) -> void:
	var n := d.orthogonal()
	ci.draw_colored_polygon(PackedVector2Array([tip, tip - d * s + n * s * 0.6, tip - d * s * 0.7, tip - d * s - n * s * 0.6]), col)


static func _chevron(ci: CanvasItem, c: Vector2, s: float, th: float, col: Color) -> void:
	ci.draw_polyline(PackedVector2Array([c + Vector2(-0.5, -1.0) * s, c + Vector2(0.5, 0.0) * s, c + Vector2(-0.5, 1.0) * s]), col, th, true)


static func _chevron_up(ci: CanvasItem, c: Vector2, s: float, th: float, col: Color) -> void:
	ci.draw_polyline(PackedVector2Array([c + Vector2(-1.0, 0.5) * s, c + Vector2(0.0, -0.5) * s, c + Vector2(1.0, 0.5) * s]), col, th, true)


static func _chevron_down(ci: CanvasItem, c: Vector2, s: float, th: float, col: Color) -> void:
	ci.draw_polyline(PackedVector2Array([c + Vector2(-1.0, -0.5) * s, c + Vector2(0.0, 0.5) * s, c + Vector2(1.0, -0.5) * s]), col, th, true)


## A crescent wave opening to the left (its belly to the right, where it runs), radius r around c.
static func _crescent(ci: CanvasItem, c: Vector2, r: float, col: Color, _ink: Color) -> void:
	var pts := PackedVector2Array()
	var steps := 14
	for i in steps + 1:
		var a := -PI * 0.42 + PI * 0.84 * i / steps
		pts.append(c + Vector2(cos(a), sin(a)) * r * 0.9)
	for i in steps + 1:
		var a := PI * 0.42 - PI * 0.84 * i / steps
		pts.append(c + Vector2(-0.38, 0) * r + Vector2(cos(a) * 1.05, sin(a)) * r * 0.86)
	ci.draw_colored_polygon(pts, col)


## A long blade from hilt to point with a short guard (a sword, never a cross: the guard is short and near the hilt).
static func _blade(ci: CanvasItem, hilt: Vector2, point: Vector2, w: float, col: Color) -> void:
	var d := (point - hilt).normalized()
	var n := d.orthogonal()
	var base := hilt.lerp(point, 0.22)
	ci.draw_colored_polygon(PackedVector2Array([base + n * w * 0.5, point, base - n * w * 0.5]), col)
	ci.draw_line(base + n * w * 1.1, base - n * w * 1.1, col, w * 0.5, true)
	ci.draw_line(hilt, base, col, w * 0.45, true)


static func _diamond_at(ci: CanvasItem, c: Vector2, h: float, col: Color) -> void:
	ci.draw_colored_polygon(_gem(c, h), col)


static func _gem(c: Vector2, h: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -h), c + Vector2(h * 0.62, 0), c + Vector2(0, h), c + Vector2(-h * 0.62, 0)])


static func _shape(c: Vector2, r: float, pts: Array[Vector2]) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p * r)
	return out


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out
