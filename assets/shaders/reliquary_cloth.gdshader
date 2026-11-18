shader_type spatial;
// The cloth over a reward's reliquary (RewardGem, AP-1 ART-01.3; Q-22: dark petrol, the lion in old gold): it lies on
// the cap and hangs down the front to a point. Soft folds along it, a thread of old gold near its sides and its foot,
// worn at the edges; on the hanging part the standing lion of Eterra (the seal's field, assets/textures/seal/lion_sdf.res)
// in old gold with a dark edge, embroidery and not a lamp: matte, no light of its own beyond the cloth's faint glow.
// UV: u across the cloth, v from its back on the cap (0) to the point (1). One material for every reliquary.
render_mode cull_disabled;

uniform vec3 cloth : source_color = vec3(0.07, 0.17, 0.19);
uniform vec3 gold : source_color = vec3(0.66, 0.5, 0.26);
uniform sampler2D lion : filter_linear_mipmap, repeat_disable;
// Where the lion stands along v (from, to: the hanging part) and its size as a share of the cloth's width.
uniform vec2 lion_v = vec2(0.53, 1.0);
uniform float lion_size = 0.62;
// The lion's field: pixels from the edge to the full swing, the texture's size, the dark edge's width.
uniform float spread = 24.0;
uniform float px = 512.0;
uniform float edge_px = 5.0;
uniform vec3 edge_color : source_color = vec3(0.03, 0.03, 0.035);
// Folds: how many across, how deep their shade; the gold thread: how far in from the sides and the foot, its width.
uniform float folds = 3.0;
uniform float fold_shade = 0.35;
uniform float thread_in = 0.07;
uniform float thread_w = 0.022;
// The faint glow of the cloth (never black in cold light, as the banners).
uniform float glow = 0.12;

void fragment() {
	float u = UV.x;
	float v = UV.y;
	// folds along the cloth, deeper toward its foot
	float f = 0.5 + 0.5 * cos(u * 6.2831853 * folds);
	float shade = mix(1.0 - fold_shade * smoothstep(lion_v.x - 0.1, 1.0, v), 1.0, f);
	vec3 col = cloth * shade;
	// worn: darker and a little frayed toward the edges
	float edge_d = min(min(u, 1.0 - u), 1.0 - v);
	col *= mix(0.7, 1.0, smoothstep(0.0, 0.05, edge_d));
	// the gold thread along the sides and, on the hanging part, along the foot's point
	float side = min(u, 1.0 - u);
	float foot = 1.0 - v;
	float t = 1.0 - smoothstep(thread_w * 0.5, thread_w, abs(side - thread_in));
	t = max(t, (1.0 - smoothstep(thread_w * 0.5, thread_w, abs(foot - thread_in * 0.7))) * step(lion_v.x, v));
	float metal = t;
	col = mix(col, gold * mix(0.8, 1.0, f), t);
	// the lion on the hanging part, upright, in the middle
	float span = lion_v.y - lion_v.x;
	vec2 luv = vec2((u - 0.5) / lion_size + 0.5, (v - lion_v.x) / span);
	// keep it square on the cloth: its height on v is the hanging part, its width on u lion_size
	if (luv.x > 0.0 && luv.x < 1.0 && luv.y > 0.04 && luv.y < 0.86) {
		vec2 tuv = vec2(luv.x, (luv.y - 0.04) / 0.82);
		vec2 fv = texture(lion, tuv).rg;
		float body = (fv.r - 0.5) * spread * 2.0;
		float cut = (fv.g - 0.5) * spread * 2.0;
		float in_body = smoothstep(-0.6, 0.6, body);
		float in_cut = smoothstep(-1.2, 0.3, cut);
		float rim = smoothstep(-edge_px, -edge_px + 1.0, body) * (1.0 - in_body);
		vec3 lion_col = mix(gold * mix(0.85, 1.05, f), edge_color, in_cut);
		col = mix(col, edge_color, rim * 0.8);
		col = mix(col, lion_col, in_body);
		metal = max(metal, in_body * (1.0 - in_cut));
	}
	ALBEDO = col;
	ROUGHNESS = mix(0.95, 0.45, metal);
	METALLIC = metal * 0.6;
	EMISSION = col * glow;
}
