shader_type spatial;
// The Seta de Luz as the Guerreiro's blade wave (W-1, decision D-69; Projectiles SPARK and its held version WAVE): a
// short, thin crescent of the Emeth's emerald lying flat at chest height and flying the way it was thrown, its bow
// forward, its two points trailing (the Fx.crescent of a finisher, small). A pale leading edge, the emerald body
// thinning behind it, the thread of old gold of the special along its middle (the veins of the blade) and a faint wake
// behind the bow. Nothing goes over the glow threshold (Game.GLOW_THRESHOLD 1.3): the brightest channel it writes is
// `peak`. It lays its light over what is behind it (premultiplied, like beam.gdshader) with a little dark ink behind
// the light, so it reads on the lit floor too, and it opens around the paladin where it is nearer the camera than he
// is (hero_hole), so it never covers him. Only the look: the hit is Projectiles' circle of Shot.radius, unchanged.
// Drawn on a flat quad (PlaneMesh 1 x 1) set to its size here, in meters, in the shot's own frame (+Z its flight).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

global uniform vec3 hero_pos;

// The blow's colour (Combat.EMETH, or a gift's): only its hue is used, its brightest channel goes to `peak`.
uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
// The special's old gold (its mark since cycle 8) and how bright the thread is.
uniform vec3 gold : source_color = vec3(0.95, 0.72, 0.3);
uniform float gold_light = 0.8;
// The brightest channel of the leading edge (linear, under the glow threshold) and the body's share of it.
uniform float peak = 1.0;
uniform float body_light = 0.55;
// How far the leading edge goes toward white.
uniform float edge_pale = 0.35;
// The crescent: meters across from point to point, how far the bow stands ahead of its points, how thick the band
// is at its middle, and the wake behind it at its longest.
uniform float span_m = 1.6;
uniform float bow_m = 0.35;
uniform float thick_m = 0.22;
uniform float wake_m = 0.9;
// The gold thread: where it runs across the band (0 leading edge, 1 back) and its width as a share of the band.
uniform float vein_at = 0.45;
uniform float vein_width = 0.18;
// The dark ink behind the light (its opacity at most) so the wave reads over a lit floor.
uniform float ink = 0.3;
// Meters flown (the wake grows as it leaves the blade) and its fade at the end of its flight (1 whole, 0 gone).
uniform float flown = 0.0;
uniform float fade = 1.0;
// The crescent opens out of the cut over its first open_m meters (from open_from of its width).
uniform float open_m = 1.2;
uniform float open_from = 0.55;
// The opening around the paladin: half its width and height in meters at his distance, the light kept in it, soft edge.
uniform vec2 hero_hole = vec2(0.7, 1.45);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
const float HERO_MID = 1.3;

// Meters in the shot's frame: x across, y along the flight (the bow at +bow_m, the points at 0).
varying vec2 at;

void vertex() {
	float back = thick_m + wake_m + 0.05;
	at = vec2(VERTEX.x * (span_m + 0.1), mix(-back, bow_m + 0.05, VERTEX.z + 0.5));
	VERTEX = vec3(at.x, 0.0, at.y);
}

void fragment() {
	float open = mix(open_from, 1.0, smoothstep(0.0, open_m, flown));
	float half_span = span_m * 0.5 * open;
	float u = at.x / max(half_span, 0.001);
	float across = 1.0 - u * u;
	if (across <= 0.0) discard;
	// the leading edge (a bow) and the band behind it, thinning to points
	float front = bow_m * open * across;
	float thick = thick_m * pow(across, 0.8);
	float v = (front - at.y) / max(thick, 0.0005);
	float band = smoothstep(-0.12, 0.05, v) * (1.0 - smoothstep(0.55, 1.0, v));
	float edge = (1.0 - smoothstep(0.0, 0.22, abs(v - 0.06))) * smoothstep(0.0, 0.25, across);
	float vein = (1.0 - smoothstep(0.0, vein_width, abs(v - vein_at))) * smoothstep(0.15, 0.5, across);
	// the wake: faint lines behind the bow, only in its middle, as long as it has flown
	float wake_len = min(wake_m, flown) * across;
	float w = (v - 1.0) * thick / max(wake_len, 0.001);
	float wake = 0.0;
	if (w > 0.0 && w < 1.0) {
		wake = (1.0 - w) * (1.0 - w) * smoothstep(0.35, 0.8, across) * (0.6 + 0.4 * sin(at.x * 23.0));
	}
	vec3 hue = color.rgb / max(max(color.r, color.g), max(color.b, 0.001));
	vec3 light = hue * peak * (band * body_light * (1.0 - 0.5 * v) + wake * 0.22);
	light = max(light, mix(hue, vec3(1.0), edge_pale) * peak * edge);
	light = mix(light, gold * gold_light * peak, vein * band);
	float dark = ink * band * smoothstep(0.2, 1.0, v);
	// the paladin seen through it
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	float keep = 1.0;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 off = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		keep = mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, length(off)));
	}
	light *= fade * keep;
	float top = max(light.r, max(light.g, light.b));
	float a = clamp(max(top / max(peak, 0.001), dark * fade * keep), 0.0, 1.0);
	if (a <= 0.003) discard;
	ALBEDO = light;
	ALPHA = a;
}
