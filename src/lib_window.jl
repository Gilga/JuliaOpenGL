import GLFW

glfwDll = GLFW.lib #should throw error if not exists
glfwLibs = abspath(GLFW.lib,"../")
glfwIncludes = abspath(glfwLibs,"../","include/")

!isdir(glfwIncludes) && error("$glfwIncludes is not found, ensure it is an absolute path.")
!isdir(glfwLibs) && error("$glfwLibs is not found, ensure it is an absolute path.")