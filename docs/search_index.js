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
    "text": "Install\nStart\nSzene"
},

{
    "location": "index.html#Developer-Documentation-1",
    "page": "Home",
    "title": "Developer Documentation",
    "category": "section",
    "text": "Algorithm\nBuild\nOptimization\nReferences"
},

{
    "location": "manual/install.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "manual/install.html#install-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": ""
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
    "text": ""
},

{
    "location": "manual/szene.html#",
    "page": "Szene",
    "title": "Szene",
    "category": "page",
    "text": ""
},

{
    "location": "manual/szene.html#szene-1",
    "page": "Szene",
    "title": "Szene",
    "category": "section",
    "text": ""
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
    "text": ""
},

{
    "location": "manual/build.html#",
    "page": "Build",
    "title": "Build",
    "category": "page",
    "text": ""
},

{
    "location": "manual/build.html#build-1",
    "page": "Build",
    "title": "Build",
    "category": "section",
    "text": ""
},

{
    "location": "manual/optimization.html#",
    "page": "JuliaOptimizer",
    "title": "JuliaOptimizer",
    "category": "page",
    "text": ""
},

{
    "location": "manual/optimization.html#optimization-1",
    "page": "JuliaOptimizer",
    "title": "JuliaOptimizer",
    "category": "section",
    "text": "(main.h, main.cpp)#pragma once#include <array> #include <unordered_map>typedef void(LoopFunc)(void); typedef void(LoopFunc2)(float);#define EXPORT __declspec(dllexport)extern \"C\" {   EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);   EXPORT void loopByIndex(const unsigned int);   EXPORT void loopByObject(void*);   EXPORT void prepare(LoopFunc f, void** a, unsigned int count);   EXPORT void loop(); };struct loopObj {   LoopFunc loopFunc = NULL;   std::vector<void*> loopArray;   using Iterator = decltype(loopArray)::iterator;   Iterator it;   Iterator start;   Iterator end;loopObj() {}   loopObj(LoopFunc f, void** a, unsigned int count) {     loopFunc = f;     loopArray = std::vector<void*>(a, a + count);     start = loopArray.begin();     end = loopArray.end();   }void loop() {     for (it = start; it != end; ++it) loopFunc(*it);   } };std::unordered_map<unsigned int, loopObj> loopObjs;void* createLoop(const unsigned int index, void** a, const unsigned int count, LoopFunc f) {   return &(loopObjs[index] = loopObj(f, a, count)); }void loopByIndex(const unsigned int index) {   const auto& it = loopObjs.find(index);   if (it == loopObjs.end()) return;   it->second.loop(); }void loopByObject(void* iobj) {   if(!iobj) return;   ((loopObj*)iobj)->loop(); }// –––––––––––––––––––––-void prepare(LoopFunc f, void** a, unsigned int count) {   renderFun = f;   FIELDS = std::vector<void*>(a, a + count);   FSTART = FIELDS.begin();   FEND = FIELDS.end(); }void loop() {   for (FIT = FSTART; FIT != FEND; ++FIT) renderFun(*FIT); }"
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
    "location": "files/JuliaOpenGL.html#",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "JuliaOpenGL.jl (main.jl)",
    "category": "page",
    "text": ""
},

{
    "location": "files/JuliaOpenGL.html#App",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "App",
    "category": "module",
    "text": "TODO\n\n\n\n"
},

{
    "location": "files/JuliaOpenGL.html#JuliaOpenGL.jl-(main.jl)-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "JuliaOpenGL.jl (main.jl)",
    "category": "section",
    "text": "App"
},

{
    "location": "files/JuliaOpenGL.html#INCLUDES-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "INCLUDES",
    "category": "section",
    "text": "include(\"libs.jl\") include(\"shader.jl\")"
},

{
    "location": "files/JuliaOpenGL.html#COMPILE-C-File-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "COMPILE C File",
    "category": "section",
    "text": "#include(\"compileAndLink.jl\") const compileAndLink = isdefined(:createLoop) setMode(program, name, mode)setFrustumCulling(load=true)chooseRenderMethod(method=RENDER_METHOD)checkForUpdate()useProgram(program)setMatrix(program, name, m)setMVP(program, mvp, old_program=nothing)"
},

{
    "location": "files/JuliaOpenGL.html#PROGRAM-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "PROGRAM",
    "category": "section",
    "text": "run()println(\"––––––––––––––––––––––––––––––––––-\") println(\"Start Program @ \", Dates.time()) versioninfo()"
},

{
    "location": "files/JuliaOpenGL.html#OS-X-specific-GLFW-hints-to-initialize-the-correct-version-of-OpenGL-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "OS X-specific GLFW hints to initialize the correct version of OpenGL",
    "category": "section",
    "text": "GLFW.Init()"
},

{
    "location": "files/JuliaOpenGL.html#Create-a-windowed-mode-window-and-its-OpenGL-context-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Create a windowed mode window and its OpenGL context",
    "category": "section",
    "text": "global window = GLFW.CreateWindow(WIDTH, HEIGHT, \"OpenGL Example\")"
},

{
    "location": "files/JuliaOpenGL.html#Make-the-window\'s-context-current-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Make the window\'s context current",
    "category": "section",
    "text": "GLFW.MakeContextCurrent(window)GLFW.SetWindowSize(window, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0 rezizeWindow(WIDTH,HEIGHT)"
},

{
    "location": "files/JuliaOpenGL.html#Window-settings-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Window settings",
    "category": "section",
    "text": "GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)"
},

{
    "location": "files/JuliaOpenGL.html#Graphcis-Settings-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Graphcis Settings",
    "category": "section",
    "text": "GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug #GLFW.WindowHint(GLFW.SAMPLES,4)"
},

{
    "location": "files/JuliaOpenGL.html#OpenGL-Version-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "OpenGL Version",
    "category": "section",
    "text": "GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4) GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)GLFW.SetCursorPosCallback(window, OnCursorPos) GLFW.SetKeyCallback(window, OnKey) GLFW.SetMouseButtonCallback(window, OnMouseKey)#setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)GLFW.ShowWindow(window)glinfo = createcontextinfo()println(\"OpenGL displayInRed(glinfo[:gl_version])\") println(\"GLSL glinfo[:glsl_version]\") println(\"Vendor displayInRed(glinfo[:gl_vendor])\") println(\"Renderer displayInRed(glinfo[:gl_renderer])\") println(\"––––––––––––––––––––––––––––––––––-\")"
},

{
    "location": "files/JuliaOpenGL.html#CAMERA-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "CAMERA",
    "category": "section",
    "text": "setPosition(CAMERA,[0f0,0,0]) setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))global fstm = Frustum() SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 1000f0) SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))Update(CAMERA)#––––––––––––––––––––––––––––––––––––––––––program = 0#––––––––––––––––––––––––––––––––––––––––––global chunkData = MeshData() global planeData = MeshData()#––––––––––––––––––––––––––––––––––––––––––"
},

{
    "location": "files/JuliaOpenGL.html#TEXTURES-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "TEXTURES",
    "category": "section",
    "text": "uploadTexture(\"blocks.png\")"
},

{
    "location": "files/JuliaOpenGL.html#LOAD-DEFAULT-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "LOAD DEFAULT",
    "category": "section",
    "text": "chooseRenderMethod()#––––––––––––––––––––––––––––––––––––––––––linkData(planeData,  :vertices=>getVertices(fstm))#chunkData.arrays[:vertices].count #n = length(cubeVertices_small) / 3#function compileShaderPrograms()"
},

{
    "location": "files/JuliaOpenGL.html#global-program_chunks,-program_normal-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "global program_chunks, program_normal",
    "category": "section",
    "text": "global program_normal = createShaderProgram(VSH, FSH) #, createShader(GSH, GL_GEOMETRY_SHADER)setAttributes(planeData, program_normal) setMVP(program_normal, CAMERA.MVP)#end#compileShaderPrograms()global location_position = -1 global location_texindex = -1#––––––––––––––––––––––––––––––––––––––––––function updateBlocks()   #const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)   #setMVP(CAMERA.MVP)   #glUniform3fv(location_shift, 1, CAMERA.position)   #glUniform3fv(location_shift, 1, shiftposition)   #for b in blocks; b.mvp=mmvp*b.model; end end#––––––––––––––––––––––––––––––––––––––––––glEnable(GL_DEPTH_TEST) glEnable(GL_BLEND) glEnable(GL_CULL_FACE) #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) #glBlendEquation(GL_FUNC_ADD) #glFrontFace(GL_CCW) glCullFace(GL_BACK) #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE glClearColor(0.0, 0.0, 0.0, 1.0)"
},

{
    "location": "files/JuliaOpenGL.html#Loop-until-the-user-closes-the-window-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Loop until the user closes the window",
    "category": "section",
    "text": "render = function(x)   #mvp = mmvpMMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))   #setMVP(CAMERA.MVPtranslation([c.x,c.y,c.z]))#glUniformMatrix4fv(location_mvp, 1, false, x.mvp)   #glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )   #glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)   nothing end#= if use_geometry_shader   const loopBlocks() = render(mychunk.childs[1]) else   if compileAndLink     objptr = createLoop(1,refblocks,render) #compileAndLink     const loopBlocks() = loopByObject(objptr) #compileAndLink   else     const loopBlocks() = for b in mychunk.childs; render(b); end   end end =#cam_updated=falseconst SLEEP=0 #1f0/200i=0 while !GLFW.WindowShouldClose(window)   showFrames()   UpdateCounters()if OnUpdate(CAMERA)     setMVP(program_chunks, CAMERA.MVP)     #setMVP(program_normal, CAMERA.MVP)     cam_updated=true   endcheckForUpdate()   if cam_updated cam_updated=false end"
},

{
    "location": "files/JuliaOpenGL.html#Pulse-the-background-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Pulse the background",
    "category": "section",
    "text": "#c=0.5 * (1 + sin(i * 0.01)); i+=1   #glClearColor(c, c, c, 1.0)   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)#print(\"loopBlocks \"); @time   #loopBlocks()if isValid(mychunk)      useProgram(program_chunks)     #glCheckError(\"useProgram\")     glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)     glBindVertexArray(chunkData.vao)     #glCheckError(\"glBindVertexArray bind\")if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS, 0, 1, mychunk.fileredCount) #GL_TRIANGLE_STRIP\r\nelseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, chunkData.draw.count, mychunk.fileredCount)\r\nelseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, mychunk.fileredCount)\r\n#glDrawElementsInstancedBaseVertex(GL_TRIANGLES, chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)\r\nelseif RENDER_METHOD > 3\r\n  #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)\r\n  for b in getFilteredChilds(mychunk)\r\n    if location_texindex > -1 glUniform1f(location_texindex, b.typ) end\r\n    if location_position > -1 glUniform3fv(location_position, 1, b.pos) end\r\n    glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )\r\n    #glCheckError(\"glDrawElements\")\r\n  end\r\nend\r\nglBindVertexArray(0)\r\n#glCheckError(\"glBindVertexArray unbind\")end#=   useProgram(program_normal)   glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)glBindVertexArray(planeData.vao)   #glDrawElements(GL_TRIANGLES, planeData.draw.count, GL_UNSIGNED_INT, C_NULL )   glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)   glBindVertexArray(0)   =#"
},

{
    "location": "files/JuliaOpenGL.html#Swap-front-and-back-buffers-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Swap front and back buffers",
    "category": "section",
    "text": "GLFW.SwapBuffers(window)"
},

{
    "location": "files/JuliaOpenGL.html#Poll-for-and-process-events-1",
    "page": "JuliaOpenGL.jl (main.jl)",
    "title": "Poll for and process events",
    "category": "section",
    "text": "GLFW.PollEvents()if SLEEP>0 Libc.systemsleep(SLEEP) end endGLFW.DestroyWindow(window) GLFW.Terminate()endendfunction main()   App.run() end"
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
    "location": "files/lib_math.html#lib_math.jl-1",
    "page": "lib_math.jl",
    "title": "lib_math.jl",
    "category": "section",
    "text": "using Quaternions using StaticArrays #using ArrayFireinclude(\"matrix.jl\") include(\"vector.jl\")frustum{T}(left::T, right::T, bottom::T, top::T, znear::T, zfar::T)projection_perspective{T}(fovy::T, aspect::T, znear::T, zfar::T)projection_orthographic{T}(left::T,right::T,bottom::T,top::T,znear::T,zfar::T)translation{T}(t::Array{T,1})rotation{T}(r::Array{T,1})rotation{T}(q::Quaternion{T})computeRotation{T}(r::Array{T,1})scaling{T}(s::Array{T})transform{T}(t::Array{T,1},r::Array{T,1},s::Array{T,1})ViewRH{T}(eye::Array{T,1}, yaw::T, pitch::T)lookat{T}(eye::Array{T,1}, lookAt::Array{T,1}, up::Array{T,1})forward{T}(m::Array{T, 2})right{T}(m::Array{T, 2})up{T}(m::Array{T, 2})"
},

{
    "location": "files/lib_opengl.html#",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_opengl.html#lib_opengl.jl-1",
    "page": "lib_opengl.jl",
    "title": "lib_opengl.jl",
    "category": "section",
    "text": "using ModernGLglGenOne(glGenFn)glGenBuffer() = glGenOne(glGenBuffers) glGenVertexArray() = glGenOne(glGenVertexArrays) glGenTexture() = glGenOne(glGenTextures)glGetIntegerv_e(name::GLenum) = begin r=GLint[0]; glGetIntegerv(name,r); r[] endgetInfoLog(obj::GLuint)validateShader(shader)glErrorMessage()glCheckError(actionName=\"\")compileShader(name, shader,source)createShader(source::Tuple{Symbol,String}, typ)createShaderProgram(vertexShader, fragmentShader, geometryShader=nothing)createcontextinfo()get_glsl_version_string()"
},

{
    "location": "files/lib_time.html#",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "page",
    "text": ""
},

{
    "location": "files/lib_time.html#lib_time.jl-1",
    "page": "lib_time.jl",
    "title": "lib_time.jl",
    "category": "section",
    "text": "GetTimer(key)SetTimer(key, time::Number) SetTimer(\"FRAME_TIMER\", Dates.time())UpdateTimers()OnTime(milisec::Number)OnTime(milisec::Number, prevTime::Ref{Float64}, time)"
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
    "location": "files/libs.html#libs.jl-1",
    "page": "libs.jl",
    "title": "libs.jl",
    "category": "section",
    "text": "using Compat: uninitialized, Nothing, Cvoid, AbstractDict using Images using ImageMagickdisplayInYellow(s) = string(\"\\x1b[93m\",s,\"\\x1b[0m\") displayInRed(s) = string(\"\\x1b[91m\",s,\"\\x1b[0m\")include(\"lib_window.jl\") include(\"lib_opengl.jl\") include(\"lib_math.jl\") include(\"lib_time.jl\")waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)fileGetContents(path::String, tryCount=100, tryWait=0.1)UpdateCounters()showFrames()include(\"cubeData.jl\") include(\"camera.jl\") include(\"frustum.jl\") include(\"chunk.jl\") include(\"mesh.jl\") include(\"texture.jl\")"
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
    "location": "files/shader.html#shader.jl-1",
    "page": "shader.jl",
    "title": "shader.jl",
    "category": "section",
    "text": "loadShaders()"
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
    "location": "files/texture.html#texture.jl-1",
    "page": "texture.jl",
    "title": "texture.jl",
    "category": "section",
    "text": "uploadTexture(path)"
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
