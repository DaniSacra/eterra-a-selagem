shader_type spatial;
// The petrified tree of the Jardim das Raízes Mortas (StoneTree, cycle C12; docs/art/cycle12_arenas_spec.md 4.4): stone,
// not wood. A fine grain runs along each limb (UV.y: meters along its spine, UV.x: meters round it), the cords of the
// bark are lighter than the deep grooves between them, grey-green lichen patches its lower half, clean fractures are
// lighter still, and a few grooves at its foot carry a faint vein of corrupted emerald (emission only, at most
// vein_light, under the glow's threshold). Vertex colour (StoneTree): r = on a cord (1) or in a groove (0),
// g = where lichen may grow, b = a fracture, a = a groove that carries a vein.
// Opens in a stipple round the paladin like the obelisks (see_through.gdshaderinc); the x-ray behind stone sees him.
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.30, 0.30, 0.34);
uniform vec3 cord_color : source_color = vec3(0.45, 0.43, 0.48);
// What is left of the base colour deep in a groove.
uniform float groove_dark = 0.35;
uniform vec3 lichen_color : source_color = vec3(0.22, 0.26, 0.22);
uniform float lichen = 0.75;
uniform vec3 fracture_color : source_color = vec3(0.55, 0.53, 0.56);
// The vein's colour (its hue; its largest channel is set to vein_light) and how wide it runs in a groove (of the
// cord-to-groove value).
uniform vec3 vein_color : source_color = vec3(0.32, 0.70, 0.60);
uniform float vein_light = 0.6;
uniform float vein_width = 0.22;
// The grain: streaks round (x) and along (y) the spine, and how much they move the value.
uniform vec2 grain = vec2(4.0, 0.45);
uniform float grain_value = 0.3;
uniform float mottle = 0.22;
// Fine cross cracks of the stone (a petrified limb splits across its grain), and long fissures along the grain (the
// old bark's): how many a meter round, how dark, how wide.
uniform float cross_cracks = 0.5;
uniform float fissures = 2.2;
uniform float fissure_dark = 0.4;
uniform float fissure_width = 0.12;
uniform sampler2D rock_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D rock_height : filter_linear_mipmap, repeat_enable;
uniform float rock_scale = 0.9;
uniform float rock_value = 0.38;
uniform float relief = 1.3;
// The values of the whole (the arena's light may want the tree a step lighter than the floor round it).
uniform float value = 0.62;
// Darker where it meets the floor (the grime and the shadow of the hollow under the flare), up to this height.
uniform float foot_dark = 0.55;
uniform float foot_height = 0.7;
// (see masonry.gdshader)
uniform float see_through = 1.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
uniform float see_gap = 0.4;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		s += noise(p) * a;
		p *= 2.07;
		a *= 0.5;
	}
	return s;
}

varying float world_y;

void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

#include "res://assets/shaders/see_through.gdshaderinc"

void fragment() {
	if (see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	float cord = COLOR.r;
	vec3 c = mix(base_color * groove_dark, cord_color, smoothstep(0.05, 0.95, cord));
	// grain along the spine
	float g = fbm(vec2(UV.x * grain.x, UV.y * grain.y));
	c *= 1.0 - grain_value + grain_value * 2.0 * g;
	float rh = texture(rock_height, UV * rock_scale).r;
	c *= mix(1.0 - rock_value, 1.0 + rock_value * 0.5, smoothstep(0.2, 0.8, rh));
	// big patches of darker and lighter stone (weathering), so no two cords read alike
	c *= 1.0 - mottle + mottle * 2.0 * fbm(UV * vec2(0.35, 0.22) + 11.0);
	// a few dark cracks across the grain
	float across = abs(fract(UV.y * 0.9 + noise(UV * vec2(1.5, 0.4)) * 0.8) - 0.5);
	float crack = (1.0 - smoothstep(0.0, 0.02, across)) * step(0.6, noise(vec2(UV.x * 0.7, floor(UV.y * 0.9))));
	c *= 1.0 - crack * cross_cracks * cord;
	// long fissures along the grain, wavering, broken here and there
	float fx = UV.x * fissures + (noise(vec2(UV.y * 0.6, UV.x * 0.5)) - 0.5) * 1.4;
	float fis = 1.0 - smoothstep(0.0, fissure_width, abs(fract(fx) - 0.5));
	fis *= smoothstep(0.3, 0.55, noise(vec2(floor(fx) * 3.1, UV.y * 0.7)));
	c *= 1.0 - fis * fissure_dark;
	float lich = COLOR.g * smoothstep(0.42, 0.62, fbm(UV * vec2(0.8, 0.6) + 3.1)) * lichen;
	c = mix(c, lichen_color * (0.8 + 0.4 * rh), lich);
	c = mix(c, fracture_color * (0.85 + 0.3 * rh), COLOR.b);
	c *= mix(foot_dark, 1.0, smoothstep(0.0, foot_height, world_y));
	ALBEDO = c * value;
	float vein = COLOR.a * (1.0 - smoothstep(0.0, vein_width, cord));
	vein *= smoothstep(0.38, 0.55, fbm(vec2(UV.y * 1.4, UV.x * 0.4) + 7.0));
	EMISSION = vein_color / max(max(vein_color.r, vein_color.g), vein_color.b) * vein_light * vein;
	ROUGHNESS = mix(0.86, 0.97, 1.0 - cord);
	SPECULAR = 0.25;
	NORMAL_MAP = texture(rock_normal, UV * rock_scale).rgb;
	NORMAL_MAP_DEPTH = relief;
}
