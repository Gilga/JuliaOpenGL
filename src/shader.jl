"""
load all content from shaders located in shaders folder in root dir
"""
function loadShaders(global_vars=Dict{Symbol,Any}();dir="shaders/")
  types=["VSH","FSH","GSH","CSH"]
   
  #shader_files = filter(x->isfile(dir*x) && uppercase(replace(splitext(x)[end],"."=>"")) == "GLSL",readdir(dir))
  
  list, list_paths = findFiles(dir, "GLSL")
  
  # replace vars and set types
  for (key,file) in list
    content=file[:content]
    vars=[x[1] for x in collect(eachmatch(r"\$(\w+)",content))]
    
    keystr=string(key)
    typ = :NOTHING
    for t in types
      if occursin(t, keystr)
        typ = Symbol(t)
        break
      end
    end
    
    for var in vars
      entry = nothing
      svar=Symbol(var)
      if haskey(global_vars, svar) entry=string(global_vars[svar])
      elseif haskey(list, var) entry="\""*list[var][:content]*"\""
      end
      if entry != nothing content=replace(content,"\$"*var=>entry) end
    end
    
    list[key][:shader] = typ
    list[key][:content] = content
  end
  
  # replace imports
  found=true
  while found
    found=false
    for (key,file) in list
      content=file[:content]
      
      if occursin("#import ", content)
        r=collect(eachmatch(r"(\#import\s+\"(\w+(\.\w+)*)\")",content))
        paths=[[x[1],x[2]] for x in r]
        
        for path in paths
          f=path[2]
          if dirname(f) == "" f=dir*f end
          kkey=Symbol(abspath(f))
          line="// FILE \""*f*"\" NOT FOUND!"
          if haskey(list_paths, kkey) line=list_paths[kkey][:content] end
          content = replace(content,path[1]=>line)
        end
        
        list[key][:content]=content

        found=true
      end
    end
  end
  
  # add glsl version
  for (key,file) in list
    file[:content] = get_glsl_version_string()*file[:content]
  end
  
  list
end

#stat("nodes.txt").mtime
