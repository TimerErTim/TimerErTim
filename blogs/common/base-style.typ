#import "components/callouts.typ": quote-callout
#import "theming.typ": catppuccin-accents, catppuccin-flavor, theme, themes
#import "components/depth.typ": depth-shadow-block
#import "variants.typ": light-or, web-or
#import "deps.typ": catppuccin, codly, codly-init, codly-languages
#import "components/pikchr.typ": pikchr-init

#let set-text-style(
  body,
) = {
  set text(
    fill: theme.colors.foreground,
    font: theme.fonts.sans.family,
    size: web-or(
      theme.layout.fontSize.small,
      theme.layout.fontSize.tiny, // Tiny font for pdf
    ),
  )

  set par(leading: theme.layout.lineHeight.tiny / 11pt * 1em - 0.8em)

  body
}

#let set-equation-style(
  body,
) = {
  show math.equation: set text(font: theme.fonts.math.family)
  set math.equation(numbering: "(1")

  body
}

#let style-link(
  it,
) = {
  show: strong
  set text(fill: theme.colors.info)
  underline(
    it,
    stroke: theme.colors.shadow + theme.layout.borderWidth.small,
    offset: theme.layout.borderWidth.large,
  )
}

#let style-quote(
  quote,
) = {
  if quote.block == true {
    show: quote-callout.with(attribution: quote.attribution)
    quote.body
  } else {
    quote
  }
}

#let style-raw(
  raw,
) = {
  if raw.block == true {
    show block.where(
      radius: theme.layout.radius.medium,
      width: 100%,
    ): depth-shadow-block.with(
      color: theme.colors.border,
      inner-border: theme.layout.borderWidth.small,
    )
    raw
  } else {
    show: box.with(inset: (x: theme.layout.borderWidth.small))
    show: highlight.with(
      radius: theme.layout.radius.small,
      fill: theme.colors.surface.mix(theme.colors.muted),
      extent: theme.layout.borderWidth.medium,
    )
    raw.text
  }
}

#let set-raw-style(
  body,
) = {
  show: catppuccin.set-code-theme.with(
    catppuccin-flavor,
  )
  show raw: set text(font: theme.fonts.mono.family)
  show: codly-init.with()
  show raw: style-raw
  codly(
    languages: codly-languages,
    lang-format: (name, icon, color) => {
      set text(fill: theme.colors.foreground, weight: "bold", size: 0.9em)
      show: pad.with(right: theme.layout.radius.small)
      set align(horizon)
      show: box.with(
        fill: color.mix((theme.colors.surface, 70%), (color, 30%)),
        height: 1em,
        inset: 1pt,
        outset: 2pt,
        radius: theme.layout.radius.small,
      )
      [#web-or(none, icon) #name]
    },
    smart-indent: true,
    number-align: left + horizon,
    zebra-fill: none,
    fill: theme.colors.surface,
    stroke: theme.colors.border + theme.layout.borderWidth.small,
    radius: theme.layout.radius.medium,
    smart-skip: true,
    skip-number: align(center)[#sym.dots.v],
    default-color: catppuccin-accents.blue,
    highlight-radius: theme.layout.radius.small,
    highlight-fill: color => color.mix(
      (theme.colors.surface, 60%),
      (color, 40%),
    ),
    reference-sep: ":",
    breakable: false,
  )

  body
}

#let set-heading-style(
  body,
) = {
  show heading.where(level: 1): it => {
    v(1.5em, weak: true)
    set text(size: 1.6em, weight: "bold")
    it
    v(0.75em, weak: true)
  }
  show heading.where(level: 2): it => {
    v(1.25em, weak: true)
    set text(size: 1.25em, weight: "bold")
    it
    v(0.5em, weak: true)
  }
  show heading.where(level: 3): it => {
    v(1em, weak: true)
    set text(size: 1.1em, weight: "bold")
    it
    v(0.35em, weak: true)
  }

  body
}

#let base-style(
  cont,
) = {
  show: set-text-style
  show: set-heading-style
  show: set-equation-style
  show: set-raw-style
  show link: style-link
  show quote: style-quote
  show: pikchr-init

  set rect(stroke: theme.colors.shadow + theme.layout.borderWidth.small)
  show figure: align.with(left)
  show figure.caption: set text(
    size: theme.layout.fontSize.tiny,
    fill: theme.colors.muted,
  )

  cont
}
