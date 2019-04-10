[statusPic]: status.png "128³ Blocks up to 25 Chunks"

# JuliaOpenGL
[![Build Status](https://travis-ci.org/Gilga/JuliaOpenGL.svg?branch=master)](https://travis-ci.org/Gilga/JuliaOpenGL) (Julia 1.1.0)

Example 3D OpenGL Szene passed 128³ Blocks and build up to 25 Chunks. Completely shader based approach.

On GPU:
1. Blocks are filtered by a Remove-Surrounded-Blocks algorithm (hidden Blocks will not be drawn)
2. Frustum Culling is used in a compute shader
3. block (point) instances are send to Vertex Shader (use of glMultiDrawArraysIndirect)
4. Geometry Shader creates Block Geometry (Vertices)
5. Fragment Shader does texturing and lightning

## Problems / Open TODOS
* No LOD (still WIP)
* No Occlusion Culling
* Whole pipeline needs rework because transfer is slow

## Program Control
See [Controls.md](Controls.md)

## Documentation
Full detailed documentation can be found [here](https://gilga.github.io/JuliaOpenGL/).

## Requirements (Packages)
* [Julia 1.1.0](https://julialang.org/downloads/)
* ~~See [Project.toml](Project.toml)~~ See [REQUIRE](REQUIRE)

## Assets
Example Assets can be found [here](https://github.com/Gilga/JLGLAssets)

## Compiling
See [Compiling with BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl#compiling)

## Run
### Windows
* Operating System: Windows 10 Home 64-bit (10.0, Build 17134 or newer)
* Processor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), ~2.0GHz
* Memory: 8192MB RAM
* Graphics Card 1: Intel(R) HD Graphics Family
* Graphics Card 2: NVIDIA GeForce 840M

### Linux
* not tested yet

![statusPic][statusPic]
