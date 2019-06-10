module GLExtender

export @glfunc

using ModernGL
using Libdl

# ModernGL functions for Extension
gl_lib = C_NULL

isOpenLib() = gl_lib != C_NULL
function openLib(); if Sys.iswindows() && !isOpenLib(); gl_lib = Libdl.dlopen("opengl32"); end; gl_lib; end
function closeLib(); if Sys.iswindows() && isOpenLib(); Libdl.dlclose(gl_lib); gl_lib=C_NULL; end; end

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

    if Sys.iswindows() # windows has some function pointers statically available and some not, this is how we deal with it:
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

"""
TODO
"""
function getExtensions()
  count = GLint[0]
  glGetIntegerv(GL_NUM_EXTENSIONS, count)
  count=count[]
  exts=[]
  for i=1:count
    name=unsafe_string(glGetStringi(GL_EXTENSIONS, i-1))
    push!(exts,name)
    #if strcmp(ccc, (const GLubyte *)"GL_ARB_debug_output") == 0
    #  # The extension is supported by our hardware and driver
    #  # Try to get the "glDebugMessageCallbackARB" function :
    #  glDebugMessageCallbackARB  = (PFNGLDEBUGMESSAGECALLBACKARBPROC) wglGetProcAddress("glDebugMessageCallbackARB");
    #end
  end
  exts
end
export getExtensions

# function setExtensionsCallback()
#   if strcmp(ccc, (const GLubyte *)"GL_ARB_debug_output") == 0
#    # The extension is supported by our hardware and driver
#    # Try to get the "glDebugMessageCallbackARB" function :
#    glDebugMessageCallbackARB  = (PFNGLDEBUGMESSAGECALLBACKARBPROC) wglGetProcAddress("glDebugMessageCallbackARB");
#   end
# end

end #GLExtender
