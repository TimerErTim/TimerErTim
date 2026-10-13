#import "../theming.typ": theme
#import "../variants.typ": targets-web

#let depth-shadow-block(
  color: theme.colors.shadow,
  depth: theme.layout.depth.medium,
  radius: theme.layout.radius.medium,
  fill: theme.colors.base,
  inner-border: 0pt,
  clip: true,
  cont,
) = context if targets-web.get() {
  block(
    fill: color,
    radius: radius,
    breakable: true,
    outset: (
      top: inner-border,
      left: inner-border,
      right: depth * 2 + inner-border,
      bottom: depth * 2 + inner-border,
    ),
    block(fill: fill, radius: radius, clip: clip, align(left + top, cont)),
  )
} else {
  // no shadow for pdf
  cont
}
