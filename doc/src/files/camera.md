# [camera.jl](@id camera.jl)

Camera script with defines camera object, its functions, events and creates a single camera object for whole szene.

```@docs
App.rezizeWindow(width,height)
```

```@docs
App.Camera
```
 
```@docs
App.forward(camera::App.Camera)
```

```@docs
App.right(camera::App.Camera)
```

```@docs
App.up(camera::App.Camera)
```

```@docs
App.setProjection(camera::App.Camera, m::AbstractArray)
```

```@docs
App.setView(camera::App.Camera, m::AbstractArray)
```

```@docs
App.OnKey(window, key::Number, scancode::Number, action::Number, mods::Number)
```

```@docs
App.OnMouseKey(window, key::Number, action::Number, mods::Number)
```

```@docs
App.OnCursorPos(window, x::Number, y::Number)
```

```@docs
App.rotate(camera::App.Camera, rotation::AbstractArray)
```

```@docs
App.move(camera::App.Camera, position::AbstractArray)
```

```@docs
App.OnRotate(camera::App.Camera)
```

```@docs
App.setPosition(camera::App.Camera, position::AbstractArray)
```

```@docs
App.OnMove(camera::App.Camera, key::Symbol, m::Number)
```

```@docs
App.Update(camera::App.Camera)
```

```@docs
App.OnUpdate(camera::App.Camera)
```
