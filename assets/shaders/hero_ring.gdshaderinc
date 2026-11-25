// The ring at the paladin's feet (hero_ring.gdshader on the open floor, hero_ring_through.gdshader through the
// crowd). THROUGH: the pass seen through enemies standing over it.

uniform vec4 color : source_color = vec4(0.24, 0.56, 0.58, 1.0);
// Opacity on the open floor and through what covers it.
uniform float open = 0.35;
uniform float through = 0.75;
// The band, as a share of the quad's half side.
uniform float band = 0.09;
// E1-7: the ring is always the petrol; a state (the Brado's ward) lights a fine thread of `inner_color` just inside it
// (`inner` its share 0..1) instead of changing the ring's colour.
uniform vec4 inner_color : source_color = vec4(0.3, 0.78, 0.45, 1.0);
uniform float inner = 0.0;
// Where he faces on the floor (x, z; the quad does not turn with him), the cosine of half the wedge and how many
// times brighter the wedge is than the rest of the ring.
uniform vec2 facing = vec2(0.0, 1.0);
uniform float wedge_cos = 0.966;
uniform float wedge_gain = 1.4;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
// Meters in front of the ring: less than `near` is the floor itself, more than `hidden_by` covers it (in between,
// feet standing on it hide it as they would).
uniform float near = 0.08;
uniform float hidden_by = 0.6;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float d = length(p);
	float ring = smoothstep(1.0 - band, 1.0 - band * 0.6, d) * (1.0 - smoothstep(1.0 - band * 0.4, 1.0, d));
	float thread = (1.0 - smoothstep(band * 0.3, band * 0.6, abs(d - (1.0 - band * 2.4)))) * inner;
	if (ring < 0.01 && thread < 0.01) {
		discard;
	}
	float depth = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 scene = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float ahead = -VERTEX.z + scene.z / scene.w;
#ifdef THROUGH
	// only through what stands well over it (and the stencil says it is the crowd)
	if (ahead < hidden_by) {
		discard;
	}
#else
	// only on the open floor: feet on it hide it, and so does stone (it never shows on top of an obelisk)
	if (ahead > near) {
		discard;
	}
#endif
	float toward = dot(p / max(d, 0.001), normalize(facing));
	float gain = mix(1.0, wedge_gain, smoothstep(wedge_cos - 0.012, wedge_cos + 0.012, toward));
	// brighter by more of the ring over the floor; by colour only for what opacity cannot give
#ifdef THROUGH
	float want = max(ring, thread) * through * gain;
#else
	float want = max(ring, thread) * open * gain;
#endif
	ALPHA = min(want, 1.0);
	ALBEDO = mix(color.rgb, inner_color.rgb, thread / max(ring + thread, 0.001)) * (want / max(ALPHA, 0.001));
}
