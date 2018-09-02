const zerosVector3f = [0f0,0,0]
const onesVector3f = [1f0,1,1]

#-------------------------------------------------------------------------------------------------
# Base implementations for StaticArray

Base.isless(a::StaticArray{Tuple{N},T,1}, b::StaticArray{Tuple{N},T,1}) where {N,T<:Number} = begin
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
Vec2(x::T) where {T} = Vector2{T}(x,x)
Vec3(x::T) where {T} = Vector2{T}(x,x,x)
Vec4(x::T) where {T} = Vector2{T}(x,x,x,x)

# copy
Vec2(v::Vector2{T}) where {T} = Vector2{T}(v.x,v.y)
Vec3(v::Vector3{T}) where {T} = Vector3{T}(v.x,v.y,v.z)
Vec4(v::Vector4{T}) where {T} = Vector4{T}(v.x,v.y,v.z,v.w)

# reduce
Vec2(v::Union{Vector3{T}, Vector4{T}}) where {T} = Vector2{T}(v.x,v.y)
Vec3(v::Vector4{T}) where {T} = Vector3{T}(v.x,v.y,v.z)

# extend
Vec3(v::Vector2{T}) where {T<:Number} = Vector3{T}(v.x,v.y,0)
Vec4(v::Vector2{T}) where {T<:Number} = Vector4{T}(v.x,v.y,0,0)
Vec4(v::Vector3{T}) where {T<:Number} = Vector4{T}(v.x,v.y,v.z,0)

# combine
Vec3(v::Vector2{T},z::Number) where {T<:Number} = Vector3{T}(v.x,v.y,z)
Vec4(v::Vector3{T},w::Number) where {T<:Number} = Vector4{T}(v.x,v.y,v.z,w)
Vec4(v1::Vector2{T},v2::Vector2{T}) where {T} = Vector4{T}(v1.x,v1.y,v2.x,v2.y)

# operate
Base.:+(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:+.(v1,v2))
Base.:-(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:-.(v1,v2))
Base.:*(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:*.(v1,v2))
Base.:/(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:/.(v1,v2))
Base.:\(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:\.(v1,v2))
Base.:^(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:^.(v1,v2))
Base.:%(v1::VectorType{N, T}, v2::VectorType{N, T}) where {N, T<:Number} = Vector{N, T}(Base.:%.(v1,v2))

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

Vec3f(v::Vector2{T},z::Number) where {T<:Number} = Vec3(v,z)
Vec4f(v::Vector3{T},w::Number) where {T<:Number} = Vec4(v,w)
Vec4f(v1::Vector2{T},v2::Vector2{T}) where {T<:Number} = Vec4(v1,v2)

Vec3i(v::Vector2{T},z::Number) where {T<:Number} = Vec3(v,z)
Vec4i(v::Vector3{T},w::Number) where {T<:Number} = Vec4(v,w)
Vec4i(v1::Vector2{T},v2::Vector2{T}) where {T<:Number} = Vec4(v1,v2)

Vec3u(v::Vector2{T},z::Number) where {T<:Number} = Vec3(v,z)
Vec4u(v::Vector3{T},w::Number) where {T<:Number} = Vec4(v,w)
Vec4u(v1::Vector2{T},v2::Vector2{T}) where {T<:Number} = Vec4(v1,v2)