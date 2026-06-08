#import "theming.typ": theme

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

#let pdf-template(
  cont,
) = {
  set page(
    paper: "a4",
    margin: (top: 2cm, x: 2cm, bottom: 2.5cm),
    fill: theme.colors.base,
  )
  intro-page()
  line(length: 100%, stroke: theme.colors.border)

  // Only show outline if we have more than 3 pages
  context if counter(page).final().first() > 3 {
    pagebreak()
    content-outline()
    pagebreak()
  }

  set heading(numbering: "1.1")

  cont
}
