#import "globals.glsl"

layout (location = 0) in vec3 iInstancePos;
layout (location = 1) in vec2 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();

  v.flags = vec4(0,(iInstanceFlags.x-1),iInstanceFlags.y,0); //vec4(0,0,127,iInstanceFlags.x);
  
  if(v.flags.x >= 0 && !(iUseTexture && v.flags.y < 0)) { //texture index
    v.world_center  = vec4(iInstancePos.xyz+iPosition,1);
    v.world_pos    = vec4(v.pos.xyz+v.world_center.xyz,1);
    v.world_normal = normalize(v.world_pos);
    if(v.flags.y >= 0) { v.uvs.zw = getTexUV(v.flags.y); }
  } // else discard

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}
