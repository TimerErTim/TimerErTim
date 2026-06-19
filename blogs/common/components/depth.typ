#import "../theming.typ": theme

#let depth-shadow-block(
  color: theme.colors.shadow,
  depth: theme.layout.depth.medium,
  radius: theme.layout.radius.medium,
  fill: theme.colors.base,
  inner-border: 0pt,
  cont,
) = block(
  fill: color,
  radius: radius,
  breakable: false,
  outset: (
    top: inner-border / 2,
    left: inner-border / 2,
    right: depth * 2 + inner-border / 2,
    bottom: depth * 2 + inner-border / 2,
  ),
  align(left + top, cont),
)
