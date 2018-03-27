function uploadTexture(path)
  #img = Images.load(path)
  #(imgwidth, imgheight) = size(img)
  #imga = reinterpret.(vec(channelview(img)))
  
  # alternative loading raw image
  (imgwidth, imgheight) = (512,512)
  imga = convert(Array{UInt8},readcsv("$path.csv"))
  
  texture = glGenTexture()
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST) #GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) #GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, imgwidth, imgheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imga)
end
