# [lib_math.jl](@id lib_math.jl)

libs:
* [Quaternions](https://github.com/JuliaGeometry/Quaternions.jl)
* [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl)

includes:
* [matrix.jl](@ref)
* [vector.jl](@ref)

```@docs
App.frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)
```

```@docs
App.projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)
```

```@docs
App.projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)
```

```@docs
App.translation{T}(t::Array{T,1})
```

```@docs
App.rotation{T}(r::Array{T,1})
```

```@docs
App.rotation{T}(q::Quaternions.Quaternion{T})
```

```@docs
App.computeRotation{T}(r::Array{T,1})
```

```@docs
App.scaling{T}(s::Array{T})
```

```@docs
App.transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})
```

```@docs
App.ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)
```

```@docs
App.lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})
```

```@docs
App.forward{T}(m::Array{T, 2})
```

```@docs
App.right{T}(m::Array{T, 2})
```

```@docs
App.up{T}(m::Array{T, 2})
```

