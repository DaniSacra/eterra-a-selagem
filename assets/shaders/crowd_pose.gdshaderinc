// The crowd's poses as a vertex animation (E1a, VX-04; BakedModel): every pose of every clip of a figure is a run of
// texels in pose_positions (half floats) and pose_normals (octahedral), vertex v of pose p at texel p * pose_vertices + v,
// in rows of pose_width. The instance's colour says what to show (CrowdRenderer.add_kind): r the pose, g the next one,
// b the share of the next. The figure is drawn between the two, so it moves, never jumps from pose to pose.
// T5b P1-3: a figure whose clip just changed (CrowdRenderer.add_kind, fade_target) has a negative a: r the pose it
// showed last, g the new clip's pose, b how far the fade is, and -a the new clip's own blend: 1 + share toward the next
// pose, 2 for none, 2 + n + share for a loop of n poses back to its first. The fade goes to the new clip's blend, not
// to its nearest pose (which stepped from pose to pose through the fade).
// Read by crowd.gdshader and crowd_outline.gdshader (the outline follows the same body).
uniform highp sampler2D pose_positions : filter_nearest, repeat_disable;
uniform sampler2D pose_normals : filter_nearest, repeat_disable;
uniform int pose_vertices = 1;
uniform int pose_width = 2048;

ivec2 pose_texel(int pose, int v) {
	int i = pose * pose_vertices + v;
	return ivec2(i % pose_width, i / pose_width);
}

vec3 pose_normal(vec2 e) {
	vec2 p = e * 2.0 - 1.0;
	vec3 n = vec3(p.x, 1.0 - abs(p.x) - abs(p.y), p.y);
	float t = max(-n.y, 0.0);
	n.x += n.x >= 0.0 ? -t : t;
	n.z += n.z >= 0.0 ? -t : t;
	return normalize(n);
}

// Where vertex v stands and which way it faces, between the two poses the instance asks for.
void crowd_pose(int v, vec4 pick, out vec3 at, out vec3 facing) {
	int a = int(pick.r + 0.5);
	int b = int(pick.g + 0.5);
	ivec2 ta = pose_texel(a, v);
	ivec2 tb = pose_texel(b, v);
	vec3 pa = texelFetch(pose_positions, ta, 0).xyz;
	vec3 pb = texelFetch(pose_positions, tb, 0).xyz;
	vec3 na = pose_normal(texelFetch(pose_normals, ta, 0).xy);
	vec3 nb = pose_normal(texelFetch(pose_normals, tb, 0).xy);
	if (pick.a < 0.0) {
		float x = -pick.a;
		int whole = int(floor(x));
		float share = x - float(whole);
		int step = whole == 1 ? 1 : (whole == 2 ? 0 : 3 - whole);
		ivec2 tc = pose_texel(b + step, v);
		pb = mix(pb, texelFetch(pose_positions, tc, 0).xyz, share);
		nb = normalize(mix(nb, pose_normal(texelFetch(pose_normals, tc, 0).xy), share));
	}
	at = mix(pa, pb, pick.b);
	facing = normalize(mix(na, nb, pick.b));
}

// A piece of the figure that is away (the knight's thrown shield, BakedModel.parts): its vertices are the run
// [hide_from, hide_to) at the end of the mesh, and an instance whose state.a is negative (CrowdRenderer.state, `away`)
// draws it nowhere (all its vertices collapse on one point: zero-area triangles). Nothing is hidden by default.
uniform int hide_from = 0;
uniform int hide_to = 0;

vec3 crowd_away(int v, float flag, vec3 at) {
	return (flag < 0.0 && v >= hide_from && v < hide_to) ? vec3(0.0) : at;
}
