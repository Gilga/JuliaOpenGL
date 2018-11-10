module ChunkManager

using ..Math
using ..LogManager
using ..FrustumManager

using StaticArrays
using JLD2
using Images

export Block
export Chunk
export ChunkNode
export reset
export update
export showAll
export getData
export createSingle
export createExample
export createLandscape
export checkInFrustum
export getActiveChilds
export getVisibleChilds
export getValidChilds
export getFilteredChilds

GPU_CHUNKS = false

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
abstract type IBlock <: INode end
abstract type IChunk <: INode end
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
  active::Bool
  visible::Bool
  surrounded::Bool
  typ::Int32
  flags::UInt32
  pos::Vec3f
  index::Vec3f
  sides::Array{UInt32,1}
  parent::Union{Nothing,IChunk}
  next::BlockNeighbours
  
  Block(parent::IChunk, pos=Vec3f(), typ=0) = new(true,true,false,typ,0,pos,Vec3f(),resetSides(),parent,BlockNeighbours()) #,zeros(Mat4x4f),zeros(Mat4x4f))
end

#Base.isless{T}(a::Ref{T}, b::Ref{T}) = a.x < b.x
Base.isless(a::Block, b::Block) = a.pos < b.pos

mutable struct ChunkNode <: IChunk
  active::Bool
  visible::Bool
  pos::Vec3f
  index::Vec3f
  nodes::Array{INode,1}
  parent::Union{Nothing,IChunk}
  
  function ChunkNode(parent::IChunk, len::Integer)
    this = new(true,true,Vec3f(),Vec3f(),Array{INode}(undef,len),parent)
  end
end

mutable struct Chunk <: IChunk
  active::Bool
  visible::Bool
  pos::Vec3f
  index::Vec3f
  count::UInt32
  fileredCount::UInt32
  childs::Array{Block,3}
  filtered::Array{Block,1}
  nodes::Array{ChunkNode,1}
  parent::Union{Nothing,IChunk}
  
  Chunk() = new(true,true,Vec3f(),Vec3f(),0,0,Array{Block}(undef,0,0,0),Block[],Array{ChunkNode}(undef,0),nothing)
end

function init(this::Chunk, size::Integer)
    this.count = size^3
    this.childs = Array{Block}(undef,size,size,size)
    createBlocks(this)
        
    #if GPU_CHUNKS linkBlockNeighbours(this); return end
    createChunkNodes(this)
    linkBlockNeighbours(this)
end

function update(this::Chunk;unseen=true)
  #if GPU_CHUNKS && unseen hideUnseen(this); return end
  updateChunkNodePos(this)
  if unseen hideUnseen(this) end
  #r=create_spiral3D_searchlist(this)
end

function reset(this::Chunk; size=64)
  clean(this)
  init(this,size)
end

function clean(this::Union{Nothing,Chunk})
  if this == nothing return end
  this.childs = Array{Block}(undef,0,0,0)
  this.nodes = Array{ChunkNode}(undef,0)
  this.filtered = Block[]
  GC.gc() # force garbage collection, free memory
end

getPosition(this::INode) = this.pos

function isActive(this::INode)
  if !this.active return false end
  node=this
  #while (parent = parent.parent) != nothing if !parent.active return false end end
  true
end

function isVisible(this::INode)
  if !this.visible return false end
  node=this.parent
  #while node != nothing if !node.visible return false else node=node.parent; end end
  true
end

setActive(this::INode, active::Bool) = this.active = active
setVisible(this::INode, visible::Bool) = this.visible = visible

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

#=
function createChunkNodes_recurive(this::Chunk, depth=size(this.childs)[1], node::IChunk=this, index=0, pos=ones(UInt,3); len=8)
  if index > 0 node = ChunkNode(node, len) end
  depth = round(UInt,depth/2)
  if depth > 1 for i=1:len node.nodes[i] = createChunkNodes(this, depth, node, i, getIndex(i, depth, pos)) end
  else
    for i=1:len
      x,y,z = getIndex(i, depth, pos)
      node.nodes[i] = b = this.childs[x,z,y]
      this.parent=node
    end
  end
  node
end
=#

function getIndex(i, depth, vindex)
  x=(i == 1 || i == 3 || i == 5 || i == 7) ? 0 : 1
  z=(i == 1 || i == 2 || i == 5 || i == 6) ? 0 : 1
  y=(i >= 1 && i <= 4) ? 0 : 1
  vindex + [x,z,y] * depth
end

function createChunkNodes(this::Chunk)
  SIZE=size(this.childs)[1]
  this.nodes=Array{ChunkNode}(undef,8)
  depths=zeros(UInt,round(UInt,log(2,SIZE)))
  max_depth = length(depths)
  scale=[2^(max_depth-i) for i=1:max_depth] #[32,16,8,4,2,1]
  depth=1
  count = 0
  len=length(this.childs)
  default_index=ones(UInt,3)
  node = this

  while depth > 0 && count <= len
    depths[depth]+=1
    index = depths[depth]
    if index > 8
      depths[depth]=0
      depth-=1
      node=node.parent
      continue
    end
    
    x,z,y = cindex = getIndex(index, scale[depth], depth == 1 ? default_index : node.index)
    child = depth < max_depth ? ChunkNode(node, 8) : this.childs[UInt(x),UInt(z),UInt(y)]
    child.index = cindex
    
    node.nodes[index] = child
    child.parent=node
    
    if depth < max_depth depth+=1; node=child; else count+=1;end
  end
end

function itranslate(this::INode, SIZE::Integer)
  x,z,y = this.index
  X, Y, Z = SIZE, SIZE, SIZE
  DIST = Vec3f(2,2,2); #Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  START = Vec3f(-(X*DIST.x) / 2.0f0, -(Y*DIST.y) / 2.0f0, (Z*DIST.z) / 2.0f0)
  Vec3f(START.x+(x-1)*DIST.x, START.y+(y-1)*DIST.y, START.z-(z-1)*DIST.z)
end

function updateChunkNodePos(this::Chunk)
  SIZE=size(this.childs)[1]
  depths=zeros(UInt,round(UInt,log(2,SIZE)))
  max_depth = length(depths)
  depth=1
  count = 0
  len=length(this.childs)
  node = this

  while depth > 0 && count <= len
    depths[depth]+=1
    index = depths[depth]
    if index > 8
      node.index = Vec3f();
      for child in node.nodes node.index += child.index end
      node.index /= 8
      node.pos = itranslate(node, SIZE)
      depths[depth]=0
      depth-=1
      node=node.parent
      continue
    end
    child = node.nodes[index]
    if depth < max_depth depth+=1; node=child; else count+=1; child.pos = itranslate(child, SIZE); end
  end
end

function checkInFrustum(this::Chunk, fstm::Frustum)
  depths=[0,0,0,0,0,0]
  scale=[32,16,8,4,2,1]
  max_depth = length(depths)
  depth=1
  count = 0
  len=length(this.childs)
  node = this
  list = Block[]
    
  #setFilteredChilds(this,getValidChilds(this))
  #return true
  
  #for b in this.childs setVisible(b, false) end
  
  #println("done.")
  #open("nodes.txt", "w") do f
  while depth > 0 && count <= len
    depths[depth]+=1
    index = depths[depth]
    
    if index <= 1
      #write(f, string(repeat(" ",depth-1),"{ ",scale[depth]," : ",  depth>1 ? depths[depth-1] : 0, "\n"))
    elseif index > 8
      #write(f, string(repeat(" ",depth-1),"} ", scale[depth]," : ", depth>1 ? depths[depth-1] : 0, "\n"))
      depths[depth]=0;
      depth-=1;
      node=node.parent
      continue
    end
    child = node.nodes[index]

    #visible = true
    #if typeof(child) == Block
    p = getPosition(child)
    #result = checkCube(fstm, p, Vec3f([1,1,1] * scale[depth]))[1]
    result = checkSphere(fstm, p, scale[depth] * 1.5)[1]
    visible = result != :FRUSTUM_OUTSIDE
    #write(f, string(repeat(" ",depth),depth >= max_depth ? "L" : "C",index,": ",p[1],", ",p[2],", ",p[3],visible ? "" : " ---> R ", "\n"))
    setVisible(child, visible)
    #end

     #result == :FRUSTUM_INTERSECT
    if depth >= max_depth
      count+=1;
      if isValid(child)
        push!(list, child)
        #=write(f, string(count,"\n"));=#
      end
    elseif visible
      #if depth == 5 && !visible continue end
      depth+=1; node=child
    end
  end
  #end
  
  setFilteredChilds(this,list)
  #setFilteredChilds(this,getValidChilds(this))
end

function createBlocks(this::Chunk)
  X, Y, Z = size(this.childs)
  for y=1:Y; for z=1:Z; for x=1:X; this.childs[x,z,y] = Block(this,Vec3f(x,y,z)); end; end; end
end

function linkBlockNeighbours(this::Chunk)
  a = this.childs
  X, Y, Z = size(this.childs)
  for y=1:Y; for z=1:Z; for x=1:X; 
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
  X, Y, Z = size(this.childs)
  (x,y,z) = pos
  b = nothing
  if side == LEFT_SIDE
    b=x>1 ? a[x-1,z,y] : nothing
  elseif side == RIGHT_SIDE
    b=x<X ? a[x+1,z,y] : nothing
  elseif side == BOTTOM_SIDE
    b=y>1 ? a[x,z,y-1] : nothing
  elseif side == TOP_SIDE
    b=y<Y ? a[x,z,y+1] : nothing
  elseif side == BACK_SIDE
    b=z>1 ? a[x,z-1,y] : nothing
  elseif side == FRONT_SIDE
    b=z<Z ? a[x,z+1,y] : nothing
  else
    b=x>=1&&x<=X&&y>=1&&y<=Y&&z>=1&&z<=Z ? a[x,z,y] : nothing
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

isSurrounded(this::Block) = this.surrounded
setSurrounded(this::Block, surrounded::Bool) = this.surrounded = surrounded

isValid(this::Block) = isActive(this) && isVisible(this) && !isSurrounded(this) && this.typ > 0

hideType(this::Chunk, typ::Integer) = for b in this.childs; if b.typ == typ; setVisible(b,false); end; end
removeType(this::Chunk, typ::Integer) = for b in this.childs; if b.typ == typ; setActive(b,false); end; end

function showAll(this::Chunk)
  if GPU_CHUNKS setFilteredChilds(this,filter(b->true,this.childs)); return end
  for b in this.childs
    setVisible(b,true)
    #setSurrounded(b,false)
    #resetSides(b)
  end
  setFilteredChilds(this,getValidChilds(this))
end

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

getPos(this::Block) = SVector(Float32[this.pos...]...)

getData(this::Chunk) = isValid(this) ? vec((b->getData(b)).(getFilteredChilds(this))) : Float32[]
getPos(this::Chunk) = isValid(this) ? vec((b->getPos(b)).(getFilteredChilds(this))) : Float32[]

#fill copies references
#refblocks = Ptr{Nothing}[]
#for b in this.childs push!(refblocks, pointer_from_objref(b)) end

function createSingle(this::Chunk)
  b=this.childs[32,22,32]
  #b.pos=Vec3f(0, 0, -10)
  b.typ=1
end

function createExample(this::Chunk)
  X, Y, Z = sz = size(this.childs)
  #DIST = Vec3f(2,2,2); #Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  #START = Vec3f(-(X*DIST.x) / 2.0f0, -(Y*DIST.y) / 2.0f0, (Z*DIST.z) / 2.0f0)
  #translate(x,y,z) = Vec3f(START.x+(x-1)*DIST.x, START.y+(y-1)*DIST.y, START.z-(z-1)*DIST.z)

  x=1; y=1; z=1;

  for i=1:length(sz)
    b = this.childs[i];
    #b.pos=translate(x,y,z)
    b.typ=rand(1:16)
    #model = Mat4x4f(translation(Array(b.pos)))
    #push!(refblocks, pointer_from_objref(b))
    
    x += 1; if x > X
      z += 1; x=1;
      if z > Z y += 1; z=1;
        if y > Y break; end
      end
    end
  end
  
  h=round(UInt,X/2)
  b = this.childs[h,h,h]
  b.typ=7
end

function createLandscape(this::Chunk)
  #Texture* heightTexture = m_pRenderer->GetTexture(m_pChunkManager->GetHeightMapTexture());
  
  rgbImage=Images.load("heightmap.jpg")
  (imgwidth, imgheight) = size(rgbImage)

  grayImage = Gray.(rgbImage)
  imgMatrix = reinterpret.(channelview(grayImage)) #convert(Array{Int32},raw(grayImage))

  X, Y, Z = size(this.childs)
  w = imgwidth/X
  h = imgheight/Y
  
  #DIST = Vec3f(2,2,2)
  #START = Vec3f(-(X*DIST.x) / 2.0f0, -(Y*DIST.y) / 2.0f0, (Z*DIST.z) / 2.0f0)
  #translate(x,y,z) = Vec3f(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z)
  
  for z=1:Z
    for x=1:X
      # Use the height map texture to get the height value of x, z
      height = (imgMatrix[UInt32(trunc(z*h)), UInt32(trunc(x*w))] / 0xFF)* 1.25 * Y
      
      level_air = height * 0.95
      level_grass = height * 0.9
      level_dirt = height * 0.8
      level_stonebricks = height * 0.7
      level_stone = height * 0.4
      level_lava = height * 0

      for y=1:Y
        if y > height break end
        #id = y*X*Y+z*Z+x
        #c = this.childs[id]
        #c.active = true
        b = this.childs[x,z,y]
        #b.id=[x,y,z]
        #b.pos = translate(x-1,y-1,z-1)
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
   
  h=round(UInt, X/2)
  b = this.childs[h,h,h]
  #b.pos=Vec3f(0,0,0)
  b.typ=7
end

function saveChunk(this::Chunk, file::String)
  #childs=getValidChilds(this)
  #childs=filter(b->(b.pos, b.typ),childs)
  r=[(b.pos, b.typ) for b in this.childs]
  @save file*".jld2" r
end

function loadChunk(this::Chunk, file::String)
  @load file*".jld2" r
  i=1; for c in this.childs; b=r[i]; c.pos=b[1]; c.typ=b[2]; i+=1; end
end

"""
  Spiral 3D Search List
  
  clock wise neighbour search around a center point (shell by shell search)
  first and last layer (z-axis) full 2D spiral search (whole layer is shell)
  layers in between: search outside (next shell) and already searched area (core) will be skipped
"""
function create_spiral3D_searchlist(this::Chunk)
  println("Spiral 3D Search List")

  Z, Y, X = sz = size(this.childs)
  MAX = length(sz)
  r = Array{Int}(undef, MAX)
    
  file="spiral3D_searchlist_chunk_"*string(X)*"x"*string(Y)*"x"*string(Z)*".jld2"
  if isfile(file) @load file r; return r; end
  
  XH, YH, ZH = X/2, Y/2, Z/2
  
  lastElement = true
  endOflayer = false
  endOflBox = false
  turn=false
  log=false

  xyz=[0,0,0]
  count=[0,0]
  element=1; j=0;
  xt=0; yt=0;
  layerElement = 0
  layer = 0
  edge=0
  layerCount = 0
  maxlength = 0
  layerElementCount = 0
  layerElementCountPrev =0
  
  r[element]=ZH*YH*XH;
  
  println("create search coordinates...")
  open(file*".txt", "w") do f
  while true
    if lastElement
      j += 1
      if j >= ZH break end
      edge=0
      layer=1
      endOflayer = false
      endOflBox = false
      layerElement = 0
      
      dimMAX = 1 + j*2
      layerCount = dimMAX
      layerElementCountPrev = layerElementCount
      layerElementCount = dimMAX^2 # X*Y
      
      xyz=[0,0,j]
      xt=1; yt=-1;
      count=[1,1]
      turn=true
      lastElement = false
      #print(".")
    end

    if !lastElement
      layerElement += 1
      element+=1
      if element > MAX break end
      
      notFirst = !(layer == 1 && layerElement == 1)
      firstLayer = layer <= 1
      lastLayer = layer >= layerCount
      max = layerElementCount-(firstLayer || lastLayer ? (lastLayer ? 1 : 0) : layerElementCountPrev)
      endOflayer = (layerElement > max)
      border = [abs(xyz[1]) >= count[1],abs(xyz[2]) >= count[2]]
     
      if notFirst
        switch = [turn && border[1],!turn && border[2]]
        if switch[1] xt=-xt; elseif switch[2] yt=-yt; end
        if switch[1] || switch[2] turn=!turn; end
      end
      
      if border[1] && border[2] edge+=1 end
      
      if endOflayer
        layerElement=1
        layer+=1
        edge=0
        firstLayer = layer <= 1
        lastLayer = layer >= layerCount
        lastElement = layer > layerCount
        count=[j,j]
        
        if lastLayer
          xt=1
          xyz=[0,0,xyz[3]]
          turn=true
          count=[1,1]
        end

        if !lastElement xyz[3]-=1; end
        if log print("\$"); if !lastElement print("\n////// |") end end
      end
      
      if edge > 3
        if log print("#") end
        edge=0
        xt=-xt
        count+=[1,1]
        turn = true
      end
      
      endOfCube = lastLayer && endOflayer
      firstLayerElement = layerElement == 1
      lastLayerElement = endOflayer || layerElement == max
      lastElement = layer > layerCount
      
      if notFirst; if turn xyz[1]+=xt; else xyz[2]+=yt; end; end
      if lastElement xyz=[0,0,xyz[3]]; end
      
      x,y,z = (xyz[2]+XH), (xyz[1]+YH), (xyz[3]+ZH)
      r[element] = index = z*Y*X + y*X + x
      write(f, string([z,y,x]," = ", index, "\n"));
      
      if log print(x>=0 ? " " : "",x, "" , y>=0 ? " " : "",y,"",z>=0 ? " " : "", z," |") end
    end
  end
  end
  println("done.")
  @save file r
  r
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

function checkInFrustum2(this::Chunk, fstm::Frustum)
  pos = getNearPosition(fstm)
  list = DataStructures.SortedDict()
  
  #open("frustum.txt", "w") do f
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
    end
  #end
end

function checkInFrustum3(this::Chunk, fstm::Frustum)
  println("checkInFrustum")
  pos = getNearPosition(fstm)
  list = DataStructures.SortedDict()

  proceed1 = function(b::Block)
    result = checkSphere(fstm, b.pos, 1.5)
    visible = result[1] != :FRUSTUM_OUTSIDE
    setVisible(b,visible)
  
    #=
    clist = result[2]
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
    return visible
  end
  
  proceed2 = function(x,y,z)
      if !isassigned(this.childs, x,y,z) return false end
      proceed(this.childs[x,y,z])
  end
  for b in this.childs proceed1(b) end
    
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

end #ChunkManager