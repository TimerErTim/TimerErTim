#import "theming.typ": theme
#import "deps.typ": easy-hgb-thesis
#import easy-hgb-thesis: *
#import "components.typ": build-references

#let intro-page() = context [
  #{
    set text(size: theme.layout.fontSize.large)
    document.title
  }

  #{
    set text(size: theme.layout.fontSize.small, fill: theme.colors.muted)
    document.author.join(", ")
  }

  #{
    set text(size: theme.layout.fontSize.small)
    document.description
  }
]

#let content-outline() = {
  outline(title: "Table of Contents")
}

#let style-link(it) = {
  show: underline
  set text(fill: theme.colors.info)
  it
}

#let pdf-template(
  cont,
  bibl: none,
) = context {
  let font = text.font
  show: full-thesis.with(
    titlepage: none,
    thesis-style: THESIS_STYLE.modern,
    include-declaration: false,
    include-figureoutline: false,
    include-tableoutline: false,

    kurzfassung: none,
    abstract: context document.description,

    bibl: build-references(bibl: bibl),

    global-style: it => {
      set text(font: font)
      it
    },
    content-style: it => {
      show link: style-link
      set figure(placement: auto)
      set cite(form: "prose")
      it
    },
    bibliography-style: it => {
      show link: style-link
      it
    },
    abstract-style: it => {
      set page(numbering: "I")
      heading(level: 1)[Description]
      show heading.where(level: 1): none
      set heading(outlined: false)
      it
    },
  )

  cont
}
