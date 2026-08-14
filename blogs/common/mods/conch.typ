#import "@preview/conch:0.1.0" as __conch: render-ansi
#import "../theming.typ": catppuccin-accents, theme
#import "../components/depth.typ": depth-shadow-block

#let terminal-frame(
  body,
  ..args,
) = {
  let color = theme.colors.border
  show: depth-shadow-block.with(
    color: color,
  )
  show: block.with(
    stroke: color + theme.layout.borderWidth.medium,
    radius: theme.layout.radius.medium,
  )
  __conch.terminal-frame(
    body,
    ..(
      width: 100%,
      theme: "catppuccin",
      font: theme.fonts.mono.family,
      ..args.named(),
    ),
  )
}
