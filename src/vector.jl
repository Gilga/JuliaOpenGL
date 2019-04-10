__precompile__(false)

export zerosVector3f
export onesVector3f

const zerosVector3f = Float32[0,0,0]
const onesVector3f = Float32[1,1,1]

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

# set 1
Vector1{T}(x::T=T(0)) where {T} = Vector1{T}(x)
Vector2{T}(x::T=T(0)) where {T} = Vector2{T}(x,x)
Vector3{T}(x::T=T(0)) where {T} = Vector3{T}(x,x,x)
Vector4{T}(x::T=T(0)) where {T} = Vector4{T}(x,x,x,x)
Vector3{T}(x::T,y::T) where {T} = Vector3{T}(x,y,0)
Vector4{T}(x::T,y::T) where {T} = Vector4{T}(x,y,x,y)
Vector4{T}(x::T,y::T,z::T) where {T} = Vector4{T}(x,y,z,0)

# set 2
Vector1(x::T=T(0)) where {T} = Vector1{T}(x)
Vector2(x::T=T(0)) where {T} = Vector2{T}(x)
Vector3(x::T=T(0)) where {T} = Vector3{T}(x)
Vector4(x::T=T(0)) where {T} = Vector4{T}(x)
Vector3(x::T,y::T) where {T} = Vector3{T}(x,y)
Vector4(x::T,y::T) where {T} = Vector4{T}(x,y)
Vector4(x::T,y::T,z::T) where {T} = Vector4{T}(x,y,z)

# copy & reduce
Vector1(v::Union{Vector1{T}, Vector2{T}, Vector3{T}, Vector4{T}}) where {T} = Vector1{T}(v.x)
Vector2(v::Union{Vector2{T}, Vector3{T}, Vector4{T}}) where {T} = Vector2{T}(v.x,v.y)
Vector3(v::Union{Vector3{T}, Vector4{T}}) where {T} = Vector3{T}(v.x,v.y,v.z)
Vector4(v::Vector4{T}) where {T} = Vector4{T}(v.x,v.y,v.z,v.w)

# extend & combine
Vector2(v::Vector1{T},y::T=T(0)) where {T<:Number} = Vector3{T}(v.x,y)
Vector3(v::Vector2{T},z::T=T(0)) where {T<:Number} = Vector3{T}(v.x,v.y,z)
Vector4(v::Vector2{T},z::T=T(0),w::T=T(0)) where {T<:Number} = Vector4{T}(v.x,v.y,z,w)
Vector4(v1::Vector2{T},v2::Vector2{T}) where {T} = Vector4{T}(v1.x,v1.y,v2.x,v2.y)
Vector4(v::Vector3{T},w::T=T(0)) where {T<:Number} = Vector4{T}(v.x,v.y,v.z,w)

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

export Vector
export Vector1
export Vector2
export Vector3
export Vector4

#-------------------------------------------------------------------------------------------------

const Vector2n = Vector2{Number}
const Vector3n = Vector3{Number}
const Vector4n = Vector4{Number}

export Vector2n
export Vector3n
export Vector4n

const Vector2g = Vector2{Integer}
const Vector3g = Vector3{Integer}
const Vector4g = Vector4{Integer}

export Vector2g
export Vector3g
export Vector4g

const Vector2f = Vector2{Float32}
const Vector3f = Vector3{Float32}
const Vector4f = Vector4{Float32}

export Vector2f
export Vector3f
export Vector4f

const Vector2h = Vector2{Float16}
const Vector3h = Vector3{Float16}
const Vector4h = Vector4{Float16}

export Vector2h
export Vector3h
export Vector4h

const Vector2d = Vector2{Float64}
const Vector3d = Vector3{Float64}
const Vector4d = Vector4{Float64}

export Vector2d
export Vector3d
export Vector4d

const Vector2i = Vector2{Int32}
const Vector3i = Vector3{Int32}
const Vector4i = Vector4{Int32}

export Vector2i
export Vector3i
export Vector4i

const Vector2u = Vector2{UInt32}
const Vector3u = Vector3{UInt32}
const Vector4u = Vector4{UInt32}

export Vector2u
export Vector3u
export Vector4u

const Vector2l = Vector2{Int64}
const Vector3l = Vector3{Int64}
const Vector4l = Vector4{Int64}

export Vector2l
export Vector3l
export Vector4l

const Vector2c = Vector2{Int8}
const Vector3c = Vector3{Int8}
const Vector4c = Vector4{Int8}

export Vector2c
export Vector3c
export Vector4c

const Vector2x = Vector2{UInt8}
const Vector3x = Vector3{UInt8}
const Vector4x = Vector4{UInt8}

export Vector2x
export Vector3x
export Vector4x

const Vector2s = Vector2{Int16}
const Vector3s = Vector3{Int16}
const Vector4s = Vector4{Int16}

export Vector2s
export Vector3s
export Vector4s

const Vector2t = Vector2{UInt16}
const Vector3t = Vector3{UInt16}
const Vector4t = Vector4{UInt16}

export Vector2t
export Vector3t
export Vector4t

const Vector2b = Vector2{Bool}
const Vector3b = Vector3{Bool}
const Vector4b = Vector4{Bool}

export Vector2b
export Vector3b
export Vector4b

#-------------------------------------------------------------------------------------------------

const Vec2 = Vector2
const Vec3 = Vector3
const Vec4 = Vector4

export Vec2
export Vec3
export Vec4

const Vec2n = Vector2n
const Vec3n = Vector3n
const Vec4n = Vector4n

export Vec2n
export Vec3n
export Vec4n

const Vec2g = Vector2g
const Vec3g = Vector3g
const Vec4g = Vector4g

export Vec2g
export Vec3g
export Vec4g

const Vec2f = Vector2f
const Vec3f = Vector3f
const Vec4f = Vector4f

export Vec2f
export Vec3f
export Vec4f

const Vec2d = Vector2d
const Vec3d = Vector3d
const Vec4d = Vector4d

export Vec2d
export Vec3d
export Vec4d

const Vec2i = Vector2i
const Vec3i = Vector3i
const Vec4i = Vector4i

export Vec2i
export Vec3i
export Vec4i

const Vec2u = Vector2u
const Vec3u = Vector3u
const Vec4u = Vector4u

export Vec2u
export Vec3u
export Vec4u

const Vec2l = Vector2l
const Vec3l = Vector3l
const Vec4l = Vector4l

export Vec2l
export Vec3l
export Vec4l
