#import "../theming.typ": theme
#import "depth.typ": depth-shadow-block

#let callout-tint(color-val) = {
  color.mix(
    (color-val, 18%),
    (theme.colors.surface, 82%),
  )
}

#let callout-heading-tint(color-val) = {
  color.mix(
    (color-val, 35%),
    (theme.colors.surface, 65%),
  )
}

#let callout-base(
  stroke-color: theme.colors.border,
  fill: theme.colors.surface,
  cont,
) = {
  show: block.with(
    stroke: stroke-color + theme.layout.borderWidth.small,
    radius: theme.layout.radius.medium,
    fill: fill,
    inset: 1em,
  )
  cont
}

#let callout-block(
  color-val: theme.colors.accent,
  heading: none,
  body,
) = {
  show: depth-shadow-block.with(
    color: color-val,
    inner-border: theme.layout.borderWidth.small,
    radius: theme.layout.radius.medium,
  )
  callout-base(stroke-color: color-val)[
    #if heading != none {
      set text(size: 1.05em, weight: "bold")
      set text(fill: color-val)
      heading
    }

    #set text(fill: theme.colors.foreground)
    #body
  ]
}

#let quote-callout(
  body,
  attribution: none,
) = {
  show: depth-shadow-block.with(
    color: theme.colors.neutral,
    inner-border: theme.layout.borderWidth.small,
    radius: theme.layout.radius.small,
  )
  callout-base(stroke-color: theme.colors.neutral, fill: theme.colors.surface)[
    #set text(fill: theme.colors.foreground, style: "italic")
    #body
    #if attribution != none {
      v(0.5em)
      set align(right)
      set text(fill: theme.colors.muted, style: "normal", size: 0.95em)
      sym.dash
      attribution
    }
  ]
}

#let info-callout = callout-block.with(color-val: theme.colors.info)
#let warning-callout = callout-block.with(color-val: theme.colors.warning)
#let danger-callout = callout-block.with(color-val: theme.colors.danger)
#let success-callout = callout-block.with(color-val: theme.colors.success)
