shader_type spatial;
// Morvath's ritual circles on the floor (cycle 9): the area of an eruption or of a summon, drawn as a carved circle of
// runes in his corrupted emerald over a violet veil. The outer rim is the edge of the area that hurts, exactly: nothing
// is drawn past d = 1 of the quad (Ground lays it radius * 2 wide). The sequence follows `progress` (the warning
// filling): a faint rune, its light growing, the veil spreading from the middle, a short double pulse just before the
// blow; then `after` (0 to 1 once it lands) dissolves it glyph by glyph. kind 2 is the steady circle under the
// ritual's shield (no veil, no pulse). Added light; only the pulse goes past the glow threshold.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, depth_prepass_alpha;

// Corrupted emerald (rim and glyphs, colder and dirtier than Emeth's crystal), the violet veil, the spectral blue of
// the cracks and the filling front. Cycle 10 (ART-006): a cold, dark teal green far from the Emeth's mint (hue about
// 165), a little more saturated than the shield's (BossShield.COLOR) so a circle that hurts still reads at a glance.
uniform vec3 color : source_color = vec3(0.26, 0.74, 0.6);
uniform vec3 deep : source_color = vec3(0.28, 0.08, 0.62);
uniform vec3 spirit : source_color = vec3(0.32, 0.6, 1.0);
uniform float progress = 0.0;
uniform float after = 0.0;
// 0 eruption, 1 summon, 2 the shield's circle.
uniform int kind = 0;
uniform float strength = 1.0;
// The circle's radius and the width of its outer rim, in meters (the rim keeps its width on small and big circles).
uniform float size_m = 2.0;
uniform float rim_m = 0.11;
// Width of a glyph along the band and of a stroke (m).
uniform float glyph_m = 0.42;
uniform float stroke_m = 0.035;
// Turns the glyphs and the inner ring so no two circles match, and how fast they turn (turns a second).
uniform float seed = 0.0;
uniform float spin = 0.012;
// How bright the rune is when it appears (a share of its full light), the veil's value, and where the pulse starts
// (share of the warning) and how much it adds.
uniform float faint = 0.32;
uniform float veil = 0.18;
// The filling front's light.
uniform float front_light = 1.0;
uniform float pulse_from = 0.84;
uniform float pulse = 0.6;
// The red of danger inside an eruption (art review P5, the signature of his other warnings: ground.gdshader's
// sign_fill of the warning red at its strength), filling from the middle with the veil; never on a summon.
uniform vec3 danger : source_color = vec3(1.0, 0.18, 0.12);
uniform float danger_fill = 0.35;
uniform float danger_strength = 1.4;

const float TAU_ = 6.2831853;
#include "res://assets/shaders/rune_glyph.gdshaderinc"

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

// A round floor's edge (cycle C11, Arena: x, z of its middle and its radius; 0 none): nothing past it.
global uniform vec3 floor_round;
varying vec3 world;

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float d = length(uv);
	if (d > 1.0 || (floor_round.z > 0.0 && length(world.xz - floor_round.xy) > floor_round.z)) {
		discard;
	}
	float R = size_m;
	float r = d * R;
	float aa = max(fwidth(r), 0.004);
	float ang = atan(uv.y, uv.x) / TAU_ + 0.5;
	bool steady = kind == 2;
	float p = steady ? 1.0 : progress;
	// the rim: the area's edge, inside it
	float rim = smoothstep(-aa, aa, r - (R - rim_m)) * (1.0 - smoothstep(R - aa * 1.5, R, r));
	// the band of glyphs between the rim and a thin inner ring
	float band_out = R - rim_m * 2.4;
	float band_h = clamp(R * 0.22, 0.22, glyph_m * 1.1);
	float band_in = band_out - band_h;
	float inner = 1.0 - smoothstep(rim_m * 0.22, rim_m * 0.22 + aa, abs(r - band_in));
	float g = 0.0;
	float cells = max(6.0, floor(TAU_ * (band_in + band_h * 0.5) / glyph_m));
	float turn = ang + seed + TIME * spin;
	float ci = floor(turn * cells);
	float alive = 1.0;
	if (r > band_in && r < band_out && band_in > 0.1) {
		vec2 cell = vec2(TAU_ * (band_in + band_h * 0.5) / cells, band_h);
		vec2 q = vec2(fract(turn * cells) * cell.x, r - band_in);
		g = 1.0 - smoothstep(stroke_m * 0.5, stroke_m * 0.5 + aa, rune_glyph(q, cell, ci + floor(seed * 97.0)));
	}
	// eight small diamonds riding on the rim, inward (the picture's marks; never past the edge)
	float da = abs(fract(ang * 8.0 + seed) - 0.5) / 8.0 * TAU_ * R;
	float diamond = 1.0 - smoothstep(0.0, aa, da / (rim_m * 1.6) + (R - rim_m * 0.5 - r) / (rim_m * 2.6) - 1.0);
	diamond *= step(r, R - rim_m * 0.5);
	// a broken inner ring turning the other way (eruption, the shield's circle) or a tight knot (summon)
	float mid_r = kind == 1 ? R * 0.32 : R * 0.5;
	float dash = step(0.35, fract((ang - seed - TIME * spin * 1.6) * (kind == 1 ? 6.0 : 14.0)));
	float mid = (1.0 - smoothstep(rim_m * 0.25, rim_m * 0.25 + aa, abs(r - mid_r))) * dash;
	// cracks of spectral light opening from the middle as the warning fills
	float cr = 1.0 - smoothstep(0.0, 0.05, abs(noise(uv * 3.2 + seed * 7.0) * 0.65 + noise(uv * 7.5 - seed * 3.0) * 0.35 - 0.5));
	float cracks = steady ? 0.0 : cr * step(d, p * 0.95) * (1.0 - smoothstep(0.3, 1.0, d)) * smoothstep(0.2, 0.6, p);
	// the violet veil filling from the middle out, its front a fine line of spectral blue (when the blow lands)
	// (brighter toward its front, as the plain warnings: the eye follows it to where the blow lands)
	float fill = steady ? 0.0 : step(d, p) * veil * (0.45 + 0.9 * smoothstep(p - 0.35, p, d));
	float front = steady ? 0.0 : (1.0 - smoothstep(0.0, 0.03, abs(d - p))) * step(0.02, p) * (1.0 - step(0.999, p));
	// the light grows from faint to full; a short double pulse warns just before the blow
	float lvl = steady ? 0.75 + 0.1 * sin(TIME * 1.4) : mix(faint, 1.0, smoothstep(0.0, 0.85, p));
	float k = clamp((p - pulse_from) / (1.0 - pulse_from), 0.0, 1.0);
	float beat = steady ? 0.0 : step(0.0001, k) * pow(sin(k * 3.14159 * 2.0), 2.0) * pulse;
	// it appears quickly instead of popping in, and dissolves glyph by glyph once it has landed
	float shown = steady ? 1.0 : smoothstep(0.0, 0.06, p);
	float gone = 1.0 - after;
	float crumble = step(after * 1.15, hash(vec2(ci, 9.0)) * 0.85 + 0.15);
	vec3 c = color * (rim * (0.95 + beat) + diamond * 0.8 + inner * 0.55 + g * (0.9 + beat * 0.6) * crumble + mid * 0.45);
	c += spirit * (cracks * 0.5 + front * front_light);
	c += deep * fill * (1.0 + beat * 0.5);
	// once landed: a last flare at the middle that fades with it
	c += spirit * (1.0 - smoothstep(0.0, 0.7, d)) * (after > 0.0 ? (1.0 - smoothstep(0.0, 0.35, after)) * 0.2 : 0.0);
	float harm = kind == 0 ? step(d, p) * danger_fill * danger_strength : 0.0;
	ALBEDO = (c * lvl * strength + danger * harm) * shown * gone * gone;
}
