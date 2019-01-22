module FrustumManager

using ..Math

using LinearAlgebra

"""
TODO
"""
mutable struct Plane3D
	mPoint::Vec3f
	mNormal::Vec3f
	d::Float32
  
  """
  TODO
  """
  Plane3D() = new(Vec3f(),Vec3f(),0)
  
  """
  TODO
  """
  function Plane3D(mPoint::Vec3f, mNormal::Vec3f)
    mNormal = normalize(mNormal)
    d= -(dot(mNormal, mPoint))
    new(mPoint,mNormal,d)
  end
  
  """
  TODO
  """
  function Plane3D(lv1::Vec3f, lv2::Vec3f, lv3::Vec3f)
    mNormal = normalize(cross(lv3 - lv2, lv1 - lv2))
    mPoint = (lv1 + lv3) / 2 #lv2
    d= -(dot(mNormal, mPoint))
    new(mPoint,mNormal,d)
  end
  
  """
  TODO
  """
  function Plane3D(a::Float32, b::Float32, c::Float32, d::Float32)
    mPoint = Vec3f(0,0,0)

    # Set the normal vector
    mNormal = Vec3f(a, b, c)

    # Compute the length of the vector
    lLength = length(mNormal)
    
    # Normalize the vector
    mNormal = Vec3f(a / lLength, b / lLength, c / lLength)

    # And divide d by the length as well
    d = d / lLength
    new(mPoint,mNormal,d)
  end
end

export Plane3D

"""
TODO
"""
function Plane3D_Rect(lbn::Vec3f, rtf::Vec3f)
  v = Vec3f(rtf.x,rtf.y,lbn.z)
  mNormal = normalize(cross(rtf - v, lbn - v))
  mPoint = (lbn + rtf) / 2
  d= -(dot(mNormal, mPoint))
  Plane3D(mPoint,mNormal,d)
end

export Plane3D_Rect

"""
TODO
"""
GetPointDistance(this::Plane3D, lPoint::Vec3f) = this.d + dot(this.mNormal, lPoint)

export GetPointDistance

"""
TODO
"""
mutable struct Frustum
  planes::Dict{Symbol,Plane3D} #Array{Plane3D,1}
  box::Dict{Symbol,Plane3D}
  pos::Dict{Symbol,Vec3f}
   
  nearDistance::Float32
  farDistance::Float32
  nearWidth::Float32
  nearHeight::Float32
  farWidth::Float32
  farHeight::Float32
  ratio::Float32
  angle::Float32
  tang::Float32
  centerRadius::Float32

  nearTopLeft::Vec3f
  nearTopRight::Vec3f
  nearBottomLeft::Vec3f
  nearBottomRight::Vec3f
  farTopLeft::Vec3f
  farTopRight::Vec3f
  farBottomLeft::Vec3f
  farBottomRight::Vec3f
  
  nearfarTopLeft::Vec3f
  nearfarTopRight::Vec3f
  nearfarBottomLeft::Vec3f
  nearfarBottomRight::Vec3f

  Frustum() = new(
  Dict(:FRUSTUM_TOP=>Plane3D(),:FRUSTUM_BOTTOM=>Plane3D(),:FRUSTUM_LEFT=>Plane3D(),:FRUSTUM_RIGHT=>Plane3D(),:FRUSTUM_NEAR=>Plane3D(),:FRUSTUM_FAR=>Plane3D()),
  Dict(:BOX_TOP=>Plane3D(),:BOX_BOTTOM=>Plane3D(),:BOX_LEFT=>Plane3D(),:BOX_RIGHT=>Plane3D()),
  Dict(:CENTER=>Vec3f(),:CAMERA=>Vec3f(),:TARGET=>Vec3f()),
  0,0,0,0,0,0,0,0,0,0,
  Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f()) #Array{Plane3D,1}(6)
end

export Frustum

getNearPosition(fstm::Frustum) = Vec3f((fstm.nearBottomLeft + fstm.nearTopRight) / 2)
getFarPosition(fstm::Frustum) = Vec3f((fstm.farBottomLeft + fstm.farTopRight) / 2)
getPosition(fstm::Frustum) = Vec3f((fstm.nearBottomLeft + fstm.farTopRight) / 2)

export getNearPosition
export getFarPosition
export getPosition

"""
TODO
"""
function getBox(this::Frustum)
  [
    this.nearfarTopLeft, this.farTopLeft, this.farTopRight,
    this.nearfarTopLeft, this.farTopRight, this.farTopLeft,

    this.nearfarTopLeft, this.nearfarTopRight, this.farTopRight,
    this.nearfarTopLeft, this.farTopRight, this.nearfarTopRight,

    this.nearfarBottomLeft, this.farBottomLeft, this.farBottomRight,
    this.nearfarBottomLeft, this.farBottomRight, this.farBottomLeft,

    this.nearfarBottomLeft, this.nearfarBottomRight, this.farBottomRight,
    this.nearfarBottomLeft, this.farBottomRight, this.nearfarBottomRight,

    this.nearfarTopLeft, this.farTopLeft, this.farBottomLeft,
    this.nearfarTopLeft, this.farBottomLeft, this.farTopLeft,

    this.nearfarTopLeft, this.nearfarBottomLeft, this.farBottomLeft,
    this.nearfarTopLeft, this.farBottomLeft, this.nearfarBottomLeft,

    this.nearfarTopRight, this.farTopRight, this.farBottomRight,
    this.nearfarTopRight, this.farBottomRight, this.farTopRight,

    this.nearfarTopRight, this.nearfarBottomRight, this.farBottomRight,
    this.nearfarTopRight, this.farBottomRight, this.nearfarBottomRight,
    
    this.farTopLeft, this.farTopRight, this.farBottomLeft,
    this.farTopLeft, this.farBottomLeft, this.farTopRight,
    
    this.farTopRight, this.farBottomRight, this.farBottomLeft,
    this.farTopRight, this.farBottomLeft, this.farBottomRight,
    
    this.farTopLeft, this.farTopRight, this.farBottomLeft,
    this.farTopLeft, this.farBottomLeft, this.farTopRight,
    
    this.nearfarTopRight, this.nearfarBottomRight, this.nearfarBottomLeft,
    this.nearfarTopRight, this.nearfarBottomLeft, this.nearfarBottomRight,
  ]
end

export getBox

"""
TODO
"""
function getVertices(this::Frustum)
  [
    this.nearTopLeft, this.farTopLeft, this.farTopRight,
    this.nearTopLeft, this.farTopRight, this.farTopLeft,

    this.nearTopLeft, this.nearTopRight, this.farTopRight,
    this.nearTopLeft, this.farTopRight, this.nearTopRight,

    this.nearBottomLeft, this.farBottomLeft, this.farBottomRight,
    this.nearBottomLeft, this.farBottomRight, this.farBottomLeft,

    this.nearBottomLeft, this.nearBottomRight, this.farBottomRight,
    this.nearBottomLeft, this.farBottomRight, this.nearBottomRight,

    this.nearTopLeft, this.farTopLeft, this.farBottomLeft,
    this.nearTopLeft, this.farBottomLeft, this.farTopLeft,

    this.nearTopLeft, this.nearBottomLeft, this.farBottomLeft,
    this.nearTopLeft, this.farBottomLeft, this.nearBottomLeft,

    this.nearTopRight, this.farTopRight, this.farBottomRight,
    this.nearTopRight, this.farBottomRight, this.farTopRight,

    this.nearTopRight, this.nearBottomRight, this.farBottomRight,
    this.nearTopRight, this.farBottomRight, this.nearBottomRight,
    
    this.farTopLeft, this.farTopRight, this.farBottomLeft,
    this.farTopLeft, this.farBottomLeft, this.farTopRight,
    
    this.farTopRight, this.farBottomRight, this.farBottomLeft,
    this.farTopRight, this.farBottomLeft, this.farBottomRight,
  ]
end

export getVertices

"""
TODO
"""
function SetFrustum(this::Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)
  this.ratio = ratio
  this.angle = angle
  this.nearDistance = nearD
  this.farDistance = farD

  this.tang = Float32(tan(deg2rad(this.angle) * 0.5))
  this.nearHeight = this.nearDistance * this.tang
  this.nearWidth = this.nearHeight * this.ratio
  this.farHeight = this.farDistance  * this.tang
  this.farWidth = this.farHeight * this.ratio
end

export SetFrustum

"""
TODO
"""
function SetCamera(this::Frustum, pos::Vec3f, target::Vec3f, up::Vec3f; near=0, far=0)
  pos = -pos
  target = -target

	Z = pos - target
	Z = normalize(Z)

	X = cross(up, Z)
	X = normalize(X)

	Y = cross(Z, X)

	nc = pos - Z * (near==0 ? this.nearDistance : near)
	fc = pos - Z * (far==0 ? this.farDistance : far)

	this.nearTopLeft = nc + Y * this.nearHeight - X * this.nearWidth
	this.nearTopRight = nc + Y * this.nearHeight + X * this.nearWidth
	this.nearBottomLeft = nc - Y * this.nearHeight - X * this.nearWidth
	this.nearBottomRight = nc - Y * this.nearHeight + X * this.nearWidth

	this.farTopLeft = fc + Y * this.farHeight - X * this.farWidth
	this.farTopRight = fc + Y * this.farHeight + X * this.farWidth
	this.farBottomLeft = fc - Y * this.farHeight - X * this.farWidth
	this.farBottomRight = fc - Y * this.farHeight + X * this.farWidth
  
	this.nearfarTopLeft = nc + Y * this.farHeight - X * this.farWidth
	this.nearfarTopRight = nc + Y * this.farHeight + X * this.farWidth
	this.nearfarBottomLeft = nc - Y * this.farHeight - X * this.farWidth
	this.nearfarBottomRight = nc - Y * this.farHeight + X * this.farWidth

	this.planes[:FRUSTUM_TOP] = Plane3D(this.nearTopRight, this.nearTopLeft, this.farTopLeft)
	this.planes[:FRUSTUM_BOTTOM] = Plane3D(this.nearBottomLeft, this.nearBottomRight, this.farBottomRight)
	this.planes[:FRUSTUM_LEFT] = Plane3D(this.nearTopLeft, this.nearBottomLeft, this.farBottomLeft)
	this.planes[:FRUSTUM_RIGHT] = Plane3D(this.nearBottomRight, this.nearTopRight, this.farBottomRight)
	this.planes[:FRUSTUM_NEAR] = Plane3D(this.nearTopLeft, this.nearTopRight, this.nearBottomRight)
	this.planes[:FRUSTUM_FAR] = Plane3D(this.farTopRight, this.farTopLeft, this.farBottomLeft)
  
  this.box[:BOX_TOP] = Plane3D(this.nearfarTopRight, this.nearfarTopLeft, this.farTopLeft) #Plane3D_Rect(this.nearfarTopRight, this.farTopLeft)
  this.box[:BOX_BOTTOM] = Plane3D(this.nearfarBottomLeft, this.nearfarBottomRight, this.farBottomRight) #Plane3D_Rect(this.nearfarBottomLeft, this.farBottomRight)
  this.box[:BOX_LEFT] = Plane3D(this.nearfarTopLeft, this.nearfarBottomLeft, this.farBottomLeft) #Plane3D_Rect(this.nearfarTopLeft, this.farBottomLeft)
  this.box[:BOX_RIGHT] = Plane3D(this.nearfarBottomRight, this.nearfarTopRight, this.farBottomRight) #Plane3D_Rect(this.nearfarBottomRight, this.farBottomRight)
  this.box[:BOX_NEAR] = Plane3D(this.nearfarTopLeft, this.nearfarTopRight, this.nearfarBottomRight)
  this.box[:BOX_FAR] = this.planes[:FRUSTUM_FAR]
  
  this.pos[:CENTER] = Vec3f((pos + target) / 2)
  this.pos[:CAMERA] = pos
  this.pos[:TARGET] = target
  this.centerRadius = 0
end

export SetCamera

"""
TODO
"""
function checkPoint2(this::Frustum, pos::Vec3f)
  result = :FRUSTUM_INSIDE
  distances = Dict{Symbol,Float32}()
  
  for (k,plane) in this.planes
    if (distances[k] = GetPointDistance(plane, pos)) < 0 result = :FRUSTUM_OUTSIDE end
  end
  
  for (k,plane) in this.box
    distances[k] = GetPointDistance(plane, pos)
  end
  
  for (k,v) in this.pos
    origin = this.pos[k]
    distances[k] = euclidean(origin,pos)
    distances[Symbol(k,:_X)] = origin.x - pos.x
    distances[Symbol(k,:_Y)] = origin.y - pos.y
    distances[Symbol(k,:_Z)] = origin.z - pos.z
  end
  
  X = distances[:BOX_LEFT] #distances[:CAMERA_X]
  Y = distances[:CAMERA_Y]
  Z = distances[:CAMERA_Z]
  
  #X,Y = normalize([X,Y])
  
  distances[:X] = X
  distances[:Y] = Y
  distances[:Z] = Z
  
  (result, distances)
end

export checkPoint2

"""
TODO
"""
function checkSphere2(this::Frustum, pos::Vec3f, radius::Number)
  result = :FRUSTUM_INSIDE
  (_, distances) = checkPoint(this, pos)

	for (k,distance) in distances
    if !haskey(this.planes, k) continue end
		if distance < -radius result = :FRUSTUM_OUTSIDE
		elseif distance < radius && result != :FRUSTUM_OUTSIDE result = :FRUSTUM_INTERSECT
		end
	end

	(result, distances)
end

export checkSphere2

"""
TODO
"""
function checkPoint(this::Frustum, pos::Vec3f)
  result = :FRUSTUM_INSIDE
  distances = Dict{Symbol,Float32}()
  
  for (k,plane) in this.planes
    distance = distances[k] = GetPointDistance(plane, pos)
    if distance < 0 result = :FRUSTUM_OUTSIDE
    elseif distance == 0 result = :FRUSTUM_INTERSECT
    end
  end
  
  (result, distances)
end

export checkPoint

"""
TODO
"""
function checkSphere(this::Frustum, pos::Vec3f, radius::Number)
  result = :FRUSTUM_INSIDE
  distances = Dict{Symbol,Float32}()
  
  for (k,plane) in this.planes
    distance = distances[k] = GetPointDistance(plane, pos)
		if distance < -radius result = :FRUSTUM_OUTSIDE
		elseif distance <= radius && result != :FRUSTUM_OUTSIDE result = :FRUSTUM_INTERSECT
		end
	end

	(result, distances)
end

export checkSphere

"""
TODO
"""
function checkCube(this::Frustum, center::Vec3f, size::Vec3f)
  result = :FRUSTUM_INSIDE
	distance = 0f0
  distances = Dict{Symbol,Dict{Symbol,Float32}}()
  
  for (k,plane) in this.planes
    # Reset counters for corners in and out
    out = 0
    in = 0
    
    distance = Dict{Symbol,Float32}(:LDB=>0f0,:RDB=>0f0,:LDF=>0f0,:RDF=>0f0,:LUB=>0f0,:RUB=>0f0,:LUF=>0f0,:RUF=>0f0)
    
    if (distance[:LDB] = GetPointDistance(plane, center + Vec3f(-size.x, -size.y, -size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:RDB] = GetPointDistance(plane, center + Vec3f(size.x, -size.y, -size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:LDF] = GetPointDistance(plane, center + Vec3f(-size.x, -size.y, size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:RDF] = GetPointDistance(plane, center + Vec3f(size.x, -size.y, size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:LUB] = GetPointDistance(plane, center + Vec3f(-size.x, size.y, -size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:RUB]= GetPointDistance(plane, center + Vec3f(size.x, size.y, -size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:LUF] = GetPointDistance(plane, center + Vec3f(-size.x, size.y, size.z))) < 0 out+=1
    else in+=1
    end

    if (distance[:RUF] = GetPointDistance(plane, center + Vec3f(size.x, size.y, size.z))) < 0 out+=1
    else in+=1
    end
    
    distances[k] = distance
    
    # If all corners are out
    if in <= 0 result = :FRUSTUM_OUTSIDE
    # If some corners are out and others are in	
    elseif out > 0 && result != :FRUSTUM_OUTSIDE result = :FRUSTUM_INTERSECT
    end
    
  end

  (result, distances)
end

export checkCube

end #FrustumManager