# lib_math.jl

using Quaternions
using StaticArrays
#using ArrayFire

include("matrix.jl")
include("vector.jl")

frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)

projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)

projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)

translation{T}(t::Array{T,1})

rotation{T}(r::Array{T,1})

rotation{T}(q::Quaternion{T})

computeRotation{T}(r::Array{T,1})

scaling{T}(s::Array{T})

transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})

ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)

lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})

forward{T}(m::Array{T, 2})

right{T}(m::Array{T, 2})

up{T}(m::Array{T, 2})

