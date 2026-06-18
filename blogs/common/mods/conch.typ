#import "@preview/conch:0.1.0" as __conch: render-ansi
#import "../theming.typ": theme
#import "../components/depth.typ": depth-shadow-block

#let terminal-frame(
  body,
  ..args,
) = {
  show: depth-shadow-block.with(
    color: theme.colors.neutral,
    inner-border: theme.layout.borderWidth.medium,
  )
  show: block.with(
    stroke: theme.colors.neutral + theme.layout.borderWidth.medium,
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
