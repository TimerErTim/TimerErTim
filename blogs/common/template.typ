#import "base-style.typ": base-style
#import "web-style.typ": web-template
#import "pdf-style.typ": pdf-template
#import "components/metadata.typ": blog-metadata
#import "variants.typ": web-or

#let blog-entry(
  cont,
  target: auto,
  created-at: datetime.today(),
  updated-at: datetime.today(),
) = {
  blog-metadata(
    created-at: created-at,
    updated-at: updated-at,
  )
  show: base-style
  show: if target == auto {
    web-or(
      web-template,
      pdf-template,
    )
  } else if target == "web" {
    web-template
  } else if target == "pdf" {
    pdf-template
  }
  cont
}
