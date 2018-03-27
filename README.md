# JuliaOpenGL
Example Julia uses OpenGL

# Status
* Works with 0.6.0 (Compiling won't work though see [BuildExecutable.jl](https://github.com/Gilga/BuildExecutable.jl))
* Works with 0.6.1

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

using module namespace in non module context won't work so easily...

execution of main() will fail probably due to missing modules (even so you defined it). why? look:

**in non module context** ("using 'modulename'" has to be called in each function!)
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

I guess the reason is that: app execution != compiler run. main() function will be called by a executable file (.exe) after code was compiled.

So question is if main() function can see all modules that i want to use.

I did an approach of defining an module 'App' around a start() function which is the programs run point (instead of using main).
All necessary files and modules are included there. The main function calls App.start(). This works!

Example:
```julia
module App
  include("myOtherModule")
  
  using Images
  using myOtherModule
  ...
  
  function start() # app run point
    Images.load(...)
    myOtherModule.call()
  end
end

function main() # entry point
  App.start() # app run point
end
```
