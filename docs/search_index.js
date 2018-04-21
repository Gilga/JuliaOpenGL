var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "JuliaOpenGL",
    "title": "JuliaOpenGL",
    "category": "page",
    "text": ""
},

{
    "location": "#JuliaOpenGL-1",
    "page": "JuliaOpenGL",
    "title": "JuliaOpenGL",
    "category": "section",
    "text": "Description"
},

{
    "location": "#App",
    "page": "JuliaOpenGL",
    "title": "App",
    "category": "module",
    "text": "Module App\n\n\n\n"
},

{
    "location": "#Start-1",
    "page": "JuliaOpenGL",
    "title": "Start",
    "category": "section",
    "text": "Manual\nBase\nStandard Library\nDeveloper DocumentationAppsetMode(program, name, mode)"
},

{
    "location": "#Manual-1",
    "page": "JuliaOpenGL",
    "title": "Manual",
    "category": "section",
    "text": "Introduction"
},

{
    "location": "#Base-1",
    "page": "JuliaOpenGL",
    "title": "Base",
    "category": "section",
    "text": "Essentials"
},

{
    "location": "#Developer-Documentation-1",
    "page": "JuliaOpenGL",
    "title": "Developer Documentation",
    "category": "section",
    "text": "Reflection and introspection\nDocumentation of Julia\'s Internals\nInitialization of the Julia runtime\nDeveloping/debugging Julia\'s C code\nReporting and analyzing crashes"
},

{
    "location": "manual/Essentials/#",
    "page": "Essentials",
    "title": "Essentials",
    "category": "page",
    "text": ""
},

{
    "location": "manual/Essentials/#Essentials-1",
    "page": "Essentials",
    "title": "Essentials",
    "category": "section",
    "text": ""
},

{
    "location": "manual/Essentials/#Introduction-1",
    "page": "Essentials",
    "title": "Introduction",
    "category": "section",
    "text": "Julia Base contains a range of functions and macros appropriate for performing scientific and numerical computing, but is also as broad as those of many general purpose programming languages.  Additional functionality is available from a growing collection of available packages. Functions are grouped by topic below.Some general notes:To use module functions, use import Module to import the module, and Module.fn(x) to use the functions.\nAlternatively, using Module will import all exported Module functions into the current namespace.\nBy convention, function names ending with an exclamation point (!) modify their arguments. Some functions have both modifying (e.g., sort!) and non-modifying (sort) versions."
},

{
    "location": "manual/Introduction/#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "manual/Introduction/#man-introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "Scientific computing has traditionally required the highest performance, yet domain experts have largely moved to slower dynamic languages for daily work. We believe there are many good reasons to prefer dynamic languages for these applications, and we do not expect their use to diminish. Fortunately, modern language design and compiler techniques make it possible to mostly eliminate the performance trade-off and provide a single environment productive enough for prototyping and efficient enough for deploying performance-intensive applications. The Julia programming language fills this role: it is a flexible dynamic language, appropriate for scientific and numerical computing, with performance comparable to traditional statically-typed languages.Because Julia\'s compiler is different from the interpreters used for languages like Python or R, you may find that Julia\'s performance is unintuitive at first. If you find that something is slow, we highly recommend reading through the Performance Tips section before trying anything else. Once you understand how Julia works, it\'s easy to write code that\'s nearly as fast as C.Julia features optional typing, multiple dispatch, and good performance, achieved using type inference and just-in-time (JIT) compilation, implemented using LLVM. It is multi-paradigm, combining features of imperative, functional, and object-oriented programming. Julia provides ease and expressiveness for high-level numerical computing, in the same way as languages such as R, MATLAB, and Python, but also supports general programming. To achieve this, Julia builds upon the lineage of mathematical programming languages, but also borrows much from popular dynamic languages, including Lisp, Perl, Python, Lua, and Ruby.The most significant departures of Julia from typical dynamic languages are:The core language imposes very little; Julia Base and the standard library is written in Julia itself, including primitive operations like integer arithmetic\nA rich language of types for constructing and describing objects, that can also optionally be used to make type declarations\nThe ability to define function behavior across many combinations of argument types via multiple dispatch\nAutomatic generation of efficient, specialized code for different argument types\nGood performance, approaching that of statically-compiled languages like CAlthough one sometimes speaks of dynamic languages as being \"typeless\", they are definitely not: every object, whether primitive or user-defined, has a type. The lack of type declarations in most dynamic languages, however, means that one cannot instruct the compiler about the types of values, and often cannot explicitly talk about types at all. In static languages, on the other hand, while one can – and usually must – annotate types for the compiler, types exist only at compile time and cannot be manipulated or expressed at run time. In Julia, types are themselves run-time objects, and can also be used to convey information to the compiler.While the casual programmer need not explicitly use types or multiple dispatch, they are the core unifying features of Julia: functions are defined on different combinations of argument types, and applied by dispatching to the most specific matching definition. This model is a good fit for mathematical programming, where it is unnatural for the first argument to \"own\" an operation as in traditional object-oriented dispatch. Operators are just functions with special notation – to extend addition to new user-defined data types, you define new methods for the + function. Existing code then seamlessly applies to the new data types.Partly because of run-time type inference (augmented by optional type annotations), and partly because of a strong focus on performance from the inception of the project, Julia\'s computational efficiency exceeds that of other dynamic languages, and even rivals that of statically-compiled languages. For large scale numerical problems, speed always has been, continues to be, and probably always will be crucial: the amount of data being processed has easily kept pace with Moore\'s Law over the past decades.Julia aims to create an unprecedented combination of ease-of-use, power, and efficiency in a single language. In addition to the above, some advantages of Julia over comparable systems include:Free and open source (MIT licensed)\nUser-defined types are as fast and compact as built-ins\nNo need to vectorize code for performance; devectorized code is fast\nDesigned for parallelism and distributed computation\nLightweight \"green\" threading (coroutines)\nUnobtrusive yet powerful type system\nElegant and extensible conversions and promotions for numeric and other types\nEfficient support for Unicode, including but not limited to UTF-8\nCall C functions directly (no wrappers or special APIs needed)\nPowerful shell-like capabilities for managing other processes\nLisp-like macros and other metaprogramming facilities"
},

]}
