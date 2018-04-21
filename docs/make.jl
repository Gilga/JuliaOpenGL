push!(LOAD_PATH,"../src/")

using Documenter

makedocs()

deploydocs(
  deps   = Deps.pip("mkdocs", "python-markdown-math"),
  repo = "https://github.com/Gilga/JuliaOpenGL",
  julia  = "0.6.2",
  osname = "osx"
)