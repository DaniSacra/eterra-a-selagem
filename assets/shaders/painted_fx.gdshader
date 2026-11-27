shader_type spatial;
// The hand-painted effect cards (docs/art/vfx_painted_style.md, Fx.painted_*): one flipbook sheet of warm greyscale on
// black (assets/textures/fx/painted/*.png), the frame STEPPED from `life` (never blended, the drawn look), tinted with
// the blow's colour. Body premultiplied over the scene, the core (the brightest part of the paint) added on top of it.
// Ground cards (cuts, smash, spin, hit ring) lie flat on the floor and are trimmed to the angle the blow covers; the
// contact spark is a billboard turned toward where the blade was going.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform sampler2D sheet : filter_linear, repeat_disable;
uniform vec2 grid = vec2(3.0, 2.0);
uniform float frames = 6.0;
uniform float life = 0.0;
uniform vec4 color : source_color = vec4(1.0, 0.82, 0.38, 1.0);
uniform vec4 core_color : source_color = vec4(0.96, 0.93, 0.86, 1.0);
uniform float body_peak = 1.0;
uniform float core_peak = 1.0;
uniform float core_amt = 1.0;
uniform float opacity = 1.0;
uniform float billboard = 0.0;
uniform float aim = 0.0;
uniform float flip = 0.0;
// arc trimming (mode 1: an arc with a head; mode 2: a fan around the sheet's "up"; 0: the whole card)
uniform float mode = 0.0;
uniform float head_deg = 190.0;
uniform float turn_deg = 0.0;
uniform float keep_deg = 240.0;

varying vec2 lp;

void vertex() {
	lp = VERTEX.xz;
	if (billboard > 0.5) {
		lp = UV * 2.0 - 1.0;
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
}

float paint_at(vec2 st) {
	// st: the sheet's own coordinates (x right, y up, -1..1); out of the cell is empty
	vec2 uv = vec2(st.x, -st.y) * 0.5 + 0.5;
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return 0.0;
	}
	float i = clamp(floor(life * frames), 0.0, frames - 1.0);
	vec2 cell = vec2(mod(i, grid.x), floor(i / grid.x));
	vec3 t = texture(sheet, (cell + clamp(uv, vec2(0.004), vec2(0.996))) / grid).rgb;
	return max(t.r, max(t.g, t.b));
}

void fragment() {
	vec2 st;
	float keep = 1.0;
	if (billboard > 0.5) {
		vec2 m = vec2(lp.x, -lp.y);
		st = vec2(m.x * cos(aim) + m.y * sin(aim), -m.x * sin(aim) + m.y * cos(aim));
	} else {
		// local +z is the way the blow faces; the sheet's head sits on local +x unless the sweep is flipped
		st = vec2(flip > 0.5 ? lp.x : -lp.x, lp.y);
		if (mode > 0.5) {
			float c = cos(turn_deg * 0.017453292);
			float s = sin(turn_deg * 0.017453292);
			st = vec2(st.x * c + st.y * s, -st.x * s + st.y * c);
			float ang = degrees(atan(st.y, st.x));
			if (mode < 1.5) {
				float t = mod(head_deg - ang + 720.0, 360.0);
				keep = 1.0 - smoothstep(keep_deg - 25.0, keep_deg, t);
			} else {
				float t = abs(mod(ang - 90.0 + 540.0, 360.0) - 180.0);
				keep = 1.0 - smoothstep(keep_deg * 0.5 - 12.0, keep_deg * 0.5, t);
			}
		}
	}
	float d = paint_at(st);
	float a = clamp(smoothstep(0.06, 0.55, d) * keep * opacity, 0.0, 1.0);
	float core = smoothstep(0.62, 0.95, d) * keep * opacity * core_amt;
	if (a < 0.01 && core < 0.01) {
		discard;
	}
	vec3 body = color.rgb / max(max(color.r, max(color.g, color.b)), 0.0001) * body_peak;
	vec3 hot = core_color.rgb / max(max(core_color.r, max(core_color.g, core_color.b)), 0.0001) * core_peak;
	ALBEDO = body * (0.62 + 0.38 * d) * a + hot * core;
	ALPHA = a;
}
