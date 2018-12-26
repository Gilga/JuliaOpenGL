#import "globals.glsl"

layout (location = 0) in vec3 iInstancePos;
layout (location = 1) in vec3 iInstanceFlags;

layout (location = 0) out Vertex vertex;

struct Data {
  float[3] pos;
  float type;
  float sides;
  float height;
};

layout(std430, binding = 0) buffer visibleBuffer {
  Data visibles[];
};

void main() {
  Vertex v = _Vertex();
  vec3 pos = iInstancePos + iCenter + iPosition;

  v.flags = vec4(iInstanceFlags.x,0,iInstanceFlags.y,iInstanceFlags.z);
  
  if(v.flags.w >= 0) {
    v.world_center  = vec4(pos,1);
    vertex = v;
    //uint objid = uint(v.flags.x);
    //visibles[objid].height = 1;

    //if (length(v.world_pos)) { //all(lessThan(abs(objPos),dim))){
      // inside bbox
      //visibles[objid] = 1;
    //}
  } //else discard;
}
