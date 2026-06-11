#import "../theming.typ": theme

#let callout-base(
  color-val: theme.colors.overlay,
  fill: auto,
  border: true, // Whether to show a border around the callout
  cont,
) = {
  let stroke-color = color.mix((color-val, 50%), (theme.colors.base, 50%))
  show: block.with(
    stroke: (
      left: color-val + theme.layout.borderWidth.large,
      rest: if border {
        stroke-color + theme.layout.borderWidth.small
      } else {
        none
      },
    ),
    radius: theme.layout.radius.medium,
    fill: if fill == auto {
      color-val.transparentize(92.5%)
    } else {
      fill
    },
    inset: 1em,
    outset: (left: -theme.layout.borderWidth.large / 2),
  )
  cont
}

#let callout-block(
  color-val: theme.colors.overlay,
  heading: none,
  body,
) = {
  callout-base(color-val: color-val, fill: auto)[
    #if heading != none {
      block(
        width: 100%,
        outset: (
          left: 1em - theme.layout.borderWidth.large,
          rest: 1em,
        ),
        fill: color.mix((color-val, 50%), (theme.colors.base, 50%)),
      )[
        #set text(size: 1.1em)
        #heading
      ]
      v(0.5em)
    }

    #set text(fill: color.mix((color-val, 20%), (theme.colors.foreground, 80%)))
    #body
  ]
}

#let quote-callout(
  body,
  attribution: none,
) = {
  callout-base(color-val: theme.colors.muted, fill: none, border: false)[
    #body
    #if attribution != none {
      set text(fill: theme.colors.muted)
      linebreak()
      h(1fr)
      sym.dash
      attribution
    }
  ]
}

#let info-callout = callout-block.with(color-val: theme.colors.info)
#let warning-callout = callout-block.with(color-val: theme.colors.warning)
#let danger-callout = callout-block.with(color-val: theme.colors.danger)
#let success-callout = callout-block.with(color-val: theme.colors.success)
