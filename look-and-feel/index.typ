#import "colors.typ": colors
#import "layout.typ": layout

#let themes = (
  layout: layout,
  ..colors,
)

#let get-theme(theme) = (
  layout: layout,
  ..colors.at(theme),
)
