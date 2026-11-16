shader_type spatial;
// Small spectral motes for Morvath's fight (cycle 9), one MultiMesh each, moved here and not on the CPU. Every mote is a
// soft dot facing the camera; its instance custom data (x, y, z, w: four numbers 0..1 picked once) makes it its own.
// mode 0, orbit: around the ritual's shield (the node's middle), a ring of radius `radius` at heights within `span`.
// mode 1, drift: rising slowly through the box `box_size` around the node, fading near the paladin (hero_pos).
// mode 2, gather: from around `from` to `to` (node space) along an arc, staggered over `travel` (0..1): the sealing.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, skip_vertex_transform;

global uniform vec3 hero_pos;

uniform int mode = 0;
uniform vec3 color : source_color = vec3(0.32, 0.95, 0.62);
// The dots' size (m) and light; power multiplies both the light and the count shown (the shield grows in).
uniform float size = 0.12;
uniform float light = 1.0;
uniform float power = 1.0;
// orbit: radius (m), the heights (m, from-to), turns a second.
uniform float radius = 3.0;
uniform vec2 span = vec2(-0.5, 1.5);
uniform float turns = 0.12;
// drift: the box (m) and how fast they rise (m a second); none within hero_clear (m, on the floor) of the paladin.
uniform vec3 box_size = vec3(10.0, 6.0, 10.0);
uniform float rise = 0.35;
uniform vec2 hero_clear = vec2(4.0, 7.0);
// gather: where from (and how far around it), where to, how far along (0..1), how high the arc.
uniform vec3 from = vec3(0.0);
uniform float from_spread = 3.0;
uniform vec3 to = vec3(0.0, 3.0, -10.0);
uniform float travel = 0.0;
uniform float arc = 3.0;

varying float shade;

void vertex() {
	vec4 k = INSTANCE_CUSTOM;
	vec3 c = vec3(0.0);
	float a = 1.0;
	if (mode == 0) {
		float ang = (k.x + TIME * turns * (0.7 + 0.6 * k.z)) * 6.2831853;
		float r = radius * (0.92 + 0.16 * k.w);
		float h = mix(span.x, span.y, k.y) + 0.15 * sin(TIME * 0.9 + k.w * 6.28);
		c = vec3(cos(ang) * r, h, sin(ang) * r);
		a = step(k.w, power);
	} else if (mode == 1) {
		float life = fract(k.w + TIME * rise / box_size.y * (0.7 + 0.6 * k.z));
		c = (vec3(k.x, life, k.y) - vec3(0.5, 0.0, 0.5)) * box_size + vec3(sin(TIME * 0.4 + k.z * 6.28), 0.0, cos(TIME * 0.3 + k.x * 6.28)) * 0.4;
		a = smoothstep(0.0, 0.2, life) * (1.0 - smoothstep(0.7, 1.0, life)) * power;
		vec3 w = (MODEL_MATRIX * vec4(c, 1.0)).xyz;
		a *= smoothstep(hero_clear.x, hero_clear.y, distance(w.xz, hero_pos.xz));
	} else {
		float t = clamp((travel - k.w * 0.45) / 0.55, 0.0, 1.0);
		float e = t * t * (3.0 - 2.0 * t);
		vec3 start = from + vec3(k.x - 0.5, 0.2 + k.z * 0.6, k.y - 0.5) * from_spread * 2.0;
		c = mix(start, to, e) + vec3(0.0, sin(e * 3.14159) * arc * (0.6 + 0.4 * k.z), 0.0);
		a = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.85, 1.0, t)) * power;
	}
	shade = a;
	vec3 v = (MODELVIEW_MATRIX * vec4(c, 1.0)).xyz;
	VERTEX = v + vec3(VERTEX.xy * size * (0.7 + 0.6 * k.z), 0.0) * step(0.001, a);
	NORMAL = vec3(0.0, 0.0, 1.0);
}

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	float dot_ = 1.0 - smoothstep(0.1, 1.0, d);
	ALBEDO = color * dot_ * dot_ * light * shade;
}
