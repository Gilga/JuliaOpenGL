# JuliaOpenGL
Example Julia uses OpenGL

# Requirements
## Packages
* Compat
* Images
* ModernGL
* GLFW
* Quaternions
* StaticArrays
* WinRPM

# Run
## Windows
* Operating System: Windows 10 Home 64-bit (10.0, Build 16299) (16299.rs3_release.170928-1534)
* Processor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), ~2.0GHz
* Memory: 8192MB RAM
* Graphics Card 1: Intel(R) HD Graphics Family
* Graphics Card 2: NVIDIA GeForce 840M

# Compiling
Compiling with [BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl)

using lib namespace in non module context won't work so easily...

**in non module context** ("using (module)" has to be called in each function!)
```julia
function test()
  using Images
  Images.load(...)
end
```

**in module context**
```julia
module Test
  using Images
  
  function load()
    Images.load(...)
  end  
end
```