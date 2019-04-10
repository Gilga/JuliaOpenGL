module RessourceManager

paths = Dict{Symbol,String}(:ROOT => "")
use_backslash = false

#string(dirname(Base.source_path()),"/"))
#currentDay() = replace(replace(string(Dates.now()),":","-"),"T","_")

""" TODO """
useBackslash(use::Bool) = global use_backslash = use

""" TODO """
printPaths() = for e in paths println(string(e)) end

""" TODO """
frontslash(path::String) = replace(path,"\\"=>"/")

""" TODO """
backslash(path::String) = replace(path,"/"=>"\\")

""" TODO """
slash(path::String) = !use_backslash ? frontslash(path) : backslash(path)

""" TODO """
setRoot() = paths[:ROOT] = slash(abspath(joinpath(@__DIR__,"../")))
setRoot() # set root

""" TODO """
ressourcepath(path::String) = slash(isabspath(path) ? path : string(getRoot(), path, last(path) != '/' ? "/" : ""))

""" TODO """
setPath(id::Symbol, path::String) = paths[id] = ressourcepath(path)
export setPath

""" TODO """
getPath(key::Symbol,file::String="") = paths[haskey(paths, key) ? key : :ROOT]*file
export getPath

""" TODO """
getRoot() = getPath(:ROOT)
export getRoot

end # RessourceManager
