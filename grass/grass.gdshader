shader_type spatial;
// render_mode world_vertex_coords;
render_mode cull_disabled;

varying vec3 worldPos;

#include "hash.gdshaderinc"

uniform vec3 origin;

uniform sampler2D noise_tex;
uniform sampler2D heightmap: repeat_disable;

uniform vec3 upper_albedo: source_color;
uniform vec3 lower_albedo: source_color;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, s), vec2(-s, c));
	return m * v;
}

void vertex() {
  VERTEX.xz *= (1.0 - VERTEX.y);
  VERTEX.xz += 1.0 * hash22(0.01 * abs(NODE_POSITION_WORLD.xz + 41232.212));
  VERTEX.x += VERTEX.y * (texture(noise_tex, 0.1 * NODE_POSITION_WORLD.xz + 0.7).r - 0.5);
  VERTEX.z += VERTEX.y * (texture(noise_tex, 0.1 * NODE_POSITION_WORLD.xz + 0.3).r - 0.5);
  VERTEX.x *= 0.1;
  VERTEX.y *= 1.0;
  VERTEX.xz = rotate(VERTEX.xz, TAU * texture(noise_tex, 0.1 * NODE_POSITION_WORLD.xz).r);
  VERTEX.x += VERTEX.y * 0.2 * sin(TIME);
  worldPos = (MODEL_MATRIX * vec4(VERTEX, 1)).xyz;
  VERTEX.y += texture(heightmap, INSTANCE_CUSTOM.xy).r;
  worldPos = INSTANCE_CUSTOM.xyz;
  //float r = length(INSTANCE_CUSTOM.xy - 0.5);
  //VERTEX *= smoothstep(0.3, 0.2, r);
  //VERTEX.y *= clamp(1.0 - length(INSTANCE_CUSTOM.xy - 0.5), 0, 1);
}

render_mode alpha_to_coverage;
render_mode depth_draw_always;

void fragment() {
  ALBEDO = mix(lower_albedo, upper_albedo, 1.0 - UV.y);
  NORMAL = -normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
  ROUGHNESS = 0.2;
  if (!FRONT_FACING)
    NORMAL = -NORMAL;
  //ALPHA = length(VERTEX);
  //ALPHA = 1.0 - smoothstep(30.0 - 0.01, 30.0, -VERTEX.z);
  ALPHA = 1.0 - smoothstep(40.0, 60, -VERTEX.z);
}
