module TextureManager

using ..GraphicsManager

using Images
using ModernGL

"""
uploads a texture by given file path
"""
function uploadTexture(path)
  img = Images.load(path)
  (imgwidth, imgheight) = size(img)
  imga = reinterpret.(vec(channelview(img)))

  textureID = glGenTexture()
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, textureID)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST) #GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) #GL_LINEAR

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, imgwidth, imgheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imga)
  glCheckError("texture")
  
  textureID
end

"""
uploads a texture by given file path
"""
function uploadTexture(sz::Tuple{Integer,Integer})
  width, height = sz
  
  textureID = glGenTexture()
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, textureID);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEA
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR) #GL_NEAREST
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR) #GL_NEAREST
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, C_NULL) #GL_RGBA8, ..., GL_RGBA, GL_UNSIGNED_BYTE  GL_FLOAT
  glBindImageTexture(0, textureID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F)
  glCheckError("texture")
  
  textureID
end

export uploadTexture

end #TextureManager