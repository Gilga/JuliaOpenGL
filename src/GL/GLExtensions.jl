module GLExtensions

using ModernGL

using MathManager
using GLDebug
using GLExtender

########################################################

GLExtender.openLib()
@glfunc glBindBuffersBase(target::GLenum, first::GLuint, count::GLsizei, buffers::Ptr{GLuint})::Cvoid
@glfunc glBindBuffersRange(target::GLenum, first::GLuint, count::GLsizei, buffers::Ptr{GLuint}, offsets::Ptr{GLintptr}, sizes::Ptr{GLintptr})::Cvoid
GLExtender.closeLib()

export glBindBuffersBase
export glBindBuffersRange

################################################################################

""" TODO """
function validateShader(shader)
  success = GLint[0]
  glGetShaderiv(shader, GL_COMPILE_STATUS, success)
  success[] == GL_TRUE
end
export validateShader

#loadShaderSource(shaderID::GLuint, source::String) = (shadercode=Vector{UInt8}(string(source,"\x00")); glShaderSource(shaderID, 1, Ptr{UInt8}[pointer(shadercode)], Ref{GLint}(length(shadercode))))
#glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(source))])), C_NULL)

""" TODO """
function compileShader(shader::GLuint, source::String)
  @GLCHECK glShaderSource(shader, 1, convert(Ptr{UInt8}, pointer([convert(Ptr{GLchar}, pointer(string(source,"\x00")))])), C_NULL)
  @GLCHECK glCompileShader(shader)
  validateShader(shader)
end
export compileShader

################################################################################

""" TODO """
glArrayFunc(ids::Array, func::Function) = begin len=length(ids); if len>0 func(len, ids) end; end
#glCreate(count::Number, arr::AbstractArray, func::Function, args...) = for i=1:count push!(arr, func(args...)) end
#glDelete(ids::Array, func::Function, args...) = for id in ids func(id, args...) end
export glArrayFunc

""" TODO """
glGenOne(glGenFn) = begin id=GLuint[0]; @GLCHECK glGenFn(1, id); id[] end
export glGenOne

""" TODO """
glDelOne(glDelFn, id) = begin ids=GLuint[id]; @GLCHECK glDelFn(1, ids) end
export glDelOne

""" TODO """
glGenBuffer() = glGenOne(glGenBuffers)
export glGenBuffer

""" TODO """
glDeleteBuffer(id) = glDelOne(glDeleteBuffers,id)
export glDeleteBuffer

""" TODO """
glGenFramebuffer() = glGenOne(glGenFramebuffers)
export glGenFramebuffer

""" TODO """
glDeleteFramebuffer(id) = glDelOne(glDeleteFramebuffers,id)
export glDeleteFramebuffer

""" TODO """
glGenRenderbuffer() = glGenOne(glGenRenderbuffers)
export glGenRenderbuffer

""" TODO """
glDeleteRenderbuffer(id) = glDelOne(glDeleteRenderbuffers,id)
export glDeleteRenderbuffer

""" TODO """
glGenVertexArray() = glGenOne(glGenVertexArrays)
export glGenVertexArray

""" TODO """
glDeleteVertexArray(id) = glDelOne(glDeleteVertexArrays,id)
export glDeleteVertexArray

""" TODO """
glGenTexture() = glGenOne(glGenTextures)
export glGenTexture

""" TODO """
glDeleteTexture(id) = glDelOne(glDeleteTextures, id)
export glDeleteTexture

""" TODO """
glGenSampler() = glGenOne(glGenSamplers)
export glGenSampler

""" TODO """
glDeleteSampler(id) = glDelOne(glDeleteSamplers, id)
export glDeleteSampler

################################################################################
export glGetValue

""" TODO """
glGetValue(f::Function, typ::DataType, t::Tuple) = begin value=typ[0]; @GLCHECK f(t...,value); value[] end

""" TODO """
function glGetValue(typ::DataType, name::GLenum, index::Union{Nothing, GLuint}=nothing)

  noindex = index == nothing
  t = noindex ? (name,) : (name,index)
	f = nothing

	if typ == GLboolean f = noindex ? glGetBooleanv : glGetBooleani_v
	elseif typ == GLint f = noindex ? glGetIntegerv : glGetIntegeri_v
	elseif typ == GLint64 f = noindex ? glGetInteger64v : glGetInteger64i_v
	elseif typ == GLfloat f = noindex ? glGetFloatv : glGetFloati_v
	elseif typ == GLdouble f = noindex ? glGetDoublev : glGetDoublei_v
  elseif typ == String return unsafe_string((noindex ? glGetString : glGetStringi)(t...))
	end

	if f != nothing return glGetValue(f, typ, t) end
	nothing
end

################################################################################

""" TODO """
glSetFragLocation(id::GLuint, name::String, colorNumber::GLuint) = glFragLocation(id, name, colorNumber)
export glSetFragLocation

""" TODO """
glFragLocation(id::GLuint, name::String, colorNumber::GLuint) = glBindFragDataLocation(id, colorNumber, name)
export glFragLocation

""" TODO """
glAttribLocation(id::GLuint, name::String) = glGetAttribLocation(id, name)
export glAttribLocation

""" TODO """
glUniformLocation(id::GLuint, name::String) = glGetUniformLocation(id, name)
export glUniformLocation

################################################################################

export glUniform

""" TODO """
glUniform(location::GLint, value::Bool) = glUniform1ui(location, GLuint(value ? 1 : 0))

""" TODO """
glUniform(location::GLint, value::UInt32) = glUniform1ui(location, GLuint(value))

""" TODO """
glUniform(location::GLint, value::UInt64) = glUniform1ui(location, GLuint(value))

""" TODO """
glUniform(location::GLint, value::Int32) = glUniform1i(location, GLint(value))

""" TODO """
glUniform(location::GLint, value::Int64) = glUniform1i(location, GLint(value))

""" TODO """
glUniform(location::GLint, value::Float32) = glUniform1f(location, GLfloat(value))

""" TODO """
glUniform(location::GLint, value::Float64) = glUniform1d(location, GLdouble(value))

""" TODO """
glUniform(location::GLint, value::Array{Float32,1}) = glUniform1fv(location, length(value), pointer(value))

""" TODO """
glUniform(location::GLint, value::Array{Float64,1}) = glUniform1dv(location, length(value), pointer(value))
#glUniform(location::GLint, value::Array{Vec{2, Float32},1}) = glUniform2fv(location, length(value), pointer(value))
#glUniform(location::GLint, value::Array{Vec{3, Float32},1}) = glUniform3fv(location, length(value), pointer(value))
#glUniform(location::GLint, value::Array{Vec{4, Float32},1}) = glUniform4fv(location, length(value), pointer(value))

""" TODO """
glUniform(location::GLint, value::Vec2f) = glUniform2fv(location, 1, pointer(convert(Array, value)))

""" TODO """
glUniform(location::GLint, value::Vec3f) = glUniform3fv(location, 1, pointer(convert(Array, value)))

""" TODO """
glUniform(location::GLint, value::Vec4f) = glUniform4fv(location, 1, pointer(convert(Array, value)))

""" TODO """
glUniform(location::GLint, value::Mat2x2f, transpose=false) = glUniformMatrix2fv(location, 1, transpose, pointer(convert(Array, value)))

""" TODO """
glUniform(location::GLint, value::Mat3x3f, transpose=false) = glUniformMatrix3fv(location, 1, transpose, pointer(convert(Array, value)))

""" TODO """
glUniform(location::GLint, value::Mat4x4f, transpose=false) = glUniformMatrix4fv(location, 1, transpose, pointer(convert(Array, value)))

################################################################################

#glGetSamplerParameterIiv
#glGetPointerv
#glGetQueryObjectui64v
#glGetProgramiv
#glGetBufferPointerv
#glGetTexParameterIuiv
#glGetShaderiv
#glGetRenderbufferParameteriv
#glGetUniformuiv
#glGetProgramPipelineiv
#glGetVertexAttribfv
#glGetVertexAttribLdv
#glGetVertexAttribiv
#glGetSamplerParameteriv
#glGetActiveUniformBlockiv
#glGetVertexAttribdv
#glGetQueryObjectuiv
#glGetProgramResourceiv
#glGetUniformfv
#glGetUniformdv
#glGetProgramInterfaceiv
#glGetVertexAttribIuiv
#glGetFramebufferParameteriv
#glGetActiveSubroutineUniformiv
#glGetVertexAttribPointerv
#glGetBufferParameteriv
#glGetUniformiv
#glGetQueryObjecti64v
#glGetTexLevelParameteriv
#glGetBufferParameteri64v
#glGetQueryObjectiv
#glGetActiveUniformsiv
#glGetTexParameterfv
#glGetTexLevelParameterfv
#glGetVertexAttribIiv
#glGetFramebufferAttachmentParameteriv
#glGetActiveAtomicCounterBufferiv
#glGetSynciv
#glGetSamplerParameterfv
#glGetQueryiv
#glGetTexParameterIiv
#glGetUniformSubroutineuiv
#glGetQueryIndexediv
#glGetProgramStageiv
#glGetSamplerParameterIuiv
#glGetTexParameteriv
#glGetMultisamplefv

end #GLExtensions
