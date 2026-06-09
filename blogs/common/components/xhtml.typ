#import "../variants.typ": is-pdf, targets-web

/// HTML extension
#let xhtml(
  outer-width: 160pt,
  outer-height: 90pt,
  inner-width: none,
  inner-height: none,
  cont,
) = {
  // From https://github.com/Myriad-Dreamin/typst.ts/blob/main/contrib/templates/xhtml/lib.typ
  let content = if type(cont) == content {
    cont.text
  } else {
    cont
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

    let (inner-width, inner-height) = resolve-relative(
      inner-width,
      inner-height,
    )
    let (outer-width, outer-height) = resolve-relative(
      outer-width,
      outer-height,
    )

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

    if (
      targets-web and is-pdf
    ) {
      show: pdf.artifact
      show: box.with(width: outer-width, height: outer-height)
      html-embed
    } else {
      image(
        bytes(html-embed),
        alt: "!typst-embed-command",
        width: outer-width,
        height: outer-height,
      )
    }
  })
}
