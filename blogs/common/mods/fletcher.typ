#import "../deps.typ": fl
#import "../theming.typ": theme
#import "../variants.typ": in-preview-or
#import fl: *

#let diagram = fl.diagram.with(
  debug: in-preview-or(3, false),
  node-fill: theme.colors.base,
  node-stroke: theme.colors.border + theme.layout.borderWidth.small,
  edge-stroke: theme.colors.foreground,
  crossing-fill: theme.colors.base,
  crossing-thickness: 4,
)
