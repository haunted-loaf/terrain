shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D depth_texture: hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D texture_normal1;
uniform sampler2D texture_normal2;

uniform vec2 wave_direction1 = vec2(2.0,0.0);
uniform vec2 wave_direction2 = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.001) = 0.025;

uniform vec3 absorption : source_color = vec3(0.09, 0.02, 0.01);
uniform float absorption_power = 1.0;

varying vec3 worldPos;

void vertex() {
  worldPos = VERTEX.xyz;
  UV.xy = 0.01 * VERTEX.xz;
}

float fresnel(float amount, vec3 normal, vec3 view) {
  return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

vec3 waterAttenuate(float depth) {
  return exp(-pow(depth, 0.5) * absorption_power * absorption);
}

vec3 samplePosition(vec2 uv, mat4 proj, mat4 view) {
  float depth = textureLod(depth_texture, uv, 0.0).r;
  vec4 pos = proj * vec4(uv * 2.0 - 1.0, depth, 1.0);
  pos = pos / pos.w;
  pos = view * vec4(pos.xyz, 1.0);
  return pos.xyz;
}

vec3 sampleNoise(vec2 uv) {
  vec2 time1 = (TIME * wave_direction1) * time_scale;
  vec2 time2 = (TIME * wave_direction2) * time_scale;
  vec3 normal = mix(texture(texture_normal1, uv + time1).rgb, texture(texture_normal2, uv + time2).rgb, 0.5);
  return normal;
}

void fragment () {
  ALBEDO = albedo;
  ROUGHNESS = roughness;

  NORMAL_MAP = sampleNoise(UV);
  NORMAL_MAP_DEPTH = 0.2;

  vec2 uv = clamp(SCREEN_UV, 0.0, 1.0);
  //INV_VIEW_MATRIX is wrong in double-precision builds
  vec3 bedPos = samplePosition(uv, INV_PROJECTION_MATRIX, inverse(VIEW_MATRIX));
  float depth = distance(bedPos, worldPos);
  vec3 color = textureLod(screen_texture, uv, 0).rgb;
  color *= waterAttenuate(depth);
  ALBEDO = mix(color, ALBEDO, clamp(fresnel(0.5, NORMAL, VIEW), 0, 1));

  //ALBEDO = mix(vec3(0.3), ALBEDO, smoothstep(0.0, 2.0, depth));
  ALPHA = smoothstep(0.0, 0.1, depth);

  if (dot(VIEW, NORMAL) < 0.003)
    discard;
}

void light() {
  SPECULAR_LIGHT = SPECULAR_LIGHT;
}