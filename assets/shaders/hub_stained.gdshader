shader_type spatial;
// Santuario da Vigilia (hub refine round 4): a Gothic lancet's stained glass. A lattice of small lozenges in four muted jewel
// tones (amber, wine, deep blue, moss), each cell its own tone and a little brighter at its heart, divided by dark lead came,
// a leaded mullion down the middle and a transom, the whole darker toward the stone and lit from behind (brighter low in
// the middle). Replaces the pure-colour wedges that read as a beach umbrella. One unlit card on an ogive panel
// (HubFacades.ogive_mesh: UV.y 0 at the apex, UV.x 0 to 1 across); the colours are the uniforms, set from HubFacades.STAINED.
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 jewel_a : source_color = vec3(0.78, 0.5, 0.16);
uniform vec3 jewel_b : source_color = vec3(0.46, 0.1, 0.17);
uniform vec3 jewel_c : source_color = vec3(0.1, 0.18, 0.42);
uniform vec3 jewel_d : source_color = vec3(0.2, 0.33, 0.18);
uniform vec3 lead_color : source_color = vec3(0.03, 0.025, 0.03);
// Lozenges across the panel, and the height of the panel over its width (so a lozenge stays a lozenge).
uniform float cells = 4.0;
uniform float aspect = 2.1;
// Half the width of the lead came, in a lozenge's own units.
uniform float lead = 0.075;
// The light behind: its overall share and how much brighter the middle is than the rim.
uniform float brightness = 0.85;
uniform float heart = 0.35;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 p = vec2(UV.x * cells, UV.y * cells * aspect);
	vec2 q = vec2(p.x + p.y, p.x - p.y) * 0.5;
	vec2 cell = floor(q);
	vec2 f = fract(q);
	float pick = hash(cell);
	vec3 c = pick < 0.28 ? jewel_a : (pick < 0.52 ? jewel_b : (pick < 0.8 ? jewel_c : jewel_d));
	c *= 0.8 + 0.4 * hash(cell + 9.0);
	// brighter at the heart of each piece of glass
	float centre = 1.0 - clamp(length(f - 0.5) * 1.6, 0.0, 1.0);
	c *= 1.0 + heart * centre;
	// the lead came between the lozenges, the mullion and the transom
	float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y));
	float came = 1.0 - smoothstep(lead, lead * 1.6, edge);
	came = max(came, 1.0 - smoothstep(0.012, 0.03, abs(UV.x - 0.5)));
	came = max(came, 1.0 - smoothstep(0.008, 0.02, abs(UV.y - 0.62)));
	// dark toward the rim, lit from behind low in the middle
	float rim = smoothstep(0.0, 0.16, min(UV.x, 1.0 - UV.x));
	float back = mix(0.55, 1.0, (1.0 - abs(UV.x - 0.5) * 1.6) * smoothstep(0.0, 0.85, UV.y));
	ALBEDO = mix(c * brightness * back * mix(0.5, 1.0, rim), lead_color, clamp(came, 0.0, 1.0));
}
