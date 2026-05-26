#import "icon.typ": logo
#import "../look-and-feel/theme.typ": load-theme

#let dark-theme = load-theme("dark")

#let background-color = dark-theme.colors.background
#let secondary-color = dark-theme.colors.secondary.at("400")
#let dark-logo(
  background-color: background-color,
) = logo(
  brace-color: secondary-color,
  text-color: dark-theme.colors.secondary.at("900"),
  background-color: background-color,
)

#set page(
  margin: 1pt,
  height: auto,
  width: auto,
  fill: background-color,
)

#show: circle.with(inset: -0.25pt, stroke: secondary-color + 0.25pt)
#set align(center + horizon)
#show: box
#dark-logo()
