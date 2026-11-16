shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
// The standing lion of Eterra on a banner (cycle C12, Daniel 2026-11-16: the banners of the arenas and of the catacomb
// hall carry the lion): the seal's own drawing (assets/textures/seal/lion_sdf.res, red = signed distance to its
// outline, green = to its inner cuts, 0.5 on each edge) in old gold, with a dark edge round it so it reads on the
// red folds and the cuts (eye, mane, claws) in the same dark. Laid on a patch of the cloth (ArenaKit.banner, its UV
// 0..1 over the patch); outside the lion nothing is drawn. Matte, no light of its own above the cloth's: it is
// embroidery, not a lamp. Works in Compatibility (no transparency, a discard).

uniform sampler2D lion : filter_linear_mipmap, repeat_disable;
// Pixels of the field from the edge to the full swing, and the texture's size (tools/make_seal_lion.gd).
uniform float spread = 24.0;
uniform float px = 512.0;
// The gold, its lit side a little lighter, the dark of the edge and the cuts, the edge's width (in field pixels).
uniform vec3 gold : source_color = vec3(0.65, 0.47, 0.18);
uniform vec3 edge_color : source_color = vec3(0.06, 0.05, 0.05);
uniform float edge_px = 5.0;
uniform float cut_px = 1.2;
// The cloth's own faint glow (as ArenaKit.BANNER_GLOW: never black in cold light), times the gold.
uniform float glow = 0.35;

varying float fold;

void vertex() {
	fold = COLOR.r;
}

void fragment() {
	vec2 f = texture(lion, UV).rg;
	if (UV.x < 0.0 || UV.y < 0.0 || UV.x > 1.0 || UV.y > 1.0) {
		discard;
	}
	// signed distances in field pixels (+ inside)
	float body = (f.r - 0.5) * spread * 2.0;
	float cut = (f.g - 0.5) * spread * 2.0;
	if (body < -edge_px) {
		discard;
	}
	float in_body = smoothstep(-0.6, 0.6, body);
	float in_cut = smoothstep(-cut_px, cut_px * 0.2, cut);
	float g = in_body * (1.0 - in_cut);
	// a little relief: lighter toward the middle of each limb
	vec3 c = gold * mix(0.8, 1.05, smoothstep(0.0, 6.0, body)) * fold;
	ALBEDO = mix(edge_color, c, g);
	EMISSION = ALBEDO * glow;
	ROUGHNESS = 0.7;
	METALLIC = 0.35 * g;
}
