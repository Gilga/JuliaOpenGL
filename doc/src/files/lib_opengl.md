# lib_opengl.jl

using ModernGL

glGenOne(glGenFn)

glGenBuffer() = glGenOne(glGenBuffers)
glGenVertexArray() = glGenOne(glGenVertexArrays)
glGenTexture() = glGenOne(glGenTextures)

glGetIntegerv_e(name::GLenum) = begin r=GLint[0]; glGetIntegerv(name,r); r[] end

getInfoLog(obj::GLuint)

validateShader(shader)

glErrorMessage()

glCheckError(actionName="")

compileShader(name, shader,source)

createShader(source::Tuple{Symbol,String}, typ)

createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)

createcontextinfo()

get_glsl_version_string()
