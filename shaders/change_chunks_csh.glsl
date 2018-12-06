#import "globals.glsl"
#import "landscape.glsl"

layout (local_size_x = 128) in; //, local_size_y = 4, local_size_z = 4

layout(binding = 0, offset = 0) uniform atomic_uint LIMIT;
layout(binding = 1, offset = 0) uniform atomic_uint instanceID;
layout(binding = 2, offset = 0) uniform atomic_uint instanceCount;

layout(std430, binding = 0) buffer Buffer {
  Data data[];
} dataset;

layout(std430, binding = 1) writeonly buffer Output {
  Data data[];
} outputset;

bool is_visible(vec3 pos)
{
  if (frustum) {
    int result = checkSphere(pos, 1.5);
    if (result < 0) { return false; }
  }
  return true;
}

void main() {
  uint ident  = gl_GlobalInvocationID.x;
  
  if(ident == 0) {
    atomicCounterExchange(instanceID, 0);
    atomicCounterExchange(instanceCount, 0);
  }
  
  if(ident >= atomicCounter(LIMIT)) return;
  uint id  = ident; //atomicCounterIncrement(instanceID);
  
  Data data = dataset.data[id];
  vec2 flags = vec2(data.type,data.sides);
  vec3 index = vec3(data.pos[0],data.pos[1],data.pos[2]);
  vec3 pos = translate(index);
  vec3 campos = vec3(iCamPos.x,0,iCamPos.z)+vec3(100,64,100)*vec3(sin(iCamAng.x),sin(iCamAng.y)*0,cos(iCamAng.x));

  vec3 len=-campos-pos;
  
  float range = 128;
  
  bool valid_x = abs(len.x) <= range;
  bool valid_z = abs(len.z) <= range;
  bool valid_y = abs(len.y) <= range;
  bool valid = true; // is_visible(pos);
  bool change = true;
    
  //if (valid && distance(-campos,pos) <= range) {
  if (valid && valid_x && valid_z && valid_y) {
    if(flags.x == -2) flags = getTypeSide(index);
    else change = false;
  }
  else {
    if(!valid || !valid_x) index.x = (len.x > 0 ? 1 : -1 ) * range + index.x;
    if(!valid || !valid_z) index.z = (len.z > 0 ? 1 : -1 ) * -range + index.z;
    //if(!valid || !valid_y) index.y = (len.y > 0 ? 1 : -1 ) * range + index.y;
    flags.x = -2;
  }
  
  if(change) dataset.data[id] = Data(float[3](index.x,index.y,index.z),flags.x,flags.y);

  if(change) return;
  if (flags.x <= 0 || flags.y <= 0 || !is_visible(pos)) return;

  uint unique  = atomicCounterIncrement(instanceCount);
  outputset.data[unique] = Data(float[3](pos.x,pos.y,pos.z),flags.x,flags.y);
}