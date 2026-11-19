shader_type spatial;
// The light of a sword arc (C12d, VX-01): only the leading edge of the blade, drawn over the dark ink body
// (slash_ink.gdshader). A fine ivory-mint line where the edge of the blade passed (edge_px pixels, the only part
// near white) and, just inside it, a soft core in the blow's colour made pale (core_sat at most), fading along the
// tail; the head is the brightest, so a still frame tells which way the blade went. Never a sheet of saturated green.
// UV.x runs along the swing (0 start, 1 end), UV.y across it (0 inner side of the mesh, 1 its outer edge).
// The edge sits where the blade's tip passed: blade_m meters from the paladin when Fx gives reach_m and band_from (the
// mesh runs from band_from * reach_m to reach_m); without them, at the outer edge of the mesh.
// t goes 0 -> 1 over the life of the slash: the head sweeps through during the first `sweep` of it, then the tail
// catches up with it while everything fades.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(0.85, 0.82, 1.0, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.4;
uniform float intensity = 2.2;
uniform bool flip = false;
// Share of the arc the tail covers behind the head.
uniform float tail = 0.6;
// Where the mesh starts (a share of reach_m, Fx.SLASH_INNER), the reach in meters, and the meters from the paladin
// where the blade's tip passes (0: the outer edge of the mesh).
uniform float band_from = 0.5;
uniform float reach_m = 0.0;
uniform float blade_m = 0.0;
// The leading edge: its width in pixels, how far it goes from the blow's colour toward ivory, and its light (with
// intensity: its largest channel near 1, the only near-white of the arc).
uniform float edge_px = 3.0;
uniform float edge_pale = 0.8;
uniform float edge_light = 0.62;
// The soft core inside the edge: how deep it reaches inward (a share of the band between the mesh's inner side and
// the edge), its light, and its colour's saturation at most (the blow's colour made pale; Emeth's green reads mint).
uniform float core_depth = 0.45;
uniform float core_light = 0.24;
uniform float core_sat = 0.4;
// The edge vanishes over this share of the tail (the head keeps the light).
uniform float edge_tail = 0.85;

// Eterra Stylized (STY-06, T23): with the global art_style at 1 the core reaches style_core_depth inward and keeps more
// of its depth down the tail (style_core_thin), cut into broken strokes over the back half (slash_strokes.gdshaderinc);
// the leading edge stays whole; nothing the arc adds passes style_cap a channel (the core reads under 235 on the
// screen). art_style 0: the classic arc, unchanged.
// STY-10 (P2-3 of the STY-09 combat review: more veil than blade): the core 28% dimmer and less deep (style_core_light,
// style_core_depth), and the leading edge its own light under its own cap style_edge_cap (on the floor, its top 15% at
// about 220 of luma and nothing past 235; the core about 150), so the edge that cuts is the light of the arc. Over the
// light bone of a crowd the added edge still reaches white, as in the classic look.
global uniform float art_style;
uniform float style_core_depth = 0.6;
uniform float style_core_thin = 0.5;
uniform float style_core_light = 0.216;
uniform float style_cap = 0.55;
uniform float style_edge_cap = 0.38;

#include "res://assets/shaders/slash_strokes.gdshaderinc"

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// The blow's colour with its saturation brought down to sat (its hue and brightest channel kept).
vec3 pale_to(vec3 c, float sat) {
	float top = max(c.r, max(c.g, c.b));
	float low = min(c.r, min(c.g, c.b));
	float now = (top - low) / max(top, 0.001);
	float k = now > sat ? 1.0 - sat / now : 0.0;
	return mix(c, vec3(top), k);
}

// Where the blade's edge lies across the mesh (UV.y).
float edge_at() {
	if (reach_m <= 0.0 || blade_m <= 0.0) {
		return 0.975;
	}
	float inner = band_from * reach_m;
	return clamp((blade_m - inner) / max(reach_m - inner, 0.001), 0.06, 0.975);
}

void fragment() {
	float head = clamp(t / sweep, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	float behind = head - along;
	if (behind < 0.0) discard;
	float rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
	float k = behind / (tail * (1.0 - 0.5 * rest));
	if (k >= 1.0) discard;
	float y = UV.y;
	float e = edge_at() - noise(vec2(along * 40.0, 3.0)) * 0.012;
	// a pointed nose at the head and no straight cut where the swing stops
	float nose = pow(clamp(behind / 0.08, 0.0, 1.0), 0.8) * sqrt(smoothstep(0.0, 0.07, 1.0 - along));
	float px = max(fwidth(y), 0.0001);
	// the fine leading edge: edge_px pixels wide, sharp, fading along the tail
	float wire = (1.0 - smoothstep(px * edge_px * 0.5, px * (edge_px * 0.5 + 1.0), abs(y - e))) * nose;
	wire *= 1.0 - smoothstep(edge_tail * 0.4, edge_tail, k);
	// the core: light just inside the edge, thinner toward the end of the tail
	bool styled = art_style > 0.5;
	float depth = core_depth * e * pow(1.0 - k, 1.2) * nose;
	if (styled) {
		depth = style_core_depth * e * pow(1.0 - k, style_core_thin) * nose;
	}
	float inside = (e - y) / max(depth, 0.001);
	float core = (y < e && inside < 1.0) ? pow(1.0 - inside, 2.0) : 0.0;
	if (styled) {
		// a flatter body of paint, broken into strokes in the back half
		core = (y < e && inside < 1.0) ? pow(1.0 - inside, 0.8) : 0.0;
		float band_m = reach_m > 0.0 ? (1.0 - band_from) * reach_m : 1.0;
		core *= slash_strokes(y * band_m, k, rest, fwidth(y * band_m));
	}
	float glow = pow(1.0 - k, 1.6);
	float life = pow(1.0 - rest, 1.5);
	vec3 edge_c = mix(color.rgb, vec3(1.0), edge_pale);
	vec3 core_c = pale_to(color.rgb, core_sat);
	if (wire + core <= 0.002) discard;
	ALBEDO = (edge_c * wire * edge_light * (0.55 + 0.45 * glow) + core_c * core * core_light * glow) * life * intensity;
	if (styled) {
		vec3 edge_part = min(edge_c * wire * edge_light * (0.55 + 0.45 * glow) * life * intensity, vec3(style_edge_cap));
		vec3 core_part = min(core_c * core * style_core_light * glow * life * intensity, vec3(style_cap));
		ALBEDO = min(edge_part + core_part, vec3(mix(style_cap, style_edge_cap, clamp(wire, 0.0, 1.0))));
	}
}
