shader_type spatial;
// A page of the Livro de Ahk open on its lectern in the hub (HUB-B2, docs/design/hub_spec_art.md 3.5): parchment with
// lines of ink and a rubric initial, nothing legible (the colours of Book: INK, RUBRIC, GILT), a gilt edge. UV 0..1
// over the page, u across it (0 at the spine when `spine_left`), v down it. Lit as paper, never glowing.
render_mode diffuse_burley, specular_disabled, cull_disabled;

uniform vec3 paper : source_color = vec3(0.62, 0.55, 0.42);
uniform vec3 ink : source_color = vec3(0.16, 0.12, 0.09);
uniform vec3 rubric : source_color = vec3(0.45, 0.13, 0.09);
uniform vec3 gilt : source_color = vec3(0.5, 0.38, 0.17);
// Lines of writing down the page, the margin, how much of a line is ink, the dark at the spine.
uniform float lines = 13.0;
uniform float margin = 0.12;
uniform float ink_share = 0.55;
uniform float spine_dark = 0.35;
uniform bool spine_left = true;

float h21(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float from_spine = spine_left ? uv.x : 1.0 - uv.x;
	vec3 c = paper * (0.92 + 0.08 * h21(floor(uv * 40.0)));
	// the gilt edge round the page and the shade toward the spine
	float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	c = mix(gilt, c, smoothstep(0.012, 0.025, edge));
	c *= mix(1.0 - spine_dark, 1.0, smoothstep(0.0, 0.18, from_spine));
	// writing: broken strokes on each line inside the margin, a rubric block at the top of the outer column
	vec2 inside = (uv - margin) / (1.0 - 2.0 * margin);
	if (all(greaterThan(inside, vec2(0.0))) && all(lessThan(inside, vec2(1.0)))) {
		float row = inside.y * lines;
		float in_row = fract(row);
		float word = floor(inside.x * 9.0 + h21(vec2(floor(row), 3.0)) * 4.0);
		float has = step(h21(vec2(word, floor(row))), ink_share + 0.3);
		float stroke = (1.0 - smoothstep(0.12, 0.2, abs(in_row - 0.5))) * has;
		c = mix(c, ink, stroke * 0.7);
		if (inside.y < 2.0 / lines && inside.x < 0.18) {
			c = mix(c, rubric, 0.85);
		}
	}
	ALBEDO = c;
	ROUGHNESS = 0.95;
}
