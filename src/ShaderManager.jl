__precompile__(false)

module ShaderManager

using ModernGL

using RessourceManager
using LogManager
using FileManager
using GraphicsManager
using GLLists

const GPU = GraphicsManager

mutable struct ShaderProperty
  value::Union{Nothing,Any}
  default::Union{Nothing,Any}
  typ::Union{Nothing,GLenum}
  layout::Union{Nothing,Dict{Symbol,Any}}
  uniform::Bool

  ShaderProperty(;value=nothing,default=nothing,typ=nothing,layout=nothing,uniform=false) = new(value,default,typ,layout,uniform)
end
export ShaderProperty

Uniform(;value=nothing,default=nothing,typ=nothing,layout=nothing) = ShaderProperty(value=value,default=default,typ=typ,layout=layout,uniform=true)
export Uniform

mutable struct ShaderProgram
  id::Integer
  locations::Dict{String, Integer}

  ShaderProgram(id::Integer) = new(id,Dict())
end
export ShaderProgram

abstract type IShaderManager end

mutable struct JShaderManager <: IShaderManager
  programs::Dict{Symbol, ShaderProgram}
  active_program::Union{Nothing, Symbol}

  JShaderManager() = new(Dict(),nothing)
end
export JShaderManager

""" TODO """
getActiveProgram(this::IShaderManager) = this.active_program
export getActiveProgram

function clean(this::IShaderManager)
  delPrograms(this)
end
export clean

""" TODO """
function doProgram(this::IShaderManager, f::Function)
  for (k,p) in this.programs f((k,p)) end
end
export doProgram

""" TODO """
function delPrograms(this::IShaderManager)
  for (k,p) in this.programs
    if this.active_program == k useProgram(this, nothing) end
    glDeleteProgram(p.id)
  end
  this.programs = typeof(this.programs)()
end
export delPrograms

""" TODO """
function useProgram(this::IShaderManager, program::Union{Nothing, Symbol})
  this.active_program = program
  p = program != nothing ? getProgram(this, program) : nothing
  @GLCHECK glUseProgram(program != nothing ? p.id : 0)
  p
end
export useProgram

""" TODO """
hasProgram(this::IShaderManager, program::Symbol) = haskey(this.programs, program)
export hasProgram

""" TODO """
getProgram(this::IShaderManager, program::Symbol) = hasProgram(this, program) ? this.programs[program] : nothing
export getProgram

""" TODO """
setProgram(this::IShaderManager, program::Symbol, id::Integer) = this.programs[program] = ShaderProgram(id)
export setProgram

nested_eltype(x) = nested_eltype(typeof(x))
nested_eltype(::Type{T}) where T<:AbstractArray = nested_eltype(eltype(T))
nested_eltype(::Type{T}) where T = T

#@deprecated
#flatten(a::AbstractArray) = begin try; while true a = vec(a...) end; catch ex; end; a; end

# faster version
function flatten(arr::AbstractArray)
    rst = nested_eltype(arr)[]
    grep(v) = for x in v
        if isa(x, Array) grep(x) else push!(rst, x) end
    end
    grep(arr)
    rst
end

""" TODO """
function delProgram(this::IShaderManager, program::Symbol)
  p = getProgram(this, program)
  if p == nothing return end
  if this.active_program == program useProgram(this, nothing) end
  this.programs = filter((x)->x[1] != program, this.programs)
  @GLCHECK glDeleteProgram(p.id)
  p
end
export delProgram

""" TODO """
function reloadProgram(this::IShaderManager, program::Symbol, shaders::AbstractArray)
  result=false

  #try
    id = createShaderProgram(shaders; name=program)
    if id <= 0 return false end

    if id > 0 && id != getProgram(this, program)
      delProgram(this, program)
      setProgram(this, program, id)
    end
  #catch ex
  #  error("Could not load $program: $ex.")
  #end
  result
end
export reloadProgram

""" TODO """
function setProperty(this::IShaderManager, name::String, value::Any; program::Union{Nothing,Symbol}=this.active_program)
  if program == nothing end
  p = getProgram(this, program)
  if p == nothing return end

  l = glGetUniformLocation(p.id, name)

  if l>-1
    elems=length(value)
    typ=typeof(value)
    dims=0

    if isa(value,AbstractArray)
      sz = size(value)
      typ = nested_eltype(value)
      dims = length(sz) > 1 ? sz[2] : 1
      value = flatten(value) #typ[value...]
      #dims = isa(value, AbstractArray{typ,1}) ? 1 : 2
    end

    t = nothing
    val = typ(0)

    if dims == 0
      t = (l, value)
      elems = 0
    elseif dims == 1 && isa(val, AbstractFloat)
      t = (l, 1, value)
    elseif dims == 2 && isa(val, AbstractFloat)
      t = (l, 1, false, value)
    end

    list = GLLists.UNIFORMS
    f = haskey(list, dims) && haskey(list[dims], elems) && haskey(list[dims][elems], typ) ? list[dims][elems][typ] : nothing

    if t != nothing && f != nothing
      (f)(t...)
    else
      warn("Shader Program $program: Shader Property $name (typ:$(string(typ)), dims:$dims, elems:$elems) is not defined!")
    end
  end
end
export setMode

################################################################################

function getShaderTypeString(value::Any)
  len=length(value)
	isArray = isa(value,AbstractArray)
  typ = isArray ? nested_eltype(value) : typeof(value)
	base_typ = GLLists.BASE_TYPES[typ].name
	type_str=base_typ #float
	if isArray
		if len>=2 && len <= 4
			type_str = (base_typ[1] != 'f' ? base_typ[1] : "")*"vec"*string(len)
			if isa(value[1],AbstractArray) type_str*="["*string(len)*"]" end #vec2[3]
		else type_str*="["*string(len)*"]"  #float[3]
		end
	end
	type_str
end

"""
load all content from shaders located in shaders folder in root dir
"""
function loadShaders(shader_vars=Dict{Symbol,Any}();auto_inputs=false,dir=RessourceManager.getPath(:SHADERS)) #joinpath(@__DIR__,"../shaders/"))
  types=["VSH","FSH","GSH","CSH"]
  uniforms = haskey(shader_vars, :UNIFORMS) ? shader_vars[:UNIFORMS] : Dict()
  globals = haskey(shader_vars, :GLOBALS) ? shader_vars[:GLOBALS] : Dict()

  #shader_files = filter(x->isfile(dir*x) && uppercase(replace(splitext(x)[end],"."=>"")) == "GLSL",readdir(dir))

  list, list_paths = findFiles(dir, "GLSL")

  # replace vars and set types
  for (key,file) in list
    shader=list[key]
    content=file[:content]

    keystr=string(key)
    typ = :NOTHING
    for t in types
      if occursin(t, keystr)
        typ = Symbol(t)
        break
      end
    end

    inputs = ""

    if auto_inputs
      if typ == :FSH
        inputs *="layout(location = 0) out vec4 fragColor;\n"
      else typ == :CSH
        inputs *= "layout(local_size_x = \$iDispatchX, local_size_y = \$iDispatchY, local_size_z = \$iDispatchZ) in;\n"
      end
      if length(inputs)>0 inputs*="\n" end
    end

    if length(uniforms)>0
      for (uname, shp) in uniforms
        ulayout=""
        if shp.layout != nothing
          ulayout = "layout("
          c=0
          for (k,v) in shp.layout
            c+=1
            ulayout*=(c>1 ? ", " : "")*string(k)*(v == nothing ? "" : "="*string(v))
          end
          ulayout *= ") "
        end

        utype = ""
        try
          utype = shp.typ != nothing ? GLLists.LIST_TYPE_STRING[shp.typ] : getShaderTypeString(shp.value)
        catch ex
          warn("Shader Property $uname::$(typeof(shp.value)) is not valid!")
          continue
        end

        uvalue = "" #!haskey(uform, :default) || uform.default == nothing ? "" : *" = "*string(uform.default)
        inputs*=ulayout*"uniform "*utype*" "*string(uname)*uvalue*";\n"
      end
      inputs*="\n"
    end

    vars=(x->x[1]).(collect(eachmatch(r"\$(\w+)",inputs*content)))

    for var in vars
      entry = nothing
      svar=Symbol(var)
      if haskey(globals, svar) entry=string(globals[svar])
      elseif haskey(list, var) entry="\""*list[var][:content]*"\""
      end
      if entry != nothing
        inputs=replace(inputs,"\$"*var=>entry)
        content=replace(content,"\$"*var=>entry)
      end
    end

    shader[:type] = typ
    shader[:inputs] = inputs
    shader[:content] = content
  end

  # replace imports
  found=true
  while found
    found=false
    for (key,file) in list
      content=file[:content]

      if occursin("#import ", content)
        r=collect(eachmatch(r"(\#import\s+\"(\w+(\.\w+)*)\")",content))
        paths=[[x[1],x[2]] for x in r]

        for path in paths
          f=path[2]
          if dirname(f) == "" f=dir*f end
          kkey=Symbol(abspath(f))
          line="// FILE \""*f*"\" NOT FOUND!"
          if haskey(list_paths, kkey) line=list_paths[kkey][:content] end
          content = replace(content,path[1]=>line)
        end

        list[key][:content]=content

        found=true
      end
    end
  end

  # add glsl version
  for (key,file) in list
    file[:content] = get_glsl_version_string()*"\n"*file[:inputs]*file[:content]
  end

  list
end
export loadShaders

#stat("nodes.txt").mtime

end #ShaderManager
