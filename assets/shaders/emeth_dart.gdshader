shader_type spatial;
// The Seta de Luz, the special of the sword (Projectiles SPARK and WAVE): a straight dart of the blade's emerald,
// pale at the point, a thread of old gold down its axis (the veins of Emeth) and a short trail that thins out behind
// it. The held version is a broader dart with a thin one on each side and a faint bow wave as wide as it reaches.
// Drawn on a quad that turns around the flight to face the camera. Everything is in meters.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, skip_vertex_transform;

uniform vec4 color : source_color = vec4(0.3, 1.0, 0.45, 1.0);
uniform vec3 gold : source_color = vec3(0.95, 0.72, 0.3);
uniform float intensity = 2.3;
// The way it flies, in the world.
uniform vec3 axis = vec3(0.0, 0.0, 1.0);
// The quad: meters along the flight and across it; the point of the dart is nose_m ahead of the node.
uniform float length_m = 3.4;
uniform float width_m = 0.6;
uniform float nose_m = 0.9;
// The dart: its length and half its width.
uniform float dart_m = 2.0;
uniform float half_m = 0.15;
// The trail behind it: how long it is now (it grows as the dart leaves the blade).
uniform float trail_m = 1.5;
// 1: the held version (side darts and bow wave reaching reach_m to each side).
uniform float omega = 0.0;
uniform float reach_m = 4.0;

varying vec2 at;

void vertex() {
	vec3 center = MODEL_MATRIX[3].xyz;
	vec3 along = normalize(axis);
	vec3 side = normalize(cross(along, normalize(CAMERA_POSITION_WORLD - center)));
	// at.x: meters behind the point; at.y: meters to the side of the axis
	at = vec2((0.5 - VERTEX.x) * length_m, VERTEX.y * width_m);
	vec3 world = center + along * (nose_m - at.x) + side * at.y;
	VERTEX = (VIEW_MATRIX * vec4(world, 1.0)).xyz;
}

// A dart: its point at x = 0, its barbs a third of the way back, thinning to a tail. Returns body (x) and core (y).
vec2 dart(vec2 p, float len, float half_w) {
	float s = p.x / len;
	if (s < 0.0 || s > 1.0) return vec2(0.0);
	float w = half_w * (s < 0.3 ? pow(s / 0.3, 0.75) : mix(1.0, 0.25, (s - 0.3) / 0.7));
	float d = abs(p.y) / max(w, 0.0005);
	return vec2(1.0 - smoothstep(0.45, 1.0, d), 1.0 - smoothstep(0.0, 0.5, d)) * (1.0 - smoothstep(0.85, 1.0, s) * 0.6);
}

void fragment() {
	vec2 body = dart(at, dart_m, half_m);
	float s = at.x / dart_m;
	// pale at the point, the blade's colour behind it
	float tip = 1.0 - smoothstep(0.0, 0.45, s);
	vec3 c = mix(color.rgb, vec3(1.0), 0.42 * tip * body.y) * (body.x * 0.9 + body.y * 0.5);
	// the thread of old gold down the axis
	float vein = (1.0 - smoothstep(0.0, half_m * 0.22, abs(at.y))) * smoothstep(0.12, 0.3, s) * (1.0 - smoothstep(0.85, 1.0, s));
	c = mix(c, gold * 1.1, vein * 0.85);
	// the trail
	float back = (at.x - dart_m * 0.8) / max(trail_m, 0.01);
	if (back > 0.0 && back < 1.0) {
		float w = half_m * 0.5 * (1.0 - back);
		float line = 1.0 - smoothstep(0.2, 1.0, abs(at.y) / max(w, 0.0005));
		c += color.rgb * line * (1.0 - back) * (1.0 - back) * 0.55;
	}
	if (omega > 0.0) {
		// a thin dart on each side, set back
		float off = half_m + 0.2;
		vec2 left = dart(vec2(at.x - 0.6, abs(at.y) - off), dart_m * 0.7, 0.085);
		c += mix(color.rgb, vec3(1.0), 0.3 * left.y) * (left.x * 0.8 + left.y * 0.35);
		// the bow wave: two fine lines swept back from the point out to what it reaches
		float out_m = abs(at.y);
		float wave = 1.0 - smoothstep(0.0, 0.07, abs(at.x - 0.5 - out_m * 0.62));
		wave *= smoothstep(off, off + 0.5, out_m) * (1.0 - smoothstep(reach_m * 0.75, reach_m, out_m));
		c += color.rgb * wave * 0.4;
	}
	ALBEDO = c * intensity;
}
