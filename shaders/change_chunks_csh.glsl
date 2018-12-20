#import "globals.glsl"
#import "landscape.glsl"

precision highp float;
precision highp int;
precision highp sampler2DShadow;

uniform int STATE = 0;
layout(binding = 0) uniform sampler2DShadow iDepthMap;

uniform int iCulling = 0;

layout (local_size_x = $CHUNK_SIZE) in; //, local_size_y = 4, local_size_z = 4

layout(binding = 0, offset = 0) uniform atomic_uint DISPATCH;
layout(binding = 1, offset = 0) uniform atomic_uint dispatchCount;
layout(binding = 2, offset = 0) uniform atomic_uint instanceCount;
layout(binding = 3, offset = 0) uniform atomic_uint counter;

layout(std430, binding = 0) buffer Buffer {
  Data data[];
} dataset;

layout(std430, binding = 1) buffer Output {
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
  uint unique = 0;
  uint dispatch = 0;
  vec3 index = vec3(0);
  MapData flags = MapData(0,0,0);
  vec3 pos = vec3(0);
  bool visible = false;
  Data data = createData();
  
  if(STATE < 2){
    // RESET
    if(STATE == -1) {
      if(ident == 0) atomicCounterExchange(DISPATCH, uint(float(MAXSIZE)/128.0)); // dispatch now
      return;
    }
  
    if(ident == 0) atomicCounterExchange(instanceCount, 0);
  
    // INIT
    if(STATE == 0){
      if(ident == 0) atomicCounterExchange(dispatchCount, 0);
      
      index = getIndex(ident);
      flags = getTypeSide2(index);
      pos = translate(index);
      visible = is_visible(pos);

      if (flags.height >= 0) {
        dispatch = atomicCounterIncrement(dispatchCount);
        dataset.data[dispatch] = data = createData(index,flags.type,flags.sides,flags.height);
      
        if (visible) {
          unique  = atomicCounterIncrement(instanceCount);
          outputset.data[unique] = createData(pos,flags.type,flags.sides,flags.height);
        }
      }
      
      // set new dispatch
      if(ident == LAST) {
        dispatch = uint(round(float(atomicCounter(dispatchCount))/gl_WorkGroupSize.x));
        //if(dispatch<=0) dispatch=1; // DO NOT REMOVE THIS LINE OR DISPATCH RESET WILL FAIL! (FIXED)
        atomicCounterExchange(DISPATCH, dispatch); // dispatch now
      }
      
      return;
    }
    else {
      data = dataset.data[ident];
      index = vec3(data.pos[0],data.pos[1],data.pos[2]);
      flags = MapData(data.type,data.sides,data.height);
      //index = getIndex(ident) + iCenter * COLSIZE * 0;
      //flags = getTypeSide2(index);
      pos = translate(index);
      visible = is_visible(pos);
    }
    
    /*
    float d = COLSIZE*0.78;
    vec3 campos = vec3(iCamPos.x,0,iCamPos.z); //+vec3(d,COLSIZE*0.5*0,d)*vec3(sin(iCamAng.x),sin(iCamAng.y)*0,cos(iCamAng.x));

    vec3 len=-campos-pos;
    
    float range = COLSIZE;
    
    bool valid_x = abs(len.x) <= range;
    bool valid_z = abs(len.z) <= range;
    bool valid_y = abs(len.y) <= range;

    bool change = true;
      
    //if (valid && distance(-campos,pos) <= range) {
    if (valid_x && valid_z && valid_y) {
      if(flags.type == -2) {
        flags = getTypeSide2(index);
        //index.y=flags.height;
      }
      else change = false;
    }
    else {
      if(!valid_x) index.x = (len.x > 0 ? 1 : -1 ) * range + index.x;
      if(!valid_z) index.z = (len.z > 0 ? 1 : -1 ) * -range + index.z;
      //if(!valid || !valid_y) index.y = (len.y > 0 ? 1 : -1 ) * range + index.y;
      flags.type = -2;
    }
    
    if(change) {
      if(STATE == 0) dataset.data[dispatch] = Data(float[3](index.x,index.y,index.z),flags.type,flags.sides,-1);
      else dataset.data[ident] = Data(float[3](index.x,index.y,index.z),flags.type,flags.sides,-1);
    }
    if(change) return;
    */
    if (flags.height < 0 || !visible) return;
    
    if(iCulling == 1) {
      vec2 zNearFar = vec2(gl_DepthRange.near,gl_DepthRange.far);

      float radius = 1.5;
      vec3 view_center = (iView * vec4(pos, 1.0)).xyz;
      float nearest_z = view_center.z + radius;
      
      // Sphere clips against near plane, just assume visibility.
      if (nearest_z >= -zNearFar.x) return;
      
      vec3 view_center_norm = normalize(view_center);
      
      float az_plane_horiz_length = length(view_center.xz);
      float az_plane_vert_length = length(view_center.yz);
      vec2 az_plane_horiz_norm = view_center.xz / az_plane_horiz_length;
      vec2 az_plane_vert_norm = view_center.yz / az_plane_vert_length;
      
      vec2 t = sqrt(vec2(az_plane_horiz_length, az_plane_vert_length) * vec2(az_plane_horiz_length, az_plane_vert_length) - radius * radius);
      vec4 w = vec4(t, radius, radius) / vec2(az_plane_horiz_length, az_plane_vert_length).xyxy;
      
      // Fairly optimized way to apply the two rotation matrices.
      // Since the two rotation matrices are almost the same (just flipped sign of sin()), we can reuse some computation.
      vec4 horiz_cos_sin = az_plane_horiz_norm.xyyx * t.x * vec4(w.xx, -w.z, w.z);
      vec4 vert_cos_sin  = az_plane_vert_norm.xyyx * t.y * vec4(w.yy, -w.w, w.w);

      vec2 horiz0 = horiz_cos_sin.xy + horiz_cos_sin.zw;
      vec2 horiz1 = horiz_cos_sin.xy - horiz_cos_sin.zw;
      vec2 vert0  = vert_cos_sin.xy + vert_cos_sin.zw;
      vec2 vert1  = vert_cos_sin.xy - vert_cos_sin.zw;

      // This assumes the projection matrix doesn't do translations or any other transforms first.
      vec4 projected = -0.5 * vec4(iProj[0][0], iProj[0][0], iProj[1][1], iProj[1][1]) *
          vec4(horiz0.x, horiz1.x, vert0.x, vert1.x) /
          vec4(horiz0.y, horiz1.y, vert0.y, vert1.y) + 0.5;

      // Since we know which way we're rotating to find the tangent points, we already know which one is min and max.
      vec2 min_xy = projected.yw;
      vec2 max_xy = projected.xz;
      
      // Project our nearest Z value in view space.
      vec2 zw = mat2(iProj[2].zw, iProj[3].zw) * vec2(nearest_z, 1.0);
      
      float dist = 0.5; //1.0/(length(-iCamPos-pos));
      
      nearest_z = 1 + (-1 + zw.x / zw.y) * clamp(dist,0.5,1.0);

      //vec4 clip_space_pos = iProj * vec4(view_center+vec3(0,0,radius),1.0);
      //nearest_z = 0.5 * (clip_space_pos.z / clip_space_pos.w) + 0.5;
      //nearest_z = clip_space_pos.z / clip_space_pos.w;
      //nearest_z = (((far-near) * nearest_z) + near + far) / 2.0;
       
      // Compute required LOD factor for shadow lookup.
      vec2 diff_pix = (max_xy - min_xy); // * textureSize(iDepthMap, 0);
      float max_diff = max(max(diff_pix.x, diff_pix.y), 1.0);
      float lod = ceil(log2(max_diff));

      vec2 mid_pix = 0.5 * (max_xy + min_xy);
      float tdepth = clamp(textureLod(iDepthMap, vec3(mid_pix, nearest_z), lod) ,0,1);
      //float tdepth = clamp(texture(iDepthTexture,mid_pix).x,0,1);
      
      //if(mid_pix.x <= 0.45 || mid_pix.x >= 0.55) return;
      //if(tdepth<=nearest_z) return; // Test visibility.
      if(tdepth<=0.0) return; // Test visibility.
    }
    
    unique  = atomicCounterIncrement(instanceCount);
    if(unique==0) { flags.type=9999; flags.sides=255; } // SUN
    
    outputset.data[unique] = createData(pos,flags.type,flags.sides,flags.height);
  
  } else {
    //if(ident == 0) atomicCounterExchange(counter, 0);
    //if(ident == 0) atomicCounterExchange(instanceCount, 0);
    //if(atomicCounter(counter) >= atomicCounter(instanceCount)) return;
    
    data = dataset.data[ident];
    pos = vec3(data.pos[0],data.pos[1],data.pos[2]);
    flags = MapData(data.type,data.sides,data.height);
 
    //unique = atomicCounterIncrement(instanceCount);
    outputset.data[ident] = createData(pos,flags.type,flags.sides,flags.height);
  }
}