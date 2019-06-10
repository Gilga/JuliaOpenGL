module GLDebug

using ModernGL

using GLLists

###############################################################################

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
glError(id) = haskey(GLLists.LIST_ERROR,id) ? GLLists.LIST_ERROR[id] : "Unknown OpenGL error with error code $id."
export glError

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

macro GLCHECK(ex) :(glCheck($(esc(ex)))) end
export @GLCHECK

end #GLDebug
