// Main color config, derived colors further down below
#let _colors = (
  "light": (
    "base": oklch(98%, 1%, 265deg),
    "foreground": oklch(44%, 4%, 279deg).darken(50%),
    "accent": rgb("#62a123").oklch(),
    "neutral": oklch(86%, 1%, 268deg),
    "surface": oklch(93%, 1%, 265deg),
    "overlay": oklch(91%, 1%, 265deg),
    "border": oklch(71%, 2%, 275deg),
    "danger": oklch(46.8%, 0.147, 24.86deg),
    "warning": oklch(71%, 15%, 68deg),
    "success": oklch(63%, 18%, 140deg),
    "info": oklch(64.41%, 0.065, 235.88deg), // Info is also used for links
  ),
  "dark": (
    "base": oklch(18%, 2%, 284deg),
    "foreground": oklch(88%, 4%, 272deg).lighten(50%),
    "accent": rgb("#426E17").oklch(),
    "neutral": oklch(40%, 3%, 280deg),
    "surface": oklch(22%, 3%, 284deg),
    "overlay": oklch(24%, 3%, 284deg),
    "border": oklch(55%, 3%, 277deg),
    "danger": oklch(76%, 13%, 3deg),
    "warning": oklch(92%, 7%, 87deg),
    "success": oklch(86%, 11%, 143deg),
    "info": oklch(85%, 8%, 210deg), // Info is also used for links
  ),
)

#let _calc_muted(colorset) = {
  return colorset.foreground.mix((colorset.base, 100%))
}

#let _process_colors(colorset) = {
  return (
    ..colorset,
    "muted": _calc_muted(colorset),
  )
}

// Merge colors for all themes
#let colors = (
  "light": _process_colors(_colors.at("light")),
  "dark": _process_colors(_colors.at("dark")),
)
