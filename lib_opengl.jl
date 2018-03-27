using ModernGL

function glGenOne(glGenFn)
  id = ModernGL.GLuint[0]
  glGenFn(1, id)
  glCheckError("generating a buffer, array, or texture")
  id[]
end

glGenBuffer() = glGenOne(ModernGL.glGenBuffers)
glGenVertexArray() = glGenOne(ModernGL.glGenVertexArrays)
glGenTexture() = glGenOne(ModernGL.glGenTextures)

glGetIntegerv_e(name::GLenum) = begin r=GLint[0]; ModernGL.glGetIntegerv(name,r); r[] end

function getInfoLog(obj::ModernGL.GLuint)
  # Return the info log for obj, whether it be a shader or a program.
  isShader = ModernGL.glIsShader(obj)
  getiv = isShader == ModernGL.GL_TRUE ? ModernGL.glGetShaderiv : ModernGL.glGetProgramiv
  getInfo = isShader == ModernGL.GL_TRUE ? ModernGL.glGetShaderInfoLog : ModernGL.glGetProgramInfoLog
  # Get the maximum possible length for the descriptive error message
  len = ModernGL.GLint[0]
  getiv(obj, ModernGL.GL_INFO_LOG_LENGTH, len)
  maxlength = len[]
  # TODO: Create a macro that turns the following into the above:
  # maxlength = @glPointer getiv(obj, GL_INFO_LOG_LENGTH, GLint)
  # Return the text of the message if there is any
  if maxlength > 0
    buffer = zeros(GLchar, maxlength)
    sizei = ModernGL.GLsizei[0]
    getInfo(obj, maxlength, sizei, buffer)
    len = sizei[]
    unsafe_string(pointer(buffer), len)
  else
    ""
  end
end
function validateShader(shader)
  success = ModernGL.GLint[0]
  ModernGL.glGetShaderiv(shader, ModernGL.GL_COMPILE_STATUS, success)
  success[] == ModernGL.GL_TRUE
end
function glErrorMessage()
# Return a string representing the current OpenGL error flag, or the empty string if there's no error.
  err = ModernGL.glGetError()
  err == ModernGL.GL_NO_ERROR ? "" :
  err == ModernGL.GL_INVALID_ENUM ? "GL_INVALID_ENUM: An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag." :
  err == ModernGL.GL_INVALID_VALUE ? "GL_INVALID_VALUE: A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag." :
  err == ModernGL.GL_INVALID_OPERATION ? "GL_INVALID_OPERATION: The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag." :
  err == ModernGL.GL_INVALID_FRAMEBUFFER_OPERATION ? "GL_INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag." :
  err == ModernGL.GL_OUT_OF_MEMORY ? "GL_OUT_OF_MEMORY: There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded." : "Unknown OpenGL error with error code $err."
end
function glCheckError(actionName="")
  message = glErrorMessage()
  if length(message) > 0
    if length(actionName) > 0
    error("Error ", actionName, ": ", message)
    else
    error("Error: ", message)
    end
  end
end

#loadShaderSource(shaderID::GLuint, source::String) = (shadercode=Vector{UInt8}(string(source,"\x00")); glShaderSource(shaderID, 1, Ptr{UInt8}[pointer(shadercode)], Ref{GLint}(length(shadercode))))
#glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(source))])), C_NULL)

function compileShader(shader,source)
  ModernGL.glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{ModernGL.GLchar}, pointer(string(source,"\x00")))])), C_NULL)
  glCheckError("glShaderSource")
    
  ModernGL.glCompileShader(shader)
  glCheckError("glCompileShader")
  
  !validateShader(shader) && error("Shader $name compile error: ", getInfoLog(shader))
end

BackupSource=Dict{Symbol,Dict{ModernGL.GLuint,String}}()

function createShader(source::Tuple{Symbol,String}, typ)
  if typ == ModernGL.GL_VERTEX_SHADER name="GL_VERTEX_SHADER" end
  if typ == ModernGL.GL_FRAGMENT_SHADER name="GL_FRAGMENT_SHADER" end
  if typ == ModernGL.GL_GEOMETRY_SHADER name="GL_GEOMETRY_SHADER" end

  # Create the shader
  shader = ModernGL.glCreateShader(typ)::ModernGL.GLuint
  glCheckError("glCreateShader")
  
  if shader == 0
    error("Error creating shader: ", glErrorMessage())
  end
  
  # Compile the shader
  name=source[1]; source=source[2]; err=false
  
  try
    compileShader(shader,source)
    
     # save backup
    if !haskey(BackupSource, name) BackupSource[name] = Dict() end
    BackupSource[name][typ]=source

  catch(ex)
    Base.showerror(STDERR, ex, catch_backtrace())
    err=true
    
    # get backup
    if haskey(BackupSource, name) && haskey(BackupSource[name], typ)
      compileShader(shader,BackupSource[name][typ])
    end
  end

  # Check for errors
  info("Shader $name initalized.")
  shader
end
function createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)
  # Create, link then return a shader program for the given shaders.
  # Create the shader program
  prog = ModernGL.glCreateProgram()
  if prog == 0
    error("Error creating shader program: ", glErrorMessage())
  end
  
  vertexShader = createShader(vertexShader, ModernGL.GL_VERTEX_SHADER)
  fragmentShader = createShader(fragmentShader, ModernGL.GL_FRAGMENT_SHADER)
  
  # Attach the vertex shader
  ModernGL.glAttachShader(prog, vertexShader)
  glCheckError("attaching vertex shader")
  # Attach the fragment shader
  ModernGL.glAttachShader(prog, fragmentShader)
  glCheckError("attaching fragment shader")
  # Attach the geometry shader
  if geometryShader != nothing
    geometryShader = createShader(geometryShader, ModernGL.GL_GEOMETRY_SHADER)
    ModernGL.glAttachShader(prog, geometryShader)
    glCheckError("attaching geometry shader")
  end
  # Finally, link the program and check for errors.
  ModernGL.glLinkProgram(prog)
  
  ModernGL.glDeleteShader(vertexShader)
  ModernGL.glDeleteShader(fragmentShader)
  if geometryShader != nothing ModernGL.glDeleteShader(geometryShader) end
  
  status = ModernGL.GLint[0]
  ModernGL.glGetProgramiv(prog, GL_LINK_STATUS, status)
  if status[] == GL_FALSE
    msg = getInfoLog(prog)
    ModernGL.glDeleteProgram(prog)
    error("Error linking shader: ", msg)
  end
  info("Shader Program initalized.")
  prog
end

global GLSL_VERSION = ""

function createcontextinfo()
  global GLSL_VERSION
  glsl = split(unsafe_string(ModernGL.glGetString(ModernGL.GL_SHADING_LANGUAGE_VERSION)), ['.', ' '])
  if length(glsl) >= 2
    glsl = VersionNumber(parse(Int, glsl[1]), parse(Int, glsl[2]))
    GLSL_VERSION = string(glsl.major) * rpad(string(glsl.minor),2,"0")
  else
    error("Unexpected version number string. Please report this bug! GLSL version string: $(glsl)")
  end

  glv = split(unsafe_string(ModernGL.glGetString(ModernGL.GL_VERSION)), ['.', ' '])
  if length(glv) >= 2
    glv = VersionNumber(parse(Int, glv[1]), parse(Int, glv[2]))
  else
    error("Unexpected version number string. Please report this bug! OpenGL version string: $(glv)")
  end
  dict = Dict{Symbol,Any}(
      :glsl_version   => glsl,
      :gl_version     => glv,
      :gl_vendor      => unsafe_string(ModernGL.glGetString(ModernGL.GL_VENDOR)),
      :gl_renderer  => unsafe_string(ModernGL.glGetString(ModernGL.GL_RENDERER)),
      #:gl_extensions => split(unsafe_string(glGetString(GL_EXTENSIONS))),
  )
end
function get_glsl_version_string()
  if isempty(GLSL_VERSION)
    error("couldn't get GLSL version, GLUTils not initialized, or context not created?")
  end
  return "#version $(GLSL_VERSION)\n"
end