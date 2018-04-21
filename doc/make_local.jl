push!(LOAD_PATH,"../src/")

# include package
info("Include all...")
try
  include("../src/JuliaOpenGL.jl")
catch e # do not exit this run!
  warn(e)
end
info("Include done.")

info("Create Docs...")
using Documenter, App

makedocs(
  build     = joinpath(@__DIR__, "../docs"),
  modules   = [App],
  clean     = true,
  doctest   = true, # :fix
  #linkcheck = true,
  strict    = false,
  checkdocs = :none,
  format    = :html, #:latex 
  sitename  = "JuliaOpenGL",
  authors   = "Gilga",
  html_prettyurls = true,
  #html_canonical = "https://gilga.github.io/JuliaOpenGL/",
)

deploydocs(
  deps   = Deps.pip("mkdocs", "python-markdown-math"), #, "curl"
  repo = "https://github.com/Gilga/JuliaOpenGL",
  branch = "gh-pages",
  julia  = "0.6.2",
)

info("Docs done.")