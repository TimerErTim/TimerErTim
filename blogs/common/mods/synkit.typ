#import "../../../libs/synkit/lib.typ": *
#import "../theming.typ": theme
#import "../../../libs/synkit/lib.typ": garden as _garden, tree as _tree

#let tree = _tree.with(
  foreground-color: theme.colors.foreground,
  ref-color: theme.colors.foreground,
)
#let garden = _garden.with(
  foreground-color: theme.colors.foreground,
  ref-color: theme.colors.foreground,
)
