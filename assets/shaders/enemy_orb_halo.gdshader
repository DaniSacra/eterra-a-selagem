shader_type spatial;
// The smoke round an enemy's orb (vfx_pass_spec.md V-11): a disc facing the camera (Projectiles.HALO times the shot's
// radius), dark smoke with a torn edge drifting round it and three short spikes in the shooter's hue turning once every
// `turn` seconds round the core; laid over what is behind (premultiplied, never added: many orbs never pile up to a
// glow). Never a round soft halo.
render_mode unshaded, blend_premul_alpha, depth_draw_never, cull_disabled, shadows_disabled;

instance uniform vec3 hue = vec3(0.53, 0.39, 1.0);
uniform vec3 smoke : source_color = vec3(0.06, 0.03, 0.05);
uniform float smoke_alpha = 0.55;
uniform float spike_light = 0.6;
uniform float turn = 0.8;
uniform float torn = 0.35;

void vertex() {
	// always facing the camera, at the node's place, at the quad's own size
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float seed = fract(dot(NODE_POSITION_WORLD, vec3(0.13, 0.0, 0.29)));
	// torn smoke: its edge eaten by noise that drifts round
	float n = noise(vec2(a * 2.5 + TIME * 1.5 + seed * 20.0, d * 3.0 - TIME));
	float edge = 0.95 - torn * n;
	float cloud = (1.0 - smoothstep(edge - 0.3, edge, d)) * smoothstep(0.25, 0.55, d);
	// three spikes turning round the core, thin, fading out to their tips
	float spin = a + TAU * TIME / turn + seed * TAU;
	float arm = pow(max(cos(spin * 1.5), 0.0), 40.0) * (1.0 - smoothstep(0.45, 0.95, d)) * smoothstep(0.35, 0.5, d);
	vec3 light = smoke * cloud * smoke_alpha + hue * spike_light * arm;
	ALBEDO = light;
	ALPHA = clamp(cloud * smoke_alpha + arm * 0.6, 0.0, 1.0);
}
