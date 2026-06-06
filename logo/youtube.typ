#import "icon.typ": logo
#import "../look-and-feel/index.typ": themes

#let background-color = themes.dark.base
#let secondary-color = themes.dark.accent
#let dark-logo(
  background-color: background-color,
) = logo(
  brace-color: themes.dark.foreground,
  text-color: secondary-color,
  background-color: background-color,
)

#set page(
  margin: 1pt,
  height: auto,
  width: auto,
  fill: gradient.radial(themes.dark.surface, background-color),
)

#show: circle.with(inset: -0.25pt, stroke: secondary-color + 0.25pt)
#set align(center + horizon)
#show: box
#dark-logo()
