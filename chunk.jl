struct HeptaOrder{T} <: FieldVector{6, T}
  front::Union{T,Void}
  back::Union{T,Void}
  left::Union{T,Void}
  right::Union{T,Void}
  top::Union{T,Void}
  bottom::Union{T,Void}
end

type Block
  active::Bool
  visible::Bool
  typ::Int32
  pos::Vec3f
  flags::UInt32
  friends::HeptaOrder{Block}
end

type Chunk
  active::Bool
  len::UInt32
  childs::Array{Block,3}
  count::UInt32
  activeCount::UInt32
  visibleCount::UInt32
  
  function Chunk(len::Integer)
    this = new(true,len,Array{Block,3}(len,len,len),0,0)
    for x=1:len; for y=1:len; for z=1:len; this.childs[x,y,z] = Block(Vec3f(x,y,z)); end; end; end
    this
  end
end

function hideUnseen(this::Chunk)
  a = this.childs
  len = this.len
  for x=1:len; for y=1:len; for z=1:len;
  
    b=a[x,y,z]

    if !isVisible(b) || x==1 || y==1 || z==1 || x==len || y==len || z==len continue end # skip invisible
    if x>1 && !isVisible(a[x-1,y,z]) continue end #skip
    if x<len && !isVisible(a[x+1,y,z]) continue end #skip
    if y>1 && !isVisible(a[x,y-1,z]) continue end #skip
    if y<len && !isVisible(a[x,y+1,z]) continue end #skip
    if z>1 && !isVisible(a[x,y,z-1]) continue end #skip
    if z<len && !isVisible(a[x,y,z+1]) continue end #skip
    
    b.flags = 0x1 # every block around this block is visible -> invisible
    
  end; end; end
  
  #remove flag and deactivate
  for b in a; if (b.flags & 0x1) > 0; b.flags -= 0x1; b.visible = false; end; end
end

function hideType(this::Chunk, typ::Integer)
  for b in this.childs; if b.typ == typ; b.visible = false; end; end
end

function removeType(this::Chunk, typ::Integer)
  for b in this.childs; if b.typ == typ; b.active = false; end; end
end

function showAll(this::Chunk)
  for b in this.childs; b.visible = true; end
end

#------------------------------------------------------------------------------------

getActiveChilds(this::Chunk) = filter(b->isActive(b),this.childs)
getVisibleChilds(this::Chunk) = filter(b->isVisible(b),this.childs) # do not render deactivated blocks and air blocks! 
getData(this::Chunk) = this.visibleCount>0?(b->Vec4(b.pos,b.typ)).(getVisibleChilds(this)):Vec4f[]

function checkInFrustum(this::Chunk, fstm::Frustum)
  for b in this.childs b.visible = checkSphere(fstm, b.pos, 1.5) != 0 end
  update(this)
end

function update(this::Chunk)
  #removeType(this,0)
  hideUnseen(this)
  this.count = length(this.childs)
  #this.activeCount = length(getActiveChilds(this))
  this.visibleCount = length(getVisibleChilds(this))
  global COUNT = this.visibleCount
  
  #fill copies references
  #refblocks = Ptr{Void}[]
  #for b in this.childs push!(refblocks, pointer_from_objref(b)) end
end

const BlockOrder = HeptaOrder{Block}
BlockOrder() = HeptaOrder{Block}(nothing,nothing,nothing,nothing,nothing,nothing)
Block(pos=Vec3f,typ=0,active=true,visible=true) = Block(active,visible,typ,pos,0,BlockOrder()) #,zeros(Mat4x4f),zeros(Mat4x4f))

isActive(this::Block) = this.active 
isVisible(this::Block) = isActive(this) && this.visible && this.typ > 0

function createSingle(this::Chunk)
  this.childs[1,1,1] = Block(Vec3f(0, 0, -10),1) 
  update(this)
end

function createExample(this::Chunk)
  const DIST = Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  const START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)

  x=0; y=0; z=0; w=0;

  for i=1:(this.len^3)
    this.childs[i] = b = Block(Vec3f(START.x+DIST.x*x, START.y+DIST.y*z, START.z-DIST.z*y),rand(0:16))
    #model = Mat4x4f(translation(Array(b.pos)))
    #push!(refblocks, pointer_from_objref(b))
    
    x += 1; if x >= this.len
      y += 1; x=0;
      if y >= this.len z += 1; y=0;
        if z >= this.len w+=1; z=0;
          if w > 1 error("invalid range"); end
        end
      end
    end
  end
  
  update(this)
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
   
  this.childs[1,1,1] = Block(translate(0,0,0),7)  
  
  update(this)
end