module GraphicsManager

using ..Log

using ModernGL

const GL_ERRORS = Dict{GLuint,AbstractString}(
	GL_NO_ERROR											 =>	"",
	GL_INVALID_ENUM									 =>	"INVALID_ENUM: An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_VALUE								 =>	"INVALID_VALUE: A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_OPERATION						 =>	"INVALID_OPERATION: The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_INVALID_FRAMEBUFFER_OPERATION => "INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.",
	GL_OUT_OF_MEMORY								 =>	"OUT_OF_MEMORY: There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.",
	GL_STACK_UNDERFLOW							 =>	"STACK_UNDERFLOW",
	GL_STACK_OVERFLOW								 =>	"STACK_OVERFLOW",
)

glError(id) = haskey(GL_ERRORS,id) ? GL_ERRORS[id] : "Unknown OpenGL error with error code $id."

GL_MESSAGES = Dict{Tuple{GLenum,GLenum,GLuint,GLenum,GLsizei},GLuint}()

"""
TODO
"""
hasDuplicates(msg) = haskey(GL_MESSAGES, msg) ? true : (global GL_MESSAGES[msg]=0; false)

#lastMessage = (0, 0, 0, 0, 0)
#hasDuplicates(msg) = (for (i,j) in zip(msg,lastMessage) if i != j return false end end; true)

"""
TODO
"""
function openglerrorcallback(
                source::GLenum, typ::GLenum,
                id::GLuint, severity::GLenum,
                len::GLsizei, message::Ptr{GLchar},
                userParam::Ptr{Nothing}
            )

		msg = (source, typ, id, severity, len)
		if hasDuplicates(msg) return end # ignore duplicates
		#global lastMessage = msg

		#source = GL_DEBUG_SOURCE_API, GL_DEBUG_SOURCE_WINDOW_SYSTEM_, GL_DEBUG_SOURCE_SHADER_COMPILER, GL_DEBUG_SOURCE_THIRD_PARTY, GL_DEBUG_SOURCE_APPLICATION, GL_DEBUG_SOURCE_OTHER, GL_DONT_CARE
		#typ = GL_DEBUG_TYPE_ERROR, GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR, GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR, GL_DEBUG_TYPE_PORTABILITY, GL_DEBUG_TYPE_PERFORMANCE, GL_DEBUG_TYPE_MARKER, GL_DEBUG_TYPE_PUSH_GROUP, GL_DEBUG_TYPE_POP_GROUP, or GL_DEBUG_TYPE_OTHER, GL_DONT_CARE
		#severity = GL_DEBUG_SEVERITY_LOW, GL_DEBUG_SEVERITY_MEDIUM, or GL_DEBUG_SEVERITY_HIGH, GL_DONT_CARE
    errormessage = 	"\n"*
                    " __OPENGL________________________________________________________\n"*
                    #"| type: $(GLENUM(typ).name) :: id: $(GLENUM(id).name)\n"*
										#"| source: $(GLENUM(source).name) :: severity: $(GLENUM(severity).name)\n"*
										(userParam != C_NULL ? "| UserParam : NOT NULL\n" : "")*
                    (len > 0 ? "| "*ascii(unsafe_string(message, len))*"\n" : "")*
										(typ == GL_DEBUG_TYPE_ERROR ?  "| " * glError(id) * "\n" : "")*
                    "|________________________________________________________________\n"

		#id == GL_NO_ERROR || !haskey(GL_ERRORS,id)
    typ == GL_DEBUG_TYPE_ERROR ? error(errormessage) : typ == GL_DEBUG_TYPE_OTHER ? debug(errormessage) : warn(errormessage)
    nothing
end

"""
TODO
"""
const _openglerrorcallback = @cfunction(openglerrorcallback,Nothing,
                                        (GLenum, GLenum,
                                        GLuint, GLenum,
                                        GLsizei, Ptr{GLchar},
                                        Ptr{Nothing}))

"""
TODO
"""
function glDebug(debug::Bool)
  if !debug return end
  
  @static if Sys.isapple()
			warn("OpenGL debug message callback not available on osx")
			return
  end
  #if (glGetIntegerval(GL_CONTEXT_FLAGS) & GL_CONTEXT_FLAG_DEBUG_BIT) != 0
		glEnable(GL_DEBUG_OUTPUT)
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS)
		glDebugMessageCallbackARB(_openglerrorcallback, C_NULL)
	#end
end

export glDebug

"""
TODO
"""
glErrorMessage() = glError(glGetError())

export glErrorMessage

"""
TODO
"""
function glCheckError(actionName="")
  message = glErrorMessage()
  if !isempty(message)
    if length(actionName) > 0
    error("Error ", actionName, ": ", message)
    else
    error("Error: ", message)
    end
  end
end

export glCheckError

"""
TODO
"""
function glCheck(x=nothing)
  message = glErrorMessage()
  if !isempty(message) error(message) end
  x
end

export glCheck

"""
TODO
"""
glGetValue(f::Function, id, typ::DataType) = begin value=typ[0]; glCheck(f(id,value)); value[] end
#ref = Ref(T(0)); #f(ref); #ref.x

export glGetValue

"""
TODO
"""
glGenOne(glGenFn) = begin id=GLuint[0]; glCheck(glGenFn(1, id)); id[] end

export glGenOne

"""
TODO
"""
glDelOne(glDelFn, id) = begin ids=GLuint[id]; glCheck(glDelFn(1, ids)) end

export glDelOne

"""
TODO
"""
glGenBuffer() = glGenOne(glGenBuffers)

export glGenBuffer

"""
TODO
"""
glDeleteBuffer(id) = glDelOne(glDeleteBuffers,id)

export glDeleteBuffer

"""
TODO
"""
glGenVertexArray() = glGenOne(glGenVertexArrays)

export glGenVertexArray

"""
TODO
"""
glDeleteVertexArray(id) = glDelOne(glDeleteVertexArrays,id)

export glDeleteVertexArray

"""
TODO
"""
glGenTexture() = glGenOne(glGenTextures)

export glGenTexture

"""
TODO
"""
glDeleteTexture(id) = glDelOne(glDeleteTextures, id)

export glDeleteTexture

"""
TODO
"""
glGetIntegerval(name::GLenum) = glGetValue(glGetIntegerv, name, GLint)

export glGetIntegerval

"""
TODO
"""
function getInfoLog(obj::GLuint)
  # Return the info log for obj, whether it be a shader or a program.
  isShader = glCheck(glIsShader(obj))
  getiv = isShader == GL_TRUE ? glGetShaderiv : glGetProgramiv
  getInfo = isShader == GL_TRUE ? glGetShaderInfoLog : glGetProgramInfoLog
  # Get the maximum possible length for the descriptive error message
  len = GLint[0]
  glCheck(getiv(obj, GL_INFO_LOG_LENGTH, len))
  maxlength = len[]
  # TODO: Create a macro that turns the following into the above:
  # maxlength = @glPointer getiv(obj, GL_INFO_LOG_LENGTH, GLint)
  # Return the text of the message if there is any
  if maxlength > 0
    buffer = zeros(GLchar, maxlength)
    sizei = GLsizei[0]
    glCheck(getInfo(obj, maxlength, sizei, buffer))
    len = sizei[]
    unsafe_string(pointer(buffer), len)
  else
    ""
  end
end

export getInfoLog

"""
TODO
"""
function validateShader(shader)
  success = GLint[0]
  glGetShaderiv(shader, GL_COMPILE_STATUS, success)
  success[] == GL_TRUE
end

#loadShaderSource(shaderID::GLuint, source::String) = (shadercode=Vector{UInt8}(string(source,"\x00")); glShaderSource(shaderID, 1, Ptr{UInt8}[pointer(shadercode)], Ref{GLint}(length(shadercode))))
#glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(source))])), C_NULL)

"""
TODO
"""
function compileShader(name, shader,source)
  glCheck(glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(string(source,"\x00")))])), C_NULL))
  glCheck(glCompileShader(shader))
  !validateShader(shader) && error("Shader $name compile error: ", getInfoLog(shader))
end

export compileShader

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
  shader = glCheck(glCreateShader(typ)::GLuint)
  
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

export createShader

"""
TODO
"""
function createShaderProgram(shaders::Array{Tuple{Symbol,Symbol,String},1})
  # Create, link then return a shader program for the given shaders.
  # Create the shader program
  prog = glCheck(glCreateProgram())
  if prog == 0
    error("Error creating shader program: ", glErrorMessage())
  end
  
  # attributes
  #glBindAttribLocation(prog,0,"iVertex") # bind attribute always
  
  shaderIDs = Int32[]
  
  for shader in shaders
    shaderID = createShader(shader)
    glCheck(glAttachShader(prog, shaderID))
    push!(shaderIDs)
  end
  
  # link the program and check for errors
  glCheck(glLinkProgram(prog))
  
  for shaderID in shaderIDs glCheck(glDeleteShader(shaderID)) end
  
  status = GLint[0]
  glCheck(glGetProgramiv(prog, GL_LINK_STATUS, status))
  if status[] == GL_FALSE
    msg = getInfoLog(prog)
    glCheck(glDeleteProgram(prog))
    error("Error linking shader: ", msg)
  end
  info("Shader Program $prog is initalized.")
  prog
end

export createShaderProgram

global GLSL_VERSION = ""

"""
TODO
"""
function createcontextinfo()
  global GLSL_VERSION
  glsl = split(unsafe_string(glCheck(glGetString(GL_SHADING_LANGUAGE_VERSION))), ['.', ' '])
  if length(glsl) >= 2
    glsl = VersionNumber(parse(Int, glsl[1]), parse(Int, glsl[2]))
    GLSL_VERSION = string(glsl.major) * rpad(string(glsl.minor),2,"0")
  else
    error("Unexpected version number string. Please report this bug! GLSL version string: $(glsl)")
  end

  glv = split(unsafe_string(glCheck(glGetString(GL_VERSION))), ['.', ' '])
  if length(glv) >= 2
    glv = VersionNumber(parse(Int, glv[1]), parse(Int, glv[2]))
  else
    error("Unexpected version number string. Please report this bug! OpenGL version string: $(glv)")
  end
  dict = Dict{Symbol,Any}(
      :glsl_version   => glsl,
      :gl_version     => glv,
      :gl_vendor      => unsafe_string(glCheck(glGetString(GL_VENDOR))),
      :gl_renderer  => unsafe_string(glCheck(glGetString(GL_RENDERER))),
      #:gl_extensions => split(unsafe_string(glGetString(GL_EXTENSIONS))),
  )
end

export createcontextinfo

function get_glsl_version_string()
  if isempty(GLSL_VERSION)
    error("couldn't get GLSL version, GLUTils not initialized, or context not created?")
  end
  return "#version $(GLSL_VERSION)\n"
end

export get_glsl_version_string

end #GraphicsManager