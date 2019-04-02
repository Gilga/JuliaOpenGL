@echo off
REM --code-coverage="test/tracefile-%p.info" --code-coverage=user 
"C:/Users/%username%/AppData/Local/Julia-1.0.0/bin/julia.exe"  --track-allocation=user "src/memory.jl"
pause