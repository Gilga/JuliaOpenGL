layout(location = 0) in Vertex v;
layout(location = 0) out vec4 outColor;

void main() {
  vec4 color = v.color;
  color = vec4(color.xyz,color.x*color.y*color.z);
  outColor = color;
}