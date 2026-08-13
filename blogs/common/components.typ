#import "variants.typ": targets-web

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
