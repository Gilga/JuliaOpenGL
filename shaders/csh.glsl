uniform float roll = 0;

layout (local_size_x = 1, local_size_y = 1) in;
layout(rgba32f, binding = 0) uniform writeonly image2D destTex;

void main() {
  ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);
  float localCoef = length(vec2(ivec2(gl_LocalInvocationID.xy)-8)/8.0);
  float globalCoef = sin(float(gl_WorkGroupID.x+gl_WorkGroupID.y)*0.1 + roll)*0.5;
  vec4 pixel = vec4(1.0-globalCoef*localCoef, 0, 0, 0);
  imageStore(destTex, pixel_coords, pixel);
}