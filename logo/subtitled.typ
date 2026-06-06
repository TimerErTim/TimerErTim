#import "icon.typ": logo, foreground-color
#import "../look-and-feel/index.typ": themes

#set page(
  margin: 1pt,
  height: auto,
  width: auto,
  fill: white.transparentize(100%),
)

#{
  set align(center)
  show: box
  logo(
    background-color: white,
  )
}
#set text(size: 4pt, font: themes.fonts.sans.family, fill: foreground-color)
#v(-3em)
TimerErTim

