module Math

using LinearAlgebra
using Quaternions
using StaticArrays
using Distances #euclidean
#using ArrayFire

include("matrix.jl")
include("vector.jl")

"""
TODO
"""
function frustum(left::T, right::T, bottom::T, top::T, znear::T, zfar::T) where {T}
  (right == left || bottom == top || znear == zfar) && return eye(T,4,4)
  T[
    2*znear/(right-left) 0 0 0
    0 2*znear/(top-bottom) 0 0
    (right+left)/(right-left) (top+bottom)/(top-bottom) (-(zfar+znear)/(zfar-znear)) -(2*znear*zfar) / (zfar-znear)
    0 0 -1 0
  ]
end

export frustum

"""
TODO
"""
function projection_perspective(fovy::T, aspect::T, znear::T, zfar::T) where {T}
  (znear == zfar) && error("znear ($znear) must be different from tfar ($zfar)")
  zfn = 1/(zfar-znear)

  t = tan(fovy * 0.5)
  h = T(tan(fovy * pi / 360) * znear)
  w = T(h * aspect)

  left = -w
  right = w
  bottom = -h
  top = h

  frustum(-w, w, -h, h, znear, zfar)
end

export projection_perspective

"""
TODO
"""
function projection_orthographic(left::T,right::T,bottom::T,top::T,znear::T,zfar::T) where {T}
  (right == left || bottom == top || znear == zfar) && return eye(T,4,4)
  T[
    2/(right-left) 0 0 0
    0 2/(top-bottom) 0 0
    0 0 -2/(zfar-znear) 0
    -(right+left)/(right-left) -(top+bottom)/(top-bottom) -(zfar+znear)/(zfar-znear) 1
  ]
end

export projection_orthographic

"""
TODO
"""
function projection_orthographic(fovy::T, aspect::T, znear::T, zfar::T) where {T}
  (znear == zfar) && error("znear ($znear) must be different from tfar ($zfar)")

  #t = tan(fovy * 0.5)
  h = T(tan(fovy * pi / 360) * znear)
  w = T(h * aspect)

  left = -w
  right = w
  bottom = -h
  top = h

  projection_orthographic(-w, w, -h, h, znear, zfar)
end

"""
TODO
"""
function translation(t::Array{T,1}) where {T}
  lt = length(t)
  T[
    1 0 0 (lt < 1 ? 0 : t[1])
    0 1 0 (lt < 2 ? 0 : t[2])
    0 0 1 (lt < 3 ? 0 : t[3])
    0 0 0 (lt < 4 ? 1 : t[4])
  ]
end

export translation

"""
TODO
"""
function rotation(r::Array{T,1}) where {T}
  lr = length(r)
  T[
    1 0 0 0
    0 1 0 0
    0 0 1 0
    (lr < 1 ? 0 : r[1]) (lr < 2 ? 0 : r[2]) (lr < 3 ? 0 : r[3]) (lr < 4 ? 1 : r[4])
  ]
end

export rotation

"""
TODO
"""
function rotation(q::Quaternion{T}) where {T}
  sx, sy, sz = 2q.s*q.v1,  2q.s*q.v2,   2q.s*q.v3
  xx, xy, xz = 2q.v1^2,    2q.v1*q.v2,  2q.v1*q.v3
  yy, yz, zz = 2q.v2^2,    2q.v2*q.v3,  2q.v3^2
  
  T[
      1-(yy+zz)  xy+sz        xz-sy        0
      xy-sz        1-(xx+zz)  yz+sx        0
      xz+sy        yz-sx        1-(xx+yy)  0
      0 0 0 1
  ]
end

"""
TODO
"""
function computeRotation(r::Array{T,1}) where {T}
  lr = length(r)
  (lr < 3) && error("rotation has less than 3 elements!")

  dirBackwards= T[-1,0,0]
  dirRight = T[0,0,1]
  dirUp = T[0,1,0] #cross(dirRight, dirBackwards)
  
  q = qrotation(dirRight, r[3]) * qrotation(dirUp, r[1]) * qrotation(dirBackwards, r[2])

  #q = qrotation(T[1,1,1],0)
  #if lr<3 q = qrotation(dirRight, r[3]) end
  #if lr<1 q *= qrotation(dirUp, r[1]) end
  #if lr<2 q *= qrotation(dirBackwards, r[2]) end

  rotation(q)
end

export computeRotation

"""
TODO
"""
function scaling(s::Array{T}) where {T}
  ls = length(s)
  T[
    (ls<1 ? 1 : s[1]) 0 0 0
    0 (ls<2 ? 1 : s[2]) 0 0
    0 0 (ls<3 ? 1 : s[3]) 0
    0 0 0 (ls<4 ? 1 : s[4])
  ]
end

export scaling

"""
TODO
"""
function transform(t::Array{T,1},r::Array{T,1},s::Array{T,1}) where {T}
#=
  lt = length(t)
  lr = length(r)
  ls = length(s)
  T[
    (ls<1?1:s[1]) 0 0 (lt<1?0:t[1])
    0 (ls<2?1:s[2]) 0 (lt<2?0:t[2])
    0 0 (ls<3?1:s[3]) (lt<3?0:t[3])
    (lr<1?0:r[1]) (lr<2?0:r[2]) (lr<3?0:r[3]) (lt<4?1:t[4])*(lr<4?1:r[4])*(ls<4?1:s[4])
  ]
=#
  translation(t)*computeRotation(r)*scaling(s)
end

export transform

"""
TODO
"""
function ViewRH(eye::Array{T,1}, yaw::T, pitch::T) where {T}
  (length(eye) < 3) && error("eye has less than 3 elements!")

  # If the pitch and yaw angles are in degrees,
  # they need to be converted to radians. Here
  # I assume the values are already converted to radians.
  cosPitch = cos(pitch)
  sinPitch = sin(pitch)
  cosYaw = cos(yaw)
  sinYaw = sin(yaw)

  xaxis = T[ cosYaw, 0, -sinYaw ]
  yaxis = T[ sinYaw * sinPitch, cosPitch, cosYaw * sinPitch ]
  zaxis = T[ sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw ]
  eaxis = T[ -dot(xaxis,eye), -dot(yaxis,eye), -dot(zaxis,eye) ]

  # Create a 4x4 view matrix from the right, up, forward and eye position vectors
  T[
    xaxis[1] yaxis[1] zaxis[1] eaxis[1]*0
    xaxis[2] yaxis[2] zaxis[2] eaxis[2]*0
    xaxis[3] yaxis[3] zaxis[3] eaxis[3]*0
    eaxis[1]*1 eaxis[2]*1 eaxis[3]*1 1
  ]
end

export ViewRH

"""
TODO
"""
function lookat(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1}) where {T}
  (length(eye) < 3) && error("eye has less than 3 elements!")
  (length(lookAt) < 3) && error("lookAt has less than 3 elements!")
  (length(up) < 3) && error("up has less than 3 elements!")  
    
  zaxis  = normalize(eye-lookAt)
  xaxis  = normalize(cross(up,zaxis))
  yaxis  = normalize(cross(zaxis, xaxis))
  eaxis = T[ -dot(xaxis,eye), -dot(yaxis,eye), -dot(zaxis,eye) ]
  
  T[
      xaxis[1] yaxis[1] zaxis[1] 0;
      xaxis[2] yaxis[2] zaxis[2] 0;
      xaxis[3] yaxis[3] zaxis[3] 0;
      eaxis[1] eaxis[2] eaxis[3] 1
  ]
end

export lookat

"""
TODO
"""
forward(m::Array{T, 2}) where {T} = T[m[3,1],m[3,2],m[3,3]]

export forward

"""
TODO
"""
right(m::Array{T, 2}) where {T} = T[m[1,1],m[1,2],m[1,3]]

export right

"""
TODO
"""
up(m::Array{T, 2}) where {T} = T[m[2,1],m[2,2],m[2,3]]

export up

#=
template <typename T, precision P>
GLM_FUNC_QUALIFIER tquat<T, P> angleAxis(T const & angle, tvec3<T, P> const & v)
{
  tquat<T, P> Result(uninitialize);

  T const a(angle);
  T const s = glm::sin(a * static_cast<T>(0.5));

  Result.w = glm::cos(a * static_cast<T>(0.5));
  Result.x = v.x * s;
  Result.y = v.y * s;
  Result.z = v.z * s;
  return Result;
}

function mat4x4ToMat3x3{T}(q)
  qxx = (q.x * q.x)
  qyy = (q.y * q.y)
  qzz = (q.z * q.z)
  qxz = (q.x * q.z)
  qxy = (q.x * q.y)
  qyz = (q.y * q.z)
  qwx = (q.w * q.x)
  qwy = (q.w * q.y)
  qwz = (q.w * q.z)

  Result = Mat3x3(T)
  Result[0][0] = T(1) - T(2) * (qyy +  qzz);
  Result[0][1] = T(2) * (qxy + qwz);
  Result[0][2] = T(2) * (qxz - qwy);

  Result[1][0] = T(2) * (qxy - qwz);
  Result[1][1] = T(1) - T(2) * (qxx +  qzz);
  Result[1][2] = T(2) * (qyz + qwx);

  Result[2][0] = T(2) * (qxz + qwy);
  Result[2][1] = T(2) * (qyz - qwx);
  Result[2][2] = T(1) - T(2) * (qxx +  qyy);
  Result
end
=#

# glm::mat4 rotate = glm::transpose(glm::toMat4(m_Rotation));

end #Math