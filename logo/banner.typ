#import "icon.typ": logo, font, brace-color, foreground-color
#import "../look-and-feel/index.typ": themes
#let theme = sys.inputs.at("theme", default: "light")

#let foreground-color = if theme == "light" {
  foreground-color
} else {
  themes.dark.foreground
}

#let brace-color = if theme == "light" {
  brace-color
} else {
  themes.dark.accent
}

#let background-color = if theme == "light" {
  white
} else {
  themes.dark.base
}

#set page(
  margin: (x: 1pt, y: 1pt, top: -2pt),
  height: auto,
  width: auto,
  fill: white.transparentize(100%),
)

#{
  show: box
  show: move.with(dy: 0.5pt, dx: 0.5pt)
  scale(box(logo(background-color: background-color,  brace-color: brace-color, text-color: foreground-color)), 50%, reflow: true)
}
#set text(size: 4pt, font: themes.fonts.sans.family, fill: foreground-color, tracking: -0pt)
#h(-1em + 0.425pt)
imerErTim
