# [libs.jl](@id libs.jl)

using Compat: uninitialized, Nothing, Cvoid, AbstractDict
using Images
using ImageMagick

displayInYellow(s) = string("\x1b[93m",s,"\x1b[0m")
displayInRed(s) = string("\x1b[91m",s,"\x1b[0m")

include("lib_window.jl")
include("lib_opengl.jl")
include("lib_math.jl")
include("lib_time.jl")

include("cubeData.jl")
include("camera.jl")
include("frustum.jl")
include("chunk.jl")
include("mesh.jl")
include("texture.jl")

```@docs
App.waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)
```

```@docs
App.fileGetContents(path::String, tryCount=100, tryWait=0.1)
```

```@docs
App.UpdateCounters()
```

```@docs
App.showFrames()
```
