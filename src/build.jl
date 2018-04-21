l=length(ARGS)

buildscript="BuildExecutable/src/build_executable.jl"

default_version=string(VERSION)

version=l<1?default_version:ARGS[1]
name=l<2?"app":ARGS[2]
dir=l<3?"build":ARGS[3]
script=l<4?"main.jl":ARGS[4]

debug = false
julia = replace(abspath(joinpath(JULIA_HOME, debug ? "julia-debug" : "julia")), default_version,version)

path = replace(dirname(Base.source_path()),"\\","/")

targetdir_build=joinpath(path,dir)
targetdir_version=joinpath(targetdir_build,version)
targetdir_project=joinpath(targetdir_version,name)
targetdir = targetdir_project

sourcescript=joinpath(path,script)
buildscriptpath=buildscript

## -------------------------------------------------------------------------------

if !isfile(julia * (is_windows() ? ".exe" : "")) error("'$julia' not found.") end

# find buildscript...
if !isfile(buildscriptpath)
  buildscriptpath=joinpath(path,buildscript)
  if !isfile(buildscriptpath)
    current = path
    prev = current
    found=false
    for i=1:10
      current=abspath(joinpath(current,"../"))
      buildscriptpath=joinpath(current,buildscript)
      if isfile(buildscriptpath) found=true; break end
      if current == prev break end #dublicate, sp break
      prev = current
    end
  end
  if !found error("'$buildscript' not found.") end
end

if !isfile(sourcescript) error("'$sourcescript' not found.") end

if !isdir(targetdir_build) mkdir(targetdir_build) end
if !isdir(targetdir_version) mkdir(targetdir_version) end
if !isdir(targetdir_project) mkdir(targetdir_project) end

if !isdir(targetdir_build) error("'$targetdir_build' failed to create.") end
if !isdir(targetdir_version) error("'$targetdir_version' failed to create.") end
if !isdir(targetdir_project) error("'$targetdir_project' failed to create.") end

cmd=`$julia $buildscriptpath --force "$name" $sourcescript $targetdir`

info(cmd)
run(cmd)
