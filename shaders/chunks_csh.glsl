#import "globals.glsl"
#import "landscape.glsl"

layout (local_size_x = 128) in; //, local_size_y = 4, local_size_z = 4

// Can also do atomic operations on an SSBO.
// instanceCount in indirect draw buffer is found at offset = 4.
layout(binding = 0, offset = 0) uniform atomic_uint instanceCount;
layout(binding = 1, offset = 0) uniform atomic_uint dispatch;

layout(std430, binding = 0) writeonly buffer Output {
  Data data[];
} outputset;

void main() {
  uint ident  = gl_GlobalInvocationID.x;
  
  if(ident == 0) atomicCounterExchange(instanceCount, 0);
  
  float i = ident;
  float y = floor(i/ROWSIZE);
  float z = floor((i-y*ROWSIZE)/COLSIZE);
  float x = i-y*ROWSIZE-z*COLSIZE;
  
  vec3 index = vec3(x,y,z);
  vec2 flags = getTypeSide(index);
  
  uint unique  = atomicCounterIncrement(instanceCount);
  outputset.data[unique] = Data(float[3](index.x,index.y,index.z),flags.x,flags.y);
  atomicCounterExchange(dispatch, uint(round(float(unique)/gl_WorkGroupSize.x)));
}