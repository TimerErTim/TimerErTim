#import "colors.typ": colors
#import "layout.typ": layout
#import "fonts.typ": fonts

#let themes = (
  layout: layout,
  fonts: fonts,
  ..colors,
)

#let get-theme(theme) = (
  layout: layout,
  fonts: fonts,
  colors: colors.at(theme),
)
