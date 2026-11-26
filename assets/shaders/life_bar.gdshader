shader_type spatial;
// A thin life bar over an enemy's head, as in Hades II: drawn by MultiMesh, always facing the camera, on top of
// everything. INSTANCE_CUSTOM: r = life left (0..1), g = armor left (0..1), b = opacity (1; less when the floor is
// crowded, CrowdRenderer.BAR_CROWD_FADE) plus 2 for an elite (its frame in old gold), a = where the pale trail of a
// recent loss ends (>= r; CrowdRenderer.BarTrails).
// b also carries +4 for an elite or a guardian's armored bar: three ink ticks of 1 px at 25, 50 and 75% of the yellow strip
// (combate_c1_leitura 7: the armor cracks there, EnemyFx.WEAR_STEPS).
// Cycle 8: armor no longer covers the top of the life. An armored bar is taller (CrowdRenderer.BAR_ARMOR_HEIGHT):
// the armor's own strip on top, a line of ink, the life under it; both read whole.
render_mode unshaded, cull_disabled, depth_test_disabled, shadows_disabled;

uniform vec3 life_color : source_color = vec3(0.86, 0.2, 0.18);  // UiKit.RED, the HUD's life red
uniform vec3 armor_color : source_color = vec3(1.0, 0.82, 0.25);
uniform vec3 back_color : source_color = vec3(0.047, 0.039, 0.055);  // UiKit.INK
uniform vec3 trail_color : source_color = vec3(1.0, 0.9, 0.78);
// PT-0 (2026-11-23): the Quebra's gauge in its own light blue (the life is red, the armor gold, the trail white)
uniform vec3 poise_color : source_color = vec3(0.45, 0.78, 1.0);
uniform vec3 elite_frame : source_color = vec3(0.56, 0.45, 0.27);
// UI-S1: the status pips over a bar, the same colours as the glossary (Glossary.COLORS)
uniform vec3 pip_burn : source_color = vec3(1.0, 0.66, 0.36);
uniform vec3 pip_frost : source_color = vec3(0.62, 0.86, 0.96);
uniform vec3 pip_weak : source_color = vec3(0.85, 0.73, 0.63);
uniform vec3 pip_mark : source_color = vec3(0.81, 0.78, 0.43);
// Meters of the frame on each side (as thick on the ends as on the long sides, and on a tall armored bar).
uniform float frame_m = 0.04;
// The armored bar's split: the armor's strip takes this share of the inside (from the top).
uniform float armor_share = 0.42;
// ART-02.6: a common enemy's bar (not an elite nor armored) is quieter than the hero's own: its life 15% darker and
// the bar thinner, its top kept where it was (the share of the quad's height cut from the top). Elites keep their
// frame and their full bar.
uniform float common_dim = 1.0;
uniform float common_cut = 0.1;

varying vec3 fill;
varying float fade;
varying float elite;
varying float ticks;
varying float poise_gauge;
varying float pip;
varying vec2 size_m;

void vertex() {
	fill = vec3(INSTANCE_CUSTOM.r, INSTANCE_CUSTOM.g, INSTANCE_CUSTOM.a);
	// +8: the poise gauge under a common's bar (C1b): pale, r = poise left
	// +16: a status pip (UI-S1): a small lozenge, r = which status (0 burn, 1 frost, 2 weak, 3 mark)
	pip = INSTANCE_CUSTOM.b > 15.5 ? 1.0 : 0.0;
	float bb = INSTANCE_CUSTOM.b - 16.0 * pip;
	poise_gauge = bb > 7.5 ? 1.0 : 0.0;
	float b = bb - 8.0 * poise_gauge;
	ticks = b > 3.5 ? 1.0 : 0.0;
	float rest = b - 4.0 * ticks;
	elite = rest > 1.5 ? 1.0 : 0.0;
	fade = rest - 2.0 * elite;
	// billboard: keep the instance's size and place, turn the quad to the camera
	vec3 scale = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), 1.0);
	size_m = scale.xy;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(scale.x, 0, 0, 0), vec4(0, scale.y, 0, 0), vec4(0, 0, 1, 0), vec4(0, 0, 0, 1));
}

void fragment() {
	vec2 uv = UV;
	if (pip > 0.5) {
		vec2 q = abs(uv - 0.5) * 2.0;
		if (q.x + q.y > 1.0) {
			discard;
		}
		int k = int(fill.r + 0.5);
		vec3 pc = k == 0 ? pip_burn : (k == 1 ? pip_frost : (k == 2 ? pip_weak : pip_mark));
		ALBEDO = (q.x + q.y > 0.7) ? back_color : pc;
		ALPHA = fade;
		return;
	}
	bool armored = fill.g > 0.0;
	bool common = elite < 0.5 && !armored && poise_gauge < 0.5;
	float tall = size_m.y;
	if (common) {
		// thinner: the bottom of the quad is cut away, so the top (where the damage numbers start) does not move
		if (uv.y > 1.0 - common_cut) {
			discard;
		}
		uv.y /= 1.0 - common_cut;
		tall *= 1.0 - common_cut;
	}
	float fy = frame_m / max(tall, 0.001);
	float fx = frame_m / max(size_m.x, 0.001);
	vec3 c = mix(back_color, elite_frame, elite);
	float well = 1.0;
	bool inside = uv.x > fx && uv.x < 1.0 - fx && uv.y > fy && uv.y < 1.0 - fy;
	if (inside) {
		float x = (uv.x - fx) / (1.0 - 2.0 * fx);
		float y = (uv.y - fy) / (1.0 - 2.0 * fy);
		c = back_color * 1.6;
		well = 0.7;
		if (poise_gauge > 0.5) {
			if (x < fill.r) {
				c = poise_color;
				well = 1.0;
			}
		} else if (armored && y < armor_share) {
			// the armor's own strip; a line of ink under it
			if (y > armor_share - 0.12) {
				c = back_color;
				well = 1.0;
			} else if (x < fill.g) {
				c = armor_color;
				well = 1.0;
			}
			if (ticks > 0.5 && y <= armor_share - 0.12) {
				float px = max(fwidth(x), 0.0001);
				for (int i = 1; i <= 3; i++) {
					if (abs(x - 0.25 * float(i)) < px * 0.5) {
						c = back_color;
					}
				}
			}
		} else {
			if (x < fill.r) {
				c = life_color * (common ? common_dim : 1.0);
				well = 1.0;
			} else if (x < fill.b) {
				c = trail_color;
				well = 1.0;
			}
		}
	}
	ALBEDO = c;
	ALPHA = 0.95 * fade * well;
}
