[statusPic]: status.png "128³ Blocks"

# JuliaOpenGL

Example 3D OpenGL Szene with up to 128³ Blocks. Uses Instances, Geometry Shader, Frustum Culling and Outside Only (Surrounded Blocks will be hidden) algorithm to render many Blocks efficiency.

For detailed information go to [Documentation](https://gilga.github.io/JuliaOpenGL/).

![statusPic][statusPic]

# Status [![Build Status](https://travis-ci.org/Gilga/JuliaOpenGL.svg?branch=master)](https://travis-ci.org/Gilga/JuliaOpenGL)
* Works with 0.6.0 (Compiling will work, but execution will fail, see [Status of BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl#status))
* Works with 0.6.1
* Works with 0.6.2

# Requirements
## Packages
* Compat
* Images
* ImageMagick
* ModernGL
* GLFW
* Quaternions
* StaticArrays (used by Images)
* WinRPM (used by ImageMagick)

# Compiling
see [Compiling with BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl#compiling)

# Run
## Windows
* Operating System: Windows 10 Home 64-bit (10.0, Build 16299) (16299.rs3_release.170928-1534)
* Processor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), ~2.0GHz
* Memory: 8192MB RAM
* Graphics Card 1: Intel(R) HD Graphics Family
* Graphics Card 2: NVIDIA GeForce 840M

# Program Control
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
