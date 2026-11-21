class_name FigureSketch
extends RefCounted
## The Compêndio's enemy drawn in ink on the Livro's paper (AP-4, ART-07.4): the figure's own baked model (no AI) in
## three passes over the page, see-through between the lines: depth only (figure_sketch.gdshader), the contour
## (figure_sketch_edge.gdshader) and the lines inside, creases, hatching in the shade and a wash where its paint is dark
## (figure_sketch_ink.gdshader). For a CrowdRenderer of one figure (FigureView): after register(def),
##   FigureSketch.apply(renderer, def)
## and every pose the renderer draws is the drawing. `ink`: the Livro's ink (Book.INK).

const DEPTH := preload("res://assets/shaders/figure_sketch.gdshader")
const EDGE := preload("res://assets/shaders/figure_sketch_edge.gdshader")
const LINES := preload("res://assets/shaders/figure_sketch_ink.gdshader")
## The contour, in metres of the figure at size 1 (a skeleton's is about 2 m tall).
const EDGE_WIDTH := 0.025
## Hatching strokes this many pixels apart at 1080 lines (scaled by the view's height).
const HATCH_PX := 5.0


## The three passes for a baked figure, chained (depth, contour, lines).
static func material(baked: BakedModel, ink: Color = Color(0.16, 0.11, 0.07), view_px: float = 1080.0) -> ShaderMaterial:
	var depth := ShaderMaterial.new()
	depth.shader = DEPTH
	depth.render_priority = -2
	var edge := ShaderMaterial.new()
	edge.shader = EDGE
	edge.render_priority = -1
	edge.set_shader_parameter(&"ink", Vector3(ink.r, ink.g, ink.b))
	edge.set_shader_parameter(&"width", EDGE_WIDTH)
	var lines := ShaderMaterial.new()
	lines.shader = LINES
	lines.render_priority = 0
	lines.set_shader_parameter(&"ink", Vector3(ink.r, ink.g, ink.b))
	lines.set_shader_parameter(&"albedo", baked.albedo)
	lines.set_shader_parameter(&"hatch_px", maxf(3.0, HATCH_PX * view_px / 1080.0))
	for m: ShaderMaterial in [depth, edge, lines]:
		CrowdRenderer._set_poses(m, baked)
	depth.next_pass = edge
	edge.next_pass = lines
	return depth


## Turns a CrowdRenderer's registered kind into the drawing (before its first add_kind).
static func apply(renderer: CrowdRenderer, d: EnemyDef, ink: Color = Color(0.16, 0.11, 0.07), view_px: float = 1080.0) -> void:
	var k := renderer.kind(d)
	k.material = material(k.model, ink, view_px)
