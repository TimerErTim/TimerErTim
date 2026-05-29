#let is-web = sys.inputs.at("x-target", default: "classic") == "web"
#let web-page-width = sys.inputs.at("x-page-width", default: none)
#let web-theme = sys.inputs.at("x-theme", default: "light")

#set document(
  title: "Typst Talk",
  description: "A talk about Typst, hi Nathalie",
  author: "John Doe",
  keywords: ("Typst", "Talk"),
)
#let blog-metadata() = context [
  #metadata(document.title.text) <blog-title-meta>
  #metadata(document.description.text) <blog-description-meta>
  #metadata(document.author) <blog-author-meta>
  #metadata(document.keywords) <blog-keywords-meta>
]
#blog-metadata()
#set page(
  width: eval(web-page-width),
  height: auto,
  fill: white.transparentize(100%),
) if is-web


/// HTML extension
#let xhtml1(
  outer-width: 160pt,
  outer-height: 90pt,
  inner-width: none,
  inner-height: none,
  content,
) = {
  // From https://github.com/Myriad-Dreamin/typst.ts/blob/main/contrib/templates/xhtml/lib.typ
  let t = content.func()
  let content = if content.func() == raw {
    content.text
  } else {
    content
  }

  let inner-width = if inner-width == none {
    outer-width
  } else {
    inner-width
  }

  let inner-height = if inner-height == none {
    outer-height
  } else {
    inner-height
  }

   layout(((width: par-width, height: par-height)) => {
    let resolve-relative(width, height) = {
  let (width-ratio, width-length) = if type(width) == length {
    (0%, width)
  } else if type(width) == ratio {
    (width, 0pt)
  } else {
    (width.ratio, width.length)
  }

  let (height-ratio, height-length) = if type(height) == length {
    (0%, height)
  } else if type(height) == ratio {
    (height, 0pt)
  } else {
    (height.ratio, height.length)
  }

  let width-par-length = width-ratio * par-width + width-length
  let height-par-length = height-ratio * par-height + height-length

  return (width-par-length.to-absolute(), height-par-length.to-absolute())
    }

  let (inner-width, inner-height) = resolve-relative(inner-width, inner-height)
  let (outer-width, outer-height) = resolve-relative(outer-width, outer-height)

  // Directly wrap the content in a <div> with the correct xhtml namespace,
  // so the SVG foreignObject doesn't need to (and shouldn't) set it again.
  let html-embed = {
    "<svg viewBox=\"0 0 "
    str(inner-width.pt())
    " "
    str(inner-height.pt())
    "\" "
    "width=\""
    str(outer-width.pt())
    "\" height=\""
    str(outer-height.pt())
    "\" "
    "xmlns=\"http://www.w3.org/2000/svg\">"
    "<foreignObject x=\"0\" y=\"0\" width=\""
    str(inner-width.pt())
    "\" height=\""
    str(inner-height.pt())
    "\">"
    "<div xmlns=\"http://www.w3.org/1999/xhtml\" style=\"display: contents;\">"
    content
    "</div>"
    "</foreignObject>"
    "</svg>"
  }

  if sys.inputs.at("x-format", default: "") == "pdf" and sys.inputs.at("x-target", default: "web") == "web" {
    show: pdf.artifact
    show: box.with(width: outer-width, height: outer-height)
    html-embed
  }

  image(
    bytes(html-embed),
    alt: "!typst-embed-command",
    width: outer-width,
    height: outer-height,
  )
})

}

/// HTML extension
#let xcommand(outer-width: 1024pt, outer-height: 768pt, inner-width: none, inner-height: none, content) = {
  let content = if type(content) == str {
    content
  } else if content.func() == raw {
    content.text
  } else {
    content
  }

  let inner-width = if inner-width == none {
    outer-width
  } else {
    inner-width
  }

  let inner-height = if inner-height == none {
    outer-height
  } else {
    inner-height
  }

  let html-embed = {
    "<svg viewBox=\"0 0 "
    str(inner-width.to-absolute().pt())
    " "
    str(inner-height.to-absolute().pt())
    "\""
    " width=\""
    str(outer-width.to-absolute().pt())
    "\" height=\""
    str(outer-height.to-absolute().pt())
    "\" xmlns=\"http://www.w3.org/2000/svg\">"
    if sys.inputs.at("target", default: "web") == "web" {
      "<foreignObject width=\""
      str(inner-width.to-absolute().pt())
      "\" height=\""
      str(inner-height.to-absolute().pt())
      "\"><!-- embedded-content "
      content
      " embedded-content --></foreignObject>"
    }
    "</svg>"
  }

  image(bytes(html-embed), format: "svg", alt: "!typst-embed-command")
}

#let xhtml(..args, tag: none, attributes: (:)) = context if sys.inputs.at("target", default: "web") == "web" {
  xcommand(
    {
      "html,"
      json.encode((
        tag: ("xhtml:", tag).join(),
        attributes: attributes,
      ))
    },
    ..args,
  )
} else {
  // outer-width: 1024pt, outer-height: 768pt, inner-width: none, inner-height: none,
  html.elem(tag, attrs: attributes)
}

#xhtml1(```html
<div style="width: 1cm; height: 1cm; background-color: blue;">
</div>
```)

#let pro-tip-box(content) = {
  show: box.with(stroke: 1pt + yellow, radius: 0.5em, fill: yellow.lighten(80%), inset: 1em)
  {
    set text(fill: black, font: "JetBrains Mono", size: 1.2em)
    [Protip Box]
  }
  parbreak()
  content
}

#pro-tip-box[
  This is a tip we want to see in our exported document.

  Maybe even html text? #xhtml1(```html
  <p>Test from html</p>
  <iframe width="560" height="315" src="https://www.youtube.com/embed/iPo_88PNudI?si=bFFhLu0I2FFMNB-D" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen="true"></iframe>
  ```, outer-width: 100%, outer-height: 315pt, inner-width: 560pt, inner-height: 330pt)
]

#let single(any) = (any,)

#show link: it => {
  set text(fill: blue)
  underline(it)
}

Let's add a #link("https://lilaq.org/")[lilaq] diagram for good measure:\
#import "@preview/lilaq:0.6.0" as lq
#lq.diagram(
  title: [Sample Plot],
  lq.plot(
    range(10),
    x => x * x / calc.exp(x),
    smooth: true
  )
)
