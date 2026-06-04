#let blog-metadata() = context [
  #metadata(document.title.text) <blog-title-meta>
  #metadata(document.description.text) <blog-description-meta>
  #metadata(document.author) <blog-author-meta>
  #metadata(document.keywords) <blog-keywords-meta>
]