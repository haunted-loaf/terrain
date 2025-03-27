#[compute]

#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
layout(set = 0, binding = 0) uniform sampler2D depth_texture;
layout(rgba16f, set = 0, binding = 1) uniform restrict writeonly image2D depth_image;

layout(set = 0, binding = 2, std430) buffer Params {
  vec2 resolution;
  float far;
} params;

void main() {
  ivec2 xy = ivec2(gl_GlobalInvocationID.xy);
  vec2 uv = (vec2(xy) + 0.5) / params.resolution;
  float depth = texture(depth_texture, uv).r;
  depth *= params.far;
  depth -= params.far / 2.0;
  // depth = 1.0 - params.far / (params.far - depth);
  imageStore(depth_image, xy, vec4(depth, 0, 0, 1));
}
