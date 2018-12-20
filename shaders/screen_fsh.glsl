layout(location = 0) uniform sampler2D iHeightMap;
layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 outColor;

void main() {
  float c = texture(iHeightMap, texCoord).x;
  outColor = vec4(c, 1, 1, 1);
}