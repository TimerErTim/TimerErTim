#import "@preview/fletcher:0.5.8" as fletcher: edge, node
#import "@preview/pinit:0.2.2": pin, pinit-point-from

#import "../look-and-feel/index.typ": get-theme
#import "lib.typ": *
#show image.where(format: "svg"): set image(alt: "!typst-embed-command")

#let theme = themed(get-theme("light"), get-theme("dark"))

#set page(margin: (x: 0pt, y: 4pt), height: auto)
#set text(size: 12pt, font: (theme.fonts.sans.family, "Noto Color Emoji"))
#show raw: set text(font: theme.fonts.mono.family)
#show math.equation: set text(font: "Fira Math")
#set text(fill: theme.colors.foreground)
#show heading: it => {
  set block(below: 0.75em)
  set text(size: 16pt - it.level * 1.5pt)
  it
  if it.level == 1 {
    set align(center)
    v(-0.5em)
    line(
      length: 100%,
      stroke: theme.colors.neutral.transparentize(50%),
    )
    v(0.5em)
  }
}
#set rect(stroke: theme.colors.foreground)
#set par(spacing: 1em)
#show link: set text(fill: theme.colors.info)
#show link: strong

`> Load successful.`

#align(center, image(
  themed(
    "out/typing-banner-light.svg",
    "out/typing-banner-dark.svg",
  ),
  alt: "!typst-embed-command",
))
#v(-1em)

#align(center)[
  #set text(size: 12pt)
  Early-Adopter *Rustacean* #box(baseline: 15%, image("assets/Ferris.svg", width: 16pt)) |
  *Typst* #box(baseline: 15%, image("assets/typst.jpeg", width: 14pt)) Enthusiast |
  *FH Hagenberg* #box(baseline: 15%, stroke: 1pt + themed(black, white), radius: 3pt, fill: white, image("assets/fhooe-logo.svg", width: 20pt)) Student
  #line(length: 98%, stroke: (
    paint: gradient.linear(
      color.rgb("#B7410E"),
      color.rgb("#239DAD"),
      color.rgb("#5E8036"),
    ),
    thickness: 3pt,
    cap: "round",
  ))
]

#v(1em)
I specialize in writing code that is safe, concurrent, and occasionally panics. I program mainly for fun and learning. Exploring ideas and finding solutions to non-existent problems is my passion.

= Overview

#pad(x: 1em, grid(
  columns: (1fr, 1fr),
  //stroke: 1pt + themed(gray.darken(25%), gray.lighten(25%)),
  gutter: 2em,
  align: center,
  grid.cell()[
    👀 The Metrics 🤌
    #image(
      themed("out/overview-light.svg", "out/overview-dark.svg"),
      width: 100%,
      alt: "!typst-embed-command",
    )
    #v(-1em)
    #image(
      themed("out/languages-light.svg", "out/languages-dark.svg"),
      width: 100%,
      alt: "!typst-embed-command",
    )
  ],
  grid.cell()[
    #[
      #set align(left)

      #let item(icon, text) = {
        set align(horizon)
        set image(height: 16pt)
        grid(
          columns: 2,
          align: horizon,
          gutter: 0.5em,
          icon,
          text
        )
      }

      #item(image("../assets/logos/yt-square.png"), link(config.TIMERERTIM_YOUTUBE_URL.trim(regex(`https?://`.text))))

      #item(image("../assets/logos/github-invertocat.svg"), link(config.TIMERERTIM_GITHUB_URL.trim(regex(`https?://`.text))))

      #item(image("../assets/logos/linkedin-square.png"), link(config.TIMERERTIM_LINKEDIN_URL.trim(regex(`https?://`.text))))

      #item(image("../assets/identity/icon.png"), link(config.TIMERERTIM_SITE_ORIGIN.trim(regex(`https?://`.text))))
    ]

    ⚙️ Tech Stack 🔧

    #pad(
      image(
        themed("out/tech-stack-light.svg", "out/tech-stack-dark.svg"),
        alt: "!typst-embed-command",
        width: 100%,
      ),
      y: -1em,
      x: -1em,
    )

    🎵 Coding Soundtrack 🎵

    #rect(
      radius: 6pt,
      inset: (bottom: -4pt),
      stroke: themed(black.lighten(60%), white.darken(60%)),
      fill: themed(white.transparentize(100%), black.lighten(5%)),
      image(
        themed("out/spotify-playing.svg", "out/spotify-playing.svg"),
        alt: "!typst-embed-command",
        width: 100%,
      ),
    )

  ],
))

== Contributions with Snakey Snek 🐍

#pad(1pt, rect(
  radius: 6pt,
  inset: (top: -1em, x: -0.25em),
  stroke: theme.colors.foreground.lighten(60%),
  image(
    themed(
      "out/snake-contribution-graph-light.svg",
      "out/snake-contribution-graph-dark.svg",
    ),
    width: 100%,
    alt: "!typst-embed-command",
  ),
))

= How this README works

Using `typst-ts-cli` with the `svg_html` format, we can inline SVG `#image(...)` elements directly into the exported SVG document. A post-processing step extracts the root `<svg>` and decodes nested base64 embeds.

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
          fill: theme.colors.base,
          stroke: 1pt + theme.colors.border,
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
        stroke: 1pt + theme.colors.border,
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
  edge-stroke: theme.colors.foreground,
  spacing: (4em, 1em),
  node((0, 0), titled-content-card(width: 17em, title: [`source.typ`])[
    #set align(left)
    #set text(size: 10pt)
    ```typ
    #lorem(15)
    #image("snake.svg", alt: "!typst-embed-command")
    #lorem(10)
    ```
  ]),
  node((0, 1), titled-content-card(width: 17em, title: [`snake.svg`])[
    #image(
      themed(
        "out/snake-contribution-graph-light.svg",
        "out/snake-contribution-graph-dark.svg",
      ),
      width: 100%,
      alt: "!typst-embed-command",
    )
  ]),
  node(enclose: ((1, 0), (1, 1)), titled-content-card(
    width: 17em,
    title: [`output.svg`],
  )[
    #set align(left)
    #set text(size: 10pt, fill: theme.colors.foreground.transparentize(25%))
    #lorem(15)
    #rect(
      radius: 5pt,
      stroke: theme.colors.danger,
      image(
        themed(
          "out/snake-contribution-graph-light.svg",
          "out/snake-contribution-graph-dark.svg",
        ),
        width: 100%,
        alt: "!typst-embed-command",
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
  #set text(size: 10pt, fill: theme.colors.foreground.transparentize(25%))
  Last compilation: *#now.display()* | Typst version: *#sys.version* | Deployed to: *GitHub*
]
