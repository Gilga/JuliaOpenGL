#import "globals.glsl"

layout(location = 0) in Vertex v;
layout(location = 0) out vec4 FragColor;

void main() {
  //vec2 uv = getUV(v.pos.xyz);
  //float depth = 1 - (1.0/(length(-iCamPos - v.world_center.xyz)));
  //float dist = abs(length(uv-vec2(0.5)));
  //if(dist>0.9) discard;
  //gl_FragDepth = depth; //gl_FragCoord.z;
  FragColor = vec4(1.0);
}