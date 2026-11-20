class_name PaintPass
extends CompositorEffect
## Eterra Stylized, the painting filter (STY-07; docs/art/stylized_spec.md 5.2, T26): a 4-sector Kuwahara of RADIUS
## pixels at 1080 (scaled by the 3D resolution) and a coloured contour where the depth jumps, run on the camera's
## compositor after the opaque pass (avisos, arcs, particles, the x-ray and the numbers are drawn after it, sharp).
## Optional: only in the stylized look, only on the Forward+, only at the "Alta" quality; `--paint-pass=0|1` decides
## for a run, else DEFAULT_ON (attach()). Decision and measures in docs/art/stylized_poc_plan.md (STY-07).

const SHADER := preload("res://assets/shaders/paint_pass.glsl")
## Kuwahara radius in pixels at 1080 lines (2; 3 at most), the contour's width in pixels at 1080, its colour (sRGB, as
## the spec's) and strength, and the depth jump (a share of the pixel's own depth) where it starts.
const RADIUS := 2.0
const EDGE_PX := 1.5
const EDGE_COLOR := Color(0.07, 0.08, 0.10)
const EDGE_ALPHA := 0.6
const EDGE_JUMP := 0.04
## Whether the filter is on when nothing says otherwise (`--paint-pass`): see attach().
const DEFAULT_ON := false
## TA-HB1 (docs/art/benchmark_hades2_style.md 4.2): the ink line alone, no Kuwahara (which smeared the medallion's
## runes): only where the depth jumps, so it outlines the pieces and the figures and never the floor's painted relief
## (its runes, the framed slabs) nor the floor marks (drawn without depth). INK_PX at 1080, in the rooms' shadow ink,
## from a jump of INK_JUMP of the pixel's depth (full at twice that). It runs after the transparent pass so it keeps the
## Alta's MSAA (the painting filter has to turn it off), in the stylized look only, on the Forward+ only, at the Alta and
## Média; on by default since the art-director approved it on 2026-11-20 (`--ink-line=0` turns it off, INK_DEFAULT_ON).
## Only on the pieces: the Forward+ marks a moving instance (the crowd, the paladin, his sword) in its normal-roughness
## buffer (roughness channel above 0.5; needs_normal_roughness), and no edge touching one is inked (with 12 enemies the
## figures' outline doubled and their edges were drawn over the life bars in front of them). `--ink-debug` shows that
## mark (red) instead of the frame.
const INK_PX := 2.0
const INK_COLOR := Color(0.045, 0.05, 0.065)
const INK_ALPHA := 0.7
const INK_JUMP := 0.015
const INK_DEFAULT_ON := true

var kuwahara := true
var contour := true
## The ink line alone (TA-HB1): no Kuwahara, INK_* for the contour.
var ink := false

var _rd: RenderingDevice
var _shader: RID
var _pipeline: RID
var _sampler: RID


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_OPAQUE
	access_resolved_color = true
	access_resolved_depth = true
	_rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_make)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _rd:
		for rid: RID in [_pipeline, _shader, _sampler]:
			if rid.is_valid():
				_rd.free_rid(rid)


## Whether it may run here: the Forward+, the given quality level (Alta only) and `--paint-pass` (else DEFAULT_ON).
## The look is not asked here: the effect is on only in the stylized one (attach registers it, F7 flips it live).
static func wanted(level: int) -> bool:
	if RenderingServer.get_current_rendering_method() != "forward_plus" or level != GraphicsQuality.HIGH:
		return false
	if Dev.has("paint-pass"):
		return Dev.arg("paint-pass") != "0"
	return DEFAULT_ON


## Whether the ink line alone may run (TA-HB1): the Forward+ above the Baixa quality and `--ink-line` (else
## INK_DEFAULT_ON). On the Baixa it cost the iGPU 1.4 ms of GPU at 1280 x 720 (58.6 to 52.6 frames a second, the
## acceptance allows 3), on the RTX at 1080 0.04 ms.
static func ink_wanted(level: int = GraphicsQuality.HIGH) -> bool:
	if RenderingServer.get_current_rendering_method() != "forward_plus" or level == GraphicsQuality.LOW:
		return false
	if Dev.has("ink-line"):
		return Dev.arg("ink-line") != "0"
	return INK_DEFAULT_ON


## Puts the filter on the camera when wanted() (and takes it off when not), or else the ink line alone when
## ink_wanted(), enabled only in the stylized look (VisualProfile). Returns whether one is on the camera.
static func attach(camera: Camera3D, level: int) -> bool:
	if camera == null:
		return false
	var line := not wanted(level) and ink_wanted(level)
	if not wanted(level) and not line:
		camera.compositor = null
		return false
	if camera.compositor and camera.compositor.compositor_effects.size() > 0 and camera.compositor.compositor_effects[0] is PaintPass \
			and (camera.compositor.compositor_effects[0] as PaintPass).ink == line:
		return true
	var effect := PaintPass.new()
	if line:
		effect.ink = true
		effect.kuwahara = false
		effect.effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
		effect.needs_normal_roughness = true
	else:
		# with MSAA the frame is resolved again after the transparent pass and the filter's work is lost (measured
		# on the Alta's 2x): the filter runs without it
		camera.get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	effect.enabled = false
	VisualProfile.vary(effect, {&"enabled": true})
	var comp := Compositor.new()
	var effects: Array[CompositorEffect] = [effect]
	comp.compositor_effects = effects
	camera.compositor = comp
	return true


func _make() -> void:
	if _rd == null:
		return
	_shader = _rd.shader_create_from_spirv(SHADER.get_spirv())
	if not _shader.is_valid():
		return
	_pipeline = _rd.compute_pipeline_create(_shader)
	var state := RDSamplerState.new()
	state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	_sampler = _rd.sampler_create(state)


func _render_callback(_type: int, data: RenderData) -> void:
	if _rd == null or not _pipeline.is_valid():
		return
	var buffers := data.get_render_scene_buffers() as RenderSceneBuffersRD
	if buffers == null:
		return
	var size := buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return
	var scale := size.y / 1080.0
	var usage := RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	if not buffers.has_texture(&"paint_pass", &"copy"):
		buffers.create_texture(&"paint_pass", &"copy", RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, usage,
			RenderingDevice.TEXTURE_SAMPLES_1, size, 1, 1, true, false)
	var edge := Color(EDGE_COLOR.srgb_to_linear(), EDGE_ALPHA if contour else 0.0)
	var width := EDGE_PX
	var jump := EDGE_JUMP
	if ink:
		edge = Color(INK_COLOR.srgb_to_linear(), INK_ALPHA)
		width = INK_PX
		jump = INK_JUMP
	var nr := RID()
	if ink and buffers.has_texture(&"forward_clustered", &"normal_roughness"):
		nr = buffers.get_texture(&"forward_clustered", &"normal_roughness")
	var mask := 0.0
	if nr.is_valid():
		mask = 2.0 if Dev.has("ink-debug") else 1.0
	var filter := _push(size, maxf(1.0, roundf(RADIUS * scale)), maxf(1.0, width * scale), edge, 1.0 if kuwahara else 0.0, 0.0, jump, mask)
	var back := _push(size, 0.0, 0.0, Color(0, 0, 0, 0), 0.0, 1.0, jump)
	var groups := Vector2i(ceili(size.x / 8.0), ceili(size.y / 8.0))
	for view in buffers.get_view_count():
		var color := buffers.get_color_layer(view)
		var depth := buffers.get_depth_layer(view)
		var copy := buffers.get_texture(&"paint_pass", &"copy")
		var tag := nr if nr.is_valid() else depth
		_dispatch(color, copy, depth, tag, filter, groups)
		_dispatch(copy, color, depth, tag, back, groups)


static func _push(size: Vector2i, radius: float, edge_px: float, edge: Color, kuwahara: float, copy_only: float, jump: float, mask := 0.0) -> PackedByteArray:
	return PackedFloat32Array([size.x, size.y, radius, edge_px, edge.r, edge.g, edge.b, edge.a, jump, kuwahara,
		copy_only, mask]).to_byte_array()


func _dispatch(from: RID, to: RID, depth: RID, tag: RID, push: PackedByteArray, groups: Vector2i) -> void:
	var out := RDUniform.new()
	out.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	out.binding = 0
	out.add_id(to)
	var src := RDUniform.new()
	src.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	src.binding = 1
	src.add_id(from)
	var deep := RDUniform.new()
	deep.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	deep.binding = 2
	deep.add_id(_sampler)
	deep.add_id(depth)
	var rough := RDUniform.new()
	rough.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	rough.binding = 3
	rough.add_id(_sampler)
	rough.add_id(tag)
	var uniforms := UniformSetCacheRD.get_cache(_shader, 0, [out, src, deep, rough])
	var list := _rd.compute_list_begin()
	_rd.compute_list_bind_compute_pipeline(list, _pipeline)
	_rd.compute_list_bind_uniform_set(list, uniforms, 0)
	_rd.compute_list_set_push_constant(list, push, push.size())
	_rd.compute_list_dispatch(list, groups.x, groups.y, 1)
	_rd.compute_list_end()
