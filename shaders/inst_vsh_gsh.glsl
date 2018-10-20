uniform vec3 iPosition = vec3(0);

layout (location = 1) in vec3 iInstancePos;
layout (location = 2) in vec2 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();

  v.flags = vec4(0,(iInstanceFlags.x-1),iInstanceFlags.y,0);
  
  if (frustum) {
    int result = checkSphere(iInstancePos.xyz, 1.5);
    if (result < 0) { v.flags.x = -1; }
  }

  if(v.flags.x >= 0) { //texture index
    v.world_center  = vec4(iInstancePos.xyz+iPosition,1);
    if(v.flags.y >= 0) { v.uvs.zw = getTexUV(v.flags.y); }
  } // else discard

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}