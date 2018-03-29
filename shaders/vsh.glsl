uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
uniform vec3 iPosition = vec3(0);
uniform float iTexIndex = 0;

layout (location = 0) in vec3 iVertex;
layout (location = 0) out Vertex vertex;

void main() {
  bool dummy = false; if (iVertex.x == 0) dummy = false; // disable out optimization
  Vertex v = preset(iVertex);
  vec4 outpos = vec4(0,0,0,0);
  
  v.flags = vec4((iTexIndex-1),0,0,0);
  
  if(v.flags.x >= 0) {
    v.world_center.xyz += iPosition;
    v.world_pos.xyz += v.world_center.xyz;
    v.world_normal = normalize(v.world_pos);
    v.uvs.zw = getTexUV(v.flags.x);
    outpos=iMVP*v.world_pos;
  }
  
  vertex = v;
  gl_Position = outpos;
}