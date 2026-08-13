#import "base-style.typ": base-style
#import "web-style.typ": web-template
#import "pdf-style.typ": pdf-template
#import "components/metadata.typ": blog-metadata
#import "variants.typ": is-preview, targets-web, web-or

#let blog-entry(
  cont,
  target: auto,
  created-at: datetime.today(),
  updated-at: auto,
  bibl: none,
) = {
  blog-metadata(
    created-at: created-at,
    updated-at: updated-at,
  )
  show: base-style

  // Set style target (only in preview)
  if is-preview {
    if target == "web" {
      targets-web.update(true)
    } else if target == "pdf" {
      targets-web.update(false)
    }
  }
  show: it => context if targets-web.get() {
    web-template(it, bibl: bibl)
  } else {
    pdf-template(it, bibl: bibl)
  }

  cont
}

