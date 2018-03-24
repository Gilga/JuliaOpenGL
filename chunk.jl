
struct HeptaOrder{T} <: FieldVector{6, T}
  front::Union{T,Void}
  back::Union{T,Void}
  left::Union{T,Void}
  right::Union{T,Void}
  top::Union{T,Void}
  bottom::Union{T,Void}
end

type Block
  typ::Int32
  pos::Vec3f
  flags::UInt32
  active::Bool
  visible::Bool
  surrounded::Bool
  sides::Array{UInt32,1}
  friends::HeptaOrder{Block}
end

const BlockOrder = HeptaOrder{Block}
BlockOrder() = HeptaOrder{Block}(nothing,nothing,nothing,nothing,nothing,nothing)
Block(pos=Vec3f,typ=0) = Block(typ,pos,0,true,true,false,resetSides(),BlockOrder()) #,zeros(Mat4x4f),zeros(Mat4x4f))

type Chunk
  active::Bool
  len::UInt32
  childs::Array{Block,3}
  filtered::Array{Block,1}
  count::UInt32
  fileredCount::UInt32
  
  function Chunk(len::Integer)
    this = new(true,len,Array{Block,3}(len,len,len),Block[],0,0)
    for x=1:len; for y=1:len; for z=1:len; this.childs[x,y,z] = Block(Vec3f(x,y,z)); end; end; end
    this
  end
end

function clean(this::Union{Void,Chunk})
  if this == nothing return end
  this.childs = Array{Block,3}(0,0,0)
  this.filtered = Block[]
  gc() # force garbage collection, free memory
end

isType(this::Block, typ) = this.typ == typ

isValid(this::Chunk) = this.count > 0 && this.fileredCount > 0

isSeen(this::Block) = isActive(this) && isVisible(this) && this.typ > 0

MAX_SIDES = 6

LEFT_SIDE = 1 #0x1
RIGHT_SIDE = 2 #0x2
TOP_SIDE = 3 #0x4
BOTTOM_SIDE = 4 #0x8
FRONT_SIDE = 5 #0x10
BACK_SIDE = 6 #0x20

resetSides() = fill(UInt32(1),MAX_SIDES)
resetSides(this::Block) = this.sides=resetSides()

function hideUnseen(this::Chunk)
  a = this.childs
  len = this.len

  for x=1:len; for y=1:len; for z=1:len;
  
    b=a[x,y,z]

    if !isSeen(b) continue end # skip invisible
    #if  x==1 || y==1 || z==1 || x==len || y==len || z==len continue end  # skip border
    
    blocked=0
    
    if x>1
      r=b.sides[LEFT_SIDE]=!isSeen(a[x-1,y,z])
      if r blocked+=1 end
    end
    
    if x<len
      r=b.sides[RIGHT_SIDE]=!isSeen(a[x+1,y,z])
      if r blocked+=1 end
    end
 
    if y>1
      r=b.sides[BOTTOM_SIDE]=!isSeen(a[x,y-1,z])
      if r blocked+=1 end
    end
    
    if y<len
      r=b.sides[TOP_SIDE]=!isSeen(a[x,y+1,z])
      if r blocked+=1 end
    end
    
    if z>1
      r=b.sides[BACK_SIDE]=!isSeen(a[x,y,z-1])
      if r blocked+=1 end
    end
    
    if z<len
      r=b.sides[FRONT_SIDE]=!isSeen(a[x,y,z+1])
      if r blocked+=1 end
    end
    
    setSurrounded(b,blocked >= 6)
    
  end; end; end
end

function setFlag(this::Block, flag::Unsigned, add::Bool)
    if add this.flags |= flag
    else this.flags ⊻= flag #⊻ = xor and is not shown on windows...
    end
end

isActive(this::Block) = this.active
isVisible(this::Block) = this.visible
isSurrounded(this::Block) = this.surrounded

isValid(this::Block) = isActive(this) && isVisible(this) && !isSurrounded(this) && this.typ > 0

setActive(this::Block, active::Bool) = this.active = active
setVisible(this::Block, visible::Bool) = this.visible = visible
setSurrounded(this::Block, surrounded::Bool) = this.surrounded = surrounded

hideType(this::Chunk, typ::Integer) = for b in this.childs; if b.typ == typ; setVisible(b,false); end; end
removeType(this::Chunk, typ::Integer) = for b in this.childs; if b.typ == typ; setActive(b,false); end; end

showAll(this::Chunk) = for b in this.childs
  setVisible(b,true)
  setSurrounded(b,false)
  resetSides(b)
end

checkInFrustum(this::Chunk, fstm::Frustum) = for b in this.childs setVisible(b,checkSphere(fstm, b.pos, 1.5) != 0) end

#------------------------------------------------------------------------------------

setFilteredChilds(this::Chunk, r::Array{Block,1}) = begin this.filtered = r; this.fileredCount = length(r); r end
getFilteredChilds(this::Chunk) = this.filtered

getActiveChilds(this::Chunk) = filter(b->isActive(b),this.childs)
getVisibleChilds(this::Chunk) = filter(b->isVisible(b),this.childs)
getValidChilds(this::Chunk) = filter(b->isValid(b),this.childs)

function getData(this::Block)
  
  sides=0
  if this.sides[LEFT_SIDE] > 0 sides |= 0x1 end
  if this.sides[RIGHT_SIDE] > 0 sides |= 0x2 end
  if this.sides[TOP_SIDE] > 0 sides |= 0x4 end
  if this.sides[BOTTOM_SIDE] > 0 sides |= 0x8 end
  if this.sides[FRONT_SIDE] > 0 sides |= 0x10 end
  if this.sides[BACK_SIDE] > 0 sides |= 0x20 end
  
  # get visible sides
  #i=0; sides=0
  #for side in this.sides
  #  if side > 0 sides |= (0x1 << i) end
  #  i+=1
  #end

  #count = MAX_SIDES*5
  #a=fill(0f0,count)
  #i=1
  
  #for side in this.sides
  #  for p in this.pos a[i] = p; i+=1 end
  #  a[i] = this.typ; i +=1
  #  a[i] = side; i +=1
  #end
   
  #SVector(Float32[
  #  this.pos...,this.typ,0,sides
  #  this.pos...,this.typ,1,sides
  #  this.pos...,this.typ,2,sides
  #  this.pos...,this.typ,3,sides
  #  this.pos...,this.typ,4,sides
  #  this.pos...,this.typ,5,sides
  #]...)
  
  SVector(Float32[this.pos...,this.typ,sides]...)
end

getData(this::Chunk) = isValid(this)?vec((b->getData(b)).(getFilteredChilds(this))):Float32[]

function update(this::Chunk)
  this.count = length(this.childs)
  setFilteredChilds(this, getValidChilds(this))
  
  #fill copies references
  #refblocks = Ptr{Void}[]
  #for b in this.childs push!(refblocks, pointer_from_objref(b)) end
end

function createSingle(this::Chunk)
  this.childs[1,1,1] = Block(Vec3f(0, 0, -10),1) 
end

function createExample(this::Chunk)
  const DIST = Vec3f(2,2,2); #Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  const START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)
  
  translate(x,y,z) = Vec3f(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z)

  x=1; y=1; z=1;

  for i=1:(this.len^3)
    this.childs[i] = b = Block(translate(x-1,y-1,z-1),rand(1:16))
    #model = Mat4x4f(translation(Array(b.pos)))
    #push!(refblocks, pointer_from_objref(b))
    
    x += 1; if x > this.len
      y += 1; x=1;
      if y > this.len z += 1; y=1;
        if z > this.len break; end
      end
    end
  end
end

function createLandscape(this::Chunk)
  #Texture* heightTexture = m_pRenderer->GetTexture(m_pChunkManager->GetHeightMapTexture());
  
  rgbImage=Images.load("heightmap.jpg")
  (imgwidth, imgheight) = size(rgbImage)

  grayImage = Gray.(rgbImage)
  imgMatrix = reinterpret.(channelview(grayImage)) #convert(Array{Int32},raw(grayImage))

  w = imgwidth/this.len
  h = imgheight/this.len
  
  const DIST = Vec3f(2,2,2)
  const START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)
  
  translate(x,y,z) = Vec3f(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z)
  
  for x=1:this.len
    for z=1:this.len
      # Use the height map texture to get the height value of x, z
      height = (imgMatrix[UInt32(trunc(z*h)), UInt32(trunc(x*w))] / 0xFF)* 1.25 * this.len
      if height >= this.len height=this.len end
      
      level_air = height * 0.95
      level_grass = height * 0.9
      level_dirt = height * 0.8
      level_stonebricks = height * 0.7
      level_stone = height * 0.4
      level_lava = height * 0

      for y=1:UInt32(round(height))
        #id = y*this.len^2+z*this.len+x
        #c = this.childs[id]
        #c.active = true
        b = Block(translate(x-1,y-1,z-1))
        #if y >= level_air b.typ = 0 # air or nothing
        if y >= level_grass  b.typ = 2 #grass
        elseif y >= level_dirt b.typ = 1 #dirt
        elseif y >= level_stonebricks b.typ = 5 #stonebricks
        elseif y >= level_stone b.typ = 4 #stone
        elseif y >= level_lava b.typ = 15 #lava
        end
        if b.typ > 0 this.childs[x,y,z]=b end #push!(this.childs,b) end
      end
    end
  end
   
  h=1 #UInt32(trunc(this.len/2))
  this.childs[h,h,h] = Block(Vec3f(0,0,0),7)
end
