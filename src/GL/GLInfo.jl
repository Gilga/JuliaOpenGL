module GLInfo

using ModernGL

###############################################################################

using GLLists
using GLDebug
using GLExtender

###############################################################################

export createcontextinfo
export get_glsl_version_string

###############################################################################

global GLSL_VERSION = ""

###############################################################################

"""
TODO
"""
function createcontextinfo()
  global GLSL_VERSION
  glsl = split(unsafe_string(@GLCHECK glGetString(GL_SHADING_LANGUAGE_VERSION)), ['.', ' '])
  if length(glsl) >= 2
    glsl = VersionNumber(parse(Int, glsl[1]), parse(Int, glsl[2]))
    GLSL_VERSION = string(glsl.major) * rpad(string(glsl.minor),2,"0")
  else
    error("Unexpected version number string. Please report this bug! GLSL version string: $(glsl)")
  end

  glv = split(unsafe_string(@GLCHECK glGetString(GL_VERSION)), ['.', ' '])
  if length(glv) >= 2
    glv = VersionNumber(parse(Int, glv[1]), parse(Int, glv[2]))
  else
    error("Unexpected version number string. Please report this bug! OpenGL version string: $(glv)")
  end
  dict = Dict{Symbol,Any}(
      :glsl_version   => glsl,
      :gl_version     => glv,
      :gl_vendor      => unsafe_string(@GLCHECK glGetString(GL_VENDOR)),
      :gl_renderer  => unsafe_string(@GLCHECK glGetString(GL_RENDERER)),
      :gl_extensions => getExtensions(), #split(unsafe_string(glGetString(GL_EXTENSIONS))),
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

"""
TODO
"""
function getInfoLog(obj::GLuint)
  # Return the info log for obj, whether it be a shader or a program.
  isShader = @GLCHECK glIsShader(obj)
  getiv = isShader == GL_TRUE ? glGetShaderiv : glGetProgramiv
  getInfo = isShader == GL_TRUE ? glGetShaderInfoLog : glGetProgramInfoLog
  # Get the maximum possible length for the descriptive error message
  len = GLint[0]
  @GLCHECK getiv(obj, GL_INFO_LOG_LENGTH, len)
  maxlength = len[]
  # TODO: Create a macro that turns the following into the above:
  # maxlength = @glPointer getiv(obj, GL_INFO_LOG_LENGTH, GLint)
  # Return the text of the message if there is any
  if maxlength > 0
    buffer = zeros(GLchar, maxlength)
    sizei = GLsizei[0]
    @GLCHECK getInfo(obj, maxlength, sizei, buffer)
    len = sizei[]
    unsafe_string(pointer(buffer), len)
  else
    ""
  end
end
export getInfoLog

end # GLInfo