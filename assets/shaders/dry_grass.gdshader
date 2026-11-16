shader_type spatial;
// Tufts of dry grass in the garden (GardenLook, cycle C12; spec 1.3): crossed cards cut by the shader into a few thin
// leaning blades (no blending: discarded where no blade is, like alpha scissor), grey-brown and matte, darker at the
// foot. One MultiMesh; each tuft picks its own blades by where it stands. Never glows.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec3 color : source_color = vec3(0.33, 0.31, 0.27);
uniform vec3 foot_color : source_color = vec3(0.14, 0.13, 0.11);
uniform int blades = 7;
uniform float blade_width = 0.06;

varying float seed;

void vertex() {
	seed = fract(sin(dot(MODEL_MATRIX[3].xz, vec2(12.9898, 78.233))) * 43758.5453);
	// lit as the floor under it (a card's own normal flickers as the camera turns)
	NORMAL = (inverse(MODEL_MATRIX) * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
}

float h1(float x) {
	return fract(sin(x * 91.17 + seed * 47.3) * 43758.5453);
}

void fragment() {
	float h = 1.0 - UV.y;
	float hit = 0.0;
	float tone = 1.0;
	for (int i = 0; i < blades; i++) {
		float fi = float(i);
		float base = 0.1 + 0.8 * h1(fi);
		float lean = (h1(fi + 11.0) - 0.5) * 0.7;
		float top = 0.45 + 0.55 * h1(fi + 23.0);
		float x = base + lean * h * h;
		float w = blade_width * (1.0 - h / top);
		if (h < top && abs(UV.x - x) < w) {
			hit = 1.0;
			tone = 0.8 + 0.4 * h1(fi + 31.0);
		}
	}
	if (hit < 0.5) {
		discard;
	}
	ALBEDO = mix(foot_color, color * tone, smoothstep(0.0, 0.55, h));
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
}
