#import "globals.glsl"
#import "buffer.glsl"

#define MAXSIZE $CHUNK3D_SIZE //?^3

layout (location = 0) in vec3 iInstancePos;
layout (location = 1) in vec3 iInstanceFlags;

layout (location = 0) out Vertex vertex;

layout(std430) buffer inputBuffer { BuffData instances[]; };

void main() {
  Vertex v = _Vertex();
  //uint objid = uint(iInstanceFlags.x);
  uint index = gl_VertexID; //+ gl_DrawID * MAXSIZE
  
  BuffData data = instances[index];

  vec3 pos = data.pos + iCenter + iPosition;

  //v.size = vec4(0,0,0,0);
  //v.flags = vec4(0,0,127,iInstanceFlags.x);
  //v.flags = vec4(iInstanceFlags.x,0,iInstanceFlags.y,iInstanceFlags.z);
  v.flags = vec4(data.height,0,data.sides,data.type);
  //if(index == 0) pos = vec3(sin(iTime)*100,70+sin(iTime*3)*30,cos(iTime)*100);
  
  if(v.flags.w >= 0) {
    v.world_center  = vec4(pos,1);
    v.world_pos    = vec4(v.pos.xyz+v.world_center.xyz,1);
    v.world_normal = normalize(v.world_pos);
    v.size = vec4(0,0,iInstancePos.x,iInstanceFlags.x);
  } // else discard

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}
