#import "../../look-and-feel/index.typ": themes
#import "variants.typ": targets-web, theme-name, web-page-width
#import "theming.typ": theme

#let style-footnote(
  footnote,
) = [
  #show: sub
  #set text(fill: theme.colors.muted)
  (#footnote.body)
]

#let set-footnote-style(
  body,
) = {
  set footnote.entry(separator: none, clearance: 0pt, gap: 0pt, indent: 0pt)
  show footnote.entry: none
  show footnote: style-footnote
  body
}

#let style-reference(
  ref,
) = {
  if ref.element != none and ref.element.func() == heading {
    link(ref.target, ref.element.body)
  } else {
    ref
  }
}

#let set-reference-style(
  body,
) = {
  show ref: style-reference
  body
}

#let set-figure-style(
  body,
) = {
  show figure: set figure(supplement: none)
  show figure.caption: set text(fill: theme.colors.muted)
  body
}

#let web-template(
  cont,
) = {
  set page(
    width: if web-page-width != none {
      eval(web-page-width)
    } else {
      640pt
    },
    height: auto,
    fill: white.transparentize(100%),
    margin: if web-page-width != none {
      0pt
    } else {
      1cm
    },
  )
  show pagebreak: none

  show: set-footnote-style
  show: set-reference-style
  show: set-figure-style

  cont
}
