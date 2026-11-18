shader_type spatial;
// The lilac light in the fissure of the Provação's stele (TrialLook, AP-1 ART-01.4): only the crack glows, the stone
// round it is stone. Unlit, brightest deep in the fissure's middle and fading toward its ends along the stele's height,
// breathing slowly; `level` dims it after the choice (TrialLook.settle). Its brightest channel stays under the glow.
render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.52, 0.36, 0.78);
uniform float glow = 0.8;
uniform float level = 1.0;
// The stele's foot (world height) and height (m) for the fade at the ends; its breath.
uniform float foot_y = 0.3;
uniform float height = 2.3;
uniform float breathe = 0.15;
uniform float breathe_rate = 0.4;

varying float up;

void vertex() {
	up = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y - foot_y;
}

void fragment() {
	float t = clamp(up / height, 0.0, 1.0);
	float ends = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.82, 1.0, t)) * 0.75 + 0.25;
	float b = 1.0 - breathe + breathe * sin(TIME * breathe_rate * 6.2831853 + t * 3.0);
	ALBEDO = color * glow * level * ends * b;
}
