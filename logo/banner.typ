#import "icon.typ": logo, font, brace-color, foreground-color


#set page(
  margin: (x: 2pt, y: 5pt),
  height: auto,
  width: auto,
  fill: white.transparentize(100%),
)

#{
  show: place.with(center + horizon, dy: 0em)
  show: scale.with(x: 100%, y: 60%, reflow: true)
  show: rotate.with(90deg, reflow: true)
  set text(font: font, top-edge: 0.75em, bottom-edge: -0.2em, tracking: 1pt, fill: brace-color)
  [}{]
}

#{
  show: place.with(horizon + left, dx: -1pt)
  //show: box
  scale(box(logo(background-color: white)), 30%, reflow: true)
}
#show: pad.with(left: 2pt)
#show: box
#set text(size: 4pt, font: "Roboto", fill: foreground-color, tracking: -0.5pt)
#let text-size(x-pos) = {
  calc.min(calc.max(0.3pt, 1.5pt - x-pos.pt() * 0.22pt), 0.8pt)
}
#show regex("."): it => context {
  let size = text-size(here().position().x)
  show: box.with(height: 1pt, inset: (x: -0.00pt))
  set align(horizon)
  // place(horizon, dy:` -size)[
  //   //#circle(radius: 0.1pt, fill: red)
  // ]`
  set text(size: size * 5)
  it
}
imerErTim
