#import "globals.glsl"

layout (location = 0) in vec3 iInstancePos;
layout (location = 1) in vec3 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();
  vec3 pos = iInstancePos + iCenter * 128 + iPosition;

  v.flags = vec4(0,(iInstanceFlags.x-1),iInstanceFlags.y,iInstanceFlags.z); //vec4(0,0,127,iInstanceFlags.x);
  if(iInstanceFlags.x == 9999) pos = vec3(sin(iTime)*100,70+sin(iTime*3)*30,cos(iTime)*100);
  
  if(v.flags.w >= 0) {
    v.world_center  = vec4(pos,1);
    v.world_pos    = vec4(v.pos.xyz+v.world_center.xyz,1);
    v.world_normal = normalize(v.world_pos);
  } // else discard

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}
