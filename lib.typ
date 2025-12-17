#let is-dark = sys.inputs.at("theme", default: "") == "dark"
#let now = sys.inputs.at("now", default: datetime.today(offset: 0))

#let themed(light-variant, dark-variant) = if is-dark { dark-variant } else { light-variant }

/// HTML extension
#let xhtml(outer-width: 160pt, outer-height: 90pt, inner-width: none, inner-height: none, content) = context {
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

  let html-embed = {
    "<svg viewBox=\"0 0 "
    str(inner-width.pt())
    " "
    str(inner-height.pt())
    "\" "
    "xmlns=\"http://www.w3.org/2000/svg\" "
    "xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">"
    "<foreignObject x=\"0\" y=\"0\" width=\""
    str(inner-width.pt())
    "\" height=\""
    str(inner-height.pt())
    "\">"
    content
    "</foreignObject>"
    "</svg>"
  }

  image(bytes(html-embed), alt: "!typst-embed-command", width: outer-width, height: outer-height)
}