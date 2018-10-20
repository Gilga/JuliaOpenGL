using ModernGL

"""
TODO
"""
function glGenOne(glGenFn)
  id = GLuint[0]
  glGenFn(1, id)
  glCheckError("generating a buffer, array, or texture")
  id[]
end

"""
TODO
"""
glGenBuffer() = glGenOne(glGenBuffers)

"""
TODO
"""
glGenVertexArray() = glGenOne(glGenVertexArrays)

"""
TODO
"""
glGenTexture() = glGenOne(glGenTextures)

"""
TODO
"""
glGetIntegerv_e(name::GLenum) = begin r=GLint[0]; glGetIntegerv(name,r); r[] end

"""
TODO
"""
function getInfoLog(obj::GLuint)
  # Return the info log for obj, whether it be a shader or a program.
  isShader = glIsShader(obj)
  getiv = isShader == GL_TRUE ? glGetShaderiv : glGetProgramiv
  getInfo = isShader == GL_TRUE ? glGetShaderInfoLog : glGetProgramInfoLog
  # Get the maximum possible length for the descriptive error message
  len = GLint[0]
  getiv(obj, GL_INFO_LOG_LENGTH, len)
  maxlength = len[]
  # TODO: Create a macro that turns the following into the above:
  # maxlength = @glPointer getiv(obj, GL_INFO_LOG_LENGTH, GLint)
  # Return the text of the message if there is any
  if maxlength > 0
    buffer = zeros(GLchar, maxlength)
    sizei = GLsizei[0]
    getInfo(obj, maxlength, sizei, buffer)
    len = sizei[]
    unsafe_string(pointer(buffer), len)
  else
    ""
  end
end

"""
TODO
"""
function validateShader(shader)
  success = GLint[0]
  glGetShaderiv(shader, GL_COMPILE_STATUS, success)
  success[] == GL_TRUE
end

"""
TODO
"""
function glErrorMessage()
# Return a string representing the current OpenGL error flag, or the empty string if there's no error.
  err = glGetError()
  err == GL_NO_ERROR ? "" :
  err == GL_INVALID_ENUM ? "GL_INVALID_ENUM: An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag." :
  err == GL_INVALID_VALUE ? "GL_INVALID_VALUE: A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag." :
  err == GL_INVALID_OPERATION ? "GL_INVALID_OPERATION: The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag." :
  err == GL_INVALID_FRAMEBUFFER_OPERATION ? "GL_INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag." :
  err == GL_OUT_OF_MEMORY ? "GL_OUT_OF_MEMORY: There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded." : "Unknown OpenGL error with error code $err."
end

"""
TODO
"""
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

"""
TODO
"""
function compileShader(name, shader,source)
  glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(string(source,"\x00")))])), C_NULL)
  glCheckError("glShaderSource")
    
  glCompileShader(shader)
  glCheckError("glCompileShader")
  
  !validateShader(shader) && error("Shader $name compile error: ", getInfoLog(shader))
end

BackupSource=Dict{Symbol,Dict{GLuint,String}}()

"""
TODO
"""
function createShader(source::Tuple{Symbol,Symbol,String})
  name, typ, source = source; err=false

  if typ == :VSH typ = GL_VERTEX_SHADER; typname="GL_VERTEX_SHADER" end
  if typ == :FSH typ = GL_FRAGMENT_SHADER; typname="GL_FRAGMENT_SHADER" end
  if typ == :GSH typ = GL_GEOMETRY_SHADER; typname="GL_GEOMETRY_SHADER" end
  if typ == :CSH typ = GL_COMPUTE_SHADER; typname="GL_COMPUTE_SHADER" end

  # Create the shader
  shader = glCreateShader(typ)::GLuint
  glCheckError("glCreateShader")
  
  if shader == 0
    error("Error creating shader: ", glErrorMessage())
  end
  
  # Compile the shader
  
  try
    compileShader(name, shader,source)
    
     # save backup
    if !haskey(BackupSource, name) BackupSource[name] = Dict() end
    BackupSource[name][typ]=source

  catch(ex)
    Base.showerror(stderr, ex, catch_backtrace())
    err=true
    
    # get backup
    if haskey(BackupSource, name) && haskey(BackupSource[name], typ)
      compileShader(shader,BackupSource[name][typ])
    end
  end

  # Check for errors
  info("Shader $name of type $typname is initalized.")
  shader
end

"""
TODO
"""
function createShaderProgram(shaders::Array{Tuple{Symbol,Symbol,String},1})
  # Create, link then return a shader program for the given shaders.
  # Create the shader program
  prog = glCreateProgram()
  if prog == 0
    error("Error creating shader program: ", glErrorMessage())
  end
  
  # attributes
  #glBindAttribLocation(prog,0,"iVertex") # bind attribute always
  
  shaderIDs = Int32[]
  
  for shader in shaders
    shaderID = createShader(shader)
    glAttachShader(prog, shaderID)
    glCheckError("attaching shader")
    push!(shaderIDs)
  end
  
  #vertexShader = createShader(vertexShader, GL_VERTEX_SHADER)
  #fragmentShader = createShader(fragmentShader, GL_FRAGMENT_SHADER)

  #glAttachShader(prog, vertexShader)
  #glCheckError("attaching vertex shader")
  #glAttachShader(prog, fragmentShader)
  #glCheckError("attaching fragment shader")
  #if geometryShader != nothing
  #  geometryShader = createShader(geometryShader, GL_GEOMETRY_SHADER)
  #  glAttachShader(prog, geometryShader)
  #  glCheckError("attaching geometry shader")
  #end
  
  # Finally, link the program and check for errors.
  glLinkProgram(prog)
  
  for shaderID in shaderIDs glDeleteShader(shaderID) end
  
  #glDeleteShader(vertexShader)
  #glDeleteShader(fragmentShader)
  #if geometryShader != nothing glDeleteShader(geometryShader) end
  
  status = GLint[0]
  glGetProgramiv(prog, GL_LINK_STATUS, status)
  if status[] == GL_FALSE
    msg = getInfoLog(prog)
    glDeleteProgram(prog)
    error("Error linking shader: ", msg)
  end
  info("Shader Program $prog is initalized.")
  prog
end

global GLSL_VERSION = ""

"""
TODO
"""
function createcontextinfo()
  global GLSL_VERSION
  glsl = split(unsafe_string(glGetString(GL_SHADING_LANGUAGE_VERSION)), ['.', ' '])
  if length(glsl) >= 2
    glsl = VersionNumber(parse(Int, glsl[1]), parse(Int, glsl[2]))
    GLSL_VERSION = string(glsl.major) * rpad(string(glsl.minor),2,"0")
  else
    error("Unexpected version number string. Please report this bug! GLSL version string: $(glsl)")
  end

  glv = split(unsafe_string(glGetString(GL_VERSION)), ['.', ' '])
  if length(glv) >= 2
    glv = VersionNumber(parse(Int, glv[1]), parse(Int, glv[2]))
  else
    error("Unexpected version number string. Please report this bug! OpenGL version string: $(glv)")
  end
  dict = Dict{Symbol,Any}(
      :glsl_version   => glsl,
      :gl_version     => glv,
      :gl_vendor      => unsafe_string(glGetString(GL_VENDOR)),
      :gl_renderer  => unsafe_string(glGetString(GL_RENDERER)),
      #:gl_extensions => split(unsafe_string(glGetString(GL_EXTENSIONS))),
  )
end
function get_glsl_version_string()
  if isempty(GLSL_VERSION)
    error("couldn't get GLSL version, GLUTils not initialized, or context not created?")
  end
  return "#version $(GLSL_VERSION)\n"
end