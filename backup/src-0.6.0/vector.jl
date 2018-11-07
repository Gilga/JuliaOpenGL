const zerosVector3f = [0f0,0,0]
const onesVector3f = [1f0,1,1]

#-------------------------------------------------------------------------------------------------
# Base implementations for StaticArray

Base.isless{N,T<:Number}(a::StaticArray{Tuple{N},T,1}, b::StaticArray{Tuple{N},T,1}) = begin
  for i=N:-1:1
    if a[i] < b[i] return true
    elseif a[i] > b[i] return false
    end
  end
  false
end

#-------------------------------------------------------------------------------------------------

VectorType{N, T} = FieldVector{N, T}

struct Vector1{T} <: VectorType{1, T}
  x::T
end

struct Vector2{T} <: VectorType{2, T}
  x::T
  y::T
end

struct Vector3{T} <: VectorType{3, T}
  x::T
  y::T
  z::T
end

struct Vector4{T} <: VectorType{4, T}
  x::T
  y::T
  z::T
  w::T
end

struct Vector{N, T}
  Vector{N,T}(x) where {N,T} = (N==4 ? Vector4{T} : N==3 ? Vector3{T} : N==2 ? Vector2{T} : VectorType{N, T})(x)
end

#-------------------------------------------------------------------------------------------------

# set
Vec2{T}(x::T) = Vector2{T}(x,x)
Vec3{T}(x::T) = Vector2{T}(x,x,x)
Vec4{T}(x::T) = Vector2{T}(x,x,x,x)

# copy
Vec2{T}(v::Vector2{T}) = Vector2{T}(v.x,v.y)
Vec3{T}(v::Vector3{T}) = Vector3{T}(v.x,v.y,v.z)
Vec4{T}(v::Vector4{T}) = Vector4{T}(v.x,v.y,v.z,v.w)

# reduce
Vec2{T}(v::Union{Vector3{T}, Vector4{T}}) = Vector2{T}(v.x,v.y)
Vec3{T}(v::Vector4{T}) = Vector3{T}(v.x,v.y,v.z)

# extend
Vec3{T<:Number}(v::Vector2{T}) = Vector3{T}(v.x,v.y,0)
Vec4{T<:Number}(v::Vector2{T}) = Vector4{T}(v.x,v.y,0,0)
Vec4{T<:Number}(v::Vector3{T}) = Vector4{T}(v.x,v.y,v.z,0)

# combine
Vec3{T<:Number}(v::Vector2{T},z::Number) = Vector3{T}(v.x,v.y,z)
Vec4{T<:Number}(v::Vector3{T},w::Number) = Vector4{T}(v.x,v.y,v.z,w)
Vec4{T}(v1::Vector2{T},v2::Vector2{T}) = Vector4{T}(v1.x,v1.y,v2.x,v2.y)

# operate
Base.:+{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:+.(v1,v2))
Base.:-{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:-.(v1,v2))
Base.:*{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:*.(v1,v2))
Base.:/{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:/.(v1,v2))
Base.:\{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:\.(v1,v2))
Base.:^{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:^.(v1,v2))
Base.:%{N, T<:Number}(v1::VectorType{N, T}, v2::VectorType{N, T}) = Vector{N, T}(Base.:%.(v1,v2))

#normalize
#normalize{N, T<:Number}(v::VectorType{N, T}) = Vector{N, T}(normalize(v))

#-------------------------------------------------------------------------------------------------

const Vector2f = Vector2{Float32}
const Vector3f = Vector3{Float32}
const Vector4f = Vector4{Float32}

const Vector2i = Vector2{Int32}
const Vector3i = Vector3{Int32}
const Vector4i = Vector4{Int32}

const Vector2u = Vector2{UInt32}
const Vector3u = Vector3{UInt32}
const Vector4u = Vector4{UInt32}

const Vector2d = Vector2{Integer}
const Vector3d = Vector3{Integer}
const Vector4d = Vector4{Integer}

const Vec2f = Vector2f
const Vec3f = Vector3f
const Vec4f = Vector4f

const Vec2i = Vector2i
const Vec3i = Vector3i
const Vec4i = Vector4i

const Vec2u = Vector2u
const Vec3u = Vector3u
const Vec4u = Vector4u

#-------------------------------------------------------------------------------------------------

Vec2f() = zeros(Vec2f)
Vec3f() = zeros(Vec3f)
Vec4f() = zeros(Vec4f)

Vec2i() = zeros(Vec2i)
Vec3i() = zeros(Vec3i)
Vec4i() = zeros(Vec4i)

Vec2u() = zeros(Vec2u)
Vec3u() = zeros(Vec3u)
Vec4u() = zeros(Vec4u)

#-------------------------------------------------------------------------------------------------

Vec3f{T<:Number}(v::Vector2{T},z::Number) = Vec3(v,z)
Vec4f{T<:Number}(v::Vector3{T},w::Number) = Vec4(v,w)
Vec4f{T<:Number}(v1::Vector2{T},v2::Vector2{T}) = Vec4(v1,v2)

Vec3i{T<:Number}(v::Vector2{T},z::Number) = Vec3(v,z)
Vec4i{T<:Number}(v::Vector3{T},w::Number) = Vec4(v,w)
Vec4i{T<:Number}(v1::Vector2{T},v2::Vector2{T}) =Vec4(v1,v2)

Vec3u{T<:Number}(v::Vector2{T},z::Number) = Vec3(v,z)
Vec4u{T<:Number}(v::Vector3{T},w::Number) = Vec4(v,w)
Vec4u{T<:Number}(v1::Vector2{T},v2::Vector2{T}) = Vec4(v1,v2)