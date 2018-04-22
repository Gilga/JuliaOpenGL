# [lib_opengl.jl](@id lib_opengl.jl)

using ModernGL

glGenOne(glGenFn)

glGenBuffer()
glGenVertexArray()
glGenTexture()

glGetIntegerv_e()

get_glsl_version_string()

glErrorMessage()

glCheckError()

```@docs
App.getInfoLog(obj::ModernGL.GLuint)
```

```@docs
App.validateShader(shader)
```

```@docs
App.compileShader(name, shader,source)
```

```@docs
App.createShader(source::Tuple{Symbol,String}, typ)
```

```@docs
App.createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)
```

```@docs
App.createcontextinfo()
```
