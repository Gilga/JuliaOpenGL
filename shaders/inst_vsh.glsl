uniform float time = 1;
uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
uniform vec3 iPosition;
uniform float iTexIndex;

layout (location = 0) in vec3 iVertex;
layout (location = 1) in vec3 iInstancePos;
layout (location = 2) in vec2 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();
  vec4 outpos = vec4(0,0,0,0);

  v.texindex = (iInstanceFlags.x-1) + iTexIndex;
  
  if(v.texindex >= 0) {
    v.world        = iInstancePos.xyz+iPosition;
  
    v.pos          = vec3(iVertex); outpos = vec4(v.world+v.pos,1);
    v.normal       = normalize(v.pos);
    v.color        = getVertexColor(v.pos,v.normal, time);

    v.texUV        = getTexUV(v.texindex);
    v.sides        = iInstanceFlags.y;

    v.world_pos    = v.pos+v.world_pos;
    v.world_normal = normalize(v.world_pos);
  }

  vertex = v;
  gl_Position = iMVP*outpos;
}