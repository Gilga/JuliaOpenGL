uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

layout (location = 0) in vec3 iVertex;
layout (location = 0) out Vertex v;

void main() {
  v = preset(iVertex);
  gl_Position = iMVP * v.world_pos;
}