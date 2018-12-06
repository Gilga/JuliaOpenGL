module FileManager

"""
TODO
"""
function waitForFileReady(path::String, func::Function; mode="r", tryCount=100, tryWait=0.1) #error when functions does not exists
	result=false
	for i = 1:tryCount
		#try reading file
		if stat(path).size > 0
			open(path, mode) do fp result=func(fp) end
			if result break end
		end
		Libc.systemsleep(tryWait) #wait
	end
	result
end

export waitForFileReady

"""
TODO
"""
function fileGetContents(path::String) #; tryCount=100, tryWait=0.1)
	content=nothing
	#waitForFileReady(path,(fp)->(content=read(fp, String); content != nothing);tryCount=tryCount,tryWait=tryWait)
  open(path, "r") do fp content=read(fp, String) end
  content
end

export fileGetContents

"""
TODO
"""
function fileReadLines(path::String, tryCount=100, tryWait=0.1)
	content=nothing
  open(path, "r") do fp
    for line in eachline(fp)
      if content == nothing content=line
      else content*="\n"*line
      end
    end
  end
  content
end

export fileReadLines

function findFiles(dir, target_ext="TXT")
  list=Dict{Symbol,Dict{Symbol,Any}}()
  list_paths=Dict{Symbol,Dict{Symbol,Any}}()
  target_ext=uppercase(target_ext)
  
  for f in readdir(dir)
    split=splitext(f)
    path=abspath(dir*f)
    name=split[1]
    ext=uppercase(replace(split[end],"."=>""))
    
    if !isfile(path) || ext != target_ext continue end
  
    file=Dict{Symbol,Any}()
    file[:file] = f
    file[:name] = name
    file[:ext] = ext
    file[:path] = path
    file[:content] = fileGetContents(path)
    file[:symbol]=key=Symbol(uppercase(name))

    list_paths[Symbol(path)] = list[key] = file
  end
  
  list, list_paths
end

export findFiles

end #FileManager