#ifndef _TERRAIN_STOCHASTIC_INCLUDED
#define _TERRAIN_STOCHASTIC_INCLUDED 1

// based on https://godotshaders.com/shader/stochastic-filter-for-hiding-texture-tiling/

vec2 hash22 (vec2 s) {
	vec2 i = vec2(0.0);
  s = vec2(dot(s, vec2(127.1, 311.7)), dot(s, vec2(269.5, 183.3)));
	return fract(sin(modf(s / 3.14159, i)) * 43758.5453);
}

vec4 textureStochastic(sampler2D tex, vec2 uv) {
  mat4 BW_vx;
  vec2 skewUV = mat2(vec2(1.0f, 0.0f), vec2(-0.57735027f, 1.15470054f)) * (uv * 3.464);
  vec2 vxID = vec2(floor(skewUV));
  vec3 barry = vec3(fract(skewUV), 0);
  barry.z = 1.0 - barry.x - barry.y;
  BW_vx = ((barry.z > 0.0) ?
          mat4(vec4(vxID, 0, 0),
               vec4(vxID + vec2(0, 1), 0, 0),
               vec4(vxID + vec2(1, 0), 0, 0),
               vec4(barry.zyx, 0)) :
          mat4(vec4(vxID + vec2(1, 1), 0, 0),
               vec4(vxID + vec2(1, 0), 0, 0),
               vec4(vxID + vec2(0, 1), 0, 0),
               vec4(-barry.z, 1.0-barry.y, 1.0-barry.x, 0)));
  vec2 dx = dFdx(uv);
  vec2 dy = dFdy(uv);
  return textureGrad(tex, uv + hash22(BW_vx[0].xy), dx, dy) * BW_vx[3].x +
         textureGrad(tex, uv + hash22(BW_vx[1].xy), dx, dy) * BW_vx[3].y +
         textureGrad(tex, uv + hash22(BW_vx[2].xy), dx, dy) * BW_vx[3].z;
}

#endif
