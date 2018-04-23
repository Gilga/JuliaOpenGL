# [Algorithm](@id algorithm)

For this project i use an advanced OpenGL technique and two algorithm to render up to 128³ blocks with 100 or more FPS.

* [OpenGL](#OpenGL-1)
* [Frustum Culling](#Frustum-Culling-1)
* [Outside Only](#Outside-Only-1)
* [All together](#All-together-1)
* [Next step](#Next-step-1)
* [Why not use?](#Why-not-use?-1)

## OpenGL
* glDrawElementsInstanced and glDrawArraysInstanced to render many objects at once
* GPU Geometry shader to adjust amount of vertices given by input. No need to create vertices on CPU side. 
  
Geometry shader example:
```
void createSide(Vertex v, int side) {
  for(int i=0;i<4;++i) {
    (...)
    gl_Position = iMVP * v.world_pos;
    EmitVertex();
  }
  EndPrimitive();
}

void main() {
  (...)
  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT
  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT
  if((sides & 0x4) > 0) createSide(v, 0);  // TOP
  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM
  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT
  if((sides & 0x20) > 0) createSide(v, 3);  // BACK
  (...)
}
```

## Frustum Culling
Frustum culling is 3d geometric object (a cone with top and bottom sliced off).
In code frustum has six planes (top,bottom,right,left,near,far) in total where each plane measure the distance between itself and a given object. 

For visual demonstration look [Frustum Culling Video](https://youtu.be/E6r9IzakO0U) by AlwaysGeeky.

*Code:*

```
type Plane
 position  :: Vector
 normal    :: Vector
 distance  :: Value
end
```

```
type Frustum
  planes :: Array
  
  nearDistance  :: Value
  farDistance   :: Value
  nearWidth     :: Value
  nearHeight    :: Value
  farWidth      :: Value
  farHeight     :: Value
  ratio         :: Value
  angle         :: Value
  tang          :: Value
  
  nearTopLeft     :: Vector
  nearTopRight    :: Vector
  nearBottomLeft  :: Vector
  nearBottomRight :: Vector
  farTopLeft      :: Vector
  farTopRight     :: Vector
  farBottomLeft   :: Vector
  farBottomRight  :: Vector
end
```

Set Camera is called in main script and sets the view for the frustum
[`App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)`](@ref)

Set Frustum is almost similiar to set camera execpt its sets ratio, angle, far and near values
[`App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)`](@ref)

GetPointDistance gets the distance between current plane and a point
[`App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)`](@ref)

checkSphere is a batter option than checkCube because its faster
[`App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)`](@ref)

checkInFrustum is called in when blocks are created / updated
[`App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)`](@ref)

## Outside Only
Is a simple algorithm to filter objects which are surrounded by other objects and are not visible from the outside.
It hides not only the objects itself but its non-visible sides too. Those objects are cubes so we have only six sides to check for visibility.

This algorithm has some similiarities to [Occlusion culling](https://en.wikipedia.org/wiki/Hidden_surface_determination#Occlusion_culling) but its different.
Occlusion culling is when objects are entirely behind other opaque objects may be culled.
This differs from Outside Only algorithm because each object looks around itself if it has visible neighbour objects or not.
If its entirely surrounded by other object then it wont be "culled".

The algorithm
[`App.hideUnseen(this::App.Chunk)`](@ref)

## All together
Combining OpenGL technique and those two algorithm gives high quality results.

This gets us a filtered list of objects where those algorithms were applied to
[`App.getFilteredChilds(this::App.Chunk)`](@ref)

## Next step
Next step is to filter objects which are not seen due to interference of other objects (blocking the view).
An approach could be using a raytracer but maybe there is an even better solution to that or it has yet to been found.
Since we only have cubes we can avoid complicated stuff most of the time.

## Why not use?
*Why not use glDrawElementsInstanced + geometry shader instead of glDrawArraysInstanced + geometry shader?*
glDrawElementsInstanced is only useful for groups but we use points here for each object (cube),
so we will have to think how we want to group our objects first. Currently glDrawArraysInstanced is the way to go.
