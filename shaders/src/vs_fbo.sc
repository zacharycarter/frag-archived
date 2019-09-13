$input a_position, a_texcoord0
$output v_texcoord0

#include "common.sh"

void main()
{
    gl_Position = vec4(a_position.x, a_position.y, 0.0f, 1.0f);
    v_texcoord0 = a_texcoord0;
}