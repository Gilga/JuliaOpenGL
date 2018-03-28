uniform vec3 iPosition;

layout (location = 1) in vec3 iInstancePos;
layout (location = 2) in vec2 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();

  v.flags = vec4((iInstanceFlags.x-1),iInstanceFlags.y,0,0);

  if(v.flags.x >= 0) { //texture index
    v.world_center  = vec4(iInstancePos.xyz+iPosition,1);
    v.uvs.zw = getTexUV(v.flags.x);
  }

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}