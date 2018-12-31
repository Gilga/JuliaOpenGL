//float = 1 * 4 bytes 
// Never use a vec3 in a UBO or SSBO.
// https://stackoverflow.com/questions/38172696/should-i-ever-use-a-vec3-inside-of-a-uniform-buffer-or-shader-storage-buffer-o
struct BuffData {
  vec3 pos; //4*3
  float type;
  float sides;
  float height;
};

/*
BuffData createBuffData(vec3 pos, float type, float sides, float height) { return BuffData(float[3](pos.xyz),type,sides,height); }
vec3 getPos(BuffData data) { return vec3(data.pos); }
BuffData setPos(BuffData data, vec3 pos) { data.pos = float[3](pos.xyz); return data; }
*/