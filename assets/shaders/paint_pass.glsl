#[compute]
#version 450
// PaintPass (STY-07, docs/art/stylized_spec.md 5.2): over the opaque frame only (it runs after the opaque pass, before
// the floor marks, the arcs, the particles, the x-ray and the numbers), a 4-sector Kuwahara of radius `radius` pixels
// (the mean of the calmest quadrant around each pixel: brush patches, edges kept) and a coloured contour where the
// depth jumps (a pixel in front of what is beside it by more than `edge_jump` of its depth; reversed Z, so the depth
// ratio is the distance ratio and no matrix is needed).

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Two dispatches (the frame's colour cannot be copied from): the filter from the frame into a scratch image, then
// the scratch back into the frame (copy_only).
layout(rgba16f, set = 0, binding = 0) uniform restrict writeonly image2D out_color;
layout(rgba16f, set = 0, binding = 1) uniform restrict readonly image2D src_color;
layout(set = 0, binding = 2) uniform sampler2D src_depth;
// The Forward+ normal and roughness (resolved), for the ink's figure mask (`mask`); the depth again when absent.
layout(set = 0, binding = 3) uniform sampler2D src_normal_roughness;

layout(push_constant, std430) uniform Params {
	vec2 size;
	float radius;
	float edge_px;
	vec4 edge_color; // rgb linear, a = strength
	float edge_jump;
	float kuwahara;
	float copy_only;
	float mask; // 0 none; 1 no ink where a figure (roughness tag) is in the cross; 2 shows the roughness channel
} p;

float luma(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

vec3 fetch(ivec2 at) {
	return imageLoad(src_color, clamp(at, ivec2(0), ivec2(p.size) - 1)).rgb;
}

float depth_at(ivec2 at) {
	return texelFetch(src_depth, clamp(at, ivec2(0), ivec2(p.size) - 1), 0).r;
}

void main() {
	ivec2 at = ivec2(gl_GlobalInvocationID.xy);
	if (at.x >= int(p.size.x) || at.y >= int(p.size.y)) {
		return;
	}
	vec3 here = fetch(at);
	if (p.mask > 1.5 && p.copy_only < 0.5) {
		// red where the instance is dynamic (Forward+ packs it above 0.5), grey by the roughness elsewhere
		float a = texelFetch(src_normal_roughness, at, 0).a;
		imageStore(out_color, at, a > 0.5 ? vec4(0.8, 0.05, 0.05, 1.0) : vec4(vec3(a * 0.5), 1.0));
		return;
	}
	if (p.copy_only > 0.5) {
		imageStore(out_color, at, vec4(here, 1.0));
		return;
	}
	vec3 result = here;
	if (p.kuwahara > 0.5) {
		int r = int(p.radius + 0.5);
		vec3 best = here;
		float best_var = 1e20;
		for (int q = 0; q < 4; q++) {
			ivec2 dir = ivec2((q & 1) == 0 ? -1 : 1, (q & 2) == 0 ? -1 : 1);
			vec3 sum = vec3(0.0);
			float l_sum = 0.0;
			float l_sq = 0.0;
			float n = 0.0;
			for (int y = 0; y <= r; y++) {
				for (int x = 0; x <= r; x++) {
					vec3 c = fetch(at + ivec2(x, y) * dir);
					float l = luma(c);
					sum += c;
					l_sum += l;
					l_sq += l * l;
					n += 1.0;
				}
			}
			vec3 mean = sum / n;
			float lm = l_sum / n;
			// the variance relative to the brightness: a dark quadrant and a light one are judged alike
			float v = (l_sq / n - lm * lm) / max(lm * lm, 1e-4);
			if (v < best_var) {
				best_var = v;
				best = mean;
			}
		}
		result = best;
	}
	if (p.edge_color.a > 0.0) {
		float d = depth_at(at);
		int w = max(1, int(p.edge_px + 0.5));
		float jump = 0.0;
		// in front of a neighbour (larger reversed depth) by edge_jump of its own depth or more
		jump = max(jump, d - depth_at(at + ivec2(w, 0)));
		jump = max(jump, d - depth_at(at + ivec2(-w, 0)));
		jump = max(jump, d - depth_at(at + ivec2(0, w)));
		jump = max(jump, d - depth_at(at + ivec2(0, -w)));
		float rel = jump / max(d, 1e-6);
		float edge = smoothstep(p.edge_jump, p.edge_jump * 2.0, rel);
		if (p.mask > 0.5 && edge > 0.0) {
			// no ink on the figures (the art review of 2026-11-20: the crowd's outline doubled, and figures behind a life
			// bar drew their edge over it): the Forward+ marks a moving instance (the crowd, the paladin, his sword)
			// with its roughness channel above 0.5, so any edge touching one is left alone
			float dyn = texelFetch(src_normal_roughness, at, 0).a;
			dyn = max(dyn, texelFetch(src_normal_roughness, clamp(at + ivec2(w, 0), ivec2(0), ivec2(p.size) - 1), 0).a);
			dyn = max(dyn, texelFetch(src_normal_roughness, clamp(at + ivec2(-w, 0), ivec2(0), ivec2(p.size) - 1), 0).a);
			dyn = max(dyn, texelFetch(src_normal_roughness, clamp(at + ivec2(0, w), ivec2(0), ivec2(p.size) - 1), 0).a);
			dyn = max(dyn, texelFetch(src_normal_roughness, clamp(at + ivec2(0, -w), ivec2(0), ivec2(p.size) - 1), 0).a);
			edge *= 1.0 - step(0.5, dyn);
		}
		result = mix(result, p.edge_color.rgb, edge * p.edge_color.a);
	}
	imageStore(out_color, at, vec4(result, 1.0));
}
