module GraphicsManager

using ..FileManager
using ..LogManager

using ModernGL

########################################################
# ModernGL functions for Extension
gl_lib = C_NULL

isOpenLib() = gl_lib != C_NULL
function openLib(); if iswindows() && !isOpenLib(); gl_lib = Libdl.dlopen("opengl32"); end; gl_lib; end
function closeLib(); if iswindows() && isOpenLib(); Libdl.dlclose(gl_lib); gl_lib=C_NULL; end; end

using Libdl

const iswindows = Sys.iswindows
const enable_opengl_debugging  = false

function debug_opengl_expr(func_name, args)
    if enable_opengl_debugging && func_name != :glGetError
        quote
            err = glGetError()
            if err != GL_NO_ERROR
                arguments = gl_represent.(tuple($(args...)))
                warn("OpenGL call to $($func_name), with arguments: $(arguments)
                Failed with error: $(GLENUM(err).name).")
            end
        end
    else
        :()
    end
end

# based on getCFun macro
macro glfunc(opengl_func)
    arguments = map(opengl_func.args[1].args[2:end]) do arg
        isa(arg, Symbol) && return Expr(:(::), arg)
        arg
    end
    # Get info out of arguments of `opengl_func`
    arg_names       = map(arg->arg.args[1], arguments)
    return_type     = opengl_func.args[2]
    input_types     = map(arg->arg.args[2], arguments)
    func_name       = opengl_func.args[1].args[1]
    func_name_sym   = Expr(:quote, func_name)
    func_name_str   = string(func_name)
    ptr_expr        = :(ModernGL.getprocaddress_e($func_name_str))
    #debug_opengl_expr = ModernGL.debug_opengl_expr
    
    wasOpenLib=true
    
    if iswindows() # windows has some function pointers statically available and some not, this is how we deal with it:
        wasOpenLib=isOpenLib()
        lib=openLib()
        ptr = Libdl.dlsym_e(lib, func_name)
        if (ptr != C_NULL)
            ptr_expr = :(($func_name_sym, "opengl32"))
            ret = quote
                function $func_name($(arg_names...))
                    result = ccall($ptr_expr, $return_type, ($(input_types...),), $(arg_names...))
                    $(debug_opengl_expr(func_name, arg_names))
                    result
                end
                $(Expr(:export, func_name))
            end
            return esc(ret)
        end
    end
    ptr_sym = gensym("$(func_name)_func_pointer")
    ret = quote
        $ptr_sym = ModernGL.GLFunc(C_NULL)
        function $func_name($(arg_names...))
            if $ptr_sym.p::Ptr{Cvoid} == C_NULL
                $ptr_sym.p::Ptr{Cvoid} = $ptr_expr
            end
            result = ccall($ptr_sym.p::Ptr{Cvoid}, $return_type, ($(input_types...),), $(arg_names...))
            $(debug_opengl_expr(func_name, arg_names))
            result
        end
        $(Expr(:export, func_name))
        end
    r=esc(ret)
    if !wasOpenLib closeLib() end
    r
end
########################################################
openLib()
@glfunc glBindBuffersBase(target::GLenum, first::GLuint, count::GLsizei, buffers::Ptr{GLuint})::Cvoid
@glfunc glBindBuffersRange(target::GLenum, first::GLuint, count::GLsizei, buffers::Ptr{GLuint}, offsets::Ptr{GLintptr}, sizes::Ptr{GLintptr})::Cvoid
closeLib()

export glBindBuffersBase
export glBindBuffersRange
########################################################

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
function showExtensions()
  count = GLint[0]
  glGetIntegerv(GL_NUM_EXTENSIONS, count)
  count=count[]
  file="gl_exentsioninfo.txt"
  open(file, "w") do f
    for i=1:count
      name=unsafe_string(glGetStringi(GL_EXTENSIONS, i-1))
      write(f,string(name,"\n"))
      #if strcmp(ccc, (const GLubyte *)"GL_ARB_debug_output") == 0
      #  # The extension is supported by our hardware and driver
      #  # Try to get the "glDebugMessageCallbackARB" function :
      #  glDebugMessageCallbackARB  = (PFNGLDEBUGMESSAGECALLBACKARBPROC) wglGetProcAddress("glDebugMessageCallbackARB");
      #end
    end
  end
  info("$count Exensions saved in $file")
end

export showExtensions

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
glGenFramebuffer() = glGenOne(glGenFramebuffers)

export glGenFramebuffer

"""
TODO
"""
glDeleteFramebuffer(id) = glDelOne(glDeleteFramebuffers,id)

export glDeleteFramebuffer

"""
TODO
"""
glGenRenderbuffer() = glGenOne(glGenRenderbuffers)

export glGenRenderbuffer

"""
TODO
"""
glDeleteRenderbuffer(id) = glDelOne(glDeleteRenderbuffers,id)

export glDeleteRenderbuffer

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
glGenSampler() = glGenOne(glGenSamplers)

export glGenSampler

"""
TODO
"""
glDeleteSampler(id) = glDelOne(glDeleteSamplers, id)

export glDeleteSampler

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
function compileShader(shader::GLuint, source::String)
  glCheck(glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(string(source,"\x00")))])), C_NULL))
  glCheck(glCompileShader(shader))
  validateShader(shader)
end

export compileShader

BackupSource=Dict{Symbol,String}()

"""
TODO
"""
function createShader(programname::Symbol, infos::Dict{Symbol,Any})
  pname = stringColor(programname;color=:yellow)
  key = Symbol(infos[:path]); file = infos[:file]; typ = infos[:shader]; source = infos[:content]; err=false
  source = string(strip(replace(source,"\r"=>"")))

  typname="?"
  if typ == :VSH typ = GL_VERTEX_SHADER; typname="VERTEX SHADER"
  elseif typ == :FSH typ = GL_FRAGMENT_SHADER; typname="FRAGMENT SHADER"
  elseif typ == :GSH typ = GL_GEOMETRY_SHADER; typname="GEOMETRY SHADER"
  elseif typ == :CSH typ = GL_COMPUTE_SHADER; typname="COMPUTE SHADER"
  end

  # Create the shader
  shader = glCheck(glCreateShader(typ)::GLuint)
  if shader == 0 LogManager.error("[$pname] Error creating $typname: ", glErrorMessage()); return -1 end
  
  tmpdir="shaders/tmp/"
  backupdir="shaders/backup/"
  
  if !isdir(tmpdir) mkdir(tmpdir) end
  if !isdir(backupdir) mkdir(backupdir) end
  
  tmpfile=abspath(tmpdir*file)
  backupfile=abspath(backupdir*file)
  
  # Compile the shader
  #try
  # load previous backup
  if !haskey(BackupSource, key) && isfile(backupfile)
    BackupSource[key]=fileGetContents(backupfile)
  end
  
  open(tmpfile, "w") do f write(f,source) end
  result=compileShader(shader, source)
  if !result
    LogManager.warn("[$pname] $typname ($file) compile error: ", getInfoLog(shader))
    
    # get backup
    if haskey(BackupSource, key)
      result=compileShader(shader, BackupSource[key])
       if !result LogManager.error("[$pname] Backup of $typname ($file) compile error: ", getInfoLog(shader)); return -1 end #lost backup?
      LogManager.debug("[$pname] Backup of $typname ($file) is compiled.")
    else
      glDeleteShader(shader)
      LogManager.error("[$pname] No valid backup for $typname.")
      return -1
    end
  else
    # save backup
    mv(tmpfile, backupfile; force=true) #move into backups
    BackupSource[key]=source
    LogManager.debug("[$pname] $typname ($file) is compiled.")
  end
  #catch(ex)
  #  Base.showerror(stderr, ex, catch_backtrace())
  #  err=true
  #end

  shader
end

export createShader

"""
TODO
"""
function createShaderProgram(name::Symbol, shaders::AbstractArray; transformfeedback=false)
  # Create, link then return a shader program for the given shaders.
  # Create the shader program
  pname = stringColor(name;color=:yellow)
  prog = glCheck(glCreateProgram())
  if prog == 0
    LogManager.error("Error creating shader program $pname: ", glErrorMessage())
  end
  
  LogManager.debug("Created shader program $pname.")
  
  # attributes
  #glBindAttribLocation(prog,0,"iVertex") # bind attribute always
  
  shaderIDs = Int32[]
  
  for shader in shaders
    shaderID = createShader(name, shader)
    if shaderID > 0
      glCheck(glAttachShader(prog, shaderID))
      push!(shaderIDs, shaderID)
    end
  end
  
  if length(shaderIDs) == 0
    glDeleteProgram(prog)
    prog = -1
    LogManager.error("No valid shaders for shader program $pname found.")
  else
  
    if transformfeedback
      #Ptr{Ptr{GLchar}}
      r = [
        convert(Ptr{GLchar}, pointer("iInstancePos")),#pointer(collect("iInstancePos\x00"))
        convert(Ptr{GLchar}, pointer("iInstanceFlags")) #pointer(collect("iInstanceFlags\x00"))
      ]
      glTransformFeedbackVaryings(prog, 2, r, GL_INTERLEAVED_ATTRIBS)
    end
    
    # link the program and check for errors
    glLinkProgram(prog)
    
    status = GLint[0]
    glGetProgramiv(prog, GL_LINK_STATUS, status)

    (id->glCheck(glDeleteShader(id))).(shaderIDs) # remove shaders

    if status[] == GL_FALSE
      msg = getInfoLog(prog)
      glDeleteProgram(prog)
      LogManager.error("Shader Program($prog) $pname: Error Linking: $msg")
      prog=-1
    end
    
    LogManager.debug("Shader Program($prog) $pname is initalized.")
  end 
    
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