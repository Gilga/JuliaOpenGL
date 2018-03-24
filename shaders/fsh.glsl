in Vertex vertex;
out vec4 outColor;

void main() {
  vec4 color = vertex.color;
  color = vec4(color.xyz,color.x*color.y*color.z);
  outColor = color;
}