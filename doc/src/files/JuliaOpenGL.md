# [JuliaOpenGL.jl](@id JuliaOpenGL.jl)

* [Definitions](#Definitions-1)
* [Program Init](#Program-Init-1)
* [Szene Init](@ref szene-init)
  * [Camera](#Camera-1)
  * [Mesh](#Mesh-1)
  * [Textures](#Textures-1)
  * [Shader](#Shader-1)
  * [Other](#Other-1)
  * [Render Loop](@ref render-loop)
  
```@docs
App
```

## Main Call
```
function main()
  App.run()
end
```

## Program Run
```@docs
App.run()
```

## Definitions

```@docs
App.setMode(program, name, mode)
```

```@docs
App.setFrustumCulling(load)
```

```@docs
App.chooseRenderMethod(method)
```

```@docs
App.checkForUpdate()
```

```@docs
App.useProgram(program)
```

```@docs
App.setMatrix(program, name, m)
```

```@docs
App.setMVP(program, mvp, old_program)
```

## Program Init

* Output Program Info (Print)
* OS X-specific GLFW hints to initialize the correct version of OpenGL
* Create a windowed mode window and its OpenGL context
* Make the window's context current
* Set windows size and viewport - seems to be necessary to guarantee that window > 0
* Window settings - SwapInterval - intervall between canvas images (min. 2 images)
* Graphcis Settings - show opengl debug report
* Set OpenGL Version (Major,Minor) - 4.6
* Set OpenGL Event Callbacks
* Show window
* Output OpenGL Info (Print)

## [Szene Init](@id szene-init)

Chooses render method
```@docs
App.chooseRenderMethod
```
### Camera
* Sets Camera position
* Sets Camera projection
* Creates/Sets Frustum
* Updates Camera

### Mesh
Creates and Links Mesh Data

### Textures
uploads this [texture](https://github.com/Gilga/JuliaOpenGL/blob/master/blocks.png).

### Shader
* Creates Shader
* Sets Shader Attributes
* Sets Uniform Variables (like MVP from Camera)

### Other
Sets OpenGL Render Options

## [Render Loop](@id render-loop)
* Begin Render Loop while (window is open)
* Event OnUpdate -> setMVP
* Show frames
* update counters/timers
* Clear szene background
* Bind Shader Program
* Wirefram Option
* Bind Vertex Array
* Draw:
```
if isValid(mychunk) 
  (...)
  if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS)  # + geometry shader => very fast!
  elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES)  # fast
  elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES)  # faster than 2 (only useful for groups)
  elseif RENDER_METHOD > 3
    for b in getFilteredChilds(mychunk)  # thats slow!
      glDrawElements(GL_TRIANGLES)
    end
  end
  (...)
```
For more information about render algorithms look [here](@ref algorithm).
* Unbind Vertex Array
* Swap front and back buffers
* Poll for and process events
* Sleep function
* End Render Loop
* destroy Window 
* terminate
