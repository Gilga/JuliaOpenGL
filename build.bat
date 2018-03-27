@echo off
set "dir=%cd%"
rem set dir=%~d1
rem set name=%~n1

set "version=%1"
set "name=%2"
set "outputdirname=build"

if "%version%" == "" ( set "version=0.6.0" )
if "%name%" == "" ( set "name=app" )

set "file=%dir%/main.jl"
set "outputdir=%dir%/%outputdirname%/%version%/"
set "output=--force %name% %file% %outputdir%"

set "juliaExe=C:/Users/%username%/AppData/Local/Julia-%version%/bin/julia.exe"
set "buildScript=%cd%/../BuildExecutable/src/build_executable.jl"

echo Build "%file%"...
echo call "%juliaExe%" "%buildScript%" %output%
"%juliaExe%" "%buildScript%" %output%
pause