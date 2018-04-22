# [Optimization](@id optimization)

Optimization can be done know how to write your code following the rules of julia page ()[].

Another option to optimize is to use write c-code, use gcc compiler to compile a lib (dll) file and link to its c-functions in julia.

If you wanna use on Windows Visual Studio's famous C++ Compiler you can do this aswell, just keep in mind to export your c++ functions to c.

## JuliaOptimizer
Is one approach to use the C++ of Visual Studio (Windows)

Files main.h and main.cpp contains examples where you can pass data from julia to C++ or C++ to julia.

Example export to c:
```
#define EXPORT __declspec(dllexport)

extern "C" {
  EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);
  EXPORT void loopByIndex(const unsigned int);
  EXPORT void loopByObject(void*);
  EXPORT void prepare(LoopFunc f, void** a, unsigned int count);
  EXPORT void loop();
};
```
