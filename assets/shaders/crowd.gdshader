shader_type spatial;
// The crowd: baked poses drawn by MultiMesh. INSTANCE_CUSTOM carries the per-enemy state:
// r = white hit flash (above WHITE_FROM the body is pure white: the first frame or two of a strong blow),
// g = frost, b = burning, a = dissolve on death.
//
// The crowd is not lit by the torches (too many lights for hundreds of characters), so it carries its own
// painted light: a fixed key from the top left of the screen (light bone, dark crevices), darker feet, and a thin
// dark edge where the body turns away, so each one reads as a shaded figure against the dark floor (reference
// docs/art/ref/arena_catacumbas_1672.png), never a flat cut-out.
render_mode cull_back, diffuse_lambert, specular_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec3 rim_color : source_color = vec3(0.4, 0.55, 1.0);
uniform float rim_power = 0.0;
// 1 = the texture's colours in grey; a little calms the saturated leathers of the KayKit atlas.
uniform float desaturate = 0.0;
// How much the scene's own light (the cold ambient and the moon) still lights the body: it tints, the key shapes.
uniform float scene_light = 1.0;
// The painted key light: direction in view space (top left of the screen, toward the camera), colour, strength
// on the lit side and what is left on the side away from it.
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.5);
uniform vec3 key_color : source_color = vec3(1.0, 0.95, 0.86);
uniform float key = 0.0;
uniform float key_fill = 0.0;
// Feet darker than the head (the floor's shadow climbing the legs): brightness at the feet, height in the model's
// meters where it is full.
uniform float foot_shade = 1.0;
uniform float foot_height = 1.2;
// The dark edge where the body turns away from the camera: how dark (0 = none) and where it starts (0..1 of the
// grazing angle).
uniform float ink = 0.0;
uniform float ink_from = 0.55;
// Flash strength above which the body is drawn pure white.
uniform float white_from = 0.75;

// The paladin carries the light of Elun: the warm light around the hero is added here.
global uniform vec3 hero_pos;
uniform vec3 hero_color : source_color = vec3(1.0, 0.72, 0.42);
uniform float hero_range = 11.0;

varying vec4 state;
varying vec3 world_pos;
varying float height;

void vertex() {
	state = INSTANCE_CUSTOM;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = VERTEX.y;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	if (state.a > 0.0 && hash(floor(UV * 96.0)) < state.a) {
		discard;
	}
	vec3 c = texture(albedo, UV).rgb;
	c = mix(c, vec3(dot(c, vec3(0.3, 0.55, 0.15))), desaturate);
	c *= tint.rgb;
	c = mix(c, vec3(0.6, 0.85, 1.0), state.g * 0.65);
	float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float shade = mix(foot_shade, 1.0, smoothstep(0.0, foot_height, height))
		* (1.0 - ink * smoothstep(ink_from, 1.0, 1.0 - facing));
	ALBEDO = c * scene_light * shade;
	float near = 1.0 - clamp(distance(world_pos.xz, hero_pos.xz) / hero_range, 0.0, 1.0);
	float lit = key_fill + key * max(dot(NORMAL, normalize(key_dir)), 0.0);
	float rim = pow(1.0 - facing, 3.0);
	// a crisp edge for elites (rim_power > 0): sharper than the soft rim, so it reads as an outline
	float edge = smoothstep(0.35, 0.6, pow(1.0 - facing, 1.5));
	EMISSION = vec3(1.8) * state.r + vec3(0.35, 0.7, 1.4) * state.g * 0.5 + vec3(2.0, 0.6, 0.1) * state.b * (0.4 + 0.4 * rim)
		+ rim_color * (rim * 0.5 + edge) * rim_power + vec3(1.6, 0.5, 0.1) * state.a * 2.0
		+ c * shade * (key_color * lit + hero_color * near * near * 0.55);
	if (state.r > white_from) {
		ALBEDO = vec3(0.0);
		EMISSION = vec3(3.0);
	}
}
