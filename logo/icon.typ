#import "../look-and-feel/theme.typ": current-theme as theme
#import "@preview/suiji:0.5.1" as sj

#let brace-color = theme.colors.secondary.at("200")
#let foreground-color = black
#let font = "Consolas"

#let logo(
  brace-color: brace-color,
  text-color: black,
  background-color: white.transparentize(100%),
) = {
  set text(
    fill: brace-color,
    font: font,
    top-edge: 0.75em,
    bottom-edge: -0.2em,
  )
  {
    set text(fill: text-color, font: "JetBrains Mono", size: 10pt)
    show block: none
    place(center + top, dy: 0.37em)[
      #set align(center)
      #show: box.with(width: 0.55em, height: 0.102em, clip: true)
      T
    ]
  }

  set text(tracking: -0.7pt, stroke: background-color + 0.1pt)
  [}{]

  // place random falling sand
  {
    let rng = sj.gen-rng(5)
    let amount-points = 1000
    let y-vals
    let x-vals
    let sizes
    let roundness
    (rng, y-vals) = sj.normal(rng, scale: 2, size: amount-points)
    (rng, x-vals) = sj.uniform(rng, low: -0.4, high: 0.4, size: amount-points)
    (rng, sizes) = sj.uniform(rng, low: 0.05, high: 0.1, size: amount-points)
    (rng, roundness) = sj.normal(rng, loc: 0.5, scale: 0.1, size: amount-points)
    for (x, y, size, roundness) in array.zip(
      x-vals.map(calc.round.with(digits: 1)),
      y-vals.map(calc.abs).map(calc.round.with(digits: 1)),
      sizes.map(it => 0.11),
      roundness.map(it => 0),
    ) {
      if (y > 5.75) {
        continue
      }
      place(bottom + center, dx: x * 1pt, dy: -5.725pt + y * 1pt)[
        #rect(
          width: size * 1pt,
          height: size * 1pt,
          fill: text-color,
          radius: roundness * 100%,
        )
      ]
    }
  }
}

#set page(
  margin: 0.2pt,
  height: auto,
  width: auto,
  fill: white.transparentize(100%),
)

#logo(
  background-color: white,
)
