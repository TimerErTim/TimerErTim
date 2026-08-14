#import "../theming.typ": theme
#import "../variants.typ": targets-web

#let depth-shadow-block(
  color: theme.colors.shadow,
  depth: theme.layout.depth.medium,
  radius: theme.layout.radius.medium,
  fill: theme.colors.base,
  inner-border: 0pt,
  cont,
) = context if targets-web.get() {
  block(
    fill: color,
    radius: radius,
    breakable: true,
    outset: (
      top: inner-border / 2,
      left: inner-border / 2,
      right: depth * 2 + inner-border / 2,
      bottom: depth * 2 + inner-border / 2,
    ),
    block(fill: fill, radius: radius, clip: true, align(left + top, cont)),
  )
} else {
  // no shadow for pdf
  cont
}
