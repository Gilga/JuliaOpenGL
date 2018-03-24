uniform float time = 1;
uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
uniform vec3 iPosition;

layout (location = 1) in vec3 iInstancePos;
layout (location = 2) in vec2 iInstanceFlags;

layout (location = 0) out Vertex vertex;

void main() {
  Vertex v = _Vertex();

  v.texindex = (iInstanceFlags.x-1);
  
  if(v.texindex >= 0) {
    v.world        = iInstancePos.xyz+iPosition*0;
    v.texUV        = getTexUV(v.texindex);
    v.sides        = iInstanceFlags.y;
  }

  vertex = v;
  gl_Position = vec4(0,0,0,0);
}