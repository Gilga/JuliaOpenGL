# Essentials

## Introduction

Julia Base contains a range of functions and macros appropriate for performing
scientific and numerical computing, but is also as broad as those of many general purpose programming
languages.  Additional functionality is available from a growing collection of available packages.
Functions are grouped by topic below.

Some general notes:

  * To use module functions, use `import Module` to import the module, and `Module.fn(x)` to use the
    functions.
  * Alternatively, `using Module` will import all exported `Module` functions into the current namespace.
  * By convention, function names ending with an exclamation point (`!`) modify their arguments.
    Some functions have both modifying (e.g., `sort!`) and non-modifying (`sort`) versions.