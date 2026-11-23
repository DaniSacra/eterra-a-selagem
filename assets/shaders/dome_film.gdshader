shader_type spatial;
// The Maga's Suspensao Absoluta: a pale ivory film over the dome with a gold hexagon net and a brighter amber rim where it
// bends away from the eye (vfx cheap: one unshaded pass, no textures, runs the same in Compatibility).
render_mode unshaded, blend_mix, cull_disabled, shadows_disabled, depth_draw_never;

uniform vec4 film : source_color = vec4(0.95, 0.88, 0.7, 0.08);
uniform vec4 net : source_color = vec4(0.95, 0.72, 0.3, 0.5);
uniform vec4 rim : source_color = vec4(1.0, 0.62, 0.18, 0.5);
uniform float cells = 9.0;

varying vec3 local;

void vertex() {
	local = normalize(VERTEX);
}

// Distance to the nearest hexagon edge in a unit-ish grid: 0 on the edge, up to ~0.5 at the centre.
float hex_edge(vec2 p) {
	const vec2 s = vec2(1.0, 1.7320508);
	vec4 hc = floor(vec4(p, p - vec2(1.0, 0.5)) / s.xyxy) + 0.5;
	vec4 h = vec4(p - hc.xy * s, p - (hc.zw + 0.5) * s);
	vec2 q = dot(h.xy, h.xy) < dot(h.zw, h.zw) ? h.xy : h.zw;
	q = abs(q);
	return 0.5 - max(dot(q, s * 0.5), q.x);
}

void fragment() {
	vec2 uv = vec2(atan(local.x, local.z) / 6.2831853 * cells * 2.0, local.y * cells);
	float edge = 1.0 - smoothstep(0.0, 0.07, hex_edge(uv));
	float fres = pow(1.0 - clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0), 2.5);
	vec4 c = film;
	c = mix(c, net, edge * net.a);
	c = mix(c, rim, fres * rim.a);
	ALBEDO = c.rgb;
	ALPHA = clamp(film.a + edge * net.a * 0.5 + fres * rim.a * 0.6, 0.0, 0.85);
}
