push!(LOAD_PATH,"../src/")

# isntall packages
Pkg.init()
cp(joinpath(@__DIR__, "REQUIRE"), Pkg.dir("REQUIRE"); force = true)
Pkg.update()
Pkg.resolve()

# include package
include("../src/JuliaOpenGL.jl")

using Documenter, App

makedocs(
  build     = joinpath(@__DIR__, "../site"),
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
