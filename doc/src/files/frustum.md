# [frutsum.jl](@id frutsum.jl)

```@docs
App.Plane3D
```

```@docs
App.Plane3D(mNormal::App.Vec3f, mPoint::App.Vec3f)
```

```@docs
App.Plane3D(lv1::App.Vec3f, lv2::App.Vec3f, lv3::App.Vec3f)
```

```@docs
App.Plane3D(a::Float32, b::Float32, c::Float32, d::Float32)
```

```@docs
App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)
```

* FRUSTUM_TOP = 1
* FRUSTUM_BOTTOM = 2
* FRUSTUM_LEFT = 3
* FRUSTUM_RIGHT = 4
* FRUSTUM_NEAR = 5
* FRUSTUM_FAR = 6

* FRUSTUM_OUTSIDE = 0
* FRUSTUM_INTERSECT = 1
* FRUSTUM_INSIDE = 2

```@docs
App.Frustum
```

```@docs
App.getVertices(this::App.Frustum)
```

```@docs
App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)
```

```@docs
App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)
```

```@docs
App.checkPoint(this::App.Frustum, pos::App.Vec3f)
```

```@docs
App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)
```

```@docs
App.checkCube(this::App.Frustum, center::App.Vec3f, size::App.Vec3f)
```
