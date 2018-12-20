module LogManager

import Base.error

export stringColor
export info
export debug
export warn
export error

FONT_COLOR = :normal

function stringColor(s...;color=FONT_COLOR, reset=true)
  global FONT_COLOR
  colorstr="\x1b[0m"
  if color == :yellow colorstr="\x1b[93m"
  elseif color == :red colorstr="\x1b[91m"
  elseif color == :cyan colorstr="\x1b[96m"
  elseif color == :magenta colorstr="\x1b[95m"
  end
  FONT_COLOR=colorstr
  return string(colorstr,s...,reset ? "\x1b[0m" : "")
end

info(s...) = println(string(stringColor("";color=:yellow,reset=false),s...,stringColor("";color=:normal)))
debug(s...) = println("DEBUG: ",string(stringColor("";color=:cyan,reset=false),s...,stringColor("";color=:normal)))
warn(s...) = println("WARNING: ",string(stringColor("";color=:magenta,reset=false),s...,stringColor("";color=:normal)))
error(s...) = Base.error(string(stringColor("";color=:red,reset=false),s...,stringColor("";color=:normal)))

end #LogManager