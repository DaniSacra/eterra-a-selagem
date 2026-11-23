// The body of the enemies' wind-up lights (enemy_tell.gdshader, enemy_tell_over.gdshader): see enemy_tell.gdshader.
// Shapes 4 (BAR, a hard stroke) and 5 (INK, the same stroke in dark ink, which only the over pass draws: PREMUL).

varying vec4 tint;
varying vec4 look;

void vertex() {
	tint = COLOR;
	look = INSTANCE_CUSTOM;
	if (look.y > 0.5) {
		vec2 size = vec2(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz));
		float c = cos(look.w);
		float s = sin(look.w);
		vec2 v = VERTEX.xy * size;
		v = vec2(v.x * c - v.y * s, v.x * s + v.y * c);
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		VERTEX = vec3(v, 0.0);
	}
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float a;
	if (look.x < 0.5) {
		a = clamp(1.0 - r, 0.0, 1.0);
		a *= a;
	} else if (look.x < 1.5) {
		a = clamp(1.0 - abs(r - (1.0 - look.z)) / max(look.z, 0.001), 0.0, 1.0);
	} else if (look.x < 2.5) {
		float across = clamp(1.0 - abs(p.y), 0.0, 1.0);
		a = across * across * clamp((1.0 - abs(p.x)) * 2.5, 0.0, 1.0);
	} else if (look.x < 3.5) {
		a = step(abs(p.x) + abs(p.y), 1.0);
	} else if (look.x > 5.5) {
		// 6 ARC (N2, the Quebra): a ring cut to a part of the turn, its two ends cut square; look.z is the thickness
		float th = max(look.z, 0.001);
		float ang = abs(atan(p.y, p.x));
		a = clamp(1.0 - abs(r - (1.0 - th)) / th, 0.0, 1.0) * step(ang, 0.42);
	} else {
		// 4 BAR, 5 INK (LC-1b): a stroke with hard edges, one pixel of smoothing
		vec2 w = max(fwidth(p), vec2(1e-4));
		vec2 e = clamp((1.0 - abs(p)) / w, 0.0, 1.0);
		a = e.x * e.y;
	}
#ifdef PREMUL
	// premultiplied: the lights add (as blend_add), the ink darkens what is behind
	bool ink = look.x > 4.5 && look.x < 5.5;
	ALBEDO = ink ? vec3(0.0) : tint.rgb * a * tint.a;
	ALPHA = ink ? a * tint.a : 0.0;
#else
	ALBEDO = tint.rgb;
	ALPHA = (look.x > 4.5 && look.x < 5.5) ? 0.0 : a * tint.a;
#endif
}
