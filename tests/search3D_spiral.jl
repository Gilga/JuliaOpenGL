using ColorTypes, ImageView

function showImg(img)
    imshow(convert(Array{RGB24}, img), flipy=true)
    print()
end

"""
  Spiral Search 3D
  
  clock wise neighbour search around a center point (shell by shell search)
  first and last layer (z-axis) full 2D spiral search (whole layer is shell)
  layers in between: search outside (next shell) and already searched area (core) will be skipped
"""
function search3D_spiral(img, X, Y, Z)
  lastElement = true
  endOflayer = false
  endOflBox = false
  turn=false
  log=false

  MAX=reduce(*,size(img))
  xyz=[0,0,0]
  count=[0,0]
  element=0; j=0;
  xt=0; yt=0;
  layerElement = 0
  layer = 0
  edge=0
  layerCount = 0
  maxlength = 0
  layerElementCount = 0
  layerElementCountPrev =0

  while true
    if lastElement
      j += 1
      if j > 15 break end
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
    end

    if !lastElement
      layerElement += 1
      element+=1
      
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
      
      img[xyz[2]+Y,xyz[1]+X,xyz[3]+Z]=1 - clamp(((element/MAX) + (layerElement/layerElementCount)) * 0.5,0,1)
      
      if log print(x>=0 ? " " : "",x, "" , y>=0 ? " " : "",y,"",z>=0 ? " " : "", z," |") end
    end
  end
end

img = Array{Float32}(undef, 31, 31, 31)
hsz=(x->Int64(round(x/2))).(size(img))
fill!(img, 1)

search3D_spiral(img,hsz[2],hsz[1],hsz[3])

showImg(img)