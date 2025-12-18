#import "lib.typ": *

#set page(margin: (x: 0pt, y: 4pt), height: auto)
#set text(size: 14pt, font: "Roboto")
#show raw: set text(font: "JetBrains Mono")
#show math.equation: set text(font: "Fira Math")
#set text(fill: themed(black, white))
#show heading: it => {
  set text(size: 16pt - it.level * 1pt)
  it
}
#set rect(stroke: themed(black, white))
#set par(spacing: 1em)

`> Load successful.`

#align(center, image(themed("out/typing-banner-light.svg", "out/typing-banner-dark.svg")))
#v(-1em)

#align(center)[
  #set text(size: 12pt)
  Early-Adopter *Rustacean* | #link("https://typst.app/")[*Typst*] Enthusiast | *FH Hagenberg* Student
  #line(length: 98%, stroke: (paint: gradient.linear(color.rgb("#B7410E"), color.rgb("#239DAD"), color.rgb("#5E8036")), thickness: 3pt, cap: "round"))
]

#image(themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"))

#pad(x: 2em, grid(
  columns: (1fr, 1fr),
  //stroke: 1pt,
  grid.cell()[
    #show: rect.with(radius: 6pt)
    Last seen vibing to:
    #pad(y: -1em, image(themed("out/spotify-playing.svg", "out/spotify-playing.svg")))
  ]
))

= Github Stats

#align(center)[
  #set text(size: 10pt, fill: themed(gray, gray.lighten(50%)))
  built on: #now.display() | Typst version: custom combiled
]