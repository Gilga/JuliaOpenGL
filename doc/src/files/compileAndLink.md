# [compileAndLink.jl](@id compileAndLink.jl)

* COMPILE WITH GCC
* LINK LIB FUNCTIONS

```@docs
App.find_system_gcc()
```

```@docs
App.gcc_compile(gcc,file,libname,env)
```

```@docs
App.write_c_file(libname)
```

```@docs
App.compiler_setPaths(gcc,env_path)
```

```@docs
App.createLoop(index, array, func)
```

```@docs
App.loopByIndex(index)
```

```@docs
App.loopByObject(pointer)
```

```@docs
App.prepareStaticLoop(x,a)
```

```@docs
App.staticloop()
```