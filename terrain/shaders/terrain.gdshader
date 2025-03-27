shader_type spatial;
render_mode world_vertex_coords;
render_mode cull_disabled;

varying vec3 worldPos;

#include "stochastic.gdshaderinc"

uniform mat4 _origins[128];
uniform sampler2D _heightmaps[128] : filter_linear_mipmap_anisotropic;
uniform int _origins_count;

uniform sampler2D grass_albedo;
uniform sampler2D grass_orm;
uniform sampler2D grass_normal;

uniform float map_size = 8192.0;
uniform float height_scale = 400.0;
uniform float sea_level : hint_range(0.0, 1e3, 0.001) = 0.76;

global uniform vec3 _terrain_origin;

float height (vec2 p) {
  float h = -10.0;
  for (int i = 0; i < _origins_count; ++i) {
    vec3 o = _origins[i][3].xyz;
    if (distance(p, o.xz) > 8192.0)
      continue;
    vec3 q = vec3(p.x, 0, p.y);
    q -= o;
    q = (vec4(q, 0) * _origins[i]).xyz;
    float k = ((textureLod(_heightmaps[i], clamp(q.xz / map_size + 0.5, 0, 1), 0).r) * height_scale - sea_level);
    k += o.y;
    k /= _origins[i][1].y;
    h = max(h, k);
    //h = h + k;
  }
  return h;
}

vec3 ll_to_xyz(vec2 ll) {
  float lon = ll.x;
  float lat = ll.y;
  vec3 p = vec3(-cos(lon) * cos(lat), sin(lon) * cos(lat), sin(lat));
  return p;
}

vec3 distort (vec3 p) {
  return p + vec3(0, height(p.xz), 0);
  //// To make it look like a sphere...
  //float h = max(0, height(p.xz));
  //float r = 6378000.0;
  //p.xz -= _terrain_origin.xz;
  //p = ll_to_xyz(p.xz / r + vec2(PI / 2.0, 0)) * (r + h) - vec3(0, r, 0);
  //p.xz += _terrain_origin.xz;
  //return p;
}

void vertex() {
  worldPos = VERTEX;
  UV = mod(VERTEX.xz / map_size + 0.5, vec2(1));
  VERTEX = distort(VERTEX);
}

uniform float rock_slope = 0.5;
uniform float rock_slope_blend = 0.0;

void fragment() {
  
  /// To generate normals from the heightmap
  float s = 10.0 * length(fwidth(worldPos));
  vec3 p1 = distort(worldPos);
  vec3 p2 = distort(worldPos + s * vec3(1, 0, 0));
  vec3 p3 = distort(worldPos + s * vec3(0, 0, -1));
  vec3 N = normalize(cross(p1 - p2, p1 - p3));

  ///// To generate normals from the actual geometry
  //N = normalize(-cross(dFdx(p1), dFdy(p1)));

  NORMAL = N;
  TANGENT = vec3(1, 0, 0);
  BINORMAL = vec3(0, 0, -1);

  float h = distort(worldPos).y;
  float grassiness = pow(N.y, 5);
  float snowy = smoothstep(40, 50, h);
  float sandy = smoothstep(5, -5, h) * grassiness;

  ROUGHNESS = mix(0.3, 0.7, grassiness);

  ALBEDO = mix(
    vec3(0.4, 0.5, 0.3) / 12.0,
    mix(vec3(0.0, 0.0, 0.0), vec3(0.0, 0.2, 0.0), 0.5),
    grassiness
  );

  ALBEDO = mix(ALBEDO, vec3(0.5, 0.5, 0.5), snowy);

  ALBEDO = mix(ALBEDO, vec3(1, 1, 0.1) / 20.0, sandy);

  vec2 uv = worldPos.xz;

  uv /= 1000.0;

  ALBEDO = mix(
    ALBEDO * 0.2,
    ALBEDO * 1.5,
    mix(
      textureStochastic(grass_albedo, uv).r,
      textureStochastic(grass_albedo, uv * 64.0).r,
      0.5
    )
  );

  NORMAL_MAP = mix(
    textureStochastic(grass_normal, uv).rgb,
    textureStochastic(grass_normal, uv * 64.0).rgb,
    0.5
  );

  NORMAL = mat3(VIEW_MATRIX) * NORMAL;
  TANGENT = mat3(VIEW_MATRIX) * vec3(1, 0, 0);
  BINORMAL = mat3(VIEW_MATRIX) * vec3(0, 0, -1);

}
