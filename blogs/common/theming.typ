#import "../../look-and-feel/index.typ": get-theme, themes
#import "variants.typ": theme-name, light-or
#import "deps.typ": catppuccin

#let theme = get-theme(theme-name)

#let catppuccin-flavor = light-or(
  catppuccin.latte,
  catppuccin.mocha,
)
#let catppuccin-accents = catppuccin-flavor.colors.pairs().filter(((key, value)) => value.accent == true).map(((key, value)) => (key, value.rgb)).to-dict()

#let color-cycle = (
  catppuccin-accents.mauve,
  catppuccin-accents.teal,
  catppuccin-accents.peach,
  catppuccin-accents.rosewater,
  catppuccin-accents.green,
  catppuccin-accents.pink,
  catppuccin-accents.sky,
  catppuccin-accents.yellow,
  catppuccin-accents.flamingo,
  catppuccin-accents.red,
)
