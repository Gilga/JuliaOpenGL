# [Start](@id start)

* [Download](@ref download)
* [Installation](@ref install)
* [Info](#Info)
* [Build](@ref build)
* [Szene](@ref szene)

## [Download](@id download)
1. [Julia 0.6](https://julialang.org/downloads/)
2. [Julia OpenGL](https://github.com/Gilga/JuliaOpenGL)

## [Installation](@id install)
1. Run Julia 0.6 setup
2. Install Packages:
  * Pkg.add("Compat")
  * Pkg.add("Images")
  * Pkg.add("ImageMagick")
  * Pkg.add("ModernGL")
  * Pkg.add("GLFW")
  * Pkg.add("Quaternions")

## Info
Tested on:
* Operating System: Windows 10 Home 64-bit
* Processor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), 2.0GHz
* Memory: 8192MB RAM
* Graphics Card 1: Intel(R) HD Graphics Family
* Graphics Card 2: NVIDIA GeForce 840M (Was mostly used for better FPS values)

## [Build](@id build)
With [BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl) script you can build a executable on your os systems (currently only for windows).
For more information look [build.jl](@ref).

## [Szene](@id szene)

* For information about szene initialization look [here](@ref szene-init).
* For information about render loop look [here](@ref render-loop).
* For information about render algorithms look [here](@ref algorithm).

Rendermethods: 
1. Arrays Instanced + Points
2. Arrays Instanced + Triangles
3. Elements Instanced + Triangles
4. Elements + Triangles

| Key   | Command/Description
|:-----:| :---
|  k    | Show Keys
|  q    | Wireframe (Enable/Disable)     
|  t    | Texture (Enable/Disable)
|  l    | Light (Enable/Disable)
|  f    | Frustum Culling (Enable/Disable)
|  o    | Outside Only Cubes (Enable/Disable)
|  r    | Reload
|F1-F4  | Rendermethod 1 - 4
| 0-9   | Chunk Size 1-64 ^ 3 (0 = 64)
| ß´^   | Chunk Size > 64 (72, 96, 128)
|  b    | Szene: Single Block
|  n    | Szene: Blocks (Full Chunk)
|  m    | Szene: Terrain
|  v    | Set Camera Vew (Frustum)
|  p    | Set Camera Position (Frustum)
| WASD  | Move Camera (Forward,Left,Back,Right,Up,Down)
|Space  | Move Camera (Up)
|Ctrl/c | Move Camera (Down)
|LShift | Hold left shift to speedUp Camera Movement
| HMK   | Hold any mouse key to rotate view

![statusPic](https://raw.githubusercontent.com/Gilga/JuliaOpenGL/master/status.png)
