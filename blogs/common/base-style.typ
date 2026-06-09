#import "../../look-and-feel/index.typ":
#import "components/metadata.typ": blog-metadata
#import "components/callouts.typ": quote-callout
#import "theming.typ": catppuccin-flavor, theme, themes
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
  link,
) = {
  show: strong
  underline(link, stroke: theme.colors.info + 1pt)
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
  set text(font: theme.fonts.mono.family)
  
  if raw.block == true {
    raw
  } else {
    show: highlight.with(
      fill: theme.colors.surface,
      extent: theme.layout.borderWidth.medium,
    )
    show: box.with(inset: (x: theme.layout.borderWidth.medium))
    raw.text
  }
}

#let set-raw-style(
  body,
) = {
  show: catppuccin.set-code-theme.with(
    catppuccin-flavor,
  )
  show raw: style-raw
  show: codly-init.with()
  codly(
    languages: codly-languages,
    lang-format: (name, icon, color) => {
      set text(fill: themes.light.foreground)
      show: box.with(
        inset: theme.layout.borderWidth.medium,
        stroke: color + theme.layout.borderWidth.small / 2,
        radius: theme.layout.radius.small,
        fill: color.lighten(80%),
        height: 1.2em
      )
      [#web-or(none, icon) #name]
    },
    smart-indent: true,
    number-align: left + horizon,
    zebra-fill: none,
    fill: theme.colors.surface,
    stroke: stroke(theme.colors.border),
    radius: theme.layout.radius.large,
    breakable: false,
  )

  body
}

#let base-style(
  cont,
) = {
  blog-metadata()
  show: set-text-style

  show: set-equation-style
  show: set-raw-style
  show link: style-link
  show quote: style-quote
  show: pikchr-init

  set rect(stroke: theme.colors.border)
  show figure: align.with(left)
  show figure.caption: set text(size: theme.layout.fontSize.tiny)

  cont
}
