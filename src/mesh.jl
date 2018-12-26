module MeshManager

using ..Math
using ..LogManager
using ..GraphicsManager

using ModernGL

export Transform
export MeshBuffer
export MeshData
export update
export upload
export linkData
export setAttributes
export setDrawArray
export createBuffer
export createBuffers
export getMeshBufferRefID
export createArrayObjects

"""
object which holds a transformation matrix and a model reference
"""
mutable struct Transform
  model::Mat4x4f
  mvp::Mat4x4f
end

"""
array which holds raw data of mesh
"""
mutable struct MeshBuffer
  elements::UInt32
  count::UInt32
  refID::GLuint
  typ::GLenum
  usage::GLenum
  loaded::Bool

  data::AbstractArray
  
  function MeshBuffer(typ=GL_ARRAY_BUFFER,usage=GL_STATIC_DRAW,data=[]; refID=0, elems=1)
    this=new(elems,0,refID,typ,usage,false,data)
    if length(data)>0 setData(this, data) end
    this
  end
end

function getMeshBufferRefID(buffers::Array{MeshBuffer,1})
  [buffer.refID for buffer in buffers]
end

"""
data which holds various arrays of mesh 
"""
mutable struct MeshData
  vao::GLuint
  arrays::Dict{Symbol,MeshBuffer}
  draw::Union{Nothing,MeshBuffer}

  MeshData() = new(0,Dict(),nothing)
end

gltypes=Dict(Float32=>GL_FLOAT,Float64=>GL_DOUBLE,UInt32=>GL_UNSIGNED_INT,Int32=>GL_INT)

"""
set attributes for shader 
"""
function setAttributes(this::MeshBuffer, program, attrb; flexible=false, typ=0)
  if this.count == 0 return end
  
  STRIDE = GLsizei(length(attrb)<=1 ? 0 : reduce(+, (x->sizeof(x[2])*x[3]).(attrb)))
  OFFSET =  C_NULL
  
  glBindBuffer(typ<=0 ? this.typ : typ, this.refID)
  #glBufferData(this.typ, sizeof(this.data), this.data,  this.usage)

  index=-1
  for (name,typ,elems,inst) in attrb
    index+=1
    atr = glGetAttribLocation(program, name)
    glCheckError("glGetAttribLocation")
    if flexible && atr <= -1 atr=index end
    if  atr > -1
      #typ = nothing; old = this.data
      #while true typ = eltype(old); if typ == old break; else old=typ; end; end
      glEnableVertexAttribArray(atr)
      glCheckError("glEnableVertexAttribArray")
      glVertexAttribPointer(atr, elems, gltypes[typ], GL_FALSE, STRIDE, OFFSET)
      glCheckError("glVertexAttribPointer")
      if inst>0 glVertexAttribDivisor(atr, inst); glCheckError("glVertexAttribDivisor") end
      OFFSET +=  sizeof(typ)*elems
    else warn("Could not load Attribute \"$name\"")
    end
  end
  
  glBindBuffer(this.typ, 0)
end

"""
creates vaos
"""
function createArrayObjects(count=1)
  arrays=zeros(GLuint,count)
  glGenVertexArrays(count, arrays)
  arrays
end

"""
creates gpu buffers
"""
function createBuffers(this::MeshData)
  if this.vao == 0 this.vao = glGenVertexArray() end
  for (s,a) in this.arrays if a.refID == 0 && a.count > 0 a.refID = glGenBuffer() end end 
end

function createBuffers(data::AbstractArray, count=1; size=0, typ=GL_ARRAY_BUFFER, usage=GL_STATIC_DRAW)
  list=Array{MeshBuffer,1}(undef, count)
  
  buffers=zeros(GLuint,count)
  glGenBuffers(count, buffers)
  
  has_data = length(data) > 0
  if size <= 0 size = sizeof(data) end
  
  for i=1:count
    buffer = MeshBuffer(typ,usage,data; refID=buffers[i],elems=1)
    list[i]=buffer
    
    glBindBuffer(typ, buffer.refID)
    glBufferData(typ, size, has_data ? buffer.data : C_NULL,  usage)
  end
  glBindBuffer(typ, 0)
  
  list
end

function createBuffer(data::AbstractArray, count=1; typ=GL_ARRAY_BUFFER, usage=GL_STATIC_DRAW)
  refID=glGenBuffer()
  buffer=MeshBuffer(typ,usage,data; refID=refID,elems=1)
  glBindBuffer(buffer.typ, buffer.refID)

  list=Array{eltype(data),1}()
  for i=1:count  list=vcat(list,data) end
  setData(buffer,list)
  
  glBufferData(buffer.typ, sizeof(buffer.data), buffer.data, buffer.usage) #length(data) > 0 ? buffer.data : C_NULL
  glBindBuffer(buffer.typ, 0)
  
  buffer
end

"""
deletes gpu buffers
"""
function deleteBuffers(this::MeshData)
  if this.vao != 0 glDeleteVertexArray(this.vao); this.vao=0 end
  for (s,a) in this.arrays if a.refID != 0 glDeleteBuffer(a.refID) end end 
  this.arrays = Dict()
  this.draw = nothing
end

"""
sets attributes for shader 
"""
function setAttributes(this::MeshData, program; flexible=false)
  glBindVertexArray(this.vao)
  glCheckError("glBindVertexArray")
  if haskey(this.arrays,:vertices) list=this.arrays[:vertices]; setAttributes(list, program, [("iVertex",Float32,list.elements,0)]) end
  if haskey(this.arrays,:points) list=this.arrays[:points]; setAttributes(list, program, [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)]) end
  if haskey(this.arrays,:instances) list=this.arrays[:instances]; setAttributes(list, program, [("iInstancePos",Float32,3,1),("iInstanceFlags",Float32,3,1)]) end
  glBindVertexArray(0)
end

"""
sets attributes for shader 
"""
function setAttributes(this::MeshData, buffers::Array{MeshBuffer,1}, program)
  glBindVertexArray(this.vao)
  for buffer in buffers
    setAttributes(buffer, program, [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)])
  end
  glBindVertexArray(0)
end

"""
sets attributes for shader 
"""
function setAttributes(vaos::Array{GLuint,1}, buffers::Array{MeshBuffer,1}, program)
  len=length(vaos)
  if len < length(buffers) warn("Object (VAO) count cannot be smaller than buffer count"); return end
  for i=1:len
    vao=vaos[i]
    buffer=buffers[i]
    glBindVertexArray(vao)
    setAttributes(buffer, program, [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)])
  end
  glBindVertexArray(0)
end

"""
sets array which will be drawn by opengl
"""
function setDrawArray(this::MeshData, key::Symbol)
  this.draw = this.arrays[key]
end

"""
sets data
"""
function setData(this::MeshBuffer, data, elems=0)
  if elems != 0 this.elements = elems end
  this.data = data
  this.count = length(this.data)/this.elements
end

"""
uploads data
"""
function upload(this::MeshBuffer, usage=this.usage)
  if this.loaded || this.count == 0 return end
  glBindBuffer(this.typ, this.refID)
  glBufferData(this.typ, sizeof(this.data), this.data, usage)
  this.loaded=true
end

"""
reset part data
"""
function resetPart(this::MeshBuffer, id=1, value=0)
  if id < 1 || id > length(this.data) return error("Invalid index for data") end
  glBindBuffer(this.typ, this.refID)
  part=this.data[id]
  glBufferSubData(this.typ , 0, sizeof(part), typeof(part)[value])
  glBindBuffer(this.typ, 0)
end

"""
uploads data
"""
function upload(this::MeshData)
  glBindVertexArray(this.vao)
  for (s,a) in this.arrays upload(a) end
  glBindVertexArray(0)
end

"""
uploads data
"""
function upload(this::MeshData, key::Symbol, data::AbstractArray)
   if !haskey(this.arrays,key) warn("Could not find key $key"); return end
  a=this.arrays[key]
  setData(a, data)
  a.loaded = false
  glBindVertexArray(this.vao)
  upload(a)
  glBindVertexArray(0)
end

"""
links data
"""
function linkData(this::MeshData, args...)
  d=Dict(args)
  
  deleteBuffers(this)
  
  for (s,x) in d
    l=isa(x,Tuple) ? length(x) : 0
    
    data = l>0 ? x[1] : x
    dtyp = eltype(data)
    elems = l>1 ? x[2] : 1
    btyp = l>2 ? x[3] : GL_ARRAY_BUFFER
    usage = l>3 ? x[4] : GL_STATIC_DRAW
    draw = l>4 ? x[5] : false
    
    if haskey(this.arrays,s)
      a = this.arrays[s]
      a.loaded = false
    else
      this.arrays[s] = a = MeshBuffer()
      a.typ = btyp
      a.usage = usage
    end
    
    setData(a, data, elems)
    
    if draw this.draw = a
    elseif this.draw == nothing this.draw = a
    end
  end

  createBuffers(this)
  upload(this)
end

end #MeshManager
