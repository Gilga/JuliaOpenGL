module Log

export stringColor
export info
export debug
export warn
export error

function stringColor(s...;color=:yellow)
  colorstr="\x1b[0m"
  if color == :yellow colorstr="\x1b[93m"
  elseif color == :red colorstr="\x1b[91m"
  elseif color == :cyan colorstr="\x1b[96m"
  elseif color == :magenta colorstr="\x1b[95m"
  end
  return string(colorstr,s...,"\x1b[0m")
end

info(s...) = println(stringColor(s...;color=:yellow))
debug(s...) = println("DEBUG: ",stringColor(s...;color=:cyan))
warn(s...) = println("WARNING: ",stringColor(s...;color=:magenta))
error(s...) = Base.error(stringColor(s...;color=:red))

end #Log