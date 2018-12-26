module LogManager

export stringColor
export info
export debug
export warn
#export error

RESET_COLOR = "\x1b[39m\x1b[49m"
FONT_COLOR = RESET_COLOR

function stringColor(s...;color=:normal, save=false)
  global FONT_COLOR
  colorstr=FONT_COLOR
  
  if color == :yellow colorstr="\x1b[93m"
  elseif color == :darkyellow colorstr="\x1b[33m"
  elseif color == :red colorstr="\x1b[91m"
  elseif color == :darkred colorstr="\x1b[31m"
  elseif color == :cyan colorstr="\x1b[96m"
  elseif color == :darkcyan colorstr="\x1b[36m"
  elseif color == :magenta colorstr="\x1b[95m"
  elseif color == :darkmagenta colorstr="\x1b[35m"
  elseif color == :reset colorstr=RESET_COLOR
  end
  
  if save FONT_COLOR=colorstr end
  
  return string(colorstr,s...,FONT_COLOR)
end

setFontColor(s...) = replace(string(s...),RESET_COLOR=>FONT_COLOR)

info(s...) = println(string(stringColor("";color=:yellow,save=true),setFontColor(s...),stringColor("";color=:reset,save=true)))
debug(s...) = println("\x1b[36mDEBUG: ",string(stringColor("";color=:cyan,save=true),setFontColor(s...),stringColor("";color=:reset,save=true)))
warn(s...) = println("\x1b[35mWARNING: ",string(stringColor("";color=:magenta,save=true),setFontColor(s...),stringColor("";color=:reset,save=true)))
error(s...) = println("\x1b[41mERROR\x1b[49m: ",string(stringColor("";color=:red,save=true),setFontColor(s...),stringColor("";color=:reset,save=true)))

end #LogManager