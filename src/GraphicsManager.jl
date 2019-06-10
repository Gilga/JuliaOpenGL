__precompile__(false)

module GraphicsManager

using ModernGL

using CodeGeneration
using RessourceManager
using FileManager
using LogManager
using WindowManager

###############################################################################

push!(LOAD_PATH,joinpath(@__DIR__,"GL")) # add path

using GLLists
using GLDebug
using GLExtensions
using GLInfo

export @GLCHECK
export glCheckError
export getExtensions

export createcontextinfo
export get_glsl_version_string

export glBindBuffersBase
export glBindBuffersRange

export glGetValue
export glGenOne
export glDelOne
export glGenBuffer
export glDeleteBuffer
export glGenFramebuffer
export glDeleteFramebuffer
export glGenRenderbuffer
export glDeleteRenderbuffer
export glGenVertexArray
export glDeleteVertexArray
export glGenTexture
export glDeleteTexture
export glGenSampler
export glDeleteSampler
export glGetIntegerval
export glArrayFunc

###############################################################################

CodeGeneration.module_listeners(@__MODULE__)
WindowManager.addListener(@__MODULE__)

###############################################################################

DRIVER_INITALIZED = false

init() = global DRIVER_INITALIZED = true

########################################################

ListElementType = GLuint
ListType = Dict{Symbol,Array{ListElementType, 1}}
lists = Dict{Symbol,Dict{Symbol,Any}}()
lists[:BUFFER] = Dict(:LIST=>ListType(),:CREATE=>glGenBuffers,:DELETE=>glDeleteBuffers)
lists[:FRAMEBUFFER] = Dict(:LIST=>ListType(),:CREATE=>glGenFramebuffers,:DELETE=>glDeleteFramebuffers)
lists[:RENDERBUFFER] = Dict(:LIST=>ListType(),:CREATE=>glGenRenderbuffers,:DELETE=>glDeleteRenderbuffers)
lists[:VERTEXARRAY] = Dict(:LIST=>ListType(),:CREATE=>glGenVertexArrays,:DELETE=>glDeleteVertexArrays)
lists[:TEXTURE] = Dict(:LIST=>ListType(),:CREATE=>glGenTextures,:DELETE=>glDeleteTextures)
lists[:SAMPLER] = Dict(:LIST=>ListType(),:CREATE=>glGenSamplers,:DELETE=>glDeleteSamplers)
#lists[:PROGRAM] = Dict(:LIST=>GLuint[],:CREATE=>(count,objs)->glCreate(count,objs,glCreateProgram),:DELETE=>(len,ids)->glDelete(ids,glDeleteProgram))
##################################################

"""
TODO
"""
function create(typ::Symbol, id::Symbol, count::Number)
  if count <=0 return nothing end

  l=lists[typ]
  biglist=l[:LIST]

  #objs=zeros(GLuint,count)
  #l[:CREATE](count, objs)
  #for obj in objs push!(l[:LIST], obj) end

  if !haskey(biglist, id) biglist[id] = ListElementType[] end
  list = biglist[id]

  if count > length(list)
    objs=zeros(ListElementType,count)
    glArrayFunc(objs, l[:CREATE]) #(count, objs)
    for obj in objs push!(list, obj) end
  else
    objs = ListElementType[]
    index=0
    checkList = Dict{ListElementType,Nothing}()
    for obj in list
      if haskey(checkList, obj) warn("$typ : $id has duplicated id = $obj")
      elseif obj <= 0  warn("$typ : $id has wrong id <= 0")
      else
        checkList[obj] = nothing
        push!(objs, obj)
        index+=1
      end
      #end
      if index>=count break end
    end
  end

  objs
end

"""
TODO
"""
function delete(typ::Symbol, ids::Array{ListElementType,1})
  error("Not implemented yet!")
  #global lists; l=lists[typ]
  #l[:DELETE](length(ids), ids)
  #l[:LIST] = filter!(e->e∉ids,l[:LIST])
end

"""
TODO
"""
create(typ::Symbol, id::Symbol) = create(typ, id, 1)[1]

"""
TODO
"""
delete(typ::Symbol, id::ListElementType) = delete(typ, ListElementType[id])

"""
TODO
"""
function delete(typ::Symbol;freememory=true)
  l=lists[typ]
  rmlist=ListElementType[]
  for (_, list) in l[:LIST] rmlist = vcat(rmlist, list...) end
  if freememory glArrayFunc(rmlist, l[:DELETE]) end
  l[:LIST] = typeof(l[:LIST])()
end

"""
TODO
"""
cleanLists(hascontext=true) = for typ in keys(lists) delete(typ;freememory=hascontext) end

"""
TODO
"""
freeMemory() = cleanLists()

########################################################

"""
TODO
"""
function cleanUp()
  #println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  global DRIVER_INITALIZED
  if DRIVER_INITALIZED == false return end
  callOnListeners(:cleanUp)
  cleanLists(false) #has no context, because window is already closed
  global DRIVER_INITALIZED = false
end

########################################################

BackupSource=Dict{Symbol,String}()

"""
TODO
"""
function createShader(name::Symbol, infos::Dict{Symbol,Any})
  pname = stringColor(name;color=:yellow)
  key = Symbol(infos[:path]); file = infos[:file]; typ = infos[:shader]; source = infos[:content]; err=false
  source = string(strip(replace(source,"\r"=>"")))

  typname="?"
  if typ == :VSH typ = GL_VERTEX_SHADER; typname="VERTEX SHADER"
  elseif typ == :FSH typ = GL_FRAGMENT_SHADER; typname="FRAGMENT SHADER"
  elseif typ == :GSH typ = GL_GEOMETRY_SHADER; typname="GEOMETRY SHADER"
  elseif typ == :CSH typ = GL_COMPUTE_SHADER; typname="COMPUTE SHADER"
  end

  # Create the shader
  shader = @GLCHECK glCreateShader(typ)::GLuint
  if shader == 0 LogManager.error("[$pname] Error creating $typname: ", glErrorMessage()); return -1 end

  shdir=RessourceManager.getPath(:SHADERS)
  tmpdir=joinpath(shdir,"tmp/") #joinpath(@__DIR__,"../shaders/tmp/")
  backupdir=joinpath(shdir,"backup/") #joinpath(@__DIR__,"../shaders/backup/")

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
function createShaderProgram(shaders::AbstractArray; transformfeedback=false, name::Union{Nothing,Symbol}=nothing)
  # Create, link then return a shader program for the given shaders.
  # Create the shader program
  prog = @GLCHECK glCreateProgram()

  if name == nothing name = symbol("("*string(prog)*")") end
  pname = stringColor(name;color=:yellow)

  if prog == 0 LogManager.error("Error creating shader program $pname: ", glErrorMessage()) end
  LogManager.debug("Created shader program $pname.")

  # attributes
  #glBindAttribLocation(prog,0,"iVertex") # bind attribute always

  shaderIDs = Int32[]

  for shader in shaders
    shaderID = createShader(name, shader)
    if shaderID > 0
      @GLCHECK glAttachShader(prog, shaderID)
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

    (id->@GLCHECK glDeleteShader(id)).(shaderIDs) # remove shaders

    if status[] == GL_FALSE
      msg = getInfoLog(prog)
      glDeleteProgram(prog)
      LogManager.error("Shader Program $pname: ($prog) Error Linking: $msg")
      prog=-1
    end

    LogManager.debug("Shader Program $pname: ($prog) is initalized.")
  end

  prog
end
export createShaderProgram

end #GraphicsManager
