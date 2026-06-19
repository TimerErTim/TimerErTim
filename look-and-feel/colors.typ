// Main color config, derived colors further down below
#let _colors = (
  "light": (
    "base": oklch(99%, 4%, 92deg),
    "foreground": oklch(14%, 4%, 280deg),
    "accent": oklch(62%, 30%, 130deg),
    "neutral": oklch(84%, 6%, 90deg),
    "surface": oklch(99%, 4%, 92deg),
    "overlay": oklch(93%, 10%, 86deg),
    "border": oklch(14%, 4%, 280deg),
    "danger": oklch(50%, 28%, 25deg),
    "warning": oklch(72%, 26%, 62deg),
    "success": oklch(54%, 26%, 145deg),
    "info": oklch(54%, 22%, 235deg),
  ),
  "dark": (
    "base": oklch(15%, 3%, 280deg),
    "foreground": oklch(95%, 3%, 280deg),
    "accent": oklch(76%, 28%, 130deg),
    "neutral": oklch(30%, 4%, 280deg),
    "surface": oklch(15%, 3%, 280deg),
    "overlay": oklch(22%, 6%, 285deg),
    "border": oklch(95%, 3%, 280deg),
    "danger": oklch(74%, 22%, 22deg),
    "warning": oklch(80%, 20%, 72deg),
    "success": oklch(72%, 22%, 145deg),
    "info": oklch(72%, 18%, 220deg),
  ),
)

#let _calc_muted(colorset) = {
  return colorset.foreground.mix((colorset.base, 100%))
}

#let _calc_shadow(colorset) = {
  return colorset.foreground
}

#let _process_colors(colorset) = {
  return (
    ..colorset,
    "muted": _calc_muted(colorset),
    "shadow": _calc_shadow(colorset),
  )
}

// Merge colors for all themes
#let colors = (
  "light": _process_colors(_colors.at("light")),
  "dark": _process_colors(_colors.at("dark")),
)
