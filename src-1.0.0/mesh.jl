#module MeshManager

export Transform
export MeshArray
export MeshData
export update
export upload
export linkData
export setAttributes
export setDrawArray


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
mutable struct MeshArray
  elements::UInt32
  count::UInt32
  bufferID::GLuint
  bufferType::GLenum
  bufferUsage::GLenum
  loaded::Bool

  data::AbstractArray
  
  MeshArray() = new(1,0,0,GL_ARRAY_BUFFER,GL_STATIC_DRAW,false,[])
end

"""
data which holds various arrays of mesh 
"""
mutable struct MeshData
  vao::GLuint
  arrays::Dict{Symbol,MeshArray}
  draw::Union{Nothing,MeshArray}

  MeshData() = new(0,Dict(),nothing)
end

gltypes=Dict(Float32=>GL_FLOAT,Float64=>GL_DOUBLE,UInt32=>GL_UNSIGNED_INT,Int32=>GL_INT)

"""
set attributes for shader 
"""
function setAttributes(this::MeshArray, program, attrb; flexible=false)
  if this.count == 0 return end
  
  STRIDE = GLsizei(length(attrb)<=1 ? 0 : reduce(+, (x->sizeof(x[2])*x[3]).(attrb)))
  OFFSET =  C_NULL
  
  glBindBuffer(this.bufferType, this.bufferID)

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
  
  glBindBuffer(this.bufferType, 0)
end

"""
creates gpu buffers
"""
function createBuffers(this::MeshData)
  if this.vao == 0 this.vao = glGenVertexArray() end
  for (s,a) in this.arrays if a.bufferID == 0 && a.count > 0 a.bufferID = glGenBuffer() end end 
end

"""
deletes gpu buffers
"""
function deleteBuffers(this::MeshData)
  if this.vao != 0 glDeleteVertexArray(this.vao); this.vao=0 end
  for (s,a) in this.arrays if a.bufferID != 0 glDeleteBuffer(a.bufferID) end end 
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
  if haskey(this.arrays,:points) list=this.arrays[:points]; setAttributes(list, program, [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,2,0)]) end
  if haskey(this.arrays,:instances) list=this.arrays[:instances]; setAttributes(list, program, [("iInstancePos",Float32,3,1),("iInstanceFlags",Float32,2,1)]) end
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
function setData(this::MeshArray, data, elems=0)
  if elems != 0 this.elements = elems end
  this.data = data
  this.count = length(this.data)/this.elements
end

"""
uploads data
"""
function upload(this::MeshArray, usage=this.bufferUsage)
  if this.loaded || this.count == 0 return end
  glBindBuffer(this.bufferType, this.bufferID)
  glBufferData(this.bufferType, sizeof(this.data), this.data, usage)
  this.loaded=true
end

"""
reset part data
"""
function resetPart(this::MeshArray, id=1, value=0)
  if id < 1 || id > length(this.data) return error("Invalid index for data") end
  glBindBuffer(this.bufferType, this.bufferID)
  part=this.data[id]
  glBufferSubData(this.bufferType , 0, sizeof(part), typeof(part)[value])
  glBindBuffer(this.bufferType, 0)
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
      this.arrays[s] = a = MeshArray()
      a.bufferType = btyp
      a.bufferUsage = usage
    end
    
    setData(a, data, elems)
    
    if draw this.draw = a
    elseif this.draw == nothing this.draw = a
    end
  end

  createBuffers(this)
  upload(this)
end

#end #MeshManager
