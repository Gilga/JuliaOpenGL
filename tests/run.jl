println("run...")

imgfile="../blocks.png"
imgarrayfile="$imgfile.jld"

using Images
img = Images.load(imgfile)
(imgwidth, imgheight) = size(img)

#img = Gray.(img) #grayImage
#imgMatrix = reinterpret.(channelview(img)) 
#println("write ",typeof(imgMatrix),"->" , size(imgMatrix))

#imga = reinterpret.(vec(channelview(rgbImage)))

#open(f -> print(f, imga), imgarrayfile, "w+")
#writecsv(imgarrayfile, imgMatrix)
#a = readcsv(imgarrayfile)
#println("read ",typeof(a),"->" , size(a))
#a = convert(Array{UInt8},a)
#println("convert ",typeof(a), "->", a[1:100],"\n")

using JLD
#JLD.save(imgarrayfile, "img", imgMatrix)
a = JLD.load(imgarrayfile, "img")
println("read ",typeof(a),"->" , size(a))