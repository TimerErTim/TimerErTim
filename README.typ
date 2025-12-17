#import "lib.typ": *

#set page(margin: (x: 0pt, top: 4pt, bottom: 0pt), height: auto)
#set text(size: 14pt, font: "Roboto")
#show raw: set text(font: "JetBrains Mono")
#show math.equation: set text(font: "Fira Math")
#set text(fill: themed(black, white))

`> Load successful.`

#align(center, image(themed("out/typing-banner-light.svg", "out/typing-banner-dark.svg")))

#image(themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"))

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