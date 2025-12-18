#import "lib.typ": *

#set page(margin: (x: 0pt, y: 4pt), height: auto)
#set text(size: 14pt, font: "Roboto")
#show raw: set text(font: "JetBrains Mono")
#show math.equation: set text(font: "Fira Math")
#set text(fill: themed(black, white))
#set rect(stroke: themed(black, white))

`> Load successful.`

#align(center, image(themed("out/typing-banner-light.svg", "out/typing-banner-dark.svg")))

#image(themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"))

#pad(x: 2em, grid(
  columns: (1fr, 1fr),
  //stroke: 1pt,
  grid.cell()[
    #show: rect.with(radius: 6pt)
    Last seen vibing to:
    #pad(y: -1em, image(themed("out/spotify-playing.svg", "out/spotify-playing.svg"), width: 9cm))
  ]
))

#[
  #set text(fill: green, font: "Fira Math")
  This is Fira Math #math.sqrt([2])
  $ E = m c^2, space "Corr"(X, Y) = "Cov"(X, Y) / (sqrt("Var"(X)) sqrt("Var"(Y))) $
]

#xhtml(```html
<xhtml:div style="background-color: green;">Hello, world!</xhtml:div>
```)


#xhtml(```html
<xhtml:img src="http://server.timerertim.eu:5000/" />
```, outer-width: 500pt, outer-height: 250pt)

#align(center)[
  #set text(size: 12pt, fill: themed(gray, gray.lighten(50%)))
  built on: #now.display() | Typst version: custom combiled
]