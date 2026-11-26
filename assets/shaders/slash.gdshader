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
// vfx_pass_spec.md V-01: premultiplied, ALPHA 0 in the classic look (the same sum as blend_add); in the stylized look
// the edge half as pale (style_edge_pale: the Emeth's green, never cyan or white), and the arc laid over what is
// behind it under style_peak (Fx: ScreenTone.linear_peak of its edge colour, 226 on the screen), its hue kept (a cap per
// channel greyed it: the edge (0.86; 1; 0.89) capped at 0.38 was flat grey-white).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;

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
// vfx_pass_spec.md 5.3: the family of the Blessing that changes the blow (Fx.family_of; -1 the sword's own): Chama the
// back of the ribbon breaks into tongues licking in from the edge, Geada 4 to 6 ice barbs hang in from the edge near the
// head, Luz a thinner edge that lasts the whole tail, Vigília three segmented strokes behind the edge (the cry's echo).
uniform int family = -1;

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
// VFX review P2 (saturation p50 near 0.4, it was 0.18 to 0.26): the stylized edge less pale (0.3, it was 0.45) and
// the core more of its colour (style_core_sat 0.65)
uniform float style_edge_pale = 0.3;
uniform float style_core_sat = 0.65;
uniform float style_peak = 0.6;
// AD2-02 (art review 2026-11-25: a weak cut): the paladin's own arcs (Fx.slash with a blade) ask more of the stylized
// look: style_core_light 0.35 (it was 0.216), a deeper core, and a fine edge of the blow's hue over the cap at
// style_wire_glow (1.5; 0: off) on the wire only, never on the body of the arc (nothing past style_wire_cap).
uniform float style_wire_glow = 0.0;
uniform float style_wire_cap = 1.3;
// E1-2: the paladin's own arc keeps its core off his body: nothing lit within body_clear_m meters of him (soft over a
// third of that), so no pixel of him is blown out (0: off, for the volleys and bosses).
uniform float body_clear_m = 0.0;
// 2026-11-25 (effects pass: painted, not smooth): a strip of dry-brush streaks (tools/make_fx_textures.gd) breaks the core
// into bristle marks along the swing, and tears the leading edge toward the tail. paint_amt 0: off (volleys, bosses).
uniform sampler2D paint : hint_default_white, repeat_enable, filter_linear;
uniform float paint_amt = 0.0;
// The edge of the paladin's own cut goes this much more toward white (his family colour stays in the fine fringe the
// wire glow adds), so it reads against the green rooms (0: style_edge_pale alone).
uniform float edge_white = 0.0;

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
	float wire_px = family == 2 ? edge_px * 0.6 : edge_px;
	float wire_tail = family == 2 ? 1.05 : edge_tail;
	// the fine leading edge: edge_px pixels wide, sharp, fading along the tail
	float wire = (1.0 - smoothstep(px * wire_px * 0.5, px * (wire_px * 0.5 + 1.0), abs(y - e))) * nose;
	wire *= 1.0 - smoothstep(wire_tail * 0.4, wire_tail, k);
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
	// the same clearing for the family's own light (ART_REVIEW_2026-11-26c P1-2: the Marca's band crossed his head)
	float clear = 1.0;
	if (styled && body_clear_m > 0.0 && reach_m > 0.0) {
		float dist = mix(band_from * reach_m, reach_m, y);
		clear = smoothstep(body_clear_m * 0.65, body_clear_m, dist);
		core *= clear;
	}
	if (paint_amt > 0.0) {
		float brush = texture(paint, vec2(along * 1.6 - k * 0.25, y * 1.3)).r;
		core *= mix(1.0, 0.25 + 1.1 * brush, paint_amt);
		wire *= mix(1.0, 0.55 + 0.9 * brush, paint_amt * 0.6 * smoothstep(0.1, 0.7, k));
		// P2-1: the outer thread breaks in a few places along the arc (at least two gaps), more in the tail
		float gap = texture(paint, vec2(along * 2.3 + 0.37, 0.61)).r;
		wire *= 1.0 - paint_amt * 0.8 * (1.0 - smoothstep(0.2, 0.4, gap)) * smoothstep(0.05, 0.4, k);
	}
	float glow = pow(1.0 - k, 1.6);
	float life = pow(1.0 - rest, 1.5);
	vec3 fam = vec3(0.0);
	if (family == 0) {
		// tongues: four lanes along the back of the tail, each a flame licking in from the edge, its tip redder
		float lane = (k - 0.3) / 0.7 * 4.0;
		float u = fract(lane) * 2.0 - 1.0;
		float id = floor(lane);
		float h = (e - y) / 0.3;
		float w = pow(clamp(1.0 - h, 0.0, 1.0), 0.7) * 0.8 * (0.8 + 0.2 * sin(TIME * 25.0 + id * 2.3));
		float tongue = step(0.3, k) * step(0.0, h) * step(h, 1.0) * (1.0 - smoothstep(w - 0.2, w, abs(u)));
		core *= 1.0 - step(0.3, k);
		fam = mix(color.rgb, color.rgb * vec3(0.8, 0.38, 0.22), h) * tongue * pow(1.0 - k, 0.6) * 0.5;
	} else if (family == 1) {
		// ice barbs hanging in from the edge, five along the arc, near the head only
		float lane = along * 5.0;
		float u = fract(lane) * 2.0 - 1.0;
		float h = (e - y) / 0.2;
		float barb = step(0.0, h) * step(h, 1.0) * (1.0 - smoothstep((1.0 - h) * 0.45 - 0.05, (1.0 - h) * 0.45, abs(u)));
		barb *= 1.0 - smoothstep(0.4, 0.75, k);
		fam = mix(color.rgb, vec3(1.0), u > 0.0 ? 0.45 : 0.1) * barb * 0.55;
	} else if (family == 3) {
		// the cry's echo: three strokes behind the edge, broken into segments
		float strokes = 0.0;
		for (int i = 1; i <= 3; i++) {
			float at = e - 0.09 * float(i);
			strokes += (1.0 - smoothstep(px, px * 2.0, abs(y - at))) * (1.0 - 0.22 * float(i));
		}
		strokes *= step(0.25, fract(along * 14.0)) * (1.0 - smoothstep(0.2, 0.8, k)) * nose;
		core *= 0.6;
		fam = mix(color.rgb, vec3(1.0), 0.2) * strokes * 0.5;
	}

	fam *= clear;
	vec3 edge_c = mix(color.rgb, vec3(1.0), edge_pale);
	vec3 core_c = pale_to(color.rgb, core_sat);
	if (wire + core <= 0.002 && max(fam.r, max(fam.g, fam.b)) <= 0.002) discard;
	ALBEDO = (edge_c * wire * edge_light * (0.55 + 0.45 * glow) + core_c * core * core_light * glow + fam) * life * intensity;
	ALPHA = 0.0;
	if (styled) {
		vec3 ec = mix(color.rgb, vec3(1.0), clamp(style_edge_pale + edge_white, 0.0, 1.0));
		vec3 lit = ec * wire * edge_light * (0.55 + 0.45 * glow) * life * intensity + pale_to(color.rgb, style_core_sat) * core * style_core_light * glow * life * intensity + fam * life * intensity;
		float peak = max(lit.r, max(lit.g, lit.b));
		if (peak > style_peak) {
			lit *= style_peak / peak;
			peak = style_peak;
		}
		ALBEDO = lit;
		ALPHA = clamp(peak / max(style_peak, 0.0001), 0.0, 1.0);
		if (style_wire_glow > 0.0) {
			vec3 hue = color.rgb / max(max(color.r, color.g), max(color.b, 0.001));
			vec3 fio = mix(hue, vec3(1.0), 0.15) * wire * (0.55 + 0.45 * glow) * life * style_wire_glow;
			ALBEDO += fio;
			float most = max(ALBEDO.r, max(ALBEDO.g, ALBEDO.b));
			ALBEDO *= min(1.0, style_wire_cap / max(most, 0.0001));
		}
	}
}
