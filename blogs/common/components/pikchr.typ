#import "../deps.typ": kip as _raw_pikchr, strfmt
#import "../theming.typ": catppuccin-accents, theme

#let color-to-pikchr(
  color,
) = {
  return "0x" + color.opacify(100%).to-hex().slice(1)
}

#let pikchr-svg(
  cont,
) = {
  // Generate all color variables
  let color-variables = (:
    ..theme.colors,
    ..catppuccin-accents,
  )
    .pairs()
    .map(((key, value)) => {
      return strfmt(
        "${key} = {value}",
        key: key,
        value: color-to-pikchr(value),
      )
    })
    .join("\n")

  let pre-header = (
    color-variables,
    "color = $foreground",
  ).join("\n")
  let full-cont = (pre-header, cont).join("\n")
  return str(_raw_pikchr(full-cont).source).replace("font-size:initial;", "")
}


#let pikchr(
  cont,
  ..args,
) = context {
  // TODO: Provide default color variables
  let svg-src = pikchr-svg(cont)

  // Inject font family into the SVG
  let current-font = text.font
  let fallback-font = theme.fonts.sans.family
  let font-string = strfmt(
    `font-family="{current-font}"`.text,
    current-font: (current-font, fallback-font).join(", "),
  )
  // svg-src always starts with <svg ...>
  let pre = svg-src.slice(0, 4)
  let post = svg-src.slice(5)
  let new-svg-src = (pre, font-string, post).join(" ")
  image(bytes(new-svg-src), format: "svg", ..args)
}

#let pikchr-init(
  body,
) = {
  show raw.where(lang: "show-pikchr"): raw => {
    pikchr(raw.text)
  }

  body
}
