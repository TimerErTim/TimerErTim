#sys.inputs

/// HTML extension
#let xhtml1(
  outer-width: 160pt,
  outer-height: 90pt,
  inner-width: none,
  inner-height: none,
  content,
) = context {
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

  // Directly wrap the content in a <div> with the correct xhtml namespace,
  // so the SVG foreignObject doesn't need to (and shouldn't) set it again.
  let html-embed = {
    "<svg viewBox=\"0 0 "
    str(inner-width.pt())
    " "
    str(inner-height.pt())
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

  image(
    bytes(html-embed),
    alt: "!typst-embed-command",
    width: outer-width,
    height: outer-height,
  )
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
    str(inner-width.pt())
    " "
    str(inner-height.pt())
    "\""
    " width=\""
    str(outer-width.pt())
    "\" height=\""
    str(outer-height.pt())
    "\" xmlns=\"http://www.w3.org/2000/svg\">"
    if sys.inputs.at("target", default: "web") == "web" {
      "<foreignObject width=\""
      str(inner-width.pt())
      "\" height=\""
      str(inner-height.pt())
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

#xhtml(tag: "div", attributes: (style: "width: 1cm; height: 1cm; background-color: red;"))

#xhtml1(```html
<div style="width: 1cm; height: 1cm; background-color: red;">
</div>
```)

#let pro-tip-box(content) = {
  show: box.with(stroke: 1pt + yellow, radius: 0.5em, fill: yellow.lighten(90%), inset: 1em)
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
  <iframe src="https://www.youtube.com/embed/iPo_88PNudI?si=ijimNYVrwhzBxJe0" title="YouTube video player" width="560" height="315" />
  ```)
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
