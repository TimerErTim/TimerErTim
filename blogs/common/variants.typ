#let input-targets-web = sys.inputs.at("x-target", default: "classic") == "web"
#let input-is-pdf = sys.inputs.at("x-format", default: "") == "pdf"
#let input-web-page-width = sys.inputs.at("x-page-width", default: none)
#let input-theme-name = sys.inputs.at("x-theme", default: "light")
#let input-is-preview = sys.inputs.at("x-preview", default: false) != false

// Public exports
#let is-preview = input-is-preview
#let web-page-width = input-web-page-width

// State for targets
#let targets-web = state("_bl_targets-web", input-targets-web)

#let web-or(
  web-variant,
  classic-variant,
) = context if targets-web.get() {
  web-variant
} else {
  classic-variant
}

#let web-only = it => web-or(it, none)
#let non-web-only = web-or.with(none)

#let light-or(
  light-variant,
  dark-variant,
) = if input-theme-name == "light" {
  light-variant
} else {
  dark-variant
}

#let in-preview-or(
  in-preview-variant,
  not-in-preview-variant,
) = if input-is-preview {
  in-preview-variant
} else {
  not-in-preview-variant
}

#let hide-in-preview = in-preview-or.with(none)
#let only-in-preview = it => in-preview-or(it, none)

/// Checks webpage width, if not webpage with, some is always returned
#let broader-than(
  width,
  some,
  fallback,
) = {
  if input-web-page-width == none or eval(input-web-page-width) >= width {
    some
  } else {
    fallback
  }
}
