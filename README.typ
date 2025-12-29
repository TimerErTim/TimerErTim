#import "@preview/fletcher:0.5.8" as fletcher: edge, node

#import "lib.typ": *

#set page(margin: (x: 0pt, y: 4pt), height: auto)
#set text(size: 12pt, font: ("Roboto", "Noto Color Emoji"))
#show raw: set text(font: "JetBrains Mono")
#show math.equation: set text(font: "Fira Math")
#set text(fill: themed(black, white))
#show heading: it => {
  set block(below: 0.75em)
  set text(size: 16pt - it.level * 1.5pt)
  it
  if it.level == 1 {
    set align(center)
    v(-0.5em)
    line(length: 100%, stroke: themed(gray.lighten(25%), gray).transparentize(50%))
    v(0.5em)
  }
}
#set rect(stroke: themed(black, white))
#set par(spacing: 1em)

`> Load successful.`

#align(center, image(themed("out/typing-banner-light.svg", "out/typing-banner-dark.svg")))
#v(-1em)

#align(center)[
  #set text(size: 12pt)
  Early-Adopter *Rustacean* #box(baseline: 15%, image("assets/Ferris.svg", width: 16pt)) |
  *Typst* #box(baseline: 15%, image("assets/typst.jpeg", width: 14pt)) Enthusiast |
  *FH Hagenberg* #box(baseline: 15%, stroke: 1pt + themed(black, white), radius: 3pt, fill: white, image("assets/fhooe-logo.svg", width: 20pt)) Student
  #line(length: 98%, stroke: (
    paint: gradient.linear(color.rgb("#B7410E"), color.rgb("#239DAD"), color.rgb("#5E8036")),
    thickness: 3pt,
    cap: "round",
  ))
]

#v(1em)
I specialize in writing code that is safe, concurrent, and occasionally panics. I program mainly for fun and learning. Exploring ideas and finding solutions to non-existent problems is my passion.

= Overview

#grid(
  columns: (1fr, 1fr),
  stroke: 1pt + themed(gray.darken(25%), gray.lighten(25%)),
  inset: 1em,
  align: center,
  grid.cell()[
    👀 The Metrics 🤌
    // #image(themed("out/github-stats-light.svg", "out/github-stats-dark.svg"), width: 100%),
  ],
  grid.cell()[
    ⚙️ Tech Stack 🔧

    #pad(image(themed("out/tech-stack-light.svg", "out/tech-stack-dark.svg"), width: 100%), y: -1em, x: -1em)

    🎵 Coding Soundtrack 🎵

    #rect(
      radius: 6pt,
      inset: (bottom: -4pt),
      fill: themed(gray.transparentize(90%), white.transparentize(50%)),
      stroke: 1pt + themed(gray.darken(25%), gray.lighten(25%)),
      image(themed("out/spotify-playing.svg", "out/spotify-playing.svg"), width: 100%),
    )
    
    #set align(left)
    #let done = box(rect(width: 1em, height: 1em, radius: 30%, stroke: themed(gray.darken(25%), gray.lighten(25%)), fill: themed(gray, gray))[
      #place(center + top, sym.checkmark, clearance: 0pt, dy: -3pt)
    ], baseline: 1pt)
    #let pending = box(rect(width: 1em, height: 1em, radius: 30%, stroke: themed(gray.darken(25%), gray.lighten(25%))), baseline: 1pt)

    📝 TODO:\
    #done Rewrite everything in Rust\
    #pending Actually finish side projects\
    #pending Expand this TODO list
  ],
)

== Contributions with Snakey Snek 🐍

#pad(1pt, rect(
  radius: 6pt,
  inset: (top: -1em, x: -0.25em),
  fill: themed(white, black).transparentize(90%),
  image(themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"), width: 100%),
))

= How this README works

Using a modified version of the `reflexo-vec2svg` crate, we can inline SVG `#image(...)` elements directly into the SVG exported Typst document.

#let titled-content-card(
  title: [],
  content,
  width: 1fr,
) = {
  grid(
    columns: (width,),
    inset: 0.32em,
    grid.header(
      grid.cell(
        inset: 0pt,
        align: center,
        box(
          fill: luma(themed(100, 256 - 100)).transparentize(90%),
          stroke: 1pt + luma(themed(120, 256 - 120)),
          inset: 0.32em,
          radius: (top-left: 0.32em, top-right: 0.32em),
          width: 1fr,
          title,
        ),
      ),
    ),
    grid.cell(
      inset: 0pt,
      align: center,
      box(
        stroke: 1pt + luma(themed(120, 256 - 120)),
        inset: 0.32em,
        radius: (bottom-left: 0.32em, bottom-right: 0.32em),
        width: 1fr,
        content,
      ),
    ),
  )
}

#align(center, fletcher.diagram(
  debug: 0,
  node-inset: 0pt,
  edge-stroke: themed(black, white),
  spacing: (4em, 1em),
  node((0, 0), titled-content-card(width: 17em, title: [`source.typ`])[
    #set align(left)
    #set text(size: 10pt)
    ```typ
    #lorem(15)
    #image("snake.svg")
    #lorem(10)
    ```
  ]),
  node((0, 1), titled-content-card(width: 17em, title: [`snake.svg`])[
    #image(themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"), width: 100%)
  ]),
  node(enclose: ((1, 0), (1, 1)), titled-content-card(width: 17em, title: [`output.svg`])[
    #set align(left)
    #set text(size: 10pt, fill: themed(black, white).transparentize(25%))
    #lorem(15)
    #rect(
      radius: 5pt,
      stroke: themed(red, red),
      image(
        themed("out/snake-contribution-graph-light.svg", "out/snake-contribution-graph-dark.svg"),
        width: 100%,
      ),
      inset: (top: -0.5em, rest: 0em),
    )
    #lorem(10)
  ]),
  edge((0, 0), (1, 0), "-|>"),
  edge((0, 1), (1, 1), "-|>"),
))

This effectively allows us to have animated SVGs in the README.

#v(1em)
#align(center)[
  #set text(size: 10pt, fill: themed(gray.darken(50%), gray.lighten(50%)))
  Last compilation: *#now.display()* | Typst based on: *#sys.version* | Deployed to: *GitHub*
]
