shader_type spatial;
// The motes and chips of Fx (one MultiMesh, C12d VX-10): each one a sliver stretched along its flight, not a round
// dot. Per instance (Fx._animate_motes writes them): the basis's x column is the sliver's axis in the world, its length
// the sliver's length (meters); the y column's length is its width; the origin where it is; the colour is its light
// (already faded). Drawn on a unit quad turned round the axis to face the camera, pointed at both ends, a little paler
// in the middle.
// vfx_pass_spec.md (rule 1 of section 3): laid over what is behind it (premultiplied, a = light / cap), never added:
// however many cross, nothing passes `cap` (Fx: ScreenTone.linear_peak of white at 226), hue kept.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled, skip_vertex_transform;

// How far the middle goes toward ivory, and the sliver's shape: its width over the length (1: a lens as wide as
// long), how soft its sides are.
uniform float heart_pale = 0.35;
uniform float soft = 0.35;
uniform float cap = 1.0;

// Eterra Stylized (STY-06, T24; docs/art/stylized_spec.md 3.3): with the global art_style at 1 the emerald motes a swing
// sheds (green the largest channel, saturated) are thin strokes, style_thin of their width (0.06 to 0.03 m), with no
// channel past style_cap (under the glow: paint, not light); the grey chips of a hit and the gold ones are as before.
// art_style 0: as before.
global uniform float art_style;
uniform float style_thin = 0.5;
uniform float style_cap = 0.9;

varying vec4 tone;
// vfx_pass_spec.md 5.3: the shape of the sliver (Fx writes it in the spare z of the basis's y column): 0 a lens
// pointed at both ends, 1 a frost barb (a triangle pointed the way it flies, two facets), 2 a tongue of fire (round at
// its foot, flickering, its tip darker).
varying flat float shape;
varying flat float sway;

void vertex() {
	vec3 center = MODEL_MATRIX[3].xyz;
	vec3 along = MODEL_MATRIX[0].xyz;
	float width = abs(MODEL_MATRIX[1].y);
	shape = MODEL_MATRIX[1].z;
	sway = fract(center.x * 3.1 + center.z * 1.7) * 6.28;
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
	float side_soft = soft;
	vec3 tint = tone.rgb;
	if (shape > 1.5) {
		// a tongue: its foot (behind) round, narrowing to a tip that sways; the tip darker and redder
		float h = (p.x + 1.0) * 0.5;
		w = pow(clamp(1.0 - h, 0.0, 1.0), 0.75) * smoothstep(0.0, 0.18, h) * (0.85 + 0.15 * sin(TIME * 23.0 + p.x * 6.0 + sway));
		tint = mix(tone.rgb, tone.rgb * vec3(0.8, 0.38, 0.22), smoothstep(0.35, 1.0, h));
	} else if (shape > 0.5) {
		// a barb: wide behind, pointed ahead, sharp sides, one facet lit
		w = (1.0 - p.x) * 0.5;
		side_soft = 0.08;
		tint = tone.rgb * (p.y > 0.0 ? 1.0 : 0.62);
	}
	float d = abs(p.y) / max(w, 0.001);
	float body = (1.0 - smoothstep(1.0 - side_soft, 1.0, d)) * step(k, 0.999);
	if (body <= 0.002) discard;
	float heart = shape > 0.5 ? 0.0 : 1.0 - smoothstep(0.0, 0.5, d);
	vec3 c = mix(tint, vec3(max(tint.r, max(tint.g, tint.b))), heart * heart_pale) * body;
	float peak = max(c.r, max(c.g, c.b));
	if (peak > cap) {
		c *= cap / peak;
		peak = cap;
	}
	ALBEDO = c;
	ALPHA = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
}
