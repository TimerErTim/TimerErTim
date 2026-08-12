#import "../../look-and-feel/index.typ": get-theme, themes
#import "variants.typ": light-or, input-theme-name
#import "deps.typ": catppuccin

#let theme = get-theme(input-theme-name)

#let catppuccin-flavor = light-or(
  catppuccin.latte,
  catppuccin.mocha,
)
#let catppuccin-accents = (
  catppuccin-flavor
    .colors
    .pairs()
    .filter(((key, value)) => value.accent == true)
    .map(((key, value)) => (key, value.rgb))
    .to-dict()
)

#let color-cycle = (
  catppuccin-accents.blue,
  catppuccin-accents.green,
  catppuccin-accents.peach,
  catppuccin-accents.mauve,
  catppuccin-accents.red,
  catppuccin-accents.yellow,
  catppuccin-accents.lavender,
  catppuccin-accents.pink,
  catppuccin-accents.teal,
  catppuccin-accents.flamingo,
  catppuccin-accents.sky,
)

