// The tiles of the Câmara das Runas Instáveis (E5 spec 3.4; rune_floor.gdshader = the catacomb floor's body with
// RUNES defined): one slab of `unit` (3 m) per tile on a grid from rune_origin, each with a frame of old gold sunk in
// a groove (0.12 m wide) and three worn straight marks inside, the gold in the albedo only. Each tile's state comes from
// rune_state (one texel a tile, RunesLook writes it): r = arming (0 to 1), g = firing (1 at the strike, falling), b =
// the ember left after it (falling), a = what the tile is (1 a rune tile, 0.5 the quiet stone of variant B: smooth
// basalt without a frame, 0 none). Arming, the frame warms from old gold to amber (its brightest channel up to 1.0 at
// the end, under the glow's threshold), the marks light one by one, a faint amber fill (0.08) that rises to 0.3 in the
// last 30% (the enemies' warnings' rhythm), chevrons running toward the next band (chevron_dir; zero: none) and short
// violet sparks running along the cracks (the instability). Firing: the whole tile flashes ivory-amber (the sheet of
// light rising off it is rune_flash.gdshader). The ember: the frame's corners keep a little amber that fades. Nothing
// round anywhere (D-29): frames, marks, chevrons and sparks are straight strokes.

uniform sampler2D rune_state : filter_nearest, repeat_disable;
uniform ivec2 rune_grid = ivec2(10, 8);
uniform vec2 rune_origin = vec2(-15.0, -12.0);
uniform vec3 rune_amber : source_color = vec3(1.0, 0.62, 0.25);
uniform vec3 rune_white : source_color = vec3(1.0, 0.88, 0.70);
uniform vec3 rune_spark : source_color = vec3(0.55, 0.3, 1.0);
uniform vec3 quiet_color : source_color = vec3(0.12, 0.125, 0.15);
// The frame: how far in from the tile's edge its groove starts, its width, how much it darkens, how much gold shows in
// it, how hard its walls lean (the relief).
uniform float frame_inset = 0.16;
uniform float frame_width = 0.12;
uniform float frame_dark = 0.5;
uniform float frame_gold = 0.7;
uniform float frame_tilt = 1.2;
// The marks inside (three a tile): half their stroke, their contrast at rest (spec: up to 15%), their glow when lit.
uniform float mark_stroke = 0.035;
uniform float mark_contrast = 0.15;
uniform float mark_glow = 0.85;
// The fill: at rest of the arming, from fill_late on, and how much light it gives.
uniform float fill_low = 0.08;
uniform float fill_high = 0.3;
uniform float fill_late = 0.7;
uniform float fill_glow = 0.45;
// Chevrons toward the next band: the way (zero: none), their spacing, width, speed, how sharp, their light.
uniform vec2 chevron_dir = vec2(0.0);
uniform float chevron_step = 0.9;
uniform float chevron_width = 0.09;
uniform float chevron_speed = 0.9;
uniform float chevron_bend = 0.7;
uniform float chevron_glow = 0.55;
// Sparks along the cracks while arming: how many dashes, how short, how fast, their light (spec: up to 1.1).
uniform float spark_count = 1.3;
uniform float spark_short = 0.94;
uniform float spark_speed = 3.0;
uniform float spark_glow = 1.1;
// The flash of the strike on the tile and the ember in the corners (reach in m, light).
uniform float flash_glow = 0.15;
uniform float flash_tint = 0.12;
uniform float ember_reach = 0.7;
uniform float ember_glow = 0.75;
// Nothing on the floor past this channel of light (the glow's threshold is 1.3 after the exposure).
uniform float rune_cap = 1.0;

// The tile under wp: its min corner and size in units (one unit a tile), its id the tile's column and row.
void rune_slab(vec2 wp, out vec4 rect, out vec2 id) {
	vec2 p = (wp - rune_origin) / unit;
	vec2 cell = floor(p);
	rect = vec4(cell + rune_origin / unit, 1.0, 1.0);
	id = cell;
}

vec4 rune_state_at(vec2 cell) {
	ivec2 t = ivec2(cell);
	if (t.x < 0 || t.y < 0 || t.x >= rune_grid.x || t.y >= rune_grid.y) {
		return vec4(0.0);
	}
	return texelFetch(rune_state, t, 0);
}

// Distance from lp (from the tile's middle) to mark k of the tile: a straight stroke at 0, 45, 90 or 135 degrees.
float rune_mark(vec2 lp, vec2 cell, float k) {
	vec2 h = vec2(hash1(cell + k * 7.1), hash1(cell + k * 3.7 + 1.3));
	vec2 c = (h - 0.5) * unit * 0.42;
	float turn = floor(hash1(cell + k * 5.3) * 4.0) * 0.7853982;
	vec2 d = vec2(cos(turn), sin(turn)) * mix(0.3, 0.65, hash1(cell + k * 9.1));
	return seg(lp, c - d, c + d);
}

void rune_floor(vec2 wp, vec4 rect, float edge, float joint, inout vec3 c, inout vec3 emit, inout vec2 lean, inout float rough) {
	vec2 cell = floor((wp - rune_origin) / unit);
	vec4 st = rune_state_at(cell);
	if (st.a < 0.25) {
		return;
	}
	vec2 half_size = rect.zw * unit * 0.5;
	vec2 lp = wp - (rect.xy + rect.zw * 0.5) * unit;
	float d_in = min(half_size.x - abs(lp.x), half_size.y - abs(lp.y));
	if (st.a < 0.75) {
		// the quiet stone: smooth dark basalt, no frame, no mark, never lit
		c = mix(c, quiet_color * (0.85 + 0.3 * noise(wp * 0.8)), 0.85 * (1.0 - joint));
		rough = 0.55;
		return;
	}
	float arm = st.r;
	float fire = st.g;
	float ember = st.b;
	// the frame's groove
	float g0 = frame_inset;
	float g1 = frame_inset + frame_width;
	float groove = smoothstep(g0 - 0.012, g0 + 0.008, d_in) * (1.0 - smoothstep(g1 - 0.008, g1 + 0.012, d_in));
	vec2 out_dir = abs(lp.x) - half_size.x > abs(lp.y) - half_size.y ? vec2(sign(lp.x), 0.0) : vec2(0.0, sign(lp.y));
	float wall_out = smoothstep(g0 - 0.02, g0, d_in) * (1.0 - smoothstep(g0, g0 + 0.025, d_in));
	float wall_in = smoothstep(g1 - 0.025, g1, d_in) * (1.0 - smoothstep(g1, g1 + 0.02, d_in));
	lean += out_dir * (wall_in - wall_out) * frame_tilt;
	vec3 gold = mix(gold_dark, gold_light, noise(wp * 6.0));
	float worn = 0.7 + 0.3 * noise(wp * 5.0 + cell);
	c = mix(c, joint_color * 0.8, groove * frame_dark);
	c = mix(c, gold, groove * frame_gold * worn);
	// the marks, lit one by one while arming
	float lit = 0.0;
	for (int k = 0; k < 3; k++) {
		float fk = float(k);
		float mk = 1.0 - smoothstep(mark_stroke, mark_stroke * 1.6, rune_mark(lp, cell, fk));
		mk *= mix(0.4, 1.0, step(0.35, noise(wp * 4.0 + fk * 3.0)));
		c = mix(c, gold, mk * mark_contrast);
		lit = max(lit, mk * step((fk + 1.0) / 4.0, arm));
	}
	// the frame warms from old gold to amber (spec 3.4), and keeps an ember in its corners after the strike
	float heat = max(arm, ember * 0.5);
	vec3 hot = mix(gold_light, rune_amber, smoothstep(0.0, 1.0, heat));
	emit += hot * groove * heat;
	emit += rune_amber * lit * mark_glow * step(0.001, arm);
	float inner = smoothstep(g1, g1 + 0.06, d_in);
	float fill = arm <= 0.0 ? 0.0 : (arm < fill_late ? fill_low : mix(fill_low, fill_high, (arm - fill_late) / (1.0 - fill_late)));
	c = mix(c, rune_amber * 0.45, fill * inner);
	emit += rune_amber * fill * fill_glow * inner;
	if (arm > 0.0 && dot(chevron_dir, chevron_dir) > 0.01) {
		vec2 dir = normalize(chevron_dir);
		float along = dot(lp, dir);
		float across = abs(dot(lp, vec2(-dir.y, dir.x)));
		float f = fract((along - across * chevron_bend) / chevron_step - TIME * chevron_speed);
		float ch = 1.0 - smoothstep(chevron_width * 0.6, chevron_width, abs(f - 0.5) * chevron_step);
		emit += rune_amber * ch * inner * smoothstep(g1 + 0.1, g1 + 0.4, d_in) * arm * chevron_glow;
	}
	if (arm > 0.0) {
		float cn = fbm(wp * 1.3 + cell * 5.0);
		float crack_line = 1.0 - smoothstep(0.0, 0.016, abs(cn - 0.5));
		float dash = step(spark_short, fract(dot(wp, vec2(1.7, 1.1)) * spark_count - TIME * spark_speed + hash1(cell) * 7.0));
		emit += rune_spark * crack_line * dash * spark_glow * inner * (1.0 - fire);
	}
	// the strike: the whole tile flashes; then the ember in the corners
	c = mix(c, rune_white * 0.6, fire * flash_tint * inner);
	emit += rune_white * fire * flash_glow * inner;
	float corner = 1.0 - smoothstep(0.0, ember_reach, length(half_size - abs(lp)) - frame_inset);
	emit += rune_amber * ember * corner * ember_glow * max(groove, 0.4);
	float peak = max(emit.r, max(emit.g, emit.b));
	if (peak > rune_cap) {
		emit *= rune_cap / peak;
	}
}
