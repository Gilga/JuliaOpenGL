__precompile__()

module App

using JLD
using Images
using ImageMagick

function run()
  include("run.jl")
end

end

function main()
  App.run()
end
