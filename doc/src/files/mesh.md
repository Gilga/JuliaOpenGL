# [mesh.jl](@id mesh.jl)

```@docs
App.Transform
```

```@docs
App.MeshArray
```

```@docs
App.MeshData
```

```@docs
App.setAttributes(this::App.MeshArray, program, attrb)
```

```@docs
App.createBuffers(this::App.MeshData)
```

```@docs
App.setAttributes(this::App.MeshData, program)
```

```@docs
App.setDrawArray(this::App.MeshData, key::Symbol)
```

```@docs
App.setData(this::App.MeshArray, data, elems=0)
```

```@docs
App.linkData(this::App.MeshData, args...)
```

```@docs
App.upload(this::App.MeshArray)
```

```@docs
App.upload(this::App.MeshData)
```

```@docs
App.upload(this::App.MeshData, key::Symbol, data::AbstractArray)
```
