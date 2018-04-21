# chunk.jl

```@docs
App.HeptaOrder{T}

```

```@docs
App.Block(pos=App.Vec3f,typ=0)
```
 
```@docs
App.Chunk(len::Integer)
```

```@docs
App.clean(this::Union{Void,App.Chunk})
```

```@docs
App.isType(this::App.Block, typ)
```

```@docs
App.isValid(this::App.Chunk) 
```

```@docs
App.isSeen(this::App.Block)
```

```@docs
App.resetSides()
```

```@docs
App.resetSides(this::App.Block)
```

```@docs
App.hideUnseen(this::App.Chunk)
```

```@docs
App.setFlag(this::App.Block, flag::Unsigned, add::Bool)
```

```@docs
App.isActive(this::App.Block)
```

```@docs
App.isVisible(this::App.Block)
```

```@docs
App.isSurrounded(this::App.Block)
```

```@docs
App.isValid(this::App.Block)
```

```@docs
App.setActive(this::App.Block, active::Bool)
```

```@docs
App.setVisible(this::App.Block, visible::Bool)
```

```@docs
App.setSurrounded(this::App.Block, surrounded::Bool)
```

```@docs
App.hideType(this::App.Chunk, typ::Integer)
```

```@docs
App.removeType(this::App.Chunk, typ::Integer)
```

```@docs
App.showAll(this::App.Chunk)
```

```@docs
App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)
```

```@docs
App.setFilteredChilds(this::App.Chunk, r::Array{App.Block,1})
```

```@docs
App.getFilteredChilds(this::App.Chunk)
```

```@docs
App.getActiveChilds(this::App.Chunk)
```

```@docs
App.getVisibleChilds(this::App.Chunk)
```

```@docs
App.getValidChilds(this::App.Chunk)
```

```@docs
App.getData(this::App.Block)
```

```@docs
App.getData(this::App.Chunk)
```

```@docs
App.update(this::App.Chunk)
```

```@docs
App.createSingle(this::App.Chunk)
```

```@docs
App.createExample(this::App.Chunk)
```

```@docs
App.createLandscape(this::App.Chunk)
```
