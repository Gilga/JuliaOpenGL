module TextureManager

using ..GraphicsManager
const GPU =  GraphicsManager

using Images
using ModernGL

mutable struct Texture
  id::Symbol
  refID::GLuint
  created::Bool

  function Texture(id::Symbol)
    this = new(id,0,true)
    set(id,this)
    this
  end
end

LIST = Dict{Symbol, Texture}()

get(id::Symbol) = haskey(LIST, id) ? LIST[id] : nothing
set(id::Symbol, tex::Texture) = LIST[id] = tex

function clean()
  global LIST = typeof(LIST)()
end

init(this::Texture) = this.refID = GPU.create(:TEXTURE, this.id)

function load(id::Symbol)
  this = get(id) 
  if this == nothing this = Texture(id) else this.created = false end
  init(this)
  this
end

getRefIDs() = [this.refID for (_,this) in LIST]

"""
uploads a texture by given file path
"""
function uploadTextureGray(path)
  this = load(Symbol(path*" (gray)"))
  if !this.created return this.refID end

  img = Images.load(path)
  (imgwidth, imgheight) = size(img)
  gray = Array{Float32}(Gray.(img)) # do not vec
  
  textureID = GPU.create(:TEXTURE, id)
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, this.refID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST) #GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) #GL_LINEAR

  glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, imgwidth, imgheight, 0, GL_LUMINANCE, GL_FLOAT, gray)
  #glGenerateMipmap(GL_TEXTURE_2D)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  #glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, -0.8f0)
  glBindImageTexture(0, this.refID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F)
  glBindTexture(GL_TEXTURE_2D, 0)
  glCheckError("texture")
  
  this.refID
end

export uploadTextureGray

"""
uploads a texture by given file path
"""
function uploadTexture(path)
  this = load(Symbol(path))
  if !this.created return this.refID end

  img = Images.load(path)
  (imgwidth, imgheight) = size(img)
  imga = reinterpret.(channelview(img)) # do not vec

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, this.refID)
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, imgwidth, imgheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imga)
  glGenerateMipmap(GL_TEXTURE_2D)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR) #GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, -0.4f0)
  largest_supported_anisotropy = GLfloat[0]
  GL_MAX_TEXTURE_MAX_ANISOTROPY = 0x84FF
  GL_TEXTURE_MAX_ANISOTROPY = 0x84FE
  glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY, largest_supported_anisotropy)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, largest_supported_anisotropy[])
  glBindTexture(GL_TEXTURE_2D, 0)
  glCheckError("texture")
  
  this.refID
end

"""
uploads a texture by given file path
"""
function uploadTexture(id::Symbol, sz::Tuple{Integer,Integer})
  this = load(id) #Symbol(id, string(sz[1])*"x"*string(sz[2]))
  if !this.created return this.refID end

  width, height = sz
  
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D,  this.refID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEA
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR) #GL_NEAREST
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR) #GL_NEAREST
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, C_NULL) #GL_RGBA8, ..., GL_RGBA, GL_UNSIGNED_BYTE  GL_FLOAT
  glBindImageTexture(0,  this.refID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F)
  glGenerateMipmap(GL_TEXTURE_2D)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  #glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, -0.8f0)
  glBindTexture(GL_TEXTURE_2D, 0)  
  glCheckError("texture")
  
  this.refID
end

"""
TODO
"""
function createTexture(id::Symbol, sz::Tuple{Integer,Integer};level=1)
  this = load(id) #Symbol(string(sz[1])*"x"*string(sz[2])*"x"*string(level))
  if !this.created return this.refID end

  width, height = sz
  
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, this.refID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEA
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) #GL_NEAREST
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST) #GL_NEAREST, GL_NEAREST_MIPMAP_NEAREST
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_NONE)
  # Useful for debugging purposes so depth shows up as graytone and not just red.
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_R, GL_RED)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_G, GL_RED)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_B, GL_RED)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_A, GL_ONE)
  #glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, C_NULL)
  #glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT24, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, C_NULL)
  #glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH_COMPONENT24, width, height)
  glTexStorage2D(GL_TEXTURE_2D, level, GL_DEPTH24_STENCIL8, width, height)
  glBindTexture(GL_TEXTURE_2D, 0)      
  #glBindImageTexture(0, this.refID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F)
  glCheckError("texture")
  
  this.refID
end

"""
TODO
"""
function createTextureMultiSample(id::Symbol, sz::Tuple{Integer,Integer})
  this = load(id) #Symbol(string(sz[1])*"x"*string(sz[2])*"x"*string(level))
  if !this.created return this.refID end
  
  width, height = sz

  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, this.refID)
  glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, 4, GL_RGB, width, height, GL_TRUE)
  glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, 0)

  this.refID
end

export createTextureMultiSample

export createTexture
export uploadTexture

end #TextureManager