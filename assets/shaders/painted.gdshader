shader_type spatial;
// GP-8 (PaintedHall): the room's painting projected from the painter's camera onto simple
// geometry. The colour is the painting's own (no ambient, no lights); lights only do two small things: the moon's
// shadows (the hero's and the fighters') tint it cold, and the scene's omni lights (torches, fires) add a little warmth.
render_mode ambient_light_disabled, specular_disabled, fog_disabled, cull_disabled;

uniform sampler2D painting : source_color, filter_linear_mipmap, repeat_disable;
// world -> clip of the painter's camera (PaintedHall.projector)
uniform mat4 projector;
// the share of the file's height the painter's frame takes (1: stretched to the file; less: scaled evenly, cliff below)
uniform float v_span = 1.0;
uniform float exposure = 0.9;  // the dark-floor paintings (Daniel 2026-11-27) carry their own low value; was 0.52 on the bright ones
uniform float shadow_strength = 0.15;
uniform vec3 shade_tint = vec3(0.5, 0.6, 0.82);
uniform float torch_boost = 0.15;
// A little unsharp mask on the painting (it is shown 1.5 to 2.5 times larger than its pixels at the game's camera).
uniform float sharpen = 0.5;
// The pieces the paladin walks behind open round him, as the room's stone does (see_through.gdshaderinc).
uniform float see_through = 0.0;
uniform float see_radius = 2.2;
uniform float see_height = 1.3;
uniform float see_keep = 0.1;
uniform float see_gap = 0.4;

#include "res://assets/shaders/see_through.gdshaderinc"

// Where the painting is trusted (PT28-12). The painter's eye (PaintedHall.eye_of): a face the painter sees edge-on, or a
// steep face (wall, riser, pillar side) the game's camera sees from further round than the painter did, would show the
// painting stretched, so it takes the stone's own plain look (the painting's soft average with a block pattern) instead.
uniform vec3 plate_eye = vec3(0.0, 100.0, 100.0);
// the angle (radians) between the painter's ray and the game camera's ray to a point where a steep face starts, and ends, to be dressed
uniform vec2 trust_angle = vec2(0.18, 0.45);
// how much of the fallback stone's tone is the painting's local (blurred) colour, the rest being the room's average
uniform float fallback_local = 0.5;
// and how much of it outside the frame, where the painting's edge row stands in (0: the room's average only)
uniform float fallback_edge = 0.0;
// footprints of the painted 3D objects (a tree), floor only: (x, z, radius, reach away from the painter), and how much they
// show now (0: the painting as it is, 1: gone, the object being the game's 3D); mask_color is what the floor is there
uniform vec4 masks[4];
uniform int mask_count = 0;
uniform float mask_amount = 0.0;
uniform vec3 mask_color = vec3(0.1, 0.095, 0.08);

varying vec3 world_pos;
varying vec3 world_normal;


float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


// the stone's plain look: the painting's own average there, in blocks
vec3 stone_of(vec2 uv, vec3 w, vec3 n, float inside) {
	// the room's average tone, and the painting's soft local one only inside the frame (its edge is sky, not stone)
	vec3 local = textureLod(painting, clamp(uv, vec2(0.0), vec2(1.0, v_span)), 4.0).rgb;
	vec3 base = mix(textureLod(painting, vec2(0.5, 0.5 * v_span), 9.0).rgb, local, fallback_local * max(inside, fallback_edge)) * 0.8;
	vec2 g = abs(n.y) > 0.7 ? w.xz : (abs(n.x) > abs(n.z) ? vec2(w.z, w.y) : vec2(w.x, w.y));
	g /= vec2(1.1, 0.55);
	float row = floor(g.y);
	g.x += row * 0.5;
	vec2 cell = floor(g);
	vec2 f = fract(g);
	float joint = step(f.x, 0.04) + step(f.y, 0.07);
	return base * (0.85 + 0.3 * hash21(cell)) * (1.0 - 0.35 * min(joint, 1.0));
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec4 c = projector * vec4(world_pos, 1.0);
	vec2 uv = c.xy / c.w * vec2(0.5, -0.5) + 0.5;
	uv.y *= v_span;
	if (see_through > 0.0 && see_through_hole(VERTEX, FRAGCOORD.xy, VIEW_MATRIX, PROJECTION_MATRIX, see_through, see_radius, see_height, see_keep, see_gap)) {
		discard;
	}
	vec3 n = normalize(world_normal);
	vec3 to_plate = normalize(plate_eye - world_pos);
	float apart = acos(clamp(dot(to_plate, normalize(CAMERA_POSITION_WORLD - world_pos)), -1.0, 1.0));
	float steep = 1.0 - smoothstep(0.85, 0.985, abs(n.y));
	float seen = mix(1.0, smoothstep(0.25, 0.5, abs(dot(n, to_plate))), steep);
	float inside = smoothstep(0.0, 0.015, uv.x) * smoothstep(1.0, 0.985, uv.x) * smoothstep(0.0, 0.015, uv.y) * smoothstep(v_span, v_span - 0.015 * v_span, uv.y);
	float trust = seen * inside * (1.0 - steep * smoothstep(trust_angle.x, trust_angle.y, apart));
	vec3 own = texture(painting, uv).rgb;
	vec3 col = (own + (own - textureLod(painting, uv, 1.5).rgb) * sharpen) * exposure;
	vec3 stone = stone_of(uv, world_pos, n, inside) * exposure;
	float gone = 0.0;
	if (mask_amount > 0.0 && abs(n.y) > 0.7) {
		for (int i = 0; i < mask_count; i++) {
			vec2 a = masks[i].xy;
			vec2 away = normalize(a - plate_eye.xz);
			vec2 d = world_pos.xz - a;
			float t = clamp(dot(d, away), 0.0, masks[i].w);
			float dist = length(d - away * t);
			gone = max(gone, 1.0 - smoothstep(masks[i].z * 0.8, masks[i].z, dist));
		}
		gone *= mask_amount;
	}
	col = mix(stone, col, trust);
	col = mix(col, mask_color * exposure, gone);
	ALBEDO = col;
	EMISSION = col;
	ROUGHNESS = 1.0;
}

void light() {
	if (LIGHT_IS_DIRECTIONAL) {
		DIFFUSE_LIGHT += ALBEDO * (shade_tint - 1.0) * shadow_strength * (1.0 - ATTENUATION);
	} else {
		// LIGHT_COLOR carries the energy (x PI): clamp it, or a hero light or a brazier of energy 4 burns the painting white
		DIFFUSE_LIGHT += ALBEDO * min(LIGHT_COLOR / PI * ATTENUATION, vec3(1.0)) * torch_boost;
	}
}
