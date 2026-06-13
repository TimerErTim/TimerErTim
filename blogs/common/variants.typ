#let targets-web = sys.inputs.at("x-target", default: "classic") == "web"
#let is-pdf = sys.inputs.at("x-format", default: "") == "pdf"
#let web-page-width = sys.inputs.at("x-page-width", default: none)
#let theme-name = sys.inputs.at("x-theme", default: "light")
#let is-preview = sys.inputs.at("x-preview", default: false) != false

#let web-or(
  web-variant,
  classic-variant,
) = if targets-web {
  web-variant
} else {
  classic-variant
}

#let light-or(
  light-variant,
  dark-variant,
) = if theme-name == "light" {
  light-variant
} else {
  dark-variant
}

#let hide-in-preview(
  cont,
) = if is-preview {
  none
} else {
  cont
}

/// Checks webpage width, if not webpage with, some is always returned
#let broader-than(
  width,
  some,
  fallback,
) = {
  if web-page-width == none or eval(web-page-width) >= width {
    some
  } else {
    fallback
  }
}
