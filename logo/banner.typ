#import "icon.typ": logo, font, brace-color, foreground-color


#set page(
  margin: (x: 2pt, y: 5pt),
  height: auto,
  width: auto,
  fill: white.transparentize(100%),
)

#{
  show: box
  show: move.with(dy: 0.5pt, dx: 0.5pt)
  scale(box(logo(background-color: white)), 50%, reflow: true)
}
#set text(size: 4pt, font: "Roboto", fill: foreground-color, tracking: -0pt)
#h(-1em + 0.5pt)
imerErTim
