shader_type spatial;
render_mode unshaded;
render_mode fog_disabled;

uniform vec3 colour : source_color;
uniform float density = 1.0;

uniform sampler2D depth_texture: hint_depth_texture, filter_nearest, repeat_disable;
uniform sampler2D screen_texture: hint_screen_texture, filter_nearest, repeat_disable;

uniform vec3 absorption : source_color = vec3(0.09, 0.02, 0.01);
uniform float absorption_power = 1.0;

varying vec3 real_vertex_sigh;

uniform sampler2D texture_normal1;
uniform sampler2D texture_normal2;

uniform vec2 wave_direction1 = vec2(2.0,0.0);
uniform vec2 wave_direction2 = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.001) = 0.025;

vec3 projectOntoPlane(vec3 O, vec3 D, vec3 N, vec3 P) {
  float t = dot(P - O, N) / dot(D, N);
  return O + t * D;
}

vec3 waterAttenuate(float depth) {
  return exp(-pow(depth, 0.5) * absorption_power * absorption);
}

vec3 clipToView(vec3 clip, mat4 inv_proj) {
  vec4 pos = inv_proj * vec4(clip, 1);
  pos = pos / pos.w;
  return pos.xyz;
}

vec3 viewToWorld(vec3 pos, mat4 inv_view) {
  return (inv_view * vec4(pos, 1)).xyz;
}

vec3 clipToWorld(vec3 pos, mat4 inv_proj, mat4 inv_view) {
  return viewToWorld(clipToView(pos, inv_proj), inv_view);
}

vec3 sampleViewPosition(vec2 uv, mat4 inv_proj) {
  float depth = textureLod(depth_texture, uv, 0.0).r;
  return clipToView(vec3(uv * 2.0 - 1.0, depth), inv_proj);
}

vec3 sampleWorldPosition(vec2 uv, mat4 inv_proj, mat4 inv_view) {
  return viewToWorld(sampleViewPosition(uv, inv_proj), inv_view);
}

vec3 sampleNoise(vec2 uv) {
  vec2 time1 = (TIME * wave_direction1) * time_scale;
  vec2 time2 = (TIME * wave_direction2) * time_scale;
  vec3 normal = mix(texture(texture_normal1, uv + time1).rgb, texture(texture_normal2, uv + time2).rgb, 0.5);
  return normal;
}

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
  real_vertex_sigh = POSITION.xyz;
}

vec3 overlay (vec3 a, vec3 b) {
  return vec3(
    a.r < 0.5 ? 2.0 * a.r * b.r : 1.0 - 2.0 * (1.0 - a.r) * (1.0 - b.r),
    a.g < 0.5 ? 2.0 * a.g * b.g : 1.0 - 2.0 * (1.0 - a.g) * (1.0 - b.g),
    a.b < 0.5 ? 2.0 * a.b * b.b : 1.0 - 2.0 * (1.0 - a.b) * (1.0 - b.b)
  );
}

void fragment() {
  // INV_VIEW_MATRIX is wrong in double-precision builds
  vec3 wpos = sampleWorldPosition(SCREEN_UV, INV_PROJECTION_MATRIX, inverse(VIEW_MATRIX));
  vec3 from = clipToWorld(real_vertex_sigh, INV_PROJECTION_MATRIX, inverse(VIEW_MATRIX));
  vec3 to = wpos;

  vec2 uv = SCREEN_UV;

  if (from.y > 0.0)
    discard;

  if (to.y > 0.0) {
    to = projectOntoPlane(from, normalize(to - from), vec3(0, 1, 0), vec3(0));
    vec3 noise = normalize(sampleNoise(to.xz / 100.0) - 0.5 * 0.5);
    uv += noise.xz * 0.02;
    ALBEDO = texture(screen_texture, uv).rgb;
    ALBEDO *= pow(dot(normalize(to - from), vec3(0, 1, 0)), 2);
    float depth = distance(from, to);
    ALBEDO *= waterAttenuate(depth) * waterAttenuate(-to.y);
  } else {
    vec3 noise = sampleNoise(to.xz / 100.0);
    float depth = distance(from, to);
    ALBEDO = texture(screen_texture, uv).rgb;
    ALBEDO = mix(ALBEDO, overlay(ALBEDO, vec3(pow(noise.z, 10.0))), 0.1);
    ALBEDO *= waterAttenuate(depth) * waterAttenuate(-to.y);
 }
}
