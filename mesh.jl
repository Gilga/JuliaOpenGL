type Transform
  model::Mat4x4f
  mvp::Mat4x4f
end

type MeshArray
  elements::UInt32
  count::UInt32
  bufferID::GLuint
  bufferType::GLenum
  loaded::Bool

  data::AbstractArray
  
  MeshArray() = new(1,0,0,GL_ARRAY_BUFFER,false,[])
end

#fieldnames

type MeshData
  vao::GLuint
  arrays::Dict{Symbol,MeshArray}
  draw::Union{Void,MeshArray}

  MeshData() = new(0,Dict(),nothing)
end

function setAttributePosition(this::MeshArray, program)
  if this.count == 0 return end
  glBindBuffer(this.bufferType, this.bufferID)
  positionAttribute = glGetAttribLocation(program, "position")
  glEnableVertexAttribArray(positionAttribute)
  glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, 0, C_NULL)
  glBindBuffer(this.bufferType, 0)
end

function setAttributeInstance(this::MeshArray, program)
  if this.count == 0 return end
  glBindBuffer(this.bufferType, this.bufferID)
  instanceMatrixAttribute = glGetAttribLocation(program, "instance")
  glEnableVertexAttribArray(instanceMatrixAttribute)
  glVertexAttribPointer(instanceMatrixAttribute, 4, GL_FLOAT, GL_FALSE, 0, C_NULL)
  glVertexAttribDivisor(instanceMatrixAttribute, 1)
  glBindBuffer(this.bufferType, 0)
end

function createBuffers(this::MeshData)
  if this.vao == 0 this.vao = glGenVertexArray() end
  for (s,a) in this.arrays if a.bufferID == 0 && a.count > 0 a.bufferID = glGenBuffer() end end 
end

function setAttributes(this::MeshData, program)
  glBindVertexArray(this.vao)
  if haskey(this.arrays,:vertices) setAttributePosition(this.arrays[:vertices], program) end
  if haskey(this.arrays,:instances) setAttributeInstance(this.arrays[:instances], program) end
  glBindVertexArray(0)
end

function setDrawArray(this::MeshData, key::Symbol)
  this.draw = this.arrays[key]
end

function setData(this::MeshArray, data, elems=0)
  if elems != 0 this.elements = elems end
  this.data = data
  this.count = length(this.data)/this.elements
end

function linkData(this::MeshData, args...)
  d=Dict(args)
  
  for (s,x) in d
    l=isa(x,Tuple)?length(x):0
    
    data = l>0?x[1]:x
    dtyp = eltype(data)
    elems = l>1?x[2]:1
    btyp = l>2?x[3]:GL_ARRAY_BUFFER
    draw = l>3?x[4]:false
    
    if haskey(this.arrays,s)
      a = this.arrays[s]
      a.loaded = false
    else
      this.arrays[s] = a = MeshArray()
      a.bufferType = btyp
    end
    
    setData(a, data, elems)
    
    if draw this.draw = a
    elseif this.draw == nothing this.draw = a
    end
  end
  
  createBuffers(this)
  upload(this)
end

function upload(this::MeshArray)
  if this.loaded || this.count == 0 return end
  const data = this.data
  glBindBuffer(this.bufferType, this.bufferID)
  glBufferData(this.bufferType, sizeof(data), data, GL_STATIC_DRAW)
  this.loaded=true
end

function upload(this::MeshData)
  glBindVertexArray(this.vao)
  for (s,a) in this.arrays upload(a) end
  glBindVertexArray(0)
end

# just update previous data
function upload(this::MeshData, key::Symbol, data::AbstractArray)
  a=this.arrays[key]
  setData(a, data)
  a.loaded = false
  glBindVertexArray(this.vao)
  upload(a)
  glBindVertexArray(0)
end
