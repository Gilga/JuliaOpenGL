[statusPic]: status.png "128³ Blocks"

# JuliaOpenGL
[![Build Status](https://travis-ci.org/Gilga/JuliaOpenGL.svg?branch=master)](https://travis-ci.org/Gilga/JuliaOpenGL) (Julia 1.0.0)

Example 3D OpenGL Szene with up to 128³ Blocks.
1. Blocks are filtered by Remove-Surrounded-Blocks algorithm (hidden Blocks will not be drawn)
2. Blocks Instances are send to the GPU
3. Frustum Culling is used in compute shader, indirect draw call sends new set of instances to Vertex Shader
4. Geometry Shader will create Block Geometry Data (Vertices)
5. Fragment Shader does texturing and lightning

## Program Control
See [Controls.md](Controls.md)

## Documentation
Full detailed documentation can be found [here](https://gilga.github.io/JuliaOpenGL/).

## Requirements (Packages)
See [Project.toml](Project.toml)

## Compiling
See [Compiling with BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl#compiling)

## Run
### Windows
* Operating System: Windows 10 Home 64-bit (10.0, ~~Build 16299~~) ~~(16299.rs3_release.170928-1534)~~
* Processor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), ~2.0GHz
* Memory: 8192MB RAM
* Graphics Card 1: Intel(R) HD Graphics Family
* Graphics Card 2: NVIDIA GeForce 840M
### Linux
* not tested

![statusPic][statusPic]
