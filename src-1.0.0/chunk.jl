
mutable struct Neighbours6{T} <: FieldVector{6, T}
  left::Union{T,Nothing}
  right::Union{T,Nothing}
  front::Union{T,Nothing}
  back::Union{T,Nothing}
  top::Union{T,Nothing}
  bottom::Union{T,Nothing}
  
  Neighbours6{T}() where T = new(nothing,nothing,nothing,nothing,nothing,nothing)
end

abstract type INode end
abstract type IBlock end
abstract type IChunk end
#RChunk = Union{Nothing,IChunk}

const NodeNeighbours6 = Neighbours6{INode}
const BlockNeighbours = Neighbours6{IBlock}

mutable struct Node6{T} <: INode
  value::Union{T,Nothing}
  next::NodeNeighbours6
  
  Node6{T}() where T = new(nothing,NodeNeighbours6())
  Node6{T}(value::T) where T = new(value,NodeNeighbours6())
end

mutable struct Block <: IBlock
  typ::Int32
  pos::Vec3f
  flags::UInt32
  active::Bool
  visible::Bool
  surrounded::Bool
  sides::Array{UInt32,1}
  
  parent::IChunk
  next::BlockNeighbours
  
  Block(parent::IChunk, pos=Vec3f,typ=0) = new(typ,pos,0,true,true,false,resetSides(),parent,BlockNeighbours()) #,zeros(Mat4x4f),zeros(Mat4x4f))
end

#Base.isless{T}(a::Ref{T}, b::Ref{T}) = a.x < b.x
Base.isless(a::Block, b::Block) = a.pos < b.pos

mutable struct Chunk <: IChunk
  active::Bool
  len::UInt32
  childs::Array{Block,3}
  filtered::Array{Block,1}
  count::UInt32
  fileredCount::UInt32
  
  function Chunk(len::Integer)
    this = new(true,len,Array{Block}(undef,len,len,len),Block[],0,0)
    createBlocks(this)
    linkBlockNeighbours(this)
    this
  end
end

function clean(this::Union{Nothing,Chunk})
  if this == nothing return end
  this.childs = Array{Block}(undef,0,0,0)
  this.filtered = Block[]
  gc() # force garbage collection, free memory
end

isType(this::Block, typ) = this.typ == typ

isValid(this::Chunk) = this.count > 0 && this.fileredCount > 0

isSeen(this::Block) = isActive(this) && isVisible(this) && this.typ > 0

i=0
i+=1; const LEFT_SIDE = i #0x1
i+=1; const RIGHT_SIDE = i #0x2
i+=1; const TOP_SIDE = i #0x4
i+=1; const BOTTOM_SIDE = i #0x8
i+=1; const FRONT_SIDE = i #0x10
i+=1; const BACK_SIDE = i #0x20
const MAX_SIDES = i

resetSides() = fill(UInt32(1),MAX_SIDES)
resetSides(this::Block) = this.sides=resetSides()

function createBlocks(this::Chunk)
  len = this.len
  for x=1:len; for y=1:len; for z=1:len; this.childs[x,y,z] = Block(this,Vec3f(x,y,z)); end; end; end
end

function linkBlockNeighbours(this::Chunk)
  a = this.childs
  len = this.len
  for x=1:len; for y=1:len; for z=1:len; 
    pos = (x,y,z)
    b = getBlock(this,pos)
    b.next.left = getBlock(this,pos,LEFT_SIDE)
    b.next.right = getBlock(this,pos,RIGHT_SIDE)
    b.next.bottom = getBlock(this,pos,BOTTOM_SIDE)
    b.next.top = getBlock(this,pos,TOP_SIDE)
    b.next.back = getBlock(this,pos,BACK_SIDE)
    b.next.front = getBlock(this,pos,FRONT_SIDE)
  end; end; end
end

function getBlock(this::Chunk, pos::Tuple{Integer,Integer,Integer}, side=0)
  a = this.childs
  len = this.len
  (x,y,z) = pos
  b = nothing
  if side == LEFT_SIDE
    b=x>1 ? a[x-1,y,z] : nothing
  elseif side == RIGHT_SIDE
    b=x<len ? a[x+1,y,z] : nothing
  elseif side == BOTTOM_SIDE
    b=y>1 ? a[x,y-1,z] : nothing
  elseif side == TOP_SIDE
    b=y<len ? a[x,y+1,z] : nothing
  elseif side == BACK_SIDE
    b=z>1 ? a[x,y,z-1] : nothing
  elseif side == FRONT_SIDE
    b=z<len ? a[x,y,z+1] : nothing
  else
    b=x>=1&&x<=len&&y>=1&&y<=len&&z>=1&&z<=len ? a[x,y,z] : nothing
  end
  b
end

function hideUnseen(this::Chunk)
  for b in this.childs
    if !isSeen(b) continue end # skip invisible

    blocked=0

    if (next=b.next.left) != nothing
      r=b.sides[LEFT_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
    
    if (next=b.next.right) != nothing
      r=b.sides[RIGHT_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
 
    if (next=b.next.bottom) != nothing
      r=b.sides[BOTTOM_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
    
    if (next=b.next.top) != nothing
      r=b.sides[TOP_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
    
    if (next=b.next.back) != nothing
      r=b.sides[BACK_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
    
    if (next=b.next.front) != nothing
      r=b.sides[FRONT_SIDE]=!isSeen(next)
      if !r blocked+=1 end
    end
    
    setSurrounded(b,blocked >= 6)
  end
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

const FrustumNode = Node6{Tuple{Block,Any}}

printList(list,n=1) = begin
  n = round(n)
  if n<1 error("n < 1 is invalid!") end
  println(typeof(list)," with ",length(list)," entries shows each ",n,n==1 ? "st" : (n==2 ? "nd" : (n==3 ? "rd" : "th"))," element:")
  i=0; for (k,v) in list; i+=1; if i == n i=0; println(" ",k) end; end
  println()
  
  #a = collect(keys(list))[1:X:end]
  #Base.showarray(STDOUT,a,false)
  #show(STDOUT, "text/plain", a)
  #display(a)
  #whos()
end

function checkInFrustum(this::Chunk, fstm::Frustum)
  pos = getNearPosition(fstm)
  list = DataStructures.SortedDict()
  
  
  open("frustum.txt", "w") do f

  for b in this.childs
    result = checkSphere(fstm, b.pos, 1.5)
    clist = result[2]
    visible = result[1] != :FRUSTUM_OUTSIDE
    setVisible(b,visible)
    
    # sort
    if visible
      (x,y,z) = (clist[:X],clist[:Y],clist[:Z])
      write(f, string("[",x,", ",y,", ",z,"]")*"\n")
      
      rx=round(x)
      ry=round(y)
      rz=round(z)
      
      if rx % 2 != 0
        rx+=1;
      end

      k = (rx,ry)
      
      if (abs(x) <= 1 && abs(y) <= 1 && abs(z) <= 1) || z < 0
        setVisible(b,false)
      else
        kv=z=>b
        if haskey(list,k)
        
          p = first(list[k])
          list[k][z] = b
          q = first(list[k])
          
          if p[1] == q[1] kv=p[1]=>p[2] else b=p[2] end
          setVisible(b,false)
        end
        list[k] = DataStructures.SortedDict(kv)
      end
    end
    
    #=
    if visible && false
      current = FrustumNode((b,clist))
      parent = nothing
      if parent == nothing parent = current
      else
        nlist = parent.value[2]
        while true
          lt = clist[:FRUSTUM_LEFT] > clist[:FRUSTUM_TOP]
          l = nlist[:FRUSTUM_LEFT] > clist[:FRUSTUM_LEFT]
          r = nlist[:FRUSTUM_RIGHT] < clist[:FRUSTUM_RIGHT]
          t = nlist[:FRUSTUM_TOP] > clist[:FRUSTUM_TOP]
          b = nlist[:FRUSTUM_BOTTOM] < clist[:FRUSTUM_BOTTOM]
          n = nlist[:FRUSTUM_NEAR] < clist[:FRUSTUM_NEAR]
          f = nlist[:FRUSTUM_FAR] > clist[:FRUSTUM_FAR]
          
          #lr = l>r ? l : r
          #tb = t>b ? t : b
          #nf = n<f ? n : f
        
          if lt
            if l
              next = parent.next.left
              if next == nothing parent.next.left = current
              else parent = next
              end
            elseif r
              next = parent.next.right
              if next == nothing parent.next.right = current
              else parent = next
              end
            end
          else
            if t
              next = parent.next.top
              if next == nothing parent.next.top = current
              else parent = next
              end
            elseif b
              next = parent.next.bottom
              if next == nothing parent.next.bottom = current
              else parent = next
              end
            end
          end
        end
        
      end 
    end
    =#
    
  end
  end
    
  #printList(list,length(list)/10)

  #for (k,z) in list
    #p = k1 + Vec3f(0,0,0)
    #l = k1 + Vec3f(-1,-1,-1)
    #r = k1 + Vec3f(1,1,1)
    
    #skip = true
    #for (k2,b) in z
      #if skip skip=false; continue end
      #if k2 == nothing continue end
      #if p.z - 10 >= k2.z continue end
      #if p.y + 1 >= k2.y continue end
      #if p.y - 1 <= k2.y continue end
      #if l.x <= k2.x continue end
      #if r.x >= k2.x continue end
      #setVisible(b,false)
    #end
  #end
 
end

#------------------------------------------------------------------------------------

setFilteredChilds(this::Chunk, r::Array{Block,1}) = begin this.filtered = r; this.fileredCount = length(r); r end
getFilteredChilds(this::Chunk) = this.filtered

getActiveChilds(this::Chunk) = filter(b->isActive(b),this.childs)
getVisibleChilds(this::Chunk) = filter(b->isVisible(b),this.childs)
getValidChilds(this::Chunk) = filter(b->isValid(b),this.childs)

function getData(this::Block)
  # get visible sides
  i=0; sides=0
  for side in this.sides
    if side > 0 sides |= (0x1 << i) end
    i+=1
  end
  
  #if this.sides[LEFT_SIDE] > 0 sides |= 0x1 end
  #if this.sides[RIGHT_SIDE] > 0 sides |= 0x2 end
  #if this.sides[TOP_SIDE] > 0 sides |= 0x4 end
  #if this.sides[BOTTOM_SIDE] > 0 sides |= 0x8 end
  #if this.sides[FRONT_SIDE] > 0 sides |= 0x10 end
  #if this.sides[BACK_SIDE] > 0 sides |= 0x20 end

  SVector(Float32[this.pos...,this.typ,sides]...)
end

getData(this::Chunk) = isValid(this) ? vec((b->getData(b)).(getFilteredChilds(this))) : Float32[]

function update(this::Chunk)
  this.count = length(this.childs)
  setFilteredChilds(this, getValidChilds(this))
  
  #fill copies references
  #refblocks = Ptr{Nothing}[]
  #for b in this.childs push!(refblocks, pointer_from_objref(b)) end
end

function createSingle(this::Chunk)
  b=this.childs[1,1,1]
  b.pos=Vec3f(0, 0, -10)
  b.typ=1
end

function createExample(this::Chunk)
  DIST = Vec3f(2,2,2); #Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)
  
  translate(x,y,z) = Vec3f(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z)

  x=1; y=1; z=1;

  for i=1:(this.len^3)
    b = this.childs[i];
    b.pos=translate(x-1,y-1,z-1)
    b.typ=rand(1:16)
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
  
  DIST = Vec3f(2,2,2)
  START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)
  
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
        b = this.childs[x,y,z]
        b.pos = translate(x-1,y-1,z-1)
        #if y >= level_air b.typ = 0 # air or nothing
        if y >= level_grass  b.typ = 2 #grass
        elseif y >= level_dirt b.typ = 1 #dirt
        elseif y >= level_stonebricks b.typ = 5 #stonebricks
        elseif y >= level_stone b.typ = 4 #stone
        elseif y >= level_lava b.typ = 15 #lava
        end
      end
    end
  end
   
  h=1 #UInt32(trunc(this.len/2))
  b = this.childs[h,h,h]
  b.pos=Vec3f(0,0,0)
  b.typ=7
end
