#import "../../look-and-feel/index.typ": themes
#import "@preview/suiji:0.5.1" as sj

#set page(
  width: 2048pt * 1.5,
  height: 1152pt * 1.5,
  margin: 256pt,
  fill: white,
  background: {
    let rng = sj.gen-rng(42)
    let amount-points = 100
    let x-offsets
    let y-offsets
    (rng, x-offsets) = sj.uniform(rng, low: 0, high: 1, size: amount-points)
    (rng, y-offsets) = sj.uniform(rng, low: 0, high: 1, size: amount-points)
    for (x, y) in array.zip(x-offsets, y-offsets) {
      let color-counts = 2
      let colors
      (rng, colors) = sj.choice(rng, (
        themes.light.accent,
        themes.light.info,
        themes.light.warning,
      ), size: color-counts)
      let transparencies
      (rng, transparencies) = sj.normal(rng, loc: 0.6, scale: 2, size: color-counts)

      let colors = colors.zip(transparencies.map(it => 100% * calc.clamp(it, 0.4, 0.7))).map(((color, transparency)) => color.transparentize(transparency))

      let radius
      (rng, radius) = sj.uniform(rng, low: 64, high: 256)
      radius = radius * 1pt
      place(left + top, dx: x * 100% - radius / 2, dy: y * 100% - radius / 2)[
        #circle(radius: radius, 
          fill: gradient.radial(
            ..colors,
            white.transparentize(100%),
          ),
        )
      ]
    }
  }
)

#set align(center + horizon)
#image("../identity/banner.png", width: 70%)