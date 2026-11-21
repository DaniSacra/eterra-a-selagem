class_name SealEmblem
extends Control
## The seal closed over Morvath, for the victory (art pack board 06: the sealing first, the summary after) and Como
## Jogar: a round seal of ink, a ring of old gold that closes round it (closed 0..1, from the top, clockwise), a thin
## ivory ring inside and the lion of the Chamber's seal (the hero's symbol, D-64 to D-71; the same drawing as the floor
## of the Seal Chamber, assets/textures/seal/lion_sdf.res) in old gold that lights up as the ring closes (lit 0..1).
## Never a sun nor a cross.
##   var s := SealEmblem.new().setup(120.0)   # s.closed = 0.0, then tween closed and lit to 1

const LION := preload("res://assets/textures/seal/lion_sdf.res")
## Pixels of the lion's field from the edge to the full swing (tools/make_seal_lion.gd SPREAD).
const SPREAD := 24.0
const INK := Color(0.05, 0.04, 0.06, 0.96)
const IVORY := Color(0.96, 0.92, 0.82)
## The lion's share of the seal's width.
const LION_SHARE := 0.62
## The gold of the lion and its shade in the cuts.
const LION_GOLD := Color(0.86, 0.69, 0.4)
const LION_CUT := Color(0.09, 0.07, 0.07)
## The soft halo round the closed ring (alpha at full light): warm, low, under the glow of anything on screen. A radial
## gradient of old gold to nothing (QW-115: the rings of discs before read as a yellow disc), out to HALO_REACH radii.
const HALO := 0.42
const HALO_REACH := 1.55
const HALO_GOLD := Color(0.62, 0.48, 0.26)

static var _halo_tex: GradientTexture2D

const SHADER := """
shader_type canvas_item;
uniform float spread = 24.0;
uniform float lit = 1.0;
uniform vec4 gold : source_color = vec4(0.86, 0.69, 0.4, 1.0);
uniform vec4 cut_color : source_color = vec4(0.09, 0.07, 0.07, 1.0);
void fragment() {
	vec2 f = texture(TEXTURE, UV).rg;
	float body = (f.r - 0.5) * spread * 2.0;
	float cut = (f.g - 0.5) * spread * 2.0;
	float w = max(fwidth(body), 0.0001);
	float wc = max(fwidth(cut), 0.0001);
	float inside = smoothstep(-w, w, body);
	float in_cut = smoothstep(-wc, wc, cut);
	// lit from the top: the upper body a little lighter, the cuts dark
	vec3 col = gold.rgb * (0.82 + 0.3 * (1.0 - UV.y));
	col = mix(col, cut_color.rgb, in_cut * 0.9);
	COLOR = vec4(col, inside * lit);
}
"""

var closed := 1.0:
	set(v):
		closed = clampf(v, 0.0, 1.0)
		queue_redraw()
var lit := 1.0:
	set(v):
		lit = clampf(v, 0.0, 1.0)
		if _lion:
			(_lion.material as ShaderMaterial).set_shader_parameter(&"lit", 0.25 + 0.75 * lit)
		queue_redraw()

var _lion: TextureRect


func setup(size_px: float) -> SealEmblem:
	name = "seal"
	custom_minimum_size = Vector2(size_px, size_px)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lion = TextureRect.new()
	_lion.texture = LION
	_lion.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lion.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lion.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_lion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter(&"spread", SPREAD)
	mat.set_shader_parameter(&"gold", LION_GOLD)
	mat.set_shader_parameter(&"cut_color", LION_CUT)
	_lion.material = mat
	var inset := size_px * (1.0 - LION_SHARE) * 0.5
	_lion.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lion.offset_left = inset
	_lion.offset_top = inset
	_lion.offset_right = -inset
	_lion.offset_bottom = -inset
	add_child(_lion)
	lit = lit
	return self


## The halo's gradient: white in the middle (tinted by the draw) to nothing at the edge, eased so no ring shows.
static func halo_texture() -> GradientTexture2D:
	if _halo_tex == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.45, 0.75, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.16), Color(1, 1, 1, 0)])
		_halo_tex = GradientTexture2D.new()
		_halo_tex.gradient = g
		_halo_tex.fill = GradientTexture2D.FILL_RADIAL
		_halo_tex.fill_from = Vector2(0.5, 0.5)
		_halo_tex.fill_to = Vector2(1.0, 0.5)
		_halo_tex.width = 128
		_halo_tex.height = 128
	return _halo_tex


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5
	# the halo once it closes, under everything: a radial gradient, nothing at its edge
	var glow := HALO * lit * closed
	if glow > 0.0:
		var reach := r * HALO_REACH
		draw_texture_rect(halo_texture(), Rect2(c - Vector2(reach, reach), Vector2(reach, reach) * 2.0), false,
				Color(HALO_GOLD, glow))
	draw_circle(c, r - 1.0, INK)
	# the outer ring: dim where still open, old gold where closed (from the top, clockwise)
	var width := maxf(2.0, r * 0.07)
	draw_arc(c, r - width * 0.5 - 1.0, 0.0, TAU, 96, Color(UiKit.OLD_GOLD, 0.25), width, true)
	if closed > 0.0:
		draw_arc(c, r - width * 0.5 - 1.0, -PI * 0.5, -PI * 0.5 + TAU * closed, 96,
				UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.35 * lit), width, true)
	# a thin ivory ring inside and four small diamonds on it (north, east, south, west)
	var inner := r - width * 2.2
	draw_arc(c, inner, 0.0, TAU, 96, Color(IVORY, 0.35 + 0.35 * lit), maxf(1.0, r * 0.012), true)
	var d := maxf(2.5, r * 0.045)
	for k in 4:
		var p := c + Vector2.from_angle(-PI * 0.5 + k * PI * 0.5) * inner
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -d), p + Vector2(d, 0), p + Vector2(0, d), p + Vector2(-d, 0)]),
				UiKit.OLD_GOLD.lerp(UiKit.GOLD, 0.5 * lit))
