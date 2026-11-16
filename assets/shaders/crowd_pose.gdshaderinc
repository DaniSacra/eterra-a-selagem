// The crowd's poses as a vertex animation (E1a, VX-04; BakedModel): every pose of every clip of a figure is a run of
// texels in pose_positions (half floats) and pose_normals (octahedral), vertex v of pose p at texel p * pose_vertices + v,
// in rows of pose_width. The instance's colour says what to show (CrowdRenderer.add_kind): r the pose, g the next one,
// b the share of the next. The figure is drawn between the two, so it moves, never jumps from pose to pose.
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
	at = mix(texelFetch(pose_positions, ta, 0).xyz, texelFetch(pose_positions, tb, 0).xyz, pick.b);
	facing = normalize(mix(pose_normal(texelFetch(pose_normals, ta, 0).xy), pose_normal(texelFetch(pose_normals, tb, 0).xy), pick.b));
}
