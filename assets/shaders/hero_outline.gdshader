shader_type spatial;
// The Guerreiro's contour in the stylized look (STY-06, T20; docs/art/stylized_spec.md 2.3): the next pass of
// hero_paint.gdshader, his skinned body pushed out along its normals by width meters of the world and drawn from
// behind, a thin cold dark ink (0.045 m, a hair wider than the crowd's 0.04, petrol-black, never pure black). Only in
// the stylized look (HeroBody puts it there).
render_mode unshaded, cull_front, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.05, 0.07, 0.08);
uniform float width = 0.045;

void vertex() {
	VERTEX += NORMAL * width / max(length(MODEL_MATRIX[0].xyz), 0.001);
}

void fragment() {
	ALBEDO = color;
}
