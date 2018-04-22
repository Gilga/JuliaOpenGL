var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#JuliaOpenGL-1",
    "page": "Home",
    "title": "JuliaOpenGL",
    "category": "section",
    "text": "Example 3D OpenGL Szene with up to 128³ Blocks. Uses Instances, Geometry Shader, Frustum Culling and Outside Only (Surrounded Blocks will be hidden) algorithm to render many Blocks efficiency."
},

{
    "location": "index.html#Start-1",
    "page": "Home",
    "title": "Start",
    "category": "section",
    "text": "Manual\nDeveloper Documentation"
},

{
    "location": "index.html#Manual-1",
    "page": "Home",
    "title": "Manual",
    "category": "section",
    "text": "Start\nInstall\nSzene"
},

{
    "location": "index.html#Developer-Documentation-1",
    "page": "Home",
    "title": "Developer Documentation",
    "category": "section",
    "text": "Algorithm\nBuild\nOptimization\nReferences"
},

{
    "location": "manual/start.html#",
    "page": "Start",
    "title": "Start",
    "category": "page",
    "text": ""
},

{
    "location": "manual/start.html#start-1",
    "page": "Start",
    "title": "Start",
    "category": "section",
    "text": "Download\nInstallation\nInfo\nBuild\nSzene"
},

{
    "location": "manual/start.html#download-1",
    "page": "Start",
    "title": "Download",
    "category": "section",
    "text": "Julia 0.6\nJulia OpenGL"
},

{
    "location": "manual/start.html#install-1",
    "page": "Start",
    "title": "Installation",
    "category": "section",
    "text": "Run Julia 0.6 setup\nInstall Packages:Pkg.add(\"Compat\")\nPkg.add(\"Images\")\nPkg.add(\"ImageMagick\")\nPkg.add(\"ModernGL\")\nPkg.add(\"GLFW\")\nPkg.add(\"Quaternions\")"
},

{
    "location": "manual/start.html#Info-1",
    "page": "Start",
    "title": "Info",
    "category": "section",
    "text": "Tested on:Operating System: Windows 10 Home 64-bit\nProcessor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), 2.0GHz\nMemory: 8192MB RAM\nGraphics Card 1: Intel(R) HD Graphics Family\nGraphics Card 2: NVIDIA GeForce 840M (Was mostly used for better FPS values)"
},

{
    "location": "manual/start.html#build-1",
    "page": "Start",
    "title": "Build",
    "category": "section",
    "text": "With BuildExecutable.jl script you can build a executable on your os systems (currently only for windows). For more information look build.jl."
},

{
    "location": "manual/start.html#szene-1",
    "page": "Start",
    "title": "Szene",
    "category": "section",
    "text": "For information about szene initialization look here.\nFor information about render loop look here.\nFor information about render algorithms look here.Rendermethods: Arrays Instanced + Points\nArrays Instanced + Triangles\nElements Instanced + Triangles\nElements + TrianglesKey Command/Description\nk Show Keys\nq Wireframe (Enable/Disable)\nt Texture (Enable/Disable)\nl Light (Enable/Disable)\nf Frustum Culling (Enable/Disable)\no Outside Only Cubes (Enable/Disable)\nr Reload\nF1-F4 Rendermethod 1 - 4\n0-9 Chunk Size 1-64 ^ 3 (0 = 64)\nß´^ Chunk Size > 64 (72, 96, 128)\nb Szene: Single Block\nn Szene: Blocks (Full Chunk)\nm Szene: Terrain\nv Set Camera Vew (Frustum)\np Set Camera Position (Frustum)\nWASD Move Camera (Forward,Left,Back,Right,Up,Down)\nSpace Move Camera (Up)\nCtrl/c Move Camera (Down)\nLShift Hold left shift to speedUp Camera Movement\nHMK Hold any mouse key to rotate view(Image: statusPic)"
},

{
    "location": "manual/algorithm.html#",
    "page": "Algorithm",
    "title": "Algorithm",
    "category": "page",
    "text": ""
},

{
    "location": "manual/algorithm.html#algorithm-1",
    "page": "Algorithm",
    "title": "Algorithm",
    "category": "section",
    "text": "For this project i use an advanced OpenGL technique and two algorithm to render up to 128³ blocks with 100 or more FPS.OpenGL\nFrustum Culling\nOutside Only\nAll together\nNext step\nWhy not use?"
},

{
    "location": "manual/algorithm.html#OpenGL-1",
    "page": "Algorithm",
    "title": "OpenGL",
    "category": "section",
    "text": "glDrawElementsInstanced and glDrawArraysInstanced to render many objects at once\nGPU Geometry shader to adjust amount of vertices given by input. No need to create vertices on CPU side. Geometry shader example:void createSide(Vertex v, int side) {\r\n  for(int i=0;i<4;++i) {\r\n    (...)\r\n    gl_Position = iMVP * v.world_pos;\r\n    EmitVertex();\r\n  }\r\n  EndPrimitive();\r\n}\r\n\r\nvoid main() {\r\n  (...)\r\n  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT\r\n  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT\r\n  if((sides & 0x4) > 0) createSide(v, 0);  // TOP\r\n  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM\r\n  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT\r\n  if((sides & 0x20) > 0) createSide(v, 3);  // BACK\r\n  (...)\r\n}"
},

{
    "location": "manual/algorithm.html#Frustum-Culling-1",
    "page": "Algorithm",
    "title": "Frustum Culling",
    "category": "section",
    "text": "Frustum culling is 3d geometric object (a cone with top and bottom sliced off). In code frustum has six planes (top,bottom,right,left,near,far) in total where each plane measure the distance between itself and a given object. For visual demonstration look Frustum Culling Video by AlwaysGeeky.Code:type Plane\r\n position  :: Vector\r\n normal    :: Vector\r\n distance  :: Value\r\nendtype Frustum\r\n  planes :: Array\r\n  \r\n  nearDistance  :: Value\r\n  farDistance   :: Value\r\n  nearWidth     :: Value\r\n  nearHeight    :: Value\r\n  farWidth      :: Value\r\n  farHeight     :: Value\r\n  ratio         :: Value\r\n  angle         :: Value\r\n  tang          :: Value\r\n  \r\n  nearTopLeft     :: Vector\r\n  nearTopRight    :: Vector\r\n  nearBottomLeft  :: Vector\r\n  nearBottomRight :: Vector\r\n  farTopLeft      :: Vector\r\n  farTopRight     :: Vector\r\n  farBottomLeft   :: Vector\r\n  farBottomRight  :: Vector\r\nendSet Camera is called in main script and sets the view for the frustum App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)Set Frustum is almost similiar to set camera execpt its sets ratio, angle, far and near values App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)GetPointDistance gets the distance between current plane and a point App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)checkSphere is a batter option than checkCube because its faster App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)checkInFrustum is called in when blocks are created / updated App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)"
},

{
    "location": "manual/algorithm.html#Outside-Only-1",
    "page": "Algorithm",
    "title": "Outside Only",
    "category": "section",
    "text": "Is a simple algorithm to filter objects which are surrounded by other objects and are not visible from the outside. It hides not only the objects itself but its non-visible sides too. Those objects are cubes so we have only six sides to check for visibility.The algorithm App.hideUnseen(this::App.Chunk)"
},

{
    "location": "manual/algorithm.html#All-together-1",
    "page": "Algorithm",
    "title": "All together",
    "category": "section",
    "text": "Combining OpenGL technique and those two algorithm gives high quality results.This gets us a filtered list of objects where those algorithms were applied to App.getFilteredChilds(this::App.Chunk)"
},

{
    "location": "manual/algorithm.html#Next-step-1",
    "page": "Algorithm",
    "title": "Next step",
    "category": "section",
    "text": "Next step is to filter objects which are not seen due to interference of other objects (blocking the view). An approach could be using a raytracer but maybe there is an even better solution to that or it has yet to been found. Since we only have cubes we can avoid complicated stuff most of the time."
},

{
    "location": "manual/algorithm.html#Why-not-use?-1",
    "page": "Algorithm",
    "title": "Why not use?",
    "category": "section",
    "text": "Why not use glDrawElementsInstanced + geometry shader instead of glDrawArraysInstanced + geometry shader? glDrawElementsInstanced is only useful for groups but we use points here for each object (cube), so we will have to think how we want to group our objects first. Currently glDrawArraysInstanced is the way to go."
},

{
    "location": "manual/optimization.html#",
    "page": "Optimization",
    "title": "Optimization",
    "category": "page",
    "text": ""
},

{
    "location": "manual/optimization.html#optimization-1",
    "page": "Optimization",
    "title": "Optimization",
    "category": "section",
    "text": "Optimization can be done know how to write your code following the rules of julia page ()[].Another option to optimize is to use write c-code, use gcc compiler to compile a lib (dll) file and link to its c-functions in julia.If you wanna use on Windows Visual Studio\'s famous C++ Compiler you can do this aswell, just keep in mind to export your c++ functions to c."
},

{
    "location": "manual/optimization.html#JuliaOptimizer-1",
    "page": "Optimization",
    "title": "JuliaOptimizer",
    "category": "section",
    "text": "Is one approach to use the C++ of Visual Studio (Windows)Files main.h and main.cpp contains examples where you can pass data from julia to C++ or C++ to julia.Example export to c:#define EXPORT __declspec(dllexport)\r\n\r\nextern \"C\" {\r\n  EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);\r\n  EXPORT void loopByIndex(const unsigned int);\r\n  EXPORT void loopByObject(void*);\r\n  EXPORT void prepare(LoopFunc f, void** a, unsigned int count);\r\n  EXPORT void loop();\r\n};"
},

{
    "location": "manual/references.html#",
    "page": "References",
    "title": "References",
    "category": "page",
    "text": ""
},

{
    "location": "manual/references.html#references-1",
    "page": "References",
    "title": "References",
    "category": "section",
    "text": ""
},

{
    "location": "manual/references.html#Julia-vs-Python-1",
    "page": "References",
    "title": "Julia vs Python",
    "category": "section",
    "text": "I found articles about this topic. First one was against julia but it had somewhat poor evidence for julia downsides. The last two articles i found favour julia over python for various situations by demonstrating benchmarks or code examples in comparison with python.Against Julia - \'Giving up on Julia\' and \'Python Benchmarks\'\nFavour Julia - \'An Updated Analysis for the \"Giving Up on Julia\" Blog Post\'\nFavour Julia - \'Python vs Julia Observations\'"
},

{
    "location": "manual/references.html#Honorable-mentions-1",
    "page": "References",
    "title": "Honorable mentions",
    "category": "section",
    "text": "Since knowlegde does not grow on trees. I decide to put my sources here as honorable mentions because those websites helped me allot:Let\'s Make a Voxel Engine\n...\n...\n..."
},

{
    "location": "files/JuliaOpenGL.html#",
    "page": "JuliaOpenGL.jl",
    "title": "JuliaOpenGL.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/JuliaOpenGL.html#App",
    "page": "JuliaOpenGL.jl",
    "title": "App",
    "category": "module",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#JuliaOpenGL.jl-1",
    "page": "JuliaOpenGL.jl",
    "title": "JuliaOpenGL.jl",
    "category": "section",
    "text": "Definitions\nProgram Init\nSzene Init\nCamera\nMesh\nTextures\nShader\nOther\nRender LoopApp"
},

{
    "location": "files/JuliaOpenGL.html#Main-Call-1",
    "page": "JuliaOpenGL.jl",
    "title": "Main Call",
    "category": "section",
    "text": "function main()\r\n  App.run()\r\nend"
},

{
    "location": "files/JuliaOpenGL.html#App.run-Tuple{}",
    "page": "JuliaOpenGL.jl",
    "title": "App.run",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#Program-Run-1",
    "page": "JuliaOpenGL.jl",
    "title": "Program Run",
    "category": "section",
    "text": "App.run()"
},

{
    "location": "files/JuliaOpenGL.html#App.setMode-Tuple{Any,Any,Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.setMode",
    "category": "method",
    "text": "sets a mode in a shader.\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.setFrustumCulling-Tuple{Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.setFrustumCulling",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.chooseRenderMethod-Tuple{Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.chooseRenderMethod",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.checkForUpdate-Tuple{}",
    "page": "JuliaOpenGL.jl",
    "title": "App.checkForUpdate",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.useProgram-Tuple{Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.useProgram",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.setMatrix-Tuple{Any,Any,Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.setMatrix",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#App.setMVP-Tuple{Any,Any,Any}",
    "page": "JuliaOpenGL.jl",
    "title": "App.setMVP",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#Definitions-1",
    "page": "JuliaOpenGL.jl",
    "title": "Definitions",
    "category": "section",
    "text": "App.setMode(program, name, mode)App.setFrustumCulling(load)App.chooseRenderMethod(method)App.checkForUpdate()App.useProgram(program)App.setMatrix(program, name, m)App.setMVP(program, mvp, old_program)"
},

{
    "location": "files/JuliaOpenGL.html#Program-Init-1",
    "page": "JuliaOpenGL.jl",
    "title": "Program Init",
    "category": "section",
    "text": "Output Program Info (Print)\nOS X-specific GLFW hints to initialize the correct version of OpenGL\nCreate a windowed mode window and its OpenGL context\nMake the window\'s context current\nSet windows size and viewport - seems to be necessary to guarantee that window > 0\nWindow settings - SwapInterval - intervall between canvas images (min. 2 images)\nGraphcis Settings - show opengl debug report\nSet OpenGL Version (Major,Minor) - 4.6\nSet OpenGL Event Callbacks\nShow window\nOutput OpenGL Info (Print)"
},

{
    "location": "files/JuliaOpenGL.html#App.chooseRenderMethod",
    "page": "JuliaOpenGL.jl",
    "title": "App.chooseRenderMethod",
    "category": "function",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#szene-init-1",
    "page": "JuliaOpenGL.jl",
    "title": "Szene Init",
    "category": "section",
    "text": "Chooses render methodApp.chooseRenderMethod"
},

{
    "location": "files/JuliaOpenGL.html#Camera-1",
    "page": "JuliaOpenGL.jl",
    "title": "Camera",
    "category": "section",
    "text": "Sets Camera position\nSets Camera projection\nCreates/Sets Frustum\nUpdates Camera"
},

{
    "location": "files/JuliaOpenGL.html#Mesh-1",
    "page": "JuliaOpenGL.jl",
    "title": "Mesh",
    "category": "section",
    "text": "Creates and Links Mesh Data"
},

{
    "location": "files/JuliaOpenGL.html#Textures-1",
    "page": "JuliaOpenGL.jl",
    "title": "Textures",
    "category": "section",
    "text": "uploads this texture."
},

{
    "location": "files/JuliaOpenGL.html#Shader-1",
    "page": "JuliaOpenGL.jl",
    "title": "Shader",
    "category": "section",
    "text": "Creates Shader\nSets Shader Attributes\nSets Uniform Variables (like MVP from Camera)"
},

{
    "location": "files/JuliaOpenGL.html#Other-1",
    "page": "JuliaOpenGL.jl",
    "title": "Other",
    "category": "section",
    "text": "Sets OpenGL Render Options"
},

{
    "location": "files/JuliaOpenGL.html#render-loop-1",
    "page": "JuliaOpenGL.jl",
    "title": "Render Loop",
    "category": "section",
    "text": "Begin Render Loop while (window is open)\nEvent OnUpdate -> setMVP\nShow frames\nupdate counters/timers\nClear szene background\nBind Shader Program\nWirefram Option\nBind Vertex Array\nDraw:if isValid(mychunk) \r\n  (...)\r\n  if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS)  # + geometry shader => very fast!\r\n  elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES)  # fast\r\n  elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES)  # faster than 2 (only useful for groups)\r\n  elseif RENDER_METHOD > 3\r\n    for b in getFilteredChilds(mychunk)  # thats slow!\r\n      glDrawElements(GL_TRIANGLES)\r\n    end\r\n  end\r\n  (...)For more information about render algorithms look here.Unbind Vertex Array\nSwap front and back buffers\nPoll for and process events\nSleep function\nEnd Render Loop\ndestroy Window \nterminate"
},

{
    "location": "files/build.html#",
    "page": "build.jl",
    "title": "build.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/build.html#build.jl-1",
    "page": "build.jl",
    "title": "build.jl",
    "category": "section",
    "text": "This File searches for BuildExecutable.jl in current path and parent dirs. BuildExecutable.jl is required to build Executables on windows machines. It runs the script automatically and creates a executable in bin folder in root directory."
},

{
    "location": "files/camera.html#",
    "page": "camera.jl",
    "title": "camera.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/camera.html#App.rezizeWindow-Tuple{Any,Any}",
    "page": "camera.jl",
    "title": "App.rezizeWindow",
    "category": "method",
    "text": "sets glfw window size + viewport\n\n\n\n"
},

{
    "location": "files/camera.html#App.Camera",
    "page": "camera.jl",
    "title": "App.Camera",
    "category": "type",
    "text": "camera object with holds position, rotation, scaling and various matrices like MVP\n\n\n\n"
},

{
    "location": "files/camera.html#App.forward-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.forward",
    "category": "method",
    "text": "gets forward vector of camera direction\n\n\n\n"
},

{
    "location": "files/camera.html#App.right-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.right",
    "category": "method",
    "text": "gets right vector of camera direction\n\n\n\n"
},

{
    "location": "files/camera.html#App.up-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.up",
    "category": "method",
    "text": "gets up vector of camera direction\n\n\n\n"
},

{
    "location": "files/camera.html#App.setProjection-Tuple{App.Camera,AbstractArray}",
    "page": "camera.jl",
    "title": "App.setProjection",
    "category": "method",
    "text": "sets projection matrix\n\n\n\n"
},

{
    "location": "files/camera.html#App.setView-Tuple{App.Camera,AbstractArray}",
    "page": "camera.jl",
    "title": "App.setView",
    "category": "method",
    "text": "sets view matrix\n\n\n\n"
},

{
    "location": "files/camera.html#App.OnKey-Tuple{Any,Number,Number,Number,Number}",
    "page": "camera.jl",
    "title": "App.OnKey",
    "category": "method",
    "text": "event which catches keyboard inputs. here keys for wireframe, fullscreen and camera movement are defined \n\n\n\n"
},

{
    "location": "files/camera.html#App.OnMouseKey-Tuple{Any,Number,Number,Number}",
    "page": "camera.jl",
    "title": "App.OnMouseKey",
    "category": "method",
    "text": "event which catches mouse key inpits and hides/shows cursor when mouse button is pressed\n\n\n\n"
},

{
    "location": "files/camera.html#App.OnCursorPos-Tuple{Any,Number,Number}",
    "page": "camera.jl",
    "title": "App.OnCursorPos",
    "category": "method",
    "text": "event which catches mouse position for camera rotation event\n\n\n\n"
},

{
    "location": "files/camera.html#App.rotate-Tuple{App.Camera,AbstractArray}",
    "page": "camera.jl",
    "title": "App.rotate",
    "category": "method",
    "text": "rotates camera\n\n\n\n"
},

{
    "location": "files/camera.html#App.move-Tuple{App.Camera,AbstractArray}",
    "page": "camera.jl",
    "title": "App.move",
    "category": "method",
    "text": "moves camera, adds vector to current position\n\n\n\n"
},

{
    "location": "files/camera.html#App.OnRotate-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.OnRotate",
    "category": "method",
    "text": "event which calculates cursor position shifts and calls rotate function\n\n\n\n"
},

{
    "location": "files/camera.html#App.setPosition-Tuple{App.Camera,AbstractArray}",
    "page": "camera.jl",
    "title": "App.setPosition",
    "category": "method",
    "text": "sets camera position\n\n\n\n"
},

{
    "location": "files/camera.html#App.OnMove-Tuple{App.Camera,Symbol,Number}",
    "page": "camera.jl",
    "title": "App.OnMove",
    "category": "method",
    "text": "event which updates positions shifts (left,right,up,down,forward,back) key is (left,right,up,down,forward,back) m is direction value with weight (positive, negative)\n\n\n\n"
},

{
    "location": "files/camera.html#App.Update-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.Update",
    "category": "method",
    "text": "update function where camera translation is update only when camera was moved by input.  here cameras MVP Matrix is updated aswell\n\n\n\n"
},

{
    "location": "files/camera.html#App.OnUpdate-Tuple{App.Camera}",
    "page": "camera.jl",
    "title": "App.OnUpdate",
    "category": "method",
    "text": "event which is called by game loop and calls real update function this event resets camera moved state\n\n\n\n"
},

{
    "location": "files/camera.html#camera.jl-1",
    "page": "camera.jl",
    "title": "camera.jl",
    "category": "section",
    "text": "Camera script with defines camera object, its functions, events and creates a single camera object for whole szene.App.rezizeWindow(width,height)App.CameraApp.forward(camera::App.Camera)App.right(camera::App.Camera)App.up(camera::App.Camera)App.setProjection(camera::App.Camera, m::AbstractArray)App.setView(camera::App.Camera, m::AbstractArray)App.OnKey(window, key::Number, scancode::Number, action::Number, mods::Number)App.OnMouseKey(window, key::Number, action::Number, mods::Number)App.OnCursorPos(window, x::Number, y::Number)App.rotate(camera::App.Camera, rotation::AbstractArray)App.move(camera::App.Camera, position::AbstractArray)App.OnRotate(camera::App.Camera)App.setPosition(camera::App.Camera, position::AbstractArray)App.OnMove(camera::App.Camera, key::Symbol, m::Number)App.Update(camera::App.Camera)App.OnUpdate(camera::App.Camera)"
},

{
    "location": "files/chunk.html#",
    "page": "chunk.jl",
    "title": "chunk.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/chunk.html#App.HeptaOrder",
    "page": "chunk.jl",
    "title": "App.HeptaOrder",
    "category": "type",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.Block",
    "page": "chunk.jl",
    "title": "App.Block",
    "category": "type",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.Chunk-Tuple{Integer}",
    "page": "chunk.jl",
    "title": "App.Chunk",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.clean-Tuple{Union{App.Chunk, Void}}",
    "page": "chunk.jl",
    "title": "App.clean",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isType-Tuple{App.Block,Any}",
    "page": "chunk.jl",
    "title": "App.isType",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isValid-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.isValid",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isSeen-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.isSeen",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.resetSides-Tuple{}",
    "page": "chunk.jl",
    "title": "App.resetSides",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.resetSides-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.resetSides",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.hideUnseen-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.hideUnseen",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.setFlag-Tuple{App.Block,Unsigned,Bool}",
    "page": "chunk.jl",
    "title": "App.setFlag",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isActive-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.isActive",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isVisible-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.isVisible",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isSurrounded-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.isSurrounded",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.isValid-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.isValid",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.setActive-Tuple{App.Block,Bool}",
    "page": "chunk.jl",
    "title": "App.setActive",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.setVisible-Tuple{App.Block,Bool}",
    "page": "chunk.jl",
    "title": "App.setVisible",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.setSurrounded-Tuple{App.Block,Bool}",
    "page": "chunk.jl",
    "title": "App.setSurrounded",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.hideType-Tuple{App.Chunk,Integer}",
    "page": "chunk.jl",
    "title": "App.hideType",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.removeType-Tuple{App.Chunk,Integer}",
    "page": "chunk.jl",
    "title": "App.removeType",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.showAll-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.showAll",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.checkInFrustum-Tuple{App.Chunk,App.Frustum}",
    "page": "chunk.jl",
    "title": "App.checkInFrustum",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.setFilteredChilds-Tuple{App.Chunk,Array{App.Block,1}}",
    "page": "chunk.jl",
    "title": "App.setFilteredChilds",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getFilteredChilds-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.getFilteredChilds",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getActiveChilds-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.getActiveChilds",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getVisibleChilds-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.getVisibleChilds",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getValidChilds-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.getValidChilds",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getData-Tuple{App.Block}",
    "page": "chunk.jl",
    "title": "App.getData",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.getData-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.getData",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.update-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.update",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.createSingle-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.createSingle",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.createExample-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.createExample",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#App.createLandscape-Tuple{App.Chunk}",
    "page": "chunk.jl",
    "title": "App.createLandscape",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/chunk.html#chunk.jl-1",
    "page": "chunk.jl",
    "title": "chunk.jl",
    "category": "section",
    "text": "App.HeptaOrder{T}\r\nApp.Block(pos=App.Vec3f,typ=0)App.Chunk(len::Integer)App.clean(this::Union{Void,App.Chunk})App.isType(this::App.Block, typ)App.isValid(this::App.Chunk) App.isSeen(this::App.Block)App.resetSides()App.resetSides(this::App.Block)App.hideUnseen(this::App.Chunk)App.setFlag(this::App.Block, flag::Unsigned, add::Bool)App.isActive(this::App.Block)App.isVisible(this::App.Block)App.isSurrounded(this::App.Block)App.isValid(this::App.Block)App.setActive(this::App.Block, active::Bool)App.setVisible(this::App.Block, visible::Bool)App.setSurrounded(this::App.Block, surrounded::Bool)App.hideType(this::App.Chunk, typ::Integer)App.removeType(this::App.Chunk, typ::Integer)App.showAll(this::App.Chunk)App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)App.setFilteredChilds(this::App.Chunk, r::Array{App.Block,1})App.getFilteredChilds(this::App.Chunk)App.getActiveChilds(this::App.Chunk)App.getVisibleChilds(this::App.Chunk)App.getValidChilds(this::App.Chunk)App.getData(this::App.Block)App.getData(this::App.Chunk)App.update(this::App.Chunk)App.createSingle(this::App.Chunk)App.createExample(this::App.Chunk)App.createLandscape(this::App.Chunk)"
},

{
    "location": "files/compileAndLink.html#",
    "page": "compileAndLink.jl",
    "title": "compileAndLink.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/compileAndLink.html#App.find_system_gcc-Tuple{}",
    "page": "compileAndLink.jl",
    "title": "App.find_system_gcc",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.gcc_compile-NTuple{4,Any}",
    "page": "compileAndLink.jl",
    "title": "App.gcc_compile",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.write_c_file-Tuple{Any}",
    "page": "compileAndLink.jl",
    "title": "App.write_c_file",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.compiler_setPaths-Tuple{Any,Any}",
    "page": "compileAndLink.jl",
    "title": "App.compiler_setPaths",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.createLoop-Tuple{Any,Any,Any}",
    "page": "compileAndLink.jl",
    "title": "App.createLoop",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.loopByIndex-Tuple{Any}",
    "page": "compileAndLink.jl",
    "title": "App.loopByIndex",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.loopByObject-Tuple{Any}",
    "page": "compileAndLink.jl",
    "title": "App.loopByObject",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.prepareStaticLoop-Tuple{Any,Any}",
    "page": "compileAndLink.jl",
    "title": "App.prepareStaticLoop",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#App.staticloop-Tuple{}",
    "page": "compileAndLink.jl",
    "title": "App.staticloop",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/compileAndLink.html#compileAndLink.jl-1",
    "page": "compileAndLink.jl",
    "title": "compileAndLink.jl",
    "category": "section",
    "text": "COMPILE WITH GCC\nLINK LIB FUNCTIONSApp.find_system_gcc()App.gcc_compile(gcc,file,libname,env)App.write_c_file(libname)App.compiler_setPaths(gcc,env_path)App.createLoop(index, array, func)App.loopByIndex(index)App.loopByObject(pointer)App.prepareStaticLoop(x,a)App.staticloop()"
},

{
    "location": "files/cubeData.html#",
    "page": "cubeData.jl",
    "title": "cubeData.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/cubeData.html#cubeData.jl-1",
    "page": "cubeData.jl",
    "title": "cubeData.jl",
    "category": "section",
    "text": "DATA_DUMMY\nDATA_CUBE\nDATA_CUBE_VERTEX\nDATA_CUBE_INDEX \nDATA_PLANE_VERTEX\nDATA_PLANE_INDEX "
},

{
    "location": "files/frustum.html#",
    "page": "frutsum.jl",
    "title": "frutsum.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/frustum.html#App.Plane3D",
    "page": "frutsum.jl",
    "title": "App.Plane3D",
    "category": "type",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.Plane3D-Tuple{App.Vector3{Float32},App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.Plane3D",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.Plane3D-Tuple{App.Vector3{Float32},App.Vector3{Float32},App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.Plane3D",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.Plane3D-NTuple{4,Float32}",
    "page": "frutsum.jl",
    "title": "App.Plane3D",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.GetPointDistance-Tuple{App.Plane3D,App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.GetPointDistance",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.Frustum",
    "page": "frutsum.jl",
    "title": "App.Frustum",
    "category": "type",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.getVertices-Tuple{App.Frustum}",
    "page": "frutsum.jl",
    "title": "App.getVertices",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.SetFrustum-Tuple{App.Frustum,Float32,Float32,Float32,Float32}",
    "page": "frutsum.jl",
    "title": "App.SetFrustum",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.SetCamera-Tuple{App.Frustum,App.Vector3{Float32},App.Vector3{Float32},App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.SetCamera",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.checkPoint-Tuple{App.Frustum,App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.checkPoint",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.checkSphere-Tuple{App.Frustum,App.Vector3{Float32},Number}",
    "page": "frutsum.jl",
    "title": "App.checkSphere",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#App.checkCube-Tuple{App.Frustum,App.Vector3{Float32},App.Vector3{Float32}}",
    "page": "frutsum.jl",
    "title": "App.checkCube",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/frustum.html#frutsum.jl-1",
    "page": "frutsum.jl",
    "title": "frutsum.jl",
    "category": "section",
    "text": "App.Plane3DApp.Plane3D(mNormal::App.Vec3f, mPoint::App.Vec3f)App.Plane3D(lv1::App.Vec3f, lv2::App.Vec3f, lv3::App.Vec3f)App.Plane3D(a::Float32, b::Float32, c::Float32, d::Float32)App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)FRUSTUM_TOP = 1\nFRUSTUM_BOTTOM = 2\nFRUSTUM_LEFT = 3\nFRUSTUM_RIGHT = 4\nFRUSTUM_NEAR = 5\nFRUSTUM_FAR = 6FRUSTUM_OUTSIDE = 0\nFRUSTUM_INTERSECT = 1\nFRUSTUM_INSIDE = 2App.FrustumApp.getVertices(this::App.Frustum)App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)App.checkPoint(this::App.Frustum, pos::App.Vec3f)App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)App.checkCube(this::App.Frustum, center::App.Vec3f, size::App.Vec3f)"
},

{
    "location": "files/lib_math.html#",
    "page": "lib_math.jl",
    "title": "lib_math.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_math.html#App.frustum-Union{NTuple{6,T}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.frustum",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.projection_perspective-Union{NTuple{4,T}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.projection_perspective",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.projection_orthographic-Union{NTuple{6,T}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.projection_orthographic",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.translation-Union{Tuple{Array{T,1}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.translation",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.rotation-Union{Tuple{Array{T,1}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.rotation",
    "category": "method",
    "text": "TODO\n\n\n\nTODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.rotation-Union{Tuple{Quaternions.Quaternion{T}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.rotation",
    "category": "method",
    "text": "TODO\n\n\n\nTODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.computeRotation-Union{Tuple{Array{T,1}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.computeRotation",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.scaling-Union{Tuple{Array{T,N} where N}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.scaling",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.transform-Union{Tuple{Array{T,1},Array{T,1},Array{T,1}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.transform",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.ViewRH-Union{Tuple{Array{T,1},T,T}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.ViewRH",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.lookat-Union{Tuple{Array{T,1},Array{T,1},Array{T,1}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.lookat",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.forward-Union{Tuple{Array{T,2}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.forward",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.right-Union{Tuple{Array{T,2}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.right",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#App.up-Union{Tuple{Array{T,2}}, Tuple{T}} where T",
    "page": "lib_math.jl",
    "title": "App.up",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_math.html#lib_math.jl-1",
    "page": "lib_math.jl",
    "title": "lib_math.jl",
    "category": "section",
    "text": "libs:Quaternions\nStaticArraysincludes:matrix.jl\nvector.jlApp.frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)App.projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)App.projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)App.translation{T}(t::Array{T,1})App.rotation{T}(r::Array{T,1})App.rotation{T}(q::Quaternions.Quaternion{T})App.computeRotation{T}(r::Array{T,1})App.scaling{T}(s::Array{T})App.transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})App.ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)App.lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})App.forward{T}(m::Array{T, 2})App.right{T}(m::Array{T, 2})App.up{T}(m::Array{T, 2})"
},

{
    "location": "files/lib_opengl.html#",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_opengl.html#App.getInfoLog-Tuple{UInt32}",
    "page": "lib_opengl.jl",
    "title": "App.getInfoLog",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#App.validateShader-Tuple{Any}",
    "page": "lib_opengl.jl",
    "title": "App.validateShader",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#App.compileShader-Tuple{Any,Any,Any}",
    "page": "lib_opengl.jl",
    "title": "App.compileShader",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#App.createShader-Tuple{Tuple{Symbol,String},Any}",
    "page": "lib_opengl.jl",
    "title": "App.createShader",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#App.createShaderProgram",
    "page": "lib_opengl.jl",
    "title": "App.createShaderProgram",
    "category": "function",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#App.createcontextinfo-Tuple{}",
    "page": "lib_opengl.jl",
    "title": "App.createcontextinfo",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_opengl.html#lib_opengl.jl-1",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "section",
    "text": "using ModernGLglGenOne(glGenFn)glGenBuffer() glGenVertexArray() glGenTexture()glGetIntegerv_e()get_glsl_version_string()glErrorMessage()glCheckError()App.getInfoLog(obj::ModernGL.GLuint)App.validateShader(shader)App.compileShader(name, shader,source)App.createShader(source::Tuple{Symbol,String}, typ)App.createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)App.createcontextinfo()"
},

{
    "location": "files/lib_time.html#",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_time.html#App.UpdateTimers-Tuple{}",
    "page": "lib_time.jl",
    "title": "App.UpdateTimers",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_time.html#App.OnTime-Tuple{Number}",
    "page": "lib_time.jl",
    "title": "App.OnTime",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_time.html#App.OnTime-Tuple{Number,Ref{Float64},Any}",
    "page": "lib_time.jl",
    "title": "App.OnTime",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/lib_time.html#lib_time.jl-1",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "section",
    "text": "GetTimer(key)SetTimer(key, time::Number) SetTimer(\"FRAME_TIMER\", Dates.time())App.UpdateTimers()App.OnTime(milisec::Number)App.OnTime(milisec::Number, prevTime::Ref{Float64}, time)"
},

{
    "location": "files/lib_window.html#",
    "page": "lib_window.jl",
    "title": "lib_window.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_window.html#lib_window.jl-1",
    "page": "lib_window.jl",
    "title": "lib_window.jl",
    "category": "section",
    "text": "using GLFWglfwDll glfwLibs glfwIncludes"
},

{
    "location": "files/libs.html#",
    "page": "libs.jl",
    "title": "libs.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/libs.html#App.waitForFileReady",
    "page": "libs.jl",
    "title": "App.waitForFileReady",
    "category": "function",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/libs.html#App.fileGetContents",
    "page": "libs.jl",
    "title": "App.fileGetContents",
    "category": "function",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/libs.html#App.UpdateCounters-Tuple{}",
    "page": "libs.jl",
    "title": "App.UpdateCounters",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/libs.html#App.showFrames-Tuple{}",
    "page": "libs.jl",
    "title": "App.showFrames",
    "category": "method",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/libs.html#libs.jl-1",
    "page": "libs.jl",
    "title": "libs.jl",
    "category": "section",
    "text": "using Compat: uninitialized, Nothing, Cvoid, AbstractDict using Images using ImageMagickdisplayInYellow(s) = string(\"\\x1b[93m\",s,\"\\x1b[0m\") displayInRed(s) = string(\"\\x1b[91m\",s,\"\\x1b[0m\")include(\"lib_window.jl\") include(\"lib_opengl.jl\") include(\"lib_math.jl\") include(\"lib_time.jl\")include(\"cubeData.jl\") include(\"camera.jl\") include(\"frustum.jl\") include(\"chunk.jl\") include(\"mesh.jl\") include(\"texture.jl\")App.waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)App.fileGetContents(path::String, tryCount=100, tryWait=0.1)App.UpdateCounters()App.showFrames()"
},

{
    "location": "files/matrix.html#",
    "page": "matrix.jl",
    "title": "matrix.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/matrix.html#matrix.jl-1",
    "page": "matrix.jl",
    "title": "matrix.jl",
    "category": "section",
    "text": ""
},

{
    "location": "files/shader.html#",
    "page": "shader.jl",
    "title": "shader.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/shader.html#App.loadShaders-Tuple{}",
    "page": "shader.jl",
    "title": "App.loadShaders",
    "category": "method",
    "text": "load all content from shaders located in shaders folder in root dir\n\n\n\n"
},

{
    "location": "files/shader.html#shader.jl-1",
    "page": "shader.jl",
    "title": "shader.jl",
    "category": "section",
    "text": "App.loadShaders()"
},

{
    "location": "files/test.html#",
    "page": "test.jl",
    "title": "test.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/test.html#test.jl-1",
    "page": "test.jl",
    "title": "test.jl",
    "category": "section",
    "text": "include(\"JuliaOpenGL.jl\") main()"
},

{
    "location": "files/texture.html#",
    "page": "texture.jl",
    "title": "texture.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/texture.html#App.uploadTexture-Tuple{Any}",
    "page": "texture.jl",
    "title": "App.uploadTexture",
    "category": "method",
    "text": "uploads a texture by given file path\n\n\n\n"
},

{
    "location": "files/texture.html#texture.jl-1",
    "page": "texture.jl",
    "title": "texture.jl",
    "category": "section",
    "text": "App.uploadTexture(path)"
},

{
    "location": "files/vector.html#",
    "page": "vector.jl",
    "title": "vector.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/vector.html#vector.jl-1",
    "page": "vector.jl",
    "title": "vector.jl",
    "category": "section",
    "text": ""
},

]}
