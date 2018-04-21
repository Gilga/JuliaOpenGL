"""
TODO
"""
type Plane3D
	mPoint::Vec3f
	mNormal::Vec3f
	d::Float32
end

"""
TODO
"""
Plane3D() = Plane3D(Vec3f(),Vec3f(),0)
  
"""
TODO
"""
function Plane3D(mNormal::Vec3f, mPoint::Vec3f)
  mNormal = normalize(mNormal)
  d= -(dot(mNormal, mPoint))
  Plane3D(mPoint,mNormal,d)
end
 
"""
TODO
"""
function Plane3D(lv1::Vec3f, lv2::Vec3f, lv3::Vec3f)
  mNormal = normalize(cross(lv3 - lv2, lv1 - lv2))
  mPoint = lv2
  d= -(dot(mNormal, mPoint))
  Plane3D(mPoint,mNormal,d)
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
  Plane3D(mPoint,mNormal,d)
end

"""
TODO
"""
GetPointDistance(this::Plane3D, lPoint::Vec3f) = this.d + dot(this.mNormal, lPoint)

const FRUSTUM_TOP = 1
const FRUSTUM_BOTTOM = 2
const FRUSTUM_LEFT = 3
const FRUSTUM_RIGHT = 4
const FRUSTUM_NEAR = 5
const FRUSTUM_FAR = 6

const FRUSTUM_OUTSIDE = 0
const FRUSTUM_INTERSECT = 1
const FRUSTUM_INSIDE = 2

"""
TODO
"""
type Frustum
  planes::Array{Plane3D,1}
  
  nearDistance::Float32
  farDistance::Float32
  nearWidth::Float32
  nearHeight::Float32
  farWidth::Float32
  farHeight::Float32
  ratio::Float32
  angle::Float32
  tang::Float32
  
  nearTopLeft::Vec3f
  nearTopRight::Vec3f
  nearBottomLeft::Vec3f
  nearBottomRight::Vec3f
  farTopLeft::Vec3f
  farTopRight::Vec3f
  farBottomLeft::Vec3f
  farBottomRight::Vec3f

  Frustum() = new(Array{Plane3D,1}(6),0,0,0,0,0,0,0,0,0,
  Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f(),Vec3f())
end

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

"""
TODO
"""
function SetCamera(this::Frustum, pos::Vec3f, target::Vec3f, up::Vec3f)
  pos = -pos
  target = -target

	Z = pos - target
	Z = normalize(Z)

	X = cross(up, Z)
	X = normalize(X)

	Y = cross(Z, X)

	nc = pos - Z * this.nearDistance
	fc = pos - Z * this.farDistance

	this.nearTopLeft = nc + Y * this.nearHeight - X * this.nearWidth
	this.nearTopRight = nc + Y * this.nearHeight + X * this.nearWidth
	this.nearBottomLeft = nc - Y * this.nearHeight - X * this.nearWidth
	this.nearBottomRight = nc - Y * this.nearHeight + X * this.nearWidth

	this.farTopLeft = fc + Y * this.farHeight - X * this.farWidth
	this.farTopRight = fc + Y * this.farHeight + X * this.farWidth
	this.farBottomLeft = fc - Y * this.farHeight - X * this.farWidth
	this.farBottomRight = fc - Y * this.farHeight + X * this.farWidth

	this.planes[FRUSTUM_TOP] = Plane3D(this.nearTopRight, this.nearTopLeft, this.farTopLeft)
	this.planes[FRUSTUM_BOTTOM] = Plane3D(this.nearBottomLeft, this.nearBottomRight, this.farBottomRight)
	this.planes[FRUSTUM_LEFT] = Plane3D(this.nearTopLeft, this.nearBottomLeft, this.farBottomLeft)
	this.planes[FRUSTUM_RIGHT] = Plane3D(this.nearBottomRight, this.nearTopRight, this.farBottomRight)
	this.planes[FRUSTUM_NEAR] = Plane3D(this.nearTopLeft, this.nearTopRight, this.nearBottomRight)
	this.planes[FRUSTUM_FAR] = Plane3D(this.farTopRight, this.farTopLeft, this.farBottomLeft)
end

"""
TODO
"""
function checkPoint(this::Frustum, pos::Vec3f)
 for plane in this.planes
    if GetPointDistance(plane, pos) < 0 return FRUSTUM_OUTSIDE end
  end
  FRUSTUM_INSIDE
end

"""
TODO
"""
function checkSphere(this::Frustum, pos::Vec3f, radius::Number)
  result = FRUSTUM_INSIDE
	distance = 0f0

	for plane in this.planes
		distance = GetPointDistance(plane, pos)

		if distance < -radius return FRUSTUM_OUTSIDE
		elseif distance < radius	result =  FRUSTUM_INTERSECT
		end
	end

	result
end

"""
TODO
"""
function checkCube(this::Frustum, center::Vec3f, size::Vec3f)
  result = FRUSTUM_INSIDE
  
  for plane in this.planes
    # Reset counters for corners in and out
    out = 0
    in = 0
    
    if GetPointDistance(plane, center + Vec3f(-size.x, -size.y, -size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(size.x, -size.y, -size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(-size.x, -size.y, size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(size.x, -size.y, size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(-size.x, size.y, -size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(size.x, size.y, -size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(-size.x, size.y, size.z)) < 0 out+=1
    else in+=1
    end

    if GetPointDistance(plane, center + Vec3f(size.x, size.y, size.z)) < 0 out+=1
    else in+=1
    end
    
    # If all corners are out
    if in <= 0 return FRUSTUM_OUTSIDE
    # If some corners are out and others are in	
    elseif out > 0 result = FRUSTUM_INTERSECT
    end
    
  end

  result
end
