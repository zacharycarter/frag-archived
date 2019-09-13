$input v_texcoord0

#include "common.sh"

SAMPLER2D(s_texColor, 0);

const vec3 u_white_point = vec3(0.75, 0.75, 0.75);

vec3 aces_tonemap(vec3 x) {
  float a = 2.51;
  float b = 0.03;
  float c = 2.43;
  float d = 0.59;
  float e = 0.14;
  return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

void main()
{
    vec3 tex_color = texture2DLod(s_texColor, v_texcoord0, 0.0).rgb;
    tex_color = vec3(1.0, 1.0, 1.0) - exp(tex_color / u_white_point);
    gl_FragColor = vec4(aces_tonemap(tex_color), 1.0);
}