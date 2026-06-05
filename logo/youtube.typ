#import "icon.typ": logo
#import "../look-and-feel/index.typ": themes

#let background-color = themes.dark.colors.base
#let secondary-color = themes.dark.colors.accent
#let dark-logo(
  background-color: background-color,
) = logo(
  brace-color: themes.dark.colors.text,
  text-color: secondary-color,
  background-color: background-color,
)

#set page(
  margin: 1pt,
  height: auto,
  width: auto,
  fill: gradient.radial(themes.dark.colors.surface, background-color),
)

#show: circle.with(inset: -0.25pt, stroke: secondary-color + 0.25pt)
#set align(center + horizon)
#show: box
#dark-logo()
