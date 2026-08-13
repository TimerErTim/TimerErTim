#import "../../look-and-feel/index.typ": themes
#import "variants.typ": input-theme-name, input-web-page-width
#import "theming.typ": theme
#import "components.typ": build-references

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
  } else if ref.element != none and ref.element.func() == figure {
    link(ref.target, ref.element.caption.body)
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

#let set-heading-style(
  body,
) = {
  show heading.where(level: 1): set text(size: 1.4em)
  show heading.where(level: 2): set text(size: 1.25em)
  show heading.where(level: 3): set text(size: 1.15em)
  show heading.where(level: 4): set text(size: 1.10em)

  show heading: set block(above: 1em, below: 0.7547em)

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

#let web-template(
  cont,
  bibl: none,
) = {
  set page(
    width: if input-web-page-width != none {
      eval(input-web-page-width)
    } else {
      640pt
    },
    height: auto,
    fill: white.transparentize(100%),
    margin: if input-web-page-width != none {
      0pt
    } else {
      1cm
    },
  )
  show pagebreak: none

  show: set-footnote-style
  show: set-reference-style
  show: set-figure-style
  show: set-heading-style
  show link: style-link

  cont

  build-references(bibl: bibl)
}
