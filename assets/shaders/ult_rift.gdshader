shader_type spatial;
// The cleave's rift (U-1, the Corte do Juizo; Ultimates): the Emeth comes down and the floor splits along the band in
// front of the Guerreiro. A dark fissure that runs out from his feet to the end of the band, its lips lit in the
// Emeth's emerald (palest right at the lips), a faint emerald breath over the band it struck, a fine line on the band's
// two edges so its size reads, all fading out. Never a white flash: the brightest channel it writes is `peak`, under
// the glow threshold (Game.GLOW_THRESHOLD 1.3) and its colour kept by ScreenTone (Ultimates passes the cap). It lays its
// light over the floor (premultiplied, as emeth_wave.gdshader) and opens around the paladin where it is nearer the
// camera than he is (hero_hole), so it never covers him. Drawn on a flat quad (PlaneMesh 1 x 1) laid in meters here:
// x across the band, +Z along it from his feet.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

global uniform vec3 hero_pos;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
// The brightest channel the lips reach (linear) and the breath over the band (share of it).
uniform float peak = 1.0;
// V-09: no flat green band (it was 0.12 of the light over the whole strip): the strip is read by its two long edges
uniform float breath = 0.0;
uniform float edge_light = 0.3;
// How far the lips go toward white.
uniform float lip_pale = 0.3;
// The band in meters (length along, width across) and the fissure's width at his feet (narrower at the far end).
uniform float length_m = 12.0;
uniform float width_m = 4.0;
uniform float crack_m = 0.32;
// How far the fissure wanders off the middle (meters) and its jagged turns.
uniform float wander_m = 0.3;
uniform float seed = 0.0;
// The dark inside the fissure (opacity at most).
uniform float ink = 0.6;
// Share of the band the fissure has run along (0 to 1) and the fade (1 whole, 0 gone).
uniform float opened = 1.0;
uniform float fade = 1.0;
// The opening around the paladin: half its width and height in meters at his distance, the light kept in it, soft edge.
uniform vec2 hero_hole = vec2(0.7, 1.45);
uniform float hero_keep = 0.15;
uniform float hero_soft = 0.5;
const float HERO_MID = 1.3;

varying vec2 at;

void vertex() {
	at = vec2(VERTEX.x * (width_m + 0.2), (VERTEX.z + 0.5) * (length_m + 0.3) - 0.15);
	VERTEX = vec3(at.x, 0.0, at.y);
}

float wander(float z) {
	return wander_m * (0.6 * sin(z * 1.3 + seed * 6.28) + 0.3 * sin(z * 3.7 + seed * 17.0) + 0.15 * sign(sin(z * 9.1 + seed * 3.0)));
}

void fragment() {
	float along = at.y / max(length_m, 0.01);
	float run = clamp(opened, 0.0, 1.0);
	// the fissure's head runs out from his feet; nothing past it yet
	float ahead = smoothstep(run, run - 0.04, along) * step(0.0, at.y);
	float w = crack_m * mix(1.0, 0.35, clamp(along, 0.0, 1.0));
	float dist = abs(at.x - wander(at.y));
	float inside = 1.0 - smoothstep(w * 0.35, w * 0.6, dist);
	float lip = (1.0 - smoothstep(0.0, w * 0.5, abs(dist - w * 0.55))) * ahead;
	float glow = exp(-max(dist - w * 0.5, 0.0) / 0.45) * ahead;
	float half_w = width_m * 0.5;
	float band = step(abs(at.x), half_w) * step(0.0, at.y) * step(at.y, length_m) * smoothstep(run + 0.08, run - 0.08, along);
	float side = (1.0 - smoothstep(0.0, 0.05, abs(abs(at.x) - half_w))) * band;
	vec3 hue = color.rgb / max(max(color.r, color.g), max(color.b, 0.001));
	vec3 light = hue * peak * (glow * 0.35 + band * breath) + mix(hue, vec3(1.0), 0.4) * peak * side * edge_light * 1.6;
	light = max(light, mix(hue, vec3(1.0), lip_pale) * peak * lip);
	float dark = ink * inside * ahead;
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, HERO_MID, 0.0), 1.0)).xyz;
	float keep = 1.0;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 off = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		keep = mix(hero_keep, 1.0, smoothstep(1.0 - hero_soft, 1.0, length(off)));
	}
	light *= fade * keep * (1.0 - inside * 0.8);
	float top = max(light.r, max(light.g, light.b));
	float a = clamp(max(top / max(peak, 0.001), dark * fade), 0.0, 1.0);
	if (a <= 0.003) discard;
	ALBEDO = light;
	ALPHA = a;
}
