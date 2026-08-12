#import "base-style.typ": base-style
#import "web-style.typ": web-template
#import "pdf-style.typ": pdf-template
#import "components/metadata.typ": blog-metadata
#import "variants.typ": is-preview, targets-web, web-or

#let build-references(bibl: none) = context {
  let is-targeting-web = targets-web.get()
  let links-in-doc = query(selector(link).before(here()))
    .map(it => it.dest)
    .filter(it => type(it) == str)
    .dedup()

  set bibliography(title: [References], style: "iso-690-numeric")
  set bibliography(style: "chicago-notes") if is-targeting-web
  let links-in-bibl = ()
  if bibl != none [
    #bibl <_blog-user-bibl>
    #{
      links-in-bibl = query(selector(link).within(label("_blog-user-bibl")))
        .map(it => it.dest)
        .filter(it => type(it) == str)
        .dedup()
    }
  ]
  set bibliography(title: none) if bibl != none
  let links-in-doc-not-in-bibl = links-in-doc.filter(it => {
    not links-in-bibl.contains(it)
  })

  let hayagriva-values = links-in-doc-not-in-bibl
    .map(it => (
      type: "web",
      url: it,
    ))
    .enumerate()
    .map(((idx, it)) => ("_link-" + str(idx), it))
    .to-dict()
  let links-hayagriva-yaml = yaml.encode(hayagriva-values)

  show: it => context if bibl != none {
    set bibliography(style: query(label("_blog-user-bibl")).first().style)
    it
  } else {
    it
  }
  bibliography(bytes(links-hayagriva-yaml), full: true)
}

#let blog-content(
  cont,
  bibl: none,
) = context {
  cont

  // Show references
  build-references(bibl: bibl)
}

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
    web-template(it)
  } else {
    pdf-template(it)
  }

  show: blog-content.with(
    bibl: bibl,
  )
  cont
}

