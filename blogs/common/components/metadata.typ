#let blog-metadata(
  created-at: datetime.today(),
  updated-at: auto,
) = context [
  #let unix-epoch-date = datetime(year: 1970, month: 1, day: 1)
  #let updated-at = if updated-at == auto {
    created-at
  } else {
    updated-at
  }
  #metadata(document.title.text) <blog-title-meta>
  #metadata(document.description.text) <blog-description-meta>
  #metadata(document.author) <blog-author-meta>
  #metadata(document.keywords) <blog-keywords-meta>
  #metadata(int(
    (created-at - unix-epoch-date).seconds(),
  )) <blog-created-at-meta>
  #metadata(int(
    (updated-at - unix-epoch-date).seconds(),
  )) <blog-updated-at-meta>
]
