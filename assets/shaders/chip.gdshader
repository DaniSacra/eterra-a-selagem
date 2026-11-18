shader_type spatial;
// The motes and chips of Fx (one MultiMesh, C12d VX-10): each one a sliver stretched along its flight, not a round
// dot. Per instance (Fx._animate_motes writes them): the basis's x column is the sliver's axis in the world, its length
// the sliver's length (meters); the y column's length is its width; the origin where it is; the colour is its light
// (already faded). Drawn on a unit quad turned round the axis to face the camera, pointed at both ends, a little paler
// in the middle.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled, skip_vertex_transform;

// How far the middle goes toward ivory, and the sliver's shape: its width over the length (1: a lens as wide as
// long), how soft its sides are.
uniform float heart_pale = 0.35;
uniform float soft = 0.35;

// Eterra Stylized (STY-06, T24; docs/art/stylized_spec.md 3.3): with the global art_style at 1 the emerald motes a swing
// sheds (green the largest channel, saturated) are thin strokes, style_thin of their width (0.06 to 0.03 m), with no
// channel past style_cap (under the glow: paint, not light); the grey chips of a hit and the gold ones are as before.
// art_style 0: as before.
global uniform float art_style;
uniform float style_thin = 0.5;
uniform float style_cap = 0.9;

varying vec4 tone;

void vertex() {
	vec3 center = MODEL_MATRIX[3].xyz;
	vec3 along = MODEL_MATRIX[0].xyz;
	float width = length(MODEL_MATRIX[1].xyz);
	tone = COLOR;
	if (art_style > 0.5) {
		float top = max(COLOR.r, max(COLOR.g, COLOR.b));
		float colourful = (top - min(COLOR.r, COLOR.b)) / max(top, 0.001);
		float emerald = step(0.45, colourful) * step(max(COLOR.r, COLOR.b), COLOR.g);
		width *= mix(1.0, style_thin, emerald);
		tone.rgb *= mix(1.0, min(1.0, style_cap / max(top, 0.001)), emerald);
	}
	vec3 to_cam = CAMERA_POSITION_WORLD - center;
	vec3 axis = length(along) > 0.0001 ? along : vec3(width, 0.0, 0.0);
	vec3 side = cross(normalize(axis), normalize(to_cam));
	side = length(side) > 0.0001 ? normalize(side) : normalize(cross(vec3(0.0, 1.0, 0.0), normalize(to_cam)));
	vec3 world = center + axis * VERTEX.x + side * width * VERTEX.y;
	VERTEX = (VIEW_MATRIX * vec4(world, 1.0)).xyz;
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	// pointed at both ends: as wide as the quad in the middle, nothing at the tips
	float k = abs(p.x);
	float w = 1.0 - k * k;
	float d = abs(p.y) / max(w, 0.001);
	float body = (1.0 - smoothstep(1.0 - soft, 1.0, d)) * step(k, 0.999);
	if (body <= 0.002) discard;
	float heart = 1.0 - smoothstep(0.0, 0.5, d);
	vec3 c = mix(tone.rgb, vec3(max(tone.r, max(tone.g, tone.b))), heart * heart_pale);
	ALBEDO = c * body;
}
