shader_type spatial;
// Morvath's Sepulchral Scythe (Fx.boss_scythe): the blade sweeping across exactly the half circle it hurts, flat on
// the floor. The head is a line of blue-green across the whole radius (the blade); behind it a short trail of deep
// violet smoke, stronger toward the reach; the reach itself is a blue-green edge along the part swept. After the
// sweep everything breaks into ashes and fades. Drawn on Fx's ring-sector mesh: UV.x along the swing (0 start,
// 1 end), UV.y from the inner edge (near his feet) to the outer one (the reach of the blow): it never leaves it.
// t goes 0 -> 1 over its life; the head crosses during the first `sweep` of it.
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 body : source_color = vec4(0.62, 0.22, 1.2, 1.0);
uniform vec4 edge : source_color = vec4(0.38, 1.55, 1.1, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.3;
// Share of the arc the trail covers behind the head.
uniform float tail = 0.35;
uniform bool flip = false;
uniform float intensity = 1.0;
// How bright the blade line and the rim are (above 1 they glow) and how strong the violet body is (kept under it).
uniform float blade_light = 1.0;
uniform float rim_light = 0.6;
uniform float body_light = 0.75;

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
	float head = clamp(t / sweep, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	float behind = head - along;
	if (behind < 0.0) discard;
	float rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
	float y = UV.y;
	// the ashes: pieces of what was swept go out one by one after the sweep
	float grain = noise(vec2(UV.x * 30.0, y * 8.0 - t * 2.0));
	if (grain < rest * 1.05) discard;
	float trail = 1.0 - smoothstep(0.0, tail, behind);
	// the blade: a thin line across the radius at the head, only while it moves
	float blade = (1.0 - smoothstep(0.0, 0.03, behind)) * (1.0 - rest);
	// the rim: the reach of the blow, along what was swept
	float rim = (1.0 - smoothstep(0.0, 0.06, 1.0 - y)) * (0.35 + 0.65 * trail);
	// the body: violet smoke carried by the trail, stronger toward the reach, crawling against the swing
	float smoke = 0.55 + 0.6 * noise(vec2(UV.x * 14.0 + t * 5.0, y * 4.0));
	float fill = mix(0.12, 0.8, y * y) * trail * smoke;
	vec3 soft = body.rgb / max(max(body.r, max(body.g, body.b)), 1.0);
	vec3 c = soft * fill * body_light + edge.rgb * (rim * rim_light + blade * blade_light);
	ALBEDO = c * (1.0 - rest) * intensity;
}
