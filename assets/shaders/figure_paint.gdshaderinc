// Eterra Stylized (STY-06, docs/art/stylized_spec.md 2.3): the painted look of the figures, shared by the crowd
// (crowd.gdshader) and the hero (hero_paint.gdshader). Used only where the global art_style is 1 (VisualProfile
// STYLIZED); with art_style 0 nothing here is called and the classic frame is the same as before.
// The bands are the same three as the stone's (paint.gdshaderinc, environment front): one hand for the hero, the crowd
// and the hall. They live here too because the two fronts were built in parallel; folding them into one include is
// a later clean-up, the numbers are the spec's. STY-10 left it so on purpose: paint.gdshaderinc is the environment
// front's file and changed in the same round (fire pools, chamber); fold the two only once both are settled, and only
// if the stone's bands stay these three (the art-director's STY-09 lowered the stone's shadow band to 0.25, not ours).

// Light in three tones (spec 1.3, T3 and T18): N.L from 0 to 0.3 is 0.42 of the lit value, 0.3 to 0.65 is 0.72,
// above that 1.0; each step FIGURE_BAND_SOFT wide (0.10: a short ramp, never a hard step).
const float FIGURE_BAND_SOFT = 0.10;

float figure_bands(float ndl) {
	float w = FIGURE_BAND_SOFT * 0.5;
	return 0.42 + 0.30 * smoothstep(0.3 - w, 0.3 + w, ndl) + 0.28 * smoothstep(0.65 - w, 0.65 + w, ndl);
}

// Less photographic detail (T21, paint_flat): the texture's colour pulled toward its own average over mip `lod`
// (the noise goes, the large patches of the painting stay).
vec3 figure_flatten(vec3 raw, vec3 mean, float amount) {
	return mix(raw, mean, amount);
}

// The warm rim (T19): a fresnel of power `power`, 0 facing the camera, 1 on the silhouette.
float figure_rim(vec3 normal, vec3 view, float power) {
	return pow(1.0 - clamp(dot(normal, view), 0.0, 1.0), power);
}

// LC-4 (the Compatibility renderer): light raised to `g` by its luminance, the colour's own proportions kept (raising
// each channel greyed the painting: the bone and the leathers went to a cold grey).
vec3 figure_gamma(vec3 light, float g) {
	vec3 l = max(light, vec3(0.0));
	float y = dot(l, vec3(0.2126, 0.7152, 0.0722));
	return y > 0.0 ? l * (pow(y, g) / y) : l;
}
