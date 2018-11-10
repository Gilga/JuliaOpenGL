abstract type Object end

"""
  Occlusion
  - degrees come from sides of a plane (camera view)
  - check object visible inside list (degree check)
  - if not visible do not set
  - set visible object with its degree sides which occludes everything else
  - 2 Arrays 1-220 (-10°-190°) for X and Y: 220 * 220 = 48400 degrees
  - Z is not needed, it changes X and Y degrees
"""
function occlusion(blocks)
  spectrum = Array{Union{Array{Object,1},Nothing}}(undef, 220, 220)
  fill!(spectrum, nothing)
  
  #currentBlock.rightTop
  #currentBlock.rightBottom
  #currentBlock.leftTop
  #currentBlock.leftBottom
  
  #currentBlock.rightTop * z_distance
  #...
  
  #loop:
  # current object degree sides are inside a objects shadow?
  #if spectrum[Y][X] != nothing continue # skip current object
  #else
  # loop2: set all degrees inside objects shadow (frustum)
  #end
  
  # search3D_spiral(block_coordinates + player_position)
  # projection_orthographic(-w, w, -h, h, znear, zfar)
  #u = atan(x / z)
  #v = atan(y / z)
  #atan(u/v)
  #a = tan(fovy * pi / 360) * (w/h)
end

occlusion(nothing)