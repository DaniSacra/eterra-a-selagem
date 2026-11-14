shader_type spatial;
// The crowd: baked poses drawn by MultiMesh. INSTANCE_CUSTOM carries the per-enemy state:
// r = white hit flash, g = frost, b = burning, a = dissolve on death.
render_mode cull_back, diffuse_lambert, specular_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec3 rim_color : source_color = vec3(0.4, 0.55, 1.0);
uniform float rim_power = 0.0;

// The paladin carries the light of Elun: the crowd is not lit by the torches (too many lights for hundreds of
// characters), so the warm light around the hero is added here.
global uniform vec3 hero_pos;
uniform vec3 hero_color : source_color = vec3(1.0, 0.72, 0.42);
uniform float hero_range = 11.0;

varying vec4 state;
varying vec3 world_pos;

void vertex() {
	state = INSTANCE_CUSTOM;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	if (state.a > 0.0 && hash(floor(UV * 96.0)) < state.a) {
		discard;
	}
	vec3 c = texture(albedo, UV).rgb * tint.rgb;
	c = mix(c, vec3(0.6, 0.85, 1.0), state.g * 0.65);
	ALBEDO = c;
	float near = 1.0 - clamp(distance(world_pos.xz, hero_pos.xz) / hero_range, 0.0, 1.0);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	// a crisp edge for elites (rim_power > 0): sharper than the soft rim, so it reads as an outline
	float edge = smoothstep(0.35, 0.6, pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 1.5));
	EMISSION = vec3(2.2) * state.r + vec3(0.35, 0.7, 1.4) * state.g * 0.5 + vec3(2.0, 0.6, 0.1) * state.b * (0.4 + 0.4 * rim)
		+ rim_color * (rim * 0.5 + edge) * rim_power + vec3(1.6, 0.5, 0.1) * state.a * 2.0 + c * hero_color * near * near * 0.55;
}
