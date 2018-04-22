var documenterSearchIndex = {"docs": [

{
    "location": "files/JuliaOpenGL/#",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "JuliaOpenGL.jl (main.jl)",
    "category": "page",
    "text": ""
},

{
    "location": "files/JuliaOpenGL/#JuliaOpenGL.jl-(main.jl)-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "JuliaOpenGL.jl (main.jl)",
    "category": "section",
    "text": "App"
},

{
    "location": "files/JuliaOpenGL/#INCLUDES-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "INCLUDES",
    "category": "section",
    "text": "include(\"libs.jl\") include(\"shader.jl\")"
},

{
    "location": "files/JuliaOpenGL/#COMPILE-C-File-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "COMPILE C File",
    "category": "section",
    "text": "#include(\"compileAndLink.jl\") const compileAndLink = isdefined(:createLoop) setMode(program, name, mode)setFrustumCulling(load=true)chooseRenderMethod(method=RENDER_METHOD)checkForUpdate()useProgram(program)setMatrix(program, name, m)setMVP(program, mvp, old_program=nothing)"
},

{
    "location": "files/JuliaOpenGL/#PROGRAM-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "PROGRAM",
    "category": "section",
    "text": "run()println(\"––––––––––––––––––––––––––––––––––-\") println(\"Start Program @ \", Dates.time()) versioninfo()"
},

{
    "location": "files/JuliaOpenGL/#OS-X-specific-GLFW-hints-to-initialize-the-correct-version-of-OpenGL-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "OS X-specific GLFW hints to initialize the correct version of OpenGL",
    "category": "section",
    "text": "GLFW.Init()"
},

{
    "location": "files/JuliaOpenGL/#Create-a-windowed-mode-window-and-its-OpenGL-context-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Create a windowed mode window and its OpenGL context",
    "category": "section",
    "text": "global window = GLFW.CreateWindow(WIDTH, HEIGHT, \"OpenGL Example\")"
},

{
    "location": "files/JuliaOpenGL/#Make-the-window\'s-context-current-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Make the window\'s context current",
    "category": "section",
    "text": "GLFW.MakeContextCurrent(window)GLFW.SetWindowSize(window, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0 rezizeWindow(WIDTH,HEIGHT)"
},

{
    "location": "files/JuliaOpenGL/#Window-settings-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Window settings",
    "category": "section",
    "text": "GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)"
},

{
    "location": "files/JuliaOpenGL/#Graphcis-Settings-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Graphcis Settings",
    "category": "section",
    "text": "GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug #GLFW.WindowHint(GLFW.SAMPLES,4)"
},

{
    "location": "files/JuliaOpenGL/#OpenGL-Version-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "OpenGL Version",
    "category": "section",
    "text": "GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4) GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)GLFW.SetCursorPosCallback(window, OnCursorPos) GLFW.SetKeyCallback(window, OnKey) GLFW.SetMouseButtonCallback(window, OnMouseKey)#setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)GLFW.ShowWindow(window)glinfo = createcontextinfo()println(\"OpenGL displayInRed(glinfo[:gl_version])\") println(\"GLSL glinfo[:glsl_version]\") println(\"Vendor displayInRed(glinfo[:gl_vendor])\") println(\"Renderer displayInRed(glinfo[:gl_renderer])\") println(\"––––––––––––––––––––––––––––––––––-\")"
},

{
    "location": "files/JuliaOpenGL/#CAMERA-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "CAMERA",
    "category": "section",
    "text": "setPosition(CAMERA,[0f0,0,0]) setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))global fstm = Frustum() SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 1000f0) SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))Update(CAMERA)#––––––––––––––––––––––––––––––––––––––––––program = 0#––––––––––––––––––––––––––––––––––––––––––global chunkData = MeshData() global planeData = MeshData()#––––––––––––––––––––––––––––––––––––––––––"
},

{
    "location": "files/JuliaOpenGL/#TEXTURES-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "TEXTURES",
    "category": "section",
    "text": "uploadTexture(\"blocks.png\")"
},

{
    "location": "files/JuliaOpenGL/#LOAD-DEFAULT-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "LOAD DEFAULT",
    "category": "section",
    "text": "chooseRenderMethod()#––––––––––––––––––––––––––––––––––––––––––linkData(planeData,  :vertices=>getVertices(fstm))#chunkData.arrays[:vertices].count #n = length(cubeVertices_small) / 3#function compileShaderPrograms()"
},

{
    "location": "files/JuliaOpenGL/#global-program_chunks,-program_normal-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "global program_chunks, program_normal",
    "category": "section",
    "text": "global program_normal = createShaderProgram(VSH, FSH) #, createShader(GSH, GL_GEOMETRY_SHADER)setAttributes(planeData, program_normal) setMVP(program_normal, CAMERA.MVP)#end#compileShaderPrograms()global location_position = -1 global location_texindex = -1#––––––––––––––––––––––––––––––––––––––––––function updateBlocks()   #const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)   #setMVP(CAMERA.MVP)   #glUniform3fv(location_shift, 1, CAMERA.position)   #glUniform3fv(location_shift, 1, shiftposition)   #for b in blocks; b.mvp=mmvp*b.model; end end#––––––––––––––––––––––––––––––––––––––––––glEnable(GL_DEPTH_TEST) glEnable(GL_BLEND) glEnable(GL_CULL_FACE) #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) #glBlendEquation(GL_FUNC_ADD) #glFrontFace(GL_CCW) glCullFace(GL_BACK) #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE glClearColor(0.0, 0.0, 0.0, 1.0)"
},

{
    "location": "files/JuliaOpenGL/#Loop-until-the-user-closes-the-window-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Loop until the user closes the window",
    "category": "section",
    "text": "render = function(x)   #mvp = mmvpMMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))   #setMVP(CAMERA.MVPtranslation([c.x,c.y,c.z]))#glUniformMatrix4fv(location_mvp, 1, false, x.mvp)   #glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )   #glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)   nothing end#= if use_geometry_shader   const loopBlocks() = render(mychunk.childs[1]) else   if compileAndLink     objptr = createLoop(1,refblocks,render) #compileAndLink     const loopBlocks() = loopByObject(objptr) #compileAndLink   else     const loopBlocks() = for b in mychunk.childs; render(b); end   end end =#cam_updated=falseconst SLEEP=0 #1f0/200i=0 while !GLFW.WindowShouldClose(window)   showFrames()   UpdateCounters()if OnUpdate(CAMERA)     setMVP(program_chunks, CAMERA.MVP)     #setMVP(program_normal, CAMERA.MVP)     cam_updated=true   endcheckForUpdate()   if cam_updated cam_updated=false end"
},

{
    "location": "files/JuliaOpenGL/#Pulse-the-background-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Pulse the background",
    "category": "section",
    "text": "#c=0.5 * (1 + sin(i * 0.01)); i+=1   #glClearColor(c, c, c, 1.0)   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)#print(\"loopBlocks \"); @time   #loopBlocks()if isValid(mychunk)      useProgram(program_chunks)     #glCheckError(\"useProgram\")     glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)     glBindVertexArray(chunkData.vao)     #glCheckError(\"glBindVertexArray bind\")if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS, 0, 1, mychunk.fileredCount) #GL_TRIANGLE_STRIP\nelseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, chunkData.draw.count, mychunk.fileredCount)\nelseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, mychunk.fileredCount)\n#glDrawElementsInstancedBaseVertex(GL_TRIANGLES, chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)\nelseif RENDER_METHOD > 3\n  #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)\n  for b in getFilteredChilds(mychunk)\n    if location_texindex > -1 glUniform1f(location_texindex, b.typ) end\n    if location_position > -1 glUniform3fv(location_position, 1, b.pos) end\n    glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )\n    #glCheckError(\"glDrawElements\")\n  end\nend\nglBindVertexArray(0)\n#glCheckError(\"glBindVertexArray unbind\")end#=   useProgram(program_normal)   glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)glBindVertexArray(planeData.vao)   #glDrawElements(GL_TRIANGLES, planeData.draw.count, GL_UNSIGNED_INT, C_NULL )   glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)   glBindVertexArray(0)   =#"
},

{
    "location": "files/JuliaOpenGL/#Swap-front-and-back-buffers-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Swap front and back buffers",
    "category": "section",
    "text": "GLFW.SwapBuffers(window)"
},

{
    "location": "files/JuliaOpenGL/#Poll-for-and-process-events-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Poll for and process events",
    "category": "section",
    "text": "GLFW.PollEvents()if SLEEP>0 Libc.systemsleep(SLEEP) end endGLFW.DestroyWindow(window) GLFW.Terminate()endendfunction main()   App.run() end"
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
    "text": "using Quaternions using StaticArrays #using ArrayFireinclude(\"matrix.jl\") include(\"vector.jl\")frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)translation{T}(t::Array{T,1})rotation{T}(r::Array{T,1})rotation{T}(q::Quaternion{T})computeRotation{T}(r::Array{T,1})scaling{T}(s::Array{T})transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})forward{T}(m::Array{T, 2})right{T}(m::Array{T, 2})up{T}(m::Array{T, 2})"
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
    "text": "using ModernGLglGenOne(glGenFn)glGenBuffer() = glGenOne(glGenBuffers) glGenVertexArray() = glGenOne(glGenVertexArrays) glGenTexture() = glGenOne(glGenTextures)glGetIntegerv_e(name::GLenum) = begin r=GLint[0]; glGetIntegerv(name,r); r[] endgetInfoLog(obj::GLuint)validateShader(shader)glErrorMessage()glCheckError(actionName=\"\")compileShader(name, shader,source)createShader(source::Tuple{Symbol,String}, typ)createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)createcontextinfo()get_glsl_version_string()"
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
    "text": "GetTimer(key)SetTimer(key, time::Number) SetTimer(\"FRAME_TIMER\", Dates.time())UpdateTimers()OnTime(milisec::Number)OnTime(milisec::Number, prevTime::Ref{Float64}, time)"
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
    "text": "using Compat: uninitialized, Nothing, Cvoid, AbstractDict using Images using ImageMagickdisplayInYellow(s) = string(\"\\x1b[93m\",s,\"\\x1b[0m\") displayInRed(s) = string(\"\\x1b[91m\",s,\"\\x1b[0m\")include(\"lib_window.jl\") include(\"lib_opengl.jl\") include(\"lib_math.jl\") include(\"lib_time.jl\")waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)fileGetContents(path::String, tryCount=100, tryWait=0.1)UpdateCounters()showFrames()include(\"cubeData.jl\") include(\"camera.jl\") include(\"frustum.jl\") include(\"chunk.jl\") include(\"mesh.jl\") include(\"texture.jl\")"
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
    "text": "TransformMeshArrayMeshDatasetAttributes(this::MeshArray, program, attrb)createBuffers(this::MeshData)setAttributes(this::MeshData, program)setDrawArray(this::MeshData, key::Symbol)setData(this::MeshArray, data, elems=0)linkData(this::MeshData, args...)upload(this::MeshArray)upload(this::MeshData)upload(this::MeshData, key::Symbol, data::AbstractArray)"
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
    "text": "loadShaders()"
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
    "text": "uploadTexture(path)"
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
    "text": "Install\nStart\nSzene"
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
    "text": ""
},

{
    "location": "manual/build/#",
    "page": "Build",
    "title": "Build",
    "category": "page",
    "text": ""
},

{
    "location": "manual/build/#build-1",
    "page": "Build",
    "title": "Build",
    "category": "section",
    "text": ""
},

{
    "location": "manual/install/#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "manual/install/#install-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": ""
},

{
    "location": "manual/optimization/#",
    "page": "JuliaOptimizer",
    "title": "JuliaOptimizer",
    "category": "page",
    "text": ""
},

{
    "location": "manual/optimization/#optimization-1",
    "page": "JuliaOptimizer",
    "title": "JuliaOptimizer",
    "category": "section",
    "text": "(main.h, main.cpp)#pragma once#include <array> #include <unordered_map>typedef void(LoopFunc)(void); typedef void(LoopFunc2)(float);#define EXPORT __declspec(dllexport)extern \"C\" {   EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);   EXPORT void loopByIndex(const unsigned int);   EXPORT void loopByObject(void*);   EXPORT void prepare(LoopFunc f, void** a, unsigned int count);   EXPORT void loop(); };struct loopObj {   LoopFunc loopFunc = NULL;   std::vector<void*> loopArray;   using Iterator = decltype(loopArray)::iterator;   Iterator it;   Iterator start;   Iterator end;loopObj() {}   loopObj(LoopFunc f, void** a, unsigned int count) {     loopFunc = f;     loopArray = std::vector<void*>(a, a + count);     start = loopArray.begin();     end = loopArray.end();   }void loop() {     for (it = start; it != end; ++it) loopFunc(*it);   } };std::unordered_map<unsigned int, loopObj> loopObjs;void* createLoop(const unsigned int index, void** a, const unsigned int count, LoopFunc f) {   return &(loopObjs[index] = loopObj(f, a, count)); }void loopByIndex(const unsigned int index) {   const auto& it = loopObjs.find(index);   if (it == loopObjs.end()) return;   it->second.loop(); }void loopByObject(void* iobj) {   if(!iobj) return;   ((loopObj*)iobj)->loop(); }// –––––––––––––––––––––-void prepare(LoopFunc f, void** a, unsigned int count) {   renderFun = f;   FIELDS = std::vector<void*>(a, a + count);   FSTART = FIELDS.begin();   FEND = FIELDS.end(); }void loop() {   for (FIT = FSTART; FIT != FEND; ++FIT) renderFun(*FIT); }"
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
    "text": ""
},

{
    "location": "manual/szene/#",
    "page": "Szene",
    "title": "Szene",
    "category": "page",
    "text": ""
},

{
    "location": "manual/szene/#szene-1",
    "page": "Szene",
    "title": "Szene",
    "category": "section",
    "text": ""
},

]}
