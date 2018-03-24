
uniform float time = 1;
uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

layout (location = 0) in vec3 iVertex;

out Vertex vertex;

void main() {
  vertex.pos          = iVertex;
  vertex.normal       = normalize(vertex.pos);
  vertex.uv           = vec2(0);
  vertex.color        = getVertexColor(vertex.pos, vertex.normal, time);
  vertex.world        = vec3(0,0,0);
  vertex.world_pos    = vertex.pos+vertex.world;
  vertex.world_normal = normalize(vertex.world_pos);
  vertex.texindex     = 0;
  
  gl_Position = iMVP * vec4(vertex.world_pos, 1.0);
}