var documenterSearchIndex = {"docs": [

{
    "location": "files/JuliaOpenGL/#",
    "page": "JuliaOpenGL.jl",
    "title": "JuliaOpenGL.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/JuliaOpenGL/#JuliaOpenGL.jl-1",
    "page": "JuliaOpenGL.jl",
    "title": "JuliaOpenGL.jl",
    "category": "section",
    "text": "Definitions\nProgram Init\nSzene Init\nCamera\nMesh\nTextures\nShader\nOther\nRender LoopApp"
},

{
    "location": "files/JuliaOpenGL/#Main-Call-1",
    "page": "JuliaOpenGL.jl",
    "title": "Main Call",
    "category": "section",
    "text": "function main()\n  App.run()\nend"
},

{
    "location": "files/JuliaOpenGL/#Program-Run-1",
    "page": "JuliaOpenGL.jl",
    "title": "Program Run",
    "category": "section",
    "text": "App.run()"
},

{
    "location": "files/JuliaOpenGL/#Definitions-1",
    "page": "JuliaOpenGL.jl",
    "title": "Definitions",
    "category": "section",
    "text": "App.setMode(program, name, mode)App.setFrustumCulling(load)App.chooseRenderMethod(method)App.checkForUpdate()App.useProgram(program)App.setMatrix(program, name, m)App.setMVP(program, mvp, old_program)"
},

{
    "location": "files/JuliaOpenGL/#Program-Init-1",
    "page": "JuliaOpenGL.jl",
    "title": "Program Init",
    "category": "section",
    "text": "Output Program Info (Print)\nOS X-specific GLFW hints to initialize the correct version of OpenGL\nCreate a windowed mode window and its OpenGL context\nMake the window\'s context current\nSet windows size and viewport - seems to be necessary to guarantee that window > 0\nWindow settings - SwapInterval - intervall between canvas images (min. 2 images)\nGraphcis Settings - show opengl debug report\nSet OpenGL Version (Major,Minor) - 4.6\nSet OpenGL Event Callbacks\nShow window\nOutput OpenGL Info (Print)"
},

{
    "location": "files/JuliaOpenGL/#szene-init-1",
    "page": "JuliaOpenGL.jl",
    "title": "Szene Init",
    "category": "section",
    "text": "Chooses render methodApp.chooseRenderMethod"
},

{
    "location": "files/JuliaOpenGL/#Camera-1",
    "page": "JuliaOpenGL.jl",
    "title": "Camera",
    "category": "section",
    "text": "Sets Camera position\nSets Camera projection\nCreates/Sets Frustum\nUpdates Camera"
},

{
    "location": "files/JuliaOpenGL/#Mesh-1",
    "page": "JuliaOpenGL.jl",
    "title": "Mesh",
    "category": "section",
    "text": "Creates and Links Mesh Data"
},

{
    "location": "files/JuliaOpenGL/#Textures-1",
    "page": "JuliaOpenGL.jl",
    "title": "Textures",
    "category": "section",
    "text": "uploads this texture."
},

{
    "location": "files/JuliaOpenGL/#Shader-1",
    "page": "JuliaOpenGL.jl",
    "title": "Shader",
    "category": "section",
    "text": "Creates Shader\nSets Shader Attributes\nSets Uniform Variables (like MVP from Camera)"
},

{
    "location": "files/JuliaOpenGL/#Other-1",
    "page": "JuliaOpenGL.jl",
    "title": "Other",
    "category": "section",
    "text": "Sets OpenGL Render Options"
},

{
    "location": "files/JuliaOpenGL/#render-loop-1",
    "page": "JuliaOpenGL.jl",
    "title": "Render Loop",
    "category": "section",
    "text": "Begin Render Loop while (window is open)\nEvent OnUpdate -> setMVP\nShow frames\nupdate counters/timers\nClear szene background\nBind Shader Program\nWirefram Option\nBind Vertex Array\nDraw:if isValid(mychunk) \n  (...)\n  if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS)  # + geometry shader => very fast!\n  elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES)  # fast\n  elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES)  # faster than 2 (only useful for groups)\n  elseif RENDER_METHOD > 3\n    for b in getFilteredChilds(mychunk)  # thats slow!\n      glDrawElements(GL_TRIANGLES)\n    end\n  end\n  (...)For more information about render algorithms look here.Unbind Vertex Array\nSwap front and back buffers\nPoll for and process events\nSleep function\nEnd Render Loop\ndestroy Window \nterminate"
},

{
    "location": "files/build/#",
    "page": "build.jl",
    "title": "build.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/build/#build.jl-1",
    "page": "build.jl",
    "title": "build.jl",
    "category": "section",
    "text": "This File searches for BuildExecutable.jl in current path and parent dirs. BuildExecutable.jl is required to build Executables on windows machines. It runs the script automatically and creates a executable in bin folder in root directory."
},

{
    "location": "files/camera/#",
    "page": "camera.jl",
    "title": "camera.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/camera/#camera.jl-1",
    "page": "camera.jl",
    "title": "camera.jl",
    "category": "section",
    "text": "Camera script with defines camera object, its functions, events and creates a single camera object for whole szene.App.rezizeWindow(width,height)App.CameraApp.forward(camera::App.Camera)App.right(camera::App.Camera)App.up(camera::App.Camera)App.setProjection(camera::App.Camera, m::AbstractArray)App.setView(camera::App.Camera, m::AbstractArray)App.OnKey(window, key::Number, scancode::Number, action::Number, mods::Number)App.OnMouseKey(window, key::Number, action::Number, mods::Number)App.OnCursorPos(window, x::Number, y::Number)App.rotate(camera::App.Camera, rotation::AbstractArray)App.move(camera::App.Camera, position::AbstractArray)App.OnRotate(camera::App.Camera)App.setPosition(camera::App.Camera, position::AbstractArray)App.OnMove(camera::App.Camera, key::Symbol, m::Number)App.Update(camera::App.Camera)App.OnUpdate(camera::App.Camera)"
},

{
    "location": "files/chunk/#",
    "page": "chunk.jl",
    "title": "chunk.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/chunk/#chunk.jl-1",
    "page": "chunk.jl",
    "title": "chunk.jl",
    "category": "section",
    "text": "App.HeptaOrder{T}\nApp.Block(pos=App.Vec3f,typ=0)App.Chunk(len::Integer)App.clean(this::Union{Void,App.Chunk})App.isType(this::App.Block, typ)App.isValid(this::App.Chunk) App.isSeen(this::App.Block)App.resetSides()App.resetSides(this::App.Block)App.hideUnseen(this::App.Chunk)App.setFlag(this::App.Block, flag::Unsigned, add::Bool)App.isActive(this::App.Block)App.isVisible(this::App.Block)App.isSurrounded(this::App.Block)App.isValid(this::App.Block)App.setActive(this::App.Block, active::Bool)App.setVisible(this::App.Block, visible::Bool)App.setSurrounded(this::App.Block, surrounded::Bool)App.hideType(this::App.Chunk, typ::Integer)App.removeType(this::App.Chunk, typ::Integer)App.showAll(this::App.Chunk)App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)App.setFilteredChilds(this::App.Chunk, r::Array{App.Block,1})App.getFilteredChilds(this::App.Chunk)App.getActiveChilds(this::App.Chunk)App.getVisibleChilds(this::App.Chunk)App.getValidChilds(this::App.Chunk)App.getData(this::App.Block)App.getData(this::App.Chunk)App.update(this::App.Chunk)App.createSingle(this::App.Chunk)App.createExample(this::App.Chunk)App.createLandscape(this::App.Chunk)"
},

{
    "location": "files/compileAndLink/#",
    "page": "compileAndLink.jl",
    "title": "compileAndLink.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/compileAndLink/#compileAndLink.jl-1",
    "page": "compileAndLink.jl",
    "title": "compileAndLink.jl",
    "category": "section",
    "text": "COMPILE WITH GCC\nLINK LIB FUNCTIONSApp.find_system_gcc()App.gcc_compile(gcc,file,libname,env)App.write_c_file(libname)App.compiler_setPaths(gcc,env_path)App.createLoop(index, array, func)App.loopByIndex(index)App.loopByObject(pointer)App.prepareStaticLoop(x,a)App.staticloop()"
},

{
    "location": "files/cubeData/#",
    "page": "cubeData.jl",
    "title": "cubeData.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/cubeData/#cubeData.jl-1",
    "page": "cubeData.jl",
    "title": "cubeData.jl",
    "category": "section",
    "text": "DATA_DUMMY\nDATA_CUBE\nDATA_CUBE_VERTEX\nDATA_CUBE_INDEX \nDATA_PLANE_VERTEX\nDATA_PLANE_INDEX "
},

{
    "location": "files/frustum/#",
    "page": "frutsum.jl",
    "title": "frutsum.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/frustum/#frutsum.jl-1",
    "page": "frutsum.jl",
    "title": "frutsum.jl",
    "category": "section",
    "text": "App.Plane3DApp.Plane3D(mNormal::App.Vec3f, mPoint::App.Vec3f)App.Plane3D(lv1::App.Vec3f, lv2::App.Vec3f, lv3::App.Vec3f)App.Plane3D(a::Float32, b::Float32, c::Float32, d::Float32)App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)FRUSTUM_TOP = 1\nFRUSTUM_BOTTOM = 2\nFRUSTUM_LEFT = 3\nFRUSTUM_RIGHT = 4\nFRUSTUM_NEAR = 5\nFRUSTUM_FAR = 6\nFRUSTUM_OUTSIDE = 0\nFRUSTUM_INTERSECT = 1\nFRUSTUM_INSIDE = 2App.FrustumApp.getVertices(this::App.Frustum)App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)App.checkPoint(this::App.Frustum, pos::App.Vec3f)App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)App.checkCube(this::App.Frustum, center::App.Vec3f, size::App.Vec3f)"
},

{
    "location": "files/lib_math/#",
    "page": "lib_math.jl",
    "title": "lib_math.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_math/#lib_math.jl-1",
    "page": "lib_math.jl",
    "title": "lib_math.jl",
    "category": "section",
    "text": "libs:Quaternions\nStaticArraysincludes:matrix.jl\nvector.jlApp.frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)App.projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)App.projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)App.translation{T}(t::Array{T,1})App.rotation{T}(r::Array{T,1})App.rotation{T}(q::Quaternions.Quaternion{T})App.computeRotation{T}(r::Array{T,1})App.scaling{T}(s::Array{T})App.transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})App.ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)App.lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})App.forward{T}(m::Array{T, 2})App.right{T}(m::Array{T, 2})App.up{T}(m::Array{T, 2})"
},

{
    "location": "files/lib_opengl/#",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_opengl/#lib_opengl.jl-1",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "section",
    "text": "using ModernGLglGenOne(glGenFn)glGenBuffer() glGenVertexArray() glGenTexture()glGetIntegerv_e()get_glsl_version_string()glErrorMessage()glCheckError()App.getInfoLog(obj::ModernGL.GLuint)App.validateShader(shader)App.compileShader(name, shader,source)App.createShader(source::Tuple{Symbol,String}, typ)App.createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)App.createcontextinfo()"
},

{
    "location": "files/lib_time/#",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_time/#lib_time.jl-1",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "section",
    "text": "GetTimer(key)SetTimer(key, time::Number) SetTimer(\"FRAME_TIMER\", Dates.time())App.UpdateTimers()App.OnTime(milisec::Number)App.OnTime(milisec::Number, prevTime::Ref{Float64}, time)"
},

{
    "location": "files/lib_window/#",
    "page": "lib_window.jl",
    "title": "lib_window.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_window/#lib_window.jl-1",
    "page": "lib_window.jl",
    "title": "lib_window.jl",
    "category": "section",
    "text": "using GLFWglfwDll glfwLibs glfwIncludes"
},

{
    "location": "files/libs/#",
    "page": "libs.jl",
    "title": "libs.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/libs/#libs.jl-1",
    "page": "libs.jl",
    "title": "libs.jl",
    "category": "section",
    "text": "using Compat: uninitialized, Nothing, Cvoid, AbstractDict using Images using ImageMagickdisplayInYellow(s) = string(\"\\x1b[93m\",s,\"\\x1b[0m\") displayInRed(s) = string(\"\\x1b[91m\",s,\"\\x1b[0m\")include(\"lib_window.jl\") include(\"lib_opengl.jl\") include(\"lib_math.jl\") include(\"lib_time.jl\")include(\"cubeData.jl\") include(\"camera.jl\") include(\"frustum.jl\") include(\"chunk.jl\") include(\"mesh.jl\") include(\"texture.jl\")App.waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)App.fileGetContents(path::String, tryCount=100, tryWait=0.1)App.UpdateCounters()App.showFrames()"
},

{
    "location": "files/matrix/#",
    "page": "matrix.jl",
    "title": "matrix.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/matrix/#matrix.jl-1",
    "page": "matrix.jl",
    "title": "matrix.jl",
    "category": "section",
    "text": ""
},

{
    "location": "files/mesh/#",
    "page": "mesh.jl",
    "title": "mesh.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/mesh/#mesh.jl-1",
    "page": "mesh.jl",
    "title": "mesh.jl",
    "category": "section",
    "text": "App.TransformApp.MeshArrayApp.MeshDataApp.setAttributes(this::App.MeshArray, program, attrb)App.createBuffers(this::App.MeshData)App.setAttributes(this::App.MeshData, program)App.setDrawArray(this::App.MeshData, key::Symbol)App.setData(this::App.MeshArray, data, elems=0)App.linkData(this::App.MeshData, args...)App.upload(this::App.MeshArray)App.upload(this::App.MeshData)App.upload(this::App.MeshData, key::Symbol, data::AbstractArray)"
},

{
    "location": "files/shader/#",
    "page": "shader.jl",
    "title": "shader.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/shader/#shader.jl-1",
    "page": "shader.jl",
    "title": "shader.jl",
    "category": "section",
    "text": "App.loadShaders()"
},

{
    "location": "files/test/#",
    "page": "test.jl",
    "title": "test.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/test/#test.jl-1",
    "page": "test.jl",
    "title": "test.jl",
    "category": "section",
    "text": "include(\"JuliaOpenGL.jl\") main()"
},

{
    "location": "files/texture/#",
    "page": "texture.jl",
    "title": "texture.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/texture/#texture.jl-1",
    "page": "texture.jl",
    "title": "texture.jl",
    "category": "section",
    "text": "App.uploadTexture(path)"
},

{
    "location": "files/vector/#",
    "page": "vector.jl",
    "title": "vector.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/vector/#vector.jl-1",
    "page": "vector.jl",
    "title": "vector.jl",
    "category": "section",
    "text": ""
},

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
    "text": "Example 3D OpenGL Szene with up to 128³ Blocks. Uses Instances, Geometry Shader, Frustum Culling and Outside Only (Surrounded Blocks will be hidden) algorithm to render many Blocks efficiency."
},

{
    "location": "#Start-1",
    "page": "JuliaOpenGL",
    "title": "Start",
    "category": "section",
    "text": "Manual\nDeveloper Documentation"
},

{
    "location": "#Manual-1",
    "page": "JuliaOpenGL",
    "title": "Manual",
    "category": "section",
    "text": "Start\nInstall\nSzene"
},

{
    "location": "#Developer-Documentation-1",
    "page": "JuliaOpenGL",
    "title": "Developer Documentation",
    "category": "section",
    "text": "Algorithm\nBuild\nOptimization\nReferences"
},

{
    "location": "manual/algorithm/#",
    "page": "Algorithm",
    "title": "Algorithm",
    "category": "page",
    "text": ""
},

{
    "location": "manual/algorithm/#algorithm-1",
    "page": "Algorithm",
    "title": "Algorithm",
    "category": "section",
    "text": "For this project i use an advanced OpenGL technique and two algorithm to render up to 128³ blocks with 100 or more FPS.OpenGL\nFrustum Culling\nOutside Only\nAll together\nNext step\nWhy not use?"
},

{
    "location": "manual/algorithm/#OpenGL-1",
    "page": "Algorithm",
    "title": "OpenGL",
    "category": "section",
    "text": "glDrawElementsInstanced and glDrawArraysInstanced to render many objects at once\nGPU Geometry shader to adjust amount of vertices given by input. No need to create vertices on CPU side. Geometry shader example:void createSide(Vertex v, int side) {\n  for(int i=0;i<4;++i) {\n    (...)\n    gl_Position = iMVP * v.world_pos;\n    EmitVertex();\n  }\n  EndPrimitive();\n}\n\nvoid main() {\n  (...)\n  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT\n  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT\n  if((sides & 0x4) > 0) createSide(v, 0);  // TOP\n  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM\n  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT\n  if((sides & 0x20) > 0) createSide(v, 3);  // BACK\n  (...)\n}"
},

{
    "location": "manual/algorithm/#Frustum-Culling-1",
    "page": "Algorithm",
    "title": "Frustum Culling",
    "category": "section",
    "text": "Frustum culling is 3d geometric object (a cone with top and bottom sliced off). In code frustum has six planes (top,bottom,right,left,near,far) in total where each plane measure the distance between itself and a given object. For visual demonstration look Frustum Culling Video by AlwaysGeeky.Code:type Plane\n position  :: Vector\n normal    :: Vector\n distance  :: Value\nendtype Frustum\n  planes :: Array\n  \n  nearDistance  :: Value\n  farDistance   :: Value\n  nearWidth     :: Value\n  nearHeight    :: Value\n  farWidth      :: Value\n  farHeight     :: Value\n  ratio         :: Value\n  angle         :: Value\n  tang          :: Value\n  \n  nearTopLeft     :: Vector\n  nearTopRight    :: Vector\n  nearBottomLeft  :: Vector\n  nearBottomRight :: Vector\n  farTopLeft      :: Vector\n  farTopRight     :: Vector\n  farBottomLeft   :: Vector\n  farBottomRight  :: Vector\nendSet Camera is called in main script and sets the view for the frustum App.SetCamera(this::App.Frustum, pos::App.Vec3f, target::App.Vec3f, up::App.Vec3f)Set Frustum is almost similiar to set camera execpt its sets ratio, angle, far and near values App.SetFrustum(this::App.Frustum, angle::Float32, ratio::Float32, nearD::Float32, farD::Float32)GetPointDistance gets the distance between current plane and a point App.GetPointDistance(this::App.Plane3D, lPoint::App.Vec3f)checkSphere is a batter option than checkCube because its faster App.checkSphere(this::App.Frustum, pos::App.Vec3f, radius::Number)checkInFrustum is called in when blocks are created / updated App.checkInFrustum(this::App.Chunk, fstm::App.Frustum)"
},

{
    "location": "manual/algorithm/#Outside-Only-1",
    "page": "Algorithm",
    "title": "Outside Only",
    "category": "section",
    "text": "Is a simple algorithm to filter objects which are surrounded by other objects and are not visible from the outside. It hides not only the objects itself but its non-visible sides too. Those objects are cubes so we have only six sides to check for visibility.This algorithm has some similiarities to Occlusion culling but its different. Occlusion culling is when objects are entirely behind other opaque objects may be culled. This differs from Outside Only algorithm because each object looks around itself if it has visible neighbour objects or not. If its entirely surrounded by other object then it wont be \"culled\".The algorithm App.hideUnseen(this::App.Chunk)"
},

{
    "location": "manual/algorithm/#All-together-1",
    "page": "Algorithm",
    "title": "All together",
    "category": "section",
    "text": "Combining OpenGL technique and those two algorithm gives high quality results.This gets us a filtered list of objects where those algorithms were applied to App.getFilteredChilds(this::App.Chunk)"
},

{
    "location": "manual/algorithm/#Next-step-1",
    "page": "Algorithm",
    "title": "Next step",
    "category": "section",
    "text": "Next step is to filter objects which are not seen due to interference of other objects (blocking the view). An approach could be using a raytracer but maybe there is an even better solution to that or it has yet to been found. Since we only have cubes we can avoid complicated stuff most of the time."
},

{
    "location": "manual/algorithm/#Why-not-use?-1",
    "page": "Algorithm",
    "title": "Why not use?",
    "category": "section",
    "text": "Why not use glDrawElementsInstanced + geometry shader instead of glDrawArraysInstanced + geometry shader? glDrawElementsInstanced is only useful for groups but we use points here for each object (cube), so we will have to think how we want to group our objects first. Currently glDrawArraysInstanced is the way to go."
},

{
    "location": "manual/optimization/#",
    "page": "Optimization",
    "title": "Optimization",
    "category": "page",
    "text": ""
},

{
    "location": "manual/optimization/#optimization-1",
    "page": "Optimization",
    "title": "Optimization",
    "category": "section",
    "text": "Optimization can be done know how to write your code following the rules of julia page ()[].Another option to optimize is to use write c-code, use gcc compiler to compile a lib (dll) file and link to its c-functions in julia.If you wanna use on Windows Visual Studio\'s famous C++ Compiler you can do this aswell, just keep in mind to export your c++ functions to c."
},

{
    "location": "manual/optimization/#JuliaOptimizer-1",
    "page": "Optimization",
    "title": "JuliaOptimizer",
    "category": "section",
    "text": "Is one approach to use the C++ of Visual Studio (Windows)Files main.h and main.cpp contains examples where you can pass data from julia to C++ or C++ to julia.Example export to c:#define EXPORT __declspec(dllexport)\n\nextern \"C\" {\n  EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);\n  EXPORT void loopByIndex(const unsigned int);\n  EXPORT void loopByObject(void*);\n  EXPORT void prepare(LoopFunc f, void** a, unsigned int count);\n  EXPORT void loop();\n};"
},

{
    "location": "manual/references/#",
    "page": "References",
    "title": "References",
    "category": "page",
    "text": ""
},

{
    "location": "manual/references/#references-1",
    "page": "References",
    "title": "References",
    "category": "section",
    "text": ""
},

{
    "location": "manual/references/#Julia-vs-Python-1",
    "page": "References",
    "title": "Julia vs Python",
    "category": "section",
    "text": "I found articles about this topic. First one was against julia but it had somewhat poor evidence for julia downsides. The last two articles i found favour julia over python for various situations by demonstrating benchmarks or code examples in comparison with python.Against Julia - \'Giving up on Julia\' and \'Python Benchmarks\'\nFavour Julia - \'An Updated Analysis for the \"Giving Up on Julia\" Blog Post\'\nFavour Julia - \'Python vs Julia Observations\'"
},

{
    "location": "manual/references/#Honorable-mentions-1",
    "page": "References",
    "title": "Honorable mentions",
    "category": "section",
    "text": "Since knowlegde does not grow on trees. I decide to put my sources here as honorable mentions because those websites helped me allot:Let\'s Make a Voxel Engine\nMineCraft-One-Week-Challenge\nVox"
},

{
    "location": "manual/references/#Helpful-Sites-1",
    "page": "References",
    "title": "Helpful Sites",
    "category": "section",
    "text": "Setting up Your Julia Environment\nJulia By Example\nTest Driven Development in Julia\nMaking/compiling C functions for use in Julia on Windows\nDocumenter.jl"
},

{
    "location": "manual/start/#",
    "page": "Start",
    "title": "Start",
    "category": "page",
    "text": ""
},

{
    "location": "manual/start/#start-1",
    "page": "Start",
    "title": "Start",
    "category": "section",
    "text": "Download\nInstallation\nInfo\nBuild\nSzene"
},

{
    "location": "manual/start/#download-1",
    "page": "Start",
    "title": "Download",
    "category": "section",
    "text": "Julia 0.6\nJulia OpenGL"
},

{
    "location": "manual/start/#install-1",
    "page": "Start",
    "title": "Installation",
    "category": "section",
    "text": "Run Julia 0.6 setup\nInstall Packages:Pkg.add(\"Compat\")\nPkg.add(\"Images\")\nPkg.add(\"ImageMagick\")\nPkg.add(\"ModernGL\")\nPkg.add(\"GLFW\")\nPkg.add(\"Quaternions\")"
},

{
    "location": "manual/start/#Info-1",
    "page": "Start",
    "title": "Info",
    "category": "section",
    "text": "Tested on:Operating System: Windows 10 Home 64-bit\nProcessor: Intel(R) Core(TM) i7-4510U CPU @ 2.00GHz (4 CPUs), 2.0GHz\nMemory: 8192MB RAM\nGraphics Card 1: Intel(R) HD Graphics Family\nGraphics Card 2: NVIDIA GeForce 840M (Was mostly used for better FPS values)"
},

{
    "location": "manual/start/#build-1",
    "page": "Start",
    "title": "Build",
    "category": "section",
    "text": "With BuildExecutable.jl script you can build a executable on your os systems (currently only for windows). For more information look build.jl."
},

{
    "location": "manual/start/#szene-1",
    "page": "Start",
    "title": "Szene",
    "category": "section",
    "text": "For information about szene initialization look here.\nFor information about render loop look here.\nFor information about render algorithms look here.Rendermethods: Arrays Instanced + Points\nArrays Instanced + Triangles\nElements Instanced + Triangles\nElements + TrianglesKey Command/Description\nk Show Keys\nq Wireframe (Enable/Disable)\nt Texture (Enable/Disable)\nl Light (Enable/Disable)\nf Frustum Culling (Enable/Disable)\no Outside Only Cubes (Enable/Disable)\nr Reload\nF1-F4 Rendermethod 1 - 4\n0-9 Chunk Size 1-64 ^ 3 (0 = 64)\nß´^ Chunk Size > 64 (72, 96, 128)\nb Szene: Single Block\nn Szene: Blocks (Full Chunk)\nm Szene: Terrain\nv Set Camera Vew (Frustum)\np Set Camera Position (Frustum)\nWASD Move Camera (Forward,Left,Back,Right,Up,Down)\nSpace Move Camera (Up)\nCtrl/c Move Camera (Down)\nLShift Hold left shift to speedUp Camera Movement\nHMK Hold any mouse key to rotate view(Image: statusPic)"
},

]}
